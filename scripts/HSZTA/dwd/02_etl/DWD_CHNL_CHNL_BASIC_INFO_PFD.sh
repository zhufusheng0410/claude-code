#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:渠道
-- ** 描述:渠道基本信息
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD  渠道基本信息
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD   销售商信息
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD   销售商信息
-- **         DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  机构编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
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
INSERT OVERWRITE TABLE DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.ORG_NUM                                                                    AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_AGENCYNAME                                                               AS CHNL_NAME                               --渠道名称
     , T1.C_AGENCYADDRESS                                                            AS HQ_ADDR                                 --总部地址
     , T1.C_AGENCYZIPCODE                                                            AS PTCD                                    --邮政编码
     , T1.C_AGEREGION                                                                AS BELT_COUNTRY_AREA                       --所属国家地区
     , T1.C_REGADDRESS                                                               AS REG_ADDR                                --注册地址
     , T1.C_LEGALREPRESEN                                                            AS LEGA_REPST                              --法定代表人
     , T1.C_CUSTSERTEL                                                               AS SERV_SERVI_TEL                          --客服服务电话
     , T1.C_URL                                                                      AS WEB                                     --网址
     , T1.C_AGENCYCONTACT                                                            AS CHNL_CNTA_NAME                          --渠道联系姓名
     , T1.C_AGENCYPHONE                                                              AS CHNL_PHONE                              --渠道联系电话
     , T1.C_AGENCYFAXNO                                                              AS CHNL_FAX                                --渠道传真号码
     , T1.C_AGENCYMAIL                                                               AS CHNL_EML                                --渠道Email
     , CASE WHEN T1.C_AGENCYSTATUS IS NOT NULL 
              THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_AGENCYSTATUS)) 
        END                                                                          AS CHNL_STAT_CODE                          --渠道状态代码
     , CASE WHEN T1.C_AGENCYTYPE IS NOT NULL 
              THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_AGENCYTYPE)) 
        END                                                                          AS CHNL_TYPE_CODE                          --渠道类型代码
     , CASE WHEN T1.C_AGENCYQRYTYPE IS NOT NULL 
              THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_AGENCYQRYTYPE)) 
        END                                                                          AS CHNL_CATG_CODE                          --渠道类别代码
     , T1.C_ZDCODE                                                                   AS CHA_SCR_REG_CENT_CODE                   --中国证券登记中心代码
     , T1.C_AGECREDITCODE                                                            AS SALE_ORG_SOCI_CREDIT_CODE               --销售机构社会信用代码
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TAGENCYINFO_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD T1  --销售商信息
  LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD T2 --机构编码映射
    ON T1.C_AGENCYNO = T2.ORG_INCD --机构内码
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.SSYS = 'HSZTA' --源系统
   AND T2.SRC_TAB = 'ODS_HSZTA_TAGENCYINFO_PFD' --源表
   AND T2.VALID_FLAG = '1' --有效
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_AGENCYSTATUS'
   AND T1.C_AGENCYSTATUS = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_AGENCYTYPE'
   AND T1.C_AGENCYTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_AGENCYQRYTYPE'
   AND T1.C_AGENCYQRYTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.ORG_NUM                                                                    AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_AGENCYNAME                                                               AS CHNL_NAME                               --渠道名称
     , T1.C_AGNCYADDRESS                                                             AS HQ_ADDR                                 --总部地址
     , T1.C_AGNCYZIPCODE                                                             AS PTCD                                    --邮政编码
     , T1.C_AGEREGION                                                                AS BELT_COUNTRY_AREA                       --所属国家地区
     , NULL                                                                          AS REG_ADDR                                --注册地址
     , NULL                                                                          AS LEGA_REPST                              --法定代表人
     , NULL                                                                          AS SERV_SERVI_TEL                          --客服服务电话
     , NULL                                                                          AS WEB                                     --网址
     , T1.C_AGNCYCONTACT                                                             AS CHNL_CNTA_NAME                          --渠道联系姓名
     , T1.C_AGNCYPHONE                                                               AS CHNL_PHONE                              --渠道联系电话
     , T1.C_AGNCYFAXNO                                                               AS CHNL_FAX                                --渠道传真号码
     , T1.C_AGNCYMAIL                                                                AS CHNL_EML                                --渠道Email
     , CASE WHEN T1.C_AGNCYSTATUS IS NOT NULL 
              THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_AGNCYSTATUS)) 
        END                                                                          AS CHNL_STAT_CODE                          --渠道状态代码
     , CASE WHEN T1.C_AGENCYTYPE =0 THEN '01' ELSE '02' END                                AS CHNL_TYPE_CODE                          --渠道类型代码
     , CASE WHEN T1.C_AGENCYTYPE IS NOT NULL 
              THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_AGENCYTYPE)) 
        END                                                                          AS CHNL_CATG_CODE                          --渠道类别代码
     , T1.C_ZDCODE                                                                   AS CHA_SCR_REG_CENT_CODE                   --中国证券登记中心代码
     , T1.C_AGECREDITCODE                                                            AS SALE_ORG_SOCI_CREDIT_CODE               --销售机构社会信用代码
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TAGENCYINFO_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD T1  --销售商信息
  LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD T2 --机构编码映射
    ON T1.C_AGENCYNO = T2.ORG_INCD --机构内码
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.SSYS = 'HSFTA' --源系统
   AND T2.SRC_TAB = 'ODS_HSFTA_TAGENCYINFO_PFD' --源表
   AND T2.VALID_FLAG = '1' --有效
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSFTA'
   AND T3.SRC_DICT_CLS_CD = 'C_AGNCYSTATUS'
   AND T1.C_AGNCYSTATUS = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFTA'
   AND T4.SRC_DICT_CLS_CD = 'C_AGENCYTYPE'
   AND T1.C_AGENCYTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN  DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T5 --渠道基本信息
    ON T1.C_AGENCYNO = T5.CHNL_INCD
   AND T5.P_DT = '${p_end_dt}'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T5.CHNL_INCD IS NULL
;
"
