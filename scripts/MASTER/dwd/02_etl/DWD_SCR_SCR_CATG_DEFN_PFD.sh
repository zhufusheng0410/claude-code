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
-- ** 描述:证券分类定义
-- ** 创建者:auto
-- ** 创建日期:2023-06-29
-- ** 修改日志:
-- ** 2023-06-29，auto，新建
-- ** 目标表：DWDXDAY.DWD_SCR_SCR_CATG_DEFN_PFD  证券分类定义
-- ** 源表：  ODS_XDAY_O32.ODS_O32_TSTOCKTYPE_PFD 证券类别
-- **         ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD 证券信息
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD HSFA业务证券内码
-- **************************************************************************

set hive.strict.checks.type.safety=false;
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


INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_SCR_CATG_DEFN_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT
       'HSFA_SCR_CATG_CODE'                                                          AS CATG_CALIBRE_CODE                       --分类口径代码
     , 'HSFA证券分类代码'                                                            AS CATG_CALIBRE_NAME                       --分类口径名称
     , T3.STD_DICT_CLS_CD_VAL                                                        AS CATG_CODE                               --分类代码
     , T3.STD_DICT_CLS_CDVAL_DESC                                                    AS CATG_NAME                               --分类名称
     , '1'                                                                           AS CATG_LVL                                --分类层级
     , NULL                                                                          AS PRN_CATG_CODE                           --父分类代码
     , NULL                                                                          AS PRN_CATG_NAME                           --父分类名称
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'HSFA'                                                                        AS SSYS                                    --源系统
     , 'ODS_HSFA_TZQXX_PFD'                                                          AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T1  --证券信息
 INNER JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD T2 --HSFA业务证券内码
    ON T1.L_ZQNM = T2.SCR_INCD
   AND T2.P_DT = '${p_end_dt}' 
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSFA'
   AND T3.SRC_DICT_CLS_CD = 'L_ZQLB' --源字典分类
   AND T1.L_ZQLB = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T3.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT = '${p_end_dt}' 
;
INSERT INTO DWDXDAY.DWD_SCR_SCR_CATG_DEFN_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT
       'HSFA_SCR_CATG_CODE'                                                          AS CATG_CALIBRE_CODE                       --分类口径代码
     , 'HSFA证券分类代码'                                                            AS CATG_CALIBRE_NAME                       --分类口径名称
     , CASE WHEN T1.L_ZQLB = '7' 
            THEN '1001' 
            ELSE NVL(T4.STD_DICT_CLS_CD_VAL,T5.STD_DICT_CLS_CD_VAL) 
       END                                                                           AS CATG_CODE                               --分类代码
     , CASE WHEN  T1.L_ZQLB = '7'  
            THEN '股指期货'
            ELSE  NVL(T4.STD_DICT_CLS_CDVAL_DESC, T5.STD_DICT_CLS_CDVAL_DESC)                 
       END                                                                           AS CATG_NAME                               --分类名称
     , '2'                                                                           AS CATG_LVL                                --分类层级
     , T3.STD_DICT_CLS_CD_VAL                                                        AS PRN_CATG_CODE                           --父分类代码
     , T3.STD_DICT_CLS_CDVAL_DESC                                                    AS PRN_CATG_NAME                           --父分类名称
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'HSFA'                                                                        AS SSYS                                    --源系统
     , 'ODS_HSFA_TZQXX_PFD'                                                          AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM (SELECT DISTINCT T10.L_ZQLB
             , T10.L_ZQLBMX1
             , T10.L_ZQLBMX2
          FROM ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD  T10 --证券信息 
         INNER JOIN DWDXDAY.DWD_SCR_HSFA_SCR_INCD_PFD T11 --HSFA业务证券内码
            ON T10.L_ZQNM = T11.SCR_INCD
           AND T11.P_DT = '${p_end_dt}'
         WHERE T10.P_DT = '${p_end_dt}'
       ) T1 
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
;

INSERT INTO DWDXDAY.DWD_SCR_SCR_CATG_DEFN_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT
       'O32_SCR_CATG_CODE'                                                           AS CATG_CALIBRE_CODE                       --分类口径代码
     , 'O32证券分类代码'                                                             AS CATG_CALIBRE_NAME                       --分类口径名称
     , T3.STD_DICT_CLS_CD_VAL                                                        AS CATG_CODE                               --分类代码
     , T3.STD_DICT_CLS_CDVAL_DESC                                                    AS CATG_NAME                               --分类名称
     , '1'                                                                           AS CATG_LVL                                --分类层级
     , NULL                                                                          AS PRN_CATG_CODE                           --父分类代码
     , NULL                                                                          AS PRN_CATG_NAME                           --父分类名称
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TSTOCKTYPE_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM (SELECT DISTINCT CASE WHEN T10.C_STOCK_TYPE = '[' AND T10.C_ASSET_CLASS = '4'  
                   THEN'13'  --信托理财
                   WHEN T10.C_STOCK_TYPE = 'U' AND T10.C_ASSET_CLASS = '4'  
                   THEN '13'  --理财
                   WHEN T10.C_STOCK_TYPE = 'n' AND T10.C_ASSET_CLASS = '6'  
                   THEN '3'   --增发债
                   WHEN T10.C_STOCK_TYPE = 'E' AND T10.C_ASSET_CLASS = '8'  
                   THEN '14'   --存款
                   WHEN T10.C_STOCK_TYPE = 'w' AND T10.C_ASSET_CLASS = '6'  
                   THEN '15'   --指数
                   WHEN T10.C_STOCK_TYPE = '8'  AND T10.C_ASSET_CLASS ='6'     
                   THEN '5'
                   WHEN T10.C_STOCK_TYPE = 'I'  AND T10.C_ASSET_CLASS ='6'     
                   THEN '5'  --回购
                   WHEN T10.C_STOCK_TYPE = 'k'  AND T10.C_ASSET_CLASS ='6'     
                   THEN '3' 
                   ELSE T10.C_ASSET_CLASS 
              END          AS C_ASSET_CLASS
       FROM  ODS_XDAY_O32.ODS_O32_TSTOCKTYPE_PFD T10  --证券类别
      WHERE T10.P_DT = '${p_end_dt}' 
     )T1
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'O32'
   AND T3.SRC_DICT_CLS_CD = 'C_ASSET_CLASS' --源字典分类
   AND T1.C_ASSET_CLASS = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T3.VALID_FLAG = '1' --有效标志
;

INSERT INTO DWDXDAY.DWD_SCR_SCR_CATG_DEFN_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT
       'O32_SCR_CATG_CODE'                                                           AS CATG_CALIBRE_CODE                       --分类口径代码
     , 'O32证券分类代码'                                                             AS CATG_CALIBRE_NAME                       --分类口径名称
     , T4.STD_DICT_CLS_CD_VAL                                                        AS CATG_CODE                               --分类代码
     , T4.STD_DICT_CLS_CDVAL_DESC                                                    AS CATG_NAME                               --分类名称
     , '2'                                                                           AS CATG_LVL                                --分类层级
     , T3.STD_DICT_CLS_CD_VAL                                                        AS PRN_CATG_CODE                           --父分类代码
     , T3.STD_DICT_CLS_CDVAL_DESC                                                    AS PRN_CATG_NAME                           --父分类名称
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TSTOCKTYPE_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM (SELECT DISTINCT CASE WHEN T10.C_STOCK_TYPE = '[' AND T10.C_ASSET_CLASS = '4'  
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
                   THEN '5'
                   WHEN T10.C_STOCK_TYPE = 'I'  AND T10.C_ASSET_CLASS ='6'     
                   THEN '5'  --回购
                   WHEN T10.C_STOCK_TYPE = 'k'  AND T10.C_ASSET_CLASS ='6'     
                   THEN '3' 
                   ELSE T10.C_ASSET_CLASS 
              END          AS C_ASSET_CLASS
           ,  C_STOCK_TYPE
       FROM  ODS_XDAY_O32.ODS_O32_TSTOCKTYPE_PFD T10  --证券类别
      WHERE T10.P_DT = '${p_end_dt}' 
     )T1
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'O32'
   AND T3.SRC_DICT_CLS_CD = 'C_ASSET_CLASS' --源字典分类
   AND T1.C_ASSET_CLASS = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T3.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'O32'
   AND T4.SRC_DICT_CLS_CD = 'C_STOCK_TYPE' --源字典分类
   AND T1.C_STOCK_TYPE = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T4.VALID_FLAG = '1' --有效标志
;
"
