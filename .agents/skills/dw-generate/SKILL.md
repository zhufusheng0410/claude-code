---
name: dw-generate
description: >
  从调研表或 MAPPING 生成 ODS、DWD、DWS，或修改生成器。用户提到生成、调研表、表级调研、字段调研、MAPPING、ODS 脚本、DWD 生成、DWS 生成、tools/main.py、tools/parser/、tools/generator/、--layer、--sys-name、--source gen 时使用，即使用户没说「生成」。
  不要用于甲方脚本搬移、清单 sha256、方言对账、verify-ddl、血缘工作簿、DolphinScheduler 部署，也不要用于只改 tools/dws/ 或 tools/ds-deploy/。
---

# 生成 ODS / DWD / DWS

生成器会把产物写进 `scripts/`。主数据目录里是甲方脚本和手工血缘，生成器覆盖一次就没了。先对禁令，再读文件，再跑命令。

## 禁令

- 禁止运行 `python tools/main.py --layer DWD --sys-name MASTER`。`--layer ALL` 且 `--sys-name MASTER` 同样禁止。大小写和首尾空白由 `tools/main.py` 护栏处理，不要自己再写一套判断。
- 生成器不产主数据。`tools/main.py` 拒绝时打印的 `dw-pipeline.py scripts --layers DWD` 不会刷新 `scripts/MASTER`。`tools/dwd/parsing.py` 的 `build_owner` 把已在 `scripts/MASTER/dwd/02_etl` 的表排除出 assign，`convert` 只做校准。用户要求刷新主数据脚本时停下来，先读 `AGENTS.md` 的 MASTER 节和 `build_owner`，不另写复制命令。
- 主数据血缘只指向 `/usr/bin/python3 tools/dwd-pipeline.py lineage`。默认不加 `--apply`。血缘的其余规则在 `dw-schedule`，这里不展开。
- 改 `tools/main.py`、`tools/parser/`、`tools/generator/` 时：不削弱上面的 MASTER 拒绝；不把写操作从「默认 dry-run，`--apply` 才落盘」改成默认写盘。只加载到本 skill 时也要守住这两条。

## 先读

只打开当次要用的文件，不预读全部。

| 何时 | 读 |
|---|---|
| 生成前 | `AGENTS.md` 的命名规范与 MASTER 节；`tools/main.py` 里的 MASTER 护栏 |
| 要确认 schema、后缀、系统别名 | `tools/config.py` |
| 用户要求刷新主数据脚本 | `tools/dwd/parsing.py` 的 `build_owner` |

不把命名表抄进回复或新文档。口径以 `AGENTS.md` 为准。

## 动作

解释器只用 `/usr/bin/python3`。不要用裸 `python` 或 `python3`。

从调研表或 MAPPING 生成：

```
/usr/bin/python3 tools/main.py --layer ODS|DWD|DWS|ALL
```

需要限定系统时用 `--sys`，例如 O32。`--sys-name` 只在配合 `--dwd-mapping-dir` 覆盖输出目录名时使用，不要拿它来选系统，也不要组成上面禁止的 MASTER 组合。

`/usr/bin/python3 tools/dw-pipeline.py scripts --source gen` 和同入口的 `ddl --source gen` 也是生成。它只同步 HSFA、HSZTA、O32，不写 MASTER。用户没明确说走这条入口时，仍用 `tools/main.py`。

注意区分两条入口的写盘行为：
- `tools/main.py` **没有 `--apply` 开关、没有 dry-run，运行即直接写盘覆盖输出目录**；若用户只想预览生成结果，必须加 `--output <临时目录>`，或改走下面的 `dw-pipeline.py --source gen` 预览。
- `tools/dw-pipeline.py` 的 `scripts/ddl --source gen` 默认 dry-run，只有用户当次明确要求落盘才加 `--apply`；`--allow-gen-errors` 只有用户当次明确说了才加。

## 停

- 请求生成 MASTER 的 DWD：拒绝，并说明 `scripts --layers DWD` 不会刷新 `scripts/MASTER`。不另写复制命令，不先跑再补救。
- 甲方交付目录不存在、清单过期、DDL 差异、部署、用甲方原文覆盖 DWS：这不是本 skill 的事。不要代跑 `all`，不要在这里加 `--source jf`。
- 不把当次条数、实例号、耗时写进 `AGENTS.md` 或 `docs/`。不把口径抄回 `CLAUDE.md`（口径只在 `AGENTS.md` 维护）。

## 不负责

甲方搬移、清单、方言对账、`verify-ddl`、血缘工作簿、DolphinScheduler。那些分别属于搬移核对和血缘调度，不要在本 skill 里接过来做。
