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


if __name__ == "__main__":
    unittest.main()
