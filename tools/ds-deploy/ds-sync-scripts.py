#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DS 脚本同步统一入口（按 --layer 自动路由到 ODS 或 DWD/DWS 同步实现）。

用法
----
    python3 tools/ds-deploy/ds-sync-scripts.py --layer ODS [--apply] [--sys O32] ...
    python3 tools/ds-deploy/ds-sync-scripts.py --layer DWD [--apply] [--only ...]
    python3 tools/ds-deploy/ds-sync-scripts.py --layer DWS [--apply]

默认 dry-run（与各子工具口径一致）；仅显式传入 ``--apply`` 时才会修改 DS 定义。
原有入口 ``ds-sync-ods-scripts.py`` 与 ``ds-sync-dwd-scripts.py`` 完整保留以兼容旧命令。
"""
import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ODS_SYNC_SCRIPT = os.path.join(HERE, "ds-sync-ods-scripts.py")
DWD_SYNC_SCRIPT = os.path.join(HERE, "ds-sync-dwd-scripts.py")


def build_command(layer: str, extra_args: list) -> list:
    """根据层级构造目标同步命令（供 CLI 与单元测试复用）。"""
    norm = (layer or "").strip().upper()
    if norm == "ODS":
        return [sys.executable, ODS_SYNC_SCRIPT, *extra_args]
    if norm in ("DWD", "DWS"):
        return [sys.executable, DWD_SYNC_SCRIPT, "--layer", norm, *extra_args]
    raise ValueError(f"不支持的层级: {layer!r}（仅支持 ODS / DWD / DWS）")


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(
        description="统一脚本同步入口（--layer ODS|DWD|DWS），其余参数原样透传给底层同步脚本",
    )
    ap.add_argument(
        "--layer",
        required=True,
        choices=("ODS", "DWD", "DWS", "ods", "dwd", "dws"),
        help="目标层级：ODS / DWD / DWS",
    )
    args, rest = ap.parse_known_args(argv)
    cmd = build_command(args.layer, rest)
    return subprocess.run(cmd).returncode


if __name__ == "__main__":
    sys.exit(main())
