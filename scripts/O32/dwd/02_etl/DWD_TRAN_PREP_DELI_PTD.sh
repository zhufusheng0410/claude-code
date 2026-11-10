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
-- ** 描    述:待交割表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_PREP_DELI_PTD       待交割表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TPENDSETTLE_PTD 待交割表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD   账套编码映射
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD     证券编码映射
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD   证券基本信息
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP   标准码值字典映射表
-- **           DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD    交易对手方编码映射
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
    set mapreduce.job.reduces=3;

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_PREP_DELI_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_SERIAL_NO                                                                AS PREP_DELI_SERIALNO                      --待交割序号
     , T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_ENTRUST_SERIAL_NO                                                        AS ENTU_SERIALNO                           --委托序号
     , T1.VC_ORIGINAL_NO                                                             AS ORI_BUSIN_NO                            --原业务编号
     , T1.VC_CONFIRM_NO                                                              AS OTC_CNFM_NO                             --场外确认编号
     , T1.VC_DEAL_NO                                                                 AS DEAL_NO                                 --成交编号
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T4.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T4.SCR_SCD_CATG_CODE                                                          AS SCR_CATG_CODE                           --证券类别代码
     , CASE 
         WHEN T1.C_MARKET_NO IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO)) 
       END                                                                           AS MKT_CODE                                --市场代码
     , T1.VC_STOCKHOLDER_ID                                                          AS HOLDER_CODE                             --股东代码
     , T1.VC_BIND_SEAT                                                               AS SEAT_CODE                               --席位代码
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS)) 
       END                                                                           AS BUSIN_CATG_CODE                         --业务分类代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION)) 
       END                                                                           AS ENTU_ORNT_CODE                          --委托方向代码
     , T1.L_BUSIN_FLAG                                                               AS ENTU_ORNT_SUBCLAS                       --委托方向细类
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE)) 
       END                                                                           AS INV_TYPE_CODE                           --投资类型代码
     , CASE 
         WHEN T1.C_CLEAR_SPEED IS NOT NULL THEN 
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CLEAR_SPEED)) 
       END                                                                           AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , CASE 
         WHEN T1.C_CLEAR_TYPE IS NOT NULL THEN 
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CLEAR_TYPE)) 
       END                                                                           AS LIQUI_TYPE_CODE                         --清算类型代码
     , CASE 
         WHEN T1.C_SETTLE_TYPE IS NOT NULL THEN 
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SETTLE_TYPE)) 
       END                                                                           AS SETL_MODE_CODE                          --结算方式代码
     , CASE 
         WHEN T1.VC_CURRENCY_NO IS NOT NULL THEN 
          COALESCE(T24.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SETTLE_TYPE)) 
       END                                                                           AS SETL_CRRC_CODE                          --结算币种代码
     , CASE 
         WHEN T1.C_BUSIN_PRO_TYPE IS NOT NULL THEN 
          COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_PRO_TYPE)) 
       END                                                                           AS OTC_BUSIN_PROCE_CATG_CODE               --场外业务过程分类代码
     , CASE 
         WHEN T1.C_STOCK_DIRECTION IS NOT NULL THEN 
          COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STOCK_DIRECTION)) 
       END                                                                           AS SCR_CHG_ORNT_CODE                       --证券变化方向代码
     , CASE 
         WHEN T1.C_STOCKSETTLE_FLAG IS NOT NULL THEN 
          COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STOCKSETTLE_FLAG)) 
       END                                                                           AS SCR_DELIV_STAT_CODE                     --证券交收状态代码
     , T1.C_STOCK_ENABLE_CHANGE_FLAG                                                 AS SCR_USE_DEAL_FLAG                       --证券可用处理标志
     , T1.L_STOCK_ENABLE_CHANGE_DATE                                                 AS SCR_USE_DATE                            --证券可用日期
     , CASE 
         WHEN T1.C_DEAL_STOCK_FROZEN_TYPE IS NOT NULL THEN 
          COALESCE(T15.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEAL_STOCK_FROZEN_TYPE)) 
       END                                                                           AS DEAL_SCR_FRZ_DEAL_MODE_CODE             --成交时的证券冻结处理方式代码
     , CASE 
         WHEN T1.C_SETTLE_STOCK_FROZEN_TYPE IS NOT NULL THEN 
          COALESCE(T16.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SETTLE_STOCK_FROZEN_TYPE)) 
       END                                                                           AS AST_DEAL_SCR_FRZ_DEAL_MODE_CODE         --资产处理时的证券冻结处理方式代码
     , CASE 
         WHEN T1.C_CASH_DIRECTION IS NOT NULL THEN 
          COALESCE(T17.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CASH_DIRECTION)) 
       END                                                                           AS CPTL_CHG_ORNT_CODE                      --资金变化方向代码
     , T1.C_CASH_ENABLE_CHANGE_FLAG                                                  AS CPTL_USE_DEAL_FLAG                      --资金可用处理标志
     , CASE 
         WHEN T1.C_CASHSETTLE_FLAG IS NOT NULL THEN 
          COALESCE(T18.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CASHSETTLE_FLAG)) 
       END                                                                           AS CPTL_DELIV_STAT_CODE                    --资金交收状态代码
     , CASE 
         WHEN T1.C_DEAL_CASH_FROZEN_TYPE IS NOT NULL THEN 
          COALESCE(T19.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEAL_CASH_FROZEN_TYPE)) 
       END                                                                           AS DEAL_CPTL_FRZ_DEAL_MODE_CODE            --成交时的资金冻结处理方式代码
     , CASE 
         WHEN T1.C_SETTLE_CASH_FROZEN_TYPE IS NOT NULL THEN 
          COALESCE(T20.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SETTLE_CASH_FROZEN_TYPE)) 
       END                                                                           AS AST_DEAL_CPTL_FRZ_DEAL_MODE_CODE        --资产处理时的资金冻结处理方式代码
     , T1.L_CASH_ENABLE_CHANGE_DATE                                                  AS CPTL_USE_DATE                           --资金可用日期
     , CASE 
         WHEN T1.C_ASSET_SETTLE_POINT IS NOT NULL THEN 
          COALESCE(T21.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ASSET_SETTLE_POINT)) 
       END                                                                           AS AST_DEAL_TIME_POI_CODE                  --资产处理时点代码
     , T1.C_ASSET_SETTLE_FLAG                                                        AS AST_DEAL_FLAG                           --资产处理标志
     , T1.L_ASSET_SETTLE_DATE                                                        AS AST_DEAL_DATE                           --资产处理日期
     , CASE 
         WHEN T1.C_ENABLE_CHANGE_POINT IS NOT NULL THEN 
          COALESCE(T22.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENABLE_CHANGE_POINT)) 
       END                                                                           AS ADD_PART_USE_CHG_TIME_POI_CODE          --增加部分的可用变化时点代码
     , T1.L_TRADE_DATE                                                               AS TRAN_DATE                               --交易日期
     , T1.L_SETTLE_DATE                                                              AS DELI_DATE                               --交割日期
     , T1.EN_PRICE                                                                   AS DEAL_PRC                                --成交价
     , T1.L_SETTLE_AMOUNT                                                            AS DELI_QTY                                --交割数量
     , T1.EN_SETTLE_BALANCE                                                          AS DELI_AMT                                --交割金额
     , T1.EN_NET_BALANCE                                                             AS NETPRC_AMT                              --净价金额
     , T1.EN_FULL_BALANCE                                                            AS FULL_PRC_AMT                            --全价金额
     , T1.EN_FEE_TOTAL                                                               AS TOT_FEE                                 --总费用
     , T1.EN_FEE_JY                                                                  AS TRAN_FEE                                --交易费
     , T1.EN_FEE_YH                                                                  AS STMP                                    --印花税
     , T1.EN_FEE_GH                                                                  AS TRFE                                    --过户费
     , T1.EN_FEE_YJ                                                                  AS FARE_FEE                                --佣金费
     , T1.EN_FEE_JS                                                                  AS EXCHFEE                                 --经手费
     , T1.EN_FEE_ZG                                                                  AS SFEE                                    --证管费
     , T1.EN_FEE_JS2                                                                 AS SETL_FEE                                --结算费
     , T1.EN_FEE_JG                                                                  AS DELIFEE                                 --交割费
     , T1.EN_FEE_OTHER                                                               AS OTH_FEE                                 --其他费用
     , T1.C_STATUS                                                                   AS STAT_CODE                               --状态代码
     , T1.EN_FEE_GH_TOTAL                                                            AS FULL_AMT_TRFE                           --全额过户费
     , T1.EN_FEE_JY_TRUE                                                             AS ACTL_TRAN_FEE                           --实际交易费
     , T1.EN_FEE_YJ_TRUE                                                             AS ACTL_FARE                               --实际佣金
     , T1.EN_HG_INTEREST                                                             AS REPO_INTR                               --回购利息
     , T1.EN_RISK_FUND                                                               AS SETL_RISK_FUND                          --结算风险基金
     , T1.L_RELATE_NO                                                                AS RELA_PREP_DELI_SERIALNO                 --关联待交割序号
     , T23.CNTP_NUM                                                                  AS CNTP_NUM                                --交易对手编码
     , T1.C_TRUSTEE                                                                  AS CUSTOD                                  --托管机构
     , T1.C_SQS_INSTR_STATUS                                                         AS SHCH_SETL_ISTCT_STAT                    --上清所结算指令状态
     , T1.C_SQS_CONTRACT_STATUS                                                      AS SHCH_SETL_AGMT_STAT                     --上清所结算合同状态
     , T1.C_ZZD_INSTR_STATUS                                                         AS CNBD_SETL_ISTCT_STAT                    --中债登结算指令状态
     , T1.C_ZZD_CONTRACT_STATUS                                                      AS CNBD_SETL_AGMT_STAT                     --中债登结算合同状态
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TPENDSETTLE_PTD'                                                     AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TPENDSETTLE_PTD T1  --待交割表
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
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T4 --证券基本信息
    ON T3.SCR_NUM = T4.SCR_NUM
   AND T4.VALID_FLAG = '1'--有效标志
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_MARKET_NO = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_MARKET_NO'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_BUSIN_CLASS  = T6.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T6.SSYS= 'O32'  --源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD= 'C_BUSIN_CLASS'  --源字典分类
   AND T6.VALID_FLAG='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_ENTRUST_DIRECTION  = T7.SRC_DICT_CLS_CDVAL   --源字典分类码值
   AND T7.SSYS= 'O32'  --源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD= 'C_ENTRUST_DIRECTION'  --源字典分类
   AND T7.VALID_FLAG='1'   --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'C_INVEST_TYPE'--源字典分类
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_CLEAR_SPEED = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T9.SRC_DICT_CLS_CD = 'C_CLEAR_SPEED'--源字典分类
   AND T9.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.C_CLEAR_TYPE = T10.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T10.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T10.SRC_DICT_CLS_CD = 'C_CLEAR_TYPE'--源字典分类
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T1.C_SETTLE_TYPE = T11.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T11.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T11.SRC_DICT_CLS_CD = 'C_OTC_SETTLE_TYPE'--源字典分类
   AND T11.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准码值字典映射表
    ON T1.C_BUSIN_PRO_TYPE = T12.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T12.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T12.SRC_DICT_CLS_CD = 'C_OTC_BUSIN_PRO_TYPE'--源字典分类
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准码值字典映射表
    ON T1.C_STOCK_DIRECTION  = T13.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T13.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T13.SRC_DICT_CLS_CD = 'C_STOCK_DIRECTION'--源字典分类
   AND T13.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准码值字典映射表
    ON T1.C_STOCKSETTLE_FLAG = T14.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T14.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T14.SRC_DICT_CLS_CD = 'C_STOCKSETTLE_FLAG'--源字典分类
   AND T14.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T15 --标准码值字典映射表
    ON T1.C_DEAL_STOCK_FROZEN_TYPE = T15.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T15.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T15.SRC_DICT_CLS_CD = 'C_DEAL_STOCK_FROZEN_TYPE'--源字典分类
   AND T15.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T16 --标准码值字典映射表
    ON T1.C_SETTLE_STOCK_FROZEN_TYPE = T16.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T16.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T16.SRC_DICT_CLS_CD = 'C_SETTLE_STOCK_FROZEN_TYPE'--源字典分类
   AND T16.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T17 --标准码值字典映射表
    ON T1.C_CASH_DIRECTION = T17.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T17.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T17.SRC_DICT_CLS_CD = 'C_CASH_DIRECTION'--源字典分类
   AND T17.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T18 --标准码值字典映射表
    ON T1.C_CASHSETTLE_FLAG = T18.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T18.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T18.SRC_DICT_CLS_CD = 'C_CASHSETTLE_FLAG'--源字典分类
   AND T18.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T19 --标准码值字典映射表
    ON T1.C_DEAL_CASH_FROZEN_TYPE = T19.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T19.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T19.SRC_DICT_CLS_CD = 'C_DEAL_CASH_FROZEN_TYPE'--源字典分类
   AND T19.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T20 --标准码值字典映射表
    ON T1.C_SETTLE_CASH_FROZEN_TYPE = T20.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T20.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T20.SRC_DICT_CLS_CD = 'C_SETTLE_CASH_FROZEN_TYPE'--源字典分类
   AND T20.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T21 --标准码值字典映射表
    ON T1.C_ASSET_SETTLE_POINT = T21.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T21.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T21.SRC_DICT_CLS_CD = 'C_ASSET_SETTLE_POINT'--源字典分类
   AND T21.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T22 --标准码值字典映射表
    ON T1.C_ENABLE_CHANGE_POINT = T22.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T22.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T22.SRC_DICT_CLS_CD = 'C_ENABLE_CHANGE_POINT'--源字典分类
   AND T22.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD T23 --交易对手方编码映射
    ON T1.L_TRADE_RIVAL_NO = T23.CNTP_NO
   AND T23.SSYS = 'O32'--源系统
   AND T23.ST_DATE <= '${p_end_dt}'--开始日期
   AND T23.END_DATE >= '${p_end_dt}'--结束日期
   AND T23.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T24 --标准码值字典映射表
    ON T1.VC_CURRENCY_NO = T24.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T24.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T24.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
   AND T24.VALID_FLAG = '1' --有效标志
WHERE (T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
  OR T1.P_DT='29991231'
 )
;

"
