"""日志配置模块

提供统一的日志配置，支持：
- 控制台彩色输出
- 不同日志级别
- 结构化日志格式
"""

import logging
import sys


def setup_logging(level=logging.INFO, fmt=None):
    """
    配置全局日志系统

    Args:
        level: 日志级别，默认 INFO
        fmt: 自定义格式字符串，如未提供则使用默认格式
    """
    if fmt is None:
        fmt = "%(asctime)s [%(levelname)-8s] %(name)s: %(message)s"

    # 配置根日志器
    logging.basicConfig(
        level=level,
        format=fmt,
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=[logging.StreamHandler(sys.stdout)]
    )

    # 设置第三方库的日志级别为 WARNING，减少噪音
    logging.getLogger("pandas").setLevel(logging.WARNING)
    logging.getLogger("openpyxl").setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    """
    获取指定名称的日志器

    Args:
        name: 日志器名称，通常使用 __name__

    Returns:
        Logger 实例
    """
    return logging.getLogger(name)
