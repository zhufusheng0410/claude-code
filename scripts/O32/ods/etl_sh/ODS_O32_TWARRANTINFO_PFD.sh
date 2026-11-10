#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TWARRANTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TWARRANTINFO_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_EXECUTE_CODE  STRING  COMMENT  '行权代码',
  VC_WARRANT_CODE  STRING  COMMENT  '权证代码',
  VC_STOCK_CODE  STRING  COMMENT  '标的证券',
  C_WARRANT_TYPE  STRING  COMMENT  '权证类型',
  L_REMAIN_AMOUNT  DECIMAL(17,0)  COMMENT  '权证余额',
  C_STRIKE_TYPE  STRING  COMMENT  '结算方式',
  C_EXECUTE_TYPE  STRING  COMMENT  '行权方式',
  EN_STRIKE_PRICE  DECIMAL(16,8)  COMMENT  '结算价',
  EN_WARRANT_PRICE  DECIMAL(14,6)  COMMENT  '行权价格',
  EN_WARRANT_RATIO  DECIMAL(6,4)  COMMENT  '行权比例',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '*存续终止日期',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '*行权起始日期',
  C_STATUS  STRING  COMMENT  '状态',
  L_LAST_DATE  DECIMAL(8,0)  COMMENT  '最后交易日期'
)
COMMENT '权证信息表'
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
              "querySql": ["SELECT  L_DATE
                                   , C_MARKET_NO
                                   , VC_EXECUTE_CODE
                                   , VC_WARRANT_CODE
                                   , VC_STOCK_CODE
                                   , C_WARRANT_TYPE
                                   , L_REMAIN_AMOUNT
                                   , C_STRIKE_TYPE
                                   , C_EXECUTE_TYPE
                                   , EN_STRIKE_PRICE
                                   , EN_WARRANT_PRICE
                                   , EN_WARRANT_RATIO
                                   , L_END_DATE
                                   , L_BEGIN_DATE
                                   , C_STATUS
                                   , L_LAST_DATE
                                FROM ${o32_src_schema}.TWARRANTINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_EXECUTE_CODE", "type": "STRING"}, {"name": "VC_WARRANT_CODE", "type": "STRING"}, {"name": "VC_STOCK_CODE", "type": "STRING"}, {"name": "C_WARRANT_TYPE", "type": "STRING"}, {"name": "L_REMAIN_AMOUNT", "type": "DOUBLE"}, {"name": "C_STRIKE_TYPE", "type": "STRING"}, {"name": "C_EXECUTE_TYPE", "type": "STRING"}, {"name": "EN_STRIKE_PRICE", "type": "DOUBLE"}, {"name": "EN_WARRANT_PRICE", "type": "DOUBLE"}, {"name": "EN_WARRANT_RATIO", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_LAST_DATE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_twarrantinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_twarrantinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_twarrantinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_twarrantinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TWARRANTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TWARRANTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_twarrantinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TWARRANTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DATE
     , C_MARKET_NO
     , VC_EXECUTE_CODE
     , VC_WARRANT_CODE
     , VC_STOCK_CODE
     , C_WARRANT_TYPE
     , L_REMAIN_AMOUNT
     , C_STRIKE_TYPE
     , C_EXECUTE_TYPE
     , EN_STRIKE_PRICE
     , EN_WARRANT_PRICE
     , EN_WARRANT_RATIO
     , L_END_DATE
     , L_BEGIN_DATE
     , C_STATUS
     , L_LAST_DATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TWARRANTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TWARRANTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TWARRANTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TWARRANTINFO_PFD成功"
      exit 0
   fi
fi
