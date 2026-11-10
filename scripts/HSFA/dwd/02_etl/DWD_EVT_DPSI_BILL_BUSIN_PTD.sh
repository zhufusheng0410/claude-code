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
    -- ** 描述: 存款票据业务
    -- ** 创建者 :VHHV
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_DPSI_BILL_BUSIN_PTD    存款票据业务
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYW_PFD     存款业务主表
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLS_PTD     存款业务交易流水表
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLL_PFD    -- 存款业务利率表
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
    set mapreduce.job.reduces=4;
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_DPSI_BILL_BUSIN_PTD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT 
        CAST(A3.L_ZTBH AS STRING)                                              AS SFAC_NO -- '账套编号'
       ,A10.SFAC_NUM                                                             AS SFAC_NUM -- '账套编码'
       ,A3.D_DATE                                                               AS TRAN_DATE -- '交易日期'
       ,A10.PROD_CODE                                                             AS PROD_CODE -- '产品代码'
      , A3.L_CKID                                                                AS depo_rece_incd   --存单内码
       ,A1.VC_CDH                                                                AS DEPO_RECE_NO -- '存单编号'
       ,A1.BUSIN_CATG                                                            AS BUSIN_CATG -- '业务类别(存款类型)'
       ,A3.VC_TYPE                                                               AS BUSIN_DETAIL_CATG -- '业务明细类别(流水类型)'
       ,A3.EN_BJBD                                                               AS DPSI_AMT -- '存款金额'
       ,A4.EN_LL                                                                 AS DPSI_INTR -- '存款利率'
       ,'0'                                                                      AS INTA_FREQ -- '计息频率'
       ,A1.C_FXFS                                                                AS INTR_CALCT_WAY -- '利息计算方法' 
       ,CAST(A1.L_NJXTS AS STRING)                                               AS YEAR_ACCRDAYS -- '年计息天数'
       ,A1.C_FXFS                                                                AS INTL_MODE -- '结息方式'
       ,A1.VC_BJKM                                                               AS PRIN_CRSE -- '本金科目'
       ,A1.VC_LXKM                                                               AS RECV_INTR_CRSE -- '应收利息科目'
       ,A1.VC_LXSRKM                                                             AS INTR_INCM_CRSE -- '利息收入科目'
       ,CAST(A1.L_LLLB AS STRING)                                                AS INTR_CATG -- '利率类别'
       ,A1.EN_ZLX                                                                AS TOT_INTR -- '总利息'
       ,CAST(A1.L_JXFS AS STRING)                                                                AS INTA_MODE -- '计息方式'
       ,A1.D_SDATE                                                               AS INIT_DATE -- '首期日期'
       ,A1.D_EDATE                                                               AS DUE_DATE_PD -- '到期日期'
       ,A4.D_KSRQ                                                                AS VALUE_DATE -- '起息日期'
       ,A1.D_XFXR                                                                AS FST_INTL_DAY -- '首次结息日'
       ,A3.EN_BJBD                                                               AS PRIN_CHG -- '本金变动'
       ,A3.EN_LXBD                                                               AS INTR_CHG -- '利息变动'
       ,A3.EN_ZCLX                                                               AS ACT_INTL_AMT -- 实际结息金额
       ,A1.VC_ZQDM                                                               AS DPSI_ACCT --'存款账户
       ,A1.VC_ZQMC                                                               AS DPSI_ACCT_NAME -- '存款账户名称'
       ,A1.CNTP                                                               AS CNTP -- '交易对手方'
       ,A3.EN_EXCH                                                               AS EXCR -- '汇率'
       ,A1.VC_JSBZ                                                               AS CRRC -- '币种'
       ,'HSFA'                                                                   AS SSYS -- '源系统'
       ,'ODS_HSFA_TCAP_CKYW_PTD'                                                 AS SOURCE_TAB -- 源表'
       ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- '加载时间'
       ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- '修改时间'
    FROM 
        (SELECT T1.L_ZTBH --账套编号
            ,T1.L_CKID --存款序号
            ,T1.VC_TYPE AS VC_TYPE --流水类别
            ,T1.D_DATE --业务日期
            ,T1.EN_BJBD --本金变动
            ,T1.EN_LXBD --利息变动
            ,T1.EN_ZCLX -- 实际结息金额
            ,T1.EN_EXCH --汇率 
         FROM ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLS_PTD T1
         WHERE T1.P_DT = '${P_BATCH_DT}' 
        ) A3  -- 存款业务交易流水表
    LEFT JOIN 
        (SELECT A1.L_CKID,A1.L_ZTBH,A1.VC_CDH,A1.C_FXFS,A1.VC_BJKM,A1.VC_LXKM,A1.VC_LXSRKM,A1.L_LLLB
               ,A1.EN_ZLX,A1.L_JXFS,A1.D_SDATE,A1.D_EDATE,A1.D_XFXR,A1.VC_ZQDM,A1.VC_ZQMC,A1.VC_JSBZ
               ,A1.L_NJXTS
               ,A5.STD_DICT_CLS_CD_VAL AS BUSIN_CATG
               ,A8.VC_NAME AS CNTP
         FROM ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYW_PFD A1 -- 存款基本信息
         LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5  -- 标准字典码值映射
         ON CAST(A1.L_YWLB AS STRING) = A5.SRC_DICT_CLS_CDVAL AND A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_YWLB' AND A5.VALID_FLAG='1'
         LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TJYDS_PFD A8 --交易对手表
         ON A1.VC_JYDS=A8.VC_DSBH AND A8.P_DT = '${P_BATCH_DT}'
         WHERE A1.P_DT = '${P_BATCH_DT}'
        ) A1
    ON A1.L_ZTBH=A3.L_ZTBH AND A1.L_CKID=A3.L_CKID 
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
    ON CAST(A3.L_ZTBH AS STRING)=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLL_PFD A4 -- 存款业务利率表
    ON A3.L_CKID=A4.L_CKID AND A4.P_DT = '${P_BATCH_DT}'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
