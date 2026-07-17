"""MAPPING 解析单元测试：动态列头定位、注释行跳过、源表收集、过滤条件剥离。

覆盖 N1（_parse_sheet_df 复用 df）与 mapping.py 的解析逻辑。
"""

import os
import shutil
import tempfile
import unittest

import pandas as pd

from tools.parser.mapping import parse_mapping_sheet, _extract_filter

# 列头：目标字段英文名(0) ... 源表英文名(10) ... 源字段英文名(12) 过滤条件(13)
_HEADER = [
    "目标字段英文名", "目标字段中文名", "目标字段类型", "序号", "主键", "组别",
    "JOIN方式", "关联条件", "源表别名", "源表英文名", "源表中文名",
    "源字段英文名", "源字段中文名", "过滤条件",
]


def _write_mapping_xlsx(path):
    data = [
        ["目标表中文名称", "单位库存表"],
        ["目标表英文名称", "DWD_AST_TUNITSTOCK_PFD"],
        _HEADER,
        ["C_DATE", "日期", "STRING", "1", "N", "1", "MAIN TABLE", "",
         "A", "ODS_O32_TUNITSTOCK_PFD", "单位库存", "L_DATE", "日期", ""],
        ["C_AMT", "金额", "DECIMAL(18,2)", "2", "N", "1", "LEFT JOIN",
         "ON A.ID=B.ID", "B", "ODS_O32_TPRICE_PFD", "价格", "PRICE", "价格",
         "WHERE A.FLAG='Y'"],
        # 注释行：目标字段英文名含中文，应被跳过
        ["初始化第1组插入历史数据", "", "", "", "", "", "", "", "", "", "", "", "", ""],
    ]
    pd.DataFrame(data).to_excel(path, sheet_name="Sheet1", header=False, index=False)


class TestParseMappingSheet(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.path = os.path.join(self.tmp, "m.xlsx")
        _write_mapping_xlsx(self.path)

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_metadata(self):
        s = parse_mapping_sheet(self.path, "Sheet1")
        self.assertEqual(s.tgt_table, "DWD_AST_TUNITSTOCK_PFD")
        self.assertEqual(s.tgt_table_cn, "单位库存表")

    def test_comment_row_skipped(self):
        s = parse_mapping_sheet(self.path, "Sheet1")
        names = [m.tgt_name for m in s.mappings]
        self.assertIn("C_DATE", names)
        self.assertIn("C_AMT", names)
        self.assertNotIn("初始化第1组插入历史数据", names)
        self.assertEqual(len(s.mappings), 2)

    def test_source_tables_collected(self):
        s = parse_mapping_sheet(self.path, "Sheet1")
        self.assertIn("ODS_O32_TUNITSTOCK_PFD", s.source_tables)
        self.assertIn("ODS_O32_TPRICE_PFD", s.source_tables)

    def test_filter_stripped_at_parse(self):
        s = parse_mapping_sheet(self.path, "Sheet1")
        amt = next(m for m in s.mappings if m.tgt_name == "C_AMT")
        # WHERE 前缀应在解析层被 _extract_filter 剥离
        self.assertFalse(amt.filter_cond.startswith("WHERE "))
        self.assertTrue(amt.filter_cond.startswith("A.FLAG"))


class TestExtractFilter(unittest.TestCase):
    def test_strip_where(self):
        self.assertEqual(_extract_filter("WHERE A.X=1"), "A.X=1")

    def test_strip_and(self):
        self.assertEqual(_extract_filter("AND A.X=1"), "A.X=1")

    def test_empty(self):
        self.assertEqual(_extract_filter(""), "")

    def test_plain_unchanged(self):
        self.assertEqual(_extract_filter("A.X=1"), "A.X=1")


if __name__ == "__main__":
    unittest.main()
