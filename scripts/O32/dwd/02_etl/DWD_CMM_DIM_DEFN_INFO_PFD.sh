#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主    题:公共
-- ** 描    述:维度定义信息表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_CMM_DIM_DEFN_INFO_PFD    维度定义信息表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD 维度定义表
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP   标准码值字典映射表
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
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_CMM_DIM_DEFN_INFO_PFD
PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_SERIAL_ID                                                                AS DIM_SERIALNO                            --维度序号
     , T1.VC_TRADE_NO                                                                AS DIM_NO                                  --维度编号
     , T1.VC_TRADE_NAME                                                              AS DIM_NAME                                --维度名称
     , CASE 
         WHEN T1.C_TRADE_TYPE IS NOT NULL THEN 
          COALESCE(T2.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TRADE_TYPE)) 
       END                                                                           AS DIM_CATG_CODE                           --维度类别代码
     , T2.STD_DICT_CLS_CDVAL_DESC                                                    AS DIM_CATG_NAME                           --维度类别名称
     , T1.VC_TRADE_LEVEL                                                             AS DIM_LVL                                 --维度级别
     , T1.L_PARENT_ID                                                                AS HLVL_SERIALNO                           --上级序号
     , T1.L_ROOT_ID                                                                  AS TOP_SERIALNO                            --顶级序号
     , CASE 
         WHEN T1.C_STOCKPOOL_TYPE IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_STOCKPOOL_TYPE)) 
       END                                                                           AS STK_POOL_CATG_CODE                      --股票池类别代码
     , T1.L_OPERATOR_NO                                                              AS CRTR_CODE                               --创建人代码
     , T1.VC_TIMESTAMP                                                               AS TIME_STAMP                              --时间戳
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TTRADETYPES_PFD'                                                     AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD T1  --维度定义表
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2 --标准码值字典映射表
    ON T2.SRC_DICT_CLS_CD = 'C_TRADE_TYPE'--源字典分类
   AND T1.C_TRADE_TYPE = T2.SRC_DICT_CLS_CDVAL
   AND T2.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T2.VALID_FLAG = '1'--有效标志
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T3.SRC_DICT_CLS_CD = 'C_STOCKPOOL_TYPE'--源字典分类
   AND T1.C_STOCKPOOL_TYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T3.VALID_FLAG = '1'--有效标志
 WHERE T1.P_DT = '${p_end_dt}'
;"
