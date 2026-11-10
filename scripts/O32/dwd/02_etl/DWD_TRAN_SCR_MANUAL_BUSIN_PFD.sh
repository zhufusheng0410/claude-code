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
-- ** 描    述:证券手工类业务表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_SCR_MANUAL_BUSIN_PFD   证券手工类业务表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TSTOCKBUSINESS_PFD 证券类业务表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD      账套编码映射
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD        证券编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP      标准码值字典映射表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD      证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_SCR_MANUAL_BUSIN_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_BUSIN_NO                                                                 AS BUSIN_SERIALNO                          --业务序号
     , T1.L_BATCH_NO                                                                 AS BAT_NO                                  --批号
     , T1.L_DATE                                                                     AS OCCUR_DATE                              --发生日期
     , T1.L_TIME                                                                     AS OCCUR_TIME                              --发生时间
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T4.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T1.VC_STOCKHOLDER_ID                                                          AS HOLDER_CODE                             --股东代码
     , T1.VC_BIND_SEAT                                                               AS CSTD_SEAT                               --托管席位
     , CASE 
         WHEN T1.C_INVEST_TYPE IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_TYPE)) 
       END                                                                           AS INV_TYPE_CODE                           --投资类型代码
     , CASE 
         WHEN T1.VC_BUSIN_OPFLAG IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_BUSIN_OPFLAG)) 
       END                                                                           AS BUSIN_OPER_TYPE_CODE                    --业务操作类型代码
     , T5.SFAC_NUM                                                                   AS TGT_PROD_NUM                            --目标产品编码
     , T5.PROD_CODE                                                                  AS TGT_PROD_CODE                           --目标产品代码
     , T1.L_TARGET_FUND                                                              AS TGT_PROD_INCD                           --目标产品内码
     , T1.L_TARGET_COMBI                                                             AS TGT_PORTF_SERIALNO                      --目标投资组合序号
     , CASE 
         WHEN T1.C_TARGET_INVEST_TYPE IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TARGET_INVEST_TYPE)) 
       END                                                                           AS TGT_INV_TYPE_CODE                       --目标投资类型代码
     , T1.EN_OCCUR_AMOUNT                                                            AS OCCUR_QTY                               --发生数量
     , T1.EN_OCCUR_COST                                                              AS OCCUR_COST                              --发生成本
     , T1.EN_PRICE                                                                   AS COST_UNPRC                              --成本单价
     , T1.EN_OCCUR_PROFIT                                                            AS OCCUR_YIEL                              --发生收益
     , T1.VC_ADJUST_INVEST                                                           AS ADJ_COST_TYPE                           --调整成本类型
     , T1.L_OPERATE_ENABLE_DATE                                                      AS FRZ_UNFZ_BEGIN_DATE                     --冻结解冻起始日期
     , T1.L_OPERATE_DISABLE_DATE                                                     AS FRZ_UNFZ_END_DATE                       --冻结解冻终止日期
     , T1.L_FROZEN_NO                                                                AS FRZ_JOUR_SERIALNO                       --冻结流水序号
     , T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , T1.VC_MEMO                                                                    AS MEMO                                    --备注
     , T1.L_CHECK_DATE                                                               AS CHK_DATE                                --复核日期
     , T1.L_CHECK_TIME                                                               AS CHK_TIME                                --复核时间
     , T1.L_CHECK_OPERATOR                                                           AS CHKR_CODE                               --复核人代码
     , CASE 
         WHEN T1.C_CHECK_FLAG IS NOT NULL THEN 
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CHECK_FLAG)) 
       END                                                                           AS CHK_STAT_CODE                           --复核状态代码
     , T1.VC_CHECK_MEMO                                                              AS CHK_MEMO                                --复核备注
     , T1.C_DEAL_FLAG                                                                AS DEAL_FLAG                               --处理标志
     , T1.C_POSITION_FLAG                                                            AS HLDP_LAS_POS_FLAG                       --持仓多空标志
     , T1.C_INFLUENCE_STD_AVAILABLE                                                  AS PLG_STK_AVL_CNVR_STD_BOND_FLAG          --质押券可折算成标准券标志
     , T1.C_DEL_STATUS                                                               AS DEL_FLAG                                --删除标志
     , T1.L_DEL_OPERATOR                                                             AS DEL_OPER_CODE                           --删除操作员代码
     , T1.L_DEL_DATE                                                                 AS DEL_DATE                                --删除日期
     , T1.L_DEL_TIME                                                                 AS DEL_TIME                                --删除时间
     , T1.L_DETAIL_ID                                                                AS HLDP_DETAIL_SERIALNO                    --持仓明细序号
     , T1.L_OPEN_DATE                                                                AS OPEP_DATE                               --开仓日期
     , T1.L_OPEN_TIME                                                                AS OPEP_TIME                               --开仓时间
     , T1.L_TRADE_DATE                                                               AS TRAN_DATE                               --交易日期
     , T1.VC_DEAL_NO                                                                 AS DEAL_NO                                 --成交编号
     , T1.L_RETURN_DATE                                                              AS RETU_DATE                               --返还日期
     , CASE 
         WHEN T1.C_RETURN_POINT IS NOT NULL THEN 
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RETURN_POINT)) 
       END                                                                           AS RETU_TIME_POI_CODE                      --返还时点代码
     , T1.C_RETURN_DEAL_FLAG                                                         AS RETU_DEAL_FLAG                          --返还处理标志
     , CASE 
         WHEN T1.VC_ADJUST_PROFIT IS NOT NULL THEN 
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_ADJUST_PROFIT)) 
       END                                                                           AS ADJ_YIEL_TYPE_CODE                      --调整收益类型代码
     , T1.VC_ADJUST_INTINVEST                                                        AS ADJ_INTR_COST_TYPE                      --调整利息成本类型
     , T1.VC_ADJUST_INTPROFIT                                                        AS ADJ_INTR_YIEL_TYPE                      --调整利息收益类型
     , T1.EN_OCCUR_INTINVEST                                                         AS CHG_INTR_COST                           --变动利息成本
     , T1.EN_OCCUR_INTPROFIT                                                         AS CHG_INTR_YIEL                           --变动利息收益
     , T1.D_DATETIME                                                                 AS TIME_STAMP                              --时间戳
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TSTOCKBUSINESS_PFD'                                                  AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TSTOCKBUSINESS_PFD T1  --证券类业务表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD --产品内码
   AND T2.SSYS = 'O32' --源系统
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT =DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
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
   AND T4.SSYS ='O32'
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T5 --账套编码映射
    ON T1.L_TARGET_FUND = T5.SFAC_INCD --产品内码
   AND T5.SSYS = 'O32' --源系统
   AND T5.ST_DATE <= '${p_end_dt}' --开始日期
   AND T5.END_DATE >= '${p_end_dt}' --结束日期
   AND T5.VALID_FLAG = '1' --有效标志
   AND T5.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_INVEST_TYPE = T6.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T6.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_INVEST_TYPE' --源字典分类
   AND T6.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.VC_BUSIN_OPFLAG = T7.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T7.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'VC_STK_BUSIN_OPFLAG' --源字典分类
   AND T7.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_TARGET_INVEST_TYPE = T8.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T8.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'C_INVEST_TYPE' --源字典分类
   AND T8.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_CHECK_FLAG = T9.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T9.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T9.SRC_DICT_CLS_CD = 'C_CHECK_FLAG' --源字典分类
   AND T9.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.C_RETURN_POINT = T10.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T10.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T10.SRC_DICT_CLS_CD = 'C_RETURN_POINT' --源字典分类
   AND T10.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T1.VC_ADJUST_PROFIT = T11.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T11.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T11.SRC_DICT_CLS_CD = 'VC_ADJUST_PROFIT' --源字典分类
 WHERE T1.P_DT = '${p_end_dt}'

;

-- 保留近一周数据
ALTER TABLE DWDXDAY.DWD_TRAN_SCR_MANUAL_BUSIN_PFD DROP PARTITION(P_DT <= '${day_8_ago}')
;

"
