#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_CMFINDEXDESCRIPTION_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_CMFINDEXDESCRIPTION_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  S_INFO_CODE  STRING  COMMENT  '交易代码',
  S_INFO_NAME  STRING  COMMENT  '证券简称',
  S_INFO_COMPNAME  STRING  COMMENT  '指数名称',
  S_INFO_EXCHMARKET  STRING  COMMENT  '交易所',
  S_INFO_PUBLISHER  STRING  COMMENT  '发布方',
  S_INFO_INDEX_BASEPER  STRING  COMMENT  '基期',
  S_INFO_INDEX_BASEPT  DECIMAL(18,2)  COMMENT  '基点',
  S_INFO_LISTDATE  STRING  COMMENT  '发布日期',
  S_INFO_INDEX_WEIGHTSRULE  STRING  COMMENT  '加权方式',
  S_INFO_INDEXSTYLE  STRING  COMMENT  '指数风格',
  INDEX_INTRO  STRING  COMMENT  '指数简介',
  EXPIRE_DATE  STRING  COMMENT  '终止发布日期',
  INCOME_PROCESSING_METHOD  STRING  COMMENT  '收益处理方式',
  S_INFO_INDEX_ENAME  STRING  COMMENT  '指数英文名称',
  WEIGHT_TYPE  STRING  COMMENT  '权重类型',
  COMPONENT_STOCKS_NUM  DECIMAL(18,2)  COMMENT  '成份股数量',
  INDEX_REGION_CODE  DECIMAL(18,2)  COMMENT  '指数区域代码',
  INDEX_CATEGORY_CODE  DECIMAL(18,2)  COMMENT  '指数类别代码',
  EXPONENTIAL_SCALE_CODE  DECIMAL(18,2)  COMMENT  '指数规模代码',
  WEIGHT_TYPE_CODE  DECIMAL(18,2)  COMMENT  '权重类型代码',
  MARKET_OWN_CODE  DECIMAL(18,2)  COMMENT  '所属市场代码',
  INCOME_PROCESSING_METHOD_CODE  DECIMAL(18,2)  COMMENT  '收益处理方式代码',
  INDEX_CATEGORY_TYPE  STRING  COMMENT  '指数类别',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国共同基金指数基本资料'
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
                                   , S_INFO_EXCHMARKET
                                   , S_INFO_PUBLISHER
                                   , S_INFO_INDEX_BASEPER
                                   , S_INFO_INDEX_BASEPT
                                   , S_INFO_LISTDATE
                                   , S_INFO_INDEX_WEIGHTSRULE
                                   , S_INFO_INDEXSTYLE
                                   , INDEX_INTRO
                                   , EXPIRE_DATE
                                   , INCOME_PROCESSING_METHOD
                                   , S_INFO_INDEX_ENAME
                                   , WEIGHT_TYPE
                                   , COMPONENT_STOCKS_NUM
                                   , INDEX_REGION_CODE
                                   , INDEX_CATEGORY_CODE
                                   , EXPONENTIAL_SCALE_CODE
                                   , WEIGHT_TYPE_CODE
                                   , MARKET_OWN_CODE
                                   , INCOME_PROCESSING_METHOD_CODE
                                   , INDEX_CATEGORY_TYPE
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.CMFINDEXDESCRIPTION"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "S_INFO_CODE", "type": "STRING"}, {"name": "S_INFO_NAME", "type": "STRING"}, {"name": "S_INFO_COMPNAME", "type": "STRING"}, {"name": "S_INFO_EXCHMARKET", "type": "STRING"}, {"name": "S_INFO_PUBLISHER", "type": "STRING"}, {"name": "S_INFO_INDEX_BASEPER", "type": "STRING"}, {"name": "S_INFO_INDEX_BASEPT", "type": "DOUBLE"}, {"name": "S_INFO_LISTDATE", "type": "STRING"}, {"name": "S_INFO_INDEX_WEIGHTSRULE", "type": "STRING"}, {"name": "S_INFO_INDEXSTYLE", "type": "STRING"}, {"name": "INDEX_INTRO", "type": "STRING"}, {"name": "EXPIRE_DATE", "type": "STRING"}, {"name": "INCOME_PROCESSING_METHOD", "type": "STRING"}, {"name": "S_INFO_INDEX_ENAME", "type": "STRING"}, {"name": "WEIGHT_TYPE", "type": "STRING"}, {"name": "COMPONENT_STOCKS_NUM", "type": "DOUBLE"}, {"name": "INDEX_REGION_CODE", "type": "DOUBLE"}, {"name": "INDEX_CATEGORY_CODE", "type": "DOUBLE"}, {"name": "EXPONENTIAL_SCALE_CODE", "type": "DOUBLE"}, {"name": "WEIGHT_TYPE_CODE", "type": "DOUBLE"}, {"name": "MARKET_OWN_CODE", "type": "DOUBLE"}, {"name": "INCOME_PROCESSING_METHOD_CODE", "type": "DOUBLE"}, {"name": "INDEX_CATEGORY_TYPE", "type": "STRING"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_cmfindexdescription_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_cmfindexdescription_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_cmfindexdescription_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_cmfindexdescription_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_CMFINDEXDESCRIPTION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_CMFINDEXDESCRIPTION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_cmfindexdescription_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_CMFINDEXDESCRIPTION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , S_INFO_CODE
     , S_INFO_NAME
     , S_INFO_COMPNAME
     , S_INFO_EXCHMARKET
     , S_INFO_PUBLISHER
     , S_INFO_INDEX_BASEPER
     , S_INFO_INDEX_BASEPT
     , S_INFO_LISTDATE
     , S_INFO_INDEX_WEIGHTSRULE
     , S_INFO_INDEXSTYLE
     , INDEX_INTRO
     , EXPIRE_DATE
     , INCOME_PROCESSING_METHOD
     , S_INFO_INDEX_ENAME
     , WEIGHT_TYPE
     , COMPONENT_STOCKS_NUM
     , INDEX_REGION_CODE
     , INDEX_CATEGORY_CODE
     , EXPONENTIAL_SCALE_CODE
     , WEIGHT_TYPE_CODE
     , MARKET_OWN_CODE
     , INCOME_PROCESSING_METHOD_CODE
     , INDEX_CATEGORY_TYPE
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_CMFINDEXDESCRIPTION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_CMFINDEXDESCRIPTION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_CMFINDEXDESCRIPTION_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_CMFINDEXDESCRIPTION_PFD成功"
      exit 0
   fi
fi
