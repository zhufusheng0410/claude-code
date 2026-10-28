#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DWD + DWS 一体化管线：脚本来源、DDL/血缘、DS 依赖配置、工作流删除/创建/排版/校验。

用法：
    python3 tools/dw-pipeline.py all --source jf --layers DWD,DWS --apply
    python3 tools/dw-pipeline.py all --source gen --layers DWD,DWS --apply
    python3 tools/dw-pipeline.py deploy --layers DWD,DWS --apply
    python3 tools/dw-pipeline.py verify --layers DWD,DWS --ds

约定：
- 所有写操作默认 dry-run，加 `--apply` 才落盘/动 DS。
- `--source jf`：DWD 读甲方 txt；DWS 从甲方 `02-DWS执行脚本` 搬移（统一落到 `scripts/{系统}/dws/02_etl`）。
- `--source gen`：调用 `tools/main.py` 生成（DWD 不碰 scripts/MASTER）。
- `deploy` 会先删 DWS 再删/建 DWD，最后建 DWS；跨层引用不会挡删。
- 参数按子命令裁剪（见 `SUBCOMMANDS`）：`verify` 只有 `--layers/--ds`，
  `deploy/delete/layout` 只有 `--layers/--apply`，逃生舱（`--allow-gen-errors`、
  `--force-dws-raw`）挂在 `scripts` 与 `all` 上 —— `all` 内部就调 `scripts`，
  不给它这两个开关就无法在一条命令内绕过生成器 ERROR。
- 任一子步骤失败即中止（`deploy` 不再「带着失败继续往下建」），避免 DS 留半成品。
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

# tools/core 下的小模块按路径加载（只依赖 re，不走包导入），每个文件只执行一次。
_CORE_MODS = {}


def _core_module(path):
    if path not in _CORE_MODS:
        import importlib.util as _ilu
        spec = _ilu.spec_from_file_location(path.stem, path)
        mod = _ilu.module_from_spec(spec)
        spec.loader.exec_module(mod)
        _CORE_MODS[path] = mod
    return _CORE_MODS[path]


def _load_ddl_verify():
    """`tools/core/ddl_verify.py`（DDL 结构对比）。"""
    return _core_module(DDL_VERIFY)


REPO = Path(__file__).resolve().parents[1]
SCRIPTS = REPO / "scripts"
SYS = ("HSFA", "HSZTA", "O32")
DWD_PIPE = REPO / "tools/dwd-pipeline.py"
GEN_MAIN = REPO / "tools/main.py"
DEPLOY_ALL = REPO / "tools/ds-deploy/ds-deploy-all-dwd.py"
DWS_DEPS = REPO / "tools/ds-deploy/ds-build-dws-dependent-from-lineage.py"
DWS_DEP_REPORT = REPO / "tools/dws-dep-report.py"
RELAYOUT = REPO / "tools/ds-deploy/ds-relayout.py"
DEPCFG_DWD = REPO / "tools/ds-deploy/dep-config-proscript"
DEPCFG_DWS = REPO / "tools/ds-deploy/dep-config-dws"
SH_REPAIR = REPO / "tools/core/sh_repair.py"
DDL_VERIFY = REPO / "tools/core/ddl_verify.py"
PY = sys.executable


def _ds_deploy():
    """惰性导入 ds-deploy 里的共用模块（该目录不在包路径上）。

    ★ 2026-10-26：原先在**模块顶层** `from ds_config import ...` —— 那会把
      `tools/ds-deploy` 目录当成包路径用，而它并没有加入 sys.path，
      于是任何 `python3 tools/dw-pipeline.py …` 启动都直接 ModuleNotFoundError。
      ⇒ 改为函数内导入，并顺便注入 sys.path（只做一次）。
    """
    d = str(REPO / "tools/ds-deploy")
    if d not in sys.path:
        sys.path.insert(0, d)
    import ds_client
    import ds_text
    return ds_client, ds_text

# ★ 2026-10-26：原来写死 WSL 路径 /mnt/d，Windows 原生跑（本项目现役环境）会判「不存在→跳过」。
#   注意不能只用 exists() 回退：Windows 会把 /mnt/d 解析成 `\mnt\d`（当前盘符下），
#   历史运行留下的镜像目录会让 exists() 假真 ⇒ 按哨兵子目录 `05-脚本` 判定。
_CAND_DELIVERY = [
    Path(os.environ["DW_DELIVERY"]) if os.environ.get("DW_DELIVERY") else None,
    Path("/mnt/d/项目/信达澳亚数仓/信达澳亚投研数据集市交付文档"),
    Path(r"D:\项目\信达澳亚数仓\信达澳亚投研数据集市交付文档"),
]
DELIVERY = next((p for p in _CAND_DELIVERY if p and (p / "05-脚本").is_dir()),
                _CAND_DELIVERY[-1])
SRC_DWS_EXEC = DELIVERY / "05-脚本/02-脚本/02-DWS执行脚本"
SRC_DWS_DDL = DELIVERY / "05-脚本/01-建表语句/02-DWS建表脚本.sql"
SRC_DWD_DDL = DELIVERY / "05-脚本/01-建表语句/01-DWD建表脚本.sql"
# ★ 2026-10-22（评审 HIGH-11）：原先是**模块级可变态全局**（`global FORCE_DWS_RAW`），
#   多次调用 / 测试之间会互相污染 ⇒ 可能把「本应不覆盖」的已修复版 DWS 脚本
#   用甲方原文误覆盖，直接违反 CLAUDE.md 的 DWS 基线口径。
#   ⇒ 取消全局，改为直接读 args 上的开关（argparse 已有该参数）。


VALID_LAYERS = {"DWD", "DWS"}

# ---- DWS 口径常量（口径变只改这里，别再散落魔数） ----
# ★ 原来 24 / 24 / 3 硬编码在 4 个地方，新增一张表就误报失败；
#   HSZTA→DWS_ZTA 是不规则映射，无法由 SYS 推导，故单独一张表统一维护。
DWS_EXPECT_SCRIPTS = 24      # scripts/{系统}/dws/02_etl/*.sh 合计
DWS_EXPECT_DEPS = 24         # tools/ds-deploy/dep-config-dws/*.dep.json
DWS_EXPECT_WORKFLOWS = 3     # DS 上 DWS_* 工作流个数
DWS_WF2SYS = {"DWS_HSFA": "HSFA", "DWS_ZTA": "HSZTA", "DWS_O32": "O32"}

# 子进程默认上限：DS API 挂住时不让整条管线无限等；需要更长可设 DW_RUN_TIMEOUT。
RUN_TIMEOUT = int(os.environ.get("DW_RUN_TIMEOUT", "1800"))


def layers_of(args):
    raw = {x.strip().upper() for x in args.layers.split(",") if x.strip()}
    bad = raw - VALID_LAYERS
    if bad:
        raise SystemExit(f"--layers 只接受 DWD / DWS，收到: {','.join(sorted(bad))}")
    return raw or set(VALID_LAYERS)


def _ap(args):
    """`--apply` 透传：子脚本自身也是 dry-run 语义，必须显式转达。"""
    return ["--apply"] if getattr(args, "apply", False) else []


def _dry(args):
    """`--dry-run` 透传：目标脚本默认会真跑，只有本层未加 --apply 时才拦。"""
    return [] if getattr(args, "apply", False) else ["--dry-run"]


def run(cmd, capture=False, timeout=None):
    """跑子进程；返回 (returncode, 输出)。

    ★ 捕获输出时固定 UTF-8 + errors=replace：Windows 下子进程的中文日志按
      locale（cp936）解码会抛 UnicodeDecodeError —— 与 `_shell_syntax` 里
      已经修过的是同一类坑，只是主执行路径原先没跟上（本机 UTF-8 侥幸不炸）。
    ★ 显式 timeout（默认 RUN_TIMEOUT）：DS API 挂住时不留无限等待；
      超时按失败返回 124，不抛异常，调用方统一走 rc 判定。
    """
    cmd = [str(x) for x in cmd]
    print("$", " ".join(cmd), flush=True)
    timeout = RUN_TIMEOUT if timeout is None else timeout
    try:
        if capture:
            p = subprocess.run(cmd, cwd=str(REPO), text=True, capture_output=True,
                               encoding="utf-8", errors="replace", timeout=timeout)
            out = (p.stdout or "") + (p.stderr or "")
            print(out, flush=True)
            return p.returncode, out
        p = subprocess.run(cmd, cwd=str(REPO), timeout=timeout)
        return p.returncode, ""
    except subprocess.TimeoutExpired:
        print(f"  ✗ 超时（{timeout}s）已中止：{' '.join(cmd[:3])} …", flush=True)
        return 124, ""


def backup_dir(src: Path):
    if not src.is_dir() or not any(src.glob("*.sh")):
        return None
    ts = time.strftime("%Y%m%d-%H%M%S")
    dst = REPO / "tools/.dx-tmp" / f"backup-{src.parent.parent.name}-{src.name}-{ts}"
    n = 0
    while dst.exists():
        n += 1
        dst = REPO / "tools/.dx-tmp" / f"backup-{src.parent.parent.name}-{src.name}-{ts}-{n}"
    shutil.copytree(src, dst)
    print(f"  备份 {src} -> {dst}")
    return dst


def sync_files(src: Path, dst: Path, apply: bool, pattern="*.sh", prune=False,
               backup=False, label=""):
    if not src.is_dir():
        print(f"  {src} 不存在，跳过")
        return 0
    srcs = {p.name: p for p in sorted(src.glob(pattern)) if p.is_file()}
    if not srcs:
        print(f"  {src} 无 {pattern}，跳过")
        return 0
    dsts = {p.name: p for p in dst.glob(pattern)} if dst.is_dir() else {}
    add = sorted(set(srcs) - set(dsts))
    upd = sorted(n for n in set(srcs) & set(dsts)
                 if srcs[n].read_bytes() != dsts[n].read_bytes())
    stale = sorted(set(dsts) - set(srcs)) if prune else []
    print(f"  {label or src}: 新增 {len(add)} / 更新 {len(upd)} / 删除 {len(stale)}")
    if apply:
        if backup and (add or upd or stale):
            backup_dir(dst)
        dst.mkdir(parents=True, exist_ok=True)
        for n in add + upd:
            shutil.copy2(srcs[n], dst / n)
        for n in stale:
            (dst / n).unlink()
    return len(srcs)


def gen_temp(prefix):
    ts = time.strftime("%Y%m%d-%H%M%S")
    p = SCRIPTS / f".{prefix}-{ts}"
    print(f"生成临时目录: {p}")
    return p


def dws_source_map():
    manifest = SCRIPTS / "_DWS搬移清单.json"
    if manifest.is_file():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        mapping = {}
        for f in data.get("files", []):
            name = f.get("name", "")
            if name.endswith(".sh"):
                mapping[name[:-3]] = f.get("group")
        if mapping:
            return mapping
    return {p.stem: s for s in SYS for p in (SCRIPTS / s / "dws/02_etl").glob("*.sh")}


def stage_dws_from_jf(apply: bool, args=None):
    """把甲方 02-DWS执行脚本/*.txt 对账到 scripts/{系统}/dws/02_etl。

    口径（2026-10-26 复核）：仓库 24 个脚本与甲方 txt **逐字节一致**，
    本步骤默认只做**差异比对防漂移**，不落盘；一旦出现差异，默认保留
    仓库版本，只有显式 --force-dws-raw 才用甲方原文覆盖。
    ★ 例外：仓库脚本带 `DW-DEVIATION` 标记的（拼接副本已按口径修复），
      `--force-dws-raw` 也**不覆盖** —— 覆盖会把修复连同甲方的缺陷一起还原。
    """
    if not SRC_DWS_EXEC.is_dir():
        print(f"  {SRC_DWS_EXEC} 不存在，跳过")
        return 0, 0
    srcs = sorted(SRC_DWS_EXEC.glob("*.txt"))
    if not srcs:
        print(f"  {SRC_DWS_EXEC} 无 *.txt，跳过")
        return 0, 0

    mapping = dws_source_map()
    planned, same, deviated = [], [], []
    for p in srcs:
        sysname = mapping.get(p.stem)
        if not sysname:
            continue
        dst = SCRIPTS / sysname / "dws/02_etl" / f"{p.stem}.sh"
        if dst.is_file() and p.read_bytes() == dst.read_bytes():
            same.append(p.stem)
            continue
        # ★ 带 DW-DEVIATION 标记 = 有意偏离甲方原文（如修复拼接副本），
        #   即使 --force-dws-raw 也不能覆盖回去，否则会把修复连同缺陷一起还原。
        if dst.is_file() and _sh_repair().DEVIATION_MARK in \
                dst.read_bytes().decode("utf-8", "replace"):
            deviated.append(p.stem)
            continue
        planned.append((sysname, p, dst))

    total = len(planned) + len(same) + len(deviated)
    if deviated:
        print(f"  已知偏离（有意不改回甲方原文，--force-dws-raw 也不覆盖）"
              f"{len(deviated)} 个: {', '.join(deviated)}")
    if planned:
        print(f"  甲方 DWS {SRC_DWS_EXEC} -> {SCRIPTS}/{{系统}}/dws/02_etl: "
              f"共 {total} 个，其中与仓库不同 {len(planned)} 个")
        for sysname, p, _d in planned[:8]:
            print(f"    差异: {sysname}/{p.name}")
        if len(planned) > 8:
            print(f"    … 其余 {len(planned) - 8} 个")
        if not getattr(args, "force_dws_raw", False):
            print("  ⚠ 与仓库存在差异，默认只比对不覆盖（防漂移）；"
                  "如确需用甲方原文覆盖请加 --force-dws-raw")
    elif not deviated:
        print(f"  甲方 DWS {total} 个与仓库完全一致")
    if not apply or not planned:
        return total, len(planned)
    # ★ 2026-10-28：原先落盘只看 apply、与上面「默认不覆盖」的提示矛盾 ——
    #   不带 --force-dws-raw 的 --apply 也会静默覆盖差异文件。当前 24/24
    #   逐字节一致 ⇒ planned 恒空、此分支空跑；仅在未来出现差异时生效。
    if not getattr(args, "force_dws_raw", False):
        return total, len(planned)
    for sysname, p, dst in planned:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dst)
        print(f"  甲方 DWS(原文) {p.name} -> {dst}")
    return total, len(planned)


def cmd_scripts(args):
    layers = layers_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD scripts ==")
        if args.source == "jf":
            rc |= run([PY, DWD_PIPE, "convert"] + _ap(args))[0]
            rc |= run([PY, DWD_PIPE, "distribute"] + _ap(args))[0]
        else:
            tmp = gen_temp("dw-gen-dwd")
            # ★ 2026-10-26：原先 `return 1`（生成器 ERROR）落在 rmtree 之前，
            #   且 dry-run 也真写盘 ⇒ `scripts/.dw-gen-*` 越积越多；
            #   而残留 .sh 会被血缘→depcfg→deploy 自动识别成作业（AGENTS.md 已警告）。
            #   改用 try/finally：无论成功/失败/dry-run 都清干净。
            try:
                code, out = run([PY, GEN_MAIN, "--layer", "DWD", "--output", tmp],
                                capture=True)
                rc |= code
                if "[ERROR" in out and not getattr(args, "allow_gen_errors", False):
                    print("  ✗ DWD 生成器有 ERROR 日志；修 MAPPING 后重跑，或加 --allow-gen-errors")
                    return 1
                for s in SYS:
                    src = tmp / s / "dwd"
                    if not src.is_dir():
                        print(f"  ⚠ 生成器未产出 {s}/dwd")
                        rc = 1
                        continue
                    sync_files(src / "02_etl", SCRIPTS / s / "dwd/02_etl", args.apply,
                               backup=True, label=f"{s} DWD ETL")
                    for sub in ("ddl", "lineage", "data_dict"):
                        sync_files(src / sub, SCRIPTS / s / "dwd" / sub, args.apply,
                                   pattern="*", label=f"{s} DWD {sub}")
                    sync_files(src, SCRIPTS / s / "dwd", args.apply, pattern="01_ddl.sql",
                               label=f"{s} DWD 01_ddl.sql")
            finally:
                shutil.rmtree(tmp, ignore_errors=True)

    if "DWS" in layers:
        print("== DWS scripts ==")
        if args.source == "jf":
            total, _diff = stage_dws_from_jf(args.apply, args)
            n_repo = sum(len(list((SCRIPTS / s / "dws/02_etl").glob("*.sh"))) for s in SYS)
            print(f"  DWS 脚本合计（仓库） {n_repo}")
            if n_repo != DWS_EXPECT_SCRIPTS:
                print(f"  ⚠ 预期 {DWS_EXPECT_SCRIPTS} 个 DWS 脚本")
                rc = 1
        else:
            tmp = gen_temp("dw-gen-dws")
            try:
                code, out = run([PY, GEN_MAIN, "--layer", "DWS", "--output", tmp],
                                capture=True)
                rc |= code
                if "[ERROR" in out and not getattr(args, "allow_gen_errors", False):
                    print("  ✗ DWS 生成器有 ERROR 日志；修 MAPPING 后重跑，或加 --allow-gen-errors")
                    return 1
                for s in SYS:
                    src = tmp / s / "dws"
                    if not src.is_dir():
                        continue
                    sync_files(src / "02_etl", SCRIPTS / s / "dws/02_etl", args.apply,
                               backup=True, label=f"{s} DWS ETL")
                    for sub in ("ddl", "lineage", "data_dict"):
                        sync_files(src / sub, SCRIPTS / s / "dws" / sub, args.apply,
                                   pattern="*", label=f"{s} DWS {sub}")
                    sync_files(src, SCRIPTS / s / "dws", args.apply, pattern="01_ddl.sql",
                               label=f"{s} DWS 01_ddl.sql")
            finally:
                shutil.rmtree(tmp, ignore_errors=True)
    return rc


def _sh_repair():
    """`tools/core/sh_repair.py`（拼接副本修复）。"""
    return _core_module(SH_REPAIR)


def _dwd_sanitize():
    """`tools/core/ddl_sanitize.py::sanitize_ddl`（单一来源，避免两处正则漂移）。

    ★ 2026-10-26：原先 exec 整个 `dwd-pipeline.py`（86KB，模块级 import openpyxl）只为拿
      这一个函数 ⇒ 缺 openpyxl 时 `ddl --layers DWS` 直接 ModuleNotFoundError。
      指向独立小模块（只依赖 re）。
    """
    return _core_module(REPO / "tools/core/ddl_sanitize.py").sanitize_ddl


def dws_table_sys_map():
    """DWS 表 → 系统。`ddl/*.sql` 落位优先，`_DWS搬移清单.json` 的 group 补缺。

    ★ 两源取**并集**：清单可能含已不在 ddl/ 下的表，ddl/ 也可能有清单未登记的表。
      只取其一会让 cmd_verify_ddl 静默跳过缺失的表（校验变弱、不报错）。
    """
    m = {}
    for s in SYS:
        for p in (SCRIPTS / s / "dws/ddl").glob("*.sql"):
            m[p.stem.upper()] = s
    manifest = SCRIPTS / "_DWS搬移清单.json"
    if manifest.is_file():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        for f in data.get("files", []):
            name = f.get("name", "")
            if name.endswith(".sh") and f.get("group"):
                m.setdefault(name[:-3].upper(), f["group"])
    return m


def parse_jf_ddl(path):
    """解析甲方建表 sql → {表名大写: 已清洗的 CREATE 语句}（含 DROP 已剥离）。

    ★ 2026-10-27：原先 `build_dws_ddl_from_jf` 与 `cmd_verify_ddl` **各写了一遍**
      同样的「按 `;` 切分 → 抓 CREATE TABLE 表名 → 去单行 DROP → sanitize」。
      两份副本必然漂移（改一处忘另一处 ⇒ 落盘与校验用不同规则，校验就此失去意义）。
      抽成单一实现，两边共用。
    """
    sanitize = _dwd_sanitize()
    raw = path.read_text(encoding="utf-8", errors="replace")
    stmts = {}
    for chunk in re.split(r";\s*(?:\r?\n)", raw):
        m = re.search(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:[A-Za-z0-9_]+\.)?"
                      r"([A-Za-z0-9_]+)", chunk, re.I)
        if not m:
            continue
        # 只移除单行的 DROP TABLE IF EXISTS ...;（不跨行吃掉 CREATE TABLE）
        body = re.sub(r"(?im)^\s*DROP\s+TABLE\s+IF\s+EXISTS\s+[^;\n]+;\s*$", "", chunk).strip()
        stmts.setdefault(m.group(1).upper(), sanitize(body))
    return stmts


def build_dws_ddl_from_jf(apply, strict=True):
    """甲方 `02-DWS建表脚本.sql` → `scripts/{系统}/dws/ddl/*.sql` + `01_ddl.sql`。

    为什么要清洗：甲方脚本是 Inceptor 方言，含 `DEFAULT NULL`（Hive 4.2 不支持）
    与 `VARCHAR2(n)`；清洗规则与 DWD 共用 `sanitize_ddl`。
    逐表文件只留 CREATE（DROP 由重建步骤自己拼 `DROP TABLE IF EXISTS`）。
    ★ 2026-10-28：原先签名没有 `strict`，但落盘后自检失败时打印「加 --no-strict 可忽略继续」
      —— 那个开关**根本没被接收**，照提示操作依旧 rc=1（提示与行为相反）。
      现在真正接收 strict：False 时只告警不阻断。
    """
    if not SRC_DWS_DDL.is_file():
        # ★ 2026-10-26：原先是 `return 0`（静默跳过）⇒ all 会带着旧 01_ddl.sql 一路走下去，
        #   而 verify 只查「文件在不在」，不看「内容是否过期」⇒ 假绿。
        #   甲方交付路径不可达属于环境问题，必须按失败上报（可用 DW_DELIVERY 指定）。
        print(f"  ✗ {SRC_DWS_DDL} 不存在：甲方交付目录不可达（可用 DW_DELIVERY 指定），"
              f"拒绝静默跳过")
        return 1
    stmts = parse_jf_ddl(SRC_DWS_DDL)
    if not stmts:
        print(f"  {SRC_DWS_DDL} 未解析出 CREATE TABLE")
        return 1
    owner = dws_table_sys_map()
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
    bak = REPO / "tools/.dx-tmp" / f"backup-dws-ddl-{ts}"
    for s in SYS:
        d = SCRIPTS / s / "dws"
        if (d / "ddl").is_dir():
            shutil.copytree(d / "ddl", bak / s / "ddl", dirs_exist_ok=True)
        if (d / "01_ddl.sql").is_file():
            (bak / s).mkdir(parents=True, exist_ok=True)
            shutil.copy2(d / "01_ddl.sql", bak / s / "01_ddl.sql")
    for t, sysname in have.items():
        body = ("-- 来源: 甲方 02-DWS建表脚本.sql（dw-pipeline ddl）\n"
                + stmts[t] + ";\n")
        d = SCRIPTS / sysname / "dws/ddl"
        d.mkdir(parents=True, exist_ok=True)
        (d / f"{t}.sql").write_text(body, encoding="utf-8", newline="\n")
    for s in SYS:
        d = SCRIPTS / s / "dws/ddl"
        parts, seen = [], set()
        for f in sorted(d.glob("*.sql")):
            if f.stem.upper() in seen:
                continue
            seen.add(f.stem.upper())
            parts.append(f.read_text(encoding="utf-8", errors="replace").rstrip())
        (SCRIPTS / s / "dws/01_ddl.sql").write_text(
            "\n\n".join(parts) + "\n", encoding="utf-8", newline="\n")
        print(f"  {s}: 01_ddl.sql <- {len(parts)} 张表")
    print(f"  备份: {bak}")
    # 落盘后自检（本函数在非 apply 时已提前 return，此处必然 apply）
    rc = verify_ddl_after_write("DWS", have, stmts, SRC_DWS_DDL)
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
    """落盘后把本地 DDL 与甲方原文逐表对比，打印差异并返回非零退出码（如有差异）。"""
    verify = _load_ddl_verify()
    all_ok = True
    drift_items = []
    for table, sysname in have.items():
        local_path = SCRIPTS / sysname / f"{layer.lower()}/ddl/{table}.sql"
        if not local_path.is_file():
            print(f"  ⚠ {table}: 本地文件不存在 {local_path}")
            all_ok = False
            continue
        # 甲方原文：从 stmts 拿（已 sanitize）
        jf_text = stmts[table] + ";"
        local_text = local_path.read_text(encoding="utf-8", errors="replace")
        diff = verify.diff_ddl(jf_text, local_text, "甲方", "本地")
        if not diff.empty():
            all_ok = False
            drift_items.append((table, sysname, diff))
            print(f"  ✗ {table} ({sysname}) 差异: {diff.summary()}")
            _print_ddl_diff(diff)
        else:
            print(f"  ✓ {table} ({sysname}) 与甲方一致")

    if not all_ok:
        # 写入报告供后续排查
        ts = time.strftime("%Y%m%d-%H%M%S")
        report = REPO / "tools/.dx-tmp" / f"ddl-drift-{layer.lower()}-{ts}.md"
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
            # 传递 --no-strict 给子命令
            cmd = [PY, DWD_PIPE, "ddl"] + _ap(args)
            if not strict:
                cmd += ["--no-strict"]
            rc |= run(cmd)[0]
        else:
            for s in SYS:
                p = SCRIPTS / s / "dwd/01_ddl.sql"
                print(f"  {s}: {'OK' if p.is_file() else '缺失'} {p}")
                rc |= 0 if p.is_file() else 1
    if "DWS" in layers:
        print("== DWS DDL ==")
        if args.source == "jf":
            rc |= build_dws_ddl_from_jf(args.apply, strict)
            if strict:
                for s in SYS:
                    _stale_warn(SRC_DWS_DDL, SCRIPTS / s / "dws/01_ddl.sql", f"{s} DWS 01_ddl.sql")
        else:
            for s in SYS:
                p = SCRIPTS / s / "dws/01_ddl.sql"
                d = SCRIPTS / s / "dws/ddl"
                n = len(list(d.glob("*.sql"))) if d.is_dir() else 0
                print(f"  {s}: 01_ddl {'OK' if p.is_file() else '缺失'} / 按表 {n}")
                rc |= 0 if p.is_file() else 1
    return rc


def local_ddl_paths(layer):
    """`{表名大写: 本地 ddl 文件}`（DWD 含 MASTER/dwd/ddl，DWS 只有三系统）。"""
    dirs = [SCRIPTS / s / layer.lower() / "ddl" for s in SYS]
    if layer == "DWD":
        dirs.append(SCRIPTS / "MASTER/dwd/ddl")
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
    checked, drift, extra = 0, 0, []
    for table, p in sorted(local.items()):
        if table not in stmts:
            extra.append(table)
            continue
        checked += 1
        diff = verify.diff_ddl(stmts[table] + ";",
                               p.read_text(encoding="utf-8", errors="replace"),
                               "甲方", "本地")
        if diff.empty():
            continue
        drift += 1
        print(f"  ✗ {table} 差异: {diff.summary()}")
        _print_ddl_diff(diff, limit=limit)
    if extra:
        shown = ", ".join(extra[:6]) + (" …" if len(extra) > 6 else "")
        print(f"  ⚠ 本地独有 {len(extra)} 张（甲方建表脚本无此表，跳过比对）: {shown}")
    return checked, drift


def cmd_verify_ddl(args):
    """仅校验本地 DDL 与甲方一致性（不落盘，不改文件）。"""
    layers = layers_of(args)
    strict = not getattr(args, "no_strict", False)
    rc = 0
    if "DWS" in layers:
        print("== DWS DDL 校验 ==")
        if not SRC_DWS_DDL.is_file():
            print(f"  ✗ {SRC_DWS_DDL} 不存在")
            return 1
        stmts = parse_jf_ddl(SRC_DWS_DDL)
        owner = dws_table_sys_map()
        have = {t: owner[t] for t in stmts if t in owner}
        verify = _load_ddl_verify()
        drift_count = 0
        for table, sysname in have.items():
            local_path = SCRIPTS / sysname / f"dws/ddl/{table}.sql"
            if not local_path.is_file():
                print(f"  ⚠ {table} ({sysname}): 本地文件不存在")
                drift_count += 1
                continue
            jf_text = stmts[table] + ";"
            local_text = local_path.read_text(encoding="utf-8", errors="replace")
            diff = verify.diff_ddl(jf_text, local_text, "甲方", "本地")
            if not diff.empty():
                drift_count += 1
                print(f"  ✗ {table} ({sysname}) 差异: {diff.summary()}")
                _print_ddl_diff(diff, limit=3)
            else:
                print(f"  ✓ {table} ({sysname}) 一致")
        print(f"  校验完成：{len(have)} 张表，{drift_count} 张有差异")
        if drift_count and strict:
            rc = 1
    if "DWD" in layers:
        print("== DWD DDL 校验 ==")
        n, drift = verify_ddl_vs_jf("DWD", SRC_DWD_DDL)
        if drift < 0:
            return 1
        print(f"  校验完成：{n} 张表，{drift} 张有差异")
        if drift and strict:
            rc = 1
    return rc


def cmd_lineage(args):
    layers = layers_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD lineage ==")
        rc |= run([PY, DWD_PIPE, "lineage"] + _ap(args))[0]
    if "DWS" in layers:
        print("== DWS lineage ==")
        total = 0
        for s in SYS:
            p = SCRIPTS / s / "dws/lineage/DWS_lineage.xlsx"
            print(f"  {s}: {'OK' if p.is_file() else '缺失'} {p}")
            if not p.is_file():
                rc = 1
            else:
                try:
                    import pandas as pd
                    df = pd.read_excel(p, sheet_name="表级血缘(扁平)")
                    total += len(df)
                    print(f"       表级 {len(df)} 行")
                except Exception as e:
                    print(f"       ⚠ {e}")
                    rc = 1
        print(f"  DWS 表级血缘合计 {total} 行")
        # ★ 2026-10-26：`scripts/DWS_依赖关系.xlsx` 原来只能手工跑 `tools/dws-dep-report.py`，
        #   `all` 里永远不刷新 ⇒ 重建后文档停留在旧版（实测落后两天）。
        #   这里并进来，与 DWD 侧 `DWD_依赖关系.xlsx` 对齐：`lineage` 子命令即刷新。
        if DWS_DEP_REPORT.is_file():
            cmd = [PY, DWS_DEP_REPORT] + _ap(args)
            rc |= run(cmd)[0]
    return rc


def cmd_config(args):
    layers = layers_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD 依赖配置 ==")
        rc |= run([PY, DWD_PIPE, "depcfg", "--out", DEPCFG_DWD] + _ap(args))[0]
    if "DWS" in layers:
        print("== DWS 依赖配置 ==")
        # 目标脚本没有 --dry-run，只有 --stats（只看统计不落盘）
        cmd = [PY, DWS_DEPS] + ([] if getattr(args, "apply", False) else ["--stats"])
        rc |= run(cmd)[0]
        if args.apply:
            m = {}
            for p in sorted(DEPCFG_DWS.glob("*.dep.json")):
                c = json.loads(p.read_text(encoding="utf-8"))
                if c.get("target_cn"):
                    m[c["target"]] = c["target_cn"]
            out = SCRIPTS / "DWS_表中文名.json"
            # sort_keys + 尾换行：否则每次跑都因字典序抖动产生无意义 diff
            out.write_text(json.dumps(m, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
                           encoding="utf-8", newline="\n")
            print(f"  中文名 {len(m)} 条 -> {out}")
    return rc


def _ds_client():
    """惰性取 `ds_client` 模块（复用 `_ds_deploy()` 的 sys.path 注入）。

    ★ 2026-10-26：原实现自己在函数里 `sys.path.insert` + `import ds_client`，
      与 `_ds_deploy()` 重复。现在统一走后者，避免两处 sys.path 逻辑漂移。
    """
    return _ds_deploy()[0]


def ds_workflows(prefixes):
    dc = _ds_client()
    ds = dc.get_client()
    pcode = dc.project_code(
        ds.call("GET", "/projects", params={"pageNo": 1, "pageSize": 100}), "dw")
    wf = dc.lst_of(ds.call("GET", f"/projects/{pcode}/workflow-definition",
                           params={"pageNo": 1, "pageSize": 500}))
    return ds, pcode, [w for w in wf if str(w["name"]).startswith(prefixes)]


def dws_refs_into_dwd(ds, pcode, dwd_codes):
    """查 DWS_* 工作流的依赖项里有没有指向 DWD_*/MASTER_* 工作流的引用。

    ★ DWD 删除只会被「别的 DEPENDENT 引用着」挡住；DWS 存在本身并不挡删。
      旧逻辑是「有 DWS 就拒」，过于保守 ⇒ 改为**实测引用**。
    ★★ 引用落在 dependItemList[].**definitionCode**（= 被引用工作流的 code）；
       projectCode 是**项目** code（dw 项目恒为 185582190746560），不能拿来比。
    """
    dc = _ds_client()
    hits = []
    dws = [w for w in dc.lst_of(ds.call(
        "GET", f"/projects/{pcode}/workflow-definition",
        params={"pageNo": 1, "pageSize": 500})) if w["name"].startswith("DWS_")]
    for w in dws:
        g = ds.call("GET", f"/projects/{pcode}/workflow-definition/{w['code']}")
        for t in dc.task_definitions(g):
            for d in dc.dependence_of(t):
                for it in d.get("dependItemList") or []:
                    if it.get("definitionCode") in dwd_codes:
                        hits.append((w["name"], t.get("name"), it.get("definitionCode")))
    return hits


def check_dwd_only_preflight(layers, block=True):
    """DWD 单独重建的前置检查：DWS 侧若引用着 DWD 工作流，删 DWD 会被 DS 拒绝。

    ★★ 实测（2026-10-21）：DWS_HSFA/O32/ZTA 共 127 条依赖项引用了全部 10 个
       DWD_* 工作流（dependItemList[].definitionCode）⇒ **只重建 DWD 一定失败**，
       必须 `--layers DWD,DWS`（先删 DWS 释放引用 → 重建 DWD → 重建 DWS）。
       这里用**实测引用**给出精确原因，而不是笼统说「有 DWS 就挡」。
    ★ 2026-10-26：预检本身是只读的，原先只在 `--apply` 才跑 ⇒ dry-run 说「可以」、
      apply 才被拒。现在 dry-run 也跑，只降级为告警（block=False），不阻断。
    """
    mark = "✗" if block else "⚠"
    if "DWD" in layers and "DWS" not in layers:
        try:
            ds, pcode, dws = ds_workflows(("DWS_",))
        except Exception as e:
            print(f"  ⚠ 无法检查 DWS 工作流: {e}")
            return True
        if dws:
            allwf = _ds_client().lst_of(ds.call(
                "GET", f"/projects/{pcode}/workflow-definition",
                params={"pageNo": 1, "pageSize": 500}))
            dwd_codes = {w["code"]: w["name"] for w in allwf
                         if w["name"].startswith(("DWD_", "MASTER_"))}
            hits = dws_refs_into_dwd(ds, pcode, set(dwd_codes))
            if hits:
                used = sorted({dwd_codes[h[2]] for h in hits if h[2] in dwd_codes})
                print(f"  {mark} DWS 的 {len(hits)} 条依赖项引用着 {len(used)} 个 DWD 工作流，"
                      f"删 DWD 会被 DS 拒绝：{used}")
                if block:
                    print("    改用 --layers DWD,DWS 一起删/建"
                          "（先删 DWS 释放引用 → 重建 DWD → 重建 DWS），"
                          "或先单独跑 --layers DWS --delete-only")
                else:
                    print("    （dry-run 仅提示；加 --apply 会在此处中止）")
                return False
            print(f"  ✓ DWS 存在 {len(dws)} 个，且无 DWS→DWD 依赖引用，不挡 DWD 删除/重建")
    return True


def cmd_delete(args):
    layers = layers_of(args)
    if not check_dwd_only_preflight(layers, block=args.apply) and args.apply:
        return 1
    # 顺序固定：先删 DWS 释放对 DWD 的引用，再删 DWD（反过来会被 DS 拒绝）
    for layer, label in (("DWS", "删除 DWS 工作流"), ("DWD", "删除 DWD 工作流")):
        if layer in layers:
            print(f"== {label} ==")
            rc = run([PY, DEPLOY_ALL, "--layer", layer, "--delete-only"] + _dry(args))[0]
            if rc:
                print(f"  ✗ {label} 失败（rc={rc}）⇒ 中止（继续往下删会被 DS 拒绝）")
                return rc
    return 0


def cmd_deploy(args):
    layers = layers_of(args)
    if not check_dwd_only_preflight(layers, block=args.apply) and args.apply:
        return 1
    # 顺序固定：预删 DWS → 删/建 DWD → 建 DWS（跨层引用不会挡删）
    steps = []
    if "DWS" in layers:
        steps.append(("预删 DWS（释放对 DWD 的引用）", ["--layer", "DWS", "--delete-only"]))
    if "DWD" in layers:
        steps.append(("删除并重建 DWD", ["--layer", "DWD"]))
    if "DWS" in layers:
        steps.append(("创建 DWS", ["--layer", "DWS"]))
    # ★ 2026-10-26：原先是 `rc |= run(...)` 一路累计 ⇒ DWD 重建失败仍会继续「创建 DWS」，
    #   把「未部署」变成「DWS 引用缺失上游的半坏状态」。改为失败即中止。
    for label, extra in steps:
        print(f"== {label} ==")
        rc = run([PY, DEPLOY_ALL] + extra + _dry(args))[0]
        if rc:
            print(f"  ✗ {label} 失败（rc={rc}）⇒ 中止后续步骤，避免 DS 留下半成品")
            return rc
    if args.apply:
        for layer in ("DWD", "DWS"):
            if layer in layers:
                print(f"== 排版 {layer} ==")
                rc = run([PY, RELAYOUT, layer.lower(), "--apply"])[0]
                if rc:
                    print(f"  ✗ 排版 {layer} 失败（rc={rc}）")
                    return rc
    return 0


def cmd_layout(args):
    layers = layers_of(args)
    rc = 0
    for layer in ("DWD", "DWS"):
        if layer in layers:
            print(f"== 排版 {layer} ==")
            cmd = [PY, RELAYOUT, layer.lower()] + _ap(args)
            rc |= run(cmd)[0]
    return rc


def cmd_repair(args):
    """拼接副本修复：只保留第一个 beeline 对应的完整 SQL（默认 dry-run）。

    ★ 口径（用户 2026-10-26 定）：类似 `DWS_PROD_SALE_DATA_PTD.sh` 这种「两份脚本被拼接」
      的甲方交付，一律只保留第一份（第一个 beeline 的完整 SQL），其后粘连的副本整段丢弃。
      判定与裁剪逻辑在 `tools/core/sh_repair.py`，这里只负责扫描/备份/落盘/标注。
    ★ 两份 SQL 不一致时**不落盘**（rc=1）：口径优先但不能默默丢内容，需人工确认。
    ★ 落盘后文件带 `DW-DEVIATION` 标记 ⇒ `stage_dws_from_jf` 不会用甲方原文把它覆盖回去。
    """
    layers = layers_of(args)
    mod = _sh_repair()
    rc = 0
    hits = 0
    for layer in ("DWD", "DWS"):
        if layer not in layers:
            continue
        print(f"== 修复 {layer} 脚本（拼接副本） ==")
        for s in SYS:
            d = SCRIPTS / s / layer.lower() / "02_etl"
            if not d.is_dir():
                continue
            for p in sorted(d.glob("*.sh")):
                text = p.read_bytes().decode("utf-8", "replace")
                n = mod.count_sql_calls(text)
                if n <= 1:
                    continue
                hits += 1
                new, notes = mod.trim_to_first_copy(text)
                print(f"  {s}/{p.name}: SQL 调用 ×{n}")
                for x in notes:
                    print(f"    {x}")
                if mod.DEVIATION_MARK in text:
                    print(f"    已带 {mod.DEVIATION_MARK} 标记，跳过")
                    continue
                if any("不一致" in x for x in notes):
                    print("    ✗ 副本 SQL 不一致，未落盘；人工确认后再手工处置")
                    rc = 1
                    continue
                if new == text:
                    print("    无可落盘改动")
                    continue
                if not args.apply:
                    print("    (dry-run，未落盘)")
                    continue
                bak = (REPO / "tools/.dx-tmp" /
                       f"backup-repair-{time.strftime('%Y%m%d-%H%M%S')}" / s)
                bak.mkdir(parents=True, exist_ok=True)
                shutil.copy2(p, bak / p.name)
                nl = "\r\n" if "\r\n" in new else "\n"
                mark = (f"# {mod.DEVIATION_MARK}: 甲方原文为两份脚本拼接（done 与 shebang 粘连，"
                        f"while 不闭合），按口径只保留第 1 个 beeline 的完整 SQL；"
                        f"勿用 --force-dws-raw 覆盖")
                if new.startswith("#!") and nl in new:
                    i = new.index(nl) + len(nl)
                    new = new[:i] + mark + nl + new[i:]
                else:
                    new = mark + nl + new
                p.write_bytes(new.encode("utf-8"))
                print(f"    已修复 → 备份 {bak / p.name}")
    if not hits:
        print("  未发现拼接副本（SQL 调用均 ≤1）")
    return rc


def _shell_syntax(p):
    """`bash -n` 语法检查：'ok' / 'bad' / 'skip'（skip = 环境拦住 bash，无法判定）。

    ★ 四个坑（全部实测过，别退回单一写法）：
      ① 沙箱/安全策略拦住 bash 启动时，stderr 是 UTF-16LE 的「拒绝访问」（含 \\x00），
         这不是脚本语法问题 ⇒ 记为跳过，不算失败；
      ② 甲方交付的 DWS .sh **24/24 都是 CRLF**，bash 会把行尾 `\\r` 当语法错误
         （`unexpected token $'\\r'`）⇒ 先归一化到 LF，本地结论才与实跑一致
         （DS 侧 rawScript 也是 `\\r\\n`→`\\n` 后执行的）。不要改仓库 .sh 本身：
         口径要求与甲方逐字节一致；
      ③ 不能用文件路径：**cygwin 版 bash 由 Windows 原生进程启动时会把 `C:\\a\\b`
         里的反斜杠吃掉**（实测 rc=127 `C:Users…: No such file`）⇒ 24 个脚本全被判
         "语法失败"。故改为 `bash -n -` 从 stdin 读脚本；
      ④ stdin 必须传 **bytes**：`text=True` 在 Windows 会把 `\\n` 反向翻译成 `\\r\\n`，
         CRLF 又回来了、照样 `$'\\r'` 报错（这个坑最隐蔽）。
    """
    try:
        text = _ds_deploy()[1].read_script(p)
    except OSError:
        return "skip"
    try:
        r = subprocess.run(["bash", "-n", "-"], input=text.encode("utf-8"),
                           capture_output=True, timeout=60)
    except (OSError, subprocess.SubprocessError):
        return "skip"
    if r.returncode == 0:
        return "ok"
    err = (r.stderr or b"").decode("utf-8", "replace")
    return "skip" if ("\x00" in err or "拒绝" in err) else "bad"


def verify_dws(use_ds):
    rc = 0
    print("== DWS 本地 ==")
    total = 0
    skipped_all = 0
    for s in SYS:
        b = {p.name: p for p in (SCRIPTS / s / "dws/02_etl").glob("*.sh")}
        total += len(b)
        bad, skipped = [], 0
        for name, p in sorted(b.items()):
            r = _shell_syntax(p)
            if r == "bad":
                bad.append(name)
            elif r == "skip":
                skipped += 1
        skipped_all += skipped
        tail = f" / 无法判定 {skipped}" if skipped else ""
        print(f"  {s}: scripts {len(b)} / 语法通过 {len(b) - len(bad) - skipped}{tail}")
        if bad:
            print("    ", bad[:8])
            rc = 1
        # 拼接副本（SQL 调用 >1）单独报：它可能语法上是「通」的，但会重复执行 SQL
        dup = [name for name, p in sorted(b.items())
               if _sh_repair().count_sql_calls(
                   p.read_bytes().decode("utf-8", "replace")) > 1]
        if dup:
            print(f"    ⚠ 拼接副本（SQL 调用 >1）→ 跑 repair 子命令: {dup}")
            rc = 1
    if skipped_all:
        print(f"  ⚠ {skipped_all}/{total} 个脚本的 bash -n 未能执行（环境安全策略拦截），"
              f"语法结果不可判定")
    print(f"  DWS 脚本合计 {total}")
    if total != DWS_EXPECT_SCRIPTS:
        rc = 1
    n_dep = len(list(DEPCFG_DWS.glob("*.dep.json")))
    print(f"  依赖配置 {n_dep} 份")
    if n_dep != DWS_EXPECT_DEPS:
        rc = 1
    if use_ds:
        print("== DWS DS ==")
        try:
            ds, _p, wfs = ds_workflows(("DWS_",))
        except Exception as e:
            print(f"  ⚠ DS 连接失败: {e}")
            return 1
        print(f"  DWS 工作流 {len(wfs)} 个: {sorted(w['name'] for w in wfs)}")
        if len(wfs) != DWS_EXPECT_WORKFLOWS:
            rc = 1
        dc, dt = _ds_deploy()
        for w in wfs:
            g = ds.call("GET", f"/projects/{_p}/workflow-definition/{w['code']}")
            tds = dc.task_definitions(g)
            shells = [t for t in tds if t.get("taskType") == "SHELL"]
            deps = [t for t in tds if t.get("taskType") == "DEPENDENT"]
            sysname = DWS_WF2SYS.get(w["name"])
            local = {p.stem: p for p in (SCRIPTS / (sysname or "") / "dws/02_etl").glob("*.sh")}
            bad = []
            for t in shells:
                tp = t.get("taskParams") or {}
                if isinstance(tp, str):
                    tp = json.loads(tp)
                p = local.get(t["name"])
                if not p or dt.normalize_newlines(tp.get("rawScript") or "").strip() != \
                        dt.normalize_newlines(p.read_text(encoding="utf-8")).strip():
                    bad.append(t["name"])
            print(f"  {w['name']}: {w.get('releaseState')} SHELL {len(shells)} DEP {len(deps)} "
                  f"脚本不一致 {len(bad)}")
            depmap = {t["name"]: t for t in deps}
            miss_dep = []
            for t in shells:
                cfgp = DEPCFG_DWS / f"{t['name']}.dep.json"
                if not cfgp.is_file():
                    continue
                c = json.loads(cfgp.read_text(encoding="utf-8"))
                expected = bool(c.get("same_workflow_predecessors") or
                                c.get("cross_workflow") or c.get("mapping_deps"))
                node = depmap.get("dep_" + t["name"])
                if expected and not node:
                    miss_dep.append(t["name"])
                    continue
                if not node:
                    continue
                tp = node.get("taskParams") or {}
                if isinstance(tp, str):
                    tp = json.loads(tp)
                n = sum(len(g.get("dependItemList", []))
                        for g in (tp.get("dependence") or {}).get("dependTaskList", []))
                if expected and n == 0:
                    miss_dep.append(t["name"])
            print(f"       依赖节点缺失/空: {len(miss_dep)}")
            if miss_dep:
                print("       ", miss_dep[:8])
            if w.get("releaseState") != "ONLINE" or bad or miss_dep:
                rc = 1
    return rc


def cmd_verify(args):
    layers = layers_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD 校验 ==")
        cmd = [PY, DWD_PIPE, "verify"] + (["--ds"] if args.ds else [])
        rc |= run(cmd)[0]
    if "DWS" in layers:
        rc |= verify_dws(args.ds)
    return rc


def cmd_all(args):
    rc = 0
    for name, fn in (("scripts", cmd_scripts), ("ddl", cmd_ddl),
                     ("lineage", cmd_lineage), ("config", cmd_config)):
        print(f"\n===== {name} =====")
        r = fn(args)
        if r:
            print(f"✗ {name} 失败（rc={r}）")
            return r
    if args.deploy:
        print("\n===== deploy =====")
        rc |= cmd_deploy(args)
        if rc:
            return rc
        args.ds = True
    print("\n===== verify =====")
    rc |= cmd_verify(args)
    return rc


# --------------------------------------------------------------------------- #
# CLI：参数单一来源 + 按子命令裁剪
#   原来 7 个开关挂在**每个**子命令上（靠 argparse.SUPPRESS 防止子解析器覆盖默认值），
#   于是 `verify --help` 会列出 --deploy / --force-dws-raw 这些完全无关的开关，
#   拼错子命令也不报错。现在改成「谁用谁声明」：verify 只有 --layers/--ds，
#   deploy/delete/layout 只有 --layers/--apply，逃生舱只挂在 scripts 上。
# --------------------------------------------------------------------------- #
OPT = {
    "layers": (("--layers",), dict(
        default="DWD,DWS", metavar="DWD,DWS",
        help="处理层级，逗号分隔（默认 DWD,DWS）")),
    "source": (("--source",), dict(
        choices=("jf", "gen"), default="jf",
        help="jf=甲方搬移（DWS 从甲方 02-DWS执行脚本）；gen=自动生成（DWD 不碰 MASTER）")),
    "apply": (("--apply",), dict(
        action="store_true", help="真正落盘/动 DS（默认 dry-run）")),
    "ds": (("--ds",), dict(
        action="store_true", help="连 DolphinScheduler 回读（工作流状态、脚本一致性）")),
    "deploy": (("--deploy",), dict(
        action="store_true", help="all 末尾追加删除/重建/排版")),
    "gen_err": (("--allow-gen-errors",), dict(
        action="store_true", help="gen 模式忽略生成器 ERROR 日志（仍会复制产物）")),
    "raw": (("--force-dws-raw",), dict(
        action="store_true", help="用甲方 02-DWS执行脚本 原文覆盖 scripts 里的 DWS 脚本")),
    "no_strict": (("--no-strict",), dict(
        action="store_true", help="DDL 校验发现差异时不阻断（默认阻断）")),
}

# 子命令 → (处理函数, 用到的参数, 一行说明)
SUBCOMMANDS = {
    "scripts": (cmd_scripts, ("layers", "source", "apply", "gen_err", "raw"),
                "同步/生成脚本（jf 搬甲方 txt；gen 跑生成器）"),
    "ddl": (cmd_ddl, ("layers", "source", "apply", "no_strict"),
            "重建建表语句（含 Inceptor 方言清洗，落盘后自检与甲方一致）"),
    "verify-ddl": (cmd_verify_ddl, ("layers", "source", "no_strict"),
                   "仅校验本地 DDL 与甲方一致性（不落盘）"),
    "lineage": (cmd_lineage, ("layers", "apply"), "重建依赖/血缘工作簿"),
    "config": (cmd_config, ("layers", "apply"), "生成 DS 依赖配置 dep-config-*"),
    "delete": (cmd_delete, ("layers", "apply"), "删除 DS 工作流（先 DWS 后 DWD）"),
    "deploy": (cmd_deploy, ("layers", "apply"), "删除并重建 DS 工作流 + 排版"),
    "layout": (cmd_layout, ("layers", "apply"), "只重排工作流坐标"),
    "repair": (cmd_repair, ("layers", "apply"),
               "拼接副本修复：只保留第 1 个 beeline 的完整 SQL"),
    "verify": (cmd_verify, ("layers", "ds"), "校验脚本/DDL/依赖配置"),
    "all": (cmd_all, ("layers", "source", "apply", "ds", "deploy", "gen_err", "raw", "no_strict"),
            "串跑 scripts→ddl→lineage→config→(deploy)→verify"),
}


def main():
    ap = argparse.ArgumentParser(
        description="DWD + DWS 一体化管线（所有写操作默认 dry-run，加 --apply 才落盘）")
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name, (fn, opts, text) in SUBCOMMANDS.items():
        p = sub.add_parser(name, help=text, description=text)
        for key in opts:
            flags, kw = OPT[key]
            p.add_argument(*flags, **kw)
        p.set_defaults(func=fn)
    args = ap.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
