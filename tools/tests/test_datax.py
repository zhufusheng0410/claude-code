"""DataX 生成器单元测试（覆盖 #10 标注为备用的未调用模块）"""

import unittest

from tools.core.ir import TableMeta, FieldMeta
from tools.generator.datax import generate_datax


class TestGenerateDatax(unittest.TestCase):
    def test_full_table(self):
        t = TableMeta(
            src_schema="FMP", src_table="T1",
            ods_table="ODS_O32_T1_PFD", load_strategy="FULL",
        )
        fields = [
            FieldMeta(src_name="A", src_type="NUMBER(10,2)"),
            FieldMeta(src_name="B", src_type="VARCHAR2(20)"),
        ]
        job = generate_datax(t, fields, "O32")
        self.assertIn('"oraclereader"', job)
        self.assertIn('"hdfswriter"', job)
        self.assertIn("ODS_O32_T1_PFD", job)
        self.assertIn('"writeMode": "truncate"', job)

    def test_incr_write_mode(self):
        t = TableMeta(
            src_schema="FMP", src_table="T1",
            ods_table="ODS_O32_T1_PTD", load_strategy="INCR",
            incr_cond="L_DATE >= 'x'",
        )
        fields = [FieldMeta(src_name="A", src_type="DATE")]
        job = generate_datax(t, fields, "O32")
        self.assertIn('"writeMode": "append"', job)
        self.assertIn("L_DATE >= 'x'", job)


if __name__ == "__main__":
    unittest.main()
