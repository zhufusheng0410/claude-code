1#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "


-- **************************************************************************
-- ** 主题: 交易
-- ** 描述: 市场交易申请
-- ** 创建者 : zhufs
-- ** 创建日期: 20230425
-- ** 修改日志:
-- ** 20230425，zhufs，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_MKT_TRAN_REQ_PTD 市场交易申请
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TREQUEST_PTD  交易申请
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TREQUEST_PTD  交易申请
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
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
set mapreduce.job.reduces=3;

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_MKT_TRAN_REQ_PTD PARTITION(P_DT)
SELECT 
       T1.D_REQUESTDATE                                                         AS REQ_DATE               --申请日期
     , T1.D_REQUESTTIME                                                         AS REQ_TIME               --申请时间
     , T1.C_REQUESTNO                                                           AS REQ_NO                 --申请编号
     , T1.C_FUNDACCO                                                            AS FUND_ACCO              --基金账号
     , T1.C_TRADEACCO                                                           AS TRAN_ACCO              --交易账号
     , CASE
         WHEN T2.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_BUSINFLAG)
         ELSE
          T2.STD_DICT_CLS_CD_VAL
       END                                                                      AS BUSIN_TYPE_CODE        --业务类型代码
     , NULL                                                                     AS CHNL_NUM               --渠道编码
     , T1.C_AGENCYNO                                                            AS AGENCY_INCD            --销售商内码
     , T1.C_NETNO                                                               AS BTCH_NO                --网点编号
     , T8.PROD_NUM                                                              AS PROD_NUM               --产品编码
     , T1.C_FUNDCODE                                                            AS PROD_CODE              --产品代码
     , CASE
         WHEN T3.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_SHARETYPE)
         ELSE
          T3.STD_DICT_CLS_CD_VAL
       END                                                                      AS SHARE_CATG_CODE        --份额类别代码
     , T1.F_BALANCE                                                             AS REQ_AMT                --申请金额
     , T1.F_SHARES                                                              AS REQ_SHARE              --申请份额
     , CASE
         WHEN T4.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_ACCEPTMODE)
         ELSE
          T4.STD_DICT_CLS_CD_VAL
       END                                                                      AS TRAN_MODE_CODE         --交易方式代码
     , T1.C_OTHERCODE                                                           AS OTHS_PROD_CODE         --对方产品代码
     , CASE
         WHEN T5.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_OTHERSHARE)
         ELSE
          T5.STD_DICT_CLS_CD_VAL
       END                                                                      AS OTHS_SHARE_CATG        --对方份额类别
     , T1.C_OTHERACCO                                                           AS OTHS_FUND_ACCO         --对方基金账号
     , T1.C_OTHERTRADEACCO                                                      AS OTHS_TRAN_ACCO         --对方交易账号
     , T1.C_OTHERAGENCY                                                         AS OTHS_AGENCY_INCD       --对方销售商内码
     , T1.C_OTHERNETNO                                                          AS OTHS_BTCH              --对方网点
     , T1.C_EXCEEDFLAG                                                          AS VAST_REDEM_DEAL_FLAG   --巨额赎回处理标志
     , T1.F_AGIO                                                                AS AGIO                   --费率折扣
     , CASE
         WHEN T6.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_BONUSTYPE)
         ELSE
          T6.STD_DICT_CLS_CD_VAL
       END                                                                      AS BONUS_MODE_CODE        --分红方式代码
     , CASE
         WHEN T7.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_FREEZECAUSE)
         ELSE
          T7.STD_DICT_CLS_CD_VAL
       END                                                                      AS FRZ_CAUSE_CODE         --冻结原因代码
     , T1.C_FREEZEENDDATE                                                       AS FRZ_END_DATE           --冻结截止日期
     , T1.C_FREEZENO                                                            AS FRZ_LEGAL_FILE_NO      --冻结法律文书号
     , T1.C_ORIREQUESTNO                                                        AS ORI_REQ_NO             --原申请编号
     , T1.C_PROTOCOLNO                                                          AS AGR_NO                 --协议号
     , T1.C_CHILDNETNO                                                          AS OPER_BTCH_NO           --操作网点编号
     , T1.C_CITYNO                                                              AS CITY_NO                --城市编号(地区)
     , T1.C_TAFLAG                                                              AS TA_SPON_FLAG           --TA发起标志
     , T1.F_CONFIRMBALANCE                                                      AS CNFM_TOT_AMT           --确认总金额
     , T1.F_CONFIRMSHARES                                                       AS CNFM_TOT_SHARE         --确认总份额
     , T1.C_REQTRADEACCO                                                        AS REQ_TRAN_ACCO          --申请交易账号
     , T1.C_TACODE                                                              AS TA_CODE                --TA代码
     , 'HSZTA'                                                                  AS SSYS                   --源系统
     , 'ODS_HSZTA_TREQUEST_PTD'                                                 AS SRC_TAB                --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME                --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME            --修改时间
     , T1.P_DT                                                                  AS P_DT                   --分区值
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TREQUEST_PTD  T1 --交易申请
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T2 --标准字典码值映射
    ON T2.SSYS = 'HSZTA'
   AND T2.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG  = T2.SRC_DICT_CLS_CDVAL 
   AND T2.VALID_FLAG = '1'
 INNER JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T8 --产品编码映射
    ON T1.C_FUNDCODE = T8.PROD_INCD 
   AND T8.SSYS = 'HSZTA' 
   AND T8.ST_DATE <= '${p_end_dt}' 
   AND T8.END_DATE >= '${p_end_dt}' 
   AND T8.VALID_FLAG = '1'  --有效标志
   AND T8.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射 
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE  = T3.SRC_DICT_CLS_CDVAL 
   AND T3.VALID_FLAG ='1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射 
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_ACCEPTMODE'
   AND T1.C_ACCEPTMODE  = T4.SRC_DICT_CLS_CDVAL 
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射 
    ON T5.SSYS= 'HSZTA'
   AND T5.SRC_DICT_CLS_CD= 'C_SHARETYPE'
   AND T1.C_OTHERSHARE  = T5.SRC_DICT_CLS_CDVAL 
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T6 --标准字典码值映射 
    ON T6.SSYS = 'HSZTA'
   AND T6.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE  = T6.SRC_DICT_CLS_CDVAL 
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射 
    ON T7.SSYS = 'HSZTA'
   AND T7.SRC_DICT_CLS_CD = 'C_FREEZECAUSE'
   AND T1.C_FREEZECAUSE  = T7.SRC_DICT_CLS_CDVAL 
   AND T7.VALID_FLAG = '1'
 WHERE T1.P_DT  BETWEEN '${p_start_dt}' AND '${p_end_dt}' 
  ;
 
 
 --交易申请
INSERT INTO DWDXDAY.DWD_TRAN_MKT_TRAN_REQ_PTD PARTITION(P_DT)
SELECT 
        T1.D_REQUESTDATE                                                            AS REQ_DATE                 --申请日期
      , T1.D_REQUESTTIME                                                            AS REQ_TIME                 --申请时间
      , T1.C_REQUESTNO                                                              AS REQ_NO                   --申请编号
      , T1.C_FUNDACCO                                                               AS FUND_ACCO                --基金账号
      , T1.C_TRADEACCO                                                              AS TRAN_ACCO                --交易账号
      , CASE
         WHEN T2.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_BUSINFLAG)
         ELSE
          T2.STD_DICT_CLS_CD_VAL
        END                                                                         AS BUSIN_TYPE_CODE          --业务类型代码
      , NULL                                                                        AS CHNL_NUM                 --渠道编码
      , T1.C_AGENCYNO                                                               AS AGENCY_INCD              --销售商内码
      , T1.C_NETNO                                                                  AS BTCH_NO                  --网点编号
      , T8.PROD_NUM                                                                 AS PROD_NUM                 --产品编码
      , T1.C_FUNDCODE                                                               AS PROD_CODE                --产品代码
      , CASE
         WHEN T3.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_SHARETYPE)
         ELSE
          T3.STD_DICT_CLS_CD_VAL
        END                                                                         AS SHARE_CATG_CODE          --份额类别代码
      , T1.F_BALANCE                                                                AS REQ_AMT                  --申请金额
      , T1.F_SHARES                                                                 AS REQ_SHARE                --申请份额
      , CASE
         WHEN T4.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_ACCEPTMODE)
         ELSE
          T4.STD_DICT_CLS_CD_VAL
        END                                                                         AS TRAN_MODE_CODE           --交易方式代码
      , T1.C_OTHERCODE                                                              AS OTHS_PROD_CODE           --对方产品代码
      , CASE
         WHEN T5.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_OTHERSHARE)
         ELSE
          T5.STD_DICT_CLS_CD_VAL
        END                                                                         AS OTHS_SHARE_CATG          --对方份额类别
      , T1.C_OTHERACCO                                                              AS OTHS_FUND_ACCO           --对方基金账号
      , T1.C_OTHERTRADEACCO                                                         AS OTHS_TRAN_ACCO           --对方交易账号
      , T1.C_OTHERAGENCY                                                            AS OTHS_AGENCY_INCD         --对方销售商内码
      , T1.C_OTHERNETNO                                                             AS OTHS_BTCH                --对方网点
      , T1.C_EXCEEDFLAG                                                             AS VAST_REDEM_DEAL_FLAG     --巨额赎回处理标志
      , T1.F_AGIO                                                                   AS AGIO                     --费率折扣
      , CASE
         WHEN T6.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_BONUSTYPE)
         ELSE
          T6.STD_DICT_CLS_CD_VAL
        END                                                                         AS BONUS_MODE_CODE          --分红方式代码
      , CASE
         WHEN T7.STD_DICT_CLS_CD_VAL IS NULL THEN
          CONCAT('@', T1.C_FREEZECAUSE)
         ELSE
          T7.STD_DICT_CLS_CD_VAL
        END                                                                         AS FRZ_CAUSE_CODE           --冻结原因代码
      , T1.C_FREEZEENDDATE                                                          AS FRZ_END_DATE             --冻结截止日期
      , T1.C_FREEZENO                                                               AS FRZ_LEGAL_FILE_NO        --冻结法律文书号
      , T1.C_FORIGINALNO                                                            AS ORI_REQ_NO               --原申请编号
      , T1.C_PROTOCOLNO                                                             AS AGR_NO                   --协议号
      , T1.C_CHILDNETNO                                                             AS OPER_BTCH_NO             --操作网点编号
      , T1.C_CITYNO                                                                 AS CITY_NO                  --城市编号(地区)
      , T1.C_TAFLAG                                                                 AS TA_SPON_FLAG             --TA发起标志
      , T1.F_CONFIRMBALANCE                                                         AS CNFM_TOT_AMT             --确认总金额
      , T1.F_CONFIRMSHARES                                                          AS CNFM_TOT_SHARE           --确认总份额
      , T1.C_RESERVE                                                                AS REQ_TRAN_ACCO            --申请交易账号
      , T1.C_TACODE                                                                 AS TA_CODE                  --TA代码
      , 'HSFTA'                                                                     AS SSYS                     --源系统
      , 'ODS_HSFTA_TREQUEST_PTD'                                                    AS SRC_TAB                  --源表
      , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')    AS LD_TIME                  --加载时间
      , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')    AS MODIFY_TIME              --修改时间
      , T1.P_DT                                                                     AS P_DT                     --分区值
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TREQUEST_PTD  T1 --交易申请
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T2 --标准字典码值映射
    ON T2.SSYS = 'HSFTA'
   AND T2.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG  = T2.SRC_DICT_CLS_CDVAL 
   AND T2.VALID_FLAG = '1'
  INNER JOIN  DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD  T8 --产品编码映射
    ON T1.C_FUNDCODE = T8.PROD_INCD 
   AND T8.SSYS = 'HSFTA' 
   AND T8.ST_DATE <= '${p_end_dt}' 
   AND T8.END_DATE >= '${p_end_dt}' 
   AND T8.VALID_FLAG = '1'  --有效标志
   AND T8.P_DT = '${p_end_dt}' 
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T3 --标准字典码值映射 
    ON T3.SSYS = 'HSFTA'
   AND T3.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE  = T3.SRC_DICT_CLS_CDVAL 
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T4 --标准字典码值映射
    ON T4.SSYS = 'HSFTA'
   AND T4.SRC_DICT_CLS_CD = 'C_ACCEPTMODE'
   AND T1.C_ACCEPTMODE  = T4.SRC_DICT_CLS_CDVAL 
   AND T4.VALID_FLAG = '1'
  LEFT JOIN  DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T5 --标准字典码值映射 
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_OTHERSHARE  = T5.SRC_DICT_CLS_CDVAL 
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T6 --标准字典码值映射 
    ON T6.SSYS = 'HSFTA'
   AND T6.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE  = T6.SRC_DICT_CLS_CDVAL 
   AND T6.VALID_FLAG = '1'
  LEFT JOIN  DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T7 --标准字典码值映射
    ON T7.SSYS = 'HSFTA'
   AND T7.SRC_DICT_CLS_CD = 'C_FREEZECAUSE'
   AND T1.C_FREEZECAUSE  = T7.SRC_DICT_CLS_CDVAL 
   AND T7.VALID_FLAG = '1'
 WHERE T1.P_DT  BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;"
