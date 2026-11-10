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
-- ** 创建者 : zhufs
-- ** 创建日期: 20230425
-- ** 修改日志:
-- ** 20230425，zhufs，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDINFO_PFD 基金信息表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD 基金信息表
-- **         ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD 分级基金信息表
-- **         ODS_XDAY_OUTS.ODS_OUTS_SPEBA_MANUAL_INFO 专户手工信息
-- **         ODS_XDAY_HSDS.ODS_HSDS_TFUNDINFO_PFD 基金基本信息表
-- **         ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD 基金基本信息表
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD 产品基本信息
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
--**          DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP 产品编码映射临时表
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


INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP
SELECT
       COALESCE(T2.PROD_NUM,T3.PROD_NUM)                                        AS PROD_NUM                --产品编码
     , T1.C_FUNDCODE                                                            AS PROD_INCD               --产品内码
     , T1.C_FUNDCODE                                                            AS PROD_CODE               --产品代码
     , T1.C_FUNDSHORTNAME                                                       AS CSNAME                  --中文简称
     , CASE
         WHEN T4.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_FUNDTYPE)
         ELSE
          T4.STD_DICT_CLS_CD_VAL
       END                                                                      AS PROD_CATG_CODE          --产品类型代码
     , '19000101'                                                               AS ST_DATE                 --开始日期
     , '29991231'                                                               AS END_DATE                --结束日期
     , '1'                                                                      AS VALID_FLAG              --有效标志
     , 'HSZTA'                                                                  AS SSYS                    --源系统
     , 'ODS_HSZTA_TFUNDINFO_PFD'                                                AS SRC_TAB                 --源表
     , CASE
         WHEN T2.PROD_INCD IS NOT NULL OR T3.PROD_CODE IS NOT NULL THEN
          '1'
         ELSE
          '0'
       END                                                                      AS IS_EXIS                 --是否存在
     , '1'                                                                      AS PRIO                    --优先级
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDINFO_PFD  T1 --基金信息表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射 
    ON T1.C_FUNDCODE = T2.PROD_INCD 
   AND T2.SSYS = 'HSZTA' 
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1'  --有效标志
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息 
    ON T1.C_FUNDCODE = T3.PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')  
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'                                               
   AND T4.SRC_DICT_CLS_CD = 'C_FUNDTYPE'               -- 源字典分类
   AND T1.C_FUNDTYPE  = T4.SRC_DICT_CLS_CDVAL        -- 源字典分类码值
   AND T4.VALID_FLAG = '1'                                        -- 有效标志
 WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP
SELECT 
       COALESCE(T2.PROD_NUM,T3.PROD_NUM)                                        AS PROD_NUM                --产品编码
     , T1.C_FUNDCODE                                                            AS PROD_INCD               --产品内码
     , T1.C_FUNDCODE                                                            AS PROD_CODE               --产品代码
     , T1.C_FUNDSHORTNAME                                                       AS CSNAME                  --中文简称
     , 'GM'                                                                     AS PROD_CATG_CODE          --产品类型代码
     , '19000101'                                                               AS ST_DATE                 --开始日期
     , '29991231'                                                               AS END_DATE                --结束日期
     , '1'                                                                      AS VALID_FLAG              --有效标志
     , 'HSFTA'                                                                  AS SSYS                    --源系统
     , 'ODS_HSFTA_TFUNDINFO_PFD'                                                AS SRC_TAB                 --源表
     , CASE
         WHEN T2.PROD_INCD IS NOT NULL OR T3.PROD_CODE IS NOT NULL THEN
          '1'
         ELSE
          '0'
       END                                                                      AS IS_EXIS                 --是否存在
     , '2'                                                                      AS PRIO                    --优先级
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD      T1 --基金信息表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD     T2 --产品编码映射 
    ON T1.C_FUNDCODE = T2.PROD_INCD 
   AND T2.SSYS = 'HSFTA' 
   AND T2.ST_DATE <= '${p_end_dt}' 
   AND T2.END_DATE >= '${p_end_dt}' 
   AND T2.VALID_FLAG = '1'  --有效标志
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息
    ON T1.C_FUNDCODE = T3.PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd') 
 WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP
SELECT 
       COALESCE(T2.PROD_NUM,T3.PROD_NUM)                                        AS PROD_NUM                --产品编码
     , T1.VC_FJJJDM                                                             AS PROD_INCD               --产品内码
     , T1.VC_FJJJDM                                                             AS PROD_CODE               --产品代码
     , T1.VC_FJJJMC                                                             AS CSNAME                  --分级基金名称
     , 'GM'                                                                     AS PROD_CATG_CODE          --产品类型代码
     , '19000101'                                                               AS ST_DATE                 --开始日期
     , '29991231'                                                               AS END_DATE                --结束日期
     , '1'                                                                      AS VALID_FLAG              --有效标志
     , 'HSFA'                                                                   AS SSYS                    --源系统
     , 'ODS_HSFA_TJJXSFL_PFD'                                                   AS SRC_TAB                 --源表
     , CASE
         WHEN T2.PROD_INCD IS NOT NULL OR T3.PROD_CODE IS NOT NULL THEN
          '1'
         ELSE
          '0'
       END                                                                       AS IS_EXIS                 --是否存在
     , '3'                                                                       AS PRIO                    --优先级
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME             --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD      T1 --分级基金信息表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.VC_FJJJDM = T2.PROD_INCD 
   AND T2.SSYS = 'HSFA' 
   AND T2.ST_DATE <= '${p_end_dt}'  
   AND T2.END_DATE >= '${p_end_dt}'  
   AND T2.VALID_FLAG = '1'  --有效标志
   AND T2.SRC_TAB = 'ODS_HSFA_TJJXSFL_PFD'
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息 
    ON T1.VC_FJJJDM = T3.PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
 WHERE T1.P_DT = '${p_end_dt}'
 ;
INSERT INTO DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP
SELECT
       COALESCE(T2.PROD_NUM,T3.PROD_NUM)                                        AS PROD_NUM               --产品编码
     , T1.PROD_CODE                                                             AS PROD_INCD              --产品内码
     , T1.PROD_CODE                                                             AS PROD_CODE              --产品代码
     , T1.PROJECT_NAME                                                          AS CSNAME                 --中文简称
     , CASE
         WHEN T4.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.PROD_TYPE)
         ELSE
          T4.STD_DICT_CLS_CD_VAL
       END                                                                      AS PROD_CATG_CODE          --产品类型代码
     , '19000101'                                                               AS ST_DATE                 --开始日期
     , '29991231'                                                               AS END_DATE                --结束日期
     , '1'                                                                      AS VALID_FLAG              --有效标志
     , 'MANUAL'                                                                 AS SSYS                    --源系统
     , 'ODS_MANUAL_SPEBA_MANUAL_INFO_PFD'                                       AS SRC_TAB --源表
     , CASE
         WHEN T2.PROD_INCD IS NOT NULL OR T3.PROD_CODE IS NOT NULL THEN
          '1'
         ELSE
          '0'
       END                                                                      AS IS_EXIS                 --是否存在
     , '4'                                                                      AS PRIO                    --优先级
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME             --修改时间
  FROM ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD  T1 --专户手工信息
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD   T2 --产品编码映射 
    ON T1.PROD_CODE = T2.PROD_INCD 
   AND T2.SSYS = 'MANUAL' 
   AND T2.ST_DATE <= '${p_end_dt}' 
   AND T2.END_DATE >= '${p_end_dt}' 
   AND T2.VALID_FLAG = '1'  --有效标志
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD  T3 --产品基本信息
    ON T1.PROD_CODE = T3.PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4
    ON T4.SSYS = 'MANUAL'                                               -- 源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'PROD_TYPE'               -- 源字典分类
   AND T1.PROD_TYPE  = T4.SRC_DICT_CLS_CDVAL        -- 源字典分类码值
   AND T4.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP
SELECT 
       COALESCE(T2.PROD_NUM,T3.PROD_NUM)                                             AS PROD_NUM                                --产品编码
     , T1.VC_FUNDCODE                                                                AS PROD_INCD                               --产品内码
     , T1.VC_FUNDCODE                                                                AS PROD_CODE                               --产品代码
     , T1.VC_FUNDNAME                                                                AS CSNAME                                  --中文简称
     , NULL                                                                          AS PROD_CATG_CODE                          --产品类型代码
     , '19000101'                                                                    AS ST_DATE                                 --开始日期
     , '29991231'                                                                    AS END_DATE                                --结束日期
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'HSDS'                                                                        AS SSYS                                    --源系统
     , 'ODS_HSDS_TFUNDINFO_PFD'                                                      AS SRC_TAB                                 --源表
     , CASE
         WHEN T2.PROD_INCD IS NOT NULL OR T3.PROD_CODE IS NOT NULL THEN
          '1'
         ELSE
          '0'
       END                                                                           AS IS_EXIS                                 --是否存在
     , '5'                                                                           AS PRIO                                    --优先级
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSDS.ODS_HSDS_TFUNDINFO_PFD T1  --基金基本信息表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.VC_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSDS'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息
    ON T1.VC_FUNDCODE = T3.PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
 WHERE T1.P_DT = '${p_end_dt}'
 ;

INSERT INTO DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP
SELECT 
       COALESCE(T2.PROD_NUM,T3.PROD_NUM)                                             AS PROD_NUM                                --产品编码
     , T1.L_FUNDID                                                                   AS PROD_INCD                               --产品内码
     , T1.VC_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.VC_NAME                                                                    AS CSNAME                                  --中文简称
     , CASE WHEN T1.L_CLASS IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_CLASS)) 
       END                                                                           AS PROD_CATG_CODE                          --产品类型代码
     , '19000101'                                                                    AS ST_DATE                                 --开始日期
     , '29991231'                                                                    AS END_DATE                                --结束日期
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'HSFA'                                                                        AS SSYS                                    --源系统
     , 'ODS_HSFA_TFUNDINFO_PFD'                                                      AS SRC_TAB                                 --源表
     , CASE
         WHEN T2.PROD_INCD IS NOT NULL OR T3.PROD_CODE IS NOT NULL THEN
          '1'
         ELSE
          '0'
       END                                                                           AS IS_EXIS                                 --是否存在
     , '5'                                                                           AS PRIO                                    --优先级
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD T1  --基金基本信息表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.L_FUNDID = T2.PROD_INCD
   AND T2.SSYS = 'HSFA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.SRC_TAB = 'ODS_HSFA_TFUNDINFO_PFD'
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息
    ON T1.VC_CODE = T3.PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD T4 --分级基金信息表
    ON T1.VC_CODE = T4.VC_JJDM
   AND T4.P_DT = '${p_end_dt}'
 INNER JOIN ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD T5 --帐套信息
    ON T1.L_FUNDID = T5.L_ID
   AND T5.L_VOID = '0' --有效
   AND T5.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSFA'
   AND T6.SRC_DICT_CLS_CD = 'L_CLASS'
   AND T1.L_CLASS = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
WHERE T1.P_DT = '${p_end_dt}' 
  AND T4.VC_JJDM IS NULL
;
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}' )
SELECT CONCAT('P0',T1.PROD_CATG_CODE,RN,'0')
     , T1.PROD_INCD
     , T1.PROD_CODE
     , T1.CSNAME
     , T1.ST_DATE
     , T1.END_DATE
     , T1.VALID_FLAG
     , TRIM(T1.SSYS)
     , TRIM(T1.SRC_TAB)
     , T1.LD_TIME
     , T1.MODIFY_TIME 
  FROM (SELECT T1.PROD_NUM
             , FIRST_VALUE(T1.PROD_CATG_CODE) OVER (PARTITION BY PROD_CODE ORDER BY PRIO) AS PROD_CATG_CODE 
             , T1.PROD_INCD
             , T1.PROD_CODE
             , T1.CSNAME
             , T1.ST_DATE
             , T1.END_DATE
             , T1.VALID_FLAG
             , T1.SSYS
             , T1.SRC_TAB
             , T1.LD_TIME
             , T1.MODIFY_TIME
             , LPAD(DENSE_RANK() OVER(ORDER BY PROD_CODE)+T2.MAX_CODE,6,0)  RN
         FROM DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP T1
         LEFT JOIN (SELECT   NVL(CAST (MAX(SUBSTR(PROD_NUM,5,6)) AS DECIMAL(10)),0) AS MAX_CODE 
                     FROM  DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 
                    WHERE P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
                   )T2 
           ON 1 = 1
        WHERE T1.IS_EXIS = 0
      )T1
 UNION ALL
SELECT T1.PROD_NUM
     , T1.PROD_INCD
     , T1.PROD_CODE
     , T1.CSNAME
     , T1.ST_DATE
     , T1.END_DATE
     , T1.VALID_FLAG
     , TRIM(T1.SSYS)
     , TRIM(T1.SRC_TAB)
     , T1.LD_TIME
     , T1.MODIFY_TIME
  FROM DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD_TMP T1
 WHERE T1.IS_EXIS = 1;
"
