#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:渠道
-- ** 描述:渠道网点信息
-- ** 创建者:auto
-- ** 创建日期:2023-06-15
-- ** 修改日志:
-- ** 2023-06-15，auto，新建
-- ** 目标表：DWDXDAY.DWD_CHNL_CHNL_BTCH_INFO_PFD  渠道网点信息
-- ** 源表：  ODS_XDAY_HSZTA.ODS_HSZTA_TNETINFO_PFD 网点信息
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TNETINFO_PFD  网点信息
-- **         ODS_XDAY_HSDS.ODS_HSDS_TNETSTATION_PFD 网点
-- **         DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD   机构编码映射
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_CHNL_CHNL_BTCH_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.ORG_NUM                                                                    AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_CODE                               --网点代码
     , T1.C_NETNAME                                                                  AS BTCH_NAME                               --网点名称
     , NULL                                                                          AS PROVINCE_CODE                           --省份代码
     , T1.C_CITYNO                                                                   AS CITY_CODE                               --城市代码
     , T1.C_NETADDRESS                                                               AS BTCH_ADDR                               --网点地址
     , T1.C_NETZIPCODE                                                               AS PTCD                                    --邮政编码
     , T1.C_NETCONTACT                                                               AS BTCH_CONP                               --网点联系人
     , T1.C_NETPHONE                                                                 AS BTCH_PHONE                              --网点联系电话
     , T1.C_NETFAXNO                                                                 AS BTCH_FAX                                --网点传真号码
     , T1.D_NETREGDATE                                                               AS BTCH_REG_DATE                           --网点登记日期
     , T1.C_NETSTATUS                                                                AS BTCH_STAT_CODE                          --网点状态代码
     , NULL                                                                          AS BTCH_TYPE_CODE                          --网点类型代码
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TNETINFO_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TNETINFO_PFD T1  --网点信息
  LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD T2 --机构编码映射
    ON T1.C_AGENCYNO = T2.ORG_INCD --机构内码
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.SSYS = 'HSZTA' --源系统
   AND T2.SRC_TAB = 'ODS_HSZTA_TAGENCYINFO_PFD' --源表
   AND T2.VALID_FLAG = '1' --有效
 WHERE T1.P_DT = '${p_end_dt}'
;

INSERT INTO DWDXDAY.DWD_CHNL_CHNL_BTCH_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.ORG_NUM                                                                    AS CHNL_NUM                                --渠道编码
     , T1.C_AGENCYNO                                                                 AS CHNL_INCD                               --渠道内码
     , T1.C_NETNO                                                                    AS BTCH_CODE                               --网点代码
     , T1.C_NETNAME                                                                  AS BTCH_NAME                               --网点名称
     , T1.C_PROVINCE                                                                 AS PROVINCE_CODE                           --省份代码
     , T1.C_CITYNO                                                                   AS CITY_CODE                               --城市代码
     , T1.C_NETADDRESS                                                               AS BTCH_ADDR                               --网点地址
     , T1.C_NETZIPCODE                                                               AS PTCD                                    --邮政编码
     , T1.C_NETCONTACT                                                               AS BTCH_CONP                               --网点联系人
     , T1.C_NETPHONE                                                                 AS BTCH_PHONE                              --网点联系电话
     , T1.C_NETFAXNO                                                                 AS BTCH_FAX                                --网点传真号码
     , T1.D_NETREGDATE                                                               AS BTCH_REG_DATE                           --网点登记日期
     , T1.C_NETSTATUS                                                                AS BTCH_STAT_CODE                          --网点状态代码
     , T1.C_TYPE                                                                     AS BTCH_TYPE_CODE                          --网点类型代码
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TNETINFO_PFD'                                                      AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TNETINFO_PFD T1  --网点信息
  LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD T2 --机构编码映射
    ON T1.C_AGENCYNO = T2.ORG_INCD --机构内码
   AND T2.ST_DATE <= '${p_end_dt}' --开始日期
   AND T2.END_DATE >= '${p_end_dt}' --结束日期
   AND T2.SSYS = 'HSFTA' --源系统
   AND T2.SRC_TAB = 'ODS_HSFTA_TAGENCYINFO_PFD' --源表
   AND T2.VALID_FLAG = '1' --有效
  LEFT JOIN DWDXDAY.DWD_CHNL_CHNL_BTCH_INFO_PFD T3 --渠道网点信息
    ON T2.ORG_NUM = T3.CHNL_NUM
   AND T1.C_NETNO = T3.BTCH_CODE
   AND T3.SSYS = 'HSZTA'
   AND T3.P_DT = '${p_end_dt}'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T3.CHNL_NUM IS NULL
;

INSERT INTO DWDXDAY.DWD_CHNL_CHNL_BTCH_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       NULL                                                                          AS CHNL_NUM                                --渠道编码
     , NULL                                                                          AS CHNL_INCD                               --渠道内码
     , T1.VC_NETNO                                                                   AS BTCH_CODE                               --网点代码
     , T1.VC_NETNAME                                                                 AS BTCH_NAME                               --网点名称
     , T1.VC_PROVINCE                                                                AS PROVINCE_CODE                           --省份代码
     , T1.VC_CITYNO                                                                  AS CITY_CODE                               --城市代码
     , T1.VC_ADDRESS                                                                 AS BTCH_ADDR                               --网点地址
     , T1.VC_ZIP                                                                     AS PTCD                                    --邮政编码
     , T1.VC_CONTACT                                                                 AS BTCH_CONP                               --网点联系人
     , T1.VC_PHONE                                                                   AS BTCH_PHONE                              --网点联系电话
     , T1.VC_FAXNO                                                                   AS BTCH_FAX                                --网点传真号码
     , NULL                                                                          AS BTCH_REG_DATE                           --网点登记日期
     , T1.C_STATE                                                                    AS BTCH_STAT_CODE                          --网点状态代码
     , T1.C_FLAG                                                                     AS BTCH_TYPE_CODE                          --网点类型代码
     , 'HSDS'                                                                        AS SSYS                                    --源系统
     , 'ODS_HSDS_TNETSTATION_PFD'                                                    AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSDS.ODS_HSDS_TNETSTATION_PFD T1  --网点
 WHERE T1.P_DT = '${p_end_dt}'
;

"
