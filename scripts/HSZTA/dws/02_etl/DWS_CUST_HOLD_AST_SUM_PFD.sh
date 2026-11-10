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
-- ** 主题:资产
-- ** 描述:客户持有资产汇总
-- ** 创建者:auto
-- ** 创建日期:2023-07-03
-- ** 修改日志:
-- ** 2023-07-03，auto，新建
-- ** 目标表：DWSXDAY.DWS_CUST_HOLD_AST_SUM_PFD  客户持有资产汇总
-- ** 源表：  DWDXDAY.DWS_CUST_HOLD_DETAIL_PTD 客户保有明细
-- **         DWS_PROD_HOLD_DETAIL_PTD 产品保有明细
-- **         DWDXDAY.DWD_PTY_CUST_INFO_PFD  --客户信息表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO 标准字典分类枚举信息
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
set hive.exec.reducers.bytes.per.reducer=10240000000; 
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWSXDAY.DWS_CUST_HOLD_AST_SUM_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.HLDP_DATE                                                                                 AS BUSIN_DATE                              --业务日期
     , T1.CUST_NUM                                                                                  AS CUST_NUM                                --客户编码
     , T1.PROD_NUM                                                                                  AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                                 AS PROD_CODE                               --产品代码
     , T3.CUST_NAME                                                                                 AS CUST_NAME                               --客户名称
     , T1.PROD_NAME                                                                                 AS PROD_NAME                               --产品名称
     , T1.CUST_TYPE_CODE                                                                            AS CUST_TYPE_CODE                          --客户类型代码
     , T1.CUST_TYPE_NAME                                                                            AS CUST_TYPE_NAME                          --客户类型名称
     , T1.TOTALSHARES                                                                               AS CUST_HOLD_SHARE                         --客户持有份额
     , T2.HOLD_SHARE                                                                                AS PROD_HOLD_SHARE                         --产品持有份额
     , ROUND(T1.TOTALSHARES/T2.HOLD_SHARE*100,4)                                                      AS CUST_HOLD_SHARE_RATIO                   --客户持有份额占比%
     , ROW_NUMBER()OVER(PARTITION BY T1.PROD_NUM, T1.CUST_TYPE_CODE ORDER BY  T1.TOTALSHARES DESC)  AS RANK                                    --排名
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                     AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                     AS MODIFY_TIME                             --修改时间
  FROM (SELECT T1.HLDP_DATE
             , T1.CUST_NUM
             , T1.CUST_TYPE_CODE
             , T1.CUST_TYPE_NAME
             , T1.PROD_NUM
             , T1.PROD_CODE
             , T1.PROD_NAME
             , SUM(T1.HOLD_SHARE) AS TOTALSHARES 
          FROM DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD T1 --客户保有明细
         WHERE T1.P_DT = '${p_end_dt}' 
           AND T1.HOLD_SHARE <> 0 
         GROUP BY T1.HLDP_DATE, T1.CUST_NUM, T1.CUST_TYPE_CODE, T1.CUST_TYPE_NAME, T1.PROD_NUM, T1.PROD_CODE, T1.PROD_NAME
       )T1
  LEFT JOIN DWSXDAY.DWS_PROD_HOLD_DETAIL_PTD T2 --产品保有明细
    ON T1.PROD_CODE = T2.PROD_CODE
   AND T1.HLDP_DATE = T2.BUSIN_DATE
   AND T2.P_DT = '${p_end_dt}' 
  LEFT JOIN DWDXDAY.DWD_PTY_CUST_INFO_PFD  T3 --客户信息表
    ON T1.CUST_NUM = T3.CUST_NUM
  ;
"
