"""数据字典生成器

汇总 ODS/DWD/DWS 三层的表级+字段级元数据，输出统一数据字典 Excel。

- ODS 字典来源：TableMeta + FieldMeta（字段级调研）
- DWD/DWS 字典来源：MappingSheet + MappingRule（MAPPING 文档）

设计参照 lineage.py：extract（纯 dict 提取，免变异）与 generate（Excel 输出）分离。
"""

import os

import pandas as pd

from tools.utils.table_utils import iter_ods_tables, extract_physical_name
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)

# 汇总总字典文件名
COMBINED_DICT_NAME = "数据字典_汇总.xlsx"


def _yn(value: str) -> str:
    """将主键/入ODS 等标志规整为 是/否"""
    return "是" if str(value).strip() in ("是", "Y", "y", "1", "是主键") else "否"


def extract_ods_dict(tables: list, fields_by_table: dict, sys_name: str) -> list:
    """提取 ODS 层数据字典，每个字段一条记录。

    Args:
        tables: TableMeta 列表
        fields_by_table: {源表名: [FieldMeta]}
        sys_name: 系统简称

    Returns:
        扁平 dict 列表
    """
    rows = []
    for table, ods_fields in iter_ods_tables(tables, fields_by_table):
        for f in ods_fields:
            rows.append({
                "系统": sys_name,
                "层级": "ODS",
                "表英文名": table.ods_table,
                "表中文名": table.src_table_cn or "",
                "加载策略": table.load_strategy or "",
                "字段序号": f.ordinal,
                "字段英文名": f.src_name,
                "字段中文名": f.src_name_cn or "",
                "Oracle类型": f.src_type or "",
                "Hive类型": f.hive_type or "",
                "是否主键": _yn(f.is_pk),
                "是否入ODS": _yn(f.is_ods) if f.is_ods else "是",
                "备注": f.src_name_cn_note or "",
            })
    return rows


def extract_layer_dict(sheets: list, layer: str, sys_name: str) -> list:
    """提取 DWD/DWS 层数据字典，每个字段映射一条记录。

    Args:
        sheets: MappingSheet 列表
        layer: 层级名称 (DWD / DWS)
        sys_name: 系统简称

    Returns:
        扁平 dict 列表
    """
    rows = []
    for sheet in sheets:
        if not sheet.tgt_table or not sheet.mappings:
            continue
        tbl = extract_physical_name(sheet.tgt_table)
        seen = set()
        for mr in sheet.mappings:
            if not mr.tgt_name or mr.tgt_name in seen:
                continue
            seen.add(mr.tgt_name)
            rows.append({
                "系统": sys_name,
                "层级": layer,
                "表英文名": tbl,
                "表中文名": sheet.tgt_table_cn or "",
                "加载策略": sheet.load_type or "",
                "字段序号": mr.tgt_ordinal,
                "字段英文名": mr.tgt_name,
                "字段中文名": mr.tgt_name_cn or "",
                "字段类型": mr.tgt_type or "STRING",
                "是否主键": _yn(mr.is_pk),
                "组别": mr.group_no or "",
                "映射规则": mr.src_field_alias or "",
                "备注": mr.note or "",
            })
    return rows


def generate_data_dict(rows: list, output_dir: str, layer: str) -> str:
    """输出单层数据字典 Excel。

    Args:
        rows: extract_* 返回的扁平 dict 列表
        output_dir: 层级输出目录
        layer: 层级名称，用于文件名

    Returns:
        输出目录路径
    """
    dict_dir = os.path.join(output_dir, "data_dict")
    os.makedirs(dict_dir, exist_ok=True)

    if not rows:
        logger.warning(f"  数据字典: {layer} 无数据可输出")
        return dict_dir

    excel_path = os.path.join(dict_dir, f"{layer}_dict.xlsx")
    with pd.ExcelWriter(excel_path, engine="openpyxl") as writer:
        pd.DataFrame(rows).to_excel(writer, index=False, sheet_name="数据字典")

    tbl_cnt = len({(r["系统"], r["表英文名"]) for r in rows})
    logger.info(f"  数据字典 → {excel_path} ({len(rows)} 个字段, {tbl_cnt} 张表)")
    return dict_dir


def write_combined_dict(rows_by_layer: dict, output_dir: str) -> str:
    """输出跨系统跨层级的汇总数据字典 Excel。

    Args:
        rows_by_layer: {层级: [字典行]}，如 {"ODS": [...], "DWD": [...], "DWS": [...]}
        output_dir: 输出根目录（scripts/）

    Returns:
        汇总文件路径，无数据时返回空串
    """
    all_rows = [r for rows in rows_by_layer.values() for r in rows]
    if not all_rows:
        logger.warning("  数据字典汇总: 无数据可输出")
        return ""

    os.makedirs(output_dir, exist_ok=True)
    excel_path = os.path.join(output_dir, COMBINED_DICT_NAME)

    with pd.ExcelWriter(excel_path, engine="openpyxl") as writer:
        # 各层字典分 sheet
        for layer in ("ODS", "DWD", "DWS"):
            layer_rows = rows_by_layer.get(layer, [])
            if layer_rows:
                pd.DataFrame(layer_rows).to_excel(
                    writer, index=False, sheet_name=f"{layer}字典"
                )

        # 表清单汇总 sheet（按系统+层级+表去重）
        table_index = {}
        for r in all_rows:
            key = (r["系统"], r["层级"], r["表英文名"])
            if key not in table_index:
                table_index[key] = {
                    "系统": r["系统"],
                    "层级": r["层级"],
                    "表英文名": r["表英文名"],
                    "表中文名": r["表中文名"],
                    "字段数": 0,
                }
            table_index[key]["字段数"] += 1
        pd.DataFrame(list(table_index.values())).to_excel(
            writer, index=False, sheet_name="表清单汇总"
        )

    logger.info(
        f"  数据字典汇总 → {excel_path} "
        f"({len(all_rows)} 个字段, {len(table_index)} 张表)"
    )
    return excel_path
