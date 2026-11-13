# -*- coding: utf-8 -*-
"""子命令参数辅助。

★ 为什么单独放这里：`scripts`/`ddl`/`verify` 都要用它们，而 `cli` 又要 import
  这些模块来分派 —— 放在 `cli.py` 会形成循环依赖。
"""
from tools.dws import state as st


def layers_of(args):
    raw = {x.strip().upper() for x in args.layers.split(",") if x.strip()}
    bad = raw - st.VALID_LAYERS
    if bad:
        raise SystemExit(f"--layers 只接受 DWD / DWS，收到: {','.join(sorted(bad))}")
    return raw or set(st.VALID_LAYERS)


def _ap(args):
    """`--apply` 透传：子脚本自身也是 dry-run 语义，必须显式转达。"""
    return ["--apply"] if getattr(args, "apply", False) else []


def _dry(args):
    """`--dry-run` 透传：目标脚本默认会真跑，只有本层未加 --apply 时才拦。"""
    return [] if getattr(args, "apply", False) else ["--dry-run"]


def stale_allowed(args):
    """是否放行「清单与现盘不一致」（`--allow-stale-dws-manifest`）。"""
    return getattr(args, "allow_stale_dws_manifest", False)


def strict_of(args):
    """DDL 校验是否阻断（默认阻断；`--no-strict` 关闭）。"""
    return not getattr(args, "no_strict", False)


def _dwd_ddl_cmd(args):
    """DWD DDL 子命令参数：透传 `--apply` 与 `--no-strict`。

    ★ 2026-11-08：`dwd-pipeline.py ddl` 当时没有 `--no-strict` 开关，
      无条件转发会在子进程 argparse 处失败（`all` 整条中断）。
    ★ 2026-11-09（评审 A8）：DWD 现在也有落盘自检，`--no-strict` 成为合法参数，
      因此改为**按需转发**（仅 args.no_strict 为真时）。
    """
    cmd = [st.PY, st.DWD_PIPE, "ddl"] + _ap(args)
    if getattr(args, "no_strict", False):
        cmd.append("--no-strict")
    return cmd
