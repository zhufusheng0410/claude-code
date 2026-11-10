
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
    -- ** 描述: 产品资产信息
    -- ** 创建者 : vhhv
    -- ** 创建日期: 20230621
    -- ** 目标表：DWSXDAY.DWS_PROD_AST_INFO_PTD       产品资产信息
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
    
    INSERT OVERWRITE TABLE DWSXDAY.DWS_PROD_AST_INFO_PTD PARTITION ( P_DT= '${P_BATCH_DT}')
    SELECT
        T3.BIZ_DATE -- 业务日期
        ,T3.SFAC_NO -- 账套编号
        ,T3.SFAC_NUM -- 账套编码
        ,T3.PROD_CODE -- 产品代码
        ,T3.PROD_NAME -- 产品名称
        ,T3.CLAS_PROD_CODE -- 分级产品代码
        ,T3.PROD_CATG -- 产品类别
        ,T4.STD_DICT_CLS_CDVAL_DESC AS PROD_CATG_NAME -- 产品类别名称
        ,T3.AST_SHARE -- 资产份额
        ,T3.AST_NAV -- 资产净值（市值）
        ,T3.AST_NAV_COST -- 资产净值（成本）
        ,T3.AST_UNIT_NAV -- 资产单位净值
        ,T3.AST_TOTAL -- 资产合计（市值）
        ,T3.AST_TOTAL_COST -- 资产合计（成本）
        ,T3.LIAB_TOTAL -- 负债合计
        ,T3.CASH_AST -- 现金资产
        ,T3.UN_CASH_AST -- 非现金资产
        ,T3.RECV_AST -- 应收资产 
        ,T3.PAYB_AST -- 应付资产
        ,T3.STK_AST -- 股票资产
        ,T3.BOND_AST -- 债券资产
        ,T3.BOND_AST + T3.BOND_AST_INT AS BOND_AST_FULL -- 债券资产(全价)
        ,T3.FUND_AST -- 基金资产 
        ,T3.REPO_AST -- 回购资产
        ,T3.REPO_AST + T3.REPO_AST_INT AS REPO_AST_FULL -- 回购资产(全价)
        ,T3.FUTR_AST -- 期货资产
        ,T3.WRNT_AST -- 权证资产
        ,T3.DPSI_AST -- 存款资产
        ,T3.NSP_AST -- 非标资产
        ,T3.TDY_DAY_YIEL -- 当日日收益
        ,T3.TOTAL_CAOU_AMT -- 累计派现金额
        ,T3.PER_MICP_YIEL -- 每万份收益
        ,T3.TOTAL_PER_MICP_YIEL -- 每万份基金本年累计收益
        ,T3.7D_AROR -- 七日年化收益率
        ,T3.DEVI_AMT -- 偏离金额
        ,T3.DEVIATION -- 偏离度
        ,T3.BEGIN_UNIT_NAV -- 期初单位净值
        ,T3.YEST_UNIT_NAV -- 昨日单位净值
        ,T3.TOTAL_UNIT_NAV -- 累计单位净值
        ,T3.NAV_DAYGROWRATE -- 净值日增长率
        ,T3.TOTAL_NAV_GRW_RATE --累计净值增长率
        ,T3.PORTF_REMA_MATY -- 投资组合剩余期限
        ,T3.PORTF_AVG_REMA_DURATION -- 投资组合平均剩余存续期
        ,T3.RSTT_UNIT_NAV -- 复权单位净值
        ,T3.CLEAR_AMT_SH -- 上海证券清算款
        ,T3.CLEAR_AMT_SZ -- 深圳证券清算款
        ,T3.CLEAR_AMT_INBK --银行间证券清算款
        ,T3.RSV_SH -- 上海备付金
        ,T3.RSV_SZ --深圳备付金
        ,T3.RSV_FUTR -- 期货备付金
        ,T3.RSV_OPT -- 期权备付金
        ,T3.RSV_SHSC -- 沪港通备付金
        ,T3.RSV_SZSC -- 深港通备付金
        ,T3.EARN_SH -- 上海保证金
        ,T3.EARN_SZ --深圳保证金
        ,T3.EARN_FUTR -- 期货保证金
        ,T3.EARN_OPT -- 期权保证金
        ,T3.EARN_SHSC -- 沪港通保证金
        ,T3.EARN_SZSC -- 深港通保证金
        ,T3.SSYS  -- 源系统
        ,T3.SOURCE_TAB -- 源表
        ,T3.LD_TIME  -- 加载时间
        ,T3.MODIFY_TIME -- 修改时间
        ,CASE WHEN T3.MANAGE_FEE <> 0 THEN  T3.MANAGE_FEE ELSE T5.LC_MVAL END   --管理费
        ,T3.CUSTOD_FEE -- 托管费
        ,CASE WHEN T3.SALE_FEE <> 0 THEN  T3.SALE_FEE ELSE T6.LC_MVAL END -- 销售服务费
        ,T3.RISK_RES -- 风险准备金
        ,T3.PERF_REMU -- 业绩报酬
        ,T3.CLEAR_AMT_SHSC --沪港通证券清算款
        ,T3.CLEAR_AMT_SZSC --深港通证券清算款
        ,T3.CLEAR_AMT_FUTR --期货证券清算款
        ,T3.POSIT_REPO_AST -- 正回购资产
        ,T3.BUY_REPO_AST -- 逆回购资产
    FROM
       (
        SELECT
            T1.VALU_DATE AS BIZ_DATE -- 业务日期
            ,T1.SFAC_NO AS SFAC_NO -- 账套编号
            ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
            ,T1.PROD_CODE AS PROD_CODE -- 产品代码
            ,T2.CNAME AS PROD_NAME -- 产品名称
            ,CASE WHEN T1.IS_CLAS_PROD='1' THEN 
                      CASE WHEN LENGTH(SUBSTR(T1.INDX_TOTAL_PROJ,6))=0 THEN '' 
                      ELSE SUBSTR(T1.INDX_TOTAL_PROJ,6) 
                      END 
                  ELSE '' 
                  END AS CLAS_PROD_CODE -- 分级产品代码
            ,T2.PROD_TYPE_CODE AS PROD_CATG -- 产品类别
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0003%' THEN T1.HLDP_QTY ELSE 0 END) AS AST_SHARE -- 资产份额
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0001%' THEN T1.LC_MVAL ELSE 0 END) AS AST_NAV -- 资产净值（市值）
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0001%' THEN T1.LC_COST ELSE 0 END) AS AST_NAV_COST -- 资产净值（成本）
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0110%' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS AST_UNIT_NAV -- 资产单位净值
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ='0008' THEN T1.LC_MVAL ELSE 0 END) AS AST_TOTAL -- 资产合计（市值）0008
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ='0008' THEN T1.LC_COST ELSE 0 END) AS AST_TOTAL_COST -- 资产合计（成本）0008
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ='0009' THEN T1.LC_MVAL ELSE 0 END) AS LIAB_TOTAL -- 负债合计0009
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '10%' AND T1.CRSE_PROP_NAME NOT LIKE '%应计利息%' THEN T1.LC_MVAL ELSE 0 END) AS CASH_AST -- 现金资产 --  CRSE_DETAIL_FLAG=1 AND (CRSE_PROP LIKE '10%' AND CRSE_PROP_NAME NOT LIKE '%应计利息%') 含银行活期、定期、协议、通知、结构化存款，保证金，备付金
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ='0400' THEN T1.LC_MVAL ELSE 0 END) AS UN_CASH_AST -- 非现金资产  -- 0400
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND 
                          (((T1.CRSE_PROP LIKE '10%' OR T1.CRSE_PROP LIKE '1202%') AND T1.CRSE_PROP_NAME LIKE '%应计利息%') OR T1.CRSE_PROP LIKE '1203%' 
                            OR T1.CRSE_PROP LIKE '1204%' OR T1.CRSE_PROP LIKE '1207%' OR T1.CRSE_PROP LIKE '1221%'
                            ) THEN LC_MVAL 
                      ELSE 0 END
                ) AS RECV_AST -- 应收资产 -- -- 含 存款、备付金、保证金、应计利息，债券，逆回购应计利息，其他应收等
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND 
                            ((T1.CRSE_PROP LIKE '2202%' AND T1.CRSE_PROP_NAME LIKE '%应计利息%') 
                              OR T1.CRSE_PROP LIKE '2203%' OR T1.CRSE_PROP LIKE '2204%' OR T1.CRSE_PROP LIKE '2206%' OR T1.CRSE_PROP LIKE '2207%' 
                              OR T1.CRSE_PROP LIKE '2208%' OR T1.CRSE_PROP LIKE '2209%' OR T1.CRSE_PROP LIKE '2221%' OR T1.CRSE_PROP LIKE '2231%'
                              OR T1.CRSE_PROP LIKE '2232%' OR T1.CRSE_PROP LIKE '2241%' OR T1.CRSE_PROP LIKE '2251%' OR T1.CRSE_PROP LIKE '2501%'
                             ) THEN LC_MVAL 
                        ELSE 0 END
                ) AS PAYB_AST -- 应付资产 --含 正回购应计利息，其他应收款，应付申购款，应付费用等
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='06' AND T1.CRSE_PROP_NAME LIKE '%成本%' THEN T1.LC_MVAL ELSE 0 END) AS STK_AST -- 股票资产 SCR_TYPE=03  
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='03' AND T1.CRSE_PROP_NAME LIKE '%成本%' THEN T1.LC_MVAL ELSE 0 END) AS BOND_AST -- 债券资产 SCR_TYPE=03
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='03' AND (T1.CRSE_PROP_NAME LIKE '%应收利息%' OR T1.   CRSE_PROP_NAME LIKE '%应计利息%') THEN T1.LC_MVAL ELSE 0 END) AS BOND_AST_INT -- 债券利息 
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='07' AND T1.CRSE_PROP_NAME LIKE '%成本%' THEN T1.LC_MVAL ELSE 0 END) AS FUND_AST -- 基金资产 SCR_TYPE=07 
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='04' AND T1.CRSE_PROP_NAME LIKE '%成本%' THEN T1.LC_MVAL ELSE 0 END) AS REPO_AST -- 回购资产 SCR_TYPE=04
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='04' AND T1.CRSE_PROP LIKE '2202%' AND T1.CRSE_PROP_NAME LIKE '%成本%' THEN T1.LC_MVAL ELSE 0 END) AS POSIT_REPO_AST -- 正回购资产 SCR_TYPE=04
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='04' AND T1.CRSE_PROP LIKE '1202%' AND T1.CRSE_PROP_NAME LIKE '%成本%' THEN T1.LC_MVAL ELSE 0 END) AS BUY_REPO_AST -- 逆回购资产 SCR_TYPE=04
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND (T1.SCR_TYPE='04' OR T1.SCR_INCD='-1') AND (T1.CRSE_PROP_NAME LIKE '%应收利息%' OR T1.   CRSE_PROP_NAME LIKE '%应计利息%') THEN T1.LC_MVAL ELSE 0 END) AS REPO_AST_INT -- 回购收益
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='10' AND T1.CRSE_PROP_NAME LIKE '%初始合约价值%' AND T1.CRSE_PROP_NAME NOT LIKE '%冲销%' THEN T1.LC_MVAL ELSE 0 END) AS FUTR_AST -- 期货资产 
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE='01' AND T1.CRSE_PROP_NAME LIKE '%成本%' THEN T1.LC_MVAL ELSE 0 END) AS WRNT_AST -- 权证资产 SCR_TYPE=01
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND (T1.CRSE_PROP LIKE '1002%' AND T1.CRSE_PROP_NAME NOT LIKE '%应计利息%') THEN T1.LC_MVAL ELSE 0 END) AS DPSI_AST -- 存款资产  含银行活期、定期、协议、通知、结构化存款等其他存款
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.SCR_TYPE NOT IN ('01','03','04','06','07','10') AND T1.CRSE_PROP_NAME LIKE '%成本%' THEN T1.LC_MVAL ELSE 0 END) AS NSP_AST -- 非标资产 
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0022%' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS TDY_DAY_YIEL -- 当日日收益 0022
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0131%' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS TOTAL_CAOU_AMT -- 累计派现金额 0131
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0021%' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS PER_MICP_YIEL -- 每万份收益 0021
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0023%' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS TOTAL_PER_MICP_YIEL -- 每万份基金年累计收益 0023
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0020%' THEN SPLIT(T1.CRSE_NAME,'\%')[0] ELSE 0 END) AS 7D_AROR -- 七日年化收益率 0020
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ='0028' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS DEVI_AMT -- 偏离金额 0028
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ='0029' THEN SPLIT(T1.CRSE_NAME,'\%')[0] ELSE 0 END) AS DEVIATION -- 偏离度 0029
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0112%' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS BEGIN_UNIT_NAV -- 期初单位净值 0112
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0111%' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS YEST_UNIT_NAV -- 昨日单位净值 0111
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0114%' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS TOTAL_UNIT_NAV -- 累计单位净值 0114
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0122%' THEN SPLIT(T1.CRSE_NAME,'\%')[0] ELSE 0 END) AS NAV_DAYGROWRATE -- 净值日增长率 0122
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ LIKE '0123%' THEN SPLIT(T1.CRSE_NAME,'\%')[0] ELSE 0 END) AS TOTAL_NAV_GRW_RATE -- 累计净值增长率 0123
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ='0014' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS PORTF_REMA_MATY -- 投资组合剩余期限 0014
            ,SUM(CASE WHEN T1.INDX_TOTAL_PROJ='0026' THEN REPLACE(T1.CRSE_NAME,',','') ELSE 0 END) AS PORTF_AVG_REMA_DURATION -- 投资组合平均剩余存续期 0026
            ,0 AS RSTT_UNIT_NAV -- 复权单位净值
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '3003%' AND T1.CRSE_PROP_NAME LIKE '证券清算款_上交所%' THEN T1.LC_MVAL ELSE 0 END) AS CLEAR_AMT_SH -- 上海证券清算款
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '3003%' AND T1.CRSE_PROP_NAME LIKE '证券清算款_深交所%' THEN T1.LC_MVAL ELSE 0 END) AS CLEAR_AMT_SZ -- 深圳证券清算款
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '3003%' AND T1.CRSE_PROP_NAME LIKE '证券清算款%银行间%' THEN T1.LC_MVAL ELSE 0 END) AS CLEAR_AMT_INBK --银行间证券清算款
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '3003%' AND (T1.CRSE_PROP_NAME LIKE '证券清算款%沪港通%' OR T1.CRSE_PROP_NAME LIKE '证券清算款%沪股通%') THEN T1.LC_MVAL ELSE 0 END) AS CLEAR_AMT_SHSC --沪港通证券清算款
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '3003%' AND T1.CRSE_PROP_NAME LIKE '证券清算款%深港通%' THEN T1.LC_MVAL ELSE 0 END) AS CLEAR_AMT_SZSC --深港通证券清算款
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '3003%' AND T1.CRSE_PROP_NAME LIKE '证券清算款_期货%' THEN T1.LC_MVAL ELSE 0 END) AS CLEAR_AMT_FUTR --期货证券清算款
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1021%' AND T1.CRSE_PROP_NAME LIKE '结算备付金_上交所%' THEN T1.LC_MVAL ELSE 0 END) AS RSV_SH -- 上海备付金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1021%' AND T1.CRSE_PROP_NAME LIKE '结算备付金_深交所%' THEN T1.LC_MVAL ELSE 0 END) AS RSV_SZ --深圳备付金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1021%' AND T1.CRSE_PROP_NAME LIKE '结算备付金%期货%' THEN T1.LC_MVAL ELSE 0 END) AS RSV_FUTR -- 期货备付金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1021%' AND T1.CRSE_PROP_NAME LIKE '结算备付金%期权%' THEN T1.LC_MVAL ELSE 0 END) AS RSV_OPT -- 期权备付金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1021%' AND T1.CRSE_PROP_NAME LIKE '结算备付金_沪港通%' THEN T1.LC_MVAL ELSE 0 END) AS RSV_SHSC -- 沪港通备付金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1021%' AND T1.CRSE_PROP_NAME LIKE '结算备付金_深港通%' THEN T1.LC_MVAL ELSE 0 END) AS RSV_SZSC -- 深港通备付金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1031%' AND T1.CRSE_PROP_NAME LIKE '存出保证金%上交所%' THEN T1.LC_MVAL ELSE 0 END) AS EARN_SH -- 上海保证金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1031%' AND T1.CRSE_PROP_NAME LIKE '存出保证金%深交所%' THEN T1.LC_MVAL ELSE 0 END) AS EARN_SZ --深圳保证金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1031%' AND T1.CRSE_PROP_NAME LIKE '存出保证金%期货%' THEN T1.LC_MVAL ELSE 0 END) AS EARN_FUTR -- 期货保证金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1031%' AND T1.CRSE_PROP_NAME LIKE '存出保证金%期权%' THEN T1.LC_MVAL ELSE 0 END) AS EARN_OPT -- 期权保证金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1031%' AND T1.CRSE_PROP_NAME LIKE '存出保证金%沪港通%' THEN T1.LC_MVAL ELSE 0 END) AS EARN_SHSC -- 沪港通保证金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP LIKE '1031%' AND T1.CRSE_PROP_NAME LIKE '存出保证金%深港通%' THEN T1.LC_MVAL ELSE 0 END) AS EARN_SZSC -- 深港通保证金
            ,'HSFA' AS SSYS  -- 源系统
            ,'' AS SOURCE_TAB -- 源表
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME  -- 加载时间
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP_NAME LIKE '应付基金管理费%' THEN T1.LC_MVAL ELSE 0 END) AS MANAGE_FEE -- 管理费
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP_NAME LIKE '应付托管费%' THEN T1.LC_MVAL ELSE 0 END) AS CUSTOD_FEE -- 托管费
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP_NAME LIKE '应付销售服务费%' THEN T1.LC_MVAL ELSE 0 END) AS SALE_FEE -- 销售服务费
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP_NAME LIKE '应付风险金%' THEN T1.LC_MVAL ELSE 0 END) AS RISK_RES -- 风险准备金
            ,SUM(CASE WHEN T1.CRSE_DETAIL_FLAG=1 AND T1.CRSE_PROP_NAME LIKE '应付业绩报酬%' THEN T1.LC_MVAL ELSE 0 END) AS PERF_REMU -- 业绩报酬
        FROM DWDXDAY.DWD_AST_VALU_INFO_PTD T1 -- 估值信息
        LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T2
        ON T1.SFAC_NUM=T2.SFAC_NUM AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
        WHERE T1.P_DT = '${P_BATCH_DT}'
        GROUP BY T1.VALU_DATE,T1.SFAC_NO,T1.SFAC_NUM,T1.PROD_CODE
                ,CASE WHEN T1.IS_CLAS_PROD='1' THEN 
                      CASE WHEN LENGTH(SUBSTR(T1.INDX_TOTAL_PROJ,6))=0 THEN '' 
                      ELSE SUBSTR(T1.INDX_TOTAL_PROJ,6) 
                      END 
                 ELSE '' 
                 END
                 ,T2.CNAME,T2.PROD_TYPE_CODE
       ) T3
    LEFT JOIN (SELECT STD_DICT_CLS_CDVAL,STD_DICT_CLS_CDVAL_DESC FROM DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO WHERE STD_DICT_ID='DIC0000039') T4
    ON T3.PROD_CATG=T4.STD_DICT_CLS_CDVAL
    LEFT JOIN 
      (
      SELECT SFAC_NO,PROD_CODE,CRSE_CODE,CRSE_NAME,SUBSTR(regexp_replace(crse_name,'\\s',''),-6,6) AS CLAS_PROD_CODE,lc_mval FROM DWDXDAY.DWD_AST_VALU_INFO_PTD 
      WHERE P_DT='${P_BATCH_DT}' AND  crse_prop = '220601'
      )  T5 
      ON T3.SFAC_NO = T5.SFAC_NO
      AND T3.CLAS_PROD_CODE = T5.CLAS_PROD_CODE
     LEFT JOIN 
      (
      SELECT SFAC_NO,PROD_CODE,CRSE_CODE,CRSE_NAME,SUBSTR(regexp_replace(crse_name,'\\s',''),-6,6) AS CLAS_PROD_CODE,lc_mval FROM DWDXDAY.DWD_AST_VALU_INFO_PTD 
      WHERE P_DT='${P_BATCH_DT}' AND  crse_prop = '2208'
      )  T6 
      ON T3.SFAC_NO = T6.SFAC_NO
      AND T3.CLAS_PROD_CODE = T6.CLAS_PROD_CODE
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done