#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:公共
-- ** 描述:区域信息
-- ** 创建者:auto
-- ** 创建日期:2023-07-11
-- ** 修改日志:
-- ** 2023-07-11，auto，新建
-- ** 目标表：DWDXDAY.DWD_CMM_AREA_INFO_PFD  区域信息
-- ** 源表：  ODS_XDAY_OA.ODS_OA_COMM_REGION_HIERARCHY_PFD 区域层级关系
-- **         ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD 区域信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_CMM_AREA_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T5.SK_REGION                                                                  AS AREA_NUM                                --区域编码
     , T5.BK_REGION                                                                  AS AREA_CODE                               --区域代码
     , T1.REGION_LEVEL                                                               AS AREA_LVL                                --区域层级
     , T5.REGION_NAME                                                                AS AREA_NAME                               --区域名称
     , T5.REGION_SHORT_NAME                                                          AS AREA_SNAME                              --区域简称
     , T2.BK_REGION                                                                  AS PROVINCE_CODE                           --省份代码
     , T2.REGION_NAME                                                                AS PROVINCE_NAME                           --省份名称
     , T3.BK_REGION                                                                  AS CITY_CODE                               --城市代码
     , T3.REGION_NAME                                                                AS CITY_NAME                               --城市名称
     , T4.BK_REGION                                                                  AS COUNTY_CODE                             --县区代码
     , T4.REGION_NAME                                                                AS COUNTY_NAME                             --县区名称
     , T5.ZIPCODE                                                                    AS PTCD                                    --邮政编码
     , T5.PHONE_AREA_CODE                                                            AS TEL_AREA_CODE                           --电话区域代码
     , T1.EFFECTIVE_FROM                                                             AS ST_DATE                                 --开始日期
     , T1.EFFECTIVE_TO                                                               AS END_DATE                                --结束日期
     , 'OA'                                                                          AS SSYS                                    --源系统
     , 'ODS_OA_COMM_REGION_HIERARCHY_PFD'                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_OA.ODS_OA_COMM_REGION_HIERARCHY_PFD T1  --区域层级关系
  LEFT JOIN ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD T2 --区域信息
    ON T1.SK_REGION_OF_LV1 = T2.SK_REGION
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD T3 --区域信息
    ON T1.SK_REGION_OF_LV2 = T3.SK_REGION
   AND T3.P_DT = '${p_end_dt}'
  LEFT JOIN ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD T4 --区域信息
    ON T1.SK_REGION_OF_LV3 = T4.SK_REGION
   AND T4.P_DT = '${p_end_dt}'
  LEFT JOIN ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD T5 --区域信息
    ON T1.SK_REGION  = T5.SK_REGION
   AND T5.P_DT = '${p_end_dt}'
 WHERE T1.DK_REGION_TREE = '01' 
   AND T1.EFFECTIVE_FROM <= '${p_end_dt}'
   AND T1.EFFECTIVE_TO >= '${p_end_dt}'
   AND T1.P_DT = '${p_end_dt}'
;
"
