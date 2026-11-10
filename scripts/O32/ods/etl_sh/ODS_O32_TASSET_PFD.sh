#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TASSET_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TASSET_PFD_TMP(
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  VC_ASSET_NAME  STRING  COMMENT  '资产单元名称',
  C_OVERDRAFT  STRING  COMMENT  '可否透支',
  VC_REMARKS  STRING  COMMENT  '备注',
  L_ACCOUNT_ID  DECIMAL(10,0)  COMMENT  '账户序号',
  L_SECURITIES_BRANCH  DECIMAL(10,0)  COMMENT  '分仓营业部',
  VC_CAPITAL_ACCOUNT  STRING  COMMENT  '资金账号',
  VC_CAPITAL_PASSWORD  STRING  COMMENT  '资金账号密码',
  VC_BANK_NAME  STRING  COMMENT  '开户行名称',
  VC_ACCOUNT_NAME  STRING  COMMENT  '开户名',
  L_LOCAL_CUSTODIAN  DECIMAL(10,0)  COMMENT  '托管行',
  VC_BANK_ACCOUNT  STRING  COMMENT  '银行帐号',
  C_TRUST  STRING  COMMENT  '是否托管',
  C_ASSET_TYPE  STRING  COMMENT  '资产类型',
  VC_ASSET_NO  STRING  COMMENT  '资产单元编号',
  VC_FA_ACCOUNT_NO  STRING  COMMENT  '分组估值账套编号',
  VC_INTRABANK_NO  STRING  COMMENT  '联行号',
  VC_PAY_NO  STRING  COMMENT  '支付系统号',
  C_CASH_POOL  STRING  COMMENT  '是否资金池',
  L_TRANSFER_ORDER  DECIMAL(4,0)  COMMENT  '划转顺序',
  C_CASH_AVAILABLE_TYPE  STRING  COMMENT  '资金可用值类型',
  EN_CASH_AVAILABLE_VALUE  DECIMAL(18,4)  COMMENT  't+0可用目标值',
  L_SECURITIES_BRANCH_QH  DECIMAL(10,0)  COMMENT  '期货营业部',
  VC_CAPITAL_ACCOUNT_QH  STRING  COMMENT  '期货营业部资金账号',
  VC_CAPITAL_PASSWORD_QH  STRING  COMMENT  '期货营业部资金帐号密码',
  C_ASSET_STATUS  STRING  COMMENT  '资产单元状态',
  L_CASH_CONF_DATE  DECIMAL(8,0)  COMMENT  '资金配置更新日期',
  L_CASH_CONF_TIME  DECIMAL(6,0)  COMMENT  '资金配置更新时间',
  VC_BANK_LINKMAN  STRING  COMMENT  '银行联系人',
  VC_BANK_PHONE  STRING  COMMENT  '银行联系电话',
  VC_BANK_FAX  STRING  COMMENT  '银行传真',
  VC_PROVINCECODE  STRING  COMMENT  '省份',
  VC_CITY  STRING  COMMENT  '城市',
  VC_INSTR_BRANCH_ORGAN  STRING  COMMENT  '指令分仓机构',
  VC_INVEST_OVERDRAFT  STRING  COMMENT  '投资时允许透支的业务',
  C_FUTUER_LIQUIDATION  STRING  COMMENT  '是否参与期货自动平仓',
  C_FUTUER_LIQUIDATION_STATUS  STRING  COMMENT  '期货自动平仓状态',
  C_INVEST_AREA  STRING  COMMENT  '投资区域',
  C_THIRD_PARTY_CUSTODY  STRING  COMMENT  '是否三方存管',
  C_CAPITAL_ACCOUNT_FLAG  STRING  COMMENT  '分仓数据导入状态',
  C_CAPITAL_ACCOUNT_FLAG_QH  STRING  COMMENT  '期货分仓数据导入状态',
  C_T1_CASH_AVAILABLE_TYPE  STRING  COMMENT  't+1资金可用值类型',
  EN_T1_CASH_AVAILABLE_VALUE  DECIMAL(18,4)  COMMENT  't+1可用目标值',
  C_CREDIT_ASSET  STRING  COMMENT  '资产单元属性',
  C_CAPITAL_RZRQ_FLAG  STRING  COMMENT  '融资融券负债导入状态字段',
  C_UFT_TRADE  STRING  COMMENT  '是否极速交易',
  C_BRANCH_ADJUST_FLAG  STRING  COMMENT  '现货分仓调整标志',
  C_BRANCH_ADJUST_FLAG_QH  STRING  COMMENT  '期货分仓调整标志',
  C_INSTR_AUTO  STRING  COMMENT  '现货指令接入模式',
  C_FUTURE_INSTR_AUTO  STRING  COMMENT  '期货指令接入模式',
  C_ENTRUST_AUTO  STRING  COMMENT  '现货交易接入模式',
  C_FUTURE_ENTRUST_AUTO  STRING  COMMENT  '期货交易接入模式',
  L_SET_ID  DECIMAL(4,0)  COMMENT  '费用套序号',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  VC_SELF_MARGIN_ACCOUNT  STRING  COMMENT  '自营业务资金保证金账户',
  VC_FUTURE_MORT_ACCOUNT  STRING  COMMENT  '',
  VC_OTC_BALANCE_ACCOUNT  STRING  COMMENT  '',
  VC_INVEST_SPONSORS  STRING  COMMENT  '投资赞助商',
  C_TRADE_PLACE  STRING  COMMENT  '交易地点',
  L_SETUP_DATE  DECIMAL(8,0)  COMMENT  '安装日期',
  L_DVP_ASSET_ID  DECIMAL(8,0)  COMMENT  '',
  C_GUARANTEE  STRING  COMMENT  '',
  C_UST_TRADE  STRING  COMMENT  '',
  VC_OVERDRAFT_DIRECTION  STRING  COMMENT  '透支方向',
  C_ALLOW_AU_TRADE  STRING  COMMENT  '',
  VC_AUTOEXEC_DIRECTION  STRING  COMMENT  '',
  C_CASH_TRANSBALA_TYPE  STRING  COMMENT  '',
  C_MUST_ADVANCE_ARRIVAL  STRING  COMMENT  '',
  EN_ADVANCE_ARRIVAL_RATE  DECIMAL(6,4)  COMMENT  '',
  C_INTFLOW_BALANCE_ENABLE  STRING  COMMENT  ''
)
COMMENT '资产单元基本信息表'
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
              "querySql": ["SELECT  L_ASSET_ID
                                   , L_FUND_ID
                                   , VC_ASSET_NAME
                                   , C_OVERDRAFT
                                   , VC_REMARKS
                                   , L_ACCOUNT_ID
                                   , L_SECURITIES_BRANCH
                                   , VC_CAPITAL_ACCOUNT
                                   , VC_CAPITAL_PASSWORD
                                   , VC_BANK_NAME
                                   , VC_ACCOUNT_NAME
                                   , L_LOCAL_CUSTODIAN
                                   , VC_BANK_ACCOUNT
                                   , C_TRUST
                                   , C_ASSET_TYPE
                                   , VC_ASSET_NO
                                   , VC_FA_ACCOUNT_NO
                                   , VC_INTRABANK_NO
                                   , VC_PAY_NO
                                   , C_CASH_POOL
                                   , L_TRANSFER_ORDER
                                   , C_CASH_AVAILABLE_TYPE
                                   , EN_CASH_AVAILABLE_VALUE
                                   , L_SECURITIES_BRANCH_QH
                                   , VC_CAPITAL_ACCOUNT_QH
                                   , VC_CAPITAL_PASSWORD_QH
                                   , C_ASSET_STATUS
                                   , L_CASH_CONF_DATE
                                   , L_CASH_CONF_TIME
                                   , VC_BANK_LINKMAN
                                   , VC_BANK_PHONE
                                   , VC_BANK_FAX
                                   , VC_PROVINCECODE
                                   , VC_CITY
                                   , VC_INSTR_BRANCH_ORGAN
                                   , VC_INVEST_OVERDRAFT
                                   , C_FUTUER_LIQUIDATION
                                   , C_FUTUER_LIQUIDATION_STATUS
                                   , C_INVEST_AREA
                                   , C_THIRD_PARTY_CUSTODY
                                   , C_CAPITAL_ACCOUNT_FLAG
                                   , C_CAPITAL_ACCOUNT_FLAG_QH
                                   , C_T1_CASH_AVAILABLE_TYPE
                                   , EN_T1_CASH_AVAILABLE_VALUE
                                   , C_CREDIT_ASSET
                                   , C_CAPITAL_RZRQ_FLAG
                                   , C_UFT_TRADE
                                   , C_BRANCH_ADJUST_FLAG
                                   , C_BRANCH_ADJUST_FLAG_QH
                                   , C_INSTR_AUTO
                                   , C_FUTURE_INSTR_AUTO
                                   , C_ENTRUST_AUTO
                                   , C_FUTURE_ENTRUST_AUTO
                                   , L_SET_ID
                                   , VC_TIMESTAMP
                                   , VC_SELF_MARGIN_ACCOUNT
                                   , VC_FUTURE_MORT_ACCOUNT
                                   , VC_OTC_BALANCE_ACCOUNT
                                   , VC_INVEST_SPONSORS
                                   , C_TRADE_PLACE
                                   , L_SETUP_DATE
                                   , L_DVP_ASSET_ID
                                   , C_GUARANTEE
                                   , C_UST_TRADE
                                   , VC_OVERDRAFT_DIRECTION
                                   , C_ALLOW_AU_TRADE
                                   , VC_AUTOEXEC_DIRECTION
                                   , C_CASH_TRANSBALA_TYPE
                                   , C_MUST_ADVANCE_ARRIVAL
                                   , EN_ADVANCE_ARRIVAL_RATE
                                   , C_INTFLOW_BALANCE_ENABLE
                                FROM ${o32_src_schema}.TASSET"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_ASSET_NAME", "type": "STRING"}, {"name": "C_OVERDRAFT", "type": "STRING"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "L_ACCOUNT_ID", "type": "DOUBLE"}, {"name": "L_SECURITIES_BRANCH", "type": "DOUBLE"}, {"name": "VC_CAPITAL_ACCOUNT", "type": "STRING"}, {"name": "VC_CAPITAL_PASSWORD", "type": "STRING"}, {"name": "VC_BANK_NAME", "type": "STRING"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "L_LOCAL_CUSTODIAN", "type": "DOUBLE"}, {"name": "VC_BANK_ACCOUNT", "type": "STRING"}, {"name": "C_TRUST", "type": "STRING"}, {"name": "C_ASSET_TYPE", "type": "STRING"}, {"name": "VC_ASSET_NO", "type": "STRING"}, {"name": "VC_FA_ACCOUNT_NO", "type": "STRING"}, {"name": "VC_INTRABANK_NO", "type": "STRING"}, {"name": "VC_PAY_NO", "type": "STRING"}, {"name": "C_CASH_POOL", "type": "STRING"}, {"name": "L_TRANSFER_ORDER", "type": "DOUBLE"}, {"name": "C_CASH_AVAILABLE_TYPE", "type": "STRING"}, {"name": "EN_CASH_AVAILABLE_VALUE", "type": "DOUBLE"}, {"name": "L_SECURITIES_BRANCH_QH", "type": "DOUBLE"}, {"name": "VC_CAPITAL_ACCOUNT_QH", "type": "STRING"}, {"name": "VC_CAPITAL_PASSWORD_QH", "type": "STRING"}, {"name": "C_ASSET_STATUS", "type": "STRING"}, {"name": "L_CASH_CONF_DATE", "type": "DOUBLE"}, {"name": "L_CASH_CONF_TIME", "type": "DOUBLE"}, {"name": "VC_BANK_LINKMAN", "type": "STRING"}, {"name": "VC_BANK_PHONE", "type": "STRING"}, {"name": "VC_BANK_FAX", "type": "STRING"}, {"name": "VC_PROVINCECODE", "type": "STRING"}, {"name": "VC_CITY", "type": "STRING"}, {"name": "VC_INSTR_BRANCH_ORGAN", "type": "STRING"}, {"name": "VC_INVEST_OVERDRAFT", "type": "STRING"}, {"name": "C_FUTUER_LIQUIDATION", "type": "STRING"}, {"name": "C_FUTUER_LIQUIDATION_STATUS", "type": "STRING"}, {"name": "C_INVEST_AREA", "type": "STRING"}, {"name": "C_THIRD_PARTY_CUSTODY", "type": "STRING"}, {"name": "C_CAPITAL_ACCOUNT_FLAG", "type": "STRING"}, {"name": "C_CAPITAL_ACCOUNT_FLAG_QH", "type": "STRING"}, {"name": "C_T1_CASH_AVAILABLE_TYPE", "type": "STRING"}, {"name": "EN_T1_CASH_AVAILABLE_VALUE", "type": "DOUBLE"}, {"name": "C_CREDIT_ASSET", "type": "STRING"}, {"name": "C_CAPITAL_RZRQ_FLAG", "type": "STRING"}, {"name": "C_UFT_TRADE", "type": "STRING"}, {"name": "C_BRANCH_ADJUST_FLAG", "type": "STRING"}, {"name": "C_BRANCH_ADJUST_FLAG_QH", "type": "STRING"}, {"name": "C_INSTR_AUTO", "type": "STRING"}, {"name": "C_FUTURE_INSTR_AUTO", "type": "STRING"}, {"name": "C_ENTRUST_AUTO", "type": "STRING"}, {"name": "C_FUTURE_ENTRUST_AUTO", "type": "STRING"}, {"name": "L_SET_ID", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "VC_SELF_MARGIN_ACCOUNT", "type": "STRING"}, {"name": "VC_FUTURE_MORT_ACCOUNT", "type": "STRING"}, {"name": "VC_OTC_BALANCE_ACCOUNT", "type": "STRING"}, {"name": "VC_INVEST_SPONSORS", "type": "STRING"}, {"name": "C_TRADE_PLACE", "type": "STRING"}, {"name": "L_SETUP_DATE", "type": "DOUBLE"}, {"name": "L_DVP_ASSET_ID", "type": "DOUBLE"}, {"name": "C_GUARANTEE", "type": "STRING"}, {"name": "C_UST_TRADE", "type": "STRING"}, {"name": "VC_OVERDRAFT_DIRECTION", "type": "STRING"}, {"name": "C_ALLOW_AU_TRADE", "type": "STRING"}, {"name": "VC_AUTOEXEC_DIRECTION", "type": "STRING"}, {"name": "C_CASH_TRANSBALA_TYPE", "type": "STRING"}, {"name": "C_MUST_ADVANCE_ARRIVAL", "type": "STRING"}, {"name": "EN_ADVANCE_ARRIVAL_RATE", "type": "DOUBLE"}, {"name": "C_INTFLOW_BALANCE_ENABLE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tasset_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tasset_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tasset_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tasset_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TASSET_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TASSET_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tasset_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TASSET_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ASSET_ID
     , L_FUND_ID
     , VC_ASSET_NAME
     , C_OVERDRAFT
     , VC_REMARKS
     , L_ACCOUNT_ID
     , L_SECURITIES_BRANCH
     , VC_CAPITAL_ACCOUNT
     , VC_CAPITAL_PASSWORD
     , VC_BANK_NAME
     , VC_ACCOUNT_NAME
     , L_LOCAL_CUSTODIAN
     , VC_BANK_ACCOUNT
     , C_TRUST
     , C_ASSET_TYPE
     , VC_ASSET_NO
     , VC_FA_ACCOUNT_NO
     , VC_INTRABANK_NO
     , VC_PAY_NO
     , C_CASH_POOL
     , L_TRANSFER_ORDER
     , C_CASH_AVAILABLE_TYPE
     , EN_CASH_AVAILABLE_VALUE
     , L_SECURITIES_BRANCH_QH
     , VC_CAPITAL_ACCOUNT_QH
     , VC_CAPITAL_PASSWORD_QH
     , C_ASSET_STATUS
     , L_CASH_CONF_DATE
     , L_CASH_CONF_TIME
     , VC_BANK_LINKMAN
     , VC_BANK_PHONE
     , VC_BANK_FAX
     , VC_PROVINCECODE
     , VC_CITY
     , VC_INSTR_BRANCH_ORGAN
     , VC_INVEST_OVERDRAFT
     , C_FUTUER_LIQUIDATION
     , C_FUTUER_LIQUIDATION_STATUS
     , C_INVEST_AREA
     , C_THIRD_PARTY_CUSTODY
     , C_CAPITAL_ACCOUNT_FLAG
     , C_CAPITAL_ACCOUNT_FLAG_QH
     , C_T1_CASH_AVAILABLE_TYPE
     , EN_T1_CASH_AVAILABLE_VALUE
     , C_CREDIT_ASSET
     , C_CAPITAL_RZRQ_FLAG
     , C_UFT_TRADE
     , C_BRANCH_ADJUST_FLAG
     , C_BRANCH_ADJUST_FLAG_QH
     , C_INSTR_AUTO
     , C_FUTURE_INSTR_AUTO
     , C_ENTRUST_AUTO
     , C_FUTURE_ENTRUST_AUTO
     , L_SET_ID
     , VC_TIMESTAMP
     , VC_SELF_MARGIN_ACCOUNT
     , VC_FUTURE_MORT_ACCOUNT
     , VC_OTC_BALANCE_ACCOUNT
     , VC_INVEST_SPONSORS
     , C_TRADE_PLACE
     , L_SETUP_DATE
     , L_DVP_ASSET_ID
     , C_GUARANTEE
     , C_UST_TRADE
     , VC_OVERDRAFT_DIRECTION
     , C_ALLOW_AU_TRADE
     , VC_AUTOEXEC_DIRECTION
     , C_CASH_TRANSBALA_TYPE
     , C_MUST_ADVANCE_ARRIVAL
     , EN_ADVANCE_ARRIVAL_RATE
     , C_INTFLOW_BALANCE_ENABLE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TASSET_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TASSET_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TASSET_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TASSET_PFD成功"
      exit 0
   fi
fi
