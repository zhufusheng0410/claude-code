# -*- coding: utf-8 -*-
"""DS 部署工具链的单元测试。

★ 为什么需要（2026-10-22 代码审查 MEDIUM-6）
    `tools/ds-deploy/` 整个目录**零测试覆盖**，而它直接操作 DolphinScheduler
    元库与 Hive —— 改动无安全网，重构极易引入静默回归。

    本文件覆盖三类**纯函数**（不需要 DS 集群、不发网络请求）：
      1. `ds_config` —— 凭据解析（优先级、缺失即失败、文件格式）
      2. `ds_text`  —— 行尾规范化（CRLF → LF）
      3. `ds_client` 的响应取值助手（防御性取值）

    涉及网络/集群的路径（登录、建工作流、排版）不在单测覆盖范围内，
    需用 `ds-verify-dwd-layout.py` 之类对真实集群回读校验。
"""
import collections
import importlib
import importlib.util
import os
import pathlib
import sys
import tempfile
import unittest

_REPO = pathlib.Path(__file__).resolve().parents[2]
_DEPLOY = _REPO / "tools" / "ds-deploy"
sys.path.insert(0, str(_DEPLOY))
sys.path.insert(0, str(_REPO))

import ds_config  # noqa: E402
import ds_text  # noqa: E402
from ds_client import (  # noqa: E402
    DSClientError, dependence_of, lst_of, project_code, task_definitions,
)


def _reload_ds_config():
    """重新加载 ds_config（清掉凭据缓存），供改环境变量的用例使用。"""
    return importlib.reload(ds_config)


def _load_module(name):
    """按文件路径加载 ds-deploy 下的模块（文件名带连字符，不能普通 import）。"""
    spec = importlib.util.spec_from_file_location(name, str(_DEPLOY / (name + ".py")))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class TestDsConfigSecrets(unittest.TestCase):
    """凭据解析：优先级 + 缺失即失败。"""

    def setUp(self):
        self._saved = {k: os.environ.pop(k, None) for k in ds_config.SECRET_KEYS}
        # ★ 隔离：把凭据文件指向**不存在的临时路径** —— 否则本机若存在
        #   tools/ds-deploy/.env.local 或 ~/.dw-secrets.env，测试会读到真实
        #   凭据（既让「缺失即失败」用例失效，也等于在测试里碰生产口令）。
        mod = _reload_ds_config()
        self.mod = mod
        self._saved_files = {}
        for attr in ("LOCAL_ENV_FILE", "HOME_ENV_FILE"):
            path = pathlib.Path(tempfile.gettempdir()) / (
                "nonexistent-credential-file-%d" % id(self))
            self._saved_files[attr] = getattr(mod, attr)
            setattr(mod, attr, path)
        mod._FILE_CACHE = None

    def tearDown(self):
        for k, v in self._saved.items():
            if v is None:
                os.environ.pop(k, None)
            else:
                os.environ[k] = v
        mod = _reload_ds_config()
        for attr, path in self._saved_files.items():
            setattr(mod, attr, path)
        mod._FILE_CACHE = None

    def test_missing_secret_raises_with_guidance(self):
        """★ 核心保证：缺凭据时**报错**，且错误信息给出三种配置方式。

        源码里不再有明文缺省值 —— 若这里退化成「用弱缺省密码」，
        整个凭据改造就失去意义。
        """
        mod = self.mod
        with self.assertRaises(mod.SecretMissingError) as cm:
            mod.require_secret("DS_PASSWORD")
        msg = str(cm.exception)
        self.assertIn("DS_PASSWORD", msg)
        # 提示了两种文件配置方式（隔离后路径是临时文件，故断言"提及文件方式"
        # 而非具体文件名）
        self.assertIn("gitignore", msg)
        self.assertEqual(msg.count("DS_PASSWORD=..."), 2)   # 两种文件方式各一次
        self.assertIn("export DS_PASSWORD", msg)             # 环境变量方式

    def test_env_var_takes_priority(self):
        mod = self.mod
        os.environ["DS_PASSWORD"] = "from_env"
        self.assertEqual(mod.require_secret("DS_PASSWORD"), "from_env")

    def test_preflight_lists_all_missing(self):
        mod = self.mod
        with self.assertRaises(mod.SecretMissingError) as cm:
            mod.preflight("DS_PASSWORD", "DS_PG_PASSWORD")
        msg = str(cm.exception)
        self.assertIn("DS_PASSWORD", msg)
        self.assertIn("DS_PG_PASSWORD", msg)

    def test_preflight_passes_when_present(self):
        mod = self.mod
        os.environ["DS_PASSWORD"] = "x"
        self.assertIsNone(mod.preflight("DS_PASSWORD"))

    def test_env_file_parsed(self):
        """凭据文件是 KEY=VALUE 行格式。"""
        mod = self.mod
        with tempfile.NamedTemporaryFile("w", suffix=".env", delete=False,
                                         encoding="utf-8") as f:
            f.write("# 注释行\n")
            f.write("DS_PASSWORD=plain_value\n")
            f.write("DS_ADMIN_PASSWORD='quoted_value'\n")
            f.write("DS_PG_PASSWORD=\"dq_value\"\n")
            f.write("\n")                    # 空行
            f.write("no_equals_sign\n")     # 无 = 的行应被忽略
            path = f.name
        try:
            parsed = mod._parse_env_file(pathlib.Path(path))
            self.assertEqual(parsed["DS_PASSWORD"], "plain_value")
            self.assertEqual(parsed["DS_ADMIN_PASSWORD"], "quoted_value")
            self.assertEqual(parsed["DS_PG_PASSWORD"], "dq_value")
            self.assertNotIn("no_equals_sign", parsed)
            self.assertNotIn("# 注释行", parsed)
        finally:
            os.unlink(path)

    def test_env_file_value_may_contain_equals(self):
        """口令里含 `=` 时只按第一个 `=` 切分。"""
        mod = self.mod
        with tempfile.NamedTemporaryFile("w", suffix=".env", delete=False,
                                         encoding="utf-8") as f:
            f.write("DS_PASSWORD=a=b=c\n")
            path = f.name
        try:
            parsed = mod._parse_env_file(pathlib.Path(path))
            self.assertEqual(parsed["DS_PASSWORD"], "a=b=c")
        finally:
            os.unlink(path)

    def test_missing_env_file_returns_empty(self):
        mod = self.mod
        self.assertEqual(mod._parse_env_file(
            pathlib.Path("/nonexistent/.env")), {})


class TestDsTextNewlines(unittest.TestCase):
    """行尾规范化：CRLF / 裸 CR → LF。"""

    def test_crlf_to_lf(self):
        self.assertEqual(ds_text.normalize_newlines("a\r\nb"), "a\nb")

    def test_lone_cr_to_lf(self):
        self.assertEqual(ds_text.normalize_newlines("a\rb"), "a\nb")

    def test_mixed(self):
        self.assertEqual(ds_text.normalize_newlines("a\r\nb\rc\nd"),
                         "a\nb\nc\nd")

    def test_lf_unchanged(self):
        self.assertEqual(ds_text.normalize_newlines("a\nb"), "a\nb")

    def test_read_script_normalizes(self):
        """★ 真实场景：Windows 源 / git autocrlf 产生的 CRLF .sh。

        内联进 DS rawScript 后，残留的 \\r 会让 Linux worker 报
        bad interpreter / 命令未找到。
        """
        with tempfile.NamedTemporaryFile("wb", suffix=".sh", delete=False) as f:
            f.write(b"#!/bin/sh\r\nset -e\r\n")
            path = f.name
        try:
            content = ds_text.read_script(path)
            self.assertNotIn("\r", content)
            self.assertEqual(content, "#!/bin/sh\nset -e\n")
        finally:
            os.unlink(path)

    def test_read_script_no_trailing_newline_added(self):
        """printf 语义：不多加换行（JSON 文件尾随换行虽无害，但保持精确）。"""
        with tempfile.NamedTemporaryFile("wb", suffix=".sh", delete=False) as f:
            f.write(b"#!/bin/sh")
            path = f.name
        try:
            self.assertEqual(ds_text.read_script(path), "#!/bin/sh")
        finally:
            os.unlink(path)


class TestResponseHelpers(unittest.TestCase):
    """DS 响应取值助手：防御性取值 + 可读报错。"""

    def test_lst_of_dict_form(self):
        res = {"data": {"totalList": [{"name": "dw"}]}}
        self.assertEqual(lst_of(res), [{"name": "dw"}])

    def test_lst_of_list_form(self):
        res = {"data": [{"name": "dw"}]}
        self.assertEqual(lst_of(res), [{"name": "dw"}])

    def test_lst_of_missing_returns_empty(self):
        self.assertEqual(lst_of({}), [])
        self.assertEqual(lst_of({"data": {}}), [])
        self.assertEqual(lst_of(None), [])

    def test_project_code_found(self):
        res = {"data": {"totalList": [{"name": "dw", "code": 123},
                                      {"name": "other", "code": 456}]}}
        self.assertEqual(project_code(res, "dw"), 123)

    def test_project_code_missing_raises_readable_error(self):
        """★ 核心保证：找不到项目时抛 **DSClientError**（可读），
        而不是裸 next() 的 StopIteration（无法判断是项目名错还是结构变了）。"""
        res = {"data": {"totalList": [{"name": "other", "code": 1}]}}
        with self.assertRaises(DSClientError) as cm:
            project_code(res, "dw")
        self.assertIn("dw", str(cm.exception))

    def test_task_definitions_from_full_response(self):
        res = {"data": {"taskDefinitionList": [{"name": "t1"}]}}
        self.assertEqual(task_definitions(res), [{"name": "t1"}])

    def test_task_definitions_from_unwrapped_data(self):
        """DS 详情接口：GET 返回的 data 里直接含 taskDefinitionList。"""
        res = {"taskDefinitionList": [{"name": "t1"}]}
        self.assertEqual(task_definitions(res), [{"name": "t1"}])

    def test_task_definitions_json_string_form(self):
        """DS 偶尔把整个数组当 JSON 字符串返回。"""
        res = {"data": {"taskDefinitionList": '[{"name": "t1"}]'}}
        self.assertEqual(task_definitions(res), [{"name": "t1"}])

    def test_task_definitions_missing_returns_empty(self):
        self.assertEqual(task_definitions({}), [])
        self.assertEqual(task_definitions({"data": {}}), [])
        self.assertEqual(task_definitions({"data": {"taskDefinitionList": None}}), [])

    def test_dependence_of_nested(self):
        task = {"taskParams": {"dependence": {"dependTaskList": [{"g": 1}]}}}
        self.assertEqual(dependence_of(task), [{"g": 1}])

    def test_dependence_of_json_string_params(self):
        """★ 回归：taskParams 为 JSON 字符串时不能静默当成「无依赖」
        （DWS→DWD 删除前检查靠它，漏判 = 放行删除）。"""
        task = {"taskParams": '{"dependence": {"dependTaskList": [{"g": 1}]}}'}
        self.assertEqual(dependence_of(task), [{"g": 1}])
        task = {"taskParams": {"dependence": '{"dependTaskList": [{"g": 2}]}'}}
        self.assertEqual(dependence_of(task), [{"g": 2}])

    def test_dependence_of_missing_returns_empty(self):
        """★ 原来 t["taskParams"]["dependence"]["dependTaskList"] 三层裸取键，
        缺 dependence 时 KeyError。"""
        self.assertEqual(dependence_of({}), [])
        self.assertEqual(dependence_of({"taskParams": {}}), [])
        self.assertEqual(dependence_of({"taskParams": {"dependence": {}}}), [])


class TestCodeAllocator(unittest.TestCase):
    """DWD 任务 code 的全局唯一分配器（HIGH-4 修 bug）。"""

    def setUp(self):
        self.mod = _load_module("ds-rebuild-from-inventory")

    def test_codes_are_unique(self):
        alloc = self.mod._CodeAllocator(700000000)
        codes = [alloc.next() for _ in range(500)]
        self.assertEqual(len(set(codes)), 500)

    def test_same_length_names_no_longer_collide(self):
        """★ 回归：原实现按 len(工作流名) 做偏移 ⇒ 同长度名必然撞码。"""
        alloc = self.mod._CodeAllocator(700000000)
        codes_a = [alloc.next() for _ in range(3)]
        codes_b = [alloc.next() for _ in range(3)]
        self.assertEqual(len(set(codes_a + codes_b)), 6)

    def test_reserved_codes_are_skipped(self):
        alloc = self.mod._CodeAllocator(700000000)
        alloc.reserve(700000000)
        self.assertNotEqual(alloc.next(), 700000000)


class TestBreakCycles(unittest.TestCase):
    """依赖环打断（HIGH-5 修 bug：原实现只处理 2-环）。"""

    def setUp(self):
        self.mod = _load_module("ds-deploy-dwd-workflow")

    def _has_cycle(self, edges):
        adj = collections.defaultdict(set)
        for a, b in edges:
            adj[a].add(b)
        return bool(self.mod._find_simple_cycles(adj))

    def test_two_cycle_broken(self):
        kept, dropped = self.mod.break_cycles(None, [("A", "B"), ("B", "A")])
        self.assertEqual(len(dropped), 1)
        self.assertFalse(self._has_cycle(kept))

    def test_three_cycle_broken(self):
        """★ 原实现只找 2-环 ⇒ 3-环原样留在图里 ⇒ DS 建图报 50019。"""
        kept, dropped = self.mod.break_cycles(
            None, [("A", "B"), ("B", "C"), ("C", "A")])
        self.assertTrue(dropped)
        self.assertFalse(self._has_cycle(kept))

    def test_four_cycle_broken(self):
        kept, dropped = self.mod.break_cycles(
            None, [("A", "B"), ("B", "C"), ("C", "D"), ("D", "A")])
        self.assertTrue(dropped)
        self.assertFalse(self._has_cycle(kept))

    def test_acyclic_edges_untouched(self):
        kept, dropped = self.mod.break_cycles(None, [("A", "B"), ("B", "C")])
        self.assertEqual(dropped, [])
        self.assertEqual(len(kept), 2)

    def test_two_independent_cycles(self):
        kept, dropped = self.mod.break_cycles(
            None, [("A", "B"), ("B", "A"), ("C", "D"), ("D", "C")])
        self.assertEqual(len(dropped), 2)
        self.assertFalse(self._has_cycle(kept))


if __name__ == "__main__":
    unittest.main()
