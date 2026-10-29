# DWD_PTY NUM_MAPP 脚本修复交接说明
> 生成时间：2026-10-26 19:26（GMT+8）
> 交接自：当前 WorkBuddy 会话（已实查集群 + DS 元数据库 + worker 日志）

## ⚠ 2026-10-26 21:xx 定稿纠正（以本段为准，下方 §3~§6 的「RN 写回」判断作废）
- **真根因：13 张 `*_INT` 中间表结构比甲方少一列**（非 RN 写回）：
  CUST 3 张少 `C_IDENTITYNO`；ORG 7 张少 `<前缀>_MODIFY_TIME`；CNTP 3 张少首列 `ID`。
- 甲方 `01-建表语句/01-DWD建表脚本.sql` 里 13 张全有；已按其 DROP+CREATE 重建并 `DESCRIBE` 复核 14/11/11 全对。
- ORG 脚本已恢复到带前缀版本（36737→36815），重跑实例 1460 → **20 task 全 SUCCESS，无 10044/10004**。
- 遗留：所有 DWD 表 p_dt=20261025 均 0 行，溯源为**整个 ODS 层无数据**（所有分区合计 0 行），与本次重建无关。

## 1. 问题概述
DolphinScheduler 工作流 **DWD_PTY**（2026-10-26 批次，工作流实例 id=1456，19:11 启动）有 4 个 task 失败。
DWD_PTY 是 P0 工作流，其失败会向下游 PROD / ACCT / AGMT / AST / EVT / TRAN 传播。
**这不是集群故障，是 SQL 脚本缺陷。**

## 2. 失败 task 清单（实例 1456）
| task | 类型 | 状态 | 性质 |
|---|---|---|---|
| DWD_PTY_CUST_NUM_MAPP_PFD | SQL(beeline-krb) | FAILED | **真因** |
| DWD_PTY_ORG_NUM_MAPP_PFD  | SQL(beeline-krb) | FAILED | **真因** |
| dep_DWD_PTY_CUST_INFO_PFD | DEPENDENT | FAILED | 级联（依赖上面两个） |
| dep_DWD_PTY_ORG_BASIC_INFO_PFD | DEPENDENT | FAILED | 级联（依赖上面两个） |
其余 4 个 dep_* task 当时仍在 RUNNING。所有失败 task retry_times=0 / max_retry_times=0，不重试。

## 3. 根因（定稿）
两个 NUM_MAPP 的 `INSERT … SELECT` 比目标表**多一列**：多出的 `ROW_NUMBER()…AS RN` 去重列被直接写回了。
Hive 报错（来自 worker 日志）：
- CUST：`SemanticException [Error 10044]: Table insclause-0 has 13 columns, but query has 14 columns.`
- ORG ：`SemanticException [Error 10044]: Table insclause-0 has 10 columns, but query has 11 columns.`

## 4. 脚本精确定位
- `scripts/MASTER/dwd/02_etl/DWD_PTY_CUST_NUM_MAPP_PFD.sh`
- `scripts/MASTER/dwd/02_etl/DWD_PTY_ORG_NUM_MAPP_PFD.sh`
两文件**最终** `INSERT INTO TABLE DWDXDAY.DWD_PTY_*_NUM_MAPP_PFD PARTITION(P_DT='…')` 段的写回 SELECT 中多带 `RN` 列。
（错误 SQL 在最终 INSERT 段；CUST 脚本约 491–520 行区间、ORG 类似，接手方 Read 后定位即可。）

worker 容器日志路径（如需复核）：
- `/opt/dolphinscheduler/logs/20261026/187978225498016/2/1456/18121.log`（CUST）
- `/opt/dolphinscheduler/logs/20261026/187978225498016/2/1456/18123.log`（ORG）

## 5. 正确写法对照
同目录 `DWD_PTY_CUST_INFO_PFD.sh` 用的是正确范式：子查询内算 `RN`，外层 `WHERE RN = 1` 去重，**外层写回 SELECT 不列出 RN**，写入列数 == 目标表列数。
接手方可直接参照该文件结构修。

## 6. 修复方案（最小改动）
将两 NUM_MAPP 脚本最终 INSERT 的写回 SELECT 中 `, ROW_NUMBER()…AS RN` 这一列去掉；
若仍需去重，把 RN 留在内层子查询并加 `WHERE RN = 1`（不要让它出现在写回列里）。

## 7. 后续处置步骤
1. 改完两个 .sh 后，同步到 DS：`python tools/ds-deploy/ds-sync-dwd-scripts.py --layer DWD`（或等价同步命令）。
2. 重跑 DWD_PTY（或在 DS 上单独补跑失败 task + 依赖它们的下游 task）。
3. **批次日对齐**：p_end_dt 必须与 ODS 现有分区对齐（本次为 20261025），否则下游跑空表。
4. **依赖注意**：DWD_PTY 是 P0，下游跨流依赖多。WORKFLOW_OVERRIDE 中 DWD_PTY_OPER_FUND_PRVL_PFD、DWD_CMM_INTR_PARA_PFD 已归 DWD_PROD（其唯一 DWD 上游为 DWD_PROD_SFAC_NUM_MAPP_PFD），但本次失败的 CUST/ORG NUM_MAPP 仍属 DWD_PTY，需确认其下游消费方不被缺失数据波及。

## 8. 交接时集群状态（供参考，非本次问题）
- DS api/master/worker/alert：Up 9h, healthy
- Hadoop(HDFS/YARN/ZK)/Hive(HS2/metastore)/KDC/Ranger：healthy
- PostgreSQL(db `dolphinscheduler`)：UP；DS API `/actuator/health` = UP
- iceberg-minio / iceberg-rest：Exited 约 11 天（停更镜像替换前置，符合计划，忽略）
- 工作流实例：34 SUCCESS + 1 RUNNING(DWD_PTY)；workflow 层面失败/被杀 = 0
- 今日跑批：ODS 抽数（o32/wind/jy/offw/oa…）全部 SUCCESS（17:10–19:01）；DWD_CMM SUCCESS（19:02–19:10）
