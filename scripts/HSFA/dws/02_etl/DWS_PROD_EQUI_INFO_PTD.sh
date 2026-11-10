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
    set hive.strict.checks.type.safety=false;
    -- **************************************************************************
    -- ** 描述: 产品权益信息
    -- ** 创建者 : vhhv
    -- ** 创建日期: 20230621
    -- ** 目标表：DWSXDAY.DWS_PROD_EQUI_INFO_PTD             产品权益信息
    -- ** 源表：  DWDXDAY.DWD_EVT_PROD_EQUI_INFO_PTD       产品分红信息
    -- **************************************************************************
    
    set mapred.max.split.size=256000000;
    set mapred.min.split.size.per.node=100000000;
    set mapred.min.split.size.per.rack=100000000;
    set hive.merge.mapredfiles=true;
    set hive.merge.mapfiles=true;
    set hive.merge.smallfiles.avgsize=16000000;
    set hive.merge.size.per.task=256000000;
    set hive.exec.reducers.bytes.per.reducer=10240000000; 
    set mapreduce.job.reduces=2;
    
    INSERT OVERWRITE TABLE DWSXDAY.DWS_PROD_EQUI_INFO_PTD PARTITION ( P_DT= '${P_BATCH_DT}')
    SELECT
        T1.SFAC_NO AS SFAC_NO -- 账套编号
        ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,T2.PROD_CODE AS PROD_CODE -- 产品代码
        ,T2.CNAME AS PROD_NAME     -- 产品名称
        ,T1.PROD_CODE AS CLAS_PROD_CODE -- 分级产品代码
        ,T1.REG_DATE AS REG_DATE -- 登记日期
        ,T1.EXRT_DATE AS EXRT_DATE -- 除权日期
        ,T1.EQUI_TYPE AS EQUI_TYPE -- 权益类型
        ,'分红' AS EQUI_NAME -- 权益名称
        ,T1.BASI_SHARE AS BASI_SHARE -- 基准份额
        ,T1.EQUI_AMT AS EQUI_AMT -- 权益金额
        ,T1.PER_UNIT_BONUS_AMT AS UNIT_BTAX_AMT -- 单位税前金额
        ,T1.PER_UNIT_BONUS_AMT AS UNIT_ATAX_AMT -- 单位税后金额
        ,'HSFA' AS SSYS  -- 源系统
        ,'' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME  -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM DWDXDAY.DWD_EVT_PROD_EQUI_INFO_PTD T1 -- 产品权益信息
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T2  -- 产品基本信息
    ON T1.SFAC_NUM=T2.SFAC_NUM AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    WHERE T1.P_DT = '${P_BATCH_DT}'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done