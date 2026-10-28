#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""往【已存在的 DWD 工作流】里增量加一张表（SHELL 作业 + DEPENDENT 依赖节点）

为什么需要这个脚本
------------------
`ds-deploy-dwd-workflow.py` 的语义是「**整条工作流重建**」—— `create_wf()` 第一行就是
`drop_wf()`。用它加一张表会把现有 30+ 个任务全删掉重排，零交叉布局虽然能重算，但：
① 已有任务 code 会全部变化，历史实例与 `t_ds_task_instance.task_code` 对不上；
② 依赖配置 `dep-config-lineage/*.dep.json` 里没有的那张表（如映射表）会被直接忽略，
   重建后**其它表反而丢了依赖**（`plan()` 只认 cfgs 里的成员）。

所以本脚本走**增量路线**：回读现有工作流的三段式定义 → 在其 tasks/rels/locations 上
追加新节点 → `PUT /workflow-definition` 整条回写。已有 code / version / 布局**原样保留**。

复用的既有逻辑（从 ds-deploy-dwd-workflow.py import，不复制粘贴）：
    login / call / wf_list / wf_code / build_task / build_dep_task / rel / script_of
    snapshot_online_schedules / set_schedule

四坑（与 ds-deploy-dwd-workflow.py 第 13 节同源，这里同样适用）
--------------------------------------------------------------
① DELETE 返���码必须校验：`drop_wf()` 不校验会静默留旧、随后 create 报 `10168`。
   —— 本脚本**不删任何东西**，天然规避。
② 依赖节点要补 `preTaskCode=0` 的入边，否则误报 `50019 has cycle`。
③ 改零连线工作流前，先摘掉目标表原有的 0 号入边（本脚本只增不改，天然规避）。
④ 不允许 0 任务（`50017`）—— 本脚本只增，任务数只会变多。

自引用依赖（`DEPENDENT_ON_TASK` 指回本工作流自身任务）会被 `neutralize_selfdeps()`
影响，所以本脚本在回写前会先对该表的上游做「跨工作流 / 同工作流」分流。

用法
----
    # 干跑（默认，不改任何东西）
    python tools/ds-add-dwd-table.py --table DWD_PROD_PROD_NUM_MAPP_PFD --workflow DWD_PROD

    # 真跑
    python tools/ds-add-dwd-table.py --table DWD_PROD_PROD_NUM_MAPP_PFD --workflow DWD_PROD --apply
"""

import argparse
import importlib.util
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_text import read_script  # noqa: E402
from ds_client import project_code  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
DEPLOYER = os.path.join(HERE, "ds-deploy-dwd-workflow.py")

# ── 复用既有部署工具的函数，避免逻辑分叉 ────────────────────────────────── #
_spec = importlib.util.spec_from_file_location("DWDDEPLOY", DEPLOYER)
D = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(D)

# 调度快照/恢复复用同步脚本（同一套「改工作流会级联下线」的处理）
SYNC_PATH = os.path.join(HERE, "ds-sync-dwd-scripts.py")
_s2 = importlib.util.spec_from_file_location("DS_SYNC", SYNC_PATH)
SYNC = importlib.util.module_from_spec(_s2)
_s2.loader.exec_module(SYNC)

PCODE_NAME = D.PROJECT
TENANT = "default"


def pcode():
    """项目 code（回读一次，缓存）。"""
    if not hasattr(pcode, "_c"):
        res = D.call("GET", "/projects", params={"pageNo": 1, "pageSize": 100})
        pcode._c = project_code(res, PCODE_NAME)
    return pcode._c


def wf_name(code):
    """工作流 code → 名称（带缓存）。wf_list 返回的是 list（不是分页对象）。"""
    if not hasattr(wf_name, "_c"):
        wf_name._c = {}
    if code not in wf_name._c:
        wf_name._c[code] = next(
            (w.get("name") for w in (D.wf_list(pcode()) or []) if w.get("code") == code),
            f"(code={code})")
    return wf_name._c[code]


def load_cfg(table):
    """读 dep-config-lineage 里该表的配置；找不到返回 None（映射表被排除规则跳过）。"""
    for f in sorted(os.listdir(D.DEPCFG)):
        if not f.endswith(".dep.json"):
            continue
        c = json.load(open(os.path.join(D.DEPCFG, f), encoding="utf-8"))
        if c.get("target") == table:
            return c
    return None


# ★ 上游表名 → 系统代号。**注意**：脚本里写的是带 XDAY 的全名（ODS_XDAY_HSZTA_TFUNDINFO_PFD），
#   而本地目录是 scripts/<SYS>/ods/etl_sh/ODS_<SYS>_<TBL>.sh（不含 XDAY）。
#   所以匹配时要把 XDAY 摘掉再比，直接拿全名 startswith('ODS_XDAY_HSZTA_') 是错的。
SYS_LIST = ["HSZTA", "HSFTA", "HSFA", "HSDS", "OA", "OFFW", "WIND", "JY"]


def sys_of(table_short):
    """表名（ODS_HSZTA_XXX）→ 系统代号 HSZTA；匹配不到返回 None。"""
    for v in SYS_LIST:
        if table_short.startswith(f"ODS_{v}_"):
            return v
    return None


def upstream_items(cfg, own_wf_code, tasks_old):
    """把配置里的上游表名解析成依赖项 list。

    分流规则
    --------
    · 上游是 `ODS_*`            ⇒ locate_ods 找批次工作流 ⇒ DEPENDENT_ON_WORKFLOW
    · 上游是 `DWD_*` 且不是本表   ⇒ DWD_<主题> 工作流      ⇒ DEPENDENT_ON_WORKFLOW
    · 上游是本工作流的兄弟表      ⇒ DEPENDENT_ON_TASK（definitionCode = 自身工作流）
    · 上游是映射表 / 手工表       ⇒ 跳过（DS 里没有对应工作流，等了也永远等不到）
    """
    items, skipped = [], []
    for src in (cfg.get("sources") or []):
        s = src if isinstance(src, str) else src.get("name", "")
        if not s or s == cfg.get("target"):
            continue

        if s.startswith("ODS_"):
            sysname = sys_of(s)
            wf = D.locate_ods(sysname, s) if sysname else None
            if not wf:
                skipped.append((s, f"本地 ODS 脚本里找不到 {sysname}/{s}"))
                continue
            code = D.wf_code(pcode(), wf)
            if not code:
                skipped.append((s, f"DS 里没有工作流 {wf}"))
                continue
            items.append({"cycle": "day", "dateValue": "today", "depTaskCode": 0,
                          "projectCode": pcode(), "dependentType": "DEPENDENT_ON_WORKFLOW",
                          "definitionCode": code, "parameterPassing": False})
            continue

        if s.startswith("DWD_"):
            # 本工作流内的兄弟表 → 任务级依赖
            tc = next((t["code"] for t in tasks_old if t["name"] == s), 0)
            if tc:
                items.append({"cycle": "day", "dateValue": "today", "depTaskCode": tc,
                              "projectCode": pcode(), "dependentType": "DEPENDENT_ON_TASK",
                              "definitionCode": own_wf_code, "parameterPassing": False})
            else:
                skipped.append((s, "同工作流内也没有这个作业（可能也是映射表）"))
            continue

        skipped.append((s, "非 ODS/DWD 前缀，未知归属"))

    return items, skipped


def parse_src_tables(script_path):
    """从 ETL 脚本里抠出真实读到的表（`FROM X.Y` / `JOIN X.Y`），去重保序。

    ★ 比读 dep-config-lineage 可靠：那是「配置」，这是「脚本实际执行」。

    ★★ `prev_partition_only`（本次新增，用户要求）
       脚本里的 JOIN 条件若带 `T2.P_DT = '${p_end_dt_1}'`，说明它读的是**上一日分区**，
       不是当日上游产出的数据 ⇒ **不能算作依赖**。典型场景就是自引用
       （`DWD_PROD_PROD_NUM_MAPP_PFD` 的 4 组 UNION 都 LEFT JOIN 自己取历史映射）。
       实现方式：把表名后面「直到下一个 FROM/JOIN 之前的正文」抓出来，若其中出现
       `p_end_dt_1` / `p_start_dt_1` 之类「非当日分区」变量即判定为历史读取。
    """
    import re
    txt = read_script(script_path)
    # 以 FROM/JOIN 为分隔点切片，保留「本表 + 其后的 JOIN 条件正文」
    parts = re.split(r"\b(?:FROM|JOIN)\s+([A-Za-z_][\w]*)\.([A-Za-z_]\w*)", txt)
    # parts = [前文, 库1, 表1, 正文1, 库2, 表2, 正文2, ...]
    out = []            # [(全名, 是否只读历史分区)]
    for i in range(1, len(parts) - 1, 3):
        db, tbl = parts[i].upper(), parts[i + 1].upper()
        body = parts[i + 2] if i + 2 < len(parts) else ""
        full = f"{db}.{tbl}"
        prev = bool(re.search(r"p_(?:end|start)_dt_1\b", body))
        if full not in [x[0] for x in out]:
            out.append((full, prev))
    return out


def _drop_if_prev(full, prev):
    """`prev=True`（该表只读上一日分区）⇒ 返回剔除理由；否则返回 None。"""
    if prev:
        return (full, "只读上一日分区（p_end_dt_1）⇒ 历史数据，不是当日上游")
    return None


def manual_upstream(table, own_wf_code, tasks_old, task_index):
    """映射表没有 dep 配置 ⇒ 直接按脚本里的源表构造依赖项。

    ★★ 用户要求（10-05）：**依赖一律用作业级**（`DEPENDENT_ON_TASK`），不再等整条工作流。
       理由：整条工作流级依赖会把「等 1 张 ODS 表」放大成「等 18 张表的那条工作流」，
             无关表失败/被删都会连带卡住，且 11 个主题之间互相等的链条会越滚越长。

    ★★ 用户要求（10-05）：**凡依赖了 `p_end_dt_1` 的表一律去掉该依赖**。
       见 `parse_src_tables` 的 `prev` 判定。

    分流：
    · ODS_*  → 定位到【具体作业 code】，跨工作流 ⇒ DEPENDENT_ON_TASK
               （definitionCode=上游工作流, depTaskCode=上游作业）
    · DWD_*  → 同工作流兄弟表 ⇒ DEPENDENT_ON_TASK（definitionCode=自身工作流）
    · 映射表 / 手工表 / 无作业 ⇒ 跳过（DS 里没有对应作业，等了也永远等不到）
    """
    script = D.script_of(table)
    all_tbls = parse_src_tables(script)
    items, skipped = [], []
    for full, prev in all_tbls:
        s = full.split(".")[-1]

        # ★ 规则一：只读上一日分区的（自引用）不产生依赖
        why = _drop_if_prev(full, prev)
        if why:
            skipped.append(why)
            continue
        if s == table:
            skipped.append((full, "自引用（同表，非上游）"))
            continue

        if s.startswith("ODS_"):
            sysname = sys_of(s)
            if not sysname:
                skipped.append((full, f"系统代号未登记（SYS_LIST={SYS_LIST}）⇒ 手工表无 ODS 工作流"))
                continue
            wf = D.locate_ods(sysname, s)
            if not wf:
                skipped.append((full, f"本地 {sysname}/ods/etl_sh 里找不到 {s}"))
                continue
            code = D.wf_code(pcode(), wf)
            if not code:
                skipped.append((full, f"DS 里没有工作流 {wf}"))
                continue
            # ★ 作业级：定位该 ODS 表在 DS 里的具体任务 code
            #   task_index 的值是 (工作流code, 作业code)，这里要【第二个】
            hit = task_index.get(s)
            tc = hit[1] if hit else 0
            if not tc:
                skipped.append((full, f"{wf} 里找不到作业 {s}"))
                continue
            items.append({"cycle": "day", "dateValue": "today", "depTaskCode": tc,
                          "projectCode": pcode(),
                          "dependentType": "DEPENDENT_ON_TASK",
                          "definitionCode": code, "parameterPassing": False})
        elif s.startswith("DWD_"):
            tc = next((t["code"] for t in tasks_old if t["name"] == s), 0)
            if tc:
                items.append({"cycle": "day", "dateValue": "today", "depTaskCode": tc,
                              "projectCode": pcode(),
                              "dependentType": "DEPENDENT_ON_TASK",
                              "definitionCode": own_wf_code,
                              "parameterPassing": False})
            else:
                skipped.append((full, "DS 里既无同工作流作业，也无独立工作流"))
        else:
            skipped.append((full, "非 ODS/DWD 前缀"))
    return items, skipped


def build_task_index():
    """全项目「作业名 → (工作流code, 作业code)」索引。

    ★ 用户要求（10-05）：依赖用**作业级**，所以必须能把 ODS 表名解析到具体作业，
      不能只停在工作流粒度。这里一次性把 11 个 DWD + 全部 ODS 工作流的作业名全捞回来。
    """
    if hasattr(build_task_index, "_c"):
        return build_task_index._c
    idx = {}
    for w in D.wf_list(pcode()) or []:
        wid, wname = w["code"], w["name"]
        r = D.call("GET", f"/projects/{pcode()}/workflow-definition/{wid}")
        if r.get("code") != 0:
            continue
        for t in (r["data"].get("taskDefinitionList") or []):
            if isinstance(t, str):
                t = json.loads(t)
            idx[t["name"]] = (wid, t["code"])
    build_task_index._c = idx
    return idx


def build_plan(args):
    login = D.login
    login()
    P = pcode()

    own_code = D.wf_code(P, args.workflow)
    if not own_code:
        sys.exit(f"工作流 {args.workflow} 不存在")

    script = D.script_of(args.table)
    if not script:
        sys.exit(f"本地找不到脚本：{args.table}.sh")
    # ★ 2026-10-22：改用共用的 ds_text.read_script（统一 CRLF→LF，
    #   且比原式多处理裸 \r；原实现只 replace("\r\n")）
    raw = read_script(script)

    # ── 回读现有定义（三段式）────────────────────────────────────────────── #
    res = D.call("GET", f"/projects/{P}/workflow-definition/{own_code}")
    if res.get("code") != 0:
        sys.exit(f"回读失败: {json.dumps(res, ensure_ascii=False)[:300]}")
    d = res["data"]
    wf_def = d["workflowDefinition"]
    tasks_old = d.get("taskDefinitionList") or []
    rels_old = d.get("workflowTaskRelationList") or []
    locs_old = json.loads(wf_def["locations"]) if isinstance(wf_def.get("locations"), str) \
        else (wf_def.get("locations") or [])
    if tasks_old and isinstance(tasks_old[0], str):
        tasks_old = json.loads(tasks_old[0])
    if rels_old and isinstance(rels_old[0], str):
        rels_old = json.loads(rels_old[0])

    names = {t["name"] for t in tasks_old}
    dep_name = f"dep_{args.table}"
    if args.table in names:
        sys.exit(f"{args.table} 已在工作流里，跳过")
    if dep_name in names:
        sys.exit(f"{dep_name} 已存在，跳过")

    # ── 新 code：取全局未用的最大值 +1（DS 要求唯一且非 0）──────────────── #
    all_codes = [t["code"] for t in tasks_old] or [0]
    new_shell_code = max(all_codes) + 1
    new_dep_code = new_shell_code + 1

    cfg = load_cfg(args.table)
    tindex = build_task_index()
    if cfg is None:
        items, skipped = manual_upstream(args.table, own_code, tasks_old, tindex)
        print("  依赖配置  : 【查不到】⇒ 被映射表排除规则跳过，改用"
              "**脚本实际源表**手工构造依赖（不改 dep-config-lineage，避免污染 103 表口径）")
    else:
        items, skipped = upstream_items(cfg, own_code, tasks_old)

    print(f"== 目标 ==")
    print(f"  工作流   : {args.workflow} (code={own_code}, 现有 {len(tasks_old)} 任务)")
    print(f"  表       : {args.table}")
    print(f"  脚本     : {script}  ({len(raw)} chars)")
    print(f"  新 SHELL code : {new_shell_code}")
    print(f"  新 DEP  code : {new_dep_code}")
    if cfg is not None:
        print(f"  配置归属  : {cfg.get('own_workflow')} / 上游 {cfg.get('sources')}")
    print(f"  解析出依赖项 {len(items)} 条（**全部作业级**）：")
    code2name = {tc: n for n, (wc, tc) in tindex.items()}
    for it in items:
        tid = it["depTaskCode"]
        scope = "本工作流" if it["definitionCode"] == own_code \
            else "工作流 " + str(wf_name(it["definitionCode"]))
        print(f"     - [TASK] 等 {code2name.get(tid, tid)}（{scope}）")
    if skipped:
        print(f"  跳过 {len(skipped)} 个上游（不产生依赖）：")
        for s, why in skipped:
            print(f"     - {s}：{why}")

    # ── 组装 ────────────────────────────────────────────────────────────── #
    new_tasks = list(tasks_old)
    new_rels = list(rels_old)

    new_tasks.append(D.build_task(new_shell_code, args.table, raw,
                                  "DWD 表（增量添加）"))

    if items:
        new_tasks.append(D.build_dep_task(new_dep_code, dep_name, items))
        new_rels.append(D.rel(0, new_dep_code))          # 坑②：入边，否则 50019
        new_rels.append(D.rel(new_dep_code, new_shell_code))

    # ── 布局：新节点放最后一行右侧，不动老坐标 ───────────────────────────── #
    maxx = maxy = 0
    for L in locs_old:
        try:
            maxx = max(maxx, int(L.get("x", 0)))
            maxy = max(maxy, int(L.get("y", 0)))
        except Exception:
            pass
    locs_new = list(locs_old)
    locs_new.append({"taskCode": new_shell_code, "x": maxx + 1, "y": maxy})
    if items:
        locs_new.append({"taskCode": new_dep_code, "x": maxx, "y": maxy})

    print(f"== 变更预览 ==")
    print(f"  任务 {len(tasks_old)} -> {len(new_tasks)}   "
          f"连线 {len(rels_old)} -> {len(new_rels)}   "
          f"坐标 {len(locs_old)} -> {len(locs_new)}")
    if not items:
        print("  ⚠ 依赖项 0 条 ⇒ 不建 DEPENDENT 节点（建了也只是空等）")

    if not args.apply:
        print("\n(--dry-run，未提交)")
        return

    # ── 保护：快照在线调度（改工作流会级联把调度置 OFFLINE）─────────────── #
    # ★ 与 ds-sync-dwd-scripts.py 同款：直接查元库，不用 API（API 只返回 ONLINE 的，
    #   而且 ds_script 账号看不到 dw 项目的调度 ⇒ 会误判「本来就没调度」）。
    online_sched = SYNC.snapshot_online_schedules() if args.apply else set()
    if online_sched:
        print(f"  调度快照：ONLINE {len(online_sched)} 条 {sorted(online_sched)}")

    # ★ was_online：本工作流当前是否 ONLINE（仅当 ONLINE 才需要下线→PUT→上线）。
    #   online_sched 是项目级快照，只用于最后恢复循环，二者职责不同，不能互相替代。
    was_online = (wf_def.get("releaseState") == "ONLINE")
    if was_online:
        print("  本工作流当前 ONLINE，提交前会先 OFFLINE → PUT → ONLINE")
    else:
        print("  本工作流当前 OFFLINE（无调度），直接 PUT 提交")

    if was_online:
        off = D.call("POST", f"/projects/{P}/workflow-definition/{own_code}/release",
                     form={"releaseState": "OFFLINE"})
        if off.get("code") != 0:
            sys.exit(f"OFFLINE 失败（拒绝继续，避免半改状态）：{json.dumps(off)[:300]}")
        print("  ① OFFLINE ✓")

    form = {
        "name": wf_def["name"], "description": wf_def.get("description") or "",
        "globalParams": wf_def.get("globalParams") or "[]",
        "locations": json.dumps(locs_new, ensure_ascii=False),
        "timeout": wf_def.get("timeout") or 0,
        "tenantCode": wf_def.get("tenantCode") or TENANT,
        "taskRelationJson": json.dumps(new_rels, ensure_ascii=False),
        "taskDefinitionJson": json.dumps(new_tasks, ensure_ascii=False),
        "executionType": wf_def.get("executionType") or "PARALLEL",
        "releaseState": "OFFLINE",
    }
    res = D.call("PUT", f"/projects/{P}/workflow-definition/{own_code}", form=form)
    if res.get("code") != 0:
        sys.exit(f"PUT 失败（工作流保持 OFFLINE，请人工检查）: "
                 f"{json.dumps(res, ensure_ascii=False)[:400]}")
    print(f"  ② PUT ✓（{len(new_tasks)} 个任务 / {len(new_rels)} 条连线）")

    if was_online:
        on = D.call("POST", f"/projects/{P}/workflow-definition/{own_code}/release",
                    form={"releaseState": "ONLINE"})
        print(f"  ③ ONLINE {'✓' if on.get('code') == 0 else '❌ ' + str(on)[:200]}")

    for sid in sorted(online_sched):
        SYNC.set_schedule(sid, 1)
    if online_sched:
        print(f"  已恢复调度 ONLINE: {sorted(online_sched)}")

    print("\n提交完成 ✅")
    print(f"  回读核对：python tools/ds-verify-dwd-layout.py --all-dwd")
    print(f"  触发跑数：python tools/ds-run-task.py --task {args.table}")


def main():
    ap = argparse.ArgumentParser(description="往已有 DWD 工作流增量加一张表")
    ap.add_argument("--table", required=True, help="表名，如 DWD_PROD_PROD_NUM_MAPP_PFD")
    ap.add_argument("--workflow", required=True, help="目标工作流名，如 DWD_PROD")
    ap.add_argument("--apply", action="store_true", help="真跑（默认 dry-run）")
    args = ap.parse_args()
    build_plan(args)


if __name__ == "__main__":
    main()
