#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DolphinScheduler 定时调度统一入口（四合一）。

并入自（原文件已删，2026-10-11）：
  create  ← ds-create-schedule.py        给单个工作流建调度（默认 OFFLINE）
  ensure  ← ds-ensure-schedules.py       批量补齐：补 globalParams + 挂调度 + 上线
  switch  ← ds-schedule-switch.py        按 id / 前缀 / 全名 批量上·下线
  release ← ds-set-schedule-release.py   查看 / 上·下线（走 REST，仅能看到 ONLINE）

用法
----
    python ds-schedule.py create --workflow ods_hsfa_etl_01 --cron "0 0 2 * * ? *" --apply
    python ds-schedule.py create --list
    python ds-schedule.py ensure --apply            # 补参数 + 建调度 + 上线（先干跑看计划）
    python ds-schedule.py ensure --check            # 只校验现状（走元库）
    python ds-schedule.py switch --offline --prefix ods_ --apply
    python ds-schedule.py release --online --id 1

★ 铁律
- ★★★ 改工作流定义会**级联把 `t_ds_schedules.release_state` 置 0** ⇒ 批量改完后必须核对调度状态
  （本项目 10-04 02:00 就这样静默漏跑过一次）。
- ★ 校验调度**必须查元库** —— REST 的 `GET /schedules` **看不到 OFFLINE 的**。
- ★ 动 DS 前先确认没有跑批；同用户只 1 会话，别并发跑。
- 端点：`/projects/{code}/schedules/{id}/online|offline`（**没有** `/release`，那是 405）。
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from ds_client import DSClient, task_definitions  # noqa: E402
from ds_config import ds_admin_password, ds_admin_user, pg_conn  # noqa: E402

PROJECT_CODE = 185582190746560
TENANT = "dolphinscheduler"
EXEC = "SERIAL_WAIT"
TZ = "Asia/Shanghai"
DEFAULT_CRON = "0 0 2 * * ? *"     # 每天 02:00
PG = pg_conn()   # ★ 2026-10-22：口令从环境/凭据文件读，源码不含字面量

WORKFLOWS = {
    "ods_hsfa_etl_01": 185582312443840,
    "ods_hsfa_etl_02": 185582314365888,
    "ods_hsfa_etl_03": 185582315538368,
    "ods_hsfa_etl_04": 185582316098496,
    "ods_hsfa_etl_05": 185593198910400,
}

# DWD 分层（2026-10-07 从 DEPENDENT 的 task_params 实测得出）
# ★ 2026-10-15 晚：与 dep-config 拓扑严格同序（MASTER 主数据按主题并入 DWD_<主题>，
#   用户决定「MASTER 和其他 DWD 放一起，按主题」；不单独建 MASTER_* 工作流）。
#   ds-deploy-all-dwd.py --dry-run 的「拓扑序」就是本表的顺序，改了那边必须同步这里。
LAYERS = [
    ("DWD_CMM", "DWD_CHNL", "DWD_PROD", "DWD_ACCT", "DWD_PTY"),
    ("DWD_PUB", "DWD_SCR", "DWD_AGMT", "DWD_AST", "DWD_EVT", "DWD_TRAN"),
]
DWD_SLOTS = [
    (12, 0), (12, 20), (12, 40), (13, 0), (13, 20),
    (13, 40), (14, 0), (14, 20), (14, 40), (15, 0), (15, 30),
]
ODS_START_MIN = 3 * 60 + 15   # 03:15
ODS_STEP_MIN = 15

GLOBAL_PARAMS = [
    {"prop": "p_start_dt", "direct": "IN", "type": "VARCHAR", "value": "${system.biz.date}"},
    {"prop": "p_end_dt", "direct": "IN", "type": "VARCHAR", "value": "${system.biz.date}"},
    {"prop": "p_batch_dt", "direct": "IN", "type": "VARCHAR", "value": "${system.biz.date}"},
]


# ============================ 公共 ============================ #
def pg_conn():
    import psycopg2
    # ★ PG 里已含 dbname（见 ds_config.pg_conn），此处不可再硬编码，否则
    #   psycopg2.connect() 会报 "got multiple values for keyword argument 'dbname'"。
    c = psycopg2.connect(connect_timeout=8, **PG)
    c.autocommit = True
    return c


def jprint(t, o):
    print("%s: %s" % (t, json.dumps(o, ensure_ascii=False)[:800]), flush=True)


# ============================ create ============================ #
def _resolve_code(ds, w):
    if w is None:
        return None
    if str(w).isdigit():
        return int(w)
    if w in WORKFLOWS:
        return WORKFLOWS[w]
    r = ds.call("GET", "/projects/%d/workflow-definition" % PROJECT_CODE,
                params={"pageNo": 1, "pageSize": 50, "searchVal": w})
    for d in ((r.get("data") or {}).get("totalList") or []):
        if d.get("name") == w:
            return d.get("code")
    return None


def cmd_create(args):
    ds = DSClient()
    if args.list:
        r = ds.call("GET", "/projects/%d/schedules" % PROJECT_CODE,
                    params={"pageNo": 1, "pageSize": 50})
        lst = ((r.get("data") or {}).get("totalList") or [])
        print("现有调度 %d 条：" % len(lst))
        for s in lst:
            print("  id=%s workflow=%s cron=%s 状态=%s"
                  % (s.get("id"), s.get("workflowCode") or s.get("processDefinitionCode"),
                     s.get("crontab"), s.get("releaseState")))
        return 0

    code = _resolve_code(ds, args.workflow)
    if code is None:
        print("找不到工作流：%s（已知：%s）" % (args.workflow, ", ".join(WORKFLOWS)), file=sys.stderr)
        return 1

    start = args.start or time.strftime("%Y-%m-%d %H:%M:%S")
    schedule = {
        "startTime": start,
        "endTime": args.end,
        "crontab": args.cron,
        "timezoneId": TZ,
        "failureStrategy": "CONTINUE",
        "warningType": "NONE",
        "warningGroupId": 0,
        "processInstancePriority": "MEDIUM",
        "workerGroup": "default",
        "environmentCode": -1,
        "releaseState": "ONLINE" if args.online else "OFFLINE",
    }
    print("工作流 code=%s（%s）" % (code, args.workflow))
    print("调度体：%s" % json.dumps(schedule, ensure_ascii=False))
    print("releaseState=%s" % ("ONLINE ⚠️ 会真的按时触发" if args.online else "OFFLINE（不会自己跑）"))
    if not args.apply:
        print("\n（干跑，未创建。加 --apply 真的建）")
        return 0

    # ★ 参数名是 workflowDefinitionCode —— 3.4.2 已把 process 全改名 workflow
    last = None
    for param in ("workflowDefinitionCode", "workflowCode", "processDefinitionCode"):
        try:
            r = ds.call("POST", "/projects/%d/schedules" % PROJECT_CODE,
                        form={param: code, "schedule": json.dumps(schedule)})
        except Exception as e:
            last = "%s: %s" % (param, e)
            continue
        if r.get("code") == 0:
            jprint("✅ 已用 %s 创建" % param, r.get("data"))
            return 0
        last = "%s: code=%s msg=%s" % (param, r.get("code"), r.get("msg"))
    print("❌ 创建失败（%s）" % last, file=sys.stderr)
    return 1


# ============================ ensure ============================ #
def _check_running(c):
    """★ 判据必须是 end_time is null，不能用 state 枚举（state=6 是 PAUSE 终态）。"""
    cur = c.cursor()
    cur.execute("select count(*) from t_ds_workflow_instance where end_time is null")
    n = cur.fetchone()[0]
    cur.close()
    return n


def _survey(c):
    cur = c.cursor()
    cur.execute("select name, code, coalesce(global_params,'') from t_ds_workflow_definition")
    wfs = cur.fetchall()
    cur.execute("select workflow_definition_code from t_ds_schedules")
    has_sched = {r[0] for r in cur.fetchall()}
    cur.close()
    need_params = [w for w in wfs
                   if w[0].startswith(("DWD_", "MASTER_"))
                   and w[2].strip() in ("", "[]", "null")]
    need_sched = [w for w in wfs if w[1] not in has_sched]
    return need_params, need_sched, has_sched


def _cron(h, m):
    return "0 %d %d * * ? *" % (m, h)


def _plan_slots(need_sched):
    dwd_slot = {}
    i = 0
    for layer in LAYERS:
        for name in layer:
            if i < len(DWD_SLOTS):
                dwd_slot[name] = DWD_SLOTS[i]
                i += 1
    out = []
    ods_i = 0
    for name, code, _ in sorted(need_sched, key=lambda x: x[0]):
        if name in dwd_slot:
            h, m = dwd_slot[name]
        else:
            t = ODS_START_MIN + ods_i * ODS_STEP_MIN
            h, m = t // 60, t % 60
            ods_i += 1
        out.append((name, code, _cron(h, m), h, m))
    return out


def _jloads(x):
    if isinstance(x, str):
        try:
            return json.loads(x)
        except Exception:
            return x
    return x


def _do_params(ds, items, apply_):
    print("\n" + "-" * 72)
    print("阶段 1：补 globalParams（%d 个）" % len(items))
    print("-" * 72)
    for name, code, _old in sorted(items, key=lambda x: x[0]):
        gp = json.dumps(GLOBAL_PARAMS, ensure_ascii=False)
        print("  %-12s %s" % (name, gp[:90]))
        if not apply_:
            continue
        g = ds.call("GET", "/projects/%d/workflow-definition/%s" % (PROJECT_CODE, code))["data"]
        wd = _jloads(g["workflowDefinition"])
        # ★ 2026-10-22：改用共用的 task_definitions（防御性取值）
        tds = task_definitions(g)
        rels = _jloads(g["workflowTaskRelationList"])
        locs = _jloads(wd.get("locations"))
        ds.call("POST", "/projects/%d/workflow-definition/%s/release" % (PROJECT_CODE, code),
                form={"releaseState": "OFFLINE"})
        res = ds.call("PUT", "/projects/%d/workflow-definition/%s" % (PROJECT_CODE, code), form={
            "name": wd.get("name"), "description": wd.get("description") or "",
            "globalParams": gp, "locations": json.dumps(locs),
            "timeout": wd.get("timeout") or 0, "tenantCode": TENANT,
            "taskRelationJson": json.dumps(rels),
            "taskDefinitionJson": json.dumps(tds, ensure_ascii=False),
            "executionType": wd.get("executionType") or EXEC,
            "releaseState": "OFFLINE"})
        if res.get("code") != 0:
            print("      ✗ PUT 失败 %s" % json.dumps(res, ensure_ascii=False)[:200])
            continue
        r2 = ds.call("POST", "/projects/%d/workflow-definition/%s/release" % (PROJECT_CODE, code),
                     form={"releaseState": "ONLINE"})
        print("      %s PUT + 重新上线（code=%s）"
              % ("✓" if r2.get("code") == 0 else "✗", r2.get("code")))


def _do_schedules(ds, slots, apply_, online):
    print("\n" + "-" * 72)
    print("阶段 2：建定时调度（%d 个，%s）" % (len(slots), "ONLINE" if online else "OFFLINE"))
    print("-" * 72)
    start = time.strftime("%Y-%m-%d %H:%M:%S")
    ok = fail = 0
    for name, code, cr, h, m in slots:
        print("  %-22s %-20s 每天 %02d:%02d" % (name, cr, h, m))
        if not apply_:
            continue
        schedule = {
            "startTime": start, "endTime": "2099-12-31 23:59:59",
            "crontab": cr, "timezoneId": TZ,
            "failureStrategy": "CONTINUE", "warningType": "NONE",
            "warningGroupId": 0, "processInstancePriority": "MEDIUM",
            "workerGroup": "default", "environmentCode": -1,
            "releaseState": "ONLINE" if online else "OFFLINE",
        }
        r = ds.call("POST", "/projects/%d/schedules" % PROJECT_CODE,
                    form={"workflowDefinitionCode": code, "schedule": json.dumps(schedule)})
        if r.get("code") != 0:
            fail += 1
            print("      ✗ 创建失败 %s" % json.dumps(r, ensure_ascii=False)[:160])
            continue
        ok += 1
        if online:
            sid = ((r.get("data") or {}).get("id"))
            if sid:
                r2 = ds.call("POST", "/projects/%d/schedules/%s/online" % (PROJECT_CODE, sid))
                print("      %s 上线（id=%s code=%s）"
                      % ("✓" if r2.get("code") == 0 else "✗", sid, r2.get("code")))
    if apply_:
        print("\n  创建成功 %d / 失败 %d" % (ok, fail))


def _do_check(c):
    print("-" * 72)
    print("校验（走元库，含 OFFLINE 的也能看到）")
    print("-" * 72)
    cur = c.cursor()
    cur.execute(
        """
        select count(*) filter (where s.release_state=1),
               count(*) filter (where s.release_state=0),
               count(*)
        from t_ds_schedules s
        """
    )
    on, off, tot = cur.fetchone()
    cur.execute("select count(*) from t_ds_workflow_definition")
    wf = cur.fetchone()[0]
    print("  调度：ONLINE %d / OFFLINE %d / 合计 %d（覆盖率 %.0f%%）"
          % (on, off, tot, tot * 100.0 / wf))
    cur.execute(
        "select count(*) from t_ds_workflow_definition "
        "where name like 'DWD%%' and coalesce(global_params,'') in ('','[]','null')"
    )
    print("  globalParams 仍为空的 DWD：%d 个" % cur.fetchone()[0])
    cur.close()


def cmd_ensure(args):
    c = pg_conn()
    if args.check:
        _do_check(c)
        c.close()
        return 0

    n = _check_running(c)
    print("跑批检查：未结束实例 %d 个%s" % (n, "" if n == 0 else "  ★ 有跑批，不建议动手"))
    if n and args.apply:
        print("终止：有作业在跑")
        c.close()
        return 1

    need_params, need_sched, _ = _survey(c)
    slots = _plan_slots(need_sched)
    print("\n计划：补参数 %d 个，建调度 %d 个（%s）"
          % (len(need_params), len(slots), "OFFLINE" if args.offline else "ONLINE"))

    ds = DSClient()
    if not args.skip_params:
        _do_params(ds, need_params, args.apply)
    _do_schedules(ds, slots, args.apply, online=not args.offline)
    if args.apply:
        _do_check(c)
    c.close()
    return 0


# ============================ switch ============================ #
def _parse_ids(spec):
    out = set()
    for part in (spec or "").split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            a, b = part.split("-", 1)
            out.update(range(int(a), int(b) + 1))
        else:
            out.add(int(part))
    return sorted(out)


def cmd_switch(args):
    c = pg_conn()
    cur = c.cursor()
    cur.execute(
        """
        select s.id, w.name, s.crontab, s.release_state
        from t_ds_schedules s join t_ds_workflow_definition w
          on w.code = s.workflow_definition_code
        order by s.id
        """
    )
    rows = cur.fetchall()

    if args.list:
        print("调度 %d 条：" % len(rows))
        for sid, nm, cr, st in rows:
            print("  id=%-4d %-22s %-22s %s" % (sid, nm, cr, "ONLINE" if st == 1 else "OFFLINE"))
        cur.close()
        c.close()
        return 0

    targets = []
    ids = set(_parse_ids(args.id))
    for sid, nm, cr, st in rows:
        if ids:
            hit = sid in ids
        elif args.prefix:
            hit = nm.startswith(args.prefix)
        elif args.name:
            hit = nm == args.name
        else:
            hit = True
        if hit:
            targets.append((sid, nm, st))

    if not targets:
        print("没有匹配的调度")
        cur.close()
        c.close()
        return 0

    action = "online" if args.online else "offline"
    want = 1 if args.online else 0
    print("将对 %d 条调度执行 %s：" % (len(targets), action))
    for sid, nm, st in targets:
        skip = "（已是目标状态，跳过）" if st == want else ""
        print("  id=%-4d %-22s %s -> %s %s"
              % (sid, nm, "ONLINE" if st == 1 else "OFFLINE", action.upper(), skip))

    if not args.apply:
        print("\n（干跑，未改动。加 --apply 执行）")
        cur.close()
        c.close()
        return 0

    ds = DSClient()
    ok = skip_n = fail = 0
    for sid, nm, st in targets:
        if st == want:
            skip_n += 1
            continue
        r = ds.call("POST", "/projects/%d/schedules/%s/%s" % (PROJECT_CODE, sid, action))
        if r.get("code") == 0:
            ok += 1
            print("  ✓ id=%-4d %-22s -> %s" % (sid, nm, action.upper()))
        else:
            fail += 1
            print("  ✗ id=%-4d %s" % (sid, json.dumps(r, ensure_ascii=False)[:160]))

    print("\n完成：成功 %d / 跳过 %d / 失败 %d" % (ok, skip_n, fail))
    cur.execute("select count(*) filter (where release_state=1), count(*) from t_ds_schedules")
    on, tot = cur.fetchone()
    print("校验：当前 ONLINE %d / 合计 %d" % (on, tot))
    cur.close()
    c.close()
    return 0


# ============================ release ============================ #
def cmd_release(args):
    if args.online and args.offline:
        print("不能同时 --online 和 --offline", file=sys.stderr)
        return 1
    ds = DSClient()
    target = "ONLINE" if args.online else ("OFFLINE" if args.offline else None)

    if target and args.id:
        # ★ GET /schedules 只返回 ONLINE 的 ⇒ 无法靠列表找 id；直接按 id 上/下线
        # ★ 端点是 /online 与 /offline，没有 /release（405）
        rr = ds.call("POST", "/projects/%d/schedules/%s/%s" % (PROJECT_CODE, args.id, target.lower()))
        print("  id=%s → %s: %s"
              % (args.id, target, "✅ code=0" if rr.get("code") == 0 else "❌ " + str(rr)[:300]))
        ds.close()
        return 0 if rr.get("code") == 0 else 1

    r = ds.call("GET", "/projects/%d/schedules" % PROJECT_CODE)
    data = r.get("data") or []
    if isinstance(data, dict):
        data = data.get("totalList") or data.get("list") or []
    print("★ GET /schedules 只返回 ONLINE 的调度，当前可见 %d 条" % len(data))
    print("  （OFFLINE 的要去数据库查：select id,crontab,release_state from t_ds_schedules）")
    for s in data:
        print("  id=%s  wf=%s  cron=%s  tz=%s  state=%s  nextFire=%s"
              % (s.get("id"), s.get("workflowDefinitionCode"), s.get("crontab"),
                 s.get("timezoneId"), s.get("releaseState"), s.get("nextFireTime")))

    if not target:
        ds.close()
        return 0

    for s in data:
        sid = s.get("id")
        if args.id and sid != args.id:
            continue
        if s.get("releaseState") == target:
            print("  id=%s 已是 %s，跳过" % (sid, target))
            continue
        rr = ds.call("POST", "/projects/%d/schedules/%s/%s" % (PROJECT_CODE, sid, target.lower()))
        ok = rr.get("code") == 0
        print("  id=%s → %s: %s" % (sid, target, "✅" if ok else "❌ " + str(rr)[:200]))

    r2 = ds.call("GET", "/projects/%d/schedules" % PROJECT_CODE)
    d2 = r2.get("data") or []
    if isinstance(d2, dict):
        d2 = d2.get("totalList") or d2.get("list") or []
    print("\n复核（API 可见的）：")
    for s in d2:
        print("  id=%s state=%s nextFire=%s" % (s.get("id"), s.get("releaseState"), s.get("nextFireTime")))
    ds.close()
    return 0


# ============================ main ============================ #
def main():
    ap = argparse.ArgumentParser(description="DS 定时调度统一入口（create/ensure/switch/release）")
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("create", help="给单个工作流建调度（默认 OFFLINE）")
    p.add_argument("--workflow", help="工作流名（或纯数字 code）")
    p.add_argument("--cron", default=DEFAULT_CRON, help="Quartz 7 段：秒 分 时 日 月 周 年")
    p.add_argument("--start", default=None, help="生效起（默认现在）")
    p.add_argument("--end", default="2099-12-31 23:59:59")
    p.add_argument("--apply", action="store_true", help="真的建（默认只打印请求体）")
    p.add_argument("--online", action="store_true", help="建完立即上线（危险）")
    p.add_argument("--list", action="store_true", help="列出现有调度")
    p.set_defaults(func=cmd_create)

    p = sub.add_parser("ensure", help="批量补齐 globalParams + 调度 + 上线")
    p.add_argument("--apply", action="store_true", help="真的执行（默认干跑）")
    p.add_argument("--offline", action="store_true", help="建调度但不上线")
    p.add_argument("--check", action="store_true", help="只校验现状")
    p.add_argument("--skip-params", action="store_true")
    p.set_defaults(func=cmd_ensure)

    p = sub.add_parser("switch", help="按 id/前缀/全名 批量上·下线")
    p.add_argument("--list", action="store_true")
    p.add_argument("--id", help="调度 id，如 6-42 或 1,3,5")
    p.add_argument("--prefix", help="按工作流名前缀筛选")
    p.add_argument("--name", help="按工作流全名筛选")
    p.add_argument("--online", action="store_true")
    p.add_argument("--offline", action="store_true")
    p.add_argument("--apply", action="store_true", help="真的执行（默认干跑）")
    p.set_defaults(func=cmd_switch)

    p = sub.add_parser("release", help="查看 / 上·下线（走 REST）")
    p.add_argument("--online", action="store_true", help="上线")
    p.add_argument("--offline", action="store_true", help="下线")
    p.add_argument("--id", type=int, help="只处理指定 schedule id")
    p.set_defaults(func=cmd_release)

    args = ap.parse_args()
    return args.func(args) or 0


if __name__ == "__main__":
    raise SystemExit(main())
