#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TFAREZONE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFAREZONE_PFD_TMP(
  L_ZONENO  DECIMAL(10,0)  COMMENT  '',
  C_FUNDCODE  STRING  COMMENT  '',
  C_SHARETYPE  STRING  COMMENT  '',
  C_BUSINFLAG  STRING  COMMENT  '',
  C_FARETYPE  STRING  COMMENT  '',
  C_CUSTTYPE  STRING  COMMENT  '',
  C_SALETYPE  STRING  COMMENT  '',
  L_MINBALANCE  DECIMAL(14,0)  COMMENT  '',
  L_MAXBALANCE  DECIMAL(14,0)  COMMENT  '',
  L_MINPREDAYS  DECIMAL(14,0)  COMMENT  '',
  L_MAXPREDAYS  DECIMAL(14,0)  COMMENT  '',
  L_MINHOLD  DECIMAL(14,0)  COMMENT  '',
  L_MAXHOLD  DECIMAL(14,0)  COMMENT  '',
  F_RATIO  DECIMAL(6,5)  COMMENT  '',
  F_MINFARE  DECIMAL(16,2)  COMMENT  '',
  F_MAXFARE  DECIMAL(16,2)  COMMENT  '',
  F_CALCULATENUMERIC  DECIMAL(16,2)  COMMENT  '',
  C_OTHERFUND  STRING  COMMENT  '',
  C_RESERVE  STRING  COMMENT  '',
  C_OTHERSHARE  STRING  COMMENT  '',
  C_SPECIALTIES  STRING  COMMENT  '',
  C_BOURSECALCFLAG  STRING  COMMENT  '',
  D_CSTARTDATE  STRING  COMMENT  '',
  C_VILDFLAG  STRING  COMMENT  ''
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  L_ZONENO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_BUSINFLAG
                                   , C_FARETYPE
                                   , C_CUSTTYPE
                                   , C_SALETYPE
                                   , L_MINBALANCE
                                   , L_MAXBALANCE
                                   , L_MINPREDAYS
                                   , L_MAXPREDAYS
                                   , L_MINHOLD
                                   , L_MAXHOLD
                                   , F_RATIO
                                   , F_MINFARE
                                   , F_MAXFARE
                                   , F_CALCULATENUMERIC
                                   , C_OTHERFUND
                                   , C_RESERVE
                                   , C_OTHERSHARE
                                   , C_SPECIALTIES
                                   , C_BOURSECALCFLAG
                                   , D_CSTARTDATE
                                   , C_VILDFLAG
                                FROM ${hsfta_src_schema}.TFAREZONE"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZONENO", "type": "DOUBLE"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "C_FARETYPE", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_SALETYPE", "type": "STRING"}, {"name": "L_MINBALANCE", "type": "DOUBLE"}, {"name": "L_MAXBALANCE", "type": "DOUBLE"}, {"name": "L_MINPREDAYS", "type": "DOUBLE"}, {"name": "L_MAXPREDAYS", "type": "DOUBLE"}, {"name": "L_MINHOLD", "type": "DOUBLE"}, {"name": "L_MAXHOLD", "type": "DOUBLE"}, {"name": "F_RATIO", "type": "DOUBLE"}, {"name": "F_MINFARE", "type": "DOUBLE"}, {"name": "F_MAXFARE", "type": "DOUBLE"}, {"name": "F_CALCULATENUMERIC", "type": "DOUBLE"}, {"name": "C_OTHERFUND", "type": "STRING"}, {"name": "C_RESERVE", "type": "STRING"}, {"name": "C_OTHERSHARE", "type": "STRING"}, {"name": "C_SPECIALTIES", "type": "STRING"}, {"name": "C_BOURSECALCFLAG", "type": "STRING"}, {"name": "D_CSTARTDATE", "type": "STRING"}, {"name": "C_VILDFLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tfarezone_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tfarezone_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tfarezone_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tfarezone_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TFAREZONE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TFAREZONE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tfarezone_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFAREZONE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZONENO
     , C_FUNDCODE
     , C_SHARETYPE
     , C_BUSINFLAG
     , C_FARETYPE
     , C_CUSTTYPE
     , C_SALETYPE
     , L_MINBALANCE
     , L_MAXBALANCE
     , L_MINPREDAYS
     , L_MAXPREDAYS
     , L_MINHOLD
     , L_MAXHOLD
     , F_RATIO
     , F_MINFARE
     , F_MAXFARE
     , F_CALCULATENUMERIC
     , C_OTHERFUND
     , C_RESERVE
     , C_OTHERSHARE
     , C_SPECIALTIES
     , C_BOURSECALCFLAG
     , D_CSTARTDATE
     , C_VILDFLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFAREZONE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFAREZONE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TFAREZONE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TFAREZONE_PFD成功"
      exit 0
   fi
fi
