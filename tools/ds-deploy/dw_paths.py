# -*- coding: utf-8 -*-
"""ds-deploy 工具的路径**单一来源**（仓库根 / 脚本根 / 备份根 / 报告根）。

历史：各脚本各自硬编码 `C:\\Users\\84148\\...` 与 `/mnt/d/datax/...`；
换机器、换盘符或换运行环境（Windows / WSL）就会失效。
默认值一律从 `__file__` 推导、落在仓库内；需要指向别处时用环境变量覆盖。

| 环境变量 | 默认 | 含义 |
|---|---|---|
| `DW_REPO` | 仓库根（由本文件位置推导） | 生成器仓库根 |
| `DW_BACKUP_ROOT` | `tools/.dx-tmp/backup` | 同步/重建前的备份根 |
| `DW_REPORT_DIR` | `tools/.dx-tmp` | 运行报告目录 |
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.environ.get("DW_REPO", os.path.dirname(os.path.dirname(HERE)))
SCRIPTS = os.path.join(REPO, "scripts")
BACKUP_ROOT = os.environ.get(
    "DW_BACKUP_ROOT", os.path.join(REPO, "tools", ".dx-tmp", "backup"))
REPORT_DIR = os.environ.get(
    "DW_REPORT_DIR", os.path.join(REPO, "tools", ".dx-tmp"))
