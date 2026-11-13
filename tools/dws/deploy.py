# -*- coding: utf-8 -*-
"""DS 工作流操作：删除、重建、排版，以及 DWD 单独重建的前置检查。"""
from tools.dws import state as st
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
    pcode = dc.project_code(
        ds.call("GET", "/projects", params={"pageNo": 1, "pageSize": 100}), "dw")
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
        except Exception as e:
            print(f"  ⚠ 无法检查 DWS 工作流: {e}")
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


def cmd_delete(args):
    layers = layers_of(args)
    if not check_dwd_only_preflight(layers, block=args.apply) and args.apply:
        return 1
    # 顺序固定：先删 DWS 释放对 DWD 的引用，再删 DWD（反过来会被 DS 拒绝）
    for layer, label in (("DWS", "删除 DWS 工作流"), ("DWD", "删除 DWD 工作流")):
        if layer in layers:
            print(f"== {label} ==")
            rc = run([st.PY, st.DEPLOY_ALL, "--layer", layer, "--delete-only"]
                     + _dry(args))[0]
            if rc:
                print(f"  ✗ {label} 失败（rc={rc}）⇒ 中止（继续往下删会被 DS 拒绝）")
                return rc
    return 0


def cmd_deploy(args):
    layers = layers_of(args)
    if not check_dwd_only_preflight(layers, block=args.apply) and args.apply:
        return 1
    # 顺序固定：预删 DWS → 删/建 DWD → 建 DWS（跨层引用不会挡删）
    steps = []
    if "DWS" in layers:
        steps.append(("预删 DWS（释放对 DWD 的引用）", ["--layer", "DWS", "--delete-only"]))
    if "DWD" in layers:
        steps.append(("删除并重建 DWD", ["--layer", "DWD"]))
    if "DWS" in layers:
        steps.append(("创建 DWS", ["--layer", "DWS"]))
    # ★ 2026-10-26：原先是 `rc |= run(...)` 一路累计 ⇒ DWD 重建失败仍会继续「创建 DWS」，
    #   把「未部署」变成「DWS 引用缺失上游的半坏状态」。改为失败即中止。
    for label, extra in steps:
        print(f"== {label} ==")
        rc = run([st.PY, st.DEPLOY_ALL] + extra + _dry(args))[0]
        if rc:
            print(f"  ✗ {label} 失败（rc={rc}）⇒ 中止后续步骤，避免 DS 留下半成品")
            return rc
    if args.apply:
        for layer in ("DWD", "DWS"):
            if layer in layers:
                print(f"== 排版 {layer} ==")
                rc = run([st.PY, st.RELAYOUT, layer.lower(), "--apply"])[0]
                if rc:
                    print(f"  ✗ 排版 {layer} 失败（rc={rc}）")
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
