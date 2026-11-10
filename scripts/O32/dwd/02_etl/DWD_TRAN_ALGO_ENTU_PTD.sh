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
-- ** 描述:保留当天发生的母单委托数据
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-17
-- ** 修改日志:
-- ** 2023-05-17，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_ALGO_ENTU_PTD      母单委托表
-- ** 源  表：ODS_XDAY_O32.ODS_O32_TALGOORDER_PTD 母单委托表
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD    证券编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  标准码值字典映射表
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD  证券基本信息
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
INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_ALGO_ENTU_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_ALGO_SERIAL_NO                                                           AS ALGO_SERIALNO                           --母单序号
     , T1.L_BATCH_SERIAL_NO                                                          AS ALGO_BAT_NO                             --母单批号
     , T9.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T12.SYMBOL                                                                    AS SYMBOL                                  --证券代码
     , CASE 
         WHEN T1.C_MARKET_NO IS NOT NULL THEN
          COALESCE(T2.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO))
              END                                                                    AS TRAN_MKT_CODE                           --交易市场代码
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS))
              END                                                                    AS BUSIN_CATG_CODE                         --业务类别代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION))
              END                                                                    AS ENTU_ORNT_CODE                          --委托方向代码
     , CASE 
         WHEN T1.EN_ENTRUST_PRICE > 0 THEN 
          '0' -- 限价
         ELSE
          '1' -- 市价
              END                                                                     AS PRC_TYPE_CODE                          --价格类型代码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE)) 
       END                                                                            AS INV_TYPE_CODE                         --投资类型代码
     , T12.TRAN_CRRC_CODE                                                             AS CRRC_CODE                             --币种代码
     , T1.EN_ENTRUST_PRICE                                                            AS ENTU_PRC                              --委托价格
     , CASE 
         WHEN T1.C_STATUS IS NOT NULL THEN
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS)) 
       END                                                                            AS ENTU_STAT_CODE                        --委托状态代码
     , T1.D_ENTRUST_TIME                                                              AS ENTU_TIME                             --委托时间
     , T1.L_COMP_ID                                                                   AS ALGOR_SUPLR_CODE                      --算法供应商代码
     , CASE 
         WHEN LENGTH(REGEXP_EXTRACT(T1.VC_PARAMS1, '<tacticname>(.*?)</tacticname>', 1)) <> 0 THEN
          REGEXP_EXTRACT(T1.VC_PARAMS1, '<tacticname>(.*?)</tacticname>', 1)
       END                                                                            AS ALGOR_NAME                            --算法名称
     , CASE 
         WHEN LENGTH(REGEXP_EXTRACT(T1.VC_PARAMS1, '<trade_style>(.*?)</trade_style>', 1)) <> 0 THEN
          COALESCE(T10.STD_DICT_CLS_CD_VAL,
                   CONCAT('@',REGEXP_EXTRACT(T1.VC_PARAMS1, '<trade_style>(.*?)</trade_style>', 1))) 
       END                                                                            AS EXEC_STYLE_CODE                       --执行风格代码
     , CASE 
         WHEN LENGTH(REGEXP_EXTRACT(T1.VC_PARAMS1, '<l_limitpov>(.*?)</l_limitpov>', 1)) <> 0 THEN
          REGEXP_EXTRACT(T1.VC_PARAMS1, '<l_limitpov>(.*?)</l_limitpov>', 1)
       END                                                                            AS CITY_RATIO                            --市占比
     , T1.VC_STRATEGY_NAME                                                            AS ALGOR_STRA_NAME                       --算法策略名称
     , CASE 
         WHEN T1.C_ALGO_STATUS IS NOT NULL THEN
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ALGO_STATUS)) 
       END                                                                            AS ALGO_STAT_CODE                        --母单状态代码
     , T1.L_BEGIN_TIME                                                                AS ALGO_BEGIN_TIME                       --母单开始时间
     , T1.L_END_TIME                                                                  AS ALGO_END_TIME                         --母单结束时间
     , CASE 
         WHEN T1.C_CANCEL_FLAG IS NOT NULL THEN
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CANCEL_FLAG)) 
       END                                                                            AS WHDW_STAT_CODE                        --撤单状态代码
     , CASE 
         WHEN T1.C_FORCE_CANCEL IS NOT NULL THEN
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FORCE_CANCEL)) 
       END                                                                            AS FORC_WHDW_STAT_CODE                   --强制撤单状态代码
     , T1.L_AMOUNT                                                                    AS TGT_VOL                               --目标数量
     , T1.EN_BALANCE                                                                  AS TGT_AMT                               --目标金额
     , T1.L_ENTRUST_AMOUNT                                                            AS HAS_ENTU_VOL                          --已委托数量
     , T1.EN_ENTRUST_BALANCE                                                          AS HAS_ENTU_AMT                          --已委托金额
     , T1.L_DEAL_AMOUNT                                                               AS HAS_DEAL_VOL                          --已成交数量
     , T1.EN_DEAL_BALANCE                                                             AS HAS_DEAL_AMT                          --已成交金额
     , T1.L_CANCEL_AMOUNT                                                             AS HAS_WHDW_VOL                          --已撤数量
     , T1.EN_CANCEL_BALANCE                                                           AS HAS_WHDW_AMT                          --已撤金额
     , T1.L_OPERATOR_NO                                                               AS ISTCT_EXEC_CODE                       --指令执行人代码
     , 'O32'                                                                          AS SSYS                                  --源系统
     , 'ODS_O32_TALGOORDER_PTD'                                                       AS SRC_TAB                               --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')       AS LD_TIME                               --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')       AS MODIFY_TIME                           --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TALGOORDER_PTD T1  --母单委托表
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2  --标准码值字典映射表
    ON T1.C_MARKET_NO = T2.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T2.SSYS = 'O32'  --源系统简称
   AND T2.SRC_DICT_CLS_CD = 'C_MARKET_NO'  --源字典分类
   AND T2.VALID_FLAG = '1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T1.C_ENTRUST_DIRECTION = T3.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T3.SSYS = 'O32'  --源系统简称
   AND T3.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'  --源字典分类
   AND T3.VALID_FLAG ='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T4.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T4.SSYS = 'O32'  --源系统简称
   AND T4.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'  --源字典分类
   AND T4.VALID_FLAG ='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_ALGO_STATUS = T5.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T5.SSYS = 'O32'  --源系统简称
   AND T5.SRC_DICT_CLS_CD = 'C_ALGO_STATUS'  --源字典分类
   AND T5.VALID_FLAG ='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_CANCEL_FLAG = T6.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T6.SSYS= 'O32'  --源系统简称
   AND T6.SRC_DICT_CLS_CD = 'C_CANCEL_FLAG'  --源字典分类
   AND T6.VALID_FLAG ='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_FORCE_CANCEL = T7.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T7.SSYS = 'O32'  --源系统简称
   AND T7.SRC_DICT_CLS_CD = 'C_FORCE_CANCEL'  --源字典分类
   AND T7.VALID_FLAG ='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_STATUS = T8.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T8.SSYS = 'O32'  --源系统简称
   AND T8.SRC_DICT_CLS_CD = 'C_ENTRUST_STATUS'  --源字典分类
   AND T8.VALID_FLAG = '1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T9 --证券编码映射
     ON T1.VC_REPORT_CODE = T9.SCR_INCD  --证券内码
    AND T9.SSYS ='O32'     --源系统
    AND T9.ST_DATE <= '${p_end_dt}'    --开始日期
    AND T9.END_DATE >= '${p_end_dt}'    --结束日期
    AND T9.VALID_FLAG = '1'  --有效标志
    AND T9.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON REGEXP_EXTRACT(T1.VC_PARAMS1, '<trade_style>(.*?)</trade_style>', 1) = 
       T10.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T10.SSYS = 'O32'  --源系统简称
   AND T10.SRC_DICT_CLS_CD = 'EXEC_STYLE_CODE'  --源字典分类
   AND T10.VALID_FLAG ='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T1.C_BUSIN_CLASS = T11.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T11.SSYS = 'O32'  --源系统简称
   AND T11.SRC_DICT_CLS_CD = 'C_BUSIN_CLASS'  --源字典分类
   AND T11.VALID_FLAG ='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T12 --证券基本信息
    ON T9.SCR_NUM = T12.SCR_NUM --证券编码
   AND T12.VALID_FLAG = '1' 
   AND T12.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;"
