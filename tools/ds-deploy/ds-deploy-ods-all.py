#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把所有系统的 ODS 抽数脚本批量落成 DolphinScheduler 工作流。

背景
----
DS 现状：只有 HSFA 的 78 个 ODS 脚本进了工作流（`ods_hsfa_etl_01..05`）。
本工具把其余 8 个系统（HSDS/HSFTA/HSZTA/JY/O32/OA/OFFW/WIND，共 441 个脚本）
按同样的约定落到 DS。

约定（与现有 `ods_hsfa_etl_01..05` 完全一致，实测得来）
-----------------------------------------------------
· 每 20 个脚本一个工作流，命名 **`ods_<sys 小写>_etl_NN`**
· 一个脚本 = 一个 SHELL 任务，任务名 = 脚本名去掉 `.sh`
· **rawScript = 脚本文件内容整体内联**（不是 `bash ./xxx.sh`！worker 里根本没有这些文件）
  已验证：`ods_hsfa_etl_01` 的任务 rawScript 开头就是 `#!/bin/sh\n#初始化环境变量：\nsource ...`
· 任务关系 **零连线**（preTaskCode 全 0），执行方式 `SERIAL_WAIT`
  ⇒ 靠工作流级串行控制，不靠 DAG 连线
· 工作流级参数 `p_start_dt` / `p_end_dt`（VARCHAR，yyyymmdd）
· 租户 `dolphinscheduler`（本集群 default 租户已禁用）

用法
----
    python tools/ds-deploy-ods-all.py --dry-run              # 只打印计划
    python tools/ds-deploy-ods-all.py                        # 建 + 上线（8 个系统）
    python tools/ds-deploy-ods-all.py --systems HSZTA,HSFTA  # 只做某几个系统
    python tools/ds-deploy-ods-all.py --exclude O32 --offline
    python tools/ds-deploy-ods-all.py --include-hsfa          # 连 HSFA 一起重建（⚠️ 会打掉其定时调度）
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from ds_config import ds_admin_password, ds_admin_user  # noqa: E402
from ds_client import legacy_client  # noqa: E402
from ds_text import read_script  # noqa: E402

DS = "http://127.0.0.1:12345/dolphinscheduler"
USER = ds_admin_user()
PWD = ds_admin_password()
DEFAULT_PROJECT = "dw"

REPO = os.environ.get("DW_REPO", os.path.dirname(os.path.dirname(HERE)))
ODS_REL = os.path.join("scripts", "{sys}", "ods", "etl_sh")

ALL_SYSTEMS = ["HSDS", "HSFA", "HSFTA", "HSZTA", "JY", "O32", "OA", "OFFW", "WIND"]
# 已完整部署（78/78）——默认跳过，避免打掉它 02:00~03:00 的定时调度
DONE_SYSTEMS = {"HSFA"}

EXEC = "SERIAL_WAIT"          # 实测：现有 HSFA 工作流就是这个值
TENANT = "dolphinscheduler"   # 本集群 default 租户已禁用

# ★★ 2026-10-15：ODS 排版参数 —— 与 `ds-relayout.py ods` 的默认值**同源**，
#    改这里必须同步改 ds-relayout.py（ods 分支默认）与 ds-rebuild-from-inventory.py，
#    否则「导入出的图」与「relayout 的目标图」又会分叉。
ODS_X0, ODS_Y0 = 40, 80       # = ds_relayout 用的 D.X0 / D.Y0
ODS_COL_W = 416               # 416 = 节点宽 350 + 66px 间隙
ODS_ROW_H = 120
ODS_PER_ROW = 3               # 每排 3 个（relayout ods 的默认 per_row）

# ★ 2026-10-15：HTTP 层改用 ds_client（原先自写 urllib）——
#   磁盘会话复用 + 401 自动重登 + 超时重试；本文件不再自实现 _raw/call/login。
_ds = None


def _client():
    global _ds
    if _ds is None:
        _ds = legacy_client(base=DS, user=USER, password=PWD,
                            allow_admin=True, timeout=300)
    return _ds


def _raw(method, path, params=None, form=None):
    """不重试版本（等价于旧 `_raw`）：401 直接返回 None/抛错，不重登。"""
    return _client().call(method, path, params=params, form=form, _retry=False)


def call(method, path, params=None, form=None, _retry=True):
    return _client().call(method, path, params=params, form=form, _retry=_retry)


def login():
    try:
        return _client().login()
    except Exception as e:
        sys.exit("登录失败: %s" % e)


def ensure_project(name):
    res = call("GET", "/projects/list", params={"searchVal": name, "pageSize": 50, "pageNo": 1})
    d = res.get("data")
    items = d.get("totalList") if isinstance(d, dict) else d
    for p in items or []:
        if p.get("name") == name:
            return p["code"]
    sys.exit(f"项目 {name} 不存在")


def list_wf(project_code, search=""):
    res = call("GET", f"/projects/{project_code}/workflow-definition",
               params={"pageNo": 1, "pageSize": 500, "searchVal": search})
    d = res.get("data") or {}
    return d.get("totalList") if isinstance(d, dict) else d


def drop_wf(project_code, name):
    """同名工作流先下线再删（可重复执行）。

    ★★★ 删除会失败如果该工作流正被别的任务的 DEPENDENT 节点引用：
        `10000 workflow definition cannot be deleted because it has dependent,
         ... used by other tasks: <wf>:depend_on_upstream`
        ⇒ 必须先删掉引用方（如 DWD_PROD），否则这里会**静默留下旧工作流**，
          随后 create 报 `10168 ... already exists`。所以这里显式检查返回码。
    """
    for it in list_wf(project_code, name) or []:
        if it.get("name") != name:
            continue
        print(f"      (清理同名旧工作流 code={it['code']} "
              f"release={it.get('releaseState')} schedule={it.get('scheduleReleaseState')})")
        call("POST", f"/projects/{project_code}/workflow-definition/{it['code']}/release",
             form={"releaseState": "OFFLINE"})
        res = call("DELETE", f"/projects/{project_code}/workflow-definition/{it['code']}")
        if res.get("code") != 0:
            sys.exit(f"       !! 删除 {name}(code={it['code']}) 失败: "
                     f"{json.dumps(res, ensure_ascii=False)[:300]}\n"
                     f"       → 多半是被别的 DEPENDENT 节点引用，先删掉引用方再重试")


# --------------------------------------------------------------------------- #
def collect(sys_name, repo):
    d = os.path.join(repo, ODS_REL.format(sys=sys_name))
    if not os.path.isdir(d):
        return []
    out = []
    for fn in sorted(os.listdir(d)):
        if not fn.endswith(".sh") or fn.startswith("."):
            continue
        if "deploy-to-worker" in fn:          # 部署辅助脚本，不是抽数作业
            continue
        out.append((fn[:-3], os.path.join(d, fn)))
    return out


def build_task(code, name, path):
    # ★ 2026-10-22：改用共用的 ds_text.read_script（统一 CRLF→LF 行尾，
    #   避免 Windows 源的 CRLF 被内联进 DS rawScript 后在 Linux worker 上
    #   报 bad interpreter / 命令未找到）
    script = read_script(path)
    return {
        "code": code,
        "name": name,
        "version": 1,
        "description": f"ODS 抽数 {name}",
        "delayTime": 0,
        "taskType": "SHELL",
        "taskParams": {"rawScript": script, "localParams": [], "resourceList": [],
                       "dependence": {}},
        "flag": "YES",
        "taskPriority": "MEDIUM",
        "workerGroup": "default",
        "environmentCode": -1,
        "failRetryTimes": 0,
        "failRetryInterval": 1,
        "timeoutFlag": "CLOSE",
        "timeoutNotifyStrategy": "",
        "timeout": 0,
        "resourceIds": "",
        "dependence": {},
        "waitStartTimeout": {},
        "conditionResult": {"successNode": [], "failedNode": []},
    }


def build_relations(codes):
    """零连线：每个任务的前驱都是 0（靠工作流级 SERIAL_WAIT 串行）。"""
    return [{"name": "", "preTaskCode": 0, "preTaskVersion": 0,
             "postTaskCode": c, "postTaskVersion": 1,
             "conditionType": "NONE", "conditionParams": {}} for c in codes]


def build_locations(codes):
    # ★ 2026-10-07：列间距 260 → 333 → **416**（260 < 节点宽会左右叠）。
    #   ★★ 节点宽同日 400→267→**350** ⇒ 333 < 350 会叠 17px，用户拍板把 ODS 抬到 416
    #      （416 = 350 + 66，保持原「267/333 时代」的 66px 间隙观感）。
    # ★★ 2026-10-15：坐标系与列数改为与 `ds-relayout.py ods` **完全一致**
    #    （X0=40 / Y0=80 / ROW_H=120 / 每排 3 列 / 间距 416）。
    #    旧值 `x=260+(i%4)*416, y=140+(i//4)*110` 是「每排 4 列 + 起点 260,140」，
    #    与 relayout 的目标排版不同 ⇒ 导入完还得再跑一次 relayout 才达标。
    #    统一后 **导入即最终排版**（线上现存 ODS 工作流实测就是 40/456/872 & 80,200,…）。
    return [{"taskCode": c, "x": ODS_X0 + (i % ODS_PER_ROW) * ODS_COL_W,
             "y": ODS_Y0 + (i // ODS_PER_ROW) * ODS_ROW_H}
            for i, c in enumerate(codes)]


def global_params(start_dt, end_dt):
    return json.dumps([
        {"prop": "p_start_dt", "direct": "IN", "type": "VARCHAR", "value": start_dt},
        {"prop": "p_end_dt", "direct": "IN", "type": "VARCHAR", "value": end_dt},
    ], ensure_ascii=False)


# --------------------------------------------------------------------------- #
def main():
    ap = argparse.ArgumentParser(description="把所有系统的 ODS 脚本落成 DS 工作流")
    ap.add_argument("--repo", default=REPO)
    ap.add_argument("--project", default=DEFAULT_PROJECT)
    ap.add_argument("--size", type=int, default=20, help="每个工作流的作业数（默认 20）")
    ap.add_argument("--systems", default="", help="逗号分隔，默认除 HSFA 外全部")
    ap.add_argument("--exclude", default="", help="逗号分隔，排除某些系统")
    ap.add_argument("--include-hsfa", action="store_true",
                    help="连 HSFA 一起重建（⚠️ 会删掉现有 5 个工作流及其定时调度）")
    # ★ 2026-10-07：默认值必须 = 线上现值 `${system.biz.date}`（系统时间-1，yyyyMMdd）。
    #   线上 31 个 ODS 已由 tools/ds-ods-param-bizdate.py 从 20260901/20260928 改过来；
    #   这里若留旧字面量，任何一次裸跑重建都会把它们拉回停在 9 月（默认值对齐铁律）。
    #   实测证据见 tools/ds-ods-param-bizdate.py 顶部 + .dx-tmp/param-probe.py。
    ap.add_argument("--start-dt", default="${system.biz.date}",
                    help="p_start_dt，默认 系统时间-1（DS 内置，yyyyMMdd）")
    ap.add_argument("--end-dt", default="${system.biz.date}",
                    help="p_end_dt，默认 系统时间-1（DS 内置，yyyyMMdd）")
    ap.add_argument("--offline", dest="online", action="store_false", default=True,
                    help="只建不上线")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    if args.systems:
        systems = [s.strip().upper() for s in args.systems.split(",") if s.strip()]
    else:
        systems = [s for s in ALL_SYSTEMS if args.include_hsfa or s not in DONE_SYSTEMS]
    if args.exclude:
        ex = {s.strip().upper() for s in args.exclude.split(",") if s.strip()}
        systems = [s for s in systems if s not in ex]

    plan = []
    for s in systems:
        files = collect(s, args.repo)
        if not files:
            print(f"!! {s}: 未找到 ODS 脚本，跳过")
            continue
        chunks = [files[i:i + args.size] for i in range(0, len(files), args.size)]
        plan.append((s, chunks))
        print(f"  {s:6s} {len(files):3d} 个脚本 → {len(chunks)} 个工作流 "
              f"({', '.join('ods_%s_etl_%02d:%d' % (s.lower(), i + 1, len(c)) for i, c in enumerate(chunks))})")

    total_wf = sum(len(c) for _, c in plan)
    total_task = sum(len(f) for _, c in plan for f in c)
    print(f"\n合计 {len(plan)} 个系统 / {total_wf} 个工作流 / {total_task} 个任务")

    if args.dry_run:
        print("\n--- dry-run，不动 DS ---")
        return 0

    print("\n[1/4] 登录 DS")
    login()
    print("[2/4] 定位项目")
    pcode = ensure_project(args.project)
    print(f"      {args.project} code={pcode}")

    base = int(time.time() * 1000) % 10 ** 9
    created = []
    print(f"\n[3/4] 创建 {total_wf} 个工作流（OFFLINE）")
    for si, (sys_name, chunks) in enumerate(plan):
        for ci, chunk in enumerate(chunks, 1):
            wf = f"ods_{sys_name.lower()}_etl_{ci:02d}"
            drop_wf(pcode, wf)
            codes = [base + si * 100000 + ci * 1000 + j for j in range(len(chunk))]
            tasks = [build_task(codes[j], chunk[j][0], chunk[j][1]) for j in range(len(chunk))]
            res = call("POST", f"/projects/{pcode}/workflow-definition", form={
                "name": wf,
                "description": f"{sys_name} ODS 抽数 第 {ci}/{len(chunks)} 批（{len(chunk)} 个作业）",
                "globalParams": global_params(args.start_dt, args.end_dt),
                "locations": json.dumps(build_locations(codes)),
                "timeout": 0,
                "tenantCode": TENANT,
                "taskRelationJson": json.dumps(build_relations(codes)),
                "taskDefinitionJson": json.dumps(tasks, ensure_ascii=False),
                "executionType": EXEC,
                "releaseState": "OFFLINE",
            })
            if res.get("code") != 0:
                print(f"      !! {wf} 失败: {json.dumps(res, ensure_ascii=False)[:300]}")
                continue
            created.append(wf)
            print(f"      {wf}: {len(chunk)} 个任务 code={res['data']['code']}")

    if not args.online:
        print("\n[4/4] 按要求保持 OFFLINE")
        return 0

    print(f"\n[4/4] 上线 {len(created)} 个工作流")
    ok = 0
    for wf in created:
        code = next((it["code"] for it in (list_wf(pcode, wf) or []) if it["name"] == wf), None)
        if code is None:
            print(f"      !! {wf} 找不到，跳过上线")
            continue
        res = call("POST", f"/projects/{pcode}/workflow-definition/{code}/release",
                   form={"releaseState": "ONLINE"})
        if res.get("code") == 0:
            ok += 1
        else:
            print(f"      !! {wf} 上线失败: {json.dumps(res, ensure_ascii=False)[:200]}")
    print(f"      上线成功 {ok}/{len(created)}（未挂任何定时调度，不会自动跑）")
    print(f"\n完成。项目 {args.project} code={pcode}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
