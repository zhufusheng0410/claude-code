import os
import json
from ..core.ir import TableMeta, FieldMeta
from ..config import ODS_SCHEMA_TMPL
from ..core.type_mapper import oracle_to_hive
from tools.utils.table_utils import find_fields_by_table, filter_ods_fields, is_table_reserved, write_file
from tools.utils.validation import validate_db_identifier
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)


# ============================================================================
# DDL 生成函数 (保持不变)
# ============================================================================

def generate_ods_ddl(table: TableMeta, fields: list, sys_name: str) -> str:
    """生成单张 ODS 表的建表 DDL"""
    schema = ODS_SCHEMA_TMPL.format(sys=sys_name)
    tbl = f"{schema}.{table.ods_table}"

    # 验证表名安全性，防止 SQL 注入
    validate_db_identifier(table.ods_table, "ODS table name")

    field_defs = []
    for f in fields:
        # 验证字段名安全性
        validate_db_identifier(f.src_name, "field name")
        hive_type = f.hive_type if f.hive_type else "STRING"
        comment = f.src_name_cn if f.src_name_cn else ""
        comment = comment.replace("'", "''")
        field_defs.append(f"   {f.src_name}  {hive_type} DEFAULT NULL COMMENT '{comment}'")

    lines = [
        f"DROP TABLE IF EXISTS {tbl};",
        f"CREATE TABLE {tbl} (",
        ",\n".join(field_defs),
        ")",
        f"COMMENT '{table.src_table_cn}'",
        "PARTITIONED BY ( P_DT  STRING)",
        "ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' NULL DEFINED AS '' ;",
    ]
    return "\n".join(lines)


def generate_all_ods_ddl(tables: list, fields_by_table: dict, sys_name: str) -> str:
    """生成所有 ODS 建表 DDL（合并为一个 SQL 文件）"""
    schema = ODS_SCHEMA_TMPL.format(sys=sys_name)
    parts = [
        "-- ============================================",
        f"-- ODS 层建表语句 - 系统: {sys_name}",
        f"-- Schema: {schema}",
        "-- ============================================\n",
    ]

    for table in tables:
        # 筛选：只有"是否保留"为"是"的表才生成
        if not is_table_reserved(table):
            continue

        tbl_fields = find_fields_by_table(table.src_table, fields_by_table)
        if not tbl_fields:
            continue

        ods_fields = filter_ods_fields(tbl_fields)
        parts.append(generate_ods_ddl(table, ods_fields, sys_name))
        parts.append("")

    return "\n".join(parts)



def generate_all_ods_ddl_files(tables: list, fields_by_table: dict, output_dir: str, sys_name: str):
    """按表生成独立的 DDL SQL 文件"""
    ddl_dir = os.path.join(output_dir, "ddl")
    os.makedirs(ddl_dir, exist_ok=True)
    for table in tables:
        # 筛选：只有"是否保留"为"是"的表才生成
        if not is_table_reserved(table):
            continue

        tbl_fields = find_fields_by_table(table.src_table, fields_by_table)
        if not tbl_fields:
            continue
        ods_fields = filter_ods_fields(tbl_fields)
        filepath = os.path.join(ddl_dir, table.ods_table + ".sql")
        try:
            ddl_sql = generate_ods_ddl(table, ods_fields, sys_name)
            write_file(filepath, ddl_sql)
        except ValueError as e:
            # 验证失败，跳过此表
            logger.error(f"  ERROR: Skipping table '{table.ods_table}': {e}")
            continue
        except IOError as e:
            logger.error(f"  ERROR: Failed to write DDL file {filepath}: {e}")
            raise



# ============================================================================
# ETL 生成函数 (使用模板)
# ============================================================================

def _load_etl_template() -> str:
    """读取 ODS ETL shell 脚本模板，失败则抛出明确错误"""
    template_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
        'demo', 'templates', 'etl_ods_template.sh'
    )
    try:
        with open(template_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        raise FileNotFoundError(
            f"ETL template file not found: {template_path}. "
            "Please ensure the 'demo/templates' directory exists in the project root."
        )
    except IOError as e:
        raise IOError(f"Failed to read ETL template from {template_path}: {e}")


def generate_ods_etl(table: TableMeta, fields: list, sys_name: str, template: str) -> str:
    """生成完整的 ODS 抽数 shell 脚本，使用模板"""
    schema = ODS_SCHEMA_TMPL.format(sys=sys_name)
    tbl = table.ods_table
    # 验证表名安全性
    validate_db_identifier(table.ods_table, "ODS table name")
    tmp_tbl = tbl + "_TMP"

    # 临时表字段定义
    tmp_field_defs = []
    for f in fields:
        # 验证字段名安全性
        validate_db_identifier(f.src_name, "field name")
        hive_type = f.hive_type if f.hive_type else oracle_to_hive(f.src_type, f.src_name_cn)
        comment = f.src_name_cn if f.src_name_cn else ""
        tmp_field_defs.append(f"  {f.src_name}  {hive_type}  COMMENT  '{comment}'")
    tmp_fields_str = ",\n".join(tmp_field_defs)

    # DataX query_sql
    select_parts = [f"SELECT  {fields[0].src_name}"]
    for f in fields[1:]:
        select_parts.append(f"                                   , {f.src_name}")
    select_str = "\n".join(select_parts)

    from_where_clause = ""
    # 动态生成源schema变量名：如 o32_src_schema, zta_src_schema, hszta_src_schema
    src_schema_var = f"{sys_name.lower()}_src_schema"
    if table.load_strategy == "INCR" and table.incr_cond:
        incr = table.incr_cond.strip()
        if incr and incr not in ('无', 'nan', ''):
            from_where_clause = f"\n                                FROM ${{{src_schema_var}}}.{table.src_table}\n                                WHERE {incr}  between ${{p_start_dt}} and ${{p_end_dt}}"
        else:
            from_where_clause = f"\n                                FROM ${{{src_schema_var}}}.{table.src_table}"
    else:
        from_where_clause = f"\n                                FROM ${{{src_schema_var}}}.{table.src_table}"

    query_sql = select_str + from_where_clause

    # writer columns
    writer_columns = []
    for f in fields:
        dx_type = _datax_type(f.src_type, f.src_name_cn)
        writer_columns.append({"name": f.src_name, "type": dx_type})

    # SELECT 字段列表（用于INSERT）
    select_lines = ["       " + fields[0].src_name]
    for f in fields[1:]:
        select_lines.append("     , " + f.src_name)
    select_lines.append("     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME")
    select_columns_str = "\n".join(select_lines)

    # 动态SET语句（增量表需要）
    dynamic_sets = "" if table.load_strategy == "FULL" else (
        "set hive.exec.dynamic.partition=true;\n"
        "set hive.exec.dynamic.partition.mode=nonstrict;\n"
        "set hive.exec.max.dynamic.partitions.pernode=10000;\n"
        "set hive.exec.max.dynamic.partitions=10000;\n"
        "set hive.exec.max.created.files=10000;"
    )

    # 分区子句
    partition_clause = "PARTITION(P_DT='${p_end_dt}')" if table.load_strategy == "FULL" else "PARTITION(P_DT)"

    # 填充模板变量
    filled = template.replace("${target_schema}", schema)
    filled = filled.replace("${tmp_table}", tmp_tbl)  # 仅表名，模板会拼接 schema
    filled = filled.replace("${tmp_table_name}", tmp_tbl.lower())
    filled = filled.replace("${tmp_field_defs}", tmp_fields_str)
    filled = filled.replace("${table_cn}", table.src_table_cn or "")
    filled = filled.replace("${query_sql}", query_sql)
    filled = filled.replace("${writer_columns}", json.dumps(writer_columns, ensure_ascii=False))
    filled = filled.replace("${dynamic_sets}", dynamic_sets)
    filled = filled.replace("${target_table}", tbl)
    filled = filled.replace("${partition_clause}", partition_clause)
    filled = filled.replace("${select_columns}", select_columns_str)

    return filled


def generate_all_ods_etl(tables: list, fields_by_table: dict, output_dir: str, sys_name: str):
    """按表生成独立的 ETL shell 脚本"""
    etl_dir = os.path.join(output_dir, "etl_sh")
    os.makedirs(etl_dir, exist_ok=True)
    template = _load_etl_template()
    for table in tables:
        # 筛选：只有"是否保留"为"是"的表才生成
        if not is_table_reserved(table):
            continue

        tbl_fields = find_fields_by_table(table.src_table, fields_by_table)
        if not tbl_fields:
            continue
        ods_fields = filter_ods_fields(tbl_fields)
        filepath = os.path.join(etl_dir, table.ods_table + ".sh")
        try:
            script = generate_ods_etl(table, ods_fields, sys_name, template)
            write_file(filepath, script)
        except ValueError as e:
            # 验证失败，跳过此表
            logger.error(f"  ERROR: Skipping table '{table.ods_table}': {e}")
            continue
        except IOError as e:
            logger.error(f"  ERROR: Failed to write ETL script {filepath}: {e}")
            raise


def _datax_type(src_type: str, field_cn: str = "") -> str:
    """DataX column type: 参照参考脚本统一用 DOUBLE 或 STRING"""
    if not src_type:
        return "STRING"
    t = src_type.upper().strip()
    if any(t.startswith(x) for x in ("NUMBER", "FLOAT", "BINARY_FLOAT", "BINARY_DOUBLE", "INTEGER", "INT")):
        return "DOUBLE"
    return "STRING"
