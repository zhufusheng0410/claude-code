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
-- ** 描述:产品费用归属配置
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_FEE_AFFI_CFG_PFD  产品费用归属配置
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TFAREBELONG_PFD 费用归属设置
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TFAREBELONG_PFD 费用归属设置
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;

set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_FEE_AFFI_CFG_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_BUSINFLAG IS NOT NULL 
             THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSINFLAG)) 
        END                                                                          AS BUSIN_CODE                              --业务代码
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , CASE WHEN T1.C_FARETYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FARETYPE)) 
        END                                                                          AS FEE_TYPE_CODE                           --费用类型代码
     , T1.F_AGENCYRATIO                                                              AS COLL_AGENCY_RATE                        --归销售商比例
     , T1.F_REGISTRATIO                                                              AS COLL_REG_ORG_RATE                       --归注册机构比例
     , T1.C_OTHERCODE                                                                AS OTHS_FUND_CODE                          --对方基金代码
     , CASE WHEN T1.C_BELONGTYPE IS NOT NULL 
             THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BELONGTYPE)) 
        END                                                                          AS FEE_SHARIG_MODE                         --费用分成方式
     , T1.C_ONLINEINPUTDATE                                                          AS DATA_PRDU_DATE                          --数据产生日期
     , T1.D_BEGINDATE                                                                AS ST_DATE                                 --开始日期
     , NULL                                                                          AS END_DATE                                --结束日期
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
             THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TFAREBELONG_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFAREBELONG_PFD T1  --费用归属设置
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T4 --渠道基本信息
    ON T4.CHNL_INCD = T1.C_AGENCYNO
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_FARETYPE'
   AND T1.C_FARETYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSZTA'
   AND T6.SRC_DICT_CLS_CD = 'C_BELONGTYPE'
   AND T1.C_BELONGTYPE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'HSZTA'
   AND T7.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_FEE_AFFI_CFG_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_BUSINFLAG IS NOT NULL 
             THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSINFLAG)) 
        END                                                                          AS BUSIN_CODE                              --业务代码
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , CASE WHEN T1.C_FARETYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FARETYPE)) 
        END                                                                          AS FEE_TYPE_CODE                           --费用类型代码
     , T1.F_AGENCYRATIO                                                              AS COLL_AGENCY_RATE                        --归销售商比例
     , T1.F_REGISTRATIO                                                              AS COLL_REG_ORG_RATE                       --归注册机构比例
     , T1.C_OTHERCODE                                                                AS OTHS_FUND_CODE                          --对方基金代码
     , NULL                                                                          AS FEE_SHARIG_MODE                         --费用分成方式
     , NULL                                                                          AS DATA_PRDU_DATE                          --数据产生日期
     , NULL                                                                          AS ST_DATE                                 --开始日期
     , NULL                                                                          AS END_DATE                                --结束日期
     , NULL                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TFAREBELONG_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFAREBELONG_PFD T1  --费用归属设置
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSFTA'
   AND T3.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T4 --渠道基本信息
    ON T4.CHNL_INCD = T1.C_AGENCYNO
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_FARETYPE'
   AND T1.C_FARETYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;
"
