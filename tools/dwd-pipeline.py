#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DWD 甲方脚本搬移 + 血缘梳理 一体化工具（薄入口）。

实现在 ``tools/dwd/``：
    parsing     MAPPING 归属、脚本依赖、分区口径
    generation  方言转换、依赖工作簿、DS 依赖配置
    ddl_check   DDL 落盘与自检
    cli         子命令

子命令与约定与拆分前相同（默认 dry-run，``--apply`` 才落盘）::

    owner / convert / distribute / ddl / lineage / prevday / depcfg / verify / all

按路径加载本文件的脚本（``dws-dep-report`` 等）仍能取到
``needs_schedule_dep`` / ``GROUPS`` / ``WORKFLOW_OVERRIDE`` 等名字。
"""
import sys
import types
from pathlib import Path

_REPO = Path(__file__).resolve().parents[1]
if str(_REPO) not in sys.path:
    sys.path.insert(0, str(_REPO))

from tools.core.facade_bridge import executing_module, PatchBridge
from tools.dwd import cli, ddl_check, generation, ns, parsing  # noqa: E402


def _export(mod):
    for key, val in vars(mod).items():
        if key.startswith('__'):
            continue
        globals()[key] = val


for _mod in (ns, parsing, generation, ddl_check, cli):
    _export(_mod)


class _PatchBridge(PatchBridge):
    """按路径加载后，测试会改本模块的 ``REPO`` / ``SCRIPTS``；写穿到 ns。"""
    _PATCHABLE = {'REPO': ns, 'SCRIPTS': ns}


_self = executing_module(globals(), __name__)
if _self is not None:
    _self.__class__ = _PatchBridge


if __name__ == '__main__':
    sys.exit(main())
