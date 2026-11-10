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
-- ** 描    述:证券资金流水表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_SCR_CPTL_JOUR_PTD     证券资金流水表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TCURRENTS_PTD     证券资金流水表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD     账套编码映射
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD       证券编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP     标准码值字典映射表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD     证券基本信息
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


INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_SCR_CPTL_JOUR_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS OCCUR_DATE                              --发生日期
     , T1.L_BUSIN_NO                                                                 AS BUSIN_SERIALNO                          --业务序号
     , T1.VC_DEAL_NO                                                                 AS DEAL_NO                                 --成交编号
     , T1.L_SERIAL_NO                                                                AS JOUR_SERIALNO                           --流水序号
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_ASSET_ID                                                                 AS AST_UNIT_SERIALNO                       --资产单元序号
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T4.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T1.VC_STOCKHOLDER_ID                                                          AS HOLDER_CODE                             --股东代码
     , T1.VC_SEAT_ID                                                                 AS SEAT_CODE                               --席位代码
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS)) 
       END                                                                           AS BUSIN_CATG_CODE                         --业务分类代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION)) 
       END                                                                           AS ENTU_ORNT_CODE                          --委托方向代码
     , T1.L_BUSIN_FLAG                                                               AS ENTU_ORNT_SUBCLAS                       --委托方向细类
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE)) 
       END                                                                           AS INV_TYPE_CODE                           --投资类型代码
     , CASE 
         WHEN T1.L_SETTLE_SPEED IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_SETTLE_SPEED)) 
       END                                                                           AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , T1.C_DELIVER_STATUS                                                           AS DELI_STAT_CODE                          --交割状态代码
     , CASE 
         WHEN T1.VC_BUSIN_OPFLAG IS NOT NULL THEN 
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_BUSIN_OPFLAG)) 
       END                                                                           AS BUSIN_OPER_TYPE_CODE                    --业务操作类型代码
     , CASE 
         WHEN T1.C_STOCK_TYPE IS NOT NULL THEN 
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STOCK_TYPE)) 
       END                                                                           AS SCR_CATG_CODE                           --证券类型代码
     , CASE 
         WHEN T1.C_POSITION_FLAG = '1' THEN 
           '1'
         ELSE
           '0'
        END                                                                          AS LPOS_HLDP_FLAG                          --多头持仓标志
     , CASE 
         WHEN T1.C_CLOSE_TYPE IS NOT NULL THEN 
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CLOSE_TYPE)) 
       END                                                                           AS COVR_TYPE_CODE                          --平仓类型代码
     , CASE 
         WHEN T1.C_DEAL_TYPE IS NOT NULL THEN 
          COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEAL_TYPE)) 
       END                                                                           AS DEAL_TYPE_CODE                          --处理类型代码
     , T1.C_REPEAT_SETTLE                                                            AS RPEAT_LIQUI_FLAG                        --重复清算标志
     , CASE 
         WHEN T1.C_STATUS IS NOT NULL THEN 
          COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS)) 
       END                                                                           AS STAT_CODE                               --状态代码
     , CASE 
         WHEN T1.VC_CURRENCY_NO IS NOT NULL THEN 
          COALESCE(T15.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PRODUCE_MARK)) 
       END                                                                           AS CRRC_CODE                               --币种代码
     , T1.L_BUSIN_TIME1                                                              AS FST_DEAL_TIME                           --首成交时间
     , T1.L_BUSIN_TIME2                                                              AS END_DEAL_TIME                           --末成交时间
     , T1.EN_OCCUR_BALANCE                                                           AS CPTL_OCCUR                              --资金发生额
     , T1.EN_POST_BALANCE                                                            AS OCCUR_BACK_CPTL_BAL                     --发生后资金余额
     , T1.L_ENTRUST_AMOUNT                                                           AS ENTU_QTY                                --委托数量
     , T1.L_BUSIN_AMOUNT                                                             AS DEAL_QTY                                --成交数量
     , T1.EN_ENTRUST_PRICE                                                           AS DEAL_PRC                                --成交价
     , T1.EN_DEAL_BALANCE                                                            AS DEAL_AMT                                --成交金额
     , T1.EN_FARE1                                                                   AS TRAN_FEE                                --交易费
     , T1.EN_FARE2                                                                   AS STMP                                    --印花税
     , T1.EN_FARE3                                                                   AS TRFE                                    --过户费
     , T1.EN_FARE4                                                                   AS FARE                                    --佣金
     , T1.EN_FARE5                                                                   AS EXCHFEE                                 --经手费
     , T1.EN_FARE6                                                                   AS SFEE                                    --证管费
     , T1.EN_FARE7                                                                   AS OTHER_FEE                               --其它费
     , T1.EN_FEE_JS2                                                                 AS SETL_FEE                                --结算费
     , T1.EN_FEE_JG                                                                  AS DELIFEE                                 --交割费
     , T1.EN_FEE_JY_TRUE                                                             AS ACTL_TRAN_FEE                           --实际交易费
     , T1.EN_FEE_YJ_TRUE                                                             AS ACTL_FARE                               --实际佣金
     , T1.EN_FEE_GH_TOTAL                                                            AS FULL_AMT_TRFE                           --全额过户费
     , T1.EN_RISK_FUND                                                               AS SETL_RISK_FUND                          --结算风险基金
     , T1.L_SUBJECT_NO                                                               AS CRSE_NO                                 --科目编号
     , T1.EN_SUBJECT_BALANCE                                                         AS CRSE_OCCUR                              --科目发生额
     , T1.EN_SUBJECT_POST_BALANCE                                                    AS CRSE_OCCUR_BACK_BAL                     --科目发生后余额
     , T1.L_TRADE_DATE                                                               AS TA_CNFM_DATE                            --TA确认日期
     , T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , T1.L_CHECK_OPERATOR                                                           AS CHKR_CODE                               --复核人代码
     , T1.VC_SUMMARY                                                                 AS MEMO                                    --备注
     , CASE 
         WHEN T1.C_PRODUCE_MARK IS NOT NULL THEN 
          COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PRODUCE_MARK)) 
       END                                                                           AS DATA_SRC_CODE                           --数据来源代码
     , T1.L_TIME                                                                     AS OCCUR_TIME                              --发生时间
     , T1.T_TIMESTAMP                                                                AS TIME_STAMP                              --时间戳
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TCURRENTS_PTD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TCURRENTS_PTD T1  --证券资金流水表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD --产品内码
   AND T2.SSYS = 'O32' --源系统
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD --证券内码
   AND T3.SSYS = 'O32' --源系统
   AND T3.ST_DATE <= '${p_end_dt}' --开始日期
   AND T3.END_DATE >= '${p_end_dt}' --结束日期
   AND T3.VALID_FLAG = '1' --有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T4 --证券基本信息
    ON T3.SCR_NUM = T4.SCR_NUM
   AND T4.VALID_FLAG = '1' --有效标志
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_BUSIN_CLASS = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T5.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_BUSIN_CLASS' --源字典分类
   AND T5.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_ENTRUST_DIRECTION  = T6.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T6.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION' --源字典分类
   AND T6.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T7.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T7.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_INVEST_TYPE' --源字典分类
   AND T7.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.L_SETTLE_SPEED = T8.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T8.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'L_SETTLE_SPEED' --源字典分类
   AND T8.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.VC_BUSIN_OPFLAG = T9.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T9.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T9.SRC_DICT_CLS_CD = 'VC_STK_BUSIN_OPFLAG' --源字典分类
   AND T9.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.C_STOCK_TYPE = T10.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T10.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T10.SRC_DICT_CLS_CD = 'C_STOCK_TYPE' --源字典分类
   AND T10.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T1.C_CLOSE_TYPE = T11.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T11.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T11.SRC_DICT_CLS_CD = 'C_CLOSE_TYPE' --源字典分类
   AND T11.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准码值字典映射表
    ON T1.C_DEAL_TYPE = T12.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T12.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T12.SRC_DICT_CLS_CD = 'C_DEAL_TYPE' --源字典分类
   AND T12.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准码值字典映射表
    ON T1.C_STATUS = T13.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T13.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T13.SRC_DICT_CLS_CD = 'C_SCR_FUND_STATUS' --源字典分类
   AND T13.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准码值字典映射表
    ON T1.C_PRODUCE_MARK = T14.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T14.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T14.SRC_DICT_CLS_CD = 'C_PRODUCE_MARK' --源字典分类
   AND T14.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T15 --标准码值字典映射表
    ON T1.VC_CURRENCY_NO = T15.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T15.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T15.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
   AND T15.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'

;

"
