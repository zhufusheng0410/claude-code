"""表工具函数单元测试（含 N2 大小写一致性修复的回归覆盖）"""

import unittest

from tools.core.ir import TableMeta, FieldMeta
from tools.utils.table_utils import (
    extract_physical_name,
    is_table_reserved,
    filter_ods_fields,
    find_fields_by_table,
    iter_ods_tables,
    filter_valid_ods_tables,
)


class TestExtractPhysicalName(unittest.TestCase):
    def test_with_schema(self):
        self.assertEqual(extract_physical_name("ODS_XDAY_O32.T1"), "T1")

    def test_no_schema(self):
        self.assertEqual(extract_physical_name("T1"), "T1")


class TestIsTableReserved(unittest.TestCase):
    def test_reserved_values(self):
        for v in ("是", "保留", "Y", "y"):
            self.assertTrue(is_table_reserved(TableMeta(is_reserved=v)))

    def test_not_reserved(self):
        self.assertFalse(is_table_reserved(TableMeta(is_reserved="否")))
        self.assertFalse(is_table_reserved(TableMeta()))


class TestFilterOdsFields(unittest.TestCase):
    def test_excludes_no(self):
        fs = [FieldMeta(src_name="A", is_ods="是"), FieldMeta(src_name="B", is_ods="否")]
        res = filter_ods_fields(fs)
        self.assertEqual([f.src_name for f in res], ["A"])

    def test_empty_omitted(self):
        fs = [FieldMeta(src_name="A", is_ods="")]
        # 未填写视为保留
        self.assertEqual([f.src_name for f in filter_ods_fields(fs)], ["A"])


class TestFindFieldsByTable(unittest.TestCase):
    def test_case_insensitive(self):
        # find_fields_by_table 检查 exact / upper / lower，不覆盖 Title 大小写
        d = {"tunitstock": [FieldMeta(src_name="A")]}
        self.assertEqual(len(find_fields_by_table("TUNITSTOCK", d)), 1)
        self.assertEqual(len(find_fields_by_table("Tunitstock", d)), 1)
        self.assertEqual(len(find_fields_by_table("tunitstock", d)), 1)


class TestIterOdsTables(unittest.TestCase):
    def test_skips_unreserved_and_missing_fields(self):
        t1 = TableMeta(src_table="T1", is_reserved="是")
        t2 = TableMeta(src_table="T2", is_reserved="否")  # 不保留
        f = [FieldMeta(src_name="A")]
        res = list(iter_ods_tables([t1, t2], {"T1": f}))
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0][0].src_table, "T1")


class TestFilterValidOdsTables(unittest.TestCase):
    def test_case_insensitive_match(self):
        # N2 回归：表级 src_table 大写、字段级 key 小写时仍应匹配
        t = TableMeta(src_table="TUNITSTOCK", is_reserved="是")
        fields = {"tunitstock": [FieldMeta(src_name="A")]}
        self.assertEqual(len(filter_valid_ods_tables([t], fields)), 1)

    def test_unreserved_excluded(self):
        t = TableMeta(src_table="T1", is_reserved="否")
        self.assertEqual(filter_valid_ods_tables([t], {"T1": [FieldMeta()]}), [])

    def test_missing_fields_excluded(self):
        t = TableMeta(src_table="T1", is_reserved="是")
        self.assertEqual(filter_valid_ods_tables([t], {}), [])


if __name__ == "__main__":
    unittest.main()
