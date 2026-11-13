# -*- coding: utf-8 -*-
"""脚本 / DDL / DS 校验。"""
import json

from tools.dws import state as st
from tools.dws.args import layers_of
from tools.dws.ddl import (_load_ddl_verify, _print_ddl_diff, dws_table_sys_map,
                           parse_jf_ddl, verify_ddl_vs_jf)
from tools.dws.deploy import ds_workflows
from tools.dws.manifest import StaleDwsManifest, fail_stale
from tools.dws.process import run, shell_syntax
from tools.dws.scripts import _sh_repair


def cmd_verify_ddl(args):
    """仅校验本地 DDL 与甲方一致性（不落盘，不改文件）。"""
    layers = layers_of(args)
    strict = not getattr(args, "no_strict", False)
    rc = 0
    if "DWS" in layers:
        print("== DWS DDL 校验 ==")
        if not st.SRC_DWS_DDL.is_file():
            print(f"  ✗ {st.SRC_DWS_DDL} 不存在")
            return 1
        stmts = parse_jf_ddl(st.SRC_DWS_DDL)
        try:
            owner = dws_table_sys_map(
                allow_stale=getattr(args, "allow_stale_dws_manifest", False))
        except StaleDwsManifest as exc:
            return fail_stale(exc)
        have = {t: owner[t] for t in stmts if t in owner}
        verify = _load_ddl_verify()
        drift_count = 0
        for table, sysname in have.items():
            local_path = st.SCRIPTS / sysname / f"dws/ddl/{table}.sql"
            if not local_path.is_file():
                print(f"  ⚠ {table} ({sysname}): 本地文件不存在")
                drift_count += 1
                continue
            jf_text = stmts[table] + ";"
            local_text = local_path.read_text(encoding="utf-8", errors="replace")
            diff = verify.diff_ddl(jf_text, local_text, "甲方", "本地")
            probs = verify.lint_statements(local_text)
            if probs:
                drift_count += 1
                print(f"  ✗ {table} ({sysname}) 语句边界: {probs[0]}")
            if not diff.empty():
                drift_count += 1
                print(f"  ✗ {table} ({sysname}) 差异: {diff.summary()}")
                _print_ddl_diff(diff, limit=3)
            elif not probs:
                print(f"  ✓ {table} ({sysname}) 一致")
        print(f"  校验完成：{len(have)} 张表，{drift_count} 张有差异（含语句边界）")
        if drift_count and strict:
            rc = 1
    if "DWD" in layers:
        print("== DWD DDL 校验 ==")
        n, drift = verify_ddl_vs_jf("DWD", st.SRC_DWD_DDL)
        if drift < 0:
            return 1
        print(f"  校验完成：{n} 张表，{drift} 张有差异")
        if drift and strict:
            rc = 1
    return rc


def _verify_dws_local(strict=False):
    """DWS 本地检查：bash -n 语法、拼接副本、脚本/依赖数量。"""
    rc = 0
    print("== DWS 本地 ==")
    total = 0
    skipped_all = 0
    for s in st.SYS:
        b = {p.name: p for p in (st.SCRIPTS / s / "dws/02_etl").glob("*.sh")}
        total += len(b)
        bad, skipped = [], 0
        for name, p in sorted(b.items()):
            r = shell_syntax(p)
            if r == "bad":
                bad.append(name)
            elif r == "skip":
                skipped += 1
        skipped_all += skipped
        tail = f" / 无法判定 {skipped}" if skipped else ""
        print(f"  {s}: scripts {len(b)} / 语法通过 {len(b) - len(bad) - skipped}{tail}")
        if bad:
            print("    ", bad[:8])
            rc = 1
        # 拼接副本（SQL 调用 >1）单独报：它可能语法上是「通」的，但会重复执行 SQL
        dup = [name for name, p in sorted(b.items())
               if _sh_repair().count_sql_calls(
                   p.read_bytes().decode("utf-8", "replace")) > 1]
        if dup:
            print(f"    ⚠ 拼接副本（SQL 调用 >1）→ 跑 repair 子命令: {dup}")
            rc = 1
    if skipped_all:
        print(f"  ⚠ {skipped_all}/{total} 个脚本的 bash -n 未能执行（环境安全策略拦截），"
              f"语法结果不可判定")
        # ★ 2026-10-29：默认仅告警（沿用旧行为）；--strict 下视为失败，
        #   避免「环境拦住 bash ⇒ 全部 skip ⇒ rc=0 假绿」。
        if strict:
            print("  ✗ --strict：存在无法判定的脚本，按失败处理")
            rc = 1
    print(f"  DWS 脚本合计 {total}")
    if total != st.DWS_EXPECT_SCRIPTS:
        rc = 1
    n_dep = len(list(st.DEPCFG_DWS.glob("*.dep.json")))
    print(f"  依赖配置 {n_dep} 份")
    if n_dep != st.DWS_EXPECT_DEPS:
        rc = 1
    return rc


def _check_dws_workflow(dc, dt, ds, pcode, w):
    """单个 DWS 工作流：SHELL 脚本一致性 + DEPENDENT 节点是否缺失。返回 0/1。"""
    g = ds.call("GET", f"/projects/{pcode}/workflow-definition/{w['code']}")
    tds = dc.task_definitions(g)
    shells = [t for t in tds if t.get("taskType") == "SHELL"]
    deps = [t for t in tds if t.get("taskType") == "DEPENDENT"]
    sysname = st.DWS_WF2SYS.get(w["name"])
    local = {p.stem: p for p in
             (st.SCRIPTS / (sysname or "") / "dws/02_etl").glob("*.sh")}
    bad = []
    for t in shells:
        tp = t.get("taskParams") or {}
        if isinstance(tp, str):
            tp = json.loads(tp)
        p = local.get(t["name"])
        if not p or dt.normalize_newlines(tp.get("rawScript") or "").strip() != \
                dt.normalize_newlines(p.read_text(encoding="utf-8")).strip():
            bad.append(t["name"])
    print(f"  {w['name']}: {w.get('releaseState')} SHELL {len(shells)} DEP {len(deps)} "
          f"脚本不一致 {len(bad)}")
    depmap = {t["name"]: t for t in deps}
    miss_dep = []
    for t in shells:
        cfgp = st.DEPCFG_DWS / f"{t['name']}.dep.json"
        if not cfgp.is_file():
            continue
        c = json.loads(cfgp.read_text(encoding="utf-8"))
        expected = bool(c.get("same_workflow_predecessors") or
                        c.get("cross_workflow") or c.get("mapping_deps"))
        node = depmap.get("dep_" + t["name"])
        if expected and not node:
            miss_dep.append(t["name"])
            continue
        if not node:
            continue
        tp = node.get("taskParams") or {}
        if isinstance(tp, str):
            tp = json.loads(tp)
        n = sum(len(g.get("dependItemList", []))
                for g in (tp.get("dependence") or {}).get("dependTaskList", []))
        if expected and n == 0:
            miss_dep.append(t["name"])
    print(f"       依赖节点缺失/空: {len(miss_dep)}")
    if miss_dep:
        print("       ", miss_dep[:8])
    if w.get("releaseState") != "ONLINE" or bad or miss_dep:
        return 1
    return 0


def _verify_dws_ds():
    """DWS 回读 DS：工作流数、rawScript 一致性、依赖节点是否缺失。"""
    print("== DWS DS ==")
    try:
        ds, pcode, wfs = ds_workflows(("DWS_",))
    except (OSError, ValueError, RuntimeError, KeyError, TypeError) as e:
        print(f"  ⚠ DS 连接失败（{type(e).__name__}）: {e}")
        return 1
    print(f"  DWS 工作流 {len(wfs)} 个: {sorted(w['name'] for w in wfs)}")
    rc = 0 if len(wfs) == st.DWS_EXPECT_WORKFLOWS else 1
    dc, dt = st.ds_deploy()
    for w in wfs:
        rc |= _check_dws_workflow(dc, dt, ds, pcode, w)
    return rc


def verify_dws(use_ds, strict=False):
    """DWS 校验：本地 + （可选）DS 回读。

    ★ 2026-11-13：拆成 `_verify_dws_local` / `_verify_dws_ds`（原函数 101 行）。
    """
    rc = _verify_dws_local(strict=strict)
    if use_ds:
        rc |= _verify_dws_ds()
    return rc


def cmd_verify(args):
    layers = layers_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD 校验 ==")
        cmd = [st.PY, st.DWD_PIPE, "verify"] + (["--ds"] if args.ds else [])
        rc |= run(cmd)[0]
    if "DWS" in layers:
        rc |= verify_dws(args.ds, strict=getattr(args, "strict", False))
    return rc
