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
-- ** 描述:市场交易确认
-- ** 创建者:auto
-- ** 创建日期:2023-08-10
-- ** 修改日志:
-- ** 2023-08-10，auto，新建
-- ** 目标表：DWSXDAY.DWS_TRAN_MKT_TRAN_CNFM_PTD  交易账户开户网点
-- ** 源表：  DWDXDAY.DWD_TRAN_MKT_TRAN_CNFM_PTD 交易确认
-- **         DWSXDAY.DWS_TRAN_AFFI_BTCH_PTD 交易归属网点
-- **         DWSXDAY.DWS_TRAN_ACCT_OPEN_BTCH_PFD 交易账户开户网点
-- **         DWDXDAY.DWD_PTY_CUST_INFO_PFD 客户信息表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO 标准字典分类枚举信息
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

INSERT OVERWRITE TABLE DWSXDAY.DWS_TRAN_MKT_TRAN_CNFM_PTD PARTITION(P_DT)
SELECT T1.CNFM_DATE                                         AS CNFM_DATE                --确认日期
     , T1.BUSIN_TYPE_CODE                                   AS BUSIN_TYPE_CODE          --业务类型代码
     , T2.STD_DICT_CLS_CDVAL_DESC                           AS BUSIN_TYPE_NAME          --业务类型名称
     , T12.CUST_NUM                                          AS CUST_NUM                 --客户编码
     , T12.CUST_NAME                                        AS CUST_NAME                --客户名字
     , T1.CUST_INCD                                         AS CUST_INCD                --客户内码
     , T1.CUST_TYPE_CODE                                    AS CUST_TYPE_CODE           --客户类型代码
     , T6.STD_DICT_CLS_CDVAL_DESC                           AS CUST_TYPE_NAME           --客户类型名称
     , T1.PROD_NUM                                          AS PROD_NUM                 --产品编码
     , T1.PROD_CODE                                         AS PROD_CODE                --产品代码
     , T1.SHARE_CATG_CODE                                   AS SHARE_CATG_CODE          --份额类别代码
     , T3.STD_DICT_CLS_CDVAL_DESC                           AS SHARE_CATG_NAME          --份额类别名称
     , T1.BONUS_MODE_CODE                                   AS BONUS_MODE_CODE          --分红方式代码
     , T4.STD_DICT_CLS_CDVAL_DESC                           AS BONUS_MODE_NAME          --分红方式代码
     , T1.CPTL_MODE_CODE                                    AS CPTL_MODE_CODE           --资金方式代码
     , T10.STD_DICT_CLS_CDVAL_DESC                          AS CPTL_MODE_NAME           --资金方式代码
     , T1.TRAN_MKT_CODE                                     AS TRAN_MKT_CODE            --交易市场代码
     , T5.STD_DICT_CLS_CDVAL_DESC                           AS TRAN_MKT_NAME            --交易市场名称
     , T1.CHNL_NUM                                          AS TRAN_CHNL_NUM            --交易渠道编码
     , T1.BTCH_NO                                           AS TRAN_BTCH_NO             --交易网点编号
     , CASE WHEN TRIM(T7.SPLIT_RULE_NAME)  IN('AGENCYNO-按经销商拆分') 
            THEN COALESCE(T8.OPEN_BTCH_NUM,T7.AFFI_BTCH_NUM)
            ELSE COALESCE(T7.AFFI_BTCH_NUM,T8.OPEN_BTCH_NUM) 
            END                                             AS AFFI_BTCH_NUM            --归属网点编码
    , CASE WHEN TRIM(T7.SPLIT_RULE_NAME)  IN('AGENCYNO-按经销商拆分') 
            THEN COALESCE(T8.OPEN_BTCH_NAME,T7.AFFI_BTCH_NAME)
            ELSE COALESCE(T7.AFFI_BTCH_NAME,T8.OPEN_BTCH_NAME) 
            END                                             AS AFFI_BTCH_NUM            --归属网点编码
       
    , CASE WHEN TRIM(T7.SPLIT_RULE_NAME)  IN('AGENCYNO-按经销商拆分')
            THEN COALESCE(T8.OPEN_AREA_CODE,T7.AFFI_AREA_CODE)
            ELSE COALESCE(T7.AFFI_AREA_CODE,T8.OPEN_AREA_CODE) 
       END                                                  AS AFFI_AREA_NUM            --归属区域编码
   , CASE WHEN TRIM(T7.SPLIT_RULE_NAME)  IN('AGENCYNO-按经销商拆分')  
          THEN NVL(T8.OPEN_CITY_CODE,T7.AFFI_CITY_CODE)
          ELSE NVL(T7.AFFI_CITY_CODE,T8.OPEN_CITY_CODE) 
       END                                                  AS AFFI_CITY_CODE  --归属城市代码  
   , CASE WHEN TRIM(T7.SPLIT_RULE_NAME)  IN('AGENCYNO-按经销商拆分')  
          THEN NVL(T8.OPEN_CITY_NAME,T7.AFFI_CITY_NAME)
          ELSE NVL(T7.AFFI_CITY_NAME,T8.OPEN_CITY_NAME) 
       END                                                  AS AFFI_CITY_NAME  --归属城市代码名称 
     , CASE WHEN TRIM(T7.SPLIT_RULE_NAME)  IN('AGENCYNO-按经销商拆分')  
          THEN NVL(T8.OPEN_PROVINCE_CODE,T7.AFFI_PROVINCE_CODE)
          ELSE NVL(T7.AFFI_PROVINCE_CODE,T8.OPEN_PROVINCE_CODE) 
       END                                                  AS AFFI_PROVINCE_CODE  --归属省份代码
    , CASE WHEN TRIM(T7.SPLIT_RULE_NAME)  IN('AGENCYNO-按经销商拆分')  
          THEN NVL(T8.OPEN_PROVINCE_NAME,T7.AFFI_PROVINCE_NAME)
          ELSE NVL(T7.AFFI_PROVINCE_NAME,T8.OPEN_PROVINCE_NAME) 
       END                                                  AS AFFI_PROVINCE_NAME  --归属省份代码       
     , T1.AGENCY_INCD                                       AS AGENCY_INCD              --销售商内码
     , T1.BROKER                                            AS BROKER_NUM               --经纪人编码
     , T1.FUND_ACCO                                         AS FUND_ACCO                --基金账号
     , T1.TRAN_ACCO                                         AS TRAN_ACCO                --交易账号
     , T1.TA_CNFM_NO                                        AS TA_CNFM_NO               --TA确认号
     , T1.TA_CODE                                           AS TA_CODE                  --TA代码
     , T1.REQ_DATE                                          AS REQ_DATE                 --申请日期
     , T1.REQ_TIME                                          AS REQ_TIME                 --申请时间
     , T1.REQ_NO                                            AS REQ_NO                   --申请编号
     , T1.ORI_REQ_NO                                        AS ORI_REQ_NO               --原申请编号
     , T1.REQ_AMT                                           AS REQ_AMT                  --申请金额
     , T1.REQ_SHARE                                         AS REQ_SHARE                --申请份额
     , T1.CNFM_AMT                                          AS CNFM_AMT                 --确认金额
     , T1.CNFM_SHARE                                        AS CNFM_SHARE               --确认份额
     , T1.TRAN_FEE                                          AS TRAN_FEE                 --交易费
     , T1.TRFE                                              AS TRFE                     --过户费
     , T1.STMP                                              AS STMP                     --印花税
     , T1.BACK_CHAG                                         AS BACK_CHAG                --后收手续费
     , T1.OTH_FEE                                           AS OTH_FEE                  --其他费用1
     , T1.LDMG                                              AS LDMG                     --违约金
     , T1.PERF_REMU_FEE                                     AS PERF_REMU_FEE            --业绩报酬费
     , T1.TOT_FEE                                           AS TOT_FEE                  --总费用
     , NVL(T1.TRAN_FEE_COLL_SALE_ORG_FEE,0)+  --交易费归销售机构费用
       NVL(T1.TRFE_COLL_SALE_ORG_FEE,0)+      --过户费归销售机构费用
       NVL(T1.FINAL_COLL_SALE_ORG_FEE,0)+     --后收费归销售机构费用
       NVL(T1.OTHER_FEE_COLL_SALE_ORG_FEE,0)+ --其他费归销售机构费用
       NVL(T1.LDMG_COLL_SALE_ORG_FEE,0)+      --违约金归销售机构费用
       NVL(T1.PERF_ROYL_COLL_AGENCY_FEE,0)    --业绩提成归销售商费用        
                                     AS COLL_SALE_ORG_FEE        --归销售机构费用
    ,  NVL(T1.TRAN_FEE_COLL_FUND_AST_FEE,0)+  --交易费归基金资产费用
       NVL(T1.TRFE_COLL_FUND_AST_FEE,0)+      --过户费归基金资产费用
       NVL(T1.FINAL_COLL_FUND_AST_FEE,0)+     --后收费归基金资产费用
       NVL(T1.OTHER_FEE_COLL_FUND_AST_FEE,0)+ --其他费归基金资产费用
       NVL(T1.LDMG_COLL_FUND_AST_FEE,0)+      --违约金归基金资产费用
       NVL(T1.PERF_REMU_COLL_FUND_AST_FEE,0)   --业绩报酬归基金资产费用                                
                                                           AS COLL_FUND_AST_FEE        --归基金资产费用
     , T1.INTR                                             AS INTR                     --利息
     , T1.INTR_TAX                                         AS INTR_TAX                 --利息税
     , T1.INTR_TRAN_SHARE                                  AS INTR_TRAN_SHARE          --利息转份额
     , T1.CNFM_DEAL_PRC                                    AS CNFM_DEAL_PRC            --确认成交价格(基金净值)
     , T1.CNFM_FRZ_CPTL                                    AS CNFM_FRZ_CPTL            --确认冻结资金
     , T1.CNFM_UNFZ_AMT                                    AS CNFM_UNFZ_AMT            --确认解冻金额
     , T1.DEAL_STAT_CODE                                   AS DEAL_STAT_CODE           --处理标志代码
     , T1.FAIL_CAUSE_CODE                                  AS FAIL_CAUSE_CODE          --失败原因代码
     , T1.TA_SPON_FLAG                                     AS TA_SPON_FLAG             --TA发起标志
     , T1.PCASH_UNP_YIEL                                   AS PCASH_UNP_YIEL           --兑现的未付收益
     , T1.PCASH_SHARE                                      AS PCASH_SHARE              --兑现的份额
     , T1.CNFM_UNP_YIEL                                    AS CNFM_UNP_YIEL            --确认的未付收益
     , T1.CNFM_RATE                                        AS CNFM_RATE                --确认比例
     , T1.ACTL_DISC_RATIO                                  AS ACTL_DISC_RATIO          --实际折扣率
     , T1.FRZ_CAUSE_CODE                                   AS FRZ_CAUSE_CODE           --冻结原因代码
     , T1.FRZ_END_DATE                                     AS FRZ_END_DATE             --冻结截止日期
     , T1.AGR_NO                                           AS AGR_NO                   --协议号
     , T1.VAST_REDEM_DEAL_FLAG                             AS VAST_REDEM_DEAL_FLAG     --巨额赎回处理标志
     , CASE WHEN NVL(TRIM(T7.SPLIT_RULE_NAME),'AGENCYNO-按经销商拆分')  IN('AGENCYNO-按经销商拆分') AND T8.OPEN_BTCH_NUM IS NOT NULL 
            THEN T8.SPLIT_RULE_NAME
            ELSE T7.SPLIT_RULE_NAME
            END AS SPLIT_RULE_NAME  
     , T1.SSYS                                             AS SSYS                     --源系统
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                       AS LD_TIME                  --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                       AS MODIFY_TIME              --修改时间      
     , T1.P_DT
  FROM DWDXDAY.DWD_TRAN_MKT_TRAN_CNFM_PTD T1 --交易确认
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T2  --标准字典分类枚举信息
    ON T1.BUSIN_TYPE_CODE = T2.STD_DICT_CLS_CDVAL
   AND T2.STD_DICT_CLS_CD = 'BUSIN_TYPE_CODE'
   AND T2.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T3  --标准字典分类枚举信息
    ON T1.SHARE_CATG_CODE = T3.STD_DICT_CLS_CDVAL
   AND T3.STD_DICT_CLS_CD = 'SHARE_CATG_CODE'
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T4  --标准字典分类枚举信息
    ON T1.BONUS_MODE_CODE = T4.STD_DICT_CLS_CDVAL
   AND T4.STD_DICT_CLS_CD = 'BONUS_MODE_CODE'
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T5  --标准字典分类枚举信息
    ON T1.TRAN_MKT_CODE = T5.STD_DICT_CLS_CDVAL
   AND T5.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T5.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T6  --标准字典分类枚举信息
    ON T1.CUST_TYPE_CODE = T6.STD_DICT_CLS_CDVAL
   AND T6.STD_DICT_CLS_CD = 'CUST_TYPE_CODE'
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWSXDAY.DWS_TRAN_AFFI_BTCH_PTD T7 --交易归属网点
    ON T1.TA_CNFM_NO = T7.CNFM_NO
   AND T1.CNFM_DATE = T7.CNFM_DATE
   AND T7.P_DT BETWEEN '${p_start_dt}'  AND '${p_end_dt}'
  LEFT JOIN (SELECT T8.FUND_ACCO
                  , T8.TRAN_ACCO
                  , T8.ST_DATE
                  , T8.END_DATE
                  , T8.OPEN_BTCH_NUM
                  , T8.OPEN_BTCH_NAME
                  , T8.OPEN_AREA_CODE
                  , T8.OPEN_CITY_CODE
                  , T8.OPEN_CITY_NAME
                  , T8.OPEN_PROVINCE_CODE
                  , T8.OPEN_PROVINCE_NAME
                  , T8.SPLIT_RULE_NAME
                  , ROW_NUMBER() OVER(PARTITION BY T8.FUND_ACCO, T8.TRAN_ACCO , T8.ST_DATE, T8.END_DATE ORDER BY T8.REQ_NO DESC ) RN
               FROM DWDXDAY.DWD_TRAN_MKT_TRAN_CNFM_PTD T1 --交易确认
              INNER JOIN DWSXDAY.DWS_TRAN_ACCT_OPEN_BTCH_PFD T8 --交易账户开户网点
                 ON T1.FUND_ACCO = T8.FUND_ACCO
                AND T1.TRAN_ACCO = T8.TRAN_ACCO
                AND T1.CNFM_DATE >= T8.ST_DATE
                AND T1.CNFM_DATE <= T8.END_DATE
                AND T8.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期  
             WHERE T1.P_DT BETWEEN '${p_start_dt}'  AND  '${p_end_dt}' 
          ) T8 --交易账户开户网点
    ON T1.FUND_ACCO = T8.FUND_ACCO
   AND T1.TRAN_ACCO = T8.TRAN_ACCO
   AND T1.CNFM_DATE >= T8.ST_DATE
   AND T1.CNFM_DATE <= T8.END_DATE
   AND T8.RN = 1
   LEFT JOIN DWDXDAY.DWD_PTY_CUST_FUNDACCT_RELA_PFD  T12 --客户基金帐号关系
    ON T1.CUST_INCD = T12.CUST_INCD
   AND T1.FUND_ACCO = T12.FUNDACCO
   AND T1.SSYS = T12.SSYS
   AND T12.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期 
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T10  --标准字典分类枚举信息
    ON T1.CPTL_MODE_CODE = T10.STD_DICT_CLS_CDVAL
   AND T10.STD_DICT_CLS_CD = 'CPTL_MODE_CODE'
   AND T10.VALID_FLAG = '1'
 WHERE T1.P_DT BETWEEN '${p_start_dt}'  AND  '${p_end_dt}' 
;
"
