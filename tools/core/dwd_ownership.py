# -*- coding: utf-8 -*-
"""DWD 表 → 工作流归属的**唯一口径**（只依赖 re，供两处共用）。

历史：`tools/dwd-pipeline.py` 与 `tools/ds-deploy/ds-build-dependent-from-lineage.py`
各自复制了一份 `WORKFLOW_OVERRIDE` + `own_workflow()`，靠文档提醒「两处必须同步」。
2026-10-29 起改为本模块单一来源，两处只做薄委托，口径变更只改这一个文件。

默认规则：`DWD_<主题>_…` → `DWD_<主题>`（表名前缀唯一决定归属）。
例外只写在 `WORKFLOW_OVERRIDE`，判定口诀：唯一 DWD 上游映射表在哪个主题 ⇒ 归该主题工作流。
"""
import re

WORKFLOW_OVERRIDE = {
    # 2026-10-23（用户决定）：搬到 DWD_PROD。
    # 它唯一的上游映射表 DWD_PROD_SFAC_NUM_MAPP_PFD 在 DWD_PROD；留在 DWD_PTY 会形成
    # 工作流级环（PROD 等 PTY，PTY 的 dep 节点又等 PROD）⇒ PTY 跑 40+ 分钟卡在
    # dep_DWD_PTY_OPER_FUND_PRVL_PFD。
    'DWD_PTY_OPER_FUND_PRVL_PFD': 'DWD_PROD',
    # 2026-10-23（用户决定）：搬到 DWD_PROD —— 上游映射表 DWD_PROD_SFAC_NUM_MAPP_PFD 在 PROD，
    # 留在 DWD_CMM 就是 DWD_CMM → DWD_PROD 的跨流作业级等待。
    'DWD_CMM_INTR_PARA_PFD': 'DWD_PROD',
}


def own_workflow(table):
    """表名 → 工作流名（`DWD_<主题>_…` → `DWD_<主题>`，例外见 WORKFLOW_OVERRIDE）。"""
    t = str(table).upper()
    if t in WORKFLOW_OVERRIDE:
        return WORKFLOW_OVERRIDE[t]
    m = re.match(r'^(DWD)_([A-Z0-9]+)_', t)
    return 'DWD_' + m.group(2) if m else '(未知)'
