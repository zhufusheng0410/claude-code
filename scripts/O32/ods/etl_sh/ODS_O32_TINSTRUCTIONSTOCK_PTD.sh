#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_PRICE_TYPE  STRING  COMMENT  '价格模式',
  EN_PRICE1  DECIMAL(20,12)  COMMENT  '指令价格',
  L_TODAY_ENTRUST_AMOUNT  DECIMAL(20,4)  COMMENT  '当日委托数量',
  EN_TODAY_ENTRUST_BALANCE  DECIMAL(16,2)  COMMENT  '当日委托金额',
  L_TODAY_DEAL_AMOUNT  DECIMAL(20,4)  COMMENT  '当日成交数量',
  EN_TODAY_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '当日成交金额',
  C_INSTRUCTION_STATUS  STRING  COMMENT  '状态',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  EN_PROFIT_RATIO  DECIMAL(16,8)  COMMENT  '到期收益率',
  L_AMOUNT  DECIMAL(20,4)  COMMENT  '指令数量',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '指令金额',
  EN_FACT_PRICE  DECIMAL(20,12)  COMMENT  '实际价格',
  C_ENTRUST_EXECUTE_STATUS  STRING  COMMENT  '委托完成状态',
  C_DEAL_EXECUTE_STATUS  STRING  COMMENT  '成交完成状态',
  C_CASH_CONTROL_TYPE  STRING  COMMENT  '头寸控制方式',
  C_STOCK_CONTROL_TYPE  STRING  COMMENT  '证券控制方式',
  EN_INTEREST  DECIMAL(18,12)  COMMENT  '应计利息',
  C_ORIGINAL_DIRECTION  STRING  COMMENT  '原委托方向',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合序号',
  L_TOTAL_DEAL_AMOUNT  DECIMAL(20,4)  COMMENT  '累计成交数量',
  EN_TOTAL_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '累计成交金额',
  L_TOTAL_ENTRUST_AMOUNT  DECIMAL(20,4)  COMMENT  '累计委托数量',
  EN_TOTAL_ENTRUST_BALANCE  DECIMAL(16,2)  COMMENT  '累计委托金额',
  VC_OTHER_INTER_CODE  STRING  COMMENT  '对方证券代码',
  C_EXCEED_FLAG  STRING  COMMENT  '巨额赎回标志',
  EN_FEE  DECIMAL(16,2)  COMMENT  '手续费用',
  L_CONTRACT_NO  DECIMAL(10,0)  COMMENT  '合同号',
  D_DEAL_COMPLETE_DATE  STRING  COMMENT  '指令成交完成时间',
  C_AMOUNT_BALANCE_FLAG  STRING  COMMENT  '金额证券标志',
  L_ALGO_UNENTRUST_AMOUNT  DECIMAL(18,2)  COMMENT  '算法交易未委托数量',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  EN_EARNEST_BALANCE  DECIMAL(16,2)  COMMENT  '定金金额',
  EN_PRICE2  DECIMAL(20,12)  COMMENT  '价格下限',
  EN_DAILY_MAX  DECIMAL(16,2)  COMMENT  '当日限量',
  EN_INSTR_TARGET_RATIO  DECIMAL(9,8)  COMMENT  '指令目标净值比例',
  EN_COMBI_TARGET_RATIO  DECIMAL(9,8)  COMMENT  '组合目标净值比例',
  C_BUSIN_CLASS  STRING  COMMENT  '指令业务分类',
  EN_ESTIMATE_FEE  DECIMAL(16,2)  COMMENT  '预估费用',
  C_RISK_INFLUENCE_FLAG  STRING  COMMENT  '风控影响标志',
  C_FUND_BONUS_TYPE  STRING  COMMENT  '基金分红方式',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '指令起始日期',
  L_BEGIN_TIME  DECIMAL(6,0)  COMMENT  '指令起始时间',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '指令终止日期',
  L_END_TIME  DECIMAL(6,0)  COMMENT  '指令终止时间',
  L_SETTLE_SPEED  DECIMAL(10,0)  COMMENT  '清算速度',
  L_FIRST_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '交割日',
  C_FIRST_SETTLE_TYPE  STRING  COMMENT  '结算方式',
  L_SECOND_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '到期交割日',
  C_SECOND_SETTLE_TYPE  STRING  COMMENT  '到期结算方式',
  EN_CUM_AVG_PRICE  DECIMAL(20,12)  COMMENT  '累计成交均价',
  EN_DAY_AVG_PRICE  DECIMAL(20,12)  COMMENT  '当日成交均价',
  EN_ALGO_UNENTRUST_BALANCE  DECIMAL(16,2)  COMMENT  '算法交易未委托金额',
  L_COMBI_ARBI_SETS  DECIMAL(12,0)  COMMENT  '组合套利份数',
  L_COMBI_TOENTR_SETS  DECIMAL(12,0)  COMMENT  '组合套利交易的目标份数',
  L_OTHER_COMBI_ID  DECIMAL(10,0)  COMMENT  '其它组合',
  C_OTHER_INVEST_TYPE  STRING  COMMENT  '其它投资类型',
  EN_BASIS  DECIMAL(20,12)  COMMENT  '基差',
  L_TRADE_RIVAL_NO  DECIMAL(10,0)  COMMENT  '交易对手',
  VC_ENGAGED_NO  STRING  COMMENT  '约定号',
  L_STOCK_SERIAL_NO  DECIMAL(10,0)  COMMENT  '指令证券序号',
  L_QUOTATION_OPERATOR  DECIMAL(8,0)  COMMENT  '报价人',
  EN_SPRING_PRICE  DECIMAL(20,12)  COMMENT  '止损盈触发价格',
  VC_RIVALTRADER_NAME  STRING  COMMENT  '对手交易员姓名',
  L_RIVALACCOUNT_NO  DECIMAL(10,0)  COMMENT  '对手银行账户',
  C_TRADE_TYPE  STRING  COMMENT  '交易类别',
  VC_RIVAL_SEAT  STRING  COMMENT  '对手席位',
  C_CLEAR_TYPE  STRING  COMMENT  '清算类型',
  VC_RIVALTRADER_ID  STRING  COMMENT  '对手交易员id',
  VC_RIVAL_BANK_ACCOUNT  STRING  COMMENT  '对手银行间托管帐号',
  EN_PREPAY_BALANCE  DECIMAL(16,2)  COMMENT  '预扣款',
  C_YIELD_RATIO_TYPE  STRING  COMMENT  '收益率类型',
  C_INNER_RISK_INFLUENCE_FLAG  STRING  COMMENT  '风控影响标志内部',
  C_COVERED  STRING  COMMENT  '是否备兑',
  VC_RIVAL_HOLDER  STRING  COMMENT  '对手股东',
  VC_SOURCE_NO  STRING  COMMENT  '来源编号',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司号',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '部门号',
  L_OTHER_FUND_ID  DECIMAL(8,0)  COMMENT  '转入基金序号',
  C_AUTODROP_FLAG  STRING  COMMENT  '期货自动平仓',
  C_RESERVE_FLAG  STRING  COMMENT  '保留期货头寸',
  VC_ORIGIN_CONTRACT_NO  STRING  COMMENT  '协议回购合同号',
  EN_CONTRACT_BALANCE  DECIMAL(16,2)  COMMENT  '协议回购到期金额',
  C_MULTI_INS_RELATE_FLAG  STRING  COMMENT  '指令证券关联标记',
  C_CHANNEL_NO  STRING  COMMENT  '基金通道号',
  VC_SALEORG_CODE  STRING  COMMENT  '销售机构',
  C_CLEAR_MODE  STRING  COMMENT  '清算方式',
  C_INSTITUTION_TYPE  STRING  COMMENT  '计算机构',
  C_BULKUNDERWEIGHT_FLAG  STRING  COMMENT  '受限股',
  C_FISP_FLAG  STRING  COMMENT  'fisp通道',
  C_MATCH_STATUS  STRING  COMMENT  '匹配状态',
  EN_RISK_GGT  DECIMAL(18,2)  COMMENT  '港股风险资金',
  VC_VOTE_SENATE_NO  STRING  COMMENT  '议案编号',
  C_EXPORT_FLAG  STRING  COMMENT  '导出状态',
  VC_COMPACT_ID  STRING  COMMENT  '合约编号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_REPORT_REFID  STRING  COMMENT  '',
  L_RESTRICTED_NO  DECIMAL(10,0)  COMMENT  '',
  EN_PRICEBP  DECIMAL(8,0)  COMMENT  '',
  C_STRATEGY_PLACING  STRING  COMMENT  '',
  C_PRINT_STATUS  STRING  COMMENT  '打印状态',
  C_CASHGROUP_PROP  STRING  COMMENT  '',
  L_BONDLENDING_AMOUNT  DECIMAL(20,4)  COMMENT  '银行间债券卖空',
  L_DEAL_BONDLENDING_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  C_FASTREDEMPTION_FLAG  STRING  COMMENT  '',
  EN_TARGET_VALUE  DECIMAL(20,6)  COMMENT  '目标值',
  L_VIRTUAL_COMBI_ID  DECIMAL(12,0)  COMMENT  '事实组合ID',
  L_CASHGROUP_ID  DECIMAL(19,0)  COMMENT  '',
  L_OPEN_DATE  DECIMAL(8,0)  COMMENT  '开放日',
  C_FIX_SETTLE_TYPE  STRING  COMMENT  'FIX清算类型',
  C_RESTRICTED_FLAG  STRING  COMMENT  '限制标志',
  L_ENTURST_BONDLENDING_AMOUNT  DECIMAL(18,4)  COMMENT  '',
  EN_PROFIT_RATIO2  DECIMAL(16,8)  COMMENT  '到期收益率',
  L_MANAGER_OPERTOR  DECIMAL(8,0)  COMMENT  '操作管理员',
  L_AFFILIATION  DECIMAL(12,0)  COMMENT  '归属',
  L_REAL_TRADE_RIVAL_NO  STRING  COMMENT  '实际交易对手编号',
  C_ORDERRESTRICTIONS  STRING  COMMENT  '订单限制',
  VC_RIVAL_MARKET_REMARK  STRING  COMMENT  '',
  VC_REPORT_SEAT  STRING  COMMENT  '席位',
  C_KC_FACTPRICETYPE  STRING  COMMENT  '',
  L_OTHER_AFFILIATION  DECIMAL(12,0)  COMMENT  '',
  C_CASH_SETTLE_TYPE  STRING  COMMENT  '清算基金类型',
  L_TARGET_ASSET_ID  DECIMAL(8,0)  COMMENT  '目标资产号',
  L_REDEEM_LIQUIDATE  DECIMAL(8,0)  COMMENT  '实际购回日期',
  L_INQUIRE_ID  DECIMAL(10,0)  COMMENT  '询价序号',
  EN_CHANGE_RATIO  DECIMAL(16,8)  COMMENT  '',
  C_CASH_STATUS  STRING  COMMENT  '兑付状态',
  L_CASH_DATETIME  DECIMAL(14,0)  COMMENT  '兑付日期',
  VC_RIVALMEMBER_ID  STRING  COMMENT  '',
  VC_RIVALINVESTOR_ID  STRING  COMMENT  '',
  VC_RIVALINVESTOR_NAME  STRING  COMMENT  '',
  VC_RIVALINVESTOR_TYPE  STRING  COMMENT  ''
)
COMMENT '指令证券表'
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
                                   , VC_INTER_CODE
                                   , C_ENTRUST_DIRECTION
                                   , C_PRICE_TYPE
                                   , EN_PRICE1
                                   , L_TODAY_ENTRUST_AMOUNT
                                   , EN_TODAY_ENTRUST_BALANCE
                                   , L_TODAY_DEAL_AMOUNT
                                   , EN_TODAY_DEAL_BALANCE
                                   , C_INSTRUCTION_STATUS
                                   , C_INVEST_TYPE
                                   , EN_PROFIT_RATIO
                                   , L_AMOUNT
                                   , EN_BALANCE
                                   , EN_FACT_PRICE
                                   , C_ENTRUST_EXECUTE_STATUS
                                   , C_DEAL_EXECUTE_STATUS
                                   , C_CASH_CONTROL_TYPE
                                   , C_STOCK_CONTROL_TYPE
                                   , EN_INTEREST
                                   , C_ORIGINAL_DIRECTION
                                   , L_BASECOMBI_ID
                                   , L_TOTAL_DEAL_AMOUNT
                                   , EN_TOTAL_DEAL_BALANCE
                                   , L_TOTAL_ENTRUST_AMOUNT
                                   , EN_TOTAL_ENTRUST_BALANCE
                                   , VC_OTHER_INTER_CODE
                                   , C_EXCEED_FLAG
                                   , EN_FEE
                                   , L_CONTRACT_NO
                                   , D_DEAL_COMPLETE_DATE
                                   , C_AMOUNT_BALANCE_FLAG
                                   , L_ALGO_UNENTRUST_AMOUNT
                                   , L_FUND_ID
                                   , EN_EARNEST_BALANCE
                                   , EN_PRICE2
                                   , EN_DAILY_MAX
                                   , EN_INSTR_TARGET_RATIO
                                   , EN_COMBI_TARGET_RATIO
                                   , C_BUSIN_CLASS
                                   , EN_ESTIMATE_FEE
                                   , C_RISK_INFLUENCE_FLAG
                                   , C_FUND_BONUS_TYPE
                                   , L_BEGIN_DATE
                                   , L_BEGIN_TIME
                                   , L_END_DATE
                                   , L_END_TIME
                                   , L_SETTLE_SPEED
                                   , L_FIRST_SETTLE_DATE
                                   , C_FIRST_SETTLE_TYPE
                                   , L_SECOND_SETTLE_DATE
                                   , C_SECOND_SETTLE_TYPE
                                   , EN_CUM_AVG_PRICE
                                   , EN_DAY_AVG_PRICE
                                   , EN_ALGO_UNENTRUST_BALANCE
                                   , L_COMBI_ARBI_SETS
                                   , L_COMBI_TOENTR_SETS
                                   , L_OTHER_COMBI_ID
                                   , C_OTHER_INVEST_TYPE
                                   , EN_BASIS
                                   , L_TRADE_RIVAL_NO
                                   , VC_ENGAGED_NO
                                   , L_STOCK_SERIAL_NO
                                   , L_QUOTATION_OPERATOR
                                   , EN_SPRING_PRICE
                                   , VC_RIVALTRADER_NAME
                                   , L_RIVALACCOUNT_NO
                                   , C_TRADE_TYPE
                                   , VC_RIVAL_SEAT
                                   , C_CLEAR_TYPE
                                   , VC_RIVALTRADER_ID
                                   , VC_RIVAL_BANK_ACCOUNT
                                   , EN_PREPAY_BALANCE
                                   , C_YIELD_RATIO_TYPE
                                   , C_INNER_RISK_INFLUENCE_FLAG
                                   , C_COVERED
                                   , VC_RIVAL_HOLDER
                                   , VC_SOURCE_NO
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , L_OTHER_FUND_ID
                                   , C_AUTODROP_FLAG
                                   , C_RESERVE_FLAG
                                   , VC_ORIGIN_CONTRACT_NO
                                   , EN_CONTRACT_BALANCE
                                   , C_MULTI_INS_RELATE_FLAG
                                   , C_CHANNEL_NO
                                   , VC_SALEORG_CODE
                                   , C_CLEAR_MODE
                                   , C_INSTITUTION_TYPE
                                   , C_BULKUNDERWEIGHT_FLAG
                                   , C_FISP_FLAG
                                   , C_MATCH_STATUS
                                   , EN_RISK_GGT
                                   , VC_VOTE_SENATE_NO
                                   , C_EXPORT_FLAG
                                   , VC_COMPACT_ID
                                   , VC_STOCKHOLDER_ID
                                   , VC_REPORT_REFID
                                   , L_RESTRICTED_NO
                                   , EN_PRICEBP
                                   , C_STRATEGY_PLACING
                                   , C_PRINT_STATUS
                                   , C_CASHGROUP_PROP
                                   , L_BONDLENDING_AMOUNT
                                   , L_DEAL_BONDLENDING_AMOUNT
                                   , C_FASTREDEMPTION_FLAG
                                   , EN_TARGET_VALUE
                                   , L_VIRTUAL_COMBI_ID
                                   , L_CASHGROUP_ID
                                   , L_OPEN_DATE
                                   , C_FIX_SETTLE_TYPE
                                   , C_RESTRICTED_FLAG
                                   , L_ENTURST_BONDLENDING_AMOUNT
                                   , EN_PROFIT_RATIO2
                                   , L_MANAGER_OPERTOR
                                   , L_AFFILIATION
                                   , L_REAL_TRADE_RIVAL_NO
                                   , C_ORDERRESTRICTIONS
                                   , VC_RIVAL_MARKET_REMARK
                                   , VC_REPORT_SEAT
                                   , C_KC_FACTPRICETYPE
                                   , L_OTHER_AFFILIATION
                                   , C_CASH_SETTLE_TYPE
                                   , L_TARGET_ASSET_ID
                                   , L_REDEEM_LIQUIDATE
                                   , L_INQUIRE_ID
                                   , EN_CHANGE_RATIO
                                   , C_CASH_STATUS
                                   , L_CASH_DATETIME
                                   , VC_RIVALMEMBER_ID
                                   , VC_RIVALINVESTOR_ID
                                   , VC_RIVALINVESTOR_NAME
                                   , VC_RIVALINVESTOR_TYPE
                                FROM ${o32_src_schema}.THISINSTRUCTIONSTOCK
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_PRICE_TYPE", "type": "STRING"}, {"name": "EN_PRICE1", "type": "DOUBLE"}, {"name": "L_TODAY_ENTRUST_AMOUNT", "type": "DOUBLE"}, {"name": "EN_TODAY_ENTRUST_BALANCE", "type": "DOUBLE"}, {"name": "L_TODAY_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_TODAY_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "C_INSTRUCTION_STATUS", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "EN_PROFIT_RATIO", "type": "DOUBLE"}, {"name": "L_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_FACT_PRICE", "type": "DOUBLE"}, {"name": "C_ENTRUST_EXECUTE_STATUS", "type": "STRING"}, {"name": "C_DEAL_EXECUTE_STATUS", "type": "STRING"}, {"name": "C_CASH_CONTROL_TYPE", "type": "STRING"}, {"name": "C_STOCK_CONTROL_TYPE", "type": "STRING"}, {"name": "EN_INTEREST", "type": "DOUBLE"}, {"name": "C_ORIGINAL_DIRECTION", "type": "STRING"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_TOTAL_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_TOTAL_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_TOTAL_ENTRUST_AMOUNT", "type": "DOUBLE"}, {"name": "EN_TOTAL_ENTRUST_BALANCE", "type": "DOUBLE"}, {"name": "VC_OTHER_INTER_CODE", "type": "STRING"}, {"name": "C_EXCEED_FLAG", "type": "STRING"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "L_CONTRACT_NO", "type": "DOUBLE"}, {"name": "D_DEAL_COMPLETE_DATE", "type": "STRING"}, {"name": "C_AMOUNT_BALANCE_FLAG", "type": "STRING"}, {"name": "L_ALGO_UNENTRUST_AMOUNT", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "EN_EARNEST_BALANCE", "type": "DOUBLE"}, {"name": "EN_PRICE2", "type": "DOUBLE"}, {"name": "EN_DAILY_MAX", "type": "DOUBLE"}, {"name": "EN_INSTR_TARGET_RATIO", "type": "DOUBLE"}, {"name": "EN_COMBI_TARGET_RATIO", "type": "DOUBLE"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "EN_ESTIMATE_FEE", "type": "DOUBLE"}, {"name": "C_RISK_INFLUENCE_FLAG", "type": "STRING"}, {"name": "C_FUND_BONUS_TYPE", "type": "STRING"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_BEGIN_TIME", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_END_TIME", "type": "DOUBLE"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "L_FIRST_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_FIRST_SETTLE_TYPE", "type": "STRING"}, {"name": "L_SECOND_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_SECOND_SETTLE_TYPE", "type": "STRING"}, {"name": "EN_CUM_AVG_PRICE", "type": "DOUBLE"}, {"name": "EN_DAY_AVG_PRICE", "type": "DOUBLE"}, {"name": "EN_ALGO_UNENTRUST_BALANCE", "type": "DOUBLE"}, {"name": "L_COMBI_ARBI_SETS", "type": "DOUBLE"}, {"name": "L_COMBI_TOENTR_SETS", "type": "DOUBLE"}, {"name": "L_OTHER_COMBI_ID", "type": "DOUBLE"}, {"name": "C_OTHER_INVEST_TYPE", "type": "STRING"}, {"name": "EN_BASIS", "type": "DOUBLE"}, {"name": "L_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "VC_ENGAGED_NO", "type": "STRING"}, {"name": "L_STOCK_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_QUOTATION_OPERATOR", "type": "DOUBLE"}, {"name": "EN_SPRING_PRICE", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_NAME", "type": "STRING"}, {"name": "L_RIVALACCOUNT_NO", "type": "DOUBLE"}, {"name": "C_TRADE_TYPE", "type": "STRING"}, {"name": "VC_RIVAL_SEAT", "type": "STRING"}, {"name": "C_CLEAR_TYPE", "type": "STRING"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "VC_RIVAL_BANK_ACCOUNT", "type": "STRING"}, {"name": "EN_PREPAY_BALANCE", "type": "DOUBLE"}, {"name": "C_YIELD_RATIO_TYPE", "type": "STRING"}, {"name": "C_INNER_RISK_INFLUENCE_FLAG", "type": "STRING"}, {"name": "C_COVERED", "type": "STRING"}, {"name": "VC_RIVAL_HOLDER", "type": "STRING"}, {"name": "VC_SOURCE_NO", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "L_OTHER_FUND_ID", "type": "DOUBLE"}, {"name": "C_AUTODROP_FLAG", "type": "STRING"}, {"name": "C_RESERVE_FLAG", "type": "STRING"}, {"name": "VC_ORIGIN_CONTRACT_NO", "type": "STRING"}, {"name": "EN_CONTRACT_BALANCE", "type": "DOUBLE"}, {"name": "C_MULTI_INS_RELATE_FLAG", "type": "STRING"}, {"name": "C_CHANNEL_NO", "type": "STRING"}, {"name": "VC_SALEORG_CODE", "type": "STRING"}, {"name": "C_CLEAR_MODE", "type": "STRING"}, {"name": "C_INSTITUTION_TYPE", "type": "STRING"}, {"name": "C_BULKUNDERWEIGHT_FLAG", "type": "STRING"}, {"name": "C_FISP_FLAG", "type": "STRING"}, {"name": "C_MATCH_STATUS", "type": "STRING"}, {"name": "EN_RISK_GGT", "type": "DOUBLE"}, {"name": "VC_VOTE_SENATE_NO", "type": "STRING"}, {"name": "C_EXPORT_FLAG", "type": "STRING"}, {"name": "VC_COMPACT_ID", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_REPORT_REFID", "type": "STRING"}, {"name": "L_RESTRICTED_NO", "type": "DOUBLE"}, {"name": "EN_PRICEBP", "type": "DOUBLE"}, {"name": "C_STRATEGY_PLACING", "type": "STRING"}, {"name": "C_PRINT_STATUS", "type": "STRING"}, {"name": "C_CASHGROUP_PROP", "type": "STRING"}, {"name": "L_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "L_DEAL_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "C_FASTREDEMPTION_FLAG", "type": "STRING"}, {"name": "EN_TARGET_VALUE", "type": "DOUBLE"}, {"name": "L_VIRTUAL_COMBI_ID", "type": "DOUBLE"}, {"name": "L_CASHGROUP_ID", "type": "DOUBLE"}, {"name": "L_OPEN_DATE", "type": "DOUBLE"}, {"name": "C_FIX_SETTLE_TYPE", "type": "STRING"}, {"name": "C_RESTRICTED_FLAG", "type": "STRING"}, {"name": "L_ENTURST_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "EN_PROFIT_RATIO2", "type": "DOUBLE"}, {"name": "L_MANAGER_OPERTOR", "type": "DOUBLE"}, {"name": "L_AFFILIATION", "type": "DOUBLE"}, {"name": "L_REAL_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "C_ORDERRESTRICTIONS", "type": "STRING"}, {"name": "VC_RIVAL_MARKET_REMARK", "type": "STRING"}, {"name": "VC_REPORT_SEAT", "type": "STRING"}, {"name": "C_KC_FACTPRICETYPE", "type": "STRING"}, {"name": "L_OTHER_AFFILIATION", "type": "DOUBLE"}, {"name": "C_CASH_SETTLE_TYPE", "type": "STRING"}, {"name": "L_TARGET_ASSET_ID", "type": "DOUBLE"}, {"name": "L_REDEEM_LIQUIDATE", "type": "DOUBLE"}, {"name": "L_INQUIRE_ID", "type": "DOUBLE"}, {"name": "EN_CHANGE_RATIO", "type": "DOUBLE"}, {"name": "C_CASH_STATUS", "type": "STRING"}, {"name": "L_CASH_DATETIME", "type": "DOUBLE"}, {"name": "VC_RIVALMEMBER_ID", "type": "STRING"}, {"name": "VC_RIVALINVESTOR_ID", "type": "STRING"}, {"name": "VC_RIVALINVESTOR_NAME", "type": "STRING"}, {"name": "VC_RIVALINVESTOR_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tinstructionstock_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tinstructionstock_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tinstructionstock_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tinstructionstock_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TINSTRUCTIONSTOCK_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TINSTRUCTIONSTOCK_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tinstructionstock_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , VC_INTER_CODE
     , C_ENTRUST_DIRECTION
     , C_PRICE_TYPE
     , EN_PRICE1
     , L_TODAY_ENTRUST_AMOUNT
     , EN_TODAY_ENTRUST_BALANCE
     , L_TODAY_DEAL_AMOUNT
     , EN_TODAY_DEAL_BALANCE
     , C_INSTRUCTION_STATUS
     , C_INVEST_TYPE
     , EN_PROFIT_RATIO
     , L_AMOUNT
     , EN_BALANCE
     , EN_FACT_PRICE
     , C_ENTRUST_EXECUTE_STATUS
     , C_DEAL_EXECUTE_STATUS
     , C_CASH_CONTROL_TYPE
     , C_STOCK_CONTROL_TYPE
     , EN_INTEREST
     , C_ORIGINAL_DIRECTION
     , L_BASECOMBI_ID
     , L_TOTAL_DEAL_AMOUNT
     , EN_TOTAL_DEAL_BALANCE
     , L_TOTAL_ENTRUST_AMOUNT
     , EN_TOTAL_ENTRUST_BALANCE
     , VC_OTHER_INTER_CODE
     , C_EXCEED_FLAG
     , EN_FEE
     , L_CONTRACT_NO
     , D_DEAL_COMPLETE_DATE
     , C_AMOUNT_BALANCE_FLAG
     , L_ALGO_UNENTRUST_AMOUNT
     , L_FUND_ID
     , EN_EARNEST_BALANCE
     , EN_PRICE2
     , EN_DAILY_MAX
     , EN_INSTR_TARGET_RATIO
     , EN_COMBI_TARGET_RATIO
     , C_BUSIN_CLASS
     , EN_ESTIMATE_FEE
     , C_RISK_INFLUENCE_FLAG
     , C_FUND_BONUS_TYPE
     , L_BEGIN_DATE
     , L_BEGIN_TIME
     , L_END_DATE
     , L_END_TIME
     , L_SETTLE_SPEED
     , L_FIRST_SETTLE_DATE
     , C_FIRST_SETTLE_TYPE
     , L_SECOND_SETTLE_DATE
     , C_SECOND_SETTLE_TYPE
     , EN_CUM_AVG_PRICE
     , EN_DAY_AVG_PRICE
     , EN_ALGO_UNENTRUST_BALANCE
     , L_COMBI_ARBI_SETS
     , L_COMBI_TOENTR_SETS
     , L_OTHER_COMBI_ID
     , C_OTHER_INVEST_TYPE
     , EN_BASIS
     , L_TRADE_RIVAL_NO
     , VC_ENGAGED_NO
     , L_STOCK_SERIAL_NO
     , L_QUOTATION_OPERATOR
     , EN_SPRING_PRICE
     , VC_RIVALTRADER_NAME
     , L_RIVALACCOUNT_NO
     , C_TRADE_TYPE
     , VC_RIVAL_SEAT
     , C_CLEAR_TYPE
     , VC_RIVALTRADER_ID
     , VC_RIVAL_BANK_ACCOUNT
     , EN_PREPAY_BALANCE
     , C_YIELD_RATIO_TYPE
     , C_INNER_RISK_INFLUENCE_FLAG
     , C_COVERED
     , VC_RIVAL_HOLDER
     , VC_SOURCE_NO
     , L_ORG_ID
     , L_DEPT_ID
     , L_OTHER_FUND_ID
     , C_AUTODROP_FLAG
     , C_RESERVE_FLAG
     , VC_ORIGIN_CONTRACT_NO
     , EN_CONTRACT_BALANCE
     , C_MULTI_INS_RELATE_FLAG
     , C_CHANNEL_NO
     , VC_SALEORG_CODE
     , C_CLEAR_MODE
     , C_INSTITUTION_TYPE
     , C_BULKUNDERWEIGHT_FLAG
     , C_FISP_FLAG
     , C_MATCH_STATUS
     , EN_RISK_GGT
     , VC_VOTE_SENATE_NO
     , C_EXPORT_FLAG
     , VC_COMPACT_ID
     , VC_STOCKHOLDER_ID
     , VC_REPORT_REFID
     , L_RESTRICTED_NO
     , EN_PRICEBP
     , C_STRATEGY_PLACING
     , C_PRINT_STATUS
     , C_CASHGROUP_PROP
     , L_BONDLENDING_AMOUNT
     , L_DEAL_BONDLENDING_AMOUNT
     , C_FASTREDEMPTION_FLAG
     , EN_TARGET_VALUE
     , L_VIRTUAL_COMBI_ID
     , L_CASHGROUP_ID
     , L_OPEN_DATE
     , C_FIX_SETTLE_TYPE
     , C_RESTRICTED_FLAG
     , L_ENTURST_BONDLENDING_AMOUNT
     , EN_PROFIT_RATIO2
     , L_MANAGER_OPERTOR
     , L_AFFILIATION
     , L_REAL_TRADE_RIVAL_NO
     , C_ORDERRESTRICTIONS
     , VC_RIVAL_MARKET_REMARK
     , VC_REPORT_SEAT
     , C_KC_FACTPRICETYPE
     , L_OTHER_AFFILIATION
     , C_CASH_SETTLE_TYPE
     , L_TARGET_ASSET_ID
     , L_REDEEM_LIQUIDATE
     , L_INQUIRE_ID
     , EN_CHANGE_RATIO
     , C_CASH_STATUS
     , L_CASH_DATETIME
     , VC_RIVALMEMBER_ID
     , VC_RIVALINVESTOR_ID
     , VC_RIVALINVESTOR_NAME
     , VC_RIVALINVESTOR_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONSTOCK_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TINSTRUCTIONSTOCK_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TINSTRUCTIONSTOCK_PTD成功"
      exit 0
   fi
fi
