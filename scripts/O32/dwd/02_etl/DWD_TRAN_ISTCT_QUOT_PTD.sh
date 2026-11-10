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
-- ** 描述:统计指令执行期间证券的市场成交情况
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-15
-- ** 修改日志:
-- ** 2023-05-15，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_ISTCT_QUOT_PTD                 指令行情表
-- ** 源  表：ODS_XDAY_O32.ODS_O32_TINSTRUCTIONMARKETINFO_PTD 指令行情信息表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD              账套编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP              标准码值字典映射表
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD                证券编码映射
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD              证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_ISTCT_QUOT_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_DAILY_INSTRUCTION_NO                                                     AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                       AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T5.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , CASE 
         WHEN  T1.C_ENTRUST_DIRECTION IS NOT NULL THEN
           COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION))
        END                                                                          AS ENTU_ORNT_CODE                          --委托方向代码
     , CASE 
         WHEN  T1.C_INVEST_TYPE IS NOT NULL THEN
           COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE))
        END                                                                          AS INV_TYPE_CODE                           --投资类型代码
     , T1.L_OPERATOR_NO                                                              AS DELR_CODE                               --交易员代码
     , T6.TRAN_CRRC_CODE                                                             AS CRRC_CODE                               --币种代码
     , T1.L_TIME                                                                     AS MKT_TIME                                --市场时间
     , T1.EN_LAST_PRICE                                                              AS CURR_LAST_PRIC                          --当前最新价
     , T1.L_MARKET_DEAL_AMOUNT                                                       AS CURR_MKT_DEAL_VOL                       --当前市场成交数量
     , T1.EN_MARKET_DEAL_BALANCE                                                     AS CURR_MKT_DEAL_AMT                       --当前市场成交金额
     , T1.EN_DISP_LAST_PRICE                                                         AS ISTCT_DISTR_LAST_PRIC                   --指令分发时最新价
     , T1.L_DISP_DEAL_AMOUNT                                                         AS ISTCT_DISTR_DEAL_VOL                    --指令分发时成交数量
     , T1.EN_DISP_DEAL_BALANCE                                                       AS ISTCT_DISTR_DEAL_AMT                    --指令分发时成交金额
     , T1.EN_CPLT_LAST_PRICE                                                         AS ISTCT_FNSH_LAST_PRIC                    --指令完成时最新价
     , T1.L_CPLT_DEAL_AMOUNT                                                         AS ISTCT_FNSH_MKT_DEALVOL                  --指令完成时市场成交量
     , T1.EN_CPLT_DEAL_BALANCE                                                       AS ISTCT_FNSH_MKT_DEAL_AMT                 --指令完成时市场成交金额
     , T1.L_CPLT_VALID_DEAL_AMOUNT                                                   AS ISTCT_FNSH_VALID_MKT_DEAL_VOL           --指令完成时有效市场成交数量
     , T1.EN_CPLT_VALID_DEAL_BALANCE                                                 AS ISTCT_FNSH_VALID_MKT_DEAL_AMT           --指令完成时有效市场成交金额
     , T1.EN_END_LAST_PRICE                                                          AS ISTCT_END_LAST_PRIC                     --指令结束时最新价
     , T1.L_END_DEAL_AMOUNT                                                          AS ISTCT_END_MKT_DEALVOL                   --指令结束时市场成交量
     , T1.EN_END_DEAL_BALANCE                                                        AS ISTCT_END_MKT_DEAL_AMT                  --指令结束时市场成交金额
     , T1.L_VALID_DEAL_AMOUNT                                                        AS ISTCT_END_VALID_MKT_DEAL_VOL            --指令结束时有效市场成交数量
     , T1.EN_VALID_DEAL_BALANCE                                                      AS ISTCT_END_VALID_MKT_DEAL_AMT            --指令结束时有效市场成交金额
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TINSTRUCTIONMARKETINFO_PTD'                                          AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTIONMARKETINFO_PTD T1  --指令行情信息表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T1.C_ENTRUST_DIRECTION  = T3.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T3.SSYS = 'O32'--源系统简称
   AND T3.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'--源字典分类
   AND T3.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.C_INVEST_TYPE  = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.SSYS = 'O32'--源系统简称
   AND T4.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'--源字典分类
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T5 --证券编码映射
    ON T1.VC_INTER_CODE = T5.SCR_INCD--证券内码
   AND T5.SSYS = 'O32'--源系统
   AND T5.ST_DATE <= '${p_end_dt}'--开始日期
   AND T5.END_DATE >= '${p_end_dt}'--结束日期
   AND T5.VALID_FLAG = '1'--有效标志
   AND T5.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T6 --证券基本信息
    ON T5.SCR_NUM = T6.SCR_NUM --证券编码
   AND T6.VALID_FLAG = '1' 
   AND T6.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
 ;"
