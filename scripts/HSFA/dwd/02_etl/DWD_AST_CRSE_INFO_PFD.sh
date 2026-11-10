#!/bin/sh
#初始化环境变量：
    source /home/dolphinscheduler/hadoop_env
    inceptor_beeline()
    {
        beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
    }
    
    inceptor_beeline "
    -- **************************************************************************
    -- ** 主题: 资产
    -- ** 描述: 科目信息
    -- ** 目标表：DWDXDAY.DWD_AST_CRSE_INFO_PFD 科目信息
    -- ** 源表：   ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD      会计科目表
    -- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD        帐套编码映射
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD      基金信息表
    -- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP        标准字典码值映射
    -- **         DWDXDAY.DWD_AST_CRSE_INFO_PFD_TMP         科目信息临时表
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_CRSE_INFO_PFD PARTITION (P_DT = '${p_end_dt}')
    SELECT 
        CAST(A1.L_FUNDID AS STRING)                              AS SFAC_NO           --账套编号
        ,A10.SFAC_NUM                                            AS SFAC_NUM          --账套编码
        ,A10.PROD_CODE                                           AS PROD_CODE         --产品代码
        ,A1.VC_CODE                                              AS CRSE_CODE         --科目代码
        ,A1.VC_NAME                                              AS CRSE_NAME         --科目名称
        ,CAST(A1.L_CLASS AS STRING)                              AS CRSE_TYPE         --科目类型
        ,A1.VC_PARENT                                            AS HLVL_CRSE_CODE    --上级科目代码
        ,CAST(A1.L_LEVEL AS STRING)                              AS CRSE_LVL          --科目级别
        ,CAST(A1.L_LEAF AS STRING)                               AS CRSE_DETAIL_FLAG  --科目明细标志
        ,A1.VC_JSBZ                                              AS CRRC_CODE         --币种代码
        ,A5.STD_DICT_CLS_CD_VAL                                  AS TRAN_MKT          --交易市场
        ,CAST(A1.L_KIND AS STRING)                               AS DEBC_ORNT         --借贷方向
        ,CAST(A1.L_QUANTITY AS STRING)                           AS CHK_QTY_ID        --核算数量标识
        ,A1.VC_CODE_HS                                           AS CRSE_PROP         --科目属性
        ,''                                                      AS CASH_ACCT_TYPE    --现金账户类型
        ,CAST(A6.L_TQBZ AS STRING)                               AS TRAN_PROP         --交易属性
        ,A6.VC_NAME_HS                                           AS CRSE_PROP_NAME    --科目属性名称
        ,CAST(A6.L_TZLX AS STRING)                               AS INV_CATG          --投资分类
        ,CAST(A6.L_ZQLB AS STRING)                               AS SCR_TYPE          --证券类型
        ,CAST(A6.L_ZQLBMX1 AS STRING)                            AS SCR_DETAIL_TYPE   --证券明细类型
        ,'HSFA'                                                  AS SSYS              --源系统
        ,'ODS_HSFA_TACCOUNT_PFD、ODS_HSFA_TACCOUNT_HS_PFD '      AS SOURCE_TAB        --源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME           --加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME       --修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD A1  --会计科目表
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10 --帐套编码映射
    ON CAST(A1.L_FUNDID AS STRING)=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5  --标准字典码值映射
    ON CAST(A1.L_SCLB AS STRING) = A5.SRC_DICT_CLS_CDVAL AND A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_SCLB' 
    AND A5.VALID_FLAG='1'
    LEFT JOIN 
        (SELECT B1.L_ID AS L_FUNDID  --账套编号
            ,B2.VC_CODE AS VC_CODE_HS --科目属性
            ,B2.VC_NAME_HS  --科目属性名称
            ,B2.L_TZLX --投资类型
            ,B2.L_ZQLB --证券类别
            ,B2.L_ZQLBMX1 --证券明细类型
            ,B2.L_TQBZ --交易属性
        FROM ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD B1   --帐套信息表
        INNER JOIN 
            (SELECT 
                T1.VC_CODE  --科目属性
                ,T1.VC_NAME_HS  --科目属性名称
                ,NVL(T2.STD_DICT_CLS_CD_VAL,'2') AS L_TZLX  --投资类型
                ,T3.STD_DICT_CLS_CD_VAL AS L_ZQLB  --证券类别
                ,T4.STD_DICT_CLS_CD_VAL AS L_ZQLBMX1 --证券明细类型
                ,T1.L_ZTBH  --账套模板
                ,SUBSTR(T1.VC_BZW,8,1) AS L_TQBZ  --交易属性
            FROM ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD T1   --科目属性
            LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2  --标准字典码值映射
            ON CAST(T1.L_TZLX AS STRING) = T2.SRC_DICT_CLS_CDVAL AND T2.SSYS= 'HSFA' AND T2.SRC_DICT_CLS_CD= 'L_TZLX' 
            AND T2.VALID_FLAG='1'
            LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3  --标准字典码值映射
            ON CAST(T1.L_ZQLB AS STRING) = T3.SRC_DICT_CLS_CDVAL AND T3.SSYS= 'HSFA' AND T3.SRC_DICT_CLS_CD= 'L_ZQLB' 
            AND T3.VALID_FLAG='1'
            LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4  --标准字典码值映射
            ON CAST(T1.L_ZQLBMX1 AS STRING) = T4.SRC_DICT_CLS_CDVAL AND T4.SSYS= 'HSFA' AND T4.SRC_DICT_CLS_CD= 'L_ZQLBMX1' 
            AND T4.VALID_FLAG='1'
            WHERE T1.P_DT = '${p_end_dt}' 
            ) B2
        ON B1.L_TYPE=B2.L_ZTBH AND B1.L_VOID='0' AND B1.P_DT = '${p_end_dt}'
        ) A6 --会计科目属性表
    ON A1.VC_CODE_HS=A6.VC_CODE_HS AND A1.L_FUNDID=A6.L_FUNDID 
    WHERE A1.L_VOID= '0' AND A1.P_DT = '${p_end_dt}'
    ; 
    "
