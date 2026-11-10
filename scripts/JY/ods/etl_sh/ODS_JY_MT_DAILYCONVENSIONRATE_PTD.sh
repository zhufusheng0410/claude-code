#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MT_DAILYCONVENSIONRATE_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MT_DAILYCONVENSIONRATE_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  PUBORGCODE  STRING  COMMENT  '发布机构代码',
  ENDDATE  STRING  COMMENT  '日期',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  FIRSTSECUCATEGORY  STRING  COMMENT  '可充抵保证金证券类别(一级分类)',
  SECONDSECUCATEGORY  STRING  COMMENT  '可充抵保证金证券类别(二级分类)',
  CONVENSIONRATE  DECIMAL(18,10)  COMMENT  '折算率(%)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '可充抵保证金证券日折算率'
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
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , PUBORGCODE
                                   , TO_CHAR(ENDDATE,'YYYYMMDD') ENDDATE
                                   , INNERCODE
                                   , FIRSTSECUCATEGORY
                                   , SECONDSECUCATEGORY
                                   , CONVENSIONRATE
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.MT_DAILYCONVENSIONRATE
                                WHERE ENDDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "PUBORGCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "FIRSTSECUCATEGORY", "type": "DOUBLE"}, {"name": "SECONDSECUCATEGORY", "type": "DOUBLE"}, {"name": "CONVENSIONRATE", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mt_dailyconvensionrate_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mt_dailyconvensionrate_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mt_dailyconvensionrate_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mt_dailyconvensionrate_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MT_DAILYCONVENSIONRATE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MT_DAILYCONVENSIONRATE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mt_dailyconvensionrate_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MT_DAILYCONVENSIONRATE_PTD PARTITION(P_DT)
SELECT
       ID
     , INFOPUBLDATE
     , INFOSOURCE
     , PUBORGCODE
     , ENDDATE
     , INNERCODE
     , FIRSTSECUCATEGORY
     , SECONDSECUCATEGORY
     , CONVENSIONRATE
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(ENDDATE,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_MT_DAILYCONVENSIONRATE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MT_DAILYCONVENSIONRATE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MT_DAILYCONVENSIONRATE_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_MT_DAILYCONVENSIONRATE_PTD成功"
      exit 0
   fi
fi
