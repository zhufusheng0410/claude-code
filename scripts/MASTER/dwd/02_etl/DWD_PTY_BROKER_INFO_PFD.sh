#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:主体
-- ** 描述:经纪人信息
-- ** 创建者:auto
-- ** 创建日期:2023-06-27
-- ** 修改日志:
-- ** 2023-06-27，auto，新建
-- ** 目标表：DWDXDAY.DWD_PTY_BROKER_INFO_PFD  经纪人信息
-- ** 源表：  ODS_XDAY_HSDS.ODS_HSDS_TBROKER_PFD 经纪人信息
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_BROKER_INFO_PFD PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       T1.VC_BROKER                                                                  AS BROKER_NUM                              --经纪人编码
     , T1.VC_BROKER                                                                  AS BROKER_INCD                             --经纪人内码
     , T1.VC_FATHERBROKER                                                            AS HLVL_BROKER_INCD                        --上级经纪人内码
     , T1.VC_BROKERNAME                                                              AS BROKER_NAME                             --经纪人名称
     , CASE WHEN T1.C_TYPE IS NOT NULL 
            THEN COALESCE(T2.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_TYPE)) 
        END                                                                          AS BROKER_CATG_CODE                        --经纪人类别代码
     , T1.VC_NETNO                                                                   AS BTCH_CODE                               --网点代码
     , T1.VC_CENTERNO                                                                AS BRANCH_CODE                             --分中心代码
     , T1.VC_PHONE                                                                   AS PHONE                                   --联系电话
     , T1.VC_QUALIFICATIONNO                                                         AS QLFY_CARD_NO                            --资质证明编号
     , T1.C_QUALIFICATION                                                            AS SALE_QLFY_FLAG                          --销售资格标志
     , 'HSDS'                                                                        AS SSYS                                    --源系统
     , 'ODS_HSDS_TBROKER_PFD'                                                        AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSDS.ODS_HSDS_TBROKER_PFD T1  --经纪人信息
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2 --标准字典码值映射
    ON T2.SSYS = 'HSDS'
   AND T2.SRC_DICT_CLS_CD = 'C_TYPE'
   AND TRIM(T1.C_TYPE) = T2.SRC_DICT_CLS_CDVAL
   AND T2.VALID_FLAG = '1'
 WHERE T1.P_DT = '${P_BATCH_DT}'
;

"
