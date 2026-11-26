# -*- coding: utf-8 -*-
"""DS 排版/布局校验、plan 归属口径与核心叶片模块隔离单测。

全部使用 mock / 临时目录，不连接真实 DolphinScheduler、Hive 或 PostgreSQL。
"""
import argparse
import contextlib
import importlib.util
import io
import json
import os
import sys
import tempfile
import types
import unittest
from pathlib import Path
from unittest.mock import patch

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


class TestDsRelayout(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mod = _load_deploy("ds-relayout.py", "_test_ds_relayout")

    def setUp(self):
        if hasattr(self.mod.pcode, "_c"):
            delattr(self.mod.pcode, "_c")

    def _dwd_detail(self, tasks, locs, state="ONLINE"):
        return {
            "code": 0,
            "data": {
                "workflowDefinition": {
                    "name": "DWD_TEST",
                    "locations": json.dumps(locs),
                    "releaseState": state,
                },
                "taskDefinitionList": tasks,
                "workflowTaskRelationList": [],
            },
        }

    def test_dwd_skips_when_fully_placed_and_compliant(self):
        col_w = 500
        pair_gap = 2 * col_w + 120
        tasks = [
            {"code": 1, "name": "dep_DWD_A", "taskType": "DEPENDENT", "taskParams": {}},
            {"code": 2, "name": "DWD_A", "taskType": "SHELL", "taskParams": {}},
            {"code": 3, "name": "dep_DWD_B", "taskType": "DEPENDENT", "taskParams": {}},
            {"code": 4, "name": "DWD_B", "taskType": "SHELL", "taskParams": {}},
        ]
        locs = [
            {"taskCode": 1, "x": 40, "y": 80},
            {"taskCode": 2, "x": 40 + col_w, "y": 80},
            {"taskCode": 3, "x": 40 + pair_gap, "y": 80},
            {"taskCode": 4, "x": 40 + pair_gap + col_w, "y": 80},
        ]
        args = argparse.Namespace(col_w=col_w, force=False, apply=False)
        calls = []

        def fake_call(method, path, **_kw):
            calls.append(method)
            return self._dwd_detail(tasks, locs)

        with patch.object(self.mod.D, "call", side_effect=fake_call):
            msg = self.mod._relayout_dwd_one(99, {"code": 7, "name": "DWD_TEST"}, args)

        self.assertIn("已达标", msg)
        self.assertIn("跳过", msg)
        self.assertEqual(calls, ["GET"])

    def test_dwd_does_not_false_skip_empty_or_partial_locations(self):
        """回归：空 locations 或部分任务缺坐标时不得被误判为「已达标」跳过。"""
        tasks = [
            {"code": 1, "name": "dep_DWD_A", "taskType": "DEPENDENT", "taskParams": {}},
            {"code": 2, "name": "DWD_A", "taskType": "SHELL", "taskParams": {}},
            {"code": 3, "name": "dep_DWD_B", "taskType": "DEPENDENT", "taskParams": {}},
            {"code": 4, "name": "DWD_B", "taskType": "SHELL", "taskParams": {}},
        ]
        args = argparse.Namespace(col_w=500, force=False, apply=False)

        # 空 locations
        with patch.object(self.mod.D, "call", return_value=self._dwd_detail(tasks, [])):
            msg_empty = self.mod._relayout_dwd_one(99, {"code": 7, "name": "DWD_TEST"}, args)
        self.assertIn("(dry-run)", msg_empty)
        self.assertNotIn("跳过", msg_empty)

        # 部分任务缺失坐标（仅第 1 对合规）
        partial_locs = [
            {"taskCode": 1, "x": 40, "y": 80},
            {"taskCode": 2, "x": 540, "y": 80},
        ]
        with patch.object(self.mod.D, "call", return_value=self._dwd_detail(tasks, partial_locs)):
            msg_partial = self.mod._relayout_dwd_one(99, {"code": 7, "name": "DWD_TEST"}, args)
        self.assertIn("(dry-run)", msg_partial)
        self.assertNotIn("跳过", msg_partial)

    def test_dwd_apply_submits_offline_put_online_and_restores_schedules(self):
        tasks = [
            {"code": 1, "name": "dep_DWD_A", "taskType": "DEPENDENT", "taskParams": {}},
            {"code": 2, "name": "DWD_A", "taskType": "SHELL", "taskParams": {}},
        ]
        args = argparse.Namespace(col_w=500, force=True, apply=True)
        ops = []

        def fake_call(method, path, **kw):
            ops.append((method, path, (kw.get("form") or {}).get("releaseState")))
            if method == "GET":
                return self._dwd_detail(tasks, [], state="ONLINE")
            return {"code": 0}

        restored = []
        with patch.object(self.mod.D, "call", side_effect=fake_call), \
             patch.object(self.mod.SYNC, "snapshot_online_schedules", return_value={20, 10}), \
             patch.object(self.mod.SYNC, "set_schedule", side_effect=lambda sid, st: restored.append((sid, st))):
            msg = self.mod._relayout_dwd_one(99, {"code": 7, "name": "DWD_TEST"}, args)

        self.assertIn("已提交", msg)
        self.assertEqual(
            ops,
            [
                ("GET", "/projects/99/workflow-definition/7", None),
                ("POST", "/projects/99/workflow-definition/7/release", "OFFLINE"),
                ("PUT", "/projects/99/workflow-definition/7", "OFFLINE"),
                ("POST", "/projects/99/workflow-definition/7/release", "ONLINE"),
            ],
        )
        self.assertEqual(restored, [(10, 1), (20, 1)])

    def test_ods_skips_single_column_and_fixes_stacked_or_unplaced(self):
        """回归：单任务 ODS 达标应跳过；多任务叠压在同一列或缺失坐标时不得跳过。"""
        x0 = self.mod.D.X0
        args = argparse.Namespace(col_w=416, per_row=3, force=False, apply=False)

        # 单任务且坐标已在 X0 → 跳过
        t1 = [{"code": 1, "name": "ODS_A", "taskType": "SHELL"}]
        l1 = [{"taskCode": 1, "x": x0, "y": 80}]
        with patch.object(self.mod.D, "call", return_value=self._dwd_detail(t1, l1)):
            msg1 = self.mod._relayout_ods_one(99, {"code": 8, "name": "ods_o32_etl_01"}, args)
        self.assertIn("跳过", msg1)

        # 2 个任务叠压在同一 X 列 → 不跳过
        t2 = [
            {"code": 1, "name": "ODS_A", "taskType": "SHELL"},
            {"code": 2, "name": "ODS_B", "taskType": "SHELL"},
        ]
        l2_stacked = [
            {"taskCode": 1, "x": x0, "y": 80},
            {"taskCode": 2, "x": x0, "y": 200},
        ]
        with patch.object(self.mod.D, "call", return_value=self._dwd_detail(t2, l2_stacked)):
            msg2 = self.mod._relayout_ods_one(99, {"code": 8, "name": "ods_o32_etl_01"}, args)
        self.assertIn("(dry-run)", msg2)
        self.assertNotIn("跳过", msg2)

        # 3 个任务缺 1 个坐标 → 不跳过
        t3 = [
            {"code": 1, "name": "ODS_A", "taskType": "SHELL"},
            {"code": 2, "name": "ODS_B", "taskType": "SHELL"},
            {"code": 3, "name": "ODS_C", "taskType": "SHELL"},
        ]
        l3_missing = [
            {"taskCode": 1, "x": x0, "y": 80},
            {"taskCode": 2, "x": x0 + 416, "y": 80},
        ]
        with patch.object(self.mod.D, "call", return_value=self._dwd_detail(t3, l3_missing)):
            msg3 = self.mod._relayout_ods_one(99, {"code": 8, "name": "ods_o32_etl_01"}, args)
        self.assertIn("(dry-run)", msg3)
        self.assertNotIn("跳过", msg3)


class TestDsVerifyDwdLayout(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mod = _load_deploy("ds-verify-dwd-layout.py", "_test_ds_verify_layout")

    def test_cross_geometry(self):
        self.assertTrue(self.mod.cross((0, 0, 10, 10), (0, 10, 10, 0)))
        self.assertFalse(self.mod.cross((0, 0, 10, 0), (0, 10, 10, 10)))
        # 共用端点不算真交叉
        self.assertFalse(self.mod.cross((0, 0, 10, 10), (0, 0, 10, 0)))

    def test_strict_1to1_controls_exit_code_and_uses_ds_project(self):
        """回归：默认缺 dep_ 控件仅提示并返回 0，仅 --strict-1to1 返回 1；项目名读 DS_PROJECT；孤儿坐标不 KeyError。"""
        def fake_raw(method, path, params=None, form=None):
            if path == "/projects/list":
                return {"code": 0, "data": [{"name": "custom_proj", "code": 77}]}
            if path == "/projects/77/workflow-definition":
                return {"code": 0, "data": [{"name": "DWD_TEST", "code": 500, "releaseState": "ONLINE"}]}
            if path == "/projects/77/workflow-definition/500":
                return {
                    "code": 0,
                    "data": {
                        "workflowDefinition": {
                            "name": "DWD_TEST",
                            "locations": json.dumps([
                                {"taskCode": 1, "x": 40, "y": 80},
                                {"taskCode": 2, "x": 540, "y": 80},
                                {"taskCode": 3, "x": 1160, "y": 80},
                                {"taskCode": 9999, "x": 40, "y": 200},  # 孤儿 taskCode
                            ]),
                        },
                        "taskDefinitionList": [
                            {"code": 1, "name": "dep_DWD_TEST_A", "taskType": "DEPENDENT"},
                            {"code": 2, "name": "DWD_TEST_A", "taskType": "SHELL"},
                            {"code": 3, "name": "DWD_TEST_B", "taskType": "SHELL"},
                        ],
                        "workflowTaskRelationList": [
                            {"preTaskCode": 0, "postTaskCode": 1},
                            {"preTaskCode": 1, "postTaskCode": 2},
                            {"preTaskCode": 0, "postTaskCode": 3},
                        ],
                    },
                }
            raise AssertionError(f"unexpected call: {method} {path}")

        with patch.dict(os.environ, {"DS_PROJECT": "custom_proj"}), \
             patch.object(self.mod, "relogin"), \
             patch.object(self.mod, "raw", side_effect=fake_raw):
            buf_default = io.StringIO()
            with patch.object(sys, "argv", ["ds-verify-dwd-layout.py", "--workflow", "DWD_TEST"]), \
                 contextlib.redirect_stdout(buf_default):
                rc_default = self.mod.main()

            buf_strict = io.StringIO()
            with patch.object(sys, "argv", ["ds-verify-dwd-layout.py", "--workflow", "DWD_TEST", "--strict-1to1"]), \
                 contextlib.redirect_stdout(buf_strict):
                rc_strict = self.mod.main()

        self.assertEqual(rc_default, 0)
        self.assertEqual(rc_strict, 1)
        self.assertIn("9999", buf_default.getvalue())


class TestDsDeployApiPlanOwnership(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = _load_deploy("ds-deploy-api.py", "_test_ds_deploy_api_plan")

    def test_plan_respects_workflow_override_and_subject_filter(self):
        """回归：cmd_plan 必须遵循 WORKFLOW_OVERRIDE，将两张例外表归入 DWD_PROD。"""
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            depcfg = root / "depcfg"
            depcfg.mkdir()
            scripts_dir = root / "scripts" / "O32" / "dwd" / "02_etl"
            scripts_dir.mkdir(parents=True)

            tables = [
                ("DWD_PTY_OPER_FUND_PRVL_PFD", "DWD_PROD"),
                ("DWD_CMM_INTR_PARA_PFD", None),  # 省略 own_workflow，验证回退到 own_workflow()
                ("DWD_PTY_CUST_INFO_PFD", "DWD_PTY"),
            ]
            for tbl, wf in tables:
                cfg = {"target": tbl, "cross_workflow": [], "same_workflow_predecessors": []}
                if wf is not None:
                    cfg["own_workflow"] = wf
                (depcfg / f"{tbl}.dep.json").write_text(json.dumps(cfg), encoding="utf-8")
                (scripts_dir / f"{tbl}.sh").write_text("echo ok\n", encoding="utf-8")

            out_prod = root / "plan_prod.json"
            out_pty = root / "plan_pty.json"
            with patch.object(self.api.D, "DEPCFG", str(depcfg)), \
                 patch.object(self.api.D, "REPO", str(root)), \
                 contextlib.redirect_stdout(io.StringIO()):
                self.api.cmd_plan(argparse.Namespace(
                    col_w=500, only=None, subject="DWD_PROD", out=str(out_prod),
                ))
                self.api.cmd_plan(argparse.Namespace(
                    col_w=500, only=None, subject="DWD_PTY", out=str(out_pty),
                ))

            prod_doc = json.loads(out_prod.read_text(encoding="utf-8"))
            self.assertEqual([w["name"] for w in prod_doc["workflows"]], ["DWD_PROD"])
            prod_tasks = {t["name"] for t in prod_doc["workflows"][0]["tasks"]}
            self.assertEqual(prod_tasks, {"DWD_PTY_OPER_FUND_PRVL_PFD", "DWD_CMM_INTR_PARA_PFD"})

            pty_doc = json.loads(out_pty.read_text(encoding="utf-8"))
            self.assertEqual([w["name"] for w in pty_doc["workflows"]], ["DWD_PTY"])
            pty_tasks = {t["name"] for t in pty_doc["workflows"][0]["tasks"]}
            self.assertEqual(pty_tasks, {"DWD_PTY_CUST_INFO_PFD"})


class TestCoreHelpers(unittest.TestCase):
    def test_ddl_sanitize_and_strip_drop(self):
        from tools.core.ddl_sanitize import sanitize_ddl, strip_drop_stmts

        raw = (
            "DROP TABLE IF EXISTS DWDXDAY.T1\n"
            "CREATE TABLE DWDXDAY.T1 (\n"
            "  NAME VARCHAR2(100 BYTE) DEFAULT NULL,\n"
            "  CODE VARCHAR(32),\n"
            "  DATE STRING\n"
            ");"
        )
        cleaned = sanitize_ddl(strip_drop_stmts(raw))
        self.assertTrue(cleaned.startswith("CREATE TABLE DWDXDAY.T1"))
        self.assertNotIn("DROP TABLE", cleaned)
        self.assertNotIn("DEFAULT NULL", cleaned)
        self.assertNotIn("VARCHAR", cleaned)
        self.assertIn("`DATE` STRING", cleaned)

        inline = "DROP TABLE IF EXISTS DWSXDAY.T2 CREATE TABLE DWSXDAY.T2 (ID STRING);"
        self.assertEqual(strip_drop_stmts(inline), "CREATE TABLE DWSXDAY.T2 (ID STRING);")

    def test_safe_sysname(self):
        from tools.core.safe_paths import safe_sysname

        for ok in ("HSFA", "O32", "MASTER", "主数据", "SYS_01"):
            self.assertEqual(safe_sysname(ok), ok)
        for bad in ("", None, "../etc", "a/b", "a\\b", "HSFA.."):
            with self.assertRaises(ValueError):
                safe_sysname(bad)

    def test_facade_bridge_and_executing_module(self):
        from tools.core.facade_bridge import PatchBridge, executing_module

        target = types.ModuleType("_target_mod")
        target.REPO = "old"

        class _Bridge(PatchBridge):
            _PATCHABLE = {"REPO": target}

        facade = _Bridge("_facade_mod")
        facade.REPO = "new"
        facade.LOCAL = 123
        self.assertEqual(target.REPO, "new")
        self.assertEqual(facade.REPO, "new")
        self.assertFalse(hasattr(target, "LOCAL"))

        with patch.dict(sys.modules, {"_facade_mod": facade}):
            self.assertIs(executing_module(facade.__dict__, "_facade_mod"), facade)

    def test_ds_graph_find_all_cycles(self):
        graph = _load_deploy("ds_graph.py", "_test_ds_graph")
        self.assertEqual(graph.find_all_cycles({"A": {"B"}, "B": {"C"}, "C": set()}), [])
        cycles = graph.find_all_cycles({"A": {"B"}, "B": {"A", "C"}, "C": {"A"}})
        normalized = {tuple(sorted(c)) for c in cycles}
        self.assertEqual(normalized, {("A", "B"), ("A", "B", "C")})


if __name__ == "__main__":
    unittest.main()
