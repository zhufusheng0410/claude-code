#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DWD 生成脚本 SQL 校验 —— 在本地 Hive 容器上**真实编译**（EXPLAIN，不执行）。

为什么需要它
------------
生成器重跑后，DWD 的 DDL / ETL 是「看起来对」的，但要上了集群才知道能不能编译。
单独靠肉眼看 SQL 抓不出：16 路 LEFT JOIN 的列名拼写、类型比较、列数错位……

做法
----
1. **DDL 校验**：把 `scripts/*/dwd/01_ddl.sql` 的全部 CREATE TABLE 建进**临时
   schema**（`dwdxday_syn_chk`，跑完 DROP，不碰真实的 `dwdxday`）。
   ⇒ 既验证 DDL 语法，又给 ETL 一套「与生成物完全一致」的上游结构，
   **把「集群旧表漂移」与「生成脚本自身问题」隔离开**。
2. **ETL 校验**：从每个 `02_etl/*.sh` 抽出 `inceptor_beeline "…"` 块内的 SQL，
   替换 `${p_end_dt}`/`${p_start_dt}` 日期变量，把 `DWDXDAY.` 换成临时 schema，
   用 `EXPLAIN INSERT OVERWRITE …` **逐条编译**（不落数据）。
3. 每条 SQL 后跟 `SELECT '__P__<n>__'` 探针；输出流按探针**切段**，
   **段内出现 `Error:` 即该条失败**（beeline 把错误打到 stderr，已合并进
   stdout 以保住「语句→错误→探针」的交错顺序）；探针缺失 = 会话级异常，单独重跑确认。
   ⚠ 历史教训（2026-10-11 连踩两坑）：① 一开始以为 `--force=true` 会让
    beeline 遇错继续、不加就停——**stdin 模式两种都继续**，失败语句的探针
    照样打印 ⇒ 假阳性（曾把全失败报成 87/87）。只能靠输出段解析，勿回退。
    ⚠ 2026-10-19（J-31）两处修正：
    ① `*_TMP*` 表在沙箱内**真建**（见 explain_wrap）——多段脚本「先 DROP 再 CREATE
       临时表」的结构与脚本运行态一致，不再拿归档 DDL 顶替导致列数假阴性；
    ② `--sys` **只过滤 ETL 扫描**，DDL 构建始终全量（此前一起被过滤 → 沙箱缺别的
       系统的表，单系统校验被迫用 `--real`，又受集群旧表漂移干扰）。

用法
----
    python3 tools/ds-deploy/validate-dwd-syntax.py                 # 全量（DDL+ETL）
    python3 tools/ds-deploy/validate-dwd-syntax.py --ddl-only
    python3 tools/ds-deploy/validate-dwd-syntax.py --etl-only --par 3 --batch 6
    python3 tools/ds-deploy/validate-dwd-syntax.py --sys O32       # 只校验 ETL（DDL 全量建沙箱）
    python3 tools/ds-deploy/validate-dwd-syntax.py --only DWD_AGMT_DPSI_AGMT_PFD,DWD_PROD  # 只校验指定表
    python3 tools/ds-deploy/validate-dwd-syntax.py --keep          # 保留临时 schema

前置：docker 里有 hive 容器（hiveserver2），beeline 走 CUSTOM 认证（hive/hive）。
"""
import argparse
import json
import os
import re
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))

sys.path.insert(0, HERE)
from ds_config import hive_password, hive_user  # noqa: E402
GEN_ROOT = os.path.normpath(os.path.join(HERE, "..", "..", "scripts"))
REPORT_DIR = os.path.join(HERE, "..", ".dx-tmp")
REPORT_PATH = os.path.join(REPORT_DIR, "dwd-syntax-check.json")

SANDBOX = "dwdxday_syn_chk"          # 临时 schema（跑完 DROP）
DATE = "20261011"                    # 编译用固定分区日期（只编译、不执行）
DATE_PREV = "20261010"
CONTAINER = "hiveserver2"
JDBC = "jdbc:hive2://localhost:10000/default"
# ★ 2026-10-22：口令不再有源码缺省值，从 ds_config 取
#   （环境变量 DS_HIVE_PASSWORD / .env.local / ~/.dw-secrets.env），缺失即报错。
#   ⚠ 已知残留风险：beeline 的 `-p` 会把口令放进 docker exec 的 argv，
#   同机其他用户可用 `ps` 读到。彻底消除需改用 stdin 提示方式，
#   但本脚本的 stdin 已被 SQL 占满（`docker exec -i`），二者无法共存。
DS_USER = hive_user()
DS_PWD = hive_password()

RE_CREATE = re.compile(
    r"\bCREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?DWDXDAY\s*\.\s*([A-Za-z0-9_]+)", re.I)
RE_DWD_REF = re.compile(r"\bDWDXDAY\s*\.", re.I)
RE_MARK = re.compile(r"__P__([A-Za-z0-9_]+)__")
RE_ERR = re.compile(r"Error:\s*(.+)", re.I)
# ★ J-12：beeline 非 tty 输出会把提示符与错误/结果挤在同一物理行（无换行），
#   单纯 splitlines 取不到错误行；先剥掉所有 `0: jdbc:...>` 提示符再抽错误文本。
RE_PROMPT = re.compile(r"\d*:?\s*jdbc:[^\s>]*>\s*")


# ---------------------------------------------------------------- SQL 文本处理
def strip_comments(sql: str) -> str:
    """去掉 `--` 行注释（引号内的不动）。"""
    out, i, n = [], 0, len(sql)
    in_q = False
    while i < n:
        c = sql[i]
        if c == "'":
            in_q = not in_q
        if c == "-" and not in_q and i + 1 < n and sql[i + 1] == "-":
            j = sql.find("\n", i)
            i = n if j < 0 else j          # 跳到行尾（保留换行由下一轮带入）
            continue
        out.append(c)
        i += 1
    return "".join(out)


def split_statements(sql: str) -> list:
    """按顶层分号切分（引号内的分号不算）。"""
    stmts, buf, in_q = [], [], False
    for c in sql:
        if c == "'":
            in_q = not in_q
        if c == ";" and not in_q:
            s = "".join(buf).strip()
            if s:
                stmts.append(s)
            buf = []
        else:
            buf.append(c)
    tail = "".join(buf).strip()
    if tail:
        stmts.append(tail)
    return stmts


def explain_wrap(sql: str, sandbox: bool = False) -> str:
    """把 ETL 里的查询语句包成 `EXPLAIN`（只编译、不执行、不落数据）。

    ★ 2026-10-13 修复（J-12）：docstring 一直写着「EXPLAIN 编译」，但 main()
    把**裸 INSERT** 直接喂给 beeline（--autoCommit=true 会真实写入/真实执行）——
    全量校验 ETL 0/xx 全判失败、msg 只剩 jdbc 提示符回显（语句超时或写库被拒）。
    修法：逐语句拆分后，对 INSERT/SELECT/WITH/CREATE 等查询语句加 EXPLAIN 前缀，
    `set ...` 等会话命令保持原样（保留动态分区等编译所需开关）。

    ★ 2026-10-19（J-31）：多段脚本的 `*_TMP*` 表改为**沙箱内真建**——
    EXPLAIN 不会执行 DROP/CREATE，脚本运行时「先 DROP 再 CREATE 临时表」的
    结构只能拿归档 DDL 顶替，一旦归档版与脚本版不一致就产生列数假阴性
    （实证：DWD_PTY_ORG_NUM_MAPP_PFD，归档 10 列+P_DT 分区 vs 脚本 10 列无分区）。
    修法：沙箱模式下把**表名**含 `_TMP` 的 DROP/CREATE（非 CTAS）真执行，
    INSERT/SELECT 仍 EXPLAIN ⇒ 临时表结构与脚本运行态完全一致。
    `--real` 模式传 sandbox=False，**绝不真执行**任何语句。
    """
    re_tmp = re.compile(
        r"\b(?:CREATE|DROP)\s+TABLE\s+(?:IF\s+(?:NOT\s+)?EXISTS\s+)?"
        r"(?:[A-Za-z0-9_]+\s*\.\s*)?([A-Za-z0-9_]+)", re.I)
    parts = []
    for s in split_statements(strip_comments(sql)):
        head = s.lstrip()[:10].upper()
        m = re_tmp.search(s) if head.startswith(("CREATE", "DROP")) else None
        if (sandbox and m and "_TMP" in m.group(1).upper()
                and not re.search(r"\bAS\s+SELECT\b", s, re.I)):
            parts.append(s + ";")          # 沙箱内真执行（临时表）
        elif head.startswith(("INSERT", "SELECT", "WITH", "CREATE",
                              "ALTER", "DROP", "MERGE")):
            parts.append("EXPLAIN\n" + s + ";")
        else:
            parts.append(s + ";")
    return "\n".join(parts)


def load_ddls() -> list:
    """从所有系统的 DWD 合并 DDL 收集 (表名, 语句)。

    ★ 2026-10-15：合并文件之外再兜底扫一轮 `*/dwd/ddl/*.sql` 单表文件——
      有的表没有 MAPPING 源、regen 不会进 01_ddl.sql（实测 `DWD_CMM_STD_DICT_CDVAL_MAP`
      这类映射表靠手工/集群落档），单表文件在就能被校验建进沙箱。按表名去重。
    """
    items, seen = [], set()

    def add_from(raw):
        for stmt in split_statements(strip_comments(raw)):
            m = RE_CREATE.search(stmt)
            if not m:
                continue
            tbl = m.group(1).upper()
            if tbl in seen:                 # 同一张表只取第一份
                continue
            seen.add(tbl)
            items.append((tbl, stmt))

    for ddl_file in sorted(_glob("*/dwd/01_ddl.sql", sys_filter=False)):
        with open(ddl_file, encoding="utf-8", errors="replace") as f:
            add_from(f.read())
    for ddl_file in sorted(_glob("*/dwd/ddl/*.sql", sys_filter=False)):
        with open(ddl_file, encoding="utf-8", errors="replace") as f:
            add_from(f.read())
    return items


def load_etls(sandbox: str = None) -> list:
    """从所有系统的 DWD ETL 收集 (表名, SQL)。

    SQL = 所有 `inceptor_beeline "…"` 块的内容（用 `;\n` 拼接）。
    ★ 2026-10-15：甲方脚本存在**一个文件多段 beeline 调用**（先建临时表再装载，
      如 DWD_PTY_CNTP_NUM_MAPP_PFD / DWD_PTY_ORG_NUM_MAPP_PFD）。原「首个引号 →
      文件最后一个引号」会把两段之间的 shell 函数定义/调用行整段吞进 SQL，
      解析必炸（首错形如 `cannot recognize input near 'set' 'hive' '.'`）。
      改为逐块提取：起点 = `inceptor_beeline "`，终点 = **独立成行的 `"`**；
      找不到独立收尾引号时退化为旧行为（rfind）。
    `sandbox` 非空时把 DWDXDAY. 换成该 schema（校验用）；为空则保持真实目标表
    （真实执行用）。
    """
    items = []
    for sh in sorted(_glob("*/dwd/02_etl/*.sh")):
        name = os.path.basename(sh)[:-3].upper()
        with open(sh, encoding="utf-8", errors="replace") as f:
            raw = f.read()
        blocks = []
        for m in re.finditer(r'inceptor_beeline\s*"', raw):
            start = m.end()
            m2 = re.search(r'^[ \t]*"[ \t]*$', raw[start:], re.M)
            if m2:
                blocks.append(raw[start:start + m2.start()])
            else:
                blocks.append(raw[start:raw.rfind('"')])
                break
        if not blocks:
            continue
        sql = ";\n".join(b.strip() for b in blocks if b.strip()).strip()
        # ★ J-17（2026-10-13）：SQL 处于 shell 双引号内，保留字别名反引号被转义成
        #   `\`DATE\``（运行时 shell 还原成 `DATE`，脚本本身正确）。此处拿到的是
        #   转义前原文，直接喂 beeline 会报「character '\' not supported」。
        #   按 bash 双引号规则还原 \$ \` \" \\ 四种转义（\u4e00 等正则反斜杠不受影响）。
        sql = re.sub(r'\\([$`"\\])', r'\1', sql)
        sql = sql.replace("${p_end_dt}", DATE).replace("${p_start_dt}", DATE)
        if sandbox:
            sql = RE_DWD_REF.sub(sandbox + ".", sql)
        items.append((name, sql))
    return items


def _glob(rel: str, sys_filter: bool = True) -> list:
    """★ 2026-10-19（J-31）：`sys_filter=False` 让 DDL 构建不受 `--sys` 影响——
    沙箱必须全量建表，否则跨系统引用（如 MASTER 甲方表）在单系统校验时假失败。"""
    import glob
    hits = glob.glob(os.path.join(GEN_ROOT, rel))
    want = os.environ.get("_DWD_SYS_FILTER") if sys_filter else None
    if want:
        hits = [h for h in hits
                if os.path.relpath(h, GEN_ROOT).split(os.sep)[0].upper() == want]
    return hits


# ---------------------------------------------------------------- beeline 执行
def beeline(sql: str, timeout: int = 900, force: bool = False) -> tuple:
    """在 hive 容器里跑一段 SQL，返回 (returncode, stdout, stderr)。

    ★ stderr **合并进 stdout**（`stderr=STDOUT`）：beeline 把 `Error: …` 打到
    stderr，而 run_batch 要靠「探针切分输出段、段内有无 Error:」判定每条语句
    成败——分开捕获会丢失语句与错误的**交错顺序**，无法定位到具体语句。
    （2026-10-11 教训：stdin 模式下 beeline 默认遇错继续，--force 与否都继续，
    所以「不加 force 就会停」不成立，只能靠输出段解析。）
    """
    cmd = ["docker", "exec", "-i", "-e", "TERM=dumb", CONTAINER,
           "beeline", "-u", JDBC, "-n", DS_USER, "-p", DS_PWD,
           "--silent=true", "--outputformat=tsv2", "--showHeader=false",
           "--autoCommit=true"]
    if force:
        cmd.append("--force=true")
    r = subprocess.run(cmd, input=sql.encode("utf-8"),
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                       timeout=timeout)
    out = r.stdout.decode("utf-8", errors="replace")
    return r.returncode, out, ""


def run_batch(items: list, tag: str, batch: int, t0: float, par: int = 1) -> tuple:
    """**精确**逐条判定成败（按「探针切分输出段 + 段内有无 Error:」判定）。

    ⚠ 历史教训（2026-10-11 连踩两坑）：
    ① `--force=true` 下 beeline 遇错**继续**执行 ⇒ 失败语句的探针照样打印
       ⇒ 假阳性（曾把全失败报成 87/87）；
    ② 原以为「不加 --force 遇错即停」——**不成立**，stdin 模式默认就继续。
    ✅ 正解：输出流里「语句 → (若有错) Error:… → 探针」顺序固定，
       把输出按探针切段，**段内出现 `Error:` 即该条失败**；探针本身合法，
       只要会话没崩就会打印 ⇒ 探针缺失 = 会话级失败，单独重跑确认。
    返回 (passed, failed)；failed = [(key, item, errmsg)]。
    """
    by_key = {}
    batches = []
    for b in range(0, len(items), batch):
        chunk = items[b:b + batch]
        keys, sql_parts = [], ["-- batch @%d (%d 条)" % (b, len(chunk))]
        for k, (_, stmt) in enumerate(chunk):
            key = "%s%d" % (tag, b + k)
            keys.append(key)
            by_key[key] = chunk[k]
            sql_parts.append(stmt.rstrip().rstrip(";")
                             + ";\nSELECT '__P__%s__' AS chk;" % key)
        batches.append((keys, "\n".join(sql_parts)))

    passed, failed = [], []
    lock = threading.Lock()
    done = [0]

    def work(job):
        keys, sql = job
        try:
            _, out, _ = beeline(sql)
        except Exception as e:
            # ★ 2026-10-12：HS2 挂起/超时时不让整个运行崩——本批全部记缺失，
            #   逐条走单跑重试（单跑超时则记失败，不影响其他批）。
            out = ""
            print("  [%s] 批次超时/异常：%s" % (tag, str(e)[:100]), flush=True)
        # 按探针切段：tokens = [stmt0输出, key0, stmt1输出, key1, stmt2输出, ...]
        tokens = re.split(r"__P__([A-Za-z0-9]+)__", out)
        seg_of = {}                      # key -> 该 key 对应语句的输出段
        if keys:
            seg_of[keys[0]] = tokens[0]
        for i, k in enumerate(keys[:-1]):
            if 2 * i + 2 < len(tokens):
                seg_of[keys[i + 1]] = tokens[2 * i + 2]
        with lock:
            done[0] += 1
            for key in keys:
                name, stmt = by_key[key]
                if key not in seg_of:    # 探针没打出来 ⇒ 会话级异常，重跑确认
                    solo = (stmt.rstrip().rstrip(";")
                            + ";\nSELECT '__P__%s__' AS chk;" % key)
                    try:
                        _, o2, _ = beeline(solo)
                    except Exception as e2:
                        failed.append((key, by_key[key],
                                       "会话超时/异常: %s" % str(e2)[:120]))
                        continue
                    if re.search(r"__P__%s__" % key, o2) and "Error:" not in _seg_before(o2, key):
                        passed.append((key, by_key[key]))
                        continue
                    _cat, msg = classify(RE_PROMPT.sub(" ", o2))
                    failed.append((key, by_key[key], "会话中断?: %s" % msg[:200]))
                    continue
                if "Error:" in seg_of[key]:
                    # ★ J-12：错误与提示符同行 ⇒ 先剥提示符再用 RE_ERR 抽错误文本
                    m = RE_ERR.search(RE_PROMPT.sub(" ", seg_of[key]))
                    first_err = (m.group(1).strip() if m else
                                 RE_PROMPT.sub(" ", seg_of[key]).strip())[:250]
                    failed.append((key, by_key[key], first_err))
                else:
                    passed.append((key, by_key[key]))
            print("  [%s] 批次 %d/%d 完成 真失败累计 %d （%.0fs）"
                  % (tag, done[0], len(batches), len(failed),
                     time.time() - t0), flush=True)

    with ThreadPoolExecutor(max_workers=max(1, par)) as ex:
        list(ex.map(work, batches))
    return passed, failed


def _seg_before(out: str, key: str) -> str:
    """单跑重试时取 key 探针**之前**的输出段（含该语句自己的输出/错误）。"""
    i = out.find("__P__%s__" % key)
    return out[:i] if i >= 0 else out


def classify(err_text: str) -> tuple:
    """把 beeline 错误归类 → (类别, 摘要)。"""
    m = RE_ERR.search(err_text)
    msg = m.group(1).strip().split("\n")[0] if m else err_text.strip()[:200]
    if "ParseException" in msg:
        return "语法错误(ParseException)", msg
    if "Error 10044" in msg:
        return "列数不符(SELECT vs DDL)", msg
    if "Table not found" in msg or "Invalid table alias" in msg:
        return "表不存在", msg
    if "not found" in msg or "Invalid column" in msg:
        return "列不存在", msg
    if "SemanticException" in msg:
        return "语义错误", msg
    return "其他错误", msg


# ---------------------------------------------------------------- 主流程
def main():
    ap = argparse.ArgumentParser(description="DWD 生成脚本 SQL 编译校验")
    ap.add_argument("--ddl-only", action="store_true", help="只校验 DDL")
    ap.add_argument("--etl-only", action="store_true", help="只校验 ETL")
    ap.add_argument("--real", action="store_true",
                    help="ETL 对【真实 dwdxday】编译（EXPLAIN 只编译不写数据，安全），"
                         "跳过 sandbox。用于 sandbox 缺甲方维护表（DWD_CMM_STD_DICT_CDVAL_MAP 等）"
                         "导致 Table not found 假失败的场景；前提是真实库 DDL 已与生成物对齐")
    ap.add_argument("--batch", type=int, default=6, help="每批编译条数（默认 6）")
    ap.add_argument("--par", type=int, default=3, help="并行 beeline 会话数（默认 3）")
    ap.add_argument("--keep", action="store_true", help="保留临时 schema 不删")
    ap.add_argument("--sys", help="只校验某系统的 ETL（如 O32/HSFA/HSZTA）；DDL 构建仍全量")
    ap.add_argument("--only", help="只校验指定表（逗号分隔，支持前缀片段）")
    args = ap.parse_args()

    if args.sys:
        os.environ["_DWD_SYS_FILTER"] = args.sys.upper()

    do_ddl, do_etl = not args.etl_only, not args.ddl_only
    if args.real:
        do_ddl = False          # real 模式：真实库 DDL 假定已对齐，跳过 sandbox 重建
    t0 = time.time()
    report = {"sandbox": SANDBOX if not args.real else "(real dwdxday)",
              "date": DATE, "ddl": {}, "etl": {}}

    ddls = load_ddls() if do_ddl else []
    etls = load_etls(sandbox=None if args.real else SANDBOX) if do_etl else []
    if do_etl:
        # ★ J-12：ETL 一律包 EXPLAIN 再编译（只编译不执行/不落数据）；
        #   J-31 例外：沙箱模式下 `*_TMP*` 的 DROP/CREATE 真执行（见 explain_wrap）
        etls = [(t, explain_wrap(s, sandbox=not args.real)) for t, s in etls]
    if args.only:
        want = [w.strip().upper() for w in args.only.split(",") if w.strip()]
        etls = [(t, s) for t, s in etls
                if any(t.startswith(w) or w in t for w in want)]
    print("收集到 DDL %d 张表、ETL %d 个脚本（来自 %s）%s" %
          (len(ddls), len(etls), GEN_ROOT,
           "【REAL 模式：对真实 dwdxday 编译】" if args.real else ""), flush=True)

    if do_ddl or (do_etl and not args.real):
        rc, out, err = beeline("CREATE DATABASE IF NOT EXISTS %s;" % SANDBOX)
        if "Error" in out + err:
            print("建 schema 失败：\n" + (out + err)[:2000])
            return 2

    if do_ddl:
        print("── DDL 校验：建临时 schema %s（先 DROP 再 CREATE） ──" % SANDBOX, flush=True)
        items = []
        for t, s in ddls:
            items.append((t, "DROP TABLE IF EXISTS %s.%s;\n%s"
                          % (SANDBOX, t, RE_DWD_REF.sub(SANDBOX + ".", s))))
        _, failed = run_batch(items, "D", args.batch, t0, args.par)
        report["ddl"] = {"total": len(items), "failed": _detail(failed)}
        print("  DDL: %d/%d 通过" % (len(items) - len(failed), len(items)), flush=True)

    if do_etl:
        print("── ETL 校验：EXPLAIN 编译（不执行、不落数据） ──", flush=True)
        _, failed = run_batch(etls, "E", args.batch, t0, args.par)
        detail = []
        for key, (name, _sql), msg in failed:
            cat, _m = classify(msg)
            detail.append({"table": name, "kind": cat, "msg": msg})
            print("  ✗ %-42s %s\n      %s" % (name, cat, msg[:300]), flush=True)
        report["etl"] = {"total": len(etls), "failed": detail}
        print("  ETL: %d/%d 通过" % (len(etls) - len(detail), len(etls)), flush=True)

    if not args.keep and not args.real:
        beeline("DROP DATABASE IF EXISTS %s CASCADE;" % SANDBOX)
    os.makedirs(REPORT_DIR, exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)

    print("─────────────────────────────────────────────")
    print("完成  耗时 %.0fs  报告 → %s" % (time.time() - t0, REPORT_PATH))
    if report.get("ddl", {}).get("failed") or report.get("etl", {}).get("failed"):
        print("⚠ 存在失败项，详见报告或上方 ✗ 列表")
        return 1
    print("✓ DWD 生成脚本全部编译通过")
    return 0


def _detail(failed: list) -> list:
    return [{"table": name, "msg": msg} for _key, (name, _s), msg in failed]


if __name__ == "__main__":
    sys.exit(main())
