"""表相关工具函数

提供表名处理和字段查找的统一逻辑，消除代码重复。
"""

from typing import Dict, List, Any


def extract_physical_name(full_name: str) -> str:
    """从完整的表名（可能带 schema）提取物理表名"""
    if '.' in full_name:
        return full_name.rsplit('.', 1)[-1]
    return full_name


def find_fields_by_table(src_table: str, fields_by_table: Dict[str, List[Any]]) -> List[Any]:
    """在字段字典中查找表，尝试多种大小写"""
    for key in (src_table, src_table.upper(), src_table.lower()):
        if key in fields_by_table:
            return fields_by_table[key]
    return []


def filter_ods_fields(tbl_fields: List[Any]) -> List[Any]:
    """过滤 ODS 字段：排除明确标记为非 ODS 的字段，未填写视为保留"""
    return [f for f in tbl_fields if f.is_ods not in ('否', 'N', 'n')]


def is_table_reserved(table) -> bool:
    """检查表是否标记为保留（需要生成）"""
    return table.is_reserved in ('是', '保留', 'Y', 'y')


def iter_ods_tables(tables: list, fields_by_table: dict):
    """迭代有效的 ODS 表，跳过未保留、无字段的表，生成 (table, ods_fields) 对。

    消除 generate_all_ods_ddl / _files / _etl 和 generate_all_datax 中重复的过滤模式。
    """
    for table in tables:
        if not is_table_reserved(table):
            continue
        tbl_fields = find_fields_by_table(table.src_table, fields_by_table)
        if not tbl_fields:
            continue
        yield table, filter_ods_fields(tbl_fields)


def write_file(filepath: str, content: str) -> None:
    """统一文件写入，写失败时抛出 OSError"""
    with open(filepath, 'w', encoding='utf-8') as fh:
        fh.write(content)
