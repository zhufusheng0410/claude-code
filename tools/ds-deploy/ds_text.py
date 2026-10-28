#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""DS 部署工具链的共用小工具（文本规范化）。

★ 为什么需要（2026-10-22 代码审查 HIGH-6）
    多个脚本各自实现了一份「读 .sh 文件」，彼此不一致：

        ds-add-dwd-table.py       → .read().replace("\\r\\n", "\\n")   ✅ 正确
        ds-deploy-dwd-workflow.py → open(...).read()                 ❌ 未规范化
        ds-deploy-ods-all.py      → open(...).read()                 ❌ 未规范化
        ds-rebuild-from-inventory.py → open(...).read()              ❌ 未规范化

    后果：Windows 源或 git autocrlf 产生的 CRLF 会被原样内联进 DS 的
    ``taskParams.rawScript``，而 DS worker 跑在 Linux 容器里 —— 行尾残留的
    ``\\r`` 会让 shell 报 ``bad interpreter`` 或命令未找到。
    表面看是「DS 任务 FAILURE」，实为换行符问题，排查方向完全被带偏。

    ⇒ 统一收口到本模块，所有内联 rawScript 的路径都必须走 ``read_script``。
"""
from __future__ import annotations

__all__ = ["read_script", "normalize_newlines"]


def normalize_newlines(text: str) -> str:
    """把 CRLF / 裸 CR 统一成 LF。

    ★ 必须同时处理裸 ``\\r``：某些编辑器在「CR 行尾 + LF 结尾」混用时会产生
    单独的 ``\\r``，它同样会让 Linux shell 解析异常。
    """
    return text.replace("\r\n", "\n").replace("\r", "\n")


def read_script(path, encoding: str = "utf-8") -> str:
    """读脚本文件并**统一行尾为 LF**。

    用于所有要把本地脚本内联进 DS ``rawScript`` 的路径。
    ``errors="replace"`` 保留原语义：非法字节不中断流程（但会被替换）。
    """
    with open(path, encoding=encoding, errors="replace") as f:
        return normalize_newlines(f.read())
