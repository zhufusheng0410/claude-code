"""表级调研解析单元测试：#3 命名列索引、保留过滤、自动表名生成、系统过滤。"""

import os
import shutil
import tempfile
import unittest

import pandas as pd

from tools.parser.table_survey import parse_table_survey

# 调研文档列索引（与 table_survey.COL_* 对应），header=None 读取，数据行从 index 3 起
COL_SRC_DB_TYPE, COL_SRC_SYS, COL_SRC_TABLE = 0, 2, 4
COL_SRC_TABLE_CN, COL_SRC_SCHEMA, COL_ODS_TABLE = 5, 6, 7
COL_TABLE_ROWS = 9
COL_IS_RESERVED, COL_LOAD_STRATEGY = 10, 15
COL_OWNER = 22


def _write(path, rows):
    ncol = max(23, max((len(r) for r in rows), default=0))
    df = pd.DataFrame(rows, columns=list(range(ncol)))
    df.to_excel(path, sheet_name="表级调研", header=False, index=False)


class TestParseTableSurvey(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.path = os.path.join(self.tmp, "t.xlsx")

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _row(self, **kw):
        r = [""] * 23
        r[COL_SRC_DB_TYPE] = "ORACLE"
        r[COL_SRC_SYS] = kw.get("sys", "O32")
        r[COL_SRC_TABLE] = kw.get("tbl", "T1")
        r[COL_SRC_TABLE_CN] = kw.get("cn", "表")
        r[COL_SRC_SCHEMA] = kw.get("schema", "FMP")
        r[COL_ODS_TABLE] = kw.get("ods", "")
        r[COL_IS_RESERVED] = kw.get("reserved", "是")
        r[COL_LOAD_STRATEGY] = kw.get("strategy", "FULL")
        r[COL_OWNER] = kw.get("owner", "")
        return r

    def _parse(self, row):
        _write(self.path, [[""] * 23, [""] * 23, [""] * 23, row])
        return parse_table_survey(self.path, "O32")

    def test_basic_full_auto_table_name(self):
        ts = self._parse(self._row())
        self.assertEqual(len(ts), 1)
        self.assertEqual(ts[0].src_table, "T1")
        self.assertEqual(ts[0].load_strategy, "FULL")
        # 空 ODS 表名时按 FULL 自动生成 _PFD 后缀
        self.assertEqual(ts[0].ods_table, "ODS_O32_T1_PFD")

    def test_incr_strategy(self):
        ts = self._parse(self._row(strategy="增量", ods="ODS_O32_T1_PTD"))
        self.assertEqual(ts[0].load_strategy, "INCR")

    def test_auto_gen_incr_suffix(self):
        ts = self._parse(self._row(strategy="增量"))
        self.assertTrue(ts[0].ods_table.endswith("_PTD"))

    def test_not_reserved_flag_parsed(self):
        # parse_table_survey 解析全部表；保留过滤在下游 iter_ods_tables 做
        ts = self._parse(self._row(reserved="否"))
        self.assertEqual(len(ts), 1)
        self.assertEqual(ts[0].is_reserved, "否")

    def test_sys_filter_excludes_other_system(self):
        ts = self._parse(self._row(sys="HSFA"))
        self.assertEqual(len(ts), 0)

    # ---- ★ 2026-10-08 规则变更：调研人 → 源物理表名；ods_table 一律按规则命名 ----

    def test_owner_overrides_physical_source_table(self):
        """调研人非空 ⇒ src_table_phys 取调研人；ods_table 仍用 col4 ⇒ DWD 血缘不破。"""
        ts = self._parse(self._row(tbl="TUNITSTOCK", owner="THISUNITSTOCK"))
        self.assertEqual(ts[0].src_table, "TUNITSTOCK")            # 字段 join key 不变
        self.assertEqual(ts[0].src_table_phys, "THISUNITSTOCK")     # 取数源表跟着改
        self.assertEqual(ts[0].ods_table, "ODS_O32_TUNITSTOCK_PFD") # ★ 依然用 col4

    def test_owner_empty_falls_back_to_col4(self):
        """调研人为空 ⇒ src_table_phys == src_table。"""
        ts = self._parse(self._row(tbl="TASSET", owner=""))
        self.assertEqual(ts[0].src_table_phys, "TASSET")
        self.assertEqual(ts[0].ods_table, "ODS_O32_TASSET_PFD")

    def test_ods_table_base_ignores_col7_but_keeps_suffix(self):
        """★ 基名不取 col7；但 col7 的 _PFD/_PTD 后缀优先保留（O32 策略/后缀冲突场景）。"""
        ts = self._parse(self._row(tbl="T1", ods="ODS_O32_WRONG_BASE_PFD", strategy="增量"))
        # 基名按 col4 ⇒ T1；后缀沿用 col7 的 PFD（而非按「增量」推成 PTD）
        self.assertEqual(ts[0].ods_table, "ODS_O32_T1_PFD")

    def test_ods_table_suffix_from_strategy_when_col7_bare(self):
        """col7 只有裸名（无后缀，如 OA/OFFW）⇒ 后缀按策略推。"""
        ts = self._parse(self._row(tbl="T1", ods="ODS_O32_T1", strategy="增量"))
        self.assertEqual(ts[0].ods_table, "ODS_O32_T1_PTD")
        ts2 = self._parse(self._row(tbl="T1", ods="ODS_O32_T1", strategy="全量"))
        self.assertEqual(ts2[0].ods_table, "ODS_O32_T1_PFD")

    def test_owner_conflict_falls_back_with_warning(self):
        """调研人撞上另一条保留表的原名 ⇒ 回退不改造（避免 ODS 表名撞车）。"""
        rows = [[""] * 23, [""] * 23, [""] * 23]
        rows.append(self._row(tbl="TCJHB", owner="T_H_CJHB", strategy="增量"))
        rows.append(self._row(tbl="T_H_CJHB", owner="", reserved="是", strategy="增量"))
        _write(self.path, rows)
        ts = parse_table_survey(self.path, "O32")
        by = {t.src_table: t for t in ts}
        # 撞名方回退：TCJHB 仍从 TCJHB 取数
        self.assertEqual(by["TCJHB"].src_table_phys, "TCJHB")
        # 两条各自成表，名字不撞
        self.assertEqual(len({t.ods_table for t in ts}), 2)


class TestTableSurveyCalamineParity(TestParseTableSurvey):
    """★ 2026-10-18：calamine 快路径与 openpyxl 回退逐字段一致（含继承用例重跑）。"""

    def setUp(self):
        from tools.utils.excel_reader import CalamineWorkbook
        if CalamineWorkbook is None:
            self.skipTest("python-calamine 未安装")
        super().setUp()
        os.environ.pop("DW_NO_CALAMINE", None)
        self.addCleanup(os.environ.pop, "DW_NO_CALAMINE", None)

    def test_parity_numeric_and_na(self):
        row = self._row(tbl="T1", owner="NULL")   # 文本 'NULL' 应视同空 → 回落 col4
        row[COL_TABLE_ROWS] = 12345               # 数字单元格
        _write(self.path, [[""] * 23, [""] * 23, [""] * 23, row])
        fast = parse_table_survey(self.path, "O32")
        os.environ["DW_NO_CALAMINE"] = "1"
        slow = parse_table_survey(self.path, "O32")
        self.assertEqual(repr(fast), repr(slow))
        # 列内混有空值 → 两引擎都经 float64 上浮，safe_str 得 '12345.0'（生产既有口径）
        self.assertEqual(fast[0].table_rows, "12345.0")
        self.assertEqual(fast[0].src_table_phys, "T1")


if __name__ == "__main__":
    unittest.main()
