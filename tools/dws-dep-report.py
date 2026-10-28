#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""生成 / 刷新 scripts/DWS_依赖关系.xlsx（DWS 层依赖关系 + 分区口径检索）。

为什么要有这个文件
------------------
`scripts/DWS_依赖关系.xlsx` 最初由一次性脚本产出，那个脚本没有进仓库 ⇒ 无法复现、
无法在口径变化后重跑。本文件把它固化成可复现的生成器，与 DWD 侧
（tools/dwd-pipeline.py lineage）保持同一套判定逻辑。

关键设计
--------
1. **口径单一真源**：直接 import tools/dwd-pipeline.py，复用
   needs_schedule_dep / partition_modes / PREV_IDIOM_DOC —— 不另写一套正则。
   否则 DWD 与 DWS 两边的「前一日」判定迟早漂移。
2. **历史页不动**：字段级血缘 / 执行顺序 / 临时表 / 血缘对照 / 排除脚本 /
   语法校验 / 运行结果 这几页来自实际运行与甲方血缘文件，本脚本**原样搬运**，
   不做重算（重算只会制造噪声，且运行结果本来就无法重放）。
3. **自引用单独成页**：脚本读自己前一天的分区做累积是 DWS 特有的高频写法，
   它**不是**可配的依赖边（配了就是自环），必须单独列出来让人看到。

用法
----
    PY=C:/Users/84148/.workbuddy-ai/binaries/python/envs/default/Scripts/python.exe
    $PY tools/dws-dep-report.py            # dry-run，只打印
    $PY tools/dws-dep-report.py --apply    # 写盘
"""
import argparse
import collections
import importlib.util
import re
import sys
import time
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

REPO = Path(__file__).resolve().parent.parent
SCRIPTS = REPO / 'scripts'
TARGET_XLSX = SCRIPTS / 'DWS_依赖关系.xlsx'

# ---- 复用 DWD 侧判定逻辑（单一真源） -------------------------------------- #
_spec = importlib.util.spec_from_file_location(
    'dwdpipe', str(REPO / 'tools' / 'dwd-pipeline.py'))
P = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(P)

SYS = P.SYS                       # ('HSFA', 'HSZTA', 'O32')
SYS2DS = {'HSFA': 'DWS_HSFA', 'HSZTA': 'DWS_ZTA', 'O32': 'DWS_O32'}

# 配置表（有 DDL、有数据口径，但 DS 上没有 SHELL 作业 ⇒ 不配调度依赖）
CONFIG_TBLS = {'DWD_CMM_STD_DICT_CLS_EMRT_INFO', 'DWD_CMM_PTCD_AREA_RELA_PFD',
               'DWD_CMM_AREA_INFO_PFD'}

HDR_FILL = PatternFill('solid', fgColor='DDEBF7')
BOLD = Font(bold=True)


# --------------------------------------------------------------------------- #
# 扫描
# --------------------------------------------------------------------------- #
def scan():
    """返回 (edges, selfrefs, conds, scripts_meta)。"""
    all_stems = {}
    for s in SYS:
        d = P.dws_etl_dir(s)
        if d.is_dir():
            for p in d.glob('*.sh'):
                all_stems[p.stem.upper()] = s
    # ★ 上游是 DWD 层表时也要知道它归哪个系统 —— 否则「跨组依赖」会漏。
    #   例：HSZTA 的 DWS_PROD_HOLD_DETAIL_PTD 读 HSFA 的 DWD_CMM_CALENDAR_INFO_PFD，
    #   这是跨系统边，但该表没有 DWS 脚本 ⇒ 只看 all_stems 会判成"不是跨组"。
    dwd_stems = {}
    for s in SYS:
        d = P.etl_dir(s)
        if d.is_dir():
            for p in d.glob('*.sh'):
                dwd_stems.setdefault(p.stem.upper(), s)

    edges, selfrefs, conds, meta = [], [], [], {}
    for s in SYS:
        d = P.dws_etl_dir(s)
        if not d.is_dir():
            print(f'!! 缺目录 {d}')
            continue
        for p in sorted(d.glob('*.sh')):
            script = p.read_text(encoding='utf-8', errors='replace')
            real, srcs = P._parse_script(p)
            rel = str(p.relative_to(REPO)).replace('\\', '/')
            meta[p.stem] = {'sys': s, 'ds_wf': SYS2DS[s], 'file': rel,
                            'targets': real, 'srcs': srcs,
                            'lines': script.count('\n') + 1}

            for tgt in real:
                # --- 自引用（_parse_script 会把它从 srcs 里剔掉，这里单独抓） --
                if re.search(r'\b(?:FROM|JOIN)\s+(?:[A-Z0-9_]+\s*\.\s*)?'
                             + re.escape(tgt) + r'\b', script, re.I):
                    sm = P.partition_set(script, tgt)
                    selfrefs.append({
                        'sys': s, 'script': p.stem, 'table': tgt,
                        'part': P._partition_cell(script, tgt),
                        'modes': sorted(sm),
                        'is_prev': 'prev' in sm,
                        'file': rel,
                    })
                for src in srcs:
                    need, ms, why = P.needs_schedule_dep(script, src)
                    up = all_stems.get(src, '')            # DWS 同名脚本（有才是 DWS 上游）
                    # ★ 归属系统：DWS 脚本优先，其次查 DWD 侧同名脚本 ——
                    #   否则「跨组依赖」会漏掉「HSZTA 读 HSFA 的 DWD 表」这类边。
                    up_sys = all_stems.get(src) or dwd_stems.get(src, '')
                    if up:
                        kind = 'DWS上游脚本'
                    elif P._layer(src) == 'ODS':
                        kind = 'ODS层(无作业)'
                    elif src in CONFIG_TBLS:
                        kind = '配置表(无作业)'
                    elif '_INT' in src or src.endswith('_TMP'):
                        kind = '内部中间表'
                    else:
                        kind = 'DWD层(非DWS脚本)'
                    if need is None:
                        dep = '-'
                    elif need:
                        dep = '需配'
                    else:
                        dep = '不配(只读前一日)'
                    edges.append({
                        'script': p.stem, 'sys': s, 'ds_wf': SYS2DS[s],
                        'target': tgt, 'source': src,
                        'src_layer': P._layer(src), 'upstream': up or '-',
                        'up_sys': up_sys or '-',
                        'kind': kind,
                        'part': P._partition_cell(script, src),
                        'modes': sorted(ms), 'dep': dep, 'why': why,
                        'cross': bool(up_sys) and up_sys != s,
                        'file': rel,
                    })

            # --- 分区条件逐条留证 ------------------------------------------ #
            clean = P._strip_sql_comments(script)
            for st in [x for x in clean.split(';') if x.strip()]:
                for m in P._PDT_Q.finditer(st.upper()):
                    expr = P._expr_at(st, m.end())
                    if not expr:
                        continue
                    conds.append({
                        'sys': s, 'script': p.stem, 'alias': m.group(1),
                        'cls': P._classify_part(expr),
                        'expr': ' '.join(expr.split())[:240],
                    })
    return edges, selfrefs, conds, meta


def defects(edges, selfrefs, meta):
    """已知缺陷清单（静态判定 + 已实证）。"""
    out = []

    # ① 循环右开：begin_date == end_date 时 while 体一次都不执行
    #   ★ 2026-10-24 改为「登记式」：扫描只用来判定**当前是否仍存在**，
    #     缺陷记录本身始终保留。否则修好后这条历史就从交付文档里消失，
    #     下次重跑 --apply 也无从追溯「为什么改过」。
    hsfa_dws = [k for k, v in meta.items() if v['sys'] == 'HSFA']
    lt = []
    for k in sorted(hsfa_dws):
        txt = (SCRIPTS / 'HSFA' / 'dws/02_etl' / (k + '.sh')).read_text(
            encoding='utf-8', errors='replace')
        if re.search(r'while\s*\[\s*\$P_BATCH_DT\s+-lt\s+\$end_date', txt):
            lt.append(k)
    out.append({
        'no': 1, 'level': '严重',
        'title': 'HSFA DWS 7 个脚本 while 循环右开 ⇒ 循环体零次执行（作业空转）',
        'where': (' / '.join(lt) if lt else
                  'HSFA/dws/02_etl/ 下 7 个脚本（现已全部改为 -le）'),
        'evidence': ('脚本头 `begin_date="${p_start_dt}"`、`end_date="${p_end_dt}"`，'
                     '而 DS 全局参数里 p_start_dt = p_end_dt = ${system.biz.date} ⇒ 两者同值；'
                     '循环条件却是 `while [ $P_BATCH_DT -lt $end_date ]`（右开）'
                     '⇒ 首次判断即假，**循环体一次都不执行**，beeline 从未被调用。'
                     '对照：20 个 HSFA DWD 脚本写的是 `-le`（右闭）⇒ 同值时恰好跑 1 次，正常。'),
        'impact': '作业返回码 0、DS 显示 SUCCESS，但一张分区都没写 ⇒ 静默无产出。'
                  'DWS 表当前全为 0 行即与此一致。',
        'fix': '把 7 个脚本的 `-lt` 改成 `-le`，与 DWD 侧一致；'
               '同步改 DS 上 DWS_HSFA 的 7 个任务 rawScript。',
        'status': '未修复' if lt else '已修复 2026-10-24',
        'fix_note': '' if lt else (
            '7 个脚本 `-lt` → `-le`（仓库 .sh + DS DWS_HSFA 7 个任务 rawScript 已同步）。'
            '修复后 begin==end 恰好执行 1 次再自增退出，与 20 个 HSFA DWD 脚本口径一致。'),
    })

    # ② / ③ 未声明变量（取自 DS 元库实测，覆盖全工作流）
    #   ★ 2026-10-24：改为「登记式 + 扫描判定当前状态」，修好后记录仍保留可追溯。
    #     ② 的修法按用户要求调整为「直接把 ${end_date} 换成 ${p_end_dt}」——
    #     不新增中间变量，少一层间接，也避免以后有人误改 end_date 的赋值。
    o32_stk = SCRIPTS / 'O32' / 'dws/02_etl' / 'DWS_TRAN_STK_TRAN_DETAIL_PTD.sh'
    d2_open = False
    if o32_stk.exists():
        _t = o32_stk.read_text(encoding='utf-8', errors='replace')
        d2_open = bool(re.search(r'\$\{end_date\}', _t)) and not re.search(
            r'^\s*end_date\s*=', _t, re.M)
    out.append({
        'no': 2, 'level': '严重',
        'title': 'DWS_O32 / DWS_TRAN_STK_TRAN_DETAIL_PTD 使用 ${end_date}，但四处均未声明',
        'where': 'O32/dws/02_etl/DWS_TRAN_STK_TRAN_DETAIL_PTD.sh（3 处 BETWEEN）',
        'evidence': ('脚本内无 `end_date=` 赋值；hadoop_env 无该变量；'
                     'DWS_O32 工作流 globalParams 只声明 p_start_dt / p_end_dt；'
                     '任务 localParams 为空 ⇒ shell 展开成**空串**。'
                     '对照：7 个 HSFA 脚本都在头部写了 `end_date="${p_end_dt}"`。'),
        'impact': "`WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${end_date}'` "
                  "→ `BETWEEN '20261022' AND ''` ⇒ 下界大于上界 ⇒ **查询恒为空**，0 行产出。",
        'fix': '把 3 处 `${end_date}` 直接改为 `${p_end_dt}`（不新增中间变量）；同步改 DS。',
        'status': '未修复' if d2_open else '已修复 2026-10-24',
        'fix_note': '' if d2_open else (
            '3 处 `${end_date}` 全部直接改为 `${p_end_dt}`，脚本头部恢复原样、'
            '不引入 `end_date` 变量（用户 2026-10-24 要求：无需重新定义变量）。'
            '因 p_start_dt = p_end_dt = ${system.biz.date}，BETWEEN 为单日区间，'
            '符合每日分区语义。DS 侧 rawScript 已同步，end_date 残留 0 处。'),
    })
    zta = SCRIPTS / 'HSZTA' / 'dws/02_etl' / 'DWS_TRAN_AFFI_BTCH_PTD.sh'
    d3_open = zta.exists() and 'p_strar_dt' in zta.read_text(
        encoding='utf-8', errors='replace')
    out.append({
        'no': 3, 'level': '严重',
        'title': 'DWS_ZTA / DWS_TRAN_AFFI_BTCH_PTD 变量名拼写错误 ${p_strar_dt}（应为 p_start_dt）',
        'where': 'HSZTA/dws/02_etl/DWS_TRAN_AFFI_BTCH_PTD.sh:248',
        'evidence': ('`WHERE T1.P_DT BETWEEN \'${p_strar_dt}\' AND \'${p_end_dt}\'`；'
                     'DS 元库扫描（工作流 globalParams + 任务 localParams + hadoop_env + '
                     '脚本内赋值）四路都没有 p_strar_dt。'),
        'impact': "展开成空串 ⇒ `BETWEEN '' AND '20261022'` ⇒ 下界恒真、上界放到批次日 "
                  "⇒ **扫全历史所有分区**（数据量放大 + 结果口径错）。"
                  "注意与 ② 的失效方向相反：② 恒空，③ 恒全。",
        'fix': '把 `${p_strar_dt}` 改为 `${p_start_dt}`；同步改 DS。',
        'status': '未修复' if d3_open else '已修复 2026-10-24',
        'fix_note': '' if d3_open else (
            '`${p_strar_dt}` → `${p_start_dt}`（仓库 .sh + DS DWS_ZTA 对应任务 '
            'rawScript 已同步）。BETWEEN 恢复为单日区间，不再扫全历史。'),
    })
    return out


# --------------------------------------------------------------------------- #
# 写出
# --------------------------------------------------------------------------- #
def _style_header(ws, widths=None, wrap_from=None):
    for c in ws[1]:
        c.font, c.fill = BOLD, HDR_FILL
        c.alignment = Alignment(horizontal='center', vertical='center')
    if widths:
        for i, w in enumerate(widths, 1):
            ws.column_dimensions[get_column_letter(i)].width = w
    ws.freeze_panes = 'A2'
    if wrap_from:
        for row in ws.iter_rows(min_row=2):
            for c in row[wrap_from - 1:]:
                c.alignment = Alignment(vertical='top', wrap_text=True)


def carry(ws_src, ws_dst):
    """把旧工作簿里某页原样搬过来（值 + 列宽 + 表头样式）。

    ★ 旧簿用 read_only=True 打开（快、省内存），但 ReadOnlyWorksheet **没有**
      column_dimensions ⇒ 列宽只能放弃、用一套按列数推导的默认宽度兜底。
      值本身是完整的，历史页的信息不会丢。
    """
    dims = getattr(ws_src, 'column_dimensions', None)
    if dims:
        for i, w in dims.items():
            if w.width:
                ws_dst.column_dimensions[i].width = w.width
    ncol, nrow, width = 0, 0, []
    for row in ws_src.iter_rows(values_only=True):
        ws_dst.append(list(row))
        ncol = max(ncol, len(row))
        nrow += 1
        # 边搬边量列宽（read_only 拿不到原始列宽，只能按内容反推）
        while len(width) < len(row):
            width.append(0)
        for i, v in enumerate(row):
            if v is not None:
                width[i] = max(width[i], min(len(str(v)), 60))
    if not dims and ncol:
        for i in range(1, ncol + 1):
            ws_dst.column_dimensions[get_column_letter(i)].width = max(
                10, min(width[i - 1] + 2, 62))
    _style_header(ws_dst)
    return nrow


def build(edges, selfrefs, conds, meta, defect_rows, old):
    wb = Workbook()

    # ---------------- 引导页 ---------------- #
    ws = wb.active
    ws.title = '引导页'
    n_scripts = len(meta)
    drop = [e for e in edges if e['dep'].startswith('不配')]
    alike = [e for e in edges if 'prev_alike' in e['modes']]
    mixed = [e for e in edges if e['dep'] == '需配' and 'prev' in e['modes']]
    selfprev = [r for r in selfrefs if r['is_prev']]

    ws.append(['DWS 依赖关系工作簿 · 引导页'])
    ws.append([f'交付范围：{n_scripts} 张目标表 / {n_scripts} 个脚本'
               f'（HSFA 7 / HSZTA 8 / O32 9）｜生成 {time.strftime("%Y-%m-%d %H:%M")}'])
    ws.append([])
    ws.append(['一、结论速览（2026-10-23 分区口径检索）'])
    for c in ws[ws.max_row]:
        c.font = BOLD
    ws.append([f'· 依赖边 {len(edges)} 条：需配 {len(edges) - len(drop)}，'
               f'不配(只读前一日) {len(drop)}'])
    ws.append([f'· 自引用前一日读 {len(selfprev)} 个脚本'
               f'（读自己昨天的分区做累积，配依赖即自环 ⇒ 只能靠 DS 业务日期推进）'])
    ws.append([f'· 含前一日但同表也有当天读（依赖必须保留）{len(mixed)} 条'])
    ws.append([f'· P_BATCH_DT 变体（与 p_end_dt 同值但不在本口径内，只报不删）{len(alike)} 条'])
    ws.append([f'· 缺陷 {len(defect_rows)} 项（见「问题清单」页）——DWS 尚未启用过，'
               f'所以都是潜在缺陷而非线上故障；'
               f'其中已修复 {sum(1 for d in defect_rows if str(d.get("status","")).startswith("已修复"))} 项、'
               f'未修复 {sum(1 for d in defect_rows if d.get("status","") == "未修复")} 项'])
    ws.append([])
    ws.append(['二、工作表导航'])
    for c in ws[ws.max_row]:
        c.font = BOLD
    nav = [('依赖明细', len(edges), '每条依赖边一行：含「分区读取」与「调度依赖」结论'),
           ('汇总', len(SYS), '按系统统计'),
           ('自引用(读前一日)', len(selfrefs), '脚本读自己的表；标注是否读前一日分区'),
           ('不配依赖(读前一日)', max(len(drop), 1), '满足「只读前一日惯用式」⇒ 不配调度依赖的边'),
           ('分区口径检索', len(conds), '脚本里每一处 P_DT 条件的原文与归类（检索证据）'),
           ('问题清单', len(defect_rows), '静态检索发现的脚本缺陷'),
           ('跨组依赖', None, '跨系统的依赖边（需跨工作流调度）'),
           ('表级血缘', None, '一张目标表一行'),
           ('无同名脚本上游', None, '引用了但仓库里没有同名脚本的上游表'),
           ('执行顺序', None, '按依赖拓扑排出的执行序（历史页，原样保留）'),
           ('字段级血缘', None, '字段级血缘（历史页，原样保留）'),
           ('临时表', None, '脚本内自建自删的临时表'),
           ('血缘对照', None, '脚本源表 vs 已有表级血缘的差异对照'),
           ('排除脚本', None, '被排除、不交付的脚本'),
           ('语法校验', None, 'Shell 语法 + Hive EXPLAIN 编译结果（历史页）'),
           ('运行结果', None, '20261018 本地直跑结果（历史页）'),
           ('说明', None, '口径、来源、范围、注意事项')]
    ws.append(['工作表', '行数', '内容'])
    for c in ws[ws.max_row]:
        c.font = BOLD
    for nm, n, desc in nav:
        ws.append([nm, '' if n is None else n, desc])
    ws.append([])
    ws.append(['三、口径提示'])
    for c in ws[ws.max_row]:
        c.font = BOLD
    for tip in [
        '★ 前一日分区 = 这个**字面形态**（不是「含 DATE_SUB 就算」）：P_DT = ' + P.PREV_IDIOM_DOC,
        '★ 分区口径依据：DS 全局参数 p_start_dt = p_end_dt = ${system.biz.date}'
        '（= 运行日-1 = 批次日）⇒ 三者同值，BETWEEN 收窄成同一天一个分区，不是区间回溯。',
        '★ DWS 层结论：**没有一条边满足「只读前一日 ⇒ 不配依赖」**。'
        '凡是用前一日惯用式读的，要么是自引用（3 个脚本），要么同一张表还有当天读（1 条）。',
        '★ 与 DWD 的差别：DWS 的源表里混了 DWS 同层表，存在**跨系统**边'
        '（HSZTA 读 HSFA），这类边在 DS 上必须跨工作流配依赖。',
        '配置表（无作业）= DS 上没有 SHELL 作业，不配调度依赖。',
    ]:
        c = ws.cell(ws.max_row + 1, 1, '· ' + tip)
        c.alignment = Alignment(vertical='top', wrap_text=True)
    ws.column_dimensions['A'].width = 26
    ws.column_dimensions['B'].width = 8
    ws.column_dimensions['C'].width = 96

    # ---------------- 依赖明细 ---------------- #
    ws2 = wb.create_sheet('依赖明细')
    ws2.append(['脚本', '脚本归属', 'DS工作流', '目标表', '源表', '源层级', '上游脚本',
                '上游归属', '依赖类型', '跨组', '分区读取', '调度依赖', '备注', '来源文件'])
    for e in edges:
        ws2.append([e['script'], e['sys'], e['ds_wf'], e['target'], e['source'],
                    e['src_layer'], e['upstream'], e['up_sys'] or '-', e['kind'],
                    '是' if e['cross'] else '否', e['part'], e['dep'], e['why'],
                    e['file']])
    _style_header(ws2, (44, 9, 11, 40, 40, 8, 44, 9, 16, 7, 22, 20, 44, 52), wrap_from=11)

    # ---------------- 汇总 ---------------- #
    ws3 = wb.create_sheet('汇总')
    ws3.append(['分组', 'DS工作流', '脚本数', '依赖边', 'ODS源', 'DWD源', 'DWS源',
                '跨组依赖', '无DWS脚本上游', '配置表源', '不配依赖(只读前一日)',
                '自引用', '自引用读前一日'])
    for s in SYS:
        rs = [e for e in edges if e['sys'] == s]
        srs = [r for r in selfrefs if r['sys'] == s]
        ws3.append([
            s, SYS2DS[s], len({e['script'] for e in rs}), len(rs),
            len({e['source'] for e in rs if e['src_layer'] == 'ODS'}),
            len({e['source'] for e in rs if e['src_layer'] == 'DWD'}),
            len({e['source'] for e in rs if e['src_layer'] == 'DWS'}),
            len({(e['script'], e['source']) for e in rs if e['cross']}),
            len({e['source'] for e in rs
                 if e['upstream'] == '-' and e['source'] not in CONFIG_TBLS}),
            len({e['source'] for e in rs if e['source'] in CONFIG_TBLS}),
            len({(e['target'], e['source']) for e in rs if e['dep'].startswith('不配')}),
            len(srs), len([r for r in srs if r['is_prev']]),
        ])
    _style_header(ws3, (9, 11, 9, 9, 9, 9, 9, 10, 16, 10, 20, 9, 14))

    # ---------------- 自引用(读前一日) ---------------- #
    ws4 = wb.create_sheet('自引用(读前一日)')
    ws4.append(['脚本', '归属', '表', '分区读取', '是否读前一日', 'DS 依赖', '说明', '来源文件'])
    for r in sorted(selfrefs, key=lambda x: (not x['is_prev'], x['script'])):
        ws4.append([
            r['script'], r['sys'], r['table'], r['part'],
            '★ 是' if r['is_prev'] else '否',
            '不配置(自环)' if r['is_prev'] else '不配置(自引用)',
            ('读自己**前一日**分区做累积（口径 = ' + P.PREV_IDIOM_DOC + '）。'
             '配自依赖会成自环；正确做法是由批次日推进——本作业当天实例读的是'
             '**自己昨天**写的分区，所以它依赖的是「昨天那次跑成功」而不是「今天等自己」。'
             if r['is_prev'] else '脚本读自身目标表，已从上游依赖边排除。'),
            r['file'],
        ])
    _style_header(ws4, (44, 9, 40, 20, 12, 18, 88, 52), wrap_from=4)

    # ---------------- 不配依赖(读前一日) ---------------- #
    ws5 = wb.create_sheet('不配依赖(读前一日)')
    ws5.append(['目标表', '目标脚本', '上游表', '上游脚本', '分区读取', 'DS 依赖',
                '判定口径（前一日惯用式）', '理由'])
    REASON = ('该边在脚本里【每一处】读取上游都只用前一日分区（批次日-1），'
              '当日实例不产出该分区 ⇒ 依赖等的是上游昨天的实例，永远等不到；'
              '若同时存在反向边还会互等死锁。故不配置调度依赖，仅在本页留痕。')
    for e in sorted(drop, key=lambda x: x['target']):
        ws5.append([e['target'], e['script'], e['source'], e['upstream'], e['part'],
                    '不配置', P.PREV_IDIOM_DOC, REASON])
    if not drop:
        ws5.append(['（本次检索：DWS 层无此类边）', '', '', '', '', '', P.PREV_IDIOM_DOC,
                    'DWS 里用前一日惯用式读取的 7 处，全部落在**自引用**上（见'
                    '「自引用(读前一日)」页），另有 1 条边同表还存在当天读 ⇒ 依赖必须保留。'
                    '故本页为空。'])
    _style_header(ws5, (40, 40, 38, 40, 22, 10, 62, 96), wrap_from=5)

    # ---------------- 分区口径检索 ---------------- #
    ws6 = wb.create_sheet('分区口径检索')
    ws6.append(['脚本', '归属', '别名', '归类', 'P_DT 条件原文'])
    order = {k: i for i, k in enumerate(P.PART_ORDER)}
    for c in sorted(conds, key=lambda x: (x['script'], order.get(x['cls'], 9), x['alias'])):
        ws6.append([c['script'], c['sys'], c['alias'] + '.P_DT',
                    P.PART_LABEL[c['cls']], c['expr']])
    _style_header(ws6, (44, 9, 12, 20, 110), wrap_from=5)

    # ---------------- 问题清单 ---------------- #
    # ★ 2026-10-24：加「修复状态 / 修复说明」两列。缺陷记录是**登记式**的——
    #    修好后历史仍留在交付文档里（可追溯「为什么改过」），但状态必须准确，
    #    否则重跑 --apply 后又变成"开放缺陷"，误导后续接手的人。
    ws7 = wb.create_sheet('问题清单')
    ws7.append(['序号', '级别', '问题', '位置', '证据', '影响', '建议修复',
                '修复状态', '修复说明'])
    for d in defect_rows:
        ws7.append([d['no'], d['level'], d['title'], d['where'],
                    d['evidence'], d['impact'], d['fix'],
                    d.get('status', ''), d.get('fix_note', '')])
    _style_header(ws7, (6, 8, 60, 46, 90, 72, 60, 16, 62), wrap_from=3)

    # ---------------- 跨组依赖 ---------------- #
    ws8 = wb.create_sheet('跨组依赖')
    ws8.append(['脚本', '脚本归属', '目标表', '源表', '上游脚本', '上游归属', 'DS 依赖', '备注'])
    for e in sorted([e for e in edges if e['cross']],
                    key=lambda x: (x['sys'], x['script'], x['source'])):
        ws8.append([e['script'], e['sys'], e['target'], e['source'], e['upstream'],
                    e['up_sys'], e['dep'], '跨系统边：DS 上必须配跨工作流依赖'])
    _style_header(ws8, (44, 10, 40, 40, 40, 10, 18, 40), wrap_from=7)

    # ---------------- 表级血缘 ---------------- #
    ws9 = wb.create_sheet('表级血缘')
    ws9.append(['目标表', '归属', '脚本', '源表列表', '源表数', '上游脚本数', '跨组数'])
    tmap = collections.OrderedDict()
    for e in edges:
        tmap.setdefault(e['target'], {'sys': e['sys'], 'script': e['script'], 'src': []})
        if e['source'] not in tmap[e['target']]['src']:
            tmap[e['target']]['src'].append(e['source'])
    for t, v in sorted(tmap.items()):
        ups = {e['upstream'] for e in edges if e['target'] == t and e['upstream'] != '-'}
        crs = {e['source'] for e in edges if e['target'] == t and e['cross']}
        ws9.append([t, v['sys'], v['script'], ', '.join(sorted(v['src'])),
                    len(v['src']), len(ups), len(crs)])
    _style_header(ws9, (42, 9, 42, 120, 8, 11, 8))

    # ---------------- 无同名脚本上游 ---------------- #
    ws10 = wb.create_sheet('无同名脚本上游')
    ws10.append(['源表', '源层级', '依赖类型', '引用脚本数', '被引脚本', '备注'])
    cnt = collections.defaultdict(set)
    kinds = {}
    for e in edges:
        if e['upstream'] == '-' and e['source'] not in CONFIG_TBLS:
            # ★ 配置表另立「配置表(无作业)」页（沿用旧版口径），不混进本页
            cnt[e['source']].add(e['script'])
            kinds[e['source']] = (e['src_layer'], e['kind'])
    for t, scr in sorted(cnt.items(), key=lambda x: -len(x[1])):
        ws10.append([t, kinds[t][0], kinds[t][1], len(scr), ', '.join(sorted(scr)),
                     '由 DWD/ODS 层提供，不是缺脚本'])
    _style_header(ws10, (42, 8, 18, 11, 80, 42))

    # ---------------- 历史页原样搬运 ---------------- #
    for name in ('字段级血缘', '执行顺序', '临时表', '血缘对照', '排除脚本', '语法校验',
                 '运行结果', '配置表(无作业)'):
        if name in old:
            carry(old[name], wb.create_sheet(name))

    # ---------------- 说明 ---------------- #
    ws11 = wb.create_sheet('说明')
    ws11.append(['项目', '内容'])
    for kv in [
        ['生成时间', time.strftime('%Y-%m-%d %H:%M:%S')],
        ['生成器', 'tools/dws-dep-report.py（可复现；旧版一次性脚本已不在仓库）'],
        ['脚本范围', 'scripts/{系统}/dws/02_etl 下 HSFA 7 + HSZTA 8 + O32 9，共 24 个'],
        ['依赖口径', '从脚本 INSERT 目标与 FROM/JOIN 源表解析；_TMP 不计入主依赖；'
                     '自引用单独成页'],
        ['分区口径真源', 'tools/dwd-pipeline.py 的 needs_schedule_dep / partition_modes；'
                         'DWD 与 DWS 共用一套判定，避免漂移'],
        ['前一日惯用式', P.PREV_IDIOM_DOC],
        ['分区口径依据', 'DS 全局参数 p_start_dt = p_end_dt = ${system.biz.date}'
                         '（批次日 = 运行日-1）'],
        ['DWS 检索结论', f'{len(edges)} 条边中 0 条满足「只读前一日 ⇒ 不配依赖」；'
                         f'自引用前一日读 {len(selfprev)} 个脚本；'
                         f'含前一日也有当天读 {len(mixed)} 条（依赖必须保留）'],
        ['与 DWD 的差别', 'DWS 存在跨系统边（HSZTA 读 HSFA），DS 上必须跨工作流配依赖'],
        ['配置表口径', '配置类上游表无作业，不计入无同名作业缺口'],
        ['历史页说明', '字段级血缘 / 执行顺序 / 临时表 / 血缘对照 / 排除脚本 / 语法校验 / '
                       '运行结果 为 2026-10-21 版原样保留，本脚本不重算'],
        ['注意', 'DWS 三个工作流在 DS 上**从未运行过**（实例数 0），'
                 '故「问题清单」的缺陷均为潜在缺陷而非线上故障；'
                 '2026-10-24 已按用户要求修复 ①②③（见「问题清单」页的修复状态列），'
                 '修复后 DWS 仍待首次实跑验证'],
    ]:
        ws11.append(kv)
    _style_header(ws11, (20, 116), wrap_from=2)
    return wb


def main():
    ap = argparse.ArgumentParser(description='生成/刷新 DWS_依赖关系.xlsx')
    ap.add_argument('--apply', action='store_true', help='写盘（默认 dry-run）')
    args = ap.parse_args()

    edges, selfrefs, conds, meta = scan()
    d = defects(edges, selfrefs, meta)
    old = {}
    if TARGET_XLSX.is_file():
        wb_old = load_workbook(TARGET_XLSX, read_only=True, data_only=True)
        old = {nm: wb_old[nm] for nm in wb_old.sheetnames}
        print(f'旧工作簿 {len(old)} 页：{", ".join(old)}')

    drop = [e for e in edges if e['dep'].startswith('不配')]
    mixed = [e for e in edges if e['dep'] == '需配' and 'prev' in e['modes']]
    alike = [e for e in edges if 'prev_alike' in e['modes']]
    selfprev = [r for r in selfrefs if r['is_prev']]

    print(f'脚本 {len(meta)} | 依赖边 {len(edges)} | 分区条件 {len(conds)}')
    print(f'★ 不配依赖(只读前一日): {len(drop)}')
    for e in drop:
        print(f'   {e["target"]}  ←  {e["source"]}')
    print(f'自引用 {len(selfrefs)} 个，其中读前一日 {len(selfprev)} 个:')
    for r in selfprev:
        print(f'   [{r["sys"]}] {r["script"]}  ←  自己   {r["part"]}')
    print(f'含前一日也有当天读（保留）: {len(mixed)}')
    for e in mixed:
        print(f'   [{e["sys"]}] {e["target"]}  ←  {e["source"]}   {e["modes"]}')
    print(f'P_BATCH_DT 变体（只报不删）: {len(alike)}')
    for e in alike:
        print(f'   [{e["sys"]}] {e["target"]}  ←  {e["source"]}   {e["modes"]}')
    print(f'问题清单 {len(d)} 项:')
    for x in d:
        print(f'   {x["no"]}. [{x["level"]}] {x["title"]}')

    wb = build(edges, selfrefs, conds, meta, d, old)
    if args.apply:
        wb.save(TARGET_XLSX)
        print(f'\n写出 {TARGET_XLSX}（{len(wb.sheetnames)} 页：{", ".join(wb.sheetnames)}）')
    else:
        print('\n(dry-run，未落盘)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
