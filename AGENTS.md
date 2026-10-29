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

## MASTER（主数据）层口径（2026-10-15 定稿）

- **脚本与 DDL 直接取甲方交付**：`05-脚本/02-脚本/01-DWD执行脚本/*.txt` → `scripts/MASTER/dwd/02_etl/`，
  建表取 `01-建表语句/01-DWD建表脚本.sql`（结构核对 `03-物理模型/`），只做 Hive 4.2 方言修复
  （禁用 SET/三参 DATE_FORMAT/SYSDATE/别名/分区/CAST，详见 `docs/功能与规范文档.md` J-28）。
- **血缘手工梳理**：`scripts/MASTER/dwd/lineage/DWD_lineage.xlsx` 为定稿，**禁止运行
  `python tools/main.py --layer DWD --sys-name MASTER`**（会覆盖甲方脚本与手工血缘）。
- **主数据随 DWD 批次执行真实脚本**（2026-10-23 用户拍板，取代 10-15 旧口径）：`scripts/MASTER/dwd/02_etl/*.sh`
  在 DS 上就是真实 rawScript、按依赖参与跑批；`--master-placeholder` 可回滚为 `MASTER_EMPTY_TPL` 空跑占位。
- 脚本同步 `ds-sync-dwd-scripts.py` 对 `MASTER` 一视同仁（推真实脚本）；空脚本占位白名单
  `DEFAULT_EMPTY` **当前为空集**（SALE_FEER / TAIL / WARN_HIS 于 2026-10-27 逐条 EXPLAIN 通过后
  转正、同步工具与部署工具两处同步清空〔J-36〕）；跑批期某张表过不了时用 `--empty-tables` 显式追加
  （详见 `tools/ds-deploy/README.md` 铁律 8）。
- 无 MAPPING 的 DWD 表 DDL 落档 `scripts/MASTER/dwd/ddl/`（STD_DICT_CDVAL_MAP / CALENDAR_INFO /
  CLS_EMRT_INFO 等），已并入 `01_ddl.sql`；数据来源见各文件头注释。
- 校验口径：DDL 全量通过；ETL **109/109 真实脚本、0 占位、0 缺脚本**（`DEFAULT_EMPTY` 已清空）。

## DWD 工作流归属与调度依赖口径（2026-10-23 定稿）

### 归属：默认按表名前缀，个别表用 `WORKFLOW_OVERRIDE`

- 默认唯一规则：`DWD_<主题>_…` → 工作流 `DWD_<主题>`（`tools/core/dwd_ownership.py::own_workflow`）。
- 例外只写在 `WORKFLOW_OVERRIDE`，**唯一来源 `tools/core/dwd_ownership.py`**（2026-10-29）：
  `tools/dwd-pipeline.py` 与 `tools/ds-deploy/ds-build-dependent-from-lineage.py` 都只是薄委托，
  不再各存一份；守门用例 `tools/tests/test_project_consistency.py`。
- 已定清单（用户 2026-10-23 拍板，**下次同类照此办理**）：

  | 表 | 原工作流 | 归到 | 理由 |
  |---|---|---|---|
  | `DWD_PTY_OPER_FUND_PRVL_PFD` | `DWD_PTY` | **`DWD_PROD`** | 唯一 DWD 上游 `DWD_PROD_SFAC_NUM_MAPP_PFD` 在 PROD，留在原工作流会形成工作流级环（跨流互等） |
  | `DWD_CMM_INTR_PARA_PFD` | `DWD_CMM` | **`DWD_PROD`** | 同上（上游同为 `DWD_PROD_SFAC_NUM_MAPP_PFD`） |

- 判定口诀：**上游映射表在哪，表就放哪**（唯一 DWD 上游是 `DWD_PROD_*NUM_MAPP_*` 的 ⇒ 归 `DWD_PROD`）。
- 粒度是**表**不是文件：`.sh`/DDL 仍留在原系统目录（如 `scripts/O32/dwd/…`），只改 DS 工作流成员。

### 调度依赖：上游读「前一日分区」（T-1）⇒ 不配

- 口径原文（必须是这个**字面形态**，允许空白/换行任意、`UNIX_TIMESTAMP` 内多包 `CAST(… AS STRING)`）：

  ```
  DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  ```

- 语义：按批次日-1 读上游 ⇒ 当天上游没跑也能取到数 ⇒ **不建调度依赖**，DAG 中不出现、不产生跨流等待。
- 实现：`dwd-pipeline.py::PREV_IDIOM_RE` 只认该形态（**不是「含 `DATE_SUB` 就算」**，周/月/账期偏移会误判）；
  `lineage` 在工作簿「调度依赖」列写 `不配依赖(只读前一日)`，`depcfg` 跳过并打印 `不配(只读前一日) N 条`；
  清单落 `tools/_prev_day_deps.json`。
- ⚠ `${P_BATCH_DT}` 变体归 `prev_alike`：**只报不删**（不擅自扩大口径）。
- 免配边清单不写进文档（会随脚本变化而失真），以 `depcfg` 运行时打印与 `tools/_prev_day_deps.json` 为准。
- 详见 `docs/功能与规范文档.md` §15.3。

### 文档记录约定（2026-10-24 / 2026-10-26 用户要求）

- **只记决策与规则**：判定口径、清单（表 → 工作流）、处置方式、为什么这么做。
- **不记临时结果**：实例号、耗时、当次条数、表数/作业数快照、「破环切断 N 条」这类一次性数据 ——
  跑批一变就失真，写了反而误导。
- **不写过程性/一次性内容**：临时脚本、中间排查步骤、失败重试过程、调试命令、未定稿方案。
  只保留**最终定稿方案**；定稿前的过程材料一律落 `.dx-tmp/` 或 `/tmp`，不进 `AGENTS.md`、`docs/`。
- **文档及时更新**：口径一变立刻回写本文件与 `CLAUDE.md`，不要留在聊天记录里。
- 需要快照时单独落盘并标「生成时间」（如 `scripts/DWD_DS依赖校验.md`）；**快照不下发口径**，
  口径以本文件为准。

## DWD 工作流重启顺序与优先级（2026-10-24 定稿）

- DS 3.4.2 没有工作流级 `priority` 字段；本节的“优先级”指**重启/上线顺序**：
  下游工作流必须等上游工作流完成，同层可并行。
- 依据 DS 实际工作流级依赖（与 `dep-config-proscript` 一致）分层：

  | 优先级 | 工作流 | 依赖的 DWD 工作流 |
  |---|---|---|
  | P0 | `DWD_CMM`、`DWD_PTY`、`DWD_SCR` | 无 |
  | P1 | `DWD_CHNL` | CMM、PTY |
  | P2 | `DWD_PROD` | PTY、CHNL |
  | P3 | `DWD_ACCT` | CHNL、PROD |
  | P3 | `DWD_AGMT` | CHNL、PROD、SCR |
  | P3 | `DWD_AST` | CMM、CHNL、PROD、SCR |
  | P3 | `DWD_EVT` | PROD、SCR |
  | P3 | `DWD_TRAN` | PTY、CHNL、PROD、SCR |

- **固定重启顺序（下次直接照此执行）**：

  `DWD_CMM → DWD_PTY → DWD_SCR → DWD_CHNL → DWD_PROD → DWD_ACCT → DWD_AGMT → DWD_AST → DWD_EVT → DWD_TRAN`

- 同层可并行，跨层必须等上游完成；新增/调整表归属后按 `tools/dwd-pipeline.py` 的 depcfg 重算，不手改本顺序。

## DWS 基线与口径（2026-10-20）

- 甲方 DWS 脚本 `05-脚本/02-脚本/02-DWS执行脚本/` 25 个 txt；实际交付 **24 张表**
  （HSFA 7 / HSZTA 8 / O32 9），`DWS_TRAN_MKT_TRAN_PR_STAT_PTD` 无 MAPPING/无血缘，排除。
- **`scripts/{系统}/dws/02_etl` 是 DWS 权威源**：24 个脚本；配套文档统一落 `scripts` 根目录
  （`DWS_lineage.xlsx`、`DWS_依赖关系.xlsx`（均含 **引导页**：各 sheet 内部跳转 + 同层关联文件相对路径外链；
  **工作簿不混层** —— DWS 工作簿只做 DWS 侧分析，DWD 工作簿只做 DWD 侧分析，跨层文档不互相链接），
  `DWS_语法校验.md`（24/24 通过 Hive `EXPLAIN`）、
  `DWS_表中文名.json`、`_DWS搬移清单.json`）。
- **DWS 脚本 = 甲方原文**（2026-10-26 复核：24/24 与 `05-脚本/02-脚本/02-DWS执行脚本/*.txt` **逐字节一致**，
  甲方交付 25 个，少的是 `DWS_TRAN_MKT_TRAN_PR_STAT_PTD`——3 份 MAPPING 里都没有它，
  按「无 MAPPING 不纳管」排除，其表建了但无作业、无分区）。
  管线仍保留「比对甲方 → 仓库」这一步用于防漂移；`--force-dws-raw` 目前等价空操作。
  ⚠ 旧文档里「仓库为已修复版 / `baseline=repaired-current`」的说法已过期（清单无该字段），不要再据此判断。
- DWS 依赖配置 `tools/ds-deploy/dep-config-dws` 24 份；工作流 `DWS_HSFA 7 / DWS_O32 9 /
  DWS_ZTA 8`，拓扑序 `DWS_HSFA → DWS_O32 → DWS_ZTA`。
- DWS 部署/重跑统一走 `tools/dw-pipeline.py deploy --layers DWS` 或按拓扑序手动触发；
  脚本变更用 `tools/ds-deploy/ds-sync-dwd-scripts.py --layer DWS` 同步到 DS。
- ⚠ **`DWS_HSFA` 的 7 个脚本 while 是右开区间**（`while [ $P_BATCH_DT -lt $end_date ]`，
  `P_BATCH_DT` 从 `p_start_dt` 起、每天 +1、`P_DT='${P_BATCH_DT}'`）。
  DS 默认 `p_start_dt = p_end_dt = ${system.biz.date}` ⇒ **循环体零次执行、作业假成功**。
  触发 HSFA 时必须传 `p_start_dt=<批次日>`、`p_end_dt=<批次日+1>`；`DWS_O32` / `DWS_ZTA`
  没有循环、直接 `P_DT='${p_end_dt}'`，仍传 `p_start_dt = p_end_dt = <批次日>`。
  （DWD 侧是闭区间 `-le`，单日跑一次，不受影响。见 `tools/dws-dep-report.py` 的「问题清单」。）
- **gen 模式 DWS 暂不可静默部署**：`DWS_PROD_INFO_PFD`（T13 括号不平衡 + T19–T23 未定义）、
  `DWS_TRAN_MKT_TRAN_CNFM_PTD`（ONT1/T10/T12/T2–T8 未定义）、
  `DWS_PROD_SCR_TRAN_DETAIL_PTD`（A1 括号不平衡 + A2–A12 未定义）需先修 MAPPING。


## 表重建口径（2026-10-26 定稿）

- **DDL 唯一来源是甲方**：DWD 取 `05-脚本/01-建表语句/01-DWD建表脚本.sql`，DWS 取 `02-DWS建表脚本.sql`；
  `dw-pipeline.py ddl --source jf` 负责清洗 Inceptor 方言（删 `DEFAULT NULL`、`VARCHAR2`→`STRING`、`DATE` 列名转义）。
- **「重建一遍」= DROP + CREATE + 按最新脚本跑数**，范围是**所有非 tmp 表**。
- **`*_TMP*` 表一律不预建**：tmp 表由主脚本内部 `CREATE`/`DROP` 自建自删，预建会与脚本内结构冲突；
  DDL 文件保留（供排查），只是不参与重建。
- 作业/依赖粒度按「有 ETL 脚本的表」算，tmp 表天然没有作业。
- **批次日（`p_end_dt`）必须与 ODS 现有分区对齐**：DWD 的 ODS 读取是同日分区（`P_DT='${p_end_dt}'`），
  批次日选错会跑出全空表；ODS 侧用启动参数覆盖（`startParams`）把分区标签打到同一批次日。
- **重建工作流只拦「本层」未结束实例**（`ds-deploy-all-dwd.py`）：ODS 抽数跑几小时不挡 DWD/DWS 重建，
  但本层（`DWD_*/MASTER_*` 或 `DWS_*`）有实例在跑仍直接拒绝。
- **`scripts/*/dwd/02_etl` 里任何残留 `.sh` 都会自动变成作业/工作流**（血缘→depcfg→deploy 全自动带上）。
  甲方搬移后必须核对 `scripts/_DWD搬移清单.json` 的 `assign`：不在里面、甲方也没有 txt 的，就是孤儿，先移走再重建。

## 目录结构

```
dw/
├── tools/                    # 核心工具目录
│   ├── config.py            # 全局配置（路径、Schema、系统映射、Hive 参数）
│   ├── main.py              # CLI 入口
│   ├── dwd-pipeline.py      # 甲方 DWD 脚本搬移 + 血缘梳理一体化（默认 dry-run）
│   ├── dw-pipeline.py       # DWD+DWS 一体化：脚本来源/DDL/血缘/依赖/删除/部署/排版/校验
│   ├── core/                # 中间表示 (IR)
│   │   ├── ir.py           # 数据类定义
│   │   ├── type_mapper.py  # Oracle→Hive 类型映射
│   │   └── dwd_ownership.py# DWD 表→工作流归属唯一口径（WORKFLOW_OVERRIDE）
│   ├── parser/              # 解析器
│   │   ├── table_survey.py # 表级调研 Excel 解析
│   │   ├── field_survey.py # 字段级调研 Excel 解析
│   │   └── mapping.py      # MAPPING Excel 解析
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
│   │   ├── pandas_helpers.py# Pandas 安全取值
│   │   └── excel_reader.py # Excel 快速读盘（calamine 快路径 + openpyxl 回退）
│   ├── ds-deploy/           # DS 部署 / 排布 / SQL 校验（详见其 README）
│   │   ├── README.md                # 部署工具说明
│   │   ├── ds_client.py             # DS API 客户端（含响应取值助手）
│   │   ├── ds_config.py             # 凭据集中读取（无明文缺省值）
│   │   ├── ds_text.py               # 文本规范化（CRLF→LF）
│   │   ├── validate-dwd-syntax.py   # DWD 脚本 SQL 编译校验（Hive EXPLAIN）
│   │   ├── ds-deploy-*.py           # 作业/工作流部署（ODS/DWD/DWS）
│   │   ├── ds-sync-*.py             # 脚本差异同步到 DS
│   │   ├── ds-relayout.py           # 工作流坐标重排（dwd/ods/dws 三用）
│   │   ├── ds-build-dependent-from-lineage.py      # DWD 血缘→依赖配置
│   │   └── ds-build-dws-dependent-from-lineage.py  # DWS 血缘→依赖配置
│   ├── .dx-tmp/             # 运行报告等临时产物（gitignored）
│   ├── .archive/            # 归档：退役脚本/历史调试/一次性排查产物（gitignored）
│   └── tests/               # 单元测试（347 个用例）
├── demo/templates/          # ODS ETL Shell 模板
│   └── etl_ods_template.sh
├── scripts/                 # 生成的脚本输出（gitignored）
├── docs/                    # 文档目录
│   ├── 功能与规范文档.md     # 生成器功能与规范
│   ├── DWD-ODS依赖体检报告.md
│   └── 主数据生成说明.md
├── CLAUDE.md                # 项目说明（AI 辅助用，本文件）
├── AGENTS.md                # 与 CLAUDE.md 内容一致
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

## 运行环境

- **Windows 原生无 Python**：本仓库统一在 **WSL Ubuntu24.04** 里跑
  （`wsl -e bash -lc "cd /mnt/c/Users/84148/Desktop/trae/claude-code && python3 ..."`，
  自带 python3 + pandas + openpyxl + python-calamine）；D 盘挂载于 `/mnt/d`。
- **SQL 校验/部署依赖本机 docker 集群**：Hive 4.2 容器 `hiveserver2`
  （beeline `jdbc:hive2://localhost:10000/default`，CUSTOM 认证，docker exec 时记得
  `-e TERM=dumb` 避开 JLine 报错），DolphinScheduler 3.4.2
  （`http://localhost:12345/dolphinscheduler`，项目 `dw`）。

### 凭据配置（DS 部署工具链）

**源码里不保留任何口令字面量**（2026-10-22 起）。`tools/ds-deploy/` 全部脚本的
凭据统一由 `tools/ds-deploy/ds_config.py` 读取，优先级：

1. 进程环境变量
2. `tools/ds-deploy/.env.local`（仓库内，已 gitignore）
3. `~/.dw-secrets.env`（用户级，已 gitignore）
4. 都没有 → **报错退出**（不回退到弱缺省密码）

```bash
# 首次配置（或直接写 tools/ds-deploy/.env.local）
export DS_ADMIN_PASSWORD='...'   # DS admin（仅确实需要管理权限时）
export DS_PASSWORD='...'         # DS 脚本专用账号 ds_script（推荐）
export DS_PG_PASSWORD='...'       # DolphinScheduler 元库
export DS_HIVE_PASSWORD='...'     # Hive beeline
python3 tools/ds-deploy/ds_config.py   # 自检：只报在/缺，不打印值
```

- `ds_script` 是**脚本专用账号**，与浏览器 UI 的 `admin` 分离 —— DS 3.4.2 的会话表
  同 user 只保留 1 行，脚本用 admin 登录会**踢掉 UI 会话**（`ds_client.py` 有护栏）。
- ⚠ 已知残留：beeline 的 `-p` 会把 Hive 口令放进 `docker exec` 的 argv，
  同机其他用户可用 `ps` 读到。彻底消除需改用 stdin 提示，但校验脚本的 stdin
  已被 SQL 占满（`docker exec -i`），二者无法共存。

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

### SQL 编译校验（DWD）

生成器重跑后，把 DWD 脚本拿到**真实 Hive** 上编译一遍（只编译、不执行）：

```bash
# 原理：先把生成 DDL 建进临时 schema dwdxday_syn_chk（隔断集群旧表漂移），
# 再用 EXPLAIN INSERT 逐条编译 02_etl/*.sh 里的 SQL
python3 tools/ds-deploy/validate-dwd-syntax.py                 # 全量（DDL+ETL）
python3 tools/ds-deploy/validate-dwd-syntax.py --etl-only      # 只校验 ETL
python3 tools/ds-deploy/validate-dwd-syntax.py --sys O32       # 只校验某系统的 ETL（DDL 恒全量）
python3 tools/ds-deploy/validate-dwd-syntax.py --only DWD_AGMT_DPSI_AGMT_PFD  # 只校验指定表
```

- 输出 `tools/.dx-tmp/dwd-syntax-check.json`；`ParseException`=语法、`Error 10044`=列数不符、`Table/Column not found`=上游缺失。
- ⚠ 2026-10-11 的首版校验报告「174/174 通过」**因探针假阳性作废**（beeline 遇错仍继续、
  失败语句探针照样打印），教训已写进 `validate-dwd-syntax.py::run_batch` 注释。
- 2026-10-19（J-31）：沙箱模式把**表名**含 `_TMP` 的 DROP/CREATE 真执行（多段脚本列数假阴性
  根治）；`--sys` 只过滤 ETL，DDL 恒全量 → 单系统校验不必再退 `--real`。
- **真实执行**（重建 DDL + 落数据）用 `tools/ds-deploy/run-dwd-etl-direct.py`
  （默认读现役 `dep-config-proscript`，`--depcfg` 可回退旧口径 `dep-config-lineage`），
  其结果才是可信口径：

```bash
python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010            # 重建 DDL + 拓扑序真实执行
python3 tools/ds-deploy/run-dwd-etl-direct.py --date 20261010 --dry-run  # 只看拓扑序
```

### 运行测试

```bash
python3 -m unittest discover -s tools/tests -p "test_*.py"
```

CI：`.github/workflows/ci.yml` 在 push/PR 时跑同一命令（Python 3.12 + requirements）。

## DS 部署与校验工具（tools/ds-deploy/）

把生成器产物（DDL/ETL/血缘）落到 DolphinScheduler 的工具链，按用途分三类
（详细说明见 `tools/ds-deploy/README.md`，动手前必跑 `ds-check-running.py`）：

| 用途 | 脚本 |
|------|------|
| **导入 ODS/DWD/DWS 到 DS 环境** | `dw-pipeline.py deploy`（推荐，统一删除/重建/排版）；`ds-deploy-api.py`（plan/import，JSON 契约）；`ds-deploy-all-dwd.py`（DWD/DWS 全部作业按主题，`--layer DWD\|DWS`）；`ds-deploy-dwd-workflow.py`（单个 DWD/DWS 工作流含依赖+布局）；`ds-deploy-ods-all.py`（ODS）；`ds-sync-ods-scripts.py` / `ds-sync-dwd-scripts.py`（重跑后只推变更脚本） |
| **DWD/DWS 血缘 → 作业工作流** | `ds-build-dependent-from-lineage.py`（读 `scripts/*/dwd/lineage/DWD_lineage.xlsx`）；`ds-build-dws-dependent-from-lineage.py`（读 `scripts/*/dws/lineage/DWS_lineage.xlsx`）；输出 `tools/ds-deploy/dep-config-proscript` / `dep-config-dws`，配合 `ds-deploy-dwd-workflow.py` 落 DS |
| **ODS/DWD/DWS 工作流排版** | `ds-relayout.py`（dwd/ods/dws 三用，坐标重排，只改 locations）；`ds-verify-dwd-layout.py`（回读复算 DWD 布局质量） |
| **SQL 编译校验** | `validate-dwd-syntax.py`（见上文「SQL 编译校验」） |
| **真实执行 DWD ETL** | `run-dwd-etl-direct.py`（重建 DDL + 按血缘拓扑序直跑 Hive，落真实分区数据；`--date` 指定分区日期，报告 `tools/.dx-tmp/dwd-etl-run.json`） |

## DWD 搬移与血缘（tools/dwd-pipeline.py）

把甲方 DWD 脚本搬进仓库、按 MAPPING 归属、生成依赖关系 xlsx 与 DS 依赖配置的
一条龙工具（合并原 `tools/.dx-tmp/_*.py` 12 个临时脚本，默认 dry-run，`--apply` 落盘）：

| 子命令 | 作用 |
|--------|------|
| `owner` | 扫描 `04-源与目标映射MAPPING/01-DWD/` → `tools/.dx-tmp/dwd_owner_map.json` |
| `convert` | 甲方 `05-脚本/02-脚本/01-DWD执行脚本/*.txt` → `scripts/{系统}/dwd/02_etl`（J-28 方言修复，跳过 _INIT） |
| `distribute` | 统计分布与 DDL 表数、写 `scripts/_DWD搬移清单.json` |
| `ddl` | 甲方建表脚本补/替 DDL、方言清洗、重建各系统 `scripts/{系统}/dwd/01_ddl.sql` + `scripts/建表语句/` |
| `lineage` | 脚本依赖梳理 → `scripts/DWD_依赖关系.xlsx`（7 sheet：引导页 + 依赖明细/汇总/表级血缘/无同名脚本上游/跨组依赖/语法校验/说明） |
| `depcfg` | xlsx → `tools/ds-deploy/dep-config-proscript/*.dep.json`（配置表自动过滤） |
| `verify` | `bash -n`、DDL 完整性（ddl/*.sql 是否并入 01_ddl.sql）、可选 DS 来源审计 |
| `all` | 按 owner→convert→distribute→ddl→lineage→depcfg→verify 串跑 |

```bash
python3 tools/dwd-pipeline.py all            # 全流程 dry-run
python3 tools/dwd-pipeline.py all --apply    # 落盘
python3 tools/dwd-pipeline.py all --apply --ds  # 末尾连 DS 审计脚本来源
```

工作流重建 / 排版 / 删除优先走 `tools/dw-pipeline.py deploy|delete|layout`；
直接调 `ds-deploy-all-dwd.py`、`ds-relayout.py dwd|dws` 仍可用。
`tools/ds-deploy/ds-dwd-pipeline.py` 已于 **2026-10-29 退役**（归档 `tools/.archive/retired/`），
其 `lineage/diff/config/deploy` 能力由本工具与 `tools/dw-pipeline.py verify` 承接。

## DWD+DWS 一体化（tools/dw-pipeline.py）

统一入口，默认 dry-run，`--apply` 才落盘/动 DS：

```bash
python3 tools/dw-pipeline.py all --source jf --layers DWD,DWS --apply
python3 tools/dw-pipeline.py all --source jf --layers DWD,DWS --apply --deploy
python3 tools/dw-pipeline.py deploy --layers DWD,DWS --apply
python3 tools/dw-pipeline.py verify --layers DWD,DWS --ds
```

> 参数按子命令裁剪：`verify` 只有 `--layers/--ds`，`deploy|delete|layout` 只有 `--layers/--apply`，
> `--allow-gen-errors/--force-dws-raw` 只挂在 `scripts` 上；参数必须写在子命令**之后**（`verify --layers DWS`）。

| 子命令 | 作用 |
|--------|------|
| `scripts` | jf：DWD 调 `dwd-pipeline.py convert/distribute`；DWS 比对甲方 `02-DWS执行脚本` 与 `scripts/*/dws/02_etl`（现二者逐字节一致，比对仅防漂移；`--force-dws-raw` 等价空操作）。gen：`tools/main.py --layer DWD\|DWS` 生成到 `scripts/.dw-gen-*`，扫 `[ERROR` 失败即停；DWD 不碰 `scripts/MASTER` |
| `ddl` | jf：DWD 调 `dwd-pipeline.py ddl`；DWS **从甲方 `01-建表语句/02-DWS建表脚本.sql` 搬移**（清洗 `DEFAULT NULL`/`VARCHAR2`，逐表落 `ddl/*.sql` 并重建 `01_ddl.sql`）。gen：只校验既有产物 |
| `lineage` | DWD 调 `dwd-pipeline.py lineage`；DWS 校验 3 份 `DWS_lineage.xlsx`（表级 160 行） |
| `config` | DWD → `dep-config-proscript`（112 表/10 工作流）；DWS → `dep-config-dws`（24 表/3 工作流），并刷新 `scripts/DWS_表中文名.json` |
| `delete` | 先删 `DWS_*` 再删 `DWD_*`；只删 DWD 时若 DWS 仍存在会拒绝 |
| `deploy` | 预删 DWS → 删/建 DWD → 建 DWS（拓扑 `HSFA→O32→ZTA`）→ relayout |
| `layout` | `ds-relayout.py dwd\|dws` |
| `verify` | DWD 本地/`--ds` 来源审计；DWS 24 脚本、24 依赖配置、3 工作流 ONLINE、脚本逐字节一致 |
| `all` | `scripts→ddl→lineage→config→verify`；加 `--deploy` 再串 `deploy` |

- gen 模式：DWD 生成 87 个（当前 89 个非主数据脚本，差集为 `_INIT`/无 MAPPING 表，不自动删旧脚本）；
  DWS 生成 24 个但 3 张表 MAPPING 有缺口，默认直接失败，需 `--allow-gen-errors` 才复制。
- 部署基线（2026-10-20）：`DWS_HSFA/DWS_O32/DWS_ZTA` ONLINE，24 SHELL + 24 dep，
  跨流依赖 26/78/28 条，布局交叉 0；DWD 10 工作流/112 表保持 ONLINE。

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
   - `excel_reader.py`: Excel 快速读盘（可选依赖 python-calamine，全量 A/B 验证语义等价，
     不可用自动回退 openpyxl；`DW_NO_CALAMINE=1` 可强制回退对比）

## dw-pipeline.py 部署管线口径（2026-10-26）

- **失败即中止**：`deploy` / `delete` 任一步骤返回非 0 立即退出，不再「带着失败继续建 DWS」。
  旧行为会把「未部署」变成「DWS 引用缺失上游」的半坏状态，比不做更糟。
- **预检不只 apply 跑**：`check_dwd_only_preflight` 在 dry-run 也执行，仅降级为告警；
  真正拦截仍只在 `--apply`。避免「dry-run 说可以、apply 才被拒」。
- **甲方 DDL 缺失 = 失败**：`ddl --layers DWS --source jf` 找不到
  `05-脚本/01-建表语句/02-DWS建表脚本.sql` 时返回 1（原为静默跳过 ⇒ `all` 带着旧
  `01_ddl.sql` 一路假绿）。交付目录不可达用 `DW_DELIVERY` 指定；另有
  「产物早于来源」的 ⚠ 提示（verify 只查文件存在，查不出内容过期）。
- **verify 的 `bash -n` 口径**：脚本先 `\r\n`→`\n` 归一化，再经 **stdin**（`bash -n -`）
  执行，且 stdin 必须传 **bytes**。三个坑均已实测固化，勿退回旧写法：
  ① 文件路径方式下，cygwin bash 由 Windows 原生进程启动会吃掉 `C:\a\b` 的反斜杠
  （rc=127 `No such file`），24 个脚本全被判语法失败；
  ② `text=True` 在 Windows 会把 `\n` 反向翻译成 `\r\n`，CRLF 又回来、照样 `$'\r'` 报错；
  ③ 甲方交付的 DWS .sh 全部是 CRLF，不归一化则本地永远「0 个通过」。
  ⇒ 回归用例 `tools/tests/test_dw_pipeline.py::TestShellSyntax`。
- **`sanitize_ddl` 独立成模块** `tools/core/ddl_sanitize.py`（只依赖 `re`）：原先
  `dw-pipeline.py` 为复用它要 exec 整个 86KB `dwd-pipeline.py`（连带 openpyxl/pandas）
  ⇒ 缺 openpyxl 的环境里 DWS DDL 直接 `ModuleNotFoundError`。
- **`all` 带逃生舱**：`--allow-gen-errors` / `--force-dws-raw` 与 `scripts` 同步声明
  （`all` 内部就调 `scripts`，否则无法在一条命令内绕过生成器 ERROR）。
- **子进程上限**：默认 1800s（`DW_RUN_TIMEOUT` 可调），超时按 rc=124 失败，不再无限等。
- **DWS 口径常量化**：`DWS_EXPECT_SCRIPTS` / `DWS_EXPECT_DEPS` / `DWS_EXPECT_WORKFLOWS`
  / `DWS_WF2SYS` 集中在文件头，口径变更只改一处。

## 拼接副本脚本的处置口径（2026-10-26 用户定稿）

- **口径**：类似 `DWS_PROD_SALE_DATA_PTD.sh` 这种「甲方 txt 是两份脚本拼接」的交付，
  一律**只保留第一个 `beeline` 对应的完整 SQL**（截到第一份循环体的 `done`），
  其后粘连的副本整段丢弃。
- **判定信号**：行首 `inceptor_beeline "`（带 SQL 参数的调用；函数定义 `inceptor_beeline()`
  不含引号）出现 **≥2 次** ⇒ 视为拼接副本。截断点 = 第一处行首 `done`
  （`done#!/bin/sh` 这类粘连形态截到 `done` 为止，并补回换行）。
- **两份 SQL 不一致时不自动改**：口径优先但不能默默丢内容 ⇒ 只提示、rc=1、需人工确认。
- **工具**：`python tools/dw-pipeline.py repair --layers DWS [--apply]`
  （默认 dry-run；落盘前备份到 `tools/.dx-tmp/backup-repair-<ts>/<系统>/`）。
  实现在 `tools/core/sh_repair.py`（只依赖 re），`dw-pipeline.py` 仅负责扫描/备份/落盘/标注。
- **三道防回归门**：
  1. `verify` 对「SQL 调用 >1」单独报 `⚠ 拼接副本`（语法可能是通的，但会重复执行 SQL）；
  2. 修复后的文件带 `# DW-DEVIATION: …` 标记 ⇒ `stage_dws_from_jf` **连 `--force-dws-raw`
     也不覆盖**（否则会把修复连同甲方缺陷一起还原）；`scripts` 步骤会打印「已知偏离」清单；
  3. 单测 `test_repo_scripts_have_single_sql_block` 对仓库全部 DWS 脚本做守门断言。
- **已处置**：`scripts/HSFA/dws/02_etl/DWS_PROD_SALE_DATA_PTD.sh`
  （甲方 7678 字节 → 4023 字节；两份 SQL 各 3042 字符、逐字符相同，丢弃无内容损失；
  `bash -n` 由 `unexpected end of file` 转为通过；`_DWS搬移清单.json` 的 bytes/sha256
  已同步并加 `deviation` 字段）。
- **教训（值得记）**：清单原登记该文件为 **3755 字节**且 `verification.shell_syntax=24/24`
  ⇒ 说明**此前修过一次，后来又被甲方原文覆盖回缺陷版**。这也是加 `DW-DEVIATION` 哨兵的原因。
- **不动**：`DWS_PROD_SCR_PL_DETAIL_PTD.sh` 只有 1 个 SQL 块（循环体内那句游离 `#!/bin/sh`
  是注释、`bash -n` 通过），按口径无需处理。

## DDL 对账与漏搬补齐（2026-10-27）

- **对账口径**：Hive `DWDXDAY`/`DWSXDAY` 实际建表 vs 仓库聚合 `01_ddl.sql`（与单表 `*/ddl/*.sql` 一致）。
- **结果**：DWD 161 vs 156（Hive 多 5 张）、DWS 37 vs 36（Hive 多 1 张）；**反向差集为 0**（仓库无 Hive 无的表，口径健康）。
- **补齐（已落盘+已备份）**：
  - 5 张单表 DDL 从甲方建表脚本搬入：`DWD_PTY_ORG_FTDICTIONARY_PTD_INT`、`DWD_PTY_ORG_ZTDICTIONARY_PTD_INT`、`DWD_PTY_ORG_NUM_MAPP_PFD_2`、`DWD_PROD_PROD_TAIL_PFD_INIT_TMP`（4 张进 `scripts/MASTER/dwd/ddl/` 并同步进 `MASTER/dwd/01_ddl.sql`，65→69 张）；`DWS_TRAN_FUTR_TRAN_DETAIL_PTD`（1 张进 `scripts/O32/dws/ddl/` 并同步进 `O32/dws/01_ddl.sql`，8→9 张，同时修复了该文件原为 2 行坏文件的问题）。
  - 聚合 `01_ddl.sql` 中 13 张 PTY INT 表段落已用单表文件新列数替换（`c_identityno`/`id`/`*_modify_time` 补齐，与线上表 `desc` 一致），备份在 `tools/.dx-tmp/backup-replace-only-20261027-093722/`。
  - 搬移清单 `_DWD搬移清单.json`：`assign` 补登记 5 条（4 张→主数据，FUTR→O32，86→91 条）；`ddl` 统计刷新为现盘单表文件数（HSFA 23 / HSZTA 31 / O32 39 / 主数据 67）。
- **CHNL 无后缀表（记录偏离，不做变更）**：Hive 有一张 `DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO`（**0 行、无分区**），但甲方建表脚本里只有 `DWD_CHNL_CHNL_BASIC_INFO_PFD`，19 个 CHNL ETL 脚本引用的也全是 `_PFD` 版（经精确词界核对，无对无后缀表的引用）。处置：**保持现状，脚本零改动、不补 DDL**（甲方脚本中无此名、表为空孤儿，不属漏搬）；如需追溯，以 Hive `show create table DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO` 为准；下次对账时不再将其列为漏搬。