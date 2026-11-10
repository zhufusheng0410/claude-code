#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_REPOCONVERSIONSTD_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_REPOCONVERSIONSTD_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  ENDDATE  STRING  COMMENT  '日期',
  EXECUTESTARTDATE  STRING  COMMENT  '折算标准执行起始日',
  EXECUTEENDDATE  STRING  COMMENT  '折算标准执行截止日',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  COEFFICIENT  DECIMAL(9,6)  COMMENT  '标准券折算率(每百元面值折算成标准券所乘的系数)',
  STDBOND  DECIMAL(19,4)  COMMENT  '标准券(元)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '债券回购折算比率表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\u0001';"

json_obj=$(cat <<'EOF'
{
  "job": {
    "setting": {
      "speed": {
        "channel": 1
      },
      "errorLimit": {
        "record": 0,
        "percentage": 0.02
      }
    },
    "content": [
      {
        "reader": {
          "name": "oraclereader",
          "parameter": {
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , INNERCODE
                                   , INFOPUBLDATE
                                   , ENDDATE
                                   , TO_CHAR(EXECUTESTARTDATE,'YYYYMMDD') EXECUTESTARTDATE
                                   , EXECUTEENDDATE
                                   , PARVALUE
                                   , COEFFICIENT
                                   , STDBOND
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.BOND_REPOCONVERSIONSTD
                                WHERE EXECUTESTARTDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "EXECUTESTARTDATE", "type": "STRING"}, {"name": "EXECUTEENDDATE", "type": "STRING"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "COEFFICIENT", "type": "DOUBLE"}, {"name": "STDBOND", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_repoconversionstd_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_repoconversionstd_ptd_tmp",
            "writeMode": "append",
            "encoding": "utf-8",
            "haveKerberos": "${haveKerberos}",
            "kerberosKeytabFilePath": "${kerberosKeytabFilePath}",
            "kerberosPrincipal": "${kerberosPrincipal}"
          }
        }
      }
    ]
  }
}
EOF
)

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_repoconversionstd_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_repoconversionstd_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_REPOCONVERSIONSTD_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_REPOCONVERSIONSTD_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_repoconversionstd_ptd_tmp.json

inceptor_beeline "
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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_REPOCONVERSIONSTD_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , INFOPUBLDATE
     , ENDDATE
     , EXECUTESTARTDATE
     , EXECUTEENDDATE
     , PARVALUE
     , COEFFICIENT
     , STDBOND
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(EXECUTESTARTDATE,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_BOND_REPOCONVERSIONSTD_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_REPOCONVERSIONSTD_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_REPOCONVERSIONSTD_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_REPOCONVERSIONSTD_PTD成功"
      exit 0
   fi
fi
