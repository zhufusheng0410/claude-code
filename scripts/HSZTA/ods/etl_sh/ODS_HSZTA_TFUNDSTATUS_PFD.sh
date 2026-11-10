#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDSTATUS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDSTATUS_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  D_CDATE  STRING  COMMENT  '预设日期',
  C_FUNDSTATUS  STRING  COMMENT  '基金状态',
  F_NETVALUE  DECIMAL(20,8)  COMMENT  '基金净值（成交价）',
  C_ACCOUNTINGDAY  STRING  COMMENT  '估值日标志',
  D_BEGINDATE  STRING  COMMENT  '',
  D_ENDDATE  STRING  COMMENT  ''
)
COMMENT '预设基金状态'
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
              "querySql": ["SELECT  C_FUNDCODE
                                   , D_CDATE
                                   , C_FUNDSTATUS
                                   , F_NETVALUE
                                   , C_ACCOUNTINGDAY
                                   , D_BEGINDATE
                                   , D_ENDDATE
                                FROM ${hszta_src_schema}.TFUNDSTATUS"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_FUNDSTATUS", "type": "STRING"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "C_ACCOUNTINGDAY", "type": "STRING"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "D_ENDDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tfundstatus_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tfundstatus_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tfundstatus_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tfundstatus_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TFUNDSTATUS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TFUNDSTATUS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tfundstatus_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDSTATUS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , D_CDATE
     , C_FUNDSTATUS
     , F_NETVALUE
     , C_ACCOUNTINGDAY
     , D_BEGINDATE
     , D_ENDDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDSTATUS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDSTATUS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TFUNDSTATUS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TFUNDSTATUS_PFD成功"
      exit 0
   fi
fi
