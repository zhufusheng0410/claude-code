#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TENTRUSTS_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTS_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_ENTRUST_SERIAL_NO  DECIMAL(10,0)  COMMENT  '委托序号',
  L_BATCH_SERIAL_NO  DECIMAL(10,0)  COMMENT  '委托批号',
  L_REPORT_SERIAL_NO  STRING  COMMENT  '申报编号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  VC_REPORT_CODE  STRING  COMMENT  '申报代码',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_REPORT_SEAT  STRING  COMMENT  '申报席位',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_FUND_DIRECTION  STRING  COMMENT  '资金方向',
  C_STOCK_DIRECTION  STRING  COMMENT  '证券方向',
  VC_REPORT_DIRECTION  STRING  COMMENT  '申报方向',
  EN_ENTRUST_PRICE  DECIMAL(16,8)  COMMENT  '委托价格',
  L_ENTRUST_AMOUNT  DECIMAL(16,0)  COMMENT  '委托数量',
  EN_PREBUY_FROZEN_BALANCE  DECIMAL(16,2)  COMMENT  '买入预冻结资金',
  L_ENTRUST_TIME  DECIMAL(6,0)  COMMENT  '委托时间',
  L_REPORT_TIME  DECIMAL(6,0)  COMMENT  '申报时间',
  L_FIRST_BUSIN_TIME  DECIMAL(6,0)  COMMENT  '首成交时间',
  L_BUSIN_AMOUNT  DECIMAL(16,0)  COMMENT  '当天成交数量',
  EN_BUSIN_BALANCE  DECIMAL(16,2)  COMMENT  '当天成交金额',
  L_CANCEL_AMOUNT  DECIMAL(16,0)  COMMENT  '撤单数量',
  L_BUSIN_TIMES  DECIMAL(10,0)  COMMENT  '分笔成交次数',
  L_OPERATOR_NO  STRING  COMMENT  '交易员代码',
  VC_REVOKE_CAUSE  STRING  COMMENT  '撤单原因',
  C_ENTRUST_STATUS  STRING  COMMENT  '*委托状态',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_ASSET_TYPE  STRING  COMMENT  '资产类别',
  C_PRICE_TYPE  STRING  COMMENT  '委托价格类型',
  EN_FACT_PRICE  DECIMAL(16,8)  COMMENT  '实际价格',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  C_FROZEN_TYPE  STRING  COMMENT  '委托冻结方式',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  L_AUTOTRADE_NO  DECIMAL(10,0)  COMMENT  '自动交易序号',
  C_FAIR_FLAG  STRING  COMMENT  '公平交易',
  VC_BROKER_NO  STRING  COMMENT  '券商编号',
  VC_BROKER_ACCOUNT  STRING  COMMENT  '券商账号',
  VC_VALID_TYPE  STRING  COMMENT  '有效类型',
  VC_CONFIRM_NO  STRING  COMMENT  '委托确认号',
  L_CANCEL_SERIAL_NO  DECIMAL(10,0)  COMMENT  '被撤单委托序号',
  L_VALID_DATE  DECIMAL(8,0)  COMMENT  '有效日期',
  D_DATETIME  STRING  COMMENT  '时间戳',
  L_TOTAL_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '累计成交数量',
  EN_TOTAL_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '累计成交金额',
  L_DIRECT_DATE  DECIMAL(8,0)  COMMENT  '委托下达日期',
  VC_SEAT_ID  STRING  COMMENT  '持仓席位',
  L_MARKET_VALID_DATE  DECIMAL(8,0)  COMMENT  '市场有效日期',
  VC_RIC_CODE  STRING  COMMENT  '路透代码',
  C_LAUNCH_FLAG  STRING  COMMENT  '*委托方式',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '委托金额',
  EN_PRESALE_BALANCE  DECIMAL(16,2)  COMMENT  '预卖金额',
  C_BUSIN_CLASS  STRING  COMMENT  '业务分类',
  C_CAN_WITHDRAW  STRING  COMMENT  '是否不允许继续撤单',
  L_REC_NUM  DECIMAL(10,0)  COMMENT  '申报记录号',
  L_CANCEL_REC_NUM  DECIMAL(10,0)  COMMENT  '被撤委托申报记录号',
  L_TARGET_COMBI_ID  DECIMAL(10,0)  COMMENT  '目标组合序号',
  C_CANCEL_FLAG  STRING  COMMENT  '＃撤单标志',
  EN_ALLOCATION_TAIL  DECIMAL(10,8)  COMMENT  '＃上次成交分配的尾数',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  C_DMA  STRING  COMMENT  '＃委托处理方式',
  C_EXTERNAL_DEAL_FLAG  STRING  COMMENT  '外部处理标志',
  VC_ALGO_ORDID  STRING  COMMENT  '算法交易子单号',
  L_COMP_ID  DECIMAL(10,0)  COMMENT  '算法交易提供商',
  VC_REPORT_SERIAL_NO_BRANCH  STRING  COMMENT  '分仓申报编号',
  L_INSTANCE_ID  DECIMAL(12,0)  COMMENT  '交易实例序号',
  VC_RIVAL_SEAT  STRING  COMMENT  '对方席位号',
  VC_ENGAGED_NO  STRING  COMMENT  '约定号',
  C_APPLY_COMPLETE_FLAG  STRING  COMMENT  '申购完成标志',
  C_FIXSEND_FLAG  STRING  COMMENT  'fix发送标志',
  C_TARGET_INVEST_TYPE  STRING  COMMENT  '目标投资类型',
  L_SCHEMA_ID  DECIMAL(10,0)  COMMENT  '方案号',
  L_PERIOD  DECIMAL(3,0)  COMMENT  '期限天数',
  VC_RIVAL_CONTRACT_NO  STRING  COMMENT  '对手方合约号',
  EN_SPRING_PRICE  DECIMAL(16,8)  COMMENT  '触发价',
  VC_CONTRACT_NO  STRING  COMMENT  '本方合约号',
  C_CLOSE_DIRECTION  STRING  COMMENT  '平仓方向',
  VC_ORIGINALSERIAL_NO  STRING  COMMENT  '原ta确认编号',
  VC_THIRD_REFF  STRING  COMMENT  '第三方系统备注',
  C_ENTRUST_ORIGIN  STRING  COMMENT  '委托来源',
  VC_RIVAL_HOLDERID  STRING  COMMENT  '对手方股东',
  L_INVEST_ADVISER  DECIMAL(8,0)  COMMENT  '投资顾问',
  L_DETAIL_ID  DECIMAL(10,0)  COMMENT  '明细序号',
  C_SPECIAL_FLAG  STRING  COMMENT  '特殊业务标识',
  L_TRACE_NO  DECIMAL(4,0)  COMMENT  '是否追单',
  C_UFT_FLAG  STRING  COMMENT  '#是否uft标志',
  VC_TRAN_REFF  STRING  COMMENT  '转换机备注',
  L_EXTSYSTEM_ID  DECIMAL(8,0)  COMMENT  '第三方系统自定义号',
  EN_MIN_VOLUME  DECIMAL(12,0)  COMMENT  '最小成交量',
  C_TRADE_OPTION  STRING  COMMENT  '交易选项',
  EN_PREBUY_DEPFRZ_BALANCE  DECIMAL(16,2)  COMMENT  '预买保证金冻结',
  VC_IP_ADDRESS  STRING  COMMENT  'ip地址',
  VC_MAC  STRING  COMMENT  'mac地址',
  VC_VOLSERIAL_NO  STRING  COMMENT  '硬盘序列号',
  VC_ADVISER_STATION  STRING  COMMENT  '投顾站点',
  VC_TERMINALINFO_EXTEND  STRING  COMMENT  '终端扩展信息',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '所属公司',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '所属部门',
  C_AUTODROP_FLAG  STRING  COMMENT  '期货自动平仓',
  C_RESERVE_FLAG  STRING  COMMENT  '保留期货头寸',
  L_RIVAL_ID  DECIMAL(10,0)  COMMENT  '交易对手',
  L_HG_DAYS  DECIMAL(10,0)  COMMENT  '回购天数',
  VC_ORIGIN_CONTRACT_NO  STRING  COMMENT  '协议回购合同号',
  L_ORIGIN_OPEN_DATE  DECIMAL(8,0)  COMMENT  '原开仓日期',
  VC_ORIGIN_DEAL_NO  STRING  COMMENT  '原成交编号',
  C_NICKED  STRING  COMMENT  '匿名申报',
  L_ICEQTY_AMOUNT  DECIMAL(12,0)  COMMENT  '冰山订单数',
  VC_RIVALTRADER_ID  STRING  COMMENT  '对手交易员',
  C_BULKUNDERWEIGHT_FLAG  STRING  COMMENT  '受限股',
  VC_SUMMARY  STRING  COMMENT  '备注',
  C_HAND_FLAG  STRING  COMMENT  '手工补录委托标记',
  C_SUB_BUSIN_CLASS  STRING  COMMENT  '业务子类',
  L_FUNC_ID  DECIMAL(10,0)  COMMENT  '分仓功能号',
  VC_VOTE_SENATE_NO  STRING  COMMENT  '议案编号',
  VC_ENTRUST_FLAG  STRING  COMMENT  '报价标识',
  EN_DIF_FROZEN_BALANCE  DECIMAL(16,2)  COMMENT  '差值冻结金额',
  L_CONFIRM_TIME  DECIMAL(6,0)  COMMENT  '委托确认时间',
  VC_COMPACT_ID  STRING  COMMENT  '融资融券合约编号',
  VC_RIGHT_TYPE  STRING  COMMENT  '权益类别',
  L_NATURAL_DAY  DECIMAL(8,0)  COMMENT  '自然日',
  VC_REPORT_REFID  STRING  COMMENT  '',
  EN_AVG_DEAL_PRICE  DECIMAL(20,12)  COMMENT  '平均交易价格',
  L_SETTLE_SPEED  DECIMAL(10,0)  COMMENT  '清算速度',
  C_STRATEGY_PLACING  STRING  COMMENT  '',
  L_SECOND_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '结算日期',
  VC_SHARES_NATURE  STRING  COMMENT  '',
  L_INSSCHEME_NO  DECIMAL(10,0)  COMMENT  '',
  L_INQUIRE_ID  DECIMAL(10,0)  COMMENT  '询价序号',
  C_CASHGROUP_PROP  STRING  COMMENT  '',
  C_TREATYHG_FLAG  STRING  COMMENT  '协议回购标志',
  L_HG_BATCH_NO  DECIMAL(10,0)  COMMENT  '协议回购批号',
  VC_RIGHT_NO  STRING  COMMENT  '权限编号',
  C_ALREADY_RELEASE_ENABLE  STRING  COMMENT  '',
  L_CASHGROUP_ID  DECIMAL(19,0)  COMMENT  '',
  L_BONDLENDING_AMOUNT  DECIMAL(20,4)  COMMENT  '银行间债券卖空',
  EN_FROZEN_FEE  DECIMAL(16,2)  COMMENT  '',
  L_RESTRICTED_NO  DECIMAL(10,0)  COMMENT  '',
  L_USE_TODAY_AMOUNT  DECIMAL(16,0)  COMMENT  '当日使用数量',
  C_SETTLE_TYPE  STRING  COMMENT  '清算类型',
  VC_TERMINALINFO_EXTEND_REP  STRING  COMMENT  '',
  VC_RIVAL_MARKET_REMARK  STRING  COMMENT  '',
  C_ETF_AUTO_FLAG  STRING  COMMENT  'ETF自动标志',
  L_MODIFY_SERIAL_NO  DECIMAL(10,0)  COMMENT  '',
  C_MODIFY_FLAG  STRING  COMMENT  '',
  L_ORG_REPORT_SERIAL_NO  DECIMAL(10,0)  COMMENT  '',
  L_DIF_FROZEN_AMOUNT  DECIMAL(12,0)  COMMENT  '',
  EN_DIF_ENTRUST_BALANCE  DECIMAL(16,2)  COMMENT  '',
  C_ENTRUST_MODE  STRING  COMMENT  '',
  C_APPLY_STATUS  STRING  COMMENT  '申请状态',
  C_EXECUTE_STATUS  STRING  COMMENT  '执行状态',
  L_BID_DEAL_TYPE  STRING  COMMENT  '标的交易类型',
  EN_HIGH_LIMIT_PRICE  DECIMAL(16,4)  COMMENT  '',
  EN_LOW_LIMIT_PRICE  DECIMAL(16,4)  COMMENT  '',
  L_ORG_CONFIRM_NO  STRING  COMMENT  '',
  L_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '清算日期',
  C_MARKETMAKE_FLAG  STRING  COMMENT  '',
  C_IS_REPLACE  STRING  COMMENT  '',
  EN_PREBUY_BALANCE_CNY  DECIMAL(16,2)  COMMENT  '',
  EN_PRESALE_BALANCE_CNY  DECIMAL(16,2)  COMMENT  '',
  L_APPEND_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  ''
)
COMMENT '委托表'
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
                                   , L_BATCH_SERIAL_NO
                                   , L_REPORT_SERIAL_NO
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_REPORT_CODE
                                   , C_MARKET_NO
                                   , VC_STOCKHOLDER_ID
                                   , VC_REPORT_SEAT
                                   , C_STOCK_TYPE
                                   , C_ENTRUST_DIRECTION
                                   , C_FUND_DIRECTION
                                   , C_STOCK_DIRECTION
                                   , VC_REPORT_DIRECTION
                                   , EN_ENTRUST_PRICE
                                   , L_ENTRUST_AMOUNT
                                   , EN_PREBUY_FROZEN_BALANCE
                                   , L_ENTRUST_TIME
                                   , L_REPORT_TIME
                                   , L_FIRST_BUSIN_TIME
                                   , L_BUSIN_AMOUNT
                                   , EN_BUSIN_BALANCE
                                   , L_CANCEL_AMOUNT
                                   , L_BUSIN_TIMES
                                   , L_OPERATOR_NO
                                   , VC_REVOKE_CAUSE
                                   , C_ENTRUST_STATUS
                                   , VC_INTER_CODE
                                   , C_ASSET_TYPE
                                   , C_PRICE_TYPE
                                   , EN_FACT_PRICE
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INDEX_DAILY_MODIFY
                                   , C_FROZEN_TYPE
                                   , C_INVEST_TYPE
                                   , L_AUTOTRADE_NO
                                   , C_FAIR_FLAG
                                   , VC_BROKER_NO
                                   , VC_BROKER_ACCOUNT
                                   , VC_VALID_TYPE
                                   , VC_CONFIRM_NO
                                   , L_CANCEL_SERIAL_NO
                                   , L_VALID_DATE
                                   , D_DATETIME
                                   , L_TOTAL_DEAL_AMOUNT
                                   , EN_TOTAL_DEAL_BALANCE
                                   , L_DIRECT_DATE
                                   , VC_SEAT_ID
                                   , L_MARKET_VALID_DATE
                                   , VC_RIC_CODE
                                   , C_LAUNCH_FLAG
                                   , EN_BALANCE
                                   , EN_PRESALE_BALANCE
                                   , C_BUSIN_CLASS
                                   , C_CAN_WITHDRAW
                                   , L_REC_NUM
                                   , L_CANCEL_REC_NUM
                                   , L_TARGET_COMBI_ID
                                   , C_CANCEL_FLAG
                                   , EN_ALLOCATION_TAIL
                                   , L_ASSET_ID
                                   , C_DMA
                                   , C_EXTERNAL_DEAL_FLAG
                                   , VC_ALGO_ORDID
                                   , L_COMP_ID
                                   , VC_REPORT_SERIAL_NO_BRANCH
                                   , L_INSTANCE_ID
                                   , VC_RIVAL_SEAT
                                   , VC_ENGAGED_NO
                                   , C_APPLY_COMPLETE_FLAG
                                   , C_FIXSEND_FLAG
                                   , C_TARGET_INVEST_TYPE
                                   , L_SCHEMA_ID
                                   , L_PERIOD
                                   , VC_RIVAL_CONTRACT_NO
                                   , EN_SPRING_PRICE
                                   , VC_CONTRACT_NO
                                   , C_CLOSE_DIRECTION
                                   , VC_ORIGINALSERIAL_NO
                                   , VC_THIRD_REFF
                                   , C_ENTRUST_ORIGIN
                                   , VC_RIVAL_HOLDERID
                                   , L_INVEST_ADVISER
                                   , L_DETAIL_ID
                                   , C_SPECIAL_FLAG
                                   , L_TRACE_NO
                                   , C_UFT_FLAG
                                   , VC_TRAN_REFF
                                   , L_EXTSYSTEM_ID
                                   , EN_MIN_VOLUME
                                   , C_TRADE_OPTION
                                   , EN_PREBUY_DEPFRZ_BALANCE
                                   , VC_IP_ADDRESS
                                   , VC_MAC
                                   , VC_VOLSERIAL_NO
                                   , VC_ADVISER_STATION
                                   , VC_TERMINALINFO_EXTEND
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , C_AUTODROP_FLAG
                                   , C_RESERVE_FLAG
                                   , L_RIVAL_ID
                                   , L_HG_DAYS
                                   , VC_ORIGIN_CONTRACT_NO
                                   , L_ORIGIN_OPEN_DATE
                                   , VC_ORIGIN_DEAL_NO
                                   , C_NICKED
                                   , L_ICEQTY_AMOUNT
                                   , VC_RIVALTRADER_ID
                                   , C_BULKUNDERWEIGHT_FLAG
                                   , VC_SUMMARY
                                   , C_HAND_FLAG
                                   , C_SUB_BUSIN_CLASS
                                   , L_FUNC_ID
                                   , VC_VOTE_SENATE_NO
                                   , VC_ENTRUST_FLAG
                                   , EN_DIF_FROZEN_BALANCE
                                   , L_CONFIRM_TIME
                                   , VC_COMPACT_ID
                                   , VC_RIGHT_TYPE
                                   , L_NATURAL_DAY
                                   , VC_REPORT_REFID
                                   , EN_AVG_DEAL_PRICE
                                   , L_SETTLE_SPEED
                                   , C_STRATEGY_PLACING
                                   , L_SECOND_SETTLE_DATE
                                   , VC_SHARES_NATURE
                                   , L_INSSCHEME_NO
                                   , L_INQUIRE_ID
                                   , C_CASHGROUP_PROP
                                   , C_TREATYHG_FLAG
                                   , L_HG_BATCH_NO
                                   , VC_RIGHT_NO
                                   , C_ALREADY_RELEASE_ENABLE
                                   , L_CASHGROUP_ID
                                   , L_BONDLENDING_AMOUNT
                                   , EN_FROZEN_FEE
                                   , L_RESTRICTED_NO
                                   , L_USE_TODAY_AMOUNT
                                   , C_SETTLE_TYPE
                                   , VC_TERMINALINFO_EXTEND_REP
                                   , VC_RIVAL_MARKET_REMARK
                                   , C_ETF_AUTO_FLAG
                                   , L_MODIFY_SERIAL_NO
                                   , C_MODIFY_FLAG
                                   , L_ORG_REPORT_SERIAL_NO
                                   , L_DIF_FROZEN_AMOUNT
                                   , EN_DIF_ENTRUST_BALANCE
                                   , C_ENTRUST_MODE
                                   , C_APPLY_STATUS
                                   , C_EXECUTE_STATUS
                                   , L_BID_DEAL_TYPE
                                   , EN_HIGH_LIMIT_PRICE
                                   , EN_LOW_LIMIT_PRICE
                                   , L_ORG_CONFIRM_NO
                                   , L_SETTLE_DATE
                                   , C_MARKETMAKE_FLAG
                                   , C_IS_REPLACE
                                   , EN_PREBUY_BALANCE_CNY
                                   , EN_PRESALE_BALANCE_CNY
                                   , L_APPEND_DAILY_INSTRUCTION_NO
                                FROM ${o32_src_schema}.THISENTRUSTS
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_ENTRUST_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_BATCH_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_REPORT_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_REPORT_SEAT", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_FUND_DIRECTION", "type": "STRING"}, {"name": "C_STOCK_DIRECTION", "type": "STRING"}, {"name": "VC_REPORT_DIRECTION", "type": "STRING"}, {"name": "EN_ENTRUST_PRICE", "type": "DOUBLE"}, {"name": "L_ENTRUST_AMOUNT", "type": "DOUBLE"}, {"name": "EN_PREBUY_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "L_ENTRUST_TIME", "type": "DOUBLE"}, {"name": "L_REPORT_TIME", "type": "DOUBLE"}, {"name": "L_FIRST_BUSIN_TIME", "type": "DOUBLE"}, {"name": "L_BUSIN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BUSIN_BALANCE", "type": "DOUBLE"}, {"name": "L_CANCEL_AMOUNT", "type": "DOUBLE"}, {"name": "L_BUSIN_TIMES", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "VC_REVOKE_CAUSE", "type": "STRING"}, {"name": "C_ENTRUST_STATUS", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_ASSET_TYPE", "type": "STRING"}, {"name": "C_PRICE_TYPE", "type": "STRING"}, {"name": "EN_FACT_PRICE", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "C_FROZEN_TYPE", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "L_AUTOTRADE_NO", "type": "DOUBLE"}, {"name": "C_FAIR_FLAG", "type": "STRING"}, {"name": "VC_BROKER_NO", "type": "STRING"}, {"name": "VC_BROKER_ACCOUNT", "type": "STRING"}, {"name": "VC_VALID_TYPE", "type": "STRING"}, {"name": "VC_CONFIRM_NO", "type": "STRING"}, {"name": "L_CANCEL_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_VALID_DATE", "type": "DOUBLE"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "L_TOTAL_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_TOTAL_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_DIRECT_DATE", "type": "DOUBLE"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "L_MARKET_VALID_DATE", "type": "DOUBLE"}, {"name": "VC_RIC_CODE", "type": "STRING"}, {"name": "C_LAUNCH_FLAG", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_PRESALE_BALANCE", "type": "DOUBLE"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "C_CAN_WITHDRAW", "type": "STRING"}, {"name": "L_REC_NUM", "type": "DOUBLE"}, {"name": "L_CANCEL_REC_NUM", "type": "DOUBLE"}, {"name": "L_TARGET_COMBI_ID", "type": "DOUBLE"}, {"name": "C_CANCEL_FLAG", "type": "STRING"}, {"name": "EN_ALLOCATION_TAIL", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "C_DMA", "type": "STRING"}, {"name": "C_EXTERNAL_DEAL_FLAG", "type": "STRING"}, {"name": "VC_ALGO_ORDID", "type": "STRING"}, {"name": "L_COMP_ID", "type": "DOUBLE"}, {"name": "VC_REPORT_SERIAL_NO_BRANCH", "type": "STRING"}, {"name": "L_INSTANCE_ID", "type": "DOUBLE"}, {"name": "VC_RIVAL_SEAT", "type": "STRING"}, {"name": "VC_ENGAGED_NO", "type": "STRING"}, {"name": "C_APPLY_COMPLETE_FLAG", "type": "STRING"}, {"name": "C_FIXSEND_FLAG", "type": "STRING"}, {"name": "C_TARGET_INVEST_TYPE", "type": "STRING"}, {"name": "L_SCHEMA_ID", "type": "DOUBLE"}, {"name": "L_PERIOD", "type": "DOUBLE"}, {"name": "VC_RIVAL_CONTRACT_NO", "type": "STRING"}, {"name": "EN_SPRING_PRICE", "type": "DOUBLE"}, {"name": "VC_CONTRACT_NO", "type": "STRING"}, {"name": "C_CLOSE_DIRECTION", "type": "STRING"}, {"name": "VC_ORIGINALSERIAL_NO", "type": "STRING"}, {"name": "VC_THIRD_REFF", "type": "STRING"}, {"name": "C_ENTRUST_ORIGIN", "type": "STRING"}, {"name": "VC_RIVAL_HOLDERID", "type": "STRING"}, {"name": "L_INVEST_ADVISER", "type": "DOUBLE"}, {"name": "L_DETAIL_ID", "type": "DOUBLE"}, {"name": "C_SPECIAL_FLAG", "type": "STRING"}, {"name": "L_TRACE_NO", "type": "DOUBLE"}, {"name": "C_UFT_FLAG", "type": "STRING"}, {"name": "VC_TRAN_REFF", "type": "STRING"}, {"name": "L_EXTSYSTEM_ID", "type": "DOUBLE"}, {"name": "EN_MIN_VOLUME", "type": "DOUBLE"}, {"name": "C_TRADE_OPTION", "type": "STRING"}, {"name": "EN_PREBUY_DEPFRZ_BALANCE", "type": "DOUBLE"}, {"name": "VC_IP_ADDRESS", "type": "STRING"}, {"name": "VC_MAC", "type": "STRING"}, {"name": "VC_VOLSERIAL_NO", "type": "STRING"}, {"name": "VC_ADVISER_STATION", "type": "STRING"}, {"name": "VC_TERMINALINFO_EXTEND", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "C_AUTODROP_FLAG", "type": "STRING"}, {"name": "C_RESERVE_FLAG", "type": "STRING"}, {"name": "L_RIVAL_ID", "type": "DOUBLE"}, {"name": "L_HG_DAYS", "type": "DOUBLE"}, {"name": "VC_ORIGIN_CONTRACT_NO", "type": "STRING"}, {"name": "L_ORIGIN_OPEN_DATE", "type": "DOUBLE"}, {"name": "VC_ORIGIN_DEAL_NO", "type": "STRING"}, {"name": "C_NICKED", "type": "STRING"}, {"name": "L_ICEQTY_AMOUNT", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "C_BULKUNDERWEIGHT_FLAG", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "C_HAND_FLAG", "type": "STRING"}, {"name": "C_SUB_BUSIN_CLASS", "type": "STRING"}, {"name": "L_FUNC_ID", "type": "DOUBLE"}, {"name": "VC_VOTE_SENATE_NO", "type": "STRING"}, {"name": "VC_ENTRUST_FLAG", "type": "STRING"}, {"name": "EN_DIF_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "L_CONFIRM_TIME", "type": "DOUBLE"}, {"name": "VC_COMPACT_ID", "type": "STRING"}, {"name": "VC_RIGHT_TYPE", "type": "STRING"}, {"name": "L_NATURAL_DAY", "type": "DOUBLE"}, {"name": "VC_REPORT_REFID", "type": "STRING"}, {"name": "EN_AVG_DEAL_PRICE", "type": "DOUBLE"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "C_STRATEGY_PLACING", "type": "STRING"}, {"name": "L_SECOND_SETTLE_DATE", "type": "DOUBLE"}, {"name": "VC_SHARES_NATURE", "type": "STRING"}, {"name": "L_INSSCHEME_NO", "type": "DOUBLE"}, {"name": "L_INQUIRE_ID", "type": "DOUBLE"}, {"name": "C_CASHGROUP_PROP", "type": "STRING"}, {"name": "C_TREATYHG_FLAG", "type": "STRING"}, {"name": "L_HG_BATCH_NO", "type": "DOUBLE"}, {"name": "VC_RIGHT_NO", "type": "STRING"}, {"name": "C_ALREADY_RELEASE_ENABLE", "type": "STRING"}, {"name": "L_CASHGROUP_ID", "type": "DOUBLE"}, {"name": "L_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "EN_FROZEN_FEE", "type": "DOUBLE"}, {"name": "L_RESTRICTED_NO", "type": "DOUBLE"}, {"name": "L_USE_TODAY_AMOUNT", "type": "DOUBLE"}, {"name": "C_SETTLE_TYPE", "type": "STRING"}, {"name": "VC_TERMINALINFO_EXTEND_REP", "type": "STRING"}, {"name": "VC_RIVAL_MARKET_REMARK", "type": "STRING"}, {"name": "C_ETF_AUTO_FLAG", "type": "STRING"}, {"name": "L_MODIFY_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_MODIFY_FLAG", "type": "STRING"}, {"name": "L_ORG_REPORT_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_DIF_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DIF_ENTRUST_BALANCE", "type": "DOUBLE"}, {"name": "C_ENTRUST_MODE", "type": "STRING"}, {"name": "C_APPLY_STATUS", "type": "STRING"}, {"name": "C_EXECUTE_STATUS", "type": "STRING"}, {"name": "L_BID_DEAL_TYPE", "type": "DOUBLE"}, {"name": "EN_HIGH_LIMIT_PRICE", "type": "DOUBLE"}, {"name": "EN_LOW_LIMIT_PRICE", "type": "DOUBLE"}, {"name": "L_ORG_CONFIRM_NO", "type": "STRING"}, {"name": "L_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_MARKETMAKE_FLAG", "type": "STRING"}, {"name": "C_IS_REPLACE", "type": "STRING"}, {"name": "EN_PREBUY_BALANCE_CNY", "type": "DOUBLE"}, {"name": "EN_PRESALE_BALANCE_CNY", "type": "DOUBLE"}, {"name": "L_APPEND_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tentrusts_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tentrusts_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tentrusts_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tentrusts_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TENTRUSTS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TENTRUSTS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tentrusts_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTS_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_ENTRUST_SERIAL_NO
     , L_BATCH_SERIAL_NO
     , L_REPORT_SERIAL_NO
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_REPORT_CODE
     , C_MARKET_NO
     , VC_STOCKHOLDER_ID
     , VC_REPORT_SEAT
     , C_STOCK_TYPE
     , C_ENTRUST_DIRECTION
     , C_FUND_DIRECTION
     , C_STOCK_DIRECTION
     , VC_REPORT_DIRECTION
     , EN_ENTRUST_PRICE
     , L_ENTRUST_AMOUNT
     , EN_PREBUY_FROZEN_BALANCE
     , L_ENTRUST_TIME
     , L_REPORT_TIME
     , L_FIRST_BUSIN_TIME
     , L_BUSIN_AMOUNT
     , EN_BUSIN_BALANCE
     , L_CANCEL_AMOUNT
     , L_BUSIN_TIMES
     , L_OPERATOR_NO
     , VC_REVOKE_CAUSE
     , C_ENTRUST_STATUS
     , VC_INTER_CODE
     , C_ASSET_TYPE
     , C_PRICE_TYPE
     , EN_FACT_PRICE
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , C_FROZEN_TYPE
     , C_INVEST_TYPE
     , L_AUTOTRADE_NO
     , C_FAIR_FLAG
     , VC_BROKER_NO
     , VC_BROKER_ACCOUNT
     , VC_VALID_TYPE
     , VC_CONFIRM_NO
     , L_CANCEL_SERIAL_NO
     , L_VALID_DATE
     , D_DATETIME
     , L_TOTAL_DEAL_AMOUNT
     , EN_TOTAL_DEAL_BALANCE
     , L_DIRECT_DATE
     , VC_SEAT_ID
     , L_MARKET_VALID_DATE
     , VC_RIC_CODE
     , C_LAUNCH_FLAG
     , EN_BALANCE
     , EN_PRESALE_BALANCE
     , C_BUSIN_CLASS
     , C_CAN_WITHDRAW
     , L_REC_NUM
     , L_CANCEL_REC_NUM
     , L_TARGET_COMBI_ID
     , C_CANCEL_FLAG
     , EN_ALLOCATION_TAIL
     , L_ASSET_ID
     , C_DMA
     , C_EXTERNAL_DEAL_FLAG
     , VC_ALGO_ORDID
     , L_COMP_ID
     , VC_REPORT_SERIAL_NO_BRANCH
     , L_INSTANCE_ID
     , VC_RIVAL_SEAT
     , VC_ENGAGED_NO
     , C_APPLY_COMPLETE_FLAG
     , C_FIXSEND_FLAG
     , C_TARGET_INVEST_TYPE
     , L_SCHEMA_ID
     , L_PERIOD
     , VC_RIVAL_CONTRACT_NO
     , EN_SPRING_PRICE
     , VC_CONTRACT_NO
     , C_CLOSE_DIRECTION
     , VC_ORIGINALSERIAL_NO
     , VC_THIRD_REFF
     , C_ENTRUST_ORIGIN
     , VC_RIVAL_HOLDERID
     , L_INVEST_ADVISER
     , L_DETAIL_ID
     , C_SPECIAL_FLAG
     , L_TRACE_NO
     , C_UFT_FLAG
     , VC_TRAN_REFF
     , L_EXTSYSTEM_ID
     , EN_MIN_VOLUME
     , C_TRADE_OPTION
     , EN_PREBUY_DEPFRZ_BALANCE
     , VC_IP_ADDRESS
     , VC_MAC
     , VC_VOLSERIAL_NO
     , VC_ADVISER_STATION
     , VC_TERMINALINFO_EXTEND
     , L_ORG_ID
     , L_DEPT_ID
     , C_AUTODROP_FLAG
     , C_RESERVE_FLAG
     , L_RIVAL_ID
     , L_HG_DAYS
     , VC_ORIGIN_CONTRACT_NO
     , L_ORIGIN_OPEN_DATE
     , VC_ORIGIN_DEAL_NO
     , C_NICKED
     , L_ICEQTY_AMOUNT
     , VC_RIVALTRADER_ID
     , C_BULKUNDERWEIGHT_FLAG
     , VC_SUMMARY
     , C_HAND_FLAG
     , C_SUB_BUSIN_CLASS
     , L_FUNC_ID
     , VC_VOTE_SENATE_NO
     , VC_ENTRUST_FLAG
     , EN_DIF_FROZEN_BALANCE
     , L_CONFIRM_TIME
     , VC_COMPACT_ID
     , VC_RIGHT_TYPE
     , L_NATURAL_DAY
     , VC_REPORT_REFID
     , EN_AVG_DEAL_PRICE
     , L_SETTLE_SPEED
     , C_STRATEGY_PLACING
     , L_SECOND_SETTLE_DATE
     , VC_SHARES_NATURE
     , L_INSSCHEME_NO
     , L_INQUIRE_ID
     , C_CASHGROUP_PROP
     , C_TREATYHG_FLAG
     , L_HG_BATCH_NO
     , VC_RIGHT_NO
     , C_ALREADY_RELEASE_ENABLE
     , L_CASHGROUP_ID
     , L_BONDLENDING_AMOUNT
     , EN_FROZEN_FEE
     , L_RESTRICTED_NO
     , L_USE_TODAY_AMOUNT
     , C_SETTLE_TYPE
     , VC_TERMINALINFO_EXTEND_REP
     , VC_RIVAL_MARKET_REMARK
     , C_ETF_AUTO_FLAG
     , L_MODIFY_SERIAL_NO
     , C_MODIFY_FLAG
     , L_ORG_REPORT_SERIAL_NO
     , L_DIF_FROZEN_AMOUNT
     , EN_DIF_ENTRUST_BALANCE
     , C_ENTRUST_MODE
     , C_APPLY_STATUS
     , C_EXECUTE_STATUS
     , L_BID_DEAL_TYPE
     , EN_HIGH_LIMIT_PRICE
     , EN_LOW_LIMIT_PRICE
     , L_ORG_CONFIRM_NO
     , L_SETTLE_DATE
     , C_MARKETMAKE_FLAG
     , C_IS_REPLACE
     , EN_PREBUY_BALANCE_CNY
     , EN_PRESALE_BALANCE_CNY
     , L_APPEND_DAILY_INSTRUCTION_NO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TENTRUSTS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TENTRUSTS_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TENTRUSTS_PTD成功"
      exit 0
   fi
fi
