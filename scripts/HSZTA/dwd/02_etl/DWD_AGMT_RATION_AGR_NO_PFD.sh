#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:合同
-- ** 描述:定期定额协议号
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_AGMT_RATION_AGR_NO_PFD  定期定额协议号
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TRATION_PFD 定期定额协议表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TRATION_PFD 定期定额协议表
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准字典码值映射
-- **************************************************************************

set hive.strict.checks.type.safety=false;
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_AGMT_RATION_AGR_NO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.C_RATIONNO                                                                 AS RATION_AGR_NO                           --定期定额协议号
     , T1.C_REQUESTNO                                                                AS REQ_NO                                  --申请编号
     , T1.D_LASTREQUESTDATE                                                          AS LAST_TRAN_REQ_DATE                      --最后交易申请日期
     , T1.D_FIRSTDATE                                                                AS FST_TRAN_CNFM_DATE                      --首次交易确认日期
     , T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
         END                                                                         AS SHARE_TYPE                              --份额类型
     , T1.D_DATE                                                                     AS REQ_DATE                                --申请日期
     , CASE WHEN T1.C_RATIONTYPE IS NOT NULL 
             THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RATIONTYPE)) 
         END                                                                         AS RATION_TYPE_CODE                        --定期定额类型代码
     , T1.L_RATIONDATE                                                               AS REGU_DATE                               --定期日期
     , T1.C_RATIONTERM                                                               AS RATION_PD                               --定期定额周期
     , T1.D_PROTOCOLENDDATE                                                          AS AGR_END_DATE                            --协议截止日期
     , T1.L_DELAY                                                                    AS PERM_DELAY_DAYS                         --允许顺延天数
     , T1.L_ALLOWFAIL                                                                AS PERM_FAIL_TIMES                         --允许失败的次数
     , T1.F_BALANCE                                                                  AS ALLOT_AMT                               --申购金额
     , T1.F_SHARES                                                                   AS REDEM_SHARE                             --赎回份额
     , T1.F_AGIO                                                                     AS AGR_FEE_DISC                            --协议费用折扣
     , T1.C_FLAG                                                                     AS VALID_FLAG                              --有效标志
     , T1.L_TIMES                                                                    AS TOTAL_ACHIEV_TIMES                      --累计实现次数
     , T1.F_TOTALBALANCE                                                             AS TOTAL_ALLOT_ACHIEV_AMT                  --累计申购实现金额
     , T1.F_TOTALSHARES                                                              AS TOTAL_REDEM_ACHIEV_SHARE                --累计赎回实现份额
     , T1.C_DEFAULT                                                                  AS DEF_AGR_FLAG                            --默认协议标志
     , T1.F_REALAGIO                                                                 AS LST_ACHIEV_DISC                         --上次实现折扣
     , T1.C_SYSROLE                                                                  AS SYS_ROLE                                --系统角色
     , T1.D_LASTDATE                                                                 AS DATA_LAST_IMPORT_DATE                   --数据最后导入日期
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TRATION_PFD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TRATION_PFD T1  --定期定额协议表
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
   AND T4.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSZTA'
   AND T5.SRC_DICT_CLS_CD = 'C_RATIONTYPE'
   AND T1.C_RATIONTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

INSERT INTO DWDXDAY.DWD_AGMT_RATION_AGR_NO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.C_RATIONNO                                                                 AS RATION_AGR_NO                           --定期定额协议号
     , T1.C_REQUESTNO                                                                AS REQ_NO                                  --申请编号
     , SUBSTR(REPLACE(T1.D_LASTREQUESTDATE,'-',''),1,8)                              AS LAST_TRAN_REQ_DATE                      --最后交易申请日期
     , SUBSTR(REPLACE(T1.D_FIRSTDATE,'-',''),1,8)                                    AS FST_TRAN_CNFM_DATE                      --首次交易确认日期
     , T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , T1.C_FUNDACCO                                                                 AS FUND_ACCO                               --基金账号
     , T1.C_TRADEACCO                                                                AS TRAN_ACCO                               --交易账号
     , T3.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , CASE WHEN T1.C_SHARETYPE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_SHARETYPE)) 
         END                                                                         AS SHARE_TYPE                              --份额类型
     , SUBSTR(REPLACE(T1.D_DATE,'-',''),1,8)                                         AS REQ_DATE                                --申请日期
     , CASE WHEN T1.C_RATIONTYPE IS NOT NULL                                        
        THEN COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RATIONTYPE))            
        END                                                                          AS RATION_TYPE_CODE                        --定期定额类型代码
     , T1.L_RATIONDATE                                                               AS REGU_DATE                               --定期日期
     , T1.C_RATIONTERM                                                               AS RATION_PD                               --定期定额周期
     , SUBSTR(REPLACE(T1.D_PROTOCOLENDDATE,'-',''),1,8)                              AS AGR_END_DATE                            --协议截止日期
     , T1.L_DELAY                                                                    AS PERM_DELAY_DAYS                         --允许顺延天数
     , T1.L_ALLOWFAIL                                                                AS PERM_FAIL_TIMES                         --允许失败的次数
     , T1.F_BALANCE                                                                  AS ALLOT_AMT                               --申购金额
     , T1.F_SHARES                                                                   AS REDEM_SHARE                             --赎回份额
     , T1.F_AGIO                                                                     AS AGR_FEE_DISC                            --协议费用折扣
     , T1.C_FLAG                                                                     AS VALID_FLAG                              --有效标志
     , T1.L_TIMES                                                                    AS TOTAL_ACHIEV_TIMES                      --累计实现次数
     , T1.F_TOTALBALANCE                                                             AS TOTAL_ALLOT_ACHIEV_AMT                  --累计申购实现金额
     , T1.F_TOTALSHARES                                                              AS TOTAL_REDEM_ACHIEV_SHARE                --累计赎回实现份额
     , T1.C_DEFAULT                                                                  AS DEF_AGR_FLAG                            --默认协议标志
     , T1.F_REALAGIO                                                                 AS LST_ACHIEV_DISC                         --上次实现折扣
     , NULL                                                                          AS SYS_ROLE                                --系统角色
     , SUBSTR(REPLACE(T1.D_LASTDATE,'-',''),1,8)                                     AS DATA_LAST_IMPORT_DATE                   --数据最后导入日期
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TRATION_PFD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TRATION_PFD T1  --定期定额协议表
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
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFTA'
   AND T4.SRC_DICT_CLS_CD = 'C_SHARETYPE'
   AND T1.C_SHARETYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准字典码值映射
    ON T5.SSYS = 'HSFTA'
   AND T5.SRC_DICT_CLS_CD = 'C_RATIONTYPE'
   AND T1.C_RATIONTYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;
"
