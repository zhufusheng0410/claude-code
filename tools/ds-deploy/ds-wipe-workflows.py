#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""清空 dw 项目里的工作流定义层（本次用于「删掉原 ODS 作业，全部重来」）。

双轨删除
--------
1. **优先 REST**：`DELETE /projects/{code}/workflow-definition/{wfCode}`
2. **REST 失败**（典型是 DEPENDENT 自环 ⇒ `50019 has cycle` / 502xx）⇒ 降级到
   **事务化 SQL** 直删定义层表（这是 2026-10-08 踩出来的硬阻塞，见 MEMORY.md）。

★ 为什么必须事务化 SQL：定义层是多张表互相引用（definition / task_definition /
  relation + 各自的 _log），删一半会留下孤儿，界面上表现为「看不见的工作流」，
  之后再建同名工作流会撞名 `10168 already exists`。

安全
----
· 默认 `--dry-run`，必须显式 `--apply` 才动手。
· `--apply` 前会**强制校验备份文件存在**（由 --backup 指定），找不到就拒绝执行。
· 逐个报告成功/失败，最后汇总。

用法
----
    python tools/ds-wipe-workflows.py --dry-run
    python tools/ds-wipe-workflows.py --apply --backup backup/ds-metastore-20261009-154742.sql
    python tools/ds-wipe-workflows.py --apply --backup <dump> --only "^ods_hsfa"   # 只删匹配名
"""
import argparse
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ds_config import ds_admin_password, ds_admin_user, pg_password  # noqa: E402
from ds_client import legacy_client  # noqa: E402

DS = "http://127.0.0.1:12345/dolphinscheduler"
USER = ds_admin_user()
PWD = ds_admin_password()

# ★ 2026-10-15：HTTP 层改用 ds_client（原先自写 urllib）——
#   磁盘会话复用 + 401 自动重登 + 超时重试。
_ds = None


def _client():
    global _ds
    if _ds is None:
        _ds = legacy_client(base=DS, user=USER, password=PWD,
                            allow_admin=True, timeout=120)
    return _ds


def _rest(method, path, params=None, form=None, sid=None):
    """`sid` 形参仅为兼容旧调用点保留；会话统一由 ds_client 持有。"""
    return _client().call(method, path, params=params, form=form)


def login():
    return _client().login()


def list_workflows(sid, project_code):
    out, page = [], 1
    while True:
        j = _rest("GET", "/projects/%s/workflow-definition" % project_code,
                  params={"pageNo": page, "pageSize": 50, "searchVal": ""}, sid=sid)
        d = j["data"]
        lst = d.get("totalList", []) if isinstance(d, dict) else d
        out.extend(lst)
        total = d.get("total") if isinstance(d, dict) else None
        if not lst or (total and len(out) >= int(total)):
            break
        page += 1
        if page > 30:
            break
    return out


def psql(sql, host_db=True):
    """在 PG 容器里执行 SQL。

    ★ 2026-10-22 安全改造（评审 CRITICAL-2）：
      原实现把 SQL 拼进 `bash -c 'psql -c "<sql>"'`，只转义双引号——
      单引号 / 反引号 / `$(...)` 均未转义 ⇒ 注入面；且口令以明文出现在 argv。
      现改为：
        1. `docker exec` 直接跑 `psql`（**不经过 bash -c**），杜绝 shell 解析；
        2. 口令经 `-e PGPASSWORD=...` 以**环境变量**注入，不进 argv；
        3. SQL 本体经 **stdin** 传入（`psql` 默认从 stdin 读），不进 argv。

    参数化说明：SQL 文本里的 `{codes}` / `{proj}` / `{tcodes}` 占位由调用方
    用 `.format()` 填入——这些值来源是 DS API / 元库查询得到的**整数 code**，
    非用户自由文本。即便如此，本函数已不再接受任何来自外部的字符串拼接。
    """
    cmd = ["docker", "exec", "-i",
           "-e", f"PGPASSWORD={pg_password()}",
           "hive-metastore-db",
           "psql", "-U", "hiveuser", "-d", "dolphinscheduler",
           "-v", "ON_ERROR_STOP=1", "-q", "-A", "-t"]
    r = subprocess.run(cmd, input=sql, capture_output=True, text=True,
                       errors="replace")
    return r.returncode, (r.stdout or "") + (r.stderr or "")


# ★ 2026-10-16 收窄：原实现 `DELETE ... WHERE project_code = {proj}` 会把整个项目
#   的任务定义全删（当初是「整项目清空」场景才安全）。现在只删 DWD 子集，
#   必须先按 relation 反查出这批工作流真正拥有的 task code，再按 code 精确删。
SQL_COLLECT_TASKS = """
SELECT DISTINCT x FROM (
  SELECT post_task_code AS x FROM t_ds_workflow_task_relation
   WHERE workflow_definition_code IN ({codes})
  UNION
  SELECT pre_task_code AS x FROM t_ds_workflow_task_relation
   WHERE workflow_definition_code IN ({codes})
) t WHERE x IS NOT NULL AND x <> 0;
"""

SQL_WIPE = """
BEGIN;
DELETE FROM t_ds_workflow_task_relation WHERE workflow_definition_code IN ({codes});
DELETE FROM t_ds_workflow_task_relation_log WHERE workflow_definition_code IN ({codes});
DELETE FROM t_ds_task_definition
 WHERE project_code = {proj} AND code IN ({tcodes})
   AND NOT EXISTS (SELECT 1 FROM t_ds_workflow_task_relation r
                    WHERE r.project_code = {proj}
                      AND (r.post_task_code = t_ds_task_definition.code
                        OR r.pre_task_code  = t_ds_task_definition.code));
DELETE FROM t_ds_task_definition_log
 WHERE project_code = {proj} AND code IN ({tcodes})
   AND NOT EXISTS (SELECT 1 FROM t_ds_workflow_task_relation r
                    WHERE r.project_code = {proj}
                      AND (r.post_task_code = t_ds_task_definition_log.code
                        OR r.pre_task_code  = t_ds_task_definition_log.code));
DELETE FROM t_ds_workflow_definition WHERE code IN ({codes});
DELETE FROM t_ds_workflow_definition_log WHERE code IN ({codes});
COMMIT;
"""

# REST 删除后可能残留孤儿 task_definition（DS 3.x 已知行为）→ 同名重建会撞 10168。
# 任何合法任务必然出现在 relation 里，所以「无任何 relation 引用」= 孤儿，可安全清。
SQL_ORPHAN_TASKS = """
SELECT count(*) FROM t_ds_task_definition t
 WHERE t.project_code = {proj}
   AND NOT EXISTS (SELECT 1 FROM t_ds_workflow_task_relation r
                    WHERE r.project_code = {proj}
                      AND (r.post_task_code = t.code OR r.pre_task_code = t.code));
"""

SQL_PURGE_ORPHANS = """
BEGIN;
DELETE FROM t_ds_task_definition_log
 WHERE project_code = {proj} AND code IN (
   SELECT t.code FROM t_ds_task_definition t
    WHERE t.project_code = {proj}
      AND NOT EXISTS (SELECT 1 FROM t_ds_workflow_task_relation r
                       WHERE r.project_code = {proj}
                         AND (r.post_task_code = t.code OR r.pre_task_code = t.code)));
DELETE FROM t_ds_task_definition t
 WHERE t.project_code = {proj}
   AND NOT EXISTS (SELECT 1 FROM t_ds_workflow_task_relation r
                    WHERE r.project_code = {proj}
                      AND (r.post_task_code = t.code OR r.pre_task_code = t.code));
COMMIT;
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="真正执行（默认只打印计划）")
    ap.add_argument("--backup", help="强制校验的备份文件路径（--apply 时必填）")
    ap.add_argument("--only", help="按正则只删匹配名称的工作流")
    ap.add_argument("--project", default="dw")
    args = ap.parse_args()

    sid = login()
    j = _rest("GET", "/projects/list",
              params={"searchVal": args.project, "pageSize": 50, "pageNo": 1}, sid=sid)
    d = j["data"]
    items = d.get("totalList", []) if isinstance(d, dict) else d
    proj = [p for p in items if p.get("name") == args.project]
    if not proj:
        print("找不到项目 %s" % args.project)
        return 1
    pcode = proj[0]["code"]

    wfs = list_workflows(sid, pcode)
    if args.only:
        pat = re.compile(args.only)
        wfs = [w for w in wfs if pat.search(w.get("name") or "")]
    print("项目 %s（code=%s）：待处理工作流 %d 个" % (args.project, pcode, len(wfs)))
    for w in sorted(wfs, key=lambda x: x.get("name")):
        print("   - %-28s code=%s  %s"
              % (w.get("name"), w.get("code"), w.get("releaseState")))
    if not wfs:
        return 0

    if not args.apply:
        print("\n[dry-run] 未做任何改动。加 --apply 执行。")
        return 0

    if not args.backup:
        print("\n!! --apply 必须同时给 --backup（先做过 pg_dump 才能删）")
        return 2
    import os
    if not os.path.exists(args.backup):
        print("\n!! 备份文件不存在：%s —— 拒绝执行" % args.backup)
        return 2
    print("\n备份校验通过：%s" % args.backup)

    ok, failed = [], []
    for w in sorted(wfs, key=lambda x: x.get("name")):
        name, code = w.get("name"), w.get("code")
        try:
            r = _rest("DELETE", "/projects/%s/workflow-definition/%s" % (pcode, code),
                      sid=sid)
            if r.get("code") == 0:
                ok.append((name, code))
                print("  ✅ REST 删除 %s" % name)
            else:
                failed.append((name, code, "REST返回 %s" % r.get("msg")))
                print("  ⚠ REST 删除 %s 失败：%s" % (name, r.get("msg")))
        except Exception as e:
            failed.append((name, code, str(e)[:120]))
            print("  ⚠ REST 删除 %s 异常：%s" % (name, str(e)[:120]))

    if failed:
        print("\n%d 个工作流 REST 删不掉（多半是 DEPENDENT 自环）⇒ 降级事务化 SQL"
              % len(failed))
        codes = ",".join(str(c) for _, c, _ in failed)
        # ★ 先反查这批工作流真正拥有的 task code（必须在删 relation 之前做）
        rc, out = psql(SQL_COLLECT_TASKS.format(codes=codes))
        if rc != 0:
            print("收集 task code 失败：%s" % out[:1500])
            return 1
        tcodes = [x.strip() for x in out.splitlines() if x.strip().isdigit()]
        if not tcodes:
            print("!! 收集到 0 个 task code，拒绝执行（防误删全项目）")
            return 1
        print("   这批工作流共关联 %d 个 task definition" % len(tcodes))
        sql = SQL_WIPE.format(codes=codes, proj=pcode,
                              tcodes=",".join(tcodes))
        rc, out = psql(sql)
        print("SQL 退出码=%d" % rc)
        if rc != 0:
            print(out[:2000])
            print("\n!! SQL 删除失败，请勿继续，先排查")
            return 1
        for name, code, _ in failed:
            print("  ✅ SQL 删除 %s" % name)

    # REST 删除可能留下孤儿 task_definition ⇒ 后续同名重建会撞 10168 already exists
    rc, out = psql(SQL_ORPHAN_TASKS.format(proj=pcode))
    n_orphan = 0
    if rc == 0 and out.strip().isdigit():
        n_orphan = int(out.strip())
    print("\n孤儿 task_definition 检查：%d 个" % n_orphan)
    if n_orphan:
        if not args.apply:
            print("  [dry-run] 将清理这些孤儿（无任何 relation 引用）")
        else:
            rc, out = psql(SQL_PURGE_ORPHANS.format(proj=pcode))
            print("  清理退出码=%d" % rc)
            if rc != 0:
                print(out[:1500])
            else:
                rc2, out2 = psql(SQL_ORPHAN_TASKS.format(proj=pcode))
                print("  清理后剩余孤儿：%s" % (out2.strip() or "?"))

    left = list_workflows(sid, pcode)
    print("\n剩余工作流 %d 个" % len(left))
    for w in left:
        print("   - %s" % w.get("name"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
