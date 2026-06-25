import os
import re
import pandas as pd
from ..core.ir import MappingSheet, MappingRule
from tools.utils.pandas_helpers import safe_str, safe_float_str
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)

# 跳过非数据sheet（目录、变更记录等）
_SKIP_SHEETS = ('目录', '变更记录', '修改记录', '数据测试')


def _sanitize_identifier(name: str) -> str:
    """
    清理标识符，确保只包含字母、数字和下划线

    将空格、连字符、点等非法字符替换为下划线，并合并连续下划线

    Args:
        name: 原始标识符

    Returns:
        清理后的安全标识符
    """
    if not name:
        return name
    # 记录原始名称（用于日志）
    original = name
    # 替换所有非字母数字下划线的字符为下划线
    name = re.sub(r'[^A-Za-z0-9_]', '_', name)
    # 合并连续的下划线
    name = re.sub(r'_+', '_', name)
    # 去除开头和结尾的下划线
    name = name.strip('_')
    if name != original:
        logger.debug(f"Sanitized identifier: '{original}' -> '{name}'")
    return name


def _has_chinese(text: str) -> bool:
    """检测字符串是否包含中文 CJK 统一表意文字"""
    return bool(text) and any('一' <= ch <= '鿿' for ch in text)


def parse_mapping_sheet(filepath: str, sheet_name: str) -> MappingSheet:
    """
    解析单个 MAPPING sheet。

    MAPPING Excel 的通用结构:
    - Row 0: 工作区说明 或 源表声明
    - Row 1: 源表声明 或 目标表中文名称
    - Row 2-9: 元数据(目标表名, 功能描述, 分区字段, 参数, 频度, 表类型, 加载类型, 增量逻辑)
    - 列头行: 包含 "目标字段英文名" 的行, 后面是字段数据

    列头格式因系统不同而异:
    O32: col 0=目标字段英文名, col 1=目标字段中文名, col 2=目标字段类型,
         col 3=序号, col 4=主键, col 5=组别, col 6=JOIN方式,
         col 7=关联条件, col 8=关联条件说明, col 9=源表别名,
         col 10=源表英文名, col 11=源表中文名, col 12=源字段英文名, ...
    HSFA: 类似但 col 6=组别, col 7=源表别名, col 8=源表英文名, ...

    策略: 动态扫描列头行, 按 "目标字段英文名" 定位, 再按列名映射。
    """
    df = pd.read_excel(filepath, sheet_name=sheet_name, header=None)

    # 使用统一的 safe_str 函数，但需要直接访问 df.iloc
    def cell(row_idx: int, col_idx: int) -> str:
        if row_idx >= len(df) or col_idx < 0 or col_idx >= len(df.columns):
            return ""
        row = df.iloc[row_idx]
        return safe_str(row, col_idx)

    # 动态定位元数据行 (查找 "目标表中文名称", "目标表英文名称" 等关键字)
    tgt_cn_row = _find_row_by_keyword(df, "目标表中文名称", 0)
    tgt_en_row = _find_row_by_keyword(df, "目标表英文名称", 0)
    func_row = _find_row_by_keyword(df, "功能描述", 0)
    part_row = _find_row_by_keyword(df, "分区字段", 0)
    param_row = _find_row_by_keyword(df, "参数", 0)
    freq_row = _find_row_by_keyword(df, "频度", 0)
    type_row = _find_row_by_keyword(df, "目标表类型", 0)
    load_row = _find_row_by_keyword(df, "加载类型", 0)
    incr_row = _find_row_by_keyword(df, "增量逻辑", 0)

    # 动态定位列头行
    header_row = _find_row_by_keyword(df, "目标字段英文名", 0)

    # 构建列名映射
    col_map = {}
    if header_row >= 0:
        for j in range(len(df.columns)):
            hdr = cell(header_row, j)
            if hdr:
                col_map[hdr] = j

    sheet = MappingSheet(
        tgt_table_cn=cell(tgt_cn_row, 1) if tgt_cn_row >= 0 else "",
        tgt_table=cell(tgt_en_row, 1) if tgt_en_row >= 0 else "",
        func_desc=cell(func_row, 1) if func_row >= 0 else "",
        partition_col=cell(part_row, 1) if part_row >= 0 else "p_dt",
        param=cell(param_row, 1) if param_row >= 0 else "p_batch_dt",
        frequency=cell(freq_row, 1) if freq_row >= 0 else "D",
        tgt_table_type=cell(type_row, 1) if type_row >= 0 else "",
        load_type=cell(load_row, 1) if load_row >= 0 else "",
        incr_logic=cell(incr_row, 1) if incr_row >= 0 else "",
    )

    if header_row < 0:
        return sheet

    # 解析字段映射
    for i in range(header_row + 1, len(df)):
        tgt_name = cell(i, col_map.get("目标字段英文名", 0))
        if not tgt_name:
            continue
        # 跳过注释行：目标字段英文名包含中文的行（如"初始化。第1组插入交易日历史数据"等ETL逻辑说明）
        if _has_chinese(tgt_name):
            logger.info(f"  SKIP comment row {i}: '{tgt_name[:60]}'")
            continue

        tgt_type = cell(i, col_map.get("目标字段类型", 2))
        tgt_name_cn = cell(i, col_map.get("目标字段中文名", 1))
        tgt_ordinal = safe_float_str(cell(i, col_map.get("序号", 3)), default=0.0)
        is_pk = cell(i, col_map.get("主键", 4))
        group_no = cell(i, col_map.get("组别", 5))

        # JOIN方式 - 在 O32 的 col 6, HSFA 可能不同
        join_type_raw = cell(i, col_map.get("JOIN方式", -1)) or ""

        # 源表别名
        src_table_alias = cell(i, col_map.get("源表别名", -1))

        # 关联条件
        join_cond = cell(i, col_map.get("关联条件", -1))

        # 源字段英文名 (用于构建映射)
        src_field_name = cell(i, col_map.get("源字段英文名", -1))
        src_table_name = cell(i, col_map.get("源表英文名", -1))

        # 映射规则 - 有的格式有专门的"映射规则"列
        src_field_alias = cell(i, col_map.get("映射规则", -1))

        # 如果没有映射规则列, 从源字段英文名+别名构建
        if not src_field_alias and src_field_name and src_table_alias:
            src_field_alias = f"{src_table_alias}.{src_field_name}"

        # 清理目标字段名，确保符合 SQL 标识符规则（只允许字母、数字、下划线）
        tgt_name = _sanitize_identifier(tgt_name)

        # 过滤条件
        filter_cond = cell(i, col_map.get("过滤条件", -1))

        mr = MappingRule(
            tgt_name=tgt_name,
            tgt_name_cn=tgt_name_cn,
            tgt_type=tgt_type,
            tgt_ordinal=tgt_ordinal,
            is_pk=is_pk,
            group_no=group_no,
            src_field_alias=src_field_alias,
            src_table_alias=src_table_alias,
            src_table_name=src_table_name,
            src_table_cn=cell(i, col_map.get("源表中文名", -1)),
            src_field_name=src_field_name,
            join_type=join_type_raw,
            join_cond=join_cond,
            filter_cond=_extract_filter(filter_cond),
            note=cell(i, col_map.get("备注", -1)),
        )
        sheet.mappings.append(mr)

    # 自动收集源表列表（从字段映射的"源表英文名"列），严格按照 Excel 给的值
    sheet.source_tables = sorted({mr.src_table_name for mr in sheet.mappings if mr.src_table_name})

    return sheet


def parse_mapping_dir(mapping_dir: str) -> list:
    """遍历目录下所有 MAPPING Excel, 解析所有 sheet"""
    results = []
    for fname in sorted(os.listdir(mapping_dir)):
        if fname.startswith('~$') or not fname.endswith('.xlsx'):
            continue
        path = os.path.join(mapping_dir, fname)
        xls = pd.ExcelFile(path)
        for sn in xls.sheet_names:
            if sn in _SKIP_SHEETS:
                continue
            try:
                results.append(parse_mapping_sheet(path, sn))
            except Exception as e:
                logger.warning(f"  WARN: skip {fname}/{sn}: {e}")
    return results


def parse_dws_mapping(filepath: str) -> list:
    """解析 DWS MAPPING 文件(单文件多sheet)"""
    results = []
    xls = pd.ExcelFile(filepath)
    for sn in xls.sheet_names:
        if sn in _SKIP_SHEETS:
            continue
        try:
            results.append(parse_mapping_sheet(filepath, sn))
        except Exception as e:
            logger.warning(f"  WARN: skip {filepath}/{sn}: {e}")
    return results


def _find_row_by_keyword(df, keyword: str, start_row: int = 0) -> int:
    """在 df 中从 start_row 开始查找第一个 col 0 包含 keyword 的行"""
    for i in range(start_row, len(df)):
        v = df.iloc[i, 0]
        if pd.notna(v) and keyword in str(v):
            return i
    return -1




def _extract_filter(val: str) -> str:
    """提取过滤条件, 去掉 WHERE/AND 前缀"""
    if not val:
        return ""
    val = val.strip()
    if val.startswith("WHERE "):
        return val[6:]
    if val.startswith("AND "):
        return val[4:]
    return val


