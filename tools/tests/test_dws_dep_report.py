# -*- coding: utf-8 -*-
"""`tools/dws-dep-report.py` 的回归测试（评审 C3）。

★ 背景：DWS 有 47 条依赖边指向 `scripts/MASTER/dwd/02_etl` 下的主数据表。
  扫描 DWD 脚本归属时若只遍历 `SYS`（HSFA/HSZTA/O32），这些边的
  `up_sys` 会落成 `-`、`cross=False`，「跨组依赖」页整页漏报。
  口径真源是 `dwd-pipeline.GROUPS`（SYS + 主数据）。
"""
import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    'dws_dep_report', ROOT / 'tools' / 'dws-dep-report.py')
DR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DR)


class TestScanMasterUpstream(unittest.TestCase):
    """主数据（scripts/MASTER）必须被识别为独立归属，而非「未知」。"""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        scripts = root / 'scripts'
        self.master = scripts / 'MASTER' / 'dwd' / '02_etl'
        for s in DR.SYS:
            (scripts / s / 'dws' / '02_etl').mkdir(parents=True)
        self.master.mkdir(parents=True)
        self._saved = (DR.REPO, DR.SCRIPTS, DR.P.SCRIPTS, DR.P.MASTER)
        DR.REPO = root
        DR.SCRIPTS = scripts
        DR.P.SCRIPTS = scripts
        DR.P.MASTER = self.master
        self.addCleanup(self._restore)

    def _restore(self):
        DR.REPO, DR.SCRIPTS, DR.P.SCRIPTS, DR.P.MASTER = self._saved

    def _write(self, path, body):
        path.write_text(body, encoding='utf-8')

    def test_master_dwd_upstream_attributed(self):
        self._write(self.master / 'DWD_CMM_CALENDAR_INFO_PFD.sh',
                    "INSERT OVERWRITE TABLE DWDXDAY.DWD_CMM_CALENDAR_INFO_PFD\n"
                    "SELECT 1;\n")
        self._write(DR.SCRIPTS / 'HSFA' / 'dws' / '02_etl' / 'DWS_X_PTD.sh',
                    "INSERT OVERWRITE TABLE DWSXDAY.DWS_X_PTD\n"
                    "SELECT * FROM DWDXDAY.DWD_CMM_CALENDAR_INFO_PFD;\n")

        edges, _selfrefs, _conds, _meta = DR.scan()
        hit = [e for e in edges if e['source'] == 'DWD_CMM_CALENDAR_INFO_PFD']
        self.assertEqual(len(hit), 1, edges)
        self.assertEqual(hit[0]['up_sys'], '主数据',
                         'MASTER 脚本未被扫描 ⇒ 主数据上游会落成 -')
        self.assertTrue(hit[0]['cross'], '主数据上游必须计入跨组依赖')

    def test_same_system_upstream_not_cross(self):
        """同系统 DWD 上游不算跨组（防 C3 修复后把 cross 判定改宽）。"""
        hsfa_dwd = DR.SCRIPTS / 'HSFA' / 'dwd' / '02_etl'
        hsfa_dwd.mkdir(parents=True, exist_ok=True)
        self._write(hsfa_dwd / 'DWD_CMM_LOCAL_PFD.sh',
                    "INSERT OVERWRITE TABLE DWDXDAY.DWD_CMM_LOCAL_PFD SELECT 1;\n")
        self._write(DR.SCRIPTS / 'HSFA' / 'dws' / '02_etl' / 'DWS_Y_PTD.sh',
                    "INSERT OVERWRITE TABLE DWSXDAY.DWS_Y_PTD\n"
                    "SELECT * FROM DWDXDAY.DWD_CMM_LOCAL_PFD;\n")
        edges, _s, _c, _m = DR.scan()
        hit = [e for e in edges if e['source'] == 'DWD_CMM_LOCAL_PFD']
        self.assertEqual(len(hit), 1, edges)
        self.assertEqual(hit[0]['up_sys'], 'HSFA')
        self.assertFalse(hit[0]['cross'])


if __name__ == '__main__':
    unittest.main()
