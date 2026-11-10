#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TRATIOLOG_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TRATIOLOG_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_SERIAL_NO  DECIMAL(12,0)  COMMENT  '流水序号',
  L_TIME  DECIMAL(6,0)  COMMENT  '时间',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_VALUE  DECIMAL(24,8)  COMMENT  '实际值',
  EN_SETVALUE  DECIMAL(24,8)  COMMENT  '设置值',
  L_OPERATOR_NO  STRING  COMMENT  '操作员代码',
  L_INSTRUCTION_NO  DECIMAL(14,0)  COMMENT  '预置指令序号',
  L_INDEX_MODIFY_INSTRUCTION  DECIMAL(10,0)  COMMENT  '预置指令修改次序',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  L_ENTRUST_SERIAL_NO  DECIMAL(12,0)  COMMENT  '委托序号',
  VC_CONNECTION_ID  STRING  COMMENT  '数据库连接id＃',
  VC_COMPUTER_NAME  STRING  COMMENT  '登录机器名＃',
  VC_MAC  STRING  COMMENT  '网卡地址＃',
  VC_VOLSERIAL_NO  STRING  COMMENT  '硬盘vol序号＃',
  VC_SUMMARY  STRING  COMMENT  '风控说明',
  VC_REASON  STRING  COMMENT  '确认原因',
  L_RISK_SERIAL_NO  DECIMAL(10,0)  COMMENT  '风控序号',
  C_RISK_TYPE  STRING  COMMENT  '风控类型',
  C_WARN_LEVEL  STRING  COMMENT  '触警级别',
  C_WARN_OPERATION  STRING  COMMENT  '触警操作',
  VC_TRIGGER_REMARK  STRING  COMMENT  '触发说明',
  L_TEMP_NO  DECIMAL(10,0)  COMMENT  '临时序号',
  L_LAYER_ID  DECIMAL(12,0)  COMMENT  '*触发的层次序号',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  L_FACT_LAYER_ID  DECIMAL(12,0)  COMMENT  '*实际控制层次',
  L_STOCK_SERIAL_NO  DECIMAL(10,0)  COMMENT  '#指令证券号',
  L_DIMENSION_ID  STRING  COMMENT  '#维度编号',
  C_LOG_SOURCE  STRING  COMMENT  '#日志来源',
  L_CREATE_DATE  DECIMAL(8,0)  COMMENT  '创建日期',
  VC_ORDER_NO  STRING  COMMENT  '#外部指令号',
  L_ETRADE_SERIAL_NO  DECIMAL(12,0)  COMMENT  '',
  L_SECTION_NO  DECIMAL(12,0)  COMMENT  '',
  L_SETTLE_SPEED  DECIMAL(10,0)  COMMENT  '清算速度',
  VC_LOG_KEYS  STRING  COMMENT  '',
  VC_ACCTGRP_NAME  STRING  COMMENT  '',
  C_LAYER  STRING  COMMENT  '设置层次',
  VC_RISKWARN_APPROVE  STRING  COMMENT  '',
  L_INQUIRE_ID  DECIMAL(10,0)  COMMENT  '询价序号',
  L_MODIFY_INDEX  DECIMAL(10,0)  COMMENT  '修改次序',
  C_ORIGINAL_ENTRUST_DIRECTION  STRING  COMMENT  '',
  L_RATIOLOG_BATCH_NO  DECIMAL(27,0)  COMMENT  '',
  VC_DETAIL  STRING  COMMENT  ''
)
COMMENT '风控预警记录表'
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
                                   , L_TIME
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_SEAT_ID
                                   , VC_STOCKHOLDER_ID
                                   , VC_INTER_CODE
                                   , EN_VALUE
                                   , EN_SETVALUE
                                   , L_OPERATOR_NO
                                   , L_INSTRUCTION_NO
                                   , L_INDEX_MODIFY_INSTRUCTION
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INDEX_DAILY_MODIFY
                                   , L_ENTRUST_SERIAL_NO
                                   , VC_CONNECTION_ID
                                   , VC_COMPUTER_NAME
                                   , VC_MAC
                                   , VC_VOLSERIAL_NO
                                   , VC_SUMMARY
                                   , VC_REASON
                                   , L_RISK_SERIAL_NO
                                   , C_RISK_TYPE
                                   , C_WARN_LEVEL
                                   , C_WARN_OPERATION
                                   , VC_TRIGGER_REMARK
                                   , L_TEMP_NO
                                   , L_LAYER_ID
                                   , C_ENTRUST_DIRECTION
                                   , C_INVEST_TYPE
                                   , L_FACT_LAYER_ID
                                   , L_STOCK_SERIAL_NO
                                   , L_DIMENSION_ID
                                   , C_LOG_SOURCE
                                   , L_CREATE_DATE
                                   , VC_ORDER_NO
                                   , L_ETRADE_SERIAL_NO
                                   , L_SECTION_NO
                                   , L_SETTLE_SPEED
                                   , VC_LOG_KEYS
                                   , VC_ACCTGRP_NAME
                                   , C_LAYER
                                   , VC_RISKWARN_APPROVE
                                   , L_INQUIRE_ID
                                   , L_MODIFY_INDEX
                                   , C_ORIGINAL_ENTRUST_DIRECTION
                                   , L_RATIOLOG_BATCH_NO
                                   , VC_DETAIL
                                FROM ${o32_src_schema}.THISRATIOLOG
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_VALUE", "type": "DOUBLE"}, {"name": "EN_SETVALUE", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_MODIFY_INSTRUCTION", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_ENTRUST_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_CONNECTION_ID", "type": "STRING"}, {"name": "VC_COMPUTER_NAME", "type": "STRING"}, {"name": "VC_MAC", "type": "STRING"}, {"name": "VC_VOLSERIAL_NO", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "VC_REASON", "type": "STRING"}, {"name": "L_RISK_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_RISK_TYPE", "type": "STRING"}, {"name": "C_WARN_LEVEL", "type": "STRING"}, {"name": "C_WARN_OPERATION", "type": "STRING"}, {"name": "VC_TRIGGER_REMARK", "type": "STRING"}, {"name": "L_TEMP_NO", "type": "DOUBLE"}, {"name": "L_LAYER_ID", "type": "DOUBLE"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "L_FACT_LAYER_ID", "type": "DOUBLE"}, {"name": "L_STOCK_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_DIMENSION_ID", "type": "DOUBLE"}, {"name": "C_LOG_SOURCE", "type": "STRING"}, {"name": "L_CREATE_DATE", "type": "DOUBLE"}, {"name": "VC_ORDER_NO", "type": "STRING"}, {"name": "L_ETRADE_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_SECTION_NO", "type": "DOUBLE"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "VC_LOG_KEYS", "type": "STRING"}, {"name": "VC_ACCTGRP_NAME", "type": "STRING"}, {"name": "C_LAYER", "type": "STRING"}, {"name": "VC_RISKWARN_APPROVE", "type": "STRING"}, {"name": "L_INQUIRE_ID", "type": "DOUBLE"}, {"name": "L_MODIFY_INDEX", "type": "DOUBLE"}, {"name": "C_ORIGINAL_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "L_RATIOLOG_BATCH_NO", "type": "DOUBLE"}, {"name": "VC_DETAIL", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tratiolog_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tratiolog_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tratiolog_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tratiolog_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TRATIOLOG_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TRATIOLOG_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tratiolog_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TRATIOLOG_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_SERIAL_NO
     , L_TIME
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_SEAT_ID
     , VC_STOCKHOLDER_ID
     , VC_INTER_CODE
     , EN_VALUE
     , EN_SETVALUE
     , L_OPERATOR_NO
     , L_INSTRUCTION_NO
     , L_INDEX_MODIFY_INSTRUCTION
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , L_ENTRUST_SERIAL_NO
     , VC_CONNECTION_ID
     , VC_COMPUTER_NAME
     , VC_MAC
     , VC_VOLSERIAL_NO
     , VC_SUMMARY
     , VC_REASON
     , L_RISK_SERIAL_NO
     , C_RISK_TYPE
     , C_WARN_LEVEL
     , C_WARN_OPERATION
     , VC_TRIGGER_REMARK
     , L_TEMP_NO
     , L_LAYER_ID
     , C_ENTRUST_DIRECTION
     , C_INVEST_TYPE
     , L_FACT_LAYER_ID
     , L_STOCK_SERIAL_NO
     , L_DIMENSION_ID
     , C_LOG_SOURCE
     , L_CREATE_DATE
     , VC_ORDER_NO
     , L_ETRADE_SERIAL_NO
     , L_SECTION_NO
     , L_SETTLE_SPEED
     , VC_LOG_KEYS
     , VC_ACCTGRP_NAME
     , C_LAYER
     , VC_RISKWARN_APPROVE
     , L_INQUIRE_ID
     , L_MODIFY_INDEX
     , C_ORIGINAL_ENTRUST_DIRECTION
     , L_RATIOLOG_BATCH_NO
     , VC_DETAIL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TRATIOLOG_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TRATIOLOG_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TRATIOLOG_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TRATIOLOG_PTD成功"
      exit 0
   fi
fi
