
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

set hive.strict.checks.type.safety=false;


set hive.mapred.mode = nonstrict;


set mapred.max.split.size=256000000;


set mapred.min.split.size.per.node=100000000;


set mapred.min.split.size.per.rack=100000000;


set hive.merge.mapredfiles=true;


set hive.merge.mapfiles=true;


set hive.merge.smallfiles.avgsize=16000000;


set hive.merge.size.per.task=256000000;


set hive.exec.reducers.bytes.per.reducer=10240000000;

 
set mapreduce.job.reduces=3;



INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT PARTITION (P_DT= '${P_BATCH_DT}')
SELECT  LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0)                                AS ID                --序号
        ,CONCAT ('INST','4','1',LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0),'1')   AS RI_ORG_NUM        --机构编码
       , A.RI_L_RIVAL_ID                                                                          AS RI_L_RIVAL_ID     --机构内码
       , A.RI_VC_ALL_NAME                                                                         AS RI_VC_ALL_NAME    --机构名称
       , A.RI_ST_DATE                                                                             AS RI_ST_DATE        --开始日期
       , A.RI_END_DATE                                                                            AS RI_END_DATE       --结束日期
       , A.RI_VALID_FLAG                                                                          AS RI_VALID_FLAG     --有效标识
       , A.RI_SSYS                                                                                AS RI_SSYS           --源系统
       , A.RI_SRC_TAB                                                                             AS RI_SRC_TAB        --源表
       , A.RI_LD_TIME                                                                             AS RI_LD_TIME        --加载时间
       , A.RI_MODIFY_TIME                                                                         AS RI_MODIFY_TIME    --修改时间
       FROM 
       (SELECT A1.L_RIVAL_ID                                                                     AS RI_L_RIVAL_ID     --机构内码
          ,COALESCE(A1.VC_ALL_NAME,A1.VC_NAME)                                                   AS RI_VC_ALL_NAME    --机构名称
          ,'19000101'                                                                            AS RI_ST_DATE        --开始日期
          ,'29991231'                                                                            AS RI_END_DATE       --结束日期
          ,'1'                                                                                   AS RI_VALID_FLAG     --有效标识
          ,'O32'                                                                                 AS RI_SSYS           --源系统
          ,'ODS_O32_TTRADERIVAL_PFD'                                                             AS RI_SRC_TAB        --源表
          ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')              AS RI_LD_TIME        --加载时间
          ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')              AS RI_MODIFY_TIME    --修改时间
          FROM ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD A1                                          --O32交易对手表
           WHERE A1.P_DT = '${P_BATCH_DT}'
           AND SUBSTR(A1.VC_TIMESTAMP,1,8)= '${P_BATCH_DT}' ) A
          LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT ) A2  --TTRADERIVAL机构映射表
            ON '1' = '1'
    WHERE A.RI_VC_ALL_NAME LIKE '%公司';




INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_TISSUER_PTD_INT PARTITION (P_DT= '${P_BATCH_DT}')
SELECT LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0)                             AS ID                        --序号
   , CONCAT ('INST','5','1',LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0),'1')   AS TI_ORG_NUM                --机构编码
   , A1.VC_ISSUER_CODE                                                                     AS TI_VC_ISSUER_CODE         --机构内码
   , A1.VC_FULL_NAME                                                                       AS TI_VC_FULL_NAME           --机构名称
   , '19000101'                                                                            AS TI_ST_DATE                --开始日期
   , '29991231'                                                                            AS TI_END_DATE               --结束日期
   , '1'                                                                                   AS TI_VALID_FLAG             --有效标识
   , 'O32'                                                                                 AS TI_SSYS                   --源系统
   , 'ODS_O32_TISSUER_PFD'                                                                 AS TI_SRC_TAB                --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')              AS TI_LD_TIME                --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')              AS TI_MODIFY_TIME            --修改时间
     FROM ODS_XDAY_O32.ODS_O32_TISSUER_PFD A1                                             --O32发行人信息表
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_ORG_TISSUER_PTD_INT ) A2  --TISSUER机构映射表 
       ON '1' = '1' 
     WHERE  A1.P_DT = '${P_BATCH_DT}'    
       AND SUBSTR(A1.VC_TIMESTAMP,1,8) = '${P_BATCH_DT}'
       AND SUBSTR(A1.VC_TIMESTAMP3,1,8) = '${P_BATCH_DT}';





INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT PARTITION (P_DT= '${P_BATCH_DT}')
SELECT  ID                 AS ID             --序号
    , ZT_ORG_NUM           AS ZT_ORG_NUM      --机构编码
    , ZT_C_CUSTNO          AS ZT_C_CUSTNO        --机构内码
    , ZT_C_CUSTNAME        AS ZT_C_CUSTNAME      --机构名称  
    , ZT_ST_DATE           AS ZT_ST_DATE         --开始日期
    , ZT_END_DATE          AS ZT_END_DATE        --结束日期
    , ZT_VALID_FLAG        AS ZT_VALID_FLAG      --有效标识
    , ZT_SSYS              AS ZT_SSYS            --源系统
    , ZT_SRC_TAB           AS ZT_SRC_TAB         --源表
    , ZT_LD_TIME           AS ZT_LD_TIME         --加载时间
    , ZT_MODIFY_TIME       AS ZT_MODIFY_TIME     --修改时间
      FROM 
      (SELECT LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0)                          AS ID             --序号
         , CONCAT ('INST','1','1',LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0),'1') AS ZT_ORG_NUM      --机构编码
         , A1.C_CUSTNO                                                                            AS ZT_C_CUSTNO        --机构内码
         , A1.C_CUSTNAME                                                                          AS ZT_C_CUSTNAME      --机构名称
         , ROW_NUMBER() OVER(PARTITION BY A1.C_CUSTNO ORDER BY  A1.D_LASTMODIFY DESC)               AS RN
         , '19000101'                                                                             AS ZT_ST_DATE         --开始日期
         , '29991231'                                                                             AS ZT_END_DATE        --结束日期
         , '1'                                                                                    AS ZT_VALID_FLAG      --有效标识
         , 'HSZTA'                                                                                AS ZT_SSYS            --源系统
         , 'ODS_HSZTA_TCUSTINFO_PFD'                                                              AS ZT_SRC_TAB         --源表
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')               AS ZT_LD_TIME         --加载时间
         , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')               AS ZT_MODIFY_TIME     --修改时间
          FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD A1                                         --HSZTA客户基本信息
          LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT ) A2  --HSZTA机构映射表
            ON '1' = '1'
          WHERE A1.P_DT = '${P_BATCH_DT}'
            AND SUBSTR(A1.D_LASTMODIFY,1,8)= '${P_BATCH_DT}' 
            AND A1.C_CUSTTYPE= '0'
            AND A1.C_CUSTNAME NOT LIKE '%计划') SUBT1
      WHERE RN = 1;



 
INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_TCUSTOMERINFO_PTD_INT PARTITION(P_DT= '${P_BATCH_DT}') 
SELECT LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0)                             AS ID                  --序号
   , CONCAT ('INST','2','1',LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0),'1')   AS FT_ORG_NUM          --机构编码
   , A1.C_CUSTNO                                                                           AS FT_C_CUSTNO         --机构内码
   , A1.C_CUSTNAME                                                                         AS FT_C_CUSTNAME       --机构名称
   , '19000101'                                                                            AS FT_ST_DATE          --开始日期
   , '29991231'                                                                            AS FT_END_DATE         --结束日期
   , '1'                                                                                   AS FT_VALID_FLAG       --有效标识
   , 'HSFTA'                                                                               AS FT_SSYS             --源系统
   , 'ODS_HSFTA_TCUSTOMERINFO_PFD'                                                         AS FT_SRC_TAB          --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')              AS FT_LD_TIME          --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')              AS FT_MODIFY_TIME      --修改时间
     FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD A1                                    --HSFTA客户基本信息
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_ORG_TCUSTOMERINFO_PTD_INT ) A2 --HSFTA机构映射表
       ON '1' = '1'
      WHERE A1.P_DT = '${P_BATCH_DT}'
      AND REPLACE(SUBSTR(A1.D_APPENDDATE,1,10),'-','') = '${P_BATCH_DT}' 
      AND A1.C_CUSTTYPE= '0' 
      AND A1.C_CUSTNAME NOT LIKE '%计划'
      AND A1.C_IDENTITYTYPE <> '8' ;




INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_HSDS_TCUSTINFO_PTD_INT PARTITION(P_DT= '${P_BATCH_DT}')
SELECT LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0)                             AS ID                    --序号
   , CONCAT ('INST','3','1',LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0),'1')   AS DS_ORG_NUM           --机构编码
   , A1.VC_CUSTNO                                                                          AS DS_VC_CUSTNO         --机构内码
   , A1.VC_CUSTOMNAME                                                                      AS DS_VC_CUSTOMNAME     --机构名称
   , '19000101'                                                                            AS DS_ST_DATE           --开始日期
   , '29991231'                                                                            AS DS_END_DATE          --结束日期
   , '1'                                                                                   AS DS_VALID_FLAG        --有效标识
   , 'HSDS'                                                                                AS DS_SSYS              --源系统
   , 'ODS_HSDS_TCUSTINFO_PFD'                                                              AS DS_SRC_TAB           --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')              AS DS_LD_TIME           --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')              AS DS_MODIFY_TIME       --修改时间
     FROM ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD A1                                                --HSDS客户资料表
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_ORG_HSDS_TCUSTINFO_PTD_INT ) A2   --HSDS机构映射表
     ON '1' = '1'
    WHERE A1.P_DT = '${P_BATCH_DT}'
    AND SUBSTR(A1.VC_LASTDATE,1,8) = '${P_BATCH_DT}'
    AND A1.C_CUSTTYPE = '0'
    AND A1.VC_CUSTOMNAME NOT LIKE '%计划';



INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_TAGENCYINFO_PTD_INT PARTITION (P_DT= '${P_BATCH_DT}') 
SELECT LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0)                            AS ID                --序号
   ,CONCAT ('INST','6','1',LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0),'1')   AS TA_ORG_NUM        --机构编码
   ,A1.C_AGENCYNO                                                                            AS TA_ORG_INCD       --机构内码
   ,A1.C_AGENCYNAME                                                                          AS TA_ORG_NAME       --机构名称
   ,'19000101'                                                                               AS TA_ST_DATE        --开始日期
   ,'29991231'                                                                               AS TA_END_DATE       --结束日期
   ,'1'                                                                                      AS TA_VALID_ID       --有效标识
   ,'HSZTA'                                                                                  AS TA_SSYS           --源系统
   ,'ODS_HSZTA_TAGENCYINFO_PFD'                                                              AS TA_SRC_TAB        --源表
   ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                 AS TA_LD_TIME        --加载时间
   ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                 AS TA_MODIFY_TIME    --修改时间
   FROM ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD A1         --HSZTA销售商信息表
   LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT ) A2  --ZTA销售商信息映射表
     ON '1' = '1'
     WHERE A1.P_DT ='${P_BATCH_DT}';



INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_FTAGENCYINFO_PTD_INT PARTITION (P_DT= '${P_BATCH_DT}') 
SELECT LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0)                            AS ID                --序号
   ,CONCAT ('INST','7','1',LPAD(CAST((ROW_NUMBER() OVER() + A2.MAXID) AS BIGINT),9,0),'1')   AS FTA_ORG_NUM        --机构编码
   ,A1.C_AGENCYNO                                                                            AS FTA_ORG_INCD       --机构内码
   ,COALESCE(A1.C_FULLNAME,A1.C_AGENCYNAME)                                                  AS FTA_ORG_NAME       --机构名称
   ,'19000101'                                                                               AS FTA_ST_DATE        --开始日期
   ,'29991231'                                                                               AS FTA_END_DATE       --结束日期
   ,'1'                                                                                      AS FTA_VALID_ID       --有效标识
   ,'HSFTA'                                                                                  AS FTA_SSYS           --源系统
   ,'ODS_HSFTA_TAGENCYINFO_PFD'                                                              AS FTA_SRC_TAB        --源表
   ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                 AS FTA_LD_TIME        --加载时间
   ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                 AS FTA_MODIFY_TIME    --修改时间
   FROM ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD A1         --HSFTA销售商信息表
   LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_ORG_FTAGENCYINFO_PTD_INT ) A2  --FTA销售商信息映射表
     ON '1' = '1'
     WHERE A1.P_DT ='${P_BATCH_DT}';




DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_ORG_NUM_MAPP_TMP;


CREATE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_TMP(
ORG_NUM          STRING     COMMENT '机构编码',
ORG_INCD         STRING     COMMENT '机构内码',
ORG_NAME         STRING     COMMENT '机构名称',
ST_DATE          STRING     COMMENT '开始日期',
END_DATE         STRING     COMMENT '结束日期',
VALID_FLAG       STRING     COMMENT '有效标识',
SSYS             STRING     COMMENT '源系统',
SRC_TAB          STRING     COMMENT '源表',
LD_TIME          STRING     COMMENT '加载时间',
MODIFY_TIME      STRING     COMMENT '修改时间'
)COMMENT '每日新增机构编码映射临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';



INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_TMP 
SELECT  FTA_ORG_NUM        --机构编码
   , FTA_ORG_INCD       --机构内码
   , FTA_ORG_NAME       --机构名称
   , FTA_ST_DATE        --开始日期
   , FTA_END_DATE       --结束日期
   , FTA_VALID_ID       --有效标识
   , FTA_SSYS           --源系统
   , FTA_SRC_TAB        --源表
   , FTA_LD_TIME        --加载时间
   , FTA_MODIFY_TIME    --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_FTAGENCYINFO_PTD_INT   --ZTA销售商信息映射表
     WHERE P_DT = '${P_BATCH_DT}'
UNION ALL
SELECT TA_ORG_NUM        --机构编码
   , TA_ORG_INCD       --机构内码
   , TA_ORG_NAME       --机构名称
   , TA_ST_DATE        --开始日期
   , TA_END_DATE       --结束日期
   , TA_VALID_ID       --有效标识
   , TA_SSYS           --源系统
   , TA_SRC_TAB        --源表
   , TA_LD_TIME        --加载时间
   , TA_MODIFY_TIME    --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_TAGENCYINFO_PTD_INT  --FTA销售商信息映射表
     WHERE P_DT = '${P_BATCH_DT}'
       AND TA_ORG_INCD NOT IN 
          ( SELECT FTA_ORG_INCD FROM DWDXDAY.DWD_PTY_ORG_FTAGENCYINFO_PTD_INT WHERE P_DT =  '${P_BATCH_DT}');




DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP;


CREATE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP(
ORG_NUM          STRING     COMMENT '机构编码',
ORG_INCD         STRING     COMMENT '机构内码',
ORG_NAME         STRING     COMMENT '机构名称',
ST_DATE          STRING     COMMENT '开始日期',
END_DATE         STRING     COMMENT '结束日期',
VALID_FLAG       STRING     COMMENT '有效标识',
SSYS             STRING     COMMENT '源系统',
SRC_TAB          STRING     COMMENT '源表',
LD_TIME          STRING     COMMENT '加载时间',
MODIFY_TIME      STRING     COMMENT '修改时间'
)COMMENT '每日新增机构编码映射临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';



INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP
SELECT A.ZT_ORG_NUM         --机构编码
   , A.ZT_C_CUSTNO        --机构内码
   , A.ZT_C_CUSTNAME      --机构名称
   , A.ZT_ST_DATE         --开始日期
   , A.ZT_END_DATE        --结束日期
   , A.ZT_VALID_FLAG      --有效标识
   , A.ZT_SSYS            --源系统
   , A.ZT_SRC_TAB         --源表
   , A.ZT_LD_TIME         --加载时间
   , A.ZT_MODIFY_TIME     --修改时间 
     FROM DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT A --HSZTA机构映射表
     WHERE P_DT =  '${P_BATCH_DT}'
UNION ALL
SELECT  A.RI_ORG_NUM         --机构编码
   , A.RI_L_RIVAL_ID      --机构内码
   , A.RI_VC_ALL_NAME     --机构名称
   , A.RI_ST_DATE         --开始日期
   , A.RI_END_DATE        --结束日期
   , A.RI_VALID_FLAG      --有效标识
   , A.RI_SSYS            --源系统
   , A.RI_SRC_TAB         --源表
   , A.RI_LD_TIME         --加载时间
   , A.RI_MODIFY_TIME     --修改时间 
     FROM DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT A  --TTRADERIVAL机构映射表
     WHERE P_DT =  '${P_BATCH_DT}'
       AND A.RI_VC_ALL_NAME NOT IN ( SELECT ZT_C_CUSTNAME FROM DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT )
UNION ALL
SELECT  FT_ORG_NUM         --机构编码
   , FT_C_CUSTNO        --机构内码
   , FT_C_CUSTNAME      --机构名称
   , FT_ST_DATE         --开始日期
   , FT_END_DATE        --结束日期
   , FT_VALID_FLAG      --有效标识
   , FT_SSYS            --源系统
   , FT_SRC_TAB         --源表
   , FT_LD_TIME         --加载时间
   , FT_MODIFY_TIME     --修改时间 
     FROM DWDXDAY.DWD_PTY_ORG_TCUSTOMERINFO_PTD_INT   --HSFTA机构映射表
     WHERE P_DT =  '${P_BATCH_DT}'
      AND FT_C_CUSTNAME NOT IN 
          (SELECT ZT_C_CUSTNAME FROM DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
          UNION SELECT RI_VC_ALL_NAME FROM DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT WHERE P_DT= '${P_BATCH_DT}')
UNION ALL
SELECT  DS_ORG_NUM           --机构编码
   , DS_VC_CUSTNO         --机构内码
   , DS_VC_CUSTOMNAME     --机构名称
   , DS_ST_DATE           --开始日期
   , DS_END_DATE          --结束日期
   , DS_VALID_FLAG        --有效标识
   , DS_SSYS              --源系统
   , DS_SRC_TAB           --源表
   , DS_LD_TIME           --加载时间
   , DS_MODIFY_TIME       --修改时间 
     FROM DWDXDAY.DWD_PTY_ORG_HSDS_TCUSTINFO_PTD_INT -- HSDS机构映射表
     WHERE P_DT =  '${P_BATCH_DT}'
      AND DS_VC_CUSTOMNAME NOT IN 
           (SELECT ZT_C_CUSTNAME FROM DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
          UNION SELECT RI_VC_ALL_NAME FROM DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
          UNION SELECT FT_C_CUSTNAME FROM DWDXDAY.DWD_PTY_ORG_TCUSTOMERINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}')
UNION ALL
SELECT TI_ORG_NUM          --机构编码
   , TI_VC_ISSUER_CODE   --机构内码
   , TI_VC_FULL_NAME     --机构名称
   , TI_ST_DATE          --开始日期
   , TI_END_DATE         --结束日期
   , TI_VALID_FLAG       --有效标识
   , TI_SSYS             --源系统
   , TI_SRC_TAB          --源表
   , TI_LD_TIME          --加载时间
   , TI_MODIFY_TIME      --修改时间 
     FROM DWDXDAY.DWD_PTY_ORG_TISSUER_PTD_INT   --TISSUER机构映射表 
     WHERE P_DT =  '${P_BATCH_DT}'
      AND TI_VC_FULL_NAME NOT IN 
                  (SELECT ZT_C_CUSTNAME FROM DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
          UNION SELECT RI_VC_ALL_NAME FROM DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
          UNION SELECT FT_C_CUSTNAME FROM DWDXDAY.DWD_PTY_ORG_TCUSTOMERINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
         UNION SELECT DS_VC_CUSTOMNAME FROM DWDXDAY.DWD_PTY_ORG_HSDS_TCUSTINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}' )
UNION ALL
SELECT ORG_NUM       --机构编码
  , ORG_INCD       --机构内码
  , ORG_NAME       --机构名称
  , ST_DATE        --开始日期
  , END_DATE       --结束日期
  , VALID_FLAG     --有效标识
  , SSYS           --源系统
  , SRC_TAB        --源表
  , LD_TIME        --加载时间
  , MODIFY_TIME    --修改时间 
FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_TMP 
WHERE ORG_NAME  NOT IN (SELECT ZT_C_CUSTNAME FROM DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
          UNION SELECT RI_VC_ALL_NAME FROM DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
          UNION SELECT FT_C_CUSTNAME FROM DWDXDAY.DWD_PTY_ORG_TCUSTOMERINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}'
         UNION SELECT DS_VC_CUSTOMNAME FROM DWDXDAY.DWD_PTY_ORG_HSDS_TCUSTINFO_PTD_INT WHERE P_DT= '${P_BATCH_DT}' 
         UNION SELECT TI_VC_FULL_NAME FROM DWDXDAY.DWD_PTY_ORG_TISSUER_PTD_INT WHERE P_DT= '${P_BATCH_DT}');



DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1;


CREATE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1(
ORG_NUM          STRING     COMMENT '机构编码',
ORG_INCD         STRING     COMMENT '机构内码',
ORG_NAME         STRING     COMMENT '机构名称',
ST_DATE          STRING     COMMENT '开始日期',
END_DATE         STRING     COMMENT '结束日期',
VALID_FLAG       STRING     COMMENT '有效标识',
SSYS             STRING     COMMENT '源系统',
SRC_TAB          STRING     COMMENT '源表',
LD_TIME          STRING     COMMENT '加载时间',
MODIFY_TIME      STRING     COMMENT '修改时间'
)COMMENT '每日新增机构编码映射临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';



INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1
SELECT T1.ZT_ORG_NUM                                     AS ORG_NUM        --机构编码
   , T1.ZT_C_CUSTNO                                      AS ORG_INCD       --机构内码
   , T1.ZT_C_CUSTNAME                                    AS ORG_NAME       --机构名称
   , T1.ZT_ST_DATE                                       AS ST_DATE        --开始日期
   , T1.ZT_END_DATE                                      AS END_DATE       --结束日期
   , T1.ZT_VALID_FLAG                                    AS VALID_FLAG     --有效标识
   , T1.ZT_SSYS                                          AS SSYS           --源系统
   , T1.ZT_SRC_TAB                                       AS SRC_TAB        --源表
   , T1.ZT_LD_TIME                                       AS LD_TIME        --加载时间
   , T1.ZT_MODIFY_TIME                                   AS MODIFY_TIME    --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_TCUSTINFO_PTD_INT T1   --HSZTA机构映射表
     WHERE T1.P_DT= '${P_BATCH_DT}' 
UNION ALL 
SELECT COALESCE(B1.ORG_NUM,A1.RI_ORG_NUM)        AS ORG_NUM             --机构编码
   , A1.RI_L_RIVAL_ID                            AS ORG_INCD            --机构内码
   , A1.RI_VC_ALL_NAME                           AS ORG_NAME            --机构名称
   , A1.RI_ST_DATE                               AS ST_DATE             --开始日期
   , A1.RI_END_DATE                              AS END_DATE            --结束日期
   , A1.RI_VALID_FLAG                            AS VALID_FLAG          --有效标识
   , A1.RI_SSYS                                  AS SSYS                --源系统
   , A1.RI_SRC_TAB                               AS SRC_TAB             --源表
   , A1.RI_LD_TIME                               AS LD_TIME             --加载时间
   , A1.RI_MODIFY_TIME                           AS MODIFY_TIME         --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_TTRADERIVAL_PTD_INT A1  --TTRADERIVAL机构映射表
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP B1   --每日新增机构编码映射临时表
       ON  A1.RI_VC_ALL_NAME = B1.ORG_NAME 
      WHERE A1.P_DT = '${P_BATCH_DT}'
UNION ALL
SELECT COALESCE(D1.ORG_NUM,C1.TI_ORG_NUM)     AS ORG_NUM           --机构编码
   , C1.TI_VC_ISSUER_CODE                     AS ORG_INCD          --机构内码
   , C1.TI_VC_FULL_NAME                       AS ORG_NAME          --机构名称
   , C1.TI_ST_DATE                            AS ST_DATE           --开始日期
   , C1.TI_END_DATE                           AS END_DATE          --结束日期
   , C1.TI_VALID_FLAG                         AS VALID_FLAG        --有效标识
   , C1.TI_SSYS                               AS SSYS              --源系统
   , C1.TI_SRC_TAB                            AS SRC_TAB           --源表
   , C1.TI_LD_TIME                            AS LD_TIME           --加载时间
   , C1.TI_MODIFY_TIME                        AS MODIFY_TIME       --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_TISSUER_PTD_INT  C1  --TISSUER机构映射表
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP  D1  --每日新增机构编码映射临时表
       ON  C1.TI_VC_FULL_NAME = D1.ORG_NAME 
        WHERE C1.P_DT = '${P_BATCH_DT}'
UNION ALL
SELECT COALESCE(F1.ORG_NUM,E1.FT_ORG_NUM)    AS ORG_NUM        --机构编码    
   , E1.FT_C_CUSTNO                          AS ORG_INCD       --机构内码    
   , E1.FT_C_CUSTNAME                        AS ORG_NAME       --机构名称    
   , E1.FT_ST_DATE                           AS ST_DATE        --开始日期    
   , E1.FT_END_DATE                          AS END_DATE       --结束日期    
   , E1.FT_VALID_FLAG                        AS VALID_FLAG     --有效标识    
   , E1.FT_SSYS                              AS SSYS           --源系统    
   , E1.FT_SRC_TAB                           AS SRC_TAB        --源表    
   , E1.FT_LD_TIME                           AS LD_TIME        --加载时间    
   , E1.FT_MODIFY_TIME                       AS MODIFY_TIME    --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_TCUSTOMERINFO_PTD_INT  E1  --HSFTA机构映射表
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP F1  --每日新增机构编码映射临时表
       ON  E1.FT_C_CUSTNAME = F1.ORG_NAME 
      WHERE E1.P_DT = '${P_BATCH_DT}'
UNION ALL 
SELECT COALESCE(H1.ORG_NUM,G1.DS_ORG_NUM)    AS ORG_NUM         --机构编码
   , G1.DS_VC_CUSTNO                         AS ORG_INCD        --机构内码
   , G1.DS_VC_CUSTOMNAME                     AS ORG_NAME        --机构名称
   , G1.DS_ST_DATE                           AS ST_DATE         --开始日期
   , G1.DS_END_DATE                          AS END_DATE        --结束日期
   , G1.DS_VALID_FLAG                        AS VALID_FLAG      --有效标识
   , G1.DS_SSYS                              AS SSYS            --源系统
   , G1.DS_SRC_TAB                           AS SRC_TAB         --源表
   , G1.DS_LD_TIME                           AS LD_TIME         --加载时间
   , G1.DS_MODIFY_TIME                       AS MODIFY_TIME     --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_HSDS_TCUSTINFO_PTD_INT G1 --HSDS机构映射表
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP  H1  --每日新增机构编码映射临时表
       ON  G1.DS_VC_CUSTOMNAME = H1.ORG_NAME 
      WHERE G1.P_DT = '${P_BATCH_DT}';



DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_2;


CREATE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_2(
ORG_NUM          STRING     COMMENT '机构编码',
ORG_INCD         STRING     COMMENT '机构内码',
ORG_NAME         STRING     COMMENT '机构名称',
ST_DATE          STRING     COMMENT '开始日期',
END_DATE         STRING     COMMENT '结束日期',
VALID_FLAG       STRING     COMMENT '有效标识',
SSYS             STRING     COMMENT '源系统',
SRC_TAB          STRING     COMMENT '源表',
LD_TIME          STRING     COMMENT '加载时间',
MODIFY_TIME      STRING     COMMENT '修改时间'
)COMMENT '每日新增机构编码映射临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';



INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_2
SELECT DISTINCT COALESCE(K1.ORG_NUM,L1.ORG_NUM,T1.ORG_NUM,J1.FTA_ORG_NUM)       AS ORG_NUM             --机构编码
   , J1.FTA_ORG_INCD                             AS ORG_INCD            --机构内码
   , J1.FTA_ORG_NAME                             AS ORG_NAME            --机构名称
   , J1.FTA_ST_DATE                              AS ST_DATE             --开始日期
   , J1.FTA_END_DATE                             AS END_DATE            --结束日期
   , J1.FTA_VALID_ID                             AS VALID_FLAG          --有效标识
   , J1.FTA_SSYS                                 AS SSYS                --源系统
   , J1.FTA_SRC_TAB                              AS SRC_TAB             --源表
   , J1.FTA_LD_TIME                              AS LD_TIME             --加载时间
   , J1.FTA_MODIFY_TIME                          AS MODIFY_TIME         --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_FTAGENCYINFO_PTD_INT J1  --FTA销售商
     LEFT JOIN 
       (SELECT DISTINCT ORG_NUM,ORG_INCD FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD
    WHERE SRC_TAB IN ('ODS_HSFTA_TAGENCYINFO_PFD','ODS_HSZTA_TAGENCYINFO_PFD','ODS_HSZTA_TDICTIONARY_PFD' )) K1   --每日新增机构编码映射临时表
       ON  J1.FTA_ORG_INCD = K1.ORG_INCD 
    LEFT JOIN (SELECT DISTINCT ORG_NUM,ORG_NAME FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD)  L1
       ON J1.FTA_ORG_NAME = L1.ORG_NAME
       AND K1.ORG_INCD IS NULL
    LEFT JOIN  DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP T1
       ON J1.FTA_ORG_NAME = T1.ORG_NAME
       AND K1.ORG_INCD IS NULL
       AND L1.ORG_NAME IS NULL
      WHERE J1.P_DT = '${P_BATCH_DT}';




INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_2
SELECT DISTINCT COALESCE(T1.ORG_NUM,K1.ORG_NUM,M1.ORG_NUM,L1.TA_ORG_NUM)       AS ORG_NUM             --机构编码
   , L1.TA_ORG_INCD                             AS ORG_INCD            --机构内码
   , L1.TA_ORG_NAME                             AS ORG_NAME            --机构名称
   , L1.TA_ST_DATE                              AS ST_DATE             --开始日期
   , L1.TA_END_DATE                             AS END_DATE            --结束日期
   , L1.TA_VALID_ID                             AS VALID_FLAG          --有效标识
   , L1.TA_SSYS                                 AS SSYS                --源系统
   , L1.TA_SRC_TAB                              AS SRC_TAB             --源表
   , L1.TA_LD_TIME                              AS LD_TIME             --加载时间
   , L1.TA_MODIFY_TIME                          AS MODIFY_TIME         --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_TAGENCYINFO_PTD_INT L1  --ZTA销售商
      LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_2  T1
       ON L1.TA_ORG_INCD = T1.ORG_INCD
     LEFT JOIN  (SELECT DISTINCT ORG_NUM,ORG_NAME FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD) K1
     ON L1.TA_ORG_NAME = K1.ORG_NAME 
     AND T1.ORG_INCD IS NULL
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP  M1  --每日新增机构编码映射临时表
       ON  L1.TA_ORG_NAME = M1.ORG_NAME 
       AND T1.ORG_INCD IS NULL
       AND K1.ORG_NAME IS NULL
      WHERE L1.P_DT = '${P_BATCH_DT}';





INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1  
SELECT DISTINCT COALESCE( B.ORG_NUM,A.ORG_NUM)        AS ORG_NUM           --机构编码
   , A.ORG_INCD                                       AS ORG_INCD           --机构内码
   , A.ORG_NAME                                       AS ORG_NAME           --机构名称
   , A.ST_DATE                                        AS ST_DATE            --开始日期
   , A.END_DATE                                       AS END_DATE           --结束日期
   , A.VALID_FLAG                                     AS VALID_FLAG         --有效标识
   , A.SSYS                                           AS SSYS               --源系统
   , A.SRC_TAB                                        AS SRC_TAB            --源表
   , A.LD_TIME                                        AS LD_TIME            --加载时间
   , A.MODIFY_TIME                                    AS MODIFY_TIME        --修改时间
    FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1 A --机构编码映射临时表
    LEFT JOIN 
    (SELECT ORG_NUM                    AS ORG_NUM            --机构编码
        , ORG_NAME                     AS ORG_NAME           --机构名称
          FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD GROUP BY ORG_NUM ,ORG_NAME  ) B  --机构编码映射表
      ON A.ORG_NAME =B.ORG_NAME ;


  
INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD PARTITION (P_DT = '${P_BATCH_DT}')
SELECT DISTINCT A1.ORG_NUM                                 AS ORG_NUM            --机构编码
   , COALESCE(A2.ORG_INCD , A1.ORG_INCD)                   AS ORG_INCD           --机构内码
   , A1.ORG_NAME                                           AS ORG_NAME           --机构名称
   , COALESCE(A2.ST_DATE , A1.ST_DATE)                    AS ST_DATE            --开始日期
   , COALESCE(A2.END_DATE , A1.END_DATE)                   AS END_DATE           --结束日期
   , COALESCE(A2.VALID_FLAG ,A1.VALID_FLAG  )              AS VALID_FLAG         --有效标识
   , COALESCE(A2.SSYS , A1.SSYS )                          AS SSYS               --源系统
   , COALESCE(A2.SRC_TAB ,A1.SRC_TAB  )                    AS SRC_TAB            --源表
   , COALESCE(A2.LD_TIME  ,A1. LD_TIME )                   AS LD_TIME            --加载时间
   , COALESCE(A2.MODIFY_TIME, A1.MODIFY_TIME )             AS MODIFY_TIME        --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD A1
     LEFT JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1 A2
       ON A1.ORG_NUM = A2.ORG_NUM 
      AND A1.SSYS = A2.SSYS
      AND A1.SRC_TAB = A2.SRC_TAB
UNION ALL
SELECT DISTINCT A1.ORG_NUM                    AS ORG_NUM            --机构编码
   , A1.ORG_INCD                     AS ORG_INCD           --机构内码
   , A1.ORG_NAME                     AS ORG_NAME           --机构名称
   , A1.ST_DATE                      AS ST_DATE            --开始日期
   , A1.END_DATE                     AS END_DATE           --结束日期
   , A1.VALID_FLAG                   AS VALID_FLAG         --有效标识
   , A1.SSYS                         AS SSYS               --源系统
   , A1.SRC_TAB                      AS SRC_TAB            --源表
   , A1.LD_TIME                      AS LD_TIME            --加载时间
   , A1.MODIFY_TIME                  AS MODIFY_TIME        --修改时间
FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1 A1
WHERE A1.ORG_NUM NOT IN (SELECT ORG_NUM FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD)
UNION ALL
SELECT DISTINCT A1.ORG_NUM                    AS ORG_NUM            --机构编码
   , A1.ORG_INCD                     AS ORG_INCD           --机构内码
   , A1.ORG_NAME                     AS ORG_NAME           --机构名称
   , A1.ST_DATE                      AS ST_DATE            --开始日期
   , A1.END_DATE                     AS END_DATE           --结束日期
   , A1.VALID_FLAG                   AS VALID_FLAG         --有效标识
   , A1.SSYS                         AS SSYS               --源系统
   , A1.SRC_TAB                      AS SRC_TAB            --源表
   , A1.LD_TIME                      AS LD_TIME            --加载时间
   , A1.MODIFY_TIME                  AS MODIFY_TIME        --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1 A1
     INNER JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD A2
       ON A1.ORG_NUM = A2.ORG_NUM
     WHERE A1.ORG_NUM NOT IN (SELECT B1.ORG_NUM FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_1 B1
                               INNER JOIN DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD B2
                               ON B1.ORG_NUM = B2.ORG_NUM AND B1.SRC_TAB = B2.SRC_TAB);


INSERT INTO TABLE DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD PARTITION (P_DT = '${P_BATCH_DT}')
SELECT ORG_NUM     AS ORG_NUM     
 ,ORG_INCD    AS ORG_INCD    
 ,ORG_NAME    AS ORG_NAME    
 ,ST_DATE     AS ST_DATE     
 ,END_DATE    AS END_DATE    
 ,VALID_FLAG  AS VALID_FLAG  
 ,SSYS        AS SSYS        
 ,SRC_TAB     AS SRC_TAB     
 ,LD_TIME     AS LD_TIME     
 ,MODIFY_TIME AS MODIFY_TIME 
 FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD_TMP_2 WHERE ORG_NAME NOT IN (SELECT ORG_NAME FROM DWDXDAY.DWD_PTY_ORG_NUM_MAPP_PFD WHERE SRC_TAB IN ('ODS_HSZTA_TAGENCYINFO_PFD','ODS_HSFTA_TAGENCYINFO_PFD'));



"
  
