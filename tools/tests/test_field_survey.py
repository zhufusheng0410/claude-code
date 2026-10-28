"""字段级调研解析单元测试：列名解析 + #8 缺列抛异常（fail-fast）。"""

import os
import shutil
import tempfile
import unittest

import pandas as pd

from tools.parser.field_survey import parse_field_survey


def _write(path, columns, rows):
    pd.DataFrame(rows, columns=columns).to_excel(path, index=False)


class TestParseFieldSurvey(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.path = os.path.join(self.tmp, "f.xlsx")

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_basic(self):
        cols = ["源系统英文名", "表英文名", "表中文名", "字段英文名",
                "字段中文名", "字段类型", "是否入ODS", "是否保留建模"]
        rows = [
            ["O32", "T1", "表1", "C1", "日期", "DATE", "是", "是"],
            ["O32", "T1", "表1", "C2", "金额", "NUMBER(10,2)", "是", "是"],
        ]
        _write(self.path, cols, rows)
        res = parse_field_survey(self.path)
        self.assertIn("T1", res)
        self.assertEqual(len(res["T1"]), 2)
        self.assertEqual(res["T1"][0].src_name, "C1")
        # 无转换后字段类型时回退到 oracle_to_hive
        self.assertEqual(res["T1"][0].hive_type, "STRING")
        self.assertEqual(res["T1"][1].hive_type, "DECIMAL(10,2)")

    def test_missing_required_column_raises(self):
        # #8 回归：列名缺失（如缺"字段类型"）应尽早抛明确异常，而非静默空结果
        cols = ["表英文名", "字段英文名"]
        rows = [["T1", "C1"]]
        _write(self.path, cols, rows)
        with self.assertRaises(ValueError):
            parse_field_survey(self.path)


class TestFieldSurveyCalamineParity(TestParseFieldSurvey):
    """★ 2026-10-18：calamine 快路径与 openpyxl 回退逐字段一致（含继承用例重跑）。"""

    def setUp(self):
        from tools.utils.excel_reader import CalamineWorkbook
        if CalamineWorkbook is None:
            self.skipTest("python-calamine 未安装")
        super().setUp()
        os.environ.pop("DW_NO_CALAMINE", None)
        self.addCleanup(os.environ.pop, "DW_NO_CALAMINE", None)

    def test_parity_numeric_and_na(self):
        cols = ["源系统英文名", "表英文名", "字段英文名", "字段序号",
                "字段类型", "默认值", "是否入ODS"]
        rows = [
            ["O32", "T1", "C1", 1, "DATE", "NULL", "是"],
            ["O32", "T1", "C2", None, "NUMBER(10,2)", None, "是"],
        ]
        _write(self.path, cols, rows)
        fast = parse_field_survey(self.path)
        os.environ["DW_NO_CALAMINE"] = "1"
        slow = parse_field_survey(self.path)
        # repr 仲裁：空单元格 ordinal=nan，nan != nan 会让 == 产生假 DIFF
        self.assertEqual(repr(fast), repr(slow))
        f1, f2 = fast["T1"]
        self.assertEqual(f1.ordinal, 1.0)
        self.assertEqual(f1.default_val, "")   # 文本 'NULL' 视同空（pandas NA 语义）
        self.assertTrue(pd.isna(f2.ordinal))


if __name__ == "__main__":
    unittest.main()
