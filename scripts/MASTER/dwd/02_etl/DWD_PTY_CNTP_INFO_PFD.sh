#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题: 产品
-- ** 描述: 产品编码映射
-- ** 创建者 : hejl
-- ** 创建日期: 20230511
-- ** 修改日志:
-- ** 20230511，hejl，新建
-- ** 目标表：DWDXDAY.DWD_PTY_CNTP_INFO_PFD 交易对手方信息表
-- **         DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD 交易对手映射表
-- ** 源表：  DWDXDAY.DWD_PTY_CNTP_NUM_TTRADERIVAL_PTD_INT O32交易对手方表
-- **         DWDXDAY.DWD_PTY_CNTP_ORG_BASIC_INFO_PTD_INT 机构交易对手方表
-- **         DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP 交易对手方临时表
-- **         DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP 新增交易对手方临时表
-- **         DWDXDAY.DWD_PTY_CNTP_INFO_PFD_TMP  交易对手方临时表
-- **************************************************************************
set hive.mapred.mode = nonstrict;
set hive.strict.checks.type.safety=false;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set hive.exec.reducers.bytes.per.reducer=10240000000; 
set mapreduce.job.reduces=3;

DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_CNTP_INFO_TMP;
CREATE TABLE DWDXDAY.DWD_PTY_CNTP_INFO_TMP(
CNTP_NUM                    STRING            COMMENT  '交易对手方编码',
CNTP_NAME                   STRING            COMMENT  '交易对手方名称',
CNTP_FNAME                  STRING            COMMENT  '交易对手方全称',
CNTP_CATG                   STRING            COMMENT  '交易对手方分类',
CNTP_TYPE                   STRING            COMMENT  '交易对手方类型',
ORG_NUM                     STRING            COMMENT  '机构编码',
UNIF_SOCI_CREDIT_CODE       STRING            COMMENT  '统一社会信用代码',
IS_ORG                      STRING            COMMENT  '是否机构',
INR_RAT                     STRING            COMMENT  '内部评级',
EXT_RAT                     STRING            COMMENT  '外部评级',
SYN_RAT                     STRING            COMMENT  '综合评级',
ADDR                        STRING            COMMENT  '地址',
CONP                        STRING            COMMENT  '联系人',
PHONE                       STRING            COMMENT  '联系电话',
FAX                         STRING            COMMENT  '传真',
STAT                        STRING            COMMENT  '状态',
BANK_ACCT                   STRING            COMMENT  '银行总行',
BANK_HEADOFF                DECIMAL(30,8)     COMMENT  '资本金',
CAPITAL_AMT                 DECIMAL(30,8)     COMMENT  '总资产',
TOT_AST                     DECIMAL(30,8)     COMMENT  '净资产',
NET_AST                     STRING            COMMENT  '银行账户',
SSYS                        STRING            COMMENT  '源系统',
SOURCE_TAB                  STRING            COMMENT  '源表',
LD_TIME                     STRING            COMMENT  '加载时间',
MODIFY_TIME                 STRING            COMMENT  '修改时间'
)COMMENT '新增交易对手方临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';
 
INSERT INTO TABLE DWDXDAY.DWD_PTY_CNTP_INFO_TMP
SELECT DISTINCT A2.CNTP_NUM                                                    AS CNTP_NUM                      --交易对手方编码
   , A1.VC_NAME                                                                AS CNTP_NAME                     --交易对手方名称
   , A1.VC_ALL_NAME                                                            AS CNTP_FNAME                    --交易对手方全称
   , A3.STD_DICT_CLS_CD_VAL                                                    AS CNTP_CATG                     --交易对手方分类
   , A4.STD_DICT_CLS_CD_VAL                                                    AS CNTP_TYPE                     --交易对手方类型
   , A8.ORG_NUM                                                                AS ORG_NUM                       --机构编码
   , NULL                                                                      AS UNIF_SOCI_CREDIT_CODE         --统一社会信用代码
   , (CASE WHEN A8.ORG_NUM IS NULL THEN 0 ELSE 1 END)                          AS IS_ORG                        --是否机构
   , A5.STD_DICT_CLS_CD_VAL                                                    AS INR_RAT                       --内部评级
   , A6.STD_DICT_CLS_CD_VAL                                                    AS EXT_RAT                       --外部评级
   , A7.STD_DICT_CLS_CD_VAL                                                    AS SYN_RAT                       --综合评级
   , A1.VC_ADDRESS                                                             AS ADDR                          --地址
   , A1.VC_LINKMAN                                                             AS CONP                          --联系人
   , A1.VC_PHONE                                                               AS PHONE                         --联系电话
   , A1.VC_FAX                                                                 AS FAX                           --传真
   , A1.C_STATUS                                                               AS STAT                          --状态
   , A1.L_BANKHEAD_ID                                                          AS BANK_ACCT                     --银行总行
   , A1.EN_CAPITAL                                                             AS BANK_HEADOFF                  --资本金
   , A1.EN_TOTAL_ASSET                                                         AS CAPITAL_AMT                   --总资产
   , A1.EN_NET_ASSET                                                           AS TOT_AST                       --净资产
   , A1.VC_BANK_ACCOUNT                                                        AS NET_AST                       --银行账户
   , 'O32'                                                                     AS SSYS                          --源系统
   , 'ODS_O32_TTRADERIVAL_PFD'                                                 AS SOURCE_TAB                    --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME                       --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME                   --修改时间 
     FROM ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD A1  --交易对手表
     LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP A2  --新增交易对手方临时表
       ON A1.L_RIVAL_ID = A2.CNTP_NO 
      AND A1.VC_ALL_NAME = A2.CNTP_NAME 
      AND A2.ST_DATE <= '${P_BATCH_DT}'   
      AND A2.END_DATE > '${P_BATCH_DT}'   
      AND A2.SSYS='O32' 
      AND A2.SRC_TAB = 'ODS_O32_TTRADERIVAL_PFD'  
      AND A2.VALID_FLAG = '1' 
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典码值映射表
       ON A1.C_TRADE_CLASS = A3.SRC_DICT_CLS_CDVAL
      AND A3.SSYS= 'O32'
      AND A3.SRC_DICT_CLS_CD= 'C_TRADE_CLASS' 
      AND A3.VALID_FLAG='1'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A4  --标准字典码值映射表
       ON  A1.C_RIVAL_TYPE = A4.SRC_DICT_CLS_CDVAL 
      AND A4.SSYS= 'O32'
      AND A4.SRC_DICT_CLS_CD= 'C_RIVAL_TYPE'
      AND A4.VALID_FLAG='1'
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD A8   --机构编码映射表
       ON A1.VC_RIVAL_CODE=A8.ORG_INCD 
      AND A8.ST_DATE <= '${P_BATCH_DT}'    
      AND A8.END_DATE > '${P_BATCH_DT}'    
      AND A8.SSYS='O32'     
      AND A8.SRC_TAB = 'ODS_O32_TTRADERIVAL_PFD' 
      AND A8.VALID_FLAG = '1'   
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5  --标准字典码值映射表
       ON A1.C_OUTER_APPRAISE= A5.SRC_DICT_CLS_CDVAL 
      AND A5.SSYS= 'O32'
      AND A5.SRC_DICT_CLS_CD= 'C_OUTER_APPRAISE'
      AND A5.VALID_FLAG='1'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A6  --标准字典码值映射表
       ON A1.C_INSIDE_APPRAISE = A6.SRC_DICT_CLS_CDVAL 
      AND A6.SSYS= 'O32'
      AND A6.SRC_DICT_CLS_CD= 'C_INSIDE_APPRAISE'
      AND A6.VALID_FLAG='1'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A7   --标准字典码值映射表
       ON A7.SSYS= 'O32'
      AND A7.SRC_DICT_CLS_CD= 'C_APPRAISE'
      AND A1.C_APPRAISE = A7.SRC_DICT_CLS_CDVAL 
      AND A7.VALID_FLAG='1'
     WHERE SUBSTR(A1.VC_TIMESTAMP,1,8)= '${P_BATCH_DT}' 
       AND (A1.EN_CAPITAL= '0' OR A1.EN_CAPITAL IS NULL )
       AND A2.SRC_TAB = 'ODS_O32_TTRADERIVAL_PFD'
       AND A1.P_DT ='${P_BATCH_DT}'  ;

INSERT INTO TABLE DWDXDAY.DWD_PTY_CNTP_INFO_TMP
SELECT DISTINCT A2.CNTP_NUM                                                              AS CNTP_NUM                      --交易对手方编码
   , A1.ORG_SNAME                                                               AS CNTP_NAME                     --交易对手方名称
   , A1.ORG_NAME                                                                AS CNTP_FNAME                    --交易对手方全称
   , '1'                                                                        AS CNTP_CATG                     --交易对手方分类
   , A3.STD_DICT_CLS_CD_VAL                                                     AS CNTP_TYPE                     --交易对手方类型
   , A1.ORG_NUM                                                                 AS ORG_NUM                       --机构编码
   , A1.UNIF_SOCI_CREDIT_CODE                                                   AS UNIF_SOCI_CREDIT_CODE         --统一社会信用代码
   , '1'                                                                        AS IS_ORG                        --是否机构
   , NULL                                                                       AS INR_RAT                       --内部评级
   , NULL                                                                       AS EXT_RAT                       --外部评级
   , NULL                                                                       AS SYN_RAT                       --综合评级
   , A1.OFFI_ADDR                                                               AS ADDR                          --地址
   , NULL                                                                       AS CONP                          --联系人
   , A1.PHONE                                                                   AS PHONE                         --联系电话
   , A1.FAX                                                                     AS FAX                           --传真
   , NULL                                                                       AS STAT                          --状态
   , NULL                                                                       AS BANK_ACCT                     --银行总行
   , NULL                                                                       AS BANK_HEADOFF                  --资本金
   , A1.REG_CAPITAL                                                             AS CAPITAL_AMT                   --总资产
   , NULL                                                                       AS TOT_AST                       --净资产
   , NULL                                                                       AS NET_AST                       --银行账户
   , 'DWD'                                                                      AS SSYS                          --源系统
   , 'DWD_PTY_ORG_BASIC_INFO_PFD'                                               AS SOURCE_TAB                    --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME                       --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME                   --修改时间 
     FROM DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD A1  --机构信息表
     INNER JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP A2  --新增交易对手方临时表
       ON A1.ORG_NUM = A2.CNTP_NO
      AND A1.ORG_NAME = A2.CNTP_NAME 
      AND A2.ST_DATE <= '${P_BATCH_DT}'    
      AND A2.END_DATE > '${P_BATCH_DT}'    
      AND A2.SSYS='DWD'    
      AND A2.SRC_TAB = 'DWD_PTY_ORG_BASIC_INFO_PFD'  
      AND A2.VALID_FLAG = '1' 
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3   --标准字典码值映射表
       ON A1.ORG_CATG = A3.SRC_DICT_CLS_CDVAL
      AND A3.SSYS= 'DWD'
      AND A3.SRC_DICT_CLS_CD= 'ORG_CATG'
      AND A3.VALID_FLAG='1'
     WHERE REPLACE(SUBSTR(A1.MODIFY_TIME ,1,10),'-','') = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),-1),'yyyyMMdd')
       AND A2.CNTP_NUM IS NOT NULL ;

INSERT INTO TABLE DWDXDAY.DWD_PTY_CNTP_INFO_TMP
SELECT DISTINCT A2.CNTP_NUM                                                   AS CNTP_NUM              --交易对手方编码
   , A1.VC_BANK_NAME                                                          AS CNTP_NAME             --交易对手方名称
   , A1.VC_BANK_NAME                                                          AS CNTP_FNAME            --交易对手方全称
   , '103'                                                                    AS CNTP_CATG             --交易对手方分类
   , '1'                                                                      AS CNTP_TYPE             --交易对手方类型
   , NULL                                                                     AS ORG_NUM               --机构编码
   , NULL                                                                     AS UNIF_SOCI_CREDIT_CODE --统一社会信用代码
   , '1'                                                                      AS IS_ORG                --是否机构
   , A5.STD_DICT_CLS_CD_VAL                                                   AS INR_RAT               --内部评级
   , A6.STD_DICT_CLS_CD_VAL                                                   AS EXT_RAT               --外部评级
   , NULL                                                                     AS SYN_RAT               --综合评级
   , NULL                                                                     AS ADDR                  --地址
   , NULL                                                                     AS CONP                  --联系人
   , NULL                                                                     AS PHONE                 --联系电话
   , NULL                                                                     AS FAX                   --传真
   , NULL                                                                     AS STAT                  --状态
   , NULL                                                                     AS BANK_ACCT             --银行总行
   , NULL                                                                     AS BANK_HEADOFF          --资本金
   , NULL                                                                     AS CAPITAL_AMT           --总资产
   , NULL                                                                     AS TOT_AST               --净资产
   , NULL                                                                     AS NET_AST               --银行账户
   , 'O32'                                                                    AS SSYS                  --源系统
   , 'ODS_O32_TBANKINFO_PFD'                                                  AS SOURCE_TAB            --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME               --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME           --修改时间
    FROM ODS_XDAY_O32.ODS_O32_TBANKINFO_PFD A1  --银行信息
    LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP A2
    ON A1.VC_BANK_NAME = A2.CNTP_NAME
    AND A2.ST_DATE <= FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyyMMdd')    -- 开始日期
    AND A2.END_DATE > FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyyMMdd')    -- 结束日期
    AND A2.SSYS='O32'     -- 源系统
    AND A2.SRC_TAB = 'ODS_O32_TBANKINFO_PFD'  -- 源表
    AND A2.VALID_FLAG = '1'   -- 有效
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5
    ON A1.C_OUTER_APPRAISE= A5.SRC_DICT_CLS_CDVAL 
    AND A5.SSYS= 'O32'
    AND A5.SRC_DICT_CLS_CD= 'C_OUTER_APPRAISE'
    AND A5.VALID_FLAG='1'
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A6
    ON A1.C_INSIDE_APPRAISE = A6.SRC_DICT_CLS_CDVAL 
    AND A6.SSYS= 'O32'
    AND A6.SRC_DICT_CLS_CD= 'C_INSIDE_APPRAISE'
    AND A6.VALID_FLAG='1'
    WHERE A2.SRC_TAB = 'ODS_O32_TBANKINFO_PFD' 
    AND SUBSTR(A1.VC_TIMESTAMP,1,8)= '${P_BATCH_DT}' 
    AND A1.P_DT = '${P_BATCH_DT}'  ;

DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_CNTP_INFO_PFD_TMP;
CREATE TABLE DWDXDAY.DWD_PTY_CNTP_INFO_PFD_TMP(
CNTP_NUM                    STRING     COMMENT  '交易对手方编码',
CNTP_NAME                   STRING     COMMENT  '交易对手方名称',
CNTP_FNAME                  STRING     COMMENT  '交易对手方全称',
CNTP_CATG                   STRING     COMMENT  '交易对手方分类',
CNTP_TYPE                   STRING     COMMENT  '交易对手方类型',
ORG_NUM                     STRING     COMMENT  '机构编码',
UNIF_SOCI_CREDIT_CODE       STRING     COMMENT  '统一社会信用代码',
IS_ORG                      STRING     COMMENT  '是否机构',
INR_RAT                     STRING     COMMENT  '内部评级',
EXT_RAT                     STRING     COMMENT  '外部评级',
SYN_RAT                     STRING     COMMENT  '综合评级',
ADDR                        STRING     COMMENT  '地址',
CONP                        STRING     COMMENT  '联系人',
PHONE                       STRING     COMMENT  '联系电话',
FAX                         STRING     COMMENT  '传真',
STAT                        STRING     COMMENT  '状态',
BANK_ACCT                   STRING     COMMENT  '银行总行',
BANK_HEADOFF                DECIMAL(30,8)     COMMENT  '资本金',
CAPITAL_AMT                 DECIMAL(30,8)     COMMENT  '总资产',
TOT_AST                     DECIMAL(30,8)     COMMENT  '净资产',
NET_AST                     STRING     COMMENT  '银行账户',
SSYS                        STRING     COMMENT  '源系统',
SOURCE_TAB                  STRING     COMMENT  '源表',
LD_TIME                     STRING     COMMENT  '加载时间',
MODIFY_TIME                 STRING     COMMENT  '修改时间'
)COMMENT '交易对手方临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_INFO_PFD_TMP
SELECT DISTINCT COALESCE ( B1.CNTP_NUM,A1.CNTP_NUM)                         AS CNTP_NUM                    --交易对手方编码
   , COALESCE ( A1.CNTP_NAME ,B1.CNTP_NAME)                        AS CNTP_NAME                   --交易对手方名称
   , COALESCE ( B1.CNTP_FNAME,A1.CNTP_FNAME)                       AS CNTP_FNAME                  --交易对手方全称
   , COALESCE ( A1.CNTP_CATG,B1.CNTP_CATG)                         AS CNTP_CATG                   --交易对手方分类
   , COALESCE ( A1.CNTP_TYPE,B1.CNTP_TYPE)                         AS CNTP_TYPE                   --交易对手方类型
   , COALESCE ( A1.ORG_NUM ,B1.ORG_NUM )                           AS ORG_NUM                     --机构编码
   , COALESCE ( A1.UNIF_SOCI_CREDIT_CODE,B1.UNIF_SOCI_CREDIT_CODE) AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
   , COALESCE ( A1.IS_ORG, B1.IS_ORG)                              AS IS_ORG                      --是否机构
   , COALESCE ( A1.INR_RAT, B1.INR_RAT )                           AS INR_RAT                     --内部评级
   , COALESCE ( A1.EXT_RAT, B1.EXT_RAT )                           AS EXT_RAT                     --外部评级
   , COALESCE ( A1.SYN_RAT , B1.SYN_RAT)                           AS SYN_RAT                     --综合评级
   , COALESCE ( A1.ADDR,B1.ADDR)                                   AS ADDR                        --地址
   , COALESCE ( A1.CONP,B1.CONP )                                  AS CONP                        --联系人
   , COALESCE ( A1.PHONE,B1.PHONE)                                 AS PHONE                       --联系电话
   , COALESCE ( A1.FAX , B1.FAX)                                   AS FAX                         --传真
   , COALESCE ( A1.STAT,B1. STAT)                                  AS STAT                        --状态
   , COALESCE ( A1.BANK_ACCT ,B1.BANK_ACCT)                        AS BANK_ACCT                   --银行总行
   , COALESCE ( A1.BANK_HEADOFF,B1.BANK_HEADOFF)                   AS BANK_HEADOFF                --资本金
   , COALESCE ( A1.CAPITAL_AMT, B1.CAPITAL_AMT)                    AS CAPITAL_AMT                 --总资产
   , COALESCE ( A1.TOT_AST,B1.TOT_AST)                             AS TOT_AST                     --净资产
   , COALESCE ( A1.NET_AST ,B1.NET_AST)                            AS NET_AST                     --银行账户
   , COALESCE ( A1.SSYS ,B1.SSYS )                                 AS SSYS                        --源系统
   , COALESCE ( A1.SOURCE_TAB,B1.SOURCE_TAB)                       AS SOURCE_TAB                  --源表
   , COALESCE ( A1.LD_TIME,B1.LD_TIME )                            AS LD_TIME                     --加载时间
   , COALESCE ( A1.MODIFY_TIME,B1.MODIFY_TIME)                     AS MODIFY_TIME                 --修改时间 
     FROM DWDXDAY.DWD_PTY_CNTP_INFO_TMP A1  --新增交易对手方临时表
     FULL JOIN  
     (SELECT CNTP_NUM                           AS CNTP_NUM                    --交易对手方编码
         , CNTP_NAME                           AS CNTP_NAME                   --交易对手方名称
         , CNTP_FNAME                          AS CNTP_FNAME                  --交易对手方全称
         , CNTP_CATG                           AS CNTP_CATG                   --交易对手方分类
         , CNTP_TYPE                           AS CNTP_TYPE                   --交易对手方类型
         , ORG_NUM                             AS ORG_NUM                     --机构编码
         , UNIF_SOCI_CREDIT_CODE               AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
         , IS_ORG                              AS IS_ORG                      --是否机构
         , INR_RAT                             AS INR_RAT                     --内部评级
         , EXT_RAT                             AS EXT_RAT                     --外部评级
         , SYN_RAT                             AS SYN_RAT                     --综合评级
         , ADDR                                AS ADDR                        --地址
         , CONP                                AS CONP                        --联系人
         , PHONE                               AS PHONE                       --联系电话
         , FAX                                 AS FAX                         --传真
         , STAT                                AS STAT                        --状态
         , BANK_ACCT                           AS BANK_ACCT                   --银行总行
         , BANK_HEADOFF                        AS BANK_HEADOFF                --资本金
         , CAPITAL_AMT                         AS CAPITAL_AMT                 --总资产
         , TOT_AST                             AS TOT_AST                     --净资产
         , NET_AST                             AS NET_AST                     --银行账户
         , SSYS                                AS SSYS                        --源系统
         , SOURCE_TAB                          AS SOURCE_TAB                  --源表
         , LD_TIME                             AS LD_TIME                     --加载时间
         , MODIFY_TIME                         AS MODIFY_TIME                 --修改时间 
           FROM  DWDXDAY.DWD_PTY_CNTP_INFO_PFD ) B1 --交易对手方信息表 
       ON B1.CNTP_FNAME = A1.CNTP_FNAME;


INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_INFO_PFD
SELECT A1.CNTP_NUM                           AS CNTP_NUM                    --交易对手方编码
    , A1.CNTP_NAME                           AS CNTP_NAME                   --交易对手方名称
    , A1.CNTP_FNAME                          AS CNTP_FNAME                  --交易对手方全称
    , A1.CNTP_CATG                           AS CNTP_CATG                   --交易对手方分类
    , A1.CNTP_TYPE                           AS CNTP_TYPE                   --交易对手方类型
    , A1.ORG_NUM                             AS ORG_NUM                     --机构编码
    , A1.UNIF_SOCI_CREDIT_CODE               AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
    , A1.IS_ORG                              AS IS_ORG                      --是否机构
    , A1.INR_RAT                             AS INR_RAT                     --内部评级
    , A1.EXT_RAT                             AS EXT_RAT                     --外部评级
    , A1.SYN_RAT                             AS SYN_RAT                     --综合评级
    , A1.ADDR                                AS ADDR                        --地址
    , A1.CONP                                AS CONP                        --联系人
    , A1.PHONE                               AS PHONE                       --联系电话
    , A1.FAX                                 AS FAX                         --传真
    , A1.STAT                                AS STAT                        --状态
    , A1.BANK_ACCT                           AS BANK_ACCT                   --银行总行
    , A1.BANK_HEADOFF                        AS BANK_HEADOFF                --资本金
    , A1.CAPITAL_AMT                         AS CAPITAL_AMT                 --总资产
    , A1.TOT_AST                             AS TOT_AST                     --净资产
    , A1.NET_AST                             AS NET_AST                     --银行账户
    , A1.SSYS                                AS SSYS                        --源系统
    , A1.SOURCE_TAB                          AS SOURCE_TAB                  --源表
    , A1.LD_TIME                             AS LD_TIME                     --加载时间
    , A1.MODIFY_TIME                         AS MODIFY_TIME                 --修改时间 
      FROM  DWDXDAY.DWD_PTY_CNTP_INFO_PFD_TMP A1;  --交易对手方临时表
"
