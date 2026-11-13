# -*- coding: utf-8 -*-
"""DDL 解析、清洗、落盘与比对（DWS 为主，DWD 侧只做存在性/委托）。"""
import json
import re
import shutil
import time
from pathlib import Path

from tools.core.loader import load as _load_file

from tools.dws import state as st
from tools.dws.args import _dwd_ddl_cmd, layers_of
from tools.dws.manifest import (StaleDwsManifest, _guard_dws_manifest,
                                _safe_group, fail_stale)
from tools.dws.process import run


def _load_ddl_verify():
    """`tools/core/ddl_verify.py`（DDL 结构对比）。"""
    return _load_file(st.DDL_VERIFY)


def _dwd_sanitize_mod():
    """`tools/core/ddl_sanitize.py` **模块对象**（需要 sanitize_ddl 之外的函数时用）。"""
    return _load_file(st.REPO / "tools/core/ddl_sanitize.py")


def _dwd_sanitize():
    """`tools/core/ddl_sanitize.py::sanitize_ddl`（单一来源，避免两处正则漂移）。

    ★ 2026-10-26：原先 exec 整个 `dwd-pipeline.py`（86KB，模块级 import openpyxl）只为拿
      这一个函数 ⇒ 缺 openpyxl 时 `ddl --layers DWS` 直接 ModuleNotFoundError。
      指向独立小模块（只依赖 re）。
    """
    return _dwd_sanitize_mod().sanitize_ddl


def dws_table_sys_map(allow_stale=False):
    """DWS 表 → 系统。`ddl/*.sql` 落位优先，`_DWS搬移清单.json` 的 group 补缺。

    ★ 两源取**并集**：清单可能含已不在 ddl/ 下的表，ddl/ 也可能有清单未登记的表。
      只取其一会让 cmd_verify_ddl 静默跳过缺失的表（校验变弱、不报错）。
    ★ 清单带 sha256/bytes 时必须与现盘一致，否则抛 StaleDwsManifest（不改清单）。
    """
    _guard_dws_manifest(allow_stale)
    m = {}
    for s in st.SYS:
        for p in (st.SCRIPTS / s / "dws/ddl").glob("*.sql"):
            m[p.stem.upper()] = s
    manifest = st.SCRIPTS / "_DWS搬移清单.json"
    if manifest.is_file():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            data = {}
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
    sanitize = _dwd_sanitize()
    raw = Path(path).read_text(encoding="utf-8", errors="replace")
    stmts = {}
    for chunk in re.split(r";\s*(?:\r?\n)", raw):
        m = re.search(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:[A-Za-z0-9_]+\.)?"
                      r"([A-Za-z0-9_]+)", chunk, re.I)
        if not m:
            continue
        # 只移除 DROP TABLE IF EXISTS（分号可有可无），中间留 CREATE TABLE
        body = _dwd_sanitize_mod().strip_drop_stmts(chunk)
        stmts.setdefault(m.group(1).upper(), sanitize(body))
    return stmts


def build_dws_ddl_from_jf(apply, strict=True, allow_stale=False):
    """甲方 `02-DWS建表脚本.sql` → `scripts/{系统}/dws/ddl/*.sql` + `01_ddl.sql`。

    为什么要清洗：甲方脚本是 Inceptor 方言，含 `DEFAULT NULL`（Hive 4.2 不支持）
    与 `VARCHAR2(n)`；清洗规则与 DWD 共用 `sanitize_ddl`。
    逐表文件只留 CREATE（DROP 由重建步骤自己拼 `DROP TABLE IF EXISTS`）。
    ★ 2026-10-28：原先签名没有 `strict`，但落盘后自检失败时打印「加 --no-strict 可忽略继续」
      —— 那个开关**根本没被接收**，照提示操作依旧 rc=1（提示与行为相反）。
      现在真正接收 strict：False 时只告警不阻断。
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
    owner = dws_table_sys_map(allow_stale=allow_stale)
    have = {t: owner[t] for t in stmts if t in owner}
    miss = sorted(t for t in stmts if t not in owner)
    by_sys = {}
    for t, s in have.items():
        by_sys[s] = by_sys.get(s, 0) + 1
    print(f"  甲方 DWS 建表 {len(stmts)} 张 | 可归属 {len(have)} {by_sys} | 未归属 {len(miss)}")
    if miss:
        print("    未归属（跳过）:", miss)
    if not apply:
        print("  (dry-run，未落盘)")
        return 0

    ts = time.strftime("%Y%m%d-%H%M%S")
    bak = st.REPO / "tools/.dx-tmp" / f"backup-dws-ddl-{ts}"
    for s in st.SYS:
        d = st.SCRIPTS / s / "dws"
        if (d / "ddl").is_dir():
            shutil.copytree(d / "ddl", bak / s / "ddl", dirs_exist_ok=True)
        if (d / "01_ddl.sql").is_file():
            (bak / s).mkdir(parents=True, exist_ok=True)
            shutil.copy2(d / "01_ddl.sql", bak / s / "01_ddl.sql")
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


def verify_ddl_after_write(layer: str, have: dict, stmts: dict, jf_source: Path):
    """落盘后把本地 DDL 与甲方原文逐表对比，打印差异并返回非零退出码（如有差异）。

    ★ 2026-11-09（评审 A1）：并列做**语句边界 lint**（`core/ddl_verify.lint_statements`）。
      `diff_ddl` 只比列/分区/注释，甲方「DROP 缺分号 + 紧跟 CREATE」这类写法会被
      它判成「一致」而假绿；beeline 按 `;` 切分执行时却必然 ParseException。
      语句边界是**执行层**属性，必须单独一道。
    """
    verify = _load_ddl_verify()
    all_ok = True
    drift_items = []
    lint_hits = []
    for table, sysname in have.items():
        local_path = st.SCRIPTS / sysname / f"{layer.lower()}/ddl/{table}.sql"
        if not local_path.is_file():
            print(f"  ⚠ {table}: 本地文件不存在 {local_path}")
            all_ok = False
            continue
        # 甲方原文：从 stmts 拿（已 sanitize）
        jf_text = stmts[table] + ";"
        local_text = local_path.read_text(encoding="utf-8", errors="replace")
        diff = verify.diff_ddl(jf_text, local_text, "甲方", "本地")
        probs = verify.lint_statements(local_text)
        if probs:
            all_ok = False
            lint_hits.append((table, sysname, probs))
            print(f"  ✗ {table} ({sysname}) 语句边界: {probs[0]}")
        if not diff.empty():
            all_ok = False
            drift_items.append((table, sysname, diff))
            print(f"  ✗ {table} ({sysname}) 差异: {diff.summary()}")
            _print_ddl_diff(diff)
        elif not probs:
            print(f"  ✓ {table} ({sysname}) 与甲方一致")

    if not all_ok:
        # 写入报告供后续排查
        ts = time.strftime("%Y%m%d-%H%M%S")
        report = st.REPO / "tools/.dx-tmp" / f"ddl-drift-{layer.lower()}-{ts}.md"
        report.parent.mkdir(parents=True, exist_ok=True)
        lines = [f"# {layer} DDL 与甲方差异报告 ({ts})", "", f"来源: {jf_source}", ""]
        for table, sysname, diff in drift_items:
            lines.append(f"## {table} ({sysname})")
            lines.append(f"- 摘要: {diff.summary()}")
            if diff.type_mismatch:
                lines.append("### 类型不一致")
                for col, lt, rt in diff.type_mismatch:
                    lines.append(f"- {col}: 甲方 `{lt}` / 本地 `{rt}`")
            if diff.comment_mismatch:
                lines.append("### 注释不一致")
                for col, lc, rc in diff.comment_mismatch:
                    lines.append(f"- {col}: 甲方 `{lc}` / 本地 `{rc}`")
            if diff.partition_mismatch:
                lines.append("### 分区不一致")
                lines.append(f"- 甲方: {[(c.name, c.type) for c in diff.left_partitions]}")
                lines.append(f"- 本地: {[(c.name, c.type) for c in diff.right_partitions]}")
            if diff.table_comment_mismatch:
                lines.append("### 表注释不一致")
                lines.append(f"- 甲方: `{diff.table_comment_mismatch[0]}`")
                lines.append(f"- 本地: `{diff.table_comment_mismatch[1]}`")
            if diff.only_in_left:
                lines.append(f"- 仅甲方有列: {', '.join(diff.only_in_left)}")
            if diff.only_in_right:
                lines.append(f"- 仅本地有列: {', '.join(diff.only_in_right)}")
            lines.append("")
        if lint_hits:
            lines.append("## 语句边界问题（beeline 按 `;` 切分会 ParseException）")
            lines.append("")
            for table, sysname, probs in lint_hits:
                for p in probs:
                    lines.append(f"- **{table}** ({sysname}): {p}")
            lines.append("")
        report.write_text("\n".join(lines), encoding="utf-8")
        print(f"  差异报告: {report}")
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
    strict = not getattr(args, "no_strict", False)
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
                    args.apply, strict,
                    allow_stale=getattr(args, "allow_stale_dws_manifest", False))
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


def verify_ddl_vs_jf(layer, jf_source, limit=3):
    """本地 `ddl/*.sql` 逐表对比甲方建表脚本。

    返回 `(已校验表数, 差异表数)`；无法校验（甲方文件缺失/解析不出/本地为空）返回 `(0, -1)`。
    ★ 2026-10-28：`verify-ddl --layers DWD` 原先只打印一句「暂委托…手工对比」就返回 0
      ⇒ DWD 的 DDL 校验**永远通过**（假绿，比没有校验更危险）。改为与 DWS 共用
      同一套 `parse_jf_ddl` + `ddl_verify.diff_ddl` 真比对。
    """
    jf_source = Path(jf_source)
    if not jf_source.is_file():
        print(f"  ✗ {jf_source} 不存在（甲方交付目录不可达，可用 DW_DELIVERY 指定）")
        return 0, -1
    stmts = parse_jf_ddl(jf_source)
    if not stmts:
        print(f"  ✗ {jf_source} 未解析出 CREATE TABLE")
        return 0, -1
    local = local_ddl_paths(layer)
    if not local:
        print(f"  ✗ 本地无 {layer} ddl/*.sql")
        return 0, -1
    verify = _load_ddl_verify()
    checked, drift, extra, lint_hits = 0, 0, [], 0
    for table, p in sorted(local.items()):
        if table not in stmts:
            extra.append(table)
            continue
        checked += 1
        local_text = p.read_text(encoding="utf-8", errors="replace")
        diff = verify.diff_ddl(stmts[table] + ";", local_text, "甲方", "本地")
        probs = verify.lint_statements(local_text)
        if probs:
            lint_hits += 1
            drift += 1
            print(f"  ✗ {table} 语句边界: {probs[0]}")
        if not diff.empty():
            drift += 1
            print(f"  ✗ {table} 差异: {diff.summary()}")
            _print_ddl_diff(diff, limit=limit)
    if extra:
        shown = ", ".join(extra[:6]) + (" …" if len(extra) > 6 else "")
        print(f"  ⚠ 本地独有 {len(extra)} 张（甲方建表脚本无此表，跳过比对）: {shown}")
    if lint_hits:
        print(f"  ✗ 语句边界问题 {lint_hits} 张（beeline 按 `;` 切分会 ParseException）")
    return checked, drift
