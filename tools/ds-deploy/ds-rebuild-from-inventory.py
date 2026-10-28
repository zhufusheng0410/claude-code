#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""ds-rebuild-from-inventory.py —— 按「原有工作流清单」重建 DS 定义层。

背景
----
2026-10-08 DS 定义层被有意清空（42 工作流 / 729 任务 / 42 调度），原因是
`DWD_CHNL`/`DWD_PROD`/`DWD_SCR` 的 DEPENDENT 自环导致 API 删不掉
（详见 `/mnt/d/datax/.dx-tmp/ds-wipe-sql.py` 与 MEMORY.md）。备份
`/mnt/d/datax/.dx-tmp/backup-ds-20261008-154010.sql` 保存了全部定义。

本脚本**不用「每 20 个脚本」硬推**，而是：
  1) 从备份 pg_dump 里读出「每个工作流的任务清单（按创建序）」，
     即权威的**原有切分**（HSFA 特殊：18/18/18/18/6，不是 20/20/…）；
  2) 用当前 `scripts/<sys>/ods/etl_sh/*.sh` 的内容去填每个任务；
  3) 任务名若因生成器改名而变（OA/OFFW 加了 `_PFD`），做「按序对齐」，
     并报告改名对照表；
  4) DWD 层的 SHELL 脚本从 `scripts/<sys>/dwd/etl_sh/` 取（依赖节点沿用备份）。

为什么必须从备份驱动切分
------------------------
`ds-deploy-ods-all.py --size 20` 对 8/9 个系统能复现原切分，**但 HSFA 会从
5 个工作流塌成 4 个**（18/18/18/18/6 → 20/20/20/18），破坏「不增删工作流」。

用法
----
    python ds-rebuild-from-inventory.py --plan          # 只打印重建计划
    python ds-rebuild-from-inventory.py --plan --sys O32 # 只看某系统
    python ds-rebuild-from-inventory.py --apply         # 真正重建（OFFLINE）
    python ds-rebuild-from-inventory.py --apply --online
    python ds-rebuild-from-inventory.py --apply --no-dwd  # 只建 ODS

安全
----
· 默认 `--plan`（干跑）；`--apply` 才写 DS。
· ⚠️ 会先删除同名工作流再创建（幂等，可重复跑）。删除前检查是否有
  DEPENDENT 引用 —— 若 DWD 引用 ODS，**必须先建 ODS 再建 DWD**（本脚本
  已按此顺序）。
· 建完状态 OFFLINE（与清空前一致），不挂任何定时调度。
"""
import argparse
import collections
import json
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from ds_client import DSClient  # noqa: E402
from ds_config import ds_admin_password, ds_admin_user, pg_conn  # noqa: E402
from ds_text import read_script  # noqa: E402

sys.stdout.reconfigure(encoding="utf-8")

REPO = os.environ.get("DW_REPO", os.path.dirname(os.path.dirname(HERE)))
DUMP = os.environ.get(
    "DW_DS_DUMP", "/mnt/d/datax/.dx-tmp/backup-ds-20261008-154010.sql")
PROJECT = os.environ.get("DW_DS_PROJECT", "dw")
TENANT = "dolphinscheduler"
EXEC = "SERIAL_WAIT"

SYS_ORDER = ["HSDS", "HSFA", "HSFTA", "HSZTA", "JY", "O32", "OA", "OFFW", "WIND"]
_END = "\\."


# --------------------------------------------------------------------------- #
# 1. 读备份，取「原有清单」
# --------------------------------------------------------------------------- #
def _iter_copy(lines, prefix):
    i = 0
    while i < len(lines):
        if lines[i].startswith("COPY public." + prefix + " "):
            j = i + 1
            while j < len(lines) and lines[j] != _END:
                yield lines[j].split("\t")
                j += 1
            return
        i += 1


def load_inventory(dump_path):
    """→ (ods, dwd, dep_items)

    ods: {wf: [(task_name, task_type), ...]}
    dwd: {wf: [(task_name, task_type), ...]}
    dep_items: {(wf, dep_name): [(定义工作流名, 依赖任务名, cycle, dateValue), ...]}
               ★ 依赖条目按**名字**保存（因为重建后 code 全变）。
    """
    with open(dump_path, "rb") as f:
        lines = f.read().decode("utf-8", "replace").split("\n")

    wf_name = {f[1]: f[2] for f in _iter_copy(lines, "t_ds_workflow_definition")}
    task_name = {f[1]: f[2] for f in _iter_copy(lines, "t_ds_task_definition")}
    task_type = {f[1]: f[7] for f in _iter_copy(lines, "t_ds_task_definition")}
    task_params = {f[1]: f[9] for f in _iter_copy(lines, "t_ds_task_definition")}

    # 旧 code → 名字（供依赖重写）
    code2name = dict(task_name)
    code2wf = {}

    rows = []
    for f in _iter_copy(lines, "t_ds_workflow_task_relation"):
        rows.append((int(f[0]), f[3], f[5], f[7]))   # id, wf, pre, post
    rows.sort()

    ods = collections.OrderedDict()
    dwd = collections.OrderedDict()
    for _id, wfcode, pre, post in rows:
        nm = wf_name.get(wfcode)
        if not nm or not post or post == "0":
            continue
        tname = task_name.get(post)
        ttype = task_type.get(post)
        code2wf[post] = nm
        if nm.lower().startswith("ods_"):
            ods.setdefault(nm, []).append((tname, ttype))
        elif nm.startswith("DWD_"):
            dwd.setdefault(nm, []).append((tname, ttype))

    # 解析依赖节点
    dep_items = {}
    for wfcode, wfnm in wf_name.items():
        pass
    for tcode, tname in task_name.items():
        if not (tname or "").startswith("dep_"):
            continue
        try:
            tp = json.loads(task_params.get(tcode) or "{}")
        except Exception:
            continue
        dep = tp.get("dependence") or {}
        items = []
        for grp in dep.get("dependTaskList") or []:
            for it in grp.get("dependItemList") or []:
                dcode = it.get("definitionCode")
                tcode_dep = it.get("depTaskCode")
                items.append({
                    "wf": wf_name.get(str(dcode)) or wf_name.get(dcode)
                          or code2wf.get(dcode),
                    "task": task_name.get(str(tcode_dep))
                            or task_name.get(tcode_dep),
                    "cycle": it.get("cycle", "day"),
                    "dateValue": it.get("dateValue", "today"),
                })
        # 该 dep 属于哪个 DWD 工作流：从关系表的 post 反推
        owner = None
        for _id, w, pre, post in rows:
            if post == tcode:
                owner = wf_name.get(w)
                break
        if owner:
            dep_items[(owner, tname)] = items
        else:
            dep_items[("*", tname)] = items

    def ods_key(n):
        m = re.match(r"ods_([a-z0-9]+)_etl_(\d+)$", n)
        return (SYS_ORDER.index(m.group(1).upper())
                if m and m.group(1).upper() in SYS_ORDER else 99,
                int(m.group(2)) if m else 99)

    ods = collections.OrderedDict(sorted(ods.items(), key=lambda kv: ods_key(kv[0])))
    dwd = collections.OrderedDict(sorted(dwd.items()))
    return ods, dwd, dep_items


# --------------------------------------------------------------------------- #
# 2. 本地脚本发现
# --------------------------------------------------------------------------- #
def collect_scripts(sys_name, layer):
    """返回 [(name, path), ...]，按文件名排序。跳过部署辅助脚本。

    ★ 两种目录约定：
      · ODS：`scripts/<sys>/ods/etl_sh/*.sh`
      · DWD：脚本**分散在各系统的** `scripts/<sys>/dwd/02_etl/*.sh`
             （HSFA/HSZTA/MASTER/O32 … 都有，脚本名前缀才决定归属）
             ⇒ layer="dwd" 且 sys_name="*" 时合并全部系统。
    """
    if layer == "ods":
        dirs = [os.path.join(REPO, "scripts", sys_name, "ods", "etl_sh")]
    else:
        sroot = os.path.join(REPO, "scripts")
        dirs = []
        if os.path.isdir(sroot):
            for s in sorted(os.listdir(sroot)):
                d = os.path.join(sroot, s, layer, "02_etl")
                if os.path.isdir(d):
                    dirs.append(d)

    out = []
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for fn in sorted(os.listdir(d)):
            if fn.startswith(".") or "deploy-to-worker" in fn or "deploy-lf" in fn:
                continue
            if not fn.endswith(".sh"):
                continue
            out.append((fn[:-3], os.path.join(d, fn)))
    return out


def _sys_of_wf(wf):
    m = re.match(r"ods_([a-z0-9]+)_etl_", wf)
    return m.group(1).upper() if m else None


def align_tasks(old_names, local, wf):
    """把备份里的老任务名对齐到当前本地脚本名。

    改名只会发生在「同系统内 base 名相同、只差 _PFD/_PTD 后缀」的情况
    （OA/OFFW 从裸名补全后缀）。做两步：
      A) 同名直配；
      B) 对剩余，用「去后缀后的基名」配对（保障顺序）。
    返回 [(task_name, script_path or None, note), ...]，长度 = len(old_names)。
    """
    by_name = dict(local)
    used = set()
    out = []

    def base(n):
        return re.sub(r"_(PFD|PTD)$", "", n)

    by_base = collections.defaultdict(list)
    for n, p in local:
        by_base[base(n)].append((n, p))

    for old in old_names:
        if old in by_name:
            out.append((old, by_name[old], ""))
            used.add(old)
            continue
        cands = [x for x in by_base.get(base(old), []) if x[0] not in used]
        if len(cands) == 1:
            n, p = cands[0]
            out.append((n, p, "renamed from %s" % old))
            used.add(n)
        else:
            out.append((old, None, "MISSING"))
    return out


# --------------------------------------------------------------------------- #
# 3. 构建 payload
# --------------------------------------------------------------------------- #
# ★ 2026-10-22：改用共用的 ds_text.read_script（统一 CRLF→LF 行尾，
#   避免 Windows 源的 CRLF 被内联进 DS rawScript 后在 Linux worker 上报错）。
#   原实现见 git 历史。


class _CodeAllocator:
    """DWD 任务 code 的全局唯一分配器。

    ★ 2026-10-22 新增（评审 HIGH-4 修 bug）：
      原实现按 `base + 700000000 + len(wf) * 200 + i` 分配 —— 偏移量取自
      **工作流名的长度**，于是两个同长度名的工作流（如 DWD_PROD / DWD_ACCT，
      均为 8 字符）拿到**完全相同**的 code 段。
      DS 项目内 task code 必须唯一 ⇒ 冲突后依赖回填会指向错误任务，
      或 PUT 直接失败，且故障表现与根因相隔很远，极难定位。

      本分配器改用**单调递增计数器**，保证：
        · 跨工作流唯一（不再依赖名字）
        · 单调递增（同一工作流内 code 有序，便于排版/排查）
        · 与 ODS 侧 code 段不重叠（独立号段，见 dwd_codes 实例化处）
    """

    def __init__(self, base: int, step: int = 1):
        self._cur = base
        self._step = step
        self._used = set()

    def next(self) -> int:
        """取下一个唯一 code。已用过的号直接跳过（防手工改动引入重复）。"""
        while self._cur in self._used:
            self._cur += self._step
        code = self._cur
        self._used.add(code)
        self._cur += self._step
        return code

    def reserve(self, code: int) -> None:
        """登记一个已占用的 code（供回填阶段避让）。"""
        self._used.add(code)


def shell_task(code, name, script):
    return {
        "code": code, "name": name, "version": 1,
        "description": ("ODS 抽数 " if name.upper().startswith("ODS_")
                        else "DWD 加工 ") + name,
        "delayTime": 0, "taskType": "SHELL",
        "taskParams": {"rawScript": script, "localParams": [],
                       "resourceList": [], "dependence": {}},
        "flag": "YES", "taskPriority": "MEDIUM", "workerGroup": "default",
        "environmentCode": -1, "failRetryTimes": 0, "failRetryInterval": 1,
        "timeoutFlag": "CLOSE", "timeoutNotifyStrategy": "", "timeout": 0,
        "resourceIds": "", "dependence": {}, "waitStartTimeout": {},
        "conditionResult": {"successNode": [], "failedNode": []},
    }


def dependent_task(code, name, items, loc_note=""):
    return {
        "code": code, "name": name, "version": 1,
        "description": "上游依赖 " + name,
        "delayTime": 0, "taskType": "DEPENDENT",
        "taskParams": {"dependence": {"dependTaskList": items,
                                      "relation": "AND"}},
        "flag": "YES", "taskPriority": "MEDIUM", "workerGroup": "default",
        "environmentCode": -1, "failRetryTimes": 0, "failRetryInterval": 1,
        "timeoutFlag": "CLOSE", "timeoutNotifyStrategy": "", "timeout": 0,
        "resourceIds": "", "dependence": {"dependTaskList": items,
                                          "relation": "AND"},
        "waitStartTimeout": {},
        "conditionResult": {"successNode": [], "failedNode": []},
    }


def ods_locations(codes):
    """ODS 网格坐标 —— 与 `ds-relayout.py ods` / `ds-deploy-ods-all.py` **同源**。

    ★★ 2026-10-15：旧值 `x=260+(i%4)*260, y=140+(i//4)*110` 有两个毛病：
      ① 260 间距 < 节点宽 350 ⇒ 节点左右重叠；
      ② 每排 4 列 / 起点 (260,140) 与 relayout 的目标（起点 (40,80)、每排 3 列、间距 416、
         行高 120）不一致 ⇒ 重建完还得再跑一次 relayout。
    现统一成 ODS 侧权威口径，**重建/导入即最终排版**。
    """
    return _grid_locations(codes, ODS_X0, ODS_Y0, ODS_COL_W, ODS_ROW_H, ODS_PER_ROW)


def dwd_grid_locations(codes):
    """DWD 阶段 1（只建 SHELL）的临时网格；间距 500 与 DWD 排版口径一致。"""
    return _grid_locations(codes, 40, 80, 500, 120, 4)


def _grid_locations(codes, x0, y0, col_w, row_h, per_row):
    return [{"taskCode": c, "x": x0 + (i % per_row) * col_w,
             "y": y0 + (i // per_row) * row_h}
            for i, c in enumerate(codes)]


# ODS 排版参数（改这里必须同步 ds-deploy-ods-all.py / ds-relayout.py 的 ods 分支）
ODS_X0, ODS_Y0 = 40, 80
ODS_COL_W, ODS_ROW_H, ODS_PER_ROW = 416, 120, 3


def build_relations(codes, edges):
    """edges: [(pre_code, post_code)]；pre=0 表示根。"""
    rels = []
    seen_root = set()
    for pre, post in edges:
        rels.append({"name": "", "preTaskCode": pre, "preTaskVersion":
                     0 if pre == 0 else 1, "postTaskCode": post,
                     "postTaskVersion": 1, "conditionType": "NONE",
                     "conditionParams": {}})
        if pre == 0:
            seen_root.add(post)
    for c in codes:
        if c not in seen_root:
            rels.append({"name": "", "preTaskCode": 0, "preTaskVersion": 0,
                         "postTaskCode": c, "postTaskVersion": 1,
                         "conditionType": "NONE", "conditionParams": {}})
    return rels


def global_params():
    return json.dumps([
        {"prop": "p_start_dt", "direct": "IN", "type": "VARCHAR",
         "value": "${system.biz.date}"},
        {"prop": "p_end_dt", "direct": "IN", "type": "VARCHAR",
         "value": "${system.biz.date}"},
    ], ensure_ascii=False)


# --------------------------------------------------------------------------- #
def drop_wf(ds, pcode, name):
    r = ds.call("GET", f"/projects/{pcode}/workflow-definition",
                params={"pageNo": 1, "pageSize": 50, "searchVal": name})
    d = r.get("data")
    items = d.get("totalList") if isinstance(d, dict) else (d or [])
    for it in items:
        if it.get("name") != name:
            continue
        ds.call("POST",
                f"/projects/{pcode}/workflow-definition/{it['code']}/release",
                form={"releaseState": "OFFLINE"})
        res = ds.call("DELETE",
                      f"/projects/{pcode}/workflow-definition/{it['code']}")
        if res.get("code") != 0:
            raise RuntimeError(
                f"删除 {name}(code={it['code']}) 失败: "
                f"{json.dumps(res, ensure_ascii=False)[:300]}")


def main():
    ap = argparse.ArgumentParser(description="按原有清单重建 DS 定义层")
    ap.add_argument("--dump", default=DUMP)
    ap.add_argument("--repo", default=REPO)
    ap.add_argument("--project", default=PROJECT)
    ap.add_argument("--sys", default="", help="只处理某系统（如 O32）")
    ap.add_argument("--no-dwd", action="store_true")
    ap.add_argument("--no-ods", action="store_true")
    ap.add_argument("--online", action="store_true",
                    help="建完上线（默认 OFFLINE）")
    ap.add_argument("--apply", action="store_true", help="真正写 DS")
    args = ap.parse_args()

    globals()["REPO"] = args.repo

    ods_inv, dwd_inv, dep_items = load_inventory(args.dump)
    print(f"备份清单：ODS {len(ods_inv)} 个工作流，"
          f"DWD {len(dwd_inv)} 个工作流")

    only = {s.strip().upper() for s in args.sys.split(",") if s.strip()}

    # ---------- 构建计划 ----------
    plan = []          # (wf_name, payload_dict)
    warnings = []
    base = int(time.time() * 1000) % 10 ** 9
    # ★ 2026-10-22：DWD 任务 code 改用全局唯一分配器（原式按 len(wf) 偏移会碰撞）
    dwd_codes = _CodeAllocator(base + 700000000)

    if not args.no_ods:
        per_sys_seq = collections.Counter()
        for wf, old_tasks in ods_inv.items():
            s = _sys_of_wf(wf)
            if not s or (only and s not in only):
                continue
            per_sys_seq[s] += 1
            seq = per_sys_seq[s]
            local = collect_scripts(s, "ods")
            local_by_name = dict(local)

            # ★ 首选：备份任务名 ∩ 本地当前脚本名（本次改名后仍存在的）
            direct = [(n, local_by_name[n], "") for n, _t in old_tasks
                      if n in local_by_name]
            renamed = [n for n, _t in old_tasks if n not in local_by_name]

            if not renamed:
                tasks = direct
                note = ""
            else:
                # 有改名：按「该工作流内、本地未被直接占用」的脚本补齐
                used = {n for n, _p, _d in direct}
                pool = [(n, p) for n, p in local if n not in used]
                tasks = list(direct)
                for old in renamed:
                    hit = None
                    for i, (n, p) in enumerate(pool):
                        if re.sub(r"_(PFD|PTD)$", "", n) == \
                           re.sub(r"_(PFD|PTD)$", "", old):
                            hit = pool.pop(i)
                            break
                    if hit:
                        tasks.append((hit[0], hit[1], "renamed from %s" % old))
                    else:
                        tasks.append((old, None, "MISSING"))
                note = " (%d renamed)" % len(renamed)
            # 保持原有顺序
            order = {n: i for i, (n, _t) in enumerate(old_tasks)}
            tasks.sort(key=lambda x: order.get(x[0], 999))

            missing = [t for t in tasks if t[1] is None]
            for t in missing:
                warnings.append(f"{wf}: 找不到脚本 for {t[0]} ({t[2]})")

            codes = [base + len(plan) * 100000 + i for i in range(len(tasks))]
            tdefs = []
            for (tname, path, _d), c in zip(tasks, codes):
                if path is None:
                    continue
                tdefs.append(shell_task(c, tname, read_script(path)))
            plan.append({
                "name": wf, "kind": "ODS", "sys": s,
                "task_defs": tdefs, "codes": codes[:len(tdefs)],
                "edges": [(0, c) for c in codes[:len(tdefs)]],
                "note": note, "n_local": len(local),
                "missing": len(missing),
            })

    if not args.no_dwd:
        # DWD 脚本分散在各系统，一次收全为全局池
        dwd_local = dict(collect_scripts("*", "dwd"))
        dwd_by_name = dwd_local
        for wf, old_tasks in dwd_inv.items():
            s = wf                      # DWD_ACCT -> 用于 --sys 过滤
            if only and s.upper() not in only:
                continue
            tasks = []
            for n, ttype in old_tasks:
                if ttype == "SHELL":
                    if n in dwd_by_name:
                        tasks.append((n, dwd_by_name[n], "SHELL"))
                    else:
                        tasks.append((n, None, "SHELL-MISSING"))
                else:
                    # DEPENDENT 节点不单独处理，构建时按 SHELL 生成 dep_X
                    tasks.append((n, None, "DEPENDENT"))
            # ★★ 去重：备份里存在纯重复行（如 DWD_PROD_PROD_WARN_HIS_INFO_PFD
            #    出现两次），DS 不允许同名任务 ⇒ 按名字保留首个 SHELL。
            dedup = []
            seen = set()
            for t in tasks:
                if t[2] != "SHELL":
                    continue
                if t[0] in seen:
                    warnings.append(f"{wf}: 备份里任务 {t[0]} 重复，已去重")
                    continue
                seen.add(t[0])
                dedup.append(t)
            tasks = dedup
            miss = [t for t in tasks if t[2] == "SHELL-MISSING"]
            for t in miss:
                warnings.append(f"{wf}: DWD 脚本缺失 {t[0]}")
            n_shell = sum(1 for t in tasks if t[2] == "SHELL")
            plan.append({
                "name": wf, "kind": "DWD", "sys": s,
                "raw_tasks": [t for t in tasks if t[2] != "DEPENDENT"],
                "n_local": len(dwd_local),
                "missing": len(miss),
                "n_shell": n_shell,
                "n_expected": len(old_tasks),
                "self_code": base + 800000000 + len(plan) * 7000,
            })

    # ---------- 打印计划 ----------
    print("\n=== 重建计划 ===")
    tw = tn = 0
    for p in plan:
        if p["kind"] == "ODS":
            n = len(p["task_defs"])
            print("  %-18s ODS  %-6s tasks=%-3d local=%-3d%s%s"
                  % (p["name"], p["sys"], n, p["n_local"], p["note"],
                     "  !! missing=%d" % p["missing"] if p["missing"] else ""))
        else:
            print("  %-18s DWD  %-6s shell=%-3d +dep=%-3d (原 %d) local=%d%s"
                  % (p["name"], p["sys"], p["n_shell"], p["n_shell"],
                     p["n_expected"], p["n_local"],
                     "  !! missing=%d" % p["missing"] if p["missing"] else ""))
        tw += 1
        if p["kind"] == "ODS":
            tn += len(p["task_defs"])
        else:
            tn += p["n_shell"] * 2
    print("  合计 %d 个工作流 / %d 个任务（含依赖节点）" % (tw, tn))

    if warnings:
        print("\n=== 警告 (%d) ===" % len(warnings))
        for w in warnings[:40]:
            print("  ⚠", w)
        if len(warnings) > 40:
            print("  ... 还有 %d 条" % (len(warnings) - 40))

    if not args.apply:
        print("\n[plan 模式] 未写 DS。加 --apply 执行。")
        return 0

    # ---------- 执行 ----------
    ds = DSClient(base="http://127.0.0.1:12345/dolphinscheduler",
                  user=ds_admin_user(), password=ds_admin_password(),
                  allow_admin=True)
    r = ds.call("GET", "/projects/list",
                params={"searchVal": args.project, "pageSize": 50, "pageNo": 1})
    d = r.get("data")
    items = d.get("totalList") if isinstance(d, dict) else (d or [])
    pcode = None
    for it in items:
        if it.get("name") == args.project:
            pcode = it["code"]
    if not pcode:
        sys.exit("项目不存在: " + args.project)
    print(f"\n项目 {args.project} code={pcode}")

    # ★ 顺序：ODS 先（只被 DWD 引用）；DWD 之间按拓扑序（忽略自环，
    #   因为同工作流内自引用在提交时即可解析 —— 所有 code 已先生成）。
    ods_plan = [p for p in plan if p["kind"] == "ODS"]
    dwd_plan = [p for p in plan if p["kind"] == "DWD"]

    dwd_names = [p["name"] for p in dwd_plan]
    graph = {w: set() for w in dwd_names}
    for (wf, _dn), items in dep_items.items():
        for it in items:
            u = it["wf"]
            if u and u.startswith("DWD_") and u != wf and u in graph \
                    and wf in graph:
                graph[wf].add(u)          # 自环已排除
    try:
        import graphlib
        order = list(graphlib.TopologicalSorter(graph).static_order())
        rank = {n: i for i, n in enumerate(order)}
        dwd_plan.sort(key=lambda p: rank.get(p["name"], 0))
        print("\nDWD 拓扑序: " + " → ".join(order))
    except Exception as e:
        print(f"\n!! DWD 拓扑排序失败（{e}），退回按名字排序")
        dwd_plan.sort(key=lambda p: p["name"])
    plan = ods_plan + dwd_plan

    ok = fail = 0

    # ODS 任务 code 由本地生成（工作流 code 交给 DS 分配，任务 code 需自备）
    for i, p in enumerate(plan):
        if p["kind"] == "ODS":
            wf_seed = base + 100000000 + i * 3000
            for j, td in enumerate(p["task_defs"]):
                td["code"] = wf_seed + 1 + j

    # ★★★ 两阶段提交（DS 忽略客户端传的 workflow code，自己分配）
    #   阶段 1：把所有工作流建出来（DWD 的 DEPENDENT 节点先留空依赖）。
    #   阶段 2：全部建完后，用 DS 分配的真实 code 回填 DWD 的依赖条目。
    #   否则前向引用（DWD_SCR→DWD_CHNL→DWD_PROD）和跨层引用（DWD→ODS）
    #   都拿不到 code ⇒ dependItemList 为空 ⇒ 50020 parameter invalid。
    new_task_code = {}     # task_name -> 真实 code（阶段 1 后填充）
    new_wf_code = {}       # wf_name   -> 真实 code

    # 旧名 → 新名（改名场景：OA/OFFW 裸名 → 补 _PFD）
    all_names = set()
    for p in plan:
        if p["kind"] == "ODS":
            all_names.update(td["name"] for td in p["task_defs"])
        else:
            all_names.update(t for t, _p, _k in p["raw_tasks"])
    name_alias = {}
    for tn in all_names:
        name_alias.setdefault(re.sub(r"_(PFD|PTD)$", "", tn), tn)

    def resolve_task(name):
        if not name:
            return None
        if name in new_task_code:
            return new_task_code[name]
        alias = name_alias.get(re.sub(r"_(PFD|PTD)$", "", name))
        return new_task_code.get(alias) if alias else None

    # ---------------- 阶段 1：创建（依赖节点留空） ----------------
    print("\n[阶段 1/2] 创建 %d 个工作流" % len(plan))
    for p in plan:
        wf = p["name"]
        try:
            drop_wf(ds, pcode, wf)
        except Exception as e:
            print(f"  !! {wf} 预删除失败：{e}")
            fail += 1
            continue

        if p["kind"] == "ODS":
            tdefs = list(p["task_defs"])
            locs = ods_locations([td["code"] for td in tdefs])
            rels = build_relations([td["code"] for td in tdefs],
                                   [(0, td["code"]) for td in tdefs])
        else:
            # DWD 阶段 1：**只建 SHELL**，DEPENDENT 节点留到阶段 2 一并加入
            # ★ 空 dependTaskList 的 DEPENDENT 会被 DS 判 parameter invalid，
            #   所以不能先建空壳再回填。
            tdefs = []
            codes = []
            for i, (tname, path, _k) in enumerate(p["raw_tasks"]):
                # ★ 2026-10-22 修 bug（评审 HIGH-4）：原式 `base + 700000000
                #   + len(wf) * 200 + i` 用**工作流名长度**做偏移 ⇒ 两个同长度名
                #   的工作流（如 DWD_PROD 与 DWD_ACCT，均 8 字符）拿到**完全相同**
                #   的 code 段 ⇒ DS 项目内任务 code 冲突（DS 要求唯一）⇒ 依赖
                #   回填指向错误任务或 PUT 建失败，且故障难从日志定位。
                #   ⇒ 改用全局单调计数器（_CodeAllocator），保证跨工作流唯一。
                c = dwd_codes.next()
                codes.append(c)
                script = (read_script(path) if path
                          else "#!/bin/sh\n# MISSING SCRIPT\n")
                tdefs.append(shell_task(c, tname, script))
            rels = build_relations(codes, [(0, c) for c in codes])
            locs = dwd_grid_locations(codes)

        res = ds.call("POST", f"/projects/{pcode}/workflow-definition", form={
            "name": wf,
            "description": f"{p['kind']} {wf}（{len(tdefs)} 个作业，重建自原清单）",
            "globalParams": global_params(),
            "locations": json.dumps(locs),
            "timeout": 0, "tenantCode": TENANT,
            "taskRelationJson": json.dumps(rels),
            "taskDefinitionJson": json.dumps(tdefs, ensure_ascii=False),
            "executionType": EXEC,
            "releaseState": "OFFLINE",
        })
        if res.get("code") != 0:
            fail += 1
            print("  ✗ %-18s %s: %s" % (wf, p["kind"],
                                        json.dumps(res, ensure_ascii=False)[:200]))
            continue
        wcode = res["data"]["code"]
        new_wf_code[wf] = wcode
        ok += 1
        # 真实任务 code 回读
        g = ds.call("GET", f"/projects/{pcode}/workflow-definition/{wcode}")
        for t in (g.get("data") or {}).get("taskDefinitionList") or []:
            new_task_code[t["name"]] = t["code"]
        print("  ✓ %-18s %s tasks=%d code=%s"
              % (wf, p["kind"], len(tdefs), wcode))

    # ---------------- 阶段 2：给 DWD 增加 DEPENDENT 节点并填依赖 ----------------
    dwd_left = [p for p in plan if p["kind"] == "DWD"]
    print("\n[阶段 2/2] 为 %d 个 DWD 工作流添加依赖节点" % len(dwd_left))
    for p in dwd_left:
        wf = p["name"]
        wcode = new_wf_code.get(wf)
        if wcode is None:
            print("  !! %s 阶段 1 未建成，跳过" % wf)
            continue
        g = ds.call("GET", f"/projects/{pcode}/workflow-definition/{wcode}")
        d = g.get("data") or {}
        tds = d.get("taskDefinitionList") or []
        locs = d.get("locationList") or []
        rels = (d.get("workflowTaskRelationList")
                or d.get("taskRelationList") or [])
        by_name = {t["name"]: t for t in tds}

        # 归一化 locations / relations 的结构（DS 回读可能带多余字段）
        locs = [{"taskCode": l.get("taskCode"), "x": l.get("x", 0),
                 "y": l.get("y", 0)} for l in locs]
        rels = [{"name": r.get("name") or "",
                 "preTaskCode": r.get("preTaskCode") or 0,
                 "preTaskVersion": r.get("preTaskVersion") or 0,
                 "postTaskCode": r.get("postTaskCode"),
                 "postTaskVersion": r.get("postTaskVersion") or 1,
                 "conditionType": r.get("conditionType") or "NONE",
                 "conditionParams": r.get("conditionParams") or {}}
                for r in rels]

        n_dep = filled = unresolved = 0
        for k, (tname, _path, _k) in enumerate(p["raw_tasks"]):
            shell = by_name.get(tname)
            if not shell:
                continue
            dcode = dwd_codes.next()
            groups = []
            for it in dep_items.get((wf, wf and ("dep_" + tname)), []):
                ddc = new_wf_code.get(it["wf"])
                dtc = resolve_task(it["task"])
                if ddc is None or dtc is None:
                    unresolved += 1
                    continue
                groups.append({"relation": "AND", "dependItemList": [{
                    "cycle": it["cycle"], "dateValue": it["dateValue"],
                    "depTaskCode": dtc, "projectCode": pcode,
                    "dependentType": "DEPENDENT_ON_TASK",
                    "definitionCode": ddc, "parameterPassing": False}]})
            if not groups:
                continue          # 无依赖则不建依赖节点
            dep_name = "dep_" + tname
            dt = by_name.get(dep_name)
            if dt is None:
                dt = dependent_task(dcode, dep_name, groups)
                tds.append(dt)
                locations_add = True
            else:
                locations_add = False
            dt["taskParams"]["dependence"] = {
                "relation": "AND", "dependTaskList": groups,
                "checkInterval": 60,
                "failurePolicy": "DEPENDENT_FAILURE_FAILURE",
                "failureWaitingTime": 0}
            if locations_add:
                locs.append({"taskCode": dt["code"],
                             "x": 40 + (n_dep % 5) * 240,
                             "y": 40 + (n_dep // 5) * 110})
                rels.append({"name": "", "preTaskCode": dt["code"],
                             "preTaskVersion": 1, "postTaskCode": shell["code"],
                             "postTaskVersion": 1,
                             "conditionType": "NONE", "conditionParams": {}})
                rels.append({"name": "", "preTaskCode": 0,
                             "preTaskVersion": 0, "postTaskCode": dt["code"],
                             "postTaskVersion": 1,
                             "conditionType": "NONE", "conditionParams": {}})
            n_dep += 1
            filled += 1

        ds.call("POST",
                f"/projects/{pcode}/workflow-definition/{wcode}/release",
                form={"releaseState": "OFFLINE"})
        up = ds.call("PUT", f"/projects/{pcode}/workflow-definition/{wcode}",
                     form={
                         "name": wf,
                         "description": d.get("description") or f"DWD {wf}",
                         "globalParams": d.get("globalParams") or "[]",
                         "locations": json.dumps(locs),
                         "timeout": d.get("timeout") or 0,
                         "tenantCode": TENANT,
                         "taskRelationJson": json.dumps(rels),
                         "taskDefinitionJson": json.dumps(tds,
                                                          ensure_ascii=False),
                         "executionType": d.get("executionType") or EXEC,
                         "releaseState": "OFFLINE",
                     })
        if up.get("code") == 0:
            print("  ✓ %-18s 依赖节点 %d 个%s"
                  % (wf, n_dep,
                     "（未解析 %d 条）" % unresolved if unresolved else ""))
        else:
            fail += 1
            print("  ✗ %-18s PUT 失败: %s"
                  % (wf, json.dumps(up, ensure_ascii=False)[:200]))

    if args.online:
        print("\n上线全部工作流")
        n_on = 0
        for wf, wcode in new_wf_code.items():
            r = ds.call("POST",
                        f"/projects/{pcode}/workflow-definition/{wcode}/release",
                        form={"releaseState": "ONLINE"})
            if r.get("code") == 0:
                n_on += 1
        print("  上线 %d/%d" % (n_on, len(new_wf_code)))

    print(f"\n完成：成功 {ok} / 失败 {fail}（状态 %s）"
          % ("ONLINE" if args.online else "OFFLINE"))
    return 0 if fail == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
