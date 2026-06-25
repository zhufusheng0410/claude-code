import os

D_BASE = "/mnt/d"
PROJECT_BASE = os.path.join(D_BASE, "项目/信达澳亚数仓/信达澳亚投研数据集市交付文档")
SURVEY_DIR = os.path.join(PROJECT_BASE, "01-系统调研文档")
DWD_MAPPING_BASE = os.path.join(PROJECT_BASE, "04-源与目标映射MAPPING/01-DWD")
DWS_MAPPING_BASE = os.path.join(PROJECT_BASE, "04-源与目标映射MAPPING/02-DWS")

ODS_SCHEMA_TMPL = "ODS_XDAY_{sys}"
ODS_TABLE_TMPL = "ODS_{sys}"
DWD_SCHEMA = "DWDXDAY"
DWS_SCHEMA = "DWSXDAY"

SUFFIX_FULL = "PFD"
SUFFIX_INCR = "PTD"

SYSTEM_ALIAS_MAP = {
    "ZTA": "HSZTA",
    "TA": "HSZTA",
}

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

OUTPUT_BASE = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts")

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
