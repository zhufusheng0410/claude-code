#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_CHINAGRADINGFUND_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAGRADINGFUND_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  '母基金Wind代码',
  F_INFO_FEEDER_WINDCODE  STRING  COMMENT  '子基金Wind代码',
  F_INFO_FEEDER_TYPECODE  DECIMAL(18,2)  COMMENT  '子基金类型代码',
  F_INFO_FEEDER_SHARERATIO  DECIMAL(18,2)  COMMENT  '子基金份额占比',
  F_INFO_TERM_TYPECODE  DECIMAL(18,2)  COMMENT  '存续期类型代码',
  F_INFO_PERIOD_IFDIV  DECIMAL(18,2)  COMMENT  '运作期内是否分红',
  F_INFO_TERM_IFTRANS  DECIMAL(18,2)  COMMENT  '存续期内是否有份额配对转换',
  F_INFO_TRANS_BGNDATE  STRING  COMMENT  '份额配对转换起始日期',
  F_INFO_TRANS_ENDDATE  STRING  COMMENT  '份额配对转换截止日期',
  F_INFO_PREFER_IFDIS  DECIMAL(18,2)  COMMENT  '优先份额是否参与超额收益分配',
  F_INFO_PREFER_IFADD  DECIMAL(18,2)  COMMENT  '优先份额约定收益是否得到累计',
  F_INFO_PREFER_FORMULA  STRING  COMMENT  '优先份额约定年收益表达式',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国分级基金'
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
                                   , F_INFO_FEEDER_WINDCODE
                                   , F_INFO_FEEDER_TYPECODE
                                   , F_INFO_FEEDER_SHARERATIO
                                   , F_INFO_TERM_TYPECODE
                                   , F_INFO_PERIOD_IFDIV
                                   , F_INFO_TERM_IFTRANS
                                   , F_INFO_TRANS_BGNDATE
                                   , F_INFO_TRANS_ENDDATE
                                   , F_INFO_PREFER_IFDIS
                                   , F_INFO_PREFER_IFADD
                                   , F_INFO_PREFER_FORMULA
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.CHINAGRADINGFUND"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "F_INFO_FEEDER_WINDCODE", "type": "STRING"}, {"name": "F_INFO_FEEDER_TYPECODE", "type": "DOUBLE"}, {"name": "F_INFO_FEEDER_SHARERATIO", "type": "DOUBLE"}, {"name": "F_INFO_TERM_TYPECODE", "type": "DOUBLE"}, {"name": "F_INFO_PERIOD_IFDIV", "type": "DOUBLE"}, {"name": "F_INFO_TERM_IFTRANS", "type": "DOUBLE"}, {"name": "F_INFO_TRANS_BGNDATE", "type": "STRING"}, {"name": "F_INFO_TRANS_ENDDATE", "type": "STRING"}, {"name": "F_INFO_PREFER_IFDIS", "type": "DOUBLE"}, {"name": "F_INFO_PREFER_IFADD", "type": "DOUBLE"}, {"name": "F_INFO_PREFER_FORMULA", "type": "STRING"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_chinagradingfund_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_chinagradingfund_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_chinagradingfund_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_chinagradingfund_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_CHINAGRADINGFUND_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_CHINAGRADINGFUND_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_chinagradingfund_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAGRADINGFUND_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , F_INFO_FEEDER_WINDCODE
     , F_INFO_FEEDER_TYPECODE
     , F_INFO_FEEDER_SHARERATIO
     , F_INFO_TERM_TYPECODE
     , F_INFO_PERIOD_IFDIV
     , F_INFO_TERM_IFTRANS
     , F_INFO_TRANS_BGNDATE
     , F_INFO_TRANS_ENDDATE
     , F_INFO_PREFER_IFDIS
     , F_INFO_PREFER_IFADD
     , F_INFO_PREFER_FORMULA
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_CHINAGRADINGFUND_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAGRADINGFUND_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_CHINAGRADINGFUND_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_CHINAGRADINGFUND_PFD成功"
      exit 0
   fi
fi
