#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_SUSPENDRESUMPTION_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_SUSPENDRESUMPTION_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  DECIMAL(10,0)  COMMENT  '信息来源',
  SUSPENDDATE  STRING  COMMENT  '停牌日期',
  SUSPENDTIME  STRING  COMMENT  '停牌时间',
  SUSPENDREASON  STRING  COMMENT  '停牌原因',
  SUSPENDSTATEMENT  DECIMAL(10,0)  COMMENT  '停牌事项说明',
  SUSPENDTERM  STRING  COMMENT  '停牌期限',
  RESUMPTIONDATE  STRING  COMMENT  '复牌日期',
  RESUMPTIONTIME  STRING  COMMENT  '复牌时间',
  RESUMPTIONSTATEMENT  STRING  COMMENT  '复牌事项说明',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '停牌复牌表'
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
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , INNERCODE
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , SUSPENDDATE
                                   , SUSPENDTIME
                                   , SUSPENDREASON
                                   , SUSPENDSTATEMENT
                                   , SUSPENDTERM
                                   , RESUMPTIONDATE
                                   , RESUMPTIONTIME
                                   , RESUMPTIONSTATEMENT
                                   , UPDATETIME
                                   , JSID
                                   , INSERTTIME
                                FROM ${jy_src_schema}.LC_SUSPENDRESUMPTION"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "DOUBLE"}, {"name": "SUSPENDDATE", "type": "STRING"}, {"name": "SUSPENDTIME", "type": "STRING"}, {"name": "SUSPENDREASON", "type": "STRING"}, {"name": "SUSPENDSTATEMENT", "type": "DOUBLE"}, {"name": "SUSPENDTERM", "type": "STRING"}, {"name": "RESUMPTIONDATE", "type": "STRING"}, {"name": "RESUMPTIONTIME", "type": "STRING"}, {"name": "RESUMPTIONSTATEMENT", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_suspendresumption_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_suspendresumption_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_suspendresumption_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_suspendresumption_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_SUSPENDRESUMPTION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_SUSPENDRESUMPTION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_suspendresumption_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_SUSPENDRESUMPTION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , SUSPENDDATE
     , SUSPENDTIME
     , SUSPENDREASON
     , SUSPENDSTATEMENT
     , SUSPENDTERM
     , RESUMPTIONDATE
     , RESUMPTIONTIME
     , RESUMPTIONSTATEMENT
     , UPDATETIME
     , JSID
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_SUSPENDRESUMPTION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_SUSPENDRESUMPTION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_SUSPENDRESUMPTION_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_SUSPENDRESUMPTION_PFD成功"
      exit 0
   fi
fi
