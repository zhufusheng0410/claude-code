#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "


-- **************************************************************************
-- ** 主题: 交易
-- ** 描述: 统计加工指令的下达，审批，分发、执行和完成情况
-- ** 创建者 : xiemn
-- ** 创建日期: 20230516
-- ** 修改日志:
-- ** 20230516，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_TRAN_ISTCT_INFO_PTD         指令信息表
-- ** 源  表：ODS_XDAY_O32.ODS_O32_TINSTRUCTION_PTD   指令表
-- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD      账套编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP      标准码值字典映射表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_ISTCT_INFO_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                       AS BUSIN_DATE                              --业务日期
     , T1.L_DAILY_INSTRUCTION_NO                                                       AS ISTCT_SERIALNO                          --指令序号
     , T1.L_INDEX_DAILY_MODIFY                                                         AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T2.SFAC_NUM                                                                     AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                    AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                    AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                               AS PORTF_SERIALNO                          --投资组合序号
     , CASE 
         WHEN T1.C_BUSIN_CLASS IS NOT NULL THEN
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BUSIN_CLASS))
       END                                                                             AS BUSIN_CATG_CODE                         --业务分类代码
     , CASE 
         WHEN T1.C_INSTRUCTION_TYPE IS NOT NULL THEN
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INSTRUCTION_TYPE))
       END                                                                             AS ISTCT_TYPE_CODE                         --指令类型代码
     , CASE 
         WHEN T1.C_TARGET_TYPE IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TARGET_TYPE))
       END                                                                             AS ISTCT_TGT_TYPE_CODE                     --指令目标类型代码
     , T1.EN_TARGET_BASE                                                               AS ISTCT_TGT_BASE_CODE                     --指令目标基数
     , T1.EN_TARGET_VALUE                                                              AS ISTCT_TARGET_VALUE                      --指令目标值
     , CASE 
         WHEN T1.C_STOCK_TARGET_TYPE IS NOT NULL THEN
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STOCK_TARGET_TYPE))
       END                                                                             AS ISTCT_SCR_CTRL_TYPE_CODE                --指令证券控制类型代码
     , CASE 
         WHEN T1.C_ENTRUST_RESTRICT IS NOT NULL THEN
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_RESTRICT))
       END                                                                             AS ENTU_ORNT_LIM_CODE                      --委托方向限制代码
     , CASE 
         WHEN T1.C_FIRST_SETTLE_TYPE IS NOT NULL AND LENGTH(T1.C_FIRST_SETTLE_TYPE) <> 0 THEN
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FIRST_SETTLE_TYPE))
       END                                                                             AS FST_DELI_MODE_CODE                      --首次交割方式代码
     , T1.L_FIRST_SETTLE_DATE                                                          AS FST_DELI_DATE                           --首次交割日期
     , CASE 
         WHEN T1.C_SECOND_SETTLE_TYPE IS NOT NULL AND LENGTH(T1.C_SECOND_SETTLE_TYPE) <> 0 THEN
          COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SECOND_SETTLE_TYPE))
       END                                                                             AS DUE_DELI_MODE_CODE                      --到期交割方式代码
     , T1.L_SECOND_SETTLE_DATE                                                         AS DUE_DELI_DATE                           --到期交割日期
     , T1.L_HG_DAYS                                                                    AS REPO_DAYS                               --回购天数
     , T1.L_TRADE_RIVAL_NO                                                             AS CNTP_NUM                                --交易对手编码
     , CASE 
         WHEN T1.L_SETTLE_SPEED IS NOT NULL THEN
          COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_SETTLE_SPEED))
       END                                                                             AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , T1.L_BEGIN_DATE                                                                 AS ISTCT_BEGIN_DATE                        --指令起始日期
     , T1.L_BEGIN_TIME                                                                 AS ISTCT_BEGIN_TIME                        --指令起始时间
     , T1.L_END_DATE                                                                   AS ISTCT_END_DATE                          --指令终止日期
     , T1.L_END_TIME                                                                   AS ISTCT_END_TIME                          --指令终止时间
     , T1.L_DIRECT_OPERATOR                                                            AS ISTCT_RELE_CODE                         --指令下达人代码
     , T1.L_DIRECT_INSTEAD_OPERATOR                                                    AS ISTCT_AGT_RELE_CODE                     --指令代下达人代码
     , T1.L_DIRECT_DATE                                                                AS ISTCT_RELE_DATE                         --指令下达日期
     , T1.L_DIRECT_TIME                                                                AS ISTCT_RELE_TIME                         --指令下达时间
     , T1.L_APPROVE_OPERATOR                                                           AS ISTCT_APRVR_CODE                        --指令审批人代码
     , T1.C_APPROVE_STATUS                                                             AS ISTCT_APRV_STAT_CODE                    --指令审批状态代码
     , T1.L_APPROVE_DATE                                                               AS ISTCT_APRV_DATE                         --指令审批日期
     , T1.L_APPROVE_BUSIN_DATE                                                         AS ISTCT_APRV_BUSIN_DATE                   --指令审批业务日期
     , T1.L_APPROVE_TIME                                                               AS ISTCT_APRV_TIME                         --指令审批时间
     , T1.VC_APPROVE_REFUSE_REASON                                                     AS ISTCT_APRV_REFU_CAUSE                   --指令审批拒绝原因
     , T1.L_DISPENSE_OPERATOR                                                          AS ISTCT_DTBTR_CODE                        --指令分发人代码
     , T1.L_DISPENSE_TIME                                                              AS ISTCT_DISTR_TIME                        --指令分发时间
     , T1.C_DISPENSE_STATUS                                                            AS ISTCT_DISTR_STAT_CODE                   --指令分发状态代码
     , T1.VC_DISPENSE_REFUSE_REASON                                                    AS ISTCT_DISTR_REFU_CAUSE                  --指令分发拒绝原因
     , T1.L_CANCEL_OPERATOR                                                            AS ISTCT_WHDW_CODE                         --指令撤销人代码
     , T1.L_CANCEL_DATE                                                                AS WHDW_DATE                               --撤销日期
     , T1.L_CANCEL_TIME                                                                AS WHDW_TIME                               --撤销时间
     , T1.VC_CANCEL_REASON                                                             AS WHDW_CAUSE                              --撤销原因
     , T1.L_OPERATOR_NO                                                                AS ISTCT_EXEC_CODE                         --指令执行人代码
     , CASE 
         WHEN T1.C_INSTRUCTION_STATUS IS NOT NULL THEN
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INSTRUCTION_STATUS))
       END                                                                             AS ISTCT_STAT_CODE                         --指令状态代码
     , CASE 
         WHEN T1.C_ENTRUST_EXECUTE_STATUS IS NOT NULL THEN
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_EXECUTE_STATUS))
       END                                                                             AS ENTU_FNSH_STAT_CODE                     --委托完成状态代码
     , CASE 
         WHEN T1.C_DEAL_EXECUTE_STATUS IS NOT NULL THEN
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEAL_EXECUTE_STATUS))
       END                                                                             AS DEAL_FNSH_STAT_CODE                     --成交完成状态代码
     , CASE 
         WHEN T1.C_SOURCE IS NOT NULL THEN
          COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SOURCE))
       END                                                                             AS ISTCT_SRC_CODE                          --指令来源代码
     , 'O32'                                                                           AS SSYS                                    --源系统
     , 'ODS_O32_TINSTRUCTION_PTD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')        AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTION_PTD T1  --指令表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'  --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T3.SSYS = 'O32'--源系统简称
   AND T3.SRC_DICT_CLS_CD = 'C_INSTRUCTION_TYPE'--源字典分类
   AND T1.C_INSTRUCTION_TYPE = T3.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T3.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T4.SSYS = 'O32'--源系统简称
   AND T4.SRC_DICT_CLS_CD = 'C_TARGET_TYPE'--源字典分类
   AND T1.C_TARGET_TYPE = T4.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T4.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T5.SSYS = 'O32'--源系统简称
   AND T5.SRC_DICT_CLS_CD = 'C_INSTRUCTION_STATUS'--源字典分类
   AND T1.C_INSTRUCTION_STATUS = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T6.SSYS = 'O32'--源系统简称
   AND T6.SRC_DICT_CLS_CD = 'C_BUSIN_CLASS'--源字典分类
   AND T1.C_BUSIN_CLASS = T6.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T6.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T7.SSYS = 'O32'--源系统简称
   AND T7.SRC_DICT_CLS_CD = 'C_ENTRUST_EXECUTE_STATUS'--源字典分类
   AND T1.C_ENTRUST_EXECUTE_STATUS = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.VALID_FLAG = 1--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T8.SSYS = 'O32'--源系统简称
   AND T8.SRC_DICT_CLS_CD = 'C_DEAL_EXECUTE_STATUS'--源字典分类
   AND T1.C_DEAL_EXECUTE_STATUS = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.VALID_FLAG = 1--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T9.SSYS = 'O32'--源系统简称
   AND T9.SRC_DICT_CLS_CD = 'C_STOCK_TARGET_TYPE'--源字典分类
   AND T1.C_STOCK_TARGET_TYPE = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T10.SSYS = 'O32'--源系统简称
   AND T10.SRC_DICT_CLS_CD = 'C_ENTRUST_RESTRICT'--源字典分类
   AND T1.C_ENTRUST_RESTRICT = T10.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T11.SSYS = 'O32'--源系统简称
   AND T11.SRC_DICT_CLS_CD = 'C_FIRST_SETTLE_TYPE'--源字典分类
   AND T1.C_FIRST_SETTLE_TYPE = T11.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T11.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准码值字典映射表
    ON T12.SSYS = 'O32'--源系统简称
   AND T12.SRC_DICT_CLS_CD = 'C_SECOND_SETTLE_TYPE'--源字典分类
   AND T1.C_SECOND_SETTLE_TYPE = T12.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准码值字典映射表
    ON T13.SSYS = 'O32'--源系统简称
   AND T13.SRC_DICT_CLS_CD = 'C_ISTCT_SOURCE'--源字典分类
   AND T1.C_SOURCE = T13.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T13.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准码值字典映射表
    ON T14.SSYS = 'O32'--源系统简称
   AND T14.SRC_DICT_CLS_CD = 'L_SETTLE_SPEED'--源字典分类
   AND T1.L_SETTLE_SPEED = T14.SRC_DICT_CLS_CDVAL
   AND T14.VALID_FLAG = '1'--有效标志
 WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
;"
