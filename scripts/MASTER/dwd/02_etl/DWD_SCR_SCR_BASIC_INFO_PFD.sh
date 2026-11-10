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
-- ** 描述:证券基本信息
-- ** 创建者:auto
-- ** 创建日期:2023-05-24
-- ** 修改日志:
-- ** 2023-05-24，auto，新建
-- ** 目标表：DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD  证券基本信息
-- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD 证券信息表
-- **         ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD 证券信息表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD 证券编码映射
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD  证券基本信息
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
INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.SCR_NUM
     , T1.SYMBOL
     , T1.SCR_PRI_CATG_CODE
     , T1.SCR_SCD_CATG_CODE
     , T1.TRAN_MKT_CODE
     , T1.SCR_SNAME
     , T1.SCR_FNAME
     , T1.ESNAME
     , T1.SCR_PHTIC
     , T1.TRAN_CRRC_CODE
     , T1.SCR_STAT_CODE
     , T1.ISIN_CODE
     , T1.LIST_DATE
     , T1.LIST_STAT_CODE
     , T1.DELT_DATE
     , T1.VALID_FLAG
     , T1.SSYS
     , T1.SRC_TAB
     , T1.LD_TIME
     , T1.MODIFY_TIME
  FROM (SELECT 
               T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
             ,  CASE WHEN T1.L_ZQLB IN('2','15') 
                     THEN NVL(T1.VC_TRADEZQDM,T1.VC_ZQDM)
                     WHEN T1.L_SCLB IN('30','44')  
                     THEN SUBSTR(T1.VC_ZQDM, 2, LENGTH(T1.VC_ZQDM))
                     ELSE T1.VC_ZQDM
                END                                                                          AS SYMBOL                                  --证券代码
             , CASE WHEN T1.L_ZQLB IS NOT NULL 
                    THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_ZQLB)) 
               END                                                                           AS SCR_PRI_CATG_CODE                           --证券一级分类代码
             , CASE WHEN T1.L_ZQLB = '7' 
                   THEN '1001' 
                   ELSE NVL(T9.STD_DICT_CLS_CD_VAL,T10.STD_DICT_CLS_CD_VAL) 
               END                                                                            AS SCR_SCD_CATG_CODE                       --证券二级分类代码  
             , CASE WHEN T1.L_SCLB = '3' AND T1.L_ZQLB IN(2,3) 
                    THEN '04'
                    WHEN T1.L_SCLB = '3' AND T1.L_ZQLB NOT IN(2,3)
                    THEN '01'
                    WHEN T1.L_SCLB IS NOT NULL 
                    THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_SCLB))
               END                                                                           AS TRAN_MKT_CODE                           --交易市场代码
             , CASE WHEN T1.L_ZQLB = '2'  
                    THEN NVL(T1.VC_ZQJC,T6.VC_STOCK_NAME) 
                    ELSE T1.VC_ZQJC 
               END                                                                           AS SCR_SNAME                               --证券简称
             , TRIM(COALESCE(T1.VC_ZQQC,T6.VC_STOCK_FULLNAME,T1.VC_ZQJC))                    AS SCR_FNAME                               --证券全称
             , T1.VC_YWJC                                                                    AS ESNAME                                  --英文简称
             , T6.VC_STOCK_SPELL                                                             AS SCR_PHTIC                               --证券拼音
             , CASE WHEN T6.VC_TRADE_CURRENCY_NO IS NOT NULL 
                    THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T6.VC_TRADE_CURRENCY_NO)) 
                END                                                                          AS TRAN_CRRC_CODE                          --交易币种代码
             , CASE WHEN T1.C_ZQZT IS NOT NULL 
                    THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ZQZT)) 
                END                                                                          AS SCR_STAT_CODE                           --证券状态代码
             , NULL                                                                          AS ISIN_CODE                               --ISIN代码
             , SUBSTR(REPLACE(T1.D_FXRQ,'-',''),1,8)                                         AS LIST_DATE                               --上市日期
             , NULL                                                                          AS LIST_STAT_CODE                          --上市状态代码
             , SUBSTR(REPLACE(T1.D_DQRQ,'-',''),1,8)                                         AS DELT_DATE                               --退市日期
             , '1'                                                                           AS VALID_FLAG                              --有效标志
             , 'HSFA'                                                                        AS SSYS                                    --源系统
             , 'ODS_HSFA_TZQXX_PFD'                                                          AS SRC_TAB                                 --源表
             , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
             , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
             , ROW_NUMBER() OVER(PARTITION BY T2.SCR_NUM  ORDER BY NVL(SUBSTR(REPLACE(T1.D_DQRQ,'-',''),1,8),'20991231') DESC ) RN
          FROM (SELECT CAST(T1.L_ZQNM AS STRING) AS L_ZQNM
                     , CAST(T1.L_SCLB AS STRING) AS L_SCLB
                     , CAST(T1.L_ZQLB AS STRING) AS L_ZQLB
                     , T1.VC_ZQDM
                     , T1.VC_TRADEZQDM
                     , T1.VC_ZQJC
                     , CAST(T1.L_ZQLBMX1 AS STRING) AS L_ZQLBMX1
                     , CAST(T1.L_ZQLBMX2 AS STRING) AS L_ZQLBMX2
                     , T1.VC_ZQQC
                     , T1.C_ZQZT
                     , T1.D_FXRQ
                     , T1.D_DQRQ
                     , T1.VC_YWJC
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
                     , NULL VC_TRADEZQDM
                     , NULL L_ZQLBMX1
                     , NULL L_ZQLBMX2
                     , NULL VC_ZQQC
                     , NULL C_ZQZT
                     , NULL D_FXRQ
                     , NULL D_DQRQ
                     , NULL VC_YWJC
                  FROM DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD T2 --HSFA业务证券内码
                  LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T1  --证券信息表
                    ON CAST(T1.L_ZQNM AS STRING) = T2.SCR_INCD --证券内码
                   AND T1.P_DT = '${p_end_dt}'
                 WHERE T2.P_DT = '${p_end_dt}'
                   AND T1.L_ZQNM IS NULL
                   AND T2.VC_ZQJC IS NOT NULL )T1
         INNER JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2 --证券编码映射
            ON T1.L_ZQNM = T2.SCR_INCD --证券内码
           AND T2.SSYS = 'HSFA'
           AND T2.ST_DATE <= '${p_end_dt}'
           AND T2.END_DATE >= '${p_end_dt}'
           AND T2.VALID_FLAG = '1' --有效标志
           AND T2.P_DT = '${p_end_dt}'
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
            ON T3.SSYS = 'HSFA'
           AND T3.SRC_DICT_CLS_CD = 'L_ZQLB' --源字典分类
           AND T1.L_ZQLB = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
           AND T3.VALID_FLAG = '1' --有效标志
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
            ON T4.SSYS = 'HSFA'
           AND T4.SRC_DICT_CLS_CD = 'L_SCLB' --源字典分类
           AND T1.L_SCLB = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
           AND T4.VALID_FLAG = '1' --有效标志
          LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T5 --证券编码映射
            ON T2.SCR_NUM = T5.SCR_NUM --证券编码
           AND T5.SSYS = 'O32'
           AND T5.ST_DATE <= '${p_end_dt}'
           AND T5.END_DATE >= '${p_end_dt}'
           AND T5.VALID_FLAG = '1' --有效标志
           AND T5.P_DT = '${p_end_dt}'
          LEFT JOIN ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD T6 --证券信息表
            ON T5.SCR_INCD = T6.VC_INTER_CODE
           AND T6.P_DT = '${p_end_dt}'
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
            ON T7.SSYS = 'O32'
           AND T7.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
           AND T6.VC_TRADE_CURRENCY_NO = T7.SRC_DICT_CLS_CDVAL --源字典分类码值
           AND T7.VALID_FLAG = '1' --有效标志
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
            ON T8.SSYS = 'HSFA'
           AND T8.SRC_DICT_CLS_CD = 'C_ZQZT' --源字典分类
           AND T1.C_ZQZT = T8.SRC_DICT_CLS_CDVAL --源字典分类码值
           AND T8.VALID_FLAG = '1' --有效标志
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
            ON T9.SSYS = 'HSFA'
           AND T9.SRC_DICT_CLS_CD = T3.STD_DICT_CLS_CD_VAL --源字典分类
           AND T1.L_ZQLBMX1 = T9.SRC_DICT_CLS_CDVAL --源字典分类码值
           AND T9.VALID_FLAG = '1' --有效标志
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准字典码值映射
            ON T10.SSYS = 'HSFA'
           AND T10.SRC_DICT_CLS_CD = T3.STD_DICT_CLS_CD_VAL --源字典分类
           AND T1.L_ZQLBMX2 = T10.SRC_DICT_CLS_CDVAL --源字典分类码值
           AND T10.VALID_FLAG = '1' --有效标志
      )T1
WHERE  T1.RN = 1
;

INSERT INTO DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.SCR_NUM
     , T1.SYMBOL
     , T1.SCR_PRI_CATG_CODE
     , T1.SCR_SCD_CATG_CODE
     , T1.TRAN_MKT_CODE
     , T1.SCR_SNAME
     , T1.SCR_FNAME
     , T1.ESNAME
     , T1.SCR_PHTIC
     , T1.TRAN_CRRC_CODE
     , T1.SCR_STAT_CODE
     , T1.ISIN_CODE
     , T1.LIST_DATE
     , T1.LIST_STAT_CODE
     , T1.DELT_DATE
     , T1.VALID_FLAG
     , T1.SSYS
     , T1.SRC_TAB
     , T1.LD_TIME
     , T1.MODIFY_TIME
  FROM (SELECT 
              T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
            , T1.VC_REPORT_CODE                                                             AS SYMBOL                                  --证券代码
            , CASE WHEN T1.C_ASSET_CLASS IS NOT NULL 
                   THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ASSET_CLASS)) 
               END                                                                          AS SCR_PRI_CATG_CODE                       --证券一级分类代码
            , T8.STD_DICT_CLS_CD_VAL                                                        AS SCR_SCD_CATG_CODE                       --证券二级分类代码
            , CASE WHEN T1.C_MARKET_NO IS NOT NULL 
                   THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO)) 
               END                                                                          AS TRAN_MKT_CODE                           --交易市场代码
            , T1.VC_STOCK_NAME                                                              AS SCR_SNAME                               --证券简称
            , NVL(TRIM(T1.VC_STOCK_FULLNAME),T1.VC_STOCK_NAME)                              AS SCR_FNAME                               --证券全称
            , NULL                                                                          AS ESNAME                                  --英文简称
            , T1.VC_STOCK_SPELL                                                             AS SCR_PHTIC                               --证券拼音
            , CASE WHEN T1.VC_TRADE_CURRENCY_NO IS NOT NULL 
                   THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_TRADE_CURRENCY_NO)) 
               END                                                                          AS TRAN_CRRC_CODE                          --交易币种代码
            , NULL                                                                          AS SCR_STAT_CODE                           --证券状态代码
            , NULL                                                                          AS ISIN_CODE                               --ISIN代码
            , T1.L_PUBLISH_DATE                                                             AS LIST_DATE                               --上市日期
            , NULL                                                                          AS LIST_STAT_CODE                          --上市状态代码
            , NULL                                                                          AS DELT_DATE                               --退市日期
            , '1'                                                                           AS VALID_FLAG                              --有效标志
            , 'O32'                                                                         AS SSYS                                    --源系统
            , 'ODS_O32_TSTOCKINFO_PFD'                                                      AS SRC_TAB                                 --源表
            , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
            , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
            , ROW_NUMBER() OVER(PARTITION BY T2.SCR_NUM  ORDER BY T2.SCR_NUM ) RN
         FROM (SELECT T10.VC_INTER_CODE
                    , CASE WHEN SUBSTR(T10.VC_REPORT_CODE, 0, 2) = 'BD' 
                           THEN SUBSTR(T10.VC_REPORT_CODE, 3, LENGTH(T10.VC_REPORT_CODE))
                           WHEN SUBSTR(T10.VC_REPORT_CODE, 0, 1) = 'O' 
                           THEN SUBSTR(T10.VC_REPORT_CODE, 2, LENGTH(T10.VC_REPORT_CODE))
                           ELSE T10.VC_REPORT_CODE
                       END                         AS VC_REPORT_CODE
                   , T10.C_MARKET_NO
                   , CASE WHEN T10.C_STOCK_TYPE = '[' AND T10.C_ASSET_CLASS = '4'  
                          THEN '13'  --信托理财
                          WHEN T10.C_STOCK_TYPE = 'U' AND T10.C_ASSET_CLASS = '4'  
                          THEN '13'  --理财
                          WHEN T10.C_STOCK_TYPE = 'n' AND T10.C_ASSET_CLASS = '6'  
                          THEN '3'   --增发债
                          WHEN T10.C_STOCK_TYPE = 'E' AND T10.C_ASSET_CLASS = '8'  
                          THEN '22'   --存款
                          WHEN T10.C_STOCK_TYPE = 'w' AND T10.C_ASSET_CLASS = '6'  
                          THEN '23'   --指数
                          WHEN T10.C_STOCK_TYPE = '8'  AND T10.C_ASSET_CLASS ='6'     
                          THEN '5'
                          WHEN T10.C_STOCK_TYPE = 'I'  AND T10.C_ASSET_CLASS ='6'     
                          THEN '5'  --回购
                          WHEN T10.C_STOCK_TYPE = 'k'  AND T10.C_ASSET_CLASS ='6'     
                          THEN '3' 
                          ELSE T10.C_ASSET_CLASS 
                     END          AS C_ASSET_CLASS
                   , T10.C_STOCK_TYPE
                   , T10.VC_STOCK_NAME
                   , T10.VC_TRADE_CURRENCY_NO
                   , T10.VC_STOCK_FULLNAME
                   , T10.VC_STOCK_SPELL
                   , T10.L_PUBLISH_DATE
                FROM ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD T10  --证券信息表
               WHERE  T10.P_DT = '${p_end_dt}' 
             )T1  
        INNER JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2 --证券编码映射
           ON T1.VC_INTER_CODE = T2.SCR_INCD --证券内码
          AND T2.SSYS = 'O32'
          AND T2.ST_DATE <= '${p_end_dt}'
          AND T2.END_DATE >= '${p_end_dt}'
          AND T2.VALID_FLAG = '1' --有效标志
          AND T2.P_DT = '${p_end_dt}'
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
           ON T3.SSYS = 'O32'
          AND T3.SRC_DICT_CLS_CD = 'C_ASSET_CLASS' --源字典分类
          AND T1.C_ASSET_CLASS = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T3.VALID_FLAG = '1' --有效标志
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
           ON T4.SSYS = 'O32'
          AND T4.SRC_DICT_CLS_CD = 'C_MARKET_NO' --源字典分类
          AND T1.C_MARKET_NO = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T4.VALID_FLAG = '1' --有效标志
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
           ON T7.SSYS = 'O32'
          AND T7.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
          AND T1.VC_TRADE_CURRENCY_NO = T7.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T7.VALID_FLAG = '1' --有效标志
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
           ON T8.SSYS = 'O32'
          AND T8.SRC_DICT_CLS_CD = 'C_STOCK_TYPE' --源字典分类
          AND T1.C_STOCK_TYPE = T8.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T8.VALID_FLAG = '1' --有效标志
         LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T9  --证券基本信息
           ON T2.SCR_NUM = T9.SCR_NUM
          AND T9.P_DT = '${p_end_dt}'
        WHERE T9.SCR_NUM IS NULL
        )T1
WHERE  T1.RN = 1
;



INSERT INTO DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.SCR_NUM
     , T1.SYMBOL
     , T1.SCR_PRI_CATG_CODE
     , T1.SCR_SCD_CATG_CODE
     , T1.TRAN_MKT_CODE
     , T1.SCR_SNAME
     , T1.SCR_FNAME
     , T1.ESNAME
     , T1.SCR_PHTIC
     , T1.TRAN_CRRC_CODE
     , T1.SCR_STAT_CODE
     , T1.ISIN_CODE
     , T1.LIST_DATE
     , T1.LIST_STAT_CODE
     , T1.DELT_DATE
     , T1.VALID_FLAG
     , T1.SSYS
     , T1.SRC_TAB
     , T1.LD_TIME
     , T1.MODIFY_TIME  
  FROM DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T1
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T2
    ON T1.SCR_NUM = T2.SCR_NUM
   AND T2.P_DT = '${p_end_dt}'
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
   AND T2.SCR_NUM IS NULL 
;
"
