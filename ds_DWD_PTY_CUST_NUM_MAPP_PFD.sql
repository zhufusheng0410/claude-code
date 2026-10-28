
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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT PARTITION(P_DT='${P_BATCH_DT}')
SELECT LPAD(CAST((row_number() over () + A2.MAXID ) AS BIGINT),9,0)                        AS ID                   --序号    
   , CONCAT ('CUST','1',LPAD(CAST((row_number() over () + A2.MAXID) AS BIGINT),9,0),'1')   AS CUST_NUM             --客户编码
   , A1.C_CUSTNO                                                                        AS CUST_NO              --客户编号
   , A1.C_CUSTNAME                                                                      AS CUST_NAME            --客户名称
   , A1.C_CUSTTYPE                                                                       AS C_CUSTTYPE         --客户类型
   , '19000101'                                                                         AS ST_DATE              --开始日期
   , '29991231'                                                                         AS END_DATE             --结束日期
   , '1'                                                                                AS VALID_FLAG           --有效标识
   , 'HSZTA'                                                                            AS SSYS                 --源系统
   , 'ODS_HSZTA_TCUSTINFO_PFD'                                                          AS SRC_TAB              --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')         AS LD_TIME              --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS MODIFY_TIME          --修改时间
   , A1.C_IDENTITYTYPE                                                                  AS C_IDENTITYTYPE       --证件类型
   , A1.C_IDENTITYNO                                                                    AS C_IDENTITYNO         --证件号码                                                        
     FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD A1                                     --客户基本信息 
     LEFT JOIN  (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT ) A2  --HSZTA客户编码映射表
       ON '1'= '1'                                                  
     WHERE (SUBSTR(A1.D_LASTMODIFY,1,8) >= '${P_BATCH_DT}' OR A1.C_CUSTNO NOT IN (SELECT CUST_NO FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD WHERE SSYS = 'HSZTA' 
      AND P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),1),'yyyyMMdd') )
           )
      AND A1.P_DT = '${P_BATCH_DT}' AND  A1.C_CUSTTYPE <>'2';

INSERT INTO TABLE DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT PARTITION(P_DT='${P_BATCH_DT}')
SELECT LPAD(CAST((row_number() over () + A2.MAXID ) AS BIGINT),9,0)                        AS ID                   --序号    
   , CONCAT ('CUST','1',LPAD(CAST((row_number() over () + A2.MAXID) AS BIGINT),9,0),'1')   AS CUST_NUM             --客户编码
   , A1.C_CUSTNO                                                                        AS CUST_NO              --客户编号
   , A1.C_CUSTNAME                                                                      AS CUST_NAME            --客户名称
   , A1.C_CUSTTYPE                                                                       AS C_CUSTTYPE         --客户类型
   , '19000101'                                                                         AS ST_DATE              --开始日期
   , '29991231'                                                                         AS END_DATE             --结束日期
   , '1'                                                                                AS VALID_FLAG           --有效标识
   , 'HSZTA'                                                                            AS SSYS                 --源系统
   , 'ODS_HSZTA_TCUSTINFO_PFD'                                                          AS SRC_TAB              --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')         AS LD_TIME              --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS MODIFY_TIME          --修改时间
   , A1.C_IDENTITYTYPE                                                                  AS C_IDENTITYTYPE       --证件类型
   , A1.C_IDENTITYNO                                                                    AS C_IDENTITYNO         --证件号码                                                        
     FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD A1                                     --客户基本信息 
     LEFT JOIN  (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT ) A2  --HSZTA客户编码映射表
       ON '1'= '1'                                                  
     WHERE (SUBSTR(A1.D_LASTMODIFY,1,8) >= '${P_BATCH_DT}' OR A1.C_CUSTNO NOT IN (SELECT CUST_NO FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD WHERE SSYS = 'HSZTA' 
      AND P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),1),'yyyyMMdd') )
           )
      AND A1.P_DT = '${P_BATCH_DT}' AND  A1.C_CUSTTYPE ='2';


INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT PARTITION(P_DT='${P_BATCH_DT}')
SELECT LPAD(CAST((row_number() over () + B2.MAXID ) AS BIGINT),9,0)                        AS ID                 --序号     
   , CONCAT ('CUST','2',LPAD(CAST((row_number() over () + B2.MAXID) AS BIGINT),9,0),'1')   AS CUST_NUM           --客户编码
   , B1.C_CUSTNO                                                                        AS CUST_NO            --客户编号
   , B1.C_CUSTNAME                                                                      AS CUST_NAME          --客户名称
   , B1.C_CUSTTYPE
   , '19000101'                                                                         AS ST_DATE            --开始日期
   , '29991231'                                                                         AS END_DATE           --结束日期
   , '1'                                                                                AS VALID_FLAG         --有效标识
   , 'HSFTA'                                                                            AS SSYS               --源系统
   , 'ODS_HSFTA_TCUSTOMERINFO_PFD'                                                      AS SRC_TAB            --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS LD_TIME            --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS MODIFY_TIME        --修改时间
   , B1.C_IDENTITYTYPE                                                                  AS C_IDENTITYTYPE     --证件类型
   , B1.C_IDENTITYNO                                                                    AS C_IDENTITYNO       --证件号码
     FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD B1                                --客户基本信息 
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT ) B2  --HSFTA客户编码映射表
       ON '1' = '1'                                                
     WHERE (REPLACE(SUBSTR(B1.D_APPENDDATE,1,10),'-','') >= '${P_BATCH_DT}' OR  B1.C_CUSTNO NOT IN (SELECT CUST_NO FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD WHERE SSYS = 'HSFTA' 
      AND P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),1),'yyyyMMdd'))
           )
      AND B1.P_DT = '${P_BATCH_DT}' AND B1.C_CUSTTYPE <> '2';

INSERT INTO TABLE DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT PARTITION(P_DT='${P_BATCH_DT}')
SELECT LPAD(CAST((row_number() over () + B2.MAXID ) AS BIGINT),9,0)                        AS ID                 --序号     
   , CONCAT ('CUST','2',LPAD(CAST((row_number() over () + B2.MAXID) AS BIGINT),9,0),'1')   AS CUST_NUM           --客户编码
   , B1.C_CUSTNO                                                                        AS CUST_NO            --客户编号
   , B1.C_CUSTNAME                                                                      AS CUST_NAME          --客户名称
   , B1.C_CUSTTYPE                                                                       AS C_CUSTTYPE         --客户类型
   , '19000101'                                                                         AS ST_DATE            --开始日期
   , '29991231'                                                                         AS END_DATE           --结束日期
   , '1'                                                                                AS VALID_FLAG         --有效标识
   , 'HSFTA'                                                                            AS SSYS               --源系统
   , 'ODS_HSFTA_TCUSTOMERINFO_PFD'                                                      AS SRC_TAB            --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS LD_TIME            --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')           AS MODIFY_TIME        --修改时间
   , B1.C_IDENTITYTYPE                                                                  AS C_IDENTITYTYPE     --证件类型
   , B1.C_IDENTITYNO                                                                    AS C_IDENTITYNO       --证件号码
     FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD B1                                --客户基本信息 
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT ) B2  --HSFTA客户编码映射表
       ON '1' = '1'                                                
     WHERE (REPLACE(SUBSTR(B1.D_APPENDDATE,1,10),'-','') >= '${P_BATCH_DT}' OR  B1.C_CUSTNO NOT IN (SELECT CUST_NO FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD WHERE SSYS = 'HSFTA' 
      AND P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),1),'yyyyMMdd'))
           )
      AND B1.P_DT = '${P_BATCH_DT}' AND  B1.C_CUSTTYPE = '2';


INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT PARTITION(P_DT='${P_BATCH_DT}')
SELECT LPAD(CAST((row_number() over () + C2.MAXID ) AS BIGINT),9,0)                       AS ID                  --序号    
   , CONCAT ('CUST','3',LPAD(CAST((row_number() over () + C2.MAXID) AS BIGINT),9,0),'1')  AS CUST_NUM            --客户编码
   , C1.VC_CUSTNO                                                                      AS CUST_NO             --客户编号
   , C1.VC_CUSTOMNAME                                                                  AS CUST_NAME           --客户名称
   , C1.C_CUSTTYPE                                                                     AS C_CUSTTYPE         --客户类型
   , '19000101'                                                                        AS ST_DATE             --开始日期
   , '29991231'                                                                        AS END_DATE            --结束日期
   , '1'                                                                               AS VALID_FLAG          --有效标识
   , 'HSDS'                                                                            AS SSYS                --源系统
   , 'ODS_HSDS_TCUSTINFO_PFD'                                                          AS SRC_TAB             --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')          AS LD_TIME             --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')          AS MODIFY_TIME         --修改时间
   , C1.C_IDENTITYTYPE                                                                 AS C_IDENTITYTYPE      --证件类型
   , C1.VC_IDENTITYNO                                                                  AS C_IDENTITYNO        --证件号码
     FROM ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD C1                                     --客户资料 
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT ) C2  --HSDS客户编码映射表
       ON '1' = '1'
     WHERE (SUBSTR(C1.VC_LASTDATE,1,8) >= '${P_BATCH_DT}' OR  C1.VC_CUSTNO NOT IN (SELECT CUST_NO FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD WHERE SSYS = 'HSDS' 
      AND P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),1),'yyyyMMdd'))
           )
      AND C1.P_DT = '${P_BATCH_DT}' AND C1.C_CUSTTYPE <> '2';

INSERT INTO TABLE DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT PARTITION(P_DT='${P_BATCH_DT}')
SELECT LPAD(CAST((row_number() over () + C2.MAXID ) AS BIGINT),9,0)                       AS ID                  --序号    
   , CONCAT ('CUST','3',LPAD(CAST((row_number() over () + C2.MAXID) AS BIGINT),9,0),'1')  AS CUST_NUM            --客户编码
   , C1.VC_CUSTNO                                                                      AS CUST_NO             --客户编号
   , C1.VC_CUSTOMNAME                                                                  AS CUST_NAME           --客户名称
   , C1.C_CUSTTYPE                                                                     AS C_CUSTTYPE         --客户类型
   , '19000101'                                                                        AS ST_DATE             --开始日期
   , '29991231'                                                                        AS END_DATE            --结束日期
   , '1'                                                                               AS VALID_FLAG          --有效标识
   , 'HSDS'                                                                            AS SSYS                --源系统
   , 'ODS_HSDS_TCUSTINFO_PFD'                                                          AS SRC_TAB             --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')          AS LD_TIME             --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')          AS MODIFY_TIME         --修改时间
   , C1.C_IDENTITYTYPE                                                                 AS C_IDENTITYTYPE      --证件类型
   , C1.VC_IDENTITYNO                                                                  AS C_IDENTITYNO        --证件号码
     FROM ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD C1                                     --客户资料 
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT ) C2  --HSDS客户编码映射表
       ON '1' = '1'
     WHERE (SUBSTR(C1.VC_LASTDATE,1,8)  >= '${P_BATCH_DT}' OR  C1.VC_CUSTNO  NOT IN (SELECT CUST_NO FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD WHERE SSYS = 'HSDS' 
      AND P_DT = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),1),'yyyyMMdd'))
           )
      AND C1.P_DT = '${P_BATCH_DT}' AND C1.C_CUSTTYPE = '2';


DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP;
CREATE TABLE DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP (
CUST_NUM            STRING         COMMENT            '客户编码',
CUST_NO             STRING         COMMENT            '客户编号',
CUST_NAME           STRING         COMMENT            '客户名称',
C_CUSTTYPE          STRING         COMMENT            '客户类型',
ST_DATE             STRING         COMMENT            '开始日期',
END_DATE            STRING         COMMENT            '结束日期',
VALID_FLAG          STRING         COMMENT            '有效标识',
SSYS                STRING         COMMENT            '源系统',
SRC_TAB             STRING         COMMENT            '源表',
LD_TIME             STRING         COMMENT            '加载时间',
MODIFY_TIME         STRING         COMMENT            '修改时间',
C_IDENTITYTYPE      STRING         COMMENT            '证件类型',
C_IDENTITYNO        STRING         COMMENT            '证件号码'
)COMMENT '新增客户编码临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL DEFINED AS '';
INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP
SELECT  CUST_NUM                    --客户编码
   , CUST_NO                     --客户编号
   , CUST_NAME                   --客户名称
   , C_CUSTTYPE                  --客户类型
   , ST_DATE                     --开始日期
   , END_DATE                    --结束日期
   , VALID_FLAG                  --有效标识
   , SSYS                        --源系统
   , SRC_TAB                     --源表
   , LD_TIME                     --加载时间
   , MODIFY_TIME                 --修改时间
   , C_IDENTITYTYPE              --证件类型
   , C_IDENTITYNO                --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT  --HSZTA客户编码映射表  
     WHERE P_DT = '${P_BATCH_DT}' AND  C_CUSTTYPE <> '2'
UNION ALL
SELECT  A.CUST_NUM                    --客户编码
   , A.CUST_NO                     --客户编号
   , A.CUST_NAME                   --客户名称
   , A.C_CUSTTYPE                    --客户类型
   , A.ST_DATE                     --开始日期
   , A.END_DATE                    --结束日期
   , A.VALID_FLAG                  --有效标识
   , A.SSYS                        --源系统
   , A.SRC_TAB                     --源表
   , A.LD_TIME                     --加载时间
   , A.MODIFY_TIME                 --修改时间
   , A.C_IDENTITYTYPE              --证件类型
   , A.C_IDENTITYNO                --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT A   --HSFTA客户编码映射表
     WHERE A.P_DT = '${P_BATCH_DT}' AND A.C_CUSTTYPE <> '2'
       AND NOT EXISTS (SELECT 1 FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT B WHERE  A.C_IDENTITYTYPE = B.C_IDENTITYTYPE AND A.C_IDENTITYNO=B.C_IDENTITYNO AND B.C_CUSTTYPE <> '2' )
UNION ALL
SELECT CUST_NUM                    --客户编码
   , A.CUST_NO                     --客户编号
   , A.CUST_NAME                   --客户名称
   , A.C_CUSTTYPE                    --客户类型
   , A.ST_DATE                     --开始日期
   , A.END_DATE                    --结束日期
   , A.VALID_FLAG                  --有效标识
   , A.SSYS                        --源系统
   , A.SRC_TAB                     --源表
   , A.LD_TIME                     --加载时间
   , A.MODIFY_TIME                 --修改时间
   , A.C_IDENTITYTYPE              --证件类型
   , A.C_IDENTITYNO                --证件号码
     FROM  DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT A --HSDS客户编码映射表
     WHERE A.P_DT = '${P_BATCH_DT}' AND A.C_CUSTTYPE <> '2'
       AND NOT EXISTS (SELECT 1 FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT B WHERE  A.C_IDENTITYTYPE =B.C_IDENTITYTYPE AND A.C_IDENTITYNO=B.C_IDENTITYNO AND B.C_CUSTTYPE <> '2' )
      AND NOT EXISTS (SELECT 1 FROM DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT C WHERE   A.C_IDENTITYTYPE =C.C_IDENTITYTYPE AND A.C_IDENTITYNO=C.C_IDENTITYNO AND C.C_CUSTTYPE <> '2');

INSERT INTO TABLE DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP
SELECT  CUST_NUM                    --客户编码
   , CUST_NO                     --客户编号
   , CUST_NAME                   --客户名称
   , C_CUSTTYPE                  --客户类型
   , ST_DATE                     --开始日期
   , END_DATE                    --结束日期
   , VALID_FLAG                  --有效标识
   , SSYS                        --源系统
   , SRC_TAB                     --源表
   , LD_TIME                     --加载时间
   , MODIFY_TIME                 --修改时间
   , C_IDENTITYTYPE              --证件类型
   , C_IDENTITYNO                --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT  --HSZTA客户编码映射表  
     WHERE P_DT = '${P_BATCH_DT}' AND  C_CUSTTYPE = '2'
UNION ALL
SELECT  A.CUST_NUM                    --客户编码
   , A.CUST_NO                     --客户编号
   , A.CUST_NAME                   --客户名称
   , A.C_CUSTTYPE                    --客户类型
   , A.ST_DATE                     --开始日期
   , A.END_DATE                    --结束日期
   , A.VALID_FLAG                  --有效标识
   , A.SSYS                        --源系统
   , A.SRC_TAB                     --源表
   , A.LD_TIME                     --加载时间
   , A.MODIFY_TIME                 --修改时间
   , A.C_IDENTITYTYPE              --证件类型
   , A.C_IDENTITYNO                --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT A   --HSFTA客户编码映射表
     WHERE A.P_DT = '${P_BATCH_DT}' AND A.C_CUSTTYPE = '2'
       AND NOT EXISTS (SELECT 1 FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT B WHERE  A.CUST_NAME = B.CUST_NAME AND A.C_IDENTITYTYPE = B.C_IDENTITYTYPE AND A.C_IDENTITYNO=B.C_IDENTITYNO AND B.C_CUSTTYPE ='2' )
UNION ALL
SELECT CUST_NUM                    --客户编码
   , A.CUST_NO                     --客户编号
   , A.CUST_NAME                   --客户名称
   , A.C_CUSTTYPE                    --客户类型
   , A.ST_DATE                     --开始日期
   , A.END_DATE                    --结束日期
   , A.VALID_FLAG                  --有效标识
   , A.SSYS                        --源系统
   , A.SRC_TAB                     --源表
   , A.LD_TIME                     --加载时间
   , A.MODIFY_TIME                 --修改时间
   , A.C_IDENTITYTYPE              --证件类型
   , A.C_IDENTITYNO                --证件号码
     FROM  DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT A --HSDS客户编码映射表
     WHERE A.P_DT = '${P_BATCH_DT}' AND A.C_CUSTTYPE = '2'
       AND NOT EXISTS (SELECT 1 FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT B WHERE A.CUST_NAME = B.CUST_NAME AND A.C_IDENTITYTYPE =B.C_IDENTITYTYPE AND A.C_IDENTITYNO=B.C_IDENTITYNO AND B.C_CUSTTYPE = '2' )
      AND NOT EXISTS (SELECT 1 FROM DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT C WHERE  A.CUST_NAME = C.CUST_NAME AND  A.C_IDENTITYTYPE =C.C_IDENTITYTYPE AND A.C_IDENTITYNO=C.C_IDENTITYNO AND C.C_CUSTTYPE = '2' );


DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP_1;
CREATE TABLE DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP_1 (
CUST_NUM            STRING         COMMENT            '客户编码',
CUST_NO             STRING         COMMENT            '客户编号',
CUST_NAME           STRING         COMMENT            '客户名称',
C_CUSTTYPE          STRING         COMMENT            '客户类型',
ST_DATE             STRING         COMMENT            '开始日期',
END_DATE            STRING         COMMENT            '结束日期',
VALID_FLAG          STRING         COMMENT            '有效标识',
SSYS                STRING         COMMENT            '源系统',
SRC_TAB             STRING         COMMENT            '源表',
LD_TIME             STRING         COMMENT            '加载时间',
MODIFY_TIME         STRING         COMMENT            '修改时间',
C_IDENTITYTYPE      STRING         COMMENT            '证件类型',
C_IDENTITYNO        STRING         COMMENT            '证件号码'
)COMMENT '新增客户编码临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL DEFINED AS '';


INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP_1
SELECT A1.CUST_NUM                                         AS CUST_NUM          --客户编码
   , A1.CUST_NO                                            AS CUST_NO           --客户编号
   , A1.CUST_NAME                                          AS CUST_NAME         --客户名称
   , A1.C_CUSTTYPE                                         AS C_CUSTTYPE        --客户类型
   , A1.ST_DATE                                            AS ST_DATE           --开始日期
   , A1.END_DATE                                           AS END_DATE          --结束日期
   , A1.VALID_FLAG                                         AS VALID_FLAG        --有效标识
   , A1.SSYS                                               AS SSYS              --源系统
   , A1.SRC_TAB                                            AS SRC_TAB           --源表
   , A1.LD_TIME                                            AS LD_TIME           --加载时间
   , A1.MODIFY_TIME                                        AS MODIFY_TIME       --修改时间
   , A1.C_IDENTITYTYPE                                     AS C_IDENTITYTYPE    --证件类型
   , A1.C_IDENTITYNO                                       AS C_IDENTITYNO      --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT A1  --HSZTA客户编码映射表
     WHERE A1.P_DT = '${P_BATCH_DT}' AND A1.C_CUSTTYPE <> '2'
UNION ALL 
SELECT COALESCE ( B2.CUST_NUM ,B1.CUST_NUM)               AS CUST_NUM          --客户编码
   , B1.CUST_NO                      AS CUST_NO           --客户编号
   , B1.CUST_NAME                  AS CUST_NAME         --客户名称
   , B1.C_CUSTTYPE                  AS C_CUSTTYPE        --客户类型
   , B1.ST_DATE                      AS ST_DATE           --开始日期
   , B1.END_DATE                    AS END_DATE          --结束日期
   , B1.VALID_FLAG                AS VALID_FLAG        --有效标识
   , B1.SSYS                            AS SSYS              --源系统
   , B1.SRC_TAB                      AS SRC_TAB           --源表
   , B1.LD_TIME                      AS LD_TIME           --加载时间
   , B1.MODIFY_TIME              AS MODIFY_TIME       --修改时间
   , B1.C_IDENTITYTYPE        AS C_IDENTITYTYPE    --证件类型
   , B1.C_IDENTITYNO            AS C_IDENTITYNO      --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT B1    --HSFTA客户编码映射表
     LEFT JOIN  DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP B2   --新增客户编码临时表
       ON B1.C_IDENTITYTYPE = B2.C_IDENTITYTYPE
      AND B1.C_IDENTITYNO = B2.C_IDENTITYNO
     WHERE B1.P_DT = '${P_BATCH_DT}' AND B1.C_CUSTTYPE <> '2'
UNION ALL
SELECT COALESCE ( C2.CUST_NUM ,C1.CUST_NUM)               AS CUST_NUM          --客户编码
   , C1.CUST_NO                     AS CUST_NO           --客户编号
   , C1.CUST_NAME                  AS CUST_NAME         --客户名称
   , C1.C_CUSTTYPE                 AS C_CUSTTYPE        --客户类型
   , C1.ST_DATE                      AS ST_DATE           --开始日期
   , C1.END_DATE                    AS END_DATE          --结束日期
   , C1.VALID_FLAG                AS VALID_FLAG        --有效标识
   , C1.SSYS                            AS SSYS              --源系统
   , C1.SRC_TAB                      AS SRC_TAB           --源表
   , C1.LD_TIME                      AS LD_TIME           --加载时间
   , C1.MODIFY_TIME              AS MODIFY_TIME       --修改时间
   , C1.C_IDENTITYTYPE        AS C_IDENTITYTYPE    --证件类型
   , C1.C_IDENTITYNO            AS C_IDENTITYNO      --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT C1   --HSDS客户编码映射表
     LEFT JOIN DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP C2   --新增客户编码临时表
       ON C1.C_IDENTITYTYPE = C2.C_IDENTITYTYPE
      AND C1.C_IDENTITYNO = C2.C_IDENTITYNO
      WHERE C1.P_DT = '${P_BATCH_DT}' AND  C1.C_CUSTTYPE <> '2'
UNION ALL
SELECT A1.CUST_NUM                                         AS CUST_NUM          --客户编码
   , A1.CUST_NO                                            AS CUST_NO           --客户编号
   , A1.CUST_NAME                                          AS CUST_NAME         --客户名称
   , A1.C_CUSTTYPE                                         AS C_CUSTTYPE        --客户类型
   , A1.ST_DATE                                            AS ST_DATE           --开始日期
   , A1.END_DATE                                           AS END_DATE          --结束日期
   , A1.VALID_FLAG                                         AS VALID_FLAG        --有效标识
   , A1.SSYS                                               AS SSYS              --源系统
   , A1.SRC_TAB                                            AS SRC_TAB           --源表
   , A1.LD_TIME                                            AS LD_TIME           --加载时间
   , A1.MODIFY_TIME                                        AS MODIFY_TIME       --修改时间
   , A1.C_IDENTITYTYPE                                     AS C_IDENTITYTYPE    --证件类型
   , A1.C_IDENTITYNO                                       AS C_IDENTITYNO      --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSZTA_PTD_INT A1  --HSZTA客户编码映射表
     WHERE A1.P_DT = '${P_BATCH_DT}' AND A1.C_CUSTTYPE = '2'
UNION ALL 
SELECT COALESCE ( B2.CUST_NUM ,B1.CUST_NUM)               AS CUST_NUM          --客户编码
   , B1.CUST_NO                      AS CUST_NO           --客户编号
   , B1.CUST_NAME                  AS CUST_NAME         --客户名称
   , B1.C_CUSTTYPE                  AS C_CUSTTYPE        --客户类型
   , B1.ST_DATE                      AS ST_DATE           --开始日期
   , B1.END_DATE                    AS END_DATE          --结束日期
   , B1.VALID_FLAG                AS VALID_FLAG        --有效标识
   , B1.SSYS                            AS SSYS              --源系统
   , B1.SRC_TAB                      AS SRC_TAB           --源表
   , B1.LD_TIME                      AS LD_TIME           --加载时间
   , B1.MODIFY_TIME              AS MODIFY_TIME       --修改时间
   , B1.C_IDENTITYTYPE        AS C_IDENTITYTYPE    --证件类型
   , B1.C_IDENTITYNO            AS C_IDENTITYNO      --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSFTA_PTD_INT B1    --HSFTA客户编码映射表
     LEFT JOIN  DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP B2   --新增客户编码临时表
       ON B1.C_IDENTITYTYPE = B2.C_IDENTITYTYPE
      AND B1.C_IDENTITYNO = B2.C_IDENTITYNO
      AND B1.CUST_NAME = B2.CUST_NAME
      AND B1.C_CUSTTYPE = B2.C_CUSTTYPE
     WHERE B1.P_DT = '${P_BATCH_DT}' AND B1.C_CUSTTYPE = '2'
UNION ALL
SELECT COALESCE ( C2.CUST_NUM ,C1.CUST_NUM)               AS CUST_NUM          --客户编码
   , C1.CUST_NO                     AS CUST_NO           --客户编号
   , C1.CUST_NAME                  AS CUST_NAME         --客户名称
   , C1.C_CUSTTYPE                 AS C_CUSTTYPE        --客户类型
   , C1.ST_DATE                      AS ST_DATE           --开始日期
   , C1.END_DATE                    AS END_DATE          --结束日期
   , C1.VALID_FLAG                AS VALID_FLAG        --有效标识
   , C1.SSYS                            AS SSYS              --源系统
   , C1.SRC_TAB                      AS SRC_TAB           --源表
   , C1.LD_TIME                      AS LD_TIME           --加载时间
   , C1.MODIFY_TIME              AS MODIFY_TIME       --修改时间
   , C1.C_IDENTITYTYPE        AS C_IDENTITYTYPE    --证件类型
   , C1.C_IDENTITYNO            AS C_IDENTITYNO      --证件号码
     FROM DWDXDAY.DWD_PTY_CUST_NUM_HSDS_PTD_INT C1   --HSDS客户编码映射表
     LEFT JOIN DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP C2   --新增客户编码临时表
       ON C1.C_IDENTITYTYPE = C2.C_IDENTITYTYPE
      AND C1.C_IDENTITYNO = C2.C_IDENTITYNO
      AND C1.CUST_NAME = C2.CUST_NAME
      AND C1.C_CUSTTYPE = C2.C_CUSTTYPE
      WHERE C1.P_DT = '${P_BATCH_DT}' AND  C1.C_CUSTTYPE = '2'
;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD PARTITION (p_dt = '${P_BATCH_DT}')
SELECT COALESCE(A.CUST_NUM,B.CUST_NUM )
  ,COALESCE(B.CUST_NO       , A.CUST_NO       )
  ,COALESCE(B.CUST_NAME     , A.CUST_NAME     )
  ,COALESCE(B.C_CUSTTYPE    , A.C_CUSTTYPE    )
  ,COALESCE(B.ST_DATE       , A.ST_DATE       )
  ,COALESCE(B.END_DATE      , A.END_DATE      )
  ,COALESCE(B.VALID_FLAG    , A.VALID_FLAG    )
  ,COALESCE(B.SSYS          , A.SSYS          )
  ,COALESCE(B.SRC_TAB       , A.SRC_TAB       )
  ,COALESCE(B.LD_TIME       , A.LD_TIME       )
  ,COALESCE(B.MODIFY_TIME   , A.MODIFY_TIME   )
  ,COALESCE(B.C_IDENTITYTYPE, A.C_IDENTITYTYPE)
  ,COALESCE(B.C_IDENTITYNO  , A.C_IDENTITYNO  )
  FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD A 
  LEFT JOIN  DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP_1 B
   ON A.CUST_NO = B.CUST_NO 
  AND A.SSYS = B.SSYS
  WHERE  A.P_DT =DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),1),'yyyyMMdd')
UNION ALL 
SELECT A.CUST_NUM
  ,A.CUST_NO       
  ,A.CUST_NAME     
  ,A.C_CUSTTYPE    
  ,A.ST_DATE       
  ,A.END_DATE      
  ,A.VALID_FLAG    
  ,A.SSYS          
  ,A.SRC_TAB       
  ,A.LD_TIME       
  ,A.MODIFY_TIME   
  ,A.C_IDENTITYTYPE
  ,A.C_IDENTITYNO  
  FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD_TMP_1 A 
  LEFT JOIN  DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD  B
   ON A.CUST_NO = B.CUST_NO 
  AND A.SSYS = B.SSYS
  AND  B.P_DT =DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),1),'yyyyMMdd')
   WHERE   B.CUST_NO  IS NULL;

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD PARTITION (p_dt = '${P_BATCH_DT}')
SELECT CUST_NUM
,CUST_NO
,CUST_NAME      
,C_CUSTTYPE     
,ST_DATE        
,END_DATE       
,CASE WHEN RN = '1' THEN '1'ELSE '0' END     
,SSYS           
,SRC_TAB        
,LD_TIME        
,MODIFY_TIME    
,C_IDENTITYTYPE 
,C_IDENTITYNO   
FROM 
(SELECT A1.CUST_NUM       AS CUST_NUM
,A1.CUST_NO        AS CUST_NO
,A1.CUST_NAME      AS CUST_NAME     
,A1.C_CUSTTYPE     AS C_CUSTTYPE    
,A1.ST_DATE        AS ST_DATE       
,A1.END_DATE       AS END_DATE      
,A1.VALID_FLAG     AS VALID_FLAG    
,A1.SSYS           AS SSYS          
,A1.SRC_TAB        AS SRC_TAB       
,A1.LD_TIME        AS LD_TIME       
,A1.MODIFY_TIME    AS MODIFY_TIME   
,A1.C_IDENTITYTYPE AS C_IDENTITYTYPE
,A1.C_IDENTITYNO   AS C_IDENTITYNO  
FROM DWDXDAY.DWD_PTY_CUST_NUM_MAPP_PFD A1 WHERE A1.P_DT = '${P_BATCH_DT}' ) T;
"
