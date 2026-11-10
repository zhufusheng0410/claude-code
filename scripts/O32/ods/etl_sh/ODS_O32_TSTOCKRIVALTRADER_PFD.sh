#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTOCKRIVALTRADER_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKRIVALTRADER_PFD_TMP(
  L_RIVAL_ID  DECIMAL(10,0)  COMMENT  '交易对手序号',
  VC_TRADER_NAME  STRING  COMMENT  '交易员姓名',
  VC_PHONE  STRING  COMMENT  '手机',
  VC_FAX  STRING  COMMENT  '传真',
  VC_EMAIL  STRING  COMMENT  '邮箱',
  VC_MSN  STRING  COMMENT  'msn',
  VC_ADDRESS  STRING  COMMENT  '地址',
  VC_POSTCODE  STRING  COMMENT  '邮政编码',
  VC_TRADER_ID  STRING  COMMENT  '交易员id',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '所属公司',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  C_MARKET_NO  STRING  COMMENT  '交易市场'
)
COMMENT '交易所交易对手交易员信息表'
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
              "querySql": ["SELECT  L_RIVAL_ID
                                   , VC_TRADER_NAME
                                   , VC_PHONE
                                   , VC_FAX
                                   , VC_EMAIL
                                   , VC_MSN
                                   , VC_ADDRESS
                                   , VC_POSTCODE
                                   , VC_TRADER_ID
                                   , L_ORG_ID
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , C_MARKET_NO
                                FROM ${o32_src_schema}.TSTOCKRIVALTRADER"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_RIVAL_ID", "type": "DOUBLE"}, {"name": "VC_TRADER_NAME", "type": "STRING"}, {"name": "VC_PHONE", "type": "STRING"}, {"name": "VC_FAX", "type": "STRING"}, {"name": "VC_EMAIL", "type": "STRING"}, {"name": "VC_MSN", "type": "STRING"}, {"name": "VC_ADDRESS", "type": "STRING"}, {"name": "VC_POSTCODE", "type": "STRING"}, {"name": "VC_TRADER_ID", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstockrivaltrader_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstockrivaltrader_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstockrivaltrader_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstockrivaltrader_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTOCKRIVALTRADER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTOCKRIVALTRADER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstockrivaltrader_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKRIVALTRADER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_RIVAL_ID
     , VC_TRADER_NAME
     , VC_PHONE
     , VC_FAX
     , VC_EMAIL
     , VC_MSN
     , VC_ADDRESS
     , VC_POSTCODE
     , VC_TRADER_ID
     , L_ORG_ID
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , C_MARKET_NO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSTOCKRIVALTRADER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKRIVALTRADER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTOCKRIVALTRADER_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTOCKRIVALTRADER_PFD成功"
      exit 0
   fi
fi
