#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  TRADE_DT  STRING  COMMENT  '交易日期',
  CRNCY_CODE  STRING  COMMENT  '货币代码',
  S_DQ_PRECLOSE  DECIMAL(18,2)  COMMENT  '昨收盘价(点)',
  S_DQ_OPEN  DECIMAL(18,2)  COMMENT  '开盘价(点)',
  S_DQ_HIGH  DECIMAL(18,2)  COMMENT  '最高价(点)',
  S_DQ_LOW  DECIMAL(18,2)  COMMENT  '最低价(点)',
  S_DQ_CLOSE  DECIMAL(18,2)  COMMENT  '收盘价(点)',
  S_DQ_CHANGE  DECIMAL(18,2)  COMMENT  '涨跌(点)',
  S_DQ_PCTCHANGE  DECIMAL(18,2)  COMMENT  '涨跌幅(%)',
  S_DQ_VOLUME  DECIMAL(18,2)  COMMENT  '成交量(手)',
  S_DQ_AMOUNT  DECIMAL(18,2)  COMMENT  '成交金额(千元)',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国A股中信行业指数日行情'
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
            "username": "${wind_username}",
            "password": "${wind_password}",
            "connection": [{
              "querySql": ["SELECT  OBJECT_ID
                                   , S_INFO_WINDCODE
                                   , TRADE_DT
                                   , CRNCY_CODE
                                   , S_DQ_PRECLOSE
                                   , S_DQ_OPEN
                                   , S_DQ_HIGH
                                   , S_DQ_LOW
                                   , S_DQ_CLOSE
                                   , S_DQ_CHANGE
                                   , S_DQ_PCTCHANGE
                                   , S_DQ_VOLUME
                                   , S_DQ_AMOUNT
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.AINDEXINDUSTRIESEODCITICS
                                WHERE TRADE_DT between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "TRADE_DT", "type": "STRING"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "S_DQ_PRECLOSE", "type": "DOUBLE"}, {"name": "S_DQ_OPEN", "type": "DOUBLE"}, {"name": "S_DQ_HIGH", "type": "DOUBLE"}, {"name": "S_DQ_LOW", "type": "DOUBLE"}, {"name": "S_DQ_CLOSE", "type": "DOUBLE"}, {"name": "S_DQ_CHANGE", "type": "DOUBLE"}, {"name": "S_DQ_PCTCHANGE", "type": "DOUBLE"}, {"name": "S_DQ_VOLUME", "type": "DOUBLE"}, {"name": "S_DQ_AMOUNT", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_aindexindustrieseodcitics_ptd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_aindexindustrieseodcitics_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_aindexindustrieseodcitics_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_aindexindustrieseodcitics_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_aindexindustrieseodcitics_ptd_tmp.json

inceptor_beeline "
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD PARTITION(P_DT)
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , TRADE_DT
     , CRNCY_CODE
     , S_DQ_PRECLOSE
     , S_DQ_OPEN
     , S_DQ_HIGH
     , S_DQ_LOW
     , S_DQ_CLOSE
     , S_DQ_CHANGE
     , S_DQ_PCTCHANGE
     , S_DQ_VOLUME
     , S_DQ_AMOUNT
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , TRADE_DT P_DT
  FROM ODS_XDAY_WIND.ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD失败"
      exit 1
   else
      echo "插入到ODS_WIND_AINDEXINDUSTRIESEODCITICS_PTD成功"
      exit 0
   fi
fi
