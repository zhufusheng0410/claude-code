
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
-- ** 目标表：DWDXDAY.DWD_PTY_CUST_INFO_PFD 客户信息表
-- **         DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD 客户编码映射表
-- ** 源表：  DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT HSZTA客户编码映射表
-- **         DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT HSFTA客户编码映射表
-- **         DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT HSDS客户编码映射表
-- **         DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP 客户编码临时表
-- **         DWDXDAY.DWD_PTY_CUST_INFO_TMP        新增客户编码临时表
-- **         DWDXDAY.DWD_PTY_CUST_INFO_PFD_TMP    客户信息临时表
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

DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_CUST_INFO_TMP;
CREATE TABLE DWDXDAY.DWD_PTY_CUST_INFO_TMP(
CUST_NUM                STRING       COMMENT  '客户编码',
CUST_NAME               STRING       COMMENT  '客户名称',
CUST_SNAME              STRING       COMMENT  '客户简称',
C_CUSTTYPE              STRING       COMMENT   '客户类型',
CUST_CATG               STRING       COMMENT  '客户类别',
CUST_CERT_TYPE          STRING       COMMENT  '客户证件类型',
CUST_CERT_NO            STRING       COMMENT  '客户证件号码',
UNIF_SOCI_CREDIT_CODE   STRING       COMMENT  '统一社会信用代码',
ORG_NUM                 STRING       COMMENT  '机构编码',
PTCD                    STRING       COMMENT  '邮编',
ADDR                    STRING       COMMENT  '地址',
FAX                     STRING       COMMENT  '传真号码',
PHONE                   STRING       COMMENT  '联系电话',
MAILBOX                 STRING       COMMENT  '邮箱',
MOBI_NO                 STRING       COMMENT  '手机号码',
SEX                     STRING       COMMENT  '客户性别',
BIRTHDAY                STRING       COMMENT  '客户生日',
OCCU                    STRING       COMMENT  '职业',
EDU                     STRING       COMMENT  '学历',
CORP_NAME               STRING       COMMENT  '公司名称',
CORP_TEL                STRING       COMMENT  '公司电话',
CUST_ACCT               STRING       COMMENT  '客户账户',
CUST_ACCT_TYPE          STRING       COMMENT  '客户账户类型',
CUST_ACCT_STAT          STRING       COMMENT  '客户账户状态',
ACCT_OPEN_DATE          STRING       COMMENT  '账户开户日期',
ACCT_LAST_MODIFY_DATE   STRING       COMMENT  '账户最后修改日期',
OPER                    STRING       COMMENT  '经办人',
OPER_CERT_TYPE          STRING       COMMENT  '经办人证件类型',
OPER_CERT_NO            STRING       COMMENT  '经办人证件号码',
SH_SCR_ACCT             STRING       COMMENT  '上交所证券账户',
SZ_SCR_ACCT             STRING       COMMENT  '深交所证券账户',
SSYS                    STRING       COMMENT  '源系统',
SOURCE_TAB              STRING       COMMENT  '源表',
LD_TIME                 STRING       COMMENT  '加载时间',
MODIFY_TIME             STRING       COMMENT  '修改时间'
)COMMENT '新增客户信息表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL DEFINED AS '';

INSERT INTO TABLE DWDXDAY.DWD_PTY_CUST_INFO_TMP
SELECT CUST_NUM                  AS CUST_NUM                --客户编码
   , CUST_NAME                 AS CUST_NAME               --客户名称
   , CUST_SNAME                AS CUST_SNAME              --客户简称
   , C_CUSTTYPE                AS C_CUSTTYPE             --客户类型
   , CUST_CATG                 AS CUST_CATG               --客户类别
   , CUST_CERT_TYPE            AS CUST_CERT_TYPE          --客户证件类型
   , CUST_CERT_NO              AS CUST_CERT_NO            --客户证件号码
   , UNIF_SOCI_CREDIT_CODE     AS UNIF_SOCI_CREDIT_CODE   --统一社会信用代码
   , ORG_NUM                   AS ORG_NUM                 --机构编码
   , PTCD                      AS PTCD                    --邮编
   , ADDR                      AS ADDR                    --地址
   , FAX                       AS FAX                     --传真号码
   , PHONE                     AS PHONE                   --联系电话
   , MAILBOX                   AS MAILBOX                 --邮箱
   , MOBI_NO                   AS MOBI_NO                 --手机号码
   , SEX                       AS SEX                     --客户性别
   , BIRTHDAY                  AS BIRTHDAY                --客户生日
   , OCCU                      AS OCCU                    --职业
   , EDU                       AS EDU                     --学历
   , CORP_NAME                 AS CORP_NAME               --公司名称
   , CORP_TEL                  AS CORP_TEL                --公司电话
   , CUST_ACCT                 AS CUST_ACCT               --客户账户
   , CUST_ACCT_TYPE            AS CUST_ACCT_TYPE          --客户账户类型
   , CUST_ACCT_STAT            AS CUST_ACCT_STAT          --客户账户状态
   , ACCT_OPEN_DATE            AS ACCT_OPEN_DATE          --账户开户日期
   , ACCT_LAST_MODIFY_DATE     AS ACCT_LAST_MODIFY_DATE   --账户最后修改日期
   , OPER                      AS OPER                    --经办人
   , OPER_CERT_TYPE            AS OPER_CERT_TYPE          --经办人证件类型
   , OPER_CERT_NO              AS OPER_CERT_NO            --经办人证件号码
   , SH_SCR_ACCT               AS SH_SCR_ACCT             --上交所证券账户
   , SZ_SCR_ACCT               AS SZ_SCR_ACCT             --深交所证券账户
   , SSYS                      AS SSYS                    --源系统
   , SOURCE_TAB                AS SOURCE_TAB              --源表
   , LD_TIME                   AS LD_TIME                 --加载时间
   , MODIFY_TIME               AS MODIFY_TIME             --修改时间
     FROM
     (SELECT A2.CUST_NUM                                                            AS CUST_NUM                    --客户编码
        , A1.C_CUSTNAME                                                             AS CUST_NAME                   --客户名称
        , A1.C_SHORTNAME                                                            AS CUST_SNAME                  --客户简称
        , A1.C_CUSTTYPE                                                             AS C_CUSTTYPE                  --客户类型
        , ROW_NUMBER()OVER( PARTITION BY A2.CUST_NUM ORDER BY A2.LD_TIME DESC ) AS RN
        , A3.STD_DICT_CLS_CD_VAL                                                    AS CUST_CATG                   --客户类别
        , A4.STD_DICT_CLS_CD_VAL                                                    AS CUST_CERT_TYPE              --客户证件类型
        , A1.C_IDENTITYNO                                                           AS CUST_CERT_NO                --客户证件号码
        , NULL                                                                      AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
        , A5.ORG_NUM                                                                AS ORG_NUM                     --机构编码
        , A1.C_ZIPCODE                                                              AS PTCD                        --邮编
        , regexp_replace(A1.C_ADDRESS,'\\n/\\r/\\t','')                             AS ADDR                        --地址
        , A1.C_FAXNO                                                                AS FAX                         --传真号码
        , A1.C_PHONE                                                                AS PHONE                       --联系电话
        , A1.C_EMAIL                                                                AS MAILBOX                     --邮箱
        , A1.C_MOBILENO                                                             AS MOBI_NO                     --手机号码
        , A1.C_SEX                                                                  AS SEX                         --客户性别
        , A1.C_BIRTHDAY                                                             AS BIRTHDAY                    --客户生日
        , A1.C_VOCATION                                                             AS OCCU                        --职业
        , A1.C_EDUCATION                                                            AS EDU                         --学历
        , A1.C_CORPNAME                                                             AS CORP_NAME                   --公司名称
        , A1.C_CORPTEL                                                              AS CORP_TEL                    --公司电话
        , A1.C_FUNDACCO                                                             AS CUST_ACCT                   --客户账户
        , A6.STD_DICT_CLS_CD_VAL                                                    AS CUST_ACCT_TYPE              --客户账户类型
        , A1.C_ACCOSTATUS                                                           AS CUST_ACCT_STAT              --客户账户状态
        , A1.D_OPENDATE                                                             AS ACCT_OPEN_DATE              --账户开户日期
        , A1.D_LASTMODIFY                                                           AS ACCT_LAST_MODIFY_DATE       --账户最后修改日期
        , A1.C_CONTACT                                                              AS OPER                        --经办人
        , A7.STD_DICT_CLS_CD_VAL                                                    AS OPER_CERT_TYPE              --经办人证件类型
        , A1.C_CONTNO                                                               AS OPER_CERT_NO                --经办人证件号码
        , A1.C_SHACCO                                                               AS SH_SCR_ACCT                 --上交所证券账户
        , A1.C_SZACCO                                                               AS SZ_SCR_ACCT                 --深交所证券账户
        , 'HSZTA'                                                                   AS SSYS                        --源系统
        , 'ODS_HSZTA_TCUSTINFO_PFD'                                                 AS SOURCE_TAB                  --源表
        , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME                     --加载时间
        , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME                 --修改时间
          FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD A1    --客户基本信息
           INNER JOIN DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD A2  --新增客户编码临时表
            ON A2.cust_no = A1.c_custno
           AND A2.ST_DATE <= '${P_BATCH_DT}'    
           AND A2.END_DATE > '${P_BATCH_DT}'   
           AND A2.P_DT = '${P_BATCH_DT}'
           AND A2.SSYS='HSZTA'     
           AND A2.SRC_TAB = 'ODS_HSZTA_TCUSTINFO_PFD' 
           AND A2.VALID_FLAG = '1'   
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3   --标准字典码值映射
            ON A1.C_CUSTTYPE = A3.SRC_DICT_CLS_CDVAL
           AND A3.SSYS= 'HSZTA'
           AND A3.SRC_DICT_CLS_CD= 'C_CUSTTYPE'  
           AND A3.VALID_FLAG='1'
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A4   --标准字典码值映射
            ON  A1.C_IDENTITYTYPE = A4.SRC_DICT_CLS_CDVAL
           AND A4.SSYS= 'HSZTA'
           AND A4.SRC_DICT_CLS_CD= 'C_IDENTITYTYPE'
           AND A4.VALID_FLAG='1'
          LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD  A5  --机构便秘映射表
            ON A1.C_CUSTNO =A5.ORG_INCD 
           AND A5.ST_DATE <= '${P_BATCH_DT}'    
           AND A5.END_DATE > '${P_BATCH_DT}'    
           AND A5.SSYS='HSZTA'   
           AND A5.SRC_TAB = 'ODS_HSZTA_TCUSTINFO_PFD'
           AND A5.VALID_FLAG = '1'    
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A6   --标准字典码值映射
            ON  A1.C_ACCOUNTTYPE = A6.SRC_DICT_CLS_CDVAL 
           AND A6.SSYS= 'HSZTA'
           AND A6.SRC_DICT_CLS_CD= 'C_ACCOUNTTYPE'
           AND A6.VALID_FLAG='1'
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A7   --标准字典码值映射
            ON A7.SSYS= 'HSZTA'
           AND A7.SRC_DICT_CLS_CD= 'C_CONTYPE'
           AND A1.C_CONTYPE = A7.SRC_DICT_CLS_CDVAL 
           AND A7.VALID_FLAG='1'
          WHERE A1.P_DT ='${P_BATCH_DT}' AND  SUBSTR(A1.D_LASTMODIFY,1,8) >='${P_BATCH_DT}'
            AND A2.SSYS = 'HSZTA'  ) SUBT1
     WHERE RN = 1 ;

INSERT INTO TABLE DWDXDAY.DWD_PTY_CUST_INFO_TMP
SELECT CUST_NUM                   AS CUST_NUM                  --客户编码
   , CUST_NAME                  AS CUST_NAME                 --客户名称
   , CUST_SNAME                 AS CUST_SNAME                --客户简称
   , C_CUSTTYPE                  AS C_CUSTTYPE                --客户类型
   , CUST_CATG                  AS CUST_CATG                 --客户类别
   , CUST_CERT_TYPE             AS CUST_CERT_TYPE            --客户证件类型
   , CUST_CERT_NO               AS CUST_CERT_NO              --客户证件号码
   , UNIF_SOCI_CREDIT_CODE      AS UNIF_SOCI_CREDIT_CODE     --统一社会信用代码
   , ORG_NUM                    AS ORG_NUM                   --机构编码
   , PTCD                       AS PTCD                      --邮编
   , ADDR                       AS ADDR                      --地址
   , FAX                        AS FAX                       --传真号码
   , PHONE                      AS PHONE                     --联系电话
   , MAILBOX                    AS MAILBOX                   --邮箱
   , MOBI_NO                    AS MOBI_NO                   --手机号码
   , SEX                        AS SEX                       --客户性别
   , BIRTHDAY                   AS BIRTHDAY                  --客户生日
   , OCCU                       AS OCCU                      --职业
   , EDU                        AS EDU                       --学历
   , CORP_NAME                  AS CORP_NAME                 --公司名称
   , CORP_TEL                   AS CORP_TEL                  --公司电话
   , CUST_ACCT                  AS CUST_ACCT                 --客户账户
   , CUST_ACCT_TYPE             AS CUST_ACCT_TYPE            --客户账户类型
   , CUST_ACCT_STAT             AS CUST_ACCT_STAT            --客户账户状态
   , ACCT_OPEN_DATE             AS ACCT_OPEN_DATE            --账户开户日期
   , ACCT_LAST_MODIFY_DATE      AS ACCT_LAST_MODIFY_DATE     --账户最后修改日期
   , OPER                       AS OPER                      --经办人
   , OPER_CERT_TYPE             AS OPER_CERT_TYPE            --经办人证件类型
   , OPER_CERT_NO               AS OPER_CERT_NO              --经办人证件号码
   , SH_SCR_ACCT                AS SH_SCR_ACCT               --上交所证券账户
   , SZ_SCR_ACCT                AS SZ_SCR_ACCT               --深交所证券账户
   , SSYS                       AS SSYS                      --源系统
   , SOURCE_TAB                 AS SOURCE_TAB                --源表
   , LD_TIME                    AS LD_TIME                   --加载时间
   , MODIFY_TIME                AS MODIFY_TIME               --修改时间
     FROM
     (SELECT A2.CUST_NUM                                                             AS CUST_NUM                    --客户编码
        , A1.C_CUSTNAME                                                              AS CUST_NAME                   --客户名称
        , A1.C_SHORTNAME                                                             AS CUST_SNAME                  --客户简称
        , A1.C_CUSTTYPE                                                              AS C_CUSTTYPE                  --客户类型
        , ROW_NUMBER()OVER(PARTITION BY A2.CUST_NUM ORDER BY A2.LD_TIME DESC )  AS RN
        , A3.STD_DICT_CLS_CD_VAL                                                     AS CUST_CATG                   --客户类别
        , A4.STD_DICT_CLS_CD_VAL                                                     AS CUST_CERT_TYPE              --客户证件类型
        , A1.C_IDENTITYNO                                                            AS CUST_CERT_NO                --客户证件号码
        , NULL                                                                       AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
        , A5.ORG_NUM                                                                 AS ORG_NUM                     --机构编码
        , A1.C_ZIPCODE                                                               AS PTCD                        --邮编
        , regexp_replace(A1.C_ADDRESS,'\\n/\\r/\\t','')                                                                AS ADDR                        --地址
        , A1.C_FAXNO                                                                 AS FAX                         --传真号码
        , A1.C_PHONE                                                                 AS PHONE                       --联系电话
        , A1.C_EMAIL                                                                 AS MAILBOX                     --邮箱
        , A1.C_MOBILENO                                                              AS MOBI_NO                     --手机号码
        , A1.C_SEX                                                                   AS SEX                         --客户性别
        , A1.C_BIRTHDAY                                                              AS BIRTHDAY                    --客户生日
        , A1.C_VOCATION                                                              AS OCCU                        --职业
        , A1.C_EDUCATION                                                             AS EDU                         --学历
        , A1.C_CORPNAME                                                              AS CORP_NAME                   --公司名称
        , A1.C_CORPTEL                                                               AS CORP_TEL                    --公司电话
        , NULL                                                                       AS CUST_ACCT                   --客户账户
        , NULL                                                                       AS CUST_ACCT_TYPE              --客户账户类型
        , NULL                                                                       AS CUST_ACCT_STAT              --客户账户状态
        , NULL                                                                       AS ACCT_OPEN_DATE              --账户开户日期
        , NULL                                                                       AS ACCT_LAST_MODIFY_DATE       --账户最后修改日期
        , A1.C_CONTACT                                                               AS OPER                        --经办人
        , A6.STD_DICT_CLS_CD_VAL                                                     AS OPER_CERT_TYPE              --经办人证件类型
        , A1.C_CONTNO                                                                AS OPER_CERT_NO                --经办人证件号码
        , A1.C_SHACCO                                                                AS SH_SCR_ACCT                 --上交所证券账户
        , A1.C_SZACCO                                                                AS SZ_SCR_ACCT                 --深交所证券账户
        , 'HSFTA'                                                                    AS SSYS                        --源系统
        , 'ODS_HSFTA_TCUSTOMERINFO_PFD'                                              AS SOURCE_TAB                  --源表
        , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS LD_TIME                     --加载时间
        , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')   AS MODIFY_TIME                 --修改时间
          FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD A1    --客户基本信息
          INNER JOIN DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD A2  --新增客户编码临时表
            ON A1.C_CUSTNO = A2.cust_no
           AND A2.ST_DATE <= '${P_BATCH_DT}'    
           AND A2.END_DATE > '${P_BATCH_DT}'  
           AND A2.P_DT = '${P_BATCH_DT}'
           AND A2.SSYS='HSFTA'     
           AND A2.SRC_TAB = 'ODS_HSFTA_TCUSTOMERINFO_PFD' 
           AND A2.VALID_FLAG = '1'   
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典码值映射
            ON A1.C_CUSTTYPE = A3.SRC_DICT_CLS_CDVAL 
           AND A3.SSYS= 'HSFTA'
           AND A3.SRC_DICT_CLS_CD= 'C_CUSTTYPE'
           AND A3.VALID_FLAG='1'
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A4  --标准字典码值映射
            ON A1.C_IDENTITYTYPE = A4.SRC_DICT_CLS_CDVAL
           AND A4.SSYS= 'HSFTA'
           AND A4.SRC_DICT_CLS_CD= 'C_IDENTITYTYPE' 
           AND A4.VALID_FLAG='1'
          LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD A5   --机构编码映射表
            ON A1.C_CUSTNO =A5.ORG_INCD
           AND A5.ST_DATE <= '${P_BATCH_DT}'    
           AND A5.END_DATE > '${P_BATCH_DT}'    
           AND A5.SSYS='HSFTA'  
           AND A5.SRC_TAB = 'ODS_HSFTA_TCUSTOMERINFO_PFD' 
           AND A5.VALID_FLAG = '1'  
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A6  --标准字典码值映射
            ON A1.C_CONTYPE = A6.SRC_DICT_CLS_CDVAL 
           AND A6.SSYS= 'HSFTA'
           AND A6.SRC_DICT_CLS_CD= 'C_CONTYPE'
           AND A6.VALID_FLAG='1'
         LEFT JOIN  DWDXDAY.DWD_PTY_CUST_INFO_TMP A7
              ON A7.CUST_NUM = A2.CUST_NUM
          WHERE A1.P_DT='${P_BATCH_DT}' AND REPLACE(SUBSTR(A1.D_APPENDDATE,1,10),'-','') >='${P_BATCH_DT}'
            AND A2.SSYS = 'HSFTA'
            AND A7.CUST_NUM IS NULL) SUBT2
     WHERE RN = 1;

 
INSERT INTO TABLE DWDXDAY.DWD_PTY_CUST_INFO_TMP
SELECT CUST_NUM                   AS CUST_NUM              --客户编码
   , CUST_NAME                  AS CUST_NAME               --客户名称
   , CUST_SNAME                 AS CUST_SNAME              --客户简称
   , C_CUSTTYPE                 AS C_CUSTTYPE              --客户类型
   , CUST_CATG                  AS CUST_CATG               --客户类别
   , CUST_CERT_TYPE             AS CUST_CERT_TYPE          --客户证件类型
   , CUST_CERT_NO               AS CUST_CERT_NO            --客户证件号码
   , UNIF_SOCI_CREDIT_CODE      AS UNIF_SOCI_CREDIT_CODE   --统一社会信用代码
   , ORG_NUM                    AS ORG_NUM                 --机构编码
   , PTCD                       AS PTCD                    --邮编
   , ADDR                       AS ADDR                    --地址
   , FAX                        AS FAX                     --传真号码
   , PHONE                      AS PHONE                   --联系电话
   , MAILBOX                    AS MAILBOX                 --邮箱
   , MOBI_NO                    AS MOBI_NO                 --手机号码
   , SEX                        AS SEX                     --客户性别
   , BIRTHDAY                   AS BIRTHDAY                --客户生日
   , OCCU                       AS OCCU                    --职业
   , EDU                        AS EDU                     --学历
   , CORP_NAME                  AS CORP_NAME               --公司名称
   , CORP_TEL                   AS CORP_TEL                --公司电话
   , CUST_ACCT                  AS CUST_ACCT               --客户账户
   , CUST_ACCT_TYPE             AS CUST_ACCT_TYPE          --客户账户类型
   , CUST_ACCT_STAT             AS CUST_ACCT_STAT          --客户账户状态
   , ACCT_OPEN_DATE             AS ACCT_OPEN_DATE          --账户开户日期
   , ACCT_LAST_MODIFY_DATE      AS ACCT_LAST_MODIFY_DATE   --账户最后修改日期
   , OPER                       AS OPER                    --经办人
   , OPER_CERT_TYPE             AS OPER_CERT_TYPE          --经办人证件类型
   , OPER_CERT_NO               AS OPER_CERT_NO            --经办人证件号码
   , SH_SCR_ACCT                AS SH_SCR_ACCT             --上交所证券账户
   , SZ_SCR_ACCT                AS SZ_SCR_ACCT             --深交所证券账户
   , SSYS                       AS SSYS                    --源系统
   , SOURCE_TAB                 AS SOURCE_TAB              --源表
   , LD_TIME                    AS LD_TIME                 --加载时间
   , MODIFY_TIME                AS MODIFY_TIME             --修改时间
     FROM 
     (SELECT A2.CUST_NUM                                                               AS CUST_NUM                    --客户编码
        , A1.VC_CUSTOMNAME                                                             AS CUST_NAME                   --客户名称
        , A1.VC_SHORTNAME                                                              AS CUST_SNAME                  --客户简称
        , A1.C_CUSTTYPE                                                                AS C_CUSTTYPE                  --客户类型
        , ROW_NUMBER()OVER(PARTITION BY A2.CUST_NUM ORDER BY A2.LD_TIME DESC ) AS RN
        , A3.STD_DICT_CLS_CD_VAL                                                       AS CUST_CATG                   --客户类别
        , A4.STD_DICT_CLS_CD_VAL                                                       AS CUST_CERT_TYPE              --客户证件类型
        , NULL                                                                         AS CUST_CERT_NO                --客户证件号码
        , NULL                                                                         AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
        , A5.ORG_NUM                                                                   AS ORG_NUM                     --机构编码
        , A1.VC_PROFFICEADDRESS                                                        AS PTCD                        --邮编
        , regexp_replace(A1.VC_LONGREGADDRESS,'\\n/\\r/\\t','')                        AS ADDR                        --地址
        , NULL                                                                         AS FAX                         --传真号码
        , A1.VC_HOLDIDPHONE                                                            AS PHONE                       --联系电话
        , A1.VC_HOLDIDEMAIL                                                            AS MAILBOX                     --邮箱
        , NULL                                                                         AS MOBI_NO                     --手机号码
        , A1.C_SEX                                                                     AS SEX                         --客户性别
        , A1.VC_BIRTHDAY                                                               AS BIRTHDAY                    --客户生日
        , A1.C_VOCATION                                                                AS OCCU                        --职业
        , A1.C_EDUCATION                                                               AS EDU                         --学历
        , NULL                                                                         AS CORP_NAME                   --公司名称
        , NULL                                                                         AS CORP_TEL                    --公司电话
        , A1.VC_INVESTACCO                                                             AS CUST_ACCT                   --客户账户
        , A6.STD_DICT_CLS_CD_VAL                                                       AS CUST_ACCT_TYPE              --客户账户类型
        , A1.C_STATE                                                                   AS CUST_ACCT_STAT              --客户账户状态
        , A1.VC_OPENDATE                                                               AS ACCT_OPEN_DATE              --账户开户日期
        , A1.VC_LASTDATE                                                               AS ACCT_LAST_MODIFY_DATE       --账户最后修改日期
        , NULL                                                                         AS OPER                        --经办人
        , NULL                                                                         AS OPER_CERT_TYPE              --经办人证件类型
        , NULL                                                                         AS OPER_CERT_NO                --经办人证件号码
        , A1.VC_SZACCO                                                                 AS SH_SCR_ACCT                 --上交所证券账户
        , A1.VC_SHACCO                                                                 AS SZ_SCR_ACCT                 --深交所证券账户
        , 'HSDS'                                                                       AS SSYS                        --源系统
        , 'ODS_HSDS_TCUSTINFO_PFD'                                                     AS SOURCE_TAB                  --源表
        , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')     AS LD_TIME                     --加载时间
        , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')     AS MODIFY_TIME                 --修改时间
          FROM ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD A1 --客户资料
          INNER JOIN DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD A2  --新增客户编码临时表
            ON A2.cust_no = A1.VC_CUSTNO
           AND A2.ST_DATE <= '${P_BATCH_DT}'   
           AND A2.END_DATE > '${P_BATCH_DT}'    
           AND A2.P_DT = '${P_BATCH_DT}'
           AND A2.SSYS='HSDS'     
           AND A2.SRC_TAB = 'ODS_HSDS_TCUSTINFO_PFD'  
           AND A2.VALID_FLAG = '1' 
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3   --标准字典码值映射
            ON A1.C_CUSTTYPE = A3.SRC_DICT_CLS_CDVAL 
           AND A3.SSYS= 'HSDS'
           AND A3.SRC_DICT_CLS_CD= 'C_CUSTTYPE'
           AND A3.VALID_FLAG='1'
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A4  --标准字典码值映射
            ON A1.C_IDENTITYTYPE = A4.SRC_DICT_CLS_CDVAL 
           AND A4.SSYS= 'HSDS'
           AND A4.SRC_DICT_CLS_CD= 'C_IDENTITYTYPE'
           AND A4.VALID_FLAG='1'
          LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD A5  --机构编码映射表
            ON A1.VC_CUSTNO=A5.ORG_INCD
           AND A5.ST_DATE <= '${P_BATCH_DT}'    
           AND A5.END_DATE > '${P_BATCH_DT}'    
           AND A5.SSYS='HSDS'    
           AND A5.SRC_TAB = 'ODS_HSDS_TCUSTINFO_PFD' 
           AND A5.VALID_FLAG = '1' 
          LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A6  --标准字典码值映射
            ON A1.C_NESTACCOTYPE = A6.SRC_DICT_CLS_CDVAL 
           AND A6.SSYS= 'HSDS'
           AND A6.SRC_DICT_CLS_CD= 'C_NESTACCOTYPE'
           AND A6.VALID_FLAG='1'
         LEFT JOIN  DWDXDAY.DWD_PTY_CUST_INFO_TMP A7
              ON A7.CUST_NUM = A2.CUST_NUM
          WHERE A1.P_DT='${P_BATCH_DT}' AND SUBSTR(A1.VC_LASTDATE,1,8) >= '${P_BATCH_DT}'
            AND A2.SSYS = 'HSDS' 
            AND A7.CUST_NUM IS NULL) SUBT3
     WHERE RN = 1;

DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_CUST_INFO_PFD_TMP;
CREATE TABLE DWDXDAY.DWD_PTY_CUST_INFO_PFD_TMP (
CUST_NUM                  STRING       COMMENT  '客户编码',
CUST_NAME                 STRING       COMMENT  '客户名称',
CUST_SNAME                STRING       COMMENT  '客户简称',
C_CUSTTYPE                STRING       COMMENT   '客户类型',
CUST_CATG                 STRING       COMMENT  '客户类别',
CUST_CERT_TYPE            STRING       COMMENT  '客户证件类型',
CUST_CERT_NO              STRING       COMMENT  '客户证件号码',
UNIF_SOCI_CREDIT_CODE     STRING       COMMENT  '统一社会信用代码',
ORG_NUM                   STRING       COMMENT  '机构编码',
PTCD                      STRING       COMMENT  '邮编',
ADDR                      STRING       COMMENT  '地址',
FAX                       STRING       COMMENT  '传真号码',
PHONE                     STRING       COMMENT  '联系电话',
MAILBOX                   STRING       COMMENT  '邮箱',
MOBI_NO                   STRING       COMMENT  '手机号码',
SEX                       STRING       COMMENT  '客户性别',
BIRTHDAY                  STRING       COMMENT  '客户生日',
OCCU                      STRING       COMMENT  '职业',
EDU                       STRING       COMMENT  '学历',
CORP_NAME                 STRING       COMMENT  '公司名称',
CORP_TEL                  STRING       COMMENT  '公司电话',
CUST_ACCT                 STRING       COMMENT  '客户账户',
CUST_ACCT_TYPE            STRING       COMMENT  '客户账户类型',
CUST_ACCT_STAT            STRING       COMMENT  '客户账户状态',
ACCT_OPEN_DATE            STRING       COMMENT  '账户开户日期',
ACCT_LAST_MODIFY_DATE     STRING       COMMENT  '账户最后修改日期',
OPER                      STRING       COMMENT  '经办人',
OPER_CERT_TYPE            STRING       COMMENT  '经办人证件类型',
OPER_CERT_NO              STRING       COMMENT  '经办人证件号码',
SH_SCR_ACCT               STRING       COMMENT  '上交所证券账户',
SZ_SCR_ACCT               STRING       COMMENT  '深交所证券账户',
SSYS                      STRING       COMMENT  '源系统',
SOURCE_TAB                STRING       COMMENT  '源表',
LD_TIME                   STRING       COMMENT  '加载时间',
MODIFY_TIME               STRING       COMMENT  '修改时间'
)COMMENT '客户信息临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL DEFINED AS '';

INSERT INTO TABLE DWDXDAY.DWD_PTY_CUST_INFO_PFD_TMP
SELECT DISTINCT  A1.CUST_NUM                                                AS CUST_NUM                    --客户编码
   , COALESCE( A1.CUST_NAME , B1.CUST_NAME )                                AS CUST_NAME                   --客户名称
   , COALESCE( B1.CUST_SNAME , A1.CUST_SNAME )                              AS CUST_SNAME                  --客户简称
   , A1.C_CUSTTYPE
   , COALESCE( B1.CUST_CATG ,A1.CUST_CATG )                                 AS CUST_CATG                   --客户类别
   , COALESCE( B1.CUST_CERT_TYPE ,A1.CUST_CERT_TYPE )                       AS CUST_CERT_TYPE              --客户证件类型
   , COALESCE( B1.CUST_CERT_NO ,A1.CUST_CERT_NO )                           AS CUST_CERT_NO                --客户证件号码
   , COALESCE( B1.UNIF_SOCI_CREDIT_CODE ,A1.UNIF_SOCI_CREDIT_CODE )         AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
   , COALESCE( B1.ORG_NUM ,A1.ORG_NUM )                                     AS ORG_NUM                     --机构编码
   , COALESCE( B1.PTCD ,A1.PTCD )                                           AS PTCD                        --邮编
   , COALESCE( B1.ADDR ,A1.ADDR )                                           AS ADDR                        --地址
   , COALESCE( B1.FAX  ,A1.FAX  )                                           AS FAX                         --传真号码
   , COALESCE( B1.PHONE  ,A1.PHONE )                                        AS PHONE                       --联系电话
   , COALESCE( B1.MAILBOX ,A1.MAILBOX )                                     AS MAILBOX                     --邮箱
   , COALESCE( B1.MOBI_NO ,A1.MOBI_NO )                                     AS MOBI_NO                     --手机号码
   , COALESCE( B1.SEX , A1.SEX   )                                          AS SEX                         --客户性别
   , COALESCE( B1.BIRTHDAY ,A1.BIRTHDAY  )                                  AS BIRTHDAY                    --客户生日
   , COALESCE( B1.OCCU ,A1.OCCU  )                                          AS OCCU                        --职业
   , COALESCE( B1.EDU ,A1.EDU )                                             AS EDU                         --学历
   , COALESCE( B1.CORP_NAME  ,A1.CORP_NAME )                                AS CORP_NAME                   --公司名称
   , COALESCE( B1.CORP_TEL ,A1.CORP_TEL   )                                 AS CORP_TEL                    --公司电话
   , COALESCE( B1.CUST_ACCT  ,A1.CUST_ACCT  )                               AS CUST_ACCT                   --客户账户
   , COALESCE( B1.CUST_ACCT_TYPE ,A1.CUST_ACCT_TYPE )                       AS CUST_ACCT_TYPE              --客户账户类型
   , COALESCE( B1.CUST_ACCT_STAT ,A1.CUST_ACCT_STAT )                       AS CUST_ACCT_STAT              --客户账户状态
   , COALESCE( B1.ACCT_OPEN_DATE ,A1.ACCT_OPEN_DATE )                       AS ACCT_OPEN_DATE              --账户开户日期
   , COALESCE( B1.ACCT_LAST_MODIFY_DATE ,A1.ACCT_LAST_MODIFY_DATE )         AS ACCT_LAST_MODIFY_DATE       --账户最后修改日期
   , COALESCE( B1.OPER ,A1.OPER )                                           AS OPER                        --经办人
   , COALESCE( B1.OPER_CERT_TYPE ,A1.OPER_CERT_TYPE )                       AS OPER_CERT_TYPE              --经办人证件类型
   , COALESCE( B1.OPER_CERT_NO ,A1.OPER_CERT_NO  )                          AS OPER_CERT_NO                --经办人证件号码
   , COALESCE( B1.SH_SCR_ACCT  ,A1.SH_SCR_ACCT )                            AS SH_SCR_ACCT                 --上交所证券账户
   , COALESCE( B1.SZ_SCR_ACCT,A1.SZ_SCR_ACCT )                              AS SZ_SCR_ACCT                 --深交所证券账户
   , COALESCE( B1.SSYS ,A1.SSYS )                                           AS SSYS                        --源系统
   , COALESCE( B1.SOURCE_TAB ,A1.SOURCE_TAB  )                              AS SOURCE_TAB                  --源表
   , COALESCE( B1.LD_TIME  ,A1.LD_TIME  )                                   AS LD_TIME                     --加载时间
   , COALESCE( B1.MODIFY_TIME  ,A1.MODIFY_TIME )                            AS MODIFY_TIME                 --修改时间
     FROM DWDXDAY.DWD_PTY_CUST_INFO_PFD  A1  --新增客户信息表
     LEFT JOIN 
     (SELECT CUST_NUM                        AS CUST_NUM                    --客户编码
        , CUST_NAME                          AS CUST_NAME                   --客户名称
        , CUST_SNAME                         AS CUST_SNAME                  --客户简称
        , C_CUSTTYPE                         AS C_CUSTTYPE                  --客户类型
        , CUST_CATG                          AS CUST_CATG                   --客户类别
        , CUST_CERT_TYPE                     AS CUST_CERT_TYPE              --客户证件类型
        , CUST_CERT_NO                       AS CUST_CERT_NO                --客户证件号码
        , UNIF_SOCI_CREDIT_CODE              AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
        , ORG_NUM                            AS ORG_NUM                     --机构编码
        , PTCD                               AS PTCD                        --邮编
        , ADDR                               AS ADDR                        --地址
        , FAX                                AS FAX                         --传真号码
        , PHONE                              AS PHONE                       --联系电话
        , MAILBOX                            AS MAILBOX                     --邮箱
        , MOBI_NO                            AS MOBI_NO                     --手机号码
        , SEX                                AS SEX                         --客户性别
        , BIRTHDAY                           AS BIRTHDAY                    --客户生日
        , OCCU                               AS OCCU                        --职业
        , EDU                                AS EDU                         --学历
        , CORP_NAME                          AS CORP_NAME                   --公司名称
        , CORP_TEL                           AS CORP_TEL                    --公司电话
        , CUST_ACCT                          AS CUST_ACCT                   --客户账户
        , CUST_ACCT_TYPE                     AS CUST_ACCT_TYPE              --客户账户类型
        , CUST_ACCT_STAT                     AS CUST_ACCT_STAT              --客户账户状态
        , ACCT_OPEN_DATE                     AS ACCT_OPEN_DATE              --账户开户日期
        , ACCT_LAST_MODIFY_DATE              AS ACCT_LAST_MODIFY_DATE       --账户最后修改日期
        , OPER                               AS OPER                        --经办人
        , OPER_CERT_TYPE                     AS OPER_CERT_TYPE              --经办人证件类型
        , OPER_CERT_NO                       AS OPER_CERT_NO                --经办人证件号码
        , SH_SCR_ACCT                        AS SH_SCR_ACCT                 --上交所证券账户
        , SZ_SCR_ACCT                        AS SZ_SCR_ACCT                 --深交所证券账户
        , SSYS                               AS SSYS                        --源系统
        , SOURCE_TAB                         AS SOURCE_TAB                  --源表
        , LD_TIME                            AS LD_TIME                     --加载时间
        , MODIFY_TIME                        AS MODIFY_TIME                 --修改时间
          FROM DWDXDAY.DWD_PTY_CUST_INFO_TMP  )  B1 --客户信息表
       ON  A1.CUST_NUM = B1.CUST_NUM
UNION ALL
SELECT A1.CUST_NUM                        AS CUST_NUM                    --客户编码
   , A1.CUST_NAME                          AS CUST_NAME                   --客户名称
   , A1.CUST_SNAME                         AS CUST_SNAME                  --客户简称
   , A1.C_CUSTTYPE                         AS C_CUSTTYPE                  --客户类型
   , A1.CUST_CATG                          AS CUST_CATG                   --客户类别
   , A1.CUST_CERT_TYPE                     AS CUST_CERT_TYPE              --客户证件类型
   , A1.CUST_CERT_NO                       AS CUST_CERT_NO                --客户证件号码
   , A1.UNIF_SOCI_CREDIT_CODE              AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
   , A1.ORG_NUM                            AS ORG_NUM                     --机构编码
   , A1.PTCD                               AS PTCD                        --邮编
   , A1.ADDR                               AS ADDR                        --地址
   , A1.FAX                                AS FAX                         --传真号码
   , A1.PHONE                              AS PHONE                       --联系电话
   , A1.MAILBOX                            AS MAILBOX                     --邮箱
   , A1.MOBI_NO                            AS MOBI_NO                     --手机号码
   , A1.SEX                                AS SEX                         --客户性别
   , A1.BIRTHDAY                           AS BIRTHDAY                    --客户生日
   , A1.OCCU                               AS OCCU                        --职业
   , A1.EDU                                AS EDU                         --学历
   , A1.CORP_NAME                          AS CORP_NAME                   --公司名称
   , A1.CORP_TEL                           AS CORP_TEL                    --公司电话
   , A1.CUST_ACCT                          AS CUST_ACCT                   --客户账户
   , A1.CUST_ACCT_TYPE                     AS CUST_ACCT_TYPE              --客户账户类型
   , A1.CUST_ACCT_STAT                     AS CUST_ACCT_STAT              --客户账户状态
   , A1.ACCT_OPEN_DATE                     AS ACCT_OPEN_DATE              --账户开户日期
   , A1.ACCT_LAST_MODIFY_DATE              AS ACCT_LAST_MODIFY_DATE       --账户最后修改日期
   , A1.OPER                               AS OPER                        --经办人
   , A1.OPER_CERT_TYPE                     AS OPER_CERT_TYPE              --经办人证件类型
   , A1.OPER_CERT_NO                       AS OPER_CERT_NO                --经办人证件号码
   , A1.SH_SCR_ACCT                        AS SH_SCR_ACCT                 --上交所证券账户
   , A1.SZ_SCR_ACCT                        AS SZ_SCR_ACCT                 --深交所证券账户
   , A1.SSYS                               AS SSYS                        --源系统
   , A1.SOURCE_TAB                         AS SOURCE_TAB                  --源表
   , A1.LD_TIME                            AS LD_TIME                     --加载时间
   , A1.MODIFY_TIME                        AS MODIFY_TIME                 --修改时间
     FROM DWDXDAY.DWD_PTY_CUST_INFO_TMP A1     --客户信息表
    WHERE A1.CUST_NUM NOT IN (SELECT CUST_NUM FROM DWDXDAY.DWD_PTY_CUST_INFO_PFD) ;
 
 

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_INFO_PFD
SELECT A1.CUST_NUM                        AS CUST_NUM                    --客户编码
   , A1.CUST_NAME                          AS CUST_NAME                   --客户名称
   , A1.CUST_SNAME                         AS CUST_SNAME                  --客户简称
   , A1.C_CUSTTYPE                         AS C_CUSTTYPE                  --客户类型
   , A1.CUST_CATG                          AS CUST_CATG                   --客户类别
   , A1.CUST_CERT_TYPE                     AS CUST_CERT_TYPE              --客户证件类型
   , A1.CUST_CERT_NO                       AS CUST_CERT_NO                --客户证件号码
   , A1.UNIF_SOCI_CREDIT_CODE              AS UNIF_SOCI_CREDIT_CODE       --统一社会信用代码
   , A1.ORG_NUM                            AS ORG_NUM                     --机构编码
   , A1.PTCD                               AS PTCD                        --邮编
   , A1.ADDR                               AS ADDR                        --地址
   , A1.FAX                                AS FAX                         --传真号码
   , A1.PHONE                              AS PHONE                       --联系电话
   , A1.MAILBOX                            AS MAILBOX                     --邮箱
   , A1.MOBI_NO                            AS MOBI_NO                     --手机号码
   , A1.SEX                                AS SEX                         --客户性别
   , A1.BIRTHDAY                           AS BIRTHDAY                    --客户生日
   , A1.OCCU                               AS OCCU                        --职业
   , A1.EDU                                AS EDU                         --学历
   , A1.CORP_NAME                          AS CORP_NAME                   --公司名称
   , A1.CORP_TEL                           AS CORP_TEL                    --公司电话
   , A1.CUST_ACCT                          AS CUST_ACCT                   --客户账户
   , A1.CUST_ACCT_TYPE                     AS CUST_ACCT_TYPE              --客户账户类型
   , A1.CUST_ACCT_STAT                     AS CUST_ACCT_STAT              --客户账户状态
   , A1.ACCT_OPEN_DATE                     AS ACCT_OPEN_DATE              --账户开户日期
   , A1.ACCT_LAST_MODIFY_DATE              AS ACCT_LAST_MODIFY_DATE       --账户最后修改日期
   , A1.OPER                               AS OPER                        --经办人
   , A1.OPER_CERT_TYPE                     AS OPER_CERT_TYPE              --经办人证件类型
   , A1.OPER_CERT_NO                       AS OPER_CERT_NO                --经办人证件号码
   , A1.SH_SCR_ACCT                        AS SH_SCR_ACCT                 --上交所证券账户
   , A1.SZ_SCR_ACCT                        AS SZ_SCR_ACCT                 --深交所证券账户
   , A1.SSYS                               AS SSYS                        --源系统
   , A1.SOURCE_TAB                         AS SOURCE_TAB                  --源表
   , A1.LD_TIME                            AS LD_TIME                     --加载时间
   , A1.MODIFY_TIME                        AS MODIFY_TIME                 --修改时间
     FROM DWDXDAY.DWD_PTY_CUST_INFO_PFD_TMP A1;  --客户信息临时表
"
