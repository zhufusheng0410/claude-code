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
-- ** 描述:证券编码映射
-- ** 创建者:auto
-- ** 创建日期:2023-05-24
-- ** 修改日志:
-- ** 2023-05-24，auto，新建
-- ** 目标表：DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD    证券编码映射
-- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD    证券信息
-- **         ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD 证券信息
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD  证券基本信息
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD    证券编码映射
-- **         DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD   HSFA业务证券内码
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  标准字典码值映射
-- **         DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD    O32业务证券内码
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

TRUNCATE  TABLE  DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP;
INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP
SELECT DISTINCT COALESCE(T1.SCR_NUM,T6.SCR_NUM,T7.SCR_NUM)                             
     , T1.SCR_INCD
     , T1.ST_DATE
     , T1.END_DATE
     , T1.SRC_SYMBOL
     , T1.SYMBOL
     , T1.SRC_TRAN_MKT_CODE
     , T1.TRAN_MKT_CODE
     , T1.SRC_SCR_CATG_CODE
     , T1.SCR_PRI_CATG_CODE
     , T1.SCR_SCD_CATG_CODE
     , T1.SRC_SCR_PRI_CATG_CODE
     , T1.SRC_SCR_SCD_CATG_CODE
     , T1.SRC_SCR_SNAME
     , T1.SRC_ISSR_NUM
     , T1.ISIN_CODE
     , T1.VALID_FLAG
     , T1.EX_FLAG
     , T1.DEAL_TYPE_CODE
     , T1.SSYS
     , T1.SRC_TAB
     , CASE WHEN T1.SCR_NUM IS NOT NULL OR T6.SCR_NUM IS NOT NULL OR T7.SCR_NUM IS NOT NULL
            THEN '1'
            ELSE '0'
       END                                                                                    AS IS_EXIS                                 --是否存在 
     , T1.LD_TIME
     , T1.MODIFY_TIME
  FROM (SELECT   T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
               , T1.L_ZQNM                                                                     AS SCR_INCD                                --证券内码
               , '19000101'                                                                    AS ST_DATE                                 --开始日期
               , '29991231'                                                                    AS END_DATE                                --结束日期
               , T1.VC_ZQDM                                                                    AS SRC_SYMBOL                              --源证券代码
               , CASE
                    WHEN T1.L_SCLB IN('30','44')
                    THEN SUBSTR(T1.VC_ZQDM, 2, LENGTH(T1.VC_ZQDM))
                    ELSE
                     T1.VC_ZQDM
                  END                                                                          AS SYMBOL                                  --证券代码
               , T1.L_SCLB                                                                     AS SRC_TRAN_MKT_CODE                       --源交易市场代码
               , CASE WHEN T1.L_SCLB = '3' AND T1.L_ZQLB IN(2,3) 
                      THEN '04'
                      WHEN T1.L_SCLB = '3' AND T1.L_ZQLB NOT IN(2,3) 
                      THEN '01'
                      WHEN T1.L_SCLB IS NOT NULL 
                      THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_SCLB))
                 END                                                                           AS TRAN_MKT_CODE                           --交易市场代码
               , T1.L_ZQLB                                                                     AS SRC_SCR_CATG_CODE                       --源证券类别代码               
               , CASE WHEN T1.L_ZQLB IS NOT NULL 
                      THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_ZQLB)) 
                  END                                                                          AS SCR_PRI_CATG_CODE                       --证券一级分类代码
               , CASE WHEN T1.L_ZQLB = '7' 
                      THEN '1001' 
                      ELSE NVL(T6.STD_DICT_CLS_CD_VAL,T7.STD_DICT_CLS_CD_VAL) 
                 END                                                                           AS SCR_SCD_CATG_CODE                       --证券二级分类代码 
               , T1.L_ZQLBMX1                                                                  AS SRC_SCR_PRI_CATG_CODE                   --源证券一级分类代码
               , T1.L_ZQLBMX2                                                                  AS SRC_SCR_SCD_CATG_CODE                   --源证券二级分类代码
               , T1.VC_ZQJC                                                                    AS SRC_SCR_SNAME                           --源证券简称
               , NULL                                                                          AS SRC_ISSR_NUM                            --源发行人编码
               , NULL                                                                          AS ISIN_CODE                               --ISIN代码
               , '1'                                                                           AS VALID_FLAG                              --有效标志
               , '0'                                                                           AS EX_FLAG                                 --异常标志
               , NULL                                                                          AS DEAL_TYPE_CODE                          --处理类型代码
               , 'HSFA'                                                                        AS SSYS                                    --源系统
               , 'ODS_HSFA_TZQXX_PFD'                                                          AS SRC_TAB                                 --源表
               , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
               , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
           FROM (SELECT CAST(T1.L_ZQNM AS STRING) AS L_ZQNM
                      , CAST(T1.L_SCLB AS STRING) AS L_SCLB
                      , CAST(T1.L_ZQLB AS STRING) AS L_ZQLB
                      , T1.VC_ZQDM
                      , T1.VC_ZQJC
                      , CAST(T1.L_ZQLBMX1 AS STRING) AS L_ZQLBMX1
                      , CAST(T1.L_ZQLBMX2 AS STRING) AS L_ZQLBMX2
                   FROM ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T1  --证券信息表
                  INNER JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD T2 --HSFA业务证券内码
                     ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD --证券内码
                    AND T2.P_DT = '${p_end_dt}'
                  WHERE T1.P_DT = '${p_end_dt}'
                 --补充基本信息不在的券信息
                  UNION ALL
                 SELECT T2.SCR_INCD 
                      , T2.L_SCLB
                      , T2.L_ZQLB
                      , T2.VC_ZQDM
                      , T2.VC_ZQJC
                      , NULL L_ZQLBMX1
                      , NULL L_ZQLBMX2
                   FROM DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD T2 --HSFA业务证券内码
                   LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T1  --证券信息表
                     ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD --证券内码
                    AND T1.P_DT = '${p_end_dt}'
                  WHERE T2.P_DT = '${p_end_dt}'
                    AND T1.L_ZQNM IS NULL
                    AND T2.VC_ZQJC IS NOT NULL 
               ) T1
         LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
           ON CAST(T1.L_ZQNM AS STRING) = T3.SCR_INCD --证券内码
          AND T3.SSYS = 'HSFA'
          AND T3.ST_DATE <= '${p_end_dt}'
          AND T3.END_DATE >= '${p_end_dt}'
          AND T3.VALID_FLAG = '1' --有效标志
          AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
           ON T4.SSYS = 'HSFA'
          AND T4.SRC_DICT_CLS_CD = 'L_SCLB' --源字典分类
          AND T1.L_SCLB = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T4.VALID_FLAG = '1' --有效标志
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
           ON T5.SSYS = 'HSFA'
          AND T5.SRC_DICT_CLS_CD = 'L_ZQLB' --源字典分类
          AND T1.L_ZQLB = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T5.VALID_FLAG = '1' --有效标志
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
           ON T6.SSYS = 'HSFA'
          AND T6.SRC_DICT_CLS_CD = T5.STD_DICT_CLS_CD_VAL --源字典分类
          AND T1.L_ZQLBMX1 = T6.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T6.VALID_FLAG = '1' --有效标志
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
           ON T7.SSYS = 'HSFA'
          AND T7.SRC_DICT_CLS_CD = T5.STD_DICT_CLS_CD_VAL --源字典分类
          AND T1.L_ZQLBMX2 = T7.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T7.VALID_FLAG = '1' --有效标志
          ) T1  
      --三要素 证券代码、证券一级分类代码、交易市场代码,香港市场的股票只要证券代码、证券一级分类代码一致则认为是同一个券
      -- 四要素 回购类型时，证券代码、证券一级分类代码、证券二级分类代码、交易市场代码,
      LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T6 --证券基本信息
        ON T1.SYMBOL = T6.SYMBOL --证券代码
       AND T1.SCR_PRI_CATG_CODE = T6.SCR_PRI_CATG_CODE --证券一级分类代码
       AND CASE WHEN T1.SCR_PRI_CATG_CODE ='04'  --回购
                THEN T1.SCR_SCD_CATG_CODE  = T6.SCR_SCD_CATG_CODE 
                ELSE 1=1 
           END 
       AND CASE  WHEN T1.TRAN_MKT_CODE NOT IN ('09','10')  --香港市场
                 THEN T1.TRAN_MKT_CODE  = T6.TRAN_MKT_CODE 
                 ELSE 1=1 
           END  --交易市场代码
       AND T6.VALID_FLAG = '1' --有效标志
       AND T6.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')  
     LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T7 --证券基本信息
        ON T1.SRC_SCR_SNAME = T7.SCR_SNAME   --证券名称初始化和当只有债券上市前有用，当债券上市后会数据重复
       AND T1.SCR_PRI_CATG_CODE = T7.SCR_PRI_CATG_CODE --证券一级分类代码
       AND T1.TRAN_MKT_CODE = T7.TRAN_MKT_CODE --交易市场代码
       AND T7.VALID_FLAG = '1' --有效标志
       AND T7.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
       AND T7.SCR_PRI_CATG_CODE = '03'       --证券一级分类代码为债券
;


INSERT INTO DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP
SELECT DISTINCT
       COALESCE(T1.SCR_NUM,T6.SCR_NUM,T7.SCR_NUM)                             
     , T1.SCR_INCD
     , T1.ST_DATE
     , T1.END_DATE
     , T1.SRC_SYMBOL
     , T1.SYMBOL
     , T1.SRC_TRAN_MKT_CODE
     , T1.TRAN_MKT_CODE
     , T1.SRC_SCR_CATG_CODE
     , T1.SCR_PRI_CATG_CODE
     , T1.SCR_SCD_CATG_CODE
     , T1.SRC_SCR_PRI_CATG_CODE
     , T1.SRC_SCR_SCD_CATG_CODE
     , T1.SRC_SCR_SNAME
     , T1.SRC_ISSR_NUM
     , T1.ISIN_CODE
     , T1.VALID_FLAG
     , T1.EX_FLAG
     , T1.DEAL_TYPE_CODE
     , T1.SSYS
     , T1.SRC_TAB
     , CASE WHEN T1.SCR_NUM IS NOT NULL OR T6.SCR_NUM IS NOT NULL OR T7.SCR_NUM IS NOT NULL
            THEN '1'
            ELSE '0'
       END                                                                                    AS IS_EXIS                                 --是否存在 
     , T1.LD_TIME
     , T1.MODIFY_TIME                                                                        AS IS_EXIS                                 --是否存在
FROM (
    SELECT
           T3.SCR_NUM                                                                     AS SCR_NUM                                 --证券编码
         , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
         , '19000101'                                                                    AS ST_DATE                                 --开始日期
         , '29991231'                                                                    AS END_DATE                                --结束日期
         , T1.VC_REPORT_CODE                                                             AS SRC_SYMBOL                              --源证券代码
         , T1.REPORT_CODE                                                                AS SYMBOL                                  --证券代码
         , T1.C_MARKET_NO                                                                AS SRC_TRAN_MKT_CODE                       --源交易市场代码
         , CASE WHEN T1.C_MARKET_NO IS NOT NULL 
                THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO)) 
            END                                                                          AS TRAN_MKT_CODE                           --交易市场代码
         , T1.C_ASSET_CLASS                                                              AS SRC_SCR_CATG_CODE                       --源证券分类代码
         , CASE WHEN T1.C_ASSET_CLASS IS NOT NULL 
                THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ASSET_CLASS)) 
            END                                                                          AS SCR_PRI_CATG_CODE                       --证券一级分类代码
         , T6.STD_DICT_CLS_CD_VAL                                                        AS SCR_SCD_CATG_CODE                       --证券二级分类代码
         , T1.C_STOCK_TYPE                                                               AS SRC_SCR_PRI_CATG_CODE                   --源证券一级分类代码
         , NULL                                                                          AS SRC_SCR_SCD_CATG_CODE                   --源证券二级分类代码
         , T1.VC_STOCK_NAME                                                              AS SRC_SCR_SNAME                           --源证券简称
         , NULL                                                                          AS SRC_ISSR_NUM                            --源发行人编码
         , NULL                                                                          AS ISIN_CODE                               --ISIN代码
         , '1'                                                                           AS VALID_FLAG                              --有效标志
         , '0'                                                                           AS EX_FLAG                                 --异常标志
         , NULL                                                                          AS DEAL_TYPE_CODE                          --处理类型代码
         , 'O32'                                                                         AS SSYS                                    --源系统
         , 'ODS_O32_TSTOCKINFO_PFD'                                                      AS SRC_TAB                                 --源表
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
      FROM (SELECT T10.VC_INTER_CODE
                 , T10.VC_REPORT_CODE
                 , CASE WHEN SUBSTR(T10.VC_REPORT_CODE, 0, 2) = 'BD' 
                        THEN SUBSTR(T10.VC_REPORT_CODE, 3, LENGTH(T10.VC_REPORT_CODE))
                        WHEN SUBSTR(T10.VC_REPORT_CODE, 0, 1) = 'O' 
                        THEN SUBSTR(T10.VC_REPORT_CODE, 2, LENGTH(T10.VC_REPORT_CODE))
                        ELSE T10.VC_REPORT_CODE
                   END                         AS REPORT_CODE
                , T10.C_MARKET_NO
                , CASE WHEN T10.C_STOCK_TYPE = '[' AND T10.C_ASSET_CLASS = '4'  
                       THEN'13'  --信托理财
                       WHEN T10.C_STOCK_TYPE = 'U' AND T10.C_ASSET_CLASS = '4'  
                       THEN '13'  --理财
                       WHEN T10.C_STOCK_TYPE = 'n' AND T10.C_ASSET_CLASS = '6'  
                       THEN '3'   --增发债
                       WHEN T10.C_STOCK_TYPE = 'E' AND T10.C_ASSET_CLASS = '8'  
                       THEN '22'   --存款
                       WHEN T10.C_STOCK_TYPE = 'w' AND T10.C_ASSET_CLASS = '6'  
                       THEN '23'   --指数
                       WHEN T10.C_STOCK_TYPE = '8'  AND T10.C_ASSET_CLASS ='6'     
                       THEN '5'  --回购
                       WHEN T10.C_STOCK_TYPE = 'I'  AND T10.C_ASSET_CLASS ='6'     
                       THEN '5'  --回购
                       WHEN T10.C_STOCK_TYPE = 'k'  AND T10.C_ASSET_CLASS ='6'     
                       THEN '3'  --债券
                       ELSE T10.C_ASSET_CLASS 
                  END          AS C_ASSET_CLASS
                , T10.C_STOCK_TYPE
                , T10.VC_STOCK_NAME
             FROM ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD T10  --证券信息表
           WHERE T10.P_DT = '${p_end_dt}'
         )T1
     INNER JOIN DWDXDAY.DWD_SCR_O32_SCR_INCD_PFD T2 --O32业务证券内码
        ON T1.VC_INTER_CODE = T2.SCR_INCD--证券内码
       AND T2.P_DT = '${p_end_dt}'
      LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
        ON T1.VC_INTER_CODE = T3.SCR_INCD --证券内码
       AND T3.SSYS = 'O32'
       AND T3.ST_DATE <= '${p_end_dt}'
       AND T3.END_DATE >= '${p_end_dt}'
       AND T3.VALID_FLAG = '1' --有效标志
       AND T3.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
        ON T4.SSYS = 'O32'
       AND T4.SRC_DICT_CLS_CD = 'C_MARKET_NO' --源字典分类
       AND T1.C_MARKET_NO = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
       AND T4.VALID_FLAG = '1' --有效标志
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
        ON T5.SSYS = 'O32'
       AND T5.SRC_DICT_CLS_CD = 'C_ASSET_CLASS' --源字典分类
       AND T1.C_ASSET_CLASS = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
       AND T5.VALID_FLAG = '1' --有效标志
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
        ON T6.SSYS = 'O32'
       AND T6.SRC_DICT_CLS_CD = 'C_STOCK_TYPE' --源字典分类
       AND T1.C_STOCK_TYPE = T6.SRC_DICT_CLS_CDVAL --源字典分类码值
       AND T6.VALID_FLAG = '1' --有效标志  
    )T1
   
     
 --三要素 证券代码、证券一级分类代码、交易市场代码,香港市场的股票只要证券代码、证券一级分类代码一致则认为是同一个券
 -- 四要素 回购类型时，证券代码、证券一级分类代码、证券二级分类代码、交易市场代码,
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T6 --证券基本信息
    ON T1.SYMBOL = T6.SYMBOL --证券代码
   AND T1.SCR_PRI_CATG_CODE = T6.SCR_PRI_CATG_CODE --证券一级分类代码
   AND CASE WHEN T1.SCR_PRI_CATG_CODE = '04'  --回购
            THEN T1.SCR_SCD_CATG_CODE  = T6.SCR_SCD_CATG_CODE 
            ELSE 1=1 
       END 
   AND CASE  WHEN T1.TRAN_MKT_CODE NOT IN ('09','10')  --香港市场
             THEN T1.TRAN_MKT_CODE  = T6.TRAN_MKT_CODE 
             ELSE  1= 1 
       END  --交易市场代码
   AND T6.VALID_FLAG = '1' --有效标志
   AND T6.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd') 
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T7 --证券基本信息
    ON T1.SRC_SCR_SNAME = T7.SCR_SNAME   --证券名称初始化和当只有债券上市前有用，当债券上市后会数据重复
   AND T1.SCR_PRI_CATG_CODE = T7.SCR_PRI_CATG_CODE --证券一级分类代码
   AND T1.TRAN_MKT_CODE = T7.TRAN_MKT_CODE --交易市场代码
   AND T7.VALID_FLAG = '1' --有效标志
   AND T7.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
   AND T7.SCR_PRI_CATG_CODE ='03'       --证券一级分类代码为债券
  
;


INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.SCR_NUM                                    --证券编码
     , T1.SCR_INCD                                   --证券内码
     , T1.ST_DATE                                    --开始日期
     , T1.END_DATE                                   --结束日期
     , T1.SRC_SYMBOL                                 --源证券代码
     , T1.SRC_TRAN_MKT_CODE                          --源交易市场代码
     , T1.SRC_SCR_CATG_CODE                          --源证券类别代码
     , T1.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
     , T1.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
     , T1.SRC_SCR_SNAME                              --源证券简称
     , T1.SRC_ISSR_NUM                               --源发行人编码
     , T1.ISIN_CODE                                  --ISIN代码
     , T1.VALID_FLAG                                 --有效标志
     , T1.EX_FLAG                                    --异常标志
     , T1.DEAL_TYPE_CODE                             --处理类型代码
     , TRIM(T1.SSYS)                                 --源系统
     , TRIM(T1.SRC_TAB)                              --源表
     , T1.LD_TIME                                    --加载时间
     , T1.MODIFY_TIME                                --修改时间	  
  FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP T1
 WHERE T1.IS_EXIS = 1
 ;
 
 --非港股非债券
INSERT INTO DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT CONCAT('S',RN,'0') AS SCR_NUM                 --证券编码
     , T1.SCR_INCD                                   --证券内码
     , T1.ST_DATE                                    --开始日期
     , T1.END_DATE                                   --结束日期
     , T1.SRC_SYMBOL                                 --源证券代码
     , T1.SRC_TRAN_MKT_CODE                          --源交易市场代码
     , T1.SRC_SCR_CATG_CODE                          --源证券类别代码
     , T1.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
     , T1.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
     , T1.SRC_SCR_SNAME                              --源证券简称
     , T1.SRC_ISSR_NUM                               --源发行人编码
     , T1.ISIN_CODE                                  --ISIN代码
     , T1.VALID_FLAG                                 --有效标志
     , T1.EX_FLAG                                    --异常标志
     , T1.DEAL_TYPE_CODE                             --处理类型代码
     , TRIM(T1.SSYS)                                 --源系统
     , TRIM(T1.SRC_TAB)                              --源表
     , T1.LD_TIME                                    --加载时间
     , T1.MODIFY_TIME                                --修改时间
  FROM (SELECT T10.SCR_INCD                                   --证券内码
             , T10.ST_DATE                                    --开始日期
             , T10.END_DATE                                   --结束日期
             , T10.SRC_SYMBOL                                 --源证券代码
             , T10.SRC_TRAN_MKT_CODE                          --源交易市场代码
             , T10.SRC_SCR_CATG_CODE                          --源证券类别代码
             , T10.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
             , T10.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
             , T10.SRC_SCR_SNAME                              --源证券简称
             , T10.SRC_ISSR_NUM                               --源发行人编码
             , T10.ISIN_CODE                                  --ISIN代码
             , T10.VALID_FLAG                                 --有效标志
             , T10.EX_FLAG                                    --异常标志
             , T10.DEAL_TYPE_CODE                             --处理类型代码
             , T10.SSYS                                       --源系统
             , T10.SRC_TAB                                    --源表
             , T10.LD_TIME                                    --加载时间
             , T10.MODIFY_TIME                                --修改时间
             , LPAD(DENSE_RANK() OVER(ORDER BY T10.SYMBOL,T10.TRAN_MKT_CODE,T10.SCR_PRI_CATG_CODE)+MAX_SCR_NUM,9,0)  RN
          FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP T10
         LEFT JOIN (SELECT NVL(CAST (MAX(SUBSTR(T20.SCR_NUM,2,9)) AS DECIMAL(10)),0) AS MAX_SCR_NUM
                     FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T20
                    WHERE T20.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
                   )T2
             ON 1 = 1
         WHERE T10.IS_EXIS = 0
           AND ((T10.TRAN_MKT_CODE NOT IN('09','10') AND T10.SCR_PRI_CATG_CODE ='06') or  (T10.SCR_PRI_CATG_CODE NOT IN('03','04','06')))
       )T1
;

 
INSERT INTO DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT CONCAT('S',RN,'0') AS SCR_NUM                 --证券编码
     , T1.SCR_INCD                                   --证券内码
     , T1.ST_DATE                                    --开始日期
     , T1.END_DATE                                   --结束日期
     , T1.SRC_SYMBOL                                 --源证券代码
     , T1.SRC_TRAN_MKT_CODE                          --源交易市场代码
     , T1.SRC_SCR_CATG_CODE                          --源证券类别代码
     , T1.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
     , T1.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
     , T1.SRC_SCR_SNAME                              --源证券简称
     , T1.SRC_ISSR_NUM                               --源发行人编码
     , T1.ISIN_CODE                                  --ISIN代码
     , T1.VALID_FLAG                                 --有效标志
     , T1.EX_FLAG                                    --异常标志
     , T1.DEAL_TYPE_CODE                             --处理类型代码
     , TRIM(T1.SSYS)                                 --源系统
     , TRIM(T1.SRC_TAB)                              --源表
     , T1.LD_TIME                                    --加载时间
     , T1.MODIFY_TIME                                --修改时间
  FROM (SELECT T10.SCR_INCD                                   --证券内码
             , T10.ST_DATE                                    --开始日期
             , T10.END_DATE                                   --结束日期
             , T10.SRC_SYMBOL                                 --源证券代码
             , T10.SRC_TRAN_MKT_CODE                          --源交易市场代码
             , T10.SRC_SCR_CATG_CODE                          --源证券类别代码
             , T10.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
             , T10.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
             , T10.SRC_SCR_SNAME                              --源证券简称
             , T10.SRC_ISSR_NUM                               --源发行人编码
             , T10.ISIN_CODE                                  --ISIN代码
             , T10.VALID_FLAG                                 --有效标志
             , T10.EX_FLAG                                    --异常标志
             , T10.DEAL_TYPE_CODE                             --处理类型代码
             , T10.SSYS                                       --源系统
             , T10.SRC_TAB                                    --源表
             , T10.LD_TIME                                    --加载时间
             , T10.MODIFY_TIME                                --修改时间
             , LPAD(DENSE_RANK() OVER(ORDER BY T10.SYMBOL,T10.SCR_PRI_CATG_CODE)+MAX_SCR_NUM,9,0)  RN
          FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP T10
          LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T11
            ON T10.SCR_INCD = T11.SCR_INCD
           AND T11.SSYS = 'HSFA'
           AND T11.P_DT = '${p_end_dt}'
          LEFT JOIN (SELECT NVL(CAST (MAX(SUBSTR(T20.SCR_NUM,2,9)) AS DECIMAL(10)),0) AS MAX_SCR_NUM
                       FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T20
                      WHERE T20.P_DT = '${p_end_dt}'
                    )T2
             ON 1 = 1
         WHERE T10.IS_EXIS = 0
           AND T10.TRAN_MKT_CODE IN('09','10')
           AND T10.SCR_PRI_CATG_CODE = '06'
           AND T11.SCR_INCD IS NULL
       )T1
;

--债券优先以正常的三要素合并
INSERT INTO TABLE DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT CONCAT('S',RN,'0') AS SCR_NUM                 --证券编码
     , T1.SCR_INCD                                   --证券内码
     , T1.ST_DATE                                    --开始日期
     , T1.END_DATE                                   --结束日期
     , T1.SRC_SYMBOL                                 --源证券代码
     , T1.SRC_TRAN_MKT_CODE                          --源交易市场代码
     , T1.SRC_SCR_CATG_CODE                          --源证券类别代码
     , T1.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
     , T1.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
     , T1.SRC_SCR_SNAME                              --源证券简称
     , T1.SRC_ISSR_NUM                               --源发行人编码
     , T1.ISIN_CODE                                  --ISIN代码
     , T1.VALID_FLAG                                 --有效标志
     , T1.EX_FLAG                                    --异常标志
     , T1.DEAL_TYPE_CODE                             --处理类型代码
     , TRIM(T1.SSYS)                                 --源系统
     , TRIM(T1.SRC_TAB)                              --源表
     , T1.LD_TIME                                    --加载时间
     , T1.MODIFY_TIME                                --修改时间
  FROM (SELECT T10.SCR_INCD                                   --证券内码
             , T10.ST_DATE                                    --开始日期
             , T10.END_DATE                                   --结束日期
             , T10.SRC_SYMBOL                                 --源证券代码
             , T10.SRC_TRAN_MKT_CODE                          --源交易市场代码
             , T10.SRC_SCR_CATG_CODE                          --源证券类别代码
             , T10.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
             , T10.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
             , T10.SRC_SCR_SNAME                              --源证券简称
             , T10.SRC_ISSR_NUM                               --源发行人编码
             , T10.ISIN_CODE                                  --ISIN代码
             , T10.VALID_FLAG                                 --有效标志
             , T10.EX_FLAG                                    --异常标志
             , T10.DEAL_TYPE_CODE                             --处理类型代码
             , T10.SSYS                                       --源系统
             , T10.SRC_TAB                                    --源表
             , T10.LD_TIME                                    --加载时间
             , T10.MODIFY_TIME                                --修改时间
             , LPAD(DENSE_RANK() OVER(ORDER BY T10.SYMBOL,T10.TRAN_MKT_CODE,T10.SCR_PRI_CATG_CODE)+MAX_SCR_NUM,9,0)  RN
             , count(1) OVER(PARTITION BY T10.SYMBOL,T10.TRAN_MKT_CODE,T10.SCR_PRI_CATG_CODE) RN_CNT
          FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP T10
         LEFT JOIN (SELECT NVL(CAST (MAX(SUBSTR(T20.SCR_NUM,2,9)) AS DECIMAL(10)),0) AS MAX_SCR_NUM
                     FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T20
                    WHERE T20.P_DT = '${p_end_dt}'
                   )T2
             ON 1 = 1
         WHERE T10.IS_EXIS = 0
           AND T10.SCR_PRI_CATG_CODE = '03'
       )T1
WHERE RN_CNT>=2
;

--债券预发布和发布合并，名称一致、市场一致、类别一致则为同一个代码
INSERT INTO TABLE DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT CONCAT('S',RN,'0') AS SCR_NUM                 --证券编码
     , T1.SCR_INCD                                   --证券内码
     , T1.ST_DATE                                    --开始日期
     , T1.END_DATE                                   --结束日期
     , T1.SRC_SYMBOL                                 --源证券代码
     , T1.SRC_TRAN_MKT_CODE                          --源交易市场代码
     , T1.SRC_SCR_CATG_CODE                          --源证券类别代码
     , T1.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
     , T1.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
     , T1.SRC_SCR_SNAME                              --源证券简称
     , T1.SRC_ISSR_NUM                               --源发行人编码
     , T1.ISIN_CODE                                  --ISIN代码
     , T1.VALID_FLAG                                 --有效标志
     , T1.EX_FLAG                                    --异常标志
     , T1.DEAL_TYPE_CODE                             --处理类型代码
     , TRIM(T1.SSYS)                                 --源系统
     , TRIM(T1.SRC_TAB)                              --源表
     , T1.LD_TIME                                    --加载时间
     , T1.MODIFY_TIME                                --修改时间
  FROM (SELECT T10.SCR_INCD                                   --证券内码
             , T10.ST_DATE                                    --开始日期
             , T10.END_DATE                                   --结束日期
             , T10.SRC_SYMBOL                                 --源证券代码
             , T10.SRC_TRAN_MKT_CODE                          --源交易市场代码
             , T10.SRC_SCR_CATG_CODE                          --源证券类别代码
             , T10.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
             , T10.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
             , T10.SRC_SCR_SNAME                              --源证券简称
             , T10.SRC_ISSR_NUM                               --源发行人编码
             , T10.ISIN_CODE                                  --ISIN代码
             , T10.VALID_FLAG                                 --有效标志
             , T10.EX_FLAG                                    --异常标志
             , T10.DEAL_TYPE_CODE                             --处理类型代码
             , T10.SSYS                                       --源系统
             , T10.SRC_TAB                                    --源表
             , T10.LD_TIME                                    --加载时间
             , T10.MODIFY_TIME                                --修改时间
             , LPAD(DENSE_RANK() OVER(ORDER BY T10.SRC_SCR_SNAME,T10.TRAN_MKT_CODE,T10.SCR_PRI_CATG_CODE)+MAX_SCR_NUM,9,0)  RN
             , ROW_NUMBER() OVER(PARTITION BY T10.SRC_SCR_SNAME,T10.TRAN_MKT_CODE,T10.SCR_PRI_CATG_CODE) RN_CNT
          FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP T10
          LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T11
            ON T10.SCR_INCD = T11.SCR_INCD
           AND T10.SSYS = T11.SSYS
           AND T11.P_DT = '${p_end_dt}'
         LEFT JOIN (SELECT NVL(CAST (MAX(SUBSTR(T20.SCR_NUM,2,9)) AS DECIMAL(10)),0) AS MAX_SCR_NUM
                     FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T20
                    WHERE T20.P_DT = '${p_end_dt}'
                   )T2
             ON 1 = 1
         WHERE T10.IS_EXIS = 0
           AND T10.SCR_PRI_CATG_CODE = '03'
           AND T11.SCR_INCD IS  NULL 
       )T1
;


--回购类型时，证券代码、证券一级分类代码、证券二级分类代码、交易市场代码
INSERT INTO TABLE DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT CONCAT('S',RN,'0') AS SCR_NUM                 --证券编码
     , T1.SCR_INCD                                   --证券内码
     , T1.ST_DATE                                    --开始日期
     , T1.END_DATE                                   --结束日期
     , T1.SRC_SYMBOL                                 --源证券代码
     , T1.SRC_TRAN_MKT_CODE                          --源交易市场代码
     , T1.SRC_SCR_CATG_CODE                          --源证券类别代码
     , T1.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
     , T1.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
     , T1.SRC_SCR_SNAME                              --源证券简称
     , T1.SRC_ISSR_NUM                               --源发行人编码
     , T1.ISIN_CODE                                  --ISIN代码
     , T1.VALID_FLAG                                 --有效标志
     , T1.EX_FLAG                                    --异常标志
     , T1.DEAL_TYPE_CODE                             --处理类型代码
     , TRIM(T1.SSYS)                                 --源系统
     , TRIM(T1.SRC_TAB)                              --源表
     , T1.LD_TIME                                    --加载时间
     , T1.MODIFY_TIME                                --修改时间
  FROM (SELECT T10.SCR_INCD                                   --证券内码
             , T10.ST_DATE                                    --开始日期
             , T10.END_DATE                                   --结束日期
             , T10.SRC_SYMBOL                                 --源证券代码
             , T10.SRC_TRAN_MKT_CODE                          --源交易市场代码
             , T10.SRC_SCR_CATG_CODE                          --源证券类别代码
             , T10.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
             , T10.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
             , T10.SRC_SCR_SNAME                              --源证券简称
             , T10.SRC_ISSR_NUM                               --源发行人编码
             , T10.ISIN_CODE                                  --ISIN代码
             , T10.VALID_FLAG                                 --有效标志
             , T10.EX_FLAG                                    --异常标志
             , T10.DEAL_TYPE_CODE                             --处理类型代码
             , T10.SSYS                                       --源系统
             , T10.SRC_TAB                                    --源表
             , T10.LD_TIME                                    --加载时间
             , T10.MODIFY_TIME                                --修改时间
             , LPAD(DENSE_RANK() OVER(ORDER BY T10.SYMBOL,T10.TRAN_MKT_CODE,T10.SCR_PRI_CATG_CODE,T10.SCR_SCD_CATG_CODE)+MAX_SCR_NUM,9,0)  RN
          FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD_TMP T10
         LEFT JOIN (SELECT NVL(CAST (MAX(SUBSTR(T20.SCR_NUM,2,9)) AS DECIMAL(10)),0) AS MAX_SCR_NUM
                     FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T20
                    WHERE T20.P_DT = '${p_end_dt}'
                   )T2
             ON 1 = 1
         WHERE T10.IS_EXIS = 0
           AND T10.SCR_PRI_CATG_CODE = '04'
       )T1
;
--O32来源存在部分代码当天不在证券基本信息表里面，需将昨日数据今日不在的补充进来
INSERT INTO TABLE DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.SCR_NUM                                    --证券编码
     , T1.SCR_INCD                                   --证券内码
     , T1.ST_DATE                                    --开始日期
     , T1.END_DATE                                   --结束日期
     , T1.SRC_SYMBOL                                 --源证券代码
     , T1.SRC_TRAN_MKT_CODE                          --源交易市场代码
     , T1.SRC_SCR_CATG_CODE                          --源证券类别代码
     , T1.SRC_SCR_PRI_CATG_CODE                      --源证券一级分类代码
     , T1.SRC_SCR_SCD_CATG_CODE                      --源证券二级分类代码
     , T1.SRC_SCR_SNAME                              --源证券简称
     , T1.SRC_ISSR_NUM                               --源发行人编码
     , T1.ISIN_CODE                                  --ISIN代码
     , T1.VALID_FLAG                                 --有效标志
     , T1.EX_FLAG                                    --异常标志
     , T1.DEAL_TYPE_CODE                             --处理类型代码
     , T1.SSYS                                       --源系统
     , T1.SRC_TAB                                    --源表
     , T1.LD_TIME                                    --加载时间
     , T1.MODIFY_TIME                                --修改时间
  FROM DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T1 
  LEFT JOIN  DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2
    ON T1.SCR_INCD = T2.SCR_INCD
   AND T1.SRC_TAB = T2.SRC_TAB
   AND T2.P_DT = '${p_end_dt}'
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
   AND T2.SCR_INCD IS NULL
;
"
