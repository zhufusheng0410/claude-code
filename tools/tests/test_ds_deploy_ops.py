# -*- coding: utf-8 -*-
"""DS 运维工具隔离单测：ds_common、ds-inspect、ds-sync-scripts 与 ds-wipe-workflows 范围护栏。

全部使用 mock / 临时目录，不连接真实 DolphinScheduler、Hive 或 PostgreSQL。
"""
import importlib.util
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

ROOT = Path(__file__).resolve().parents[2]
DEPLOY_DIR = ROOT / "tools" / "ds-deploy"

_DUMMY_ENV = {
    "DS_PASSWORD": "test-dummy-not-real",
    "DS_ADMIN_PASSWORD": "test-dummy-not-real",
    "DS_PG_PASSWORD": "test-dummy-not-real",
    "DS_HIVE_PASSWORD": "test-dummy-not-real",
}


def _load_deploy(filename: str, modname: str):
    if str(DEPLOY_DIR) not in sys.path:
        sys.path.insert(0, str(DEPLOY_DIR))
    path = DEPLOY_DIR / filename
    with patch.dict(os.environ, _DUMMY_ENV):
        spec = importlib.util.spec_from_file_location(modname, path)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        return mod


class TestDsCommon(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.common = _load_deploy("ds_common.py", "_test_ds_common")

    def test_parse_json_list(self):
        self.assertEqual(self.common.parse_json_list('[1, 2]'), [1, 2])
        self.assertEqual(self.common.parse_json_list('not-json'), [])
        self.assertEqual(self.common.parse_json_list(None), [])
        self.assertEqual(self.common.parse_json_list(['a']), ['a'])
        # 与各脚本原 j() 一致：JSON 对象原样返回，不能被改写成 []
        self.assertEqual(self.common.parse_json_list('{}'), {})
        self.assertEqual(self.common.parse_json_list('{"a": 1}'), {"a": 1})

    def test_error_tuples_cover_external_failures_only(self):
        ds_client = _load_deploy("ds_client.py", "_test_ds_client_for_errors")
        # DSClientError 与 drop_wf 抛出的 RuntimeError 必须被视为「外部失败」
        self.assertTrue(issubclass(ds_client.DSClientError, self.common.DS_CALL_ERRORS))
        self.assertTrue(issubclass(RuntimeError, self.common.DS_CALL_ERRORS))
        self.assertTrue(issubclass(TimeoutError, self.common.DS_CALL_ERRORS))
        # beeline() 准备口令文件失败抛 RuntimeError
        self.assertTrue(issubclass(RuntimeError, self.common.SUBPROCESS_ERRORS))
        self.assertTrue(issubclass(subprocess.TimeoutExpired, self.common.SUBPROCESS_ERRORS))
        # 编程错误必须穿透
        for exc in (TypeError, AttributeError, KeyError, NameError):
            self.assertFalse(issubclass(exc, self.common.DS_CALL_ERRORS), exc)
            self.assertFalse(issubclass(exc, self.common.SUBPROCESS_ERRORS), exc)

    def test_snapshot_online_schedules_modes_and_error(self):
        fake = MagicMock(stdout="101\n202\nbad\n\n")
        with patch.object(self.common.subprocess, "run", return_value=fake):
            self.assertEqual(
                self.common.snapshot_online_schedules(docker="docker", as_int=True),
                {101, 202},
            )
            self.assertEqual(
                self.common.snapshot_online_schedules(docker="docker", as_int=False),
                {"101", "202", "bad"},
            )
        with patch.object(
            self.common.subprocess, "run", side_effect=OSError("docker unavailable")
        ):
            self.assertEqual(
                self.common.snapshot_online_schedules(docker="docker", as_int=True),
                set(),
            )

    def test_set_schedule_state_validates_inputs(self):
        with patch.object(self.common.subprocess, "run") as mock_run:
            self.assertTrue(self.common.set_schedule_state("42", 1, docker="docker"))
            args = mock_run.call_args[0][0]
            self.assertIn("release_state=1 where id=42", args[-1])

        # 非法状态或 SQL 注入字符必须拒绝
        with self.assertRaises(ValueError):
            self.common.set_schedule_state(42, 2, docker="docker")
        with self.assertRaises(ValueError):
            self.common.set_schedule_state("42; DROP TABLE x", 1, docker="docker")


class TestDsInspectAndSyncWrappers(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.inspect = _load_deploy("ds-inspect.py", "_test_ds_inspect")
        cls.sync = _load_deploy("ds-sync-scripts.py", "_test_ds_sync_scripts")

    def test_inspect_dispatch_and_exit_code(self):
        calls = []

        def fake_run(cmd):
            calls.append(cmd)
            return MagicMock(returncode=0)

        with patch.object(self.inspect.subprocess, "run", side_effect=fake_run):
            self.assertEqual(self.inspect.main(["running", "--all"]), 0)
            self.assertEqual(self.inspect.main(["tables"]), 0)
            self.assertEqual(self.inspect.main(["all"]), 0)

        self.assertTrue(calls[0][1].endswith("ds-check-running.py"))
        self.assertIn("--all", calls[0])
        self.assertTrue(calls[1][1].endswith("ds-check-tables-exist.py"))
        self.assertTrue(calls[2][1].endswith("ds-check-running.py"))
        self.assertTrue(calls[3][1].endswith("ds-check-tables-exist.py"))

    def test_inspect_all_propagates_failure(self):
        rcs = iter([1, 0])
        with patch.object(
            self.inspect.subprocess,
            "run",
            side_effect=lambda cmd: MagicMock(returncode=next(rcs)),
        ):
            self.assertEqual(self.inspect.main(["all"]), 1)

    def test_sync_scripts_routing(self):
        cmd_ods = self.sync.build_command("ods", ["--sys", "O32", "--apply"])
        self.assertTrue(cmd_ods[1].endswith("ds-sync-ods-scripts.py"))
        self.assertEqual(cmd_ods[2:], ["--sys", "O32", "--apply"])

        cmd_dwd = self.sync.build_command("DWD", ["--apply"])
        self.assertTrue(cmd_dwd[1].endswith("ds-sync-dwd-scripts.py"))
        self.assertEqual(cmd_dwd[2:], ["--layer", "DWD", "--apply"])

        cmd_dws = self.sync.build_command("dws", [])
        self.assertTrue(cmd_dws[1].endswith("ds-sync-dwd-scripts.py"))
        self.assertEqual(cmd_dws[2:], ["--layer", "DWS"])

        with self.assertRaises(ValueError):
            self.sync.build_command("ADS", [])


class TestRunDwdEtlDirectBeelineFailure(unittest.TestCase):
    """beeline() 准备口令文件失败抛 RuntimeError 时，单表记失败，整批不得崩溃。"""

    def test_runtime_error_marks_table_failed(self):
        mod = _load_deploy("run-dwd-etl-direct.py", "_test_run_dwd_etl_direct")
        logs = []
        with (
            patch.object(mod, "wait_mem", return_value=None),
            patch.object(mod.V, "beeline",
                         side_effect=RuntimeError("无法在容器内准备 Hive 口令文件（exit 1）")),
        ):
            results = mod.run_etls(
                ["DWD_A", "DWD_B"],
                {0: ["DWD_A", "DWD_B"]},
                {"DWD_A": "SELECT 1", "DWD_B": "SELECT 2"},
                "20261010", 60, 1, 0, logs.append,
            )
        self.assertEqual([r["table"] for r in results], ["DWD_A", "DWD_B"])
        for r in results:
            self.assertFalse(r["ok"])
            self.assertIn("执行异常", r["msg"])


class TestDsRunHiveSql(unittest.TestCase):
    """核验 ds-run-hive-sql.py 的失败退出码传递与清理容错，不连接真实 DS/Hive。"""

    def setUp(self):
        self.mod = _load_deploy("ds-run-hive-sql.py", "_test_ds_run_hive_sql")

    def test_project_create_failure_returns_2(self):
        def fake_call(method, path, **kw):
            if path == "/projects/list":
                return {"code": 0, "data": []}
            if method == "POST" and path == "/projects":
                return {"code": 50001, "msg": "quota", "data": None}
            raise AssertionError(f"unexpected {method} {path}")

        with (
            patch.object(sys, "argv", ["ds-run-hive-sql.py", "select 1"]),
            patch.object(self.mod, "login", return_value="sid"),
            patch.object(self.mod, "call", side_effect=fake_call),
        ):
            self.assertEqual(self.mod.main(), 2)

    def test_missing_datasource_returns_2(self):
        def fake_call(method, path, **kw):
            if path == "/projects/list":
                return {"code": 0, "data": [{"name": "hive_ds_verify", "code": 7}]}
            if path == "/datasources/list":
                return {"code": 0, "data": []}
            raise AssertionError(f"unexpected {method} {path}")

        with (
            patch.object(sys, "argv", ["ds-run-hive-sql.py", "--datasource", "missing_ds"]),
            patch.object(self.mod, "login", return_value="sid"),
            patch.object(self.mod, "call", side_effect=fake_call),
        ):
            self.assertEqual(self.mod.main(), 2)

    def test_failure_state_returns_1_even_if_cleanup_errors(self):
        def fake_call(method, path, **kw):
            if path == "/projects/list":
                return {"code": 0, "data": [{"name": "hive_ds_verify", "code": 7}]}
            if path == "/datasources/list":
                return {"code": 0, "data": [{"name": "hive_krb", "id": 3}]}
            if method == "POST" and path == "/projects/7/workflow-definition":
                return {"code": 0, "data": {"code": 555}}
            if path == "/projects/7/workflow-definition/555/release":
                if (kw.get("form") or {}).get("releaseState") == "OFFLINE":
                    raise OSError("cleanup network blip")
                return {"code": 0}
            if path == "/projects/7/executors/start-workflow-instance":
                return {"code": 0, "data": [888]}
            if path == "/projects/7/workflow-instances/888":
                return {"code": 0, "data": {"state": "FAILURE"}}
            return {"code": 0}

        with (
            patch.object(sys, "argv", ["ds-run-hive-sql.py", "select 1"]),
            patch.object(self.mod, "login", return_value="sid"),
            patch.object(self.mod, "call", side_effect=fake_call),
            patch.object(self.mod.time, "sleep", return_value=None),
        ):
            self.assertEqual(self.mod.main(), 1)

    def test_success_state_returns_0_and_cleans_up(self):
        deleted = []

        def fake_call(method, path, **kw):
            if path == "/projects/list":
                return {"code": 0, "data": [{"name": "hive_ds_verify", "code": 7}]}
            if path == "/datasources/list":
                return {"code": 0, "data": [{"name": "hive_krb", "id": 3}]}
            if method == "POST" and path == "/projects/7/workflow-definition":
                return {"code": 0, "data": {"code": 555}}
            if path == "/projects/7/workflow-definition/555/release":
                return {"code": 0}
            if method == "DELETE" and path == "/projects/7/workflow-definition/555":
                deleted.append(path)
                return {"code": 0}
            if path == "/projects/7/executors/start-workflow-instance":
                return {"code": 0, "data": [888]}
            if path == "/projects/7/workflow-instances/888":
                return {"code": 0, "data": {"state": "SUCCESS"}}
            return {"code": 0}

        with (
            patch.object(sys, "argv", ["ds-run-hive-sql.py", "select 1"]),
            patch.object(self.mod, "login", return_value="sid"),
            patch.object(self.mod, "call", side_effect=fake_call),
            patch.object(self.mod.time, "sleep", return_value=None),
        ):
            self.assertEqual(self.mod.main(), 0)
        self.assertEqual(deleted, ["/projects/7/workflow-definition/555"])


class TestDsWipeWorkflowsGuards(unittest.TestCase):
    """核验破坏性脚本 ds-wipe-workflows.py 的 dry-run、备份门控、范围限制与 SQL 防误删护栏。"""

    def setUp(self):
        self.wipe = _load_deploy("ds-wipe-workflows.py", "_test_ds_wipe")
        self.tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.tmp, True)
        self.backup_file = os.path.join(self.tmp, "backup.sql")
        Path(self.backup_file).write_text("-- backup", encoding="utf-8")

        self.sample_wfs = [
            {"name": "ods_o32_etl_01", "code": 1001, "releaseState": "OFFLINE"},
            {"name": "DWD_AST", "code": 2001, "releaseState": "OFFLINE"},
            {"name": "DWD_PROD", "code": 2002, "releaseState": "OFFLINE"},
        ]

    def _run_wipe(self, argv, rest_side_effect=None, psql_side_effect=None):
        def default_rest(method, path, params=None, form=None, sid=None):
            if path == "/projects/list":
                return {"code": 0, "data": [{"name": "dw", "code": 99}]}
            if rest_side_effect is not None:
                return rest_side_effect(method, path, params=params, form=form, sid=sid)
            return {"code": 0, "data": None}

        with (
            patch.object(sys, "argv", ["ds-wipe-workflows.py", *argv]),
            patch.object(self.wipe, "login", return_value="sid-1"),
            patch.object(self.wipe, "list_workflows", return_value=list(self.sample_wfs)),
            patch.object(self.wipe, "_rest", side_effect=default_rest) as mock_rest,
            patch.object(
                self.wipe,
                "psql",
                side_effect=psql_side_effect or (lambda sql: (0, "0")),
            ) as mock_psql,
        ):
            rc = self.wipe.main()
            return rc, mock_rest, mock_psql

    def test_dry_run_makes_no_delete_calls(self):
        rc, mock_rest, mock_psql = self._run_wipe([])
        self.assertEqual(rc, 0)
        methods = [c.args[0] for c in mock_rest.call_args_list]
        self.assertNotIn("DELETE", methods)
        mock_psql.assert_not_called()

    def test_apply_requires_existing_backup(self):
        rc1, mock_rest1, _ = self._run_wipe(["--apply"])
        self.assertEqual(rc1, 2)
        self.assertNotIn("DELETE", [c.args[0] for c in mock_rest1.call_args_list])

        rc2, mock_rest2, _ = self._run_wipe(
            ["--apply", "--backup", os.path.join(self.tmp, "missing.sql")]
        )
        self.assertEqual(rc2, 2)
        self.assertNotIn("DELETE", [c.args[0] for c in mock_rest2.call_args_list])

    def test_only_restricts_actual_deleted_workflows(self):
        deleted_paths = []

        def on_rest(method, path, **kw):
            if method == "DELETE":
                deleted_paths.append(path)
            return {"code": 0}

        rc, _, mock_psql = self._run_wipe(
            ["--apply", "--backup", self.backup_file, "--only", "^DWD_"],
            rest_side_effect=on_rest,
        )
        self.assertEqual(rc, 0)
        self.assertEqual(
            deleted_paths,
            [
                "/projects/99/workflow-definition/2001",
                "/projects/99/workflow-definition/2002",
            ],
        )
        # 不得删除未匹配的 ods_o32_etl_01 (1001)
        self.assertFalse(any("1001" in p for p in deleted_paths))

    def test_sql_fallback_refuses_zero_task_codes(self):
        def fail_delete(method, path, **kw):
            if method == "DELETE":
                return {"code": 50000, "msg": "cycle"}
            return {"code": 0}

        executed_sql = []

        def fake_psql(sql):
            executed_sql.append(sql)
            return (0, "")  # 收集到 0 个 task code

        rc, _, _ = self._run_wipe(
            ["--apply", "--backup", self.backup_file, "--only", "^DWD_AST$"],
            rest_side_effect=fail_delete,
            psql_side_effect=fake_psql,
        )
        self.assertEqual(rc, 1)
        # 只执行了收集查询，绝不能执行 DELETE FROM t_ds_workflow_definition
        self.assertEqual(len(executed_sql), 1)
        self.assertNotIn("DELETE FROM", executed_sql[0])


if __name__ == "__main__":
    unittest.main()
