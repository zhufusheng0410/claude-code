#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TOAD_PLAN_TABLE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TOAD_PLAN_TABLE_PFD_TMP(
  STATEMENT_ID  STRING  COMMENT  '',
  PLAN_ID  DECIMAL(18,0)  COMMENT  '',
  \`TIMESTAMP\`  STRING  COMMENT  '',
  REMARKS  STRING  COMMENT  '',
  OPERATION  STRING  COMMENT  '',
  OPTIONS  STRING  COMMENT  '',
  OBJECT_NODE  STRING  COMMENT  '',
  OBJECT_OWNER  STRING  COMMENT  '',
  OBJECT_NAME  STRING  COMMENT  '',
  OBJECT_ALIAS  STRING  COMMENT  '',
  OBJECT_INSTANCE  DECIMAL(18,0)  COMMENT  '',
  OBJECT_TYPE  STRING  COMMENT  '',
  OPTIMIZER  STRING  COMMENT  '',
  SEARCH_COLUMNS  DECIMAL(18,0)  COMMENT  '',
  ID  DECIMAL(18,0)  COMMENT  '',
  PARENT_ID  DECIMAL(18,0)  COMMENT  '',
  DEPTH  DECIMAL(18,0)  COMMENT  '',
  POSITION  DECIMAL(18,0)  COMMENT  '',
  COST  DECIMAL(18,0)  COMMENT  '',
  CARDINALITY  DECIMAL(18,0)  COMMENT  '',
  BYTES  DECIMAL(18,0)  COMMENT  '',
  OTHER_TAG  STRING  COMMENT  '',
  PARTITION_START  STRING  COMMENT  '',
  PARTITION_STOP  STRING  COMMENT  '',
  PARTITION_ID  DECIMAL(18,0)  COMMENT  '',
  OTHER  DECIMAL(18,0)  COMMENT  '',
  DISTRIBUTION  STRING  COMMENT  '',
  CPU_COST  DECIMAL(18,0)  COMMENT  '',
  IO_COST  DECIMAL(18,0)  COMMENT  '',
  TEMP_SPACE  DECIMAL(18,0)  COMMENT  '',
  ACCESS_PREDICATES  STRING  COMMENT  '',
  FILTER_PREDICATES  STRING  COMMENT  '',
  PROJECTION  STRING  COMMENT  '',
  \`TIME\`  DECIMAL(18,0)  COMMENT  ''
)
COMMENT ''
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
            "username": "${hsds_username}",
            "password": "${hsds_password}",
            "connection": [{
              "querySql": ["SELECT  STATEMENT_ID\n                                   , PLAN_ID\n                                   , TIMESTAMP\n                                   , REMARKS\n                                   , OPERATION\n                                   , OPTIONS\n                                   , OBJECT_NODE\n                                   , OBJECT_OWNER\n                                   , OBJECT_NAME\n                                   , OBJECT_ALIAS\n                                   , OBJECT_INSTANCE\n                                   , OBJECT_TYPE\n                                   , OPTIMIZER\n                                   , SEARCH_COLUMNS\n                                   , ID\n                                   , PARENT_ID\n                                   , DEPTH\n                                   , POSITION\n                                   , COST\n                                   , CARDINALITY\n                                   , BYTES\n                                   , OTHER_TAG\n                                   , PARTITION_START\n                                   , PARTITION_STOP\n                                   , PARTITION_ID\n                                   , OTHER\n                                   , DISTRIBUTION\n                                   , CPU_COST\n                                   , IO_COST\n                                   , TEMP_SPACE\n                                   , ACCESS_PREDICATES\n                                   , FILTER_PREDICATES\n                                   , PROJECTION\n                                   , TIME\n                                FROM ${hsds_src_schema}.TOAD_PLAN_TABLE"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "STATEMENT_ID", "type": "STRING"}, {"name": "PLAN_ID", "type": "DOUBLE"}, {"name": "TIMESTAMP", "type": "STRING"}, {"name": "REMARKS", "type": "STRING"}, {"name": "OPERATION", "type": "STRING"}, {"name": "OPTIONS", "type": "STRING"}, {"name": "OBJECT_NODE", "type": "STRING"}, {"name": "OBJECT_OWNER", "type": "STRING"}, {"name": "OBJECT_NAME", "type": "STRING"}, {"name": "OBJECT_ALIAS", "type": "STRING"}, {"name": "OBJECT_INSTANCE", "type": "DOUBLE"}, {"name": "OBJECT_TYPE", "type": "STRING"}, {"name": "OPTIMIZER", "type": "STRING"}, {"name": "SEARCH_COLUMNS", "type": "DOUBLE"}, {"name": "ID", "type": "DOUBLE"}, {"name": "PARENT_ID", "type": "DOUBLE"}, {"name": "DEPTH", "type": "DOUBLE"}, {"name": "POSITION", "type": "DOUBLE"}, {"name": "COST", "type": "DOUBLE"}, {"name": "CARDINALITY", "type": "DOUBLE"}, {"name": "BYTES", "type": "DOUBLE"}, {"name": "OTHER_TAG", "type": "STRING"}, {"name": "PARTITION_START", "type": "STRING"}, {"name": "PARTITION_STOP", "type": "STRING"}, {"name": "PARTITION_ID", "type": "DOUBLE"}, {"name": "OTHER", "type": "STRING"}, {"name": "DISTRIBUTION", "type": "STRING"}, {"name": "CPU_COST", "type": "DOUBLE"}, {"name": "IO_COST", "type": "DOUBLE"}, {"name": "TEMP_SPACE", "type": "DOUBLE"}, {"name": "ACCESS_PREDICATES", "type": "STRING"}, {"name": "FILTER_PREDICATES", "type": "STRING"}, {"name": "PROJECTION", "type": "STRING"}, {"name": "TIME", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_toad_plan_table_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_toad_plan_table_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_toad_plan_table_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_toad_plan_table_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TOAD_PLAN_TABLE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TOAD_PLAN_TABLE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_toad_plan_table_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TOAD_PLAN_TABLE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       STATEMENT_ID
     , PLAN_ID
     , \`TIMESTAMP\`
     , REMARKS
     , OPERATION
     , OPTIONS
     , OBJECT_NODE
     , OBJECT_OWNER
     , OBJECT_NAME
     , OBJECT_ALIAS
     , OBJECT_INSTANCE
     , OBJECT_TYPE
     , OPTIMIZER
     , SEARCH_COLUMNS
     , ID
     , PARENT_ID
     , DEPTH
     , POSITION
     , COST
     , CARDINALITY
     , BYTES
     , OTHER_TAG
     , PARTITION_START
     , PARTITION_STOP
     , PARTITION_ID
     , OTHER
     , DISTRIBUTION
     , CPU_COST
     , IO_COST
     , TEMP_SPACE
     , ACCESS_PREDICATES
     , FILTER_PREDICATES
     , PROJECTION
     , \`TIME\`
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TOAD_PLAN_TABLE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TOAD_PLAN_TABLE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TOAD_PLAN_TABLE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TOAD_PLAN_TABLE_PFD成功"
      exit 0
   fi
fi
