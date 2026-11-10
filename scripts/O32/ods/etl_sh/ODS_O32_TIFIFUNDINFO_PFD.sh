#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TIFIFUNDINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TIFIFUNDINFO_PFD_TMP(
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '序号',
  VC_FUND_CODE  STRING  COMMENT  '基金编号',
  VC_FUND_NAME  STRING  COMMENT  '基金简称',
  VC_FULL_NAME  STRING  COMMENT  '基金全称',
  C_STATUS  STRING  COMMENT  '基金状态',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '成立日期',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '结束日期',
  VC_REMARK  STRING  COMMENT  '备注',
  C_DEAL_FLAG  STRING  COMMENT  '状态标识',
  VC_FAIL_REASON  STRING  COMMENT  '失败原因',
  C_TYPE_NO  STRING  COMMENT  '',
  VC_BANK_ACCOUNT  STRING  COMMENT  '中债登托管账号',
  VC_BANK_ACCOUNT_NAME  STRING  COMMENT  '中债登托管账号名称',
  L_FROZEN_DAYS  DECIMAL(10,0)  COMMENT  '冻结天数',
  VC_SHCLEARING_ACCOUNT  STRING  COMMENT  '上清所托管账号',
  VC_SHCLEARING_ACCOUNT_NAME  STRING  COMMENT  '上清所托管账号名称',
  C_INDEX_CHANGE_DATE  DECIMAL(8,0)  COMMENT  '',
  C_AGENT_TYPE  STRING  COMMENT  '代销模式',
  VC_DEFAULT_SALEORG  STRING  COMMENT  '默认销售机构',
  VC_CHECK_SALEORG  STRING  COMMENT  ''
)
COMMENT '基金账户表cdms'
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
                                   , VC_FUND_CODE
                                   , VC_FUND_NAME
                                   , VC_FULL_NAME
                                   , C_STATUS
                                   , L_BEGIN_DATE
                                   , L_END_DATE
                                   , VC_REMARK
                                   , C_DEAL_FLAG
                                   , VC_FAIL_REASON
                                   , C_TYPE_NO
                                   , VC_BANK_ACCOUNT
                                   , VC_BANK_ACCOUNT_NAME
                                   , L_FROZEN_DAYS
                                   , VC_SHCLEARING_ACCOUNT
                                   , VC_SHCLEARING_ACCOUNT_NAME
                                   , C_INDEX_CHANGE_DATE
                                   , C_AGENT_TYPE
                                   , VC_DEFAULT_SALEORG
                                   , VC_CHECK_SALEORG
                                FROM ${o32_src_schema}.TIFIFUNDINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_FUND_CODE", "type": "STRING"}, {"name": "VC_FUND_NAME", "type": "STRING"}, {"name": "VC_FULL_NAME", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "VC_FAIL_REASON", "type": "STRING"}, {"name": "C_TYPE_NO", "type": "STRING"}, {"name": "VC_BANK_ACCOUNT", "type": "STRING"}, {"name": "VC_BANK_ACCOUNT_NAME", "type": "STRING"}, {"name": "L_FROZEN_DAYS", "type": "DOUBLE"}, {"name": "VC_SHCLEARING_ACCOUNT", "type": "STRING"}, {"name": "VC_SHCLEARING_ACCOUNT_NAME", "type": "STRING"}, {"name": "C_INDEX_CHANGE_DATE", "type": "DOUBLE"}, {"name": "C_AGENT_TYPE", "type": "STRING"}, {"name": "VC_DEFAULT_SALEORG", "type": "STRING"}, {"name": "VC_CHECK_SALEORG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tififundinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tififundinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tififundinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tififundinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TIFIFUNDINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TIFIFUNDINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tififundinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TIFIFUNDINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_SERIAL_NO
     , VC_FUND_CODE
     , VC_FUND_NAME
     , VC_FULL_NAME
     , C_STATUS
     , L_BEGIN_DATE
     , L_END_DATE
     , VC_REMARK
     , C_DEAL_FLAG
     , VC_FAIL_REASON
     , C_TYPE_NO
     , VC_BANK_ACCOUNT
     , VC_BANK_ACCOUNT_NAME
     , L_FROZEN_DAYS
     , VC_SHCLEARING_ACCOUNT
     , VC_SHCLEARING_ACCOUNT_NAME
     , C_INDEX_CHANGE_DATE
     , C_AGENT_TYPE
     , VC_DEFAULT_SALEORG
     , VC_CHECK_SALEORG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TIFIFUNDINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TIFIFUNDINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TIFIFUNDINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TIFIFUNDINFO_PFD成功"
      exit 0
   fi
fi
