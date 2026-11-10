#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TRATEEXCHANGERECEIPT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TRATEEXCHANGERECEIPT_PFD_TMP(
  L_CONFIRM_NO  STRING  COMMENT  '确认编号',
  L_DATE  DECIMAL(8,0)  COMMENT  '互换日期',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  C_EXCHANGE_TYPE  STRING  COMMENT  '互换类型',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '名义本金',
  VC_LIMIT_TIME  STRING  COMMENT  '期限',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '起息日',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日',
  L_FIRST_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '首期起息日',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  L_TRADE_RIVAL_NO  DECIMAL(10,0)  COMMENT  '交易对手',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '执行人',
  EN_FEE  DECIMAL(16,2)  COMMENT  '费用',
  C_STATUS  STRING  COMMENT  '状态',
  VC_REMARK  STRING  COMMENT  '备注',
  C_OWNER_RATE_TYPE  STRING  COMMENT  '本方利率类型',
  EN_OWNER_RATE  DECIMAL(9,8)  COMMENT  '本方利率',
  VC_OWNER_PAY_PERIOD  STRING  COMMENT  '本方支付周期',
  C_OWNER_CALC_METHOD  STRING  COMMENT  '本方计息方法',
  C_OWNER_DAY_TYPE  STRING  COMMENT  '本方计息基准',
  VC_OWNER_RATE_PERIOD  STRING  COMMENT  '本方重置频率',
  L_OWNER_FIRST_RATE_DATE  DECIMAL(8,0)  COMMENT  '本方首次利率确定日',
  L_OWNER_FIRST_PAY_DATE  DECIMAL(8,0)  COMMENT  '本方首期定期支付日',
  C_OWNER_CALC_DAYS_TYPE  STRING  COMMENT  '本方计息天数调整',
  C_OWNER_PAY_DATE_TYPE  STRING  COMMENT  '本方支付日调整',
  C_OWNER_BAIL_CHANGEFLAG  STRING  COMMENT  '本方保证品变动标识',
  L_OWNER_BAIL_SUBMIT_DATE  DECIMAL(8,0)  COMMENT  '本方保证品提交日',
  C_RIVAL_RATE_TYPE  STRING  COMMENT  '对手方利率类型',
  EN_RIVAL_RATE  DECIMAL(9,8)  COMMENT  '对手方利率',
  VC_RIVAL_PAY_PERIOD  STRING  COMMENT  '对手方支付周期',
  C_RIVAL_CALC_METHOD  STRING  COMMENT  '对手方计息方法',
  C_RIVAL_DAY_TYPE  STRING  COMMENT  '对手方计息基准',
  VC_RIVAL_RATE_PERIOD  STRING  COMMENT  '对手方重置频率',
  L_RIVAL_FIRST_RATE_DATE  DECIMAL(8,0)  COMMENT  '对手方首次利率确定日',
  L_RIVAL_FIRST_PAY_DATE  DECIMAL(8,0)  COMMENT  '对手方首期定期支付日',
  C_RIVAL_CALC_DAYS_TYPE  STRING  COMMENT  '对手方计息天数调整',
  C_RIVAL_PAY_DATE_TYPE  STRING  COMMENT  '对手方支付日调整',
  C_RIVAL_BAIL_CHANGEFLAG  STRING  COMMENT  '对手方保证品变动标识',
  L_RIVAL_BAIL_SUBMIT_DATE  DECIMAL(8,0)  COMMENT  '对手方保证品提交日',
  VC_FROZEN_SERIAL_NOS  STRING  COMMENT  '保证品冻结序号串',
  EN_IRS_VALUE  DECIMAL(16,2)  COMMENT  '合约价值',
  EN_INTEREST_RECEIVABLE  DECIMAL(16,2)  COMMENT  '已计应收利息',
  EN_INTEREST_PAYABLE  DECIMAL(16,2)  COMMENT  '已计应付利息',
  EN_FIRST_BALANCE  DECIMAL(16,2)  COMMENT  '原始合约金额',
  L_BASIC_DATE  DECIMAL(8,0)  COMMENT  '提交日期',
  L_INPUT_DATE  DECIMAL(8,0)  COMMENT  '输入日期',
  C_SOURCE  STRING  COMMENT  '来源',
  C_LOCK_FLAG  STRING  COMMENT  '锁定标志',
  EN_PVBP  DECIMAL(16,2)  COMMENT  '基点价值dv1',
  EN_REMAINING_TIME  DECIMAL(6,4)  COMMENT  '剩余期限',
  L_RIVALACCOUNT_NO  DECIMAL(10,0)  COMMENT  '对手账号',
  VC_RIVALTRADER_ID  STRING  COMMENT  '对手id',
  L_BANK_ID  DECIMAL(10,0)  COMMENT  'l_bank_id',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司序号',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '#部门号',
  C_FIXSEND_FLAG  STRING  COMMENT  'FIX发送标志',
  VC_EXPORT_FLAG  STRING  COMMENT  '导出标志',
  VC_CONTRACT_NO  STRING  COMMENT  '合同编号',
  C_CHANNEL_TYPE  STRING  COMMENT  '',
  VC_CHANNEL_NAME  STRING  COMMENT  '通道名称',
  EN_RATE_ZJ  DECIMAL(12,8)  COMMENT  '',
  EN_RATE_DFZJ  DECIMAL(12,8)  COMMENT  '',
  VC_SCHEMA_NO  STRING  COMMENT  '',
  C_UNDERTAKE_FLAG  STRING  COMMENT  '',
  L_ORIGINAL_RIVAL_NO  DECIMAL(10,0)  COMMENT  '',
  L_INSIDER_TRADING_NO  DECIMAL(10,0)  COMMENT  '内部交易号',
  VC_QUOTE_ID  STRING  COMMENT  '报价单号',
  C_TRADE_METHOD  STRING  COMMENT  '交易方式',
  L_AFFILIATION  STRING  COMMENT  '交易目的编号',
  VC_UNIQUE_DEAL_SERIAL_NO  STRING  COMMENT  '对接外部系统唯一成交标识'
)
COMMENT '在途利率互换信息表'
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
              "querySql": ["SELECT  L_CONFIRM_NO
                                   , L_DATE
                                   , VC_DEAL_NO
                                   , C_EXCHANGE_TYPE
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_INTER_CODE
                                   , EN_BALANCE
                                   , VC_LIMIT_TIME
                                   , L_BEGIN_DATE
                                   , L_END_DATE
                                   , L_FIRST_BEGIN_DATE
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INDEX_DAILY_MODIFY
                                   , L_TRADE_RIVAL_NO
                                   , L_OPERATOR_NO
                                   , EN_FEE
                                   , C_STATUS
                                   , VC_REMARK
                                   , C_OWNER_RATE_TYPE
                                   , EN_OWNER_RATE
                                   , VC_OWNER_PAY_PERIOD
                                   , C_OWNER_CALC_METHOD
                                   , C_OWNER_DAY_TYPE
                                   , VC_OWNER_RATE_PERIOD
                                   , L_OWNER_FIRST_RATE_DATE
                                   , L_OWNER_FIRST_PAY_DATE
                                   , C_OWNER_CALC_DAYS_TYPE
                                   , C_OWNER_PAY_DATE_TYPE
                                   , C_OWNER_BAIL_CHANGEFLAG
                                   , L_OWNER_BAIL_SUBMIT_DATE
                                   , C_RIVAL_RATE_TYPE
                                   , EN_RIVAL_RATE
                                   , VC_RIVAL_PAY_PERIOD
                                   , C_RIVAL_CALC_METHOD
                                   , C_RIVAL_DAY_TYPE
                                   , VC_RIVAL_RATE_PERIOD
                                   , L_RIVAL_FIRST_RATE_DATE
                                   , L_RIVAL_FIRST_PAY_DATE
                                   , C_RIVAL_CALC_DAYS_TYPE
                                   , C_RIVAL_PAY_DATE_TYPE
                                   , C_RIVAL_BAIL_CHANGEFLAG
                                   , L_RIVAL_BAIL_SUBMIT_DATE
                                   , VC_FROZEN_SERIAL_NOS
                                   , EN_IRS_VALUE
                                   , EN_INTEREST_RECEIVABLE
                                   , EN_INTEREST_PAYABLE
                                   , EN_FIRST_BALANCE
                                   , L_BASIC_DATE
                                   , L_INPUT_DATE
                                   , C_SOURCE
                                   , C_LOCK_FLAG
                                   , EN_PVBP
                                   , EN_REMAINING_TIME
                                   , L_RIVALACCOUNT_NO
                                   , VC_RIVALTRADER_ID
                                   , L_BANK_ID
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , C_FIXSEND_FLAG
                                   , VC_EXPORT_FLAG
                                   , VC_CONTRACT_NO
                                   , C_CHANNEL_TYPE
                                   , VC_CHANNEL_NAME
                                   , EN_RATE_ZJ
                                   , EN_RATE_DFZJ
                                   , VC_SCHEMA_NO
                                   , C_UNDERTAKE_FLAG
                                   , L_ORIGINAL_RIVAL_NO
                                   , L_INSIDER_TRADING_NO
                                   , VC_QUOTE_ID
                                   , C_TRADE_METHOD
                                   , L_AFFILIATION
                                   , VC_UNIQUE_DEAL_SERIAL_NO
                                FROM ${o32_src_schema}.THISRATEEXCHANGERECEIPT"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_CONFIRM_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "C_EXCHANGE_TYPE", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "VC_LIMIT_TIME", "type": "STRING"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_FIRST_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_OWNER_RATE_TYPE", "type": "STRING"}, {"name": "EN_OWNER_RATE", "type": "DOUBLE"}, {"name": "VC_OWNER_PAY_PERIOD", "type": "STRING"}, {"name": "C_OWNER_CALC_METHOD", "type": "STRING"}, {"name": "C_OWNER_DAY_TYPE", "type": "STRING"}, {"name": "VC_OWNER_RATE_PERIOD", "type": "STRING"}, {"name": "L_OWNER_FIRST_RATE_DATE", "type": "DOUBLE"}, {"name": "L_OWNER_FIRST_PAY_DATE", "type": "DOUBLE"}, {"name": "C_OWNER_CALC_DAYS_TYPE", "type": "STRING"}, {"name": "C_OWNER_PAY_DATE_TYPE", "type": "STRING"}, {"name": "C_OWNER_BAIL_CHANGEFLAG", "type": "STRING"}, {"name": "L_OWNER_BAIL_SUBMIT_DATE", "type": "DOUBLE"}, {"name": "C_RIVAL_RATE_TYPE", "type": "STRING"}, {"name": "EN_RIVAL_RATE", "type": "DOUBLE"}, {"name": "VC_RIVAL_PAY_PERIOD", "type": "STRING"}, {"name": "C_RIVAL_CALC_METHOD", "type": "STRING"}, {"name": "C_RIVAL_DAY_TYPE", "type": "STRING"}, {"name": "VC_RIVAL_RATE_PERIOD", "type": "STRING"}, {"name": "L_RIVAL_FIRST_RATE_DATE", "type": "DOUBLE"}, {"name": "L_RIVAL_FIRST_PAY_DATE", "type": "DOUBLE"}, {"name": "C_RIVAL_CALC_DAYS_TYPE", "type": "STRING"}, {"name": "C_RIVAL_PAY_DATE_TYPE", "type": "STRING"}, {"name": "C_RIVAL_BAIL_CHANGEFLAG", "type": "STRING"}, {"name": "L_RIVAL_BAIL_SUBMIT_DATE", "type": "DOUBLE"}, {"name": "VC_FROZEN_SERIAL_NOS", "type": "STRING"}, {"name": "EN_IRS_VALUE", "type": "DOUBLE"}, {"name": "EN_INTEREST_RECEIVABLE", "type": "DOUBLE"}, {"name": "EN_INTEREST_PAYABLE", "type": "DOUBLE"}, {"name": "EN_FIRST_BALANCE", "type": "DOUBLE"}, {"name": "L_BASIC_DATE", "type": "DOUBLE"}, {"name": "L_INPUT_DATE", "type": "DOUBLE"}, {"name": "C_SOURCE", "type": "STRING"}, {"name": "C_LOCK_FLAG", "type": "STRING"}, {"name": "EN_PVBP", "type": "DOUBLE"}, {"name": "EN_REMAINING_TIME", "type": "DOUBLE"}, {"name": "L_RIVALACCOUNT_NO", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "L_BANK_ID", "type": "DOUBLE"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "C_FIXSEND_FLAG", "type": "STRING"}, {"name": "VC_EXPORT_FLAG", "type": "STRING"}, {"name": "VC_CONTRACT_NO", "type": "STRING"}, {"name": "C_CHANNEL_TYPE", "type": "STRING"}, {"name": "VC_CHANNEL_NAME", "type": "STRING"}, {"name": "EN_RATE_ZJ", "type": "DOUBLE"}, {"name": "EN_RATE_DFZJ", "type": "DOUBLE"}, {"name": "VC_SCHEMA_NO", "type": "STRING"}, {"name": "C_UNDERTAKE_FLAG", "type": "STRING"}, {"name": "L_ORIGINAL_RIVAL_NO", "type": "DOUBLE"}, {"name": "L_INSIDER_TRADING_NO", "type": "DOUBLE"}, {"name": "VC_QUOTE_ID", "type": "STRING"}, {"name": "C_TRADE_METHOD", "type": "STRING"}, {"name": "L_AFFILIATION", "type": "DOUBLE"}, {"name": "VC_UNIQUE_DEAL_SERIAL_NO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_trateexchangereceipt_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_trateexchangereceipt_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_trateexchangereceipt_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_trateexchangereceipt_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TRATEEXCHANGERECEIPT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TRATEEXCHANGERECEIPT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_trateexchangereceipt_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TRATEEXCHANGERECEIPT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_CONFIRM_NO
     , L_DATE
     , VC_DEAL_NO
     , C_EXCHANGE_TYPE
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_INTER_CODE
     , EN_BALANCE
     , VC_LIMIT_TIME
     , L_BEGIN_DATE
     , L_END_DATE
     , L_FIRST_BEGIN_DATE
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , L_TRADE_RIVAL_NO
     , L_OPERATOR_NO
     , EN_FEE
     , C_STATUS
     , VC_REMARK
     , C_OWNER_RATE_TYPE
     , EN_OWNER_RATE
     , VC_OWNER_PAY_PERIOD
     , C_OWNER_CALC_METHOD
     , C_OWNER_DAY_TYPE
     , VC_OWNER_RATE_PERIOD
     , L_OWNER_FIRST_RATE_DATE
     , L_OWNER_FIRST_PAY_DATE
     , C_OWNER_CALC_DAYS_TYPE
     , C_OWNER_PAY_DATE_TYPE
     , C_OWNER_BAIL_CHANGEFLAG
     , L_OWNER_BAIL_SUBMIT_DATE
     , C_RIVAL_RATE_TYPE
     , EN_RIVAL_RATE
     , VC_RIVAL_PAY_PERIOD
     , C_RIVAL_CALC_METHOD
     , C_RIVAL_DAY_TYPE
     , VC_RIVAL_RATE_PERIOD
     , L_RIVAL_FIRST_RATE_DATE
     , L_RIVAL_FIRST_PAY_DATE
     , C_RIVAL_CALC_DAYS_TYPE
     , C_RIVAL_PAY_DATE_TYPE
     , C_RIVAL_BAIL_CHANGEFLAG
     , L_RIVAL_BAIL_SUBMIT_DATE
     , VC_FROZEN_SERIAL_NOS
     , EN_IRS_VALUE
     , EN_INTEREST_RECEIVABLE
     , EN_INTEREST_PAYABLE
     , EN_FIRST_BALANCE
     , L_BASIC_DATE
     , L_INPUT_DATE
     , C_SOURCE
     , C_LOCK_FLAG
     , EN_PVBP
     , EN_REMAINING_TIME
     , L_RIVALACCOUNT_NO
     , VC_RIVALTRADER_ID
     , L_BANK_ID
     , L_ORG_ID
     , L_DEPT_ID
     , C_FIXSEND_FLAG
     , VC_EXPORT_FLAG
     , VC_CONTRACT_NO
     , C_CHANNEL_TYPE
     , VC_CHANNEL_NAME
     , EN_RATE_ZJ
     , EN_RATE_DFZJ
     , VC_SCHEMA_NO
     , C_UNDERTAKE_FLAG
     , L_ORIGINAL_RIVAL_NO
     , L_INSIDER_TRADING_NO
     , VC_QUOTE_ID
     , C_TRADE_METHOD
     , L_AFFILIATION
     , VC_UNIQUE_DEAL_SERIAL_NO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TRATEEXCHANGERECEIPT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TRATEEXCHANGERECEIPT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TRATEEXCHANGERECEIPT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TRATEEXCHANGERECEIPT_PFD成功"
      exit 0
   fi
fi
