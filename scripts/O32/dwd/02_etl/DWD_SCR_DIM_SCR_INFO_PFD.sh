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
-- ** 描    述:维度证券信息表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_SCR_DIM_SCR_INFO_PFD     维度证券信息表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TTRADESTOCK_PFD 维度证券表
-- **           ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD 维度定义表
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP   标准码值字典映射表
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD     证券编码映射
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD   证券基本信息
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_DIM_SCR_INFO_PFD
PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T1.L_SERIAL_ID                                                                AS DIM_SERIALNO                            --维度序号
     , T4.VC_TRADE_NAME                                                              AS DIM_NAME                                --维度名称
     , CASE 
         WHEN T4.C_TRADE_TYPE IS NOT NULL THEN 
          COALESCE(T5.STD_DICT_CLS_CD_VAL,CONCAT('@',T4.C_TRADE_TYPE)) 
       END                                                                           AS DIM_CATG_CODE                           --维度类别代码
     , T5.STD_DICT_CLS_CDVAL_DESC                                                    AS DIM_CATG_NAME                           --维度类别名称
     , T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T3.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T1.L_ADD_DATE                                                                 AS ADD_DATE                                --加入日期
     , T1.L_ADD_TIME                                                                 AS ADD_TIME                                --加入时间
     , T1.L_BEGIN_DATE                                                               AS VALID_ST_DATE                           --有效开始日期
     , T1.L_END_DATE                                                                 AS VALID_END_DATE                          --有效结束日期
     , T1.L_CHECK_OPERATOR                                                           AS AUDITOR_CODE                            --复核员代码
     , T1.L_CREATE_DATE                                                              AS CRT_DATE                                --创建日期
     , T1.L_CREATE_TIME                                                              AS CRT_TIME                                --创建时间
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TTRADESTOCK_PFD'                                                     AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TTRADESTOCK_PFD T1  --维度证券表
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD T2 --证券编码映射
    ON T1.VC_INTER_CODE = T2.SCR_INCD--证券内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${p_end_dt}'--开始日期
   AND T2.END_DATE >= '${p_end_dt}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T3 --证券基本信息
    ON T2.SCR_NUM = T3.SCR_NUM--证券编码
   AND T3.VALID_FLAG = '1' 
   AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD T4 --维度定义表
    ON T1.L_SERIAL_ID = T4.L_SERIAL_ID
   AND T4.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5 --标准码值字典映射表
    ON T5.SRC_DICT_CLS_CD = 'C_TRADE_TYPE'--源字典分类
   AND T4.C_TRADE_TYPE = T5.SRC_DICT_CLS_CDVAL
   AND T5.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T5.VALID_FLAG = '1'--有效标志
 WHERE T1.P_DT = '${p_end_dt}'
;"
