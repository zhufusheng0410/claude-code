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
    -- ** 描述: 期货交易业务
    -- ** 创建者 :VHHV
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_FUTR_TRAN_BUSIN_PTD    期货交易业务
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD     清算库
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_FUTR_TRAN_BUSIN_PTD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT
        CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
        ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,A1.D_RQ AS TRAN_DATE -- 交易日期
        ,A10.PROD_CODE AS PROD_CODE -- 产品代码
        ,A11.SCR_NUM AS SCR_NUM -- 证券编码
        ,CAST(A1.L_ZQNM AS STRING) AS SCR_INCD -- 证券内码
        ,A1.VC_ZQDM AS FP_CODE -- 期货合约代码
        ,A11.SCR_DETAIL_TYPE AS FP_TYPE -- 期货品种类型
        ,A11.TRAN_MKT_CODE AS TRAN_MKT -- 交易市场
        ,A1.VC_JSBZ AS CRRC -- 币种
        ,A5.STD_DICT_CLS_CD_VAL AS BUSIN_CATG -- 业务类别
        ,A6.STD_DICT_CLS_CD_VAL AS BUSIN_CATG_DETAIL -- 业务类别明细
        ,A1.VC_XWDM AS TRAN_CHNL -- 交易渠道
        ,NVL(A7.STD_DICT_CLS_CD_VAL,'2') AS INV_CATG -- 投资分类
        ,A1.VC_GDDM AS TRAN_ACCT -- 交易账户
        ,A1.VC_ZHDM AS CPTL_ACCT -- 资金账户
        ,A1.EN_MRJE AS BUY_IN_AMT -- 买入金额
        ,A1.EN_MCJE AS SELL_AMT -- 卖出金额
        ,A1.L_MRSL AS BUY_IN_QTY -- 买入数量
        ,A1.L_MCSL AS SELL_QTY -- 卖出数量
        ,A1.EN_MRSXF AS BUY_IN_CHAG -- 买入手续费
        ,A1.EN_MCSXF AS SELL_CHAG -- 卖出手续费
        ,A1.EN_MRQTFY AS BUY_IN_OTH_FEE -- 买入其他费用
        ,A1.EN_MCQTFY AS SELL_OTH_FEE -- 卖出其他费用
        ,A1.EN_MCGYJZBDSY AS TRAN_PL  -- 交易盈亏
        ,A1.D_SJQRRQ AS LIQUI_DATE -- 清算日期
        ,A1.EN_QSJE AS LIQUI_AMT -- 清算金额 
        ,A1.EN_EXCH AS EXCR -- 汇率
        ,CAST(A1.L_BH AS STRING) AS DEAL_NO -- 成交编号
        ,CAST(A1.L_GLBH AS STRING) AS RELA_NO -- 关联编号
        ,CAST(A1.L_TQBZ AS STRING) AS TRAN_PROP -- 交易属性
        ,CAST(A1.L_DKFX AS STRING) AS MULTI_ORNT -- 多空方向
        ,A1.VC_GDDM AS CUST_NUM -- 客户编码
        ,A8.VC_MC AS TRAN_MEM -- 交易会员
        ,A1.EN_CJJG AS DEAL_PRC -- 成交价格
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_TQSK_PTD' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD A1 -- 清算库
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
    ON CAST(A1.L_ZTBH AS STRING)= A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
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
        ) A11
    ON CAST(A1.L_ZQNM AS STRING)= A11.SCR_INCD
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5
    ON A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_YWLB' AND CAST(A1.L_YWLB AS STRING) = A5.SRC_DICT_CLS_CDVAL  AND A5.VALID_FLAG='1'
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A6
    ON A6.SSYS= 'HSFA' AND A6.SRC_DICT_CLS_CD= 'L_YWLBMX' AND CAST(A1.L_YWLBMX AS STRING) = A6.SRC_DICT_CLS_CDVAL  AND A6.VALID_FLAG='1'
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A7
    ON A7.SSYS= 'HSFA' AND A7.SRC_DICT_CLS_CD= 'L_TZLX' AND CAST(A1.L_TZLX AS STRING) = A7.SRC_DICT_CLS_CDVAL  AND A7.VALID_FLAG='1'
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TQS_PFD A8 -- 券商信息表
    ON A1.VC_QSBH=A8.VC_BH AND A8.P_DT = '${P_BATCH_DT}'
    WHERE A1.P_DT = '${P_BATCH_DT}' AND A1.L_YWLB IN (1501,1502,1503,1504,1505,1511,1512,1513,1514,1515,1517,1518,1520,1526,1527)
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
