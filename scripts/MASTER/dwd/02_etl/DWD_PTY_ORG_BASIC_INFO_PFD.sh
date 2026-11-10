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
-- ** 创建日期: 20230628
-- ** 修改日志: 新建
-- **
-- ** 目标表：DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD 机构基本信息表表
-- **         DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD 机构编码映射表
-- ** 源表：  DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT TTRADERIVAL机构映射表
-- **         DWDXDAY.DWD_PTY_ORG_TISSUER_PTD_INT TISSUER机构映射表
-- **         DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT HSZTA机构映射表
-- **         DWDXDAY.DWD_PTY_ORG_TCUSTOMERINFO_PTD_INT HSFTA机构映射表
-- **         DWDXDAY.DWD_PTY_ORG_HSDS_TCUSTINFO_PTD_INT HSDS机构映射表
-- **         DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP 每日新增机构编码映射临时表
-- **         DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP  每日新增机构基本信息表
-- **         DWDXDAY.DWD_PTY_ORG_BASIC_INFO_TMP    机构基本信息临时表
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

DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP;
CREATE TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP(
ORG_NUM                 STRING  COMMENT '机构编码',
ORG_NAME                STRING  COMMENT '机构名称',
ORG_SNAME               STRING  COMMENT '机构简称',
ORG_ENG_NAME            STRING  COMMENT '机构英文名称',
ORG_ESNAME              STRING  COMMENT '机构英文简称',
ORG_CATG                STRING  COMMENT '机构类别',
SETUP_DATE              STRING  COMMENT '成立日期',
COUNTRY                 STRING  COMMENT '国家',
PROVINCE                STRING  COMMENT '省份',
REG_ADDR                STRING  COMMENT '注册地址',
REG_PTCD                STRING  COMMENT '注册邮政编码',
REG_LCT_LCAL_CITY       STRING  COMMENT '注册地所在城市',
LEGA_REPST              STRING  COMMENT '法定代表人',
UNIF_SOCI_CREDIT_CODE   STRING  COMMENT '统一社会信用代码',
REG_CAPITAL             STRING  COMMENT '注册资本',
REG_CAPITAL_CRRC        STRING  COMMENT '注册资本币种',
OFFI_ADDR               STRING  COMMENT '办公地址',
OFFI_ADDR_PTCD          STRING  COMMENT '办公地址邮编',
WEB                     STRING  COMMENT '网址',
MAILBOX                 STRING  COMMENT '邮箱',
PHONE                   STRING  COMMENT '联系电话',
FAX                     STRING  COMMENT '传真',
PRINCIPAL_ACTIVITY      STRING  COMMENT '主营业务',
MANAGE_RANGE            STRING  COMMENT '经营范围',
SSYS                    STRING  COMMENT '源系统',
SOURCE_TAB              STRING  COMMENT '源表',
LD_TIME                 STRING  COMMENT '加载时间',
MODIFY_TIME             STRING  COMMENT '修改时间'
)COMMENT '每日新增机构基本信息表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';

INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP 
SELECT DISTINCT T2.ORG_NUM                                                                     AS ORG_NUM                          --机构编码
   , T1.C_CUSTNAME                                                                    AS ORG_NAME                         --机构名称
   , T1.C_SHORTNAME                                                                   AS ORG_SNAME                        --机构简称
   , NULL                                                                             AS ORG_ENG_NAME                     --机构英文名称
   , NULL                                                                             AS ORG_ESNAME                       --机构英文简称
   , T3.STD_DICT_CLS_CD_VAL                                                           AS ORG_CATG                         --机构类别
   , NULL                                                                             AS SETUP_DATE                       --成立日期
   , T1.C_NATIONALITY                                                                 AS COUNTRY                          --国家
   , T1.C_PROVINCE                                                                    AS PROVINCE                         --省份
   , T1.C_ADDRESS                                                                     AS REG_ADDR                         --注册地址
   , T1.C_ZIPCODE                                                                     AS REG_PTCD                         --注册邮政编码
   , T1.C_CITY                                                                        AS REG_LCT_LCAL_CITY                --注册地所在城市
   , T1.C_LAWNAME                                                                     AS LEGA_REPST                       --法定代表人
   , NULL                                                                             AS UNIF_SOCI_CREDIT_CODE            --统一社会信用代码
   , NULL                                                                             AS REG_CAPITAL                      --注册资本
   , NULL                                                                             AS REG_CAPITAL_CRRC                 --注册资本币种
   , T1.C_ADDRESS                                                                     AS OFFI_ADDR                        --办公地址
   , T1.C_ZIPCODE                                                                     AS OFFI_ADDR_PTCD                   --办公地址邮编
   , NULL                                                                             AS WEB                              --网址
   , T1.C_EMAIL                                                                       AS MAILBOX                          --邮箱
   , T1.C_PHONE                                                                       AS PHONE                            --联系电话
   , T1.C_FAXNO                                                                       AS FAX                              --传真
   , NULL                                                                             AS PRINCIPAL_ACTIVITY               --主营业务
   , T1.C_MANAGERANGE                                                                 AS MANAGE_RANGE                     --经营范围
   , 'HSZTA'                                                                          AS SSYS                             --源系统
   , 'ODS_HSZTA_TCUSTINFO_PFD'                                                        AS SOURCE_TAB                       --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')         AS LD_TIME                          --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')         AS MODIFY_TIME                      --修改时间    
     FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD T1   --HSZTA客户基本信息                                                                             
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP T2  --每日新增机构编码映射临时表
       ON T1.C_CUSTNAME = T2.ORG_NAME   
      AND T2.ST_DATE <= '${P_BATCH_DT}'  
      AND T2.END_DATE > '${P_BATCH_DT}'   
      AND T2.SSYS='HSZTA'     
      AND T2.SRC_TAB = 'ODS_HSZTA_TCUSTINFO_PFD'  
      AND T2.VALID_FLAG = '1'   
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T3    --标准字典码值映射
       ON T1.C_INSTITUTIONTYPE  = T3.SRC_DICT_CLS_CDVAL 
      AND T3.SSYS= 'HSZTA'
      AND T3.SRC_DICT_CLS_CD= 'C_INSTITUTIONTYPE'
      AND T3.VALID_FLAG='1'
     WHERE SUBSTR(T1.D_LASTMODIFY,1,8)= '${P_BATCH_DT}' 
       AND T1.C_CUSTTYPE= '0'
       AND T1.P_DT = '${P_BATCH_DT}' 
       AND T1.C_CUSTNAME NOT LIKE '%计划' ;

INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP 
SELECT DISTINCT A2.ORG_NUM                                                               AS ORG_NUM                          --机构编码
   , COALESCE(A1.VC_ALL_NAME,A1.VC_NAME)                                                             AS ORG_NAME                         --机构名称
   , A1.VC_NAME                                                                 AS ORG_SNAME                        --机构简称
   , NULL                                                                       AS ORG_ENG_NAME                     --机构英文名称
   , NULL                                                                       AS ORG_ESNAME                       --机构英文简称
   , A3.STD_DICT_CLS_CD_VAL                                                     AS ORG_CATG                         --机构类别
   , NULL                                                                       AS SETUP_DATE                       --成立日期
   , NULL                                                                       AS COUNTRY                          --国家
   , NULL                                                                       AS PROVINCE                         --省份
   , A1.VC_ADDRESS                                                              AS REG_ADDR                         --注册地址
   , NULL                                                                       AS REG_PTCD                         --注册邮政编码
   , NULL                                                                       AS REG_LCT_LCAL_CITY                --注册地所在城市
   , NULL                                                                       AS LEGA_REPST                       --法定代表人
   , NULL                                                                       AS UNIF_SOCI_CREDIT_CODE            --统一社会信用代码
   , NULL                                                                       AS REG_CAPITAL                      --注册资本
   , NULL                                                                       AS REG_CAPITAL_CRRC                 --注册资本币种
   , A1.VC_ADDRESS                                                              AS OFFI_ADDR                        --办公地址
   , NULL                                                                       AS OFFI_ADDR_PTCD                   --办公地址邮编
   , NULL                                                                       AS WEB                              --网址
   , NULL                                                                       AS MAILBOX                          --邮箱
   , A1.VC_PHONE                                                                AS PHONE                            --联系电话
   , A1.VC_FAX                                                                  AS FAX                              --传真
   , NULL                                                                       AS PRINCIPAL_ACTIVITY               --主营业务
   , NULL                                                                       AS MANAGE_RANGE                     --经营范围
   , 'O32'                                                                      AS SSYS                             --源系统
   , 'ODS_O32_TTRADERIVAL_PFD'                                                  AS SOURCE_TAB                       --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME                          --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME                      --修改时间    
     FROM ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD A1   --O32交易对手表
     LEFT JOIN  DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP A2  --每日新增机构编码映射临时表
       ON A2.ORG_NAME = COALESCE(A1.VC_ALL_NAME,A1.VC_NAME)
      AND A2.SSYS = 'O32'
      AND A2.SRC_TAB = 'ODS_O32_TTRADERIVAL_PFD'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典码值映射
       ON A1.C_RIVAL_TYPE  = A3.SRC_DICT_CLS_CDVAL
      AND A3.SRC_DICT_CLS_CD= 'C_RIVAL_TYPE'  
      AND A3.VALID_FLAG='1'
      AND A3.SSYS= 'O32'
     WHERE  SUBSTR(A1.VC_TIMESTAMP,1,8)= '${P_BATCH_DT}'
       AND COALESCE(A1.VC_ALL_NAME,A1.VC_NAME) LIKE '%公司'  
       AND A1.P_DT = '${P_BATCH_DT}'
       AND A2.SRC_TAB = 'ODS_O32_TTRADERIVAL_PFD';

INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP 
SELECT DISTINCT B2.ORG_NUM                                                               AS ORG_NUM                          --机构编码
   , B1.C_CUSTNAME                                                              AS ORG_NAME                         --机构名称
   , B1.C_SHORTNAME                                                             AS ORG_SNAME                        --机构简称
   , NULL                                                                       AS ORG_ENG_NAME                     --机构英文名称
   , NULL                                                                       AS ORG_ESNAME                       --机构英文简称
   , B3.STD_DICT_CLS_CD_VAL                                                     AS ORG_CATG                         --机构类别
   , NULL                                                                       AS SETUP_DATE                       --成立日期
   , B1.C_NATIONALITY                                                           AS COUNTRY                          --国家
   , B1.C_PROVINCE                                                              AS PROVINCE                         --省份
   , B1.C_ADDRESS                                                               AS REG_ADDR                         --注册地址
   , B1.C_ZIPCODE                                                               AS REG_PTCD                         --注册邮政编码
   , B1.C_CITY                                                                  AS REG_LCT_LCAL_CITY                --注册地所在城市
   , B1.C_LAWNAME                                                               AS LEGA_REPST                       --法定代表人
   , NULL                                                                       AS UNIF_SOCI_CREDIT_CODE            --统一社会信用代码
   , NULL                                                                       AS REG_CAPITAL                      --注册资本
   , NULL                                                                       AS REG_CAPITAL_CRRC                 --注册资本币种
   , B1.C_ADDRESS                                                               AS OFFI_ADDR                        --办公地址
   , B1.C_ZIPCODE                                                               AS OFFI_ADDR_PTCD                   --办公地址邮编
   , NULL                                                                       AS WEB                              --网址
   , B1.C_EMAIL                                                                 AS MAILBOX                          --邮箱
   , B1.C_PHONE                                                                 AS PHONE                            --联系电话
   , B1.C_FAXNO                                                                 AS FAX                              --传真
   , NULL                                                                       AS PRINCIPAL_ACTIVITY               --主营业务
   , B1.C_MANAGERANGE                                                           AS MANAGE_RANGE                     --经营范围
   , 'HSFTA'                                                                    AS SSYS                             --源系统
   , 'ODS_HSFTA_TCUSTOMERINFO_PFD'                                              AS SOURCE_TAB                       --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME                          --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME                      --修改时间    
     FROM  ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD B1         --HSFTA客户基本信息
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP B2   --每日新增机构编码映射临时表
       ON COALESCE (B1.C_CUSTNAME,B1.C_SHORTNAME) = B2.ORG_NAME
      AND B2.SSYS = 'HSFTA'
      AND B2.SRC_TAB= 'ODS_HSFTA_TCUSTOMERINFO_PFD'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP B3   --标准字典码值映射
       ON  B1.C_INSTITUTIONTYPE  = B3.SRC_DICT_CLS_CDVAL
      AND B3.SSYS= 'HSFTA'
      AND B3.SRC_DICT_CLS_CD= 'C_INSTITUTIONTYPE'
      AND B3.VALID_FLAG='1'
     WHERE  REPLACE(SUBSTR(B1.D_APPENDDATE,1,10),'-','') = '${P_BATCH_DT}' 
       AND B1.C_CUSTTYPE = 0  
       AND B1.P_DT = '${P_BATCH_DT}'
       AND B2.SSYS = 'HSFZA'
       AND B1.C_CUSTNAME NOT LIKE '%计划'
       AND B1.C_IDENTITYTYPE <> '8';

INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP 
SELECT DISTINCT C2.ORG_NUM                                                                AS ORG_NUM                          --机构编码
   , C1.VC_CUSTOMNAME                                                            AS ORG_NAME                         --机构名称
   , C1.VC_SHORTNAME                                                             AS ORG_SNAME                        --机构简称
   , C1.VC_FIRSTNAME                                                             AS ORG_ENG_NAME                     --机构英文名称
   , C1.VC_FIRSTNAME                                                             AS ORG_ESNAME                       --机构英文简称
   , C3.STD_DICT_CLS_CD_VAL                                                      AS ORG_CATG                         --机构类别
   , C1.VC_OPENDATE                                                              AS SETUP_DATE                       --成立日期
   , C1.VC_NATIONALITY                                                           AS COUNTRY                          --国家
   , NULL                                                                        AS PROVINCE                         --省份
   , NULL                                                                        AS REG_ADDR                         --注册地址
   , NULL                                                                        AS REG_PTCD                         --注册邮政编码
   , NULL                                                                        AS REG_LCT_LCAL_CITY                --注册地所在城市
   , NULL                                                                        AS LEGA_REPST                       --法定代表人
   , NULL                                                                        AS UNIF_SOCI_CREDIT_CODE            --统一社会信用代码
   , NULL                                                                        AS REG_CAPITAL                      --注册资本
   , NULL                                                                        AS REG_CAPITAL_CRRC                 --注册资本币种
   , C1.VC_OCRADDRESS                                                            AS OFFI_ADDR                        --办公地址
   , NULL                                                                        AS OFFI_ADDR_PTCD                   --办公地址邮编
   , NULL                                                                        AS WEB                              --网址
   , C1.VC_HOLDIDEMAIL                                                           AS MAILBOX                          --邮箱
   , C1.VC_HOLDIDPHONE                                                           AS PHONE                            --联系电话
   , NULL                                                                        AS FAX                              --传真
   , NULL                                                                        AS PRINCIPAL_ACTIVITY               --主营业务
   , NULL                                                                        AS MANAGE_RANGE                     --经营范围
   , 'HSDS'                                                                      AS SSYS                             --源系统
   , 'ODS_HSDS_TCUSTINFO_PTD'                                                    AS SOURCE_TAB                       --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')    AS LD_TIME                          --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')    AS MODIFY_TIME                      --修改时间    
     FROM  ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD  C1              --HSDS客户资料表
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP C2  --每日新增机构编码映射临时表
       ON C2.ORG_NAME = C1.VC_CUSTOMNAME 
      AND C2.SSYS = 'HSDS'
      AND C2.SRC_TAB ='ODS_HSDS_TCUSTINFO_PTD'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP  C3 --标准字典码值映射
       ON  C1.C_ORGTYPE  = C3.SRC_DICT_CLS_CDVAL 
      AND C3.SSYS= 'HSDS'
      AND C3.SRC_DICT_CLS_CD= 'C_ORGTYPE'
      AND C3.VALID_FLAG='1'
     WHERE  SUBSTR(C1.VC_LASTDATE,1,8) = '${P_BATCH_DT}' 
       AND C1.C_CUSTTYPE=0 
       AND C1.P_DT ='${P_BATCH_DT}' 
       AND C2.SSYS = 'HSDS'
       AND C1.VC_CUSTOMNAME NOT LIKE '%计划' ;

INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP 
SELECT DISTINCT D2.ORG_NUM                                                               AS ORG_NUM                          --机构编码
   , D1.VC_FULL_NAME                                                          AS ORG_NAME                         --机构名称
   , D1.VC_ISSUER_NAME                                                          AS ORG_SNAME                        --机构简称
   , NULL                                                                       AS ORG_ENG_NAME                     --机构英文名称
   , NULL                                                                       AS ORG_ESNAME                       --机构英文简称
   , D3.STD_DICT_CLS_CD_VAL                                                     AS ORG_CATG                         --机构类别
   , NULL                                                                       AS SETUP_DATE                       --成立日期
   , D1.VC_COUNTY                                                               AS COUNTRY                          --国家
   , D1.VC_PROVINCECODE                                                         AS PROVINCE                         --省份
   , D1.VC_ADDRESS                                                              AS REG_ADDR                         --注册地址
   , NULL                                                                       AS REG_PTCD                         --注册邮政编码
   , NULL                                                                       AS REG_LCT_LCAL_CITY                --注册地所在城市
   , NULL                                                                       AS LEGA_REPST                       --法定代表人
   , NULL                                                                       AS UNIF_SOCI_CREDIT_CODE            --统一社会信用代码
   , NULL                                                                       AS REG_CAPITAL                      --注册资本
   , NULL                                                                       AS REG_CAPITAL_CRRC                 --注册资本币种
   , D1.VC_ADDRESS                                                              AS OFFI_ADDR                        --办公地址
   , NULL                                                                       AS OFFI_ADDR_PTCD                   --办公地址邮编
   , NULL                                                                       AS WEB                              --网址
   , D1.VC_EMAIL                                                                AS MAILBOX                          --邮箱
   , D1.VC_PHONE                                                                AS PHONE                            --联系电话
   , D1.VC_FAX                                                                  AS FAX                              --传真
   , NULL                                                                       AS PRINCIPAL_ACTIVITY               --主营业务
   , NULL                                                                       AS MANAGE_RANGE                     --经营范围
   , 'O32'                                                                      AS SSYS                             --源系统
   , 'ODS_O32_TISSUER_PFD'                                                      AS SOURCE_TAB                       --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME                          --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME                      --修改时间    
     FROM ODS_XDAY_O32.ODS_O32_TISSUER_PFD  D1    --O32发行人信息表
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP D2 --每日新增机构编码映射临时表
       ON D2.ORG_NAME = D1.VC_FULL_NAME
      AND D2.SSYS = 'O32' 
      AND D2.SRC_TAB='ODS_O32_TISSUER_PFD'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP D3  --标准字典码值映射
       ON D1.VC_ISSUER_TYPE  = D3.SRC_DICT_CLS_CDVAL
      AND  D3.SSYS= 'O32'
      AND  D3.SRC_DICT_CLS_CD= 'VC_ISSUER_TYPE'
      AND  D3.VALID_FLAG='1'
     WHERE  SUBSTR(D1.VC_TIMESTAMP,1,8)= '${P_BATCH_DT}'
       AND SUBSTR(D1.VC_TIMESTAMP3,1,8)= '${P_BATCH_DT}'   
       AND D1.P_DT = '${P_BATCH_DT}'
       AND D2.SRC_TAB='ODS_O32_TISSUER_PFD';

INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP
SELECT A2.ORG_NUM                                                              AS ORG_NUM                          --机构编码
   ,  COALESCE(A1.C_FULLNAME,A1.C_AGENCYNAME)                                                           AS ORG_NAME                         --机构名称
   , NULL                                                                      AS ORG_SNAME                        --机构简称
   , NULL                                                                      AS ORG_ENG_NAME                     --机构英文名称
   , A1.C_AGENCYENGLISHNAME                                                    AS ORG_ESNAME                       --机构英文简称
   , A3.STD_DICT_CLS_CD_VAL                                                    AS ORG_CATG                         --机构类别
   , NULL                                                                      AS SETUP_DATE                       --成立日期
   , A1.C_AGEREGION                                                            AS COUNTRY                          --国家
   , NULL                                                                      AS PROVINCE                         --省份
   , NULL                                                                      AS REG_ADDR                         --注册地址
   , NULL                                                                      AS REG_PTCD                         --注册邮政编码
   , NULL                                                                      AS REG_LCT_LCAL_CITY                --注册地所在城市
   , NULL                                                                      AS LEGA_REPST                       --法定代表人
   , A1.C_AGECREDITCODE                                                        AS UNIF_SOCI_CREDIT_CODE            --统一社会信用代
   , NULL                                                                      AS REG_CAPITAL                      --注册资本
   , NULL                                                                      AS REG_CAPITAL_CRRC                 --注册资本币种
   , NULL                                                                      AS OFFI_ADDR                        --办公地址
   , NULL                                                                      AS OFFI_ADDR_PTCD                   --办公地址邮编
   , NULL                                                                      AS WEB                              --网址
   , A1.C_AGNCYMAIL                                                            AS MAILBOX                          --邮箱
   , A1.C_AGNCYPHONE                                                           AS PHONE                            --联系电话
   , A1.C_AGNCYFAXNO                                                           AS FAX                              --传真
   , NULL                                                                      AS PRINCIPAL_ACTIVITY               --主营业务
   , NULL                                                                      AS MANAGE_RANGE                     --经营范围
   , 'HSFTA'                                                                   AS SSYS                             --源系统
   , 'ODS_HSFTA_TAGENCYINFO_PFD'                                               AS SOURCE_TAB                       --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME                          --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME                      --修改时间    
     FROM ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD A1 --HSFTA销售商信息表
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  A2 --机构编码映射表
      ON A1.C_AGENCYNAME=A2.ORG_NAME  --机构内码
     AND A2.ST_DATE <= FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyyMMdd')    -- 开始日期
     AND A2.END_DATE > FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyyMMdd')    -- 结束日期
     AND A2.SSYS='HSFTA'     -- 源系统
     AND A2.SRC_TAB = 'ODS_HSFTA_TAGENCYINFO_PFD'  -- 源表
     AND A2.VALID_FLAG = '1'   -- 有效
    LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典分类代码
     ON A1.C_AGENCYTYPE  = A3.SRC_DICT_CLS_CDVAL 
    AND A3.SRC_DICT_CLS_CD= 'C_AGENCYTYPE'
    AND A3.VALID_FLAG='1'
    AND A3.SSYS= 'HSFTA'
    LEFT JOIN DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP A4
    ON A4.ORG_NUM = A2.ORG_NUM
    WHERE A1.P_DT='${P_BATCH_DT}' 
      AND A2.SRC_TAB = 'ODS_HSFTA_TAGENCYINFO_PFD'
      AND A4.ORG_NUM IS NULL;

INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP     
SELECT A2.ORG_NUM                                                             AS ORG_NUM                          --机构编码
   , A1.C_AGENCYNAME                                                          AS ORG_NAME                         --机构名称
   , NULL                                                                     AS ORG_SNAME                        --机构简称
   , NULL                                                                     AS ORG_ENG_NAME                     --机构英文名称
   , A1.C_AGENCYENGLISHNAME                                                   AS ORG_ESNAME                       --机构英文简称
   , A3.STD_DICT_CLS_CD_VAL                                                   AS ORG_CATG                         --机构类别
   , NULL                                                                     AS SETUP_DATE                       --成立日期
   , A1.C_AGEREGION                                                           AS COUNTRY                          --国家
   , NULL                                                                     AS PROVINCE                         --省份
   , A1.C_REGADDRESS                                                          AS REG_ADDR                         --注册地址
   , NULL                                                                     AS REG_PTCD                         --注册邮政编码
   , NULL                                                                     AS REG_LCT_LCAL_CITY                --注册地所在城市
   , A1.C_LEGALREPRESEN                                                       AS LEGA_REPST                       --法定代表人
   , A1.C_AGECREDITCODE                                                       AS UNIF_SOCI_CREDIT_CODE            --统一社会信用代
   , NULL                                                                     AS REG_CAPITAL                      --注册资本
   , NULL                                                                     AS REG_CAPITAL_CRRC                 --注册资本币种
   , A1.C_AGENCYADDRESS                                                          AS OFFI_ADDR                        --办公地址
   , A1.C_AGENCYZIPCODE                                                          AS OFFI_ADDR_PTCD                   --办公地址邮编
   , A1.C_URL                                                                    AS WEB                              --网址
   , A1.C_AGENCYMAIL                                                             AS MAILBOX                          --邮箱
   , A1.C_AGENCYPHONE                                                            AS PHONE                            --联系电话
   , A1.C_AGENCYFAXNO                                                            AS FAX                              --传真
   , NULL                                                                     AS PRINCIPAL_ACTIVITY               --主营业务
   , NULL                                                                     AS MANAGE_RANGE                     --经营范围
   , 'HSZTA'                                                                  AS SSYS                             --源系统
   , 'ODS_HSZTA_TAGENCYINFO_PFD'                                              AS SOURCE_TAB                       --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME                          --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME                      --修改时间    
     FROM ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD A1 --HSZTA销售商信息表
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  A2 --机构编码映射表
       ON A2.ORG_INCD=A1.C_AGENCYNO  --机构全称
      AND A2.ST_DATE <= FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyyMMdd')    -- 开始日期
      AND A2.END_DATE > FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyyMMdd')    -- 结束日期
      AND A2.SSYS='HSZTA'     -- 源系统
      AND A2.SRC_TAB = 'ODS_HSZTA_TAGENCYINFO_PFD'  -- 源表
      AND A2.VALID_FLAG = '1'   -- 有效
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典分类代码
       ON A1.C_AGENCYTYPE  = A3.SRC_DICT_CLS_CDVAL 
      AND A3.SRC_DICT_CLS_CD= 'C_AGENCYTYPE'
      AND A3.VALID_FLAG='1'
      AND A3.SSYS= 'HSZTA'
      LEFT JOIN DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP A4
           ON A4.ORG_NUM = A2.ORG_NUM
     WHERE A1.P_DT='${P_BATCH_DT}'
       AND A4.ORG_NUM IS NULL ;
 
DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_ORG_BASIC_INFO_TMP;
CREATE TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_TMP(
ORG_NUM                 STRING  COMMENT '机构编码',
ORG_NAME                STRING  COMMENT '机构名称',
ORG_SNAME               STRING  COMMENT '机构简称',
ORG_ENG_NAME            STRING  COMMENT '机构英文名称',
ORG_ESNAME              STRING  COMMENT '机构英文简称',
ORG_CATG                STRING  COMMENT '机构类别',
SETUP_DATE              STRING  COMMENT '成立日期',
COUNTRY                 STRING  COMMENT '国家',
PROVINCE                STRING  COMMENT '省份',
REG_ADDR                STRING  COMMENT '注册地址',
REG_PTCD                STRING  COMMENT '注册邮政编码',
REG_LCT_LCAL_CITY       STRING  COMMENT '注册地所在城市',
LEGA_REPST              STRING  COMMENT '法定代表人',
UNIF_SOCI_CREDIT_CODE   STRING  COMMENT '统一社会信用代码',
REG_CAPITAL             STRING  COMMENT '注册资本',
REG_CAPITAL_CRRC        STRING  COMMENT '注册资本币种',
OFFI_ADDR               STRING  COMMENT '办公地址',
OFFI_ADDR_PTCD          STRING  COMMENT '办公地址邮编',
WEB                     STRING  COMMENT '网址',
MAILBOX                 STRING  COMMENT '邮箱',
PHONE                   STRING  COMMENT '联系电话',
FAX                     STRING  COMMENT '传真',
PRINCIPAL_ACTIVITY      STRING  COMMENT '主营业务',
MANAGE_RANGE            STRING  COMMENT '经营范围',
SSYS                    STRING  COMMENT '源系统',
SOURCE_TAB              STRING  COMMENT '源表',
LD_TIME                 STRING  COMMENT '加载时间',
MODIFY_TIME             STRING  COMMENT '修改时间'
)COMMENT '机构基本信息表临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_TMP 
SELECT DISTINCT COALESCE ( B.ORG_NUM,A.ORG_NUM)                                         AS ORG_NUM                      --机构编码
   , COALESCE ( B.ORG_NAME,A.ORG_NAME)                                         AS ORG_NAME                     --机构名称
   , COALESCE ( A.ORG_SNAME,B.ORG_SNAME)                                       AS ORG_SNAME                    --机构简称
   , COALESCE ( A.ORG_ENG_NAME,B.ORG_ENG_NAME)                                 AS ORG_ENG_NAME                 --机构英文名称
   , COALESCE ( A.ORG_ESNAME,B.ORG_ESNAME )                                    AS ORG_ESNAME                   --机构英文简称
   , COALESCE ( A.ORG_CATG,B.ORG_CATG )                                        AS ORG_CATG                     --机构类别
   , COALESCE ( A.SETUP_DATE,B.SETUP_DATE)                                     AS SETUP_DATE                   --成立日期
   , COALESCE ( A.COUNTRY,B.COUNTRY)                                           AS COUNTRY                      --国家
   , COALESCE ( A.PROVINCE,B.PROVINCE)                                         AS PROVINCE                     --省份
   , COALESCE ( A.REG_ADDR,B.REG_ADDR)                                         AS REG_ADDR                     --注册地址
   , COALESCE ( A.REG_PTCD,B.REG_PTCD)                                         AS REG_PTCD                     --注册邮政编码
   , COALESCE ( A.REG_LCT_LCAL_CITY,B.REG_LCT_LCAL_CITY)                       AS REG_LCT_LCAL_CITY            --注册地所在城市
   , COALESCE ( A.LEGA_REPST,B.LEGA_REPST )                                    AS LEGA_REPST                   --法定代表人
   , COALESCE ( A.UNIF_SOCI_CREDIT_CODE,B.UNIF_SOCI_CREDIT_CODE)               AS UNIF_SOCI_CREDIT_CODE        --统一社会信用代码
   , COALESCE ( A.REG_CAPITAL,B.REG_CAPITAL)                                   AS REG_CAPITAL                  --注册资本
   , COALESCE ( A.REG_CAPITAL_CRRC,B.REG_CAPITAL_CRRC)                         AS REG_CAPITAL_CRRC             --注册资本币种
   , COALESCE ( A.OFFI_ADDR,B.OFFI_ADDR)                                       AS OFFI_ADDR                    --办公地址
   , COALESCE ( A.OFFI_ADDR_PTCD,B.OFFI_ADDR_PTCD)                             AS OFFI_ADDR_PTCD               --办公地址邮编
   , COALESCE ( A.WEB,B.WEB)                                                   AS WEB                          --网址
   , COALESCE ( A.MAILBOX,B.MAILBOX)                                           AS MAILBOX                      --邮箱
   , COALESCE ( A.PHONE,B.PHONE)                                               AS PHONE                        --联系电话
   , COALESCE ( A.FAX,B.FAX)                                                   AS FAX                          --传真
   , COALESCE ( A.PRINCIPAL_ACTIVITY,B.PRINCIPAL_ACTIVITY)                     AS PRINCIPAL_ACTIVITY           --主营业务
   , COALESCE ( A.MANAGE_RANGE,B.MANAGE_RANGE)                                 AS MANAGE_RANGE                 --经营范围
   , COALESCE ( A.SSYS,B.SSYS)                                                 AS SSYS                         --源系统
   , COALESCE ( A.SOURCE_TAB,B.SOURCE_TAB)                                     AS SOURCE_TAB                   --源表
   , COALESCE ( A.LD_TIME,B.LD_TIME)                                           AS LD_TIME                      --加载时间
   , COALESCE ( A.MODIFY_TIME,B.MODIFY_TIME)                                   AS MODIFY_TIME                  --修改时间    
     FROM  DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD_TMP A  --每日新增机构基本信息表
     FULL JOIN
     (SELECT  ORG_NUM                     AS ORG_NUM                      --机构编码
         , ORG_NAME                       AS ORG_NAME                     --机构名称
         , ORG_SNAME                      AS ORG_SNAME                    --机构简称
         , ORG_ENG_NAME                   AS ORG_ENG_NAME                 --机构英文名称
         , ORG_ESNAME                     AS ORG_ESNAME                   --机构英文简称
         , ORG_CATG                       AS ORG_CATG                     --机构类别
         , SETUP_DATE                     AS SETUP_DATE                   --成立日期
         , COUNTRY                        AS COUNTRY                      --国家
         , PROVINCE                       AS PROVINCE                     --省份
         , REG_ADDR                       AS REG_ADDR                     --注册地址
         , REG_PTCD                       AS REG_PTCD                     --注册邮政编码
         , REG_LCT_LCAL_CITY              AS REG_LCT_LCAL_CITY            --注册地所在城市
         , LEGA_REPST                     AS LEGA_REPST                   --法定代表人
         , UNIF_SOCI_CREDIT_CODE          AS UNIF_SOCI_CREDIT_CODE        --统一社会信用代码
         , REG_CAPITAL                    AS REG_CAPITAL                  --注册资本
         , REG_CAPITAL_CRRC               AS REG_CAPITAL_CRRC             --注册资本币种
         , OFFI_ADDR                      AS OFFI_ADDR                    --办公地址
         , OFFI_ADDR_PTCD                 AS OFFI_ADDR_PTCD               --办公地址邮编
         , WEB                            AS WEB                          --网址
         , MAILBOX                        AS MAILBOX                      --邮箱
         , PHONE                          AS PHONE                        --联系电话
         , FAX                            AS FAX                          --传真
         , PRINCIPAL_ACTIVITY             AS PRINCIPAL_ACTIVITY           --主营业务
         , MANAGE_RANGE                   AS MANAGE_RANGE                 --经营范围
         , SSYS                           AS SSYS                         --源系统
         , SOURCE_TAB                     AS SOURCE_TAB                   --源表
         , LD_TIME                        AS LD_TIME                      --加载时间
         , MODIFY_TIME                    AS MODIFY_TIME                  --修改时间    
           FROM DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD ) B --机构基本信息表
       ON A.ORG_NAME = B.ORG_NAME;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD
SELECT  A.ORG_NUM                     AS ORG_NUM                      --机构编码
   , A.ORG_NAME                       AS ORG_NAME                     --机构名称
   , A.ORG_SNAME                      AS ORG_SNAME                    --机构简称
   , A.ORG_ENG_NAME                   AS ORG_ENG_NAME                 --机构英文名称
   , A.ORG_ESNAME                     AS ORG_ESNAME                   --机构英文简称
   , A.ORG_CATG                       AS ORG_CATG                     --机构类别
   , A.SETUP_DATE                     AS SETUP_DATE                   --成立日期
   , A.COUNTRY                        AS COUNTRY                      --国家
   , A.PROVINCE                       AS PROVINCE                     --省份
   , A.REG_ADDR                       AS REG_ADDR                     --注册地址
   , A.REG_PTCD                       AS REG_PTCD                     --注册邮政编码
   , A.REG_LCT_LCAL_CITY              AS REG_LCT_LCAL_CITY            --注册地所在城市
   , A.LEGA_REPST                     AS LEGA_REPST                   --法定代表人
   , A.UNIF_SOCI_CREDIT_CODE          AS UNIF_SOCI_CREDIT_CODE        --统一社会信用代码
   , A.REG_CAPITAL                    AS REG_CAPITAL                  --注册资本
   , A.REG_CAPITAL_CRRC               AS REG_CAPITAL_CRRC             --注册资本币种
   , A.OFFI_ADDR                      AS OFFI_ADDR                    --办公地址
   , A.OFFI_ADDR_PTCD                 AS OFFI_ADDR_PTCD               --办公地址邮编
   , A.WEB                            AS WEB                          --网址
   , A.MAILBOX                        AS MAILBOX                      --邮箱
   , A.PHONE                          AS PHONE                        --联系电话
   , A.FAX                            AS FAX                          --传真
   , A.PRINCIPAL_ACTIVITY             AS PRINCIPAL_ACTIVITY           --主营业务
   , A.MANAGE_RANGE                   AS MANAGE_RANGE                 --经营范围
   , A.SSYS                           AS SSYS                         --源系统
   , A.SOURCE_TAB                     AS SOURCE_TAB                   --源表
   , A.LD_TIME                        AS LD_TIME                      --加载时间
   , A.MODIFY_TIME                    AS MODIFY_TIME                  --修改时间    
     FROM DWDXDAY.DWD_PTY_ORG_BASIC_INFO_TMP A ; --机构基本信息临时表
"
