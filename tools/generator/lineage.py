"""血缘关系生成器

从 MappingSheet 提取表级和字段级血缘信息，输出 JSON 文件。
血缘关系覆盖 ODS→DWD→DWS 全链路。
"""

import json
import os
from ..core.ir import LineageField, LineageTable
from tools.utils.table_utils import write_file
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


def generate_lineage_json(lineages: list, output_dir: str, layer: str) -> str:
    """将血缘数据序列化为 JSON 文件。

    输出两个文件:
    - {layer}_tables.json: 表级血缘（目标表 ← 上游表）
    - {layer}_fields.json: 字段级血缘（目标字段 ← 源字段+转换逻辑）

    Returns:
        输出目录路径
    """
    lineage_dir = os.path.join(output_dir, "lineage")
    os.makedirs(lineage_dir, exist_ok=True)

    # 表级血缘
    table_data = [
        {
            "tgt_table": l.tgt_table,
            "tgt_table_cn": l.tgt_table_cn,
            "layer": l.layer,
            "sys_name": l.sys_name,
            "upstream_tables": l.upstream_tables,
        }
        for l in lineages
    ]
    tables_path = os.path.join(lineage_dir, f"{layer}_tables.json")
    write_file(tables_path, json.dumps(table_data, indent=2, ensure_ascii=False))
    logger.info(f"    表级血缘 → {tables_path}")

    # 字段级血缘
    field_data = [
        {
            "tgt_table": f.tgt_table,
            "tgt_field": f.tgt_field,
            "tgt_field_cn": f.tgt_field_cn,
            "src_table": f.src_table,
            "src_field": f.src_field,
            "src_field_alias": f.src_field_alias,
            "join_type": f.join_type,
            "filter_cond": f.filter_cond,
            "note": f.note,
        }
        for l in lineages
        for f in l.mappings
    ]
    fields_path = os.path.join(lineage_dir, f"{layer}_fields.json")
    write_file(fields_path, json.dumps(field_data, indent=2, ensure_ascii=False))
    logger.info(f"    字段级血缘 → {fields_path}")

    return lineage_dir
