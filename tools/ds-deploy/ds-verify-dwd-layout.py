#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""回读一个 DS 工作流，**独立复算**它的布局质量与归属正确性。

为什么要有这个工具
------------------
`ds-deploy-dwd-workflow.py` 自己打印的「交叉 0 条」是**它自己算的**；
DS 存进去的坐标会不会被 UI 改、有没有漏边，只有**回读**才知道。
本工具从 DS 拉回 `locations` + `taskRelationJson`，用**同一套线段相交判定**再算一遍。

校验四项
--------
1. **归属**：工作流里的表任务是否都属于该主题（如全为 `DWD_PROD_` 前缀）
2. **依赖控件**：每个表作业是否都挂了一个 `dep_<表>` 控件（1:1）
3. **交叉数**：真实坐标下的线段相交数（应 = 0）
4. **排布**：逐行打印，人眼核对「每排 3 对」

用法
----
    python tools/ds-verify-dwd-layout.py --workflow DWD_PROD
    python tools/ds-verify-dwd-layout.py --workflow DWD_PROD --prefix DWD_PROD_
"""
import argparse
import importlib.util
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_client import dependence_of, task_definitions  # noqa: E402
from ds_config import ds_admin_password, ds_admin_user  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def _load(name):
    """按**文件路径**导入（文件名带连字符 ⇒ 不能 `import ds-deploy-...`）。"""
    spec = importlib.util.spec_from_file_location(name, os.path.join(HERE, name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

DS = "http://localhost:12345/dolphinscheduler"
USER = ds_admin_user()
PWD = ds_admin_password()
SID = None


def _raw(method, path, params=None, form=None):
    url = DS + path + ("?" + urllib.parse.urlencode(params) if params else "")
    h = {"Accept": "application/json"}
    if SID:
        h["Cookie"] = "sessionId=" + SID
    data = None
    if form is not None:
        data = urllib.parse.urlencode(form, doseq=True).encode()
        h["Content-Type"] = "application/x-www-form-urlencoded"
    with urllib.request.urlopen(urllib.request.Request(url, data=data, headers=h,
                                                       method=method), timeout=120) as r:
        b = r.read().decode("utf-8", "replace")
        return json.loads(b) if b else {}


def raw(method, path, params=None, form=None, _retry=True):
    """★ 401（会话被别的 admin 登录顶掉）自动重登一次再重试。

    `--all-dwd` 要连续拉 11 个工作流的详情，中途被顶掉一次就全盘失败 ⇒ 必须有这一层。
    """
    try:
        return _raw(method, path, params, form)
    except urllib.error.HTTPError as e:
        if e.code == 401 and _retry:
            relogin()
            return _raw(method, path, params, form)
        raise


def relogin():
    global SID
    r = _raw("POST", "/login", form={"userName": USER, "userPassword": PWD})
    if r.get("code") != 0:
        sys.exit("登录失败")
    SID = r["data"]["sessionId"]


def total_list(res):
    d = res.get("data")
    return d.get("totalList") if isinstance(d, dict) else (d or [])


def cross(s, t):
    """两线段真交叉（共用端点不算）。s/t 都是 (x1, y1, x2, y2)。"""
    def cr(ax, ay, bx, by, cx, cy):
        return (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)
    x1, y1, x2, y2 = s
    x3, y3, x4, y4 = t
    d1 = cr(x3, y3, x4, y4, x1, y1)
    d2 = cr(x3, y3, x4, y4, x2, y2)
    d3 = cr(x1, y1, x2, y2, x3, y3)
    d4 = cr(x1, y1, x2, y2, x4, y4)
    return d1 * d2 < 0 and d3 * d4 < 0


def cleanup_probes(pcode):
    """删掉遗留的 `probe_*` 探针工作流。

    ★ 探针跑失败/被 Ctrl-C 打断时不会自清，就会一直挂在 UI 里当垃圾，
    而且它们大多是 OFFLINE ⇒ 会干扰「非 ONLINE 的工作流」这类巡检判据。
    """
    tl = total_list(raw("GET", f"/projects/{pcode}/workflow-definition",
                        params={"pageNo": 1, "pageSize": 500}))
    pr = [x for x in tl if x["name"].startswith("probe_")]
    if not pr:
        print("没有 probe_* 残留 ✓")
        return 0
    print(f"待清理探针 {len(pr)} 个: {[x['name'] for x in pr]}")
    D = _load("ds-deploy-dwd-workflow")
    rc = 0
    for x in pr:
        raw("POST", f"/projects/{pcode}/workflow-definition/{x['code']}/release",
            form={"releaseState": "OFFLINE"})
        # ★ 探针的 DEPENDENT 节点 `definitionCode` 指向**它自己** ⇒ 同样删不掉
        D.SID = SID
        n = D.neutralize_selfdeps(pcode, x["code"])
        if n:
            print(f"      中和 {x['name']} 的 {n} 条自引用依赖")
        r = raw("DELETE", f"/projects/{pcode}/workflow-definition/{x['code']}")
        ok = r.get("code") == 0
        rc |= 0 if ok else 1
        print(f"   {x['name']}: {'已删' if ok else str(r)[:200]}")
    left = [x["name"] for x in total_list(
        raw("GET", f"/projects/{pcode}/workflow-definition",
            params={"pageNo": 1, "pageSize": 500})) if x["name"].startswith("probe_")]
    print(f"剩余探针: {left or '无'}")
    return rc


def j(x):
    """DS 详情接口里 `locations` / `taskDefinitionList` / `workflowTaskRelationList`
    有时是 list、**有时是 JSON 字符串** ⇒ 统一解析。"""
    return json.loads(x) if isinstance(x, str) else (x or [])


def summary(pcode):
    """汇总全部 DWD_* 工作流：证明「依赖都进 dep 了、画线降到最少」。"""
    tl = total_list(raw("GET", f"/projects/{pcode}/workflow-definition",
                        params={"pageNo": 1, "pageSize": 500}))
    dwd = sorted([x for x in tl
                  if x["name"].startswith(("DWD_", "MASTER_"))], key=lambda z: z["name"])
    print(f"DWD_*/MASTER_* 工作流 {len(dwd)} 个（项目内共 {len(tl)} 个工作流）\n")
    print(f"{'工作流':12s} {'状态':8s} {'表':>4s} {'dep':>5s} {'画线':>5s} "
          f"{'dep内·作业级':>14s} {'dep内·工作流级':>14s}")
    t_s = t_tbl = t_dep = t_draw = t_same = t_cross = 0
    for w in dwd:
        g = raw("GET", f"/projects/{pcode}/workflow-definition/{w['code']}")["data"]
        tds = task_definitions(g)
        rels = j(g["workflowTaskRelationList"])
        tbl = [t for t in tds if t["taskType"] == "SHELL"]
        deps = [t for t in tds if t["taskType"] == "DEPENDENT"]
        same = cross = 0
        for t in deps:
            # ★ 2026-10-22：改用共用的 dependence_of（防御性取值）——
            #   原为 t["taskParams"]["dependence"]["dependTaskList"] 三层裸取键，
            #   任务缺 dependence 时 KeyError（DS 结构变化 / 无依赖的 DEPENDENT）。
            for grp in dependence_of(t):
                for i in grp["dependItemList"]:
                    if i["dependentType"] == "DEPENDENT_ON_TASK":
                        same += 1
                    else:
                        cross += 1
        drawn = len([r for r in rels if r["preTaskCode"] != 0])
        t_tbl += len(tbl)
        t_dep += len(deps)
        t_draw += drawn
        t_same += same
        t_cross += cross
        if w.get("releaseState") == "ONLINE":
            t_s += 1
        print(f"{w['name']:12s} {w.get('releaseState',''):8s} {len(tbl):4d} {len(deps):5d} "
              f"{drawn:5d} {same:14d} {cross:14d}")
    print(f"\n合计：表任务 {t_tbl}，依赖节点 {t_dep}，"
          f"**画出来的连线只有 {t_draw} 条**（全部是 dep→作业）")
    print(f"      dep 节点内承载：作业级(TASK) {t_same} 条 + 工作流级(WORKFLOW) {t_cross} 条")
    print(f"ONLINE {t_s}/{len(dwd)}")
    bad = [x["name"] for x in tl if x.get("releaseState") != "ONLINE"]
    print("非 ONLINE 的工作流:", bad or "无")
    return 0 if t_s == len(dwd) else 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--workflow", default="")
    ap.add_argument("--prefix", default="", help="成员表应有的前缀（默认 = 工作流名 + _）")
    ap.add_argument("--strict-1to1", action="store_true",
                    help="把「缺 depend 控件的表」也算失败（默认只提示）")
    ap.add_argument("--all-dwd", action="store_true",
                    help="汇总全部 DWD_* 工作流（表数 / dep 节点 / 画的线 / dep 内的依赖条数）")
    ap.add_argument("--cleanup-probes", action="store_true",
                    help="删掉遗留的 `probe_*` 探针工作流（ds-probe-selfdependent.py 的残留）")
    args = ap.parse_args()
    prefix = args.prefix or (args.workflow + "_")

    relogin()

    projs = raw("GET", "/projects/list", params={"pageSize": 100, "pageNo": 1}).get("data")
    projs = projs if isinstance(projs, list) else (projs or {}).get("totalList", [])
    pcode = next((p["code"] for p in projs if p["name"] == "dw"), None)
    if not pcode:
        sys.exit("项目 dw 不存在")

    if args.cleanup_probes:
        return cleanup_probes(pcode)
    if args.all_dwd:
        return summary(pcode)
    if not args.workflow:
        sys.exit("要传 --workflow <名>，或 --all-dwd 看全部 DWD_* 的汇总")

    w = next((x for x in total_list(raw("GET", f"/projects/{pcode}/workflow-definition",
                                        params={"pageNo": 1, "pageSize": 500,
                                                "searchVal": args.workflow}))
              if x["name"] == args.workflow), None)
    if not w:
        sys.exit(f"工作流 {args.workflow} 不存在")
    print(f"{args.workflow}  code={w['code']}  releaseState={w.get('releaseState')}")

    # ★ 详情接口的返回是**三段式**：{workflowDefinition, taskDefinitionList,
    #   workflowTaskRelationList}，不是扁平的 {locations, taskRelationJson}。
    g = raw("GET", f"/projects/{pcode}/workflow-definition/{w['code']}")["data"]
    wd = g["workflowDefinition"]
    locs = {int(l["taskCode"]): (l["x"], l["y"]) for l in j(wd["locations"])}
    rel = j(g["workflowTaskRelationList"])
    tasks = task_definitions(g)
    name = {t["code"]: t["name"] for t in tasks}
    names = set(name.values())

    tbl = sorted(n for n in names if not n.startswith("dep_"))
    deps = sorted(n for n in names if n.startswith("dep_"))
    print(f"表任务 {len(tbl)} 个，依赖控件 {len(deps)} 个")

    bad = [n for n in tbl if not n.startswith(prefix)]
    print(f"[1] 归属（应为 {prefix}*）：{'✓ 全部符合' if not bad else '✗ 混入 ' + str(bad)}")
    miss = [n for n in tbl if f"dep_{n}" not in names]
    # ★ 缺控件**未必是 bug**：剔除映射表/手工表后，有的表确实「什么都不用等」
    #   （它只等同工作流的连线）⇒ 空的 `dependItemList` 在 DS 里行为未定义，不挂才是对的。
    print(f"[2] 每个作业一个 depend 控件：{'✓ 1:1' if not miss else str(miss)}")
    if miss:
        print("    ↳ 上表**故意不挂**控件（依赖集为空），只受同工作流连线约束"
              + ("" if not args.strict_1to1 else "　★ --strict-1to1 ⇒ 视为失败"))

    segs = [(locs[r["preTaskCode"]][0], locs[r["preTaskCode"]][1],
             locs[r["postTaskCode"]][0], locs[r["postTaskCode"]][1])
            for r in rel
            if r["preTaskCode"] != 0
            and r["preTaskCode"] in locs and r["postTaskCode"] in locs]
    n = sum(1 for i in range(len(segs)) for j in range(i + 1, len(segs))
            if cross(segs[i], segs[j]))
    print(f"[3] 回读复算交叉数 = {n}（真实边 {len(segs)} 条）"
          + ("  ✓" if n == 0 else "  ✗ 还有交叉"))

    print("[4] 逐排排布：")
    rows = {}
    for c, (x, y) in locs.items():
        rows.setdefault(y, []).append((x, name[c]))
    for y in sorted(rows):
        line = "  ".join(nm for _, nm in sorted(rows[y]))
        print(f"    y={y:4d}  {line}")
    return 0 if (n == 0 and not bad and not miss) else 1


if __name__ == "__main__":
    sys.exit(main())
