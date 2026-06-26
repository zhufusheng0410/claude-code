"""血缘关系生成器

从 MappingSheet 提取表级和字段级血缘信息，输出 Excel 文件。
血缘关系覆盖 ODS→DWD→DWS 全链路。
"""

import os

import pandas as pd

from ..core.ir import LineageField, LineageTable
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)


def extract_lineage(sheets: list, layer: str, sys_name: str) -> list:
    """从 MAPPING sheets 提取表级+字段级血缘。

    Args:
        sheets: MappingSheet 列表（每个 sheet 对应一张目标表）
        layer: 层级名称 (DWD / DWS)
        sys_name: 系统简称

    Returns:
        [LineageTable] 列表
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

        # 构建字段级血缘
        fields = []
        for mr in sheet.mappings:
            if not mr.tgt_name or not mr.src_field_alias:
                continue
            fields.append(LineageField(
                tgt_table=sheet.tgt_table,
                tgt_field=mr.tgt_name,
                tgt_field_cn=mr.tgt_name_cn,
                src_table=mr.src_table_name or "",
                src_field=mr.src_field_name or "",
                src_field_alias=mr.src_field_alias,
                join_type=mr.join_type,
                filter_cond=mr.filter_cond,
                note=mr.note,
            ))

        lt = LineageTable(
            tgt_table=sheet.tgt_table,
            tgt_table_cn=sheet.tgt_table_cn,
            layer=layer,
            sys_name=sys_name,
            upstream_tables=upstream_tables,
            mappings=fields,
        )
        lineages.append(lt)

    logger.info(f"  血缘关系: {len(lineages)} 张表, {sum(len(l.mappings) for l in lineages)} 个字段映射")
    return lineages


def generate_lineage_excel(lineages: list, output_dir: str, layer: str) -> str:
    """将血缘数据输出为 Excel 文件（字段级）。

    输出一个 Excel 文件，包含以下列：
    - 目标表英文名 / 目标表中文名
    - 目标字段英文名 / 目标字段中文名
    - 来源表英文名 / 来源表中文名
    - 来源字段英文名 / 来源字段中文名
    - 映射规则/表达式
    - JOIN 方式
    - 过滤条件
    - 备注

    Returns:
        输出目录路径
    """
    lineage_dir = os.path.join(output_dir, "lineage")
    os.makedirs(lineage_dir, exist_ok=True)

    # 收集所有字段级记录
    rows = []
    for lt in lineages:
        tgt_table = lt.tgt_table
        tgt_table_cn = lt.tgt_table_cn
        for fld in lt.mappings:
            rows.append({
                "目标表英文名": tgt_table,
                "目标表中文名": tgt_table_cn,
                "目标字段英文名": fld.tgt_field,
                "目标字段中文名": fld.tgt_field_cn,
                "来源表英文名": fld.src_table,
                "来源字段英文名": fld.src_field,
                "来源字段中文名": fld.src_field_alias,
                "映射规则/表达式": fld.note or "",
                "JOIN方式": fld.join_type or "",
                "过滤条件": fld.filter_cond or "",
                "备注": fld.note or "",
            })

    if not rows:
        logger.warning(f"  血缘关系: 无数据可输出")
        return lineage_dir

    df = pd.DataFrame(rows)

    # 写入 Excel
    excel_path = os.path.join(lineage_dir, f"{layer}_lineage.xlsx")
    with pd.ExcelWriter(excel_path, engine="openpyxl") as writer:
        df.to_excel(writer, index=False, sheet_name="字段级血缘")

        # 同时生成表级血缘 sheet
        table_rows = []
        for lt in lineages:
            table_rows.append({
                "目标表英文名": lt.tgt_table,
                "目标表中文名": lt.tgt_table_cn,
                "层级": lt.layer,
                "系统": lt.sys_name,
                "上游表列表": "; ".join(lt.upstream_tables),
            })
        df_tables = pd.DataFrame(table_rows)
        df_tables.to_excel(writer, index=False, sheet_name="表级血缘")

    logger.info(f"  血缘关系 → {excel_path} ({len(rows)} 个字段映射, {len(lineages)} 张表)")
    return lineage_dir
