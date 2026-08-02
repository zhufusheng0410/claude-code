"""DDL 共用逻辑单元测试（含 #4 escape_sql_comment helper）"""

import unittest

from tools.generator.ddl_common import escape_sql_comment, generate_ddl_body


class TestEscapeSqlComment(unittest.TestCase):
    def test_escapes_single_quote(self):
        self.assertEqual(escape_sql_comment("O'Hara"), "O''Hara")

    def test_multiple_quotes(self):
        self.assertEqual(escape_sql_comment("a'b'c"), "a''b''c")

    def test_empty(self):
        self.assertEqual(escape_sql_comment(""), "")

    def test_plain(self):
        self.assertEqual(escape_sql_comment("客户类型"), "客户类型")


class TestGenerateDdlBody(unittest.TestCase):
    def test_basic_structure(self):
        sql = generate_ddl_body("DWDXDAY", "T1", ["C1  STRING", "C2  STRING"], "表注释")
        self.assertIn("CREATE TABLE DWDXDAY.T1", sql)
        self.assertIn("C1  STRING", sql)
        self.assertIn("PARTITIONED BY", sql)
        self.assertIn("COMMENT '表注释'", sql)

    def test_comment_escaped(self):
        sql = generate_ddl_body("ODS_XDAY_O32", "T1", ["C1  STRING"], "O'Hara")
        self.assertIn("COMMENT 'O''Hara'", sql)

    def test_field_comment_escaped(self):
        """字段级 COMMENT 含单引号时应被转义，防止 SQL 语法错误/注入。"""
        field = "C1  STRING DEFAULT NULL COMMENT 'O''Hara'"
        sql = generate_ddl_body("DWDXDAY", "T1", [field], "表注释")
        self.assertIn("COMMENT 'O''Hara'", sql)
        # 不应出现未转义的单引号破坏 COMMENT 结构
        self.assertNotIn("COMMENT 'O'Hara'", sql)


if __name__ == "__main__":
    unittest.main()
