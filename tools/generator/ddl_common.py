"""DDL 生成共用逻辑

ODS 和 DWD/DWS 的建表语句结构相同：
  DROP TABLE IF EXISTS; CREATE TABLE (fields); COMMENT; PARTITIONED BY; ROW FORMAT;

本模块提供通用的 DDL 生成函数，消除 ODS 和 DWD/DWS 之间的重复代码。
"""

import re

from ..config import DDL_PARTITIONS, DDL_ROW_FORMAT, DDL_FIELD_PREFIX, DDL_FIELD_SEP

# ★★★ 2026-10-26：Oracle/Hive 类型前缀共享常量（消除 ods.py 与 base.py 重复维护）
ORACLE_NUMERIC_PREFIXES = (
    "NUMBER", "FLOAT", "INTEGER", "INT", "BINARY_FLOAT", "BINARY_DOUBLE",
    "DECIMAL", "NUMERIC",
)
ORACLE_DATE_PREFIXES = ("DATE", "TIMESTAMP")
ORACLE_CHAR_PREFIXES = ("CHAR", "VARCHAR", "VARCHAR2", "NCHAR", "NVARCHAR")
# ★ Hive 侧字符串类型（**不含** Oracle 的 CHAR/VARCHAR，两者需合并判断）
HIVE_STRING_PREFIXES = ("STRING", "TEXT")
HIVE_NUMERIC_PREFIXES = (
    "DECIMAL", "DOUBLE", "FLOAT", "INT", "BIGINT", "SMALLINT",
    "TINYINT", "NUMERIC",
)

# 合法 Hive 类型（用于判断是否需要归一化；Oracle 裸类型不在其列）
# ★ 2026-10-26：保留复杂类型 ARRAY/MAP/STRUCT/UNIONTYPE（测试用例验证，虽本项目不生成）
_VALID_HIVE_TYPE = re.compile(
    r"^(?:STRING|TINYINT|SMALLINT|INT|INTEGER|BIGINT|BOOLEAN|FLOAT|DOUBLE"
    r"|REAL|DATE|BINARY"
    r"|DECIMAL\s*(?:\(\s*\d+\s*(?:\s*,\s*\d+)?\s*\))?"
    r"|TIMESTAMP(?:\s+WITH\s+LOCAL\s+TIME\s+ZONE)?"
    r"|CHAR\s*\(\s*\d+\s*\)|VARCHAR\s*\(\s*\d+\s*\)"
    r"|ARRAY\s*<.*>|MAP\s*<.*>|STRUCT\s*<.*>|UNIONTYPE\s*<.*>)$",
    re.I | re.S)


def normalize_hive_type(ftype: str, field_cn: str = "") -> str:
    """把 Oracle 原始类型归一成 Hive 类型；**已是 Hive 类型的原样返回**。

    ★ 2026-10-12 修 bug（全量重生成后 19 张 DWD 表建不出来）：
      甲方 MAPPING 的「目标字段类型」列直填了 Oracle 类型——
      `NUMBER(30,8)` 171 列、`NUMBER(30,15)` 20 列、`NUMBER(30,16)` 3 列、
      `char` 2 列、`VARCHAR2(64)` 1 列，合计 197 列/19 张表。
      build_field_defs 此前原样拼进 DDL ⇒ Hive 4.2.0 实测：
        ParseException line 10:11 cannot recognize input near 'NUMBER' '(' '30'
        in column type
    ★ 只归一「非 Hive 合法」的类型：已是 `DECIMAL(18,2)` 的**不能**过
      `oracle_to_hive`（它不认 DECIMAL，会退化成 STRING，反而破坏正确类型）。
    """
    if not ftype:
        return "STRING"
    t = str(ftype).strip()
    if _VALID_HIVE_TYPE.match(t):
        return t
    from ..core.type_mapper import oracle_to_hive
    return oracle_to_hive(t, field_cn)


# ★★★ Hive 侧保留字：作为【列名】出现在 Hive SQL 里时必须加**反引号**引用，
#   否则 Hive 解析器会把它们当语法元素 ⇒ 直接 ParseException，**建表就失败**。
#
# ★ 2026-10-09 起因：全量重生成 ODS 后，`ODS_HSDS_TOAD_PLAN_TABLE_PFD` 等 6 张表
#   建不出来：
#     ParseException line 1:36 cannot recognize input near 'TIMESTAMP' 'STRING' ','
#   根因：**列名引号只有 Oracle 侧做了**（ods.py::quote_oracle_column 加双引号），
#   Hive 侧没有 —— 于是 DDL 的字段定义和 ETL 的 SELECT 列表都裸写了这些词。
#
# ★ 清单来源 = Hive 官方 Reserved Keywords，并**在 Hive 4.2.0 上一词一词实测核对**：
#       EXCHANGE / TIME / TIMESTAMP   → 裸写 ParseException，必须加反引号
#       LEVEL / TYPE                  → 裸写**能**正常建表（这俩是 **Oracle** 保留字，
#                                       不是 Hive 的）⇒ 不进本清单，避免过度加引号
#   反引号对非保留字同样合法 ⇒ 本清单宁可宽不可窄（只影响可读性，不影响正确性）。
#
# ★ 作用域仅限 **Hive 侧的 DDL / SELECT 列名**。两处**不能**用：
#     ① DataX writer 的 `column[].name` —— 那是**按名字匹配** DataX 记录的 key，
#        加了反引号就对不上，会写成空/错位；
#     ② Oracle 源的 querySql —— 那边用 ods.py::quote_oracle_column 加**双引号**。
HIVE_RESERVED_WORDS = frozenset("""
ALL ALTER AND ARRAY AS AUTHORIZATION BETWEEN BOTH BY CASE CAST CHECK COLLATE COLUMN
CONSTRAINT CREATE CROSS CUBE CURRENT_DATE CURRENT_TIMESTAMP CURSOR DATABASE DATE DAY
DELETE DESCRIBE DISTINCT DROP ELSE END EXCEPT EXCHANGE EXISTS EXTENDED EXTERNAL EXTRACT
FALSE FETCH FILTER FOLLOWING FOR FOREIGN FROM FULL FUNCTION GRANT GROUP GROUPING HAVING
HOUR IN INNER INSERT INTERSECT INTERVAL INTO IS JOIN LEADING LEFT LIKE LIMIT LOCAL MACRO
MAP MINUTE MONTH NATURAL NOT NULL NULLS OF ON ONLY OR ORDER OUT OUTER OVER OVERWRITE
PARTITION PERCENT PRECEDING PRIMARY PROCEDURE RANGE REFERENCES REVOKE RIGHT ROLLUP ROW
ROWS SECOND SELECT SESSION_USER SET SOME TABLE TABLESAMPLE THEN TIME TIMESTAMP TO
TRAILING TRUE TRUNCATE UNION UNIQUE UNNEST UPDATE USER USING VALUES WHEN WHERE WINDOW
YEAR
""".split())


def quote_hive_column(name: str) -> str:
    """Hive 侧列名引用：Hive 保留字加反引号，其余原样返回。

    用于 Hive **DDL 的字段定义** 与 **ETL 的 SELECT 列名**（两者都必须），
    不要用于 DataX writer 的 column[].name。
    """
    if not name:
        return name
    return "`%s`" % name if name.upper() in HIVE_RESERVED_WORDS else name


def quote_hive_column_sh(name: str) -> str:
    """★ **写进 .sh 脚本** 的 Hive 列名引用 —— 反引号要再加一层 **shell 转义**。

    ★★★ 2026-10-09（J-04）为什么必须有这个变体：
    ODS 的 ETL 是 `sh` 脚本，SQL 以 **双引号** 传给 beeline：
        inceptor_beeline() { beeline ... -e "$1"; }
        inceptor_beeline "CREATE TABLE ... ( `TIMESTAMP` STRING ... )"
    在 sh 里，**双引号内的反引号是「命令替换」** —— 上面那行会真的去执行
    `TIMESTAMP` 这个命令，然后把它替换成空串。实测任务日志：
        line 11: TIMESTAMP: command not found
        line 11: TIME: command not found
    ⇒ 列定义变成 `   STRING  COMMENT  '',`（列名蒸发）⇒ ParseException
      ⇒ _TMP 建不出来 ⇒ DataX `HdfsWriter-02: path ... does not exist`。
    ★ 处理方式：对反引号再加一层反斜杠。sh 解析后 beeline 收到的仍是反引号包裹的列名。

    适用：`.sh` 里的 **Hive DDL / SELECT**。纯 `.sql` 文件走 `quote_hive_column`（不经 shell）。
    """
    if not name:
        return name
    return "\\`%s\\`" % name if name.upper() in HIVE_RESERVED_WORDS else name


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
        字段定义字符串列表，每项形如 "CUST_NO  STRING COMMENT '客户号'"。

    ★ 2026-09-28 修 bug：**不能写 `DEFAULT NULL`**。
      Hive 4.2 对 `DEFAULT NULL` 直接报硬错误（建表即失败）：
        SemanticException [Error 10326]: Invalid Constraint syntax
        Invalid type: void for default value: NULL.
      （Hive 的 DEFAULT 必须给一个与列类型兼容的字面量，`NULL` 被解析成 void 类型。）
      此前 79 张 ODS 表能建出来，是因为生成后【手工 sed 删掉】了 DEFAULT NULL —— 
      属运气，不属于设计。这里统一去掉，与上游参考 DDL 的裸写法保持一致。
    """
    from tools.utils.validation import validate_db_identifier

    field_defs = []
    seen = set(existing_names) if existing_names is not None else set()
    for name, ftype, comment in field_specs:
        validate_db_identifier(name, "field name")
        if name in seen:
            continue
        seen.add(name)
        # ★ 2026-10-12（J-05）：Oracle 裸类型归一。甲方 MAPPING 的「目标字段类型」
        #   可能直填 NUMBER(30,8)/char/VARCHAR2(64) 等 Oracle 类型，原样拼进 DDL
        #   会让 CREATE TABLE 直接 ParseException（19 张表 197 列实测）。
        #   归一只针对「非 Hive 合法」类型，已是 DECIMAL(p,s) 的原样保留。
        ftype = normalize_hive_type(ftype, comment)
        # ★ 2026-10-09（J-02）：列名走 quote_hive_column —— Hive 保留字
        #   （TIMESTAMP / EXCHANGE / TIME…）裸写会让 CREATE TABLE 直接 ParseException。
        field_defs.append(
            f"{quote_hive_column(name)}  {ftype} COMMENT '{escape_sql_comment(comment)}'"
        )

    if sys_fields:
        for sf_name, sf_type, sf_cn in sys_fields:
            if sf_name in seen:
                continue
            validate_db_identifier(sf_name, "system field name")
            seen.add(sf_name)
            field_defs.append(
                f"{quote_hive_column(sf_name)}  {sf_type} COMMENT '{escape_sql_comment(sf_cn)}'"
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
