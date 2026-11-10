#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFUNDSTOCKVALUE_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDSTOCKVALUE_PTD_TMP(
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_VALUE_PRICE  DECIMAL(16,8)  COMMENT  '估值价格',
  C_VALUE_TYPE  STRING  COMMENT  '估值类型',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_INVALID_DATE  DECIMAL(8,0)  COMMENT  '',
  VC_REMARKS  STRING  COMMENT  '备注',
  C_ADDITIONAL_MARK  STRING  COMMENT  ''
)
COMMENT '基金证券估值信息表'
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
              "querySql": ["SELECT  L_FUND_ID
                                   , VC_INTER_CODE
                                   , EN_VALUE_PRICE
                                   , C_VALUE_TYPE
                                   , L_DATE
                                   , L_INVALID_DATE
                                   , VC_REMARKS
                                   , C_ADDITIONAL_MARK
                                FROM ${o32_src_schema}.THISFUNDSTOCKVALUE
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_VALUE_PRICE", "type": "DOUBLE"}, {"name": "C_VALUE_TYPE", "type": "STRING"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_INVALID_DATE", "type": "DOUBLE"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "C_ADDITIONAL_MARK", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfundstockvalue_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfundstockvalue_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfundstockvalue_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfundstockvalue_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFUNDSTOCKVALUE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFUNDSTOCKVALUE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfundstockvalue_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFUNDSTOCKVALUE_PTD PARTITION(P_DT)
SELECT
       L_FUND_ID
     , VC_INTER_CODE
     , EN_VALUE_PRICE
     , C_VALUE_TYPE
     , L_DATE
     , L_INVALID_DATE
     , VC_REMARKS
     , C_ADDITIONAL_MARK
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TFUNDSTOCKVALUE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDSTOCKVALUE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFUNDSTOCKVALUE_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFUNDSTOCKVALUE_PTD成功"
      exit 0
   fi
fi
