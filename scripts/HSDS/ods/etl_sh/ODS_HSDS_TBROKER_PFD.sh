#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TBROKER_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TBROKER_PFD_TMP(
  VC_BROKER  STRING  COMMENT  '经纪人',
  VC_FATHERBROKER  STRING  COMMENT  '上级经纪人',
  VC_BROKERNAME  STRING  COMMENT  '经纪人名称',
  C_TYPE  STRING  COMMENT  '类别',
  VC_NETNO  STRING  COMMENT  '网点(备用)',
  VC_CENTERNO  STRING  COMMENT  '分中心（备用）',
  VC_PHONE  STRING  COMMENT  '联系电话',
  VC_QUALIFICATIONNO  STRING  COMMENT  '资质证明编号',
  C_QUALIFICATION  STRING  COMMENT  '销售资格标识',
  EN_ACHIEVESCALE  DECIMAL(3,2)  COMMENT  '',
  VC_COMEFROM  STRING  COMMENT  '',
  VC_OPERATORNO  STRING  COMMENT  '',
  VC_LASTDATE  STRING  COMMENT  '',
  C_CATEGORY  STRING  COMMENT  '',
  VC_IDENTIFICATION  STRING  COMMENT  '',
  C_WORKSTATE  STRING  COMMENT  '',
  VC_EMAIL  STRING  COMMENT  '',
  C_IGNOREAMLFLAG  STRING  COMMENT  '',
  VC_DEPARTMENTCODE  STRING  COMMENT  '',
  VC_CUSTNO  STRING  COMMENT  '',
  C_IDENTITYTYPE  STRING  COMMENT  '',
  VC_IDENTITYNO  STRING  COMMENT  '',
  VC_COMBCODE  STRING  COMMENT  ''
)
COMMENT '经纪人表'
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
              "querySql": ["SELECT  VC_BROKER\n                                   , VC_FATHERBROKER\n                                   , VC_BROKERNAME\n                                   , C_TYPE\n                                   , VC_NETNO\n                                   , VC_CENTERNO\n                                   , VC_PHONE\n                                   , VC_QUALIFICATIONNO\n                                   , C_QUALIFICATION\n                                   , EN_ACHIEVESCALE\n                                   , VC_COMEFROM\n                                   , VC_OPERATORNO\n                                   , VC_LASTDATE\n                                   , C_CATEGORY\n                                   , VC_IDENTIFICATION\n                                   , C_WORKSTATE\n                                   , VC_EMAIL\n                                   , C_IGNOREAMLFLAG\n                                   , VC_DEPARTMENTCODE\n                                   , VC_CUSTNO\n                                   , C_IDENTITYTYPE\n                                   , VC_IDENTITYNO\n                                   , VC_COMBCODE\n                                FROM ${hsds_src_schema}.TBROKER"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_BROKER", "type": "STRING"}, {"name": "VC_FATHERBROKER", "type": "STRING"}, {"name": "VC_BROKERNAME", "type": "STRING"}, {"name": "C_TYPE", "type": "STRING"}, {"name": "VC_NETNO", "type": "STRING"}, {"name": "VC_CENTERNO", "type": "STRING"}, {"name": "VC_PHONE", "type": "STRING"}, {"name": "VC_QUALIFICATIONNO", "type": "STRING"}, {"name": "C_QUALIFICATION", "type": "STRING"}, {"name": "EN_ACHIEVESCALE", "type": "DOUBLE"}, {"name": "VC_COMEFROM", "type": "STRING"}, {"name": "VC_OPERATORNO", "type": "STRING"}, {"name": "VC_LASTDATE", "type": "STRING"}, {"name": "C_CATEGORY", "type": "STRING"}, {"name": "VC_IDENTIFICATION", "type": "STRING"}, {"name": "C_WORKSTATE", "type": "STRING"}, {"name": "VC_EMAIL", "type": "STRING"}, {"name": "C_IGNOREAMLFLAG", "type": "STRING"}, {"name": "VC_DEPARTMENTCODE", "type": "STRING"}, {"name": "VC_CUSTNO", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "VC_IDENTITYNO", "type": "STRING"}, {"name": "VC_COMBCODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_tbroker_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_tbroker_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_tbroker_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_tbroker_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TBROKER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TBROKER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_tbroker_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TBROKER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_BROKER
     , VC_FATHERBROKER
     , VC_BROKERNAME
     , C_TYPE
     , VC_NETNO
     , VC_CENTERNO
     , VC_PHONE
     , VC_QUALIFICATIONNO
     , C_QUALIFICATION
     , EN_ACHIEVESCALE
     , VC_COMEFROM
     , VC_OPERATORNO
     , VC_LASTDATE
     , C_CATEGORY
     , VC_IDENTIFICATION
     , C_WORKSTATE
     , VC_EMAIL
     , C_IGNOREAMLFLAG
     , VC_DEPARTMENTCODE
     , VC_CUSTNO
     , C_IDENTITYTYPE
     , VC_IDENTITYNO
     , VC_COMBCODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TBROKER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TBROKER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TBROKER_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TBROKER_PFD成功"
      exit 0
   fi
fi
