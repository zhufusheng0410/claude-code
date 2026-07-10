#!/usr/bin/env python3
"""数仓代码自动生成工具 — CLI 入口

用法:
  python tools/main.py --layer ALL
  python tools/main.py --layer ODS --sys O32
  python tools/main.py --layer DWD --sys O32 --dwd-mapping-dir /path/to/mapping/
  python tools/main.py --layer DWS --sys O32 --dws-mapping /path/to/mapping.xlsx
"""

import argparse
import logging
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from tools.config import (
    SURVEY_DIR, DWD_MAPPING_BASE, DWS_MAPPING_BASE, OUTPUT_BASE,
    ODS_SCHEMA_TMPL, ODS_TABLE_TMPL, SYSTEM_ALIAS_MAP
)

from tools.parser.table_survey import parse_table_survey
from tools.parser.field_survey import parse_field_survey
from tools.parser.mapping import parse_mapping_dir, parse_dws_mapping
from tools.generator.ods import generate_all_ods_ddl, generate_all_ods_ddl_files, generate_all_ods_etl
from tools.generator.base import create_generator
from tools.generator.lineage import extract_lineage, generate_lineage_excel
from tools.generator.data_dict import (
    extract_ods_dict, extract_layer_dict, generate_data_dict, write_combined_dict,
)
from tools.utils.sys_extractor import extract_sys_name
from tools.utils.validation import validate_output_path
from tools.utils.logging_setup import setup_logging, get_logger
from tools.utils.table_utils import is_table_reserved, write_file
from tools.utils.mapping_finder import find_mapping_dir, find_mapping_file


def normalize_sys_name(raw_name: str) -> str:
    if not raw_name:
        return raw_name
    return SYSTEM_ALIAS_MAP.get(raw_name, raw_name)


def _all_sys_names(sys_key: str) -> list:
    """返回一个系统的所有可能名称，用于查找 MAPPING 文件/目录。

    包括：原始 key、所有映射到同一标准名的别名、标准名本身。
    顺序固定，确保查找结果可预测。
    """
    sys_name = normalize_sys_name(sys_key)
    aliases = [k for k, v in SYSTEM_ALIAS_MAP.items() if v == sys_name]
    return list(dict.fromkeys([sys_key] + aliases + [sys_name]))


def _discover_systems():
    """自动发现所有系统目录，返回 [(sys_key, survey_dir), ...]"""
    systems = []
    if not os.path.isdir(SURVEY_DIR):
        return systems
    for entry in sorted(os.listdir(SURVEY_DIR)):
        full = os.path.join(SURVEY_DIR, entry)
        if not os.path.isdir(full) or entry.startswith('~'):
            continue
        # 从目录名提取系统简称，如 "01-恒生投资交易系统_O32" → "O32"
        parts = entry.split('_', 1)
        if len(parts) == 2:
            sys_key = parts[1]
            systems.append((sys_key, full))
    return systems


def _find_survey_files(survey_dir):
    """在系统调研目录中查找表级和字段级调研文件"""
    return (
        find_mapping_file(survey_dir, ["01-表级调研"], "*.xlsx"),
        find_mapping_file(survey_dir, ["02-字段级调研"], "*.xlsx"),
    )


def _generate_ods_for_sys(sys_key, survey_dir, out, logger):
    """为单个系统生成 ODS 层代码，返回该系统的 ODS 数据字典行列表"""
    ts_path, fs_path = _find_survey_files(survey_dir)
    if not ts_path or not fs_path:
        logger.warning(f"  [{sys_key}] 未找到调研文件，跳过")
        return []

    sys_name = normalize_sys_name(sys_key)

    tables = parse_table_survey(ts_path, sys_name, ODS_TABLE_TMPL)
    fields_by_table = parse_field_survey(fs_path)

    valid_tables = [t for t in tables if t.src_table in fields_by_table and is_table_reserved(t)]
    if not valid_tables:
        logger.info(f"  [{sys_name}] 无有效表，跳过")
        return []

    full_cnt = sum(1 for t in valid_tables if t.load_strategy == "FULL")
    incr_cnt = len(valid_tables) - full_cnt
    logger.info(
        f"  [{sys_name}] 生成 {len(valid_tables)} 张表"
        f" (全量 {full_cnt}, 增量 {incr_cnt})"
        f" — 来自 {os.path.basename(survey_dir)}"
    )
    grp_dir = os.path.join(out, sys_name, "ods")
    os.makedirs(grp_dir, exist_ok=True)

    ddl = generate_all_ods_ddl(valid_tables, fields_by_table, sys_name)
    ddl_path = os.path.join(grp_dir, "01_ddl.sql")
    write_file(ddl_path, ddl)
    logger.info(f"    ODS DDL      → {ddl_path}")

    generate_all_ods_ddl_files(valid_tables, fields_by_table, grp_dir, sys_name)
    logger.info(f"    ODS DDL(按表)→ {os.path.join(grp_dir, 'ddl')}/")

    generate_all_ods_etl(valid_tables, fields_by_table, grp_dir, sys_name)
    logger.info(f"    ODS ETL(按表)→ {os.path.join(grp_dir, 'etl_sh')}/ ({len(valid_tables)} 个.sh)")

    # 数据字典
    dict_rows = extract_ods_dict(valid_tables, fields_by_table, sys_name)
    generate_data_dict(dict_rows, grp_dir, "ODS")
    return dict_rows


def _generate_dwd_dws(layer_name, parser_func, input_path, out, logger):
    """生成 DWD/DWS 层代码"""
    raw_sys = extract_sys_name(layer_name, input_path)
    sys_name = normalize_sys_name(raw_sys)

    input_desc = os.path.basename(os.path.normpath(input_path))
    if sys_name != raw_sys:
        logger.info(f"[{layer_name}] 自动识别系统: {raw_sys} (来自: {input_desc}) → 标准化为: {sys_name}")
    else:
        logger.info(f"[{layer_name}] 自动识别系统: {sys_name} (来自: {input_desc})")

    logger.info(f"[{layer_name}] 解析 MAPPING: {input_path}")
    sheets = parser_func(input_path)
    logger.info(f"  解析到 {len(sheets)} 个 MAPPING sheet")

    layer_dir = os.path.join(out, sys_name, layer_name.lower())
    os.makedirs(layer_dir, exist_ok=True)

    generator = create_generator(layer_name)

    ddl = generator.generate_all_ddl(sheets)
    ddl_path = os.path.join(layer_dir, "01_ddl.sql")
    write_file(ddl_path, ddl)
    logger.info(f"  {layer_name} DDL → {ddl_path}")

    generator.generate_all_ddl_files(sheets, layer_dir, sys_name)
    logger.info(f"  {layer_name} DDL(按表) → {layer_dir}/ddl/")

    etl_files_dir = os.path.join(layer_dir, "02_etl")
    generator.generate_all_etl_files(sheets, etl_files_dir, sys_name)
    logger.info(f"  {layer_name} ETL(按表) → {etl_files_dir}/ ({len(sheets)} 个.sh)")

    # 血缘关系
    lineages = extract_lineage(sheets, layer_name, sys_name)
    generate_lineage_excel(lineages, layer_dir, layer_name)

    # 数据字典
    dict_rows = extract_layer_dict(sheets, layer_name, sys_name)
    generate_data_dict(dict_rows, layer_dir, layer_name)
    return dict_rows


def main():
    setup_logging(level=logging.INFO)
    logger = get_logger(__name__)

    p = argparse.ArgumentParser(description="数仓代码自动生成工具")
    p.add_argument("--layer", choices=["ODS", "DWD", "DWS", "ALL"], default="ALL")
    p.add_argument("--sys", help="指定系统简称，如 O32/HSFA/ZTA。不指定则自动发现所有系统")
    p.add_argument("--output", default=OUTPUT_BASE, help="脚本输出目录")
    p.add_argument("--verbose", "-v", action="store_true", help="输出 DEBUG 级别详细日志")

    args = p.parse_args()
    layer = args.layer

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    out = validate_output_path(args.output, OUTPUT_BASE)
    import time
    t_start = time.time()

    systems = _discover_systems()
    if not systems:
        logger.error(f"未在 {SURVEY_DIR} 中发现任何系统目录")
        sys.exit(1)

    logger.info(f"发现 {len(systems)} 个系统: {', '.join(s[0] for s in systems)}")
    logger.info(f"输出目录: {out}")
    logger.info(f"生成层级: {layer}")

    # 如果指定了 --sys，只处理匹配的系统
    if args.sys:
        target = args.sys.upper()
        systems = [(k, d) for k, d in systems if k.upper() == target]
        if not systems:
            logger.error(f"未找到系统: {args.sys}")
            sys.exit(1)

    # 汇总各层数据字典行，跨系统跨层级
    dict_by_layer = {"ODS": [], "DWD": [], "DWS": []}

    # --- ODS ---
    if layer in ("ODS", "ALL"):
        logger.info("─── ODS 层 ──────────────────────────────────")
        for sys_key, survey_dir in systems:
            dict_by_layer["ODS"].extend(
                _generate_ods_for_sys(sys_key, survey_dir, out, logger)
            )

    # 预计算每个系统的标准名和全部别名，供 DWD/DWS 两轮复用
    sys_info = {
        sys_key: (normalize_sys_name(sys_key), _all_sys_names(sys_key))
        for sys_key, _ in systems
    }

    # --- DWD ---
    if layer in ("DWD", "ALL"):
        logger.info("─── DWD 层 ──────────────────────────────────")
        for sys_key, _ in systems:
            sys_name, names = sys_info[sys_key]
            dwd_dir = find_mapping_dir(DWD_MAPPING_BASE, names)
            if dwd_dir:
                dict_by_layer["DWD"].extend(
                    _generate_dwd_dws("DWD", parse_mapping_dir, dwd_dir, out, logger)
                )
            else:
                logger.info(f"  [{sys_name}] 无 DWD MAPPING，跳过")

    # --- DWS ---
    if layer in ("DWS", "ALL"):
        logger.info("─── DWS 层 ──────────────────────────────────")
        for sys_key, _ in systems:
            sys_name, names = sys_info[sys_key]
            dws_file = find_mapping_file(DWS_MAPPING_BASE, names, "_DWS_*.xlsx")
            if dws_file:
                dict_by_layer["DWS"].extend(
                    _generate_dwd_dws("DWS", parse_dws_mapping, dws_file, out, logger)
                )
            else:
                logger.info(f"  [{sys_name}] 无 DWS MAPPING，跳过")

    # 汇总数据字典（跨系统跨层级）
    write_combined_dict(dict_by_layer, out)

    elapsed = time.time() - t_start
    logger.info(f"─────────────────────────────────────────────")
    logger.info(f"完成  耗时 {elapsed:.1f}s  输出 → {out}")


if __name__ == "__main__":
    main()
