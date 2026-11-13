# -*- coding: utf-8 -*-
"""tools/dw-pipeline.py 纯函数回归测试（不触碰 /mnt/d 与 DS）。"""
import argparse
import contextlib
import importlib.util
import io
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('dw_pipeline', ROOT / 'tools/dw-pipeline.py')
WP = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(WP)


class TestLayers(unittest.TestCase):
    def test_layers_of(self):
        self.assertEqual(WP.layers_of(argparse.Namespace(layers=' dwd, DWS ')),
                         {'DWD', 'DWS'})
        self.assertEqual(WP.layers_of(argparse.Namespace(layers='DWS')), {'DWS'})


class TestSyncFiles(unittest.TestCase):
    def test_dry_run_then_apply(self):
        with tempfile.TemporaryDirectory() as td:
            src = Path(td) / 'src'
            dst = Path(td) / 'dst'
            src.mkdir()
            (src / 'a.sh').write_text('a', encoding='utf-8')
            (src / 'b.sh').write_text('b', encoding='utf-8')
            self.assertEqual(WP.sync_files(src, dst, False), 2)
            self.assertFalse(dst.exists())
            WP.sync_files(src, dst, True)
            self.assertEqual(sorted(p.name for p in dst.iterdir()), ['a.sh', 'b.sh'])

    def test_update_and_prune(self):
        with tempfile.TemporaryDirectory() as td:
            src = Path(td) / 'src'
            dst = Path(td) / 'dst'
            src.mkdir()
            dst.mkdir()
            (src / 'a.sh').write_text('new', encoding='utf-8')
            (dst / 'a.sh').write_text('old', encoding='utf-8')
            (dst / 'stale.sh').write_text('x', encoding='utf-8')
            WP.sync_files(src, dst, True, prune=True)
            self.assertEqual((dst / 'a.sh').read_text(encoding='utf-8'), 'new')
            self.assertFalse((dst / 'stale.sh').exists())


class TestShellSyntax(unittest.TestCase):
    """`_shell_syntax` 必须对「CRLF + Windows 绝对路径」给出与实跑一致的结论。

    ★ 历史回退点：曾用文件路径调 bash ⇒ cygwin bash 由 Windows 原生进程启动时
      把 `C:\\a\\b` 的反斜杠吃掉（rc=127），24 个 DWS 脚本全被判语法失败；
      改用 stdin + text=True 又会被 Windows 反向翻译成 CRLF，`$'\\r'` 照样报错。
    这里固化「CRLF 合法脚本 ⇒ ok」与「真语法错 ⇒ bad」两个方向。
    """

    def setUp(self):
        if not shutil.which('bash'):
            self.skipTest('环境无 bash')

    def _write(self, td, body: str) -> Path:
        p = Path(td) / 'x.sh'
        p.write_bytes(body.replace('\n', '\r\n').encode('utf-8'))  # 强制 CRLF
        return p

    def test_crlf_valid_script_is_ok(self):
        with tempfile.TemporaryDirectory() as td:
            p = self._write(td, '#!/bin/sh\nif [ 1 -eq 1 ]; then\n  echo hi\nfi\n')
            self.assertEqual(WP._shell_syntax(p), 'ok')

    def test_real_syntax_error_is_bad(self):
        with tempfile.TemporaryDirectory() as td:
            p = self._write(td, '#!/bin/sh\nif [ 1 -eq 1 ]; then\n  echo hi\n')
            self.assertEqual(WP._shell_syntax(p), 'bad')


class TestShRepair(unittest.TestCase):
    """拼接副本修复：只保留第一个 beeline 的完整 SQL。"""

    def setUp(self):
        self.m = WP._sh_repair()

    ONE_COPY = ('#!/bin/sh\r\nbegin_date="${p_start_dt}"\r\n'
                'while [ $P_BATCH_DT -lt $end_date ]; \r\ndo\r\n'
                '    inceptor_beeline "\r\n    SELECT 1\r\n    "\r\n'
                '    P_BATCH_DT=$(date +1)\r\n'
                'done')
    # 甲方真实形态：第一份的 done 与第二份的 shebang 之间丢了换行
    GLUED = ONE_COPY + '#!/bin/sh\r\nbegin_date="${p_start_dt}"\r\n' \
                       'while [ $P_BATCH_DT -lt $end_date ]; \r\ndo\r\n' \
                       '    inceptor_beeline "\r\n    SELECT 1\r\n    "\r\n' \
                       '    P_BATCH_DT=$(date +1)\r\n' \
                       'done\r\n'

    def test_single_copy_untouched(self):
        new, notes = self.m.trim_to_first_copy(self.ONE_COPY)
        self.assertEqual(new, self.ONE_COPY)
        self.assertEqual(notes, [])

    def test_glued_done_keeps_first_copy_only(self):
        self.assertEqual(self.m.count_sql_calls(self.GLUED), 2)
        new, notes = self.m.trim_to_first_copy(self.GLUED)
        self.assertEqual(self.m.count_sql_calls(new), 1)
        # 只截断、不改写：新文本 == 第一份 + 补回的换行
        self.assertEqual(new, self.ONE_COPY + '\r\n')
        self.assertTrue(new.endswith('done\r\n'))
        # 第一份 SQL 逐字节保留
        self.assertEqual(self.m.sql_blocks(new)[0], self.m.sql_blocks(self.GLUED)[0])
        self.assertTrue(any('逐字符相同' in x for x in notes))

    def test_mismatched_copies_are_flagged(self):
        # 只改第二份的 SQL（rindex），第一份保持原样
        i = self.GLUED.rindex('SELECT 1')
        other = self.GLUED[:i] + 'SELECT 2' + self.GLUED[i + len('SELECT 1'):]
        _, notes = self.m.trim_to_first_copy(other)
        self.assertTrue(any('不一致' in x for x in notes))

    def test_repo_scripts_have_single_sql_block(self):
        """守门断言：仓库内脚本都只应有一处 beeline SQL（新增交付要过这道检查）。"""
        root = Path(__file__).resolve().parents[2] / 'scripts'
        for p in sorted(root.glob('*/dws/02_etl/*.sh')):
            n = self.m.count_sql_calls(p.read_bytes().decode('utf-8', 'replace'))
            self.assertLessEqual(n, 1, f'{p.parent.parent.parent.name}/{p.name} SQL 块 ×{n}')


class TestDdlDiffLabels(unittest.TestCase):
    """★ 2026-10-27 回归：`diff_ddl` 的 left/right 标签必须真正生效。

    原先 `left_label`/`right_label` 一路传到 `_cmp_cols` 却**从未被使用**，
    而 `DDLDiff.summary()` 把「甲方/本地」写死 ⇒ 换成「线上 vs 仓库」等场景时，
    摘要仍谎称甲方/本地，读报告的人会被带偏。
    """

    LEFT = ("CREATE TABLE T (A STRING COMMENT 'a', B INT COMMENT 'b') "
            "COMMENT 't' PARTITIONED BY (P_DT STRING)")
    RIGHT = ("CREATE TABLE T (A STRING COMMENT 'a', C BIGINT COMMENT 'c') "
             "COMMENT 't' PARTITIONED BY (P_DT STRING)")

    @classmethod
    def setUpClass(cls):
        import importlib.util
        path = Path(__file__).resolve().parents[1] / 'core' / 'ddl_verify.py'
        spec = importlib.util.spec_from_file_location('_ddl_verify_t', path)
        cls.m = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.m)

    def test_default_labels(self):
        d = self.m.diff_ddl(self.LEFT, self.RIGHT)
        s = d.summary()
        self.assertIn('甲方', s)
        self.assertIn('本地', s)

    def test_custom_labels_take_effect(self):
        d = self.m.diff_ddl(self.LEFT, self.RIGHT, '线上', '仓库')
        s = d.summary()
        self.assertIn('仅线上有列', s)
        self.assertIn('仅仓库有列', s)
        self.assertNotIn('甲方', s)
        self.assertNotIn('本地', s)

    def test_parse_failure_respects_labels(self):
        d = self.m.diff_ddl('not a ddl', self.RIGHT, '线上', '仓库')
        self.assertIn('仅线上有列', d.summary())


class TestDwsTableSysMap(unittest.TestCase):
    """★ 回归：ddl/ 与 `_DWS搬移清单.json` 必须取并集。

    原先「清单存在就只用清单」会丢掉清单未登记的 ddl 表，cmd_verify_ddl 随即
    静默跳过这些表（校验变弱、不报错）。
    """

    def test_union_of_ddl_dir_and_manifest(self):
        import json
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            ddl = root / 'HSFA' / 'dws' / 'ddl'
            ddl.mkdir(parents=True)
            (ddl / 'DWS_ONLY_DDL.sql').write_text('x', encoding='utf-8')
            (ddl / 'DWS_BOTH.sql').write_text('x', encoding='utf-8')
            manifest = {'files': [
                {'name': 'DWS_ONLY_MANIFEST.sh', 'group': 'O32'},
                {'name': 'DWS_BOTH.sh', 'group': 'HSZTA'},
            ]}
            (root / '_DWS搬移清单.json').write_text(json.dumps(manifest), encoding='utf-8')
            old_scripts, old_sys = WP.SCRIPTS, WP.SYS
            WP.SCRIPTS, WP.SYS = root, ('HSFA',)
            try:
                m = WP.dws_table_sys_map()
            finally:
                WP.SCRIPTS, WP.SYS = old_scripts, old_sys
        self.assertEqual(m, {'DWS_ONLY_DDL': 'HSFA', 'DWS_ONLY_MANIFEST': 'O32',
                             'DWS_BOTH': 'HSFA'})  # ddl 落位优先于清单


class TestDwsManifestSha(unittest.TestCase):
    """清单 sha/bytes 与现盘不符时失败，且不得改写清单或覆盖脚本。"""

    def test_mismatch_fails_unless_flag_and_does_not_rewrite(self):
        import hashlib
        import json
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            script = root / 'HSFA' / 'dws' / '02_etl' / 'DWS_X.sh'
            script.parent.mkdir(parents=True)
            script.write_bytes(b'hello')
            manifest_path = root / '_DWS搬移清单.json'
            manifest = {'files': [{
                'name': 'DWS_X.sh', 'group': 'HSFA',
                'sha256': '0' * 64, 'bytes': 5,
            }]}
            manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
            before = manifest_path.read_bytes()
            old = WP.SCRIPTS
            WP.SCRIPTS = root
            WP._STALE_MANIFEST_WARNED = False
            try:
                with self.assertRaises(WP.StaleDwsManifest):
                    WP.dws_source_map()
                self.assertEqual(manifest_path.read_bytes(), before)
                got = WP.dws_source_map(allow_stale=True)
                self.assertEqual(got['DWS_X'], 'HSFA')
                self.assertEqual(manifest_path.read_bytes(), before)
                manifest['files'][0]['sha256'] = hashlib.sha256(b'hello').hexdigest()
                manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
                self.assertEqual(WP.dws_source_map()['DWS_X'], 'HSFA')
            finally:
                WP.SCRIPTS = old
                WP._STALE_MANIFEST_WARNED = False

    def test_stage_never_overwrites(self):
        import json
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            jf = root / 'jf'
            jf.mkdir()
            (jf / 'DWS_X.txt').write_bytes(b'raw-jf')
            scripts = root / 'scripts'
            dst = scripts / 'HSFA' / 'dws' / '02_etl' / 'DWS_X.sh'
            dst.parent.mkdir(parents=True)
            dst.write_bytes(b'repo-fixed')
            (scripts / '_DWS搬移清单.json').write_text(json.dumps({
                'files': [{'name': 'DWS_X.sh', 'group': 'HSFA'}],
            }), encoding='utf-8')
            old_s, old_src = WP.SCRIPTS, WP.SRC_DWS_EXEC
            WP.SCRIPTS, WP.SRC_DWS_EXEC = scripts, jf
            try:
                WP.stage_dws_from_jf(argparse.Namespace(
                    allow_stale_dws_manifest=False))
                self.assertEqual(dst.read_bytes(), b'repo-fixed')
            finally:
                WP.SCRIPTS, WP.SRC_DWS_EXEC = old_s, old_src

    def test_overwrite_flag_removed(self):
        self.assertNotIn('raw', WP.OPT)
        blob = str(WP.OPT) + str({k: v[1] for k, v in WP.SUBCOMMANDS.items()})
        self.assertNotIn('force-dws-raw', blob)
        self.assertNotIn('force_dws_raw', blob)
        for name, (_fn, opts, _text) in WP.SUBCOMMANDS.items():
            self.assertNotIn('raw', opts, name)



class TestManifestGroupTraversal(unittest.TestCase):
    """★ 2026-11-10（评审 H2）：清单 ``group`` 是外部数据，必须当路径校验。

    原先 `SCRIPTS / group / …` 直接拼清单值：一条 `group: "../../x"` 就能
    让 `build_dws_ddl_from_jf` 把 `*.sql` 写到 `scripts/` 之外。
    """

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.root = Path(self._tmp.name)
        self._saved = (WP.SCRIPTS, WP._STALE_MANIFEST_WARNED)
        WP.SCRIPTS = self.root
        WP._STALE_MANIFEST_WARNED = False
        self.addCleanup(self._restore)

    def _restore(self):
        WP.SCRIPTS, WP._STALE_MANIFEST_WARNED = self._saved

    def _manifest(self, files):
        import json
        (self.root / '_DWS搬移清单.json').write_text(
            json.dumps({'files': files}, ensure_ascii=False), encoding='utf-8')

    def test_group_with_dotdot_raises(self):
        self._manifest([{'name': 'DWS_X.sh', 'group': '../../evil'}])
        with self.assertRaises(WP.StaleDwsManifest):
            WP.dws_source_map()

    def test_group_with_slash_never_maps_even_allow_stale(self):
        self._manifest([{'name': 'DWS_X.sh', 'group': 'HSFA/../../evil'}])
        self.assertEqual(WP.dws_source_map(allow_stale=True), {})

    def test_legal_group_still_maps(self):
        self._manifest([{'name': 'DWS_X.sh', 'group': 'HSFA'}])
        self.assertEqual(WP.dws_source_map()['DWS_X'], 'HSFA')

    def test_non_object_entry_reported(self):
        self._manifest(['oops'])
        self.assertTrue(WP.dws_manifest_mismatches())

    def test_non_string_group_reported(self):
        """★ 复审：group 是 int 时 safe_sysname 会抛 TypeError，必须被拦下。"""
        self._manifest([{'name': 'DWS_X.sh', 'group': 123}])
        self.assertTrue(WP.dws_manifest_mismatches())

    def test_non_string_name_reported(self):
        """★ 复审：name 是 int 时 .endswith 会抛 AttributeError。"""
        self._manifest([{'name': 123, 'group': 'HSFA'}])
        self.assertTrue(WP.dws_manifest_mismatches())

    def test_null_files_does_not_crash(self):
        """★ 复审：`{"files": null}` 时取值不得抛 NoneType is not iterable。"""
        self._manifest(None)
        self.assertEqual(WP.dws_source_map(allow_stale=True), {})

    def test_name_with_separator_reported(self):
        self._manifest([{'name': '../../x.sh', 'group': 'HSFA'}])
        self.assertTrue(WP.dws_manifest_mismatches())

    def test_dwd_etl_dir_rejects_traversal(self):
        with self.assertRaises(ValueError):
            WP.dwd_etl_dir('../evil')


class TestApplyForwarding(unittest.TestCase):
    """★ 阶段 1 行为契约：`--apply` / dry-run 必须原样传给子命令。"""

    def test_apply_flag_forwarded(self):
        self.assertEqual(WP._ap(argparse.Namespace(apply=True)), ['--apply'])
        self.assertEqual(WP._ap(argparse.Namespace(apply=False)), [])

    def test_dry_run_flag_only_without_apply(self):
        self.assertEqual(WP._dry(argparse.Namespace(apply=False)), ['--dry-run'])
        self.assertEqual(WP._dry(argparse.Namespace(apply=True)), [])


class TestCmdAllStopsOnFailure(unittest.TestCase):
    """★ 阶段 1 行为契约：子步骤失败时后续阶段不得继续。"""

    def test_later_steps_not_run(self):
        calls = []
        saved = {n: getattr(WP, n) for n in TestCmdAllSteps._NAMES}
        self.addCleanup(lambda: [setattr(WP, n, v) for n, v in saved.items()])

        def fake(name, rc):
            def _f(_args):
                calls.append(name)
                return rc
            return _f

        WP.cmd_scripts = fake("scripts", 0)
        WP.cmd_ddl = fake("ddl", 1)          # 第二步失败
        for n in ("cmd_verify_ddl", "cmd_lineage", "cmd_config", "cmd_verify"):
            setattr(WP, n, fake(n[4:], 0))
        with contextlib.redirect_stdout(io.StringIO()):
            rc = WP.cmd_all(argparse.Namespace(source="jf", deploy=False, ds=False))
        self.assertEqual(rc, 1)
        self.assertEqual(calls, ["scripts", "ddl"], "失败后不得继续后续阶段")


class TestRepairDryRun(unittest.TestCase):
    """★ 阶段 1 行为契约：dry-run 不写文件。"""

    def test_dry_run_leaves_script_untouched(self):
        glued = ('#!/bin/sh\n'
                 'inceptor_beeline "SELECT 1"\ndone\n'
                 'inceptor_beeline "SELECT 1"\ndone\n')
        with tempfile.TemporaryDirectory() as td:
            scripts = Path(td) / 'scripts'
            d = scripts / 'HSFA' / 'dwd' / '02_etl'
            d.mkdir(parents=True)
            p = d / 'X.sh'
            p.write_text(glued, encoding='utf-8')
            saved = WP.SCRIPTS
            WP.SCRIPTS = scripts
            self.addCleanup(setattr, WP, 'SCRIPTS', saved)
            with contextlib.redirect_stdout(io.StringIO()):
                rc = WP.cmd_repair(argparse.Namespace(layers='DWD', apply=False))
            self.assertEqual(rc, 0)
            self.assertEqual(p.read_text(encoding='utf-8'), glued)


class TestDwdDdlCmd(unittest.TestCase):
    """DWD DDL 子命令参数透传。

    ★ 历史：2026-11-08 `dwd-pipeline.py ddl` 没有 `--no-strict` 开关，
      早先无条件转发 ⇒ 子进程 argparse 报 `unrecognized arguments`。
    ★ 2026-11-09（A8）：DWD 侧也加了落盘自检，开关成为合法参数，
      但仍只在**显式传入**时转发，避免无谓参数污染。
    """

    def test_no_strict_forwarded_when_set(self):
        args = argparse.Namespace(apply=False, no_strict=True)
        cmd = WP._dwd_ddl_cmd(args)
        self.assertIn('--no-strict', cmd)
        self.assertEqual([str(x) for x in cmd],
                         [str(WP.PY), str(WP.DWD_PIPE), 'ddl', '--no-strict'])

    def test_no_strict_absent_when_not_set(self):
        args = argparse.Namespace(apply=False, no_strict=False)
        self.assertNotIn('--no-strict', WP._dwd_ddl_cmd(args))

    def test_apply_still_forwarded(self):
        args = argparse.Namespace(apply=True, no_strict=True)
        self.assertEqual(WP._dwd_ddl_cmd(args)[-1], '--no-strict')
        self.assertIn('--apply', WP._dwd_ddl_cmd(args))


class TestDdlStatementBoundary(unittest.TestCase):
    """语句边界（A1 回归）：`diff_ddl` 只看列/分区，看不出「DROP 缺分号」。

    ★ 实证缺陷文件：`scripts/O32/dws/ddl/DWS_TRAN_FUTR_TRAN_DETAIL_PTD.sql`
      （甲方 `02-DWS建表脚本.sql` 里 DROP 行没写分号，紧跟 CREATE）。
      beeline 按 `;` 切分 ⇒ DROP 与 CREATE 被合成一条语句 ⇒ ParseException，
      而 37/37 的 diff 全绿。故 DDL 校验必须并列一道语句边界检查。
    """

    def setUp(self):
        self.dv = WP._load_ddl_verify()

    def test_split_ignores_semicolon_in_string_and_comment(self):
        sql = ("CREATE TABLE T (A STRING COMMENT 'x; --y') -- 行注释 ;\n"
               ";\nCREATE TABLE U (B STRING);\n")
        st = self.dv.split_statements(sql)
        self.assertEqual(len(st), 2, st)
        self.assertIn("'x; --y'", st[0])

    def test_lint_flags_drop_create_glued(self):
        bad = ("DROP TABLE IF EXISTS DWSXDAY.T \n"
               "CREATE TABLE DWSXDAY.T (A STRING);\n")
        probs = self.dv.lint_statements(bad)
        self.assertEqual(len(probs), 1, probs)
        self.assertIn('DROP 与 CREATE', probs[0])

    def test_lint_flags_two_creates_glued(self):
        bad = "CREATE TABLE T (A STRING)\nCREATE TABLE U (B STRING);\n"
        probs = self.dv.lint_statements(bad)
        self.assertTrue(any('2 个 CREATE' in p for p in probs), probs)

    def test_lint_flags_standalone_drop(self):
        bad = "DROP TABLE IF EXISTS DWSXDAY.T;\n"
        probs = self.dv.lint_statements(bad)
        self.assertTrue(any('残留独立 DROP' in p for p in probs), probs)

    def test_lint_clean_ddl_passes(self):
        good = ("-- 来源: 甲方\nCREATE TABLE T (A STRING COMMENT 'x; --y')\n"
                "PARTITIONED BY ( P_DT STRING)\n;\n")
        self.assertEqual(self.dv.lint_statements(good), [])

    def test_parse_jf_ddl_strips_semicolonless_drop(self):
        src = ("DROP TABLE IF EXISTS DWSXDAY.T \n"
               "CREATE TABLE DWSXDAY.T (A STRING);\n")
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / 'jf.sql'
            p.write_text(src, encoding='utf-8')
            stmts = WP.parse_jf_ddl(p)
        self.assertIn('T', stmts)
        self.assertNotIn('DROP', stmts['T'].upper())
        self.assertEqual(self.dv.lint_statements(stmts['T']), [])


class TestDwdGroupDirs(unittest.TestCase):
    """C3 回归：主数据必须映射到 scripts/MASTER，且 repair 要扫到它。

    ★ 背景：C3 只把循环变量从 SYS 换成 GROUPS 还不够——路径仍按
      `scripts/<组>/dwd/02_etl` 拼，`主数据` 目录根本不存在，扫不到就静默跳过。
    """

    def test_master_maps_to_master_dir(self):
        self.assertEqual(WP.dwd_etl_dir('主数据'),
                         WP.SCRIPTS / 'MASTER/dwd/02_etl')
        self.assertEqual(WP.ddl_main('主数据'),
                         WP.SCRIPTS / 'MASTER/dwd/01_ddl.sql')

    def test_regular_system_path(self):
        self.assertEqual(WP.dwd_etl_dir('O32'), WP.SCRIPTS / 'O32/dwd/02_etl')
        self.assertEqual(WP.ddl_main('O32'), WP.SCRIPTS / 'O32/dwd/01_ddl.sql')

    def test_repair_scans_master_scripts(self):
        with tempfile.TemporaryDirectory() as td:
            scripts = Path(td) / 'scripts'
            master = scripts / 'MASTER' / 'dwd' / '02_etl'
            master.mkdir(parents=True)
            (master / 'X.sh').write_text(
                '#!/bin/sh\n'
                'inceptor_beeline "SELECT 1"\n'
                'done\n'
                'inceptor_beeline "SELECT 1"\n', encoding='utf-8')
            saved = WP.SCRIPTS
            WP.SCRIPTS = scripts
            self.addCleanup(setattr, WP, 'SCRIPTS', saved)
            out = io.StringIO()
            with contextlib.redirect_stdout(out):
                rc = WP.cmd_repair(argparse.Namespace(layers='DWD', apply=False))
            self.assertEqual(rc, 0)
            self.assertIn('主数据/X.sh', out.getvalue())


class TestCmdAllSteps(unittest.TestCase):
    """A8 回归：`all` 的步骤编排。

    ★ gen 模式的 DDL 来自生成器（与甲方不保证逐字节一致，如 6 张去分区表），
      不能拿它去跑「与甲方比对」的 verify-ddl ⇒ 该步只在 jf 模式出现。
    """

    _NAMES = ("cmd_scripts", "cmd_ddl", "cmd_verify_ddl",
              "cmd_lineage", "cmd_config", "cmd_verify")

    def _run(self, source):
        calls = []
        saved = {n: getattr(WP, n) for n in self._NAMES}

        def _restore():
            for n, v in saved.items():
                setattr(WP, n, v)

        self.addCleanup(_restore)
        for n in self._NAMES:
            label = n[len("cmd_"):]
            setattr(WP, n, (lambda lab: lambda args: calls.append(lab) or 0)(label))
        args = argparse.Namespace(source=source, deploy=False, ds=False)
        with contextlib.redirect_stdout(io.StringIO()):
            rc = WP.cmd_all(args)
        return rc, calls

    def test_jf_mode_includes_verify_ddl(self):
        rc, calls = self._run("jf")
        self.assertEqual(rc, 0)
        self.assertEqual(calls,
                         ["scripts", "ddl", "verify_ddl", "lineage", "config", "verify"])

    def test_gen_mode_skips_verify_ddl(self):
        rc, calls = self._run("gen")
        self.assertEqual(rc, 0)
        self.assertNotIn("verify_ddl", calls)
        self.assertEqual(calls, ["scripts", "ddl", "lineage", "config", "verify"])


if __name__ == '__main__':
    unittest.main()
