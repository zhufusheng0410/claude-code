
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
    -- ** 描述: 产品层汇总信息
    -- ** 创建者 : vhhv
    -- ** 创建日期: 20230621
    -- ** 目标表：DWSXDAY.DWS_PROD_SUM_INFO_PTD       产品层汇总信息
    -- ** 源表：  DWSXDAY.DWS_PROD_AST_INFO_PTD       产品资产信息
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
    
    INSERT OVERWRITE TABLE DWSXDAY.DWS_PROD_SUM_INFO_PTD PARTITION ( P_DT= '${P_BATCH_DT}')
    SELECT
        T5.SFAC_NO AS SFAC_NO -- 账套编号
        ,T5.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,T5.PROD_CODE AS PROD_CODE -- 产品代码
        ,MAX(T5.PROD_NAME) AS PROD_NAME --产品名称
        ,T5.CLAS_PROD_CODE  --分级产品代码
        ,T5.BIZ_DATE AS BIZ_DATE -- 业务日期
        ,SUM(T5.AST_SHARE) AS AST_SHARE -- 资产份额
        ,SUM(T5.LST_DAY_AST_SHARE) AS LST_DAY_AST_SHARE -- 上一日资产份额
        ,SUM(T5.MTB_AST_SHARE) AS MTB_AST_SHARE -- 月初资产份额
        ,SUM(T5.BOQ_AST_SHARE) AS BOQ_AST_SHARE -- 季初资产份额
        ,SUM(T5.BEGINYEAR_AST_SHARE) AS BEGINYEAR_AST_SHARE -- 年初资产份额
        ,SUM(T5.AST_NAV) AS AST_NAV -- 资产净值
        ,SUM(T5.LST_DAY_AST_NAV) AS LST_DAY_AST_NAV -- 上一日资产净值
        ,SUM(T5.MTB_AST_NAV) AS MTB_AST_NAV -- 月初资产净值
        ,SUM(T5.BOQ_AST_NAV) AS BOQ_AST_NAV -- 季初资产净值
        ,SUM(T5.BEGINYEAR_AST_NAV) AS BEGINYEAR_AST_NAV -- 年初资产净值
        ,SUM(T5.AST_TOT_VAL) AS AST_TOT_VAL -- 资产总值
        ,SUM(T5.LST_DAY_AST_TOT_VAL) AS LST_DAY_AST_TOT_VAL -- 上一日资产总值
        ,SUM(T5.MTB_AST_TOT_VAL) AS MTB_AST_TOT_VAL -- 月初资产总值
        ,SUM(T5.BOQ_AST_TOT_VAL) AS BOQ_AST_TOT_VAL -- 季初资产总值
        ,SUM(T5.BEGINYEAR_AST_TOT_VAL) AS BEGINYEAR_AST_TOT_VAL -- 年初资产总值
        ,SUM(T5.LIAB_TOT_VAL) AS LIAB_TOT_VAL -- 负债总值
        ,SUM(T5.LST_DAY_LIAB_TOT_VAL) AS LST_DAY_LIAB_TOT_VAL -- 上一日负债总值
        ,SUM(T5.MTB_LIAB_TOT_VAL) AS MTB_LIAB_TOT_VAL -- 月初负债总值
        ,SUM(T5.BOQ_LIAB_TOT_VAL) AS BOQ_LIAB_TOT_VAL -- 季初负债总值
        ,SUM(T5.BEGINYEAR_LIAB_TOT_VAL) AS BEGINYEAR_LIAB_TOT_VAL -- 年初负债总值
        ,SUM(T5.UNIT_NAV) AS UNIT_NAV -- 单位净值
        ,SUM(T5.LST_DAY_UNIT_NAV) AS LST_DAY_UNIT_NAV -- 上一日单位净值
        ,SUM(T5.MTB_UNIT_NAV) AS MTB_UNIT_NAV -- 月初单位净值
        ,SUM(T5.BOQ_UNIT_NAV) AS BOQ_UNIT_NAV -- 季初单位净值
        ,SUM(T5.BEGINYEAR_UNIT_NAV) AS BEGINYEAR_UNIT_NAV -- 年初单位净值
        ,SUM(T5.TOTAL_UNIT_NAV) AS TOTAL_UNIT_NAV -- 累计单位净值
        ,SUM(T5.LST_DAY_TOTAL_UNIT_NAV) AS LST_DAY_TOTAL_UNIT_NAV -- 上一日累计单位净值
        ,SUM(T5.MTB_TOTAL_UNIT_NAV) AS MTB_TOTAL_UNIT_NAV -- 月初累计单位净值
        ,SUM(T5.BOQ_TOTAL_UNIT_NAV) AS BOQ_TOTAL_UNIT_NAV -- 季初累计单位净值
        ,SUM(T5.BEGINYEAR_TOTAL_UNIT_NAV) AS BEGINYEAR_TOTAL_UNIT_NAV -- 年初累计单位净值
        ,SUM(T5.UNIT_BONUS) AS UNIT_BONUS -- 累计派现金额
        ,SUM(T5.LST_DAY_UNIT_BONUS) AS LST_DAY_UNIT_BONUS -- 上一日累计派现金额
        ,SUM(T5.MTH_TOTAL_UNIT_BONUS) AS MTH_TOTAL_UNIT_BONUS -- 月初累计派现金额
        ,SUM(T5.BOQ_TOTAL_UNIT_BONUS) AS BOQ_TOTAL_UNIT_BONUS -- 季初累计派现金额
        ,SUM(T5.YEAR_TOTAL_UNIT_BONUS) AS YEAR_TOTAL_UNIT_BONUS -- 年初累计派现金额
        ,SUM(T5.TDY_CPTL_NETIN) AS TDY_CPTL_NETIN -- 当日资金净流入
        ,SUM(T5.TDY_CPTL_IN) AS TDY_CPTL_IN -- 当日资金流入
        ,SUM(T5.TDY_CPTL_OUT) AS TDY_CPTL_OUT -- 当日资金流出
        ,SUM(T5.TMTH_CPTL_NETIN) AS TMTH_CPTL_NETIN -- 当月资金净流入
        ,SUM(T5.TMTH_CPTL_IN) AS TMTH_CPTL_IN -- 当月资金流入
        ,SUM(T5.TMTH_CPTL_OUT) AS TMTH_CPTL_OUT -- 当月资金流出
        ,SUM(T5.TQ_CPTL_NETIN) AS TQ_CPTL_NETIN -- 当季资金净流入
        ,SUM(T5.TQ_CPTL_IN) AS TQ_CPTL_IN -- 当季资金流入
        ,SUM(T5.TQ_CPTL_OUT) AS TQ_CPTL_OUT -- 当季资金流出
        ,SUM(T5.SOTHISYEAR_CPTL_NETIN) AS SOTHISYEAR_CPTL_NETIN -- 今年以来资金净流入
        ,SUM(T5.SOTHISYEAR_CPTL_IN) AS SOTHISYEAR_CPTL_IN -- 今年以来资金流入
        ,SUM(T5.SOTHISYEAR_CPTL_OUT) AS SOTHISYEAR_CPTL_OUT -- 今年以来资金流出
        ,'HSFA' AS SSYS  -- 源系统
        ,'DWS_PROD_AST_INFO_PTD' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME  -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM
        (   
        -- 当日
        SELECT
            T1.SFAC_NO AS SFAC_NO -- 账套编号
            ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
            ,T1.PROD_CODE AS PROD_CODE -- 产品代码
            ,T1.PROD_NAME AS PROD_NAME -- 产品名称
            ,T1.CLAS_PROD_CODE  --分级产品代码
            ,T1.BIZ_DATE AS BIZ_DATE -- 业务日期
            ,T1.AST_SHARE AS AST_SHARE -- 资产份额
            ,0 AS LST_DAY_AST_SHARE -- 上一日资产份额
            ,0 AS MTB_AST_SHARE -- 月初资产份额
            ,0 AS BOQ_AST_SHARE -- 季初资产份额
            ,0 AS BEGINYEAR_AST_SHARE -- 年初资产份额
            ,T1.AST_NAV AS AST_NAV -- 资产净值
            ,0 AS LST_DAY_AST_NAV -- 上一日资产净值
            ,0 AS MTB_AST_NAV -- 月初资产净值
            ,0 AS BOQ_AST_NAV -- 季初资产净值
            ,0 AS BEGINYEAR_AST_NAV -- 年初资产净值
            ,T1.AST_TOTAL AS AST_TOT_VAL -- 资产总值
            ,0 AS LST_DAY_AST_TOT_VAL -- 上一日资产总值
            ,0 AS MTB_AST_TOT_VAL -- 月初资产总值
            ,0 AS BOQ_AST_TOT_VAL -- 季初资产总值
            ,0 AS BEGINYEAR_AST_TOT_VAL -- 年初资产总值
            ,T1.LIAB_TOTAL AS LIAB_TOT_VAL -- 负债总值
            ,0 AS LST_DAY_LIAB_TOT_VAL -- 上一日负债总值
            ,0 AS MTB_LIAB_TOT_VAL -- 月初负债总值
            ,0 AS BOQ_LIAB_TOT_VAL -- 季初负债总值
            ,0 AS BEGINYEAR_LIAB_TOT_VAL -- 年初负债总值
            ,T1.AST_UNIT_NAV AS UNIT_NAV -- 单位净值
            ,0 AS LST_DAY_UNIT_NAV -- 上一日单位净值
            ,0 AS MTB_UNIT_NAV -- 月初单位净值
            ,0 AS BOQ_UNIT_NAV -- 季初单位净值
            ,0 AS BEGINYEAR_UNIT_NAV -- 年初单位净值
            ,T1.TOTAL_UNIT_NAV AS TOTAL_UNIT_NAV -- 累计单位净值
            ,0 AS LST_DAY_TOTAL_UNIT_NAV -- 上一日累计单位净值
            ,0 AS MTB_TOTAL_UNIT_NAV -- 月初累计单位净值
            ,0 AS BOQ_TOTAL_UNIT_NAV -- 季初累计单位净值
            ,0 AS BEGINYEAR_TOTAL_UNIT_NAV -- 年初累计单位净值
            ,T1.TOTAL_CAOU_AMT AS UNIT_BONUS -- 单位分红
            ,0 AS LST_DAY_UNIT_BONUS --上一日单位分红
            ,0 AS MTH_TOTAL_UNIT_BONUS -- 月累计单位分红
            ,0 AS BOQ_TOTAL_UNIT_BONUS -- 季累计单位分红
            ,0 AS YEAR_TOTAL_UNIT_BONUS -- 年累计单位分红
            ,0 AS TDY_CPTL_NETIN -- 当日资金净流入
            ,0 AS TDY_CPTL_IN -- 当日资金流入
            ,0 AS TDY_CPTL_OUT -- 当日资金流出
            ,0 AS TMTH_CPTL_NETIN -- 当月资金净流入
            ,0 AS TMTH_CPTL_IN -- 当月资金流入
            ,0 AS TMTH_CPTL_OUT -- 当月资金流出
            ,0 AS TQ_CPTL_NETIN -- 当季资金净流入
            ,0 AS TQ_CPTL_IN -- 当季资金流入
            ,0 AS TQ_CPTL_OUT -- 当季资金流出
            ,0 AS SOTHISYEAR_CPTL_NETIN -- 今年以来资金净流入
            ,0 AS SOTHISYEAR_CPTL_IN -- 今年以来资金流入
            ,0 AS SOTHISYEAR_CPTL_OUT -- 今年以来资金流出
        FROM DWSXDAY.DWS_PROD_AST_INFO_PTD T1 -- 产品资产信息
        WHERE T1.P_DT = '${P_BATCH_DT}' 
        UNION ALL
        -- 上一日
        SELECT
            T1.SFAC_NO AS SFAC_NO -- 账套编号
            ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
            ,T1.PROD_CODE AS PROD_CODE -- 产品代码
            ,T1.PROD_NAME AS PROD_NAME -- 产品名称
            ,T1.CLAS_PROD_CODE  --分级产品代码
            ,'${P_BATCH_DT}' AS BIZ_DATE -- 业务日期
            ,0 AS AST_SHARE -- 资产份额
            ,T1.AST_SHARE AS LST_DAY_AST_SHARE -- 上一日资产份额
            ,0 AS MTB_AST_SHARE -- 月初资产份额
            ,0 AS BOQ_AST_SHARE -- 季初资产份额
            ,0 AS BEGINYEAR_AST_SHARE -- 年初资产份额
            ,0 AS AST_NAV -- 资产净值
            ,T1.AST_NAV AS LST_DAY_AST_NAV -- 上一日资产净值
            ,0 AS MTB_AST_NAV -- 月初资产净值
            ,0 AS BOQ_AST_NAV -- 季初资产净值
            ,0 AS BEGINYEAR_AST_NAV -- 年初资产净值
            ,0 AS AST_TOT_VAL -- 资产总值
            ,T1.AST_TOTAL AS LST_DAY_AST_TOT_VAL -- 上一日资产总值
            ,0 AS MTB_AST_TOT_VAL -- 月初资产总值
            ,0 AS BOQ_AST_TOT_VAL -- 季初资产总值
            ,0 AS BEGINYEAR_AST_TOT_VAL -- 年初资产总值
            ,0 AS LIAB_TOT_VAL -- 负债总值
            ,T1.LIAB_TOTAL AS LST_DAY_LIAB_TOT_VAL -- 上一日负债总值
            ,0 AS MTB_LIAB_TOT_VAL -- 月初负债总值
            ,0 AS BOQ_LIAB_TOT_VAL -- 季初负债总值
            ,0 AS BEGINYEAR_LIAB_TOT_VAL -- 年初负债总值
            ,0 AS UNIT_NAV -- 单位净值
            ,T1.AST_UNIT_NAV AS LST_DAY_UNIT_NAV -- 上一日单位净值
            ,0 AS MTB_UNIT_NAV -- 月初单位净值
            ,0 AS BOQ_UNIT_NAV -- 季初单位净值
            ,0 AS BEGINYEAR_UNIT_NAV -- 年初单位净值
            ,0 AS TOTAL_UNIT_NAV -- 累计单位净值
            ,T1.TOTAL_UNIT_NAV AS LST_DAY_TOTAL_UNIT_NAV -- 上一日累计单位净值
            ,0 AS MTB_TOTAL_UNIT_NAV -- 月初累计单位净值
            ,0 AS BOQ_TOTAL_UNIT_NAV -- 季初累计单位净值
            ,0 AS BEGINYEAR_TOTAL_UNIT_NAV -- 年初累计单位净值
            ,0 AS UNIT_BONUS -- 单位分红
            ,T1.TOTAL_CAOU_AMT AS LST_DAY_UNIT_BONUS --上一日单位分红
            ,0 AS MTH_TOTAL_UNIT_BONUS -- 月累计单位分红
            ,0 AS BOQ_TOTAL_UNIT_BONUS -- 季累计单位分红
            ,0 AS YEAR_TOTAL_UNIT_BONUS -- 年累计单位分红
            ,0 AS TDY_CPTL_NETIN -- 当日资金净流入
            ,0 AS TDY_CPTL_IN -- 当日资金流入
            ,0 AS TDY_CPTL_OUT -- 当日资金流出
            ,0 AS TMTH_CPTL_NETIN -- 当月资金净流入
            ,0 AS TMTH_CPTL_IN -- 当月资金流入
            ,0 AS TMTH_CPTL_OUT -- 当月资金流出
            ,0 AS TQ_CPTL_NETIN -- 当季资金净流入
            ,0 AS TQ_CPTL_IN -- 当季资金流入
            ,0 AS TQ_CPTL_OUT -- 当季资金流出
            ,0 AS SOTHISYEAR_CPTL_NETIN -- 今年以来资金净流入
            ,0 AS SOTHISYEAR_CPTL_IN -- 今年以来资金流入
            ,0 AS SOTHISYEAR_CPTL_OUT -- 今年以来资金流出
        FROM DWSXDAY.DWS_PROD_AST_INFO_PTD T1 -- 产品资产信息
        WHERE T1.P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST('${P_BATCH_DT}' AS STRING),'yyyyMMdd'))),1),'yyyyMMdd')
        UNION ALL
        -- 月初
        SELECT
            T1.SFAC_NO AS SFAC_NO -- 账套编号
            ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
            ,T1.PROD_CODE AS PROD_CODE -- 产品代码
            ,T1.PROD_NAME AS PROD_NAME -- 产品名称
            ,T1.CLAS_PROD_CODE  --分级产品代码
            ,'${P_BATCH_DT}' AS BIZ_DATE -- 业务日期
            ,0 AS AST_SHARE -- 资产份额
            ,0 AS LST_DAY_AST_SHARE -- 上一日资产份额
            ,T1.AST_SHARE AS MTB_AST_SHARE -- 月初资产份额
            ,0 AS BOQ_AST_SHARE -- 季初资产份额
            ,0 AS BEGINYEAR_AST_SHARE -- 年初资产份额
            ,0 AS AST_NAV -- 资产净值
            ,0 AS LST_DAY_AST_NAV -- 上一日资产净值
            ,T1.AST_NAV AS MTB_AST_NAV -- 月初资产净值
            ,0 AS BOQ_AST_NAV -- 季初资产净值
            ,0 AS BEGINYEAR_AST_NAV -- 年初资产净值
            ,0 AS AST_TOT_VAL -- 资产总值
            ,0 AS LST_DAY_AST_TOT_VAL -- 上一日资产总值
            ,T1.AST_TOTAL AS MTB_AST_TOT_VAL -- 月初资产总值
            ,0 AS BOQ_AST_TOT_VAL -- 季初资产总值
            ,0 AS BEGINYEAR_AST_TOT_VAL -- 年初资产总值
            ,0 AS LIAB_TOT_VAL -- 负债总值
            ,0 AS LST_DAY_LIAB_TOT_VAL -- 上一日负债总值
            ,T1.LIAB_TOTAL AS MTB_LIAB_TOT_VAL -- 月初负债总值
            ,0 AS BOQ_LIAB_TOT_VAL -- 季初负债总值
            ,0 AS BEGINYEAR_LIAB_TOT_VAL -- 年初负债总值
            ,0 AS UNIT_NAV -- 单位净值
            ,0 AS LST_DAY_UNIT_NAV -- 上一日单位净值
            ,T1.AST_UNIT_NAV AS MTB_UNIT_NAV -- 月初单位净值
            ,0 AS BOQ_UNIT_NAV -- 季初单位净值
            ,0 AS BEGINYEAR_UNIT_NAV -- 年初单位净值
            ,0 AS TOTAL_UNIT_NAV -- 累计单位净值
            ,0 AS LST_DAY_TOTAL_UNIT_NAV -- 上一日累计单位净值
            ,T1.TOTAL_UNIT_NAV AS MTB_TOTAL_UNIT_NAV -- 月初累计单位净值
            ,0 AS BOQ_TOTAL_UNIT_NAV -- 季初累计单位净值
            ,0 AS BEGINYEAR_TOTAL_UNIT_NAV -- 年初累计单位净值
            ,0 AS UNIT_BONUS -- 单位分红
            ,0 AS LST_DAY_UNIT_BONUS --上一日单位分红
            ,T1.TOTAL_CAOU_AMT AS MTH_TOTAL_UNIT_BONUS -- 月累计单位分红
            ,0 AS BOQ_TOTAL_UNIT_BONUS -- 季累计单位分红
            ,0 AS YEAR_TOTAL_UNIT_BONUS -- 年累计单位分红
            ,0 AS TDY_CPTL_NETIN -- 当日资金净流入
            ,0 AS TDY_CPTL_IN -- 当日资金流入
            ,0 AS TDY_CPTL_OUT -- 当日资金流出
            ,0 AS TMTH_CPTL_NETIN -- 当月资金净流入
            ,0 AS TMTH_CPTL_IN -- 当月资金流入
            ,0 AS TMTH_CPTL_OUT -- 当月资金流出
            ,0 AS TQ_CPTL_NETIN -- 当季资金净流入
            ,0 AS TQ_CPTL_IN -- 当季资金流入
            ,0 AS TQ_CPTL_OUT -- 当季资金流出
            ,0 AS SOTHISYEAR_CPTL_NETIN -- 今年以来资金净流入
            ,0 AS SOTHISYEAR_CPTL_IN -- 今年以来资金流入
            ,0 AS SOTHISYEAR_CPTL_OUT -- 今年以来资金流出
        FROM DWSXDAY.DWS_PROD_AST_INFO_PTD T1 -- 产品资产信息
        WHERE T1.P_DT = CONCAT(SUBSTR('${P_BATCH_DT}',1,6),'01')
        UNION ALL
        -- 季初
        SELECT
            T1.SFAC_NO AS SFAC_NO -- 账套编号
            ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
            ,T1.PROD_CODE AS PROD_CODE -- 产品代码
            ,T1.PROD_NAME AS PROD_NAME -- 产品名称
            ,T1.CLAS_PROD_CODE  --分级产品代码
            ,'${P_BATCH_DT}' AS BIZ_DATE -- 业务日期
            ,0 AS AST_SHARE -- 资产份额
            ,0 AS LST_DAY_AST_SHARE -- 上一日资产份额
            ,0 AS MTB_AST_SHARE -- 月初资产份额
            ,T1.AST_SHARE AS BOQ_AST_SHARE -- 季初资产份额
            ,0 AS BEGINYEAR_AST_SHARE -- 年初资产份额
            ,0 AS AST_NAV -- 资产净值
            ,0 AS LST_DAY_AST_NAV -- 上一日资产净值
            ,0 AS MTB_AST_NAV -- 月初资产净值
            ,T1.AST_NAV AS BOQ_AST_NAV -- 季初资产净值
            ,0 AS BEGINYEAR_AST_NAV -- 年初资产净值
            ,0 AS AST_TOT_VAL -- 资产总值
            ,0 AS LST_DAY_AST_TOT_VAL -- 上一日资产总值
            ,0 AS MTB_AST_TOT_VAL -- 月初资产总值
            ,T1.AST_TOTAL AS BOQ_AST_TOT_VAL -- 季初资产总值
            ,0 AS BEGINYEAR_AST_TOT_VAL -- 年初资产总值
            ,0 AS LIAB_TOT_VAL -- 负债总值
            ,0 AS LST_DAY_LIAB_TOT_VAL -- 上一日负债总值
            ,0 AS MTB_LIAB_TOT_VAL -- 月初负债总值
            ,T1.LIAB_TOTAL AS BOQ_LIAB_TOT_VAL -- 季初负债总值
            ,0 AS BEGINYEAR_LIAB_TOT_VAL -- 年初负债总值
            ,0 AS UNIT_NAV -- 单位净值
            ,0 AS LST_DAY_UNIT_NAV -- 上一日单位净值
            ,0 AS MTB_UNIT_NAV -- 月初单位净值
            ,T1.AST_UNIT_NAV AS BOQ_UNIT_NAV -- 季初单位净值
            ,0 AS BEGINYEAR_UNIT_NAV -- 年初单位净值
            ,0 AS TOTAL_UNIT_NAV -- 累计单位净值
            ,0 AS LST_DAY_TOTAL_UNIT_NAV -- 上一日累计单位净值
            ,0 AS MTB_TOTAL_UNIT_NAV -- 月初累计单位净值
            ,T1.TOTAL_UNIT_NAV AS BOQ_TOTAL_UNIT_NAV -- 季初累计单位净值
            ,0 AS BEGINYEAR_TOTAL_UNIT_NAV -- 年初累计单位净值
            ,0 AS UNIT_BONUS -- 单位分红
            ,0 AS LST_DAY_UNIT_BONUS --上一日单位分红
            ,0 AS MTH_TOTAL_UNIT_BONUS -- 月累计单位分红
            ,T1.TOTAL_CAOU_AMT AS BOQ_TOTAL_UNIT_BONUS -- 季累计单位分红
            ,0 AS YEAR_TOTAL_UNIT_BONUS -- 年累计单位分红
            ,0 AS TDY_CPTL_NETIN -- 当日资金净流入
            ,0 AS TDY_CPTL_IN -- 当日资金流入
            ,0 AS TDY_CPTL_OUT -- 当日资金流出
            ,0 AS TMTH_CPTL_NETIN -- 当月资金净流入
            ,0 AS TMTH_CPTL_IN -- 当月资金流入
            ,0 AS TMTH_CPTL_OUT -- 当月资金流出
            ,0 AS TQ_CPTL_NETIN -- 当季资金净流入
            ,0 AS TQ_CPTL_IN -- 当季资金流入
            ,0 AS TQ_CPTL_OUT -- 当季资金流出
            ,0 AS SOTHISYEAR_CPTL_NETIN -- 今年以来资金净流入
            ,0 AS SOTHISYEAR_CPTL_IN -- 今年以来资金流入
            ,0 AS SOTHISYEAR_CPTL_OUT -- 今年以来资金流出
        FROM DWSXDAY.DWS_PROD_AST_INFO_PTD T1 -- 产品资产信息
        WHERE T1.P_DT = CASE WHEN SUBSTR('${P_BATCH_DT}',5,2) IN ('01','02','03') THEN CONCAT(SUBSTR('${P_BATCH_DT}',1,4),'0101')
             WHEN SUBSTR('${P_BATCH_DT}',5,2) IN ('04','05','06') THEN CONCAT (SUBSTR('${P_BATCH_DT}',1,4),'0401')
             WHEN SUBSTR('${P_BATCH_DT}',5,2) IN ('07','08','09') THEN CONCAT (SUBSTR('${P_BATCH_DT}',1,4),'0701')
             ELSE CONCAT(SUBSTR('${P_BATCH_DT}',1,4),'1001')
             END
        UNION ALL
        -- 年初
        SELECT
            T1.SFAC_NO AS SFAC_NO -- 账套编号
            ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
            ,T1.PROD_CODE AS PROD_CODE -- 产品代码
            ,T1.PROD_NAME AS PROD_NAME -- 产品名称
            ,T1.CLAS_PROD_CODE  --分级产品代码
            ,'${P_BATCH_DT}' AS BIZ_DATE -- 业务日期
            ,0 AS AST_SHARE -- 资产份额
            ,0 AS LST_DAY_AST_SHARE -- 上一日资产份额
            ,0 AS MTB_AST_SHARE -- 月初资产份额
            ,0 AS BOQ_AST_SHARE -- 季初资产份额
            ,T1.AST_SHARE AS BEGINYEAR_AST_SHARE -- 年初资产份额
            ,0 AS AST_NAV -- 资产净值
            ,0 AS LST_DAY_AST_NAV -- 上一日资产净值
            ,0 AS MTB_AST_NAV -- 月初资产净值
            ,0 AS BOQ_AST_NAV -- 季初资产净值
            ,T1.AST_NAV AS BEGINYEAR_AST_NAV -- 年初资产净值
            ,0 AS AST_TOT_VAL -- 资产总值
            ,0 AS LST_DAY_AST_TOT_VAL -- 上一日资产总值
            ,0 AS MTB_AST_TOT_VAL -- 月初资产总值
            ,0 AS BOQ_AST_TOT_VAL -- 季初资产总值
            ,T1.AST_TOTAL AS BEGINYEAR_AST_TOT_VAL -- 年初资产总值
            ,0 AS LIAB_TOT_VAL -- 负债总值
            ,0 AS LST_DAY_LIAB_TOT_VAL -- 上一日负债总值
            ,0 AS MTB_LIAB_TOT_VAL -- 月初负债总值
            ,0 AS BOQ_LIAB_TOT_VAL -- 季初负债总值
            ,T1.LIAB_TOTAL AS BEGINYEAR_LIAB_TOT_VAL -- 年初负债总值
            ,0 AS UNIT_NAV -- 单位净值
            ,0 AS LST_DAY_UNIT_NAV -- 上一日单位净值
            ,0 AS MTB_UNIT_NAV -- 月初单位净值
            ,0 AS BOQ_UNIT_NAV -- 季初单位净值
            ,T1.AST_UNIT_NAV AS BEGINYEAR_UNIT_NAV -- 年初单位净值
            ,0 AS TOTAL_UNIT_NAV -- 累计单位净值
            ,0 AS LST_DAY_TOTAL_UNIT_NAV -- 上一日累计单位净值
            ,0 AS MTB_TOTAL_UNIT_NAV -- 月初累计单位净值
            ,0 AS BOQ_TOTAL_UNIT_NAV -- 季初累计单位净值
            ,T1.TOTAL_UNIT_NAV AS BEGINYEAR_TOTAL_UNIT_NAV -- 年初累计单位净值
            ,0 AS UNIT_BONUS -- 单位分红
            ,0 AS LST_DAY_UNIT_BONUS --上一日单位分红
            ,0 AS MTH_TOTAL_UNIT_BONUS -- 月累计单位分红
            ,0 AS BOQ_TOTAL_UNIT_BONUS -- 季累计单位分红
            ,T1.TOTAL_CAOU_AMT AS YEAR_TOTAL_UNIT_BONUS -- 年累计单位分红
            ,0 AS TDY_CPTL_NETIN -- 当日资金净流入
            ,0 AS TDY_CPTL_IN -- 当日资金流入
            ,0 AS TDY_CPTL_OUT -- 当日资金流出
            ,0 AS TMTH_CPTL_NETIN -- 当月资金净流入
            ,0 AS TMTH_CPTL_IN -- 当月资金流入
            ,0 AS TMTH_CPTL_OUT -- 当月资金流出
            ,0 AS TQ_CPTL_NETIN -- 当季资金净流入
            ,0 AS TQ_CPTL_IN -- 当季资金流入
            ,0 AS TQ_CPTL_OUT -- 当季资金流出
            ,0 AS SOTHISYEAR_CPTL_NETIN -- 今年以来资金净流入
            ,0 AS SOTHISYEAR_CPTL_IN -- 今年以来资金流入
            ,0 AS SOTHISYEAR_CPTL_OUT -- 今年以来资金流出
        FROM DWSXDAY.DWS_PROD_AST_INFO_PTD T1 -- 产品资产信息
        WHERE T1.P_DT = CONCAT(SUBSTR('${P_BATCH_DT}',1,4),'0101') 
        ) T5
    GROUP BY T5.SFAC_NO,T5.SFAC_NUM,T5.PROD_CODE,T5.CLAS_PROD_CODE,T5.BIZ_DATE
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done