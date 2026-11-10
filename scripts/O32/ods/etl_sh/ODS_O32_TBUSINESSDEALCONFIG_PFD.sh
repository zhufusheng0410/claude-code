#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBUSINESSDEALCONFIG_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBUSINESSDEALCONFIG_PFD_TMP(
  C_MARKET_NO  STRING  COMMENT  '市场代码',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  L_DIMENSION_ID  DECIMAL(10,0)  COMMENT  '纬度id',
  C_CLEAR_SPEED  STRING  COMMENT  '清算速度',
  C_ASSET_SETTLE_POINT  STRING  COMMENT  '资产处理时点',
  C_CASH_CONTROL_TYPE  STRING  COMMENT  '头寸控制方式',
  C_STOCK_CONTROL_TYPE  STRING  COMMENT  '可用证券控制方式',
  C_CASH_ADD_TYPE  STRING  COMMENT  '头寸增加方式',
  C_STOCK_ADD_TYPE  STRING  COMMENT  '可用证券增加方式',
  C_ADD_POINT  STRING  COMMENT  '可用增加时点',
  C_MARKET_CASH_DIFF  STRING  COMMENT  '本市场头寸是否不同',
  C_MARKET_CASH_ADD_TYPE  STRING  COMMENT  '本市场头寸增加方式',
  VC_CONTAIN_MARKET  STRING  COMMENT  '本市场针对的市场代码',
  C_ASSET_SETTLE_DATE  STRING  COMMENT  '资产处理日期',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  C_ADD_POINT_BOUND  STRING  COMMENT  ''
)
COMMENT '业务处理配置表'
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
            "username": "${o32_username}",
            "password": "${o32_password}",
            "connection": [{
              "querySql": ["SELECT  C_MARKET_NO
                                   , C_STOCK_TYPE
                                   , C_ENTRUST_DIRECTION
                                   , L_DIMENSION_ID
                                   , C_CLEAR_SPEED
                                   , C_ASSET_SETTLE_POINT
                                   , C_CASH_CONTROL_TYPE
                                   , C_STOCK_CONTROL_TYPE
                                   , C_CASH_ADD_TYPE
                                   , C_STOCK_ADD_TYPE
                                   , C_ADD_POINT
                                   , C_MARKET_CASH_DIFF
                                   , C_MARKET_CASH_ADD_TYPE
                                   , VC_CONTAIN_MARKET
                                   , C_ASSET_SETTLE_DATE
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , C_ADD_POINT_BOUND
                                FROM ${o32_src_schema}.TBUSINESSDEALCONFIG"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_MARKET_NO", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "L_DIMENSION_ID", "type": "DOUBLE"}, {"name": "C_CLEAR_SPEED", "type": "STRING"}, {"name": "C_ASSET_SETTLE_POINT", "type": "STRING"}, {"name": "C_CASH_CONTROL_TYPE", "type": "STRING"}, {"name": "C_STOCK_CONTROL_TYPE", "type": "STRING"}, {"name": "C_CASH_ADD_TYPE", "type": "STRING"}, {"name": "C_STOCK_ADD_TYPE", "type": "STRING"}, {"name": "C_ADD_POINT", "type": "STRING"}, {"name": "C_MARKET_CASH_DIFF", "type": "STRING"}, {"name": "C_MARKET_CASH_ADD_TYPE", "type": "STRING"}, {"name": "VC_CONTAIN_MARKET", "type": "STRING"}, {"name": "C_ASSET_SETTLE_DATE", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "C_ADD_POINT_BOUND", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbusinessdealconfig_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbusinessdealconfig_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbusinessdealconfig_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbusinessdealconfig_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBUSINESSDEALCONFIG_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBUSINESSDEALCONFIG_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbusinessdealconfig_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBUSINESSDEALCONFIG_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_MARKET_NO
     , C_STOCK_TYPE
     , C_ENTRUST_DIRECTION
     , L_DIMENSION_ID
     , C_CLEAR_SPEED
     , C_ASSET_SETTLE_POINT
     , C_CASH_CONTROL_TYPE
     , C_STOCK_CONTROL_TYPE
     , C_CASH_ADD_TYPE
     , C_STOCK_ADD_TYPE
     , C_ADD_POINT
     , C_MARKET_CASH_DIFF
     , C_MARKET_CASH_ADD_TYPE
     , VC_CONTAIN_MARKET
     , C_ASSET_SETTLE_DATE
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , C_ADD_POINT_BOUND
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TBUSINESSDEALCONFIG_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBUSINESSDEALCONFIG_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBUSINESSDEALCONFIG_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBUSINESSDEALCONFIG_PFD成功"
      exit 0
   fi
fi
