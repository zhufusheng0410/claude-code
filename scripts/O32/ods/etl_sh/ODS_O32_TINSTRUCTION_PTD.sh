#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TINSTRUCTION_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTION_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  L_INDEX_LAST_MODIFY  DECIMAL(10,0)  COMMENT  '前指令修改次序',
  L_INDEX_MODIFY_INSTRUCTION  DECIMAL(10,0)  COMMENT  '预置指令修改次序',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  C_ENTRUST_RESTRICT  STRING  COMMENT  '委托方向限制',
  C_INSTRUCTION_TYPE  STRING  COMMENT  '指令类型',
  C_TARGET_TYPE  STRING  COMMENT  '指令目标类型',
  EN_TARGET_VALUE  DECIMAL(22,6)  COMMENT  '指令目标值',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '指令起始日期',
  L_BEGIN_TIME  DECIMAL(6,0)  COMMENT  '指令起始时间',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '指令终止日期',
  L_END_TIME  DECIMAL(6,0)  COMMENT  '指令终止时间',
  C_INSTRUCTION_LEVEL  STRING  COMMENT  '指令操作级别',
  L_DIRECT_INSTEAD_OPERATOR  DECIMAL(8,0)  COMMENT  '下达代下达人',
  L_DIRECT_OPERATOR  DECIMAL(8,0)  COMMENT  '指令下达人',
  L_MODIFY_TIME  DECIMAL(6,0)  COMMENT  '指令修改时间',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '执行人',
  C_INSTRUCTION_STATUS  STRING  COMMENT  '指令状态',
  C_APPROVE_STATUS  STRING  COMMENT  '审批状态',
  C_DISPENSE_STATUS  STRING  COMMENT  '分发状态',
  VC_SUMMARY  STRING  COMMENT  '备注',
  C_STOCK_TARGET_TYPE  STRING  COMMENT  '指令证券控制类型',
  L_TRADE_RIVAL_NO  DECIMAL(10,0)  COMMENT  '交易对手',
  L_SETTLE_SPEED  DECIMAL(10,0)  COMMENT  '清算速度',
  L_HG_DAYS  DECIMAL(10,0)  COMMENT  '回购天数',
  C_FIRST_SETTLE_TYPE  STRING  COMMENT  '首次交割方式',
  C_SECOND_SETTLE_TYPE  STRING  COMMENT  '到期交割方式',
  L_FIRST_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '首次交割日',
  L_SECOND_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '到期交割日',
  L_DIRECT_DATE  DECIMAL(8,0)  COMMENT  '指令下达日期',
  L_DIRECT_TIME  DECIMAL(6,0)  COMMENT  '指令下达时间',
  L_MODIFY_OPERATOR  DECIMAL(8,0)  COMMENT  '修改人',
  VC_MODIFY_REASON  STRING  COMMENT  '修改原因',
  L_APPROVE_TIME  DECIMAL(6,0)  COMMENT  '审批时间',
  L_APPROVE_OPERATOR  DECIMAL(8,0)  COMMENT  '审批人',
  VC_APPROVE_REFUSE_REASON  STRING  COMMENT  '审批拒绝原因',
  L_DISPENSE_TIME  DECIMAL(6,0)  COMMENT  '分发时间',
  L_DISPENSE_OPERATOR  DECIMAL(8,0)  COMMENT  '分发人',
  VC_DISPENSE_REFUSE_REASON  STRING  COMMENT  '分发拒绝原因',
  L_CANCEL_TIME  DECIMAL(6,0)  COMMENT  '撤销时间',
  L_CANCEL_OPERATOR  DECIMAL(8,0)  COMMENT  '撤销人',
  VC_CANCEL_REASON  STRING  COMMENT  '撤销原因',
  C_ENTRUST_EXECUTE_STATUS  STRING  COMMENT  '委托完成状态',
  C_DEAL_EXECUTE_STATUS  STRING  COMMENT  '成交完成状态',
  C_REQUIRE_ORIGIN  STRING  COMMENT  '回购需求方',
  C_PURPOSE_TYPE  STRING  COMMENT  '回购用途类别',
  L_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '预置指令序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合序号',
  C_POWER_TYPE  STRING  COMMENT  '权重方式',
  VC_ETF_CODE  STRING  COMMENT  'etf基金代码',
  C_TRADE_REASON  STRING  COMMENT  '指令下达原因',
  D_DATETIME  STRING  COMMENT  '时间戳',
  C_BUSIN_CLASS  STRING  COMMENT  '指令业务分类',
  C_LOCK_FLAG  STRING  COMMENT  '锁定标志',
  C_FAIR_TRADE  STRING  COMMENT  '参与公平交易',
  C_OPERATOR_ASSESS  STRING  COMMENT  '参与交易员考核',
  VC_NO_ASSESS_REASON  STRING  COMMENT  '不参与考核原因',
  VC_ASSESS_RESULT  STRING  COMMENT  '交易评价',
  C_PAPERY_APPROVE  STRING  COMMENT  '纸制审批标志',
  L_BATCH_SERIAL_NO  DECIMAL(10,0)  COMMENT  '指令批号',
  L_GROUP_ID  DECIMAL(10,0)  COMMENT  '管理组序号',
  C_RISK_APPROVE_STATUS  STRING  COMMENT  '风控审批状态',
  C_FLOW_APPROVE_STATUS  STRING  COMMENT  '流程审批状态',
  VC_EXECUTE_EXPLAIN  STRING  COMMENT  '交易说明',
  C_CANCEL_DISPENSE_STATUS  STRING  COMMENT  '撤销分发状态',
  L_DISPENSE_DATE  DECIMAL(8,0)  COMMENT  '分发日期',
  L_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '修改日期',
  C_CONFIRM_STATUS  STRING  COMMENT  '交易员审核状态',
  C_OWNER_BAILTYPE  STRING  COMMENT  '本方履约保证金方式',
  C_RIVAL_BAILTYPE  STRING  COMMENT  '对方履约保证金方式',
  C_ETF_AUTO  STRING  COMMENT  'etf自动补券',
  VC_NO_FAIRTRADE_REASON  STRING  COMMENT  '不参与公平交易原因',
  VC_BROKER_NO  STRING  COMMENT  '券商编号',
  L_SETTLE_LOCK_OPERATOR  DECIMAL(8,0)  COMMENT  '交收锁定人员',
  L_LIMIT_OPERATOR  DECIMAL(8,0)  COMMENT  '指定交易员',
  L_APPROVE_DATE  DECIMAL(8,0)  COMMENT  '审批日期',
  C_PRICE_CONTROL_TYPE  STRING  COMMENT  '价格控制类型',
  C_ARBI_TYPE  STRING  COMMENT  '套利类型',
  C_EXEC_PHASE  STRING  COMMENT  '套利指令执行阶段',
  L_COMBITEMPLATE_ID  STRING  COMMENT  '交易实例编号',
  VC_SHORT_CODE  STRING  COMMENT  '空头合约代码',
  VC_LONG_CODE  STRING  COMMENT  '多头合约代码',
  L_ARBI_SETS  DECIMAL(12,0)  COMMENT  '套利份数',
  L_TOENTR_SETS  DECIMAL(12,0)  COMMENT  '套利交易的目标份数',
  EN_TARGET_BASE  DECIMAL(20,6)  COMMENT  '指令目标基数',
  C_ETF_MANUAL  STRING  COMMENT  'etf补券手工导入',
  C_BRANCH_DEAL_STATUS  STRING  COMMENT  '分仓处理状态',
  C_BRANCH_STATUS  STRING  COMMENT  '指令分仓状态',
  VC_BRANCH_FAIL_REASON  STRING  COMMENT  '分仓失败原因',
  C_CANCEL_BRANCH_STATUS  STRING  COMMENT  '撤销指令分仓状态字段',
  C_CANCEL_BRANCH_DEAL_STATUS  STRING  COMMENT  '撤销指令分仓处理状态',
  VC_TRADE_FLAG  STRING  COMMENT  '交易标识',
  L_SCHEMA_ID  DECIMAL(12,0)  COMMENT  '策略序号',
  D_HEART_BEAT  STRING  COMMENT  '心跳时间',
  C_SOURCE  STRING  COMMENT  '指令来源',
  VC_SOURCE_NO  STRING  COMMENT  '来源编号',
  C_CANCEL_APPROVE_STATUS  STRING  COMMENT  '投资建议撤销的审批状态',
  C_DIRECT_APPROVE_STATUS  STRING  COMMENT  '投资建议下达的审批状态',
  L_INVEST_ADVISER  DECIMAL(8,0)  COMMENT  '投资顾问',
  C_QUOTE_SIDE  STRING  COMMENT  '引用语',
  C_SPECIAL_FLAG  STRING  COMMENT  '特殊业务标识',
  C_TARGET_BASE  STRING  COMMENT  '指令目标基准',
  L_INSIDER_TRADING_NO  DECIMAL(10,0)  COMMENT  '内部交易号',
  C_CANCEL_STATUS  STRING  COMMENT  '撤销审批状态',
  C_DEAL_EXECUTE_FLAG  STRING  COMMENT  '成交回填标志',
  L_BUSIN_END_DATE  DECIMAL(8,0)  COMMENT  '业务结束日期',
  L_BUSIN_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '业务开始日期',
  C_PAYSTOCK_MODE  STRING  COMMENT  '还券模式',
  VC_ADVISER_STATION  STRING  COMMENT  '投顾站点',
  VC_IP_ADDRESS  STRING  COMMENT  '网卡地址',
  VC_MAC  STRING  COMMENT  'mac地址',
  VC_VOLSERIAL_NO  STRING  COMMENT  '磁盘序列号',
  L_INVEST_DATE  DECIMAL(8,0)  COMMENT  '投资建议下达日期',
  L_INVEST_TIME  DECIMAL(6,0)  COMMENT  '投资建议下达时间',
  C_SEARCH_SOURCE  STRING  COMMENT  '筛选来源',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司号',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '部门号',
  C_ADVISE_TYPE  STRING  COMMENT  '投资建议类型',
  C_OPER_FLAG  STRING  COMMENT  '操作标记',
  VC_BASKET_NO  STRING  COMMENT  '组别号',
  C_TRADE_AGENT_FLAG  STRING  COMMENT  '交易代理标志',
  L_APPROVE_BUSIN_DATE  DECIMAL(8,0)  COMMENT  '审批业务日期',
  L_DEFAULT_OPERATOR  DECIMAL(8,0)  COMMENT  '默认操作员',
  VC_UNIQUE_INSTRUCTION_NO  STRING  COMMENT  '唯一交易编号',
  L_ADVISE_ID  STRING  COMMENT  '推荐编号',
  C_TREATYHG_FLAG  STRING  COMMENT  '处理标签',
  L_HG_BATCH_NO  DECIMAL(10,0)  COMMENT  '协议回购批号',
  L_APPLY_NO  STRING  COMMENT  '申请编号',
  VC_INTERBANK_QUOTE_ID  STRING  COMMENT  '银行间报价编号',
  C_EFT_STATUS  STRING  COMMENT  '退出状态',
  C_DEAL_SOURCE  STRING  COMMENT  '处理源',
  VC_SUMMARY2  STRING  COMMENT  '摘要2',
  C_QUOTE_TYPE  STRING  COMMENT  '报价类型',
  L_CRMW_BATCH_SERIAL_NO  DECIMAL(10,0)  COMMENT  '批次序列号',
  L_CANCEL_DATE  DECIMAL(8,0)  COMMENT  '撤销日期',
  VC_TRADE_FEEDBACK  DECIMAL(8,0)  COMMENT  '交易反馈',
  L_FEEDBACK_DATE  DECIMAL(8,0)  COMMENT  '反馈日期',
  L_FEEDBACK_TIME  DECIMAL(8,0)  COMMENT  '反馈时间',
  C_DISPUTE_RESOLUTIO  STRING  COMMENT  '争议解决方案',
  C_PLEDGED_REPLACE_TYPE  STRING  COMMENT  '可替换类型',
  L_BANK_SERIAL_NO  DECIMAL(10,0)  COMMENT  '银行序列号',
  C_TRADE_TYPE  STRING  COMMENT  '交易类型',
  C_EXPORT_STATUS  STRING  COMMENT  '导出状态',
  L_VOUCHPLAN_SERIAL_NO  DECIMAL(10,0)  COMMENT  '凭证计划序列号',
  VC_INDEX  STRING  COMMENT  '索引',
  L_REAL_TRADE_RIVAL_NO  STRING  COMMENT  '真实交易对手编号',
  L_FEEDBACK_STATUS  STRING  COMMENT  '反馈状态',
  C_MULTIDAY_CONTROL_TYPE  STRING  COMMENT  '控件类型',
  C_BANKENTR_AUTO  STRING  COMMENT  '银行自动化',
  VC_TRADE_RIVAL_NAME  STRING  COMMENT  '交易对手名字',
  VC_MENU_NO  STRING  COMMENT  '菜单编号',
  C_RIGHTS_ID  STRING  COMMENT  '菜单附加权限',
  VC_SMARTINS_MSG  STRING  COMMENT  ''
)
COMMENT '指令表'
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
                                   , L_INDEX_LAST_MODIFY
                                   , L_INDEX_MODIFY_INSTRUCTION
                                   , L_FUND_ID
                                   , C_ENTRUST_RESTRICT
                                   , C_INSTRUCTION_TYPE
                                   , C_TARGET_TYPE
                                   , EN_TARGET_VALUE
                                   , L_BEGIN_DATE
                                   , L_BEGIN_TIME
                                   , L_END_DATE
                                   , L_END_TIME
                                   , C_INSTRUCTION_LEVEL
                                   , L_DIRECT_INSTEAD_OPERATOR
                                   , L_DIRECT_OPERATOR
                                   , L_MODIFY_TIME
                                   , L_OPERATOR_NO
                                   , C_INSTRUCTION_STATUS
                                   , C_APPROVE_STATUS
                                   , C_DISPENSE_STATUS
                                   , VC_SUMMARY
                                   , C_STOCK_TARGET_TYPE
                                   , L_TRADE_RIVAL_NO
                                   , L_SETTLE_SPEED
                                   , L_HG_DAYS
                                   , C_FIRST_SETTLE_TYPE
                                   , C_SECOND_SETTLE_TYPE
                                   , L_FIRST_SETTLE_DATE
                                   , L_SECOND_SETTLE_DATE
                                   , L_DIRECT_DATE
                                   , L_DIRECT_TIME
                                   , L_MODIFY_OPERATOR
                                   , VC_MODIFY_REASON
                                   , L_APPROVE_TIME
                                   , L_APPROVE_OPERATOR
                                   , VC_APPROVE_REFUSE_REASON
                                   , L_DISPENSE_TIME
                                   , L_DISPENSE_OPERATOR
                                   , VC_DISPENSE_REFUSE_REASON
                                   , L_CANCEL_TIME
                                   , L_CANCEL_OPERATOR
                                   , VC_CANCEL_REASON
                                   , C_ENTRUST_EXECUTE_STATUS
                                   , C_DEAL_EXECUTE_STATUS
                                   , C_REQUIRE_ORIGIN
                                   , C_PURPOSE_TYPE
                                   , L_INSTRUCTION_NO
                                   , L_BASECOMBI_ID
                                   , C_POWER_TYPE
                                   , VC_ETF_CODE
                                   , C_TRADE_REASON
                                   , D_DATETIME
                                   , C_BUSIN_CLASS
                                   , C_LOCK_FLAG
                                   , C_FAIR_TRADE
                                   , C_OPERATOR_ASSESS
                                   , VC_NO_ASSESS_REASON
                                   , VC_ASSESS_RESULT
                                   , C_PAPERY_APPROVE
                                   , L_BATCH_SERIAL_NO
                                   , L_GROUP_ID
                                   , C_RISK_APPROVE_STATUS
                                   , C_FLOW_APPROVE_STATUS
                                   , VC_EXECUTE_EXPLAIN
                                   , C_CANCEL_DISPENSE_STATUS
                                   , L_DISPENSE_DATE
                                   , L_MODIFY_DATE
                                   , C_CONFIRM_STATUS
                                   , C_OWNER_BAILTYPE
                                   , C_RIVAL_BAILTYPE
                                   , C_ETF_AUTO
                                   , VC_NO_FAIRTRADE_REASON
                                   , VC_BROKER_NO
                                   , L_SETTLE_LOCK_OPERATOR
                                   , L_LIMIT_OPERATOR
                                   , L_APPROVE_DATE
                                   , C_PRICE_CONTROL_TYPE
                                   , C_ARBI_TYPE
                                   , C_EXEC_PHASE
                                   , L_COMBITEMPLATE_ID
                                   , VC_SHORT_CODE
                                   , VC_LONG_CODE
                                   , L_ARBI_SETS
                                   , L_TOENTR_SETS
                                   , EN_TARGET_BASE
                                   , C_ETF_MANUAL
                                   , C_BRANCH_DEAL_STATUS
                                   , C_BRANCH_STATUS
                                   , VC_BRANCH_FAIL_REASON
                                   , C_CANCEL_BRANCH_STATUS
                                   , C_CANCEL_BRANCH_DEAL_STATUS
                                   , VC_TRADE_FLAG
                                   , L_SCHEMA_ID
                                   , D_HEART_BEAT
                                   , C_SOURCE
                                   , VC_SOURCE_NO
                                   , C_CANCEL_APPROVE_STATUS
                                   , C_DIRECT_APPROVE_STATUS
                                   , L_INVEST_ADVISER
                                   , C_QUOTE_SIDE
                                   , C_SPECIAL_FLAG
                                   , C_TARGET_BASE
                                   , L_INSIDER_TRADING_NO
                                   , C_CANCEL_STATUS
                                   , C_DEAL_EXECUTE_FLAG
                                   , L_BUSIN_END_DATE
                                   , L_BUSIN_BEGIN_DATE
                                   , C_PAYSTOCK_MODE
                                   , VC_ADVISER_STATION
                                   , VC_IP_ADDRESS
                                   , VC_MAC
                                   , VC_VOLSERIAL_NO
                                   , L_INVEST_DATE
                                   , L_INVEST_TIME
                                   , C_SEARCH_SOURCE
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , C_ADVISE_TYPE
                                   , C_OPER_FLAG
                                   , VC_BASKET_NO
                                   , C_TRADE_AGENT_FLAG
                                   , L_APPROVE_BUSIN_DATE
                                   , L_DEFAULT_OPERATOR
                                   , VC_UNIQUE_INSTRUCTION_NO
                                   , L_ADVISE_ID
                                   , C_TREATYHG_FLAG
                                   , L_HG_BATCH_NO
                                   , L_APPLY_NO
                                   , VC_INTERBANK_QUOTE_ID
                                   , C_EFT_STATUS
                                   , C_DEAL_SOURCE
                                   , VC_SUMMARY2
                                   , C_QUOTE_TYPE
                                   , L_CRMW_BATCH_SERIAL_NO
                                   , L_CANCEL_DATE
                                   , VC_TRADE_FEEDBACK
                                   , L_FEEDBACK_DATE
                                   , L_FEEDBACK_TIME
                                   , C_DISPUTE_RESOLUTIO
                                   , C_PLEDGED_REPLACE_TYPE
                                   , L_BANK_SERIAL_NO
                                   , C_TRADE_TYPE
                                   , C_EXPORT_STATUS
                                   , L_VOUCHPLAN_SERIAL_NO
                                   , VC_INDEX
                                   , L_REAL_TRADE_RIVAL_NO
                                   , L_FEEDBACK_STATUS
                                   , C_MULTIDAY_CONTROL_TYPE
                                   , C_BANKENTR_AUTO
                                   , VC_TRADE_RIVAL_NAME
                                   , VC_MENU_NO
                                   , C_RIGHTS_ID
                                   , VC_SMARTINS_MSG
                                FROM ${o32_src_schema}.THISINSTRUCTION
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_INDEX_LAST_MODIFY", "type": "DOUBLE"}, {"name": "L_INDEX_MODIFY_INSTRUCTION", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "C_ENTRUST_RESTRICT", "type": "STRING"}, {"name": "C_INSTRUCTION_TYPE", "type": "STRING"}, {"name": "C_TARGET_TYPE", "type": "STRING"}, {"name": "EN_TARGET_VALUE", "type": "DOUBLE"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_BEGIN_TIME", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_END_TIME", "type": "DOUBLE"}, {"name": "C_INSTRUCTION_LEVEL", "type": "STRING"}, {"name": "L_DIRECT_INSTEAD_OPERATOR", "type": "DOUBLE"}, {"name": "L_DIRECT_OPERATOR", "type": "DOUBLE"}, {"name": "L_MODIFY_TIME", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "C_INSTRUCTION_STATUS", "type": "STRING"}, {"name": "C_APPROVE_STATUS", "type": "STRING"}, {"name": "C_DISPENSE_STATUS", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "C_STOCK_TARGET_TYPE", "type": "STRING"}, {"name": "L_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "L_HG_DAYS", "type": "DOUBLE"}, {"name": "C_FIRST_SETTLE_TYPE", "type": "STRING"}, {"name": "C_SECOND_SETTLE_TYPE", "type": "STRING"}, {"name": "L_FIRST_SETTLE_DATE", "type": "DOUBLE"}, {"name": "L_SECOND_SETTLE_DATE", "type": "DOUBLE"}, {"name": "L_DIRECT_DATE", "type": "DOUBLE"}, {"name": "L_DIRECT_TIME", "type": "DOUBLE"}, {"name": "L_MODIFY_OPERATOR", "type": "DOUBLE"}, {"name": "VC_MODIFY_REASON", "type": "STRING"}, {"name": "L_APPROVE_TIME", "type": "DOUBLE"}, {"name": "L_APPROVE_OPERATOR", "type": "DOUBLE"}, {"name": "VC_APPROVE_REFUSE_REASON", "type": "STRING"}, {"name": "L_DISPENSE_TIME", "type": "DOUBLE"}, {"name": "L_DISPENSE_OPERATOR", "type": "DOUBLE"}, {"name": "VC_DISPENSE_REFUSE_REASON", "type": "STRING"}, {"name": "L_CANCEL_TIME", "type": "DOUBLE"}, {"name": "L_CANCEL_OPERATOR", "type": "DOUBLE"}, {"name": "VC_CANCEL_REASON", "type": "STRING"}, {"name": "C_ENTRUST_EXECUTE_STATUS", "type": "STRING"}, {"name": "C_DEAL_EXECUTE_STATUS", "type": "STRING"}, {"name": "C_REQUIRE_ORIGIN", "type": "STRING"}, {"name": "C_PURPOSE_TYPE", "type": "STRING"}, {"name": "L_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_POWER_TYPE", "type": "STRING"}, {"name": "VC_ETF_CODE", "type": "STRING"}, {"name": "C_TRADE_REASON", "type": "STRING"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "C_LOCK_FLAG", "type": "STRING"}, {"name": "C_FAIR_TRADE", "type": "STRING"}, {"name": "C_OPERATOR_ASSESS", "type": "STRING"}, {"name": "VC_NO_ASSESS_REASON", "type": "STRING"}, {"name": "VC_ASSESS_RESULT", "type": "STRING"}, {"name": "C_PAPERY_APPROVE", "type": "STRING"}, {"name": "L_BATCH_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_GROUP_ID", "type": "DOUBLE"}, {"name": "C_RISK_APPROVE_STATUS", "type": "STRING"}, {"name": "C_FLOW_APPROVE_STATUS", "type": "STRING"}, {"name": "VC_EXECUTE_EXPLAIN", "type": "STRING"}, {"name": "C_CANCEL_DISPENSE_STATUS", "type": "STRING"}, {"name": "L_DISPENSE_DATE", "type": "DOUBLE"}, {"name": "L_MODIFY_DATE", "type": "DOUBLE"}, {"name": "C_CONFIRM_STATUS", "type": "STRING"}, {"name": "C_OWNER_BAILTYPE", "type": "STRING"}, {"name": "C_RIVAL_BAILTYPE", "type": "STRING"}, {"name": "C_ETF_AUTO", "type": "STRING"}, {"name": "VC_NO_FAIRTRADE_REASON", "type": "STRING"}, {"name": "VC_BROKER_NO", "type": "STRING"}, {"name": "L_SETTLE_LOCK_OPERATOR", "type": "DOUBLE"}, {"name": "L_LIMIT_OPERATOR", "type": "DOUBLE"}, {"name": "L_APPROVE_DATE", "type": "DOUBLE"}, {"name": "C_PRICE_CONTROL_TYPE", "type": "STRING"}, {"name": "C_ARBI_TYPE", "type": "STRING"}, {"name": "C_EXEC_PHASE", "type": "STRING"}, {"name": "L_COMBITEMPLATE_ID", "type": "DOUBLE"}, {"name": "VC_SHORT_CODE", "type": "STRING"}, {"name": "VC_LONG_CODE", "type": "STRING"}, {"name": "L_ARBI_SETS", "type": "DOUBLE"}, {"name": "L_TOENTR_SETS", "type": "DOUBLE"}, {"name": "EN_TARGET_BASE", "type": "DOUBLE"}, {"name": "C_ETF_MANUAL", "type": "STRING"}, {"name": "C_BRANCH_DEAL_STATUS", "type": "STRING"}, {"name": "C_BRANCH_STATUS", "type": "STRING"}, {"name": "VC_BRANCH_FAIL_REASON", "type": "STRING"}, {"name": "C_CANCEL_BRANCH_STATUS", "type": "STRING"}, {"name": "C_CANCEL_BRANCH_DEAL_STATUS", "type": "STRING"}, {"name": "VC_TRADE_FLAG", "type": "STRING"}, {"name": "L_SCHEMA_ID", "type": "DOUBLE"}, {"name": "D_HEART_BEAT", "type": "STRING"}, {"name": "C_SOURCE", "type": "STRING"}, {"name": "VC_SOURCE_NO", "type": "STRING"}, {"name": "C_CANCEL_APPROVE_STATUS", "type": "STRING"}, {"name": "C_DIRECT_APPROVE_STATUS", "type": "STRING"}, {"name": "L_INVEST_ADVISER", "type": "DOUBLE"}, {"name": "C_QUOTE_SIDE", "type": "STRING"}, {"name": "C_SPECIAL_FLAG", "type": "STRING"}, {"name": "C_TARGET_BASE", "type": "STRING"}, {"name": "L_INSIDER_TRADING_NO", "type": "DOUBLE"}, {"name": "C_CANCEL_STATUS", "type": "STRING"}, {"name": "C_DEAL_EXECUTE_FLAG", "type": "STRING"}, {"name": "L_BUSIN_END_DATE", "type": "DOUBLE"}, {"name": "L_BUSIN_BEGIN_DATE", "type": "DOUBLE"}, {"name": "C_PAYSTOCK_MODE", "type": "STRING"}, {"name": "VC_ADVISER_STATION", "type": "STRING"}, {"name": "VC_IP_ADDRESS", "type": "STRING"}, {"name": "VC_MAC", "type": "STRING"}, {"name": "VC_VOLSERIAL_NO", "type": "STRING"}, {"name": "L_INVEST_DATE", "type": "DOUBLE"}, {"name": "L_INVEST_TIME", "type": "DOUBLE"}, {"name": "C_SEARCH_SOURCE", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "C_ADVISE_TYPE", "type": "STRING"}, {"name": "C_OPER_FLAG", "type": "STRING"}, {"name": "VC_BASKET_NO", "type": "STRING"}, {"name": "C_TRADE_AGENT_FLAG", "type": "STRING"}, {"name": "L_APPROVE_BUSIN_DATE", "type": "DOUBLE"}, {"name": "L_DEFAULT_OPERATOR", "type": "DOUBLE"}, {"name": "VC_UNIQUE_INSTRUCTION_NO", "type": "STRING"}, {"name": "L_ADVISE_ID", "type": "DOUBLE"}, {"name": "C_TREATYHG_FLAG", "type": "STRING"}, {"name": "L_HG_BATCH_NO", "type": "DOUBLE"}, {"name": "L_APPLY_NO", "type": "DOUBLE"}, {"name": "VC_INTERBANK_QUOTE_ID", "type": "STRING"}, {"name": "C_EFT_STATUS", "type": "STRING"}, {"name": "C_DEAL_SOURCE", "type": "STRING"}, {"name": "VC_SUMMARY2", "type": "STRING"}, {"name": "C_QUOTE_TYPE", "type": "STRING"}, {"name": "L_CRMW_BATCH_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_CANCEL_DATE", "type": "DOUBLE"}, {"name": "VC_TRADE_FEEDBACK", "type": "DOUBLE"}, {"name": "L_FEEDBACK_DATE", "type": "DOUBLE"}, {"name": "L_FEEDBACK_TIME", "type": "DOUBLE"}, {"name": "C_DISPUTE_RESOLUTIO", "type": "STRING"}, {"name": "C_PLEDGED_REPLACE_TYPE", "type": "STRING"}, {"name": "L_BANK_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_TRADE_TYPE", "type": "STRING"}, {"name": "C_EXPORT_STATUS", "type": "STRING"}, {"name": "L_VOUCHPLAN_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_INDEX", "type": "STRING"}, {"name": "L_REAL_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "L_FEEDBACK_STATUS", "type": "STRING"}, {"name": "C_MULTIDAY_CONTROL_TYPE", "type": "STRING"}, {"name": "C_BANKENTR_AUTO", "type": "STRING"}, {"name": "VC_TRADE_RIVAL_NAME", "type": "STRING"}, {"name": "VC_MENU_NO", "type": "STRING"}, {"name": "C_RIGHTS_ID", "type": "STRING"}, {"name": "VC_SMARTINS_MSG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tinstruction_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tinstruction_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tinstruction_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tinstruction_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TINSTRUCTION_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TINSTRUCTION_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tinstruction_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTION_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , L_INDEX_LAST_MODIFY
     , L_INDEX_MODIFY_INSTRUCTION
     , L_FUND_ID
     , C_ENTRUST_RESTRICT
     , C_INSTRUCTION_TYPE
     , C_TARGET_TYPE
     , EN_TARGET_VALUE
     , L_BEGIN_DATE
     , L_BEGIN_TIME
     , L_END_DATE
     , L_END_TIME
     , C_INSTRUCTION_LEVEL
     , L_DIRECT_INSTEAD_OPERATOR
     , L_DIRECT_OPERATOR
     , L_MODIFY_TIME
     , L_OPERATOR_NO
     , C_INSTRUCTION_STATUS
     , C_APPROVE_STATUS
     , C_DISPENSE_STATUS
     , VC_SUMMARY
     , C_STOCK_TARGET_TYPE
     , L_TRADE_RIVAL_NO
     , L_SETTLE_SPEED
     , L_HG_DAYS
     , C_FIRST_SETTLE_TYPE
     , C_SECOND_SETTLE_TYPE
     , L_FIRST_SETTLE_DATE
     , L_SECOND_SETTLE_DATE
     , L_DIRECT_DATE
     , L_DIRECT_TIME
     , L_MODIFY_OPERATOR
     , VC_MODIFY_REASON
     , L_APPROVE_TIME
     , L_APPROVE_OPERATOR
     , VC_APPROVE_REFUSE_REASON
     , L_DISPENSE_TIME
     , L_DISPENSE_OPERATOR
     , VC_DISPENSE_REFUSE_REASON
     , L_CANCEL_TIME
     , L_CANCEL_OPERATOR
     , VC_CANCEL_REASON
     , C_ENTRUST_EXECUTE_STATUS
     , C_DEAL_EXECUTE_STATUS
     , C_REQUIRE_ORIGIN
     , C_PURPOSE_TYPE
     , L_INSTRUCTION_NO
     , L_BASECOMBI_ID
     , C_POWER_TYPE
     , VC_ETF_CODE
     , C_TRADE_REASON
     , D_DATETIME
     , C_BUSIN_CLASS
     , C_LOCK_FLAG
     , C_FAIR_TRADE
     , C_OPERATOR_ASSESS
     , VC_NO_ASSESS_REASON
     , VC_ASSESS_RESULT
     , C_PAPERY_APPROVE
     , L_BATCH_SERIAL_NO
     , L_GROUP_ID
     , C_RISK_APPROVE_STATUS
     , C_FLOW_APPROVE_STATUS
     , VC_EXECUTE_EXPLAIN
     , C_CANCEL_DISPENSE_STATUS
     , L_DISPENSE_DATE
     , L_MODIFY_DATE
     , C_CONFIRM_STATUS
     , C_OWNER_BAILTYPE
     , C_RIVAL_BAILTYPE
     , C_ETF_AUTO
     , VC_NO_FAIRTRADE_REASON
     , VC_BROKER_NO
     , L_SETTLE_LOCK_OPERATOR
     , L_LIMIT_OPERATOR
     , L_APPROVE_DATE
     , C_PRICE_CONTROL_TYPE
     , C_ARBI_TYPE
     , C_EXEC_PHASE
     , L_COMBITEMPLATE_ID
     , VC_SHORT_CODE
     , VC_LONG_CODE
     , L_ARBI_SETS
     , L_TOENTR_SETS
     , EN_TARGET_BASE
     , C_ETF_MANUAL
     , C_BRANCH_DEAL_STATUS
     , C_BRANCH_STATUS
     , VC_BRANCH_FAIL_REASON
     , C_CANCEL_BRANCH_STATUS
     , C_CANCEL_BRANCH_DEAL_STATUS
     , VC_TRADE_FLAG
     , L_SCHEMA_ID
     , D_HEART_BEAT
     , C_SOURCE
     , VC_SOURCE_NO
     , C_CANCEL_APPROVE_STATUS
     , C_DIRECT_APPROVE_STATUS
     , L_INVEST_ADVISER
     , C_QUOTE_SIDE
     , C_SPECIAL_FLAG
     , C_TARGET_BASE
     , L_INSIDER_TRADING_NO
     , C_CANCEL_STATUS
     , C_DEAL_EXECUTE_FLAG
     , L_BUSIN_END_DATE
     , L_BUSIN_BEGIN_DATE
     , C_PAYSTOCK_MODE
     , VC_ADVISER_STATION
     , VC_IP_ADDRESS
     , VC_MAC
     , VC_VOLSERIAL_NO
     , L_INVEST_DATE
     , L_INVEST_TIME
     , C_SEARCH_SOURCE
     , L_ORG_ID
     , L_DEPT_ID
     , C_ADVISE_TYPE
     , C_OPER_FLAG
     , VC_BASKET_NO
     , C_TRADE_AGENT_FLAG
     , L_APPROVE_BUSIN_DATE
     , L_DEFAULT_OPERATOR
     , VC_UNIQUE_INSTRUCTION_NO
     , L_ADVISE_ID
     , C_TREATYHG_FLAG
     , L_HG_BATCH_NO
     , L_APPLY_NO
     , VC_INTERBANK_QUOTE_ID
     , C_EFT_STATUS
     , C_DEAL_SOURCE
     , VC_SUMMARY2
     , C_QUOTE_TYPE
     , L_CRMW_BATCH_SERIAL_NO
     , L_CANCEL_DATE
     , VC_TRADE_FEEDBACK
     , L_FEEDBACK_DATE
     , L_FEEDBACK_TIME
     , C_DISPUTE_RESOLUTIO
     , C_PLEDGED_REPLACE_TYPE
     , L_BANK_SERIAL_NO
     , C_TRADE_TYPE
     , C_EXPORT_STATUS
     , L_VOUCHPLAN_SERIAL_NO
     , VC_INDEX
     , L_REAL_TRADE_RIVAL_NO
     , L_FEEDBACK_STATUS
     , C_MULTIDAY_CONTROL_TYPE
     , C_BANKENTR_AUTO
     , VC_TRADE_RIVAL_NAME
     , VC_MENU_NO
     , C_RIGHTS_ID
     , VC_SMARTINS_MSG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTION_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTION_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TINSTRUCTION_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TINSTRUCTION_PTD成功"
      exit 0
   fi
fi
