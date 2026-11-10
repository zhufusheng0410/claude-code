#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TCFNL_ZQPJ_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCFNL_ZQPJ_PFD_TMP(
  L_ZQNM  DECIMAL(18,2)  COMMENT  '',
  VC_ZQDM  STRING  COMMENT  '',
  VC_ZQJC  STRING  COMMENT  '',
  VC_JYSC  STRING  COMMENT  '',
  VC_ZQPJ  STRING  COMMENT  '',
  VC_FXJG  STRING  COMMENT  '',
  D_PJRQ  STRING  COMMENT  '',
  L_CLBZ  DECIMAL(1,0)  COMMENT  ''
)
COMMENT '偿付能力-债券信用评级表'
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_ZQNM
                                   , VC_ZQDM
                                   , VC_ZQJC
                                   , VC_JYSC
                                   , VC_ZQPJ
                                   , VC_FXJG
                                   , D_PJRQ
                                   , L_CLBZ
                                FROM ${hsfa_src_schema}.TCFNL_ZQPJ"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "VC_ZQJC", "type": "STRING"}, {"name": "VC_JYSC", "type": "STRING"}, {"name": "VC_ZQPJ", "type": "STRING"}, {"name": "VC_FXJG", "type": "STRING"}, {"name": "D_PJRQ", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tcfnl_zqpj_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tcfnl_zqpj_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tcfnl_zqpj_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tcfnl_zqpj_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TCFNL_ZQPJ_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TCFNL_ZQPJ_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tcfnl_zqpj_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCFNL_ZQPJ_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZQNM
     , VC_ZQDM
     , VC_ZQJC
     , VC_JYSC
     , VC_ZQPJ
     , VC_FXJG
     , D_PJRQ
     , L_CLBZ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TCFNL_ZQPJ_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCFNL_ZQPJ_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TCFNL_ZQPJ_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TCFNL_ZQPJ_PFD成功"
      exit 0
   fi
fi
