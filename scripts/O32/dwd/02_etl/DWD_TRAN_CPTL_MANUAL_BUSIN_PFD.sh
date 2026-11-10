#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env

day_8_ago=$(date -d "8 day ago" +"%Y%m%d")

inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:交易
-- ** 描    述:资金手工类业务表
-- ** 创 建 者:auto
-- ** 创建日期:2023-06-20
-- ** 修改日志:
-- ** 2023-06-20，auto，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_CPTL_MANUAL_BUSIN_PFD  资金手工类业务表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TCASHBUSINESS_PFD  资金类业务表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD      账套编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP      标准码值字典映射表
-- **************************************************************************

set hive.strict.checks.type.safety=false;
    set mapred.max.split.size=256000000;
    set mapred.min.split.size.per.node=100000000;
    set mapred.min.split.size.per.rack=100000000;
    set hive.merge.mapredfiles=true;
    set hive.merge.mapfiles=true;
    set hive.merge.smallfiles.avgsize=16000000;
    set hive.merge.size.per.task=256000000;
    set hive.exec.reducers.bytes.per.reducer=10240000000; 
    set mapreduce.job.reduces=3;

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_CPTL_MANUAL_BUSIN_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_BUSIN_NO                                                                 AS BUSIN_SERIALNO                          --业务序号
     , T1.L_BATCH_NO                                                                 AS BAT_NO                                  --批号
     , T1.L_DATE                                                                     AS OCCUR_DATE                              --发生日期
     , T1.L_TIME                                                                     AS OCCUR_TIME                              --发生时间
     , CASE 
         WHEN T1.VC_BUSIN_OPFLAG IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_BUSIN_OPFLAG)) 
       END                                                                           AS BUSIN_OPER_TYPE_CODE                    --业务操作类型代码
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_ASSET_ID                                                                 AS AST_UNIT_SERIALNO                       --资产单元序号
     , T3.SFAC_NUM                                                                   AS TGT_PROD_NUM                            --目标产品编码
     , T3.PROD_CODE                                                                  AS TGT_PROD_CODE                           --目标产品代码
     , T1.L_TARGET_FUND                                                              AS TGT_PROD_INCD                           --目标产品内码
     , T1.L_TARGET_ASSET                                                             AS TGT_AST_UNIT_SERIALNO                   --目标资产单元序号
     , CASE 
         WHEN T1.VC_CURRENCY_NO IS NOT NULL THEN 
          COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_CURRENCY_NO)) 
       END                                                                           AS CRRC_CODE                               --币种代码
     , CASE 
         WHEN T1.C_ENABLE_POINT IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENABLE_POINT)) 
       END                                                                           AS TECT_TIME_POI_CODE                      --币种代码
     , T1.C_ENABLE_FLAG                                                              AS DUE_BACK_INFLU_USE_FLAG                 --到期后影响可用标志
     , T1.EN_OCCUR_BALANCE                                                           AS OCCUR_AMT                               --发生金额
     , T1.EN_OCCUR_SHARE                                                             AS OCCUR_SHARE                             --发生份额
     , T1.L_OPERATE_ENABLE_DATE                                                      AS FRZ_UNFZ_BEGIN_DATE                     --冻结解冻起始日期
     , T1.L_OPERATE_DISABLE_DATE                                                     AS FRZ_UNFZ_END_DATE                       --冻结解冻终止日期
     , T1.L_FROZEN_NO                                                                AS FRZ_JOUR_SERIALNO                       --冻结流水序号
     , T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , T1.VC_MEMO                                                                    AS MEMO                                    --备注
     , T1.L_CHECK_DATE                                                               AS CHK_DATE                                --复核日期
     , T1.L_CHECK_TIME                                                               AS CHK_TIME                                --复核时间
     , T1.L_CHECK_OPERATOR                                                           AS CHKR_CODE                               --复核人代码
     , CASE 
         WHEN T1.C_CHECK_FLAG IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CHECK_FLAG)) 
       END                                                                           AS CHK_STAT_CODE                           --复核状态代码
     , T1.VC_CHECK_MEMO                                                              AS CHK_MEMO                                --复核备注
     , T1.C_DEAL_FLAG                                                                AS DEAL_FLAG                               --处理标志
     , T1.C_DEL_STATUS                                                               AS DEL_FLAG                                --删除标志
     , T1.L_DEL_DATE                                                                 AS DEL_DATE                                --删除日期
     , T1.L_DEL_TIME                                                                 AS DEL_TIME                                --删除时间
     , T1.L_DEL_OPERATOR                                                             AS DEL_OPER_CODE                           --删除操作员代码
     , T1.L_RETURN_DATE                                                              AS RETU_DATE                               --返还日期
     , CASE 
         WHEN T1.C_RETURN_POINT IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_RETURN_POINT)) 
       END                                                                           AS RETU_TIME_POI_CODE                      --返还时点代码
     , T1.C_RETURN_DEAL_FLAG                                                         AS RETU_DEAL_FLAG                          --返还处理标志
     , T1.C_GX_CASH_LINKED_STATUS                                                    AS CPTL_LINKG_STAT_CODE                    --资金联动状态代码
     , T1.C_FUTURE_ENABLE_FLAG                                                       AS FWD_BUSIN_INFLU_USE_FLAG                --远期业务影响可用标志
     , CASE 
          WHEN T1.C_INFLUENCE_T0 IS NOT NULL THEN 
            CASE 
              WHEN T1.VC_BUSIN_OPFLAG = 107 THEN       --资金划转类
                COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INFLUENCE_T0)) 
              ELSE 
                COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INFLUENCE_T0)) 
            END
        END                                                                          AS INFLU_TDY_STAT_CODE                     --影响T+0状态代码
     , T1.D_DATETIME                                                                 AS TIME_STAMP                              --时间戳
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TCASHBUSINESS_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TCASHBUSINESS_PFD T1  --资金类业务表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD --产品内码
   AND T2.SSYS = 'O32' --源系统
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T3 --账套编码映射
    ON T1.L_TARGET_FUND = T3.SFAC_INCD --产品内码
   AND T3.SSYS = 'O32' --源系统
   AND T3.ST_DATE <= '${p_end_dt}' --开始日期
   AND T3.END_DATE >= '${p_end_dt}' --结束日期
   AND T3.VALID_FLAG = '1' --有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T1.VC_BUSIN_OPFLAG = T4.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T4.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T4.SRC_DICT_CLS_CD = 'VC_CPTL_BUSIN_OPFLAG' --源字典分类
   AND T4.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_ENABLE_POINT = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T5.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_ENABLE_POINT' --源字典分类
   AND T5.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.C_CHECK_FLAG = T6.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T6.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'C_CHECK_FLAG' --源字典分类
   AND T6.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_RETURN_POINT = T7.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T7.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_RETURN_POINT' --源字典分类
   AND T7.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_INFLUENCE_T0 = T8.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T8.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'C_TRAN_INFLUENCE_T0' --源字典分类
   AND T8.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_INFLUENCE_T0 = T9.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T9.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T9.SRC_DICT_CLS_CD = 'C_NOTRAN_INFLUENCE_T0' --源字典分类
   AND T9.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.VC_CURRENCY_NO = T10.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T10.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T10.SRC_DICT_CLS_CD = 'C_CURRENCY' --源字典分类
   AND T10.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT = '${p_end_dt}'

;

-- 保留近一周数据
ALTER TABLE DWDXDAY.DWD_TRAN_CPTL_MANUAL_BUSIN_PFD DROP PARTITION(P_DT <= '${day_8_ago}')
;

"
