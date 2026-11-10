#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TIFISTOCKHODER_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TIFISTOCKHODER_PFD_TMP(
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '序号',
  C_MARKET_NO  STRING  COMMENT  '交易市场',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_STOCKHOLDER_NAME  STRING  COMMENT  '股东名称',
  L_OPEN_DATE  DECIMAL(8,0)  COMMENT  '开户日期',
  VC_BIND_SEAT  STRING  COMMENT  '指定席位',
  C_BIND_STATUS  STRING  COMMENT  '指定状态',
  C_STATUS  STRING  COMMENT  '股东状态',
  VC_REMARK  STRING  COMMENT  '备注',
  C_DEAL_FLAG  STRING  COMMENT  '状态标识',
  VC_FAIL_REASON  STRING  COMMENT  '失败原因',
  C_FUTURES_INVEST_TYPE  STRING  COMMENT  '估值期货投资类型'
)
COMMENT '股东代码表cdms'
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
              "querySql": ["SELECT  L_SERIAL_NO
                                   , C_MARKET_NO
                                   , VC_STOCKHOLDER_ID
                                   , VC_STOCKHOLDER_NAME
                                   , L_OPEN_DATE
                                   , VC_BIND_SEAT
                                   , C_BIND_STATUS
                                   , C_STATUS
                                   , VC_REMARK
                                   , C_DEAL_FLAG
                                   , VC_FAIL_REASON
                                   , C_FUTURES_INVEST_TYPE
                                FROM ${o32_src_schema}.TIFISTOCKHODER"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_STOCKHOLDER_NAME", "type": "STRING"}, {"name": "L_OPEN_DATE", "type": "DOUBLE"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "C_BIND_STATUS", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "VC_FAIL_REASON", "type": "STRING"}, {"name": "C_FUTURES_INVEST_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tifistockhoder_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tifistockhoder_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tifistockhoder_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tifistockhoder_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TIFISTOCKHODER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TIFISTOCKHODER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tifistockhoder_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TIFISTOCKHODER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_SERIAL_NO
     , C_MARKET_NO
     , VC_STOCKHOLDER_ID
     , VC_STOCKHOLDER_NAME
     , L_OPEN_DATE
     , VC_BIND_SEAT
     , C_BIND_STATUS
     , C_STATUS
     , VC_REMARK
     , C_DEAL_FLAG
     , VC_FAIL_REASON
     , C_FUTURES_INVEST_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TIFISTOCKHODER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TIFISTOCKHODER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TIFISTOCKHODER_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TIFISTOCKHODER_PFD成功"
      exit 0
   fi
fi
