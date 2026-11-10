#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:产品
-- ** 描述:产品分红明细
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_BONUS_DETAIL_PTD  产品分红明细
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TDIVIDENDDETAIL_PTD 基金分红明细
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TDIVIDENDDETAIL_PTD 基金分红明细
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD  产品编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;

set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_BONUS_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T1.D_REGDATE                                                                  AS BONUS_REG_DATE                          --分红登记日期
     , T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
     , T1.D_DATE                                                                     AS GANT_DATE                               --发放日期
     , T1.D_LASTDATE                                                                 AS REINV_DEAL_DATE                         --再投资处理日期
     , NULL                                                                          AS REINV_REQ_DATE                          --再投资申请日期
     , T1.C_SCHEMANO                                                                 AS BONUS_SCHEME_NO                         --分红方案编号
     , T1.C_CSERIALNO                                                                AS TA_CNFM_NO                              --TA确认号
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , CASE WHEN T1.C_FLAG IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FLAG)) 
        END                                                                          AS BONUS_MODE_CODE                         --分红方式代码
     , T1.F_TOTALSHARE                                                               AS BONUS_BASE_SHARE                        --分红基数份额
     , T1.F_UNITPROFIT                                                               AS PER_UNIT_BONUS                          --每单位分红
     , T1.F_TOTALPROFIT                                                              AS DIVD_GAMT                               --红利总额
     , T1.F_REALBALANCE                                                              AS REAL_CASHDIVI                           --实发现金红利
     , T1.F_REINVESTBALANCE                                                          AS REINV_DIVD_AMT                          --再投资红利金额
     , T1.F_REALSHARES                                                               AS REINV_SHARE                             --再投资份额
     , T1.F_TAX                                                                      AS INCT                                    --所得税
     , T1.F_INCOMETAX                                                                AS INCT_RATIO                              --所得税率
     , T1.F_FARE                                                                     AS REINV_FEE                               --再投资费用
     , T1.F_NETVALUE                                                                 AS REINV_UNIT_NAV                          --再投资单位净值
     , T1.F_FROZENBALANCE                                                            AS FRZ_AMT                                 --冻结金额
     , T1.F_FROZENSHARES                                                             AS FRZ_SHARE                               --冻结份额
     , T1.F_SUMSHARES                                                                AS TOT_SHARE                               --总份额
     , T1.F_DEDUCTBALANCE                                                            AS DEDUCT_AMT                              --扣除金额
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TDIVIDENDDETAIL_PTD'                                               AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TDIVIDENDDETAIL_PTD T1  --基金分红明细
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
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
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_FLAG'
   AND T1.C_FLAG = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_BONUS_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , SUBSTR(REPLACE(T1.D_REGDATE,'-',''),1,8)                                      AS BONUS_REG_DATE                          --分红登记日期
     , SUBSTR(REPLACE(T1.D_CDATE,'-',''),1,8)                                        AS CNFM_DATE                               --确认日期
     , SUBSTR(REPLACE(T1.D_DATE  ,'-',''),1,8)                                       AS GANT_DATE                               --发放日期
     , SUBSTR(REPLACE(T1.D_LASTDATE   ,'-',''),1,8)                                  AS REINV_DEAL_DATE                         --再投资处理日期
     , SUBSTR(REPLACE(T1.D_REQUESTDATE   ,'-',''),1,8)                               AS REINV_REQ_DATE                          --再投资申请日期
     , NULL                                                                          AS BONUS_SCHEME_NO                         --分红方案编号
     , T1.C_CSERIALNO                                                                AS TA_CNFM_NO                              --TA确认号
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , CASE WHEN T1.C_FLAG IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FLAG)) 
        END                                                                          AS BONUS_MODE_CODE                         --分红方式代码
     , T1.F_TOTALSHARE                                                               AS BONUS_BASE_SHARE                        --分红基数份额
     , T1.F_UNITPROFIT                                                               AS PER_UNIT_BONUS                          --每单位分红
     , T1.F_TOTALPROFIT                                                              AS DIVD_GAMT                               --红利总额
     , T1.F_REALBALANCE                                                              AS REAL_CASHDIVI                           --实发现金红利
     , T1.F_REINVESTBALANCE                                                          AS REINV_DIVD_AMT                          --再投资红利金额
     , T1.F_REALSHARES                                                               AS REINV_SHARE                             --再投资份额
     , T1.F_TAX                                                                      AS INCT                                    --所得税
     , T1.F_INCOMETAX                                                                AS INCT_RATIO                              --所得税率
     , T1.F_FARE                                                                     AS REINV_FEE                               --再投资费用
     , T1.F_NETVALUE                                                                 AS REINV_UNIT_NAV                          --再投资单位净值
     , T1.F_FROZENBALANCE                                                            AS FRZ_AMT                                 --冻结金额
     , T1.F_FROZENSHARES                                                             AS FRZ_SHARE                               --冻结份额
     , NULL                                                                          AS TOT_SHARE                               --总份额
     , NULL                                                                          AS DEDUCT_AMT                              --扣除金额
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TDIVIDENDDETAIL_PTD'                                               AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TDIVIDENDDETAIL_PTD T1  --基金分红明细
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
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
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_FLAG'
   AND T1.C_FLAG = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

"
