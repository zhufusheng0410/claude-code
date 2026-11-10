#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:资产
-- ** 描述:产品净值行情信息
-- ** 创建者:auto
-- ** 创建日期:2023-08-01
-- ** 修改日志:
-- ** 2023-08-01，auto，新建
-- ** 目标表：DWDXDAY.DWD_AST_PROD_NAV_QUOT_INFO_PFD  产品净值行情信息
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDDAY_PFD   基金日信息
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD      产品编码映射
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP      标准字典码值映射
-- **         DWDXDAY.DWD_AST_PROD_NAV_QUOT_INFO_PFD  产品净值行情信息
-- **         DWDXDAY.DWD_CMM_CALENDAR_INFO_PFD       日历表
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
set mapreduce.job.reduces=3;

INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_PROD_NAV_QUOT_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.D_DATE                                                                     AS NAV_DATE                                --净值日期 
     , T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期 
     , T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , CASE WHEN T1.C_TODAYSTATUS IS NOT NULL 
            THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TODAYSTATUS)) 
        END                                                                          AS PROD_STAT_CODE                          --产品状态代码
     , CASE WHEN T1.C_STATUS IS NOT NULL 
            THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STATUS)) 
        END                                                                          AS YEST_PROD_STAT_CODE                     --昨日产品状态代码
     , T1.F_NETVALUE                                                                 AS FUND_NAV                                --基金净值（成交价）
     , T1.F_LASTSHARES                                                               AS TOT_SHARE                               --总份额
     , T1.F_LASTASSET                                                                AS TOT_NAV                                 --总净值
     , T1.F_ASUCCEED                                                                 AS ADD_NUMS                                --增加份数  
     , T1.F_RSUCCEED                                                                 AS RD_NUMS                                 --减少份数  
     , T1.C_VASTFLAG                                                                 AS VAST_REDEM_FLAG                         --巨额赎回标志
     , T1.F_ENCASHRATIO                                                              AS VAST_REDEM_RATE                         --巨额赎回比例
     , T1.F_CHANGERATIO                                                              AS VAST_REDEM_CNFM_RATE                    --巨额赎回，转出确认比例
     , T1.C_EXCESSFLAG                                                               AS EXCESS_FLAG                             --超额申购标志
     , T1.F_SUBSCRIBERATIO                                                           AS EXCESS_RATE                             --超额申购比例
     , T1.F_INCOME                                                                   AS FUND_YIEL                               --基金收益
     , T1.F_INCOMEUNIT                                                               AS MICP_UNIT_YIEL                          --万份单位收益
     , T1.F_INCOMERATIO                                                              AS YEAR_YLD                                --年收益率
     , T1.F_UNASSIGN                                                                 AS UNASSN_YIEL                             --未分配收益
     , T1.F_TOTALNETVALUE                                                            AS TOTAL_NAV                               --累计净值
     , T1.F_SERVICEFARE                                                              AS SALE_FEE                                --销售服务费 
     , T1.F_ASSIGN                                                                   AS TDY_ASSN_YIEL                           --当天分配收益 
     , T1.F_MANAGEFARE                                                               AS ACCT_MAGF_AMT                           --账户管理费金额 
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TFUNDDAY_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDDAY_PFD T1  --基金日信息
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_TODAYSTATUS'
   AND T1.C_TODAYSTATUS = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_STATUS'
   AND T1.C_STATUS = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T1.D_DATE = '${p_end_dt}'
;

INSERT INTO DWDXDAY.DWD_AST_PROD_NAV_QUOT_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.NAV_DATE                                                                   AS NAV_DATE                                --净值日期 周六日当天
     , T1.CNFM_DATE                                                                  AS CNFM_DATE                               --确认日期 周五
     , T1.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.PROD_STAT_CODE                                                             AS PROD_STAT_CODE                          --产品状态代码
     , T1.YEST_PROD_STAT_CODE                                                        AS YEST_PROD_STAT_CODE                     --昨日产品状态代码
     , T1.FUND_NAV                                                                   AS FUND_NAV                                --基金净值（成交价）
     , T1.TOT_SHARE                                                                  AS TOT_SHARE                               --总份额
     , T1.TOT_NAV                                                                    AS TOT_NAV                                 --总净值
     , T1.ADD_NUMS                                                                   AS ADD_NUMS                                --增加份数
     , T1.RD_NUMS                                                                    AS RD_NUMS                                 --减少份数
     , T1.VAST_REDEM_FLAG                                                            AS VAST_REDEM_FLAG                         --巨额赎回标志
     , T1.VAST_REDEM_RATE                                                            AS VAST_REDEM_RATE                         --巨额赎回比例
     , T1.VAST_REDEM_CNFM_RATE                                                       AS VAST_REDEM_CNFM_RATE                    --巨额赎回，转出确认比例
     , T1.EXCESS_FLAG                                                                AS EXCESS_FLAG                             --超额申购标志
     , T1.EXCESS_RATE                                                                AS EXCESS_RATE                             --超额申购比例
     , T1.FUND_YIEL                                                                  AS FUND_YIEL                               --基金收益
     , T1.MICP_UNIT_YIEL                                                             AS MICP_UNIT_YIEL                          --万份单位收益
     , T1.YEAR_YLD                                                                   AS YEAR_YLD                                --年收益率
     , T1.UNASSN_YIEL                                                                AS UNASSN_YIEL                             --未分配收益
     , T1.TOTAL_NAV                                                                  AS TOTAL_NAV                               --累计净值
     , T1.SALE_FEE                                                                   AS SALE_FEE                                --销售服务费
     , T1.TDY_ASSN_YIEL                                                              AS TDY_ASSN_YIEL                           --当天分配收益
     , T1.ACCT_MAGF_AMT                                                              AS ACCT_MAGF_AMT                           --账户管理费金额
     , T1.SSYS                                                                       AS SSYS                                    --源系统
     , T1.SRC_TAB                                                                    AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_AST_PROD_NAV_QUOT_INFO_PFD T1  --产品净值行情信息
 WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
;

INSERT INTO DWDXDAY.DWD_AST_PROD_NAV_QUOT_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.D_DATE                                                                        AS NAV_DATE                                --净值日期 周六日当天
     , T1.CNFM_DATE                                                                     AS CNFM_DATE                               --确认日期 周五
     , T1.PROD_NUM                                                                      AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                     AS PROD_CODE                               --产品代码
     , T1.PROD_STAT_CODE                                                                AS PROD_STAT_CODE                          --产品状态代码
     , T1.YEST_PROD_STAT_CODE                                                           AS YEST_PROD_STAT_CODE                     --昨日产品状态代码
     , T1.FUND_NAV                                                                      AS FUND_NAV                                --基金净值（成交价）
     , T1.TOT_SHARE                                                                     AS TOT_SHARE                               --总份额
     , T1.TOT_NAV                                                                       AS TOT_NAV                                 --总净值
     , 0                                                                                AS ADD_NUMS                                --增加份数
     , 0                                                                                AS RD_NUMS                                 --减少份数
     , T1.VAST_REDEM_FLAG                                                               AS VAST_REDEM_FLAG                         --巨额赎回标志
     , T1.VAST_REDEM_RATE                                                               AS VAST_REDEM_RATE                         --巨额赎回比例
     , T1.VAST_REDEM_CNFM_RATE                                                          AS VAST_REDEM_CNFM_RATE                    --巨额赎回，转出确认比例
     , T1.EXCESS_FLAG                                                                   AS EXCESS_FLAG                             --超额申购标志
     , T1.EXCESS_RATE                                                                   AS EXCESS_RATE                             --超额申购比例
     , T1.FUND_YIEL                                                                     AS FUND_YIEL                               --基金收益
     , T1.MICP_UNIT_YIEL                                                                AS MICP_UNIT_YIEL                          --万份单位收益
     , T1.YEAR_YLD                                                                      AS YEAR_YLD                                --年收益率
     , T1.UNASSN_YIEL                                                                   AS UNASSN_YIEL                             --未分配收益
     , T1.TOTAL_NAV                                                                     AS TOTAL_NAV                               --累计净值
     , 0                                                                                AS SALE_FEE                                --销售服务费
     , 0                                                                                AS TDY_ASSN_YIEL                           --当天分配收益
     , 0                                                                                AS ACCT_MAGF_AMT                           --账户管理费金额
     , 'HSZTA'                                                                          AS SSYS                                    --源系统
     , 'ODS_HSZTA_TFUNDDAY_PFD'                                                         AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')         AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')         AS MODIFY_TIME                             --修改时间
  FROM DWDXDAY.DWD_AST_PROD_NAV_QUOT_INFO_PFD T1  --产品净值行情信息
 INNER JOIN DWDXDAY.DWD_CMM_CALENDAR_INFO_PFD T2  --日历表
    ON T2.LASTEST_TRADE_DATE = T1.NAV_DATE --最近的交易日
   AND T2.IS_TRADE_DATE = 0 --非工作日
   AND T2.D_DATE = '${p_end_dt}'
   AND T2.TRAN_MKT ='1'  --国内交易所
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
 WHERE T1.P_DT = '${p_end_dt}'
;
"
