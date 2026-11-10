#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
    set hive.strict.checks.type.safety=false;
-- **************************************************************************
-- ** 主题:渠道
-- ** 描述:渠道保有明细
-- ** 创建者:auto
-- ** 创建日期:2023-08-10
-- ** 修改日志:
-- ** 2023-08-10，auto，新建
-- ** 目标表：DWSXDAY.DWS_CUST_FST_TRAN_BTCH_PFD  客户首次交易网点
-- ** 源表：  DWSXDAY.DWS_TRAN_MKT_TRAN_CNFM_PTD 市场交易确认
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

INSERT OVERWRITE TABLE DWSXDAY.DWS_CUST_FST_TRAN_BTCH_PFD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT T1.P_DT      AS BUSIN_DATE              --业务日期
     , CUST_NUM               AS CUST_NUM                --客户编码
     , FUND_ACCO              AS FUND_ACCO               --基金账号
     , TRAN_ACCO              AS TRAN_ACCO               --交易账号
     , CUST_NAME              AS CUST_NAME               --客户名称
     , BUSIN_TYPE_CODE        AS FST_BUSIN_TYPE_CODE     --首次业务类型代码
     , BUSIN_TYPE_NAME        AS FST_BUSIN_TYPE_NAME     --首次业务类型名称
     , TRAN_CHNL_NUM          AS FST_TRAN_CHNL_NUM       --首次交易渠道编码
     , AGENCY_INCD            AS FST_TRAN_CHNL_INCD      --首次交易渠道内码
     , AFFI_BTCH_NUM          AS FST_TRAN_BTCH_NUM       --首次交易网点编码
     , AFFI_BTCH_NAME         AS FST_TRAN_BTCH_NAME      --首次交易网点名称
     , AFFI_PROVINCE_CODE     AS FST_TRAN_PROVINCE_CODE  --首次交易省份代码
     , AFFI_PROVINCE_NAME     AS FST_TRAN_PROVINCE_NAME  --首次交易省份名称
     , AFFI_CITY_CODE         AS FST_TRAN_CITY_CODE      --首次交易城市代码
     , AFFI_CITY_NAME         AS FST_TRAN_CITY_NAME      --首次交易城市名称
     , AFFI_AREA_NUM          AS FST_AFFI_AREA_NUM       --首次交易区域代码
     , CNFM_DATE              AS FST_TRAN_DATE           --首次交易日期
 FROM DWSXDAY.DWS_TRAN_MKT_TRAN_CNFM_PTD T1 --市场交易确认
WHERE T1.P_DT =  '${p_end_dt}'
  AND T1.DEAL_STAT_CODE = '02' --处理成功
;

INSERT OVERWRITE TABLE DWSXDAY.DWS_CUST_FST_TRAN_BTCH_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.BUSIN_DATE              --业务日期
     , T1.CUST_NUM                --客户编码
     , T1.FUND_ACCO               --基金账号
     , T1.TRAN_ACCO               --交易账号
     , T1.CUST_NAME               --客户名称
     , T1.FST_BUSIN_TYPE_CODE     --首次业务类型代码
     , T1.FST_BUSIN_TYPE_NAME     --首次业务类型名称
     , T1.FST_TRAN_CHNL_NUM       --首次交易渠道编码
     , T1.FST_TRAN_CHNL_INCD      --首次交易渠道内码
     , T1.FST_TRAN_BTCH_NUM       --首次交易网点编码
     , T1.FST_TRAN_BTCH_NAME      --首次交易网点名称
     , T1.FST_TRAN_PROVINCE_CODE  --首次交易省份代码
     , T1.FST_TRAN_PROVINCE_NAME  --首次交易省份名称
     , T1.FST_TRAN_CITY_CODE      --首次交易城市代码
     , T1.FST_TRAN_CITY_NAME      --首次交易城市名称
     , T1.FST_AFFI_AREA_NUM       -- 首次交易区域代码
     , T1.FST_TRAN_DATE           --首次交易日期
  FROM DWSXDAY.DWS_CUST_FST_TRAN_BTCH_PFD T1 
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
 ;

INSERT INTO DWSXDAY.DWS_CUST_FST_TRAN_BTCH_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.BUSIN_DATE              --业务日期
     , T1.CUST_NUM                --客户编码
     , T1.FUND_ACCO               --基金账号
     , T1.TRAN_ACCO               --交易账号
     , T1.CUST_NAME               --客户名称
     , T1.FST_BUSIN_TYPE_CODE     --首次业务类型代码
     , T1.FST_BUSIN_TYPE_NAME     --首次业务类型名称
     , T1.FST_TRAN_CHNL_NUM       --首次交易渠道编码
     , T1.FST_TRAN_CHNL_INCD      --首次交易渠道内码
     , T1.FST_TRAN_BTCH_NUM       --首次交易网点编码
     , T1.FST_TRAN_BTCH_NAME      --首次交易网点名称
     , T1.FST_TRAN_PROVINCE_CODE  --首次交易省份代码
     , T1.FST_TRAN_PROVINCE_NAME  --首次交易省份名称
     , T1.FST_TRAN_CITY_CODE      --首次交易城市代码
     , T1.FST_TRAN_CITY_NAME      --首次交易城市名称
     , T1.FST_AFFI_AREA_NUM       -- 首次交易区域代码
     , T1.FST_TRAN_DATE           --首次交易日期
  FROM DWSXDAY.DWS_CUST_FST_TRAN_BTCH_PFD_TMP T1
  LEFT JOIN DWSXDAY.DWS_CUST_FST_TRAN_BTCH_PFD T2
    ON T1.FUND_ACCO = T2.FUND_ACCO
   AND T1.TRAN_ACCO = T2.TRAN_ACCO
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
 WHERE T2.FUND_ACCO IS NULL
 ;
"
