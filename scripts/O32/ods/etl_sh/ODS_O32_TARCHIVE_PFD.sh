#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TARCHIVE_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TARCHIVE_PFD_TMP(
  VC_TABLE_NAME  STRING  COMMENT  '归档表名',
  C_ARCHIVE_TYPE  STRING  COMMENT  '归档方式',
  VC_CONDITION  STRING  COMMENT  '归档条件',
  VC_MEMO  STRING  COMMENT  '备注',
  C_FUND_FLAG  STRING  COMMENT  '分基金标志',
  C_ARCHIVE_POINT  STRING  COMMENT  '归档时点'
)
COMMENT '归档配置表'
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
            "username": "${o32_username}",
            "password": "${o32_password}",
            "connection": [{
              "querySql": ["SELECT  VC_TABLE_NAME
                                   , C_ARCHIVE_TYPE
                                   , VC_CONDITION
                                   , VC_MEMO
                                   , C_FUND_FLAG
                                   , C_ARCHIVE_POINT
                                FROM ${o32_src_schema}.TARCHIVE"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_TABLE_NAME", "type": "STRING"}, {"name": "C_ARCHIVE_TYPE", "type": "STRING"}, {"name": "VC_CONDITION", "type": "STRING"}, {"name": "VC_MEMO", "type": "STRING"}, {"name": "C_FUND_FLAG", "type": "STRING"}, {"name": "C_ARCHIVE_POINT", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tarchive_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tarchive_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tarchive_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tarchive_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TARCHIVE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TARCHIVE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tarchive_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TARCHIVE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_TABLE_NAME
     , C_ARCHIVE_TYPE
     , VC_CONDITION
     , VC_MEMO
     , C_FUND_FLAG
     , C_ARCHIVE_POINT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TARCHIVE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TARCHIVE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TARCHIVE_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TARCHIVE_PFD成功"
      exit 0
   fi
fi
