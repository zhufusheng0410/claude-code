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
-- ** 描述:产品销售费率信息
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD  产品销售费率信息
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD 基金销售商参数表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD 基金销售商参数表
-- **         ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD 专户手工信息
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
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

--临时表1
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP1 PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , CASE WHEN T1.C_SHARETYPES IS NOT NULL 
              THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPES)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , T1.F_SERVICERATIO                                                             AS SALE_FEER                               --销售服务费率
     , CASE WHEN T1.D_SERVFAREBGNDATE IN ('20991231','99990101') THEN 
              '29991231'
            ELSE 
              T1.D_SERVFAREBGNDATE
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN T1.D_SERVFAREENDDATE IN ('20991231','99990101') THEN 
              '29991231'
            ELSE 
              T1.D_SERVFAREENDDATE
       END                                                                           AS END_DATE                                --结束日期
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TFUNDAGENCY_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD T1  --基金销售商参数表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_SHARETYPES'
   AND T1.C_SHARETYPES = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND COALESCE(T1.F_SERVICERATIO,0) <> 0
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP1 PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , NULL                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , T1.F_SERVICERATIO                                                             AS SALE_FEER                               --销售服务费率
     , CASE WHEN SUBSTR(REPLACE(T1.D_SERVFAREBGNDATE,'-',''),1,8) IN ('20991231','99990101') THEN 
              '29991231'
            ELSE 
              SUBSTR(REPLACE(T1.D_SERVFAREBGNDATE,'-',''),1,8)
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN SUBSTR(REPLACE(T1.D_SERVFAREENDDATE,'-',''),1,8) IN ('20991231','99990101') THEN 
              '29991231'
            ELSE 
              SUBSTR(REPLACE(T1.D_SERVFAREENDDATE,'-',''),1,8)
       END                                                                           AS END_DATE                                --结束日期
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TFUNDAGENCY_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD T1  --基金销售商参数表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
   AND COALESCE(T1.F_SERVICERATIO,0) <> 0
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP1 PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T3.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , 'A'                                                                           AS SHARE_CATG_CODE                         --份额类别代码
     , T1.SALE_FEER                                                                  AS SALE_FEER                               --销售服务费率
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
  LEFT JOIN ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD T3 --销售商信息
    ON T1.SALE_INST = T3.C_AGENCYNAME
   AND T3.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T4 --渠道基本信息
    ON T4.CHNL_INCD = T3.C_AGENCYNO
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP1 T5 --产品销售费率信息
    ON T2.PROD_NUM = T5.PROD_NUM
   AND T5.P_DT = '${p_end_dt}'
   AND T5.SSYS <> 'MANUAL'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T5.PROD_NUM IS NULL
   AND COALESCE(T1.SALE_FEER, '-') <> '-'
;

--临时表2
--新增的数据
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP2 PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.CHNL_INCD                                                                  AS CHNL_INCD                               --渠道内码
     , T1.SHARE_CATG_CODE                                                            AS SHARE_CATG_CODE                         --份额类别代码
     , T1.SALE_FEER                                                                  AS SALE_FEER                               --销售服务费率
     , T1.ST_DATE                                                                    AS ST_DATE                                 --开始日期
     , T1.END_DATE                                                                   AS END_DATE                                --结束日期
     , T1.SSYS                                                                       AS SSYS                                    --源系统
     , T1.SRC_TAB                                                                    AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP1 T1 
  LEFT JOIN (SELECT T.PROD_NUM       
                  , T.CHNL_NUM       
                  , MAX(T.ST_DATE ) AS MX_DT      
               FROM DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD T --产品销售费率信息
              WHERE T.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')--上一天数据
              GROUP BY T.PROD_NUM, T.CHNL_NUM) T2 --产品销售费率信息
    ON T1.PROD_NUM = T2.PROD_NUM
   AND T1.CHNL_NUM = T2.CHNL_NUM
   AND T1.ST_DATE = T2.MX_DT
 WHERE T1.P_DT = '${p_end_dt}'
   AND T2.PROD_NUM IS NULL
;

--历史数据
INSERT INTO DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP2 PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.CHNL_INCD                                                                  AS CHNL_INCD                               --渠道内码
     , T1.SHARE_CATG_CODE                                                            AS SHARE_CATG_CODE                         --份额类别代码
     , T1.SALE_FEER                                                                  AS SALE_FEER                               --销售服务费率
     , T1.ST_DATE                                                                    AS ST_DATE                                 --开始日期
     , T1.END_DATE                                                                   AS END_DATE                                --结束日期
     , T1.SSYS                                                                       AS SSYS                                    --源系统
     , T1.SRC_TAB                                                                    AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD T1 
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')--上一天数据
;

--正式表
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.CHNL_INCD                                                                  AS CHNL_INCD                               --渠道内码
     , T1.SHARE_CATG_CODE                                                            AS SHARE_CATG_CODE                         --份额类别代码
     , T1.SALE_FEER                                                                  AS SALE_FEER                               --销售服务费率
     , T1.ST_DATE                                                                    AS ST_DATE                                 --开始日期
     , COALESCE(DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(
       LEAD(T1.ST_DATE,1) OVER(PARTITION BY T1.PROD_NUM,T1.CHNL_NUM
       ORDER BY T1.ST_DATE),'yyyyMMdd'))),1),'yyyyMMdd'),
       T1.END_DATE)                                                                  AS END_DATE                                --结束日期
     , T1.SSYS                                                                       AS SSYS                                    --源系统
     , T1.SRC_TAB                                                                    AS SRC_TAB                                 --源表
     , T1.LD_TIME                                                                    AS LD_TIME                                 --加载时间
     , T1.MODIFY_TIME                                                                AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP2 T1 
 WHERE T1.P_DT = '${p_end_dt}'
;

--清空临时表
TRUNCATE TABLE DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP1;
TRUNCATE TABLE DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD_TMP2;

"
