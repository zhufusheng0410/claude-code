"""ODS 生成器单元测试（字段级 COMMENT 转义）"""

import unittest

from tools.core.ir import TableMeta, FieldMeta
from tools.generator.ods import generate_ods_ddl, generate_ods_etl


def _make_table(**kw):
    defaults = dict(
        src_sys="O32", src_table="TUNITSTOCK", src_table_cn="单位库存",
        ods_table="ODS_O32_TUNITSTOCK_PFD", load_strategy="FULL",
    )
    defaults.update(kw)
    return TableMeta(**defaults)


def _make_field(**kw):
    defaults = dict(
        ordinal=1.0, src_name="C_CUSTNO", src_name_cn="客户's 编号",
        src_type="VARCHAR2(20)", hive_type="STRING",
    )
    defaults.update(kw)
    return FieldMeta(**defaults)


class TestGenerateOdsDdl(unittest.TestCase):
    def test_field_comment_escaped(self):
        """ODS DDL 字段注释含单引号时应被转义。"""
        table = _make_table()
        fields = [_make_field()]
        sql = generate_ods_ddl(table, fields, "O32")
        self.assertIn("COMMENT '客户''s 编号'", sql)
        self.assertNotIn("COMMENT '客户's 编号'", sql)

    def test_empty_field_comment(self):
        """空字段注释不应产生未转义问题。"""
        table = _make_table()
        fields = [_make_field(src_name_cn="")]
        sql = generate_ods_ddl(table, fields, "O32")
        self.assertIn("COMMENT ''", sql)


class TestGenerateOdsEtl(unittest.TestCase):
    def test_tmp_field_comment_escaped(self):
        """ODS ETL 临时表字段注释含单引号时应被转义。"""
        table = _make_table()
        fields = [_make_field()]
        template = "${tmp_field_defs}"
        script = generate_ods_etl(table, fields, "O32", template)
        self.assertIn("COMMENT  '客户''s 编号'", script)
        self.assertNotIn("COMMENT  '客户's 编号'", script)


if __name__ == "__main__":
    unittest.main()
