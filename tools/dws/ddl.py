# -*- coding: utf-8 -*-
"""DDL 解析、清洗、落盘与比对（DWS 为主，DWD 侧只做存在性/委托）。"""
import datetime as dt
import json
import re
import shutil
import time
from pathlib import Path

from tools.core.ddl_compare import append_diff_section, compare_local_ddl
from tools.core.loader import load as _load_file

from tools.dws import state as st
from tools.dws.args import _dwd_ddl_cmd, layers_of, stale_allowed, strict_of
from tools.dws.manifest import (StaleDwsManifest, _guard_dws_manifest,
                                _safe_group, fail_stale)
from tools.dws.process import run


def _load_ddl_verify():
    """`tools/core/ddl_verify.py`（DDL 结构对比）。"""
    return _load_file(st.DDL_VERIFY)


def _dwd_sanitize_mod():
    """`tools/core/ddl_sanitize.py` **模块对象**（需要 sanitize_ddl 之外的函数时用）。

    ★ 2026-10-26：原先 exec 整个 `dwd-pipeline.py`（86KB，模块级 import openpyxl）只为拿
      `sanitize_ddl` ⇒ 缺 openpyxl 时 `ddl --layers DWS` 直接 ModuleNotFoundError。
      指向独立小模块（只依赖 re）。
    """
    return _load_file(st.REPO / "tools/core/ddl_sanitize.py")


def dws_table_sys_map(allow_stale=False):
    """DWS 表 → 系统。`ddl/*.sql` 落位优先，`_DWS搬移清单.json` 的 group 补缺。

    ★ 两源取**并集**：清单可能含已不在 ddl/ 下的表，ddl/ 也可能有清单未登记的表。
      只取其一会让 cmd_verify_ddl 静默跳过缺失的表（校验变弱、不报错）。
    ★ 清单带 sha256/bytes 时必须与现盘一致，否则抛 StaleDwsManifest（不改清单）。
    """
    data = _guard_dws_manifest(allow_stale)
    m = {}
    for s in st.SYS:
        for p in (st.SCRIPTS / s / "dws/ddl").glob("*.sql"):
            m[p.stem.upper()] = s
    if data is not None:
        for f in data.get("files") or []:
            if not isinstance(f, dict):
                continue
            name = f.get("name", "")
            group = _safe_group(f.get("group"))
            if isinstance(name, str) and name.endswith(".sh") and group:
                m.setdefault(name[:-3].upper(), group)
    return m


# 甲方 DDL 里 `DROP TABLE IF EXISTS` 与 `CREATE TABLE` 之间**可能没有分号**
# （实测 `02-DWS建表脚本.sql:1212` 的 `DWS_TRAN_FUTR_TRAN_DETAIL_PTD`）。
# 按 `;` + 换行切块后，该表所在 chunk 就成了
#   `DROP TABLE IF EXISTS X \nCREATE TABLE X (...);`
# 只认「DROP 行以 `;` 结尾」的剥法（`ddl_sanitize.strip_drop_stmts` 之前的版本）
# 会整条漏剥 ⇒ DROP 留在 CREATE 前面，落盘的 `ddl/*.sql` 与 `01_ddl.sql`
# 一上 beeline 就 ParseException，而 `diff_ddl` 只看列/分区/注释、**看不出来**。
def parse_jf_ddl(path):
    """解析甲方建表 sql → {表名大写: 已清洗的 CREATE 语句}（含 DROP 已剥离）。

    ★ 2026-10-27：原先 `build_dws_ddl_from_jf` 与 `cmd_verify_ddl` **各写了一遍**
      同样的「按 `;` 切分 → 抓 CREATE TABLE 表名 → 去单行 DROP → sanitize」。
      两份副本必然漂移（改一处忘另一处 ⇒ 落盘与校验用不同规则，校验就此失去意义）。
      抽成单一实现，两边共用。
    ★ 2026-11-09（评审 A1）：剥 DROP 改用 `strip_drop_stmts`，**不再要求 DROP 行
      自带分号**。甲方偶发的不规范写法（见上方注释）此前会被漏剥。
    """
    mod = _dwd_sanitize_mod()
    sanitize = mod.sanitize_ddl
    raw = Path(path).read_text(encoding="utf-8", errors="replace")
    stmts = {}
    for chunk in re.split(r";\s*(?:\r?\n)", raw):
        m = re.search(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:[A-Za-z0-9_]+\.)?"
                      r"([A-Za-z0-9_]+)", chunk, re.I)
        if not m:
            continue
        # 只移除 DROP TABLE IF EXISTS（分号可有可无），中间留 CREATE TABLE
        # ★ 2026-11-13：模块对象在循环外取一次 —— 每次 `_load_file` 都要算
        #   `realpath`（本机 drvfs 约 15ms），逐 chunk 调用曾占 DWD 建表解析的一半时间。
        body = mod.strip_drop_stmts(chunk)
        stmts.setdefault(m.group(1).upper(), sanitize(body))
    return stmts


def _dws_ddl_owner(stmts, allow_stale):
    """按归属把甲方 DWS 建表语句分到各系统，并打印统计（返回 have）。"""
    owner = dws_table_sys_map(allow_stale=allow_stale)
    have = {t: owner[t] for t in stmts if t in owner}
    miss = sorted(t for t in stmts if t not in owner)
    by_sys = {}
    for t, s in have.items():
        by_sys[s] = by_sys.get(s, 0) + 1
    print(f"  甲方 DWS 建表 {len(stmts)} 张 | 可归属 {len(have)} {by_sys} | 未归属 {len(miss)}")
    if miss:
        print("    未归属（跳过）:", miss)
    return have


def _backup_dws_ddl():
    """落盘前把现有 `ddl/` 与 `01_ddl.sql` 备份到 `tools/.dx-tmp`。"""
    ts = time.strftime("%Y%m%d-%H%M%S")
    bak = st.REPO / "tools/.dx-tmp" / f"backup-dws-ddl-{ts}"
    for s in st.SYS:
        d = st.SCRIPTS / s / "dws"
        if (d / "ddl").is_dir():
            shutil.copytree(d / "ddl", bak / s / "ddl", dirs_exist_ok=True)
        if (d / "01_ddl.sql").is_file():
            (bak / s).mkdir(parents=True, exist_ok=True)
            shutil.copy2(d / "01_ddl.sql", bak / s / "01_ddl.sql")
    return bak


def _write_dws_ddl(have, stmts):
    """逐表写 `ddl/*.sql`，再按系统重建 `01_ddl.sql`。"""
    for t, sysname in have.items():
        body = ("-- 来源: 甲方 02-DWS建表脚本.sql（dw-pipeline ddl）\n"
                + stmts[t] + ";\n")
        d = st.SCRIPTS / sysname / "dws/ddl"
        d.mkdir(parents=True, exist_ok=True)
        (d / f"{t}.sql").write_text(body, encoding="utf-8", newline="\n")
    for s in st.SYS:
        d = st.SCRIPTS / s / "dws/ddl"
        parts, seen = [], set()
        for f in sorted(d.glob("*.sql")):
            if f.stem.upper() in seen:
                continue
            seen.add(f.stem.upper())
            parts.append(f.read_text(encoding="utf-8", errors="replace").rstrip())
        (st.SCRIPTS / s / "dws/01_ddl.sql").write_text(
            "\n\n".join(parts) + "\n", encoding="utf-8", newline="\n")
        print(f"  {s}: 01_ddl.sql <- {len(parts)} 张表")


def build_dws_ddl_from_jf(apply, strict=True, allow_stale=False):
    """甲方 `02-DWS建表脚本.sql` → `scripts/{系统}/dws/ddl/*.sql` + `01_ddl.sql`。

    为什么要清洗：甲方脚本是 Inceptor 方言，含 `DEFAULT NULL`（Hive 4.2 不支持）
    与 `VARCHAR2(n)`；清洗规则与 DWD 共用 `sanitize_ddl`。
    逐表文件只留 CREATE（DROP 由重建步骤自己拼 `DROP TABLE IF EXISTS`）。
    ★ 2026-10-28：原先签名没有 `strict`，但落盘后自检失败时打印「加 --no-strict 可忽略继续」
      —— 那个开关**根本没被接收**，照提示操作依旧 rc=1（提示与行为相反）。
      现在真正接收 strict：False 时只告警不阻断。
    ★ 2026-11-13：拆出 `_dws_ddl_owner` / `_backup_dws_ddl` / `_write_dws_ddl`，
      输出顺序与拆分前逐行一致。
    """
    if not st.SRC_DWS_DDL.is_file():
        # ★ 2026-10-26：原先是 `return 0`（静默跳过）⇒ all 会带着旧 01_ddl.sql 一路走下去，
        #   而 verify 只查「文件在不在」，不看「内容是否过期」⇒ 假绿。
        #   甲方交付路径不可达属于环境问题，必须按失败上报（可用 DW_DELIVERY 指定）。
        print(f"  ✗ {st.SRC_DWS_DDL} 不存在：甲方交付目录不可达（可用 DW_DELIVERY 指定），"
              f"拒绝静默跳过")
        return 1
    stmts = parse_jf_ddl(st.SRC_DWS_DDL)
    if not stmts:
        print(f"  {st.SRC_DWS_DDL} 未解析出 CREATE TABLE")
        return 1
    have = _dws_ddl_owner(stmts, allow_stale)
    if not apply:
        print("  (dry-run，未落盘)")
        return 0

    bak = _backup_dws_ddl()
    _write_dws_ddl(have, stmts)
    print(f"  备份: {bak}")
    # 落盘后自检（本函数在非 apply 时已提前 return，此处必然 apply）
    rc = verify_ddl_after_write("DWS", have, stmts, st.SRC_DWS_DDL)
    if rc and strict:
        print("  ✗ DWS DDL 校验发现差异（已阻断）。加 --no-strict 可忽略继续。")
        return 1
    if rc:
        print("  ⚠ DWS DDL 校验发现差异（--no-strict：仅告警，不阻断）")
    return 0


def _print_ddl_diff(diff, indent="    ", limit=5):
    """打印一份 DDL 差异的明细（type/comment/partition/表注释/仅单边列）。

    ★ 2026-10-27：`verify_ddl_after_write` 与 `cmd_verify_ddl` 各自内联了这 6 个
      分支（连行文本都几乎逐字相同，只有截断条数不同）⇒ 抽成一份，用 `limit` 区分。
      漏改一处的后果是「某个维度静默不报」—— 正是校验代码最不该有的失效方式。
    """
    ll, rl = diff.left_label, diff.right_label
    if diff.table_name_mismatch:
        print(f"{indent}- 表名: {ll}={diff.table_name_mismatch[0]} "
              f"{rl}={diff.table_name_mismatch[1]}")
    if diff.type_mismatch:
        for col, lt, rt in diff.type_mismatch[:limit]:
            print(f"{indent}- 列 {col}: {ll}类型={lt} {rl}类型={rt}")
    if diff.comment_mismatch:
        for col, lc, rc in diff.comment_mismatch[:limit]:
            print(f"{indent}- 列 {col} 注释: {ll}='{lc}' {rl}='{rc}'")
    if diff.partition_mismatch:
        lpart = [f"{c.name}:{c.type}" for c in diff.left_partitions]
        rpart = [f"{c.name}:{c.type}" for c in diff.right_partitions]
        print(f"{indent}- 分区: {ll}=[{', '.join(lpart)}] {rl}=[{', '.join(rpart)}]")
    if diff.table_comment_mismatch:
        print(f"{indent}- 表注释: {ll}='{diff.table_comment_mismatch[0]}' "
              f"{rl}='{diff.table_comment_mismatch[1]}'")
    if diff.only_in_left:
        print(f"{indent}- 仅{ll}有列: {', '.join(diff.only_in_left)}")
    if diff.only_in_right:
        print(f"{indent}- 仅{rl}有列: {', '.join(diff.only_in_right)}")


def _write_drift_report(layer, ts, drift_items, lint_hits, jf_source):
    """把落盘自检的问题写成 Markdown（与 DWS 的 ddl-drift 报告同目录）。"""
    report = st.REPO / "tools/.dx-tmp" / f"ddl-drift-{layer.lower()}-{ts}.md"
    report.parent.mkdir(parents=True, exist_ok=True)
    lines = [f"# {layer} DDL 与甲方差异报告 ({ts})", "", f"来源: {jf_source}", ""]
    for table, sysname, diff in drift_items:
        append_diff_section(lines, table, sysname, diff)
        lines.append("")
    if lint_hits:
        lines.append("## DDL 文件名或语句边界问题")
        lines.append("")
        for table, sysname, probs in lint_hits:
            for p in probs:
                lines.append(f"- **{table}** ({sysname}): {p}")
        lines.append("")
    report.write_text("\n".join(lines), encoding="utf-8")
    print(f"  差异报告: {report}")


def verify_ddl_after_write(layer: str, have: dict, stmts: dict, jf_source: Path):
    """落盘后把本地 DDL 与甲方原文逐表对比，打印差异并返回非零退出码（如有差异）。

    ★ 2026-11-09（评审 A1）：并列做**语句边界 lint**（`core/ddl_verify.lint_statements`）。
      `diff_ddl` 只比列/分区/注释，甲方「DROP 缺分号 + 紧跟 CREATE」这类写法会被
      它判成「一致」而假绿；beeline 按 `;` 切分执行时却必然 ParseException。
      语句边界是**执行层**属性，必须单独一道。
    ★ 2026-11-13：报告写出拆到 `_write_drift_report`（原函数 75 行）。
    ★ 2026-11-18：逐表比对（读盘 + diff + 语句边界 lint）收进
      `core/ddl_compare.compare_local_ddl`，与 DWD 落盘自检、`verify-ddl`
      共用一份内核；原 4 份副本改一处忘另一处就会让某条链路静默不校验。
    """
    all_ok = True
    drift_items = []
    lint_hits = []
    for table, sysname in have.items():
        local_path = st.SCRIPTS / sysname / f"{layer.lower()}/ddl/{table}.sql"
        # 甲方原文：从 stmts 拿（已 sanitize）；读盘+比对+lint 走共用内核
        diff, probs = compare_local_ddl(local_path, stmts[table])
        if diff is None:
            print(f"  ⚠ {table}: 本地文件不存在 {local_path}")
            all_ok = False
            continue
        if probs:
            all_ok = False
            lint_hits.append((table, sysname, probs))
            print(f"  ✗ {table} ({sysname}) DDL 文件检查: {probs[0]}")
        if not diff.empty():
            all_ok = False
            drift_items.append((table, sysname, diff))
            print(f"  ✗ {table} ({sysname}) 差异: {diff.summary()}")
            _print_ddl_diff(diff)
        elif not probs:
            print(f"  ✓ {table} ({sysname}) 与甲方一致")

    if not all_ok:
        _write_drift_report(layer, time.strftime("%Y%m%d-%H%M%S"),
                            drift_items, lint_hits, jf_source)
    return 0 if all_ok else 1


def _stale_warn(src, dst, label):
    """产物比来源旧 ⇒ 提示（verify 只查「文件在不在」，查不出「内容过期」）。

    ★ 为什么 +1：FAT/NTFS 的 mtime 精度与 copy2 保留时间戳会造成同秒误报。
    """
    if not dst.is_file() or not src.is_file():
        return False
    if src.stat().st_mtime > dst.stat().st_mtime + 1:
        print(f"  ⚠ {label} 早于来源（{src.name} 更新过）⇒ 需重跑 ddl 子命令（--apply）")
        return True
    return False


def cmd_ddl(args):
    layers = layers_of(args)
    strict = strict_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD DDL ==")
        if args.source == "jf":
            rc |= run(_dwd_ddl_cmd(args))[0]
        else:
            # ★ 2026-11-09（评审 C3）：主数据 DDL（scripts/MASTER/dwd/01_ddl.sql）
            #   也是交付物，gen 模式的存在性检查不能只看 SYS。
            for s in st.GROUPS:
                p = st.ddl_main(s)
                print(f"  {s}: {'OK' if p.is_file() else '缺失'} {p}")
                rc |= 0 if p.is_file() else 1
    if "DWS" in layers:
        print("== DWS DDL ==")
        if args.source == "jf":
            try:
                rc |= build_dws_ddl_from_jf(
                    args.apply, strict, allow_stale=stale_allowed(args))
            except StaleDwsManifest as exc:
                return fail_stale(exc)
            if strict:
                for s in st.SYS:
                    _stale_warn(st.SRC_DWS_DDL, st.SCRIPTS / s / "dws/01_ddl.sql",
                                f"{s} DWS 01_ddl.sql")
        else:
            for s in st.SYS:
                p = st.SCRIPTS / s / "dws/01_ddl.sql"
                d = st.SCRIPTS / s / "dws/ddl"
                n = len(list(d.glob("*.sql"))) if d.is_dir() else 0
                print(f"  {s}: 01_ddl {'OK' if p.is_file() else '缺失'} / 按表 {n}")
                rc |= 0 if p.is_file() else 1
    return rc


def local_ddl_paths(layer):
    """`{表名大写: 本地 ddl 文件}`（DWD 含 MASTER/dwd/ddl，DWS 只有三系统）。"""
    dirs = [st.SCRIPTS / s / layer.lower() / "ddl" for s in st.SYS]
    if layer == "DWD":
        dirs.append(st.SCRIPTS / "MASTER/dwd/ddl")
    m = {}
    for d in dirs:
        if not d.is_dir():
            continue
        for p in sorted(d.glob("*.sql")):
            m.setdefault(p.stem.upper(), p)
    return m


def _load_drift_allowlist():
    """读登记豁免清单。文件缺失或坏掉 ⇒ 返回空字典（等于没登记，校验照常失败）。

    ★ 2026-11-19：清单**随仓库提交**。不放 `tools/.dx-tmp/`——那是 gitignored 的
      运行产物，清理一次就会静默解除豁免，等于给校验开后门。
    """
    path = st.REPO / "tools/dwd_ddl_drift_allowlist.json"
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}
    tables = data.get("tables") if isinstance(data, dict) else None
    return tables if isinstance(tables, dict) else {}


def _drift_is_registered(diff, entry):
    """差异是否**全部**落在登记列内。有一列越界就返回 False（不豁免）。

    只认列级差异（仅一侧有列 / 类型 / 注释）。分区、表注释这类整体性差异
    即使表在清单里也不豁免——它们通常意味着表结构本身变了。
    """
    if not isinstance(entry, dict):
        return False
    reason = entry.get("reason")
    registered = entry.get("registered")
    if (not isinstance(reason, str) or not reason.strip()
            or not isinstance(registered, str)
            or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", registered)):
        print(f"  ⚠ {diff.table} 豁免登记缺少有效 reason 或 registered，不予豁免")
        return False
    try:
        dt.date.fromisoformat(registered)
    except ValueError:
        print(f"  ⚠ {diff.table} 豁免登记日期无效，不予豁免")
        return False
    columns = entry.get("columns")
    if not isinstance(columns, list) or not columns or not all(
        isinstance(c, str) and c.strip() for c in columns
    ):
        print(f"  ⚠ {diff.table} 豁免登记无效：columns 必须是非空字符串列表，不予豁免")
        return False
    cols = {c.strip().upper() for c in columns}
    if (diff.table_name_mismatch or diff.partition_mismatch or
            diff.table_comment_mismatch is not None):
        return False
    touched = set()
    touched.update(str(c).strip().upper() for c in diff.only_in_left)
    touched.update(str(c).strip().upper() for c in diff.only_in_right)
    touched.update(str(c).strip().upper() for c, _l, _r in diff.type_mismatch)
    touched.update(str(c).strip().upper() for c, _l, _r in diff.comment_mismatch)
    return bool(touched) and touched <= cols


def verify_ddl_vs_jf(layer, jf_source, limit=3):
    """本地 `ddl/*.sql` 逐表对比甲方建表脚本。

    返回 `(已校验表数, 差异表数, 豁免表数)`；无法校验（甲方文件缺失/解析不出/本地为空）
    返回 `(0, -1, 0)`。
    ★ 2026-10-28：`verify-ddl --layers DWD` 原先只打印一句「暂委托…手工对比」就返回 0
      ⇒ DWD 的 DDL 校验**永远通过**（假绿，比没有校验更危险）。改为与 DWS 共用
      同一套 `parse_jf_ddl` + `ddl_verify.diff_ddl` 真比对。
    ★ 2026-11-19：差异全部落在 `tools/dwd_ddl_drift_allowlist.json` 登记列内时
      计入 `ignore`（打印一次、不阻断）；清单外的差异照常算 drift。
    """
    jf_source = Path(jf_source)
    if not jf_source.is_file():
        print(f"  ✗ {jf_source} 不存在（甲方交付目录不可达，可用 DW_DELIVERY 指定）")
        return 0, -1, 0
    stmts = parse_jf_ddl(jf_source)
    if not stmts:
        print(f"  ✗ {jf_source} 未解析出 CREATE TABLE")
        return 0, -1, 0
    local = local_ddl_paths(layer)
    if not local:
        print(f"  ✗ 本地无 {layer} ddl/*.sql")
        return 0, -1, 0
    allow = _load_drift_allowlist()
    checked, drift, extra, lint_hits, ignored = 0, 0, [], 0, []
    for table, p in sorted(local.items()):
        if table not in stmts:
            extra.append(table)
            continue
        checked += 1
        # p 来自 glob，必然存在 ⇒ diff 不会为 None
        diff, probs = compare_local_ddl(p, stmts[table])
        if probs:
            lint_hits += 1
            drift += 1
            print(f"  ✗ {table} DDL 文件检查: {probs[0]}")
        if not diff.empty():
            if not probs and _drift_is_registered(diff, allow.get(table)):
                ignored.append(table)
                print(f"  · {table} 差异已登记豁免: {diff.summary()}")
            else:
                drift += 1
                print(f"  ✗ {table} 差异: {diff.summary()}")
                _print_ddl_diff(diff, limit=limit)
    if extra:
        shown = ", ".join(extra[:6]) + (" …" if len(extra) > 6 else "")
        print(f"  ⚠ 本地独有 {len(extra)} 张（甲方建表脚本无此表，跳过比对）: {shown}")
    if not checked:
        print(f"  ✗ {layer} 本地与甲方没有可比对的表，校验未完成")
        return 0, -1, 0
    if lint_hits:
        print(f"  ✗ DDL 文件名或语句边界问题 {lint_hits} 张")
    if ignored:
        print(f"  ⚠ 已登记豁免 {len(ignored)} 张（清单 tools/dwd_ddl_drift_allowlist.json）: "
              f"{', '.join(ignored[:6])}{' …' if len(ignored) > 6 else ''}")
    return checked, drift, len(ignored)
