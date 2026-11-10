#!/bin/sh
# DW-DEVIATION: 甲方原文为两份脚本拼接（done 与 shebang 粘连，while 不闭合），按口径只保留第 1 个 beeline 的完整 SQL；勿用 --force-dws-raw 覆盖
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
    -- ** 主题: 资产
    -- ** 描述: 产品销售数据
    -- ** 创建者 : vhhv
    -- ** 创建日期: 20230621
    -- ** 目标表：DWSXDAY.DWS_PROD_SALE_DATA_PTD             产品销售数据
    -- ** 源表：  DWDXDAY.DWD_EVT_TA_SALE_DATA_PTD       TA销售数据
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
    
    INSERT OVERWRITE TABLE DWSXDAY.DWS_PROD_SALE_DATA_PTD PARTITION ( P_DT= '${P_BATCH_DT}')
    SELECT
        T1.SFAC_NO AS SFAC_NO -- 账套编号
        ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,T2.PROD_CODE AS PROD_CODE -- 产品代码
        ,T2.CNAME AS PROD_NAME     -- 产品名称
        ,T1.PROD_CODE AS CLAS_PROD_CODE -- 分级产品代码
        ,T1.BUSIN_CATG AS TRAN_TYPE -- TA业务类别
        ,MAX(T3.STD_DICT_CLS_CDVAL_DESC) AS TRAN_TYPE_NAME -- TA业务类别名称
        ,T1.CUST_TYPE AS HOLDER_PROP -- 持有人属性
        ,CASE WHEN T1.CUST_TYPE='1' THEN '机构' ELSE '个人' END AS HOLDER_PROP_NAME --持有人属性名称
        ,T1.REQ_DAY AS REQ_DAY -- 申请日
        ,T1.CNFM_DAY AS CNFM_DAY -- 确认日
        ,T1.DELIV_DAY AS DELIV_DAY -- 交收日
        ,SUM(CASE WHEN T1.BUSIN_CATG IN(1,3,6,13) THEN T1.ALLOT_QTY ELSE T1.REDEM_QTY END) AS REQ_AMT -- 申请金额
        ,SUM(CASE WHEN T1.BUSIN_CATG IN(1,3,6,13) THEN T1.ALLOT_QTY ELSE T1.REDEM_QTY END) AS CNFM_AMT -- 确认金额
        ,SUM(CASE WHEN T1.BUSIN_CATG IN(1,3,6,13) THEN T1.ALLOT_AMT ELSE T1.REDEM_AMT END) AS REQ_SHARE -- 申请份额
        ,SUM(CASE WHEN T1.BUSIN_CATG IN(1,3,6,13) THEN T1.ALLOT_AMT ELSE T1.REDEM_AMT END) AS CNFM_SHARE -- 确认份额
        ,SUM(T1.ORG_REDEM_FEE+T1.FUND_REDEM_FEE+T1.CHANGEFEE+T1.BEND_PURFEE+T1.OTH_FEE) AS FEE -- 费用
        ,'CNY' AS CRRC -- 币种
        ,'HSFA' AS SSYS  -- 源系统
        ,'' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME  -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM DWDXDAY.DWD_EVT_TA_SALE_DATA_PTD T1 -- TA销售数据
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T2  -- 产品基本信息
    ON T1.SFAC_NUM=T2.SFAC_NUM AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000211') T3
    ON T1.BUSIN_CATG=T3.STD_DICT_CLS_CDVAL  -- TA业务类别
    WHERE T1.P_DT = '${P_BATCH_DT}'  -- 申购赎回 转入转出 调增调减
    GROUP BY T1.SFAC_NO,T1.SFAC_NUM,T2.PROD_CODE,T2.CNAME,T1.PROD_CODE,T1.BUSIN_CATG,T1.CUST_TYPE,T1.REQ_DAY,T1.CNFM_DAY,T1.DELIV_DAY
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
