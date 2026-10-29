# Code Wiki — 数仓代码自动生成项目

> 本文件是仓库级代码维基，覆盖：整体架构、模块职责、关键类与函数、依赖关系、运行方式。
> 口径类规范以 [AGENTS.md](../AGENTS.md) / `CLAUDE.md` 为准；本文件只描述**代码结构与用法**。

---

## 1. 项目概述

**dw-generator**（`pyproject.toml` 包名，v0.1.0）是一个从 **Excel 调研文档 / MAPPING 文档** 自动生成
数据仓库各层代码的 Python 工具集，覆盖三层：

| 层 | 输入 | 产物 | Schema |
|---|---|---|---|
| **ODS** | `01-系统调研文档/{系统}/01-表级调研.xlsx` + `02-字段级调研.xlsx` | 建表 DDL、DataX 抽数 Shell（`etl_sh/`）、数据字典 | `ODS_XDAY_{系统}` |
| **DWD** | `04-源与目标映射MAPPING/01-DWD/{编号}-{系统}/` 或甲方 txt 脚本 | 建表 DDL、ETL Shell（`02_etl/`）、血缘 xlsx、依赖配置 | `DWDXDAY` |
| **DWS** | `04-源与目标映射MAPPING/02-DWS/{系统}_DWS_*.xlsx` 或甲方 txt 脚本 | 同 DWD | `DWSXDAY` |

统一分区 `PARTITIONED BY (P_DT STRING)`；表名后缀 `_PFD`（全量快照）/ `_PTD`（增量）。

产物进一步通过 `tools/ds-deploy/` 工具链部署到本机 **DolphinScheduler 3.4.2**（项目 `dw`），
SQL 拿到本机 docker **Hive 4.2**（`hiveserver2`）做编译校验与真实执行。

---

## 2. 整体架构

### 2.1 分层数据流

```
                    ┌──────────────────────────────────────────────┐
   Excel 输入        │                tools/ (核心引擎)              │      输出
 ┌────────────────┐  │  ┌─────────┐   ┌──────────┐   ┌───────────┐  │  ┌─────────────────────┐
 │ 表级/字段级调研  │─▶│ parser/  │──▶│ core/ IR │──▶│generator/ │─▶│  │ scripts/{系统}/{层}/  │
 │ DWD/DWS MAPPING│  │ (Excel解析)│   │(dataclass)│   │ DDL/ETL/  │  │  │  ├ 01_ddl.sql        │
 └────────────────┘  └─────────┘   └──────────┘   │ 血缘/字典  │  │  │  ├ ddl/*.sql         │
        ▲                 │                        └───────────┘  │  │  ├ 02_etl|etl_sh/*.sh│
        │                 └── utils/ (安全写入、类型映射、查找、日志) ─┘  │  ├ lineage/*_lineage.xlsx│
        │                                                            │  └ data_dict/*_dict.xlsx│
   config.py (路径/Schema/系统别名/Hive参数 全局配置)                    │  └ 数据字典_汇总.xlsx   │
                                                                      └─────────────────────┘
                                                                            │
        ┌───────────────────────────────────────────────────────────────────┘
        ▼
 ┌─────────────┐   血缘 xlsx    ┌────────────────────┐   JSON/HTTP   ┌──────────────────┐
 │ 编排管线      │──────────────▶│ ds-deploy/ 工具链    │──────────────▶│ DolphinScheduler │
 │ main.py     │               │ 依赖配置/部署/同步/   │               │ 3.4.2 (localhost) │
 │ dwd-pipeline│               │ 校验/排版/调度        │               │ Hive 4.2 容器     │
 │ dw-pipeline │               └────────────────────┘               └──────────────────┘
 └─────────────┘
```

### 2.2 三条编排管线（职责分工）

| 管线 | 定位 | 关键约定 |
|---|---|---|
| [tools/main.py](../tools/main.py) | **生成器 CLI**：调研 Excel → DDL/ETL/血缘/字典 | `--layer ODS\|DWD\|DWS\|ALL`，自动发现系统 |
| [tools/dwd-pipeline.py](../tools/dwd-pipeline.py) | **甲方 DWD 脚本搬移 + 血缘梳理一条龙**（`jf` 来源） | 默认 dry-run，`--apply` 落盘；**MASTER 层禁用 gen 覆盖** |
| [tools/dw-pipeline.py](../tools/dw-pipeline.py) | **DWD+DWS 一体化**：脚本/DDL/血缘/依赖/部署/排版/校验 | `--source jf\|gen`，默认 dry-run，`--apply` 才动 DS |

关系：`dw-pipeline` 是总入口，内部按层**子进程调用** `dwd-pipeline.py`（DWD jf 路径）或
`main.py`（gen 路径），部署阶段调用 `ds-deploy/` 下的脚本。

### 2.3 目录结构

```
claude-code/
├── AGENTS.md / CLAUDE.md      # 项目口径规范（两份内容一致，AI 辅助用）
├── pyproject.toml             # 包元信息；入口 generate-dw = tools.main:main
├── requirements.txt           # pandas / openpyxl / python-calamine(可选)
├── demo/templates/
│   └── etl_ods_template.sh    # ODS ETL Shell 模板（${...} 占位符）
├── docs/                      # 规范文档（功能与规范、DWD-DWS 管线、主数据、依赖体检）
├── scripts/                   # ★ 生成产物（gitignored），按 {系统}/{层}/ 组织
│   ├── {O32|HSFA|HSZTA|WIND|...}/{ods|dws}/...
│   ├── MASTER/dwd/            # 主数据：甲方脚本 + 手工血缘（不可重生成）
│   ├── 建表语句/  DWD_依赖关系.xlsx  DWS_*.xlsx  数据字典_汇总.xlsx
└── tools/                     # ★ 代码核心
    ├── config.py  main.py  dwd-pipeline.py  dw-pipeline.py  dws-dep-report.py
    ├── core/       # 中间表示 IR + 类型映射 + SQL 表引用工具
    ├── parser/     # Excel 解析（调研表 / MAPPING）
    ├── generator/  # DDL / ETL / 血缘 / 数据字典 生成器
    ├── utils/      # 共享工具（写文件、校验、查找、日志、Excel 读盘）
    ├── ds-deploy/  # DolphinScheduler 部署工具链（唯一权威源，见其 README）
    ├── tests/      # unittest 单元测试（18 文件 / 347 个 test_* 用例）
    └── .dx-tmp/    # 运行报告等临时产物（gitignored）
```

---

## 3. 核心模块职责与关键接口

### 3.1 `tools/config.py` — 全局配置

路径、Schema、系统字段、Hive 参数的单一配置源，全部模块 import 它。

| 分组 | 关键常量 | 说明 |
|---|---|---|
| 路径 | `D_BASE` `PROJECT_BASE` `SURVEY_DIR` `DWD_MAPPING_BASE` `DWS_MAPPING_BASE` `OUTPUT_BASE` | 支持 `DW_D_BASE` / `DW_PROJECT_BASE` 环境变量覆盖，跨平台（WSL/Win/macOS） |
| Schema/表名 | `ODS_SCHEMA_TMPL` `ODS_TABLE_TMPL` `DWD_SCHEMA` `DWS_SCHEMA` `SUFFIX_FULL(PFD)` `SUFFIX_INCR(PTD)` | 命名规范常量 |
| 系统字段 | `SYS_FIELDS_ODS/DWD/DWS` | `(字段名, 类型, 注释)` 三元组列表；ODS 仅 `LD_TIME`，DWD 含 `SSYS/SRC_TAB` |
| DDL 排版 | `DDL_PARTITIONS` `DDL_ROW_FORMAT` `DDL_FIELD_PREFIX/SEP` `TIMESTAMP_EXPR` | 与 ETL 对齐的列宽常量 `AS_POS=80` `COMMENT_POS=120` `DEP_TBL_WIDTH=55` |
| Hive 参数 | `HIVE_COMPAT_SETTINGS` `HIVE_DYNAMIC_PARTITION_SETTINGS` `HIVE_SETTINGS` | 严格模式关闭 + 动态分区 + 合并小文件，**顺序即作用域** |
| 别名映射 | `SYSTEM_ALIAS_MAP` | `ZTA/TA→HSZTA`、`LOFTA→HSFTA`、`直销→HSDS`、`聚源→JY`、`官网→OFFW` |
| 其他 | `CODE_FIELD_KEYWORDS` `DATAX_ORACLE_VARS` `DATAX_HDFS_VARS` `GLOBAL_TABLE_CN_MAP` | 码值字段识别、DataX 凭据占位、血缘中文名回退表 |

### 3.2 `tools/core/` — 中间表示与 SQL 工具

**[core/ir.py](../tools/core/ir.py)** —— parser 与 generator 之间的数据契约（4 个 dataclass）：

| 类 | 来源 | 关键字段 |
|---|---|---|
| `TableMeta` | 表级调研 | `src_sys/src_schema/src_table`（字段级 join 键）、`src_table_phys`（真实取数物理表，两者不可混用）、`ods_table`、`load_strategy`(FULL/INCR)、`incr_cond*`、`is_reserved` |
| `FieldMeta` | 字段级调研 | `ordinal/src_name/src_type/hive_type/is_ods/is_reserved/is_code_field` |
| `MappingRule` | MAPPING 行 | `tgt_*`（目标字段）、`src_table_alias/src_field_name/src_field_type`、`join_type(MAIN/LEFT JOIN)/join_cond/filter_cond`、`group_no` |
| `MappingSheet` | MAPPING sheet 页 | `tgt_table/partition_col(p_dt)/param(p_batch_dt)/frequency`、`mappings[]`、`source_tables[]` |

**[core/type_mapper.py](../tools/core/type_mapper.py)**
- `oracle_to_hive(oracle_type, field_cn="")` —— Oracle→Hive 类型映射；`_is_code_field()` 用
  `CODE_FIELD_KEYWORDS` 判定码值字段（影响映射到 STRING 的策略）。

**[core/sql_tables.py](../tools/core/sql_tables.py)** —— SQL 中表引用的解析与改写：
`is_subquery()`、`extract_tables_from_subquery()`（带缓存）、`validate_table_ref()`（防注入标识符校验）、
`qualify_table()`（补 `DWDXDAY.`/`ODS_XDAY_*.` schema）、`qualify_subquery_tables()`、`wrap_subquery()`
（子查询补别名）、`compat_sql_functions()`（IFNULL→COALESCE）、`normalize_inceptor_sql()`。

### 3.3 `tools/parser/` — Excel 解析

| 文件 | 公共接口 | 职责 |
|---|---|---|
| [table_survey.py](../tools/parser/table_survey.py) | `parse_table_survey(filepath, sys_name, table_prefix) -> list[TableMeta]` | 定位「表级调研」sheet，按 `是否保留` 过滤、生成 ODS 表名、处理增量/全量策略与撞名回退 |
| [field_survey.py](../tools/parser/field_survey.py) | `parse_field_survey(filepath) -> dict[str, list[FieldMeta]]` | 字段级调研 → 按表组织字段；`是否入ODS` 留空/是/Y/y 才生成；`_read_excel_safely()` 容错读盘 |
| [mapping.py](../tools/parser/mapping.py) | `parse_mapping_dir(dir) -> list[MappingSheet]`、`parse_dws_mapping(file) -> list[MappingSheet]`、`parse_mapping_sheet(file, sheet)` | 解析 DWD/DWS MAPPING：定位目标字段列、展开子查询源表、解析 JOIN/WHERE、`SRC_TAB` 顺序；`_sanitize_identifier()` 修复非法标识符；内置**指纹缓存**（`_cache_*`，`DW_*` 环境变量可禁用） |

### 3.4 `tools/generator/` — 生成器

**工厂** [generator/\_\_init\_\_.py](../tools/generator/__init__.py)：`create_generator(layer_name) -> BaseGenerator`
—— `DWD`/`DWS` 均返回 `BaseGenerator` 实例，仅 `schema`（`DWDXDAY`/`DWSXDAY`）与系统字段
（DWD 含 `SSYS/SRC_TAB`，DWS 只有 `LD_TIME/MODIFY_TIME`）不同。

**[generator/base.py](../tools/generator/base.py)** —— 核心生成器（约 1200 行）：

- `class BaseGenerator`
  - `__init__(schema, sys_fields, has_src_fields)`
  - **DDL**：`generate_ddl(sheet)` / `generate_all_ddl(sheets)` / `generate_all_ddl_files(...)`
  - **ETL**：`generate_etl(sheet, sys_name)` / `generate_all_etl_files(sheets, output_dir, sys_name)`
  - **FROM/JOIN 构建**：`_build_from_join(aliases)`（MAIN TABLE + LEFT JOIN，子查询自动补 schema 与别名）、
    `_split_on_and()`、`_append_on_conditions()`、`_build_where()`
  - **SELECT 构建**：`_build_select_lines()`、`_resolve_expr()`、`_format_case_expr()`、`_fmt_select_line()`
  - **分组/别名**：`_collect_aliases()`、`_has_alias_conflict()`、`_split_by_ordinal()`、`_subgroups()`
  - **校验辅助**：`_undefined_aliases_in_sql()`、`_bad_subqueries()`（供生成期自检）
  - **UNION 类型对齐**（J-29）：`_type_class()`、`_unify_union_type()`、`_cast_placeholder()`
- 模块级函数：`qualify_src_table()`、`_render_src_ref()`、`normalize_params()`（`${p_end_dt}` 参数归一）、
  `_strip_bare_pdt()`、`_resolve_group_sys()/​_resolve_group_src_tab()`（SSYS/SRC_TAB 取值）

**[generator/ods.py](../tools/generator/ods.py)** —— ODS 层（DDL + DataX 抽数脚本）：
`generate_ods_ddl()` / `generate_all_ods_ddl(_files)` / `generate_ods_etl()` / `generate_all_ods_etl()`；
增量列解析 `_extract_incr_col()`、`_build_where_pred()`、分区表达式 `_build_p_dt_expr()`、
`_validate_incr_columns()`（增量列缺失即报错）、模板加载 `_load_etl_template()`（读
`demo/templates/etl_ods_template.sh` 并替换 `${...}`）、`_datax_type()`。

**[generator/ddl_common.py](../tools/generator/ddl_common.py)** —— DDL 共享构建：
`normalize_hive_type()`、`quote_hive_column(_sh)`、`escape_sql_comment()`、
`build_field_defs()`（业务列 + 系统字段统一拼装）、`generate_ddl_body()`。

**[generator/lineage.py](../tools/generator/lineage.py)** —— 血缘提取：
`extract_lineage(sheets, layer, sys_name)`（表级 + 字段级上游，`_resolve_upstream_tables()` 处理子查询与别名）、
`generate_lineage_excel()` → `{层}/lineage/{layer}_lineage.xlsx`。

**[generator/data_dict.py](../tools/generator/data_dict.py)** —— 数据字典：
`extract_ods_dict()` / `extract_layer_dict()` / `generate_data_dict()` /
`write_combined_dict()`（跨系统跨层级汇总 → `scripts/数据字典_汇总.xlsx`）。

### 3.5 `tools/utils/` — 共享工具

| 文件 | 关键接口 | 职责 |
|---|---|---|
| `table_utils.py` | `parse_bool()` `filter_valid_ods_tables()` `iter_ods_tables()` `write_file()` `write_files_per_table()` `write_file_safe()` | 布尔口径统一、ODS 表过滤（表保留 + 有入 ODS 字段）、**统一 UTF-8/LF 写盘**（禁止裸 `open('w')`） |
| `validation.py` | `validate_db_identifier()` `validate_output_path()` | SQL 注入防护（表/字段名）与路径遍历防护 |
| `sys_extractor.py` | `normalize_sys_name()` `extract_sys_name(layer, path)` | 系统名标准化（应用 `SYSTEM_ALIAS_MAP`）与从路径推断系统名 |
| `mapping_finder.py` | `find_mapping_file(base, names, suffix)` `find_mapping_dir(base, names)` | 单次 scandir 按「原始名+别名+标准名」顺序查找 MAPPING 文件/目录 |
| `excel_reader.py` | `read_workbook_sheets()` `calamine_available()` `apply_header_row0()` | Excel 快速读盘：python-calamine 快路径 + openpyxl 回退（`DW_NO_CALAMINE=1` 强制回退） |
| `pandas_helpers.py` | `safe_str()` `safe_float()` `safe_float_str()` | NaN/None 安全取值 |
| `logging_setup.py` | `setup_logging()` `get_logger()` | 统一日志格式、第三方库降噪 |

---

## 4. 编排管线详解

### 4.1 `tools/main.py`（生成器 CLI）

```
python tools/main.py --layer ALL|ODS|DWD|DWS [--sys O32] [--output DIR]
                     [--dwd-mapping-dir DIR --sys-name MASTER] [--verbose]
```

执行流程：
1. `_discover_systems()` 扫描 `SURVEY_DIR`（支持 `序号-中文名_简称` 与 `序号-简称` 两种目录名）；
2. **ODS**：`_generate_ods_for_sys()` → 表级+字段级解析 → 过滤 → DDL/按表 DDL/ETL/字典；
3. **DWD/DWS**：`_all_sys_names()` 展开别名 → `find_mapping_dir/file()` 找 MAPPING →
   `_generate_dwd_dws()` → `create_generator()` → DDL/ETL/血缘/字典；
4. `write_combined_dict()` 汇总字典（`--dwd-mapping-dir` 模式**刻意跳过**，避免覆盖全量汇总）。

### 4.2 `tools/dwd-pipeline.py`（甲方脚本搬移）

子命令（默认 dry-run，`--apply` 落盘）：

| 子命令 | 作用 |
|---|---|
| `owner` | 扫 MAPPING 目录 → 表归属映射 `tools/.dx-tmp/dwd_owner_map.json` |
| `convert` | 甲方 `01-DWD执行脚本/*.txt` → `scripts/{系统}/dwd/02_etl/*.sh`（`convert()` 做 Hive 4.2 方言修复：`fix_date_format3()`、`add_subquery_alias()`、去 SET/SYSDATE 等） |
| `distribute` | 分布统计 + DDL 表数 → `scripts/_DWD搬移清单.json` |
| `ddl` | 甲方建表脚本补/替 DDL（`parse_jf_ddl()` `sanitize_ddl()`），重建各系统 `01_ddl.sql` |
| `lineage` | 脚本依赖梳理 → `scripts/DWD_依赖关系.xlsx`（7 sheet）；`PREV_IDIOM_RE` 识别 T-1 免配边 |
| `depcfg` | xlsx → `tools/ds-deploy/dep-config-proscript/*.dep.json` |
| `verify` | `bash -n`、DDL 并入完整性、可选 `--ds` 来源审计（本地索引扫 `GROUPS`，**含主数据**；占位/缺脚本非 0 即失败） |
| `all` | owner→convert→distribute→ddl→lineage→depcfg→verify 串跑 |

关键常量：`WORKFLOW_OVERRIDE` / `own_workflow()`（工作流归属，**唯一来源 `tools/core/dwd_ownership.py`**，
本文件与 `ds-build-dependent-from-lineage.py` 均为薄委托）、
`SCHEDULE_EXCLUDE`（配置表排除）、`PREV_IDIOM_RE`/`PREV_IDIOM_VARS`（T-1 只读前一日判定，
`${P_BATCH_DT}` 变体 `prev_alike` **只报不删**）、`PART_LABEL/PART_ORDER`（分区读取口径分类）、
`RE_SET_DROP`/`PART_FIX`/`EVT_CAST_FIX`（方言修复规则）、`safe_sysname()`（防路径穿越）。

⚠ `scripts/MASTER` 是甲方交付 + 手工血缘，**禁止** `main.py --layer DWD --sys-name MASTER` 重生成。

### 4.3 `tools/dw-pipeline.py`（DWD+DWS 一体化）

```
python3 tools/dw-pipeline.py <子命令> [--layers DWD,DWS] [--source jf|gen]
                             [--apply] [--deploy] [--ds] [--allow-gen-errors] [--force-dws-raw]
```

| 子命令 | 作用 |
|---|---|
| `scripts` | jf：DWD 调 `dwd-pipeline convert/distribute`，DWS 比对甲方 25 个 txt（默认不覆盖已修复版）；gen：调 `main.py` 到临时目录并扫 `[ERROR` 失败即停 |
| `ddl` / `lineage` | jf 调 `dwd-pipeline`；DWS 校验各系统 `01_ddl.sql`、3 份 `DWS_lineage.xlsx` |
| `config` | 生成 `dep-config-proscript`（DWD）/ `dep-config-dws`（DWS），刷新 `DWS_表中文名.json` |
| `delete` | 先删 `DWS_*` 再删 `DWD_*`；`check_dwd_only_preflight()` 拒绝「DWS 仍在却只删 DWD」 |
| `deploy` | 预删 DWS → 删/建 DWD → 建 DWS（拓扑 `HSFA→O32→ZTA`）→ relayout |
| `layout` | 调 `ds-relayout.py dwd\|dws` |
| `verify` | 本地/`--ds` 来源审计（`verify_dws()`：24 脚本、24 dep、3 工作流 ONLINE、逐字节一致） |
| `all` | `scripts→ddl→lineage→config→verify`（`--deploy` 再串部署） |

辅助函数：`run()`（子进程封装）、`sync_files()`（差异比对 + 备份 `backup_dir()`）、
`dws_source_map()`/`stage_dws_from_jf()`（甲方 DWS 搬移）、`ds_workflows()`/`dws_refs_into_dwd()`（DS 侧引用处理）。

### 4.4 `tools/dws-dep-report.py`

DWS 依赖关系报表生成（配合 `scripts/DWS_依赖关系.xlsx` 使用）。

---

## 5. `tools/ds-deploy/` — DolphinScheduler 部署工具链

本目录是 DS 工具的**唯一权威源**（详见 [ds-deploy/README.md](../tools/ds-deploy/README.md)，含 8 条铁律）。
共 22 个现役脚本，按用途分四类：

| 类别 | 脚本 |
|---|---|
| **部署/落库** | `ds-deploy-api.py`（★JSON 契约 `dw-ds-deploy/v1`：`export/plan/import`，幂等 upsert）、`ds-deploy-all-dwd.py`（逆拓扑全删→正拓扑重建，`--layer DWD\|DWS`）、`ds-deploy-ods-all.py`、`ds-deploy-dwd-workflow.py`（单工作流，公共 HTTP 库）、`ds-add-dwd-table.py`、`ds-rebuild-from-inventory.py`（灾后重建，两阶段提交） |
| **一键管线** | `tools/dw-pipeline.py`（现役唯一入口；原 `ds-dwd-pipeline.py` 已退役归档 `tools/.archive/retired/`） |
| **脚本同步** | `ds-sync-dwd-scripts.py`、`ds-sync-ods-scripts.py`（逐字节比对，只推 sha1 变更，先 OFFLINE 再 PUT） |
| **依赖构建** | `ds-build-dependent-from-lineage.py`（★DWD，读 `scripts/*/dwd/lineage/DWD_lineage.xlsx` → `dep-config-proscript`；`own_workflow()`/`WORKFLOW_OVERRIDE` 委托自 `tools/core/dwd_ownership.py`）、`ds-build-dws-dependent-from-lineage.py`（DWS → `dep-config-dws`） |
| **运行/跑批** | `ds-run.py`、`ds-run-hive-sql.py`、`run-dwd-etl-direct.py`（绕 DS 直跑 Hive：Kahn 拓扑 + 最长路径分层、内存闸门、行数回采，报告 `tools/.dx-tmp/dwd-etl-run.json`） |
| **调度** | `ds-schedule.py`（`ensure/create/switch/release`；`LAYERS/DWD_SLOTS` 必须与部署拓扑同序） |
| **体检/守卫** | `ds-check-running.py`（★★ 动 DS 前必跑）、`ds-check-tables-exist.py`、`ds-verify-dwd-layout.py`、`validate-dwd-syntax.py`（Hive `EXPLAIN` 沙箱编译，报告 `tools/.dx-tmp/dwd-syntax-check.json`） |
| **排版** | `ds-relayout.py dwd\|ods`（DWD 列距 500 / ODS 416，**刻意分层**；导入脚本已内置，本工具为兜底） |
| **危险维护** | `ds-wipe-workflows.py`（先 pg_dump） |

### 5.1 公共基础模块

**[ds_client.py](../tools/ds-deploy/ds_client.py)** —— DS API 客户端（被 12+ 脚本 import）：
- `class DSClient`：唯一 HTTP 入口 `call(method, path, params/form/body, _retry=True)`（**没有 get()/post()**）；
  401 自动重登重试；会话复用。
- `get_client(**kw)` 单例工厂；`legacy_client()` / `LegacyCaller` —— 旧脚本兼容层（`call+login` 形态）。
- 响应取值助手：`lst_of()`、`project_code(res, name)`、`task_definitions()`、`dependence_of()`、`_maybe_json()`。
- **护栏**：默认用脚本专用账号 `ds_script`；`allow_admin=True` 才允许 admin —— 同 user 只保留 1 个会话，
  脚本用 admin 登录会踢掉浏览器 UI 会话。

**[ds_config.py](../tools/ds-deploy/ds_config.py)** —— 凭据集中读取（源码无任何口令字面量）：
`require_secret(key)` 优先级 = **进程环境变量 → `tools/ds-deploy/.env.local` → `~/.dw-secrets.env` → 抛
`SecretMissingError`**；访问器 `ds_base/ds_user/ds_password/ds_service_user/ds_service_password/
ds_admin_user/ds_admin_password/pg_conn/pg_password/hive_user/hive_password`；`preflight(*keys)` 批量预检。
另支持 `DW_DS` / `DW_DS_USER` / `DW_DS_PWD` / `DW_DS_PROJECT` / `DW_REPO` / `DW_DEPCFG` 环境变量。

**[ds_text.py](../tools/ds-deploy/ds_text.py)** —— `normalize_newlines()`（CRLF→LF）、`read_script()`，
保证本地脚本与 DS 上 `rawScript` 可逐字节比对。

### 5.2 部署数据流

```
scripts/{sys}/dwd/lineage/DWD_lineage.xlsx
        │  ds-build-dependent-from-lineage.py
        ▼
tools/ds-deploy/dep-config-proscript/*.dep.json   (DWS: dep-config-dws)
        │  ds-deploy-all-dwd.py / ds-deploy-api.py plan→import
        ▼
DolphinScheduler 项目 dw：工作流(DWD_<主题>/DWS_<系统>) + SHELL 作业 + DEPENDENT 作业级依赖
        │  ds-sync-dwd-scripts.py 推脚本、ds-schedule.py 建调度、ds-relayout.py 兜底排版
        ▼
DS 跑批 → Hive 4.2 (hiveserver2 容器) 执行 inceptor_beeline SQL
```

---

## 6. 依赖关系

### 6.1 模块级 import 关系（自上而下单向，无环）

```
main.py ────────┬── parser/*  ──→ core/ir.py, utils/excel_reader, utils/pandas_helpers
dwd-pipeline.py  │
dw-pipeline.py ──┴── generator/* ──→ core/{ir,type_mapper,sql_tables}, utils/*, config.py
                     │
ds-deploy/*.py ──────┴── ds_client.py ← ds_config.py / ds_text.py   （部署层不依赖生成层，
                                                                    只读 scripts/ 产物）
```

- `config.py` 被所有生成侧模块 import（无反向依赖）。
- `utils/` 不 import `parser/generator`（叶子层）。
- `ds-deploy/` 通过**文件系统产物**（`scripts/`、`lineage/*.xlsx`、`dep-config-*`）与生成层解耦。
- `dw-pipeline.py` 以子进程方式调用 `dwd-pipeline.py` / `main.py` / `ds-deploy/*.py`（`run()`）。

### 6.2 外部依赖

| 依赖 | 用途 |
|---|---|
| `pandas>=1.3.0` | Excel 解析核心 |
| `openpyxl>=3.0.0` | Excel 读写（回退路径） |
| `python-calamine>=0.2.0`（可选） | MAPPING 冷读加速 ~6x，缺失自动回退 |
| `pyyaml`（可选） | `ds-check-mount-sources` 等维护脚本 |
| Hive 4.2（docker `hiveserver2`） | SQL 编译校验（`EXPLAIN`）、真实执行（beeline） |
| DolphinScheduler 3.4.2（`http://localhost:12345/dolphinscheduler`） | 部署目标，项目 `dw` |
| PostgreSQL（DS 元库） | 调度状态核查、灾后重建取清单 |

### 6.3 数据/系统依赖（业务侧）

- 上游源系统：`O32 / HSFA / HSZTA / HSFTA / HSDS / WIND / JY / OFFW / OA`（别名映射见 `SYSTEM_ALIAS_MAP`）。
- 层间依赖：ODS → DWD → DWS；DWD 工作流级依赖 19 条，重启顺序
  `DWD_CMM → PTY → SCR → CHNL → PROD → ACCT → AGMT → AST → EVT → TRAN`。
- **T-1 免配规则**：上游读「前一日分区」的边不建调度依赖（判定形态见 `PREV_IDIOM_RE`）。

---

## 7. 项目运行方式

### 7.1 环境准备

```bash
# 统一在 WSL Ubuntu24.04 中运行（Windows 原生无 Python）
wsl -e bash -lc "cd /mnt/c/Users/84148/Desktop/trae/claude-code && python3 ..."

pip install -r requirements.txt        # pandas / openpyxl / python-calamine
pip install pyyaml                     # 部分 ds 维护脚本需要

# DS 凭据（首次，写 tools/ds-deploy/.env.local 或 ~/.dw-secrets.env）
export DS_ADMIN_PASSWORD='...'  DS_PASSWORD='...'  DS_PG_PASSWORD='...'  DS_HIVE_PASSWORD='...'
python3 tools/ds-deploy/ds_config.py   # 自检：只报在/缺，不打印值
```

路径可通过 `DW_D_BASE` / `DW_PROJECT_BASE` 覆盖（调研文档默认在 `/mnt/d/项目/信达澳亚数仓/...`）。

### 7.2 常用命令

```bash
# ① 生成（gen 来源）
python tools/main.py --layer ALL                     # 全层自动发现
python tools/main.py --layer ODS --sys O32 -v
python3 tools/dw-pipeline.py all --source gen --layers DWD,DWS   # gen 一体化（失败即停）

# ② 甲方脚本搬移（jf 来源，推荐）
python3 tools/dwd-pipeline.py all --apply
python3 tools/dw-pipeline.py all --source jf --layers DWD,DWS --apply

# ③ 校验
python3 -m unittest discover -s tools/tests -p "test_*.py"       # 单元测试
python3 tools/ds-deploy/validate-dwd-syntax.py [--sys O32|--etl-only|--only 表名]  # Hive 编译
bash -n scripts/<sys>/dwd/02_etl/*.sh                            # Shell 语法

# ④ 部署到 DS（先体检！）
python3 tools/ds-deploy/ds-check-running.py          # ★ 动 DS 前必跑
python3 tools/dw-pipeline.py deploy --layers DWD,DWS --apply
python3 tools/dw-pipeline.py verify --layers DWD,DWS --ds

# ⑤ 真实执行（落数据，绕开 DS）
python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010 [--dry-run|--skip-ddl|--only A,B]
```

### 7.3 约定速查

- **dry-run 优先**：`dwd-pipeline` / `dw-pipeline` 默认不落盘，`--apply` 才执行。
- **gen vs jf**：gen = 生成器自产（`main.py`）；jf = 甲方交付脚本搬移 + 方言修复。
- **MASTER 例外**：主数据脚本/DDL/血缘均为甲方交付 + 手工定稿，任何 gen 重生成都会覆盖。
- **写盘统一走** `table_utils.write_file / write_file_safe`（UTF-8 + LF）。
- 临时产物一律进 `tools/.dx-tmp/`（gitignored）；归档/退役脚本进 `tools/.archive/`（gitignored）；`scripts/` 也在 gitignore 中。

---

## 8. 测试与文档

### 8.1 测试（`tools/tests/`，unittest，18 文件 / 347 个 `test_*`）

| 测试文件 | 被测对象 | 用例数 |
|---|---|---|
| `test_ods.py` | ODS 生成器（DDL/ETL/增量列） | 87 |
| `test_sql_tables.py` | `core/sql_tables.py` 表引用解析 | 42 |
| `test_ds_deploy_utils.py` | ds-deploy 公共工具 | 32 |
| `test_generator_grouping.py` | base.py 别名分组/SSYS 归属 | 28 |
| `test_ddl_common.py` | DDL 共享构建 | 22 |
| `test_mapping_parse.py` | MAPPING 解析 | 15 |
| `test_type_mapper.py` | 类型映射 | 13 |
| `test_table_utils.py` / `test_data_dict.py` | 工具 / 数据字典 | 各 11 |
| `test_table_survey.py` / `test_validation.py` | 表级解析 / 安全校验 | 各 7 / 7 |
| `test_excel_reader.py` | calamine/openpyxl 双路径 | 6 |
| `test_project_consistency.py` | 口径守门（归属字典单一来源、`AGENTS.md`≡`CLAUDE.md`） | 4 |
| 其余（`test_dwd_pipeline` `test_dw_pipeline` `test_sys_extractor` `test_field_survey`） | 管线与解析 | 3–8 |

```bash
python3 -m unittest discover -s tools/tests -p "test_*.py"
```

### 8.2 文档索引

| 文档 | 内容 |
|---|---|
| [AGENTS.md](../AGENTS.md) / `CLAUDE.md` | 项目口径：命名规范、系统列表、MASTER/DWD/DWS 基线、工作流归属与重启顺序 |
| `docs/功能与规范文档.md` | 生成器功能与规范明细（含 J-xx 条目、§15.3 T-1 免配规则） |
| `docs/DWD-DWS一体化管线使用说明.md` | `dw-pipeline` 使用手册 |
| `docs/主数据生成说明.md` | MASTER 层口径（甲方脚本 + 手工血缘） |
| `docs/DWD-ODS依赖体检报告.md` | 依赖体检快照（快照不下发口径） |
| [tools/ds-deploy/README.md](../tools/ds-deploy/README.md) | 部署工具链：工具清单、JSON 契约、8 条铁律、踩坑记录 |
