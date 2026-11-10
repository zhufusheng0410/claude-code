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
-- ** 描述:包含：
-- **      竞价平台普通业务，包括股票/基金/期货/债券买卖，质押式回购（含提交转换质押券）、个股期权组合保证金、债券认购、ETF申赎
-- **      大宗交易平台普通业务，包括股票/基金/债券买卖、质押式回购
-- **      上海固定收益平台业务，包括债券买卖
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-17
-- ** 修改日志:
-- ** 2023-05-17，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_REAL_DEAL_JOUR_PTD  实时成交流水表
-- ** 源  表：ODS_XDAY_O32.ODS_O32_TREALDEAL_PTD   实时成交流水表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD   账套编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP   标准码值字典映射表
-- **         DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD     证券编码映射
-- **         DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD    交易对手方编码映射
-- **         DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD   证券基本信息
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
    set mapreduce.job.reduces=5;

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_REAL_DEAL_JOUR_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT
       T1.L_DATE                                                                       AS DEAL_DATE                               --成交日期
     , T1.L_REALDEAL_SERIAL_NO                                                         AS DEAL_SERIALNO                           --成交序号
     , T1.L_DAILY_INSTRUCTION_NO                                                       AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                         AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T1.L_ENTRUST_SERIAL_NO                                                          AS ENTU_SERIALNO                           --委托序号
     , T2.SFAC_NUM                                                                     AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                    AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                               AS PORTF_SERIALNO                          --投资组合序号
     , CASE 
         WHEN T1.C_MARKET_NO IS NOT NULL THEN
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO))
       END                                                                             AS TRAN_MKT_CODE                           --交易市场代码
     , T1.VC_STOCKHOLDER_ID                                                            AS HOLDER_CODE                             --股东代码
     , T1.VC_REPORT_SEAT                                                               AS REP_SEAT                                --申报席位
     , T1.L_REPORT_SERIAL_NO                                                           AS REP_NO                                  --申报编号
     , T3.SCR_NUM                                                                      AS SCR_NUM                                 --证券编码
     , T13.SYMBOL                                                                      AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                                AS SCR_INCD                                --证券内码
     , CASE 
         WHEN T1.C_STOCK_TYPE IS NOT NULL THEN
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STOCK_TYPE))
       END                                                                             AS SCR_CATG_CODE                           --证券类别代码
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS))
       END                                                                             AS BUSIN_CATG_CODE                         --业务分类代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION))
       END                                                                             AS ENTU_ORNT_CODE                          --委托方向代码
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE))
       END                                                                             AS INV_TYPE_CODE                           --投资类型代码
     , CASE 
         WHEN T1.C_CLOSE_TYPE IS NOT NULL AND LENGTH(T1.C_CLOSE_TYPE) <> 0 THEN
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CLOSE_TYPE))
       END                                                                             AS COVR_TYPE_CODE                          --平仓类型代码
     , CASE 
         WHEN T1.C_VALID IS NOT NULL THEN
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_VALID))
       END                                                                             AS VALID_STAT_CODE                         --有效状态代码
     , T13.TRAN_CRRC_CODE                                                              AS CRRC_CODE                               --币种代码
     , T1.L_SETTLE_DATE                                                                AS DELI_DATE                               --交割日期
     , T1.L_MARKET_DATE                                                                AS MKT_DEAL_DATE                           --市场成交日期
     , T1.L_BUSINESS_TIME                                                              AS EXCH_DEAL_TIME                          --交易所成交时间
     , T1.VC_DEAL_NO                                                                   AS DEAL_NO                                 --成交编号
     , T1.L_DEAL_AMOUNT                                                                AS DEAL_VOL                                --成交数量
     , T1.EN_DEAL_PRICE                                                                AS DEAL_PRC                                --成交价格
     , T1.EN_FEE_JY                                                                    AS TRAN_FEE                                --交易费
     , T1.EN_FEE_YH                                                                    AS STMP                                    --印花税
     , T1.EN_FEE_GH                                                                    AS TRFE                                    --过户费
     , T1.EN_FEE_YJ                                                                    AS FARE                                    --佣金
     , T1.EN_FEE_JS                                                                    AS EXCHFEE                                 --经手费
     , T1.EN_FEE_ZG                                                                    AS SFEE                                    --证管费
     , T1.EN_FEE_QT                                                                    AS OTH_FEE                                 --其他费用
     , T1.EN_FEE_JS2                                                                   AS SETL_FEE                                --结算费
     , T1.EN_FEE_JG                                                                    AS DELIFEE                                 --交割费
     , T1.EN_FEE_JY_TRUE                                                               AS ACTL_TRAN_FEE                           --实际交易费
     , T1.EN_FEE_YJ_TRUE                                                               AS ACTL_FARE                               --实际佣金
     , T1.EN_FEE_GH_TOTAL                                                              AS FULL_AMT_TRFE                           --全额过户费
     , T1.EN_BALANCE                                                                   AS DEAL_AMT                                --成交金额
     , T1.L_HG_DAYS                                                                    AS REPO_DAYS                               --回购天数
     , T1.L_ORIGIN_OPEN_DATE                                                           AS ORI_OPEP_DATE                           --原开仓日期
     , T1.VC_ORIGIN_DEAL_NO                                                            AS ORI_DEAL_NO                             --原成交编号
     , T1.C_SPECIAL_FLAG                                                               AS SPC_BUSIN_ID                            --特殊业务标识
     , T1.L_OPERATOR_NO                                                                AS OPER_CODE                               --操作员代码
     , T12.CNTP_NUM                                                                    AS CNTP_NUM                                --交易对手编码
     , CASE 
         WHEN T1.C_SOURCE IS NOT NULL THEN
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SOURCE))
       END                                                                             AS DATA_SRC_CODE                           --数据来源代码
     , 'O32'                                                                           AS SSYS                                    --源系统
     , 'ODS_O32_TREALDEAL_PTD'                                                         AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TREALDEAL_PTD T1  --实时成交流水表
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
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'O32'
   AND T4.SRC_DICT_CLS_CD = 'C_MARKET_NO'
   AND T1.C_MARKET_NO = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'O32'
   AND T5.SRC_DICT_CLS_CD = 'C_STOCK_TYPE'
   AND T1.C_STOCK_TYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'O32'
   AND T6.SRC_DICT_CLS_CD = 'C_BUSIN_CLASS'
   AND T1.C_BUSIN_CLASS = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'O32'
   AND T7.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'
   AND T1.C_ENTRUST_DIRECTION  = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'O32'
   AND T8.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'
   AND T1.C_INVEST_TYPE = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
    ON T9.SSYS = 'O32'
   AND T9.SRC_DICT_CLS_CD = 'C_CLOSE_TYPE'
   AND T1.C_CLOSE_TYPE = T9.SRC_DICT_CLS_CDVAL
   AND T9.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准字典码值映射
    ON T10.SSYS = 'O32'
   AND T10.SRC_DICT_CLS_CD = 'C_VALID'
   AND T1.C_VALID = T10.SRC_DICT_CLS_CDVAL
   AND T10.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准字典码值映射
    ON T11.SSYS = 'O32'
   AND T11.SRC_DICT_CLS_CD = 'C_DEAL_DATA_SOURCE'
   AND T1.C_SOURCE = T11.SRC_DICT_CLS_CDVAL
   AND T11.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD T12 --交易对手方编码映射
    ON T1.L_TRADE_RIVAL_NO = T12.CNTP_NO
   AND T12.SSYS = 'O32'--源系统
   AND T12.ST_DATE <= '${p_end_dt}'--开始日期
   AND T12.END_DATE >= '${p_end_dt}'--结束日期
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T13 --证券基本信息
    ON T3.SCR_NUM = T13.SCR_NUM --证券编码
   AND T13.VALID_FLAG = '1' 
   AND T13.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;"
