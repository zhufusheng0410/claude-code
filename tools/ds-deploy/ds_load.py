# -*- coding: utf-8 -*-
"""ds-deploy 按路径加载模块的唯一入口。

连字符文件名不能 ``import``。真正的加载（按绝对路径缓存、只执行一次）
在 ``tools/core/loader.py``。本文件只把仓库根放进 ``sys.path`` 再转交它，
这样本目录脚本不用再各抄一份「算仓库根 + from tools.core.loader import load」。

直接运行本目录脚本时，``sys.path[0]`` 就是本目录，写::

    from ds_load import load as _load_file

``tools/`` 下的脚本不在本目录，继续自己插入仓库根后
``from tools.core.loader import load``。两边拿到的是同一个模块对象、同一份缓存。
"""
import os
import sys

_REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if _REPO not in sys.path:
    sys.path.insert(0, _REPO)

from tools.core.loader import load  # noqa: E402

__all__ = ["load"]
