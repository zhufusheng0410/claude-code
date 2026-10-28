# -*- coding: utf-8 -*-
"""2026-10-05 修复的回归测试：DWD ETL 的 UNION 分组。

背景（真实事故）：MAPPING 的「组别」列常被误填 —— 把 SSYS/SRC_TAB/LD_TIME/MODIFY_TIME
这类【系统字段行】标成第 2 组，而真正的两组业务数据都留在第 1 组。后果：
  ① 系统字段单独成组 ⇒ 该组没有源表 ⇒ 生成 `FROM source_table` 占位符 ⇒ 一跑就
     Table not found；
  ② 两组业务数据挤在同一组 ⇒ _collect_aliases 对同一别名 A1 只保留首次出现的源表
     ⇒ 第二个源表被**静默丢掉**，数据少一半（DWD_PTY_DELR_INFO_PTD 实测丢掉了
     ODS_O32_TSTOCKRIVALTRADER_PFD 那一支）。

修法：组内出现「同一别名指向不同源表」时按序号回退二次切分，并带安全闸；
      再丢掉完全没有源表的伪组。
"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from tools.core.ir import MappingRule  # noqa
from tools.generator.base import BaseGenerator, FROM_PLACEHOLDER  # noqa
from tools.config import DWD_SCHEMA, SYS_FIELDS_DWD  # noqa


def row(ordinal, tgt, alias="", table="", join="", group="1", field=""):
    return MappingRule(
        tgt_name=tgt, tgt_ordinal=float(ordinal), group_no=group,
        src_field_alias=field, src_table_alias=alias,
        src_table_name=table, join_type=join,
    )


class TestGrouping(unittest.TestCase):
    def setUp(self):
        self.gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)

    # ---- 冲突检测 ----
    def test_no_conflict_when_alias_stable(self):
        rows = [row(1, "A", "A1", "T_ONE", "MAIN TABLE"),
                row(2, "B", "A1", "T_ONE")]
        self.assertFalse(BaseGenerator._has_alias_conflict(rows))

    def test_conflict_when_same_alias_two_tables(self):
        rows = [row(1, "A", "A1", "T_ONE", "MAIN TABLE"),
                row(2, "B", "A1", "T_TWO")]
        self.assertTrue(BaseGenerator._has_alias_conflict(rows))

    def test_empty_alias_not_conflict(self):
        """别名/源表为空的行不参与冲突判定"""
        rows = [row(1, "SSYS"), row(2, "LD_TIME")]
        self.assertFalse(BaseGenerator._has_alias_conflict(rows))

    # ---- 序号回退切分 ----
    def test_split_on_ordinal_regression(self):
        rows = [row(1, "A"), row(2, "B"), row(1, "C"), row(2, "D")]
        subs = BaseGenerator._split_by_ordinal(rows)
        self.assertEqual(len(subs), 2)
        self.assertEqual([r.tgt_name for r in subs[0]], ["A", "B"])
        self.assertEqual([r.tgt_name for r in subs[1]], ["C", "D"])

    def test_no_split_when_monotonic(self):
        rows = [row(1, "A"), row(2, "B"), row(3, "C")]
        self.assertEqual(len(BaseGenerator._split_by_ordinal(rows)), 1)

    # ---- 安全闸 ----
    def test_subgroups_splits_when_each_part_has_main_table(self):
        """两组各有 MAIN TABLE ⇒ 应该切"""
        rows = [
            row(1, "A", "A1", "T_ONE", "MAIN TABLE"),
            row(2, "B", "A1", "T_ONE"),
            row(1, "C", "A1", "T_TWO", "MAIN TABLE"),
            row(2, "D", "A1", "T_TWO"),
        ]
        subs = self.gen._subgroups(rows)
        self.assertEqual(len(subs), 2)
        self.assertEqual(subs[0][0].src_table_name, "T_ONE")
        self.assertEqual(subs[1][0].src_table_name, "T_TWO")

    def test_subgroups_aborts_when_a_part_lacks_main_table(self):
        """切完有一组没有 MAIN TABLE ⇒ 整体放弃切分（安全闸）"""
        rows = [
            row(1, "A", "A1", "T_ONE", "MAIN TABLE"),
            row(2, "B", "A1", "T_ONE"),
            # 第二段只有 LEFT JOIN，没有 MAIN TABLE
            row(1, "C", "A2", "DWD_CMM_STD_DICT_CDVAL_MAP", "LEFT JOIN"),
        ]
        subs = self.gen._subgroups(rows)
        self.assertEqual(len(subs), 1, "安全闸应当阻止切分")

    def test_subgroups_aborts_when_a_part_has_no_source(self):
        """切完有一组拿不到任何别名 ⇒ 放弃切分"""
        rows = [
            row(1, "A", "A1", "T_ONE", "MAIN TABLE"),
            row(2, "SSYS"),          # 无别名无源表
            row(1, "LD_TIME"),
        ]
        subs = self.gen._subgroups(rows)
        self.assertEqual(len(subs), 1)

    def test_subgroups_noop_without_conflict(self):
        rows = [row(1, "A", "A1", "T_ONE", "MAIN TABLE"),
                row(2, "B", "A1", "T_ONE")]
        self.assertEqual(len(self.gen._subgroups(rows)), 1)


class TestPseudoGroupDropped(unittest.TestCase):
    """端到端：系统字段伪组应被丢弃，而不是产出一个 FROM 占位符分支"""

    def setUp(self):
        self.gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)

    def test_system_field_pseudo_group_not_emitted(self):
        from tools.core.ir import MappingSheet
        sheet = MappingSheet(
            tgt_table="DWDXDAY.DWD_PTY_DELR_INFO_PTD",
            tgt_table_cn="交易员信息",
            param="p_batch_dt",
            source_tables=["ODS_O32_TRIVALTRADER_PFD"],
            mappings=[
                # 第 1 组：正常业务数据
                row(1, "CNTP_NO", "A1", "ODS_O32_TRIVALTRADER_PFD", "MAIN TABLE",
                    field="A1.L_RIVAL_ID"),
                row(2, "DELR_ID", "A1", "ODS_O32_TRIVALTRADER_PFD", field="A1.VC_TRADER_ID"),
                # ★ 被误标成第 2 组的系统字段行（无源表）
                row(13, "SSYS", group="2"),
                row(14, "LD_TIME", group="2"),
            ],
        )
        txt = self.gen.generate_etl(sheet, "MASTER")
        self.assertNotIn(FROM_PLACEHOLDER, txt, "伪组应被丢弃，不应留下 FROM 占位符")
        self.assertIn("ODS_O32_TRIVALTRADER_PFD", txt)
        self.assertEqual(txt.count("UNION ALL"), 0)

    def test_real_broken_group_still_flagged(self):
        """整表都没源表时，占位符必须带醒目标记（不能静默）"""
        from tools.core.ir import MappingSheet
        sheet = MappingSheet(
            tgt_table="DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD",
            tgt_table_cn="HSFA业务证券内码",
            param="PI_DATE",
            mappings=[row(1, "SCR_INCD", field="T1.VC_INTER_CODE")],
        )
        txt = self.gen.generate_etl(sheet, "MASTER")
        self.assertIn(FROM_PLACEHOLDER, txt)
        self.assertIn("★★TODO", txt, "缺源表时必须打醒目标记")
        self.assertIn("★★ 警告", txt)


class TestCommentNewline(unittest.TestCase):
    """2026-10-05 修复的回归测试：注释字段里的换行会把 `--` 行注释“撑断”。

    真实事故：`DWD_PROD_PROD_NUM_MAPP_PFD` 的 MAPPING「描述」列含手工换行
    （「1、…\\n2、…」），生成器原样拼进 `-- ** 描述:` 一行 ⇒ 续行没有 `--` 前缀
    ⇒ Hive 把续行当 SQL 解析、整条语句从该处报
    `ParseException ... cannot recognize input near '2' 'TA' 'TA'`。
    列注释（`tgt_name_cn`）含换行是同一类问题，已用 `_one_line()` 压成单行。
    """

    def setUp(self):
        self.gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)

    def _sheet(self, func_desc="", col_cn=""):
        from tools.core.ir import MappingSheet
        r = row(1, "C1", "A1", "ODS_XDAY_HSFA.ODS_HSFA_TX_PFD", "MAIN TABLE", field="A1.C1")
        r.tgt_name_cn = col_cn
        return MappingSheet(
            tgt_table="DWDXDAY.DWD_HSFA_DEMO_PFD", tgt_table_cn="演示表",
            param="PI_DATE", func_desc=func_desc,
            source_tables=["ODS_XDAY_HSFA.ODS_HSFA_TX_PFD"], mappings=[r],
        )

    def test_multiline_desc_every_line_is_comment(self):
        txt = self.gen.generate_etl(
            self._sheet(func_desc="1、第一行\n2、第二行\n3、第三行"), "HSFA")
        for ln in txt.splitlines():
            if any(k in ln for k in ("第一行", "第二行", "第三行")):
                self.assertTrue(ln.lstrip().startswith("--"),
                                f"描述续行未加注释前缀：{ln!r}")
        self.assertNotIn("\n2、", txt)   # 不能出现裸的非注释续行

    def test_multiline_column_comment_collapsed_to_one_line(self):
        txt = self.gen.generate_etl(
            self._sheet(col_cn="账户属性\n(普通、套保)"), "HSFA")
        self.assertIn("--账户属性 (普通、套保)", txt)
        self.assertNotIn("\n(普通、套保)", txt)


class TestDepBlockAliasFilter(unittest.TestCase):
    """2026-10-12：源表英文名为空的行不得把源表别名当"表名"写进依赖声明块。

    真实事故：MAPPING 同组只在首行写一次源表（或子查询），后续行该列为空，
    旧代码 `t = mr.src_table_name or mr.src_table_alias` 回退取到别名 ⇒
      ① DWD_EVT_EQUI_JOUR_INFO_PTD 依赖块出现 "-- ** A12  证券类别信息"；
      ② MAPPING 列错位（组别值漏进别名列）⇒ DWD_PUB_CALENDAR_TAB_PFD 出现 "-- ** 1"。
    规则：数仓表名必含 "_"（ODS_/DWD_/DWS_）或 "."（schema.表），二者皆无即别名，丢弃。
    """

    def setUp(self):
        self.gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)

    @staticmethod
    def _dep_lines(txt):
        lines = txt.splitlines()
        out, on = [], False
        for ln in lines:
            if ln.startswith("-- ** 源表："):
                on = True
                continue
            if on:
                if ln.startswith("-- **         "):
                    out.append(ln)
                else:
                    break
        return out

    def _sheet(self, mappings):
        from tools.core.ir import MappingSheet
        return MappingSheet(
            tgt_table="DWDXDAY.DWD_EVT_DEMO_PTD", tgt_table_cn="演示表",
            param="PI_DATE",
            source_tables=["ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD"],
            mappings=mappings,
        )

    def test_alias_only_rows_not_in_dep_block(self):
        sheet = self._sheet([
            row(1, "C1", "A12", "ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD",
                "MAIN TABLE", field="A12.C1"),
            # 同组后续行：源表英文名留空（甲方只在首行写一次），别名仍 A12
            row(2, "C2", "A12", "", field="A12.C2"),
            # 列错位行：别名列被填成组别数字 "1"
            row(3, "C3", "1", "", field="A1.C3"),
        ])
        dep = self._dep_lines(self.gen.generate_etl(sheet, "HSFA"))
        self.assertTrue(dep, "依赖声明块不应为空")
        joined = "\n".join(dep)
        self.assertIn("ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD", joined,
                      "真实源表必须在依赖块中")
        for ln in dep:
            token = ln.replace("-- **", "").strip().split()[0]
            self.assertNotIn(token, ("A12", "A1", "1", "T1"),
                             f"别名混入依赖声明块：{ln!r}")

    def test_real_table_always_kept(self):
        sheet = self._sheet([
            row(1, "C1", "A1", "ODS_XDAY_HSFA.ODS_HSFA_TX_PFD",
                "MAIN TABLE", field="A1.C1"),
            row(2, "SSYS", group="2"),
        ])
        dep = "\n".join(self._dep_lines(self.gen.generate_etl(sheet, "HSFA")))
        self.assertIn("ODS_XDAY_HSFA.ODS_HSFA_TX_PFD", dep)


class TestSplitOnAnd(unittest.TestCase):
    """★ 2026-10-22：ON 条件的顶层 AND 切分（评审 MEDIUM-3 修 bug）。

    原实现用 `re.split(r'\\s+AND\\s+', cond, flags=re.IGNORECASE)` 无差别切分，
    于是条件**值里**出现的 AND 也会被切开：
        `T1.CODE = 'A AND B' AND T1.F = 'Y'`
    → 被切成 `['T1.CODE = 'A AND B'", "T1.F = 'Y'"]` 看似没事，但值里含 AND
    的**单个**条件会被切成两段 ⇒ 生成残缺的 ON 子句 ⇒ Hive ParseException。

    改为逐字符扫描，只在字符串字面量**之外**的顶层 AND 处切分。
    """

    def setUp(self):
        self.split = BaseGenerator._split_on_and

    def test_two_conditions(self):
        self.assertEqual(self.split("T1.A = 1 AND T1.B = 2"),
                         ["T1.A = 1", "T1.B = 2"])

    def test_and_inside_string_literal_not_split(self):
        self.assertEqual(self.split("T1.CODE = 'A AND B' AND T1.F = 'Y'"),
                         ["T1.CODE = 'A AND B'", "T1.F = 'Y'"])

    def test_single_condition_with_and_in_value(self):
        self.assertEqual(self.split("T1.CODE = 'A AND B'"),
                         ["T1.CODE = 'A AND B'"])

    def test_escaped_quote_inside_literal(self):
        self.assertEqual(self.split("T1.S = 'it''s AND fine' AND T1.X=1"),
                         ["T1.S = 'it''s AND fine'", "T1.X=1"])

    def test_lone_trailing_and_dropped(self):
        # 孤立的 AND 是 MAPPING 书写残留，留着会生成 `ON AND x`
        self.assertEqual(self.split("T1.A=1 AND"), ["T1.A=1"])

    def test_lone_leading_and_dropped(self):
        self.assertEqual(self.split("AND T1.A=1"), ["T1.A=1"])

    def test_three_conditions(self):
        self.assertEqual(self.split("T1.A=1 AND T1.B=2 AND T1.C=3"),
                         ["T1.A=1", "T1.B=2", "T1.C=3"])

    def test_and_after_closing_quote(self):
        # 引号紧邻 AND 是合法 SQL 分隔（原正则不切，这里是改进）
        self.assertEqual(self.split("T1.A='X'AND T1.B=2"),
                         ["T1.A='X'", "T1.B=2"])

    def test_value_starting_with_and(self):
        self.assertEqual(self.split("T1.COL='ANDY' AND T2.X=1"),
                         ["T1.COL='ANDY'", "T2.X=1"])

    def test_identifier_ending_with_and_not_split(self):
        # `1AND` 是标识符片段而非连接符 —— 与原正则行为一致（不切）
        self.assertEqual(self.split("T1.A=1AND T1.B=2"),
                         ["T1.A=1AND T1.B=2"])


class TestCaseExprAliasQuoting(unittest.TestCase):
    """★ 2026-10-22：单行 CASE 分支的目标别名要加反引号（评审 MEDIUM-2）。

    多行分支与 _fmt_select_line 早已用 quote_hive_column_sh，单行分支遗漏 ——
    目标字段若是 Hive 保留字（如 DATE/TIME/USER）会生成 `AS DATE`
    ⇒ Hive ParseException: "cannot recognize input near 'AS' 'DATE'"。
    """

    def setUp(self):
        self.gen = BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, has_src_fields=True)

    def test_single_line_case_alias_quoted(self):
        out = self.gen._format_case_expr(
            "CASE WHEN T1.X IS NOT NULL THEN 'Y' END", "DATE", "日期", "  , ")
        self.assertTrue(out, "应产出至少一行")
        # ★ 注意：quote_hive_column_sh 是「写进 .sh」的变体 —— 反引号还要
        #   再加一层 shell 转义（见 ddl_common.py 的说明：sh 双引号内的反引号
        #   会被当作命令替换）。故这里是 \`DATE\` 而非裸 `DATE`。
        joined = "\n".join(out)
        self.assertIn("\\`DATE\\`", joined)

    def test_multiline_case_alias_quoted(self):
        out = self.gen._format_case_expr(
            "CASE WHEN T1.X IS NOT NULL\n THEN 'Y'\nEND", "DATE", "日期", "  , ")
        joined = "\n".join(out)
        self.assertIn("\\`DATE\\`", joined)

    def test_non_reserved_alias_unchanged(self):
        # 非保留字不该被加反引号（避免无谓的差异噪音）
        out = self.gen._format_case_expr(
            "CASE WHEN T1.X IS NOT NULL THEN 'Y' END", "CUST_TYPE_CODE", "客户类型", "  , ")
        joined = "\n".join(out)
        self.assertIn("CUST_TYPE_CODE", joined)
        self.assertNotIn("\\`CUST_TYPE_CODE\\`", joined)


if __name__ == "__main__":
    unittest.main()
