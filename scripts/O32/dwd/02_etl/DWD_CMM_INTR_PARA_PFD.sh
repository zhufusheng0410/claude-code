#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:公共
-- ** 描    述:利率参数表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_CMM_INTR_PARA_PFD           利率参数表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TINTERESTRATE_PFD  利率参数表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD      账套编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP      标准码值字典映射表
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_CMM_INTR_PARA_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS \`DATE\`                                    --日期
     , T1.L_RATE_NO                                                                  AS INTR_PARA_SERIALNO                      --利率参数序号
     , CASE 
         WHEN T1.VC_CURRENCY_NO IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_CURRENCY_NO)) 
       END                                                                           AS CRRC_CODE                               --币种代码
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_ASSET_ID                                                                 AS AST_UNIT_SERIALNO                       --资产单元序号
     , CASE 
         WHEN T1.L_RATE_TYPE IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_RATE_TYPE)) 
       END                                                                           AS INTR_CATG_CODE                          --利率类别代码
     , T1.VC_RATE_NAME                                                               AS INTR_NAME                               --利率名称
     , CASE 
         WHEN T1.C_YEAR_DAY_TYPE IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_YEAR_DAY_TYPE)) 
       END                                                                           AS YEAR_CALCT_DAYS_TYPE_CODE               --年计算天数类型代码
     , T1.EN_YEAR_RATE                                                               AS YEAR_INTR                               --年利率
     , T1.L_DAYS                                                                     AS YEAR_INTR_CALCT_DAYS                    --年利率计算天数
     , T1.EN_DAY_RATE                                                                AS DAY_INTR                                --日利率
     , T1.EN_RATE_TAX_RATE                                                           AS INTR_TAX_RATIO                          --利息税比率
     , CASE 
         WHEN T1.C_BASIC IS NOT NULL AND LENGTH(T1.C_BASIC) <> 0 THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BASIC)) 
       END                                                                           AS ACCRUE_BASI_CODE                        --计提基准代码
     , T1.EN_FIXED_AMOUNT                                                            AS ACCRUE_FIX_VAL                          --计提固定值
     , T1.EN_MIN_RESERVE_BALANCE                                                     AS LOW_RETA_AMT                            --最低保留额
     , T1.EN_FLOATING_BALANCE                                                        AS FLOAT_LMT                               --浮动额度
     , CASE 
         WHEN T1.C_RATE_STATUS IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RATE_STATUS)) 
       END                                                                           AS INTR_STAT_CODE                          --利率状态代码
     , T1.VC_TIMESTAMP                                                               AS TIME_STAMP                              --时间戳
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TINTERESTRATE_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TINTERESTRATE_PFD T1  --利率参数表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD --产品内码
   AND T2.SSYS = 'O32' --源系统
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T1.L_RATE_TYPE = T3.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T3.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T3.SRC_DICT_CLS_CD = 'L_RATE_TYPE' --源字典分类
   AND T3.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.C_YEAR_DAY_TYPE = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T4.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'C_YEAR_DAY_TYPE' --源字典分类
   AND T4.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_BASIC = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T5.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_ACCRUE_BASIC' --源字典分类
   AND T5.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_RATE_STATUS = T6.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T6.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_RATE_STATUS' --源字典分类
   AND T6.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.VC_CURRENCY_NO = T7.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T7.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
   AND T7.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT = '${p_end_dt}'

;

"
