# -*- coding: utf-8 -*-
"""tools/dwd-pipeline.py 纯函数回归测试（不触碰 /mnt/d 与 DS）。"""
import collections
import contextlib
import importlib.util
import io
import os
import tempfile
import types
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

    def test_derived_paths_follow_patch(self):
        """★ 复审：MASTER/OWNER_JSON/DEPCFG_OUT/PREVDAY_OUT 必须现算。

        这些名字若在 import 时算成常量，改 SCRIPTS/REPO 后仍指向真实仓库。
        """
        from tools.dwd import ns
        for name in ('MASTER', 'OWNER_JSON', 'DEPCFG_OUT', 'PREVDAY_OUT'):
            with self.subTest(name=name):
                self.assertNotIn(name, vars(ns), '派生路径不得固化在模块字典里')
        saved = (DP.REPO, DP.SCRIPTS)
        self.addCleanup(lambda: (setattr(DP, 'REPO', saved[0]),
                                 setattr(DP, 'SCRIPTS', saved[1])))
        DP.REPO = Path('/tmp/dw-probe-repo')
        DP.SCRIPTS = Path('/tmp/dw-probe-scripts')
        self.assertEqual(ns.MASTER, Path('/tmp/dw-probe-scripts/MASTER/dwd/02_etl'))
        self.assertEqual(ns.OWNER_JSON,
                         Path('/tmp/dw-probe-repo/tools/.dx-tmp/dwd_owner_map.json'))
        self.assertEqual(ns.DEPCFG_OUT,
                         Path('/tmp/dw-probe-repo/tools/ds-deploy/dep-config-proscript'))
        self.assertEqual(ns.PREVDAY_OUT,
                         Path('/tmp/dw-probe-repo/tools/_prev_day_deps.json'))


def _mapping_xlsx(path):
    from openpyxl import Workbook
    wb = Workbook()
    ws = wb.active
    ws['A1'] = '目标表英文名称'
    ws['C1'] = 'DWD_AST_CRSE_INFO_PFD'
    ws['A2'] = '实体英文名称'
    ws['A3'] = 'DWD_CMM_FOO_PFD'
    path.parent.mkdir(parents=True, exist_ok=True)
    wb.save(path)
    wb.close()


def _scan_both(parsing, path):
    fast = collections.defaultdict(list)
    slow = collections.defaultdict(list)
    saved = os.environ.get('DW_NO_CALAMINE')
    try:
        os.environ.pop('DW_NO_CALAMINE', None)
        parsing._scan_mapping_xlsx(path, fast)
        os.environ['DW_NO_CALAMINE'] = '1'
        parsing._scan_mapping_xlsx(path, slow)
    finally:
        if saved is None:
            os.environ.pop('DW_NO_CALAMINE', None)
        else:
            os.environ['DW_NO_CALAMINE'] = saved
    return fast, slow


def _patch_scan(parsing, calls):
    real = parsing._scan_mapping_xlsx

    def wrapped(p, out):
        calls.append(p.name)
        return real(p, out)

    parsing._scan_mapping_xlsx = wrapped
    return real


class TestMappingScan(unittest.TestCase):
    """空单元格不能截断表名查找。calamine 与 openpyxl 回退必须看到同一张表。"""

    def test_blank_between_label_and_name(self):
        from tools.dwd import parsing
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / 'a.xlsx'
            _mapping_xlsx(path)
            out_fast, out_slow = _scan_both(parsing, path)
        self.assertEqual({k: sorted(v) for k, v in out_fast.items()},
                         {k: sorted(v) for k, v in out_slow.items()})
        self.assertIn('DWD_AST_CRSE_INFO_PFD', out_fast)
        self.assertIn('DWD_CMM_FOO_PFD', out_fast)

    def test_na_placeholder_stops_both_engines(self):
        from tools.utils.excel_reader import CalamineWorkbook
        from openpyxl import Workbook
        if CalamineWorkbook is None:
            self.skipTest('python-calamine 未安装')
        from tools.dwd import parsing
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / 'na.xlsx'
            wb = Workbook()
            ws = wb.active
            ws['A1'] = '目标表英文名称'
            ws['B1'] = 'NULL'
            ws['C1'] = 'DWD_OTHER_SRC_PFD'
            wb.save(path)
            wb.close()
            out_fast, out_slow = _scan_both(parsing, path)
        self.assertEqual(list(out_fast), [])
        self.assertEqual(list(out_slow), [])

    def test_nan_does_not_hide_table_name(self):
        from tools.dwd import parsing
        out = collections.defaultdict(list)
        parsing._consume_mapping_rows(
            [('目标表英文名称', float('nan'), 'DWD_AST_CRSE_INFO_PFD')],
            'a.xlsx', out)
        self.assertEqual(out['DWD_AST_CRSE_INFO_PFD'], ['a.xlsx'])


class TestOwnerCache(unittest.TestCase):
    """归属缓存不看 --apply，但指纹不符必须重扫。"""

    def setUp(self):
        from tools.dwd import ns, parsing
        self.parsing = parsing
        self.ns = ns
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.map_root = root / 'map'
        self.xlsx = self.map_root / '03-HSFA' / 'a.xlsx'
        _mapping_xlsx(self.xlsx)
        jf = root / 'jf'
        jf.mkdir()
        (jf / 'DWD_AST_CRSE_INFO_PFD.txt').write_text('x', encoding='utf-8')
        (jf / 'DWD_CMM_FOO_PFD.txt').write_text('x', encoding='utf-8')
        self.saved = (parsing.MAP_ROOT, parsing.JF, ns.REPO, ns.SCRIPTS,
                      parsing._OWNER_MEM)
        parsing.MAP_ROOT = self.map_root
        parsing.JF = jf
        ns.REPO = root / 'repo'
        ns.SCRIPTS = root / 'scripts'
        parsing._OWNER_MEM = None
        (ns.SCRIPTS / 'MASTER/dwd/02_etl').mkdir(parents=True)
        self.addCleanup(self._restore)

    def _restore(self):
        (self.parsing.MAP_ROOT, self.parsing.JF, self.ns.REPO, self.ns.SCRIPTS,
         self.parsing._OWNER_MEM) = self.saved

    def test_dry_run_writes_cache_and_hit_skips_scan(self):
        parsing = self.parsing
        calls = []
        real = _patch_scan(parsing, calls)
        self.addCleanup(setattr, parsing, '_scan_mapping_xlsx', real)
        with contextlib.redirect_stdout(io.StringIO()):
            data = parsing.load_owner()
        cache_path = self.ns.REPO / 'tools/.dx-tmp/dwd_owner_map.json'
        self.assertTrue(cache_path.is_file())
        self.assertEqual(str(parsing._ns.OWNER_JSON), str(cache_path))
        self.assertEqual(data['assign']['DWD_AST_CRSE_INFO_PFD'], 'HSFA')
        self.assertTrue(data['fingerprint'])
        self.assertEqual(data['version'], parsing.OWNER_CACHE_VERSION)
        n = len(calls)
        self.assertGreater(n, 0)
        with contextlib.redirect_stdout(io.StringIO()):
            again = parsing.load_owner()
        self.assertEqual(len(calls), n)
        self.assertEqual(again['assign'], data['assign'])

    def test_mapping_content_change_rescans(self):
        """内存命中不重扫；只有 force_rescan=True 才强制重扫并拾取新文件。"""
        parsing = self.parsing
        with contextlib.redirect_stdout(io.StringIO()):
            parsing.load_owner()
        calls = []
        real = _patch_scan(parsing, calls)
        self.addCleanup(setattr, parsing, '_scan_mapping_xlsx', real)
        _mapping_xlsx(self.map_root / '03-HSFA' / 'b.xlsx')
        with contextlib.redirect_stdout(io.StringIO()):
            parsing.load_owner()
        self.assertEqual(calls, [], '内存命中不得重新扫描')
        with contextlib.redirect_stdout(io.StringIO()):
            parsing.load_owner(force_rescan=True)
        self.assertEqual(sorted(calls), ['a.xlsx', 'b.xlsx'])

    def test_cache_without_fingerprint_is_stale(self):
        parsing = self.parsing
        path = self.ns.REPO / 'tools/.dx-tmp/dwd_owner_map.json'
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('{"assign": {}, "version": 1}', encoding='utf-8')
        with contextlib.redirect_stdout(io.StringIO()):
            data = parsing.load_owner()
        self.assertIn('DWD_AST_CRSE_INFO_PFD', data['assign'])
        self.assertIn('fingerprint', data)

    def test_new_jf_txt_after_cache_hit(self):
        parsing = self.parsing
        with contextlib.redirect_stdout(io.StringIO()):
            first = parsing.load_owner()
        self.assertEqual(set(first['stems']), {'DWD_AST_CRSE_INFO_PFD', 'DWD_CMM_FOO_PFD'})
        (parsing.JF / 'DWD_EVT_FOO_PFD.txt').write_text('x', encoding='utf-8')
        with contextlib.redirect_stdout(io.StringIO()):
            second = parsing.load_owner()
        self.assertIn('DWD_EVT_FOO_PFD', second['stems'])
        self.assertIn('DWD_EVT_FOO_PFD', second.get('none') or [])

    def test_failed_mapping_scan_is_not_cached(self):
        bad = self.map_root / '03-HSFA' / 'bad.xlsx'
        bad.write_bytes(b'not-a-zip')
        cache = self.ns.REPO / 'tools/.dx-tmp/dwd_owner_map.json'
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            self.parsing.load_owner()
        self.assertIn('! bad.xlsx:', buf.getvalue())
        self.assertFalse(cache.is_file())
        self.assertIsNone(self.parsing._OWNER_MEM)
        calls = []
        real = _patch_scan(self.parsing, calls)
        self.addCleanup(setattr, self.parsing, '_scan_mapping_xlsx', real)
        buf2 = io.StringIO()
        with contextlib.redirect_stdout(buf2):
            self.parsing.load_owner()
        self.assertEqual(sorted(calls), ['a.xlsx', 'bad.xlsx'])
        self.assertNotIn('归属缓存命中', buf2.getvalue())
        self.assertFalse(cache.is_file())

    def test_force_rescan_scans_once_for_cmd_all(self):
        import tools.dwd.cli as cli
        parsing = self.parsing
        calls = []
        real = _patch_scan(parsing, calls)
        self.addCleanup(setattr, parsing, '_scan_mapping_xlsx', real)
        saved = {}
        for name in ('cmd_convert', 'cmd_distribute', 'cmd_ddl', 'cmd_lineage',
                     'cmd_depcfg', 'cmd_verify'):
            saved[name] = getattr(cli, name)

            def _step(args, _name=name):
                if _name in ('cmd_convert', 'cmd_distribute', 'cmd_ddl', 'cmd_lineage'):
                    parsing.load_owner(force_rescan=getattr(args, 'force_rescan', False))
                return 0

            setattr(cli, name, _step)
            self.addCleanup(setattr, cli, name, saved[name])
        args = types.SimpleNamespace(apply=False, force_rescan=True, force_sys='')
        with contextlib.redirect_stdout(io.StringIO()):
            rc = cli.cmd_all(args)
        self.assertEqual(rc, 0)
        self.assertEqual(calls, ['a.xlsx'])

    def test_failed_forced_scan_stops_before_using_old_cache(self):
        from unittest.mock import patch
        from tools.dwd import cli

        self.parsing.load_owner()
        args = types.SimpleNamespace(apply=False, force_rescan=True, force_sys='')
        with patch.object(self.parsing, '_scan_mapping_xlsx', return_value=False), \
                patch.object(cli, 'cmd_convert', return_value=1) as convert:
            self.assertEqual(cli.cmd_all(args), 1)
            convert.assert_not_called()

    def test_concurrent_cache_writers_publish_complete_json(self):
        import json
        from concurrent.futures import ThreadPoolExecutor
        from threading import Barrier
        from unittest.mock import patch

        payloads = [{'owner': {name: ['HSFA']}} for name in ('A', 'B')]
        ready = Barrier(2)
        replace = self.parsing.os.replace

        def replace_together(src, dst):
            ready.wait(timeout=10)
            return replace(src, dst)

        with patch.object(self.parsing.os, 'replace', replace_together), ThreadPoolExecutor(2) as pool:
            list(pool.map(self.parsing._write_owner_cache, payloads))
        self.assertIn(json.loads(self.ns.OWNER_JSON.read_text(encoding='utf-8')), payloads)
        self.assertEqual(list(self.ns.OWNER_JSON.parent.iterdir()), [self.ns.OWNER_JSON])

    def test_cache_hit_owner_prints_summary(self):
        parsing = self.parsing
        with contextlib.redirect_stdout(io.StringIO()):
            parsing.load_owner()
        parsing._OWNER_MEM = None
        calls = []
        real = _patch_scan(parsing, calls)
        self.addCleanup(setattr, parsing, '_scan_mapping_xlsx', real)
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = parsing.cmd_owner(types.SimpleNamespace(force_rescan=False))
        text = buf.getvalue()
        self.assertEqual(rc, 0)
        self.assertEqual(calls, [])
        self.assertIn('归属缓存命中', text)
        self.assertIn('唯一归属 2 | 多系统 0 | 未命中 0', text)


if __name__ == '__main__':
    unittest.main()
