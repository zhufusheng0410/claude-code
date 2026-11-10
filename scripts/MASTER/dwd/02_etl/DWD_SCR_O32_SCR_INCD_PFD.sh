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
-- ** 描述:O32业务证券内码
-- ** 创建者:auto
-- ** 创建日期:2023-05-24
-- ** 修改日志:
-- ** 2023-05-24，auto，新建
-- ** 目标表：DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD  O32业务证券内码
-- ** 源表：  ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD-指令证券表
-- **         ODS_XDAY_O32.ODS_O32_THGMORTAGAGE_PFD-在途回购质押债券表
-- **         ODS_XDAY_O32.ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD-银行间指令质押信息表
-- **         ODS_XDAY_O32.ODS_O32_TDEALHGMORTAGAGE_PTD-银行间成交回报回购质押表
-- **         ODS_XDAY_O32.ODS_O32_TMARGINBONDS_PTD-银行间交易质押券/保证券/保证金表
-- **         ODS_XDAY_O32.ODS_O32_TUNITSTOCK_PFD 投资单元证券表
-- **************************************************************************
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;

set hive.strict.checks.type.safety=false;
set mapreduce.job.reduces=2;

TRUNCATE TABLE   DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP;
INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP  
SELECT  
       T1.SCR_INCD                                                                               AS SCR_INCD    --证券内码
     , T1.SSYS                                                                                   AS SSYS        --源系统
     , T1.SRC_TAB                                                                                AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD  T1 --指令证券表
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
;
   
   
INSERT INTO DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP
SELECT DISTINCT 
       T1.VC_INTER_CODE                                                                          AS SCR_INCD    --证券内码
     , 'O32'                                                                                     AS SSYS        --源系统
     , 'ODS_O32_TINSTRUCTIONSTOCK_PTD'                                                           AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD  T1 --指令证券表
  LEFT JOIN DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP T2 --O32业务证券内码
    ON T1.VC_INTER_CODE = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
;

INSERT INTO DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP
SELECT DISTINCT 
       T1.VC_INTER_CODE                                                                          AS SCR_INCD    --证券内码
     , 'O32'                                                                                     AS SSYS        --源系统
     , 'ODS_O32_THGMORTAGAGE_PFD'                                                                AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_O32.ODS_O32_THGMORTAGAGE_PFD  T1 --在途回购质押债券表
  LEFT JOIN DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP T2 --O32业务证券内码
    ON T1.VC_INTER_CODE = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
;

INSERT INTO DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP
SELECT DISTINCT 
       T1.VC_INTER_CODE                                                                          AS SCR_INCD    --证券内码
     , 'O32'                                                                                     AS SSYS        --源系统
     , 'ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD'                                                     AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD  T1 --银行间指令质押信息表
  LEFT JOIN DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP T2 --O32业务证券内码
    ON T1.VC_INTER_CODE = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
;

INSERT INTO DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP
SELECT DISTINCT 
       T1.VC_INTER_CODE                                                                          AS SCR_INCD    --证券内码
     , 'O32'                                                                                     AS SSYS        --源系统
     , 'ODS_O32_TDEALHGMORTAGAGE_PTD'                                                            AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TDEALHGMORTAGAGE_PTD  T1 --银行间成交回报回购质押表
  LEFT JOIN DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP T2 --O32业务证券内码
    ON T1.VC_INTER_CODE = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
;

INSERT INTO DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP
SELECT DISTINCT 
       T3.VC_INTER_CODE                                                                         AS SCR_INCD    --证券内码
     , 'O32'                                                                                     AS SSYS        --源系统
     , 'ODS_O32_TMARGINBONDS_PTD'                                                                AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TMARGINBONDS_PTD  T1 --银行间交易质押券/保证券/保证金表
 INNER JOIN ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD T3  --证券信息表
    ON T1.VC_REPORT_CODE  = T3.VC_REPORT_CODE
   AND T3.P_DT = '${p_end_dt}' 
  LEFT JOIN DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP T2 --O32业务证券内码
    ON T3.VC_INTER_CODE = T2.SCR_INCD  
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
;


INSERT INTO DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP
SELECT DISTINCT 
       T1.VC_INTER_CODE                                                                          AS SCR_INCD    --证券内码
     , 'O32'                                                                                     AS SSYS        --源系统
     , 'ODS_O32_TUNITSTOCK_PFD'                                                                  AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TUNITSTOCK_PFD  T1 --投资单元证券表
  LEFT JOIN DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP T2 --O32业务证券内码
    ON T1.VC_INTER_CODE = T2.SCR_INCD  
 WHERE T1.P_DT BETWEEN   '${p_start_dt}'  AND   '${p_end_dt}' 
   AND T2.SCR_INCD IS NULL
;



INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT  
       T1.SCR_INCD                                                                               AS SCR_INCD    --证券内码
     , T1.SSYS                                                                                   AS SSYS        --源系统
     , T1.SRC_TAB                                                                                AS SRC_TAB     --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS LD_TIME     --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                  AS MODIFY_TIME --修改时间
  FROM DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD_TMP T1
;
"
