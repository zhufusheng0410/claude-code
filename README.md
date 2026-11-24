# 数仓代码自动生成

从 Excel 调研文档生成 ODS / DWD / DWS 的建表 DDL、ETL、血缘和数据字典。

口径以 [AGENTS.md](AGENTS.md) 为准。`CLAUDE.md` 只是指向该文件的短入口，不要再维护第二份全文。

## 常用入口

在 WSL 的仓库根目录运行。先分清是要校验、预览，还是直接生成文件：

| 用途 | 命令 | 是否写入交付物 |
|------|------|----------------|
| 对账：本地 DDL 与甲方建表脚本 | `/usr/bin/python3 tools/dw-pipeline.py verify-ddl --layers DWD,DWS` | 否，只读校验 |
| 预览：DWD 脚本搬移、DWS 脚本比对 | `/usr/bin/python3 tools/dw-pipeline.py scripts --layers DWD,DWS` | 否；可更新运行缓存。DWS 的 jf 比对即使加 `--apply` 也不覆盖脚本 |
| 生成：只处理 O32 的 ODS | `/usr/bin/python3 tools/main.py --layer ODS --sys O32` | **是**，直接写生成文件；不是 dry-run，不需要 `--apply` |

部署、MASTER 保护和工作流重启顺序见 [AGENTS.md](AGENTS.md)；完整文档分级索引见 [docs/README.md](docs/README.md)（工作区 AI 技能在 `.agents/skills/`）。

## 测试与本地门禁

```bash
/usr/bin/python3 -m compileall -q tools .agents/skills
/usr/bin/python3 tools/ci_shell_gate.py
/usr/bin/python3 -m unittest discover -s tools/tests -p "test_*.py"
/usr/bin/python3 tools/dw-pipeline.py verify --layers DWD,DWS --strict
```
