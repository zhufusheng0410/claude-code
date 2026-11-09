# -*- coding: utf-8 -*-
"""tools/dwd-pipeline.py 纯函数回归测试（不触碰 /mnt/d 与 DS）。"""
import contextlib
import importlib.util
import io
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('dwd_pipeline', ROOT / 'tools/dwd-pipeline.py')
DP = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DP)


class TestConvert(unittest.TestCase):
    RAW = (
        '#!/bin/sh\n'
        'source ${hadoop_env}\n'
        'inceptor_beeline()\n'
        '{\n'
        '    beeline -u ${hive_jdbc} -e "$1"\n'
        '}\n'
        '-- **\n'
        '-- ** 描述:测试\n'
        'inceptor_beeline "SELECT 1"\n'
        'set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;\n'
        'set mapreduce.job.queuename=root.default;\n'
        'INSERT INTO DWDXDAY.T\n'
        "SELECT DATE_FORMAT(SYSDATE,'yyyyMMdd','yyyy-MM-dd') AS DATE\n"
        'FROM (SELECT 1 AS X) ;\n'
    )

    def test_convert_rules(self):
        stats = DP.new_stats()
        out = DP.convert(self.RAW, stats, 'T')
        self.assertIn('source /home/dolphinscheduler/hadoop_env', out)
        self.assertNotIn('${source_path}', out)
        self.assertIn('set hive.strict.checks.type.safety=false;', out)
        self.assertNotIn('CombineHiveInputFormat', out)
        self.assertIn("DATE_FORMAT(DATE_FORMAT(CURRENT_DATE,'yyyyMMdd'),'yyyyMMdd')", out)
        self.assertIn('AS \\`DATE\\`', out)
        self.assertIn('(SELECT 1 AS X) SUBT1', out)
        self.assertTrue(out.endswith('\n'))
        self.assertEqual(stats['safety'], 1)
        self.assertEqual(stats['sets_dropped'], 1)
        self.assertEqual(stats['date_format3'], 1)
        self.assertEqual(stats['sysdate'], 1)
        self.assertEqual(stats['as_date'], 1)
        self.assertEqual(stats['subt1'], 1)

    def test_convert_idempotent(self):
        once = DP.convert(self.RAW, None, 'T')
        twice = DP.convert(once, None, 'T')
        self.assertEqual(once, twice)

    def test_date_format_nested(self):
        src = "DATE_FORMAT(NVL(DATE_FORMAT(T.D,'yyyyMMdd','yyyy-MM-dd'),'x'),'yyyyMMdd','yyyy-MM-dd')"
        out, n = DP.fix_date_format3(src)
        self.assertEqual(n, 2)
        self.assertNotIn("'yyyy-MM-dd')", out)


class TestAliasAndDdl(unittest.TestCase):
    def test_alias_added_once(self):
        sql = 'SELECT * FROM (SELECT 1) SUBT1'
        out, n = DP.add_subquery_alias(sql)
        self.assertEqual(n, 0)
        self.assertEqual(out, sql)
        out, n = DP.add_subquery_alias('SELECT * FROM (SELECT 1) ;')
        self.assertEqual(n, 1)
        self.assertTrue(out.endswith('(SELECT 1) SUBT1 ;'))

    def test_sanitize_ddl(self):
        body = ('CREATE TABLE T (\n  ID NUMBER,\n  DATE STRING,\n'
                '  NAME VARCHAR2(32 BYTE) DEFAULT NULL\n)')
        out = DP.sanitize_ddl(body)
        self.assertIn('`DATE` STRING', out)
        self.assertIn('NAME STRING', out)
        self.assertNotIn('VARCHAR2', out)
        self.assertNotIn('DEFAULT NULL', out)


class TestAssign(unittest.TestCase):
    DATA = {'assign': {'A': 'O32'}, 'none': ['B'],
            'amb': {'C': ['O32', 'HSFA']}}

    def test_defaults(self):
        with contextlib.redirect_stdout(io.StringIO()):
            got = DP.resolved_assign(self.DATA)
        self.assertEqual(got, {'A': 'O32', 'B': 'HSFA'})

    def test_force_sys(self):
        got = DP.resolved_assign(self.DATA, 'HSFA')
        self.assertEqual(got['C'], 'HSFA')

    def test_helpers(self):
        self.assertEqual(DP.norm_table('DWDXDAY.DWD_AST_X_PFD'), 'DWD_AST_X_PFD')
        self.assertEqual(DP._own_workflow('DWD_AST_X_PFD'), 'DWD_AST')


class TestParseScriptInput(unittest.TestCase):
    """`_parse_script` 必须同时接受**文本**与 **PathLike**（评审 C1 回归）。

    ★ 背景：2026-11-09 把签名从「Path」收成「文本」（省一次重复读盘），
      但 `dws-dep-report.py` 是按路径加载本模块后**跨文件调用**，仍传 Path
      ⇒ 实测 `TypeError: expected string or bytes-like object, got 'PosixPath'`，
      该命令 100% 崩溃。入口保留 PathLike 兼容才安全。
    """

    SQL = (
        "INSERT INTO DWDXDAY.DWD_AST_X_PFD\n"
        "SELECT * FROM ODS_XDAY_O32.ODS_O32_TUNITSTOCK_PFD\n"
    )

    def test_accepts_text(self):
        real, srcs = DP._parse_script(self.SQL)
        self.assertEqual(real, ['DWD_AST_X_PFD'])
        self.assertEqual(srcs, ['ODS_O32_TUNITSTOCK_PFD'])

    def test_pathlike_equals_text(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / 'x.sh'
            p.write_text(self.SQL, encoding='utf-8')
            self.assertEqual(DP._parse_script(p), DP._parse_script(self.SQL))

    def test_str_path_is_not_mistaken_for_sql(self):
        """传 `str` 路径是**不支持**的（会当文本解析、静默得到空结果）。

        这里把现状固化成断言，避免有人误以为两种 str 都行；真要支持得显式判断
        `os.path.isfile`，但会与「脚本文本恰好等于某路径」产生歧义，故意不做。
        """
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / 'x.sh'
            p.write_text(self.SQL, encoding='utf-8')
            self.assertEqual(DP._parse_script(str(p)), ([], []))


if __name__ == '__main__':
    unittest.main()
