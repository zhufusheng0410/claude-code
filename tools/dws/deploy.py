# -*- coding: utf-8 -*-
"""DS 工作流操作：删除、重建、排版，以及 DWD 单独重建的前置检查。"""
import datetime as dt
import json

from tools.dws import state as st
from tools.core.ds_snapshot import SNAPSHOT_SCHEMA, dependency_items
from tools.dws.args import _ap, _dry, layers_of
from tools.dws.process import run


def _ds_client():
    """惰性取 `ds_client` 模块（复用 `state.ds_deploy()` 的 sys.path 注入）。

    ★ 2026-10-26：原实现自己在函数里 `sys.path.insert` + `import ds_client`，
      与 `ds_deploy()` 重复。现在统一走后者，避免两处 sys.path 逻辑漂移。
    """
    return st.ds_deploy()[0]


def ds_workflows(prefixes):
    dc = _ds_client()
    ds = dc.get_client()
    pcode = dc.project_code_of(ds)
    wf = dc.lst_of(ds.call("GET", f"/projects/{pcode}/workflow-definition",
                           params={"pageNo": 1, "pageSize": 500}))
    return ds, pcode, [w for w in wf if str(w["name"]).startswith(prefixes)]


def dws_refs_into_dwd(ds, pcode, dwd_codes):
    """查 DWS_* 工作流的依赖项里有没有指向 DWD_*/MASTER_* 工作流的引用。

    ★ DWD 删除只会被「别的 DEPENDENT 引用着」挡住；DWS 存在本身并不挡删。
      旧逻辑是「有 DWS 就拒」，过于保守 ⇒ 改为**实测引用**。
    ★★ 引用落在 dependItemList[].**definitionCode**（= 被引用工作流的 code）；
       projectCode 是**项目** code（不能拿来比）。
    """
    dc = _ds_client()
    hits = []
    dws = [w for w in dc.lst_of(ds.call(
        "GET", f"/projects/{pcode}/workflow-definition",
        params={"pageNo": 1, "pageSize": 500})) if w["name"].startswith("DWS_")]
    for w in dws:
        g = ds.call("GET", f"/projects/{pcode}/workflow-definition/{w['code']}")
        for t in dc.task_definitions(g):
            for d in dc.dependence_of(t):
                for it in d.get("dependItemList") or []:
                    if it.get("definitionCode") in dwd_codes:
                        hits.append((w["name"], t.get("name"), it.get("definitionCode")))
    return hits


def check_dwd_only_preflight(layers, block=True):
    """DWD 单独重建的前置检查：DWS 侧若引用着 DWD 工作流，删 DWD 会被 DS 拒绝。

    ★★ 实测（2026-10-21）：DWS_HSFA/O32/ZTA 共 127 条依赖项引用了全部 10 个
       DWD_* 工作流（dependItemList[].definitionCode）⇒ **只重建 DWD 一定失败**，
       必须 `--layers DWD,DWS`（先删 DWS 释放引用 → 重建 DWD → 重建 DWS）。
       这里用**实测引用**给出精确原因，而不是笼统说「有 DWS 就挡」。
    ★ 2026-10-26：预检本身是只读的，原先只在 `--apply` 才跑 ⇒ dry-run 说「可以」、
      apply 才被拒。现在 dry-run 也跑，只降级为告警（block=False），不阻断。
    """
    mark = "✗" if block else "⚠"
    if "DWD" in layers and "DWS" not in layers:
        try:
            ds, pcode, dws = ds_workflows(("DWS_",))
        except (OSError, ValueError, RuntimeError, KeyError, TypeError) as e:
            # 连不上 / 会话坏 / 返回结构异常：预检降级为「不阻断」。
            # 不接编程错误（AttributeError/NameError）—— 那是本模块自己的 bug。
            print(f"  ⚠ 无法检查 DWS 工作流（{type(e).__name__}）: {e}")
            return True
        if dws:
            allwf = _ds_client().lst_of(ds.call(
                "GET", f"/projects/{pcode}/workflow-definition",
                params={"pageNo": 1, "pageSize": 500}))
            dwd_codes = {w["code"]: w["name"] for w in allwf
                         if w["name"].startswith(("DWD_", "MASTER_"))}
            hits = dws_refs_into_dwd(ds, pcode, set(dwd_codes))
            if hits:
                used = sorted({dwd_codes[h[2]] for h in hits if h[2] in dwd_codes})
                print(f"  {mark} DWS 的 {len(hits)} 条依赖项引用着 {len(used)} 个 DWD 工作流，"
                      f"删 DWD 会被 DS 拒绝：{used}")
                if block:
                    print("    改用 --layers DWD,DWS 一起删/建"
                          "（先删 DWS 释放引用 → 重建 DWD → 重建 DWS），"
                          "或先单独跑 --layers DWS --delete-only")
                else:
                    print("    （dry-run 仅提示；加 --apply 会在此处中止）")
                return False
            print(f"  ✓ DWS 存在 {len(dws)} 个，且无 DWS→DWD 依赖引用，不挡 DWD 删除/重建")
    return True


def _run_steps(steps, hint=""):
    """顺序跑子进程步骤；任一失败即返回其 rc（不继续，避免 DS 留半成品）。"""
    for label, cmd in steps:
        print(f"== {label} ==")
        rc = run(cmd)[0]
        if rc:
            print(f"  ✗ {label} 失败（rc={rc}）{hint}")
            return rc
    return 0


def _create_recovery_snapshot(layers):
    """在 apply 部署的首次删除前导出目标层工作流，失败时阻止破坏性步骤。"""
    prefixes = []
    if "DWD" in layers:
        prefixes.extend(("DWD_", "MASTER_"))
    if "DWS" in layers:
        prefixes.append("DWS_")
    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    path = st.REPO / "tools/.dx-tmp/ds-recovery" / f"deploy-{stamp}.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    rc, _ = run([st.PY, st.DEPLOY_API, "export", "--match",
                 ",".join(prefixes), "--out", path])
    if rc:
        print(f"✗ DS 恢复快照导出失败（rc={rc}），为保护现有工作流，取消部署")
        return None
    try:
        doc = json.loads(path.read_text(encoding="utf-8"))
        workflows = doc["workflows"]
        names = [wf["name"] for wf in workflows]
        if (doc.get("schema") != SNAPSHOT_SCHEMA
                or not isinstance(workflows, list)
                or len(names) != len(set(names))
                or any(not name.startswith(tuple(prefixes)) for name in names)):
            raise ValueError("快照结构或工作流范围无效")
        _, project, current = ds_workflows(tuple(prefixes))
        if doc.get("source", {}).get("projectCode") != project:
            raise ValueError("快照项目与部署目标项目不一致")
        if set(names) != {wf["name"] for wf in current}:
            raise ValueError("快照未覆盖部署目标的全部工作流")
        doc["workflows"] = _order_recovery_workflows(workflows)
        path.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n",
                        encoding="utf-8")
    except (OSError, UnicodeError, json.JSONDecodeError, KeyError,
            TypeError, ValueError, RuntimeError) as e:
        print(f"✗ DS 恢复快照校验失败：{e}；为保护现有工作流，取消部署")
        return None
    print(f"✓ DS 恢复快照已保存：{path}（{len(names)} 个现有工作流）")
    return path


def _order_recovery_workflows(workflows):
    """恢复导入按上游优先排序；循环依赖的剩余项按名称稳定排序。"""
    by_name = {wf["name"]: wf for wf in workflows}
    deps = {name: set() for name in by_name}
    for name, wf in by_name.items():
        for task in wf.get("tasks", []):
            for item in dependency_items(task):
                upstream = item.get("dependWorkflow")
                if upstream in by_name and upstream != name:
                    deps[name].add(upstream)
    remaining = {name: set(upstreams) for name, upstreams in deps.items()}
    ordered = []
    while remaining:
        ready = sorted(name for name, upstreams in remaining.items() if not upstreams)
        if not ready:
            ordered.extend(by_name[name] for name in sorted(remaining))
            break
        for name in ready:
            ordered.append(by_name[name])
            remaining.pop(name)
        for upstreams in remaining.values():
            upstreams.difference_update(ready)
    return ordered


def _report_recovery(snapshot):
    """部署失败后打印快照位置和人工恢复入口。"""
    print("\n部署未完成。恢复前请先确认 DS 实例已停止，并审阅快照内容：")
    print(f"  快照：{snapshot}")
    print(f"  预览：{st.PY} {st.DEPLOY_API} import --input {snapshot} --restore --dry-run")
    print(f"  导入：{st.PY} {st.DEPLOY_API} import --input {snapshot} --restore")
    print("  恢复按快照替换目标工作流的任务、关系和全局参数。")
    print("  上线状态与调度需按原运行状态核验后手工处理；请检查目标层是否有多余工作流。")


def cmd_delete(args):
    layers = layers_of(args)
    if not check_dwd_only_preflight(layers, block=args.apply) and args.apply:
        return 1
    # 顺序固定：先删 DWS 释放对 DWD 的引用，再删 DWD（反过来会被 DS 拒绝）
    steps = [(f"删除 {layer} 工作流",
              [st.PY, st.DEPLOY_ALL, "--layer", layer, "--delete-only"] + _dry(args))
             for layer in ("DWS", "DWD") if layer in layers]
    return _run_steps(steps, " ⇒ 中止（继续往下删会被 DS 拒绝）")


def cmd_deploy(args):
    layers = layers_of(args)
    if not check_dwd_only_preflight(layers, block=args.apply) and args.apply:
        return 1
    # 所有目标层均通过只读检查后，才能开始跨层删除。
    for layer in ("DWD", "DWS"):
        if layer in layers:
            check = "--check-only" if args.apply else "--dry-run"
            rc = run([st.PY, st.DEPLOY_ALL, "--layer", layer, check])[0]
            if rc:
                return rc
    snapshot = None
    if args.apply:
        snapshot = _create_recovery_snapshot(layers)
        if snapshot is None:
            return 1
    # 顺序固定：预删 DWS → 删/建 DWD → 建 DWS（跨层引用不会挡删）
    steps = []
    if "DWS" in layers:
        steps.append(("预删 DWS（释放对 DWD 的引用）",
                      [st.PY, st.DEPLOY_ALL, "--layer", "DWS", "--delete-only"] + _dry(args)))
    if "DWD" in layers:
        steps.append(("删除并重建 DWD",
                      [st.PY, st.DEPLOY_ALL, "--layer", "DWD"] + _dry(args)))
    if "DWS" in layers:
        steps.append(("创建 DWS",
                      [st.PY, st.DEPLOY_ALL, "--layer", "DWS"] + _dry(args)))
    rc = _run_steps(steps, " ⇒ 中止后续步骤，避免 DS 留下半成品")
    if rc:
        if snapshot:
            _report_recovery(snapshot)
        return rc
    if args.apply:
        for layer in ("DWD", "DWS"):
            if layer in layers:
                print(f"== 排版 {layer} ==")
                rc = run([st.PY, st.RELAYOUT, layer.lower(), "--apply"])[0]
                if rc:
                    print(f"  ✗ 排版 {layer} 失败（rc={rc}）")
                    if snapshot:
                        _report_recovery(snapshot)
                    return rc
    return 0


def cmd_layout(args):
    layers = layers_of(args)
    rc = 0
    for layer in ("DWD", "DWS"):
        if layer in layers:
            print(f"== 排版 {layer} ==")
            cmd = [st.PY, st.RELAYOUT, layer.lower()] + _ap(args)
            rc |= run(cmd)[0]
    return rc
