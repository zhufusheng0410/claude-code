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
-- ** 描述:产品角色信息
-- ** 创建者:auto
-- ** 创建日期:2023-07-04
-- ** 修改日志:
-- ** 2023-07-04，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD  产品角色信息
-- ** 源表：  ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD 专户手工信息
-- **         ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_FUND_PFD 官网基金经理
-- **         ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_PFD
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD 产品基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , NULL                                                                          AS PTY_NUM                                 --主体编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , '01'                                                                          AS ROLE_TYPE_CODE                          --角色类型代码
     , T1.PROD_MNGR                                                                  AS PTY_NAME                                --主体名称
     , CASE WHEN SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            ELSE
              SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8)
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            WHEN LENGTH (REGEXP_EXTRACT (T1.EXPE_END_DATE,'[\u4e00-\u9fff]+', 0)) = 0 THEN --不含中文,纯日期
              SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8)
            ELSE --含中文,直接取中文内容
              T1.EXPE_END_DATE
        END                                                                          AS END_DATE                                --结束日期
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
WHERE T1.P_DT = '${p_end_dt}'
  AND T1.PROD_MNGR IS NOT NULL
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , NULL                                                                          AS PTY_NUM                                 --主体编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , '02'                                                                          AS ROLE_TYPE_CODE                          --角色类型代码
     , T1.AVL_CONT_SALE_PRSN                                                         AS PTY_NAME                                --主体名称
     , CASE WHEN SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            ELSE
              SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8)
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            WHEN LENGTH (REGEXP_EXTRACT (T1.EXPE_END_DATE,'[\u4e00-\u9fff]+', 0)) = 0 THEN --不含中文,纯日期
              SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8)
            ELSE --含中文,直接取中文内容
              T1.EXPE_END_DATE
        END                                                                          AS END_DATE                                --结束日期
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
WHERE T1.P_DT = '${p_end_dt}'
  AND T1.AVL_CONT_SALE_PRSN IS NOT NULL
;
INSERT INTO DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , NULL                                                                          AS PTY_NUM                                 --主体编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , '03'                                                                          AS ROLE_TYPE_CODE                          --角色类型代码
     , T1.ASIT_MAG                                                                   AS PTY_NAME                                --主体名称
     , CASE WHEN SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            ELSE
              SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8)
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            WHEN LENGTH (REGEXP_EXTRACT (T1.EXPE_END_DATE,'[\u4e00-\u9fff]+', 0)) = 0 THEN --不含中文,纯日期
              SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8)
            ELSE --含中文,直接取中文内容
              T1.EXPE_END_DATE
        END                                                                          AS END_DATE                                --结束日期
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
WHERE T1.P_DT = '${p_end_dt}'
  AND T1.ASIT_MAG IS NOT NULL
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , NULL                                                                          AS PTY_NUM                                 --主体编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , '04'                                                                          AS ROLE_TYPE_CODE                          --角色类型代码
     , T1.INV_MNGR                                                                   AS PTY_NAME                                --主体名称
     , CASE WHEN SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            ELSE
              SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8)
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            WHEN LENGTH (REGEXP_EXTRACT (T1.EXPE_END_DATE,'[\u4e00-\u9fff]+', 0)) = 0 THEN --不含中文,纯日期
              SUBSTR(REPLACE(T1.EXPE_END_DATE,'-',''),1,8)
            ELSE --含中文,直接取中文内容
              T1.EXPE_END_DATE
        END                                                                          AS END_DATE                                --结束日期
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
WHERE T1.P_DT = '${p_end_dt}'
  AND T1.INV_MNGR IS NOT NULL
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T3.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUND_MANAGER_ID                                                          AS PTY_NUM                                 --主体编码
     , T1.C_INDEX_FUNDCODE                                                           AS PROD_CODE                               --产品代码
     , '04'                                                                          AS ROLE_TYPE_CODE                          --角色类型代码
     , T2.C_NAME                                                                     AS PTY_NAME                                --主体名称
     , CASE WHEN SUBSTR(REPLACE(T1.D_BEGIN_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            ELSE
              SUBSTR(REPLACE(T1.D_BEGIN_DATE,'-',''),1,8)
       END                                                                           AS ST_DATE                                 --开始日期
     , CASE WHEN SUBSTR(REPLACE(T1.D_END_DATE,'-',''),1,8) IN('20991231','99990101') THEN 
              '29991231'
            WHEN LENGTH (REGEXP_EXTRACT (T1.D_END_DATE,'[\u4e00-\u9fff]+', 0)) = 0 THEN --不含中文,纯日期
              SUBSTR(REPLACE (T1.D_END_DATE,'-',''),1,8)
            ELSE--含中文,直接取中文内容
              T1.D_END_DATE
       END                                                                          AS END_DATE                                --结束日期
     , CASE WHEN NVL(T1.D_END_DATE,'29991231') >= '${p_end_dt}'
            THEN '1'
            ELSE '0'
       END                                                                           AS VALID_FLAG                              --有效标志
     , 'OFFW'                                                                        AS SSYS                                    --源系统
     , 'ODS_OFFW_WN_FUND_MANAGER_FUND_PFD'                                           AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_FUND_PFD T1  --官网基金经理
  LEFT JOIN ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_PFD T2 --
    ON T1.C_FUND_MANAGER_ID = T2.C_FUND_MANAGER_ID
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息
    ON T1.C_INDEX_FUNDCODE = T3.PROD_CODE
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
   AND  T2.C_NAME IS NOT NULL
;
"
