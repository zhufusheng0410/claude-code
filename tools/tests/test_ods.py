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


class TestMergedDdlDedup(unittest.TestCase):
    """★ 2026-10-09（J-03）回归：合并 DDL 里同一张表只能出现一次。

    调研文档同一张表被列两行时，`iter_ods_tables` 会吐两次 ⇒ 合并文件里出现两个
    `CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD (...)`。
    beeline 顺序执行，第二条直接 AlreadyExistsException，且 `-f` 默认遇错即停
    ⇒ 该系统**后续所有建表都被跳过**（HSFA 78 张全废）。
    """

    def test_duplicate_table_emitted_once(self):
        from tools.generator.ods import generate_all_ods_ddl
        # ★ 必须显式给 is_reserved：iter_ods_tables 会跳过「未保留」的表
        tables = [
            _make_table(src_table="TACCOUNT_HS", ods_table="ODS_HSFA_TACCOUNT_HS_PFD",
                        is_reserved="是"),
            _make_table(src_table="TACCOUNT_HS ", ods_table="ODS_HSFA_TACCOUNT_HS_PFD",
                        is_reserved="是"),
        ]
        flds = {t.src_table: [_make_field()] for t in tables}
        sql = generate_all_ods_ddl(tables, flds, "HSFA")
        n = sql.count("CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD")
        self.assertEqual(n, 1, "重复定义会导致第二条建表报 AlreadyExistsException")

    def test_distinct_tables_all_kept(self):
        """去重不能误删正常的不同表。"""
        from tools.generator.ods import generate_all_ods_ddl
        tables = [
            _make_table(src_table="T_A", ods_table="ODS_HSFA_TA_PFD", is_reserved="是"),
            _make_table(src_table="T_B", ods_table="ODS_HSFA_TB_PFD", is_reserved="是"),
        ]
        flds = {t.src_table: [_make_field()] for t in tables}
        sql = generate_all_ods_ddl(tables, flds, "HSFA")
        self.assertIn("CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TA_PFD", sql)
        self.assertIn("CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TB_PFD", sql)


class TestQuerySqlJsonEscape(unittest.TestCase):
    """★ 2026-10-09（J-05）回归：querySql 嵌进 `.sh` 的 JSON 前必须转义双引号。

    背景：Oracle 保留字列（LEVEL / TYPE）要加双引号，而模板是
    `"querySql": ["${query_sql}"]` —— 裸双引号会打破 JSON，DataX 报
        Code:[Common-00] 您提供的配置信息不是合法的JSON格式: TODO : L
    实测表 JYDB.LC_MAINOPERINCOME / JY_MF_FUNDARCHIVES。
    """

    def test_escape_function(self):
        from tools.generator.ods import _escape_sql_for_json
        self.assertEqual(_escape_sql_for_json('SELECT "LEVEL" FROM T'),
                         'SELECT \\"LEVEL\\" FROM T')

    def test_backslash_escaped_first(self):
        """反斜杠要先转义，否则会把刚加的反斜杠二次转义。"""
        from tools.generator.ods import _escape_sql_for_json
        self.assertEqual(_escape_sql_for_json('a\\b'), 'a\\\\b')

    def test_quoted_oracle_column_survives_json(self):
        """端到端：带双引号列名的 querySql 必须是合法 JSON 字符串。"""
        import json
        from tools.generator.ods import _escape_sql_for_json
        sql = 'SELECT ID, "LEVEL", "TYPE" FROM JYDB.LC_MAINOPERINCOME'
        embedded = '["%s"]' % _escape_sql_for_json(sql)
        obj = json.loads(embedded)          # 不抛异常即合法
        self.assertEqual(obj[0], sql)       # 解出来要和原文一致

    def test_generated_etl_escapes_quoted_column(self):
        """真跑一遍生成器：保留字列的双引号必须以 \\" 形式落进脚本。"""
        from tools.generator.ods import _load_etl_template
        table = _make_table(
            src_sys="JY", src_table="LC_MAINOPERINCOME",
            ods_table="ODS_JY_LC_MAINOPERINCOME_PFD", is_reserved="是",
        )
        flds = [
            _make_field(src_name="ID", src_name_cn="ID", src_type="NUMBER(10)"),
            _make_field(src_name="LEVEL", src_name_cn="层级", src_type="NUMBER(10)"),
        ]
        sh = generate_ods_etl(table, flds, "JY", _load_etl_template())
        self.assertIn('\\"LEVEL\\"', sh, "Oracle 保留字列应转义为 \\\"LEVEL\\\"")
        self.assertNotIn(', "LEVEL"', sh, "不应残留未转义的裸双引号（会破坏 JSON）")

    def test_generated_etl_json_is_valid(self):
        """★ 2026-10-26 回归：生成脚本内嵌的 DataX JSON 必须能被严格解析。

        根因：querySql 由多行 SQL 拼成（`_build_query_sql` 用 `"\\n".join`），
        旧 `_escape_sql_for_json` 只转义 `\\` 和 `"` ⇒ 换行原样留在 JSON 字符串里
        ⇒ 按 RFC 8259 非法（实测 12/12 个 ODS 脚本 `json.loads` 报
        `Invalid control character`）。DataX 解析器宽松才"碰巧能跑"，
        但校验脚本/其它工具链会直接失败。

        这里**真正从生成的 .sh 里抽出 JSON 块**解析，并校验解码后的
        querySql 与生成器拼出的多行 SQL 完全一致（转义不能改值）。
        """
        import json
        import re
        from tools.generator.ods import _load_etl_template

        table = _make_table(
            src_sys="JY", src_table="LC_MAINOPERINCOME",
            ods_table="ODS_JY_LC_MAINOPERINCOME_PFD", is_reserved="是",
        )
        flds = [
            _make_field(src_name="ID", src_name_cn="ID", src_type="NUMBER(10)"),
            _make_field(src_name="LEVEL", src_name_cn="层级", src_type="NUMBER(10)"),
            _make_field(src_name="TYPE", src_name_cn="类型", src_type="VARCHAR2(20)"),
        ]
        sh = generate_ods_etl(table, flds, "JY", _load_etl_template())

        m = re.search(r"json_obj=\$\(cat <<'EOF'\n(.*?)\nEOF\n\)", sh, re.S)
        self.assertIsNotNone(m, "未找到 heredoc JSON 块")
        obj = json.loads(m.group(1))        # 严格解析；不抛异常即合法

        query_sql = obj["job"]["content"][0]["reader"]["parameter"]["connection"][0]["querySql"][0]
        # 解码后必须是多行 SQL，且包含全部字段与保留字双引号
        self.assertIn("\n", query_sql, "解码后应恢复多行 SQL")
        self.assertIn('"LEVEL"', query_sql)
        self.assertIn('"TYPE"', query_sql)
        self.assertTrue(query_sql.startswith("SELECT"))


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


class TestIncrDateQuoting(unittest.TestCase):
    """★ 2026-09-29 回归：增量表日期过滤必须是显式 TO_DATE（Oracle 两级报错）。

    背景
    ----
    ${p_start_dt}/${p_end_dt} 运行时展开为裸的 `2026-09-01`：
      ① 不加引号 → Oracle 当算术表达式（2026-9-01 = NUMBER）→
         ORA-00932: 数据类型不一致: 应为 DATE, 但却获得 NUMBER。
      ② 只加单引号仍不行 → 隐式转换依赖会话 NLS_DATE_FORMAT，
         实测该库为 `DD-MON-RR`，`'2026-09-01'` 解析失败 →
         ORA-01861: 文字与格式字符串不匹配。
    ★ 唯一稳妥写法：TO_DATE('${p_start_dt}','YYYY-MM-DD')，
      完全绕开 NLS_DATE_FORMAT，与会话/源库配置无关。
    """

    def _incr_table(self, cond="D_DATE"):
        return _make_table(
            ods_table="ODS_O32_TACCOUNTZQJC_PTD",
            load_strategy="INCR",
            incr_cond=cond,
        )

    def test_date_col_uses_to_date_yyyymmdd(self):
        """★ 2026-10-09：日期型列用 TO_DATE(...,'YYYYMMDD')（与运行时 20261007 对齐）。"""
        # ★ 列名必须与 incr_cond 一致，否则定位不到增量列 ⇒ 退回「非日期」分支
        script = generate_ods_etl(self._incr_table(),
                                  [_make_field(src_name="D_DATE", src_type="DATE")],
                                  "O32", "${query_sql}")
        self.assertIn("TO_DATE('${p_start_dt}','YYYYMMDD')", script)
        self.assertIn("TO_DATE('${p_end_dt}','YYYYMMDD')", script)

    def test_non_date_col_uses_plain_string(self):
        """★ 2026-10-09：非日期型（NUMBER/字符）一律裸字符串比较，不再包 TO_DATE。"""
        script = generate_ods_etl(self._incr_table(),
                                  [_make_field(src_type="NUMBER(8,0)")],
                                  "O32", "${query_sql}")
        self.assertIn("between '${p_start_dt}' and '${p_end_dt}'", script)
        self.assertNotIn("TO_DATE", script)

    def test_no_bare_placeholder_remains(self):
        """绝不能残留裸占位符 `between ${p_start_dt}`（ORA-00932 根因）。"""
        script = generate_ods_etl(self._incr_table(), [_make_field()], "O32", "${query_sql}")
        self.assertNotIn("between ${p_start_dt}", script)
        self.assertNotIn("and ${p_end_dt}", script)

    def test_no_bare_placeholder_without_quotes(self):
        """绝不能残留**不带引号**的裸占位符（ORA-00932 根因）。

        ★ 注意：带引号的 `'${p_start_dt}'` 对**非日期型**是正确的（2026-10-09 用户拍板），
          这里只禁裸写。"""
        script = generate_ods_etl(self._incr_table(),
                                  [_make_field(src_type="NUMBER(8,0)")],
                                  "O32", "${query_sql}")
        self.assertNotIn("between ${p_start_dt}", script)
        self.assertNotIn("and ${p_end_dt}", script)

    def test_full_table_has_no_date_filter(self):
        """全量表不得出现日期区间过滤（它用 P_DT='${p_end_dt}' 分区）。"""
        table = _make_table(load_strategy="FULL")
        script = generate_ods_etl(table, [_make_field()], "O32", "${query_sql}")
        self.assertNotIn("between", script)


class TestIncrColumnValidation(unittest.TestCase):
    """★ 2026-09-29 回归：incr_cond 引用不存在的列时必须在生成期告警。

    背景（实测案例）
    ----------------
    `HSFA.T_H_FYMX` 的日期列实际叫 `D_YWRQ`，调研文档却填了 `D_RQ`
    → 生成 `WHERE D_RQ between ...` → Oracle `ORA-00904: "D_RQ": 标识符无效`，
    要等 DataX 跑起来才炸。生成器应在**生成阶段**就 WARNING。
    ★ 设计上是「只告警不阻断」—— incr_cond 可能是合法函数/表达式，
      误报人工确认即可，不该中断整批生成。
    """

    def _incr_table(self, cond):
        return _make_table(
            ods_table="ODS_O32_T_H_FYMX_PTD", load_strategy="INCR", incr_cond=cond,
        )

    def test_missing_column_warns(self):
        """incr_cond 引用不存在的列 → 打 WARNING。"""
        table = self._incr_table("D_RQ")
        with self.assertLogs("tools.generator.ods", level="WARNING") as cm:
            generate_ods_etl(table, [_make_field()], "O32", "${query_sql}")
        self.assertTrue(any("D_RQ" in m for m in cm.output))
        self.assertTrue(any("不存在的列" in m for m in cm.output))

    def test_existing_column_no_warning(self):
        """incr_cond 引用真实存在的列 → 不打 WARNING（无误报）。"""
        table = self._incr_table("D_YWRQ")
        field = _make_field(src_name="D_YWRQ")
        with self.assertRaises(AssertionError):  # 断言「没有」WARNING 日志
            with self.assertLogs("tools.generator.ods", level="WARNING"):
                generate_ods_etl(table, [field], "O32", "${query_sql}")

    def test_validation_does_not_block_generation(self):
        """★ 列名不存在也不阻断生成 —— SQL 照样产出，交由人工订正上游。"""
        table = self._incr_table("D_RQ")
        script = generate_ods_etl(table, [_make_field()], "O32", "${query_sql}")
        self.assertIn("WHERE D_RQ between", script)

    def test_sql_keywords_not_treated_as_columns(self):
        """SQL 关键字/函数不该被当成缺失列误报（如 to_date）。

        ★ 2026-10-08：P_DT 取增量列后，本用例的 incr_cond='DATE' 既不是合法列
          也不是裸列名 ⇒ 会额外多出一条「P_DT 退回运行日」的 WARNING。
          这里只断言【缺失列】那条不出现，不要求「零 WARNING」。
        """
        table = self._incr_table("DATE")
        fields = [_make_field(src_name="D_DATE")]
        with self.assertLogs("tools.generator.ods", level="WARNING") as cm:
            generate_ods_etl(table, fields, "O32", "${query_sql}")
        self.assertFalse(
            any("不存在的列" in m for m in cm.output),
            f"SQL 关键字 DATE 被误报成缺失列: {cm.output}",
        )

    def test_nondate_incr_column_warns(self):
        """★ 列名存在但不是日期列 → 也要告警（实测 TVOUCHERSJC: L_YEAR+L_MONTH）。

        只查「列是否存在」抓不到这类：L_YEAR / L_MONTH 确实在字段清单里，
        但拼成 `WHERE L_YEAR+L_MONTH between TO_DATE(...) and TO_DATE(...)` 后
        Oracle 报 ORA-00932（NUMBER vs DATE）。
        """
        table = self._incr_table("L_YEAR+L_MONTH")
        fields = [_make_field(src_name="L_YEAR"), _make_field(src_name="L_MONTH")]
        with self.assertLogs("tools.generator.ods", level="WARNING") as cm:
            generate_ods_etl(table, fields, "O32", "${query_sql}")
        self.assertTrue(any("疑似非日期列" in m for m in cm.output))
        self.assertTrue(any("ORA-00932" in m for m in cm.output))

    def test_dateish_column_no_warning(self):
        """★ 零误报底线：D_ 开头的日期列不得告警（23 张增量表里 22 张是这种）。"""
        table = self._incr_table("D_DATE")
        with self.assertRaises(AssertionError):
            with self.assertLogs("tools.generator.ods", level="WARNING"):
                generate_ods_etl(table, [_make_field(src_name="D_DATE")], "O32", "${query_sql}")


class TestIncrCondPlaceholder(unittest.TestCase):
    """★ 2026-10-18（评审 #1）：增量条件填「无」/`nan` ⇒ 必须按「无过滤」处理。

    重写生成器时丢了旧守卫：`无`/`nan` 原文是真值 ⇒ 进了 INCR+WHERE 分支，
    但 WHERE 左操作数已按约定归一化成空串 ⇒ 产出
        WHERE  between '${p_start_dt}' and '${p_end_dt}'
    （缺左操作数，DataX 拉数时才炸）。当前调研文档 0 命中，属潜伏回归 ——
    未来谁把增量条件改成「无」就会踩中，本类把守卫钉死。
    """

    def _incr_table(self, cond):
        return _make_table(
            ods_table="ODS_O32_T_H_FYMX_PTD", load_strategy="INCR", incr_cond=cond,
        )

    def test_wu_and_nan_produce_no_where(self):
        for cond in ("无", "nan"):
            script = generate_ods_etl(self._incr_table(cond),
                                      [_make_field(src_name="D_YWRQ")],
                                      "O32", "${query_sql}")
            self.assertNotIn("WHERE", script, f"incr_cond={cond!r} 不应生成 WHERE")
            self.assertNotIn("between", script, f"incr_cond={cond!r} 不应生成区间过滤")

    def test_normal_cond_still_filtered(self):
        """对照组：正常增量条件不受守卫影响。"""
        script = generate_ods_etl(self._incr_table("D_YWRQ"),
                                  [_make_field(src_name="D_YWRQ")],
                                  "O32", "${query_sql}")
        self.assertIn("WHERE D_YWRQ between", script)


class TestIncrPartitionColumn(unittest.TestCase):
    """★ 2026-09-29 回归：增量表动态分区 P_DT 必须在 SELECT 末列（Hive Error 10044）。

    背景
    ----
    增量表走动态分区 `PARTITION(P_DT)`，此时分区列 P_DT 必须作为 SELECT
    的最后一列出现，Hive 才能从数据中取分区值。漏掉它会导致：
      Error 10044: Table insclause-0 has 18 columns, but query has 17 columns
    （18 = 16 业务 + LD_TIME + P_DT；17 = 只有前两者）
    全量表走静态分区 PARTITION(P_DT='${p_end_dt}')，不得多出 P_DT 列。

    ★★ 2026-10-08 变更：增量表的 P_DT **不再取运行日**，改为取增量日期列的值。
       见 TestIncrPartitionValue 的详细断言。
    """

    def test_incr_select_ends_with_p_dt(self):
        """增量表 SELECT 必须以 P_DT 收尾（值是增量列，不再是运行日）。"""
        table = _make_table(
            ods_table="ODS_O32_TBJJFH_PTD", load_strategy="INCR", incr_cond="D_YWRQ",
        )
        script = generate_ods_etl(table, [_make_field(src_name="D_YWRQ")], "O32", "${select_columns}")
        self.assertIn("P_DT", script)
        self.assertNotIn("'${p_end_dt}' P_DT", script)
        self.assertIn("D_YWRQ P_DT", script)

    def test_full_select_has_no_p_dt(self):
        """全量表不得在 SELECT 里出现 P_DT（它用静态分区）。"""
        table = _make_table(load_strategy="FULL")
        script = generate_ods_etl(table, [_make_field()], "O32", "${select_columns}")
        self.assertNotIn("P_DT", script)


class TestIncrPartitionValue(unittest.TestCase):
    """★★ 2026-10-08 用户拍板：增量表 P_DT 取【增量日期列的值】，不取运行日。

    规则（用户明确裁决）：
      1. P_DT 统一成 **8 位 yyyyMMdd 字符型**，不 TO_CHAR 成 yyyy-MM-dd；
      2. 按增量列的【源库类型】分支：
         - `DATE`        → 直接取列（该列已被 querySql 的 TO_CHAR 包成 8 位）
         - `NUMBER`      → `CAST(col AS STRING)`
         - `CHAR/VARCHAR2` → 直接取列（源值本就是 8 位字符串）
      3. NULL 不兜底 —— 允许出现 P_DT=NULL 分区，不加 NVL。
    定位不到唯一日期列时退回 `'${p_end_dt}'`（不阻断生成）。
    """

    def _etl(self, incr_cond, field_name="L_DATE", hive_type="DECIMAL(8,0)",
             src_type="NUMBER(8,0)"):
        table = _make_table(
            ods_table="ODS_HSZTA_TCONFIRM_PTD", load_strategy="INCR", incr_cond=incr_cond,
        )
        fields = [
            _make_field(src_name=field_name, src_name_cn="日期",
                        hive_type=hive_type, src_type=src_type),
            _make_field(src_name="C_MEMO", src_name_cn="备注"),
        ]
        # ★ 模板同时含 query_sql 与 select_columns —— 前者看 DataX 侧，
        #   后者看 Hive INSERT 侧的 P_DT。
        return generate_ods_etl(table, fields, "HSZTA", "${query_sql}\n${select_columns}")

    # ---- NUMBER 型：CAST AS STRING ----
    def test_decimal_col_casted_to_string(self):
        s = self._etl("L_DATE", "L_DATE", "DECIMAL(8,0)", "NUMBER(8,0)")
        self.assertIn("CAST(L_DATE AS STRING) P_DT", s)

    def test_decimal_10_0_col_casted(self):
        s = self._etl("L_DATE", "L_DATE", "DECIMAL(10,0)", "NUMBER(10,0)")
        self.assertIn("CAST(L_DATE AS STRING) P_DT", s)

    def test_bigint_col_casted(self):
        s = self._etl("L_DATE", "L_DATE", "BIGINT", "NUMBER(19,0)")
        self.assertIn("CAST(L_DATE AS STRING) P_DT", s)

    # ---- DATE 型：直接取（querySql 已 TO_CHAR 包成 8 位）----
    def test_date_col_uses_replace(self):
        """★ 2026-10-09：日期型 P_DT 用 REPLACE(<col>,'-','') 去横杠。"""
        s = self._etl("D_DATE", "D_DATE", "STRING", "DATE")
        self.assertIn("REPLACE(D_DATE,'-','') P_DT", s)
        self.assertNotIn("CAST(D_DATE AS STRING) P_DT", s)

    def test_date_col_wrapped_by_to_char_in_query(self):
        """★ DATE 型必须在 querySql 里 TO_CHAR 成 YYYYMMDD，否则落 TMP 是 07-OCT-26。"""
        s = self._etl("D_DATE", "D_DATE", "STRING", "DATE")
        self.assertIn("TO_CHAR(D_DATE,'YYYYMMDD') D_DATE", s)

    # ---- 字符型：直接取 ----
    def test_string_col_used_as_is(self):
        s = self._etl("D_CDATE", "D_CDATE", "STRING", "CHAR(8)")
        self.assertIn("D_CDATE P_DT", s)
        self.assertNotIn("CAST(", s)

    def test_string_col_not_to_char(self):
        """不得把增量列 TO_CHAR 成 yyyy-MM-dd（用户要求 P_DT 是 8 位 yyyyMMdd）。

        ★ 只检查 P_DT 那一行 —— 脚本里本就有一处 LD_TIME 用了
          `'yyyy-MM-dd HH:mm:ss'` 格式串，不能对整个脚本断言。
        """
        s = self._etl("D_CDATE", "D_CDATE", "STRING", "CHAR(8)")
        p_dt_line = [ln for ln in s.splitlines() if ln.strip().endswith("P_DT")]
        self.assertEqual(len(p_dt_line), 1)
        self.assertNotIn("yyyy-MM-dd", p_dt_line[0])

    def test_string_col_not_wrapped_in_query(self):
        """字符型列**不该**被 TO_CHAR 包装（源值本就是 8 位字符串）。"""
        s = self._etl("D_CDATE", "D_CDATE", "STRING", "CHAR(8)")
        self.assertNotIn("TO_CHAR(", s.split("FROM")[0])

    # ---- 规则 3：NULL 不兜底 ----
    def test_null_not_coalesced(self):
        s = self._etl("L_DATE", "L_DATE", "DECIMAL(8,0)", "NUMBER(8,0)")
        self.assertNotIn("NVL", s)
        self.assertNotIn("COALESCE", s)

    # ---- 带表名前缀的 incr_cond ----
    def test_prefixed_column_resolved(self):
        s = self._etl("T.D_CDATE", "D_CDATE", "STRING", "CHAR(8)")
        self.assertIn("D_CDATE P_DT", s)

    # ---- 大小写不敏感 ----
    def test_case_insensitive_match(self):
        s = self._etl("l_date", "L_DATE", "DECIMAL(8,0)", "NUMBER(8,0)")
        self.assertIn("CAST(L_DATE AS STRING) P_DT", s)

    # ---- 定位不到 ⇒ 退回运行日，且不抛异常 ----
    def test_expression_falls_back_to_run_date(self):
        s = self._etl("L_YEAR+L_MONTH", "L_DATE", "DECIMAL(8,0)", "NUMBER(8,0)")
        self.assertIn("'${p_end_dt}' P_DT", s)

    def test_unknown_column_falls_back(self):
        s = self._etl("NOT_A_COL", "L_DATE", "DECIMAL(8,0)", "NUMBER(8,0)")
        self.assertIn("'${p_end_dt}' P_DT", s)

    def test_empty_incr_cond_falls_back(self):
        s = self._etl("", "L_DATE", "DECIMAL(8,0)", "NUMBER(8,0)")
        self.assertIn("'${p_end_dt}' P_DT", s)

    # ---- 全量表不受影响 ----
    def test_full_table_still_uses_run_date_partition(self):
        table = _make_table(load_strategy="FULL", ods_table="ODS_X_PFD")
        s = generate_ods_etl(table, [_make_field(src_name="L_DATE")], "HSZTA", "${select_columns}")
        self.assertNotIn("P_DT", s.split("INSERT OVERWRITE")[-1].split("FROM")[0])


class TestIncrWherePredicate(unittest.TestCase):
    """★★★ 2026-10-08：WHERE 上下界必须按【增量列的源库类型】动态生成。

    背景（159 个增量表的 Oracle 实测，见 ODS问题汇总.xlsx「类型探针」）：
      | 源类型          | 数量 | 原一刀切 TO_DATE 的后果                    |
      |----------------|-----|------------------------------------------|
      | DATE           |  68 | OK                                        |
      | NUMBER         |  58 | ORA-00932（NUMBER 与 DATE 比较）           |
      | CHAR/VARCHAR2  |  25 | **静默 0 行**（不报错但一行都抽不到）        |
    """

    def _etl(self, incr_cond, field_name, src_type):
        table = _make_table(
            ods_table="ODS_X_PTD", load_strategy="INCR", incr_cond=incr_cond,
        )
        fields = [_make_field(src_name=field_name, src_name_cn="日期", src_type=src_type)]
        # ★ 必须传 "${query_sql}" 作模板才能看到 WHERE（传 ${select_columns} 只看 INSERT 列）
        return generate_ods_etl(table, fields, "HSZTA", "${query_sql}")

    def test_date_uses_to_date_yyyymmdd(self):
        s = self._etl("D_DATE", "D_DATE", "DATE")
        self.assertIn("TO_DATE('${p_start_dt}','YYYYMMDD')", s)
        self.assertIn("TO_DATE('${p_end_dt}','YYYYMMDD')", s)
        self.assertNotIn("YYYY-MM-DD", s)

    def test_number_uses_plain_string(self):
        """★ 2026-10-09：NUMBER 改裸字符串（Oracle 隐式转 NUMBER），不再 TO_NUMBER(REPLACE)。"""
        s = self._etl("L_DATE", "L_DATE", "NUMBER(8,0)")
        self.assertIn("between '${p_start_dt}' and '${p_end_dt}'", s)
        self.assertNotIn("TO_NUMBER", s)
        self.assertNotIn("TO_DATE", s)

    def test_char_uses_plain_string(self):
        s = self._etl("D_CDATE", "D_CDATE", "CHAR(8)")
        self.assertIn("between '${p_start_dt}' and '${p_end_dt}'", s)
        self.assertNotIn("TO_DATE", s)
        self.assertNotIn("REPLACE", s)

    def test_varchar2_uses_plain_string(self):
        s = self._etl("TRADE_DT", "TRADE_DT", "VARCHAR2")
        self.assertIn("between '${p_start_dt}' and '${p_end_dt}'", s)
        self.assertNotIn("TO_DATE", s)

    def test_unknown_type_also_plain_string(self):
        """类型查不到时同样走裸字符串（用户规则：**只有**日期型才 TO_DATE）。"""
        table = _make_table(ods_table="ODS_X_PTD", load_strategy="INCR", incr_cond="L_DATE")
        s = generate_ods_etl(table, [_make_field(src_name="L_DATE", src_type="")],
                             "HSZTA", "${query_sql}")
        self.assertIn("between '${p_start_dt}' and '${p_end_dt}'", s)
        self.assertNotIn("TO_DATE", s)

    def test_full_table_has_no_where(self):
        table = _make_table(load_strategy="FULL", ods_table="ODS_X_PFD")
        s = generate_ods_etl(table, [_make_field(src_name="L_DATE", src_type="DATE")],
                             "HSZTA", "${query_sql}")
        self.assertNotIn("p_start_dt}','YYYY-MM-DD')", s)


class TestExtractIncrCol(unittest.TestCase):
    """_extract_incr_col / _build_p_dt_expr 的纯函数级断言（不经过模板渲染）。"""

    def setUp(self):
        from tools.generator.ods import (
            _extract_incr_col, _build_p_dt_expr, _incr_col_type,
            _incr_col_src_type, _build_where_pred, _query_col_expr,
        )
        self.extract = _extract_incr_col
        self.build = _build_p_dt_expr
        self.coltype = _incr_col_type
        self.srctype = _incr_col_src_type
        self.where = _build_where_pred
        self.qexpr = _query_col_expr

    def _f(self, name, ty="STRING", src=""):
        return [_make_field(src_name=name, hive_type=ty, src_type=src)]

    def test_bare_identifier(self):
        self.assertEqual(self.extract("L_DATE", self._f("L_DATE")), "L_DATE")

    def test_returns_original_case_from_fields(self):
        """列名以 fields 里的原文大小写返回（不是 incr_cond 里的写法）。"""
        self.assertEqual(self.extract("l_date", self._f("L_DATE")), "L_DATE")

    def test_prefixed(self):
        self.assertEqual(self.extract("T.D_CDATE", self._f("D_CDATE")), "D_CDATE")

    def test_multi_level_prefix(self):
        self.assertEqual(self.extract("A.B.L_DATE", self._f("L_DATE")), "L_DATE")

    def test_expression_returns_empty(self):
        self.assertEqual(self.extract("L_YEAR+L_MONTH", self._f("L_DATE")), "")

    def test_parenthesised_returns_empty(self):
        self.assertEqual(self.extract("TRUNC(D_DATE)", self._f("D_DATE")), "")

    def test_not_in_fields_returns_empty(self):
        self.assertEqual(self.extract("NOPE", self._f("L_DATE")), "")

    def test_empty_string(self):
        self.assertEqual(self.extract("", self._f("L_DATE")), "")

    # ---- P_DT ----
    def test_p_dt_number_cast(self):
        self.assertEqual(self.build("L_DATE", "NUMBER(8,0)", "DECIMAL(8,0)"),
                         "CAST(L_DATE AS STRING)")

    def test_p_dt_char_as_is(self):
        self.assertEqual(self.build("D_CDATE", "CHAR(8)", "STRING"), "D_CDATE")

    def test_p_dt_date_uses_replace(self):
        """★ 2026-10-09：DATE 型 P_DT = REPLACE(col,'-','')（防御式去横杠，两种落法都对）。"""
        self.assertEqual(self.build("D_DATE", "DATE", "STRING"), "REPLACE(D_DATE,'-','')")

    def test_p_dt_unknown_src_falls_back_to_hive_type(self):
        self.assertEqual(self.build("L_DATE", "", "DECIMAL(8,0)"), "CAST(L_DATE AS STRING)")
        self.assertEqual(self.build("D_CDATE", "", "STRING"), "D_CDATE")

    # ---- 类型识别 ----
    def test_src_type_lookup(self):
        self.assertEqual(self.srctype("L_DATE", self._f("L_DATE", "DECIMAL(8,0)", "NUMBER(8,0)")),
                         "NUMBER(8,0)")

    def test_src_type_unknown_returns_empty(self):
        self.assertEqual(self.srctype("NOPE", self._f("L_DATE")), "")

    # ---- WHERE ----
    def test_where_date(self):
        w = self.where("D_DATE", "DATE")
        self.assertIn("TO_DATE('${p_start_dt}','YYYYMMDD')", w)
        self.assertIn("TO_DATE('${p_end_dt}','YYYYMMDD')", w)

    def test_where_number(self):
        w = self.where("L_DATE", "NUMBER(10,0)")
        self.assertEqual(w, "L_DATE between '${p_start_dt}' and '${p_end_dt}'")

    def test_where_char(self):
        w = self.where("D_CDATE", "CHAR(8)")
        self.assertEqual(w, "D_CDATE between '${p_start_dt}' and '${p_end_dt}'")

    def test_where_unknown(self):
        """只有日期型才 TO_DATE；类型未知也走裸字符串。"""
        self.assertEqual(self.where("X", ""), "X between '${p_start_dt}' and '${p_end_dt}'")

    # ---- querySql 列表达式 ----
    def test_qexpr_date_wrapped(self):
        self.assertEqual(self.qexpr("D_DATE", "DATE"), "TO_CHAR(D_DATE,'YYYYMMDD') D_DATE")

    def test_qexpr_number_bare(self):
        self.assertEqual(self.qexpr("L_DATE", "NUMBER(8,0)"), "L_DATE")

    def test_qexpr_reserved_word_quoted_inside_to_char(self):
        """★ 保留字加引号必须加在 TO_CHAR 里面，否则整串变成带引号标识符。"""
        self.assertEqual(self.qexpr("LEVEL", "DATE"), "TO_CHAR(\"LEVEL\",'YYYYMMDD') LEVEL")

    def test_qexpr_reserved_word_number(self):
        self.assertEqual(self.qexpr("LEVEL", "NUMBER(8,0)"), '"LEVEL"')

    def test_coltype_lookup(self):
        self.assertEqual(self.coltype("L_DATE", self._f("L_DATE", "DECIMAL(8,0)")), "DECIMAL(8,0)")

    def test_coltype_unknown_defaults_string(self):
        self.assertEqual(self.coltype("NOPE", self._f("L_DATE")), "STRING")


class TestDataXLandingPath(unittest.TestCase):
    """★ 回归：DataX 落地区变量必须带【系统前缀】（"抽数假成功"根因 + 命名规范）。

    背景
    ----
    warehouse 已切到 HDFS 后，TMP 表（managed）落在
      /user/hive/warehouse/<sys小写>.db/<表名>_tmp
    DataX hdfswriter 的 path 必须指向**同一目录**，否则 `INSERT ... SELECT FROM TMP`
    读 0 行 ⇒ 脚本 exit 0 却报"成功"、目标表 0 行。

    正确方案：DataX path 用 `${<sys>_path}/${tmp_table_name}`，与 TMP 表目录**对齐**，
    且变量名带系统前缀（hsfa_path / hsds_path …）。
    ★ 注意：`path` 写在**模板**里，不在生成器里 —— 故真正的断言在
      TestEtlTemplateConsistency。本类只锁"生成器不注入 EXTERNAL 等旧方案残留"。
    """

    def test_generator_does_not_inject_external(self):
        """生成器不得自行注入 EXTERNAL TABLE / LOCATION（那是旧方案）。"""
        table = _make_table()
        script = generate_ods_etl(table, [_make_field()], "O32", "${tmp_field_defs}")
        self.assertNotIn("EXTERNAL TABLE", script)
        self.assertNotIn("LOCATION", script)
        self.assertNotIn("dfs -rm", script)


class TestSystemScopedVariables(unittest.TestCase):
    """★ 2026-09-30 回归：源库连接 / 落地区变量名必须带【系统前缀】。

    模板里写通用占位符 ${sys_username}/${sys_password}/${sys_jdbc}/${sys_path}，
    生成器按系统替换成系统专属名字：
      HSFA → ${hsfa_username} / ${hsfa_password} / ${hsfa_jdbc} / ${hsfa_path}
      HSDS → ${hsds_username} …
    与 FROM ${<sys>_src_schema}.<表> 的命名规则保持一致。
    ★ 旧的通用名 ${o32_*} / ${dw_path} 不得再出现在产物里。
    """

    TEMPLATE = '"${sys_username}" "${sys_password}" "${sys_jdbc}" "${sys_path}"'

    def test_hsfa_prefix(self):
        """HSFA → ${hsfa_username}/${hsfa_password}/${hsfa_jdbc}/${hsfa_path}。"""
        script = generate_ods_etl(_make_table(), [_make_field()], "HSFA", self.TEMPLATE)
        self.assertIn('"${hsfa_username}"', script)
        self.assertIn('"${hsfa_password}"', script)
        self.assertIn('"${hsfa_jdbc}"', script)
        self.assertIn('"${hsfa_path}"', script)

    def test_hsds_prefix(self):
        """换一个系统（HSDS）也必须按自己的前缀生成。"""
        script = generate_ods_etl(_make_table(), [_make_field()], "HSDS", self.TEMPLATE)
        self.assertIn('"${hsds_username}"', script)
        self.assertIn('"${hsds_path}"', script)

    def test_no_legacy_generic_names(self):
        """产物里不得残留通用占位符，也不得回退到旧 o32_/dw_path 名字。"""
        script = generate_ods_etl(_make_table(), [_make_field()], "HSFA", self.TEMPLATE)
        self.assertNotIn("${sys_", script)
        self.assertNotIn("${dw_path}", script)
        self.assertNotIn("o32_", script)


class TestEtlTemplateConsistency(unittest.TestCase):
    """★ 回归：真实 ETL 模板必须与 <sys>_path 方案一致（防回退）。

    ★ 断言只扫【非注释行】—— 模板头部有大段说明性注释，里面会引用
      `dfs -rm`、`o32_path` 等字样作为"历史/反面"说明，扫全文会误报。
    """

    def _load_template_code(self):
        """读模板并**剔除注释行**（行首可含空白 + #）。"""
        import os
        here = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        path = os.path.join(here, "demo", "templates", "etl_ods_template.sh")
        lines = []
        with open(path, "r", encoding="utf-8") as f:
            for ln in f:
                if ln.lstrip().startswith("#"):
                    continue
                lines.append(ln)
        return "".join(lines)

    def test_template_uses_sys_path(self):
        """模板代码里 DataX path 用通用占位符 ${sys_path}（生成器再按系统改名）。"""
        code = self._load_template_code()
        self.assertIn('"path": "${sys_path}/${tmp_table_name}"', code)
        self.assertNotIn('"path": "${o32_path}/', code)
        self.assertNotIn('"path": "${dw_path}/', code)

    def test_template_uses_sys_credentials(self):
        """模板里的源库凭据也必须用通用占位符，不带任何系统前缀。"""
        code = self._load_template_code()
        self.assertIn('"username": "${sys_username}"', code)
        self.assertIn('"password": "${sys_password}"', code)
        self.assertIn('"jdbcUrl": ["${sys_jdbc}"]', code)
        self.assertNotIn("${o32_username}", code)
        self.assertNotIn("${o32_password}", code)
        self.assertNotIn("${o32_jdbc}", code)

    def test_template_has_no_header_comment_block(self):
        """脚本头部的大段说明性注释块已删除（只留 shebang 与 #初始化环境变量）。"""
        import os
        here = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        path = os.path.join(here, "demo", "templates", "etl_ods_template.sh")
        with open(path, "r", encoding="utf-8") as f:
            raw = f.read()
        self.assertNotIn("最终方案", raw)
        self.assertNotIn("2026-09-29", raw)
        comment_lines = [l for l in raw.splitlines() if l.lstrip().startswith("#")]
        self.assertLessEqual(len(comment_lines), 2, f"仍有多余注释行: {comment_lines}")

    def test_template_has_no_external_location(self):
        """模板代码不得回退到 EXTERNAL + LOCATION 的旧方案。"""
        code = self._load_template_code()
        self.assertNotIn("CREATE EXTERNAL TABLE", code)
        self.assertNotIn("LOCATION '${defaultFS}", code)
        self.assertNotIn("dfs -rm", code)
        self.assertNotIn("TMP_CNT", code)

    def test_template_write_mode_append(self):
        """writeMode 必须是 append（managed 表每次 DROP 重建，无需 truncate）。"""
        code = self._load_template_code()
        self.assertIn('"writeMode": "append"', code)

    def test_template_tmp_is_managed_table(self):
        """TMP 表必须是普通 CREATE TABLE（managed），Hive 才会自动建目录。"""
        code = self._load_template_code()
        self.assertIn("CREATE TABLE ${target_schema}.${tmp_table}(", code)


class TestDerivedColAndTypeWhitelist(unittest.TestCase):
    """A-01 派生列 + J-01 Hive 类型白名单兜底（2026-10-09）。"""

    # ---- A-01：派生列 ----
    def test_d_make_num_is_derived_not_bare_column(self):
        """A-01 实况：HSFA.TVOUCHERS 源表 36 列里没有 D_MAKE_NUM，
        直接当列名引用必然 ORA-00904 ⇒ 必须出表达式，且保留别名
        （DataX writer 的 column[].name 按列名匹配，丢别名会对不上）。"""
        from tools.generator.ods import _query_col_expr
        self.assertEqual(_query_col_expr("D_MAKE_NUM", ""),
                         "TO_NUMBER(TO_CHAR(D_MAKE,'YYYYMMDD')) D_MAKE_NUM")

    def test_d_make_num_lookup_is_case_insensitive(self):
        from tools.generator.ods import _query_col_expr
        self.assertIn("TO_CHAR(D_MAKE", _query_col_expr("d_make_num", ""))

    def test_regular_columns_untouched_by_derived_map(self):
        """派生列映射不能误伤普通列与保留字列。"""
        from tools.generator.ods import _query_col_expr
        self.assertEqual(_query_col_expr("VC_CODE", ""), "VC_CODE")
        self.assertEqual(_query_col_expr("LEVEL", ""), '"LEVEL"')

    def test_derived_map_covers_only_declared_columns(self):
        """★ 未声明的列不能被当成派生列（否则会静默改掉取数语义）。"""
        from tools.generator.ods import _DERIVED_COLS, _query_col_expr
        self.assertIn("D_MAKE_NUM", _DERIVED_COLS)
        self.assertEqual(_query_col_expr("D_MAKE", ""), "D_MAKE")

    # ---- J-01：Hive 类型白名单 ----
    def test_hive_type_whitelist_accepts_common_types(self):
        from tools.generator.ods import _safe_hive_type
        for t in ("STRING", "DECIMAL(16,2)", "varchar(20)", "TIMESTAMP",
                  "TIMESTAMP WITH LOCAL TIME ZONE", "BIGINT", "CHAR(1)",
                  "DOUBLE", "BOOLEAN", "DATE", "ARRAY<STRING>"):
            self.assertEqual(_safe_hive_type(t, "C_X", "test"), t,
                             "合法类型被误判: %r" % t)

    def test_hive_type_empty_degrades_to_string(self):
        from tools.generator.ods import _safe_hive_type
        self.assertEqual(_safe_hive_type("", "C_X", "test"), "STRING")
        self.assertEqual(_safe_hive_type(None, "C_X", "test"), "STRING")
        self.assertEqual(_safe_hive_type("   ", "C_X", "test"), "STRING")

    def test_hive_type_junk_degrades_to_string_without_raising(self):
        """J-01 实况：「转换后字段类型」被填成**别的字段名**/SQL 表达式。
        必须降级成 STRING 且**不抛异常** —— 抛了会让整批 DDL 生成中断，
        比生成一个能执行的 STRING 列糟糕得多。"""
        from tools.generator.ods import _safe_hive_type
        junk = ("C_CSERIALNO", "D_REGDATE", "T.D_CDATE",
                "CASE WHEN NVL(T.C_BUSINFLAG,'')='' THEN '--' END", "T'",
                "F_REALSHARES")
        for j in junk:
            self.assertEqual(_safe_hive_type(j, "C_X", "test"), "STRING",
                             "坏值未被拦下: %r" % j)

    def test_hive_type_bare_and_malformed_rejected(self):
        """裸类型名/括号不全也要拦（Hive 解析器同样不认）。"""
        from tools.generator.ods import _safe_hive_type
        for j in ("VARCHAR2(20)", "NUMBER(16,2)", "CHAR", "DECIMAL(", "abc"):
            self.assertEqual(_safe_hive_type(j, "C_X", "test"), "STRING",
                             "应被拦下: %r" % j)


if __name__ == "__main__":
    unittest.main()
