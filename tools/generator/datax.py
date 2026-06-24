import json
import os
from ..core.ir import TableMeta, FieldMeta
from ..config import DATAX_ORACLE_VARS, DATAX_HDFS_VARS, ODS_SCHEMA_TMPL
from ..core.type_mapper import oracle_to_hive
from tools.utils.table_utils import find_fields_by_table, filter_ods_fields, is_table_reserved, write_file
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)


def generate_datax(table: TableMeta, fields: list, sys_name: str = "O32") -> str:
    """生成单张表的 DataX JSON 配置"""
    schema = ODS_SCHEMA_TMPL.format(sys=sys_name)

    reader_columns = []
    writer_columns = []
    for f in fields:
        reader_columns.append(f.src_name)
        hive_type = f.hive_type if f.hive_type else oracle_to_hive(f.src_type, f.src_name_cn)
        writer_columns.append({"name": f.src_name, "type": hive_type})

    where_clause = ""
    if table.load_strategy == "INCR" and table.incr_cond:
        incr = table.incr_cond.strip()
        if incr and incr not in ('无', 'nan', ''):
            where_clause = f"{incr} >= '${{start_date}}' AND {incr} < '${{end_date}}'"

    write_mode = "truncate" if table.load_strategy == "FULL" else "append"

    job = {
        "job": {
            "setting": {"speed": {"channel": 5}},
            "content": [{
                "reader": {
                    "name": "oraclereader",
                    "parameter": {
                        "username": DATAX_ORACLE_VARS["username"],
                        "password": DATAX_ORACLE_VARS["password"],
                        "connection": [{
                            "jdbcUrl": [f"jdbc:oracle:thin:@{DATAX_ORACLE_VARS['host']}:{DATAX_ORACLE_VARS['port']}:{DATAX_ORACLE_VARS['sid']}"],
                            "table": [f"{table.src_schema}.{table.src_table}"]
                        }],
                        "where": where_clause,
                        "column": reader_columns
                    }
                },
                "writer": {
                    "name": "hdfswriter",
                    "parameter": {
                        "defaultFS": DATAX_HDFS_VARS["defaultFS"],
                        "fileType": "text",
                        "path": f"/user/hive/warehouse/{schema}.db/{table.ods_table}/p_dt=${{batch_dt}}",
                        "fileName": table.ods_table,
                        "column": writer_columns,
                        "writeMode": write_mode,
                        "fieldDelimiter": "\t",
                        "nullFormat": ""
                    }
                }
            }]
        }
    }
    return json.dumps(job, indent=2, ensure_ascii=False)


def generate_all_datax(tables: list, fields_by_table: dict, output_dir: str, sys_name: str = "O32"):
    """为所有表生成 DataX JSON 文件"""
    datax_dir = os.path.join(output_dir, "datax")
    os.makedirs(datax_dir, exist_ok=True)

    generated = 0
    for table in tables:
        if not is_table_reserved(table):
            continue

        tbl_fields = find_fields_by_table(table.src_table, fields_by_table)
        if not tbl_fields:
            logger.debug(f"  [DataX] 跳过 {table.ods_table}: 无字段信息")
            continue

        ods_fields = filter_ods_fields(tbl_fields)
        json_str = generate_datax(table, ods_fields, sys_name)
        filepath = os.path.join(datax_dir, f"{table.ods_table}.json")
        write_file(filepath, json_str)
        generated += 1

    logger.info(f"  DataX JSON → {datax_dir}/ ({generated} 个.json)")
