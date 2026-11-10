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
-- ** 描述:账户网点关系
-- ** 创建者:auto
-- ** 创建日期:2023-07-11
-- ** 修改日志:
-- ** 2023-07-11，auto，新建
-- ** 目标表：DWDXDAY.DWD_ACCT_ACCT_BTCH_RELA_PFD  账户网点关系
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TACCONET_PFD 账号可交易网点
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TACCONET_PFD 账号可交易网点
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_ACCT_BTCH_RELA_PFD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T2.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , CASE WHEN T1.C_TRADEACCOSTATUS IS NOT NULL 
            THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TRADEACCOSTATUS)) 
        END                                                                          AS TRAN_ACCO_STAT_CODE                     --交易账号状态代码
     , T2.CHNL_NAME                                                                  AS CHNL_NAME                               --渠道名称
     , T2.CHNL_TYPE_CODE                                                             AS CHNL_TYPE_CODE                          --渠道类型代码
     , T1.D_OPENDATE                                                                 AS ST_DATE                                 --开始日期
     , T1.C_BANKNO                                                                   AS DELIV_BANK_NAME                         --交收行名称
     , T1.C_BANKACCO                                                                 AS DELIV_BANK_ACCO                         --交收行账号
     , T1.C_NAMEINBANK                                                               AS DELIV_BANK_USN                          --交收行户名
     , T1.C_CHILDNETNO                                                               AS OPER_BTCH_NO                            --操作网点编号
     , T1.C_TRADEACCOBAK                                                             AS TRAN_ACCO_BAK                           --交易账号备份
     , T1.C_SYSROLE                                                                  AS SYS_ROLE                                --系统角色
     , T1.C_ISENDOWACCO                                                              AS IS_ENDOW_ACCT                           --是否赋予账户
     , T1.C_CREDITACCOFLAG                                                           AS CREDIT_ACCT_FLAG                        --信用账户标志
     , T1.D_LASTMODIFY                                                               AS BUSIN_MODIFY_DATE                       --业务修改日期
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TACCONET_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TACCONET_PFD T1  --账号可交易网点
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T2 --渠道基本信息
    ON T2.CHNL_INCD = T1.C_AGENCYNO
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_TRADEACCOSTATUS'
   AND T1.C_TRADEACCOSTATUS = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
 WHERE T1.P_DT = '${P_BATCH_DT}'
;

INSERT INTO DWDXDAY.DWD_ACCT_ACCT_BTCH_RELA_PFD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T2.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , NULL                                                                          AS TRAN_ACCO_STAT_CODE                     --交易账号状态代码
     , T2.CHNL_NAME                                                                  AS CHNL_NAME                               --渠道名称
     , T2.CHNL_TYPE_CODE                                                             AS CHNL_TYPE_CODE                          --渠道类型代码
     , SUBSTR(REPLACE(T1.D_APPENDDATE,'-',''),1,8)                                   AS ST_DATE                                 --开始日期
     , T1.C_BANKNO                                                                   AS DELIV_BANK_NAME                         --交收行名称
     , T1.C_BANKACCO                                                                 AS DELIV_BANK_ACCO                         --交收行账号
     , T1.C_NAMEINBANK                                                               AS DELIV_BANK_USN                          --交收行户名
     , T1.C_CHILDNETNO                                                               AS OPER_BTCH_NO                            --操作网点编号
     , T1.C_TRADEACCOBAK                                                             AS TRAN_ACCO_BAK                           --交易账号备份
     , NULL                                                                          AS SYS_ROLE                                --系统角色
     , T1.C_ISENDOWACCO                                                              AS IS_ENDOW_ACCT                           --是否赋予账户
     , NULL                                                                          AS CREDIT_ACCT_FLAG                        --信用账户标志
     , NULL                                                                          AS BUSIN_MODIFY_DATE                       --业务修改日期
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TACCONET_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TACCONET_PFD T1  --账号可交易网点
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T2 --渠道基本信息
    ON T2.CHNL_INCD = T1.C_AGENCYNO
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${P_BATCH_DT}'
;
"
