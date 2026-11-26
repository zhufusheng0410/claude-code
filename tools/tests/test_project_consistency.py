# -*- coding: utf-8 -*-
"""项目级口径守门：工作流归属单一来源、依赖配置默认目录、双份文档一致。

这些点历史上都靠文档/人肉同步，漂移后不会报错、只会在部署时静默用错口径。
"""
import importlib.util
import io
import sys
import unittest
import unittest.mock
from contextlib import redirect_stdout
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _load(name, rel):
    spec = importlib.util.spec_from_file_location(name, ROOT / rel)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class TestReporting(unittest.TestCase):
    def test_print_limited_preserves_tail_count_and_unit(self):
        reporting = _load("reporting", "tools/core/reporting.py")
        out = io.StringIO()
        with redirect_stdout(out):
            reporting.print_limited(("A", "B", "C"), limit=2, unit="个")
        self.assertEqual(out.getvalue(),
                         "    A\n    B\n    … 其余 1 个\n")


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


class TestMasterProtection(unittest.TestCase):
    """★ 阶段 1 行为契约：生成器必须拒绝 `--sys-name MASTER`。

    `scripts/MASTER/dwd/` 存的是甲方脚本与手工血缘，生成器跑一次就会覆盖，
    而这部分无法从 MAPPING 复原。护栏在 `parse_args()` 之后立即触发。
    """

    def test_generator_refuses_master(self):
        import tools.main as gen_main
        argv = ['main.py', '--layer', 'DWD', '--sys-name', 'MASTER']
        with unittest.mock.patch.object(sys, 'argv', argv):
            with self.assertRaises(SystemExit) as cm:
                gen_main.main()
        self.assertIn('拒绝生成 MASTER', str(cm.exception))

    def test_lowercase_master_also_refused(self):
        import tools.main as gen_main
        argv = ['main.py', '--layer', 'ALL', '--sys-name', ' master ']
        with unittest.mock.patch.object(sys, 'argv', argv):
            with self.assertRaises(SystemExit):
                gen_main.main()


class TestDepcfgDefaults(unittest.TestCase):
    def test_exec_uses_active_config(self):
        """真实执行必须默认读现役 dep-config-proscript，不能再用旧口径。"""
        mod = _load('run_dwd_etl_direct', 'tools/ds-deploy/run-dwd-etl-direct.py')
        self.assertTrue(mod.DEPCFG_DEFAULT.endswith('dep-config-proscript'))


class TestDocSync(unittest.TestCase):
    def test_claude_points_at_agents(self):
        """口径全文只在 AGENTS.md。CLAUDE.md 是短入口，禁止再复制成第二份全文。"""
        agents = (ROOT / 'AGENTS.md').read_text(encoding='utf-8')
        claude = (ROOT / 'CLAUDE.md').read_text(encoding='utf-8')
        self.assertIn('AGENTS.md', claude)
        self.assertLess(len(claude), 800, 'CLAUDE.md 应保持短入口，不要复制 AGENTS.md')
        self.assertGreater(len(agents), len(claude) * 5)
        self.assertIn('数仓层级规范', agents)
        self.assertNotEqual(agents, claude)

    def test_readme_points_at_agents(self):
        readme = (ROOT / 'README.md').read_text(encoding='utf-8')
        self.assertIn('AGENTS.md', readme)
        self.assertLess(len(readme), 4000)


class TestPyprojectPackages(unittest.TestCase):
    """防止拆分出新子包（如 tools.dws）后漏写 pyproject.toml 的 packages，导致 wheel 丢包。"""

    def test_all_tools_subpackages_listed_in_pyproject(self):
        import ast
        import re

        text = (ROOT / 'pyproject.toml').read_text(encoding='utf-8')
        m = re.search(r'^packages\s*=\s*(\[[^\]]*\])', text, re.M)
        self.assertIsNotNone(m, 'pyproject.toml 缺少 packages = [...] 声明')
        declared = set(ast.literal_eval(m.group(1)))

        expected = {'tools'}
        for init_py in (ROOT / 'tools').glob('*/__init__.py'):
            pkg_dir = init_py.parent.name
            if pkg_dir in ('tests',) or pkg_dir.startswith('.'):
                continue
            expected.add(f'tools.{pkg_dir}')

        missing = expected - declared
        self.assertEqual(missing, set(), f'pyproject.toml packages 漏列子包: {sorted(missing)}')


class TestDsConfigConsistency(unittest.TestCase):
    """守门：ds-deploy 工具不得硬编码 DS 地址或项目名 "dw"，plan 须沿用单一归属口径。"""

    def test_no_hardcoded_ds_url_or_project_outside_ds_config(self):
        import ast

        deploy_dir = ROOT / 'tools' / 'ds-deploy'
        bad_urls = []
        bad_proj = []
        for path in sorted(deploy_dir.glob('*.py')):
            if path.name == 'ds_config.py':
                continue
            src = path.read_text(encoding='utf-8')
            tree = ast.parse(src, filename=str(path))
            for node in ast.walk(tree):
                # 1. 禁止代码字符串字面量中硬编码 DS 本机端口 URL（排除注释与模块 docstring）
                if isinstance(node, ast.Constant) and isinstance(node.value, str):
                    if ('localhost:12345' in node.value or '127.0.0.1:12345' in node.value):
                        # 仅忽略纯文档注释（Expr 节点里的 docstring）
                        bad_urls.append(f'{path.name}:{node.lineno}')
                # 2. 禁止 == "dw" / DEFAULT_PROJECT = "dw" / project_code(..., "dw") / default="dw"
                if isinstance(node, ast.Compare):
                    for comp in node.comparators:
                        if isinstance(comp, ast.Constant) and comp.value == 'dw':
                            bad_proj.append(f'{path.name}:{node.lineno}')
                if isinstance(node, ast.Assign):
                    if isinstance(node.value, ast.Constant) and node.value.value == 'dw':
                        for tgt in node.targets:
                            if isinstance(tgt, ast.Name) and 'PROJECT' in tgt.id.upper():
                                bad_proj.append(f'{path.name}:{node.lineno}')
                if isinstance(node, ast.Call):
                    fname = node.func.id if isinstance(node.func, ast.Name) else (
                        node.func.attr if isinstance(node.func, ast.Attribute) else ''
                    )
                    if fname == 'project_code' and len(node.args) >= 2:
                        if isinstance(node.args[1], ast.Constant) and node.args[1].value == 'dw':
                            bad_proj.append(f'{path.name}:{node.lineno}')
                    if fname == 'add_argument' and any(
                        isinstance(a, ast.Constant) and a.value == '--project' for a in node.args
                    ):
                        for kw in node.keywords:
                            if kw.arg == 'default' and isinstance(kw.value, ast.Constant) and kw.value.value == 'dw':
                                bad_proj.append(f'{path.name}:{node.lineno}')

        self.assertEqual(bad_urls, [], f'发现硬编码 DS URL（应改用 ds_config.ds_base()）: {bad_urls}')
        self.assertEqual(bad_proj, [], f'发现硬编码项目名 "dw"（应改用 ds_config.ds_project()）: {bad_proj}')

    def test_ds_deploy_api_uses_dwd_ownership(self):
        src = (ROOT / 'tools' / 'ds-deploy' / 'ds-deploy-api.py').read_text(encoding='utf-8')
        self.assertIn('from core.dwd_ownership import own_workflow', src)


if __name__ == '__main__':
    unittest.main()
