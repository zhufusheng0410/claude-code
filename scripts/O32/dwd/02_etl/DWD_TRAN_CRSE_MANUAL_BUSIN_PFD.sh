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
-- ** 描    述:科目手工类业务表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_CRSE_MANUAL_BUSIN_PFD     科目手工类业务表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TSUBJECTBUSINESS_PFD  科目类业务表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD         账套编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP         标准码值字典映射表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_CRSE_MANUAL_BUSIN_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_BUSIN_NO                                                                 AS BUSIN_SERIALNO                          --业务序号
     , T1.L_BATCH_NO                                                                 AS BAT_NO                                  --批号
     , T1.L_DATE                                                                     AS OCCUR_DATE                              --发生日期
     , T1.L_TIME                                                                     AS OCCUR_TIME                              --发生时间
     , CASE 
         WHEN T1.VC_BUSIN_OPFLAG IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_BUSIN_OPFLAG)) 
       END                                                                           AS BUSIN_OPER_TYPE_CODE                    --业务操作类型代码
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_ASSET_ID                                                                 AS AST_UNIT_SERIALNO                       --资产单元序号
     , CASE 
         WHEN T1.C_ADJUST_TYPE IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ADJUST_TYPE)) 
       END                                                                           AS CRSE_ADJ_TYPE_CODE                      --科目调整类型代码
     , T1.C_ADJUST_ASSET                                                             AS SYNC_ADJ_CPTL_FLAG                      --同步调整资金标志
     , CASE 
         WHEN T1.VC_CURRENCY_NO IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_CURRENCY_NO)) 
       END                                                                           AS CRRC_CODE                               --币种代码
     , T1.L_SUBJECT_NO                                                               AS O3_CRSE_NO                              --O3科目编号
     , T1.EN_OCCUR_BALANCE                                                           AS OCCUR_AMT                               --发生金额
     , T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , T1.L_OPERATE_ENABLE_DATE                                                      AS OPER_TECT_DATE                          --操作生效日期
     , T1.VC_MEMO                                                                    AS MEMO                                    --备注
     , T1.L_CHECK_DATE                                                               AS CHK_DATE                                --复核日期
     , T1.L_CHECK_TIME                                                               AS CHK_TIME                                --复核时间
     , T1.L_CHECK_OPERATOR                                                           AS CHKR_CODE                               --复核人代码
     , T1.C_CHECK_FLAG                                                               AS CHK_FLAG                                --复核标志
     , T1.VC_CHECK_MEMO                                                              AS CHK_MEMO                                --复核备注
     , T1.C_DEAL_FLAG                                                                AS DEAL_FLAG                               --处理标志
     , T1.C_DEL_STATUS                                                               AS DEL_FLAG                                --删除标志
     , T1.L_DEL_OPERATOR                                                             AS DEL_OPER_CODE                           --删除操作员代码
     , T1.L_DEL_DATE                                                                 AS DEL_DATE                                --删除日期
     , T1.L_DEL_TIME                                                                 AS DEL_TIME                                --删除时间
     , T1.L_BUSINESS_DATE                                                            AS BUSIN_DATE                              --业务日期
     , T1.D_DATETIME                                                                 AS TIME_STAMP                              --时间戳
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TSUBJECTBUSINESS_PFD'                                                AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TSUBJECTBUSINESS_PFD T1  --科目类业务表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD --产品内码
   AND T2.SSYS = 'O32' --源系统
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T1.VC_BUSIN_OPFLAG = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T3.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T3.SRC_DICT_CLS_CD = 'VC_CRSE_BUSIN_OPFLAG' --源字典分类
   AND T3.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.C_ADJUST_TYPE = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T4.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'C_ADJUST_TYPE' --源字典分类
   AND T4.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.VC_CURRENCY_NO = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T5.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
   AND T5.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT =  '${p_end_dt}'

;

ALTER TABLE DWDXDAY.DWD_TRAN_CRSE_MANUAL_BUSIN_PFD DROP PARTITION(P_DT <= '${day_8_ago}')
;


"
