#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""核查：**DWD 工作流里的表**（以及它们脚本里读的源表）**有没有在 Hive 里建出来**。

做两件事：
  A) 目标表：每个 DWD 工作流的 SHELL 任务名 = 目标表名 → 是否在 `dwdxday` 里存在。
  B) 源表：用 `parse_src_tables` 从各自脚本抠出读到的 `库.表` → 逐个查该库是否有这张表
     （能揪出「脚本引用了没建的库/表」，如 `ods_xday_hsfta` / `ods_xday_hsds` / `ods_xday_manual` 根本不存在）。

只读，不改任何东西。用法: python tools/ds-check-tables-exist.py
"""
import collections
import importlib.util
import json
import os
import re
import subprocess

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_client import project_code, task_definitions  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
DOCKER = os.environ.get("DOCKER", "docker")   # WSL：用 PATH 里的 docker（原 C:\...\docker.exe 仅 Windows 可用）
JDBC = ("jdbc:hive2://hiveserver2:10000/default;principal=hive/hiveserver2@DATAX.COM")

_spec = importlib.util.spec_from_file_location("DWDDEPLOY", os.path.join(HERE, "ds-deploy-dwd-workflow.py"))
D = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(D)

_s2 = importlib.util.spec_from_file_location("DS_ADD_DWD", os.path.join(HERE, "ds-add-dwd-table.py"))
ADD = importlib.util.module_from_spec(_s2)
_s2.loader.exec_module(ADD)


def beeline(sql):
    r = subprocess.run([DOCKER, "exec", "dolphinscheduler-worker", "beeline",
                        "-u", JDBC, "--force=false", "-e", sql],
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                       timeout=180)
    return r.stdout.decode("utf-8", "replace")


def tables_in(db):
    """返回该库的表名集合（大写）；库不存在返回 None。"""
    out = beeline(f"show tables in {db}")
    if re.search(r"Database does not exist|Error", out):
        return None
    ts = set()
    for line in out.splitlines():
        m = re.match(r"\|\s*([A-Za-z0-9_]+)\s*\|", line)
        if m and m.group(1).lower() not in ("tab_name",):
            ts.add(m.group(1).upper())
    return ts


def j(x):
    if isinstance(x, str):
        try:
            return json.loads(x)
        except Exception:
            return []
    return x or []


def main():
    D.login()
    res = D.call("GET", "/projects", params={"pageNo": 1, "pageSize": 100})
    P = project_code(res, "dw")
    wfs = D.wf_list(P)
    dwd = sorted([w for w in wfs if w["name"].startswith("DWD_")], key=lambda x: x["name"])

    targets = []          # (workflow, table)
    for w in dwd:
        g = D.call("GET", f"/projects/{P}/workflow-definition/{w['code']}")["data"]
        for t in task_definitions(g):
            if t["taskType"] == "SHELL":
                targets.append((w["name"], t["name"]))

    # 各库现有表（缓存）
    cache = {}
    def has(db, tbl):
        db = db.lower()
        if db not in cache:
            cache[db] = tables_in(db)
        ts = cache[db]
        return None if ts is None else (tbl.upper() in ts)

    # ---- A) 目标表 ----
    print(f"根 DB 现状：", end="")
    for db in ["dwdxday", "dwsxday", "ods_xday_hsfa", "ods_xday_hszta",
               "ods_xday_hsfta", "ods_xday_hsds", "ods_xday_manual"]:
        ts = tables_in(db)
        print(f"{db}={'不存在' if ts is None else len(ts)}", end="  ")
    cache.clear()
    print("\n")
    print("=" * 68)
    print(f"A) 目标表（DWD 工作流的 SHELL 任务，共 {len(targets)} 张）在 dwdxday 是否存在")
    print("=" * 68)
    miss_a = []
    for wf, tbl in targets:
        r = has("dwdxday", tbl)
        if not r:
            miss_a.append((wf, tbl))
    print(f"  存在 {len(targets) - len(miss_a)} / {len(targets)}；**缺失 {len(miss_a)}**")
    for wf, tbl in miss_a:
        print(f"    ✗ [{wf}] {tbl}")

    # ---- B) 源表 ----
    print("\n" + "=" * 68)
    print("B) 各脚本读到的**源表**（库.表）是否存在")
    print("=" * 68)
    src = collections.defaultdict(set)     # db -> {表: 谁引用}
    for wf, tbl in targets:
        p = D.script_of(tbl)
        if not p:
            continue
        for full, _prev in ADD.parse_src_tables(p):
            db, _, t = full.partition(".")
            src[db.lower()].add(t.upper())
    miss_b = []
    for db in sorted(src):
        ts = tables_in(db)
        if ts is None:
            miss_b.append((db, f"【整个库不存在】({len(src[db])} 张表)"))
            continue
        for t in sorted(src[db]):
            if t.upper() not in ts:
                miss_b.append((db, t))
    print(f"  源表覆盖库 {len(src)} 个；**缺失 {len(miss_b)} 项**")
    for db, t in miss_b:
        print(f"    ✗ {db}.{t}")

    print(f"\n小结：目标表缺 {len(miss_a)}，源表缺 {len(miss_b)}")


if __name__ == "__main__":
    main()
