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
-- ** 描述:产品渠道参数
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_CHNL_PARA_PFD  产品渠道参数
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD 基金销售商参数表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD 基金销售商参数表
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_CHNL_PARA_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , CASE WHEN T1.C_SHARETYPES IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPES)) 
        END                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , NULL                                                                          AS ALLOT_CLEARDAYS                         --申购清算天数
     , NULL                                                                          AS REDEM_CLEARDAYS                         --赎回清算天数
     , NULL                                                                          AS BONUS_CLEARDAYS                         --分红清算天数
     , NULL                                                                          AS SCRP_CLEARDAYS                          --认购清算天数
     , CASE
          WHEN T5.STD_DICT_CLS_CD_VAL IS NULL THEN
           CONCAT('@', T1.C_SUBBALANCETYPE)
           ELSE
            T5.STD_DICT_CLS_CD_VAL
        END                                                                          AS SCRP_AMT_ARVD_MODE_CODE                 --认购款到账方式代码
     , T1.C_TNTYPE                                                                   AS TN_MODE                                 --T＋n方式
     , NULL                                                                          AS WORD_MODE_CODE                          --工作日方式代码
     , NULL                                                                          AS CALCT_MODE_CODE                         --计算方式代码
     , T1.F_SERVICERATIO                                                             AS SALE_FEE_RATIO                          --销售服务费率
     , T1.L_BANKACCONO                                                               AS LIQUI_BANK_NO                           --清算银行编号
     , T1.F_FEWFORCEINVEST                                                           AS MIN_CASHDIVI                            --最小现金红利
     , T1.L_FAREBANKACCONO                                                           AS FEE_LIQUI_BANK_NO                       --费用清算银行编号
     , CASE WHEN SUBSTR(REPLACE(T1.D_SERVFAREBGNDATE,'-',''),1,8) = '20991231' THEN
              '29991231'
            ELSE 
              SUBSTR(REPLACE(T1.D_SERVFAREBGNDATE,'-',''),1,8)
       END                                                                           AS BEGIN_DATE                              --起始日期
     , CASE WHEN SUBSTR(REPLACE(T1.D_SERVFAREENDDATE,'-',''),1,8) = '20991231' THEN
              '29991231'
            ELSE 
              SUBSTR(REPLACE(T1.D_SERVFAREENDDATE,'-',''),1,8)
       END                                                                           AS END_DATE                                --截止日期
     , T1.C_PAYFREQ                                                                  AS SERVI_FEE_PAY_FREQ                      --服务费支付频率
     , SUBSTR(REPLACE(T1.D_CONTRACTDATE,'-',''),1,8)                                 AS SIGN_BEGIN_DATE                         --签约起始日期
     , T1.C_ALLOTLIQTYPE                                                             AS ALLOT_CPTL_DELIV_MODE                   --申购资金交收方式
     , T1.C_REDEEMLIQTYPE                                                            AS REDEM_CPTL_DELIV_MODE                   --赎回资金交收方式
     , T1.C_BACKFAREMODE                                                             AS FINAL_SHARIG_MODE                       --后收费分成模式
     , T1.L_ACCONUM                                                                  AS SPEBA_PROD_MAX_ACCT_NUM                 --专户产品最大账户数
     , T1.C_ALLOWEDBREACHRDM                                                         AS IS_PERM_SPON_BREK_REDEM                 --是否允许发起违约赎回
     , T1.C_RATIONAGIOMODE                                                           AS FIXEDPITCH_FREE_MODE                    --定投优惠模式
     , T1.C_EXTRADEALTYPE                                                            AS EXCESS_DEAL_MODE                        --超额申购的处理模式
     , T1.C_CMPECONTRACT                                                             AS CHK_ELEC_AGMT                           --核对电子合同
     , T1.C_ECONTRACTTRADERULE                                                       AS ELEC_AGMT_CTRL_TRAN_RULE                --电子合同控制交易规则
     , T1.C_ECONTRACTTRADE                                                           AS ELEC_AGMT_CTRL_TRAN                     --电子合同控制交易
     , T1.C_ISOTC                                                                    AS IS_OTC_PROD                             --是否OTC产品
     , T1.F_CSHARESSERVICERATIO                                                      AS C_CATG_SALE_FEE_RATIO                   --C类销售服务费率(%)
     , T1.C_SERVICEFARECALTYPE                                                       AS SALE_FEE_CALCT_MODE                     --销售服务费计算方式
     , T1.L_SERVICEFAREDATE                                                          AS SALE_FEE_CALCT_YEAR_DAYS                --销售服务费计算年天数
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TFUNDAGENCY_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD T1  --基金销售商参数表
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
   AND T4.SRC_DICT_CLS_CD = 'C_SHARETYPES'
   AND T1.C_SHARETYPES = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_SUBBALANCETYPE'
   AND T1.C_SUBBALANCETYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;
INSERT INTO DWDXDAY.DWD_PROD_PROD_CHNL_PARA_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , NULL                                                                          AS SHARE_CATG_CODE                         --份额类别代码
     , T1.L_LIQUIDATEALLOT                                                           AS ALLOT_CLEARDAYS                         --申购清算天数
     , T1.L_LIQUIDATEREDEEM                                                          AS REDEM_CLEARDAYS                         --赎回清算天数
     , T1.L_LIQUIDATEBONUS                                                           AS BONUS_CLEARDAYS                         --分红清算天数
     , T1.L_LIQUIDATESUB                                                             AS SCRP_CLEARDAYS                          --认购清算天数
     , CASE WHEN T1.C_SUBBALANCETYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SUBBALANCETYPE)) 
        END                                                                          AS SCRP_AMT_ARVD_MODE_CODE                 --认购款到账方式代码
     , T1.C_TNTYPE                                                                   AS TN_MODE                                 --T＋n方式
     , CASE WHEN T1.C_WORKTYPE IS NOT NULL 
             THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_WORKTYPE)) 
        END                                                                          AS WORD_MODE_CODE                          --工作日方式代码
     , CASE WHEN T1.C_CALCULATETYPE IS NOT NULL 
             THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CALCULATETYPE)) 
        END                                                                          AS CALCT_MODE_CODE                         --计算方式代码
     , T1.F_SERVICERATIO                                                             AS SALE_FEE_RATIO                          --销售服务费率
     , T1.L_BANKACCONO                                                               AS LIQUI_BANK_NO                           --清算银行编号
     , T1.F_FEWFORCEINVEST                                                           AS MIN_CASHDIVI                            --最小现金红利
     , T1.L_FAREBANKACCONO                                                           AS FEE_LIQUI_BANK_NO                       --费用清算银行编号
     , CASE WHEN SUBSTR(REPLACE(T1.D_SERVFAREBGNDATE,'-',''),1,8) = '20991231' THEN
              '29991231'
            ELSE 
              SUBSTR(REPLACE(T1.D_SERVFAREBGNDATE,'-',''),1,8)
       END                                                                           AS BEGIN_DATE                              --起始日期
     , CASE WHEN SUBSTR(REPLACE(T1.D_SERVFAREENDDATE,'-',''),1,8) = '20991231' THEN
              '29991231'
            ELSE 
              SUBSTR(REPLACE(T1.D_SERVFAREENDDATE,'-',''),1,8)
       END                                                                           AS END_DATE                                --截止日期
     , T1.C_PAYFREQ                                                                  AS SERVI_FEE_PAY_FREQ                      --服务费支付频率 
     , SUBSTR(REPLACE(T1.D_CONTRACTDATE,'-',''),1,8)                                 AS SIGN_BEGIN_DATE                         --签约起始日期
     , NULL                                                                          AS ALLOT_CPTL_DELIV_MODE                   --申购资金交收方式
     , NULL                                                                          AS REDEM_CPTL_DELIV_MODE                   --赎回资金交收方式
     , T1.C_BACKFAREMODE                                                             AS FINAL_SHARIG_MODE                       --后收费分成模式
     , NULL                                                                          AS SPEBA_PROD_MAX_ACCT_NUM                 --专户产品最大账户数
     , NULL                                                                          AS IS_PERM_SPON_BREK_REDEM                 --是否允许发起违约赎回
     , NULL                                                                          AS FIXEDPITCH_FREE_MODE                    --定投优惠模式
     , NULL                                                                          AS EXCESS_DEAL_MODE                        --超额申购的处理模式
     , T1.C_CMPECONTRACT                                                             AS CHK_ELEC_AGMT                           --核对电子合同
     , T1.C_ECONTRACTTRADERULE                                                       AS ELEC_AGMT_CTRL_TRAN_RULE                --电子合同控制交易规则
     , T1.C_ECONTRACTTRADE                                                           AS ELEC_AGMT_CTRL_TRAN                     --电子合同控制交易
     , NULL                                                                          AS IS_OTC_PROD                             --是否OTC产品
     , T1.F_CSHARESSERVICERATIO                                                      AS C_CATG_SALE_FEE_RATIO                   --C类销售服务费率(%)
     , NULL                                                                          AS SALE_FEE_CALCT_MODE                     --销售服务费计算方式
     , NULL                                                                          AS SALE_FEE_CALCT_YEAR_DAYS                --销售服务费计算年天数
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TFUNDAGENCY_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD T1  --基金销售商参数表
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
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_SUBBALANCETYPE'
   AND T1.C_SUBBALANCETYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSFTA'
   AND T6.SRC_DICT_CLS_CD = 'C_WORKTYPE'
   AND T1.C_WORKTYPE = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'HSFTA'
   AND T7.SRC_DICT_CLS_CD = 'C_CALCULATETYPE'
   AND T1.C_CALCULATETYPE = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

"
