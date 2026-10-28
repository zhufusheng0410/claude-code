import os

# 路径支持环境变量覆盖，便于跨平台（WSL/Windows 原生/macOS/Linux）部署
D_BASE = os.environ.get("DW_D_BASE", "/mnt/d")
PROJECT_BASE = os.environ.get(
    "DW_PROJECT_BASE",
    os.path.join(D_BASE, "项目/信达澳亚数仓/信达澳亚投研数据集市交付文档"),
)
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

# ★ 2026-09-28 新增：ODS 层的系统字段。
#   为什么需要它：ODS 的 ETL 生成器（ods.py::generate_ods_etl）在 INSERT … SELECT 末尾
#   【恒定追加】一列 LD_TIME（加载时间），但 generate_ods_ddl 此前【不追加任何系统字段】，
#   导致「建表列数 = 业务列数(42)」而「SELECT 列数 = 业务列数 + 1(43)」，
#   执行时报：
#     SemanticException [Error 10044]: Cannot insert into target table because
#     column number/types are different: Table insclause-0 has 42 columns,
#     but query has 43 columns.
#   参考生产 DWD 建表脚本（05-脚本/01-建表语句/01-DWD建表脚本.sql）的约定，
#   ODS 只需 LD_TIME（不需要 SSYS/SRC_TAB/MODIFY_TIME 这三列）。
#   改这里 = 让 ODS 目标表列数与 ETL 的 SELECT 列数对齐。
SYS_FIELDS_ODS = [
    ("LD_TIME", "STRING", "加载时间"),
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
AS_POS = 80        # " AS 别名" 起始列
COMMENT_POS = 120  # "--注释" 起始列
DEP_TBL_WIDTH = 55  # 依赖声明中表名列宽

# ★★★ 2026-10-10 新增：Hive 4.x **兼容性开关**（必须放在最前面，set 顺序即作用域）
#
# `hive.strict.checks.type.safety` 默认 false，但本集群开了严格模式
# ⇒ 任何「非 STRING 列 vs 字符串字面量」的比较都会报
#   `SemanticException [Error 10014] Wrong arguments ''20261009'':
#    Unsafe compares between different types are disabled`
# 真实踩坑（18:53 实测）：`ODS_OA_COMM_REGION_HIERARCHY_PFD.effective_from` 是
# **`decimal(8,0)`**，而 MAPPING 的过滤条件写的是「拉链区间 vs 当前分区日期」：
#       AND T1.EFFECTIVE_FROM <= '${p_end_dt}'
# ⇒ decimal 与 string 比较 ⇒ 10014。逐列改类型不可行（列类型因表而异，
#   有 decimal / string / timestamp），**放宽这两个开关是唯一稳定解**。
# 这也是甲方/行业惯例的 ETL 头；**Hive 4.0+ 行为一致**。
HIVE_COMPAT_SETTINGS = [
    "set hive.strict.checks.type.safety=false;",
    "set hive.mapred.mode=nonstrict;",
]

# Hive 动态分区参数（ODS 增量表 ETL 与 DWD/DWS ETL 共用，避免两处硬编码漂移）
HIVE_DYNAMIC_PARTITION_SETTINGS = [
    "set hive.exec.dynamic.partition=true;",
    "set hive.exec.dynamic.partition.mode=nonstrict;",
    "set hive.exec.max.dynamic.partitions.pernode=10000;",
    "set hive.exec.max.dynamic.partitions=10000;",
    "set hive.exec.max.created.files=10000;",
]

# Hive 运行参数
HIVE_SETTINGS = HIVE_COMPAT_SETTINGS + HIVE_DYNAMIC_PARTITION_SETTINGS + [
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

# 代码字段关键词（用于 type_mapper.py 中的 _is_code_field 判断）
CODE_FIELD_KEYWORDS = ("代码", "编码", "编号", "标志", "标识", "类型", "分类", "方向")

SYSTEM_ALIAS_MAP = {
    "ZTA": "HSZTA",
    "TA": "HSZTA",
    "LOFTA": "HSFTA",
    "直销": "HSDS",
    "聚源": "JY",
    "官网": "OFFW",
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

# 全局表名中文名映射（用于血缘关系中子查询展开时的中文名回退）
# 优先级：非子查询映射 > 此全局映射 > 子查询的 src_table_cn
# 键同时支持 带 schema 全名 和 裸表名（内部对裸表名也建索引）
GLOBAL_TABLE_CN_MAP = {
    # ODS 层常用表
    "ODS_HSFA_TZQXX_PFD": "证券信息表",
    "ODS_HSFA_TVOUCHER_PTD": "凭证主表",
    "ODS_HSFA_TVOUCHERS_PTD": "凭证子表",
    "ODS_HSFA_TSYSINFO_PFD": "系统信息表",
    "ODS_HSFA_TACCOUNT_HS_PFD": "账套科目表",
    "ODS_HSFA_TFUNDINFO_PFD": "基金信息表",
    "ODS_HSFA_TACCOUNT_PFD": "账户表",
    "ODS_HSFA_TTRADEDATE_PFD": "交易日历表",
    "ODS_HSFA_TVOUCHERSJC_PTD": "月度余额表",
    # DWD/DWS 公共表
    "DWD_CMM_STD_DICT_CDVAL_MAP": "标准字典码值映射",
    "DWD_CMM_STD_DICT_CLS_EMRT_INFO": "标准字典分类枚举信息",
    "DWD_CMM_CALENDAR_INFO_PFD": "日历信息",
    # DWD 业务表（子查询中常见，补充中文名）
    "DWD_EVT_BOND_TRAN_BUSIN_PTD": "债券交易业务",
    "DWD_EVT_DPSI_BILL_BUSIN_PTD": "存款票据业务",
    "DWD_EVT_EQUI_JOUR_INFO_PTD": "权益流水信息",
    "DWD_EVT_FIN_INV_BUSIN_PTD": "理财交易业务",
    "DWD_EVT_FUND_TRAN_BUSIN_PTD": "基金交易业务",
    # OA / OFFW 表
    "ODS_OA_AGENCY_VIEW_PFD": "渠道解析规则",
    "ODS_OA_IP_AGENCY_HIERARCHY_PFD": "网点区域信息",
    "ODS_OFFW_WN_FUND_MANAGER_PFD": "基金经理信息",
    "ODS_OFFW_WN_FUND_MANAGER_FUND_PFD": "官网基金经理",
}
