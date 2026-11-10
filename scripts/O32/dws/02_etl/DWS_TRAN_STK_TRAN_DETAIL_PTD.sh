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
-- ** 描    述:股票交易明细表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-07-04
-- ** 修改日志:
-- ** 2023-07-04，xiemn，新建
-- ** 目 标 表：DWSXDAY.DWS_TRAN_STK_TRAN_DETAIL_PTD         股票交易明细表
-- ** 源    表：DWDXDAY.DWD_TRAN_REAL_DEAL_JOUR_PTD          O32实时成交流水表
-- **           DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD    账套产品基本信息
-- **           DWDXDAY.DWD_PROD_PORTF_PFD                   O32投资组合表
-- **           DWDXDAY.DWD_PROD_AST_UNIT_PFD                O32资产单元表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD           证券基本信息
-- **           DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD            证券分类信息
-- **           DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO       标准字典分类枚举信息
-- **           DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD        O32指令证券明细表
-- **           DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD            交易对手方编码映射
-- **           ODS_XDAY_O32.ODS_O32_TCURRENCYRATE_PFD       O32汇率表
-- **           DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD          O32场外业务确认表
-- **************************************************************************

set mapred.max.split.size=256000000;                                        
set mapred.min.split.size.per.node=100000000;                               
set mapred.min.split.size.per.rack=100000000;                               
set hive.merge.mapredfiles=true;                                            
set hive.merge.mapfiles=true;                                               
set hive.merge.smallfiles.avgsize=16000000;                                 
set hive.merge.size.per.task=256000000;                                     
set hive.exec.reducers.bytes.per.reducer=10240000000;                       
set mapreduce.job.reduces=3;                                                


ALTER TABLE DWSXDAY.DWS_TRAN_STK_TRAN_DETAIL_PTD DROP PARTITION(P_DT='${p_end_dt}')
; 
INSERT OVERWRITE TABLE DWSXDAY.DWS_TRAN_STK_TRAN_DETAIL_PTD PARTITION(P_DT='${p_end_dt}')
SELECT 
       T1.DEAL_DATE                                                                  AS TRAN_DATE                               --交易日期
     , T1.DEAL_SERIALNO                                                              AS DEAL_SERIALNO                           --成交序号
     , T1.DEAL_NO                                                                    AS DEAL_NO                                 --成交编号
     , T1.ISTCT_SERIALNO                                                             AS ISTCT_SERIALNO                          --指令序号
     , T1.ISTCT_MODIFY_SERIALNO                                                      AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
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
     , T1.HOLDER_CODE                                                                AS HOLDER_CODE                             --股东代码
     , T1.REP_SEAT                                                                   AS TRAN_SEAT                               --交易席位
     , T1.BUSIN_CATG_CODE                                                            AS BUSIN_CATG_CODE                         --业务分类代码
     , T7.STD_DICT_CLS_CDVAL_DESC                                                    AS BUSIN_CATG_NAME                         --业务分类名称
     , T1.ENTU_ORNT_CODE                                                             AS ENTU_ORNT_CODE                          --委托方向代码
     , T8.STD_DICT_CLS_CDVAL_DESC                                                    AS ENTU_ORNT_NAME                          --委托方向名称
     , T1.TRAN_MKT_CODE                                                              AS TRAN_MKT_CODE                           --交易市场代码
     , T13.STD_DICT_CLS_CDVAL_DESC                                                   AS TRAN_MKT_NAME                           --交易市场名称
     , T1.INV_TYPE_CODE                                                              AS INV_TYPE_CODE                           --投资类型代码
     , T14.STD_DICT_CLS_CDVAL_DESC                                                   AS INV_TYPE_NAME                           --投资类型名称
     , T9.LIQUI_VELOCITY_CODE                                                        AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , T15.STD_DICT_CLS_CDVAL_DESC                                                   AS LIQUI_VELOCITY_NAME                     --清算速度名称
     , T1.CRRC_CODE                                                                  AS CRRC_CODE                               --币种代码
     , T1.CNTP_NUM                                                                   AS CNTP_NUM                                --交易对手编码
     , T10.CNTP_NAME                                                                 AS CNTP_NAME                               --交易对手名称
     , NVL(T1.DEAL_VOL,0)                                                            AS DEAL_QTY                                --成交数量
     , NVL(T1.DEAL_PRC,0)                                                            AS DEAL_PRC_CRRC                           --成交价格(原币)
     , NVL(T1.DEAL_VOL,0)*NVL(T1.DEAL_PRC,0)                                         AS DEAL_AMT_ORI_CRRC                       --成交金额(原币)
     , NVL(T1.STMP,0)                                                                AS STMP_ORI_CRRC                           --印花税(原币)
     , NVL(T1.EXCHFEE,0)                                                             AS EXCHFEE_ORI_CRRC                        --经手费(原币)
     , NVL(T1.TRFE,0)                                                                AS TRFE_ORI_CRRC                           --过户费(原币)
     , NVL(T1.SFEE,0)                                                                AS SFEE_ORI_CRRC                           --证管费(原币)
     , NVL(T1.TRAN_FEE,0)                                                            AS TRAN_FEE_ORI_CRRC                       --交易费(原币)
     , NVL(T1.SETL_FEE,0)                                                            AS SETL_FEE_ORI_CRRC                       --结算费(原币)
     , NVL(T1.FARE,0)                                                                AS FARE_ORI_CRRC                           --佣金(原币)
     , NVL(T1.OTH_FEE,0)                                                             AS OTHER_FEE_ORI_CRRC                      --其它费用(原币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  -- 02-买入，54-申购
           ROUND(NVL(T1.DEAL_PRC,0) * NVL(T11.EN_ASK_PRICE,0),2)              --成交金额(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.DEAL_PRC,0) * NVL(T11.EN_BID_PRICE,0),2)              --成交金额(原币)*买入价
       END                                                                           AS DEAL_PRC_LC                             --成交价格(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  -- 02-买入，54-申购
           ROUND(NVL(T1.DEAL_VOL,0)*NVL(T1.DEAL_PRC,0) * NVL(T11.EN_ASK_PRICE,0),2)              --成交金额(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.DEAL_VOL,0)*NVL(T1.DEAL_PRC,0) * NVL(T11.EN_BID_PRICE,0),2)              --成交金额(原币)*买入价
       END                                                                           AS DEAL_AMT_LC                             --成交金额(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  --02-买入，54-申购
           ROUND(NVL(T1.STMP,0) * NVL(T11.EN_ASK_PRICE,0),2)                  --印花税(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.STMP,0) * NVL(T11.EN_BID_PRICE,0),2)                  --印花税(原币)*买入价
       END                                                                           AS STMP_LC                                 --印花税(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  --02-买入，54-申购
           ROUND(NVL(T1.EXCHFEE,0) * NVL(T11.EN_ASK_PRICE,0),2)               --经手费(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.EXCHFEE,0) * NVL(T11.EN_BID_PRICE,0),2)               --经手费(原币)*买入价
       END                                                                           AS EXCHFEE_LC                              --经手费(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  --02-买入，54-申购
           ROUND(NVL(T1.TRFE,0) * NVL(T11.EN_ASK_PRICE,0),2)                  --过户费(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.TRFE,0) * NVL(T11.EN_BID_PRICE,0),2)                  --过户费(原币)*买入价
       END                                                                           AS TRFE_LC                                 --过户费(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  --02-买入，54-申购
           ROUND(NVL(T1.SFEE,0) * NVL(T11.EN_ASK_PRICE,0),2)                  --证管费(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.SFEE,0) * NVL(T11.EN_BID_PRICE,0),2)                  --证管费(原币)*买入价
       END                                                                           AS SFEE_LC                                 --证管费(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  --02-买入，54-申购
           ROUND(NVL(T1.TRAN_FEE,0) * NVL(T11.EN_ASK_PRICE,0),2)              --交易费(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.TRAN_FEE,0) * NVL(T11.EN_BID_PRICE,0),2)              --交易费(原币)*买入价
       END                                                                           AS TRAN_FEE_LC                             --交易费(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  --02-买入，54-申购
           ROUND(NVL(T1.SETL_FEE,0) * NVL(T11.EN_ASK_PRICE,0),2)              --结算费(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.SETL_FEE,0) * NVL(T11.EN_BID_PRICE,0),2)              --结算费(原币)*买入价
       END                                                                           AS SETL_FEE_LC                             --结算费(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  --02-买入，54-申购
           ROUND(NVL(T1.FARE,0) * NVL(T11.EN_ASK_PRICE,0),2)                  --佣金(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.FARE,0) * NVL(T11.EN_BID_PRICE,0),2)                  --佣金(原币)*买入价
       END                                                                           AS FARE_LC                                 --佣金(本币)
     , CASE 
         WHEN T1.ENTU_ORNT_CODE IN ('02','54') THEN  --02-买入，54-申购
           ROUND(NVL(T1.OTH_FEE,0) * NVL(T11.EN_ASK_PRICE,0),2)               --其它费用(原币)*卖出价
         ELSE 
           ROUND(NVL(T1.OTH_FEE,0) * NVL(T11.EN_BID_PRICE,0),2)               --其它费用(原币)*买入价
       END                                                                           AS OTHER_FEE_LC                            --其它费用(本币)
     , T1.EXCH_DEAL_TIME                                                             AS DEAL_TIME                               --成交时间
     , 'DWD_TRAN_REAL_DEAL_JOUR_PTD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
  FROM DWDXDAY.DWD_TRAN_REAL_DEAL_JOUR_PTD            T1  --O32实时成交流水表
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
    ON T7.STD_DICT_CLS_CD = 'ISTCT_BUSIN_TYPES_CODE'  --指令业务分类代码
   AND T7.STD_DICT_CLS_CDVAL = T1.BUSIN_CATG_CODE
   AND T7.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T8 --标准字典分类枚举信息
    ON T8.STD_DICT_CLS_CD = 'ENTR_ORIENTATION_CODE'  --委托方向
   AND T8.STD_DICT_CLS_CDVAL = T1.ENTU_ORNT_CODE
   AND T8.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD  T9 --O32指令证券明细表
    ON T1.ISTCT_SERIALNO = T9.ISTCT_SERIALNO
   AND T1.ISTCT_MODIFY_SERIALNO = T9.ISTCT_MODIFY_SERIALNO
   AND T1.SCR_INCD = T9.SCR_INCD
   AND T9.RISK_INFLU_FLAG_CODE = '0' --0正常
   AND T9.P_DT BETWEEN  '${p_start_dt}'   AND '${end_date}'
   AND T1.P_DT = T9.P_DT
  LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD T10 --交易对手方编码映射
    ON T1.CNTP_NUM = T10.CNTP_NUM
   AND T10.ST_DATE <= '${p_end_dt}'
   AND T10.END_DATE >= '${p_end_dt}'
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN ODS_XDAY_O32.ODS_O32_TCURRENCYRATE_PFD T11 --O32汇率表
    ON (CASE 
          WHEN T1.CRRC_CODE = 'HKD' THEN --港币
            'HK1'
          WHEN T1.CRRC_CODE = 'HKS' THEN --港币(深港通)
            'HK2'
          ELSE 
            T1.CRRC_CODE
        END) = T11.VC_CURRENCY_SOURCE
   AND T11.VC_CURRENCY_TARGET = 'CNY'
   AND T11.L_SET_NO = 0 --汇率套号
   AND T11.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T13 --标准字典分类枚举信息
    ON T13.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T13.STD_DICT_CLS_CDVAL = T1.TRAN_MKT_CODE
   AND T13.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T14 --标准字典分类枚举信息
    ON T14.STD_DICT_ID = 'DIC0000014'
   AND T14.STD_DICT_CLS_CDVAL = T1.INV_TYPE_CODE
   AND T14.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T15 --标准字典分类枚举信息
    ON T15.STD_DICT_ID = 'DIC0000061'
   AND T15.STD_DICT_CLS_CDVAL = T9.LIQUI_VELOCITY_CODE
   AND T15.VALID_FLAG = '1' --有效标志
WHERE T1.P_DT BETWEEN  '${p_start_dt}'   AND '${end_date}'
  AND T1.ENTU_ORNT_CODE IN ('02','03','54')               --02 买入 03 卖出 54 申购
  AND T6.SCR_PRI_CATG_CODE = '06'                         --股票资产
  AND T1.VALID_STAT_CODE = '01'                           --有效状态代码为 01-有效
;

INSERT INTO TABLE DWSXDAY.DWS_TRAN_STK_TRAN_DETAIL_PTD PARTITION(P_DT='${p_end_dt}')
SELECT 
       T1.BUSIN_DATE                                                                 AS TRAN_DATE                               --交易日期
     , T1.CNFM_NO                                                                    AS DEAL_SERIALNO                           --成交序号
     , T1.CNFM_NO                                                                    AS DEAL_NO                                 --成交编号
     , T1.ISTCT_SERIALNO                                                             AS ISTCT_SERIALNO                          --指令序号
     , T1.ISTCT_MODIFY_SERIALNO                                                      AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
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
     , T1.HOLDER_CODE                                                                AS HOLDER_CODE                             --股东代码
     , T1.REP_SEAT                                                                   AS TRAN_SEAT                               --交易席位
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
     , 'CNY'                                                                         AS CRRC_CODE                               --币种代码
     , T1.CNTP_NUM                                                                   AS CNTP_NUM                                --交易对手编码
     , T10.CNTP_NAME                                                                 AS CNTP_NAME                               --交易对手名称
     , NVL(T1.QTY,0)                                                                 AS DEAL_QTY                                --成交数量
     , NVL(T1.PRC,0)                                                                 AS DEAL_PRC_CRRC                           --成交价格(原币)
     , NVL(T1.AMT,0)                                                                 AS DEAL_AMT_ORI_CRRC                       --成交金额(原币)
     , 0                                                                             AS STMP_ORI_CRRC                           --印花税(原币)
     , 0                                                                             AS EXCHFEE_ORI_CRRC                        --经手费(原币)
     , 0                                                                             AS TRFE_ORI_CRRC                           --过户费(原币)
     , 0                                                                             AS SFEE_ORI_CRRC                           --证管费(原币)
     , 0                                                                             AS TRAN_FEE_ORI_CRRC                       --交易费(原币)
     , 0                                                                             AS SETL_FEE_ORI_CRRC                       --结算费(原币)
     , NVL(T1.FARE,0)                                                                AS FARE_ORI_CRRC                           --佣金(原币)
     , 0                                                                             AS OTHER_FEE_ORI_CRRC                      --其它费用(原币)
     , NVL(T1.PRC,0)                                                                 AS DEAL_PRC_LC                             --成交价格(本币)
     , NVL(T1.AMT,0)                                                                 AS DEAL_AMT_LC                             --成交金额(本币)
     , 0                                                                             AS STMP_LC                                 --印花税(本币)
     , 0                                                                             AS EXCHFEE_LC                              --经手费(本币)
     , 0                                                                             AS TRFE_LC                                 --过户费(本币)
     , 0                                                                             AS SFEE_LC                                 --证管费(本币)
     , NVL(T1.FEE,0)                                                                 AS TRAN_FEE_LC                             --交易费(本币)
     , 0                                                                             AS SETL_FEE_LC                             --结算费(本币)
     , NVL(T1.FARE,0)                                                                AS FARE_LC                                 --佣金(本币)
     , 0                                                                             AS OTHER_FEE_LC                            --其它费用(本币)
     , T1.CNFM_TIME                                                                  AS DEAL_TIME                               --成交时间
     , 'DWD_TRAN_OTC_BUSIN_CNFM_PTD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
  FROM DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD            T1  --O32场外业务确认表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T2 --账套产品基本信息
    ON T1.SFAC_NUM = T2.SFAC_NUM
   AND T2.VALID_FLAG = '1'
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
  LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD T10 --交易对手方编码映射
    ON T1.CNTP_NUM = T10.CNTP_NUM
   AND T10.ST_DATE <= '${p_end_dt}'
   AND T10.END_DATE >= '${p_end_dt}'
   AND T10.VALID_FLAG = '1'--有效标志
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
WHERE T1.P_DT BETWEEN  '${p_start_dt}'   AND '${end_date}'
  AND T1.ENTU_ORNT_CODE = '54'                         --54 申购
  AND T1.BUSIN_PROCE_CATG_CODE = '03'                  --业务过程分类代码 03 成交确认
  AND T6.SCR_PRI_CATG_CODE = '06'                      --06 股票资产
  AND T1.STAT_CODE = '01'                              --状态代码为 01-正常
;

"