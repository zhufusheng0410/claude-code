#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把 DS 工作流重排成整齐网格 —— **DWD / ODS 两用**（二合一）。

并入自（原文件已删，2026-10-11）：
  `dwd` ← `ds-relayout-dwd.py`   3 列前置依赖 + 3 列作业（每排 3 对），消除坐标叠压
  `ods` ← `ds-relayout-ods.py`   零连线纯 SHELL，每排 3 列作业（紧凑网格）

★ 只改 `locations`，**不动** task / relation / code / 依赖 —— 非破坏性、可反复执行。
★ 已符合目标布局的默认跳过（`--force` 强制）。
★ **默认间距两套值刻意分层，别顺手统一**：
    DWD 500（对间另留 +120 ⇒ 620；UI 节点宽 350 ⇒ 间隙 150px）
    ODS 416（= 节点宽 350 + 66px；ODS 用 500 会浪费横向空间，DWD 用 416 会 dep/任务左右叠）

用法
----
    python ds-relayout.py dwd [--apply] [--only DWD_PROD] [--force] [--col-w 500]
    python ds-relayout.py ods [--apply] [--only ods_hsfa_etl_01] [--force] [--col-w 416] [--per-row 3]
"""
import argparse
import importlib.util
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_client import project_code, task_definitions  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def _load(name, f):
    s = importlib.util.spec_from_file_location(name, os.path.join(HERE, f))
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


D = _load("DWDDEPLOY", "ds-deploy-dwd-workflow.py")
SYNC = _load("DS_SYNC", "ds-sync-dwd-scripts.py")


def j(x):
    if isinstance(x, str):
        try:
            return json.loads(x)
        except Exception:
            return []
    return x or []


def pcode():
    if not hasattr(pcode, "_c"):
        res = D.call("GET", "/projects", params={"pageNo": 1, "pageSize": 100})
        pcode._c = project_code(res, "dw")
    return pcode._c


def _submit(P, own_code, wfd, rels, tasks, new_locs, summary):
    """OFFLINE → PUT → ONLINE（原在线则恢复）+ 调度快照/恢复。两路共用。"""
    snap = SYNC.snapshot_online_schedules()
    was_online = (wfd.get("releaseState") == "ONLINE")
    if was_online:
        off = D.call("POST", "/projects/%d/workflow-definition/%d/release" % (P, own_code),
                     form={"releaseState": "OFFLINE"})
        if off.get("code") != 0:
            return summary + "  ✗ OFFLINE 失败 %s" % str(off)[:150]
    form = {
        "name": wfd["name"], "description": wfd.get("description") or "",
        "globalParams": wfd.get("globalParams") or "[]",
        "locations": json.dumps(new_locs, ensure_ascii=False),
        "timeout": wfd.get("timeout") or 0,
        "tenantCode": wfd.get("tenantCode") or "default",
        "taskRelationJson": json.dumps(rels, ensure_ascii=False),
        "taskDefinitionJson": json.dumps(tasks, ensure_ascii=False),
        "executionType": wfd.get("executionType") or "PARALLEL",
        "releaseState": "OFFLINE",
    }
    up = D.call("PUT", "/projects/%d/workflow-definition/%d" % (P, own_code), form=form)
    if up.get("code") != 0:
        return summary + "  ✗ PUT 失败 %s" % str(up)[:200]
    if was_online:
        on = D.call("POST", "/projects/%d/workflow-definition/%d/release" % (P, own_code),
                    form={"releaseState": "ONLINE"})
        if on.get("code") != 0:
            # ★ 别再静默：PUT 成功但 ONLINE 失败 ⇒ 工作流停在 OFFLINE
            for sid in sorted(snap):
                SYNC.set_schedule(sid, 1)
            return summary + "  ⚠ PUT ✓ 但 ONLINE 失败: %s" % str(on)[:150]
    for sid in sorted(snap):
        SYNC.set_schedule(sid, 1)
    return summary + "  ✓ 已提交"


# ============================ DWD ============================ #
def _relayout_dwd_one(P, w, args):
    g = D.call("GET", "/projects/%d/workflow-definition/%d" % (P, w["code"]))["data"]
    tasks = task_definitions(g)
    rels = j(g["workflowTaskRelationList"])
    wfd = g["workflowDefinition"]
    locs = j(wfd.get("locations"))
    own_code = w["code"]

    members = [t["name"] for t in tasks if t["taskType"] == "SHELL"]
    dep_names = {t["name"] for t in tasks if t["taskType"] == "DEPENDENT"}
    name2code = {t["name"]: t["code"] for t in tasks}
    code2name = {t["code"]: t["name"] for t in tasks}
    dep_codes = {t["code"] for t in tasks if t["taskType"] == "DEPENDENT"}
    sh_codes = {t["code"] for t in tasks if t["taskType"] == "SHELL"}

    dep_of = {m: "dep_%s" % m for m in members if ("dep_%s" % m) in dep_names}
    cur_dep = sorted({int(L["x"]) for L in locs if L["taskCode"] in dep_codes})
    cur_sh = sorted({int(L["x"]) for L in locs if L["taskCode"] in sh_codes})
    # ★ 2026-10-15 修正「假跳过」：原判定只看「列数==3」，**既不看列间距、也不看 dep↔作业
    #   偏移** ⇒ 距离 340 的老图被判成「已达标」而跳过（DWD_ACCT/CHNL/TRAN 就这样漏掉；
    #   DWD_PUB 只有 1 对、无列间距可查，也一并漏掉，dep 与作业仍叠 10px）。
    #   达标 = ① 列数 ≤ per_row ② 列间距 == PAIR_W = 2*COL_W+120 ③ 每对 dep→作业偏移 == COL_W。
    pair_gap = 2 * args.col_w + 120
    per_row = getattr(args, "per_row", 3)      # dwd 分支没有 --per-row，恒为 3 对/排
    x_of = {int(L["taskCode"]): int(L["x"]) for L in locs}

    def _cols_ok(xs):
        if len(xs) > per_row:
            return False
        return all(b - a == pair_gap for a, b in zip(xs, xs[1:]))

    offsets = [x_of[name2code[m]] - x_of[name2code[dep_of[m]]]
               for m in members
               if dep_of.get(m) in name2code and m in name2code
               and name2code[dep_of[m]] in x_of and name2code[m] in x_of]
    pair_ok = all(o == args.col_w for o in offsets)

    if _cols_ok(cur_dep) and _cols_ok(cur_sh) and pair_ok and not args.force:
        return "[%s] 已达标（%d 列dep+%d 列作业 / 列距 %d / dep→作业 %d），跳过" % (
            w["name"], len(cur_dep), len(cur_sh), pair_gap, args.col_w)

    logical = set()
    for t in tasks:
        if t["taskType"] != "DEPENDENT" or not t["name"].startswith("dep_"):
            continue
        T = t["name"][4:]
        for grp in (t.get("taskParams") or {}).get("dependence", {}).get("dependTaskList", []):
            for it in grp.get("dependItemList", []):
                if str(it.get("definitionCode")) == str(own_code) and it.get("depTaskCode"):
                    U = code2name.get(it["depTaskCode"])
                    if U in members and T in members:
                        logical.add((U, T))

    locs_by_name, cross, col, row, back, span = D.pair_grid_layout(
        members, set(), dep_of, per_row=3, order_mode="crossing", logical=logical)

    new_locs, placed = [], set()
    for name, pos in locs_by_name.items():
        c = name2code.get(name)
        if c is None:
            continue
        new_locs.append({"taskCode": c, "x": int(pos["x"]), "y": int(pos["y"])})
        placed.add(c)
    leftover = [t["code"] for t in tasks if t["code"] not in placed]
    if leftover:
        maxy = max((int(L["y"]) for L in new_locs), default=D.Y0)
        for k, c in enumerate(leftover):
            new_locs.append({"taskCode": c, "x": D.X0 + k * D.COL_W, "y": maxy + D.ROW_H})

    summary = ("[%s] %d 表: %d列dep+%d列作业 → 3+3 | 交叉 %d 逆序边 %d 跨度 %d"
               % (w["name"], len(members), len(cur_dep), len(cur_sh), cross, back, span)
               + (" | 兜底 %d 个" % len(leftover) if leftover else ""))
    if not args.apply:
        return summary + "  (dry-run)"
    return _submit(P, own_code, wfd, rels, tasks, new_locs, summary)


def cmd_dwd(args):
    # ★ pair_grid_layout 内部读模块全局 COL_W/PAIR_W ⇒ 在这里覆盖即可改整套间距
    D.COL_W = args.col_w
    D.login()
    P = pcode()
    wfs = D.wf_list(P)
    only = {x.strip() for x in args.only.split(",") if x.strip()}
    dwd = sorted([w for w in wfs if w["name"].startswith("DWD_")
                  and (not only or w["name"] in only)], key=lambda x: x["name"])
    for w in dwd:
        print(_relayout_dwd_one(P, w, args))
    if not args.apply:
        print("\n(--dry-run，未提交；加 --apply 提交)")
    return 0


def cmd_dws(args):
    """DWS 与 DWD 同为「dep 节点 + SHELL 作业」的 pair-grid 结构，直接复用排版器。"""
    D.COL_W = args.col_w
    D.login()
    P = pcode()
    wfs = D.wf_list(P)
    only = {x.strip() for x in args.only.split(",") if x.strip()}
    dws = sorted([w for w in wfs if w["name"].startswith("DWS_")
                  and (not only or w["name"] in only)], key=lambda x: x["name"])
    for w in dws:
        print(_relayout_dwd_one(P, w, args))
    if not args.apply:
        print("\n(--dry-run，未提交；加 --apply 提交)")
    return 0


# ============================ ODS ============================ #
def _grid(names, per_row, col_w):
    """纯作业网格：每排 per_row 个，横向间距 col_w"""
    out = {}
    for i, t in enumerate(names):
        r, c = divmod(i, per_row)
        out[t] = {"x": D.X0 + c * col_w, "y": D.Y0 + r * D.ROW_H}
    return out


def _relayout_ods_one(P, w, args):
    g = D.call("GET", "/projects/%d/workflow-definition/%d" % (P, w["code"]))["data"]
    tasks = task_definitions(g)
    rels = j(g["workflowTaskRelationList"])
    wfd = g["workflowDefinition"]
    locs = j(wfd.get("locations"))
    own = w["code"]

    shells = [t for t in tasks if t["taskType"] == "SHELL"]
    others = [t for t in tasks if t["taskType"] != "SHELL"]
    name2code = {t["name"]: t["code"] for t in tasks}
    lc = {L["taskCode"]: (int(L["x"]), int(L["y"])) for L in locs}

    members = sorted(t["name"] for t in shells)
    xs = sorted({lc[t["code"]][0] for t in shells if t["code"] in lc})
    gaps = [xs[i + 1] - xs[i] for i in range(len(xs) - 1)] if len(xs) > 1 else []
    already = (len(xs) <= args.per_row and gaps and all(gap == args.col_w for gap in gaps)
               and xs[0] == D.X0)
    if already and not args.force:
        return "[%s] 已是 %d 列 / 间距 %s，跳过" % (w["name"], len(xs), gaps[0] if gaps else "-")

    pos = _grid(members, args.per_row, args.col_w)
    new_locs = [{"taskCode": name2code[n], "x": p["x"], "y": p["y"]}
                for n, p in pos.items() if n in name2code]
    if others:
        maxy = max((p["y"] for p in pos.values()), default=D.Y0)
        for k, t in enumerate(others):
            new_locs.append({"taskCode": t["code"],
                             "x": D.X0 + k * args.col_w, "y": maxy + D.ROW_H})

    ncols = len({p["x"] for p in pos.values()})
    nrows = len({p["y"] for p in pos.values()})
    summary = ("[%s] %d 作业: %d列/间距%s → %d列×%d行/间距%d"
               % (w["name"], len(members), len(xs), gaps[0] if gaps else "-",
                  ncols, nrows, args.col_w)
               + (" | 兜底 %d 个" % len(others) if others else ""))
    if not args.apply:
        return summary + "  (dry-run)"
    return _submit(P, own, wfd, rels, tasks, new_locs, summary)


def cmd_ods(args):
    D.login()
    P = pcode()
    wfs = D.wf_list(P)
    only = {x.strip() for x in args.only.split(",") if x.strip()}
    targets = sorted([w for w in wfs
                      if w["name"].lower().startswith(args.match.lower())
                      and (not only or w["name"] in only)], key=lambda x: x["name"])
    print("匹配 %s* 的工作流 %d 个（每排 %d 列 / 间距 %d）"
          % (args.match, len(targets), args.per_row, args.col_w))
    for w in targets:
        print(_relayout_ods_one(P, w, args))
    if not args.apply:
        print("\n(--dry-run，未提交；加 --apply 提交)")
    return 0


# ============================ main ============================ #
def main():
    ap = argparse.ArgumentParser(description="DS 工作流重排（dwd / dws / ods）")
    sub = ap.add_subparsers(dest="cmd", required=True)

    def common(p, default_colw, colw_help):
        p.add_argument("--apply", action="store_true", help="提交（默认 dry-run）")
        p.add_argument("--only", default="", help="只处理指定工作流，逗号分隔")
        p.add_argument("--force", action="store_true", help="已符合的也重排")
        p.add_argument("--col-w", type=int, default=default_colw, help=colw_help)

    p = sub.add_parser("dwd", help="DWD：3 列前置依赖 + 3 列作业")
    common(p, D.COL_W, "dep→作业水平间距（默认 %d = UI 节点宽 350 + 150px）。★ ODS 为 416，两层刻意分层" % D.COL_W)
    p.set_defaults(func=cmd_dwd)

    p = sub.add_parser("dws", help="DWS：3 列前置依赖 + 3 列作业（同 DWD 版式）")
    common(p, D.COL_W, "dep→作业水平间距（默认 %d = UI 节点宽 350 + 150px）" % D.COL_W)
    p.set_defaults(func=cmd_dws)

    p = sub.add_parser("ods", help="ODS：零连线纯 SHELL 紧凑网格")
    common(p, 416, "列间距（默认 416 = 节点宽 350 + 66px）。★ 必须 > UI 节点宽（350）")
    p.add_argument("--match", default="ods_", help="工作流名前缀（默认 ods_）")
    p.add_argument("--per-row", type=int, default=3, help="每排几列（默认 3）")
    p.set_defaults(func=cmd_ods)

    args = ap.parse_args()
    return args.func(args) or 0


if __name__ == "__main__":
    raise SystemExit(main())
