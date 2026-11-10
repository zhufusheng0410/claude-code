#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TFUNDACCO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TFUNDACCO_PFD_TMP(
  VC_CUSTNO  STRING  COMMENT  '客户编号',
  VC_FUNDACCO  STRING  COMMENT  '基金账号',
  C_ACCOFLAG  STRING  COMMENT  '账户类型',
  C_OPENFLAG  STRING  COMMENT  '直销开户标识',
  VC_OPENDATE  STRING  COMMENT  '开户日期',
  VC_NETNO  STRING  COMMENT  '开户网点',
  C_STATE  STRING  COMMENT  '状态',
  VC_ORGANNO  STRING  COMMENT  '所属机构',
  VC_TACODE  STRING  COMMENT  'ta代码',
  C_AMLRISKTYPE  STRING  COMMENT  '',
  VC_AMLEXPLAIN  STRING  COMMENT  '',
  VC_PREFUNDACCO  STRING  COMMENT  '',
  C_SLEEPFLAG  STRING  COMMENT  '',
  VC_SLEEPFLAGMODDATE  STRING  COMMENT  '',
  C_ACTIVEFLAG  STRING  COMMENT  '',
  VC_ACTIVEFLAGDATE  STRING  COMMENT  '',
  C_TACUSTTYPE  STRING  COMMENT  ''
)
COMMENT '基金账号信息表'
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
              "querySql": ["SELECT  VC_CUSTNO\n                                   , VC_FUNDACCO\n                                   , C_ACCOFLAG\n                                   , C_OPENFLAG\n                                   , VC_OPENDATE\n                                   , VC_NETNO\n                                   , C_STATE\n                                   , VC_ORGANNO\n                                   , VC_TACODE\n                                   , C_AMLRISKTYPE\n                                   , VC_AMLEXPLAIN\n                                   , VC_PREFUNDACCO\n                                   , C_SLEEPFLAG\n                                   , VC_SLEEPFLAGMODDATE\n                                   , C_ACTIVEFLAG\n                                   , VC_ACTIVEFLAGDATE\n                                   , C_TACUSTTYPE\n                                FROM ${hsds_src_schema}.TFUNDACCO"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_CUSTNO", "type": "STRING"}, {"name": "VC_FUNDACCO", "type": "STRING"}, {"name": "C_ACCOFLAG", "type": "STRING"}, {"name": "C_OPENFLAG", "type": "STRING"}, {"name": "VC_OPENDATE", "type": "STRING"}, {"name": "VC_NETNO", "type": "STRING"}, {"name": "C_STATE", "type": "STRING"}, {"name": "VC_ORGANNO", "type": "STRING"}, {"name": "VC_TACODE", "type": "STRING"}, {"name": "C_AMLRISKTYPE", "type": "STRING"}, {"name": "VC_AMLEXPLAIN", "type": "STRING"}, {"name": "VC_PREFUNDACCO", "type": "STRING"}, {"name": "C_SLEEPFLAG", "type": "STRING"}, {"name": "VC_SLEEPFLAGMODDATE", "type": "STRING"}, {"name": "C_ACTIVEFLAG", "type": "STRING"}, {"name": "VC_ACTIVEFLAGDATE", "type": "STRING"}, {"name": "C_TACUSTTYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_tfundacco_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_tfundacco_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_tfundacco_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_tfundacco_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TFUNDACCO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TFUNDACCO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_tfundacco_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TFUNDACCO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_CUSTNO
     , VC_FUNDACCO
     , C_ACCOFLAG
     , C_OPENFLAG
     , VC_OPENDATE
     , VC_NETNO
     , C_STATE
     , VC_ORGANNO
     , VC_TACODE
     , C_AMLRISKTYPE
     , VC_AMLEXPLAIN
     , VC_PREFUNDACCO
     , C_SLEEPFLAG
     , VC_SLEEPFLAGMODDATE
     , C_ACTIVEFLAG
     , VC_ACTIVEFLAGDATE
     , C_TACUSTTYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TFUNDACCO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TFUNDACCO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TFUNDACCO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TFUNDACCO_PFD成功"
      exit 0
   fi
fi
