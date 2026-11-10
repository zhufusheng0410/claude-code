#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDNAV_PTD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDNAV_PTD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  F_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  ANN_DATE  STRING  COMMENT  '公告日期',
  PRICE_DATE  STRING  COMMENT  '截止日期',
  F_NAV_UNIT  DECIMAL(18,2)  COMMENT  '单位净值',
  F_NAV_ACCUMULATED  DECIMAL(18,2)  COMMENT  '累计净值',
  F_NAV_DIVACCUMULATED  DECIMAL(18,2)  COMMENT  '累计分红(废弃)',
  F_NAV_ADJFACTOR  DECIMAL(18,2)  COMMENT  '复权因子',
  CRNCY_CODE  STRING  COMMENT  '货币代码',
  F_PRT_NETASSET  DECIMAL(18,2)  COMMENT  '资产净值',
  F_ASSET_MERGEDSHARESORNOT  DECIMAL(18,2)  COMMENT  '是否合计数据',
  NETASSET_TOTAL  DECIMAL(18,2)  COMMENT  '合计资产净值',
  F_NAV_ADJUSTED  DECIMAL(18,2)  COMMENT  '复权单位净值',
  IS_EXDIVIDENDDATE  DECIMAL(18,2)  COMMENT  '是否净值除权日',
  F_NAV_DISTRIBUTION  DECIMAL(18,2)  COMMENT  '累计单位分配',
  S_INFO_ASHARECODE  STRING  COMMENT  '证券ID',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国共同基金净值'
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
                                   , F_INFO_WINDCODE
                                   , ANN_DATE
                                   , PRICE_DATE
                                   , F_NAV_UNIT
                                   , F_NAV_ACCUMULATED
                                   , F_NAV_DIVACCUMULATED
                                   , F_NAV_ADJFACTOR
                                   , CRNCY_CODE
                                   , F_PRT_NETASSET
                                   , F_ASSET_MERGEDSHARESORNOT
                                   , NETASSET_TOTAL
                                   , F_NAV_ADJUSTED
                                   , IS_EXDIVIDENDDATE
                                   , F_NAV_DISTRIBUTION
                                   , S_INFO_ASHARECODE
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.CHINAMUTUALFUNDNAV
                                WHERE ANN_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "F_INFO_WINDCODE", "type": "STRING"}, {"name": "ANN_DATE", "type": "STRING"}, {"name": "PRICE_DATE", "type": "STRING"}, {"name": "F_NAV_UNIT", "type": "DOUBLE"}, {"name": "F_NAV_ACCUMULATED", "type": "DOUBLE"}, {"name": "F_NAV_DIVACCUMULATED", "type": "DOUBLE"}, {"name": "F_NAV_ADJFACTOR", "type": "DOUBLE"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "F_PRT_NETASSET", "type": "DOUBLE"}, {"name": "F_ASSET_MERGEDSHARESORNOT", "type": "DOUBLE"}, {"name": "NETASSET_TOTAL", "type": "DOUBLE"}, {"name": "F_NAV_ADJUSTED", "type": "DOUBLE"}, {"name": "IS_EXDIVIDENDDATE", "type": "DOUBLE"}, {"name": "F_NAV_DISTRIBUTION", "type": "DOUBLE"}, {"name": "S_INFO_ASHARECODE", "type": "STRING"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_chinamutualfundnav_ptd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_chinamutualfundnav_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_chinamutualfundnav_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_chinamutualfundnav_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_CHINAMUTUALFUNDNAV_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_CHINAMUTUALFUNDNAV_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_chinamutualfundnav_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDNAV_PTD PARTITION(P_DT)
SELECT
       OBJECT_ID
     , F_INFO_WINDCODE
     , ANN_DATE
     , PRICE_DATE
     , F_NAV_UNIT
     , F_NAV_ACCUMULATED
     , F_NAV_DIVACCUMULATED
     , F_NAV_ADJFACTOR
     , CRNCY_CODE
     , F_PRT_NETASSET
     , F_ASSET_MERGEDSHARESORNOT
     , NETASSET_TOTAL
     , F_NAV_ADJUSTED
     , IS_EXDIVIDENDDATE
     , F_NAV_DISTRIBUTION
     , S_INFO_ASHARECODE
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , ANN_DATE P_DT
  FROM ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDNAV_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDNAV_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_CHINAMUTUALFUNDNAV_PTD失败"
      exit 1
   else
      echo "插入到ODS_WIND_CHINAMUTUALFUNDNAV_PTD成功"
      exit 0
   fi
fi
