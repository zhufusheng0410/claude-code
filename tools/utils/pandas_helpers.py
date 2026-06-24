"""Pandas 相关工具函数

提供安全的 DataFrame 访问模式，处理空值和类型转换。
这是核心数据访问层，所有 parser 都应使用这些函数。
"""

import pandas as pd
from typing import Any, Union, Optional


def safe_str(row: pd.Series, col: Any) -> str:
    """安全获取单元格字符串值，处理 NaN"""
    if col not in row.index:
        return ""
    v = row[col]
    return "" if pd.isna(v) else str(v).strip()


def safe_float(row: pd.Series, col: Any, default: float = 0.0) -> float:
    """安全转换为浮点数，处理 NaN 和转换错误"""
    if col not in row.index:
        return default
    v = row[col]
    try:
        return float(v)
    except (ValueError, TypeError):
        return default


def safe_float_str(val: Union[str, float, int, None], default: float = 0.0) -> float:
    """将任意值安全转换为浮点数，处理空值和转换错误"""
    if val is None or (isinstance(val, str) and not val.strip()):
        return default
    try:
        return float(val)
    except (ValueError, TypeError):
        return default
