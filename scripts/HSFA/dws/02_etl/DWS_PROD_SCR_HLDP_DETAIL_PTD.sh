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
    -- ** 主题: 资产
    -- ** 描述: 产品证券持仓明细
    -- ** 创建者 : vhhv
    -- ** 创建日期: 20230621
    -- ** 目标表：DWSXDAY.DWS_PROD_SCR_HLDP_DETAIL_PTD             产品证券持仓明细
    -- ** 源表：  DWDXDAY.DWD_AST_VALU_INFO_PTD       估值信息
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
    
    INSERT OVERWRITE TABLE DWSXDAY.DWS_PROD_SCR_HLDP_DETAIL_PTD PARTITION ( P_DT= '${P_BATCH_DT}')
    SELECT
        T2.BIZ_DATE                 -- '业务日期',
        ,T2.SFAC_NO                 -- '账套编号',
        ,T2.SFAC_NUM                 -- '账套编码',
        ,T2.PROD_CODE                 -- '产品代码',
        ,T3.CNAME AS PROD_NAME                 -- '产品名称',
        ,T2.SCR_NUM                  -- '证券编码',
        ,T2.SCR_INCD                 -- '证券内码',
        ,T2.SYMBOL                   -- '证券代码',
        ,T4.SCR_SNAME AS SCR_NAME                 -- '证券名称',
        ,T2.SCR_TYPE                 -- '证券类型',
        ,T5.STD_DICT_CLS_CDVAL_DESC AS SCR_TYPE_NAME             -- '证券类型名称',
        ,T2.SCR_DETAIL_TYPE           -- '证券明细类型',
        ,CASE WHEN T2.SCR_TYPE='06' AND T2.TRAN_MKT IN('09','10') THEN '港股' ELSE T6.STD_DICT_CLS_CDVAL_DESC END AS SCR_DETAIL_TYPE_NAME      -- '证券明细类型名称',
        ,T2.TRAN_MKT                 -- '交易市场',
        ,T7.STD_DICT_CLS_CDVAL_DESC AS TRAN_MKT_NAME              -- '交易市场名称',
        ,T2.INV_CATG                 -- '投资分类',
        ,T8.STD_DICT_CLS_CDVAL_DESC AS INV_CATG_NAME                 -- '投资分类名称',
        ,T2.CIR_STAT                 -- '流通状态',
        ,CASE WHEN T2.SCR_TYPE='06' THEN T9.STD_DICT_CLS_CDVAL_DESC ELSE '' END AS CIR_STAT_NAME                  -- '流通状态名称',
        ,T2.TRAN_PROP                 -- '交易属性',
        ,T10.STD_DICT_CLS_CDVAL_DESC AS TRAN_PROP_NAME                 -- '交易属性名称',
        ,T2.CRRC_CODE                 -- '币种代码',
        ,T2.VALU_EXCR                 -- '估值汇率',
        ,T2.VALU_QUOT_PRC                 -- '估值行情价格',
        ,T2.HLDP_QTY                       -- '持仓数量',
        ,T2.COST_OC                       -- '成本(原币)',
        ,T2.COST_BC                       -- '成本(本位币)',
        ,T2.MVAL_OC                       -- '市值(原币)',
        ,T2.MVAL_BC                       -- '市值(本位币)',
        ,T2.VAL_APPRE_OC                       -- '估值增值(原币)',
        ,T2.VAL_APPRE_BC                       -- '估值增值(本位币)',
        ,T2.RECV_INTR_OC                       -- '应收利息(原币)',
        ,T2.RECV_INTR_BC                       -- '应收利息(本位币)',
        ,T2.APT_AMT_OC                       -- '应摊销金额(原币)',
        ,T2.APT_AMT_BC                       -- '应摊销金额(本位币)',
        ,T2.RECV_SDIVD_OC                       -- '应收股利(原币)',
        ,T2.RECV_SDIVD_BC                       -- '应收股利(本位币)',
        ,T2.RECV_DIVD_OC                       -- '应收红利(原币)',
        ,T2.RECV_DIVD_BC                       -- '应收红利(本位币)',
        ,T2.IMPR_PRE_OC                       -- '减值准备(原币)',
        ,T2.IMPR_PRE_BC                       -- '减值准备(本位币)',
        ,T2.MULTI_ORNT                 -- '多空方向',
        ,T11.STD_DICT_CLS_CDVAL_DESC AS MULTI_ORNT_NAME                 -- '多空方向名称',
        ,T2.MVAL_PCT_NAV              --'市值占净值比',
        ,T2.SSYS                      -- '源系统',
        ,T2.SOURCE_TAB                 -- '源表',
        ,T2.LD_TIME                   -- '加载时间',
        ,T2.MODIFY_TIME                 -- '修改时间'
        ,T2.INTR_PCT_NAV              --利息占比   
        ,CASE WHEN T2.SCR_TYPE='03' THEN 
              CASE WHEN T3.CNAME LIKE '%货币%' THEN '摊余成本法' 
                   ELSE CASE WHEN T2.VALU_MODE=1 THEN '摊余成本法' ELSE '市价法' END
              END 
         ELSE '' END AS VALU_MODE            --'估值方式'
        ,CASE WHEN T2.SCR_TYPE='03' THEN 
              CASE WHEN T2.VALU_MODE=1 THEN '以摊余成本计量' ELSE '以公允价值计量' END 
         ELSE '' END AS CAL_MODE              --'计量方式'
        ,CASE WHEN T2.SCR_TYPE='04' THEN 
              CASE WHEN T2.TRAN_MODE=1 THEN '正回购' ELSE '逆回购' END 
         ELSE '' END AS TRAN_ORNT              --'交易方向'
    FROM 
       (
        SELECT
            T1.VALU_DATE AS BIZ_DATE    -- 业务日期
            ,T1.SFAC_NO AS SFAC_NO -- 账套编号
            ,T1.SFAC_NUM AS SFAC_NUM    -- 账套编码
            ,T1.PROD_CODE AS PROD_CODE  -- 产品代码
            ,T1.SCR_NUM AS SCR_NUM  -- 证券编码
            ,T1.SCR_INCD AS SCR_INCD   -- 证券内码
            ,MAX(NVL(T1.SYMBOL,0)) AS SYMBOL   -- 证券代码
            ,MAX(CASE WHEN T1.CRSE_PROP_NAME LIKE '%成本%' AND T1.CRSE_PROP_NAME LIKE '%以摊余成本计量%' THEN 1 ELSE 0 END) AS VALU_MODE  -- 估值方式
            ,'' AS SCR_NAME    -- 证券名称
            ,MAX(T1.SCR_TYPE) AS SCR_TYPE   -- 证券类型
            ,MAX(T1.SCR_DETAIL_TYPE) AS SCR_DETAIL_TYPE -- 证券明细类型
            ,T1.TRAN_MKT AS TRAN_MKT    -- 交易市场
            ,T1.INV_CATG AS INV_CATG    -- 投资分类
            ,CASE WHEN T1.CRSE_PROP_NAME LIKE '%成本%' AND T1.SCR_TYPE='06' THEN T1.CIR_STAT ELSE '1' END AS CIR_STAT    -- 流通状态
            ,T1.TRAN_PROP AS TRAN_PROP  -- 交易属性
            ,MAX(T1.CRRC_CODE) AS CRRC_CODE -- 币种代码
            ,MAX(T1.VALU_EXCR) AS VALU_EXCR -- 估值汇率
            ,MAX(T1.VALU_PRC) AS VALU_QUOT_PRC  -- 估值行情价格
            ,CASE WHEN T1.CRSE_PROP LIKE '2202%' THEN 1
                  WHEN T1.CRSE_PROP LIKE '1202%' THEN 0
                  ELSE 0 END AS TRAN_MODE
            ,SUM(CASE WHEN (T1.CRSE_PROP_NAME LIKE '%成本%' OR (T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%')) AND LENGTH(T1.SYMBOL)<>0 THEN T1.HLDP_QTY ELSE 0 END) AS HLDP_QTY   -- 持仓数量
            ,SUM(CASE WHEN (T1.CRSE_PROP_NAME LIKE '%成本%' OR (T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%')) AND LENGTH(T1.SYMBOL)<>0 THEN T1.ORI_CRRC_COST ELSE 0 END) AS COST_OC   -- 成本(原币)
            ,SUM(CASE WHEN (T1.CRSE_PROP_NAME LIKE '%成本%' OR (T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%')) AND LENGTH(T1.SYMBOL)<>0 THEN T1.LC_COST ELSE 0 END)AS COST_BC  -- 成本(本位币)
            ,SUM(CASE WHEN (T1.CRSE_PROP_NAME LIKE '%成本%' OR (T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%')) AND LENGTH(T1.SYMBOL)<>0 THEN T1.ORI_CRRC_MVAL ELSE 0 END) AS MVAL_OC   -- 市值(原币)
            ,SUM(CASE WHEN (T1.CRSE_PROP_NAME LIKE '%成本%' OR (T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%')) AND LENGTH(T1.SYMBOL)<>0 THEN T1.LC_MVAL ELSE 0 END) AS MVAL_BC -- 市值(本位币)
            ,SUM(T1.ORI_CRRC_VAL_APPRE) AS VAL_APPRE_OC -- 估值增值(原币)
            ,SUM(T1.LC_VAL_APPRE) AS VAL_APPRE_BC   -- 估值增值(本位币)
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%应收利息%' OR T1.CRSE_PROP_NAME LIKE '%应计利息%' THEN T1.ORI_CRRC_MVAL ELSE 0 END) AS RECV_INTR_OC    -- 应收利息(原币)
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%应收利息%' OR T1.CRSE_PROP_NAME LIKE '%应计利息%' THEN T1.LC_MVAL ELSE 0 END) AS RECV_INTR_BC  -- 应收利息(本位币)
            ,SUM(CASE WHEN (T1.CRSE_PROP_NAME LIKE '%成本%' OR (T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%')) AND LENGTH(T1.SYMBOL)<>0 THEN T1.ORI_CRRC_PD_COST ELSE 0 END) AS APT_AMT_OC -- 应摊销金额(原币)
            ,SUM(CASE WHEN (T1.CRSE_PROP_NAME LIKE '%成本%' OR (T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%')) AND LENGTH(T1.SYMBOL)<>0 THEN T1.LC_PD_COST ELSE 0 END) AS APT_AMT_BC   -- 应摊销金额(本位币)
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%应收股利%' THEN T1.ORI_CRRC_MVAL ELSE 0 END) AS RECV_SDIVD_OC    -- 应收股利(原币)
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%应收股利%' THEN T1.LC_MVAL ELSE 0 END) AS RECV_SDIVD_BC  -- 应收股利(本位币)
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%应收红利%' THEN T1.ORI_CRRC_MVAL ELSE 0 END) AS RECV_DIVD_OC    -- 应收红利(原币)
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%应收红利%' THEN T1.LC_MVAL ELSE 0 END) AS RECV_DIVD_BC  -- 应收红利(本位币)
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%减值准备%' THEN T1.ORI_CRRC_MVAL ELSE 0 END) AS IMPR_PRE_OC -- 减值准备(原币)
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%减值准备%' THEN T1.LC_MVAL ELSE 0 END) AS IMPR_PRE_BC   -- 减值准备(本位币)
            ,T1.MULTI_SPOS_ORNT AS MULTI_ORNT   -- 多空方向
            ,SUM(CASE WHEN (T1.CRSE_PROP_NAME LIKE '%成本%' OR (T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%')) AND LENGTH(T1.SYMBOL)<>0 THEN T1.LC_MVAL_PCT_NAV_COMPARE ELSE 0 END) AS MVAL_PCT_NAV --市值占净值比
            ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%应收利息%' OR T1.CRSE_PROP_NAME LIKE '%应计利息%' THEN T1.LC_MVAL_PCT_NAV_COMPARE ELSE 0 END) AS INTR_PCT_NAV  --利息占比
            ,'HSFA' AS SSYS  -- 源系统
            ,'' AS SOURCE_TAB -- 源表
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME  -- 加载时间
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
        FROM DWDXDAY.DWD_AST_VALU_INFO_PTD T1 -- 估值信息
        WHERE T1.P_DT = '${P_BATCH_DT}' AND T1.DATA_TP=1 AND T1.SCR_INCD<>'-1'  -- 1 证券类  0 非券类
        GROUP BY T1.VALU_DATE,T1.SFAC_NO,T1.SFAC_NUM,T1.PROD_CODE,T1.SCR_NUM,T1.SCR_INCD,T1.TRAN_MKT,T1.INV_CATG,CASE WHEN T1.CRSE_PROP_NAME LIKE '%成本%' AND T1.SCR_TYPE='06' THEN T1.CIR_STAT ELSE '1' END ,T1.TRAN_PROP,T1.MULTI_SPOS_ORNT
                 ,CASE WHEN T1.CRSE_PROP LIKE '2202%' THEN 1 WHEN T1.CRSE_PROP LIKE '1202%' THEN 0 ELSE 0 END
        ) T2
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T3  -- 产品基本信息
    ON T2.SFAC_NUM=T3.SFAC_NUM AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    LEFT JOIN DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD T4  --证券基本信息
    ON T2.SCR_NUM=T4.SCR_NUM AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000001') T5
    ON T2.SCR_TYPE=T5.STD_DICT_CLS_CDVAL  -- 证券类型
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000056') T6
    ON T2.SCR_DETAIL_TYPE=T6.STD_DICT_CLS_CDVAL  -- 证券明细类型
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000007') T7
    ON T2.TRAN_MKT=T7.STD_DICT_CLS_CDVAL  -- 交易市场
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000202') T8
    ON T2.INV_CATG=T8.STD_DICT_CLS_CDVAL  -- '投资分类'
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000201') T9
    ON T2.CIR_STAT=T9.STD_DICT_CLS_CDVAL  -- '流通状态'
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000203') T10
    ON T2.TRAN_PROP=T10.STD_DICT_CLS_CDVAL  -- '交易属性'
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000204') T11
    ON T2.MULTI_ORNT=T11.STD_DICT_CLS_CDVAL  -- '多空方向'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done