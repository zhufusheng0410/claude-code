# -*- coding: utf-8 -*-
"""tools/dws/ 子包的直接单元测试（覆盖 args / process / cli，不依赖 facade 间接测试）。"""
import shutil
import subprocess
import tempfile
import types
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

from tools.dws import args as dws_args
from tools.dws import cli as dws_cli
from tools.dws import process as dws_proc
from tools.dws import state as dws_state


class TestDwsArgs(unittest.TestCase):
    def test_layers_of_valid_and_invalid(self):
        self.assertEqual(dws_args.layers_of(types.SimpleNamespace(layers="dwd")), {"DWD"})
        self.assertEqual(
            dws_args.layers_of(types.SimpleNamespace(layers=" dwd , DWS ")),
            {"DWD", "DWS"},
        )
        self.assertEqual(
            dws_args.layers_of(types.SimpleNamespace(layers="")),
            set(dws_state.VALID_LAYERS),
        )
        with self.assertRaises(SystemExit):
            dws_args.layers_of(types.SimpleNamespace(layers="ODS"))

    def test_flag_helpers_and_dwd_ddl_cmd(self):
        dry_ns = types.SimpleNamespace(apply=False, no_strict=False, allow_stale_dws_manifest=False)
        self.assertEqual(dws_args._ap(dry_ns), [])
        self.assertEqual(dws_args._dry(dry_ns), ["--dry-run"])
        self.assertFalse(dws_args.stale_allowed(dry_ns))
        self.assertTrue(dws_args.strict_of(dry_ns))
        cmd_dry = dws_args._dwd_ddl_cmd(dry_ns)
        self.assertNotIn("--apply", cmd_dry)
        self.assertNotIn("--no-strict", cmd_dry)

        apply_ns = types.SimpleNamespace(apply=True, no_strict=True, allow_stale_dws_manifest=True)
        self.assertEqual(dws_args._ap(apply_ns), ["--apply"])
        self.assertEqual(dws_args._dry(apply_ns), [])
        self.assertTrue(dws_args.stale_allowed(apply_ns))
        self.assertFalse(dws_args.strict_of(apply_ns))
        cmd_apply = dws_args._dwd_ddl_cmd(apply_ns)
        self.assertIn("--apply", cmd_apply)
        self.assertIn("--no-strict", cmd_apply)


class TestDwsProcess(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp, True)

    def test_run_returns_124_on_timeout(self):
        with patch.object(
            dws_proc.subprocess,
            "run",
            side_effect=subprocess.TimeoutExpired(cmd=["sleep", "9"], timeout=1),
        ):
            rc, out = dws_proc.run(["sleep", "9"], capture=True)
        self.assertEqual(rc, 124)
        self.assertEqual(out, "")

    def test_sync_files_dry_run_vs_apply_prune(self):
        src = self.tmp / "src"
        dst = self.tmp / "dst"
        src.mkdir()
        dst.mkdir()
        (src / "a.sh").write_text("new-a", encoding="utf-8")
        (src / "b.sh").write_text("upd-b", encoding="utf-8")
        (dst / "b.sh").write_text("old-b", encoding="utf-8")
        (dst / "stale.sh").write_text("stale", encoding="utf-8")

        # dry-run 不改目标目录
        count_dry = dws_proc.sync_files(src, dst, apply=False, prune=True)
        self.assertEqual(count_dry, 2)
        self.assertFalse((dst / "a.sh").exists())
        self.assertEqual((dst / "b.sh").read_text(encoding="utf-8"), "old-b")
        self.assertTrue((dst / "stale.sh").exists())

        # apply + prune 同步新增/更新并清理过期文件
        count_apply = dws_proc.sync_files(src, dst, apply=True, prune=True)
        self.assertEqual(count_apply, 2)
        self.assertEqual((dst / "a.sh").read_text(encoding="utf-8"), "new-a")
        self.assertEqual((dst / "b.sh").read_text(encoding="utf-8"), "upd-b")
        self.assertFalse((dst / "stale.sh").exists())

    def test_shell_syntax_outcomes(self):
        with patch.object(
            dws_proc.subprocess, "run", return_value=MagicMock(returncode=0, stderr=b"")
        ):
            self.assertEqual(dws_proc.shell_syntax("x.sh", text="echo ok\n"), "ok")

        with patch.object(
            dws_proc.subprocess, "run", return_value=MagicMock(returncode=2, stderr=b"syntax error")
        ):
            self.assertEqual(dws_proc.shell_syntax("x.sh", text="if then\n"), "bad")

        # 沙箱拒绝（UTF-16LE 含 \x00 或中文拒绝）判 skip 而非 bad
        with patch.object(
            dws_proc.subprocess, "run", return_value=MagicMock(returncode=1, stderr=b"E\x00R\x00R")
        ):
            self.assertEqual(dws_proc.shell_syntax("x.sh", text="echo ok\n"), "skip")

        with patch.object(dws_proc.subprocess, "run", side_effect=OSError("no bash")):
            self.assertEqual(dws_proc.shell_syntax("x.sh", text="echo ok\n"), "skip")


class TestDwsCli(unittest.TestCase):
    def test_apply_option_defaults_to_dry_run(self):
        flags, kw = dws_cli.OPT["apply"]
        self.assertEqual(flags, ("--apply",))
        self.assertEqual(kw.get("action"), "store_true")

    def test_cmd_all_jf_vs_gen_stage_order(self):
        order = []

        def make_step(name, rc=0):
            def _fn(args):
                order.append(name)
                return rc
            return _fn

        ns_jf = types.SimpleNamespace(source="jf", deploy=False, ds=False)
        with (
            patch.object(dws_cli, "cmd_scripts", side_effect=make_step("scripts")),
            patch.object(dws_cli, "cmd_ddl", side_effect=make_step("ddl")),
            patch.object(dws_cli, "cmd_verify_ddl", side_effect=make_step("verify-ddl")),
            patch.object(dws_cli, "cmd_lineage", side_effect=make_step("lineage")),
            patch.object(dws_cli, "cmd_config", side_effect=make_step("config")),
            patch.object(dws_cli, "cmd_verify", side_effect=make_step("verify")),
        ):
            self.assertEqual(dws_cli.cmd_all(ns_jf), 0)
        self.assertEqual(order, ["scripts", "ddl", "verify-ddl", "lineage", "config", "verify"])

        # gen 模式跳过 verify-ddl
        order.clear()
        ns_gen = types.SimpleNamespace(source="gen", deploy=False, ds=False)
        with (
            patch.object(dws_cli, "cmd_scripts", side_effect=make_step("scripts")),
            patch.object(dws_cli, "cmd_ddl", side_effect=make_step("ddl")),
            patch.object(dws_cli, "cmd_verify_ddl", side_effect=make_step("verify-ddl")),
            patch.object(dws_cli, "cmd_lineage", side_effect=make_step("lineage")),
            patch.object(dws_cli, "cmd_config", side_effect=make_step("config")),
            patch.object(dws_cli, "cmd_verify", side_effect=make_step("verify")),
        ):
            self.assertEqual(dws_cli.cmd_all(ns_gen), 0)
        self.assertEqual(order, ["scripts", "ddl", "lineage", "config", "verify"])


if __name__ == "__main__":
    unittest.main()
