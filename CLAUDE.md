# 数仓代码自动生成项目

## 概述

本项目用于从 Excel 调研文档自动生成数据仓库各层代码，包括建表 DDL、DataX 抽数脚本和 ETL 加工 SQL。

## 技术架构

- Python 3 + pandas + openpyxl
- 解析器(Parser) → 中间表示(IR) → 生成器(Generator)
- CLI 入口: `python tools/main.py --layer ALL`（系统自动检测）
- CC Skill: `/generate-dw`（代码生成）、`/generate-dict`（数据字典）

### 核心模块

| 模块 | 文件 | 职责 |
|------|------|------|
| CLI 入口 | `tools/main.py` | 参数解析、系统发现、流程编排 |
| 配置 | `tools/config.py` | 路径、Schema、别名、字段定义 |
| IR 数据类 | `tools/core/ir.py` | TableMeta, FieldMeta, MappingRule, MappingSheet |
| 类型映射 | `tools/core/type_mapper.py` | Oracle→Hive 类型转换 |
| Excel 解析 | `tools/parser/` | 表级/字段级调研解析、MAPPING 解析 |
| 代码生成 | `tools/generator/` | ODS/DWD/DWS DDL+ETL、DataX 配置 |
| 共享工具 | `tools/utils/` | 别名查找、文件写入、输入验证、日志 |
| 血缘生成 | `tools/generator/lineage.py` | 从 MAPPING 提取表级+字段级血缘，输出 Excel |
| 数据字典 | `tools/generator/data_dict.py` | 汇总三层表+字段元数据，输出 Excel（分层+汇总） |

## 目录结构

```
tools/
├── main.py              # CLI 入口，驱动全流程
├── config.py            # 路径、Schema、别名配置
├── core/                # IR 数据类 + 类型映射
├── parser/              # Excel 解析器 (ODS/DWD/DWS)
├── generator/           # 代码生成器 (ODS/DWD/DWS/DataX)
└── utils/               # 共享工具 (mapping_finder, table_utils…)
scripts/
├── {系统}/{层级}/       # 生成的 DDL/ETL 脚本输出目录
│   ├── lineage/         # 血缘 Excel
│   └── data_dict/       # 单层数据字典 Excel
└── 数据字典_汇总.xlsx   # 跨系统跨层级汇总字典
demo/templates/          # ETL shell 脚本模板
```

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

## Oracle → Hive 类型映射

| Oracle | Hive |
|--------|------|
| VARCHAR2/CHAR/CLOB | STRING |
| NUMBER(p,s) s>0 | DECIMAL(p,s) 保留原始精度 |
| NUMBER(p,0) 整数含义 | DECIMAL(p,0) 保留原始精度 |
| NUMBER(p,0) 代码含义 | STRING |
| DATE/TIMESTAMP | STRING |
| FLOAT/BINARY_FLOAT/BINARY_DOUBLE | DECIMAL(18,2) |
| INTEGER/INT | DECIMAL(8,0) |
| RAW/BLOB | STRING |

## 源系统列表

| 简称 | 全称 | 数据库 | 备注 |
|------|------|--------|------|
| **O32** | 恒生投资交易系统 | ORACLE (schema: FMP) | |
| **HSFA** | 恒生估值系统 | ORACLE | |
| **HSZTA** | 恒生中登份额登记系统 | ORACLE | 标准简称 |
| **LOFTA** | 恒生份额登记系统 | ORACLE | |

### 系统别名说明

`config.py` 中维护 `SYSTEM_ALIAS_MAP`，自动将调研文档中的历史简称映射到标准简称：

| 历史简称 | 标准简称 | 说明 |
|---------|---------|------|
| `ZTA` | `HSZTA` | 目录名如 `01-ZTA` |
| `TA` | `HSZTA` | DWS 文件如 `TA_DWS_汇总层模型MAPPING.xlsx` |

系统在查找 MAPPING 文件/目录时会自动尝试所有别名，无需手动配置。

## 关键路径

- 调研文档: `/mnt/d/项目/信达澳亚数仓/信达澳亚投研数据集市交付文档/`
  - `01-系统调研文档/` → ODS 解析来源
  - `04-源与目标映射MAPPING/01-DWD/` → DWD MAPPING 目录
  - `04-源与目标映射MAPPING/02-DWS/` → DWS MAPPING 文件
- 脚本输出: `scripts/{系统}/{层级}/`
- 引擎: `tools/`

## 使用方式

### CLI

```bash
# 全流程生成（自动检测系统）
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
```

### 参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--layer` | `ALL` | 生成层级: `ODS` / `DWD` / `DWS` / `ALL` |
| `--sys` | 自动发现 | 指定系统简称，如 `O32`、`HSFA`、`ZTA` |
| `--output` | `scripts/` | 脚本输出根目录 |
| `--verbose` / `-v` | 关闭 | 输出 DEBUG 级别详细日志 |

### CC Skill

```
/generate-dw --sys O32 --layer ALL
/generate-dw --sys HSFA --layer DWD
```

数据字典（随代码生成一并产出，也可单独用 skill 说明触发）：

```
/generate-dict --sys O32 --layer ALL
/generate-dict --layer ALL
```

## 调研文档要求

1. **表级调研.xlsx**
   - "源系统英文名"字段须为 **HSZTA/HSFA/O32/LOFTA** 之一（或历史别名 ZTA/TA）
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

4. **血缘关系**
   - 自动生成 JSON 格式的表级+字段级血缘
   - 输出位置: `scripts/{系统}/{层级}/lineage/{layer}_tables.json`（表级）
   - 字段级: `scripts/{系统}/{层级}/lineage/{layer}_fields.json`
   - 表级血缘包含：目标表、中文名、层级、系统、上游表列表
   - 字段级血缘包含：目标字段、源字段、映射规则/表达式、JOIN方式、过滤条件

4. **代码生成器**
   - ODS: `tools/generator/ods.py`（独立函数，使用 `iter_ods_tables`）
   - DWD/DWS: `tools/generator/base.py`（`BaseGenerator` 类，使用 `write_file_safe`）
   - DataX: `tools/generator/datax.py`（生成 JSON 配置）

5. **共享工具**
   - `table_utils.py`: `iter_ods_tables()` 消除 4 处重复过滤模式
   - `mapping_finder.py`: `find_mapping_file/dir()` 单次 scandir 查找
   - `validation.py`: 数据库标识符验证、路径遍历防护
   - `logging_setup.py`: 统一日志格式、第三方库降噪
