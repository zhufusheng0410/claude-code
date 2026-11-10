#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TDEPOSITRECEIPT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TDEPOSITRECEIPT_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '存入日期',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  VC_INTER_NO  STRING  COMMENT  '内部合同号',
  VC_RECEIPT_NO  STRING  COMMENT  '存单号',
  VC_ACCOUNT_NO  STRING  COMMENT  '存款帐号',
  VC_ACCOUNT_NAME  STRING  COMMENT  '账户名称',
  VC_PLACE  STRING  COMMENT  '存款地',
  L_BANK  DECIMAL(10,0)  COMMENT  '银行总行',
  VC_MINOR_BANK  STRING  COMMENT  '存款支行',
  VC_DEPOSIT_OWNER  STRING  COMMENT  '存款人',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '存单金额',
  EN_RATE  DECIMAL(16,12)  COMMENT  '利率*',
  L_LIMIT_TIME  DECIMAL(4,0)  COMMENT  '存款期限*',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '起息日',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日',
  L_LAST_INTEREST_DATE  DECIMAL(8,0)  COMMENT  '上一付息日',
  L_LAST_MOD_INTEREST_DATE  DECIMAL(8,0)  COMMENT  '上一调息日',
  EN_TOTAL_INTEREST  DECIMAL(16,2)  COMMENT  '累计利息收入',
  EN_INTEREST  DECIMAL(16,2)  COMMENT  '应收利息',
  EN_PUNISH_INTEREST  DECIMAL(16,2)  COMMENT  '罚息金额',
  VC_REMARK  STRING  COMMENT  '备注',
  C_STATUS  STRING  COMMENT  '存单状态',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '执行人',
  L_CONFIRM_NO  STRING  COMMENT  '确认编号',
  L_DEPOSIT_CONFIRM_NO  DECIMAL(4,0)  COMMENT  '存单确认序号',
  L_NOTIFY_DAYS  DECIMAL(4,0)  COMMENT  '通知天数',
  EN_RECEIVABLE_INTEREST  DECIMAL(16,2)  COMMENT  '当日计提利息',
  C_AUTO_REDEPOSIT  STRING  COMMENT  '是否自动转存',
  C_INTEREST_DEPOSIT  STRING  COMMENT  '利息是否转存',
  C_RATE_TYPE  STRING  COMMENT  '利率类型',
  C_INTEREST_PAY_TYPE  STRING  COMMENT  '付息方式',
  C_DEPOSIT_TYPE  STRING  COMMENT  '存单附加属性',
  EN_BASIC_RATE  DECIMAL(16,12)  COMMENT  '#基本利差',
  C_DAY_TYPE  STRING  COMMENT  '#计息天数',
  C_FLOAT_TYPE  STRING  COMMENT  '基准利率类型',
  L_INTEREST_PAY_DATE  DECIMAL(8,0)  COMMENT  '首次付息日',
  C_INTEREST_PAY_FREQ  STRING  COMMENT  '付息频率',
  C_RATE_CHANGE_TYPE  STRING  COMMENT  '利率变动方式',
  C_ADVANCE_LIMIT_FLAG  STRING  COMMENT  '提前支限限制',
  L_PAY_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '支取交收日期',
  C_LIMIT_UNIT  STRING  COMMENT  '合同期限单位',
  EN_ADVANCE_RATE  DECIMAL(16,12)  COMMENT  '提前支取利率',
  EN_PAYIN_BALANCE  DECIMAL(16,2)  COMMENT  '已存入本金',
  EN_PRE_PAY_BALANCE  DECIMAL(16,2)  COMMENT  '待支取本金',
  C_INPUT_TYPE  STRING  COMMENT  '录入类型',
  L_ADVANCE_DATE  DECIMAL(8,0)  COMMENT  '可提前支取日期',
  L_QS_CONFIRM_NO  STRING  COMMENT  'o4确认编号',
  VC_SECOND_DEPOSIT_NO  STRING  COMMENT  '',
  L_ACCOUNT_ID  DECIMAL(8,0)  COMMENT  '账户序号',
  VC_BANK_BRANCH_CODE  STRING  COMMENT  '',
  L_LAST_RATE_MOD_DATE  DECIMAL(8,0)  COMMENT  '',
  EN_MOD_RECEIVABLE_INTEREST  DECIMAL(16,2)  COMMENT  '',
  L_RE_PAY_INTEVAL  DECIMAL(10,0)  COMMENT  '',
  C_RE_PAY_INTEVAL_UNIT  STRING  COMMENT  '',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  C_MARKET_NO  STRING  COMMENT  '交易市场',
  L_FIRST_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '首次结算日',
  C_SETTLE_DELAY_TYPE  STRING  COMMENT  '',
  C_PAY_DELAY_TYPE  STRING  COMMENT  '',
  L_USE_DAYS  DECIMAL(8,0)  COMMENT  '实际占款天数',
  L_PRO_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '',
  EN_UNSETTLE_INTREST_AMT  DECIMAL(16,2)  COMMENT  '',
  L_TRADE_RIVAL_NO  DECIMAL(10,0)  COMMENT  '交易对手',
  VC_RIVALTRADER_ID  STRING  COMMENT  '交易对手交易员id',
  L_SETTLE_SPEED  DECIMAL(8,0)  COMMENT  '清算速度',
  VC_RIVALTRADER_NAME  STRING  COMMENT  '交易对手交易员名称',
  VC_SELFTRADER_NAME  STRING  COMMENT  '本方交易员名称',
  L_RIVALBANK_ID  DECIMAL(10,0)  COMMENT  '对手方银行间ID',
  L_BANK_ID  DECIMAL(10,0)  COMMENT  '',
  VC_QUOTE_ID  STRING  COMMENT  '报价单号',
  VC_OPERATOR_NAME  STRING  COMMENT  '操作员名字',
  VC_DISBURSEMENT_ACCOUNT  STRING  COMMENT  '',
  VC_DISBURSEMENT_ACCOUNT_NAME  STRING  COMMENT  '',
  VC_SELF_PRODUCTS_NAME  STRING  COMMENT  '',
  VC_RIVAL_PRODUCTS_NAME  STRING  COMMENT  ''
)
COMMENT '在途存单信息表'
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
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_INTER_CODE
                                   , VC_INTER_NO
                                   , VC_RECEIPT_NO
                                   , VC_ACCOUNT_NO
                                   , VC_ACCOUNT_NAME
                                   , VC_PLACE
                                   , L_BANK
                                   , VC_MINOR_BANK
                                   , VC_DEPOSIT_OWNER
                                   , EN_BALANCE
                                   , EN_RATE
                                   , L_LIMIT_TIME
                                   , L_BEGIN_DATE
                                   , L_END_DATE
                                   , L_LAST_INTEREST_DATE
                                   , L_LAST_MOD_INTEREST_DATE
                                   , EN_TOTAL_INTEREST
                                   , EN_INTEREST
                                   , EN_PUNISH_INTEREST
                                   , VC_REMARK
                                   , C_STATUS
                                   , L_OPERATOR_NO
                                   , L_CONFIRM_NO
                                   , L_DEPOSIT_CONFIRM_NO
                                   , L_NOTIFY_DAYS
                                   , EN_RECEIVABLE_INTEREST
                                   , C_AUTO_REDEPOSIT
                                   , C_INTEREST_DEPOSIT
                                   , C_RATE_TYPE
                                   , C_INTEREST_PAY_TYPE
                                   , C_DEPOSIT_TYPE
                                   , EN_BASIC_RATE
                                   , C_DAY_TYPE
                                   , C_FLOAT_TYPE
                                   , L_INTEREST_PAY_DATE
                                   , C_INTEREST_PAY_FREQ
                                   , C_RATE_CHANGE_TYPE
                                   , C_ADVANCE_LIMIT_FLAG
                                   , L_PAY_SETTLE_DATE
                                   , C_LIMIT_UNIT
                                   , EN_ADVANCE_RATE
                                   , EN_PAYIN_BALANCE
                                   , EN_PRE_PAY_BALANCE
                                   , C_INPUT_TYPE
                                   , L_ADVANCE_DATE
                                   , L_QS_CONFIRM_NO
                                   , VC_SECOND_DEPOSIT_NO
                                   , L_ACCOUNT_ID
                                   , VC_BANK_BRANCH_CODE
                                   , L_LAST_RATE_MOD_DATE
                                   , EN_MOD_RECEIVABLE_INTEREST
                                   , L_RE_PAY_INTEVAL
                                   , C_RE_PAY_INTEVAL_UNIT
                                   , C_INVEST_TYPE
                                   , VC_DEAL_NO
                                   , C_MARKET_NO
                                   , L_FIRST_SETTLE_DATE
                                   , C_SETTLE_DELAY_TYPE
                                   , C_PAY_DELAY_TYPE
                                   , L_USE_DAYS
                                   , L_PRO_SETTLE_DATE
                                   , EN_UNSETTLE_INTREST_AMT
                                   , L_TRADE_RIVAL_NO
                                   , VC_RIVALTRADER_ID
                                   , L_SETTLE_SPEED
                                   , VC_RIVALTRADER_NAME
                                   , VC_SELFTRADER_NAME
                                   , L_RIVALBANK_ID
                                   , L_BANK_ID
                                   , VC_QUOTE_ID
                                   , VC_OPERATOR_NAME
                                   , VC_DISBURSEMENT_ACCOUNT
                                   , VC_DISBURSEMENT_ACCOUNT_NAME
                                   , VC_SELF_PRODUCTS_NAME
                                   , VC_RIVAL_PRODUCTS_NAME
                                FROM ${o32_src_schema}.TDEPOSITRECEIPT"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "VC_INTER_NO", "type": "STRING"}, {"name": "VC_RECEIPT_NO", "type": "STRING"}, {"name": "VC_ACCOUNT_NO", "type": "STRING"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "VC_PLACE", "type": "STRING"}, {"name": "L_BANK", "type": "DOUBLE"}, {"name": "VC_MINOR_BANK", "type": "STRING"}, {"name": "VC_DEPOSIT_OWNER", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "L_LIMIT_TIME", "type": "DOUBLE"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_LAST_INTEREST_DATE", "type": "DOUBLE"}, {"name": "L_LAST_MOD_INTEREST_DATE", "type": "DOUBLE"}, {"name": "EN_TOTAL_INTEREST", "type": "DOUBLE"}, {"name": "EN_INTEREST", "type": "DOUBLE"}, {"name": "EN_PUNISH_INTEREST", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_CONFIRM_NO", "type": "DOUBLE"}, {"name": "L_DEPOSIT_CONFIRM_NO", "type": "DOUBLE"}, {"name": "L_NOTIFY_DAYS", "type": "DOUBLE"}, {"name": "EN_RECEIVABLE_INTEREST", "type": "DOUBLE"}, {"name": "C_AUTO_REDEPOSIT", "type": "STRING"}, {"name": "C_INTEREST_DEPOSIT", "type": "STRING"}, {"name": "C_RATE_TYPE", "type": "STRING"}, {"name": "C_INTEREST_PAY_TYPE", "type": "STRING"}, {"name": "C_DEPOSIT_TYPE", "type": "STRING"}, {"name": "EN_BASIC_RATE", "type": "DOUBLE"}, {"name": "C_DAY_TYPE", "type": "STRING"}, {"name": "C_FLOAT_TYPE", "type": "STRING"}, {"name": "L_INTEREST_PAY_DATE", "type": "DOUBLE"}, {"name": "C_INTEREST_PAY_FREQ", "type": "STRING"}, {"name": "C_RATE_CHANGE_TYPE", "type": "STRING"}, {"name": "C_ADVANCE_LIMIT_FLAG", "type": "STRING"}, {"name": "L_PAY_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_LIMIT_UNIT", "type": "STRING"}, {"name": "EN_ADVANCE_RATE", "type": "DOUBLE"}, {"name": "EN_PAYIN_BALANCE", "type": "DOUBLE"}, {"name": "EN_PRE_PAY_BALANCE", "type": "DOUBLE"}, {"name": "C_INPUT_TYPE", "type": "STRING"}, {"name": "L_ADVANCE_DATE", "type": "DOUBLE"}, {"name": "L_QS_CONFIRM_NO", "type": "DOUBLE"}, {"name": "VC_SECOND_DEPOSIT_NO", "type": "STRING"}, {"name": "L_ACCOUNT_ID", "type": "DOUBLE"}, {"name": "VC_BANK_BRANCH_CODE", "type": "STRING"}, {"name": "L_LAST_RATE_MOD_DATE", "type": "DOUBLE"}, {"name": "EN_MOD_RECEIVABLE_INTEREST", "type": "DOUBLE"}, {"name": "L_RE_PAY_INTEVAL", "type": "DOUBLE"}, {"name": "C_RE_PAY_INTEVAL_UNIT", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "L_FIRST_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_SETTLE_DELAY_TYPE", "type": "STRING"}, {"name": "C_PAY_DELAY_TYPE", "type": "STRING"}, {"name": "L_USE_DAYS", "type": "DOUBLE"}, {"name": "L_PRO_SETTLE_DATE", "type": "DOUBLE"}, {"name": "EN_UNSETTLE_INTREST_AMT", "type": "DOUBLE"}, {"name": "L_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_NAME", "type": "STRING"}, {"name": "VC_SELFTRADER_NAME", "type": "STRING"}, {"name": "L_RIVALBANK_ID", "type": "DOUBLE"}, {"name": "L_BANK_ID", "type": "DOUBLE"}, {"name": "VC_QUOTE_ID", "type": "STRING"}, {"name": "VC_OPERATOR_NAME", "type": "STRING"}, {"name": "VC_DISBURSEMENT_ACCOUNT", "type": "STRING"}, {"name": "VC_DISBURSEMENT_ACCOUNT_NAME", "type": "STRING"}, {"name": "VC_SELF_PRODUCTS_NAME", "type": "STRING"}, {"name": "VC_RIVAL_PRODUCTS_NAME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tdepositreceipt_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tdepositreceipt_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tdepositreceipt_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tdepositreceipt_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TDEPOSITRECEIPT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TDEPOSITRECEIPT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tdepositreceipt_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TDEPOSITRECEIPT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DATE
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_INTER_CODE
     , VC_INTER_NO
     , VC_RECEIPT_NO
     , VC_ACCOUNT_NO
     , VC_ACCOUNT_NAME
     , VC_PLACE
     , L_BANK
     , VC_MINOR_BANK
     , VC_DEPOSIT_OWNER
     , EN_BALANCE
     , EN_RATE
     , L_LIMIT_TIME
     , L_BEGIN_DATE
     , L_END_DATE
     , L_LAST_INTEREST_DATE
     , L_LAST_MOD_INTEREST_DATE
     , EN_TOTAL_INTEREST
     , EN_INTEREST
     , EN_PUNISH_INTEREST
     , VC_REMARK
     , C_STATUS
     , L_OPERATOR_NO
     , L_CONFIRM_NO
     , L_DEPOSIT_CONFIRM_NO
     , L_NOTIFY_DAYS
     , EN_RECEIVABLE_INTEREST
     , C_AUTO_REDEPOSIT
     , C_INTEREST_DEPOSIT
     , C_RATE_TYPE
     , C_INTEREST_PAY_TYPE
     , C_DEPOSIT_TYPE
     , EN_BASIC_RATE
     , C_DAY_TYPE
     , C_FLOAT_TYPE
     , L_INTEREST_PAY_DATE
     , C_INTEREST_PAY_FREQ
     , C_RATE_CHANGE_TYPE
     , C_ADVANCE_LIMIT_FLAG
     , L_PAY_SETTLE_DATE
     , C_LIMIT_UNIT
     , EN_ADVANCE_RATE
     , EN_PAYIN_BALANCE
     , EN_PRE_PAY_BALANCE
     , C_INPUT_TYPE
     , L_ADVANCE_DATE
     , L_QS_CONFIRM_NO
     , VC_SECOND_DEPOSIT_NO
     , L_ACCOUNT_ID
     , VC_BANK_BRANCH_CODE
     , L_LAST_RATE_MOD_DATE
     , EN_MOD_RECEIVABLE_INTEREST
     , L_RE_PAY_INTEVAL
     , C_RE_PAY_INTEVAL_UNIT
     , C_INVEST_TYPE
     , VC_DEAL_NO
     , C_MARKET_NO
     , L_FIRST_SETTLE_DATE
     , C_SETTLE_DELAY_TYPE
     , C_PAY_DELAY_TYPE
     , L_USE_DAYS
     , L_PRO_SETTLE_DATE
     , EN_UNSETTLE_INTREST_AMT
     , L_TRADE_RIVAL_NO
     , VC_RIVALTRADER_ID
     , L_SETTLE_SPEED
     , VC_RIVALTRADER_NAME
     , VC_SELFTRADER_NAME
     , L_RIVALBANK_ID
     , L_BANK_ID
     , VC_QUOTE_ID
     , VC_OPERATOR_NAME
     , VC_DISBURSEMENT_ACCOUNT
     , VC_DISBURSEMENT_ACCOUNT_NAME
     , VC_SELF_PRODUCTS_NAME
     , VC_RIVAL_PRODUCTS_NAME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TDEPOSITRECEIPT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TDEPOSITRECEIPT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TDEPOSITRECEIPT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TDEPOSITRECEIPT_PFD成功"
      exit 0
   fi
fi
