import os

D_BASE = "/mnt/d"
PROJECT_BASE = os.path.join(D_BASE, "项目/信达澳亚数仓/信达澳亚投研数据集市交付文档")
SURVEY_DIR = os.path.join(PROJECT_BASE, "01-系统调研文档")
DWD_MAPPING_BASE = os.path.join(PROJECT_BASE, "04-源与目标映射MAPPING/01-DWD")
DWS_MAPPING_BASE = os.path.join(PROJECT_BASE, "04-源与目标映射MAPPING/02-DWS")

# --- 路径/Schema ---
ODS_SCHEMA_TMPL = "ODS_XDAY_{sys}"
ODS_TABLE_TMPL = "ODS_{sys}"
DWD_SCHEMA = "DWDXDAY"
DWS_SCHEMA = "DWSXDAY"

SUFFIX_FULL = "PFD"
SUFFIX_INCR = "PTD"

SYS_FIELDS_DWD = [
    ("SSYS", "STRING", "源系统"),
    ("SRC_TAB", "STRING", "源表"),
    ("LD_TIME", "STRING", "加载时间"),
    ("MODIFY_TIME", "STRING", "修改时间"),
]

SYS_FIELDS_DWS = [
    ("LD_TIME", "STRING", "加载时间"),
    ("MODIFY_TIME", "STRING", "修改时间"),
]

# --- DDL 常量 ---
DDL_PARTITIONS = "PARTITIONED BY ( P_DT  STRING)"
DDL_ROW_FORMAT = "ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' NULL DEFINED AS '' ;"
DDL_FIELD_PREFIX = "   "
DDL_FIELD_SEP = ",\n"

# 系统字段默认表达式
TIMESTAMP_EXPR = "FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')"

# --- ETL 脚本对齐常量 ---
_AS_POS = 80        # " AS 别名" 起始列
_COMMENT_POS = 120  # "--注释" 起始列
_DEP_TBL_WIDTH = 55  # 依赖声明中表名列宽

# Hive 运行参数
HIVE_SETTINGS = [
    "set hive.exec.dynamic.partition=true;",
    "set hive.exec.dynamic.partition.mode=nonstrict;",
    "set hive.exec.max.dynamic.partitions.pernode=10000;",
    "set hive.exec.max.dynamic.partitions=10000;",
    "set hive.exec.max.created.files=10000;",
    "set mapred.max.split.size=256000000;",
    "set mapred.min.split.size.per.node=100000000;",
    "set mapred.min.split.size.per.rack=100000000;",
    "set hive.merge.mapredfiles=true;",
    "set hive.merge.mapfiles=true;",
    "set hive.merge.smallfiles.avgsize=16000000;",
    "set hive.merge.size.per.task=256000000;",
    "set hive.exec.reducers.bytes.per.reducer=10240000000;",
    "set mapreduce.job.reduces=2;",
]

OUTPUT_BASE = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts")

SYSTEM_ALIAS_MAP = {
    "ZTA": "HSZTA",
    "TA": "HSZTA",
}

DATAX_ORACLE_VARS = {
    "username": "${oracle_username}",
    "password": "${oracle_password}",
    "host": "${oracle_host}",
    "port": "${oracle_port}",
    "sid": "${oracle_sid}",
}

DATAX_HDFS_VARS = {
    "defaultFS": "${hdfs_defaultFS}",
}
