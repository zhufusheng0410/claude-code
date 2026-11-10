#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:交易
-- ** 描述:市场交易确认
-- ** 创建者:auto
-- ** 创建日期:2023-06-14
-- ** 修改日志:
-- ** 2023-06-14，auto，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_MKT_TRAN_CNFM_PTD  市场交易确认
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRM_PTD 交易确认
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TCONFIRM_PTD 交易确认
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
-- **         DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD 客户编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_MKT_TRAN_CNFM_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T1.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
            THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.D_REQUESTDATE                                                              AS REQ_DATE                                --申请日期
     , T1.D_REQUESTTIME                                                              AS REQ_TIME                                --申请时间
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS AGENCY_INCD                             --销售商内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , CASE WHEN T1.C_BUSINFLAG IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSINFLAG)) 
        END                                                                          AS BUSIN_TYPE_CODE                         --业务类型代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T11.PROD_NUM                                                                  AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , '01'                                                                          AS TRAN_MKT_CODE                           --交易市场代码
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , T1.C_CSERIALNO                                                                AS TA_CNFM_NO                              --TA确认号
     , T1.F_CONFIRMBALANCE                                                           AS CNFM_AMT                                --确认金额
     , T1.F_CONFIRMSHARES                                                            AS CNFM_SHARE                              --确认份额
     , T1.F_TRADEFARE                                                                AS TRAN_FEE                                --交易费
     , T1.F_TAFARE                                                                   AS TRFE                                    --过户费
     , T1.F_STAMPTAX                                                                 AS STMP                                    --印花税
     , T1.F_BACKFARE                                                                 AS BACK_CHAG                               --后收手续费
     , T1.F_OTHERFARE1                                                               AS OTH_FEE                                 --其他费用1
     , T1.F_BREACHFARE                                                               AS LDMG                                    --违约金
     , T1.F_PROFITBALANCE                                                            AS PERF_REMU_FEE                           --业绩报酬费
     , T1.F_TOTALFARE                                                                AS TOT_FEE                                 --总费用
     , T1.F_TRADEFARE4AGT                                                            AS TRAN_FEE_COLL_SALE_ORG_FEE              --交易费归销售机构费用
     , T1.F_TRADEFARE4FUND                                                           AS TRAN_FEE_COLL_FUND_AST_FEE              --交易费归基金资产费用
     , T1.F_TAFARE4AGT                                                               AS TRFE_COLL_SALE_ORG_FEE                  --过户费归销售机构费用
     , T1.F_TAFARE4FUND                                                              AS TRFE_COLL_FUND_AST_FEE                  --过户费归基金资产费用
     , T1.F_BACKFARE4AGT                                                             AS FINAL_COLL_SALE_ORG_FEE                 --后收费归销售机构费用
     , T1.F_BACKFARE4FUND                                                            AS FINAL_COLL_FUND_AST_FEE                 --后收费归基金资产费用
     , T1.F_OTHERFARE14AGT                                                           AS OTHER_FEE_COLL_SALE_ORG_FEE             --其他费归销售机构费用
     , T1.F_OTHERFARE14FUND                                                          AS OTHER_FEE_COLL_FUND_AST_FEE             --其他费归基金资产费用
     , T1.F_BREACHFARE4AGT                                                           AS LDMG_COLL_SALE_ORG_FEE                  --违约金归销售机构费用
     , T1.F_BREACHFARE4FUND                                                          AS LDMG_COLL_FUND_AST_FEE                  --违约金归基金资产费用
     , T1.F_PROFITBALANCE4AGT                                                        AS PERF_ROYL_COLL_AGENCY_FEE               --业绩提成归销售商费用
     , T1.F_PROFITBALANCE4FUND                                                       AS PERF_REMU_COLL_FUND_AST_FEE             --业绩报酬归基金资产费用
     , T1.F_INTEREST                                                                 AS INTR                                    --利息
     , T1.F_INTERESTTAX                                                              AS INTR_TAX                                --利息税
     , T1.F_INTERESTSHARE                                                            AS INTR_TRAN_SHARE                         --利息转份额
     , T1.F_AGIO                                                                     AS ACTL_DISC_RATIO                         --实际折扣率
     , T1.F_NETVALUE                                                                 AS CNFM_DEAL_PRC                           --确认成交价格(基金净值)
     , T1.F_FROZENBALANCE                                                            AS CNFM_FRZ_CPTL                           --确认冻结资金
     , T1.F_UNFROZENBALANCE                                                          AS CNFM_UNFZ_AMT                           --确认解冻金额
     , T1.C_EXCEEDFLAG                                                               AS VAST_REDEM_DEAL_FLAG                    --巨额赎回处理标志
     , CASE WHEN T1.C_STATUS IS NOT NULL 
            THEN COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS)) 
        END                                                                          AS DEAL_STAT_CODE                          --处理标志
     , CASE WHEN T1.C_CAUSE IS NOT NULL 
            THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CAUSE)) 
        END                                                                          AS FAIL_CAUSE_CODE                         --失败原因代码
     , T1.C_TAFLAG                                                                   AS TA_SPON_FLAG                            --TA发起标志
     , T1.F_CHINCOME                                                                 AS PCASH_UNP_YIEL                          --兑现的未付收益
     , T1.F_CHSHARE                                                                  AS PCASH_SHARE                             --兑现的份额
     , T1.F_CONFIRMINCOME                                                            AS CNFM_UNP_YIEL                           --确认的未付收益
     , T1.F_CONFIRMRATIO                                                             AS CNFM_RATE                               --确认比例
     , T1.C_REQUESTNO                                                                AS REQ_NO                                  --申请编号
     , T1.F_BALANCE                                                                  AS REQ_AMT                                 --申请金额
     , T1.F_SHARES                                                                   AS REQ_SHARE                               --申请份额
     , T1.C_OTHERCODE                                                                AS OTHS_PROD_CODE                          --对方产品代码
     , CASE WHEN T1.C_OTHERSHARE IS NOT NULL 
            THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_OTHERSHARE)) 
        END                                                                          AS OTHS_SHARE_CATG                         --对方份额类别
     , T1.C_OTHERACCO                                                                AS OTHS_FUND_ACCO                          --对方基金账号
     , T1.C_OTHERAGENCY                                                              AS OTHS_AGENCY_INCD                        --对方销售商内码
     , T1.C_OTHERNETNO                                                               AS OTHS_BTCH                               --对方网点
     , T1.C_OTHERTRADEACCO                                                           AS OTHS_TRAN_ACCO                          --对方交易账号
     , CASE WHEN T1.C_BONUSTYPE IS NOT NULL 
             THEN COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BONUSTYPE)) 
        END                                                                          AS BONUS_MODE_CODE                         --分红方式代码
     , T1.C_ORIREQUESTNO                                                             AS ORI_REQ_NO                              --原申请编号
     , CASE WHEN T1.C_FREEZECAUSE IS NOT NULL 
            THEN COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FREEZECAUSE)) 
        END                                                                          AS FRZ_CAUSE_CODE                          --冻结原因代码
     , T1.C_FREEZEENDDATE                                                            AS FRZ_END_DATE                            --冻结截止日期
     , T1.C_PROTOCOLNO                                                               AS AGR_NO                                  --协议号
     , T1.C_TACODE                                                                   AS TA_CODE                                 --TA代码
     , CASE WHEN T1.C_FUNDMETHOD IS NOT NULL 
            THEN COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUNDMETHOD)) 
        END                                                                          AS CPTL_MODE_CODE                          --资金方式代码
     , CASE WHEN T1.C_SUBFUNDMETHOD IS NOT NULL 
            THEN COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SUBFUNDMETHOD)) 
        END                                                                          AS DETAIL_CPTL_MODE_CODE                   --明细资金方式代码
     , T1.C_BROKER                                                                   AS BROKER                                  --经纪人
     , T1.C_CHILDNETNO                                                               AS OPER_BTCH_NO                            --操作网点编号
     , T1.C_PARTNERID                                                                AS PART_CODE                               --合作方代码
     , T1.C_CITYNO                                                                   AS CITY_NO                                 --城市编号
     , T1.C_MEMO                                                                     AS MEMO                                    --备注
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TCONFIRM_PTD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRM_PTD T1  --交易确认
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T4 --渠道基本信息
    ON T4.CHNL_INCD = T1.C_AGENCYNO
   AND T4.P_DT =  DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSZTA'
   AND T6.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'HSZTA'
   AND T7.SRC_DICT_CLS_CD = 'C_CAUSE'
   AND T1.C_CAUSE = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'HSZTA'
   AND T8.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_OTHERSHARE = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
    ON T9.SSYS = 'HSZTA'
   AND T9.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE = T9.SRC_DICT_CLS_CDVAL
   AND T9.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准字典码值映射
    ON T10.SSYS = 'HSZTA'
   AND T10.SRC_DICT_CLS_CD = 'C_FREEZECAUSE'
   AND T1.C_FREEZECAUSE = T10.SRC_DICT_CLS_CDVAL
   AND T10.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T11 --产品编码映射
    ON T1.C_FUNDCODE = T11.PROD_INCD
   AND T11.SSYS = 'HSZTA'
   AND T11.ST_DATE <= '${p_end_dt}'
   AND T11.END_DATE >= '${p_end_dt}'
   AND T11.VALID_FLAG = '1' --有效标志
   AND T11.P_DT =  DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准字典码值映射
    ON T12.SSYS = 'HSZTA'
   AND T12.SRC_DICT_CLS_CD = 'C_STATUS_DEAL'
   AND T1.C_STATUS = T12.SRC_DICT_CLS_CDVAL
   AND T12.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准字典码值映射
    ON T13.SSYS = 'HSZTA'
   AND T13.SRC_DICT_CLS_CD = 'C_FUNDMETHOD'
   AND T1.C_FUNDMETHOD = T13.SRC_DICT_CLS_CDVAL
   AND T13.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准字典码值映射
    ON T14.SSYS = 'HSZTA'
   AND T14.SRC_DICT_CLS_CD = 'C_SUBFUNDMETHOD'
   AND T1.C_SUBFUNDMETHOD = T14.SRC_DICT_CLS_CDVAL
   AND T14.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;



INSERT INTO DWDXDAY.DWD_TRAN_MKT_TRAN_CNFM_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       SUBSTR(REPLACE(T1.D_CDATE,'-',''),1,8)                                        AS CNFM_DATE                               --确认日期
     , NULL                                                                          AS CUST_NUM                                --客户编码
     , T1.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
            THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , SUBSTR(REPLACE(D_REQUESTTIME,'-',''),1,8)                                     AS REQ_DATE                                --申请日期
     , SUBSTR(REPLACE(D_REQUESTTIME,':',''),11,8)                                    AS REQ_TIME                                --申请时间
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS AGENCY_INCD                             --销售商内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , CASE WHEN T1.C_BUSINFLAG IS NOT NULL 
            THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSINFLAG)) 
        END                                                                          AS BUSIN_TYPE_CODE                         --业务类型代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T11.PROD_NUM                                                                  AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , CASE WHEN T1.C_BOURSEFLAG IS NOT NULL 
            THEN COALESCE(T15.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BOURSEFLAG)) 
       END                                                                           AS TRAN_MKT_CODE                           --交易市场代码
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , T1.C_CSERIALNO                                                                AS TA_CNFM_NO                              --TA确认号
     , T1.F_CONFIRMBALANCE                                                           AS CNFM_AMT                                --确认金额
     , T1.F_CONFIRMSHARES                                                            AS CNFM_SHARE                              --确认份额
     , T1.F_TRADEFARE                                                                AS TRAN_FEE                                --交易费
     , T1.F_TAFARE                                                                   AS TRFE                                    --过户费
     , T1.F_STAMPTAX                                                                 AS STMP                                    --印花税
     , T1.F_BACKFARE                                                                 AS BACK_CHAG                               --后收手续费
     , T1.F_OTHERFARE1                                                               AS OTH_FEE                                 --其他费用1
     , NULL                                                                          AS LDMG                                    --违约金
     , NULL                                                                          AS PERF_REMU_FEE                           --业绩报酬费
     , T1.F_TOTALFARE                                                                AS TOT_FEE                                 --总费用
     , NULL                                                                          AS TRAN_FEE_COLL_SALE_ORG_FEE              --交易费归销售机构费用
     , NULL                                                                          AS TRAN_FEE_COLL_FUND_AST_FEE              --交易费归基金资产费用
     , NULL                                                                          AS TRFE_COLL_SALE_ORG_FEE                  --过户费归销售机构费用
     , NULL                                                                          AS TRFE_COLL_FUND_AST_FEE                  --过户费归基金资产费用
     , NULL                                                                          AS FINAL_COLL_SALE_ORG_FEE                 --后收费归销售机构费用
     , NULL                                                                          AS FINAL_COLL_FUND_AST_FEE                 --后收费归基金资产费用
     , NULL                                                                          AS OTHER_FEE_COLL_SALE_ORG_FEE             --其他费归销售机构费用
     , NULL                                                                          AS OTHER_FEE_COLL_FUND_AST_FEE             --其他费归基金资产费用
     , NULL                                                                          AS LDMG_COLL_SALE_ORG_FEE                  --违约金归销售机构费用
     , NULL                                                                          AS LDMG_COLL_FUND_AST_FEE                  --违约金归基金资产费用
     , NULL                                                                          AS PERF_ROYL_COLL_AGENCY_FEE               --业绩提成归销售商费用
     , NULL                                                                          AS PERF_REMU_COLL_FUND_AST_FEE             --业绩报酬归基金资产费用
     , T1.F_INTEREST                                                                 AS INTR                                    --利息
     , T1.F_INTERESTTAX                                                              AS INTR_TAX                                --利息税
     , T1.F_INTERESTSHARE                                                            AS INTR_TRAN_SHARE                         --利息转份额
     , T1.F_AGIO                                                                     AS ACTL_DISC_RATIO                         --实际折扣率
     , T1.F_NETVALUE                                                                 AS CNFM_DEAL_PRC                           --确认成交价格(基金净值)
     , T1.F_FROZENBALANCE                                                            AS CNFM_FRZ_CPTL                           --确认冻结资金
     , T1.F_UNFROZENBALANCE                                                          AS CNFM_UNFZ_AMT                           --确认解冻金额
     , T1.C_EXCEEDFLAG                                                               AS VAST_REDEM_DEAL_FLAG                    --巨额赎回处理标志
     , CASE WHEN T1.C_STATUS IS NOT NULL 
            THEN COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS))
       END                                                                           AS DEAL_STAT_CODE                          --处理标志
     , CASE WHEN T1.C_CAUSE IS NOT NULL 
            THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CAUSE)) 
        END                                                                          AS FAIL_CAUSE_CODE                         --失败原因代码
     , T1.C_TAFLAG                                                                   AS TA_SPON_FLAG                            --TA发起标志
     , T1.F_CHINCOME                                                                 AS PCASH_UNP_YIEL                          --兑现的未付收益
     , T1.F_CHSHARE                                                                  AS PCASH_SHARE                             --兑现的份额
     , T1.F_CONFIRMINCOME                                                            AS CNFM_UNP_YIEL                           --确认的未付收益
     , NULL                                                                          AS CNFM_RATE                               --确认比例
     , T1.C_REQUESTNO                                                                AS REQ_NO                                  --申请编号
     , T1.F_BALANCE                                                                  AS REQ_AMT                                 --申请金额
     , T1.F_SHARES                                                                   AS REQ_SHARE                               --申请份额
     , T1.C_OTHERCODE                                                                AS OTHS_PROD_CODE                          --对方产品代码
     , CASE WHEN T1.C_OTHERSHARE IS NOT NULL 
            THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_OTHERSHARE)) 
        END                                                                          AS OTHS_SHARE_CATG                         --对方份额类别
     , T1.C_OTHERACCO                                                                AS OTHS_FUND_ACCO                          --对方基金账号
     , T1.C_OTHERAGENCY                                                              AS OTHS_AGENCY_INCD                        --对方销售商内码
     , T1.C_OTHERNETNO                                                               AS OTHS_BTCH                               --对方网点
     , NULL                                                                          AS OTHS_TRAN_ACCO                          --对方交易账号
     , CASE WHEN T1.C_BONUSTYPE IS NOT NULL 
            THEN COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BONUSTYPE)) 
        END                                                                          AS BONUS_MODE_CODE                         --分红方式代码
     , T1.C_FORIGINALNO                                                              AS ORI_REQ_NO                              --原申请编号
     , CASE WHEN T1.C_FREEZECAUSE IS NOT NULL 
            THEN COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FREEZECAUSE)) 
        END                                                                          AS FRZ_CAUSE_CODE                          --冻结原因代码
     , T1.C_FREEZEENDDATE                                                            AS FRZ_END_DATE                            --冻结截止日期
     , T1.C_PROTOCOLNO                                                               AS AGR_NO                                  --协议号
     , NULL                                                                          AS TA_CODE                                 --TA代码
     , CASE WHEN T1.C_FUNDTYPE IS NOT NULL 
            THEN COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUNDTYPE)) 
        END                                                                          AS CPTL_MODE_CODE                          --资金方式代码
     , CASE WHEN T1.C_SUBFUNDMETHOD IS NOT NULL 
            THEN COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SUBFUNDMETHOD)) 
        END                                                                          AS DETAIL_CPTL_MODE_CODE                   --明细资金方式代码
     , NULL                                                                          AS BROKER                                  --经纪人
     , T1.C_CHILDNETNO                                                               AS OPER_BTCH_NO                            --操作网点编号
     , T1.C_PARTNERID                                                                AS PART_CODE                               --合作方代码
     , NULL                                                                          AS CITY_NO                                 --城市编号
     , T1.C_MEMO                                                                     AS MEMO                                    --备注
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TCONFIRM_PTD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCONFIRM_PTD T1  --交易确认
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSFTA'
   AND T3.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T4 --渠道基本信息
    ON T4.CHNL_INCD = T1.C_AGENCYNO
   AND T4.P_DT =  DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_BUSINFLAG'
   AND T1.C_BUSINFLAG = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSFTA'
   AND T6.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'HSFTA'
   AND T7.SRC_DICT_CLS_CD = 'C_CAUSE'
   AND T1.C_CAUSE = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'HSFTA'
   AND T8.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_OTHERSHARE = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
    ON T9.SSYS = 'HSFTA'
   AND T9.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE = T9.SRC_DICT_CLS_CDVAL
   AND T9.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准字典码值映射
    ON T10.SSYS = 'HSFTA'
   AND T10.SRC_DICT_CLS_CD = 'C_FREEZECAUSE'
   AND T1.C_FREEZECAUSE = T10.SRC_DICT_CLS_CDVAL
   AND T10.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T11 --产品编码映射
    ON T1.C_FUNDCODE = T11.PROD_INCD
   AND T11.SSYS = 'HSFTA'
   AND T11.ST_DATE <= '${p_end_dt}'
   AND T11.END_DATE >= '${p_end_dt}'
   AND T11.VALID_FLAG = '1' --有效标志
   AND T11.P_DT =  DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准字典码值映射
    ON T12.SSYS = 'HSFTA'
   AND T12.SRC_DICT_CLS_CD = 'C_STATUS_DEAL'
   AND T1.C_STATUS = T12.SRC_DICT_CLS_CDVAL
   AND T12.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准字典码值映射
    ON T13.SSYS = 'HSFTA'
   AND T13.SRC_DICT_CLS_CD = 'C_FUNDTYPE'
   AND T1.C_FUNDTYPE = T13.SRC_DICT_CLS_CDVAL
   AND T13.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准字典码值映射
    ON T14.SSYS = 'HSFTA'
   AND T14.SRC_DICT_CLS_CD = 'C_SUBFUNDMETHOD'
   AND T1.C_SUBFUNDMETHOD = T14.SRC_DICT_CLS_CDVAL
   AND T14.VALID_FLAG = '1'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T15 --标准字典码值映射
    ON T15.SSYS = 'HSFTA'
   AND T15.SRC_DICT_CLS_CD = 'C_BOURSEFLAG'
   AND T1.C_BOURSEFLAG = T15.SRC_DICT_CLS_CDVAL
   AND T15.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
 ;

"
