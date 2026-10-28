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
        field = "C1  STRING COMMENT 'O''Hara'"
        sql = generate_ddl_body("DWDXDAY", "T1", [field], "表注释")
        self.assertIn("COMMENT 'O''Hara'", sql)
        # 不应出现未转义的单引号破坏 COMMENT 结构
        self.assertNotIn("COMMENT 'O'Hara'", sql)


class TestBuildFieldDefsNoDefaultNull(unittest.TestCase):
    """★ 2026-09-28 回归：build_field_defs 不能产出 `DEFAULT NULL`。

    Hive 4.2 对 `DEFAULT NULL` 报 Error 10326（Invalid type: void for default
    value: NULL），建表直接失败。本用例锁死该行为，防止回归。
    """

    def test_no_default_null_in_business_fields(self):
        from tools.generator.ddl_common import build_field_defs
        defs = build_field_defs([("C1", "STRING", "列一"), ("N1", "DECIMAL(10,2)", "列二")])
        joined = "\n".join(defs)
        self.assertNotIn("DEFAULT", joined)
        self.assertIn("C1  STRING COMMENT '列一'", joined)

    def test_no_default_null_in_sys_fields(self):
        from tools.generator.ddl_common import build_field_defs
        defs = build_field_defs(
            [("C1", "STRING", "列一")],
            sys_fields=[("LD_TIME", "STRING", "加载时间")],
        )
        joined = "\n".join(defs)
        self.assertNotIn("DEFAULT", joined)
        self.assertIn("LD_TIME  STRING COMMENT '加载时间'", joined)


class TestHiveReservedWordQuoting(unittest.TestCase):
    """★ 2026-10-09（J-02）回归：Hive 保留字列名必须加**反引号**。

    裸写会让 `CREATE TABLE` 直接 ParseException：
        line 1:36 cannot recognize input near 'TIMESTAMP' 'STRING' ','
    实测（Hive 4.2.0，文件 `.dx-tmp/probe-words.sql` / `probe-bq.sql`）：
        EXCHANGE / TIME / TIMESTAMP  → 裸写必炸
        LEVEL / TYPE                 → 裸写能建（它们是 **Oracle** 保留字）
    本用例锁死「该加的加、不该加的不加」，防止清单被掺水或漏掉。
    """

    def test_reserved_word_gets_backtick(self):
        from tools.generator.ddl_common import build_field_defs
        for word in ("TIMESTAMP", "TIME", "EXCHANGE", "DATE", "USER", "YEAR"):
            defs = build_field_defs([(word, "STRING", "某列")])
            self.assertIn("`%s`  STRING COMMENT '某列'" % word, defs,
                          "%s 未加反引号，Hive 会 ParseException" % word)

    def test_oracle_only_word_kept_bare(self):
        """LEVEL / TYPE 是 Oracle 保留字（走双引号），**不是** Hive 的 ⇒ 保持裸名。"""
        from tools.generator.ddl_common import build_field_defs
        for word in ("LEVEL", "TYPE"):
            defs = build_field_defs([(word, "STRING", "某列")])
            self.assertIn("%s  STRING COMMENT '某列'" % word, defs)
            self.assertNotIn("`%s`" % word, defs[0])

    def test_ordinary_column_untouched(self):
        from tools.generator.ddl_common import build_field_defs
        defs = build_field_defs([("CUST_NO", "STRING", "客户号")])
        self.assertEqual(defs, ["CUST_NO  STRING COMMENT '客户号'"])

    def test_case_insensitive_match(self):
        """源库列名可能大小写混写，保留字判定必须 case-insensitive。"""
        from tools.generator.ddl_common import quote_hive_column
        self.assertEqual(quote_hive_column("timestamp"), "`timestamp`")
        self.assertEqual(quote_hive_column("Timestamp"), "`Timestamp`")
        self.assertEqual(quote_hive_column("EXCHANGE"), "`EXCHANGE`")


class TestNormalizeHiveType(unittest.TestCase):
    """★ 2026-10-12（J-05）回归：Oracle 裸类型必须归一成 Hive 类型。

    甲方 MAPPING 的「目标字段类型」直填了 Oracle 类型（NUMBER(30,8)×171、
    NUMBER(30,15)×20、NUMBER(30,16)×3、char×2、VARCHAR2(64)×1，19 张表 197 列），
    原样拼进 DDL ⇒ Hive 4.2.0 实测 ParseException cannot recognize input near
    'NUMBER' '(' '30' in column type，19 张表建不出来。
    本用例锁死：Oracle 类型→Hive 映射；**已是 Hive 合法类型的原样保留**
    （DECIMAL(18,2) 过 oracle_to_hive 会退化成 STRING，属破坏）。
    """

    def test_oracle_types_mapped(self):
        from tools.generator.ddl_common import normalize_hive_type
        self.assertEqual(normalize_hive_type("NUMBER(30,8)"), "DECIMAL(30,8)")
        self.assertEqual(normalize_hive_type("NUMBER(30,15)"), "DECIMAL(30,15)")
        self.assertEqual(normalize_hive_type("NUMBER(30,16)"), "DECIMAL(30,16)")
        self.assertEqual(normalize_hive_type("NUMBER(10,0)"), "DECIMAL(10,0)")
        self.assertEqual(normalize_hive_type("char"), "STRING")
        self.assertEqual(normalize_hive_type("VARCHAR2(64)"), "STRING")
        self.assertEqual(normalize_hive_type("CLOB"), "STRING")
        self.assertEqual(normalize_hive_type(""), "STRING")

    def test_hive_types_untouched(self):
        """已是 Hive 合法类型的一律原样返回，防止退化。"""
        from tools.generator.ddl_common import normalize_hive_type
        for t in ("STRING", "DECIMAL(18,2)", "DECIMAL(30,8)", "BIGINT",
                  "TIMESTAMP", "DATE", "CHAR(10)", "VARCHAR(32)"):
            self.assertEqual(normalize_hive_type(t), t, "%s 被意外改写" % t)

    def test_build_field_defs_end_to_end(self):
        from tools.generator.ddl_common import build_field_defs
        defs = build_field_defs([("AMT", "NUMBER(30,8)", "金额"),
                                 ("SSYS", "char", "源系统")])
        joined = "\n".join(defs)
        self.assertIn("AMT  DECIMAL(30,8) COMMENT '金额'", joined)
        self.assertIn("SSYS  STRING COMMENT '源系统'", joined)
        self.assertNotIn("NUMBER", joined)
        self.assertNotIn("char", joined)

    def test_empty_and_none_safe(self):
        from tools.generator.ddl_common import quote_hive_column
        self.assertEqual(quote_hive_column(""), "")
        self.assertEqual(quote_hive_column(None), None)

    def test_sys_field_also_quoted(self):
        """系统字段同样可能被撞名，比如某系统自定义 DATE 系统列。"""
        from tools.generator.ddl_common import build_field_defs
        defs = build_field_defs([("C1", "STRING", "列一")],
                                sys_fields=[("DATE", "STRING", "日期")])
        self.assertIn("`DATE`  STRING COMMENT '日期'", defs)


class TestHiveColumnShellEscape(unittest.TestCase):
    """★ 2026-10-09（J-04）回归：写进 `.sh` 的反引号必须多转义一层。

    ETL 是 sh 脚本，SQL 以双引号传给 `beeline -e "$1"`。**双引号内的反引号 =
    命令替换** ⇒ 裸写 `` `TIMESTAMP` `` 会被真的拿去执行，任务日志里留下
        line 11: TIMESTAMP: command not found
    列名直接蒸发 ⇒ _TMP 建不出来 ⇒ DataX 报 path does not exist。
    """

    def test_sh_variant_escapes_backtick(self):
        from tools.generator.ddl_common import quote_hive_column_sh
        self.assertEqual(quote_hive_column_sh("TIMESTAMP"), "\\`TIMESTAMP\\`")
        self.assertEqual(quote_hive_column_sh("TIME"), "\\`TIME\\`")
        self.assertEqual(quote_hive_column_sh("EXCHANGE"), "\\`EXCHANGE\\`")

    def test_sh_variant_leaves_normal_name(self):
        from tools.generator.ddl_common import quote_hive_column_sh
        self.assertEqual(quote_hive_column_sh("CUST_NO"), "CUST_NO")
        self.assertEqual(quote_hive_column_sh("LEVEL"), "LEVEL")   # 非 Hive 保留字

    def test_sql_variant_stays_bare_backtick(self):
        """.sql 文件经 beeline -f 读取、不经 shell ⇒ 保持裸反引号。"""
        from tools.generator.ddl_common import quote_hive_column
        self.assertEqual(quote_hive_column("TIMESTAMP"), "`TIMESTAMP`")
        self.assertNotIn("\\\\", quote_hive_column("TIMESTAMP"))

    def test_sh_escaped_survives_shell(self):
        """端到端：转义后的串经 sh 还原，应当回到裸反引号。"""
        import subprocess
        from tools.generator.ddl_common import quote_hive_column_sh
        body = "  %s  STRING COMMENT ''," % quote_hive_column_sh("TIMESTAMP")
        # 在 sh 里用双引号 echo 出来（模拟 inceptor_beeline "$1" 的传参方式）
        script = 'printf "%%s\\n" "%s"' % body.replace('"', '\\"')
        out = subprocess.run(["sh", "-c", script], capture_output=True,
                             text=True, errors="replace").stdout
        self.assertIn("`TIMESTAMP`  STRING", out)
        self.assertNotIn("command not found", out)


if __name__ == "__main__":
    unittest.main()
