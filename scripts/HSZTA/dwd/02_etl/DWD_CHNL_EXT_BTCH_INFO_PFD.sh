#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:渠道
-- ** 描述:外部网点信息
-- ** 创建者:auto
-- ** 创建日期:2023-07-17
-- ** 修改日志:
-- ** 2023-07-17，auto，新建
-- ** 目标表：DWDXDAY.DWD_CHNL_EXT_BTCH_INFO_PFD  外部网点信息
-- ** 源表：  ODS_XDAY_OA.ODS_OA_IP_AGENCY_HIERARCHY_PFD
-- **         ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
-- **         DWDXDAY.DWD_CMM_AREA_INFO_PFD 区域信息
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set mapreduce.job.reduces=3;
 

CREATE TABLE  DWDXDAY.ODS_OA_AGENCY_VIEW_PFD AS
SELECT SK_AGENCY
     , AGENCYNO
     , AGENCY_NAME
     , AGENCY_BRANCH_NAME
     , AGENCY_LEVEL
     , DK_SALE_CHANNEL
     , DK_AGENCY_TYPE
     , SK_REGION
     , ROW_NUMBER() OVER(PARTITION BY SK_AGENCY ORDER BY  AGENCY_LEVEL)  RN 
  FROM ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T2 
 WHERE T2.P_DT = '${p_end_dt}'
   AND NVL(T2.EFFECTIVE_FROM,'19000101') <= '${p_end_dt}'
   AND NVL(T2.EFFECTIVE_TO,'99991231') >= '${p_end_dt}'
;
INSERT OVERWRITE TABLE DWDXDAY.DWD_CHNL_EXT_BTCH_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.SK_AGENCY                                                                  AS BTCH_NUM                                --网点编码
     , T2.AGENCY_BRANCH_NAME                                                         AS BTCH_NAME                               --网点名称
     , T2.AGENCY_LEVEL                                                               AS BTCH_BELT_LVL                           --网点所属层级
     , T9.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T2.AGENCYNO                                                                   AS CHNL_INCD                               -- 渠道内码
     , T3.AGENCY_NAME                                                                AS CHNL_NAME                               -- 渠道名称
     , T1.SK_AGENCY_OF_LV1                                                           AS PRI_BTCH_NUM                            --一级网点编码
     , T3.AGENCY_BRANCH_NAME                                                         AS PRI_BTCH_NAME                           --一级网点名称
     , T1.SK_AGENCY_OF_LV2                                                           AS SCD_BTCH_NUM                            --二级网点编码
     , T4.AGENCY_BRANCH_NAME                                                         AS SCD_BTCH_NAME                           --二级网点名称
     , T1.SK_AGENCY_OF_LV3                                                           AS THRE_LVL_BTCH_NUM                       --三级网点编码
     , T5.AGENCY_BRANCH_NAME                                                         AS THRE_LVL_BTCH_NAME                      --三级网点名称
     , T1.SK_AGENCY_OF_LV4                                                           AS FOUR_LVL_BTCH_NUM                       --四级网点编码
     , T6.AGENCY_BRANCH_NAME                                                         AS FOUR_LVL_BTCH_NAME                      --四级网点名称
     , T1.SK_AGENCY_OF_LV5                                                           AS FIVE_LVL_BTCH_NUM                       --五级网点编码
     , T7.AGENCY_BRANCH_NAME                                                         AS FIVE_LVL_BTCH_NAME                      --五级网点名称
     , T1.SK_AGENCY_OF_LV6                                                           AS SIX_LVL_BTCH_NUM                        --六级网点编码
     , T8.AGENCY_BRANCH_NAME                                                         AS SIX_LVL_BTCH_NAME                       --六级网点名称
     , T1.EFFECTIVE_FROM                                                             AS ST_DATE                                 --开始日期
     , T1.EFFECTIVE_TO                                                               AS END_DATE                                --结束日期
     , CASE WHEN T2.DK_SALE_CHANNEL IS NOT NULL 
              THEN COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T2.DK_SALE_CHANNEL)) 
        END                                                                          AS CHNL_TYPE_CODE                          --渠道类型代码
     , CASE WHEN T2.DK_AGENCY_TYPE IS NOT NULL 
              THEN COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T2.DK_AGENCY_TYPE)) 
        END                                                                          AS CHNL_CATG_CODE                          --渠道类别代码
     , T10.AREA_NUM                                                                  AS AREA_NUM                                --区域编码
     , T1.MEMO                                                                       AS MEMO                                    --备注
     , 'OA'                                                                          AS SSYS                                    --源系统
     , 'ODS_OA_IP_AGENCY_HIERARCHY_PFD'                                              AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_OA.ODS_OA_IP_AGENCY_HIERARCHY_PFD T1  
  LEFT JOIN DWDXDAY.ODS_OA_AGENCY_VIEW_PFD T2 
    ON T1.SK_AGENCY = T2.SK_AGENCY
   AND T2.RN = 1
  LEFT JOIN DWDXDAY.ODS_OA_AGENCY_VIEW_PFD T3 
    ON T1.SK_AGENCY_OF_LV1 = T3.SK_AGENCY
   AND T3.RN = 1
  LEFT JOIN DWDXDAY.ODS_OA_AGENCY_VIEW_PFD T4 
    ON T1.SK_AGENCY_OF_LV2 = T4.SK_AGENCY
   AND T4.RN = 1
  LEFT JOIN DWDXDAY.ODS_OA_AGENCY_VIEW_PFD T5 
    ON T1.SK_AGENCY_OF_LV3 = T5.SK_AGENCY
   AND T5.RN = 1
  LEFT JOIN DWDXDAY.ODS_OA_AGENCY_VIEW_PFD T6 
    ON T1.SK_AGENCY_OF_LV4 = T6.SK_AGENCY
   AND T6.RN = 1
  LEFT JOIN DWDXDAY.ODS_OA_AGENCY_VIEW_PFD T7 
    ON T1.SK_AGENCY_OF_LV5 = T7.SK_AGENCY
   AND T7.RN = 1
  LEFT JOIN DWDXDAY.ODS_OA_AGENCY_VIEW_PFD T8 
    ON T1.SK_AGENCY_OF_LV6 = T8.SK_AGENCY
   AND T8.RN = 1
   LEFT JOIN  DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD  T9   --渠道基本信息
   ON T2.AGENCYNO = T9.CHNL_INCD
   AND T9.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
   LEFT JOIN DWDXDAY.DWD_CMM_AREA_INFO_PFD  T10  --区域信息
   ON T2.SK_REGION = T10.AREA_CODE
   AND T10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准字典码值映射
    ON T11.SSYS = 'OA'
   AND T11.SRC_DICT_CLS_CD = 'DK_SALE_CHANNEL'
   AND T2.DK_SALE_CHANNEL = T11.SRC_DICT_CLS_CDVAL
   AND T11.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准字典码值映射
    ON T12.SSYS = 'OA'
   AND T12.SRC_DICT_CLS_CD = 'DK_AGENCY_TYPE'
   AND T2.DK_AGENCY_TYPE = T12.SRC_DICT_CLS_CDVAL
   AND T12.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;
DROP TABLE DWDXDAY.ODS_OA_AGENCY_VIEW_PFD;
"
