#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题: 账户
-- ** 描述: 基金交易账户信息
-- ** 创建者 : hejl
-- ** 创建日期: 20230516
-- ** 修改日志:
-- ** 20230516，hejl，新建
-- ** 目标表：DWDXDAY.DWD_ACCT_FUND_TRAN_ACCT_INFO_PFD  基金交易账户信息表
-- **         
-- ** 源表：  ODS_XDAY_HSDS.ODS_HSDS_TACCOINFO_PFD   基金交易账户信息表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP     标准字典码值映射表
-- **         DWDXDAY.DWD_ACCT_FUND_TRAN_ACCT_INFO_PFD_TMP  基金交易账户信息临时表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_FUND_TRAN_ACCT_INFO_PFD_TMP
SELECT A1.VC_TRADEACCO                                                           AS FUND_TRAN_ACCT_NUM   --基金交易账户编码
   , A1.VC_ACCONAME                                                              AS TRAN_ACCT_NAME       --交易账户名称
   , A1.VC_CUSTNO                                                                AS CUST_NO              --客户编号
   , A3.STD_DICT_CLS_CD_VAL                                                      AS CUST_CATG            --客户类别
   , A1.C_MAINFLAG                                                               AS MAIN_ACCO_ID         --主账号标识
   , A1.VC_ACCOCARD                                                              AS CARD_NO              --卡号
   , A1.VC_OPENDATE                                                              AS OPEN_DATE            --开户日期
   , A1.VC_NETNO                                                                 AS OPEN_BTCH            --开户网点
   , A1.VC_LASTDATE                                                              AS LAST_MODIFY_DATE     --最后修改日期
   , A1.VC_CENTERNO                                                              AS OPEN_BANK_CENT       --开户分中心
   , A1.VC_CITYNO                                                                AS OPEN_CITY            --开户城市
   , A1.C_STATE                                                                  AS ACCT_STAT            --账户状态
   , A1.VC_DEALPWD                                                               AS TRAN_PWD             --交易密码
   , A1.VC_QUERYPWD                                                              AS QRY_PWD              --查询密码
   , A1.C_CAPITALMODE                                                            AS CPTL_MODE            --资金方式
   , A1.C_DIVIDENDMETHOD                                                         AS BONUS_MODE           --分红方式
   , A1.VC_ADDRESS                                                               AS ADDR                 --通讯地址
   , A1.VC_ZIP                                                                   AS PTCD                 --邮编
   , A1.VC_MOBILENO                                                              AS MOBL                 --手机
   , A1.VC_FAXNO                                                                 AS FAX                  --传真
   , A1.VC_EMAIL                                                                 AS MAILBOX              --邮箱
   , A1.D_ERRDATE                                                                AS LOCK_DATE            --锁定日期
   , 'HSDS'                                                                      AS SSYS                 --源系统
   , 'ODS_HSDS_TACCOINFO_PFD'                                                    AS SOURCE_TAB           --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')    AS LD_TIME              --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')    AS MODIFY_TIME          --修改时间
     FROM ODS_XDAY_HSDS.ODS_HSDS_TACCOINFO_PFD A1   --基金交易账户信息表
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3 --标准字典码值映射表
      ON A1.C_CUSTTYPE = A3.SRC_DICT_CLS_CDVAL 
     AND A3.VALID_FLAG='1'
     AND A3.SSYS= 'HSDS'
     AND A3.SRC_DICT_CLS_CD= 'C_CUSTTYPE' 
     WHERE A1.P_DT = '${P_BATCH_DT}';

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_FUND_TRAN_ACCT_INFO_PFD PARTITION (P_DT ='${P_BATCH_DT}')
SELECT A1.FUND_TRAN_ACCT_NUM            AS FUND_TRAN_ACCT_NUM   --基金交易账户编码
   , A1.TRAN_ACCT_NAME                  AS TRAN_ACCT_NAME       --交易账户名称
   , A1.CUST_NO                         AS CUST_NO              --客户编号
   , A1.CUST_CATG                       AS CUST_CATG            --客户类别
   , A1.MAIN_ACCO_ID                    AS MAIN_ACCO_ID         --主账号标识
   , A1.CARD_NO                         AS CARD_NO              --卡号
   , A1.OPEN_DATE                       AS OPEN_DATE            --开户日期
   , A1.OPEN_BTCH                       AS OPEN_BTCH            --开户网点
   , A1.LAST_MODIFY_DATE                AS LAST_MODIFY_DATE     --最后修改日期
   , A1.OPEN_BANK_CENT                  AS OPEN_BANK_CENT       --开户分中心
   , A1.OPEN_CITY                       AS OPEN_CITY            --开户城市
   , A1.ACCT_STAT                       AS ACCT_STAT            --账户状态
   , A1.TRAN_PWD                        AS TRAN_PWD             --交易密码
   , A1.QRY_PWD                         AS QRY_PWD              --查询密码
   , A1.CPTL_MODE                       AS CPTL_MODE            --资金方式
   , A1.BONUS_MODE                      AS BONUS_MODE           --分红方式
   , A1.ADDR                            AS ADDR                 --通讯地址
   , A1.PTCD                            AS PTCD                 --邮编
   , A1.MOBL                            AS MOBL                 --手机
   , A1.FAX                             AS FAX                  --传真
   , A1.MAILBOX                         AS MAILBOX              --邮箱
   , A1.LOCK_DATE                       AS LOCK_DATE            --锁定日期
   , A1.SSYS                            AS SSYS                 --源系统
   , A1.SOURCE_TAB                      AS SOURCE_TAB           --源表
   , A1.LD_TIME                         AS LD_TIME              --加载时间
   , A1.MODIFY_TIME                     AS MODIFY_TIME          --修改时间
     FROM  DWDXDAY.DWD_ACCT_FUND_TRAN_ACCT_INFO_PFD_TMP A1 ;   --基金交易账户信息临时表
"
