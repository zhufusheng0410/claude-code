#!/bin/sh
#初始化环境变量：
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
    -- ** 描述: 余额信息(月)
    -- ** 创建者 : hejl
    -- ** 创建日期: 20230523
    -- ** 修改日志:
    -- ** 20230511，hejl，新建
    -- ** 目标表：DWDXDAY.DWD_AST_BAL_INFO_PTD_TMP         余额信息(月)表
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERSJC_PTD    余额信息表
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T3       证券信息
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD      基金信息表
    -- **         DWDXDAY.DWD_AST_BAL_INFO_PTM              月度结存表
    -- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP        标准字典码值映射
    -- **         DWDXDAY.DWD_AST_BAL_INFO_PTD            余额信息(月)临时表
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_BAL_INFO_PTD_TMP
    SELECT A1.SFAC_NO                                                             AS SFAC_NO                                --账套编号
       , A1.SFAC_NUM                                                              AS SFAC_NUM                               --账套编码
       , A1.PROD_CODE                                                             AS PROD_CODE                              --产品代码
       , A1.ACCUT_YEAR                                                            AS ACCUT_YEAR                             --会计年份
       , A1.ACCUT_MTH                                                             AS ACCUT_MTH                              --会计月份
       , A1.CRSE_CODE                                                             AS CRSE_CODE                              --科目代码
       , A1.CRSE_NAME                                                             AS CRSE_NAME                              --科目名称
       , A1.CRRC_CODE                                                             AS CRRC_CODE                              --币种代码
       , A1.DEBC_ORNT                                                             AS DEBC_ORNT                              --借贷方向
       , A1.BEGIN_QTY                                                             AS BEGIN_QTY                              --期初数量
       , A1.TCUPD_DBT_QTY                                                         AS TCUPD_DBT_QTY                          --本期借方数量
       , A1.TCUPD_LDR_QTY                                                         AS TCUPD_LDR_QTY                          --本期贷方数量
       , A1.END_QTY                                                               AS END_QTY                                --期末数量
       , A1.LC_BEGIN_BAL                                                          AS LC_BEGIN_BAL                           --本币期初余额
       , A1.TCUPD_LC_DBT_OCCUR                                                    AS TCUPD_LC_DBT_OCCUR                     --本期本币借方发生额
       , A1.TCUPD_LC_LDR_OCCUR                                                    AS TCUPD_LC_LDR_OCCUR                     --本期本币贷方发生额
       , A1.LC_END_BAL                                                            AS LC_END_BAL                             --本币期末余额
       , A1.ORI_CRRC_BEGIN_BAL                                                    AS ORI_CRRC_BEGIN_BAL                     --原币期初余额
       , A1.TCUPD_ORI_CRRC_DBT_OCCUR                                              AS TCUPD_ORI_CRRC_DBT_OCCUR               --本期原币借方发生额
       , A1.TCUPD_ORI_CRRC_LDR_OCCUR                                              AS TCUPD_ORI_CRRC_LDR_OCCUR               --本期原币贷方发生额
       , A1.ORI_CRRC_END_BAL                                                      AS ORI_CRRC_END_BAL                       --原币期末余额
       , A1.SYMBOL                                                                AS SYMBOL                                 --证券代码
       , A1.SCR_INCD                                                              AS SCR_INCD                               --证券内码
       , A1.INV_CATG                                                              AS INV_CATG                               --投资分类
       , A1.CRSE_PROP                                                             AS CRSE_PROP                              --科目属性
       , 'HSFA'                                                                   AS SSYS                                   --源系统
       , ''                                               AS SOURCE_TAB                             --源表
       , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME                                --加载时间
       , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME                            --修改时间
         FROM --按月获取，暂定每月10号跑批，统计上月月结信息
         (SELECT T1.L_FUNDID AS SFAC_NO --账套编号
             , T6.SFAC_NUM AS SFAC_NUM --账套编码
             , T8.VC_CODE AS PROD_CODE --产品代码
             , T1.VC_CODE AS CRSE_CODE --科目代码
             , T1.VC_FULLNAME AS CRSE_NAME --科目名称
             , T4.STD_DICT_CLS_CD_VAL AS INV_CATG --投资分类
             , T1.L_YEAR AS ACCUT_YEAR --会计年份
             , T1.L_MONTH AS ACCUT_MTH--会计月份
             , T7.LC_END_BAL AS LC_BEGIN_BAL --本币期初余额 如果没有数据赋值0
             , T1.LC_END_BAL AS LC_END_BAL --本币期末余额
             , T7.ORI_CRRC_END_BAL AS ORI_CRRC_BEGIN_BAL --原币期初余额 如果没有数据赋值0
             , T1.ORI_CRRC_END_BAL --原币期末余额
             , T7.END_QTY AS BEGIN_QTY --期初数量 如果没有数据赋值0
             , T1.END_QTY AS END_QTY --期末数量
             , T1.TCUPD_LC_DBT_OCCUR AS TCUPD_LC_DBT_OCCUR --本期本币借方发生额
             , T1.TCUPD_LC_LDR_OCCUR AS TCUPD_LC_LDR_OCCUR --本期本币贷方发生额
             , T1.TCUPD_ORI_CRRC_DBT_OCCUR AS TCUPD_ORI_CRRC_DBT_OCCUR--本期原币借方发生额
             , T1.TCUPD_ORI_CRRC_LDR_OCCUR AS TCUPD_ORI_CRRC_LDR_OCCUR--本期原币贷方发生额
             , T1.TCUPD_DBT_QTY AS TCUPD_DBT_QTY --本期借方数量
             , T1.TCUPD_LDR_QTY AS TCUPD_LDR_QTY --本期贷方数量
             , T5.STD_DICT_CLS_CD_VAL AS CRRC_CODE --币种代码
             , T1.L_ZQNM AS SCR_INCD --证券内码
             , T3.VC_ZQDM AS SYMBOL --证券代码
             , T1.L_KIND AS DEBC_ORNT --借贷方向
             , T1.VC_CODE_HS AS CRSE_PROP --科目属性
               FROM
               (SELECT B1.L_FUNDID --账套编号
                  , B1.VC_CODE  --科目代码
                  , MAX(B1.VC_FULLNAME) AS VC_FULLNAME --科目名称
                  , B1.VC_CODE_HS AS VC_CODE_HS --科目属性
                  , B1.L_TZLX AS L_TZLX --投资分类
                  , B1.L_YEAR AS L_YEAR --会计年份
                  , B1.L_MONTH AS L_MONTH --会计月份
                  , SUM((NVL(B1.EN_DEBIT,0)-NVL(EN_CREDIT,0))*NVL(B2.L_KIND,0)) AS LC_END_BAL --本币期末余额
                  , SUM(NVL(B1.L_KIND,0)*NVL(B1.EN_FOREIGN,0)*NVL(B2.L_KIND,0)) AS ORI_CRRC_END_BAL --原币期末余额
                  , SUM(NVL(B1.L_KIND,0)*NVL(B1.EN_QUANTITY,0)) AS END_QTY --期末数量
                  , SUM(NVL(B1.EN_DEBIT,0)) AS TCUPD_LC_DBT_OCCUR --本期本币借方发生额
                  , SUM(NVL(B1.EN_CREDIT,0)) AS TCUPD_LC_LDR_OCCUR --本期本币贷方发生额
                  , SUM(CASE WHEN B1.L_KIND = '1' 
                             THEN B1.EN_FOREIGN 
                             ELSE '0' END ) AS TCUPD_ORI_CRRC_DBT_OCCUR --本期原币借方发生额
                  , SUM(CASE WHEN B1.L_KIND = '-1' 
                             THEN B1.EN_FOREIGN 
                             ELSE '0' END ) AS TCUPD_ORI_CRRC_LDR_OCCUR --本期原币贷方发生额
                  , SUM(CASE WHEN B1.L_KIND = '1' 
                             THEN B1.EN_QUANTITY 
                             ELSE '0' END ) AS TCUPD_DBT_QTY --本期借方数量
                  , SUM(CASE WHEN B1.L_KIND = '-1' 
                             THEN B1.EN_QUANTITY 
                             ELSE '0' END ) AS TCUPD_LDR_QTY --本期贷方数量
                  , MAX(B1.VC_JSBZ) AS VC_JSBZ --币种代码
                  , MAX(B1.L_ZQNM) AS L_ZQNM --证券内码
                  , B1.L_KIND AS L_KIND --借贷方向
                    FROM ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERSJC_PTD B1     ---每个月10号跑数据
                    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD B2  --科目属性表
                      ON B1.L_FUNDID=B2.L_FUNDID  
                     AND B1.VC_CODE=B2.VC_CODE 
                     AND B2.P_DT = '${P_BATCH_DT}'
                    INNER JOIN ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD B3   -- 帐套信息表
                       ON B1.L_FUNDID=B3.L_ID 
                      AND B3.L_VOID='0' 
                      AND B3.P_DT = '${P_BATCH_DT}'
                   WHERE B1.P_DT=SUBSTR(DATE_FORMAT(ADD_MONTHS(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),-1),'yyyyMMdd'),1,6)||'16'
                    GROUP BY B1.L_FUNDID,B1.VC_CODE,B1.VC_CODE_HS,B1.L_TZLX,B1.L_YEAR,B1.L_MONTH,B1.L_KIND) T1  --分组
               LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD T3  -- 证券信息
                 ON T1.L_ZQNM=T3.L_ZQNM 
                AND T3.P_DT = '${P_BATCH_DT}'
               LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4   --标准字典码值映射
                 ON T1.L_TZLX = T4.SRC_DICT_CLS_CDVAL  
                AND T4.SSYS= 'HSFTA' 
                AND T4.SRC_DICT_CLS_CD= 'L_TZLX' 
                AND T4.VALID_FLAG='1'
               LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T5   --标准字典码值映射
                 ON T1.VC_JSBZ = T5.SRC_DICT_CLS_CDVAL  
                AND T5.SSYS= 'HSFTA' 
                AND T5.SRC_DICT_CLS_CD= 'VC_JSBZ' 
                AND T5.VALID_FLAG='1' 
               LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T6   --标准字典码值映射
                 ON T1.L_FUNDID=T6.SFAC_INCD 
                AND T6.P_DT = '${P_BATCH_DT}'
               LEFT JOIN DWDXDAY.DWD_AST_BAL_INFO_PTD T7  -- 月度结存
                 ON T1.L_FUNDID=T7.SFAC_NO 
                AND T1.VC_CODE=T7.CRSE_CODE 
                AND T7.P_DT = DATE_FORMAT(ADD_MONTHS(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),-2),'yyyyMMdd')
               LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD T8 --基金信息表
                 ON T8.L_FUNDID=T1.L_FUNDID 
                AND T8.P_DT = '${P_BATCH_DT}' ) A1 ;
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_BAL_INFO_PTD PARTITION (P_DT = '${P_BATCH_DT}' )
    SELECT A1.SFAC_NO                 AS SFAC_NO                                --账套编号
       , A1.SFAC_NUM                  AS SFAC_NUM                               --账套编码
       , A1.PROD_CODE                 AS PROD_CODE                              --产品代码
       , A1.ACCUT_YEAR                AS ACCUT_YEAR                             --会计年份
       , A1.ACCUT_MTH                 AS ACCUT_MTH                              --会计月份
       , A1.CRSE_CODE                 AS CRSE_CODE                              --科目代码
       , A1.CRSE_NAME                 AS CRSE_NAME                              --科目名称
       , A1.CRRC_CODE                 AS CRRC_CODE                              --币种代码
       , A1.DEBC_ORNT                 AS DEBC_ORNT                              --借贷方向
       , A1.BEGIN_QTY                 AS BEGIN_QTY                              --期初数量
       , A1.TCUPD_DBT_QTY             AS TCUPD_DBT_QTY                          --本期借方数量
       , A1.TCUPD_LDR_QTY             AS TCUPD_LDR_QTY                          --本期贷方数量
       , A1.END_QTY                   AS END_QTY                                --期末数量
       , A1.LC_BEGIN_BAL              AS LC_BEGIN_BAL                           --本币期初余额
       , A1.TCUPD_LC_DBT_OCCUR        AS TCUPD_LC_DBT_OCCUR                     --本期本币借方发生额
       , A1.TCUPD_LC_LDR_OCCUR        AS TCUPD_LC_LDR_OCCUR                     --本期本币贷方发生额
       , A1.LC_END_BAL                AS LC_END_BAL                             --本币期末余额
       , A1.ORI_CRRC_BEGIN_BAL        AS ORI_CRRC_BEGIN_BAL                     --原币期初余额
       , A1.TCUPD_ORI_CRRC_DBT_OCCUR  AS TCUPD_ORI_CRRC_DBT_OCCUR               --本期原币借方发生额
       , A1.TCUPD_ORI_CRRC_LDR_OCCUR  AS TCUPD_ORI_CRRC_LDR_OCCUR               --本期原币贷方发生额
       , A1.ORI_CRRC_END_BAL          AS ORI_CRRC_END_BAL                       --原币期末余额
       , A1.SYMBOL                    AS SYMBOL                                 --证券代码
       , A1.SCR_INCD                  AS SCR_INCD                               --证券内码
       , A1.INV_CATG                  AS INV_CATG                               --投资分类
       , A1.CRSE_PROP                 AS CRSE_PROP                              --科目属性
       , A1.SSYS                      AS SSYS                                   --源系统
       , A1.SOURCE_TAB                AS SOURCE_TAB                             --源表
       , A1.LD_TIME                   AS LD_TIME                                --加载时间
       , A1.MODIFY_TIME               AS MODIFY_TIME                            --修改时间
         FROM DWDXDAY.DWD_AST_BAL_INFO_PTD_TMP  A1;   --余额信息(月)临时表
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
