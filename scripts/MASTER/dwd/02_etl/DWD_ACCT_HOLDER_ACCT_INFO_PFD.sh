#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题: 账户
-- ** 描述: 股东账户信息
-- ** 创建者 : hejl
-- ** 创建日期: 20230516
-- ** 修改日志:
-- ** 20230516，hejl，新建
-- ** 目标表：DWDXDAY.DWD_ACCT_HOLDER_ACCT_INFO_PFD 股东账户信息表
-- **         
-- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TGDZTDY_PFD     股东设置表
-- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP     标准字典码值映射表
-- **         ODS_XDAY_O32.ODS_O32_TSTOCKHOLDER_PFD   股东信息表 
-- **         DWDXDAY.DWD_ACCT_HOLDER_ACCT_INFO_PFD_TMP  股东账户信息临时表
-- **************************************************************************

set hive.strict.checks.type.safety=false;
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
set hive.exec.reducers.bytes.per.reducer=10240000000; 
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_HOLDER_ACCT_INFO_PFD_TMP
SELECT COALESCE( T1.HOLDER_ACCT_CODE,T2.HOLDER_ACCT_CODE)       AS HOLDER_ACCT_CODE    --股东账户代码
   , COALESCE( T1.TRAN_MKT,T2.TRAN_MKT )                        AS TRAN_MKT            --交易市场
   , COALESCE( T1.HOLDER_ACCT_NAME ,T2.HOLDER_ACCT_NAME )       AS HOLDER_ACCT_NAME    --股东账户名称
   , COALESCE( T1.HOLDER_ACCT_TYPE,T2.HOLDER_ACCT_TYPE)         AS HOLDER_ACCT_TYPE    --股东账户类型
   , COALESCE( T1.ACCT_STAT,T2.ACCT_STAT)                       AS ACCT_STAT           --账户状态
   , COALESCE( T1.ACCT_PROP_NORM ,T2.ACCT_PROP_NORM)            AS ACCT_PROP_NORM      --账户属性(普通、套保)
   , COALESCE( T1.OPEN_DATE ,T2.OPEN_DATE)                      AS OPEN_DATE           --开户日期
   , COALESCE( T1.OPEN_ORG ,T2.OPEN_ORG)                        AS OPEN_ORG            --开户机构
   , COALESCE( T1.MODIFY_DATE ,T2.MODIFY_DATE )                 AS MODIFY_DATE         --修改日期
   , COALESCE( T1.CLOS_DATE , T2.CLOS_DATE)                     AS CLOS_DATE           --销户日期
   , COALESCE( T1.FUND_CODE ,T2.FUND_CODE)                      AS FUND_CODE           --基金代码
   , COALESCE( T1.SFAC_NO ,T2.SFAC_NO)                          AS SFAC_NO             --账套编号
   , COALESCE( T1.INV_TYPE ,T2.INV_TYPE)                        AS INV_TYPE            --投资类型
   , COALESCE( T1.SEAT_TYPE ,T2.SEAT_TYPE)                      AS SEAT_TYPE           --席位类型
   , COALESCE( T1.SEAT_CODE, T2.SEAT_CODE)                      AS SEAT_CODE           --席位代码
   , COALESCE( T1.CPTL_ACCT_NUM,T2.CPTL_ACCT_NUM )              AS CPTL_ACCT_NUM       --资金账户编码
   , COALESCE( T1.SSYS,  T2.SSYS)                               AS SSYS                --源系统
   , COALESCE( T1.SOURCE_TAB ,T2.SOURCE_TAB)                    AS SOURCE_TAB          --源表
   , COALESCE( T1.LD_TIME ,T2.LD_TIME )                         AS LD_TIME             --加载时间
   , COALESCE( T1.MODIFY_TIME ,T2.MODIFY_TIME)                  AS MODIFY_TIME         --修改时间
     FROM
     (SELECT A1.VC_GDDM                                                               AS HOLDER_ACCT_CODE    --股东账户代码
         , A5.STD_DICT_CLS_CD_VAL                                                     AS TRAN_MKT            --交易市场
         , A1.VC_GDMC                                                                 AS HOLDER_ACCT_NAME    --股东账户名称
         , '0'                                                                        AS HOLDER_ACCT_TYPE    --股东账户类型
         , A1.C_STOCKHOLDER_STATUS                                                    AS ACCT_STAT           --账户状态
         , A2.STD_DICT_CLS_CD_VAL                                                     AS ACCT_PROP_NORM      --账户属性(普通、套保)
         , A1.D_SYNCHRO_TIME                                                          AS OPEN_DATE           --开户日期
         , A1.VC_QSBH                                                                 AS OPEN_ORG            --开户机构
         , NULL                                                                       AS MODIFY_DATE         --修改日期
         , NULL                                                                       AS CLOS_DATE           --销户日期
         , A1.VC_FUNDCODE                                                             AS FUND_CODE           --基金代码
         , A1.L_ZTBH                                                                  AS SFAC_NO             --账套编号
         , A3.STD_DICT_CLS_CD_VAL                                                     AS INV_TYPE            --投资类型
         , A4.STD_DICT_CLS_CD_VAL                                                     AS SEAT_TYPE           --席位类型
         , NULL                                                                       AS SEAT_CODE           --席位代码
         , A1.VC_ZJZH                                                                 AS CPTL_ACCT_NUM       --资金账户编码
         , 'HSFA'                                                                     AS SSYS                --源系统
         , 'ODS_HSFA_TGDZTDY_PFD'                                                     AS SOURCE_TAB          --源表
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME             --加载时间
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME         --修改时间
           FROM 
             (SELECT  VC_GDDM                                                               AS VC_GDDM    --股东账户代码
                  , ROW_NUMBER() OVER (PARTITION BY VC_GDDM ORDER BY D_SYNCHRO_TIME)        AS RN 
                  , VC_GDMC                                                                 AS VC_GDMC                 --股东账户名称
                  , C_STOCKHOLDER_STATUS                                                    AS C_STOCKHOLDER_STATUS    --账户状态
                  , D_SYNCHRO_TIME                                                          AS D_SYNCHRO_TIME          --开户日期
                  , VC_QSBH                                                                 AS VC_QSBH                 --开户机构
                  , VC_FUNDCODE                                                             AS VC_FUNDCODE             --基金代码
                  , L_ZTBH                                                                  AS L_ZTBH                  --账套编号
                  , VC_ZJZH                                                                 AS VC_ZJZH                 --资金账户编码
                  , L_SCLB                                                                  AS L_SCLB 
                  , L_TQBZ                                                                  AS L_TQBZ 
                  , L_TZLX                                                                  AS L_TZLX
                  , C_XWLX                                                                  AS C_XWLX 
                    FROM ODS_XDAY_HSFA.ODS_HSFA_TGDZTDY_PFD   
                    WHERE P_DT = '${P_BATCH_DT}'
                      AND VC_GDDM <> '任意' ) A1  --股东设置表
           LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5  --标准字典码值映射表
            ON A1.L_SCLB = A5.SRC_DICT_CLS_CDVAL 
           AND A5.VALID_FLAG='1'
           AND A5.SSYS= 'HSFA'
           AND A5.SRC_DICT_CLS_CD= 'L_SCLB'
           LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A2  --标准字典码值映射表
            ON A1.L_TQBZ = A2.SRC_DICT_CLS_CDVAL 
           AND A2.VALID_FLAG='1'
           AND A2.SSYS= 'HSFA'
           AND A2.SRC_DICT_CLS_CD= 'L_TQBZ'
           LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典码值映射表
           ON A1.L_TZLX = A3.SRC_DICT_CLS_CDVAL 
           AND A3.VALID_FLAG='1'
           AND A3.SSYS= 'HSFA'
           AND A3.SRC_DICT_CLS_CD= 'L_TZLX'
           LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A4   --标准字典码值映射表
            ON A1.C_XWLX = A4.SRC_DICT_CLS_CDVAL 
           AND A4.VALID_FLAG='1'
           AND A4.SSYS= 'HSFA'
           AND A4.SRC_DICT_CLS_CD= 'C_XWLX'
           WHERE A1.RN =1 ) T1
     FULL JOIN 
     (SELECT B1.VC_STOCKHOLDER_ID                                                     AS HOLDER_ACCT_CODE    --股东账户代码
         , B5.STD_DICT_CLS_CD_VAL                                                     AS TRAN_MKT            --交易市场
         , B1.VC_STOCKHOLDER_NAME                                                     AS HOLDER_ACCT_NAME    --股东账户名称
         , B1.C_CREDIT_STOCKHOLDER                                                    AS HOLDER_ACCT_TYPE    --股东账户类型
         , B1.C_STOCKHOLDER_STATUS                                                    AS ACCT_STAT           --账户状态
         , B2.STD_DICT_CLS_CD_VAL                                                     AS ACCT_PROP_NORM      --账户属性(普通、套保)
         , B1.L_OPEN_DATE                                                             AS OPEN_DATE           --开户日期
         , B1.L_ORG_ID                                                                AS OPEN_ORG            --开户机构
         , B1.L_MODIFY_DATE                                                           AS MODIFY_DATE         --修改日期
         , NULL                                                                       AS CLOS_DATE           --销户日期
         , B1.VC_FUND_IDS                                                             AS FUND_CODE           --基金代码
         , NULL                                                                       AS SFAC_NO             --账套编号
         , NULL                                                                       AS INV_TYPE            --投资类型
         , '0'                                                                        AS SEAT_TYPE           --席位类型
         , B1.VC_BIND_SEAT                                                            AS SEAT_CODE           --席位代码
         , NULL                                                                       AS CPTL_ACCT_NUM       --资金账户编码
         , 'O32'                                                                      AS SSYS                --源系统
         , 'ODS_O32_TSTOCKHOLDER_PFD'                                                 AS SOURCE_TAB          --源表
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME             --加载时间
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME         --修改时间
           FROM 
             (SELECT VC_STOCKHOLDER_ID                                                           AS VC_STOCKHOLDER_ID    --股东账户代码
                 , ROW_NUMBER() OVER(PARTITION BY VC_STOCKHOLDER_ID ORDER BY L_OPEN_DATE)  AS RN                     --排序 
                 , VC_STOCKHOLDER_NAME                                                     AS VC_STOCKHOLDER_NAME      --股东账户名称
                 , C_CREDIT_STOCKHOLDER                                                    AS C_CREDIT_STOCKHOLDER     --股东账户类型
                 , C_STOCKHOLDER_STATUS                                                    AS C_STOCKHOLDER_STATUS     --账户状态
                 , L_OPEN_DATE                                                             AS L_OPEN_DATE              --开户日期
                 , L_ORG_ID                                                                AS L_ORG_ID                 --开户机构
                 , L_MODIFY_DATE                                                           AS L_MODIFY_DATE            --修改日期
                 , VC_FUND_IDS                                                             AS VC_FUND_IDS              --基金代码
                 , VC_BIND_SEAT                                                            AS VC_BIND_SEAT             --席位代码
                 , C_MARKET_NO 
                 , C_INVEST_TYPE 
                   FROM ODS_XDAY_O32.ODS_O32_TSTOCKHOLDER_PFD    
                   WHERE P_DT = '${P_BATCH_DT}' ) B1 --股东信息表
           LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP B5  --标准字典码值映射表
             ON B1.C_MARKET_NO = B5.SRC_DICT_CLS_CDVAL 
            AND B5.VALID_FLAG='1'
            AND B5.SSYS= 'O32'
            AND B5.SRC_DICT_CLS_CD= 'C_MARKET_NO'
           LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP B2  --标准字典码值映射表
             ON B1.C_INVEST_TYPE = B2.SRC_DICT_CLS_CDVAL 
            AND B2.SSYS= 'O32'
            AND B2.SRC_DICT_CLS_CD= 'C_INVEST_TYPE'
            AND B2.VALID_FLAG='1'
           WHERE B1.RN = '1' ) T2
     ON T1.HOLDER_ACCT_CODE = T2.HOLDER_ACCT_CODE ;  --股东账户代码

INSERT OVERWRITE TABLE DWDXDAY.DWD_ACCT_HOLDER_ACCT_INFO_PFD PARTITION ( P_DT = '${P_BATCH_DT}')
SELECT A1.HOLDER_ACCT_CODE            AS HOLDER_ACCT_CODE    --股东账户代码
   , A1.TRAN_MKT                      AS TRAN_MKT            --交易市场
   , A1.HOLDER_ACCT_NAME              AS HOLDER_ACCT_NAME    --股东账户名称
   , A1.HOLDER_ACCT_TYPE              AS HOLDER_ACCT_TYPE    --股东账户类型
   , A1.ACCT_STAT                     AS ACCT_STAT           --账户状态
   , A1.ACCT_PROP_NORM                AS ACCT_PROP_NORM      --账户属性(普通、套保)
   , A1.OPEN_DATE                     AS OPEN_DATE           --开户日期
   , A1.OPEN_ORG                      AS OPEN_ORG            --开户机构
   , A1.MODIFY_DATE                   AS MODIFY_DATE         --修改日期
   , A1.CLOS_DATE                     AS CLOS_DATE           --销户日期
   , A1.FUND_CODE                     AS FUND_CODE           --基金代码
   , A1.SFAC_NO                       AS SFAC_NO             --账套编号
   , A1.INV_TYPE                      AS INV_TYPE            --投资类型
   , A1.SEAT_TYPE                     AS SEAT_TYPE           --席位类型
   , A1.SEAT_CODE                     AS SEAT_CODE           --席位代码
   , A1.CPTL_ACCT_NUM                 AS CPTL_ACCT_NUM       --资金账户编码
   , A1.SSYS                          AS SSYS                --源系统
   , A1.SOURCE_TAB                    AS SOURCE_TAB          --源表
   , A1.LD_TIME                       AS LD_TIME             --加载时间
   , A1.MODIFY_TIME                   AS MODIFY_TIME         --修改时间
     FROM  DWDXDAY.DWD_ACCT_HOLDER_ACCT_INFO_PFD_TMP A1 ;    --股东账户信息临时表
"
