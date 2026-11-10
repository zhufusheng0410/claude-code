#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主   题:合同
-- ** 描   述:存款合同表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_AGMT_DPSI_AGMT_PFD            存款合同表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TDEPOSITCONTRACT_PTD 存款合同表
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD          证券编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP        标准码值字典映射表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD        证券基本信息
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set mapreduce.job.reduces=3;

INSERT OVERWRITE TABLE DWDXDAY.DWD_AGMT_DPSI_AGMT_PFD
PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.VC_INTER_NO                                                                AS INR_AGMT_NO                             --内部合同号
     , T1.L_DATE                                                                     AS AGMT_DATE                               --合同日期
     , T1.VC_FUND_IDS                                                                AS FUND_SERIALNO                           --基金序号
     , T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T18.SYMBOL                                                                    AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T1.VC_CONTRACT_NO                                                             AS AGMT_NO                                 --合同号
     , T1.VC_CONTRACT_NAME                                                           AS AGMT_NAME                               --合同名称
     , T1.VC_CONTRACT_OWNER                                                          AS AGMT_HDR                                --合同所有人
     , T1.VC_ACCOUNT_NAME                                                            AS OPEN_NAME                               --开户名称
     , T1.L_BANK                                                                     AS BANK_HEADOFF                            --银行总行
     , T1.VC_AFFIX_OPERATOR                                                          AS OURS_SIGNR                              --我方签署人
     , T1.VC_ADVERSARY_OPERATOR                                                      AS OTHS_SIGNR                              --对方签署人
     , T1.L_AFFIX_DATE                                                               AS SIGN_DATE                               --签署日期
     , CASE 
         WHEN T1.C_DEPOSIT_TYPE IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEPOSIT_TYPE)) 
       END                                                                           AS DPSI_TYPE_CODE                          --存款类型代码
     , CASE 
         WHEN T1.C_STATUS IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS)) 
       END                                                                           AS AGMT_STAT_CODE                          --合同状态代码
     , CASE 
         WHEN T1.C_LIMIT_UNIT IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_LIMIT_UNIT)) 
       END                                                                           AS AGMT_MATY_UNIT_CODE                     --合同期限单位代码
     , T1.L_LIMIT_TIME                                                               AS AGMT_MATY                               --合同期限(单位:月)
     , T1.L_END_DATE                                                                 AS DUE_DATE                                --到期日期
     , T1.EN_BALANCE                                                                 AS AGMT_AMT                                --合同金额
     , T1.EN_INTEREST_RATE                                                           AS AGMT_IR                                 --合同利率
     , CASE 
         WHEN T1.C_RATE_TYPE IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RATE_TYPE)) 
       END                                                                           AS INTR_TYPE_CODE                       --利率类型代码
     , CASE 
         WHEN T1.C_FLOAT_TYPE IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FLOAT_TYPE)) 
       END                                                                           AS BASI_INTR_TYPE_CODE                  --基准利率类型代码
     , T1.EN_FLOAT_RATE                                                              AS FLOAT_RATE                              --浮动比例
     , T1.EN_BASIC_RATE                                                              AS BASIC_SPR                               --基本利差
     , T1.EN_LEAST_RATE                                                              AS GUAT_INTR                               --保底利率
     , T1.EN_HIGHEST_RATE                                                            AS CEILG_INTR                              --封顶利率
     , CASE 
         WHEN T1.C_DAY_TYPE IS NOT NULL THEN 
          COALESCE(T17.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DAY_TYPE)) 
       END                                                                           AS INTA_BASI_CODE                       --计息基准代码
     , CASE 
         WHEN T1.C_CAL_TYPE IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CAL_TYPE)) 
       END                                                                           AS INTA_RULE_CODE                       --计息规则代码
     , T1.L_PAY_INTEVAL                                                              AS INTP_INTERVL                            --付息间隔
     , CASE 
         WHEN T1.C_PAY_INTEVAL_UNIT IS NOT NULL THEN 
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PAY_INTEVAL_UNIT)) 
       END                                                                           AS INTP_INTERVL_UNIT_CODE                  --付息间隔单位代码
     , CASE 
         WHEN  T1.C_INTEREST_PAY_TYPE IS NOT NULL THEN 
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INTEREST_PAY_TYPE)) 
       END                                                                           AS INTP_MODE_CODE --付息方式代码
     , CASE 
         WHEN  T1.C_INTEREST_DEPOSIT IS NOT NULL THEN 
          COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INTEREST_DEPOSIT)) 
       END                                                                           AS INTR_DEAL_MODE_CODE                     --利息处理方式代码
     , CASE 
         WHEN  T1.C_INTEREST_CAL_TYPE IS NOT NULL THEN 
          COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INTEREST_CAL_TYPE)) 
       END                                                                           AS INTR_CALCT_MODE_CODE                    --利息计算方式代码
     , CASE 
         WHEN  T1.C_DATE_TYPE IS NOT NULL THEN 
          COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DATE_TYPE)) 
       END                                                                           AS INTP_DAY_CALCT_MODE_CODE                --付息日计算模式代码
     , CASE 
         WHEN  T1.C_BEGIN_PAY_TYPE IS NOT NULL THEN 
          COALESCE(T15.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BEGIN_PAY_TYPE)) 
       END                                                                           AS BEGIN_INTP_MODE_CODE                    --开始时付息模式代码
     , CASE 
         WHEN  T1.C_END_PAY_TYPE IS NOT NULL THEN 
          COALESCE(T16.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_END_PAY_TYPE)) 
       END                                                                           AS LAST_INTP_MODE_CODE                     --最后时付息模式代码
     , T1.L_BASE_DATE                                                                AS ADJ_INTR_BASI_DATE                      --调息基准日期
     , T1.L_BASE_DAYS                                                                AS ADJ_INTR_BASI_WORD                      --调息基准工作日
     , T1.L_ADVANCE_COUNT                                                            AS AVL_AHED_DRAW_TIMES                     --可提前支取次数
     , T1.L_ADVANCE_DEAL_COUNT                                                       AS HAS_DRAW_TIMES                          --已取次数
     , T1.L_ADVANCE_DATE                                                             AS AVL_AHED_DRAW_DATE                      --可提前支取日期
     , T1.L_ADVANCE_DAYS                                                             AS AHED_DRAW_NOTIC_DAYS                    --提前支取通知天数
     , T1.EN_ADVANCE_RATE                                                            AS AHED_DRAW_INTR                          --提前支取利率
     , T1.C_CANCEL_TYPE                                                              AS AVL_REMT_APPT_FLAG                      --可解约标志
     , T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TDEPOSITCONTRACT_PFD'                                                AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TDEPOSITCONTRACT_PFD T1  --存款合同表
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2 --证券编码映射
    ON T1.VC_INTER_CODE = T2.SCR_INCD--证券内码
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
    ON T1.C_STATUS = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'C_AGMT_STATUS'--源字典分类
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_LIMIT_UNIT = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_LIMIT_UNIT'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_RATE_TYPE = T6.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T6.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_RATE_TYPE'--源字典分类
   AND T6.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_FLOAT_TYPE = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_FLOAT_TYPE'--源字典分类
   AND T7.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_CAL_TYPE = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'C_CAL_TYPE'--源字典分类
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.C_PAY_INTEVAL_UNIT = T10.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T10.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T10.SRC_DICT_CLS_CD = 'C_PAY_INTEVAL_UNIT'--源字典分类
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T1.C_INTEREST_PAY_TYPE  = T11.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T11.SSYS= 'O32'  --源系统简称比如O32\FA45
   AND T11.SRC_DICT_CLS_CD= 'C_INTEREST_PAY_TYPE'  --源字典分类
   AND T11.VALID_FLAG='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准码值字典映射表
    ON T1.C_INTEREST_DEPOSIT = T12.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T12.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T12.SRC_DICT_CLS_CD = 'C_INTEREST_DEPOSIT'--源字典分类
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准码值字典映射表
    ON T1.C_INTEREST_CAL_TYPE = T13.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T13.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T13.SRC_DICT_CLS_CD = 'C_INTEREST_CAL_TYPE'--源字典分类
   AND T13.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准码值字典映射表
    ON T1.C_DATE_TYPE = T14.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T14.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T14.SRC_DICT_CLS_CD = 'C_DATE_TYPE'--源字典分类
   AND T14.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T15 --标准码值字典映射表
    ON T1.C_BEGIN_PAY_TYPE = T15.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T15.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T15.SRC_DICT_CLS_CD = 'C_BEGIN_PAY_TYPE'--源字典分类
   AND T15.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T16 --标准码值字典映射表
    ON T1.C_END_PAY_TYPE = T16.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T16.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T16.SRC_DICT_CLS_CD = 'C_END_PAY_TYPE'--源字典分类
   AND T16.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T17 --标准码值字典映射表
    ON T1.C_DAY_TYPE = T17.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T17.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T17.SRC_DICT_CLS_CD = 'C_DAY_TYPE'--源字典分类
   AND T17.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T18 --证券基本信息
    ON T2.SCR_NUM = T18.SCR_NUM--证券编码
   AND T18.VALID_FLAG = '1'
   AND T18.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
;"
