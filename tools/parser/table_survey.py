import re

import pandas as pd
from ..core.ir import TableMeta
from ..config import ODS_TABLE_TMPL, SUFFIX_FULL, SUFFIX_INCR
from tools.utils.excel_reader import read_workbook_sheets
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
COL_ODS_TABLE = 7          # 贴源层表名。★ 2026-10-08 起只取它的 _PFD/_PTD 后缀作为后缀候选，
                           #   基名一律用 col4（见 parse_table_survey 规则②）
COL_TABLE_ROWS = 9
COL_IS_RESERVED = 10
COL_STORAGE_PERIOD = 14
COL_LOAD_STRATEGY = 15
COL_IS_PARTITION = 16
COL_INCR_COND = 17
COL_INCR_COND_FORMAT = 18
COL_TOPIC = 19
# ★ 2026-10-08 新增：调研人。O32 有 561 行、HSFA 有 7 行在此填写的是【真实源物理表名】
#   （如 TUNITSTOCK 行填 THISUNITSTOCK —— 归档/历史表），其余系统该列恒为空。
#   用途见 parse_table_survey 里对 src_table_phys 的赋值。
COL_OWNER = 22


def parse_table_survey(filepath: str, sys_name: str = "O32", table_prefix: str = None) -> list:
    if table_prefix is None:
        table_prefix = ODS_TABLE_TMPL
    sheets = read_workbook_sheets(filepath)
    if sheets is not None:
        sheet_names = list(sheets.keys())
    else:
        with pd.ExcelFile(filepath) as xls:
            sheet_names = list(xls.sheet_names)

    target_sheet = next((n for n in sheet_names if "表级调研" in n), None)
    if not target_sheet:
        raise ValueError(f"未找到包含'表级调研'的sheet: {filepath}")

    logger.debug(f"  读取 sheet: '{target_sheet}' ({filepath})")
    if sheets is not None:
        df = sheets[target_sheet]          # ★ 2026-10-18 calamine 快路径（语义见 excel_reader）
    else:
        df = pd.read_excel(filepath, sheet_name=target_sheet, header=None)

    tables = []
    skipped_sys = 0
    skipped_empty = 0
    auto_generated = 0
    owner_overridden = 0
    conflict_fallback = 0

    # ★★★ 2026-10-08 规则变更（用户拍板）：
    #   ① 【源物理表名 src_table_phys】调研人(COL_OWNER) 非空 → 取调研人；否则取「表英文名」(col4)。
    #      · src_table 恒 = col4（字段级调研的 join key，不能动，否则 find_fields_by_table 查不到字段）
    #      · src_table_phys 只用于 ODS 抽数脚本的 `FROM <src_schema>.<表>`
    #   ② 【贴源层表名 ods_table】不再整串取调研表的「贴源层表名」(col7)，改按规则组装：
    #        ODS_{sys}_{col4}_{后缀}
    #      · 基名 ★ 必须用 col4 而非调研人，否则 O32 的 51 张 / HSFA 的 30 张会被
    #        DWD MAPPING 的源表引用全部对不上（血缘断裂）。
    #        用户明确：「只改 ods 抽数脚本，dwd 层依赖维持不变」。
    #      · 后缀优先取 col7 既有后缀，否则按策略推（详下）。
    #   ③ 【撞名防护】新 ods_table 若与另一条「保留」行重名（HSFA 有 6 组：
    #      TCJHB(调研人=T_H_CJHB) 与独立的 T_H_CJHB 历史表都是「保留」），
    #      则该表回退用 col4 原名，打 WARNING 不阻断（用户拍板）。
    #
    #   先扫一遍收集所有「保留」行的 col4 原名，供撞名检测使用。
    reserved_src_tables = set()
    for _i in range(3, len(df)):
        _row = df.iloc[_i]
        if "不保留" in safe_str(_row, COL_IS_RESERVED):
            continue
        _t = safe_str(_row, COL_SRC_TABLE)
        if _t:
            reserved_src_tables.add(_t)

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

        # 提前计算公共变量，避免在分支内外重复
        strategy_raw = safe_str(row, COL_LOAD_STRATEGY)
        load_strategy = "INCR" if "增量" in strategy_raw else "FULL"
        actual_sys = sys_name or src_sys_from_excel

        # ① 源物理表名：调研人优先
        owner = safe_str(row, COL_OWNER)
        if owner and owner not in ("无", "nan"):
            src_table_phys = owner
            owner_overridden += 1
        else:
            src_table_phys = src_table

        # ② 贴源层表名：以 col4 为基名，后缀按下述优先级决定（不再整串取 col7）
        #    · 后缀优先取 col7 的既有后缀（_PFD/_PTD）：O32 有 10 张表「策略=增量」但
        #      col7 与 DWD MAPPING 都写 _PFD，若按策略硬推成 _PTD 会让 DWD 引用落空
        #      ⇒ 用户 2026-10-08 拍板：col7 后缀优先。
        #    · col7 无后缀（OA/OFFW 只写了 ODS_OA_AGENCY_VIEW 这种裸名）或为空 ⇒ 按策略推。
        if not actual_sys:
            skipped_empty += 1
            continue
        table_name_part = table_prefix.replace("{sys}", actual_sys)
        col7_raw = safe_str(row, COL_ODS_TABLE)
        m7 = re.search(r"_(PFD|PTD)$", col7_raw.upper()) if col7_raw else None
        if m7:
            suffix = m7.group(1)
        else:
            suffix = SUFFIX_INCR if load_strategy == "INCR" else SUFFIX_FULL
        ods_table = f"{table_name_part}_{src_table}_{suffix}"

        # ③ 撞名防护：与另一条「保留」行的原名重合 → 回退原名（即本行 src_table）
        #    回退后 ods_table == 按 col4 命名，与冲突行的原名一致，但内容仍各自成表。
        if src_table_phys != src_table and src_table_phys in reserved_src_tables:
            conflict_fallback += 1
            logger.warning(
                f"  ⚠ 表 '{src_table}' 的调研人 '{src_table_phys}' 与另一条保留表的"
                f"表英文名重合，为避免 ODS 表名撞车，本次【不改写源表名】"
                f"（仍取 col4='{src_table}'）。请人工确认是否需单独建历史表。")
            src_table_phys = src_table

        auto_generated += 1
        logger.debug(f"    自动生成表名: {src_table} → {ods_table}"
                     + (f" (取数源表={src_table_phys})" if src_table_phys != src_table else ""))

        tables.append(TableMeta(
            src_sys=actual_sys,
            src_db_type=safe_str(row, COL_SRC_DB_TYPE),
            src_schema=safe_str(row, COL_SRC_SCHEMA),
            src_table=src_table,
            src_table_phys=src_table_phys,
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
        + (f", 规则命名 {auto_generated}" if auto_generated else "")
        + (f", 取数源表改取调研人 {owner_overridden}" if owner_overridden else "")
        + (f", 撞名回退 {conflict_fallback}" if conflict_fallback else "")
    )
    return tables
