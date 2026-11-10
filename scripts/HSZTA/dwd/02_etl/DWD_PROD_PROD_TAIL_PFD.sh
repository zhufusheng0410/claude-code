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
-- ** 描述:产品尾随佣金
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建



-- ** 目标表：DWDXDAY.DWD_PROD_PROD_TAIL_PFD  产品尾随佣金
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIO_PFD  尾随佣金比例
-- **         ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD 尾随佣金比例
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTATAILRATIO_PFD 尾随佣金比例
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTACUSTTAILRATIO_PFD 尾随佣金比例
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
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

--临时表
--处理新表ZTA最新一天的全部数据
--客户类型不为*的
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_TAIL_PFD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.C_FLAG                                                                     AS SPON_FLAG                               --发起标志
     , SUBSTR(REPLACE(T1.D_BEGINDATE,'-',''),1,8)                                    AS ST_DATE                                 --开始日期
     , CASE WHEN T1.D_ENDDATE IS NULL OR T1.D_ENDDATE = '20991231' THEN 
              '29991231'
            ELSE
              T1.D_ENDDATE
       END                                                                           AS END_DATE                                --结束日期
     , T1.F_HOLDMIN                                                                  AS MIN_HOLD_AMT                            --最小保有金额
     , T1.F_HOLDMAX                                                                  AS MAX_HOLD_AMT                            --最大保有金额
     , T1.F_RATIO                                                                    AS OTC_TAIL_RATE                           --场外尾随佣金比例
     , NULL                                                                          AS EXCH_TAIL_RATE                          --场内尾随佣金比例
     , T1.C_CALCULATETYPE                                                            AS TAIL_CALCT_MODE                         --尾随佣金计算方式
     , T1.F_MINTAILFARE                                                              AS TAIL_MNP_AMT                            --尾随佣金起付金额
     , T1.L_YEARDAYS                                                                 AS TAIL_YEAR_DAYS                          --尾随佣金年天数
     , T1.C_TAILSEGMENT                                                              AS AGGR_CALCT_FLAG                         --累进计算标志
     , T1.C_UPDATEFLAG                                                               AS UPD_FLAG                                --更新标志
     , T1.F_AGENCYFEERATIO                                                           AS SALE_FEE_RATE                           --销售费用比例
     , T1.C_FOFEXTERNALRATIOFLAG                                                     AS FOF_EXT_RATE_FLAG                       --FOF外部比例标志
     , CASE WHEN T1.C_TAILRATIONTYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TAILRATIONTYPE)) 
        END                                                                           AS TAIL_RATE_TYPE_CODE                     --尾随佣金比例类型代码
     , T1.F_MANAGERRATIO                                                             AS MGR_RATE                                --管理人比例
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD'                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD T1  --尾随佣金比例  
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_TAILRATIONTYPE'
   AND T1.C_TAILRATIONTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T1.C_CUSTTYPE <> '*'
;

--处理新表ZTA最新一天的全部数据
--客户类型为*的 01
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_TAIL_PFD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , '01'                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.C_FLAG                                                                     AS SPON_FLAG                               --发起标志
     , SUBSTR(REPLACE(T1.D_BEGINDATE,'-',''),1,8)                                    AS ST_DATE                                 --开始日期
     , CASE WHEN T1.D_ENDDATE IS NULL OR T1.D_ENDDATE = '20991231' THEN 
              '29991231'
            ELSE
              T1.D_ENDDATE
       END                                                                           AS END_DATE                                --结束日期
     , T1.F_HOLDMIN                                                                  AS MIN_HOLD_AMT                            --最小保有金额
     , T1.F_HOLDMAX                                                                  AS MAX_HOLD_AMT                            --最大保有金额
     , T1.F_RATIO                                                                    AS OTC_TAIL_RATE                           --场外尾随佣金比例
     , NULL                                                                          AS EXCH_TAIL_RATE                          --场内尾随佣金比例
     , T1.C_CALCULATETYPE                                                            AS TAIL_CALCT_MODE                         --尾随佣金计算方式
     , T1.F_MINTAILFARE                                                              AS TAIL_MNP_AMT                            --尾随佣金起付金额
     , T1.L_YEARDAYS                                                                 AS TAIL_YEAR_DAYS                          --尾随佣金年天数
     , T1.C_TAILSEGMENT                                                              AS AGGR_CALCT_FLAG                         --累进计算标志
     , T1.C_UPDATEFLAG                                                               AS UPD_FLAG                                --更新标志
     , T1.F_AGENCYFEERATIO                                                           AS SALE_FEE_RATE                           --销售费用比例
     , T1.C_FOFEXTERNALRATIOFLAG                                                     AS FOF_EXT_RATE_FLAG                       --FOF外部比例标志
     , CASE WHEN T1.C_TAILRATIONTYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TAILRATIONTYPE)) 
        END                                                                           AS TAIL_RATE_TYPE_CODE                     --尾随佣金比例类型代码
     , T1.F_MANAGERRATIO                                                             AS MGR_RATE                                --管理人比例
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD'                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD T1  --尾随佣金比例  
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_TAILRATIONTYPE'
   AND T1.C_TAILRATIONTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T1.C_CUSTTYPE = '*'
;

--处理新表ZTA最新一天的全部数据
--客户类型为*的 02
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_TAIL_PFD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , '02'                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.C_FLAG                                                                     AS SPON_FLAG                               --发起标志
     , SUBSTR(REPLACE(T1.D_BEGINDATE,'-',''),1,8)                                    AS ST_DATE                                 --开始日期
     , CASE WHEN T1.D_ENDDATE IS NULL OR T1.D_ENDDATE = '20991231' THEN 
              '29991231'
            ELSE
              T1.D_ENDDATE
       END                                                                           AS END_DATE                                --结束日期
     , T1.F_HOLDMIN                                                                  AS MIN_HOLD_AMT                            --最小保有金额
     , T1.F_HOLDMAX                                                                  AS MAX_HOLD_AMT                            --最大保有金额
     , T1.F_RATIO                                                                    AS OTC_TAIL_RATE                           --场外尾随佣金比例
     , NULL                                                                          AS EXCH_TAIL_RATE                          --场内尾随佣金比例
     , T1.C_CALCULATETYPE                                                            AS TAIL_CALCT_MODE                         --尾随佣金计算方式
     , T1.F_MINTAILFARE                                                              AS TAIL_MNP_AMT                            --尾随佣金起付金额
     , T1.L_YEARDAYS                                                                 AS TAIL_YEAR_DAYS                          --尾随佣金年天数
     , T1.C_TAILSEGMENT                                                              AS AGGR_CALCT_FLAG                         --累进计算标志
     , T1.C_UPDATEFLAG                                                               AS UPD_FLAG                                --更新标志
     , T1.F_AGENCYFEERATIO                                                           AS SALE_FEE_RATE                           --销售费用比例
     , T1.C_FOFEXTERNALRATIOFLAG                                                     AS FOF_EXT_RATE_FLAG                       --FOF外部比例标志
     , CASE WHEN T1.C_TAILRATIONTYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TAILRATIONTYPE)) 
        END                                                                           AS TAIL_RATE_TYPE_CODE                     --尾随佣金比例类型代码
     , T1.F_MANAGERRATIO                                                             AS MGR_RATE                                --管理人比例
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD'                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD T1  --尾随佣金比例  
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_TAILRATIONTYPE'
   AND T1.C_TAILRATIONTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T1.C_CUSTTYPE = '*'
;

--处理新表ZTA最新一天的全部数据
--客户类型为*的 03
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_TAIL_PFD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , '03'                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T1.C_FLAG                                                                     AS SPON_FLAG                               --发起标志
     , SUBSTR(REPLACE(T1.D_BEGINDATE,'-',''),1,8)                                    AS ST_DATE                                 --开始日期
     , CASE WHEN T1.D_ENDDATE IS NULL OR T1.D_ENDDATE = '20991231' THEN 
              '29991231'
            ELSE
              T1.D_ENDDATE
       END                                                                           AS END_DATE                                --结束日期
     , T1.F_HOLDMIN                                                                  AS MIN_HOLD_AMT                            --最小保有金额
     , T1.F_HOLDMAX                                                                  AS MAX_HOLD_AMT                            --最大保有金额
     , T1.F_RATIO                                                                    AS OTC_TAIL_RATE                           --场外尾随佣金比例
     , NULL                                                                          AS EXCH_TAIL_RATE                          --场内尾随佣金比例
     , T1.C_CALCULATETYPE                                                            AS TAIL_CALCT_MODE                         --尾随佣金计算方式
     , T1.F_MINTAILFARE                                                              AS TAIL_MNP_AMT                            --尾随佣金起付金额
     , T1.L_YEARDAYS                                                                 AS TAIL_YEAR_DAYS                          --尾随佣金年天数
     , T1.C_TAILSEGMENT                                                              AS AGGR_CALCT_FLAG                         --累进计算标志
     , T1.C_UPDATEFLAG                                                               AS UPD_FLAG                                --更新标志
     , T1.F_AGENCYFEERATIO                                                           AS SALE_FEE_RATE                           --销售费用比例
     , T1.C_FOFEXTERNALRATIOFLAG                                                     AS FOF_EXT_RATE_FLAG                       --FOF外部比例标志
     , CASE WHEN T1.C_TAILRATIONTYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TAILRATIONTYPE)) 
        END                                                                           AS TAIL_RATE_TYPE_CODE                     --尾随佣金比例类型代码
     , T1.F_MANAGERRATIO                                                             AS MGR_RATE                                --管理人比例
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD'                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD T1  --尾随佣金比例  
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_TAILRATIONTYPE'
   AND T1.C_TAILRATIONTYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T1.C_CUSTTYPE = '*'
;

--处理新表FTA最新一天的全部数据
INSERT INTO DWDXDAY.DWD_PROD_PROD_TAIL_PFD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , NULL                                                                          AS SPON_FLAG                               --发起标志
     , SUBSTR(REPLACE(T1.D_BEGINDATE,'-',''),1,8)                                    AS ST_DATE                                 --开始日期
     , '29991231'                                                                    AS END_DATE                                --结束日期
     , T1.F_SHAREMIN                                                                 AS MIN_HOLD_AMT                            --最小保有金额
     , T1.F_SHAREMAX                                                                 AS MAX_HOLD_AMT                            --最大保有金额
     , T1.F_RATIO                                                                    AS OTC_TAIL_RATE                           --场外尾随佣金比例
     , T1.F_RATIO1                                                                   AS EXCH_TAIL_RATE                          --场内尾随佣金比例
     , NULL                                                                          AS TAIL_CALCT_MODE                         --尾随佣金计算方式
     , NULL                                                                          AS TAIL_MNP_AMT                            --尾随佣金起付金额
     , NULL                                                                          AS TAIL_YEAR_DAYS                          --尾随佣金年天数
     , NULL                                                                          AS AGGR_CALCT_FLAG                         --累进计算标志
     , NULL                                                                          AS UPD_FLAG                                --更新标志
     , NULL                                                                          AS SALE_FEE_RATE                           --销售费用比例
     , T1.C_ENABLEEXTERNALRATIO                                                      AS FOF_EXT_RATE_FLAG                       --FOF外部比例标志
     , NULL                                                                          AS TAIL_RATE_TYPE_CODE                     --尾随佣金比例类型代码
     , NULL                                                                          AS MGR_RATE                                --管理人比例
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TSUBTACUSTTAILRATIO_PFD'                                           AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTACUSTTAILRATIO_PFD T1  --尾随佣金比例 
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T3 --渠道基本信息
    ON T3.CHNL_INCD = T1.C_AGENCYNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

--旧表全部数据
INSERT INTO DWDXDAY.DWD_PROD_PROD_TAIL_PFD_TMP PARTITION(P_DT = '${p_end_dt}')
SELECT T1.PROD_NUM                                                            AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                           AS PROD_CODE                               --产品代码
     , T1.CHNL_NUM                                                            AS CHNL_NUM                                --渠道编码
     , T1.CHNL_INCD                                                           AS CHNL_INCD                               --渠道内码
     , T1.CUST_TYPE_CODE                                                      AS CUST_TYPE_CODE                          --客户类型代码
     , T1.SPON_FLAG                                                           AS SPON_FLAG                               --发起标志
     , T1.ST_DATE                                                             AS ST_DATE                                 --开始日期
     , T1.END_DATE                                                            AS END_DATE                                --结束日期
     , T1.MIN_HOLD_AMT                                                        AS MIN_HOLD_AMT                            --最小保有金额
     , T1.MAX_HOLD_AMT                                                        AS MAX_HOLD_AMT                            --最大保有金额
     , T1.OTC_TAIL_RATE                                                       AS OTC_TAIL_RATE                           --场外尾随佣金比例
     , T1.EXCH_TAIL_RATE                                                      AS EXCH_TAIL_RATE                          --场内尾随佣金比例
     , T1.TAIL_CALCT_MODE                                                     AS TAIL_CALCT_MODE                         --尾随佣金计算方式
     , T1.TAIL_MNP_AMT                                                        AS TAIL_MNP_AMT                            --尾随佣金起付金额
     , T1.TAIL_YEAR_DAYS                                                      AS TAIL_YEAR_DAYS                          --尾随佣金年天数
     , T1.AGGR_CALCT_FLAG                                                     AS AGGR_CALCT_FLAG                         --累进计算标志
     , T1.UPD_FLAG                                                            AS UPD_FLAG                                --更新标志
     , T1.SALE_FEE_RATE                                                       AS SALE_FEE_RATE                           --销售费用比例
     , T1.FOF_EXT_RATE_FLAG                                                   AS FOF_EXT_RATE_FLAG                       --FOF外部比例标志
     , T1.TAIL_RATE_TYPE_CODE                                                 AS TAIL_RATE_TYPE_CODE                     --尾随佣金比例类型代码
     , T1.MGR_RATE                                                            AS MGR_RATE                                --管理人比例
     , T1.SSYS                                                                AS SSYS                                    --源系统
     , T1.SRC_TAB                                                             AS SRC_TAB                                 --源表
     , T1.LD_TIME                                                             AS LD_TIME                                 --加载时间
     , T1.MODIFY_TIME                                                         AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_PROD_TAIL_PFD T1
 WHERE T1.SRC_TAB IN ('ODS_HSZTA_TTAILRATIO_PFD','ODS_HSFTA_TSUBTATAILRATIO_PFD')
   AND T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
;

--正式表
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_TAIL_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT T1.PROD_NUM                                                            AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                           AS PROD_CODE                               --产品代码
     , T1.CHNL_NUM                                                            AS CHNL_NUM                                --渠道编码
     , T1.CHNL_INCD                                                           AS CHNL_INCD                               --渠道内码
     , T1.CUST_TYPE_CODE                                                      AS CUST_TYPE_CODE                          --客户类型代码
     , T1.SPON_FLAG                                                           AS SPON_FLAG                               --发起标志
     , T1.ST_DATE                                                             AS ST_DATE                                 --开始日期
     , COALESCE(DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(
                LEAD(T1.ST_DATE,1) OVER(PARTITION BY T1.PROD_NUM,T1.CUST_TYPE_CODE,T1.CHNL_NUM,T1.MIN_HOLD_AMT,T1.SSYS 
                ORDER BY T1.SRC_TAB DESC,T1.ST_DATE),'yyyyMMdd'))),1),'yyyyMMdd'),
                T1.END_DATE)                                                  AS END_DATE                                --结束日期
     , T1.MIN_HOLD_AMT                                                        AS MIN_HOLD_AMT                            --最小保有金额
     , T1.MAX_HOLD_AMT                                                        AS MAX_HOLD_AMT                            --最大保有金额
     , T1.OTC_TAIL_RATE                                                       AS OTC_TAIL_RATE                           --场外尾随佣金比例
     , T1.EXCH_TAIL_RATE                                                      AS EXCH_TAIL_RATE                          --场内尾随佣金比例
     , T1.TAIL_CALCT_MODE                                                     AS TAIL_CALCT_MODE                         --尾随佣金计算方式
     , T1.TAIL_MNP_AMT                                                        AS TAIL_MNP_AMT                            --尾随佣金起付金额
     , T1.TAIL_YEAR_DAYS                                                      AS TAIL_YEAR_DAYS                          --尾随佣金年天数
     , T1.AGGR_CALCT_FLAG                                                     AS AGGR_CALCT_FLAG                         --累进计算标志
     , T1.UPD_FLAG                                                            AS UPD_FLAG                                --更新标志
     , T1.SALE_FEE_RATE                                                       AS SALE_FEE_RATE                           --销售费用比例
     , T1.FOF_EXT_RATE_FLAG                                                   AS FOF_EXT_RATE_FLAG                       --FOF外部比例标志
     , T1.TAIL_RATE_TYPE_CODE                                                 AS TAIL_RATE_TYPE_CODE                     --尾随佣金比例类型代码
     , T1.MGR_RATE                                                            AS MGR_RATE                                --管理人比例
     , T1.SSYS                                                                AS SSYS                                    --源系统
     , T1.SRC_TAB                                                             AS SRC_TAB                                 --源表
     , T1.LD_TIME                                                             AS LD_TIME                                 --加载时间
     , T1.MODIFY_TIME                                                         AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_PROD_PROD_TAIL_PFD_TMP T1
 WHERE T1.P_DT = '${p_end_dt}'
;
--清空临时表
TRUNCATE TABLE DWDXDAY.DWD_PROD_PROD_TAIL_PFD_TMP;
"
