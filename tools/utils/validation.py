"""验证工具函数

提供输入验证功能，防止常见安全漏洞：
- SQL 注入：验证数据库标识符（表名、字段名）
- 路径遍历：限制输出目录在允许范围内
"""

import re
import os


def validate_db_identifier(name: str, identifier_type: str = "identifier") -> None:
    """
    验证数据库对象名（表名、字段名）安全性

    规则：只允许字母、数字、下划线（不强制要求以字母开头，兼容历史数据）
    这样可以防止 SQL 注入（排除危险字符如单引号、分号、空格等）

    Args:
        name: 要验证的名称
        identifier_type: 标识符类型（用于错误消息）

    Raises:
        ValueError: 如果名称包含非法字符
    """
    if not name:
        raise ValueError(f"{identifier_type} cannot be empty")

    # 只允许字母、数字、下划线（可以数字开头）
    if not re.match(r'^[A-Za-z0-9_]+$', name):
        raise ValueError(
            f"Invalid {identifier_type} '{name}': must contain only alphanumeric and underscore"
        )


def validate_output_path(user_path: str, base_dir: str) -> str:
    """
    验证输出路径在基础目录内，防止路径遍历攻击

    Args:
        user_path: 用户提供的路径
        base_dir: 允许的基础目录

    Returns:
        规范化后的绝对路径

    Raises:
        ValueError: 如果路径超出允许范围
    """
    # 获取绝对路径并解析符号链接
    real_base = os.path.realpath(base_dir)
    real_path = os.path.realpath(user_path)

    # 确保路径在基础目录内
    if not real_path.startswith(real_base + os.sep) and real_path != real_base:
        raise ValueError(
            f"Output path '{user_path}' is outside allowed directory '{base_dir}'"
        )

    return real_path
