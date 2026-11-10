# -*- coding: utf-8 -*-
"""DWD 管线 CLI。"""
import argparse
import sys

from tools.dwd import ns as _ns
from tools.dwd import parsing as _parsing
from tools.dwd import generation as _generation
from tools.dwd import ddl_check as _ddl
globals().update({k: v for k, v in vars(_ns).items() if not k.startswith("__")})
globals().update({k: v for k, v in vars(_parsing).items() if not k.startswith("__")})
globals().update({k: v for k, v in vars(_generation).items() if not k.startswith("__")})
globals().update({k: v for k, v in vars(_ddl).items() if not k.startswith("__")})

# --------------------------------------------------------------------------- #
# 校验
# --------------------------------------------------------------------------- #
def cmd_verify(args):
    report = {}
    print('== Shell 语法 (bash -n)')
    bad_all = []
    total = 0
    for g in GROUPS:
        n, bad, _sk = _shell_check(etl_dir(g))
        total += n
        bad_all += [(g, *b) for b in bad]
        print(f'  {g}: {n - len(bad)}/{n}')
    for x in bad_all[:10]:
        print('  BAD', x)
    report['shell'] = {'total': total, 'bad': bad_all}

    print('== DDL 完整性（scripts/{系统}/dwd）')
    ddl_bad = {}
    for s in GROUPS:
        d = SCRIPTS / ('MASTER/dwd' if s == '主数据' else f'{s}/dwd')
        per = {p.name: p for p in (d / 'ddl').glob('*.sql')} if (d / 'ddl').is_dir() else {}
        f1 = d / '01_ddl.sql'
        diff = []
        if not f1.is_file():
            diff.append('01_ddl.sql 缺失')
        else:
            body = f1.read_text(encoding='utf-8', errors='replace')
            for name in per:
                if f'CREATE TABLE' in per[name].read_text(
                        encoding='utf-8', errors='replace').upper():
                    if name.replace('.sql', '').upper() not in body.upper():
                        diff.append(f'{name} 未并入 01_ddl.sql')
        ddl_bad[s] = diff
        print(f'  {s}: {len(per)} 张表 / 01_ddl.sql '
              f'{"一致" if not diff else f"{len(diff)} 处问题"}')
    report['ddl_check'] = ddl_bad

    if args.ds:
        print('== DS 脚本来源审计')
        sys.path.insert(0, str(REPO / 'tools/ds-deploy'))
        try:
            import ds_client
            ds = ds_client.get_client()
        except Exception as e:
            print('  ⚠ DS 连接失败:', e)
            report['ds'] = {'error': str(e)}
            return 1
        P = '/projects/185582190746560'
        lst = ds_client.lst_of(
            ds.call('GET', P + '/workflow-definition?pageNo=1&pageSize=500'))
        # ★ 2026-10-29：范围改为 GROUPS（含主数据）。原为 SYS（HSFA/HSZTA/O32），
        #   而 2026-10-23 用户拍板「主数据跑真实脚本、参与 DWD 批次」⇒ 那 23 张
        #   主数据脚本会被误报成「缺脚本」，并让 verify --ds 恒返回非 0。
        local = {p.stem: p for g in GROUPS for p in etl_dir(g).glob('*.sh')}
        real = master = other = empty = 0
        bad, missing, excluded_init = [], [], []
        for f in lst:
            if not f['name'].startswith('DWD_'):
                continue
            g = ds.call('GET', P + '/workflow-definition/%d' % f['code'])
            tds = ds_client.task_definitions(g)
            for t in tds:
                if t.get('taskType') != 'SHELL':
                    continue
                raw = (t.get('taskParams') or {}).get('rawScript') or ''
                nm = t['name']
                if 'master-data placeholder' in raw:
                    master += 1
                    continue
                if 'mapping-table placeholder' in raw:
                    other += 1
                    continue
                if 'script invalid' in raw or '脚本有问题' in raw:
                    empty += 1
                    continue
                p = local.get(nm)
                if not p:
                    if nm.endswith('_INIT'):
                        excluded_init.append(nm)
                    else:
                        missing.append(nm)
                elif raw.replace('\r\n', '\n').strip() != p.read_text(
                        encoding='utf-8').replace('\r\n', '\n').strip():
                    bad.append(nm)
                else:
                    real += 1
        print(f'  与 scripts 一致 {real} | 不一致 {len(bad)} | 默认空脚本占位 {empty}'
              f' | 主数据占位 {master} | 其它占位 {other} | 排除 INIT {len(excluded_init)}')
        print('  缺脚本:', missing[:5])
        if excluded_init:
            print('  DS 仍有 INIT 作业（重建 DWD 后自动消失）:', excluded_init)
        report['ds'] = {'same': real, 'diff': bad, 'empty': empty, 'master': master,
                        'other': other, 'missing': missing, 'excluded_init': excluded_init}
        if bad or missing:
            return 1
    # ★ 2026-10-22（评审 MEDIUM-2 修 bug）：报告写盘原本**不受 --apply 控制**，
    #   与本工具「默认 dry-run、所有写操作需显式 --apply」的约定不一致 ——
    #   dry-run 也会在仓库里落文件。
    #   ⇒ dry-run 只打印摘要；--apply 时才写报告文件。
    if getattr(args, 'apply', False):
        out = REPO / 'tools/.dx-tmp/dwd-pipeline-verify.json'
        out.write_text(json.dumps(report, ensure_ascii=False, indent=1), encoding='utf-8')
        print('报告:', out)
    else:
        print('（dry-run：未写报告文件，加 --apply 才落盘）')
    if bad_all or any(ddl_bad.values()):
        return 1
    print('校验通过')
    return 0


# --------------------------------------------------------------------------- #
def cmd_all(args):
    steps = [
        ('owner', cmd_owner),
        ('convert', cmd_convert),
        ('distribute', cmd_distribute),
        ('ddl', cmd_ddl),
        ('lineage', cmd_lineage),
        ('depcfg', cmd_depcfg),
        ('verify', cmd_verify),
    ]
    for name, fn in steps:
        print(f'\n===== {name} =====')
        rc = fn(args)
        if rc:
            print(f'✗ {name} 失败（rc={rc}）')
            return rc
    print('\n全部完成' + ('' if args.apply else '（dry-run，未落盘）'))
    return 0


def main():
    ap = argparse.ArgumentParser(description='DWD 甲方脚本搬移 + 血缘梳理一体化工具')
    sub = ap.add_subparsers(dest='cmd', required=True)
    for name, help_txt in [
        ('owner', '扫描 MAPPING 生成归属'),
        ('convert', '甲方 txt → sh'),
        ('distribute', '统计分布、写 scripts/_DWD搬移清单.json'),
        ('ddl', '补齐/替换 DDL'),
        ('lineage', '生成依赖 xlsx + 语法校验 sheet'),
        ('prevday', '扫描「只读前一日分区」的依赖边 → tools/_prev_day_deps.json'),
        ('depcfg', '生成 DS 依赖配置'),
        ('verify', '语法/一致性/DS 来源校验'),
        ('all', '串跑全部步骤'),
    ]:
        p = sub.add_parser(name, help=help_txt)
        if name != 'verify':
            p.add_argument('--apply', action='store_true', help='真正落盘（默认 dry-run）')
        if name in ('ddl', 'all'):
            p.add_argument('--no-strict', action='store_true',
                           help='DDL 落盘自检发现差异时不阻断（默认阻断）')
        if name in ('owner', 'convert', 'distribute', 'ddl', 'lineage', 'all'):
            p.add_argument('--force-sys', default='', help='归属歧义时强制归到该系统')
        if name in ('depcfg', 'all'):
            p.add_argument('--out', default=str(DEPCFG_OUT), help='依赖配置输出目录')
        if name == 'prevday':
            p.add_argument('--out', default=str(PREVDAY_OUT),
                           help='上一日依赖清单输出路径')
        if name in ('verify', 'all'):
            p.add_argument('--ds', action='store_true', help='连 DS 审计脚本来源')
    args = ap.parse_args()
    fn = {
        'owner': cmd_owner, 'convert': cmd_convert, 'distribute': cmd_distribute,
        'ddl': cmd_ddl, 'lineage': cmd_lineage, 'prevday': cmd_prevday,
        'depcfg': cmd_depcfg, 'verify': cmd_verify, 'all': cmd_all,
    }[args.cmd]
    return fn(args)

