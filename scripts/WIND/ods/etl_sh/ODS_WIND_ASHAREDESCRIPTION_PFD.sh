#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_ASHAREDESCRIPTION_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREDESCRIPTION_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  S_INFO_CODE  STRING  COMMENT  '交易代码',
  S_INFO_NAME  STRING  COMMENT  '证券简称',
  S_INFO_COMPNAME  STRING  COMMENT  '公司中文名称',
  S_INFO_COMPNAMEENG  STRING  COMMENT  '公司英文名称',
  S_INFO_ISINCODE  STRING  COMMENT  'ISIN代码',
  S_INFO_EXCHMARKET  STRING  COMMENT  '交易所',
  S_INFO_LISTBOARD  STRING  COMMENT  '上市板类型',
  S_INFO_LISTDATE  STRING  COMMENT  '上市日期',
  S_INFO_DELISTDATE  STRING  COMMENT  '退市日期',
  S_INFO_SEDOLCODE  STRING  COMMENT  '废弃',
  CRNCY_CODE  STRING  COMMENT  '货币代码',
  S_INFO_PINYIN  STRING  COMMENT  '简称拼音',
  S_INFO_LISTBOARDNAME  STRING  COMMENT  '上市板',
  IS_SHSC  DECIMAL(18,2)  COMMENT  '是否在沪股通或深股通范围内',
  S_INFO_COMPCODE  STRING  COMMENT  '公司ID',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国A股基本资料'
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
                                   , S_INFO_CODE
                                   , S_INFO_NAME
                                   , S_INFO_COMPNAME
                                   , S_INFO_COMPNAMEENG
                                   , S_INFO_ISINCODE
                                   , S_INFO_EXCHMARKET
                                   , S_INFO_LISTBOARD
                                   , S_INFO_LISTDATE
                                   , S_INFO_DELISTDATE
                                   , S_INFO_SEDOLCODE
                                   , CRNCY_CODE
                                   , S_INFO_PINYIN
                                   , S_INFO_LISTBOARDNAME
                                   , IS_SHSC
                                   , S_INFO_COMPCODE
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.ASHAREDESCRIPTION"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "S_INFO_CODE", "type": "STRING"}, {"name": "S_INFO_NAME", "type": "STRING"}, {"name": "S_INFO_COMPNAME", "type": "STRING"}, {"name": "S_INFO_COMPNAMEENG", "type": "STRING"}, {"name": "S_INFO_ISINCODE", "type": "STRING"}, {"name": "S_INFO_EXCHMARKET", "type": "STRING"}, {"name": "S_INFO_LISTBOARD", "type": "STRING"}, {"name": "S_INFO_LISTDATE", "type": "STRING"}, {"name": "S_INFO_DELISTDATE", "type": "STRING"}, {"name": "S_INFO_SEDOLCODE", "type": "STRING"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "S_INFO_PINYIN", "type": "STRING"}, {"name": "S_INFO_LISTBOARDNAME", "type": "STRING"}, {"name": "IS_SHSC", "type": "DOUBLE"}, {"name": "S_INFO_COMPCODE", "type": "STRING"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_asharedescription_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_asharedescription_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_asharedescription_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_asharedescription_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_ASHAREDESCRIPTION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_ASHAREDESCRIPTION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_asharedescription_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREDESCRIPTION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , S_INFO_CODE
     , S_INFO_NAME
     , S_INFO_COMPNAME
     , S_INFO_COMPNAMEENG
     , S_INFO_ISINCODE
     , S_INFO_EXCHMARKET
     , S_INFO_LISTBOARD
     , S_INFO_LISTDATE
     , S_INFO_DELISTDATE
     , S_INFO_SEDOLCODE
     , CRNCY_CODE
     , S_INFO_PINYIN
     , S_INFO_LISTBOARDNAME
     , IS_SHSC
     , S_INFO_COMPCODE
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_ASHAREDESCRIPTION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREDESCRIPTION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_ASHAREDESCRIPTION_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_ASHAREDESCRIPTION_PFD成功"
      exit 0
   fi
fi
