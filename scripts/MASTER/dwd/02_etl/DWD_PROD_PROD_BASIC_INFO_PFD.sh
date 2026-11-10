#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题: 产品
-- ** 描述: 产品基本信息
-- ** 创建者 : zhufs
-- ** 创建日期: 20230425
-- ** 修改日志:
-- ** 20230425，zhufs，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD 产品基本信息
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDINFO_PFD 基金信息表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD 基金信息表
-- **         ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD 分级基金
-- **         ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD 专户手工信息
--**          DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_DWD_PROD_PROD_BASIC_INFO_PFD 产品基本信息
-- **         DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  机构编码映射
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
     
INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT
       T2.PROD_NUM                                          AS PROD_NUM       --产品编码
     , T1.C_FUNDCODE                                        AS PROD_CODE      --产品代码
     , CASE WHEN T1.C_MAINFUNDCODE IS NOT NULL  
            THEN T1.C_MAINFUNDCODE
            WHEN T4.VC_JJDM IS NOT NULL
            THEN T4.VC_JJDM
            ELSE T1.C_FUNDCODE
       END                                                  AS MAIN_PROD_CODE --主产品代码
     , CASE WHEN T1.C_FUNDCODE = T1.C_MAINFUNDCODE
            THEN 1
            WHEN T1.C_MAINFUNDCODE IS NOT NULL AND T1.C_FUNDCODE <> T1.C_MAINFUNDCODE
            THEN 0
            WHEN T1.C_FUNDCODE = T4.VC_JJDM 
            THEN 1
            WHEN T4.VC_JJDM IS NOT NULL AND T1.C_FUNDCODE <> T4.VC_JJDM
            THEN 0
            WHEN T1.C_FUNDCODE IS NOT NULL
            THEN 1
            ELSE 0
       END                                                  AS MAIN_PROD_FLAG  --主产品标志
     , COALESCE(T1.C_FUNDSHORTNAME,T1.C_FUNDNAME)           AS CSNAME          --中文简称
     , T1.C_FUNDNAME                                        AS CNAME           --中文全称
     , T1.C_FUNDENGLISHNAME                                 AS ESNAME          --英文简称
     , NULL                                                 AS ENAME           --英文全称
     , CASE WHEN T1.C_FUNDTYPE IS NOT NULL 
            THEN COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUNDTYPE)) 
       END                                                   AS PROD_CATG_CODE  --产品类别代码
     , CASE WHEN T4.VC_FJJB IS NOT NULL 
            THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T4.VC_FJJB)) 
       END                                                   AS SHARE_CATG_CODE --份额类别代码
     , CASE WHEN T4.L_YXBZ IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T4.L_YXBZ))
            WHEN T1.C_FUNDSHORTNAME LIKE '%优先%'
            THEN '02'
            WHEN T1.C_FUNDSHORTNAME LIKE '%进取%'
            THEN '03'
       END                                                  AS CLAS_CATG_CODE  --分级类别代码
     , NULL                                                 AS MGR_NUM         --管理人编码
     , T1.C_MANAGERNAME                                     AS MGR_NAME        --管理人名称
     , T11.ORG_NUM                                          AS TRUS_NUM        --托管人编码
     , T1.C_TRUSTEECODE                                     AS TRUS_INCD       --托管人内码
     , T11.ORG_NAME                                         AS TRUS_NAME       --托管人名称
     , CASE WHEN T1.C_FUNDSTATUS IS NOT NULL 
            THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUNDSTATUS)) 
       END                                                  AS PROD_STAT_CODE  --产品状态代码
     , T1.D_SETUPDATE                                       AS PROD_SETUP_DATE --产品成立日期
     , T1.D_FAILUEDATE                                      AS PROD_END_DATE   --产品结束日期
     , T1.D_ISSUEDATE                                       AS RAIS_ST_DATE    --募集开始日期
     , T1.D_ISSUEENDDATE                                    AS RAIS_END_DATE   --募集结束日期
     , CASE WHEN T1.C_FUNDSTATUS = 9 
            THEN T1.D_FAILUEDATE
            ELSE NULL
       END                                                  AS RAIS_FAIL_DATE  --募集失败日期
     , CASE WHEN T1.C_MONEYTYPE IS NOT NULL 
            THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MONEYTYPE)) 
       END                                                  AS PR_CRRC_CODE    --申赎币种代码
     , T1.F_PARVALUE                                        AS INIT_PARV       --初始面额
     , '1'                                                  AS INIT_UNIT_NAV   --初始单位净值
     , T12.INIT_SCALE                                       AS SETUP_SCALE     --成立规模
     , T1.F_FACTCOLLECT                                     AS RAIS_AMT        --募集金额
     , CASE WHEN T1.C_FUNDTYPE = '0' 
            THEN '61'
            ELSE NULL
        END                                                 AS REG_ORGNO      --注册登记机构代码
     , CASE WHEN T1.C_RISKLEVEL IS NOT NULL 
            THEN COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RISKLEVEL)) 
       END                                                  AS RISK_LVL_CODE  --风险等级代码
     , '1'                                                  AS VALID_FLAG     --有效标志
     , 'HSZTA'                                              AS SSYS           --源系统
     , 'ODS_HSZTA_TFUNDINFO_PFD'                            AS SRC_TAB        --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME --修改时间
 FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDINFO_PFD      T1 --基金信息表
 INNER JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
   ON T1.C_FUNDCODE = T2.PROD_INCD  --产品内码
  AND T2.ST_DATE <= '${p_end_dt}'    -- 开始日期
  AND T2.END_DATE > '${p_end_dt}'    -- 结束日期
  AND T2.SSYS = 'HSZTA'     -- 源系统
  AND T2.SRC_TAB = 'ODS_HSZTA_TFUNDINFO_PFD'
  AND T2.VALID_FLAG = '1'   -- 有效
  AND T2.P_DT = '${p_end_dt}'
 LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD  T4 --分级基金
   ON T1.C_FUNDCODE = T4.VC_FJJJDM  --产品代码
  AND T4.P_DT = '${p_end_dt}'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T5 --标准字典码值映射
   ON T5.SSYS = 'HSFA'
  AND T5.SRC_DICT_CLS_CD = 'VC_FJJB'
  AND T4.VC_FJJB  = T5.SRC_DICT_CLS_CDVAL 
  AND T5.VALID_FLAG = '1'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
   ON T6.SSYS = 'HSFA'
  AND T6.SRC_DICT_CLS_CD = 'L_YXBZ'
  AND T4.L_YXBZ  = T6.SRC_DICT_CLS_CDVAL 
  AND T6.VALID_FLAG = '1'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T7 --标准字典码值映射 
   ON T7.SSYS = 'HSZTA'
  AND T7.SRC_DICT_CLS_CD = 'C_FUNDSTATUS'
  AND T1.C_FUNDSTATUS  = T7.SRC_DICT_CLS_CDVAL 
  AND T7.VALID_FLAG = '1'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射 
   ON T8.SSYS = 'HSZTA'
  AND T8.SRC_DICT_CLS_CD = 'C_MONEYTYPE'
  AND T1.C_MONEYTYPE  = T8.SRC_DICT_CLS_CDVAL 
  AND T8.VALID_FLAG = '1'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T9 --标准字典码值映射 
   ON T9.SSYS = 'HSZTA'
  AND T9.SRC_DICT_CLS_CD = 'C_RISKLEVEL'
  AND T1.C_RISKLEVEL  = T9.SRC_DICT_CLS_CDVAL 
  AND T9.VALID_FLAG = '1'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T10 --标准字典码值映射
   ON T10.SSYS = 'HSZTA'
  AND T10.SRC_DICT_CLS_CD = 'C_FUNDTYPE'
  AND T1.C_FUNDTYPE  = T10.SRC_DICT_CLS_CDVAL 
  AND T10.VALID_FLAG = '1'
 LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  T11 --机构编码映射 
   ON T1.C_TRUSTEECODE = T11.ORG_INCD  --机构内码
  AND T11.ST_DATE <= '${p_end_dt}'    -- 开始日期
  AND T11.END_DATE > '${p_end_dt}'    -- 结束日期
  AND T11.SSYS = 'HSZTA'     -- 源系统
  AND T11.SRC_TAB = 'ODS_HSZTA_TDICTIONARY_PFD'  -- 源表
  AND T11.VALID_FLAG = '1'   -- 有效
 --AND T11.P_DT = '${p_end_dt}'
 LEFT JOIN  ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD T12  --专户手工信息
   ON T1.C_FUNDCODE = T12.PROD_CODE
  AND T12.P_DT = '${p_end_dt}'
WHERE T1.P_DT = '${p_end_dt}'
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT  
       T2.PROD_NUM                                                         AS PROD_NUM          --产品编码
     , T1.C_FUNDCODE                                                       AS PROD_CODE         --产品代码
     , CASE WHEN T1.C_MAINFUNDCODE IS NOT NULL  
            THEN T1.C_MAINFUNDCODE
            WHEN T4.VC_JJDM IS NOT NULL
            THEN T4.VC_JJDM
            ELSE T1.C_FUNDCODE
       END                                                                 AS MAIN_PROD_CODE    --主产品代码
     , CASE WHEN T1.C_FUNDCODE = T1.C_MAINFUNDCODE
            THEN 1
            WHEN T1.C_MAINFUNDCODE IS NOT NULL AND T1.C_FUNDCODE <> T1.C_MAINFUNDCODE
            THEN 0
            WHEN T4.VC_JJDM = T1.C_FUNDCODE
            THEN 1
            WHEN T4.VC_JJDM IS NOT NULL AND T1.C_FUNDCODE <> T4.VC_JJDM
            THEN 0
            WHEN T1.C_FUNDCODE IS NOT NULL
            THEN 1
            ELSE 0
       END                                                                 AS MAIN_PROD_FLAG     --主产品标志
     , COALESCE(T1.C_FUNDSHORTNAME,T1.C_FUNDNAME)                          AS CSNAME             --中文简称
     , T1.C_FUNDNAME                                                       AS CNAME              --中文全称
     , T1.C_FUNDENGLISHNAME                                                AS ESNAME             --英文简称
     , NULL                                                                AS ENAME              --英文全称
     , 'GM'                                                                AS PROD_CATG_CODE     --产品类别代码
     , CASE WHEN T4.VC_FJJB IS NOT NULL 
            THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T4.VC_FJJB)) 
       END                                                                 AS SHARE_CATG_CODE    --份额类别代码
     , CASE WHEN T4.L_YXBZ IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T4.L_YXBZ)) 
            WHEN T1.C_FUNDSHORTNAME LIKE '%优先%'
            THEN '02'
            WHEN T1.C_FUNDSHORTNAME LIKE '%进取%'
            THEN '03'
       END                                                                  AS CLAS_CATG_CODE     --分级类别代码
     , NULL                                                                 AS MGR_NUM            --管理人编码
     , T1.C_MANAGERNAME                                                     AS MGR_NAME           --管理人名称
     , T11.ORG_NUM                                                          AS TRUS_NUM           --托管人编码
     , T1.C_TRUSTEECODE                                                     AS TRUS_INCD          --托管人内码
     , T11.ORG_NAME                                                         AS TRUS_NAME          --托管人名称
     , CASE WHEN T1.C_FUNDSTATUS IS NOT NULL 
            THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUNDSTATUS)) 
       END                                                                   AS PROD_STAT_CODE     --产品状态代码
     , SUBSTR(REPLACE(T1.D_SETUPDATE,'-',''),1,8)                            AS PROD_SETUP_DATE    --产品成立日期
     , SUBSTR(REPLACE(T1.D_FAILUEDATE ,'-',''),1,8)                          AS PROD_END_DATE      --产品结束日期
     , SUBSTR(REPLACE(T1.D_ISSUEDATE,'-',''),1,8)                            AS RAIS_ST_DATE       --募集开始日期
     , SUBSTR(REPLACE(T1.D_ISSUEENDDATE,'-',''),1,8)                         AS RAIS_END_DATE      --募集结束日期
     , CASE WHEN T1.C_FUNDSTATUS = 9 
            THEN T1.D_FAILUEDATE
            ELSE NULL
       END                                                                    AS RAIS_FAIL_DATE    --募集失败日期
     , CASE WHEN T1.C_MONEYTYPE IS NOT NULL 
            THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MONEYTYPE)) 
       END                                                                     AS PR_CRRC_CODE      --申赎币种代码
     , T1.F_PARVALUE                                                           AS INIT_PARV         --初始面额
     , '1'                                                                     AS INIT_UNIT_NAV     --初始单位净值
     , T12.INIT_SCALE                                                          AS SETUP_SCALE       --成立规模
     , T1.F_FACTCOLLECT                                                        AS RAIS_AMT          --募集金额
     , '98'                                                                    AS REG_ORGNO         --注册登记机构代码
     , CASE WHEN T1.C_RISKCLASS IS NOT NULL 
            THEN COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RISKCLASS)) 
       END                                                                      AS RISK_LVL_CODE     --风险等级代码
     , '1'                                                                      AS VALID_FLAG        --有效标志
     , 'HSFTA'                                                                  AS SSYS              --源系统
     , 'ODS_HSFTA_TFUNDINFO_PFD'                                                AS SRC_TAB           --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME           --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME       --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD  T1 --基金信息表
 INNER JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD  T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD  --产品内码
   AND T2.ST_DATE <= '${p_end_dt}'    -- 开始日期
   AND T2.END_DATE > '${p_end_dt}'    -- 结束日期
   AND T2.SSYS = 'HSFTA'     -- 源系统
   AND T2.SRC_TAB = 'ODS_HSFTA_TFUNDINFO_PFD'
   AND T2.VALID_FLAG = '1'   -- 有效
   AND T2.P_DT = '${p_end_dt}'  
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息
    ON T2.PROD_NUM = T3.PROD_NUM
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = '${p_end_dt}' 
   AND T3.SSYS <> 'HSFTA'     -- 源系统
  LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD T4 --分级基金 
    ON T1.C_FUNDCODE = T4.VC_FJJJDM  --产品代码
   AND T4.P_DT = '${p_end_dt}' 
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T5 --标准字典码值映射 
    ON T5.SSYS = 'HSFA'
   AND T5.SRC_DICT_CLS_CD = 'VC_FJJB'
   AND T4.VC_FJJB  = T5.SRC_DICT_CLS_CDVAL 
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T6 --标准字典码值映射 
    ON T6.SSYS = 'HSFA'
   AND T6.SRC_DICT_CLS_CD = 'L_YXBZ'
   AND T4.L_YXBZ  = T6.SRC_DICT_CLS_CDVAL 
   AND T6.VALID_FLAG ='1'
 LEFT JOIN  DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  T11 --机构编码映射 
   ON T1.C_TRUSTEECODE = T11.ORG_INCD  --机构内码
  AND T11.ST_DATE <= '${p_end_dt}'    -- 开始日期
  AND T11.END_DATE > '${p_end_dt}'    -- 结束日期
  AND T11.SSYS = 'HSZTA'     -- 源系统
  AND T11.SRC_TAB = 'ODS_HSZTA_TDICTIONARY_PFD'  -- 源表
  AND T11.VALID_FLAG = '1'   -- 有效
  --AND T11.P_DT = '${p_end_dt}'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T7 --标准字典码值映射 
   ON T7.SSYS = 'HSFTA'
  AND T7.SRC_DICT_CLS_CD = 'C_FUNDSTATUS'
  AND T1.C_FUNDSTATUS  = T7.SRC_DICT_CLS_CDVAL 
  AND T7.VALID_FLAG = '1'
 LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T8 --标准字典码值映射
   ON T8.SSYS = 'HSFTA'
  AND T8.SRC_DICT_CLS_CD = 'C_MONEYTYPE'
  AND T1.C_MONEYTYPE  = T8.SRC_DICT_CLS_CDVAL 
  AND T8.VALID_FLAG = '1'
 LEFT JOIN  DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  T9 --标准字典码值映射 
   ON T9.SSYS = 'HSFTA'
  AND T9.SRC_DICT_CLS_CD = 'C_RISKCLASS'
  AND T1.C_RISKCLASS  = T9.SRC_DICT_CLS_CDVAL 
  AND T9.VALID_FLAG = '1' 
 LEFT JOIN  ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD T12  --专户手工信息
   ON T1.C_FUNDCODE = T12.PROD_CODE
  AND T12.P_DT = '${p_end_dt}'
WHERE T1.P_DT = '${p_end_dt}'
  AND T3.PROD_NUM IS NULL
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                               AS PROD_NUM        --产品编码
     , T1.PROD_CODE                                                              AS PROD_CODE       --产品代码
     , T1.PROD_CODE                                                              AS MAIN_PROD_CODE  --主产品代码
     , '1'                                                                       AS MAIN_PROD_FLAG  --主产品标志
     , T1.PROJECT_NAME                                                           AS CSNAME          --中文简称
     , T1.PROJECT_NAME                                                           AS CNAME           --中文全称
     ,  NULL                                                                     AS ESNAME          --英文简称
     ,  NULL                                                                     AS ENAME           --英文全称
     ,  'ZH'                                                                     AS PROD_CATG_CODE  --产品类别代码
     ,  NULL                                                                     AS SHARE_CATG_CODE --份额类别代码
     ,  NULL                                                                     AS CLAS_CATG_CODE  --分级类别代码
     ,  NULL                                                                     AS MGR_NUM         --管理人编码
     , T1.MGR_NAME                                                               AS MGR_NAME        --管理人名称
     , T6.ORG_NUM                                                                AS TRUS_NUM        --托管人编码
     , T4.VC_TGHID                                                               AS TRUS_INCD       --托管人内码
     , T6.ORG_NAME                                                               AS TRUS_NAME       --托管人名称
     , CASE WHEN T1.PROD_STAT IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.PROD_STAT)) 
        END                                                                      AS PROD_STAT_CODE  --产品状态代码
     , SUBSTR(REPLACE(T1.SETUP_DATE,'-',''),1,8)                                 AS PROD_SETUP_DATE --产品成立日期
     , SUBSTR(REPLACE(T1.EXPE_END_DATE ,'-',''),1,8)                             AS PROD_END_DATE   --产品结束日期
     , NULL                                                                      AS RAIS_ST_DATE    --募集开始日期
     , NULL                                                                      AS RAIS_END_DATE   --募集结束日期
     , NULL                                                                      AS RAIS_FAIL_DATE  --募集失败日期
     , NULL                                                                      AS PR_CRRC_CODE    --申赎币种代码
     , NULL                                                                      AS INIT_PARV       --初始面额
     , NULL                                                                      AS INIT_UNIT_NAV   --初始单位净值
     , T1.INIT_SCALE                                                             AS SETUP_SCALE     --成立规模
     , T1.INIT_SCALE                                                             AS RAIS_AMT        --募集金额
     , NULL                                                                      AS REG_ORGNO       --注册登记机构代码
     , CASE WHEN T1.PROD_RISK_LVL IS NOT NULL 
             THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.PROD_RISK_LVL)) 
        END                                                                      AS RISK_LVL_CODE   --风险等级代码
     , '1'                                                                       AS VALID_FLAG      --有效标志
     , 'MANUAL'                                                                  AS SSYS            --源系统
     , 'ODS_MANUAL_SPEBA_MANUAL_INFO_PFD'                                        AS SRC_TAB         --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME         --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME     --修改时间
  FROM ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD  T1  --专户手工信息
 INNER JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD  T2  --产品编码映射
    ON T1.PROD_CODE = T2.PROD_INCD  --产品内码
   AND T2.ST_DATE <= '${p_end_dt}'     -- 开始日期
   AND T2.END_DATE > '${p_end_dt}'     -- 结束日期
   AND T2.SSYS = 'MANUAL'     -- 源系统
   AND T2.SRC_TAB = 'ODS_MANUAL_SPEBA_MANUAL_INFO_PFD'
   AND T2.VALID_FLAG = '1'   -- 有效
   AND T2.P_DT = '${p_end_dt}' 
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD  T3 --产品基本信息
    ON T1.PROD_CODE = T3.PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = '${p_end_dt}'
   AND T3.SSYS <> 'MANUAL'     -- 源系统
  LEFT JOIN (SELECT VC_CODE,VC_TGHID,VC_TGR
               FROM ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD T4 --基金基本信息表
              INNER JOIN ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD T5 --帐套信息
                ON T4.L_FUNDID = T5.L_ID
               AND T5.L_VOID = '0' --有效
               AND T5.P_DT = '${p_end_dt}'
             WHERE T4.P_DT = '${p_end_dt}'
           )T4
    ON T1.PROD_CODE = T4.VC_CODE
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'MANUAL'
   AND T5.SRC_DICT_CLS_CD = 'PROD_STAT'
   AND T1.PROD_STAT = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  T6 --机构编码映射 
    ON T4.VC_TGHID = T6.ORG_INCD  --机构内码
   AND T6.ST_DATE <= '${p_end_dt}'    -- 开始日期
   AND T6.END_DATE > '${p_end_dt}'    -- 结束日期
   AND T6.SSYS = 'HSFA'     -- 源系统
   AND T6.SRC_TAB = 'ODS_HSFA_TDICTIONARY_PFD'  -- 源表
   AND T6.VALID_FLAG = '1'   -- 有效
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'MANUAL'
   AND T7.SRC_DICT_CLS_CD = 'PROD_RISK_LVL'
   AND T1.PROD_RISK_LVL = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}' 
   AND T3.PROD_CODE IS NULL 
;


INSERT INTO DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                       AS PROD_NUM                                --产品编码
     , T1.VC_CODE                                                                        AS PROD_CODE                               --产品代码
     , T1.VC_CODE                                                                        AS MAIN_PROD_CODE                          --主产品代码
     , '1'                                                                               AS MAIN_PROD_FLAG                          --主产品标志
     , COALESCE(T1.VC_NAME,T1.VC_FULLNAME)                                               AS CSNAME                                  --中文简称
     , T1.VC_FULLNAME                                                                    AS CNAME                                   --中文全称
     , NULL                                                                              AS ESNAME                                  --英文简称
     , NULL                                                                              AS ENAME                                   --英文全称
     , CASE WHEN T1.L_CLASS IS NOT NULL                                                  
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_CLASS))                
        END                                                                              AS PROD_CATG_CODE                          --产品类别代码
     , NULL                                                                              AS SHARE_CATG_CODE                         --份额类别代码
     , NULL                                                                              AS CLAS_CATG_CODE                          --分级类别代码
     , T1.VC_GLR                                                                         AS MGR_NUM                                 --管理人编码
     , '信达澳亚基金管理有限公司'                                                        AS MGR_NAME                                --管理人名称
     , T6.ORG_NUM                                                                        AS TRUS_NUM                                --托管人编码
     , T1.VC_TGHID                                                                       AS TRUS_INCD                               --托管人内码
     , T6.ORG_NAME                                                                       AS TRUS_NAME                               --托管人名称
     , CASE WHEN SUBSTR(COALESCE(REPLACE(T1.D_DQRQ ,'-',''),
                                 REPLACE(T5.D_DESTORY ,'-','')) ,1,8) IS NOT NULL 
             THEN '10'  --基金终止
            ELSE  '06'  --正常开放
        END                                                                              AS PROD_STAT_CODE                          --产品状态代码
     , SUBSTR(REPLACE(T1.D_CREATE,'-',''),1,8)                                           AS PROD_SETUP_DATE                         --产品成立日期
     , SUBSTR(COALESCE(REPLACE(T1.D_DQRQ ,'-',''),REPLACE(T5.D_DESTORY ,'-','') ),1,8)   AS PROD_END_DATE                           --产品结束日期
     , NULL                                                                              AS RAIS_ST_DATE                            --募集开始日期
     , NULL                                                                              AS RAIS_END_DATE                           --募集结束日期
     , NULL                                                                              AS RAIS_FAIL_DATE                          --募集失败日期
     , NULL                                                                              AS PR_CRRC_CODE                            --申赎币种代码
     , NULL                                                                              AS INIT_PARV                               --初始面额
     , NULL                                                                              AS INIT_UNIT_NAV                           --初始单位净值
     , T1.EN_MJJE                                                                        AS SETUP_SCALE                             --成立规模
     , NULL                                                                              AS RAIS_AMT                                --募集金额
     , NULL                                                                              AS REG_ORGNO                               --注册登记机构代码
     , NULL                                                                              AS RISK_LVL_CODE                           --风险等级代码
     , '1'                                                                               AS VALID_FLAG                              --有效标志
     , 'HSFA'                                                                            AS SSYS                                    --源系统
     , 'ODS_HSFA_TFUNDINFO_PFD'                                                          AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')          AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')          AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD T1  --基金基本信息表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.L_FUNDID = T2.PROD_INCD --产品内码
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE>'${p_end_dt}' --结束日期
   AND T2.SSYS = 'HSFA' --源系统
   AND T2.SRC_TAB = 'ODS_HSFA_TFUNDINFO_PFD'
   AND T2.VALID_FLAG = '1' --有效
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T3 --产品基本信息
    ON T1.VC_CODE = T3.PROD_CODE
   AND T3.VALID_FLAG = '1'
   AND T3.P_DT = '${p_end_dt}'
   AND T3.SSYS <> 'HSFA'     -- 源系统
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFA'
   AND T4.SRC_DICT_CLS_CD = 'L_CLASS'
   AND T1.L_CLASS = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
 INNER JOIN ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD T5 --帐套信息
    ON T1.L_FUNDID = T5.L_ID
   AND T5.L_VOID = '0' --有效
   AND T5.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  T6 --机构编码映射 
    ON T1.VC_TGHID = T6.ORG_INCD  --机构内码
   AND T6.ST_DATE <= '${p_end_dt}'    -- 开始日期
   AND T6.END_DATE > '${p_end_dt}'    -- 结束日期
   AND T6.SSYS = 'HSFA'     -- 源系统
   AND T6.SRC_TAB = 'ODS_HSFA_TDICTIONARY_PFD'  -- 源表
   AND T6.VALID_FLAG = '1'   -- 有效
WHERE T1.P_DT = '${p_end_dt}' 
  AND T3.PROD_CODE IS NULL
 ;
"
