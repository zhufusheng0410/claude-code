#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TALGOORDER_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TALGOORDER_PTD_TMP(
  L_BATCH_SERIAL_NO  DECIMAL(10,0)  COMMENT  '批号',
  L_ALGO_SERIAL_NO  DECIMAL(10,0)  COMMENT  '母单序号',
  VC_CONFIRM_NO  STRING  COMMENT  '确认号',
  VC_REPORT_CODE  STRING  COMMENT  '证券代码',
  C_MARKET_NO  STRING  COMMENT  '交易市场',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_PRICE_TYPE  STRING  COMMENT  '价格类型',
  EN_ENTRUST_PRICE  DECIMAL(16,8)  COMMENT  '委托价格',
  L_AMOUNT  DECIMAL(10,0)  COMMENT  '数量',
  L_ENTRUST_AMOUNT  DECIMAL(10,0)  COMMENT  '已委托数量',
  C_STATUS  STRING  COMMENT  '状态',
  VC_REVOKE_CAUSE  STRING  COMMENT  '错误原因',
  D_ENTRUST_TIME  STRING  COMMENT  '委托时间',
  C_CANCEL_FLAG  STRING  COMMENT  '是否撤单',
  L_CANCEL_AMOUNT  DECIMAL(10,0)  COMMENT  '已撤数量',
  L_CANCEL_SERIAL_NO  DECIMAL(10,0)  COMMENT  '被撤号',
  L_OPERATOR_NO  DECIMAL(10,0)  COMMENT  '操作员',
  L_COMP_ID  DECIMAL(10,0)  COMMENT  '算法提供商',
  VC_STRATEGY_NAME  STRING  COMMENT  '策略名',
  C_NOTIFICATION_TYPE  STRING  COMMENT  '预警类型',
  C_NOTIFICATION_REASON  STRING  COMMENT  '预警原因',
  L_DEAL_AMOUNT  DECIMAL(10,0)  COMMENT  '已成交数量',
  C_ALGO_STATUS  STRING  COMMENT  '母单运行状态',
  VC_PARAMS1  STRING  COMMENT  '参数1值',
  VC_PARAMS2  STRING  COMMENT  '参数2值',
  L_ALGO_REAL_NO  DECIMAL(10,0)  COMMENT  '当前在算法服务器的母单号',
  L_FAIR_NO  DECIMAL(10,0)  COMMENT  '公平交易批号',
  L_BEGIN_TIME  DECIMAL(8,0)  COMMENT  '母单开始时间',
  L_END_TIME  DECIMAL(8,0)  COMMENT  '母单结束时间',
  L_DATE  DECIMAL(10,0)  COMMENT  '日期',
  C_FORCE_CANCEL  STRING  COMMENT  '是否强制撤单',
  C_STOCK_TARGET_TYPE  STRING  COMMENT  '证券控制方式',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '金额',
  EN_ENTRUST_BALANCE  DECIMAL(16,2)  COMMENT  '已委托金额',
  EN_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '已成交金额',
  EN_CANCEL_BALANCE  DECIMAL(16,2)  COMMENT  '已撤金额',
  C_BUSIN_CLASS  STRING  COMMENT  '业务类别',
  VC_THIRD_REFF  STRING  COMMENT  '',
  L_INVEST_ADVISER  DECIMAL(8,0)  COMMENT  '投资顾问',
  C_ENTRUST_ORIGIN  STRING  COMMENT  '',
  C_ALGO_BUSIN_CLASS  STRING  COMMENT  '',
  VC_IP_ADDRESS  STRING  COMMENT  'IP地址',
  VC_MAC  STRING  COMMENT  'MAC地址',
  VC_VOLSERIAL_NO  STRING  COMMENT  '',
  VC_ADVISER_STATION  STRING  COMMENT  '顾问站点',
  VC_TERMINALINFO_EXTEND  STRING  COMMENT  '',
  L_SCHEME_NO  DECIMAL(10,0)  COMMENT  '',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型'
)
COMMENT '母单委托表'
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
                                   , VC_CONFIRM_NO
                                   , VC_REPORT_CODE
                                   , C_MARKET_NO
                                   , C_ENTRUST_DIRECTION
                                   , C_PRICE_TYPE
                                   , EN_ENTRUST_PRICE
                                   , L_AMOUNT
                                   , L_ENTRUST_AMOUNT
                                   , C_STATUS
                                   , VC_REVOKE_CAUSE
                                   , D_ENTRUST_TIME
                                   , C_CANCEL_FLAG
                                   , L_CANCEL_AMOUNT
                                   , L_CANCEL_SERIAL_NO
                                   , L_OPERATOR_NO
                                   , L_COMP_ID
                                   , VC_STRATEGY_NAME
                                   , C_NOTIFICATION_TYPE
                                   , C_NOTIFICATION_REASON
                                   , L_DEAL_AMOUNT
                                   , C_ALGO_STATUS
                                   , VC_PARAMS1
                                   , VC_PARAMS2
                                   , L_ALGO_REAL_NO
                                   , L_FAIR_NO
                                   , L_BEGIN_TIME
                                   , L_END_TIME
                                   , L_DATE
                                   , C_FORCE_CANCEL
                                   , C_STOCK_TARGET_TYPE
                                   , EN_BALANCE
                                   , EN_ENTRUST_BALANCE
                                   , EN_DEAL_BALANCE
                                   , EN_CANCEL_BALANCE
                                   , C_BUSIN_CLASS
                                   , VC_THIRD_REFF
                                   , L_INVEST_ADVISER
                                   , C_ENTRUST_ORIGIN
                                   , C_ALGO_BUSIN_CLASS
                                   , VC_IP_ADDRESS
                                   , VC_MAC
                                   , VC_VOLSERIAL_NO
                                   , VC_ADVISER_STATION
                                   , VC_TERMINALINFO_EXTEND
                                   , L_SCHEME_NO
                                   , C_INVEST_TYPE
                                FROM ${o32_src_schema}.THISALGOORDER
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BATCH_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_ALGO_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_CONFIRM_NO", "type": "STRING"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_PRICE_TYPE", "type": "STRING"}, {"name": "EN_ENTRUST_PRICE", "type": "DOUBLE"}, {"name": "L_AMOUNT", "type": "DOUBLE"}, {"name": "L_ENTRUST_AMOUNT", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_REVOKE_CAUSE", "type": "STRING"}, {"name": "D_ENTRUST_TIME", "type": "STRING"}, {"name": "C_CANCEL_FLAG", "type": "STRING"}, {"name": "L_CANCEL_AMOUNT", "type": "DOUBLE"}, {"name": "L_CANCEL_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_COMP_ID", "type": "DOUBLE"}, {"name": "VC_STRATEGY_NAME", "type": "STRING"}, {"name": "C_NOTIFICATION_TYPE", "type": "STRING"}, {"name": "C_NOTIFICATION_REASON", "type": "STRING"}, {"name": "L_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "C_ALGO_STATUS", "type": "STRING"}, {"name": "VC_PARAMS1", "type": "STRING"}, {"name": "VC_PARAMS2", "type": "STRING"}, {"name": "L_ALGO_REAL_NO", "type": "DOUBLE"}, {"name": "L_FAIR_NO", "type": "DOUBLE"}, {"name": "L_BEGIN_TIME", "type": "DOUBLE"}, {"name": "L_END_TIME", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "C_FORCE_CANCEL", "type": "STRING"}, {"name": "C_STOCK_TARGET_TYPE", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_ENTRUST_BALANCE", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "EN_CANCEL_BALANCE", "type": "DOUBLE"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "VC_THIRD_REFF", "type": "STRING"}, {"name": "L_INVEST_ADVISER", "type": "DOUBLE"}, {"name": "C_ENTRUST_ORIGIN", "type": "STRING"}, {"name": "C_ALGO_BUSIN_CLASS", "type": "STRING"}, {"name": "VC_IP_ADDRESS", "type": "STRING"}, {"name": "VC_MAC", "type": "STRING"}, {"name": "VC_VOLSERIAL_NO", "type": "STRING"}, {"name": "VC_ADVISER_STATION", "type": "STRING"}, {"name": "VC_TERMINALINFO_EXTEND", "type": "STRING"}, {"name": "L_SCHEME_NO", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_talgoorder_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_talgoorder_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_talgoorder_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_talgoorder_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TALGOORDER_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TALGOORDER_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_talgoorder_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TALGOORDER_PTD PARTITION(P_DT)
SELECT
       L_BATCH_SERIAL_NO
     , L_ALGO_SERIAL_NO
     , VC_CONFIRM_NO
     , VC_REPORT_CODE
     , C_MARKET_NO
     , C_ENTRUST_DIRECTION
     , C_PRICE_TYPE
     , EN_ENTRUST_PRICE
     , L_AMOUNT
     , L_ENTRUST_AMOUNT
     , C_STATUS
     , VC_REVOKE_CAUSE
     , D_ENTRUST_TIME
     , C_CANCEL_FLAG
     , L_CANCEL_AMOUNT
     , L_CANCEL_SERIAL_NO
     , L_OPERATOR_NO
     , L_COMP_ID
     , VC_STRATEGY_NAME
     , C_NOTIFICATION_TYPE
     , C_NOTIFICATION_REASON
     , L_DEAL_AMOUNT
     , C_ALGO_STATUS
     , VC_PARAMS1
     , VC_PARAMS2
     , L_ALGO_REAL_NO
     , L_FAIR_NO
     , L_BEGIN_TIME
     , L_END_TIME
     , L_DATE
     , C_FORCE_CANCEL
     , C_STOCK_TARGET_TYPE
     , EN_BALANCE
     , EN_ENTRUST_BALANCE
     , EN_DEAL_BALANCE
     , EN_CANCEL_BALANCE
     , C_BUSIN_CLASS
     , VC_THIRD_REFF
     , L_INVEST_ADVISER
     , C_ENTRUST_ORIGIN
     , C_ALGO_BUSIN_CLASS
     , VC_IP_ADDRESS
     , VC_MAC
     , VC_VOLSERIAL_NO
     , VC_ADVISER_STATION
     , VC_TERMINALINFO_EXTEND
     , L_SCHEME_NO
     , C_INVEST_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TALGOORDER_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TALGOORDER_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TALGOORDER_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TALGOORDER_PTD成功"
      exit 0
   fi
fi
