#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DS 统一只读巡检入口（整合运行中实例检查与集群表存在性核查）。

用法
----
    python3 tools/ds-deploy/ds-inspect.py running [--all]   # 查 DS 未结束实例（动 DS 前必跑）
    python3 tools/ds-deploy/ds-inspect.py tables            # 查 DWD 目标表与源表是否在 Hive 中存在
    python3 tools/ds-deploy/ds-inspect.py all [--all]       # 依次执行 running + tables

原有单功能脚本 ``ds-check-running.py`` 与 ``ds-check-tables-exist.py`` 均保留，
本工具作为统一只读巡检入口，不修改 DS 定义或 Hive 数据。
"""
import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RUNNING_SCRIPT = os.path.join(HERE, "ds-check-running.py")
TABLES_SCRIPT = os.path.join(HERE, "ds-check-tables-exist.py")


def _run(script: str, extra_args: list) -> int:
    proc = subprocess.run([sys.executable, script, *extra_args])
    return proc.returncode


def build_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(
        description="DS 统一只读巡检入口（running / tables / all）"
    )
    sub = ap.add_subparsers(dest="cmd", required=True)

    p_run = sub.add_parser("running", help="检查 DS 中是否有未结束的跑批实例")
    p_run.add_argument("--all", action="store_true", help="检查所有项目（默认只看 dw）")

    sub.add_parser("tables", help="核查 DWD 目标表与脚本引用的源表是否在 Hive 中存在")

    p_all = sub.add_parser("all", help="依次执行 running 与 tables 巡检")
    p_all.add_argument("--all", action="store_true", help="running 阶段检查所有项目")
    return ap


def main(argv=None) -> int:
    args = build_parser().parse_args(argv)
    if args.cmd == "running":
        extra = ["--all"] if args.all else []
        return _run(RUNNING_SCRIPT, extra)
    if args.cmd == "tables":
        return _run(TABLES_SCRIPT, [])
    if args.cmd == "all":
        extra = ["--all"] if args.all else []
        rc1 = _run(RUNNING_SCRIPT, extra)
        rc2 = _run(TABLES_SCRIPT, [])
        return rc1 or rc2
    return 2


if __name__ == "__main__":
    sys.exit(main())
