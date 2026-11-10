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
-- ** 描述:账户未付收益
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_ACCT_ACCT_UNP_YIEL_PTD  账户未付收益
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TINCOME_PTD 账户未付收益表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TINCOME_PTD  账户未付收益表
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_ACCT_UNP_YIEL_PTD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
     , T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
              THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , T1.F_REALSHARES_PRE                                                           AS REINV_SHARE                             --再投资份额
     , T1.F_FROZENSHARES_PRE                                                         AS AGA_FRZ_SHARE                           --再冻结份额
     , T1.F_INCOME_PRE                                                               AS YEST_FUND_YIEL                          --昨日基金收益
     , T1.F_FROZENINCOME_PRE                                                         AS AGA_FRZ_UNP_YIEL                        --再冻结未付收益
     , T1.F_NEWINCOME                                                                AS TDY_NEW_UNP_YIEL                        --当天新增未付收益
     , T1.F_REALSHARES                                                               AS SHARE_BAL                               --份额余额
     , T1.F_FROZENSHARES                                                             AS FRZ_SHARE                               --冻结份额
     , T1.F_INCOME                                                                   AS UNP_YIEL                                --未付收益
     , T1.F_TOTALINCOME                                                              AS TOTAL_YIEL                              --累计收益
     , T1.F_FROZENINCOME                                                             AS FRZ_UNP_YIEL                            --冻结未付收益
     , NULL                                                                          AS TOTAL_UN_RETU_FEE                       --累计未返还费用
     , NULL                                                                          AS NEW_UN_RETU_FEE                         --新增未返还费用
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TINCOME_PTD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TINCOME_PTD T1  --账户未付收益表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${P_BATCH_DT}'
   AND T2.END_DATE >= '${P_BATCH_DT}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
 WHERE T1.P_DT = '${P_BATCH_DT}'
;
INSERT INTO DWDXDAY.DWD_ACCT_ACCT_UNP_YIEL_PTD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
     , T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
              THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , NULL                                                                          AS REINV_SHARE                             --再投资份额
     , NULL                                                                          AS AGA_FRZ_SHARE                           --再冻结份额
     , NULL                                                                          AS YEST_FUND_YIEL                          --昨日基金收益
     , NULL                                                                          AS AGA_FRZ_UNP_YIEL                        --再冻结未付收益
     , T1.F_NEWINCOME                                                                AS TDY_NEW_UNP_YIEL                        --当天新增未付收益
     , T1.F_REALSHARES                                                               AS SHARE_BAL                               --份额余额
     , T1.F_FROZENSHARES                                                             AS FRZ_SHARE                               --冻结份额
     , T1.F_INCOME                                                                   AS UNP_YIEL                                --未付收益
     , T1.F_TOTALINCOME                                                              AS TOTAL_YIEL                              --累计收益
     , T1.F_FROZENINCOME                                                             AS FRZ_UNP_YIEL                            --冻结未付收益
     , T1.F_RETURNFARE                                                               AS TOTAL_UN_RETU_FEE                       --累计未返还费用
     , T1.F_RETURNFARENEW                                                            AS NEW_UN_RETU_FEE                         --新增未返还费用
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TINCOME_PTD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TINCOME_PTD T1  --账户未付收益表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${P_BATCH_DT}'
   AND T2.END_DATE >= '${P_BATCH_DT}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFTA'
   AND T4.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
 WHERE T1.P_DT = '${P_BATCH_DT}'
;

"
