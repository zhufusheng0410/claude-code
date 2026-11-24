# -*- coding: utf-8 -*-
"""tools.utils.mapping_finder 的单元测试。"""
import os
import shutil
import tempfile
import unittest

from tools.utils.mapping_finder import find_mapping_dir, find_mapping_file


class TestMappingFinder(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.tmp, True)

    def _touch(self, name):
        p = os.path.join(self.tmp, name)
        with open(p, "w", encoding="utf-8") as f:
            f.write("")
        return p

    def test_find_mapping_file_priority_and_skip_backup(self):
        self._touch("TA_DWS_模型_备份-20261001.xlsx")
        real_ta = self._touch("TA_DWS_模型.xlsx")
        real_hszta = self._touch("HSZTA_DWS_模型.xlsx")

        # 按候选顺序命中 TA，且跳过 _备份 文件
        self.assertEqual(
            find_mapping_file(self.tmp, ["ZTA", "TA", "HSZTA"], "_DWS_*.xlsx"),
            real_ta,
        )
        # 调换候选顺序命中 HSZTA
        self.assertEqual(
            find_mapping_file(self.tmp, ["HSZTA", "TA"], "_DWS_*.xlsx"),
            real_hszta,
        )

    def test_find_mapping_file_only_backup_returns_none(self):
        self._touch("O32_DWS_模型_备份.xlsx")
        self.assertIsNone(find_mapping_file(self.tmp, ["O32"], "_DWS_*.xlsx"))

    def test_find_mapping_file_missing_dir_returns_none(self):
        self.assertIsNone(
            find_mapping_file(os.path.join(self.tmp, "nope"), ["O32"], "_DWS_*.xlsx")
        )

    def test_find_mapping_dir_priority(self):
        d1 = os.path.join(self.tmp, "01-ZTA")
        d2 = os.path.join(self.tmp, "02-恒生份额登记系统_LOFTA")
        os.mkdir(d1)
        os.mkdir(d2)
        self._touch("01-ZTA_file.xlsx")  # 文件不应被当作目录命中

        self.assertEqual(find_mapping_dir(self.tmp, ["HSZTA", "ZTA"]), d1)
        self.assertEqual(find_mapping_dir(self.tmp, ["HSFTA", "LOFTA"]), d2)
        self.assertIsNone(find_mapping_dir(self.tmp, ["NO_MATCH"]))
        self.assertIsNone(find_mapping_dir(os.path.join(self.tmp, "nope"), ["ZTA"]))


if __name__ == "__main__":
    unittest.main()
