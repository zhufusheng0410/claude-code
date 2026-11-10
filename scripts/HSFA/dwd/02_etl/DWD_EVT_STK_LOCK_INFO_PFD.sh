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
    -- ** 描述: 股票锁定信息
    -- ** 创建者 :VHHV
    -- ** 创建日期: 20230621
    -- ** 目标表：DWDXDAY.DWD_EVT_STK_LOCK_INFO_PFD    股票锁定信息
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TGPSD_PFD     股票锁定表
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_STK_LOCK_INFO_PFD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT
        CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
        ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
        ,A10.PROD_CODE AS PROD_CODE -- 产品代码
        ,A11.SCR_NUM AS SCR_NUM -- 证券编码
        ,CAST(A1.L_ZQNM AS STRING) AS SCR_INCD -- 证券内码
        ,A1.VC_ZQDM AS STK_CODE -- 股票代码
        ,A11.SCR_DETAIL_TYPE AS STK_CATG -- 股票类别
        ,A5.STD_DICT_CLS_CD_VAL AS RES_TYPE -- 限售类型
        ,A1.D_SDBEGIN AS LOCK_ST_DATE -- 锁定开始日期
        ,A1.D_SDEND AS LOCK_END_DATE -- 锁定结束日期
        ,CAST(A1.L_SDTS AS STRING) AS LOCK_MATY -- 锁定期限
        ,0 AS LOCK_COST -- 锁定成本
        ,0 AS LOCK_QTY -- 锁定数量
        ,A1.EN_SDJG AS LOCK_PRC -- 锁定价格
        ,0 AS LOCK_DAYS_ADJ -- 锁定天数调整
        ,'HSFA' AS SSYS -- 源系统
        ,'ODS_HSFA_TGPSD_PFD  ' AS SOURCE_TAB -- 源表
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
        ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
    FROM ODS_XDAY_HSFA.ODS_HSFA_TGPSD_PFD  A1 -- 股票锁定表
    LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
    ON CAST(A1.L_ZTBH AS STRING) = A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
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
    ON CAST(A1.L_ZQNM AS STRING) = A11.SCR_INCD
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5  -- 标准字典码值映射
    ON A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD= 'L_XSLX' AND CAST(A1.L_XSLX AS STRING) = A5.SRC_DICT_CLS_CDVAL AND A5.VALID_FLAG='1'
    WHERE A1.P_DT = '${P_BATCH_DT}'
    ;
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
