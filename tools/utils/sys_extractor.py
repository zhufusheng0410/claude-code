"""系统简称提取和标准化工具"""

from typing import Optional
import os


def extract_sys_name(layer: str, path: str) -> Optional[str]:
    """
    从路径中提取系统简称

    DWD: 从目录名提取，如 "01-ZTA" -> "ZTA"
    DWS: 从文件名提取，如 "O32_DWS_..." -> "O32"

    Args:
        layer: 层级名称 (ODS/DWD/DWS)
        path: 输入路径 (文件或目录)

    Returns:
        提取的系统简称，提取失败返回 None
    """
    if layer == "DWD":
        parent_dir = os.path.basename(os.path.normpath(path))
        parts = parent_dir.split('-')
        return parts[-1] if len(parts) > 1 else parent_dir

    elif layer == "DWS":
        filename = os.path.basename(path)
        parts = filename.split('_')
        if len(parts) >= 2:
            return parts[0]
        return os.path.splitext(filename)[0]

    elif layer == "ODS":
        return None

    return None
