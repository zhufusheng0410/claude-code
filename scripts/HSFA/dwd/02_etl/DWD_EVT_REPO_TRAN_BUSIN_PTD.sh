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
    -- ** 描述: 回购交易业务
    -- ** 创建者 :VHHV
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_REPO_TRAN_BUSIN_PTD    回购交易业务
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD A1    回购交易表
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TXM_XX_PTD A1   协议回购信息
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_REPO_TRAN_BUSIN_PTD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT
        CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
        ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,A1.D_CJRQ AS TRAN_DATE -- 交易日期
        ,A10.PROD_CODE AS PROD_CODE -- 产品代码
        ,A11.SCR_NUM AS SCR_NUM -- 证券编码
        ,CAST(A1.L_ZQNM AS STRING) AS SCR_INCD -- 证券内码
        ,A1.VC_ZQDM AS REPO_CODE -- 回购代码
        ,A11.SCR_DETAIL_TYPE AS REPO_VAR -- 回购品种
        ,A11.TRAN_MKT_CODE AS TRAN_MKT -- 交易市场
        ,A1.VC_JSBZ AS CRRC -- 币种
        ,A5.STD_DICT_CLS_CD_VAL AS BUSIN_CATG -- 业务类别
        ,'' AS BUSIN_CATG_DETAIL -- 业务类别明细
        ,A1.VC_XWDM AS TRAN_CHNL -- 交易渠道
        ,A1.VC_GDDM AS TRAN_ACCT -- 交易账户
        ,A1.VC_BFZH AS CPTL_ACCT -- 资金账户
        ,A1.L_HGSL AS REPO_QTY -- 回购数量
        ,A1.EN_HGJG AS REPO_PRC -- 回购价格
        ,A1.EN_HGJE AS REPO_AMT -- 回购金额
        ,A1.EN_HGLX AS REPO_YIEL -- 回购收益
        ,A1.EN_YJ AS FARE -- 佣金
        ,A1.EN_HGFY AS TRAN_CHAG -- 交易手续费
        ,A1.EN_JSSXF AS SETL_FEE -- 结算手续费
        ,A1.EN_FKJE AS REBA_AMT -- 返款金额
        ,CAST(A1.L_QSSD AS STRING) AS LIQUI_VELOCITY -- 清算速度
        ,A1.D_JGRI AS DUE_DATE_PD -- 到期日期
        ,'' AS SCR_STK_INCD -- 标的券内码 需通过编号关联质押券信息表取数，质押券可能有多个
        ,0 AS SCR_STK_QTY -- 标的券数量 需关联质押券信息表取数，质押券可能有多个
        ,CAST(A12.L_HGTS AS STRING) AS REPO_MATY -- 回购期限
        ,CAST(A1.L_YJXTS AS STRING) AS ACTL_FUTK_DAYS -- 实际占款天数
        ,A1.EN_NLL AS REPO_INTR -- 回购利率
        ,CAST(A1.L_JSJG AS STRING) AS SETL_ORG -- 结算机构
        ,'' AS AHED_DUE_DATE -- 提前到期日
        ,CAST(A1.L_DQJSFS AS STRING) AS DUE_SETL_MODE -- 到期结算方式 
        ,A8.VC_NAME AS CNTP -- 交易对手方
        ,'' AS CUTP_ACCT -- 对手方账户
        ,CAST(A1.L_BH AS STRING) AS DEAL_NO -- 成交编号
        ,CAST(A1.L_BH AS STRING) AS RELA_NO -- 关联编号
        ,CAST(A1.L_TQBZ AS STRING) AS TRAN_PROP -- 交易属性
        ,A1.EN_EXCH AS EXCR -- 汇率
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_THGJY_PTD' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD A1 -- 回购交易表
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
        ) A11
    ON CAST(A1.L_ZQNM AS STRING)=A11.SCR_INCD
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TZQXX_PFD A12
    ON A1.L_ZQNM=A12.L_ZQNM AND A12.P_DT = '${P_BATCH_DT}'
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5
    ON A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_YWLB' AND CAST(A1.L_YWLB AS STRING) = A5.SRC_DICT_CLS_CDVAL  AND A5.VALID_FLAG='1'
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TJYDS_PFD A8  -- 交易对手表
    ON A1.VC_JYDS=A8.VC_DSBH AND A8.P_DT = '${P_BATCH_DT}'
    WHERE A1.L_YWLB IN (1301,1302) AND A1.P_DT = '${P_BATCH_DT}'
    UNION ALL  -- 协议回购
    SELECT
        CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
        ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,A1.D_SDATE AS TRAN_DATE -- 交易日期
        ,A10.PROD_CODE AS PROD_CODE -- 产品代码
        ,'' AS SCR_NUM -- 证券编码
        ,'' AS SCR_INCD -- 证券内码
        ,'' AS REPO_CODE -- 回购代码
        ,'' AS REPO_VAR -- 回购品种
        ,A3.STD_DICT_CLS_CD_VAL AS TRAN_MKT -- 交易市场
        ,A1.VC_JSBZ AS CRRC -- 币种
        ,A5.STD_DICT_CLS_CD_VAL AS BUSIN_CATG -- 业务类别
        ,'' AS BUSIN_CATG_DETAIL -- 业务类别明细
        ,A1.VC_XWDM AS TRAN_CHNL -- 交易渠道
        ,A1.VC_GDDM AS TRAN_ACCT -- 交易账户
        ,'' AS CPTL_ACCT -- 资金账户
        ,A6.L_BDSL AS REPO_QTY -- 回购数量
        ,CAST('' AS DECIMAL(20,10)) AS REPO_PRC -- 回购价格
        ,A6.EN_CJJE AS REPO_AMT -- 回购金额
        ,A6.EN_LXBD AS REPO_YIEL -- 回购收益
        ,A6.EN_YJ AS FARE -- 佣金
        ,A6.EN_FY AS TRAN_CHAG -- 交易手续费
        ,0 AS SETL_FEE -- 结算手续费
        ,0 AS REBA_AMT -- 返款金额
        ,'' AS LIQUI_VELOCITY -- 清算速度
        ,A1.D_EDATE AS DUE_DATE_PD -- 到期日期
        ,CAST(A9.L_ZQNM AS STRING) AS SCR_STK_INCD -- 标的券内码
        ,A9.EN_SL AS SCR_STK_QTY -- 标的券数量
        ,'' AS REPO_MATY -- 回购期限
        ,'' AS ACTL_FUTK_DAYS -- 实际占款天数
        ,A7.EN_NLL AS REPO_INTR -- 回购利率
        ,'' AS SETL_ORG -- 结算机构
        ,'' AS AHED_DUE_DATE -- 提前到期日
        ,'' AS DUE_SETL_MODE -- 到期结算方式 
        ,A8.VC_NAME AS CNTP -- 交易对手方
        ,'' AS CUTP_ACCT -- 对手方账户
        ,CAST(A1.L_BH AS STRING) AS DEAL_NO -- 成交编号
        ,CAST(A1.L_BH AS STRING) AS RELA_NO -- 关联编号
        ,'' AS TRAN_PROP -- 交易属性
        ,A6.EN_EXCH AS EXCR -- 汇率
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_THGJY_PTD ' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TXM_XX_PTD A1 -- 协议回购信息
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
    ON CAST(A1.L_ZTBH AS STRING)=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典码值映射
    ON A3.SSYS= 'HSFA' AND A3.SRC_DICT_CLS_CD= 'L_SCLB' AND CAST(A1.L_SCLB AS STRING) = A3.SRC_DICT_CLS_CDVAL  AND A3.VALID_FLAG='1'
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5
    ON A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_YWLB' AND CAST(A1.L_YWLB AS STRING) = A5.SRC_DICT_CLS_CDVAL  AND A5.VALID_FLAG='1'
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TXM_LS_PTD A6 -- 协议回购流水
    ON A1.L_ZTBH=A6.L_ZTBH AND A1.L_BH=A6.L_BH AND A6.P_DT = '${P_BATCH_DT}'
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TXM_LL_PFD A7  -- 协议回购利率
    ON A1.L_ZTBH=A7.L_ZTBH AND A1.L_BH=A7.L_BH AND A7.P_DT = '${P_BATCH_DT}'
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TJYDS_PFD A8 -- 交易对手表
    ON A1.VC_JYDS=A8.VC_DSBH AND A8.P_DT = '${P_BATCH_DT}'
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TGPZYHG_ZYQ_PFD A9  -- 股票协议回购质押券信息
    ON A1.L_BH=A9.L_BH AND A9.P_DT = '${P_BATCH_DT}'
    WHERE A1.L_YWLB IN (1347,1349,1351,1353) AND A1.P_DT = '${P_BATCH_DT}'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
