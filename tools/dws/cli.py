# -*- coding: utf-8 -*-
"""DWS 管线 CLI：参数单一来源 + 按子命令裁剪。"""
import argparse
import sys

from tools.dws.ddl import cmd_ddl
from tools.dws.deploy import cmd_delete, cmd_deploy, cmd_layout
from tools.dws.lineage import cmd_config, cmd_lineage
from tools.dws.scripts import cmd_repair, cmd_scripts
from tools.dws.verify import cmd_verify, cmd_verify_ddl


def cmd_all(args):
    rc = 0
    steps = [("scripts", cmd_scripts), ("ddl", cmd_ddl)]
    # ★ 2026-11-09（评审 A8）：jf 模式落盘后立即与甲方逐表自检（结构+语句边界）。
    #   gen 模式的 DDL 来自生成器，与甲方本就不保证逐字节一致（如 6 张去分区表），
    #   拿它去比甲方只会误报 ⇒ 只在 jf 模式串这一步。
    if args.source == "jf":
        steps.append(("verify-ddl", cmd_verify_ddl))
    steps += [("lineage", cmd_lineage), ("config", cmd_config)]
    for name, fn in steps:
        print(f"\n===== {name} =====")
        r = fn(args)
        if r:
            print(f"✗ {name} 失败（rc={r}）")
            return r
    if args.deploy:
        print("\n===== deploy =====")
        rc = cmd_deploy(args)
        if rc:
            return rc
        args.ds = True
    print("\n===== verify =====")
    return cmd_verify(args)


# --------------------------------------------------------------------------- #
# 原来 7 个开关挂在**每个**子命令上（靠 argparse.SUPPRESS 防止子解析器覆盖默认值），
# 于是 `verify --help` 会列出 --deploy 这类完全无关的开关，
# 拼错子命令也不报错。现在改成「谁用谁声明」：verify 只有 --layers/--ds，
# deploy/delete/layout 只有 --layers/--apply，逃生舱只挂在 scripts 上。
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
    "allow_gen_errors": (("--allow-gen-errors",), dict(
        action="store_true", help="gen 模式忽略生成器 ERROR 日志（仍会复制产物）")),
    "allow_stale_dws_manifest": (("--allow-stale-dws-manifest",), dict(
        action="store_true",
        help="清单 sha256/bytes 与现盘不一致时仍继续（不刷新清单、不覆盖脚本）")),    "no_strict": (("--no-strict",), dict(
        action="store_true", help="DDL 校验发现差异时不阻断（默认阻断）")),
    "strict": (("--strict",), dict(
        action="store_true",
        help="校验「无法判定」时按失败处理（如 bash 被环境拦截导致语法检查全 skip）")),
}

# 子命令 → (处理函数, 用到的参数, 一行说明)
SUBCOMMANDS = {
    "scripts": (cmd_scripts, ("layers", "source", "apply", "allow_gen_errors",
                              "allow_stale_dws_manifest"),
                "同步/生成脚本（jf 搬甲方 txt；gen 跑生成器）"),
    "ddl": (cmd_ddl, ("layers", "source", "apply", "no_strict",
                      "allow_stale_dws_manifest"),
            "重建建表语句（含 Inceptor 方言清洗，落盘后自检与甲方一致）"),
    "verify-ddl": (cmd_verify_ddl, ("layers", "source", "no_strict",
                                    "allow_stale_dws_manifest"),
                   "仅校验本地 DDL 与甲方一致性（不落盘）"),
    "lineage": (cmd_lineage, ("layers", "apply"), "重建依赖/血缘工作簿"),
    "config": (cmd_config, ("layers", "apply"), "生成 DS 依赖配置 dep-config-*"),
    "delete": (cmd_delete, ("layers", "apply"), "删除 DS 工作流（先 DWS 后 DWD）"),
    "deploy": (cmd_deploy, ("layers", "apply"), "删除并重建 DS 工作流 + 排版"),
    "layout": (cmd_layout, ("layers", "apply"), "只重排工作流坐标"),
    "repair": (cmd_repair, ("layers", "apply"),
               "拼接副本修复：只保留第 1 个 beeline 的完整 SQL"),
    "verify": (cmd_verify, ("layers", "ds", "strict"), "校验脚本/DDL/依赖配置"),
    "all": (cmd_all, ("layers", "source", "apply", "ds", "deploy", "allow_gen_errors",
                      "allow_stale_dws_manifest", "no_strict", "strict"),
            "串跑 scripts→ddl→verify-ddl→lineage→config→(deploy)→verify"),
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
