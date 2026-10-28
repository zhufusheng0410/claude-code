# -*- coding: utf-8 -*-
"""tools/dw-pipeline.py 纯函数回归测试（不触碰 /mnt/d 与 DS）。"""
import argparse
import importlib.util
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


if __name__ == '__main__':
    unittest.main()
