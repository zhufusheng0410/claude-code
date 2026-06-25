import os
import re
import pandas as pd
from ..core.ir import MappingSheet, MappingRule
from tools.utils.pandas_helpers import safe_str, safe_float_str
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)

# 跳过非数据sheet（目录、变更记录等）
_SKIP_SHEETS = ('目录', '变更记录', '修改记录', '数据测试')

# 已知的列头描述行（出现在数据区域中但只是列名说明，不是真正的注释行）
_KNOWN_COLUMN_HEADERS = frozenset({
    '目标字段中文名', '目标字段类型', '序号', '主键', '组别',
    'JOIN方式', '关联条件', '关联条件说明', '源表别名', '源表英文名',
    '源表中文名', '源字段英文名', '源字段中文名', '源字段类型',
    '映射规则', '映射规则注释', '备注', '数据质量检查或约束条件',
    '过滤条件', '过滤条件说明',
})


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

    # 一次扫描 col 0 找所有关键词行，避免 N 次重复遍历
    _KEYWORDS = {
        "目标表中文名称", "目标表英文名称", "功能描述", "分区字段",
        "参数", "频度", "目标表类型", "加载类型", "增量逻辑", "目标字段英文名",
    }
    keyword_rows: dict[str, int] = {}
    for i in range(len(df)):
        v = df.iloc[i, 0]
        if pd.notna(v):
            s = str(v)
            for kw in _KEYWORDS - keyword_rows.keys():
                if kw in s:
                    keyword_rows[kw] = i

    def cell(row_idx: int, col_idx: int) -> str:
        if row_idx < 0 or row_idx >= len(df) or col_idx < 0 or col_idx >= len(df.columns):
            return ""
        return safe_str(df.iloc[row_idx], col_idx)

    def meta(keyword: str, default: str = "") -> str:
        row = keyword_rows.get(keyword, -1)
        return cell(row, 1) if row >= 0 else default

    header_row = keyword_rows.get("目标字段英文名", -1)

    sheet = MappingSheet(
        tgt_table_cn=meta("目标表中文名称"),
        tgt_table=meta("目标表英文名称"),
        func_desc=meta("功能描述"),
        partition_col=meta("分区字段", "p_dt"),
        param=meta("参数", "p_batch_dt"),
        frequency=meta("频度", "D"),
        tgt_table_type=meta("目标表类型"),
        load_type=meta("加载类型"),
        incr_logic=meta("增量逻辑"),
    )

    if header_row < 0:
        return sheet

    # 构建列名映射
    col_map = {cell(header_row, j): j for j in range(len(df.columns)) if cell(header_row, j)}

    # 解析字段映射
    for i in range(header_row + 1, len(df)):
        tgt_name = cell(i, col_map.get("目标字段英文名", 0))
        if not tgt_name:
            continue
        # 跳过注释行：目标字段英文名包含中文的行（如"初始化。第1组插入交易日历史数据"等ETL逻辑说明）
        if _has_chinese(tgt_name):
            if tgt_name not in _KNOWN_COLUMN_HEADERS:
                logger.info(f"  SKIP comment row {i}: '{tgt_name[:80]}'")
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


def _parse_xlsx_sheets(filepath: str) -> list:
    """从单个 Excel 文件解析所有非跳过 sheet，返回 [MappingSheet]"""
    results = []
    with pd.ExcelFile(filepath) as xls:
        fname = os.path.basename(filepath)
        for sn in xls.sheet_names:
            if sn in _SKIP_SHEETS:
                continue
            try:
                results.append(parse_mapping_sheet(filepath, sn))
            except Exception as e:
                logger.warning(f"  WARN: skip {fname}/{sn}: {e}")
    return results


def parse_mapping_dir(mapping_dir: str) -> list:
    """遍历目录下所有 MAPPING Excel, 解析所有 sheet"""
    results = []
    for fname in sorted(os.listdir(mapping_dir)):
        if fname.startswith('~$') or not fname.endswith('.xlsx'):
            continue
        results.extend(_parse_xlsx_sheets(os.path.join(mapping_dir, fname)))
    return results


def parse_dws_mapping(filepath: str) -> list:
    """解析 DWS MAPPING 文件(单文件多sheet)"""
    return _parse_xlsx_sheets(filepath)




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


