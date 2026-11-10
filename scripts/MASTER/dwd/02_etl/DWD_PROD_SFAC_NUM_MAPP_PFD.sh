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
-- ** 描述:帐套编码映射
-- ** 创建者:auto
-- ** 创建日期:2023-05-11
-- ** 修改日志:
-- ** 2023-05-11，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD  帐套编码映射
-- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD 基金信息表
-- **         ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD 帐套信息
-- **         ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD 基金信息
-- **         DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD 帐套产品基本信息
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP   标准字典码值映射
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
TRUNCATE TABLE DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD_TMP;
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD_TMP
SELECT COALESCE(T3.SFAC_NUM,T4.SFAC_NUM)                                             AS SFAC_NUM                                --帐套编码
     , T1.L_FUNDID                                                                   AS SFAC_INCD                               --帐套内码
     , T1.VC_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.VC_NAME                                                                    AS PROD_NAME                               --产品名称
     , '19000101'                                                                    AS ST_DATE                                 --开始日期
     , '29991231'                                                                    AS END_DATE                                --结束日期
     , CASE WHEN T2.L_VOID = 0 THEN 1 ELSE 0 END                                     AS VALID_FLAG                              --有效标志
     , 'HSFA'                                                                        AS SSYS                                    --源系统
     , 'ODS_HSFA_TFUNDINFO_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
     , CASE
         WHEN T3.SFAC_INCD IS NOT NULL OR T4.PROD_CODE IS NOT NULL THEN
          '1'
         ELSE
          '0'
       END                                                                           AS IS_EXIS                                 --是否存在
     , CASE
         WHEN T5.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.L_CLASS)
         ELSE
          T5.STD_DICT_CLS_CD_VAL
       END                                                                           AS PROD_CATG_CODE                           --产品类别代码
     , '1'                                                                           AS PRIO                                     --优先级
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD T1 --基金信息表
 INNER JOIN ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD T2 --帐套信息
    ON T1.L_FUNDID = T2.L_ID
   --AND T2.L_VOID = '0' --有效
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T3 --帐套编码映射
    ON T1.L_FUNDID = T3.SFAC_INCD
   AND T3.SSYS = 'HSFA'
   AND T3.ST_DATE <= '${p_end_dt}'
   AND T3.END_DATE >= '${p_end_dt}'
   --AND T3.VALID_FLAG = '1'
   AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T4 --帐套产品基本信息
    ON T1.VC_CODE = T4.PROD_CODE --产品代码
   --AND T4.VALID_FLAG = '1' --有效标志
   AND T4.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFA'
   AND T5.SRC_DICT_CLS_CD = 'L_CLASS'
   AND T1.L_CLASS = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

INSERT INTO DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD_TMP
SELECT COALESCE(T2.SFAC_NUM,T3.SFAC_NUM)                                             AS SFAC_NUM                                --帐套编码
     , T1.L_FUND_ID                                                                  AS SFAC_INCD                               --帐套内码
     , T1.VC_FUND_CODE                                                               AS PROD_CODE                               --产品代码
     , T1.VC_FUND_NAME                                                               AS PROD_NAME                               --产品名称
     , '19000101'                                                                    AS ST_DATE                                 --开始日期
     , '29991231'                                                                    AS END_DATE                                --结束日期
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TFUNDINFO_PFD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
     , CASE
         WHEN T2.SFAC_INCD IS NOT NULL OR T3.PROD_CODE IS NOT NULL THEN
          '1'
         ELSE
          '0'
       END                                                                           AS IS_EXIS                                 --是否存在
     , CASE
         WHEN T1.VC_FUND_NAME LIKE '%MOM%'  THEN 
          'MOM'
         WHEN T1.VC_FUND_NAME LIKE '%单一' OR T1.VC_FUND_NAME LIKE '%集合' THEN 
          'ZH'
       ELSE NULL 
       END                                                                           AS PROD_CATG_CODE                          --产品类别代码
     , '2'                                                                           AS PRIO                                    --优先级
  FROM ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD T1  --基金信息
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --帐套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD
   AND T2.SSYS = 'O32'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1'
   AND T2.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T3 --帐套产品基本信息
    ON T1.VC_FUND_CODE = T3.PROD_CODE --产品代码
  -- AND T3.VALID_FLAG = '1' --有效标志
   AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
 WHERE T1.P_DT = '${p_end_dt}'
;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT CONCAT('P1',T1.PROD_CATG_CODE,RN,'0') AS SFAC_NUM         --帐套编码                
     , T1.SFAC_INCD                                              --帐套内码                
     , T1.PROD_CODE                                              --产品代码                
     , T1.PROD_NAME                                              --产品名称                
     , T1.ST_DATE                                                --开始日期                
     , T1.END_DATE                                               --结束日期                
     , T1.VALID_FLAG                                             --有效标志                
     , TRIM(T1.SSYS)                                             --源系统                 
     , TRIM(T1.SRC_TAB)                                          --源表                  
     , T1.LD_TIME                                                --加载时间                
     , T1.MODIFY_TIME                                            --修改时间
  FROM (
          SELECT T1.SFAC_NUM                                                                                  --帐套编码                
               , T1.SFAC_INCD                                                                                 --帐套内码                
               , FIRST_VALUE(T1.PROD_CATG_CODE) OVER (PARTITION BY PROD_CODE ORDER BY PRIO) AS PROD_CATG_CODE --产品类别代码
               , T1.PROD_CODE                                                                                 --产品代码                
               , T1.PROD_NAME                                                                                 --产品名称                
               , T1.ST_DATE                                                                                   --开始日期                
               , T1.END_DATE                                                                                  --结束日期                
               , T1.VALID_FLAG                                                                                --有效标志                
               , T1.SSYS                                                                                      --源系统                 
               , T1.SRC_TAB                                                                                   --源表                  
               , T1.LD_TIME                                                                                   --加载时间                
               , T1.MODIFY_TIME                                                                               --修改时间 
               , LPAD(DENSE_RANK() OVER(ORDER BY PROD_CODE)+T2.MAX_SFAC_NUM,6,0)  RN
            FROM DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD_TMP T1
           LEFT JOIN (SELECT NVL(CAST (MAX(SUBSTR(T20.SFAC_NUM,-7,6)) AS DECIMAL(10)),0) AS MAX_SFAC_NUM
                        FROM DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T20
                       WHERE T20.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
                      )T2
             ON 1 = 1
          WHERE T1.IS_EXIS = '0'
      )T1
UNION ALL
SELECT DISTINCT T1.SFAC_NUM         --帐套编码                
     , T1.SFAC_INCD        --帐套内码                
     , T1.PROD_CODE        --产品代码                
     , T1.PROD_NAME        --产品名称                
     , T1.ST_DATE          --开始日期                
     , T1.END_DATE         --结束日期                
     , T1.VALID_FLAG       --有效标志                
     , TRIM(T1.SSYS)       --源系统                 
     , TRIM(T1.SRC_TAB)    --源表                  
     , T1.LD_TIME          --加载时间                
     , T1.MODIFY_TIME      --修改时间
  FROM DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD_TMP T1
 WHERE T1.IS_EXIS = '1'
;"
