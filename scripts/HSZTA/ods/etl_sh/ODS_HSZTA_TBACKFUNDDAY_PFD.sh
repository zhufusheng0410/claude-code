#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TBACKFUNDDAY_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TBACKFUNDDAY_PFD_TMP(
  D_BEGINDATE  STRING  COMMENT  '起始日期',
  D_ENDDATE  STRING  COMMENT  '结束日期',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_TODAYSTATUS  STRING  COMMENT  '今日基金状态',
  C_RATIONFLAG  STRING  COMMENT  '是否对定期定额申购有效'
)
COMMENT '后收费基金的基金状态'
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
              "querySql": ["SELECT  D_BEGINDATE
                                   , D_ENDDATE
                                   , C_FUNDCODE
                                   , C_TODAYSTATUS
                                   , C_RATIONFLAG
                                FROM ${hszta_src_schema}.TBACKFUNDDAY"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_BEGINDATE", "type": "STRING"}, {"name": "D_ENDDATE", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_TODAYSTATUS", "type": "STRING"}, {"name": "C_RATIONFLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tbackfundday_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tbackfundday_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tbackfundday_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tbackfundday_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TBACKFUNDDAY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TBACKFUNDDAY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tbackfundday_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TBACKFUNDDAY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       D_BEGINDATE
     , D_ENDDATE
     , C_FUNDCODE
     , C_TODAYSTATUS
     , C_RATIONFLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TBACKFUNDDAY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TBACKFUNDDAY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TBACKFUNDDAY_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TBACKFUNDDAY_PFD成功"
      exit 0
   fi
fi
