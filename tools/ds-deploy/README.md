# ds-deploy —— 把生成器产物部署到 DolphinScheduler

> ★★★ **2026-10-11 起：本目录是 DS 工具的唯一权威源（single source of truth）。**
> 此前 `D:\datax\tools\ds-*.py` 与本目录**并存且已双向漂移**（各有独有脚本、10+ 个同名文件内容不同）。
> 2026-10-11 已按「取更新版本」把两边**合并到本目录**（47 个 `*.py`），
> **`D:\datax\tools` 下的 ds 脚本已全部删除**。⇒ **要改 DS 工具请直接改这里。**
>
> ⚠️ 旧的同步脚本 `ds-sync-tools-to-codegen.py`（方向 = `D:\datax\tools` → 本目录）**已作废，勿再运行**
> （会拿已删的旧文件回灌、覆盖这里的合并结果）。
>
> ★ **2026-10-15 二次精简：41 → 31 个 `*.py`**（退役 10 个：一次性探针 + 重复实现 + 已完成使命的脚本）。
>
> ★ **2026-10-26：`backup/` 整个归档目录已删除**（此前未纳入 git，删除后不可恢复）。
> 下文所有 `backup/retired-*` 路径均为历史记录，**已不存在**，勿据此查找文件。
>
> ★★★ **2026-10-26：依赖配置与一次性脚本从 `D:\datax\tools` 迁入本目录，仓库自此自包含。**
> 此前 `DEPCFG` / `OUT` 硬编码 `D:\datax\tools\dep-config-*`（仓库外），
> 生产方（`ds-build-dependent-from-lineage.py` 的 `OUT`）与消费方（`ds-deploy-dwd-workflow.py`
> 的 `DEPCFG`）曾因路径不一致导致部署报「缺 …/dep-config-lineage」跑不起来（2026-10-10 踩过）。
> 现在两边都指向本目录，统一由 `os.path.join(HERE, "dep-config-*")` 解析 ⇒ **Windows / WSL 都正确**。
>
> 迁入内容：
>
> | 目录 | 内容 |
> |---|---|
> | `dep-config-proscript/` (109) | **现役** DWD 依赖配置（`DW_DEPCFG` 默认） |
> | `dep-config-dws/` (24) | DWS 依赖配置（`DW_DEPCFG_DWS` 默认） |
> | `dep-config-lineage/` (111) | 旧口径 DWD 依赖配置（历史回退，`--dep-dir` 可指） |
> | `_expect/` (22) | 部署期望结果（`_diff_expect_vs_ds.py` 用） |
> | `_pipeline/` (9) | 管线 dry-run 日志与快照 |
> | `_debug-history/` (10) | 历史调试脚本归档 |
> | `_legacy/` (20) | 一次性分析/生成脚本（`gen-deploy.py`、`_build_lineage*.py`、`_check_*ods*.py`、`_probe_ods_*.py` 等）+ 结果 json/log |
>
> ⇒ **`D:\datax` 今后只管 docker 集群**（启停、镜像、bind mount 源、集群体检/YARN/Hive 客户端）；
> DS 调度、数仓血缘、建模全在本仓库。`ds-ui-patch/` 与 `apply-all-patches.py` 属部署链，
> **故意留在 datax**（前者是 compose bind mount 源，后者被 `start-cluster.sh` 调用）。
>
> 目的：生成器（`tools/main.py`）产出 DWD/ODS 脚本与血缘后，**就地**一键部署到 DS。

## 前置

```bash
pip install pyyaml          # ds-check-mount-sources / apply-all-patches 需要
```

默认连接的是本机集群（`http://localhost:12345/dolphinscheduler`，项目 `dw`）。
要指向别的 DS / 别的产物目录，设环境变量：

| 环境变量 | 默认 | 含义 |
|---|---|---|
| `DW_DS` | `http://localhost:12345/dolphinscheduler` | DS API 基址 |
| `DW_DS_USER` / `DW_DS_PWD` | `admin` / 无（**必须显式提供**） | 登录 |
| `DW_DS_PROJECT` | `dw` | 项目名 |
| `DW_REPO` | `C:\Users\84148\Desktop\trae\claude-code` | 脚本与血缘所在的生成器仓库根 |
| `DW_DEPCFG` | `tools/ds-deploy/dep-config-proscript` | DWD 依赖配置目录（DWS 用 `dep-config-dws`） |

> 2026-10-20：`ds-deploy-all-dwd.py` / `ds-deploy-dwd-workflow.py` 已支持 `--layer DWS`
> （依赖目录 `tools/ds-deploy/dep-config-dws`），`ds-relayout.py` 新增 `dws` 子命令。
> DWD+DWS 统一编排优先用 `tools/dw-pipeline.py deploy|delete|layout|verify`。

## 灾后重建（DS 定义层被清空时）

```bash
# 从 pg_dump 备份里读「原有工作流清单」，用当前脚本内容重建整个定义层。
# ★ 不要用 ds-deploy-ods-all.py --size 20 硬推切分（HSFA 原切分是 18/18/18/18/6，会被塌成 4 个）。
python ds-rebuild-from-inventory.py                      # 默认干跑，打印计划
python ds-rebuild-from-inventory.py --apply              # 真正重建（默认建完 OFFLINE）
python ds-rebuild-from-inventory.py --sys O32 --apply    # 只重建某系统
```

- 备份默认 `.dx-tmp/backup-ds-*.sql`（`--dump` 可指定）。
- **两阶段提交**：① 先建全部工作流（DWD 只建 SHELL）→ 回读 DS 分配的真实 code；
  ② 再 GET 追加 DEPENDENT 节点并回填依赖。**不能合并** —— 空 `dependTaskList` 非法（50020），
  且 DS **忽略客户端传的 workflow `code`**，前向引用在提交时拿不到 code。
- 内置「旧名 → 新名」回退表（按去 `_PFD/_PTD` 基名匹配），修 ODS 改名导致的依赖断裂。

## 批量改作业脚本（只改脚本，不动结构）

```bash
# 生成器重跑后，把本地已变更的 ODS 抽数脚本推回 DS。
python ds-sync-ods-scripts.py                                  # 干跑（minimal：只删 source 行）
python ds-sync-ods-scripts.py --apply                          # 真提交（保持 OFFLINE）
python ds-sync-ods-scripts.py --sys O32 --apply                # 只推某系统
python ds-sync-ods-scripts.py --mode full --apply              # 用本地脚本整体覆盖
python ds-sync-ods-scripts.py --only-changed-with scripts.bak --apply
    # 只推「与基线目录内容不同」的任务 —— 适合「本次只改了 X 规则」的场景
```

- **只改 `taskParams.rawScript`**，其余字段（依赖/布局/全局参数/`executionType`）原样回填。
- 自动**先置 OFFLINE 再 PUT**，建完保持 OFFLINE（不自动上线）。
- 内容逐字节比对，**只提交真变了的**；串行执行（同用户只 1 会话）。
- ★★★ **动手前必跑 `ds-check-running.py`**，有跑批就别动。

## ★★ 导入即排版（2026-10-15 统一，勿再事后补 relayout）

**问题**：三个脚本各自写死了排版参数，导出的图与「排版要求」不一致，导完还得手动跑一次 relayout：

| 脚本 | 旧参数 | 后果 |
|---|---|---|
| `ds-deploy-dwd-workflow.py`（现役 DWD 落地器） | `COL_W=340` | 340 < 节点宽 350 ⇒ dep 与作业左右叠 10px；且与全仓 500 口径分叉 |
| `ds-deploy-ods-all.py::build_locations` | `260 + (i%4)*416`，`140 + (i//4)*110` | 起点/列数/行高都与 relayout 不同 ⇒ 每排 4 列、起点偏右 |
| `ds-rebuild-from-inventory.py` | `260 + (i%4)*260` | 260 间距必叠 |

**已统一**（权威口径 = `ds-relayout.py` 的默认值）：

| 层 | 参数 | 依据 |
|---|---|---|
| DWD | `COL_W=500`、`X0=40`、`Y0=80`、`ROW_H=120`、**每排 3 对**、`PAIR_W=2*500+120=1120` | 500 > 节点宽 350，间隙 150px |
| ODS | `X0=40`、`Y0=80`、`ROW_H=120`、间距 `416`、每排 3 列 | 416 = 节点宽 350 + 66px 间隙 |

★ DWD 的 `--per-row` 默认已从 `auto` 改为 **`3`**：`auto`（按表数取 3~6 的近似矩形）会与 relayout 的
固定 3 分叉（12/13/15 表时取 4~5 对，实测 7/11 个工作流会不一致）⇒ 要 auto 就显式传 `--per-row auto`，
并接受「导完再补一次 relayout」。

⇒ **现在「导入 ODS / 重建 / 部署 DWD」生成的坐标就是最终版式**，跑完不需要再补 relayout；
`ds-relayout.py` 退化为**兜底/救援**工具（给历史上已存在、或人工拖乱过的工作流重新规整）。

★ 改任何一处参数，必须同步：`ds-deploy-ods-all.py`、`ds-rebuild-from-inventory.py`、
`ds-relayout.py`（dwd/ods 两个分支默认）、`ds-deploy-dwd-workflow.py`、`ds-deploy-api.py --col-w`，
否则又会分叉。DWD/ODS 两层刻意分层（500 vs 416），**别顺手统一成一个值**。

## 一条龙（推荐）

```bash
# 1) 生成血缘依赖配置（读 scripts/*/dwd/lineage/DWD_lineage.xlsx）
python ds-build-dependent-from-lineage.py

# 2) 同步 DWD 脚本到 DS（只提交 sha1 真正变了的）
python ds-sync-dwd-scripts.py          # 先看差异
python ds-sync-dwd-scripts.py --apply

# 3) 一键部署：作业 + 作业级依赖（JSON 中间契约）
python ds-deploy-api.py plan --subject DWD_PROD -o plan.json   # 本地 → JSON
python ds-deploy-api.py import -i plan.json --dry-run           # 看会改什么
python ds-deploy-api.py import -i plan.json                     # 落库

# 4) 收尾：依赖已是作业级；排版已由导入脚本内置（见上「导入即排版」），
#    仅在「规范改过 / 图被人手拖乱」时才需要补跑：
python ds-relayout.py dwd --col-w 500 --apply     # 兜底
python ds-relayout.py ods --apply                 # 兜底
```

## DWD 脚本 SQL 校验（`validate-dwd-syntax.py`）

生成器重跑后，把 DWD 脚本拿到**本机 Hive 4 容器**上编译一遍（**只编译、不执行、不落数据**）：

```bash
python validate-dwd-syntax.py                 # 全量（DDL+ETL，默认 3 会话并行）
python validate-dwd-syntax.py --etl-only      # 只校验 ETL
python validate-dwd-syntax.py --sys O32       # 只校验某系统的 ETL（DDL 仍全量建沙箱）
python validate-dwd-syntax.py --only DWD_AGMT_DPSI_AGMT_PFD   # 只校验指定表
```

原理：

1. 把 `scripts/*/dwd/01_ddl.sql` 的全部 CREATE TABLE 建进**临时 schema
   `dwdxday_syn_chk`**（跑完 `DROP DATABASE … CASCADE`，`--keep` 可保留）——
   既验证 DDL 语法，又给 ETL 一套「与生成物完全一致」的上游结构，
   **把「集群旧表漂移」与「生成脚本自身问题」隔离开**。
2. 从每个 `02_etl/*.sh` 抽出 `inceptor_beeline "…"` 块内的 SQL，替换
   `${p_end_dt}`/`${p_start_dt}` 日期变量、把 `DWDXDAY.` 换成临时 schema，
   用 `EXPLAIN INSERT OVERWRITE …` **逐条编译**。
3. 每条 SQL 后跟 `SELECT '__P__<n>__'` 探针，输出流按探针**切段**，
   **段内出现 `Error:` 即该条失败**。

- **2026-10-19（J-31）两处修正**：① 沙箱模式下**表名含 `_TMP` 的 DROP/CREATE 真执行**
  （多段脚本不再拿归档 DDL 顶替 → 列数假阴性根治，实证 `DWD_PTY_ORG_NUM_MAPP_PFD`；
  `--real` 模式绝不真执行）；② `--sys` **只过滤 ETL**，DDL 构建恒全量 ⇒ 单系统校验
  不必再退 `--real`（`--sys HSFA` 沙箱实测 149/149 + 20/20）。
- 报告输出 `tools/.dx-tmp/dwd-syntax-check.json`。
- ⚠ **2026-10-11 首版「87 DDL + 87 ETL 174/174 全部编译通过」是假阳性、已作废**：
  探针法原依赖「失败即停」，实测 beeline（stdin 模式）**遇错照样继续**、
  失败语句的探针也打印 ⇒ 全失败也会被报成全过。正确判定（切段找 Error:）
  写在 `validate-dwd-syntax.py::run_batch` 注释里，**勿回退到只看探针**。
- 依赖 hiveserver2 容器在跑；beeline 走 CUSTOM 认证（`hive/hive`），
  docker exec 记得 `-e TERM=dumb`。

## 真实执行 DWD ETL（`run-dwd-etl-direct.py`）

校验只证明「能编译」；要**落数据**用本工具——绕开 DS，beeline 直跑 Hive：

```bash
python run-dwd-etl-direct.py --date 20261010 --dry-run   # 只打印分层与顺序
python run-dwd-etl-direct.py --date 20261010             # 重建 DDL + 分层执行 + 行数回采
python run-dwd-etl-direct.py --date 20261010 --skip-ddl  # DDL 已对齐，只执行
python run-dwd-etl-direct.py --date 20261010 --only A,B  # 只跑指定表
python run-dwd-etl-direct.py --date 20261010 --no-count  # 跳过行数回采
```

- **先 DROP+CREATE 重建全部表**：生成的 `01_ddl.sql` 只有 CREATE 没有 DROP，
  对已存在的表必须自拼 `DROP TABLE IF EXISTS`，否则全部 `AlreadyExistsException`
  （2026-10-11 踩坑）；重建后目标结构与脚本 SELECT **严格一致**，
  天然规避线上旧表漂移导致的 `Error 10044`。
- **按 `dep-config-lineage` 血缘分层**执行：先 Kahn 拓扑定序，再在拓扑序上取**前向边**
  做最长路径分层 ⇒ 层号严格满足「上游层 < 下游层」，同层互不依赖。环按原序放开并告警。
- **默认串行 + 内存闸门**（`MemAvailable < 1.6GiB` 等待）。`--exec-par N` 可开**层内并行**，
  但 **并发 DAG > 2 会打爆 worker**（10-08 踩过）⇒ 非必要别调高（默认 1）。
  跑批前可先停 DS 容器腾内存（`docker stop dolphinscheduler-{api,master,worker,alert}`）。
- **行数回采**：执行后批量 `COUNT` 每张表 `P_DT=date` 行数，0 行单独标注
  （上游空转 / 分区无数据）；`--no-count` 可跳过。
- **EXCLUDE 5 张**指定排除表（编译即失败/含临时过程）不执行、只登记；
  DS 侧配**空脚本**保持依赖完整。`--exclude` 可通过常量 `EXCLUDE` 调整。
- **ODS 前置检查**：抽样 `ODS_HSFA_TACCOUNT_PFD` 的 `P_DT=date` 行数，为 0/查询失败则告警（非致命）。
- 成败判定 = 探针存在**且**探针前的输出段无 `Error:`（只看探针会假阳性，同上）。
- 报告 `tools/.dx-tmp/dwd-etl-run.json`（逐表耗时/成败/错误摘要 + 行数回采 + 0 行清单）。
- ★ **2026-10-15**：原 `run-dwd-etl.py` 的**分层 / 行数回采 / EXCLUDE / ODS 前置检查**已全部
  合并进本工具，该脚本随之退役（备份 `backup/retired-20261015-T2/`）。

## 注意（踩过的坑）

- `DSClient` **只有 `call(method, path, ...)`，没有 `get()`/`post()`**。
- `/projects/list` 用普通用户（如 `ds_script`）**可能返回空 list**（按项目授权过滤）
  ⇒ 查项目 code 用 `admin` + `searchVal=<项目名>`。
- `/projects/list` 的 `data` 是 **list**；`/projects/{code}/workflow-definition` 的 `data` 是 **dict**。
- 查任务数**别用 PSQL `count(*)`** —— `t_ds_task_definition` 主键是 `(code, version)`，
  `PUT` 会递增 version 留历史行。**API 的 `taskDefinitionList` 才是权威口径**。
- **空 `dependTaskList` 的 DEPENDENT 节点非法** ⇒ 接口报 `50020 parameter invalid`。
- **DS 忽略客户端传的 workflow `code`**，自己分配 ⇒ 前向引用必须两阶段回填。
- ★★★ **GET 单个工作流的返回是【嵌套】的**：`data = { workflowDefinition:{…},
  taskDefinitionList:[…], workflowTaskRelationList:[…] }`，`releaseState` 在**内层**。
  直接读 `data` 当工作流本体 ⇒ `name=None` ⇒ `10168 name None already exists`；
  在内层读不到 `releaseState` ⇒ 漏掉「先 OFFLINE」⇒ `50008 does not allow edit`。
  ★★ **改前必须实测当前 `releaseState`**，不要假设它还是 OFFLINE。

## JSON 契约（`ds-deploy-api.py`）

`schema = dw-ds-deploy/v1`，**用名字做键、不写死 code** ⇒ 同一份 JSON 可导入到不同环境的 DS。

```json
{"schema":"dw-ds-deploy/v1","project":"dw","workflows":[
  {"name":"DWD_PROD","tasks":[
     {"name":"X","taskType":"SHELL","script":"..."},
     {"name":"dep_X","taskType":"DEPENDENT","dependItems":[
        {"dependWorkflow":"ods_o32_etl_03","dependTask":"ODS_O32_T..._PFD",
         "dependentType":"DEPENDENT_ON_TASK"}]}],
   "relations":[["dep_X","X"],[null,"dep_X"]],
   "locations":{"X":[540,80],"dep_X":[40,80]}}]}
```

三个子命令：

| 子命令 | 方向 | 说明 |
|---|---|---|
| `export` | DS → JSON | 备份 / 迁移 / 人工编辑（`--only WF1,WF2`、`--match ods_`） |
| `plan` | 本地 → JSON | 脚本目录 + 血缘配置 ⇒ 作业 + **作业级**依赖 + 3 列布局 |
| `import` | JSON → DS | **幂等 upsert**（按名字合并，保留已有 code）；两遍建图回填依赖 |

## 铁律（踩过的坑）

1. ★★ **动 DS 前先跑 `ds-check-running.py`**（有跑批就别动）。
2. ★ **同一用户只有 1 个会话** ⇒ 别并发跑多个 `ds-*.py`（会 401 互踢）。
3. ★ **列间距必须 > UI 节点宽**（实测节点宽 **350**：DWD 用 500 ⇒ 间隙 150px；ODS 用 **416** ⇒ 间隙 66px。
   两层**刻意分层**，别统一）。2026-10-15 前 ODS 侧 `ds-deploy-ods-all.py`/`ds-rebuild-from-inventory.py`
   用的是 4 列 + 起点 (260,140)，与 relayout 不一致 ⇒ 已统一，见上「导入即排版」。
4. ★ 改工作流定义会**级联把定时调度置 OFFLINE** ⇒ 跑完查一次元库
   `select d.name, s.release_state from t_ds_schedules s join t_ds_workflow_definition d
    on d.code=s.workflow_definition_code;`
5. ★ 依赖一律**作业级**（`DEPENDENT_ON_TASK`）；只读 `p_end_dt_1` 历史分区的源表**不算当日上游**，自动剔除。
6. ★★ **2026-10-15 晚：跨工作流依赖回归作业级，勿再加 `gate_ods_fresh`**。10-14 曾按
   「上游最近 N 天成功过」改 `DEPENDENT_ON_WORKFLOW`，实测 DS 3.4.2 枚举白名单只认
   25 个无空格驼峰值（`"last 5 days"` 之类的值 9ms 秒败），且 `last N days` 语义是
   「窗口内**每天**都要有成功实例」⇒ 一度改用 SHELL 门禁 `gate_ods_fresh`（查 ODS
   分区新鲜度），但门禁**不是作业级**、绕过了 DS 依赖图。10-15 晚用户拍板回到作业级：
   `DEPENDENT_ON_TASK` + `dateValue=today`——**ODS 当天没跑 ⇒ DWD 一直 WAITING，
   就是合理批次语义**。重建走 `ds-deploy-all-dwd.py`（逆拓扑全删 → 正拓扑重建）。
7. ★★ **2026-10-15 晚：MASTER（主数据）按主题并入 `DWD_<主题>`，不建 `MASTER_*` 工作流**
   （用户决定「MASTER 和其他 DWD 放一起，按主题」）。三个连带口径：
   ① `ds-build-dependent-from-lineage.py` 的 `own_workflow()` 只按 `DWD_<主题>_` 前缀归属，
   血缘来自 `scripts/MASTER/dwd/lineage` 的表天然落进同主题（`TBL_LAYER` 仅作信息保留）；
   ② **`build_job_index` 必须覆盖实际存在的全部工作流前缀**——曾只收 `ods_`/`DWD_`，
   若出现 `MASTER_*` 则其作业不进索引 ⇒ 依赖被「DS 无此作业」**静默跳过**
   （实测 DWD_PROD 13 张表的 NUM_MAPP 跨依赖全丢、WARN_HIS 的 dep 节点被掏空）；
   ③ `ds-schedule.py` 的 `LAYERS`/`DWD_SLOTS` 必须与 `ds-deploy-all-dwd.py --dry-run`
   的拓扑序**严格同序**（改拓扑必须同步这里），当前 11 档 12:00→15:30、ODS 03:15 起每 15 分。
8. ★★ **2026-10-15 定稿：MASTER 主数据口径 + 同步双护栏**（docs/功能与规范文档.md J-28）：
   主数据脚本/DDL **直接取甲方交付**、血缘**手工定稿**于 `scripts/MASTER/dwd/lineage/DWD_lineage.xlsx`
   ⇒ **严禁 `main.py --layer DWD --sys-name MASTER` 重生成**（会覆盖甲方脚本与手工血缘）。
   DS 侧 23 个主数据作业**跑真实脚本**（★2026-10-23 用户要求，推翻 10-15「占位不跑」；
   回滚用 `ds-deploy-dwd-workflow.py --master-placeholder`）；
   `ds-sync-dwd-scripts.py` 对 `system==MASTER` 一视同仁推实脚本，仅对 `DEFAULT_EMPTY` 3 张
   （SALE_FEER/TAIL/WARN_HIS，临时表族多段结构待处置）**不推**——推后者跑批必失败。
   （AST_BAL / VOU 2026-10-16 修复转正（J-30、真编译通过），已移出本名单。）
   ⚠ 该工具历史写死 Windows 路径，现已加盘符→WSL 归一化（`_p()`），WSL 下可直接跑。

## DWD 作业级依赖部署（现役流程 · 2026-10-15 晚）

```bash
# 0) ⚠ scripts/MASTER **不可重生成**（2026-10-15 定稿 · J-28 ①）：主数据脚本/DDL 直取甲方交付
#    （05-脚本/02-脚本/01-DWD执行脚本、01-DWD建表脚本.sql），血缘手工定稿于
#    scripts/MASTER/dwd/lineage/DWD_lineage.xlsx；严禁 python tools/main.py --layer DWD
#    --sys-name MASTER（会覆盖甲方脚本与手工血缘）。丢失恢复 = 甲方交付包重取 + git 恢复血缘。

# 1) 血缘 → 依赖配置（tools/ds-deploy/dep-config-lineage，117 个 dep.json
#    = 87 消费方 + 23 主数据 + 7 个 _PTD 旧名孤儿〔PTY 后缀修复遗留，构建时自动跳过〕）
python ds-build-dependent-from-lineage.py

# 2) 逆拓扑全删 → 正拓扑重建 11 个 DWD 工作流（作业级跨工作流依赖）
#    ★ 主数据 23 张**配真实脚本**（2026-10-23 用户要求；`--master-placeholder` 可回滚旧占位口径）。
#      --empty-tables 仍可用于非主数据的临时占位（当前 DEFAULT_EMPTY 3 张已是内置默认；
#      AST_BAL/VOU 已修复转正（J-30））。
python ds-deploy-all-dwd.py --dry-run     # 只看拓扑序
python ds-deploy-all-dwd.py --empty-tables \
  "DWD_PROD_PROD_BASIC_INFO_PFD,DWD_SCR_O32_SCR_INCD_PFD,DWD_SCR_HSFA_SCR_INCD_PFD"

# 3) 复核：无 gate、一作业一依赖、跨工作流项数、ONLINE
python ds-dwd-pipeline.py diff            # 结构体检（逐节点三方比对：血缘 vs dep.json vs DS）

# 4) 定时调度（此前全 DS 0 条）：ODS 03:15 起每 15 分、DWD 按拓扑 12:00→15:30
python ds-schedule.py ensure --check      # 只体检
python ds-schedule.py ensure --apply      # 补 globalParams + 建调度 + 上线
python ds-verify-dwd-layout.py            # 排版复算（DWD 格式：dep 就近成对、零交叉）
```

- **工作流归属例外**（2026-10-23）：默认只认表名前缀 `DWD_<主题>_`；例外写 `WORKFLOW_OVERRIDE`
  （`tools/dwd-pipeline.py` 与同目录 `ds-build-dependent-from-lineage.py` **两处同步**）。当前 2 张：
  `DWD_PTY_OPER_FUND_PRVL_PFD`、`DWD_CMM_INTR_PARA_PFD` → `DWD_PROD`（唯一上游映射表在 PROD，
  否则成工作流级环/跨流长等待）。口径：**上游映射表在哪，表就放哪**。
- **T-1 免配调度依赖**（2026-10-23）：上游按批次日-1 分区读，字面形态为
  `DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')`
  （空白/换行任意；`UNIX_TIMESTAMP` 内可多包 `CAST(… AS STRING)`）⇒ `lineage` 标 `不配依赖(只读前一日)`、
  `depcfg` 跳过。**不是「含 `DATE_SUB` 就算」**（周/月偏移会误判）；`${P_BATCH_DT}` 变体只报不删。
  详见 `docs/功能与规范文档.md` §15.3。
- 空脚本占位只剩一类：**`DEFAULT_EMPTY` 3 张**（SALE_FEER / WARN_HIS / TAIL，临时表族多段结构待处置
  〔J-30〕，占位保依赖边、跑即过）。`ds-sync-dwd-scripts.py` 对此 3 张**不推实脚本**（否则跑批必失败）。
  ★ **主数据 23 张 2026-10-23 起恢复正常脚本**（`scripts/MASTER/dwd/02_etl/` 直接推 DS、按依赖参与跑批），
  旧 `MASTER_EMPTY_TPL` 占位口径作废（`--master-placeholder` 可回滚）。
  （AST_BAL / VOU 2026-10-16 修复转正〔J-30、真编译通过〕；整体 ETL 校验 107/110，余 3 = 临时表族。）
- 跨工作流项形如 `{definitionCode: <上游工作流code>, depTaskCode: <具体作业code>,
  dateValue: "today", DEPENDENT_ON_TASK}`；**无作业可等的源表自动跳过并打印清单**
  （甲方维表 `DWD_CMM_STD_DICT_CDVAL_MAP` 等、未部署的 ODS 表、6 条
  `ODS_MANUAL_SPEBA_MANUAL_INFO_PFD`（DS 有作业但本地无脚本、builder 解析不到））。
- ⚠ 重建工作流会换作业 code ⇒ **必须先全删再按拓扑序建**（DS 拒绝删被引用的工作流），
  逐个重建会让后建的依赖指向已失效的 code。
- ⚠ 重建后跨工作流依赖要等上游**新实例**（当天）才会放行——部署当天如需立即验证，
  按拓扑序触发（先 CMM/CHNL，再 PROD…），或等次日调度自然衔接。

## HTTP 层统一（2026-10-15）

历史脚本各自手写了一份 urllib HTTP 层（`login`/`call`/`_raw`），彼此重复且缺陷同源
（多为「401 只重试一次」「无超时重试」）。现已统一到 `ds_client.py`：

- **新增兼容封装** `legacy_client(...)` → 返回一个 `call(method, path, params=None, form=None,
  body=None, _retry=True)` + `login()` 的薄对象，让老脚本**不改调用形态**即可迁移。
- `ds_client.py` 的 form 编码改用 `doseq=True`（对纯标量无影响，list 值正确展开，与旧 `_raw` 一致）。
- `_retry=True` → 401 自动重登并重试（`raise_on_401=True`）；`_retry=False` → 不重登。
- **已迁移 12 个脚本**（历史记录；其中 `ds-inventory-ods` / `ds-create-datasource` /
  `ds-list-datasources` 已于 2026-10-21 退役）：`ds-wipe-workflows` · `ds-run-hive-sql` ·
  `ds-deploy-ods-all` · `ds-check-running`（+ 原有 `ds-run` / `ds-schedule` /
  `ds-sync-dwd-scripts` / `ds-sync-ods-scripts` / `ds-rebuild-from-inventory`）。
  共删掉约 **163 行**重复 HTTP 实现。
- 等价性验证（当时）：`ds-inventory-ods` / `ds-wipe-workflows` / `ds-check-running` 三个脚本
  「改造前 vs 改造后」输出**逐字节一致**。

★ **仍有 4 个脚本自实现 HTTP 层，暂不迁移**（有隐性契约，需专门一轮 + 部署演练）：
`ds-deploy-dwd-workflow.py` 是 **7 个脚本的公共 HTTP 库**（`D.call` 40+ 处），且把会话存在
**模块级可变全局 `SID`**，外部还会 `D.SID = ...` 直接改写（`ds-deploy-all-dwd` 2 处、
`ds-verify-dwd-layout` 1 处）。

## 工具清单（2026-10-21 更新 · 22 个）

> - **2026-10-21**：退役 9 个一次性/已被覆盖脚本：`ds-check-task-overlap` / `ds-convert-deps-task-level` /
>   `ds-list-workflow-level-deps` / `collect-ods-run` / `check-dwd-ddl-sync` / `ds-inventory-ods` /
>   `ds-task-log` / `ds-list-datasources` / `ds-create-datasource`。
> - **2026-10-11**：原 **47 个精简为 33 个** —— 删 3 个已被取代的（`ds-deploy-ods-workflows` / `ds-build-dependent` / `run-ods-serial`），
>   并把 **5 组同职责脚本合并**为统一 CLI（见下"〔并 …〕"）。原件备份在 `D://datax//backup//2026-10-11-ds-deploy-consolidate//`。
> - **2026-10-15**：整体 **41 → 31 个 `*.py`**。退役 10 个（下表已剔除）：
>   · **一次性探针（T1）**：`_probe_dup` / `_probe_parse` / `_verify_mapp` / `_trigger_dwd_prod` / `_verify_onedep.sql`
>     → `backup/retired-20261015-T1/`
>   · **重复实现 · 已完成使命（T2）**：`ds-deploy-dwd-dependent`（被 `ds-deploy-dwd-workflow` 覆盖）/
>     `run-dwd-etl`（能力并入 `run-dwd-etl-direct`）/ `ds-rename-ods-vars` / `ds-batch-fix-ods-path` /
>     `ds-add-num-mapp-edge` / `ds-deploy-pg-hive-job` → `backup/retired-20261015-T2/`
>   · 另有 1 个**不计入上表**的现役脚本：`run-dwd-etl-direct.py`（独立章节）。
> - **2026-10-16**：再退役 11 个一次性运维脚本（T3，下表从未列入）→ `backup/retired-20261016-T3/`：
>   `_run_chain_pty`（链式跑 ODS 05→06→PTY 探针）/ `_poll_chain`（实例终态轮询）/ `_run_remaining`（接手卡死 runner）/
>   `_run_manual_batch`（10-16 手工批总控）/ `_add_pbatchdt`（补 P_BATCH_DT 全局参数）/ `_sync_master_real`（主数据 23 张换真脚本）/
>   `_verify_depnode_acct`（ACCT dep 节点专项核）/ `_verify_ods_placeholder`（ODS 占位核）/ `_verify_onedep.py`（结构体检，
>   能力并入 `ds-dwd-pipeline.py diff`）/ `_verify_onedep.sql`（根目录残留，原件已在 T1）/ `_trigger_wf`（触发直连版，被 `ds-run` 覆盖）
> - **2026-10-19**：再归档 8 个一次性脚本（T5）→ `backup/retired-20261019-T5/`：
>   `_patch_pbatchdt_param`（P_BATCH_DT 补丁，已复核 globalParams 生效）/ `_patch_org_num_mapp_dialect`（date 方言补丁，DS 已与仓库版字节一致后无需）/
>   `_patch_noop_tasks` / `_noop_tasks_generic` / `_noop_restore_generic`（E2E NOOP 三件套，DS 侧 NOOP 残留复核 = 0）/
>   `_fix_pty_cycle` / `_online_all_wf` / `_verify_dwd_deploy`。
>   另：`backup/` 目录**未纳入 git**（删除不可从 git 恢复）；如需清理先确认 `D:\datax\backup` 有对应批次副本。

- **部署 / 落库**：`ds-deploy-api.py`（★统一接口）· `ds-deploy-all-dwd.py` · `ds-deploy-ods-all.py` · `ds-deploy-dwd-workflow.py` · `ds-add-dwd-table.py` · `ds-rebuild-from-inventory.py`
- **一键管线（血缘→依赖差异→依赖配置→部署/排版）**：`ds-dwd-pipeline.py`（★ 2026-10-16 起四段 `lineage/diff/config/deploy`；无 `--apply` 绝不写任何东西）
- **脚本同步 / 批量改**：`ds-sync-dwd-scripts.py` · **`ds-sync-ods-scripts.py`**〔并 `ds-batch-update-ods-scripts` + `ds-sync-ods-scripts-batch`〕
- **依赖构建**：`ds-build-dependent-from-lineage.py`（★现役口径）· `ds-build-dws-dependent-from-lineage.py`
- **运行 / 跑批**：**`ds-run.py`**〔并 `manual` / `task` / `ods-serial` / `dwd-serial` / `rerun-failed` 5 个〕· `ds-run-hive-sql.py` · `run-dwd-etl-direct.py`（真实执行 DWD ETL，见上章）
- **调度**：**`ds-schedule.py`**〔并 `create` / `ensure` / `switch` / `release` 4 个〕
- **体检 / 守卫**：`ds-check-running.py`（★ 动 DS 前必跑）· `ds-check-tables-exist.py` · `ds-verify-dwd-layout.py` · `validate-dwd-syntax.py`
- **排版**：**`ds-relayout.py dwd|ods`**〔并 `ds-relayout-dwd` + `ds-relayout-ods`；★ 默认间距 DWD 500 / ODS 416，两层刻意分层〕
  —— 2026-10-15 起各导入脚本已内置同参数（见「导入即排版」），本工具**退化为兜底/救援**：
  只在「规范改过」或「图被人手拖乱」时对已存在的工作流补跑
- **维护 / ⚠️ 危险**：`ds-wipe-workflows.py`（⚠️ 先 pg_dump）
- **基础设施**：`ds_client.py`（DS API 客户端，被 12 个脚本 import；另提供 `legacy_client()`
  旧式 `call/login` 兼容层，见上「HTTP 层统一」）