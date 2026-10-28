#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""★ 从 `scripts/*/dws/lineage/DWS_lineage.xlsx` 的「表级血缘(扁平)」构建 DWS 依赖配置

与 `ds-build-dependent-from-lineage.py`（DWD 版）的关系
-------------------------------------------------------
- helper 全部 importlib 复用 DWD 版（norm / locate_ods / own_workflow /
  break_wf_cycles / dep_params / script_of / ods_chunks），本文件**只加 DWS 差异**，
  不改动现役 DWD 工具。
- 归属规则不同：DWD 用 `DWD_<主题>` 前缀；**DWS 用血缘文件所在系统目录**：
  HSZTA → DWS_ZTA，HSFA → DWS_HSFA，O32 → DWS_O32（与 2026-10-20 方案一致）。
- 上游三分：`ODS_*` → ods_<sys>_etl_NN 批次；`DWD_*` → DWD_<主题> 工作流；
  `DWS_*` → 产出该 DWS 表的系统 DWS 工作流（同流进 same_workflow_predecessors）。
- ★ 防死锁与占位口径（2026-10-20 复核 README 铁律8 + ds-deploy-dwd-workflow.py:136 后定稿）：
  1) DWD 上游脚本位于 scripts/MASTER/ ⇒ DS 里是 `MASTER_EMPTY_TPL` **echo 秒过占位任务**
     （跑 DWD 批次时主数据不真跑、任务本身照常完成保 DAG，不存在死锁）⇒ **照常建边**，
     计入 master_dep 仅作报告；
  2) 无脚本上游（本地无 .sh，无法确认 DS 任务存在，如 _PTD 旧名孤儿）⇒ 跳过并**列出明细**，
     与 DWD 构建器 noscript_up 同口径；不建空占位（占位是 DWD 内部 2026-10-15 口径）。
- 产出：`D:\\datax\\tools\\dep-config-dws\\<TABLE>.dep.json`（schema 与 DWD 版同构，
  layer=DWS, _source=dws/lineage），供 `ds-deploy-api.py plan-dws` 消费。

用法
----
    python3 tools/ds-deploy/ds-build-dws-dependent-from-lineage.py --stats   # 只看统计
    python3 tools/ds-deploy/ds-build-dws-dependent-from-lineage.py           # 落盘
"""
import argparse
import collections
import glob
import importlib.util
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


DWD = _load("dwd_builder", os.path.join(HERE, "ds-build-dependent-from-lineage.py"))

REPO = DWD.REPO
# ★ DWD 版 _wsl_path 在目标目录尚不存在时会回退返回 Windows 字面路径（踩坑：
#   24 份 json 曾落进仓库根的字面目录 `D:\datax\...`），这里显式按平台解析。
OUT = os.path.join(HERE, "dep-config-dws")
# 系统目录 -> DWS 工作流名（2026-10-20 方案 A/B/C）
WF_OF_SYS = {"HSZTA": "DWS_ZTA", "HSFA": "DWS_HSFA", "O32": "DWS_O32"}


def script_of_dws(table, sysname=None):
    """`<table>.sh` 在 scripts/<sys>/dws/02_etl/ 下查找；sysname 缺省时全量扫。"""
    if sysname:
        p = os.path.join(REPO, sysname, "dws", "02_etl", table + ".sh")
        return p if os.path.isfile(p) else None
    for s in sorted(os.listdir(REPO)):
        p = os.path.join(REPO, s, "dws", "02_etl", table + ".sh")
        if os.path.isfile(p):
            return p
    return None


def load_lineage():
    import pandas as pd
    files = sorted(glob.glob(os.path.join(REPO, "*", "dws", "lineage", "DWS_lineage.xlsx")))
    if not files:
        sys.exit("找不到任何 DWS_lineage.xlsx")
    pairs, meta, tgt_sys = [], {}, {}
    for f in files:
        sys_name = os.path.basename(os.path.dirname(os.path.dirname(os.path.dirname(f))))
        if sys_name not in WF_OF_SYS:
            print(f"⚠ 跳过未知系统血缘文件: {f}")
            continue
        df = pd.read_excel(f, sheet_name="表级血缘(扁平)")
        for _, r in df.iterrows():
            t, u = DWD.norm(r["目标表英文名"]), DWD.norm(r["上游表英文名"])
            if not t or not u or t == u:
                continue
            pairs.append((t, u, sys_name))
            meta.setdefault(t, str(r["目标表中文名"] or ""))
            meta.setdefault(u, str(r["上游表中文名"] or ""))
            if tgt_sys.setdefault(t, sys_name) != sys_name:
                print(f"⚠ 目标表跨系统重复: {t} ({tgt_sys[t]} vs {sys_name})")
    return files, pairs, meta, tgt_sys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--stats", action="store_true", help="只看统计，不落盘")
    ap.add_argument("--exclude-prev-day", default="",
                    help="「上一日分区」依赖边清单 JSON（由 dwd-pipeline.py prevday 产出），"
                         "命中 (目标表, 上游表) 的边全部剔除。"
                         "此类边等的是上游**昨天**的实例，当日实例满足不了 ⇒ 不配。")
    args = ap.parse_args()

    files, pairs, meta, tgt_sys = load_lineage()
    print("lineage 文件 %d 个：%s" % (len(files), ", ".join(
        os.path.basename(os.path.dirname(os.path.dirname(os.path.dirname(f)))) for f in files)))
    print(f"表级血缘 {len(pairs)} 行")

    # ---- ★ 剔除「只读前一日分区」的边（与 DWD 版同口径）----
    if args.exclude_prev_day:
        try:
            pdoc = json.load(open(args.exclude_prev_day, encoding="utf-8"))
        except Exception as e:
            sys.exit(f"读上一日依赖清单失败: {args.exclude_prev_day} ({e})")
        pset = {(a.upper(), b.upper()) for a, b, *_ in pdoc.get("edges", [])}
        before = len(pairs)
        pairs = [(t, u, s) for t, u, s in pairs if (t.upper(), u.upper()) not in pset]
        print(f"\n★ 排除「上一日分区」依赖边（{args.exclude_prev_day}，{len(pset)} 条）："
              f"丢掉 {before - len(pairs)} 行，剩 {len(pairs)} 条")
        for a, b in sorted(pset):
            if a.startswith("DWS_"):
                print(f"     - {a} → {b}")

    # ---- 所有 DWS 表的归属（血缘目标 + 实际脚本），供上游 DWS_* 解析 ----
    owner = dict(tgt_sys)
    for s in sorted(os.listdir(REPO)):
        d = os.path.join(REPO, s, "dws", "02_etl")
        if not os.path.isdir(d):
            continue
        for fn in os.listdir(d):
            if fn.endswith(".sh"):
                t = fn[:-3].upper()
                prev = owner.get(t)
                if prev and prev != s:
                    print(f"⚠ DWS 表归属冲突: {t} {prev} vs {s}")
                owner[t] = s

    up_by_t = collections.defaultdict(list)
    for t, u, s in pairs:
        up_by_t[t].append((u, s))

    targets = sorted(up_by_t)
    noscript_t = [t for t in targets if not script_of_dws(t, owner.get(t))]
    print(f"目标表 {len(targets)} 张（有脚本 {len(targets) - len(noscript_t)} / "
          f"无脚本 {len(noscript_t)}）")
    for t in noscript_t:
        print(f"   ⚠ 目标无脚本（不建作业）: {t} {meta.get(t, '')}")

    # ---- 工作流级候选跨流边（破环用；ODS 批次不可能参与环，同 DWD 口径剔除）----
    cross_all = collections.defaultdict(lambda: collections.defaultdict(list))
    for t in targets:
        wf = WF_OF_SYS.get(tgt_sys.get(t, ""))
        if not wf or not script_of_dws(t, owner.get(t)):
            continue
        for u, _s in sorted(set(up_by_t[t])):
            if u.startswith("ODS_"):
                continue
            w = DWD.own_workflow(u) if u.startswith("DWD_") else \
                WF_OF_SYS.get(owner.get(u, ""), "(未知)")
            if w in ("(未知)",) or w == wf:
                continue
            if u.startswith("DWS_") and not script_of_dws(u, owner.get(u)):
                continue
            if u.startswith("DWD_") and not DWD.script_of(u):
                continue
            cross_all[(w, wf)][u].append(t)
    print(f"\n工作流级候选跨流边 {len(cross_all)} 条（DWS↔DWS / DWD→DWS，两端都有脚本）")
    cut = DWD.break_wf_cycles(cross_all, meta)
    cutset = set(cut)
    print(f"★ 最小破环切断 {len(cut)} 条，保留 {len(cross_all) - len(cut)} 条")

    # ---- 逐表构造 dep.json ----
    os.makedirs(OUT, exist_ok=True)
    by_wf = collections.Counter()
    unresolved, noscript_list = [], []
    noscript_up = master_dep = cut_hits = written = 0
    up_kinds = collections.Counter()

    for t in targets:
        sysname = tgt_sys.get(t)
        wf = WF_OF_SYS.get(sysname or "")
        if not wf or not script_of_dws(t, owner.get(t)):
            continue
        by_wf[wf] += 1
        same, cross = [], collections.OrderedDict()
        unresolved_wf = []
        for u, _s in sorted(set(up_by_t[t])):
            if u.startswith("ODS_"):
                up_kinds["ODS"] += 1
                w = DWD.locate_ods(u)
                if not w:
                    unresolved.append((t, u, "ODS 批次定位失败"))
                    continue
            elif u.startswith("DWD_"):
                up_kinds["DWD"] += 1
                sp = DWD.script_of(u)
                if not sp:
                    noscript_up += 1
                    noscript_list.append((t, u))
                    continue
                if os.sep + "MASTER" + os.sep in sp:
                    master_dep += 1
                w = DWD.own_workflow(u)
            elif u.startswith("DWS_"):
                up_kinds["DWS"] += 1
                uown = owner.get(u)
                if not uown:
                    unresolved.append((t, u, "DWS 上游无归属"))
                    continue
                if not script_of_dws(u, uown):
                    noscript_up += 1
                    noscript_list.append((t, u))
                    continue
                w = WF_OF_SYS[uown]
            else:
                up_kinds["其它"] += 1
                unresolved.append((t, u, "非 ODS/DWD/DWS 前缀"))
                continue
            if w == wf:
                same.append({"source": u, "source_cn": meta.get(u, "")})
            elif (w, wf) in cutset:
                cut_hits += 1
            else:
                cross.setdefault(w, []).append({"source": u, "source_cn": meta.get(u, "")})
                if w not in unresolved_wf:
                    unresolved_wf.append(w)

        cfg = {
            "target": t,
            "target_cn": meta.get(t, ""),
            "layer": "DWS",
            "own_workflow": wf,
            "owner_system": sysname,
            "dependency_rows": len(up_by_t[t]),
            "cross_workflow": [{"workflow": w, "code": None, "sources": srcs}
                               for w, srcs in cross.items()],
            "same_workflow_predecessors": same,
            "mapping_deps": [],
            "no_workflow_sources": [],
            "unresolved_workflows": unresolved_wf,
            "dependent_task_params": DWD.dep_params(),
            "_source": "dws/lineage",
        }
        if not args.stats:
            with open(os.path.join(OUT, t + ".dep.json"), "w", encoding="utf-8") as f:
                json.dump(cfg, f, ensure_ascii=False, indent=1)
        written += 1

    print("\n归属分布：")
    for w, n in sorted(by_wf.items(), key=lambda x: -x[1]):
        print(f"   {w:14s} {n:3d} 张")
    print(f"上游构成: {dict(up_kinds)}")
    if unresolved:
        print(f"\n⚠ 无法解析上游（{len(unresolved)} 条，已跳过）:")
        for t, u, why in unresolved[:20]:
            print(f"   {t} ← {u}  [{why}]")
    if noscript_list:
        print(f"\n⚠ 上游无本地脚本（{len(noscript_list)} 条，跳过；核对是否 _PTD 旧名孤儿/DEFAULT_EMPTY）:")
        for t, u in noscript_list[:30]:
            print(f"   {t} ← {u}")
    print(f"\n★ 上游无脚本跳过 {noscript_up} 条 | 破环丢弃 {cut_hits} 条 | "
          f"含主数据占位(MASTER_EMPTY_TPL echo 秒过) {master_dep} 条")
    print(f"{'（--stats，未落盘）' if args.stats else '已写出 %d 份到 %s' % (written, OUT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
