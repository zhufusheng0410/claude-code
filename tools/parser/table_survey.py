import pandas as pd
from ..core.ir import TableMeta
from ..config import ODS_TABLE_TMPL, SUFFIX_FULL, SUFFIX_INCR
from tools.utils.pandas_helpers import safe_str
from tools.utils.table_utils import find_fields_by_table
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)


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
        src_sys_from_excel = safe_str(row, 2)
        if sys_name and src_sys_from_excel and src_sys_from_excel != sys_name:
            skipped_sys += 1
            continue

        src_table = safe_str(row, 4)
        if not src_table:
            skipped_empty += 1
            continue  # 源表名为空，跳过

        ods_table = safe_str(row, 7)

        # 修复：如果ODS表名为空，自动生成
        if not ods_table:
            strategy_raw = safe_str(row, 15)
            load_strategy = "INCR" if "增量" in strategy_raw else "FULL"
            suffix = SUFFIX_INCR if load_strategy == "INCR" else SUFFIX_FULL
            # 确定实际系统名：优先使用传入的 sys_name，其次使用 Excel 中的值
            actual_sys = sys_name or src_sys_from_excel
            if not actual_sys:
                # 系统名为空，无法生成表名，跳过
                skipped_empty += 1
                continue
            table_name_part = table_prefix.replace("{sys}", actual_sys)
            ods_table = f"{table_name_part}_{src_table}_{suffix}"
            auto_generated += 1
            logger.debug(f"    自动生成表名: {src_table} → {ods_table}")

        if not ods_table.startswith("ODS_"):
            skipped_no_ods += 1
            continue

        strategy_raw = safe_str(row, 15)
        load_strategy = "INCR" if "增量" in strategy_raw else "FULL"

        # 确定实际系统名：优先使用传入的 sys_name，其次使用 Excel 中的值
        actual_sys = sys_name or src_sys_from_excel
        if not actual_sys:
            # 如果还是没有系统名，跳过这条记录（不应该发生）
            skipped_empty += 1
            continue
        tables.append(TableMeta(
            src_sys=actual_sys,
            src_db_type=safe_str(row, 0),
            src_schema=safe_str(row, 6),
            src_table=src_table,
            src_table_cn=safe_str(row, 5),
            ods_table=ods_table,
            load_strategy=load_strategy,
            incr_cond=safe_str(row, 17),
            incr_cond_format=safe_str(row, 18),
            is_partition=safe_str(row, 16),
            storage_period=safe_str(row, 14),
            topic=safe_str(row, 19),
            table_rows=safe_str(row, 9),
            is_reserved=safe_str(row, 10),  # 列10: 是否保留
        ))

    logger.debug(
        f"  表级调研解析完成: 共 {len(tables)} 张表"
        + (f", 跳过系统不符 {skipped_sys}" if skipped_sys else "")
        + (f", 跳过空行 {skipped_empty}" if skipped_empty else "")
        + (f", 跳过非ODS {skipped_no_ods}" if skipped_no_ods else "")
        + (f", 自动生成表名 {auto_generated}" if auto_generated else "")
    )
    return tables
