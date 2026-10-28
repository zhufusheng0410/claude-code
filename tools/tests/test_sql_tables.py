# -*- coding: utf-8 -*-
"""2026-10-12 修复的回归测试：MAPPING「源表英文名」列贴整段子查询。

背景（真实事故，13 张 DWD_EVT_* 表）：
  甲方在 MAPPING 的「源表英文名」单元格里直接贴了整段子查询：
      SELECT T1.L_ZQNM AS L_ZQNM--证券内码
      ...
      FROM ODS_HSFA_TZQXX_PFD T1
      LEFT JOIN DWD_CMM_STD_DICT_CDVAL_MAP T2 ON ...
      WHERE T1.P_DT = '${p_end_dt}'
  旧生成器把整段文本当**表名**：
    ① SQL：`LEFT JOIN SELECT ... FROM ... WHERE ... A12` 无括号 ⇒ ParseException
    ② 依赖声明块 / source_tables：整段 SELECT 当一个"表名"，真实上游表丢失
  修法：core.sql_tables 提供 is_subquery/extract/wrap/qualify，
       base.py 的 FROM/JOIN 渲染与依赖块、parser 的 source_tables 共用。
"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from tools.core.sql_tables import (  # noqa
    is_subquery, extract_tables_from_subquery,
    wrap_subquery, qualify_table, qualify_subquery_tables,
    validate_table_ref,
)
from tools.core.ir import MappingRule  # noqa
from tools.generator.base import BaseGenerator, _render_src_ref, _resolve_group_src_tab  # noqa
from tools.config import DWD_SCHEMA, SYS_FIELDS_DWD  # noqa

# 甲方 MAPPING 里贴的真实子查询（DWD_EVT_* 系列，别名 A12）
REAL_SUBQUERY = """SELECT
 T1.L_ZQNM AS L_ZQNM--证券内码
 ,T1.VC_ZQDM AS VC_ZQDM--证券代码
 ,T2.STD_DICT_CLS_CD_VAL AS L_ZQLB --证券类别
 ,T3.STD_DICT_CLS_CD_VAL AS L_ZQLBMX --证券明细类别1
FROM ODS_HSFA_TZQXX_PFD T1
LEFT JOIN DWD_CMM_STD_DICT_CDVAL_MAP T2
ON T2.SSYS= 'HSFTA' AND T2.SRC_DICT_CLS_CD= 'L_ZQLB' AND T1.L_ZQLB = T2.SRC_DICT_CLS_CDVAL AND T2.VALID_FLAG='1'
LEFT JOIN DWD_CMM_STD_DICT_CDVAL_MAP T3
ON T3.SSYS= 'HSFTA' AND T3.SRC_DICT_CLS_CD= 'L_ZQLBMX1' AND T1.L_ZQLBMX1 = T3.SRC_DICT_CLS_CDVAL AND T3.VALID_FLAG='1'
WHERE T1.P_DT = '${p_end_dt}'"""


class TestIsSubquery(unittest.TestCase):
    def test_select_prefix(self):
        self.assertTrue(is_subquery("SELECT 1 FROM A"))

    def test_parenthesized_select(self):
        self.assertTrue(is_subquery("(SELECT 1 FROM A)"))

    def test_comment_prefixed_select(self):
        self.assertTrue(is_subquery("-- note\nSELECT 1 FROM A"))

    def test_plain_table_name(self):
        self.assertFalse(is_subquery("ODS_O32_TUNITSTOCK_PFD"))
        self.assertFalse(is_subquery("DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP"))
        self.assertFalse(is_subquery("A1"))

    def test_empty(self):
        self.assertFalse(is_subquery(""))


class TestExtractTables(unittest.TestCase):
    def test_real_subquery(self):
        tables = [t for t, _cn in extract_tables_from_subquery(REAL_SUBQUERY)]
        self.assertEqual(tables,
                         ["ODS_HSFA_TZQXX_PFD", "DWD_CMM_STD_DICT_CDVAL_MAP"])

    def test_dedup_and_order(self):
        tables = [t for t, _cn in extract_tables_from_subquery(
            "SELECT * FROM A X JOIN B Y ON 1=1 JOIN A Z ON 1=1")]
        self.assertEqual(tables, ["A", "B"])

    def test_non_subquery_returns_empty(self):
        self.assertEqual(extract_tables_from_subquery("ODS_O32_T_PFD"), [])

    # ★ 2026-10-22（评审 HIGH-1）回归：无别名子查询曾丢表。
    #   原正则的「可选别名」段会把 FROM 后紧跟的下一个标识词吞掉——
    #   `FROM A JOIN B` 里 'JOIN' 被当成 B 的别名吞了，于是 B 永远匹配不到。
    #   后果是 MAPPING 的 source_tables 不全 ⇒ SRC_TAB/依赖声明块漏上游表
    #   ⇒ 血缘与调度依赖缺边 ⇒ **静默产出错数据**（不报错、不告警）。
    #   旧测试夹具全带别名（T1/T2/T3），恰好绕开了这条路径，故未暴露。
    def test_join_without_alias_keeps_both_tables(self):
        tables = [t for t, _cn in extract_tables_from_subquery(
            "SELECT * FROM A JOIN B ON A.id = B.id")]
        self.assertEqual(tables, ["A", "B"])

    def test_three_joins_without_alias_keeps_all(self):
        tables = [t for t, _cn in extract_tables_from_subquery(
            "SELECT * FROM A JOIN B ON 1=1 JOIN C ON 2=2")]
        self.assertEqual(tables, ["A", "B", "C"])

    def test_mixed_alias_and_no_alias(self):
        tables = [t for t, _cn in extract_tables_from_subquery(
            "SELECT * FROM S.T1 A JOIN S.T2 ON 1=1 JOIN S.T3 C ON 2=2")]
        self.assertEqual(tables, ["S.T1", "S.T2", "S.T3"])

    def test_left_join_without_alias(self):
        tables = [t for t, _cn in extract_tables_from_subquery(
            "SELECT * FROM ODS_X LEFT JOIN ODS_Y ON ODS_X.k = ODS_Y.k")]
        self.assertEqual(tables, ["ODS_X", "ODS_Y"])


class TestValidateTableRef(unittest.TestCase):
    """★ 2026-10-22（评审 HIGH-8）源表名标识符校验。

    源表名来自甲方 MAPPING Excel（外部输入），此前经 qualify_table 后
    **原样**拼进 FROM/JOIN —— 一个带引号/分号的表名即可污染生成的 ETL 脚本。
    目标表名有 validate_db_identifier 兜底，源表名此前是缺口。
    """

    def test_valid_bare_name(self):
        self.assertEqual(validate_table_ref("ODS_HSFA_TZQXX_PFD"),
                         "ODS_HSFA_TZQXX_PFD")

    def test_valid_schema_qualified(self):
        self.assertEqual(validate_table_ref("ODS_XDAY_O32.TBL"),
                         "ODS_XDAY_O32.TBL")

    def test_rejects_quotes(self):
        with self.assertRaises(ValueError):
            validate_table_ref("ODS_X'; DROP TABLE X--")

    def test_rejects_semicolon_and_comment(self):
        with self.assertRaises(ValueError):
            validate_table_ref("TBL;--")

    def test_rejects_space(self):
        with self.assertRaises(ValueError):
            validate_table_ref("A B")

    def test_rejects_empty(self):
        with self.assertRaises(ValueError):
            validate_table_ref("")

    def test_qualify_table_rejects_injection(self):
        with self.assertRaises(ValueError):
            qualify_table("ODS_X'; DROP TABLE X--")

    def test_qualify_table_accepts_normal(self):
        self.assertEqual(qualify_table("ODS_HSFA_TZQXX_PFD"),
                         "ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD")
        self.assertEqual(qualify_table("ODS_XDAY_O32.TBL"), "ODS_XDAY_O32.TBL")


class TestQualify(unittest.TestCase):
    def test_ods_bare(self):
        self.assertEqual(qualify_table("ODS_HSFA_TZQXX_PFD"),
                         "ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD")

    def test_dwd_dws_bare(self):
        self.assertEqual(qualify_table("DWD_CMM_STD_DICT_CDVAL_MAP"),
                         "DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP")
        self.assertEqual(qualify_table("DWS_PROD_X_PFD"), "DWSXDAY.DWS_PROD_X_PFD")

    def test_already_qualified(self):
        self.assertEqual(qualify_table("ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD"),
                         "ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD")

    def test_unknown_prefix_untouched(self):
        self.assertEqual(qualify_table("T1"), "T1")

    def test_qualify_subquery_roundtrip(self):
        out = qualify_subquery_tables(REAL_SUBQUERY)
        self.assertIn("FROM ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T1", out)
        self.assertIn("LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2", out)
        self.assertIn("LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3", out)
        self.assertIn("WHERE T1.P_DT = '${p_end_dt}'", out)


class TestFuncCompat(unittest.TestCase):
    """★ 2026-10-12（J-07）回归：IFNULL/ISNULL → NVL（Hive 4 无 IFNULL）。

    甲方 MAPPING 映射规则直填 MySQL 风格函数，实测 8 张表报
    `SemanticException [Error 10011]: Invalid function IFNULL`。
    """

    def test_ifnull_mapped(self):
        from tools.core.sql_tables import compat_sql_functions
        self.assertEqual(compat_sql_functions("IFNULL(T1.A, 0)"), "COALESCE(T1.A, 0)")
        self.assertEqual(compat_sql_functions("ifnull(T1.A, 0)"), "COALESCE(T1.A, 0)")
        self.assertEqual(compat_sql_functions("ISNULL(T1.A, 0)"), "COALESCE(T1.A, 0)")

    def test_no_false_positive(self):
        from tools.core.sql_tables import compat_sql_functions
        # 不含目标函数的原样返回；NVL2（3 参）不能被误改
        self.assertEqual(compat_sql_functions("COALESCE(T1.A, 0)"), "COALESCE(T1.A, 0)")
        self.assertEqual(compat_sql_functions("NVL2(T1.A, 1, 2)"), "NVL2(T1.A, 1, 2)")
        self.assertEqual(compat_sql_functions("T1.IFNULL_FLAG"), "T1.IFNULL_FLAG")

    def test_resolve_expr_applies_compat(self):
        gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)
        self.assertEqual(gen._resolve_expr("IFNULL(T1.AMT,0)"), "COALESCE(T1.AMT,0)")

    def test_end_to_end_select(self):
        """端到端：映射规则带 IFNULL ⇒ SELECT 行里是 COALESCE。"""
        rows = [
            MappingRule(tgt_name="AMT", tgt_ordinal=1.0, group_no="1",
                        src_table_alias="T1", src_table_name="ODS_O32_TX_PFD",
                        join_type="MAIN TABLE",
                        src_field_alias="IFNULL(T1.EN_AMT, 0)"),
        ]
        gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)
        aliases = gen._collect_aliases(rows)
        lines = gen._build_select_lines(rows, [], {"SSYS", "SRC_TAB"}, "O32")
        joined = "\n".join(lines)
        self.assertIn("COALESCE(T1.EN_AMT, 0)", joined)
        self.assertNotIn("IFNULL", joined)


class TestResolveGroupSrcTab(unittest.TestCase):
    """★ J-26（2026-10-14）：SRC_TAB 必须取 MAPPING 登记行的原文，不得整表拼接。

    真实事故：UNP_YIEL 两个分支都被拼成 5 张表的并集
      ('ODS_XDAY_HSZTA.ODS_HSZTA_TINCOME_PTD,DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD,...,ODS_XDAY_HSFTA.ODS_HSFTA_TINCOME_PTD')
    而 MAPPING 每分支登记行分别是 'ODS_HSZTA_TINCOME_PTD' / 'ODS_HSFTA_TINCOME_PTD'
    （与甲方脚本一致）。
    """

    def _row(self, tgt, alias, group="1"):
        return MappingRule(tgt_name=tgt, tgt_ordinal=99.0, group_no=group,
                           src_table_alias="", src_table_name="",
                           src_field_alias=alias)

    def test_literal_from_excel(self):
        rows = [self._row("SRC_TAB", "'ODS_HSZTA_TINCOME_PTD'")]
        self.assertEqual(_resolve_group_src_tab(rows, ["A", "B"]),
                         "'ODS_HSZTA_TINCOME_PTD'")

    def test_passthrough_expr(self):
        """TMP 透传行（如 WARN_HIS 的 T1.SRC_TAB）原样输出。"""
        rows = [self._row("SRC_TAB", "T1.SRC_TAB")]
        self.assertEqual(_resolve_group_src_tab(rows, []), "T1.SRC_TAB")

    def test_bare_name_wrapped(self):
        rows = [self._row("SOURCE_TAB", "ODS_HSFA_TQSK_PTD")]
        self.assertEqual(_resolve_group_src_tab(rows, []), "'ODS_HSFA_TQSK_PTD'")

    def test_fallback_when_absent(self):
        """未登记 ⇒ 保留旧的整表源表清单拼接行为（如 SCR_CHANGE）。"""
        self.assertEqual(_resolve_group_src_tab([], ["A_PTD", "B_PFD"]),
                         "'A_PTD,B_PFD'")

    def test_group_scoped(self):
        """每个分支只认自己组里的登记行（r36 c6=1 / r61 c6=2）。"""
        b1 = [self._row("SRC_TAB", "'ODS_HSZTA_TINCOME_PTD'", "1"),
              self._row("AMT", "T1.AMOUNT", "1")]
        b2 = [self._row("SRC_TAB", "'ODS_HSFTA_TINCOME_PTD'", "2")]
        self.assertEqual(_resolve_group_src_tab(b1, []), "'ODS_HSZTA_TINCOME_PTD'")
        self.assertEqual(_resolve_group_src_tab(b2, []), "'ODS_HSFTA_TINCOME_PTD'")

    def test_end_to_end_select_line(self):
        """端到端：_build_select_lines 里 SRC_TAB 行 = Excel 值，不是拼接。"""
        rows = [
            MappingRule(tgt_name="AMT", tgt_ordinal=1.0, group_no="1",
                        src_table_alias="T1", src_table_name="ODS_HSZTA_TINCOME_PTD",
                        join_type="MAIN TABLE", src_field_alias="T1.AMOUNT"),
            MappingRule(tgt_name="SRC_TAB", tgt_ordinal=99.0, group_no="1",
                        src_table_alias="", src_table_name="",
                        src_field_alias="'ODS_HSZTA_TINCOME_PTD'"),
        ]
        gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)
        lines = gen._build_select_lines(
            rows, ["ODS_HSZTA_TINCOME_PTD", "DWD_PROD_PROD_NUM_MAPP_PFD"],
            {"SSYS", "SRC_TAB"}, "HSZTA")
        joined = "\n".join(lines)
        self.assertIn("'ODS_HSZTA_TINCOME_PTD'", joined)
        self.assertNotIn("DWD_PROD_PROD_NUM_MAPP_PFD", joined)


class TestWrap(unittest.TestCase):
    def test_wrap_bare(self):
        self.assertEqual(wrap_subquery("SELECT 1"), "(SELECT 1)")

    def test_already_wrapped(self):
        self.assertEqual(wrap_subquery("(SELECT 1)"), "(SELECT 1)")


class TestRenderSrcRef(unittest.TestCase):
    """★ 核心回归：FROM/JOIN 里的子查询必须带 parentheses。"""

    def test_plain_table(self):
        self.assertEqual(_render_src_ref("ODS_O32_TUNITSTOCK_PFD"),
                         "ODS_XDAY_O32.ODS_O32_TUNITSTOCK_PFD")

    def test_bare_dwd_table_qualified(self):
        """★ 2026-10-12：普通行里的裸 DWD_ 表名也要补 DWDXDAY.（此前-only-ODS 前缀）。"""
        self.assertEqual(_render_src_ref("DWD_CMM_STD_DICT_CDVAL_MAP"),
                         "DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP")
        self.assertEqual(_render_src_ref("DWS_PROD_X_PTD"),
                         "DWSXDAY.DWS_PROD_X_PTD")

    def test_bare_dwd_in_build_from_join(self):
        """端到端：MAPPING 普通行填裸 DWD_ 表名 ⇒ 生成 LEFT JOIN DWDXDAY.xxx。"""
        rows = [
            MappingRule(tgt_name="A", tgt_ordinal=1.0, group_no="1",
                        src_table_alias="A1", src_table_name="ODS_HSFA_TQSK_PTD",
                        join_type="MAIN TABLE"),
            MappingRule(tgt_name="B", tgt_ordinal=2.0, group_no="1",
                        src_table_alias="A3",
                        src_table_name="DWD_CMM_STD_DICT_CDVAL_MAP",
                        join_type="LEFT JOIN", src_table_cn="标准字典码值映射"),
        ]
        gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)
        aliases = gen._collect_aliases(rows)
        clause = gen._build_from_join(aliases)
        self.assertIn("LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3", clause)

    def test_subquery_wrapped_and_qualified(self):
        out = _render_src_ref(REAL_SUBQUERY)
        self.assertTrue(out.startswith("(SELECT"), out[:40])
        self.assertTrue(out.endswith(")"), out[-40:])
        self.assertIn("FROM ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T1", out)
        self.assertIn("LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2", out)
        # 不能再出现「JOIN SELECT」（无括号的老 bug 形态）
        self.assertNotIn("JOIN SELECT", out)
        self.assertNotIn("FROM SELECT", out)


class TestBuildFromJoinWithSubquery(unittest.TestCase):
    """端到端：`_build_from_join` 产出 `LEFT JOIN ( ... ) A12 --中文名`。"""

    def setUp(self):
        self.gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)

    def test_join_clause(self):
        rows = [
            MappingRule(tgt_name="L_ZQNM", tgt_ordinal=1.0, group_no="1",
                        src_table_alias="T1", src_table_name="ODS_HSFA_TQSK_PTD",
                        join_type="MAIN TABLE"),
            MappingRule(tgt_name="L_ZQLB", tgt_ordinal=2.0, group_no="1",
                        src_table_alias="A12", src_table_name=REAL_SUBQUERY,
                        join_type="LEFT JOIN", src_table_cn="证券类别信息"),
        ]
        aliases = self.gen._collect_aliases(rows)
        from_clause = self.gen._build_from_join(aliases)
        self.assertIn("FROM ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD T1", from_clause)
        self.assertIn("LEFT JOIN (SELECT", from_clause)
        self.assertIn(") A12 --证券类别信息", from_clause)
        self.assertIn("FROM ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T1", from_clause)
        self.assertNotIn("JOIN SELECT", from_clause)


class TestTypeClass(unittest.TestCase):
    """★ 2026-10-26 回归：`_type_class` 必须同时识别 Hive 与 Oracle 的字符串类型。

    抽取共享常量时曾漏掉 `STRING`（只查 ORACLE_CHAR_PREFIXES）⇒ STRING 被归成
    `other` ⇒ `_unify_union_type` 判定不出 string↔numeric 的差异 ⇒ 该 CAST 的
    没 CAST ⇒ UNION ALL 两侧类型不一致报 SemanticException。
    """

    def test_hive_and_oracle_types(self):
        cases = {
            # Hive 字符串
            "STRING": "string", "TEXT": "string",
            # Oracle 字符串
            "VARCHAR2(20)": "string", "CHAR(1)": "string", "NVARCHAR(10)": "string",
            # 数值（Hive + Oracle）
            "DECIMAL(16,2)": "numeric", "NUMBER(10,0)": "numeric",
            "BIGINT": "numeric", "DOUBLE": "numeric", "INT": "numeric",
            # 日期
            "DATE": "date", "TIMESTAMP": "date",
            # 空与其它
            "": "", "BOOLEAN": "other",
        }
        for t, expected in cases.items():
            self.assertEqual(BaseGenerator._type_class(t), expected, f"type={t!r}")
