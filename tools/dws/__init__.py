# -*- coding: utf-8 -*-
"""DWD + DWS 一体化管线（`tools/dw-pipeline.py` 的实现）。

子模块：
    state     仓库路径、口径常量、共享状态
    process   子进程与文件同步原语
    manifest  `_DWS搬移清单.json` 守卫与 source map
    scripts   脚本搬移 / 同步 / 拼接副本修复
    ddl       DDL 解析、清洗、落盘与比对
    lineage   血缘与依赖配置
    deploy    DS 工作流操作
    verify    脚本 / DDL / DS 校验
    cli       参数解析与子命令分派

对外入口仍是 `tools/dw-pipeline.py`（薄 facade，保留全部历史导出名）。
"""
