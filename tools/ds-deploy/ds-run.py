#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DS 触发 / 跑批统一入口（五合一）。

并入自（原文件已删，2026-10-11）：
  manual       ← ds-run-manual.py         工作流级手动触发（内存闸门 + 并发闸门）
  task         ← ds-run-task.py           单任务触发 + 跟踪（严格按 workflowInstanceId 过滤）
  ods-serial   ← ds-run-ods-serial.py     串行跑 ODS 抽数（按系统字母序）
  dwd-serial   ← ds-run-dwd-serial.py     串行跑 DWD 主题（按依赖拓扑序）
  rerun-failed ← ds-rerun-failed-tasks.py 补跑指定 / 捞出的 FAILURE 任务

用法
----
    python ds-run.py manual --name ods_jy_etl_01 --apply --wait
    python ds-run.py manual --status
    python ds-run.py task --task ODS_HSFA_TGDXW_PFD
    python ds-run.py ods-serial --apply --order hsfa,hszta,hsfta,o32
    python ds-run.py dwd-serial --apply --start-from DWD_PROD
    python ds-run.py rerun-failed --tasks A,B --dry-run

★★★ 为什么必须走这些脚本而不是 DS UI 点「运行」
    worker `physical-task-config.task-executor-thread-size=4` ⇒ 同时只能跑 4 个任务；
    ODS 是 DataX（吃 worker 线程，不吃 YARN）⇒ 线程池打满 ⇒ dispatchFailTimes=15
    ⇒ 发不出 ZK 心跳 ⇒ session expired ⇒ Worker 掉线（10-08 凌晨实测打断 209+81+4 个）。
    ⇒ 全部内置**内存闸门**（在容器内量 VM `MemAvailable`）+ **串行/并发闸门**，宁可拒绝。

★ 铁律
- ★★★ 手动触发要求工作流 **ONLINE**（OFFLINE 报 `50014`）⇒ 串行版会自动置 ONLINE。
- ★★★ 单节点触发唯一正确姿势：`start-workflow-instance` + `startNodeList=<taskCode 数字>` + `taskDependType=TASK_ONLY`。
- ★★★ **必须严格按 workflowInstanceId 过滤**同名任务实例，绝不能回退到列表首项（会把上次的实例当本次结果）。
- ★★★ 串行跑批用 `failureStrategy=CONTINUE`（`END` 会把未跑任务卡成 WAITING_THREAD ⇒ 假象式大面积失败）。
- ★ 同用户只 1 会话，别并发跑多个 ds-*.py。
"""
import argparse
import collections
import json
import os
import subprocess
import sys
import time
import urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from ds_client import DSClient  # noqa: E402
from ds_config import ds_service_user, ds_service_password, pg_conn  # noqa: E402

PROJECT_CODE = 185582190746560
PG = pg_conn()   # ★ 2026-10-22：口令从环境/凭据文件读，源码不含字面量
PROBE_CONTAINER = "dolphinscheduler-worker"
# ★ 2026-10-26：依赖配置已从 `D:\datax\tools` 迁入本目录（仓库内自包含）。
#   用相对 HERE 的路径，Windows / WSL 两种环境都自然正确。
DEPCFG = os.environ.get("DW_DEPCFG", os.path.join(HERE, "dep-config-proscript"))
ROOT = os.path.dirname(HERE)   # 仓库根（.dx-tmp 在那）

STATE = {
    0: "SUBMITTED", 1: "RUNNING", 2: "DELAY", 3: "FAILURE", 4: "SUCCESS",
    5: "READY_PAUSE", 6: "PAUSE", 7: "READY_STOP", 8: "STOP", 9: "KILL",
    10: "WAITING_THREAD", 11: "WAITING_DEPEND",
}
TASK_OK = {"SUCCESS", "FORCED_SUCCESS"}
TERMINAL = ("SUCCESS", "FAILURE", "STOP", "PAUSE", "CANCEL", "KILL", "NEED_FAULT_TOLERANCE")

WORKFLOWS = [
    ("ods_hsfa_etl_01", 185582312443840),
    ("ods_hsfa_etl_02", 185582314365888),
    ("ods_hsfa_etl_03", 185582315538368),
    ("ods_hsfa_etl_04", 185582316098496),
    ("ods_hsfa_etl_05", 185593198910400),
]
SYS_ORDER = ["hsfa", "hszta", "hsfta", "o32"]

# ★ 2026-10-24 用户拍板：DWD 工作流重启/跑批顺序（按工作流级依赖分层）。
#   同层可并行；跨层必须等上游完成。详见 AGENTS.md「DWD 工作流重启顺序与优先级」。
DWD_WORKFLOW_ORDER = [
    "DWD_CMM", "DWD_PTY", "DWD_SCR", "DWD_CHNL", "DWD_PROD",
    "DWD_ACCT", "DWD_AGMT", "DWD_AST", "DWD_EVT", "DWD_TRAN",
]
DWD_WORKFLOW_PRIORITY = {
    "DWD_CMM": "HIGHEST", "DWD_PTY": "HIGHEST", "DWD_SCR": "HIGHEST",
    "DWD_CHNL": "HIGH", "DWD_PROD": "MEDIUM",
    "DWD_ACCT": "LOW", "DWD_AGMT": "LOW", "DWD_AST": "LOW",
    "DWD_EVT": "LOW", "DWD_TRAN": "LOW",
}


# ============================ 公共 ============================ #
def st(v):
    """REST 的 state 可能是字符串（'SUCCESS'）也可能是 int ⇒ 统一成字符串。

    ★ 踩过的坑：写死 `state == 4` 判成功，但 task-instances 返回**字符串** ⇒ 全部误判成失败。
    """
    if isinstance(v, str):
        return v
    return STATE.get(v, str(v))


def vm_mem_gb():
    """读 WSL VM 剩余内存。★ 必须在容器内量 —— Git Bash 的 free 看的是 Windows 宿主。

    ★ 用 `grep|tr|cut` 而非 awk —— `docker exec … awk "/MemAvailable/{print $2}"` 在
      bash 层会把 `$2` 吃掉报 awk 语法错（2026-10-10 实测）。
    """
    try:
        p = subprocess.run(
            ["docker", "exec", PROBE_CONTAINER, "bash", "-c",
             'grep MemAvailable /proc/meminfo | tr -s " " | cut -d" " -f2'],
            capture_output=True, timeout=60)
        return int(p.stdout.decode().strip().split()[0]) / 1048576.0
    except Exception:
        return -1.0


def pg():
    import psycopg2
    c = psycopg2.connect(connect_timeout=8, **PG)
    c.autocommit = True
    return c


def pcode_of(ds, project="dw"):
    r = ds.call("GET", "/projects/list", params={"searchVal": project, "pageSize": 50, "pageNo": 1})
    d = r.get("data")
    items = d.get("totalList") if isinstance(d, dict) else (d or [])
    return next((it["code"] for it in items if it.get("name") == project), None)


def all_workflows(ds, pcode):
    wfs, page = {}, 1
    while True:
        r = ds.call("GET", "/projects/%d/workflow-definition" % pcode,
                    params={"pageNo": page, "pageSize": 100})
        tl = (r.get("data") or {}).get("totalList") or []
        for w in tl:
            wfs[w["name"]] = w["code"]
        if len(tl) < 100:
            break
        page += 1
    return wfs


def list_workflow_codes(ds, pcode, only=""):
    """项目下所有工作流 (名, code)，只留 name 含 only 的。★ 列表接口返回是嵌套的。"""
    out = []
    for page in (1, 2, 3):
        r = ds.call("GET", "/projects/%d/workflow-definition/list" % pcode,
                    params={"pageNo": page, "pageSize": 50, "searchVal": ""})
        d = r.get("data")
        lst = (d or {}).get("totalList") if isinstance(d, dict) else (d or [])
        if not lst:
            break
        for w in lst:
            wd = w.get("workflowDefinition") or w
            nm = wd.get("name") or ""
            if only and only not in nm:
                continue
            out.append((nm, wd.get("code")))
        if len(lst) < 50:
            break
    return out


def _running(ds, pcode):
    r = ds.call("GET", "/projects/%d/workflow-instances" % pcode,
                params={"pageNo": 1, "pageSize": 50, "stateType": "RUNNING_EXECUTION"})
    return [x.get("name") for x in ((r.get("data") or {}).get("totalList") or [])]


def _today_success(ds, pcode, prefix):
    out, page = set(), 1
    while True:
        r = ds.call("GET", "/projects/%d/workflow-instances" % pcode,
                    params={"pageNo": page, "pageSize": 100, "stateType": "SUCCESS"})
        tl = (r.get("data") or {}).get("totalList") or []
        for x in tl:
            nm = x.get("name") or ""
            if nm.startswith(prefix) and (x.get("endTime") or "").startswith(time.strftime("%Y-%m-%d")):
                out.add(nm.rsplit("-", 1)[0])
        if len(tl) < 100:
            break
        page += 1
    return out


def _ensure_online(ds, pcode, code):
    """OFFLINE 下手动触发会被拒（50014）⇒ 先置 ONLINE。"""
    d = ds.call("GET", "/projects/%d/workflow-definition/%d" % (pcode, code))
    wf = (d.get("data") or {}).get("workflowDefinition") or {}
    if wf.get("releaseState") == "ONLINE":
        return True
    r = ds.call("POST", "/projects/%d/workflow-definition/%d/release" % (pcode, code),
                form={"releaseState": "ONLINE"})
    if r.get("code") != 0:
        print("     置 ONLINE 失败: %s" % json.dumps(r, ensure_ascii=False)[:180])
        return False
    print("     ↗ 已置 ONLINE")
    return True


def _latest(ds, pcode, name):
    r = ds.call("GET", "/projects/%d/workflow-instances" % pcode,
                params={"pageNo": 1, "pageSize": 20, "searchVal": name})
    tl = (r.get("data") or {}).get("totalList") or []
    for x in tl:
        if (x.get("name") or "").startswith(name + "-"):
            return x
    return tl[0] if tl else None


def _tasks_of(ds, pcode, inst_id):
    out, page = [], 1
    while True:
        r = ds.call("GET", "/projects/%d/task-instances" % pcode,
                    params={"pageNo": page, "pageSize": 100, "workflowInstanceId": inst_id})
        tl = (r.get("data") or {}).get("totalList") or []
        out += tl
        if len(tl) < 100:
            break
        page += 1
    return out


def _save_report(path, rep):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(rep, f, ensure_ascii=False, indent=2)


def _trigger_wf(ds, pcode, code, failure_strategy, start_node=None,
                priority="MEDIUM"):
    q = {
        "workflowDefinitionCode": code, "scheduleTime": "",
        "failureStrategy": failure_strategy, "warningType": "NONE",
        "warningGroupId": 0, "workflowInstancePriority": priority,
    }
    if start_node is not None:
        q["startNodeList"] = str(start_node)
        q["taskDependType"] = "TASK_ONLY"
    return ds.call("POST", "/projects/%d/executors/start-workflow-instance?%s"
                   % (pcode, urllib.parse.urlencode(q)))


# ============================ manual ============================ #
def cmd_manual(args):
    c = pg()
    cur = c.cursor()
    pcode = PROJECT_CODE

    if args.list:
        cur.execute("select name, code from t_ds_workflow_definition order by name")
        print("工作流清单（★ 建议按层级自下而上手动跑）：")
        for name, code in cur.fetchall():
            print("  %-22s %-18s [%s]" % (name, code, "ODS" if name.startswith("ods_") else "DWD"))
        cur.close(); c.close(); return 0

    if args.status:
        cur.execute("select name, state, start_time from t_ds_workflow_instance "
                    "where end_time is null order by start_time")
        rows = cur.fetchall()
        print("当前未结束实例 %d 个：" % len(rows))
        for n, s, t in rows:
            print("  %-34s %-14s 起 %s" % (n, st(s) if not isinstance(s, str) else s, t))
        if not rows:
            print("  （空闲）")
        cur.close(); c.close(); return 0

    cur.execute("select name, code from t_ds_workflow_definition order by name")
    allw = cur.fetchall()
    targets = [(n, cd) for n, cd in allw
               if (args.name and n == args.name) or (args.prefix and n.startswith(args.prefix))]
    if not targets:
        print("没有匹配的工作流（用 --list 看名字）")
        cur.close(); c.close(); return 0
    print("待触发 %d 条：%s" % (len(targets), ", ".join(t[0] for t in targets)[:90]))

    mem = vm_mem_gb()
    cur.execute("select count(*) from t_ds_workflow_instance where end_time is null")
    run = cur.fetchone()[0]
    print("\n闸门检查：")
    print("  VM MemAvailable  %.2f GiB  （下限 %.1f）%s"
          % (mem, args.min_mem, "" if mem >= args.min_mem else "  ← 不足"))
    print("  当前在跑工作流  %d 个（并发上限 %d）%s"
          % (run, args.max_parallel, "" if run < args.max_parallel else "  ← 已满"))
    if not args.force and (mem < args.min_mem or run >= args.max_parallel):
        print("\n★ 拒绝触发：资源不满足。凑够资源再跑，或加 --force 硬来（会把 Worker 拖垮，慎用）")
        cur.close(); c.close(); return 0

    if not args.apply:
        print("\n（干跑，未触发。加 --apply 执行）")
        cur.close(); c.close(); return 0

    ds = DSClient()
    slots = args.max_parallel - run
    batch = targets[:slots]
    if len(batch) < len(targets):
        print("\n本次只触发前 %d 条（受并发上限限制），剩余 %d 条下次再跑"
              % (len(batch), len(targets) - len(batch)))
    insts = []
    for name, code in batch:
        r = _trigger_wf(ds, pcode, code, "END" if args.failure_strategy == "END" else "CONTINUE")
        if r.get("code") == 0:
            print("  ✓ %-22s 已触发" % name)
            insts.append((name, code))
        else:
            print("  ✗ %-22s %s" % (name, str(r)[:150]))

    if not args.wait or not insts:
        cur.close(); c.close(); return 0

    print("\n等待完成（每 30s 轮询一次，Ctrl+C 退出跟踪不影响作业）...")
    names = [n for n, _ in insts]
    try:
        while True:
            time.sleep(30)
            q = ",".join(["%s"] * len(names))
            cur.execute(
                "select name, state, end_time from t_ds_workflow_instance "
                "where name in (%s) and start_time >= now() - interval '6 hours' "
                "order by start_time desc limit %d" % (q, len(names)), names)
            rows = cur.fetchall()
            pend = [r for r in rows if r[2] is None]
            print("  %s  未完成 %d / %d" % (time.strftime("%H:%M:%S"), len(pend), len(rows)))
            if not pend and rows:
                print("\n全部结束：")
                for n, s, _e in rows[:len(names)][::-1]:
                    print("  %-24s %s" % (n, s if isinstance(s, str) else st(s)))
                break
    except KeyboardInterrupt:
        print("\n（退出跟踪，作业继续在跑。用 --status 查看）")
    cur.close(); c.close(); return 0


# ============================ task ============================ #
def _locate_task(ds, pcode, task_name, wf_code=None):
    if wf_code:
        r = ds.call("GET", "/projects/%d/workflow-definition/%d" % (pcode, wf_code))
        d = r.get("data") or {}
        nm = (d.get("workflowDefinition") or {}).get("name")
        for t in (d.get("taskDefinitionList") or []):
            if t.get("name") == task_name:
                return wf_code, nm, t
        return None, None, None
    for cands in (WORKFLOWS, list_workflow_codes(ds, pcode)):
        for c in cands:
            wc = c[1]
            r = ds.call("GET", "/projects/%d/workflow-definition/%d" % (pcode, wc))
            if r.get("code") != 0:
                continue
            d = r.get("data") or {}
            nm = (d.get("workflowDefinition") or {}).get("name")
            for t in (d.get("taskDefinitionList") or []):
                if t.get("name") == task_name:
                    return wc, nm, t
    return None, None, None


def cmd_task(args):
    ds = DSClient()
    pcode = PROJECT_CODE
    wf_code, wf_name, task = _locate_task(ds, pcode, args.task, args.wf or None)
    if not task:
        print("未找到任务 %s" % args.task)
        ds.close(); return 1
    print("任务定位 OK: %s" % args.task)
    print("  工作流 = %s (%s)" % (wf_name, wf_code))
    print("  task code = %s  type=%s  version=%s"
          % (task.get("code"), task.get("taskType"), task.get("version")))

    script = (task.get("taskParams") or {}).get("rawScript") or ""
    print("  脚本 %d chars" % len(script))
    for tok, label in (("${hsfa_path}", "hsfa_path"), ("${hsfa_username}", "hsfa_username"),
                       ("${hsfa_jdbc}", "hsfa_jdbc"), ("${dw_path}", "旧 dw_path"),
                       ("${o32_path}", "旧 o32_path"), ("${o32_jdbc}", "旧 o32_jdbc")):
        print("    %-18s: %s" % (label, tok in script))

    if args.dry_run:
        print("[dry-run] 不触发。")
        ds.close(); return 0

    tcode = task.get("code")
    print("\n① 单节点触发 [%s] (startNodeList=%s) …" % (args.task, tcode))
    res = _trigger_wf(ds, pcode, wf_code, "END", start_node=tcode)
    print("  返回: %s" % json.dumps(res, ensure_ascii=False)[:600])
    if res.get("code") != 0:
        ds.close(); return 1
    wf_inst = (res.get("data") or [None])[0]
    print("  workflow instance id = %s" % wf_inst)

    print("\n② 跟踪任务实例状态（最多 %ds）…" % args.timeout)
    t0, last, inst = time.time(), None, None
    while time.time() - t0 < args.timeout:
        q = ds.call("GET", "/projects/%d/task-instances" % pcode,
                    params={"pageNo": 1, "pageSize": 50, "taskName": args.task})
        lst = (q.get("data") or {}).get("totalList") or []
        # ★★★ 必须【严格】按 workflowInstanceId 过滤，绝不能回退到 lst（同名历史实例一大堆）
        cands = [x for x in lst if x.get("workflowInstanceId") == wf_inst]
        if not cands:
            print("   [%4ds] 等待新实例落库（wfInst=%s）…" % (int(time.time() - t0), wf_inst), flush=True)
            time.sleep(8)
            continue
        cand = sorted(cands, key=lambda x: x.get("id") or 0)[-1]
        s = st(cand.get("state"))
        if s != last:
            print("   [%4ds] state=%s id=%s start=%s end=%s"
                  % (int(time.time() - t0), s, cand.get("id"), cand.get("startTime"), cand.get("endTime")),
                  flush=True)
            last = s
        inst = cand
        if s in TERMINAL:
            break
        time.sleep(8)

    if inst:
        print("\n=== 最终任务实例 ===")
        for k in ("id", "name", "state", "startTime", "endTime", "duration", "host", "logPath"):
            print("  %s: %s" % (k, inst.get(k)))
        print("\nworkflowInstanceId=%s  taskInstanceId=%s" % (wf_inst, inst.get("id")))
    ds.close()
    return 0


# ============================ rerun-failed ============================ #
def _rerun_one(ds, pcode, task_name, args, cache):
    if not cache:
        cache["wfs"] = list_workflow_codes(ds, pcode, args.only)
    for wf_name, wf_code in cache["wfs"]:
        r = ds.call("GET", "/projects/%d/workflow-definition/%d" % (pcode, wf_code))
        if r.get("code") != 0:
            continue
        d = r.get("data") or {}
        for t in (d.get("taskDefinitionList") or []):
            if t.get("name") == task_name:
                tcode = t.get("code")
                print("  定位 OK：%s @ %s(%s) taskCode=%s" % (task_name, wf_name, wf_code, tcode))
                if args.dry_run:
                    return True
                for i in range(60):
                    g = vm_mem_gb()
                    if g < 0:
                        print("  量不到内存，放行（自行承担风险）"); break
                    if g >= args.min_mem:
                        print("  [%s] MemAvailable=%.2f GiB ✓" % (task_name, g)); break
                    print("  [%s] MemAvailable=%.2f GiB < %.1f ⇒ 等 30s（%d/60）"
                          % (task_name, g, args.min_mem, i + 1), flush=True)
                    time.sleep(30)
                res = _trigger_wf(ds, pcode, wf_code, "END", start_node=tcode)
                if res.get("code") != 0:
                    print("  !! 触发失败 %s: %s" % (task_name, res)); return False
                wf_inst = (res.get("data") or [None])[0]
                print("  已触发，workflowInstanceId=%s" % wf_inst)
                t0, last = time.time(), None
                while time.time() - t0 < args.timeout:
                    q = ds.call("GET", "/projects/%d/task-instances" % pcode,
                                params={"pageNo": 1, "pageSize": 50, "taskName": task_name})
                    lst = (q.get("data") or {}).get("totalList") or []
                    cands = [x for x in lst if x.get("workflowInstanceId") == wf_inst]
                    if not cands:
                        print("     [%4ds] 等待新实例落库…" % int(time.time() - t0), flush=True)
                        time.sleep(8)
                        continue
                    cand = sorted(cands, key=lambda x: x.get("id") or 0)[-1]
                    s = st(cand.get("state"))
                    if s != last:
                        print("     [%4ds] state=%s id=%s" % (int(time.time() - t0), s, cand.get("id")), flush=True)
                        last = s
                    if s in TERMINAL:
                        print("     → %s: %s" % (task_name, s)); return s == "SUCCESS"
                    time.sleep(8)
                print("  !! %s 跟踪超时" % task_name); return False
    print("  !! 未找到任务 %s" % task_name)
    return False


def cmd_rerun_failed(args):
    ds = DSClient()
    pcode = PROJECT_CODE
    names = [x.strip() for x in args.tasks.split(",") if x.strip()]
    if args.from_db:
        c = pg()
        cur = c.cursor()
        cur.execute(
            "SELECT DISTINCT ti.name FROM t_ds_task_instance ti "
            "JOIN t_ds_workflow_instance wi ON wi.id=ti.workflow_instance_id "
            "WHERE ti.state=6 AND wi.start_time > NOW() - INTERVAL '%s hours' ORDER BY 1",
            (args.hours,))
        names = sorted(set(names) | {r[0] for r in cur.fetchall()})
        print("从元库捞到 %d 个 FAILURE 任务" % len(names))
        cur.close(); c.close()
    if not names:
        print("没有任务"); ds.close(); return 0
    print("待补跑 %d 个：%s\n" % (len(names), ", ".join(names)))
    ok, bad, cache = [], [], {}
    for n in names:
        print("── %s" % n)
        (ok if _rerun_one(ds, pcode, n, args, cache) else bad).append(n)
        print()
    print("补跑完成：成功 %d / 失败 %d" % (len(ok), len(bad)))
    if bad:
        print("仍失败：", ", ".join(bad))
    ds.close()
    return 0 if not bad else 1


# ============================ serial（ODS / DWD 共用） ============================ #
def _topo_order(available):
    """按 dep-config-lineage 推导 DWD_<主题> 拓扑序；回退字母序。

    ★ 2026-10-15 订正：EVT **不**依赖 PROD/SCR（旧注释错误，已绕过我一次）。
      EVT 脚本确实 LEFT JOIN `DWD_PROD_SFAC_NUM_MAPP_PFD` / `DWD_SCR_SCR_NUM_MAPP_PFD` /
      `DWD_CMM_STD_DICT_CDVAL_MAP`，但这三张是**无 ETL 脚本的映射表**（全集群无脚本，
      手工维护/独立刷新）⇒ 生成器 `ds-build-dependent-from-lineage.py` 的
      `noscript_up` 主动跳过「上游无脚本」的边 ⇒ **建不出作业级依赖**。
      数据血缘存在但调度上无依赖 ⇒ EVT 顺序自由；映射表数据新鲜度不在
      dep-config-lineage 表达范围内（门禁 WANT 只收有脚本的上游，ODS 表承担新鲜度信号）。
    """
    deps = collections.defaultdict(set)
    wfs = set(available)
    try:
        for f in sorted(os.listdir(DEPCFG)):
            if not f.endswith(".dep.json"):
                continue
            c = json.load(open(os.path.join(DEPCFG, f), encoding="utf-8"))
            wf = c.get("own_workflow")
            if wf not in wfs:
                continue
            for g in c.get("cross_workflow", []):
                u = g.get("workflow")
                if u in wfs and u != wf:
                    deps[wf].add(u)
    except OSError as e:
        print("   ⚠ 读依赖配置失败（%s），回退字母序" % e)

    indeg = {w: len(deps.get(w, ())) for w in wfs}
    q = sorted(w for w, d in indeg.items() if d == 0)
    out = []
    while q:
        w = q.pop(0)
        out.append(w)
        for v in sorted(wfs):
            if w in deps.get(v, ()):
                indeg[v] -= 1
                if indeg[v] == 0:
                    q.append(v)
        q.sort()
    for w in sorted(wfs):
        if w not in out:
            out.append(w)
    return out


def _serial(args, kind):
    """kind ∈ {ods, dwd}"""
    prefix = "ods_" if kind == "ods" else "DWD_"
    min_mem = args.min_mem if args.min_mem is not None else (1.0 if kind == "ods" else 1.5)
    report = os.path.join(ROOT, ".dx-tmp", "%s-run-report.json" % kind)

    ds = DSClient(user=ds_service_user(), password=ds_service_password())
    pcode = PROJECT_CODE
    wfs = all_workflows(ds, pcode)

    if kind == "ods":
        order = [s.strip().lower() for s in args.order.split(",") if s.strip()]
        plan = [(n, wfs[n]) for s in order for n in sorted(n for n in wfs if n.startswith("ods_%s_" % s))]
    else:
        # 先按用户定稿的重启顺序；新增/未登记的工作流再按依赖拓扑序补在后面
        order = [n for n in DWD_WORKFLOW_ORDER if n in wfs]
        order += [n for n in _topo_order(set(n for n in wfs if n.startswith("DWD_")))
                  if n not in order]
        plan = [(n, wfs[n]) for n in order]
    if args.only:
        plan = [(args.only, wfs.get(args.only))]

    if args.start_from:
        idx = next((i for i, (n, _) in enumerate(plan) if n == args.start_from), None)
        if idx is None:
            sys.exit("--start-from 指定的工作流不在计划里: %s" % args.start_from)
        plan = plan[idx:]
    if not args.no_skip_success:
        done = _today_success(ds, pcode, prefix)
        skipped = [n for n, _ in plan if n in done]
        plan = [(n, c) for n, c in plan if n not in done]
        if skipped:
            print("（跳过今日已成功 %d 个: %s%s）"
                  % (len(skipped), ", ".join(skipped[:6]), " …" if len(skipped) > 6 else ""))

    print("=" * 78)
    print("串行跑 %s（每次只启动一个%s）"
          % ("ODS 抽数工作流" if kind == "ods" else "DWD 主题工作流",
             "，按系统字母序" if kind == "ods" else "，按拓扑序"))
    print("=" * 78)
    for i, (n, c) in enumerate(plan, 1):
        print("  %2d. %-22s code=%s" % (i, n, c))
    print("\n共 %d 个工作流" % len(plan))

    if not args.apply:
        print("\n（干跑，未触发。加 --apply 执行）")
        ds.close(); return 0

    rep = {"startedAt": time.strftime("%Y-%m-%d %H:%M:%S"), "workflows": []}
    for idx, (name, code) in enumerate(plan, 1):
        print("\n" + "-" * 78)
        print("[%d/%d] %s" % (idx, len(plan), name))
        while True:
            cur = _running(ds, pcode)
            if not cur:
                break
            print("   ⏳ 仍有 %d 个实例在跑（%s），等待串行…" % (len(cur), cur[0]))
            time.sleep(args.poll)
        for _ in range(args.mem_wait):
            m = vm_mem_gb()
            if m < 0 or m >= min_mem:
                break
            print("   ⏳ VM 内存仅 %.2f GiB（下限 %.1f），等待…" % (m, min_mem))
            time.sleep(args.poll)

        if not _ensure_online(ds, pcode, code):
            print("   ✗ 置 ONLINE 失败，跳过")
            rep["workflows"].append({"name": name, "state": "ONLINE_FAILED"})
            _save_report(report, rep)
            continue

        prio = DWD_WORKFLOW_PRIORITY.get(name, "MEDIUM") if kind == "dwd" else "MEDIUM"
        r = _trigger_wf(ds, pcode, code, args.failure_strategy, priority=prio)
        if r.get("code") != 0:
            print("   ✗ 触发失败: %s" % json.dumps(r, ensure_ascii=False)[:200])
            rep["workflows"].append({"name": name, "state": "TRIGGER_FAILED", "detail": str(r)[:300]})
            _save_report(report, rep)
            continue
        print("   ✓ 已触发，等待完成…")

        deadline = time.time() + args.max_min * 60
        inst = None
        while time.time() < deadline:
            time.sleep(args.poll)
            inst = _latest(ds, pcode, name)
            if inst and inst.get("endTime"):
                break
            rest = int(deadline - time.time())
            print("   … %s  (剩余 %dm%ds)" % (st(inst.get("state")) if inst else "?", rest // 60, rest % 60))
        else:
            print("   ⚠ 超时，记为 TIMEOUT 并继续下一条")
            rep["workflows"].append({"name": name, "state": "TIMEOUT"})
            _save_report(report, rep)
            continue

        tasks = _tasks_of(ds, pcode, inst["id"]) if inst else []
        ok = sum(1 for t in tasks if st(t.get("state")) in TASK_OK)
        bad = [t for t in tasks if st(t.get("state")) not in TASK_OK]
        wstate = st(inst.get("state"))
        print("   → %s  成功 %d/%d" % (wstate, ok, len(tasks)))
        for t in bad[:8]:
            print("        ✗ %s  %s" % (t["name"], st(t.get("state"))))
        rep["workflows"].append({
            "name": name, "instanceId": inst.get("id"), "state": wstate,
            "startTime": inst.get("startTime"), "endTime": inst.get("endTime"),
            "taskTotal": len(tasks), "taskOk": ok, "taskFail": len(bad),
            "failedTasks": [{"name": t["name"], "state": st(t.get("state"))} for t in bad],
        })
        _save_report(report, rep)

    rep["finishedAt"] = time.strftime("%Y-%m-%d %H:%M:%S")
    _save_report(report, rep)
    print("\n" + "=" * 78)
    print("汇总")
    print("=" * 78)
    for w in rep["workflows"]:
        print("  %-22s %-12s 成功 %s/%s"
              % (w["name"], w.get("state"), w.get("taskOk", "-"), w.get("taskTotal", "-")))
    print("\n报告: %s" % report)
    ds.close()
    return 0


# ============================ main ============================ #
def main():
    ap = argparse.ArgumentParser(description="DS 触发/跑批统一入口（manual/task/ods-serial/dwd-serial/rerun-failed）")
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("manual", help="工作流级手动触发（内存 + 并发闸门）")
    p.add_argument("--list", action="store_true")
    p.add_argument("--status", action="store_true")
    p.add_argument("--name", help="工作流全名")
    p.add_argument("--prefix", help="工作流名前缀批量选")
    p.add_argument("--max-parallel", type=int, default=3, help="并发上限，默认 3")
    p.add_argument("--min-mem", type=float, default=1.0, help="VM 内存下限 GiB")
    p.add_argument("--apply", action="store_true")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--wait", action="store_true")
    p.add_argument("--force", action="store_true")
    p.add_argument("--failure-strategy", default="CONTINUE", choices=["CONTINUE", "END"])
    p.set_defaults(func=cmd_manual)

    p = sub.add_parser("task", help="单任务触发 + 跟踪")
    p.add_argument("--task", required=True)
    p.add_argument("--wf", type=int, default=0, help="工作流 code（不传则自动搜索）")
    p.add_argument("--timeout", type=int, default=1500)
    p.add_argument("--dry-run", action="store_true")
    p.set_defaults(func=cmd_task)

    def serial_args(parser, default_order):
        parser.add_argument("--apply", action="store_true")
        parser.add_argument("--only", help="只跑这一个工作流")
        parser.add_argument("--start-from", help="从这个工作流名开始")
        parser.add_argument("--poll", type=int, default=30)
        parser.add_argument("--mem-wait", type=int, default=20)
        parser.add_argument("--max-min", type=int, default=30)
        parser.add_argument("--no-skip-success", action="store_true")
        parser.add_argument("--min-mem", type=float, default=None, help="VM 内存下限 GiB（默认 ODS 1.0 / DWD 1.5）")
        parser.add_argument("--failure-strategy", default="CONTINUE", choices=["CONTINUE", "END"],
                            help="★ 默认 CONTINUE")
        parser.add_argument("--order", default=default_order)

    p = sub.add_parser("ods-serial", help="串行跑 ODS（按系统字母序）")
    serial_args(p, ",".join(SYS_ORDER))
    p.set_defaults(func=lambda a: _serial(a, "ods"))

    p = sub.add_parser("dwd-serial", help="串行跑 DWD（按拓扑序）")
    serial_args(p, "")
    p.add_argument("--max-min-dwd", type=int, default=45)   # 占位，避免误用
    p.set_defaults(func=lambda a: _serial(a, "dwd"))

    p = sub.add_parser("rerun-failed", help="补跑指定 / 捞出的 FAILURE 任务")
    p.add_argument("--tasks", default="", help="逗号分隔的任务名")
    p.add_argument("--from-db", action="store_true")
    p.add_argument("--hours", type=int, default=10)
    p.add_argument("--only", default="", help="只跑名字含该串的工作流下的任务（如 ods_）")
    p.add_argument("--min-mem", type=float, default=1.0)
    p.add_argument("--timeout", type=int, default=1800)
    p.add_argument("--dry-run", action="store_true")
    p.set_defaults(func=cmd_rerun_failed)

    args = ap.parse_args()
    # DWD 串行默认 max-min 45
    if args.cmd == "dwd-serial" and args.max_min == 30:
        args.max_min = 45
    return args.func(args) or 0


if __name__ == "__main__":
    raise SystemExit(main())
