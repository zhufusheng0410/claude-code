#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env

day_8_ago=$(date -d "8 day ago" +"%Y%m%d")

inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:交易
-- ** 描    述:在途存单表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_ROUG_DEPO_RECE_PFD      在途存单表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TDEPOSITRECEIPT_PFD 在途存单信息表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD       账套编码映射
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD         证券编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP       标准码值字典映射表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD       证券基本信息
-- **************************************************************************

set hive.strict.checks.type.safety=false;
    set mapred.max.split.size=256000000;
    set mapred.min.split.size.per.node=100000000;
    set mapred.min.split.size.per.rack=100000000;
    set hive.merge.mapredfiles=true;
    set hive.merge.mapfiles=true;
    set hive.merge.smallfiles.avgsize=16000000;
    set hive.merge.size.per.task=256000000;
    set hive.exec.reducers.bytes.per.reducer=10240000000; 
    set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_ROUG_DEPO_RECE_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_CONFIRM_NO                                                               AS CNFM_NO                                 --确认编号
     , T1.L_DEPOSIT_CONFIRM_NO                                                       AS DEPO_RECE_CNFM_SERIALNO                 --存单确认序号
     , T1.L_DATE                                                                     AS DPSI_DATE                               --存入日期
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T13.SYMBOL                                                                    AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , CASE 
         WHEN T1.C_MARKET_NO IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO)) 
       END                                                                           AS TRAN_MKT_CODE                           --交易市场代码
     , CASE 
         WHEN T1.L_SETTLE_SPEED IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_SETTLE_SPEED)) 
       END                                                                           AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE)) 
       END                                                                           AS INV_TYPE_CODE                           --投资类型代码
     , T1.VC_INTER_NO                                                                AS INR_AGMT_NO                             --内部合同号
     , T1.VC_RECEIPT_NO                                                              AS DEPO_RECE_NO                            --存单编号
     , T1.VC_ACCOUNT_NO                                                              AS DPSI_ACCT                               --存款帐号
     , T1.VC_ACCOUNT_NAME                                                            AS ACCT_NAME                               --账户名称
     , T1.VC_PLACE                                                                   AS DPSI_LCT                                --存款地
     , T1.L_BANK                                                                     AS BANK_HEADOFF                            --银行总行
     , T1.VC_MINOR_BANK                                                              AS DPSI_SUBBRANCH                          --存款支行
     , T1.EN_BALANCE                                                                 AS DEPO_RECE_AMT                           --存单金额
     , T1.EN_RATE                                                                    AS IR                                      --利率
     , CASE 
         WHEN T1.C_RATE_TYPE IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RATE_TYPE)) 
       END                                                                           AS IR_TYPE_CODE                            --利率类型代码
     , CASE 
         WHEN T1.C_FLOAT_TYPE IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FLOAT_TYPE)) 
       END                                                                           AS BASI_IR_TYPE_CODE                       --基准利率类型代码
     , CASE 
         WHEN T1.C_RATE_CHANGE_TYPE IS NOT NULL THEN 
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RATE_CHANGE_TYPE)) 
       END                                                                           AS IR_CHG_MODE_CODE                        --利率变动方式代码
     , T1.EN_BASIC_RATE                                                              AS BASIC_SPR                               --基本利差
     , T1.L_BEGIN_DATE                                                               AS VALUE_DATE                              --起息日期
     , T1.L_END_DATE                                                                 AS DUE_DATE                                --到期日期
     , T1.C_AUTO_REDEPOSIT                                                           AS AUTO_TRAN_DPSI_FLAG                     --自动转存标志
     , T1.EN_PAYIN_BALANCE                                                           AS HAS_DPSI_PRIN                           --已存入本金
     , T1.EN_PRE_PAY_BALANCE                                                         AS PREP_DRAW_PRIN                          --待支取本金
     , T1.L_LIMIT_TIME                                                               AS DPSI_MATY                               --存款期限(单位:月)
     , CASE 
         WHEN T1.C_LIMIT_UNIT IS NOT NULL THEN 
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_LIMIT_UNIT)) 
       END                                                                           AS AGMT_MATY_UNIT_CODE                     --合同期限单位代码
     , T1.L_FIRST_SETTLE_DATE                                                        AS FST_SETL_DATE                           --首次结算日期
     , T1.C_INTEREST_PAY_TYPE                                                        AS INTP_MODE_CODE                          --付息方式代码
     , CASE 
         WHEN T1.C_INTEREST_PAY_FREQ IS NOT NULL THEN 
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INTEREST_PAY_FREQ)) 
       END                                                                           AS INTP_FREQ_CODE                          --付息频率代码
     , T1.L_INTEREST_PAY_DATE                                                        AS FST_INTP_DATE                           --首次付息日期
     , T1.L_LAST_INTEREST_DATE                                                       AS LST_INTP_DATE                           --上一付息日期
     , T1.L_LAST_MOD_INTEREST_DATE                                                   AS LST_ADJ_INTR_DATE                       --上一调息日期
     , T1.C_DAY_TYPE                                                                 AS ACCRDAYS                                --计息天数
     , T1.EN_INTEREST                                                                AS RECV_INTR                               --应收利息
     , T1.EN_PUNISH_INTEREST                                                         AS PNLT_AMT                                --罚息金额
     , T1.EN_RECEIVABLE_INTEREST                                                     AS TDY_ACCRUE_INTR                         --当日计提利息
     , T1.EN_TOTAL_INTEREST                                                          AS TOTAL_INTR_INCM                         --累计利息收入
     , T1.C_INTEREST_DEPOSIT                                                         AS INTR_TRAN_DPSI_FLAG                     --利息转存标志
     , T1.C_ADVANCE_LIMIT_FLAG                                                       AS AHED_DRAW_LMT_CODE                      --提前支取限制代码
     , T1.EN_ADVANCE_RATE                                                            AS AHED_DRAW_IR                            --提前支取利率
     , T1.L_NOTIFY_DAYS                                                              AS NOTIC_DAYS                              --通知天数
     , T1.L_ADVANCE_DATE                                                             AS AVL_AHED_DRAW_DATE                      --可提前支取日期
     , T1.L_PAY_SETTLE_DATE                                                          AS DRAW_DELIV_DATE                         --支取交收日期
     , T1.L_USE_DAYS                                                                 AS ACTL_FUTK_DAYS                          --实际占款天数
     , CASE 
         WHEN T1.C_STATUS IS NOT NULL
             THEN COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS)) 
       END                                                                           AS DEPO_RECE_STAT_CODE                     --存单状态代码
     , T1.VC_DEAL_NO                                                                 AS DEAL_NO                                 --成交编号
     , T1.VC_SELFTRADER_NAME                                                         AS ICBC_DELR_NAME                          --本方交易员名称
     , T1.L_TRADE_RIVAL_NO                                                           AS CNTP_INCD                                --交易对手内码
     , T1.VC_RIVALTRADER_ID                                                          AS CNTP_DELR_NUM                           --交易对手交易员ID
     , T1.VC_RIVALTRADER_NAME                                                        AS CNTP_DELR_NAME                          --交易对手交易员名称
     , T1.L_RIVALBANK_ID                                                             AS CUTP_INBK_NUM                           --对手方银行间ID
     , T1.VC_DEPOSIT_OWNER                                                           AS DPSIR_CODE                              --存款人代码
     , T1.L_OPERATOR_NO                                                              AS EXEC_CODE                               --执行人代码
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TDEPOSITRECEIPT_PFD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TDEPOSITRECEIPT_PFD T1  --在途存单信息表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD--证券内码
   AND T3.SSYS = 'O32'--源系统
   AND T3.ST_DATE <= '${p_end_dt}'--开始日期
   AND T3.END_DATE >= '${p_end_dt}'--结束日期
   AND T3.VALID_FLAG = '1'--有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.C_MARKET_NO = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'C_MARKET_NO'--源字典分类
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.L_SETTLE_SPEED = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'L_SETTLE_SPEED'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T6.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T6.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'--源字典分类
   AND T6.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_RATE_TYPE = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_RATE_TYPE'--源字典分类
   AND T7.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_FLOAT_TYPE = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'C_FLOAT_TYPE'--源字典分类
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_RATE_CHANGE_TYPE = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T9.SRC_DICT_CLS_CD = 'C_RATE_CHANGE_TYPE'--源字典分类
   AND T9.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.C_LIMIT_UNIT = T10.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T10.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T10.SRC_DICT_CLS_CD = 'C_LIMIT_UNIT'--源字典分类
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T1.C_INTEREST_PAY_FREQ = T11.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T11.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T11.SRC_DICT_CLS_CD = 'C_INTEREST_PAY_FREQ'--源字典分类
   AND T11.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准码值字典映射表
    ON T1.C_STATUS = T12.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T12.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T12.SRC_DICT_CLS_CD = 'C_AGR_DPSI_STATUS'--源字典分类
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T13 --证券基本信息
    ON T3.SCR_NUM = T13.SCR_NUM--证券编码
   AND T13.VALID_FLAG = '1'
   AND T13.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;

-- 保留近一周数据
ALTER TABLE DWDXDAY.DWD_TRAN_ROUG_DEPO_RECE_PFD DROP PARTITION(P_DT <= '${day_8_ago}')
;

"
