# DWD DS 依赖校验（对照 scripts/DWD_依赖关系.xlsx）

DS：项目 dw；配置源 `dep-config-proscript`；**109 张表 / 10 个工作流**。

本文件是**某一时刻的快照**（不下发口径）；判定规则见 `docs/功能与规范文档.md` §15.3。

| 工作流 | 成员表 | SHELL作业 | dep节点 | 依赖项 | 其中跨流 | 上线状态 |
|---|---|---|---|---|---|---|
| DWD_ACCT | 7 | 7 | 7 | 17 | 17 | ONLINE |
| DWD_AGMT | 2 | 2 | 2 | 7 | 7 | ONLINE |
| DWD_AST | 12 | 12 | 12 | 59 | 59 | ONLINE |
| DWD_CHNL | 3 | 3 | 3 | 11 | 10 | ONLINE |
| DWD_CMM | 4 | 4 | 4 | 6 | 6 | ONLINE |
| DWD_EVT | 17 | 17 | 17 | 84 | 84 | ONLINE |
| DWD_PROD | 20 | 20 | 20 | 79 | 60 | ONLINE |
| DWD_PTY | 10 | 10 | 10 | 37 | 30 | ONLINE |
| DWD_SCR | 10 | 10 | 10 | 35 | 26 | ONLINE |
| DWD_TRAN | 24 | 24 | 24 | 88 | 88 | ONLINE |
| **合计** | **109** | **109** | **109** | **423** | **387** | — |

## 差异结论

- **破环丢弃 0 条**：搬表后工作流级 DAG 无环（拓扑 CMM/PTY/SCR(1) → CHNL(2) → PROD(3) → ACCT/AGMT/AST/EVT/TRAN(4)），`DWD_CHNL→DWD_PROD` 等 8 条真实边全部保留。
- **T-1 免配 4 条**（源表 → 目标表）：`DWD_PROD_PROD_NUM_MAPP_PFD → DWD_PROD_PROD_BASIC_INFO_PFD`、
  `DWD_PROD_SFAC_NUM_MAPP_PFD → DWD_PROD_SFAC_PROD_BASIC_INFO_PFD`、
  `DWD_SCR_SCR_NUM_MAPP_PFD → DWD_CMM_STD_DICT_CDVAL_MAP`、`DWD_SCR_SCR_NUM_MAPP_PFD → DWD_SCR_SCR_BASIC_INFO_PFD`。
- **配置表免配 94 条**：均指向 `DWD_CMM_STD_DICT_CDVAL_MAP`（`SCHEDULE_EXCLUDE`）。
- **血缘 / 配置口径性缺口**：血缘有/配置无 **177** 条，配置有/血缘无 **46** 条。
- **DS 节点差异**：缺 **0** 项 / 多 **0** 项（脏工作流 0 个），三方（血缘 / dep.json / DS）一致。

> 「传递归约 / 跨流批次漂移 / 无作业跳过」明细由 `tools/ds-deploy/ds-dwd-pipeline.py diff` 现算，输出 `D:\datax\docs\DWD全链核对-<时间戳>.xlsx`；本文件只固化 DS 现状与口径。

_生成时间：2026-10-24；生成方式：DS API 回读 + `dep-config-proscript` 对齐。_
