#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTRADESTOCK_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTRADESTOCK_PFD_TMP(
  L_SERIAL_ID  DECIMAL(18,2)  COMMENT  '维度序号',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_STOCK_POWER  DECIMAL(9,8)  COMMENT  '证券权重',
  C_CONTAIN  STRING  COMMENT  '包含在下层中',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '操作员',
  L_ADD_DATE  DECIMAL(8,0)  COMMENT  '加入日期',
  L_ADD_TIME  DECIMAL(6,0)  COMMENT  '加入时间',
  VC_MEMO  STRING  COMMENT  '备注',
  L_NEAR_AMOUNT  DECIMAL(16,0)  COMMENT  '参考股本',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '有效开始日期',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '有效结束日期',
  L_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  '复核人',
  L_CREATE_DATE  DECIMAL(8,0)  COMMENT  '创建日期',
  L_CREATE_TIME  DECIMAL(6,0)  COMMENT  '创建时间'
)
COMMENT '维度证券表'
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
              "querySql": ["SELECT  L_SERIAL_ID
                                   , VC_INTER_CODE
                                   , EN_STOCK_POWER
                                   , C_CONTAIN
                                   , L_OPERATOR_NO
                                   , L_ADD_DATE
                                   , L_ADD_TIME
                                   , VC_MEMO
                                   , L_NEAR_AMOUNT
                                   , L_DATE
                                   , L_BEGIN_DATE
                                   , L_END_DATE
                                   , L_CHECK_OPERATOR
                                   , L_CREATE_DATE
                                   , L_CREATE_TIME
                                FROM ${o32_src_schema}.THISTRADESTOCK
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SERIAL_ID", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_STOCK_POWER", "type": "DOUBLE"}, {"name": "C_CONTAIN", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_ADD_DATE", "type": "DOUBLE"}, {"name": "L_ADD_TIME", "type": "DOUBLE"}, {"name": "VC_MEMO", "type": "STRING"}, {"name": "L_NEAR_AMOUNT", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_CHECK_OPERATOR", "type": "DOUBLE"}, {"name": "L_CREATE_DATE", "type": "DOUBLE"}, {"name": "L_CREATE_TIME", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_ttradestock_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_ttradestock_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_ttradestock_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_ttradestock_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTRADESTOCK_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTRADESTOCK_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_ttradestock_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTRADESTOCK_PFD PARTITION(P_DT)
SELECT
       L_SERIAL_ID
     , VC_INTER_CODE
     , EN_STOCK_POWER
     , C_CONTAIN
     , L_OPERATOR_NO
     , L_ADD_DATE
     , L_ADD_TIME
     , VC_MEMO
     , L_NEAR_AMOUNT
     , L_DATE
     , L_BEGIN_DATE
     , L_END_DATE
     , L_CHECK_OPERATOR
     , L_CREATE_DATE
     , L_CREATE_TIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TTRADESTOCK_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTRADESTOCK_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTRADESTOCK_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTRADESTOCK_PFD成功"
      exit 0
   fi
fi
