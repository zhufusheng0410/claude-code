#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题: 产品
-- ** 描述: 产品编码映射
-- ** 创建者 : hejl
-- ** 创建日期: 20230511
-- ** 修改日志:
-- ** 20230511，hejl，新建
-- ** 目标表：DWDXDAY.DWD_PTY_CUST_FUNDACCT_RELA_PFD 客户基金账号关系表
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD  客户信息表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD 客户信息表
-- **         DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD 客户编码映射
-- **         DWDXDAY.DWD_PTY_CUST_INFO_PFD   客户信息表
-- **************************************************************************
set hive.strict.checks.type.safety=false;
set hive.mapred.mode = nonstrict;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set hive.exec.reducers.bytes.per.reducer=10240000000; 
set mapreduce.job.reduces=3;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_FUNDACCT_RELA_PFD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT T1.C_CUSTNO  AS CUST_INCD
     , T2.CUST_NUM AS CUST_NUM
     , T1.C_FUNDACCO AS FUNDACCO
     , T3.C_CUSTTYPE AS CUST_TYPE
     , T3.CUST_NAME   AS CUST_NAME
     , 'HSZTA'  AS SSYS
     , 'ODS_HSZTA_TCUSTINFO_PFD' AS  SRC_TAB
     , T1.D_LASTMODIFY AS LAST_MODIFY_TIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS LD_TIME            --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS MODIFY_TIME        --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD T1 --客户信息表
   JOIN DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD T2 --客户编码映射
    ON T1.C_CUSTNO = T2.CUST_NO
   AND T2.ST_DATE <= '${P_BATCH_DT}'
   AND T2.END_DATE >= '${P_BATCH_DT}'
   AND T2.SRC_TAB ='ODS_HSZTA_TCUSTINFO_PFD'
   AND T2.VALID_FLAG = '1'
   AND T2.P_DT = '${P_BATCH_DT}'
  LEFT JOIN  DWDXDAY.DWD_PTY_CUST_INFO_PFD T3
    ON T2.CUST_NUM = T3.CUST_NUM
 WHERE T1.P_DT  = '${P_BATCH_DT}'
;

INSERT INTO DWDXDAY.DWD_PTY_CUST_FUNDACCT_RELA_PFD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT T1.C_CUSTNO AS  cust_incd
     , T2.CUST_NUM AS CUST_NUM
     , T1.C_FUNDACCO AS FUNDACCO
     , T3.C_CUSTTYPE AS CUST_TYPE
     , T3.CUST_NAME  AS CUST_NAME
     , 'HSFTA' AS SSYS 
     , 'ODS_HSFTA_TACCOINFO_PFD' AS  SRC_TAB
     , T1.D_LASTMODIFY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS LD_TIME            --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS MODIFY_TIME        --修改时间
  FROM  ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD T1 --客户信息表
  LEFT JOIN DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD T2 --客户编码映射
    ON T1.C_CUSTNO = T2.CUST_NO
   AND T2.ST_DATE <= '${P_BATCH_DT}'
   AND T2.END_DATE >= '${P_BATCH_DT}'
   AND T2.SRC_TAB ='ODS_HSFTA_TCUSTOMERINFO_PFD'
   AND T2.VALID_FLAG = '1'
   AND T2.P_DT = '${P_BATCH_DT}'
  LEFT JOIN  DWDXDAY.DWD_PTY_CUST_INFO_PFD T3 --客户信息表
    ON T2.CUST_NUM = T3.CUST_NUM
 WHERE T1.P_DT = '${P_BATCH_DT}';
"
