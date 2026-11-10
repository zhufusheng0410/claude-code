#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TOUTCONFIRM_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TOUTCONFIRM_PTD_TMP(
  L_CONFIRM_NO  STRING  COMMENT  '确认编号',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_TIME  DECIMAL(6,0)  COMMENT  '确认时间',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  L_BUSIN_FLAG  DECIMAL(8,0)  COMMENT  '业务类别',
  C_BUSIN_CLASS  STRING  COMMENT  '业务分类',
  C_BUSIN_PRO_TYPE  STRING  COMMENT  '业务过程分类',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '组合序号',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_MARKET_NO  STRING  COMMENT  '市场代码',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '金额',
  EN_CBALANCE  DECIMAL(16,2)  COMMENT  '定金金额',
  EN_AMOUNT  DECIMAL(20,4)  COMMENT  '数量',
  EN_PRICE  DECIMAL(16,8)  COMMENT  '价格',
  EN_FEE_RATIO  DECIMAL(11,10)  COMMENT  '费率',
  EN_FEE  DECIMAL(12,2)  COMMENT  '费用',
  C_DEAL_STATUS  STRING  COMMENT  '成交状态',
  C_STATUS  STRING  COMMENT  '状态',
  D_DATETIME  STRING  COMMENT  '时间戳',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '操作员',
  C_EXCEED_FLAG  STRING  COMMENT  '巨额赎回处理标志',
  VC_IN_INTERCODE  STRING  COMMENT  '转入证券代码',
  L_RIVAL_ID  DECIMAL(10,0)  COMMENT  '交易对手',
  C_SETTLE_TYPE  STRING  COMMENT  '结算方式',
  EN_INTEREST  DECIMAL(16,2)  COMMENT  '利息',
  C_FEE_DEAL_TYPE  STRING  COMMENT  '手续费处理方式',
  VC_REMARK  STRING  COMMENT  '备注',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东',
  VC_SEAT_ID  STRING  COMMENT  '席位',
  L_EXECCONFIRM_NO  STRING  COMMENT  '执行确认编号',
  VC_ATTACHED_WARRANT_CODE  STRING  COMMENT  '附送权证代码',
  EN_WARRANT_AMOUNT  DECIMAL(16,2)  COMMENT  '附送权证数量',
  L_WARRANT_COMBI  DECIMAL(10,0)  COMMENT  '权证入账组合',
  L_CONFIRM_DATE  DECIMAL(8,0)  COMMENT  '确认日期',
  L_DEAL_DATE  DECIMAL(8,0)  COMMENT  '成交日期',
  L_IN_COMBI_ID  DECIMAL(10,0)  COMMENT  '转入组合序号',
  VC_IN_STOCKHOLDER_ID  STRING  COMMENT  '转入股东代码',
  VC_IN_SEAT_ID  STRING  COMMENT  '转入席位代码',
  C_WARRANT_INVEST_TYPE  STRING  COMMENT  '附送权证的投资类型',
  C_EXTERNAL_DEAL_FLAG  STRING  COMMENT  '外部处理标志',
  EN_DOWN_PRICE  DECIMAL(16,8)  COMMENT  '下限价格',
  EN_COMMISSION  DECIMAL(16,2)  COMMENT  '佣金',
  L_DIRECT_DATE  DECIMAL(8,0)  COMMENT  '指令下达日期',
  L_DIRECT_OPERATOR  DECIMAL(8,0)  COMMENT  '指令下达人',
  L_APPROVE_DATE  DECIMAL(8,0)  COMMENT  '指令审批日期',
  L_APPROVE_OPERATOR  DECIMAL(8,0)  COMMENT  '指令审批人',
  L_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '到账日期',
  C_ENTRUST_STATUS  STRING  COMMENT  '委托状态',
  L_BATCH_SERIAL_NO  DECIMAL(10,0)  COMMENT  '批号',
  C_IN_INVEST_TYPE  STRING  COMMENT  '转入投资类型',
  C_CHANNEL_NO  STRING  COMMENT  '通道',
  VC_ERROR_MSG  STRING  COMMENT  '报单错误信息',
  C_CANCEL_STATUS  STRING  COMMENT  '撤销状态',
  VC_CANCEL_ERROR_MSG  STRING  COMMENT  '撤销错误信息',
  EN_PRICE1  DECIMAL(16,8)  COMMENT  '价格1',
  EN_PRICE2  DECIMAL(16,8)  COMMENT  '价格2',
  VC_MINOR_BANK  STRING  COMMENT  '分支银行',
  VC_ACCOUNT_NO  STRING  COMMENT  '账户编号',
  VC_ACCOUNT_NAME  STRING  COMMENT  '账户名称',
  L_FA_CONFIRM_DATE  DECIMAL(8,0)  COMMENT  '财务到账日期',
  C_FIXSEND_FLAG  STRING  COMMENT  'fix发生标志',
  L_INSTR_DATE  DECIMAL(8,0)  COMMENT  '结算指令日期',
  VC_INSTRID  STRING  COMMENT  '结算指令标识号',
  L_STOCK_SERIAL_NO  DECIMAL(10,0)  COMMENT  '指令确认序号',
  VC_RIVALTRADER_NAME  STRING  COMMENT  '对手方交易员中文名称',
  L_RIVALACCOUNT_NO  DECIMAL(10,0)  COMMENT  '对手方银行账户序号',
  VC_RIVAL_BANK_ACCOUNT  STRING  COMMENT  '对手银行间托管帐号',
  EN_PREPAY_BALANCE  DECIMAL(16,2)  COMMENT  '预扣款金额',
  VC_CONFIRM_NO  STRING  COMMENT  '确认号',
  L_OLD_CONFIRM_NO  DECIMAL(10,0)  COMMENT  '原存单确认号',
  L_OLD_DEPOSIT_CONFIRM_NO  DECIMAL(10,0)  COMMENT  '原存单序号',
  VC_RIVALTRADER_ID  STRING  COMMENT  '交易对手id',
  L_OLD_PAY_DATE  DECIMAL(8,0)  COMMENT  '原实际收息日期',
  EN_RECEIVABLE_INTEREST  DECIMAL(16,2)  COMMENT  '原应收利息',
  EN_PUNISH_INTEREST  DECIMAL(16,2)  COMMENT  '罚息金额',
  EN_RECEIVED  DECIMAL(16,2)  COMMENT  '原收取本金',
  C_ZXRECEIVE_STATUS  STRING  COMMENT  '直销接收状态',
  L_CANCEL_NO  DECIMAL(10,0)  COMMENT  '撤单订单号内部',
  VC_ZXORDER_NO  STRING  COMMENT  '直销订单号',
  C_ZXCANCEL_STATUS  STRING  COMMENT  '直销撤销状态',
  C_FUNDCHECK_STATUS  STRING  COMMENT  '资金校验状态',
  VC_ZXCANCEL_NO  STRING  COMMENT  '直销撤单号',
  C_TA_STATUS  STRING  COMMENT  'ta确认状态',
  VC_TA_NO  STRING  COMMENT  'ta确认编号',
  C_FEE_TYPE  STRING  COMMENT  '收费方式',
  VC_FUND_ACCOUNT  STRING  COMMENT  '基金账号',
  VC_TRADE_ACCOUNT  STRING  COMMENT  '交易账号',
  C_BONUS_TYPE  STRING  COMMENT  '分红方式',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '所属公司',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '所属部门',
  L_CURRENTS_NO  DECIMAL(12,0)  COMMENT  '',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日期',
  EN_PROFIT_RATIO  DECIMAL(9,8)  COMMENT  '到期收益率',
  C_TRAN_FLAG  STRING  COMMENT  '',
  C_TRAN_POINT  STRING  COMMENT  '',
  L_RESTRICTED_NO  DECIMAL(10,0)  COMMENT  '',
  VC_UNIQUE_SERIAL_NO  STRING  COMMENT  '',
  L_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  '复核人员',
  L_CHECK_TIME  DECIMAL(6,0)  COMMENT  '复核时间',
  VC_IP_ADDRESS  STRING  COMMENT  'IP地址',
  VC_MAC  STRING  COMMENT  '电脑mac地址',
  VC_VOLSERIAL_NO  STRING  COMMENT  '',
  VC_TERMINALINFO_EXTEND  STRING  COMMENT  '',
  VC_CAPITAL_ACCOUNT  STRING  COMMENT  '资金账号',
  L_FROZEN_BALANCE_DATE  DECIMAL(8,0)  COMMENT  '',
  VC_CHANNEL_CODE  STRING  COMMENT  '',
  VC_EXPORT_FLAG  STRING  COMMENT  '导出标志',
  C_EXEC_STATUS  STRING  COMMENT  '',
  EN_DEAL_AMOUNT  DECIMAL(16,2)  COMMENT  '成交数量',
  EN_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '成交金额',
  VC_OTCORDERID  STRING  COMMENT  '',
  EN_CANCEL_AMOUNT  DECIMAL(16,2)  COMMENT  '',
  L_BONDLENDING_AMOUNT  DECIMAL(18,4)  COMMENT  '银行间债券卖空',
  L_INVEST_ADVISER  DECIMAL(8,0)  COMMENT  '投资顾问',
  C_INTEREST_DEPOSIT  STRING  COMMENT  '',
  L_RE_PAY_INTEVAL  DECIMAL(10,0)  COMMENT  '',
  C_RE_PAY_INTEVAL_UNIT  STRING  COMMENT  '',
  L_EXTSYSTEM_ID  DECIMAL(8,0)  COMMENT  '',
  VC_THIRD_REFF  STRING  COMMENT  '',
  C_RESTRICTED_FLAG  STRING  COMMENT  '',
  L_BANK_FUND_ID  DECIMAL(8,0)  COMMENT  '',
  L_BANK_ASSET_ID  DECIMAL(8,0)  COMMENT  '',
  L_MANAGER_OPERTOR  DECIMAL(8,0)  COMMENT  '',
  L_AFFILIATION  STRING  COMMENT  '交易目的编号',
  EN_DEAL_INTEREST  DECIMAL(20,12)  COMMENT  '',
  C_CASH_INFLUENCE  STRING  COMMENT  '',
  C_TA_TYPE  STRING  COMMENT  '',
  C_LAST_BONUS_TYPE  STRING  COMMENT  '',
  L_IN_AFFILIATION  DECIMAL(12,0)  COMMENT  '',
  C_SOURCE  STRING  COMMENT  '',
  EN_PROFIT_REWARD  DECIMAL(12,2)  COMMENT  '',
  L_BUYOUT_AMOUNT  DECIMAL(20,4)  COMMENT  '卖出数量',
  L_LOCK_OPERATOR  DECIMAL(8,0)  COMMENT  '锁定操作员',
  C_LOCK_FLAG  STRING  COMMENT  '锁定标志',
  L_MATCHTIME  DECIMAL(6,0)  COMMENT  '匹配时间',
  C_CAPITAL_CHANGE  STRING  COMMENT  '',
  VC_DEAL_DETIAL_STATUS  STRING  COMMENT  '',
  EN_CHANGE_RATIO  DECIMAL(8,4)  COMMENT  '',
  C_OUT_CONFIRM_FLAG  STRING  COMMENT  '',
  EN_PRICE3  DECIMAL(16,8)  COMMENT  '',
  EN_AMOUNT1  DECIMAL(20,4)  COMMENT  '',
  EN_AMOUNT2  DECIMAL(20,4)  COMMENT  '数量参数2',
  EN_AMOUNT3  DECIMAL(20,4)  COMMENT  '',
  EN_BALANCE1  DECIMAL(16,2)  COMMENT  '',
  EN_BALANCE2  DECIMAL(16,2)  COMMENT  '',
  EN_BALANCE3  DECIMAL(16,2)  COMMENT  '',
  L_MODIFY_NO  DECIMAL(8,0)  COMMENT  '修改序号'
)
COMMENT '场外业务确认'
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
                                   , L_TIME
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INDEX_DAILY_MODIFY
                                   , L_BUSIN_FLAG
                                   , C_BUSIN_CLASS
                                   , C_BUSIN_PRO_TYPE
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , C_INVEST_TYPE
                                   , VC_INTER_CODE
                                   , C_ENTRUST_DIRECTION
                                   , C_MARKET_NO
                                   , EN_BALANCE
                                   , EN_CBALANCE
                                   , EN_AMOUNT
                                   , EN_PRICE
                                   , EN_FEE_RATIO
                                   , EN_FEE
                                   , C_DEAL_STATUS
                                   , C_STATUS
                                   , D_DATETIME
                                   , L_OPERATOR_NO
                                   , C_EXCEED_FLAG
                                   , VC_IN_INTERCODE
                                   , L_RIVAL_ID
                                   , C_SETTLE_TYPE
                                   , EN_INTEREST
                                   , C_FEE_DEAL_TYPE
                                   , VC_REMARK
                                   , VC_STOCKHOLDER_ID
                                   , VC_SEAT_ID
                                   , L_EXECCONFIRM_NO
                                   , VC_ATTACHED_WARRANT_CODE
                                   , EN_WARRANT_AMOUNT
                                   , L_WARRANT_COMBI
                                   , L_CONFIRM_DATE
                                   , L_DEAL_DATE
                                   , L_IN_COMBI_ID
                                   , VC_IN_STOCKHOLDER_ID
                                   , VC_IN_SEAT_ID
                                   , C_WARRANT_INVEST_TYPE
                                   , C_EXTERNAL_DEAL_FLAG
                                   , EN_DOWN_PRICE
                                   , EN_COMMISSION
                                   , L_DIRECT_DATE
                                   , L_DIRECT_OPERATOR
                                   , L_APPROVE_DATE
                                   , L_APPROVE_OPERATOR
                                   , L_SETTLE_DATE
                                   , C_ENTRUST_STATUS
                                   , L_BATCH_SERIAL_NO
                                   , C_IN_INVEST_TYPE
                                   , C_CHANNEL_NO
                                   , VC_ERROR_MSG
                                   , C_CANCEL_STATUS
                                   , VC_CANCEL_ERROR_MSG
                                   , EN_PRICE1
                                   , EN_PRICE2
                                   , VC_MINOR_BANK
                                   , VC_ACCOUNT_NO
                                   , VC_ACCOUNT_NAME
                                   , L_FA_CONFIRM_DATE
                                   , C_FIXSEND_FLAG
                                   , L_INSTR_DATE
                                   , VC_INSTRID
                                   , L_STOCK_SERIAL_NO
                                   , VC_RIVALTRADER_NAME
                                   , L_RIVALACCOUNT_NO
                                   , VC_RIVAL_BANK_ACCOUNT
                                   , EN_PREPAY_BALANCE
                                   , VC_CONFIRM_NO
                                   , L_OLD_CONFIRM_NO
                                   , L_OLD_DEPOSIT_CONFIRM_NO
                                   , VC_RIVALTRADER_ID
                                   , L_OLD_PAY_DATE
                                   , EN_RECEIVABLE_INTEREST
                                   , EN_PUNISH_INTEREST
                                   , EN_RECEIVED
                                   , C_ZXRECEIVE_STATUS
                                   , L_CANCEL_NO
                                   , VC_ZXORDER_NO
                                   , C_ZXCANCEL_STATUS
                                   , C_FUNDCHECK_STATUS
                                   , VC_ZXCANCEL_NO
                                   , C_TA_STATUS
                                   , VC_TA_NO
                                   , C_FEE_TYPE
                                   , VC_FUND_ACCOUNT
                                   , VC_TRADE_ACCOUNT
                                   , C_BONUS_TYPE
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , L_CURRENTS_NO
                                   , L_END_DATE
                                   , EN_PROFIT_RATIO
                                   , C_TRAN_FLAG
                                   , C_TRAN_POINT
                                   , L_RESTRICTED_NO
                                   , VC_UNIQUE_SERIAL_NO
                                   , L_CHECK_OPERATOR
                                   , L_CHECK_TIME
                                   , VC_IP_ADDRESS
                                   , VC_MAC
                                   , VC_VOLSERIAL_NO
                                   , VC_TERMINALINFO_EXTEND
                                   , VC_CAPITAL_ACCOUNT
                                   , L_FROZEN_BALANCE_DATE
                                   , VC_CHANNEL_CODE
                                   , VC_EXPORT_FLAG
                                   , C_EXEC_STATUS
                                   , EN_DEAL_AMOUNT
                                   , EN_DEAL_BALANCE
                                   , VC_OTCORDERID
                                   , EN_CANCEL_AMOUNT
                                   , L_BONDLENDING_AMOUNT
                                   , L_INVEST_ADVISER
                                   , C_INTEREST_DEPOSIT
                                   , L_RE_PAY_INTEVAL
                                   , C_RE_PAY_INTEVAL_UNIT
                                   , L_EXTSYSTEM_ID
                                   , VC_THIRD_REFF
                                   , C_RESTRICTED_FLAG
                                   , L_BANK_FUND_ID
                                   , L_BANK_ASSET_ID
                                   , L_MANAGER_OPERTOR
                                   , L_AFFILIATION
                                   , EN_DEAL_INTEREST
                                   , C_CASH_INFLUENCE
                                   , C_TA_TYPE
                                   , C_LAST_BONUS_TYPE
                                   , L_IN_AFFILIATION
                                   , C_SOURCE
                                   , EN_PROFIT_REWARD
                                   , L_BUYOUT_AMOUNT
                                   , L_LOCK_OPERATOR
                                   , C_LOCK_FLAG
                                   , L_MATCHTIME
                                   , C_CAPITAL_CHANGE
                                   , VC_DEAL_DETIAL_STATUS
                                   , EN_CHANGE_RATIO
                                   , C_OUT_CONFIRM_FLAG
                                   , EN_PRICE3
                                   , EN_AMOUNT1
                                   , EN_AMOUNT2
                                   , EN_AMOUNT3
                                   , EN_BALANCE1
                                   , EN_BALANCE2
                                   , EN_BALANCE3
                                   , L_MODIFY_NO
                                FROM ${o32_src_schema}.THISOUTCONFIRM
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_CONFIRM_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_BUSIN_FLAG", "type": "DOUBLE"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "C_BUSIN_PRO_TYPE", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_CBALANCE", "type": "DOUBLE"}, {"name": "EN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "EN_FEE_RATIO", "type": "DOUBLE"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "C_DEAL_STATUS", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "C_EXCEED_FLAG", "type": "STRING"}, {"name": "VC_IN_INTERCODE", "type": "STRING"}, {"name": "L_RIVAL_ID", "type": "DOUBLE"}, {"name": "C_SETTLE_TYPE", "type": "STRING"}, {"name": "EN_INTEREST", "type": "DOUBLE"}, {"name": "C_FEE_DEAL_TYPE", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "L_EXECCONFIRM_NO", "type": "DOUBLE"}, {"name": "VC_ATTACHED_WARRANT_CODE", "type": "STRING"}, {"name": "EN_WARRANT_AMOUNT", "type": "DOUBLE"}, {"name": "L_WARRANT_COMBI", "type": "DOUBLE"}, {"name": "L_CONFIRM_DATE", "type": "DOUBLE"}, {"name": "L_DEAL_DATE", "type": "DOUBLE"}, {"name": "L_IN_COMBI_ID", "type": "DOUBLE"}, {"name": "VC_IN_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_IN_SEAT_ID", "type": "STRING"}, {"name": "C_WARRANT_INVEST_TYPE", "type": "STRING"}, {"name": "C_EXTERNAL_DEAL_FLAG", "type": "STRING"}, {"name": "EN_DOWN_PRICE", "type": "DOUBLE"}, {"name": "EN_COMMISSION", "type": "DOUBLE"}, {"name": "L_DIRECT_DATE", "type": "DOUBLE"}, {"name": "L_DIRECT_OPERATOR", "type": "DOUBLE"}, {"name": "L_APPROVE_DATE", "type": "DOUBLE"}, {"name": "L_APPROVE_OPERATOR", "type": "DOUBLE"}, {"name": "L_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_ENTRUST_STATUS", "type": "STRING"}, {"name": "L_BATCH_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_IN_INVEST_TYPE", "type": "STRING"}, {"name": "C_CHANNEL_NO", "type": "STRING"}, {"name": "VC_ERROR_MSG", "type": "STRING"}, {"name": "C_CANCEL_STATUS", "type": "STRING"}, {"name": "VC_CANCEL_ERROR_MSG", "type": "STRING"}, {"name": "EN_PRICE1", "type": "DOUBLE"}, {"name": "EN_PRICE2", "type": "DOUBLE"}, {"name": "VC_MINOR_BANK", "type": "STRING"}, {"name": "VC_ACCOUNT_NO", "type": "STRING"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "L_FA_CONFIRM_DATE", "type": "DOUBLE"}, {"name": "C_FIXSEND_FLAG", "type": "STRING"}, {"name": "L_INSTR_DATE", "type": "DOUBLE"}, {"name": "VC_INSTRID", "type": "STRING"}, {"name": "L_STOCK_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_NAME", "type": "STRING"}, {"name": "L_RIVALACCOUNT_NO", "type": "DOUBLE"}, {"name": "VC_RIVAL_BANK_ACCOUNT", "type": "STRING"}, {"name": "EN_PREPAY_BALANCE", "type": "DOUBLE"}, {"name": "VC_CONFIRM_NO", "type": "STRING"}, {"name": "L_OLD_CONFIRM_NO", "type": "DOUBLE"}, {"name": "L_OLD_DEPOSIT_CONFIRM_NO", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "L_OLD_PAY_DATE", "type": "DOUBLE"}, {"name": "EN_RECEIVABLE_INTEREST", "type": "DOUBLE"}, {"name": "EN_PUNISH_INTEREST", "type": "DOUBLE"}, {"name": "EN_RECEIVED", "type": "DOUBLE"}, {"name": "C_ZXRECEIVE_STATUS", "type": "STRING"}, {"name": "L_CANCEL_NO", "type": "DOUBLE"}, {"name": "VC_ZXORDER_NO", "type": "STRING"}, {"name": "C_ZXCANCEL_STATUS", "type": "STRING"}, {"name": "C_FUNDCHECK_STATUS", "type": "STRING"}, {"name": "VC_ZXCANCEL_NO", "type": "STRING"}, {"name": "C_TA_STATUS", "type": "STRING"}, {"name": "VC_TA_NO", "type": "STRING"}, {"name": "C_FEE_TYPE", "type": "STRING"}, {"name": "VC_FUND_ACCOUNT", "type": "STRING"}, {"name": "VC_TRADE_ACCOUNT", "type": "STRING"}, {"name": "C_BONUS_TYPE", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "L_CURRENTS_NO", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "EN_PROFIT_RATIO", "type": "DOUBLE"}, {"name": "C_TRAN_FLAG", "type": "STRING"}, {"name": "C_TRAN_POINT", "type": "STRING"}, {"name": "L_RESTRICTED_NO", "type": "DOUBLE"}, {"name": "VC_UNIQUE_SERIAL_NO", "type": "STRING"}, {"name": "L_CHECK_OPERATOR", "type": "DOUBLE"}, {"name": "L_CHECK_TIME", "type": "DOUBLE"}, {"name": "VC_IP_ADDRESS", "type": "STRING"}, {"name": "VC_MAC", "type": "STRING"}, {"name": "VC_VOLSERIAL_NO", "type": "STRING"}, {"name": "VC_TERMINALINFO_EXTEND", "type": "STRING"}, {"name": "VC_CAPITAL_ACCOUNT", "type": "STRING"}, {"name": "L_FROZEN_BALANCE_DATE", "type": "DOUBLE"}, {"name": "VC_CHANNEL_CODE", "type": "STRING"}, {"name": "VC_EXPORT_FLAG", "type": "STRING"}, {"name": "C_EXEC_STATUS", "type": "STRING"}, {"name": "EN_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "VC_OTCORDERID", "type": "STRING"}, {"name": "EN_CANCEL_AMOUNT", "type": "DOUBLE"}, {"name": "L_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "L_INVEST_ADVISER", "type": "DOUBLE"}, {"name": "C_INTEREST_DEPOSIT", "type": "STRING"}, {"name": "L_RE_PAY_INTEVAL", "type": "DOUBLE"}, {"name": "C_RE_PAY_INTEVAL_UNIT", "type": "STRING"}, {"name": "L_EXTSYSTEM_ID", "type": "DOUBLE"}, {"name": "VC_THIRD_REFF", "type": "STRING"}, {"name": "C_RESTRICTED_FLAG", "type": "STRING"}, {"name": "L_BANK_FUND_ID", "type": "DOUBLE"}, {"name": "L_BANK_ASSET_ID", "type": "DOUBLE"}, {"name": "L_MANAGER_OPERTOR", "type": "DOUBLE"}, {"name": "L_AFFILIATION", "type": "DOUBLE"}, {"name": "EN_DEAL_INTEREST", "type": "DOUBLE"}, {"name": "C_CASH_INFLUENCE", "type": "STRING"}, {"name": "C_TA_TYPE", "type": "STRING"}, {"name": "C_LAST_BONUS_TYPE", "type": "STRING"}, {"name": "L_IN_AFFILIATION", "type": "DOUBLE"}, {"name": "C_SOURCE", "type": "STRING"}, {"name": "EN_PROFIT_REWARD", "type": "DOUBLE"}, {"name": "L_BUYOUT_AMOUNT", "type": "DOUBLE"}, {"name": "L_LOCK_OPERATOR", "type": "DOUBLE"}, {"name": "C_LOCK_FLAG", "type": "STRING"}, {"name": "L_MATCHTIME", "type": "DOUBLE"}, {"name": "C_CAPITAL_CHANGE", "type": "STRING"}, {"name": "VC_DEAL_DETIAL_STATUS", "type": "STRING"}, {"name": "EN_CHANGE_RATIO", "type": "DOUBLE"}, {"name": "C_OUT_CONFIRM_FLAG", "type": "STRING"}, {"name": "EN_PRICE3", "type": "DOUBLE"}, {"name": "EN_AMOUNT1", "type": "DOUBLE"}, {"name": "EN_AMOUNT2", "type": "DOUBLE"}, {"name": "EN_AMOUNT3", "type": "DOUBLE"}, {"name": "EN_BALANCE1", "type": "DOUBLE"}, {"name": "EN_BALANCE2", "type": "DOUBLE"}, {"name": "EN_BALANCE3", "type": "DOUBLE"}, {"name": "L_MODIFY_NO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_toutconfirm_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_toutconfirm_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_toutconfirm_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_toutconfirm_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TOUTCONFIRM_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TOUTCONFIRM_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_toutconfirm_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TOUTCONFIRM_PTD PARTITION(P_DT)
SELECT
       L_CONFIRM_NO
     , L_DATE
     , L_TIME
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , L_BUSIN_FLAG
     , C_BUSIN_CLASS
     , C_BUSIN_PRO_TYPE
     , L_FUND_ID
     , L_BASECOMBI_ID
     , C_INVEST_TYPE
     , VC_INTER_CODE
     , C_ENTRUST_DIRECTION
     , C_MARKET_NO
     , EN_BALANCE
     , EN_CBALANCE
     , EN_AMOUNT
     , EN_PRICE
     , EN_FEE_RATIO
     , EN_FEE
     , C_DEAL_STATUS
     , C_STATUS
     , D_DATETIME
     , L_OPERATOR_NO
     , C_EXCEED_FLAG
     , VC_IN_INTERCODE
     , L_RIVAL_ID
     , C_SETTLE_TYPE
     , EN_INTEREST
     , C_FEE_DEAL_TYPE
     , VC_REMARK
     , VC_STOCKHOLDER_ID
     , VC_SEAT_ID
     , L_EXECCONFIRM_NO
     , VC_ATTACHED_WARRANT_CODE
     , EN_WARRANT_AMOUNT
     , L_WARRANT_COMBI
     , L_CONFIRM_DATE
     , L_DEAL_DATE
     , L_IN_COMBI_ID
     , VC_IN_STOCKHOLDER_ID
     , VC_IN_SEAT_ID
     , C_WARRANT_INVEST_TYPE
     , C_EXTERNAL_DEAL_FLAG
     , EN_DOWN_PRICE
     , EN_COMMISSION
     , L_DIRECT_DATE
     , L_DIRECT_OPERATOR
     , L_APPROVE_DATE
     , L_APPROVE_OPERATOR
     , L_SETTLE_DATE
     , C_ENTRUST_STATUS
     , L_BATCH_SERIAL_NO
     , C_IN_INVEST_TYPE
     , C_CHANNEL_NO
     , VC_ERROR_MSG
     , C_CANCEL_STATUS
     , VC_CANCEL_ERROR_MSG
     , EN_PRICE1
     , EN_PRICE2
     , VC_MINOR_BANK
     , VC_ACCOUNT_NO
     , VC_ACCOUNT_NAME
     , L_FA_CONFIRM_DATE
     , C_FIXSEND_FLAG
     , L_INSTR_DATE
     , VC_INSTRID
     , L_STOCK_SERIAL_NO
     , VC_RIVALTRADER_NAME
     , L_RIVALACCOUNT_NO
     , VC_RIVAL_BANK_ACCOUNT
     , EN_PREPAY_BALANCE
     , VC_CONFIRM_NO
     , L_OLD_CONFIRM_NO
     , L_OLD_DEPOSIT_CONFIRM_NO
     , VC_RIVALTRADER_ID
     , L_OLD_PAY_DATE
     , EN_RECEIVABLE_INTEREST
     , EN_PUNISH_INTEREST
     , EN_RECEIVED
     , C_ZXRECEIVE_STATUS
     , L_CANCEL_NO
     , VC_ZXORDER_NO
     , C_ZXCANCEL_STATUS
     , C_FUNDCHECK_STATUS
     , VC_ZXCANCEL_NO
     , C_TA_STATUS
     , VC_TA_NO
     , C_FEE_TYPE
     , VC_FUND_ACCOUNT
     , VC_TRADE_ACCOUNT
     , C_BONUS_TYPE
     , L_ORG_ID
     , L_DEPT_ID
     , L_CURRENTS_NO
     , L_END_DATE
     , EN_PROFIT_RATIO
     , C_TRAN_FLAG
     , C_TRAN_POINT
     , L_RESTRICTED_NO
     , VC_UNIQUE_SERIAL_NO
     , L_CHECK_OPERATOR
     , L_CHECK_TIME
     , VC_IP_ADDRESS
     , VC_MAC
     , VC_VOLSERIAL_NO
     , VC_TERMINALINFO_EXTEND
     , VC_CAPITAL_ACCOUNT
     , L_FROZEN_BALANCE_DATE
     , VC_CHANNEL_CODE
     , VC_EXPORT_FLAG
     , C_EXEC_STATUS
     , EN_DEAL_AMOUNT
     , EN_DEAL_BALANCE
     , VC_OTCORDERID
     , EN_CANCEL_AMOUNT
     , L_BONDLENDING_AMOUNT
     , L_INVEST_ADVISER
     , C_INTEREST_DEPOSIT
     , L_RE_PAY_INTEVAL
     , C_RE_PAY_INTEVAL_UNIT
     , L_EXTSYSTEM_ID
     , VC_THIRD_REFF
     , C_RESTRICTED_FLAG
     , L_BANK_FUND_ID
     , L_BANK_ASSET_ID
     , L_MANAGER_OPERTOR
     , L_AFFILIATION
     , EN_DEAL_INTEREST
     , C_CASH_INFLUENCE
     , C_TA_TYPE
     , C_LAST_BONUS_TYPE
     , L_IN_AFFILIATION
     , C_SOURCE
     , EN_PROFIT_REWARD
     , L_BUYOUT_AMOUNT
     , L_LOCK_OPERATOR
     , C_LOCK_FLAG
     , L_MATCHTIME
     , C_CAPITAL_CHANGE
     , VC_DEAL_DETIAL_STATUS
     , EN_CHANGE_RATIO
     , C_OUT_CONFIRM_FLAG
     , EN_PRICE3
     , EN_AMOUNT1
     , EN_AMOUNT2
     , EN_AMOUNT3
     , EN_BALANCE1
     , EN_BALANCE2
     , EN_BALANCE3
     , L_MODIFY_NO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TOUTCONFIRM_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TOUTCONFIRM_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TOUTCONFIRM_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TOUTCONFIRM_PTD成功"
      exit 0
   fi
fi
