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
-- ** 描述:客户持仓信息
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_AST_CUST_HLDP_INFO_PFD  客户持仓信息
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TSTATICSHARES_PFD 静态份额表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TSTATICSHARES_PFD 静态份额表
-- **         ODS_XDAY_HSDS.ODS_HSDS_TSTATICSHARE_PFD 静态份额表
-- **         ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD 客户基本信息
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD 基金账户信息
-- **         ODS_XDAY_HSDS.ODS_HSDS_TACCOINFO_PFD 基金账户信息
-- **         DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD 客户编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_CUST_HLDP_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.P_DT                                                                       AS BUSIN_DATE                              --业务日期
     , NULL                                                                   AS CUST_NUM                                --客户编码
     , T2.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
             THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , T4.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , T6.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.F_REALSHARES                                                               AS SHARE_BAL                               --份额余额
     , T1.F_FROZENSHARES                                                             AS FRZ_SHARE                               --冻结份额
     , T1.F_INCOME                                                                   AS UNP_YIEL                                --未付收益
     , T1.F_FROZENINCOME                                                             AS FRZ_UNP_YIEL                            --冻结未付收益
     , T1.F_NEWINCOME                                                                AS TDY_NEW_ASSN_YIEL                       --当天新分配收益
     , T1.F_FLOORINCOME                                                              AS YIELDISTR_CF_YIEL                       --收益分配截去的收益
     , T1.D_LASTMODIFY                                                               AS LAST_HLDP_DATE                          --最新持仓日期
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TSTATICSHARES_PFD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TSTATICSHARES_PFD T1  --静态份额表
  LEFT JOIN ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD T2 --客户基本信息
    ON T1.C_FUNDACCO = T2.C_FUNDACCO
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T4 --产品编码映射
    ON T1.C_FUNDCODE = T4.PROD_INCD
   AND T4.SSYS = 'HSZTA'
   AND T4.ST_DATE <= '${p_end_dt}'
   AND T4.END_DATE >= '${p_end_dt}'
   AND T4.VALID_FLAG = '1' --有效标志
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T6 --渠道基本信息
    ON T6.CHNL_INCD = T1.C_AGENCYNO
   AND T6.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_AST_CUST_HLDP_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.P_DT                                                                       AS BUSIN_DATE                              --业务日期
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T2.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
             THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , T4.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , T6.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.F_REALSHARES                                                               AS SHARE_BAL                               --份额余额
     , T1.F_FROZENSHARES                                                             AS FRZ_SHARE                               --冻结份额
     , T1.F_INCOME                                                                   AS UNP_YIEL                                --未付收益
     , T1.F_FROZENINCOME                                                             AS FRZ_UNP_YIEL                            --冻结未付收益
     , T1.F_NEWINCOME                                                                AS TDY_NEW_ASSN_YIEL                       --当天新分配收益
     , T1.F_FLOORINCOME                                                              AS YIELDISTR_CF_YIEL                       --收益分配截去的收益
     , SUBSTR(REPLACE(T1.D_LASTMODIFY,'-',''),1,8)                                   AS LAST_HLDP_DATE                          --最新持仓日期
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TSTATICSHARES_PFD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSTATICSHARES_PFD T1  --静态份额表
  LEFT JOIN ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD T2 --基金账户信息
    ON T1.C_FUNDACCO = T2.C_FUNDACCO
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSFTA'
   AND T3.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T4 --产品编码映射
    ON T1.C_FUNDCODE = T4.PROD_INCD
   AND T4.SSYS = 'HSFTA'
   AND T4.ST_DATE <= '${p_end_dt}'
   AND T4.END_DATE >= '${p_end_dt}'
   AND T4.VALID_FLAG = '1' --有效标志
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T6 --渠道基本信息
    ON T6.CHNL_INCD = T1.C_AGENCYNO
   AND T6.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
;
"
