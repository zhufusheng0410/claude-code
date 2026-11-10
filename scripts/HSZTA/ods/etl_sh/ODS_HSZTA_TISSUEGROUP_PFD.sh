#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TISSUEGROUP_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TISSUEGROUP_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  F_QUOTA  DECIMAL(16,2)  COMMENT  '发行额度',
  C_ISSUEMODE  STRING  COMMENT  '发行方式',
  F_HAVEALLOT  DECIMAL(16,2)  COMMENT  '已认购额度',
  D_LASTDATE  STRING  COMMENT  '最后认购日期',
  F_LASTALLOT  DECIMAL(16,2)  COMMENT  '最后一天认购额度',
  F_ALLOTRATIO  DECIMAL(9,8)  COMMENT  '认购配售比例'
)
COMMENT '基金发行分组设置'
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
                                   , F_QUOTA
                                   , C_ISSUEMODE
                                   , F_HAVEALLOT
                                   , D_LASTDATE
                                   , F_LASTALLOT
                                   , F_ALLOTRATIO
                                FROM ${hszta_src_schema}.TISSUEGROUP"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "F_QUOTA", "type": "DOUBLE"}, {"name": "C_ISSUEMODE", "type": "STRING"}, {"name": "F_HAVEALLOT", "type": "DOUBLE"}, {"name": "D_LASTDATE", "type": "STRING"}, {"name": "F_LASTALLOT", "type": "DOUBLE"}, {"name": "F_ALLOTRATIO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tissuegroup_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tissuegroup_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tissuegroup_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tissuegroup_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TISSUEGROUP_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TISSUEGROUP_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tissuegroup_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TISSUEGROUP_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , F_QUOTA
     , C_ISSUEMODE
     , F_HAVEALLOT
     , D_LASTDATE
     , F_LASTALLOT
     , F_ALLOTRATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TISSUEGROUP_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TISSUEGROUP_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TISSUEGROUP_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TISSUEGROUP_PFD成功"
      exit 0
   fi
fi
