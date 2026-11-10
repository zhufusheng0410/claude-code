#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TCL_STRATEGYSCHEMA_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TCL_STRATEGYSCHEMA_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_SCHEMA_ID  DECIMAL(12,0)  COMMENT  '方案序号',
  VC_SCHEMA_NAME  STRING  COMMENT  '方案名称',
  L_STRATEGY_ID  DECIMAL(12,0)  COMMENT  '策略序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合',
  L_ADD_OPERATOR  DECIMAL(8,0)  COMMENT  '添加人',
  L_ADD_DATE  DECIMAL(8,0)  COMMENT  '添加日期',
  L_ADD_TIME  DECIMAL(6,0)  COMMENT  '添加时间',
  C_SCHEMA_STATUS  STRING  COMMENT  '方案状态',
  VC_RUNTIME_PERIOD  STRING  COMMENT  '运行时段',
  L_TEMPLATE_ID  STRING  COMMENT  '模板编号id'
)
COMMENT '策略方案表'
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
                                   , L_SCHEMA_ID
                                   , VC_SCHEMA_NAME
                                   , L_STRATEGY_ID
                                   , L_FUND_ID
                                   , L_ASSET_ID
                                   , L_BASECOMBI_ID
                                   , L_ADD_OPERATOR
                                   , L_ADD_DATE
                                   , L_ADD_TIME
                                   , C_SCHEMA_STATUS
                                   , VC_RUNTIME_PERIOD
                                   , L_TEMPLATE_ID
                                FROM ${o32_src_schema}.TCL_STRATEGYSCHEMA
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_SCHEMA_ID", "type": "DOUBLE"}, {"name": "VC_SCHEMA_NAME", "type": "STRING"}, {"name": "L_STRATEGY_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_ADD_OPERATOR", "type": "DOUBLE"}, {"name": "L_ADD_DATE", "type": "DOUBLE"}, {"name": "L_ADD_TIME", "type": "DOUBLE"}, {"name": "C_SCHEMA_STATUS", "type": "STRING"}, {"name": "VC_RUNTIME_PERIOD", "type": "STRING"}, {"name": "L_TEMPLATE_ID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tcl_strategyschema_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tcl_strategyschema_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tcl_strategyschema_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tcl_strategyschema_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TCL_STRATEGYSCHEMA_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TCL_STRATEGYSCHEMA_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tcl_strategyschema_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TCL_STRATEGYSCHEMA_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_SCHEMA_ID
     , VC_SCHEMA_NAME
     , L_STRATEGY_ID
     , L_FUND_ID
     , L_ASSET_ID
     , L_BASECOMBI_ID
     , L_ADD_OPERATOR
     , L_ADD_DATE
     , L_ADD_TIME
     , C_SCHEMA_STATUS
     , VC_RUNTIME_PERIOD
     , L_TEMPLATE_ID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TCL_STRATEGYSCHEMA_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TCL_STRATEGYSCHEMA_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TCL_STRATEGYSCHEMA_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TCL_STRATEGYSCHEMA_PTD成功"
      exit 0
   fi
fi
