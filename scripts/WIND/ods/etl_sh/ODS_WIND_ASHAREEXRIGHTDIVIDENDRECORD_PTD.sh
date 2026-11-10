#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  EX_DATE  STRING  COMMENT  '除权除息日',
  EX_TYPE  STRING  COMMENT  '除权类型',
  EX_DESCRIPTION  STRING  COMMENT  '除权说明',
  CASH_DIVIDEND_RATIO  DECIMAL(18,2)  COMMENT  '派息比例',
  BONUS_SHARE_RATIO  DECIMAL(18,2)  COMMENT  '送股比例',
  RIGHTSISSUE_RATIO  DECIMAL(18,2)  COMMENT  '配股比例',
  RIGHTSISSUE_PRICE  DECIMAL(18,2)  COMMENT  '配股价格',
  CONVERSED_RATIO  DECIMAL(18,2)  COMMENT  '转增比例',
  SEO_PRICE  DECIMAL(18,2)  COMMENT  '增发价格',
  SEO_RATIO  DECIMAL(18,2)  COMMENT  '增发比例',
  CONSOLIDATE_SPLIT_RATIO  DECIMAL(18,2)  COMMENT  '缩减比例',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国A股除权除息记录'
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
                                   , EX_DATE
                                   , EX_TYPE
                                   , EX_DESCRIPTION
                                   , CASH_DIVIDEND_RATIO
                                   , BONUS_SHARE_RATIO
                                   , RIGHTSISSUE_RATIO
                                   , RIGHTSISSUE_PRICE
                                   , CONVERSED_RATIO
                                   , SEO_PRICE
                                   , SEO_RATIO
                                   , CONSOLIDATE_SPLIT_RATIO
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.ASHAREEXRIGHTDIVIDENDRECORD
                                WHERE EX_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "EX_DATE", "type": "STRING"}, {"name": "EX_TYPE", "type": "STRING"}, {"name": "EX_DESCRIPTION", "type": "STRING"}, {"name": "CASH_DIVIDEND_RATIO", "type": "DOUBLE"}, {"name": "BONUS_SHARE_RATIO", "type": "DOUBLE"}, {"name": "RIGHTSISSUE_RATIO", "type": "DOUBLE"}, {"name": "RIGHTSISSUE_PRICE", "type": "DOUBLE"}, {"name": "CONVERSED_RATIO", "type": "DOUBLE"}, {"name": "SEO_PRICE", "type": "DOUBLE"}, {"name": "SEO_RATIO", "type": "DOUBLE"}, {"name": "CONSOLIDATE_SPLIT_RATIO", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_ashareexrightdividendrecord_ptd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_ashareexrightdividendrecord_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_ashareexrightdividendrecord_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_ashareexrightdividendrecord_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_ashareexrightdividendrecord_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD PARTITION(P_DT)
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , EX_DATE
     , EX_TYPE
     , EX_DESCRIPTION
     , CASH_DIVIDEND_RATIO
     , BONUS_SHARE_RATIO
     , RIGHTSISSUE_RATIO
     , RIGHTSISSUE_PRICE
     , CONVERSED_RATIO
     , SEO_PRICE
     , SEO_RATIO
     , CONSOLIDATE_SPLIT_RATIO
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , EX_DATE P_DT
  FROM ODS_XDAY_WIND.ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD失败"
      exit 1
   else
      echo "插入到ODS_WIND_ASHAREEXRIGHTDIVIDENDRECORD_PTD成功"
      exit 0
   fi
fi
