#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TINSTRUCTIONMARKETINFO_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONMARKETINFO_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_OPERATOR_NO  STRING  COMMENT  '交易员代码',
  L_TIME  DECIMAL(6,0)  COMMENT  '市场时间',
  L_MARKET_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '当前市场成交数量',
  EN_MARKET_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '当前市场成交金额',
  L_VALID_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '指令结束时有效市场成交数量',
  EN_VALID_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '指令结束时有效市场成交金额',
  EN_LAST_PRICE  DECIMAL(16,8)  COMMENT  '当前最新价',
  L_CPLT_VALID_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '指令完成时有效市场成交数量',
  EN_CPLT_VALID_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '指令完成时有效市场成交金额',
  EN_DISP_LAST_PRICE  DECIMAL(16,8)  COMMENT  '指令分发时最新价',
  EN_CPLT_LAST_PRICE  DECIMAL(16,8)  COMMENT  '指令完成时最新价',
  EN_END_LAST_PRICE  DECIMAL(16,8)  COMMENT  '指令结束时最新价',
  L_DISP_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '指令分发时成交数量',
  EN_DISP_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '指令分发时成交金额',
  L_CPLT_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '指令完成时市场成交量',
  EN_CPLT_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '指令完成时市场成交金额',
  L_END_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '指令结束时市场成交量',
  EN_END_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '指令结束时市场成交金额',
  EN_INDEX_DISP_PRICE  DECIMAL(16,8)  COMMENT  'EN_INDEX_DISP_PRICE',
  EN_TIME_LAST_PRICE  DECIMAL(16,8)  COMMENT  '上笔成交价',
  L_TIME_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '成交数量节点',
  EN_TIME_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '成交金额节点',
  L_TIME_VALID_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '有效成交数量节点',
  EN_TIME_VALID_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '有效成交金额节点',
  EN_CPLT_CAL_PRICE_TOTAL  DECIMAL(16,8)  COMMENT  'EN_CPLT_CAL_PRICE_TOTAL',
  L_CPLT_CAL_TIME  DECIMAL(10,0)  COMMENT  'L_CPLT_CAL_TIME',
  EN_END_CAL_PRICE_TOTAL  DECIMAL(20,8)  COMMENT  'EN_END_CAL_PRICE_TOTAL',
  L_END_CAL_TIME  DECIMAL(10,0)  COMMENT  'L_END_CAL_TIME',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  L_FIRST_ENTRUST_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '',
  EN_FIRST_ENTRUST_DEAL_BALANCE  DECIMAL(19,3)  COMMENT  '',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型'
)
COMMENT '指令行情信息表'
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
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INDEX_DAILY_MODIFY
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_INTER_CODE
                                   , L_OPERATOR_NO
                                   , L_TIME
                                   , L_MARKET_DEAL_AMOUNT
                                   , EN_MARKET_DEAL_BALANCE
                                   , L_VALID_DEAL_AMOUNT
                                   , EN_VALID_DEAL_BALANCE
                                   , EN_LAST_PRICE
                                   , L_CPLT_VALID_DEAL_AMOUNT
                                   , EN_CPLT_VALID_DEAL_BALANCE
                                   , EN_DISP_LAST_PRICE
                                   , EN_CPLT_LAST_PRICE
                                   , EN_END_LAST_PRICE
                                   , L_DISP_DEAL_AMOUNT
                                   , EN_DISP_DEAL_BALANCE
                                   , L_CPLT_DEAL_AMOUNT
                                   , EN_CPLT_DEAL_BALANCE
                                   , L_END_DEAL_AMOUNT
                                   , EN_END_DEAL_BALANCE
                                   , EN_INDEX_DISP_PRICE
                                   , EN_TIME_LAST_PRICE
                                   , L_TIME_DEAL_AMOUNT
                                   , EN_TIME_DEAL_BALANCE
                                   , L_TIME_VALID_DEAL_AMOUNT
                                   , EN_TIME_VALID_DEAL_BALANCE
                                   , EN_CPLT_CAL_PRICE_TOTAL
                                   , L_CPLT_CAL_TIME
                                   , EN_END_CAL_PRICE_TOTAL
                                   , L_END_CAL_TIME
                                   , C_ENTRUST_DIRECTION
                                   , L_FIRST_ENTRUST_DEAL_AMOUNT
                                   , EN_FIRST_ENTRUST_DEAL_BALANCE
                                   , C_INVEST_TYPE
                                FROM ${o32_src_schema}.THISINSTRUCTIONMARKETINFO
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "L_MARKET_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_MARKET_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_VALID_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_VALID_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "EN_LAST_PRICE", "type": "DOUBLE"}, {"name": "L_CPLT_VALID_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_CPLT_VALID_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "EN_DISP_LAST_PRICE", "type": "DOUBLE"}, {"name": "EN_CPLT_LAST_PRICE", "type": "DOUBLE"}, {"name": "EN_END_LAST_PRICE", "type": "DOUBLE"}, {"name": "L_DISP_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DISP_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_CPLT_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_CPLT_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_END_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_END_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "EN_INDEX_DISP_PRICE", "type": "DOUBLE"}, {"name": "EN_TIME_LAST_PRICE", "type": "DOUBLE"}, {"name": "L_TIME_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_TIME_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_TIME_VALID_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_TIME_VALID_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "EN_CPLT_CAL_PRICE_TOTAL", "type": "DOUBLE"}, {"name": "L_CPLT_CAL_TIME", "type": "DOUBLE"}, {"name": "EN_END_CAL_PRICE_TOTAL", "type": "DOUBLE"}, {"name": "L_END_CAL_TIME", "type": "DOUBLE"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "L_FIRST_ENTRUST_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_FIRST_ENTRUST_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tinstructionmarketinfo_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tinstructionmarketinfo_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tinstructionmarketinfo_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tinstructionmarketinfo_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TINSTRUCTIONMARKETINFO_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TINSTRUCTIONMARKETINFO_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tinstructionmarketinfo_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONMARKETINFO_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_INTER_CODE
     , L_OPERATOR_NO
     , L_TIME
     , L_MARKET_DEAL_AMOUNT
     , EN_MARKET_DEAL_BALANCE
     , L_VALID_DEAL_AMOUNT
     , EN_VALID_DEAL_BALANCE
     , EN_LAST_PRICE
     , L_CPLT_VALID_DEAL_AMOUNT
     , EN_CPLT_VALID_DEAL_BALANCE
     , EN_DISP_LAST_PRICE
     , EN_CPLT_LAST_PRICE
     , EN_END_LAST_PRICE
     , L_DISP_DEAL_AMOUNT
     , EN_DISP_DEAL_BALANCE
     , L_CPLT_DEAL_AMOUNT
     , EN_CPLT_DEAL_BALANCE
     , L_END_DEAL_AMOUNT
     , EN_END_DEAL_BALANCE
     , EN_INDEX_DISP_PRICE
     , EN_TIME_LAST_PRICE
     , L_TIME_DEAL_AMOUNT
     , EN_TIME_DEAL_BALANCE
     , L_TIME_VALID_DEAL_AMOUNT
     , EN_TIME_VALID_DEAL_BALANCE
     , EN_CPLT_CAL_PRICE_TOTAL
     , L_CPLT_CAL_TIME
     , EN_END_CAL_PRICE_TOTAL
     , L_END_CAL_TIME
     , C_ENTRUST_DIRECTION
     , L_FIRST_ENTRUST_DEAL_AMOUNT
     , EN_FIRST_ENTRUST_DEAL_BALANCE
     , C_INVEST_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTIONMARKETINFO_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONMARKETINFO_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TINSTRUCTIONMARKETINFO_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TINSTRUCTIONMARKETINFO_PTD成功"
      exit 0
   fi
fi
