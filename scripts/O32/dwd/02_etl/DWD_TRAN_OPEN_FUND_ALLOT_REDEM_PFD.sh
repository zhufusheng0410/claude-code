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
-- ** 描    述:开放式基金申购赎回表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_OPEN_FUND_ALLOT_REDEM_PFD  开放式基金申购赎回表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TAPPLYREDEEM_PFD       开放式基金申购赎回表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD          账套编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP          标准码值字典映射表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_OPEN_FUND_ALLOT_REDEM_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS DEAL_DATE                               --处理日期
     , CASE 
         WHEN T1.VC_BUSIN_FLAG IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_BUSIN_FLAG)) 
       END                                                                           AS BUSIN_TYPE_CODE                         --业务类型代码
     , T1.L_TRADE_DATE                                                               AS TA_CNFM_DATE                            --TA确认日期
     , T1.L_COMPLETE_DATE                                                            AS CPTL_DELIV_DATE                         --资金交收日期
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_ASSET_ID                                                                 AS AST_UNIT_SERIALNO                       --资产单元序号
     , CASE 
         WHEN T1.VC_ORIGINAL_BUSIN_FLAG IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_ORIGINAL_BUSIN_FLAG)) 
       END                                                                           AS ORI_BUSIN_TYPE_CODE                     --原业务类型代码
     , CASE 
         WHEN T1.VC_CURRENCY_NO IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_CURRENCY_NO)) 
       END                                                                           AS CRRC_CODE                               --币种代码
     , T1.C_SUBJECT_FLAG                                                             AS CRSE_DEAL_FLAG                          --科目处理标志
     , T1.C_DEAL_FLAG                                                                AS AST_DEAL_FLAG                           --资产处理标志
     , T1.L_SERIAL_NO                                                                AS TRAN_SERIALNO                           --交易序号
     , T1.EN_SHARES                                                                  AS DEAL_SHARE                              --成交份额
     , T1.EN_BALANCE                                                                 AS DEAL_AMT                                --成交金额
     , T1.C_FORZEN_FLAG                                                              AS FRZ_FLAG                                --冻结标志
     , T1.EN_FROZEN_BALANCE                                                          AS FRZ_AMT                                 --冻结金额
     , T1.VC_AGENCY                                                                  AS SALE_ORG                                --销售机构
     , T1.EN_UNIT_DIVIDENDS                                                          AS UNIT_BONUS                              --单位分红
     , T1.EN_FEE                                                                     AS FEE                                     --费用
     , T1.EN_FEE_JY                                                                  AS TRAN_FEE                                --交易费
     , T1.EN_FEE_GH                                                                  AS TRFE                                    --过户费
     , T1.EN_FEE_YH                                                                  AS STMP                                    --印花税
     , T1.EN_FEE_HS                                                                  AS FINAL                                   --后收费
     , T1.EN_FEE_QT                                                                  AS OTH_FEE                                 --其他费用
     , T1.EN_FEE_GJJZC                                                               AS COLL_FUND_AST_FEE                       --归基金资产费用
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_XDAY_O32.ODS_O32_TAPPLYREDEEM_PFD'                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TAPPLYREDEEM_PFD T1  --开放式基金申购赎回表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD --产品内码
   AND T2.SSYS = 'O32' --源系统
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T1.VC_BUSIN_FLAG = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T3.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T3.SRC_DICT_CLS_CD = 'VC_BUSIN_FLAG' --源字典分类
   AND T3.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.VC_ORIGINAL_BUSIN_FLAG = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T4.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'VC_ORIGINAL_BUSIN_FLAG' --源字典分类
   AND T4.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.VC_CURRENCY_NO = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T5.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
   AND T5.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT = '${p_end_dt}'

;

-- 保留近一周数据
ALTER TABLE DWDXDAY.DWD_TRAN_OPEN_FUND_ALLOT_REDEM_PFD DROP PARTITION(P_DT <= '${day_8_ago}')
;

"
