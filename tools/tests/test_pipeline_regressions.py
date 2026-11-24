"""管线失败场景回归，所有外部调用均使用模拟响应。"""
import argparse
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

from tools.dwd.parsing import PREV_IDIOM_DOC, needs_schedule_dep
from tools.dws import deploy, scripts, state, verify
from tools.core.ddl_compare import compare_local_ddl
from tools.core.ddl_verify import diff_ddl

ROOT = Path(__file__).resolve().parents[2]


class TestPartitionDependencies(unittest.TestCase):
    def needs(self, sql):
        return needs_schedule_dep(sql, 'DWD_SRC')[0]

    def test_only_exact_equality_is_exempt(self):
        for op in ('>=', '<=', '>', '<', 'BETWEEN'):
            tail = " AND '${p_end_dt}'" if op == 'BETWEEN' else ''
            with self.subTest(op=op):
                self.assertTrue(self.needs(
                    f'SELECT * FROM DWD_SRC a WHERE a.P_DT {op} {PREV_IDIOM_DOC}{tail}'))
        self.assertFalse(self.needs(
            f'SELECT * FROM DWD_SRC a WHERE a.P_DT = {PREV_IDIOM_DOC}'))

    def test_self_join_unfiltered_reference_requires_dependency(self):
        self.assertTrue(self.needs(
            f'SELECT * FROM DWD_SRC a JOIN DWD_SRC b ON a.ID=b.ID '
            f'WHERE a.P_DT = {PREV_IDIOM_DOC}'))

    def test_nested_aliases_and_union_are_scoped(self):
        for sql in (
            f'SELECT * FROM (SELECT * FROM DWD_SRC a) x JOIN OTHER a '
            f'ON a.P_DT = {PREV_IDIOM_DOC}',
            f'SELECT * FROM (SELECT * FROM OTHER a WHERE a.P_DT = {PREV_IDIOM_DOC}) x '
            'JOIN DWD_SRC a ON a.ID=x.ID',
            f'SELECT * FROM DWD_SRC a WHERE a.P_DT = {PREV_IDIOM_DOC} '
            'UNION ALL SELECT * FROM DWD_SRC a',
            f'SELECT * FROM DWD_SRC a WHERE a.P_DT = {PREV_IDIOM_DOC} OR a.ID=1',
            f'SELECT * FROM DWD_SRC a WHERE a.P_DT = CONCAT({PREV_IDIOM_DOC}, 1)',
        ):
            with self.subTest(sql=sql):
                self.assertTrue(self.needs(sql))

    def test_each_filtered_reference_can_be_exempt(self):
        self.assertFalse(self.needs(
            f'SELECT * FROM DWD_SRC a JOIN DWD_SRC b ON a.ID=b.ID '
            f'AND b.P_DT = {PREV_IDIOM_DOC} WHERE a.P_DT = {PREV_IDIOM_DOC}'))
        self.assertFalse(self.needs(
            f'SELECT * FROM (SELECT * FROM DWD_SRC a WHERE a.P_DT = {PREV_IDIOM_DOC}) x'))

    def test_bare_partition_and_batch_variant(self):
        self.assertFalse(self.needs(
            f'SELECT * FROM DWD_SRC WHERE P_DT = {PREV_IDIOM_DOC}'))
        self.assertTrue(self.needs(
            'SELECT * FROM DWD_SRC WHERE P_DT = '
            + PREV_IDIOM_DOC.replace('p_end_dt', 'P_BATCH_DT')))
        cast = PREV_IDIOM_DOC.replace("'${p_end_dt}'", "CAST('${p_end_dt}' AS STRING)")
        self.assertFalse(self.needs(f'SELECT * FROM DWD_SRC a WHERE a.P_DT = {cast}'))

    def test_select_case_or_does_not_widen_partition_filter(self):
        sql = ("SELECT CASE WHEN a.ID=1 OR a.ID=2 THEN 1 ELSE 0 END "
               f"FROM DWD_SRC a WHERE a.P_DT = {PREV_IDIOM_DOC}")
        self.assertFalse(self.needs(sql))
        self.assertTrue(self.needs(sql + ' OR a.ID=3'))

    def test_or_in_separate_conjunct_does_not_bypass_partition(self):
        for condition in (
            f'a.P_DT = {PREV_IDIOM_DOC} AND (a.ID=1 OR a.ID=2)',
            f'(a.ID=1 OR a.ID=2) AND (a.P_DT = {PREV_IDIOM_DOC})',
            f'(a.P_DT = {PREV_IDIOM_DOC} AND (a.ID=1 OR (a.ID=2 OR a.ID=3)))',
        ):
            with self.subTest(condition=condition):
                self.assertFalse(self.needs(f'SELECT * FROM DWD_SRC a WHERE {condition}'))

    def test_or_outside_partition_group_still_requires_dependency(self):
        for condition in (
            f'(a.P_DT = {PREV_IDIOM_DOC} AND a.ID=1) OR a.ID=2',
            f'a.ID=1 AND (a.P_DT = {PREV_IDIOM_DOC} OR a.ID=2)',
            f'(a.P_DT = {PREV_IDIOM_DOC}) OR a.ID=2',
        ):
            with self.subTest(condition=condition):
                self.assertTrue(self.needs(f'SELECT * FROM DWD_SRC a WHERE {condition}'))

    def test_or_in_join_does_not_bypass_where_partition(self):
        self.assertFalse(self.needs(
            'SELECT * FROM DWD_SRC a JOIN OTHER b ON a.ID=b.ID OR a.ID=b.ID2 '
            f'WHERE a.P_DT = {PREV_IDIOM_DOC}'))


class TestGenerationFailures(unittest.TestCase):
    def test_failed_dwd_generation_stops_dws(self):
        with patch.object(scripts, '_sync_generated', side_effect=[7, 0]) as gen:
            rc = scripts.cmd_scripts(argparse.Namespace(layers='DWD,DWS', source='gen'))
        self.assertEqual(rc, 7)
        self.assertEqual([call.args[1] for call in gen.call_args_list], ['DWD'])

    def test_no_ods_fields_produces_no_table_artifacts(self):
        from tools.core.ir import TableMeta, FieldMeta
        from tools.generator.ods import (generate_all_ods_ddl,
                                         generate_all_ods_ddl_files, generate_all_ods_etl)
        table = TableMeta(src_table='T', ods_table='ODS_O32_T_PFD', is_reserved='是')
        fields = {'T': [FieldMeta(src_name='ID', is_ods='否')]}
        self.assertNotIn('CREATE TABLE', generate_all_ods_ddl([table], fields, 'O32'))
        with tempfile.TemporaryDirectory() as td:
            generate_all_ods_ddl_files([table], fields, td, 'O32')
            generate_all_ods_etl([table], fields, td, 'O32')
            self.assertEqual(list(Path(td).rglob('*.sh')), [])
            self.assertEqual(list(Path(td).rglob('*.sql')), [])

    def test_inferred_master_refused_before_parsing_or_writing(self):
        from tools import main
        parser = Mock()
        with patch.object(main.os, 'makedirs') as mkdir:
            with self.assertRaisesRegex(SystemExit, '拒绝生成 MASTER'):
                main._generate_dwd_dws('DWD', parser, '/input/00-MASTER',
                                       '/output', Mock())
        parser.assert_not_called()
        mkdir.assert_not_called()

    def test_failed_generator_never_publishes_partial_output(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            stage = root / 'stage'
            etl = stage / 'HSFA/dws/02_etl'
            etl.mkdir(parents=True)
            (etl / 'T.sh').write_text('partial', encoding='utf-8')
            with patch.object(scripts, 'gen_temp', return_value=stage), \
                    patch.object(scripts, 'run', return_value=(124, '')), \
                    patch.object(state, 'SCRIPTS', root / 'output'), \
                    patch.object(scripts, 'sync_files') as sync:
                self.assertEqual(scripts._sync_generated(
                    argparse.Namespace(apply=True), 'DWS'), 124)
                sync.assert_not_called()
            self.assertFalse(stage.exists())

    def test_missing_system_is_detected_before_any_sync(self):
        with tempfile.TemporaryDirectory() as td:
            stage = Path(td) / 'stage'
            etl = stage / 'HSFA/dws/02_etl'
            etl.mkdir(parents=True)
            (etl / 'T.sh').write_text('complete', encoding='utf-8')
            with patch.object(scripts, 'gen_temp', return_value=stage), \
                    patch.object(scripts, 'run', return_value=(0, '')), \
                    patch.object(scripts, 'sync_files') as sync:
                self.assertEqual(scripts._sync_generated(
                    argparse.Namespace(apply=True), 'DWS'), 1)
                sync.assert_not_called()

    def test_ods_initial_failure_stops_datax(self):
        template = (ROOT / 'demo/templates/etl_ods_template.sh').read_text(encoding='utf-8')
        # 用 shell 函数代替外部命令，保留完整模板控制流。
        template = template.replace('source /home/dolphinscheduler/hadoop_env', '')
        harness = 'beeline() { return 9; }\nsudo() { echo DATAX_CALLED; return 0; }\n'
        result = subprocess.run(['bash', '-s'], input=harness + template,
                                text=True, capture_output=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('DATAX_CALLED', result.stdout)

    def test_ods_json_write_failure_stops_datax(self):
        template = (ROOT / 'demo/templates/etl_ods_template.sh').read_text(encoding='utf-8')
        template = template.replace('source /home/dolphinscheduler/hadoop_env', '')
        harness = ('beeline() { return 0; }\nprintf() { return 7; }\n'
                   'sudo() { echo DATAX_CALLED; return 0; }\n')
        with tempfile.TemporaryDirectory() as td:
            result = subprocess.run(['bash', '-s'], input=harness + template,
                                    cwd=td, text=True, capture_output=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('DATAX_CALLED', result.stdout)


class TestDeploymentValidation(unittest.TestCase):
    def test_strict_is_forwarded_to_dwd(self):
        with patch.object(verify, 'run', return_value=(0, '')) as run:
            self.assertEqual(verify.cmd_verify(argparse.Namespace(
                layers='DWD', ds=False, strict=True)), 0)
        self.assertIn('--strict', run.call_args.args[0])

    def test_dwd_skipped_syntax_checks_are_visible_and_strict_fails(self):
        from tools.dwd import cli
        with tempfile.TemporaryDirectory() as td:
            ddl = Path(td) / '01_ddl.sql'
            ddl.write_text('', encoding='utf-8')
            with patch.object(cli, 'GROUPS', ('TEST',)), \
                    patch.object(cli, '_shell_check', return_value=(2, [], 1)), \
                    patch.object(cli, 'ddl_main', return_value=ddl), \
                    patch.object(cli, 'ddl_dir', return_value=Path(td) / 'empty'):
                from contextlib import redirect_stdout
                import io
                for strict, expected in [(False, 0), (True, 1)]:
                    output = io.StringIO()
                    with redirect_stdout(output):
                        rc = cli.cmd_verify(argparse.Namespace(ds=False, strict=strict))
                    self.assertEqual(rc, expected)
                    self.assertIn('通过 1/2，未执行 1', output.getvalue())
                    self.assertNotIn('校验通过', output.getvalue())

    def test_empty_online_workflow_fails(self):
        with tempfile.TemporaryDirectory() as td:
            etl = Path(td) / 'HSFA/dws/02_etl'
            etl.mkdir(parents=True)
            (etl / 'DWS_A.sh').write_text('echo ok', encoding='utf-8')
            dc = Mock()
            dc.task_definitions.return_value = []
            with patch.object(state, 'SCRIPTS', Path(td)):
                self.assertEqual(verify._check_dws_workflow(
                    dc, Mock(), Mock(), 1,
                    dict(name='DWS_HSFA', code=2, releaseState='ONLINE')), 1)

    def test_preflight_uses_configured_project_resolver(self):
        dc = Mock()
        dc.project_code_of.return_value = 22
        dc.lst_of.return_value = []
        with patch.object(deploy, '_ds_client', return_value=dc):
            _, code, _ = deploy.ds_workflows(('DWD_',))
        self.assertEqual(code, 22)
        dc.project_code_of.assert_called_once_with(dc.get_client.return_value)

    def test_all_layers_checked_before_first_delete(self):
        with patch.object(deploy, 'check_dwd_only_preflight', return_value=True), \
                patch.object(deploy, 'run', side_effect=[(0, ''), (1, '')]) as run:
            self.assertEqual(deploy.cmd_deploy(
                argparse.Namespace(layers='DWD,DWS', apply=True)), 1)
        self.assertEqual(len(run.call_args_list), 2)
        for call in run.call_args_list:
            self.assertIn('--check-only', call.args[0])

    def test_snapshot_failure_prevents_deletion(self):
        with tempfile.TemporaryDirectory() as td, \
                patch.object(state, 'REPO', Path(td)), \
                patch.object(deploy, 'check_dwd_only_preflight', return_value=True), \
                patch.object(deploy, 'run', side_effect=[(0, ''), (0, ''), (7, '')]) as run:
            self.assertEqual(deploy.cmd_deploy(
                argparse.Namespace(layers='DWD,DWS', apply=True)), 1)
        self.assertEqual(len(run.call_args_list), 3)
        self.assertTrue(all('--delete-only' not in c.args[0]
                            for c in run.call_args_list))

    def test_failed_apply_prints_recovery_snapshot_and_commands(self):
        def fake_run(cmd):
            if '--out' in cmd:
                path = Path(cmd[cmd.index('--out') + 1])
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(
                    '{"schema":"dw-ds-deploy/v2","source":{"projectCode":22},"workflows":'
                    '[{"name":"DWS_HSFA"}]}', encoding='utf-8')
                return 0, ''
            return (1, '') if '--delete-only' in cmd else (0, '')

        output = io.StringIO()
        with tempfile.TemporaryDirectory() as td, \
                patch.object(state, 'REPO', Path(td)), \
                patch.object(deploy, 'check_dwd_only_preflight', return_value=True), \
                patch.object(deploy, 'ds_workflows', return_value=(Mock(), 22, [{'name': 'DWS_HSFA'}])), \
                patch.object(deploy, 'run', side_effect=fake_run), \
                redirect_stdout(output):
            rc = deploy.cmd_deploy(
                argparse.Namespace(layers='DWS', apply=True))
        self.assertEqual(rc, 1)
        self.assertIn('deploy-', output.getvalue())
        self.assertIn('import --input', output.getvalue())
        self.assertIn('--restore --dry-run', output.getvalue())
        self.assertIn('恢复按快照替换目标工作流', output.getvalue())

    def test_snapshot_project_or_coverage_mismatch_prevents_deletion(self):
        for source, workflows in (({'projectCode': 11}, [{'name': 'DWS_HSFA'}]),
                                  ({'projectCode': 22}, [])):
            def fake_run(cmd):
                if '--out' in cmd:
                    path = Path(cmd[cmd.index('--out') + 1])
                    path.write_text(json.dumps({
                        'schema': 'dw-ds-deploy/v2', 'source': source,
                        'workflows': workflows}), encoding='utf-8')
                return 0, ''

            with self.subTest(source=source, workflows=workflows), \
                    tempfile.TemporaryDirectory() as td, \
                    patch.object(state, 'REPO', Path(td)), \
                    patch.object(deploy, 'ds_workflows', return_value=(Mock(), 22, [{'name': 'DWS_HSFA'}])), \
                    patch.object(deploy, 'run', side_effect=fake_run) as run:
                self.assertEqual(deploy.cmd_deploy(
                    argparse.Namespace(layers='DWS', apply=True)), 1)
                self.assertTrue(all('--delete-only' not in call.args[0]
                                    for call in run.call_args_list))


class TestBatchDeployment(unittest.TestCase):
    def test_recovery_snapshot_orders_upstream_before_downstream(self):
        downstream = {
            'name': 'DWD_PROD',
            'tasks': [{'dependence': {'relation': 'OR', 'dependTaskList': [
                {'relation': 'AND', 'dependItemList': [{'dependWorkflow': 'DWD_CHNL'}]}]}}],
        }
        unrelated = {'name': 'DWD_CMM', 'tasks': []}
        upstream = {'name': 'DWD_CHNL', 'tasks': []}
        ordered = deploy._order_recovery_workflows(
            [downstream, unrelated, upstream])
        names = [wf['name'] for wf in ordered]
        self.assertLess(names.index('DWD_CMM'), names.index('DWD_PROD'))
        self.assertLess(names.index('DWD_CHNL'), names.index('DWD_PROD'))

    @classmethod
    def setUpClass(cls):
        directory = ROOT / 'tools/ds-deploy'
        # 导入时提供占位，阻止读取本机凭据文件。
        with patch.dict(os.environ, {
            'DS_ADMIN_PASSWORD': 'test-only', 'DS_PASSWORD': 'test-only',
            'DS_PROJECT': 'dw_test', 'DS_BASE': 'http://example.invalid/ds',
        }):
            sys.path.insert(0, str(directory))
            try:
                spec = importlib.util.spec_from_file_location(
                    'batch_regression', directory / 'ds-deploy-all-dwd.py')
                cls.batch = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(cls.batch)
            finally:
                sys.path.remove(str(directory))

    def test_batch_and_child_use_same_target(self):
        self.assertEqual(self.batch.DS, self.batch.D.DS)
        self.assertEqual(self.batch.PROJECT, self.batch.D.PROJECT)
        env = dict(os.environ, DS_BASE='http://example.invalid/ds', DS_PROJECT='dw_test',
                   DS_ADMIN_PASSWORD='test-only', DS_PASSWORD='test-only')
        code = (
            'import runpy, sys; b = runpy.run_path(sys.argv[1]); '
            'assert b["DS"] == b["D"].DS == "http://example.invalid/ds"; '
            'assert b["PROJECT"] == b["D"].PROJECT == "dw_test"'
        )
        result = subprocess.run(
            [sys.executable, '-B', '-c', code,
             str(ROOT / 'tools/ds-deploy/ds-deploy-all-dwd.py')],
            env=env, capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 0, '非默认 DS 地址和项目未能一致解析')

    def test_empty_rebuild_fails_before_login(self):
        with tempfile.TemporaryDirectory() as td, \
                patch.object(self.batch, 'DEPCFG', td), \
                patch.object(self.batch, 'login') as login, \
                patch.object(sys, 'argv', ['batch', '--layer', 'DWD']):
            with self.assertRaisesRegex(SystemExit, '重建计划为空'):
                self.batch.main()
            login.assert_not_called()

    def test_project_code_override_is_shared_without_querying(self):
        api = Mock()
        with patch.dict(os.environ, DS_PROJECT_CODE='987654'):
            self.assertEqual(self.batch.D.resolve_project(api), 987654)
        api.assert_not_called()

    def test_script_index_preserves_directory_precedence_and_layer(self):
        child = self.batch.D
        with tempfile.TemporaryDirectory() as td:
            for system, layer in [('A', 'dwd'), ('B', 'dwd'), ('A', 'dws')]:
                etl = Path(td) / 'scripts' / system / layer / '02_etl'
                etl.mkdir(parents=True)
                (etl / 'T.sh').write_text(system, encoding='utf-8')
            with patch.object(child, 'REPO', td), patch.object(child, 'LAYER', 'DWD'):
                index = child.script_index()
                self.assertEqual(Path(index['T']).parts[-4], 'A')
                self.assertEqual(Path(index['T']).parts[-3], 'dwd')
                self.assertEqual(child.script_of('T', index), index['T'])

    def test_offline_or_missing_after_rebuild_fails(self):
        batch = self.batch
        for final in ([], [dict(name='DWD_TEST', code=123, releaseState='OFFLINE')],
                      [dict(name='DWD_TEST', code=123, releaseState='ONLINE')]):
            with self.subTest(final=final), tempfile.TemporaryDirectory() as td:
                responses = iter([{'data': []}, {'data': []}, {'data': final}])
                with patch.object(batch, 'DEPCFG', td), \
                        patch.object(batch, 'load_groups', return_value=({'DWD_TEST': ['T']}, {})), \
                        patch.object(batch.D, 'script_index', return_value={'T': 'fixture'}), \
                        patch.object(batch.D, 'resolve_project', return_value=1), \
                        patch.object(batch, 'login'), \
                        patch.object(batch, 'raw', side_effect=lambda *a, **k: next(responses)), \
                        patch.object(batch.subprocess, 'run', return_value=Mock(
                            returncode=0, stdout=b'', stderr=b'')), \
                        patch.object(sys, 'argv', ['batch']):
                    self.assertEqual(batch.main(),
                                     0 if final and final[0]['releaseState'] == 'ONLINE' else 1)

    def test_release_failure_stops_later_workflows(self):
        child = self.batch.D
        with patch.object(child, 'wf_code', return_value=123), \
                patch.object(child, 'call', return_value={'code': 1}) as call:
            self.assertEqual(child.release_workflows(1, ['DWD_A', 'DWD_B']), 1)
            call.assert_called_once()
        with patch.object(child, 'wf_code', return_value=None), \
                patch.object(child, 'call') as call:
            self.assertEqual(child.release_workflows(1, ['DWD_A']), 1)
            call.assert_not_called()

    def test_release_success_returns_zero(self):
        child = self.batch.D
        with patch.object(child, 'wf_code', return_value=123), \
                patch.object(child, 'call', return_value={'code': 0}) as call:
            self.assertEqual(child.release_workflows(1, ['DWD_A', 'DWD_B']), 0)
            self.assertEqual(call.call_count, 2)


class TestDdlTargetNames(unittest.TestCase):
    def test_wrong_target_is_a_difference(self):
        diff = diff_ddl('CREATE TABLE A(ID STRING);', 'CREATE TABLE B(ID STRING);')
        self.assertFalse(diff.empty())
        self.assertEqual(diff.table_name_mismatch, ('A', 'B'))
        self.assertIn('表名不一致', diff.summary())

    def test_target_name_is_case_insensitive(self):
        self.assertTrue(diff_ddl('CREATE TABLE a(ID STRING);',
                                 'CREATE TABLE A(ID STRING);').empty())

    def test_filename_must_match_create_target(self):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / 'EXPECTED.sql'
            path.write_text('CREATE TABLE OTHER(ID STRING);', encoding='utf-8')
            diff, probs = compare_local_ddl(path, 'CREATE TABLE OTHER(ID STRING)')
        self.assertTrue(diff.empty())
        self.assertTrue(any('建表目标' in p for p in probs))

