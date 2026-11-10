#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TOTCCUSTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TOTCCUSTINFO_PFD_TMP(
  C_AGENCYNO  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '',
  C_TRADEACCO  STRING  COMMENT  '',
  C_TACODE  STRING  COMMENT  '',
  C_CUSTTYPE  STRING  COMMENT  '',
  C_IDENTITYTYPE  STRING  COMMENT  '',
  C_IDENTITYNO  STRING  COMMENT  '',
  C_CUSTNAME  STRING  COMMENT  '',
  C_SHORTNAME  STRING  COMMENT  '',
  C_SEX  STRING  COMMENT  '',
  C_PHONE  STRING  COMMENT  '',
  C_NATIONALITY  STRING  COMMENT  '',
  D_IDNOVALIDDATE  STRING  COMMENT  '',
  C_RISKRATE  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '',
  C_ACCOSTATUS  STRING  COMMENT  '',
  D_LASTMODIFY  STRING  COMMENT  ''
)
COMMENT '场外账户信息表'
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
              "querySql": ["SELECT  C_AGENCYNO
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_TACODE
                                   , C_CUSTTYPE
                                   , C_IDENTITYTYPE
                                   , C_IDENTITYNO
                                   , C_CUSTNAME
                                   , C_SHORTNAME
                                   , C_SEX
                                   , C_PHONE
                                   , C_NATIONALITY
                                   , D_IDNOVALIDDATE
                                   , C_RISKRATE
                                   , C_MEMO
                                   , C_ACCOSTATUS
                                   , D_LASTMODIFY
                                FROM ${hszta_src_schema}.TOTCCUSTINFO"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_TACODE", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "C_IDENTITYNO", "type": "STRING"}, {"name": "C_CUSTNAME", "type": "STRING"}, {"name": "C_SHORTNAME", "type": "STRING"}, {"name": "C_SEX", "type": "STRING"}, {"name": "C_PHONE", "type": "STRING"}, {"name": "C_NATIONALITY", "type": "STRING"}, {"name": "D_IDNOVALIDDATE", "type": "STRING"}, {"name": "C_RISKRATE", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "C_ACCOSTATUS", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_totccustinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_totccustinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_totccustinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_totccustinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TOTCCUSTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TOTCCUSTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_totccustinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TOTCCUSTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_AGENCYNO
     , C_FUNDACCO
     , C_TRADEACCO
     , C_TACODE
     , C_CUSTTYPE
     , C_IDENTITYTYPE
     , C_IDENTITYNO
     , C_CUSTNAME
     , C_SHORTNAME
     , C_SEX
     , C_PHONE
     , C_NATIONALITY
     , D_IDNOVALIDDATE
     , C_RISKRATE
     , C_MEMO
     , C_ACCOSTATUS
     , D_LASTMODIFY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TOTCCUSTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TOTCCUSTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TOTCCUSTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TOTCCUSTINFO_PFD成功"
      exit 0
   fi
fi
