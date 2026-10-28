#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把本地 ODS 抽数脚本同步进 DS（**只改 `taskParams.rawScript`，不动工作流结构**）—— 二合一。

并入自（原文件已删，2026-10-11）：
  `ds-batch-update-ods-scripts.py`  → `--mode minimal|full` + `--auto` + 调度快照/恢复
  `ds-sync-ods-scripts-batch.py`    → 全 `ods_*` 扫描 + `--sys` + `--only-changed-with`

两种模式（★ 默认 minimal，安全选择）
------------------------------------
  minimal（默认）  基于【DS 当前 rawScript】删掉 `source ${source_path}` 那一行，其余原样保留。
  full             用【本地重新生成的脚本】整体覆盖 rawScript。

为什么必须走 API 改 rawScript
-----------------------------
  DS 的 SHELL 任务执行的是 **DB 里 `task_params.rawScript` 内联脚本**；
  worker 容器 `/home/dolphinscheduler/*.sh` 只是参考副本、**不参与执行**。

用法
----
    python ds-sync-ods-scripts.py                       # 干跑（minimal，扫全部 ods_*）
    python ds-sync-ods-scripts.py --apply               # 提交（保持 OFFLINE）
    python ds-sync-ods-scripts.py --sys O32 --apply
    python ds-sync-ods-scripts.py --mode full --dir <目录> --apply
    python ds-sync-ods-scripts.py --only ODS_HSFA_TFUNDINFO_PFD --auto --apply
    python ds-sync-ods-scripts.py --only-changed-with scripts.bak --apply
    python ds-sync-ods-scripts.py --apply --online      # 提交后恢复原上线状态 + 调度

硬约束（都是踩出来的）
----------------------
- ★ 只动 `taskParams.rawScript`，其余字段原样回填 —— 否则破坏依赖/布局/全局参数。
- ★ 任务名去 `_PFD/_PTD` 基名匹配时**必须保留后缀**，否则 OA/OFFW 同名不同后缀会互相覆盖。
- ★ 同一用户只 1 个会话 ⇒ 串行执行，不并发。
- ★ 改定义会**级联把定时调度置 OFFLINE**；默认建完**保持 OFFLINE**（2026-10-08 用户裁决：全部离线）；
  要恢复原状态用 `--online`（会快照并逐条恢复调度）。
- ★ 提交前先核 `ds-check-running.py`，有跑批就别动。
"""
import argparse
import glob
import json
import os
import pathlib
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from ds_client import DSClient  # noqa: E402
from ds_config import ds_admin_password, ds_admin_user, pg_conn  # noqa: E402
from ds_text import normalize_newlines  # noqa: E402

DOCKER = "docker"   # WSL 环境直接调 Linux docker CLI（原 r'C:\Program Files\...\docker.exe' 仅 Windows 可用）
REPO = os.environ.get("DW_REPO", os.path.dirname(os.path.dirname(HERE)))
PROJECT = os.environ.get("DW_DS_PROJECT", "dw")
BACKUP_DIR = "/mnt/d/datax/backup/ods-sync/rawscript-before"
SKIP_FILES = {"deploy-to-worker.sh"}
SRC_LINE = "source ${source_path}"


# ============================ 本地脚本 ============================ #
def read_text(p):
    """读本地脚本并**统一行尾为 LF**。

    ★ 2026-10-22：DS 上的 rawScript 是经 ds_text.read_script 规范化过的（LF），
      而本地 .sh 可能是 CRLF（Windows 源 / git autocrlf）。若此处不规范化，
      比对永远不等 ⇒ 每次都判定「需推送」，产生无意义的反复上线/下线。
    """
    with open(p, "rb") as f:
        return normalize_newlines(f.read().decode("utf-8"))


def collect_local(dir_=None, sys_filter=None):
    """任务名（文件名去 .sh）→ 本地脚本路径。含 _PFD/_PTD 后缀。"""
    roots = [dir_] if dir_ else glob.glob(os.path.join(REPO, "scripts", "*", "ods", "etl_sh"))
    out = {}
    for r in roots:
        # scripts/<SYS>/ods/etl_sh → SYS
        sysname = os.path.basename(os.path.dirname(os.path.dirname(r)))
        if sys_filter and sysname.upper() != sys_filter.upper():
            continue
        for fn in sorted(os.listdir(r)):
            if not fn.endswith(".sh") or fn.startswith(".") or fn in SKIP_FILES:
                continue
            out[fn[:-3]] = os.path.join(r, fn)
    return out


def strip_source_line(text):
    """minimal 模式：删掉 `source ${source_path}` 那一行，其余原样。"""
    return "\n".join(ln for ln in text.split("\n") if ln.strip() != SRC_LINE)


# ============================ 调度快照 ============================ #
def snapshot_online_schedules():
    """读元库里当前 ONLINE 的调度 id 集合。

    ★★ 必须查库，不能用 API（`GET /schedules` 只返回 ONLINE 的）。
    ★★ 为什么需要：工作流的 release 会**级联把挂在其上的调度置 OFFLINE**
       （2026-10-04 实测：update_time 精确等于提交那一刻，02:00 跑批静默漏跑）。
    """
    sql = "select id from t_ds_schedules where release_state = 1"
    try:
        p = subprocess.run([DOCKER, "exec", "hive-metastore-db", "psql", "-U", "dolphinscheduler",
                            "-d", "dolphinscheduler", "-tAc", sql],
                           capture_output=True, timeout=60)
    except Exception as e:
        print("⚠️ 读调度快照失败（不影响上传，但无法自动恢复调度）: %s" % str(e)[:120])
        return set()
    ids = set()
    for line in p.stdout.decode("utf-8", errors="replace").splitlines():
        line = line.strip()
        if line.isdigit():
            ids.add(int(line))
    return ids


def restore_schedules(ds, ids, pcode):
    if not ids:
        return
    print("\n④ 恢复调度状态（上传过程会级联把调度置 OFFLINE）: %s" % sorted(ids))
    for sid in sorted(ids):
        r = ds.call("POST", "/projects/%d/schedules/%d/online" % (pcode, sid))
        print("    schedule id=%d → ONLINE: %s"
              % (sid, "✅" if r.get("code") == 0 else "❌ " + str(r)[:200]))


# ============================ 元库反查 ============================ #
def resolve_workflows_by_tasks(task_names):
    """从元库反查：给定任务名属于哪些工作流 → [(名, code)]（JY/O32/WIND 的任务不在 hsfa 那 5 个里）。"""
    try:
        import psycopg2
    except ImportError:
        raise SystemExit("需要 psycopg2：pip install psycopg2-binary")
    names = sorted({x for x in task_names if x})
    if not names:
        return []
    c = psycopg2.connect(**pg_conn(), connect_timeout=8)
    c.autocommit = True
    cur = c.cursor()
    cur.execute(
        """
        select distinct w.name, w.code
        from t_ds_workflow_definition w
        join t_ds_workflow_task_relation r on r.workflow_definition_code = w.code
        join t_ds_task_definition t on t.code = r.post_task_code
        where t.name = any(%s)
        order by 1
        """, (names,))
    rows = cur.fetchall()
    cur.close()
    c.close()
    return [(n, int(code)) for n, code in rows]


def list_ods_workflows(ds, pcode):
    wfs, page = [], 1
    while True:
        rr = ds.call("GET", "/projects/%d/workflow-definition" % pcode,
                     params={"pageNo": page, "pageSize": 100})
        dd = rr.get("data") or {}
        tl = dd.get("totalList") or []
        for w in tl:
            if w["name"].startswith("ods_"):
                wfs.append(w)
        if len(tl) < 100:
            break
        page += 1
    return wfs


# ============================ 主流程 ============================ #
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["minimal", "full"], default="minimal",
                    help="minimal=只删 source 行（默认）；full=本地脚本整体覆盖")
    ap.add_argument("--dir", help="本地 ETL 脚本目录（仅 full；默认扫 scripts/*/ods/etl_sh）")
    ap.add_argument("--sys", help="只处理某系统（如 O32）")
    ap.add_argument("--only", help="只处理指定任务，逗号分隔")
    ap.add_argument("--only-changed-with", help="只提交与这个基线目录里同名脚本内容不同的任务")
    ap.add_argument("--auto", action="store_true",
                    help="用元库反查『这些任务属于哪些工作流』（任务不在 ods_* 里时用）")
    ap.add_argument("--online", action="store_true",
                    help="提交后恢复工作流原上线状态 + 调度（默认保持 OFFLINE）")
    ap.add_argument("--apply", action="store_true", help="真正提交（默认干跑）")
    args = ap.parse_args()

    only_names = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    local = collect_local(args.dir, args.sys)
    print("本地 ODS 抽数脚本: %d 个%s" % (len(local), ("（系统 %s）" % args.sys) if args.sys else ""))
    print("模式: %s%s" % (args.mode, "（只删 '%s' 这一行）" % SRC_LINE if args.mode == "minimal" else "（本地整体覆盖）"))

    if args.only_changed_with:
        changed = set()
        base_root = os.path.join(REPO, "scripts")
        for name, path in local.items():
            base = os.path.join(args.only_changed_with, os.path.relpath(path, base_root))
            if not os.path.exists(base):
                changed.add(name)          # 基线里没有 = 新增
                continue
            with open(base, "rb") as f:
                if f.read() != read_text(path).encode("utf-8"):
                    changed.add(name)
        print("与 %s 比对，内容有变化: %d 个" % (args.only_changed_with, len(changed)))
        local = {k: v for k, v in local.items() if k in changed}

    ds = DSClient(user=ds_admin_user(), password=ds_admin_password(),
                  allow_admin=True)
    r = ds.call("GET", "/projects/list", params={"searchVal": PROJECT, "pageSize": 50, "pageNo": 1})
    d = r.get("data")
    items = d.get("totalList") if isinstance(d, dict) else (d or [])
    pcode = next((it["code"] for it in items if it.get("name") == PROJECT), None)
    if not pcode:
        sys.exit("项目不存在: " + PROJECT)
    print("项目 %s code=%s\n" % (PROJECT, pcode))

    # 目标工作流
    if args.auto:
        wf_list = resolve_workflows_by_tasks(only_names or set(local.keys()))
        print("--auto：从元库反查到 %d 个工作流 %s" % (len(wf_list), [w[0] for w in wf_list]))
        wf_list = [{"name": n, "code": c} for n, c in wf_list]
    else:
        wf_list = list_ods_workflows(ds, pcode)
        if only_names:
            # --only 但不 --auto：仍扫全部 ods_*，靠任务名过滤
            pass
    print("目标工作流: %d 个" % len(wf_list))

    online_sched = snapshot_online_schedules() if (args.apply and args.online) else set()
    if args.apply and args.online:
        print("调度快照: 上线中 %d 条 %s" % (len(online_sched), sorted(online_sched)))

    total_changed = total_same = total_missing = 0
    seen_tasks = set()
    for w in sorted(wf_list, key=lambda x: x["name"]):
        det = ds.call("GET", "/projects/%d/workflow-definition/%d" % (pcode, w["code"]))
        # ★★ GET 单个工作流的返回是【嵌套】的：data = {workflowDefinition, taskDefinitionList, workflowTaskRelationList}
        dd = det.get("data") or {}
        wf = dd.get("workflowDefinition") or {}
        tds = dd.get("taskDefinitionList") or []
        rels = dd.get("workflowTaskRelationList") or []

        todo = []
        for t in tds:
            if t.get("taskType") != "SHELL":
                continue
            name = t.get("name")
            old = (t.get("taskParams") or {}).get("rawScript") or ""
            if args.mode == "full":
                if name not in local:
                    total_missing += 1
                    continue
                seen_tasks.add(name)
                new = read_text(local[name])
                if old.replace("\r\n", "\n") == new.replace("\r\n", "\n"):
                    total_same += 1
                    continue
            else:
                if only_names and name not in only_names:
                    continue
                seen_tasks.add(name)
                if SRC_LINE not in [ln.strip() for ln in old.split("\n")]:
                    total_same += 1
                    continue
                new = strip_source_line(old)
                if old == new:
                    total_same += 1
                    continue
            todo.append((name, old, new))

        if not todo:
            continue
        print("  [%s] 待更新 %d 个" % (w["name"], len(todo)))
        total_changed += len(todo)

        if not args.apply:
            continue

        os.makedirs(BACKUP_DIR, exist_ok=True)
        for name, old, _ in todo:
            pathlib.Path(os.path.join(BACKUP_DIR, "%s.sh" % name)).write_text(old, encoding="utf-8", newline="\n")

        # ★ 先 OFFLINE（ONLINE 状态下 DS 拒绝编辑 ⇒ 50008）
        if wf.get("releaseState") == "ONLINE":
            off = ds.call("POST", "/projects/%d/workflow-definition/%d/release" % (pcode, w["code"]),
                          form={"releaseState": "OFFLINE"})
            if off.get("code") != 0:
                print("      → 置 OFFLINE 失败，跳过：%s" % json.dumps(off, ensure_ascii=False)[:160])
                continue

        by_name = {t.get("name"): t for t in tds}
        for name, _, new in todo:
            by_name[name].setdefault("taskParams", {})["rawScript"] = new

        payload = {
            "name": wf.get("name"),
            "description": wf.get("description") or "",
            "globalParams": (json.dumps(wf.get("globalParamList"), ensure_ascii=False)
                             if wf.get("globalParamList") else (wf.get("globalParams") or "[]")),
            "locations": wf.get("locations") or "[]",
            "timeout": wf.get("timeout") or 0,
            "tenantCode": wf.get("tenantCode") or "default",
            "taskRelationJson": json.dumps(_rels_payload(rels), ensure_ascii=False),
            "taskDefinitionJson": json.dumps(tds, ensure_ascii=False),
            "executionType": wf.get("executionType") or "PARALLEL",
            "releaseState": "OFFLINE",
        }
        up = ds.call("PUT", "/projects/%d/workflow-definition/%d" % (pcode, w["code"]), form=payload)
        ok = up.get("code") == 0
        print("      → %s" % ("OK" if ok else "FAIL " + json.dumps(up, ensure_ascii=False)[:200]))
        if not ok:
            continue
        if args.online:
            on = ds.call("POST", "/projects/%d/workflow-definition/%d/release" % (pcode, w["code"]),
                         form={"releaseState": "ONLINE"})
            print("      → ONLINE %s" % ("✓" if on.get("code") == 0 else "❌ " + str(on)[:160]))

    if args.mode == "full":
        missing = sorted(set(local) - seen_tasks)
        if missing:
            print("\n⚠️ full 模式下有 %d 个本地脚本未匹配到 DS 任务: %s" % (len(missing), missing[:10]))
        else:
            print("\n✅ 本地 %d 个脚本全部匹配到 DS 任务" % len(local))

    print("\n===== 汇总: 变更 %d / 内容相同 %d / DS 未找到 %d =====" % (total_changed, total_same, total_missing))
    if not args.apply:
        print("[dry-run] 未提交。加 --apply 真正写入。")
    elif args.online:
        restore_schedules(ds, online_sched, pcode)
    ds.close()


def _rels_payload(rels):
    """把 relation 列表规整成 DS PUT 需要的形状（去掉只读字段）。"""
    keep = ("name", "preTaskCode", "preTaskVersion", "postTaskCode",
            "postTaskVersion", "conditionType", "conditionParams")
    return [{k: r.get(k) for k in keep if k in r} for r in rels]


if __name__ == "__main__":
    main()
