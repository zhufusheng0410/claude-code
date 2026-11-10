#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
    set hive.strict.checks.type.safety=false;
-- **************************************************************************
-- ** 主题:渠道
-- ** 描述:交易归属网点
-- ** 创建者:auto
-- ** 创建日期:2023-08-10
-- ** 修改日志:
-- ** 2023-08-10，auto，新建
-- ** 目标表：DWSXDAY.DWS_TRAN_AFFI_BTCH_PTD  交易归属网点
-- ** 源表：  DWDXDAY.DWD_TRAN_MKT_TRAN_CNFM_PTD 交易确认
-- **         DWDXDAY.DWD_CMM_AREA_INFO_PFD 区域信息
-- **         ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD 网点视图
-- **************************************************************************
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWSXDAY.DWS_TRAN_AFFI_BTCH_PTD PARTITION(P_DT )
SELECT T1.CNFM_DATE           AS CNFM_DATE          -- 确认日期
     , T1.CNFM_NO             AS CNFM_NO            -- 确认号
     , T1.REQ_NO              AS REQ_NO             -- 申请单号
     , T1.CHNL_NUM            AS CHNL_NUM           -- 渠道编码
     , T1.CHNL_INCD           AS CHNL_INCD          -- 渠道内码
     , T1.OPER_BTCH_INCD      AS OPER_BTCH_INCD     -- 操作网点内码
     , T1.PART_CODE           AS PART_CODE          -- 合作方代码
     , T1.PROD_NUM            AS PROD_NUM           -- 产品编码
     , T1.PROD_CODE           AS PROD_CODE          -- 产品代码
     , T1.TRAN_ACCO           AS TRAN_ACCO          -- 交易账号
     , T1.FUND_ACCO           AS FUND_ACCO          -- 基金账号
     , T1.BUSIN_TYPE_CODE     AS BUSIN_TYPE_CODE    -- 业务类型代码
     , T1.BUSIN_TYPE_NAME     AS BUSIN_TYPE_NAME    -- 业务类型名称
     , T1.CUST_NUM            AS CUST_NUM           -- 客户编码
     , T1.CITY_CODE           AS CITY_CODE          -- 城市代码
     , T1.CPTL_MODE_CODE      AS CPTL_MODE_CODE     -- 资金方式代码
     , T1.MEMO                AS MEMO               -- 备注
     , T1.AFFI_BTCH_NUM       AS AFFI_BTCH_NUM      -- 归属网点编码
     , T1.AFFI_BTCH_NAME      AS AFFI_BTCH_NAME     -- 归属网点名称
     , T1.AREA_CODE           AS AFFI_AREA_CODE     -- 区域代码
     , T2.CITY_CODE           AS AFFI_CITY_CODE     -- 城市代码 
     , T2.CITY_NAME           AS AFFI_CITY_NAME     -- 城市名称
     , T2.PROVINCE_CODE       AS AFFI_PROVINCE_CODE -- 省份代码
     , T2.PROVINCE_NAME       AS AFFI_PROVINCE_NAME -- 省份名称
     , T1.SPLIT_RULE_CODE     AS SPLIT_RULE_CODE    -- 拆分规则代码
     , T1.SPLIT_RULE_NAME     AS SPLIT_RULE_NAME    -- 拆分规则名称
     , T1.SSYS                AS SSYS               -- 源系统
     , T1.P_DT                AS P_DT
  FROM ( 
       SELECT T1.CNFM_DATE                   AS CNFM_DATE          -- 确认日期
            , T1.TA_CNFM_NO                  AS CNFM_NO            -- 确认号
            , T1.REQ_NO                      AS REQ_NO             -- 申请单号
            , T1.CHNL_NUM                    AS CHNL_NUM           -- 渠道编码
            , T1.AGENCY_INCD                 AS CHNL_INCD          -- 渠道内码
            , T1.OPER_BTCH_NO                AS OPER_BTCH_INCD     -- 操作网点内码
            , T1.PART_CODE                   AS PART_CODE          -- 合作方代码
            , T1.PROD_NUM                    AS PROD_NUM           -- 产品编码
            , T1.PROD_CODE                   AS PROD_CODE          -- 产品代码
            , T1.TRAN_ACCO                   AS TRAN_ACCO          -- 交易账号
            , T1.FUND_ACCO                   AS FUND_ACCO          -- 交易账号
            , T1.BUSIN_TYPE_CODE             AS BUSIN_TYPE_CODE    -- 业务类型代码
            , T14.STD_DICT_CLS_CDVAL_DESC    AS BUSIN_TYPE_NAME    -- 业务类型名称
            , T1.CUST_NUM                    AS CUST_NUM           -- 客户编码
            , T1.CITY_NO                     AS CITY_CODE          -- 城市代码
            , T1.CPTL_MODE_CODE              AS CPTL_MODE_CODE     -- 资金方式代码
            , T1.MEMO                        AS MEMO               -- 备注
            , CASE WHEN T1.AGENCY_INCD = '005' THEN COALESCE(T2.SK_AGENCY,T13.SK_AGENCY)  -- 005 建设银行
                   WHEN T1.AGENCY_INCD = '002' THEN COALESCE(T3.SK_AGENCY,T15.SK_AGENCY,T18.SK_AGENCY)  -- 002 工商银行
                   WHEN T1.AGENCY_INCD = '004' THEN NVL(T7.SK_AGENCY,T13.SK_AGENCY)  -- 004 中国银行
                   WHEN T1.AGENCY_INCD  IN ('009','604','019') THEN NVL(T9.SK_AGENCY,T13.SK_AGENCY)   -- 009 浦发银行 604 招商证券 019 广发银行
                   WHEN T1.AGENCY_INCD  IN('006','601') THEN NVL(T10.SK_AGENCY,T13.SK_AGENCY)  -- 006 交通银行 601 国泰君安证券
                   WHEN T1.AGENCY_INCD = '608' THEN NVL(T11.SK_AGENCY,T13.SK_AGENCY)  -- 608 海通证券
                   WHEN T1.AGENCY_INCD = '613' THEN T12.SK_AGENCY  -- 613 兴业证券
                   WHEN T1.AGENCY_INCD = '007' THEN COALESCE(T2.SK_AGENCY,T16.SK_AGENCY,T13.SK_AGENCY) -- 007 招商银行
                   WHEN T1.AGENCY_INCD = '261' THEN NVL(T17.SK_AGENCY,T13.SK_AGENCY)  -- 261 直销
                   ELSE NVL(T2.SK_AGENCY,T13.SK_AGENCY)
              END AS AFFI_BTCH_NUM
           ,  CASE WHEN T1.AGENCY_INCD = '005' THEN COALESCE(T2.AGENCY_BRANCH_NAME,T13.AGENCY_BRANCH_NAME)  -- 005 建设银行
                   WHEN T1.AGENCY_INCD = '002' THEN COALESCE(T3.AGENCY_BRANCH_NAME,T15.AGENCY_BRANCH_NAME,T18.AGENCY_BRANCH_NAME)  -- 002 工商银行
                   WHEN T1.AGENCY_INCD = '004' THEN NVL(T7.AGENCY_BRANCH_NAME,T13.AGENCY_BRANCH_NAME)  -- 004 中国银行
                   WHEN T1.AGENCY_INCD IN ('009','604','019') THEN NVL(T9.AGENCY_BRANCH_NAME,T13.AGENCY_BRANCH_NAME)  -- 009 浦发银行 604 招商证券 019 广发银行
                   WHEN T1.AGENCY_INCD IN('006','601')  THEN NVL(T10.AGENCY_BRANCH_NAME,T13.AGENCY_BRANCH_NAME)  -- 006 交通银行 601 国泰君安证券
                   WHEN T1.AGENCY_INCD = '608' THEN NVL(T11.AGENCY_BRANCH_NAME,T13.AGENCY_BRANCH_NAME)  -- 608 海通证券
                   WHEN T1.AGENCY_INCD = '613' THEN T12.AGENCY_BRANCH_NAME  -- 613 兴业证券
                   WHEN T1.AGENCY_INCD = '007' THEN COALESCE(T2.AGENCY_BRANCH_NAME,T16.AGENCY_BRANCH_NAME,T13.AGENCY_BRANCH_NAME)  -- 007 招商银行
                   WHEN T1.AGENCY_INCD = '261' THEN NVL(T17.AGENCY_BRANCH_NAME,T13.AGENCY_BRANCH_NAME)  -- 261 直销
              ELSE NVL(T2.AGENCY_BRANCH_NAME,T13.AGENCY_BRANCH_NAME)
              END AS AFFI_BTCH_NAME
           ,  CASE WHEN T1.AGENCY_INCD = '005' THEN COALESCE(T2.SK_REGION,T13.SK_REGION)  -- 005 建设银行
                   WHEN T1.AGENCY_INCD = '002' THEN COALESCE(T3.SK_REGION,T15.SK_REGION,T18.SK_REGION)  -- 002 工商银行
                   WHEN T1.AGENCY_INCD = '004' THEN NVL(T7.SK_REGION,T13.SK_REGION)  -- 004 中国银行
                   WHEN T1.AGENCY_INCD IN ('009','604','019') THEN NVL(T9.SK_REGION,T13.SK_REGION)  -- 009 浦发银行 604 招商证券 019 广发银行
                   WHEN T1.AGENCY_INCD IN('006','601') THEN NVL(T10.SK_REGION,T13.SK_REGION)  -- 006 交通银行 601 国泰君安证券
                   WHEN T1.AGENCY_INCD = '608' THEN NVL(T11.SK_REGION,T13.SK_REGION)  -- 608 海通证券
                   WHEN T1.AGENCY_INCD = '613' THEN T12.SK_REGION  -- 613 兴业证券
                   WHEN T1.AGENCY_INCD = '007' THEN COALESCE(T2.SK_REGION,T16.SK_REGION,T13.SK_REGION)  -- 002 工商银行
                   WHEN T1.AGENCY_INCD = '261' THEN NVL(T17.SK_REGION,T13.SK_REGION)  -- 261 直销
                   ELSE NVL(T2.SK_REGION,T13.SK_REGION) 
              END AS AREA_CODE
            , NULL                     AS  SPLIT_RULE_CODE  --拆分规则代码
            , CASE WHEN T2.AGENCY_BRANCH_NAME IS NOT NULL THEN 'N-按操作网点拆分'  --按操作网点拆分
                   WHEN T3.AGENCY_BRANCH_NAME IS NOT NULL THEN 'N-工商银行按操作网点拆分'  --按操作网点拆分
                   WHEN T7.AGENCY_BRANCH_NAME IS NOT NULL THEN 'B-中国银行网点按备注拆分'  --按备注拆分
                   WHEN T9.AGENCY_BRANCH_NAME IS NOT NULL THEN 'T-浦发银行、招商证券、广发银行按交易账号拆分'  --按交易账号拆分
                   WHEN T10.AGENCY_BRANCH_NAME IS NOT NULL THEN 'T-交通银行、国泰君安证券按交易账号拆分'  --按交易账号拆分
                   WHEN T11.AGENCY_BRANCH_NAME IS NOT NULL THEN 'T-海通证券按交易账号拆分'  --按交易账号拆分
                   WHEN T12.AGENCY_BRANCH_NAME IS NOT NULL THEN 'T-兴业证券 按交易账号拆分'  --按操作网点拆分
                   WHEN T15.AGENCY_BRANCH_NAME IS NOT NULL THEN 'R-工商银行申请单号'  --按申请单号拆分
                   WHEN T17.AGENCY_BRANCH_NAME IS NOT NULL THEN 'N-直销网点拆分'  --按资金方式拆分
                   WHEN T18.AGENCY_BRANCH_NAME IS NOT NULL THEN 'T-工商银行按交易账号拆分'  --按交易账号拆分
                   WHEN T13.AGENCY_BRANCH_NAME IS NOT NULL THEN 'AGENCYNO-按经销商拆分'  --按经销商拆分
                   ELSE '' 
               END AS SPLIT_RULE_NAME    --拆分规则名称 
            , T1.SSYS
            , T1.P_DT
         FROM DWDXDAY.DWD_TRAN_MKT_TRAN_CNFM_PTD T1 --市场交易确认
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T14  --标准字典分类枚举信息
           ON T1.BUSIN_TYPE_CODE = T14.STD_DICT_CLS_CDVAL
          AND T14.STD_DICT_CLS_CD = 'BUSIN_TYPE_CODE'
          AND T14.VALID_FLAG = '1'
         LEFT JOIN  ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T2   
           ON T1.OPER_BTCH_NO = T2.AGENCY_NETNO     --建设银行 005   中信银行 008 没有省份  平安银行 020 没有省市  614 长江证券
          AND T1.AGENCY_INCD = T2.AGENCYNO
          AND T2.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T2.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
          AND T2.AGENCYNO != '002'  
         LEFT JOIN ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T3
           ON T1.OPER_BTCH_NO = T3.AGENCY_NETNO 
          AND T1.AGENCY_INCD = T3.AGENCYNO
          AND T1.CITY_NO = T3.AGENCY_AREA_CODE     
          AND T3.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T3.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
          AND T3.AGENCYNO = '002'  --工商银行 002
         LEFT JOIN ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T15
           ON SUBSTR(T1.REQ_NO,5,4) = T15.AGENCY_NETNO 
          AND T1.AGENCY_INCD = T15.AGENCYNO
          AND SUBSTR(T1.REQ_NO,1,4) = T15.AGENCY_AREA_CODE     
          AND T15.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T15.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T15.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
          AND T15.AGENCYNO = '002'  --工商银行 002  按申请单拆分
         LEFT JOIN (SELECT ROW_NUMBER () OVER(PARTITION BY T.AGENCY_AREA_CODE ORDER BY AGENCY_LEVEL )RN
                        , T.BK_AGENCY
                        , T.SK_AGENCY
                        , T.AGENCY_BRANCH_NAME
                        , T.AGENCY_AREA_CODE 
                        , T.AGENCYNO
                        , T.EFFECTIVE_FROM
                        , T.EFFECTIVE_TO
                        , T.SK_REGION
                      FROM ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T  
                     WHERE T.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
                       AND T.AGENCYNO = '002'  --工商银行 002 
                   ) T18
           ON  SUBSTR(T1.TRAN_ACCO,5,4)  = T18.AGENCY_AREA_CODE  
          AND T1.AGENCY_INCD = T18.AGENCYNO
          AND T18.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T18.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T18.AGENCYNO = '002'   --工商银行 002 按交易账户拆分 
          AND T18.RN = 1
         LEFT JOIN ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T7
           ON T1.MEMO = SUBSTR(T7.BK_AGENCY,7,5)  
          AND T1.AGENCY_INCD = T7.AGENCYNO
          AND T7.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T7.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T7.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
          AND T7.AGENCYNO = '004'   --004 中国银行 分行
         LEFT JOIN ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T9 
           ON SUBSTR(T1.TRAN_ACCO,1,2) = NVL(T9.AGENCY_NETNO,T9.AGENCY_AREA_CODE)  
          AND T1.AGENCY_INCD = T9.AGENCYNO
          AND T9.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T9.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T9.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
          AND T9.AGENCYNO IN('009','604','019')  --009 浦发银行 604 招商证券 019 广发银行
         LEFT JOIN ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T10
           ON  SUBSTR(T1.TRAN_ACCO,4,4)  =  CASE WHEN  T10.AGENCYNO = '601' THEN  SUBSTR(T10.BK_AGENCY,7,4) ELSE SUBSTR(T10.BK_AGENCY,6,4) END   
          AND T1.AGENCY_INCD = T10.AGENCYNO
          AND T10.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T10.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
          AND T10.AGENCYNO IN('006','601')   --006 交通银行 601 国泰君安证券 
         LEFT JOIN ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD  T11
           ON CASE WHEN  SUBSTR(T1.TRAN_ACCO,1,3)= '608' 
                   THEN SUBSTR(T1.TRAN_ACCO,4,4)
              ELSE SUBSTR(T1.TRAN_ACCO,1,4) 
              END = T11.AGENCY_NETNO   -- 608 海通证券
          AND T1.AGENCY_INCD = T11.AGENCYNO
          AND T11.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T11.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T11.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
          AND T11.AGENCYNO = '608' -- 608 海通证券
         LEFT JOIN  ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T12   
           ON SUBSTR(T1.TRAN_ACCO,6,2) = NVL(T12.AGENCY_NETNO,T12.AGENCY_AREA_CODE)      --613  兴业证券
          AND T1.AGENCY_INCD = T12.AGENCYNO
          AND T12.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T12.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T12.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
          AND T12.AGENCYNO = '613' 
         LEFT JOIN (SELECT ROW_NUMBER () OVER(PARTITION BY AGENCYNO ORDER BY AGENCY_LEVEL )RN
                         , T.BK_AGENCY
                         , T.SK_AGENCY
                         , T.AGENCY_BRANCH_NAME
                         , T.AGENCYNO 
                         , T.SK_REGION 
                         , T.EFFECTIVE_FROM
                         , T.EFFECTIVE_TO
                      FROM ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T  
                     WHERE T.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
                       AND T.AGENCY_LEVEL = '1'
                  )T13
           ON T1.AGENCY_INCD = T13.AGENCYNO             --按经销商代码
          AND T13.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T13.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T13.RN = 1
         LEFT JOIN ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T16
           ON T1.BROKER = T16.AGENCY_NETNO
          AND T1.AGENCY_INCD = T16.AGENCYNO
          AND T16.EFFECTIVE_FROM <= T1.CNFM_DATE 
          AND T16.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T16.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
          AND T16.AGENCYNO = '007'  --招商银行 007
         LEFT JOIN ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD T17
           ON (T1.OPER_BTCH_NO = SUBSTR(T17.BK_AGENCY,7) OR T1.PART_CODE = SUBSTR(T17.BK_AGENCY,7))
          AND T1.AGENCY_INCD = T17.AGENCYNO
          AND T17.EFFECTIVE_FROM <= T1.CNFM_DATE
          AND T17.EFFECTIVE_TO >= T1.CNFM_DATE
          AND T17.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
          AND T17.AGENCYNO = '261'  --直销 261
        WHERE T1.P_DT BETWEEN '${p_strar_dt}'  AND  '${p_end_dt}'
       )T1
  LEFT JOIN  DWDXDAY.DWD_CMM_AREA_INFO_PFD T2
    ON T1.AREA_CODE = T2.AREA_CODE
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
;
"