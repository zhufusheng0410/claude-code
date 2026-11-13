#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DWD + DWS 一体化管线（薄入口）。

实现在 ``tools/dws/``：
    state     仓库路径、口径常量、共享状态
    args      子命令参数辅助
    process   子进程与文件同步原语
    manifest  `_DWS搬移清单.json` 守卫与 source map
    scripts   脚本搬移 / 同步 / 拼接副本修复
    ddl       DDL 解析、清洗、落盘与比对
    lineage   血缘与依赖配置
    deploy    DS 工作流操作
    verify    脚本 / DDL / DS 校验
    cli       参数解析与子命令分派

子命令、参数、默认 dry-run 行为与拆分前完全一致。

★ 兼容层
  历史上 `tools/tests/test_*.py` 与外部脚本会按路径加载本文件，然后直接改
  `REPO` / `SCRIPTS` / `SYS` / `SRC_DWS_EXEC` 或读 `cmd_*` / `_ap` 等名字。
  这里把它们原样再导出，并用 `_PatchBridge` 把路径类赋值**写穿**到
  `tools.dws.state`，否则各子模块仍会读写真实仓库（见 2026-11-10 评审 H1）。
"""
import sys
import types
from pathlib import Path

_REPO = Path(__file__).resolve().parents[1]
if str(_REPO) not in sys.path:
    sys.path.insert(0, str(_REPO))

from tools.dws import (args as _args, cli as _cli, ddl as _ddl, deploy as _deploy,
                       lineage as _lineage, manifest as _manifest,
                       process as _process, scripts as _scripts, state as _state,
                       verify as _verify)  # noqa: E402

#: 赋值时需要写穿到真实模块的「可变状态」名字 → 目标模块。
_PATCHABLE = {
    'REPO': _state, 'SCRIPTS': _state, 'SYS': _state, 'GROUPS': _state,
    'SRC_DWS_EXEC': _state, 'SRC_DWS_DDL': _state, 'SRC_DWD_DDL': _state,
    '_STALE_MANIFEST_WARNED': _manifest,
}
# ★ 2026-11-13（简化）：`cmd_*` 交给 `cli.cmd_all` 按名字查全局，测试替换时必须
#   同步写穿；这里从 cli 自动派生，新增命令不用再手工登记。
_PATCHABLE.update({n: _cli for n in vars(_cli) if n.startswith('cmd_')})


_EXPORT_SKIP = (types.ModuleType,)


def _export(mod):
    """把子模块的公开名字导入本 facade。

    ★ 评审 L1：跳过模块对象（`os`/`re`/`json`/`sys`/`argparse`）以及**外部**
      的函数/类（如 `pathlib.Path`），否则 facade 命名空间会被各模块的 import
      污染。数据对象（Path 实例、dict、int 等）一律保留 —— 注意不能用
      `getattr(val, '__module__')` 判断，实例会查到类属性而误判成 pathlib。
    """
    for key, val in vars(mod).items():
        if key.startswith('__') or isinstance(val, _EXPORT_SKIP):
            continue
        if isinstance(val, (types.FunctionType, type)):
            owner = getattr(val, '__module__', '') or ''
            if not owner.startswith('tools'):
                continue
        globals()[key] = val


for _mod in (_state, _args, _process, _manifest, _scripts, _ddl,
             _lineage, _deploy, _verify, _cli):
    _export(_mod)

# 历史名字兼容（拆分前是 `_shell_syntax` / `_fail_stale`）
_shell_syntax = _process.shell_syntax
_fail_stale = _manifest.fail_stale


class _PatchBridge(types.ModuleType):
    """把对本模块的路径类赋值写穿到 `tools.dws.state`（及 manifest 的告警标志）。"""

    def __setattr__(self, name, value):
        target = _PATCHABLE.get(name)
        if target is not None:
            setattr(target, name, value)
        super().__setattr__(name, value)


def _executing_module():
    """正在执行本文件的模块对象。

    ``tools.core.loader`` 会先登记 ``sys.modules``；单测则只 ``exec_module``、不登记。
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
    sys.exit(_cli.main())
