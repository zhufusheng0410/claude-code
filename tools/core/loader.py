#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""按文件路径加载模块的唯一实现（供 tools/ 与 tools/ds-deploy/ 共用）。

为什么需要它
------------
本仓库有大量脚本文件名带连字符（`ds-deploy-dwd-workflow.py`、`ds-run.py` …），
`import ds-deploy-x` 在语法上就不合法，于是各脚本各自抄了一份
`spec_from_file_location` 样板。抄出来的副本有两个问题：
  1. **必然漂移**：有的加缓存（`_CORE_MODS`）、有的每次 `exec_module` 重执行，
     同一个模块在不同脚本里被反复初始化，模块级副作用不一致；
  2. 改一处漏一处。
⇒ 统一到这里：**按绝对路径缓存**，同一文件只执行一次。

用法
----
    # tools/ds-deploy/：同目录 ds_load 已把仓库根放进 sys.path
    from ds_load import load
    # tools/ 下的脚本：自己把仓库根放进 sys.path 后
    from tools.core.loader import load

    D = load(os.path.join(HERE, "ds-deploy-dwd-workflow.py"))      # 名字自动取文件名
    P = load(os.path.join(REPO, "tools", "dwd-pipeline.py"), name="dwdpipe")  # 指定名

两边 import 的是同一个模块对象（同一份 ``_CACHE``）。不要再在每个脚本里
抄 ``_ROOT = …; sys.path.insert``。
"""
import importlib.util
import os
import sys

# 以「绝对路径」为键：同路径不同调用方拿到同一实例（真正只执行一次）。
_CACHE = {}


def _module_name(path):
    """由文件路径推导模块名：去掉扩展名，连字符转下划线。"""
    return os.path.splitext(os.path.basename(path))[0].replace("-", "_")


def load(path, name=None):
    """按绝对路径加载并缓存一个 .py 模块。

    path : .py 的路径（str / PathLike），内部转绝对路径
    name : 可选模块名（默认由文件名推导）。仅在需要固定 `__name__` 时传。

    同一路径重复调用返回同一模块对象，**不会重复执行**。
    """
    ap = os.path.abspath(str(path))
    cached = _CACHE.get(ap)
    if cached is not None:
        return cached

    if not os.path.isfile(ap):
        raise ImportError("要加载的模块不存在: %s" % ap)

    modname = name or _module_name(ap)
    spec = importlib.util.spec_from_file_location(modname, ap)
    if spec is None or spec.loader is None:
        raise ImportError("无法按路径加载模块: %s" % ap)
    mod = importlib.util.module_from_spec(spec)
    # 先注册再执行：允许模块内部出现循环引用（部分脚本会互相 import 同一批工具）。
    sys.modules.setdefault(modname, mod)
    spec.loader.exec_module(mod)
    _CACHE[ap] = mod
    return mod
