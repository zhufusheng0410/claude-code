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
-- ** 描述:银行间成交回报表
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-17
-- ** 修改日志:
-- ** 2023-05-17，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_INBK_DEAL_REPLY_APPLY_PTD  银行间成交回报表
-- ** 源表：  ODS_XDAY_O32.ODS_O32_TBANKREALDEAL_PTD      银行间成交回报
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD          账套编码映射
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD            证券编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP          标准字典码值映射
-- **         DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD           交易对手方编码映射
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD          证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_INBK_DEAL_REPLY_APPLY_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                       AS DEAL_DATE                               --成交日期
     , T1.L_SERIAL_NO                                                                  AS DEAL_SERIALNO                           --成交序号
     , T1.VC_DEAL_NO                                                                   AS DEAL_NO                                 --成交编号
     , T1.L_DAILY_INSTRUCTION_NO                                                       AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                         AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T1.L_STOCK_SERIAL_NO                                                            AS ISTCT_SCR_SERIALNO                      --指令证券序号
     , T1.L_ENTRUST_SERIAL_NO                                                          AS ENTU_SERIALNO                           --委托序号
     , T2.SFAC_NUM                                                                     AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                    AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                               AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                      AS SCR_NUM                                 --证券编码
     , T14.SYMBOL                                                                      AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                                AS SCR_INCD                                --证券内码
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS))
       END                                                                             AS BUSIN_CATG_CODE                         --业务分类代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION))
       END                                                                             AS ENTU_ORNT_CODE                          --委托方向代码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE))
       END                                                                             AS INV_TYPE_CODE                           --投资类型代码
     , CASE 
         WHEN T1.L_SETTLE_SPEED IS NOT NULL THEN
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_SETTLE_SPEED))
       END                                                                             AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , CASE 
         WHEN T1.C_CLEAR_TYPE IS NOT NULL THEN
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CLEAR_TYPE))
       END                                                                             AS LIQUI_TYPE_CODE                         --清算类型代码
     , T14.TRAN_CRRC_CODE                                                              AS CRRC_CODE                               --币种代码
     , CASE 
         WHEN T1.C_STATUS IS NOT NULL THEN
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS))
       END                                                                             AS STAT_CODE                               --状态代码
     , T1.C_CANCEL_FLAG                                                                AS WHDW_FLAG                               --撤单标志
     , T1.EN_BALANCE                                                                   AS PAR_GAMT                                --券面总额
     , T1.EN_FIRST_NET_PRICE                                                           AS FST_TRAN_NETPRC_PRC                     --首次交易净价价格
     , T1.EN_FIRST_SETTLE_INTEREST                                                     AS FST_DELI_DAY_HUD_BOND_INTR              --首次交割日百元债券利息
     , T1.EN_FIRST_FULL_PRICE                                                          AS FST_TRAN_FULL_PRC_PRC                   --首次交易全价价格
     , T1.EN_FIRST_CLEAR_BALANCE                                                       AS FST_CPTL_LIQUI_AMT                      --首次资金清算额
     , T1.EN_FIRST_MATURE_YIELD                                                        AS FST_YLD                                 --首次收益率
     , T1.L_FIRST_SETTLE_DATE                                                          AS FST_DELI_DATE                           --首次交割日期
     , CASE 
         WHEN T1.C_FIRST_SETTLE_TYPE IS NOT NULL THEN
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FIRST_SETTLE_TYPE))
       END                                                                             AS FST_DELI_MODE_CODE                      --首次交割方式代码
     , T1.EN_MATURE_NET_PRICE                                                          AS DUE_TRAN_NETPRC_PRC                     --到期交易净价价格
     , T1.EN_MATURE_SETTLE_INTEREST                                                    AS DUE_DELI_DAY_HUD_BOND_INTR              --到期交割日百元债券利息
     , T1.EN_SECOND_CLEAR_BALANCE                                                      AS DUE_CPTL_LIQUI_AMT                      --到期资金清算额
     , T1.EN_SECOND_MATURE_YIELD                                                       AS YTM                                     --到期收益率
     , T1.L_SECOND_SETTLE_DATE                                                         AS DUE_DELI_DATE                           --到期交割日期
     , CASE 
         WHEN T1.C_SECOND_SETTLE_TYPE IS NOT NULL THEN
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SECOND_SETTLE_TYPE))
       END                                                                             AS DUE_DELI_MODE_CODE                      --到期交割方式代码
     , T1.EN_RATE                                                                      AS REPO_IR                                 --回购利率
     , T1.L_HG_DAYS                                                                    AS REPO_DAYS                               --回购天数
     , T1.L_USE_DAYS                                                                   AS ACTL_FUTK_DAYS                          --实际占款天数
     , T1.L_DEAL_AMOUNT                                                                AS DEAL_VOL                                --成交数量
     , T1.EN_DEAL_BALANCE                                                              AS DEAL_AMT                                --成交金额
     , T1.L_TIME                                                                       AS DEAL_TIME                               --成交时间
     , T1.EN_FEE                                                                       AS FEE                                     --费用
     , T1.EN_FEE_JS2                                                                   AS SETL_FEE                                --结算费
     , T1.EN_FEE_JG                                                                    AS DELIFEE                                 --交割费
     , T1.L_OPERATOR_NO                                                                AS OPER_CODE                               --操作员代码
     , T1.VC_SELFTRADER_NAME                                                           AS ICBC_DELR_NAME                          --本方交易员名称
     , T13.CNTP_NUM                                                                    AS CNTP_NUM                                --交易对手编码
     , T1.L_BANK_ID                                                                    AS INBK_ID                                 --银行间ID
     , T1.L_RIVALBANK_ID                                                               AS CUTP_INBK_ID                            --对手方银行间ID
     , T1.VC_RIVALTRADER_ID                                                            AS CNTP_DELR_ID                            --对手交易员ID
     , T1.VC_SELFTRADER_NAME                                                           AS CUTP_DELR_CN_NAME                       --对手方交易员中文名称
     , T1.L_RIVALACCOUNT_NO                                                            AS CUTP_BANK_ACCT_SERIALNO                 --对手方银行账户序号
     , T1.L_INSTR_DATE                                                                 AS SETL_ISTCT_DATE                         --结算指令日期
     , T1.VC_INSTRID                                                                   AS SETL_ISTCT_SERIALNO                     --结算指令序号
     , T1.VC_ORIGINAL_DEAL_NO                                                          AS ORI_DEAL_NO                             --原成交编号
     , T1.C_LOCK_FLAG                                                                  AS LOCK_FLAG                               --锁定标志
     , CASE 
         WHEN T1.C_SOURCE IS NOT NULL THEN
          COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SOURCE))
       END                                                                             AS DATA_SRC_CODE                           --数据来源代码
     , 'O32'                                                                           AS SSYS                                    --源系统
     , 'ODS_O32_TBANKREALDEAL_PTD'                                                     AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TBANKREALDEAL_PTD T1  --银行间成交回报
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD--产品内码
   AND T3.SSYS = 'O32'--源系统
   AND T3.ST_DATE <= '${p_end_dt}'--开始日期
   AND T3.END_DATE >= '${p_end_dt}'--结束日期
   AND T3.VALID_FLAG = '1'--有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'O32'
   AND T4.SRC_DICT_CLS_CD = 'C_BUSIN_CLASS'
   AND T1.C_BUSIN_CLASS = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'O32'
   AND T5.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'
   AND T1.C_ENTRUST_DIRECTION = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'O32'
   AND T6.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'
   AND T1.C_INVEST_TYPE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'O32'
   AND T7.SRC_DICT_CLS_CD = 'L_SETTLE_SPEED'
   AND T1.L_SETTLE_SPEED = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'O32'
   AND T8.SRC_DICT_CLS_CD = 'C_CLEAR_TYPE'
   AND T1.C_CLEAR_TYPE = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
    ON T9.SSYS = 'O32'
   AND T9.SRC_DICT_CLS_CD = 'C_RETURN_DATA_DEAL_STATUS'
   AND T1.C_STATUS = T9.SRC_DICT_CLS_CDVAL
   AND T9.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准字典码值映射
    ON T10.SSYS = 'O32'
   AND T10.SRC_DICT_CLS_CD = 'C_FIRST_SETTLE_TYPE'
   AND T1.C_FIRST_SETTLE_TYPE = T10.SRC_DICT_CLS_CDVAL
   AND T10.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准字典码值映射
    ON T11.SSYS = 'O32'
   AND T11.SRC_DICT_CLS_CD = 'C_SECOND_SETTLE_TYPE'
   AND T1.C_SECOND_SETTLE_TYPE = T11.SRC_DICT_CLS_CDVAL
   AND T11.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准字典码值映射
    ON T12.SSYS = 'O32'
   AND T12.SRC_DICT_CLS_CD = 'C_DEAL_DATA_SOURCE'
   AND T1.C_SOURCE = T12.SRC_DICT_CLS_CDVAL
   AND T12.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD T13 --交易对手方编码映射
    ON T1.L_TRADE_RIVAL_NO = T13.CNTP_NO
   AND T13.SSYS = 'O32'--源系统
   AND T13.ST_DATE <= '${p_end_dt}'--开始日期
   AND T13.END_DATE >= '${p_end_dt}'--结束日期
   AND T13.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T14 --证券基本信息
    ON T3.SCR_NUM = T14.SCR_NUM --证券编码
   AND T14.VALID_FLAG = '1' 
   AND T14.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;"
