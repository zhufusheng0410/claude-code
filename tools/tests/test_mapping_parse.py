"""MAPPING 解析单元测试：动态列头定位、注释行跳过、源表收集、过滤条件剥离。

覆盖 N1（_parse_sheet_df 复用 df）与 mapping.py 的解析逻辑。
"""

import os
import shutil
import tempfile
import time
import unittest

import pandas as pd

from tools.parser.mapping import (
    _parse_xlsx_sheets, parse_mapping_sheet, _extract_filter,
)
from tools.utils.excel_reader import (
    CalamineWorkbook, norm_cell, read_workbook_sheets as calamine_read_workbook,
)

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


def _write_mapping_xlsx_numeric(path):
    """数值/NA 文本混合夹具：序号与组别写数字，映射规则列写文本 'NULL'。"""
    data = [
        ["目标表中文名称", "单位库存表"],
        ["目标表英文名称", "DWD_AST_TUNITSTOCK_PFD"],
        _HEADER + ["映射规则"],
        ["C_DATE", "日期", "STRING", 1, "N", 1, "MAIN TABLE", "",
         "A", "ODS_O32_TUNITSTOCK_PFD", "单位库存", "L_DATE", "日期", "", ""],
        ["SSYS", "源系统", "STRING", 2, "N", 1, "MAIN TABLE", "",
         "", "", "", "", "", "", "NULL"],
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


class TestXlsxSheetsDiskCache(unittest.TestCase):
    """★ 2026-10-18：_parse_xlsx_sheets 磁盘缓存（命中 / 失效 / 禁用）回归。

    缓存为文件级：(fingerprint, mtime_ns, size) 任一变化即重新解析；
    DW_MAPPING_CACHE_DIR 把缓存目录隔离到临时目录，DW_NO_MAPPING_CACHE=1 一键禁用。
    """

    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.cache_dir = os.path.join(self.tmp, "cache")
        self.path = os.path.join(self.tmp, "m.xlsx")
        os.environ["DW_MAPPING_CACHE_DIR"] = self.cache_dir
        os.environ.pop("DW_NO_MAPPING_CACHE", None)
        _write_mapping_xlsx(self.path)

    def tearDown(self):
        os.environ.pop("DW_MAPPING_CACHE_DIR", None)
        os.environ.pop("DW_NO_MAPPING_CACHE", None)
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _cache_files(self):
        if not os.path.isdir(self.cache_dir):
            return []
        # ★ 2026-10-22：缓存格式由 pickle 改为 JSON（消除反序列化执行面），
        #   扩展名随之变化。
        return [f for f in os.listdir(self.cache_dir) if f.endswith(".json")]

    def test_second_call_hits_cache(self):
        s1 = _parse_xlsx_sheets(self.path)
        files = self._cache_files()
        self.assertEqual(len(files), 1)
        cache_file = os.path.join(self.cache_dir, files[0])
        cache_mtime = os.stat(cache_file).st_mtime_ns
        s2 = _parse_xlsx_sheets(self.path)
        # 第二次没有重写缓存文件（mtime 不变）⇒ 命中缓存而非重新解析
        self.assertEqual(os.stat(cache_file).st_mtime_ns, cache_mtime)
        self.assertEqual([x.tgt_table for x in s1], [x.tgt_table for x in s2])
        self.assertEqual(len(s1[0].mappings), len(s2[0].mappings))

    def test_modified_file_invalidates(self):
        s1 = _parse_xlsx_sheets(self.path)
        self.assertEqual(s1[0].tgt_table, "DWD_AST_TUNITSTOCK_PFD")
        time.sleep(0.01)  # 拉开 mtime，防文件系统时间戳粒度粗导致的假命中
        data = [
            ["目标表中文名称", "新目标表"],
            ["目标表英文名称", "DWD_NEW_TARGET_PFD"],
            _HEADER,
            ["C_DATE", "日期", "STRING", "1", "N", "1", "MAIN TABLE", "",
             "A", "ODS_O32_TUNITSTOCK_PFD", "单位库存", "L_DATE", "日期", ""],
        ]
        pd.DataFrame(data).to_excel(self.path, sheet_name="Sheet1",
                                    header=False, index=False)
        s2 = _parse_xlsx_sheets(self.path)
        self.assertEqual(s2[0].tgt_table, "DWD_NEW_TARGET_PFD")

    def test_disable_env_var(self):
        os.environ["DW_NO_MAPPING_CACHE"] = "1"
        _parse_xlsx_sheets(self.path)
        self.assertEqual(self._cache_files(), [])


class TestCalamineFastPath(unittest.TestCase):
    """★ 2026-10-18：python-calamine 快路径 —— 与 openpyxl 逐字段一致 + 环境开关。

    差异点收口在 norm_cell：数字 int 化、pandas 默认 NA 文本（如 'NULL'）转 NaN。
    真文件全量 A/B（21 个交付 Excel / 308 sheet）见 tools/.dx-tmp/_ab_calamine.py。
    """

    def setUp(self):
        if CalamineWorkbook is None:
            self.skipTest("python-calamine 未安装")
        self.tmp = tempfile.mkdtemp()
        self.path = os.path.join(self.tmp, "m.xlsx")
        _write_mapping_xlsx(self.path)
        os.environ["DW_NO_MAPPING_CACHE"] = "1"
        self.addCleanup(os.environ.pop, "DW_NO_CALAMINE", None)
        self.addCleanup(os.environ.pop, "DW_NO_MAPPING_CACHE", None)
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)

    def test_parity_with_openpyxl(self):
        os.environ.pop("DW_NO_CALAMINE", None)
        fast = _parse_xlsx_sheets(self.path)
        os.environ["DW_NO_CALAMINE"] = "1"
        slow = _parse_xlsx_sheets(self.path)
        self.assertEqual(fast, slow)

    def test_numeric_and_na_cells_normalized(self):
        path2 = os.path.join(self.tmp, "num.xlsx")
        _write_mapping_xlsx_numeric(path2)
        os.environ.pop("DW_NO_CALAMINE", None)
        fast = _parse_xlsx_sheets(path2)[0]
        os.environ["DW_NO_CALAMINE"] = "1"
        slow = _parse_xlsx_sheets(path2)[0]
        self.assertEqual(fast, slow)
        m1, m2 = fast.mappings
        self.assertEqual(m1.group_no, "1")       # 数字 1 → '1'（不是 '1.0'）
        self.assertEqual(m1.src_field_alias, "A.L_DATE")  # 映射规则空 → 别名.字段兜底
        self.assertEqual(m2.src_field_alias, "")  # 文本 'NULL' 视同空

    def test_disable_env_var_falls_back(self):
        os.environ["DW_NO_CALAMINE"] = "1"
        self.assertIsNone(calamine_read_workbook(self.path))

    def test_norm_cell_rules(self):
        self.assertEqual(norm_cell(1.0), 1)
        self.assertEqual(norm_cell(1.5), 1.5)
        self.assertEqual(norm_cell("abc"), "abc")
        self.assertTrue(pd.isna(norm_cell("NULL")))
        self.assertTrue(pd.isna(norm_cell("")))


if __name__ == "__main__":
    unittest.main()
