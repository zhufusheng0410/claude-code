# 数仓代码自动生成

从 Excel 调研文档生成 ODS / DWD / DWS 的建表 DDL、ETL、血缘和数据字典。

口径以 [AGENTS.md](AGENTS.md) 为准。`CLAUDE.md` 只是指向该文件的短入口，不要再维护第二份全文。

## 测试

统一在 **WSL Ubuntu** 里用 `python3` 运行（Windows 原生无 Python，详见 `AGENTS.md`）：

```text
python3 -m unittest discover -s tools/tests -p "test_*.py"
python3 -m compileall -q tools
```

生成与部署的运行环境、凭据和 Hive / DolphinScheduler 约定见 `AGENTS.md`。口令只放环境变量或本机忽略文件，不要写进仓库。

## 常用入口

| 用途 | 命令 |
|------|------|
| 生成 | `python3 tools/main.py --layer ALL` |
| DWD 搬移与血缘 | `python3 tools/dwd-pipeline.py all`（默认 dry-run，`--apply` 才落盘） |
| DWD+DWS 管线 | `python3 tools/dw-pipeline.py all --source jf --layers DWD,DWS` |

子命令、禁止事项和重启顺序都在 `AGENTS.md`，不要以本页代替。
