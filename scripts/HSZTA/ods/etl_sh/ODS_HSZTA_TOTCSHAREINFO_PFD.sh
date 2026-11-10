#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TOTCSHAREINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TOTCSHAREINFO_PFD_TMP(
  C_TACODE  STRING  COMMENT  '',
  C_OUTERFUNDCODE  STRING  COMMENT  '',
  C_ISSUECODE  STRING  COMMENT  '',
  C_FUNDNO  STRING  COMMENT  '',
  C_AGENCYNO  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '',
  C_TRADEACCO  STRING  COMMENT  '',
  F_USEABLESHARES  DECIMAL(16,2)  COMMENT  '',
  F_TOTALSHARES  DECIMAL(16,2)  COMMENT  '',
  F_FROZENSHARES  DECIMAL(16,2)  COMMENT  '',
  C_CSERIALNO  STRING  COMMENT  '',
  D_REGISTDATE  STRING  COMMENT  '',
  C_DETAILFLAG  STRING  COMMENT  '',
  C_FUNDCODE  STRING  COMMENT  '',
  C_SHARETYPE  STRING  COMMENT  '',
  C_NETNO  STRING  COMMENT  '',
  D_LASTMODIFY  STRING  COMMENT  '',
  D_CYCLESTARTDATE  STRING  COMMENT  '',
  D_CYCLEENDDATE  STRING  COMMENT  ''
)
COMMENT 'OTC份额信息表'
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
              "querySql": ["SELECT  C_TACODE
                                   , C_OUTERFUNDCODE
                                   , C_ISSUECODE
                                   , C_FUNDNO
                                   , C_AGENCYNO
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , F_USEABLESHARES
                                   , F_TOTALSHARES
                                   , F_FROZENSHARES
                                   , C_CSERIALNO
                                   , D_REGISTDATE
                                   , C_DETAILFLAG
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_NETNO
                                   , D_LASTMODIFY
                                   , D_CYCLESTARTDATE
                                   , D_CYCLEENDDATE
                                FROM ${hszta_src_schema}.TOTCSHAREINFO"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_TACODE", "type": "STRING"}, {"name": "C_OUTERFUNDCODE", "type": "STRING"}, {"name": "C_ISSUECODE", "type": "STRING"}, {"name": "C_FUNDNO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "F_USEABLESHARES", "type": "DOUBLE"}, {"name": "F_TOTALSHARES", "type": "DOUBLE"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "C_DETAILFLAG", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "D_CYCLESTARTDATE", "type": "STRING"}, {"name": "D_CYCLEENDDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_totcshareinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_totcshareinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_totcshareinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_totcshareinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TOTCSHAREINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TOTCSHAREINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_totcshareinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TOTCSHAREINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_TACODE
     , C_OUTERFUNDCODE
     , C_ISSUECODE
     , C_FUNDNO
     , C_AGENCYNO
     , C_FUNDACCO
     , C_TRADEACCO
     , F_USEABLESHARES
     , F_TOTALSHARES
     , F_FROZENSHARES
     , C_CSERIALNO
     , D_REGISTDATE
     , C_DETAILFLAG
     , C_FUNDCODE
     , C_SHARETYPE
     , C_NETNO
     , D_LASTMODIFY
     , D_CYCLESTARTDATE
     , D_CYCLEENDDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TOTCSHAREINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TOTCSHAREINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TOTCSHAREINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TOTCSHAREINFO_PFD成功"
      exit 0
   fi
fi
