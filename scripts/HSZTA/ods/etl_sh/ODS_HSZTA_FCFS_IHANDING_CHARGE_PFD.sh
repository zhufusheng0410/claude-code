#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD_TMP(
  FUND_ID  STRING  COMMENT  '',
  FUND_NAME  STRING  COMMENT  '',
  FUND_TYPE  STRING  COMMENT  '',
  FUND_SUB_TYPE  STRING  COMMENT  '',
  MOTHER_FUND_CODE  STRING  COMMENT  '',
  FEE_TYPE  STRING  COMMENT  '',
  SUMS  DECIMAL(38,8)  COMMENT  '',
  PAYABLE_DATE  STRING  COMMENT  '',
  CUSTOMER_TYPE  STRING  COMMENT  '',
  C_TRADEACCO  STRING  COMMENT  '',
  C_MOBILENO  STRING  COMMENT  '',
  C_ADDRESS  STRING  COMMENT  '',
  C_BANKACCO  STRING  COMMENT  '',
  C_BANKNAME  STRING  COMMENT  '',
  CUSTOMER_CODE  STRING  COMMENT  '',
  CUSTOMER_NAME  STRING  COMMENT  '',
  TA_CONFIRM_NO  STRING  COMMENT  '',
  SOURCE_SYSTEM  STRING  COMMENT  '',
  CREATE_BY  STRING  COMMENT  '',
  CREATE_DATE  STRING  COMMENT  '',
  UPDATE_BY  STRING  COMMENT  '',
  UPDATE_DATE  STRING  COMMENT  '',
  DATA_STATE  STRING  COMMENT  ''
)
COMMENT ''
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  FUND_ID
                                   , FUND_NAME
                                   , FUND_TYPE
                                   , FUND_SUB_TYPE
                                   , MOTHER_FUND_CODE
                                   , FEE_TYPE
                                   , SUMS
                                   , PAYABLE_DATE
                                   , CUSTOMER_TYPE
                                   , C_TRADEACCO
                                   , C_MOBILENO
                                   , C_ADDRESS
                                   , C_BANKACCO
                                   , C_BANKNAME
                                   , CUSTOMER_CODE
                                   , CUSTOMER_NAME
                                   , TA_CONFIRM_NO
                                   , SOURCE_SYSTEM
                                   , CREATE_BY
                                   , CREATE_DATE
                                   , UPDATE_BY
                                   , UPDATE_DATE
                                   , DATA_STATE
                                FROM ${hszta_src_schema}.FCFS_IHANDING_CHARGE"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "FUND_ID", "type": "STRING"}, {"name": "FUND_NAME", "type": "STRING"}, {"name": "FUND_TYPE", "type": "STRING"}, {"name": "FUND_SUB_TYPE", "type": "STRING"}, {"name": "MOTHER_FUND_CODE", "type": "STRING"}, {"name": "FEE_TYPE", "type": "STRING"}, {"name": "SUMS", "type": "DOUBLE"}, {"name": "PAYABLE_DATE", "type": "STRING"}, {"name": "CUSTOMER_TYPE", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_MOBILENO", "type": "STRING"}, {"name": "C_ADDRESS", "type": "STRING"}, {"name": "C_BANKACCO", "type": "STRING"}, {"name": "C_BANKNAME", "type": "STRING"}, {"name": "CUSTOMER_CODE", "type": "STRING"}, {"name": "CUSTOMER_NAME", "type": "STRING"}, {"name": "TA_CONFIRM_NO", "type": "STRING"}, {"name": "SOURCE_SYSTEM", "type": "STRING"}, {"name": "CREATE_BY", "type": "STRING"}, {"name": "CREATE_DATE", "type": "STRING"}, {"name": "UPDATE_BY", "type": "STRING"}, {"name": "UPDATE_DATE", "type": "STRING"}, {"name": "DATA_STATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_fcfs_ihanding_charge_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_fcfs_ihanding_charge_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_fcfs_ihanding_charge_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_fcfs_ihanding_charge_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_fcfs_ihanding_charge_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       FUND_ID
     , FUND_NAME
     , FUND_TYPE
     , FUND_SUB_TYPE
     , MOTHER_FUND_CODE
     , FEE_TYPE
     , SUMS
     , PAYABLE_DATE
     , CUSTOMER_TYPE
     , C_TRADEACCO
     , C_MOBILENO
     , C_ADDRESS
     , C_BANKACCO
     , C_BANKNAME
     , CUSTOMER_CODE
     , CUSTOMER_NAME
     , TA_CONFIRM_NO
     , SOURCE_SYSTEM
     , CREATE_BY
     , CREATE_DATE
     , UPDATE_BY
     , UPDATE_DATE
     , DATA_STATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_FCFS_IHANDING_CHARGE_PFD成功"
      exit 0
   fi
fi
