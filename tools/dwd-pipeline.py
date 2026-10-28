#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DWD 甲方脚本搬移 + 血缘梳理 一体化工具。

合并自（2026-10-20）：
  · 搬移：`_jf_to_repo_sh.py` / `_regen89.py` / `_build_owner_map.py` /
    `_distribute_dwd.py` / `_extract_ddl.py` / `_replace_ddl.py`
  · 血缘：`_build_deps.py` / `_add_validation_sheet.py` /
    `_build_depcfg_proscript.py`
  · 校验：`_bashn_pro.sh` / `_verify_sync.sh` / `_audit_ds_scripts_src.py`

子命令
------
    owner       扫描 MAPPING，生成 DWD表→系统 归属（tools/.dx-tmp/dwd_owner_map.json）
    convert     甲方 txt → scripts/{系统}/dwd/02_etl（跳过 _INIT）
    distribute  统计分布、写 scripts/_DWD搬移清单.json
    ddl         补齐/替换 DDL（甲方建表脚本）+ 方言清洗 + 重建 scripts/{系统}/dwd/01_ddl.sql
    lineage     脚本逻辑梳理依赖 → scripts/DWD_依赖关系.xlsx（含语法校验 sheet）
    depcfg      xlsx 依赖明细 → DS 依赖配置（配置表自动过滤）
    verify      bash -n / DDL 完整性 /（可选）DS 脚本来源审计
    all         按 owner→convert→distribute→ddl→lineage→depcfg→verify 串跑

约定：所有写操作默认 dry-run，加 `--apply` 才落盘。
`all` 末尾的 verify 默认只做本地校验；加 `--ds` 才连 DolphinScheduler。
"""
import argparse
import collections
import difflib
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.worksheet.hyperlink import Hyperlink

# ★ 2026-10-26：原先硬编码 WSL 路径 + exists() 回退。Windows 下 `Path('/mnt/c/…')`
#   会被当成「当前盘符下的相对路径」`\mnt\c\…`；只要该镜像目录被历史运行创建过一次，
#   `exists()` 就为真 ⇒ 产物全部写进假仓库 `C:\mnt\c\…`（实测把 HSFA DDL 混成 82 张）。
#   ⇒ 仓库用 `__file__` 定位；交付目录按哨兵子目录 `05-脚本` 判定，均不再依赖挂载点。
REPO = Path(__file__).resolve().parents[1]
_CAND_DELIVERY = [
    Path(os.environ["DW_DELIVERY"]) if os.environ.get("DW_DELIVERY") else None,
    Path('/mnt/d/项目/信达澳亚数仓/信达澳亚投研数据集市交付文档'),
    Path(r'D:\项目\信达澳亚数仓\信达澳亚投研数据集市交付文档'),
]
DELIVERY = next((p for p in _CAND_DELIVERY if p and (p / '05-脚本').is_dir()),
                _CAND_DELIVERY[-1])
JF = DELIVERY / '05-脚本/02-脚本/01-DWD执行脚本'
JF_DDL = DELIVERY / '05-脚本/01-建表语句/01-DWD建表脚本.sql'
MAP_ROOT = DELIVERY / '04-源与目标映射MAPPING/01-DWD'

SCRIPTS = REPO / 'scripts'
MASTER = SCRIPTS / 'MASTER/dwd/02_etl'
SYS = ('HSFA', 'HSZTA', 'O32')
GROUPS = SYS + ('主数据',)
OWNER_JSON = REPO / 'tools/.dx-tmp/dwd_owner_map.json'
DEPCFG_OUT = REPO / 'tools/ds-deploy/dep-config-proscript'
ALIAS = {'01-ZTA': 'HSZTA', '02-O32': 'O32', '03-HSFA': 'HSFA'}

# ★ 2026-10-22（评审 HIGH-10）：系统简称的合法字符集。
#   sysname 源自 MAPPING 目录下的一级子目录名（**外部输入**），此前原样
#   拼进输出路径（SCRIPTS / sysname / 'dwd/02_etl'）—— 一个含 `..` 或路径
#   分隔符的目录名即可把文件写到 SCRIPTS 之外（路径遍历）。
#   标准简称是字母数字（HSFA / HSZTA / O32），MASTER 与「主数据」为特例。
_SYS_RE = re.compile(r'^[A-Za-z0-9_]+$')


def safe_sysname(name: str) -> str:
    """校验系统简称可安全用于路径拼接；不合法则抛 ValueError。

    允许的特例：``主数据``（中文，历史目录名）与 ``MASTER``。
    """
    if name in ('主数据', 'MASTER'):
        return name
    if not _SYS_RE.match(name or ''):
        raise ValueError(
            f"非法系统简称 {name!r}：只允许字母/数字/下划线"
            f"（含 '..'、路径分隔符等一律拒绝）")
    return name


def etl_dir(sysname):
    """DWD 脚本目录（主数据归 MASTER）。"""
    safe_sysname(sysname)
    return MASTER if sysname == '主数据' else SCRIPTS / sysname / 'dwd/02_etl'


def ddl_dir(sysname):
    """DDL 目录（主数据归 MASTER）。"""
    safe_sysname(sysname)
    return (SCRIPTS / 'MASTER/dwd/ddl') if sysname == '主数据' \
        else (SCRIPTS / sysname / 'dwd/ddl')


def dws_etl_dir(sysname):
    """DWS 脚本目录（scripts/<系统>/dws/02_etl）。"""
    safe_sysname(sysname)
    return SCRIPTS / sysname / 'dws/02_etl'


def ddl_main(sysname):
    safe_sysname(sysname)
    return (SCRIPTS / 'MASTER/dwd/01_ddl.sql') if sysname == '主数据' \
        else (SCRIPTS / sysname / 'dwd/01_ddl.sql')
TAB_RE = re.compile(r'^DWD_[A-Z0-9_]+$')
SCHEDULE_EXCLUDE = {'DWD_CMM_STD_DICT_CDVAL_MAP'}

# --------------------------------------------------------------------------- #
# 甲方 txt → sh 转换器（J-28 口径）
# --------------------------------------------------------------------------- #
SAFETY = 'set hive.strict.checks.type.safety=false;'
RE_SET_DROP = re.compile(
    r"^\s*set\s+(?:inceptor\.cross\.join\.enabled\s*=\s*TRUE"
    r"|hive\.input\.format\s*=\s*org\.apache\.hadoop\.hive\.ql\.io\.CombineHiveInputFormat)\s*;.*$",
    re.I)
RE_SCR3 = re.compile(
    r"SELECT\s+T1\.L_ZQNM\s*,?\s*\n\s*,?\s*T1\.L_SCLB\s*,?\s*\n\s*,?\s*T1\.L_ZQLB")
SCR3_FIX = ("SELECT CAST(T1.L_ZQNM AS STRING) AS L_ZQNM,\n"
            "                  CAST(T1.L_SCLB AS STRING) AS L_SCLB,\n"
            "                  CAST(T1.L_ZQLB AS STRING) AS L_ZQLB")
SCR3_TABLES = {'DWD_SCR_SCR_BASIC_INFO_PFD', 'DWD_SCR_SCR_CATG_INFO_PFD',
               'DWD_SCR_SCR_NUM_MAPP_PFD'}
PART_FIX = {'DWD_PTY_CNTP_NUM_MAPP_PFD', 'DWD_PTY_ORG_NUM_MAPP_PFD'}
EVT_CAST_FIX = {
    'DWD_EVT_REPO_TRAN_BUSIN_PTD': [
        (r",''(\s+AS\s+REPO_PRC)", r",CAST('' AS DECIMAL(20,10))\1"),
    ],
    'DWD_EVT_EQUI_JOUR_INFO_PTD': [
        (r",'0'(\s+AS\s+QTY)", r",CAST('0' AS DECIMAL(19,4))\1"),
        (r",'0'(\s+AS\s+EQUI_RATE)", r",CAST('0' AS DECIMAL(12,6))\1"),
    ],
}
STAT_KEYS = ('dedupe_head', 'safety', 'date_format3', 'sysdate', 'as_date',
             'sets_dropped', 'scr_cast', 'partition', 'subt1', 'evt_cast')


def _split_top(s):
    args, depth, cur, quote = [], 0, '', None
    for ch in s:
        if quote:
            cur += ch
            if ch == quote:
                quote = None
            continue
        if ch in ("'", '"'):
            quote = ch
            cur += ch
        elif ch == '(':
            depth += 1
            cur += ch
        elif ch == ')':
            depth -= 1
            cur += ch
        elif ch == ',' and depth == 0:
            args.append(cur)
            cur = ''
        else:
            cur += ch
    args.append(cur)
    return [a.strip() for a in args]


def fix_date_format3(s):
    out, pos, n = s, 0, 0
    while True:
        i = out.upper().find('DATE_FORMAT(', pos)
        if i < 0:
            break
        j = i + len('DATE_FORMAT(')
        depth, k, quote = 1, j, None
        while k < len(out) and depth:
            ch = out[k]
            if quote:
                if ch == quote:
                    quote = None
            elif ch in ("'", '"'):
                quote = ch
            elif ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
            k += 1
        if depth:
            break
        args = _split_top(out[j:k - 1])
        if len(args) == 3:
            new = 'DATE_FORMAT(' + args[0] + ',' + args[1] + ')'
            out = out[:i] + new + out[k:]
            n += 1
        pos = i + len('DATE_FORMAT(')
    return out, n


def add_subquery_alias(sql):
    out, added = [], 0
    i = 0
    n = len(sql)
    pat = re.compile(r'\b(FROM|JOIN)\s*\(')
    while True:
        m = pat.search(sql, i)
        if not m:
            out.append(sql[i:])
            break
        ls = sql.rfind('\n', 0, m.start()) + 1
        if sql[ls:m.start()].lstrip().startswith('--'):
            out.append(sql[i:m.end()])
            i = m.end()
            continue
        depth, j = 1, m.end()
        while j < n and depth:
            c = sql[j]
            if c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
            j += 1
        if depth:
            out.append(sql[i:j])
            i = j
            continue
        k = j
        while k < n and sql[k] in ' \t':
            k += 1
        nxt = sql[k:k + 1]
        if nxt and (nxt.isalnum() or nxt == '_'):
            out.append(sql[i:j])
        else:
            out.append(sql[i:j] + ' SUBT1')
            added += 1
        i = j
    return ''.join(out), added


def convert(raw, stats=None, table=''):
    s = raw.replace('\r\n', '\n').replace('\r', '\n').lstrip('\ufeff')
    if s.count('#!/bin/sh') > 1:
        s = s[s.rfind('#!/bin/sh'):]
        if stats is not None:
            stats['dedupe_head'] += 1
    if 'inceptor_beeline "' not in s:
        raise ValueError('找不到 inceptor_beeline "')
    s = s.replace('source ${hadoop_env}', 'source /home/dolphinscheduler/hadoop_env')
    s = re.sub(r'(?m)^[ \t]*source[ \t]+\$\{source_path\}[ \t]*\n', '', s)
    s = re.sub(r'(?m)^([ \t]*)beeline -u \$\{hive_jdbc\}.*$',
               r'\1beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"', s)
    out = s.lstrip('\n')
    lines = out.split('\n')
    kept = [ln for ln in lines if not RE_SET_DROP.match(ln)]
    if stats is not None:
        stats['sets_dropped'] += len(lines) - len(kept)
    out = '\n'.join(kept)
    if SAFETY not in out:
        lines = out.split('\n')
        bidx = max((k for k, x in enumerate(lines) if x.startswith('-- **')), default=-1)
        sidx = next((k for k in range(bidx + 1, len(lines)) if lines[k].strip().startswith('set ')),
                    len(lines))
        lines.insert(sidx, SAFETY)
        out = '\n'.join(lines)
        if stats is not None:
            stats['safety'] += 1
    out, nd = fix_date_format3(out)
    if stats is not None:
        stats['date_format3'] += nd
    out, nq = re.subn(r'\bAS\s+DATE\b(?![\w`])', 'AS \\`DATE\\`', out)
    if stats is not None:
        stats['as_date'] += nq
    n = len(re.findall(r'\bSYSDATE\b', out))
    if n:
        out = re.sub(r'\bSYSDATE\b', "DATE_FORMAT(CURRENT_DATE,'yyyyMMdd')", out)
        if stats is not None:
            stats['sysdate'] += n
    if table in SCR3_TABLES:
        out, nc = RE_SCR3.subn(SCR3_FIX, out)
        if stats is not None:
            stats['scr_cast'] += nc
    if table in PART_FIX:
        pat = re.compile(r'(INSERT\s+OVERWRITE\s+TABLE\s+DWDXDAY\.' + table +
                         r')(?![\w])(?!\s+PARTITION)')
        out, np_ = pat.subn(r"\1 PARTITION (P_DT= '${P_BATCH_DT}')", out)
        if stats is not None:
            stats['partition'] += np_
    if table in EVT_CAST_FIX:
        for pat, rep in EVT_CAST_FIX[table]:
            out, nc = re.subn(pat, rep, out)
            if stats is not None:
                stats['evt_cast'] += nc
    out, na = add_subquery_alias(out)
    if stats is not None:
        stats['subt1'] += na
    return out.rstrip('\n') + '\n'


def norm_lines(txt):
    return [ln.strip() for ln in txt.split('\n') if ln.strip()]


def new_stats():
    return {k: 0 for k in STAT_KEYS}


# --------------------------------------------------------------------------- #
# 归属
# --------------------------------------------------------------------------- #
def norm_table(t):
    return str(t).strip().upper().replace('DWDXDAY.', '').replace('DWD.', '')


def _scan_mapping_xlsx(p, out):
    wb = load_workbook(p, read_only=True, data_only=True)
    try:
        for ws in wb.worksheets:
            entity_col = None
            for row in ws.iter_rows(values_only=True):
                for j, c in enumerate(row):
                    if c is None:
                        continue
                    label = str(c).strip()
                    if label not in ('目标表英文名称', '目标表英文名', '目标表名称'):
                        continue
                    for v in row[j + 1:]:
                        if v is not None and str(v).strip():
                            if TAB_RE.match(norm_table(v)):
                                out[norm_table(v)].append(p.name)
                            break
                if entity_col is None:
                    # ★ 内层用 jj/cc：避免遮蔽外层 for j, c 的循环变量
                    for jj, cc in enumerate(row):
                        if cc is not None and str(cc).strip() in ('实体名称', '实体英文名称'):
                            entity_col = jj
                    if entity_col is not None:
                        continue
                else:
                    v = row[entity_col] if entity_col < len(row) else None
                    if v is not None and TAB_RE.match(norm_table(v)):
                        out[norm_table(v)].append(p.name)
    except Exception as e:
        print(f'  ! {p.name}: {e}')
    finally:
        wb.close()


def build_owner(write=True):
    owner = collections.defaultdict(set)
    for d in sorted(MAP_ROOT.iterdir()):
        if not d.is_dir():
            continue
        sysname = ALIAS.get(d.name, d.name)
        names = collections.defaultdict(list)
        for p in sorted(d.rglob('*.xlsx')):
            if p.name.startswith('~$'):
                continue
            _scan_mapping_xlsx(p, names)
        for t in names:
            owner[t].add(sysname)
        print(f'{d.name:8s} -> {sysname:6s} 表数={len(names)}')
    owner = {k: sorted(v) for k, v in owner.items()}
    master_stems = {p.stem for p in MASTER.glob('*.sh')}
    stems = [p.stem for p in sorted(JF.glob('*.txt'))
             if p.stem not in master_stems and not p.stem.endswith('_INIT')]
    assign, amb, none = {}, {}, []
    for s in stems:
        base = s[:-5] if s.endswith('_INIT') else s
        hits = owner.get(base, [])
        if len(hits) == 1:
            assign[s] = hits[0]
        elif len(hits) > 1:
            amb[s] = hits
        else:
            none.append(s)
    data = {'owner': owner, 'assign': assign, 'amb': amb, 'none': none, 'stems': stems}
    print(f'\n唯一归属 {len(assign)} | 多系统 {len(amb)} | 未命中 {len(none)}')
    for s, h in sorted(amb.items()):
        print(f'  AMB {s}: {h}')
    for s in none:
        print(f'  NONE {s}')
    if write:
        OWNER_JSON.parent.mkdir(parents=True, exist_ok=True)
        OWNER_JSON.write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding='utf-8')
        print('写出', OWNER_JSON)
    return data


def load_owner(write=False):
    if OWNER_JSON.exists():
        return json.loads(OWNER_JSON.read_text(encoding='utf-8'))
    print('归属缓存不存在，现场扫描 MAPPING …')
    return build_owner(write=write)


def resolved_assign(data, force_sys=None):
    assign = dict(data['assign'])
    for t in data.get('none') or []:
        assign.setdefault(t, 'HSFA')
    for t in (data.get('amb') or {}):
        if force_sys:
            assign[t] = force_sys
        else:
            print(f'  ⚠ 归属歧义未处理（可用 --force-sys）：{t}')
    return {k: v for k, v in assign.items() if not k.endswith('_INIT')}


# --------------------------------------------------------------------------- #
# owner / convert / distribute
# --------------------------------------------------------------------------- #
def cmd_owner(args):
    build_owner(write=args.apply)
    return 0


def cmd_convert(args):
    data = load_owner(write=args.apply)
    assign = resolved_assign(data, args.force_sys)
    stats = new_stats()
    init_src = sorted(p.stem for p in JF.glob('*_INIT.txt'))
    init_old = sorted(p for s in GROUPS for d in (etl_dir(s),)
                      for p in d.glob('*_INIT.sh'))
    print(f'INIT 脚本排除 {len(init_src)} 个：{init_src or "无"}')
    print(f'清理旧 INIT 脚本 {len(init_old)} 个')
    if args.apply:
        if init_old:
            bak = REPO / 'tools/.dx-tmp' / f'backup-dwd-init-{time.strftime("%Y%m%d-%H%M%S")}'
            for p in init_old:
                rel = p.relative_to(REPO)
                dst = bak / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(p, dst)
            print(f'  INIT 备份: {bak}')
        for p in init_old:
            p.unlink()
    wrote = 0
    missing = [t for t in assign if not (JF / (t + '.txt')).exists()]
    # ★ 2026-10-22（评审 MEDIUM-3 修 bug）：原来 convert() 抛的 ValueError
    #   未被捕获 ⇒ **一个格式异常的甲方 txt 就中断整批转换**，前面已转换落盘的
    #   留在磁盘上、后面的一律不处理 ⇒ 留下「半成品」结果集，
    #   且报错信息不说明是哪个文件坏了。
    #   ⇒ 改为逐个兜底：失败的记入 failed 继续处理，末尾汇总。
    failed = []
    for t, sysname in sorted(assign.items()):
        p = JF / (t + '.txt')
        if not p.exists():
            continue
        try:
            out = convert(p.read_text(encoding='utf-8', errors='replace'), stats, t)
        except ValueError as e:
            failed.append((t, str(e)))
            print(f'  ✗ 转换失败 {t}: {e}')
            continue
        if args.apply:
            d = etl_dir(sysname)
            d.mkdir(parents=True, exist_ok=True)
            (d / (t + '.sh')).write_text(out, encoding='utf-8', newline='\n')
        wrote += 1
    print(f'\n转换 {wrote} 个（甲方缺 txt：{missing or "无"}）')
    if failed:
        print(f'⚠ {len(failed)} 个转换失败（已跳过，其余正常处理）：')
        for t, e in failed[:10]:
            print(f'    {t}: {e}')
        if len(failed) > 10:
            print(f'    … 其余 {len(failed) - 10} 个')
    print('变换计数:', stats)
    ok, bad = 0, []
    master_shs = sorted(MASTER.glob('*.sh'))
    for sh in master_shs:
        t = sh.stem
        p = JF / (t + '.txt')
        if not p.exists():
            continue
        try:
            got = convert(p.read_text(encoding='utf-8', errors='replace'), None, t)
        except ValueError as e:
            # ★ 2026-10-22：同样兜底（否则一个坏 txt 会中断整个校准环节）
            bad.append(t)
            continue
        if norm_lines(sh.read_text(encoding='utf-8', errors='replace')) == norm_lines(got):
            ok += 1
        else:
            bad.append(t)
    print(f'校准(空白归一化) 与 MASTER {len(master_shs)} 个: 一致 {ok} / 不一致 {len(bad)}')
    if bad:
        print('  不一致:', bad)
        print('  注：MASTER 为主数据手工稿，历史漂移不影响 DWD 批次（DS 侧为占位）')
    if not args.apply:
        print('(dry-run，未落盘)')
    return 0


def cmd_distribute(args):
    dist = {}
    for s in SYS:
        dist[s] = len(list(etl_dir(s).glob('*.sh')))
    n_master = len(list(MASTER.glob('*.sh')))
    if sum(dist.values()) + n_master == 0:
        sys.exit('scripts/ 下没有任何 DWD 脚本 ⇒ 先跑 dwd-pipeline.py convert --apply')
    assign = resolved_assign(load_owner(write=args.apply), args.force_sys)
    ddl = {s: len(list(ddl_dir(s).glob('*.sql'))) for s in GROUPS}
    manifest = {'dist': dist, 'master': n_master, 'ddl': ddl, 'assign': assign,
                'scripts_root': str(SCRIPTS)}
    if args.apply:
        (SCRIPTS / '_DWD搬移清单.json').write_text(
            json.dumps(manifest, ensure_ascii=False, indent=1), encoding='utf-8')
    print(f'分布: {dist} | 主数据 {n_master}')
    print(f'DDL 表数: {ddl}')
    print(f'清单: {SCRIPTS}/_DWD搬移清单.json')
    if not args.apply:
        print('(dry-run，未落盘)')
    return 0


# --------------------------------------------------------------------------- #
# DDL
# --------------------------------------------------------------------------- #
RE_CREATE = re.compile(
    r'CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:[A-Za-z0-9_]+\.)?([A-Za-z0-9_]+)', re.I)
TGT = re.compile(
    r'INSERT\s+(?:OVERWRITE|INTO)\s+(?:TABLE\s+)?(?:[A-Za-z0-9_]+\.)?([A-Za-z][A-Za-z0-9_]*)',
    re.I)
NEED_DDL = [
    'DWD_AST_BAL_INFO_PTD', 'DWD_AST_BAL_INFO_PTD_TMP',
    'DWD_CMM_CALENDAR_INFO_PFD',
    'DWD_EVT_PROD_EQUI_INFO_PTD', 'DWD_EVT_TA_SALE_DATA_PTD',
    'DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP1', 'DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP2',
    'DWD_PROD_PROD_TAIL_PFD_TMP',
    'DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP1', 'DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP2',
]


def _load_shared_sanitize():
    """`sanitize_ddl` 的单一来源：`tools/core/ddl_sanitize.py`（只依赖 re）。

    ★ 2026-10-26：原先 `dw-pipeline.py` 为了复用下面这几行正则，要 exec 整个本模块
      （86KB，连带 openpyxl/pandas）⇒ 缺 openpyxl 的环境里 DWS DDL 直接崩。
      抽成独立小模块后，两边都不再引入重依赖。
    """
    import importlib.util as _ilu
    _p = Path(__file__).resolve().parent / 'core' / 'ddl_sanitize.py'
    _spec = _ilu.spec_from_file_location('_ddl_sanitize', _p)
    _mod = _ilu.module_from_spec(_spec)
    _spec.loader.exec_module(_mod)
    return _mod.sanitize_ddl


sanitize_ddl = _load_shared_sanitize()


def parse_jf_ddl():
    raw = JF_DDL.read_text(encoding='utf-8', errors='replace')
    stmts = {}
    for chunk in re.split(r';\s*(?:\r?\n)', raw):
        m = RE_CREATE.search(chunk)
        if m:
            stmts.setdefault(m.group(1).upper(), chunk.strip())
    return stmts


def cmd_ddl(args):
    if not any(etl_dir(s).is_dir() for s in SYS):
        sys.exit('缺 scripts/{系统}/dwd/02_etl ⇒ 先跑 dwd-pipeline.py convert --apply')
    data = load_owner(write=args.apply)
    assign = resolved_assign(data, args.force_sys)
    jf = parse_jf_ddl()
    want = {}
    for s, sysname in assign.items():
        p = etl_dir(sysname) / (s + '.sh')
        if not p.exists():
            continue
        for t in TGT.findall(p.read_text(encoding='utf-8', errors='replace')):
            want.setdefault(t.upper(), (sysname, s))
    for t in NEED_DDL:
        base = re.sub(r'_TMP\d*$', '', t)
        owner = assign.get(base) or assign.get(re.sub(r'_INIT$', '', base)) or 'HSFA'
        want.setdefault(t, (owner, ''))
    have = {t: v for t, v in want.items() if t in jf}
    miss = sorted(t for t in want if t not in jf)
    by_sys = collections.Counter(v[0] for v in have.values())
    print(f'目标 DDL {len(want)} | 甲方有 {len(have)} | 缺 {len(miss)} | 按系统 {dict(by_sys)}')
    if miss:
        print('  缺:', miss)
    if not args.apply:
        print('(dry-run，未落盘)')
        return 0
    stamp = time.strftime('%Y%m%d-%H%M%S')
    bak = REPO / 'tools/.dx-tmp' / f'backup-dwd-ddl-{stamp}'
    for s in GROUPS:
        d = SCRIPTS / ('MASTER/dwd' if s == '主数据' else f'{s}/dwd')
        if (d / 'ddl').exists():
            shutil.copytree(d / 'ddl', bak / s / 'ddl', dirs_exist_ok=True)
        if (d / '01_ddl.sql').exists():
            (bak / s).mkdir(parents=True, exist_ok=True)
            shutil.copy2(d / '01_ddl.sql', bak / s / '01_ddl.sql')
    for t, (sysname, _s) in have.items():
        body = ('-- 来源: 甲方 01-DWD建表脚本.sql（dwd-pipeline ddl）\n'
                + sanitize_ddl(jf[t]) + ';\n')
        d = ddl_dir(sysname)
        d.mkdir(parents=True, exist_ok=True)
        (d / f'{t}.sql').write_text(body, encoding='utf-8', newline='\n')
    for s in GROUPS:
        d = ddl_dir(s)
        for p in d.glob('*_INIT*.sql'):
            p.unlink()
        parts, seen = [], set()
        for f in sorted(d.glob('*.sql')):
            if f.stem.upper() in seen:
                continue
            seen.add(f.stem.upper())
            parts.append(f.read_text(encoding='utf-8', errors='replace').rstrip())
        ddl_main(s).write_text(
            '\n\n'.join(parts) + '\n', encoding='utf-8', newline='\n')
        print(f'  {s}: 01_ddl.sql <- {len(parts)} 张表')

    top = SCRIPTS / '建表语句'
    top.mkdir(parents=True, exist_ok=True)
    for s in GROUPS:
        main_sql = ddl_main(s)
        if main_sql.is_file():
            shutil.copy2(main_sql, top / f'DWD_{s}_建表语句.sql')
    print(f'  DDL 已落地 {SCRIPTS}/{{系统}}/dwd/ddl、01_ddl.sql 和 {top}')
    print('备份:', bak)
    return 0


# --------------------------------------------------------------------------- #
# 血缘
# --------------------------------------------------------------------------- #
SRC = re.compile(
    r'\b(?:FROM|JOIN)\s+(?!UNIXTIME|_UNIXTIME)(?:[A-Za-z0-9_]+\.)?'
    r'((?:ODS|DWD|DWS|ADM|DIM)_[A-Za-z0-9_]+)', re.I)
SRC_HDR = re.compile(r'--\s*\*\*\s*源表[:：]\s*(.*)')


def _uniq(seq):
    seen, out = set(), []
    for x in seq:
        if x not in seen:
            seen.add(x)
            out.append(x)
    return out


# --------------------------------------------------------------------------- #
# 分区读取口径判定（2026-10-23）
# --------------------------------------------------------------------------- #
# ★ 为什么必须做别名解析：DWD 脚本一律写成
#     FROM ODS_XDAY_O32.ODS_O32_TXXX_PFD T1
#     LEFT JOIN DWDXDAY.DWD_Y T6 ON ... AND T6.P_DT = DATE_SUB('${p_end_dt}',1)
#   P_DT 条件挂在**别名**上，且离 FROM 子句很远（常在 WHERE / 别的 JOIN 的 ON 里），
#   按「FROM 附近 900 字符窗口」找会漏判（2026-10-23 实测：漏掉 O32_SCR_INCD 的
#   BETWEEN 写法、把 DATE_SUB 惯用式误判成 day）。
#
# ★ 口径依据（DS 全局参数实证）：13 个 DWD/DWS 工作流都声明
#     p_start_dt = ${system.biz.date}
#     p_end_dt   = ${system.biz.date}      ← DS 业务日期 = 运行日-1
#     P_BATCH_DT = ${system.biz.date}      （仅 DWD_ACCT / DWD_PTY）
#   所以：
#     '${p_end_dt}' / '${P_BATCH_DT}'                   → 批次日（= 当天那份，必须等上游当天实例）
#     DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
#                                                       → 运行日-1 = 批次日，同上
#     DATE_SUB('${p_end_dt}',1) / DATE_FORMAT(DATE_SUB(...),'yyyyMMdd')
#                                                       → 批次日-1 = ★前一日
# --------------------------------------------------------------------------- #
# ★★ 前一日分区惯用式（用户口径，2026-10-23）
# --------------------------------------------------------------------------- #
# ★ 定义顺序很重要：本节所有常量必须声明在 T1_NOTE / needs_schedule_dep 之前，
#   否则运行期 NameError（2026-10-23 踩过：T1_NOTE 引用了下面的 PREV_IDIOM_DOC）。
#
# 只有**这个字面形态**才算「前一日分区」：
#   DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(
#       '${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
# 允许的变体：空白/换行任意、UNIX_TIMESTAMP 里多包一层 CAST(... AS STRING)。
#
# 为什么必须按形态认，而不是「含 DATE_SUB 就算」：
#   脚本里 DATE_SUB 还可能出现在别处（周偏移、月偏移、账期回溯等），
#   那些**不是**「读批次日-1」，一旦误认就会误删真实依赖。
#
# ★ 变量白名单：PREV_IDIOM_VARS 里的是「本口径」。实测脚本里出现的变量只有两个：
#     p_end_dt   → 本口径（用户明确指定）
#     P_BATCH_DT → 同值同义（13 个工作流的 globalParams 里两者都 = ${system.biz.date}），
#                  单独归为 prev_alike：**只报不删**，避免擅自扩大口径。
PREV_IDIOM_VARS = ('p_end_dt',)
PREV_IDIOM_VARS_ALIKE = ('P_BATCH_DT',)

# 供报告/备注引用的「口径原文」（就是用户指定的那个表达式）
PREV_IDIOM_DOC = ("DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP("
                  "'${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')")

_PREV_CORE = (
    r"DATE_FORMAT\s*\(\s*"
    r"DATE_SUB\s*\(\s*"
    r"TO_DATE\s*\(\s*"
    r"FROM_UNIXTIME\s*\(\s*"
    r"UNIX_TIMESTAMP\s*\(\s*"
    r"(?:CAST\s*\(\s*)?'\$\{(?P<var>[A-Za-z0-9_]+)\}'\s*(?:AS\s+STRING\s*\)\s*)?"
    r"\s*,\s*'yyyyMMdd'\s*"
    # ★ 这里必须三个 )：分别关 UNIX_TIMESTAMP、FROM_UNIXTIME、TO_DATE，
    #   之后才轮到 DATE_SUB 的 ",1)"。写成两个会**永远匹配不上**。
    r"\)\s*\)\s*\)\s*,\s*1\s*\)\s*,\s*'yyyyMMdd'\s*\)"
)
PREV_IDIOM_RE = re.compile(_PREV_CORE, re.I)
_PREV_VARS = {v.upper() for v in PREV_IDIOM_VARS}
_PREV_VARS_ALIKE = {v.upper() for v in PREV_IDIOM_VARS_ALIKE}

PART_LABEL = {'day': '当天', 'prev': '前一日', 'prev_alike': '前一日(P_BATCH_DT)',
              'field': '跟随别名分区', 'latest': '最新快照', 'other': '其它常量',
              'none': '无分区条件'}
PART_ORDER = ('day', 'latest', 'prev', 'prev_alike', 'field', 'other', 'none')

# 写进 xlsx「备注」列的固定文案（与 DS 侧 ds-fix-t1-remark.py 的备注对齐）
T1_NOTE = ('读前一日分区（T-1，口径 = ' + PREV_IDIOM_DOC + '）⇒ 不配调度依赖')
T1_MIXED_NOTE = '读前一日+当天分区 ⇒ 当天那份要等上游当天实例，依赖必须保留'
T1_ALIKE_NOTE = ('读前一日(P_BATCH_DT)分区，与 p_end_dt 同值（都=${system.biz.date}）'
                 '但不在本口径内 ⇒ 暂按需配，待确认')

# 上游「配不上依赖」的两种说明（2026-10-24）
# ★ 起因：DWD_CMM_STD_DICT_CDVAL_MAP 有 94 行写成「需配」，但 depcfg 里它命中
#   SCHEDULE_EXCLUDE 被整表过滤 ⇒ 工作簿与实际生成的依赖配置对不上。
#   现在「调度依赖」列=**最终是否真的建这条边**，理由写在这里。
CONFIG_NOTE = ('映射表/码表：仓库里没有 ETL 脚本（仅 DDL，手工维护/独立刷新）；'
               'DS 上只有占位空作业（保 DAG 完整性）。生成依赖配置时按配置表自动过滤 '
               '⇒ 不建调度依赖')
NOSCRIPT_NOTE = '仓库里没有该上游表的 ETL 脚本 ⇒ 没有可依赖的工作流 ⇒ 不建调度依赖'

# 「调度依赖」列的取值。★ 一律用常量比较，不要写 startswith('不配') ——
# 现在有三种「不配」，混在一起会把「配置表排除」也算进「只读前一日」的统计里。
DROP_PREV = '不配(只读前一日)'
DROP_CONFIG = '不配(配置表排除)'
DROP_NOSCRIPT = '不配(上游无脚本)'
NEED_DEP = '需配'

_SQL_REF = re.compile(
    r'\b(?:FROM|JOIN)\s+(?:[A-Z0-9_]+\s*\.\s*)?([A-Z0-9_]+)(?:\s+(?:AS\s+)?([A-Z0-9_]+))?', re.I)
_SQL_KW_ALIAS = {
    'ON', 'WHERE', 'GROUP', 'ORDER', 'LEFT', 'RIGHT', 'INNER', 'FULL', 'JOIN',
    'UNION', 'LIMIT', 'HAVING', 'SELECT', 'SET', 'INSERT', 'OVERWRITE',
    'DISTRIBUTE', 'SORT', 'CLUSTER', 'TABLESAMPLE', 'LATERAL', 'CROSS',
    'AND', 'OR', 'PARTITION', 'AS', 'VALUES', 'WITH', 'IS', 'NOT', 'NULL',
}
_PDT_Q = re.compile(r'\b([A-Z0-9_]+)\s*\.\s*P_DT\s*(?:=|>=|<=|>|<|BETWEEN)\s*', re.I)
_PDT_B = re.compile(r'\bP_DT\s*(?:=|>=|<=|>|<|BETWEEN)\s*', re.I)
# `T2.P_DT = T4.P_DT` 这种「分区字段对字段」：整条表达式就是一个「别名.P_DT」
_ALIAS_PDT_RE = re.compile(r'^[A-Z0-9_]+\s*\.\s*P_DT\b', re.I)
_PDT_STOP = re.compile(
    r'\s+(AND|OR|ON|LEFT|RIGHT|INNER|FULL|OUTER|JOIN|FROM|WHERE|GROUP|ORDER|'
    r'UNION|LIMIT|HAVING|CLUSTER|DISTRIBUTE|SORT|LATERAL|CROSS|SELECT|SET)\b', re.I)


def _strip_sql_comments(s):
    """去掉 -- 行注释（不误伤单引号里的内容）。"""
    out, i, n, q = [], 0, len(s), False
    while i < n:
        c = s[i]
        if q:
            out.append(c)
            if c == "'":
                if i + 1 < n and s[i + 1] == "'":
                    out.append("'")
                    i += 2
                    continue
                q = False
            i += 1
            continue
        if c == "'":
            q = True
            out.append(c)
            i += 1
            continue
        if c == '-' and i + 1 < n and s[i + 1] == '-':
            j = s.find('\n', i)
            i = n if j < 0 else j
            continue
        out.append(c)
        i += 1
    return ''.join(out)


def _expr_at(stmt, pos, maxlen=460):
    """从 pos 起取一个分区条件表达式：括号配平 + 遇 depth0 子句关键字停。
    BETWEEN 中间那个 AND 要放行（BETWEEN a AND b）。"""
    depth, i, n, between_used = 0, pos, len(stmt), False
    while i < n and i - pos < maxlen:
        c = stmt[i]
        if c == "'":
            j = i + 1
            while j < n:
                if stmt[j] == "'":
                    if j + 1 < n and stmt[j + 1] == "'":
                        j += 2
                        continue
                    break
                j += 1
            i = j + 1
            continue
        if c == '(':
            depth += 1
        elif c == ')':
            if depth == 0:
                break
            depth -= 1
        elif depth == 0 and i > pos:
            sw = _PDT_STOP.match(stmt, i)
            if not sw:
                i += 1
                continue
            if not between_used and re.search(r'\bBETWEEN\b',
                                              stmt[max(0, pos - 24):i], re.I):
                between_used = True
                i = sw.end()
                continue
            break
        i += 1
    return stmt[pos:i].strip()


def _classify_part(expr):
    """把分区条件表达式归到
    prev / prev_alike / day / latest / other / none。

    ★ 判定顺序不能变：
      1) 先认「前一日惯用式」的**字面形态**（含 DATE_SUB 且是 -1 天）。
         不能写成「含 DATE_SUB 就算 prev」—— T-1 惯用式里同时含 DATE_SUB 与
         '${p_end_dt}'，若先判 ${p_end_dt} 会误判成 day；若反过来不认形态，
         又会把别处的周/月偏移 DATE_SUB 误认成「读前一日」而误删真实依赖。
      2) 再判 ${p_end_dt} / ${P_BATCH_DT} / ${p_start_dt} ⇒ day（三者同值）
      3) 再判 CURRENT_TIMESTAMP/CURRENT_DATE ⇒ latest
      4) 再判别名.P_DT（分区字段对字段）⇒ field
    """
    e = expr.upper()
    if 'DATE_SUB' in e:
        m = PREV_IDIOM_RE.search(expr)
        if m:
            v = m.group('var').upper()
            if v in _PREV_VARS:
                return 'prev'
            if v in _PREV_VARS_ALIKE:
                return 'prev_alike'
            return 'other'          # 惯用式形态但变量不在白名单 ⇒ 不擅自认
        return 'other'              # 其它 DATE_SUB 用法（周/月偏移等）⇒ 不是本口径
    if '${P_END_DT}' in e or '${P_BATCH_DT}' in e or '${P_START_DT}' in e:
        # ★ P_START_DT 与 P_END_DT 同值（13 个工作流的 globalParams 里两者都
        #   = ${system.biz.date}），所以 BETWEEN '${p_start_dt}' AND '${p_end_dt}'
        #   收窄成**同一天一个分区** ⇒ 归当天，不是"区间回溯"。
        return 'day'
    if 'CURRENT_TIMESTAMP' in e or 'CURRENT_DATE' in e:
        return 'latest'
    if _ALIAS_PDT_RE.match(e.strip()):
        # ★ `T2.P_DT = T4.P_DT`：分区字段对字段，读哪个分区由 T4 决定。
        #   单独归一类而不是丢进 other —— 否则「分区读取」列会显示成「其它常量」误导人。
        return 'field'
    if not e:
        return 'none'
    return 'other'


def partition_modes(script, src):
    """返回脚本里【每一处】读 src 这张表的分区口径列表，如 ['prev','prev']。

    空列表 = 脚本里没有对 src 的 FROM/JOIN 引用。
    """
    src_u = src.upper()
    out = []
    for st in [x for x in _strip_sql_comments(script).split(';') if x.strip()]:
        st_u = st.upper()
        aliases, refs = set(), 0
        for m in _SQL_REF.finditer(st_u):
            if m.group(1) != src_u:
                continue
            refs += 1
            al = (m.group(2) or '').strip()
            aliases.add(al if al and al not in _SQL_KW_ALIAS else src_u)
        if not refs:
            continue
        found = []
        for m in _PDT_Q.finditer(st_u):
            if m.group(1) in aliases:
                found.append(_classify_part(_expr_at(st, m.end())))
        if not found and refs == 1:
            # 无别名限定 ⇒ 看未限定的 P_DT（排除 T2.P_DT 这种）
            for m in _PDT_B.finditer(st_u):
                if re.search(r'[A-Z0-9_]\s*\.\s*$', st[max(0, m.start() - 24):m.start()], re.I):
                    continue
                found.append(_classify_part(_expr_at(st, m.end())))
        if not found:
            out.extend(['none'] * refs)
        elif len(set(found)) == 1:
            out.extend(found)
        else:
            out.extend(['mixed:' + '+'.join(sorted(set(found)))] * refs)
    return out


def partition_set(script, src):
    """把 partition_modes 折叠成口径集合（mixed:x+y 展开）。"""
    ms = set()
    for m in partition_modes(script, src):
        ms |= set(m[6:].split('+')) if m.startswith('mixed:') else {m}
    return ms


def needs_schedule_dep(script, src):
    """该边是否**必须**配 DS 依赖。

    返回 (需不需要, 口径集合, 结论文案)。
      · 只有 prev（本口径的前一日惯用式）
                            ⇒ 不需要（等的是上游昨天那份分区，当日实例满足不了）
      · 含 day/latest/mixed ⇒ 需要（当天那份必须等上游今天产出）
      · 只有/含 prev_alike   ⇒ **暂按需要**（P_BATCH_DT 与 p_end_dt 同值，
                              但用户口径只认 p_end_dt 字面形态 ⇒ 只报不删，待确认）
      · none/other（无分区条件 / 常量分区）
                            ⇒ 需要（读的是全表 / 固定分区，同样得等上游今天跑完）
      · 无引用              ⇒ None（判定不了，交人工）
    """
    modes = partition_modes(script, src)
    if not modes:
        return None, set(), '脚本未引用该上游表'
    ms = partition_set(script, src)
    if ms == {'prev'}:
        return False, ms, '只按前一日分区（T-1 惯用式）读取 ⇒ 不配调度依赖'
    if 'prev' in ms:
        return True, ms, '前一日与当天并存 ⇒ 依赖必须保留'
    if ms == {'prev_alike'}:
        return True, ms, '按 P_BATCH_DT-1 读取（与 p_end_dt 同值，非本口径）⇒ 暂按需配，待确认'
    if 'prev_alike' in ms:
        return True, ms, '含前一日(P_BATCH_DT)读取 ⇒ 暂按需配，待确认'
    if 'field' in ms and ms <= {'field', 'none'}:
        # 分区跟随另一个别名 ⇒ 实际分区由被跟随的那张表决定，无法只看本边判定 ⇒ 保守需配
        return True, ms, '分区跟随另一别名（T2.P_DT = Tx.P_DT）⇒ 保守按需配'
    return True, ms, '按当天读取 ⇒ 必须配依赖'


def _partition_cell(s, src):
    """「分区读取」列：当天 / 前一日 / 当天+前一日 / 无分区条件 / ''。"""
    ms = partition_set(s, src)
    if not ms:
        return ''
    return '+'.join(PART_LABEL[m] for m in PART_ORDER if m in ms)


def _partition_note(s, src):
    """写进「备注」列的分区说明，例如「；读前一日分区（T-1）⇒ 不配调度依赖」。"""
    ms = partition_set(s, src)
    if not ms:
        return ''
    txt = '+'.join(PART_LABEL[m] for m in PART_ORDER if m in ms)
    if ms == {'prev'}:
        return f'；读{txt}分区（T-1，口径 = {PREV_IDIOM_DOC}）⇒ 不配调度依赖'
    if 'prev' in ms:
        return f'；读{txt}分区（含当天读取 ⇒ 依赖必须保留）'
    if 'prev_alike' in ms:
        return f'；读{txt}分区（与 p_end_dt 同值，非本口径 ⇒ 暂按需配）'
    return f'；读{txt}分区'


def _parse_script(p):
    s = p.read_text(encoding='utf-8', errors='replace')
    targets = _uniq(t.upper() for t in TGT.findall(s))
    real = [t for t in targets if '_TMP' not in t]
    srcs = _uniq(x.upper() for x in SRC.findall(s))
    srcs = [x for x in srcs if x not in real and '_TMP' not in x]
    return real, srcs


def _layer(t):
    return t.split('_')[0]


def _shell_check(folder):
    bad, total, skipped = [], 0, 0
    for p in sorted(Path(folder).glob('*.sh')):
        total += 1
        # ★ 2026-10-23：Windows 下 bash 报错按 GBK 输出，text=True 用 UTF-8 解码会抛
        #   UnicodeDecodeError（表现为 109 个脚本全被判"语法失败"的假象）。
        r = subprocess.run(['bash', '-n', str(p)], capture_output=True, text=True,
                           encoding='utf-8', errors='replace')
        # ★ 沙箱/安全策略拦住子进程启动 bash 时，stderr 是 UTF-16LE 的「拒绝访问」
        #   （含 \x00），这不是脚本语法问题 ⇒ 记为「跳过」，不算失败。
        if r.returncode != 0:
            if '\x00' in (r.stderr or '') or '拒绝' in (r.stderr or ''):
                skipped += 1
                continue
            bad.append((p.name, (r.stderr or '').strip().splitlines()[:1]))
    if skipped:
        print(f"  ⚠ {skipped}/{total} 个脚本的 bash -n 被环境安全策略拦截，未执行语法校验")
    return total, bad, skipped


def _hive_result():
    """读 Hive 语法校验结果；结构不完整（陈旧/残缺）时返回 None，避免写出误导性的 0/0。"""
    p = REPO / 'tools/.dx-tmp/dwd-syntax-check.json'
    if not p.exists():
        return None
    try:
        data = json.loads(p.read_text(encoding='utf-8'))
    except Exception:
        return None
    ddl = data.get('ddl') or {}
    etl = data.get('etl') or {}
    if not ddl.get('total') or not etl.get('total'):
        return None
    return data


# --------------------------------------------------------------------------- #
# 工作簿引导页（首页）：内部 sheet 超链接 + 关联文件外链
# --------------------------------------------------------------------------- #
COVER_SHEETS = [
    ('依赖明细', '每条依赖边一行：脚本 / 归属 / 目标表 / 源表 / 源层级 / 上游脚本 / 备注'),
    ('汇总', '按分组统计：脚本数、依赖边数、各层级上游数、跨组依赖、无上游脚本'),
    ('表级血缘', '一张目标表一行：上游表清单与上游脚本数'),
    ('无同名脚本上游', '引用了但仓库里没有同名脚本的上游表（ODS/中间表/配置表）'),
    ('跨组依赖', '跨分组（跨工作流）的依赖边'),
    ('语法校验', 'Shell bash -n + Hive DDL 建表 + Hive EXPLAIN 编译结果'),
    ('说明', '口径、来源、范围、注意事项'),
]

# ★ 只放 DWD 侧文件；DWS 侧文档不交叉链接（工作簿不混层）。
COVER_LINKS = [
    ('DS 依赖校验', 'DWD_DS依赖校验.md', '同目录：DS 侧依赖配置回读校验'),
    ('表中文名', 'DWD_表中文名.json', '同目录：DS 作业描述用'),
    ('搬移清单', '_DWD搬移清单.json', '同目录：分布、DDL 表数、归属表'),
]

LINK_FONT = Font(color='0563C1', underline='single')
LINK_FONT_LOCAL = Font(color='0563C1', underline='single', bold=True)
TITLE_FONT = Font(bold=True, size=16)
SUB_FONT = Font(bold=True, size=12, color='1F4E79')
NOTE_FONT = Font(italic=True, color='808080')


def _link_cell(cell, text, target, local=False):
    """写一个超链接单元格（内部跳转 or 相对路径外链）。"""
    cell.value = text
    cell.font = LINK_FONT_LOCAL if local else LINK_FONT
    if local:
        cell.hyperlink = Hyperlink(ref=cell.coordinate, location=target, display=text)
    else:
        cell.hyperlink = Hyperlink(ref=cell.coordinate, target=target, display=text)
    return cell


def build_cover(wb, title, subtitle, notes, links=None, sheets=None):
    """生成工作簿引导页：置为首个 sheet，含各 sheet 内部跳转 + 关联文件外链。"""
    ws = wb.create_sheet('引导页', 0)
    ws.sheet_view.showGridLines = False
    for col, w in zip('ABCD', (30, 14, 62, 46)):
        ws.column_dimensions[col].width = w

    ws['A1'] = title
    ws['A1'].font = TITLE_FONT
    ws.merge_cells('A1:D1')
    ws.row_dimensions[1].height = 26
    ws['A2'] = subtitle
    ws['A2'].font = NOTE_FONT
    ws.merge_cells('A2:D2')

    r = 4
    ws.cell(r, 1, '一、工作表导航（点击跳转）').font = SUB_FONT
    r += 1
    for i, h in enumerate(['工作表', '行数', '内容', '']):
        c = ws.cell(r, i + 1)
        c.value = h
        c.font = Font(bold=True)
        c.fill = PatternFill('solid', fgColor='DDEBF7')
    r += 1
    for st, desc in (sheets or COVER_SHEETS):
        if st not in wb.sheetnames:
            continue
        _link_cell(ws.cell(r, 1), st, "'%s'!A1" % st, local=True)
        ws.cell(r, 2, wb[st].max_row)
        ws.cell(r, 3, desc)
        r += 1

    r += 1
    ws.cell(r, 1, '二、关联文件（相对路径外链）').font = SUB_FONT
    r += 1
    for i, h in enumerate(['文件', '类型', '说明', '']):
        c = ws.cell(r, i + 1)
        c.value = h
        c.font = Font(bold=True)
        c.fill = PatternFill('solid', fgColor='DDEBF7')
    r += 1
    for name, fname, desc in (links if links is not None else COVER_LINKS):
        if not (SCRIPTS / fname).is_file():
            continue
        _link_cell(ws.cell(r, 1), fname, fname)
        ws.cell(r, 2, fname.rsplit('.', 1)[-1].upper())
        ws.cell(r, 3, desc)
        r += 1

    r += 1
    ws.cell(r, 1, '三、口径提示').font = SUB_FONT
    r += 1
    for tip in notes:
        c = ws.cell(r, 1, '· ' + tip)
        c.alignment = Alignment(vertical='top', wrap_text=True)
        ws.merge_cells(start_row=r, start_column=1, end_row=r, end_column=4)
        r += 1

    ws.freeze_panes = 'A4'
    return ws


def cmd_lineage(args):
    if not any(etl_dir(g).is_dir() for g in GROUPS):
        sys.exit('缺 scripts/{系统}/dwd/02_etl ⇒ 先跑 dwd-pipeline.py convert --apply')
    assign = resolved_assign(load_owner(write=args.apply), args.force_sys)
    all_stems = {p.stem: g for g in GROUPS for p in etl_dir(g).glob('*.sh')}
    rows = []
    for g in GROUPS:
        for p in sorted(etl_dir(g).glob('*.sh')):
            s = p.read_text(encoding='utf-8', errors='replace')
            real, srcs = _parse_script(p)
            cache = {}                      # src → (need, modes, part, why)
            for tgt in real:
                for src in srcs:
                    up = all_stems.get(src, '')
                    # ★ 2026-10-24：可配性。仓库里没有该上游的 ETL 脚本 ⇒ 没有可依赖的
                    #   工作流，depcfg 也一律过滤（配置表走 SCHEDULE_EXCLUDE、其余走
                    #   no_script_up）⇒ 这一列必须如实写「不配」，否则会跟 depcfg 打架：
                    #   实测 DWD_CMM_STD_DICT_CDVAL_MAP 有 94 行写成「需配」，一条都没配。
                    #   ⚠ ODS_ 开头的不算 —— 它们由 ods_* 工作流承载，depcfg 会去定位并配。
                    unconfigurable = (not up) and _layer(src) != 'ODS'
                    if up:
                        note = ''
                    elif _layer(src) == 'ODS':
                        note = '外部源(ODS)'
                    elif src in SCHEDULE_EXCLUDE:
                        note = CONFIG_NOTE
                    elif '_INT' in src:
                        note = '内部中间表(无脚本)'
                    else:
                        note = NOSCRIPT_NOTE
                    # ★ 2026-10-23：分区读取口径 + 调度依赖结论
                    if src not in cache:
                        need, ms, _why = needs_schedule_dep(s, src)
                        cache[src] = (need, ms, _partition_cell(s, src))
                    need, ms, part = cache[src]
                    if need is None:
                        dep = '-'
                    elif need is False:
                        # 「只读前一日」优先于「上游没脚本」：这条边既有 T-1 语义、
                        # 上游又确实没脚本，两个理由都要留痕，不该被后者盖掉。
                        dep = DROP_PREV
                    elif unconfigurable:
                        dep = DROP_CONFIG if src in SCHEDULE_EXCLUDE else DROP_NOSCRIPT
                    else:
                        dep = NEED_DEP
                    if need is False:
                        note = (note + '；' if note else '') + T1_NOTE
                    elif need and 'prev' in ms:
                        note = (note + '；' if note else '') + T1_MIXED_NOTE
                    rows.append([p.stem, g, tgt, src, _layer(src), up or '-',
                                 up or '-', note, part, dep])

    wb = Workbook()
    ws = wb.active
    ws.title = '依赖明细'
    ws.append(['脚本', '脚本归属', '目标表', '源表', '源层级', '上游脚本', '上游归属',
               '备注', '分区读取', '调度依赖'])
    bold, fill = Font(bold=True), PatternFill('solid', fgColor='DDEBF7')
    for c in ws[1]:
        c.font, c.fill = bold, fill
        c.alignment = Alignment(horizontal='center')
    for r in rows:
        ws.append(r)
    ws.freeze_panes = 'A2'
    for col, w in zip('ABCDEFGHIJ', (42, 10, 38, 38, 9, 38, 10, 62, 18, 15)):
        ws.column_dimensions[col].width = w
    # 备注里带完整口径原文 ⇒ 必须换行，否则列宽失控
    for row in ws.iter_rows(min_row=2):
        row[7].alignment = Alignment(vertical='top', wrap_text=True)

    ws2 = wb.create_sheet('汇总')
    # ★ 不设「DWS源」列：DWD 不依赖 DWS 层（实测 0 条），留空列属于混层
    ws2.append(['分组', '脚本数', '依赖边', 'ODS源', 'DWD源', '跨组依赖', '无上游脚本',
                '不配依赖(只读前一日)'])
    for c in ws2[1]:
        c.font, c.fill = bold, fill
    for g in GROUPS:
        rr = [r for r in rows if r[1] == g]
        ws2.append([
            g, len({r[0] for r in rr}), len(rr),
            len({r[3] for r in rr if r[4] == 'ODS'}),
            len({r[3] for r in rr if r[4] == 'DWD'}),
            len({(r[0], r[3]) for r in rr if r[6] not in ('-', '') and r[6] != g}),
            len({r[3] for r in rr if r[9] in (DROP_CONFIG, DROP_NOSCRIPT)}),
            len({(r[2], r[3]) for r in rr if r[9] == DROP_PREV}),
        ])
    for col, w in zip('ABCDEFGH', (10, 8, 8, 8, 8, 10, 12, 22)):
        ws2.column_dimensions[col].width = w

    ws5 = wb.create_sheet('表级血缘')
    ws5.append(['目标表', '归属', '脚本', '源表列表', '源表数', '上游脚本数'])
    for c in ws5[1]:
        c.font, c.fill = bold, fill
    tmap = {}
    for r in rows:
        tmap.setdefault(r[2], {'g': r[1], 's': r[0], 'src': []})
        if r[3] not in tmap[r[2]]['src']:
            tmap[r[2]]['src'].append(r[3])
    for t, v in sorted(tmap.items()):
        ups = sorted({all_stems[x] for x in v['src'] if x in all_stems})
        ws5.append([t, v['g'], v['s'], ', '.join(sorted(v['src'])), len(v['src']), len(ups)])
    for col, w in zip('ABCDEF', (40, 8, 40, 120, 8, 10)):
        ws5.column_dimensions[col].width = w

    ws3 = wb.create_sheet('无同名脚本上游')
    ws3.append(['源表', '源层级', '引用次数', 'DS 依赖', '不配原因', '被引脚本'])
    for c in ws3[1]:
        c.font, c.fill = bold, fill
    cnt = collections.defaultdict(set)
    reason = {}
    for r in rows:
        # ★ 判据用「调度依赖」列，不要用备注文案 —— 备注是可读说明，会随口径改字，
        #   用它做分支等于把展示文案当协议（2026-10-24 踩过）。
        if r[9] in (DROP_CONFIG, DROP_NOSCRIPT):
            cnt[r[3]].add(r[0])
            reason[r[3]] = (r[4], r[9], r[7])
    for t, scr in sorted(cnt.items(), key=lambda x: -len(x[1])):
        ws3.append([t, reason[t][0], len(scr), reason[t][1], reason[t][2],
                    ','.join(sorted(scr))])
    for col, w in zip('ABCDEF', (44, 9, 9, 18, 70, 90)):
        ws3.column_dimensions[col].width = w
    for row in ws3.iter_rows(min_row=2):
        row[4].alignment = Alignment(vertical='top', wrap_text=True)

    ws4 = wb.create_sheet('跨组依赖')
    ws4.append(['脚本', '脚本归属', '源表', '上游归属'])
    for c in ws4[1]:
        c.font, c.fill = bold, fill
    seen = set()
    for r in rows:
        if r[6] not in ('-', '') and r[6] != r[1]:
            k = (r[0], r[3])
            if k in seen:
                continue
            seen.add(k)
            ws4.append([r[0], r[1], r[3], r[6]])
    for col, w in zip('ABCD', (44, 10, 46, 10)):
        ws4.column_dimensions[col].width = w

    # ★ 2026-10-23 新增页：只按前一日惯用式读取 ⇒ **不配**调度依赖的边
    ws8 = wb.create_sheet('不配依赖(读前一日)')
    ws8.append(['目标表', '目标脚本', '上游表', '上游脚本', '分区读取',
                'DS 依赖', '判定口径（前一日惯用式）', '理由'])
    for c in ws8[1]:
        c.font, c.fill = bold, fill
    # ★ 只收「只读前一日」；「配置表排除 / 上游无脚本」另见「无同名脚本上游」页
    t1rows = [r for r in rows if r[9] == DROP_PREV]
    REASON = ('该边在脚本里【每一处】读取上游都只用前一日分区（批次日-1），'
              '当日实例不产出该分区 ⇒ 依赖等的是上游昨天的实例，永远等不到；'
              '若同时存在反向边还会互等死锁（2026-10-23 DWD_SCR 卡死 25 分钟即此因）。'
              '故不配置调度依赖，仅在本页留痕。')
    for r in sorted(t1rows):
        ws8.append([r[2], r[0], r[3], r[5], r[8], '不配置', PREV_IDIOM_DOC, REASON])
    if not t1rows:
        ws8.append(['（本次扫描无此类边）', '', '', '', '', '', '', ''])
    for col, w in zip('ABCDEFGH', (40, 40, 38, 38, 14, 10, 62, 66)):
        ws8.column_dimensions[col].width = w
    ws8.freeze_panes = 'A2'
    for row in ws8.iter_rows(min_row=2):
        for c in row:
            c.alignment = Alignment(vertical='top', wrap_text=True)

    ws6 = wb.create_sheet('语法校验')
    ws6.append(['检查项', '结果', '说明'])
    for c in ws6[1]:
        c.font, c.fill = bold, fill
    per, total, bad, skipped = {}, 0, [], 0
    for g in GROUPS:
        n, b, sk = _shell_check(etl_dir(g))
        per[g], total, bad = n, total + n, bad + b
        skipped += sk
    # ★ 全被拦截时不能写成「109/109 通过」——那是把"没跑"伪装成"通过"。
    shell_res = (f'{total - len(bad)}/{total} 通过' if skipped < total
                 else f'未执行（{skipped}/{total} 被环境安全策略拦截）')
    ws6.append(['Shell 语法 (bash -n)', shell_res,
                ' / '.join(f'{g} {per[g]}' for g in GROUPS)])
    hive = _hive_result()
    failed_names = []
    if hive:
        d = hive.get('ddl') or {}
        e = hive.get('etl') or {}
        df, ef = d.get('failed') or [], e.get('failed') or []
        dt, et = d.get('total', 0), e.get('total', 0)
        failed_names = [x.get('table', str(x)) if isinstance(x, dict) else str(x) for x in ef]
        ws6.append(['Hive DDL 编译（沙箱建表）', f'{dt - len(df)}/{dt} 通过',
                    '甲方 DDL 方言清洗：DEFAULT NULL 剔除、VARCHAR2→STRING、保留字列 DATE 反引号'])
        if len(failed_names) == 1:
            note = f'仅 {failed_names[0]} 因上游 ODS 缺表未通过（非脚本语法问题）'
        elif failed_names:
            note = '未通过：' + ' / '.join(failed_names) + '（多为上游缺表，非脚本语法问题）'
        else:
            note = '全部通过'
        ws6.append(['Hive ETL 编译（EXPLAIN）', f'{et - len(ef)}/{et} 通过', note])
    else:
        ws6.append(['Hive DDL/ETL 编译', '未执行', '用 tools/ds-deploy/validate-dwd-syntax.py 生成报告'])
    ws6.append(['', '', ''])
    ws6.append(['方言/缺陷修复（89 个非主数据脚本）', '次数', '规则'])
    for c in ws6[ws6.max_row]:
        c.font, c.fill = bold, fill
    stats = new_stats()
    for t in sorted(assign):
        p = JF / (t + '.txt')
        if p.exists():
            # ★ 2026-10-22：兜底（统计用途，坏 txt 跳过即可，不应中断报告生成）
            try:
                convert(p.read_text(encoding='utf-8', errors='replace'), stats, t)
            except ValueError:
                continue
    labels = {
        'safety': '插入 set hive.strict.checks.type.safety=false;',
        'sets_dropped': '删除禁用 SET（input.format / inceptor.cross.join）',
        'date_format3': '三参 DATE_FORMAT → 两参',
        'as_date': 'AS DATE → AS `DATE`（反引号转义）',
        'evt_cast': 'UNION 第二支字符串字面量 → CAST(... AS DECIMAL)',
        'dedupe_head': '重复 #!/bin/sh 头去重',
        'sysdate': 'SYSDATE → DATE_FORMAT(CURRENT_DATE)',
        'scr_cast': 'SCR union 前三列 CAST(... AS STRING)',
        'partition': 'PARTITION 漏写补齐',
        'subt1': '子查询缺别名补 SUBT1',
    }
    notes = {
        'safety': '类型安全校验，避免隐式转换报错',
        'sets_dropped': 'Hive 4.2 不支持',
        'date_format3': 'Hive 4.2 仅支持 2 参',
        'as_date': 'DATE 为保留字',
        'evt_cast': '甲方脚本缺陷：setop 类型不一致（REPO_PRC/QTY/EQUI_RATE）',
        'dedupe_head': '个别脚本头粘连',
        'sysdate': 'SYSDATE 兼容',
        'scr_cast': 'UNION 分支类型对齐',
        'partition': '静态分区补齐',
        'subt1': 'Hive 4.2 要求子查询别名',
    }
    for k in ('safety', 'sets_dropped', 'date_format3', 'as_date', 'evt_cast',
              'dedupe_head', 'sysdate', 'scr_cast', 'partition', 'subt1'):
        if stats[k]:
            ws6.append([labels[k], stats[k], notes[k]])
    ws6.append(['source ${hadoop_env}/${source_path} → /home/dolphinscheduler/hadoop_env',
                total, 'DS 环境变量收敛'])
    ws6.append(['', '', ''])
    ws6.append(['上游缺口', '说明', ''])
    for c in ws6[ws6.max_row]:
        c.font, c.fill = bold, fill
    if 'DWD_CHNL_EXT_BTCH_INFO_PFD' in failed_names:
        ws6.append(['ODS_OA_AGENCY_VIEW_PFD',
                    '集群 ods_xday_oa 无此表（仅 hierarchy/saletran 两张）', '需补 OA 系统 ODS 采集'])
    ws6.append(['DWD_CMM_STD_DICT_CDVAL_MAP',
                '主数据字典表（0 行，仅 DDL），无 ETL 脚本，符合主数据口径', ''])
    ws6.column_dimensions['A'].width = 52
    ws6.column_dimensions['B'].width = 24
    ws6.column_dimensions['C'].width = 110
    for row in ws6.iter_rows(min_row=1):
        for c in row:
            c.alignment = Alignment(vertical='top', wrap_text=True)

    ws7 = wb.create_sheet('说明')
    ws7.append(['项目', '内容'])
    for c in ws7[1]:
        c.font, c.fill = bold, fill
    n_sh_all = sum(len(list(etl_dir(g).glob('*.sh'))) for g in GROUPS)
    n_ddl_all = sum(len(list(ddl_dir(g).glob('*.sql'))) for g in GROUPS)
    info_rows = [
        ['生成时间', time.strftime('%Y-%m-%d %H:%M:%S')],
        ['脚本范围', 'scripts/{系统}/dwd/02_etl 下 %d 个脚本（HSFA 22 / HSZTA 26 / O32 38 / 主数据 23）'
         % n_sh_all],
        ['建表语句', 'scripts/{系统}/dwd/ddl 下 %d 张表 + 各系统 01_ddl.sql；汇总在 scripts/建表语句/' % n_ddl_all],
        ['依赖口径', '从脚本 INSERT 目标与 FROM/JOIN 源表解析；_TMP 不计入主依赖'],
        ['上游层级', '上游是 ODS 或 DWD 同层表；DWD 不依赖 DWS 层（实测 0 条）'],
        ['主数据口径', 'scripts/MASTER/dwd/02_etl 的 23 个为主数据手工稿；2026-10-23 起随 DWD 批次跑真实脚本'],
        ['甲方来源', '甲方 05-脚本/02-脚本/01-DWD执行脚本/*.txt 经 dwd-pipeline.py convert 转换（J-28 方言修复）'],
        ['排除脚本', '甲方 3 个 _INIT 脚本按设计排除；DS 上重建 DWD 后 INIT 作业自动消失'],
        ['空脚本占位', '无（SALE_FEER / TAIL / WARN_HIS 三张已于 2026-10-27 通过逐条 EXPLAIN 转正，DS 配真实脚本）'],
        ['注意', 'DWD_CMM_CALENDAR_INFO_PFD 实际存在，不是 PUB 表；不要按旧结论替换'],
    ]
    for r in info_rows:
        ws7.append(r)
    ws7.column_dimensions['A'].width = 20
    ws7.column_dimensions['B'].width = 110
    for row in ws7.iter_rows(min_row=1):
        for c in row:
            c.alignment = Alignment(vertical='top', wrap_text=True)

    n_sh = sum(len(list(etl_dir(g).glob('*.sh'))) for g in GROUPS)
    n_ddl = sum(len(list(ddl_dir(g).glob('*.sql'))) for g in GROUPS)
    build_cover(
        wb,
        'DWD 依赖关系工作簿 · 引导页',
        f'交付范围：{len(GROUPS)} 个分组 / {n_sh} 个脚本 / {n_ddl} 张建表语句'
        f'（HSFA 22 / HSZTA 26 / O32 38 / 主数据 23）',
        [
            '本工作簿 = scripts/{系统}/dwd/02_etl 下 DWD 脚本的逻辑梳理结果（甲方 01-DWD执行脚本 转换而来）。',
            '「语法校验」= Shell bash -n + Hive DDL 沙箱建表 + Hive EXPLAIN 编译（不执行、不落数据）。',
            '主数据（MASTER）组为主数据手工稿，与甲方 txt 存在历史漂移；DS 侧为占位，不参与 DWD 批次。',
            '上游表无同名脚本 = 该表由 ODS 层或中间层提供，不是缺脚本；详见「无同名脚本上游」页。',
            '★ 依赖口径（2026-10-23 用户指定）：脚本按【前一日分区】读取上游时，'
            '等的是上游**昨天**的实例，当日实例永远满足不了 ⇒ 不配置调度依赖，'
            '清单见「不配依赖(读前一日)」页。',
            '★ 前一日分区 = 这个**字面形态**（不是「含 DATE_SUB 就算」）：P_DT = ' + PREV_IDIOM_DOC,
            '★ 分区口径依据：各工作流全局参数 p_end_dt / P_BATCH_DT = ${system.biz.date}'
            '（= 运行日-1 = 批次日）；故 CURRENT_TIMESTAMP-1 与 ${p_end_dt} 是**同一个分区**，'
            '只有上式 DATE_SUB(...,1) 才是真正的前一日。'
            'P_BATCH_DT 变体与 p_end_dt 同值，但不在本口径内 ⇒ 只报不删，见 tools/_prev_day_deps.json '
            '的 prev_alike_pending。',
            '甲方 3 个 _INIT 脚本按设计排除（重建 DWD 后 DS 上的 INIT 作业自动消失）。',
            '本工作簿只做 DWD 层分析；DWD 不依赖 DWS 层。',
        ])

    out = SCRIPTS / 'DWD_依赖关系.xlsx'
    if args.apply:
        # ★ 目标 xlsx 常被 Excel 打开占用（PermissionError: Errno 13）。
        #   跑一遍 lineage 要几分钟，不能因为文件被占就整轮白费 ⇒ 降级写到 .new 文件，
        #   并明确告诉用户怎么落地，不要静默失败。
        try:
            wb.save(out)
        except PermissionError:
            alt = out.with_name(out.stem + time.strftime('_new-%H%M%S') + out.suffix)
            wb.save(alt)
            print(f'⚠ {out.name} 被占用（多半是 Excel 开着），已改写到：\n    {alt}\n'
                  f'  关掉 Excel 后把它改名覆盖 {out.name} 即可。')
            out = alt
        print(f'写出 {out}（依赖明细 {len(rows)} 行，跨组 {len(seen)}，'
              f'不配依赖 {len(t1rows)} 条）')
    else:
        shell_txt = (f'Shell {total - len(bad)}/{total}' if skipped < total
                     else f'Shell 未执行({skipped}/{total} 被拦截)')
        print(f'(dry-run) 依赖明细 {len(rows)} 行，跨组 {len(seen)}，{shell_txt}')
    print('分组:', {g: sum(1 for r in rows if r[1] == g) for g in GROUPS})
    print('无同名脚本上游:', len(cnt), '| 跨组边:', len(seen), '| 不配依赖(T-1):', len(t1rows))
    for r in t1rows:
        print(f'   · {r[2]}  ←  {r[3]}')
    if bad:
        print('Shell 语法失败:', bad[:5])
    return 0


# --------------------------------------------------------------------------- #
# 上一日分区依赖扫描（2026-10-23）
# --------------------------------------------------------------------------- #
# ★ 为什么要有这个子命令
#   `ds-build-dependent-from-lineage.py --exclude-prev-day` 需要一份
#   「上游按批次日-1 读取」的边清单。旧清单由已废弃的 tools/_scan_prev_day_deps.py
#   产出，它按**文本行窗口**匹配 T-1 惯用式，上游表定位不准（16 条里混进了
#   (表, 自己的 _TMP) 这类无效边）。本命令改用 alias 解析 + 语句切分，
#   并且只在【该上游表的所有读取口径都是 prev】时才输出 —— 只要还有一处
#   按当天/最新快照读，这条边就必须保留。
#
# 输出格式（与 ds-build-dependent-from-lineage.py 约定一致）：
#   {"edges": [[目标表, 上游表, 口径片段, 出处], ...], "by_target": {...}}
PREVDAY_OUT = REPO / 'tools/_prev_day_deps.json'


def cmd_prevday(args):
    top = Path(args.out)
    edges, skipped_mixed, self_edges, no_ref, alike = [], [], [], 0, []
    units = [(g, etl_dir(g), 'DWD') for g in GROUPS] + \
            [(g, dws_etl_dir(g), 'DWS') for g in SYS]        # ★ DWD + DWS 都扫
    seen_files = set()
    for g, d, layer in units:
        if not d.is_dir():
            continue
        for p in sorted(d.glob('*.sh')):
            if p.resolve() in seen_files:
                continue
            seen_files.add(p.resolve())
            s = p.read_text(encoding='utf-8', errors='replace')
            real, srcs = _parse_script(p)
            for src in srcs:
                need, ms, _why = needs_schedule_dep(s, src)
                if need is None:
                    no_ref += 1
                    continue
                rel = str(p.relative_to(REPO)).replace('\\', '/')
                if need is False:
                    if src == p.stem.upper():
                        self_edges.append((p.stem, src))
                        continue
                    edges.append([p.stem.upper(), src, PREV_IDIOM_DOC, rel, layer])
                elif 'prev' in ms:
                    skipped_mixed.append((p.stem, src, sorted(ms), layer))
                elif 'prev_alike' in ms:
                    # ★ 同值同义但不在本口径内 ⇒ 只报不删，等用户确认
                    alike.append((p.stem, src, sorted(ms), layer, rel))

    doc = {
        'generated': time.strftime('%Y-%m-%d %H:%M:%S'),
        'rule': '目标表脚本对上游表的【每一处】读取都是前一日惯用式 '
                + PREV_IDIOM_DOC + ' ⇒ 不配调度依赖',
        'scope': 'DWD + DWS（scripts/*/dwd/02_etl、scripts/*/dws/02_etl）',
        'edges': edges,
        'by_target': {},
        'mixed_kept': [{'target': t, 'upstream': u, 'modes': m, 'layer': l}
                       for t, u, m, l in skipped_mixed],
        'prev_alike_pending': [{'target': t, 'upstream': u, 'modes': m,
                                'layer': l, 'script': f}
                               for t, u, m, l, f in alike],
    }
    for t, u, *_ in edges:
        doc['by_target'].setdefault(t, []).append(u)

    n_dwd = sum(1 for e in edges if e[4] == 'DWD')
    print(f'★ 只读前一日分区 ⇒ 不配调度依赖的边：{len(edges)} 条'
          f'（DWD {n_dwd} / DWS {len(edges) - n_dwd}）')
    for t, u, _c, _f, layer in edges:
        print(f'   [{layer}] {t}  ←  {u}')
    print(f'\n含前一日但也有当天读取（依赖必须保留）：{len(skipped_mixed)} 条')
    for t, u, m, layer in skipped_mixed:
        print(f'   [{layer}] {t}  ←  {u}   {m}')
    if alike:
        print(f'\n⚠ P_BATCH_DT 变体（与 p_end_dt 同值但非本口径 ⇒ 只报不删，待确认）：{len(alike)} 条')
        for t, u, m, layer, rel in alike:
            print(f'   [{layer}] {t}  ←  {u}   {m}   ({rel})')
    if self_edges:
        print(f'\n（忽略 {len(self_edges)} 条自指边，如 {self_edges[0]}）')
    if no_ref:
        print(f'（{no_ref} 条边的上游在脚本里找不到引用，未计入）')

    if args.apply:
        PREVDAY_OUT.parent.mkdir(parents=True, exist_ok=True)
        PREVDAY_OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=1),
                               encoding='utf-8')
        print(f'\n写出 {PREVDAY_OUT}')
    else:
        print('\n(dry-run，未落盘)')
    return 0


# --------------------------------------------------------------------------- #
# DS 依赖配置
# --------------------------------------------------------------------------- #
def _load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _script_of(table):
    for s in os.listdir(SCRIPTS):
        p = SCRIPTS / s / 'dwd/02_etl' / (table + '.sh')
        if p.is_file():
            return str(p)
    return None


def _ods_chunks(sys_name):
    d = SCRIPTS / sys_name / 'ods/etl_sh'
    if not d.is_dir():
        return []
    files = sorted(f[:-3] for f in os.listdir(d)
                   if f.endswith('.sh') and not f.startswith('.') and 'deploy-to-worker' not in f)
    return [(i // 20 + 1, files[i:i + 20]) for i in range(0, len(files), 20)]


def _locate_ods(table):
    sys_name = table.split('_')[1]
    chunks = _ods_chunks(sys_name)
    for n, ts in chunks:
        if table in ts:
            return 'ods_%s_etl_%02d' % (sys_name.lower(), n)
    allt = [t for _, ts in chunks for t in ts]
    close = difflib.get_close_matches(table, allt, n=1, cutoff=0.6)
    if close:
        for n, ts in chunks:
            if close[0] in ts:
                return 'ods_%s_etl_%02d' % (sys_name.lower(), n)
    return None


WORKFLOW_OVERRIDE = {
    # 2026-10-23（用户决定）：搬到 DWD_PROD。
    # 它唯一的上游映射表 DWD_PROD_SFAC_NUM_MAPP_PFD 在 DWD_PROD；留在 DWD_PTY 会形成
    # 工作流级环（PROD 等 PTY，PTY 的 dep 节点又等 PROD）⇒ PTY 跑 40+ 分钟卡在
    # dep_DWD_PTY_OPER_FUND_PRVL_PFD。与 ds-deploy/ds-build-dependent-from-lineage.py 保持一致。
    'DWD_PTY_OPER_FUND_PRVL_PFD': 'DWD_PROD',
    # 2026-10-23（用户决定）：搬到 DWD_PROD —— 上游映射表 DWD_PROD_SFAC_NUM_MAPP_PFD 在 PROD，
    # 留在 DWD_CMM 就是 DWD_CMM → DWD_PROD 的跨流作业级等待。
    'DWD_CMM_INTR_PARA_PFD': 'DWD_PROD',
}


def _own_workflow(table):
    t = str(table).upper()
    if t in WORKFLOW_OVERRIDE:
        return WORKFLOW_OVERRIDE[t]
    m = re.match(r'^(DWD)_([A-Z0-9]+)_', t)
    return 'DWD_' + m.group(2) if m else '(未知)'


def cmd_depcfg(args):
    L = _load_module('LINEAGE_BUILDER',
                     str(REPO / 'tools/ds-deploy/ds-build-dependent-from-lineage.py'))
    xlsx = SCRIPTS / 'DWD_依赖关系.xlsx'
    if not xlsx.exists():
        sys.exit(f'缺 {xlsx} ⇒ 先跑 dwd-pipeline.py lineage --apply')
    # ★ 2026-10-23：改用 openpyxl 读（本文件本来就硬依赖 openpyxl），
    #   不再为了读一张表引入 pandas —— 交付环境常常没装 pandas。
    ws = load_workbook(xlsx, read_only=True, data_only=True)['依赖明细']
    it = ws.iter_rows(values_only=True)
    hdr = [str(x or '').strip() for x in next(it)]
    idx = {h: i for i, h in enumerate(hdr)}
    need = ('目标表', '源表')
    for c in need:
        if c not in idx:
            sys.exit(f'{xlsx} 的「依赖明细」缺少「{c}」列（表头={hdr}）')
    rows = collections.defaultdict(list)
    # 「调度依赖」列由 lineage 子命令按 alias 解析脚本分区口径算出。
    # ★ 现在有三种「不配」，语义不同，必须分开计数（否则诊断信息全糊成一坨）：
    #     不配(只读前一日)  → T-1 口径免配
    #     不配(配置表排除)  → 命中 SCHEDULE_EXCLUDE（映射表/码表）
    #     不配(上游无脚本)  → 仓库里根本没有该上游的 ETL 脚本
    #   老版本工作簿没这列时退化为全量建边（不静默改变行为，但要打警告）。
    di = idx.get('调度依赖')
    dropped_kind = collections.Counter()     # 按原因分类计数
    drop_by_target = collections.Counter()
    prev_by_target = collections.Counter()   # 只读前一日 的逐表分布（用于打印）
    # ★ 这两个计数器仍由下面的 per-target 循环自增（命中 SCHEDULE_EXCLUDE /
    #   上游无同名脚本），诊断打印要用到；重构时被误删过声明，务必保留。
    excluded = collections.Counter()
    no_script_up = collections.Counter()
    if di is None:
        print('⚠ 工作簿缺「调度依赖」列 ⇒ 无法过滤免配边，'
              '请先跑 dwd-pipeline.py lineage --apply 重新生成')
    for r in it:
        t = str(r[idx['目标表']] or '').strip()
        u = str(r[idx['源表']] or '').strip()
        if not t or not u:
            continue
        cell = str(r[di] or '').strip() if di is not None else ''
        if cell == DROP_PREV:
            # ★ 只有这一类在解析阶段就丢掉（与旧行为一致：连 rows 的 key 都不建）。
            #   「配置表排除 / 上游无脚本」**必须仍然 append 进 rows** —— rows 是
            #   defaultdict，key 在 append 时才创建；若在这里 continue，那些
            #   「只被配置表引用」的目标表会整个从 cfgs 里消失、连空的 .dep.json
            #   都不再产出（2026-10-24 实测：DWD_PTY 11→10、DWD_PROD 18→19，
            #   破环数 2→1 —— 就是被这个 continue 吃掉的）。
            #   交给下面既有的 SCHEDULE_EXCLUDE / _script_of 过滤，行为零变化。
            dropped_kind[cell] += 1
            drop_by_target[t] += 1
            prev_by_target[t] += 1
            continue
        if cell in (DROP_CONFIG, DROP_NOSCRIPT):
            dropped_kind[cell] += 1
            drop_by_target[t] += 1
        rows[t].append(u)

    targets = [t for t in rows if _script_of(t)]
    cfgs = {}
    unresolved = []
    for t in sorted(targets):
        wf = _own_workflow(t)
        same, cross = [], collections.OrderedDict()
        for u in sorted(set(rows[t])):
            if u == t:
                continue
            if u in SCHEDULE_EXCLUDE:
                excluded[u] += 1
                continue
            if u.startswith('ODS_'):
                w = _locate_ods(u)
                if not w:
                    unresolved.append((t, u, 'ODS 未定位'))
                    continue
            else:
                w = _own_workflow(u)
                if w == '(未知)':
                    unresolved.append((t, u, '无法解析主题'))
                    continue
                if not _script_of(u):
                    no_script_up[u] += 1
                    continue
            if w == wf:
                same.append({'source': u, 'source_cn': ''})
            else:
                cross.setdefault(w, []).append({'source': u, 'source_cn': ''})
        cfgs[t] = {
            'target': t, 'target_cn': '', 'layer': 'DWD', 'own_workflow': wf,
            'dependency_rows': len(rows[t]),
            'cross_workflow': [{'workflow': w, 'code': None, 'sources': v}
                               for w, v in cross.items()],
            'same_workflow_predecessors': same,
            'mapping_deps': [], 'no_workflow_sources': [], 'unresolved_workflows': [],
            'dependent_task_params': L.dep_params(),
            '_source': 'scripts/DWD_依赖关系.xlsx',
        }

    for t in sorted({p.stem for g in SYS for p in etl_dir(g).glob('*.sh')} - set(cfgs)):
        cfgs[t] = {
            'target': t, 'target_cn': '', 'layer': 'DWD', 'own_workflow': _own_workflow(t),
            'dependency_rows': 0, 'cross_workflow': [], 'same_workflow_predecessors': [],
            'mapping_deps': [], 'no_workflow_sources': [], 'unresolved_workflows': [],
            'dependent_task_params': L.dep_params(),
            '_source': 'scripts/DWD_依赖关系.xlsx (无依赖行)',
        }

    edge_info = collections.defaultdict(dict)
    for t, c in cfgs.items():
        for g in c['cross_workflow']:
            if g['workflow'].startswith(('DWD_', 'MASTER_')):
                edge_info[(g['workflow'], c['own_workflow'])].setdefault(t, [])
    cut = set(L.break_wf_cycles(edge_info, {}))
    cutset = set(cut)
    for c in cfgs.values():
        wf = c['own_workflow']
        kept, dropped = [], 0
        for g in c['cross_workflow']:
            if g['workflow'].startswith(('DWD_', 'MASTER_')) and \
                    (g['workflow'], wf) in cutset:
                dropped += len(g['sources'])
                continue
            kept.append(g)
        c['cross_workflow'] = kept
        c['_cut_dropped'] = dropped

    wf_members = collections.Counter(c['own_workflow'] for c in cfgs.values())
    print(f'依赖配置：{len(cfgs)} 张表 / {len(wf_members)} 个工作流；破环切断 {len(cutset)} 条工作流边')
    if dropped_kind:
        print(f'★ 免配（不建调度依赖）的边共 {sum(dropped_kind.values())} 条，'
              f'涉及 {len(drop_by_target)} 张目标表：')
        for k in (DROP_PREV, DROP_CONFIG, DROP_NOSCRIPT):
            if dropped_kind.get(k):
                print(f'     {k:<18} {dropped_kind[k]:4d} 条')
        # 只有「只读前一日」值得逐表列出来（通常两三张表）；
        # 「配置表排除」动辄 90+ 张表、每张 1 条，逐表列只会把有用的信息淹掉。
        for t, n in sorted(prev_by_target.items()):
            print(f'     [只读前一日] {t:40s} 免配 {n} 条')
    print('归属:', dict(sorted(wf_members.items())))
    print('无脚本上游（已过滤）:', dict(no_script_up))
    print('配置表自动过滤:', dict(excluded), '| 无法解析:', len(unresolved))
    for x in unresolved[:10]:
        print('  ', x)

    out = Path(args.out)
    if not args.apply:
        print('(dry-run，未落盘)')
        return 0
    out.mkdir(parents=True, exist_ok=True)
    for t, c in cfgs.items():
        (out / (t + '.dep.json')).write_text(
            json.dumps(c, ensure_ascii=False, indent=1), encoding='utf-8')
    # ★ 2026-10-26：原先是「先删光再写」，两个问题：
    #   ① 50+ 个文件批量删除会撞环境的安全删除闸门（整批中止，产物只剩一半）；
    #   ② Windows 安全删除 shim 偶发 SHFileOperationW 0x2 直接抛异常。
    #   改为「直接覆盖 + 只清理真正的 stale」，删不掉只告警，不中断产出。
    planned = {k.upper() for k in cfgs}
    # ★ 注意 `f.stem` 对 `X.dep.json` 只去掉 `.json`（得 `X.dep`），必须按完整后缀切。
    stale = [f for f in out.glob('*.dep.json')
             if f.name[:-len('.dep.json')].upper() not in planned]
    for f in stale:
        try:
            f.unlink()
        except OSError as e:
            print(f'  ⚠ 残留未清理: {f.name}（{e}）')
    print(f'写出 {len(cfgs)} 份到 {out}'
          + (f' | 清理 stale {len(stale)} 份' if stale else ''))
    return 0


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
        local = {p.stem: p for g in SYS for p in etl_dir(g).glob('*.sh')}
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


if __name__ == '__main__':
    sys.exit(main())
