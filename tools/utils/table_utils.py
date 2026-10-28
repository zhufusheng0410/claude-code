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
    """过滤 ODS 字段：排除明确标记为非 ODS 的字段，未填写视为保留。

    ★ 2026-10-08 新增：按【源列名】去重（大小写不敏感），保留首次出现，重复项打 WARNING。
      起因：ODS 层此前**完全没有去重**，而 DWD 层（`generator/base.py`）一直按 tgt_name 去重
      ⇒ 两侧防护不一致。上游调研表里同一列被写了两行时，ODS 会生成
        · Oracle querySql `SELECT A, B, A`（DataX writer 的 column 按位置对应 ⇒ 列错位）
        · Hive DDL `A STRING, A STRING` ⇒ `Error 10015: Column repeated in table`
      这类问题生成期不报、要等 DataX 或建表时才炸，属于典型的"上游数据脏 → 产物坏"。
      ★ 只告警不阻断：保留首次出现那条、让生成继续（上游漏填/误填是常态，
        与 incr_cond 校验的策略保持一致）。
      ★ 放在这里是因为 DDL / ETL / DataX 三条链路都经过本函数，改一处全生效。
    """
    kept = [f for f in tbl_fields if parse_bool(f.is_ods, default=True)]

    seen = set()
    out = []
    for f in kept:
        name = str(getattr(f, "src_name", "") or "").strip()
        if not name:
            # 空列名交给后续校验处理，不在这里静默丢弃
            out.append(f)
            continue
        key = name.upper()
        if key in seen:
            logger.warning(
                f"  ⚠ 字段 '{name}' 在同一张表中重复出现，已去重（保留首次出现）。"
                f"请检查上游调研表是否误填了重复行。")
            continue
        seen.add(key)
        out.append(f)
    return out


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


def write_file(filepath: str, content: str, newline: str = '\n') -> None:
    """统一文件写入，写失败时抛出 OSError。

    ★ 2026-09-28 修 bug：必须显式 `newline='\\n'`。
      若不指定，Windows 上 Python 的文本模式默认 `newline=None`，会把内容里的
      `\\n` 一律翻译成 `\\r\\n`（CRLF）。生成的 .sh 被部署到 Linux 容器后：
        1. shebang 变成 `#!/bin/sh\\r` → 解释器路径带 CR，内核找不到解释器；
        2. 每行行尾带 CR → `source /home/dolphinscheduler/hadoop_env\\r`
           → 报 `No such file or directory`（实际文件是存在的！）；
        3. `bash -c` 报 `syntax error near unexpected token $'\\r'`。
      现象极具误导性：明明文件在、路径对，却报"文件不存在"。
      显式 newline='\\n' 后，无论宿主是 Windows 还是 Linux，产出恒为 LF。
      ★ 2026-10-26：新增 `newline` 参数，默认 LF；Windows 目标文件（.bat/.cmd）可传 `''` 保持原生。
    """
    with open(filepath, 'w', encoding='utf-8', newline=newline) as fh:
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
