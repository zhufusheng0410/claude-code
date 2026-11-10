#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBANKENTRUST_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBANKENTRUST_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_ENTRUST_SERIAL_NO  DECIMAL(10,0)  COMMENT  '委托序号',
  C_QUOTE_TYPE  STRING  COMMENT  '报单类型',
  VC_BUSIN_CLASS  STRING  COMMENT  '市场标识',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '买卖方向',
  C_OP_TYPE  STRING  COMMENT  '操作类型',
  VC_QUOTE_ID  STRING  COMMENT  '报价单号',
  L_ORIGINAL_SERIAL_NO  DECIMAL(10,0)  COMMENT  '原委托序号',
  VC_ORIGINAL_QUOTE_ID  STRING  COMMENT  '原报价单号',
  C_ENTRUST_STATUS  STRING  COMMENT  '委托状态',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_FIRST_MATURE_YIELD  DECIMAL(15,8)  COMMENT  '首次到期收益率',
  EN_FIRST_STRIKE_YIELD  DECIMAL(15,8)  COMMENT  '首次行权收益率',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '券面总额',
  EN_FIRST_NET_PRICE  DECIMAL(16,8)  COMMENT  '首次净价',
  EN_MATURE_NET_PRICE  DECIMAL(16,8)  COMMENT  '到期净价',
  C_CLEAR_TYPE  STRING  COMMENT  '清算类型',
  L_SETTLE_SPEED  DECIMAL(10,0)  COMMENT  '清算速度',
  VC_TRADER_CODE  STRING  COMMENT  '本方交易员编号',
  VC_BANK_ACCOUNT  STRING  COMMENT  '本方资金账户',
  VC_RIVALTRADER_ID  STRING  COMMENT  '交易对手交易员编号',
  C_RATEISNULL  STRING  COMMENT  '报送方式',
  VC_QUOTE_TIME  STRING  COMMENT  '报价确认时间',
  VC_ORIGINAL_QUOTE_TIME  STRING  COMMENT  '原报价确认时间',
  EN_SECOND_MATURE_YIELD  DECIMAL(15,8)  COMMENT  '到期收益率',
  EN_RATE  DECIMAL(14,8)  COMMENT  '回购利率',
  EN_FIRST_SETTLE_INTEREST  DECIMAL(18,12)  COMMENT  '首次百元利息',
  EN_MATURE_SETTLE_INTEREST  DECIMAL(18,12)  COMMENT  '到期百元债券利息',
  EN_FIRST_CLEAR_BALANCE  DECIMAL(16,2)  COMMENT  '首次清算额',
  EN_SECOND_CLEAR_BALANCE  DECIMAL(16,2)  COMMENT  '到期清算额',
  L_FIRST_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '首次交割日',
  L_SECOND_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '到期交割日',
  C_FIRST_SETTLE_TYPE  STRING  COMMENT  '首次交割方式',
  C_SECOND_SETTLE_TYPE  STRING  COMMENT  '到期交割方式',
  L_TRADE_RIVAL_NO  DECIMAL(10,0)  COMMENT  '交易对手',
  VC_RIVALTRADER_NAME  STRING  COMMENT  '交易对手交易员名称',
  VC_BANK_ACCOUNT_NAME  STRING  COMMENT  '本方资金账户开户行',
  VC_TRADER_NAME  STRING  COMMENT  '本方交易员名称',
  L_BANK_ID  DECIMAL(10,0)  COMMENT  '银行间ID',
  EN_FIRST_NET_BALANCE  DECIMAL(16,2)  COMMENT  '交易金额',
  L_VALID_TIME  DECIMAL(6,0)  COMMENT  '有效时间',
  L_FUND_ID  DECIMAL(10,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合序号',
  L_TIME  DECIMAL(6,0)  COMMENT  '时间',
  VC_REMARK  STRING  COMMENT  '补充条款',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '操作员',
  EN_FIRST_NET_PRICE_RIV  DECIMAL(16,8)  COMMENT  '首次净价(本币)',
  EN_FIRST_MATURE_YIELD_RIV  DECIMAL(15,8)  COMMENT  '首次到期收益率(本币)',
  EN_FIRST_STRIKE_YIELD_RIV  DECIMAL(15,8)  COMMENT  '首次行权收益率(本币)',
  EN_ENTRUST_BALANCE  DECIMAL(16,2)  COMMENT  '委托完成金额',
  EN_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '成交完成金额',
  L_DEAL_AMOUNT  DECIMAL(16,2)  COMMENT  '成交完成数量',
  VC_TRADE_RIVAL_NOS  STRING  COMMENT  '请求机构',
  L_ENTRUST_AMOUNT  DECIMAL(16,2)  COMMENT  '委托完成数量',
  VC_QUOTEREQ_ID  STRING  COMMENT  '',
  C_SPLIT_INDICATOR  STRING  COMMENT  '拆分标识',
  L_MINTICKSIZE  DECIMAL(8,0)  COMMENT  '变动单位',
  L_REPORT_TIME  DECIMAL(6,0)  COMMENT  '委托下达时间',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  VC_REFUSE_RIVAL_NOS  STRING  COMMENT  '拒绝机构',
  VC_RFQACCOUNT_INFO  STRING  COMMENT  '请求分账信息',
  C_ENTRUST_ORIGIN  STRING  COMMENT  '委托来源',
  L_EXTSYSTEM_ID  DECIMAL(8,0)  COMMENT  '外部系统委托序号',
  VC_THIRD_REMARK  STRING  COMMENT  '第三方自定义备注(UFX)',
  C_LAUNCH_FLAG  STRING  COMMENT  '委托发起方式',
  C_NEEDSENDINTEREST  STRING  COMMENT  '利息报送标识',
  C_CONTINGENCY  STRING  COMMENT  '应急标识',
  VC_SETTLE_CURRENCY  STRING  COMMENT  '结算币种',
  C_DEALQUOTE  STRING  COMMENT  '报价处理标识',
  VC_ERROR_MSG  STRING  COMMENT  '错误原因',
  C_QUOTE_CHAT_TYPE  STRING  COMMENT  '是否报价交谈',
  C_SIDE  STRING  COMMENT  '是否为本方发送报价',
  L_NEGOTIATION_COUNT  DECIMAL(8,0)  COMMENT  '询价轮次',
  C_CHECK_STATUS  STRING  COMMENT  '复核状态',
  L_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  '复核员',
  L_CHECK_TIME  DECIMAL(6,0)  COMMENT  '复核时间',
  VC_CHECK_MEMO  STRING  COMMENT  '复核备注',
  VC_ERROR_CODE  STRING  COMMENT  '错误编号',
  EN_FIRST_CLEAR_BALANCE_ZZD  DECIMAL(16,2)  COMMENT  '中债登首次清算额',
  EN_FIRST_CLEAR_BALANCE_SQS  DECIMAL(16,2)  COMMENT  '上清所首次清算额',
  EN_SECOND_CLEAR_BALANCE_ZZD  DECIMAL(16,2)  COMMENT  '中债登到期清算额',
  EN_SECOND_CLEAR_BALANCE_SQS  DECIMAL(16,2)  COMMENT  '上清所到期清算额',
  VC_BANK_ACCOUNT_SQS  STRING  COMMENT  '',
  VC_BANK_ACCOUNT_NAME_SQS  STRING  COMMENT  '',
  VC_CHANNEL  STRING  COMMENT  '',
  C_IDEAL_TYPE  STRING  COMMENT  '',
  VC_IDEAL_ID  STRING  COMMENT  '',
  VC_MKT_QUOTE_ID  STRING  COMMENT  '',
  C_PRICE_TYPE  STRING  COMMENT  '',
  C_ORDER_STATUS  STRING  COMMENT  '订单状态',
  VC_MATCH_TYPE  STRING  COMMENT  '匿名点击报价方式',
  C_PRE_MARKET  STRING  COMMENT  '是否上市前债券',
  VC_PLEDGE_SUBMISSION_CODE  STRING  COMMENT  '',
  C_RATE_MODIFY  STRING  COMMENT  '',
  L_COMP_ID  DECIMAL(10,0)  COMMENT  '算法交易提供商',
  VC_ALGO_ORDID  STRING  COMMENT  '算法交易子单号',
  EN_BALANCE2  DECIMAL(16,2)  COMMENT  '',
  L_SETTLE_SPEED2  DECIMAL(10,0)  COMMENT  '',
  EN_NET_PRICE2  DECIMAL(16,8)  COMMENT  '',
  EN_SETTLE_INTEREST2  DECIMAL(18,12)  COMMENT  '',
  EN_MATURE_YIELD2  DECIMAL(15,8)  COMMENT  '',
  EN_STRIKE_YIELD2  DECIMAL(15,8)  COMMENT  '',
  C_SETTLE_TYPE2  STRING  COMMENT  '',
  C_CLEAR_TYPE2  STRING  COMMENT  '',
  L_SETTLE_DATE2  DECIMAL(8,0)  COMMENT  '',
  VC_SEND_TARGET  STRING  COMMENT  '',
  EN_MAX_FLOOR  DECIMAL(16,2)  COMMENT  '',
  VC_XREPOGROUP_INFO  STRING  COMMENT  '',
  VC_REPORT_CODE  STRING  COMMENT  '',
  VC_TRADE_RECORD_ID  STRING  COMMENT  '',
  C_REALTIME_UNDERTAKE_FLAG  STRING  COMMENT  '',
  C_TRUSTEE  STRING  COMMENT  '',
  VC_CANCEL_TIME  STRING  COMMENT  ''
)
COMMENT '银行间委托表'
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
                                   , L_ENTRUST_SERIAL_NO
                                   , C_QUOTE_TYPE
                                   , VC_BUSIN_CLASS
                                   , C_ENTRUST_DIRECTION
                                   , C_OP_TYPE
                                   , VC_QUOTE_ID
                                   , L_ORIGINAL_SERIAL_NO
                                   , VC_ORIGINAL_QUOTE_ID
                                   , C_ENTRUST_STATUS
                                   , VC_INTER_CODE
                                   , EN_FIRST_MATURE_YIELD
                                   , EN_FIRST_STRIKE_YIELD
                                   , EN_BALANCE
                                   , EN_FIRST_NET_PRICE
                                   , EN_MATURE_NET_PRICE
                                   , C_CLEAR_TYPE
                                   , L_SETTLE_SPEED
                                   , VC_TRADER_CODE
                                   , VC_BANK_ACCOUNT
                                   , VC_RIVALTRADER_ID
                                   , C_RATEISNULL
                                   , VC_QUOTE_TIME
                                   , VC_ORIGINAL_QUOTE_TIME
                                   , EN_SECOND_MATURE_YIELD
                                   , EN_RATE
                                   , EN_FIRST_SETTLE_INTEREST
                                   , EN_MATURE_SETTLE_INTEREST
                                   , EN_FIRST_CLEAR_BALANCE
                                   , EN_SECOND_CLEAR_BALANCE
                                   , L_FIRST_SETTLE_DATE
                                   , L_SECOND_SETTLE_DATE
                                   , C_FIRST_SETTLE_TYPE
                                   , C_SECOND_SETTLE_TYPE
                                   , L_TRADE_RIVAL_NO
                                   , VC_RIVALTRADER_NAME
                                   , VC_BANK_ACCOUNT_NAME
                                   , VC_TRADER_NAME
                                   , L_BANK_ID
                                   , EN_FIRST_NET_BALANCE
                                   , L_VALID_TIME
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , L_TIME
                                   , VC_REMARK
                                   , L_OPERATOR_NO
                                   , EN_FIRST_NET_PRICE_RIV
                                   , EN_FIRST_MATURE_YIELD_RIV
                                   , EN_FIRST_STRIKE_YIELD_RIV
                                   , EN_ENTRUST_BALANCE
                                   , EN_DEAL_BALANCE
                                   , L_DEAL_AMOUNT
                                   , VC_TRADE_RIVAL_NOS
                                   , L_ENTRUST_AMOUNT
                                   , VC_QUOTEREQ_ID
                                   , C_SPLIT_INDICATOR
                                   , L_MINTICKSIZE
                                   , L_REPORT_TIME
                                   , VC_DEAL_NO
                                   , VC_REFUSE_RIVAL_NOS
                                   , VC_RFQACCOUNT_INFO
                                   , C_ENTRUST_ORIGIN
                                   , L_EXTSYSTEM_ID
                                   , VC_THIRD_REMARK
                                   , C_LAUNCH_FLAG
                                   , C_NEEDSENDINTEREST
                                   , C_CONTINGENCY
                                   , VC_SETTLE_CURRENCY
                                   , C_DEALQUOTE
                                   , VC_ERROR_MSG
                                   , C_QUOTE_CHAT_TYPE
                                   , C_SIDE
                                   , L_NEGOTIATION_COUNT
                                   , C_CHECK_STATUS
                                   , L_CHECK_OPERATOR
                                   , L_CHECK_TIME
                                   , VC_CHECK_MEMO
                                   , VC_ERROR_CODE
                                   , EN_FIRST_CLEAR_BALANCE_ZZD
                                   , EN_FIRST_CLEAR_BALANCE_SQS
                                   , EN_SECOND_CLEAR_BALANCE_ZZD
                                   , EN_SECOND_CLEAR_BALANCE_SQS
                                   , VC_BANK_ACCOUNT_SQS
                                   , VC_BANK_ACCOUNT_NAME_SQS
                                   , VC_CHANNEL
                                   , C_IDEAL_TYPE
                                   , VC_IDEAL_ID
                                   , VC_MKT_QUOTE_ID
                                   , C_PRICE_TYPE
                                   , C_ORDER_STATUS
                                   , VC_MATCH_TYPE
                                   , C_PRE_MARKET
                                   , VC_PLEDGE_SUBMISSION_CODE
                                   , C_RATE_MODIFY
                                   , L_COMP_ID
                                   , VC_ALGO_ORDID
                                   , EN_BALANCE2
                                   , L_SETTLE_SPEED2
                                   , EN_NET_PRICE2
                                   , EN_SETTLE_INTEREST2
                                   , EN_MATURE_YIELD2
                                   , EN_STRIKE_YIELD2
                                   , C_SETTLE_TYPE2
                                   , C_CLEAR_TYPE2
                                   , L_SETTLE_DATE2
                                   , VC_SEND_TARGET
                                   , EN_MAX_FLOOR
                                   , VC_XREPOGROUP_INFO
                                   , VC_REPORT_CODE
                                   , VC_TRADE_RECORD_ID
                                   , C_REALTIME_UNDERTAKE_FLAG
                                   , C_TRUSTEE
                                   , VC_CANCEL_TIME
                                FROM ${o32_src_schema}.TBANKENTRUST"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_ENTRUST_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_QUOTE_TYPE", "type": "STRING"}, {"name": "VC_BUSIN_CLASS", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_OP_TYPE", "type": "STRING"}, {"name": "VC_QUOTE_ID", "type": "STRING"}, {"name": "L_ORIGINAL_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_ORIGINAL_QUOTE_ID", "type": "STRING"}, {"name": "C_ENTRUST_STATUS", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_FIRST_MATURE_YIELD", "type": "DOUBLE"}, {"name": "EN_FIRST_STRIKE_YIELD", "type": "DOUBLE"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_FIRST_NET_PRICE", "type": "DOUBLE"}, {"name": "EN_MATURE_NET_PRICE", "type": "DOUBLE"}, {"name": "C_CLEAR_TYPE", "type": "STRING"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "VC_TRADER_CODE", "type": "STRING"}, {"name": "VC_BANK_ACCOUNT", "type": "STRING"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "C_RATEISNULL", "type": "STRING"}, {"name": "VC_QUOTE_TIME", "type": "STRING"}, {"name": "VC_ORIGINAL_QUOTE_TIME", "type": "STRING"}, {"name": "EN_SECOND_MATURE_YIELD", "type": "DOUBLE"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "EN_FIRST_SETTLE_INTEREST", "type": "DOUBLE"}, {"name": "EN_MATURE_SETTLE_INTEREST", "type": "DOUBLE"}, {"name": "EN_FIRST_CLEAR_BALANCE", "type": "DOUBLE"}, {"name": "EN_SECOND_CLEAR_BALANCE", "type": "DOUBLE"}, {"name": "L_FIRST_SETTLE_DATE", "type": "DOUBLE"}, {"name": "L_SECOND_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_FIRST_SETTLE_TYPE", "type": "STRING"}, {"name": "C_SECOND_SETTLE_TYPE", "type": "STRING"}, {"name": "L_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_NAME", "type": "STRING"}, {"name": "VC_BANK_ACCOUNT_NAME", "type": "STRING"}, {"name": "VC_TRADER_NAME", "type": "STRING"}, {"name": "L_BANK_ID", "type": "DOUBLE"}, {"name": "EN_FIRST_NET_BALANCE", "type": "DOUBLE"}, {"name": "L_VALID_TIME", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "EN_FIRST_NET_PRICE_RIV", "type": "DOUBLE"}, {"name": "EN_FIRST_MATURE_YIELD_RIV", "type": "DOUBLE"}, {"name": "EN_FIRST_STRIKE_YIELD_RIV", "type": "DOUBLE"}, {"name": "EN_ENTRUST_BALANCE", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "VC_TRADE_RIVAL_NOS", "type": "STRING"}, {"name": "L_ENTRUST_AMOUNT", "type": "DOUBLE"}, {"name": "VC_QUOTEREQ_ID", "type": "STRING"}, {"name": "C_SPLIT_INDICATOR", "type": "STRING"}, {"name": "L_MINTICKSIZE", "type": "DOUBLE"}, {"name": "L_REPORT_TIME", "type": "DOUBLE"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "VC_REFUSE_RIVAL_NOS", "type": "STRING"}, {"name": "VC_RFQACCOUNT_INFO", "type": "STRING"}, {"name": "C_ENTRUST_ORIGIN", "type": "STRING"}, {"name": "L_EXTSYSTEM_ID", "type": "DOUBLE"}, {"name": "VC_THIRD_REMARK", "type": "STRING"}, {"name": "C_LAUNCH_FLAG", "type": "STRING"}, {"name": "C_NEEDSENDINTEREST", "type": "STRING"}, {"name": "C_CONTINGENCY", "type": "STRING"}, {"name": "VC_SETTLE_CURRENCY", "type": "STRING"}, {"name": "C_DEALQUOTE", "type": "STRING"}, {"name": "VC_ERROR_MSG", "type": "STRING"}, {"name": "C_QUOTE_CHAT_TYPE", "type": "STRING"}, {"name": "C_SIDE", "type": "STRING"}, {"name": "L_NEGOTIATION_COUNT", "type": "DOUBLE"}, {"name": "C_CHECK_STATUS", "type": "STRING"}, {"name": "L_CHECK_OPERATOR", "type": "DOUBLE"}, {"name": "L_CHECK_TIME", "type": "DOUBLE"}, {"name": "VC_CHECK_MEMO", "type": "STRING"}, {"name": "VC_ERROR_CODE", "type": "STRING"}, {"name": "EN_FIRST_CLEAR_BALANCE_ZZD", "type": "DOUBLE"}, {"name": "EN_FIRST_CLEAR_BALANCE_SQS", "type": "DOUBLE"}, {"name": "EN_SECOND_CLEAR_BALANCE_ZZD", "type": "DOUBLE"}, {"name": "EN_SECOND_CLEAR_BALANCE_SQS", "type": "DOUBLE"}, {"name": "VC_BANK_ACCOUNT_SQS", "type": "STRING"}, {"name": "VC_BANK_ACCOUNT_NAME_SQS", "type": "STRING"}, {"name": "VC_CHANNEL", "type": "STRING"}, {"name": "C_IDEAL_TYPE", "type": "STRING"}, {"name": "VC_IDEAL_ID", "type": "STRING"}, {"name": "VC_MKT_QUOTE_ID", "type": "STRING"}, {"name": "C_PRICE_TYPE", "type": "STRING"}, {"name": "C_ORDER_STATUS", "type": "STRING"}, {"name": "VC_MATCH_TYPE", "type": "STRING"}, {"name": "C_PRE_MARKET", "type": "STRING"}, {"name": "VC_PLEDGE_SUBMISSION_CODE", "type": "STRING"}, {"name": "C_RATE_MODIFY", "type": "STRING"}, {"name": "L_COMP_ID", "type": "DOUBLE"}, {"name": "VC_ALGO_ORDID", "type": "STRING"}, {"name": "EN_BALANCE2", "type": "DOUBLE"}, {"name": "L_SETTLE_SPEED2", "type": "DOUBLE"}, {"name": "EN_NET_PRICE2", "type": "DOUBLE"}, {"name": "EN_SETTLE_INTEREST2", "type": "DOUBLE"}, {"name": "EN_MATURE_YIELD2", "type": "DOUBLE"}, {"name": "EN_STRIKE_YIELD2", "type": "DOUBLE"}, {"name": "C_SETTLE_TYPE2", "type": "STRING"}, {"name": "C_CLEAR_TYPE2", "type": "STRING"}, {"name": "L_SETTLE_DATE2", "type": "DOUBLE"}, {"name": "VC_SEND_TARGET", "type": "STRING"}, {"name": "EN_MAX_FLOOR", "type": "DOUBLE"}, {"name": "VC_XREPOGROUP_INFO", "type": "STRING"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "VC_TRADE_RECORD_ID", "type": "STRING"}, {"name": "C_REALTIME_UNDERTAKE_FLAG", "type": "STRING"}, {"name": "C_TRUSTEE", "type": "STRING"}, {"name": "VC_CANCEL_TIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbankentrust_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbankentrust_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbankentrust_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbankentrust_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBANKENTRUST_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBANKENTRUST_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbankentrust_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBANKENTRUST_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_ENTRUST_SERIAL_NO
     , C_QUOTE_TYPE
     , VC_BUSIN_CLASS
     , C_ENTRUST_DIRECTION
     , C_OP_TYPE
     , VC_QUOTE_ID
     , L_ORIGINAL_SERIAL_NO
     , VC_ORIGINAL_QUOTE_ID
     , C_ENTRUST_STATUS
     , VC_INTER_CODE
     , EN_FIRST_MATURE_YIELD
     , EN_FIRST_STRIKE_YIELD
     , EN_BALANCE
     , EN_FIRST_NET_PRICE
     , EN_MATURE_NET_PRICE
     , C_CLEAR_TYPE
     , L_SETTLE_SPEED
     , VC_TRADER_CODE
     , VC_BANK_ACCOUNT
     , VC_RIVALTRADER_ID
     , C_RATEISNULL
     , VC_QUOTE_TIME
     , VC_ORIGINAL_QUOTE_TIME
     , EN_SECOND_MATURE_YIELD
     , EN_RATE
     , EN_FIRST_SETTLE_INTEREST
     , EN_MATURE_SETTLE_INTEREST
     , EN_FIRST_CLEAR_BALANCE
     , EN_SECOND_CLEAR_BALANCE
     , L_FIRST_SETTLE_DATE
     , L_SECOND_SETTLE_DATE
     , C_FIRST_SETTLE_TYPE
     , C_SECOND_SETTLE_TYPE
     , L_TRADE_RIVAL_NO
     , VC_RIVALTRADER_NAME
     , VC_BANK_ACCOUNT_NAME
     , VC_TRADER_NAME
     , L_BANK_ID
     , EN_FIRST_NET_BALANCE
     , L_VALID_TIME
     , L_FUND_ID
     , L_BASECOMBI_ID
     , L_TIME
     , VC_REMARK
     , L_OPERATOR_NO
     , EN_FIRST_NET_PRICE_RIV
     , EN_FIRST_MATURE_YIELD_RIV
     , EN_FIRST_STRIKE_YIELD_RIV
     , EN_ENTRUST_BALANCE
     , EN_DEAL_BALANCE
     , L_DEAL_AMOUNT
     , VC_TRADE_RIVAL_NOS
     , L_ENTRUST_AMOUNT
     , VC_QUOTEREQ_ID
     , C_SPLIT_INDICATOR
     , L_MINTICKSIZE
     , L_REPORT_TIME
     , VC_DEAL_NO
     , VC_REFUSE_RIVAL_NOS
     , VC_RFQACCOUNT_INFO
     , C_ENTRUST_ORIGIN
     , L_EXTSYSTEM_ID
     , VC_THIRD_REMARK
     , C_LAUNCH_FLAG
     , C_NEEDSENDINTEREST
     , C_CONTINGENCY
     , VC_SETTLE_CURRENCY
     , C_DEALQUOTE
     , VC_ERROR_MSG
     , C_QUOTE_CHAT_TYPE
     , C_SIDE
     , L_NEGOTIATION_COUNT
     , C_CHECK_STATUS
     , L_CHECK_OPERATOR
     , L_CHECK_TIME
     , VC_CHECK_MEMO
     , VC_ERROR_CODE
     , EN_FIRST_CLEAR_BALANCE_ZZD
     , EN_FIRST_CLEAR_BALANCE_SQS
     , EN_SECOND_CLEAR_BALANCE_ZZD
     , EN_SECOND_CLEAR_BALANCE_SQS
     , VC_BANK_ACCOUNT_SQS
     , VC_BANK_ACCOUNT_NAME_SQS
     , VC_CHANNEL
     , C_IDEAL_TYPE
     , VC_IDEAL_ID
     , VC_MKT_QUOTE_ID
     , C_PRICE_TYPE
     , C_ORDER_STATUS
     , VC_MATCH_TYPE
     , C_PRE_MARKET
     , VC_PLEDGE_SUBMISSION_CODE
     , C_RATE_MODIFY
     , L_COMP_ID
     , VC_ALGO_ORDID
     , EN_BALANCE2
     , L_SETTLE_SPEED2
     , EN_NET_PRICE2
     , EN_SETTLE_INTEREST2
     , EN_MATURE_YIELD2
     , EN_STRIKE_YIELD2
     , C_SETTLE_TYPE2
     , C_CLEAR_TYPE2
     , L_SETTLE_DATE2
     , VC_SEND_TARGET
     , EN_MAX_FLOOR
     , VC_XREPOGROUP_INFO
     , VC_REPORT_CODE
     , VC_TRADE_RECORD_ID
     , C_REALTIME_UNDERTAKE_FLAG
     , C_TRUSTEE
     , VC_CANCEL_TIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , '${p_end_dt}' P_DT
  FROM ODS_XDAY_O32.ODS_O32_TBANKENTRUST_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBANKENTRUST_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBANKENTRUST_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBANKENTRUST_PTD成功"
      exit 0
   fi
fi
