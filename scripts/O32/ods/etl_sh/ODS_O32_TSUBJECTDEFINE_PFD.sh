#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSUBJECTDEFINE_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTDEFINE_PFD_TMP(
  L_SUBJECT_NO  DECIMAL(10,0)  COMMENT  '系统科目',
  VC_SUBJECT_NAME  STRING  COMMENT  '科目名称',
  C_ASSET_CLASS  STRING  COMMENT  '资产类别',
  C_CURRENCY  STRING  COMMENT  '*币种＃',
  C_TYPE  STRING  COMMENT  '类型',
  L_RATE_TYPE  DECIMAL(4,0)  COMMENT  '利率类别',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  L_ORIGINAL_SUBJECT_NO  DECIMAL(10,0)  COMMENT  ''
)
COMMENT '系统科目定义表'
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
              "querySql": ["SELECT  L_SUBJECT_NO
                                   , VC_SUBJECT_NAME
                                   , C_ASSET_CLASS
                                   , C_CURRENCY
                                   , C_TYPE
                                   , L_RATE_TYPE
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , L_ORIGINAL_SUBJECT_NO
                                FROM ${o32_src_schema}.TSUBJECTDEFINE"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SUBJECT_NO", "type": "DOUBLE"}, {"name": "VC_SUBJECT_NAME", "type": "STRING"}, {"name": "C_ASSET_CLASS", "type": "STRING"}, {"name": "C_CURRENCY", "type": "STRING"}, {"name": "C_TYPE", "type": "STRING"}, {"name": "L_RATE_TYPE", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "L_ORIGINAL_SUBJECT_NO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tsubjectdefine_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tsubjectdefine_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tsubjectdefine_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tsubjectdefine_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSUBJECTDEFINE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSUBJECTDEFINE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tsubjectdefine_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTDEFINE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_SUBJECT_NO
     , VC_SUBJECT_NAME
     , C_ASSET_CLASS
     , C_CURRENCY
     , C_TYPE
     , L_RATE_TYPE
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , L_ORIGINAL_SUBJECT_NO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSUBJECTDEFINE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTDEFINE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSUBJECTDEFINE_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSUBJECTDEFINE_PFD成功"
      exit 0
   fi
fi
