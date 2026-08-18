"""血缘关系生成器

从 MappingSheet 提取表级和字段级血缘信息，输出 Excel 文件。
血缘关系覆盖 ODS→DWD→DWS 全链路。
"""

import os
import re

import pandas as pd

from tools.utils.logging_setup import get_logger
from ..config import GLOBAL_TABLE_CN_MAP

logger = get_logger(__name__)


def _strip_schema_ref(name: str) -> str:
    """去掉 schema 前缀，返回裸表名"""
    if '.' in name:
        return name.rsplit('.', 1)[-1]
    return name


# 构建全局表名 -> 中文名的扁平索引（键同时含 全名 和 裸表名），便于子查询中的表名匹配
_GLOBAL_CN_INDEX = {}
for _name, _cn in GLOBAL_TABLE_CN_MAP.items():
    _GLOBAL_CN_INDEX[_name] = _cn
    _GLOBAL_CN_INDEX[_strip_schema_ref(_name)] = _cn


def _global_cn(table: str) -> str:
    """从全局映射中按 全名或裸表名 匹配中文名"""
    return _GLOBAL_CN_INDEX.get(table) or _GLOBAL_CN_INDEX.get(_strip_schema_ref(table), "")


# 正则：从子查询中提取真实表名（支持 schema.table 格式）及行尾注释
# 匹配 FROM/JOIN 后的表名（含可选 -- 注释）
_TABLE_REF_RE = re.compile(
    r'(?:FROM|JOIN)\s+([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)?)\s*(?:[A-Za-z0-9_]+)?\s*(?:--\s*([^\n]*))?',
    re.IGNORECASE,
)


def _extract_tables_from_subquery(subquery: str) -> list[tuple[str, str]]:
    """从子查询 SQL 中提取引用的真实表名，返回 [(表名, 行尾注释), ...]"""
    if not subquery:
        return []
    # 查找 FROM/JOIN 后的表名及注释
    matches = _TABLE_REF_RE.findall(subquery)
    seen = set()
    result = []
    for table, comment in matches:
        if table and table not in seen:
            seen.add(table)
            comment = comment.strip() if comment else ""
            result.append((table, comment))
    return result


def _is_subquery(value: str) -> bool:
    """判断字符串是否为子查询（包含 SELECT 或以 -- 注释开头后跟 SELECT）"""
    if not value:
        return False
    v = value.strip().upper()
    # 兼容全宽括号（中文括号）
    # 也兼容以 -- 注释开头的 SQL 块
    return (v.startswith("SELECT") or
            (v.startswith("(") or v.startswith("（")) and "SELECT" in v or
            v.startswith("--") and "SELECT" in v)


def _looks_like_alias(name: str) -> bool:
    """判断是否像表别名（短、大写字母+数字，如 A1, T1, T2）"""
    if not name:
        return False
    # 1-3 位，大写字母开头，后跟数字
    return bool(re.match(r'^[A-Z][A-Z0-9]{0,2}$', name.strip()))


def _looks_like_real_table(name: str) -> bool:
    """判断是否像真实表名（包含 ODS_、DWD_、DWS_ 前缀）"""
    if not name:
        return False
    return any(prefix in name.upper() for prefix in ("ODS_", "DWD_", "DWS_"))


def _strip_schema(full_name: str) -> str:
    """去掉 schema 前缀，返回裸表名"""
    if '.' in full_name:
        return full_name.rsplit('.', 1)[-1]
    return full_name


def _build_table_cn_lookup(sheet_mappings) -> dict:
    """构建真实表名（含裸表名） -> 中文名的查找表，忽略子查询"""
    lookup = {}
    for mr in sheet_mappings:
        if mr.src_table_name and not _is_subquery(mr.src_table_name):
            table_name = mr.src_table_name
            table_cn = mr.src_table_cn or ""

            # 如果 src_table_name 是别名而 src_table_cn 是真实表名，交换
            if _looks_like_alias(table_name) and _looks_like_real_table(table_cn):
                real_table = table_cn
                real_cn = _global_cn(real_table) or real_table
                # 同时存全名和裸名
                for key in (real_table, _strip_schema(real_table)):
                    lookup[key] = real_cn
            else:
                # 同时存全名和裸名
                for key in (table_name, _strip_schema(table_name)):
                    lookup[key] = table_cn
    return lookup


def _resolve_upstream_tables(mr, sheet_mappings, sys_name: str = "") -> list[tuple[str, str]]:
    """
    解析上游表名：优先用 src_table_name，若为子查询则从中提取所有真实表名。
    返回 [(表英文名, 表中文名), ...] 列表，支持子查询展开多个表。
    """
    src_table = mr.src_table_name or ""
    src_table_cn = mr.src_table_cn or ""

    # ODS 表补全 schema 前缀（ODS_XDAY_{sys}）
    if sys_name and src_table.startswith("ODS_") and not src_table.startswith("ODS_XDAY_"):
        src_table = f"ODS_XDAY_{sys_name}.{src_table}"

    # 处理别名/真实表名可能反向的情况
    if _looks_like_alias(src_table) and _looks_like_real_table(src_table_cn):
        src_table, src_table_cn = src_table_cn, src_table
        # 交换后用全局映射获取真实表的中文名
        src_table_cn = _global_cn(src_table) or src_table_cn

    if _is_subquery(src_table):
        # 预构建真实表的中文名查找表
        table_cn_lookup = _build_table_cn_lookup(sheet_mappings)
        # 从子查询提取所有真实表及行尾注释
        extracted = _extract_tables_from_subquery(src_table)
        if extracted:
            results = []
            for table, comment in extracted:
                # 子查询中的表也需要补全 schema
                if sys_name and table.startswith("ODS_") and not table.startswith("ODS_XDAY_"):
                    table = f"ODS_XDAY_{sys_name}.{table}"
                # 优先级：非子查询映射 > 行尾注释 > 全局映射 > 当前映射的中文名
                table_cn = table_cn_lookup.get(table) or _global_cn(table)
                if not table_cn:
                    table_cn = comment or src_table_cn
                results.append((table, table_cn))
            return results

    # 非子查询，处理别名/真实表名反向
    if _looks_like_alias(src_table) and _looks_like_real_table(src_table_cn):
        src_table, src_table_cn = src_table_cn, src_table
        # 使用全局映射获取中文名
        src_table_cn = _global_cn(src_table) or src_table_cn

    # 非子查询，直接返回（若中文名为空则用全局映射补充）
    if src_table:
        if not src_table_cn:
            src_table_cn = _global_cn(src_table)
        return [(src_table, src_table_cn)]
    return []


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

        # 收集上游表（去重），处理子查询
        upstream_tables = []
        seen_tables = set()
        for mr in sheet.mappings:
            if not mr.src_table_name:
                continue
            tables = _resolve_upstream_tables(mr, sheet.mappings, sys_name)
            for table_name, table_cn in tables:
                if table_name and table_name not in seen_tables:
                    seen_tables.add(table_name)
                    upstream_tables.append((table_name, table_cn))

        mappings = []
        for mr in sheet.mappings:
            if not mr.tgt_name or not mr.src_field_alias:
                continue
            tables = _resolve_upstream_tables(mr, sheet.mappings, sys_name)
            # 字段级血缘取第一个表（兼容性），或者可以展开
            src_table, src_table_cn = tables[0] if tables else ("", "")
            mappings.append({
                "tgt_field": mr.tgt_name,
                "tgt_field_cn": mr.tgt_name_cn,
                "src_table": src_table,
                "src_table_cn": src_table_cn,
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
    表级血缘(扁平) sheet：每行一对 目标表→上游表，便于筛选和导入图数据库。
    """
    lineage_dir = os.path.join(output_dir, "lineage")
    os.makedirs(lineage_dir, exist_ok=True)

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

        # 表级血缘（扁平格式：每行一对 目标表→上游表")
        flat_rows = []
        for lt in lineages:
            for up_table, up_cn in lt["upstream_tables"]:
                flat_rows.append({
                    "目标表英文名": lt["tgt_table"],
                    "目标表中文名": lt["tgt_table_cn"],
                    "目标层级": lt["layer"],
                    "目标系统": lt["sys_name"],
                    "上游表英文名": up_table,
                    "上游表中文名": up_cn,
                })
        pd.DataFrame(flat_rows).to_excel(writer, index=False, sheet_name="表级血缘(扁平)")

    logger.info(f"  血缘关系 → {excel_path} ({len(rows)} 个字段映射, {len(lineages)} 张表, {len(flat_rows)} 个表级关系)")
    return lineage_dir
