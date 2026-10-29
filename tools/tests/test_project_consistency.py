# -*- coding: utf-8 -*-
"""项目级口径守门：工作流归属单一来源、依赖配置默认目录、双份文档一致。

这些点历史上都靠文档/人肉同步，漂移后不会报错、只会在部署时静默用错口径。
"""
import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _load(name, rel):
    spec = importlib.util.spec_from_file_location(name, ROOT / rel)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class TestWorkflowOwnership(unittest.TestCase):
    def test_single_source(self):
        own = _load('dwd_ownership', 'tools/core/dwd_ownership.py')
        self.assertEqual(own.WORKFLOW_OVERRIDE, {
            'DWD_PTY_OPER_FUND_PRVL_PFD': 'DWD_PROD',
            'DWD_CMM_INTR_PARA_PFD': 'DWD_PROD',
        })
        self.assertEqual(own.own_workflow('DWD_AST_X_PFD'), 'DWD_AST')
        self.assertEqual(own.own_workflow('DWD_PTY_OPER_FUND_PRVL_PFD'), 'DWD_PROD')
        self.assertEqual(own.own_workflow('DWD_CMM_INTR_PARA_PFD'), 'DWD_PROD')
        self.assertEqual(own.own_workflow('ODS_X'), '(未知)')

    def test_consumers_delegate(self):
        """两个消费方不得再各存一份字典（历史回归：靠「两处必须同步」的人肉约定）。"""
        own = _load('dwd_ownership2', 'tools/core/dwd_ownership.py')
        dp = _load('dwd_pipeline', 'tools/dwd-pipeline.py')
        builder = _load('lineage_builder',
                        'tools/ds-deploy/ds-build-dependent-from-lineage.py')
        self.assertEqual(dp.WORKFLOW_OVERRIDE, own.WORKFLOW_OVERRIDE)
        self.assertEqual(builder.WORKFLOW_OVERRIDE, own.WORKFLOW_OVERRIDE)
        for t in ('DWD_AST_X_PFD', 'DWD_PTY_OPER_FUND_PRVL_PFD', 'DWD_CMM_INTR_PARA_PFD'):
            self.assertEqual(dp._own_workflow(t), own.own_workflow(t))
            self.assertEqual(builder.own_workflow(t), own.own_workflow(t))


class TestDepcfgDefaults(unittest.TestCase):
    def test_exec_uses_active_config(self):
        """真实执行必须默认读现役 dep-config-proscript，不能再用旧口径。"""
        mod = _load('run_dwd_etl_direct', 'tools/ds-deploy/run-dwd-etl-direct.py')
        self.assertTrue(mod.DEPCFG_DEFAULT.endswith('dep-config-proscript'))


class TestDocSync(unittest.TestCase):
    def test_agents_equals_claude(self):
        a = (ROOT / 'AGENTS.md').read_bytes()
        c = (ROOT / 'CLAUDE.md').read_bytes()
        self.assertEqual(a, c, 'AGENTS.md 与 CLAUDE.md 必须逐字节一致（改一个就复制过去）')


if __name__ == '__main__':
    unittest.main()
