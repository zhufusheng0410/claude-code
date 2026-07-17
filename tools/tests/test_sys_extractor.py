"""系统简称提取单元测试（含 #6 移除未使用 config_map 参数后的行为）"""

import unittest

from tools.utils.sys_extractor import extract_sys_name


class TestExtractSysName(unittest.TestCase):
    def test_dwd_from_dir(self):
        self.assertEqual(extract_sys_name("DWD", "/x/01-ZTA"), "ZTA")
        self.assertEqual(extract_sys_name("DWD", "/x/02-O32"), "O32")

    def test_dwd_single_segment(self):
        self.assertEqual(extract_sys_name("DWD", "/x/HSZTA"), "HSZTA")

    def test_dws_from_filename(self):
        self.assertEqual(extract_sys_name("DWS", "/x/O32_DWS_xxx.xlsx"), "O32")

    def test_ods_returns_none(self):
        self.assertIsNone(extract_sys_name("ODS", "/x"))


if __name__ == "__main__":
    unittest.main()
