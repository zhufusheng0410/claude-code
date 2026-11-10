#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TIFITRADESEAT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TIFITRADESEAT_PFD_TMP(
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '序号',
  C_MARKET_NO  STRING  COMMENT  '交易市场',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_FUND_CODE  STRING  COMMENT  '基金编号',
  VC_COMBI_NO  STRING  COMMENT  '组合编号',
  C_BIND_FLAG  STRING  COMMENT  '绑定标志',
  VC_REMARK  STRING  COMMENT  '备注',
  C_DEAL_FLAG  STRING  COMMENT  '状态标识',
  VC_FAIL_REASON  STRING  COMMENT  '失败原因'
)
COMMENT '席位关联表cdms'
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
                                   , VC_SEAT_ID
                                   , VC_FUND_CODE
                                   , VC_COMBI_NO
                                   , C_BIND_FLAG
                                   , VC_REMARK
                                   , C_DEAL_FLAG
                                   , VC_FAIL_REASON
                                FROM ${o32_src_schema}.TIFITRADESEAT"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_FUND_CODE", "type": "STRING"}, {"name": "VC_COMBI_NO", "type": "STRING"}, {"name": "C_BIND_FLAG", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "VC_FAIL_REASON", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tifitradeseat_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tifitradeseat_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tifitradeseat_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tifitradeseat_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TIFITRADESEAT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TIFITRADESEAT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tifitradeseat_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TIFITRADESEAT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_SERIAL_NO
     , C_MARKET_NO
     , VC_SEAT_ID
     , VC_FUND_CODE
     , VC_COMBI_NO
     , C_BIND_FLAG
     , VC_REMARK
     , C_DEAL_FLAG
     , VC_FAIL_REASON
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TIFITRADESEAT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TIFITRADESEAT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TIFITRADESEAT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TIFITRADESEAT_PFD成功"
      exit 0
   fi
fi
