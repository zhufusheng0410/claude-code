#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主   题:交易
-- ** 描   述:场外业务确认表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD  场外业务确认表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TOUTCONFIRM_PTD 场外业务确认
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD   账套编码映射
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD     证券编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP   标准码值字典映射表
-- **           DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD    交易对手方编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_CONFIRM_NO                                                               AS CNFM_NO                                 --确认编号
     , T1.L_DAILY_INSTRUCTION_NO                                                     AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                       AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T1.L_STOCK_SERIAL_NO                                                          AS ISTCT_CNFM_SERIALNO                     --指令确认序号
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T19.SYMBOL                                                                    AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T1.VC_STOCKHOLDER_ID                                                          AS HOLDER_CODE                             --股东代码
     , T1.VC_SEAT_ID                                                                 AS REP_SEAT                                --申报席位
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS)) 
       END                                                                           AS BUSIN_CATG_CODE                         --业务分类代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION)) 
       END                                                                           AS ENTU_ORNT_CODE                          --委托方向代码
     , T1.L_BUSIN_FLAG                                                               AS ENTU_ORNT_SUBCLAS                       --委托方向细类
     , CASE 
         WHEN T1.C_BUSIN_PRO_TYPE IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_PRO_TYPE)) 
       END                                                                           AS BUSIN_PROCE_CATG_CODE                   --业务过程分类代码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE)) 
       END                                                                           AS INV_TYPE_CODE                           --投资类型代码
     , CASE 
         WHEN T1.C_MARKET_NO IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO)) 
       END                                                                           AS MKT_CODE                                --市场代码
     , CASE 
         WHEN T1.C_CHANNEL_NO IS NOT NULL THEN 
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CHANNEL_NO)) 
       END                                                                           AS CHANNEL_CODE                            --通道代码
     , CASE 
         WHEN T1.C_DEAL_STATUS IS NOT NULL THEN 
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEAL_STATUS)) 
       END                                                                           AS DEAL_STAT_CODE                          --成交状态代码
     , CASE 
         WHEN T1.C_STATUS IS NOT NULL THEN 
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS)) 
       END                                                                           AS STAT_CODE                               --状态代码
     , CASE 
         WHEN T1.C_SETTLE_TYPE IS NOT NULL THEN 
          COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SETTLE_TYPE)) 
       END                                                                           AS SETL_MODE_CODE                          --结算方式代码
     , CASE 
         WHEN T1.C_ENTRUST_STATUS IS NOT NULL THEN 
          COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_STATUS)) 
       END                                                                           AS ENTU_STAT_CODE                          --委托状态代码
     , CASE 
         WHEN T1.C_EXCEED_FLAG IS NOT NULL THEN 
          COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_EXCEED_FLAG)) 
       END                                                                           AS VAST_REDEM_DEAL_FLAG_CODE               --巨额赎回处理标志代码
     , CASE 
         WHEN T1.C_FEE_DEAL_TYPE IS NOT NULL THEN 
          COALESCE(T15.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FEE_DEAL_TYPE)) 
       END                                                                           AS CHAG_DEAL_MODE_CODE                     --手续费处理方式代码
     , CASE 
         WHEN T1.C_CANCEL_STATUS IS NOT NULL THEN 
          COALESCE(T16.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CANCEL_STATUS)) 
       END                                                                           AS WHDW_STAT_CODE                          --撤销状态代码
     , T1.EN_BALANCE                                                                 AS AMT                                     --金额
     , T1.EN_CBALANCE                                                                AS DPSIT_AMT                               --定金金额
     , T1.EN_AMOUNT                                                                  AS QTY                                     --数量
     , T1.EN_PRICE                                                                   AS PRC                                     --价格
     , T1.EN_FEE_RATIO                                                               AS FEER                                    --费率
     , T1.EN_FEE                                                                     AS FEE                                     --费用
     , T1.EN_INTEREST                                                                AS INTR                                    --利息
     , T1.EN_COMMISSION                                                              AS FARE                                    --佣金
     , T1.L_DIRECT_DATE                                                              AS ISTCT_RELE_DATE                         --指令下达日期
     , T1.L_DEAL_DATE                                                                AS DEAL_DATE                               --成交日期
     , T1.L_CONFIRM_DATE                                                             AS CNFM_DATE                               --确认日期
     , T1.L_SETTLE_DATE                                                              AS ARVD_DATE                               --到账日期
     , T1.L_FA_CONFIRM_DATE                                                          AS FIN_ARVD_DATE                           --财务到账日期
     , T1.VC_IN_INTERCODE                                                            AS IN_SYMBOL                               --转入证券代码
     , T1.L_IN_COMBI_ID                                                              AS IN_COMB_SERIALNO                        --转入组合序号
     , T1.VC_IN_STOCKHOLDER_ID                                                       AS IN_HOLDER_CODE                          --转入股东代码
     , T1.VC_IN_SEAT_ID                                                              AS IN_SEAT_CODE                            --转入席位代码
     , CASE 
         WHEN T1.C_IN_INVEST_TYPE IS NOT NULL THEN 
          COALESCE(T17.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_IN_INVEST_TYPE)) 
       END                                                                           AS IN_INV_TYPE_CODE                        --转入投资类型代码
     , T1.VC_MINOR_BANK                                                              AS DPSI_BRH_BANK_NAME                      --存款分支银行名称
     , T1.VC_ACCOUNT_NO                                                              AS DPSI_ACCT_NO                            --存款账户编号
     , T1.VC_ACCOUNT_NAME                                                            AS DPSI_ACCT_NAME                          --存款账户名称
     , T1.L_OLD_CONFIRM_NO                                                           AS ORI_DEPO_RECE_CNFM_NO                   --原存单确认号
     , T1.L_OLD_DEPOSIT_CONFIRM_NO                                                   AS ORI_DEPO_RECE_SERIALNO                  --原存单序号
     , T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , T18.CNTP_NUM                                                                  AS CNTP_NUM                                --交易对手编码
     , T1.VC_RIVALTRADER_ID                                                          AS CNTP_DELR_ID                            --对手交易员id
     , T1.L_RIVALACCOUNT_NO                                                          AS CUTP_BANK_ACCT_SERIALNO                 --对手方银行账户序号
     , T1.VC_RIVALTRADER_NAME                                                        AS CUTP_DELR_CN_NAME                       --对手方交易员中文名称
     , T1.VC_RIVAL_BANK_ACCOUNT                                                      AS CNTP_INBK_CSTD_ACCT                     --对手银行间托管帐号
     , T1.L_EXECCONFIRM_NO                                                           AS EXEC_CNFM_NO                            --执行确认编号
     , T1.L_TIME                                                                     AS CNFM_TIME                               --确认时间
     , T1.D_DATETIME                                                                 AS TIME_STAMP                              --时间戳
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TOUTCONFIRM_PTD'                                                     AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TOUTCONFIRM_PTD T1  --场外业务确认
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD--证券内码
   AND T3.SSYS = 'O32'--源系统
   AND T3.ST_DATE <= '${p_end_dt}'--开始日期
   AND T3.END_DATE >= '${p_end_dt}'--结束日期
   AND T3.VALID_FLAG = '1'--有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) 
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.C_BUSIN_CLASS = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'C_BUSIN_CLASS'--源字典分类
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_ENTRUST_DIRECTION  = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_BUSIN_PRO_TYPE = T6.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T6.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_OTC_BUSIN_PRO_TYPE'--源字典分类
   AND T6.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'--源字典分类
   AND T7.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_MARKET_NO = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'C_MARKET_NO'--源字典分类
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_CHANNEL_NO = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T9.SRC_DICT_CLS_CD = 'C_CHANNEL_NO'--源字典分类
   AND T9.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.C_DEAL_STATUS = T10.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T10.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T10.SRC_DICT_CLS_CD = 'C_OTC_DEAL_STATUS'--源字典分类
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T1.C_STATUS = T11.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T11.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T11.SRC_DICT_CLS_CD = 'C_OTC_STATUS'--源字典分类
   AND T11.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准码值字典映射表
    ON T1.C_SETTLE_TYPE = T12.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T12.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T12.SRC_DICT_CLS_CD = 'C_OTC_SETTLE_TYPE'--源字典分类
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准码值字典映射表
    ON T1.C_ENTRUST_STATUS = T13.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T13.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T13.SRC_DICT_CLS_CD = 'C_ENTRUST_STATUS'--源字典分类
   AND T13.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准码值字典映射表
    ON T1.C_EXCEED_FLAG = T14.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T14.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T14.SRC_DICT_CLS_CD = 'C_EXCEED_FLAG'--源字典分类
   AND T14.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T15 --标准码值字典映射表
    ON T1.C_FEE_DEAL_TYPE = T15.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T15.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T15.SRC_DICT_CLS_CD = 'C_FEE_DEAL_TYPE'--源字典分类
   AND T15.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T16 --标准码值字典映射表
    ON T1.C_CANCEL_STATUS = T16.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T16.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T16.SRC_DICT_CLS_CD = 'C_CANCEL_STATUS'--源字典分类
   AND T16.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T17 --标准码值字典映射表
    ON T1.C_IN_INVEST_TYPE = T17.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T17.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T17.SRC_DICT_CLS_CD = 'C_IN_INVEST_TYPE'--源字典分类
   AND T17.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD T18 --交易对手方编码映射
    ON T1.L_RIVAL_ID = T18.CNTP_NO
   AND T18.SSYS = 'O32'--源系统
   AND T18.ST_DATE <= '${p_end_dt}'--开始日期
   AND T18.END_DATE >= '${p_end_dt}'--结束日期
   AND T18.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T19 --证券基本信息
    ON T3.SCR_NUM = T19.SCR_NUM--证券编码
   AND T19.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
   AND T19.VALID_FLAG = '1' 
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;

"
