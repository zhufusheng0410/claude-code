"""DDL 生成共用逻辑

ODS 和 DWD/DWS 的建表语句结构相同：
  DROP TABLE IF EXISTS; CREATE TABLE (fields); COMMENT; PARTITIONED BY; ROW FORMAT;

本模块提供通用的 DDL 生成函数，消除 ODS 和 DWD/DWS 之间的重复代码。
"""

from ..config import DDL_PARTITIONS, DDL_ROW_FORMAT, DDL_FIELD_PREFIX, DDL_FIELD_SEP


def escape_sql_comment(comment: str) -> str:
    """转义 SQL 注释中的单引号，防止 COMMENT 子句注入或语法错误。

    统一替代各生成器里散落的 `comment.replace("'", "''")`。
    """
    if not comment:
        return ""
    return comment.replace("'", "''")


def build_field_defs(
    field_specs: list,
    sys_fields: list = None,
    existing_names: set = None,
) -> list:
    """统一的字段定义构建器。

    消除 ODS generate_ods_ddl 与 DWD/DWS BaseGenerator.generate_ddl 中重复的
    "验证标识符 → 拼接字段行 → 追加系统字段" 逻辑。

    Args:
        field_specs: [(name, type, comment), ...] 已去重的字段三元组列表。
            name 为字段英文名，type 为 Hive 类型（空则用 STRING），comment 为字段中文名。
        sys_fields: [(name, type, comment), ...] 系统字段，追加到末尾（跳过已存在的）。
        existing_names: 已出现的字段名集合，用于跳过系统字段重复。若为 None 则从
            field_specs 自行推导。
    Returns:
        字段定义字符串列表，每项形如 "CUST_NO  STRING DEFAULT NULL COMMENT '客户号'"。
    """
    from tools.utils.validation import validate_db_identifier

    field_defs = []
    seen = set(existing_names) if existing_names is not None else set()
    for name, ftype, comment in field_specs:
        validate_db_identifier(name, "field name")
        if name in seen:
            continue
        seen.add(name)
        ftype = ftype if ftype else "STRING"
        field_defs.append(
            f"{name}  {ftype} DEFAULT NULL COMMENT '{escape_sql_comment(comment)}'"
        )

    if sys_fields:
        for sf_name, sf_type, sf_cn in sys_fields:
            if sf_name in seen:
                continue
            validate_db_identifier(sf_name, "system field name")
            seen.add(sf_name)
            field_defs.append(
                f"{sf_name}  {sf_type} DEFAULT NULL COMMENT '{escape_sql_comment(sf_cn)}'"
            )

    return field_defs


def generate_ddl_body(
    schema: str,
    tbl: str,
    fields: list,
    comment: str,
    field_prefix: str = DDL_FIELD_PREFIX,
    field_sep: str = DDL_FIELD_SEP,
    partitions: str = DDL_PARTITIONS,
    row_format: str = DDL_ROW_FORMAT,
) -> str:
    """生成标准 DDL 主体（不含 DROP）。

    Args:
        schema: 数据库名
        tbl: 表名
        fields: 字段定义字符串列表
        comment: 表注释
        field_prefix: 字段行前缀（ODS 用 "   "，DWD 也用 "   "）
        field_sep: 字段分隔符
        partitions: 分区子句
        row_format: 行格式子句

    Returns:
        完整的 CREATE TABLE DDL 语句
    """
    comment = escape_sql_comment(comment)
    field_defs = [f"{field_prefix}{f}" for f in fields]
    lines = [
        f"CREATE TABLE {schema}.{tbl} (",
        field_sep.join(field_defs),
        ")",
        f"COMMENT '{comment}'",
        partitions,
        f"{row_format} ;",
    ]
    return "\n".join(lines)
