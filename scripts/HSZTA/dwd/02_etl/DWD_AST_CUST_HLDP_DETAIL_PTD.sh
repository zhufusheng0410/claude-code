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
-- ** 描述:客户持仓明细
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_AST_CUST_HLDP_DETAIL_PTD  客户持仓明细
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TSHAREDETAIL_PTD  份额明细表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TSHAREDETAIL_PTD  份额明细表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD 基金账户信息
-- **         ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD 客户基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_CUST_HLDP_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T10.C_CUSTNO                                                                  AS CUST_INCD                               --客户内码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , T3.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , T1.D_REGISTDATE                                                               AS SHARE_REG_DATE                          --份额注册日期
     , T1.C_CSERIALNO                                                                AS TA_CNFM_NO                              --TA确认号
     , CASE WHEN T1.C_ACCEPTMODE IS NOT NULL 
             THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ACCEPTMODE)) 
        END                                                                          AS TRAN_MODE_CODE                          --交易方式代码
     , T1.C_FIRSTCSERIALNO                                                           AS FST_CNFM_NO                             --首次确认编号
     , CASE WHEN T1.C_FUNDMETHOD IS NOT NULL 
             THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUNDMETHOD)) 
        END                                                                          AS CPTL_MODE_CODE                          --资金方式代码
     , CASE WHEN T1.C_SOURCETYPE IS NOT NULL 
             THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SOURCETYPE)) 
        END                                                                          AS SHARE_SRC_CODE                          --份额来源代码
     , CASE WHEN T1.C_ORISOURCE IS NOT NULL 
             THEN COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ORISOURCE)) 
        END                                                                          AS SHARE_ORI_SRC_CODE                      --份额原始来源代码
     , T1.F_REMAINSHARES                                                             AS THE_REMA_SHARE                          --本笔剩余份额
     , T1.F_ORIBALANCE                                                               AS ORI_CNFM_AMT                            --原确认金额
     , T1.F_ORISHARES                                                                AS ORI_CNFM_SHARE                          --原确认份额
     , T1.F_ORINETVALUE                                                              AS ORI_UNIT_NAV                            --原单位净值
     , T1.F_INTERESTSHARE                                                            AS INTR_TRAN_SHARE                         --利息转份额
     , T1.F_BACKFARE                                                                 AS BACK_CHAG                               --后收手续费
     , T1.F_INCOME                                                                   AS YEST_FUND_YIEL                          --昨日基金收益
     , T1.F_NEWINCOME                                                                AS TDY_NEW_UNP_YIEL                        --当天新增未付收益
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TSHAREDETAIL_PTD'                                                  AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TSHAREDETAIL_PTD T1  --份额明细表
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
   AND T5.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSZTA'
   AND T6.SRC_DICT_CLS_CD = 'C_ACCEPTMODE'
   AND T1.C_ACCEPTMODE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'HSZTA'
   AND T7.SRC_DICT_CLS_CD = 'C_FUNDMETHOD'
   AND T1.C_FUNDMETHOD = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'HSZTA'
   AND T8.SRC_DICT_CLS_CD = 'C_SOURCETYPE'
   AND T1.C_SOURCETYPE = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
    ON T9.SSYS = 'HSZTA'
   AND T9.SRC_DICT_CLS_CD = 'C_ORISOURCE'
   AND T1.C_ORISOURCE = T9.SRC_DICT_CLS_CDVAL
   AND T9.VALID_FLAG = '1'
  LEFT JOIN ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD T10 --客户基本信息
    ON T1.C_FUNDACCO = T10.C_FUNDACCO
   AND T10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_AST_CUST_HLDP_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T10.C_CUSTNO                                                                  AS CUST_INCD                               --客户内码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , T3.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , T1.D_REGISTDATE                                                                          AS SHARE_REG_DATE                          --份额注册日期
     , T1.C_CSERIALNO                                                                          AS TA_CNFM_NO                              --TA确认号
     , CASE WHEN T1.C_ACCEPTMODE IS NOT NULL 
             THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ACCEPTMODE)) 
        END                                                                          AS TRAN_MODE_CODE                          --交易方式代码
     , T1.C_FIRSTCSERIALNO                                                                          AS FST_CNFM_NO                             --首次确认编号
     , CASE WHEN T1.C_FUNDTYPE IS NOT NULL 
             THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUNDTYPE)) 
        END                                                                          AS CPTL_MODE_CODE                          --资金方式代码
     , CASE WHEN T1.C_SOURCETYPE IS NOT NULL 
             THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SOURCETYPE)) 
        END                                                                          AS SHARE_SRC_CODE                          --份额来源代码
     , CASE WHEN T1.C_ORISOURCE IS NOT NULL 
             THEN COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ORISOURCE)) 
        END                                                                          AS SHARE_ORI_SRC_CODE                      --份额原始来源代码
     , T1.F_REMAINSHARES                                                             AS THE_REMA_SHARE                          --本笔剩余份额
     , T1.F_ORIBALANCE                                                               AS ORI_CNFM_AMT                            --原确认金额
     , T1.F_ORISHARES                                                                AS ORI_CNFM_SHARE                          --原确认份额
     , T1.F_ORINETVALUE                                                              AS ORI_UNIT_NAV                            --原单位净值
     , T1.F_INTERESTSHARE                                                            AS INTR_TRAN_SHARE                         --利息转份额
     , T1.F_BACKFARE                                                                 AS BACK_CHAG                               --后收手续费
     , T1.F_INCOME                                                                   AS YEST_FUND_YIEL                          --昨日基金收益
     , T1.F_NEWINCOME                                                                AS TDY_NEW_UNP_YIEL                        --当天新增未付收益
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TSHAREDETAIL_PTD'                                                  AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSHAREDETAIL_PTD T1  --份额明细表
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
   AND T5.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSFTA'
   AND T6.SRC_DICT_CLS_CD = 'C_ACCEPTMODE'
   AND T1.C_ACCEPTMODE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'HSFTA'
   AND T7.SRC_DICT_CLS_CD = 'C_FUNDTYPE'
   AND T1.C_FUNDTYPE = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'HSFTA'
   AND T8.SRC_DICT_CLS_CD = 'C_SOURCETYPE'
   AND T1.C_SOURCETYPE = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
    ON T9.SSYS = 'HSFTA'
   AND T9.SRC_DICT_CLS_CD = 'C_ORISOURCE'
   AND T1.C_ORISOURCE = T9.SRC_DICT_CLS_CDVAL
   AND T9.VALID_FLAG = '1'
  LEFT JOIN ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD T10 --基金账户信息
    ON T1.C_FUNDACCO = T10.C_FUNDACCO
   AND T10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
;

"
