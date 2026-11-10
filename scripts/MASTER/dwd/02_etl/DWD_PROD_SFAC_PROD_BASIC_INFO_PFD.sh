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
-- ** 描述:帐套产品基本信息
-- ** 创建者:auto
-- ** 创建日期:2023-05-11
-- ** 修改日志:
-- ** 2023-05-11，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD  帐套产品基本信息
-- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD 基金信息表
-- **         ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD 帐套信息
-- **         ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD 基金信息表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD 帐套编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD 机构编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT T3.SFAC_NUM                                                                   AS SFAC_NUM                                --帐套编码
     , T1.VC_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.VC_NAME                                                                    AS CSNAME                                  --中文简称
     , T1.VC_FULLNAME                                                                AS CNAME                                   --中文全称
     , CASE
          WHEN T4.STD_DICT_CLS_CD_VAL IS NULL THEN
           CONCAT('@', T1.L_CLASS)
          ELSE
           T4.STD_DICT_CLS_CD_VAL
        END                                                                          AS PROD_TYPE_CODE                          --产品类型代码
     , SUBSTR(REPLACE(T1.D_CREATE,'-',''),1,8)                                       AS SETUP_DATE                              --成立日期
     , SUBSTR(REPLACE(T2.D_DESTORY,'-',''),1,8)                                      AS LIQU_DATE                               --清算日期
     , SUBSTR(REPLACE(T1.D_CREATE,'-',''),1,8)                                       AS OPER_ST_DATE                            --运作开始日期
     , SUBSTR(REPLACE(T1.D_DQRQ,'-',''),1,8)                                         AS OPER_END_DATE                           --运作结束日期
     , T5.ORG_NUM                                                                    AS TRUS_NUM                                --托管人编码
     , T1.VC_TGHID                                                                   AS TRUS_INCD                               --托管人内码
     , T1.VC_TGR                                                                     AS TRUS_NAME                               --托管人名称
     , T1.VC_GLR                                                                     AS MGR_NUM                                 --管理人编码
     , CASE 
         WHEN T1.VC_GLR = '50550000' THEN 
          '信达澳亚基金管理有限公司'
         ELSE 
          '信达新兴资产管理有限公司'
       END                                                                           AS MGR_NAME                                --管理人名称
     , 'CNY'                                                                         AS LC_CRRC_CODE                            --本币币种代码
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'HSFA'                                                                        AS SSYS                                    --源系统
     , 'ODS_HSFA_TFUNDINFO_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD T1  --基金信息表
 INNER JOIN ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD T2 --帐套信息
    ON T1.L_FUNDID = T2.L_ID
   AND T2.L_VOID = '0' --有效
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T3 --帐套编码映射
    ON T1.L_FUNDID = T3.SFAC_INCD
   AND T3.SSYS = 'HSFA'
   AND T3.ST_DATE <= '${p_end_dt}'
   AND T3.END_DATE >= '${p_end_dt}'
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFA'
   AND T4.SRC_DICT_CLS_CD = 'L_CLASS'
   AND T1.L_CLASS = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD T5 --机构编码映射
    ON T1.VC_TGHID = T5.ORG_INCD  --机构内码
   AND T5.ST_DATE <= '${p_end_dt}' --开始日期
   AND T5.END_DATE >= '${p_end_dt}' --结束日期
   AND T5.SSYS = 'HSFA' --源系统
   AND T5.SRC_TAB = 'ODS_HSFA_TTGRXX_PFD' --源表
   AND T5.VALID_FLAG = '1'--有效
   --AND T5.P_DT = '${p_end_dt}'
 WHERE T1.P_DT = '${p_end_dt}'
 ;
 
INSERT INTO DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT DISTINCT T3.SFAC_NUM                                                                   AS SFAC_NUM                                --帐套编码
     , T1.VC_FUND_CODE                                                               AS PROD_CODE                               --产品代码
     , T1.VC_FUND_NAME                                                               AS CSNAME                                  --中文简称
     , T1.VC_FUND_CAPTION                                                            AS CNAME                                   --中文全称
     , CASE 
         WHEN T1.VC_FUND_NAME LIKE '%MOM%' THEN 
         'MOM'
         WHEN T1.VC_FUND_NAME LIKE '%单一' OR T1.VC_FUND_NAME LIKE '%集合' THEN 
          'ZH'
       END                                                                           AS PROD_TYPE_CODE                          --产品类型代码
     , T1.L_OPEN_DATE                                                                AS SETUP_DATE                              --成立日期
     , T1.L_END_DATE                                                                 AS LIQU_DATE                               --清盘日期
     , NULL                                                                          AS OPER_ST_DATE                            --运作开始日期
     , NULL                                                                          AS OPER_END_DATE                           --运作结束日期
     , T5.ORG_NUM                                                                    AS TRUS_NUM                                --托管人编码
     , T1.L_LOCAL_CUSTODIAN                                                          AS TRUS_INCD                               --托管人内码
     , T5.ORG_NAME                                                                   AS TRUS_NAME                               --托管人名称
     , '50550000'                                                                    AS MGR_NUM                                 --管理人编码
     , '信达澳亚基金管理有限公司'                                                    AS MGR_NAME                                --管理人名称
     , 'CNY'                                                                         AS LC_CRRC_CODE                            --本币币种代码
     , '1'                                                                           AS VALID_FLAG                              --有效标志
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TFUNDINFO_PFD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD T1  --基金信息表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T2  --帐套产品基本信息
    ON T1.VC_FUND_CODE = T2.PROD_CODE
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T3  ----帐套编码映射
    ON T1.L_FUND_ID = T3.SFAC_INCD
   AND T3.SSYS = 'O32'
   AND T3.ST_DATE <= '${p_end_dt}'
   AND T3.END_DATE >= '${p_end_dt}'
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD T5  --机构编码映射
    ON T1.L_LOCAL_CUSTODIAN = T5.ORG_INCD --机构内码
   AND T5.ST_DATE <= '${p_end_dt}' --开始日期
   AND T5.END_DATE >= '${p_end_dt}' --结束日期
   AND T5.SSYS = 'O32' --源系统
   AND T5.SRC_TAB = 'ODS_O32_TBANKINFO_PFD' --源表
   AND T5.VALID_FLAG = '1' --有效
   --AND T5.P_DT = '${p_end_dt}'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T2.PROD_CODE IS NULL
;"
