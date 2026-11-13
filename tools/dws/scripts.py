# -*- coding: utf-8 -*-
"""DWS 脚本搬移、同步与拼接副本修复。"""
import shutil
import time

from tools.core.loader import load as _load_file

from tools.dws import state as st
from tools.dws.args import _ap, layers_of, stale_allowed
from tools.dws.manifest import (StaleDwsManifest, dws_source_map,
                                fail_stale)
from tools.dws.process import gen_temp, run, sync_files


def _sh_repair():
    """`tools/core/sh_repair.py`（拼接副本修复）。"""
    return _load_file(st.SH_REPAIR)


def stage_dws_from_jf(args=None):
    """把甲方 02-DWS执行脚本/*.txt 对账到 scripts/{系统}/dws/02_etl。

    只比对、不覆盖。仓库版含 Hive 4.2 方言修复，甲方原文跑不了。
    带 ``DW-DEVIATION`` 的脚本单独列出。
    ★ 2026-11-10（评审 L1）：去掉 `apply` 形参 —— 本函数从不落盘，
      留着它会让调用方误以为 `--apply` 控制这一步。
    """
    src_exec = st.SRC_DWS_EXEC
    if not src_exec.is_dir():
        print(f"  {src_exec} 不存在，跳过")
        return
    srcs = sorted(src_exec.glob("*.txt"))
    if not srcs:
        print(f"  {src_exec} 无 *.txt，跳过")
        return

    allow = stale_allowed(args)
    mapping = dws_source_map(allow_stale=allow)
    mod = _sh_repair()          # 循环外取一次：`_load_file` 每次都要算 realpath
    planned, same, deviated = [], [], []
    for p in srcs:
        sysname = mapping.get(p.stem)
        if not sysname:
            continue
        dst = st.dws_etl_dir(sysname) / f"{p.stem}.sh"
        if dst.is_file():
            blob = dst.read_bytes()      # 只读一次：比较与 DEVIATION_MARK 共用
            if p.read_bytes() == blob:
                same.append(p.stem)
                continue
            if mod.DEVIATION_MARK in blob.decode("utf-8", "replace"):
                deviated.append(p.stem)
                continue
        planned.append((sysname, p, dst))

    total = len(planned) + len(same) + len(deviated)
    if deviated:
        print(f"  已知偏离（有意不改回甲方原文）"
              f"{len(deviated)} 个: {', '.join(deviated)}")
    if planned:
        print(f"  甲方 DWS {src_exec} -> {st.SCRIPTS}/{{系统}}/dws/02_etl: "
              f"共 {total} 个，其中与仓库不同 {len(planned)} 个")
        for sysname, p, _d in planned[:8]:
            print(f"    差异: {sysname}/{p.name}")
        if len(planned) > 8:
            print(f"    … 其余 {len(planned) - 8} 个")
        print("  ⚠ 与仓库存在差异，只比对不覆盖（仓库版才是可执行基线）")
    elif not deviated:
        print(f"  甲方 DWS {total} 个与仓库完全一致")


def _sync_dws_jf(args):
    """DWS jf 模式：只比对甲方原文（不覆盖），并核对仓库脚本数。"""
    try:
        stage_dws_from_jf(args)
    except StaleDwsManifest as exc:
        return fail_stale(exc)
    n_repo = sum(len(list(st.dws_etl_dir(s).glob("*.sh")))
                 for s in st.SYS)
    print(f"  DWS 脚本合计（仓库） {n_repo}")
    if n_repo != st.DWS_EXPECT_SCRIPTS:
        print(f"  ⚠ 预期 {st.DWS_EXPECT_SCRIPTS} 个 DWS 脚本")
        return 1
    return 0


def _sync_generated(args, layer, require_output):
    """gen 模式：跑生成器，把产物同步进 `scripts/{系统}/{layer}/`。

    ``require_output``：生成器没产出该系统目录时是否算失败（DWD 算，DWS 只跳过）。
    ★ 2026-11-13：原 `_sync_dwd_scripts` / `_sync_dws_scripts` 的 gen 分支逐字相同，
      只是层名与「缺目录」策略不同 —— 合并成一个。
    """
    rc = 0
    tmp = gen_temp(f"dw-gen-{layer.lower()}")
    # ★ 2026-10-26：原先 `return 1`（生成器 ERROR）落在 rmtree 之前，
    #   且 dry-run 也真写盘 ⇒ `scripts/.dw-gen-*` 越积越多；
    #   而残留 .sh 会被血缘→depcfg→deploy 自动识别成作业（AGENTS.md 已警告）。
    #   改用 try/finally：无论成功/失败/dry-run 都清干净。
    try:
        code, out = run([st.PY, st.GEN_MAIN, "--layer", layer, "--output", tmp],
                        capture=True)
        rc |= code
        if "[ERROR" in out and not getattr(args, "allow_gen_errors", False):
            print(f"  ✗ {layer} 生成器有 ERROR 日志；修 MAPPING 后重跑，或加 --allow-gen-errors")
            return 1
        for s in st.SYS:
            src = tmp / s / layer.lower()
            if not src.is_dir():
                if require_output:
                    print(f"  ⚠ 生成器未产出 {s}/{layer.lower()}")
                    rc = 1
                continue
            dst = st.SCRIPTS / s / layer.lower()
            sync_files(src / "02_etl", dst / "02_etl", args.apply,
                       backup=True, label=f"{s} {layer} ETL")
            for sub in ("ddl", "lineage", "data_dict"):
                sync_files(src / sub, dst / sub, args.apply,
                           pattern="*", label=f"{s} {layer} {sub}")
            sync_files(src, dst, args.apply, pattern="01_ddl.sql",
                       label=f"{s} {layer} 01_ddl.sql")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return rc


def cmd_scripts(args):
    layers = layers_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD scripts ==")
        if args.source == "jf":
            rc |= run([st.PY, st.DWD_PIPE, "convert"] + _ap(args))[0]
            rc |= run([st.PY, st.DWD_PIPE, "distribute"] + _ap(args))[0]
        else:
            rc |= _sync_generated(args, "DWD", require_output=True)
    if "DWS" in layers:
        print("== DWS scripts ==")
        if args.source == "jf":
            rc |= _sync_dws_jf(args)
        else:
            rc |= _sync_generated(args, "DWS", require_output=False)
    return rc


def _repair_one(mod, sysname, p, args):
    """处理单个脚本。返回 ``(是否命中拼接副本, rc 增量)``。"""
    text = p.read_bytes().decode("utf-8", "replace")
    n = mod.count_sql_calls(text)
    if n <= 1:
        return False, 0
    new, notes = mod.trim_to_first_copy(text)
    print(f"  {sysname}/{p.name}: SQL 调用 ×{n}")
    for x in notes:
        print(f"    {x}")
    if mod.DEVIATION_MARK in text:
        print(f"    已带 {mod.DEVIATION_MARK} 标记，跳过")
        return True, 0
    if any("不一致" in x for x in notes):
        print("    ✗ 副本 SQL 不一致，未落盘；人工确认后再手工处置")
        return True, 1
    if new == text:
        print("    无可落盘改动")
        return True, 0
    if not args.apply:
        print("    (dry-run，未落盘)")
        return True, 0
    bak = (st.REPO / "tools/.dx-tmp" /
           f"backup-repair-{time.strftime('%Y%m%d-%H%M%S')}" / sysname)
    bak.mkdir(parents=True, exist_ok=True)
    shutil.copy2(p, bak / p.name)
    nl = "\r\n" if "\r\n" in new else "\n"
    mark = (f"# {mod.DEVIATION_MARK}: 甲方原文为两份脚本拼接（done 与 shebang 粘连，"
            f"while 不闭合），按口径只保留第 1 个 beeline 的完整 SQL；"
            f"不要用甲方原文覆盖")
    if new.startswith("#!") and nl in new:
        i = new.index(nl) + len(nl)
        new = new[:i] + mark + nl + new[i:]
    else:
        new = mark + nl + new
    p.write_bytes(new.encode("utf-8"))
    print(f"    已修复 → 备份 {bak / p.name}")
    return True, 0


def cmd_repair(args):
    """拼接副本修复：只保留第一个 beeline 对应的完整 SQL（默认 dry-run）。

    ★ 口径（用户 2026-10-26 定）：类似 `DWS_PROD_SALE_DATA_PTD.sh` 这种「两份脚本被拼接」
      的甲方交付，一律只保留第一份（第一个 beeline 的完整 SQL），其后粘连的副本整段丢弃。
      判定与裁剪逻辑在 `tools/core/sh_repair.py`，这里只负责扫描/备份/落盘/标注。
    ★ 两份 SQL 不一致时**不落盘**（rc=1）：口径优先但不能默默丢内容，需人工确认。
    ★ 落盘后文件带 `DW-DEVIATION` 标记 ⇒ `stage_dws_from_jf` 不会用甲方原文把它覆盖回去。
    ★ 2026-11-13：单脚本处理拆到 `_repair_one`（原函数 67 行）。
    """
    layers = layers_of(args)
    mod = _sh_repair()
    rc = 0
    hits = 0
    for layer in ("DWD", "DWS"):
        if layer not in layers:
            continue
        print(f"== 修复 {layer} 脚本（拼接副本） ==")
        # ★ 2026-11-09（评审 C3）：DWD 主数据脚本也在 scripts/MASTER/dwd/02_etl，
        #   只扫 SYS 会漏掉它们（DWS 只有三系统，保持 SYS）。
        #   ★ 路径必须走 dwd-pipeline 的 etl_dir()：主数据目录是 scripts/MASTER，
        #     不是 scripts/主数据。
        for s in (st.GROUPS if layer == "DWD" else st.SYS):
            d = (st.dwd_etl_dir(s) if layer == "DWD"
                 else st.SCRIPTS / s / "dws" / "02_etl")
            if not d.is_dir():
                continue
            for p in sorted(d.glob("*.sh")):
                hit, delta = _repair_one(mod, s, p, args)
                if hit:
                    hits += 1
                    rc |= delta
    if not hits:
        print("  未发现拼接副本（SQL 调用均 ≤1）")
    return rc
