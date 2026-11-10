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
-- ** 主题:主体
-- ** 描述:操作员信息表
-- ** 创建者:xiemn
-- ** 创建日期:2023-06-02
-- ** 修改日志:
-- ** 2023-06-02，xiemn，新建
-- ** 目标表：DWDXDAY.DWD_PTY_OPER_INFO_PFD      操作员信息表
-- ** 源表：  ODS_XDAY_O32.ODS_O32_TOPERATOR_PFD 操作员表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP 标准码值字典映射表
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_OPER_INFO_PFD
PARTITION(P_DT = '${P_BATCH_DT}')
SELECT 
       T1.L_OPERATOR_NO                                                              AS OPER_CODE                               --操作员代码
     , T1.VC_OPERATOR_NAME                                                           AS OPER_NAME                               --操作员姓名
     , T1.VC_DOMAIN_NAME                                                             AS DOMAIN_USER_NAME                        --域用户名
     , CASE 
         WHEN T1.C_CARD_TYPE IS NOT NULL THEN 
          COALESCE(T2.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CARD_TYPE)) 
       END                                                                           AS CERT_CATG_CODE                          --证件类别代码
     , T1.VC_CARD_NO                                                                 AS CERT_NO                                 --证件号码
     , T1.VC_ADDRESS                                                                 AS CNTA_ADDR                               --联系地址
     , T1.VC_EMAIL                                                                   AS MAILBOX                                 --邮箱
     , T1.VC_TEL_NO                                                                  AS TEL                                     --电话
     , T1.L_REGISTER_DATE                                                            AS REG_DATE                                --注册日期
     , T1.L_CANCEL_DATE                                                              AS CNCL_DATE                               --注销日期
     , T1.C_OPERATOR_STATUS                                                          AS OPER_STAT                               --操作员状态
     , T1.VC_MANAGE_RIGHT                                                            AS SCR_CATG_PRVL                           --证券类别权限
     , T1.VC_BUSIN_CLASSES                                                           AS PERM_OPER_BUSIN_CATG                    --允许操作的业务分类
     , 'O32'                                                                         AS SSYS                                    --源系统
     , 'ODS_O32_TOPERATOR_PFD'                                                       AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_O32.ODS_O32_TOPERATOR_PFD T1  --操作员表
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2 --标准码值字典映射表
    ON T2.SRC_DICT_CLS_CD = 'C_CARD_TYPE'--源字典分类
   AND T1.C_CARD_TYPE = T2.SRC_DICT_CLS_CDVAL
   AND T2.SSYS = 'O32'--源系统简称比如O32\FA45
   AND T2.VALID_FLAG = '1'--有效标志
 WHERE T1.P_DT = '${P_BATCH_DT}'
;
-- 保留近一周数据
ALTER TABLE DWDXDAY.DWD_TRAN_SCR_MANUAL_BUSIN_PFD DROP PARTITION(P_DT <= '${day_8_ago}')
;

"
