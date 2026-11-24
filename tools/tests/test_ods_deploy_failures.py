# -*- coding: utf-8 -*-
"""ODS 部署失败时立即退出，避免继续改动后续工作流。"""
import contextlib
import importlib
import importlib.util
import io
import pathlib
import sys
import unittest
from unittest import mock


_DEPLOY = pathlib.Path(__file__).resolve().parents[1] / "ds-deploy"


def _load_module():
    with mock.patch.object(sys, "path", [str(_DEPLOY), *sys.path]):
        config = importlib.import_module("ds_config")
        spec = importlib.util.spec_from_file_location(
            "ods_deploy_failures", _DEPLOY / "ds-deploy-ods-all.py")
        module = importlib.util.module_from_spec(spec)
        with mock.patch.object(config, "ds_admin_password",
                               return_value=mock.sentinel.admin_password):
            spec.loader.exec_module(module)
    return module


class TestOdsDeployFailures(unittest.TestCase):
    def setUp(self):
        self.module = _load_module()
        patches = {
            "_client": mock.Mock(side_effect=AssertionError("不应连接 DS")),
            "login": mock.Mock(),
            "ensure_project": mock.Mock(return_value=123),
            "collect": mock.Mock(return_value=[
                ("ODS_O32_FIRST_PFD", "first.sh"),
                ("ODS_O32_SECOND_PFD", "second.sh"),
            ]),
            "build_task": mock.Mock(side_effect=lambda code, name, path: {
                "code": code, "name": name,
            }),
            "drop_wf": mock.Mock(),
            "list_wf": mock.Mock(side_effect=lambda project, name: [
                {"name": name, "code": 501 if name.endswith("01") else 502},
            ]),
            "call": mock.Mock(return_value={"code": 0, "data": {"code": 501}}),
        }
        self.patches = mock.patch.multiple(self.module, **patches)
        self.patches.start()
        self.addCleanup(self.patches.stop)

    def run_main(self, *options):
        argv = ["ds-deploy-ods-all.py", "--systems", "O32", "--size", "1", *options]
        with mock.patch.object(sys, "argv", argv), contextlib.redirect_stdout(io.StringIO()):
            return self.module.main()

    def test_creation_failure_stops_later_creation_and_online(self):
        self.module.call.return_value = {"code": 10000, "msg": "create failed"}

        self.assertEqual(self.run_main(), 1)

        self.module.drop_wf.assert_called_once_with(123, "ods_o32_etl_01")
        self.module.call.assert_called_once()
        self.module.list_wf.assert_not_called()

    def test_offline_creation_failure_returns_nonzero(self):
        self.module.call.return_value = {"code": 10000, "msg": "create failed"}

        self.assertEqual(self.run_main("--offline"), 1)

        self.module.call.assert_called_once()

    def test_later_creation_failure_keeps_created_workflow_offline(self):
        self.module.call.side_effect = [
            {"code": 0, "data": {"code": 501}},
            {"code": 10000, "msg": "create failed"},
        ]

        self.assertEqual(self.run_main(), 1)

        self.assertEqual(self.module.call.call_count, 2)
        self.module.list_wf.assert_not_called()

    def test_online_failure_stops_later_release(self):
        self.module.call.side_effect = [
            {"code": 0, "data": {"code": 501}},
            {"code": 0, "data": {"code": 502}},
            {"code": 10000, "msg": "release failed"},
            {"code": 0},
        ]

        self.assertEqual(self.run_main(), 1)

        self.assertEqual(self.module.call.call_count, 3)
        self.module.list_wf.assert_called_once_with(123, "ods_o32_etl_01")

    def test_missing_created_workflow_stops_online(self):
        self.module.list_wf.return_value = []
        self.module.list_wf.side_effect = None

        self.assertEqual(self.run_main(), 1)

        self.assertEqual(self.module.call.call_count, 2)
        self.module.list_wf.assert_called_once_with(123, "ods_o32_etl_01")

    def test_successful_offline_deployment_keeps_workflows_offline(self):
        self.assertEqual(self.run_main("--offline"), 0)

        self.assertEqual(self.module.call.call_count, 2)
        self.module.list_wf.assert_not_called()

    def test_successful_online_deployment_returns_zero(self):
        self.assertEqual(self.run_main(), 0)

        self.assertEqual(self.module.call.call_count, 4)
        self.assertEqual(self.module.list_wf.call_count, 2)

    def test_dry_run_does_not_connect_or_write(self):
        self.assertEqual(self.run_main("--dry-run"), 0)

        self.module.login.assert_not_called()
        self.module.call.assert_not_called()
        self.module.drop_wf.assert_not_called()


class TestOdsWorkflowCleanup(unittest.TestCase):
    def setUp(self):
        self.module = _load_module()
        client = mock.patch.object(
            self.module, "_client", side_effect=AssertionError("不应连接 DS"))
        client.start()
        self.addCleanup(client.stop)

    def test_failed_offline_does_not_delete_existing_workflow(self):
        with mock.patch.object(self.module, "list_wf", return_value=[{
            "name": "ods_o32_etl_01", "code": 501,
            "releaseState": "ONLINE",
        }]), mock.patch.object(self.module, "call", return_value={
            "code": 10000, "msg": "offline failed",
        }) as api, contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(SystemExit) as caught:
                self.module.drop_wf(123, "ods_o32_etl_01")

        self.assertNotEqual(caught.exception.code, 0)
        api.assert_called_once_with(
            "POST", "/projects/123/workflow-definition/501/release",
            form={"releaseState": "OFFLINE"})

    def test_failed_lookup_does_not_treat_workflow_as_missing(self):
        with mock.patch.object(self.module, "call", return_value={
            "code": 10000, "msg": "lookup failed",
        }) as api:
            with self.assertRaises(SystemExit) as caught:
                self.module.drop_wf(123, "ods_o32_etl_01")

        self.assertNotEqual(caught.exception.code, 0)
        api.assert_called_once()


if __name__ == "__main__":
    unittest.main()
