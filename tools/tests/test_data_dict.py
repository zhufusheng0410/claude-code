"""数据字典生成器单元测试"""

import os
import tempfile
import unittest

from tools.core.ir import TableMeta, FieldMeta, MappingSheet, MappingRule
from tools.generator.data_dict import (
    _bool_to_yn, extract_ods_dict, extract_layer_dict, generate_data_dict, write_combined_dict,
)


class TestBoolToYn(unittest.TestCase):
    def test_yes_values(self):
        for v in ("是", "Y", "y", "1", "是主键", "主键"):
            self.assertEqual(_bool_to_yn(v), "是", f"value={v!r}")

    def test_no_values(self):
        for v in ("否", "N", "n", "0", ""):
            self.assertEqual(_bool_to_yn(v), "否", f"value={v!r}")

    def test_yes_values_extended(self):
        """测试扩展的是值列表（包括 保留）"""
        for v in ("保留",):
            self.assertEqual(_bool_to_yn(v), "是", f"value={v!r}")


class TestExtractOdsDict(unittest.TestCase):
    def _table(self, **kw):
        defaults = dict(
            src_sys="O32", src_table="T", src_table_cn="表",
            ods_table="ODS_O32_T_PFD", load_strategy="FULL",
            is_reserved="是",
        )
        defaults.update(kw)
        return TableMeta(**defaults)

    def _field(self, **kw):
        defaults = dict(
            ordinal=1.0, src_name="C1", src_name_cn="字段1",
            src_type="VARCHAR2(20)", hive_type="STRING",
        )
        defaults.update(kw)
        return FieldMeta(**defaults)

    def test_extracts_rows(self):
        table = self._table()
        fields = [self._field(), self._field(ordinal=2.0, src_name="C2")]
        rows = extract_ods_dict([table], {"T": fields}, "O32")
        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[0]["系统"], "O32")
        self.assertEqual(rows[0]["层级"], "ODS")
        self.assertEqual(rows[0]["表英文名"], "ODS_O32_T_PFD")

    def test_skips_non_reserved_and_no_fields(self):
        table = self._table(is_reserved="否")
        rows = extract_ods_dict([table], {"T": [self._field()]}, "O32")
        self.assertEqual(rows, [])

    def test_is_ods_defaults_yes(self):
        table = self._table()
        fields = [self._field(is_ods="")]
        rows = extract_ods_dict([table], {"T": fields}, "O32")
        self.assertEqual(rows[0]["是否入ODS"], "是")

    def test_is_pk_bare_marker(self):
        table = self._table()
        fields = [self._field(is_pk="主键")]
        rows = extract_ods_dict([table], {"T": fields}, "O32")
        self.assertEqual(rows[0]["是否主键"], "是")


class TestExtractLayerDict(unittest.TestCase):
    def test_extracts_rows(self):
        mr = MappingRule(
            tgt_name="C1", tgt_name_cn="字段1", tgt_type="STRING",
            tgt_ordinal=1.0, is_pk="主键", group_no="1",
        )
        sheet = MappingSheet(
            tgt_table="DWDXDAY.DWD_AST_T_PFD", tgt_table_cn="表",
            load_type="FULL", mappings=[mr],
        )
        rows = extract_layer_dict([sheet], "DWD", "O32")
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["表英文名"], "DWD_AST_T_PFD")
        self.assertEqual(rows[0]["层级"], "DWD")
        self.assertEqual(rows[0]["是否主键"], "是")

    def test_dedups_tgt_name(self):
        mr1 = MappingRule(tgt_name="C1", tgt_name_cn="字段1")
        mr2 = MappingRule(tgt_name="C1", tgt_name_cn="字段1重复")
        sheet = MappingSheet(
            tgt_table="DWDXDAY.T", tgt_table_cn="表", mappings=[mr1, mr2],
        )
        rows = extract_layer_dict([sheet], "DWD", "O32")
        self.assertEqual(len(rows), 1)


class TestWriteCombinedDict(unittest.TestCase):
    def test_writes_excel(self):
        rows = [{
            "系统": "O32", "层级": "ODS", "表英文名": "ODS_O32_T_PFD",
            "表中文名": "表", "字段数": 1,
        }]
        with tempfile.TemporaryDirectory() as tmp:
            path = write_combined_dict({"ODS": rows}, tmp)
            self.assertTrue(path)
            self.assertTrue(os.path.exists(path))
            self.assertTrue(path.endswith("数据字典_汇总.xlsx"))

    def test_empty_returns_empty(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = write_combined_dict({"ODS": [], "DWD": [], "DWS": []}, tmp)
            self.assertEqual(path, "")


if __name__ == "__main__":
    unittest.main()
