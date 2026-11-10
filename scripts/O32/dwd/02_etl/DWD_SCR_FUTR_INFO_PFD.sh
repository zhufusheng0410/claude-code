#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:资讯
-- ** 描    述:期货信息表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_SCR_FUTR_INFO_PFD         期货信息表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TFUTURESINFO_PFD 期货信息表
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD      证券编码映射
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD    证券基本信息
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP    标准码值字典映射表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_FUTR_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T3.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T3.SCR_SNAME                                                                  AS SCR_NAME                                --证券名称
     , T3.TRAN_MKT_CODE                                                              AS MKT_CODE                                --市场代码
     , T3.SCR_SCD_CATG_CODE                                                          AS SCR_CATG_CODE                           --证券类别代码
     , T5.STD_DICT_CLS_CDVAL_DESC                                               AS SCR_CATG_NAME                           --证券类别名称
     , T1.C_MARKET_PRICE                                                             AS PERM_MKTP_TRAN_FLAG                     --允许市价交易标志
     , CASE 
         WHEN T1.L_KIND_NO IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_KIND_NO)) 
       END                                                                           AS FUTR_VAR_CODE                           --期货品种代码
     , T4.STD_DICT_CLS_CDVAL_DESC                                               AS FUTR_VAR_NAME                           --期货品种名称
     , CASE 
         WHEN T1.C_STATUS IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS)) 
       END                                                                           AS STAT_CODE                               --状态代码
     , T1.VC_MONTH                                                                   AS CTRA_MTH                                --合约月份
     , T1.L_MULTIPLE                                                                 AS CTRA_MULT                               --合约乘数
     , T1.L_LAST_TRADE_DATE                                                          AS LAST_TRAN_DATE                          --最后交易日期
     , T1.L_LAST_TRADE_TIME                                                          AS LAST_TRAN_DATE_TIME                     --最后交易日时间
     , T1.L_LAST_SETTLEMENT_DATE                                                     AS DELI_DATE                               --交割日期
     , T1.EN_REAL_PRICE                                                              AS REAL_QUOT_SETL_PRIC                     --实时行情结算价
     , T1.EN_PRICE                                                                   AS TDY_MKT_SETL_PRIC                       --当日市场结算价
     , T1.EN_PRE_PRICE                                                               AS LST_TRAN_DATE_MKT_SETL_PRIC             --上一交易日市场结算价
     , T1.EN_POSITION_AMOUNT                                                         AS TDY_MKT_OI                              --当日市场持仓量
     , T1.EN_POSITION_AMOUNT_PRE                                                     AS LST_TRAN_DATE_MKT_OI                    --上一交易日市场持仓量
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TFUTURESINFO_PFD'                                                    AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TFUTURESINFO_PFD T1  --期货信息表
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2 --证券编码映射
    ON T1.VC_INTER_CODE = T2.SCR_INCD--证券内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T3 --证券基本信息
    ON T2.SCR_NUM = T3.SCR_NUM
   AND T3.VALID_FLAG = '1'--有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T4.SRC_DICT_CLS_CD = 'L_KIND_NO'--源字典分类
   AND T1.L_KIND_NO = T4.SRC_DICT_CLS_CDVAL
   AND T4.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T3.SCR_SCD_CATG_CODE = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.STD_DICT_CLS_CD = 'SCR_SCD_CATG_CODE'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T6.SRC_DICT_CLS_CD = 'C_FUTR_STATUS'--源字典分类
   AND T1.C_STATUS = T6.SRC_DICT_CLS_CDVAL
   AND T6.SSYS = 'O32'--源系统简称比如O32\FA45
 WHERE T1.P_DT = '${p_end_dt}'
;"
