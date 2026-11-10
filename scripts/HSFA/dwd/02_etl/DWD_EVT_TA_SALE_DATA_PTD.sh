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
    -- ** 描述: TA销售数据
    -- ** 创建者 : vhhv
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_TA_SALE_DATA_PTD      TA销售数据
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TSGSH_PTD       TA销售数据
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_TA_SALE_DATA_PTD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT
        CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
        ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,A1.VC_JJDM AS PROD_CODE -- 产品代码
        ,A1.D_RQ AS REQ_DAY -- 申请日
        ,A1.D_QRRQ AS CNFM_DAY -- 确认日
        ,A1.D_QRRQ AS DELIV_DAY -- 交收日
        ,A1.L_IMPORT AS BUSIN_CATG -- 业务类别
        ,CASE WHEN A1.VC_JGDM IS NULL THEN 0 ELSE 1 END AS CUST_TYPE -- 客户类型
        ,A1.L_SGSL AS ALLOT_QTY -- 申购数量
        ,A1.EN_SGJE AS ALLOT_AMT -- 申购金额
        ,A1.L_SHSL AS REDEM_QTY -- 赎回数量
        ,A1.EN_SHJE AS REDEM_AMT -- 赎回金额
        ,A1.EN_JGSHF AS ORG_REDEM_FEE -- 机构赎回费
        ,A1.EN_JJSHF AS FUND_REDEM_FEE -- 基金赎回费
        ,A1.EN_ZHFSR AS CHANGEFEE -- 转换费
        ,A1.EN_HDSGF AS BEND_PURFEE -- 后端申购费
        ,A1.EN_BCF AS OTH_FEE -- 其他费用
        ,A1.VC_JGDM AS ORGNO -- 机构代码
        ,A1.VC_JGMC AS ORG_NAME -- 机构名称
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_TSGSH_PTD' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TSGSH_PTD A1 -- 申购赎回表
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
    ON A1.L_ZTBH=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    WHERE A1.P_DT = '${P_BATCH_DT}'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
