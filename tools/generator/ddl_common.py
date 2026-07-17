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
