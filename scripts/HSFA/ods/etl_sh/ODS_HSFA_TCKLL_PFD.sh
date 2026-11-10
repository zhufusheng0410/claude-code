#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TCKLL_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCKLL_PFD_TMP(
  L_ID  DECIMAL(10,0)  COMMENT  '',
  VC_KSRQ  STRING  COMMENT  '',
  VC_DQRQ  STRING  COMMENT  '',
  EN_LL  DECIMAL(10,6)  COMMENT  '',
  D_SCSJ  STRING  COMMENT  '',
  L_CZRY  DECIMAL(4,0)  COMMENT  '',
  VC_BZ  STRING  COMMENT  '',
  L_JXTS  DECIMAL(4,0)  COMMENT  '',
  L_YWLB  DECIMAL(4,0)  COMMENT  '',
  EN_FDSX  DECIMAL(19,4)  COMMENT  '',
  EN_FDXX  DECIMAL(19,4)  COMMENT  '',
  L_WSCL  DECIMAL(4,0)  COMMENT  ''
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_ID
                                   , VC_KSRQ
                                   , VC_DQRQ
                                   , EN_LL
                                   , D_SCSJ
                                   , L_CZRY
                                   , VC_BZ
                                   , L_JXTS
                                   , L_YWLB
                                   , EN_FDSX
                                   , EN_FDXX
                                   , L_WSCL
                                FROM ${hsfa_src_schema}.TCKLL"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "VC_KSRQ", "type": "STRING"}, {"name": "VC_DQRQ", "type": "STRING"}, {"name": "EN_LL", "type": "DOUBLE"}, {"name": "D_SCSJ", "type": "STRING"}, {"name": "L_CZRY", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "L_JXTS", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "EN_FDSX", "type": "DOUBLE"}, {"name": "EN_FDXX", "type": "DOUBLE"}, {"name": "L_WSCL", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tckll_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tckll_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tckll_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tckll_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TCKLL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TCKLL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tckll_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCKLL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ID
     , VC_KSRQ
     , VC_DQRQ
     , EN_LL
     , D_SCSJ
     , L_CZRY
     , VC_BZ
     , L_JXTS
     , L_YWLB
     , EN_FDSX
     , EN_FDXX
     , L_WSCL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TCKLL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCKLL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TCKLL_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TCKLL_PFD成功"
      exit 0
   fi
fi
