"""excel_reader 纯函数单测：header=0/dtype=str 模拟 + norm_cell。★ 2026-10-18"""

import unittest

import pandas as pd

from tools.utils.excel_reader import apply_header_row0, frame_to_str, norm_cell


class TestApplyHeaderRow0(unittest.TestCase):
    def test_basic(self):
        df = pd.DataFrame([["a", "b"], [1, None], [None, "x"]])
        out = apply_header_row0(df)
        self.assertEqual(list(out.columns), ["a", "b"])
        self.assertEqual(len(out), 2)
        self.assertEqual(list(out.index), [0, 1])
        self.assertEqual(out.iloc[0, 0], 1)
        self.assertTrue(pd.isna(out.iloc[0, 1]))
        self.assertEqual(out.iloc[1, 1], "x")

    def test_unnamed_and_duplicate_columns(self):
        df = pd.DataFrame([["A", None, "A"], ["x", "y", "z"]])
        out = apply_header_row0(df)
        self.assertEqual(list(out.columns), ["A", "Unnamed: 1", "A.1"])

    def test_empty(self):
        self.assertTrue(apply_header_row0(pd.DataFrame()).empty)


class TestFrameToStr(unittest.TestCase):
    def test_object_col_numbers_and_nan(self):
        # norm_cell 已在读盘时把 calamine 数字归一（int 1 → '1'），本函数只做 str()
        df = pd.DataFrame({"a": pd.Series([1, 2.5, None], dtype=object),
                           "b": ["x", None, "y"]})
        out = frame_to_str(df)
        self.assertEqual(out.iloc[0, 0], "1")
        self.assertEqual(out.iloc[1, 0], "2.5")
        self.assertTrue(pd.isna(out.iloc[2, 0]))
        self.assertEqual(out.iloc[0, 1], "x")
        self.assertTrue(pd.isna(out.iloc[1, 1]))


class TestNormCell(unittest.TestCase):
    def test_number_normalization(self):
        self.assertEqual(norm_cell(1.0), 1)
        self.assertEqual(norm_cell(1.5), 1.5)
        self.assertEqual(norm_cell(2.0**53), 2.0**53)  # 超精度边界的整数保持 float
        self.assertIs(norm_cell(True), True)           # bool 不是 float，原样

    def test_na_strings(self):
        self.assertTrue(pd.isna(norm_cell("NULL")))
        self.assertTrue(pd.isna(norm_cell("")))
        self.assertEqual(norm_cell("1"), "1")          # 文本 '1' 不转数字
        self.assertEqual(norm_cell("正常"), "正常")


if __name__ == "__main__":
    unittest.main()
