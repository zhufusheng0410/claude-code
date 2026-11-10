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
-- ** 描述:产品发行信息
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_SUE_INFO_PFD  产品发行信息
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TISSUEGROUP_PFD  基金发行分组设置
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TISSUEGROUP_PFD 基金发行分组设置
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD  产品编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_SUE_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , NULL                                                                          AS CHNL_NUM                                --渠道编码
     , NULL                                                                          AS CHNL_INCD                               --渠道内码
     , NULL                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , NULL                                                                          AS SECT_MAX_VAL                            --分段最大值
     , NULL                                                                          AS SECT_MIN_VAL                            --分段最小值
     , T1.F_QUOTA                                                                    AS SUE_LMT                                 --发行额度
     , CASE WHEN T1.C_ISSUEMODE IS NOT NULL 
             THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ISSUEMODE)) 
        END                                                                          AS SUE_MODE_CODE                           --发行方式代码
     , T1.F_HAVEALLOT                                                                AS HAS_SCRP_LMT                            --已认购额度
     , T1.D_LASTDATE                                                                 AS LAST_SCRP_DATE                          --最后认购日期
     , T1.F_LASTALLOT                                                                AS LAST_ONE_DAY_SCRP_LMT                   --最后一天认购额度
     , T1.F_ALLOTRATIO                                                               AS SCRP_RATN_RATE                          --认购配售比例
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TISSUEGROUP_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TISSUEGROUP_PFD T1  --基金发行分组设置
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_ISSUEMODE'
   AND T1.C_ISSUEMODE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_SUE_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.F_MINBALANCE                                                               AS SECT_MAX_VAL                            --分段最大值
     , T1.F_MAXBALANCE                                                               AS SECT_MIN_VAL                            --分段最小值
     , T1.F_QUOTA                                                                    AS SUE_LMT                                 --发行额度
     , CASE WHEN T1.C_ISSUEMODE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ISSUEMODE)) 
        END                                                                          AS SUE_MODE_CODE                           --发行方式代码
     , T1.F_HAVEALLOT                                                                AS HAS_SCRP_LMT                            --已认购额度
     , T1.D_LASTDATE                                                                 AS LAST_SCRP_DATE                          --最后认购日期
     , T1.F_LASTALLOT                                                                AS LAST_ONE_DAY_SCRP_LMT                   --最后一天认购额度
     , T1.F_ALLOTRATIO                                                               AS SCRP_RATN_RATE                          --认购配售比例
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TISSUEGROUP_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TISSUEGROUP_PFD T1  --基金发行分组设置
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFTA'
   AND T4.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_ISSUEMODE'
   AND T1.C_ISSUEMODE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

"
