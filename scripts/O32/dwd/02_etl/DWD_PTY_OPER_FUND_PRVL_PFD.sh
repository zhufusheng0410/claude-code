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
-- ** 主    题:主体
-- ** 描    述:操作员基金权限表
-- ** 创 建 者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目 标 表：DWDXDAY.DWD_PTY_OPER_FUND_PRVL_PFD    操作员基金权限表
-- ** 源    表：DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD    账套编码映射
-- **           ODS_XDAY_O32.ODS_O32_TOPFUNDRIGHT_PFD 操作员基金权限表
-- **           ODS_XDAY_O32.ODS_O32_TROLE_PFD        角色表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_OPER_FUND_PRVL_PFD
PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       T2.SFAC_NUM                                                                   AS SFAC_NUM                                --账套编码
     , T2.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.L_FUND_ID                                                                  AS PROD_INCD                               --产品内码
     , T1.L_ROLE_ID                                                                  AS ROLE_CODE                               --角色代码
     , T3.VC_ROLE_NAME                                                               AS ROLE_NAME                               --角色名称
     , T1.L_ASSET_ID                                                                 AS AST_UNIT_SERIALNO                       --资产单元序号
     , T1.L_BASECOMBI_ID                                                             AS PORTF_SERIALNO                          --投资组合序号
     , T1.C_LAYER                                                                    AS PRVL_LVL                                --权限层次
     , T1.VC_RIGHTS                                                                  AS PRVL                                    --权限
     , T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TOPFUNDRIGHT_PFD'                                                    AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TOPFUNDRIGHT_PFD T1  --操作员基金权限表
  LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T2 --账套编码映射
    ON T1.L_FUND_ID = T2.SFAC_INCD--产品内码
   AND T2.SSYS = 'O32'--源系统
   AND T2.ST_DATE <= '${P_BATCH_DT}'--开始日期
   AND T2.END_DATE >= '${P_BATCH_DT}'--结束日期
   AND T2.VALID_FLAG = '1'--有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN ODS_XDAY_O32.ODS_O32_TROLE_PFD T3 --角色表
    ON T1.L_ROLE_ID = T3.L_ROLE_ID
   AND T3.P_DT = '${P_BATCH_DT}'
 WHERE T1.P_DT = '${P_BATCH_DT}'
;
-- 保留近一周数据
ALTER TABLE DWDXDAY.DWD_TRAN_SCR_MANUAL_BUSIN_PFD DROP PARTITION(P_DT <= '${day_8_ago}')
;

"
