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
-- ** 主    题:交易
-- ** 描    述:证券转换明细表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-07-04
-- ** 修改日志:
-- ** 2023-07-04，xiemn，新建
-- ** 目 标 表：DWSXDAY.DWS_TRAN_SCR_CHANGE_DETAIL_PTD        证券转换明细表
-- ** 源    表：DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD    O32场外业务确认表
-- **           DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO 标准字典分类枚举信息
-- **           DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD   账套产品基本信息
-- **           DWDXDAY.DWD_PROD_PORTF_PFD             O32投资组合表
-- **           DWDXDAY.DWD_PROD_AST_UNIT_PFD          O32资产单元表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD     证券基本信息
-- **           DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD      证券分类信息
-- **           DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD  O32指令证券明细表
-- **************************************************************************

set mapred.max.split.size=256000000;                                        
set mapred.min.split.size.per.node=100000000;                               
set mapred.min.split.size.per.rack=100000000;                               
set hive.merge.mapredfiles=true;                                            
set hive.merge.mapfiles=true;                                               
set hive.merge.smallfiles.avgsize=16000000;                                 
set hive.merge.size.per.task=256000000;                                     
set hive.exec.reducers.bytes.per.reducer=10240000000;                       
set mapreduce.job.reduces=1;                                                

ALTER TABLE DWSXDAY.DWS_TRAN_SCR_CHANGE_DETAIL_PTD DROP PARTITION(P_DT='${p_end_dt}')
;
INSERT OVERWRITE TABLE DWSXDAY.DWS_TRAN_SCR_CHANGE_DETAIL_PTD PARTITION(P_DT='${p_end_dt}')
SELECT 
       T1.BUSIN_DATE                                                                 AS TRAN_DATE                               --交易日期
     , T1.ISTCT_SERIALNO                                                             AS ISTCT_SERIALNO                          --指令序号
     , T1.ISTCT_MODIFY_SERIALNO                                                      AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T1.BUSIN_CATG_CODE                                                            AS BUSIN_CATG_CODE                         --业务分类代码
     , T7.STD_DICT_CLS_CDVAL_DESC                                                    AS BUSIN_CATG_NAME                         --业务分类名称
     , T1.ENTU_ORNT_CODE                                                             AS ENTU_ORNT_CODE                          --委托方向代码
     , T8.STD_DICT_CLS_CDVAL_DESC                                                    AS ENTU_ORNT_NAME                          --委托方向名称
     , T1.CNFM_NO                                                                    AS OUT_DEAL_SERIALNO                       --转出成交序号
     , T1.CNFM_NO                                                                    AS OUT_DEAL_NO                             --转出成交编号
     , T1.SFAC_NUM                                                                   AS OUT_SFAC_NUM                            --转出账套编码
     , T1.PROD_CODE                                                                  AS OUT_PROD_CODE                           --转出产品代码
     , T1.PROD_INCD                                                                  AS OUT_PROD_INCD                           --转出产品内码
     , T2.CSNAME                                                                     AS OUT_PROD_NAME                           --转出产品名称
     , T3.AST_UNIT_SERIALNO                                                          AS OUT_AST_UNIT_SERIALNO                   --转出资产单元序号
     , T4.AST_UNIT_NAME                                                              AS OUT_AST_UNIT_NAME                       --转出资产单元名称
     , T1.PORTF_SERIALNO                                                             AS OUT_PORTF_SERIALNO                      --转出投资组合序号
     , T3.PORTF_NAME                                                                 AS OUT_PORTF_NAME                          --转出投资组合名称
     , T1.SCR_NUM                                                                    AS OUT_SCR_NUM                             --转出证券编码
     , T1.SYMBOL                                                                     AS OUT_SYMBOL                              --转出证券代码
     , T1.SCR_INCD                                                                   AS OUT_SCR_INCD                            --转出证券内码
     , T5.SCR_SNAME                                                                  AS OUT_SCR_NAME                            --转出证券名称
     , T6.SCR_PRI_CATG_CODE                                                          AS OUT_SCR_PRI_CATG_CODE                   --转出证券一级分类代码
     , T6.SCR_PRI_CATG_NAME                                                          AS OUT_SCR_PRI_CATG_NAME                   --转出证券一级分类名称
     , T6.SCR_SCD_CATG_CODE                                                          AS OUT_SCR_SCD_CATG_CODE                   --转出证券二级分类代码
     , T6.SCR_SCD_CATG_NAME                                                          AS OUT_SCR_SCD_CATG_NAME                   --转出证券二级分类名称
     , T1.HOLDER_CODE                                                                AS OUT_HOLDER_CODE                         --转出股东代码
     , T1.REP_SEAT                                                                   AS OUT_SEAT_CODE                           --转出席位代码
     , T1.MKT_CODE                                                                   AS OUT_MKT_CODE                            --转出市场代码
     , T16.STD_DICT_CLS_CDVAL_DESC                                                   AS OUT_MKT_NAME                            --转出市场名称
     , NVL(T1.QTY,0)                                                                 AS OUT_QTY                                 --转出数量
     , NVL(T1.PRC,0)                                                                 AS OUT_PRC                                 --转出价格
     , NVL(T1.AMT,0)                                                                 AS OUT_AMT                                 --转出金额
     , T9.CNFM_NO                                                                    AS IN_DEAL_SERIALNO                        --转入成交序号
     , T1.SFAC_NUM                                                                   AS IN_SFAC_NUM                             --转入账套编码
     , T1.PROD_CODE                                                                  AS IN_PROD_CODE                            --转入产品代码
     , T1.PROD_INCD                                                                  AS IN_PROD_INCD                            --转入产品内码
     , T10.CSNAME                                                                    AS IN_PROD_NAME                            --转入产品名称
     , T11.AST_UNIT_SERIALNO                                                         AS IN_AST_UNIT_SERIALNO                    --转入资产单元序号
     , T12.AST_UNIT_NAME                                                             AS IN_AST_UNIT_NAME                        --转入资产单元名称
     , T9.PORTF_SERIALNO                                                             AS IN_PORTF_SERIALNO                       --转入投资组合序号
     , T11.PORTF_NAME                                                                AS IN_PORTF_NAME                           --转入投资组合名称
     , T9.SCR_NUM                                                                    AS IN_SCR_NUM                              --转入证券编码
     , T9.SYMBOL                                                                     AS IN_SYMBOL                               --转入证券代码
     , T9.SCR_INCD                                                                   AS IN_SCR_INCD                             --转入证券内码
     , T13.SCR_SNAME                                                                 AS IN_SCR_NAME                             --转入证券名称
     , T14.SCR_PRI_CATG_CODE                                                         AS IN_SCR_PRI_CATG_CODE                    --转入证券一级分类代码
     , T14.SCR_PRI_CATG_NAME                                                         AS IN_SCR_PRI_CATG_NAME                    --转入证券一级分类名称
     , T14.SCR_SCD_CATG_CODE                                                         AS IN_SCR_SCD_CATG_CODE                    --转入证券二级分类代码
     , T14.SCR_SCD_CATG_NAME                                                         AS IN_SCR_SCD_CATG_NAME                    --转入证券二级分类名称
     , T9.MKT_CODE                                                                   AS IN_MKT_CODE                             --转入市场代码
     , T17.STD_DICT_CLS_CDVAL_DESC                                                   AS IN_MKT_NAME                             --转入市场名称
     , T9.INV_TYPE_CODE                                                              AS IN_INV_TYPE_CODE                        --转入投资类型代码
     , T18.STD_DICT_CLS_CDVAL_DESC                                                   AS IN_INV_TYPE_NAME                        --转入投资类型名称
     , T15.LIQUI_VELOCITY_CODE                                                       AS IN_LIQUI_VELOCITY_CODE                  --转入清算速度代码
     , T19.STD_DICT_CLS_CDVAL_DESC                                                   AS IN_LIQUI_VELOCITY_NAME                  --转入清算速度名称
     , T9.HOLDER_CODE                                                                AS IN_HOLDER_CODE                          --转入股东代码
     , T9.REP_SEAT                                                                   AS IN_SEAT_CODE                            --转入席位代码
     , NVL(T9.QTY,0)                                                                 AS IN_DEAL_QTY                             --转入成交数量
     , NVL(T9.PRC,0)                                                                 AS IN_PRC                                  --转入价格
     , NVL(T9.AMT,0)                                                                 AS IN_AMT                                  --转入金额
     , 'DWD_TRAN_OTC_BUSIN_CNFM_PTD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
  FROM DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD T1  --O32场外业务确认表
 INNER JOIN DWDXDAY.DWD_TRAN_OTC_BUSIN_CNFM_PTD T9 --O32场外业务确认表
    ON T1.ISTCT_SERIALNO = T9.ISTCT_SERIALNO
   AND T1.ISTCT_MODIFY_SERIALNO = T9.ISTCT_MODIFY_SERIALNO
   AND T9.ENTU_ORNT_CODE IN ('58','61')   --58 基金转换 61 跨市场转托管
   AND T9.BUSIN_PROCE_CATG_CODE = '06'    --业务过程分类代码 06开基转换入确认
   AND T9.STAT_CODE = '01'                --状态代码为01-正常
   AND T9.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
   AND T1.P_DT = T9.P_DT
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T2 --账套产品基本信息
    ON T1.SFAC_NUM = T2.SFAC_NUM
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_PORTF_PFD T3 --O32投资组合表
    ON T1.PORTF_SERIALNO = T3.PORTF_SERIALNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_AST_UNIT_PFD T4 --O32资产单元表
    ON T3.AST_UNIT_SERIALNO = T4.AST_UNIT_SERIALNO
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T5 --证券基本信息
    ON T1.SCR_NUM = T5.SCR_NUM --证券编码
   AND T5.VALID_FLAG = '1'
   AND T5.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD T6 --证券分类信息
    ON T1.SCR_NUM = T6.SCR_NUM --证券编码
   AND T6.SSYS = 'O32'
   AND T6.VALID_FLAG = '1'
   AND T6.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T7 --标准字典分类枚举信息
    ON T7.STD_DICT_CLS_CD = 'ISTCT_BUSIN_TYPES_CODE'
   AND T7.STD_DICT_CLS_CDVAL = T1.BUSIN_CATG_CODE
   AND T7.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T8 --标准字典分类枚举信息
    ON T8.STD_DICT_CLS_CD = 'ENTR_ORIENTATION_CODE'
   AND T8.STD_DICT_CLS_CDVAL = T1.ENTU_ORNT_CODE
   AND T8.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T10 --账套产品基本信息
    ON T9.SFAC_NUM = T10.SFAC_NUM
   AND T10.VALID_FLAG = '1'
   AND T10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_PORTF_PFD T11 --O32投资组合表
    ON T9.PORTF_SERIALNO = T11.PORTF_SERIALNO
   AND T11.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_AST_UNIT_PFD T12 --O32资产单元表
    ON T11.AST_UNIT_SERIALNO = T12.AST_UNIT_SERIALNO
   AND T12.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T13 --证券基本信息
    ON T9.SCR_NUM = T13.SCR_NUM --证券编码
   AND T13.VALID_FLAG = '1'
   AND T13.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD T14 --证券分类信息
    ON T9.SCR_NUM = T14.SCR_NUM --证券编码
   AND T14.SSYS = 'O32'
   AND T14.VALID_FLAG = '1' --有效标志
   AND T14.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD T15 --O32指令证券明细表
    ON T9.ISTCT_SERIALNO = T15.ISTCT_SERIALNO
   AND T9.ISTCT_MODIFY_SERIALNO = T15.ISTCT_MODIFY_SERIALNO
   AND T9.SCR_INCD = T15.OTHS_SCR_INCD
   AND T15.ENTU_ORNT_CODE IN ('58','61') --58 基金转换 61 跨市场转托管
   AND T15.RISK_INFLU_FLAG_CODE = '0'    --0正常
   AND T9.ISTCT_RELE_DATE = T15.P_DT
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T16 --标准字典分类枚举信息
    ON T16.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T16.STD_DICT_CLS_CDVAL = T1.MKT_CODE
   AND T16.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T17 --标准字典分类枚举信息
    ON T17.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T17.STD_DICT_CLS_CDVAL = T9.MKT_CODE
   AND T17.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T18 --标准字典分类枚举信息
    ON T18.STD_DICT_ID = 'DIC0000014'
   AND T18.STD_DICT_CLS_CDVAL = T9.INV_TYPE_CODE
   AND T18.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T19 --标准字典分类枚举信息
    ON T19.STD_DICT_ID = 'DIC0000061'
   AND T19.STD_DICT_CLS_CDVAL = T15.LIQUI_VELOCITY_CODE
   AND T19.VALID_FLAG = '1' --有效标志
WHERE T1.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
  AND T1.ENTU_ORNT_CODE IN ('58','61')        --58 基金转换 61 跨市场转托管
  AND T1.BUSIN_PROCE_CATG_CODE = '05'         --业务过程分类代码 05 开基转换出确认
  AND T1.STAT_CODE = '01'                     --状态代码为 01-正常
;

INSERT INTO TABLE DWSXDAY.DWS_TRAN_SCR_CHANGE_DETAIL_PTD PARTITION(P_DT='${p_end_dt}')
SELECT 
       T1.BUSIN_DATE                                                                 AS TRAN_DATE                               --交易日期
     , T1.ISTCT_SERIALNO                                                             AS ISTCT_SERIALNO                          --指令序号
     , T1.ISTCT_MODIFY_SERIALNO                                                      AS ISTCT_MODIFY_SERIALNO                   --指令修改序号
     , T1.BUSIN_CATG_CODE                                                            AS BUSIN_CATG_CODE                         --业务分类代码
     , T7.STD_DICT_CLS_CDVAL_DESC                                                    AS BUSIN_CATG_NAME                         --业务分类名称
     , T1.ENTU_ORNT_CODE                                                             AS ENTU_ORNT_CODE                          --委托方向代码
     , T8.STD_DICT_CLS_CDVAL_DESC                                                    AS ENTU_ORNT_NAME                          --委托方向名称
     , T1.ISTCT_SERIALNO                                                             AS OUT_DEAL_SERIALNO                       --转出成交序号
     , T1.ISTCT_SERIALNO                                                             AS OUT_DEAL_NO                             --转出成交编号
     , T1.SFAC_NUM                                                                   AS OUT_SFAC_NUM                            --转出账套编码
     , T1.PROD_CODE                                                                  AS OUT_PROD_CODE                           --转出产品代码
     , T1.PROD_INCD                                                                  AS OUT_PROD_INCD                           --转出产品内码
     , T2.CSNAME                                                                     AS OUT_PROD_NAME                           --转出产品名称
     , T3.AST_UNIT_SERIALNO                                                          AS OUT_AST_UNIT_SERIALNO                   --转出资产单元序号
     , T4.AST_UNIT_NAME                                                              AS OUT_AST_UNIT_NAME                       --转出资产单元名称
     , T1.PORTF_SERIALNO                                                             AS OUT_PORTF_SERIALNO                      --转出投资组合序号
     , T3.PORTF_NAME                                                                 AS OUT_PORTF_NAME                          --转出投资组合名称
     , T1.SCR_NUM                                                                    AS OUT_SCR_NUM                             --转出证券编码
     , T1.SYMBOL                                                                     AS OUT_SYMBOL                              --转出证券代码
     , T1.SCR_INCD                                                                   AS OUT_SCR_INCD                            --转出证券内码
     , T5.SCR_SNAME                                                                  AS OUT_SCR_NAME                            --转出证券名称
     , T6.SCR_PRI_CATG_CODE                                                          AS OUT_SCR_PRI_CATG_CODE                   --转出证券一级分类代码
     , T6.SCR_PRI_CATG_NAME                                                          AS OUT_SCR_PRI_CATG_NAME                   --转出证券一级分类名称
     , T6.SCR_SCD_CATG_CODE                                                          AS OUT_SCR_SCD_CATG_CODE                   --转出证券二级分类代码
     , T6.SCR_SCD_CATG_NAME                                                          AS OUT_SCR_SCD_CATG_NAME                   --转出证券二级分类名称
     , NULL                                                                          AS OUT_HOLDER_CODE                         --转出股东代码
     , NULL                                                                          AS OUT_SEAT_CODE                           --转出席位代码
     , T5.TRAN_MKT_CODE                                                              AS OUT_MKT_CODE                            --转出市场代码
     , T16.STD_DICT_CLS_CDVAL_DESC                                                   AS OUT_MKT_NAME                            --转出市场名称
     , NVL(T1.ISTCT_VOL,0)                                                           AS OUT_QTY                                 --转出数量
     , NVL(T1.ISTCT_PRC,0)                                                           AS OUT_PRC                                 --转出价格
     , NVL(T1.ISTCT_VOL,0)*NVL(T1.ISTCT_PRC,0)                                       AS OUT_AMT                                 --转出金额
     , T9.ISTCT_SERIALNO                                                             AS IN_DEAL_SERIALNO                        --转入成交序号
     , T9.SFAC_NUM                                                                   AS IN_SFAC_NUM                             --转入账套编码
     , T9.PROD_CODE                                                                  AS IN_PROD_CODE                            --转入产品代码
     , T9.PROD_INCD                                                                  AS IN_PROD_INCD                            --转入产品内码
     , T10.CSNAME                                                                    AS IN_PROD_NAME                            --转入产品名称
     , T11.AST_UNIT_SERIALNO                                                         AS IN_AST_UNIT_SERIALNO                    --转入资产单元序号
     , T12.AST_UNIT_NAME                                                             AS IN_AST_UNIT_NAME                        --转入资产单元名称
     , T9.PORTF_SERIALNO                                                             AS IN_PORTF_SERIALNO                       --转入投资组合序号
     , T11.PORTF_NAME                                                                AS IN_PORTF_NAME                           --转入投资组合名称
     , T9.SCR_NUM                                                                    AS IN_SCR_NUM                              --转入证券编码
     , T9.SYMBOL                                                                     AS IN_SYMBOL                               --转入证券代码
     , T9.SCR_INCD                                                                   AS IN_SCR_INCD                             --转入证券内码
     , T13.SCR_SNAME                                                                 AS IN_SCR_NAME                             --转入证券名称
     , T14.SCR_PRI_CATG_CODE                                                         AS IN_SCR_PRI_CATG_CODE                    --转入证券一级分类代码
     , T14.SCR_PRI_CATG_NAME                                                         AS IN_SCR_PRI_CATG_NAME                    --转入证券一级分类名称
     , T14.SCR_SCD_CATG_CODE                                                         AS IN_SCR_SCD_CATG_CODE                    --转入证券二级分类代码
     , T14.SCR_SCD_CATG_NAME                                                         AS IN_SCR_SCD_CATG_NAME                    --转入证券二级分类名称
     , T13.TRAN_MKT_CODE                                                             AS IN_MKT_CODE                             --转入市场代码
     , T17.STD_DICT_CLS_CDVAL_DESC                                                   AS IN_MKT_NAME                             --转入市场名称
     , T9.INV_TYPE_CODE                                                              AS IN_INV_TYPE_CODE                        --转入投资类型代码
     , T18.STD_DICT_CLS_CDVAL_DESC                                                   AS IN_INV_TYPE_NAME                        --转入投资类型名称
     , T9.LIQUI_VELOCITY_CODE                                                        AS IN_LIQUI_VELOCITY_CODE                  --转入清算速度代码
     , T19.STD_DICT_CLS_CDVAL_DESC                                                   AS IN_LIQUI_VELOCITY_NAME                  --转入清算速度名称
     , NULL                                                                          AS IN_HOLDER_CODE                          --转入股东代码
     , NULL                                                                          AS IN_SEAT_CODE                            --转入席位代码
     , NVL(T9.ISTCT_VOL,0)                                                           AS IN_DEAL_QTY                             --转入成交数量
     , NVL(T9.ISTCT_PRC,0)                                                           AS IN_PRC                                  --转入价格
     , NVL(T9.ISTCT_AMT,0)                                                           AS IN_AMT                                  --转入金额
     , 'DWD_TRAN_ISTCT_SCR_DETAIL_PTD'                                               AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
  FROM (SELECT A.BUSIN_DATE                                                                                                     --业务日期
             , A.ISTCT_SERIALNO                                                                                                 --指令序号
             , A.BUSIN_CATG_CODE                                                                                                --业务分类代码
             , A.ENTU_ORNT_CODE                                                                                                 --委托方向代码
             , A.SFAC_NUM                                                                                                       --账套编码
             , A.PROD_CODE                                                                                                      --产品代码
             , A.PROD_INCD                                                                                                      --转出产品内码
             , A.PORTF_SERIALNO                                                                                                 --转出投资组合序号
             , A.SCR_NUM                                                                                                        --转出证券编码
             , A.SYMBOL                                                                                                         --转出证券代码
             , A.SCR_INCD                                                                                                       --转出证券内码
             , NVL(A.ISTCT_VOL,0)                                AS  ISTCT_VOL                                                  --指令数量
             , NVL(A.ISTCT_PRC,0)                                AS  ISTCT_PRC                                                  --指令价格
             , A.ISTCT_MODIFY_SERIALNO                                                                                          --指令修改序号
             , A.P_DT                                                                                                           --分区值
             , A.ISTCT_STAT_CODE                                                                                                --指令状态代码
             , ROW_NUMBER() OVER(PARTITION BY A.ISTCT_SERIALNO ORDER BY A.ISTCT_MODIFY_SERIALNO DESC) RN                        --指令序号排序
          FROM DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD A  --O32指令证券明细表
         WHERE A.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
           AND A.ENTU_ORNT_CODE  = '50'                          -- 50 转股
           AND A.ISTCT_STAT_CODE = '01'                          -- 状态代码为 01-正常
       ) T1  --O32指令证券明细表
 INNER JOIN DWDXDAY.DWD_TRAN_ISTCT_SCR_DETAIL_PTD T9 --O32指令证券明细表
    ON T1.ISTCT_SERIALNO = T9.ISTCT_SERIALNO
   AND T1.ISTCT_MODIFY_SERIALNO = T9.ISTCT_MODIFY_SERIALNO
   AND T9.ENTU_ORNT_CODE = '02'  --02-买入
   AND T9.ISTCT_STAT_CODE = '01' --状态代码为01-正常
   AND T9.P_DT BETWEEN '${p_start_dt}' AND '${p_end_dt}'
   AND T1.P_DT = T9.P_DT
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T2 --账套产品基本信息
    ON T1.SFAC_NUM = T2.SFAC_NUM
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_PORTF_PFD T3 --O32投资组合表
    ON T1.PORTF_SERIALNO = T3.PORTF_SERIALNO
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_AST_UNIT_PFD T4 --O32资产单元表
    ON T3.AST_UNIT_SERIALNO = T4.AST_UNIT_SERIALNO
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T5 --证券基本信息
    ON T1.SCR_NUM = T5.SCR_NUM --证券编码
   AND T5.VALID_FLAG = '1'
   AND T5.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD T6 --证券分类信息
    ON T1.SCR_NUM = T6.SCR_NUM --证券编码
   AND T6.SSYS = 'O32'
   AND T6.VALID_FLAG = '1'
   AND T6.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T7 --标准字典分类枚举信息
    ON T7.STD_DICT_CLS_CD = 'ISTCT_BUSIN_TYPES_CODE'
   AND T7.STD_DICT_CLS_CDVAL = T1.BUSIN_CATG_CODE
   AND T7.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T8 --标准字典分类枚举信息
    ON T8.STD_DICT_CLS_CD = 'ENTR_ORIENTATION_CODE'
   AND T8.STD_DICT_CLS_CDVAL = T1.ENTU_ORNT_CODE
   AND T8.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T10 --账套产品基本信息
    ON T9.SFAC_NUM = T10.SFAC_NUM
   AND T10.VALID_FLAG = '1' --有效标志
   AND T10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_PORTF_PFD T11 --O32投资组合表
    ON T9.PORTF_SERIALNO = T11.PORTF_SERIALNO
   AND T11.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_PROD_AST_UNIT_PFD T12 --O32资产单元表
    ON T11.AST_UNIT_SERIALNO = T12.AST_UNIT_SERIALNO
   AND T12.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T13 --证券基本信息
    ON T9.SCR_NUM = T13.SCR_NUM --证券编码
   AND T13.VALID_FLAG = '1' --有效标志
   AND T13.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD T14 --证券分类信息
    ON T9.SCR_NUM = T14.SCR_NUM --证券编码
   AND T14.SSYS = 'O32'
   AND T14.VALID_FLAG = '1' --有效标志
   AND T14.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T16 --标准字典分类枚举信息
    ON T16.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T16.STD_DICT_CLS_CDVAL = T5.TRAN_MKT_CODE
   AND T16.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T17 --标准字典分类枚举信息
    ON T17.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
   AND T17.STD_DICT_CLS_CDVAL = T13.TRAN_MKT_CODE
   AND T17.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T18 --标准字典分类枚举信息
    ON T18.STD_DICT_ID = 'DIC0000014'
   AND T18.STD_DICT_CLS_CDVAL = T9.INV_TYPE_CODE
   AND T18.VALID_FLAG = '1' --有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T19 --标准字典分类枚举信息
    ON T19.STD_DICT_ID = 'DIC0000061'
   AND T19.STD_DICT_CLS_CDVAL = T9.LIQUI_VELOCITY_CODE
   AND T19.VALID_FLAG = '1' --有效标志
 WHERE T1.RN = 1 
;
"