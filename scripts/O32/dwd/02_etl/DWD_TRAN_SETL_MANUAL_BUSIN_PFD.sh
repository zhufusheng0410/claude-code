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
-- ** 描    述:结算手工类业务表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-19
-- ** 修改日志:
-- ** 2023-06-19，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_TRAN_SETL_MANUAL_BUSIN_PFD   结算手工类业务表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TSTRIKEBUSINESS_PFD 结算类业务表
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD         证券编码映射
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP       标准码值字典映射表
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD       证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_TRAN_SETL_MANUAL_BUSIN_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_BUSIN_NO                                                                 AS BUSIN_SERIALNO                          --业务序号
     , T1.L_BATCH_NO                                                                 AS BAT_NO                                  --批号
     , T1.L_DATE                                                                     AS OCCUR_DATE                              --发生日期
     , T1.L_TIME                                                                     AS OCCUR_TIME                              --发生时间
     , T1.L_REGISTER_DATE                                                            AS EQUI_DATE                               --权益日期
     , CASE 
         WHEN T1.VC_BUSIN_OPFLAG IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.VC_BUSIN_OPFLAG)) 
       END                                                                           AS BUSIN_OPER_TYPE_CODE                    --业务操作类型代码
     , T3.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T4.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T1.EN_RATIO                                                                   AS ASSN_RATE                               --分配比例
     , T1.EN_PRICE                                                                   AS PRC                                     --价格
     , T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , T1.VC_MEMO                                                                    AS MEMO                                    --备注
     , T1.L_CHECK_DATE                                                               AS CHK_DATE                                --复核日期
     , T1.L_CHECK_TIME                                                               AS CHK_TIME                                --复核时间
     , T1.L_CHECK_OPERATOR                                                           AS AUDITOR_CODE                            --复核员代码
     , T1.C_CHECK_FLAG                                                               AS CHK_FLAG                                --复核标志
     , T1.VC_CHECK_MEMO                                                              AS CHK_MEMO                                --复核备注
     , T1.C_DEAL_FLAG                                                                AS DEAL_FLAG                               --处理标志
     , T1.D_DATETIME                                                                 AS TIME_STAMP                              --时间戳
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TSTRIKEBUSINESS_PFD'                                                 AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TSTRIKEBUSINESS_PFD T1  --结算类业务表
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T3 --证券编码映射
    ON T1.VC_INTER_CODE = T3.SCR_INCD --证券内码
   AND T3.SSYS = 'O32' --源系统
   AND T3.ST_DATE <= '${p_end_dt}' --开始日期
   AND T3.END_DATE >= '${p_end_dt}' --结束日期
   AND T3.VALID_FLAG = '1' --有效标志
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T4 --证券基本信息
    ON T3.SCR_NUM = T4.SCR_NUM
   AND T4.VALID_FLAG = '1' --有效标志
   AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T1.VC_BUSIN_OPFLAG = T5.SRC_DICT_CLS_CDVAL --源字典分类码值
   AND T5.SSYS = 'O32' --源系统简称比如O32\FA45
   AND T5.SRC_DICT_CLS_CD = 'VC_SETL_BUSIN_OPFLAG' --源字典分类
   AND T5.VALID_FLAG = '1' --有效标志
 WHERE T1.P_DT = '${p_end_dt}'

;

-- 保留近一周数据
ALTER TABLE DWDXDAY.DWD_TRAN_SETL_MANUAL_BUSIN_PFD DROP PARTITION(P_DT <= '${day_8_ago}')
;


"
