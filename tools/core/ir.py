from dataclasses import dataclass, field

@dataclass
class TableMeta:
    """表级元数据，来自表级调研"""
    src_sys: str = ""
    src_db_type: str = ""
    src_schema: str = ""
    src_table: str = ""
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
