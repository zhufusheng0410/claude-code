# -*- coding: utf-8 -*-
"""DWD DDL 落盘与自检。"""
# -*- coding: utf-8 -*-
import collections
import difflib
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

from tools.core.loader import load as _load_file

from tools.dwd import export_ns
from tools.dwd import ns as _ns
from tools.dwd import parsing as _parsing
export_ns(_ns, globals())
export_ns(_parsing, globals())

# --------------------------------------------------------------------------- #
# DDL
# --------------------------------------------------------------------------- #
RE_CREATE = re.compile(
    r'CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:[A-Za-z0-9_]+\.)?([A-Za-z0-9_]+)', re.I)
# ★ 2026-11-10（评审 M2）：`TGT` 与 `ns.TGT` 逐字相同，已由 export_ns 引入。
#   本处不再重复定义 —— 两份副本改一处忘另一处就会让解析口径漂移。
NEED_DDL = [
    'DWD_AST_BAL_INFO_PTD', 'DWD_AST_BAL_INFO_PTD_TMP',
    'DWD_CMM_CALENDAR_INFO_PFD',
    'DWD_EVT_PROD_EQUI_INFO_PTD', 'DWD_EVT_TA_SALE_DATA_PTD',
    'DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP1', 'DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP2',
    'DWD_PROD_PROD_TAIL_PFD_TMP',
    'DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP1', 'DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP2',
]


_CORE_DDL_SANITIZE = _load_file(Path(__file__).resolve().parents[1] / 'core' / 'ddl_sanitize.py',
                                '_ddl_sanitize')


def _load_shared_sanitize():
    """`sanitize_ddl` 的单一来源：`tools/core/ddl_sanitize.py`（只依赖 re）。

    ★ 2026-10-26：原先 `dw-pipeline.py` 为了复用下面这几行正则，要 exec 整个本模块
      （86KB，连带 openpyxl/pandas）⇒ 缺 openpyxl 的环境里 DWS DDL 直接崩。
      抽成独立小模块后，两边都不再引入重依赖。
    """
    return _CORE_DDL_SANITIZE.sanitize_ddl


def _load_shared_strip_drop():
    """`strip_drop_stmts` 的单一来源（同一模块，DWD/DWS 两条 DDL 链路共用）。

    ★ 2026-11-09（评审 A1）：甲方 DDL 的 `DROP TABLE IF EXISTS` **可能不带分号**，
      只认「DROP 行以 ; 结尾」的剥法会漏剥 ⇒ DROP 与 CREATE 粘连成一条语句，
      beeline 执行即 ParseException（DWS 侧已实证，见 ddl_sanitize 模块注释）。
    """
    return _CORE_DDL_SANITIZE.strip_drop_stmts


sanitize_ddl = _load_shared_sanitize()
strip_drop_stmts = _load_shared_strip_drop()


def _load_ddl_verify():
    """`tools/core/ddl_verify.py`（DDL 结构比对 + 语句边界 lint，与 DWS 共用）。"""
    return _load_file(Path(__file__).resolve().parents[1] / 'core' / 'ddl_verify.py',
                      '_ddl_verify')


def verify_ddl_after_write(have: dict, stmts: dict) -> list:
    """DWD DDL 落盘后自检：逐表与甲方原文比对 + 语句边界 lint。

    ★ 2026-11-09（评审 A8）：DWD 侧原先**没有落盘自检**——DWS 有、DWD 没有，
      同一个仓库两套标准。`ddl --apply` 写坏文件（剥 DROP 漏掉、清洗改错列、
      旧文件没被覆盖）只能靠事后 `verify-ddl` 或上 beeline 才发现。
      这里改为与 DWS 同一套 `diff_ddl` + `lint_statements`。

    返回问题列表（空 = 全部一致）；每项为 `{table, sysname, diff, probs}`。
    """
    verify = _load_ddl_verify()
    out = []
    for table, (sysname, _s) in have.items():
        local = ddl_dir(sysname) / f'{table}.sql'
        if not local.is_file():
            out.append({'table': table, 'sysname': sysname, 'diff': None,
                        'probs': ['本地文件不存在']})
            continue
        text = local.read_text(encoding='utf-8', errors='replace')
        diff = verify.diff_ddl(stmts[table] + ';', text, '甲方', '本地')
        probs = verify.lint_statements(text)
        if probs or not diff.empty():
            out.append({'table': table, 'sysname': sysname, 'diff': diff,
                        'probs': probs})
    return out


def _report_dwd_ddl_drift(bad: list):
    """把 DWD 落盘自检的问题写成 Markdown（与 DWS 的 ddl-drift 报告同目录）。"""
    ts = time.strftime('%Y%m%d-%H%M%S')
    report = _ns.REPO / 'tools/.dx-tmp' / f'ddl-drift-dwd-{ts}.md'
    report.parent.mkdir(parents=True, exist_ok=True)
    lines = [f'# DWD DDL 落盘自检报告 ({ts})', '', f'来源: {JF_DDL}', '']
    for item in bad:
        t, s, diff, probs = item['table'], item['sysname'], item['diff'], item['probs']
        lines.append(f'## {t} ({s})')
        if diff is not None:
            lines.append(f'- 摘要: {diff.summary()}')
            if diff.type_mismatch:
                lines.append('### 类型不一致')
                for col, lt, rt in diff.type_mismatch:
                    lines.append(f'- {col}: 甲方 `{lt}` / 本地 `{rt}`')
            if diff.comment_mismatch:
                lines.append('### 注释不一致')
                for col, lc, rc in diff.comment_mismatch:
                    lines.append(f'- {col}: 甲方 `{lc}` / 本地 `{rc}`')
            if diff.partition_mismatch:
                lines.append('### 分区不一致')
                lines.append(f'- 甲方: {[(c.name, c.type) for c in diff.left_partitions]}')
                lines.append(f'- 本地: {[(c.name, c.type) for c in diff.right_partitions]}')
            if diff.table_comment_mismatch:
                lines.append('### 表注释不一致')
                lines.append(f'- 甲方: `{diff.table_comment_mismatch[0]}`')
                lines.append(f'- 本地: `{diff.table_comment_mismatch[1]}`')
            if diff.only_in_left:
                lines.append(f'- 仅甲方有列: {", ".join(diff.only_in_left)}')
            if diff.only_in_right:
                lines.append(f'- 仅本地有列: {", ".join(diff.only_in_right)}')
        if probs:
            lines.append('### 语句边界')
            for p in probs:
                lines.append(f'- {p}')
        lines.append('')
    report.write_text('\n'.join(lines), encoding='utf-8')
    print(f'  差异报告: {report}')


def parse_jf_ddl():
    """甲方 01-DWD建表脚本.sql → {表名大写: 该表 CREATE 语句原文}。

    ★ 2026-11-09（评审 A1）：补上 `strip_drop_stmts` 剥 DROP（分号可有可无）。
      甲方 DWD 建表脚本当前**一条 DROP 都没有**，此改动对现盘是 no-op；
      但 DWS 侧已经实测过「DROP 缺分号 + 紧跟 CREATE」这种写法，DWD 下次
      更新若出现同样形态就会被静默带进 `ddl/*.sql` 与 `01_ddl.sql`。
      两条 DDL 链路从此共用 `core/ddl_sanitize.py` 的同一套剥离规则。
    """
    raw = JF_DDL.read_text(encoding='utf-8', errors='replace')
    stmts = {}
    for chunk in re.split(r';\s*(?:\r?\n)', raw):
        m = RE_CREATE.search(chunk)
        if m:
            stmts.setdefault(m.group(1).upper(),
                             strip_drop_stmts(chunk.strip()))
    return stmts


def cmd_ddl(args):
    # ★ 2026-11-09（评审 C3）：主数据也有 DWD 脚本（scripts/MASTER/dwd/02_etl），
    #   只查 SYS 会让「只有主数据」的环境被误判成没有脚本。
    if not any(etl_dir(s).is_dir() for s in GROUPS):
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
    bak = _ns.REPO / 'tools/.dx-tmp' / f'backup-dwd-ddl-{stamp}'
    for s in GROUPS:
        d = _ns.SCRIPTS / ('MASTER/dwd' if s == '主数据' else f'{s}/dwd')
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
        # 只删 `_INIT` 脚本的 DDL；`_INIT_TMP` 属 `*_TMP*`，按口径保留（供排查、不参与重建）。
        for p in d.glob('*_INIT.sql'):
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

    top = _ns.SCRIPTS / '建表语句'
    top.mkdir(parents=True, exist_ok=True)
    for s in GROUPS:
        main_sql = ddl_main(s)
        if main_sql.is_file():
            shutil.copy2(main_sql, top / f'DWD_{s}_建表语句.sql')
    print(f'  DDL 已落地 {_ns.SCRIPTS}/{{系统}}/dwd/ddl、01_ddl.sql 和 {top}')
    print('备份:', bak)

    # ★ A8（2026-11-09 评审）：落盘后与甲方逐表自检（结构 + 语句边界）。
    san = {t: sanitize_ddl(jf[t]) for t in have}
    bad = verify_ddl_after_write(have, san)
    if bad:
        for item in bad:
            msg = (item['probs'][0] if item['probs']
                   else item['diff'].summary())
            print(f"  ✗ {item['table']} ({item['sysname']}): {msg}")
        _report_dwd_ddl_drift(bad)
        if not getattr(args, 'no_strict', False):
            print('  ✗ DWD DDL 落盘自检发现差异（已阻断）。加 --no-strict 可忽略继续。')
            return 1
        print('  ⚠ DWD DDL 落盘自检发现差异（--no-strict：仅告警，不阻断）')
    else:
        print(f'  ✓ 落盘自检：{len(have)} 张与甲方一致（含语句边界）')
    return 0

