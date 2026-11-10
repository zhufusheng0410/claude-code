#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTATAILRATIO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTATAILRATIO_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '',
  C_AGENCYNO  STRING  COMMENT  '',
  F_SHAREMIN  DECIMAL(16,2)  COMMENT  '',
  F_SHAREMAX  DECIMAL(16,2)  COMMENT  '',
  F_RATIO  DECIMAL(9,8)  COMMENT  '',
  F_RATIO1  DECIMAL(9,8)  COMMENT  '',
  D_BEGINDATE  STRING  COMMENT  '',
  C_UPDATEFLAG  STRING  COMMENT  '',
  C_MFUNDACCO  STRING  COMMENT  ''
)
COMMENT '尾随佣金比例'
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
              "querySql": ["SELECT  C_FUNDCODE
                                   , C_AGENCYNO
                                   , F_SHAREMIN
                                   , F_SHAREMAX
                                   , F_RATIO
                                   , F_RATIO1
                                   , D_BEGINDATE
                                   , C_UPDATEFLAG
                                   , C_MFUNDACCO
                                FROM ${hsfta_src_schema}.TSUBTATAILRATIO"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "F_SHAREMIN", "type": "DOUBLE"}, {"name": "F_SHAREMAX", "type": "DOUBLE"}, {"name": "F_RATIO", "type": "DOUBLE"}, {"name": "F_RATIO1", "type": "DOUBLE"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "C_UPDATEFLAG", "type": "STRING"}, {"name": "C_MFUNDACCO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tsubtatailratio_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tsubtatailratio_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tsubtatailratio_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tsubtatailratio_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TSUBTATAILRATIO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TSUBTATAILRATIO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tsubtatailratio_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTATAILRATIO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_AGENCYNO
     , F_SHAREMIN
     , F_SHAREMAX
     , F_RATIO
     , F_RATIO1
     , D_BEGINDATE
     , C_UPDATEFLAG
     , C_MFUNDACCO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTATAILRATIO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSUBTATAILRATIO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TSUBTATAILRATIO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TSUBTATAILRATIO_PFD成功"
      exit 0
   fi
fi
