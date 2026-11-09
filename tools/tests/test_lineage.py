# -*- coding: utf-8 -*-
"""`tools/generator/lineage.py` 的回归测试（评审 C6）。

★ 背景：`_resolve_upstream_tables` 原来在每个子查询字段上重建整张
  `sheet.mappings` 的中文名索引；一张表几百个字段就是几百次全表扫描。
  现在由 `extract_lineage` 按表构建一次并传入，本测试锁住「传了就不再重建」。
  另：函数尾部原有一段与开头完全相同的「别名/真实表名反向」交换，
  因开头已交换过 ⇒ 条件恒为 False，属死代码，已删除（行为不变）。
"""
import types
import unittest

from tools.generator import lineage as L


def _mr(src_table, src_cn=""):
    return types.SimpleNamespace(src_table_name=src_table, src_table_cn=src_cn)


class TestResolveUpstream(unittest.TestCase):
    MAPPINGS = [
        _mr("DWD_X_PFD", "X表"),
        _mr("A1", "DWD_Y_PFD"),                       # 别名/真实表名写反
        _mr("SELECT * FROM DWD_Y_PFD A1", ""),        # 子查询
    ]

    def test_prebuilt_lookup_is_reused(self):
        lookup = L._build_table_cn_lookup(self.MAPPINGS)
        saved = L._build_table_cn_lookup
        self.addCleanup(setattr, L, "_build_table_cn_lookup", saved)

        def _boom(_mappings):
            raise AssertionError("传入 table_cn_lookup 后不应重建索引")

        L._build_table_cn_lookup = _boom
        out = L._resolve_upstream_tables(self.MAPPINGS[2], self.MAPPINGS,
                                         "", lookup)
        self.assertEqual(out, [("DWD_Y_PFD", "DWD_Y_PFD")])

    def test_without_lookup_still_builds(self):
        """不传 lookup 时保持旧行为（兼容既有直接调用方）。"""
        out = L._resolve_upstream_tables(self.MAPPINGS[2], self.MAPPINGS)
        self.assertEqual([t for t, _ in out], ["DWD_Y_PFD"])

    def test_alias_swap_still_works(self):
        """删掉尾部死代码后，开头的别名交换仍然生效。"""
        out = L._resolve_upstream_tables(self.MAPPINGS[1], self.MAPPINGS)
        self.assertEqual(out[0][0], "DWD_Y_PFD")


if __name__ == "__main__":
    unittest.main()
