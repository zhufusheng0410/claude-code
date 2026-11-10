#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:账户
-- ** 描述:账户确认
-- ** 创建者:auto
-- ** 创建日期:2023-07-21
-- ** 修改日志:
-- ** 2023-07-21，auto，新建
-- ** 目标表：DWDXDAY.DWD_ACCT_ACCT_CNFM_PFD  账户确认
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TACCOCONFIRM_PFD  账户确认
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TACCOREQUEST_PTD  账户申请表
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD  渠道基本信息
-- **         ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD 客户基本信息
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD 客户基本信息
-- **         DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD 客户编码映射
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
set hive.exec.reducers.bytes.per.reducer=10240000000; 
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_ACCT_CNFM_PFD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       CASE WHEN T1.C_BUSINFLAG IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSINFLAG)) 
        END                                                                          AS BUSIN_TYPE_CODE                         --业务类型代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.D_REQUESTDATE                                                              AS REQ_DATE                                --申请日期
     , T1.D_REQUESTTIME                                                              AS REQ_TIME                                --申请时间
     , T1.C_REQUESTNO                                                                AS REQ_NO                                  --申请编号
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T1.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码
     , T1.C_CUSTNAME                                                                 AS CUST_NAME                               --客户名称
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
            THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.C_ZIPCODE                                                                  AS PTCD                                    --邮政编码
     , T1.C_CHILDNETNO                                                               AS OPEN_BTCH_INCD                          --开户网点内码
     , T1.C_PHONE                                                                    AS TEL                                     --电话
     , T1.C_MOBILENO                                                                 AS MOBL                                    --手机
     , T1.C_ADDRESS                                                                  AS ADDR                                    --地址
     , T1.C_IDENTITYTYPE                                                             AS CERT_TYPE_CODE                          --证件类型代码
     , T1.C_IDENTITYNO                                                               AS CERT_NO                                 --证件号码
     , CASE WHEN T1.C_FREEZECAUSE IS NOT NULL 
            THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FREEZECAUSE)) 
        END                                                                          AS FRZ_CAUSE_CODE                          --冻结原因代码
     , T1.D_BACKDATE                                                                 AS VALID_END_DATE                          --有效截止日期
     , T1.C_ORIREQUESTNO                                                             AS ORI_REQ_NO                              --原申请编号
     , T1.C_CHILDNETNO                                                               AS OPER_BTCH_NO                            --操作网点编号
     , T1.C_CITYNO                                                                   AS CITY_NO                                 --城市编号(地区)
     , T1.C_OUTBUSINFLAG                                                             AS EXT_BUSIN_FLAG                          --外部业务标志
     , T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
     , T1.C_STATUS                                                                   AS STATUS                                  --确认结果
     , T1.C_CAUSE                                                                    AS FAIL_CAUSE                              --失败原因
     , T1.C_BANKNAME                                                                 AS BANK_NAME                               --银行名称
     , T1.C_BRANCHBANK                                                               AS BTCH_BANK                               --网点银行
     , T1.C_BANKPROVINCE                                                             AS BANK_PROVINCE                           --银行省份
     , T1.C_BANKCITYNO                                                               AS BANK_LCAL_CITY_CODE                     --银行所在城市代码
     , T1.C_MEMO                                                                     AS MEMO                                    --备注
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TACCOCONFIRM_PFD'                                                  AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TACCOCONFIRM_PFD T1  --账户确认
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_FREEZECAUSE'
   AND T1.C_FREEZECAUSE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSZTA'
   AND T6.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
 WHERE T1.P_DT = '${P_BATCH_DT}'
;


INSERT INTO DWDXDAY.DWD_ACCT_ACCT_CNFM_PFD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       CASE WHEN T1.C_BUSINFLAG IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSINFLAG)) 
        END                                                                          AS BUSIN_TYPE_CODE                         --业务类型代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , SUBSTR(REPLACE(T1.D_DATE,'-',''),1,8)                                         AS REQ_DATE                                --申请日期
     , T1.D_REQUESTTIME                                                              AS REQ_TIME                                --申请时间
     , T1.C_REQUESTNO                                                                AS REQ_NO                                  --申请编号
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T1.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码
     , T1.C_CUSTNAME                                                                 AS CUST_NAME                               --客户名称
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
            THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.C_ZIPCODE                                                                  AS PTCD                                    --邮政编码
     , T1.C_CHILDNETNO                                                               AS OPEN_BTCH_INCD                          --开户网点内码
     , T1.C_PHONE                                                                    AS TEL                                     --电话
     , T1.C_MOBILENO                                                                 AS MOBL                                    --手机
     , T1.C_ADDRESS                                                                  AS ADDR                                    --地址
     , T1.C_IDENTITYTYPE                                                             AS CERT_TYPE_CODE                          --证件类型代码
     , T1.C_IDENTITYNO                                                               AS CERT_NO                                 --证件号码
     , CASE WHEN T1.C_FREEZECAUSE IS NOT NULL 
            THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FREEZECAUSE)) 
        END                                                                          AS FRZ_CAUSE_CODE                          --冻结原因代码
     , NULL                                                                          AS VALID_END_DATE                          --有效截止日期
     , T1.C_ORIGINALNO                                                               AS ORI_REQ_NO                              --原申请编号
     , T1.C_CHILDNETNO                                                               AS OPER_BTCH_NO                            --操作网点编号
     , T1.C_CITYNO                                                                   AS CITY_NO                                 --城市编号(地区)
     , T1.C_OUTBUSINFLAG                                                             AS EXT_BUSIN_FLAG                          --外部业务标志
     , SUBSTR(REPLACE(T1.D_CDATE,'-',''),1,8)                                        AS CNFM_DATE                               --确认日期
     , T1.C_STATUS                                                                   AS STATUS                                  --确认结果
     , T1.C_CAUSE                                                                    AS FAIL_CAUSE                              --失败原因
     , NULL                                                                          AS BANK_NAME                               --银行名称
     , NULL                                                                          AS BTCH_BANK                               --网点银行
     , T1.C_PROVINCE                                                                 AS BANK_PROVINCE                           --银行省份
     , T1.C_CITY                                                                     AS BANK_LCAL_CITY_CODE                     --银行所在城市代码
     , T1.C_MEMO                                                                     AS MEMO                                    --备注
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TACCOREQUEST_PTD'                                                  AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TACCOREQUEST_PTD T1  --账户申请表
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFTA'
   AND T4.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_FREEZECAUSE'
   AND T1.C_FREEZECAUSE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSFTA'
   AND T6.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
 WHERE T1.P_DT = '${P_BATCH_DT}'
;
"
