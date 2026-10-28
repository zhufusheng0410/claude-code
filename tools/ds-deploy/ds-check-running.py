#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""★ 动任何工作流/容器之前的**必做检查**：DS 里有没有正在跑的实例。

★★★ 为什么必须先查：宿主唤醒后 master 会**自动续跑 RUNNING 态实例**。
此时删工作流 / 重启容器会把跑到一半的作业打断，而且**不会有任何报错**。

用法
----
    python tools/ds-check-running.py            # 只看 dw 项目
    python tools/ds-check-running.py --all      # 看所有项目
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_config import ds_admin_password, ds_admin_user  # noqa: E402
from ds_client import legacy_client  # noqa: E402

DS = "http://localhost:12345/dolphinscheduler"
USER = ds_admin_user()
PWD = ds_admin_password()

# ★ 2026-10-15：HTTP 层改用 ds_client（原先自写 urllib）——
#   磁盘会话复用 + 401 自动重登 + 超时重试（原 raw() 没有任何 401 重试）。
_ds = None


def _client():
    global _ds
    if _ds is None:
        _ds = legacy_client(base=DS, user=USER, password=PWD,
                            allow_admin=True, timeout=120)
    return _ds

# ★ 终态：只有 SUCCESS / FAILURE 算「跑完了」。
#   ★★ `state` 在列表接口里返回的是**字符串**（"SUCCESS"），在元库 `t_ds_workflow_instance`
#   里是**数字**（6/7）⇒ 两种都要认，别只判一种（只判数字会把 12 个成功实例误报成跑批）。
TERMINAL = {6, 7, "SUCCESS", "FAILURE"}
STATE_CN = {"SUBMITTED_SUCCESS": "提交成功", "RUNNING_EXECUTION": "运行中",
            "READY_PAUSE": "准备暂停", "PAUSE": "暂停", "READY_STOP": "准备停止",
            "STOP": "停止", "SUCCESS": "成功", "FAILURE": "失败",
            "DELAY_EXECUTION": "延迟执行", "SERIAL_WAIT": "串行等待",
            "WAITING_THREAD": "等待依赖", "READY_BLOCK": "准备阻塞", "BLOCK": "阻塞",
            "KILL": "Kill"}


def raw(method, path, params=None, form=None):
    """不重试版本（等价旧 raw）：401 不重登。"""
    return _client().call(method, path, params=params, form=form, _retry=False)


def lst_of(res):
    """DS 的分页返回有时是 list、有时是 {'totalList': [...]} ⇒ 两种都接。"""
    d = res.get("data")
    return d.get("totalList") if isinstance(d, dict) else (d or [])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--all", action="store_true", help="检查所有项目（默认只看 dw）")
    args = ap.parse_args()

    try:
        _client().login()
    except Exception as e:
        sys.exit("登录失败: %s" % e)

    projs = lst_of(raw("GET", "/projects/list", params={"pageSize": 100, "pageNo": 1}))
    if not args.all:
        projs = [p for p in projs if p["name"] == "dw"]

    total_run = 0
    for p in projs:
        insts = lst_of(raw("GET", f"/projects/{p['code']}/workflow-instances",
                           params={"pageNo": 1, "pageSize": 200}))
        run = [i for i in insts if i.get("state") not in TERMINAL]
        total_run += len(run)
        flag = "⚠ 有跑批" if run else "✓ 空闲"
        print(f"{p['name']:12s} code={p['code']}  实例 {len(insts):3d} 个  {flag}")
        for i in run[:20]:
            st = i.get("state")
            print(f"     - {i.get('name')}  state={st}({STATE_CN.get(st, st)})")
    print(f"\n未结束实例合计 {total_run} 个" + ("（可以动手）" if not total_run
                                          else "  ★★★ 先等跑完再动"))
    return 0 if not total_run else 1


if __name__ == "__main__":
    sys.exit(main())
