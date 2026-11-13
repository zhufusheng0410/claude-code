# -*- coding: utf-8 -*-
"""血缘与依赖配置（DWS 侧；DWD 侧委托子进程）。"""
import json

from tools.dws import state as st
from tools.dws.args import _ap, layers_of
from tools.dws.process import run


def cmd_lineage(args):
    layers = layers_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD lineage ==")
        rc |= run([st.PY, st.DWD_PIPE, "lineage"] + _ap(args))[0]
    if "DWS" in layers:
        print("== DWS lineage ==")
        total = 0
        for s in st.SYS:
            p = st.SCRIPTS / s / "dws/lineage/DWS_lineage.xlsx"
            print(f"  {s}: {'OK' if p.is_file() else '缺失'} {p}")
            if not p.is_file():
                rc = 1
            else:
                try:
                    import pandas as pd
                    df = pd.read_excel(p, sheet_name="表级血缘(扁平)")
                    total += len(df)
                    print(f"       表级 {len(df)} 行")
                except (ImportError, OSError, ValueError, KeyError, TypeError) as e:
                    # 缺 pandas / 文件坏 / 缺 sheet：只影响本系统的行数统计，记失败继续。
                    print(f"       ⚠ {type(e).__name__}: {e}")
                    rc = 1
        print(f"  DWS 表级血缘合计 {total} 行")
        # ★ 2026-10-26：`scripts/DWS_依赖关系.xlsx` 原来只能手工跑 `tools/dws-dep-report.py`，
        #   `all` 里永远不刷新 ⇒ 重建后文档停留在旧版（实测落后两天）。
        #   这里并进来，与 DWD 侧 `DWD_依赖关系.xlsx` 对齐：`lineage` 子命令即刷新。
        if st.DWS_DEP_REPORT.is_file():
            cmd = [st.PY, st.DWS_DEP_REPORT] + _ap(args)
            rc |= run(cmd)[0]
    return rc


def cmd_config(args):
    layers = layers_of(args)
    rc = 0
    if "DWD" in layers:
        print("== DWD 依赖配置 ==")
        rc |= run([st.PY, st.DWD_PIPE, "depcfg", "--out", str(st.DEPCFG_DWD)] + _ap(args))[0]
    if "DWS" in layers:
        print("== DWS 依赖配置 ==")
        # 目标脚本没有 --dry-run，只有 --stats（只看统计不落盘）
        cmd = [st.PY, st.DWS_DEPS] + ([] if getattr(args, "apply", False) else ["--stats"])
        rc |= run(cmd)[0]
        if args.apply:
            m = {}
            for p in sorted(st.DEPCFG_DWS.glob("*.dep.json")):
                c = json.loads(p.read_text(encoding="utf-8"))
                if c.get("target_cn"):
                    m[c["target"]] = c["target_cn"]
            out = st.SCRIPTS / "DWS_表中文名.json"
            # sort_keys + 尾换行：否则每次跑都因字典序抖动产生无意义 diff
            out.write_text(json.dumps(m, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
                           encoding="utf-8", newline="\n")
            print(f"  中文名 {len(m)} 条 -> {out}")
    return rc
