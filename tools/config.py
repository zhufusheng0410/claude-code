import os

# ── 输入根目录探测（2026-10-29）──────────────────────────────────────────────
# 历史写法：`D_BASE = os.environ.get("DW_D_BASE", "/mnt/d")`。
# 为什么必须改：本项目在 **Windows 原生 Python** 下运行时，`/mnt/d` 会被解析成
# `C:\mnt\d`（本机恰好残留了这个镜像目录，`os.path.isdir("/mnt/d")` 返回 True），
# 于是「路径看起来存在、其实读不到项目交付文档」——生成器拿空目录静默跑出空表。
# ⇒ 改为**按「交付文档目录是否真的存在」探测**，而不是只探 D 盘根。
#   探测优先级：DW_D_BASE 显式覆盖 > Windows 盘符 > POSIX 挂载点；首个能命中
#   `<根>/项目/信达澳亚数仓/信达澳亚投研数据集市交付文档` 的胜出。
_PROJECT_REL = os.path.join("项目", "信达澳亚数仓", "信达澳亚投研数据集市交付文档")


def _detect_d_base():
    """探测 D 盘根：显式环境变量优先，否则取首个能命中交付文档目录的候选。

    全都不命中时返回首选候选，由 missing_inputs() 给出可读报错。
    """
    env = os.environ.get("DW_D_BASE")
    if env:
        return env          # 用户显式指定，不再猜测
    cands = ["D:/", "E:/"] if os.name == "nt" else ["/mnt/d", "/d", "/data"]
    for c in cands:
        if os.path.isdir(os.path.join(c, _PROJECT_REL)):
            return c
    return cands[0]


D_BASE = _detect_d_base()
PROJECT_BASE = os.path.normpath(
    os.environ.get("DW_PROJECT_BASE") or os.path.join(D_BASE, _PROJECT_REL))

SURVEY_DIR = os.path.join(PROJECT_BASE, "01-系统调研文档")
DWD_MAPPING_BASE = os.path.join(PROJECT_BASE, "04-源与目标映射MAPPING/01-DWD")
DWS_MAPPING_BASE = os.path.join(PROJECT_BASE, "04-源与目标映射MAPPING/02-DWS")


def missing_inputs(layers=None):
    """返回「输入目录缺失」的可读说明列表（空列表 = 输入齐全）。

    生成器启动时调用。区别于让下游 `os.listdir` 抛异常或读到空 Excel：
    这里直接告诉用户**该设哪个环境变量、指向哪里**。

    ★ 2026-11-09（评审 A2）：新增 `layers` 过滤。原先**无条件**检查 3 个目录，
      于是 `--layer ODS`（只需要调研文档）在「只交付了一半目录」的机器上
      被无关的 DWD/DWS MAPPING 目录拦住（实测返回 2 条无关问题并 exit 1）。
      按需检查：ODS 只查调研目录，DWD 另查 DWD MAPPING，DWS 另查 DWS MAPPING。
    layers: None/'ALL' = 全部检查；'ODS'/'DWD'/'DWS'（或它们的集合）= 按层查。
    """
    if layers is None:
        want = {"ODS", "DWD", "DWS"}
    elif isinstance(layers, str):
        want = {"ALL": {"ODS", "DWD", "DWS"}}.get(layers.upper(), {layers.upper()})
    else:
        want = {str(x).upper() for x in layers} - {""}
        if "ALL" in want:
            want |= {"ODS", "DWD", "DWS"}
    problems = []
    if not os.path.isdir(PROJECT_BASE):
        problems.append(
            "交付文档根目录不存在: %s\n"
            "  ⇒ 请设置 DW_D_BASE 指向 D 盘根（Windows 用 'D:/'，WSL 用 '/mnt/d'），\n"
            "    或设置 DW_PROJECT_BASE 直接指向交付文档目录"
            % PROJECT_BASE)
        return problems          # 根都没有，再谈子目录没意义
    checks = [("调研文档目录", SURVEY_DIR, "ODS")]
    if "DWD" in want:
        checks.append(("DWD MAPPING 目录", DWD_MAPPING_BASE, "DWD"))
    if "DWS" in want:
        checks.append(("DWS MAPPING 目录", DWS_MAPPING_BASE, "DWS"))
    for label, p, _need in checks:
        if not os.path.isdir(p):
            problems.append("%s 不存在: %s" % (label, p))
    return problems

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
