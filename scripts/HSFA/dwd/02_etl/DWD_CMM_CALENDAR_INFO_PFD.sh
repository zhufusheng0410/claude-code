#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题: 公共
-- ** 描述: 日历表
-- ** 创建者 :VHHV
-- ** 创建日期: 20230621
-- ** 目标表：DWDXDAY.DWD_CMM_CALENDAR_INFO_PFD    日历表
-- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TTRADEDATE_PFD     日历表
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
set mapreduce.job.reduces=3;

INSERT OVERWRITE TABLE DWDXDAY.DWD_CMM_CALENDAR_INFO_PFD PARTITION (P_DT = '${p_end_dt}' )
SELECT A1.L_DATE                                                                                  AS \`DATE\`         
   ,  CASE WHEN A1.C_TRADE_DATE = '2' THEN '0'                         
           ELSE A1.C_TRADE_DATE   END                                                             AS IS_TRADE_DATE
   , A3.STD_DICT_CLS_CD_VAL                                                                       AS TRAN_MKT     
   , MAX (A2.L_DATE )                                                                             AS LASTEST_TRADE_DATE
   , SUBSTR(A1.L_DATE,1,4)                                                                        AS YEAR
   , CASE WHEN SUBSTR(A1.L_DATE,5,2) IN ('01','02','03') THEN '1'
         WHEN SUBSTR(A1.L_DATE,5,2) IN ('04','05','06') THEN '2'
         WHEN SUBSTR(A1.L_DATE,5,2) IN ('07','08','09') THEN '3'
         ELSE '4' 
         END                                                                                  AS QUARTER
   , SUBSTR(A1.L_DATE,5,2)                                                                        AS MTH
   , DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST (A1.L_DATE AS STRING),'yyyyMMdd'))),1),'yyyyMMdd')    AS LAST_DATE
   , CONCAT (SUBSTR(A1.L_DATE,1,4),'0101')                                                        AS YEAR_BEG_DATE 
   , CASE WHEN SUBSTR(A1.L_DATE,5,2) IN ('01','02','03') THEN CONCAT (SUBSTR(A1.L_DATE,1,4),'0101')
         WHEN SUBSTR(A1.L_DATE,5,2) IN ('04','05','06') THEN CONCAT (SUBSTR(A1.L_DATE,1,4),'0401')
         WHEN SUBSTR(A1.L_DATE,5,2) IN ('07','08','09') THEN CONCAT (SUBSTR(A1.L_DATE,1,4),'0701')
         ELSE CONCAT (SUBSTR(A1.L_DATE,1,4),'1001')
         END                                                                                 AS QUR_BEG_DATE
   , CONCAT (SUBSTR(A1.L_DATE,1,6),'01')                                                         AS MTH_BEG_DATE
   , CONCAT (SUBSTR(A1.L_DATE,1,4),'1231')                                                       AS YEAR_END_DATE
   , CASE WHEN SUBSTR(A1.L_DATE,5,2) IN ('01','02','03') THEN CONCAT (SUBSTR(A1.L_DATE,1,4),'0331')
         WHEN SUBSTR(A1.L_DATE,5,2) IN ('04','05','06') THEN CONCAT (SUBSTR(A1.L_DATE,1,4),'0630')
         WHEN SUBSTR(A1.L_DATE,5,2) IN ('07','08','09') THEN CONCAT (SUBSTR(A1.L_DATE,1,4),'0930')
         ELSE CONCAT (SUBSTR(A1.L_DATE,1,4),'1231')
         END                                                                                 AS QUR_END_DATE 
   , CAST(REPLACE(LAST_DAY(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(A1.L_DATE AS STRING),'yyyyMMdd'))),'-','') AS STRING ) AS MTH_END_DATE
   , 'HSFA'
   , 'ODS_HSFA_TTRADEDATE_PFD'
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')
     FROM ODS_XDAY_HSFA.ODS_HSFA_TTRADEDATE_PFD A1   --日历表
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3     --标准字段表
       ON A1.C_DATE_TYPE = A3.SRC_DICT_CLS_CDVAL 
      AND A3.SSYS= 'HSFA'
      AND A3.SRC_DICT_CLS_CD= 'C_DATE_TYPE' 
      AND A3.VALID_FLAG='1'
     LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TTRADEDATE_PFD A2 --日历表
       ON A1.L_DATE >= A2.L_DATE 
      AND A1.C_DATE_TYPE = A2.C_DATE_TYPE
      AND A2.C_TRADE_DATE=1
      AND A2.P_DT = '${p_end_dt}'
     WHERE  A1.P_DT = '${p_end_dt}'
     GROUP BY A1.L_DATE,
              A1.C_TRADE_DATE ,
              A3.STD_DICT_CLS_CD_VAL;
"
