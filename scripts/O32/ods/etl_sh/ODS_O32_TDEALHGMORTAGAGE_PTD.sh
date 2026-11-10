#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TDEALHGMORTAGAGE_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TDEALHGMORTAGAGE_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '成交日期',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_MORTAGAGE_AMOUNT  DECIMAL(16,2)  COMMENT  '质押数量',
  EN_RATIO  DECIMAL(9,4)  COMMENT  '质押比例',
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '银行间成交流水序号',
  C_SPLIT_STATUS  STRING  COMMENT  '拆分状态',
  C_MORTAGAGE_SIDE  STRING  COMMENT  '#履约保证提交方',
  C_BAIL_TYPE  STRING  COMMENT  '#质押物类别',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '#资产单元',
  C_EFFECT_STATUS  STRING  COMMENT  '',
  L_OLD_MORTAGAGE_AMOUNT  DECIMAL(16,2)  COMMENT  ''
)
COMMENT '银行间成交回报回购质押表'
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
                                   , VC_DEAL_NO
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , C_INVEST_TYPE
                                   , VC_INTER_CODE
                                   , L_MORTAGAGE_AMOUNT
                                   , EN_RATIO
                                   , L_SERIAL_NO
                                   , C_SPLIT_STATUS
                                   , C_MORTAGAGE_SIDE
                                   , C_BAIL_TYPE
                                   , L_ASSET_ID
                                   , C_EFFECT_STATUS
                                   , L_OLD_MORTAGAGE_AMOUNT
                                FROM ${o32_src_schema}.TDEALHGMORTAGAGE
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_MORTAGAGE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_RATIO", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_SPLIT_STATUS", "type": "STRING"}, {"name": "C_MORTAGAGE_SIDE", "type": "STRING"}, {"name": "C_BAIL_TYPE", "type": "STRING"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "C_EFFECT_STATUS", "type": "STRING"}, {"name": "L_OLD_MORTAGAGE_AMOUNT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tdealhgmortagage_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tdealhgmortagage_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tdealhgmortagage_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tdealhgmortagage_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TDEALHGMORTAGAGE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TDEALHGMORTAGAGE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tdealhgmortagage_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TDEALHGMORTAGAGE_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_DEAL_NO
     , L_FUND_ID
     , L_BASECOMBI_ID
     , C_INVEST_TYPE
     , VC_INTER_CODE
     , L_MORTAGAGE_AMOUNT
     , EN_RATIO
     , L_SERIAL_NO
     , C_SPLIT_STATUS
     , C_MORTAGAGE_SIDE
     , C_BAIL_TYPE
     , L_ASSET_ID
     , C_EFFECT_STATUS
     , L_OLD_MORTAGAGE_AMOUNT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TDEALHGMORTAGAGE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TDEALHGMORTAGAGE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TDEALHGMORTAGAGE_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TDEALHGMORTAGAGE_PTD成功"
      exit 0
   fi
fi
