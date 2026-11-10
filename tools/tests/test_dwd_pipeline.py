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


class TestDwdDdlSelfCheck(unittest.TestCase):
    """A8 回归：DWD DDL 落盘自检（结构比对 + 语句边界 + 差异报告）。

    ★ 背景：DWS 侧早有 `verify_ddl_after_write` + `ddl-drift-*.md`，DWD 侧
      原先没有 ⇒ `ddl --apply` 写坏文件只能等上 beeline 才发现。
    """

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self._saved = (DP.REPO, DP.SCRIPTS)
        DP.REPO = self.root
        DP.SCRIPTS = self.root / 'scripts'
        self.addCleanup(self._restore)

    def _restore(self):
        DP.REPO, DP.SCRIPTS = self._saved

    def _local(self, sysname, table, body):
        d = DP.SCRIPTS / sysname / 'dwd' / 'ddl'
        d.mkdir(parents=True, exist_ok=True)
        (d / f'{table}.sql').write_text(body, encoding='utf-8')

    def test_column_drift_detected(self):
        self._local('O32', 'DWD_T_PFD',
                    "CREATE TABLE DWDXDAY.DWD_T_PFD (A STRING, C STRING)\n")
        bad = DP.verify_ddl_after_write(
            {'DWD_T_PFD': ('O32', 'x')},
            {'DWD_T_PFD': "CREATE TABLE DWDXDAY.DWD_T_PFD (A STRING, B STRING)"})
        self.assertEqual(len(bad), 1)
        self.assertEqual(bad[0]['diff'].only_in_left, ['B'])
        self.assertEqual(bad[0]['diff'].only_in_right, ['C'])

    def test_clean_ddl_passes(self):
        body = ("CREATE TABLE DWDXDAY.DWD_T_PFD (A STRING)\n"
                "PARTITIONED BY ( P_DT STRING)\n;\n")
        self._local('O32', 'DWD_T_PFD', body)
        self.assertEqual(
            DP.verify_ddl_after_write({'DWD_T_PFD': ('O32', 'x')},
                                      {'DWD_T_PFD': body.rstrip(';\n')}),
            [])

    def test_missing_local_file_reported(self):
        bad = DP.verify_ddl_after_write(
            {'DWD_NOPE_PFD': ('O32', 'x')},
            {'DWD_NOPE_PFD': 'CREATE TABLE DWDXDAY.DWD_NOPE_PFD (A STRING)'})
        self.assertEqual(bad[0]['probs'], ['本地文件不存在'])

    def test_report_writes_only_in_columns(self):
        dv = DP._load_ddl_verify()
        diff = dv.diff_ddl("CREATE TABLE DWDXDAY.T (A STRING, B STRING)",
                           "CREATE TABLE DWDXDAY.T (A STRING, C STRING)",
                           '甲方', '本地')
        DP._report_dwd_ddl_drift([{'table': 'T', 'sysname': 'O32',
                                   'diff': diff, 'probs': []}])
        reports = list((self.root / 'tools/.dx-tmp').glob('ddl-drift-dwd-*.md'))
        self.assertEqual(len(reports), 1)
        text = reports[0].read_text(encoding='utf-8')
        self.assertIn('仅甲方有列: B', text)
        self.assertIn('仅本地有列: C', text)


class TestPathPatchPropagation(unittest.TestCase):
    """★ 2026-11-10（评审 H1）：改 facade 的 REPO/SCRIPTS 必须对**所有**子模块生效。

    原先 parsing / generation / ddl_check 各持一份 `globals().update(vars(ns))`
    **拷贝**出来的 `SCRIPTS`；把 facade 的指向临目录后，它们仍读写真实仓库
    （实测 `parsing._script_index()` 扫的是仓库）。现在一律走 `_ns.SCRIPTS`。
    """

    SUBMODULES = ('parsing', 'generation', 'ddl_check', 'cli')

    def test_patch_reaches_every_submodule(self):
        from tools.dwd import cli, ddl_check, generation, parsing
        mods = {'parsing': parsing, 'generation': generation,
                'ddl_check': ddl_check, 'cli': cli}
        sentinel = Path(tempfile.gettempdir()) / 'dw-h1-probe-scripts'
        saved = DP.SCRIPTS
        self.addCleanup(setattr, DP, 'SCRIPTS', saved)
        DP.SCRIPTS = sentinel
        for name in self.SUBMODULES:
            with self.subTest(module=name):
                self.assertNotIn('SCRIPTS', vars(mods[name]),
                                 '子模块不得自带 SCRIPTS 快照')
                self.assertEqual(mods[name].etl_dir('HSFA'),
                                 sentinel / 'HSFA' / 'dwd' / '02_etl')
        self.assertNotIn('SCRIPTS', parsing._script_index.__globals__)
        self.assertNotIn('REPO', parsing._script_index.__globals__)


if __name__ == '__main__':
    unittest.main()
