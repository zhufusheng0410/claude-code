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

from tools.dwd import cli, ddl_check, generation, ns, parsing  # noqa: E402


def _export(mod):
    for key, val in vars(mod).items():
        if key.startswith('__'):
            continue
        globals()[key] = val


for _mod in (ns, parsing, generation, ddl_check, cli):
    _export(_mod)


class _PatchBridge(types.ModuleType):
    """按路径加载后，测试会改 ``REPO`` / ``SCRIPTS``。写穿到 ns，路径函数才看得见。"""

    def __setattr__(self, name, value):
        if name in ('REPO', 'SCRIPTS'):
            setattr(ns, name, value)
        super().__setattr__(name, value)


def _executing_module():
    """正在执行本文件的模块对象。

    ``loader.load`` 会先登记 ``sys.modules``；单测则只 ``exec_module``、不登记。
    两种都要把补丁桥装到**调用方持有的那个对象**上。
    """
    g = globals()
    registered = sys.modules.get(__name__)
    if registered is not None and getattr(registered, '__dict__', None) is g:
        return registered
    frame = sys._getframe()
    while frame is not None:
        for val in frame.f_locals.values():
            if getattr(val, '__dict__', None) is g:
                return val
        frame = frame.f_back
    return None


_self = _executing_module()
if _self is not None:
    _self.__class__ = _PatchBridge


if __name__ == '__main__':
    sys.exit(main())
