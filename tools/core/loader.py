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
    # ★ 2026-11-09（评审 B3）：缓存键用 normcase(realpath)。
    #   只用 abspath 时，Windows 下 `D:\a\X.py` 与 `d:\a\x.py`（大小写/短路径）
    #   会被当成两个模块，各执行一次、模块级副作用翻倍。
    key = os.path.normcase(os.path.realpath(str(path)))
    cached = _CACHE.get(key)
    if cached is not None:
        return cached

    ap = os.path.abspath(str(path))
    if not os.path.isfile(ap):
        raise ImportError("要加载的模块不存在: %s" % ap)

    modname = name or _module_name(ap)
    spec = importlib.util.spec_from_file_location(modname, ap)
    if spec is None or spec.loader is None:
        raise ImportError("无法按路径加载模块: %s" % ap)
    mod = importlib.util.module_from_spec(spec)
    # 先注册再执行：允许模块内部出现循环引用（部分脚本会互相 import 同一批工具）。
    # ★ 但**执行失败必须回滚**：原实现把半初始化对象永久留在 sys.modules 里，
    #   调用方重试成功拿到的是另一个对象，`sys.modules[name] is mod` 为 False
    #   ⇒ dataclasses / get_type_hints / pickle 会拿错模块（评审 B3 实测）。
    prev = sys.modules.get(modname)
    sys.modules[modname] = mod
    try:
        spec.loader.exec_module(mod)
    except BaseException:
        if prev is not None:
            sys.modules[modname] = prev
        else:
            sys.modules.pop(modname, None)
        raise
    _CACHE[key] = mod
    return mod
