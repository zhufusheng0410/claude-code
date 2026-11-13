# -*- coding: utf-8 -*-
"""路径片段安全校验（DWD / DWS 管线共用）。

★ 为什么单独一个模块（2026-11-13 评审 L2）
    原先 `safe_sysname` 只定义在 `tools/dwd/ns.py`，而 `tools/dws/` 为了用它
    不得不反向依赖 DWD 包。它只依赖 `re`，放到 `tools/core/` 对两边都是叶子，
    依赖方向也更干净。
"""
import re

#: 系统简称的合法字符集（字母 / 数字 / 下划线）。
#   sysname 源自 MAPPING 目录下的一级子目录名（**外部输入**），会拼进输出路径；
#   含 `..` 或路径分隔符的目录名可把文件写到 SCRIPTS 之外（路径遍历）。
_SYS_RE = re.compile(r'^[A-Za-z0-9_]+$')

#: 历史 / 特例目录名：中文「主数据」与 ASCII 的 MASTER。
_ALLOWED_SPECIAL = ('主数据', 'MASTER')


def safe_sysname(name: str) -> str:
    """校验系统简称可安全用于路径拼接；不合法则抛 :class:`ValueError`。

    允许的特例：``主数据``（中文，历史目录名）与 ``MASTER``。
    """
    if name in _ALLOWED_SPECIAL:
        return name
    if not _SYS_RE.match(name or ''):
        raise ValueError(
            f"非法系统简称 {name!r}：只允许字母/数字/下划线"
            f"（含 '..'、路径分隔符等一律拒绝）")
    return name
