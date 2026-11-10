#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:交易
-- ** 描    述:存款指令明细表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_DPSI_ISTCT_DETAIL_PTD             存款指令明细表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TINSTRUCTIONDEPOSITDETAIL_PTD 存款指令明细表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD                 账套编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP                 标准码值字典映射表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_DPSI_ISTCT_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_DAILY_INSTRUCTION_NO                                                     AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                       AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T1.VC_INTER_NO                                                                AS INR_AGMT_NO                             --内部合同号
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T1.VC_RECEIPT_NO                                                              AS DEPO_RECE_NO                            --存单编号
     , T1.VC_ACCOUNT_NO                                                              AS DPSI_ACCT                               --存款帐号
     , T1.VC_ACCOUNT_NAME                                                            AS ACCT_NAME                               --账户名称
     , T1.VC_PLACE                                                                   AS DPSI_LCT                                --存款地
     , T1.L_BANK                                                                     AS BANK_HEADOFF                            --银行总行
     , T1.VC_MINOR_BANK                                                              AS DPSI_SUBBRANCH                          --存款支行
     , T1.VC_PROVINCECODE                                                            AS DPSI_PROVINCE                           --存款省份
     , T1.VC_CITYNO                                                                  AS DPSI_CITY                               --存款城市
     , CASE 
         WHEN T1.C_DEPOSIT_TYPE IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEPOSIT_TYPE)) 
       END                                                                           AS DPSI_TYPE_CODE                          --存款类型代码
     , CASE 
         WHEN T1.C_LIMIT_UNIT IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_LIMIT_UNIT)) 
       END                                                                           AS DPSI_MATY_UNIT_CODE                     --存款期限单位代码
     , T1.L_LIMIT_TIME                                                               AS DPSI_MATY                               --存款期限(单位:月)
     , T1.EN_RATE                                                                    AS IR                                      --利率
     , T1.L_INTEREST_START_DATE                                                      AS VALUE_DATE                              --起息日期
     , CASE 
         WHEN T1.C_INTEREST_PAY_TYPE IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INTEREST_PAY_TYPE)) 
       END                                                                           AS INTP_MODE_CODE                          --付息方式代码
     , T1.L_PAY_INTEVAL                                                              AS INTP_INTERVL                            --付息间隔
     , CASE 
         WHEN T1.C_PAY_INTEVAL_UNIT IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PAY_INTEVAL_UNIT)) 
       END                                                                           AS INTP_INTERVL_UNIT_CODE                  --付息间隔单位代码
     , CASE 
         WHEN T1.C_INTEREST_DEPOSIT IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INTEREST_DEPOSIT)) 
       END                                                                           AS INTR_DEAL_MODE_CODE                     --利息处理方式代码
     , CASE 
         WHEN T1.C_ADVANCE_LIMIT_FLAG IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ADVANCE_LIMIT_FLAG)) 
       END                                                                           AS AHED_DRAW_LMT_CODE                      --提前支取限制代码
     , CASE 
         WHEN T1.C_DRAW_TYPE IS NOT NULL THEN 
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DRAW_TYPE)) 
       END                                                                           AS DRAW_TYPE_CODE                          --支取类型代码
     , T1.L_NOTIFY_DAYS                                                              AS NOTIC_DAYS                              --通知天数
     , T1.L_NOTIFY_DATE                                                              AS NOTIC_DATE                              --通知日期
     , T1.L_DRAW_DATE                                                                AS DRAW_DATE                               --支取日期
     , T1.L_DEPOSIT_CONFIRM_NO                                                       AS DEPO_RECE_CNFM_SERIALNO                 --存单确认序号
     , T1.L_CONFIRM_NO                                                               AS CNFM_NO                                 --确认编号
     , T1.C_AUTO_REDEPOSIT                                                           AS APPT_TRAN_DPSI_FLAG                     --约定转存标志
     , T1.EN_ADVANCE_RATE                                                            AS SUBMIT_DRAW_IR                          --提交支取利率
     , T1.L_PAYBACK_COUNT                                                            AS REPM_PD_NUM                             --还款期数
     , T1.L_INTEREST_RECEIVED_DATE                                                   AS ACTL_COLL_INTR_DATE                     --实际收息日期
     , T1.EN_SUPPOSED_INTEREST                                                       AS RECV_INTR                               --应收利息
     , T1.EN_PUNITIVE_BALANCE                                                        AS PNLT_AMT                                --罚息金额
     , T1.L_FIRST_CLEAR_DATE                                                         AS FST_SETL_DATE                           --首次结算日期
     , T1.VC_DEPOSIT_OWNER                                                           AS DPSIR_CODE                              --存款人代码
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TINSTRUCTIONDEPOSITDETAIL_PTD'                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTIONDEPOSITDETAIL_PTD T1  --存款指令明细表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T1.C_DEPOSIT_TYPE = T3.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T3.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T3.SRC_DICT_CLS_CD = 'C_DEPOSIT_TYPE'--源字典分类
   AND T3.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.C_LIMIT_UNIT = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'C_LIMIT_UNIT'--源字典分类
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_INTEREST_PAY_TYPE = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_INTEREST_PAY_TYPE'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_PAY_INTEVAL_UNIT = T6.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T6.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_PAY_INTEVAL_UNIT'--源字典分类
   AND T6.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_INTEREST_DEPOSIT = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_INTEREST_DEPOSIT'--源字典分类
   AND T7.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_ADVANCE_LIMIT_FLAG = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'C_ADVANCE_LIMIT_FLAG'--源字典分类
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_DRAW_TYPE = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T9.SRC_DICT_CLS_CD = 'C_DRAW_TYPE'--源字典分类
   AND T9.VALID_FLAG = '1'--有效标志
WHERE  T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;

"
