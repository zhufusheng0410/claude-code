"""映射文件查找工具"""

import fnmatch
import os
from typing import Optional, Sequence


def find_mapping_file(base_dir: str, names: Sequence[str], suffix: str) -> Optional[str]:
    """查找映射文件，按优先顺序尝试多个系统名称前缀。

    单次 scandir 扫描目录，用 fnmatch 逐名匹配，避免每个名称各发一次 glob 请求。

    Args:
        base_dir: 基础目录
        names: 系统名候选列表，按顺序尝试 (如 ['ZTA', 'TA', 'HSZTA'])
        suffix: 文件名后缀 glob 模式 (如 '_DWS_*.xlsx')

    Returns:
        找到的第一个匹配文件路径，未找到返回 None
    """
    try:
        entries = [(e.name, e.path) for e in os.scandir(base_dir) if e.is_file()]
    except FileNotFoundError:
        return None
    for name in names:
        pattern = f"{name}{suffix}"
        match = next((path for fname, path in entries if fnmatch.fnmatch(fname, pattern)), None)
        if match:
            return match
    return None


def find_mapping_dir(base_dir: str, names: Sequence[str]) -> Optional[str]:
    """查找映射目录，按优先顺序尝试多个系统名称（包含匹配）。

    DWD 目录结构为 01-ZTA、02-O32 等编号子目录，需用包含匹配。
    单次 scandir 扫描目录，避免每个名称各发一次 glob 请求。

    Args:
        base_dir: 基础目录
        names: 系统名候选列表，按顺序尝试 (如 ['ZTA', 'TA', 'HSZTA'])

    Returns:
        找到的第一个匹配目录路径，未找到返回 None
    """
    try:
        entries = [(e.name, e.path) for e in os.scandir(base_dir) if e.is_dir()]
    except FileNotFoundError:
        return None
    for name in names:
        match = next((path for dname, path in entries if name in dname), None)
        if match:
            return match
    return None
