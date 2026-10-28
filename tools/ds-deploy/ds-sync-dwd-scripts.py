#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把本地重新生成的 DWD ETL 脚本同步到 DS 的 11 个主题工作流（改 task_params.rawScript）。

★ 为什么必须走 DS API：
    DS 的 SHELL 任务执行的是 **DB 里 task_params.rawScript 的内联脚本**，
    worker 容器里的 .sh 只是参考副本、**不参与执行**。

★ 与 ODS 版（ds-batch-update-ods-scripts.py）的区别：
    ODS 版默认 minimal（只删一行），因为本地产物与 DS 版本存在类型差异；
    **DWD 没有这个问题** —— 2026-10-05 实测 103 个任务的 rawScript 与本地 .sh
    哈希**全部一致**，说明部署时就是整体内联。故本工具直接整体覆盖。

★ 为什么按【工作流】分组而不是按任务逐个提交：
    DS 3.4.2 的 ONLINE 工作流不能直接编辑（报 50008）⇒ 每次提交都要
    OFFLINE → PUT 全量定义 → ONLINE。分组后每个工作流只上下线 1 次、PUT 1 次。

★ 比对用 sha1（先统一 CRLF），只提交真正变了的，避免无谓上下线。

用法：
    python tools/ds-sync-dwd-scripts.py                     # dry-run，只看差异
    python tools/ds-sync-dwd-scripts.py --apply             # 提交（自动备份旧脚本）
    python tools/ds-sync-dwd-scripts.py --apply --only DWD_PTY_DELR_INFO_PTD
    python tools/ds-sync-dwd-scripts.py --layer DWS         # DWS 层（默认 DWD）

★ 2026-10-23：新增 `--layer DWS`（DWS 也走同一套 OFFLINE→PUT→ONLINE 原地同步），
    并加**硬护栏**：任何脚本若仍含 `set inceptor.cross.join.enabled`（Hive 4.2 运行时
    不可改，实测报 `Cannot modify ... at runtime`，任务秒败），直接拒绝提交。

★ 2026-10-22 MASTER 口径更新（用户拍板，取代 10-15 旧口径）：`scripts/MASTER` 的
    本地实脚本（甲方脚本 + Hive4.2 方言修复）**直接推 DS**——主数据各作业在 DS 上
    跑真实脚本（10-15 旧口径"MASTER_EMPTY_TPL 占位、永不执行"已作废；实时 DS 里
    的占位已全被换成真实脚本，属既定事实）。本工具对 system==MASTER 的条目**不再
    跳过**，与其余系统一视同仁地同步。以后不再就"主数据推不推"提问。
"""
import argparse
import hashlib
import json
import os
import pathlib
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_text import normalize_newlines  # noqa: E402
from ds_client import DSClient, task_definitions  # noqa: E402

PCODE = 185582190746560
DOCKER = r"C:\Program Files\Docker\Docker\resources\bin\docker.exe"


def _p(p: str) -> str:
    """Windows 盘符路径 → WSL 挂载路径（历史写死 Windows 路径，统一成两边都能跑）。"""
    if os.name == "posix" and len(p) > 2 and p[1] == ":" and p[2] in "\\/":
        return "/mnt/" + p[0].lower() + p[2:].replace("\\", "/")
    return p


SCRIPTS = _p(r"C:\Users\84148\Desktop\trae\claude-code\scripts")
BACKUP_DIR = _p(r"D:\datax\backup\dwd-rawscript-before")
PREFIX = "DWD_"
# Hive 4.2 运行时**不允许**修改的参数（实测：`Cannot modify inceptor.cross.join.enabled
# at runtime. It is not in list of params that are allowed to be modified at runtime`，
# state=42000 ⇒ beeline 退出码 1，任务秒败）。脚本里残留 = 推上去必然失败 ⇒ 提交前硬拦。
RE_FORBIDDEN_SET = re.compile(r"^\s*set\s+inceptor\.cross\.join\.enabled\b", re.I | re.M)
# 与 ds-deploy-dwd-workflow.py::DEFAULT_EMPTY 保持一致（那边决定建占位、这边决定不推；
# 若某表过校验要转正，两处同步移除）：编译未过/用户跳过的 3 张（临时表族），DS 上是空脚本保依赖边。
# ★ 2026-10-16（J-30）：AST_BAL / VOU 修复并通过真编译 → 已移除转正（配真实脚本）。
# ★ 2026-10-27（J-36）：SALE_FEER / WARN_HIS / TAIL 三张本地脚本已通过逐条 EXPLAIN
#   （18 条 INSERT 全绿、TMP1/TMP2 实际存在），并已同步 DS 转正 ⇒ 占位集合清空。
#   执行期失败的表仍可由 `--empty-tables` 追加（逗号分隔，大小写不敏感）。
DEFAULT_EMPTY = set()
if os.name == "posix":
    DOCKER = os.environ.get("DOCKER", "docker")   # WSL 下用 PATH 里的 docker


def total_list(res):
    """回读接口的分页结果可能是 dict 也可能是 list"""
    d = res.get("data") if isinstance(res, dict) else res
    return d.get("totalList") if isinstance(d, dict) else (d or [])


def j(x):
    """DS 回读的字段有时是 JSON 字符串，统一反序列化"""
    if isinstance(x, str):
        try:
            return json.loads(x)
        except Exception:
            return []
    return x or []


def sha(s):
    return hashlib.sha1(s.replace("\r\n", "\n").encode("utf-8", "replace")).hexdigest()[:12]


def load_local(layer="DWD"):
    """扫各系统 <layer>/02_etl：{表名: (系统, 内容)}"""
    out = {}
    for sysn in sorted(os.listdir(SCRIPTS)):
        d = os.path.join(SCRIPTS, sysn, layer.lower(), "02_etl")
        if not os.path.isdir(d):
            continue
        for fn in sorted(os.listdir(d)):
            if not fn.endswith(".sh"):
                continue
            t = fn[:-3].upper()
            if t in out:
                print(f"  ⚠ 表名重复：{t} 同时存在于 {out[t][0]} 和 {sysn}，跳过后者")
                continue
            # ★ 2026-10-22：规范化行尾后再比对（DS 端 rawScript 恒为 LF）
            out[t] = (sysn, normalize_newlines(
                pathlib.Path(os.path.join(d, fn)).read_text(encoding="utf-8")))
    return out


def snapshot_online_schedules():
    """快照当前 ONLINE 的调度 id（改工作流会把调度级联下线，提交后要恢复）。"""
    try:
        r = subprocess.run(
            [DOCKER, "exec", "hive-metastore-db", "psql", "-U", "dolphinscheduler",
             "-d", "dolphinscheduler", "-tAc",
             "select id from t_ds_schedules where release_state=1"],
            capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=60)
        return {x.strip() for x in (r.stdout or "").splitlines() if x.strip()}
    except Exception as e:
        print(f"  ⚠ 快照调度失败（继续）：{e}")
        return set()


def set_schedule(sid, state):
    try:
        subprocess.run(
            [DOCKER, "exec", "hive-metastore-db", "psql", "-U", "dolphinscheduler",
             "-d", "dolphinscheduler", "-tAc",
             f"update t_ds_schedules set release_state={state} where id={sid}"],
            capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=60)
    except Exception as e:
        print(f"  ⚠ 恢复调度 {sid} 失败：{e}")


def main():
    global PREFIX
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="真正提交（不加 = dry-run）")
    ap.add_argument("--only", help="只处理指定表，逗号分隔")
    ap.add_argument("--layer", default="DWD", choices=["DWD", "DWS"],
                    help="同步哪一层（默认 DWD）")
    args = ap.parse_args()
    layer = args.layer.upper()
    PREFIX = layer + "_"
    empty_set = DEFAULT_EMPTY if layer == "DWD" else set()

    local = load_local(layer)
    only = {x.strip().upper() for x in args.only.split(",") if x.strip()} if args.only else None
    print(f"本地 {layer} 脚本: {len(local)} 个（{SCRIPTS}\\*\\{layer.lower()}\\02_etl）")
    if only:
        print(f"只处理: {sorted(only)}")

    ds = DSClient()
    tl = total_list(ds.call("GET", f"/projects/{PCODE}/workflow-definition",
                               params={"pageNo": 1, "pageSize": 500}))
    dwd = sorted([x for x in tl if x["name"].startswith(PREFIX)], key=lambda z: z["name"])
    print(f"DS 里 {PREFIX}* 工作流: {len(dwd)} 个\n")

    online_sched = snapshot_online_schedules() if args.apply else set()
    if args.apply:
        print(f"调度快照: ONLINE {len(online_sched)} 条 {sorted(online_sched)}\n")

    n_same = n_diff = n_skip = n_eskip = n_forbid = 0
    forbidden = []
    planned = []
    for w in dwd:
        g = ds.call("GET", f"/projects/{PCODE}/workflow-definition/{w['code']}")["data"]
        wf = g["workflowDefinition"]
        tds = task_definitions(g)
        rels = j(g["workflowTaskRelationList"])
        todo = []
        for t in tds:
            if t.get("taskType") != "SHELL":
                continue
            name = t["name"]
            old = (t.get("taskParams") or {}).get("rawScript") or ""
            if only and name not in only:
                continue
            if name not in local:
                n_skip += 1
                print(f"    ⚠ [{w['name']}] {name}: DS 有任务但本地无脚本，跳过")
                continue
            if name in empty_set:
                n_eskip += 1
                print(f"    ✗ [{w['name']}] {name}: DEFAULT_EMPTY 占位（实脚本未过校验，"
                      f"推了跑批必失败）不推")
                continue
            new = local[name][1]
            # ★ 2026-10-26：SHA 一致先判 —— 内容与 DS 完全相同 ⇒ 本次根本不会推送，
            #   不存在"把禁用 SET 推上去"的风险。此前顺序相反，导致 DS 上本来就带着
            #   该 SET、且能正常跑的任务（如 DWS_PROD_AST_INFO_PTD）也被记入 forbidden，
            #   把整批 return 2 拦死，实质是误伤。真正待推送且含 SET 的仍会被拦。
            if sha(old) == sha(new):
                n_same += 1
                continue
            if RE_FORBIDDEN_SET.search(new):
                n_forbid += 1
                print(f"    ⛔ [{w['name']}] {name}: 含运行时禁止修改的 "
                      f"`set inceptor.cross.join.enabled`（Hive 4.2 会报 "
                      f"Cannot modify ... at runtime）⇒ 拒绝提交，请先删掉该 SET")
                forbidden.append((w["name"], name, local[name][0]))
                continue
            todo.append((name, old, new))
        if todo:
            print(f"[{w['name']}] 待更新 {len(todo)} 个:")
            for name, old, new in todo:
                print(f"    - {name:<42} {len(old):>6} → {len(new):>6} chars "
                      f"({sha(old)} → {sha(new)}) [{local[name][0]}]")
            planned.append((w, wf, tds, rels, todo))
            n_diff += len(todo)

    print(f"\n一致 {n_same} 个，待更新 {n_diff} 个，DS 有本地无 {n_skip} 个，"
          f"DEFAULT_EMPTY 占位不推 {n_eskip} 个，禁用 SET 拦截 {n_forbid} 个")
    if forbidden:
        print("\n⛔ 以下脚本含运行时禁止的 SET，已全部拦截（本次不提交任何变更）：")
        for wfname, name, sysn in forbidden:
            print(f"   - [{wfname}] {name}  ({sysn})")
        print("   修法：删掉 `set inceptor.cross.join.enabled=...;` 整行后重跑。")
        return 2
    if not args.apply:
        print("[dry-run] 未提交。加 --apply 真正提交。")
        return 0
    if not planned:
        print("无需提交。")
        return 0

    os.makedirs(BACKUP_DIR, exist_ok=True)
    for w, wf, tds, rels, todo in planned:
        print(f"\n=== {w['name']} ===")
        for name, old, _ in todo:
            pathlib.Path(os.path.join(BACKUP_DIR, f"{name}.sh")).write_text(
                old, encoding="utf-8", newline="\n")
        print(f"  已备份旧脚本 → {BACKUP_DIR}")

        # ★ 2026-10-22 修 bug（评审 HIGH-7）：原实现 PUT 成功后**无条件**执行
        #   release ONLINE ⇒ 原本被人工置为 OFFLINE 的工作流（出于「先别跑」
        #   的意图）会被误上线，按定时或下游依赖意外触发。
        #   ⇒ 记录原始状态，只在原本 ONLINE 时才恢复 ONLINE。
        was_online = wf.get("releaseState") == "ONLINE"

        if was_online:
            off = ds.call("POST", f"/projects/{PCODE}/workflow-definition/{w['code']}/release",
                          form={"releaseState": "OFFLINE"})
            if off.get("code") != 0:
                print(f"  ❌ OFFLINE 失败: {str(off)[:300]}")
                continue
            print("  ① OFFLINE ✓")

        by_name = {t["name"]: t for t in tds}
        for name, _, new in todo:
            by_name[name]["taskParams"]["rawScript"] = new

        payload = {
            "name": wf.get("name"),
            "description": wf.get("description") or "",
            "globalParams": (wf.get("globalParamList") and
                             json.dumps(wf.get("globalParamList"), ensure_ascii=False) or
                             (wf.get("globalParams") or "[]")),
            "locations": wf.get("locations") or "[]",
            "timeout": wf.get("timeout") or 0,
            "tenantCode": wf.get("tenantCode") or "default",
            "taskRelationJson": json.dumps(rels, ensure_ascii=False),
            "taskDefinitionJson": json.dumps(tds, ensure_ascii=False),
            "executionType": wf.get("executionType") or "PARALLEL",
            "releaseState": "OFFLINE",
        }
        up = ds.call("PUT", f"/projects/{PCODE}/workflow-definition/{w['code']}", form=payload)
        if up.get("code") != 0:
            print(f"  ❌ PUT 失败: {str(up)[:400]}（工作流保持 OFFLINE，请人工检查）")
            continue
        print(f"  ② PUT ✓（{len(todo)} 个任务）")

        if was_online:
            on = ds.call("POST", f"/projects/{PCODE}/workflow-definition/{w['code']}/release",
                         form={"releaseState": "ONLINE"})
            print(f"  ③ ONLINE {'✓' if on.get('code') == 0 else '❌ ' + str(on)[:200]}")
        else:
            # 原本就是 OFFLINE ⇒ 保持 OFFLINE（不擅自上线）
            print("  ③ 保持 OFFLINE（原本即离线，不擅自上线）")

    for sid in sorted(online_sched):
        set_schedule(sid, 1)
    if online_sched:
        print(f"\n已恢复调度 ONLINE: {sorted(online_sched)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
