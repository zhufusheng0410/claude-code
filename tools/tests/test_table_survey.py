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
COL_IS_RESERVED, COL_LOAD_STRATEGY = 10, 15


def _write(path, rows):
    df = pd.DataFrame(rows, columns=list(range(20)))
    df.to_excel(path, sheet_name="表级调研", header=False, index=False)


class TestParseTableSurvey(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.path = os.path.join(self.tmp, "t.xlsx")

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _row(self, **kw):
        r = [""] * 20
        r[COL_SRC_DB_TYPE] = "ORACLE"
        r[COL_SRC_SYS] = kw.get("sys", "O32")
        r[COL_SRC_TABLE] = kw.get("tbl", "T1")
        r[COL_SRC_TABLE_CN] = kw.get("cn", "表")
        r[COL_SRC_SCHEMA] = kw.get("schema", "FMP")
        r[COL_ODS_TABLE] = kw.get("ods", "")
        r[COL_IS_RESERVED] = kw.get("reserved", "是")
        r[COL_LOAD_STRATEGY] = kw.get("strategy", "FULL")
        return r

    def _parse(self, row):
        _write(self.path, [[""] * 20, [""] * 20, [""] * 20, row])
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


if __name__ == "__main__":
    unittest.main()
