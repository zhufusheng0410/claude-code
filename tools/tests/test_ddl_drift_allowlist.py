# -*- coding: utf-8 -*-
"""DDL 登记豁免（`tools/dwd_ddl_drift_allowlist.json`）的回归测试。

覆盖：登记后通过、越界列不豁免、整体性差异不豁免、清单缺失或坏掉时退回「不豁免」。
全部走合成 diff 对象与临时目录，不读仓库真实 DDL、不连集群。
"""
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools.core.ddl_verify import DDLDiff
from tools.dws import ddl as dws_ddl


def _diff(**kw):
    return DDLDiff(table="DWD_T_PFD", **kw)


def _entry(columns):
    return {"columns": columns, "reason": "合成差异登记", "registered": "2026-11-22"}


class TestDriftIsRegistered(unittest.TestCase):
    def test_registered_columns_pass(self):
        d = _diff(only_in_right=["REPO_IR", "REPO_INTR"])
        self.assertTrue(dws_ddl._drift_is_registered(
            d, _entry(["REPO_IR", "REPO_INTR"])))

    def test_case_and_space_insensitive(self):
        d = _diff(only_in_right=["repo_ir"])
        self.assertTrue(dws_ddl._drift_is_registered(d, _entry([" REPO_IR "])))

    def test_type_mismatch_on_registered_column_passes(self):
        d = _diff(type_mismatch=[("REPO_IR", "STRING", "DECIMAL(10,0)")])
        self.assertTrue(dws_ddl._drift_is_registered(d, _entry(["REPO_IR"])))

    def test_unregistered_column_fails(self):
        d = _diff(only_in_right=["REPO_IR", "OTHER_COL"])
        self.assertFalse(dws_ddl._drift_is_registered(d, _entry(["REPO_IR"])))

    def test_partition_mismatch_never_exempt(self):
        d = _diff(only_in_right=["REPO_IR"], partition_mismatch=True)
        self.assertFalse(dws_ddl._drift_is_registered(d, _entry(["REPO_IR"])))

    def test_table_comment_mismatch_never_exempt(self):
        d = _diff(only_in_right=["REPO_IR"], table_comment_mismatch=("甲方", "本地"))
        self.assertFalse(dws_ddl._drift_is_registered(d, _entry(["REPO_IR"])))

    def test_table_name_mismatch_never_exempt(self):
        d = _diff(only_in_right=["REPO_IR"], table_name_mismatch=("A", "B"))
        self.assertFalse(dws_ddl._drift_is_registered(d, _entry(["REPO_IR"])))

    def test_malformed_columns_never_exempt(self):
        for value in ('ABC', {'A': False}, 12, ['A', 1], ['A', '  ']):
            with self.subTest(value=value):
                self.assertFalse(dws_ddl._drift_is_registered(
                    _diff(only_in_left=['A']), _entry(value)))

    def test_missing_or_invalid_metadata_never_exempt(self):
        for key, values in {
            'reason': [None, '', '  ', 1],
            'registered': [None, '', '20261122', '2026-2-03', '2026-02-30', 20261122],
        }.items():
            for value in values:
                with self.subTest(key=key, value=value):
                    entry = _entry(['A'])
                    entry[key] = value
                    self.assertFalse(dws_ddl._drift_is_registered(
                        _diff(only_in_left=['A']), entry))
        self.assertFalse(dws_ddl._drift_is_registered(
            _diff(only_in_left=['A']), {'columns': ['A']}))

    def test_empty_entry_fails(self):
        d = _diff(only_in_right=["REPO_IR"])
        self.assertFalse(dws_ddl._drift_is_registered(d, {}))
        self.assertFalse(dws_ddl._drift_is_registered(d, None))
        self.assertFalse(dws_ddl._drift_is_registered(d, {"columns": []}))


class TestLoadAllowlist(unittest.TestCase):
    def test_missing_file_returns_empty(self):
        with mock.patch.object(dws_ddl.st, "REPO",
                               Path(tempfile.gettempdir()) / "no-such-repo-dw"):
            self.assertEqual(dws_ddl._load_drift_allowlist(), {})

    def test_broken_json_returns_empty(self):
        with tempfile.TemporaryDirectory() as td:
            (Path(td) / "tools").mkdir()
            (Path(td) / "tools/dwd_ddl_drift_allowlist.json").write_text(
                "{bad", encoding="utf-8")
            with mock.patch.object(dws_ddl.st, "REPO", Path(td)):
                self.assertEqual(dws_ddl._load_drift_allowlist(), {})

    def test_reads_tables(self):
        with tempfile.TemporaryDirectory() as td:
            (Path(td) / "tools").mkdir()
            payload = {"tables": {"DWD_T_PFD": {
                "columns": ["A"], "reason": "合成样例", "registered": "2026-11-19"}}}
            (Path(td) / "tools/dwd_ddl_drift_allowlist.json").write_text(
                json.dumps(payload), encoding="utf-8")
            with mock.patch.object(dws_ddl.st, "REPO", Path(td)):
                got = dws_ddl._load_drift_allowlist()
        self.assertEqual(got["DWD_T_PFD"]["columns"], ["A"])


if __name__ == "__main__":
    unittest.main()
