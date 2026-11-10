# DWS 语法校验

- 日期：`20261018`
- 方式：本地 Hive 实际元数据 `EXPLAIN`，不执行、不写入
- 范围：`scripts/{系统}/dws/02_etl` 的 24 个脚本，24 个 SQL 块
- 结果：**24/24 通过**，失败 0

## 逐脚本

| 分组 | 脚本 | 块数 | 结果 |
|---|---|---:|---|
| HSFA | `DWS_PROD_AST_INFO_PTD.sh` | 1 | 通过 |
| HSFA | `DWS_PROD_EQUI_INFO_PTD.sh` | 1 | 通过 |
| HSFA | `DWS_PROD_SALE_DATA_PTD.sh` | 1 | 通过 |
| HSFA | `DWS_PROD_SCR_HLDP_DETAIL_PTD.sh` | 1 | 通过 |
| HSFA | `DWS_PROD_SCR_PL_DETAIL_PTD.sh` | 1 | 通过 |
| HSFA | `DWS_PROD_SCR_TRAN_DETAIL_PTD.sh` | 1 | 通过 |
| HSFA | `DWS_PROD_SUM_INFO_PTD.sh` | 1 | 通过 |
| HSZTA | `DWS_CUST_FST_TRAN_BTCH_PFD.sh` | 1 | 通过 |
| HSZTA | `DWS_CUST_HOLD_AST_SUM_PFD.sh` | 1 | 通过 |
| HSZTA | `DWS_CUST_HOLD_DETAIL_PTD.sh` | 1 | 通过 |
| HSZTA | `DWS_PROD_HOLD_DETAIL_PTD.sh` | 1 | 通过 |
| HSZTA | `DWS_PROD_INFO_PFD.sh` | 1 | 通过 |
| HSZTA | `DWS_TRAN_ACCT_OPEN_BTCH_PFD.sh` | 1 | 通过 |
| HSZTA | `DWS_TRAN_AFFI_BTCH_PTD.sh` | 1 | 通过 |
| HSZTA | `DWS_TRAN_MKT_TRAN_CNFM_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_BOND_TRAN_DETAIL_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_DPSI_TRAN_DETAIL_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_EXCH_BOND_OUT_IN_DETAIL_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_EXCH_FUND_TRAN_DETAIL_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_FUTR_TRAN_DETAIL_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_OTC_FUND_TRAN_DETAIL_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_REPO_TRAN_DETAIL_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_SCR_CHANGE_DETAIL_PTD.sh` | 1 | 通过 |
| O32 | `DWS_TRAN_STK_TRAN_DETAIL_PTD.sh` | 1 | 通过 |
