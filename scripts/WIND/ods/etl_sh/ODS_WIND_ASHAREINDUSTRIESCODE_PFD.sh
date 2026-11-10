#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_ASHAREINDUSTRIESCODE_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREINDUSTRIESCODE_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  INDUSTRIESCODE  STRING  COMMENT  '行业代码',
  INDUSTRIESNAME  STRING  COMMENT  '行业名称',
  LEVELNUM  DECIMAL(18,2)  COMMENT  '级数',
  USED  DECIMAL(18,2)  COMMENT  '是否有效',
  INDUSTRIESALIAS  STRING  COMMENT  '板块别名',
  SEQUENCE  DECIMAL(18,2)  COMMENT  '展示序号',
  MEMO  STRING  COMMENT  '备注',
  CHINESEDEFINITION  STRING  COMMENT  '板块中文定义',
  WIND_NAME_ENG  STRING  COMMENT  '板块英文名称',
  INDUSTRIESCODE_OLD  STRING  COMMENT  '行业代码(旧)',
  REGION_CODE  STRING  COMMENT  '行政区域代码',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '行业代码'
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
                                   , INDUSTRIESCODE
                                   , INDUSTRIESNAME
                                   , LEVELNUM
                                   , USED
                                   , INDUSTRIESALIAS
                                   , SEQUENCE
                                   , MEMO
                                   , CHINESEDEFINITION
                                   , WIND_NAME_ENG
                                   , INDUSTRIESCODE_OLD
                                   , REGION_CODE
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.ASHAREINDUSTRIESCODE"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "INDUSTRIESCODE", "type": "STRING"}, {"name": "INDUSTRIESNAME", "type": "STRING"}, {"name": "LEVELNUM", "type": "DOUBLE"}, {"name": "USED", "type": "DOUBLE"}, {"name": "INDUSTRIESALIAS", "type": "STRING"}, {"name": "SEQUENCE", "type": "DOUBLE"}, {"name": "MEMO", "type": "STRING"}, {"name": "CHINESEDEFINITION", "type": "STRING"}, {"name": "WIND_NAME_ENG", "type": "STRING"}, {"name": "INDUSTRIESCODE_OLD", "type": "STRING"}, {"name": "REGION_CODE", "type": "STRING"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_ashareindustriescode_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_ashareindustriescode_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_ashareindustriescode_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_ashareindustriescode_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_ASHAREINDUSTRIESCODE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_ASHAREINDUSTRIESCODE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_ashareindustriescode_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREINDUSTRIESCODE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , INDUSTRIESCODE
     , INDUSTRIESNAME
     , LEVELNUM
     , USED
     , INDUSTRIESALIAS
     , SEQUENCE
     , MEMO
     , CHINESEDEFINITION
     , WIND_NAME_ENG
     , INDUSTRIESCODE_OLD
     , REGION_CODE
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_ASHAREINDUSTRIESCODE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREINDUSTRIESCODE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_ASHAREINDUSTRIESCODE_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_ASHAREINDUSTRIESCODE_PFD成功"
      exit 0
   fi
fi
