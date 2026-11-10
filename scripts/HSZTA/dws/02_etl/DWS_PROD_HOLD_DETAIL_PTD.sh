#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
    set hive.strict.checks.type.safety=false;
INSERT OVERWRITE TABLE DWSXDAY.DWS_PROD_HOLD_DETAIL_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.HLDP_DATE                                                                                   AS BUSIN_DATE                              --业务日期
     , T1.PROD_NUM                                                                                    AS PROD_NUM                                --产品编码
     , T1.PROD_CODE                                                                                   AS PROD_CODE                               --产品代码
     , T7.CSNAME                                                                                      AS PROD_NAME                               --产品名称
     , ROUND(T1.HOLD_SHARE,4)                                                                         AS HOLD_SHARE                              --持有份额
     , ROUND(T1.HOLD_SHARE*NVL(T2.AST_UNIT_NAV,T3.AST_UNIT_NAV),4)                                    AS HOLD_AST                                --持有资产
     , ROUND(T1.INCL_UNP_YIEL_SHARE,4)                                                                AS INCL_UNP_YIEL_SHARE                     --含未付收益份额
     , ROUND(T1.TOTAL_YIEL,4)                                                                         AS TOTAL_YIEL                              --累计收益
     , ROUND(T1.TDY_UNP_YIEL,4)                                                                       AS TDY_UNP_YIEL                            --当日未付收益
     , ROUND(NVL(T2.AST_UNIT_NAV,T3.AST_UNIT_NAV),4)                                                  AS VALU_UNIT_NAV                           --估值单位净值
     , ROUND(NVL(T8.AST_UNIT_NAV,T9.AST_UNIT_NAV),4)                                                  AS YEST_VALU_UNIT_NAV                      --上日估值单位净值
     , ROUND(T7.CURR_MAG_FEER,4)                                                                      AS MAG_FEER                                --管理费率
     , ROUND(NVL(T2.AST_UNIT_NAV,T3.AST_UNIT_NAV)*T1.HOLD_SHARE*T7.CURR_MAG_FEER/T5.DAYS,4)           AS MAG_FEE                                 --管理费
     , ROUND(T1.SALE_FEE*NVL(T2.AST_UNIT_NAV,T3.AST_UNIT_NAV)/T5.DAYS,4)                              AS SALE_FEE                                --销售服务费
     , ROUND(NVL(T2.AST_SHARE,T3.AST_SHARE),4)                                                        AS VALU_AST_SHARE                          --估值资产份额
     , ROUND(NVL(T8.AST_SHARE,T9.AST_SHARE),4)                                                        AS YEST_VALU_AST_SHARE                     --上日估值资产份额
     , ROUND(NVL(T2.AST_NAV,T3.AST_NAV),4)                                                            AS VALU_AST_MVAL                           --估值资产净值市值
     , ROUND(NVL(T8.AST_NAV,T9.AST_NAV),4)                                                            AS YEST_VALU_AST_MVAL                      --上日估值资产净值市值
     , ROUND(NVL(NVL(T2.MAGF,T4.MAGF*T2.AST_SHARE/T4.AST_SHARE),T3.MAGF),4)                           AS VALU_TOTAL_MAG_FEE                      --估值累计管理费
     , ROUND(NVL(NVL(T8.MAGF,T10.MAGF*T8.AST_SHARE/T10.AST_SHARE),T9.MAGF),4)                         AS YEST_VALU_TOTAL_MAG_FEE                 --上日估值累计管理费
     , CASE WHEN T2.MAGF IS NOT NULL THEN ROUND((T2.MAGF - T8.MAGF),4) 
       ELSE ROUND(NVL((T4.MAGF-T10.MAGF)*T2.AST_SHARE/T4.AST_SHARE ,(T3.MAGF-T9.MAGF)),4) END         AS TDY_VALU_MAG_FEE                        --当日估值管理费
     , ROUND(NVL(NVL(T2.SALE_FEE,T4.SALE_FEE*T2.AST_SHARE/T4.AST_SHARE),T3.SALE_FEE),4)               AS VALU_TOTAL_SALE_FEE                     --估值累计销售服务费
     , ROUND(NVL(NVL(T8.SALE_FEE,T10.SALE_FEE*T8.AST_SHARE/T10.AST_SHARE),T9.SALE_FEE),4)             AS YEST_VALU_TOTAL_SALE_FEE                --上日估值累计销售服务费 
     , CASE WHEN T2.SALE_FEE IS NOT NULL THEN ROUND((T2.SALE_FEE - T8.SALE_FEE),4) ELSE
         ROUND(NVL((T4.SALE_FEE-T10.SALE_FEE)*T2.AST_SHARE/T4.AST_SHARE ,(T3.SALE_FEE-T9.SALE_FEE)),4) END  AS TDY_SALE_FEE                      --当日估值销售费
     , ROUND(NVL(T3.PERF_REMU,T4.PERF_REMU*T2.AST_SHARE/T4.AST_SHARE),4)                              AS VALU_PERF_REMU                          --估值累计业绩报酬
     , ROUND(NVL(T3.RISK_RES,T4.RISK_RES*T2.AST_SHARE/T4.AST_SHARE),4)                                AS VALU_RISK_RES                           --估值风险准备金
  FROM (SELECT T1.HLDP_DATE     
             , T1.PROD_NUM      
             , T1.PROD_CODE    
             , SUM(T1.HOLD_SHARE)             HOLD_SHARE
             , SUM(T1.INCL_UNP_YIEL_SHARE)    INCL_UNP_YIEL_SHARE   
             , SUM(T1.TOTAL_YIEL)             TOTAL_YIEL  
             , SUM(T1.TDY_UNP_YIEL)           TDY_UNP_YIEL 
             , SUM(T1.HOLD_SHARE*T6.SALE_FEER) AS SALE_FEE
          FROM DWSXDAY.DWS_CUST_HOLD_DETAIL_PTD T1  --客户保有明细
          LEFT JOIN DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD T6 --产品销售费率
            ON T1.PROD_NUM = T6.PROD_NUM
           AND T1.CHNL_NUM = T6.CHNL_NUM
           AND T6.ST_DATE <= '${p_end_dt}'--开始日期
           AND T6.END_DATE >= '${p_end_dt}'--结束日期
           AND T6.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
         WHERE T1.P_DT = '${p_end_dt}'
         GROUP BY T1.HLDP_DATE     
                , T1.PROD_NUM      
                , T1.PROD_CODE 
     )T1
  LEFT JOIN DWSXDAY.DWS_PROD_AST_INFO_PTD T2 --产品资产信息
    ON T1.PROD_CODE = T2.CLAS_PROD_CODE
   AND T1.HLDP_DATE = T2.P_DT
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWSXDAY.DWS_PROD_AST_INFO_PTD T3 --产品资产信息
    ON T1.PROD_CODE = T3.PROD_CODE
   AND T3.CLAS_PROD_CODE IS NULL
   AND T1.HLDP_DATE = T3.P_DT
   AND T3.P_DT = '${p_end_dt}'
  LEFT JOIN DWSXDAY.DWS_PROD_AST_INFO_PTD T4 --产品资产信息
    ON T2.PROD_CODE = T4.PROD_CODE
   AND T4.CLAS_PROD_CODE IS NULL
   AND T2.P_DT = T4.P_DT
   AND T4.P_DT = '${p_end_dt}'
  LEFT JOIN (SELECT COUNT(1) AS DAYS 
              FROM DWDXDAY.DWD_CMM_CALENDAR_INFO_PFD --日历信息
             WHERE P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)  --取最新日期 
               AND TRAN_MKT = '1'  --国内交易所
               AND YEAR = SUBSTR('${p_end_dt}',1,4)
             )T5
    ON 1 = 1
  LEFT JOIN DWSXDAY.DWS_PROD_INFO_PFD T7 --产品信息
    ON T1.PROD_NUM = T7.PROD_NUM
   AND T7.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)  --取最新日期
    LEFT JOIN DWSXDAY.DWS_PROD_AST_INFO_PTD T8 --产品资产信息
    ON T1.PROD_CODE = T8.CLAS_PROD_CODE
   AND T8.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWSXDAY.DWS_PROD_AST_INFO_PTD T9 --产品资产信息
    ON T1.PROD_CODE = T9.PROD_CODE
   AND T9.CLAS_PROD_CODE IS NULL
   AND T9.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  LEFT JOIN DWSXDAY.DWS_PROD_AST_INFO_PTD T10 --产品资产信息
    ON T8.PROD_CODE = T10.PROD_CODE
   AND T10.CLAS_PROD_CODE IS NULL
   AND T8.P_DT = T10.P_DT
   AND T10.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${p_end_dt}','yyyyMMdd'))),1),'yyyyMMdd')
  WHERE T1.HOLD_SHARE <> 0;
"