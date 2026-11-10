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
-- ** 描述: 资金账户信息
-- ** 创建者 : hejl
-- ** 创建日期: 20230516
-- ** 修改日志:
-- ** 20230516，hejl，新建
-- ** 目标表：DWDXDAY.DWD_ACCT_CPTL_ACCT_INFO_PFD  资金账户信息表
-- **         
-- ** 源表：  ODS_XDAY_O32.ODS_O32_TBANKACCOUNT_PFD  银行账户信息表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP     标准字典码值映射表
-- **         ODS_XDAY_O32.ODS_O32_TSELFBANKACCOUNT_PFD    本方账户信息表
-- **         DWDXDAY.DWD_ACCT_CPTL_ACCT_INFO_PFD_TMP  资金账户信息临时表
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
    
INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_CPTL_ACCT_INFO_PFD_TMP
SELECT A1.VC_ACCOUNT                                                            AS CPTL_ACCT_NUM       --资金账户编码
   , A1.VC_ACCOUNT_NAME                                                         AS CPTL_ACCT_NAME      --资金账户名称
   , '1'                                                                        AS CPTL_ACCT_TYPE      --资金账户类型
   , NULL                                                                       AS OPEN_BANK_NUM       --开户行编码
   , A1.VC_BANK_NAME                                                            AS OPEN_BANK_NAME      --开户行名称
   , NULL                                                                       AS OPEN_BANK_TYPE      --开户行类型
   , A1.L_BANK_NO                                                               AS OPEN_BANK_HEADOFF   --开户行总行
   , NULL                                                                       AS OPEN_DATE           --开户日期
   , NULL                                                                       AS CLOS_DATE           --销户日期
   , A1.L_LAST_CHANGE_DATE                                                      AS LAST_UPD_DATE       --最后更新日期
   , A1.VC_PROVINCECODE                                                         AS OPEN_BANK_PROVINCE  --开户行省份
   , A1.VC_CITY                                                                 AS OPEN_BANK_CITY      --开户行城市
   , NULL                                                                       AS CRRC_CODE           --币种代码
   , A1.VC_PAY_NO                                                               AS LARGE_PAY_BANK_NO   --大额支付行号
   , A1.C_STATUS                                                                AS ACCT_STAT           --账户状态
   , NULL                                                                       AS MAILBOX             --邮箱
   , NULL                                                                       AS ADDR                --通讯地址
   , NULL                                                                       AS FAX                 --传真
   , NULL                                                                       AS MOBL                --手机
   , NULL                                                                       AS ACCT_MAG_MODE       --账户管理模式
   , A1.VC_SUB_TYPE                                                             AS IS_DVP_ACCT         --是否DVP账户
   , A1.VC_INTRABANK_NO                                                         AS IB_NO               --联行号
   , 'O32'                                                                      AS SSYS                --源系统
   , 'ODS_O32_TBANKACCOUNT_PFD'                                                 AS SOURCE_TAB          --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME             --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME         --修改时间
     FROM ODS_XDAY_O32.ODS_O32_TBANKACCOUNT_PFD A1    --银行账户信息表 
     WHERE A1.P_DT = '${P_BATCH_DT}';
INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_CPTL_ACCT_INFO_PFD_TMP
SELECT A1.VC_BANK_ACCOUNT                                                       AS CPTL_ACCT_NUM       --资金账户编码
   , A1.VC_ACCOUNT_NAME                                                         AS CPTL_ACCT_NAME      --资金账户名称
   , A2.STD_DICT_CLS_CD_VAL                                                     AS CPTL_ACCT_TYPE      --资金账户类型
   , NULL                                                                       AS OPEN_BANK_NUM       --开户行编码
   , A1.VC_BANK_NAME                                                            AS OPEN_BANK_NAME      --开户行名称
   , NULL                                                                       AS OPEN_BANK_TYPE      --开户行类型
   , A1.VC_BANK_NO                                                              AS OPEN_BANK_HEADOFF   --开户行总行
   , A1.L_OPEN_DATE                                                             AS OPEN_DATE           --开户日期
   , A1.L_CLOSE_DATE                                                            AS CLOS_DATE           --销户日期
   , NULL                                                                       AS LAST_UPD_DATE       --最后更新日期
   , A1.VC_PROVINCECODE                                                         AS OPEN_BANK_PROVINCE  --开户行省份
   , A1.VC_CITYNO                                                               AS OPEN_BANK_CITY      --开户行城市
   , NULL                                                                       AS CRRC_CODE           --币种代码
   , A1.VC_PAY_NO                                                               AS LARGE_PAY_BANK_NO   --大额支付行号
   , A1.C_STATUS                                                                AS ACCT_STAT           --账户状态
   , A1.VC_EMAIL                                                                AS MAILBOX             --邮箱
   , NULL                                                                       AS ADDR                --通讯地址
   , A1.VC_BANK_FAX                                                             AS FAX                 --传真
   , A1.VC_BANK_PHONE                                                           AS MOBL                --手机
   , A3.STD_DICT_CLS_CD_VAL                                                     AS ACCT_MAG_MODE       --账户管理模式
   , A1.C_DVP                                                                   AS IS_DVP_ACCT         --是否DVP账户
   , A1.VC_INTRABANK_NO                                                         AS IB_NO               --联行号
   , 'O32'                                                                      AS SSYS                --源系统
   , 'ODS_O32_TSELFBANKACCOUNT_PFD'                                             AS SOURCE_TAB          --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME             --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME         --修改时间
     FROM ODS_XDAY_O32.ODS_O32_TSELFBANKACCOUNT_PFD A1  --本方账户信息表
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A2  --标准字典码值映射
      ON A1.C_ACCOUNT_TYPE = A2.SRC_DICT_CLS_CDVAL
     AND A2.SSYS= 'HSDS'
     AND A2.SRC_DICT_CLS_CD= 'C_ACCOUNT_TYPE'
     AND A2.VALID_FLAG='1'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  ----标准字典码值映射
      ON A1.C_ACCOUNT_MANAGE_TYPE = A3.SRC_DICT_CLS_CDVAL
     AND A3.SSYS= 'HSDS'
     AND A3.SRC_DICT_CLS_CD= 'C_ACCOUNT_MANAGE_TYPE'
     AND A3.VALID_FLAG='1'
     WHERE A1.P_DT = '${P_BATCH_DT}';

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_CPTL_ACCT_INFO_PFD PARTITION (P_DT = '${P_BATCH_DT}')
SELECT A1.CPTL_ACCT_NUM               AS CPTL_ACCT_NUM       --资金账户编码
   , A1.CPTL_ACCT_NAME                AS CPTL_ACCT_NAME      --资金账户名称
   , A1.CPTL_ACCT_TYPE                AS CPTL_ACCT_TYPE      --资金账户类型
   , A1.OPEN_BANK_NUM                 AS OPEN_BANK_NUM       --开户行编码
   , A1.OPEN_BANK_NAME                AS OPEN_BANK_NAME      --开户行名称
   , A1.OPEN_BANK_TYPE                AS OPEN_BANK_TYPE      --开户行类型
   , A1.OPEN_BANK_HEADOFF             AS OPEN_BANK_HEADOFF   --开户行总行
   , A1.OPEN_DATE                     AS OPEN_DATE           --开户日期
   , A1.CLOS_DATE                     AS CLOS_DATE           --销户日期
   , A1.LAST_UPD_DATE                 AS LAST_UPD_DATE       --最后更新日期
   , A1.OPEN_BANK_PROVINCE            AS OPEN_BANK_PROVINCE  --开户行省份
   , A1.OPEN_BANK_CITY                AS OPEN_BANK_CITY      --开户行城市
   , A1.CRRC_CODE                     AS CRRC_CODE           --币种代码
   , A1.LARGE_PAY_BANK_NO             AS LARGE_PAY_BANK_NO   --大额支付行号
   , A1.ACCT_STAT                     AS ACCT_STAT           --账户状态
   , A1.MAILBOX                       AS MAILBOX             --邮箱
   , A1.ADDR                          AS ADDR                --通讯地址
   , A1.FAX                           AS FAX                 --传真
   , A1.MOBL                          AS MOBL                --手机
   , A1.ACCT_MAG_MODE                 AS ACCT_MAG_MODE       --账户管理模式
   , A1.IS_DVP_ACCT                   AS IS_DVP_ACCT         --是否DVP账户
   , A1.IB_NO                         AS IB_NO               --联行号
   , A1.SSYS                          AS SSYS                --源系统
   , A1.SOURCE_TAB                    AS SOURCE_TAB          --源表
   , A1.LD_TIME                       AS LD_TIME             --加载时间
   , A1.MODIFY_TIME                   AS MODIFY_TIME         --修改时间
     FROM DWDXDAY.DWD_ACCT_CPTL_ACCT_INFO_PFD_TMP A1 --资金账户信息临时表
"
