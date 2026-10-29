#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""★ 从 **`scripts/*/dwd/lineage/DWD_lineage.xlsx`** 直接构建 DWD 依赖配置
（映射表默认**参与**建图；`--exclude-mapping` 可回退到旧的「映射表排除」口径）。

与 `ds-build-dependent.py` 的区别
--------------------------------
| | 旧（`ds-build-dependent.py`） | 新（本工具） |
|---|---|---|
| 依赖来源 | 甲方 Excel `05-脚本/脚本调度依赖关系梳理.xlsx`（137 表/626 行） | **生成器自己产出的 `dwd/lineage/DWD_lineage.xlsx`**（4 个系统，569 行） |
| 归属判定 | 依赖表的「所属工作流」列 ⇒ **易写反**（10-05 踩过：`DWD_EVT/AST/TRAN` 被误塞进 `DWD_PROD`） | **只看表名前缀** `DWD_<主题>_` → `DWD_<主题>`（唯一规则，不可能写反） |
| 有脚本率 | 137 张目标表里**一堆没脚本** | **109 张目标表 100% 有脚本** |
| 映射表 | 参与建图 | ★ **默认参与**（2026-10-10 用户口径变更）；加 `--exclude-mapping` 可回退 |

★★★ 关于映射表（`_MAPP` / `_MAP` / 中文名含「映射」）—— 口径变更史
--------------------------------------------------------
- **旧口径（～2026-10-09）：完全排除**。映射表（编码映射，如 `DWD_PROD_SFAC_NUM_MAPP_PFD`
  帐套编码映射、`DWD_CMM_STD_DICT_CDVAL_MAP` 标准字典码值映射）属**维表/码表**：
  不是每日批次产物（多为手工维护或独立全量刷新），但血缘里被依赖极频繁
  （`STD_DICT_CDVAL_MAP` 作上游 **96 次**、`SFAC_NUM_MAPP` 51 次、`SCR_NUM_MAPP` 42 次）
  ⇒ 参与建图会让几乎所有 DWD 表都挂上指向它的边，**DAG 糊成一团**。
- **新口径（2026-10-10 起）：默认不排除**，映射表**照常建节点、照常建边**。
  ⇒ 依赖边会从 298 涨到 ~556 条，**DAG 明显变密**，这是预期代价。
  ⇒ 需回退旧行为时加 `--exclude-mapping`。

用法
----
    python tools/ds-build-dependent-from-lineage.py              # 生成到 tools/dep-config-lineage/
    python tools/ds-build-dependent-from-lineage.py --stats      # 只看统计，不落盘
"""
import argparse
import collections
import difflib
import glob
import importlib.util
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import dw_paths  # noqa: E402


def _wsl_path(p):
    r"""Windows 路径在 WSL 里不存在时回退 `/mnt/<盘>/...`（本工具两种环境都跑）。"""
    if os.path.isdir(p) or ":" not in p:
        return p
    drive, rest = p[0], p[3:].replace("\\", "/")
    alt = "/mnt/" + drive.lower() + "/" + rest.lstrip("/")
    return alt if os.path.isdir(alt) else p


def _load_core(name, f):
    """按文件路径加载 `tools/core/` 下的共享模块（本目录文件名带连字符，不能走包导入）。"""
    path = os.path.join(os.path.dirname(HERE), "core", f)
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


REPO = _wsl_path(dw_paths.SCRIPTS)
OUT = _wsl_path(os.path.join(HERE, "dep-config-lineage"))
PCODE = 185582190746560
CHUNK = 20

# ★ 映射表判据：表名里有 MAPP / 以 _MAP 结尾，或中文名含「映射」
MAP_RE = re.compile(r"_MAPP|_MAP$|_MAP_|MAPP")
# ★ 基本信息表判据（2026-10-10 用户口径）
BASIC_RE = re.compile(r"BASIC_INFO")


def is_map(name, cn=""):
    return bool(MAP_RE.search(name)) or "映射" in str(cn or "")


def is_basic_info(name, cn=""):
    """基本信息表：表名含 BASIC_INFO 或中文名含「基本信息」。

    用于「映射表 ← 基本信息表」边的剔除（见 main 里的 mapp_basic_skipped）。

    ★★ 2026-10-16 修正：本函数**只应作用于 DWD 上游**。
      中文名叫「…基本信息…」的 **ODS 表**（如 `ODS_HSFTA_TCUSTOMERINFO_PFD`
      客户基本信息、`ODS_HSDS_TFUNDINFO_PFD` 基金基本信息表）会被误判 ⇒
      真实的 ODS 依赖被当成「映射表←基本信息表」杀掉（实测误杀 3 条）。
      调用处必须先用 `u.startswith("DWD_")` 收窄（见 `mapp_basic_hit()`）。
    """
    return bool(BASIC_RE.search(name)) or "基本信息" in str(cn or "")


def mapp_basic_hit(t_is_map, u, cn_u):
    """「映射表 ← 基本信息表」是否命中（用于剔除）。

    规则初衷（2026-10-10）：DWD 映射表与 DWD 基本信息表**互指**构成 2-环，
    DS 建图报 `50019 workflow node has cycle` ⇒ 剔除「映射表 ← 基本信息表」方向。

    ★ 所以**只对 DWD→DWD 生效**：ODS 落在 `ods_<sys>_etl_NN`，按本文件自己的
      口径「不可能参与 DWD 环」，没有 2-环问题，剔除它只会**丢真实依赖**。
    """
    return t_is_map and u.startswith("DWD_") and is_basic_info(u, cn_u)


def norm(name):
    """去掉库名前缀：`DWDXDAY.DWD_X` / `DWD.DWD_X` / `ODS_XDAY_HSFA.ODS_HSFA_TX` → 裸表名。"""
    if not isinstance(name, str):
        return ""
    s = name.strip()
    if "." in s:
        s = s.rsplit(".", 1)[1]
    return s.upper()


TBL_LAYER = {}       # 表 -> "MASTER" / "DWD" / "ODS"（按血缘来源打标）

# ★ 表 → 工作流 的归属口径：**唯一来源** `tools/core/dwd_ownership.py`。
#   此前本文件与 `tools/dwd-pipeline.py` 各复制一份 WORKFLOW_OVERRIDE，靠文档提醒同步；
#   2026-10-29 起两处都只做薄委托，口径变更只改共享模块。
_OWNERSHIP = _load_core("dwd_ownership", "dwd_ownership.py")
WORKFLOW_OVERRIDE = _OWNERSHIP.WORKFLOW_OVERRIDE


def own_workflow(table):
    """★★ 归属只有一条规则：`DWD_<主题>_…` → `DWD_<主题>`。

    （旧的「查甲方依赖表的『所属工作流』列」极易写反 —— 那列的语义是
     「产出该行**源表**的工作流」，10-05 就是在这里把别的主题塞进了 DWD_PROD。）

    ★ 2026-10-15 晚：MASTER（主数据）表**不单独建工作流**，按主题并入
    `DWD_<主题>`（用户决定「MASTER 和其他 DWD 放一起，按主题」）——
    血缘来自 `scripts/MASTER/dwd/lineage` 的表与 01-DWD 的表同主题同名，
    归属同一个 `DWD_<主题>` 工作流（TBL_LAYER 仅作信息保留，不改变归属）。
    """
    return _OWNERSHIP.own_workflow(table)


# --------------------------------------------------------------------------- #
# ODS 批次定位（与 ds-deploy-dwd-workflow.py 保持一致）
# --------------------------------------------------------------------------- #
def script_of(table):
    for s in os.listdir(REPO):
        p = os.path.join(REPO, s, "dwd", "02_etl", table + ".sh")
        if os.path.isfile(p):
            return p
    return None


def ods_chunks(sys_name):
    d = os.path.join(REPO, sys_name, "ods", "etl_sh")
    if not os.path.isdir(d):
        return []
    files = sorted(f[:-3] for f in os.listdir(d)
                   if f.endswith(".sh") and not f.startswith(".")
                   and "deploy-to-worker" not in f)
    return [(i // CHUNK + 1, files[i:i + CHUNK]) for i in range(0, len(files), CHUNK)]


def locate_ods(table):
    """`ODS_<SYS>_<T>` → `ods_<sys>_etl_NN`；找不到就用 difflib 找最相近的兄弟表所在批次。"""
    sys_name = table.split("_")[1]
    chunks = ods_chunks(sys_name)
    for n, ts in chunks:
        if table in ts:
            return f"ods_{sys_name.lower()}_etl_{n:02d}"
    allt = [t for _, ts in chunks for t in ts]
    close = difflib.get_close_matches(table, allt, n=1, cutoff=0.6)
    if close:
        for n, ts in chunks:
            if close[0] in ts:
                return f"ods_{sys_name.lower()}_etl_{n:02d}"
    return None


def dep_params():
    return {"localParams": [], "resourceList": [], "rawScript": "",
            "dependence": {"relation": "AND",
                           "dependTaskList": [{"relation": "AND", "dependItemList": []}],
                           "checkInterval": 60,
                           "failurePolicy": "DEPENDENT_FAILURE_FAILURE",
                           "failureWaitingTime": 0}}


# --------------------------------------------------------------------------- #
# ★★ 最小破环（2026-10-10 定型）：取代「一律切掉映射表边」
# --------------------------------------------------------------------------- #
def find_all_cycles(adj, maxlen=10):
    """枚举全部简单环（限制长度，避免组合爆炸）。"""
    cycles, seen = [], set()

    def dfs(path, inpath):
        for nxt in sorted(adj.get(path[-1], ())):
            if nxt == path[0]:
                key = tuple(sorted(path))
                if key not in seen:
                    seen.add(key)
                    cycles.append(list(path))
            elif nxt not in inpath and len(path) < maxlen:
                inpath.add(nxt)
                path.append(nxt)
                dfs(path, inpath)
                path.pop()
                inpath.discard(nxt)

    for s in sorted(adj):
        dfs([s], {s})
    return cycles


def break_wf_cycles(edge_info, meta, verbose=True):
    """在「工作流级」依赖图上求**最小反馈弧集**（贪心）。

    edge_info: `{(上游工作流, 目标工作流): {上游表名: [目标表名…]}}`

    ★ 为什么必须无环：DS 的 DEPENDENT 跨工作流依赖**不允许成环** ——
      既排不出创建/删除顺序（先建哪个都缺对方的 code），运行时也会互等死锁。

    ★★ 为什么不「一律切掉映射表边」（旧策略，已废弃）
      旧做法：只要上游是映射表（`_MAPP`/`_MAP`/含「映射」）就整条跨流边丢掉。
      代价：把**真实依赖也一起丢了** ——
      2026-10-10 用户报「EVT 怎么不依赖 PROD？」就是这个坑：
      `DWD_EVT_*` 通过 `DWD_PROD_SFAC_NUM_MAPP_PFD`（帐套编码映射）依赖 DWD_PROD，
      而 PROD→EVT 这条边的 14 张上游表**全是映射表** ⇒ 被整体丢掉。

    ★ 新策略（贪心最小反馈弧集）：
      1) 找出全部简单环；
      2) 选**出现在最多环里**的那条边切断（切一条顶多条）；
      3) 同次数时优先切 **纯映射表边**（映射表是维表，切断语义损失最小）；
      4) 再同则优先切 **表边数最少**的（影响面最小）；
      5) 重复直到无环。
      实测：全量建边 6 个环，只需切 2 条边（`PROD→CMM`、`PROD→PTY`，均为纯映射边）
      ⇒ 保住了 `PROD→EVT`(14)、`CMM→EVT`(14)、`SCR→EVT`(13)、
         `PROD→TRAN`(24)、`CMM→TRAN`(26) 等真实依赖。
    """
    def pure_map(e):
        return all(is_map(u, meta.get(u, "")) for u in edge_info[e])

    def ntab(e):
        return sum(len(v) for v in edge_info[e].values())

    adj = collections.defaultdict(set)
    for uw, tw in edge_info:
        adj[uw].add(tw)

    cut = []
    while True:
        cycles = find_all_cycles(adj)
        if not cycles:
            break
        cnt = collections.Counter()
        for c in cycles:
            for i in range(len(c)):
                cnt[(c[i], c[(i + 1) % len(c)])] += 1
        # 排序键：环内出现次数降序 → 纯映射优先 → 表边数升序 → 边名（稳定）
        best = min(cnt, key=lambda e: (-cnt[e], 0 if pure_map(e) else 1, ntab(e), e))
        cut.append(best)
        adj[best[0]].discard(best[1])
        if verbose:
            tbls = sorted(edge_info[best])
            print(f"   ✂ 切断 {best[0]:12s} → {best[1]:12s}"
                  f"  （落在 {cnt[best]} 个环、{len(tbls)} 张上游表"
                  f"{'、纯映射' if pure_map(best) else ''}）: {tbls[:4]}")
    return cut


# --------------------------------------------------------------------------- #
def load_lineage():
    """读全部 `scripts/*/dwd/lineage/DWD_lineage.xlsx` 的「表级血缘(扁平)」。"""
    import pandas as pd
    files = sorted(glob.glob(os.path.join(REPO, "*", "dwd", "lineage", "DWD_lineage.xlsx")))
    if not files:
        sys.exit("找不到任何 DWD_lineage.xlsx")
    pairs = []
    meta = {}
    tgt_layer = {}          # 目标表 -> MASTER / DWD（按血缘文件来源）
    for f in files:
        # f = scripts/<SYS>/dwd/lineage/DWD_lineage.xlsx ⇒ 往上三层才是 <SYS>
        sys_name = os.path.basename(os.path.dirname(os.path.dirname(os.path.dirname(f))))
        df = pd.read_excel(f, sheet_name="表级血缘(扁平)")
        for _, r in df.iterrows():
            t, u = norm(r["目标表英文名"]), norm(r["上游表英文名"])
            if not t or not u or t == u:
                continue
            pairs.append((t, u, sys_name))
            meta.setdefault(t, str(r["目标表中文名"] or ""))
            meta.setdefault(u, str(r["上游表中文名"] or ""))
            tgt_layer[t] = "MASTER" if sys_name == "MASTER" else "DWD"
    # 层标：目标表用来源；上游表按「是不是某层血缘的目标表」归类，
    # 都不是（ODS_* / 甲方手工表）→ ODS/其他（own_workflow 本就返回未知）。
    for t, u, _s in pairs:
        TBL_LAYER[t] = tgt_layer.get(t, "DWD")
        if u not in TBL_LAYER:
            TBL_LAYER[u] = tgt_layer.get(u, "ODS")
    return files, pairs, meta


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--stats", action="store_true", help="只看统计，不落盘")
    ap.add_argument("--exclude-mapping", action="store_true",
                    help="排除映射表（**旧口径**，默认不排除）。"
                         "映射表指表名含 MAPP/_MAP 或中文名含「映射」的维表/码表。")
    ap.add_argument("--exclude-table", default="",
                    help="逗号分隔：这些表**作上游**的依赖边全部剔除"
                         "（2026-10-16 用于 DWD_CMM_STD_DICT_CDVAL_MAP 码表）。")
    ap.add_argument("--exclude-prev-day", default="",
                    help="「上一日分区」依赖边清单 JSON（由 tools/_scan_prev_day_deps.py 产出），"
                         "命中 (目标表, 上游表) 的边全部剔除。")
    args = ap.parse_args()

    files, pairs, meta = load_lineage()
    print(f"lineage 文件 {len(files)} 个："
          + ", ".join(os.path.basename(
              os.path.dirname(os.path.dirname(os.path.dirname(f)))) for f in files))
    print(f"表级血缘 {len(pairs)} 行")

    # ---- 1. 映射表：默认**参与建图**（2026-10-10 用户口径变更）----
    #    ★ 旧口径是「完全排除」（不建节点、不建边），理由是映射表被依赖极频繁
    #      （STD_DICT_CDVAL_MAP 作上游 96 次）会让 DAG 糊成一团。
    #    ★ 2026-10-10 用户明确要求「映射表不排除」⇒ 改为默认参与，
    #      同时保留 `--exclude-mapping` 开关以便随时回退到旧口径。
    all_names = set()
    for t, u, _ in pairs:
        all_names.add(t)
        all_names.add(u)

    if args.exclude_mapping:
        maps = sorted(n for n in all_names if is_map(n, meta.get(n, "")))
        print(f"\n★ 映射表（{len(maps)} 张）—— **完全排除**（--exclude-mapping 旧口径）:")
        for n in maps:
            as_t = sum(1 for t, _, _ in pairs if t == n)
            as_u = sum(1 for _, u, _ in pairs if u == n)
            print(f"   {n:38s} {meta.get(n, ''):14s} 作目标 {as_t:3d} / 作上游 {as_u:3d}")
        mset = set(maps)
    else:
        maps = sorted(n for n in all_names if is_map(n, meta.get(n, "")))
        mset = set()
        print(f"\n★ 映射表（{len(maps)} 张）—— **参与建图**（默认口径，2026-10-10 用户要求）:")
        for n in maps:
            as_t = sum(1 for t, _, _ in pairs if t == n)
            as_u = sum(1 for _, u, _ in pairs if u == n)
            print(f"   {n:38s} {meta.get(n, ''):14s} 作目标 {as_t:3d} / 作上游 {as_u:3d}")

    # ---- 2. 留下来的边 ----
    edges = [(t, u, s) for t, u, s in pairs if t not in mset and u not in mset]
    dropped = len(pairs) - len(edges)
    print(f"\n{'排除映射表后' if mset else '未排除映射表'}：丢掉 {dropped} 行，剩 {len(edges)} 条依赖边")

    # ---- 2b. ★ 2026-10-16 用户口径：两张「排除名单」 ----
    #   ① `--exclude-table` 指定表名（本次 = DWD_CMM_STD_DICT_CDVAL_MAP 标准码值字典映射表）：
    #      它是**码表/维表**，不是每日批次产物，却几乎被所有 DWD 脚本 JOIN ⇒ 建依赖会让
    #      每张 DWD 表都挂一条指向它的边，DAG 糊成一团且它本身也没有 ETL 脚本可等。
    #      ⇒ 只剔「它作上游」的边，不剔它作目标的行（它无脚本，本来就不会建作业）。
    #   ② `--exclude-prev-day`：剔除「脚本读上一日分区」的依赖边（读 P_DT = p_end_dt - 1）。
    #      这类边等的是**上游昨天的实例**，当日实例满足不了 ⇒ 要么死锁要么无意义。
    #      名单由 tools/_scan_prev_day_deps.py 扫描脚本产出。
    if args.exclude_table:
        xset = {x.strip().upper() for x in args.exclude_table.split(",") if x.strip()}
        before = len(edges)
        edges = [(t, u, s) for t, u, s in edges if u not in xset]
        print(f"\n★ 排除指定表（作上游）{sorted(xset)}：丢掉 {before - len(edges)} 行，剩 {len(edges)} 条")

    if args.exclude_prev_day:
        pf = args.exclude_prev_day
        try:
            pdoc = json.load(open(pf, encoding="utf-8"))
        except Exception as e:
            sys.exit(f"读上一日依赖清单失败: {pf} ({e})")
        pset = {(a.upper(), b.upper()) for a, b, *_ in pdoc.get("edges", [])}
        before = len(edges)
        edges = [(t, u, s) for t, u, s in edges if (t, u) not in pset]
        print(f"\n★ 排除「上一日分区」依赖边（{pf}，{len(pset)} 条）："
              f"丢掉 {before - len(edges)} 行，剩 {len(edges)} 条")
        for a, b in sorted(pset)[:20]:
            print(f"     - {a} → {b}")


    targets = sorted({t for t, _, _ in edges})
    print(f"目标表 {len(targets)} 张")
    noscript = [t for t in targets if not script_of(t)]
    print(f"  其中有 ETL 脚本: {len(targets) - len(noscript)}，无脚本: {len(noscript)}")
    for t in noscript[:15]:
        print(f"     ⚠ 无脚本 {t} {meta.get(t, '')}")

    # ---- 3. 逐表构造配置 ----
    os.makedirs(OUT, exist_ok=True)
    up_by_t = collections.defaultdict(list)
    for t, u, s in edges:
        up_by_t[t].append((u, s))

    # ---- 3. 先按「工作流级」汇总候选跨流边，再做**最小破环** ----
    #   （★ 2026-10-10 取代旧的「上游是映射表就整条丢弃」——
    #     那样会把 PROD→EVT 这类真实依赖一起丢掉，详见 break_wf_cycles 注释）
    cross_all = collections.defaultdict(lambda: collections.defaultdict(list))
    for t in targets:
        if not script_of(t):
            continue
        wf = own_workflow(t)
        t_is_map = is_map(t, meta.get(t, ""))
        for u, _s in sorted(set(up_by_t[t])):
            if mapp_basic_hit(t_is_map, u, meta.get(u, "")):
                continue                       # ★ 映射表←基本信息表：剔除（同 main 循环口径）
            if u.startswith("ODS_"):
                continue                       # ODS → ods_*_etl_NN，不可能参与 DWD 环
            w = own_workflow(u)
            if w == "(未知)" or w == wf:
                continue
            if not script_of(u):
                continue                       # 上游无脚本 ⇒ 建不出作业级依赖，跳过
            cross_all[(w, wf)][u].append(t)
    print(f"\n工作流级候选跨流边 {len(cross_all)} 条（DWD→DWD，上游/目标都有脚本）")
    cut = break_wf_cycles(cross_all, meta)
    cutset = set(cut)
    print(f"★ 最小破环切断 {len(cut)} 条工作流级边，其余 {len(cross_all) - len(cut)} 条**全部保留**")

    by_wf = collections.Counter()
    unresolved = []
    written = 0
    mapping_dep_total = 0      # 2026-10-15: mapping_deps 条目累计
    mapping_tables = set()     # 2026-10-15: 被引用的映射表集合
    map_edge_skipped = 0          # ★ 因「上游是映射表」而跳过的跨工作流边数（已废弃，恒 0）
    cut_hits = 0                  # ★ 因破环而丢弃的表级依赖数
    noscript_up = 0               # ★ 上游是 DWD 但无脚本 ⇒ 无法建依赖
    mapp_basic_skipped = 0        # ★ 「映射表 ← 基本信息表」被剔除的依赖数
    for t in targets:
        if not script_of(t):
            continue
        wf = own_workflow(t)
        by_wf[wf] += 1
        t_is_map = is_map(t, meta.get(t, ""))
        same, cross = [], collections.OrderedDict()
        unresolved_wf = []
        mapping_deps = []   # 2026-10-15: 无脚本映射表上游（见下方 noscript_up 分支）
        for u, sys_name in sorted(set(up_by_t[t])):
            # ★★★ 2026-10-10 用户口径：**映射表依赖基本信息表的边去掉**。
            #   为什么：这类边（如 `DWD_PROD_PROD_NUM_MAPP_PFD ← DWD_PROD_PROD_BASIC_INFO_PFD`
            #   产品编码映射 ← 产品基本信息）与反方向「基表 ← 映射表」构成 **2-环**
            #   （DS 建图报 `50019 workflow node has cycle`）。
            #   语义上映射表（编码映射/码表）由 ODS 直接产出，不该等基表 ⇒ 剔除。
            #   实测命中 3 组：PROD_BASIC_INFO↔PROD_NUM_MAPP、
            #   SFAC_PROD_BASIC_INFO↔SFAC_NUM_MAPP、SCR_BASIC_INFO↔SCR_NUM_MAPP。
            # ★★ 2026-10-16：改为 `mapp_basic_hit()` —— **只杀 DWD 上游**。
            #   原写法连 `ODS_HSFTA_TCUSTOMERINFO_PFD`(客户基本信息)、
            #   `ODS_HSDS_TFUNDINFO_PFD`(基金基本信息表) 这类**中文名带「基本信息」的 ODS**
            #   一起杀了 ⇒ 误杀 3 条真实 ODS 依赖。
            if mapp_basic_hit(t_is_map, u, meta.get(u, "")):
                mapp_basic_skipped += 1
                continue
            if u.startswith("ODS_"):
                w = locate_ods(u)
                if not w:
                    unresolved.append((t, u))
                    continue
            else:
                w = own_workflow(u)
                if w == "(未知)":
                    unresolved.append((t, u))
                    continue
                # ★★★ 上游是 DWD 但**没有 ETL 脚本** ⇒ DS 里根本不存在这个作业，
                #   建出来的作业级依赖会指向空 code（实测 116 条，典型代表
                #   `DWD_CMM_STD_DICT_CDVAL_MAP` 标准字典码值映射，被引用 96 次）。
                if not script_of(u):
                    noscript_up += 1
                    # 2026-10-15（用户要求）：映射表（无脚本的编码映射/码表）
                    #   依赖不再静默丢弃，记录到 mapping_deps（含归属工作流）。
                    #   部署工具据此建【空脚本占位任务】+ 同工作流依赖边
                    #   （只配依赖、脚本给空，防脚本不通过一直等待）。
                    #   跨工作流引用不建任务级边：目标工作流当天没跑时
                    #   DEPENDENT_ON_TASK 永久 WAITING（dependent 事故同款），
                    #   跨流语义仍由门禁兜底。
                    if is_map(u, meta.get(u, "")):
                        mapping_deps.append({
                            "source": u, "source_cn": meta.get(u, ""),
                            "owner_workflow": w,
                        })
                    continue
            if w == wf:
                same.append({"source": u, "source_cn": meta.get(u, "")})
            elif (w, wf) in cutset:
                # ★ 这条跨工作流边被最小破环切掉了 ⇒ 该表依赖一并丢弃（保证建图/跑批无环）
                cut_hits += 1
                continue
            else:
                cross.setdefault(w, []).append({"source": u, "source_cn": meta.get(u, "")})
                if w not in unresolved_wf:
                    unresolved_wf.append(w)
        cfg = {
            "target": t,
            "target_cn": meta.get(t, ""),
            "layer": "DWD",
            "own_workflow": wf,
            "dependency_rows": len(up_by_t[t]),
            "cross_workflow": [{"workflow": w, "code": None, "sources": srcs}
                               for w, srcs in cross.items()],
            "same_workflow_predecessors": same,
            "mapping_deps": mapping_deps,   # 2026-10-15: 无脚本映射表上游（部署器建空任务+边）
            "no_workflow_sources": [],
            "unresolved_workflows": unresolved_wf,
            "dependent_task_params": dep_params(),
            "_source": "dwd/lineage",
        }
        if not args.stats:
            with open(os.path.join(OUT, t + ".dep.json"), "w", encoding="utf-8") as f:
                json.dump(cfg, f, ensure_ascii=False, indent=1)
        written += 1
        mapping_dep_total += len(mapping_deps)
        for _md in mapping_deps:
            mapping_tables.add(_md["source"])

    print(f"\n归属分布（DWD_<主题>）：")
    for w, n in sorted(by_wf.items(), key=lambda x: -x[1]):
        print(f"   {w:14s} {n:3d} 张")
    if unresolved:
        print(f"\n⚠ 无法解析上游的（{len(unresolved)} 条，已跳过该依赖）:")
        for t, u in unresolved[:20]:
            print(f"   {t} ← {u}")
    print(f"\n{'（--stats，未落盘）' if args.stats else f'已写出 {written} 份到 ' + OUT}")
    print(f"★ 因破环丢弃表级依赖 {cut_hits} 条")
    print(f"★ 剔除「映射表 ← 基本信息表」依赖 {mapp_basic_skipped} 条（防 2-环，2026-10-10 用户口径）")
    print(f"★ 上游是 DWD 但无脚本（无法建作业级依赖）{noscript_up} 条")
    print(f"★ 其中映射表依赖已记录到 mapping_deps（部署器建空脚本占位任务）"
          f"{mapping_dep_total} 条 / {len(mapping_tables)} 张表")
    return 0


if __name__ == "__main__":
    sys.exit(main())
