# 数仓代码自动生成项目

## 概述

本项目用于从 Excel 调研文档自动生成数据仓库各层代码，包括建表 DDL、ETL 加工 SQL、血缘关系和数据字典。

## 数仓层级规范

### 命名规范

| 层级 | Schema | 表名格式 | 示例 |
|------|--------|---------|------|
| ODS | `ODS_XDAY_{系统}` | `ODS_{系统}_{表名}_{后缀}` | `ODS_O32_TUNITSTOCK_PFD` |
| DWD | `DWDXDAY` | `DWD_{主题}_{实体}_{后缀}` | `DWD_AST_CRSE_INFO_PFD` |
| DWS | `DWSXDAY` | `DWS_{主题}_{实体}_{后缀}` | `DWS_PROD_SCR_HLDP_DETAIL_PTD` |

### 后缀规则

- `_PFD`: 全量表 (Partition Full Data)
- `_PTD`: 增量表 (Partition Time-slice Data)

### 分区

- 所有表统一使用 `PARTITIONED BY (P_DT STRING)`
- 全量表: 每日快照, 覆盖当天分区
- 增量表: 按增量字段值分区

### ODS 层

- 字段保持源系统英文名不变
- 类型按 Oracle→Hive 映射规则转换
- Schema: `ODS_XDAY_{系统简称}`

### DWD 层

- 字段通过词根库 + MAPPING 命名
- 包含系统字段: SSYS, SRC_TAB, LD_TIME, MODIFY_TIME
- Schema: `DWDXDAY`

### DWS 层

- 源表来自 DWD 层
- 系统字段: LD_TIME, MODIFY_TIME (无 SSYS/SRC_TAB)
- Schema: `DWSXDAY`

## 源系统列表

| 简称 | 全称 | 数据库 | 备注 |
|------|------|--------|------|
| **O32** | 恒生投资交易系统 | ORACLE (schema: FMP) | |
| **HSFA** | 恒生估值系统 | ORACLE | |
| **HSZTA** | 恒生中登份额登记系统 | ORACLE | 标准简称 |
| **HSFTA** | 恒生份额登记系统（分TA） | ORACLE | 目录名 LOFTA 自动映射 |
| **HSDS** | 直销系统 | 数据库 | 目录名 直销 自动映射 |
| **WIND** | 万德数据 | - | |
| **JY** | 聚源数据 | - | 目录名 聚源 自动映射 |
| **OFFW** | 官网数据 | - | 目录名 官网 自动映射 |
| **OA** | OA系统 | - | |

### 系统别名说明

`config.py` 中维护 `SYSTEM_ALIAS_MAP`，自动将调研文档中的历史简称映射到标准简称：

| 历史简称 | 标准简称 | 说明 |
|---------|---------|------|
| `ZTA` | `HSZTA` | 目录名如 `01-ZTA` |
| `TA` | `HSZTA` | DWS 文件如 `TA_DWS_汇总层模型MAPPING.xlsx` |
| `LOFTA` | `HSFTA` | 目录名如 `02-恒生份额登记系统_LOFTA` |
| `直销` | `HSDS` | 目录名如 `05-直销` |
| `聚源` | `JY` | 目录名如 `07-聚源` |
| `官网` | `OFFW` | 目录名如 `08-官网` |

系统在查找 MAPPING 文件/目录时会自动尝试所有别名，无需手动配置。

## 目录结构

```
dw/
├── tools/                    # 核心工具目录
│   ├── config.py            # 全局配置（路径、Schema、系统映射）
│   ├── main.py              # CLI 入口
│   ├── core/                # 中间表示 (IR)
│   │   ├── ir.py           # 数据类定义
│   │   └── type_mapper.py  # Oracle→Hive 类型映射
│   ├── parser/              # 解析器
│   │   ├── table_survey.py # 表级调研 Excel 解析
│   │   ├── field_survey.py # 字段级调研 Excel 解析
│   │   ├── mapping.py      # MAPPING Excel 解析
│   │   └── sys_extractor.py# 系统名提取
│   ├── generator/           # 生成器
│   │   ├── __init__.py     # 工厂函数 create_generator()
│   │   ├── base.py         # 基础生成器（DWD/DWS DDL + ETL）
│   │   ├── ods.py          # ODS 层生成器（DDL + ETL）
│   │   ├── ddl_common.py   # 通用 DDL 构建函数
│   │   ├── lineage.py      # 血缘关系提取与 Excel 生成
│   │   └── data_dict.py    # 数据字典提取与 Excel 生成
│   ├── utils/               # 工具函数
│   │   ├── table_utils.py  # 表字段查询、布尔解析、文件写入
│   │   ├── validation.py   # SQL 注入防护、路径遍历防护
│   │   ├── logging_setup.py# 统一日志系统
│   │   ├── mapping_finder.py# MAPPING 文件/目录查找
│   │   ├── sys_extractor.py# 系统名标准化
│   │   └── pandas_helpers.py# Pandas 安全取值
│   └── tests/               # 单元测试（71 个用例）
├── demo/templates/          # ODS ETL Shell 模板
│   └── etl_ods_template.sh
├── scripts/                 # 生成的脚本输出（gitignored）
├── docs/                    # 文档目录
│   └── 功能与规范文档.md
├── CLAUDE.md                # 项目说明（AI 辅助用，本文件）
├── requirements.txt         # Python 依赖
└── pyproject.toml           # 包管理配置
```

## 关键路径

- 调研文档: `/mnt/d/项目/信达澳亚数仓/信达澳亚投研数据集市交付文档/`
  - `01-系统调研文档/` → ODS 解析来源（9 个系统目录）
  - `04-源与目标映射MAPPING/01-DWD/` → DWD MAPPING 目录
  - `04-源与目标映射MAPPING/02-DWS/` → DWS MAPPING 文件
- 脚本输出: `scripts/{系统}/{层级}/`
- 引擎: `tools/`

## 使用方式

### CLI

```bash
# 全流程生成（自动检测所有系统）
python tools/main.py --layer ALL

# 仅 ODS
python tools/main.py --layer ODS

# 仅 DWD
python tools/main.py --layer DWD

# 仅 DWS
python tools/main.py --layer DWS

# 指定单个系统
python tools/main.py --layer ALL --sys O32

# 自定义输出目录
python tools/main.py --layer ALL --output /custom/output/

# 详细日志
python tools/main.py --layer ALL --verbose
```

### 生成产物

| 产物 | 位置 | 说明 |
|------|------|------|
| 合并 DDL | `{系统}/{层级}/01_ddl.sql` | 所有表的 DDL 合并 |
| 按表 DDL | `{系统}/{层级}/ddl/*.sql` | 每表一个 SQL 文件 |
| ETL Shell | `{系统}/{层级}/etl_sh/*.sh` (ODS) 或 `02_etl/*.sh` (DWD/DWS) | 抽数/加工脚本 |
| 血缘关系 | `{系统}/{层级}/lineage/{layer}_lineage.xlsx` | 表级+字段级血缘 |
| 数据字典 | `{系统}/{层级}/data_dict/{layer}_dict.xlsx` | 字段级数据字典 |
| 汇总字典 | `scripts/数据字典_汇总.xlsx` | 跨系统跨层级汇总 |

### 运行测试

```bash
python3 -m unittest discover -s tools/tests -p "test_*.py"
```

## 调研文档要求

1. **表级调研.xlsx**
   - "源系统英文名"字段须为标准简称之一（或历史别名）
   - "是否保留"字段须填写 `是/Y/y/保留` 才会生成对应脚本

2. **字段级调研.xlsx**
   - "是否入ODS"留空或填 `是/Y/y` 的字段会生成；填 `否/N/n` 的字段跳过
   - "源表名"需与表级调研一致

3. **MAPPING 文件**
   - DWD: 存放于 `01-DWD/{编号}-{系统}/` 子目录
   - DWS: 文件名格式 `{系统}_DWS_*.xlsx`（系统名可用别名，如 `TA_DWS_...`）

## 重要规范

1. **表名生成规则**
   - ODS 表：`ODS_{系统}_{源表名}_{后缀}` （如 `ODS_HSZTA_SCOMBI_PFD`）
   - DWD 表：`DWD_{主题}_{实体}_{后缀}` （如 `DWD_AST_CRSE_INFO_PFD`）

2. **Schema 规则**
   - ODS 层：`ODS_XDAY_{系统}`（如 `ODS_XDAY_HSZTA`）
   - DWD/DWS 层：`DWDXDAY`/`DWSXDAY`（无系统后缀）

3. **文件写入**
   - 普通写入: `tools/utils/table_utils.write_file()`（UTF-8, LF）
   - 安全写入: `tools/utils/table_utils.write_file_safe()`（含错误处理，跳过无效表）
   - 所有生成器统一使用上述工具，禁止直接 `open('w')`

4. **安全验证**
   - SQL 注入防护: `validate_db_identifier()` 验证表名/字段名
   - 路径遍历防护: `validate_output_path()` 验证输出路径
   - 字段名自动修复: `_sanitize_identifier()` 替换非法字符

5. **共享工具**
   - `table_utils.py`: `iter_ods_tables()` 消除重复过滤模式，`parse_bool()` 统一布尔判断
   - `ddl_common.py`: `build_field_defs()` 统一 DDL 字段构建，`generate_ddl_body()` 统一 DDL 主体
   - `mapping_finder.py`: `find_mapping_file/dir()` 单次 scandir 查找
   - `validation.py`: 数据库标识符验证、路径遍历防护
   - `logging_setup.py`: 统一日志格式、第三方库降噪