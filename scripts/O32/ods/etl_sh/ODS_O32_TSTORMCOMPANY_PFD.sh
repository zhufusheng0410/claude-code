#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTORMCOMPANY_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTORMCOMPANY_PFD_TMP(
  L_COMP_ID  DECIMAL(10,0)  COMMENT  '提供商序号',
  VC_COMP_NAME  STRING  COMMENT  '提供商名称',
  VC_MODULE_NAME  STRING  COMMENT  '提供商module名',
  L_SCHEMA_COUNT  DECIMAL(10,0)  COMMENT  '可建母单数量',
  VC_LIMIT_FUNCTION  STRING  COMMENT  '限制功能',
  C_ACCESS_TYPE  STRING  COMMENT  '',
  VC_CONN_TYPE  STRING  COMMENT  ''
)
COMMENT '算法提供商明细表'
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
              "querySql": ["SELECT  L_COMP_ID
                                   , VC_COMP_NAME
                                   , VC_MODULE_NAME
                                   , L_SCHEMA_COUNT
                                   , VC_LIMIT_FUNCTION
                                   , C_ACCESS_TYPE
                                   , VC_CONN_TYPE
                                FROM ${o32_src_schema}.TSTORMCOMPANY"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_COMP_ID", "type": "DOUBLE"}, {"name": "VC_COMP_NAME", "type": "STRING"}, {"name": "VC_MODULE_NAME", "type": "STRING"}, {"name": "L_SCHEMA_COUNT", "type": "DOUBLE"}, {"name": "VC_LIMIT_FUNCTION", "type": "STRING"}, {"name": "C_ACCESS_TYPE", "type": "STRING"}, {"name": "VC_CONN_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstormcompany_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstormcompany_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstormcompany_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstormcompany_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTORMCOMPANY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTORMCOMPANY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstormcompany_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTORMCOMPANY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_COMP_ID
     , VC_COMP_NAME
     , VC_MODULE_NAME
     , L_SCHEMA_COUNT
     , VC_LIMIT_FUNCTION
     , C_ACCESS_TYPE
     , VC_CONN_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSTORMCOMPANY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTORMCOMPANY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTORMCOMPANY_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTORMCOMPANY_PFD成功"
      exit 0
   fi
fi
