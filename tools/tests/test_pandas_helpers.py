# -*- coding: utf-8 -*-
"""tools.utils.pandas_helpers 的单元测试。"""
import unittest
import pandas as pd

from tools.utils.pandas_helpers import safe_float, safe_float_str, safe_str


class TestPandasHelpers(unittest.TestCase):
    def setUp(self):
        self.series = pd.Series({
            "str_col": "  hello world  ",
            "empty_str": "   ",
            "nan_col": float("nan"),
            "int_col": 123,
            "float_col": 45.67,
            "bad_num": "not_a_number",
        })

    def test_safe_str(self):
        self.assertEqual(safe_str(self.series, "str_col"), "hello world")
        self.assertEqual(safe_str(self.series, "empty_str"), "")
        self.assertEqual(safe_str(self.series, "nan_col"), "")
        self.assertEqual(safe_str(self.series, "non_existent"), "")
        self.assertEqual(safe_str(self.series, "int_col"), "123")

    def test_safe_float(self):
        self.assertEqual(safe_float(self.series, "float_col"), 45.67)
        self.assertEqual(safe_float(self.series, "int_col"), 123.0)
        # 既有契约：浮点 NaN 原样保留（供 field_survey 区分空序号与 0）
        self.assertTrue(pd.isna(safe_float(self.series, "nan_col", default=9.9)))
        self.assertEqual(safe_float(self.series, "bad_num", default=-1.0), -1.0)
        self.assertEqual(safe_float(self.series, "non_existent", default=0.0), 0.0)

    def test_safe_float_str(self):
        self.assertEqual(safe_float_str("12.34"), 12.34)
        self.assertEqual(safe_float_str("  99  "), 99.0)
        self.assertEqual(safe_float_str(42), 42.0)
        self.assertEqual(safe_float_str(3.1415), 3.1415)
        self.assertEqual(safe_float_str(None, default=5.0), 5.0)
        self.assertEqual(safe_float_str("", default=5.0), 5.0)
        self.assertEqual(safe_float_str("   ", default=5.0), 5.0)
        self.assertEqual(safe_float_str("abc", default=-1.0), -1.0)


if __name__ == "__main__":
    unittest.main()
