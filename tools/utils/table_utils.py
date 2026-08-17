"""表相关工具函数

提供表名处理和字段查找的统一逻辑，消除代码重复。
"""

from typing import Dict, List, Any, Tuple, Callable
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)


def parse_bool(value, default: bool = False) -> bool:
    """统一布尔判断：将中文/英文/数字标志解析为 bool。

    消除 is_table_reserved / filter_ods_fields / _yn 中重复的布尔判断逻辑。

    Args:
        value: 原始值（可为 str/None/空）。
        default: 空值或未知值时的默认返回值。

    Returns:
        True 表示"是/保留/有效"，False 表示"否/排除/无效"。
    """
    if not value:
        return default
    s = str(value).strip()
    if s in ("是", "保留", "Y", "y", "1", "是主键", "主键"):
        return True
    if s in ("否", "N", "n", "0"):
        return False
    return default


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
    return [f for f in tbl_fields if parse_bool(f.is_ods, default=True)]


def is_table_reserved(table) -> bool:
    """检查表是否标记为保留（需要生成）"""
    return parse_bool(table.is_reserved)


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


def filter_valid_ods_tables(tables: list, fields_by_table: dict) -> list:
    """筛选需要生成的 ODS 表（保留 + 有字段），供主流程预统计/预过滤。

    直接复用 iter_ods_tables 的同一过滤逻辑，避免预过滤时因表名大小写
    与字段级调研不一致而静默漏表。
    """
    return [t for t, _ in iter_ods_tables(tables, fields_by_table)]


def write_file(filepath: str, content: str) -> None:
    """统一文件写入，写失败时抛出 OSError"""
    with open(filepath, 'w', encoding='utf-8') as fh:
        fh.write(content)


def write_files_per_table(
    items: List[Tuple[str, Any]],
    output_dir: str,
    ext: str,
    content_fn: Callable[[Any], str],
    *,
    sub_dir: str = ""
) -> int:
    """按表生成独立文件的通用模式。

    消除 generate_all_ods_ddl_files / generate_all_ddl_files / generate_all_etl_files /
    generate_all_ods_etl 中重复的 "建目录 → 遍历 → 生成内容 → write_file_safe" 模式。

    Args:
        items: [(key, payload), ...]，key 用于文件名，payload 传给 content_fn。
        output_dir: 输出根目录。
        ext: 文件扩展名（如 ".sql"、".sh"）。
        content_fn: callable(payload) -> str，根据 payload 生成文件内容。
        sub_dir: 可选子目录名（如 "ddl"），为空则直接写到 output_dir 下。

    Returns:
        成功写入的文件数。
    """
    target_dir = os.path.join(output_dir, sub_dir) if sub_dir else output_dir
    os.makedirs(target_dir, exist_ok=True)
    written = 0
    for key, payload in items:
        if not key:
            continue
        filepath = os.path.join(target_dir, key + ext)
        content = content_fn(payload)
        if write_file_safe(filepath, content, key, ext.lstrip('.').upper()):
            written += 1
    return written


def write_file_safe(filepath: str, content: str, table_name: str, file_type: str) -> bool:
    """安全写入文件，处理 ValueError（验证失败）和 IOError（IO错误）。

    ValueError 时记录错误并返回 False（跳过此表），IOError 时记录并抛出。
    """
    try:
        write_file(filepath, content)
    except ValueError as e:
        logger.error(f"  ERROR: Skipping table '{table_name}': {e}")
        return False
    except IOError as e:
        logger.error(f"  ERROR: Failed to write {file_type} file {filepath}: {e}")
        raise
    return True
