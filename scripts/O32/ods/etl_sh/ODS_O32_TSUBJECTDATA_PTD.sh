#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSUBJECTDATA_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTDATA_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  C_LAYER  STRING  COMMENT  '科目层次',
  L_LAYER_ID  DECIMAL(10,0)  COMMENT  '层次序号',
  L_SUBJECT_NO  DECIMAL(10,0)  COMMENT  '系统科目',
  EN_SUBJECT_VALUE  DECIMAL(16,2)  COMMENT  '科目余额',
  EN_FROZEN_BALANCE  DECIMAL(16,2)  COMMENT  '冻结金额',
  EN_PROGRESSION_VALUE  DECIMAL(18,8)  COMMENT  '固定计提金额',
  C_FROZEN_POINT  STRING  COMMENT  '*自动冻结方式',
  C_FROZEN_DAY_TYPE  STRING  COMMENT  '冻结天数方式',
  L_FROZEN_DAYS  DECIMAL(10,0)  COMMENT  '冻结天数',
  L_FROZEN_START_DAYS  DECIMAL(10,0)  COMMENT  '冻结起始天数',
  EN_ESTIMATE_RATIO  DECIMAL(16,2)  COMMENT  '预估比例',
  C_FROZEN_FLAG  STRING  COMMENT  '冻结标志',
  L_FROZEN_EXPIRE_DATE  DECIMAL(8,0)  COMMENT  '冻结到期日期',
  C_FROZEN_TRADE_DAY  STRING  COMMENT  '冻结起始天数类型',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  L_DEFAULT_ASSET  DECIMAL(8,0)  COMMENT  '主账户缺省资产单元'
)
COMMENT '系统科目数据'
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
                                   , C_LAYER
                                   , L_LAYER_ID
                                   , L_SUBJECT_NO
                                   , EN_SUBJECT_VALUE
                                   , EN_FROZEN_BALANCE
                                   , EN_PROGRESSION_VALUE
                                   , C_FROZEN_POINT
                                   , C_FROZEN_DAY_TYPE
                                   , L_FROZEN_DAYS
                                   , L_FROZEN_START_DAYS
                                   , EN_ESTIMATE_RATIO
                                   , C_FROZEN_FLAG
                                   , L_FROZEN_EXPIRE_DATE
                                   , C_FROZEN_TRADE_DAY
                                   , VC_CURRENCY_NO
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , L_DEFAULT_ASSET
                                FROM ${o32_src_schema}.THISSUBJECTDATA
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "C_LAYER", "type": "STRING"}, {"name": "L_LAYER_ID", "type": "DOUBLE"}, {"name": "L_SUBJECT_NO", "type": "DOUBLE"}, {"name": "EN_SUBJECT_VALUE", "type": "DOUBLE"}, {"name": "EN_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_PROGRESSION_VALUE", "type": "DOUBLE"}, {"name": "C_FROZEN_POINT", "type": "STRING"}, {"name": "C_FROZEN_DAY_TYPE", "type": "STRING"}, {"name": "L_FROZEN_DAYS", "type": "DOUBLE"}, {"name": "L_FROZEN_START_DAYS", "type": "DOUBLE"}, {"name": "EN_ESTIMATE_RATIO", "type": "DOUBLE"}, {"name": "C_FROZEN_FLAG", "type": "STRING"}, {"name": "L_FROZEN_EXPIRE_DATE", "type": "DOUBLE"}, {"name": "C_FROZEN_TRADE_DAY", "type": "STRING"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "L_DEFAULT_ASSET", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tsubjectdata_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tsubjectdata_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tsubjectdata_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tsubjectdata_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSUBJECTDATA_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSUBJECTDATA_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tsubjectdata_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTDATA_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , C_LAYER
     , L_LAYER_ID
     , L_SUBJECT_NO
     , EN_SUBJECT_VALUE
     , EN_FROZEN_BALANCE
     , EN_PROGRESSION_VALUE
     , C_FROZEN_POINT
     , C_FROZEN_DAY_TYPE
     , L_FROZEN_DAYS
     , L_FROZEN_START_DAYS
     , EN_ESTIMATE_RATIO
     , C_FROZEN_FLAG
     , L_FROZEN_EXPIRE_DATE
     , C_FROZEN_TRADE_DAY
     , VC_CURRENCY_NO
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , L_DEFAULT_ASSET
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSUBJECTDATA_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTDATA_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSUBJECTDATA_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSUBJECTDATA_PTD成功"
      exit 0
   fi
fi
