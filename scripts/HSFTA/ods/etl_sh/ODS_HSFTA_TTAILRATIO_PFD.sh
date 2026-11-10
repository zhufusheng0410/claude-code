#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TTAILRATIO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TTAILRATIO_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_AGENCYNO  STRING  COMMENT  '销售商代码',
  F_SHAREMIN  DECIMAL(16,2)  COMMENT  '保有份额最小',
  F_SHAREMAX  DECIMAL(16,2)  COMMENT  '保有份额最大',
  F_RATIO  DECIMAL(9,8)  COMMENT  '尾随佣金比例',
  D_BEGINDATE  STRING  COMMENT  '启用日期',
  C_FLAG  STRING  COMMENT  '是否已经发起',
  C_UPDATEFLAG  STRING  COMMENT  '是否更新标志',
  F_FLOATRATIO  DECIMAL(9,8)  COMMENT  '动态基准浮动比例(%)',
  C_ENABLEEXTERNALRATIO  STRING  COMMENT  ''
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
                                   , D_BEGINDATE
                                   , C_FLAG
                                   , C_UPDATEFLAG
                                   , F_FLOATRATIO
                                   , C_ENABLEEXTERNALRATIO
                                FROM ${hsfta_src_schema}.TTAILRATIO"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "F_SHAREMIN", "type": "DOUBLE"}, {"name": "F_SHAREMAX", "type": "DOUBLE"}, {"name": "F_RATIO", "type": "DOUBLE"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "C_UPDATEFLAG", "type": "STRING"}, {"name": "F_FLOATRATIO", "type": "DOUBLE"}, {"name": "C_ENABLEEXTERNALRATIO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_ttailratio_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_ttailratio_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_ttailratio_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_ttailratio_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TTAILRATIO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TTAILRATIO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_ttailratio_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TTAILRATIO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_AGENCYNO
     , F_SHAREMIN
     , F_SHAREMAX
     , F_RATIO
     , D_BEGINDATE
     , C_FLAG
     , C_UPDATEFLAG
     , F_FLOATRATIO
     , C_ENABLEEXTERNALRATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TTAILRATIO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TTAILRATIO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TTAILRATIO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TTAILRATIO_PFD成功"
      exit 0
   fi
fi
