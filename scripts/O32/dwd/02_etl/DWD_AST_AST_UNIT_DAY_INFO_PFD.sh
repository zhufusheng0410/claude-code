#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:资产
-- ** 描    述:资产单元日信息表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_AST_AST_UNIT_DAY_INFO_PFD  资产单元日信息表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TASSETDAY_PFD     资产单元日信息表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD     账套编码映射
-- **         
-- **************************************************************************


set hive.strict.checks.type.safety=false;
    set mapred.max.split.size=256000000;
    set mapred.min.split.size.per.node=100000000;
    set mapred.min.split.size.per.rack=100000000;
    set hive.merge.mapredfiles=true;
    set hive.merge.mapfiles=true;
    set hive.merge.smallfiles.avgsize=16000000;
    set hive.merge.size.per.task=256000000;
    set hive.exec.reducers.bytes.per.reducer=10240000000; 
    set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_AST_UNIT_DAY_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS STAT_DATE                               --统计日期
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_ASSET_ID                                                                 AS AST_UNIT_SERIALNO                       --资产单元序号
     , CASE 
         WHEN T1.VC_CURRENCY_NO IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_CURRENCY_NO)) 
       END                                                                           AS CRRC_CODE                               --币种代码
     , T1.EN_BEGIN_CASH                                                              AS BEGIN_CPTL_BAL                          --期初资金余额
     , T1.EN_CURRENT_CASH                                                            AS CURR_CPTL_BAL                           --当前资金余额
     , T1.EN_FROZEN_BALANCE                                                          AS FRZ_AMT                                 --冻结金额
     , T1.EN_UNFROZEN_BALANCE                                                        AS UNFZ_AMT                                --解冻金额
     , T1.EN_BASIC_FROZEN_BALANCE                                                    AS EARN                                    --保证金
     , T1.EN_PREBUY_BALANCE                                                          AS TDY_PRE_BUY_AMT                         --当日预买金额
     , T1.EN_PRESALE_BALANCE                                                         AS TDY_PRE_SELL_AMT                        --当日预卖金额
     , T1.EN_BUY_BALANCE                                                             AS TDY_BUY_IN_AMT                          --当日买入金额
     , T1.EN_SALE_BALANCE                                                            AS TDY_SELL_AMT                            --当日卖出金额
     , T1.EN_TEMP_FROZEN_BALANCE                                                     AS TDY_TMP_FRZ_AMT                         --当日临时冻结金额
     , T1.EN_TEMP_UNFROZEN_BALANCE                                                   AS TDY_TMP_UNFZ_AMT                        --当日临时解冻金额
     , T1.EN_T1_TEMP_FROZEN_BALANCE                                                  AS AFT_1_TD_TMP_FRZ_AMT                    --T+1临时冻结金额
     , T1.EN_T1_FROZEN_BALANCE                                                       AS AFT_1_TD_FRZ_AMT                        --T+1冻结金额
     , T1.EN_BUY_UNSETTLE_BALANCE                                                    AS BUY_IN_UN_DELI_AMT                      --买入未交割金额
     , T1.EN_SALE_UNSETTLE_BALANCE                                                   AS SELL_UN_DELI_AMT                        --卖出未交割金额
     , T1.EN_STOCK_ASSET                                                             AS STK_AST                                 --股票资产
     , T1.EN_BOND_ASSET                                                              AS BOND_AST                                --债券资产
     , T1.EN_FUND_ASSET                                                              AS FUND_AST                                --基金资产
     , T1.EN_HG_ASSET                                                                AS REPO_AST                                --回购资产
     , T1.EN_WARRANT_ASSET                                                           AS WRNT_AST                                --权证资产
     , T1.EN_OPTION_ASSET                                                            AS OPT_AST                                 --期权资产
     , T1.EN_OTHER_ASSET                                                             AS OTHER_AST                               --其他资产
     , T1.EN_ASSET_TOTAL_VALUE                                                       AS AST_UNIT_TOT_AST                        --资产单元总资产
     , T1.EN_ACCUMULATE_PROFIT                                                       AS TOTAL_ACHIEV_YIEL                       --累计实现收益
     , T1.EN_RATIO                                                                   AS SPLIT_RATE                              --拆分比例
     , T1.EN_PAYABLE                                                                 AS TOTAL_PAYB                              --合计应付
     , T1.EN_RECEIVABLE                                                              AS TOTAL_RECV                              --合计应收
     , T1.EN_ASSET_SHARE                                                             AS SHARE                                   --份额
     , T1.EN_ASSET_SHARE_YESTERDAY                                                   AS YEST_SHARE                              --昨日份额
     , T1.EN_ASSET_VALUE                                                             AS NET_AST                                 --净资产
     , T1.EN_ASSET_VALUE_YESTERDAY                                                   AS YEST_NET_AST                            --昨日净资产
     , T1.EN_PAYIN_BALANCE                                                           AS TDY_INPUT_AMT                           --当日投入金额
     , T1.EN_PAYIN_TOTAL                                                             AS TOTAL_INPUT_AMT                         --累计投入金额
     , T1.EN_PAYOUT_BALANCE                                                          AS TDY_DRAW_AMT                            --当日支取金额
     , T1.EN_PAYOUT_TOTAL                                                            AS TOTAL_DRAW_AMT                          --累计支取金额
     , T1.EN_BEGIN_T0_ENABLE                                                         AS DAY_BEGIN_TDY_USE_AMT                   --日初T日可用金额
     , T1.EN_BEGIN_T1_ENABLE                                                         AS DAY_BEGIN_AFT_1_TD_USE_AMT              --日初T+1可用金额
     , T1.EN_FUTURES_BALANCE                                                         AS FUTR_EARN_ACCT_BAL                      --期货保证金账户余额
     , T1.EN_FUTURES_DEPOSIT                                                         AS FUTR_EARN                               --期货保证金
     , T1.EN_FUTURES_PREPARE                                                         AS FUTR_LOW_RESV                           --期货最低准备金
     , T1.EN_FUTURES_ASSET                                                           AS FUTR_PL                                 --期货盈亏
     , T1.EN_INTEREST_BALANCE                                                        AS INTR_ARRG                               --利息积数
     , T1.EN_TOTAL_YJ                                                                AS TOTAL_FARE                              --累计佣金
     , T1.L_BEGINCALC_DATE                                                           AS BEGIN_CALCT_DATE                        --起计日期
     , T1.EN_COMMISION_RATIO                                                         AS ACTL_INCM_FARE_RATE                     --实际收入的佣金比例
     , T1.EN_PRINCIPAL_ACCRUAL                                                       AS PRIN_ARRG                               --本金积数
     , T1.EN_DEPOSIT_BALANCE                                                         AS DPSI_BAL                                --存款余额
     , T1.EN_NAV                                                                     AS UNIT_NAV                                --单位净值
     , T1.EN_NAV_YESTERDAY                                                           AS YEST_UNIT_NAV                           --昨日单位净值
     , T1.EN_UNIT_DIVIDENDS                                                          AS UNIT_BONUS_AMT                          --单位分红金额
     , T1.EN_TOTAL_UNIT_DIVIDENDS                                                    AS TOTAL_UNIT_BONUS_AMT                    --累计单位分红金额
     , T1.EN_BOND_INTEREST                                                           AS BOND_INTR                               --债券利息
     , T1.EN_BEGIN_PROFIT_RATIO                                                      AS BEGIN_YIEL_RATE                         --期初收益比例
     , T1.EN_T1_PREBUY_BALANCE                                                       AS AFT_1_TD_PRE_BUY_AMT                    --T+1日预买金额
     , T1.EN_T1_PRESALE_BALANCE                                                      AS AFT_1_TD_PRE_SELL_AMT                   --T+1日预卖金额
     , T1.EN_SECACC_BONUS                                                            AS SHTS_ACCT_DIVD_AMT                      --融券账户红利金额
     , T1.EN_FUTURE_TEMP_BALANCE                                                     AS FUTR_TMP_FRZ_EARN                       --期货临时冻结保证金
     , T1.EN_TRUST_BALANCE                                                           AS CRDT_LMT                                --授信额度
     , T1.EN_REC_SEC_ASSET                                                           AS RECV_SCR_AST                            --应收证券资产
     , T1.EN_PAY_SEC_ASSET                                                           AS PAYB_SCR_AST                            --应付证券资产
     , T1.EN_FUTURES_SETTLE_DEPOSIT                                                  AS FUTR_DELI_EARN_OCCP_AMT                 --期货交割保证金占用金额
     , T1.EN_PREIPO_DEPOSIT                                                          AS PRE_SUE_HAS_COLL_EARN                   --预发行已收取保证金
     , T1.L_FIRST_PAYIN_DATE                                                         AS INIT_INPUT_DATE                         --初始投入日期
     , T1.EN_PRINCIPAL_DAILY                                                         AS DAILY_PRIN                              --日均本金
     , T1.EN_BUY_UNASSET_BALANCE                                                     AS BUY_IN_AST_UN_CHG_AMT                   --买入资产未变化金额
     , T1.EN_SALE_UNASSET_BALANCE                                                    AS SELL_AST_UN_CHG_AMT                     --卖出资产未变化金额
     , T1.EN_FUTURE_FROZEN_BALANCE                                                   AS FUTR_EARN_FRZ_AMT                       --期货保证金冻结金额
     , T1.EN_T2_FROZEN_BALANCE                                                       AS SHSC_AFT_2_TD_FRZ_AMT                   --沪港通T+2冻结金额
     , T1.EN_T2_TEMP_FROZEN_BALANCE                                                  AS SHSC_AFT_2_TD_TMP_FRZ_AMT               --沪港通T+2临时冻结金额
     , T1.EN_OTC_FRZN_BALANCE                                                        AS OTC_FRZ_AMT                             --场外冻结金额
     , T1.EN_OTC_UNFRZN_BALANCE                                                      AS OTC_UNFZ_AMT                            --场外解冻金额
     , T1.EN_T1OTC_FRZN_BALANCE                                                      AS AFT_1_TD_OTC_FRZ_AMT                    --T+1场外冻结金额
     , T1.EN_BUY_BALANCE_HGT                                                         AS SHSC_BUY_IN_AMT                         --沪港通买入金额
     , T1.EN_SALE_BALANCE_HGT                                                        AS SHSC_SELL_AMT                           --沪港通卖出金额
     , T1.EN_BUY_BALANCE_SGT                                                         AS SZSC_BUY_IN_AMT                         --深港通买入金额
     , T1.EN_SALE_BALANCE_SGT                                                        AS SZSC_SELL_AMT                           --深港通卖出金额
     , T1.EN_T2_FROZEN_BALANCE_SGT                                                   AS SZSC_AFT_2_TD_FRZ_AMT                   --深港通T+2冻结金额
     , T1.EN_T2_TEMP_FROZEN_BALANCE_SGT                                              AS SZSC_AFT_2_TD_TMP_FRZ_AMT               --深港通T+2临时冻结金额
     , T1.EN_CHANGE_BALANCE_JYS                                                      AS EXCH_AFT_2_TD_CHG_AMT                   --交易所T+2变化金额
     , T1.EN_CHANGE_BALANCE_YHJ                                                      AS INBK_AFT_2_TD_CHG_AMT                   --银行间T+2变化金额
     , T1.EN_RISK_GGT                                                                AS HK_SHARES_RISK_CPTL                     --港股风险资金
     , T1.EN_CMM_PREBUY_MARGIN                                                       AS ABTRG_PRE_BUY_EARN_OCCP_AMT             --套利单预买保证金占用金额
     , T1.EN_T1CHANGE_BALANCE_GGT                                                    AS HKSC_TDY_AND_AFT_1_TD_TRAN_CPTL_NETT    --港股通T和T1交易资金轧差
     , T1.EN_ACCUMULATE_PROFIT_GQ                                                    AS EXP_TOTAL_ACHIEV_YIEL                   --过期累计实现收益
     , T1.EN_TURN_PROFIT_GQ                                                          AS EXP_UN_CO_YIEL                          --过期未结转收益
     , T1.EN_NET_GAIN_GQ                                                             AS EXP_AFT_CO_WOF_TOTAL_YIEL               --过期结转后扣费用累计收益
     , T1.EN_UNCARRYOVER_NET_GAIN_GQ                                                 AS EXP_UN_CO_WOF_BEGIN_YIEL                --过期未结转扣费用期初收益
     , T1.EN_INTEREST_PROFIT_GQ                                                      AS EXP_BOND_INTR_YIEL                      --过期债券利息收益
     , T1.EN_TURN_INTEREST_PROFIT_GQ                                                 AS EXP_CARRYOVER_BOND_INTR_YIEL            --过期结转债券利息收益
     , T1.EN_INTEREST_GAIN_GQ                                                        AS EXP_BOND_INTR_ACHIEV_YIEL               --过期债券利息实现收益
     , T1.EN_TURN_INTEREST_GAIN_GQ                                                   AS EXP_CARRYOVER_BOND_INTR_ACHIEV_YIEL     --过期结转债券利息实现收益
     , T1.EN_BEGINYEAR_TURN_PROFIT_GQ                                                AS EXP_BEGINYEAR_CARRYOVER_YIEL            --过期年初结转收益
     , T1.EN_BEGINYEAR_UNTURN_PROFIT_GQ                                              AS EXP_BEGINYEAR_UN_CO_YIEL                --过期年初未结转收益
     , T1.D_LASTUPDATE                                                               AS LST_UPDTIME                             --上次更新时间
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TASSETDAY_PFD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TASSETDAY_PFD T1  --资产单元日信息表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD --产品内码
   AND T2.SSYS = 'O32' --源系统
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T1.VC_CURRENCY_NO = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T3.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T3.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
   AND T3.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT = '${p_end_dt}'

;

"
