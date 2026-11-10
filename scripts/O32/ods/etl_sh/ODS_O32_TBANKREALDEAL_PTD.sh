#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBANKREALDEAL_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBANKREALDEAL_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '成交日期',
  L_TIME  DECIMAL(6,0)  COMMENT  '成交时间',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '券面总额',
  EN_RATE  DECIMAL(14,8)  COMMENT  '回购利率',
  EN_FIRST_SETTLE_INTEREST  DECIMAL(22,12)  COMMENT  '首次交割日百元债券利息',
  EN_FIRST_NET_PRICE  DECIMAL(20,12)  COMMENT  '首次交易净价价格',
  EN_FIRST_FULL_PRICE  DECIMAL(20,12)  COMMENT  '首次交易全价价格',
  EN_FIRST_CLEAR_BALANCE  DECIMAL(16,2)  COMMENT  '首次资金清算额',
  EN_FIRST_MATURE_YIELD  DECIMAL(15,8)  COMMENT  '首次收益率',
  EN_SECOND_CLEAR_BALANCE  DECIMAL(16,2)  COMMENT  '到期资金清算额',
  EN_SECOND_MATURE_YIELD  DECIMAL(15,8)  COMMENT  '到期收益率',
  L_FIRST_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '首次交割日',
  L_SECOND_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '到期交割日',
  L_HG_DAYS  DECIMAL(10,0)  COMMENT  '回购天数',
  L_SETTLE_SPEED  DECIMAL(10,0)  COMMENT  '清算速度',
  L_USE_DAYS  DECIMAL(10,0)  COMMENT  '实际占款天数',
  C_FIRST_SETTLE_TYPE  STRING  COMMENT  '首次交割方式',
  C_SECOND_SETTLE_TYPE  STRING  COMMENT  '到期交割方式',
  C_CANCEL_FLAG  STRING  COMMENT  '撤单标志',
  C_STATUS  STRING  COMMENT  '状态',
  L_ENTRUST_SERIAL_NO  DECIMAL(10,0)  COMMENT  '委托序号',
  L_TRADE_RIVAL_NO  DECIMAL(10,0)  COMMENT  '交易对手',
  EN_FEE  DECIMAL(12,2)  COMMENT  '费用',
  C_BUSIN_CLASS  STRING  COMMENT  '业务分类',
  VC_REMARK  STRING  COMMENT  '备注',
  L_SERIAL_NO  DECIMAL(8,0)  COMMENT  '成交序号',
  C_SOURCE  STRING  COMMENT  '数据来源',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改序号',
  VC_ORIGINAL_DEAL_NO  STRING  COMMENT  '原成交编号',
  C_EXTERNAL_DEAL_FLAG  STRING  COMMENT  '外部处理标志',
  EN_MATURE_NET_PRICE  DECIMAL(20,12)  COMMENT  '到期交易净价价格',
  EN_MATURE_SETTLE_INTEREST  DECIMAL(22,12)  COMMENT  '到期交割日百元债券利息',
  VC_BROKER_NO  STRING  COMMENT  '券商编号',
  C_LOCK_FLAG  STRING  COMMENT  '锁定标志',
  VC_MATCH_INFO  STRING  COMMENT  '匹配信息',
  C_FIXSEND_FLAG  STRING  COMMENT  'FIX发送标志',
  L_INSTR_DATE  DECIMAL(8,0)  COMMENT  '结算指令日期',
  VC_INSTRID  STRING  COMMENT  '结算指令序号',
  L_STOCK_SERIAL_NO  DECIMAL(10,0)  COMMENT  '指令证券序号',
  VC_SOURCE_NO  STRING  COMMENT  '方案序号',
  VC_QUOTE_ID  STRING  COMMENT  '报价单号',
  VC_RIVALTRADER_NAME  STRING  COMMENT  '对手方交易员中文名称',
  L_RIVALACCOUNT_NO  DECIMAL(10,0)  COMMENT  '对手方银行账户序号',
  C_CLEAR_TYPE  STRING  COMMENT  '清算类型',
  L_INSTANCE_ID  DECIMAL(12,0)  COMMENT  '实例ID',
  VC_BANK_ACCOUNT  STRING  COMMENT  '银行账号',
  VC_OPERATOR_NAME  STRING  COMMENT  '操作员名字',
  L_BANK_ID  DECIMAL(10,0)  COMMENT  '银行iD',
  VC_CONFIRM_NO  STRING  COMMENT  '确认号',
  L_DEAL_AMOUNT  DECIMAL(20,4)  COMMENT  '成交数量',
  EN_DEAL_BALANCE  DECIMAL(18,2)  COMMENT  '成交金额',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '操作员',
  VC_ALERT_METHOD  STRING  COMMENT  'Alert交收方式',
  VC_RIVALTRADER_ID  STRING  COMMENT  '对手交易员',
  C_TRADE_TYPE  STRING  COMMENT  '成交类别',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司序号',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '部门序号',
  L_EXEC_CONFIRM_NO  DECIMAL(10,0)  COMMENT  '执行确认序号',
  C_ACCOUNT_MODE  STRING  COMMENT  '做账模式',
  VC_SELFTRADER_NAME  STRING  COMMENT  '本方交易员名称',
  L_RIVALBANK_ID  DECIMAL(10,0)  COMMENT  '对手方银行间ID',
  VC_UNIQUE_DEAL_SERIAL_NO  STRING  COMMENT  '对接外部系统唯一成交标识',
  L_MODIFY_NO  DECIMAL(8,0)  COMMENT  '修改序号',
  L_LOCK_OPERATOR  DECIMAL(8,0)  COMMENT  '锁定操作员',
  EN_FEE_JG  DECIMAL(12,2)  COMMENT  '交割费',
  EN_FEE_JS2  DECIMAL(12,2)  COMMENT  '结算费',
  C_TREATYHG_FLAG  STRING  COMMENT  '协议回购标志',
  L_HG_BATCH_NO  DECIMAL(10,0)  COMMENT  '协议回购批号',
  C_SETTLE_FLAG  STRING  COMMENT  '交收失败标识',
  L_BONDLENDING_AMOUNT  DECIMAL(18,2)  COMMENT  '银行间债券卖空',
  VC_EXPORT_FLAG  STRING  COMMENT  '导出标志',
  L_MATCHTIME  DECIMAL(6,0)  COMMENT  '匹配时间',
  L_IMP_DEAL_TERM  DECIMAL(10,0)  COMMENT  '质押券处理时段',
  VC_ORIGINAL_ENTRUST_DIRECTION  STRING  COMMENT  '原委托方向',
  EN_FIRST_CLEAR_BALANCE_ZZD  DECIMAL(16,2)  COMMENT  '首次资金清算额',
  EN_FIRST_CLEAR_BALANCE_SQS  DECIMAL(16,2)  COMMENT  '首次资金清算额',
  EN_SECOND_CLEAR_BALANCE_ZZD  DECIMAL(16,2)  COMMENT  '到期资金清算额',
  EN_SECOND_CLEAR_BALANCE_SQS  DECIMAL(16,2)  COMMENT  '到期资金清算额',
  C_TRUSTEE  STRING  COMMENT  '银行账号增加托管机构',
  C_CROSSMARKET_FLAG  STRING  COMMENT  '',
  VC_BANK_ACCOUNT2  STRING  COMMENT  '银行账户',
  L_RIVALACCOUNT_NO2  STRING  COMMENT  '对手账户编号',
  L_BUYOUT_AMOUNT  DECIMAL(20,4)  COMMENT  '卖出数量',
  EN_FEE_JSDL  DECIMAL(12,2)  COMMENT  '',
  C_DISPUTE_RESOLUTIO  STRING  COMMENT  '',
  C_PLEDGED_REPLACE_TYPE  STRING  COMMENT  '',
  C_MATCH_SOURCE  STRING  COMMENT  '匹配资源',
  C_TRADE_METHOD  STRING  COMMENT  '交易方式',
  L_MANAGER_OPERTOR  STRING  COMMENT  '投资经理编号',
  L_AFFILIATION  STRING  COMMENT  '交易目的编号',
  L_FUZZY_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '',
  L_FUZZY_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '',
  C_CASH_STATUS  STRING  COMMENT  '兑付状态',
  C_CASH_STATUS2  STRING  COMMENT  '兑付状态2',
  L_CASH_DATETIME  DECIMAL(14,0)  COMMENT  '兑付日期',
  L_CASH_DATETIME2  DECIMAL(14,0)  COMMENT  '兑付日期2',
  C_IS_FORCE  STRING  COMMENT  '',
  C_CLEAR_METHOD  STRING  COMMENT  '清算方法',
  L_EXTSYSTEM_ID  DECIMAL(8,0)  COMMENT  '',
  C_LAUNCH_FLAG  STRING  COMMENT  '发行标志',
  C_PREJS_STATUS  STRING  COMMENT  '',
  EN_FIRST_STRIKE_YIELD  DECIMAL(15,8)  COMMENT  '首次行权收益率',
  EN_SECOND_STRIKE_YIELD  DECIMAL(15,8)  COMMENT  '',
  L_DIRECT_DATE  DECIMAL(8,0)  COMMENT  '',
  L_DIRECT_OPERATOR  DECIMAL(8,0)  COMMENT  '基金经理'
)
COMMENT '银行间成交回报表'
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
                                   , L_TIME
                                   , VC_DEAL_NO
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , C_INVEST_TYPE
                                   , C_ENTRUST_DIRECTION
                                   , VC_INTER_CODE
                                   , EN_BALANCE
                                   , EN_RATE
                                   , EN_FIRST_SETTLE_INTEREST
                                   , EN_FIRST_NET_PRICE
                                   , EN_FIRST_FULL_PRICE
                                   , EN_FIRST_CLEAR_BALANCE
                                   , EN_FIRST_MATURE_YIELD
                                   , EN_SECOND_CLEAR_BALANCE
                                   , EN_SECOND_MATURE_YIELD
                                   , L_FIRST_SETTLE_DATE
                                   , L_SECOND_SETTLE_DATE
                                   , L_HG_DAYS
                                   , L_SETTLE_SPEED
                                   , L_USE_DAYS
                                   , C_FIRST_SETTLE_TYPE
                                   , C_SECOND_SETTLE_TYPE
                                   , C_CANCEL_FLAG
                                   , C_STATUS
                                   , L_ENTRUST_SERIAL_NO
                                   , L_TRADE_RIVAL_NO
                                   , EN_FEE
                                   , C_BUSIN_CLASS
                                   , VC_REMARK
                                   , L_SERIAL_NO
                                   , C_SOURCE
                                   , L_INDEX_DAILY_MODIFY
                                   , VC_ORIGINAL_DEAL_NO
                                   , C_EXTERNAL_DEAL_FLAG
                                   , EN_MATURE_NET_PRICE
                                   , EN_MATURE_SETTLE_INTEREST
                                   , VC_BROKER_NO
                                   , C_LOCK_FLAG
                                   , VC_MATCH_INFO
                                   , C_FIXSEND_FLAG
                                   , L_INSTR_DATE
                                   , VC_INSTRID
                                   , L_STOCK_SERIAL_NO
                                   , VC_SOURCE_NO
                                   , VC_QUOTE_ID
                                   , VC_RIVALTRADER_NAME
                                   , L_RIVALACCOUNT_NO
                                   , C_CLEAR_TYPE
                                   , L_INSTANCE_ID
                                   , VC_BANK_ACCOUNT
                                   , VC_OPERATOR_NAME
                                   , L_BANK_ID
                                   , VC_CONFIRM_NO
                                   , L_DEAL_AMOUNT
                                   , EN_DEAL_BALANCE
                                   , L_OPERATOR_NO
                                   , VC_ALERT_METHOD
                                   , VC_RIVALTRADER_ID
                                   , C_TRADE_TYPE
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , L_EXEC_CONFIRM_NO
                                   , C_ACCOUNT_MODE
                                   , VC_SELFTRADER_NAME
                                   , L_RIVALBANK_ID
                                   , VC_UNIQUE_DEAL_SERIAL_NO
                                   , L_MODIFY_NO
                                   , L_LOCK_OPERATOR
                                   , EN_FEE_JG
                                   , EN_FEE_JS2
                                   , C_TREATYHG_FLAG
                                   , L_HG_BATCH_NO
                                   , C_SETTLE_FLAG
                                   , L_BONDLENDING_AMOUNT
                                   , VC_EXPORT_FLAG
                                   , L_MATCHTIME
                                   , L_IMP_DEAL_TERM
                                   , VC_ORIGINAL_ENTRUST_DIRECTION
                                   , EN_FIRST_CLEAR_BALANCE_ZZD
                                   , EN_FIRST_CLEAR_BALANCE_SQS
                                   , EN_SECOND_CLEAR_BALANCE_ZZD
                                   , EN_SECOND_CLEAR_BALANCE_SQS
                                   , C_TRUSTEE
                                   , C_CROSSMARKET_FLAG
                                   , VC_BANK_ACCOUNT2
                                   , L_RIVALACCOUNT_NO2
                                   , L_BUYOUT_AMOUNT
                                   , EN_FEE_JSDL
                                   , C_DISPUTE_RESOLUTIO
                                   , C_PLEDGED_REPLACE_TYPE
                                   , C_MATCH_SOURCE
                                   , C_TRADE_METHOD
                                   , L_MANAGER_OPERTOR
                                   , L_AFFILIATION
                                   , L_FUZZY_DAILY_INSTRUCTION_NO
                                   , L_FUZZY_INDEX_DAILY_MODIFY
                                   , C_CASH_STATUS
                                   , C_CASH_STATUS2
                                   , L_CASH_DATETIME
                                   , L_CASH_DATETIME2
                                   , C_IS_FORCE
                                   , C_CLEAR_METHOD
                                   , L_EXTSYSTEM_ID
                                   , C_LAUNCH_FLAG
                                   , C_PREJS_STATUS
                                   , EN_FIRST_STRIKE_YIELD
                                   , EN_SECOND_STRIKE_YIELD
                                   , L_DIRECT_DATE
                                   , L_DIRECT_OPERATOR
                                FROM ${o32_src_schema}.TBANKREALDEAL
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "EN_FIRST_SETTLE_INTEREST", "type": "DOUBLE"}, {"name": "EN_FIRST_NET_PRICE", "type": "DOUBLE"}, {"name": "EN_FIRST_FULL_PRICE", "type": "DOUBLE"}, {"name": "EN_FIRST_CLEAR_BALANCE", "type": "DOUBLE"}, {"name": "EN_FIRST_MATURE_YIELD", "type": "DOUBLE"}, {"name": "EN_SECOND_CLEAR_BALANCE", "type": "DOUBLE"}, {"name": "EN_SECOND_MATURE_YIELD", "type": "DOUBLE"}, {"name": "L_FIRST_SETTLE_DATE", "type": "DOUBLE"}, {"name": "L_SECOND_SETTLE_DATE", "type": "DOUBLE"}, {"name": "L_HG_DAYS", "type": "DOUBLE"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "L_USE_DAYS", "type": "DOUBLE"}, {"name": "C_FIRST_SETTLE_TYPE", "type": "STRING"}, {"name": "C_SECOND_SETTLE_TYPE", "type": "STRING"}, {"name": "C_CANCEL_FLAG", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_ENTRUST_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_SOURCE", "type": "STRING"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "VC_ORIGINAL_DEAL_NO", "type": "STRING"}, {"name": "C_EXTERNAL_DEAL_FLAG", "type": "STRING"}, {"name": "EN_MATURE_NET_PRICE", "type": "DOUBLE"}, {"name": "EN_MATURE_SETTLE_INTEREST", "type": "DOUBLE"}, {"name": "VC_BROKER_NO", "type": "STRING"}, {"name": "C_LOCK_FLAG", "type": "STRING"}, {"name": "VC_MATCH_INFO", "type": "STRING"}, {"name": "C_FIXSEND_FLAG", "type": "STRING"}, {"name": "L_INSTR_DATE", "type": "DOUBLE"}, {"name": "VC_INSTRID", "type": "STRING"}, {"name": "L_STOCK_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_SOURCE_NO", "type": "STRING"}, {"name": "VC_QUOTE_ID", "type": "STRING"}, {"name": "VC_RIVALTRADER_NAME", "type": "STRING"}, {"name": "L_RIVALACCOUNT_NO", "type": "DOUBLE"}, {"name": "C_CLEAR_TYPE", "type": "STRING"}, {"name": "L_INSTANCE_ID", "type": "DOUBLE"}, {"name": "VC_BANK_ACCOUNT", "type": "STRING"}, {"name": "VC_OPERATOR_NAME", "type": "STRING"}, {"name": "L_BANK_ID", "type": "DOUBLE"}, {"name": "VC_CONFIRM_NO", "type": "STRING"}, {"name": "L_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "VC_ALERT_METHOD", "type": "STRING"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "C_TRADE_TYPE", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "L_EXEC_CONFIRM_NO", "type": "DOUBLE"}, {"name": "C_ACCOUNT_MODE", "type": "STRING"}, {"name": "VC_SELFTRADER_NAME", "type": "STRING"}, {"name": "L_RIVALBANK_ID", "type": "DOUBLE"}, {"name": "VC_UNIQUE_DEAL_SERIAL_NO", "type": "STRING"}, {"name": "L_MODIFY_NO", "type": "DOUBLE"}, {"name": "L_LOCK_OPERATOR", "type": "DOUBLE"}, {"name": "EN_FEE_JG", "type": "DOUBLE"}, {"name": "EN_FEE_JS2", "type": "DOUBLE"}, {"name": "C_TREATYHG_FLAG", "type": "STRING"}, {"name": "L_HG_BATCH_NO", "type": "DOUBLE"}, {"name": "C_SETTLE_FLAG", "type": "STRING"}, {"name": "L_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "VC_EXPORT_FLAG", "type": "STRING"}, {"name": "L_MATCHTIME", "type": "DOUBLE"}, {"name": "L_IMP_DEAL_TERM", "type": "DOUBLE"}, {"name": "VC_ORIGINAL_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "EN_FIRST_CLEAR_BALANCE_ZZD", "type": "DOUBLE"}, {"name": "EN_FIRST_CLEAR_BALANCE_SQS", "type": "DOUBLE"}, {"name": "EN_SECOND_CLEAR_BALANCE_ZZD", "type": "DOUBLE"}, {"name": "EN_SECOND_CLEAR_BALANCE_SQS", "type": "DOUBLE"}, {"name": "C_TRUSTEE", "type": "STRING"}, {"name": "C_CROSSMARKET_FLAG", "type": "STRING"}, {"name": "VC_BANK_ACCOUNT2", "type": "STRING"}, {"name": "L_RIVALACCOUNT_NO2", "type": "DOUBLE"}, {"name": "L_BUYOUT_AMOUNT", "type": "DOUBLE"}, {"name": "EN_FEE_JSDL", "type": "DOUBLE"}, {"name": "C_DISPUTE_RESOLUTIO", "type": "STRING"}, {"name": "C_PLEDGED_REPLACE_TYPE", "type": "STRING"}, {"name": "C_MATCH_SOURCE", "type": "STRING"}, {"name": "C_TRADE_METHOD", "type": "STRING"}, {"name": "L_MANAGER_OPERTOR", "type": "DOUBLE"}, {"name": "L_AFFILIATION", "type": "DOUBLE"}, {"name": "L_FUZZY_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_FUZZY_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "C_CASH_STATUS", "type": "STRING"}, {"name": "C_CASH_STATUS2", "type": "STRING"}, {"name": "L_CASH_DATETIME", "type": "DOUBLE"}, {"name": "L_CASH_DATETIME2", "type": "DOUBLE"}, {"name": "C_IS_FORCE", "type": "STRING"}, {"name": "C_CLEAR_METHOD", "type": "STRING"}, {"name": "L_EXTSYSTEM_ID", "type": "DOUBLE"}, {"name": "C_LAUNCH_FLAG", "type": "STRING"}, {"name": "C_PREJS_STATUS", "type": "STRING"}, {"name": "EN_FIRST_STRIKE_YIELD", "type": "DOUBLE"}, {"name": "EN_SECOND_STRIKE_YIELD", "type": "DOUBLE"}, {"name": "L_DIRECT_DATE", "type": "DOUBLE"}, {"name": "L_DIRECT_OPERATOR", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbankrealdeal_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbankrealdeal_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbankrealdeal_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbankrealdeal_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBANKREALDEAL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBANKREALDEAL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbankrealdeal_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBANKREALDEAL_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_TIME
     , VC_DEAL_NO
     , L_DAILY_INSTRUCTION_NO
     , L_FUND_ID
     , L_BASECOMBI_ID
     , C_INVEST_TYPE
     , C_ENTRUST_DIRECTION
     , VC_INTER_CODE
     , EN_BALANCE
     , EN_RATE
     , EN_FIRST_SETTLE_INTEREST
     , EN_FIRST_NET_PRICE
     , EN_FIRST_FULL_PRICE
     , EN_FIRST_CLEAR_BALANCE
     , EN_FIRST_MATURE_YIELD
     , EN_SECOND_CLEAR_BALANCE
     , EN_SECOND_MATURE_YIELD
     , L_FIRST_SETTLE_DATE
     , L_SECOND_SETTLE_DATE
     , L_HG_DAYS
     , L_SETTLE_SPEED
     , L_USE_DAYS
     , C_FIRST_SETTLE_TYPE
     , C_SECOND_SETTLE_TYPE
     , C_CANCEL_FLAG
     , C_STATUS
     , L_ENTRUST_SERIAL_NO
     , L_TRADE_RIVAL_NO
     , EN_FEE
     , C_BUSIN_CLASS
     , VC_REMARK
     , L_SERIAL_NO
     , C_SOURCE
     , L_INDEX_DAILY_MODIFY
     , VC_ORIGINAL_DEAL_NO
     , C_EXTERNAL_DEAL_FLAG
     , EN_MATURE_NET_PRICE
     , EN_MATURE_SETTLE_INTEREST
     , VC_BROKER_NO
     , C_LOCK_FLAG
     , VC_MATCH_INFO
     , C_FIXSEND_FLAG
     , L_INSTR_DATE
     , VC_INSTRID
     , L_STOCK_SERIAL_NO
     , VC_SOURCE_NO
     , VC_QUOTE_ID
     , VC_RIVALTRADER_NAME
     , L_RIVALACCOUNT_NO
     , C_CLEAR_TYPE
     , L_INSTANCE_ID
     , VC_BANK_ACCOUNT
     , VC_OPERATOR_NAME
     , L_BANK_ID
     , VC_CONFIRM_NO
     , L_DEAL_AMOUNT
     , EN_DEAL_BALANCE
     , L_OPERATOR_NO
     , VC_ALERT_METHOD
     , VC_RIVALTRADER_ID
     , C_TRADE_TYPE
     , L_ORG_ID
     , L_DEPT_ID
     , L_EXEC_CONFIRM_NO
     , C_ACCOUNT_MODE
     , VC_SELFTRADER_NAME
     , L_RIVALBANK_ID
     , VC_UNIQUE_DEAL_SERIAL_NO
     , L_MODIFY_NO
     , L_LOCK_OPERATOR
     , EN_FEE_JG
     , EN_FEE_JS2
     , C_TREATYHG_FLAG
     , L_HG_BATCH_NO
     , C_SETTLE_FLAG
     , L_BONDLENDING_AMOUNT
     , VC_EXPORT_FLAG
     , L_MATCHTIME
     , L_IMP_DEAL_TERM
     , VC_ORIGINAL_ENTRUST_DIRECTION
     , EN_FIRST_CLEAR_BALANCE_ZZD
     , EN_FIRST_CLEAR_BALANCE_SQS
     , EN_SECOND_CLEAR_BALANCE_ZZD
     , EN_SECOND_CLEAR_BALANCE_SQS
     , C_TRUSTEE
     , C_CROSSMARKET_FLAG
     , VC_BANK_ACCOUNT2
     , L_RIVALACCOUNT_NO2
     , L_BUYOUT_AMOUNT
     , EN_FEE_JSDL
     , C_DISPUTE_RESOLUTIO
     , C_PLEDGED_REPLACE_TYPE
     , C_MATCH_SOURCE
     , C_TRADE_METHOD
     , L_MANAGER_OPERTOR
     , L_AFFILIATION
     , L_FUZZY_DAILY_INSTRUCTION_NO
     , L_FUZZY_INDEX_DAILY_MODIFY
     , C_CASH_STATUS
     , C_CASH_STATUS2
     , L_CASH_DATETIME
     , L_CASH_DATETIME2
     , C_IS_FORCE
     , C_CLEAR_METHOD
     , L_EXTSYSTEM_ID
     , C_LAUNCH_FLAG
     , C_PREJS_STATUS
     , EN_FIRST_STRIKE_YIELD
     , EN_SECOND_STRIKE_YIELD
     , L_DIRECT_DATE
     , L_DIRECT_OPERATOR
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TBANKREALDEAL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBANKREALDEAL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBANKREALDEAL_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBANKREALDEAL_PTD成功"
      exit 0
   fi
fi
