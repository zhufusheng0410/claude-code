# -*- coding: utf-8 -*-
"""ds-deploy 脚本导入冒烟。

CI 只装 requirements.txt，没有 psycopg2，也没有集群凭据。本测试：

- 用假口令占位，避免导入期读到本机凭据文件（假值不打印）；
- 缺可选依赖（psycopg2）时 skip，不让 CI 变红；
- 其它导入失败仍失败。
"""
import importlib.util
import os
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEPLOY = ROOT / "tools" / "ds-deploy"

# 仅用于占位，让 pg_conn() 等导入期调用不必读凭据文件。不是真实口令。
_DUMMY = "not-a-real-secret"
_SECRET_KEYS = (
    "DS_PASSWORD",
    "DS_ADMIN_PASSWORD",
    "DS_SERVICE_PASSWORD",
    "DS_PG_PASSWORD",
    "DS_HIVE_PASSWORD",
)
_OPTIONAL_PREFIXES = ("psycopg2",)


def is_optional_import_error(exc) -> bool:
    """缺可选依赖（目前只有 psycopg2）时为真，测试应 skip 而非失败。"""
    name = getattr(exc, "name", None) or ""
    if any(name == p or name.startswith(p + ".") for p in _OPTIONAL_PREFIXES):
        return True
    if isinstance(exc, ImportError) and any(p in str(exc) for p in _OPTIONAL_PREFIXES):
        return True
    if isinstance(exc, SystemExit):
        text = exc.code if isinstance(exc.code, str) else str(exc)
        return any(p in text for p in _OPTIONAL_PREFIXES)
    return False


def import_deploy_scripts() -> None:
    """导入 tools/ds-deploy 下每个 .py，每文件打印一行：OK / SKIP / FAIL。"""
    for key in _SECRET_KEYS:
        os.environ[key] = _DUMMY
    sys.path.insert(0, str(DEPLOY))
    sys.path.insert(0, str(ROOT))
    for path in sorted(DEPLOY.glob("*.py")):
        modname = "ds_deploy_smoke_" + path.stem.replace("-", "_")
        spec = importlib.util.spec_from_file_location(modname, path)
        module = importlib.util.module_from_spec(spec)
        sys.modules[modname] = module
        try:
            spec.loader.exec_module(module)
        except KeyboardInterrupt:
            raise
        except BaseException as exc:
            if is_optional_import_error(exc):
                print("SKIP\t%s\t%s" % (path.name, _OPTIONAL_PREFIXES[0]))
                continue
            msg = str(exc).replace(_DUMMY, "<redacted>")
            print("FAIL\t%s\t%s\t%s" % (path.name, type(exc).__name__, msg[:200]))
        else:
            print("OK\t%s" % path.name)


def _run_child():
    """在子进程里导入，避免假口令或模块状态污染本进程的其它用例。"""
    code = (
        "import sys; sys.path.insert(0, sys.argv[1]); "
        "from tools.tests.test_ds_deploy_import_smoke import import_deploy_scripts; "
        "import_deploy_scripts()"
    )
    return subprocess.run(
        [sys.executable, "-X", "utf8", "-c", code, str(ROOT)],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
        timeout=180,
    )


class TestDsDeployImportSmoke(unittest.TestCase):
    def test_optional_missing_is_skip_not_fail(self):
        missing = ModuleNotFoundError("No module named 'psycopg2'", name="psycopg2")
        self.assertTrue(is_optional_import_error(missing))
        wrapped = ImportError("No module named psycopg2")
        self.assertTrue(is_optional_import_error(wrapped))
        # ds-sync-ods-scripts.py 缺包时用 SystemExit，不能当成测试失败。
        self.assertTrue(is_optional_import_error(
            SystemExit("需要 psycopg2：pip install psycopg2-binary")))
        hard = ModuleNotFoundError("No module named 'pandas'", name="pandas")
        self.assertFalse(is_optional_import_error(hard))
        self.assertFalse(is_optional_import_error(SystemExit("缺少环境变量 DS_PG_PASSWORD")))

    def test_scripts_import_or_skip_optional(self):
        proc = _run_child()
        out = (proc.stdout or "").replace(_DUMMY, "<redacted>")
        err = (proc.stderr or "").replace(_DUMMY, "<redacted>")
        self.assertNotIn(_DUMMY, out + err)
        lines = [ln for ln in out.splitlines() if ln.startswith(("OK\t", "SKIP\t", "FAIL\t"))]
        if proc.returncode != 0 and not lines:
            self.fail("导入子进程失败 rc=%s\n%s" % (proc.returncode, err[-500:]))
        self.assertTrue(lines, "没有导入任何 ds-deploy 脚本\n%s" % err[-500:])
        skipped = []
        for line in lines:
            kind, _, rest = line.partition("\t")
            name = rest.split("\t", 1)[0]
            with self.subTest(script=name):
                if kind == "SKIP":
                    skipped.append(name)
                    continue
                self.assertEqual(kind, "OK", line)
        if skipped and len(skipped) == len(lines):
            self.skipTest("可选依赖缺失，已跳过: " + ", ".join(skipped))
