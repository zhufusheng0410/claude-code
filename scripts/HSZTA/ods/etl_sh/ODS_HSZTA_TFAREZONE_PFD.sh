#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TFAREZONE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFAREZONE_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '',
  C_AGENCYNO  STRING  COMMENT  '',
  C_SHARETYPE  STRING  COMMENT  '',
  C_BUSINFLAG  STRING  COMMENT  '',
  C_FARETYPE  STRING  COMMENT  '',
  L_MINBALANCE  DECIMAL(14,0)  COMMENT  '',
  L_MAXBALANCE  DECIMAL(14,0)  COMMENT  '',
  L_MINPREDAYS  DECIMAL(10,0)  COMMENT  '',
  L_MAXPREDAYS  DECIMAL(10,0)  COMMENT  '',
  L_MINHOLD  DECIMAL(10,0)  COMMENT  '',
  L_MAXHOLD  DECIMAL(10,0)  COMMENT  '',
  F_RATIO  DECIMAL(9,8)  COMMENT  '',
  F_MINFARE  DECIMAL(16,2)  COMMENT  '',
  F_MAXFARE  DECIMAL(16,2)  COMMENT  '',
  C_OTHERFUND  STRING  COMMENT  '',
  C_OTHERSHARE  STRING  COMMENT  '',
  C_SPECIALTIES  STRING  COMMENT  '',
  D_CSTARTDATE  STRING  COMMENT  '',
  F_LEASTRATIO  DECIMAL(16,6)  COMMENT  '',
  C_NETNO  STRING  COMMENT  '',
  C_ONLINEINPUTDATE  STRING  COMMENT  '',
  C_CUSTTYPE  STRING  COMMENT  '',
  F_MAXRATE  DECIMAL(9,8)  COMMENT  '',
  F_MAXRDMRATE  DECIMAL(9,8)  COMMENT  '',
  F_MINRDMRATE  DECIMAL(9,8)  COMMENT  ''
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , C_AGENCYNO
                                   , C_SHARETYPE
                                   , C_BUSINFLAG
                                   , C_FARETYPE
                                   , L_MINBALANCE
                                   , L_MAXBALANCE
                                   , L_MINPREDAYS
                                   , L_MAXPREDAYS
                                   , L_MINHOLD
                                   , L_MAXHOLD
                                   , F_RATIO
                                   , F_MINFARE
                                   , F_MAXFARE
                                   , C_OTHERFUND
                                   , C_OTHERSHARE
                                   , C_SPECIALTIES
                                   , D_CSTARTDATE
                                   , F_LEASTRATIO
                                   , C_NETNO
                                   , C_ONLINEINPUTDATE
                                   , C_CUSTTYPE
                                   , F_MAXRATE
                                   , F_MAXRDMRATE
                                   , F_MINRDMRATE
                                FROM ${hszta_src_schema}.TFAREZONE"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "C_FARETYPE", "type": "STRING"}, {"name": "L_MINBALANCE", "type": "DOUBLE"}, {"name": "L_MAXBALANCE", "type": "DOUBLE"}, {"name": "L_MINPREDAYS", "type": "DOUBLE"}, {"name": "L_MAXPREDAYS", "type": "DOUBLE"}, {"name": "L_MINHOLD", "type": "DOUBLE"}, {"name": "L_MAXHOLD", "type": "DOUBLE"}, {"name": "F_RATIO", "type": "DOUBLE"}, {"name": "F_MINFARE", "type": "DOUBLE"}, {"name": "F_MAXFARE", "type": "DOUBLE"}, {"name": "C_OTHERFUND", "type": "STRING"}, {"name": "C_OTHERSHARE", "type": "STRING"}, {"name": "C_SPECIALTIES", "type": "STRING"}, {"name": "D_CSTARTDATE", "type": "STRING"}, {"name": "F_LEASTRATIO", "type": "DOUBLE"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_ONLINEINPUTDATE", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "F_MAXRATE", "type": "DOUBLE"}, {"name": "F_MAXRDMRATE", "type": "DOUBLE"}, {"name": "F_MINRDMRATE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tfarezone_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tfarezone_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tfarezone_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tfarezone_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TFAREZONE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TFAREZONE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tfarezone_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFAREZONE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_AGENCYNO
     , C_SHARETYPE
     , C_BUSINFLAG
     , C_FARETYPE
     , L_MINBALANCE
     , L_MAXBALANCE
     , L_MINPREDAYS
     , L_MAXPREDAYS
     , L_MINHOLD
     , L_MAXHOLD
     , F_RATIO
     , F_MINFARE
     , F_MAXFARE
     , C_OTHERFUND
     , C_OTHERSHARE
     , C_SPECIALTIES
     , D_CSTARTDATE
     , F_LEASTRATIO
     , C_NETNO
     , C_ONLINEINPUTDATE
     , C_CUSTTYPE
     , F_MAXRATE
     , F_MAXRDMRATE
     , F_MINRDMRATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFAREZONE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFAREZONE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TFAREZONE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TFAREZONE_PFD成功"
      exit 0
   fi
fi
