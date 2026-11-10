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
-- ** 描述:产品预警历史信息
-- ** 创建者:auto
-- ** 创建日期:2023-07-04
-- ** 修改日志:
-- ** 2023-07-04，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD  产品预警历史信息
-- ** 源表：  ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD 专户手工信息
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
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

--临时表1 分别插入预警线阈值 1，止损线阈值 2
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP1 PARTITION(P_DT = '${p_end_dt}') 
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , '1'                                                                           AS THD_CATG_CODE                           --阈值类别代码
     , CASE WHEN T1.WARN_LINE_TYPE IS NOT NULL AND T1.WARN_LINE_TYPE <> '-'
            THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.WARN_LINE_TYPE)) 
       END                                                                           AS THD_TYPE_CODE                           --阈值类型代码
     , T1.WARN_LINE                                                                  AS THD                                     --阈值
     , CASE WHEN SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8) IN ('20991231','99990101') THEN 
              '29991231'
            ELSE
              SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8)
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8) IN ('20991231','99990101') THEN 
              '29991231'
            WHEN LENGTH(REGEXP_EXTRACT(T1.EXPE_END_DATE,'[\u4e00-\u9fff]+',0)) = 0 THEN --不含中文，纯日期
              SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8)
            ELSE --含中文，直接取中文内容
              T1.EXPE_END_DATE
       END                                                                           AS END_DATE                                --结束日期
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'MANUAL'                                                                      AS SSYS                                    --源系统
     , 'ODS_MANUAL_SPEBA_MANUAL_INFO_PFD'                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD T1  --专户手工信息
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.PROD_CODE = T2.PROD_INCD
   AND T2.SSYS = 'MANUAL'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'MANUAL'
   AND T3.SRC_DICT_CLS_CD = 'WARN_LINE_TYPE'
   AND T1.WARN_LINE_TYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND REPLACE(T1.WARN_LINE,'-',0) <> 0
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP1 PARTITION(P_DT = '${p_end_dt}') 
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , '2'                                                                           AS THD_CATG_CODE                           --阈值类别代码
     , CASE WHEN T1.WARN_LINE_TYPE IS NOT NULL AND T1.WARN_LINE_TYPE <> '-'
            THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.WARN_LINE_TYPE)) 
       END                                                                           AS THD_TYPE_CODE                           --阈值类型代码
     , T1.STOP_LINE                                                                  AS THD                                     --阈值
     , CASE WHEN SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8) IN ('20991231','99990101') THEN 
              '29991231'
            ELSE
              SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8)
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8) IN ('20991231','99990101') THEN 
              '29991231'
            WHEN LENGTH(REGEXP_EXTRACT(T1.EXPE_END_DATE,'[\u4e00-\u9fff]+',0)) = 0 THEN --不含中文，纯日期
              SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8)
            ELSE --含中文，直接取中文内容
              T1.EXPE_END_DATE
       END                                                                           AS END_DATE                                --结束日期
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'MANUAL'                                                                      AS SSYS                                    --源系统
     , 'ODS_MANUAL_SPEBA_MANUAL_INFO_PFD'                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD T1  --专户手工信息
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.PROD_CODE = T2.PROD_INCD
   AND T2.SSYS = 'MANUAL'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'MANUAL'
   AND T3.SRC_DICT_CLS_CD = 'WARN_LINE_TYPE'
   AND T1.WARN_LINE_TYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND REPLACE(T1.STOP_LINE,'-',0) <> 0
;

--临时表2
--新增数据
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP2 PARTITION(P_DT = '${p_end_dt}') 
SELECT T1.PROD_NUM
     , T1.PROD_CODE
     , T1.THD_CATG_CODE
     , T1.THD_TYPE_CODE
     , T1.THD
     , T1.P_DT
     , T1.END_DATE
     , T1.VALID_FLAG
     , T1.SSYS
     , T1.SRC_TAB
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP1 T1
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD T2
    ON T1.PROD_NUM = T2.PROD_NUM
   AND T1.THD_CATG_CODE = T2.THD_CATG_CODE
   AND T1.THD = T2.THD
   AND T1.VALID_FLAG = '1'
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
 WHERE T1.P_DT = '${p_end_dt}'
   AND T2.PROD_NUM IS NULL
 ;

--历史数据
INSERT INTO DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP2 PARTITION(P_DT = '${p_end_dt}') 
SELECT T1.PROD_NUM
     , T1.PROD_CODE
     , T1.THD_CATG_CODE
     , T1.THD_TYPE_CODE
     , T1.THD
     , T1.ST_DATE
     , T1.END_DATE
     , T1.VALID_FLAG
     , T1.SSYS
     , T1.SRC_TAB
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD T1
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
 ;

--正式表
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD PARTITION(P_DT = '${p_end_dt}') 
SELECT T1.PROD_NUM
     , T1.PROD_CODE
     , T1.THD_CATG_CODE
     , T1.THD_TYPE_CODE
     , T1.THD
     , T1.ST_DATE
     , COALESCE(DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(
       LEAD(T1.ST_DATE,1) OVER(PARTITION BY T1.PROD_NUM,T1.THD_CATG_CODE
       ORDER BY T1.ST_DATE),'yyyyMMdd'))),1),'yyyyMMdd'),
       T1.END_DATE)                                                                  AS END_DATE                                --结束日期
     , CASE WHEN LEAD(T1.VALID_FLAG,1) OVER(PARTITION BY T1.PROD_NUM,T1.THD_CATG_CODE
                 ORDER BY T1.ST_DATE) IS NOT NULL THEN 
              '0'
            ELSE
              '1'
       END                                                                           AS VALID_FLAG                              --有效标志
     , T1.SSYS
     , T1.SRC_TAB
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP2 T1
 WHERE T1.P_DT = '${p_end_dt}'
 ;
 
--清空历史数据
TRUNCATE TABLE DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP1;
TRUNCATE TABLE DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD_TMP2;

"
