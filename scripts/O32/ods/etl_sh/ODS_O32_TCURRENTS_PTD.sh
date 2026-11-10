#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TCURRENTS_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TCURRENTS_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_SERIAL_NO  DECIMAL(12,0)  COMMENT  '流水序号',
  L_OPERATOR_NO  STRING  COMMENT  '操作员代码',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  L_TIME  DECIMAL(6,0)  COMMENT  '发生时间',
  L_BUSIN_FLAG  STRING  COMMENT  '业务标志',
  VC_CONNECTION_ID  STRING  COMMENT  '数据库连接id',
  VC_COMPUTER_NAME  STRING  COMMENT  '登录机器名',
  VC_MAC  STRING  COMMENT  '网卡地址',
  VC_VOLSERIAL_NO  STRING  COMMENT  '硬盘vol序号',
  EN_OCCUR_BALANCE  DECIMAL(18,2)  COMMENT  '资金发生额',
  EN_POST_BALANCE  DECIMAL(18,2)  COMMENT  '发生后资金余额',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  EN_ENTRUST_PRICE  DECIMAL(16,8)  COMMENT  '成交价格',
  L_ENTRUST_AMOUNT  DECIMAL(20,4)  COMMENT  '*委托数量',
  L_BUSIN_AMOUNT  DECIMAL(20,4)  COMMENT  '*成交数量',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  EN_FARE1  DECIMAL(12,2)  COMMENT  '费用1',
  EN_FARE2  DECIMAL(12,2)  COMMENT  '费用2',
  EN_FARE3  DECIMAL(12,2)  COMMENT  '费用3',
  EN_FARE4  DECIMAL(12,2)  COMMENT  '费用4',
  EN_FARE5  DECIMAL(12,2)  COMMENT  '费用5',
  EN_FARE6  DECIMAL(12,2)  COMMENT  '费用6',
  EN_FARE7  DECIMAL(12,2)  COMMENT  '费用7',
  L_BUSIN_TIME1  DECIMAL(6,0)  COMMENT  '首成交时间',
  L_BUSIN_TIME2  DECIMAL(6,0)  COMMENT  '末成交时间',
  C_DELIVER_STATUS  STRING  COMMENT  '交割状态',
  VC_SUMMARY  STRING  COMMENT  '摘要',
  VC_BUSIN_OPFLAG  STRING  COMMENT  '业务操作类型',
  L_BUSIN_NO  DECIMAL(10,0)  COMMENT  '业务序号',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_REPEAT_SETTLE  STRING  COMMENT  '重复清算标志',
  EN_FEE_JS2  DECIMAL(12,2)  COMMENT  '结算费',
  EN_FEE_JG  DECIMAL(12,2)  COMMENT  '交割费',
  C_POSITION_FLAG  STRING  COMMENT  '持仓多空标志',
  EN_RISK_FUND  DECIMAL(12,2)  COMMENT  '结算风险基金',
  C_CLOSE_TYPE  STRING  COMMENT  '平仓类型',
  EN_DEAL_BALANCE  DECIMAL(18,2)  COMMENT  '成交金额',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  C_BUSIN_CLASS  STRING  COMMENT  '＃业务分类',
  L_SETTLE_SPEED  DECIMAL(10,0)  COMMENT  '清算速度',
  L_SUBJECT_NO  STRING  COMMENT  '＃相关科目编号',
  EN_SUBJECT_BALANCE  DECIMAL(18,2)  COMMENT  '＃科目发生额',
  C_STATUS  STRING  COMMENT  '状态',
  EN_SUBJECT_POST_BALANCE  DECIMAL(18,2)  COMMENT  '科目发生后余额',
  C_DEAL_TYPE  STRING  COMMENT  '处理类型',
  VC_EXPORT_FLAG  STRING  COMMENT  '导出标志',
  VC_EXTERNAL_NO  STRING  COMMENT  '外部编号',
  L_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  '复核人',
  L_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '交割日期',
  VC_BROKER_NO  STRING  COMMENT  '交易券商编号',
  L_TRADE_DATE  DECIMAL(8,0)  COMMENT  '交易日期',
  L_POST_AMOUNT  DECIMAL(20,4)  COMMENT  '发生后数量',
  T_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_BUSIN_NO2  DECIMAL(10,0)  COMMENT  '业务序号2',
  EN_FEE_JY_TRUE  DECIMAL(19,2)  COMMENT  '实际交易费',
  EN_FEE_YJ_TRUE  DECIMAL(19,2)  COMMENT  '实际佣金',
  EN_FEE_GH_TOTAL  DECIMAL(19,2)  COMMENT  '全额过户费',
  C_PRODUCE_MARK  STRING  COMMENT  '数据来源标志',
  EN_TAIL_BALANCE  DECIMAL(18,2)  COMMENT  '尾差',
  C_ADDITIONAL_FLAG  STRING  COMMENT  '',
  EN_TMP_BALANCE1  DECIMAL(18,2)  COMMENT  '',
  L_BONDLENDING_AMOUNT  DECIMAL(20,4)  COMMENT  '银行间债券卖空',
  L_BUYOUT_AMOUNT  DECIMAL(20,4)  COMMENT  '卖出数量',
  C_SOURCE_NO  STRING  COMMENT  '',
  EN_DEAL_BALANCE_GGT  DECIMAL(19,2)  COMMENT  '',
  EN_OCCUR_BALANCE_GGT  DECIMAL(19,2)  COMMENT  '',
  C_INTERCONNECTION_FLAG  STRING  COMMENT  ''
)
COMMENT '证券资金流水表'
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
                                   , L_OPERATOR_NO
                                   , L_FUND_ID
                                   , L_ASSET_ID
                                   , L_BASECOMBI_ID
                                   , L_TIME
                                   , L_BUSIN_FLAG
                                   , VC_CONNECTION_ID
                                   , VC_COMPUTER_NAME
                                   , VC_MAC
                                   , VC_VOLSERIAL_NO
                                   , EN_OCCUR_BALANCE
                                   , EN_POST_BALANCE
                                   , VC_STOCKHOLDER_ID
                                   , VC_SEAT_ID
                                   , VC_INTER_CODE
                                   , C_ENTRUST_DIRECTION
                                   , EN_ENTRUST_PRICE
                                   , L_ENTRUST_AMOUNT
                                   , L_BUSIN_AMOUNT
                                   , C_STOCK_TYPE
                                   , EN_FARE1
                                   , EN_FARE2
                                   , EN_FARE3
                                   , EN_FARE4
                                   , EN_FARE5
                                   , EN_FARE6
                                   , EN_FARE7
                                   , L_BUSIN_TIME1
                                   , L_BUSIN_TIME2
                                   , C_DELIVER_STATUS
                                   , VC_SUMMARY
                                   , VC_BUSIN_OPFLAG
                                   , L_BUSIN_NO
                                   , C_INVEST_TYPE
                                   , C_REPEAT_SETTLE
                                   , EN_FEE_JS2
                                   , EN_FEE_JG
                                   , C_POSITION_FLAG
                                   , EN_RISK_FUND
                                   , C_CLOSE_TYPE
                                   , EN_DEAL_BALANCE
                                   , VC_CURRENCY_NO
                                   , VC_DEAL_NO
                                   , C_BUSIN_CLASS
                                   , L_SETTLE_SPEED
                                   , L_SUBJECT_NO
                                   , EN_SUBJECT_BALANCE
                                   , C_STATUS
                                   , EN_SUBJECT_POST_BALANCE
                                   , C_DEAL_TYPE
                                   , VC_EXPORT_FLAG
                                   , VC_EXTERNAL_NO
                                   , L_CHECK_OPERATOR
                                   , L_SETTLE_DATE
                                   , VC_BROKER_NO
                                   , L_TRADE_DATE
                                   , L_POST_AMOUNT
                                   , T_TIMESTAMP
                                   , L_BUSIN_NO2
                                   , EN_FEE_JY_TRUE
                                   , EN_FEE_YJ_TRUE
                                   , EN_FEE_GH_TOTAL
                                   , C_PRODUCE_MARK
                                   , EN_TAIL_BALANCE
                                   , C_ADDITIONAL_FLAG
                                   , EN_TMP_BALANCE1
                                   , L_BONDLENDING_AMOUNT
                                   , L_BUYOUT_AMOUNT
                                   , C_SOURCE_NO
                                   , EN_DEAL_BALANCE_GGT
                                   , EN_OCCUR_BALANCE_GGT
                                   , C_INTERCONNECTION_FLAG
                                FROM ${o32_src_schema}.THISCURRENTS
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "L_BUSIN_FLAG", "type": "DOUBLE"}, {"name": "VC_CONNECTION_ID", "type": "STRING"}, {"name": "VC_COMPUTER_NAME", "type": "STRING"}, {"name": "VC_MAC", "type": "STRING"}, {"name": "VC_VOLSERIAL_NO", "type": "STRING"}, {"name": "EN_OCCUR_BALANCE", "type": "DOUBLE"}, {"name": "EN_POST_BALANCE", "type": "DOUBLE"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "EN_ENTRUST_PRICE", "type": "DOUBLE"}, {"name": "L_ENTRUST_AMOUNT", "type": "DOUBLE"}, {"name": "L_BUSIN_AMOUNT", "type": "DOUBLE"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "EN_FARE1", "type": "DOUBLE"}, {"name": "EN_FARE2", "type": "DOUBLE"}, {"name": "EN_FARE3", "type": "DOUBLE"}, {"name": "EN_FARE4", "type": "DOUBLE"}, {"name": "EN_FARE5", "type": "DOUBLE"}, {"name": "EN_FARE6", "type": "DOUBLE"}, {"name": "EN_FARE7", "type": "DOUBLE"}, {"name": "L_BUSIN_TIME1", "type": "DOUBLE"}, {"name": "L_BUSIN_TIME2", "type": "DOUBLE"}, {"name": "C_DELIVER_STATUS", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "VC_BUSIN_OPFLAG", "type": "STRING"}, {"name": "L_BUSIN_NO", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_REPEAT_SETTLE", "type": "STRING"}, {"name": "EN_FEE_JS2", "type": "DOUBLE"}, {"name": "EN_FEE_JG", "type": "DOUBLE"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "EN_RISK_FUND", "type": "DOUBLE"}, {"name": "C_CLOSE_TYPE", "type": "STRING"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "L_SUBJECT_NO", "type": "DOUBLE"}, {"name": "EN_SUBJECT_BALANCE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "EN_SUBJECT_POST_BALANCE", "type": "DOUBLE"}, {"name": "C_DEAL_TYPE", "type": "STRING"}, {"name": "VC_EXPORT_FLAG", "type": "STRING"}, {"name": "VC_EXTERNAL_NO", "type": "STRING"}, {"name": "L_CHECK_OPERATOR", "type": "DOUBLE"}, {"name": "L_SETTLE_DATE", "type": "DOUBLE"}, {"name": "VC_BROKER_NO", "type": "STRING"}, {"name": "L_TRADE_DATE", "type": "DOUBLE"}, {"name": "L_POST_AMOUNT", "type": "DOUBLE"}, {"name": "T_TIMESTAMP", "type": "STRING"}, {"name": "L_BUSIN_NO2", "type": "DOUBLE"}, {"name": "EN_FEE_JY_TRUE", "type": "DOUBLE"}, {"name": "EN_FEE_YJ_TRUE", "type": "DOUBLE"}, {"name": "EN_FEE_GH_TOTAL", "type": "DOUBLE"}, {"name": "C_PRODUCE_MARK", "type": "STRING"}, {"name": "EN_TAIL_BALANCE", "type": "DOUBLE"}, {"name": "C_ADDITIONAL_FLAG", "type": "STRING"}, {"name": "EN_TMP_BALANCE1", "type": "DOUBLE"}, {"name": "L_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "L_BUYOUT_AMOUNT", "type": "DOUBLE"}, {"name": "C_SOURCE_NO", "type": "STRING"}, {"name": "EN_DEAL_BALANCE_GGT", "type": "DOUBLE"}, {"name": "EN_OCCUR_BALANCE_GGT", "type": "DOUBLE"}, {"name": "C_INTERCONNECTION_FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tcurrents_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tcurrents_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tcurrents_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tcurrents_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TCURRENTS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TCURRENTS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tcurrents_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TCURRENTS_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_SERIAL_NO
     , L_OPERATOR_NO
     , L_FUND_ID
     , L_ASSET_ID
     , L_BASECOMBI_ID
     , L_TIME
     , L_BUSIN_FLAG
     , VC_CONNECTION_ID
     , VC_COMPUTER_NAME
     , VC_MAC
     , VC_VOLSERIAL_NO
     , EN_OCCUR_BALANCE
     , EN_POST_BALANCE
     , VC_STOCKHOLDER_ID
     , VC_SEAT_ID
     , VC_INTER_CODE
     , C_ENTRUST_DIRECTION
     , EN_ENTRUST_PRICE
     , L_ENTRUST_AMOUNT
     , L_BUSIN_AMOUNT
     , C_STOCK_TYPE
     , EN_FARE1
     , EN_FARE2
     , EN_FARE3
     , EN_FARE4
     , EN_FARE5
     , EN_FARE6
     , EN_FARE7
     , L_BUSIN_TIME1
     , L_BUSIN_TIME2
     , C_DELIVER_STATUS
     , VC_SUMMARY
     , VC_BUSIN_OPFLAG
     , L_BUSIN_NO
     , C_INVEST_TYPE
     , C_REPEAT_SETTLE
     , EN_FEE_JS2
     , EN_FEE_JG
     , C_POSITION_FLAG
     , EN_RISK_FUND
     , C_CLOSE_TYPE
     , EN_DEAL_BALANCE
     , VC_CURRENCY_NO
     , VC_DEAL_NO
     , C_BUSIN_CLASS
     , L_SETTLE_SPEED
     , L_SUBJECT_NO
     , EN_SUBJECT_BALANCE
     , C_STATUS
     , EN_SUBJECT_POST_BALANCE
     , C_DEAL_TYPE
     , VC_EXPORT_FLAG
     , VC_EXTERNAL_NO
     , L_CHECK_OPERATOR
     , L_SETTLE_DATE
     , VC_BROKER_NO
     , L_TRADE_DATE
     , L_POST_AMOUNT
     , T_TIMESTAMP
     , L_BUSIN_NO2
     , EN_FEE_JY_TRUE
     , EN_FEE_YJ_TRUE
     , EN_FEE_GH_TOTAL
     , C_PRODUCE_MARK
     , EN_TAIL_BALANCE
     , C_ADDITIONAL_FLAG
     , EN_TMP_BALANCE1
     , L_BONDLENDING_AMOUNT
     , L_BUYOUT_AMOUNT
     , C_SOURCE_NO
     , EN_DEAL_BALANCE_GGT
     , EN_OCCUR_BALANCE_GGT
     , C_INTERCONNECTION_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TCURRENTS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TCURRENTS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TCURRENTS_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TCURRENTS_PTD成功"
      exit 0
   fi
fi
