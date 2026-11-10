#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TASSETDAY_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TASSETDAY_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  EN_BEGIN_CASH  DECIMAL(18,2)  COMMENT  '期初资金余额',
  EN_CURRENT_CASH  DECIMAL(18,2)  COMMENT  '*当前资金余额',
  EN_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '*冻结金额',
  EN_UNFROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '*解冻金额',
  EN_BASIC_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '保证金*',
  EN_PREBUY_BALANCE  DECIMAL(18,2)  COMMENT  '*当日预买金额',
  EN_PRESALE_BALANCE  DECIMAL(18,2)  COMMENT  '当日预卖金额',
  EN_BUY_BALANCE  DECIMAL(18,2)  COMMENT  '*当日买入金额',
  EN_SALE_BALANCE  DECIMAL(18,2)  COMMENT  '*当日卖出金额',
  EN_TEMP_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '当日临时冻结金额',
  EN_TEMP_UNFROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '当日临时解冻金额',
  EN_T1_TEMP_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  't+1临时冻结金额',
  EN_T1_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  't+1冻结金额',
  EN_BUY_UNSETTLE_BALANCE  DECIMAL(18,2)  COMMENT  '买入未交割金额',
  EN_SALE_UNSETTLE_BALANCE  DECIMAL(18,2)  COMMENT  '卖出未交割金额',
  EN_STOCK_ASSET  DECIMAL(18,2)  COMMENT  '股票资产',
  EN_BOND_ASSET  DECIMAL(18,2)  COMMENT  '债券资产',
  EN_FUND_ASSET  DECIMAL(18,2)  COMMENT  '基金资产',
  EN_HG_ASSET  DECIMAL(18,2)  COMMENT  '回购资产',
  EN_WARRANT_ASSET  DECIMAL(18,2)  COMMENT  '权证资产',
  EN_OTHER_ASSET  DECIMAL(18,2)  COMMENT  '其他资产',
  EN_ACCUMULATE_PROFIT  DECIMAL(18,2)  COMMENT  '累计实现收益',
  EN_RATIO  DECIMAL(18,2)  COMMENT  '拆分比例',
  EN_RECEIVABLE  DECIMAL(18,2)  COMMENT  '合计应收',
  EN_PAYABLE  DECIMAL(18,2)  COMMENT  '合计应付',
  EN_ASSET_SHARE  DECIMAL(18,2)  COMMENT  '份额',
  EN_ASSET_VALUE_YESTERDAY  DECIMAL(18,2)  COMMENT  '昨日净资产',
  EN_PAYOUT_BALANCE  DECIMAL(18,2)  COMMENT  '当日支取金额',
  EN_FUTURES_BALANCE  DECIMAL(18,2)  COMMENT  '期货保证金账户余额',
  EN_FUTURES_DEPOSIT  DECIMAL(18,2)  COMMENT  '期货保证金',
  EN_FUTURES_PREPARE  DECIMAL(18,2)  COMMENT  '期货最低准准备金',
  EN_FUTURES_ASSET  DECIMAL(18,2)  COMMENT  '期货盈亏',
  EN_ASSET_VALUE  DECIMAL(18,2)  COMMENT  '净资产',
  EN_PAYIN_BALANCE  DECIMAL(18,2)  COMMENT  '当日投入金额',
  EN_PAYIN_TOTAL  DECIMAL(18,2)  COMMENT  '累计投入金额',
  EN_PAYOUT_TOTAL  DECIMAL(18,2)  COMMENT  '累计支取金额',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  EN_BEGIN_T0_ENABLE  DECIMAL(18,2)  COMMENT  '日初t日可用金额',
  EN_BEGIN_T1_ENABLE  DECIMAL(18,2)  COMMENT  '日初t+1可用金额',
  EN_INTEREST_BALANCE  DECIMAL(18,2)  COMMENT  '利息积数',
  EN_TOTAL_YJ  DECIMAL(18,2)  COMMENT  '累计佣金',
  L_BEGINCALC_DATE  DECIMAL(8,0)  COMMENT  '起计日期',
  EN_COMMISION_RATIO  DECIMAL(9,8)  COMMENT  '实际收入的佣金比例',
  D_LASTUPDATE  STRING  COMMENT  '前次更新时间',
  EN_PRINCIPAL_ACCRUAL  DECIMAL(20,2)  COMMENT  '本金积数',
  EN_DEPOSIT_BALANCE  DECIMAL(18,2)  COMMENT  '存款余额',
  EN_NAV  DECIMAL(16,8)  COMMENT  '单位净值',
  EN_NAV_YESTERDAY  DECIMAL(16,8)  COMMENT  '昨日单位净值',
  EN_UNIT_DIVIDENDS  DECIMAL(8,4)  COMMENT  '单位分红金额',
  EN_TOTAL_UNIT_DIVIDENDS  DECIMAL(8,4)  COMMENT  '累计单位分红金额',
  EN_BOND_INTEREST  DECIMAL(18,2)  COMMENT  '债券利息',
  EN_ASSET_TOTAL_VALUE  DECIMAL(18,2)  COMMENT  '资产单元总资产',
  EN_BEGIN_PROFIT_RATIO  DECIMAL(9,8)  COMMENT  '期初收益比例',
  EN_T1_PREBUY_BALANCE  DECIMAL(16,2)  COMMENT  't+1日预买金额',
  EN_T1_PRESALE_BALANCE  DECIMAL(16,2)  COMMENT  't+1日预卖金额',
  EN_SECACC_BONUS  DECIMAL(16,2)  COMMENT  '融券账户红利金额',
  EN_FUTURE_TEMP_BALANCE  DECIMAL(18,2)  COMMENT  '期货临时冻结保证金',
  EN_TRUST_BALANCE  DECIMAL(16,2)  COMMENT  '授信额度',
  EN_REC_SEC_ASSET  DECIMAL(18,2)  COMMENT  '应收证券资产',
  EN_PAY_SEC_ASSET  DECIMAL(18,2)  COMMENT  '应付证券资产',
  EN_FUTURES_SETTLE_DEPOSIT  DECIMAL(18,2)  COMMENT  '期货交割保证金占用金额',
  EN_PREIPO_DEPOSIT  DECIMAL(18,2)  COMMENT  '预发行已收取保证金',
  L_FIRST_PAYIN_DATE  DECIMAL(8,0)  COMMENT  '初始投入日期',
  EN_PRINCIPAL_DAILY  DECIMAL(16,2)  COMMENT  '日均本金',
  EN_ASSET_SHARE_YESTERDAY  DECIMAL(18,2)  COMMENT  '昨日份额',
  EN_OPTION_ASSET  DECIMAL(18,2)  COMMENT  '期权资产',
  EN_BUY_UNASSET_BALANCE  DECIMAL(18,2)  COMMENT  '买入资产未变化金额',
  EN_SALE_UNASSET_BALANCE  DECIMAL(18,2)  COMMENT  '卖出资产未变化金额',
  EN_FUTURE_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '期货保证金冻结金额',
  EN_T2_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '沪港通t+2冻结金额',
  EN_T2_TEMP_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '沪港通t+2临时冻结金额',
  EN_OTC_FRZN_BALANCE  DECIMAL(18,2)  COMMENT  '场外冻结金额',
  EN_OTC_UNFRZN_BALANCE  DECIMAL(18,2)  COMMENT  '场外解冻金额',
  EN_T1OTC_FRZN_BALANCE  DECIMAL(18,2)  COMMENT  't+1场外冻结金额',
  EN_BUY_BALANCE_HGT  DECIMAL(18,2)  COMMENT  '沪港通买入金额',
  EN_SALE_BALANCE_HGT  DECIMAL(18,2)  COMMENT  '沪港通卖出金额',
  EN_BUY_BALANCE_SGT  DECIMAL(18,2)  COMMENT  '深港通买入金额',
  EN_SALE_BALANCE_SGT  DECIMAL(18,2)  COMMENT  '深港通卖出金额',
  EN_T2_FROZEN_BALANCE_SGT  DECIMAL(18,2)  COMMENT  '深港通t+2冻结金额2',
  EN_T2_TEMP_FROZEN_BALANCE_SGT  DECIMAL(18,2)  COMMENT  '深港通t+2临时冻结金额2',
  EN_CHANGE_BALANCE_JYS  DECIMAL(18,2)  COMMENT  '交易所t+2变化金额',
  EN_CHANGE_BALANCE_YHJ  DECIMAL(18,2)  COMMENT  '银行间t+2变化金额',
  EN_RISK_GGT  DECIMAL(18,2)  COMMENT  '港股风险资金',
  EN_CMM_PREBUY_MARGIN  DECIMAL(18,2)  COMMENT  '套利单预买保证金占用金额',
  EN_T1CHANGE_BALANCE_GGT  DECIMAL(18,2)  COMMENT  '港股通t和t1交易资金轧差',
  EN_CMMOPT_TEMP_BALANCE  DECIMAL(16,2)  COMMENT  '',
  EN_ACCUMULATE_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期累计实现收益',
  EN_TURN_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期未结转收益',
  EN_NET_GAIN_GQ  DECIMAL(18,2)  COMMENT  '过期结转后扣费用累计收益',
  EN_UNCARRYOVER_NET_GAIN_GQ  DECIMAL(18,2)  COMMENT  '过期未结转扣费用期初收益',
  EN_INTEREST_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期债券利息收益',
  EN_TURN_INTEREST_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期结转债券利息收益',
  EN_INTEREST_GAIN_GQ  DECIMAL(18,2)  COMMENT  '过期债券利息实现收益',
  EN_TURN_INTEREST_GAIN_GQ  DECIMAL(18,2)  COMMENT  '过期结转债券利息实现收益',
  EN_BEGINYEAR_TURN_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期年初结转收益',
  EN_BEGINYEAR_UNTURN_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期年初未结转收益',
  EN_GOLD_ASSET  DECIMAL(18,2)  COMMENT  '',
  EN_GOLD_PROFIT  DECIMAL(18,2)  COMMENT  '',
  EN_GOLD_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_BEGIN_FUTURE_RIGHTS  DECIMAL(18,2)  COMMENT  '期初期货保证金余额',
  EN_REDEEM_RATIO  DECIMAL(18,2)  COMMENT  '',
  EN_BONUS_RATIO  DECIMAL(18,2)  COMMENT  '',
  EN_GOLD_EQUITY  DECIMAL(18,2)  COMMENT  '',
  EN_GOLD_SPOT  DECIMAL(18,2)  COMMENT  '',
  EN_GURANTEESECFUT_BALANCE  DECIMAL(18,2)  COMMENT  '',
  EN_STOCK_ASSET_GGT  DECIMAL(18,2)  COMMENT  '',
  EN_STOCK_ASSET_NOGGT  DECIMAL(18,2)  COMMENT  '',
  EN_OUTFLOW_BALANCE_GGT  DECIMAL(18,2)  COMMENT  '',
  EN_BROKER_BALANCE  DECIMAL(18,2)  COMMENT  '',
  EN_BANK_BALANCE  DECIMAL(18,2)  COMMENT  '',
  EN_BANK_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '',
  EN_ENERALHG_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_IRS_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_FINADEBT_ASSET  DECIMAL(18,2)  COMMENT  '',
  EN_FINADEBT_INTEREST  DECIMAL(18,2)  COMMENT  '',
  EN_FUT_REPORT_FEE  DECIMAL(16,2)  COMMENT  '',
  EN_IRS_FROZEN_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_IRS_PRICE  DECIMAL(18,2)  COMMENT  '',
  EN_IRS_OFFSET_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_EXERCISE_TEMP_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_SECFUT_EXERCISE_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_CMM_SECFUT_PREBUY_MARGIN  DECIMAL(18,2)  COMMENT  '',
  EN_DERIVATIVES_ASSET  DECIMAL(18,2)  COMMENT  '',
  EN_PRENETBUY_BALANCE  DECIMAL(18,2)  COMMENT  '',
  EN_FUND_ASSET_GGT  DECIMAL(18,2)  COMMENT  '',
  EN_FUND_ASSET_NOGGT  DECIMAL(18,2)  COMMENT  '',
  EN_FUTURE_INTEREST  DECIMAL(18,2)  COMMENT  '',
  EN_ONLY_T1_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '',
  EN_RISK_SGT  DECIMAL(18,2)  COMMENT  '',
  EN_ASSET_JSSJJS_VALUE  DECIMAL(18,2)  COMMENT  '',
  EN_DF_BOND_ASSET_TOTAL  DECIMAL(18,2)  COMMENT  '',
  EN_DF_BOND_ASSET  DECIMAL(18,2)  COMMENT  '',
  EN_DX_BOND_ASSET_TOTAL  DECIMAL(18,2)  COMMENT  '',
  EN_DX_BOND_ASSET  DECIMAL(18,2)  COMMENT  '',
  EN_DEVALUE_VALUE  DECIMAL(18,2)  COMMENT  '',
  EN_BZJYE_RZ  DECIMAL(18,2)  COMMENT  '',
  EN_PREBUY_BALANCE_HGT  DECIMAL(18,2)  COMMENT  '',
  EN_PRESALE_BALANCE_HGT  DECIMAL(18,2)  COMMENT  '',
  EN_PREBUY_BALANCE_SGT  DECIMAL(18,2)  COMMENT  '',
  EN_PRESALE_BALANCE_SGT  DECIMAL(18,2)  COMMENT  '',
  EN_PREPAY_BALANCE_DIFF  DECIMAL(18,2)  COMMENT  ''
)
COMMENT '资产单元日信息表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\u0001';"

json_obj=$(cat <<'EOF'
{
  "job": {
    "setting": {
      "speed": {
        "channel": 1
      },
      "errorLimit": {
        "record": 0,
        "percentage": 0.02
      }
    },
    "content": [
      {
        "reader": {
          "name": "oraclereader",
          "parameter": {
            "username": "${o32_username}",
            "password": "${o32_password}",
            "connection": [{
              "querySql": ["SELECT  L_DATE
                                   , L_ASSET_ID
                                   , L_FUND_ID
                                   , EN_BEGIN_CASH
                                   , EN_CURRENT_CASH
                                   , EN_FROZEN_BALANCE
                                   , EN_UNFROZEN_BALANCE
                                   , EN_BASIC_FROZEN_BALANCE
                                   , EN_PREBUY_BALANCE
                                   , EN_PRESALE_BALANCE
                                   , EN_BUY_BALANCE
                                   , EN_SALE_BALANCE
                                   , EN_TEMP_FROZEN_BALANCE
                                   , EN_TEMP_UNFROZEN_BALANCE
                                   , EN_T1_TEMP_FROZEN_BALANCE
                                   , EN_T1_FROZEN_BALANCE
                                   , EN_BUY_UNSETTLE_BALANCE
                                   , EN_SALE_UNSETTLE_BALANCE
                                   , EN_STOCK_ASSET
                                   , EN_BOND_ASSET
                                   , EN_FUND_ASSET
                                   , EN_HG_ASSET
                                   , EN_WARRANT_ASSET
                                   , EN_OTHER_ASSET
                                   , EN_ACCUMULATE_PROFIT
                                   , EN_RATIO
                                   , EN_RECEIVABLE
                                   , EN_PAYABLE
                                   , EN_ASSET_SHARE
                                   , EN_ASSET_VALUE_YESTERDAY
                                   , EN_PAYOUT_BALANCE
                                   , EN_FUTURES_BALANCE
                                   , EN_FUTURES_DEPOSIT
                                   , EN_FUTURES_PREPARE
                                   , EN_FUTURES_ASSET
                                   , EN_ASSET_VALUE
                                   , EN_PAYIN_BALANCE
                                   , EN_PAYIN_TOTAL
                                   , EN_PAYOUT_TOTAL
                                   , VC_CURRENCY_NO
                                   , EN_BEGIN_T0_ENABLE
                                   , EN_BEGIN_T1_ENABLE
                                   , EN_INTEREST_BALANCE
                                   , EN_TOTAL_YJ
                                   , L_BEGINCALC_DATE
                                   , EN_COMMISION_RATIO
                                   , D_LASTUPDATE
                                   , EN_PRINCIPAL_ACCRUAL
                                   , EN_DEPOSIT_BALANCE
                                   , EN_NAV
                                   , EN_NAV_YESTERDAY
                                   , EN_UNIT_DIVIDENDS
                                   , EN_TOTAL_UNIT_DIVIDENDS
                                   , EN_BOND_INTEREST
                                   , EN_ASSET_TOTAL_VALUE
                                   , EN_BEGIN_PROFIT_RATIO
                                   , EN_T1_PREBUY_BALANCE
                                   , EN_T1_PRESALE_BALANCE
                                   , EN_SECACC_BONUS
                                   , EN_FUTURE_TEMP_BALANCE
                                   , EN_TRUST_BALANCE
                                   , EN_REC_SEC_ASSET
                                   , EN_PAY_SEC_ASSET
                                   , EN_FUTURES_SETTLE_DEPOSIT
                                   , EN_PREIPO_DEPOSIT
                                   , L_FIRST_PAYIN_DATE
                                   , EN_PRINCIPAL_DAILY
                                   , EN_ASSET_SHARE_YESTERDAY
                                   , EN_OPTION_ASSET
                                   , EN_BUY_UNASSET_BALANCE
                                   , EN_SALE_UNASSET_BALANCE
                                   , EN_FUTURE_FROZEN_BALANCE
                                   , EN_T2_FROZEN_BALANCE
                                   , EN_T2_TEMP_FROZEN_BALANCE
                                   , EN_OTC_FRZN_BALANCE
                                   , EN_OTC_UNFRZN_BALANCE
                                   , EN_T1OTC_FRZN_BALANCE
                                   , EN_BUY_BALANCE_HGT
                                   , EN_SALE_BALANCE_HGT
                                   , EN_BUY_BALANCE_SGT
                                   , EN_SALE_BALANCE_SGT
                                   , EN_T2_FROZEN_BALANCE_SGT
                                   , EN_T2_TEMP_FROZEN_BALANCE_SGT
                                   , EN_CHANGE_BALANCE_JYS
                                   , EN_CHANGE_BALANCE_YHJ
                                   , EN_RISK_GGT
                                   , EN_CMM_PREBUY_MARGIN
                                   , EN_T1CHANGE_BALANCE_GGT
                                   , EN_CMMOPT_TEMP_BALANCE
                                   , EN_ACCUMULATE_PROFIT_GQ
                                   , EN_TURN_PROFIT_GQ
                                   , EN_NET_GAIN_GQ
                                   , EN_UNCARRYOVER_NET_GAIN_GQ
                                   , EN_INTEREST_PROFIT_GQ
                                   , EN_TURN_INTEREST_PROFIT_GQ
                                   , EN_INTEREST_GAIN_GQ
                                   , EN_TURN_INTEREST_GAIN_GQ
                                   , EN_BEGINYEAR_TURN_PROFIT_GQ
                                   , EN_BEGINYEAR_UNTURN_PROFIT_GQ
                                   , EN_GOLD_ASSET
                                   , EN_GOLD_PROFIT
                                   , EN_GOLD_DEPOSIT
                                   , EN_BEGIN_FUTURE_RIGHTS
                                   , EN_REDEEM_RATIO
                                   , EN_BONUS_RATIO
                                   , EN_GOLD_EQUITY
                                   , EN_GOLD_SPOT
                                   , EN_GURANTEESECFUT_BALANCE
                                   , EN_STOCK_ASSET_GGT
                                   , EN_STOCK_ASSET_NOGGT
                                   , EN_OUTFLOW_BALANCE_GGT
                                   , EN_BROKER_BALANCE
                                   , EN_BANK_BALANCE
                                   , EN_BANK_FROZEN_BALANCE
                                   , EN_ENERALHG_DEPOSIT
                                   , EN_IRS_DEPOSIT
                                   , EN_FINADEBT_ASSET
                                   , EN_FINADEBT_INTEREST
                                   , EN_FUT_REPORT_FEE
                                   , EN_IRS_FROZEN_DEPOSIT
                                   , EN_IRS_PRICE
                                   , EN_IRS_OFFSET_DEPOSIT
                                   , EN_EXERCISE_TEMP_DEPOSIT
                                   , EN_SECFUT_EXERCISE_DEPOSIT
                                   , EN_CMM_SECFUT_PREBUY_MARGIN
                                   , EN_DERIVATIVES_ASSET
                                   , EN_PRENETBUY_BALANCE
                                   , EN_FUND_ASSET_GGT
                                   , EN_FUND_ASSET_NOGGT
                                   , EN_FUTURE_INTEREST
                                   , EN_ONLY_T1_FROZEN_BALANCE
                                   , EN_RISK_SGT
                                   , EN_ASSET_JSSJJS_VALUE
                                   , EN_DF_BOND_ASSET_TOTAL
                                   , EN_DF_BOND_ASSET
                                   , EN_DX_BOND_ASSET_TOTAL
                                   , EN_DX_BOND_ASSET
                                   , EN_DEVALUE_VALUE
                                   , EN_BZJYE_RZ
                                   , EN_PREBUY_BALANCE_HGT
                                   , EN_PRESALE_BALANCE_HGT
                                   , EN_PREBUY_BALANCE_SGT
                                   , EN_PRESALE_BALANCE_SGT
                                   , EN_PREPAY_BALANCE_DIFF
                                FROM ${o32_src_schema}.THISASSETDAY
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "EN_BEGIN_CASH", "type": "DOUBLE"}, {"name": "EN_CURRENT_CASH", "type": "DOUBLE"}, {"name": "EN_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_UNFROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_BASIC_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_PREBUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_PRESALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_TEMP_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_TEMP_UNFROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_T1_TEMP_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_T1_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_UNSETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_UNSETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_STOCK_ASSET", "type": "DOUBLE"}, {"name": "EN_BOND_ASSET", "type": "DOUBLE"}, {"name": "EN_FUND_ASSET", "type": "DOUBLE"}, {"name": "EN_HG_ASSET", "type": "DOUBLE"}, {"name": "EN_WARRANT_ASSET", "type": "DOUBLE"}, {"name": "EN_OTHER_ASSET", "type": "DOUBLE"}, {"name": "EN_ACCUMULATE_PROFIT", "type": "DOUBLE"}, {"name": "EN_RATIO", "type": "DOUBLE"}, {"name": "EN_RECEIVABLE", "type": "DOUBLE"}, {"name": "EN_PAYABLE", "type": "DOUBLE"}, {"name": "EN_ASSET_SHARE", "type": "DOUBLE"}, {"name": "EN_ASSET_VALUE_YESTERDAY", "type": "DOUBLE"}, {"name": "EN_PAYOUT_BALANCE", "type": "DOUBLE"}, {"name": "EN_FUTURES_BALANCE", "type": "DOUBLE"}, {"name": "EN_FUTURES_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_FUTURES_PREPARE", "type": "DOUBLE"}, {"name": "EN_FUTURES_ASSET", "type": "DOUBLE"}, {"name": "EN_ASSET_VALUE", "type": "DOUBLE"}, {"name": "EN_PAYIN_BALANCE", "type": "DOUBLE"}, {"name": "EN_PAYIN_TOTAL", "type": "DOUBLE"}, {"name": "EN_PAYOUT_TOTAL", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "EN_BEGIN_T0_ENABLE", "type": "DOUBLE"}, {"name": "EN_BEGIN_T1_ENABLE", "type": "DOUBLE"}, {"name": "EN_INTEREST_BALANCE", "type": "DOUBLE"}, {"name": "EN_TOTAL_YJ", "type": "DOUBLE"}, {"name": "L_BEGINCALC_DATE", "type": "DOUBLE"}, {"name": "EN_COMMISION_RATIO", "type": "DOUBLE"}, {"name": "D_LASTUPDATE", "type": "STRING"}, {"name": "EN_PRINCIPAL_ACCRUAL", "type": "DOUBLE"}, {"name": "EN_DEPOSIT_BALANCE", "type": "DOUBLE"}, {"name": "EN_NAV", "type": "DOUBLE"}, {"name": "EN_NAV_YESTERDAY", "type": "DOUBLE"}, {"name": "EN_UNIT_DIVIDENDS", "type": "DOUBLE"}, {"name": "EN_TOTAL_UNIT_DIVIDENDS", "type": "DOUBLE"}, {"name": "EN_BOND_INTEREST", "type": "DOUBLE"}, {"name": "EN_ASSET_TOTAL_VALUE", "type": "DOUBLE"}, {"name": "EN_BEGIN_PROFIT_RATIO", "type": "DOUBLE"}, {"name": "EN_T1_PREBUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_T1_PRESALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_SECACC_BONUS", "type": "DOUBLE"}, {"name": "EN_FUTURE_TEMP_BALANCE", "type": "DOUBLE"}, {"name": "EN_TRUST_BALANCE", "type": "DOUBLE"}, {"name": "EN_REC_SEC_ASSET", "type": "DOUBLE"}, {"name": "EN_PAY_SEC_ASSET", "type": "DOUBLE"}, {"name": "EN_FUTURES_SETTLE_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_PREIPO_DEPOSIT", "type": "DOUBLE"}, {"name": "L_FIRST_PAYIN_DATE", "type": "DOUBLE"}, {"name": "EN_PRINCIPAL_DAILY", "type": "DOUBLE"}, {"name": "EN_ASSET_SHARE_YESTERDAY", "type": "DOUBLE"}, {"name": "EN_OPTION_ASSET", "type": "DOUBLE"}, {"name": "EN_BUY_UNASSET_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_UNASSET_BALANCE", "type": "DOUBLE"}, {"name": "EN_FUTURE_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_T2_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_T2_TEMP_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_OTC_FRZN_BALANCE", "type": "DOUBLE"}, {"name": "EN_OTC_UNFRZN_BALANCE", "type": "DOUBLE"}, {"name": "EN_T1OTC_FRZN_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE_HGT", "type": "DOUBLE"}, {"name": "EN_SALE_BALANCE_HGT", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE_SGT", "type": "DOUBLE"}, {"name": "EN_SALE_BALANCE_SGT", "type": "DOUBLE"}, {"name": "EN_T2_FROZEN_BALANCE_SGT", "type": "DOUBLE"}, {"name": "EN_T2_TEMP_FROZEN_BALANCE_SGT", "type": "DOUBLE"}, {"name": "EN_CHANGE_BALANCE_JYS", "type": "DOUBLE"}, {"name": "EN_CHANGE_BALANCE_YHJ", "type": "DOUBLE"}, {"name": "EN_RISK_GGT", "type": "DOUBLE"}, {"name": "EN_CMM_PREBUY_MARGIN", "type": "DOUBLE"}, {"name": "EN_T1CHANGE_BALANCE_GGT", "type": "DOUBLE"}, {"name": "EN_CMMOPT_TEMP_BALANCE", "type": "DOUBLE"}, {"name": "EN_ACCUMULATE_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_TURN_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_NET_GAIN_GQ", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_NET_GAIN_GQ", "type": "DOUBLE"}, {"name": "EN_INTEREST_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_INTEREST_GAIN_GQ", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_GAIN_GQ", "type": "DOUBLE"}, {"name": "EN_BEGINYEAR_TURN_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_BEGINYEAR_UNTURN_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_GOLD_ASSET", "type": "DOUBLE"}, {"name": "EN_GOLD_PROFIT", "type": "DOUBLE"}, {"name": "EN_GOLD_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_BEGIN_FUTURE_RIGHTS", "type": "DOUBLE"}, {"name": "EN_REDEEM_RATIO", "type": "DOUBLE"}, {"name": "EN_BONUS_RATIO", "type": "DOUBLE"}, {"name": "EN_GOLD_EQUITY", "type": "DOUBLE"}, {"name": "EN_GOLD_SPOT", "type": "DOUBLE"}, {"name": "EN_GURANTEESECFUT_BALANCE", "type": "DOUBLE"}, {"name": "EN_STOCK_ASSET_GGT", "type": "DOUBLE"}, {"name": "EN_STOCK_ASSET_NOGGT", "type": "DOUBLE"}, {"name": "EN_OUTFLOW_BALANCE_GGT", "type": "DOUBLE"}, {"name": "EN_BROKER_BALANCE", "type": "DOUBLE"}, {"name": "EN_BANK_BALANCE", "type": "DOUBLE"}, {"name": "EN_BANK_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_ENERALHG_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_IRS_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_FINADEBT_ASSET", "type": "DOUBLE"}, {"name": "EN_FINADEBT_INTEREST", "type": "DOUBLE"}, {"name": "EN_FUT_REPORT_FEE", "type": "DOUBLE"}, {"name": "EN_IRS_FROZEN_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_IRS_PRICE", "type": "DOUBLE"}, {"name": "EN_IRS_OFFSET_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_EXERCISE_TEMP_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_SECFUT_EXERCISE_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_CMM_SECFUT_PREBUY_MARGIN", "type": "DOUBLE"}, {"name": "EN_DERIVATIVES_ASSET", "type": "DOUBLE"}, {"name": "EN_PRENETBUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_FUND_ASSET_GGT", "type": "DOUBLE"}, {"name": "EN_FUND_ASSET_NOGGT", "type": "DOUBLE"}, {"name": "EN_FUTURE_INTEREST", "type": "DOUBLE"}, {"name": "EN_ONLY_T1_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_RISK_SGT", "type": "DOUBLE"}, {"name": "EN_ASSET_JSSJJS_VALUE", "type": "DOUBLE"}, {"name": "EN_DF_BOND_ASSET_TOTAL", "type": "DOUBLE"}, {"name": "EN_DF_BOND_ASSET", "type": "DOUBLE"}, {"name": "EN_DX_BOND_ASSET_TOTAL", "type": "DOUBLE"}, {"name": "EN_DX_BOND_ASSET", "type": "DOUBLE"}, {"name": "EN_DEVALUE_VALUE", "type": "DOUBLE"}, {"name": "EN_BZJYE_RZ", "type": "DOUBLE"}, {"name": "EN_PREBUY_BALANCE_HGT", "type": "DOUBLE"}, {"name": "EN_PRESALE_BALANCE_HGT", "type": "DOUBLE"}, {"name": "EN_PREBUY_BALANCE_SGT", "type": "DOUBLE"}, {"name": "EN_PRESALE_BALANCE_SGT", "type": "DOUBLE"}, {"name": "EN_PREPAY_BALANCE_DIFF", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tassetday_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tassetday_pfd_tmp",
            "writeMode": "append",
            "encoding": "utf-8",
            "haveKerberos": "${haveKerberos}",
            "kerberosKeytabFilePath": "${kerberosKeytabFilePath}",
            "kerberosPrincipal": "${kerberosPrincipal}"
          }
        }
      }
    ]
  }
}
EOF
)

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tassetday_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tassetday_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TASSETDAY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TASSETDAY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tassetday_pfd_tmp.json

inceptor_beeline "
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TASSETDAY_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , L_ASSET_ID
     , L_FUND_ID
     , EN_BEGIN_CASH
     , EN_CURRENT_CASH
     , EN_FROZEN_BALANCE
     , EN_UNFROZEN_BALANCE
     , EN_BASIC_FROZEN_BALANCE
     , EN_PREBUY_BALANCE
     , EN_PRESALE_BALANCE
     , EN_BUY_BALANCE
     , EN_SALE_BALANCE
     , EN_TEMP_FROZEN_BALANCE
     , EN_TEMP_UNFROZEN_BALANCE
     , EN_T1_TEMP_FROZEN_BALANCE
     , EN_T1_FROZEN_BALANCE
     , EN_BUY_UNSETTLE_BALANCE
     , EN_SALE_UNSETTLE_BALANCE
     , EN_STOCK_ASSET
     , EN_BOND_ASSET
     , EN_FUND_ASSET
     , EN_HG_ASSET
     , EN_WARRANT_ASSET
     , EN_OTHER_ASSET
     , EN_ACCUMULATE_PROFIT
     , EN_RATIO
     , EN_RECEIVABLE
     , EN_PAYABLE
     , EN_ASSET_SHARE
     , EN_ASSET_VALUE_YESTERDAY
     , EN_PAYOUT_BALANCE
     , EN_FUTURES_BALANCE
     , EN_FUTURES_DEPOSIT
     , EN_FUTURES_PREPARE
     , EN_FUTURES_ASSET
     , EN_ASSET_VALUE
     , EN_PAYIN_BALANCE
     , EN_PAYIN_TOTAL
     , EN_PAYOUT_TOTAL
     , VC_CURRENCY_NO
     , EN_BEGIN_T0_ENABLE
     , EN_BEGIN_T1_ENABLE
     , EN_INTEREST_BALANCE
     , EN_TOTAL_YJ
     , L_BEGINCALC_DATE
     , EN_COMMISION_RATIO
     , D_LASTUPDATE
     , EN_PRINCIPAL_ACCRUAL
     , EN_DEPOSIT_BALANCE
     , EN_NAV
     , EN_NAV_YESTERDAY
     , EN_UNIT_DIVIDENDS
     , EN_TOTAL_UNIT_DIVIDENDS
     , EN_BOND_INTEREST
     , EN_ASSET_TOTAL_VALUE
     , EN_BEGIN_PROFIT_RATIO
     , EN_T1_PREBUY_BALANCE
     , EN_T1_PRESALE_BALANCE
     , EN_SECACC_BONUS
     , EN_FUTURE_TEMP_BALANCE
     , EN_TRUST_BALANCE
     , EN_REC_SEC_ASSET
     , EN_PAY_SEC_ASSET
     , EN_FUTURES_SETTLE_DEPOSIT
     , EN_PREIPO_DEPOSIT
     , L_FIRST_PAYIN_DATE
     , EN_PRINCIPAL_DAILY
     , EN_ASSET_SHARE_YESTERDAY
     , EN_OPTION_ASSET
     , EN_BUY_UNASSET_BALANCE
     , EN_SALE_UNASSET_BALANCE
     , EN_FUTURE_FROZEN_BALANCE
     , EN_T2_FROZEN_BALANCE
     , EN_T2_TEMP_FROZEN_BALANCE
     , EN_OTC_FRZN_BALANCE
     , EN_OTC_UNFRZN_BALANCE
     , EN_T1OTC_FRZN_BALANCE
     , EN_BUY_BALANCE_HGT
     , EN_SALE_BALANCE_HGT
     , EN_BUY_BALANCE_SGT
     , EN_SALE_BALANCE_SGT
     , EN_T2_FROZEN_BALANCE_SGT
     , EN_T2_TEMP_FROZEN_BALANCE_SGT
     , EN_CHANGE_BALANCE_JYS
     , EN_CHANGE_BALANCE_YHJ
     , EN_RISK_GGT
     , EN_CMM_PREBUY_MARGIN
     , EN_T1CHANGE_BALANCE_GGT
     , EN_CMMOPT_TEMP_BALANCE
     , EN_ACCUMULATE_PROFIT_GQ
     , EN_TURN_PROFIT_GQ
     , EN_NET_GAIN_GQ
     , EN_UNCARRYOVER_NET_GAIN_GQ
     , EN_INTEREST_PROFIT_GQ
     , EN_TURN_INTEREST_PROFIT_GQ
     , EN_INTEREST_GAIN_GQ
     , EN_TURN_INTEREST_GAIN_GQ
     , EN_BEGINYEAR_TURN_PROFIT_GQ
     , EN_BEGINYEAR_UNTURN_PROFIT_GQ
     , EN_GOLD_ASSET
     , EN_GOLD_PROFIT
     , EN_GOLD_DEPOSIT
     , EN_BEGIN_FUTURE_RIGHTS
     , EN_REDEEM_RATIO
     , EN_BONUS_RATIO
     , EN_GOLD_EQUITY
     , EN_GOLD_SPOT
     , EN_GURANTEESECFUT_BALANCE
     , EN_STOCK_ASSET_GGT
     , EN_STOCK_ASSET_NOGGT
     , EN_OUTFLOW_BALANCE_GGT
     , EN_BROKER_BALANCE
     , EN_BANK_BALANCE
     , EN_BANK_FROZEN_BALANCE
     , EN_ENERALHG_DEPOSIT
     , EN_IRS_DEPOSIT
     , EN_FINADEBT_ASSET
     , EN_FINADEBT_INTEREST
     , EN_FUT_REPORT_FEE
     , EN_IRS_FROZEN_DEPOSIT
     , EN_IRS_PRICE
     , EN_IRS_OFFSET_DEPOSIT
     , EN_EXERCISE_TEMP_DEPOSIT
     , EN_SECFUT_EXERCISE_DEPOSIT
     , EN_CMM_SECFUT_PREBUY_MARGIN
     , EN_DERIVATIVES_ASSET
     , EN_PRENETBUY_BALANCE
     , EN_FUND_ASSET_GGT
     , EN_FUND_ASSET_NOGGT
     , EN_FUTURE_INTEREST
     , EN_ONLY_T1_FROZEN_BALANCE
     , EN_RISK_SGT
     , EN_ASSET_JSSJJS_VALUE
     , EN_DF_BOND_ASSET_TOTAL
     , EN_DF_BOND_ASSET
     , EN_DX_BOND_ASSET_TOTAL
     , EN_DX_BOND_ASSET
     , EN_DEVALUE_VALUE
     , EN_BZJYE_RZ
     , EN_PREBUY_BALANCE_HGT
     , EN_PRESALE_BALANCE_HGT
     , EN_PREBUY_BALANCE_SGT
     , EN_PRESALE_BALANCE_SGT
     , EN_PREPAY_BALANCE_DIFF
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TASSETDAY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TASSETDAY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TASSETDAY_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TASSETDAY_PFD成功"
      exit 0
   fi
fi
