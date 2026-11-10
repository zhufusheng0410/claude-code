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
    -- ** 描述: 新股新债业务
    -- ** 创建者 :VHHV
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_NEW_SHARES_NEW_DEBT_BUSIN_PTD    新股新债业务
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD A1    新股表
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_NEW_SHARES_NEW_DEBT_BUSIN_PTD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT
        CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
        ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,A1.D_CJRQ AS TRAN_DATE -- 交易日期
        ,A10.PROD_CODE AS PROD_CODE -- 产品代码
        ,A11.SCR_NUM AS SCR_NUM -- 证券编码
        ,CAST(A1.L_ZQNM AS STRING) AS SCR_INCD -- 证券内码
        ,A1.VC_ZQDM AS SYMBOL -- 证券代码
        ,A11.SCR_TYPE AS SCR_TYPE -- 证券类型
        ,A11.SCR_DETAIL_TYPE AS SCR_DETAIL_TYPE -- 证券明细类型
        ,A11.TRAN_MKT_CODE AS TRAN_MKT -- 交易市场
        ,A1.VC_JSBZ AS CRRC -- 币种
        ,A5.STD_DICT_CLS_CD_VAL AS BUSIN_CATG -- 业务类别
        ,A1.VC_YSZQDM AS ORI_SYMBOL -- 原始证券代码
        ,A1.EN_CJSL AS DEAL_QTY -- 成交数量
        ,A1.EN_CJJG AS DEAL_PRC -- 成交价格
        ,A1.EN_CJJE AS DEAL_AMT -- 成交金额
        ,A1.EN_CJFY AS DEAL_FEE -- 成交费用
        ,A1.EN_QSJE AS LIQUI_AMT  --清算金额
        ,A1.EN_LTLX AS CIR_INTR  --流通利息
        ,A1.EN_LTGZ AS CIR_APPRE  --流通估值
        ,A1.VC_XWDM AS TRAN_CHNL -- 交易渠道
        ,NVL(A7.STD_DICT_CLS_CD_VAL,'2') AS INV_CATG -- 投资分类
        ,A1.VC_GDDM AS TRAN_ACCT -- 交易账户
        ,A1.VC_ZHDM AS CPTL_ACCT -- 资金账户
        ,A1.C_XWLX AS SEAT_TYPE -- 席位类型
        ,A1.EN_EXCH AS EXCR -- 汇率
        ,CAST(A1.L_ID AS STRING) AS DEAL_NO -- 成交编号
        ,A1.C_LTSXGPYWMS AS RESTR_CIR_CATG -- 受限流通类别
        ,A1.C_YWMS AS SUE_MODE -- 发行方式
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_TXG_PTD ' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD A1 -- 新股表
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
    ON CAST(A1.L_ZTBH AS STRING)=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
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
        ) A11  -- 证券类别信息
    ON CAST(A1.L_ZQNM AS STRING)=A11.SCR_INCD
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5
    ON A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_YWLB' AND CAST(A1.L_YWLB AS STRING) = A5.SRC_DICT_CLS_CDVAL  AND A5.VALID_FLAG='1'
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A7
    ON A7.SSYS= 'HSFA' AND A7.SRC_DICT_CLS_CD= 'L_TZLX' AND CAST(A1.L_TZLX AS STRING) = A7.SRC_DICT_CLS_CDVAL  AND A7.VALID_FLAG='1'
    WHERE A1.P_DT = '${P_BATCH_DT}' AND A1.L_YWLB IN (1011,1012,1013,1014,1017,1021,1022,1024,1031,1032,1033,1034,1035,1036,1105,1106,1107,1110,1111,1112,1206,1207,2811,2812,2813,2814,2815,2816,2817,2824,3913,3915,3916) 
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
