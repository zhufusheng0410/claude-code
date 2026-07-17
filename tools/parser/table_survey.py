import pandas as pd
from ..core.ir import TableMeta
from ..config import ODS_TABLE_TMPL, SUFFIX_FULL, SUFFIX_INCR
from tools.utils.pandas_helpers import safe_str
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)

# 表级调研 Excel 列索引（pd.read_excel(..., header=None)，数据行从 row 3 起）。
# 调研文档列序若调整，仅需改此处的命名常量，避免散落的魔法数字静默错列。
COL_SRC_DB_TYPE = 0
COL_SRC_SYS = 2
COL_SRC_TABLE = 4
COL_SRC_TABLE_CN = 5
COL_SRC_SCHEMA = 6
COL_ODS_TABLE = 7
COL_TABLE_ROWS = 9
COL_IS_RESERVED = 10
COL_STORAGE_PERIOD = 14
COL_LOAD_STRATEGY = 15
COL_IS_PARTITION = 16
COL_INCR_COND = 17
COL_INCR_COND_FORMAT = 18
COL_TOPIC = 19


def parse_table_survey(filepath: str, sys_name: str = "O32", table_prefix: str = None) -> list:
    if table_prefix is None:
        table_prefix = ODS_TABLE_TMPL
    xls = pd.ExcelFile(filepath)
    target_sheet = None
    for name in xls.sheet_names:
        if "表级调研" in name:
            target_sheet = name
            break
    if not target_sheet:
        raise ValueError(f"未找到包含'表级调研'的sheet: {filepath}")

    logger.debug(f"  读取 sheet: '{target_sheet}' ({filepath})")
    df = pd.read_excel(filepath, sheet_name=target_sheet, header=None)

    tables = []
    skipped_sys = 0
    skipped_empty = 0
    skipped_no_ods = 0
    auto_generated = 0

    for i in range(3, len(df)):
        row = df.iloc[i]
        # 过滤：只保留指定系统的表（未指定系统则不过滤）
        src_sys_from_excel = safe_str(row, COL_SRC_SYS)
        if sys_name and src_sys_from_excel and src_sys_from_excel != sys_name:
            skipped_sys += 1
            continue

        src_table = safe_str(row, COL_SRC_TABLE)
        if not src_table:
            skipped_empty += 1
            continue  # 源表名为空，跳过

        # 提前计算公共变量，避免在 if not ods_table 分支内外重复
        strategy_raw = safe_str(row, COL_LOAD_STRATEGY)
        load_strategy = "INCR" if "增量" in strategy_raw else "FULL"
        actual_sys = sys_name or src_sys_from_excel

        ods_table = safe_str(row, COL_ODS_TABLE)

        # 修复：如果ODS表名为空，自动生成
        if not ods_table:
            if not actual_sys:
                skipped_empty += 1
                continue
            suffix = SUFFIX_INCR if load_strategy == "INCR" else SUFFIX_FULL
            table_name_part = table_prefix.replace("{sys}", actual_sys)
            ods_table = f"{table_name_part}_{src_table}_{suffix}"
            auto_generated += 1
            logger.debug(f"    自动生成表名: {src_table} → {ods_table}")

        if not ods_table.startswith("ODS_"):
            skipped_no_ods += 1
            continue

        tables.append(TableMeta(
            src_sys=actual_sys,
            src_db_type=safe_str(row, COL_SRC_DB_TYPE),
            src_schema=safe_str(row, COL_SRC_SCHEMA),
            src_table=src_table,
            src_table_cn=safe_str(row, COL_SRC_TABLE_CN),
            ods_table=ods_table,
            load_strategy=load_strategy,
            incr_cond=safe_str(row, COL_INCR_COND),
            incr_cond_format=safe_str(row, COL_INCR_COND_FORMAT),
            is_partition=safe_str(row, COL_IS_PARTITION),
            storage_period=safe_str(row, COL_STORAGE_PERIOD),
            topic=safe_str(row, COL_TOPIC),
            table_rows=safe_str(row, COL_TABLE_ROWS),
            is_reserved=safe_str(row, COL_IS_RESERVED),
        ))

    logger.debug(
        f"  表级调研解析完成: 共 {len(tables)} 张表"
        + (f", 跳过系统不符 {skipped_sys}" if skipped_sys else "")
        + (f", 跳过空行 {skipped_empty}" if skipped_empty else "")
        + (f", 跳过非ODS {skipped_no_ods}" if skipped_no_ods else "")
        + (f", 自动生成表名 {auto_generated}" if auto_generated else "")
    )
    return tables
