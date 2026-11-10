# -*- coding: utf-8 -*-
"""DWD 管线解析：MAPPING 归属、脚本依赖、分区口径。"""
# -*- coding: utf-8 -*-
import collections
import difflib
import functools
import json
import os
import re
import shutil
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
import zipfile
import zlib
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.utils.exceptions import InvalidFileException
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.worksheet.hyperlink import Hyperlink

from tools.core.loader import load as _load_file

from tools.dwd import export_ns
from tools.dwd import ns as _ns
export_ns(_ns, globals())

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
    # ★ 2026-11-10：一个坏 xlsx 跳过并带上异常类型；编程错误不再被裸 Exception 吞掉。
    #   ★ 评审 M4：**不含 TypeError** —— 这是「读不出来」的分支，吞掉 TypeError
    #     会把参数个数写错之类的编程错误变成「安静跳过一份 MAPPING」。
    except (OSError, ValueError, LookupError, zipfile.BadZipFile,
            zlib.error, InvalidFileException, ET.ParseError) as e:
        print(f'  ! {p.name}: {type(e).__name__}: {e}')
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
    master_stems = {p.stem for p in _ns.MASTER.glob('*.sh')}
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
        owner_json = _ns.OWNER_JSON
        owner_json.parent.mkdir(parents=True, exist_ok=True)
        owner_json.write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding='utf-8')
        print('写出', owner_json)
    return data


def load_owner(write=False):
    if _ns.OWNER_JSON.exists():
        return json.loads(_ns.OWNER_JSON.read_text(encoding='utf-8'))
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


@functools.lru_cache(maxsize=None)
def _strip_sql_comments(s):
    """去掉 -- 行注释（不误伤单引号里的内容）。

    ★ 2026-11-09：纯函数，加记忆化。原先每分析一张上游表就把整段脚本重新
      逐字符扫一遍（实测 1605 次、耗时占 lineage 的 ~60%）。
    """
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


@functools.lru_cache(maxsize=None)
def partition_modes(script, src):
    """返回脚本里【每一处】读 src 这张表的分区口径，如 ('prev','prev')。

    空元组 = 脚本里没有对 src 的 FROM/JOIN 引用。

    ★ 2026-11-09：纯函数 + 记忆化 —— 原先它是 lineage 的计算热点
      （1605 次调用；`needs_schedule_dep` 内部对同一 (脚本, 上游) 算了两次）。
      返回**元组**而非 list，避免缓存值被调用方原地修改后污染后续查询。
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
    return tuple(out)


@functools.lru_cache(maxsize=None)
def partition_set(script, src):
    """把 partition_modes 折叠成口径集合（mixed:x+y 展开）。

    ★ 2026-11-09：记忆化；返回 frozenset（不可变），调用方只做比较/迭代。
    """
    ms = set()
    for m in partition_modes(script, src):
        ms |= set(m[6:].split('+')) if m.startswith('mixed:') else {m}
    return frozenset(ms)


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


def _parse_script(s):
    """从脚本**内容**解析出 (目标表列表, 上游源表列表)。

    ★ 2026-11-09：原签名收 Path 并自行 read_text，而两个调用方都已先读过同一文件
      ⇒ 每个脚本被读两遍、正则跑两遍。改为直接收文本。
    ★ 2026-11-09（评审 C1）：入口**保留** PathLike 兼容。本模块被
      `dws-dep-report.py` 等脚本按路径加载后**跨文件调用**（那边仍然传 Path），
      签名一收紧就 `TypeError: expected string or bytes-like object,
      got 'PosixPath'` —— 实测 dws-dep-report.py 整条命令 100% 崩溃。
      纯文本入参按原样（省一次读盘）；只有真传了路径才读一次。
    """
    if isinstance(s, os.PathLike):
        s = Path(s).read_text(encoding='utf-8', errors='replace')
    targets = _uniq(t.upper() for t in TGT.findall(s))
    real = [t for t in targets if '_TMP' not in t]
    srcs = _uniq(x.upper() for x in SRC.findall(s))
    srcs = [x for x in srcs if x not in real and '_TMP' not in x]
    return real, srcs


def _layer(t):
    return t.split('_')[0]


def _script_index():
    """一次扫描 SCRIPTS：表名 → DWD 脚本路径。

    ★ 2026-11-09：原 `_script_of()` 每次调用都 `os.listdir(SCRIPTS)`，而它在
      「每张目标表 × 每个上游表」的嵌套循环里被调用 ⇒ O(n×m) 次目录扫描。
      改为调用方构建一次索引后传入，扫描次数降为 1。
    """
    idx = {}
    scripts = _ns.SCRIPTS
    for s in sorted(os.listdir(scripts)):
        d = scripts / s / 'dwd/02_etl'
        if not d.is_dir():
            continue
        for p in d.glob('*.sh'):
            idx.setdefault(p.stem, str(p))
    return idx


def _script_of(table, index=None):
    """返回某表的 DWD 脚本路径；不存在返回 None。

    index: 可选，`_script_index()` 的结果。批量调用时应传入以免重复扫描。
    """
    if index is None:
        index = _script_index()
    return index.get(table)


def _ods_chunks(sys_name):
    d = _ns.SCRIPTS / sys_name / 'ods/etl_sh'
    if not d.is_dir():
        return []
    files = sorted(f[:-3] for f in os.listdir(d)
                   if f.endswith('.sh') and not f.startswith('.') and 'deploy-to-worker' not in f)
    return [(i // 20 + 1, files[i:i + 20]) for i in range(0, len(files), 20)]


def _locate_ods(table, chunks_cache=None):
    """把 ODS 表定位到所属抽取作业组（ods_<sys>_etl_NN）。

    chunks_cache: 可选 dict，按系统名缓存 `_ods_chunks()` 结果。
                  批量调用时传入，避免每个上游表都重新 listdir。
    """
    sys_name = table.split('_')[1]
    if chunks_cache is not None:
        if sys_name not in chunks_cache:
            chunks_cache[sys_name] = _ods_chunks(sys_name)
        chunks = chunks_cache[sys_name]
    else:
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


# 归属口径：**唯一来源** tools/core/dwd_ownership.py（与
# ds-deploy/ds-build-dependent-from-lineage.py 共用，不再各存一份字典）。
_OWNERSHIP = _load_file(str(_ns.REPO / 'tools/core/dwd_ownership.py'), 'DWD_OWNERSHIP')
WORKFLOW_OVERRIDE = _OWNERSHIP.WORKFLOW_OVERRIDE


def _own_workflow(table):
    return _OWNERSHIP.own_workflow(table)

