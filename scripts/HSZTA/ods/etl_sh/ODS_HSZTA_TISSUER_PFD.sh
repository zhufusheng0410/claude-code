#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TISSUER_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TISSUER_PFD_TMP(
  C_ISSUERCODE  STRING  COMMENT  '',
  C_ISSUERNAME  STRING  COMMENT  '',
  C_ISSUERTYPE  STRING  COMMENT  '',
  C_ISSUERLEVEL  STRING  COMMENT  '',
  C_ISSUERLEVELADD  STRING  COMMENT  '',
  C_ISSUERCREDITAGENCY  STRING  COMMENT  '',
  F_REGISTERCAPITAL  DECIMAL(16,2)  COMMENT  '',
  C_LAWNAME  STRING  COMMENT  '',
  D_REGISTERDATE  STRING  COMMENT  '',
  C_INDUSTRY  STRING  COMMENT  '',
  C_REGISTERADDRESS  STRING  COMMENT  '',
  C_ADDRESS  STRING  COMMENT  '',
  C_TELPHONE  STRING  COMMENT  '',
  C_EMAIL  STRING  COMMENT  '',
  C_FAX  STRING  COMMENT  ''
)
COMMENT '发行人信息表'
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
              "querySql": ["SELECT  C_ISSUERCODE
                                   , C_ISSUERNAME
                                   , C_ISSUERTYPE
                                   , C_ISSUERLEVEL
                                   , C_ISSUERLEVELADD
                                   , C_ISSUERCREDITAGENCY
                                   , F_REGISTERCAPITAL
                                   , C_LAWNAME
                                   , D_REGISTERDATE
                                   , C_INDUSTRY
                                   , C_REGISTERADDRESS
                                   , C_ADDRESS
                                   , C_TELPHONE
                                   , C_EMAIL
                                   , C_FAX
                                FROM ${hszta_src_schema}.TISSUER"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_ISSUERCODE", "type": "STRING"}, {"name": "C_ISSUERNAME", "type": "STRING"}, {"name": "C_ISSUERTYPE", "type": "STRING"}, {"name": "C_ISSUERLEVEL", "type": "STRING"}, {"name": "C_ISSUERLEVELADD", "type": "STRING"}, {"name": "C_ISSUERCREDITAGENCY", "type": "STRING"}, {"name": "F_REGISTERCAPITAL", "type": "DOUBLE"}, {"name": "C_LAWNAME", "type": "STRING"}, {"name": "D_REGISTERDATE", "type": "STRING"}, {"name": "C_INDUSTRY", "type": "STRING"}, {"name": "C_REGISTERADDRESS", "type": "STRING"}, {"name": "C_ADDRESS", "type": "STRING"}, {"name": "C_TELPHONE", "type": "STRING"}, {"name": "C_EMAIL", "type": "STRING"}, {"name": "C_FAX", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tissuer_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tissuer_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tissuer_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tissuer_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TISSUER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TISSUER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tissuer_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TISSUER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_ISSUERCODE
     , C_ISSUERNAME
     , C_ISSUERTYPE
     , C_ISSUERLEVEL
     , C_ISSUERLEVELADD
     , C_ISSUERCREDITAGENCY
     , F_REGISTERCAPITAL
     , C_LAWNAME
     , D_REGISTERDATE
     , C_INDUSTRY
     , C_REGISTERADDRESS
     , C_ADDRESS
     , C_TELPHONE
     , C_EMAIL
     , C_FAX
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TISSUER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TISSUER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TISSUER_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TISSUER_PFD成功"
      exit 0
   fi
fi
