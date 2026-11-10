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
-- ** 描述:产品交易限制
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_TRAN_LMT_PFD  产品交易限制
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TARLIMIT_PFD 交易限制
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TARLIMIT_PFD 交易限制
-- **         DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD 渠道基本信息
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_TRAN_LMT_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
              THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , T4.CHNL_NUM                                                                   AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.F_OMINBALA                                                                 AS FST_INV_LOW_AMT                         --首次投资最低金额
     , T1.F_STEPBALA                                                                 AS MIN_APPD_AMT                            --最少追加金额
     , T1.F_OMAXBALA                                                                 AS MAX_SCRP_LA                             --最高认购限额
     , T1.F_HMAXRATIO                                                                AS MAX_HOLD_RATE                           --最高持有比例
     , T1.F_HMAXBALA                                                                 AS MAX_HOLD_AMT                            --最高持有金额
     , T1.F_RMINSHARES                                                               AS REDEM_LOW_SHARE                         --赎回最低份额
     , T1.F_HMINSHARES                                                               AS LOW_BOOK_SHARE                          --最低账面份额
     , T1.F_CMINSHARES                                                               AS LOW_CHANGE_SHARE                        --最低转换份额
     , T1.F_RATIONMINBALA                                                            AS RATION_LOW_AMT                          --定期定额最低金额
     , T1.F_SWITCHINBALA                                                             AS CHANGE_INTO_LOW_AMT                     --转换入最低金额(含费)
     , T1.F_RATIONREDEEMMIN                                                          AS RATION_REDEM_LOW_SHARE                  --定期定额赎回最低份额
     , T1.F_MAXALLOTBALA                                                             AS LARGE_ALLOT_MAX_AMT                     --大额申购最高金额
     , T1.F_HMINBALA                                                                 AS LOW_BOOK_AMT                            --最低账面金额
     , T1.F_GRADEDIFF                                                                AS GRADE_AMT                               --级差金额
     , T1.F_MAXBIDSAMOUNT                                                            AS MAX_ALLOT_AMT                           --最大申购金额
     , T1.F_MAXSUMBIDSAMOUNT                                                         AS TDAG_ALLOT_MAX_AMT                      --当日累计申购最大金额
     , T1.F_MAXREDSVOL                                                               AS MAX_REDEM_SHARE                         --最大赎回份额
     , T1.F_MAXSUMREDSVOL                                                            AS TDAG_REDEM_MAX_SHARE                    --当日累计赎回最大份额
     , T1.F_RATIONMAXBALA                                                            AS RATION_MAX_AMT                          --定期定额最高金额
     , T1.C_NETNO                                                                    AS BTCH_NO                                 --网点编号
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TARLIMIT_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TARLIMIT_PFD T1  --交易限制
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BASIC_INFO_PFD T4 --渠道基本信息
    ON T4.CHNL_INCD = T1.C_AGENCYNO
   AND T4.P_DT = '${p_end_dt}'
WHERE T1.P_DT = '${p_end_dt}'
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_TRAN_LMT_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_CUSTTYPE IS NOT NULL 
              THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE)) 
        END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
     , NULL                                                                          AS CHNL_NUM                                --渠道编码
     , NULL                                                                          AS CHNL_INCD                               --渠道内码
     , T1.F_OMINBALA                                                                 AS FST_INV_LOW_AMT                         --首次投资最低金额
     , T1.F_STEPBALA                                                                 AS MIN_APPD_AMT                            --最少追加金额
     , T1.F_OMAXBALA                                                                 AS MAX_SCRP_LA                             --最高认购限额
     , T1.F_HMAXRATIO                                                                AS MAX_HOLD_RATE                           --最高持有比例
     , T1.F_HMAXBALA                                                                 AS MAX_HOLD_AMT                            --最高持有金额
     , T1.F_RMINSHARES                                                               AS REDEM_LOW_SHARE                         --赎回最低份额
     , T1.F_HMINSHARES                                                               AS LOW_BOOK_SHARE                          --最低账面份额
     , T1.F_CMINSHARES                                                               AS LOW_CHANGE_SHARE                        --最低转换份额
     , T1.F_RATIONMINBALA                                                            AS RATION_LOW_AMT                          --定期定额最低金额
     , T1.F_SWITCHINBALA                                                             AS CHANGE_INTO_LOW_AMT                     --转换入最低金额(含费)
     , T1.F_RATIONREDEEMMIN                                                          AS RATION_REDEM_LOW_SHARE                  --定期定额赎回最低份额
     , T1.F_MAXALLOTBALA                                                             AS LARGE_ALLOT_MAX_AMT                     --大额申购最高金额
     , T1.F_HMINBALA                                                                 AS LOW_BOOK_AMT                            --最低账面金额
     , T1.F_GRADEDIFF                                                                AS GRADE_AMT                               --级差金额
     , T1.F_MAXBIDSAMOUNT                                                            AS MAX_ALLOT_AMT                           --最大申购金额
     , T1.F_MAXSUMBIDSAMOUNT                                                         AS TDAG_ALLOT_MAX_AMT                      --当日累计申购最大金额
     , T1.F_MAXREDSVOL                                                               AS MAX_REDEM_SHARE                         --最大赎回份额
     , T1.F_MAXSUMREDSVOL                                                            AS TDAG_REDEM_MAX_SHARE                    --当日累计赎回最大份额
     , T1.F_RATIONMAXBALA                                                            AS RATION_MAX_AMT                          --定期定额最高金额
     , NULL                                                                          AS BTCH_NO                                 --网点编号
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TARLIMIT_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TARLIMIT_PFD T1  --交易限制
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSFTA'
   AND T3.SRC_DICT_CLS_CD = 'C_CUSTTYPE'
   AND T1.C_CUSTTYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
;

"
