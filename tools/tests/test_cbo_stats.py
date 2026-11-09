# -*- coding: utf-8 -*-
"""`tools/ds-deploy/cbo-stats.py` 纯函数回归测试（评审 A3/A4/A5）。

★ 三个问题都**不会报错、只会静默出错**，所以必须靠单测固话：
  A3 引用缓存只在 `--rebuild` 时失效 ⇒ 改完 ETL 脚本仍用旧表清单；
  A4 多分区键表把同一个值赋给每个键 ⇒ 命中错误分区或 partition not found；
  A5 `--top 0` 在 probe 里是「空列表」、在 gen/run 里是「不限量」⇒ 语义相反。
"""
import importlib.util
import json
import pathlib
import tempfile
import types
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    'cbo_stats', ROOT / 'tools' / 'ds-deploy' / 'cbo-stats.py')
CS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CS)


class TestPartitionSpec(unittest.TestCase):
    def test_value_only_shorthand(self):
        self.assertEqual(CS._parse_partition_spec("20261029"), {"": "20261029"})

    def test_explicit_key_value_pairs(self):
        self.assertEqual(CS._parse_partition_spec("p_dt=20261029, region=cn"),
                         {"p_dt": "20261029", "region": "cn"})

    def test_quotes_are_stripped(self):
        self.assertEqual(CS._parse_partition_spec("p_dt='20261029'"),
                         {"p_dt": "20261029"})

    def test_empty(self):
        self.assertEqual(CS._parse_partition_spec(""), {})


class _Args(types.SimpleNamespace):
    def __init__(self, **kw):
        kw.setdefault("rebuild", False)
        kw.setdefault("top", 0)
        kw.setdefault("min_refs", 1)
        kw.setdefault("with_columns", False)
        kw.setdefault("partition", "")
        kw.setdefault("verbose", False)
        super().__init__(**kw)


class TestScanRefsCache(unittest.TestCase):
    """A3：缓存必须能自我失效，且损坏时静默重建而不是崩掉。"""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = pathlib.Path(self.tmp.name)
        self.scripts = self.root / "scripts"
        (self.scripts / "O32" / "dwd" / "02_etl").mkdir(parents=True)
        self.sh = self.scripts / "O32" / "dwd" / "02_etl" / "a.sh"
        self.sh.write_text("INSERT INTO DWDXDAY.DWD_T1 SELECT 1;\n", encoding="utf-8")
        self._saved = (CS.SCRIPTS_DIR, CS.CACHE)
        CS.SCRIPTS_DIR = self.scripts
        CS.CACHE = self.root / ".dx-tmp" / "cbo-refs.json"
        self.addCleanup(self._restore)

    def _restore(self):
        CS.SCRIPTS_DIR, CS.CACHE = self._saved

    def test_cache_is_versioned_by_content(self):
        self.assertEqual(CS.scan_refs(), [{"tbl": "DWDXDAY.DWD_T1", "refs": 1}])
        doc = json.loads(CS.CACHE.read_text(encoding="utf-8"))
        self.assertIn("fingerprint", doc)
        self.assertEqual(doc["refs"], [{"tbl": "DWDXDAY.DWD_T1", "refs": 1}])

    def test_etl_change_invalidates_cache(self):
        self.assertEqual(len(CS.scan_refs()), 1)
        # 改脚本：新增一张被引用表（size 必变，不依赖 mtime 精度）
        self.sh.write_text(
            "INSERT INTO DWDXDAY.DWD_T1 SELECT 1;\n"
            "INSERT INTO DWDXDAY.DWD_T2 SELECT 1;\n", encoding="utf-8")
        got = {r["tbl"] for r in CS.scan_refs()}
        self.assertEqual(got, {"DWDXDAY.DWD_T1", "DWDXDAY.DWD_T2"},
                         "改过 ETL 脚本后仍返回旧表清单 = 缓存未失效")

    def test_corrupt_cache_falls_back_to_rescan(self):
        CS.CACHE.parent.mkdir(parents=True)
        CS.CACHE.write_text("{broken json", encoding="utf-8")
        self.assertEqual(CS.scan_refs(), [{"tbl": "DWDXDAY.DWD_T1", "refs": 1}])
        # 重建后应是合法 JSON
        json.loads(CS.CACHE.read_text(encoding="utf-8"))

    def test_old_format_cache_without_fingerprint_rescans(self):
        """旧版缓存是裸 list（没有 fingerprint），不能被当成新格式命中。"""
        CS.CACHE.parent.mkdir(parents=True)
        CS.CACHE.write_text(json.dumps([{"tbl": "DWDXDAY.STALE", "refs": 99}]),
                            encoding="utf-8")
        self.assertEqual(CS.scan_refs(), [{"tbl": "DWDXDAY.DWD_T1", "refs": 1}])


class TestBuildStmts(unittest.TestCase):
    """A4（多分区键）+ A5（--top 0 语义）。"""

    def setUp(self):
        self._saved = (CS.scan_refs, CS.load_meta)
        self.refs = [{"tbl": f"DWDXDAY.DWD_T{i}", "refs": 10 - i} for i in range(3)]
        CS.scan_refs = lambda rebuild=False: self.refs
        self.addCleanup(self._restore)

    def _restore(self):
        CS.scan_refs, CS.load_meta = self._saved

    def _meta(self, part_keys):
        return {f"dwdxday.dwd_t{i}": {"part_keys": list(part_keys), "parts": 1,
                                      "numrows": 1}
                for i in range(3)}

    def test_single_key_shorthand(self):
        CS.load_meta = lambda: self._meta(["p_dt"])
        stmts = CS._build_stmts(_Args(partition="20261029"))
        self.assertEqual(len(stmts), 3)
        self.assertIn("PARTITION(p_dt='20261029')", stmts[0][1])

    def test_multi_key_requires_explicit_values(self):
        CS.load_meta = lambda: self._meta(["p_dt", "region"])
        stmts = CS._build_stmts(_Args(partition="20261029"))
        self.assertEqual(stmts, [], "多分区键表不能把同一个值赋给每个键")

    def test_multi_key_accepts_explicit_values(self):
        CS.load_meta = lambda: self._meta(["p_dt", "region"])
        stmts = CS._build_stmts(_Args(partition="p_dt=20261029,region=cn"))
        self.assertEqual(len(stmts), 3)
        self.assertIn("PARTITION(p_dt='20261029', region='cn')", stmts[0][1])

    def test_multi_key_rejects_partial_values(self):
        CS.load_meta = lambda: self._meta(["p_dt", "region"])
        stmts = CS._build_stmts(_Args(partition="p_dt=20261029"))
        self.assertEqual(stmts, [])

    def test_unknown_key_is_skipped(self):
        CS.load_meta = lambda: self._meta(["p_dt"])
        stmts = CS._build_stmts(_Args(partition="hour=1"))
        self.assertEqual(stmts, [])

    def test_top_zero_means_unlimited(self):
        CS.load_meta = lambda: self._meta([])
        self.assertEqual(len(CS._build_stmts(_Args(top=0))), 3)

    def test_top_limits(self):
        CS.load_meta = lambda: self._meta([])
        self.assertEqual(len(CS._build_stmts(_Args(top=2))), 2)


class TestPartitionWhere(unittest.TestCase):
    """A7 回归：体检抽样的 count(*) 必须能带分区过滤。"""

    META = {"part_keys": ["p_dt"], "parts": 3, "numrows": 1}

    def test_no_partition_key_means_full_table(self):
        self.assertEqual(CS._partition_where({"part_keys": [], "parts": 1}, "20261029"),
                         ("", ""))
        self.assertEqual(CS._partition_where(None, "20261029"), ("", ""))

    def test_single_key_shorthand(self):
        self.assertEqual(
            CS._partition_where(self.META, "20261029"),
            ("WHERE p_dt = '20261029'", ""))

    def test_no_spec_reports_reason(self):
        where, why = CS._partition_where(self.META, "")
        self.assertEqual(where, "")
        self.assertIn("扫全部分区", why)

    def test_multi_key_accepts_explicit_and_filters_subset(self):
        m = {"part_keys": ["p_dt", "region"], "parts": 3}
        where, why = CS._partition_where(m, "p_dt=20261029,region=cn")
        self.assertEqual(why, "")
        self.assertIn("p_dt = '20261029'", where)
        self.assertIn("region = 'cn'", where)

    def test_multi_key_bare_value_is_refused(self):
        m = {"part_keys": ["p_dt", "region"], "parts": 3}
        where, why = CS._partition_where(m, "20261029")
        self.assertEqual(where, "")
        self.assertIn("需显式写成", why)

    def test_unknown_key_is_refused(self):
        where, why = CS._partition_where(self.META, "hour=1")
        self.assertEqual(where, "")
        self.assertIn("不在分区键", why)


class TestProbePartitionFilter(unittest.TestCase):
    """A7 回归：probe 抽样发出的 SQL 要带上分区过滤。"""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self._saved = (CS.scan_refs, CS.load_meta, CS._beeline,
                       CS.dw_paths.REPORT_DIR)
        CS.scan_refs = lambda rebuild=False: [{"tbl": "DWDXDAY.DWD_A", "refs": 9},
                                              {"tbl": "DWDXDAY.DWD_B", "refs": 1}]
        CS.load_meta = lambda: {
            "dwdxday.dwd_a": {"part_keys": ["p_dt"], "parts": 2, "numrows": 0},
            "dwdxday.dwd_b": {"part_keys": [], "parts": 0, "numrows": 0}}
        CS.dw_paths.REPORT_DIR = self.tmp.name
        self.sql = []

        def fake(sql, timeout=300):
            self.sql.append(sql)
            return True, "12\n"

        CS._beeline = fake
        self.addCleanup(self._restore)

    def _restore(self):
        (CS.scan_refs, CS.load_meta, CS._beeline,
         CS.dw_paths.REPORT_DIR) = self._saved

    def _probe(self, partition):
        return CS.cmd_probe(_Args(top=0, sample=2, partition=partition,
                                  verbose=False, rebuild=False))

    def test_partition_predicate_is_applied(self):
        self.assertEqual(self._probe("20261029"), 0)
        blob = "\n".join(self.sql)
        self.assertIn("from dwdxday.dwd_a where p_dt = '20261029'", blob.lower())
        self.assertIn("from dwdxday.dwd_b", blob.lower())
        self.assertNotIn("dwd_a where p_dt", blob.lower().replace(
            "from dwdxday.dwd_a where p_dt = '20261029'", ""))

    def test_without_partition_counts_whole_table(self):
        self.assertEqual(self._probe(""), 0)
        self.assertIn("select count(*) from dwdxday.dwd_a",
                      "\n".join(self.sql).lower())


class TestRunResume(unittest.TestCase):
    """A6 回归：run 断点续跑 + 逐条落盘。"""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self._saved = CS.dw_paths.REPORT_DIR
        CS.dw_paths.REPORT_DIR = self.tmp.name
        self.addCleanup(self._restore)
        self._saved_beeline = CS._beeline
        self.addCleanup(setattr, CS, "_beeline", self._saved_beeline)

    def _restore(self):
        CS.dw_paths.REPORT_DIR = self._saved

    def _stmt(self, name):
        return (name, f"ANALYZE TABLE dwdxday.{name.lower()} COMPUTE STATISTICS")

    def test_previous_ok_runs_are_skipped(self):
        stmts = [self._stmt("DWD_A"), self._stmt("DWD_B")]
        import json as _json
        (pathlib.Path(self.tmp.name) / "cbo_run_20261109-000000.json").write_text(
            _json.dumps([{"tbl": "DWD_A", "sql": stmts[0][1], "ok": True}]),
            encoding="utf-8")
        self.assertEqual(CS._load_done(stmts), {"DWD_A"})

    def test_failed_rows_are_not_remembered(self):
        stmts = [self._stmt("DWD_A")]
        import json as _json
        (pathlib.Path(self.tmp.name) / "cbo_run_20261109-000000.json").write_text(
            _json.dumps([{"tbl": "DWD_A", "sql": stmts[0][1], "ok": False}]),
            encoding="utf-8")
        self.assertEqual(CS._load_done(stmts), set())

    def test_broken_log_is_ignored(self):
        stmts = [self._stmt("DWD_A")]
        (pathlib.Path(self.tmp.name) / "cbo_run_20261109-000000.json").write_text(
            "{broken", encoding="utf-8")
        self.assertEqual(CS._load_done(stmts), set())

    def test_run_writes_valid_json_incrementally(self):
        """Ctrl-C 场景：已完成的行必须已落盘，且文件仍是合法 JSON。"""
        import json as _json
        seen = []

        def fake(sql, timeout=1800):
            seen.append(sql)
            if len(seen) == 2:
                raise KeyboardInterrupt
            return True, ""

        CS._beeline = fake
        args = _Args(partition="", with_columns=False, min_refs=1, top=0,
                     dry_run=False, keep_going=True, timeout=1800,
                     rebuild=False, verbose=False)
        CS._build_stmts = lambda _a: [self._stmt("DWD_A"), self._stmt("DWD_B"),
                                      self._stmt("DWD_C")]
        with self.assertRaises(KeyboardInterrupt):
            CS.cmd_run(args)
        logs = list(pathlib.Path(self.tmp.name).glob("cbo_run_*.json"))
        self.assertEqual(len(logs), 1)
        rows = _json.loads(logs[0].read_text(encoding="utf-8"))
        self.assertEqual([r["tbl"] for r in rows], ["DWD_A"])


if __name__ == "__main__":
    unittest.main()
