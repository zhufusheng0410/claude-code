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

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_NUM_TTRADERIVAL_PTD_INT PARTITION (P_DT ='${P_BATCH_DT}' )
SELECT LPAD(CAST((row_number() over () + A2.MAXID) AS BIGINT),9,0)                                               AS ID           --序号                                           
   , CONCAT ('CTP','1','1',LPAD(CAST((row_number() over () + A2.MAXID) AS BIGINT),9,0),'1')                      AS CNTP_NUM     --交易对手方编码
   , A1.L_RIVAL_ID                                                                                            AS CNTP_NO      --交易对手方编号
   , A1.VC_ALL_NAME                                                                                           AS CNTP_NAME    --交易对手方名称
   , '19000101'                                                                                               AS ST_DATE      --开始日期
   , '29991231'                                                                                               AS END_DATE     --结束日期
   , '1'                                                                                                      AS VALID_FLAG   --有效标识
   , 'O32'                                                                                                    AS SSYS         --源系统
   , 'ODS_O32_TTRADERIVAL_PFD'                                                                                AS SRC_TAB      --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                                 AS LD_TIME      --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                                 AS MODIFY_TIME  --修改时间
     FROM ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD A1                                                            --交易对手表
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM  DWDXDAY.DWD_PTY_CNTP_NUM_TTRADERIVAL_PTD_INT ) A2  --O32交易对手方表
       ON '1' = '1'
     WHERE SUBSTR(A1.VC_TIMESTAMP,1,8)= '${P_BATCH_DT}' 
      AND (A1.EN_CAPITAL= '0' OR A1.EN_CAPITAL IS NULL )
      AND A1.P_DT ='${P_BATCH_DT}'
      AND A1.VC_ALL_NAME IS NOT NULL ;


INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_NUM_TBANKINFO_PTD_INT PARTITION (P_DT ='${P_BATCH_DT}' )
SELECT LPAD(CAST((row_number() over () + maxid) AS BIGINT),9,0)                                               AS ID           --序号                                           
   , CONCAT ('CTP','3','1',LPAD(CAST((row_number() over () + maxid) AS BIGINT),9,0),'1')                      AS CNTP_NUM     --交易对手方编码
   , A1.L_BANK_NO                                                                                             AS CNTP_NO      --交易对手方编号
   , A1.VC_BANK_NAME                                                                                          AS CNTP_NAME    --交易对手方名称
   , '19000101'                                                                                               AS ST_DATE      --开始日期
   , '29991231'                                                                                               AS END_DATE     --结束日期
   , '1'                                                                                                      AS VALID_FLAG   --有效标识
   , 'O32'                                                                                                    AS SSYS         --源系统
   , 'ODS_O32_TBANKINFO_PFD'                                                                                  AS SRC_TAB      --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                                 AS LD_TIME      --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                                 AS MODIFY_TIME  --修改时间
     FROM ODS_XDAY_O32.ODS_O32_TBANKINFO_PFD A1    --银行间信息表
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM  DWDXDAY.DWD_PTY_CNTP_NUM_TBANKINFO_PTD_INT) A2  --O32交易对手方表
       ON '1' = '1'
      WHERE SUBSTR(A1.VC_TIMESTAMP,1,8) ='${P_BATCH_DT}' 
      AND A1.P_DT ='${P_BATCH_DT}';

 

INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_ORG_BASIC_INFO_PTD_INT PARTITION (P_DT='${P_BATCH_DT}')
SELECT LPAD(CAST((row_number() over () + B2.MAXID) AS BIGINT),9,0)                                        AS ID            --序号                                          
   , CONCAT ('CTP','2','1',LPAD(CAST((row_number() over () + B2.MAXID) AS BIGINT),9,0),'1')               AS CNTP_NUM      --交易对手方编码
   , B1.ORG_NUM                                                                                        AS CNTP_NO       --交易对手方编号
   , B1.ORG_NAME                                                                                       AS CNTP_NAME     --交易对手方名称
   , '19000101'                                                                                        AS ST_DATE       --开始日期
   , '29991231'                                                                                        AS END_DATE      --结束日期
   , '1'                                                                                               AS VALID_FLAG    --有效标识
   , 'DWD'                                                                                             AS SSYS          --源系统
   , 'DWD_PTY_ORG_BASIC_INFO_PFD'                                                                      AS SRC_TAB       --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                          AS LD_TIME       --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')                          AS MODIFY_TIME   --修改时间
     FROM DWDXDAY.DWD_PTY_ORG_BASIC_INFO_PFD B1  --机构信息表
     LEFT JOIN (SELECT NVL(MAX(ID),0) AS MAXID FROM DWDXDAY.DWD_PTY_CNTP_ORG_BASIC_INFO_PTD_INT ) B2   --机构交易对手方表
       ON '1' = '1'
     WHERE REPLACE(SUBSTR(B1.MODIFY_TIME ,1,10),'-','') = DATE_FORMAT(DATE_SUB(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP('${P_BATCH_DT}','yyyyMMdd'))),-1),'yyyyMMdd') ;


DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP;

CREATE TABLE DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP(
CNTP_NUM         STRING      COMMENT   '交易对手方编码',
CNTP_NO          STRING      COMMENT   '交易对手方编号',
CNTP_NAME        STRING      COMMENT   '交易对手方名称',
ST_DATE          STRING      COMMENT   '开始日期',
END_DATE         STRING      COMMENT   '结束日期',
VALID_FLAG       STRING      COMMENT   '有效标识',
SSYS             STRING      COMMENT   '源系统',
SRC_TAB          STRING      COMMENT   '源表',
LD_TIME          STRING      COMMENT   '加载时间',
MODIFY_TIME      STRING      COMMENT   '修改时间'
)COMMENT '交易对手映射临时表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';


INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP 
SELECT  CNTP_NUM     AS CNTP_NUM       --交易对手方编码
    , CNTP_NO      AS CNTP_NO        --交易对手方编号
    , CNTP_NAME    AS CNTP_NAME      --交易对手方名称
    , ST_DATE      AS ST_DATE        --开始日期
    , END_DATE     AS END_DATE       --结束日期
    , VALID_FLAG   AS VALID_FLAG     --有效标识
    , SSYS         AS SSYS           --源系统
    , SRC_TAB      AS SRC_TAB        --源表
    , LD_TIME      AS LD_TIME        --加载时间
    , MODIFY_TIME  AS MODIFY_TIME    --修改时间
      FROM DWDXDAY.DWD_PTY_CNTP_NUM_TTRADERIVAL_PTD_INT 
      WHERE P_DT = '${P_BATCH_DT}' 
UNION ALL
SELECT CNTP_NUM      AS CNTP_NUM       --交易对手方编码
   , CNTP_NO       AS CNTP_NO        --交易对手方编号
   , CNTP_NAME     AS CNTP_NAME      --交易对手方名称
   , ST_DATE       AS ST_DATE        --开始日期
   , END_DATE      AS END_DATE       --结束日期
   , VALID_FLAG    AS VALID_FLAG     --有效标识
   , SSYS          AS SSYS           --源系统
   , SRC_TAB       AS SRC_TAB        --源表
   , LD_TIME       AS LD_TIME        --加载时间
   , MODIFY_TIME   AS MODIFY_TIME    --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_ORG_BASIC_INFO_PTD_INT 
    WHERE P_DT = '${P_BATCH_DT}'
    AND CNTP_NAME NOT IN (SELECT CNTP_NAME FROM DWDXDAY.DWD_PTY_CNTP_NUM_TTRADERIVAL_PTD_INT )
UNION ALL 
SELECT   CNTP_NUM      AS CNTP_NUM       --交易对手方编码
   , CNTP_NO       AS CNTP_NO        --交易对手方编号
   , CNTP_NAME     AS CNTP_NAME      --交易对手方名称
   , ST_DATE       AS ST_DATE        --开始日期
   , END_DATE      AS END_DATE       --结束日期
   , VALID_FLAG    AS VALID_FLAG     --有效标识
   , SSYS          AS SSYS           --源系统
   , SRC_TAB       AS SRC_TAB        --源表
   , LD_TIME       AS LD_TIME        --加载时间
   , MODIFY_TIME   AS MODIFY_TIME    --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_NUM_TBANKINFO_PTD_INT --银行间信息交易对手方表
    WHERE P_DT = '${P_BATCH_DT}'
    AND CNTP_NAME NOT IN (SELECT CNTP_NAME FROM DWDXDAY.DWD_PTY_CNTP_NUM_TTRADERIVAL_PTD_INT 
                   UNION SELECT CNTP_NAME FROM DWDXDAY.DWD_PTY_CNTP_ORG_BASIC_INFO_PTD_INT );


DROP TABLE IF EXISTS DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1;

CREATE TABLE DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1(
CNTP_NUM         STRING      COMMENT   '交易对手方编码',
CNTP_NO          STRING      COMMENT   '交易对手方编号',
CNTP_NAME        STRING      COMMENT   '交易对手方名称',
ST_DATE          STRING      COMMENT   '开始日期',
END_DATE         STRING      COMMENT   '结束日期',
VALID_FLAG       STRING      COMMENT   '有效标识',
SSYS             STRING      COMMENT   '源系统',
SRC_TAB          STRING      COMMENT   '源表',
LD_TIME          STRING      COMMENT   '加载时间',
MODIFY_TIME      STRING      COMMENT   '修改时间'
)COMMENT '交易对手映射临时表1'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
NULL  DEFINED AS '';


INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1 
SELECT A1.CNTP_NUM                AS  CNTP_NUM            --交易对手方编码
   , A1.CNTP_NO                   AS  CNTP_NO             --交易对手方编号
   , A1.CNTP_NAME                 AS  CNTP_NAME           --交易对手方名称
   , A1.ST_DATE                   AS  ST_DATE             --开始日期
   , A1.END_DATE                  AS  END_DATE            --结束日期
   , A1.VALID_FLAG                AS  VALID_FLAG          --有效标识
   , A1.SSYS                      AS  SSYS                --源系统
   , A1.SRC_TAB                   AS  SRC_TAB             --源表
   , A1.LD_TIME                   AS  LD_TIME             --加载时间
   , A1.MODIFY_TIME               AS  MODIFY_TIME         --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_NUM_TTRADERIVAL_PTD_INT A1  --O32交易对手方表
     WHERE A1.P_DT = '${P_BATCH_DT}'
UNION ALL
SELECT COALESCE (B2.CNTP_NUM,B1.CNTP_NUM)  AS  CNTP_NUM                    --交易对手方编码
   ,  B1.CNTP_NO                           AS  CNTP_NO                  --交易对手方编号
   ,  B1.CNTP_NAME                         AS  CNTP_NAME                --交易对手方名称
   ,  B1.ST_DATE                           AS  ST_DATE                --开始日期
   ,  B1.END_DATE                          AS  END_DATE               --结束日期
   ,  B1.VALID_FLAG                        AS  VALID_FLAG           --有效标识
   ,  B1.SSYS                              AS  SSYS                  --源系统
   ,  B1.SRC_TAB                           AS  SRC_TAB              --源表
   ,  B1.LD_TIME                           AS  LD_TIME           --加载时间
   ,  B1.MODIFY_TIME                       AS  MODIFY_TIME       --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_ORG_BASIC_INFO_PTD_INT B1 --机构交易对手方表
     LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP B2   --新增交易对手方临时表
       ON B1.CNTP_NAME = B2.CNTP_NAME
     WHERE B1.P_DT = '${P_BATCH_DT}'
UNION ALL
SELECT COALESCE (C2.CNTP_NUM,C1.CNTP_NUM)    AS  CNTP_NUM                 --交易对手方编码
   ,  C1.CNTP_NO                             AS  CNTP_NO              --交易对手方编号
   ,  C1.CNTP_NAME                           AS  CNTP_NAME          --交易对手方名称
   ,  C1.ST_DATE                             AS  ST_DATE             --开始日期
   ,  C1.END_DATE                            AS  END_DATE           --结束日期
   ,  C1.VALID_FLAG                          AS  VALID_FLAG       --有效标识
   ,  C1.SSYS                                AS  SSYS                   --源系统
   ,  C1.SRC_TAB                             AS  SRC_TAB             --源表
   ,  C1.LD_TIME                             AS  LD_TIME             --加载时间
   ,  C1.MODIFY_TIME                         AS  MODIFY_TIME     --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_NUM_TBANKINFO_PTD_INT C1 --银行间信息交易对手方表
     LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP C2   --新增交易对手方临时表
       ON C1.CNTP_NAME = C2.CNTP_NAME
     WHERE C1.P_DT = '${P_BATCH_DT}'
 ;



                                
INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1 
SELECT DISTINCT COALESCE(B.CNTP_NUM , A.CNTP_NUM)  AS CNTP_NUM              --交易对手方编码
   , A.CNTP_NO                                     AS CNTP_NO                --交易对手方编号
   , A.CNTP_NAME                                   AS CNTP_NAME              --交易对手方名称
   , A.ST_DATE                                     AS ST_DATE                --开始日期
   , A.END_DATE                                    AS END_DATE               --结束日期
   , A.VALID_FLAG                                  AS VALID_FLAG             --有效标识
   , A.SSYS                                        AS SSYS                   --源系统
   , A.SRC_TAB                                     AS SRC_TAB                --源表
   , A.LD_TIME                                     AS LD_TIME                --加载时间
   , A.MODIFY_TIME                                 AS MODIFY_TIME            --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1  A
     LEFT JOIN 
         (SELECT CNTP_NUM               AS CNTP_NUM                     --交易对手方编码
             , CNTP_NAME                 AS CNTP_NAME                    --交易对手方名称
               FROM DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD GROUP BY CNTP_NAME,CNTP_NUM) B  --交易对手方映射表
            ON A.CNTP_NAME = B.CNTP_NAME  ;


INSERT OVERWRITE TABLE DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD PARTITION (P_DT= '${P_BATCH_DT}')
SELECT DISTINCT  A.CNTP_NUM                                            AS CNTP_NUM               --交易对手方编码
   , COALESCE(B.CNTP_NO , A.CNTP_NO)                                   AS CNTP_NO                --交易对手方编号
   , A.CNTP_NAME                                                       AS CNTP_NAME              --交易对手方名称
   , COALESCE(B.ST_DATE,A.ST_DATE )                                    AS ST_DATE                --开始日期
   , COALESCE(B.END_DATE, A.END_DATE)                                  AS END_DATE               --结束日期
   , COALESCE(B.VALID_FLAG,A.VALID_FLAG)                               AS VALID_FLAG             --有效标识
   , COALESCE(B.SSYS ,A.SSYS  )                                        AS SSYS                   --源系统
   , COALESCE(B.SRC_TAB,A.SRC_TAB )                                    AS SRC_TAB                --源表
   , COALESCE(B.LD_TIME ,A.LD_TIME )                                   AS LD_TIME                --加载时间
   , COALESCE(B.MODIFY_TIME,A.MODIFY_TIME)                            AS MODIFY_TIME            --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD A
     LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1 B
            ON A.CNTP_NAME = B.CNTP_NAME AND A.SSYS= B.SSYS AND A.SRC_TAB = B.SRC_TAB
UNION ALL
SELECT DISTINCT  A.CNTP_NUM                        AS CNTP_NUM               --交易对手方编码
   , A.CNTP_NO                                     AS CNTP_NO                --交易对手方编号
   , A.CNTP_NAME                                   AS CNTP_NAME              --交易对手方名称
   , A.ST_DATE                                     AS ST_DATE                --开始日期
   , A.END_DATE                                    AS END_DATE               --结束日期
   , A.VALID_FLAG                                  AS VALID_FLAG             --有效标识
   , A.SSYS                                        AS SSYS                   --源系统
   , A.SRC_TAB                                     AS SRC_TAB                --源表
   , A.LD_TIME                                     AS LD_TIME                --加载时间
   , A.MODIFY_TIME                                 AS MODIFY_TIME            --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1 A
     WHERE A.CNTP_NUM NOT IN (SELECT CNTP_NUM FROM DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD )
UNION ALL
SELECT DISTINCT  A1.CNTP_NUM                        AS CNTP_NUM               --交易对手方编码
   , A1.CNTP_NO                                     AS CNTP_NO                --交易对手方编号
   , A1.CNTP_NAME                                   AS CNTP_NAME              --交易对手方名称
   , A1.ST_DATE                                     AS ST_DATE                --开始日期
   , A1.END_DATE                                    AS END_DATE               --结束日期
   , A1.VALID_FLAG                                  AS VALID_FLAG             --有效标识
   , A1.SSYS                                        AS SSYS                   --源系统
   , A1.SRC_TAB                                     AS SRC_TAB                --源表
   , A1.LD_TIME                                     AS LD_TIME                --加载时间
   , A1.MODIFY_TIME                                 AS MODIFY_TIME            --修改时间
     FROM DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1 A1
     INNER JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD A2
     ON A1.CNTP_NUM = A2.CNTP_NUM
     WHERE A1.CNTP_NUM NOT IN (SELECT B1.CNTP_NUM FROM DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_TMP_1 B1
                               INNER JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD B2
                               ON B1.CNTP_NUM = B2.CNTP_NUM AND B1.SRC_TAB=B2.SRC_TAB AND B1.CNTP_NAME = B2.CNTP_NAME);


"