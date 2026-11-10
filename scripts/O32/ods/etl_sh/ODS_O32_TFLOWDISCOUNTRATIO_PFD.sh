#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFLOWDISCOUNTRATIO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFLOWDISCOUNTRATIO_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_RSEND_DATE  DECIMAL(8,0)  COMMENT  '受限结束日期',
  L_RSRESIDUE_DAY  DECIMAL(8,0)  COMMENT  '剩余受限期',
  EN_FLOW_DISCOUNT_RATIO  DECIMAL(20,6)  COMMENT  '流动性折扣',
  L_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '修改日期',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_FLOW_DATE  DECIMAL(8,0)  COMMENT  ''
)
COMMENT '流动性折扣系数表'
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
                                   , VC_INTER_CODE
                                   , L_RSEND_DATE
                                   , L_RSRESIDUE_DAY
                                   , EN_FLOW_DISCOUNT_RATIO
                                   , L_MODIFY_DATE
                                   , L_VIRTUAL_KEY
                                   , VC_TIMESTAMP
                                   , L_FLOW_DATE
                                FROM ${o32_src_schema}.THISFLOWDISCOUNTRATIO
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_RSEND_DATE", "type": "DOUBLE"}, {"name": "L_RSRESIDUE_DAY", "type": "DOUBLE"}, {"name": "EN_FLOW_DISCOUNT_RATIO", "type": "DOUBLE"}, {"name": "L_MODIFY_DATE", "type": "DOUBLE"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_FLOW_DATE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tflowdiscountratio_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tflowdiscountratio_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tflowdiscountratio_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tflowdiscountratio_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFLOWDISCOUNTRATIO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFLOWDISCOUNTRATIO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tflowdiscountratio_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFLOWDISCOUNTRATIO_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_INTER_CODE
     , L_RSEND_DATE
     , L_RSRESIDUE_DAY
     , EN_FLOW_DISCOUNT_RATIO
     , L_MODIFY_DATE
     , L_VIRTUAL_KEY
     , VC_TIMESTAMP
     , L_FLOW_DATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TFLOWDISCOUNTRATIO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFLOWDISCOUNTRATIO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFLOWDISCOUNTRATIO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFLOWDISCOUNTRATIO_PFD成功"
      exit 0
   fi
fi
