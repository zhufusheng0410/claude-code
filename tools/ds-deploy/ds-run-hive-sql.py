# -*- coding: utf-8 -*-
"""
端到端验证：用刚建好的 Kerberos HIVE 数据源在 DolphinScheduler 里跑一条 SQL。

流程：建项目 → 建工作流（单个 SQL 任务）→ 上线 → 启动实例 → 轮询直到终态。
用法：
  python tools/ds-run-hive-sql.py [SQL] [--datasource hive_krb] [--project hive_ds_verify]
"""
import argparse
import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_client import legacy_client  # noqa: E402
from ds_config import ds_admin_password, ds_admin_user  # noqa: E402

BASE = "http://127.0.0.1:12345/dolphinscheduler"
USER = ds_admin_user()
PWD = ds_admin_password()
# 本集群里租户 default 是禁用的，用真实租户
TENANT = "dolphinscheduler"

# ★ 2026-10-15：HTTP 层改用 ds_client（原先自写 urllib）——
#   磁盘会话复用 + 401 自动重登（比原「只重试一次」更强）+ 超时重试。
_ds = None


def _client():
    global _ds
    if _ds is None:
        _ds = legacy_client(base=BASE, user=USER, password=PWD,
                            allow_admin=True, timeout=180)
    return _ds


def parse_args():
    ap = argparse.ArgumentParser()
    ap.add_argument("sql", nargs="?", default="select 'hdfs' as src, count(1) as c from db_demo.tb_hdfs")
    ap.add_argument("--datasource", default="hive_krb", help="数据源名（默认 hive_krb = xdaydw）")
    ap.add_argument("--project", default="hive_ds_verify", help="验证用项目名")
    return ap.parse_args()


def login():
    """建立/复用会话，返回 sessionId。

    ⚠️ DS 3.4.x **同一用户只保留一个有效会话**：再登录一次会立刻顶掉上一个
    （2026-09-22 实测：登录 A → A 可用；再登录 B → B 可用、**A 立刻 401**）。
    所以**并发跑多个 ds-*.py（都用 admin 登录）会互相踢**。
    ds_client 会优先复用磁盘会话（降低重登频率），并在 401 时自动重登重试。
    """
    return _client().login()


def call(method, path, form=None, body=None, params=None, _retry=True):
    return _client().call(method, path, form=form, body=body, params=params,
                          _retry=_retry)


def cleanup_workflow(project_code, pd_code):
    """跑完即删：先下线（ONLINE 才能删）再 DELETE，失败仅告警不中断。"""
    print(f"清理临时工作流 code={pd_code} ...")
    call("POST", f"/projects/{project_code}/workflow-definition/{pd_code}/release",
         form={"releaseState": "OFFLINE"})
    r = call("DELETE", f"/projects/{project_code}/workflow-definition/{pd_code}")
    print(f"  {'✓ 已删除' if r.get('code') == 0 else '⚠ 删除返回 ' + str(r.get('msg'))}")


def main():
    global SQL
    args = parse_args()
    SQL = args.sql
    login()
    print("登录成功")

    # 1) 项目
    pname = args.project
    project_code = None
    lst = call("GET", "/projects/list", params={"searchVal": pname, "pageSize": 50, "pageNo": 1})
    # /projects/list 的 data 有时是数组、有时是 {totalList:[...]}，两种都兼容
    raw_data = lst.get("data") or []
    items = raw_data.get("totalList", []) if isinstance(raw_data, dict) else raw_data
    for p in items:
        if p.get("name") == pname:
            project_code = p["code"]
    if project_code:
        print(f"复用项目 {pname} code={project_code}")
    else:
        # 注意：/projects 用的是 form 参数（@RequestParam），且字段叫 projectName
        res = call("POST", "/projects", form={"projectName": pname, "description": "数据源中心 Hive Kerberos 端到端验证"})
        project_code = res["data"]["code"]
        print(f"新建项目 {pname} code={project_code}")

    # 2) 数据源 id
    ds = call("GET", "/datasources/list", params={"type": "HIVE", "searchVal": args.datasource})
    ds_id = None
    for d in ds.get("data", []) or []:
        if d.get("name") == args.datasource:
            ds_id = d["id"]
    if not ds_id:
        print("找不到数据源 hive_krb，先跑 ds-create-hive-datasource.py")
        return 2
    print(f"数据源 id={ds_id}")

    task_code = int(time.time() * 1000) % 10**9
    task_def = [{
        "code": task_code,
        "name": "hive_sql",
        "version": 1,
        "description": "",
        "taskType": "SQL",
        "taskParams": {
            "type": "HIVE",
            "datasource": ds_id,
            "sql": SQL,
            "sqlType": "1",
            "preStatements": [],
            "postStatements": [],
            "segmented": False,
            "displayRows": 10,
            "localParams": [],
            "varPool": [],
        },
        "flag": "YES",
        "taskPriority": "MEDIUM",
        "workerGroup": "default",
        "environmentCode": -1,
        "failRetryTimes": "0",
        "failRetryInterval": "1",
        "timeoutFlag": "CLOSE",
        "timeoutNotifyStrategy": "WARN",
        "timeout": "0",
        "delayTime": "0",
        "resourceIds": [],
        "dependence": {},
        "waitStartTimeout": {},
        "conditionResult": {"successNode": [], "failedNode": []},
    }]
    relation = [{
        "name": "",
        "preTaskCode": 0,
        "preTaskVersion": 0,
        "postTaskCode": task_code,
        "postTaskVersion": 1,
        "conditionType": "NONE",
        "conditionParams": {},
    }]

    pdname = "hive_sql_verify_%d" % (task_code % 100000)
    # 注意：这个接口收 form 参数（@RequestParam），几个 JSON 是以字符串形式传的
    res = call("POST", f"/projects/{project_code}/workflow-definition", form={
        "name": pdname,
        "description": "数据源中心 Hive Kerberos 端到端验证",
        "globalParams": "[]",
        "locations": "[]",
        "timeoutFlag": "CLOSE",
        "timeoutNotifyStrategy": "",
        "timeout": 0,
        "executionType": "PARALLEL",
        "taskRelationJson": json.dumps(relation),
        "taskDefinitionJson": json.dumps(task_def),
        "otherParamsJson": "",
        "releaseState": "OFFLINE",
    })
    if not (res.get("data") or {}).get("code"):
        print("建工作流失败，响应：", json.dumps(res, ensure_ascii=False)[:600])
        return 2
    pd_code = res["data"]["code"]
    print(f"工作流已建：{pdname} code={pd_code}")

    # 3) 上线：/{code}/release 收的是 form 参数（@RequestParam releaseState）
    res = call("POST", f"/projects/{project_code}/workflow-definition/{pd_code}/release",
               form={"releaseState": "ONLINE"})
    if res.get("code") != 0:
        print("上线失败，响应：", json.dumps(res, ensure_ascii=False)[:600])
        cleanup_workflow(project_code, pd_code)
        return 2
    print(f"已上线（{pdname}）")

    # 4) 启动实例
    #    端点必须是 /executors/start-workflow-instance（form 参数）。
    #    /executors/execute 是"控制实例"（暂停/停止等），它要 workflowInstanceId，别用错。
    res = call("POST", f"/projects/{project_code}/executors/start-workflow-instance", form={
        "workflowDefinitionCode": pd_code,
        "scheduleTime": "",
        "failureStrategy": "CONTINUE",
        "startNodeList": "",
        "taskDependType": "TASK_POST",
        "execType": "START_PROCESS",
        "warningType": "NONE",
        "warningGroupId": 0,
        "runMode": "RUN_MODE_SERIAL",
        "workflowInstancePriority": "MEDIUM",
        "workerGroup": "default",
        # 租户 default 在本集群是禁用的，必须用真实租户 dolphinscheduler
        "tenantCode": TENANT,
        "environmentCode": -1,
        "startParams": "",
        "expectedParallelismNumber": 1,
        "dryRun": 0,
        "complementDependentMode": "OFF_MODE",
        "allLevelDependent": "false",
        "executionOrder": "DESC_ORDER",
    })
    if res.get("code") != 0:
        print("启动实例失败，响应：", json.dumps(res, ensure_ascii=False)[:600])
        cleanup_workflow(project_code, pd_code)
        return 2
    inst_id = (res.get("data") or [None])[0]
    if not inst_id:
        print("启动实例未返回 id，响应：", json.dumps(res, ensure_ascii=False)[:600])
        cleanup_workflow(project_code, pd_code)
        return 2
    print(f"实例已启动 id={inst_id}")

    # 5) 轮询
    for i in range(40):
        time.sleep(5)
        try:
            info = call("GET", f"/projects/{project_code}/workflow-instances/{inst_id}")
            st = (info.get("data") or {}).get("state")
        except Exception:
            continue
        print(f"    [{i*5}s] state={st}")
        if st in ("SUCCESS", "FAILURE", "STOP", "CANCELED"):
            if st == "SUCCESS":
                print("\n✅ SQL 任务执行成功 —— 数据源中心 Hive(Kerberos) 端到端打通")
                print(f"    SQL: {SQL}")
                print(f"    DS UI: {BASE}/ui/projects/{project_code}/workflow/instances/{inst_id}")
                cleanup_workflow(project_code, pd_code)
                return 0
            print(f"\n❌ 实例终态 {st}，去 UI 看日志：{BASE}/ui/projects/{project_code}/workflow/instances/{inst_id}")
            cleanup_workflow(project_code, pd_code)
            return 1
    print("轮询超时，未到终态")
    cleanup_workflow(project_code, pd_code)
    return 3


if __name__ == "__main__":
    raise SystemExit(main())
