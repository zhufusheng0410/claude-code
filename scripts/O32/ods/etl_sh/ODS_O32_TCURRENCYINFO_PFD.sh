#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TCURRENCYINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TCURRENCYINFO_PFD_TMP(
  VC_CURRENCY_NO  STRING  COMMENT  '币种代码',
  VC_CURRENCY_NAME  STRING  COMMENT  '币种名称',
  VC_CURRENCY_UNIT  STRING  COMMENT  '币种单位',
  VC_CURRENCY_SIGN  STRING  COMMENT  '符号',
  VC_CURRENCY_NO2  STRING  COMMENT  '币种代码2',
  C_EXCHANGE_FREE  STRING  COMMENT  '是否自由兑换',
  C_USE_FLAG  STRING  COMMENT  '启用标志',
  VC_DIRECT_TARGET_CURRENCY  STRING  COMMENT  '直接兑换的目标币种',
  L_PRECISION  DECIMAL(1,0)  COMMENT  '币种精度',
  C_ISMAIN_CURRENCY  STRING  COMMENT  '是否主币种',
  VC_MAIN_CURRENCY  STRING  COMMENT  '对应主币种',
  EN_EXCHANGE_UNIT  DECIMAL(16,8)  COMMENT  '换算单位'
)
COMMENT '币种信息表'
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
              "querySql": ["SELECT  VC_CURRENCY_NO
                                   , VC_CURRENCY_NAME
                                   , VC_CURRENCY_UNIT
                                   , VC_CURRENCY_SIGN
                                   , VC_CURRENCY_NO2
                                   , C_EXCHANGE_FREE
                                   , C_USE_FLAG
                                   , VC_DIRECT_TARGET_CURRENCY
                                   , L_PRECISION
                                   , C_ISMAIN_CURRENCY
                                   , VC_MAIN_CURRENCY
                                   , EN_EXCHANGE_UNIT
                                FROM ${o32_src_schema}.TCURRENCYINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "VC_CURRENCY_NAME", "type": "STRING"}, {"name": "VC_CURRENCY_UNIT", "type": "STRING"}, {"name": "VC_CURRENCY_SIGN", "type": "STRING"}, {"name": "VC_CURRENCY_NO2", "type": "STRING"}, {"name": "C_EXCHANGE_FREE", "type": "STRING"}, {"name": "C_USE_FLAG", "type": "STRING"}, {"name": "VC_DIRECT_TARGET_CURRENCY", "type": "STRING"}, {"name": "L_PRECISION", "type": "DOUBLE"}, {"name": "C_ISMAIN_CURRENCY", "type": "STRING"}, {"name": "VC_MAIN_CURRENCY", "type": "STRING"}, {"name": "EN_EXCHANGE_UNIT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tcurrencyinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tcurrencyinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tcurrencyinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tcurrencyinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TCURRENCYINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TCURRENCYINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tcurrencyinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TCURRENCYINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_CURRENCY_NO
     , VC_CURRENCY_NAME
     , VC_CURRENCY_UNIT
     , VC_CURRENCY_SIGN
     , VC_CURRENCY_NO2
     , C_EXCHANGE_FREE
     , C_USE_FLAG
     , VC_DIRECT_TARGET_CURRENCY
     , L_PRECISION
     , C_ISMAIN_CURRENCY
     , VC_MAIN_CURRENCY
     , EN_EXCHANGE_UNIT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TCURRENCYINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TCURRENCYINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TCURRENCYINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TCURRENCYINFO_PFD成功"
      exit 0
   fi
fi
