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
-- ** 描    述:算法定义表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_CMM_ALGOR_DEFN_PFD             算法定义表
-- ** 源    表：ODS_XDAY_O32.ODS_O32_TSTORMCOMPANYALGO_PFD 算法定义表
-- **           ODS_XDAY_O32.ODS_O32_TSTORMCOMPANY_PFD     算法提供商明细表
-- **           DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP         标准码值字典映射表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_CMM_ALGOR_DEFN_PFD
PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T1.L_COMP_ID                                                                  AS PROVID_SERIALNO                         --提供商序号
     , T2.VC_COMP_NAME                                                               AS PROVID_NAME                             --提供商名称
     , T1.VC_STRATEGY_NAME                                                           AS ALGOR_NAME                              --算法名称
     , CASE 
         WHEN T1.C_ALGO_BUSIN_CLASS IS NOT NULL THEN 
          COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_ALGO_BUSIN_CLASS)) 
       END                                                                           AS ALGOR_CATG_CODE                         --算法类别代码
     , T1.VC_DESCRIPTION                                                             AS ALGOR_DESC                              --算法描述
     , T1.VC_DESCRIPTION_DETAIL                                                      AS ALGOR_DET_DESC                          --算法详细描述
     , T1.C_ENABLE_FLAG                                                              AS SUSE_FLAG                               --启用标志
     , T1.VC_STOCK_TYPES                                                             AS SUPT_SCR_CATG                           --支持的证券类别
     , T1.C_BUSIN_CLASS                                                              AS BUSIN_CATG                              --业务类别
     , T1.C_ENABLE_FAIR                                                              AS SUPT_FAIR_TRAN_FLAG                     --支持公平交易标志
     , T1.VC_ENTRUST_DIRECTIONS                                                      AS SUPT_ENTU_ORNT                          --支持的委托方向
     , T1.VC_STOCK_TARGET_TYPES                                                      AS SUPT_CTRL_MODE                          --支持的控制方式
     , T1.VC_ORDER_TYPES                                                             AS ORDE_TYPE                               --订单类型
     , T1.VC_MI_TARGET_TYPES                                                         AS MANU_INTERVE_CTRL_MODE                  --人工干预控制方式
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TSTORMCOMPANYALGO_PFD'                                               AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TSTORMCOMPANYALGO_PFD T1  --算法定义表
  LEFT JOIN ODS_XDAY_O32.ODS_O32_TSTORMCOMPANY_PFD T2 --算法提供商明细表
    ON T1.L_COMP_ID = T2.L_COMP_ID
   AND T2.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准码值字典映射表
    ON T3.SRC_DICT_CLS_CD = 'C_ALGO_BUSIN_CLASS'--源字典分类
   AND T1.C_ALGO_BUSIN_CLASS = T3.SRC_DICT_CLS_CDVAL
   AND T3.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T3.VALID_FLAG = '1'--有效标志
 WHERE T1.P_DT = '${p_end_dt}'
;"
