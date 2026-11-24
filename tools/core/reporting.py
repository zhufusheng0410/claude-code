# -*- coding: utf-8 -*-
"""轻量命令行输出辅助。"""


def print_limited(items, limit=8, unit="条", indent="    "):
    """打印前 limit 项；超出时追加「其余 N 项」的计数行。"""
    items = list(items)
    for item in items[:limit]:
        print(f"{indent}{item}")
    if len(items) > limit:
        print(f"{indent}… 其余 {len(items) - limit} {unit}")
