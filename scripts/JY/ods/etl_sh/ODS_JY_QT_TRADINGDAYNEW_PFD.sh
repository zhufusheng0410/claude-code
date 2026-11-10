#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_QT_TRADINGDAYNEW_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_QT_TRADINGDAYNEW_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  TRADINGDATE  STRING  COMMENT  '日期',
  IFTRADINGDAY  DECIMAL(10,0)  COMMENT  '是否交易日',
  SECUMARKET  DECIMAL(10,0)  COMMENT  '证券市场',
  IFWEEKEND  DECIMAL(10,0)  COMMENT  '是否周末',
  IFMONTHEND  DECIMAL(10,0)  COMMENT  '是否月末',
  IFQUARTEREND  DECIMAL(10,0)  COMMENT  '是否季末',
  IFYEAREND  DECIMAL(10,0)  COMMENT  '是否年末',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '交易日表(新)'
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
                                   , TRADINGDATE
                                   , IFTRADINGDAY
                                   , SECUMARKET
                                   , IFWEEKEND
                                   , IFMONTHEND
                                   , IFQUARTEREND
                                   , IFYEAREND
                                   , XGRQ
                                   , JSID
                                FROM ${jy_src_schema}.QT_TRADINGDAYNEW"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "TRADINGDATE", "type": "STRING"}, {"name": "IFTRADINGDAY", "type": "DOUBLE"}, {"name": "SECUMARKET", "type": "DOUBLE"}, {"name": "IFWEEKEND", "type": "DOUBLE"}, {"name": "IFMONTHEND", "type": "DOUBLE"}, {"name": "IFQUARTEREND", "type": "DOUBLE"}, {"name": "IFYEAREND", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_qt_tradingdaynew_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_qt_tradingdaynew_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_qt_tradingdaynew_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_qt_tradingdaynew_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_QT_TRADINGDAYNEW_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_QT_TRADINGDAYNEW_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_qt_tradingdaynew_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_QT_TRADINGDAYNEW_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , TRADINGDATE
     , IFTRADINGDAY
     , SECUMARKET
     , IFWEEKEND
     , IFMONTHEND
     , IFQUARTEREND
     , IFYEAREND
     , XGRQ
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_QT_TRADINGDAYNEW_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_QT_TRADINGDAYNEW_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_QT_TRADINGDAYNEW_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_QT_TRADINGDAYNEW_PFD成功"
      exit 0
   fi
fi
