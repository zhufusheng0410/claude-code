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
-- ** 描    述:基金证券表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_AST_FUND_SCR_PFD         基金证券表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TFUNDSTOCK_PFD  基金证券表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD   账套编码映射
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD     证券编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP   标准码值字典映射表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD   证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_FUND_SCR_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS STAT_DATE                               --统计日期
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE)) 
       END                                                                           AS INV_TYPE_CODE                           --投资类型代码
     , CASE 
         WHEN T1.C_POSITION_FLAG IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_POSITION_FLAG)) 
       END                                                                           AS HLDP_TYPE_CODE                          --持仓类型代码
     , T1.VC_BIND_SEAT                                                               AS CSTD_SEAT                               --托管席位
     , T1.VC_STOCKHOLDER_ID                                                          AS HOLDER_CODE                             --股东代码
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T4.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T4.TRAN_CRRC_CODE                                                             AS CRRC_CODE                               --币种代码
     , T1.L_BEGIN_AMOUNT                                                             AS BEGIN_QTY                               --期初数量
     , T1.L_CURRENT_AMOUNT                                                           AS CURR_QTY                                --当前数量
     , T1.L_BUY_AMOUNT                                                               AS TDY_BUY_IN_QTY                          --当日买入数量
     , T1.EN_BUY_BALANCE                                                             AS TDY_BUY_IN_AMT                          --当日买入金额
     , T1.EN_BUY_FEE                                                                 AS TDY_BUY_IN_FEE                          --当日买入费用
     , T1.EN_REAL_BUY_FEE                                                            AS ACTL_TDY_BUY_IN_FEE                     --实际当日买入费用
     , T1.L_SALE_AMOUNT                                                              AS TDY_SELL_QTY                            --当日卖出数量
     , T1.EN_SALE_BALANCE                                                            AS TDY_SELL_AMT                            --当日卖出金额
     , T1.EN_SALE_FEE                                                                AS TDY_SELL_FEE                            --当日卖出费用
     , T1.EN_REAL_SALE_FEE                                                           AS ACTL_TDY_SELL_FEE                       --实际当日卖出费用
     , T1.L_PREBUY_AMOUNT                                                            AS TDY_PRE_BUY_QTY                         --当日预买数量
     , T1.L_PRESALE_AMOUNT                                                           AS TDY_PRE_SELL_QTY                        --当日预卖数量
     , T1.EN_TRADE_BALANCE                                                           AS BUY_SELL_CPTL_OCCP_AMT                  --买卖资金占用金额
     , T1.EN_TURN_INVEST                                                             AS BEGIN_ORI_COST                          --期初原始成本
     , T1.EN_UNTRANSFERED_INVEST                                                     AS BEGIN_COST                              --期初成本
     , T1.EN_INTEREST_INVEST                                                         AS BEGIN_BOND_INTR_COST                    --期初债券利息成本
     , T1.EN_TURN_INTEREST_INVEST                                                    AS CARRYOVER_BEF_INTR_COST                 --结转前利息成本
     , T1.EN_REAL_COST                                                               AS AFT_CO_WF_BEGIN_COST                    --结转后含费用期初成本
     , T1.EN_UNCARRYOVER_REAL_COST                                                   AS UN_CO_WF_COST                           --未结转含费用成本
     , T1.EN_CURRENT_COST                                                            AS CURR_COST                               --当前成本
     , T1.EN_INTEREST_PROFIT                                                         AS BOND_INTR_YIEL                          --债券利息收益
     , T1.EN_TURN_INTEREST_PROFIT                                                    AS CARRYOVER_BOND_INTR_YIEL                --结转债券利息收益
     , T1.EN_INTEREST_GAIN                                                           AS BOND_INTR_ACHIEV_YIEL                   --债券利息实现收益
     , T1.EN_TURN_INTEREST_GAIN                                                      AS CARRYOVER_BOND_INTR_ACHIEV_YIEL         --结转债券利息实现收益
     , T1.EN_NET_GAIN                                                                AS AFT_CO_WOF_TOTAL_YIEL                   --结转后扣费用累计收益
     , T1.EN_UNCARRYOVER_NET_GAIN                                                    AS UN_CO_WOF_BEGIN_YIEL                    --未结转扣费用期初收益
     , T1.EN_UNCARRYOVER_DIVIDEND                                                    AS UN_CO_BEGIN_TOTAL_BONUS_AMT             --未结转期初累计分红金额
     , T1.EN_DIVIDEND                                                                AS CARRYOVER_BEGIN_TOTAL_BONUS_AMT         --结转期初累计分红金额
     , T1.EN_UNCARRYOVER_TRADING_FEE                                                 AS UN_CO_AVL_TRAN_AST_TOT_FEE              --未结转可交易资产总费用
     , T1.EN_TRADING_FEE                                                             AS AFT_CO_AVL_TRAN_AST_TOT_FEE             --结转后可交易资产总费用
     , T1.EN_ACCUMULATE_PROFIT                                                       AS TOTAL_ACHIEV_YIEL                       --累计实现收益
     , T1.EN_TURN_PROFIT                                                             AS CARRYOVER_YIEL                          --结转收益
     , T1.EN_TODAY_PROFIT                                                            AS TDY_ACHIEV_YIEL                         --当日实现收益
     , T1.EN_BEGINYEAR_TURN_PROFIT                                                   AS BEGINYEAR_CARRYOVER_YIEL                --年初结转收益
     , T1.EN_BEGINYEAR_UNTURN_PROFIT                                                 AS BEGINYEAR_UN_CO_YIEL                    --年初未结转收益
     , T1.L_BUY_UNSETTLE_AMOUNT                                                      AS BUY_IN_UN_DELI_QTY                      --买入未交割数量
     , T1.EN_BUY_UNSETTLE_BALANCE                                                    AS BUY_IN_UN_DELI_AMT                      --买入未交割金额
     , T1.L_SALE_UNSETTLE_AMOUNT                                                     AS SELL_UN_DELI_QTY                        --卖出未交割数量
     , T1.EN_SALE_UNSETTLE_BALANCE                                                   AS SELL_UN_DELI_AMT                        --卖出未交割金额
     , T1.L_T1_PREBUY_AMOUNT                                                         AS AFT_1_TD_PRE_BUY_QTY                    --T+1日预买数量
     , T1.L_T1_PRESALE_AMOUNT                                                        AS AFT_1_TD_PRE_SELL_QTY                   --T+1日预卖数量
     , T1.L_ETF_APPLY_AMOUNT                                                         AS ETF_ALLOT_QTY                           --ETF申购数量
     , T1.L_ETF_REDEEM_AMOUNT                                                        AS ETF_REDEM_QTY                           --ETF赎回数量
     , T1.L_TODAY_ENTR_STT_AMOUNT                                                    AS TDY_ENTU_DELI_QTY                       --当日委托交割数量
     , T1.L_TOTAL_ENTR_STT_AMOUNT                                                    AS TOTAL_ENTU_DELI_QTY                     --累计委托交割数量
     , T1.L_TODAY_DEAL_STT_AMOUNT                                                    AS TDY_DEAL_DELI_QTY                       --当日成交交割数量
     , T1.L_TOTAL_DEAL_STT_AMOUNT                                                    AS TOTAL_DEAL_DELI_QTY                     --累计成交交割数量
     , T1.L_BUY_UNASSET_AMOUNT                                                       AS BUY_IN_AST_UN_CHG_QTY                   --买入资产未变化数量
     , T1.L_SALE_UNASSET_AMOUNT                                                      AS SELL_AST_UN_CHG_QTY                     --卖出资产未变化数量
     , T1.EN_TURN_INVEST_NEW                                                         AS NEW_ORI_BEGIN_COST                      --新原始期初成本
     , T1.EN_UNTRANSFERED_INVEST_NEW                                                 AS NEW_AFT_CO_BEGIN_COST                   --新结转后的期初成本
     , T1.EN_ACCUMULATE_PROFIT_NEW                                                   AS NEW_TOTAL_ACHIEV_YIEL                   --新累计实现收益
     , T1.EN_TURN_PROFIT_NEW                                                         AS NEW_AFT_CO_ACHIEV_YIEL                  --新结转后实现收益
     , T1.L_RESTRICTED_AMOUNT                                                        AS RESTR_SHARES_QTY                        --受限股数量
     , T1.EN_DISCOUNT_RATIO                                                          AS DISC_COEF                               --折扣系数
     , T1.L_BEGIN_ENABLE_DEDUCT_AMOUNT                                               AS BEGIN_AVL_DECT_QTY                      --期初可抵扣数量
     , T1.L_T0_ENABLE_DEDUCT_AMOUNT                                                  AS TDY_AVL_DECT_QTY                        --T+0可抵扣数量
     , T1.L_T1_SALE_AMOUNT                                                           AS AFT_1_TD_SELL_QTY                       --T+1卖出数量
     , T1.EN_CURRENT_IMPAWN_AMOUNT                                                   AS BEGIN_PLG_QTY                           --期初质押数量
     , T1.EN_PRE_IMPAWN_AMOUNT                                                       AS TDY_PRE_PLG_QTY                         --当日预质押数量
     , T1.EN_IMPAWN_AMOUNT                                                           AS TDY_PLG_QTY                             --当日质押数量
     , T1.EN_PRE_RETURN_AMOUNT                                                       AS TDY_PRE_TURN_BACK_QTY                   --当日预转回数量
     , T1.EN_RETURN_AMOUNT                                                           AS TDY_TURN_BACK_QTY                       --当日转回数量
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TFUNDSTOCK_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TFUNDSTOCK_PFD T1  --基金证券表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD --产品内码
   AND T2.SSYS = 'O32' --源系统
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD --证券内码
   AND T3.SSYS = 'O32' --源系统
   AND T3.ST_DATE <= '${p_end_dt}' --开始日期
   AND T3.END_DATE >= '${p_end_dt}' --结束日期
   AND T3.VALID_FLAG = '1' --有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T4 --证券基本信息
    ON T3.SCR_NUM = T4.SCR_NUM
   AND T4.VALID_FLAG = '1' --有效标志
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T6.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T6.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_INVEST_TYPE' --源字典分类
   AND T6.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_POSITION_FLAG = T7.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T7.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_POSITION_FLAG' --源字典分类
   AND T7.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT = '${p_end_dt}'
;


"
