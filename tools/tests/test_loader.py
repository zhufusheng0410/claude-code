"""tools/core/loader.py 与 config 路径探测的回归测试。

覆盖 2026-10-29 的改动：
  · 按路径加载：同路径只执行一次（缓存），不同路径互不干扰；
  · 加载不存在文件时抛 ImportError 而非静默 None；
  · config 不再因默认 `/mnt/d` 在无该挂载的机器上抛异常，`missing_inputs()` 恒返回 list。
"""
import os
import sys
import tempfile
import unittest
from pathlib import Path

_REPO = Path(__file__).resolve().parents[2]
if str(_REPO) not in sys.path:
    sys.path.insert(0, str(_REPO))

from tools.core.loader import load  # noqa: E402
import tools.core.loader as loader_mod  # noqa: E402
import tools.config as config  # noqa: E402


class TestLoader(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        # ★ 2026-11-09（评审 B6）：测试必须还原全局状态。
        #   原先 load() 会把 mod_a / a_b 永久塞进 sys.modules，`test_ds_load_...`
        #   还会往 sys.path 插 ds-deploy 不还原 ⇒ 将来出现同名测试文件会互相污染。
        self._saved_modules = set(sys.modules)
        self._saved_path = list(sys.path)
        self.addCleanup(self._restore_globals)

    def _restore_globals(self):
        for name in set(sys.modules) - self._saved_modules:
            sys.modules.pop(name, None)
        sys.path[:] = self._saved_path
        # 缓存里指向本临时目录的条目也清掉（目录即将被删，留着只会让
        # 「sys.modules 里没有但 load() 命中缓存」的不变量失效）。
        tmp = os.path.normcase(os.path.realpath(self.tmp.name))
        for key in [k for k in loader_mod._CACHE if k.startswith(tmp)]:
            loader_mod._CACHE.pop(key, None)

    def _write(self, name, body):
        p = os.path.join(self.tmp.name, name)
        with open(p, "w", encoding="utf-8") as f:
            f.write(body)
        return p

    def test_same_path_is_cached(self):
        p = self._write("mod_a.py", "VALUE = 1\n")
        a = load(p)
        b = load(p)
        self.assertIs(a, b, "同一路径应复用同一模块对象")

    def test_distinct_paths_distinct_modules(self):
        p1 = self._write("mod_x.py", "NAME = 'x'\n")
        p2 = self._write("mod_y.py", "NAME = 'y'\n")
        self.assertEqual(load(p1).NAME, "x")
        self.assertEqual(load(p2).NAME, "y")
        self.assertIsNot(load(p1), load(p2))

    def test_hyphen_filename_gets_safe_module_name(self):
        p = self._write("a-b.py", "OK = True\n")
        mod = load(p)
        self.assertTrue(mod.OK)
        self.assertEqual(mod.__name__, "a_b")

    def test_ds_load_is_the_same_function(self):
        deploy = _REPO / "tools" / "ds-deploy"
        if str(deploy) not in sys.path:
            sys.path.insert(0, str(deploy))
        import ds_load
        self.assertIs(ds_load.load, load)

    def test_missing_file_raises(self):
        with self.assertRaises(ImportError):
            load(os.path.join(self.tmp.name, "nope.py"))

    def test_failed_load_does_not_pollute_sys_modules(self):
        """B3 回归：导入期抛异常后，sys.modules 不得残留半初始化对象。

        ★ 原实现先 `setdefault` 再 exec ⇒ 失败后 `sys.modules['boom_mod']`
          仍是那个半成品；修复后重试成功拿到的是另一个对象，
          `sys.modules[name] is mod` 为 False（dataclasses/get_type_hints 会拿错）。
        """
        p = self._write("boom_mod.py", "raise RuntimeError('boom')\n")
        with self.assertRaises(RuntimeError):
            load(p)
        self.assertNotIn("boom_mod", sys.modules,
                         "失败的模块不能留在 sys.modules")

        self._write("boom_mod.py", "OK = 1\n")
        mod = load(p)
        self.assertEqual(mod.OK, 1)
        self.assertIs(sys.modules["boom_mod"], mod,
                      "重试成功后 sys.modules 必须指向同一个模块对象")


class TestConfigPaths(unittest.TestCase):
    def test_detect_d_base_returns_path_string(self):
        # 行为级断言（不耦合内部候选列表实现）：
        # 探测结果必须是可直接参与 os.path.join 的字符串。
        base = config._detect_d_base()
        self.assertIsInstance(base, str)
        self.assertTrue(base)
        self.assertTrue(os.path.join(base, "x"))

    def test_missing_inputs_returns_list(self):
        # 无论本机有没有 D 盘/交付文档，都必须返回 list（不能抛异常）。
        self.assertIsInstance(config.missing_inputs(), list)

    def test_project_base_is_absolute(self):
        self.assertTrue(os.path.isabs(config.PROJECT_BASE))


class TestMissingInputsLayering(unittest.TestCase):
    """`missing_inputs(layers)` 按层只查该层需要的目录（评审 A2 回归）。

    ★ 原实现**无条件**检查 3 个目录 ⇒ `--layer ODS`（只需调研文档）在
      「只交付了一半目录」的机器上被无关的 DWD/DWS MAPPING 目录拦住并 exit 1。
    """

    _ATTRS = ("PROJECT_BASE", "SURVEY_DIR", "DWD_MAPPING_BASE", "DWS_MAPPING_BASE")

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        (root / "01-系统调研文档" / "O32").mkdir(parents=True)
        self._saved = {a: getattr(config, a) for a in self._ATTRS}
        config.PROJECT_BASE = str(root)
        config.SURVEY_DIR = str(root / "01-系统调研文档")
        config.DWD_MAPPING_BASE = str(root / "04-源与目标映射MAPPING/01-DWD")
        config.DWS_MAPPING_BASE = str(root / "04-源与目标映射MAPPING/02-DWS")
        self.addCleanup(self._restore)

    def _restore(self):
        for a, v in self._saved.items():
            setattr(config, a, v)

    def test_ods_ignores_mapping_dirs(self):
        self.assertEqual(config.missing_inputs("ODS"), [])

    def test_dwd_only_reports_dwd_mapping(self):
        probs = config.missing_inputs("DWD")
        self.assertEqual(len(probs), 1)
        self.assertIn("DWD MAPPING", probs[0])

    def test_dws_only_reports_dws_mapping(self):
        probs = config.missing_inputs("DWS")
        self.assertEqual(len(probs), 1)
        self.assertIn("DWS MAPPING", probs[0])

    def test_none_and_all_mean_everything(self):
        self.assertEqual(len(config.missing_inputs()), 2)
        self.assertEqual(len(config.missing_inputs("ALL")), 2)

    def test_collection_form(self):
        self.assertEqual(config.missing_inputs(["ODS", "DWS"]),
                         config.missing_inputs("DWS"))


if __name__ == "__main__":
    unittest.main()
