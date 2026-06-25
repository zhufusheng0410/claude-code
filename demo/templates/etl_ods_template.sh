#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
source ${source_path}
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ${target_schema}.${tmp_table};
CREATE TABLE ${target_schema}.${tmp_table}(
${tmp_field_defs}
)
COMMENT '${table_cn}'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\u0001';"

json_obj=$(cat <<'EOF'
{
  "job": {
    "setting": {
      "speed": {
        "channel": 3
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
              "querySql": ["${query_sql}"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": ${writer_columns},
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.nameservices": "${service}",
              "dfs.namenode.rpc-address.${service}.${node1}": "hdfsnamenode-${namenode}",
              "dfs.namenode.rpc-address.${service}.${node2}": "hdfssecondary-${namenode}",
              "dfs.client.failover.proxy.provider.${service}": "org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "${tmp_table_name}",
            "fileType": "text",
            "path": "${o32_path}/${tmp_table_name}",
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

sudo -u ${ds_user} echo $json_obj>${json_path}${tmp_table_name}.json

sudo -u ${ds_user} python ${datax_path} ${json_path}${tmp_table_name}.json

if [ $? -ne 0 ]; then
   echo "导入到${tmp_table}表失败"
   exit 1
else
   echo "导入到${tmp_table}表成功"
   sudo -u ${ds_user} rm -f ${json_path}${tmp_table_name}.json

inceptor_beeline "
${dynamic_sets}
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ${target_schema}.${target_table} ${partition_clause}
SELECT
${select_columns}
  FROM ${target_schema}.${tmp_table}
;
TRUNCATE TABLE ${target_schema}.${tmp_table};"
if [ $? -ne 0 ]; then
      echo "插入到${target_table}失败"
      exit 1
   else
      echo "插入到${target_table}成功"
      exit 0
   fi
fi