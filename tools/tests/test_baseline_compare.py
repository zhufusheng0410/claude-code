# -*- coding: utf-8 -*-
"""`tools/tests/baseline_compare.py` 的单元测试（阶段 1 产物基线）。"""
import hashlib
import os
import tempfile
import unittest
import unittest.mock
from pathlib import Path

from tools.tests import baseline_compare as bc


class TestCompare(unittest.TestCase):
    def test_added_removed_changed(self):
        diff = bc.compare({'a': '1', 'b': '2', 'c': '3'},
                          {'a': '1', 'b': 'X', 'd': '4'})
        self.assertEqual(diff['added'], ['d'])
        self.assertEqual(diff['removed'], ['c'])
        self.assertEqual(diff['changed'], ['b'])
        self.assertFalse(bc.is_empty(diff))

    def test_identical_is_empty(self):
        self.assertTrue(bc.is_empty(bc.compare({'a': '1'}, {'a': '1'})))


class TestSnapshot(unittest.TestCase):
    def test_skips_cache_dirs_and_hashes_content(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'x.sh').write_text('a', encoding='utf-8')
            (root / '__pycache__').mkdir()
            (root / '__pycache__' / 'y.pyc').write_bytes(b'z')
            (root / '.dx-tmp').mkdir()
            (root / '.dx-tmp' / 'r.json').write_text('{}', encoding='utf-8')
            snap = bc.snapshot(root)
        self.assertEqual(list(snap), ['x.sh'])
        self.assertEqual(snap['x.sh'], hashlib.sha256(b'a').hexdigest())

    def test_nested_paths_are_posix_relative(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'sub').mkdir()
            (root / 'sub' / 'a.sql').write_text('x', encoding='utf-8')
            self.assertEqual(list(bc.snapshot(root)), ['sub/a.sql'])


class TestMainGate(unittest.TestCase):
    """默认不启用：没有 DW_BASELINE 时必须跳过，而不是误报差异。"""

    def test_disabled_without_env(self):
        with unittest.mock.patch.dict(os.environ, {}, clear=False):
            os.environ.pop('DW_BASELINE', None)
            self.assertEqual(bc.main(['a', 'b']), 2)

    def test_save_then_compare_roundtrip(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td) / 'out'
            root.mkdir()
            (root / 'a.sh').write_text('one', encoding='utf-8')
            base = Path(td) / 'base.json'
            env = {'DW_BASELINE': '1'}
            with unittest.mock.patch.dict(os.environ, env):
                self.assertEqual(bc.main(['--save', str(base), str(root)]), 0)
                self.assertEqual(bc.main([str(base), str(root)]), 0)
                (root / 'a.sh').write_text('two', encoding='utf-8')
                self.assertEqual(bc.main([str(base), str(root)]), 1)


if __name__ == '__main__':
    unittest.main()
