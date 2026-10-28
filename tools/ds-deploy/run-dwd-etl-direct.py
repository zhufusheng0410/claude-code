#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""**真实执行** DWD ETL（绕开 DS，beeline 直跑 Hive），全量重刷 dwdxday。

与 `validate-dwd-syntax.py` 的分工：那个只**编译**（EXPLAIN，零副作用）；
本工具**真跑**——先按生成 DDL 重建线上表，再按血缘依赖分层（同层无依赖、
层间串行）真实执行 INSERT OVERWRITE，落真实分区数据，最后回采每张表行数。

★ 2026-10-15：已把原 `run-dwd-etl.py`（分层 + 行数回采 + EXCLUDE + ODS 前置检查）
  的能力合并进本工具，`run-dwd-etl.py` 随之退役（备份 `backup/run-dwd-etl-20261015-preretire.py`）。

为什么要先重建 DDL
------------------
线上 dwdxday 是旧结构（历史实测 87 张中 61 张与生成 DDL 漂移），
Hive 的 INSERT OVERWRITE **按位置**对应列 ⇒ 漂移表直接跑必报
`SemanticException [Error 10044]`。重建前已确认线上 0 分区（无数据损失），
DROP+CREATE 后目标结构与脚本 SELECT 严格一致。
（生成的 `01_ddl.sql` **只有 CREATE 没有 DROP** ⇒ 本工具自己拼 `DROP TABLE IF EXISTS`，
否则全部报 AlreadyExistsException，2026-10-11 踩坑。）

为什么要分层（拓扑）
--------------------
DWD 表之间有上下游（如 DWD_PROD_SCR_* 依赖 DWD_SCR_SCR_NUM_MAPP_PFD、
DWD_CMM_STD_DICT_CDVAL_MAP）——上游没数据，下游跑出来也是空。
依赖边来自 `dep-config-lineage/*.dep.json`（`ds-build-dependent-from-lineage.py` 的产物，
★权威血缘）；先 Kahn 拓扑定序，再在拓扑序上用**前向边**做最长路径分层，
保证「上游层 < 下游层」。环（甲方依赖表里有 2-环）按原序放开并告警。

资源闸门与并发
--------------
worker Tez AM 约 1.5 GiB ⇒ WSL `MemAvailable` < 阈值就等。
**默认全程串行**（并发 DAG > 2 会打爆 worker，10-08 凌晨踩过）；
如需层内并行，用 `--exec-par N`（默认 1），代价自负。

用法
----
    python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010 --dry-run
    python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010              # 全量（重建DDL+执行+回采）
    python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010 --skip-ddl  # 只执行（DDL已对齐）
    python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010 --only A,B  # 只跑指定表
    python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010 --no-count  # 跳过行数回采
    python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010 --exec-par 2  # 层内并行（慎用）

报告：tools/.dx-tmp/dwd-etl-run.json（逐表 耗时/成败/错误摘要 + 行数回采 + 0 行清单）。
成败判定 = 探针存在**且**探针前的输出段无 `Error:`——beeline 遇错也继续、
探针照样打印，只看探针会**假阳性**（2026-10-11 踩坑，详见
validate-dwd-syntax.py::run_batch 的历史教训注释）。
"""
import argparse
import glob
import importlib.util
import json
import os
import re
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "VLD", os.path.join(HERE, "validate-dwd-syntax.py"))
V = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(V)

REPORT_DIR = os.path.normpath(os.path.join(HERE, "..", ".dx-tmp"))
REPORT_PATH = os.path.join(REPORT_DIR, "dwd-etl-run.json")
DEPCFG_DEFAULT = os.path.join(HERE, "dep-config-lineage")
MEM_FLOOR_GIB = 1.6          # Tez AM 1.5G + 余量
MEM_WAIT_MAX_MIN = 90        # 内存闸门最长等待
EXEC_DATE_DEFAULT = "20261010"

# 2 张指定排除表（编译即失败/含临时过程，真实执行无意义）。
# ★ 2026-10-27（J-36）：SALE_FEER / WARN_HIS / TAIL 三张已通过逐条 EXPLAIN 并同步 DS 转正，
#   从本排除表移除；占位白名单（DEFAULT_EMPTY）同步清空。
EXCLUDE = {
    "DWD_AST_BAL_INFO_PTM",
    "DWD_AST_VOU_INFO_PTD",
}

# ODS 前置抽样：防空转 ⇒ INSERT 0 行 的「假成功」
ODS_PROBE = ("SELECT 'probe', COUNT(1) FROM ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD "
             "WHERE P_DT = '%s'")


def mem_available_gib() -> float:
    try:
        with open("/proc/meminfo", encoding="utf-8") as f:
            for ln in f:
                if ln.startswith("MemAvailable:"):
                    return int(ln.split()[1]) / 1024 / 1024
    except OSError:
        return 99.0
    return 99.0


def wait_mem(floor: float, log) -> None:
    waited = 0
    while mem_available_gib() < floor and waited < MEM_WAIT_MAX_MIN:
        log("  内存闸门：MemAvailable %.1fG < %.1fG，等 30s…" %
            (mem_available_gib(), floor))
        time.sleep(30)
        waited += 0.5


def load_dep_edges(depcfg: str, targets: set) -> list:
    """从 dep json 推导 [上游源表, 目标表] 边（只保留两端都在 targets 里的）。"""
    edges = []
    for jf in sorted(glob.glob(os.path.join(depcfg, "*.dep.json"))):
        try:
            with open(jf, encoding="utf-8") as f:
                d = json.load(f)
        except (OSError, json.JSONDecodeError):
            continue
        tgt = str(d.get("target", "")).split(".")[-1].upper()
        if tgt not in targets:
            continue
        for cw in d.get("cross_workflow", []):
            for s in cw.get("sources", []):
                src = str(s.get("source", "")).split(".")[-1].upper()
                if src in targets:
                    edges.append((src, tgt))
    return edges


def topo_order(targets: list, edges: list) -> tuple:
    """Kahn 拓扑；环内节点按原序追加。返回 (顺序, 环内告警列表)。"""
    indeg = {t: 0 for t in targets}
    adj = {t: [] for t in targets}
    for s, t in set(edges):
        adj[s].append(t)
        indeg[t] += 1
    ready = [t for t in targets if indeg[t] == 0]   # 保持收集顺序 ⇒ 可复现
    order, cyclic = [], []
    seen = set()
    while ready:
        n = ready.pop(0)
        if n in seen:
            continue
        seen.add(n)
        order.append(n)
        for m in adj[n]:
            indeg[m] -= 1
            if indeg[m] == 0:
                ready.append(m)
    cyclic = [t for t in targets if t not in seen]
    return order, cyclic


def layerize(order: list, edges: list) -> dict:
    """在 Kahn 拓扑序上取**前向边**做最长路径分层；回边/环边忽略。

    order 已是合法拓扑序 ⇒ 真实依赖都是前向边（pos[s] < pos[t]），
    层号严格满足「上游层 < 下游层」；同层互不依赖 ⇒ 层内可并行、层间串行。
    """
    pos = {t: i for i, t in enumerate(order)}
    preds = {t: [] for t in order}
    for s, t in set(edges):
        ps, pt = pos.get(s), pos.get(t)
        if ps is not None and pt is not None and ps < pt:
            preds[t].append(s)
    lvl = {}
    for t in order:                       # 按拓扑序推进 ⇒ 前驱层号必已算出
        m = 0
        for p in preds[t]:
            if lvl.get(p, 0) + 1 > m:
                m = lvl[p] + 1
        lvl[t] = m
    return lvl


def rebuild_ddl(ddls: list, batch: int, par: int, t0: float, log) -> bool:
    """DROP+CREATE 全部生成 DDL（真实 dwdxday）。失败即返回 False。

    ★ 生成的 01_ddl.sql **只有 CREATE 没有 DROP** ⇒ 对已存在的表必须自己拼
    `DROP TABLE IF EXISTS`，否则全部报 AlreadyExistsException（2026-10-11 踩坑）。
    """
    log("── 阶段1/2：重建 DDL（%d 张，par=%d，先 DROP 再 CREATE） ──"
        % (len(ddls), par))
    items = [(t, "DROP TABLE IF EXISTS DWDXDAY.%s;\n%s" % (t, s)) for t, s in ddls]
    _, failed = V.run_batch(items, "D", batch, t0, par)
    if failed:
        for _key, (name, _stmt), msg in failed:
            log("  ✗ DDL 失败: %s — %s" % (name, msg[:200]))
        return False
    log("  DDL: %d/%d 重建成功" % (len(ddls), len(ddls)))
    return True


def run_etls(order: list, groups: dict, sqls: dict, date: str, timeout: int,
             exec_par: int, mem_floor: float, log) -> list:
    """按分层真实执行（默认串行 + 每表内存闸门；--exec-par>1 时层内并行）。"""
    mode = ("串行+内存闸门 %.1fG" % mem_floor if exec_par <= 1
            else "层内并行 %d + 内存闸门 %.1fG" % (exec_par, mem_floor))
    log("── 阶段2/2：真实执行 ETL（%d 个，date=%s，%s） ──"
        % (len(order), date, mode))
    results, lock = {}, threading.Lock()
    total = len(order)
    done = [0]
    t_all = time.time()

    def one(name: str, idx: int) -> None:
        marker = "__R__%d__" % idx
        stmt = sqls[name].rstrip().rstrip(";") + ";\nSELECT '%s' AS chk;" % marker
        t0 = time.time()
        try:
            # ★ 判定不能只看探针：beeline 遇错也继续，探针照样打印（假阳性踩坑）。
            #   正确判定 = 探针存在 **且** 探针之前的输出段无 `Error:`。
            _rc, out, err = V.beeline(stmt, timeout=timeout)
            ok = marker in out and "Error:" not in V._seg_before(out, marker)
            msg = "" if ok else V.classify(out + err)[1][:300]
        except Exception as e:                       # 超时等
            ok, msg = False, "执行异常: %s" % e
        secs = time.time() - t0
        with lock:
            results[name] = {"table": name, "ok": ok, "secs": round(secs, 1),
                             "msg": msg}
            done[0] += 1
            okc = sum(1 for r in results.values() if r["ok"])
            log("  [%3d/%3d] %-44s %s %.0fs%s"
                % (done[0], total, name, "OK " if ok else "FAIL", secs,
                   "" if ok else "  " + msg[:160]))
            if done[0] % 10 == 0:
                log("    ── 进度 %d/%d 成功 %d 失败 %d，累计 %.0f min ──"
                    % (done[0], total, okc, done[0] - okc,
                       (time.time() - t_all) / 60))

    idx = 0
    for lv in sorted(groups):
        batch = groups[lv]
        if exec_par > 1:
            wait_mem(mem_floor, log)                 # 每层起始等一次内存
            with ThreadPoolExecutor(max_workers=max(1, exec_par)) as ex:
                for i, n in enumerate(batch):
                    ex.submit(one, n, idx + i)
        else:
            for n in batch:
                wait_mem(mem_floor, log)             # 每表等一次内存
                one(n, idx)
        idx += len(batch)
    return [results[t] for t in order]


def collect_counts(order: list, date: str, log, chunk: int = 20) -> dict:
    """执行后批量回采每张表 P_DT=date 行数（0 行单独标注）。"""
    log("── 行数回采（P_DT=%s） ──" % date)
    stmts = ["SELECT '%s', COUNT(1) FROM DWDXDAY.%s WHERE P_DT = '%s';"
             % (t, t, date) for t in order]
    counts = {}
    for i in range(0, len(stmts), chunk):
        sql = "\n".join(stmts[i:i + chunk])
        try:
            _rc, out, _err = V.beeline(sql, timeout=900)
        except Exception as e:
            log("  回采批次 %d 超时/异常: %s" % (i // chunk, str(e)[:80]))
            continue
        for line in out.splitlines():
            # ★ beeline 每行带 `0: jdbc:...> ` 提示符前缀（J-12），
            #   不剥的话 `^DWD_\w+\t\d+$` 永远不匹配 ⇒ counts 全空（2026-10-14 踩坑）。
            m = re.match(r"^(DWD_\w+)\t(\d+)$",
                         V.RE_PROMPT.sub("", line).strip())
            if m:
                counts[m.group(1)] = int(m.group(2))
    return counts


def main():
    ap = argparse.ArgumentParser(description="真实执行 DWD ETL（直跑 Hive）")
    ap.add_argument("--date", default=EXEC_DATE_DEFAULT,
                    help="分区日期 p_end_dt/p_start_dt（默认 %(default)s）")
    ap.add_argument("--skip-ddl", action="store_true", help="跳过 DDL 重建（已对齐时）")
    ap.add_argument("--only", help="只跑指定表（逗号分隔）")
    ap.add_argument("--depcfg", default=DEPCFG_DEFAULT, help="依赖配置目录")
    ap.add_argument("--batch", type=int, default=10, help="DDL 每批条数")
    ap.add_argument("--par", type=int, default=3, help="DDL 并行会话数")
    ap.add_argument("--exec-par", type=int, default=1,
                    help="ETL 层内并行会话数（默认 1=串行；勿轻调高：并发 DAG>2 打爆 worker）")
    ap.add_argument("--timeout", type=int, default=1800, help="单表执行超时秒数（默认 1800）")
    ap.add_argument("--mem-floor", type=float, default=MEM_FLOOR_GIB,
                    help="内存闸门阈值 GiB（默认 %.1f；环境紧时可调低至 1.0-1.2）" % MEM_FLOOR_GIB)
    ap.add_argument("--no-count", action="store_true", help="跳过行数回采")
    ap.add_argument("--dry-run", "--dry", dest="dry_run", action="store_true",
                    help="只打印分层与顺序，不执行")
    args = ap.parse_args()

    def log(s):
        print(s, flush=True)

    t0 = time.time()
    # ★ 让 load_etls 直接把 ${p_end_dt}/${p_start_dt} 替换成**执行日期**
    #   （validate 默认值是编译用的 20261011，在 ODS 无分区 ⇒ 会 INSERT 0 行假成功）。
    V.DATE = args.date
    V.DATE_PREV = args.date
    ddls = V.load_ddls()
    etls = V.load_etls(sandbox=None)          # 保持真实 DWDXDAY 目标
    sqls = {t: s for t, s in etls}
    etls = [(t, s) for t, s in etls if t not in EXCLUDE]
    if args.only:
        want = [w.strip().upper() for w in args.only.split(",") if w.strip()]
        etls = [(t, s) for t, s in etls if any(t.startswith(w) or w in t for w in want)]

    targets = [t for t, _ in etls]
    edges = load_dep_edges(args.depcfg, set(targets))
    order, cyclic = topo_order(targets, edges)
    if cyclic:
        log("⚠ 依赖环 %d 张（放开环按原序执行）: %s" % (len(cyclic), cyclic[:10]))
    lvl = layerize(order, edges)
    groups = {}
    for t in order:
        groups.setdefault(lvl[t], []).append(t)

    log("DWD ETL %d 脚本（排除 %d 张指定表）/ DDL %d 张 / date=%s"
        % (len(etls), len(EXCLUDE), len(ddls), args.date))
    for lv in sorted(groups):
        log("  L%d: %s" % (lv, ", ".join(groups[lv])))
    if args.dry_run:
        log("（--dry-run 结束，未动任何数据）")
        return 0

    ddl_ok = True
    if not args.skip_ddl:
        ddl_ok = rebuild_ddl(ddls, args.batch, args.par, t0, log)
        if not ddl_ok:
            log("✗ DDL 重建失败，放弃执行（未跑任何 ETL）")
            return 2

    # ── 前置检查：ODS 执行日期分区是否有数（防空转假成功；非致命） ──
    try:
        _rc, out, _err = V.beeline(ODS_PROBE % args.date, timeout=120)
        m = re.search(r"probe\t(\d+)", out)
        if not m or m.group(1) == "0":
            log("⚠ ODS 抽样 TACCOUNT_PFD P_DT=%s 行数 0/查询失败——"
                "上游可能空转，继续执行但行数请以回采为准" % args.date)
        else:
            log("前置检查：ODS TACCOUNT_PFD P_DT=%s 共 %s 行 ✓" % (args.date, m.group(1)))
    except Exception as e:
        log("⚠ ODS 前置检查异常（忽略）: %s" % str(e)[:100])

    results = run_etls(order, groups, sqls, args.date, args.timeout,
                       args.exec_par, args.mem_floor, log)

    counts = {} if args.no_count else collect_counts(order, args.date, log)

    okc = sum(1 for r in results if r["ok"])
    fail = [r for r in results if not r["ok"]]
    zero = [r["table"] for r in results
            if r["ok"] and counts.get(r["table"], -1) == 0]

    log("─────────────────────────────────────────────")
    log("完成  总耗时 %.0f min  成功 %d / %d  报告 → %s"
        % ((time.time() - t0) / 60, okc, len(results), REPORT_PATH))
    if fail:
        log("✗ 失败 %d 张：" % len(fail))
        for r in fail:
            log("   %-44s %s" % (r["table"], r["msg"][:160]))
    if zero:
        log("⚠ 成功但 0 行 %d 张：%s" % (len(zero), ", ".join(zero)))
    if counts:
        log("── 行数一览（P_DT=%s）──" % args.date)
        for r in results:
            c = counts.get(r["table"])
            log("  %-44s %-4s %s"
                % (r["table"], "OK" if r["ok"] else "FAIL",
                   ("%d 行" % c) if c is not None else "?"))

    os.makedirs(REPORT_DIR, exist_ok=True)
    report = {
        "date": args.date, "ddl_rebuilt": ddl_ok,
        "total": len(results), "ok": okc, "fail": len(results) - okc,
        "excluded": sorted(EXCLUDE), "cyclic": cyclic,
        "levels": {str(k): v for k, v in sorted(groups.items())},
        "counts": counts, "zero_rows": zero,
        "results": results,
        "sec_total": round(time.time() - t0, 1),
    }
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main())
