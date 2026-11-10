#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:资讯
-- ** 描    述:债券信息表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_SCR_BOND_INFO_PFD          债券信息表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TBONDPROPERTY_PFD 债券属性表
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD       证券编码映射
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD     证券基本信息
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP     标准码值字典映射表
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
    set mapreduce.job.reduces=5;

INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_BOND_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T3.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T3.SCR_SNAME                                                                  AS SCR_NAME                                --证券名称
     , T3.TRAN_MKT_CODE                                                              AS MKT_CODE                                --市场代码
     , T4.SCR_SCD_CATG_CODE                                                          AS SCR_CATG_CODE                           --证券类别代码
     , T4.SCR_SCD_CATG_NAME                                                          AS SCR_CATG_NAME                           --证券类别名称
     , T1.L_PUBLISH_DATE                                                             AS SUE_DATE                                --发行日期
     , T1.L_END_DATE                                                                 AS END_DATE                                --结束日期
     , T1.L_BEGINCAL_DATE                                                            AS VALUE_DATE                              --起息日期
     , T1.L_MARKET_DATE                                                              AS LIST_DATE                               --上市日期
     , T1.EN_EXIST_LIMITE                                                            AS MATY                                    --期限(单位:年)
     , T1.EN_PUBLISH_PRICE                                                           AS SUE_PRIC                                --发行价
     , T1.EN_FACE_PRICE                                                              AS PARV                                    --面额
     , T1.EN_YEAR_RATE                                                               AS COUP                                    --票面利率
     , T1.L_RATE_DAYS                                                                AS CALCT_INTR_DAYS                         --计息天数
     , T1.EN_PAY_INTEVAL                                                             AS YEAR_INTP_TIMES                         --年付息次数
     , T1.EN_BOND_INTEREST                                                           AS HUD_BOND_INTR                           --百元债券利息
     , T1.EN_REAL_INTEREST                                                           AS ACTL_INTR                               --实际利息
     , T1.EN_NEXT_BOND_INTEREST                                                      AS NEXT_DAY_INTR                           --下一日利息
     , T1.C_SUBJECT_TYPE                                                             AS CALCT_CRSE_CATG_FLAG                    --计算科目类别标志
     , CASE 
         WHEN T1.C_INSIDE_APPRAISE IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INSIDE_APPRAISE)) 
       END                                                                           AS INR_RAT_CODE                            --内部评级代码
     , CASE 
         WHEN T1.C_OUTER_APPRAISE IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_OUTER_APPRAISE)) 
       END                                                                           AS EXT_RAT_CODE                            --外部评级代码
     , NULL                                                                          AS NETPRC_FLAG                             --净价标志
     , NULL                                                                          AS BASIC_SPR                               --基本利差
     , CASE 
         WHEN T1.C_BASIC_RATE_TYPE IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BASIC_RATE_TYPE)) 
       END                                                                           AS BASI_INTR_TYPE_CODE                     --基准利率类型代码
     , NULL                                                                          AS GUAT_INTR                               --保底利率
     , CASE 
         WHEN T1.C_INVESTOR_OPERATION_TYPE IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVESTOR_OPERATION_TYPE)) 
       END                                                                           AS INVR_CHIC_TYPE_CODE                     --投资人选择权类型代码
     , NULL                                                                          AS INVR_EXER_DATE                          --投资人行权日期
     , CASE 
         WHEN T1.C_PUBLISHER_OPERATION_TYPE IS NOT NULL THEN 
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PUBLISHER_OPERATION_TYPE)) 
       END                                                                           AS ISSR_CHIC_TYPE_CODE                     --发行人选择权类型代码
     , NULL                                                                          AS ISSR_EXER_DATE                          --发行人行权日期
     , NULL                                                                          AS CUSTOD_CODE                             --托管机构代码
     , T10.STD_DICT_CLS_CDVAL_DESC                                                   AS CUSTOD_NAME                             --托管机构名称
     , CASE 
         WHEN T1.C_INTEREST_TYPE IS NOT NULL THEN 
          COALESCE(T11.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INTEREST_TYPE)) 
       END                                                                           AS INTR_TYPE_CODE                          --利率类型代码
     , CASE 
         WHEN T1.C_PAY_INTEREST_TYPE IS NOT NULL THEN 
          COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PAY_INTEREST_TYPE)) 
       END                                                                           AS INTP_TYPE_CODE                          --付息类型代码
     , T1.VC_APPRAISE_ORGAN                                                          AS EXT_RAT_ORG                             --外部评级机构
     , T1.L_LEFT_TERM                                                                AS REMA_DURA                               --剩余久期(单位:天)
     , T1.EN_MATURITY                                                                AS MAC_DURA                                --麦氏久期
     , T1.EN_MATURITY_ADJUST                                                         AS CORR_DURA                               --修正久期
     , T1.EN_CHANGE_PRICE                                                            AS TDY_CONVSTK_PRC                         --T日转股价格
     , T1.L_CHANGE_BEGIN_DATE                                                        AS CONVSTK_ST_DATE                         --转股开始日期
     , T1.L_CHANGE_END_DATE                                                          AS CONVSTK_END_DATE                        --转股结束日期
     , T1.EN_INVESTOR_OPERATION_PRICE                                                AS INVR_EXER_PRC                           --投资人行权价格
     , T1.EN_PUBLISHER_OPERATION_PRICE                                               AS ISSR_EXER_PRC                           --发行人行权价格
     , T1.L_TRADE_DEADLINE                                                           AS TRAN_END_DATE                           --交易结束日期
     , T1.EN_FAIR_YIELD_RATIO                                                        AS CNBD_FAIR_YLD                           --中债登公允收益率
     , T1.EN_VALUATE_DURATION                                                        AS APPRA_CORR_DURA                         --估价修正久期
     , T1.EN_VALUATE_CONVEXITY                                                       AS APPRA_CVXY                              --估价凸性
     , T1.EN_VALUATE_POINT_VALUE                                                     AS APPRA_BPVAL                             --估价基点价值
     , T1.EN_VALUATE_SPREAD_DURATION                                                 AS APPRA_SPR_DURA                          --估价利差久期
     , T1.EN_VALUATE_RATE_DURATION                                                   AS APPRA_INTR_DURA                         --估价利率久期
     , T1.EN_YESTERDAY_CHANGE_PRICE                                                  AS TEST_CONVSTK_PRC                        --T-1日转股价格
     , T1.EN_POINT_VALUE                                                             AS BPVAL                                   --基点价值
     , T1.EN_CONVEXITY                                                               AS CVXY                                    --凸性
     , T1.L_STARTCAL_DATE                                                            AS ORI_VALUE_DATE                          --原始起息日期
     , CASE 
         WHEN T1.C_INTEREST_CALC_TYPE IS NOT NULL THEN 
          COALESCE(T13.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INTEREST_CALC_TYPE)) 
       END                                                                           AS INTR_CALCT_WAY_CODE                     --利息计算方法代码
     , CASE 
         WHEN T1.C_PAYMENTOFINTEREST_TYPE IS NOT NULL THEN 
          COALESCE(T14.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PAYMENTOFINTEREST_TYPE)) 
       END                                                                           AS DUE_INTP_MODE_CODE                      --到期付息方式代码
     , T1.L_GUARANTOR_ID                                                             AS GUARR_NUM                               --担保人编码
     , T1.EN_BP_CEILING                                                              AS INTR_ADJ_BP_TOPL                        --利率调整基点上限
     , T1.EN_BP_FLOOR                                                                AS INTR_ADJ_BP_LOWL                        --利率调整基点下限
     , T1.L_YEAR                                                                     AS VOU_TREA_YEAR                           --凭证式国债年份
     , T1.L_TIMES                                                                    AS VOU_TREA_PD_NUM                         --凭证式国债期数
     , T1.EN_CURR_FACE_PRICE                                                         AS CURR_PARV                               --当前面额
     , T1.L_NEXTPAYMENT_DATE                                                         AS NEXT_INTP_DATE                          --下一付息日期
     , CASE 
         WHEN T1.C_YIELD_RATIO_TYPE IS NOT NULL THEN 
          COALESCE(T15.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_YIELD_RATIO_TYPE)) 
       END                                                                           AS YLD_TYPE_CODE                           --收益率类型代码
     , T1.EN_TODAY_INTEREST                                                          AS TDY_INTR                                --当日利息
     , CASE 
         WHEN T1.C_PAY_CAPITAL_TYPE IS NOT NULL THEN 
          COALESCE(T16.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PAY_CAPITAL_TYPE)) 
       END                                                                           AS PRIN_REPY_TYPE_CODE                     --本金偿还类型代码
     , T1.L_OUTER_APPRAISE_DATE                                                      AS EXT_RAT_DATE                            --外部评级日期
     , T1.L_ZQHS_BEGINDATE                                                           AS DEBT_PUT_REG_ST_DATE                    --债回售登记开始日期
     , T1.L_ZQHS_ENDDATE                                                             AS DEBT_PUT_REG_END_DATE                   --债回售登记结束日期
     , T1.L_SUPERVENTION_MARKET_DATE                                                 AS RNEW_LIST_DATE                          --续发上市日期
     , T1.L_BOND_COUNT                                                               AS BOND_PD_NUM                             --债券期数
     , T1.L_NEXT_RATECHANGE_DATE                                                     AS NEXT_INTR_ADJ_DATE                      --下一利息调整日期
     , CASE 
         WHEN T1.C_DRAWBENCHMRK IS NOT NULL THEN 
          COALESCE(T17.STD_DICT_CLS_CD_VAL,CONCAT('@', T1.C_DRAWBENCHMRK)) 
       END                                                                           AS INTA_BASI_CODE                          --计息基准代码
     , T1.L_ISSUEBALANCE                                                             AS BOND_SUE_BAL                            --债券发行余额
     , T1.EN_ZZ_FAIR_YIELD_RATIO                                                     AS CSDC_FAIR_YLD                           --中证公允收益率
     , CASE 
         WHEN T1.C_LEVEL_EXPECTATION IS NOT NULL THEN 
          COALESCE(T18.STD_DICT_CLS_CD_VAL,CONCAT('@', T1.C_LEVEL_EXPECTATION)) 
       END                                                                           AS RAT_EXPE_CODE                           --评级展望代码
     , T1.L_MODIFY_DATE                                                              AS MAINT_DATE                              --维护日期
     , T1.L_NEXT_MODIFY_DATE                                                         AS NEXT_MAINT_DATE                         --下次维护日期
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TBONDPROPERTY_PFD'                                                   AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TBONDPROPERTY_PFD T1  --债券属性表
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2 --证券编码映射
    ON T1.VC_INTER_CODE = T2.SCR_INCD--证券内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T3 --证券基本信息
    ON T2.SCR_NUM = T3.SCR_NUM
   AND T3.VALID_FLAG = '1'--有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD  T4 --证券分类信息
    ON T2.SCR_NUM = T4.SCR_NUM --证券编码
   AND T4.SSYS = 'O32'
   AND T4.VALID_FLAG = '1'
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T5.SRC_DICT_CLS_CD = 'C_INSIDE_APPRAISE'--源字典分类
   AND T1.C_INSIDE_APPRAISE = T5.SRC_DICT_CLS_CDVAL
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T6.SRC_DICT_CLS_CD = 'C_OUTER_APPRAISE'--源字典分类
   AND T1.C_OUTER_APPRAISE = T6.SRC_DICT_CLS_CDVAL
   AND T6.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T6.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T7.SRC_DICT_CLS_CD = 'C_BASIC_RATE_TYPE'--源字典分类
   AND T1.C_BASIC_RATE_TYPE = T7.SRC_DICT_CLS_CDVAL
   AND T7.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T7.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T8.SRC_DICT_CLS_CD = 'C_INVESTOR_OPERATION_TYPE'--源字典分类
   AND T1.C_INVESTOR_OPERATION_TYPE = T8.SRC_DICT_CLS_CDVAL
   AND T8.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T9.SRC_DICT_CLS_CD = 'C_PUBLISHER_OPERATION_TYPE'--源字典分类
   AND T1.C_PUBLISHER_OPERATION_TYPE = T9.SRC_DICT_CLS_CDVAL
   AND T9.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T9.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准码值字典映射表
    ON T1.C_TRUSTEE = T10.SRC_DICT_CLS_CD--源字典分类码值
   AND T10.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T10.SRC_DICT_CLS_CD = 'C_TRUSTEE'--源字典分类
   AND T10.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T11 --标准码值字典映射表
    ON T11.SRC_DICT_CLS_CD = 'C_INTEREST_TYPE'--源字典分类
   AND T1.C_INTEREST_TYPE = T11.SRC_DICT_CLS_CDVAL
   AND T11.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T11.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准码值字典映射表
    ON T12.SRC_DICT_CLS_CD = 'C_PAY_INTEREST_TYPE'--源字典分类
   AND T1.C_PAY_INTEREST_TYPE = T12.SRC_DICT_CLS_CDVAL
   AND T12.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T12.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T13 --标准码值字典映射表
    ON T13.SRC_DICT_CLS_CD = 'C_INTEREST_CALC_TYPE'--源字典分类
   AND T1.C_INTEREST_CALC_TYPE = T13.SRC_DICT_CLS_CDVAL
   AND T13.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T13.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T14 --标准码值字典映射表
    ON T14.SRC_DICT_CLS_CD = 'C_PAYMENTOFINTEREST_TYPE'--源字典分类
   AND T1.C_PAYMENTOFINTEREST_TYPE = T14.SRC_DICT_CLS_CDVAL
   AND T14.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T14.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T15 --标准码值字典映射表
    ON T15.SRC_DICT_CLS_CD = 'C_YIELD_RATIO_TYPE'--源字典分类
   AND T1.C_YIELD_RATIO_TYPE = T15.SRC_DICT_CLS_CDVAL
   AND T15.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T15.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T16 --标准码值字典映射表
    ON T16.SRC_DICT_CLS_CD = 'C_PAY_CAPITAL_TYPE'--源字典分类
   AND T1.C_PAY_CAPITAL_TYPE = T16.SRC_DICT_CLS_CDVAL
   AND T16.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T16.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T17 --标准码值字典映射表
    ON T17.SRC_DICT_CLS_CD = 'C_INTEREST_PAY_FREQ'--源字典分类
   AND T1.C_DRAWBENCHMRK = T17.SRC_DICT_CLS_CDVAL
   AND T17.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T17.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T18 --标准码值字典映射表
    ON T18.SRC_DICT_CLS_CD = 'C_LEVEL_EXPECTATION '--源字典分类
   AND T1.C_LEVEL_EXPECTATION  = T18.SRC_DICT_CLS_CDVAL
   AND T18.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T18.VALID_FLAG = '1'--有效标志
 WHERE T1.P_DT = '${p_end_dt}'
;"
