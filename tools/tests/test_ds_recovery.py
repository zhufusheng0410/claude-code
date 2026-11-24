"""恢复导入和串行跑批的回归测试，使用内存中的 DS 响应。"""
import argparse
import copy
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch


DEPLOY = Path(__file__).resolve().parents[1] / 'ds-deploy'


def load_script(filename):
    with patch.dict(os.environ, {
        'DS_ADMIN_PASSWORD': 'test-only', 'DS_PASSWORD': 'test-only',
        'DS_PG_PASSWORD': 'test-only', 'DS_PROJECT': 'review_test',
        'DS_BASE': 'http://example.invalid/ds',
    }):
        spec = importlib.util.spec_from_file_location(filename.replace('-', '_'), DEPLOY / filename)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
    return module


class MemoryDS:
    def __init__(self):
        self.workflows = {}
        self.calls = []
        self.fail_backfill = False
        self.schedules = []

    def call(self, method, path, params=None, form=None):
        self.calls.append((method, path, copy.deepcopy(form)))
        if not path.startswith('/projects/22/'):
            raise AssertionError(f'访问了非目标项目 {path}')
        if path == '/projects/22/schedules':
            return {'code': 0, 'data': self.schedules}
        if '/schedules/' in path:
            return {'code': 0}
        base = '/projects/22/workflow-definition'
        if method == 'GET' and path == base:
            return {'code': 0, 'data': {'totalList': [
                {'code': code, 'name': data['workflowDefinition']['name']}
                for code, data in self.workflows.items()]}}
        if path.endswith('/release'):
            code = int(path.split('/')[-2])
            self.workflows[code]['workflowDefinition']['releaseState'] = form['releaseState']
            return {'code': 0}
        if method == 'GET':
            return {'code': 0, 'data': copy.deepcopy(self.workflows[int(path.split('/')[-1])])}
        code = len(self.workflows) + 101 if method == 'POST' else int(path.split('/')[-1])
        tasks = json.loads(form['taskDefinitionJson'])
        if self.fail_backfill and any(
            group.get('dependItemList')
            for task in tasks for group in task.get('taskParams', {}).get(
                'dependence', {}).get('dependTaskList', [])
        ):
            return {'code': 1, 'msg': 'backfill failed'}
        if method == 'POST':
            # 模拟服务端最终编号，确认第二遍使用回读结果。
            for offset, task in enumerate(tasks):
                task['code'] = code * 100 + offset
        self.workflows[code] = {
            'workflowDefinition': dict(form, code=code),
            'taskDefinitionList': tasks,
            'workflowTaskRelationList': json.loads(form['taskRelationJson']),
        }
        return {'code': 0, 'data': {'code': code}}


def shell(name):
    return {'name': name, 'taskType': 'SHELL', 'script': 'echo recovery-test'}


def dependent(name, workflow, task='', kind='DEPENDENT_ON_TASK'):
    return {'name': name, 'taskType': 'DEPENDENT', 'dependItems': [{
        'dependWorkflow': workflow, 'dependTask': task, 'dependentType': kind}]}


class TestRecoveryImport(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = load_script('ds-deploy-api.py')

    def setUp(self):
        self.ds = MemoryDS()
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / 'recovery.json'
        for target, name, value in (
            (self.api.D, 'call', self.ds.call),
            (self.api.D, 'login', Mock()),
        ):
            patcher = patch.object(target, name, value)
            patcher.start()
            self.addCleanup(patcher.stop)
        patcher = patch.dict(os.environ, {'DS_PROJECT_CODE': '22'})
        patcher.start()
        self.addCleanup(patcher.stop)

    def run_import(self, workflows, dry_run=False):
        self.path.write_text(json.dumps({'schema': self.api.SCHEMA,
                                        'workflows': workflows}), encoding='utf-8')
        return self.api.cmd_import(argparse.Namespace(input=str(self.path), dry_run=dry_run))

    def test_forward_dependencies_use_fresh_workflow_scoped_codes(self):
        workflows = [
            {'name': 'DWS_DOWN', 'tasks': [shell('DOWN'), dependent('dep', 'DWD_UP', 'SAME')]},
            {'name': 'DWD_OTHER', 'tasks': [shell('SAME')]},
            {'name': 'DWD_UP', 'tasks': [shell('SAME')]},
        ]
        self.assertEqual(self.run_import(workflows), 0)
        index = self.api._workflow_index(22)
        data = self.ds.workflows[index['DWS_DOWN']['code']]
        dep = next(t for t in data['taskDefinitionList'] if t['name'] == 'dep')
        item = dep['taskParams']['dependence']['dependTaskList'][0]['dependItemList'][0]
        self.assertEqual(item['definitionCode'], index['DWD_UP']['code'])
        self.assertEqual(item['depTaskCode'], index['DWD_UP']['tasks']['SAME'])
        self.assertEqual(item['projectCode'], 22)
        writes = [method for method, path, form in self.ds.calls if method != 'GET']
        self.assertEqual(writes, ['POST', 'POST', 'POST', 'PUT'])

    def test_workflow_dependency_and_existing_upstream(self):
        self.assertEqual(self.run_import([{'name': 'UP', 'tasks': [shell('T')]}]), 0)
        self.assertEqual(self.run_import([{'name': 'DOWN', 'tasks': [
            dependent('dep', 'UP', kind='DEPENDENT_ON_WORKFLOW')]}]), 0)
        dep = self.ds.workflows[102]['taskDefinitionList'][0]
        item = dep['taskParams']['dependence']['dependTaskList'][0]['dependItemList'][0]
        self.assertEqual((item['definitionCode'], item['depTaskCode']), (101, 0))

    def test_missing_dependency_aborts_before_writes_including_dry_run(self):
        for dry_run in (False, True):
            self.assertEqual(self.run_import([{'name': 'DOWN', 'tasks': [
                dependent('dep', 'MISSING', 'T')]}], dry_run=dry_run), 1)
        self.assertTrue(all(method == 'GET' for method, _, _ in self.ds.calls))

    def test_legacy_ambiguous_task_is_rejected(self):
        self.assertEqual(self.run_import([
            {'name': 'A', 'tasks': [shell('T')]},
            {'name': 'B', 'tasks': [shell('T')]},
            {'name': 'DOWN', 'tasks': [dependent('dep', '', 'T')]},
        ]), 1)
        self.assertEqual(self.ds.workflows, {})

    def test_backfill_failure_returns_nonzero_and_leaves_workflows_offline(self):
        self.ds.fail_backfill = True
        self.path.write_text(json.dumps({'schema': self.api.SCHEMA, 'workflows': [
            {'name': 'DOWN', 'tasks': [dependent('dep', 'UP', 'T')]},
            {'name': 'UP', 'tasks': [shell('T')]},
        ]}), encoding='utf-8')
        with patch.object(sys, 'argv', ['ds-deploy-api.py', 'import', '-i', str(self.path)]):
            self.assertEqual(self.api.main(), 1)
        self.assertFalse(any(path.endswith('/release') for _, path, _ in self.ds.calls))
        self.assertFalse(any('/schedules/' in path for _, path, _ in self.ds.calls))

    def test_upsert_restores_only_target_schedules_after_dependency_backfill(self):
        workflows = [
            {'name': 'DOWN', 'tasks': [dependent('dep', 'UP', 'T')]},
            {'name': 'UP', 'tasks': [shell('T')]},
        ]
        self.assertEqual(self.run_import(workflows), 0)
        for wf in self.ds.workflows.values():
            wf['workflowDefinition']['releaseState'] = 'ONLINE'
        self.ds.schedules = [
            {'id': 1, 'workflowDefinitionCode': 101, 'releaseState': 'ONLINE'},
            {'id': 2, 'workflowDefinitionCode': 999, 'releaseState': 'ONLINE'},
            {'id': 3, 'workflowDefinitionCode': 102, 'releaseState': 'OFFLINE'},
        ]
        self.ds.calls.clear()
        self.assertEqual(self.run_import(workflows), 0)
        writes = [(method, path, form) for method, path, form in self.ds.calls if method != 'GET']
        self.assertEqual(writes[-1][1], '/projects/22/schedules/1/online')
        self.assertEqual(sum('/schedules/' in path for _, path, _ in writes), 1)
        last_put = max(i for i, (method, _, _) in enumerate(writes) if method == 'PUT')
        first_online = next(i for i, (_, path, form) in enumerate(writes)
                            if path.endswith('/release') and form['releaseState'] == 'ONLINE')
        self.assertLess(last_put, first_online)

    def test_export_records_resolved_project(self):
        self.assertEqual(self.run_import([{'name': 'DWD_UP', 'tasks': [shell('T')]}]), 0)
        self.api.cmd_export(argparse.Namespace(match='DWD_', only='', out=str(self.path)))
        doc = json.loads(self.path.read_text(encoding='utf-8'))
        self.assertEqual(doc['source']['projectCode'], 22)
        self.assertEqual(doc['workflows'][0]['name'], 'DWD_UP')

    def test_snapshot_round_trip_keeps_task_settings_and_dependency_groups(self):
        self.assertEqual(self.run_import([
            {'name': 'UP', 'tasks': [shell('A'), shell('B')]},
            {'name': 'DOWN', 'tasks': [dependent('gate', 'UP', 'A')]},
        ]), 0)
        self.ds.workflows[101]['workflowDefinition']['timeout'] = 45
        original = self.ds.workflows[101]['taskDefinitionList'][0]
        original.update(workerGroup='batch', environmentCode=42, failRetryTimes=3,
                        timeoutFlag='OPEN', timeout=15)
        original['taskParams'].update(
            localParams=[{'prop': 'batch', 'value': 'night', 'type': 'VARCHAR', 'direct': 'IN'}],
            resourceList=[{'id': 7}])
        gate = self.ds.workflows[102]['taskDefinitionList'][0]
        dep = gate['taskParams']['dependence']
        first = dep['dependTaskList'][0]['dependItemList'][0]
        second = dict(first, depTaskCode=10101, dateValue='last1Days', parameterPassing=True)
        whole = dict(first, depTaskCode=0, dependentType='DEPENDENT_ON_WORKFLOW')
        dep.update(relation='OR', checkInterval=12, dependTaskList=[
            {'relation': 'OR', 'dependItemList': [first, second]},
            {'relation': 'AND', 'dependItemList': [whole]}])
        dep['dependTaskList'] = json.dumps(dep['dependTaskList'])
        gate['taskParams']['dependence'] = json.dumps(dep)
        gate['taskParams'] = json.dumps(gate['taskParams'])

        export = argparse.Namespace(match='', only='UP,DOWN', out=str(self.path))
        self.api.cmd_export(export)
        snapshot = json.loads(self.path.read_text(encoding='utf-8'))
        self.assertEqual(snapshot['schema'], 'dw-ds-deploy/v2')
        groups = snapshot['workflows'][0]['tasks'][0]['dependence']['dependTaskList']
        self.assertEqual(groups[0]['dependItemList'][1]['dependTask'], 'B')
        self.assertNotIn('depTaskCode', groups[0]['dependItemList'][0])
        self.ds.workflows.clear()
        self.assertEqual(self.api.cmd_import(argparse.Namespace(
            input=str(self.path), dry_run=False, restore=True)), 0)
        # 导出按名字排序，恢复时 DOWN 先创建，UP 获得新编号。
        restored = self.ds.workflows[102]['taskDefinitionList'][0]
        self.assertEqual(self.ds.workflows[102]['workflowDefinition']['timeout'], 45)
        self.assertEqual(restored['taskParams'], original['taskParams'])
        for key in ('workerGroup', 'environmentCode', 'failRetryTimes', 'timeoutFlag', 'timeout'):
            self.assertEqual(restored[key], original[key])
        restored_dep = self.ds.workflows[101]['taskDefinitionList'][0]['taskParams']['dependence']
        self.assertEqual(restored_dep['dependTaskList'][0]['dependItemList'][1]['depTaskCode'], 10201)
        self.api.cmd_export(export)
        self.assertEqual(json.loads(self.path.read_text(encoding='utf-8'))['workflows'],
                         snapshot['workflows'])

    def test_restore_removes_extra_members_and_edges_and_restores_empty_params(self):
        self.assertEqual(self.run_import([
            {'name': 'TARGET', 'tasks': [shell('A'), shell('B')]},
            {'name': 'OTHER', 'tasks': [shell('KEEP')]},
        ]), 0)
        target = self.ds.workflows[101]
        a, b = (t['code'] for t in target['taskDefinitionList'])
        target['workflowTaskRelationList'] = [self.api.D.rel(0, a), self.api.D.rel(a, b)]
        self.api.cmd_export(argparse.Namespace(match='', only='TARGET', out=str(self.path)))
        target['taskDefinitionList'].append(dict(target['taskDefinitionList'][0], name='EXTRA', code=99999))
        target['workflowTaskRelationList'].append(self.api.D.rel(b, a))
        target['workflowDefinition']['globalParams'] = '[{"prop":"obsolete","value":"x"}]'
        original = copy.deepcopy(self.ds.workflows)
        self.ds.calls.clear()
        output = io.StringIO()
        with redirect_stdout(output), patch.object(sys, 'argv', [
            'ds-deploy-api.py', 'import', '-i', str(self.path), '--restore', '--dry-run',
        ]):
            self.assertEqual(self.api.main(), 0)
        self.assertEqual(self.ds.workflows, original)
        self.assertTrue(all(method == 'GET' for method, _, _ in self.ds.calls))
        self.assertIn('EXTRA', output.getvalue())
        self.assertIn('B → A', output.getvalue())

        # 普通导入仍支持增量合并。
        self.assertEqual(self.api.cmd_import(argparse.Namespace(input=str(self.path), dry_run=False)), 0)
        self.assertEqual(len(self.ds.workflows[101]['taskDefinitionList']), 3)
        for _ in range(2):
            with patch.object(sys, 'argv', [
                'ds-deploy-api.py', 'import', '-i', str(self.path), '--restore',
            ]):
                self.assertEqual(self.api.main(), 0)
            restored = self.ds.workflows[101]
            self.assertEqual([t['name'] for t in restored['taskDefinitionList']], ['A', 'B'])
            self.assertEqual([(r['preTaskCode'], r['postTaskCode'])
                              for r in restored['workflowTaskRelationList']], [(0, a), (a, b)])
            self.assertEqual(json.loads(restored['workflowDefinition']['globalParams']), [])
            self.assertEqual(self.ds.workflows[102], original[102])

    def test_restore_rejects_dependencies_on_removed_tasks_before_writes(self):
        self.assertEqual(self.run_import([{'name': 'UP', 'tasks': [shell('A'), shell('B')]}]), 0)
        self.path.write_text(json.dumps({'schema': self.api.SNAPSHOT_SCHEMA, 'workflows': [
            {'name': 'UP', 'tasks': [shell('A')], 'relations': [], 'globalParams': []},
            {'name': 'DOWN', 'tasks': [dependent('gate', 'UP', 'B')],
             'relations': [], 'globalParams': []},
        ]}), encoding='utf-8')
        for dry_run in (True, False):
            self.ds.calls.clear()
            self.assertEqual(self.api.cmd_import(argparse.Namespace(
                input=str(self.path), dry_run=dry_run, restore=True)), 1)
            self.assertTrue(all(method == 'GET' for method, _, _ in self.ds.calls))

    def test_restore_rejects_incomplete_snapshot_before_writes(self):
        for schema, workflow in (
            (self.api.SCHEMA, {'name': 'UP', 'tasks': [shell('A')]}),
            (self.api.SNAPSHOT_SCHEMA, {'name': 'UP', 'tasks': [shell('A')]}),
            (self.api.SNAPSHOT_SCHEMA, {'name': 'UP', 'tasks': [shell('A')],
                                       'relations': [['MISSING', 'A']], 'globalParams': []}),
        ):
            with self.subTest(schema=schema, workflow=workflow):
                self.path.write_text(json.dumps({'schema': schema, 'workflows': [workflow]}), encoding='utf-8')
                with patch.object(sys, 'argv', [
                    'ds-deploy-api.py', 'import', '-i', str(self.path), '--restore',
                ]):
                    self.assertEqual(self.api.main(), 1)
                self.assertEqual(self.ds.calls, [])

    def test_restore_rejects_outside_references_to_removed_tasks(self):
        self.assertEqual(self.run_import([
            {'name': 'UP', 'tasks': [shell('A'), shell('B')]},
            {'name': 'OUTSIDE', 'tasks': [dependent('gate', 'UP', 'B')]},
        ]), 0)
        self.path.write_text(json.dumps({'schema': self.api.SNAPSHOT_SCHEMA, 'workflows': [
            {'name': 'UP', 'tasks': [shell('A')], 'relations': [], 'globalParams': []},
        ]}), encoding='utf-8')
        original = copy.deepcopy(self.ds.workflows)
        self.ds.calls.clear()
        with self.assertRaisesRegex(ValueError, 'OUTSIDE/gate'):
            self.api.cmd_import(argparse.Namespace(input=str(self.path), dry_run=False, restore=True))
        self.assertEqual(self.ds.workflows, original)
        self.assertTrue(all(method == 'GET' for method, _, _ in self.ds.calls))

    def test_import_preserves_legacy_timeout_and_accepts_explicit_zero(self):
        workflow = {'name': 'UP', 'tasks': [shell('A')]}
        self.assertEqual(self.run_import([workflow]), 0)
        self.ds.workflows[101]['workflowDefinition']['timeout'] = 45
        self.assertEqual(self.run_import([workflow]), 0)
        self.assertEqual(self.ds.workflows[101]['workflowDefinition']['timeout'], 45)
        self.assertEqual(self.run_import([dict(workflow, timeout=0)]), 0)
        self.assertEqual(self.ds.workflows[101]['workflowDefinition']['timeout'], 0)

    def test_restore_validates_later_workflows_before_any_write(self):
        self.assertEqual(self.run_import([{'name': 'FIRST', 'tasks': [shell('ORIGINAL')]}]), 0)
        original = copy.deepcopy(self.ds.workflows)
        invalid_workflows = [
            {'name': 'LATER', 'tasks': [{'name': 'BROKEN', 'taskType': 'SHELL', 'taskParams': {}}]},
            {'name': 'LATER', 'tasks': [dict(shell('BROKEN'), script=42)]},
            {'name': 'LATER', 'tasks': [dict(shell('BROKEN'), taskParams=[])]},
            {'name': 'LATER', 'tasks': [shell('BROKEN')], 'locations': {'BROKEN': [10]}},
            {'name': 'LATER', 'tasks': [dependent('BROKEN', 'FIRST', 'REPLACEMENT')],
             'locations': {}, 'timeout': 'invalid'},
            {'name': 'LATER', 'tasks': [dict(dependent('BROKEN', 'FIRST', 'REPLACEMENT'),
                                           dependence={'dependTaskList': []})]},
            {'name': 'LATER', 'tasks': [dict(dependent('BROKEN', 'FIRST', 'REPLACEMENT'),
                                           dependence={'relation': 'AND', 'dependTaskList': [None]})]},
        ]
        for invalid in invalid_workflows:
            for dry_run in (True, False):
                with self.subTest(invalid=invalid, dry_run=dry_run):
                    workflows = [
                        {'name': 'FIRST', 'tasks': [shell('REPLACEMENT')], 'relations': [], 'globalParams': []},
                        dict(invalid, relations=[], globalParams=[]),
                    ]
                    self.path.write_text(json.dumps({'schema': self.api.SNAPSHOT_SCHEMA,
                                                     'workflows': workflows}), encoding='utf-8')
                    self.ds.calls.clear()
                    argv = ['ds-deploy-api.py', 'import', '-i', str(self.path), '--restore']
                    if dry_run:
                        argv.append('--dry-run')
                    with patch.object(sys, 'argv', argv), redirect_stdout(io.StringIO()):
                        self.assertEqual(self.api.main(), 1)
                    self.assertEqual(self.ds.workflows, original)
                    self.assertTrue(all(method == 'GET' for method, _, _ in self.ds.calls))

    def test_restore_rejects_non_object_documents(self):
        for doc in (None, [], 'invalid'):
            with self.subTest(doc=doc):
                self.path.write_text(json.dumps(doc), encoding='utf-8')
                with patch.object(sys, 'argv', [
                    'ds-deploy-api.py', 'import', '-i', str(self.path), '--restore',
                ]):
                    self.assertEqual(self.api.main(), 1)
                self.assertEqual(self.ds.calls, [])

    def test_import_does_not_publish_when_server_omits_a_shell_task(self):
        self.assertEqual(self.run_import([{'name': 'TARGET', 'tasks': [shell('ORIGINAL')]}]), 0)
        self.ds.workflows[101]['workflowDefinition']['releaseState'] = 'ONLINE'
        self.ds.schedules = [{'id': 1, 'workflowDefinitionCode': 101, 'releaseState': 'ONLINE'}]
        self.ds.calls.clear()
        original_call = self.ds.call

        def omit_task(method, path, params=None, form=None):
            response = original_call(method, path, params=params, form=form)
            if method == 'PUT' and path.endswith('/workflow-definition/101'):
                self.ds.workflows[101]['taskDefinitionList'] = [
                    t for t in self.ds.workflows[101]['taskDefinitionList'] if t['name'] != 'NEW']
            return response

        self.path.write_text(json.dumps({'schema': self.api.SCHEMA, 'workflows': [
            {'name': 'TARGET', 'tasks': [shell('NEW')]},
        ]}), encoding='utf-8')
        with patch.object(self.api.D, 'call', side_effect=omit_task), \
                patch.object(sys, 'argv', ['ds-deploy-api.py', 'import', '-i', str(self.path)]):
            self.assertEqual(self.api.main(), 1)
        self.assertEqual(self.ds.workflows[101]['workflowDefinition']['releaseState'], 'OFFLINE')
        self.assertFalse(any(path.endswith('/release') and form['releaseState'] == 'ONLINE'
                             for _, path, form in self.ds.calls))
        self.assertFalse(any('/schedules/' in path for _, path, _ in self.ds.calls))

    def test_restore_does_not_publish_when_server_keeps_extra_tasks(self):
        self.assertEqual(self.run_import([{'name': 'TARGET', 'tasks': [shell('ORIGINAL')]}]), 0)
        self.api.cmd_export(argparse.Namespace(match='', only='TARGET', out=str(self.path)))
        target = self.ds.workflows[101]
        target['workflowDefinition']['releaseState'] = 'ONLINE'
        self.ds.calls.clear()
        original_call = self.ds.call

        def keep_extra(method, path, params=None, form=None):
            response = original_call(method, path, params=params, form=form)
            if method == 'PUT' and path.endswith('/workflow-definition/101'):
                self.ds.workflows[101]['taskDefinitionList'].append(
                    dict(target['taskDefinitionList'][0], name='EXTRA', code=99999))
            return response

        with patch.object(self.api.D, 'call', side_effect=keep_extra), \
                patch.object(sys, 'argv', [
                    'ds-deploy-api.py', 'import', '-i', str(self.path), '--restore',
                ]):
            self.assertEqual(self.api.main(), 1)
        self.assertEqual(self.ds.workflows[101]['workflowDefinition']['releaseState'], 'OFFLINE')
        self.assertFalse(any(path.endswith('/release') and form['releaseState'] == 'ONLINE'
                             for _, path, form in self.ds.calls))


class TestSerialTracking(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.runner = load_script('ds-run.py')

    def run_serial(self, states, trigger=None, end_time=None):
        runner = self.runner
        ds = Mock()
        ds.call.side_effect = [{'code': 0, 'data': {'id': 77, 'state': state, 'endTime': end_time}}
                               for state in states]
        args = argparse.Namespace(
            min_mem=0, order='hsfa', only=None, start_from=None, no_skip_success=True,
            apply=True, mem_wait=1, poll=0, failure_strategy='CONTINUE', max_min=1)
        reports = []
        with patch.object(runner, 'DSClient', return_value=ds), \
                patch.object(runner, 'ds_service_password', return_value='test-only'), \
                patch.object(runner, 'project_code_of', return_value=22), \
                patch.object(runner, 'all_workflows', return_value={'ods_hsfa_etl_01': 33}), \
                patch.object(runner, '_running', return_value=[]), \
                patch.object(runner, 'vm_mem_gb', return_value=10), \
                patch.object(runner, '_ensure_online', return_value=True), \
                patch.object(runner, '_trigger_wf', return_value=trigger or {'code': 0, 'data': [77]}), \
                patch.object(runner, '_latest', side_effect=AssertionError('同名历史实例不得参与跟踪')), \
                patch.object(runner, '_tasks_of', return_value=[{'name': 'T', 'state': states[-1]}]), \
                patch.object(runner.time, 'sleep'), \
                patch.object(runner.time, 'monotonic', side_effect=[0, 61, 62]), \
                patch.object(runner, '_save_report', side_effect=lambda path, rep: reports.append(copy.deepcopy(rep))):
            rc = runner._serial(args, 'ods')
        return rc, reports, ds

    def test_last_workflow_is_followed_through_timeout_to_success(self):
        rc, reports, ds = self.run_serial(['RUNNING_EXECUTION', 'SUCCESS'])
        self.assertEqual(rc, 0)
        self.assertEqual(reports[0]['workflows'][0]['instanceId'], 77)
        final = reports[-1]['workflows'][0]
        self.assertEqual(final['state'], 'SUCCESS')
        self.assertTrue(final['waitTimedOut'])
        self.assertEqual(final['taskOk'], 1)
        self.assertEqual([call.args[1] for call in ds.call.call_args_list],
                         ['/projects/22/workflow-instances/77'] * 2)

    def test_terminal_failure_returns_nonzero(self):
        rc, reports, _ = self.run_serial(['FAILURE'])
        self.assertEqual(rc, 1)
        self.assertEqual(reports[-1]['workflows'][0]['state'], 'FAILURE')

    def test_missing_trigger_id_stops_followup(self):
        rc, reports, ds = self.run_serial(['SUCCESS'], trigger={'code': 0, 'data': []})
        self.assertEqual(rc, 1)
        self.assertEqual(reports[-1]['workflows'][0]['state'], 'INSTANCE_ID_MISSING')
        ds.call.assert_not_called()

    def test_ended_instance_with_other_state_does_not_wait_forever(self):
        rc, reports, ds = self.run_serial(['CANCELED'], end_time='2026-11-22 12:00:00')
        self.assertEqual(rc, 1)
        self.assertEqual(reports[-1]['workflows'][0]['state'], 'CANCELED')
        self.assertEqual(ds.call.call_count, 1)

    def test_task_results_are_strictly_scoped_to_instance(self):
        ds = Mock()
        ds.call.return_value = {'code': 0, 'data': {'totalList': [
            {'workflowInstanceId': 77, 'name': 'CURRENT'},
            {'workflowInstanceId': 76, 'name': 'HISTORY'},
        ]}}
        self.assertEqual([t['name'] for t in self.runner._tasks_of(ds, 22, 77)], ['CURRENT'])
        ds.call.return_value = {'code': 1}
        with self.assertRaisesRegex(RuntimeError, '回查失败'):
            self.runner._tasks_of(ds, 22, 77)


if __name__ == '__main__':
    unittest.main()
