#!/bin/sh
#初始化环境变量：
begin_date="${p_start_dt}"
end_date="${p_end_dt}"
P_BATCH_DT=$begin_date
echo  $P_BATCH_DT
while [ $P_BATCH_DT -lt $end_date ]; 
do
    source /home/dolphinscheduler/hadoop_env
    inceptor_beeline()
    {
        beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
    }
    
    inceptor_beeline "
    -- **************************************************************************
    -- ** 主题: 事件
    -- ** 描述: 质押物信息
    -- ** 创建者 :VHHV
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_PLG_PROTY_INFO_PFD    质押物信息
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_THGJY_BDQ_PFD  A1    回购质押券信息
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TGPZYHG_ZYQ_PFD A1    协议回购质押券信息
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
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_PLG_PROTY_INFO_PFD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT
        CAST(A1.L_BH AS STRING) AS RELA_NO -- 关联编号
        ,A11.SCR_NUM AS PLG_SCR_NUM -- 质押券编码
        ,CAST(A1.L_ZQNM AS STRING) AS PLG_SCR_INCD -- 质押券内码
        ,A2.VC_ZQDM AS PLG_SYMBOL -- 质押券代码
        ,A2.VC_ZQJC AS PLG_NAME -- 质押券名称
        ,A1.EN_SL AS PLG_QTY -- 质押数量
        ,0 AS PLG_ORI_CRRC_COST -- 质押原币成本
        ,0 AS PLG_LC_COST -- 质押本币成本
        ,'' AS PLG_ORNT -- 质押方向
        ,'' AS PLG_DATE -- 质押日期
        ,0 AS PLG_RATE -- 质押比例
        ,'' AS PLG_CPTL_ACCT -- 质押资金账户
        ,'' AS DUE_DATE_PD -- 到期日期
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_THGJY_BDQ_PFD ' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_THGJY_BDQ_PFD  A1 -- 回购质押券信息
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD A2  -- 证券信息表
    ON A1.L_ZQNM=A2.L_ZQNM AND A2.P_DT = '${P_BATCH_DT}'
    LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD A11
    ON CAST(A1.L_ZQNM AS STRING)=A11.SCR_INCD AND A11.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    WHERE A1.P_DT = '${P_BATCH_DT}'
    UNION ALL
    SELECT
        CAST(A1.L_BH AS STRING) AS RELA_NO -- 关联编号
        ,A11.SCR_NUM AS PLG_SCR_NUM -- 质押券编码
        ,CAST(A1.L_ZQNM AS STRING) AS PLG_SCR_INCD -- 质押券内码
        ,A2.VC_ZQDM AS PLG_SYMBOL -- 质押券代码
        ,A2.VC_ZQJC AS PLG_NAME -- 质押券名称
        ,A1.EN_SL AS PLG_QTY -- 质押数量
        ,0 AS PLG_ORI_CRRC_COST -- 质押原币成本
        ,0 AS PLG_LC_COST -- 质押本币成本
        ,'' AS PLG_ORNT -- 质押方向
        ,'' AS PLG_DATE -- 质押日期
        ,0 AS PLG_RATE -- 质押比例
        ,'' AS PLG_CPTL_ACCT -- 质押资金账户
        ,'' AS DUE_DATE_PD -- 到期日期
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_TGPZYHG_ZYQ_PFD ' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TGPZYHG_ZYQ_PFD A1 -- 协议回购质押券信息
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD A2  -- 证券信息表
    ON A1.L_ZQNM=A2.L_ZQNM AND A2.P_DT = '${P_BATCH_DT}'
    LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD A11 -- 证券编码映射
    ON CAST(A1.L_ZQNM AS STRING) = A11.SCR_INCD AND A11.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    WHERE A1.P_DT = '${P_BATCH_DT}'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
