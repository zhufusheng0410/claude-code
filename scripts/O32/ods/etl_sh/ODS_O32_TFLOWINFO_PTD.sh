#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFLOWINFO_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFLOWINFO_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_FLOW_NAME  STRING  COMMENT  '操作步骤名称',
  D_DATETIME  STRING  COMMENT  '信息生成的时间',
  VC_INFORMATION  STRING  COMMENT  '操作信息',
  C_INFO_TYPE  STRING  COMMENT  '信息类型',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '操作员',
  L_SERIAL_NO  DECIMAL(12,0)  COMMENT  '序号'
)
COMMENT '流程操作信息'
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
              "querySql": ["SELECT  L_DATE
                                   , VC_FLOW_NAME
                                   , D_DATETIME
                                   , VC_INFORMATION
                                   , C_INFO_TYPE
                                   , L_FUND_ID
                                   , L_OPERATOR_NO
                                   , L_SERIAL_NO
                                FROM ${o32_src_schema}.TFLOWINFO
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_FLOW_NAME", "type": "STRING"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "VC_INFORMATION", "type": "STRING"}, {"name": "C_INFO_TYPE", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tflowinfo_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tflowinfo_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tflowinfo_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tflowinfo_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFLOWINFO_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFLOWINFO_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tflowinfo_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFLOWINFO_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_FLOW_NAME
     , D_DATETIME
     , VC_INFORMATION
     , C_INFO_TYPE
     , L_FUND_ID
     , L_OPERATOR_NO
     , L_SERIAL_NO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TFLOWINFO_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFLOWINFO_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFLOWINFO_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFLOWINFO_PTD成功"
      exit 0
   fi
fi
