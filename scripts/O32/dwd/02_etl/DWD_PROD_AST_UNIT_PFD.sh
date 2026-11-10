#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "

-- **************************************************************************
-- ** 主题:产品
-- ** 描述:O32资产单元表
-- ** 创建者:xiemn
-- ** 创建日期:2023-05-17
-- ** 修改日志:
-- ** 2023-05-17，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_PROD_AST_UNIT_PFD       O32资产单元表
-- ** 源  表：ODS_XDAY_O32.ODS_O32_TASSET_PFD     资产单元基本信息表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD  账套编码映射
-- **         ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD  基金信息表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  标准字典码值映射
-- **
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;

set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_AST_UNIT_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_ASSET_ID                                                                   AS AST_UNIT_SERIALNO                       --资产单元序号
     , T1.VC_ASSET_NO                                                                  AS AST_UNIT_NO                             --资产单元编号
     , T1.VC_ASSET_NAME                                                                AS AST_UNIT_NAME                           --资产单元名称
     , T2.SFAC_NUM                                                                     AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                    AS PROD_INCD                               --产品内码
     , T1.C_OVERDRAFT                                                                  AS PERM_ODFT_FLAG                          --允许透支标志
     , CASE 
         WHEN T12.L_DEFAULT_ASSET = T1.L_ASSET_ID THEN
          '1'
         ELSE 
          '0'
       END                                                                             AS DEF_AST_UNIT_FLAG                       --默认资产单元标志
     , T1.VC_CAPITAL_ACCOUNT                                                           AS CPTL_ACCO                               --资金账号
     , T1.VC_BANK_NAME                                                                 AS OPEN_BANK_NAME                          --开户行名称
     , T1.VC_ACCOUNT_NAME                                                              AS OPEN_NAME                               --开户名
     , T1.L_LOCAL_CUSTODIAN                                                            AS CSTD_BANK                               --托管行
     , T1.VC_BANK_ACCOUNT                                                              AS CSTD_BANK_ACCT                          --托管行银行帐号
     , T1.C_TRUST                                                                      AS CSTD_FLAG                               --托管标志
     , CASE 
         WHEN T1.C_ASSET_TYPE IS NOT NULL THEN
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ASSET_TYPE))
       END                                                                             AS AST_CATG_CODE                           --资产类别代码
     , CASE 
         WHEN T1.C_CASH_AVAILABLE_TYPE IS NOT NULL THEN
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CASH_AVAILABLE_TYPE))
       END                                                                             AS CPTL_USE_VAL_TYPE_CODE                  --资金可用值类型代码
     , CASE 
         WHEN T1.C_ASSET_STATUS IS NOT NULL THEN
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ASSET_STATUS))
       END                                                                             AS AST_UNIT_STAT_CODE                      --资产单元状态代码
     , CASE 
         WHEN T1.C_INVEST_AREA IS NOT NULL THEN
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVEST_AREA))
       END                                                                             AS INV_AREA_CODE                           --投资区域代码
     , T1.C_THIRD_PARTY_CUSTODY                                                        AS THIP_DEPO_FLAG                          --第三方存管标志
     , CASE 
         WHEN T1.C_CREDIT_ASSET IS NOT NULL THEN
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CREDIT_ASSET))
       END                                                                             AS AST_UNIT_PROP_CODE                      --资产单元属性代码
     , T1.C_BRANCH_ADJUST_FLAG                                                         AS SPOT_COMPART_ADJ_FLAG                   --现货分仓调整标志
     , T1.C_BRANCH_ADJUST_FLAG_QH                                                      AS FUTR_COMPART_ADJ_FLAG                   --期货分仓调整标志
     , CASE 
         WHEN T1.C_INSTR_AUTO IS NOT NULL THEN
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INSTR_AUTO))
       END                                                                             AS SPOT_ISTCT_LINK_MODE_CODE               --现货指令接入模式代码
     , CASE 
         WHEN T1.C_FUTURE_INSTR_AUTO IS NOT NULL THEN
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUTURE_INSTR_AUTO))
       END                                                                             AS FUTR_ISTCT_LINK_MODE_CODE               --期货指令接入模式代码
     , CASE 
         WHEN T1.C_ENTRUST_AUTO IS NOT NULL THEN
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_AUTO))
       END                                                                             AS SPOT_TRAN_LINK_MODE_CODE                --现货交易接入模式代码
     , CASE 
         WHEN T1.C_FUTURE_ENTRUST_AUTO IS NOT NULL THEN
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUTURE_ENTRUST_AUTO))
       END                                                                             AS FUTR_TRAN_LINK_MODE_CODE                --期货交易接入模式代码
     , 'O32'                                                                           AS SSYS                                    --源系统
     , 'ODS_O32_TASSET_PTD'                                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TASSET_PFD T1  --资产单元基本信息表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'O32'
   AND T3.SRC_DICT_CLS_CD = 'C_ASSET_CLASS'
   AND T1.C_ASSET_TYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'O32'
   AND T4.SRC_DICT_CLS_CD = 'C_CASH_AVAILABLE_TYPE'
   AND T1.C_CASH_AVAILABLE_TYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'O32'
   AND T5.SRC_DICT_CLS_CD = 'C_ASSET_STATUS'
   AND T1.C_ASSET_STATUS = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'O32'
   AND T6.SRC_DICT_CLS_CD = 'C_INVEST_AREA'
   AND T1.C_INVEST_AREA = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'O32'
   AND T7.SRC_DICT_CLS_CD = 'C_CREDIT_ASSET'
   AND T1.C_CREDIT_ASSET = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'O32'
   AND T8.SRC_DICT_CLS_CD = 'C_INSTR_AUTO'
   AND T1.C_INSTR_AUTO = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
    ON T9.SSYS = 'O32'
   AND T9.SRC_DICT_CLS_CD = 'C_FUTURE_INSTR_AUTO'
   AND T1.C_FUTURE_INSTR_AUTO = T9.SRC_DICT_CLS_CDVAL
   AND T9.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准字典码值映射
    ON T10.SSYS = 'O32'
   AND T10.SRC_DICT_CLS_CD = 'C_ENTRUST_AUTO'
   AND T1.C_ENTRUST_AUTO = T10.SRC_DICT_CLS_CDVAL
   AND T10.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准字典码值映射
    ON T11.SSYS = 'O32'
   AND T11.SRC_DICT_CLS_CD = 'C_FUTURE_ENTRUST_AUTO'
   AND T1.C_FUTURE_ENTRUST_AUTO = T11.SRC_DICT_CLS_CDVAL
   AND T11.VALID_FLAG = '1'
  LEFT JOIN ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD T12 --基金信息表
    ON T1.L_FUND_ID = T12.L_FUND_ID
   AND T1.P_DT = T12.P_DT
 WHERE T1.P_DT = '${p_end_dt}'
;"
