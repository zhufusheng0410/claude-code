#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""★ DS 部署统一接口：**以 JSON 为契约**，可导出、可人工编辑、可直接导入 DS。

解决什么问题
------------
以前「把作业和依赖配到 DS」散在十几个 `ds-*.py` 里，每个都是**直连 DS 改**，
没有中间产物 ⇒ 没法 review、没法版本化、没法跨环境迁移。
本工具把这件事收敛成一条 **JSON 契约**：

    本地产物（脚本 + 血缘）  --plan-->   JSON  --import-->  DS
    DS 现状                --export-->  JSON   （备份 / 迁移 / 人工编辑）

JSON **用名字做键、不写死 code** ⇒ 同一份 JSON 可以导入到另一套 DS（开发/生产），
code 由导入时的环境解析（这正是以前直接改 DS 做不到的事）。

子命令
------
    export    DS → JSON        （`--only WF1,WF2` 限定；`--match ods_` 前缀）
    plan      本地 → JSON      （脚本目录 + lineage 依赖配置；`--only 表1,表2`）
    import    JSON → DS        （幂等 upsert；`--dry-run` 只报差异）

用法:
    python tools/ds-deploy-api.py export --match ods_ -o ods.json
    python tools/ds-deploy-api.py export --only DWD_PROD -o dwd_prod.json
    python tools/ds-deploy-api.py plan --subject DWD_PROD -o plan.json
    python tools/ds-deploy-api.py import -i plan.json --dry-run
    python tools/ds-deploy-api.py import -i plan.json

JSON 结构（schema = dw-ds-deploy/v1）
------------------------------------
    {"schema":"dw-ds-deploy/v1","generated_at":"...","project":"dw","workflows":[
      {"name":"DWD_PROD","description":"","executionType":"SERIAL_WAIT",
       "tenantCode":"dolphinscheduler","globalParams":[],
       "tasks":[{"name":"X","taskType":"SHELL","script":"..."},
                {"name":"dep_X","taskType":"DEPENDENT","dependItems":[
                   {"dependWorkflow":"ods_o32_etl_03","dependTask":"ODS_O32_T..._PFD",
                    "dependentType":"DEPENDENT_ON_TASK"}]}],
       "relations":[["dep_X","X"],[null,"dep_X"]],   # null = 入边（preTaskCode=0）
       "locations":{"X":[40,80],"dep_X":[540,80]}}]}
"""
import argparse
import datetime as dt
import importlib.util
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_client import project_code, task_definitions  # noqa: E402
from ds_text import read_script  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def load(mod, f):
    s = importlib.util.spec_from_file_location(mod, os.path.join(HERE, f))
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


D = load("DWDDEPLOY", "ds-deploy-dwd-workflow.py")
ADD = load("DS_ADD", "ds-add-dwd-table.py")
SYNC = ADD.SYNC

SCHEMA = "dw-ds-deploy/v1"

# ★★ 2026-10-24：DWD 工作流全局参数的**单一来源** =
#   ds-deploy-dwd-workflow.py::global_params()（已含 p_start_dt / p_end_dt / P_BATCH_DT）。
#
#   历史坑（同一个坑踩了两次）：
#     · 10-10  用 fix-dwd-globalparams.py 单独补 globalParams，被重建冲掉；
#     · 10-24 00:30-00:38 用本工具重部署 13 个 DWD/DWS 工作流，
#       cmd_plan 发 `"globalParams": []`、cmd_import 又 `json.dumps(wf.get("globalParams") or [])`
#       ⇒ 把 DWD_ACCT/DWD_PTY 手工补的 P_BATCH_DT 冲掉 ⇒ 18 个任务
#       `P_DT='${P_BATCH_DT}'` 展开成 `P_DT=''`，静默写 0 行且作业报 SUCCESS。
#   ⇒ plan 必须发真参数；import 在 JSON 未带参数时必须**保留现值**而不是写 []。
DWD_GLOBAL_PARAMS = json.loads(D.global_params())


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
        pcode._c = project_code(res, D.PROJECT)
    return pcode._c


def now():
    return dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def out(obj, path):
    if path:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(obj, f, ensure_ascii=False, indent=2)
        print(f"已写出 {path}（{os.path.getsize(path):,} 字节）")
    else:
        print(json.dumps(obj, ensure_ascii=False, indent=2))


# ===================================================================== export
def cmd_export(args):
    D.login()
    P = pcode()
    wfs = [w for w in D.wf_list(P)
           if (not args.only or w["name"] in set(args.only.split(",")))
           and (not args.match or w["name"].lower().startswith(args.match.lower()))]
    wfs.sort(key=lambda x: x["name"])

    # 全局索引：task_code -> (工作流名, 任务名)；wf_code -> 工作流名
    tindex = ADD.build_task_index()                       # 任务名 -> (wf_code, task_code)
    code2name = {}
    for n, (wf, tc) in tindex.items():
        code2name[tc] = n
    wfname = {w["code"]: w["name"] for w in D.wf_list(P)}

    out_wfs = []
    for w in wfs:
        g = D.call("GET", f"/projects/{P}/workflow-definition/{w['code']}")["data"]
        tasks = task_definitions(g)
        rels = j(g["workflowTaskRelationList"])
        wfd = g["workflowDefinition"]
        locs = j(wfd.get("locations"))
        c2n = {t["code"]: t["name"] for t in tasks}

        t_out, loc_out = [], {}
        for t in tasks:
            tp = t.get("taskParams") or {}
            if t["taskType"] == "SHELL":
                t_out.append({"name": t["name"], "taskType": "SHELL",
                              "script": tp.get("rawScript") or ""})
            elif t["taskType"] == "DEPENDENT":
                items = []
                for grp in ((tp.get("dependence") or {}).get("dependTaskList") or []):
                    for it in (grp.get("dependItemList") or []):
                        items.append({
                            "dependWorkflow": wfname.get(it.get("definitionCode"), ""),
                            "dependTask": code2name.get(it.get("depTaskCode"), ""),
                            "dependentType": it.get("dependentType", "DEPENDENT_ON_TASK"),
                            "cycle": it.get("cycle", "day"),
                            "dateValue": it.get("dateValue", "today")})
                t_out.append({"name": t["name"], "taskType": "DEPENDENT",
                              "dependItems": items})
            else:
                t_out.append({"name": t["name"], "taskType": t["taskType"], "taskParams": tp})
        for L in locs:
            n = c2n.get(L.get("taskCode"))
            if n:
                loc_out[n] = [int(L["x"]), int(L["y"])]

        rel_out = []
        for r in rels:
            pre = c2n.get(r.get("preTaskCode")) if r.get("preTaskCode") else None
            post = c2n.get(r.get("postTaskCode"))
            if post:
                rel_out.append([pre, post])

        out_wfs.append({"name": w["name"], "description": wfd.get("description") or "",
                        "executionType": wfd.get("executionType") or "PARALLEL",
                        "tenantCode": wfd.get("tenantCode") or D.TENANT,
                        "globalParams": j(wfd.get("globalParams") or "[]"),
                        "tasks": t_out, "relations": rel_out, "locations": loc_out})
        print(f"  ✓ 导出 {w['name']}（{len(tasks)} 任务）")

    out({"schema": SCHEMA, "generated_at": now(), "project": D.PROJECT,
         "source": {"ds": D.DS, "command": "export"}, "workflows": out_wfs}, args.out)


# ======================================================================= plan
def cmd_plan(args):
    """本地 → JSON：脚本目录 + lineage 依赖配置 ⇒ 作业 + **作业级**依赖 + 3 列布局。"""
    # ★ 列间距必须 > UI 的 DAG 节点宽（**当前 350**；10-06 由 400 缩 1/3 → 267、10-07 拍板 →350），否则节点左右叠
    D.COL_W = args.col_w
    cfgs = {}
    for f in sorted(os.listdir(D.DEPCFG)):
        if f.endswith(".dep.json"):
            c = json.load(open(os.path.join(D.DEPCFG, f), encoding="utf-8"))
            cfgs[c.get("target")] = c

    # 脚本位置：REPO/scripts/<系统>/dwd/<表>.sh（与 ds-sync-dwd-scripts.py 口径一致）
    script_idx = {}
    for root, _, files in os.walk(os.path.join(D.REPO, "scripts")):
        for fn in files:
            if fn.lower().endswith(".sh"):
                script_idx.setdefault(fn[:-3].upper(), os.path.join(root, fn))

    tables = []
    if args.only:
        tables = [t.strip().upper() for t in args.only.split(",") if t.strip()]
    else:
        tables = sorted(cfgs)
    if args.subject:                       # 主题 ⇒ DWD_<主题>_ 前缀
        tables = [t for t in tables if t.startswith(args.subject.upper() + "_")]

    by_wf = {}
    for t in tables:
        cfg = cfgs.get(t)
        if not cfg:
            print(f"  ⚠ 跳过 {t}：dep-config-lineage 里没有它的配置")
            continue
        wf = re.match(r"^(DWD_[A-Z]+)", t)
        wf = wf.group(1) if wf else "DWD_OTHER"
        by_wf.setdefault(wf, []).append((t, cfg))

    out_wfs = []
    for wf in sorted(by_wf):
        tasks, rels, locs = [], [], {}
        n = 0
        for t, cfg in sorted(by_wf[wf]):
            sp = script_idx.get(t)
            script = ""
            if sp and os.path.exists(sp):
                script = read_script(sp)
            else:
                print(f"  ⚠ {t} 脚本文件未找到")
            # 依赖：跨工作流部分 ⇒ 作业级
            items = []
            for cw in (cfg.get("cross_workflow") or []):
                for s in (cw.get("sources") or []):
                    items.append({"dependWorkflow": cw["workflow"],
                                  "dependTask": s["source"],
                                  "dependentType": "DEPENDENT_ON_TASK",
                                  "cycle": "day", "dateValue": "today"})
            dep_name = f"dep_{t}"
            if items:
                tasks.append({"name": dep_name, "taskType": "DEPENDENT",
                              "dependItems": items})
                rels.append([None, dep_name])
                rels.append([dep_name, t])
            else:
                rels.append([None, t])
            tasks.append({"name": t, "taskType": "SHELL", "script": script})
            # 3 列布局：dep 与作业成对（与 ds-relayout-dwd.py 一致）
            r, c = divmod(n, 3)
            x0 = D.X0 + c * (2 * D.COL_W + 120)
            if items:
                locs[dep_name] = [x0, D.Y0 + r * D.ROW_H]
                locs[t] = [x0 + D.COL_W, D.Y0 + r * D.ROW_H]
            else:
                locs[t] = [x0, D.Y0 + r * D.ROW_H]
            n += 1
        out_wfs.append({"name": wf, "description": "由 ds-deploy-api plan 生成",
                        "executionType": D.EXEC, "tenantCode": D.TENANT,
                        # ★ 2026-10-24：以前这里是 [] —— 发空参数，
                        #   import 再原样写回 DS ⇒ globalParams 被清空。
                        "globalParams": DWD_GLOBAL_PARAMS, "tasks": tasks,
                        "relations": rels, "locations": locs})
        print(f"  ✓ 计划 {wf}（{len(tasks)} 任务）")

    out({"schema": SCHEMA, "generated_at": now(), "project": D.PROJECT,
         "source": {"dep_dir": D.DEPCFG, "repo": D.REPO, "command": "plan"},
         "workflows": out_wfs}, args.out)


# ===================================================================== import
def cmd_import(args):
    doc = json.load(open(args.input, encoding="utf-8"))
    if doc.get("schema") != SCHEMA:
        sys.exit(f"JSON schema 不是 {SCHEMA}：{doc.get('schema')}")
    D.login()
    P = pcode()

    existing = {w["name"]: w["code"] for w in D.wf_list(P)}
    tindex = ADD.build_task_index()         # 任务名 -> (wf_code, task_code)

    # ---- 预检：依赖指向的作业是否都能解析（导入前就把问题说清楚）
    miss = []
    for wf in doc["workflows"]:
        for t in wf["tasks"]:
            for it in (t.get("dependItems") or []):
                if it.get("dependTask") and it["dependTask"] not in tindex:
                    miss.append(f"{wf['name']}/{t['name']} → {it['dependTask']}")
    if miss:
        print(f"⚠ 有 {len(miss)} 条依赖指向的作业当前在 DS 里不存在"
              f"（导入后这些项会被跳过，需先导入上游）：")
        for m in miss[:10]:
            print(f"    - {m}")
        if len(miss) > 10:
            print(f"    … 还有 {len(miss) - 10} 条")

    if args.dry_run:
        for wf in doc["workflows"]:
            act = "更新" if wf["name"] in existing else "新建"
            print(f"  [{act}] {wf['name']}（{len(wf['tasks'])} 任务）")
        print("\n(--dry-run，未提交)")
        return

    # ★ 两遍建图：第一遍建/改任务（依赖先留空）⇒ 所有作业 code 就位后再回填依赖。
    #   否则「依赖的作业还没建」会因拿不到 code 而只能留工作流级依赖。
    for wf in doc["workflows"]:
        name = wf["name"]
        snap = SYNC.snapshot_online_schedules()
        if name in existing:
            code = existing[name]
            g = D.call("GET", f"/projects/{P}/workflow-definition/{code}")["data"]
            cur_tasks = task_definitions(g)
            cur_rels = j(g["workflowTaskRelationList"])
            wfd = g["workflowDefinition"]
            was_online = (wfd.get("releaseState") == "ONLINE")
            by_name = {t["name"]: t for t in cur_tasks}
            # ★★ 2026-10-15 实测坑：新任务**不能带 code=0** ——
            #   DS 的 PUT /workflow-definition 会**静默丢弃** code=0 的任务
            #   （API 返回 code=0「更新成功(2 任务)」，回读却只剩原来的 1 个任务）。
            #   ⇒ 新任务必须显式分配非零 code（与 ds-add-dwd-table「max+1」同一口径）。
            next_code = max([t.get("code") or 0 for t in cur_tasks] or [0]) + 1
            merged = []
            for spec in wf["tasks"]:
                old = by_name.get(spec["name"])
                if old:                       # 已存在 ⇒ 复用 code，只更新内容
                    nt = dict(old)
                else:
                    nt = {"code": int(spec.get("code") or next_code), "name": spec["name"]}
                    if not spec.get("code"):
                        next_code += 1
                nt.update(_task_from_spec(spec, nt.get("code") or 0))
                nt["code"] = nt.get("code") or next_code   # 兜底：绝不为 0
                merged.append(nt)
            # 未在本 JSON 里出现的既有任务：保留
            keep = [t for t in cur_tasks if t["name"] not in {m["name"] for m in merged}]
            merged = keep + merged
            tasks, rels = merged, cur_rels
        else:
            code, was_online = None, False
            # 同上：新建工作流时每个任务也必须有非零 code
            _base = int(dt.datetime.now().timestamp() * 1000) % 10 ** 9
            tasks = []
            for _i, _s in enumerate(wf["tasks"]):
                _c = int(_s.get("code") or (_base + _i))
                _t = _task_from_spec(_s, _c)
                _t["code"] = _c
                tasks.append(_t)
            rels = []

        # 关系：按名字解析（已存在的用原 code）
        n2c = {t["name"]: t["code"] for t in tasks}
        for pre, post in wf.get("relations") or []:
            pc = (n2c.get(pre) if pre else 0)
            ps = n2c.get(post)
            if not ps:
                continue
            if not any(r.get("preTaskCode") == pc and r.get("postTaskCode") == ps for r in rels):
                rels.append(D.rel(pc, ps))
        # 坐标
        locs = [{"taskCode": n2c[n], "x": xy[0], "y": xy[1]}
                for n, xy in (wf.get("locations") or {}).items() if n in n2c]
        # ★★ 2026-10-15 第二个坑：原实现把「JSON 未给坐标」的既有任务**一律兜底成
        #   (X0,Y0)** ⇒ 只补 1 个任务就会把同工作流其余任务全部拍平到同一点，
        #   排版（ODS 416 间距 / DWD 500 间距）当场被毁且**不报错**。
        #   正确做法：未指定坐标的既有任务**保留原坐标**。
        old_loc = {}
        try:
            for _L in json.loads(wfd.get("locations") or "[]"):
                old_loc[_L.get("taskCode")] = (_L.get("x"), _L.get("y"))
        except Exception:
            old_loc = {}
        for t in tasks:
            if any(L["taskCode"] == t["code"] for L in locs):
                continue
            _xy = old_loc.get(t["code"])
            locs.append({"taskCode": t["code"],
                         "x": _xy[0] if _xy else D.X0,
                         "y": _xy[1] if _xy else D.Y0})

        # ★★ 2026-10-24：globalParams 绝不允许被 [] 覆盖（详见 DWD_GLOBAL_PARAMS 注释）。
        #   优先级：JSON 显式带的 > 更新时保留 DS 现值 > 新建时 DWD 默认参数。
        gp_raw = wf.get("globalParams")
        if gp_raw:
            gp_json = json.dumps(gp_raw, ensure_ascii=False)
        elif code:                       # 更新：保留 DS 里的现值（绝不写 []）
            gp_json = wfd.get("globalParams") or "[]"
        elif name.startswith("DWD_"):    # 新建：DWD 默认参数
            gp_json = json.dumps(DWD_GLOBAL_PARAMS, ensure_ascii=False)
        else:                            # ODS 等：无参数可保留
            gp_json = "[]"

        form = {"name": name, "description": wf.get("description") or "",
                "globalParams": gp_json,
                "locations": json.dumps(locs), "timeout": 0,
                "tenantCode": wf.get("tenantCode") or D.TENANT,
                "taskRelationJson": json.dumps(rels, ensure_ascii=False),
                "taskDefinitionJson": json.dumps(tasks, ensure_ascii=False),
                "executionType": wf.get("executionType") or D.EXEC,
                "releaseState": "OFFLINE"}
        if code:
            if was_online:
                D.call("POST", f"/projects/{P}/workflow-definition/{code}/release",
                       form={"releaseState": "OFFLINE"})
            up = D.call("PUT", f"/projects/{P}/workflow-definition/{code}", form=form)
            verb, ok = "更新", up.get("code") == 0
        else:
            up = D.call("POST", f"/projects/{P}/workflow-definition", form=form)
            verb, ok = "新建", up.get("code") == 0
            if ok:
                code = up["data"]["code"]
                existing[name] = code
        if not ok:
            print(f"  ✗ {verb} {name} 失败: {str(up)[:200]}")
            continue
        # 回填依赖（第二遍用同一个 PUT 接口，此处所有任务 code 已确定）
        _backfill_deps(P, code, wf, tasks)
        if was_online:
            on = D.call("POST", f"/projects/{P}/workflow-definition/{code}/release",
                        form={"releaseState": "ONLINE"})
            if on.get("code") != 0:
                print(f"  ⚠ {name} 已{verb}但 ONLINE 失败: {str(on)[:120]}")
        for sid in sorted(snap):
            SYNC.set_schedule(sid, 1)
        print(f"  ✓ {verb} {name}（{len(tasks)} 任务）")


def _task_from_spec(spec, code):
    """JSON 里的一个任务 spec → DS 的 task 结构"""
    if spec["taskType"] == "SHELL":
        t = D.build_task(code, spec["name"], spec.get("script") or "", "")
    elif spec["taskType"] == "DEPENDENT":
        t = D.build_dep_task(code, spec["name"], [])   # 依赖第二遍回填
    else:
        t = D.build_task(code, spec["name"], "", "")
        t["taskType"] = spec["taskType"]
        t["taskParams"] = spec.get("taskParams") or {}
    return t


def _backfill_deps(P, wf_code, wf_spec, tasks):
    """第二遍：把 DEPENDENT 的 dependItems 从**名字**解析成 code 并 PUT 回去。"""
    need = {t["name"] for t in wf_spec["tasks"]
            if t["taskType"] == "DEPENDENT" and t.get("dependItems")}
    if not need:
        return
    tindex = ADD.build_task_index()
    wfcodes = {w["name"]: w["code"] for w in D.wf_list(P)}
    g = D.call("GET", f"/projects/{P}/workflow-definition/{wf_code}")["data"]
    cur = task_definitions(g)
    rels = j(g["workflowTaskRelationList"])
    wfd = g["workflowDefinition"]
    locs = j(wfd.get("locations"))
    spec_by = {t["name"]: t for t in wf_spec["tasks"]}
    changed = False
    for t in cur:
        if t["name"] not in need or t["taskType"] != "DEPENDENT":
            continue
        items, skipped = [], 0
        for it in spec_by[t["name"]].get("dependItems") or []:
            hit = tindex.get(it.get("dependTask"))
            if not hit:
                skipped += 1
                continue
            items.append({"cycle": it.get("cycle", "day"),
                          "dateValue": it.get("dateValue", "today"),
                          "depTaskCode": hit[1], "projectCode": P,
                          "dependentType": it.get("dependentType", "DEPENDENT_ON_TASK"),
                          "definitionCode": hit[0], "parameterPassing": False})
        if not items:
            continue
        tp = t.setdefault("taskParams", {})
        dep = tp.setdefault("dependence", {})
        dtl = dep.get("dependTaskList") or [{"relation": "AND", "dependItemList": []}]
        dtl[0]["dependItemList"] = items
        dep["dependTaskList"] = dtl
        tp["dependence"] = dep
        changed = True
        if skipped:
            print(f"      {t['name']}: 跳过 {skipped} 条（目标作业不存在）")
    if not changed:
        return
    form = {"name": wfd["name"], "description": wfd.get("description") or "",
            "globalParams": wfd.get("globalParams") or "[]",
            "locations": json.dumps(locs), "timeout": wfd.get("timeout") or 0,
            "tenantCode": wfd.get("tenantCode") or D.TENANT,
            "taskRelationJson": json.dumps(rels, ensure_ascii=False),
            "taskDefinitionJson": json.dumps(cur, ensure_ascii=False),
            "executionType": wfd.get("executionType") or D.EXEC,
            "releaseState": "OFFLINE"}
    up = D.call("PUT", f"/projects/{P}/workflow-definition/{wf_code}", form=form)
    if up.get("code") != 0:
        print(f"      ✗ 依赖回填失败: {str(up)[:160]}")


def main():
    ap = argparse.ArgumentParser(description="DS 部署统一接口（JSON 契约 + 直接导入）")
    sub = ap.add_subparsers(dest="cmd", required=True)

    e = sub.add_parser("export", help="DS → JSON")
    e.add_argument("-o", "--out", default="", help="输出文件（默认打印到 stdout）")
    e.add_argument("--only", default="", help="只导这几个工作流，逗号分隔")
    e.add_argument("--match", default="", help="工作流名前缀，如 ods_")
    e.set_defaults(func=cmd_export)

    p = sub.add_parser("plan", help="本地（脚本 + lineage）→ JSON 计划")
    p.add_argument("-o", "--out", required=True)
    p.add_argument("--only", default="", help="只规划这几张表，逗号分隔")
    p.add_argument("--subject", default="", help="只规划某个主题，如 DWD_PROD")
    p.add_argument("--col-w", type=int, default=500,
                   help="dep→作业间距（★ 仅 DWD：2026-10-07 第三轮定到 500 = 缩减前原始值，"
                        "对间 PAIR_W 自动 = 2*500+120 = 1120 ⇒ 分隔 620。ODS 为 416，别混）。"
                        "★ 必须 > UI 节点宽（**当前 350**；DWD 现 500 ⇒ 间隙 150px）。"
                        "★★ 此值会写进 plan 的 JSON 再 import 回 DS，默认必须与线上一致，"
                        "否则一次裸跑就会把 500 拉回 444/333")
    p.set_defaults(func=cmd_plan)

    i = sub.add_parser("import", help="JSON → DS（幂等 upsert）")
    i.add_argument("-i", "--input", required=True)
    i.add_argument("--dry-run", action="store_true")
    i.set_defaults(func=cmd_import)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
