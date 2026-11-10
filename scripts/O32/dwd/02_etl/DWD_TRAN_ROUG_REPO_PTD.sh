#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:交易
-- ** 描    述:在途回购表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_ROUG_REPO_PTD       在途回购表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_THGREGISTER_PTD 在途回购表
-- **           DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD   账套编码映射
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD     证券编码映射
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD   证券基本信息
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP   标准码值字典映射表
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
    set mapreduce.job.reduces=2;


INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_ROUG_REPO_PTD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_SERIAL_NO                                                                AS JOUR_SERIALNO                           --流水序号
     , T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T4.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T4.SCR_SCD_CATG_CODE                                                          AS SCR_CATG_CODE                           --证券类别代码
     , CASE 
         WHEN T1.C_ENTRUST_DIRECTION IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ENTRUST_DIRECTION)) 
       END                                                                           AS ENTU_ORNT_CODE                          --委托方向代码
     , CASE 
         WHEN T1.L_SETTLE_SPEED IS NOT NULL THEN 
          COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.L_SETTLE_SPEED)) 
       END                                                                           AS LIQUI_VELOCITY_CODE                     --清算速度代码
     , CASE 
         WHEN T1.C_CLEAR_TYPE IS NOT NULL THEN 
          COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CLEAR_TYPE)) 
       END                                                                           AS LIQUI_TYPE_CODE                         --清算类型代码
     , CASE 
         WHEN T1.C_MARKET_NO IS NOT NULL THEN 
          COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_MARKET_NO)) 
       END                                                                           AS MKT_CODE                                --市场代码
     , T1.VC_SEAT_ID                                                                 AS SEAT_CODE                               --席位代码
     , T1.VC_STOCKHOLDER_ID                                                          AS HOLDER_CODE                             --股东代码
     , T1.L_HG_DATE                                                                  AS REPO_BUSIN_DATE                         --回购业务日期
     , T1.L_REDEEM_DAYS                                                              AS REPO_DAYS                               --回购天数
     , T1.L_REDEEM_LAWDATE                                                           AS LEGA_BUYB_DATE                          --法定购回日期
     , T1.L_REDEEM_LIQUIDATE                                                         AS ACTL_BUYB_DATE                          --实际购回日期
     , T1.L_SETTLE_DATE                                                              AS BUYB_DELI_DATE                          --购回交割日期
     , T1.L_DEAL_AMOUNT                                                              AS DEAL_QTY                                --成交数量
     , T1.EN_DEAL_PRICE                                                              AS DEAL_PRC                                --成交价格
     , T1.EN_DEAL_BALANCE                                                            AS DEAL_AMT                                --成交金额
     , T1.EN_REDEEM_INTEREST                                                         AS REPO_INTR                               --回购利息
     , T1.EN_FEE                                                                     AS REPO_FEE                                --回购费用
     , CASE 
         WHEN T1.C_PURPOSE_TYPE IS NOT NULL THEN 
          COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PURPOSE_TYPE)) 
       END                                                                           AS REPO_USE_CATG_CODE                      --回购用途类别代码
     , T1.C_FROZEN_FLAG                                                              AS BUYB_FRZ_FLAG                           --购回冻结标志
     , T1.C_REDEAL_FLAG                                                              AS BUYB_DEAL_FLAG                          --购回处理标志
     , T1.L_REDEAL_DATE                                                              AS BUYB_DEAL_DATE                          --购回处理日期
     , T1.C_REDEAL_AVAILABLE_FLAG                                                    AS BUYB_USE_DEAL_FLAG                      --购回可用处理标志
     , T1.EN_FIRST_PRICE                                                             AS FST_TRAN_PRC                            --首次交易价格
     , T1.EN_FIRST_BOND_INTEREST                                                     AS FST_TRAN_HUD_BOND_INTR                  --首次交易百元债券利息
     , T1.EN_MATURE_PRICE                                                            AS DUE_TRAN_PRC                            --到期交易价格
     , T1.EN_MATURE_BOND_INTEREST                                                    AS DUE_ACCR_HUD_BOND_INTR                  --到期应计百元债券利息
     , T1.EN_INTEREST_PAYMENT_BALANCE                                                AS HALFWY_INTP_AMT                         --中途付息金额
     , T1.L_BUSIN_AMOUNT                                                             AS SCR_STK_DEAL_QTY                        --标的券成交数量
     , T1.EN_NOW_INTEREST                                                            AS CURR_OCC_INTR                           --当前已计利息
     , T1.L_YEAR_DAYS                                                                AS ACCRDAYS                                --计息天数
     , T1.EN_GH_BALANCE                                                              AS BUYB_AMT                                --购回金额
     , T1.EN_EXTRA_PAY_INTEREST                                                      AS APPD_INTP_AMT                           --追加付息金额
     , T1.EN_NEW_RATE                                                                AS DELY_IR                                 --延期利率
     , T1.L_NEW_REDEEM_DATE                                                          AS DELY_BUYB_DATE                          --延期购回日期
     , T1.EN_MORTGAGE_BALANCE                                                        AS PLG_AMT                                 --质押金额
     , T1.L_HG_TRADE_DATE                                                            AS DEAL_REPO_DATE                          --成交时回购日期
     , T1.VC_BASKET_NO                                                               AS PLG_STK_BASK_NO                         --质押券篮子编号
     , T1.L_ADD_DATE                                                                 AS LAST_SUPP_PLG_DATE                      --最后补充质押日期
     , T1.L_BACK_DATE                                                                AS LAST_AHED_BUYB_DATE                     --最后提前购回日期
     , T1.L_ADD_AMOUNT                                                               AS SUPP_PLG_QTY                            --补充质押数量
     , T1.EN_ORIGINAL_BALANCE                                                        AS ORI_AGMT_AMT                            --原合同金额
     , T1.EN_BACK_BALANCE                                                            AS AHED_BUYB_AMT                           --提前购回金额
     , T1.L_ORIGINAL_AMOUNT                                                          AS ORI_PLG_QTY                             --原质押数量
     , T1.L_BACK_AMOUNT                                                              AS AHED_BUYB_QTY                           --提前购回数量
     , T1.EN_PENALTY_INTEREST                                                        AS PNLT                                    --罚息
     , T1.L_ENTRUST_SERIAL_NO                                                        AS ENTU_SERIALNO                           --委托序号
     , T1.VC_DEAL_NO                                                                 AS DEAL_NO                                 --成交编号
     , T1.VC_CONTRACT_NO                                                             AS AGMT_SERIALNO                           --合同序号
     , T1.C_TRUSTEE                                                                  AS CUSTOD                                  --托管机构
     , T1.L_OPERATOR_NO                                                              AS DELR_CODE                               --交易员代码
     , T1.L_RIVAL_ID                                                                 AS CNTP_NUM                                --交易对手编码
     , T1.VC_RIVALTRADER_ID                                                          AS CNTP_DELR_ID                            --对手交易员id
     , T1.VC_RIVAL_SEAT                                                              AS CNTP_SEAT                               --对手席位
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_THGREGISTER_PTD'                                                     AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_THGREGISTER_PTD T1  --在途回购表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD--证券内码
   AND T3.SSYS = 'O32'--源系统
   AND T3.ST_DATE <= '${p_end_dt}'--开始日期
   AND T3.END_DATE >= '${p_end_dt}'--结束日期
   AND T3.VALID_FLAG = '1'--有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T4 --证券基本信息
    ON T3.SCR_NUM = T4.SCR_NUM
   AND T4.VALID_FLAG = '1'--有效标志
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.C_ENTRUST_DIRECTION  = T5.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'C_ENTRUST_DIRECTION'--源字典分类
   AND T5.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准码值字典映射表
    ON T1.L_SETTLE_SPEED = T6.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T6.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T6.SRC_DICT_CLS_CD = 'L_SETTLE_SPEED'--源字典分类
   AND T6.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准码值字典映射表
    ON T1.C_CLEAR_TYPE = T7.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T7.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T7.SRC_DICT_CLS_CD = 'C_CLEAR_TYPE'--源字典分类
   AND T7.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准码值字典映射表
    ON T1.C_MARKET_NO = T8.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T8.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T8.SRC_DICT_CLS_CD = 'C_MARKET_NO'--源字典分类
   AND T8.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准码值字典映射表
    ON T1.C_PURPOSE_TYPE = T9.SRC_DICT_CLS_CDVAL--源字典分类码值
   AND T9.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T9.SRC_DICT_CLS_CD = 'C_PURPOSE_TYPE'--源字典分类
   AND T9.VALID_FLAG = '1'--有效标志
WHERE (T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
  OR T1.P_DT='29991231'
 )
;

"
