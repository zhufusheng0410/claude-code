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
-- ** 主    题:交易
-- ** 描    述:存款交易明细表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-07-04
-- ** 修改日志:
-- ** 2023-07-04，xiemn，新建
-- ** 目 标 表：DWSXDAY.DWS_TRAN_DPSI_TRAN_DETAIL_PTD           存款交易明细表
-- ** 源    表：DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD      O32场外业务确认表
-- **           DWDXDAY.DWD_TRAN_DPSI_ISTCT_DETAIL_PTD   O32存款指令明细表
-- **           DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD   账套产品基本信息
-- **           DWDXDAY.DWD_PROD_PORTF_PFD               O32投资组合表
-- **           DWDXDAY.DWD_PROD_AST_UNIT_PFD            O32资产单元表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD       证券基本信息
-- **           DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD        证券分类信息
-- **           DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO   标准字典分类枚举信息
-- **           DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD    O32指令证券明细表
-- **           DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD        交易对手方编码映射
-- **           DWDXDAY.DWD_AGMT_DPSI_AGMT_PFD O32       存款合同表
-- **************************************************************************

set mapred.max.split.size=256000000;                                        
set mapred.min.split.size.per.node=100000000;                               
set mapred.min.split.size.per.rack=100000000;                               
set hive.merge.mapredfiles=true;                                            
set hive.merge.mapfiles=true;                                               
set hive.merge.smallfiles.avgsize=16000000;                                 
set hive.merge.size.per.task=256000000;                                     
set hive.exec.reducers.bytes.per.reducer=10240000000;                       
set mapreduce.job.reduces=1;                                                

ALTER TABLE DWSXDAY.DWS_TRAN_DPSI_TRAN_DETAIL_PTD DROP PARTITION(P_DT='${p_end_dt}')
;
INSERT OVERWRITE TABLE DWSXDAY.DWS_TRAN_DPSI_TRAN_DETAIL_PTD PARTITION(P_DT='${p_end_dt}')
SELECT 
       T1.BUSIN_DATE                                                                 AS TRAN_DATE                               --交易日期
     , T1.CNFM_NO                                                                    AS DEAL_SERIALNO                           --成交序号
     , T1.CNFM_NO                                                                    AS DEAL_NO                                 --成交编号
     , T1.ISTCT_SERIALNO                                                             AS ISTCT_SERIALNO                          --指令序号
     , T1.ISTCT_MODIFY_SERIALNO                                                      AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T10.INR_AGMT_NO                                                               AS INR_AGMT_NO                             --内部合同号
     , T1.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.PROD_INCD                                                                  AS PROD_INCD                               --产品内码
     , T2.CSNAME                                                                     AS PROD_NAME                               --产品名称
     , T3.AST_UNIT_SERIALNO                                                          AS AST_UNIT_SERIALNO                       --资产单元序号
     , T4.AST_UNIT_NAME                                                              AS AST_UNIT_NAME                           --资产单元名称
     , T1.PORTF_SERIALNO                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.PORTF_NAME                                                                 AS PORTF_NAME                              --投资组合名称
     , T1.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T1.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.SCR_INCD                                                                   AS SCR_INCD                                --证券内码
     , T5.SCR_SNAME                                                                  AS SCR_NAME                                --证券名称
     , T6.SCR_PRI_CATG_CODE                                                          AS SCR_PRI_CATG_CODE                       --证券一级分类代码
     , T6.SCR_PRI_CATG_NAME                                                          AS SCR_PRI_CATG_NAME                       --证券一级分类名称
     , T6.SCR_SCD_CATG_CODE                                                          AS SCR_SCD_CATG_CODE                       --证券二级分类代码
     , T6.SCR_SCD_CATG_NAME                                                          AS SCR_SCD_CATG_NAME                       --证券二级分类名称
     , T1.BUSIN_CATG_CODE                                                            AS BUSIN_CATG_CODE                         --业务分类代码
     , T7.STD_DICT_CLS_CDVAL_DESC                                                    AS BUSIN_CATG_NAME                         --业务分类名称
     , T1.ENTU_ORNT_CODE                                                             AS ENTU_ORNT_CODE                          --委托方向代码
     , T8.STD_DICT_CLS_CDVAL_DESC                                                    AS ENTU_ORNT_NAME                          --委托方向名称
     , T1.MKT_CODE                                                                   AS TRAN_MKT_CODE                           --交易市场代码
     , T13.STD_DICT_CLS_CDVAL_DESC                                                   AS TRAN_MKT_NAME                           --交易市场名称
     , T1.INV_TYPE_CODE                                                              AS INV_TYPE_CODE                           --投资类型代码
     , T14.STD_DICT_CLS_CDVAL_DESC                                                   AS INV_TYPE_NAME                           --投资类型名称
     , T9.LIQUI_VELOCITY_CODE                                                        AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , T15.STD_DICT_CLS_CDVAL_DESC                                                   AS LIQUI_VELOCITY_NAME                     --清算速度名称
     , T10.DEPO_RECE_NO                                                              AS DEPO_RECE_NO                            --存单编号
     , T10.DPSI_ACCT                                                                 AS DPSI_ACCT                               --存款帐号
     , T10.ACCT_NAME                                                                 AS ACCT_NAME                               --账户名称
     , T10.DPSI_LCT                                                                  AS DPSI_LCT                                --存款地
     , T1.CNTP_NUM                                                                   AS CNTP_NUM                                --交易对手编码
     , T11.CNTP_NAME                                                                 AS CNTP_NAME                               --交易对手名称
     , T10.DPSI_SUBBRANCH                                                            AS DPSI_SUBBRANCH                          --存款支行
     , T10.DPSI_PROVINCE                                                             AS DPSI_PROVINCE                           --存款省份
     , T10.DPSI_CITY                                                                 AS DPSI_CITY                               --存款城市
     , T10.DPSI_TYPE_CODE                                                            AS DPSI_TYPE_CODE                          --存款类型代码
     , T10.DPSI_MATY_UNIT_CODE                                                       AS DPSI_MATY_UNIT_CODE                     --存款期限单位代码
     , T10.DPSI_MATY                                                                 AS DPSI_MATY_UM                            --存款期限(月)
     , NVL(T10.IR,0)                                                                 AS IR                                      --利率
     , T10.VALUE_DATE                                                                AS VALUE_DATE                              --起息日期
     , T12.DUE_DATE                                                                  AS DUE_DATE                                --到期日期
     , T10.INTP_MODE_CODE                                                            AS INTP_MODE_CODE                          --付息方式代码
     , T10.INTP_INTERVL                                                              AS INTP_INTERVL                            --付息间隔
     , T10.INTP_INTERVL_UNIT_CODE                                                    AS INTP_INTERVL_UNIT_CODE                  --付息间隔单位代码
     , T10.INTR_DEAL_MODE_CODE                                                       AS INTR_DEAL_MODE_CODE                     --利息处理方式代码
     , T10.AHED_DRAW_LMT_CODE                                                        AS AHED_DRAW_LMT_CODE                      --提前支取限制代码
     , T10.DRAW_TYPE_CODE                                                            AS DRAW_TYPE_CODE                          --支取类型代码
     , T10.NOTIC_DAYS                                                                AS NOTIC_DAYS                              --通知天数
     , T10.NOTIC_DATE                                                                AS NOTIC_DATE                              --通知日期
     , T10.DRAW_DATE                                                                 AS DRAW_DATE                               --支取日期
     , T10.FST_SETL_DATE                                                             AS FST_SETL_DATE                           --首次结算日期
     , NVL(T1.AMT,0)                                                                 AS PRIN                                    --本金
     , 'DWD_TRAN_OTC_BUSIN_CNFM_PTD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
  FROM DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD T1  --O32场外业务确认表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T2 --账套产品基本信息
    ON T1.SFAC_NUM = T2.SFAC_NUM
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_PORTF_PFD T3 --O32投资组合表
    ON T1.PORTF_SERIALNO = T3.PORTF_SERIALNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_AST_UNIT_PFD T4 --O32资产单元表
    ON T3.AST_UNIT_SERIALNO = T4.AST_UNIT_SERIALNO
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T5 --证券基本信息
    ON T1.SCR_NUM = T5.SCR_NUM --证券编码
   AND T5.VALID_FLAG = '1'
   AND T5.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD T6 --证券分类信息
    ON T1.SCR_NUM = T6.SCR_NUM --证券编码
   AND T6.SSYS = 'O32'
   AND T6.VALID_FLAG = '1'
   AND T6.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T7 --标准字典分类枚举信息
    ON T7.STD_DICT_CLS_CD = 'ISTCT_BUSIN_TYPES_CODE'
   AND T7.STD_DICT_CLS_CDVAL = T1.BUSIN_CATG_CODE
   AND T7.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T8 --标准字典分类枚举信息
    ON T8.STD_DICT_CLS_CD = 'ENTR_ORIENTATION_CODE'
   AND T8.STD_DICT_CLS_CDVAL = T1.ENTU_ORNT_CODE
   AND T8.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD T9 --O32指令证券明细表
    ON T1.ISTCT_SERIALNO = T9.ISTCT_SERIALNO
   AND T1.ISTCT_MODIFY_SERIALNO = T9.ISTCT_MODIFY_SERIALNO
   AND T1.SCR_INCD = T9.SCR_INCD
   AND T9.RISK_INFLU_FLAG_CODE = '0' --0正常
   AND T1.ISTCT_RELE_DATE = T9.P_DT
  LEFT JOIN DWDXDAY.DWD_TRAN_DPSI_ISTCT_DETAIL_PTD T10 --O32存款指令明细表
    ON T1.ISTCT_SERIALNO = T10.ISTCT_SERIALNO
   AND T1.ISTCT_MODIFY_SERIALNO = T10.ISTCT_MODIFY_SERIALNO
   AND T1.ISTCT_RELE_DATE = T10.P_DT
  LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD T11 --交易对手方编码映射
    ON T1.CNTP_NUM = T11.CNTP_NUM
   AND T11.ST_DATE <= '${p_end_dt}'
   AND T11.END_DATE >= '${p_end_dt}'
   AND T11.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_AGMT_DPSI_AGMT_PFD T12 --O32存款合同表
    ON T10.INR_AGMT_NO = T12.INR_AGMT_NO
   AND T12.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T13 --标准字典分类枚举信息
    ON T13.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T13.STD_DICT_CLS_CDVAL = T1.MKT_CODE
   AND T13.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T14 --标准字典分类枚举信息
    ON T14.STD_DICT_ID = 'DIC0000014'
   AND T14.STD_DICT_CLS_CDVAL = T1.INV_TYPE_CODE
   AND T14.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T15 --标准字典分类枚举信息
    ON T15.STD_DICT_ID = 'DIC0000061'
   AND T15.STD_DICT_CLS_CDVAL = T9.LIQUI_VELOCITY_CODE
   AND T15.VALID_FLAG = '1' --有效标志
WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
  AND T1.ENTU_ORNT_CODE = '59'                        --59 存款
  AND T1.BUSIN_PROCE_CATG_CODE = '03'                 --业务过程分类代码 03 成交确认
  AND T1.STAT_CODE = '01'                             --状态代码为 01-正常

;

"