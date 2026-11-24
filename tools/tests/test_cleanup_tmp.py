# -*- coding: utf-8 -*-
"""tools.cleanup_tmp 的单元测试。"""
import os
import shutil
import tempfile
import time
import unittest
from pathlib import Path

from tools.cleanup_tmp import PROTECTED_NAMES, cleanup_tmp, select_candidates


class TestCleanupTmp(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp, True)
        self.now = time.time()

    def _make_file(self, name: str, age_days: float, content: str = "x") -> Path:
        p = self.tmp / name
        p.write_text(content, encoding="utf-8")
        ts = self.now - age_days * 86400
        os.utime(p, (ts, ts))
        return p

    def _make_dir(self, name: str, age_days: float) -> Path:
        d = self.tmp / name
        d.mkdir()
        f = d / "inner.txt"
        f.write_text("data", encoding="utf-8")
        ts = self.now - age_days * 86400
        os.utime(f, (ts, ts))
        os.utime(d, (ts, ts))
        return d

    def test_protected_entries_never_selected(self):
        for pname in PROTECTED_NAMES:
            if pname.endswith(".json"):
                self._make_file(pname, age_days=365)
            else:
                self._make_dir(pname, age_days=365)
        old_file = self._make_file("old-report.json", age_days=120)

        candidates, protected = select_candidates(
            self.tmp, max_age_days=30, max_items=0, now=self.now
        )
        self.assertEqual(candidates, [old_file])
        self.assertEqual({p.name for p in protected}, set(PROTECTED_NAMES))

    def test_age_and_max_items_union(self):
        old_dir = self._make_dir("backup-old", age_days=100)
        mid_file = self._make_file("mid.json", age_days=20)
        new_file = self._make_file("new.json", age_days=1)

        # max_age_days=90 命中 old_dir；剩余 2 个条目 > max_items=1 ⇒ 最旧的 mid_file 也命中
        candidates, _ = select_candidates(
            self.tmp, max_age_days=90, max_items=1, now=self.now
        )
        self.assertEqual(candidates, sorted([old_dir, mid_file], key=lambda p: p.name))
        self.assertNotIn(new_file, candidates)

    def test_dry_run_does_not_delete_and_apply_deletes(self):
        old_file = self._make_file("expired.json", age_days=100, content="hello")
        old_dir = self._make_dir("expired-dir", age_days=100)
        fresh = self._make_file("fresh.json", age_days=2, content="keep")
        prot = self._make_dir("ds-recovery", age_days=200)

        dry = cleanup_tmp(self.tmp, max_age_days=90, apply=False, now=self.now)
        self.assertEqual(dry["removed"], [])
        self.assertEqual(set(dry["candidates"]), {"expired.json", "expired-dir"})
        self.assertTrue(old_file.exists())
        self.assertTrue(old_dir.exists())

        real = cleanup_tmp(self.tmp, max_age_days=90, apply=True, now=self.now)
        self.assertEqual(set(real["removed"]), {"expired.json", "expired-dir"})
        self.assertEqual(real["failed"], [])
        self.assertFalse(old_file.exists())
        self.assertFalse(old_dir.exists())
        self.assertTrue(fresh.exists())
        self.assertTrue(prot.exists())

    def test_negative_args_raise(self):
        with self.assertRaises(ValueError):
            select_candidates(self.tmp, max_age_days=-1)
        with self.assertRaises(ValueError):
            select_candidates(self.tmp, max_items=-1)


if __name__ == "__main__":
    unittest.main()
