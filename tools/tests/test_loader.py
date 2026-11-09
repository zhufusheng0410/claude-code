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
import tools.config as config  # noqa: E402


class TestLoader(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)

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


class TestConfigPaths(unittest.TestCase):
    def test_candidates_non_empty(self):
        self.assertTrue(config._d_base_candidates(), "至少应有一个候选根目录")

    def test_missing_inputs_returns_list(self):
        # 无论本机有没有 D 盘/交付文档，都必须返回 list（不能抛异常）。
        self.assertIsInstance(config.missing_inputs(), list)

    def test_project_base_is_absolute(self):
        self.assertTrue(os.path.isabs(config.PROJECT_BASE))


if __name__ == "__main__":
    unittest.main()
