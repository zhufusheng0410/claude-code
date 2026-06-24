"""系统简称提取和标准化工具"""

from typing import Optional, Dict
import os


# DWD 目录编号到系统简称的默认映射（与 CLAUDE.md 保持一致）
DEFAULT_DWD_DIR_SYSTEM_MAP = {
    "01-ZTA": "ZTA",
    "02-O32": "O32",
    "03-HSFA": "HSFA",
}


def extract_sys_name(layer: str, path: str, config_map: Dict[str, str] = None) -> Optional[str]:
    """
    从路径中提取系统简称

    Args:
        layer: 层级名称 (ODS/DWD/DWS)
        path: 输入路径 (文件或目录)
        config_map: 映射配置（如 DWD 目录编号映射），如未提供则使用默认映射

    Returns:
        提取的系统简称，提取失败返回 None
    """
    if layer == "DWD":
        # DWD: 从目录名提取，如 "01-ZTA" -> "ZTA"
        parent_dir = os.path.basename(os.path.normpath(path))
        # 使用传入的配置映射，否则使用默认映射
        effective_map = config_map or DEFAULT_DWD_DIR_SYSTEM_MAP
        if effective_map and parent_dir in effective_map:
            return effective_map[parent_dir]
        parts = parent_dir.split('-')
        return parts[-1] if len(parts) > 1 else parent_dir

    elif layer == "DWS":
        # DWS: 从文件名提取，如 "O32_DWS_..." -> "O32"
        filename = os.path.basename(path)
        parts = filename.split('_')
        if len(parts) >= 2:
            return parts[0]
        return os.path.splitext(filename)[0]

    elif layer == "ODS":
        # ODS: 无法从路径单独提取，需要解析 Excel，返回 None
        return None

    return None
