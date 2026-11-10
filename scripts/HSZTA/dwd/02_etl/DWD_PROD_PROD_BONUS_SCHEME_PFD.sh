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
-- ** 描述:产品分红方案
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_BONUS_SCHEME_PFD  产品分红方案
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITSCHEMA_PFD  基金分红方案
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITSCHEMA_PFD 基金分红方案
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD  产品编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_BONUS_SCHEME_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T1.C_SCHEMANO                                                                 AS BONUS_SCHEME_NO                         --分红方案编号
     , T1.C_DESCRIBE                                                                 AS BONUS_SCHEME_DESC                       --分红方案描述
     , SUBSTR(REPLACE(T1.D_REGISTERDATE,'-',''),1,8)                                 AS REG_DATE                                --登记日期
     , CASE WHEN T1.C_BONUSTYPE IS NOT NULL 
              THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BONUSTYPE)) 
        END                                                                          AS BONUS_MODE_CODE                         --分红方式代码
     , T1.F_TOTALPROFIT                                                              AS DIVD_GAMT                               --红利总额
     , T1.F_UNITPROFIT                                                               AS PER_UNIT_BONUS                          --每单位分红
     , SUBSTR(REPLACE(T1.D_DISTRIBUTEDATE,'-',''),1,8)                               AS DIVD_GANT_DATE                          --红利发放日期
     , SUBSTR(REPLACE(T1.D_REINVESTDATE,'-',''),1,8)                                 AS REINV_DATE                              --再投资日期
     , CASE WHEN T1.C_DEALFLAG IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEALFLAG)) 
        END                                                                          AS BONUS_DEAL_STAT_CODE                    --分红处理状态代码
     , T1.F_INCOMETAX                                                                AS INCT_RATIO                              --所得税率
     , T1.C_RATIOTYPE                                                                AS YLD_MODE                                --收益率方式
     , T1.F_EXPECTRATIO                                                              AS EXPE_YLD                                --预期收益率
     , T1.C_YEARDAYS                                                                 AS YEAR_DAYS_STD                           --年天数标准
     , CASE WHEN T1.C_FBALANCEFLAG = '1' THEN --原系统 是否冻结现金 1表示否 
              '0'
            WHEN T1.C_FBALANCEFLAG = '0' THEN
              '1'
            ELSE
              T1.C_FBALANCEFLAG
       END                                                                           AS IS_FRZ_CASH_CODE                        --是否冻结现金代码
     , CASE WHEN T1.C_FSHARESFLAG = '1' THEN --原系统 是否冻结份额 1表示否 
              '0'
            WHEN T1.C_FSHARESFLAG = '0' THEN
              '1'
            ELSE
              T1.C_FSHARESFLAG
       END                                                                           AS IS_FRZ_SHARE_CODE                       --是否冻结份额代码
     , CASE WHEN T1.C_FORCEREDEEM = '1' THEN --原系统 冻结是否强制再投资 1表示否 
              '0'
            WHEN T1.C_FORCEREDEEM = '0' THEN
              '1'
            ELSE
              T1.C_FORCEREDEEM
       END                                                                           AS FRZ_IS_FORC_REINV_CODE                  --冻结是否强制再投资代码
     , CASE WHEN T1.C_FLAG = '1' THEN --原系统 是否已经发起 1表示否 
              '0'
            WHEN T1.C_FLAG = '0' THEN
              '1'
            ELSE
              T1.C_FLAG
       END                                                                           AS IS_HAS_SPON                             --是否已经发起
     , CASE WHEN T1.C_FROMFLAG = '1' THEN --原系统 发起标志 1表示否 
              '0'
            WHEN T1.C_FROMFLAG = '0' THEN
              '1'
            ELSE
              T1.C_FROMFLAG
       END                                                                           AS SPON_FLAG_CODE                          --发起标志代码
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TPROFITSCHEMA_PFD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITSCHEMA_PFD T1  --基金分红方案
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_DEALFLAG'
   AND T1.C_DEALFLAG = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_BONUS_SCHEME_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , NULL                                                                          AS BONUS_SCHEME_NO                         --分红方案编号
     , T1.C_DESCRIBE                                                                 AS BONUS_SCHEME_DESC                       --分红方案描述
     , SUBSTR(REPLACE(T1.D_REGISTERDATE,'-',''),1,8)                                 AS REG_DATE_PD                             --登记日期
     , CASE WHEN T1.C_BONUSTYPE IS NOT NULL 
              THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BONUSTYPE)) 
        END                                                                          AS BONUS_MODE_CODE                         --分红方式代码
     , T1.F_TOTALPROFIT                                                              AS DIVD_GAMT                               --红利总额
     , T1.F_UNITPROFIT                                                               AS PER_UNIT_BONUS                          --每单位分红
     , SUBSTR(REPLACE(T1.D_DISTRIBUTEDATE,'-',''),1,8)                               AS DIVD_GANT_DATE                          --红利发放日期
     , SUBSTR(REPLACE(T1.D_REINVESTDATE,'-',''),1,8)                                 AS REINV_DATE                              --再投资日期
     , CASE WHEN T1.C_DEALFLAG IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_DEALFLAG)) 
        END                                                                          AS BONUS_DEAL_STAT_CODE                    --分红处理状态代码
     , T1.F_INCOMETAX                                                                AS INCT_RATIO                              --所得税率
     , NULL                                                                          AS YLD_MODE                                --收益率方式
     , NULL                                                                          AS EXPE_YLD                                --预期收益率
     , NULL                                                                          AS YEAR_DAYS_STD                           --年天数标准
     , CASE WHEN T1.C_FBALANCEFLAG = '1' THEN --原系统 是否冻结现金 1表示否 
              '0'
            WHEN T1.C_FBALANCEFLAG = '0' THEN
              '1'
            ELSE
              T1.C_FBALANCEFLAG
       END                                                                           AS IS_FRZ_CASH_CODE                        --是否冻结现金代码
     , CASE WHEN T1.C_FSHARESFLAG = '1' THEN --原系统 是否冻结现金 1表示否 
              '0'
            WHEN T1.C_FSHARESFLAG = '0' THEN
              '1'
            ELSE
              T1.C_FSHARESFLAG
       END                                                                           AS IS_FRZ_SHARE_CODE                       --是否冻结份额代码
     , CASE WHEN T1.C_FORCEREDEEM = '1' THEN --原系统 冻结是否强制再投资 1表示否 
              '0'
            WHEN T1.C_FORCEREDEEM = '0' THEN
              '1'
            ELSE
              T1.C_FORCEREDEEM
       END                                                                           AS FRZ_IS_FORC_REINV_CODE                  --冻结是否强制再投资代码
     , CASE WHEN T1.C_FLAG = '1' THEN --原系统 是否已经发起 1表示否 
              '0'
            WHEN T1.C_FLAG = '0' THEN
              '1'
            ELSE
              T1.C_FLAG
       END                                                                           AS IS_HAS_SPON                             --是否已经发起
     , CASE WHEN T1.C_FROMFLAG = '1' THEN --原系统 发起标志 1表示否 
              '0'
            WHEN T1.C_FROMFLAG = '0' THEN
              '1'
            ELSE
              T1.C_FROMFLAG
       END                                                                           AS SPON_FLAG_CODE                          --发起标志代码
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TPROFITSCHEMA_PFD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITSCHEMA_PFD T1  --基金分红方案
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSFTA'
   AND T3.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFTA'
   AND T4.SRC_DICT_CLS_CD = 'C_DEALFLAG'
   AND T1.C_DEALFLAG = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

"
