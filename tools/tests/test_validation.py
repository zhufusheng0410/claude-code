"""输入验证单元测试：数据库标识符 + 输出路径遍历防护"""

import os
import tempfile
import unittest

from tools.utils.validation import validate_db_identifier, validate_output_path


class TestValidateDbIdentifier(unittest.TestCase):
    def test_valid_identifiers(self):
        for name in ("ODS_O32_T1", "T1", "a1_b2", "X"):
            validate_db_identifier(name, "table")  # 不应抛异常

    def test_digit_leading_identifiers_allowed(self):
        """★ 2026-10-26 回归：甲方 MAPPING 存在数字开头的目标字段名。

        实测 `7D_AROR` / `1V1_INIT_CNOR` / `1VN_INIT_CNOR_QTY`
        （scripts/O32/dwd/02_etl/DWD_AST_FUND_AST_PFD.sh）。
        若把正则收紧成「必须字母/下划线开头」，这些表会在 build_field_defs
        处抛 ValueError、整表被跳过 ⇒ 静默缺表。
        """
        for name in ("7D_AROR", "1V1_INIT_CNOR", "1VN_INIT_CNOR_QTY", "123"):
            validate_db_identifier(name, "field")  # 不应抛异常

    def test_empty_raises(self):
        with self.assertRaises(ValueError):
            validate_db_identifier("", "table")

    def test_invalid_chars_raise(self):
        for bad in ("t;drop", "t'x", "t x", "t-x", "t.x"):
            with self.assertRaises(ValueError):
                validate_db_identifier(bad, "table")


class TestValidateOutputPath(unittest.TestCase):
    def test_inside_base(self):
        base = tempfile.mkdtemp()
        out = os.path.join(base, "sub", "dir")
        resolved = validate_output_path(out, base)
        self.assertTrue(resolved.startswith(os.path.realpath(base)))

    def test_dotdot_raises(self):
        base = tempfile.mkdtemp()
        with self.assertRaises(ValueError):
            validate_output_path(os.path.join(base, "..", "evil"), base)

    def test_unrelated_path_raises(self):
        base = tempfile.mkdtemp()
        with self.assertRaises(ValueError):
            validate_output_path("/tmp/somewhere-else", base)

    def test_base_itself_allowed(self):
        base = tempfile.mkdtemp()
        resolved = validate_output_path(base, base)
        self.assertEqual(resolved, os.path.realpath(base))


if __name__ == "__main__":
    unittest.main()
