# -*- coding: utf-8 -*-
"""Facade 补丁桥：按路径加载的入口模块把路径类赋值写穿到真实子模块。

★ 为什么单独一个模块
    ``tools/dw-pipeline.py`` 与 ``tools/dwd-pipeline.py`` 都需要「找到正在
    执行本文件的模块对象」以及「把赋值写穿到子模块」这两件事。原先各存一份，
    且 ``executing_module`` 放在 ``tools/core/loader.py`` 里，让按路径加载器
    背上了 CPython 栈语义。⇒ 抽到本模块，``loader.py`` 只保留 ``load()``。

用法
----
    from tools.core.facade_bridge import executing_module, PatchBridge

    class _PatchBridge(PatchBridge):
        _PATCHABLE = {'REPO': _state, 'SCRIPTS': _state, ...}

    _self = executing_module(globals(), __name__)
    if _self is not None:
        _self.__class__ = _PatchBridge
"""
import sys
import types


def executing_module(namespace, module_name):
    """返回正在执行 ``namespace`` 的模块对象，供模块级补丁桥安装使用。

    ``loader.load`` 会先登记 ``sys.modules``；直接 ``exec_module`` 的调用方
    可能尚未保存返回对象，因此还需要沿调用栈查找。两种加载方式共用这一份。
    """
    registered = sys.modules.get(module_name)
    if registered is not None and getattr(registered, '__dict__', None) is namespace:
        return registered
    frame = sys._getframe()
    while frame is not None:
        for val in frame.f_locals.values():
            if getattr(val, '__dict__', None) is namespace:
                return val
        frame = frame.f_back
    return None


class PatchBridge(types.ModuleType):
    """把对本模块的赋值写穿到 ``_PATCHABLE`` 指定的真实模块。

    子类必须定义 ``_PATCHABLE``：{属性名: 目标模块}。命中时同时写目标模块
    和本模块，保证两边读到同一值；未命中时只写本模块。
    """
    _PATCHABLE = {}

    def __setattr__(self, name, value):
        target = self._PATCHABLE.get(name)
        if target is not None:
            setattr(target, name, value)
        super().__setattr__(name, value)
