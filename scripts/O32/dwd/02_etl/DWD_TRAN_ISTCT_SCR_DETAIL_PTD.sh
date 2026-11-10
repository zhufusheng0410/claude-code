#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "


-- **************************************************************************
-- ** 主题:交易
-- ** 描述:指令证券明细表
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-16
-- ** 修改日志:
-- ** 2023-05-16，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD      指令证券明细表
-- ** 源  表：ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD 指令证券表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD         账套编码映射
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD           证券编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP         标准码值字典映射表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP         标准字典码值映射
-- **         DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD          交易对手方编码映射
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD         证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_DAILY_INSTRUCTION_NO                                                     AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                       AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T1.L_STOCK_SERIAL_NO                                                          AS ISTCT_SCR_SERIALNO                      --指令证券序号
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T14.SYMBOL                                                                    AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN 
          COALESCE(T16.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS)) 
       END                                                                           AS BUSIN_CATG_CODE                         --业务分类代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION)) 
       END                                                                           AS ENTU_ORNT_CODE                          --委托方向代码
     , T1.C_ORIGINAL_DIRECTION                                                       AS ORI_ENTU_ORNT_CODE                      --原委托方向代码
     , CASE 
         WHEN T1.C_PRICE_TYPE IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PRICE_TYPE)) 
       END                                                                           AS PRC_MODE_CODE                           --价格模式代码
     , T1.C_AMOUNT_BALANCE_FLAG                                                      AS AMT_SCR_FLAG_CODE                       --金额证券标志代码
     , T1.C_RISK_INFLUENCE_FLAG                                                      AS RISK_INFLU_FLAG_CODE                    --风控影响标志代码
     , T1.C_FUND_BONUS_TYPE                                                          AS FUND_BONUS_MODE_CODE                    --基金分红方式代码
     , T1.C_CASH_CONTROL_TYPE                                                        AS PST_CTRL_MODE_CODE                      --头寸控制方式代码
     , T1.C_STOCK_CONTROL_TYPE                                                       AS SCR_CTRL_MODE_CODE                      --证券控制方式代码
     , T1.C_TRADE_TYPE                                                               AS TRAN_CATG_CODE                          --交易类别代码
     , T14.TRAN_CRRC_CODE                                                            AS CRRC_CODE                               --币种代码
     , T1.EN_PRICE1                                                                  AS ISTCT_PRC                               --指令价格
     , T1.L_AMOUNT                                                                   AS ISTCT_VOL                               --指令数量
     , T1.EN_BALANCE                                                                 AS ISTCT_AMT                               --指令金额
     , T1.EN_PRICE2                                                                  AS PRC_LOWL                                --价格下限
     , T1.EN_DAILY_MAX                                                               AS TDY_LMT_QTY                             --当日限量
     , T1.EN_EARNEST_BALANCE                                                         AS DPSIT_AMT                               --定金金额
     , T1.L_TODAY_ENTRUST_AMOUNT                                                     AS TDY_ENTU_VOL                            --当日委托数量
     , T1.EN_TODAY_ENTRUST_BALANCE                                                   AS TDY_ENTU_AMT                            --当日委托金额
     , CASE 
         WHEN T1.C_ENTRUST_EXECUTE_STATUS IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_EXECUTE_STATUS)) 
       END                                                                           AS ENTU_FNSH_STAT_CODE                     --委托完成状态代码
     , T1.L_TODAY_DEAL_AMOUNT                                                        AS TDY_DEAL_VOL                            --当日成交数量
     , T1.EN_TODAY_DEAL_BALANCE                                                      AS TDY_DEAL_AMT                            --当日成交金额
     , T1.D_DEAL_COMPLETE_DATE                                                       AS ISTCT_DEAL_FNSH_TIME                    --指令成交完成时间
     , CASE 
         WHEN T1.C_DEAL_EXECUTE_STATUS IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEAL_EXECUTE_STATUS))   
       END                                                                           AS DEAL_FNSH_STAT_CODE                     --成交完成状态代码
     , CASE 
         WHEN T1.C_INSTRUCTION_STATUS IS NOT NULL THEN 
          COALESCE(T15.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INSTRUCTION_STATUS))   
       END                                                                           AS ISTCT_STAT_CODE                         --指令状态代码 
     , CASE 
         WHEN  T1.C_INVEST_TYPE IS NOT NULL THEN 
         COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE))   
       END                                                                           AS INV_TYPE_CODE                           --投资类型代码
     , CASE 
         WHEN T1.C_YIELD_RATIO_TYPE IS NOT NULL THEN 
         COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_YIELD_RATIO_TYPE))    
       END                                                                           AS YLD_TYPE_CODE                           --收益率类型代码
     , T1.EN_PROFIT_RATIO                                                            AS YTM                                     --到期收益率
     , T1.EN_FACT_PRICE                                                              AS ACTL_PRC                                --实际价格
     , T1.EN_INTEREST                                                                AS HUD_BOND_ACCR_INTR                      --百元债券应计利息
     , T1.EN_FEE                                                                     AS CHAG                                    --手续费用
     , T1.L_TOTAL_ENTRUST_AMOUNT                                                     AS TOTAL_ENTU_VOL                          --累计委托数量
     , T1.EN_TOTAL_ENTRUST_BALANCE                                                   AS TOTAL_ENTU_AMT                          --累计委托金额
     , T1.L_TOTAL_DEAL_AMOUNT                                                        AS TOTAL_DEAL_VOL                          --累计成交数量
     , T1.EN_TOTAL_DEAL_BALANCE                                                      AS TOTAL_DEAL_AMT                          --累计成交金额
     , T1.EN_CUM_AVG_PRICE                                                           AS TOTAL_DEAL_APRC                         --累计成交均价
     , T1.EN_DAY_AVG_PRICE                                                           AS TDY_DEAL_APRC                           --当日成交均价
     , CASE 
         WHEN T1.L_SETTLE_SPEED IS NOT NULL THEN
           COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_SETTLE_SPEED))
       END                                                                           AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , T1.C_CLEAR_TYPE                                                               AS LIQUI_TYPE_CODE                         --清算类型代码
     , T1.C_CLEAR_MODE                                                               AS LIQUI_MODE_CODE                         --清算方式代码
     , T1.L_FIRST_SETTLE_DATE                                                        AS FST_DELI_DATE                           --首次交割日期
     , CASE 
         WHEN T1.C_FIRST_SETTLE_TYPE IS NOT NULL THEN 
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FIRST_SETTLE_TYPE))  
       END                                                                           AS INIT_SETL_MODE_CODE                     --首期结算方式代码
     , T1.L_SECOND_SETTLE_DATE                                                       AS DUE_DELI_DATE                           --到期交割日期
     , CASE 
         WHEN T1.C_SECOND_SETTLE_TYPE IS NOT NULL THEN
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SECOND_SETTLE_TYPE))  
       END                                                                           AS DUE_SETL_MODE_CODE                      --到期结算方式代码
     , T12.CNTP_NUM                                                                  AS CNTP_NUM                                --交易对手编码
     , T1.VC_RIVALTRADER_ID                                                          AS CNTP_DELR_ID                            --对手交易员id
     , T1.VC_RIVALTRADER_NAME                                                        AS CNTP_DELR_NAME                          --对手交易员姓名
     , T1.L_RIVALACCOUNT_NO                                                          AS CNTP_BANK_ACCT                          --对手银行账户
     , T1.VC_RIVAL_BANK_ACCOUNT                                                      AS CNTP_INBK_CSTD_ACCT                     --对手银行间托管帐号
     , T1.VC_RIVAL_SEAT                                                              AS CNTP_SEAT                               --对手席位
     , T1.VC_OTHER_INTER_CODE                                                        AS OTHS_SCR_INCD                           --对方证券内码
     , T1.L_OTHER_FUND_ID                                                            AS IN_FUND_SERIALNO                        --转入基金序号
     , T1.L_OTHER_COMBI_ID                                                           AS OTHER_COMB                              --其它组合
     , T1.C_OTHER_INVEST_TYPE                                                        AS OTHER_INV_TYPE_CODE                     --其它投资类型代码
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TINSTRUCTIONSTOCK_PTD'                                               AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD T1  --指令证券表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD--证券内码
   AND T3.SSYS = 'O32'--源系统
   AND T3.ST_DATE <= '${p_end_dt}'--开始日期
   AND T3.END_DATE >= '${p_end_dt}'--结束日期
   AND T3.VALID_FLAG = '1'--有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T4.SSYS = 'O32'--源系统简称
   AND T4.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'--源字典分类
   AND T1.C_ENTRUST_DIRECTION  = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.VALID_FLAG = 1--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T5.SSYS = 'O32'--源系统简称
   AND T5.SRC_DICT_CLS_CD = 'C_PRICE_TYPE'--源字典分类
   AND T1.C_PRICE_TYPE = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.VALID_FLAG = 1--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T6.SSYS = 'O32'--源系统简称
   AND T6.SRC_DICT_CLS_CD = 'C_ENTRUST_EXECUTE_STATUS'--源字典分类
   AND T1.C_ENTRUST_EXECUTE_STATUS = T6.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T6.VALID_FLAG = 1--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T7.SSYS = 'O32'--源系统简称
   AND T7.SRC_DICT_CLS_CD = 'C_DEAL_EXECUTE_STATUS'--源字典分类
   AND T1.C_DEAL_EXECUTE_STATUS = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.VALID_FLAG = 1--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T8.SSYS = 'O32'--源系统简称
   AND T8.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'--源字典分类
   AND T1.C_INVEST_TYPE = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.VALID_FLAG = 1--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T9.SSYS = 'O32'--源系统简称
   AND T9.SRC_DICT_CLS_CD = 'C_YIELD_RATIO_TYPE'--源字典分类
   AND T1.C_YIELD_RATIO_TYPE = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T10.SSYS = 'O32'--源系统简称
   AND T10.SRC_DICT_CLS_CD = 'C_FIRST_SETTLE_TYPE'--源字典分类
   AND T1.C_FIRST_SETTLE_TYPE = T10.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T11.SSYS = 'O32'--源系统简称
   AND T11.SRC_DICT_CLS_CD = 'C_SECOND_SETTLE_TYPE'--源字典分类
   AND T1.C_SECOND_SETTLE_TYPE = T11.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T11.VALID_FLAG = '1'--有效标志
 LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD T12 --交易对手方编码映射
    ON T1.L_TRADE_RIVAL_NO = T12.CNTP_NO
   AND T12.SSYS = 'O32'--源系统
   AND T12.ST_DATE <= '${p_end_dt}'--开始日期
   AND T12.END_DATE >= '${p_end_dt}'--结束日期
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准字典码值映射
    ON T13.SSYS = 'O32'
   AND T13.SRC_DICT_CLS_CD = 'L_SETTLE_SPEED'
   AND T1.L_SETTLE_SPEED = T13.SRC_DICT_CLS_CDVAL
   AND T13.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T14 --证券基本信息
    ON T3.SCR_NUM = T14.SCR_NUM --证券编码
   AND T14.VALID_FLAG = '1' 
   AND T14.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T15 --标准字典码值映射
    ON T15.SSYS = 'O32'
   AND T15.SRC_DICT_CLS_CD = 'C_INSTRUCTION_STATUS'
   AND T1.C_INSTRUCTION_STATUS = T15.SRC_DICT_CLS_CDVAL
   AND T15.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T16 --标准字典码值映射
    ON T16.SSYS = 'O32'
   AND T16.SRC_DICT_CLS_CD = 'C_BUSIN_CLASS'
   AND T1.C_BUSIN_CLASS = T16.SRC_DICT_CLS_CDVAL
   AND T16.VALID_FLAG = '1'
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
 ;"
