---
name: dw-sync
description: >
  搬移或核对甲方脚本与建表语句：DWS 对账、清单 sha256、方言清洗、DDL 自检、DDL 差异登记豁免、拼接副本修复、和桌面 scripts 比对。用户提到甲方搬移、对一下、不要覆盖、_DWS搬移清单、sha256、verify-ddl、dwd_ddl_drift_allowlist、repair、方言、Inceptor、Hive 4.2 清洗时使用，即使用户没说「搬移」。
  不要用于从调研表或 MAPPING 生成，不要用于血缘工作簿、依赖配置、DolphinScheduler 部署，也不要用于只改 tools/ 里的 Python。
---

# 甲方搬移与核对

仓库里的 DWS 脚本是甲方原文加上 Hive 4.2 方言修复，不是逐字节副本。用甲方原文覆盖会把修过的脚本还原成跑不了的版本。比对只报告，不落盘。

## 禁令

- 不把生成器产物或甲方原文写入 `scripts/MASTER`。`repair` 可以改 MASTER 里已确认的拼接副本，但仍默认 dry-run。副本 SQL 不一致时不落盘。
- 不用甲方原文覆盖 `scripts/{系统}/dws/02_etl`。比对只报告差异。带 `DW-DEVIATION` 的已修复脚本不还原成甲方原文。
- `scripts` 与 `ddl` 只走默认的 `--source jf`。不传 `--source gen`。生成交给生成 skill，不在这里代跑。
- `_DWS搬移清单.json` 的 sha256 / bytes 与现盘不一致时默认失败。不刷新清单，不覆盖脚本。`--allow-stale-dws-manifest` 只有用户当次明确说了才加，加上也不改清单、不覆盖脚本。

## 先读

只打开当次要用的文件。

| 何时 | 读 |
|---|---|
| 搬移、对账、DDL 落盘前 | `AGENTS.md` 的 DWS 基线节 |
| 要看比对或修复怎么停 | `tools/dws/scripts.py` |
| 清单过期或用户要求改清单 | `tools/dws/manifest.py` |
| 落盘 DDL 或做 verify-ddl | `tools/dws/ddl.py` |
| verify-ddl 报列差异或讨论豁免登记 | `AGENTS.md` 的「DWD DDL 差异登记」节与 `tools/dwd_ddl_drift_allowlist.json` |

仓库与甲方 DWS 脚本有差异是预期：差异来自方言修复，不是漂移。不要据此判定仓库被改坏。

## 动作

解释器只用 `/usr/bin/python3`。

| 要做的事 | 命令 |
|---|---|
| 同步或比对脚本 | `/usr/bin/python3 tools/dw-pipeline.py scripts --layers DWD,DWS` |
| 重建建表语句 | `/usr/bin/python3 tools/dw-pipeline.py ddl --layers DWD,DWS` |
| 只校验 DDL，不落盘 | `/usr/bin/python3 tools/dw-pipeline.py verify-ddl --layers DWD,DWS` |
| 拼接副本修复 | `/usr/bin/python3 tools/dw-pipeline.py repair --layers DWD,DWS` |

只处理用户点名的层级时，把 `--layers` 收窄。不要传 `--source gen`。不要跑 `all`。

写操作默认不加 `--apply`。`--no-strict` 只有用户当次明确要求忽略 DDL 差异时才加。

## 停

- 甲方交付目录不存在：停。可以告诉用户用 `DW_DELIVERY` 指定。不许当成成功跳过。
- 清单 sha256 / bytes 与现盘不一致：停。不改清单，不覆盖脚本。用户要求「对不上也继续，并把清单改到和现盘一致」时，两件事都拒绝。
- DDL 自检有未登记差异：停。不擅自改 `tools/dwd_ddl_drift_allowlist.json` 登记豁免，也不加 `--no-strict`，除非用户当次明确要求忽略。
- 要用甲方原文覆盖已修复的 DWS 脚本：拒绝。
- 用户要跑 `all`，或要求 `--source gen`：拒绝代跑。生成交给生成 skill；整条链按子命令拆开，第一步失败就停。

## 不负责

`tools/main.py` 生成、血缘工作簿、依赖配置、DolphinScheduler 部署。`verify` 不是 `verify-ddl`，不要在这里跑。
