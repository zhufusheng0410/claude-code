#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
    set hive.strict.checks.type.safety=false;
-- **************************************************************************
-- ** 主题:产品
-- ** 描述:客户保有明细
-- ** 创建者:auto
-- ** 创建日期:2023-08-10
-- ** 修改日志:
-- ** 2023-08-10，auto，新建
-- ** 目标表：DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD  客户保有明细
-- ** 源表：  DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD 客户持仓变更明细
-- **         DWDXDAY.DWD_ACCT_ACCT_UNP_YIEL_PTD 账户未付收益
-- **         DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO 标准字典分类枚举信息
-- **************************************************************************

    set mapred.max.split.size=256000000;
    set mapred.min.split.size.per.node=100000000;
    set mapred.min.split.size.per.rack=100000000;
    set hive.merge.mapredfiles=true;
    set hive.merge.mapfiles=true;
    set hive.merge.smallfiles.avgsize=16000000;
    set hive.merge.size.per.task=256000000;
    set hive.exec.reducers.bytes.per.reducer=10240000000; 
    set mapreduce.job.reduces=2;

ALTER TABLE DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD_TMP DROP PARTITION(P_DT <= '${p_end_dt}');
INSERT OVERWRITE TABLE DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT T2.CNFM_DATE                                                                  AS HLDP_DATE                               --持仓日期
     , T2.CNFM_NO                                                                    AS CNFM_NO                                 --确认号
     , T2.CUST_NUM                                                                   AS CUST_NUM                                --客户编码
     , T2.CUST_INCD                                                                  AS CUST_INCD                               --客户内码
     , T2.CUST_TYPE_CODE                                                             AS CUST_TYPE_CODE                          --客户类型代码
     , T4.STD_DICT_CLS_CDVAL_DESC                                                    AS CUST_TYPE_NAME                          --客户类型名称
     , T2.FUND_ACCO                                                                  AS FUND_ACCO                               --基金账号
     , T2.TRAN_ACCO                                                                  AS TRAN_ACCO                               --交易账号
     , T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T8.CSNAME                                                                     AS PROD_NAME                               --产品名称
     , T2.CHAG_FORM_CODE                                                             AS CHAG_FORM_CODE                          --收费形式代码
     , T5.STD_DICT_CLS_CDVAL_DESC                                                    AS CHAG_FORM_NAME                          --收费形式名称
     , T2.BONUS_MODE_CODE                                                            AS BONUS_MODE_CODE                         --分红方式代码
     , T6.STD_DICT_CLS_CDVAL_DESC                                                    AS BONUS_MODE_NAME                         --分红方式名称
     , T2.TRAN_MKT_CODE                                                              AS TRAN_MKT_CODE                           --交易市场代码
     , T7.STD_DICT_CLS_CDVAL_DESC                                                    AS TRAN_MKT_NAME                           --交易市场名称
     , T2.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T2.CHNL_INCD                                                                  AS CHNL_INCD                               --渠道内码
     , T9.CHNL_NAME                                                                  AS CHNL_NAME                               --渠道名称
     , T2.BTCH_NO                                                                    AS BTCH_NO                                 --网点编号
     , NULL                                                                          AS AFFI_BTCH_NUM                           --归属网点编码
     , T2.HOLD_SHARE                                                                 AS HOLD_SHARE                              --持有份额
     , NVL(T1.THIM_OCCUR_SHARE,0)                                                    AS TDY_CNFM_SHARE                          --当日确认份额
     , NVL(T1.THIM_FRZ_SHARE,0)                                                      AS TDY_FRZ_SHARE                           --当日冻结份额
     , NVL(T2.HOLD_FRZ_SHARE,0)                                                      AS FRZ_SHARE                               --冻结份额
     , NVL(T3.SHARE_BAL,0)                                                           AS INCL_UNP_YIEL_SHARE                     --含未付收益份额
     , NVL(T3.TOTAL_YIEL,0)                                                          AS TOTAL_YIEL                              --累计收益
     , NVL(T3.TDY_NEW_UNP_YIEL,0)                                                    AS TDY_UNP_YIEL                            --当日未付收益
     , NVL(T3.FRZ_UNP_YIEL,0)                                                        AS TOTAL_FRZ_UNP_YIEL                      --累计冻结未付收益
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM (SELECT T1.CNFM_DATE                    
             , T1.FUND_ACCO                    
             , T1.TRAN_ACCO                    
             , T1.PROD_NUM                     
             , T1.CHNL_INCD                     
             , SUM(THIM_OCCUR_SHARE)  AS THIM_OCCUR_SHARE
             , SUM(THIM_FRZ_SHARE)    AS THIM_FRZ_SHARE 
          FROM DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD T1  --客户持仓变更明细
         WHERE T1.P_DT = '${p_end_dt}'
           AND T1.SSYS = 'HSZTA' 
         GROUP BY  T1.CNFM_DATE                    
             , T1.FUND_ACCO                    
             , T1.TRAN_ACCO                    
             , T1.PROD_NUM                     
             , T1.CHNL_INCD
       )T1
  INNER JOIN (SELECT T1.CNFM_DATE                    
                  , T1.CNFM_NO                      
                  , T4.CUST_NUM                   
                  , T1.CUST_INCD                    
                  , T1.CUST_TYPE_CODE               
                  , T1.FUND_ACCO                    
                  , T1.TRAN_ACCO                    
                  , T1.PROD_NUM                     
                  , T1.PROD_CODE                    
                  , T1.CHAG_FORM_CODE               
                  , T1.BONUS_MODE_CODE              
                  , T1.TRAN_MKT_CODE                
                  , T1.CHNL_NUM                     
                  , T1.CHNL_INCD                    
                  , T1.BTCH_NO  
                  , T1.HOLD_SHARE
                  , T1.HOLD_FRZ_SHARE
                  , ROW_NUMBER() OVER (PARTITION BY T1.FUND_ACCO,T1.TRAN_ACCO,T1.PROD_NUM,T1.CHNL_INCD ORDER BY T1.CNFM_DATE DESC ,CAST(T1.REQ_SERIALNO  AS INT) DESC ,T1.CNFM_NO DESC ) RN
               FROM DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD T1  --客户持仓变更明细
               LEFT JOIN DWDXDAY.DWD_PTY_CUST_FUNDACCT_RELA_PFD  T4 --客户基金帐号关系
                 ON T1.CUST_INCD = T4.CUST_INCD
                AND T1.FUND_ACCO = T4.FUNDACCO
                AND T1.SSYS = T4.SSYS
                AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
              WHERE T1.P_DT = '${p_end_dt}'
                AND T1.SSYS = 'HSZTA' 
               )T2
    ON T1.CNFM_DATE = T2.CNFM_DATE
   AND T1.FUND_ACCO = T2.FUND_ACCO
   AND T1.TRAN_ACCO = T2.TRAN_ACCO
   AND T1.PROD_NUM = T2.PROD_NUM
   AND T1.CHNL_INCD = T2.CHNL_INCD
   AND T2.RN = 1
  LEFT JOIN DWDXDAY.DWD_ACCT_ACCT_UNP_YIEL_PTD T3  --账户未付收益
    ON T1.CNFM_DATE = T3.CNFM_DATE
   AND T1.FUND_ACCO = T3.FUND_ACCO
   AND T1.TRAN_ACCO = T3.TRAN_ACCO
   AND T1.PROD_NUM  = T3.PROD_NUM
   AND T1.CHNL_INCD = T3.CHNL_INCD
   AND T3.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T4 --标准字典分类枚举信息
    ON T2.CUST_TYPE_CODE = T4.STD_DICT_CLS_CDVAL
   AND T4.STD_DICT_CLS_CD = 'CUST_TYPE_CODE'
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T5 --标准字典分类枚举信息
    ON T2.CHAG_FORM_CODE = T5.STD_DICT_CLS_CDVAL
   AND T5.STD_DICT_CLS_CD = 'CHAG_FORM_CODE'
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T6 --标准字典分类枚举信息
    ON T2.BONUS_MODE_CODE = T6.STD_DICT_CLS_CDVAL
   AND T6.STD_DICT_CLS_CD = 'BONUS_MODE_CODE'
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T7 --标准字典分类枚举信息
    ON T2.TRAN_MKT_CODE = T7.STD_DICT_CLS_CDVAL
   AND T7.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T7.VALID_FLAG = '1'
  LEFT JOIN  DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T8 --产品基本信息
    ON T1.PROD_NUM = T8.PROD_NUM
   AND T8.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN  DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T9 --渠道基本信息
    ON T1.CHNL_INCD = T9.CHNL_INCD
   AND T9.P_DT =  DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期       
;

INSERT INTO DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT T2.CNFM_DATE                                                                  AS HLDP_DATE                               --持仓日期
     , T2.CNFM_NO                                                                    AS CNFM_NO                                 --确认号
     , T2.CUST_NUM                                                                   AS CUST_NUM                                --客户编码
     , T2.CUST_INCD                                                                  AS CUST_INCD                               --客户内码
     , T2.CUST_TYPE_CODE                                                             AS CUST_TYPE_CODE                          --客户类型代码
     , T4.STD_DICT_CLS_CDVAL_DESC                                                    AS CUST_TYPE_NAME                          --客户类型名称
     , T2.FUND_ACCO                                                                  AS FUND_ACCO                               --基金账号
     , T2.TRAN_ACCO                                                                  AS TRAN_ACCO                               --交易账号
     , T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T8.CSNAME                                                                     AS PROD_NAME                               --产品名称
     , T2.CHAG_FORM_CODE                                                             AS CHAG_FORM_CODE                          --收费形式代码
     , T5.STD_DICT_CLS_CDVAL_DESC                                                    AS CHAG_FORM_NAME                          --收费形式名称
     , T2.BONUS_MODE_CODE                                                            AS BONUS_MODE_CODE                         --分红方式代码
     , T6.STD_DICT_CLS_CDVAL_DESC                                                    AS BONUS_MODE_NAME                         --分红方式名称
     , T2.TRAN_MKT_CODE                                                              AS TRAN_MKT_CODE                           --交易市场代码
     , T7.STD_DICT_CLS_CDVAL_DESC                                                    AS TRAN_MKT_NAME                           --交易市场名称
     , T2.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T2.CHNL_INCD                                                                  AS CHNL_INCD                               --渠道内码
     , T9.CHNL_NAME                                                                  AS CHNL_NAME                               --渠道名称
     , T2.BTCH_NO                                                                    AS BTCH_NO                                 --网点编号
     , NULL                                                                          AS AFFI_BTCH_NUM                           --归属网点编码
     , T2.HOLD_SHARE                                                                 AS HOLD_SHARE                              --持有份额
     , NVL(T1.THIM_OCCUR_SHARE,0)                                                    AS TDY_CNFM_SHARE                          --当日确认份额
     , NVL(T1.THIM_FRZ_SHARE,0)                                                      AS TDY_FRZ_SHARE                           --当日冻结份额
     , NVL(T2.HOLD_FRZ_SHARE,0)                                                      AS FRZ_SHARE                               --冻结份额
     , NVL(T3.SHARE_BAL,0)                                                           AS INCL_UNP_YIEL_SHARE                     --含未付收益份额
     , NVL(T3.TOTAL_YIEL,0)                                                          AS TOTAL_YIEL                              --累计收益
     , NVL(T3.TDY_NEW_UNP_YIEL,0)                                                    AS TDY_UNP_YIEL                            --当日未付收益
     , NVL(T3.FRZ_UNP_YIEL,0)                                                        AS TOTAL_FRZ_UNP_YIEL                      --累计冻结未付收益
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM (SELECT T1.CNFM_DATE                    
             , T1.CNFM_NO                      
             , T4.CUST_NUM                   
             , T1.CUST_INCD                    
             , T1.CUST_TYPE_CODE               
             , T1.FUND_ACCO                    
             , T1.TRAN_ACCO                    
             , T1.PROD_NUM                     
             , T1.PROD_CODE                    
             , T1.CHAG_FORM_CODE               
             , T1.BONUS_MODE_CODE              
             , T1.TRAN_MKT_CODE                
             , T1.CHNL_NUM                     
             , T1.CHNL_INCD                    
             , T1.BTCH_NO  
             , T1.HOLD_SHARE
             , T1.HOLD_FRZ_SHARE
             , ROW_NUMBER() OVER (PARTITION BY T1.FUND_ACCO,T1.TRAN_ACCO,T1.PROD_NUM,T1.CHNL_INCD ORDER BY T1.CNFM_DATE DESC ,CAST(T1.REQ_SERIALNO  AS INT) DESC ,T1.CNFM_NO DESC ) RN
          FROM DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD T1  --客户持仓变更明细
          LEFT JOIN DWDXDAY.DWD_PTY_CUST_FUNDACCT_RELA_PFD  T4 --客户基金帐号关系
            ON T1.CUST_INCD = T4.CUST_INCD
           AND T1.FUND_ACCO = T4.FUNDACCO
           AND T1.SSYS = T4.SSYS
           AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
         WHERE T1.P_DT = '${p_end_dt}'
           AND T1.SSYS = 'HSFTA' 
               )T2
  LEFT JOIN (SELECT T1.CNFM_DATE                    
                  , T1.FUND_ACCO                    
                  , T1.TRAN_ACCO                    
                  , T1.PROD_NUM                     
                  , T1.CHNL_INCD                     
                  , SUM(THIM_OCCUR_SHARE)  AS THIM_OCCUR_SHARE
                  , SUM(THIM_FRZ_SHARE)    AS THIM_FRZ_SHARE 
               FROM DWDXDAY.DWD_AST_CUST_HLDP_ALTR_DETAIL_PTD T1  --客户持仓变更明细
              WHERE T1.P_DT = '${p_end_dt}'
                AND T1.SSYS = 'HSFTA' 
                AND T1.CNFM_DATE = '${p_end_dt}'
              GROUP BY  T1.CNFM_DATE                    
                  , T1.FUND_ACCO                    
                  , T1.TRAN_ACCO                    
                  , T1.PROD_NUM                     
                  , T1.CHNL_INCD
       )T1 
   ON T1.CNFM_DATE = T2.CNFM_DATE
  AND T1.FUND_ACCO = T2.FUND_ACCO
  AND T1.TRAN_ACCO = T2.TRAN_ACCO
  AND T1.PROD_NUM =  T2.PROD_NUM
  AND T1.CHNL_INCD = T2.CHNL_INCD
  AND T2.RN = 1
  LEFT JOIN DWDXDAY.DWD_ACCT_ACCT_UNP_YIEL_PTD T3  --账户未付收益
    ON T2.FUND_ACCO = T3.FUND_ACCO
   AND T2.TRAN_ACCO = T3.TRAN_ACCO
   AND T2.PROD_NUM  = T3.PROD_NUM
   AND T2.CHNL_INCD = T3.CHNL_INCD
   AND T3.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T4 --标准字典分类枚举信息
    ON T2.CUST_TYPE_CODE = T4.STD_DICT_CLS_CDVAL
   AND T4.STD_DICT_CLS_CD = 'CUST_TYPE_CODE'
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T5 --标准字典分类枚举信息
    ON T2.CHAG_FORM_CODE = T5.STD_DICT_CLS_CDVAL
   AND T5.STD_DICT_CLS_CD = 'CHAG_FORM_CODE'
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T6 --标准字典分类枚举信息
    ON T2.BONUS_MODE_CODE = T6.STD_DICT_CLS_CDVAL
   AND T6.STD_DICT_CLS_CD = 'BONUS_MODE_CODE'
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T7 --标准字典分类枚举信息
    ON T2.TRAN_MKT_CODE = T7.STD_DICT_CLS_CDVAL
   AND T7.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T7.VALID_FLAG = '1'
  LEFT JOIN  DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T8 --产品基本信息
    ON T2.PROD_NUM = T8.PROD_NUM
   AND T8.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN  DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T9 --渠道基本信息
    ON T2.CHNL_INCD = T9.CHNL_INCD
   AND T9.P_DT =  DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期       
;

-- 今日最新持仓信息
INSERT OVERWRITE TABLE DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT  '${p_end_dt}'                             --持仓日期
     , T1.HLDP_DATE                               --持仓变更日期
     , T1.CNFM_NO                                 --确认号
     , T1.CUST_NUM                                --客户编码
     , T1.CUST_INCD                               --客户内码
     , T1.CUST_TYPE_CODE                          --客户类型代码
     , T1.CUST_TYPE_NAME                          --客户类型名称
     , T1.FUND_ACCO                               --基金账号
     , T1.TRAN_ACCO                               --交易账号
     , T1.PROD_NUM                                --产品编码
     , T1.PROD_CODE                               --产品代码
     , T1.PROD_NAME                               --产品名称
     , T1.CHAG_FORM_CODE                          --收费形式代码
     , T1.CHAG_FORM_NAME                          --收费形式名称
     , T1.BONUS_MODE_CODE                         --分红方式代码
     , T1.BONUS_MODE_NAME                         --分红方式名称
     , T1.TRAN_MKT_CODE                           --交易市场代码
     , T1.TRAN_MKT_NAME                           --交易市场名称
     , T1.CHNL_NUM                                --渠道编码
     , T1.CHNL_INCD                               --渠道内码
     , T1.CHNL_NAME                               --渠道名称
     , T1.BTCH_NO                                 --网点编号
     , T1.AFFI_BTCH_NUM                           --归属网点编码
     , T1.HOLD_SHARE                              --持有份额
     , T1.TDY_CNFM_SHARE                          --当日确认份额
     , T1.TDY_FRZ_SHARE                           --当日冻结份额
     , T1.FRZ_SHARE                               --冻结份额
     , T1.INCL_UNP_YIEL_SHARE                    --含未付收益份
     , T1.TOTAL_YIEL                             --累计收益
     , T1.TDY_UNP_YIEL                            --当日未付收益
     , T1.TOTAL_FRZ_UNP_YIEL                     --累计冻结未付
     , T1.LD_TIME                                 --加载时间
     , T1.MODIFY_TIME                             --修改时间
  FROM DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD_TMP T1 --客户保有明细
WHERE T1.P_DT = '${p_end_dt}'
 ;
 
 -- 今日无最新持仓的,用昨天数据填充,当日指标给0
INSERT INTO DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT '${p_end_dt}' HLDP_DATE                               --持仓日期
     , T1.HLDP_ALTR_DATE  --持仓变更日期
     , T1.CNFM_NO                                 --确认号
     , T1.CUST_NUM                                --客户编码
     , T1.CUST_INCD                               --客户内码
     , T1.CUST_TYPE_CODE                          --客户类型代码
     , T1.CUST_TYPE_NAME                          --客户类型名称
     , T1.FUND_ACCO                               --基金账号
     , T1.TRAN_ACCO                               --交易账号
     , T1.PROD_NUM                                --产品编码
     , T1.PROD_CODE                               --产品代码
     , T1.PROD_NAME                               --产品名称
     , T1.CHAG_FORM_CODE                          --收费形式代码
     , T1.CHAG_FORM_NAME                          --收费形式名称
     , T1.BONUS_MODE_CODE                         --分红方式代码
     , T1.BONUS_MODE_NAME                         --分红方式名称
     , T1.TRAN_MKT_CODE                           --交易市场代码
     , T1.TRAN_MKT_NAME                           --交易市场名称
     , T1.CHNL_NUM                                --渠道编码
     , T1.CHNL_INCD                               --渠道内码
     , T1.CHNL_NAME                               --渠道名称
     , T1.BTCH_NO                                 --网点编号
     , T1.AFFI_BTCH_NUM                           --归属网点编码
     , T1.HOLD_SHARE                              --持有份额
     , 0 TDY_CNFM_SHARE                           --当日确认份额
     , 0 TDY_FRZ_SHARE                            --当日冻结份额
     , T1.FRZ_SHARE                               --冻结份额
     , NVL(T3.SHARE_BAL,T1.INCL_UNP_YIEL_SHARE)                    AS INCL_UNP_YIEL_SHARE                     --含未付收益份额
     , NVL(T3.TOTAL_YIEL,T1.TOTAL_YIEL)                            AS TOTAL_YIEL                              --累计收益
     , NVL(T3.TDY_NEW_UNP_YIEL,0)                                  AS TDY_UNP_YIEL                            --当日未付收益
     , NVL(T3.FRZ_UNP_YIEL,T1.TOTAL_FRZ_UNP_YIEL)                  AS TOTAL_FRZ_UNP_YIEL                      --累计冻结未付收益
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                               --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                               --修改时间
  FROM DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD T1 --客户保有明细
  LEFT JOIN DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD_TMP T2
    ON T1.FUND_ACCO = T2.FUND_ACCO
   AND T1.TRAN_ACCO = T2.TRAN_ACCO
   AND T1.PROD_NUM  = T2.PROD_NUM
   AND T1.CHNL_INCD = T2.CHNL_INCD
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_ACCT_ACCT_UNP_YIEL_PTD T3  --账户未付收益
    ON T1.FUND_ACCO = T3.FUND_ACCO
   AND T1.TRAN_ACCO = T3.TRAN_ACCO
   AND T1.PROD_NUM  = T3.PROD_NUM
   AND T1.CHNL_INCD = T3.CHNL_INCD
   AND T3.P_DT = '${p_end_dt}'
  LEFT JOIN DWSXDAY.DWS_PROD_INFO_PFD T4
    ON T1.PROD_NUM = T4.PROD_NUM
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
   AND T4.PROD_STAT_CODE  IN(10,11,14)
   AND T4.PROD_END_DATE IS NOT NULL
   AND T4.PROD_END_DATE < T1.P_DT
 WHERE T4.PROD_NUM IS NULL
   AND T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
   AND T2.FUND_ACCO IS NULL
   AND T1.HOLD_SHARE <> 0
 ;

 "