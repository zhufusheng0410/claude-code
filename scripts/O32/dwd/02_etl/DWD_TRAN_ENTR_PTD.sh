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
-- ** 描述:委托表
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-12
-- ** 修改日志:
-- ** 2023-05-17，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_ENTR_PTD              委托表
-- ** 源  表：ODS_XDAY_O32.ODS_O32_TENTRUSTS_PTD     委托表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD     账套编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP     标准码值字典映射表
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD       证券编码映射
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD     证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_ENTR_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                       AS BUSIN_DATE                              --业务日期
     , T1.L_ENTRUST_SERIAL_NO                                                          AS ENTU_SERIALNO                           --委托序号
     , T1.L_BATCH_SERIAL_NO                                                            AS ENTU_BAT_NO                             --委托批号
     , T1.L_DAILY_INSTRUCTION_NO                                                       AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                         AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T1.L_AUTOTRADE_NO                                                               AS AUTO_TRAN_SERIALNO                      --自动交易序号
     , T2.SFAC_NUM                                                                     AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                    AS PROD_INCD                               --产品内码
     , T1.L_ASSET_ID                                                                   AS AST_UNIT_SERIALNO                       --资产单元序号
     , T1.L_BASECOMBI_ID                                                               AS PORTF_SERIALNO                          --投资组合序号
     , CASE 
         WHEN T1.C_MARKET_NO IS NOT NULL THEN
          COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO))
       END                                                                             AS TRAN_MKT_CODE                           --交易市场代码
     , T3.SCR_NUM                                                                      AS SCR_NUM                                 --证券编码
     , T16.SYMBOL                                                                      AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                                AS SCR_INCD                                --证券内码
     , CASE 
         WHEN T1.C_ASSET_TYPE IS NOT NULL THEN
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ASSET_TYPE))
       END                                                                             AS AST_CATG_CODE                           --资产类别代码
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS))
       END                                                                             AS BUSIN_CATG_CODE                         --业务分类代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION))
       END                                                                             AS ENTU_ORNT_CODE                          --委托方向代码
     , CASE 
         WHEN T1.C_STOCK_DIRECTION IS NOT NULL THEN
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STOCK_DIRECTION))
       END                                                                             AS SCR_ORNT_CODE                           --证券方向代码
     , CASE 
         WHEN T1.C_FUND_DIRECTION IS NOT NULL THEN
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUND_DIRECTION))
       END                                                                             AS CPTL_ORNT_CODE                          --资金方向代码
     , CASE 
         WHEN T1.C_ENTRUST_STATUS IS NOT NULL THEN
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_STATUS))
       END                                                                             AS ENTU_STAT_CODE                          --委托状态代码
     , CASE 
         WHEN T1.C_LAUNCH_FLAG IS NOT NULL THEN
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_LAUNCH_FLAG))
       END                                                                             AS ENTU_MODE_CODE                          --委托方式代码
     , CASE 
         WHEN T1.C_LAUNCH_FLAG = '7' THEN 
          '01'
         WHEN T1.C_LAUNCH_FLAG = 'V' THEN 
          '03'
         ELSE 
          '02'
       END                                                                             AS ENTU_TYPE_CODE                          --委托类型代码
     , CASE 
         WHEN T1.EN_ENTRUST_PRICE > 0 THEN 
          '01' -- 限价
         ELSE 
          '02' -- 市价
       END                                                                             AS ENTU_PRC_TYPE_CODE                      --委托价格类型代码
     , CASE 
         WHEN T1.C_FROZEN_TYPE IS NOT NULL AND LENGTH(T1.C_FROZEN_TYPE) <> 0 THEN
          COALESCE(T15.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FROZEN_TYPE))
       END                                                                             AS ENTU_FRZ_MODE_CODE                      --委托冻结方式代码
     , T16.TRAN_CRRC_CODE                                                              AS CRRC_CODE                               --币种代码
     , T1.EN_ENTRUST_PRICE                                                             AS ENTU_PRC                                --委托价格
     , T1.EN_FACT_PRICE                                                                AS ACTL_PRC                                --实际价格
     , T1.L_ENTRUST_AMOUNT                                                             AS ENTU_VOL                                --委托数量
     , T1.EN_BALANCE                                                                   AS ENTU_AMT                                --委托金额
     , T1.L_DIRECT_DATE                                                                AS ENTU_RELE_DATE                          --委托下达日期
     , T1.L_ENTRUST_TIME                                                               AS ENTU_TIME                               --委托时间
     , CASE 
         WHEN T1.C_DMA IS NOT NULL THEN
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DMA))
       END                                                                             AS ENTU_DEAL_MODE_CODE                     --委托处理方式代码
     , CASE 
         WHEN T1.VC_VALID_TYPE IS NOT NULL AND LENGTH(T1.C_FROZEN_TYPE) <> 0 THEN
          COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_VALID_TYPE))
       END                                                                             AS ENTU_VALID_TYPE_CODE                    --委托有效类型代码
     , T1.L_VALID_DATE                                                                 AS ENTU_VALID_DATE                         --委托有效日期
     , T1.L_MARKET_VALID_DATE                                                          AS BUSIN_END_DATE                          --业务截止日期
     , T1.VC_STOCKHOLDER_ID                                                            AS HOLDER_CODE                             --股东代码
     , T1.VC_REPORT_SEAT                                                               AS REP_SEAT                                --申报席位
     , T1.L_REPORT_SERIAL_NO                                                           AS REP_NO                                  --申报编号
     , T1.VC_REPORT_DIRECTION                                                          AS REP_ORNT_CODE                           --申报方向代码
     , T1.L_REPORT_TIME                                                                AS REP_TIME                                --申报时间
     , T1.L_FIRST_BUSIN_TIME                                                           AS FST_DEAL_TIME                           --首成交时间
     , T1.L_BUSIN_AMOUNT                                                               AS TDY_DEAL_VOL                            --当日成交数量
     , T1.EN_BUSIN_BALANCE                                                             AS TDY_DEAL_AMT                            --当日成交金额
     , T1.EN_AVG_DEAL_PRICE                                                            AS AVG_TRAN_PRC                            --平均交易价格
     , T1.L_TOTAL_DEAL_AMOUNT                                                          AS TOTAL_DEAL_VOL                          --累计成交数量
     , T1.EN_TOTAL_DEAL_BALANCE                                                        AS TOTAL_DEAL_AMT                          --累计成交金额
     , T1.L_BUSIN_TIMES                                                                AS DEAL_TIMES                              --分笔成交次数
     , T1.L_OPERATOR_NO                                                                AS ISTCT_EXEC_CODE                         --指令执行人代码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN
          COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE))
       END                                                                             AS INV_TYPE_CODE                           --投资类型代码
     , T1.VC_SEAT_ID                                                                   AS HLDP_SEAT                               --持仓席位
     , T1.C_CANCEL_FLAG                                                                AS WHDW_FLAG                               --撤单标志
     , T1.VC_REVOKE_CAUSE                                                              AS WHDW_CAUSE                              --撤单原因
     , T1.L_CANCEL_AMOUNT                                                              AS WHDW_VOL                                --撤单数量
     , T1.C_ENTRUST_ORIGIN                                                             AS ENTU_SRC                                --委托来源
     , 'O32'                                                                           AS SSYS                                    --源系统
     , 'ODS_O32_TENTRUSTS_PTD'                                                         AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TENTRUSTS_PTD T1  --委托表
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
    ON T1.C_ASSET_TYPE = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.SSYS = 'O32'--源系统简称
   AND T4.SRC_DICT_CLS_CD = 'C_ASSET_CLASS'--源字典分类
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_BUSIN_CLASS = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称
   AND T5.SRC_DICT_CLS_CD = 'C_BUSIN_CLASS'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_STOCK_DIRECTION  = T6.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T6.SSYS = 'O32'--源系统简称
   AND T6.SRC_DICT_CLS_CD = 'C_STOCK_DIRECTION'--源字典分类
   AND T6.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_FUND_DIRECTION  = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.SSYS = 'O32'--源系统简称
   AND T7.SRC_DICT_CLS_CD = 'C_FUND_DIRECTION'--源字典分类
   AND T7.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_ENTRUST_DIRECTION  = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.SSYS = 'O32'--源系统简称
   AND T8.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'--源字典分类
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_ENTRUST_STATUS = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.SSYS = 'O32'--源系统简称
   AND T9.SRC_DICT_CLS_CD = 'C_ENTRUST_STATUS'--源字典分类
   AND T9.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.C_LAUNCH_FLAG = T10.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T10.SSYS = 'O32'--源系统简称
   AND T10.SRC_DICT_CLS_CD = 'C_LAUNCH_FLAG'--源字典分类
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T1.C_DMA = T11.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T11.SSYS = 'O32'--源系统简称
   AND T11.SRC_DICT_CLS_CD = 'C_DMA'--源字典分类
   AND T11.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准码值字典映射表
    ON T1.VC_VALID_TYPE = T12.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T12.SSYS = 'O32'--源系统简称
   AND T12.SRC_DICT_CLS_CD = 'VC_VALID_TYPE'--源字典分类
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T13.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T13.SSYS = 'O32'--源系统简称
   AND T13.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'--源字典分类
   AND T13.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准码值字典映射表
    ON T1.C_MARKET_NO = T14.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T14.SSYS = 'O32'--源系统简称
   AND T14.SRC_DICT_CLS_CD = 'C_MARKET_NO'--源字典分类
   AND T14.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T15 --标准码值字典映射表
    ON T1.C_FROZEN_TYPE = T15.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T15.SSYS = 'O32'--源系统简称
   AND T15.SRC_DICT_CLS_CD = 'C_FROZEN_TYPE'--源字典分类
   AND T15.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T16 --证券基本信息
    ON T3.SCR_NUM = T16.SCR_NUM --证券编码
   AND T16.VALID_FLAG = '1' 
   AND T16.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;"
