#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TCHILDCENTER_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCHILDCENTER_PFD_TMP(
  C_CENTERNO  STRING  COMMENT  '所属分中心',
  C_CENTERNAME  STRING  COMMENT  '分中心名称'
)
COMMENT '直销中心'
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_CENTERNO
                                   , C_CENTERNAME
                                FROM ${hsfta_src_schema}.TCHILDCENTER"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CENTERNO", "type": "STRING"}, {"name": "C_CENTERNAME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tchildcenter_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tchildcenter_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tchildcenter_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tchildcenter_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TCHILDCENTER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TCHILDCENTER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tchildcenter_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCHILDCENTER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_CENTERNO
     , C_CENTERNAME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCHILDCENTER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCHILDCENTER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TCHILDCENTER_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TCHILDCENTER_PFD成功"
      exit 0
   fi
fi
