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
    -- ** 主题:产品
    -- ** 描述:产品信息
    -- ** 创建者:auto
    -- ** 创建日期:2023-07-11
    -- ** 修改日志:
    -- ** 2023-07-11，auto，新建
    -- ** 目标表：DWSXDAY.DWS_PROD_INFO_PFD  产品信息
    -- ** 源表：  DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD 产品基本信息
    -- **         DWDXDAY.DWD_PROD_PROD_EXTN_INFO_PFD 产品扩展信息
    -- **         DWDXDAY.DWD_PROD_PROD_SALE_FEER_INFO_PFD 产品销售费率信息
    -- **         DWDXDAY.DWD_PROD_PROD_SFAC_RELA_PFD 产品套账关系
    -- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD 帐套编码映射
    -- **         DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD 产品角色
    -- **         DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD 产品预警历史信息
    -- **         DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO 标准字典分类枚举信息
    -- **************************************************************************
    
    set hive.exec.dynamic.partition=true;
    set hive.exec.dynamic.partition.mode=nonstrict;
    set hive.exec.max.dynamic.partitions.pernode=10000;
    set hive.exec.max.dynamic.partitions=10000;
    set hive.exec.max.created.files=10000;
    set mapred.max.split.size=256000000;
    set mapred.min.split.size.per.node=100000000;
    set mapred.min.split.size.per.rack=100000000;
    set hive.merge.mapredfiles=true;
    set hive.merge.mapfiles=true;
    set hive.merge.smallfiles.avgsize=16000000;
    set hive.merge.size.per.task=256000000;
    
    INSERT OVERWRITE TABLE DWSXDAY.DWS_PROD_INFO_PFD PARTITION(P_DT = '${p_end_dt}')
    SELECT 
           T1.PROD_NUM                                                                   AS PROD_NUM                                --产品编码
         , T3.SFAC_NUM                                                                   AS SFAC_NUM                                --帐套编码
         , T4.SFAC_INCD                                                                  AS FA_SFAC_INCD                            --FA帐套内码
         , T5.SFAC_INCD                                                                  AS O32_SFAC_INCD                           --O32帐套内码
         , T1.MAIN_PROD_CODE                                                             AS MAIN_PROD_CODE                          --主产品代码
         , T1.MAIN_PROD_FLAG                                                             AS MAIN_PROD_FLAG                          --主产品标志
         , T1.PROD_CODE                                                                  AS PROD_CODE                               --产品代码
         , T2.FILG_CODE                                                                  AS FILG_CODE                               --备案代码
         , T1.CSNAME                                                                     AS CSNAME                                  --中文简称
         , T1.CNAME                                                                      AS CNAME                                   --中文全称
         , T15.CSNAME                                                                    AS SFAC_CSNAME                             --帐套中文简称
         , T15.CNAME                                                                     AS SFAC_CNAME                              --帐套中文全称
         , T1.SHARE_CATG_CODE                                                            AS SHARE_CATG_CODE                         --份额类别代码
         , T1.CLAS_CATG_CODE                                                             AS CLAS_CATG_CODE                          --分级类别代码
         , T1.PROD_SETUP_DATE                                                            AS PROD_SETUP_DATE                         --成立日期
         , T1.PROD_END_DATE                                                              AS PROD_END_DATE                           --结束日期（预期到期日期）
         , T15.LIQU_DATE                                                                 AS LIQU_DATE                               --清盘日期(实际结束日期)
         , T1.RAIS_ST_DATE                                                               AS RAIS_ST_DATE                            --募集开始日期
         , T1.RAIS_END_DATE                                                              AS RAIS_END_DATE                           --募集结束日期
         , T1.RAIS_FAIL_DATE                                                             AS RAIS_FAIL_DATE                          --募集失败日期
         , T15.OPER_ST_DATE                                                              AS VALU_ST_DATE                            --估值开始日期
         , T15.OPER_END_DATE                                                             AS VALU_END_DATE                           --估值结束日期
         , T2.DELY_LIQUI_CAUSE                                                           AS DELY_LIQUI_CAUSE                        --延期清算原因
         , T2.END_CAUSE                                                                  AS END_CAUSE                               --终止原因
         , T2.INV_OBJ_TYPE_CODE                                                          AS INV_OBJ_TYPE_CODE                       --投资对象类型代码
         , T19.STD_DICT_CLS_CDVAL_DESC                                                   AS INV_OBJ_TYPE                            --投资对象类型
         , T2.INV_OBJ_CODE                                                               AS INV_OBJ_CODE                            --投资对象代码
         , T20.STD_DICT_CLS_CDVAL_DESC                                                   AS INV_OBJ                                 --投资对象
         , T2.TRAN_MKT_CODE                                                              AS TRAN_MKT_CODE                           --交易市场代码
         , T21.STD_DICT_CLS_CDVAL_DESC                                                   AS TRAN_MKT                                --交易市场
         , T1.PR_CRRC_CODE                                                               AS PR_CRRC_CODE                            --申赎币种代码
         , T1.REG_ORGNO                                                                  AS REG_ORGNO                               --注册登记机构代码
         , T1.MGR_NUM                                                                    AS MGR_NUM                                 --管理人编码
         , T1.MGR_NAME                                                                   AS MGR_NAME                                --管理人名称
         , T1.TRUS_NUM                                                                   AS TRUS_NUM                                --托管人编码
         , T1.TRUS_NAME                                                                  AS TRUS_NAME                               --托管人名称
         , T1.PROD_STAT_CODE                                                             AS PROD_STAT_CODE                          --产品状态代码
         , T17.STD_DICT_CLS_CDVAL_DESC                                                   AS PROD_STAT_NAME                          --产品状态名称
         , NULL                                                                          AS OPER_MODE_CODE                          --运作方式代码
         , T2.RAIS_MODE_CODE                                                             AS RAIS_MODE_CODE                          --募集方式代码
         , T16.STD_DICT_CLS_CDVAL_DESC                                                   AS RAIS_MODE_NAME                          --募集方式名称
         , T2.INV_STRA_CATG_CODE                                                         AS INV_STRA_CATG_CODE                      --投资策略分类代码
         , T23.STD_DICT_CLS_CDVAL_DESC                                                   AS INV_STRA_CATG                           --投资策略分类
         , T2.OPEN_FREQ                                                                  AS OPEN_FREQ                               --开放频率
         , T2.NEXT_OPEN_ST_DATE                                                          AS RECT_OPEN_ST_DATE                       --最近开放开始日期
         , T2.NEXT_OPEN_END_DATE                                                         AS RECT_OPEN_END_DATE                      --最近开放结束日期
         , T1.PROD_CATG_CODE                                                             AS PROD_TYPE                               --产品类型代码
         , T6.PTY_NAME                                                                   AS INV_MNGR                                --投资经理
         , T7.PTY_NAME                                                                   AS PV_INV_MNGR                             --历任投资经理
         , T2.CURR_WARN_LINE                                                             AS WARN_LINE                               --预警线
         , T2.WARN_LINE_TYPE_CODE                                                        AS WARN_LINE_TYPE_CODE                     --预警线类型代码
         , T2.AT_WARN_LINE_MEAS                                                          AS AT_WARN_LINE_MEAS                       --到达预警线后措施
         , T12.THD                                                                       AS HIS_WARN_LINE                           --历史预警线
         , T12.END_DATE                                                                  AS WARN_LINE_ALTR_DATE                     --预警线变更日期
         , T2.STOP_LINE                                                                  AS STOP_LINE                               --止损线
         , T2.STOP_LINE_TYPE_CODE                                                        AS STOP_LINE_TYPE_CODE                     --止损线类型代码
         , T2.AT_STOP_LINE_MEAS                                                          AS AT_STOP_LINE_MEAS                       --到达止损线后措施
         , T13.THD                                                                       AS HIS_STOP_LINE                           --历史止损线
         , T13.END_DATE                                                                  AS STOP_LINE_ALTR_DATE                     --止损线变更日期
         , T18.PTY_NAME                                                                  AS INV_SUPT_TEAM                           --投资支持团队
         , T14.PTY_NAME                                                                  AS PROD_MNGR                               --产品经理
         , T2.1V1_INIT_CNOR                                                              AS 1V1_INIT_CNOR                           --一对一初始委托人
         , T2.1VN_INIT_CNOR_QTY                                                          AS 1VN_INIT_CNOR_QTY                       --一对多初始委托人数量
         , T2.CURR_MAG_FEER                                                              AS CURR_MAG_FEER                           --当前管理费率
         , T2.CURR_CUSTOD_FEER                                                           AS CURR_CUSTOD_FEER                        --当前托管费率
         , T2.CURR_SALE_FEER                                                             AS CURR_SALE_FEER                          --当前销售服务费率
         , T2.INV_OBJ_TYPE_CODE                                                          AS INV_ORNT_CODE                           --投资方向代码
         , T8.STD_DICT_CLS_CDVAL_DESC                                                    AS INV_ORNT_NAME                           --投资方向名称
         , T2.PROD_SINVD                                                                 AS PROD_SINVD                              --产品具体投向
         , T2.IS_ACCRUE_PERF_REMU                                                        AS IS_ACCRUE_PERF_REMU                     --是否计提业绩报酬
         , T2.ACCRUE_TIME_POI                                                            AS ACCRUE_TIME_POI                         --计提时点
         , T2.ACCRUE_BASI                                                                AS ACCRUE_BASI                             --计提基准
         , T2.ACCRUE_RATE                                                                AS ACCRUE_RATE                             --计提比例
         , T2.MAG_MODE_CODE                                                              AS MAG_MODE_CODE                           --管理方式代码
         , T9.STD_DICT_CLS_CDVAL_DESC                                                    AS MAG_MODE_NAME                           --管理方式名称
         , T2.YIELDISTR_MODE_CODE                                                        AS YIELDISTR_MODE_CODE                     --收益分配方式代码
         , T22.STD_DICT_CLS_CDVAL_DESC                                                   AS YIELDISTR_MODE                          --收益分配方式
         , T2.YIELDISTR_TIMES                                                            AS YIELDISTR_TIMES                         --收益分配次数
         , T1.RISK_LVL_CODE                                                              AS PROD_RISK_LVL_CODE                      --产品风险等级代码
         , T10.STD_DICT_CLS_CDVAL_DESC                                                   AS PROD_RISK_LVL_NAME                      --产品风险等级名称
         , T2.AML_RISK_LVL_CODE                                                          AS AML_RISK_LVL_CODE                       --反洗钱风险等级代码
         , T11.STD_DICT_CLS_CDVAL_DESC                                                   AS AML_RISK_LVL_NAME                       --反洗钱风险等级名称
         , T2.RISK_IDTY_EVT                                                              AS RISK_IDTY_EVT                           --风险识别事件
         , T1.INIT_UNIT_NAV                                                              AS INIT_UNIT_NAV                           --初始单位净值
         , T1.RAIS_AMT                                                                   AS RAIS_AMT                                --募集金额
         , T1.SETUP_SCALE                                                                AS SETUP_SCALE                             --成立规模(募集金额+利息)
         , T2.RISK_RES                                                                   AS RISK_RES                                --风险准备金
         , '1'                                                                           AS IS_NAV_PROD                             --是否净值型产品
         , CASE WHEN T2.INV_OBJ_CODE = '02'  
                THEN 1 
                ELSE 0 
           END                                                                           AS IS_CRRC_FUND_PROD                       --是否货币基金产品
         , '0'                                                                           AS IS_MRECN_FUND                           --是否互认基金
         , T2.IS_BANK_YIELDISTR                                                          AS IS_BANK_YIELDISTR                       --是否进行收益分配
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS LD_TIME                                 --加载时间
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')      AS MODIFY_TIME                             --修改时间
      FROM DWDXDAY.DWD_PROD_PROD_BASIC_INFO_PFD T1  --产品基本信息
      LEFT JOIN DWDXDAY.DWD_PROD_PROD_EXTN_INFO_PFD T2 --产品扩展信息
        ON T1.PROD_NUM = T2.PROD_NUM
       AND T2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
      LEFT JOIN DWDXDAY.DWD_PROD_PROD_SFAC_RELA_PFD T3 --产品套账关系
        ON T1.PROD_NUM = T3.PROD_NUM
       AND T3.VALID_FLAG = '1'
       AND T3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
      LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T4 --帐套编码映射
        ON T3.SFAC_NUM = T4.SFAC_NUM
       AND T4.VALID_FLAG = '1'
       AND T4.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
       AND T4.SSYS = 'HSFA'
      LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD T5 --帐套编码映射
        ON T3.SFAC_NUM = T5.SFAC_NUM
       AND T5.VALID_FLAG = '1'
       AND T5.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
       AND T5.SSYS = 'O32'
      LEFT JOIN (SELECT T6.PROD_NUM
                      , CONCAT_WS(',',COLLECT_SET(T6.PTY_NAME)) AS PTY_NAME
                   FROM DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD T6 --产品角色
                  WHERE T6.VALID_FLAG = '1'
                    AND T6.ROLE_TYPE_CODE = '04'  --投资经理
                    AND T6.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
                    GROUP BY T6.PROD_NUM
                 )T6
        ON T1.PROD_NUM = T6.PROD_NUM
      LEFT JOIN (SELECT T7.PROD_NUM
                      , CONCAT_WS(',',COLLECT_SET(T7.PTY_NAME)) AS PTY_NAME
                   FROM DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD T7 --产品角色
                  WHERE T7.VALID_FLAG = '0'
                    AND T7.ROLE_TYPE_CODE = '04'  --投资经理
                    AND T7.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
                    GROUP BY T7.PROD_NUM
                 )T7
        ON T1.PROD_NUM = T7.PROD_NUM
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T8 --标准字典分类枚举信息
        ON T2.INV_OBJ_TYPE_CODE = T8.STD_DICT_CLS_CDVAL
       AND T8.STD_DICT_CLS_CD = 'INV_OBJ_TYPE_CODE'
       AND T8.VALID_FLAG = '1'
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T9 --标准字典分类枚举信息
        ON T2.MAG_MODE_CODE = T9.STD_DICT_CLS_CDVAL
       AND T9.STD_DICT_CLS_CD = 'MAG_MODE_CODE'
       AND T9.VALID_FLAG = '1'
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T10 --标准字典分类枚举信息
        ON T1.RISK_LVL_CODE = T10.STD_DICT_CLS_CDVAL
       AND T10.STD_DICT_CLS_CD = 'RISK_LVL_CODE'
       AND T10.VALID_FLAG = '1'
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T11 --标准字典分类枚举信息
        ON T2.AML_RISK_LVL_CODE = T11.STD_DICT_CLS_CDVAL
       AND T11.STD_DICT_CLS_CD = 'RISK_LVL_CODE'
       AND T11.VALID_FLAG = '1'
      LEFT JOIN (SELECT T12.PROD_NUM
                      , T12.THD
                      , T12.ST_DATE
                      , T12.END_DATE
                      , ROW_NUMBER() OVER(PARTITION BY  T12.PROD_NUM ORDER BY  T12.END_DATE DESC) RN
                   FROM DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD T12 --产品预警历史信息
                  WHERE T12.VALID_FLAG = '0'
                    AND T12.THD_CATG_CODE = '1'        --预警线
                    AND T12.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
                )T12
        ON T1.PROD_NUM = T12.PROD_NUM
       AND T12.RN = 1
      LEFT JOIN (SELECT T13.PROD_NUM
                      , T13.THD
                      , T13.ST_DATE
                      , T13.END_DATE
                      , ROW_NUMBER() OVER(PARTITION BY  T13.PROD_NUM ORDER BY  T13.END_DATE DESC) RN
                   FROM DWDXDAY.DWD_PROD_PROD_WARN_HIS_INFO_PFD T13 --产品预警历史信息
                  WHERE T13.VALID_FLAG = '0'
                    AND T13.THD_CATG_CODE = '2'  --止损线
                    AND T13.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
                )T13
        ON T1.PROD_NUM = T13.PROD_NUM
       AND T13.RN = 1
      LEFT JOIN DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD T14 --产品角色
        ON T1.PROD_NUM = T14.PROD_NUM
       AND T14.VALID_FLAG = '1'
       AND T14.ROLE_TYPE_CODE = '01'  --产品经理
       AND T14.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
      LEFT JOIN DWDXDAY.DWD_PROD_SFAC_PROD_BASIC_INFO_PFD T15 --帐套产品基本信息
        ON T1.MAIN_PROD_CODE = T15.PROD_CODE
       AND T15.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T16 --标准字典分类枚举信息
        ON T2.RAIS_MODE_CODE = T16.STD_DICT_CLS_CDVAL
       AND T16.STD_DICT_CLS_CD = 'RAIS_MODE_CODE'
       AND T16.VALID_FLAG = '1'
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T17 --标准字典分类枚举信息
        ON T1.PROD_STAT_CODE = T17.STD_DICT_CLS_CDVAL
       AND T17.STD_DICT_CLS_CD = 'PROD_STAT_CODE'
       AND T17.VALID_FLAG = '1'
      LEFT JOIN (SELECT T18.PROD_NUM
                      , CONCAT_WS(',',COLLECT_SET(T18.PTY_NAME)) AS PTY_NAME
                   FROM DWDXDAY.DWD_PROD_PROD_ROLE_INFO_PFD T18 --产品角色
                  WHERE T18.VALID_FLAG = '1'
                    AND T18.ROLE_TYPE_CODE = '03'  --协助管理
                    AND T18.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1) --取最新日期
                    GROUP BY T18.PROD_NUM
                 )T18
        ON T1.PROD_NUM = T18.PROD_NUM
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T19 --标准字典分类枚举信息
        ON T2.INV_OBJ_TYPE_CODE = T19.STD_DICT_CLS_CDVAL
       AND T19.STD_DICT_CLS_CD = 'INV_OBJ_TYPE_CODE'
       AND T19.VALID_FLAG = '1'
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T20 --标准字典分类枚举信息
        ON T2.INV_OBJ_CODE = T20.STD_DICT_CLS_CDVAL
       AND T20.STD_DICT_CLS_CD = 'INV_OBJ_CODE'
       AND T20.VALID_FLAG = '1'
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T21 --标准字典分类枚举信息
        ON T2.TRAN_MKT_CODE = T21.STD_DICT_CLS_CDVAL
       AND T21.STD_DICT_CLS_CD = 'TRADE_MKT_CODE'
       AND T21.VALID_FLAG = '1'
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T22 --标准字典分类枚举信息
        ON T2.YIELDISTR_MODE_CODE = T22.STD_DICT_CLS_CDVAL
       AND T22.STD_DICT_CLS_CD = 'BONUS_MODE_CODE'
       AND T22.VALID_FLAG = '1' 
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CLS_EMRT_INFO T23 --标准字典分类枚举信息
        ON T2.INV_STRA_CATG_CODE = T23.STD_DICT_CLS_CDVAL
       AND T23.STD_DICT_CLS_CD = 'INV_STRA_CATG_CODE'
       AND T23.VALID_FLAG = '1' 
     WHERE T1.P_DT = '${p_end_dt}'
    ;
    "
