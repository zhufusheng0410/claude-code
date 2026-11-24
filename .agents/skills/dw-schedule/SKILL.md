---
name: dw-schedule
description: >
  梳理血缘、生成依赖配置、部署或删除 DolphinScheduler 工作流、排版、校验脚本与依赖。用户提到血缘、依赖、depcfg、dep-config、DolphinScheduler、DS 部署、上线、排版、工作流、T-1、不配依赖、DWS_HSFA、p_start_dt、p_end_dt 时使用，即使用户没说「部署」。
  不要用于从调研表生成，不要用于甲方脚本搬移、清单 sha256、verify-ddl，也不要用于只改 tools/ 里的 Python。
---

# 血缘与调度

写操作默认只预览。没看到用户当次明确要求落盘或动 DS，就不要加 `--apply`。DolphinScheduler 上的作业会按脚本真跑，dry-run 是为了避免没确认就改线上。

## 禁令

- 没有用户当次明确要求落盘或动 DS 时，不加 `--apply`。
- T-1 只认 `AGENTS.md` 写明的字面形态。`${P_BATCH_DT}` 变体只报不删，不扩大成「含 `DATE_SUB` 就算」。
- 触发 `DWS_HSFA` 时传 `p_start_dt=<批次日>`、`p_end_dt=<批次日+1>`。`DWS_O32` 与 `DWS_ZTA` 仍是 `p_start_dt = p_end_dt = <批次日>`。这 7 个 HSFA 脚本的 `while` 仍是 `-lt`。不按 `tools/dws-dep-report.py` 里「已改为 `-le`」的注释去改脚本。
- `--source gen` 的 DWS 不部署。`AGENTS.md` 写明有表的 MAPPING 未修完。用户当次明确要求部署 gen 版 DWS 时也先停，指出该节，不静默继续。
- 源码、skill、提交说明里不写口令字面量。凭据只走 `tools/ds-deploy/ds_config.py` 已有的解析链。

## 先读

| 何时 | 读 |
|---|---|
| 配依赖、决定不配 T-1、排重启顺序 | `AGENTS.md` 的调度依赖、重启顺序、DWS 基线节 |
| 选子命令和开关 | `tools/dws/cli.py` 的 `SUBCOMMANDS` |
| 部署、删除、同步脚本到 DS | `tools/ds-deploy/` 下这次要跑的那个脚本，不预读整个目录 |

免配边的当次条数不要写进文档。以运行时打印和 `tools/_prev_day_deps.json` 为准。

## 动作

解释器只用 `/usr/bin/python3`。

| 要做的事 | 命令 |
|---|---|
| 重建血缘 / 依赖工作簿 | `/usr/bin/python3 tools/dw-pipeline.py lineage --layers DWD,DWS` |
| 主数据血缘 | `/usr/bin/python3 tools/dwd-pipeline.py lineage` |
| 生成 DS 依赖配置 | `/usr/bin/python3 tools/dw-pipeline.py config --layers DWD,DWS` |
| 部署 | `/usr/bin/python3 tools/dw-pipeline.py deploy --layers DWD,DWS` |
| 只删除工作流 | `/usr/bin/python3 tools/dw-pipeline.py delete --layers DWD,DWS` |
| 只排版 | `/usr/bin/python3 tools/dw-pipeline.py layout --layers DWD,DWS` |
| 校验脚本与依赖 | `/usr/bin/python3 tools/dw-pipeline.py verify --layers DWD,DWS` |

DWS 部署入口以 `AGENTS.md` 为准，收窄为 `--layers DWS`。脚本同步到 DS 用已有的 `tools/ds-deploy/ds-sync-dwd-scripts.py`，`--layer DWS` 时指向它，不在这里重写同步步骤。

不要跑 `all`。它会串起搬移、DDL、血缘和可选部署。用户要整条链时按归属拆开，第一步失败就停。

`--ds` 只有用户要求连 DolphinScheduler 回读时才加。`--apply`、`--allow-gen-errors` 只有用户当次明确说了才加。

## 停

- 甲方交付目录不存在：停。可以告诉用户用 `DW_DELIVERY` 指定。不许当成成功跳过。
- 用户没说落盘，却要求直接写依赖配置或改 DS：拒绝，先给不加 `--apply` 的命令。
- 要部署 gen 版 DWS：停，指出 `AGENTS.md` 里 MAPPING 未修完的那节。
- 要跑 `all`：拒绝代跑。
- 正文、源码或提交说明里出现口令字面量：停，不写入。

## 不负责

从调研表生成、甲方脚本搬移、清单 sha256、`verify-ddl`。DDL 自检属于搬移核对，不要在这里加 `--no-strict`。
