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
-- ** 描    述:回购证券参数表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_SCR_REPO_SCR_PARA_PFD  回购证券参数表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_THGRATIO_PFD  回购参数表
-- **           DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD   证券编码映射
-- **           DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD 证券基本信息
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准码值字典映射表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_SCR_REPO_SCR_PARA_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_DATE                                                                     AS BUSIN_DATE                              --业务日期
     , T2.SCR_NUM                                                                    AS SCR_NUM                                 --证券编码
     , T3.SYMBOL                                                                     AS SYMBOL                                  --证券代码
     , T1.VC_INTER_CODE                                                              AS SCR_INCD                                --证券内码
     , T3.SCR_SNAME                                                                  AS SCR_NAME                                --证券名称
     , CASE 
         WHEN T1.C_PARAMETER_TYPE IS NOT NULL THEN 
          COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PARAMETER_TYPE)) 
       END                                                                           AS PARA_CATG_CODE                          --参数类别代码
     , T1.L_RATIO                                                                    AS REPO_PARA                               --回购参数
     , T1.EN_SYS_RATIO                                                               AS SYS_PLG_RATE                            --系统质押比例
     , T1.L_MODIFY_DATE                                                              AS MAINT_DATE                              --维护日期
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_THGRATIO_PFD'                                                        AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_THGRATIO_PFD T1  --回购参数表
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
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准码值字典映射表
    ON T4.SRC_DICT_CLS_CD = 'C_PARAMETER_TYPE'--源字典分类
   AND T1.C_PARAMETER_TYPE = T4.SRC_DICT_CLS_CDVAL
   AND T4.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T4.VALID_FLAG = '1'--有效标志
 WHERE T1.P_DT = '${p_end_dt}'
;"
