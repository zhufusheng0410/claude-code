#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESORDER_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESORDER_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '成交日期',
  L_TIME  DECIMAL(6,0)  COMMENT  '成交时间',
  VC_MARKET_INDICATOR  STRING  COMMENT  '市场标识成交类型',
  VC_REPORT_CODE  STRING  COMMENT  '证券代码',
  VC_NAME  STRING  COMMENT  '证券名称',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  VC_ORIGINAL_DEAL_NO  STRING  COMMENT  '原始成交编号',
  EN_TOTAL_FACE_VALUE  DECIMAL(16,2)  COMMENT  '券面总额',
  EN_PRICE  DECIMAL(16,8)  COMMENT  '成交价格',
  L_FIRST_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '首次结算日',
  L_END_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '到期结算日',
  EN_SETTLE_BALANCE  DECIMAL(16,2)  COMMENT  '首次结算金额',
  EN_SETTLE_END_BALANCE  DECIMAL(16,2)  COMMENT  '到期结算金额',
  EN_ACCRUED_INTEREST_AMT  DECIMAL(22,12)  COMMENT  '应计利息',
  EN_ACCRUED_INTEREST_TOTAL_AMT  DECIMAL(16,2)  COMMENT  '利息总额',
  EN_MISCFEEAMT  DECIMAL(16,2)  COMMENT  '借贷费用',
  VC_CAPTION  STRING  COMMENT  '备注',
  VC_MATURITY  STRING  COMMENT  '待偿期',
  L_TRADE_BALANCE  DECIMAL(16,2)  COMMENT  '成交金额',
  C_SIDE  STRING  COMMENT  '本方交易方向',
  EN_END_YLD  DECIMAL(16,8)  COMMENT  '到期收益率',
  EN_DISCOUNT_RATE  DECIMAL(14,8)  COMMENT  '贴现率',
  EN_FULL_PRICE  DECIMAL(16,8)  COMMENT  '全价',
  L_LIMIT_DAYS  DECIMAL(10,0)  COMMENT  '期限',
  L_HOLD_DAYS  DECIMAL(10,0)  COMMENT  '占款天数',
  C_FIRST_DELIVERY_TYPE  STRING  COMMENT  '首次结算方式',
  C_END_DELIVERY_TYPE  STRING  COMMENT  '到期结算方式',
  C_TRADE_TYPE  STRING  COMMENT  '成交类别',
  EN_PRINCIPAL  DECIMAL(16,2)  COMMENT  '每百元本金',
  EN_TOTAL_PRINCIPAL  DECIMAL(16,2)  COMMENT  '当前本金',
  EN_BENK_PRICE  DECIMAL(16,8)  COMMENT  '浮动利率',
  VC_BENCH_NAME  STRING  COMMENT  '参考利率名称',
  C_INTEREST_ACCRUAL_METHOD  STRING  COMMENT  '计息基准',
  EN_IOP_VALUE  DECIMAL(14,8)  COMMENT  '参考净值',
  C_TRADE_METHOD  STRING  COMMENT  '交易方式',
  L_PAY_DATE  DECIMAL(8,0)  COMMENT  '支付日',
  L_SETTLE_DAY_RESET  DECIMAL(10,0)  COMMENT  '支付日调整',
  L_INTEREST_DAY_RESET  DECIMAL(10,0)  COMMENT  '计息天数调整',
  L_FIRST_INTEREST_START_DAY  DECIMAL(8,0)  COMMENT  '首期起息日',
  C_ORDER_STATUS  STRING  COMMENT  '成交状态',
  VC_SELF_PARTY_ID  STRING  COMMENT  '本方会员代码',
  VC_SELF_PARTY_NAME  STRING  COMMENT  '本方会员简称',
  VC_SELF_PARTY_FULL_NAME  STRING  COMMENT  '本方会员全称',
  VC_SELF_ACC_NAME  STRING  COMMENT  '本方开户名',
  VC_SELF_ACC_BANK_NAME  STRING  COMMENT  '本方开户行名称',
  VC_SELF_ACC_NO  STRING  COMMENT  '本方银行间账户编号',
  VC_SELF_ACC_BANK_NO  STRING  COMMENT  '本方银行编号',
  VC_SELF_BOND_ACC_NAME  STRING  COMMENT  '本方债券托管账户名',
  VC_SELF_BOND_CUST_NAME  STRING  COMMENT  '本方债券托管机构名',
  VC_SELF_BOND_ACC_NO  STRING  COMMENT  '本方债券托管账户',
  VC_SELF_TRADER_NAME  STRING  COMMENT  '本方交易员',
  VC_SELF_TRADER_CODE  STRING  COMMENT  '本方交易员编号',
  VC_SELF_FUND_BANK_NAME  STRING  COMMENT  '本方基金托管行',
  VC_SELF_FUND_ACC_NAME  STRING  COMMENT  '本方基金托管账户户名',
  VC_SELF_FUND_BANK_NO  STRING  COMMENT  '基金托管账号',
  VC_SELF_REMARK  STRING  COMMENT  '本方说明',
  VC_SELF_SWIFTCODE  STRING  COMMENT  '本方swift代码',
  VC_SELF_CASH_ACC_NAME  STRING  COMMENT  '本方中文资金账户户名',
  VC_SELF_CUST_NO  STRING  COMMENT  '本方保证券托管账号',
  VC_SELF_CUST_NAME  STRING  COMMENT  '本方保证券托管机构',
  VC_SELF_MARG_CUST_ACC_NAME  STRING  COMMENT  '本方保证券托管账户户名',
  VC_SELF_MARG_ACC_BANK_NO  STRING  COMMENT  '本方保证金开户行联行行号',
  VC_SELF_MARG_ACC_NO  STRING  COMMENT  '本方保证金账号',
  VC_SELF_MARG_BANK_NAME  STRING  COMMENT  '本方保证金开户行',
  VC_SELF_MARG_ACC_NAME  STRING  COMMENT  '本方保证金账户户名',
  VC_COUNTERPTY_PARTY_ID  STRING  COMMENT  '对手方会员代码',
  VC_COUNTERPTY_PARTY_NAME  STRING  COMMENT  '对手方会员简称',
  VC_COUNTERPTY_PARTY_FULL_NAME  STRING  COMMENT  '对手方会员全称',
  VC_COUNTERPTY_ACC_NAME  STRING  COMMENT  '对手方开户名',
  VC_COUNTERPTY_ACC_BANK_NAME  STRING  COMMENT  '对手方开户行名称',
  VC_COUNTERPTY_ACC_NO  STRING  COMMENT  '对手方银行间账户编号',
  VC_COUNTERPTY_ACC_BANK_NO  STRING  COMMENT  '对手方银行编号',
  VC_COUNTERPTY_BOND_ACC_NAME  STRING  COMMENT  '对手方债券托管账户名',
  VC_COUNTERPTY_BOND_CUST_NAME  STRING  COMMENT  '对手方债券托管机构名',
  VC_COUNTERPTY_BOND_ACC_NO  STRING  COMMENT  '对手方债券托管账户',
  VC_COUNTERPTY_TRADER_NAME  STRING  COMMENT  '对手方交易员',
  VC_COUNTERPTY_TRADER_CODE  STRING  COMMENT  '对手方交易员编号',
  VC_COUNTERPTY_MARG_ACC_NAME  STRING  COMMENT  '对手方保证金账户户名',
  VC_COUNTERPTY_MARG_BANK_NAME  STRING  COMMENT  '对手方保证金开户行',
  VC_COUNTERPTY_MARG_ACC_NO  STRING  COMMENT  '对手方保证金账号',
  VC_COUNTERPTY_MARG_ACC_BANK_NO  STRING  COMMENT  '对手方保证金开户行联行行号',
  VC_COUNTERPTY_MARG_CUST_ACC_NM  STRING  COMMENT  '对手方保证券托管账户户名',
  VC_COUNTERPTY_CUST_NAME  STRING  COMMENT  '对手方保证券托管机构',
  VC_COUNTERPTY_CUST_NO  STRING  COMMENT  '对手方保证券托管账号',
  VC_COUNTERPTY_CASH_ACC_NAME  STRING  COMMENT  '对手方中文资金账户户名',
  VC_COUNTERPTY_SWIFTCODE  STRING  COMMENT  '对手方swift代码',
  VC_COUNTERPTY_REMARK  STRING  COMMENT  '对手方说明',
  VC_COUNTERPTY_FUND_ACC_NAME  STRING  COMMENT  '对手方基金托管账户户名',
  VC_COUNTERPTY_FUND_BANK_NAME  STRING  COMMENT  '对手方基金托管行',
  VC_COUNTERPTY_FUND_BANK_NO  STRING  COMMENT  '对手方基金托管账号',
  VC_QUOTE_NO  STRING  COMMENT  '报价编号',
  VC_EXEC_TYPE  STRING  COMMENT  '成交类型',
  EN_STRIKE_YLD  DECIMAL(14,8)  COMMENT  '行权利率',
  VC_DEALTRTYPE  STRING  COMMENT  '处理类型，应急时需要判断',
  VC_TRANSTIME  STRING  COMMENT  '更新日',
  C_COUPONPAYMENT_INDICATOR  STRING  COMMENT  '重发标志',
  C_CONTINGENCY_INDICATOR  STRING  COMMENT  '应急标识',
  L_START_DATE  DECIMAL(8,0)  COMMENT  '起息日',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日',
  L_DISSETMET  DECIMAL(5,0)  COMMENT  '争议解决方式',
  L_INT_FIX_DATE  DECIMAL(8,0)  COMMENT  '利率确定日',
  L_CALC_AGENCY  DECIMAL(10,0)  COMMENT  '计算代理方',
  C_MARGIN_CHANGE_INDICATOR  STRING  COMMENT  '保证品变动标识',
  C_MARGINREQ  STRING  COMMENT  '有无保证品',
  L_SETTL_TYPE  DECIMAL(10,0)  COMMENT  '清算速度',
  VC_REFERENCE  STRING  COMMENT  '请求报价编号',
  VC_SELF_ACC_BANK_NAME2  STRING  COMMENT  '',
  VC_SELF_ACC_BANK_NO2  STRING  COMMENT  '',
  VC_SELF_BOND_CUST_NAME2  STRING  COMMENT  '',
  VC_SELF_BOND_ACC_NAME2  STRING  COMMENT  '',
  VC_SELF_BOND_ACC_NO2  STRING  COMMENT  '',
  VC_SELF_ACC_NAME2  STRING  COMMENT  '',
  VC_SELF_ACC_NO2  STRING  COMMENT  '',
  VC_COUNTERPTY_ACC_BANK_NAME2  STRING  COMMENT  '',
  VC_COUNTERPTY_ACC_BANK_NO2  STRING  COMMENT  '',
  VC_COUNTERPTY_BOND_CUST_NAME2  STRING  COMMENT  '',
  VC_COUNTERPTY_BOND_ACC_NAME2  STRING  COMMENT  '',
  VC_COUNTERPTY_BOND_ACC_NO2  STRING  COMMENT  '',
  VC_COUNTERPTY_ACC_NAME2  STRING  COMMENT  '',
  VC_COUNTERPTY_ACC_NO2  STRING  COMMENT  '',
  L_TRADE_BALANCE1  DECIMAL(16,2)  COMMENT  '',
  EN_ACCRUED_INTEREST_TOTAL_AMT1  DECIMAL(16,2)  COMMENT  '',
  EN_SETTLE_END_BALANCE1  DECIMAL(16,2)  COMMENT  '',
  EN_TOTAL_FACE_VALUE1  DECIMAL(16,2)  COMMENT  '',
  L_TRADE_BALANCE2  DECIMAL(16,2)  COMMENT  '',
  EN_ACCRUED_INTEREST_TOTAL_AMT2  DECIMAL(16,2)  COMMENT  '',
  EN_SETTLE_END_BALANCE2  DECIMAL(16,2)  COMMENT  '',
  EN_TOTAL_FACE_VALUE2  DECIMAL(16,2)  COMMENT  '',
  C_FORCE  STRING  COMMENT  '',
  VC_CLEAR_METHOD  STRING  COMMENT  ''
)
COMMENT '银行间交易关联机构成交表'
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
                                   , VC_MARKET_INDICATOR
                                   , VC_REPORT_CODE
                                   , VC_NAME
                                   , VC_DEAL_NO
                                   , VC_ORIGINAL_DEAL_NO
                                   , EN_TOTAL_FACE_VALUE
                                   , EN_PRICE
                                   , L_FIRST_SETTLE_DATE
                                   , L_END_SETTLE_DATE
                                   , EN_SETTLE_BALANCE
                                   , EN_SETTLE_END_BALANCE
                                   , EN_ACCRUED_INTEREST_AMT
                                   , EN_ACCRUED_INTEREST_TOTAL_AMT
                                   , EN_MISCFEEAMT
                                   , VC_CAPTION
                                   , VC_MATURITY
                                   , L_TRADE_BALANCE
                                   , C_SIDE
                                   , EN_END_YLD
                                   , EN_DISCOUNT_RATE
                                   , EN_FULL_PRICE
                                   , L_LIMIT_DAYS
                                   , L_HOLD_DAYS
                                   , C_FIRST_DELIVERY_TYPE
                                   , C_END_DELIVERY_TYPE
                                   , C_TRADE_TYPE
                                   , EN_PRINCIPAL
                                   , EN_TOTAL_PRINCIPAL
                                   , EN_BENK_PRICE
                                   , VC_BENCH_NAME
                                   , C_INTEREST_ACCRUAL_METHOD
                                   , EN_IOP_VALUE
                                   , C_TRADE_METHOD
                                   , L_PAY_DATE
                                   , L_SETTLE_DAY_RESET
                                   , L_INTEREST_DAY_RESET
                                   , L_FIRST_INTEREST_START_DAY
                                   , C_ORDER_STATUS
                                   , VC_SELF_PARTY_ID
                                   , VC_SELF_PARTY_NAME
                                   , VC_SELF_PARTY_FULL_NAME
                                   , VC_SELF_ACC_NAME
                                   , VC_SELF_ACC_BANK_NAME
                                   , VC_SELF_ACC_NO
                                   , VC_SELF_ACC_BANK_NO
                                   , VC_SELF_BOND_ACC_NAME
                                   , VC_SELF_BOND_CUST_NAME
                                   , VC_SELF_BOND_ACC_NO
                                   , VC_SELF_TRADER_NAME
                                   , VC_SELF_TRADER_CODE
                                   , VC_SELF_FUND_BANK_NAME
                                   , VC_SELF_FUND_ACC_NAME
                                   , VC_SELF_FUND_BANK_NO
                                   , VC_SELF_REMARK
                                   , VC_SELF_SWIFTCODE
                                   , VC_SELF_CASH_ACC_NAME
                                   , VC_SELF_CUST_NO
                                   , VC_SELF_CUST_NAME
                                   , VC_SELF_MARG_CUST_ACC_NAME
                                   , VC_SELF_MARG_ACC_BANK_NO
                                   , VC_SELF_MARG_ACC_NO
                                   , VC_SELF_MARG_BANK_NAME
                                   , VC_SELF_MARG_ACC_NAME
                                   , VC_COUNTERPTY_PARTY_ID
                                   , VC_COUNTERPTY_PARTY_NAME
                                   , VC_COUNTERPTY_PARTY_FULL_NAME
                                   , VC_COUNTERPTY_ACC_NAME
                                   , VC_COUNTERPTY_ACC_BANK_NAME
                                   , VC_COUNTERPTY_ACC_NO
                                   , VC_COUNTERPTY_ACC_BANK_NO
                                   , VC_COUNTERPTY_BOND_ACC_NAME
                                   , VC_COUNTERPTY_BOND_CUST_NAME
                                   , VC_COUNTERPTY_BOND_ACC_NO
                                   , VC_COUNTERPTY_TRADER_NAME
                                   , VC_COUNTERPTY_TRADER_CODE
                                   , VC_COUNTERPTY_MARG_ACC_NAME
                                   , VC_COUNTERPTY_MARG_BANK_NAME
                                   , VC_COUNTERPTY_MARG_ACC_NO
                                   , VC_COUNTERPTY_MARG_ACC_BANK_NO
                                   , VC_COUNTERPTY_MARG_CUST_ACC_NM
                                   , VC_COUNTERPTY_CUST_NAME
                                   , VC_COUNTERPTY_CUST_NO
                                   , VC_COUNTERPTY_CASH_ACC_NAME
                                   , VC_COUNTERPTY_SWIFTCODE
                                   , VC_COUNTERPTY_REMARK
                                   , VC_COUNTERPTY_FUND_ACC_NAME
                                   , VC_COUNTERPTY_FUND_BANK_NAME
                                   , VC_COUNTERPTY_FUND_BANK_NO
                                   , VC_QUOTE_NO
                                   , VC_EXEC_TYPE
                                   , EN_STRIKE_YLD
                                   , VC_DEALTRTYPE
                                   , VC_TRANSTIME
                                   , C_COUPONPAYMENT_INDICATOR
                                   , C_CONTINGENCY_INDICATOR
                                   , L_START_DATE
                                   , L_END_DATE
                                   , L_DISSETMET
                                   , L_INT_FIX_DATE
                                   , L_CALC_AGENCY
                                   , C_MARGIN_CHANGE_INDICATOR
                                   , C_MARGINREQ
                                   , L_SETTL_TYPE
                                   , VC_REFERENCE
                                   , VC_SELF_ACC_BANK_NAME2
                                   , VC_SELF_ACC_BANK_NO2
                                   , VC_SELF_BOND_CUST_NAME2
                                   , VC_SELF_BOND_ACC_NAME2
                                   , VC_SELF_BOND_ACC_NO2
                                   , VC_SELF_ACC_NAME2
                                   , VC_SELF_ACC_NO2
                                   , VC_COUNTERPTY_ACC_BANK_NAME2
                                   , VC_COUNTERPTY_ACC_BANK_NO2
                                   , VC_COUNTERPTY_BOND_CUST_NAME2
                                   , VC_COUNTERPTY_BOND_ACC_NAME2
                                   , VC_COUNTERPTY_BOND_ACC_NO2
                                   , VC_COUNTERPTY_ACC_NAME2
                                   , VC_COUNTERPTY_ACC_NO2
                                   , L_TRADE_BALANCE1
                                   , EN_ACCRUED_INTEREST_TOTAL_AMT1
                                   , EN_SETTLE_END_BALANCE1
                                   , EN_TOTAL_FACE_VALUE1
                                   , L_TRADE_BALANCE2
                                   , EN_ACCRUED_INTEREST_TOTAL_AMT2
                                   , EN_SETTLE_END_BALANCE2
                                   , EN_TOTAL_FACE_VALUE2
                                   , C_FORCE
                                   , VC_CLEAR_METHOD
                                FROM ${o32_src_schema}.THISBANKAFFILIATESORDER
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "VC_MARKET_INDICATOR", "type": "STRING"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "VC_ORIGINAL_DEAL_NO", "type": "STRING"}, {"name": "EN_TOTAL_FACE_VALUE", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "L_FIRST_SETTLE_DATE", "type": "DOUBLE"}, {"name": "L_END_SETTLE_DATE", "type": "DOUBLE"}, {"name": "EN_SETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_SETTLE_END_BALANCE", "type": "DOUBLE"}, {"name": "EN_ACCRUED_INTEREST_AMT", "type": "DOUBLE"}, {"name": "EN_ACCRUED_INTEREST_TOTAL_AMT", "type": "DOUBLE"}, {"name": "EN_MISCFEEAMT", "type": "DOUBLE"}, {"name": "VC_CAPTION", "type": "STRING"}, {"name": "VC_MATURITY", "type": "STRING"}, {"name": "L_TRADE_BALANCE", "type": "DOUBLE"}, {"name": "C_SIDE", "type": "STRING"}, {"name": "EN_END_YLD", "type": "DOUBLE"}, {"name": "EN_DISCOUNT_RATE", "type": "DOUBLE"}, {"name": "EN_FULL_PRICE", "type": "DOUBLE"}, {"name": "L_LIMIT_DAYS", "type": "DOUBLE"}, {"name": "L_HOLD_DAYS", "type": "DOUBLE"}, {"name": "C_FIRST_DELIVERY_TYPE", "type": "STRING"}, {"name": "C_END_DELIVERY_TYPE", "type": "STRING"}, {"name": "C_TRADE_TYPE", "type": "STRING"}, {"name": "EN_PRINCIPAL", "type": "DOUBLE"}, {"name": "EN_TOTAL_PRINCIPAL", "type": "DOUBLE"}, {"name": "EN_BENK_PRICE", "type": "DOUBLE"}, {"name": "VC_BENCH_NAME", "type": "STRING"}, {"name": "C_INTEREST_ACCRUAL_METHOD", "type": "STRING"}, {"name": "EN_IOP_VALUE", "type": "DOUBLE"}, {"name": "C_TRADE_METHOD", "type": "STRING"}, {"name": "L_PAY_DATE", "type": "DOUBLE"}, {"name": "L_SETTLE_DAY_RESET", "type": "DOUBLE"}, {"name": "L_INTEREST_DAY_RESET", "type": "DOUBLE"}, {"name": "L_FIRST_INTEREST_START_DAY", "type": "DOUBLE"}, {"name": "C_ORDER_STATUS", "type": "STRING"}, {"name": "VC_SELF_PARTY_ID", "type": "STRING"}, {"name": "VC_SELF_PARTY_NAME", "type": "STRING"}, {"name": "VC_SELF_PARTY_FULL_NAME", "type": "STRING"}, {"name": "VC_SELF_ACC_NAME", "type": "STRING"}, {"name": "VC_SELF_ACC_BANK_NAME", "type": "STRING"}, {"name": "VC_SELF_ACC_NO", "type": "STRING"}, {"name": "VC_SELF_ACC_BANK_NO", "type": "STRING"}, {"name": "VC_SELF_BOND_ACC_NAME", "type": "STRING"}, {"name": "VC_SELF_BOND_CUST_NAME", "type": "STRING"}, {"name": "VC_SELF_BOND_ACC_NO", "type": "STRING"}, {"name": "VC_SELF_TRADER_NAME", "type": "STRING"}, {"name": "VC_SELF_TRADER_CODE", "type": "STRING"}, {"name": "VC_SELF_FUND_BANK_NAME", "type": "STRING"}, {"name": "VC_SELF_FUND_ACC_NAME", "type": "STRING"}, {"name": "VC_SELF_FUND_BANK_NO", "type": "STRING"}, {"name": "VC_SELF_REMARK", "type": "STRING"}, {"name": "VC_SELF_SWIFTCODE", "type": "STRING"}, {"name": "VC_SELF_CASH_ACC_NAME", "type": "STRING"}, {"name": "VC_SELF_CUST_NO", "type": "STRING"}, {"name": "VC_SELF_CUST_NAME", "type": "STRING"}, {"name": "VC_SELF_MARG_CUST_ACC_NAME", "type": "STRING"}, {"name": "VC_SELF_MARG_ACC_BANK_NO", "type": "STRING"}, {"name": "VC_SELF_MARG_ACC_NO", "type": "STRING"}, {"name": "VC_SELF_MARG_BANK_NAME", "type": "STRING"}, {"name": "VC_SELF_MARG_ACC_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_PARTY_ID", "type": "STRING"}, {"name": "VC_COUNTERPTY_PARTY_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_PARTY_FULL_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_ACC_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_ACC_BANK_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_ACC_NO", "type": "STRING"}, {"name": "VC_COUNTERPTY_ACC_BANK_NO", "type": "STRING"}, {"name": "VC_COUNTERPTY_BOND_ACC_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_BOND_CUST_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_BOND_ACC_NO", "type": "STRING"}, {"name": "VC_COUNTERPTY_TRADER_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_TRADER_CODE", "type": "STRING"}, {"name": "VC_COUNTERPTY_MARG_ACC_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_MARG_BANK_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_MARG_ACC_NO", "type": "STRING"}, {"name": "VC_COUNTERPTY_MARG_ACC_BANK_NO", "type": "STRING"}, {"name": "VC_COUNTERPTY_MARG_CUST_ACC_NM", "type": "STRING"}, {"name": "VC_COUNTERPTY_CUST_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_CUST_NO", "type": "STRING"}, {"name": "VC_COUNTERPTY_CASH_ACC_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_SWIFTCODE", "type": "STRING"}, {"name": "VC_COUNTERPTY_REMARK", "type": "STRING"}, {"name": "VC_COUNTERPTY_FUND_ACC_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_FUND_BANK_NAME", "type": "STRING"}, {"name": "VC_COUNTERPTY_FUND_BANK_NO", "type": "STRING"}, {"name": "VC_QUOTE_NO", "type": "STRING"}, {"name": "VC_EXEC_TYPE", "type": "STRING"}, {"name": "EN_STRIKE_YLD", "type": "DOUBLE"}, {"name": "VC_DEALTRTYPE", "type": "STRING"}, {"name": "VC_TRANSTIME", "type": "STRING"}, {"name": "C_COUPONPAYMENT_INDICATOR", "type": "STRING"}, {"name": "C_CONTINGENCY_INDICATOR", "type": "STRING"}, {"name": "L_START_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_DISSETMET", "type": "DOUBLE"}, {"name": "L_INT_FIX_DATE", "type": "DOUBLE"}, {"name": "L_CALC_AGENCY", "type": "DOUBLE"}, {"name": "C_MARGIN_CHANGE_INDICATOR", "type": "STRING"}, {"name": "C_MARGINREQ", "type": "STRING"}, {"name": "L_SETTL_TYPE", "type": "DOUBLE"}, {"name": "VC_REFERENCE", "type": "STRING"}, {"name": "VC_SELF_ACC_BANK_NAME2", "type": "STRING"}, {"name": "VC_SELF_ACC_BANK_NO2", "type": "STRING"}, {"name": "VC_SELF_BOND_CUST_NAME2", "type": "STRING"}, {"name": "VC_SELF_BOND_ACC_NAME2", "type": "STRING"}, {"name": "VC_SELF_BOND_ACC_NO2", "type": "STRING"}, {"name": "VC_SELF_ACC_NAME2", "type": "STRING"}, {"name": "VC_SELF_ACC_NO2", "type": "STRING"}, {"name": "VC_COUNTERPTY_ACC_BANK_NAME2", "type": "STRING"}, {"name": "VC_COUNTERPTY_ACC_BANK_NO2", "type": "STRING"}, {"name": "VC_COUNTERPTY_BOND_CUST_NAME2", "type": "STRING"}, {"name": "VC_COUNTERPTY_BOND_ACC_NAME2", "type": "STRING"}, {"name": "VC_COUNTERPTY_BOND_ACC_NO2", "type": "STRING"}, {"name": "VC_COUNTERPTY_ACC_NAME2", "type": "STRING"}, {"name": "VC_COUNTERPTY_ACC_NO2", "type": "STRING"}, {"name": "L_TRADE_BALANCE1", "type": "DOUBLE"}, {"name": "EN_ACCRUED_INTEREST_TOTAL_AMT1", "type": "DOUBLE"}, {"name": "EN_SETTLE_END_BALANCE1", "type": "DOUBLE"}, {"name": "EN_TOTAL_FACE_VALUE1", "type": "DOUBLE"}, {"name": "L_TRADE_BALANCE2", "type": "DOUBLE"}, {"name": "EN_ACCRUED_INTEREST_TOTAL_AMT2", "type": "DOUBLE"}, {"name": "EN_SETTLE_END_BALANCE2", "type": "DOUBLE"}, {"name": "EN_TOTAL_FACE_VALUE2", "type": "DOUBLE"}, {"name": "C_FORCE", "type": "STRING"}, {"name": "VC_CLEAR_METHOD", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbankaffiliatesorder_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbankaffiliatesorder_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbankaffiliatesorder_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbankaffiliatesorder_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBANKAFFILIATESORDER_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBANKAFFILIATESORDER_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbankaffiliatesorder_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESORDER_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_TIME
     , VC_MARKET_INDICATOR
     , VC_REPORT_CODE
     , VC_NAME
     , VC_DEAL_NO
     , VC_ORIGINAL_DEAL_NO
     , EN_TOTAL_FACE_VALUE
     , EN_PRICE
     , L_FIRST_SETTLE_DATE
     , L_END_SETTLE_DATE
     , EN_SETTLE_BALANCE
     , EN_SETTLE_END_BALANCE
     , EN_ACCRUED_INTEREST_AMT
     , EN_ACCRUED_INTEREST_TOTAL_AMT
     , EN_MISCFEEAMT
     , VC_CAPTION
     , VC_MATURITY
     , L_TRADE_BALANCE
     , C_SIDE
     , EN_END_YLD
     , EN_DISCOUNT_RATE
     , EN_FULL_PRICE
     , L_LIMIT_DAYS
     , L_HOLD_DAYS
     , C_FIRST_DELIVERY_TYPE
     , C_END_DELIVERY_TYPE
     , C_TRADE_TYPE
     , EN_PRINCIPAL
     , EN_TOTAL_PRINCIPAL
     , EN_BENK_PRICE
     , VC_BENCH_NAME
     , C_INTEREST_ACCRUAL_METHOD
     , EN_IOP_VALUE
     , C_TRADE_METHOD
     , L_PAY_DATE
     , L_SETTLE_DAY_RESET
     , L_INTEREST_DAY_RESET
     , L_FIRST_INTEREST_START_DAY
     , C_ORDER_STATUS
     , VC_SELF_PARTY_ID
     , VC_SELF_PARTY_NAME
     , VC_SELF_PARTY_FULL_NAME
     , VC_SELF_ACC_NAME
     , VC_SELF_ACC_BANK_NAME
     , VC_SELF_ACC_NO
     , VC_SELF_ACC_BANK_NO
     , VC_SELF_BOND_ACC_NAME
     , VC_SELF_BOND_CUST_NAME
     , VC_SELF_BOND_ACC_NO
     , VC_SELF_TRADER_NAME
     , VC_SELF_TRADER_CODE
     , VC_SELF_FUND_BANK_NAME
     , VC_SELF_FUND_ACC_NAME
     , VC_SELF_FUND_BANK_NO
     , VC_SELF_REMARK
     , VC_SELF_SWIFTCODE
     , VC_SELF_CASH_ACC_NAME
     , VC_SELF_CUST_NO
     , VC_SELF_CUST_NAME
     , VC_SELF_MARG_CUST_ACC_NAME
     , VC_SELF_MARG_ACC_BANK_NO
     , VC_SELF_MARG_ACC_NO
     , VC_SELF_MARG_BANK_NAME
     , VC_SELF_MARG_ACC_NAME
     , VC_COUNTERPTY_PARTY_ID
     , VC_COUNTERPTY_PARTY_NAME
     , VC_COUNTERPTY_PARTY_FULL_NAME
     , VC_COUNTERPTY_ACC_NAME
     , VC_COUNTERPTY_ACC_BANK_NAME
     , VC_COUNTERPTY_ACC_NO
     , VC_COUNTERPTY_ACC_BANK_NO
     , VC_COUNTERPTY_BOND_ACC_NAME
     , VC_COUNTERPTY_BOND_CUST_NAME
     , VC_COUNTERPTY_BOND_ACC_NO
     , VC_COUNTERPTY_TRADER_NAME
     , VC_COUNTERPTY_TRADER_CODE
     , VC_COUNTERPTY_MARG_ACC_NAME
     , VC_COUNTERPTY_MARG_BANK_NAME
     , VC_COUNTERPTY_MARG_ACC_NO
     , VC_COUNTERPTY_MARG_ACC_BANK_NO
     , VC_COUNTERPTY_MARG_CUST_ACC_NM
     , VC_COUNTERPTY_CUST_NAME
     , VC_COUNTERPTY_CUST_NO
     , VC_COUNTERPTY_CASH_ACC_NAME
     , VC_COUNTERPTY_SWIFTCODE
     , VC_COUNTERPTY_REMARK
     , VC_COUNTERPTY_FUND_ACC_NAME
     , VC_COUNTERPTY_FUND_BANK_NAME
     , VC_COUNTERPTY_FUND_BANK_NO
     , VC_QUOTE_NO
     , VC_EXEC_TYPE
     , EN_STRIKE_YLD
     , VC_DEALTRTYPE
     , VC_TRANSTIME
     , C_COUPONPAYMENT_INDICATOR
     , C_CONTINGENCY_INDICATOR
     , L_START_DATE
     , L_END_DATE
     , L_DISSETMET
     , L_INT_FIX_DATE
     , L_CALC_AGENCY
     , C_MARGIN_CHANGE_INDICATOR
     , C_MARGINREQ
     , L_SETTL_TYPE
     , VC_REFERENCE
     , VC_SELF_ACC_BANK_NAME2
     , VC_SELF_ACC_BANK_NO2
     , VC_SELF_BOND_CUST_NAME2
     , VC_SELF_BOND_ACC_NAME2
     , VC_SELF_BOND_ACC_NO2
     , VC_SELF_ACC_NAME2
     , VC_SELF_ACC_NO2
     , VC_COUNTERPTY_ACC_BANK_NAME2
     , VC_COUNTERPTY_ACC_BANK_NO2
     , VC_COUNTERPTY_BOND_CUST_NAME2
     , VC_COUNTERPTY_BOND_ACC_NAME2
     , VC_COUNTERPTY_BOND_ACC_NO2
     , VC_COUNTERPTY_ACC_NAME2
     , VC_COUNTERPTY_ACC_NO2
     , L_TRADE_BALANCE1
     , EN_ACCRUED_INTEREST_TOTAL_AMT1
     , EN_SETTLE_END_BALANCE1
     , EN_TOTAL_FACE_VALUE1
     , L_TRADE_BALANCE2
     , EN_ACCRUED_INTEREST_TOTAL_AMT2
     , EN_SETTLE_END_BALANCE2
     , EN_TOTAL_FACE_VALUE2
     , C_FORCE
     , VC_CLEAR_METHOD
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESORDER_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESORDER_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBANKAFFILIATESORDER_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBANKAFFILIATESORDER_PTD成功"
      exit 0
   fi
fi
