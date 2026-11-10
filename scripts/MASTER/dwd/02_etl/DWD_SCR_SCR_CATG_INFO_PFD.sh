

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
-- ** 描述:证券分类信息
-- ** 创建者:auto
-- ** 创建日期:2023-06-29
-- ** 修改日志:
-- ** 2023-06-29，auto，新建
-- ** 目标表：DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD  证券分类信息
-- ** 源表：  ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PTD 证券信息
-- **          ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD 证券信息
-- **          DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD  证券编码映射 
-- **          DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD 证券基本信息 
-- **          DWDXDAY.DWD_SCR_SCR_CATG_DEFN_PFD 证券分类定义 
-- **          DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射 
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


INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT
       T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T6.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , 'HSFA_SCR_CATG_CODE'                                                          AS CATG_CALIBRE_CODE                       --分类口径代码
     , 'HSFA证券分类代码'                                                            AS CATG_CALIBRE_NAME                       --分类口径名称
     , T3.STD_DICT_CLS_CD_VAL                                                       AS SCR_PRI_CATG_CODE                       --证券一级分类代码
     , T3.STD_DICT_CLS_CDVAL_DESC                                                   AS SCR_PRI_CATG_NAME                       --证券一级分类名称
     , CASE WHEN T1.L_ZQLB = '7' 
            THEN '1001' 
            ELSE NVL(T4.STD_DICT_CLS_CD_VAL,T5.STD_DICT_CLS_CD_VAL) 
       END                                                                           AS SCR_SCD_CATG_CODE                       --证券二级分类代码
     , CASE WHEN  T1.L_ZQLB = '7'  
            THEN '股指期货'
            ELSE  NVL(T4.STD_DICT_CLS_CDVAL_DESC, T5.STD_DICT_CLS_CDVAL_DESC)                 
       END                                                                           AS SCR_SCD_CATG_NAME                       --证券二级分类名称
     , '19000101'                                                                    AS ST_DATE                                 --开始日期
     , '29991231'                                                                    AS END_DATE                                --结束日期
     , '1'                                                                           AS VALID_FLAG                              --有效标志
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
        )T1
 INNER JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2 --证券编码映射
    ON T1.L_ZQNM = T2.SCR_INCD --证券内码
   AND T2.SSYS = 'HSFA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = '${p_end_dt}' --分区，具体日期视情况而定
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSFA'
   AND T3.SRC_DICT_CLS_CD = 'L_ZQLB' --源字典分类
   AND T1.L_ZQLB = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T3.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFA'
   AND T4.SRC_DICT_CLS_CD = T3.STD_DICT_CLS_CD_VAL --源字典分类
   AND T1.L_ZQLBMX1 = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T4.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFA'
   AND T5.SRC_DICT_CLS_CD = T3.STD_DICT_CLS_CD_VAL --源字典分类
   AND T1.L_ZQLBMX2 = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T5.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T6 --证券基本信息
    ON T2.SCR_NUM = T6.SCR_NUM
   AND T6.VALID_FLAG = '1' --有效标志
   AND T6.P_DT = '${p_end_dt}' --分区，具体日期视情况而定

;

INSERT INTO DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT SCR_NUM                                 --证券编码
     , SYMBOL                                  --证券代码
     , CATG_CALIBRE_CODE                       --分类口径代码
     , CATG_CALIBRE_NAME                       --分类口径名称
     , SCR_PRI_CATG_CODE                       --证券一级分类代码
     , SCR_PRI_CATG_NAME                       --证券一级分类名称
     , SCR_SCD_CATG_CODE                       --证券二级分类代码
     , SCR_SCD_CATG_NAME                       --证券二级分类名称
     , ST_DATE                                 --开始日期
     , END_DATE                                --结束日期
     , VALID_FLAG                              --有效标志
     , SSYS                                    --源系统
     , SRC_TAB                                 --源表
     , LD_TIME                                 --加载时间
     , MODIFY_TIME                             --修改时间
FROM ( 
       SELECT 
              T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
            , T3.SYMBOL                                                                     AS SYMBOL                                  --证券代码
            , 'O32_SCR_CATG_CODE'                                                           AS CATG_CALIBRE_CODE                       --分类口径代码
            , 'O32证券分类代码'                                                             AS CATG_CALIBRE_NAME                       --分类口径名称
            , T4.STD_DICT_CLS_CD_VAL                                                        AS SCR_PRI_CATG_CODE                       --证券一级分类代码
            , T4.STD_DICT_CLS_CDVAL_DESC                                                    AS SCR_PRI_CATG_NAME                       --证券一级分类名称
            , T5.STD_DICT_CLS_CD_VAL                                                        AS SCR_SCD_CATG_CODE                       --证券二级分类代码
            , T5.STD_DICT_CLS_CDVAL_DESC                                                    AS SCR_SCD_CATG_NAME                       --证券二级分类名称
            , '19000101'                                                                    AS ST_DATE                                 --开始日期
            , '29991231'                                                                    AS END_DATE                                --结束日期
            , '1'                                                                           AS VALID_FLAG                              --有效标志
            , 'O32'                                                                         AS SSYS                                    --源系统
            , 'ODS_O32_TSTOCKINFO_PFD'                                                      AS SRC_TAB                                 --源表
            , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
            , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
            , ROW_NUMBER() OVER(PARTITION BY T2.SCR_NUM ORDER BY T1.L_PUBLISH_DATE DESC  ) RN 
         FROM ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD T1  --证券信息
        INNER JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2 --证券编码映射
           ON T1.VC_INTER_CODE = T2.SCR_INCD --证券内码
          AND T2.SSYS = 'O32'
          AND T2.ST_DATE <= '${p_end_dt}'
          AND T2.END_DATE >= '${p_end_dt}'
          AND T2.VALID_FLAG = '1' --有效标志
          AND T2.P_DT = '${p_end_dt}' --分区，具体日期视情况而定
         LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T3 --证券基本信息
           ON T2.SCR_NUM = T3.SCR_NUM
          AND T3.VALID_FLAG = '1' --有效标志
          AND T3.P_DT = '${p_end_dt}' --分区，具体日期视情况而定
        LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
           ON T4.SSYS = 'O32'
          AND T4.SRC_DICT_CLS_CD = 'C_ASSET_CLASS' --源字典分类
          AND  CASE WHEN T1.C_STOCK_TYPE = '[' AND T1.C_ASSET_CLASS = '4'  
                    THEN'13'  --信托理财
                    WHEN T1.C_STOCK_TYPE = 'U' AND T1.C_ASSET_CLASS = '4'  
                    THEN '13'  --理财
                    WHEN T1.C_STOCK_TYPE = 'n' AND T1.C_ASSET_CLASS = '6'  
                    THEN '3'   --增发债
                    WHEN T1.C_STOCK_TYPE = 'E' AND T1.C_ASSET_CLASS = '8'  
                    THEN '22'   --存款
                    WHEN T1.C_STOCK_TYPE = 'w' AND T1.C_ASSET_CLASS = '6'  
                    THEN '23'   --指数
                    WHEN T1.C_STOCK_TYPE = '8'  AND T1.C_ASSET_CLASS ='6'     
                    THEN '5'
                    WHEN T1.C_STOCK_TYPE = 'I'  AND T1.C_ASSET_CLASS ='6'     
                    THEN '5'  --回购
                    WHEN T1.C_STOCK_TYPE = 'k'  AND T1.C_ASSET_CLASS ='6'     
                    THEN '3' 
                    ELSE T1.C_ASSET_CLASS 
              END = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T4.VALID_FLAG = '1' --有效标志
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
           ON T5.SSYS = 'O32'
          AND T5.SRC_DICT_CLS_CD = 'C_STOCK_TYPE' --源字典分类
          AND T1.C_STOCK_TYPE = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
          AND T5.VALID_FLAG = '1' --有效标志
         WHERE T1.P_DT =  '${p_end_dt}' 
    ) SUBT
WHERE RN = 1
;

INSERT INTO DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.SCR_NUM                                 --证券编码
     , T1.SYMBOL                                  --证券代码
     , T1.CATG_CALIBRE_CODE                       --分类口径代码
     , T1.CATG_CALIBRE_NAME                       --分类口径名称
     , T1.SCR_PRI_CATG_CODE                       --证券一级分类代
     , T1.SCR_PRI_CATG_NAME                       --证券一级分类名
     , T1.SCR_SCD_CATG_CODE                       --证券二级分类代
     , T1.SCR_SCD_CATG_NAME                       --证券二级分类名
     , T1.ST_DATE                                 --开始日期
     , T1.END_DATE                                --结束日期
     , T1.VALID_FLAG                              --有效标志
     , T1.SSYS                                    --源系统
     , T1.SRC_TAB                                 --源表
     , T1.LD_TIME                                 --加载时间
     , T1.MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD T1
  LEFT JOIN  DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD T2
    ON T1.SCR_NUM = T2.SCR_NUM
   AND T1.SSYS = T2.SSYS
   AND T2.P_DT = '${p_end_dt}'
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
   AND T2.SCR_NUM IS NULL
;
"
