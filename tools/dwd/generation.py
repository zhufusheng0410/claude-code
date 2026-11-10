# -*- coding: utf-8 -*-
"""DWD 管线生成：方言转换、依赖工作簿、DS 依赖配置。"""
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


# --------------------------------------------------------------------------- #
# 脚本转换：_TRANSFORMS 里的每个函数都是 (sql, table) -> (new_sql, count)，
# 顺序即语义，不可随意调整。
# ★ 2026-11-09（评审 B2）：注释原先说「每个修复都是独立纯函数 (sql, table)」，
#   与实际不符：_dedupe_shebang 只收 sql；_normalize_env / _normalize_beeline
#   收 table 但不用，且返回的 count 被调用方丢弃（它们是格式归一，不计统计）。
# --------------------------------------------------------------------------- #
def _dedupe_shebang(sql):
    """甲方偶把两份脚本粘连；保留最后一个 shebang 起的正文。"""
    if sql.count('#!/bin/sh') > 1:
        return sql[sql.rfind('#!/bin/sh'):], 1
    return sql, 0


def _normalize_env(sql, table):
    """env 路径标准化，并删掉冗余的 source_path 行。"""
    sql = sql.replace('source ${hadoop_env}',
                      'source /home/dolphinscheduler/hadoop_env')
    sql = re.sub(r'(?m)^[ \t]*source[ \t]+\$\{source_path\}[ \t]*\n', '', sql)
    return sql, 0


def _normalize_beeline(sql, table):
    """补全 beeline 的 -n / -p 参数。"""
    return re.sub(
        r'(?m)^([ \t]*)beeline -u \$\{hive_jdbc\}.*$',
        r'\1beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"',
        sql), 0


def _drop_inceptor_sets(sql, table):
    """删除 Inceptor 专有 SET（Hive 4.2 不认）。"""
    lines = sql.lstrip('\n').split('\n')
    kept = [ln for ln in lines if not RE_SET_DROP.match(ln)]
    return '\n'.join(kept), len(lines) - len(kept)


def _insert_type_safety(sql, table):
    """缺少时插入类型安全开关（位置：首条 set 之前）。"""
    if SAFETY in sql:
        return sql, 0
    lines = sql.split('\n')
    bidx = max((k for k, x in enumerate(lines) if x.startswith('-- **')), default=-1)
    sidx = next((k for k in range(bidx + 1, len(lines))
                 if lines[k].strip().startswith('set ')), len(lines))
    lines.insert(sidx, SAFETY)
    return '\n'.join(lines), 1


def _fix_date_format3(sql, table):
    """三参数 DATE_FORMAT → 两参（Hive 4.2 只认两参）。"""
    return fix_date_format3(sql)


def _escape_as_date(sql, table):
    """Hive 保留字 DATE 作别名时加反引号（并对 shell 二次转义）。"""
    return re.subn(r'\bAS\s+DATE\b(?![\w`])', 'AS \\`DATE\\`', sql)


def _replace_sysdate(sql, table):
    """SYSDATE → DATE_FORMAT(CURRENT_DATE,'yyyyMMdd')。"""
    n = len(re.findall(r'\bSYSDATE\b', sql))
    if not n:
        return sql, 0
    return re.sub(r'\bSYSDATE\b', "DATE_FORMAT(CURRENT_DATE,'yyyyMMdd')", sql), n


def _scr_cast(sql, table):
    """SCR 表的类型转换修复（按表生效）。"""
    if table not in SCR3_TABLES:
        return sql, 0
    return RE_SCR3.subn(SCR3_FIX, sql)


def _add_partition(sql, table):
    """补分区子句（按表生效）。"""
    if table not in PART_FIX:
        return sql, 0
    pat = re.compile(r'(INSERT\s+OVERWRITE\s+TABLE\s+DWDXDAY\.' + table +
                     r')(?![\w])(?!\s+PARTITION)')
    return pat.subn(r"\1 PARTITION (P_DT= '${P_BATCH_DT}')", sql)


def _evt_cast(sql, table):
    """EVT 表的类型转换修复（按表生效，可多条规则）。"""
    if table not in EVT_CAST_FIX:
        return sql, 0
    total = 0
    for pat, rep in EVT_CAST_FIX[table]:
        sql, n = re.subn(pat, rep, sql)
        total += n
    return sql, total


def _add_subquery_alias(sql, table):
    """给未命名的子查询补 SUBT1 别名。"""
    return add_subquery_alias(sql)


#: (stats 键, 变换函数)。顺序即语义。
_TRANSFORMS = (
    ('sets_dropped', _drop_inceptor_sets),
    ('safety', _insert_type_safety),
    ('date_format3', _fix_date_format3),
    ('as_date', _escape_as_date),
    ('sysdate', _replace_sysdate),
    ('scr_cast', _scr_cast),
    ('partition', _add_partition),
    ('evt_cast', _evt_cast),
    ('subt1', _add_subquery_alias),
)

#: 统计键：`dedupe_head` 由 convert() 单独累加，其余全部由 _TRANSFORMS 派生。
# ★ 2026-11-09（评审 B1）：原先两处手写清单，新增变换忘加 key 时
#   `stats[key] += n` 会 KeyError（且 stats 只在 --apply 路径非 None，测试未必覆盖）。
STAT_KEYS = ('dedupe_head',) + tuple(k for k, _ in _TRANSFORMS)


def convert(raw, stats=None, table=''):
    s = raw.replace('\r\n', '\n').replace('\r', '\n').lstrip('\ufeff')
    s, n = _dedupe_shebang(s)
    if stats is not None:
        stats['dedupe_head'] += n

    if 'inceptor_beeline "' not in s:
        raise ValueError('找不到 inceptor_beeline "')

    s, _ = _normalize_env(s, table)
    s, _ = _normalize_beeline(s, table)

    for key, fn in _TRANSFORMS:
        s, n = fn(s, table)
        if stats is not None:
            stats[key] += n

    return s.rstrip('\n') + '\n'


def norm_lines(txt):
    return [ln.strip() for ln in txt.split('\n') if ln.strip()]


def new_stats():
    return {k: 0 for k in STAT_KEYS}


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
            bak = _ns.REPO / 'tools/.dx-tmp' / f'backup-dwd-init-{time.strftime("%Y%m%d-%H%M%S")}'
            for p in init_old:
                rel = p.relative_to(_ns.REPO)
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
        print('  注：MASTER 为主数据手工稿；2026-10-23 起 DS 侧跑真实脚本，'
              '历史漂移需按 J-33 口径处置（--master-placeholder 可回滚占位）')
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
                'scripts_root': str(_ns.SCRIPTS)}
    if args.apply:
        (_ns.SCRIPTS / '_DWD搬移清单.json').write_text(
            json.dumps(manifest, ensure_ascii=False, indent=1), encoding='utf-8')
    print(f'分布: {dist} | 主数据 {n_master}')
    print(f'DDL 表数: {ddl}')
    print(f'清单: {_ns.SCRIPTS}/_DWD搬移清单.json')
    if not args.apply:
        print('(dry-run，未落盘)')
    return 0

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
    p = _ns.REPO / 'tools/.dx-tmp/dwd-syntax-check.json'
    if not p.exists():
        return None
    try:
        data = json.loads(p.read_text(encoding='utf-8'))
    except (json.JSONDecodeError, OSError, UnicodeError) as e:
        # 残缺/不可读当作没有结果；类型写进日志，避免再被裸 Exception 静默吞掉。
        print(f'  ! 语法校验结果无法读取 {p.name}: {type(e).__name__}: {e}')
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
        if not (_ns.SCRIPTS / fname).is_file():
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
            real, srcs = _parse_script(s)
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
    # ★ 2026-11-09：分组计数只扫一次，供「说明」页与引导页共用（原先两处各算了一遍）。
    #   分组明细也由实盘算出，不再硬编码快照 —— 见 CLAUDE.md「文档记录约定」：
    #   「不记临时结果：表数/作业数快照…跑批一变就失真」。
    sh_counts = {g: len(list(etl_dir(g).glob('*.sh'))) for g in GROUPS}
    ddl_counts = {g: len(list(ddl_dir(g).glob('*.sql'))) for g in GROUPS}
    n_sh = sum(sh_counts.values())
    n_ddl = sum(ddl_counts.values())
    n_master = sh_counts.get('主数据', 0)
    # 甲方 _INIT 脚本数（按交付目录实盘算，不写死快照）
    n_init = sum(1 for p in JF.glob('*.txt') if '_INIT' in p.stem.upper())
    sh_breakdown = ' / '.join('%s %d' % (g, sh_counts[g]) for g in GROUPS)
    info_rows = [
        ['生成时间', time.strftime('%Y-%m-%d %H:%M:%S')],
        ['脚本范围', 'scripts/{系统}/dwd/02_etl 下 %d 个脚本（%s）'
         % (n_sh, sh_breakdown)],
        ['建表语句', 'scripts/{系统}/dwd/ddl 下 %d 张表 + 各系统 01_ddl.sql；汇总在 scripts/建表语句/' % n_ddl],
        ['依赖口径', '从脚本 INSERT 目标与 FROM/JOIN 源表解析；_TMP 不计入主依赖'],
        ['上游层级', '上游是 ODS 或 DWD 同层表；DWD 不依赖 DWS 层（实测 0 条）'],
        ['主数据口径', 'scripts/MASTER/dwd/02_etl 的 %d 个为主数据手工稿；2026-10-23 起随 DWD 批次跑真实脚本' % n_master],
        ['甲方来源', '甲方 05-脚本/02-脚本/01-DWD执行脚本/*.txt 经 dwd-pipeline.py convert 转换（J-28 方言修复）'],
        ['排除脚本', '甲方 %d 个 _INIT 脚本按设计排除；DS 上重建 DWD 后 INIT 作业自动消失' % n_init],
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

    build_cover(
        wb,
        'DWD 依赖关系工作簿 · 引导页',
        f'交付范围：{len(GROUPS)} 个分组 / {n_sh} 个脚本 / {n_ddl} 张建表语句'
        f'（{sh_breakdown}）',
        [
            '本工作簿 = scripts/{系统}/dwd/02_etl 下 DWD 脚本的逻辑梳理结果（甲方 01-DWD执行脚本 转换而来）。',
            '「语法校验」= Shell bash -n + Hive DDL 沙箱建表 + Hive EXPLAIN 编译（不执行、不落数据）。',
            '主数据（MASTER）组为主数据手工稿；2026-10-23 起随 DWD 批次执行真实脚本'
            '（--master-placeholder 可回滚为占位）。',
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
            '甲方 %d 个 _INIT 脚本按设计排除（重建 DWD 后 DS 上的 INIT 作业自动消失）。' % n_init,
            '本工作簿只做 DWD 层分析；DWD 不依赖 DWS 层。',
        ])

    out = _ns.SCRIPTS / 'DWD_依赖关系.xlsx'
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
            real, srcs = _parse_script(s)
            for src in srcs:
                need, ms, _why = needs_schedule_dep(s, src)
                if need is None:
                    no_ref += 1
                    continue
                rel = str(p.relative_to(_ns.REPO)).replace('\\', '/')
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


def cmd_depcfg(args):
    L = _load_file(str(_ns.REPO / 'tools/ds-deploy/ds-build-dependent-from-lineage.py'), 'LINEAGE_BUILDER')
    xlsx = _ns.SCRIPTS / 'DWD_依赖关系.xlsx'
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

    # ★ 2026-11-09：索引与 ODS 分组缓存各建一次，避免嵌套循环里的重复目录扫描。
    script_idx = _script_index()
    ods_cache = {}
    targets = [t for t in rows if _script_of(t, script_idx)]
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
                w = _locate_ods(u, ods_cache)
                if not w:
                    unresolved.append((t, u, 'ODS 未定位'))
                    continue
            else:
                w = _own_workflow(u)
                if w == '(未知)':
                    unresolved.append((t, u, '无法解析主题'))
                    continue
                if not _script_of(u, script_idx):
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

