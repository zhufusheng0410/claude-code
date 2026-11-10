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
-- ** 描述:保留当天发生的母单交易证券数据
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-17
-- ** 修改日志:
-- ** 2023-05-17，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_ALGO_ASSN_PTD          母单分配表
-- ** 源表：  ODS_XDAY_O32.ODS_O32_TALGOENTRUSTS_PTD  母单分配表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD      账套编码映射
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD        证券编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP      标准码值字典映射表
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD      证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_ALGO_ASSN_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_ALGO_SERIAL_NO                                                           AS ALGO_SERIALNO                           --母单序号
     , T1.L_BATCH_SERIAL_NO                                                          AS ALGO_BAT_NO                             --母单批号
     , T1.L_DAILY_INSTRUCTION_NO                                                     AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                       AS ISTCT_MODIFY_SERIALNO                   --指令修改次序
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T10.SYMBOL                                                                    AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , CASE 
         WHEN T1.C_MARKET_NO IS NOT NULL THEN
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO))
       END                                                                           AS TRAN_MKT_CODE                           --交易市场代码
     , T1.VC_STOCKHOLDER_ID                                                          AS HOLDER_CODE                             --股东代码
     , T1.VC_MAIN_SEAT                                                               AS MAIN_SEAT                               --主席位
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION))
       END                                                                           AS ENTU_ORNT_CODE                          --委托方向代码
     , CASE 
         WHEN T1.EN_ENTRUST_PRICE > 0 THEN 
          '0' -- 限价
         ELSE 
          '1' -- 市价
       END                                                                           AS PRC_TYPE_CODE                           --价格类型代码
     , T10.TRAN_CRRC_CODE                                                            AS CRRC_CODE                               --币种代码
     , T1.L_AMOUNT                                                                   AS TGT_VOL                                 --目标数量
     , T1.EN_BALANCE                                                                 AS TGT_AMT                                 --目标金额
     , T1.EN_ENTRUST_PRICE                                                           AS ENTU_PRC                                --委托价格
     , T1.L_AMOUNT                                                                   AS ENTU_VOL                                --委托数量
     , T1.EN_BALANCE                                                                 AS ENTU_AMT                                --委托金额
     , T1.L_ENTRUST_AMOUNT                                                           AS HAS_ENTU_VOL                            --已委托数量
     , T1.EN_ENTRUST_BALANCE                                                         AS HAS_ENTU_AMT                            --已委托金额
     , T1.D_ENTRUST_TIME                                                             AS ENTU_TIME                               --委托时间
     , T1.L_DEAL_AMOUNT                                                              AS DEAL_VOL                                --成交数量
     , T1.EN_DEAL_BALANCE                                                            AS DEAL_AMT                                --成交金额
     , T1.EN_ORDER_AVG_PRICE                                                         AS ALGO_DEAL_APRC                          --母单成交均价
     , CASE 
         WHEN T1.C_ENTRUST_EXECUTE_STATUS IS NOT NULL THEN
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_EXECUTE_STATUS))
       END                                                                           AS ENTU_FNSH_STAT_CODE                     --委托完成状态代码
     , CASE 
         WHEN T1.C_DEAL_EXECTUE_STATUS IS NOT NULL THEN
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEAL_EXECTUE_STATUS))
       END                                                                           AS DEAL_FNSH_STAT_CODE                     --成交完成状态代码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE))
       END                                                                           AS INV_TYPE_CODE                           --投资类型代码
     , T1.D_DEAL_COMPLETE_DATE                                                       AS END_TIME                                --结束时间
     , T1.L_DISP_DEAL_AMOUNT                                                         AS BEGIN_MKT_DEALVOL                       --开始时的市场成交量
     , T1.EN_DISP_DEAL_BALANCE                                                       AS BEGIN_MKT_DEAL_AMT                      --开始时的市场成交金额
     , T1.EN_DISP_LAST_PRICE                                                         AS ALGO_BEGIN_LAST_PRIC                    --母单开始时最新价
     , T1.L_CPLT_DEAL_AMOUNT                                                         AS FNSH_MKT_DEALVOL                        --完成时的市场成交量
     , T1.EN_CPLT_DEAL_BALANCE                                                       AS FNSH_MKT_DEAL_AMT                       --完成时的市场成交金额
     , T1.L_CPLT_VALID_DEAL_AMOUNT                                                   AS ALGO_FNSH_MKT_VALID_DEALVOL             --母单完成时的市场有效成交量
     , T1.EN_CPLT_VALID_DEAL_BALANCE                                                 AS ALGO_FNSH_MKT_VALID_DEAL_AMT            --母单完成时的市场有效成交金额
     , T1.EN_CPLT_LAST_PRICE                                                         AS ALGO_FNSH_LAST_PRIC                     --母单完成时最新价
     , T1.L_END_DEAL_AMOUNT                                                          AS END_MKT_DEALVOL                         --结束时的市场成交量
     , T1.EN_END_DEAL_BALANCE                                                        AS END_MKT_DEAL_AMT                        --结束时的市场成交金额
     , T1.L_VALID_DEAL_AMOUNT                                                        AS ALGO_END_MKT_VALID_DEALVOL              --母单结束时的市场有效成交量
     , T1.EN_VALID_DEAL_BALANCE                                                      AS ALGO_END_MKT_VALID_DEAL_AMT             --母单结束时的市场有效成交金额
     , T1.EN_END_LAST_PRICE                                                          AS ALGO_END_LAST_PRIC                      --母单结束时最新价
     , T1.L_MARKET_DEAL_AMOUNT                                                       AS MKT_DEALVOL                             --市场成交量
     , T1.EN_MARKET_DEAL_BALANCE                                                     AS MKT_DEAL_AMT                            --市场成交金额
     , T1.EN_LAST_PRICE                                                              AS CURR_LAST_PRIC                          --当前最新价
     , T1.L_OPERATOR_NO                                                              AS ISTCT_EXEC_CODE                         --指令执行人代码
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TALGOENTRUSTS_PTD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TALGOENTRUSTS_PTD T1  --母单分配表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD --证券内码
   AND T3.SSYS = 'O32'--源系统
   AND T3.ST_DATE <= '${p_end_dt}'--开始日期
   AND T3.END_DATE >= '${p_end_dt}'--结束日期
   AND T3.VALID_FLAG = '1'--有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.C_MARKET_NO = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.SSYS = 'O32'--源系统简称
   AND T4.SRC_DICT_CLS_CD = 'C_MARKET_NO'--源字典分类
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_ENTRUST_DIRECTION = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称
   AND T5.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_ENTRUST_EXECUTE_STATUS = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.SSYS = 'O32'--源系统简称
   AND T7.SRC_DICT_CLS_CD = 'C_ENTRUST_EXECUTE_STATUS'--源字典分类
   AND T7.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_DEAL_EXECTUE_STATUS = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.SSYS = 'O32'--源系统简称
   AND T8.SRC_DICT_CLS_CD = 'C_DEAL_EXECUTE_STATUS'--源字典分类
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.SSYS = 'O32'--源系统简称
   AND T9.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'--源字典分类
   AND T9.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T10 --证券基本信息
    ON T3.SCR_NUM = T10.SCR_NUM --证券编码
   AND T10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
   AND T10.VALID_FLAG = '1' 
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;"
