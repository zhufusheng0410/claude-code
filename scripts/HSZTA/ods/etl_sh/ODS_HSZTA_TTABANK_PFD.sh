#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TTABANK_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TTABANK_PFD_TMP(
  L_TASPECIALACCOID  DECIMAL(10,0)  COMMENT  '',
  C_BANKNO  STRING  COMMENT  '',
  C_BANKACCO  STRING  COMMENT  '',
  F_BALANCE  DECIMAL(16,2)  COMMENT  '',
  C_TAACCONAME  STRING  COMMENT  '',
  L_BANKACCONO  DECIMAL(10,0)  COMMENT  '',
  L_TA2ACCOUNTNO  DECIMAL(3,0)  COMMENT  ''
)
COMMENT '银行信息表'
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  L_TASPECIALACCOID
                                   , C_BANKNO
                                   , C_BANKACCO
                                   , F_BALANCE
                                   , C_TAACCONAME
                                   , L_BANKACCONO
                                   , L_TA2ACCOUNTNO
                                FROM ${hszta_src_schema}.TTABANK"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_TASPECIALACCOID", "type": "DOUBLE"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_BANKACCO", "type": "STRING"}, {"name": "F_BALANCE", "type": "DOUBLE"}, {"name": "C_TAACCONAME", "type": "STRING"}, {"name": "L_BANKACCONO", "type": "DOUBLE"}, {"name": "L_TA2ACCOUNTNO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_ttabank_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_ttabank_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_ttabank_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_ttabank_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TTABANK_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TTABANK_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_ttabank_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TTABANK_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_TASPECIALACCOID
     , C_BANKNO
     , C_BANKACCO
     , F_BALANCE
     , C_TAACCONAME
     , L_BANKACCONO
     , L_TA2ACCOUNTNO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TTABANK_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TTABANK_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TTABANK_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TTABANK_PFD成功"
      exit 0
   fi
fi
