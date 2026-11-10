#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TALGOENTRUSTS_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TALGOENTRUSTS_PTD_TMP(
  L_BATCH_SERIAL_NO  DECIMAL(10,0)  COMMENT  '委托批号',
  L_ALGO_SERIAL_NO  DECIMAL(10,0)  COMMENT  '母单序号',
  VC_ALGO_ORDID  STRING  COMMENT  '确认号',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  VC_REPORT_CODE  STRING  COMMENT  '证券代码',
  C_MARKET_NO  STRING  COMMENT  '交易市场',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '修改号',
  L_FUND_ID  DECIMAL(10,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '投资组合序号',
  VC_MAIN_SEAT  STRING  COMMENT  '主席位',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_PRICE_TYPE  STRING  COMMENT  '价格类型',
  EN_ENTRUST_PRICE  DECIMAL(16,8)  COMMENT  '委托价格',
  L_AMOUNT  DECIMAL(10,0)  COMMENT  '数量',
  L_ENTRUST_AMOUNT  DECIMAL(10,0)  COMMENT  '已委托数量',
  VC_REVOKE_CAUSE  STRING  COMMENT  '错误原因',
  D_ENTRUST_TIME  STRING  COMMENT  '委托时间',
  L_DEAL_AMOUNT  DECIMAL(10,0)  COMMENT  '成交数量',
  EN_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '成交金额',
  L_OPERATOR_NO  DECIMAL(10,0)  COMMENT  '操作员',
  C_ENTRUST_EXECUTE_STATUS  STRING  COMMENT  '委托完成状态',
  C_DEAL_EXECTUE_STATUS  STRING  COMMENT  '成交完成状态',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  L_DISP_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '开始时的市场成交量',
  EN_DISP_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '开始时的市场成交金额',
  L_CPLT_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '完成时的市场成交量',
  EN_CPLT_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '完成时的市场成交金额',
  L_END_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '结束时的市场成交量',
  EN_END_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '结束时的市场成交金额',
  L_MARKET_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '市场成交量',
  EN_MARKET_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '市场成交金额',
  L_CPLT_VALID_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '母单完成时的市场有效成交量',
  EN_CPLT_VALID_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '母单完成时的市场有效成交金额',
  L_VALID_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '母单结束时的市场有效成交量',
  EN_VALID_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '母单结束时的市场有效成交金额',
  EN_LAST_PRICE  DECIMAL(16,8)  COMMENT  '当前的最新价',
  EN_DISP_LAST_PRICE  DECIMAL(16,8)  COMMENT  '母单开始时最新价',
  EN_CPLT_LAST_PRICE  DECIMAL(16,8)  COMMENT  '母单完成时最新价',
  EN_END_LAST_PRICE  DECIMAL(16,8)  COMMENT  '母单结束时最新价',
  D_DEAL_COMPLETE_DATE  STRING  COMMENT  '结束时间',
  L_FAIR_NO  DECIMAL(10,0)  COMMENT  '公平交易组号',
  L_DATE  DECIMAL(10,0)  COMMENT  '日期',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '金额',
  EN_ENTRUST_BALANCE  DECIMAL(16,2)  COMMENT  '已委托金额',
  EN_ORDER_AVG_PRICE  DECIMAL(16,8)  COMMENT  '母单成交均价',
  L_MESSAGE_ID  STRING  COMMENT  '信息编号',
  L_VIRTUAL_COMBI_ID  DECIMAL(12,0)  COMMENT  ''
)
COMMENT '母单分配表'
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
              "querySql": ["SELECT  L_BATCH_SERIAL_NO
                                   , L_ALGO_SERIAL_NO
                                   , VC_ALGO_ORDID
                                   , VC_INTER_CODE
                                   , VC_REPORT_CODE
                                   , C_MARKET_NO
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INDEX_DAILY_MODIFY
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_MAIN_SEAT
                                   , VC_STOCKHOLDER_ID
                                   , C_ENTRUST_DIRECTION
                                   , C_PRICE_TYPE
                                   , EN_ENTRUST_PRICE
                                   , L_AMOUNT
                                   , L_ENTRUST_AMOUNT
                                   , VC_REVOKE_CAUSE
                                   , D_ENTRUST_TIME
                                   , L_DEAL_AMOUNT
                                   , EN_DEAL_BALANCE
                                   , L_OPERATOR_NO
                                   , C_ENTRUST_EXECUTE_STATUS
                                   , C_DEAL_EXECTUE_STATUS
                                   , C_INVEST_TYPE
                                   , L_DISP_DEAL_AMOUNT
                                   , EN_DISP_DEAL_BALANCE
                                   , L_CPLT_DEAL_AMOUNT
                                   , EN_CPLT_DEAL_BALANCE
                                   , L_END_DEAL_AMOUNT
                                   , EN_END_DEAL_BALANCE
                                   , L_MARKET_DEAL_AMOUNT
                                   , EN_MARKET_DEAL_BALANCE
                                   , L_CPLT_VALID_DEAL_AMOUNT
                                   , EN_CPLT_VALID_DEAL_BALANCE
                                   , L_VALID_DEAL_AMOUNT
                                   , EN_VALID_DEAL_BALANCE
                                   , EN_LAST_PRICE
                                   , EN_DISP_LAST_PRICE
                                   , EN_CPLT_LAST_PRICE
                                   , EN_END_LAST_PRICE
                                   , D_DEAL_COMPLETE_DATE
                                   , L_FAIR_NO
                                   , L_DATE
                                   , EN_BALANCE
                                   , EN_ENTRUST_BALANCE
                                   , EN_ORDER_AVG_PRICE
                                   , L_MESSAGE_ID
                                   , L_VIRTUAL_COMBI_ID
                                FROM ${o32_src_schema}.THISALGOENTRUSTS
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BATCH_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_ALGO_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_ALGO_ORDID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_MAIN_SEAT", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_PRICE_TYPE", "type": "STRING"}, {"name": "EN_ENTRUST_PRICE", "type": "DOUBLE"}, {"name": "L_AMOUNT", "type": "DOUBLE"}, {"name": "L_ENTRUST_AMOUNT", "type": "DOUBLE"}, {"name": "VC_REVOKE_CAUSE", "type": "STRING"}, {"name": "D_ENTRUST_TIME", "type": "STRING"}, {"name": "L_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "C_ENTRUST_EXECUTE_STATUS", "type": "STRING"}, {"name": "C_DEAL_EXECTUE_STATUS", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "L_DISP_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DISP_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_CPLT_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_CPLT_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_END_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_END_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_MARKET_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_MARKET_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_CPLT_VALID_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_CPLT_VALID_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_VALID_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_VALID_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "EN_LAST_PRICE", "type": "DOUBLE"}, {"name": "EN_DISP_LAST_PRICE", "type": "DOUBLE"}, {"name": "EN_CPLT_LAST_PRICE", "type": "DOUBLE"}, {"name": "EN_END_LAST_PRICE", "type": "DOUBLE"}, {"name": "D_DEAL_COMPLETE_DATE", "type": "STRING"}, {"name": "L_FAIR_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_ENTRUST_BALANCE", "type": "DOUBLE"}, {"name": "EN_ORDER_AVG_PRICE", "type": "DOUBLE"}, {"name": "L_MESSAGE_ID", "type": "DOUBLE"}, {"name": "L_VIRTUAL_COMBI_ID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_talgoentrusts_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_talgoentrusts_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_talgoentrusts_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_talgoentrusts_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TALGOENTRUSTS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TALGOENTRUSTS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_talgoentrusts_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TALGOENTRUSTS_PTD PARTITION(P_DT)
SELECT
       L_BATCH_SERIAL_NO
     , L_ALGO_SERIAL_NO
     , VC_ALGO_ORDID
     , VC_INTER_CODE
     , VC_REPORT_CODE
     , C_MARKET_NO
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_MAIN_SEAT
     , VC_STOCKHOLDER_ID
     , C_ENTRUST_DIRECTION
     , C_PRICE_TYPE
     , EN_ENTRUST_PRICE
     , L_AMOUNT
     , L_ENTRUST_AMOUNT
     , VC_REVOKE_CAUSE
     , D_ENTRUST_TIME
     , L_DEAL_AMOUNT
     , EN_DEAL_BALANCE
     , L_OPERATOR_NO
     , C_ENTRUST_EXECUTE_STATUS
     , C_DEAL_EXECTUE_STATUS
     , C_INVEST_TYPE
     , L_DISP_DEAL_AMOUNT
     , EN_DISP_DEAL_BALANCE
     , L_CPLT_DEAL_AMOUNT
     , EN_CPLT_DEAL_BALANCE
     , L_END_DEAL_AMOUNT
     , EN_END_DEAL_BALANCE
     , L_MARKET_DEAL_AMOUNT
     , EN_MARKET_DEAL_BALANCE
     , L_CPLT_VALID_DEAL_AMOUNT
     , EN_CPLT_VALID_DEAL_BALANCE
     , L_VALID_DEAL_AMOUNT
     , EN_VALID_DEAL_BALANCE
     , EN_LAST_PRICE
     , EN_DISP_LAST_PRICE
     , EN_CPLT_LAST_PRICE
     , EN_END_LAST_PRICE
     , D_DEAL_COMPLETE_DATE
     , L_FAIR_NO
     , L_DATE
     , EN_BALANCE
     , EN_ENTRUST_BALANCE
     , EN_ORDER_AVG_PRICE
     , L_MESSAGE_ID
     , L_VIRTUAL_COMBI_ID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TALGOENTRUSTS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TALGOENTRUSTS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TALGOENTRUSTS_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TALGOENTRUSTS_PTD成功"
      exit 0
   fi
fi
