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
-- ** 描述: 基金账户信息
-- ** 创建者 : hejl
-- ** 创建日期: 20230516
-- ** 修改日志:
-- ** 20230516，hejl，新建
-- ** 目标表：DWDXDAY.DWD_ACCT_FUND_ACCT_INFO_PFD  基金账户信息表
-- **         
-- ** 源表：  ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD  基金账户信息表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP     标准字典码值映射表
-- **         ODS_XDAY_HSDS.ODS_HSDS_TFUNDACCO_PFD    基金账号信息表
-- **         DWDXDAY.DWD_ACCT_FUND_ACCT_INFO_PFD_TMP 基金账户信息临时表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_FUND_ACCT_INFO_PFD_TMP
SELECT A1.C_FUNDACCO                                                           AS FUND_ACCT_NUM      --基金账户编码
   , A3.STD_DICT_CLS_CD_VAL                                                    AS ACCT_TYPE          --账户类型(TA账户类型)
   , A1.C_CUSTNO                                                               AS CUST_NO            --客户编号
   , A1.C_AGENCYNO                                                             AS AGENCY_NO          --销售商编号
   , A1.C_NETNO                                                                AS OPEN_BTCH          --开户网点
   , A1.D_OPENDATE                                                             AS OPEN_DATE          --开户日期
   , A1.D_LASTMODIFY                                                           AS LAST_MODIFY_DATE   --最后修改日期
   , A1.C_ACCOSTATUS                                                           AS ACCT_STAT          --账户状态
   , NULL                                                                      AS TA_CODE            --TA代码
   , A1.C_FREEZECAUSE                                                          AS FRZ_CAUSE          --冻结原因
   , A1.D_BACKDATE                                                             AS FRZ_END_DATE       --冻结截止日期
   , A1.D_FIRSTINVEST                                                          AS FST_INV_DATE       --首次投资日期
   , A1.C_PASSWORD                                                             AS QRY_PWD            --查询密码
   , A1.C_BOURSEFLAG                                                           AS EXCH_FLAG          --交易所标志
   , 'HSFTA'                                                                   AS SSYS               --源系统
   , 'ODS_HSFTA_TACCOINFO_PFD'                                                 AS SOURCE_TAB         --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME            --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME        --修改时间
     FROM ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD A1   --基金账户信息表
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典码值映射表
       ON A1.C_ACCOUNTTYPE = A3.SRC_DICT_CLS_CDVAL 
      AND A3.VALID_FLAG='1'
      AND A3.SSYS= 'HSFTA'
      AND A3.SRC_DICT_CLS_CD= 'C_ACCOUNTTYPE'
     WHERE A1.P_DT = '${P_BATCH_DT}';
INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_FUND_ACCT_INFO_PFD_TMP
SELECT A1.VC_FUNDACCO                                                          AS FUND_ACCT_NUM      --基金账户编码
   , A3.STD_DICT_CLS_CD_VAL                                                    AS ACCT_TYPE          --账户类型(TA账户类型)
   , A1.VC_CUSTNO                                                              AS CUST_NO            --客户编号
   , NULL                                                                      AS AGENCY_NO          --销售商编号
   , A1.VC_NETNO                                                               AS OPEN_BTCH          --开户网点
   , A1.VC_OPENDATE                                                            AS OPEN_DATE          --开户日期
   , NULL                                                                      AS LAST_MODIFY_DATE   --最后修改日期
   , A1.C_STATE                                                                AS ACCT_STAT          --账户状态
   , A1.VC_TACODE                                                              AS TA_CODE            --TA代码
   , NULL                                                                      AS FRZ_CAUSE          --冻结原因
   , NULL                                                                      AS FRZ_END_DATE       --冻结截止日期
   , NULL                                                                      AS FST_INV_DATE       --首次投资日期
   , NULL                                                                      AS QRY_PWD            --查询密码
   , NULL                                                                      AS EXCH_FLAG          --交易所标志
   , 'HSDS'                                                                    AS SSYS               --源系统
   , 'ODS_HSDS_TFUNDACCO_PFD'                                                  AS SOURCE_TAB         --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME            --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME        --修改时间
     FROM ODS_XDAY_HSDS.ODS_HSDS_TFUNDACCO_PFD A1     --基金账号信息表
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典码值映射表
       ON A1.C_ACCOFLAG = A3.SRC_DICT_CLS_CDVAL 
      AND A3.VALID_FLAG='1'
      AND A3.SSYS= 'HSDS'
      AND A3.SRC_DICT_CLS_CD= 'C_ACCOFLAG'
     WHERE A1.P_DT = '${P_BATCH_DT}';

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_FUND_ACCT_INFO_PFD PARTITION(P_DT ='${P_BATCH_DT}')
SELECT A1.FUND_ACCT_NUM            AS FUND_ACCT_NUM      --基金账户编码
   , A1.ACCT_TYPE                  AS ACCT_TYPE          --账户类型(TA账户类型)
   , A1.CUST_NO                    AS CUST_NO            --客户编号
   , A1.AGENCY_NO                  AS AGENCY_NO          --销售商编号
   , A1.OPEN_BTCH                  AS OPEN_BTCH          --开户网点
   , A1.OPEN_DATE                  AS OPEN_DATE          --开户日期
   , A1.LAST_MODIFY_DATE           AS LAST_MODIFY_DATE   --最后修改日期
   , A1.ACCT_STAT                  AS ACCT_STAT          --账户状态
   , A1.TA_CODE                    AS TA_CODE            --TA代码
   , A1.FRZ_CAUSE                  AS FRZ_CAUSE          --冻结原因
   , A1.FRZ_END_DATE               AS FRZ_END_DATE       --冻结截止日期
   , A1.FST_INV_DATE               AS FST_INV_DATE       --首次投资日期
   , A1.QRY_PWD                    AS QRY_PWD            --查询密码
   , A1.EXCH_FLAG                  AS EXCH_FLAG          --交易所标志
   , A1.SSYS                       AS SSYS               --源系统
   , A1.SOURCE_TAB                 AS SOURCE_TAB         --源表
   , A1.LD_TIME                    AS LD_TIME            --加载时间
   , A1.MODIFY_TIME                AS MODIFY_TIME        --修改时间
     FROM DWDXDAY.DWD_ACCT_FUND_ACCT_INFO_PFD_TMP A1;  --基金账户信息临时表
"
