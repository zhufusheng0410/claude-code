"""Oracle→Hive 类型映射单元测试（纯逻辑，无 IO）"""

import unittest

from tools.core.type_mapper import oracle_to_hive, _is_code_field


class TestOracleToHive(unittest.TestCase):
    def test_varchar_family_to_string(self):
        for t in ("VARCHAR2(20)", "VARCHAR(20)", "CHAR(10)", "NVARCHAR2(10)", "NCHAR(10)"):
            self.assertEqual(oracle_to_hive(t), "STRING")

    def test_clob_long_to_string(self):
        self.assertEqual(oracle_to_hive("CLOB"), "STRING")
        self.assertEqual(oracle_to_hive("LONG"), "STRING")

    def test_number_with_scale(self):
        # s>0：保留原始精度
        self.assertEqual(oracle_to_hive("NUMBER(10,2)"), "DECIMAL(10,2)")

    def test_number_integer_meaning(self):
        # s=0 整数含义：保留原始精度（非代码字段）
        self.assertEqual(oracle_to_hive("NUMBER(10,0)"), "DECIMAL(10,0)")

    def test_number_code_field_becomes_string(self):
        # s=0 代码含义：映射为 STRING
        self.assertEqual(oracle_to_hive("NUMBER(10,0)", "客户类型代码"), "STRING")

    def test_number_no_precision_default(self):
        self.assertEqual(oracle_to_hive("NUMBER"), "DECIMAL(18,2)")

    def test_float_family(self):
        # P0 回归：FLOAT/BINARY_FLOAT/BINARY_DOUBLE → DECIMAL(30,8)（与规范文档 8.1 一致）
        for t in ("FLOAT", "BINARY_FLOAT", "BINARY_DOUBLE"):
            self.assertEqual(oracle_to_hive(t), "DECIMAL(30,8)")

    def test_date_timestamp(self):
        for t in ("DATE", "TIMESTAMP", "DATETIME"):
            self.assertEqual(oracle_to_hive(t), "STRING")

    def test_integer(self):
        self.assertEqual(oracle_to_hive("INTEGER"), "DECIMAL(8,0)")
        self.assertEqual(oracle_to_hive("INT"), "DECIMAL(8,0)")

    def test_raw_blob(self):
        for t in ("RAW", "BLOB"):
            self.assertEqual(oracle_to_hive(t), "STRING")

    def test_empty_and_none(self):
        self.assertEqual(oracle_to_hive(""), "STRING")
        self.assertEqual(oracle_to_hive(None), "STRING")


class TestIsCodeField(unittest.TestCase):
    def test_code_keywords(self):
        for kw in ("代码", "编码", "编号", "标志", "标识", "类型", "分类", "方向"):
            self.assertTrue(_is_code_field(f"客户{kw}"))

    def test_non_code(self):
        self.assertFalse(_is_code_field("日期"))
        self.assertFalse(_is_code_field("金额"))
        self.assertFalse(_is_code_field(""))


if __name__ == "__main__":
    unittest.main()
