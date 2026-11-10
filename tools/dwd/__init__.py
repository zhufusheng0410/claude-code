# -*- coding: utf-8 -*-
"""DWD 甲方脚本搬移 + 血缘梳理。

子模块：``parsing``（解析）、``generation``（生成）、``ddl_check``（DDL 自检）、
``cli``（命令行）。对外入口仍是 ``tools/dwd-pipeline.py``。
"""

#: 由 REPO / SCRIPTS 派生、且调用方会改写的路径名。
#: ★ 2026-11-10（评审 H1）：这些名字**不得**被导出成其它模块的模块级快照。
#:   原先各模块 `globals().update(vars(ns))` 会把 `SCRIPTS`/`REPO` 拷成自己的
#:   独立名字；`ns.SCRIPTS` 改成临时目录后，拷贝仍指向真实仓库 ——
#:   实测 `parsing._script_index()` 扫描的是仓库而非临时目录。
#:   现在统一走 `_ns.REPO` / `_ns.SCRIPTS`（调用时取值），裸用即 NameError。
MUTABLE_PATHS = ("REPO", "SCRIPTS")


def export_ns(mod, namespace: dict) -> None:
    """把 ``mod`` 的公开名字导入 ``namespace``（通常传 ``globals()``）。

    跳过双下划线名，并跳过 :data:`MUTABLE_PATHS` —— 见上方说明。
    """
    for key, value in vars(mod).items():
        if key.startswith("__") or key in MUTABLE_PATHS:
            continue
        namespace[key] = value
