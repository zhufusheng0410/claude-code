#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题:产品
-- ** 描述:产品扩展信息
-- ** 创建者:auto
-- ** 创建日期:2023-06-27
-- ** 修改日志:
-- ** 2023-06-27，auto，新建
-- ** 目标表：DWDXDAY.DWD_PROD_PROD_EXTN_INFO_PFD  产品扩展信息
-- ** 源表：  ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD  专户手工信息
-- **         ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDINFO_PFD  基金信息表
-- **         ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD  --基金信息表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  标准字典码值映射
-- **         DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD 产品编码映射
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;

set mapreduce.job.reduces=3;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PROD_PROD_EXTN_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , T1.FILG_CODE                                                                  AS FILG_CODE                               --备案代码
     , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
     , T1.DELY_LIQUI_CAUSE                                                           AS DELY_LIQUI_CAUSE                        --延期清算原因
     , T1.END_CAUSE                                                                  AS END_CAUSE                               --终止原因
     , CASE WHEN T1.INV_TYPE IS NOT NULL 
             THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.INV_TYPE)) 
        END                                                                          AS INV_OBJ_TYPE_CODE                       --投资对象类型代码
     , CASE WHEN T11.C_INVESTORIENTATION IS NOT NULL 
             THEN COALESCE(T12.STD_DICT_CLS_CD_VAL,CONCAT('@',T11.C_INVESTORIENTATION)) 
        END                                                                          AS INV_OBJ_CODE                            --投资对象代码
     , CASE WHEN T1.PROD_TYPE IS NOT NULL 
             THEN COALESCE(T10.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.PROD_TYPE)) 
        END                                                                          AS RAIS_MODE_CODE                          --募集方式代码
     , CASE WHEN T1.MAG_MODE IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.MAG_MODE)) 
        END                                                                          AS MAG_MODE_CODE                           --管理方式代码
     , '01'                                                                          AS TRAN_MKT_CODE                           --交易市场代码(01：场外)
     , CASE WHEN T1.AML_RISK_LVL IS NOT NULL 
             THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.AML_RISK_LVL)) 
        END                                                                          AS AML_RISK_LVL_CODE                       --反洗钱风险等级代码
     , CASE WHEN T1.1V1_INIT_CNOR = '-' 
            THEN NULL                                                                
            ELSE  T1.1V1_INIT_CNOR 
       END                                                                           AS 1V1_INIT_CNOR                           --一对一初始委托人
     , T1.1VN_INIT_CNOR_VOL                                                          AS 1VN_INIT_CNOR_QTY                       --一对多初始委托人数量
     , T1.OPEN_FREQ                                                                  AS OPEN_FREQ                               --开放频率
     , CASE WHEN T1.NEXT_OPEN_TIME = '-' 
            THEN NULL
            WHEN INSTR(T1.NEXT_OPEN_TIME,'-') <> 0
            THEN SUBSTR(T1.NEXT_OPEN_TIME,1,INSTR(T1.NEXT_OPEN_TIME,'-')-1)
            ELSE T1.NEXT_OPEN_TIME
       END                                                                           AS NEXT_OPEN_ST_DATE                       --下次开放开始日期
     , CASE WHEN T1.NEXT_OPEN_TIME = '-' 
            THEN NULL 
            WHEN INSTR(T1.NEXT_OPEN_TIME,'-') <> 0
            THEN SUBSTR(T1.NEXT_OPEN_TIME,INSTR(T1.NEXT_OPEN_TIME,'-')+1,LENGTH(T1.NEXT_OPEN_TIME))
            ELSE T1.NEXT_OPEN_TIME
       END                                                                           AS NEXT_OPEN_END_DATE                      --下次开放结束日期
     , CASE WHEN T1.INV_STRA_CATG IS NOT NULL 
             THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.INV_STRA_CATG)) 
        END                                                                          AS INV_STRA_CATG_CODE                      --投资策略分类代码
     , T1.PROD_SINVD                                                                 AS PROD_SINVD                              --产品具体投向
     , T1.MAG_FEER                                                                   AS CURR_MAG_FEER                           --当前管理费率
     , T1.CSTD_FEER                                                                  AS CURR_CUSTOD_FEER                        --当前托管费率
     , T1.SALE_FEER                                                                  AS CURR_SALE_FEER                          --当前销售费率
     , T1.IS_ACCRUE_PERF_REMU                                                        AS IS_ACCRUE_PERF_REMU                     --是否计提业绩报酬
     , CASE WHEN T1.ACCRUE_TIME_POI = '-'
            THEN NULL
            ELSE T1.ACCRUE_TIME_POI 
       END                                                                           AS ACCRUE_TIME_POI                         --计提时点
     , CASE WHEN T1.ACCRUE_BASI = '-' 
            THEN NULL                                                                
            ELSE T1.ACCRUE_BASI 
       END                                                                           AS ACCRUE_BASI                             --计提基准
     , T1.ACCRUE_RATE                                                                AS ACCRUE_RATE                             --计提比例
     , CASE WHEN TRIM(T1.IS_RETDISTRI) = '否' THEN
              '0'
            WHEN TRIM(T1.IS_RETDISTRI) = '是' THEN
              '1'
            ELSE
              T1.IS_RETDISTRI
       END                                                                           AS IS_BANK_YIELDISTR                       --是否进行收益分配
       --手工表数据不够标准化，需手工转码
     , CASE WHEN T1.RETDISTRI_MODE LIKE '%红利%' AND T1.RETDISTRI_MODE LIKE '%现金%' THEN
              '03'  -- 红利再投资/现金分红(两者兼有)
            WHEN T1.RETDISTRI_MODE LIKE '%红利%' THEN
              '01'  -- 红利再投资
            WHEN T1.RETDISTRI_MODE LIKE '%现金%' THEN
              '02'  -- 现金分红
            WHEN T1.RETDISTRI_MODE = '无' THEN
              '99'
            WHEN LENGTH(REPLACE(T1.RETDISTRI_MODE,'-','')) = 0 OR T1.RETDISTRI_MODE IS NULL THEN 
              NULL
            ELSE  --不规范的数据，或者新增的分配方式
              CONCAT('@',REPLACE(T1.RETDISTRI_MODE,'-',''))
       END                                                                           AS YIELDISTR_MODE_CODE                     --收益分配方式
     , REPLACE(T1.RETDISTRI_TIME,'-','')                                             AS YIELDISTR_TIMES                         --收益分配次数
     , CASE WHEN T1.WARN_LINE = '-' 
            THEN NULL                                                                
            ELSE T1.WARN_LINE 
       END                                                                           AS CURR_WARN_LINE                          --当前预警线
     , CASE WHEN LENGTH(REPLACE(T1.WARN_LINE_TYPE,'-','')) <> 0
             THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',REPLACE(T1.WARN_LINE_TYPE,'-',''))) 
        END                                                                          AS WARN_LINE_TYPE_CODE                     --预警线类型代码
     , CASE WHEN T1.TW_WARN_LINE_BACK_MEASU ='-'                                                     
            THEN NULL 
            ELSE T1.TW_WARN_LINE_BACK_MEASU
       END                                                                           AS AT_WARN_LINE_MEAS                       --到达预警线后措施
     , CASE WHEN T1.STOP_LINE ='-'
            THEN NULL
            ELSE  T1.STOP_LINE
       END                                                                           AS STOP_LINE                               --当前止损线
     , CASE WHEN LENGTH(REPLACE(T1.STOP_LINE_TYPE,'-','')) <> 0
             THEN COALESCE(T9.STD_DICT_CLS_CD_VAL,CONCAT('@',REPLACE(T1.STOP_LINE_TYPE,'-',''))) 
        END                                                                          AS STOP_LINE_TYPE_CODE                     --止损线类型代码
     , T1.TW_STOP_LINE_BACK_MEASU                                                    AS AT_STOP_LINE_MEAS                       --到达止损线后措施
     , T1.RISK_IDTY_EVT                                                              AS RISK_IDTY_EVT                           --风险识别事件
     , NULL                                                                          AS RISK_RES                                --风险准备金
     , NULL                                                                          AS TRACK_ATTE_LVL                          --跟踪关注等级
     , NULL                                                                          AS VALU_SEND_FREQ                          --估值发送频率
     , NULL                                                                          AS OTHER_TYPE_SERVI                        --其他类型服务
     , NULL                                                                          AS MEMO                                    --备注
     , 'MANUAL'                                                                      AS SSYS                                    --源系统
     , 'ODS_MANUAL_SPEBA_MANUAL_INFO_PFD'                                            AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD T1  --专户手工信息
  LEFT JOIN ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDINFO_PFD T11 --基金信息表
    ON T1.PROD_CODE = T11.C_FUNDCODE
   AND T11.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.PROD_CODE = T2.PROD_INCD
   AND T2.SSYS = 'MANUAL'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'MANUAL'
   AND T3.SRC_DICT_CLS_CD = 'INV_TYPE'
   AND T1.INV_TYPE = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'MANUAL'
   AND T4.SRC_DICT_CLS_CD = 'MAG_MODE'
   AND T1.MAG_MODE = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'MANUAL'
   AND T6.SRC_DICT_CLS_CD = 'AML_RISK_LVL'
   AND T1.AML_RISK_LVL = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'MANUAL'
   AND T7.SRC_DICT_CLS_CD = 'INV_STRA_CATG'
   AND T1.INV_STRA_CATG = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'MANUAL'
   AND T8.SRC_DICT_CLS_CD = 'WARN_LINE_TYPE'
   AND REPLACE(T1.WARN_LINE_TYPE,'-','') = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T9 --标准字典码值映射
    ON T9.SSYS = 'MANUAL'
   AND T9.SRC_DICT_CLS_CD = 'STOP_LINE_TYPE'
   AND REPLACE(T1.STOP_LINE_TYPE,'-','') = T9.SRC_DICT_CLS_CDVAL
   AND T9.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T10 --标准字典码值映射
    ON T10.SSYS = 'MANUAL'
   AND T10.SRC_DICT_CLS_CD = 'PROD_RAIS_TYPE'
   AND T1.PROD_TYPE = T10.SRC_DICT_CLS_CDVAL
   AND T10.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T12 --标准字典码值映射
    ON T12.SSYS = 'HSZTA'
   AND T12.SRC_DICT_CLS_CD = 'C_INVESTORIENTATION'
   AND T11.C_INVESTORIENTATION = T12.SRC_DICT_CLS_CDVAL
   AND T12.VALID_FLAG = '1'
WHERE T1.P_DT = '${p_end_dt}'
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_EXTN_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , NULL                                                                          AS FILG_CODE                               --备案代码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , NULL                                                                          AS DELY_LIQUI_CAUSE                        --延期清算原因
     , NULL                                                                          AS END_CAUSE                               --终止原因
     , CASE WHEN T1.C_INVESTORIENTATION IS NOT NULL 
             THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVESTORIENTATION)) 
        END                                                                          AS INV_OBJ_TYPE_CODE                       --投资对象类型代码
     , CASE WHEN T1.C_INVESTORIENTATION IS NOT NULL 
            THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_INVESTORIENTATION)) 
        END                                                                          AS INV_OBJ_CODE                            --投资对象代码
     , CASE WHEN T1.C_FUNDTYPE IS NOT NULL 
             THEN COALESCE(T8.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_FUNDTYPE)) 
        END                                                                          AS RAIS_MODE_CODE                          --募集方式代码
     , CASE WHEN T1.C_INVESTORIENTATION=5 THEN '01' ELSE '02' END                    AS MAG_MODE_CODE                           --管理方式代码
     , '01'                                                                          AS TRAN_MKT_CODE                           --交易市场代码(01：场外)
     , NULL                                                                          AS AML_RISK_LVL_CODE                       --反洗钱风险等级代码
     , NULL                                                                          AS 1V1_INIT_CNOR                           --一对一初始委托人
     , NULL                                                                          AS 1VN_INIT_CNOR_QTY                       --一对多初始委托人数量
     , NULL                                                                          AS OPEN_FREQ                               --开放频率
     , NULL                                                                          AS NEXT_OPEN_ST_DATE                       --下次开放开始日期
     , NULL                                                                          AS NEXT_OPEN_END_DATE                      --下次开放结束日期
     , NULL                                                                          AS INV_STRA_CATG_CODE                      --投资策略分类代码
     , T1.C_INVESTORIENTATION                                                        AS PROD_SINVD                              --产品具体投向
     , T1.F_MANAGERFEE                                                               AS CURR_MAG_FEER                           --当前管理费率
     , NULL                                                                          AS CURR_CUSTOD_FEER                        --当前托管费率
     , NULL                                                                          AS CURR_SALE_FEER                          --当前销售费率
     , NULL                                                                          AS IS_ACCRUE_PERF_REMU                     --是否计提业绩报酬
     , NULL                                                                          AS ACCRUE_TIME_POI                         --计提时点
     , NULL                                                                          AS ACCRUE_BASI                             --计提基准
     , NULL                                                                          AS ACCRUE_RATE                             --计提比例
     , CASE WHEN TRIM(T1.C_WHETHERDIVID) = '否' THEN
              '0'
            WHEN TRIM(T1.C_WHETHERDIVID) = '是' THEN
              '1'
            ELSE
              T1.C_WHETHERDIVID
       END                                                                           AS IS_BANK_YIELDISTR                       --是否进行收益分配
     , CASE WHEN T1.C_BONUSTYPE IS NOT NULL THEN 
              COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BONUSTYPE)) 
       END                                                                           AS YIELDISTR_MODE                          --收益分配方式
     , NULL                                                                          AS YIELDISTR_TIMES                         --收益分配次数
     , NULL                                                                          AS CURR_WARN_LINE                          --当前预警线
     , NULL                                                                          AS WARN_LINE_TYPE_CODE                     --预警线类型代码
     , NULL                                                                          AS AT_WARN_LINE_MEAS                       --到达预警线后措施
     , NULL                                                                          AS STOP_LINE                               --当前止损线
     , NULL                                                                          AS STOP_LINE_TYPE_CODE                     --止损线类型代码
     , NULL                                                                          AS AT_STOP_LINE_MEAS                       --到达止损线后措施
     , NULL                                                                          AS RISK_IDTY_EVT                           --风险识别事件
     , NULL                                                                          AS RISK_RES                                --风险准备金
     , NULL                                                                          AS TRACK_ATTE_LVL                          --跟踪关注等级
     , NULL                                                                          AS VALU_SEND_FREQ                          --估值发送频率
     , NULL                                                                          AS OTHER_TYPE_SERVI                        --其他类型服务
     , NULL                                                                          AS MEMO                                    --备注
     , 'HSZTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSZTA_TFUNDINFO_PFD'                                                     AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDINFO_PFD T1  --基金信息表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSZTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3 --标准字典码值映射
    ON T3.SSYS = 'HSZTA'
   AND T3.SRC_DICT_CLS_CD = 'C_INVESTORIENTATION1'
   AND T1.C_INVESTORIENTATION  = T3.SRC_DICT_CLS_CDVAL
   AND T3.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSZTA'
   AND T4.SRC_DICT_CLS_CD = 'C_RISKLEVEL'
   AND T1.C_RISKLEVEL = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSZTA'
   AND T6.SRC_DICT_CLS_CD = 'C_INVESTORIENTATION'
   AND T1.C_INVESTORIENTATION  = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN  DWDXDAY.DWD_PROD_PROD_EXTN_INFO_PFD  T5  --产品扩展信息
    ON T5.PROD_NUM = T2.PROD_NUM
   AND T5.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'HSZTA'
   AND T7.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE  = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T8 --标准字典码值映射
    ON T8.SSYS = 'HSZTA'
   AND T8.SRC_DICT_CLS_CD = 'C_FUND_RAIS_TYPE'
   AND T1.C_FUNDTYPE  = T8.SRC_DICT_CLS_CDVAL
   AND T8.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T5.PROD_NUM IS NULL
;

INSERT INTO DWDXDAY.DWD_PROD_PROD_EXTN_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
SELECT 
       T2.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
     , NULL                                                                          AS FILG_CODE                               --备案代码
     , T1.C_FUNDCODE                                                                 AS PROD_CODE                               --产品代码
     , NULL                                                                          AS DELY_LIQUI_CAUSE                        --延期清算原因
     , NULL                                                                          AS END_CAUSE                               --终止原因
     , CASE WHEN T1.C_PROPERTY IS NOT NULL 
             THEN COALESCE(T4.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PROPERTY)) 
       END                                                                          AS INV_OBJ_TYPE_CODE                       --投资对象类型代码
     , CASE WHEN T1.C_PROPERTY IS NOT NULL 
             THEN COALESCE(T6.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_PROPERTY)) 
       END                                                                           AS INV_OBJ_CODE                            --投资对象代码
     , '02'                                                                          AS RAIS_MODE_CODE                          --募集方式代码(02:集合)
     , NULL                                                                          AS MAG_MODE_CODE                           --管理方式代码
     , CASE WHEN T1.C_BOURSEFLAG IS NOT NULL 
             THEN COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BOURSEFLAG)) 
       END                                                                           AS TRAN_MKT_CODE                           --交易市场代码
     , NULL                                                                          AS AML_RISK_LVL_CODE                       --反洗钱风险等级代码
     , NULL                                                                          AS 1V1_INIT_CNOR                           --一对一初始委托人
     , NULL                                                                          AS 1VN_INIT_CNOR_QTY                       --一对多初始委托人数量
     , NULL                                                                          AS OPEN_FREQ                               --开放频率
     , NULL                                                                          AS NEXT_OPEN_ST_DATE                       --下次开放开始日期
     , NULL                                                                          AS NEXT_OPEN_END_DATE                      --下次开放结束日期
     , NULL                                                                          AS INV_STRA_CATG_CODE                      --投资策略分类代码
     , NULL                                                                          AS PROD_SINVD                              --产品具体投向
     , T1.F_MANAGERFEE                                                               AS CURR_MAG_FEER                           --当前管理费率
     , NULL                                                                          AS CURR_CUSTOD_FEER                        --当前托管费率
     , NULL                                                                          AS CURR_SALE_FEER                          --当前销售费率
     , NULL                                                                          AS IS_ACCRUE_PERF_REMU                     --是否计提业绩报酬
     , NULL                                                                          AS ACCRUE_TIME_POI                         --计提时点
     , NULL                                                                          AS ACCRUE_BASI                             --计提基准
     , NULL                                                                          AS ACCRUE_RATE                             --计提比例
     , CASE WHEN TRIM(T1.C_WHETHERDIVID) = '否' THEN
              '0'
            WHEN TRIM(T1.C_WHETHERDIVID) = '是' THEN
              '1'
            ELSE
              T1.C_WHETHERDIVID
       END                                                                           AS IS_BANK_YIELDISTR                       --是否进行收益分配
     , CASE WHEN T1.C_BONUSTYPE IS NOT NULL THEN 
              COALESCE(T7.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_BONUSTYPE)) 
       END                                                                           AS YIELDISTR_MODE                          --收益分配方式
     , NULL                                                                          AS YIELDISTR_TIMES                         --收益分配次数
     , NULL                                                                          AS CURR_WARN_LINE                          --当前预警线
     , NULL                                                                          AS WARN_LINE_TYPE_CODE                     --预警线类型代码
     , NULL                                                                          AS AT_WARN_LINE_MEAS                       --到达预警线后措施
     , NULL                                                                          AS STOP_LINE                               --当前止损线
     , NULL                                                                          AS STOP_LINE_TYPE_CODE                     --止损线类型代码
     , NULL                                                                          AS AT_STOP_LINE_MEAS                       --到达止损线后措施
     , NULL                                                                          AS RISK_IDTY_EVT                           --风险识别事件
     , NULL                                                                          AS RISK_RES                                --风险准备金
     , NULL                                                                          AS TRACK_ATTE_LVL                          --跟踪关注等级
     , NULL                                                                          AS VALU_SEND_FREQ                          --估值发送频率
     , NULL                                                                          AS OTHER_TYPE_SERVI                        --其他类型服务
     , NULL                                                                          AS MEMO                                    --备注
     , 'HSFTA'                                                                       AS SSYS                                    --源系统
     , 'ODS_HSFTA_TFUNDINFO_PFD'                                                     AS SRC_TAB                                 --源表
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD T1  --基金信息表
  LEFT JOIN DWDXDAY.DWD_PROD_PROD_NUM_MAPP_PFD T2 --产品编码映射
    ON T1.C_FUNDCODE = T2.PROD_INCD
   AND T2.SSYS = 'HSFTA'
   AND T2.ST_DATE <= '${p_end_dt}'
   AND T2.END_DATE >= '${p_end_dt}'
   AND T2.VALID_FLAG = '1' --有效标志
   AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
  LEFT JOIN  DWDXDAY.DWD_PROD_PROD_EXTN_INFO_PFD  T5  --产品扩展信息
    ON T5.PROD_NUM = T2.PROD_NUM
   AND T5.SSYS <> 'HSFTA'
   AND T5.P_DT = '${p_end_dt}'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4 --标准字典码值映射
    ON T4.SSYS = 'HSFTA'
   AND T4.SRC_DICT_CLS_CD = 'C_PROPERTY1'
   AND T1.C_PROPERTY  = T4.SRC_DICT_CLS_CDVAL
   AND T4.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T6 --标准字典码值映射
    ON T6.SSYS = 'HSFTA'
   AND T6.SRC_DICT_CLS_CD = 'C_PROPERTY'
   AND T1.C_PROPERTY  = T6.SRC_DICT_CLS_CDVAL
   AND T6.VALID_FLAG = '1'
  LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T7 --标准字典码值映射
    ON T7.SSYS = 'HSFTA'
   AND T7.SRC_DICT_CLS_CD = 'C_BONUSTYPE'
   AND T1.C_BONUSTYPE  = T7.SRC_DICT_CLS_CDVAL
   AND T7.VALID_FLAG = '1'
 WHERE T1.P_DT = '${p_end_dt}'
   AND T5.PROD_NUM IS NULL
;
"
