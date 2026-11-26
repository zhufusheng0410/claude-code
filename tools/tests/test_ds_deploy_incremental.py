# -*- coding: utf-8 -*-
"""ds-add-dwd-table 与 ds-build-dws-dependent-from-lineage 隔离单测。

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
import unittest
from pathlib import Path
from unittest.mock import patch

try:
    import pandas as pd
    import openpyxl  # noqa: F401
    HAS_EXCEL = True
except ImportError:
    HAS_EXCEL = False

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


class TestDsAddDwdTable(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mod = _load_deploy("ds-add-dwd-table.py", "_test_ds_add_dwd_table")

    def setUp(self):
        for fn in (self.mod.pcode, self.mod.wf_name, self.mod.job_index):
            if hasattr(fn, "_c"):
                delattr(fn, "_c")

    def test_sys_of(self):
        self.assertEqual(self.mod.sys_of("ODS_HSZTA_TFUNDINFO_PFD"), "HSZTA")
        self.assertEqual(self.mod.sys_of("ODS_HSFTA_TACCONET_PFD"), "HSFTA")
        self.assertEqual(self.mod.sys_of("ODS_HSFA_TBOOK_PFD"), "HSFA")
        self.assertIsNone(self.mod.sys_of("ODS_UNKNOWN_TBL"))
        self.assertIsNone(self.mod.sys_of("DWD_PROD_INFO_PFD"))

    def test_parse_src_tables_dedup_and_prev_partition(self):
        sql = (
            "INSERT OVERWRITE TABLE DWDXDAY.DWD_TARGET\n"
            "SELECT * FROM odsx.ODS_HSZTA_A T1\n"
            "LEFT JOIN DWDXDAY.DWD_X T2 ON T2.P_DT='${p_end_dt_1}'\n"
            "JOIN dwdxday.dwd_y T3 ON 1=1\n"
            "JOIN ODSX.ODS_HSZTA_A T4 ON 1=1\n"
        )
        with tempfile.TemporaryDirectory() as tmp:
            sp = Path(tmp) / "DWD_TARGET.sh"
            sp.write_text(sql, encoding="utf-8")
            got = self.mod.parse_src_tables(str(sp))
        self.assertEqual(
            got,
            [
                ("ODSX.ODS_HSZTA_A", False),
                ("DWDXDAY.DWD_X", True),
                ("DWDXDAY.DWD_Y", False),
            ],
        )

    def test_load_cfg(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp)
            (p / "readme.txt").write_text("ignore", encoding="utf-8")
            (p / "A.dep.json").write_text(
                json.dumps({"target": "DWD_A"}), encoding="utf-8"
            )
            (p / "B.dep.json").write_text(
                json.dumps({"target": "DWD_B"}), encoding="utf-8"
            )
            with patch.object(self.mod.D, "DEPCFG", str(p)):
                cfg = self.mod.load_cfg("DWD_B")
                missing = self.mod.load_cfg("DWD_NONE")
        self.assertIsNotNone(cfg)
        self.assertEqual(cfg["target"], "DWD_B")
        self.assertIsNone(missing)

    def test_upstream_items_real_schema_and_drift(self):
        """回归测试：支持 cross_workflow + same_workflow_predecessors 真实结构，采信 DS 实际归属。"""
        own_code = 44
        cfg = {
            "target": "DWD_ACCT_ACCT_BTCH_RELA_PFD",
            "own_workflow": "DWD_ACCT",
            "cross_workflow": [
                {
                    "workflow": "DWD_CHNL",
                    "code": None,
                    "sources": [{"source": "DWD_CHNL_CHNL_BASIC_INFO_PFD", "source_cn": ""}],
                },
                {
                    "workflow": "ods_hsfta_etl_01",
                    "code": None,
                    "sources": [{"source": "ODS_HSFTA_TACCONET_PFD", "source_cn": ""}],
                },
                {
                    "workflow": "ods_hszta_etl_01",
                    "code": None,
                    "sources": [{"source": "ODS_HSZTA_TACCONET_PFD", "source_cn": ""}],
                },
                {
                    "workflow": "DWD_ACCT",
                    "code": None,
                    "sources": [{"source": "DWD_ACCT_SIB", "source_cn": ""}],
                },
            ],
            "same_workflow_predecessors": [
                {"source": "DWD_ACCT_SIB", "source_cn": ""},
                {"source": "DWD_ACCT_ACCT_BTCH_RELA_PFD", "source_cn": ""},
            ],
        }
        tasks_old = [{"name": "DWD_ACCT_SIB", "code": 5}]
        idx = {
            "DWD_CHNL_CHNL_BASIC_INFO_PFD": ("DWD_CHNL", 11, 111),
            "ODS_HSFTA_TACCONET_PFD": ("ods_hsfta_etl_02", 22, 222),
        }
        buf = io.StringIO()
        with patch.object(self.mod, "pcode", return_value=999), \
             patch.object(self.mod, "job_index", return_value=idx), \
             patch.object(self.mod.D, "script_index", return_value={"DWD_CHNL_CHNL_BASIC_INFO_PFD"}), \
             contextlib.redirect_stdout(buf):
            items, skipped = self.mod.upstream_items(cfg, own_code, "DWD_ACCT", tasks_old)

        pairs = [(it["definitionCode"], it["depTaskCode"]) for it in items]
        self.assertEqual(len(pairs), len(set(pairs)))
        self.assertIn((11, 111), pairs)
        self.assertIn((22, 222), pairs)
        self.assertIn((own_code, 5), pairs)
        self.assertTrue(all(it["dependentType"] == "DEPENDENT_ON_TASK" for it in items))
        skipped_names = [name for name, _why in skipped]
        self.assertIn("ODS_HSZTA_TACCONET_PFD", skipped_names)
        out = buf.getvalue()
        self.assertIn("配置漂移", out)
        self.assertIn("ODS_HSFTA_TACCONET_PFD", out)

    def test_manual_upstream_trusts_ds_and_skips(self):
        """回归测试：ODS 上游按 DS job_index 实际工作流建依赖，不因本地分块漂移指错工作流。"""
        sql = (
            "INSERT OVERWRITE TABLE DWDXDAY.DWD_SELF\n"
            "SELECT * FROM ODSX.ODS_HSZTA_A T1\n"
            "LEFT JOIN DWDXDAY.DWD_T T2 ON T2.P_DT='${p_end_dt_1}'\n"
            "JOIN DWDXDAY.DWD_SELF T3 ON 1=1\n"
            "JOIN EXT.MANUAL_TBL T4 ON 1=1\n"
        )
        idx = {
            "ODS_HSZTA_A": ("ods_hszta_etl_03", 88, 888),
        }
        buf = io.StringIO()
        with tempfile.TemporaryDirectory() as tmp:
            sp = Path(tmp) / "DWD_SELF.sh"
            sp.write_text(sql, encoding="utf-8")
            with patch.object(self.mod, "pcode", return_value=999), \
                 patch.object(self.mod.D, "script_of", return_value=str(sp)), \
                 patch.object(self.mod.D, "locate_ods", return_value="ods_hszta_etl_01"), \
                 patch.object(self.mod.D, "wf_code", return_value=77), \
                 contextlib.redirect_stdout(buf):
                items, skipped = self.mod.manual_upstream("DWD_SELF", 500, [], idx)

        self.assertEqual(len(items), 1)
        self.assertEqual(items[0]["definitionCode"], 88)
        self.assertEqual(items[0]["depTaskCode"], 888)
        self.assertEqual(items[0]["dependentType"], "DEPENDENT_ON_TASK")
        skipped_names = [name for name, _why in skipped]
        self.assertIn("DWDXDAY.DWD_T", skipped_names)
        self.assertIn("DWDXDAY.DWD_SELF", skipped_names)
        self.assertIn("EXT.MANUAL_TBL", skipped_names)
        self.assertIn("配置漂移", buf.getvalue())

    def test_build_plan_dry_run_and_existing_table_guard(self):
        cfg = {
            "target": "DWD_ACCT_ACCT_BTCH_RELA_PFD",
            "own_workflow": "DWD_ACCT",
            "cross_workflow": [
                {
                    "workflow": "DWD_CHNL",
                    "code": None,
                    "sources": [{"source": "DWD_CHNL_CHNL_BASIC_INFO_PFD", "source_cn": ""}],
                }
            ],
            "same_workflow_predecessors": [],
        }
        idx = {"DWD_CHNL_CHNL_BASIC_INFO_PFD": ("DWD_CHNL", 11, 111)}
        calls = []

        def fake_call(method, path, **_kw):
            calls.append((method, path))
            return {
                "code": 0,
                "data": {
                    "workflowDefinition": {
                        "name": "DWD_ACCT",
                        "locations": "[]",
                        "releaseState": "ONLINE",
                    },
                    "taskDefinitionList": [{"name": "DWD_ACCT_SIB", "code": 5}],
                    "workflowTaskRelationList": [],
                },
            }

        buf = io.StringIO()
        with tempfile.TemporaryDirectory() as tmp:
            sp = Path(tmp) / "DWD_ACCT_ACCT_BTCH_RELA_PFD.sh"
            sp.write_text("SELECT 1;\n", encoding="utf-8")
            args = argparse.Namespace(
                table="DWD_ACCT_ACCT_BTCH_RELA_PFD",
                workflow="DWD_ACCT",
                apply=False,
            )
            with patch.object(self.mod, "pcode", return_value=999), \
                 patch.object(self.mod.D, "login"), \
                 patch.object(self.mod.D, "wf_code", return_value=500), \
                 patch.object(self.mod.D, "script_of", return_value=str(sp)), \
                 patch.object(self.mod.D, "call", side_effect=fake_call), \
                 patch.object(self.mod.D, "script_index", return_value={"DWD_CHNL_CHNL_BASIC_INFO_PFD"}), \
                 patch.object(self.mod, "load_cfg", return_value=cfg), \
                 patch.object(self.mod, "job_index", return_value=idx), \
                 patch.object(self.mod, "wf_name", return_value="DWD_CHNL"), \
                 contextlib.redirect_stdout(buf):
                self.mod.build_plan(args)

        self.assertTrue(calls)
        self.assertTrue(all(m == "GET" for m, _p in calls))
        out = buf.getvalue()
        self.assertIn("(--dry-run，未提交)", out)
        self.assertIn("解析出依赖项 1 条", out)

        # 表已存在于工作流中时必须拒绝
        def fake_call_existing(method, path, **_kw):
            return {
                "code": 0,
                "data": {
                    "workflowDefinition": {
                        "name": "DWD_ACCT",
                        "locations": "[]",
                        "releaseState": "ONLINE",
                    },
                    "taskDefinitionList": [{"name": "DWD_ACCT_ACCT_BTCH_RELA_PFD", "code": 5}],
                    "workflowTaskRelationList": [],
                },
            }

        with tempfile.TemporaryDirectory() as tmp:
            sp = Path(tmp) / "DWD_ACCT_ACCT_BTCH_RELA_PFD.sh"
            sp.write_text("SELECT 1;\n", encoding="utf-8")
            args = argparse.Namespace(
                table="DWD_ACCT_ACCT_BTCH_RELA_PFD",
                workflow="DWD_ACCT",
                apply=False,
            )
            with patch.object(self.mod, "pcode", return_value=999), \
                 patch.object(self.mod.D, "login"), \
                 patch.object(self.mod.D, "wf_code", return_value=500), \
                 patch.object(self.mod.D, "script_of", return_value=str(sp)), \
                 patch.object(self.mod.D, "call", side_effect=fake_call_existing):
                with self.assertRaises(SystemExit) as cm:
                    self.mod.build_plan(args)
                self.assertIn("已在工作流里", str(cm.exception))


class TestDsBuildDwsDeps(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.dwd = _load_deploy("ds-build-dependent-from-lineage.py", "_test_dwd_deps")
        cls.dws = _load_deploy("ds-build-dws-dependent-from-lineage.py", "_test_dws_deps")

    def test_cn_text(self):
        self.assertEqual(self.dwd.cn_text(float("nan")), "")
        self.assertEqual(self.dwd.cn_text(None), "")
        self.assertEqual(self.dwd.cn_text("基金"), "基金")

    def test_script_of_dws(self):
        with tempfile.TemporaryDirectory() as tmp:
            etl = Path(tmp) / "HSFA" / "dws" / "02_etl"
            etl.mkdir(parents=True)
            target = etl / "DWS_A.sh"
            target.write_text("SELECT 1;\n", encoding="utf-8")
            with patch.object(self.dws, "REPO", tmp):
                self.assertEqual(self.dws.script_of_dws("DWS_A", "HSFA"), str(target))
                self.assertEqual(self.dws.script_of_dws("DWS_A"), str(target))
                self.assertIsNone(self.dws.script_of_dws("DWS_MISSING", "HSFA"))
                self.assertIsNone(self.dws.script_of_dws("DWS_MISSING"))

    def _write_lineage_xlsx(self, path: Path, rows):
        path.parent.mkdir(parents=True, exist_ok=True)
        df = pd.DataFrame(
            rows,
            columns=["目标表英文名", "上游表英文名", "目标表中文名", "上游表中文名"],
        )
        with pd.ExcelWriter(path, engine="openpyxl") as writer:
            df.to_excel(writer, sheet_name="表级血缘(扁平)", index=False)

    @unittest.skipUnless(HAS_EXCEL, "需要 pandas 与 openpyxl")
    def test_load_lineage_handles_nan_self_edge_and_unknown_sys(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            self._write_lineage_xlsx(
                repo / "HSFA" / "dws" / "lineage" / "DWS_lineage.xlsx",
                [
                    ("DWS_A", "DWD_PROD_X", "汇总A", None),
                    ("DWS_A", "DWS_A", "汇总A", "汇总A"),
                ],
            )
            self._write_lineage_xlsx(
                repo / "UNKNOWN_SYS" / "dws" / "lineage" / "DWS_lineage.xlsx",
                [("DWS_B", "DWD_PROD_Y", "汇总B", "基础Y")],
            )
            buf = io.StringIO()
            with patch.object(self.dws, "REPO", str(repo)), \
                 contextlib.redirect_stdout(buf):
                files, pairs, meta, tgt_sys = self.dws.load_lineage()

        self.assertEqual(len(files), 2)
        self.assertEqual(pairs, [("DWS_A", "DWD_PROD_X", "HSFA")])
        self.assertEqual(meta["DWS_A"], "汇总A")
        self.assertEqual(meta["DWD_PROD_X"], "")
        self.assertNotIn("DWS_B", tgt_sys)
        self.assertIn("跳过未知系统血缘文件", buf.getvalue())

    @unittest.skipUnless(HAS_EXCEL, "需要 pandas 与 openpyxl")
    def test_main_stats_and_apply(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            repo = root / "scripts"
            self._write_lineage_xlsx(
                repo / "HSFA" / "dws" / "lineage" / "DWS_lineage.xlsx",
                [
                    ("DWS_A", "DWD_PROD_X", "汇总A", None),
                    ("DWS_A", "ODS_HSFA_T", "汇总A", "估值表"),
                ],
            )
            etl_dir = repo / "HSFA" / "dws" / "02_etl"
            etl_dir.mkdir(parents=True)
            (etl_dir / "DWS_A.sh").write_text("SELECT 1;\n", encoding="utf-8")

            out_dir = root / "dep-config-dws-out"

            buf_stats = io.StringIO()
            with patch.object(self.dws, "REPO", str(repo)), \
                 patch.object(self.dws, "OUT", str(out_dir)), \
                 patch.object(self.dws.DWD, "script_of", return_value="/fake/MASTER/dwd/02_etl/DWD_PROD_X.sh"), \
                 patch.object(self.dws.DWD, "locate_ods", return_value="ods_hsfa_etl_01"), \
                 patch.object(self.dws.DWD, "own_workflow", return_value="DWD_PROD"), \
                 patch.object(sys, "argv", ["ds-build-dws-dependent-from-lineage.py", "--stats"]), \
                 contextlib.redirect_stdout(buf_stats):
                rc_stats = self.dws.main()

            self.assertEqual(rc_stats, 0)
            self.assertFalse(out_dir.exists())

            buf_apply = io.StringIO()
            with patch.object(self.dws, "REPO", str(repo)), \
                 patch.object(self.dws, "OUT", str(out_dir)), \
                 patch.object(self.dws.DWD, "script_of", return_value="/fake/MASTER/dwd/02_etl/DWD_PROD_X.sh"), \
                 patch.object(self.dws.DWD, "locate_ods", return_value="ods_hsfa_etl_01"), \
                 patch.object(self.dws.DWD, "own_workflow", return_value="DWD_PROD"), \
                 patch.object(sys, "argv", ["ds-build-dws-dependent-from-lineage.py"]), \
                 contextlib.redirect_stdout(buf_apply):
                rc_apply = self.dws.main()

            self.assertEqual(rc_apply, 0)
            dep_file = out_dir / "DWS_A.dep.json"
            self.assertTrue(dep_file.is_file())
            raw_text = dep_file.read_text(encoding="utf-8")
            self.assertNotIn('"nan"', raw_text)
            cfg = json.loads(raw_text)
            self.assertEqual(cfg["own_workflow"], "DWS_HSFA")
            wfs = [g["workflow"] for g in cfg["cross_workflow"]]
            self.assertIn("DWD_PROD", wfs)
            self.assertIn("ods_hsfa_etl_01", wfs)


if __name__ == "__main__":
    unittest.main()
