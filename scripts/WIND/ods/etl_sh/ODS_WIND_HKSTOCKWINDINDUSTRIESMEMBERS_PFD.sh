#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  WIND_IND_CODE  STRING  COMMENT  'Wind行业代码',
  ENTRY_DT  STRING  COMMENT  '纳入日期',
  REMOVE_DT  STRING  COMMENT  '剔除日期',
  CUR_SIGN  DECIMAL(18,2)  COMMENT  '最新标志',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '香港股票万得行业成份'
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
                                   , WIND_IND_CODE
                                   , ENTRY_DT
                                   , REMOVE_DT
                                   , CUR_SIGN
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.HKSTOCKWINDINDUSTRIESMEMBERS"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "WIND_IND_CODE", "type": "STRING"}, {"name": "ENTRY_DT", "type": "STRING"}, {"name": "REMOVE_DT", "type": "STRING"}, {"name": "CUR_SIGN", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_hkstockwindindustriesmembers_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_hkstockwindindustriesmembers_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_hkstockwindindustriesmembers_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_hkstockwindindustriesmembers_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_hkstockwindindustriesmembers_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , WIND_IND_CODE
     , ENTRY_DT
     , REMOVE_DT
     , CUR_SIGN
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_HKSTOCKWINDINDUSTRIESMEMBERS_PFD成功"
      exit 0
   fi
fi
