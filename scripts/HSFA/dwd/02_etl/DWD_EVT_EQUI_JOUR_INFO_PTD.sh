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
    -- ** 描述: 权益流水信息
    -- ** 创建者 :VHHV
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_EQUI_JOUR_INFO_PTD    权益流水信息
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TFJYGH_PTD A1   非交易过户表
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD A1   新股表
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_EQUI_JOUR_INFO_PTD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT
        MAX(T0.SFAC_NO)      AS SFAC_NO
        ,T0.SFAC_NUM         AS SFAC_NUM
        ,MAX(T0.TRAN_DATE)        AS TRAN_DATE
        ,T0.PROD_CODE        AS PROD_CODE
        ,T0.SCR_NUM          AS SCR_NUM
        ,MAX(T0.SCR_INCD)         AS SCR_INCD
        ,MAX(T0.SYMBOL)           AS SYMBOL
        ,MAX(T0.SCR_TYPE)         AS SCR_TYPE
        ,MAX(T0.SCR_DETAIL_TYPE)  AS SCR_DETAIL_TYPE
        ,MAX(T0.TRAN_MKT)         AS TRAN_MKT
        ,MAX(T0.SETL_CRRC)        AS SETL_CRRC
        ,MAX(T0.REG_CRRC)         AS REG_CRRC
        ,T0.BUSIN_CATG       AS BUSIN_CATG
        ,MAX(T0.REG_DATE)         AS REG_DATE
        ,MAX(T0.EXRT_DAY)        AS EXRT_DAY
        ,T0.ARVD_DATE        AS ARVD_DATE
        ,MAX(T0.AMT)              AS AMT
        ,MAX(T0.QTY)              AS QTY
        ,MAX(T0.EQUI_RATE)        AS EQUI_RATE
        ,MAX(T0.INV_CATG)         AS INV_CATG
        ,T0.TRAN_ACCT        AS TRAN_ACCT
        ,T0.CPTL_ACCT        AS CPTL_ACCT
        ,MAX(T0.SEAT_TYPE)        AS SEAT_TYPE
        ,MAX(T0.EXCR)             AS EXCR
        ,MAX(T0.DEAL_NO)          AS DEAL_NO
       ,'HSFA' AS SSYS -- 源系统
       ,'ODS_HSFA_TFJYGH_PTD' AS SOURCE_TAB -- 源表
       ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
       ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM 
        (
        SELECT 
            CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
           ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
           ,A1.D_RQ AS TRAN_DATE -- 交易日期
           ,A10.PROD_CODE AS PROD_CODE -- 产品代码
           ,A11.SCR_NUM AS SCR_NUM -- 证券编码
           ,CAST(A1.L_ZQNM AS STRING) AS SCR_INCD -- 证券内码
           ,A1.VC_ZQDM AS SYMBOL -- 证券代码
           ,A11.SCR_TYPE AS SCR_TYPE -- 证券类型
           ,A11.SCR_DETAIL_TYPE AS SCR_DETAIL_TYPE -- 证券明细类型
           ,A11.TRAN_MKT_CODE AS TRAN_MKT -- 交易市场
           ,A1.VC_JSBZ AS SETL_CRRC -- 结算币种
           ,A1.VC_DJBZ AS REG_CRRC -- 登记币种
           ,A5.STD_DICT_CLS_CD_VAL AS BUSIN_CATG -- 业务类别
           ,A1.D_RQ AS REG_DATE -- 登记日
           ,CAST(A1.L_JSRQ AS STRING) AS EXRT_DAY -- 除权日
           ,CAST(A1.L_JSRQ AS STRING) AS ARVD_DATE -- 到账日
           ,A1.EN_JG AS AMT -- 金额
           ,A1.L_GHSL AS QTY -- 数量
           ,A1.EN_QYBL AS EQUI_RATE -- 比例
           ,NVL(A7.STD_DICT_CLS_CD_VAL,'2') AS INV_CATG -- 投资分类
           ,A1.VC_GDDM AS TRAN_ACCT -- 交易账户
           ,A1.VC_ZHDM AS CPTL_ACCT -- 资金账户
           ,A1.C_XWLX AS SEAT_TYPE -- 席位类型
           ,A1.EN_EXCH AS EXCR -- 汇率
           ,CAST(A1.L_BH AS STRING) AS DEAL_NO -- 成交编号
        FROM ODS_XDAY_HSFA.ODS_HSFA_TFJYGH_PTD A1 -- 非交易过户表
        LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
        ON CAST(A1.L_ZTBH AS STRING)=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
        LEFT JOIN 
            (SELECT C1.SCR_NUM  --证券编码
                 ,C1.TRAN_MKT_CODE  --交易市场
                 ,C2.SCR_INCD  --证券内码
                 ,C3.SCR_PRI_CATG_CODE AS SCR_TYPE  --证券类别代码(证券类型)
                 ,C3.SCR_SCD_CATG_CODE AS SCR_DETAIL_TYPE  --分类代码(证券明细类型)
             FROM DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD C1 --证券基本信息
             LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD C2  -- 证券编码映射
             ON C1.SCR_NUM=C2.SCR_NUM AND C2.SSYS= 'HSFA' AND C2.VALID_FLAG=1 AND C2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
             LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD C3  --证券分类信息
             ON C1.SCR_NUM=C3.SCR_NUM AND C3.CATG_CALIBRE_CODE='HSFA_SCR_CATG_CODE' AND C3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
             WHERE C1.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
             ) A11  -- 证券类别信息
        ON CAST(A1.L_ZQNM AS STRING)=A11.SCR_INCD
        LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5
        ON A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_YWLB' AND CAST(A1.L_YWLB AS STRING) = A5.SRC_DICT_CLS_CDVAL AND A5.VALID_FLAG='1'
        LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A7
        ON CAST(A1.L_TZLX AS STRING) = A7.SRC_DICT_CLS_CDVAL AND A7.SSYS= 'HSFA' AND A7.SRC_DICT_CLS_CD= 'L_TZLX' AND A7.VALID_FLAG='1'
        WHERE A1.P_DT = '${P_BATCH_DT}' AND A1.L_YWLB IN (1003,1004,1103,1104,1121,1125,1203,1204,1205,2423,2425,2427,2440,2442,2450,2451,2452,2453,2454,2455,2803,2804,2805,2806,2807,2808,2809,2821,2822,2831,2832,2833,2834,2835,2836,2837,3908,3909) 
        ) T0
        GROUP BY T0.SFAC_NUM,T0.PROD_CODE,T0.SCR_NUM,T0.BUSIN_CATG,T0.ARVD_DATE,T0.TRAN_ACCT,T0.CPTL_ACCT
    UNION ALL
    SELECT 
        CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
        ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,A1.D_RQ AS TRAN_DATE -- 交易日期
        ,A10.PROD_CODE AS PROD_CODE -- 产品代码
        ,A11.SCR_NUM AS SCR_NUM -- 证券编码
        ,CAST(A1.L_ZQNM AS STRING) AS SCR_INCD -- 证券内码
        ,A1.VC_ZQDM AS SYMBOL -- 证券代码
        ,A11.SCR_TYPE AS SCR_TYPE -- 证券类型
        ,A11.SCR_DETAIL_TYPE AS SCR_DETAIL_TYPE -- 证券明细类型
        ,A11.TRAN_MKT_CODE AS TRAN_MKT -- 交易市场
        ,A1.VC_JSBZ AS SETL_CRRC -- 结算币种
        ,A1.VC_JSBZ AS REG_CRRC -- 登记币种
        ,A5.STD_DICT_CLS_CD_VAL AS BUSIN_CATG -- 业务类别
        ,A1.D_RQ AS REG_DATE -- 登记日
        ,A1.D_CJRQ AS EXRT_DAY -- 除权日
        ,A1.D_CJRQ AS ARVD_DATE -- 到账日
        ,A1.EN_CJJE AS AMT -- 金额
        ,CAST('0' AS DECIMAL(19,4)) AS QTY -- 数量
        ,CAST('0' AS DECIMAL(12,6)) AS EQUI_RATE -- 比例
        ,A7.STD_DICT_CLS_CD_VAL AS INV_CATG -- 投资分类
        ,A1.VC_GDDM AS TRAN_ACCT -- 交易账户
        ,A1.VC_ZHDM AS CPTL_ACCT -- 资金账户
        ,A1.C_XWLX AS SEAT_TYPE -- 席位类型
        ,A1.EN_EXCH AS EXCR -- 汇率
        ,CAST(A1.L_ID AS STRING) AS DEAL_NO -- 成交编号
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_TXG_PTD' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD A1 -- 新股表
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
    ON CAST(A1.L_ZTBH AS STRING)=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    LEFT JOIN 
        (SELECT C1.SCR_NUM  --证券编码
            ,C1.TRAN_MKT_CODE  --交易市场
            ,C2.SCR_INCD  --证券内码
            ,C3.SCR_PRI_CATG_CODE AS SCR_TYPE  --证券类别代码(证券类型)
            ,C3.SCR_SCD_CATG_CODE AS SCR_DETAIL_TYPE  --分类代码(证券明细类型)
         FROM DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD C1 --证券基本信息
         LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD C2  -- 证券编码映射
         ON C1.SCR_NUM=C2.SCR_NUM AND C2.SSYS= 'HSFA' AND C2.VALID_FLAG=1 
         AND C2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
         LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD C3  --证券分类信息
         ON C1.SCR_NUM=C3.SCR_NUM AND C3.CATG_CALIBRE_CODE='HSFA_SCR_CATG_CODE' 
         AND C3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
         WHERE C1.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
        ) A11  -- 证券类别信息
    ON CAST(A1.L_ZQNM AS STRING) = A11.SCR_INCD
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5
    ON A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_YWLB' AND CAST(A1.L_YWLB AS STRING) = A5.SRC_DICT_CLS_CDVAL  AND A5.VALID_FLAG='1'
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A7
    ON CAST(A1.L_TZLX AS STRING) = A7.SRC_DICT_CLS_CDVAL AND A7.SSYS= 'HSFA' AND A7.SRC_DICT_CLS_CD= 'L_TZLX' AND A7.VALID_FLAG='1'
    WHERE A1.P_DT = '${P_BATCH_DT}'AND A1.L_YWLB =1124
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
