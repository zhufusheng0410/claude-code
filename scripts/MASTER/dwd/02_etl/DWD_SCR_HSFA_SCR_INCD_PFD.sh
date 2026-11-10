#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:资讯
-- ** 描述:HFA业务证券内码
-- ** 创建者:auto
-- ** 创建日期:2023-05-24
-- ** 修改日志:
-- ** 2023-05-24，auto，新建
-- ** 目标表：DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP  HFA业务证券内码
-- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD  估值表
-- **         ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERS_PTD  凭证子表
-- **         ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD  清算库
-- **         ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD  回购交易表
-- **         ODS_XDAY_HSFA.ODS_HSFA_THGJY_BDQ_PFD  债券质押券信息
-- **         ODS_XDAY_HSFA.ODS_HSFA_TGPZYHG_ZYQ_PFD 股票质押券信息
-- **************************************************************************

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
set mapreduce.job.reduces=2;
TRUNCATE  TABLE  DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP;
INSERT OVERWRITE TABLE  DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP
SELECT DISTINCT 
       T1.SCR_INCD                                                                               AS SCR_INCD    --证券内码
     , T1.L_ZQLB                                                                                                --证券类别
     , T1.L_SCLB                                                                                                --市场类别   
     , T1.VC_ZQDM                                                                                               --证券代码  
     , T1.VC_ZQJC                                                                                               --证券简称 
     , T1.SSYS                                                                                   AS SSYS        --源系统
     , T1.SRC_TAB                                                                                AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD  T1 -- HFA业务证券内码
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
;


INSERT INTO DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP 
SELECT DISTINCT 
       T1.L_ZQNM                                                                                  AS SCR_INCD    --证券内码
     , T1.L_ZQLB                                                                                                 --证券类别
     , T1.L_SCLB                                                                                                 --市场类别   
     , T1.VC_ZQDM                                                                                                --证券代码  
     , T1.VC_KMMC                                                                                                --证券简称 
     , 'HSFA'                                                                                     AS SSYS        --源系统
     , 'ODS_HSFA_TTMP_H_GZB_PTD'                                                                  AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD  T1 --估值表
  LEFT JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP T2 --HFA业务证券内码
    ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
   AND T1.L_ZQNM IS NOT NULL
;

INSERT INTO DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP 
SELECT DISTINCT 
       T1.L_ZQNM                                                                                  AS SCR_INCD    --证券内码
     ,  NULL                                                                                                     --证券类别
     ,  NULL                                                                                                     --市场类别   
     ,  NULL                                                                                                     --证券代码  
     ,  NULL                                                                                                     --证券简称 
     , 'HSFA'                                                                                     AS SSYS        --源系统
     , 'ODS_HSFA_TVOUCHERS_PTD'                                                                   AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERS_PTD  T1 --凭证子表
  LEFT JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP T2 -- HFA业务证券内码
    ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
   AND T1.L_ZQNM IS NOT NULL
;

INSERT INTO DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP 
SELECT DISTINCT 
       T1.L_ZQNM                                                                                  AS SCR_INCD    --证券内码
     ,  NULL                                                                                                     --证券类别
     ,  NULL                                                                                                     --市场类别   
     ,  NULL                                                                                                     --证券代码  
     ,  NULL                                                                                                     --证券简称 
     , 'HSFA'                                                                                     AS SSYS        --源系统
     , 'ODS_HSFA_TQSK_PTD'                                                                        AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD  T1 --清算库
  LEFT JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP T2 --HFA业务证券内码
    ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
   AND T1.L_ZQNM IS NOT NULL
;


INSERT INTO DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP 
SELECT DISTINCT 
       T1.L_ZQNM                                                                                  AS SCR_INCD    --证券内码
     ,  NULL                                                                                                     --证券类别
     ,  NULL                                                                                                     --市场类别   
     ,  NULL                                                                                                     --证券代码  
     ,  NULL                                                                                                     --证券简称 
     , 'HSFA'                                                                                     AS SSYS        --源系统
     , 'ODS_HSFA_THGJY_PTD'                                                                       AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD  T1 --回购交易表
  LEFT JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP T2 --FA业务证券内码
    ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
   AND T1.L_ZQNM IS NOT NULL
;


INSERT INTO DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP 
SELECT DISTINCT 
       T1.L_ZQNM                                                                                  AS SCR_INCD    --证券内码
     ,  NULL                                                                                                     --证券类别
     ,  NULL                                                                                                     --市场类别   
     ,  NULL                                                                                                     --证券代码  
     ,  NULL                                                                                                     --证券简称 
     , 'HSFA'                                                                                     AS SSYS        --源系统
     , 'ODS_HSFA_THGJY_BDQ_PFD'                                                                   AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_THGJY_BDQ_PFD  T1 --债券质押券信息
  LEFT JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP T2 --FA业务证券内码
    ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
   AND T1.L_ZQNM IS NOT NULL
;



INSERT INTO DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP 
SELECT DISTINCT 
       T1.L_ZQNM                                                                                  AS SCR_INCD    --证券内码
     ,  NULL                                                                                                     --证券类别
     ,  NULL                                                                                                     --市场类别   
     ,  NULL                                                                                                     --证券代码  
     ,  NULL                                                                                                     --证券简称 
     , 'HSFA'                                                                                     AS SSYS        --源系统
     , 'ODS_HSFA_TGPZYHG_ZYQ_PFD'                                                                 AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                   AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TGPZYHG_ZYQ_PFD  T1 --股票质押券信息
  LEFT JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP T2 --FA业务证券内码
    ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
   AND T1.L_ZQNM IS NOT NULL
;


INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT  
       T1.SCR_INCD                                                                               AS SCR_INCD    --证券内码
     , T1.L_ZQLB                                                                                                --证券类别
     , T1.L_SCLB                                                                                                --市场类别   
     , T1.VC_ZQDM                                                                                               --证券代码  
     , T1.VC_ZQJC                                                                                               --证券简称 
     , T1.SSYS                                                                                   AS SSYS        --源系统
     , T1.SRC_TAB                                                                                AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM (SELECT  T1.SCR_INCD                                                                             AS SCR_INCD    --证券内码
             , T1.L_ZQLB                                                                                                --证券类别
             , T1.L_SCLB                                                                                                --市场类别   
             , T1.VC_ZQDM                                                                                               --证券代码  
             , T1.VC_ZQJC                                                                                               --证券简称 
             , T1.SSYS                                                                                   AS SSYS        --源系统
             , T1.SRC_TAB                                                                                AS SRC_TAB     --源表
             , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
             , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
             , ROW_NUMBER() OVER(PARTITION BY SCR_INCD ORDER BY VC_ZQDM,VC_ZQJC) RN 
          FROM DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD_TMP  T1 --FA业务证券内码
         WHERE T1.SCR_INCD <>'-1'
           AND T1.L_SCLB  IS NOT NULL
           AND T1.VC_ZQDM IS NOT NULL
           AND T1.L_ZQLB IS NOT NULL
        )T1
 WHERE T1.RN = 1
;
"
