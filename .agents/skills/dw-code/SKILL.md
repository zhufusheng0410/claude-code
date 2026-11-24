---
name: dw-code
description: >
  修改 tools/ 下的 Python 时守住已定护栏。用户提到改 tools/、改 CLI、dry-run、--apply、MASTER 护栏、safe_sysname、路径拼接、facade、补丁桥、dw-pipeline.py、cleanup_tmp.py、ds_common.py、ds-inspect.py、ds-sync-scripts.py、不要把口径抄进 CLAUDE.md、不要把条数写进文档时使用。
  改 tools/main.py、tools/parser/、tools/generator/ 时也要使用。不要用于跑生成、甲方搬移、血缘或 DolphinScheduler 部署；那些只是在改代码时才顺便守规则。
---

# 改 tools/ 时的护栏

这些护栏一旦改掉，下一次生成或部署就会覆盖主数据，或在没确认时写盘。改代码之前先核对它们还在，而不是等跑起来再发现。

## 禁令

- 不削弱 `tools/main.py` 对 `DWD` / `ALL` + `MASTER` 的拒绝。判断仍是 `layer in ("DWD", "ALL")` 且 `sys-name` 去空白、转大写后等于 `MASTER`。
- 不把写操作从「默认 dry-run，`--apply` 才落盘」改成默认写盘。实现是 `--apply` 的 `action="store_true"`，没有名为 `dry_run` 的开关。`tools/dw-pipeline.py` 与 `tools/dwd-pipeline.py` 都保持这个默认。
- 项目口径在 `AGENTS.md` 维护。`CLAUDE.md` 只保留指向它的短入口。
- 不把当次条数、实例号、耗时写进 `AGENTS.md` 或 `docs/`。只记决策和规则。
- 源码、skill、提交说明里不写口令字面量。凭据只走 `tools/ds-deploy/ds_config.py` 已有的解析链。

`safe_sysname` 和 facade 补丁写穿不是另写一套禁令。改到路径拼接或 facade 时，先打开下面两个文件，按那里的现有做法改。

## 先读

| 何时 | 读 |
|---|---|
| 改任何 `tools/` Python 前 | `AGENTS.md` 的文档记录约定 |
| 改路径拼接、系统简称、输出目录 | `tools/core/safe_paths.py` |
| 改 `tools/dw-pipeline.py`，或要让测试打到 facade 上的名字 | `tools/dw-pipeline.py` 的补丁桥 |

只在改到那一块时才打开。不要为了「熟悉项目」把生成、搬移、部署的实现读一遍。

## 动作

本 skill 不给管线运行命令。不要从这里启动 `tools/main.py` 或 `tools/dw-pipeline.py` 的子命令。

改完后跑：

```
/usr/bin/python3 -m compileall -q tools .agents/skills
/usr/bin/python3 -m unittest discover -s tools/tests -p "test_*.py"
```

若改到 `.sh` 脚本或 `demo/templates/` 下的 Shell 模板，加跑 `/usr/bin/python3 tools/ci_shell_gate.py`。不要把单测改成 pytest。仓库测试就是 unittest。失败就看失败用例，不要为了变绿去削弱 MASTER 护栏或 dry-run 默认。

改 `tools/main.py`、`tools/parser/`、`tools/generator/` 时，生成 skill 里还有 MASTER 拒绝和 dry-run 两条。本 skill 没被一起加载时，仍然守住上面的禁令。

## 停

- 改动会让 MASTER 生成重新变得可执行：停，不提交。
- 改动会让未加 `--apply` 的命令落盘或动 DS：停，不提交。
- 正文、源码或提交说明里出现口令字面量：停，不写入。
- 用户要求把命名表、T-1 正则或工作流归属抄进 `CLAUDE.md` 或本 skill：拒绝。口径只改 `AGENTS.md` 和对应模块。

## 不负责

不跑生成、搬移、血缘、部署。用户要的是执行管线而不是改 `tools/` 时，不要用本 skill 接过那次运行。
