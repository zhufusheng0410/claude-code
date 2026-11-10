#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTRADESTOCKLIST_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTRADESTOCKLIST_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_SERIAL_NO  DECIMAL(4,0)  COMMENT  '方案序号',
  L_DAILY_INSTRUCTION_NO  DECIMAL(8,0)  COMMENT  '当日指令序号',
  L_INSTRUCTION_NO  DECIMAL(14,0)  COMMENT  '指令序号',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_TARGET_TYPE  STRING  COMMENT  '目标类型',
  EN_TARGET_VALUE  DECIMAL(16,2)  COMMENT  '目标值',
  L_LAST_ENTRUST_TIME  DECIMAL(6,0)  COMMENT  '最后委托时间',
  L_MODIFY_TIME  DECIMAL(6,0)  COMMENT  '修改时间',
  C_PARAM_FLAG  STRING  COMMENT  '参数独立设置标志',
  C_EXCH_TYPE  STRING  COMMENT  '交易方式'
)
COMMENT '交易证券表'
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
                                   , L_SERIAL_NO
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INSTRUCTION_NO
                                   , C_MARKET_NO
                                   , VC_STOCKHOLDER_ID
                                   , VC_INTER_CODE
                                   , C_ENTRUST_DIRECTION
                                   , C_TARGET_TYPE
                                   , EN_TARGET_VALUE
                                   , L_LAST_ENTRUST_TIME
                                   , L_MODIFY_TIME
                                   , C_PARAM_FLAG
                                   , C_EXCH_TYPE
                                FROM ${o32_src_schema}.THISTRADESTOCKLIST
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_TARGET_TYPE", "type": "STRING"}, {"name": "EN_TARGET_VALUE", "type": "DOUBLE"}, {"name": "L_LAST_ENTRUST_TIME", "type": "DOUBLE"}, {"name": "L_MODIFY_TIME", "type": "DOUBLE"}, {"name": "C_PARAM_FLAG", "type": "STRING"}, {"name": "C_EXCH_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_ttradestocklist_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_ttradestocklist_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_ttradestocklist_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_ttradestocklist_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTRADESTOCKLIST_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTRADESTOCKLIST_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_ttradestocklist_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTRADESTOCKLIST_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_SERIAL_NO
     , L_DAILY_INSTRUCTION_NO
     , L_INSTRUCTION_NO
     , C_MARKET_NO
     , VC_STOCKHOLDER_ID
     , VC_INTER_CODE
     , C_ENTRUST_DIRECTION
     , C_TARGET_TYPE
     , EN_TARGET_VALUE
     , L_LAST_ENTRUST_TIME
     , L_MODIFY_TIME
     , C_PARAM_FLAG
     , C_EXCH_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TTRADESTOCKLIST_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTRADESTOCKLIST_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTRADESTOCKLIST_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTRADESTOCKLIST_PTD成功"
      exit 0
   fi
fi
