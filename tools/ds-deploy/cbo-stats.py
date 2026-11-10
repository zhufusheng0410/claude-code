#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""cbo-stats.py —— Hive CBO 统计信息补全工具

背景
----
``hive.stats.autogather=false`` + ``hive.stats.column.autogather=false``，
加上从未跑过 ANALYZE，导致 metastore 里几乎没有 numRows：
  - 表级 numRows：1 条
  - 分区级 numRows：0 条
CBO 拿不到基数就只能按默认值猜，join 顺序 / map join 判定 / reducer 估算全部失真。

本工具做三件事：
  1. 从 ETL 脚本里抽取「实际被引用的表」，按引用频次排序（高频 = 先补）；
  2. 区分分区表 / 非分区表，分区表按指定分区补（分区级统计才是查询真正用到的）；
  3. 生成 SQL 或直接经 beeline 执行，支持 dry-run、断点续跑、结果逐条落盘。

★ 断点续跑口径（2026-11-09 A6）：`run` 会把**每条**结果立即写进明细文件
  （`finally` 保证 JSON 数组闭合，Ctrl-C 也是合法文件），重跑时跳过历史上
  「同一条 SQL 已成功」的表；`probe` 可用 `--partition` 让抽样 `count(*)`
  带分区过滤，避免小体检扫全部分区（A7）。

★ 关键前提：ANALYZE 要扫描真实数据。**空表补统计毫无意义**（0 行本来就准），
   执行前先用 ``--probe`` 看一遍数据量，确认仓库里真有数据再跑。

用法
----
    # 1) 先体检：看看被引用的表里到底有没有数据
    python cbo-stats.py probe --top 20

    # 2) 只看要生成什么 SQL（不执行）
    python cbo-stats.py gen --min-refs 10 --partition 20261029

    # 3) 真正执行（分区表按 p_dt='20261029' 补分区级统计）
    python cbo-stats.py run --min-refs 10 --partition 20261029

    # 4) 带列统计（更准，但每个表多一次扫描，先小范围试）
    python cbo-stats.py run --top 20 --with-columns --partition 20261029
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import re
import subprocess
import sys
import time

HERE = pathlib.Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import dw_paths  # noqa: E402

REPO_ROOT = pathlib.Path(dw_paths.REPO)
SCRIPTS_DIR = pathlib.Path(dw_paths.SCRIPTS)
CACHE = pathlib.Path(dw_paths.REPORT_DIR) / "cbo-refs.json"

WORKER = "dolphinscheduler-worker"
META_DB = "hive-metastore-db"
META_USER = "hiveuser"
META_NAME = "hivemetastore"

JDBC = "jdbc:hive2://hiveserver2:10000/;principal=hive/hiveserver2@DATAX.COM"
KEYTAB = "/etc/krb5-keytab/xdaydw.keytab"
PRINCIPAL = "xdaydw@DATAX.COM"

# 抽取 ETL 脚本里对库表的引用（去注释后匹配 db.table）
_REF_RE = re.compile(
    r"\b(ODS_XDAY_[A-Z0-9]+|DWDXDAY|DWSXDAY)\.([A-Z0-9_]+)", re.IGNORECASE
)


# --------------------------------------------------------------------------
# 1. 从 ETL 脚本抽取被引用的表
# --------------------------------------------------------------------------
def _etl_files() -> list:
    """DWD + DWS 两层 ETL 脚本（含 MASTER/dwd；`*` 通配即覆盖）。"""
    return sorted(SCRIPTS_DIR.glob("*/dwd/02_etl/*.sh")) + sorted(
        SCRIPTS_DIR.glob("*/dws/02_etl/*.sh")
    )


def _refs_fingerprint(files: list) -> str:
    """ETL 脚本清单的内容指纹：脚本数 + 各文件 (mtime_ns, size)。

    ★ 2026-11-09（评审 A3）：原缓存**只在 `--rebuild` 时才失效**。改完 ETL 脚本
      再跑 `gen`/`run`，命中的是**旧表清单**（无任何提示）—— 这与
      `parser/mapping.py` 的约定「缓存只提速、绝不参与正确性」相反。
    """
    h = hashlib.sha1()
    for f in files:
        st = f.stat()
        h.update(f"{f.name}:{st.st_mtime_ns}:{st.st_size}\n".encode("utf-8"))
    return h.hexdigest()[:16]


def scan_refs(rebuild: bool = False) -> list[dict]:
    """返回 [{"tbl": "DB.TBL", "refs": n}]，按引用次数降序。"""
    files = _etl_files()
    fp = _refs_fingerprint(files)
    if CACHE.exists() and not rebuild:
        try:
            doc = json.loads(CACHE.read_text(encoding="utf-8"))
            if not isinstance(doc, dict):
                # ★ A3：旧版缓存是**裸 list**（没有 fingerprint 包裹）。
                #   直接 doc.get 会 AttributeError（不在下面的异常清单里）
                #   ⇒ 工具崩掉。这里显式判类型并走重建。
                raise TypeError("cache format is not dict")
            if doc.get("fingerprint") == fp:
                return doc["refs"]
            print("· cbo 引用缓存已过期（ETL 脚本有改动），重新扫描")
        except (json.JSONDecodeError, OSError, KeyError, TypeError) as e:
            # ★ A3：缓存损坏/结构不对时**静默重建**，绝不让缓存问题中断工具
            print("· cbo 引用缓存不可用（%s），重新扫描" % type(e).__name__)

    from collections import Counter

    counter: Counter[str] = Counter()
    for f in files:
        text = f.read_text(encoding="utf-8", errors="ignore")
        text = re.sub(r"--[^\n]*", "", text)  # 去掉 SQL 行注释，避免注释里的表名被算进去
        for db, tbl in _REF_RE.findall(text):
            counter[f"{db.upper()}.{tbl.upper()}"] += 1

    out = [{"tbl": k, "refs": v} for k, v in counter.most_common()]
    try:
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(json.dumps({"fingerprint": fp, "refs": out},
                                    ensure_ascii=False, indent=1),
                         encoding="utf-8")
    except OSError as e:
        print("· cbo 引用缓存写入失败（%s），本次仅用内存结果" % e)
    return out


# --------------------------------------------------------------------------
# 2. 从 metastore 拿分区信息
# --------------------------------------------------------------------------
def _psql(sql: str) -> list[str]:
    """在 metastore 容器里跑一条 psql，返回非空行。

    SQL 走 stdin，不经 ``sh -c``。多行不用压成一行，引号也不会被 shell 吃掉。
    同形：``ds-wipe-workflows.py::psql``（那边连的是 dolphinscheduler 库）。
    """
    cmd = [
        "docker", "exec", "-i", META_DB,
        "psql", "-U", META_USER, "-d", META_NAME, "-tA",
    ]
    r = subprocess.run(
        cmd, input=sql, capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    if r.returncode != 0:
        raise RuntimeError(f"psql 失败: {r.stderr.strip()[:300]}")
    return [ln.strip() for ln in r.stdout.splitlines() if ln.strip()]


def load_meta() -> dict[str, dict]:
    """返回 {小写 db.tbl: {"parts": n, "part_keys": [..], "numrows": str|None}}"""
    sql = """
    select d."NAME" || '.' || t."TBL_NAME"
         , t."TBL_ID"
         , coalesce((select count(*) from "PARTITIONS" p where p."TBL_ID" = t."TBL_ID"), 0)
         , coalesce((select "PARAM_VALUE" from "TABLE_PARAMS" tp
                     where tp."TBL_ID" = t."TBL_ID" and tp."PARAM_KEY" = 'numRows'), '')
         , coalesce((select string_agg(distinct pk."PKEY_NAME", ',')
                     from "PARTITION_KEYS" pk where pk."TBL_ID" = t."TBL_ID"), '')
    from "TBLS" t join "DBS" d on t."DB_ID" = d."DB_ID"
    """
    meta: dict[str, dict] = {}
    for line in _psql(sql):
        parts = line.split("|")
        if len(parts) < 5:
            continue
        name, _tid, npart, numrows, pkeys = parts[0], parts[1], parts[2], parts[3], parts[4]
        meta[name.lower()] = {
            "parts": int(npart or 0),
            "numrows": numrows or None,
            "part_keys": [k for k in pkeys.split(",") if k],
        }
    return meta


# --------------------------------------------------------------------------
# 3. beeline 执行
# --------------------------------------------------------------------------
def _beeline(sql: str, timeout: int = 1800) -> tuple[bool, str]:
    """在 worker 容器里取票后执行一条 SQL，返回 (成功, 输出尾部)。"""
    inner = (
        f'kinit -kt {KEYTAB} {PRINCIPAL} >/dev/null 2>&1\n'
        f"""beeline -u "{JDBC}" --silent=true --outputformat=tsv2 -e {json.dumps(sql)} 2>&1"""
    )
    try:
        r = subprocess.run(
            ["docker", "exec", "-e", "TERM=dumb", WORKER, "sh", "-c", inner],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return False, f"超时 {timeout}s"
    out = "\n".join(
        ln for ln in (r.stdout or "").splitlines()
        if not any(k in ln for k in ("SLF4J", "log4j", "WARN ", "WARNING"))
    )
    ok = r.returncode == 0 and "Error" not in out and "FAILED" not in out
    return ok, out.strip()[-500:]


# --------------------------------------------------------------------------
# 子命令
# --------------------------------------------------------------------------
def cmd_probe(args) -> int:
    """体检：被引用最多的表到底有多少行、有没有分区。

    只在空表/无数据时给出「不该现在补统计」的明确结论，
    避免花几小时扫描空目录。

    ★ A7（2026-11-09 评审）：`--partition` 给定时，抽样 `count(*)` 会带上分区
      过滤（见 `_partition_where`），不再无条件扫全部分区。
    """
    refs = scan_refs(args.rebuild)
    meta = load_meta()
    # ★ A5：0 = 不限（与 gen/run 一致）；见 _build_stmts 同款说明
    top = refs[: args.top] if args.top else refs
    spec = getattr(args, "partition", "") or ""

    print(f"{'表':<50}{'引用':>5}{'分区':>6}{'已有numRows':>12}")
    print("-" * 76)
    for r in top:
        key = r["tbl"].lower()
        m = meta.get(key)
        if not m:
            print(f"{r['tbl']:<50}{r['refs']:>5}{'?':>6}{'表不存在':>12}")
            continue
        print(
            f"{r['tbl']:<50}{r['refs']:>5}{m['parts']:>6}"
            f"{(m['numrows'] or '无'):>12}"
        )

    print("\n--- 实际数据量抽样（count(*)%s）---"
          % ("，按分区过滤" if spec else "，全表"))
    empty = 0
    scanned = 0
    for r in top[: args.sample]:
        tbl = r["tbl"].lower()
        m = meta.get(tbl)
        where, why = _partition_where(m, spec)
        if why and args.verbose:
            print(f"  ⚠ {r['tbl']}: {why}")
        sql = f"select count(*) from {tbl} {where}".strip()
        ok, out = _beeline(sql, timeout=300)
        scanned += 1
        cnt = "?"
        if ok:
            nums = [ln.strip() for ln in out.splitlines() if ln.strip().isdigit()]
            cnt = nums[-1] if nums else "?"
        if cnt == "0":
            empty += 1
        print(f"  {r['tbl']:<48} rows={cnt}")

    sampled = min(args.sample, len(top))
    if sampled and scanned and empty == sampled:
        print(
            f"\n⚠ 抽样的 {sampled} 张表全部 0 行。此时补统计没有收益——"
            "0 行本身就是准确值，CBO 已经「知道」它是空的。\n"
            "  先解决数据落地问题，再回来跑本工具。"
        )
    return 0


def _parse_partition_spec(text: str) -> dict:
    """把 `--partition` 值解析成 {分区键: 值}。

    两种形态都认（后者是多分区键表的唯一正确用法）：
      · `20261029`             → {'': '20261029'}（空键占位；单键表由调用方补键名）
      · `p_dt=20261029,hour=0` → {'p_dt': '20261029', 'hour': '0'}
    ★ 2026-11-09（评审 A4）。单键表仍可用「只给值」的简写；
      多键表若不写键名，无法知道值该给谁 ⇒ 调用方要求显式 k=v。
    """
    out = {}
    for part in (text or "").split(","):
        part = part.strip()
        if not part:
            continue
        k, _, v = part.partition("=")
        if _:
            out[k.strip()] = v.strip().strip("'\"")
        else:
            out[""] = part
    return out


def _partition_where(m: dict, spec_text: str) -> tuple:
    """体检用的分区过滤：把 `--partition` 变成 WHERE 子句（A7，2026-11-09 评审）。

    原实现 `select count(*) from T` **不带任何分区过滤** ⇒ 扫全部分区，
    大分区表一次体检可能跑几小时，与「先体检再决定补不补统计」的目的相反。

    返回 `(where, 跳过原因)`：where 为空表示全表计数。
    与 `_build_stmts` 的严格口径不同，这里是**宽松**口径：给了显式键名的分区键
    有几个就按几个过滤（子集也是合法谓词，只是统计范围更小）；但「只给一个值」
    的简写对多键表仍然无法知道该给谁 ⇒ 跳过并说明。
    """
    if not m:
        return ("", "")
    keys = m.get("part_keys") or []
    if not keys or not spec_text:
        return ("", "" if not keys else "分区表未给 --partition（将扫全部分区）")

    specs = _parse_partition_spec(spec_text)
    if "" in specs:
        if len(keys) != 1:
            return ("", f"分区键 {keys} 需显式写成 k=v，无法把单个值分配给多键")
        specs = {keys[0]: specs[""]}

    unknown = [k for k in specs if k not in keys]
    if unknown:
        return ("", f"--partition 里的键 {unknown} 不在分区键 {keys} 里")

    cond = " AND ".join(f"{k} = '{v}'" for k, v in specs.items())
    return ("WHERE " + cond, "")


def _build_stmts(args) -> list[tuple[str, str]]:
    """返回 [(目标描述, SQL)]。"""
    refs = scan_refs(args.rebuild)
    meta = load_meta()

    # ★ A5（2026-11-09 评审）：`--top 0` 语义统一为「不限量」。
    #   原先 `probe` 用 `refs[:0]`（空列表，静默什么都不做），而 gen/run 里 0 = 不限
    #   ⇒ 同一个小篆在不同子命令下含义相反。
    top = args.top if getattr(args, "top", 0) else None
    picked = [r for r in refs if r["refs"] >= args.min_refs]
    if top:
        picked = picked[:top]

    stmts: list[tuple[str, str]] = []
    skipped: list[str] = []
    for r in picked:
        tbl = r["tbl"].lower()
        m = meta.get(tbl)
        if not m:
            skipped.append(f"{r['tbl']}（元数据里不存在）")
            continue

        col = " FOR COLUMNS" if args.with_columns else ""

        # ★ A4（2026-11-09 评审）：**多分区键表不能把同一个值赋给每个键**。
        #   原实现 `spec = ", ".join(f"{k}='{partition}'" for k in part_keys)`，
        #   对 `PARTITIONED BY (p_dt, region)` 会生成
        #     PARTITION(p_dt='20261029', region='20261029')
        #   ⇒ 要么 partition not found（白跑一次失败）、要么命中一个语义错误的分区。
        #   本仓库当前都是单键 p_dt，这是**潜伏**问题：一旦上游加二级分区就会静默出错。
        #   ⇒ 多键表要求显式给 `--partition k=v,k2=v2`，否则跳过并说明。
        keys = m["part_keys"]

        if not keys:
            stmts.append((r["tbl"], f"ANALYZE TABLE {tbl} COMPUTE STATISTICS{col}"))
            continue

        if not args.partition:
            skipped.append(
                f"{r['tbl']}（分区表，需 --partition，分区键={','.join(keys)}）"
            )
            continue

        specs = _parse_partition_spec(args.partition)
        if "" in specs:                       # 简写「只给值」⇒ 只对单键表合法
            if len(keys) != 1 or len(specs) != 1:
                skipped.append(
                    f"{r['tbl']}（分区键 {keys} 需显式写成 "
                    f"{','.join(k + '=<值>' for k in keys)}，跳过）")
                continue
            specs = {keys[0]: specs[""]}
        unknown = [k for k in specs if k not in keys]
        if unknown:
            skipped.append(
                f"{r['tbl']}（--partition 里的键 {unknown} 不在分区键 {keys} 里，跳过）")
            continue
        if len(keys) > 1:
            miss = [k for k in keys if k not in specs]
            if miss:
                skipped.append(
                    f"{r['tbl']}（分区键 {keys} 有 {len(keys)} 个，需逐个赋值："
                    f"--partition {','.join(k + '=<值>' for k in keys)}；"
                    f"缺 {miss}，跳过）")
                continue

        if m["parts"] == 0:
            # 声明了分区键但一个分区都没创建（常见于只建表没灌数的维表）。
            # 此时 PARTITION(...) 会报 partition not found，直接跳过。
            skipped.append(
                f"{r['tbl']}（分区键={','.join(keys)} 但无任何分区，跳过）"
            )
            continue

        spec = ", ".join(f"{k}='{v}'" for k, v in specs.items())
        stmts.append(
            (r["tbl"], f"ANALYZE TABLE {tbl} PARTITION({spec}) COMPUTE STATISTICS{col}")
        )

    if skipped and args.verbose:
        print(f"--- 跳过 {len(skipped)} 张 ---", file=sys.stderr)
        for s in skipped:
            print(f"  {s}", file=sys.stderr)
    return stmts


def cmd_gen(args) -> int:
    stmts = _build_stmts(args)
    if not stmts:
        print("没有匹配的表。放宽 --min-refs 或补 --partition。")
        return 1
    out = pathlib.Path(dw_paths.REPORT_DIR) / "cbo_analyze.sql"
    out.parent.mkdir(parents=True, exist_ok=True)
    body = "-- 由 cbo-stats.py 生成，分区={}，列统计={}\n".format(
        args.partition or "-", "on" if args.with_columns else "off"
    ) + "\n".join(s for _, s in stmts) + "\n"
    out.write_text(body, encoding="utf-8")
    print(body)
    print(f"--- 共 {len(stmts)} 条，已写入 {out}")
    return 0


def _load_done(stmts: list) -> set:
    """断点续跑（A6，2026-11-09 评审）：历史上「同一条 SQL 成功过」的表不再重跑。

    ANALYZE 是幂等的，重跑只是白扫一遍；长任务（几十张表、每张几分钟）被中断后，
    没有这一步就得从头再来。明细文件逐条增量落盘 ⇒ Ctrl-C 之后也能读到已完成部分。
    """
    import glob as _glob
    want = {sql for _t, sql in stmts}
    done = set()
    report_dir = str(dw_paths.REPORT_DIR)
    for p in sorted(_glob.glob(os.path.join(report_dir, "cbo_run_*.json"))):
        try:
            rows = json.loads(pathlib.Path(p).read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError, UnicodeError) as e:
            # 坏掉的断点文件跳过，不让一次写坏拖垮续跑；类型写进日志。
            print("  ! 跳过无法读取的断点文件 %s（%s: %s）" % (
                p, type(e).__name__, e))
            continue
        for row in rows:
            if row.get("ok") and row.get("sql") in want:
                done.add(row["tbl"])
    return done


def cmd_run(args) -> int:
    stmts = _build_stmts(args)
    if not stmts:
        print("没有匹配的表。")
        return 1

    done = _load_done(stmts)
    todo = [(t, s) for t, s in stmts if t not in done]
    print(f"准备执行 {len(stmts)} 条 ANALYZE（分区={args.partition or '-'}），"
          f"其中 {len(done)} 条历史已成功 ⇒ 本次执行 {len(todo)} 条")
    if args.dry_run:
        for tbl, s in todo:
            print(f"  [dry-run] {tbl}: {s}")
        return 0
    if not todo:
        print("全部已处理过，无事可做。")
        return 0

    log_path = pathlib.Path(dw_paths.REPORT_DIR) / f"cbo_run_{time.strftime('%Y%m%d-%H%M%S')}.json"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    ok_n = fail_n = 0
    t0 = time.time()
    # ★ A6：逐条落盘 + finally 收尾 ⇒ 数组永远是合法 JSON，Ctrl-C 也不丢已完成明细。
    with open(log_path, "w", encoding="utf-8") as f:
        f.write("[")
        first = True
        try:
            for i, (tbl, sql) in enumerate(todo, 1):
                st = time.time()
                ok, tail = _beeline(sql, timeout=args.timeout)
                dur = round(time.time() - st, 1)
                ok_n += ok
                fail_n += not ok
                if not first:
                    f.write(",")
                f.write(json.dumps({"tbl": tbl, "sql": sql, "ok": ok,
                                    "sec": dur, "tail": tail}, ensure_ascii=False))
                f.flush()                      # 边跑边落盘，中断也不丢
                first = False
                print(f"[{i}/{len(todo)}] {'OK ' if ok else 'FAIL'} {tbl:<46} {dur:>6}s")
                if not ok and not args.keep_going:
                    print(f"  中止。输出尾部：\n{tail}")
                    break
        except KeyboardInterrupt:
            print("\n收到中断，已保留本次完成的明细（重跑会自动续上）。")
            raise
        finally:
            f.write("]\n")
            f.flush()

    print(f"\n完成：成功 {ok_n}，失败 {fail_n}，总耗时 {round((time.time()-t0)/60,1)} min")
    print(f"明细：{log_path}")
    return 0 if fail_n == 0 else 2


def main() -> int:
    ap = argparse.ArgumentParser(description="Hive CBO 统计信息补全工具")
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--rebuild", action="store_true", help="重新扫描 ETL 脚本，忽略缓存")
    common.add_argument("--verbose", action="store_true")
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("probe", parents=[common], help="体检：看被引用表有没有数据")
    p.add_argument("--top", type=int, default=15)
    p.add_argument("--sample", type=int, default=5, help="抽几张表跑 count(*)")
    # ★ A7（2026-11-09 评审）：给定时抽样 count(*) 带分区过滤，不再扫全部分区
    p.add_argument("--partition", default="", help="分区过滤，如 20261029 或 p_dt=20261029")
    p.set_defaults(func=cmd_probe)

    for name, func in (("gen", cmd_gen), ("run", cmd_run)):
        q = sub.add_parser(name, parents=[common])
        q.add_argument("--min-refs", type=int, default=1, help="只处理引用次数 >= N 的表")
        q.add_argument("--top", type=int, default=0, help="只处理前 N 张（0=不限）")
        q.add_argument("--partition", default="", help="分区值，如 20261029")
        q.add_argument("--with-columns", action="store_true", help="含 FOR COLUMNS（更准更慢）")
        q.set_defaults(func=func)

    sub.choices["run"].add_argument("--dry-run", action="store_true")
    sub.choices["run"].add_argument("--keep-going", action="store_true")
    sub.choices["run"].add_argument("--timeout", type=int, default=1800)

    args = ap.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
