"""Generator 包入口，提供工厂函数"""

from .base import BaseGenerator


def create_generator(layer_name: str) -> BaseGenerator:
    """创建对应层级的生成器实例"""
    from ..config import DWD_SCHEMA, SYS_FIELDS_DWD, DWS_SCHEMA, SYS_FIELDS_DWS

    if layer_name == "DWD":
        return BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, True)
    elif layer_name == "DWS":
        return BaseGenerator(DWS_SCHEMA, SYS_FIELDS_DWS, False)
    else:
        raise ValueError(f"Unknown layer: {layer_name}")