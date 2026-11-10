#!/bin/sh
#初始化环境变量：
begin_date="${p_start_dt}"
end_date="${p_end_dt}"
P_BATCH_DT=$begin_date
echo  $P_BATCH_DT
while [ $P_BATCH_DT -lt $end_date ]; 
do
    #!/bin/sh
    #初始化环境变量：
    source /home/dolphinscheduler/hadoop_env
    inceptor_beeline()
    {
        beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
    }
    
    inceptor_beeline "
    set hive.strict.checks.type.safety=false;
    -- **************************************************************************
    -- ** 主题: 资产
    -- ** 描述: 产品证券损益明细
    -- ** 创建者 : vhhv
    -- ** 创建日期: 20230621
    -- ** 目标表：DWSXDAY.DWS_PROD_SCR_PL_DETAIL_PTD             产品证券损益明细
    -- ** 源表：  DWDXDAY.DWD_AST_VOU_INFO_PTD       凭证信息
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
    
    INSERT OVERWRITE TABLE DWSXDAY.DWS_PROD_SCR_PL_DETAIL_PTD PARTITION ( P_DT= '${P_BATCH_DT}')
    SELECT
         T2.BIZ_DATE                  -- '业务日期',
        ,T2.SFAC_NO                  -- '账套编号',
        ,T2.SFAC_NUM                 -- '账套编码',
        ,T2.PROD_CODE                -- '产品代码',
        ,T3.CNAME AS PROD_NAME                -- '产品名称',
        ,T2.SCR_NUM                  -- '证券编码',
        ,T2.SCR_INCD                 -- '证券内码',
        ,T2.SYMBOL                   -- '证券代码',
        ,CASE WHEN T2.SCR_TYPE='22' THEN T2.SCR_NAME ELSE T4.SCR_SNAME END AS SCR_NAME                -- '证券名称',
        ,T2.SCR_TYPE                 -- '证券类型',
        ,T5.STD_DICT_CLS_CDVAL_DESC AS SCR_TYPE_NAME                 -- '证券类型名称',
        ,T2.SCR_DETAIL_TYPE                 -- '证券明细类型',
        ,CASE WHEN T2.SCR_TYPE='06' AND T2.TRAN_MKT IN('09','10') THEN '港股' ELSE T6.STD_DICT_CLS_CDVAL_DESC END AS SCR_DETAIL_TYPE_NAME      -- '证券明细类型名称',
        ,T2.TRAN_MKT                 -- '交易市场',
        ,T7.STD_DICT_CLS_CDVAL_DESC AS TRAN_MKT_NAME                 -- '交易市场名称',
        ,T2.INV_CATG                 -- '投资分类',
        ,T8.STD_DICT_CLS_CDVAL_DESC AS INV_CATG_NAME                 -- '投资分类名称',
        ,T2.CIR_STAT                 -- '流通状态',
        ,T9.STD_DICT_CLS_CDVAL_DESC AS CIR_STAT_NAME                 -- '流通状态名称',
        ,T2.TRAN_PROP                 -- '交易属性',
        ,T10.STD_DICT_CLS_CDVAL_DESC AS TRAN_PROP_NAME                 -- '交易属性名称',
        ,T2.CRRC_CODE                 -- '币种代码',
        ,T2.FAIRVAL_CHG_OC                       -- '公允价值变动损益(原币）',
        ,T2.FAIRVAL_CHG_BC                       -- '公允价值变动损益(本位币）',
        ,T2.INTR_INCM_OC                       -- '利息收入(原币）',
        ,T2.INTR_INCM_BC                       -- '利息收入(本位币）',
        ,T2.INTR_OUT_OC                       -- '利息支出(原币）',
        ,T2.INTR_OUT_BC                       -- '利息支出(本位币）',
        ,T2.PREM_OC                      -- '溢折价(原币）',
        ,T2.PREM_BC                      -- '溢折价(本位币）',
        ,T2.DIVD_INCM_OC                       -- '红利收入(原币）',
        ,T2.DIVD_INCM_BC                       -- '红利收入(本位币）',
        ,T2.PRIC_DIFF_INCM_OC                       -- '差价收入(原币）',
        ,T2.PRIC_DIFF_INCM_BC                       -- '差价收入(本位币）',
        ,T2.OTHER_INCM_OC                       -- '其它收入(原币）',
        ,T2.OTHER_INCM_BC                       -- '其它收入(本位币）',
        ,T2.IMPR_PRE_OC                       -- '减值准备(原币）',
        ,T2.IMPR_PRE_BC                       -- '减值准备(本位币）',
        ,T2.TRAN_FEE_OC                       -- '交易费用(原币）',
        ,T2.TRAN_FEE_BC                       -- '交易费用(本位币）',
        ,T2.OTHER_FEE_OC                       -- '其它费用(原币）',
        ,T2.OTHER_FEE_BC                       -- '其它费用(本位币）',
        ,T2.INTR_INCM_VAT_OC                       -- '利息收入增值税(原币）',
        ,T2.INTR_INCM_VAT_BC                       -- '利息收入增值税(本位币）',
        ,T2.PRIC_DIFF_INCM_VAT_OC                  -- '差价收入增值税(原币）',
        ,T2.PRIC_DIFF_INCM_VAT_BC                 -- '差价收入增值税(本位币）',
        ,T2.SSYS                                 -- '源系统',
        ,T2.SOURCE_TAB                           -- '源表',
        ,T2.LD_TIME                              -- '加载时间',
        ,T2.MODIFY_TIME                          -- '修改时间'
    FROM
        (
        SELECT
            T2.BIZ_DATE -- 业务日期
            ,T2.SFAC_NO  --账套编号
            ,T2.SFAC_NUM  --账套编码
            ,T2.PROD_CODE  --产品代码
            ,T2.SCR_NUM  --证券编码
            ,T2.SCR_INCD AS SCR_INCD  --证券内码
            ,MAX(T2.SYMBOL) AS SYMBOL  --证券代码
            ,MAX(T2.SCR_NAME) AS SCR_NAME  --证券名称
            ,MAX(T2.SCR_TYPE) AS SCR_TYPE  --证券类型
            ,MAX(T2.SCR_DETAIL_TYPE) AS SCR_DETAIL_TYPE  --证券明细类型
            ,T2.TRAN_MKT  --交易市场
            ,T2.INV_CATG  --投资分类
            ,T2.CIR_STAT  --流通状态
            ,T2.TRAN_PROP  --交易属性
            ,T2.CRRC_CODE  --币种代码
            ,SUM(T2.FAIRVAL_CHG_OC) AS FAIRVAL_CHG_OC  --公允价值变动损益(原币）
            ,SUM(T2.FAIRVAL_CHG_BC) AS FAIRVAL_CHG_BC   --公允价值变动损益(本位币）
            ,SUM(T2.INTR_INCM_OC) AS INTR_INCM_OC  --利息收入(原币）
            ,SUM(T2.INTR_INCM_BC) AS INTR_INCM_BC  --利息收入(本位币）
            ,SUM(T2.INTR_OUT_OC) AS INTR_OUT_OC  --利息支出(原币）
            ,SUM(T2.INTR_OUT_BC) AS INTR_OUT_BC  --利息支出(本位币）
            ,SUM(T2.PREM_OC) AS PREM_OC  --溢折价(原币）
            ,SUM(T2.PREM_BC) AS PREM_BC --溢折价(本位币）
            ,SUM(T2.DIVD_INCM_OC) AS DIVD_INCM_OC  --红利收入(原币）
            ,SUM(T2.DIVD_INCM_BC) AS DIVD_INCM_BC --红利收入(本位币）
            ,SUM(T2.PRIC_DIFF_INCM_OC) AS PRIC_DIFF_INCM_OC  --差价收入(原币）
            ,SUM(T2.PRIC_DIFF_INCM_BC) AS PRIC_DIFF_INCM_BC  --差价收入(本位币）
            ,SUM(T2.OTHER_INCM_OC)  AS OTHER_INCM_OC --其它收入(原币）
            ,SUM(T2.OTHER_INCM_BC) AS OTHER_INCM_BC  --其它收入(本位币）
            ,SUM(T2.IMPR_PRE_OC) AS IMPR_PRE_OC  --减值准备(原币）
            ,SUM(T2.IMPR_PRE_BC) AS IMPR_PRE_BC  --减值准备(本位币）
            ,SUM(T2.TRAN_FEE_OC) AS TRAN_FEE_OC  --交易费用(原币）
            ,SUM(T2.TRAN_FEE_BC) AS TRAN_FEE_BC  --交易费用(本位币）
            ,SUM(T2.OTHER_FEE_OC) AS OTHER_FEE_OC  --其它费用(原币）
            ,SUM(T2.OTHER_FEE_BC) AS OTHER_FEE_BC  --其它费用(本位币）
            ,SUM(T2.INTR_INCM_VAT_OC) AS INTR_INCM_VAT_OC  --利息收入增值税(原币）
            ,SUM(T2.INTR_INCM_VAT_BC) AS INTR_INCM_VAT_BC  --利息收入增值税(本位币）
            ,SUM(T2.PRIC_DIFF_INCM_VAT_OC) AS PRIC_DIFF_INCM_VAT_OC  --差价收入增值税(原币）
            ,SUM(T2.PRIC_DIFF_INCM_VAT_BC) AS PRIC_DIFF_INCM_VAT_BC --差价收入增值税(本位币）
            ,'HSFA' AS SSYS -- 源系统
            ,'DWD_AST_VOU_INFO_PTD' AS SOURCE_TAB -- 源表
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
        FROM
            (
            SELECT
                T1.BUSIN_DATE AS BIZ_DATE -- 业务日期
                ,T1.VOU_NO  --凭证号
                ,T1.SFAC_NO AS SFAC_NO -- 账套编号
                ,T1.SFAC_NUM AS SFAC_NUM -- 账套编码
                ,T1.PROD_CODE AS PROD_CODE -- 产品代码
                ,T1.SCR_NUM AS SCR_NUM -- 证券编码
                ,T1.SCR_INCD AS SCR_INCD -- 证券内码
                ,MAX(T1.SYMBOL) AS SYMBOL -- 证券代码
                ,MAX(CASE WHEN T1.SCR_TYPE='22' THEN T1.DPSI_BANK ELSE ' ' END) AS SCR_NAME -- 证券名称
                ,MAX(T1.SCR_TYPE) AS SCR_TYPE -- 证券类型
                ,MAX(T1.SCR_DETAIL_TYPE) AS SCR_DETAIL_TYPE -- 证券明细类型
                ,MAX(T1.TRAN_MKT) AS TRAN_MKT -- 交易市场
                ,MAX(T1.INV_CATG) AS INV_CATG -- 投资分类
                ,'' AS CIR_STAT -- 流通状态
                ,'' AS TRAN_PROP -- 交易属性
                ,MAX(T1.CRRC_CODE) AS CRRC_CODE -- 币种代码
                -- 凭证表、估值表 科目方向（1-借方；-1-贷方）
                --科目属性表中 借贷方向(第一位借方,第二位贷方,1表示需要选择证券) 00 01 10 11
                ,SUM(CASE WHEN T1.CRSE_CODE LIKE '6101%' OR T1.CRSE_CODE LIKE '4%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_LDR_AMT ELSE (-1)*T1.LC_DBT_AMT END
                     ELSE 0 END
                     ) AS FAIRVAL_CHG_OC -- 公允价值变动损益(本位币）
                ,SUM(CASE WHEN T1.CRSE_CODE LIKE '6101%' OR T1.CRSE_CODE LIKE '4%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS FAIRVAL_CHG_BC -- 公允价值变动损益(原币）
                ,SUM(CASE WHEN (T1.CRSE_CODE LIKE '6011%' OR (T1.CRSE_CODE LIKE '6111%' AND T1.CRSE_PROP_NAME LIKE '%利息收入%')) 
                                AND T1.VOU_TYPE NOT IN('9090','9091') THEN 
                                CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_LDR_AMT ELSE (-1)*T1.LC_DBT_AMT END
                     ELSE 0 END
                     ) AS INTR_INCM_OC -- 利息收入(本位币）
                ,SUM(CASE WHEN (T1.CRSE_CODE LIKE '6011%' OR (T1.CRSE_CODE LIKE '6111%' AND T1.CRSE_PROP_NAME LIKE '%利息收入%'))
                                AND T1.VOU_TYPE NOT IN('9090','9091') THEN
                                CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS INTR_INCM_BC -- 利息收入(原币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '利息支出%' THEN
                          CASE WHEN T1.DEBC_ORNT=1 THEN T1.LC_DBT_AMT ELSE (-1)*T1.LC_LDR_AMT END
                     ELSE 0 END
                     ) AS INTR_OUT_OC -- 利息支出(本位币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '利息支出%' THEN
                          CASE WHEN T1.DEBC_ORNT=1 THEN T1.ORI_CRRC_DBT_AMT ELSE (-1)*T1.ORI_CRRC_LDR_AMT END 
                     ELSE 0 END
                     ) AS INTR_OUT_BC -- 利息支出(原币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%利息调整%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_DBT_AMT ELSE (-1)*T1.LC_LDR_AMT END 
                     ELSE 0 END
                     ) AS PREM_OC -- 溢折价(本位币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%利息调整%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS PREM_BC -- 溢折价(原币）
                ,SUM(CASE WHEN T1.CRSE_CODE LIKE '6111%' AND T1.CRSE_PROP_NAME LIKE '红利收入%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_LDR_AMT ELSE (-1)*T1.LC_DBT_AMT END
                     ELSE 0 END
                     ) AS DIVD_INCM_OC -- 红利收入(本位币）
                ,SUM(CASE WHEN T1.CRSE_CODE LIKE '6111%' AND  T1.CRSE_PROP_NAME LIKE '红利收入%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS DIVD_INCM_BC -- 红利收入(原币）
                ,SUM(CASE WHEN  T1.CRSE_CODE LIKE '6111%' AND T1.CRSE_PROP_NAME NOT LIKE '红利收入%' AND T1.CRSE_PROP_NAME NOT LIKE '%利息收入%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_LDR_AMT ELSE (-1)*T1.LC_DBT_AMT END
                     ELSE 0 END
                     ) AS PRIC_DIFF_INCM_OC -- 差价收入(本位币）
                ,SUM(CASE WHEN T1.CRSE_CODE LIKE '6111%' AND  T1.CRSE_PROP_NAME NOT LIKE '红利收入%' AND T1.CRSE_PROP_NAME NOT LIKE '%利息收入%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS PRIC_DIFF_INCM_BC -- 差价收入(原币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '其他收入%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_LDR_AMT ELSE (-1)*T1.LC_DBT_AMT END
                     ELSE 0 END
                     ) AS OTHER_INCM_OC -- 其它收入(本位币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '其他收入%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS OTHER_INCM_BC -- 其它收入(原币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%减值损失%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_LDR_AMT ELSE (-1)*T1.LC_DBT_AMT END
                     ELSE 0 END
                     ) AS IMPR_PRE_OC -- 减值准备(本位币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%减值损失%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS IMPR_PRE_BC -- 减值准备(原币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '交易费用%' THEN
                          CASE WHEN T1.DEBC_ORNT=1 THEN T1.LC_DBT_AMT ELSE (-1)*T1.LC_LDR_AMT END
                     ELSE 0 END
                     ) AS TRAN_FEE_OC -- 交易费用(本位币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '交易费用%' THEN
                          CASE WHEN T1.DEBC_ORNT=1 THEN T1.ORI_CRRC_DBT_AMT ELSE (-1)*T1.ORI_CRRC_LDR_AMT END
                     ELSE 0 END
                     ) AS TRAN_FEE_BC -- 交易费用(原币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '其他费用%' THEN
                          CASE WHEN T1.DEBC_ORNT=1 THEN T1.LC_DBT_AMT ELSE (-1)*T1.LC_LDR_AMT END
                     ELSE 0 END
                     ) AS OTHER_FEE_OC -- 其它费用(本位币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '其他费用%' THEN
                          CASE WHEN T1.DEBC_ORNT=1 THEN T1.ORI_CRRC_DBT_AMT ELSE (-1)*T1.ORI_CRRC_LDR_AMT END
                     ELSE 0 END
                     ) AS OTHER_FEE_BC -- 其它费用(原币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%增值税贷款服务%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_LDR_AMT ELSE (-1)*T1.LC_DBT_AMT END
                     ELSE 0 END
                     ) AS INTR_INCM_VAT_OC -- 利息收入增值税(本位币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%增值税贷款服务%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS INTR_INCM_VAT_BC -- 利息收入增值税(原币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%价差收入增值税%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.LC_LDR_AMT ELSE (-1)*T1.LC_DBT_AMT END
                     ELSE 0 END
                     ) AS PRIC_DIFF_INCM_VAT_OC -- 差价收入增值税(本位币）
                ,SUM(CASE WHEN T1.CRSE_PROP_NAME LIKE '%价差收入增值税%' THEN
                          CASE WHEN T1.DEBC_ORNT=-1 THEN T1.ORI_CRRC_LDR_AMT ELSE (-1)*T1.ORI_CRRC_DBT_AMT END
                     ELSE 0 END
                     ) AS PRIC_DIFF_INCM_VAT_BC -- 差价收入增值税(原币）
            FROM DWDXDAY.DWD_AST_VOU_INFO_PTD T1 -- 凭证信息
            WHERE T1.P_DT = '${P_BATCH_DT}' AND (T1.CRSE_CODE LIKE '6%' OR (T1.CRSE_CODE LIKE '4%' AND T1.CRSE_PROP_NAME LIKE '资本公积%')) AND T1.VOU_TYPE IN ('0','-1','300','306','309','333','334','338','341','401','403','408','9049','9090','9091')
            GROUP BY T1.BUSIN_DATE,T1.VOU_NO,T1.SFAC_NO,T1.SFAC_NUM,T1.PROD_CODE,T1.SCR_NUM,T1.SCR_INCD
            ) T2 
        WHERE T2.SCR_INCD IS NOT NULL 
        GROUP BY T2.BIZ_DATE,T2.SFAC_NO,T2.SFAC_NUM,T2.PROD_CODE,T2.SCR_NUM,T2.SCR_INCD,T2.SYMBOL,T2.TRAN_MKT,T2.INV_CATG,T2.CIR_STAT,T2.TRAN_PROP,T2.CRRC_CODE
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
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done