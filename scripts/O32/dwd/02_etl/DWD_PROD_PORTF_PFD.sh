#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "


-- **************************************************************************
-- ** 主题:产品
-- ** 描述:O32投资组合表
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-17
-- ** 修改日志:
-- ** 2023-05-17，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PORTF_PFD          O32投资组合表
-- ** 源  表：ODS_XDAY_O32.ODS_O32_TCOMBI_PFD     投资组合表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD  账套编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  标准字典码值映射
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PORTF_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_COMBI_ID                                                                   AS PORTF_SERIALNO                          --投资组合序号
     , T1.VC_COMBI_NO                                                                  AS PORTF_NO                                --投资组合编号
     , T1.VC_COMBI_NAME                                                                AS PORTF_NAME                              --投资组合名称
     , T2.SFAC_NUM                                                                     AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                    AS PROD_INCD                               --产品内码
     , T1.L_ASSET_ID                                                                  AS AST_UNIT_SERIALNO                       --资产单元序号
     , CASE 
         WHEN T1.C_COMBI_CLASS IS NOT NULL THEN
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_COMBI_CLASS))
       END                                                                             AS COMB_TYPE_CODE                          --组合类型代码
     , CASE 
         WHEN T6.L_DEFAULT_COMBI = T1.L_COMBI_ID
             THEN '1'
             ELSE '0'
       END                                                                             AS DEF_PORTF_FLAG                          --默认投资组合标志
     , CASE 
         WHEN T1.C_COMBI_STATUS IS NOT NULL THEN
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_COMBI_STATUS))
       END                                                                             AS STAT_CODE                               --状态代码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE))
       END                                                                             AS INV_TYPE_CODE                           --投资类型代码
     , T1.VC_STOCKTYPE_RIGHT                                                           AS SCR_CATG_PRVL                           --证券类别权限
     , T1.VC_ENTRDIRE_RIGHT                                                            AS ENTU_ORNT_PRVL                          --委托方向权限
     , T1.VC_PERMIT_MARKET                                                             AS PERM_INV_TRAN_MKT                       --允许投资的交易市场
     , T1.L_SETUP_DATE                                                                 AS CRT_DATE                                --创建日期
     , T1.L_END_DATE                                                                   AS END_DATE                                --结束日期
     , 'O32'                                                                           AS SSYS                                    --源系统
     , 'ODS_O32_TCOMBI_PTD'                                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TCOMBI_PFD T1  --投资组合表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'O32'
   AND T3.SRC_DICT_CLS_CD = 'C_COMBI_CLASS'
   AND T1.C_COMBI_CLASS = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'O32'
   AND T4.SRC_DICT_CLS_CD = 'C_COMBI_STATUS'
   AND T1.C_COMBI_STATUS = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'O32'
   AND T5.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'
   AND T1.C_INVEST_TYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD T6 --基金信息表
    ON T1.L_FUND_ID = T6.L_FUND_ID
   AND T1.P_DT = T6.P_DT
WHERE T1.P_DT = '${p_end_dt}'
;"
