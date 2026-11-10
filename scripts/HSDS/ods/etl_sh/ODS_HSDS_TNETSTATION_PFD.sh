#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TNETSTATION_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TNETSTATION_PFD_TMP(
  VC_NETNO  STRING  COMMENT  '网点号',
  VC_NETNAME  STRING  COMMENT  '网点名称',
  VC_CENTERNO  STRING  COMMENT  '所属分中心',
  VC_PROVINCE  STRING  COMMENT  '省',
  VC_CITYNO  STRING  COMMENT  '城市',
  VC_ZIP  STRING  COMMENT  '邮编',
  VC_ADDRESS  STRING  COMMENT  '通讯地址',
  VC_PHONE  STRING  COMMENT  '电话',
  VC_FAXNO  STRING  COMMENT  '传真',
  C_FLAG  STRING  COMMENT  '网点标识',
  C_STATE  STRING  COMMENT  '网点状态',
  VC_CONTACT  STRING  COMMENT  '联系人',
  VC_MANAGER  STRING  COMMENT  '负责人',
  VC_COMPANYREPORTMODE  STRING  COMMENT  '',
  VC_TRUST  STRING  COMMENT  '',
  C_PRIVATEFLAG  STRING  COMMENT  ''
)
COMMENT '网点'
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
            "username": "${hsds_username}",
            "password": "${hsds_password}",
            "connection": [{
              "querySql": ["SELECT  VC_NETNO\n                                   , VC_NETNAME\n                                   , VC_CENTERNO\n                                   , VC_PROVINCE\n                                   , VC_CITYNO\n                                   , VC_ZIP\n                                   , VC_ADDRESS\n                                   , VC_PHONE\n                                   , VC_FAXNO\n                                   , C_FLAG\n                                   , C_STATE\n                                   , VC_CONTACT\n                                   , VC_MANAGER\n                                   , VC_COMPANYREPORTMODE\n                                   , VC_TRUST\n                                   , C_PRIVATEFLAG\n                                FROM ${hsds_src_schema}.TNETSTATION"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_NETNO", "type": "STRING"}, {"name": "VC_NETNAME", "type": "STRING"}, {"name": "VC_CENTERNO", "type": "STRING"}, {"name": "VC_PROVINCE", "type": "STRING"}, {"name": "VC_CITYNO", "type": "STRING"}, {"name": "VC_ZIP", "type": "STRING"}, {"name": "VC_ADDRESS", "type": "STRING"}, {"name": "VC_PHONE", "type": "STRING"}, {"name": "VC_FAXNO", "type": "STRING"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "C_STATE", "type": "STRING"}, {"name": "VC_CONTACT", "type": "STRING"}, {"name": "VC_MANAGER", "type": "STRING"}, {"name": "VC_COMPANYREPORTMODE", "type": "STRING"}, {"name": "VC_TRUST", "type": "STRING"}, {"name": "C_PRIVATEFLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_tnetstation_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_tnetstation_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_tnetstation_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_tnetstation_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TNETSTATION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TNETSTATION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_tnetstation_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TNETSTATION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_NETNO
     , VC_NETNAME
     , VC_CENTERNO
     , VC_PROVINCE
     , VC_CITYNO
     , VC_ZIP
     , VC_ADDRESS
     , VC_PHONE
     , VC_FAXNO
     , C_FLAG
     , C_STATE
     , VC_CONTACT
     , VC_MANAGER
     , VC_COMPANYREPORTMODE
     , VC_TRUST
     , C_PRIVATEFLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TNETSTATION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TNETSTATION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TNETSTATION_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TNETSTATION_PFD成功"
      exit 0
   fi
fi
