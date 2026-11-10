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
-- ** 描述:产品套账关系
-- ** 创建者:auto
-- ** 创建日期:2023-05-12
-- ** 修改日志:
-- ** 2023-05-12，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_SFAC_RELA_PFD  产品套账关系
-- ** 源表：  DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD 帐套产品基本信息
-- **         DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD 产品基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_SFAC_RELA_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.SFAC_NUM                                                                   AS SFAC_NUM                                --帐套编码
     , NVL(T3.PROD_NUM,T2.PROD_NUM)                                                  AS PROD_NUM                                --产品编码
     , NVL(T3.PROD_CODE,T2.PROD_CODE)                                                AS PROD_CODE                               --产品代码
     , '19000101'                                                                    AS ST_DATE                                 --开始日期
     , '29991231'                                                                    AS END_DATE                                --结束日期
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'DWDXDAY'                                                                     AS SSYS                                    --源系统
     , 'DWD_PROD_SFAC_PROD_BASIC_INFO_PFD'                                           AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T1  --帐套产品基本信息
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T2 --产品基本信息
    ON T1.PROD_CODE = T2.PROD_CODE
   AND T2.VALID_FLAG = '1'
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息
    ON T1.PROD_CODE = T3.MAIN_PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = '${p_end_dt}'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T1.VALID_FLAG = '1'
;"
