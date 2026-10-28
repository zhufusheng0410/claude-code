# DWD → ODS 依赖体检报告

> 生成时间：2026-10-04
> 口径：`scripts/<SYS>/dwd/02_etl/*.sh` 中**实际出现**的 `ODS_*` 表名，与 `scripts/<SYS>/ods/etl_sh/*.sh` 的**文件名（= 目标表名）**比对。
> 权威依赖来源：`D:\项目\...\05-脚本\脚本调度依赖关系梳理.xlsx`（626 行，列为 分层 / 表英文名称 / 表中文名称 / 源系统 / 源表英文名称 / 源表中文名称 / 所属工作流）。

---

## 一、总览

| 指标 | 数量 |
|---|---|
| DWD ETL 脚本 | 87（HSFA 20 + HSZTA 27 + O32 40） |
| 被引用的 ODS 表（去重） | **126** |
| ✅ 在 `ods/etl_sh` 中有对应抽取脚本 | **102** |
| ⚠️ 待处理 | **24** |

24 个待处理项**不是同一类问题**，必须分开处理：

| 类别 | 数量 | 处理方式 |
|---|---|---|
| A1 后缀写错（`_PTD` 应为 `_PFD`） | 12 | 改**引用侧**表名即可，ODS 脚本已存在 |
| A2 ODS 侧无后缀（OA / OFFW） | 6 | 改**引用侧**表名（去掉 `_PFD`）即可 |
| A3 拼写差异 | 2 | 改**引用侧**表名（`TCUSTINFO` → `TCUSTOMERINFO`） |
| B 真缺抽取脚本 | 4 → **2** | 2 张 HSFTA 表已补（见下）；余下 2 张需业务定 |

> **关键判断**：A 类全部是**上游交付口径与 ODS 实际生成口径不一致**，不是生成器缺陷。
> 佐证：`脚本调度依赖关系梳理.xlsx` 里同样写 `ODS_HSFA_TQSK_PTD`、`ODS_HSFTA_TSUBTACUSTTAILRATIO_PFD`，
> 说明甲方依赖表与 ODS 调研文档本身就不同源。

---

## 二、A 类：引用名与 ODS 实际表名不符（20 个）

### A1 后缀应为 `_PFD`（12）

| DWD 中引用的名字 | ODS 层实际脚本 |
|---|---|
| `ODS_HSFA_TQSK_PTD` | `ODS_HSFA_TQSK_PFD.sh` |
| `ODS_HSFA_TXG_PTD` | `ODS_HSFA_TXG_PFD.sh` |
| `ODS_HSFA_TCAP_CKYW_PTD` | `ODS_HSFA_TCAP_CKYW_PFD.sh` |
| `ODS_HSFA_TFJYGH_PTD` | `ODS_HSFA_TFJYGH_PFD.sh` |
| `ODS_HSFA_THGJY_PTD` | `ODS_HSFA_THGJY_PFD.sh` |
| `ODS_HSFA_TXM_LS_PTD` | `ODS_HSFA_TXM_LS_PFD.sh` |
| `ODS_O32_TAPPLYREDEEM_PTD` | `ODS_O32_TAPPLYREDEEM_PFD.sh` |
| `ODS_O32_TCASHBUSINESS_PTD` | `ODS_O32_TCASHBUSINESS_PFD.sh` |
| `ODS_O32_THGMORTAGAGE_PTD` | `ODS_O32_THGMORTAGAGE_PFD.sh` |
| `ODS_O32_TSTOCKBUSINESS_PTD` | `ODS_O32_TSTOCKBUSINESS_PFD.sh` |
| `ODS_O32_TSTRIKEBUSINESS_PTD` | `ODS_O32_TSTRIKEBUSINESS_PFD.sh` |
| `ODS_O32_TSUBJECTBUSINESS_PTD` | `ODS_O32_TSUBJECTBUSINESS_PFD.sh` |

**根因推测**：`_PTD` = 增量（PARTITION by Date）、`_PFD` = 全量。上述表的 ODS 调研文档判定为**全量**，故生成 `_PFD`；
而 DWD 映射文档按**增量**理解写成 `_PTD`。

⚠️ 需业务确认：是 ODS 加载策略判错（该表其实是增量），还是引用名写错。两者改法完全不同。

### A2 ODS 侧无后缀（6）

| DWD 中引用的名字 | ODS 层实际脚本 |
|---|---|
| `ODS_OA_AGENCY_VIEW_PFD` | `ODS_OA_AGENCY_VIEW.sh` |
| `ODS_OA_COMM_REGION_PFD` | `ODS_OA_COMM_REGION.sh` |
| `ODS_OA_COMM_REGION_HIERARCHY_PFD` | `ODS_OA_COMM_REGION_HIERARCHY.sh` |
| `ODS_OA_IP_AGENCY_HIERARCHY_PFD` | `ODS_OA_IP_AGENCY_HIERARCHY.sh` |
| `ODS_OFFW_WN_FUND_MANAGER_PFD` | `ODS_OFFW_WN_FUND_MANAGER.sh` |
| `ODS_OFFW_WN_FUND_MANAGER_FUND_PFD` | `ODS_OFFW_WN_FUND_MANAGER_FUND.sh` |

> OA（6 个脚本）与 OFFW（3 个脚本）的 ODS 目标表**一律不带 `_PFD/_PTD` 后缀**。
> `tools/config.py::GLOBAL_TABLE_CN_MAP` 里也已按 `ODS_OA_AGENCY_VIEW_PFD` 登记中文名，说明代码侧一直在用带后缀的名字。

### A3 拼写差异（2）

| DWD 中引用的名字 | ODS 层实际脚本 |
|---|---|
| `ODS_HSFTA_TCUSTINFO_PFD` | `ODS_HSFTA_TCUSTOMERINFO_PFD.sh` |
| `ODS_HSFTA_TCUSTOMINFO_PFD` | `ODS_HSFTA_TCUSTOMERINFO_PFD.sh` |

> 实际表名中间有 `ER`（TCUSTOM**ER**INFO），引用侧漏写。

---

## 三、B 类：真缺抽取脚本（4 个）

| 缺失表名 | 引用它的 DWD 脚本 | 说明 |
|---|---|---|
| ~~`ODS_HSFTA_TSUBTACUSTTAILRATIO_PFD`~~ | `HSZTA/DWD_PROD_PROD_TAIL_PFD.sh` | ✅ **2026-10-04 已补**：调研表级漏登记，已补行并重新生成 |
| ~~`ODS_HSFTA_TSUBTATAILRATIO_PFD`~~ | `HSZTA/DWD_PROD_PROD_TAIL_PFD.sh` | ✅ **2026-10-04 已补**：原标「不保留」，已改为「保留」并重新生成 |
| `ODS_O32_TRATIOLOG_PTD` | `O32/DWD_TRAN_RISK_WARN_PTD.sh` | O32 全部脚本中**无任何** `RATIOLOG` / 近似名 |
| `ODS_MANUAL_SPEBA_MANUAL_INFO_PFD` | `HSZTA/DWD_PROD_PROD_EXTN_INFO_PFD.sh`<br>`HSZTA/DWD_PROD_PROD_ROLE_INFO_PFD.sh`<br>`HSZTA/DWD_PROD_PROD_SALE_FEER_INFO_PFD.sh`<br>`HSZTA/DWD_PROD_PROD_WARN_HIS_INFO_PFD.sh` | 「手工表」——无 MANUAL 系统目录，本就不该有抽取脚本 |

**逐脚本明细**

```
HSFA/DWD_EVT_BOND_TRAN_BUSIN_PTD.sh          → ODS_HSFA_TQSK_PTD
HSFA/DWD_EVT_DPSI_BILL_BUSIN_PTD.sh          → ODS_HSFA_TCAP_CKYW_PTD
HSFA/DWD_EVT_EQUI_JOUR_INFO_PTD.sh           → ODS_HSFA_TFJYGH_PTD, ODS_HSFA_TXG_PTD
HSFA/DWD_EVT_FIN_INV_BUSIN_PTD.sh            → ODS_HSFA_TQSK_PTD
HSFA/DWD_EVT_FUND_TRAN_BUSIN_PTD.sh          → ODS_HSFA_TQSK_PTD
HSFA/DWD_EVT_FUTR_TRAN_BUSIN_PTD.sh          → ODS_HSFA_TQSK_PTD
HSFA/DWD_EVT_NEW_SHARES_NEW_DEBT_BUSIN_PTD.sh→ ODS_HSFA_TXG_PTD
HSFA/DWD_EVT_OPEN_PR_BUSIN_PTD.sh            → ODS_HSFA_TQSK_PTD
HSFA/DWD_EVT_REPO_TRAN_BUSIN_PTD.sh          → ODS_HSFA_THGJY_PTD, ODS_HSFA_TXM_LS_PTD
HSFA/DWD_EVT_SCR_CHANGE_BUSIN_PTD.sh         → ODS_HSFA_TQSK_PTD
HSFA/DWD_EVT_STK_TRAN_BUSIN_PTD.sh           → ODS_HSFA_TQSK_PTD
HSFA/DWD_EVT_WRNT_TRAN_BUSIN_PTD.sh          → ODS_HSFA_TQSK_PTD
HSZTA/DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD.sh   → ODS_HSFTA_TCUSTOMINFO_PFD
HSZTA/DWD_CHNL_EXT_BTCH_INFO_PFD.sh          → ODS_OA_AGENCY_VIEW_PFD, ODS_OA_IP_AGENCY_HIERARCHY_PFD
HSZTA/DWD_CMM_AREA_INFO_PFD.sh               → ODS_OA_COMM_REGION_HIERARCHY_PFD, ODS_OA_COMM_REGION_PFD
HSZTA/DWD_CMM_CHNL_PARSE_RULE_PFD.sh         → ODS_OA_AGENCY_VIEW_PFD
HSZTA/DWD_PROD_PROD_EXTN_INFO_PFD.sh         → ODS_MANUAL_SPEBA_MANUAL_INFO_PFD
HSZTA/DWD_PROD_PROD_ROLE_INFO_PFD.sh         → ODS_MANUAL_*, ODS_OFFW_WN_FUND_MANAGER_FUND_PFD, ODS_OFFW_WN_FUND_MANAGER_PFD
HSZTA/DWD_PROD_PROD_SALE_FEER_INFO_PFD.sh    → ODS_MANUAL_SPEBA_MANUAL_INFO_PFD
HSZTA/DWD_PROD_PROD_TAIL_PFD.sh              → ODS_HSFTA_TSUBTACUSTTAILRATIO_PFD, ODS_HSFTA_TSUBTATAILRATIO_PFD
HSZTA/DWD_PROD_PROD_WARN_HIS_INFO_PFD.sh     → ODS_MANUAL_SPEBA_MANUAL_INFO_PFD
HSZTA/DWD_TRAN_MKT_TRAN_CNFM_PTD.sh          → ODS_HSFTA_TCUSTINFO_PFD
O32/DWD_TRAN_CPTL_MANUAL_BUSIN_PFD.sh        → ODS_O32_TCASHBUSINESS_PTD
O32/DWD_TRAN_CRSE_MANUAL_BUSIN_PFD.sh        → ODS_O32_TSUBJECTBUSINESS_PTD
O32/DWD_TRAN_OPEN_FUND_ALLOT_REDEM_PFD.sh    → ODS_O32_TAPPLYREDEEM_PTD
O32/DWD_TRAN_RISK_WARN_PTD.sh                → ODS_O32_TRATIOLOG_PTD
O32/DWD_TRAN_ROUG_REPO_PLG_STK_PFD.sh        → ODS_O32_THGMORTAGAGE_PTD
O32/DWD_TRAN_SCR_MANUAL_BUSIN_PFD.sh         → ODS_O32_TSTOCKBUSINESS_PTD
O32/DWD_TRAN_SETL_MANUAL_BUSIN_PFD.sh        → ODS_O32_TSTRIKEBUSINESS_PTD
```

---

## 四、DWD_PROD_PROD_TAIL_PFD 权威依赖（来自依赖关系梳理表）

| 分层 | 源系统 | 源表英文名称 | 源表中文名称 | 所属工作流 |
|---|---|---|---|---|
| DWDXDAY | ODS_XDAY_HSZTA | `ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD` | 尾随佣金比例 | HSZTA2 |
| DWDXDAY | ODS_XDAY_HSFTA | `ODS_HSFTA_TSUBTACUSTTAILRATIO_PFD` | 尾随佣金比例 | HSFTA2 |
| DWDXDAY | DWDXDAY | `DWD_PROD_PROD_TAIL_PFD`（自） | 产品尾随佣金 | DWD_PROD |
| DWDXDAY | DWDXDAY | `DWD_PROD_PROD_NUM_MAPP_PFD` | 产品编码映射 | DWD_PROD |
| DWDXDAY | DWDXDAY | `DWD_CHNL_CHNL_BASIC_INFO_PFD` | 渠道基本信息 | DWD_CHNL |
| DWDXDAY | DWDXDAY | `DWD_CMM_STD_DICT_CDVAL_MAP` | 标准字典码值映射 | 手工表 |

**与当前脚本头部「-- ** 源表：」声明块的差异**（脚本由 `tools/generator/base.py::generate_etl` 的 `dep_block` 生成，
来源是 SQL 里**实际用到的别名**、按物理表名去重）：

| 依赖表 | 脚本声明块 | 依赖关系表 |
|---|---|---|
| `ODS_HSZTA_TTAILRATIO_PFD` | ✅ 有 | ❌ 无 |
| `ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD` | ❌ 无 | ✅ 有 |
| `ODS_HSFTA_TSUBTACUSTTAILRATIO_PFD` | ❌ 无 | ✅ 有 |
| `DWD_PROD_PROD_TAIL_PFD`（自） | ❌ 无 | ✅ 有 |
| `DWD_PROD_PROD_NUM_MAPP_PFD` | ✅ 有 | ✅ 有 |
| `DWD_CHNL_CHNL_BASIC_INFO_PFD` | ✅ 有 | ✅ 有 |
| `DWD_CMM_STD_DICT_CDVAL_MAP` | ✅ 有 | ✅ 有 |

> 脚本 SQL 的 FROM/JOIN 里确实出现了 `ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD`、
> `ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTATAILRATIO_PFD` 等表，但 `dep_block` 未收录。
>
> ★ **2026-10-04 22:30 已修复**：根因不是映射表缺值，而是 `base.py` 里 `all_aliases`
> **以别名为键**，多组 `UNION ALL` 时各组都从 `A1/A2/A3` 重新命名 ⇒ 只保住第一组。
> 修复后本脚本的声明块已从 4 条变成 14 行（6 张源表全覆盖）。
> 详见 `主数据生成说明.md` 第六节。

---

## 五、附：00-主数据 依赖体检（同一脚本口径）

23 张目标表 / 64 处 ODS 引用，其中 6 处待处理：

| 类别 | 引用名 | 实际情况 |
|---|---|---|
| B-后缀 | `ODS_O32_TSTOCKINFO_PTD` | → `ODS_O32_TSTOCKINFO_PFD` |
| B-后缀 | `ODS_O32_THGMORTAGAGE_PTD` | → `ODS_O32_THGMORTAGAGE_PFD` |
| B-后缀 | `ODS_HSFA_TQSK_PTD` | → `ODS_HSFA_TQSK_PFD` |
| B-后缀 | `ODS_HSFA_THGJY_PTD` | → `ODS_HSFA_THGJY_PFD` |
| **真缺** | `ODS_O32_TBANKACCOUNT_PFD` | O32 有 `TBANKINFO_PFD`/`TSELFBANKACCOUNT_PFD`，无 `TBANKACCOUNT_PFD` |
| **真缺** | `ODS_MANUAL_SPEBA_MANUAL_INFO_PFD` | 手工表 |

---

## 六、建议

1. **A 类（20 个）**：不要动 ODS，改 DWD 映射侧的「源表英文名」列（或引用名），先与业务确认
   `_PTD/_PFD` 到底哪个对 —— 这直接决定要不要重建 ODS 加载策略。
2. **B 类（4 个）**：
   - `ODS_MANUAL_*` → 建立「手工表」约定（不生成抽取脚本，由 DWD 侧直接用外部表）。
   - `ODS_O32_TRATIOLOG_PTD` → 需业务确认该表在 O32 源库的真实表名。
   - ~~`ODS_HSFTA_TSUBTA*TAILRATIO_PFD`~~ → ✅ **已补**（2026-10-04）：根因是**表级调研的输入问题**，
     不是生成器 bug —— `TSUBTATAILRATIO` 被标「不保留」、`TSUBTACUSTTAILRATIO` 整行漏登记。
     已改调研 Excel 并重跑，HSFTA ODS 50 → 52 张。详见 `D:\datax\docs\DWD依赖节点与布局.md` 第五节（旧文《DS依赖节点配置-DWD_PROD_PROD_TAIL_PFD.md》2026-10-18 已合并归档）。
3. **`tools/config.py::GLOBAL_TABLE_CN_MAP`** 里的 OA/OFFW 中文名映射用的是带后缀的名字，与 ODS 实际表名不符 ——
   A2 若按「引用侧去后缀」修，这份映射也要同步改。
