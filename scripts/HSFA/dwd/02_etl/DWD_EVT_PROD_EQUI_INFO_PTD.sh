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
    -- ** 描述: 产品权益信息
    -- ** 创建者 : vhhv
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_PROD_EQUI_INFO_PTD             产品权益信息
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TBJJFH_PTD       产品分红信息
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_PROD_EQUI_INFO_PTD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT 
        CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
       ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
       ,A1.D_YWRQ AS BIZ_DATE -- 业务日期
       ,A1.VC_FUNDCODE AS PROD_CODE -- 产品代码
       ,A1.D_DJRQ AS REG_DATE -- 登记日期
       ,A1.D_CQRQ AS EXRT_DATE -- 除权日期
       ,CAST(A1.L_TYPE AS STRING) AS EQUI_TYPE -- 权益类型
       ,A1.EN_QYJE AS EQUI_AMT -- 权益金额
       ,A1.EN_QYFE AS BASI_SHARE -- 基准份额
       ,'' AS SHARE_CATG -- 份额类别
       ,'' AS ARVD_DATE -- 到账日期
       ,A1.EN_DWSQJE AS PER_UNIT_BONUS_AMT -- 每单位分红金额
       ,'' AS YIEL_TYPE -- 收益类型
       ,'HSFA' AS SSYS -- 源系统
       ,'ODS_HSFA_TBJJFH_PTD' AS SOURCE_TAB -- 源表
       ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
       ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TBJJFH_PTD A1 -- 产品分红信息
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
    ON A1.L_ZTBH=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    WHERE A1.P_DT = '${P_BATCH_DT}'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
