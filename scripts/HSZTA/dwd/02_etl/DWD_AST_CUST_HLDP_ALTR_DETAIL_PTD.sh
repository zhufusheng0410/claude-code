#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:资产
-- ** 描述:客户持仓变更明细
-- ** 创建者:auto
-- ** 创建日期:2023-08-09
-- ** 修改日志:
-- ** 2023-08-09，auto，新建
-- ** 目标表：DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD  客户持仓变更明细
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECURRENTS_PTD 份额变化流水
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TSHARECURRENTS_PTD 份额变化流水
-- **         ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD 客户基本信息
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD  产品编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
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

ALTER TABLE DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD DROP PARTITION(P_DT = '${p_end_dt}');
INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
     , T1.C_CSERIALNO                                                                AS CNFM_NO                                 --确认号
     , CASE WHEN T1.C_BUSINFLAG IS NOT NULL 
            THEN COALESCE(T2.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSINFLAG)) 
        END                                                                          AS BUSIN_CODE                              --业务代码
     , T1.D_REQUESTDATE                                                              AS REQ_DATE                                --申请日期
     , T1.C_REQUESTNO                                                                AS REQ_NO                                  --申请编号
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T10.C_CUSTNO                                                                  AS CUST_INCD                               --客户内码
     , T3.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , '01'                                                                          AS TRAN_MKT_CODE                           --交易市场代码(场外)
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
            THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS CHAG_FORM_CODE                          --收费形式代码
     , T1.C_SHARECLASS                                                               AS SHARE_LVL_CODE                          --份额级别代码
     , CASE WHEN T1.C_BONUSTYPE IS NOT NULL 
            THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BONUSTYPE)) 
        END                                                                          AS BONUS_MODE_CODE                         --分红方式代码
     , T1.F_OCCURSHARES                                                              AS THIM_OCCUR_SHARE                        --本次发生份额
     , T1.F_OCCURBALANCE                                                             AS THIM_OCCUR_AMT                          --本次发生金额
     , T1.F_LASTSHARES                                                               AS HOLD_SHARE                              --持有份额
     , T1.F_OCCURFREEZE                                                              AS HOLD_FRZ_OCCUR                          --持有冻结份额
     , T1.F_LASTFREEZESHARE                                                          AS THIM_FRZ_BAL                            --本次冻结余额
     , T1.C_OUTBUSINFLAG                                                             AS EXT_BUSIN_FLAG                          --外部业务标志
     , T1.L_SERIALNO                                                                 AS REQ_SERIALNO                            --申请序号
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TSHARECURRENTS_PTD'                                                AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
     , T1.D_SHAREVALIDDATE                                                           AS SHARE_VALID_DATE                        --份额有效日期
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECURRENTS_PTD T1  --份额变化流水
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2 --标准字典码值映射
    ON T2.SSYS = 'HSZTA'
   AND T2.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG = T2.SRC_DICT_CLS_CDVAL
   AND T2.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T3 --产品编码映射
    ON T1.C_FUNDCODE = T3.PROD_INCD
   AND T3.SSYS = 'HSZTA'
   AND T3.ST_DATE <= '${p_end_dt}'
   AND T3.END_DATE >= '${p_end_dt}'
   AND T3.VALID_FLAG = '1' --有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T4 --渠道基本信息
    ON T4.CHNL_INCD = T1.C_AGENCYNO
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSZTA'
   AND T6.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'HSZTA'
   AND T8.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD T10 --客户基本信息
    ON T1.C_FUNDACCO = T10.C_FUNDACCO
   AND T10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
;



INSERT INTO DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       SUBSTR(REPLACE(T1.D_CDATE,'-',''),1,8)                                        AS CNFM_DATE                               --确认日期
     , T1.C_CSERIALNO                                                                AS CNFM_NO                                 --确认号
     , CASE WHEN T1.C_BUSINFLAG IS NOT NULL 
            THEN COALESCE(T2.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSINFLAG)) 
        END                                                                          AS BUSIN_CODE                              --业务代码
     , SUBSTR(REPLACE(T1.D_REQUESTDATE,'-',''),1,8)                                  AS REQ_DATE                                --申请日期
     , T1.C_REQUESTNO                                                                AS REQ_NO                                  --申请编号
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T1.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码
     , T3.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , CASE WHEN T1.C_BOURSEFLAG IS NOT NULL 
            THEN COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BOURSEFLAG)) 
        END                                                                          AS TRAN_MKT_CODE                           --交易市场代码
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
            THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS CHAG_FORM_CODE                          --收费形式代码
     , T1.C_SHARECLASS                                                               AS SHARE_LVL_CODE                          --份额级别代码
     , CASE WHEN T1.C_BONUSTYPE IS NOT NULL 
            THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BONUSTYPE)) 
        END                                                                          AS BONUS_MODE_CODE                         --分红方式代码
     , T1.F_OCCURSHARES                                                              AS THIM_OCCUR_SHARE                        --本次发生份额
     , T1.F_OCCURBALANCE                                                             AS THIM_OCCUR_AMT                          --本次发生金额
     , T1.F_LASTSHARES                                                               AS HOLD_SHARE                              --持有份额
     , T1.F_OCCURFREEZE                                                              AS HOLD_FRZ_OCCUR                          --持有冻结份额
     , T1.F_LASTFREEZESHARE                                                          AS THIM_FRZ_BAL                            --本次冻结余额
     , T1.C_OUTBUSINFLAG                                                             AS EXT_BUSIN_FLAG                          --外部业务标志
     , NULL                                                                          AS REQ_SERIALNO                            --申请序号
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TSHARECURRENTS_PTD'                                                AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
     , SUBSTR(REPLACE(T1.D_SHAREVALIDDATE,'-',''),1,8)                               AS SHARE_VALID_DATE                        --份额有效日期
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_VSHARECURRENTS_PFD T1  --份额变化流水
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2 --标准字典码值映射
    ON T2.SSYS = 'HSFTA'
   AND T2.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG = T2.SRC_DICT_CLS_CDVAL
   AND T2.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T3 --产品编码映射
    ON T1.C_FUNDCODE = T3.PROD_INCD
   AND T3.SSYS = 'HSFTA'
   AND T3.ST_DATE <= '${p_end_dt}'
   AND T3.END_DATE >= '${p_end_dt}'
   AND T3.VALID_FLAG = '1' --有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T4 --渠道基本信息
    ON T4.CHNL_INCD = T1.C_AGENCYNO
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSFTA'
   AND T6.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'HSFTA'
   AND T8.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准字典码值映射
    ON T10.SSYS = 'HSFTA'
   AND T10.SRC_DICT_CLS_CD = 'C_BOURSEFLAG'
   AND T1.C_BOURSEFLAG = T10.SRC_DICT_CLS_CDVAL
   AND T10.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND SUBSTR(REPLACE(T1.D_CDATE,'-',''),1,8) <='${p_end_dt}'
   AND SUBSTR(REPLACE(T1.D_SHAREVALIDDATE,'-',''),1,8) >'${p_end_dt}'
;
"
