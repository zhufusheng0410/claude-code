#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD_TMP(
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  VC_FUND_CODE  STRING  COMMENT  '基金代码',
  VC_FUND_NAME  STRING  COMMENT  '基金简称',
  VC_FUND_CAPTION  STRING  COMMENT  '基金全称',
  L_DEFAULT_ASSET  DECIMAL(8,0)  COMMENT  '缺省资产单元',
  L_DEFAULT_COMBI  DECIMAL(12,0)  COMMENT  '缺省组合单元',
  L_OPEN_DATE  DECIMAL(8,0)  COMMENT  '成立日期',
  C_INTEREST_CLASS  STRING  COMMENT  '计息类型',
  C_VALUE_CLASS  STRING  COMMENT  '市值计算类型',
  C_FUND_TYPE  STRING  COMMENT  '基金类型',
  C_FUND_STATUS  STRING  COMMENT  '基金状态',
  C_CHECK_TYPE  STRING  COMMENT  '科目调整方式',
  C_OUT_BOND_TYPE  STRING  COMMENT  '银行间债券估值类型',
  VC_REMARKS  STRING  COMMENT  '备注',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '结束日期',
  C_ACCOUNTANT_TYPE  STRING  COMMENT  '会计类型',
  C_FALOAD_STATE  STRING  COMMENT  '财务导入状态',
  VC_SEQUARE_CODE  STRING  COMMENT  '结算参与人编号',
  VC_TA_CODE  STRING  COMMENT  'ta编号',
  L_BANK_ID  DECIMAL(10,0)  COMMENT  '银行间id',
  EN_FUND_SHARE  DECIMAL(16,2)  COMMENT  '基金总份额',
  C_NEED_FA  STRING  COMMENT  '每天是否需要财务对账',
  C_FADEAL_STATE  STRING  COMMENT  '财务处理状态',
  VC_CURRENCY_NO  STRING  COMMENT  '本币币种',
  L_LOCAL_CUSTODIAN  DECIMAL(10,0)  COMMENT  '境内托管行',
  L_FOREIGN_CUSTODIAN  DECIMAL(10,0)  COMMENT  '境外托管行',
  VC_PERMIT_MARKET  STRING  COMMENT  '允许投资的市场',
  C_CHANGE_METHOD  STRING  COMMENT  '财务代码转换方法',
  C_MULTI_CURRENCY  STRING  COMMENT  '多币种标志',
  VC_COLLECT_CURRENCY_NO  STRING  COMMENT  '募集币种',
  C_CASH_ADDUP  STRING  COMMENT  '资金合用标志',
  C_LIQUIDATE_ALONE  STRING  COMMENT  '清算模式',
  C_TN_LIQUIDATE  STRING  COMMENT  't+n清算',
  L_LIQUIDATE_TIME  DECIMAL(6,0)  COMMENT  '清算时点',
  L_BUSINESS_DATE  DECIMAL(8,0)  COMMENT  '业务日期',
  L_LIQUIDATE_DATE  DECIMAL(8,0)  COMMENT  '清算日期',
  C_SYNONYM_FLAG  STRING  COMMENT  '同步标志',
  VC_BANK_ACCOUNT  STRING  COMMENT  '中债登托管账号',
  C_CALCULATE_TYPE  STRING  COMMENT  '中债登托管账号名称',
  VC_CASH_CONTROL_POINT  STRING  COMMENT  '头寸控制点',
  VC_STOCK_CONTROL_POINT  STRING  COMMENT  '证券控制点',
  L_BRANCH_DATE  DECIMAL(8,0)  COMMENT  '分仓清算日期',
  C_ACCOUNT_TYPE  STRING  COMMENT  '账套类型',
  C_TAX_FLAG  STRING  COMMENT  '红利交税标志',
  C_LONG_STOP_TYPE  STRING  COMMENT  '长期停牌证券的估值类型',
  L_PAPER_NO  STRING  COMMENT  '划款指令单编号',
  L_NET_PRICE_DIGITS  DECIMAL(1,0)  COMMENT  '单位净值小数位数',
  L_BEENTRUST_NO  DECIMAL(10,0)  COMMENT  '受托人',
  VC_BANK_NAME  STRING  COMMENT  '托管银行名称',
  VC_TRUST_ACCOUNT  STRING  COMMENT  '托管账户',
  VC_ACCOUNT_NAME  STRING  COMMENT  '托管账户名',
  L_PATTERN_ID  DECIMAL(4,0)  COMMENT  '业绩计提模式',
  C_FROZEN_DAY_TYPE  STRING  COMMENT  '冻结备付金方式',
  L_FROZEN_DAYS  DECIMAL(10,0)  COMMENT  '备付金冻结天数',
  VC_OBJECT_CODE  STRING  COMMENT  '配售对象编码',
  C_BOND_RISK_VALUE  STRING  COMMENT  '债券风控市值计算模式',
  C_GROUPFA  STRING  COMMENT  '是否分组估值',
  C_TASETTLE_TYPE  STRING  COMMENT  'ta申购赎回款交收金额类型',
  VC_SUBCONTRACT_NO  STRING  COMMENT  '子合同编号',
  VC_INTRABANK_NO  STRING  COMMENT  '联行号',
  VC_PAY_NO  STRING  COMMENT  '支付系统号',
  C_BOND_RISK_COST  STRING  COMMENT  '债券风控成本计算方式',
  EN_FOREIGH_QUOTA  DECIMAL(16,2)  COMMENT  '外汇额度',
  L_APPLY_EXCHANGE_DAYS  DECIMAL(4,0)  COMMENT  '申购换入天数',
  L_REDEMPTION_EXCHANGE_DAYS  DECIMAL(4,0)  COMMENT  '赎回换出天数',
  VC_FOREIGN_TRUST_ACCOUNT  STRING  COMMENT  '境外托管账号',
  C_INVEST_DIRECTION  STRING  COMMENT  '投资方向',
  C_MARKET_TYPE  STRING  COMMENT  '投资市场',
  VC_PERMIT_ETFS  STRING  COMMENT  '允许投资的etf',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_USE_LOOSE_BALANCE  STRING  COMMENT  '使用松头寸',
  C_ETF_VALUE_TYPE  STRING  COMMENT  '所投资的etf基金的估值方式',
  C_FUTURE_LIQUIDATE_ALONE  STRING  COMMENT  '股指期货清算模式',
  C_FUTURES_INVEST_TYPE  STRING  COMMENT  '股指期货投资类型',
  C_BONDACCOUNT_TYPE  STRING  COMMENT  '债券账户类型',
  VC_BANK_LINKMAN  STRING  COMMENT  '银行联系人',
  VC_BANK_PHONE  STRING  COMMENT  '银行联系电话',
  VC_BANK_FAX  STRING  COMMENT  '银行传真',
  VC_PROVINCECODE  STRING  COMMENT  '托管账户省份',
  VC_CITY  STRING  COMMENT  '托管账户城市',
  L_SET_NO  DECIMAL(10,0)  COMMENT  '汇率套号',
  C_BOND_STOP_TYPE  STRING  COMMENT  '停牌债券股指方式',
  C_GX_CASH_LINKED  STRING  COMMENT  '资金联动',
  L_TADEAL_SERIALNO  DECIMAL(4,0)  COMMENT  'ta数据处理模式',
  L_FUTURE_BRANCH_DATE  DECIMAL(8,0)  COMMENT  '期货清算日期字段',
  VC_SHCLEARING_ACCOUNT  STRING  COMMENT  '上海清算所托管账号字段',
  C_RZ_TYPE  STRING  COMMENT  '融资限额类型',
  EN_RZ_LIMIT  DECIMAL(18,4)  COMMENT  '可融资项',
  VC_RZ_ITEMS  STRING  COMMENT  '融资限额',
  EN_FUTURE_STOPLOSS_RATIO  DECIMAL(9,8)  COMMENT  '股指期货止损比例',
  C_TAX_TYPE  STRING  COMMENT  '税率类型',
  C_FROZEN_BYASSET  STRING  COMMENT  '分资产单元冻结备付金:',
  VC_FAIMP_SOURCE  STRING  COMMENT  '估值导入同义词',
  L_FROZEN_START_DAYS  DECIMAL(4,0)  COMMENT  '备付金冻结起始日',
  VC_FA_NET_NAME  STRING  COMMENT  '净值科目名称',
  C_TRADE_TYPE  STRING  COMMENT  '交易类别',
  EN_NAVTOSUB_RATIO  DECIMAL(7,6)  COMMENT  '日初净值转应收比例',
  C_CLASS_BOND_TYPE  STRING  COMMENT  '固收大宗债券估值类型',
  C_EXCHANGE_ABS_TYPE  STRING  COMMENT  '交易所资产支持证券估值类型',
  C_BANK_ABS_TYPE  STRING  COMMENT  '银行间资产支持证券估值类型',
  L_YYSH_CASH_FROZEN  DECIMAL(4,0)  COMMENT  '预约赎回资金提前冻结天数',
  L_YYSH_STOCK_FROZEN  DECIMAL(4,0)  COMMENT  '预约赎回证券提前冻结天数',
  VC_BANK_ACCOUNT_NAME  STRING  COMMENT  '中债登托管账号名称',
  VC_SHCLEARING_ACCOUNT_NAME  STRING  COMMENT  '上清所托管账号名称',
  L_ASSET_REF_TIME  DECIMAL(4,0)  COMMENT  '净值刷新时间',
  L_APPROVAL_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '强平审批人',
  C_ZZD_TYPE  STRING  COMMENT  '中债登托管模式',
  C_EXCHANGE_NET_TYPE  STRING  COMMENT  '交易所净价交易债券估值类型',
  C_INITIALIZTION_FLAG  STRING  COMMENT  '初始化标志',
  C_INACTIVE_TYPE  STRING  COMMENT  '交易不活跃证券估值类型',
  EN_FUND_FACEVALUE  DECIMAL(16,8)  COMMENT  '基金面额',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '所属公司',
  EN_FACT_COLLECT  DECIMAL(16,2)  COMMENT  '事实收集',
  EN_FACT_COLLECT_SHARES  DECIMAL(16,2)  COMMENT  '事实收集共享',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '所属部门',
  C_ZQ_GZMS  STRING  COMMENT  '债券估值模式',
  C_YHJZQ_PRICE_SOURCE  STRING  COMMENT  '银行间债券公允价来源',
  C_JYSZQ_PRICE_SOURCE  STRING  COMMENT  '交易所债券估值净价来源',
  C_FA_PRECISION_MODE  STRING  COMMENT  '单位净值校验精度处理方式',
  C_COMMISION_MODE  STRING  COMMENT  '佣金模式',
  VC_FUND_ID  STRING  COMMENT  '产品编号',
  VC_FUND_VALUE_UPSEAT  STRING  COMMENT  '基金净值上传席位',
  C_HGZCFKJS_MODE  STRING  COMMENT  '回购资产风控计算模式',
  L_SJSGZJ_WS  DECIMAL(2,0)  COMMENT  '深交所债券估值价小数位数',
  L_SJSKZZGZJ_WZ  DECIMAL(2,0)  COMMENT  '深交所可转债估值价小数位数',
  C_UFT_TRADE  STRING  COMMENT  '是否极速交易',
  C_APPROVE_MODE  STRING  COMMENT  '审批模式控制',
  C_GGTGZJGXS_MODE  STRING  COMMENT  '港股通估值价格小数处理模式',
  C_AGENT_TYPE  STRING  COMMENT  '代销模式',
  VC_DEFAULT_SALEORG  STRING  COMMENT  '默认销售机构',
  C_BANKBOND_GZ_DECIMAL  STRING  COMMENT  '银行间债券估值价小数位数',
  C_FUNDFLOW_TYPE  STRING  COMMENT  '资金流向类型',
  VC_CHECK_SALEORG  STRING  COMMENT  '销售机构查验',
  C_UC_QHLIQ_FLAG  STRING  COMMENT  'uc_期货清算完成状态',
  L_LAST_IMPORT_DATE  DECIMAL(8,0)  COMMENT  '最近导入日期',
  C_GZXYZR_VALUE_TYPE  STRING  COMMENT  '股转协议转让证券估值类型',
  C_JYSSMZ_VALUE_TYPE  STRING  COMMENT  '交易所私募债估值类型',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_CANCEL_DATE  DECIMAL(8,0)  COMMENT  '注销日期',
  L_GGT_SET_NO  DECIMAL(10,0)  COMMENT  '港股通汇率套号',
  C_JYSQJJYZQ_VALUE_MODE  STRING  COMMENT  '交易所全价交易债券估值类型',
  C_LIQUIDATE_STATUS  STRING  COMMENT  '账户现货清算状态',
  C_FUTURES_LIQUIDATE_STATUS  STRING  COMMENT  '账户期货清算状态',
  L_PROVISION_ASSET  DECIMAL(8,0)  COMMENT  '备付金冻结单元',
  C_TRADE_SETTLE_MODE  STRING  COMMENT  '交易结算模式',
  VC_OPEN_RANGE  STRING  COMMENT  '基金开放区间',
  L_VALUEMODEL_ID  DECIMAL(4,0)  COMMENT  '估值模板序号',
  C_GGT_TAX_FLAG  STRING  COMMENT  '',
  L_LAST_SS_DAY  DECIMAL(4,0)  COMMENT  '',
  C_AUPRICE_VALUE_TYPE  STRING  COMMENT  '',
  C_DEPT_TYPE  STRING  COMMENT  '部门类型',
  VC_FUND_MANAGERS  STRING  COMMENT  '基金经理',
  C_QS_SETTLE_MODE  STRING  COMMENT  '清算模式',
  C_LIQ_FLAG  STRING  COMMENT  '',
  VC_PLEDGE_ACCOUNT  STRING  COMMENT  '',
  C_GENHG_BZJ_MODE  STRING  COMMENT  '',
  C_INDEX_CHANGE_DATE  DECIMAL(8,0)  COMMENT  '指标改变日期',
  C_RESACCOUNT_TYPE  STRING  COMMENT  '',
  L_HEDGEYE_DAY  DECIMAL(8,0)  COMMENT  '',
  C_RAISE_TYPE  STRING  COMMENT  '终止类型',
  C_OPERATE_TYPE  STRING  COMMENT  '操作类型',
  VC_BANKCUST_CODE  STRING  COMMENT  '银行客户代码',
  VC_INSTITUT_CODE  STRING  COMMENT  '研究代码',
  L_VIRTUAL_COMBI_ID  DECIMAL(12,0)  COMMENT  '事实组合ID',
  C_BANK_ACCOUNT_TYPE  STRING  COMMENT  '银行账户类型',
  C_SHCLEARING_ACCOUNT_TYPE  STRING  COMMENT  '清理账户类型',
  VC_FUND_RECORD_CODE  STRING  COMMENT  '资金记录代码',
  L_SHZQGZJ_WS  DECIMAL(2,0)  COMMENT  '',
  VC_DISCOUNT_RESTYPE  STRING  COMMENT  '',
  L_SHSMZ_WS  DECIMAL(2,0)  COMMENT  '',
  C_CUSTOM_TYPE  STRING  COMMENT  '消费类型',
  EN_BUY_RATIO  DECIMAL(9,4)  COMMENT  '买进率',
  EN_SALE_RATIO  DECIMAL(9,4)  COMMENT  '卖出率',
  EN_LIMIT_BALANCE  DECIMAL(18,2)  COMMENT  '结算保证金最低限额',
  C_GGT_PAYMENT_POINT  STRING  COMMENT  '',
  C_GGT_SETTLEMENT_POINT  STRING  COMMENT  '',
  C_GGT_ASSETNETSALE_AVAILABLE  STRING  COMMENT  '',
  C_DAYEND_FLAG  STRING  COMMENT  '',
  L_SHKZZGZJ_WS  DECIMAL(2,0)  COMMENT  '',
  VC_AUTOSETTLE_FLAG  STRING  COMMENT  '',
  VC_UNFROZEN_FLAG  STRING  COMMENT  '',
  C_GGT_ADVANCEDIF_METHOD  STRING  COMMENT  '',
  C_GGT_ADVANCEDIF_POINT  STRING  COMMENT  '',
  VC_ZRTPARTICIPANT_CODE  STRING  COMMENT  ''
)
COMMENT '基金信息表'
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
              "querySql": ["SELECT  L_FUND_ID
                                   , VC_FUND_CODE
                                   , VC_FUND_NAME
                                   , VC_FUND_CAPTION
                                   , L_DEFAULT_ASSET
                                   , L_DEFAULT_COMBI
                                   , L_OPEN_DATE
                                   , C_INTEREST_CLASS
                                   , C_VALUE_CLASS
                                   , C_FUND_TYPE
                                   , C_FUND_STATUS
                                   , C_CHECK_TYPE
                                   , C_OUT_BOND_TYPE
                                   , VC_REMARKS
                                   , L_END_DATE
                                   , C_ACCOUNTANT_TYPE
                                   , C_FALOAD_STATE
                                   , VC_SEQUARE_CODE
                                   , VC_TA_CODE
                                   , L_BANK_ID
                                   , EN_FUND_SHARE
                                   , C_NEED_FA
                                   , C_FADEAL_STATE
                                   , VC_CURRENCY_NO
                                   , L_LOCAL_CUSTODIAN
                                   , L_FOREIGN_CUSTODIAN
                                   , VC_PERMIT_MARKET
                                   , C_CHANGE_METHOD
                                   , C_MULTI_CURRENCY
                                   , VC_COLLECT_CURRENCY_NO
                                   , C_CASH_ADDUP
                                   , C_LIQUIDATE_ALONE
                                   , C_TN_LIQUIDATE
                                   , L_LIQUIDATE_TIME
                                   , L_BUSINESS_DATE
                                   , L_LIQUIDATE_DATE
                                   , C_SYNONYM_FLAG
                                   , VC_BANK_ACCOUNT
                                   , C_CALCULATE_TYPE
                                   , VC_CASH_CONTROL_POINT
                                   , VC_STOCK_CONTROL_POINT
                                   , L_BRANCH_DATE
                                   , C_ACCOUNT_TYPE
                                   , C_TAX_FLAG
                                   , C_LONG_STOP_TYPE
                                   , L_PAPER_NO
                                   , L_NET_PRICE_DIGITS
                                   , L_BEENTRUST_NO
                                   , VC_BANK_NAME
                                   , VC_TRUST_ACCOUNT
                                   , VC_ACCOUNT_NAME
                                   , L_PATTERN_ID
                                   , C_FROZEN_DAY_TYPE
                                   , L_FROZEN_DAYS
                                   , VC_OBJECT_CODE
                                   , C_BOND_RISK_VALUE
                                   , C_GROUPFA
                                   , C_TASETTLE_TYPE
                                   , VC_SUBCONTRACT_NO
                                   , VC_INTRABANK_NO
                                   , VC_PAY_NO
                                   , C_BOND_RISK_COST
                                   , EN_FOREIGH_QUOTA
                                   , L_APPLY_EXCHANGE_DAYS
                                   , L_REDEMPTION_EXCHANGE_DAYS
                                   , VC_FOREIGN_TRUST_ACCOUNT
                                   , C_INVEST_DIRECTION
                                   , C_MARKET_TYPE
                                   , VC_PERMIT_ETFS
                                   , C_INVEST_TYPE
                                   , C_USE_LOOSE_BALANCE
                                   , C_ETF_VALUE_TYPE
                                   , C_FUTURE_LIQUIDATE_ALONE
                                   , C_FUTURES_INVEST_TYPE
                                   , C_BONDACCOUNT_TYPE
                                   , VC_BANK_LINKMAN
                                   , VC_BANK_PHONE
                                   , VC_BANK_FAX
                                   , VC_PROVINCECODE
                                   , VC_CITY
                                   , L_SET_NO
                                   , C_BOND_STOP_TYPE
                                   , C_GX_CASH_LINKED
                                   , L_TADEAL_SERIALNO
                                   , L_FUTURE_BRANCH_DATE
                                   , VC_SHCLEARING_ACCOUNT
                                   , C_RZ_TYPE
                                   , EN_RZ_LIMIT
                                   , VC_RZ_ITEMS
                                   , EN_FUTURE_STOPLOSS_RATIO
                                   , C_TAX_TYPE
                                   , C_FROZEN_BYASSET
                                   , VC_FAIMP_SOURCE
                                   , L_FROZEN_START_DAYS
                                   , VC_FA_NET_NAME
                                   , C_TRADE_TYPE
                                   , EN_NAVTOSUB_RATIO
                                   , C_CLASS_BOND_TYPE
                                   , C_EXCHANGE_ABS_TYPE
                                   , C_BANK_ABS_TYPE
                                   , L_YYSH_CASH_FROZEN
                                   , L_YYSH_STOCK_FROZEN
                                   , VC_BANK_ACCOUNT_NAME
                                   , VC_SHCLEARING_ACCOUNT_NAME
                                   , L_ASSET_REF_TIME
                                   , L_APPROVAL_OPERATOR_NO
                                   , C_ZZD_TYPE
                                   , C_EXCHANGE_NET_TYPE
                                   , C_INITIALIZTION_FLAG
                                   , C_INACTIVE_TYPE
                                   , EN_FUND_FACEVALUE
                                   , L_ORG_ID
                                   , EN_FACT_COLLECT
                                   , EN_FACT_COLLECT_SHARES
                                   , L_DEPT_ID
                                   , C_ZQ_GZMS
                                   , C_YHJZQ_PRICE_SOURCE
                                   , C_JYSZQ_PRICE_SOURCE
                                   , C_FA_PRECISION_MODE
                                   , C_COMMISION_MODE
                                   , VC_FUND_ID
                                   , VC_FUND_VALUE_UPSEAT
                                   , C_HGZCFKJS_MODE
                                   , L_SJSGZJ_WS
                                   , L_SJSKZZGZJ_WZ
                                   , C_UFT_TRADE
                                   , C_APPROVE_MODE
                                   , C_GGTGZJGXS_MODE
                                   , C_AGENT_TYPE
                                   , VC_DEFAULT_SALEORG
                                   , C_BANKBOND_GZ_DECIMAL
                                   , C_FUNDFLOW_TYPE
                                   , VC_CHECK_SALEORG
                                   , C_UC_QHLIQ_FLAG
                                   , L_LAST_IMPORT_DATE
                                   , C_GZXYZR_VALUE_TYPE
                                   , C_JYSSMZ_VALUE_TYPE
                                   , VC_TIMESTAMP
                                   , L_CANCEL_DATE
                                   , L_GGT_SET_NO
                                   , C_JYSQJJYZQ_VALUE_MODE
                                   , C_LIQUIDATE_STATUS
                                   , C_FUTURES_LIQUIDATE_STATUS
                                   , L_PROVISION_ASSET
                                   , C_TRADE_SETTLE_MODE
                                   , VC_OPEN_RANGE
                                   , L_VALUEMODEL_ID
                                   , C_GGT_TAX_FLAG
                                   , L_LAST_SS_DAY
                                   , C_AUPRICE_VALUE_TYPE
                                   , C_DEPT_TYPE
                                   , VC_FUND_MANAGERS
                                   , C_QS_SETTLE_MODE
                                   , C_LIQ_FLAG
                                   , VC_PLEDGE_ACCOUNT
                                   , C_GENHG_BZJ_MODE
                                   , C_INDEX_CHANGE_DATE
                                   , C_RESACCOUNT_TYPE
                                   , L_HEDGEYE_DAY
                                   , C_RAISE_TYPE
                                   , C_OPERATE_TYPE
                                   , VC_BANKCUST_CODE
                                   , VC_INSTITUT_CODE
                                   , L_VIRTUAL_COMBI_ID
                                   , C_BANK_ACCOUNT_TYPE
                                   , C_SHCLEARING_ACCOUNT_TYPE
                                   , VC_FUND_RECORD_CODE
                                   , L_SHZQGZJ_WS
                                   , VC_DISCOUNT_RESTYPE
                                   , L_SHSMZ_WS
                                   , C_CUSTOM_TYPE
                                   , EN_BUY_RATIO
                                   , EN_SALE_RATIO
                                   , EN_LIMIT_BALANCE
                                   , C_GGT_PAYMENT_POINT
                                   , C_GGT_SETTLEMENT_POINT
                                   , C_GGT_ASSETNETSALE_AVAILABLE
                                   , C_DAYEND_FLAG
                                   , L_SHKZZGZJ_WS
                                   , VC_AUTOSETTLE_FLAG
                                   , VC_UNFROZEN_FLAG
                                   , C_GGT_ADVANCEDIF_METHOD
                                   , C_GGT_ADVANCEDIF_POINT
                                   , VC_ZRTPARTICIPANT_CODE
                                FROM ${o32_src_schema}.TFUNDINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_FUND_CODE", "type": "STRING"}, {"name": "VC_FUND_NAME", "type": "STRING"}, {"name": "VC_FUND_CAPTION", "type": "STRING"}, {"name": "L_DEFAULT_ASSET", "type": "DOUBLE"}, {"name": "L_DEFAULT_COMBI", "type": "DOUBLE"}, {"name": "L_OPEN_DATE", "type": "DOUBLE"}, {"name": "C_INTEREST_CLASS", "type": "STRING"}, {"name": "C_VALUE_CLASS", "type": "STRING"}, {"name": "C_FUND_TYPE", "type": "STRING"}, {"name": "C_FUND_STATUS", "type": "STRING"}, {"name": "C_CHECK_TYPE", "type": "STRING"}, {"name": "C_OUT_BOND_TYPE", "type": "STRING"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "C_ACCOUNTANT_TYPE", "type": "STRING"}, {"name": "C_FALOAD_STATE", "type": "STRING"}, {"name": "VC_SEQUARE_CODE", "type": "STRING"}, {"name": "VC_TA_CODE", "type": "STRING"}, {"name": "L_BANK_ID", "type": "DOUBLE"}, {"name": "EN_FUND_SHARE", "type": "DOUBLE"}, {"name": "C_NEED_FA", "type": "STRING"}, {"name": "C_FADEAL_STATE", "type": "STRING"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "L_LOCAL_CUSTODIAN", "type": "DOUBLE"}, {"name": "L_FOREIGN_CUSTODIAN", "type": "DOUBLE"}, {"name": "VC_PERMIT_MARKET", "type": "STRING"}, {"name": "C_CHANGE_METHOD", "type": "STRING"}, {"name": "C_MULTI_CURRENCY", "type": "STRING"}, {"name": "VC_COLLECT_CURRENCY_NO", "type": "STRING"}, {"name": "C_CASH_ADDUP", "type": "STRING"}, {"name": "C_LIQUIDATE_ALONE", "type": "STRING"}, {"name": "C_TN_LIQUIDATE", "type": "STRING"}, {"name": "L_LIQUIDATE_TIME", "type": "DOUBLE"}, {"name": "L_BUSINESS_DATE", "type": "DOUBLE"}, {"name": "L_LIQUIDATE_DATE", "type": "DOUBLE"}, {"name": "C_SYNONYM_FLAG", "type": "STRING"}, {"name": "VC_BANK_ACCOUNT", "type": "STRING"}, {"name": "C_CALCULATE_TYPE", "type": "STRING"}, {"name": "VC_CASH_CONTROL_POINT", "type": "STRING"}, {"name": "VC_STOCK_CONTROL_POINT", "type": "STRING"}, {"name": "L_BRANCH_DATE", "type": "DOUBLE"}, {"name": "C_ACCOUNT_TYPE", "type": "STRING"}, {"name": "C_TAX_FLAG", "type": "STRING"}, {"name": "C_LONG_STOP_TYPE", "type": "STRING"}, {"name": "L_PAPER_NO", "type": "DOUBLE"}, {"name": "L_NET_PRICE_DIGITS", "type": "DOUBLE"}, {"name": "L_BEENTRUST_NO", "type": "DOUBLE"}, {"name": "VC_BANK_NAME", "type": "STRING"}, {"name": "VC_TRUST_ACCOUNT", "type": "STRING"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "L_PATTERN_ID", "type": "DOUBLE"}, {"name": "C_FROZEN_DAY_TYPE", "type": "STRING"}, {"name": "L_FROZEN_DAYS", "type": "DOUBLE"}, {"name": "VC_OBJECT_CODE", "type": "STRING"}, {"name": "C_BOND_RISK_VALUE", "type": "STRING"}, {"name": "C_GROUPFA", "type": "STRING"}, {"name": "C_TASETTLE_TYPE", "type": "STRING"}, {"name": "VC_SUBCONTRACT_NO", "type": "STRING"}, {"name": "VC_INTRABANK_NO", "type": "STRING"}, {"name": "VC_PAY_NO", "type": "STRING"}, {"name": "C_BOND_RISK_COST", "type": "STRING"}, {"name": "EN_FOREIGH_QUOTA", "type": "DOUBLE"}, {"name": "L_APPLY_EXCHANGE_DAYS", "type": "DOUBLE"}, {"name": "L_REDEMPTION_EXCHANGE_DAYS", "type": "DOUBLE"}, {"name": "VC_FOREIGN_TRUST_ACCOUNT", "type": "STRING"}, {"name": "C_INVEST_DIRECTION", "type": "STRING"}, {"name": "C_MARKET_TYPE", "type": "STRING"}, {"name": "VC_PERMIT_ETFS", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_USE_LOOSE_BALANCE", "type": "STRING"}, {"name": "C_ETF_VALUE_TYPE", "type": "STRING"}, {"name": "C_FUTURE_LIQUIDATE_ALONE", "type": "STRING"}, {"name": "C_FUTURES_INVEST_TYPE", "type": "STRING"}, {"name": "C_BONDACCOUNT_TYPE", "type": "STRING"}, {"name": "VC_BANK_LINKMAN", "type": "STRING"}, {"name": "VC_BANK_PHONE", "type": "STRING"}, {"name": "VC_BANK_FAX", "type": "STRING"}, {"name": "VC_PROVINCECODE", "type": "STRING"}, {"name": "VC_CITY", "type": "STRING"}, {"name": "L_SET_NO", "type": "DOUBLE"}, {"name": "C_BOND_STOP_TYPE", "type": "STRING"}, {"name": "C_GX_CASH_LINKED", "type": "STRING"}, {"name": "L_TADEAL_SERIALNO", "type": "DOUBLE"}, {"name": "L_FUTURE_BRANCH_DATE", "type": "DOUBLE"}, {"name": "VC_SHCLEARING_ACCOUNT", "type": "STRING"}, {"name": "C_RZ_TYPE", "type": "STRING"}, {"name": "EN_RZ_LIMIT", "type": "DOUBLE"}, {"name": "VC_RZ_ITEMS", "type": "STRING"}, {"name": "EN_FUTURE_STOPLOSS_RATIO", "type": "DOUBLE"}, {"name": "C_TAX_TYPE", "type": "STRING"}, {"name": "C_FROZEN_BYASSET", "type": "STRING"}, {"name": "VC_FAIMP_SOURCE", "type": "STRING"}, {"name": "L_FROZEN_START_DAYS", "type": "DOUBLE"}, {"name": "VC_FA_NET_NAME", "type": "STRING"}, {"name": "C_TRADE_TYPE", "type": "STRING"}, {"name": "EN_NAVTOSUB_RATIO", "type": "DOUBLE"}, {"name": "C_CLASS_BOND_TYPE", "type": "STRING"}, {"name": "C_EXCHANGE_ABS_TYPE", "type": "STRING"}, {"name": "C_BANK_ABS_TYPE", "type": "STRING"}, {"name": "L_YYSH_CASH_FROZEN", "type": "DOUBLE"}, {"name": "L_YYSH_STOCK_FROZEN", "type": "DOUBLE"}, {"name": "VC_BANK_ACCOUNT_NAME", "type": "STRING"}, {"name": "VC_SHCLEARING_ACCOUNT_NAME", "type": "STRING"}, {"name": "L_ASSET_REF_TIME", "type": "DOUBLE"}, {"name": "L_APPROVAL_OPERATOR_NO", "type": "DOUBLE"}, {"name": "C_ZZD_TYPE", "type": "STRING"}, {"name": "C_EXCHANGE_NET_TYPE", "type": "STRING"}, {"name": "C_INITIALIZTION_FLAG", "type": "STRING"}, {"name": "C_INACTIVE_TYPE", "type": "STRING"}, {"name": "EN_FUND_FACEVALUE", "type": "DOUBLE"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "EN_FACT_COLLECT", "type": "DOUBLE"}, {"name": "EN_FACT_COLLECT_SHARES", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "C_ZQ_GZMS", "type": "STRING"}, {"name": "C_YHJZQ_PRICE_SOURCE", "type": "STRING"}, {"name": "C_JYSZQ_PRICE_SOURCE", "type": "STRING"}, {"name": "C_FA_PRECISION_MODE", "type": "STRING"}, {"name": "C_COMMISION_MODE", "type": "STRING"}, {"name": "VC_FUND_ID", "type": "STRING"}, {"name": "VC_FUND_VALUE_UPSEAT", "type": "STRING"}, {"name": "C_HGZCFKJS_MODE", "type": "STRING"}, {"name": "L_SJSGZJ_WS", "type": "DOUBLE"}, {"name": "L_SJSKZZGZJ_WZ", "type": "DOUBLE"}, {"name": "C_UFT_TRADE", "type": "STRING"}, {"name": "C_APPROVE_MODE", "type": "STRING"}, {"name": "C_GGTGZJGXS_MODE", "type": "STRING"}, {"name": "C_AGENT_TYPE", "type": "STRING"}, {"name": "VC_DEFAULT_SALEORG", "type": "STRING"}, {"name": "C_BANKBOND_GZ_DECIMAL", "type": "STRING"}, {"name": "C_FUNDFLOW_TYPE", "type": "STRING"}, {"name": "VC_CHECK_SALEORG", "type": "STRING"}, {"name": "C_UC_QHLIQ_FLAG", "type": "STRING"}, {"name": "L_LAST_IMPORT_DATE", "type": "DOUBLE"}, {"name": "C_GZXYZR_VALUE_TYPE", "type": "STRING"}, {"name": "C_JYSSMZ_VALUE_TYPE", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_CANCEL_DATE", "type": "DOUBLE"}, {"name": "L_GGT_SET_NO", "type": "DOUBLE"}, {"name": "C_JYSQJJYZQ_VALUE_MODE", "type": "STRING"}, {"name": "C_LIQUIDATE_STATUS", "type": "STRING"}, {"name": "C_FUTURES_LIQUIDATE_STATUS", "type": "STRING"}, {"name": "L_PROVISION_ASSET", "type": "DOUBLE"}, {"name": "C_TRADE_SETTLE_MODE", "type": "STRING"}, {"name": "VC_OPEN_RANGE", "type": "STRING"}, {"name": "L_VALUEMODEL_ID", "type": "DOUBLE"}, {"name": "C_GGT_TAX_FLAG", "type": "STRING"}, {"name": "L_LAST_SS_DAY", "type": "DOUBLE"}, {"name": "C_AUPRICE_VALUE_TYPE", "type": "STRING"}, {"name": "C_DEPT_TYPE", "type": "STRING"}, {"name": "VC_FUND_MANAGERS", "type": "STRING"}, {"name": "C_QS_SETTLE_MODE", "type": "STRING"}, {"name": "C_LIQ_FLAG", "type": "STRING"}, {"name": "VC_PLEDGE_ACCOUNT", "type": "STRING"}, {"name": "C_GENHG_BZJ_MODE", "type": "STRING"}, {"name": "C_INDEX_CHANGE_DATE", "type": "DOUBLE"}, {"name": "C_RESACCOUNT_TYPE", "type": "STRING"}, {"name": "L_HEDGEYE_DAY", "type": "DOUBLE"}, {"name": "C_RAISE_TYPE", "type": "STRING"}, {"name": "C_OPERATE_TYPE", "type": "STRING"}, {"name": "VC_BANKCUST_CODE", "type": "STRING"}, {"name": "VC_INSTITUT_CODE", "type": "STRING"}, {"name": "L_VIRTUAL_COMBI_ID", "type": "DOUBLE"}, {"name": "C_BANK_ACCOUNT_TYPE", "type": "STRING"}, {"name": "C_SHCLEARING_ACCOUNT_TYPE", "type": "STRING"}, {"name": "VC_FUND_RECORD_CODE", "type": "STRING"}, {"name": "L_SHZQGZJ_WS", "type": "DOUBLE"}, {"name": "VC_DISCOUNT_RESTYPE", "type": "STRING"}, {"name": "L_SHSMZ_WS", "type": "DOUBLE"}, {"name": "C_CUSTOM_TYPE", "type": "STRING"}, {"name": "EN_BUY_RATIO", "type": "DOUBLE"}, {"name": "EN_SALE_RATIO", "type": "DOUBLE"}, {"name": "EN_LIMIT_BALANCE", "type": "DOUBLE"}, {"name": "C_GGT_PAYMENT_POINT", "type": "STRING"}, {"name": "C_GGT_SETTLEMENT_POINT", "type": "STRING"}, {"name": "C_GGT_ASSETNETSALE_AVAILABLE", "type": "STRING"}, {"name": "C_DAYEND_FLAG", "type": "STRING"}, {"name": "L_SHKZZGZJ_WS", "type": "DOUBLE"}, {"name": "VC_AUTOSETTLE_FLAG", "type": "STRING"}, {"name": "VC_UNFROZEN_FLAG", "type": "STRING"}, {"name": "C_GGT_ADVANCEDIF_METHOD", "type": "STRING"}, {"name": "C_GGT_ADVANCEDIF_POINT", "type": "STRING"}, {"name": "VC_ZRTPARTICIPANT_CODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfundinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfundinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfundinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfundinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFUNDINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFUNDINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfundinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_FUND_ID
     , VC_FUND_CODE
     , VC_FUND_NAME
     , VC_FUND_CAPTION
     , L_DEFAULT_ASSET
     , L_DEFAULT_COMBI
     , L_OPEN_DATE
     , C_INTEREST_CLASS
     , C_VALUE_CLASS
     , C_FUND_TYPE
     , C_FUND_STATUS
     , C_CHECK_TYPE
     , C_OUT_BOND_TYPE
     , VC_REMARKS
     , L_END_DATE
     , C_ACCOUNTANT_TYPE
     , C_FALOAD_STATE
     , VC_SEQUARE_CODE
     , VC_TA_CODE
     , L_BANK_ID
     , EN_FUND_SHARE
     , C_NEED_FA
     , C_FADEAL_STATE
     , VC_CURRENCY_NO
     , L_LOCAL_CUSTODIAN
     , L_FOREIGN_CUSTODIAN
     , VC_PERMIT_MARKET
     , C_CHANGE_METHOD
     , C_MULTI_CURRENCY
     , VC_COLLECT_CURRENCY_NO
     , C_CASH_ADDUP
     , C_LIQUIDATE_ALONE
     , C_TN_LIQUIDATE
     , L_LIQUIDATE_TIME
     , L_BUSINESS_DATE
     , L_LIQUIDATE_DATE
     , C_SYNONYM_FLAG
     , VC_BANK_ACCOUNT
     , C_CALCULATE_TYPE
     , VC_CASH_CONTROL_POINT
     , VC_STOCK_CONTROL_POINT
     , L_BRANCH_DATE
     , C_ACCOUNT_TYPE
     , C_TAX_FLAG
     , C_LONG_STOP_TYPE
     , L_PAPER_NO
     , L_NET_PRICE_DIGITS
     , L_BEENTRUST_NO
     , VC_BANK_NAME
     , VC_TRUST_ACCOUNT
     , VC_ACCOUNT_NAME
     , L_PATTERN_ID
     , C_FROZEN_DAY_TYPE
     , L_FROZEN_DAYS
     , VC_OBJECT_CODE
     , C_BOND_RISK_VALUE
     , C_GROUPFA
     , C_TASETTLE_TYPE
     , VC_SUBCONTRACT_NO
     , VC_INTRABANK_NO
     , VC_PAY_NO
     , C_BOND_RISK_COST
     , EN_FOREIGH_QUOTA
     , L_APPLY_EXCHANGE_DAYS
     , L_REDEMPTION_EXCHANGE_DAYS
     , VC_FOREIGN_TRUST_ACCOUNT
     , C_INVEST_DIRECTION
     , C_MARKET_TYPE
     , VC_PERMIT_ETFS
     , C_INVEST_TYPE
     , C_USE_LOOSE_BALANCE
     , C_ETF_VALUE_TYPE
     , C_FUTURE_LIQUIDATE_ALONE
     , C_FUTURES_INVEST_TYPE
     , C_BONDACCOUNT_TYPE
     , VC_BANK_LINKMAN
     , VC_BANK_PHONE
     , VC_BANK_FAX
     , VC_PROVINCECODE
     , VC_CITY
     , L_SET_NO
     , C_BOND_STOP_TYPE
     , C_GX_CASH_LINKED
     , L_TADEAL_SERIALNO
     , L_FUTURE_BRANCH_DATE
     , VC_SHCLEARING_ACCOUNT
     , C_RZ_TYPE
     , EN_RZ_LIMIT
     , VC_RZ_ITEMS
     , EN_FUTURE_STOPLOSS_RATIO
     , C_TAX_TYPE
     , C_FROZEN_BYASSET
     , VC_FAIMP_SOURCE
     , L_FROZEN_START_DAYS
     , VC_FA_NET_NAME
     , C_TRADE_TYPE
     , EN_NAVTOSUB_RATIO
     , C_CLASS_BOND_TYPE
     , C_EXCHANGE_ABS_TYPE
     , C_BANK_ABS_TYPE
     , L_YYSH_CASH_FROZEN
     , L_YYSH_STOCK_FROZEN
     , VC_BANK_ACCOUNT_NAME
     , VC_SHCLEARING_ACCOUNT_NAME
     , L_ASSET_REF_TIME
     , L_APPROVAL_OPERATOR_NO
     , C_ZZD_TYPE
     , C_EXCHANGE_NET_TYPE
     , C_INITIALIZTION_FLAG
     , C_INACTIVE_TYPE
     , EN_FUND_FACEVALUE
     , L_ORG_ID
     , EN_FACT_COLLECT
     , EN_FACT_COLLECT_SHARES
     , L_DEPT_ID
     , C_ZQ_GZMS
     , C_YHJZQ_PRICE_SOURCE
     , C_JYSZQ_PRICE_SOURCE
     , C_FA_PRECISION_MODE
     , C_COMMISION_MODE
     , VC_FUND_ID
     , VC_FUND_VALUE_UPSEAT
     , C_HGZCFKJS_MODE
     , L_SJSGZJ_WS
     , L_SJSKZZGZJ_WZ
     , C_UFT_TRADE
     , C_APPROVE_MODE
     , C_GGTGZJGXS_MODE
     , C_AGENT_TYPE
     , VC_DEFAULT_SALEORG
     , C_BANKBOND_GZ_DECIMAL
     , C_FUNDFLOW_TYPE
     , VC_CHECK_SALEORG
     , C_UC_QHLIQ_FLAG
     , L_LAST_IMPORT_DATE
     , C_GZXYZR_VALUE_TYPE
     , C_JYSSMZ_VALUE_TYPE
     , VC_TIMESTAMP
     , L_CANCEL_DATE
     , L_GGT_SET_NO
     , C_JYSQJJYZQ_VALUE_MODE
     , C_LIQUIDATE_STATUS
     , C_FUTURES_LIQUIDATE_STATUS
     , L_PROVISION_ASSET
     , C_TRADE_SETTLE_MODE
     , VC_OPEN_RANGE
     , L_VALUEMODEL_ID
     , C_GGT_TAX_FLAG
     , L_LAST_SS_DAY
     , C_AUPRICE_VALUE_TYPE
     , C_DEPT_TYPE
     , VC_FUND_MANAGERS
     , C_QS_SETTLE_MODE
     , C_LIQ_FLAG
     , VC_PLEDGE_ACCOUNT
     , C_GENHG_BZJ_MODE
     , C_INDEX_CHANGE_DATE
     , C_RESACCOUNT_TYPE
     , L_HEDGEYE_DAY
     , C_RAISE_TYPE
     , C_OPERATE_TYPE
     , VC_BANKCUST_CODE
     , VC_INSTITUT_CODE
     , L_VIRTUAL_COMBI_ID
     , C_BANK_ACCOUNT_TYPE
     , C_SHCLEARING_ACCOUNT_TYPE
     , VC_FUND_RECORD_CODE
     , L_SHZQGZJ_WS
     , VC_DISCOUNT_RESTYPE
     , L_SHSMZ_WS
     , C_CUSTOM_TYPE
     , EN_BUY_RATIO
     , EN_SALE_RATIO
     , EN_LIMIT_BALANCE
     , C_GGT_PAYMENT_POINT
     , C_GGT_SETTLEMENT_POINT
     , C_GGT_ASSETNETSALE_AVAILABLE
     , C_DAYEND_FLAG
     , L_SHKZZGZJ_WS
     , VC_AUTOSETTLE_FLAG
     , VC_UNFROZEN_FLAG
     , C_GGT_ADVANCEDIF_METHOD
     , C_GGT_ADVANCEDIF_POINT
     , VC_ZRTPARTICIPANT_CODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFUNDINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFUNDINFO_PFD成功"
      exit 0
   fi
fi
