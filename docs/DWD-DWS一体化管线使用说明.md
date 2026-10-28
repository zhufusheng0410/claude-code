# DWD + DWS 一体化管线使用说明

## 1. 脚本位置

统一入口：

```text
tools/dw-pipeline.py
```

`tools/dwd-pipeline.py` 仍然保留，负责 DWD 层的甲方脚本搬移、DDL、血缘和依赖配置；
`dw-pipeline.py` 在它之上增加了 DWS，并统一了脚本来源、依赖配置、DS 删除/重建、排版和校验。

所有命令都在 **仓库根目录** 执行（Windows 原生 / WSL 均可）：

```bash
cd /mnt/c/Users/84148/Desktop/trae/claude-code   # WSL
# 或 C:\Users\84148\Desktop\trae\claude-code      # Windows 原生
```

> ⚠ Windows 原生跑时不要依赖 `/mnt/c`、`/mnt/d` 字面路径：Windows 会把它们解析成
> **当前盘符下的相对路径** `\mnt\c\…`，历史运行留下的镜像目录会让 `exists()` 假真，
> 产物全部写进假仓库。工具已改为 `__file__` 定位仓库 + 按哨兵子目录 `05-脚本` 判定交付目录。

---

## 2. 两种脚本来源

### `--source jf`（推荐，当前基线）

| 层级 | 来源 | 说明 |
|------|------|------|
| DWD | `05-脚本/02-脚本/01-DWD执行脚本/*.txt` | 调用 `tools/dwd-pipeline.py convert/distribute` |
| DWS | `scripts/{HSFA,HSZTA,O32}/dws/02_etl/*.sh` | 24 个**甲方原文**脚本（逐字节一致），权威源 |

DWS 比对方向固定为：

```text
甲方 05-脚本/02-脚本/02-DWS执行脚本/*.txt  ->  scripts/{系统}/dws/02_etl/*.sh
```

仓库内 DWS 脚本**就是甲方原文**：2026-10-26 复核 24/24 与甲方 `02-DWS执行脚本/*.txt` 逐字节一致
（甲方交 25 个，少的 `DWS_TRAN_MKT_TRAN_PR_STAT_PTD` 因 3 份 MAPPING 都没有它而按「无 MAPPING 不纳管」排除）。
管线仍保留「甲方 → 仓库」的比对步骤用于防漂移；`--force-dws-raw` 目前等价空操作。
（旧文档说的「已修复版 / `baseline=repaired-current`」已过期。）

### `--source gen`（自动生成）

| 层级 | 来源 | 说明 |
|------|------|------|
| DWD | `tools/main.py --layer DWD` | 不触碰 `scripts/MASTER` |
| DWS | `tools/main.py --layer DWS` | 生成到 `scripts/.dw-gen-*` 临时目录 |

生成器日志中出现 `[ERROR` 时，管线默认立即失败，不复制产物。
DWS 目前有 3 张表 MAPPING 缺口，不能静默使用 gen 模式，详见第 8 节。

---

## 3. 参数（按子命令裁剪）

```bash
python3 tools/dw-pipeline.py <子命令> [参数]
```

参数**只挂在真正用它的子命令上**，`<子命令> --help` 看到的就是该命令的全部可用开关
（早期版本把 7 个开关挂在每个子命令上，`verify --help` 里会混进 `--deploy` 这类无关项）。

| 参数 | 默认 | 作用 | 可用子命令 |
|------|------|------|-----------|
| `--layers DWD,DWS` | `DWD,DWS` | 处理层级，可只写 `DWD` 或 `DWS`（拼错会直接报错） | 全部 |
| `--source jf\|gen` | `jf` | 脚本来源 | `scripts` `ddl` `all` |
| `--apply` | 否 | 真正写文件/操作 DS；不加就是 dry-run | `scripts` `ddl` `lineage` `config` `delete` `deploy` `layout` `all` |
| `--ds` | 否 | 连接 DolphinScheduler 回读校验 | `verify` `all` |
| `--deploy` | 否 | 末尾追加 DS 删除/重建/排版 | `all` |
| `--allow-gen-errors` | 否 | gen 模式忽略 `[ERROR` 并继续复制，不推荐 | `scripts` |
| `--force-dws-raw` | 否 | 用甲方 DWS 原文覆盖仓库脚本（当前二者一致，等价空操作） | `scripts` |

> 默认 dry-run。确认输出无误后再加 `--apply`。
> 参数必须写在子命令**之后**（`verify --layers DWS`）；写在前面（`--layers DWS verify`）会报错。

---

## 4. 子命令

| 子命令 | 作用 |
|--------|------|
| `scripts` | 同步/生成脚本；jf DWS 比对甲方原文与 `scripts/*/dws/02_etl`（默认不覆盖） |
| `ddl` | DWD 调 `dwd-pipeline.py ddl`；DWS **从甲方 `05-脚本/01-建表语句/02-DWS建表脚本.sql` 搬移**（清洗 `DEFAULT NULL`/`VARCHAR2`，逐表落 `ddl/*.sql` 并重建 `01_ddl.sql`） |
| `lineage` | DWD 重建 `scripts/DWD_依赖关系.xlsx`；DWS 校验 3 份 `DWS_lineage.xlsx` |
| `config` | 生成 DWD `dep-config-proscript` 和 DWS `dep-config-dws`（24 表）；DWD 份数以 `depcfg` 运行时打印为准，不写死 |
| `delete` | 删除 DS 工作流，固定先删 `DWS_*` 再删 `DWD_*` |
| `deploy` | 预删 DWS → 删/建 DWD → 建 DWS → relayout |
| `layout` | 只重排坐标，不改依赖和脚本 |
| `verify` | 本地脚本/血缘/配置校验；加 `--ds` 后回读 DS |
| `all` | `scripts → ddl → lineage → config → verify`；加 `--deploy` 再串 `deploy` |

---

## 5. 常用命令

### 5.1 DWD + DWS 全流程，只落盘

```bash
python3 tools/dw-pipeline.py all --source jf --layers DWD,DWS --apply
```

执行内容：

1. DWD：甲方 txt → `scripts/*/dwd/02_etl`（含 `scripts/_DWD搬移清单.json`）
2. DWS：比对甲方 `02-DWS执行脚本` 与 `scripts/*/dws/02_etl`
3. DWD DDL 重建
4. DWD 依赖关系 xlsx 重建
5. DWD/DWS 依赖配置生成
6. 本地校验

不会动 DS。

### 5.2 全流程 + 重建 DS

```bash
python3 tools/dw-pipeline.py all --source jf --layers DWD,DWS --apply --deploy
```

会在 5.1 之后执行：

1. 删除现有 `DWS_*`
2. 删除并重建 `DWD_*` / `MASTER_*`
3. 按拓扑序创建 DWS：`DWS_HSFA → DWS_O32 → DWS_ZTA`
4. DWD/DWS 排版
5. `verify --ds`

> 这是**破坏性操作**，会删除并重建 DS 上的 DWD/DWS 工作流。
> 执行前先确认没有正在运行的批次。

### 5.3 只处理 DWS

```bash
python3 tools/dw-pipeline.py all --source jf --layers DWS --apply --deploy
```

只影响 DWS：

- 同步 24 个脚本
- 生成 24 份依赖配置
- 删除/重建 3 个 DWS 工作流
- 排版并校验

不会删除 DWD。

### 5.4 只重建/排版 DS，不重跑脚本和配置

```bash
# 重建 DWD + DWS
python3 tools/dw-pipeline.py deploy --layers DWD,DWS --apply

# 只重排 DWS
python3 tools/dw-pipeline.py layout --layers DWS --apply
```

`deploy` 默认使用已经生成的脚本和 `dep-config-*`，不会重新生成它们。

### 5.5 删除工作流

```bash
python3 tools/dw-pipeline.py delete --layers DWD,DWS --apply
```

删除顺序固定为：

```text
DWS_*  ->  DWD_* / MASTER_*
```

如果只删 DWD 且 DS 上仍有 DWS，工具会拒绝执行，避免 DWD 被 DWS 依赖引用挡住。

### 5.6 校验

```bash
# 本地
python3 tools/dw-pipeline.py verify --layers DWD,DWS

# 本地 + DS
python3 tools/dw-pipeline.py verify --layers DWD,DWS --ds
```

DWS 校验项：

- `scripts/*/dws/02_etl` 24 个脚本 `bash -n` 全部通过
  （环境安全策略拦住 bash 时记「无法判定」并告警，不判失败——避免全量假报错）
- 24 份 `dep-config-dws/*.dep.json`
- 3 个工作流存在且 ONLINE
- SHELL 作业数 7/9/8
- 依赖节点非空
- DS 中的 `rawScript` 与本地脚本一致

### 5.7 gen 模式

```bash
# DWD 自动生成
python3 tools/dw-pipeline.py all --source gen --layers DWD --apply

# DWS 自动生成（当前会因 MAPPING 缺口失败）
python3 tools/dw-pipeline.py all --source gen --layers DWS --apply
```

DWS gen 失败时会打印 `[ERROR` 日志并停止。`--allow-gen-errors` 只建议用于排查，
不建议带着错误直接部署。

---

## 6. 产物与路径

| 产物 | 路径 |
|------|------|
| DWD 脚本 | `scripts/{系统}/dwd/02_etl/*.sh`（主数据 `scripts/MASTER/dwd/02_etl/*.sh`） |
| DWS 脚本 | `scripts/{系统}/dws/02_etl/*.sh` |
| DWD DDL | `scripts/{系统}/dwd/01_ddl.sql`、`ddl/*.sql`；汇总 `scripts/建表语句/` |
| DWS DDL | `scripts/{系统}/dws/01_ddl.sql`、`ddl/*.sql` |
| DWD 血缘 | `scripts/DWD_依赖关系.xlsx` |
| DWS 血缘 | `scripts/{系统}/dws/lineage/DWS_lineage.xlsx`、`scripts/DWS_lineage.xlsx`、`scripts/DWS_依赖关系.xlsx`（含「引导页」：各 sheet 内部跳转 + 关联文件相对路径外链） |
| DWD 依赖配置 | `tools/ds-deploy/dep-config-proscript`（Windows：`tools/ds-deploy/dep-config-proscript`） |
| DWS 依赖配置 | `tools/ds-deploy/dep-config-dws`（Windows：`tools/ds-deploy/dep-config-dws`） |
| DWS 中文名 | `scripts/DWS_表中文名.json` |
| DWD 中文名 | `scripts/DWD_表中文名.json`（供 DS 作业描述读取，**非本管线生成**，缺失时作业描述回退为表名） |
| 搬移清单 | `scripts/_DWD搬移清单.json`、`scripts/_DWS搬移清单.json` |
| 依赖校验报告 | `scripts/DWD_DS依赖校验.md` |
| 运行报告 | `tools/.dx-tmp/` |

---

## 7. 当前基线（2026-10-20）

DWS：

- 24 张表：HSFA 7 / HSZTA 8 / O32 9
- 24 个脚本，`scripts/*/dws/02_etl` 全部 `bash -n` 通过
- 24 份依赖配置
- 3 个工作流：`DWS_HSFA`、`DWS_O32`、`DWS_ZTA`
- 全部 ONLINE
- 24 个 SHELL + 24 个依赖节点
- 布局交叉 0
- 拓扑序：`DWS_HSFA → DWS_O32 → DWS_ZTA`

DWD：

- 10 个工作流，全部 ONLINE；成员表/作业数/依赖项以 `depcfg` 打印为准（不写死，避免过期）
- DS 中的 rawScript 与 `scripts/*/dwd/02_etl` 逐字节一致（由 `ds-sync-dwd-scripts.py` 保证）
- 占位仅剩 `DEFAULT_EMPTY` 3 张（SALE_FEER / TAIL / WARN_HIS，临时表族结构缺口）
- **主数据跑真实脚本**（2026-10-23 用户拍板，旧 `MASTER_EMPTY_TPL` 口径作废；`--master-placeholder` 可回滚）
- **工作流归属例外**写 `WORKFLOW_OVERRIDE`（两处同步）；**上游读前一日分区（T-1）⇒ 不配调度依赖**
- 两条口径的判定与处置见 `docs/功能与规范文档.md` §15.3

---

## 8. 已知阻塞

### 8.1 DWS gen 模式 MAPPING 缺口

以下 3 张表生成 SQL 会报错：

| 表 | 问题 |
|----|------|
| `DWS_PROD_INFO_PFD` | T13 括号不平衡；T19–T23 未定义 |
| `DWS_TRAN_MKT_TRAN_CNFM_PTD` | ONT1、T10、T12、T2–T8 未定义 |
| `DWS_PROD_SCR_TRAN_DETAIL_PTD` | A1 括号不平衡；A2–A12 未定义 |

处理方式：

1. 修 MAPPING 后重新跑 `--source gen`；或
2. 继续使用 `--source jf`（`scripts/*/dws/02_etl` 已 24/24 通过 Hive EXPLAIN）。

### 8.2 OA ODS 表缺失

`ODS_OA_AGENCY_VIEW_PFD` 在集群中缺失，影响：

- `DWD_CHNL_EXT_BTCH_INFO_PFD`
- 部分 `DWS_ZTA` 表

需要 OA 抽数任务落地后复验。

---

## 9. 排查建议

1. 先跑不带 `--apply` 的 dry-run，确认新增/更新/删除数量。
2. DS 操作前确认没有运行中的批次。
3. 只部署 DWD 时如果 DS 上还有 DWS，改用：

   ```bash
   python3 tools/dw-pipeline.py deploy --layers DWD,DWS --apply
   ```

   或先单独删除 DWS：

   ```bash
   python3 tools/dw-pipeline.py delete --layers DWS --apply
   ```

4. DWS 脚本不一致时，优先比对甲方 `02-DWS执行脚本` 与 `scripts/{系统}/dws/02_etl` 的差异。
5. gen 模式失败时不要加 `--allow-gen-errors` 直接部署，先修 MAPPING。
6. `verify` 打印「无法判定 N」而不是「语法通过 N」时，是本机 `bash` 被安全策略/路径问题挡住
   （常见于 `bash` 解析到 WSL 启动器），不是脚本语法错；换 Git Bash 的 bash 再验一次即可。
