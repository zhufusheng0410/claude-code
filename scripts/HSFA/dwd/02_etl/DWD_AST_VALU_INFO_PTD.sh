#!/bin/sh
#初始化环境变量:
begin_date="${p_start_dt}"
end_date="${p_end_dt}"
P_BATCH_DT=$begin_date
echo  $P_BATCH_DT
while [ $P_BATCH_DT -le $end_date ]; 
do
    source /home/dolphinscheduler/hadoop_env
    inceptor_beeline()
    {
        beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
    }
    
    inceptor_beeline "
    -- **************************************************************************
    -- ** 主题: 资产
    -- ** 描述: 估值信息
    -- ** 目标表：DWDXDAY.DWD_AST_VALU_INFO_PTD            估值信息表
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD     估值表(全)
    -- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD        帐套编码映射
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD      基金信息表
    -- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP        标准字典码值映射
    -- **         DWDXDAY.DWD_AST_VALU_INFO_PTD_TMP         估值信息临时表
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_VALU_INFO_PTD PARTITION ( P_DT= '${P_BATCH_DT}')
    SELECT
       CAST(A1.L_ZTBH AS STRING)                                              AS SFAC_NO                 --账套编号
       ,A10.SFAC_NUM                                                              AS SFAC_NUM                --账套编码
       ,A10.PROD_CODE                                                             AS PROD_CODE               --产品代码
       ,A1.D_YWRQ                                                                 AS VALU_DATE               --估值日期
       ,CAST(A1.VC_KMDM AS STRING)                                                               AS CRSE_CODE               --科目代码
       ,A1.VC_KMMC                                                                AS CRSE_NAME               --科目名称
       ,A1.L_SL                                                                   AS HLDP_QTY                --持仓数量
       ,A1.EN_DWCB                                                                AS UNIT_COST               --单位成本
       ,A1.EN_WBCB                                                                AS ORI_CRRC_COST           --原币成本
       ,A1.EN_WBSZ                                                                AS ORI_CRRC_MVAL           --原币市值
       ,A1.EN_YBGZZZ                                                              AS ORI_CRRC_VAL_APPRE      --原币估增
       ,A1.EN_WBZYJ                                                               AS ORI_CRRC_PD_COST        --原币摊余成本
       ,A1.VC_JSBZ                                                                AS CRRC_CODE               --币种代码
       ,A1.EN_CB                                                                  AS LC_COST                 --本币成本
       ,A1.EN_SZ                                                                  AS LC_MVAL                 --本币市值
       ,A1.EN_GZZZ                                                                AS LC_VAL_APPRE            --本币估增
       ,A1.EN_ZYJ                                                                 AS LC_PD_COST              --本币摊余成本
       ,A1.EN_HQJZ                                                                AS VALU_PRC                --估值价格
       ,A1.EN_CBZJZ                                                               AS LC_COST_PCT_NAV_COMPARE --本币成本占净值比
       ,A1.EN_SZZJZ                                                               AS LC_MVAL_PCT_NAV_COMPARE --本币市值占净值比
       ,A1.EN_EXCH                                                                AS VALU_EXCR               --估值汇率
       ,CAST(A1.L_ZQNM AS STRING)                                                 AS SCR_INCD                --证券内码
       ,A1.VC_ZQDM                                                                AS SYMBOL                  --证券代码
       ,CAST(A1.L_KIND AS STRING)                                                 AS DEBC_ORNT               --借贷方向
       ,NVL(A5.STD_DICT_CLS_CD_VAL,'2')                                           AS INV_CATG                --投资分类
       ,A1.VC_CODE_HS                                                             AS CRSE_PROP               --科目属性
       ,A3.VC_NAME_HS                                                             AS CRSE_PROP_NAME          --科目属性名称
       ,A11.SCR_TYPE                                                              AS SCR_TYPE                --证券类型
       ,A11.SCR_DETAIL_TYPE                                                       AS SCR_DETAIL_TYPE         --证券明细类型
       ,CAST(NVL(A3.L_DKFX,'1') AS STRING)                                        AS MULTI_SPOS_ORNT         --多空方向
       ,CAST(NVL(A3.L_TQBZ,'0') AS STRING)                                        AS TRAN_PROP               --交易属性
       ,A11.TRAN_MKT_CODE                                                         AS TRAN_MKT                --交易市场
       ,CASE WHEN LENGTH(A1.VC_LTLX)=0 THEN '1' ELSE A1.VC_LTLX END               AS CIR_STAT                --流通状态
       ,A1.VC_TPXX                                                                AS SUSP_INFO               --停牌信息
       ,A1.VC_QYXX                                                                AS EQUI_INFO               --权益信息
       ,A1.VC_BZW                                                                 AS INDX_TOTAL_PROJ         --指标合计项
       ,'HSFA'                                                                    AS SSYS                    --源系统
       ,''                                                 AS SOURCE_TAB              --源表
       ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME                 --加载时间
       ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME             --修改时间
       ,'' AS CLAS_PROD_CODE  --分级产品代码
       ,CASE WHEN A12.CNT>1 THEN '1' ELSE '0' END AS IS_CLAS_PROD    --是否分级产品
       ,CAST(A11.SCR_NUM AS STRING) AS SCR_NUM  --证券编码
       ,A1.VC_JYS AS DATA_TP  --数据类型
       ,CAST(A1.L_LEAF AS STRING) AS CRSE_DETAIL_FLAG  --明细科目标志
       ,CAST(A1.L_SFJCZS AS STRING) AS INDX_DETAIL_FLAG  --分级指标标志
    FROM ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD A1 --估值表(全)
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10 --帐套编码映射
    ON CAST(A1.L_ZTBH AS STRING)=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    LEFT JOIN (SELECT L_ZTBH,COUNT(1) AS CNT FROM ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD WHERE P_DT = '${P_BATCH_DT}' GROUP BY L_ZTBH) A12  -- 分级基金设置表
    ON A1.L_ZTBH=A12.L_ZTBH 
    LEFT JOIN 
        (SELECT
            C1.SCR_NUM  --证券编码
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
        )A11  --证券编码映射
    ON CAST(A1.L_ZQNM AS STRING)=A11.SCR_INCD
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5  --标准字典码值映射
    ON CAST(A1.L_TZLX AS STRING) = A5.SRC_DICT_CLS_CDVAL AND A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_TZLX' AND A5.VALID_FLAG='1'
    LEFT JOIN 
        (SELECT B1.L_ID AS L_FUNDID  --账套编号
             ,B2.VC_CODE AS VC_CODE_HS --科目属性
             ,B2.VC_NAME_HS  --科目属性名称
             ,B2.L_DKFX  --多空方向
             ,B2.L_TQBZ --交易属性
        FROM ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD B1  ---- 帐套信息表
        INNER JOIN 
           (SELECT T1.VC_CODE  --科目属性
                ,T1.VC_NAME_HS  --科目属性名称
                ,T2.STD_DICT_CLS_CD_VAL AS L_DKFX  --多空方向
                ,T1.L_ZTBH  --账套模板
                ,SUBSTR(T1.VC_BZW,8,1) AS L_TQBZ  --交易属性
            FROM ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD T1 -- --科目信息表
            LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T2 --标准字典码值映射
            ON CAST(T1.L_DKFX AS STRING) = T2.SRC_DICT_CLS_CDVAL AND T2.SSYS= 'HSFA' AND T2.SRC_DICT_CLS_CD= 'L_DKFX' AND T2.VALID_FLAG='1'
            WHERE T1.P_DT = '${P_BATCH_DT}'
            ) B2
        ON B1.L_TYPE=B2.L_ZTBH AND B1.L_VOID=0 AND B1.P_DT = '${P_BATCH_DT}'
        ) A3 --会计科目属性表
    ON A1.L_ZTBH=A3.L_FUNDID AND A1.VC_CODE_HS=A3.VC_CODE_HS
    WHERE  LENGTH(A1.VC_KMDM)<>0 AND A1.P_DT = '${P_BATCH_DT}'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
