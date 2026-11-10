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
-- ** 描    述:基金资产表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_AST_FUND_AST_PFD        基金资产表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TFUNDASSET_PFD 基金资产信息表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD  账套编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_FUND_AST_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS STAT_DATE                               --统计日期
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , CASE 
         WHEN T1.VC_CURRENCY_NO IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_CURRENCY_NO)) 
       END                                                                           AS CRRC_CODE                               --币种代码
     , T1.EN_BEGIN_CASH                                                              AS BEGIN_CPTL_BAL                          --期初资金余额
     , T1.EN_CURRENT_CASH                                                            AS CURR_CPTL_BAL                           --当前资金余额
     , T1.EN_BASIC_FROZEN_BALANCE                                                    AS EARN                                    --保证金
     , T1.EN_PREBUY_BALANCE                                                          AS TDY_PRE_BUY_IN_AMT                      --当日预买入金额
     , T1.EN_PRESALE_BALANCE                                                         AS TDY_PRE_SELL_AMT                        --当日预卖金额
     , T1.EN_BUY_BALANCE                                                             AS TDY_BUY_IN_AMT                          --当日买入金额
     , T1.EN_SALE_BALANCE                                                            AS TDY_SELL_AMT                            --当日卖出金额
     , T1.EN_BUY_UNSETTLE_BALANCE                                                    AS BUY_IN_UN_DELI_AMT                      --买入未交割金额
     , T1.EN_SALE_UNSETTLE_BALANCE                                                   AS SELL_UN_DELI_AMT                        --卖出未交割金额
     , T1.EN_OTHER_EXPENSE                                                           AS TOTAL_PAYB_AMT                          --合计应付金额
     , T1.EN_OTHER_PROFIT                                                            AS TOTAL_RECV_AMT                          --合计应收金额
     , T1.EN_INTEREST_BALANCE                                                        AS INTA_PST                                --计息头寸
     , T1.EN_STOCK_ASSET                                                             AS STK_AST                                 --股票资产
     , T1.EN_BOND_ASSET                                                              AS BOND_AST                                --债券资产
     , T1.EN_FUND_ASSET                                                              AS FUND_AST                                --基金资产
     , T1.EN_WARRANT_ASSET                                                           AS WRNT_AST                                --权证资产
     , T1.EN_HG_ASSET                                                                AS REPO_AST                                --回购资产
     , T1.EN_REC_SEC_ASSET                                                           AS OPT_AST                                 --期权资产
     , T1.EN_OTHER_ASSET                                                             AS OTHER_AST                               --其他资产
     , T1.EN_FUND_TOTAL_VALUE                                                        AS FUND_TOT_AST                            --基金总资产
     , T1.EN_ACCUMULATE_PROFIT                                                       AS TOTAL_ACHIEV_YIEL                       --累计实现收益
     , T1.EN_FUTURES_ASSET                                                           AS FUTR_PL                                 --期货盈亏
     , T1.EN_FUTURES_BALANCE                                                         AS FUTR_EARN_ACCT_BAL                      --期货保证金账户余额
     , T1.EN_FUTURES_DEPOSIT                                                         AS FUTR_EARN                               --期货保证金
     , T1.EN_FUTURES_PREPARE                                                         AS FUTR_LOW_RESV                           --期货最低准备金
     , T1.EN_FUND_SHARE                                                              AS FUND_TOT_SHARE                          --基金总份额
     , T1.EN_FUND_VALUE                                                              AS FUND_NET_AST                            --基金净资产
     , T1.EN_FUND_VALUE_YESTERDAY                                                    AS FUND_YEST_NET_AST                       --基金昨日净资产
     , T1.EN_EXCHANGED_IN_QUOTA                                                      AS BEGIN_NAV                               --期初净值
     , T1.EN_NAV                                                                     AS NET_VALUE                               --基金单位净值
     , T1.EN_NAV_YESTERDAY                                                           AS YEST_UNIT_NAV                           --昨日单位净值
     , T1.EN_TOTAL_NAV                                                               AS TOTAL_UNIT_NAV                          --累计单位净值
     , T1.EN_UNIT_DIVIDENDS                                                          AS UNIT_BONUS                              --单位分红
     , T1.EN_TOTAL_UNIT_DIVIDENDS                                                    AS TOTAL_UNIT_BONUS                        --累计单位分红
     , T1.EN_7DAYS_YIELD_RATE                                                        AS 7D_AROR                                 --7日年化收益率
     , T1.EN_10K_UNIT_YIELD                                                          AS PER_MICP_YIEL                           --每万份收益
     , T1.EN_DEPOSIT_BALANCE                                                         AS DPSI_BAL                                --存款余额
     , T1.EN_EXCHANGED_OUT_QUOTA                                                     AS HAS_TRANIN_FX                           --已换入外汇
     , T1.EN_TODAY_EXCHANGE_IN_QUOTA                                                 AS HAS_TRANOUT_FX                          --已换出外汇
     , T1.EN_TODAY_EXCHANGE_OUT_QUOTA                                                AS TDY_NEED_TRANIN_FX_AMT                  --当日需换入外汇金额
     , T1.EN_NEXT_EXCHANGE_OUT_QUOTA                                                 AS TDY_NEED_TRANOUT_FX_AMT                 --当日需换出外汇金额
     , T1.EN_BOND_INTEREST                                                           AS NEXT_DAY_NEED_TRANOUT_FX_AMT            --下一日需换出外汇金额
     , T1.EN_BEGIN_FUND_VALUE                                                        AS BOND_INTR                               --债券利息
     , T1.EN_PAYABLE_BOND_ASSET                                                      AS PAYB_BOND_AST                           --应付债券资产
     , T1.EN_T1_PREBUY_BALANCE                                                       AS AFT_1_TD_PRE_BUY_AMT                    --T+1日预买金额
     , T1.EN_T1_PRESALE_BALANCE                                                      AS AFT_1_TD_PRE_SELL_AMT                   --T+1日预卖金额
     , T1.EN_PAY_SEC_ASSET                                                           AS PAYB_SCR_AST                            --应付证券资产
     , T1.EN_OPTION_ASSET                                                            AS RECV_SCR_AST                            --应收证券资产
     , T1.EN_BUY_UNASSET_BALANCE                                                     AS BUY_IN_AST_UN_CHG_AMT                   --买入资产未变化金额
     , T1.EN_SALE_UNASSET_BALANCE                                                    AS SELL_AST_UN_CHG_AMT                     --卖出资产未变化金额
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
     , T1.VC_DIFF_DESCRIPTION                                                        AS DIFF_EXPL                               --差异说明
     , T1.D_LASTUPDATE                                                               AS REFRESH_TIME                            --刷新时间
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TFUNDASSET_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TFUNDASSET_PFD T1  --基金资产信息表
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
