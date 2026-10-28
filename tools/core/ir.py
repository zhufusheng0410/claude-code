from dataclasses import dataclass, field

@dataclass
class TableMeta:
    """表级元数据，来自表级调研"""
    src_sys: str = ""
    src_db_type: str = ""
    src_schema: str = ""
    src_table: str = ""          # 表级调研「表英文名」(col4) —— 字段级调研的 join key，勿改
    src_table_phys: str = ""     # ★ 2026-10-08 新增：实际取数的源物理表名。
                                 #   规则：调研人(col22) 非空时取调研人，否则取 src_table。
                                 #   用途：ODS 抽数脚本 `FROM <src_schema>.<表>`。
                                 #   与 src_table 分开的原因：字段级调研恒以「表英文名」(col4) 为键，
                                 #   而 O32/HSFA 的调研人在 561+6 行里填的是真实归档表名
                                 #   （TUNITSTOCK → THISUNITSTOCK、TCJHB → T_H_CJHB），
                                 #   两者不可混用：字段查找用 src_table（否则查不到字段），
                                 #   取数用 src_table_phys（否则抽错表）。
    src_table_cn: str = ""
    ods_table: str = ""
    load_strategy: str = ""      # FULL / INCR
    incr_cond: str = ""
    incr_cond_format: str = ""
    is_partition: str = ""
    storage_period: str = ""
    topic: str = ""
    table_rows: str = ""
    is_reserved: str = ""        # 是否保留（表级）

@dataclass
class FieldMeta:
    """字段级元数据，来自字段级调研"""
    ordinal: float = 0.0
    src_name: str = ""
    src_name_cn: str = ""
    src_name_cn_note: str = ""
    src_type: str = ""
    hive_type: str = ""
    is_nullable: str = ""
    is_pk: str = ""
    is_biz_pk: str = ""
    is_fk: str = ""
    default_val: str = ""
    is_ods: str = ""
    is_reserved: str = ""
    sample_data: str = ""
    null_rate: str = ""
    is_code_field: str = ""
    code_val: str = ""

@dataclass
class MappingRule:
    """单个字段映射规则，来自 MAPPING Excel"""
    tgt_name: str = ""
    tgt_name_cn: str = ""
    tgt_type: str = ""
    tgt_ordinal: float = 0.0
    is_pk: str = ""
    group_no: str = ""
    src_field_alias: str = ""
    src_table_alias: str = ""
    src_table_name: str = ""     # 源表英文名 (e.g. ODS_XDAY_O32.ODS_O32_TUNITSTOCK_PFD)
    src_table_cn: str = ""       # 源表中文名
    src_field_name: str = ""     # 源字段英文名 (e.g. L_DATE)
    src_field_cn: str = ""       # 源字段中文名
    src_field_type: str = ""     # 源字段类型 (e.g. NUMBER(10,0) / STRING)，J-29 用于 UNION 类型对齐
    join_type: str = ""          # MAIN TABLE / LEFT JOIN
    join_cond: str = ""
    filter_cond: str = ""
    note: str = ""

@dataclass
class MappingSheet:
    """一个 MAPPING sheet 页的完整信息"""
    tgt_table_cn: str = ""
    tgt_table: str = ""
    func_desc: str = ""
    partition_col: str = "p_dt"
    param: str = "p_batch_dt"
    frequency: str = "D"
    tgt_table_type: str = ""
    load_type: str = ""
    incr_logic: str = ""
    mappings: list = field(default_factory=list)
    source_tables: list = field(default_factory=list)


