"""输入验证单元测试：数据库标识符 + 输出路径遍历防护"""

import os
import tempfile
import unittest

from tools.utils.validation import validate_db_identifier, validate_output_path


class TestValidateDbIdentifier(unittest.TestCase):
    def test_valid_identifiers(self):
        for name in ("ODS_O32_T1", "T1", "a1_b2", "X"):
            validate_db_identifier(name, "table")  # 不应抛异常

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
