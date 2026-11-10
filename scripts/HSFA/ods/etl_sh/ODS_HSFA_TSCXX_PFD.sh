#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TSCXX_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSCXX_PFD_TMP(
  L_SCDM  STRING  COMMENT  '市场代码',
  VC_SCMC  STRING  COMMENT  '市场名称',
  VC_GJMC  STRING  COMMENT  '国家名称',
  VC_GJBM  STRING  COMMENT  '国家编码',
  C_DYJYRLX  STRING  COMMENT  '',
  VC_GJBZ  STRING  COMMENT  '',
  VC_MIC  STRING  COMMENT  '',
  L_JNJW  DECIMAL(1,0)  COMMENT  ''
)
COMMENT '市场类别表'
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
              "querySql": ["SELECT  L_SCDM
                                   , VC_SCMC
                                   , VC_GJMC
                                   , VC_GJBM
                                   , C_DYJYRLX
                                   , VC_GJBZ
                                   , VC_MIC
                                   , L_JNJW
                                FROM ${hsfa_src_schema}.TSCXX"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SCDM", "type": "DOUBLE"}, {"name": "VC_SCMC", "type": "STRING"}, {"name": "VC_GJMC", "type": "STRING"}, {"name": "VC_GJBM", "type": "STRING"}, {"name": "C_DYJYRLX", "type": "STRING"}, {"name": "VC_GJBZ", "type": "STRING"}, {"name": "VC_MIC", "type": "STRING"}, {"name": "L_JNJW", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tscxx_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tscxx_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tscxx_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tscxx_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TSCXX_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TSCXX_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tscxx_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSCXX_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_SCDM
     , VC_SCMC
     , VC_GJMC
     , VC_GJBM
     , C_DYJYRLX
     , VC_GJBZ
     , VC_MIC
     , L_JNJW
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TSCXX_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSCXX_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TSCXX_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TSCXX_PFD成功"
      exit 0
   fi
fi
