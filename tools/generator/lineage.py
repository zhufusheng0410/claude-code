"""血缘关系生成器

从 MappingSheet 提取表级和字段级血缘信息，输出 Excel 文件。
血缘关系覆盖 ODS→DWD→DWS 全链路。
"""

import os

import pandas as pd

from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)


def extract_lineage(sheets: list, layer: str, sys_name: str) -> list:
    """从 MAPPING sheets 提取表级+字段级血缘。

    Args:
        sheets: MappingSheet 列表（每个 sheet 对应一张目标表）
        layer: 层级名称 (DWD / DWS)
        sys_name: 系统简称

    Returns:
        [{表级+字段级血缘字段}] 列表，每个 MappingSheet 一条记录
    """
    lineages = []
    for sheet in sheets:
        if not sheet.tgt_table or not sheet.mappings:
            continue

        # 收集上游表（去重）
        upstream_tables = sorted({
            mr.src_table_name
            for mr in sheet.mappings
            if mr.src_table_name
        })

        mappings = []
        for mr in sheet.mappings:
            if not mr.tgt_name or not mr.src_field_alias:
                continue
            mappings.append({
                "tgt_field": mr.tgt_name,
                "tgt_field_cn": mr.tgt_name_cn,
                "src_table": mr.src_table_name or "",
                "src_table_cn": mr.src_table_cn or "",
                "src_field": mr.src_field_name or "",
                "src_field_cn": mr.src_field_cn or "",
                "src_field_alias": mr.src_field_alias,
                "join_type": mr.join_type,
                "filter_cond": mr.filter_cond,
                "note": mr.note,
            })

        lineages.append({
            "tgt_table": sheet.tgt_table,
            "tgt_table_cn": sheet.tgt_table_cn,
            "layer": layer,
            "sys_name": sys_name,
            "upstream_tables": upstream_tables,
            "mappings": mappings,
        })

    logger.info(f"  血缘关系: {len(lineages)} 张表, {sum(len(l['mappings']) for l in lineages)} 个字段映射")
    return lineages


def generate_lineage_excel(lineages: list, output_dir: str, layer: str) -> str:
    """输出表级+字段级血缘到 Excel。

    字段级血缘 sheet 包含：目标表(英文名/中文名)、目标字段(英文名/中文名)、
    来源表(英文名/中文名)、来源字段(英文名/中文名)、映射规则/表达式、JOIN方式、
    过滤条件、备注。
    表级血缘 sheet 包含：目标表(英文名/中文名)、层级、系统、上游表列表。
    """
    lineage_dir = os.path.join(output_dir, "lineage")
    if not os.path.exists(lineage_dir):
        os.makedirs(lineage_dir)

    # 收集字段级记录
    rows = []
    for lt in lineages:
        tgt_table = lt["tgt_table"]
        tgt_table_cn = lt["tgt_table_cn"]
        for fld in lt["mappings"]:
            rows.append({
                "目标表英文名": tgt_table,
                "目标表中文名": tgt_table_cn,
                "目标字段英文名": fld["tgt_field"],
                "目标字段中文名": fld["tgt_field_cn"],
                "来源表英文名": fld["src_table"],
                "来源表中文名": fld["src_table_cn"],
                "来源字段英文名": fld["src_field"],
                "来源字段中文名": fld["src_field_cn"],
                "映射规则/表达式": fld["src_field_alias"],
                "JOIN方式": fld["join_type"] or "",
                "过滤条件": fld["filter_cond"] or "",
                "备注": fld["note"] or "",
            })

    if not rows:
        logger.warning(f"  血缘关系: 无数据可输出")
        return lineage_dir

    excel_path = os.path.join(lineage_dir, f"{layer}_lineage.xlsx")
    with pd.ExcelWriter(excel_path, engine="openpyxl") as writer:
        pd.DataFrame(rows).to_excel(writer, index=False, sheet_name="字段级血缘")

        table_rows = [
            {
                "目标表英文名": lt["tgt_table"],
                "目标表中文名": lt["tgt_table_cn"],
                "层级": lt["layer"],
                "系统": lt["sys_name"],
                "上游表列表": "; ".join(lt["upstream_tables"]),
            }
            for lt in lineages
        ]
        pd.DataFrame(table_rows).to_excel(writer, index=False, sheet_name="表级血缘")

    logger.info(f"  血缘关系 → {excel_path} ({len(rows)} 个字段映射, {len(lineages)} 张表)")
    return lineage_dir
