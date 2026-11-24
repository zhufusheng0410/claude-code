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
    import    JSON → DS        （幂等 upsert；`--restore` 按 v2 快照恢复；`--dry-run` 预览）

用法:
    python tools/ds-deploy-api.py export --match ods_ -o ods.json
    python tools/ds-deploy-api.py export --only DWD_PROD -o dwd_prod.json
    python tools/ds-deploy-api.py plan --subject DWD_PROD -o plan.json
    python tools/ds-deploy-api.py import -i plan.json --dry-run
    python tools/ds-deploy-api.py import -i plan.json
    python tools/ds-deploy-api.py import -i snapshot.json --restore --dry-run

plan 的 v1 结构（export 的 v2 快照另保留任务参数和依赖分组）
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
from copy import deepcopy
import datetime as dt
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_client import dependence_of, task_definitions  # noqa: E402
from ds_text import read_script  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from core.ds_snapshot import PLAN_SCHEMA, SNAPSHOT_SCHEMA, dependency_groups, dependency_items
from ds_load import load as _load_file  # noqa: E402


def load(mod, f):
    return _load_file(os.path.join(HERE, f), mod)


D = load("DWDDEPLOY", "ds-deploy-dwd-workflow.py")

SCHEMA = PLAN_SCHEMA
TASK_SETTINGS = (
    "description", "delayTime", "flag", "taskPriority", "workerGroup",
    "environmentCode", "failRetryTimes", "failRetryInterval", "timeoutFlag",
    "timeoutNotifyStrategy", "timeout", "resourceIds", "taskGroupId",
    "taskGroupPriority", "cpuQuota", "memoryMax", "taskExecuteType",
)

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
    if isinstance(x, str) and x:
        return json.loads(x)
    return x or []


def pcode():
    return D.resolve_project(D.call)


def _checked_call(method, path, **kwargs):
    response = D.call(method, path, **kwargs)
    if response.get("code") != 0:
        raise RuntimeError(f"{method} {path} 失败：{str(response)[:200]}")
    return response


def _workflow_index(project):
    """每次回读指定项目，以工作流名和任务名共同定位依赖。"""
    index = {}
    page = 1
    while True:
        result = _checked_call(
            "GET", f"/projects/{project}/workflow-definition",
            params={"pageNo": page, "pageSize": 100})
        data = result.get("data") or {}
        workflows = data.get("totalList", []) if isinstance(data, dict) else data
        for workflow in workflows:
            code = workflow["code"]
            detail = _checked_call(
                "GET", f"/projects/{project}/workflow-definition/{code}")["data"]
            index[workflow["name"]] = {
                "code": code,
                "tasks": {t["name"]: t["code"] for t in task_definitions(detail)},
            }
        if len(workflows) < 100:
            return index
        page += 1


def _dependency_target(item, index):
    workflow = item.get("dependWorkflow")
    task = item.get("dependTask")
    if item.get("dependentType") == "DEPENDENT_ON_WORKFLOW":
        if workflow in index:
            return index[workflow]["code"], 0
    elif workflow:
        if workflow in index and task in index[workflow]["tasks"]:
            return index[workflow]["code"], index[workflow]["tasks"][task]
    else:
        # 兼容旧契约缺少工作流名的项，但同名任务必须唯一。
        hits = [(wf["code"], wf["tasks"][task])
                for wf in index.values() if task in wf["tasks"]]
        if len(hits) == 1:
            return hits[0]
    raise ValueError(f"依赖目标无法唯一解析：{workflow or '?'} / {task or '?'}")


def _online_schedules(project, workflow_codes):
    """只保存本次更新工作流的在线调度，恢复时使用同一项目 API。"""
    schedules = set()
    page = 1
    while workflow_codes:
        data = _checked_call("GET", f"/projects/{project}/schedules",
                             params={"pageNo": page, "pageSize": 100}).get("data") or []
        rows = data.get("totalList", []) if isinstance(data, dict) else data
        schedules.update(row["id"] for row in rows
                         if row.get("workflowDefinitionCode") in workflow_codes
                         and row.get("releaseState") in ("ONLINE", 1))
        if not isinstance(data, dict) or len(rows) < 100:
            break
        page += 1
    return schedules


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
    prefixes = tuple(x.strip() for x in args.match.split(",") if x.strip())
    index = _workflow_index(P)
    wfs = [{"name": name, "code": wf["code"]} for name, wf in index.items()]
    wfs = [w for w in wfs
           if (not args.only or w["name"] in set(args.only.split(",")))
           and (not prefixes or w["name"].lower().startswith(
               tuple(x.lower() for x in prefixes)))]
    wfs.sort(key=lambda x: x["name"])

    # 全局索引：task_code -> (工作流名, 任务名)；wf_code -> 工作流名
    code2name = {(wf["code"], tc): name
                 for wf in index.values() for name, tc in wf["tasks"].items()}
    wfname = {wf["code"]: name for name, wf in index.items()}

    out_wfs = []
    for w in wfs:
        g = _checked_call("GET", f"/projects/{P}/workflow-definition/{w['code']}")["data"]
        tasks = task_definitions(g)
        rels = j(g["workflowTaskRelationList"])
        wfd = g["workflowDefinition"]
        locs = j(wfd.get("locations"))
        c2n = {t["code"]: t["name"] for t in tasks}

        t_out, loc_out = [], {}
        for t in tasks:
            tp = deepcopy(j(t.get("taskParams")) or {})
            spec = {key: t[key] for key in TASK_SETTINGS if key in t}
            spec.update(name=t["name"], taskType=t["taskType"], taskParams=tp)
            if t["taskType"] == "SHELL":
                spec["script"] = tp.pop("rawScript")
            elif t["taskType"] == "DEPENDENT":
                dep = j(tp.pop("dependence"))
                groups = j(dep["dependTaskList"])
                for group in groups:
                    group["dependItemList"] = j(group["dependItemList"])
                dep["dependTaskList"] = groups
                spec["dependence"] = dep
                for item in dependency_items(spec):
                    if item.pop("projectCode", P) != P:
                        raise ValueError(f"{w['name']}/{t['name']} 包含跨项目依赖，无法导出为项目内恢复快照")
                    workflow = item.pop("definitionCode")
                    task = item.pop("depTaskCode", 0)
                    item["dependWorkflow"] = wfname[workflow]
                    item["dependTask"] = code2name.get((workflow, task), "")
                    _dependency_target(item, index)
            t_out.append(spec)
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
                        "timeout": wfd.get("timeout") or 0,
                        "globalParams": j(wfd.get("globalParams") or "[]"),
                        "tasks": t_out, "relations": rel_out, "locations": loc_out})
        print(f"  ✓ 导出 {w['name']}（{len(tasks)} 任务）")

    out({"schema": SNAPSHOT_SCHEMA, "generated_at": now(), "project": D.PROJECT,
         "source": {"ds": D.DS, "projectCode": P, "command": "export"},
         "workflows": out_wfs}, args.out)


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
def _validate_restore_task(task):
    """在提交任何工作流前校验任务及依赖分组的输入结构。"""
    if (not isinstance(task, dict)
            or not isinstance(task.get("name"), str) or not task["name"].strip()
            or not isinstance(task.get("taskType"), str) or not task["taskType"].strip()):
        raise ValueError("恢复任务必须包含非空 name 和 taskType")
    if "taskParams" in task and not isinstance(task["taskParams"], dict):
        raise ValueError(f"{task['name']} 的 taskParams 必须为对象")
    if task["taskType"] == "SHELL" and not isinstance(task.get("script"), str):
        raise ValueError(f"{task['name']} 缺少字符串 script")
    if task["taskType"] != "DEPENDENT":
        return
    if "dependence" in task:
        dep = task["dependence"]
        if (not isinstance(dep, dict) or dep.get("relation") not in ("AND", "OR")
                or not isinstance(dep.get("dependTaskList"), list)):
            raise ValueError(f"{task['name']} 的 dependence 结构无效")
    for group in dependency_groups(task):
        if (not isinstance(group, dict) or group.get("relation") not in ("AND", "OR")
                or not isinstance(group.get("dependItemList"), list)
                or any(not isinstance(item, dict) for item in group["dependItemList"])):
            raise ValueError(f"{task['name']} 的依赖分组结构无效")


def _validate_restore(doc):
    """替换工作流成员前，确认输入是含完整任务和关系的恢复快照。"""
    if doc.get("schema") != SNAPSHOT_SCHEMA:
        raise ValueError("--restore 需要 v2 恢复快照")
    if not isinstance(doc.get("workflows"), list):
        raise ValueError("恢复快照缺少 workflows 列表")
    for wf in doc["workflows"]:
        if (not isinstance(wf, dict) or not isinstance(wf.get("name"), str)
                or not wf["name"].strip()):
            raise ValueError("恢复工作流必须包含非空 name")
    names = [wf["name"] for wf in doc["workflows"]]
    if len(names) != len(set(names)):
        raise ValueError("恢复快照包含重复工作流名")
    for wf in doc["workflows"]:
        if not all(isinstance(wf.get(key), list)
                   for key in ("tasks", "relations", "globalParams")):
            raise ValueError(f"{wf['name']} 缺少完整 tasks/relations/globalParams 列表")
        for task in wf["tasks"]:
            _validate_restore_task(task)
        tasks = [task["name"] for task in wf["tasks"]]
        if len(tasks) != len(set(tasks)):
            raise ValueError(f"{wf['name']} 包含重复任务名")
        for edge in wf["relations"]:
            if not isinstance(edge, list) or len(edge) != 2:
                raise ValueError(f"{wf['name']} 的关系必须为 [前驱, 后继]")
            pre, post = edge
            if post not in tasks or (pre is not None and pre not in tasks):
                raise ValueError(f"{wf['name']} 的关系引用了快照之外的任务：{pre} → {post}")
        locations = wf.get("locations", {})
        if not isinstance(locations, dict):
            raise ValueError(f"{wf['name']} 的 locations 必须为对象")
        for name, xy in locations.items():
            if (name not in tasks or not isinstance(xy, list) or len(xy) != 2
                    or any(type(value) not in (int, float) for value in xy)):
                raise ValueError(f"{wf['name']}/{name} 的坐标必须为 [x, y] 数值对")
        if "timeout" in wf and (type(wf["timeout"]) is not int or wf["timeout"] < 0):
            raise ValueError(f"{wf['name']} 的 timeout 必须为非负整数")


def _check_restore_references(project, index, prospective, targets):
    """移除任务前检查范围外工作流，避免留下悬空的跨流依赖。"""
    removed = {(wf["code"], code)
               for name, wf in index.items() if name in targets
               for task, code in wf["tasks"].items()
               if task not in prospective[name]["tasks"]}
    if not removed:
        return
    for name, wf in index.items():
        if name in targets:
            continue
        detail = _checked_call(
            "GET", f"/projects/{project}/workflow-definition/{wf['code']}")["data"]
        for task in task_definitions(detail):
            for group in dependence_of(task):
                for item in j(group.get("dependItemList")):
                    if (item.get("projectCode", project) == project
                            and (item.get("definitionCode"), item.get("depTaskCode")) in removed):
                        raise ValueError(f"{name}/{task['name']} 依赖待移除任务，请先处理范围外依赖")


def cmd_import(args):
    with open(args.input, encoding="utf-8") as source:
        doc = json.load(source)
    if not isinstance(doc, dict):
        raise ValueError("部署文件必须为 JSON 对象")
    if doc.get("schema") not in (PLAN_SCHEMA, SNAPSHOT_SCHEMA):
        sys.exit(f"不支持的部署文件版本：{doc.get('schema')}")
    restore = getattr(args, "restore", False)
    if restore:
        _validate_restore(doc)
    D.login()
    P = pcode()

    index = _workflow_index(P)
    existing = {name: wf["code"] for name, wf in index.items()}
    prospective = {name: {"code": wf["code"], "tasks": dict(wf["tasks"])}
                   for name, wf in index.items()}
    for wf in doc["workflows"]:
        target = prospective.setdefault(wf["name"], {"code": None, "tasks": {}})
        if restore:
            target["tasks"] = {}
        target["tasks"].update({t["name"]: None for t in wf["tasks"]})
    if restore:
        _check_restore_references(P, index, prospective, {wf["name"] for wf in doc["workflows"]})

    # ---- 预检：依赖指向的作业是否都能解析（导入前就把问题说清楚）
    miss = []
    for wf in doc["workflows"]:
        for t in wf["tasks"]:
            for it in dependency_items(t):
                try:
                    _dependency_target(it, prospective)
                except ValueError as exc:
                    miss.append(f"{wf['name']}/{t['name']} → {exc}")
    if miss:
        print(f"✗ 有 {len(miss)} 条依赖无法从目标项目或本次导入解析，取消导入：")
        for m in miss[:10]:
            print(f"    - {m}")
        if len(miss) > 10:
            print(f"    … 还有 {len(miss) - 10} 条")
        return 1

    if args.dry_run:
        for wf in doc["workflows"]:
            act = "更新" if wf["name"] in existing else "新建"
            print(f"  [{act}] {wf['name']}（{len(wf['tasks'])} 任务）")
            if restore and wf["name"] in existing:
                current = index[wf["name"]]
                removed = sorted(set(current["tasks"]) - set(prospective[wf["name"]]["tasks"]))
                print(f"    移除任务：{', '.join(removed) or '无'}")
                detail = _checked_call(
                    "GET", f"/projects/{P}/workflow-definition/{current['code']}")["data"]
                c2n = {code: name for name, code in current["tasks"].items()}
                wanted = {tuple(edge) for edge in wf["relations"]}
                for edge in j(detail["workflowTaskRelationList"]):
                    pair = (c2n.get(edge.get("preTaskCode")), c2n.get(edge["postTaskCode"]))
                    if pair not in wanted:
                        print(f"    移除依赖边：{pair[0] or '起点'} → {pair[1]}")
        print("\n(--dry-run，未提交)")
        return 0

    # ★ 两遍建图：第一遍建/改任务（依赖先留空）⇒ 所有作业 code 就位后再回填依赖。
    #   否则「依赖的作业还没建」会因拿不到 code 而只能留工作流级依赖。
    imported = []
    snap = _online_schedules(P, {existing[wf["name"]] for wf in doc["workflows"]
                                 if wf["name"] in existing})
    next_code = max([int(dt.datetime.now().timestamp() * 1000) % 10 ** 9]
                    + [code for wf in index.values() for code in wf["tasks"].values()]) + 1
    for wf in doc["workflows"]:
        name = wf["name"]
        wfd = {}
        if name in existing:
            code = existing[name]
            g = _checked_call("GET", f"/projects/{P}/workflow-definition/{code}")["data"]
            cur_tasks = task_definitions(g)
            cur_rels = j(g["workflowTaskRelationList"])
            wfd = g["workflowDefinition"]
            was_online = (wfd.get("releaseState") == "ONLINE")
            by_name = {t["name"]: t for t in cur_tasks}
            # ★★ 2026-10-15 实测坑：新任务**不能带 code=0** ——
            #   DS 的 PUT /workflow-definition 会**静默丢弃** code=0 的任务
            #   （API 返回 code=0「更新成功(2 任务)」，回读却只剩原来的 1 个任务）。
            #   ⇒ 新任务必须显式分配非零 code（与 ds-add-dwd-table「max+1」同一口径）。
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
            if restore:
                tasks, rels = merged, []
            else:
                keep = [t for t in cur_tasks if t["name"] not in {m["name"] for m in merged}]
                tasks, rels = keep + merged, cur_rels
        else:
            code, was_online = None, False
            # 同上：新建工作流时每个任务也必须有非零 code
            tasks = []
            for _s in wf["tasks"]:
                _c = int(_s.get("code") or next_code)
                next_code = max(next_code, _c) + 1
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
        except (ValueError, TypeError):
            old_loc = {}
        for t in tasks:
            if any(L["taskCode"] == t["code"] for L in locs):
                continue
            _xy = old_loc.get(t["code"])
            locs.append({"taskCode": t["code"],
                         "x": _xy[0] if _xy else D.X0,
                         "y": _xy[1] if _xy else D.Y0})

        # 恢复模式使用快照的完整参数列表；普通 upsert 保留历史空列表兜底行为。
        gp_raw = wf.get("globalParams")
        if restore or gp_raw:
            gp_json = json.dumps(gp_raw, ensure_ascii=False)
        elif code:                       # 更新：保留 DS 里的现值（绝不写 []）
            gp_json = wfd.get("globalParams") or "[]"
        elif name.startswith("DWD_"):    # 新建：DWD 默认参数
            gp_json = json.dumps(DWD_GLOBAL_PARAMS, ensure_ascii=False)
        else:                            # ODS 等：无参数可保留
            gp_json = "[]"

        form = {"name": name, "description": wf.get("description") or "",
                "globalParams": gp_json,
                "locations": json.dumps(locs), "timeout": wf.get("timeout", wfd.get("timeout") or 0),
                "tenantCode": wf.get("tenantCode") or D.TENANT,
                "taskRelationJson": json.dumps(rels, ensure_ascii=False),
                "taskDefinitionJson": json.dumps(tasks, ensure_ascii=False),
                "executionType": wf.get("executionType") or D.EXEC,
                "releaseState": "OFFLINE"}
        if code:
            if was_online:
                _checked_call("POST", f"/projects/{P}/workflow-definition/{code}/release",
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
            return 1
        imported.append((code, wf, was_online))
        print(f"  ✓ {verb} {name}（{len(tasks)} 任务）")

    # 所有定义就位后重新读取编号，全部依赖回填成功才恢复上线。
    index = _workflow_index(P)
    for code, wf, _ in imported:
        _backfill_deps(P, code, wf, index)
    # API 可能返回成功却遗漏任务，最终成员回读通过后才能恢复上线与调度。
    for code, wf, _ in imported:
        detail = _checked_call("GET", f"/projects/{P}/workflow-definition/{code}")["data"]
        actual = {t["name"] for t in task_definitions(detail)}
        expected = {t["name"] for t in wf["tasks"]}
        missing = expected - actual
        extra = actual - expected if restore else set()
        if missing or extra:
            raise ValueError(f"{wf['name']} 回读任务不一致，缺少 {sorted(missing)}，多出 {sorted(extra)}")
    for code, wf, was_online in imported:
        if was_online:
            _checked_call("POST", f"/projects/{P}/workflow-definition/{code}/release",
                          form={"releaseState": "ONLINE"})
    for sid in sorted(snap):
        _checked_call("POST", f"/projects/{P}/schedules/{sid}/online")
    return 0


def _task_from_spec(spec, code):
    """JSON 里的一个任务 spec → DS 的 task 结构"""
    if spec["taskType"] == "SHELL":
        t = D.build_task(code, spec["name"], spec.get("script") or "", "")
        if "taskParams" in spec:
            t["taskParams"] = dict(spec["taskParams"], rawScript=spec["script"])
    elif spec["taskType"] == "DEPENDENT":
        t = D.build_dep_task(code, spec["name"], [])   # 依赖第二遍回填
        if "taskParams" in spec:
            t["taskParams"] = dict(spec["taskParams"], dependence=t["taskParams"]["dependence"])
    else:
        t = D.build_task(code, spec["name"], "", "")
        t["taskType"] = spec["taskType"]
        t["taskParams"] = spec.get("taskParams") or {}
    t.update({key: spec[key] for key in TASK_SETTINGS if key in spec})
    return t


def _backfill_deps(P, wf_code, wf_spec, index):
    """第二遍：把 DEPENDENT 的 dependItems 从**名字**解析成 code 并 PUT 回去。"""
    need = {t["name"]: t for t in wf_spec["tasks"]
            if t["taskType"] == "DEPENDENT" and ("dependence" in t or t.get("dependItems"))}
    if not need:
        return
    g = _checked_call("GET", f"/projects/{P}/workflow-definition/{wf_code}")["data"]
    cur = task_definitions(g)
    rels = j(g["workflowTaskRelationList"])
    wfd = g["workflowDefinition"]
    locs = j(wfd.get("locations"))
    if not need.keys() <= {t["name"] for t in cur if t["taskType"] == "DEPENDENT"}:
        raise ValueError(f"{wf_spec['name']} 回读缺少待恢复的 DEPENDENT 任务")
    for t in cur:
        if t["name"] not in need or t["taskType"] != "DEPENDENT":
            continue
        spec = need[t["name"]]
        tp = j(t.get("taskParams")) or {}
        t["taskParams"] = tp
        dep = dict(spec.get("dependence", tp.get("dependence", {})))
        dep["dependTaskList"] = deepcopy(dependency_groups(spec))
        for group in dep["dependTaskList"]:
            for item in group["dependItemList"]:
                workflow, task = _dependency_target(item, index)
                item.pop("dependWorkflow", None)
                item.pop("dependTask", None)
                item.update(projectCode=P, definitionCode=workflow, depTaskCode=task)
                if "dependence" not in spec:
                    item.setdefault("cycle", "day")
                    item.setdefault("dateValue", "today")
                    item.setdefault("dependentType", "DEPENDENT_ON_TASK")
                    item.setdefault("parameterPassing", False)
        tp["dependence"] = dep
    form = {"name": wfd["name"], "description": wfd.get("description") or "",
            "globalParams": wfd.get("globalParams") or "[]",
            "locations": json.dumps(locs), "timeout": wfd.get("timeout") or 0,
            "tenantCode": wfd.get("tenantCode") or D.TENANT,
            "taskRelationJson": json.dumps(rels, ensure_ascii=False),
            "taskDefinitionJson": json.dumps(cur, ensure_ascii=False),
            "executionType": wfd.get("executionType") or D.EXEC,
            "releaseState": "OFFLINE"}
    _checked_call("PUT", f"/projects/{P}/workflow-definition/{wf_code}", form=form)


def main():
    ap = argparse.ArgumentParser(description="DS 部署统一接口（JSON 契约 + 直接导入）")
    sub = ap.add_subparsers(dest="cmd", required=True)

    e = sub.add_parser("export", help="DS → JSON")
    e.add_argument("-o", "--out", default="", help="输出文件（默认打印到 stdout）")
    e.add_argument("--only", default="", help="只导这几个工作流，逗号分隔")
    e.add_argument("--match", default="", help="工作流名前缀，多个用逗号分隔，如 DWD_,MASTER_")
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
    i.add_argument("--restore", action="store_true",
                   help="按 v2 快照替换目标工作流的任务、关系和全局参数；可配合 --dry-run 预览移除项")
    i.set_defaults(func=cmd_import)

    args = ap.parse_args()
    try:
        return args.func(args)
    except (OSError, ValueError, RuntimeError, KeyError, TypeError) as exc:
        print(f"✗ {args.cmd} 失败：{exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
