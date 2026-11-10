#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFUNDSTOCK_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDSTOCK_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  VC_BIND_SEAT  STRING  COMMENT  '托管席位',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_BEGIN_AMOUNT  DECIMAL(20,4)  COMMENT  '期初数量',
  L_CURRENT_AMOUNT  DECIMAL(20,4)  COMMENT  '当前数量',
  L_BUY_AMOUNT  DECIMAL(20,4)  COMMENT  '当日买入数量',
  L_SALE_AMOUNT  DECIMAL(20,4)  COMMENT  '当日卖出数量',
  L_PREBUY_AMOUNT  DECIMAL(20,4)  COMMENT  '当日预买数量',
  L_PRESALE_AMOUNT  DECIMAL(20,4)  COMMENT  '当日预卖数量',
  EN_BUY_BALANCE  DECIMAL(18,2)  COMMENT  '当日买入金额',
  EN_SALE_BALANCE  DECIMAL(18,2)  COMMENT  '当日卖出金额',
  EN_BUY_FEE  DECIMAL(18,2)  COMMENT  '当日买入费用',
  EN_SALE_FEE  DECIMAL(18,2)  COMMENT  '当日卖出费用',
  EN_UNTRANSFERED_INVEST  DECIMAL(18,2)  COMMENT  '期初成本',
  EN_INTEREST_INVEST  DECIMAL(18,2)  COMMENT  '期初债券利息成本',
  EN_ACCUMULATE_PROFIT  DECIMAL(18,2)  COMMENT  '累计实现收益',
  EN_TURN_INVEST  DECIMAL(18,2)  COMMENT  '期初的原始成本',
  EN_TURN_INTEREST_INVEST  DECIMAL(18,2)  COMMENT  '结转前利息成本',
  EN_TURN_PROFIT  DECIMAL(18,2)  COMMENT  '结转收益',
  L_BUY_UNSETTLE_AMOUNT  DECIMAL(20,4)  COMMENT  '买入未交割数量',
  L_SALE_UNSETTLE_AMOUNT  DECIMAL(20,4)  COMMENT  '卖出未交割数量',
  EN_BUY_UNSETTLE_BALANCE  DECIMAL(18,2)  COMMENT  '买入未交割金额',
  EN_SALE_UNSETTLE_BALANCE  DECIMAL(18,2)  COMMENT  '卖出未交割金额',
  EN_CURRENT_COST  DECIMAL(18,2)  COMMENT  '当前成本',
  EN_TODAY_PROFIT  DECIMAL(18,2)  COMMENT  '当日实现收益',
  C_POSITION_FLAG  STRING  COMMENT  '持仓多空标志',
  EN_TRADE_BALANCE  DECIMAL(18,2)  COMMENT  '买卖资金占用',
  EN_REAL_BUY_FEE  DECIMAL(18,2)  COMMENT  '实际当日买入费用',
  EN_REAL_SALE_FEE  DECIMAL(18,2)  COMMENT  '实际当日卖出费用',
  EN_REAL_COST  DECIMAL(18,2)  COMMENT  '结转后含费用期初成本',
  EN_UNCARRYOVER_REAL_COST  DECIMAL(18,2)  COMMENT  '未结转含费用成本',
  EN_NET_GAIN  DECIMAL(18,2)  COMMENT  '结转后扣费用累计收益',
  EN_UNCARRYOVER_NET_GAIN  DECIMAL(18,2)  COMMENT  '未结转扣费用期初收益',
  EN_UNCARRYOVER_DIVIDEND  DECIMAL(18,2)  COMMENT  '未结转期初累计分红金额',
  EN_DIVIDEND  DECIMAL(18,2)  COMMENT  '结转期初累计分红金额',
  EN_TRADING_FEE  DECIMAL(18,2)  COMMENT  '结转后可交易资产总费用',
  EN_UNCARRYOVER_TRADING_FEE  DECIMAL(18,2)  COMMENT  '未结转可交易资产总费用',
  EN_INTEREST_PROFIT  DECIMAL(18,2)  COMMENT  '债券利息收益',
  EN_TURN_INTEREST_PROFIT  DECIMAL(18,2)  COMMENT  '结转债券利息收益',
  EN_BEGINYEAR_TURN_PROFIT  DECIMAL(18,2)  COMMENT  '年初结转收益',
  EN_BEGINYEAR_UNTURN_PROFIT  DECIMAL(18,2)  COMMENT  '年初未结转收益',
  EN_INTEREST_GAIN  DECIMAL(18,2)  COMMENT  '债券利息实现收益',
  EN_TURN_INTEREST_GAIN  DECIMAL(18,2)  COMMENT  '结转债券利息实现收益',
  L_T1_PREBUY_AMOUNT  DECIMAL(20,4)  COMMENT  't+1日预买数量',
  L_T1_PRESALE_AMOUNT  DECIMAL(20,4)  COMMENT  't+1日预卖数量',
  L_ETF_APPLY_AMOUNT  DECIMAL(18,2)  COMMENT  'etf申购数量',
  L_ETF_REDEEM_AMOUNT  DECIMAL(18,2)  COMMENT  'etf赎回数量',
  L_TODAY_ENTR_STT_AMOUNT  DECIMAL(20,4)  COMMENT  '当日委托交割数量',
  L_TOTAL_ENTR_STT_AMOUNT  DECIMAL(20,4)  COMMENT  '累计委托交割数量',
  L_TODAY_DEAL_STT_AMOUNT  DECIMAL(20,4)  COMMENT  '当日成交交割数量',
  L_TOTAL_DEAL_STT_AMOUNT  DECIMAL(20,4)  COMMENT  '累计成交交割数量',
  L_BUY_UNASSET_AMOUNT  DECIMAL(18,2)  COMMENT  '买入资产未变化数量',
  L_SALE_UNASSET_AMOUNT  DECIMAL(18,2)  COMMENT  '卖出资产未变化数量',
  EN_TURN_INVEST_NEW  DECIMAL(18,2)  COMMENT  '新原始期初成本',
  EN_UNTRANSFERED_INVEST_NEW  DECIMAL(18,2)  COMMENT  '新结转后的期初成本',
  EN_ACCUMULATE_PROFIT_NEW  DECIMAL(18,2)  COMMENT  '新累计实现收益',
  EN_TURN_PROFIT_NEW  DECIMAL(18,2)  COMMENT  '新结转后实现收益',
  L_RESTRICTED_AMOUNT  DECIMAL(20,4)  COMMENT  '受限股数量',
  EN_DISCOUNT_RATIO  DECIMAL(14,12)  COMMENT  '折扣系数',
  L_BEGIN_ENABLE_DEDUCT_AMOUNT  DECIMAL(20,4)  COMMENT  '期初可抵扣数量',
  L_T0_ENABLE_DEDUCT_AMOUNT  DECIMAL(20,4)  COMMENT  't+可抵扣数量',
  L_T1_SALE_AMOUNT  DECIMAL(20,4)  COMMENT  't+1卖出数量',
  EN_CURRENT_IMPAWN_AMOUNT  DECIMAL(18,2)  COMMENT  '期初质押数量',
  EN_PRE_IMPAWN_AMOUNT  DECIMAL(18,2)  COMMENT  '当日预质押数量',
  EN_IMPAWN_AMOUNT  DECIMAL(18,2)  COMMENT  '当日质押数量',
  EN_PRE_RETURN_AMOUNT  DECIMAL(18,2)  COMMENT  '当日预转回数量',
  EN_RETURN_AMOUNT  DECIMAL(18,2)  COMMENT  '当日转回数量',
  L_GOLD_APPLY_AMOUNT  DECIMAL(20,4)  COMMENT  '黄金申购数量',
  L_STGPLC_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_STGPLC_FROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_STGPLC_TEMP_FROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  EN_SALE_REAL_COST  DECIMAL(18,2)  COMMENT  '销售实际成本',
  C_BUSINSPEC_PROPERTY  STRING  COMMENT  '',
  L_IMPAWN_DEDUCT_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_TEMP_IMPAWN_DEDUCT_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_PRE_RESOLD_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_PRE_REPURCHASED_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  EN_PAY_INTEREST  DECIMAL(18,2)  COMMENT  '支付利息',
  EN_TURN_PAY_INTEREST  DECIMAL(18,2)  COMMENT  '调节支付利息',
  EN_BANKHG_INTEREST  DECIMAL(18,2)  COMMENT  '银行利息',
  EN_TURN_BANKHG_INTEREST  DECIMAL(18,2)  COMMENT  '调整银行利息',
  L_TBDC_BOND_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_ETF_PHY_APPLY_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_ETF_PHY_REDEEM_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_MULTI_BUY_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  EN_MULTI_BUY_BALANCE  DECIMAL(20,4)  COMMENT  '',
  EN_MULTI_BUY_FEE  DECIMAL(20,4)  COMMENT  '',
  L_MULTI_BUY_RESTRICTED_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  EN_NET_PRICE  DECIMAL(20,12)  COMMENT  '',
  EN_FULL_PRICE  DECIMAL(20,12)  COMMENT  '全价',
  EN_NET_PRICE2  DECIMAL(20,12)  COMMENT  '净价',
  C_INTERCONNECTION_FLAG  STRING  COMMENT  ''
)
COMMENT '基金证券表'
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
                                   , VC_BIND_SEAT
                                   , VC_STOCKHOLDER_ID
                                   , C_INVEST_TYPE
                                   , VC_INTER_CODE
                                   , L_BEGIN_AMOUNT
                                   , L_CURRENT_AMOUNT
                                   , L_BUY_AMOUNT
                                   , L_SALE_AMOUNT
                                   , L_PREBUY_AMOUNT
                                   , L_PRESALE_AMOUNT
                                   , EN_BUY_BALANCE
                                   , EN_SALE_BALANCE
                                   , EN_BUY_FEE
                                   , EN_SALE_FEE
                                   , EN_UNTRANSFERED_INVEST
                                   , EN_INTEREST_INVEST
                                   , EN_ACCUMULATE_PROFIT
                                   , EN_TURN_INVEST
                                   , EN_TURN_INTEREST_INVEST
                                   , EN_TURN_PROFIT
                                   , L_BUY_UNSETTLE_AMOUNT
                                   , L_SALE_UNSETTLE_AMOUNT
                                   , EN_BUY_UNSETTLE_BALANCE
                                   , EN_SALE_UNSETTLE_BALANCE
                                   , EN_CURRENT_COST
                                   , EN_TODAY_PROFIT
                                   , C_POSITION_FLAG
                                   , EN_TRADE_BALANCE
                                   , EN_REAL_BUY_FEE
                                   , EN_REAL_SALE_FEE
                                   , EN_REAL_COST
                                   , EN_UNCARRYOVER_REAL_COST
                                   , EN_NET_GAIN
                                   , EN_UNCARRYOVER_NET_GAIN
                                   , EN_UNCARRYOVER_DIVIDEND
                                   , EN_DIVIDEND
                                   , EN_TRADING_FEE
                                   , EN_UNCARRYOVER_TRADING_FEE
                                   , EN_INTEREST_PROFIT
                                   , EN_TURN_INTEREST_PROFIT
                                   , EN_BEGINYEAR_TURN_PROFIT
                                   , EN_BEGINYEAR_UNTURN_PROFIT
                                   , EN_INTEREST_GAIN
                                   , EN_TURN_INTEREST_GAIN
                                   , L_T1_PREBUY_AMOUNT
                                   , L_T1_PRESALE_AMOUNT
                                   , L_ETF_APPLY_AMOUNT
                                   , L_ETF_REDEEM_AMOUNT
                                   , L_TODAY_ENTR_STT_AMOUNT
                                   , L_TOTAL_ENTR_STT_AMOUNT
                                   , L_TODAY_DEAL_STT_AMOUNT
                                   , L_TOTAL_DEAL_STT_AMOUNT
                                   , L_BUY_UNASSET_AMOUNT
                                   , L_SALE_UNASSET_AMOUNT
                                   , EN_TURN_INVEST_NEW
                                   , EN_UNTRANSFERED_INVEST_NEW
                                   , EN_ACCUMULATE_PROFIT_NEW
                                   , EN_TURN_PROFIT_NEW
                                   , L_RESTRICTED_AMOUNT
                                   , EN_DISCOUNT_RATIO
                                   , L_BEGIN_ENABLE_DEDUCT_AMOUNT
                                   , L_T0_ENABLE_DEDUCT_AMOUNT
                                   , L_T1_SALE_AMOUNT
                                   , EN_CURRENT_IMPAWN_AMOUNT
                                   , EN_PRE_IMPAWN_AMOUNT
                                   , EN_IMPAWN_AMOUNT
                                   , EN_PRE_RETURN_AMOUNT
                                   , EN_RETURN_AMOUNT
                                   , L_GOLD_APPLY_AMOUNT
                                   , L_STGPLC_AMOUNT
                                   , L_STGPLC_FROZEN_AMOUNT
                                   , L_STGPLC_TEMP_FROZEN_AMOUNT
                                   , EN_SALE_REAL_COST
                                   , C_BUSINSPEC_PROPERTY
                                   , L_IMPAWN_DEDUCT_AMOUNT
                                   , L_TEMP_IMPAWN_DEDUCT_AMOUNT
                                   , L_PRE_RESOLD_AMOUNT
                                   , L_PRE_REPURCHASED_AMOUNT
                                   , EN_PAY_INTEREST
                                   , EN_TURN_PAY_INTEREST
                                   , EN_BANKHG_INTEREST
                                   , EN_TURN_BANKHG_INTEREST
                                   , L_TBDC_BOND_AMOUNT
                                   , L_ETF_PHY_APPLY_AMOUNT
                                   , L_ETF_PHY_REDEEM_AMOUNT
                                   , L_MULTI_BUY_AMOUNT
                                   , EN_MULTI_BUY_BALANCE
                                   , EN_MULTI_BUY_FEE
                                   , L_MULTI_BUY_RESTRICTED_AMOUNT
                                   , EN_NET_PRICE
                                   , EN_FULL_PRICE
                                   , EN_NET_PRICE2
                                   , C_INTERCONNECTION_FLAG
                                FROM ${o32_src_schema}.THISFUNDSTOCK
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_BEGIN_AMOUNT", "type": "DOUBLE"}, {"name": "L_CURRENT_AMOUNT", "type": "DOUBLE"}, {"name": "L_BUY_AMOUNT", "type": "DOUBLE"}, {"name": "L_SALE_AMOUNT", "type": "DOUBLE"}, {"name": "L_PREBUY_AMOUNT", "type": "DOUBLE"}, {"name": "L_PRESALE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_FEE", "type": "DOUBLE"}, {"name": "EN_SALE_FEE", "type": "DOUBLE"}, {"name": "EN_UNTRANSFERED_INVEST", "type": "DOUBLE"}, {"name": "EN_INTEREST_INVEST", "type": "DOUBLE"}, {"name": "EN_ACCUMULATE_PROFIT", "type": "DOUBLE"}, {"name": "EN_TURN_INVEST", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_INVEST", "type": "DOUBLE"}, {"name": "EN_TURN_PROFIT", "type": "DOUBLE"}, {"name": "L_BUY_UNSETTLE_AMOUNT", "type": "DOUBLE"}, {"name": "L_SALE_UNSETTLE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BUY_UNSETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_UNSETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_CURRENT_COST", "type": "DOUBLE"}, {"name": "EN_TODAY_PROFIT", "type": "DOUBLE"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "EN_TRADE_BALANCE", "type": "DOUBLE"}, {"name": "EN_REAL_BUY_FEE", "type": "DOUBLE"}, {"name": "EN_REAL_SALE_FEE", "type": "DOUBLE"}, {"name": "EN_REAL_COST", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_REAL_COST", "type": "DOUBLE"}, {"name": "EN_NET_GAIN", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_NET_GAIN", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_DIVIDEND", "type": "DOUBLE"}, {"name": "EN_DIVIDEND", "type": "DOUBLE"}, {"name": "EN_TRADING_FEE", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_TRADING_FEE", "type": "DOUBLE"}, {"name": "EN_INTEREST_PROFIT", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_PROFIT", "type": "DOUBLE"}, {"name": "EN_BEGINYEAR_TURN_PROFIT", "type": "DOUBLE"}, {"name": "EN_BEGINYEAR_UNTURN_PROFIT", "type": "DOUBLE"}, {"name": "EN_INTEREST_GAIN", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_GAIN", "type": "DOUBLE"}, {"name": "L_T1_PREBUY_AMOUNT", "type": "DOUBLE"}, {"name": "L_T1_PRESALE_AMOUNT", "type": "DOUBLE"}, {"name": "L_ETF_APPLY_AMOUNT", "type": "DOUBLE"}, {"name": "L_ETF_REDEEM_AMOUNT", "type": "DOUBLE"}, {"name": "L_TODAY_ENTR_STT_AMOUNT", "type": "DOUBLE"}, {"name": "L_TOTAL_ENTR_STT_AMOUNT", "type": "DOUBLE"}, {"name": "L_TODAY_DEAL_STT_AMOUNT", "type": "DOUBLE"}, {"name": "L_TOTAL_DEAL_STT_AMOUNT", "type": "DOUBLE"}, {"name": "L_BUY_UNASSET_AMOUNT", "type": "DOUBLE"}, {"name": "L_SALE_UNASSET_AMOUNT", "type": "DOUBLE"}, {"name": "EN_TURN_INVEST_NEW", "type": "DOUBLE"}, {"name": "EN_UNTRANSFERED_INVEST_NEW", "type": "DOUBLE"}, {"name": "EN_ACCUMULATE_PROFIT_NEW", "type": "DOUBLE"}, {"name": "EN_TURN_PROFIT_NEW", "type": "DOUBLE"}, {"name": "L_RESTRICTED_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DISCOUNT_RATIO", "type": "DOUBLE"}, {"name": "L_BEGIN_ENABLE_DEDUCT_AMOUNT", "type": "DOUBLE"}, {"name": "L_T0_ENABLE_DEDUCT_AMOUNT", "type": "DOUBLE"}, {"name": "L_T1_SALE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_CURRENT_IMPAWN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_PRE_IMPAWN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_IMPAWN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_PRE_RETURN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_RETURN_AMOUNT", "type": "DOUBLE"}, {"name": "L_GOLD_APPLY_AMOUNT", "type": "DOUBLE"}, {"name": "L_STGPLC_AMOUNT", "type": "DOUBLE"}, {"name": "L_STGPLC_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "L_STGPLC_TEMP_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_SALE_REAL_COST", "type": "DOUBLE"}, {"name": "C_BUSINSPEC_PROPERTY", "type": "STRING"}, {"name": "L_IMPAWN_DEDUCT_AMOUNT", "type": "DOUBLE"}, {"name": "L_TEMP_IMPAWN_DEDUCT_AMOUNT", "type": "DOUBLE"}, {"name": "L_PRE_RESOLD_AMOUNT", "type": "DOUBLE"}, {"name": "L_PRE_REPURCHASED_AMOUNT", "type": "DOUBLE"}, {"name": "EN_PAY_INTEREST", "type": "DOUBLE"}, {"name": "EN_TURN_PAY_INTEREST", "type": "DOUBLE"}, {"name": "EN_BANKHG_INTEREST", "type": "DOUBLE"}, {"name": "EN_TURN_BANKHG_INTEREST", "type": "DOUBLE"}, {"name": "L_TBDC_BOND_AMOUNT", "type": "DOUBLE"}, {"name": "L_ETF_PHY_APPLY_AMOUNT", "type": "DOUBLE"}, {"name": "L_ETF_PHY_REDEEM_AMOUNT", "type": "DOUBLE"}, {"name": "L_MULTI_BUY_AMOUNT", "type": "DOUBLE"}, {"name": "EN_MULTI_BUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_MULTI_BUY_FEE", "type": "DOUBLE"}, {"name": "L_MULTI_BUY_RESTRICTED_AMOUNT", "type": "DOUBLE"}, {"name": "EN_NET_PRICE", "type": "DOUBLE"}, {"name": "EN_FULL_PRICE", "type": "DOUBLE"}, {"name": "EN_NET_PRICE2", "type": "DOUBLE"}, {"name": "C_INTERCONNECTION_FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfundstock_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfundstock_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfundstock_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfundstock_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFUNDSTOCK_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFUNDSTOCK_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfundstock_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFUNDSTOCK_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , L_FUND_ID
     , VC_BIND_SEAT
     , VC_STOCKHOLDER_ID
     , C_INVEST_TYPE
     , VC_INTER_CODE
     , L_BEGIN_AMOUNT
     , L_CURRENT_AMOUNT
     , L_BUY_AMOUNT
     , L_SALE_AMOUNT
     , L_PREBUY_AMOUNT
     , L_PRESALE_AMOUNT
     , EN_BUY_BALANCE
     , EN_SALE_BALANCE
     , EN_BUY_FEE
     , EN_SALE_FEE
     , EN_UNTRANSFERED_INVEST
     , EN_INTEREST_INVEST
     , EN_ACCUMULATE_PROFIT
     , EN_TURN_INVEST
     , EN_TURN_INTEREST_INVEST
     , EN_TURN_PROFIT
     , L_BUY_UNSETTLE_AMOUNT
     , L_SALE_UNSETTLE_AMOUNT
     , EN_BUY_UNSETTLE_BALANCE
     , EN_SALE_UNSETTLE_BALANCE
     , EN_CURRENT_COST
     , EN_TODAY_PROFIT
     , C_POSITION_FLAG
     , EN_TRADE_BALANCE
     , EN_REAL_BUY_FEE
     , EN_REAL_SALE_FEE
     , EN_REAL_COST
     , EN_UNCARRYOVER_REAL_COST
     , EN_NET_GAIN
     , EN_UNCARRYOVER_NET_GAIN
     , EN_UNCARRYOVER_DIVIDEND
     , EN_DIVIDEND
     , EN_TRADING_FEE
     , EN_UNCARRYOVER_TRADING_FEE
     , EN_INTEREST_PROFIT
     , EN_TURN_INTEREST_PROFIT
     , EN_BEGINYEAR_TURN_PROFIT
     , EN_BEGINYEAR_UNTURN_PROFIT
     , EN_INTEREST_GAIN
     , EN_TURN_INTEREST_GAIN
     , L_T1_PREBUY_AMOUNT
     , L_T1_PRESALE_AMOUNT
     , L_ETF_APPLY_AMOUNT
     , L_ETF_REDEEM_AMOUNT
     , L_TODAY_ENTR_STT_AMOUNT
     , L_TOTAL_ENTR_STT_AMOUNT
     , L_TODAY_DEAL_STT_AMOUNT
     , L_TOTAL_DEAL_STT_AMOUNT
     , L_BUY_UNASSET_AMOUNT
     , L_SALE_UNASSET_AMOUNT
     , EN_TURN_INVEST_NEW
     , EN_UNTRANSFERED_INVEST_NEW
     , EN_ACCUMULATE_PROFIT_NEW
     , EN_TURN_PROFIT_NEW
     , L_RESTRICTED_AMOUNT
     , EN_DISCOUNT_RATIO
     , L_BEGIN_ENABLE_DEDUCT_AMOUNT
     , L_T0_ENABLE_DEDUCT_AMOUNT
     , L_T1_SALE_AMOUNT
     , EN_CURRENT_IMPAWN_AMOUNT
     , EN_PRE_IMPAWN_AMOUNT
     , EN_IMPAWN_AMOUNT
     , EN_PRE_RETURN_AMOUNT
     , EN_RETURN_AMOUNT
     , L_GOLD_APPLY_AMOUNT
     , L_STGPLC_AMOUNT
     , L_STGPLC_FROZEN_AMOUNT
     , L_STGPLC_TEMP_FROZEN_AMOUNT
     , EN_SALE_REAL_COST
     , C_BUSINSPEC_PROPERTY
     , L_IMPAWN_DEDUCT_AMOUNT
     , L_TEMP_IMPAWN_DEDUCT_AMOUNT
     , L_PRE_RESOLD_AMOUNT
     , L_PRE_REPURCHASED_AMOUNT
     , EN_PAY_INTEREST
     , EN_TURN_PAY_INTEREST
     , EN_BANKHG_INTEREST
     , EN_TURN_BANKHG_INTEREST
     , L_TBDC_BOND_AMOUNT
     , L_ETF_PHY_APPLY_AMOUNT
     , L_ETF_PHY_REDEEM_AMOUNT
     , L_MULTI_BUY_AMOUNT
     , EN_MULTI_BUY_BALANCE
     , EN_MULTI_BUY_FEE
     , L_MULTI_BUY_RESTRICTED_AMOUNT
     , EN_NET_PRICE
     , EN_FULL_PRICE
     , EN_NET_PRICE2
     , C_INTERCONNECTION_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TFUNDSTOCK_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDSTOCK_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFUNDSTOCK_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFUNDSTOCK_PFD成功"
      exit 0
   fi
fi
