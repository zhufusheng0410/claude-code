#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFUNDASSET_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDASSET_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  EN_BEGIN_CASH  DECIMAL(18,2)  COMMENT  '期初资金余额',
  EN_CURRENT_CASH  DECIMAL(18,2)  COMMENT  '*当前资金余额',
  EN_BASIC_FROZEN_BALANCE  DECIMAL(18,2)  COMMENT  '保证金',
  EN_PREBUY_BALANCE  DECIMAL(18,2)  COMMENT  '当日预买入金额',
  EN_PRESALE_BALANCE  DECIMAL(18,2)  COMMENT  '当日预卖金额',
  EN_BUY_BALANCE  DECIMAL(18,2)  COMMENT  '当日买入金额',
  EN_SALE_BALANCE  DECIMAL(18,2)  COMMENT  '当日卖出金额',
  EN_BUY_UNSETTLE_BALANCE  DECIMAL(18,2)  COMMENT  '买入未交割金额',
  EN_SALE_UNSETTLE_BALANCE  DECIMAL(18,2)  COMMENT  '卖出未交割金额',
  EN_OTHER_EXPENSE  DECIMAL(18,2)  COMMENT  '合计应付金额',
  EN_OTHER_PROFIT  DECIMAL(18,2)  COMMENT  '合计应收金额',
  EN_INTEREST_BALANCE  DECIMAL(18,2)  COMMENT  '计息头寸',
  EN_STOCK_ASSET  DECIMAL(18,2)  COMMENT  '股票资产',
  EN_BOND_ASSET  DECIMAL(18,2)  COMMENT  '债券资产',
  EN_FUND_ASSET  DECIMAL(18,2)  COMMENT  '基金资产',
  EN_WARRANT_ASSET  DECIMAL(18,2)  COMMENT  '*权证资产',
  EN_HG_ASSET  DECIMAL(18,2)  COMMENT  '回购资产',
  EN_OTHER_ASSET  DECIMAL(18,2)  COMMENT  '其他资产',
  EN_ACCUMULATE_PROFIT  DECIMAL(18,2)  COMMENT  '累计实现收益',
  EN_FUTURES_ASSET  DECIMAL(18,2)  COMMENT  '期货盈亏',
  EN_FUTURES_BALANCE  DECIMAL(18,2)  COMMENT  '期货保证金账户余额',
  EN_FUTURES_DEPOSIT  DECIMAL(18,2)  COMMENT  '期货保证金',
  EN_FUTURES_PREPARE  DECIMAL(18,2)  COMMENT  '期货最低准备金',
  EN_FUND_SHARE  DECIMAL(18,2)  COMMENT  '基金总份额',
  EN_FUND_VALUE  DECIMAL(18,2)  COMMENT  '基金净资产',
  EN_NAV  DECIMAL(14,6)  COMMENT  '基金单位净值',
  EN_FUND_VALUE_YESTERDAY  DECIMAL(18,2)  COMMENT  '基金昨日净资产',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  EN_TOTAL_NAV  DECIMAL(8,4)  COMMENT  '累计单位净值',
  EN_NAV_YESTERDAY  DECIMAL(14,6)  COMMENT  '昨日单位净值',
  D_LASTUPDATE  STRING  COMMENT  '刷新时间',
  EN_UNIT_DIVIDENDS  DECIMAL(8,4)  COMMENT  '单位分红',
  EN_TOTAL_UNIT_DIVIDENDS  DECIMAL(8,4)  COMMENT  '累计单位分红',
  EN_7DAYS_YIELD_RATE  DECIMAL(16,8)  COMMENT  '7日年化收益率',
  EN_10K_UNIT_YIELD  DECIMAL(16,8)  COMMENT  '每万份收益',
  EN_DEPOSIT_BALANCE  DECIMAL(18,2)  COMMENT  '存款余额',
  EN_EXCHANGED_IN_QUOTA  DECIMAL(18,2)  COMMENT  '期初净值',
  EN_EXCHANGED_OUT_QUOTA  DECIMAL(18,2)  COMMENT  '已换入外汇',
  EN_TODAY_EXCHANGE_IN_QUOTA  DECIMAL(18,2)  COMMENT  '已换出外汇',
  EN_TODAY_EXCHANGE_OUT_QUOTA  DECIMAL(18,2)  COMMENT  '当日需换入外汇金额',
  EN_NEXT_EXCHANGE_OUT_QUOTA  DECIMAL(18,2)  COMMENT  '当日需换出外汇金额',
  EN_BOND_INTEREST  DECIMAL(18,2)  COMMENT  '下一日需换出外汇金额',
  EN_BEGIN_FUND_VALUE  DECIMAL(18,2)  COMMENT  '债券利息',
  EN_FUND_TOTAL_VALUE  DECIMAL(18,2)  COMMENT  '基金总资产',
  EN_PAYABLE_BOND_ASSET  DECIMAL(18,2)  COMMENT  '应付债券资产',
  VC_DIFF_DESCRIPTION  STRING  COMMENT  '差异说明',
  EN_T1_PREBUY_BALANCE  DECIMAL(16,2)  COMMENT  't+1日预买金额',
  EN_T1_PRESALE_BALANCE  DECIMAL(16,2)  COMMENT  't+1日预卖金额',
  EN_REC_SEC_ASSET  DECIMAL(18,2)  COMMENT  '期权资产',
  EN_PAY_SEC_ASSET  DECIMAL(18,2)  COMMENT  '应付证券资产',
  EN_OPTION_ASSET  DECIMAL(18,2)  COMMENT  '应收证券资产',
  EN_BUY_UNASSET_BALANCE  DECIMAL(18,2)  COMMENT  '买入资产未变化金额',
  EN_SALE_UNASSET_BALANCE  DECIMAL(18,2)  COMMENT  '卖出资产未变化金额',
  EN_ACCUMULATE_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期累计实现收益',
  EN_TURN_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期未结转收益',
  EN_NET_GAIN_GQ  DECIMAL(18,2)  COMMENT  '过期结转后扣费用累计收益',
  EN_UNCARRYOVER_NET_GAIN_GQ  DECIMAL(18,2)  COMMENT  '过期未结转扣费用期初收益',
  EN_INTEREST_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期债券利息收益',
  EN_TURN_INTEREST_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期结转债券利息收益',
  EN_INTEREST_GAIN_GQ  DECIMAL(18,2)  COMMENT  '过期债券利息实现收益',
  EN_TURN_INTEREST_GAIN_GQ  DECIMAL(18,2)  COMMENT  '过期结转债券利息实现收益',
  EN_BEGINYEAR_TURN_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期年初结转收益',
  EN_BEGINYEAR_UNTURN_PROFIT_GQ  DECIMAL(18,2)  COMMENT  '过期年初未结转收益',
  EN_GOLD_ASSET  DECIMAL(18,2)  COMMENT  '黄金资产',
  EN_GOLD_PROFIT  DECIMAL(18,2)  COMMENT  '黄金利润',
  EN_GOLD_DEPOSIT  DECIMAL(18,2)  COMMENT  '黄金存款',
  EN_GOLD_EQUITY  DECIMAL(18,2)  COMMENT  '黄金股本',
  EN_GOLD_SPOT  DECIMAL(18,2)  COMMENT  '黄金现货',
  EN_STOCK_ASSET_GGT  DECIMAL(18,2)  COMMENT  '',
  EN_STOCK_ASSET_NOGGT  DECIMAL(18,2)  COMMENT  '',
  EN_BROKER_BALANCE  DECIMAL(18,2)  COMMENT  '股票金额',
  EN_ENERALHG_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_AVG_FUND_VALUE  DECIMAL(18,2)  COMMENT  '平均基金价值',
  EN_IRS_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_FINADEBT_ASSET  DECIMAL(18,2)  COMMENT  '资产偿还债务',
  EN_FINADEBT_INTEREST  DECIMAL(18,2)  COMMENT  '利息偿还债务',
  EN_IRS_FROZEN_DEPOSIT  DECIMAL(18,2)  COMMENT  '',
  EN_DERIVATIVES_ASSET  DECIMAL(18,2)  COMMENT  '衍生资产',
  EN_PRENETBUY_BALANCE  DECIMAL(18,2)  COMMENT  '预净价金额',
  EN_GURANTEESECFUT_BALANCE  DECIMAL(18,2)  COMMENT  '信用保证金',
  EN_FUND_ASSET_GGT  DECIMAL(18,2)  COMMENT  '',
  EN_FUND_ASSET_NOGGT  DECIMAL(18,2)  COMMENT  '',
  EN_DF_BOND_ASSET_TOTAL  DECIMAL(18,2)  COMMENT  '',
  EN_DF_BOND_ASSET  DECIMAL(18,2)  COMMENT  '',
  EN_DX_BOND_ASSET_TOTAL  DECIMAL(18,2)  COMMENT  '',
  EN_DX_BOND_ASSET  DECIMAL(18,2)  COMMENT  '',
  EN_DEVALUE_VALUE  DECIMAL(18,2)  COMMENT  '',
  EN_PREPAY_BALANCE_DIFF  DECIMAL(18,2)  COMMENT  ''
)
COMMENT '基金资产信息表'
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
                                   , EN_BEGIN_CASH
                                   , EN_CURRENT_CASH
                                   , EN_BASIC_FROZEN_BALANCE
                                   , EN_PREBUY_BALANCE
                                   , EN_PRESALE_BALANCE
                                   , EN_BUY_BALANCE
                                   , EN_SALE_BALANCE
                                   , EN_BUY_UNSETTLE_BALANCE
                                   , EN_SALE_UNSETTLE_BALANCE
                                   , EN_OTHER_EXPENSE
                                   , EN_OTHER_PROFIT
                                   , EN_INTEREST_BALANCE
                                   , EN_STOCK_ASSET
                                   , EN_BOND_ASSET
                                   , EN_FUND_ASSET
                                   , EN_WARRANT_ASSET
                                   , EN_HG_ASSET
                                   , EN_OTHER_ASSET
                                   , EN_ACCUMULATE_PROFIT
                                   , EN_FUTURES_ASSET
                                   , EN_FUTURES_BALANCE
                                   , EN_FUTURES_DEPOSIT
                                   , EN_FUTURES_PREPARE
                                   , EN_FUND_SHARE
                                   , EN_FUND_VALUE
                                   , EN_NAV
                                   , EN_FUND_VALUE_YESTERDAY
                                   , VC_CURRENCY_NO
                                   , EN_TOTAL_NAV
                                   , EN_NAV_YESTERDAY
                                   , D_LASTUPDATE
                                   , EN_UNIT_DIVIDENDS
                                   , EN_TOTAL_UNIT_DIVIDENDS
                                   , EN_7DAYS_YIELD_RATE
                                   , EN_10K_UNIT_YIELD
                                   , EN_DEPOSIT_BALANCE
                                   , EN_EXCHANGED_IN_QUOTA
                                   , EN_EXCHANGED_OUT_QUOTA
                                   , EN_TODAY_EXCHANGE_IN_QUOTA
                                   , EN_TODAY_EXCHANGE_OUT_QUOTA
                                   , EN_NEXT_EXCHANGE_OUT_QUOTA
                                   , EN_BOND_INTEREST
                                   , EN_BEGIN_FUND_VALUE
                                   , EN_FUND_TOTAL_VALUE
                                   , EN_PAYABLE_BOND_ASSET
                                   , VC_DIFF_DESCRIPTION
                                   , EN_T1_PREBUY_BALANCE
                                   , EN_T1_PRESALE_BALANCE
                                   , EN_REC_SEC_ASSET
                                   , EN_PAY_SEC_ASSET
                                   , EN_OPTION_ASSET
                                   , EN_BUY_UNASSET_BALANCE
                                   , EN_SALE_UNASSET_BALANCE
                                   , EN_ACCUMULATE_PROFIT_GQ
                                   , EN_TURN_PROFIT_GQ
                                   , EN_NET_GAIN_GQ
                                   , EN_UNCARRYOVER_NET_GAIN_GQ
                                   , EN_INTEREST_PROFIT_GQ
                                   , EN_TURN_INTEREST_PROFIT_GQ
                                   , EN_INTEREST_GAIN_GQ
                                   , EN_TURN_INTEREST_GAIN_GQ
                                   , EN_BEGINYEAR_TURN_PROFIT_GQ
                                   , EN_BEGINYEAR_UNTURN_PROFIT_GQ
                                   , EN_GOLD_ASSET
                                   , EN_GOLD_PROFIT
                                   , EN_GOLD_DEPOSIT
                                   , EN_GOLD_EQUITY
                                   , EN_GOLD_SPOT
                                   , EN_STOCK_ASSET_GGT
                                   , EN_STOCK_ASSET_NOGGT
                                   , EN_BROKER_BALANCE
                                   , EN_ENERALHG_DEPOSIT
                                   , EN_AVG_FUND_VALUE
                                   , EN_IRS_DEPOSIT
                                   , EN_FINADEBT_ASSET
                                   , EN_FINADEBT_INTEREST
                                   , EN_IRS_FROZEN_DEPOSIT
                                   , EN_DERIVATIVES_ASSET
                                   , EN_PRENETBUY_BALANCE
                                   , EN_GURANTEESECFUT_BALANCE
                                   , EN_FUND_ASSET_GGT
                                   , EN_FUND_ASSET_NOGGT
                                   , EN_DF_BOND_ASSET_TOTAL
                                   , EN_DF_BOND_ASSET
                                   , EN_DX_BOND_ASSET_TOTAL
                                   , EN_DX_BOND_ASSET
                                   , EN_DEVALUE_VALUE
                                   , EN_PREPAY_BALANCE_DIFF
                                FROM ${o32_src_schema}.THISFUNDASSET
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "EN_BEGIN_CASH", "type": "DOUBLE"}, {"name": "EN_CURRENT_CASH", "type": "DOUBLE"}, {"name": "EN_BASIC_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "EN_PREBUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_PRESALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_UNSETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_UNSETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_OTHER_EXPENSE", "type": "DOUBLE"}, {"name": "EN_OTHER_PROFIT", "type": "DOUBLE"}, {"name": "EN_INTEREST_BALANCE", "type": "DOUBLE"}, {"name": "EN_STOCK_ASSET", "type": "DOUBLE"}, {"name": "EN_BOND_ASSET", "type": "DOUBLE"}, {"name": "EN_FUND_ASSET", "type": "DOUBLE"}, {"name": "EN_WARRANT_ASSET", "type": "DOUBLE"}, {"name": "EN_HG_ASSET", "type": "DOUBLE"}, {"name": "EN_OTHER_ASSET", "type": "DOUBLE"}, {"name": "EN_ACCUMULATE_PROFIT", "type": "DOUBLE"}, {"name": "EN_FUTURES_ASSET", "type": "DOUBLE"}, {"name": "EN_FUTURES_BALANCE", "type": "DOUBLE"}, {"name": "EN_FUTURES_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_FUTURES_PREPARE", "type": "DOUBLE"}, {"name": "EN_FUND_SHARE", "type": "DOUBLE"}, {"name": "EN_FUND_VALUE", "type": "DOUBLE"}, {"name": "EN_NAV", "type": "DOUBLE"}, {"name": "EN_FUND_VALUE_YESTERDAY", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "EN_TOTAL_NAV", "type": "DOUBLE"}, {"name": "EN_NAV_YESTERDAY", "type": "DOUBLE"}, {"name": "D_LASTUPDATE", "type": "STRING"}, {"name": "EN_UNIT_DIVIDENDS", "type": "DOUBLE"}, {"name": "EN_TOTAL_UNIT_DIVIDENDS", "type": "DOUBLE"}, {"name": "EN_7DAYS_YIELD_RATE", "type": "DOUBLE"}, {"name": "EN_10K_UNIT_YIELD", "type": "DOUBLE"}, {"name": "EN_DEPOSIT_BALANCE", "type": "DOUBLE"}, {"name": "EN_EXCHANGED_IN_QUOTA", "type": "DOUBLE"}, {"name": "EN_EXCHANGED_OUT_QUOTA", "type": "DOUBLE"}, {"name": "EN_TODAY_EXCHANGE_IN_QUOTA", "type": "DOUBLE"}, {"name": "EN_TODAY_EXCHANGE_OUT_QUOTA", "type": "DOUBLE"}, {"name": "EN_NEXT_EXCHANGE_OUT_QUOTA", "type": "DOUBLE"}, {"name": "EN_BOND_INTEREST", "type": "DOUBLE"}, {"name": "EN_BEGIN_FUND_VALUE", "type": "DOUBLE"}, {"name": "EN_FUND_TOTAL_VALUE", "type": "DOUBLE"}, {"name": "EN_PAYABLE_BOND_ASSET", "type": "DOUBLE"}, {"name": "VC_DIFF_DESCRIPTION", "type": "STRING"}, {"name": "EN_T1_PREBUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_T1_PRESALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_REC_SEC_ASSET", "type": "DOUBLE"}, {"name": "EN_PAY_SEC_ASSET", "type": "DOUBLE"}, {"name": "EN_OPTION_ASSET", "type": "DOUBLE"}, {"name": "EN_BUY_UNASSET_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_UNASSET_BALANCE", "type": "DOUBLE"}, {"name": "EN_ACCUMULATE_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_TURN_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_NET_GAIN_GQ", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_NET_GAIN_GQ", "type": "DOUBLE"}, {"name": "EN_INTEREST_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_INTEREST_GAIN_GQ", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_GAIN_GQ", "type": "DOUBLE"}, {"name": "EN_BEGINYEAR_TURN_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_BEGINYEAR_UNTURN_PROFIT_GQ", "type": "DOUBLE"}, {"name": "EN_GOLD_ASSET", "type": "DOUBLE"}, {"name": "EN_GOLD_PROFIT", "type": "DOUBLE"}, {"name": "EN_GOLD_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_GOLD_EQUITY", "type": "DOUBLE"}, {"name": "EN_GOLD_SPOT", "type": "DOUBLE"}, {"name": "EN_STOCK_ASSET_GGT", "type": "DOUBLE"}, {"name": "EN_STOCK_ASSET_NOGGT", "type": "DOUBLE"}, {"name": "EN_BROKER_BALANCE", "type": "DOUBLE"}, {"name": "EN_ENERALHG_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_AVG_FUND_VALUE", "type": "DOUBLE"}, {"name": "EN_IRS_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_FINADEBT_ASSET", "type": "DOUBLE"}, {"name": "EN_FINADEBT_INTEREST", "type": "DOUBLE"}, {"name": "EN_IRS_FROZEN_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_DERIVATIVES_ASSET", "type": "DOUBLE"}, {"name": "EN_PRENETBUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_GURANTEESECFUT_BALANCE", "type": "DOUBLE"}, {"name": "EN_FUND_ASSET_GGT", "type": "DOUBLE"}, {"name": "EN_FUND_ASSET_NOGGT", "type": "DOUBLE"}, {"name": "EN_DF_BOND_ASSET_TOTAL", "type": "DOUBLE"}, {"name": "EN_DF_BOND_ASSET", "type": "DOUBLE"}, {"name": "EN_DX_BOND_ASSET_TOTAL", "type": "DOUBLE"}, {"name": "EN_DX_BOND_ASSET", "type": "DOUBLE"}, {"name": "EN_DEVALUE_VALUE", "type": "DOUBLE"}, {"name": "EN_PREPAY_BALANCE_DIFF", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfundasset_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfundasset_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfundasset_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfundasset_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFUNDASSET_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFUNDASSET_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfundasset_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFUNDASSET_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , L_FUND_ID
     , EN_BEGIN_CASH
     , EN_CURRENT_CASH
     , EN_BASIC_FROZEN_BALANCE
     , EN_PREBUY_BALANCE
     , EN_PRESALE_BALANCE
     , EN_BUY_BALANCE
     , EN_SALE_BALANCE
     , EN_BUY_UNSETTLE_BALANCE
     , EN_SALE_UNSETTLE_BALANCE
     , EN_OTHER_EXPENSE
     , EN_OTHER_PROFIT
     , EN_INTEREST_BALANCE
     , EN_STOCK_ASSET
     , EN_BOND_ASSET
     , EN_FUND_ASSET
     , EN_WARRANT_ASSET
     , EN_HG_ASSET
     , EN_OTHER_ASSET
     , EN_ACCUMULATE_PROFIT
     , EN_FUTURES_ASSET
     , EN_FUTURES_BALANCE
     , EN_FUTURES_DEPOSIT
     , EN_FUTURES_PREPARE
     , EN_FUND_SHARE
     , EN_FUND_VALUE
     , EN_NAV
     , EN_FUND_VALUE_YESTERDAY
     , VC_CURRENCY_NO
     , EN_TOTAL_NAV
     , EN_NAV_YESTERDAY
     , D_LASTUPDATE
     , EN_UNIT_DIVIDENDS
     , EN_TOTAL_UNIT_DIVIDENDS
     , EN_7DAYS_YIELD_RATE
     , EN_10K_UNIT_YIELD
     , EN_DEPOSIT_BALANCE
     , EN_EXCHANGED_IN_QUOTA
     , EN_EXCHANGED_OUT_QUOTA
     , EN_TODAY_EXCHANGE_IN_QUOTA
     , EN_TODAY_EXCHANGE_OUT_QUOTA
     , EN_NEXT_EXCHANGE_OUT_QUOTA
     , EN_BOND_INTEREST
     , EN_BEGIN_FUND_VALUE
     , EN_FUND_TOTAL_VALUE
     , EN_PAYABLE_BOND_ASSET
     , VC_DIFF_DESCRIPTION
     , EN_T1_PREBUY_BALANCE
     , EN_T1_PRESALE_BALANCE
     , EN_REC_SEC_ASSET
     , EN_PAY_SEC_ASSET
     , EN_OPTION_ASSET
     , EN_BUY_UNASSET_BALANCE
     , EN_SALE_UNASSET_BALANCE
     , EN_ACCUMULATE_PROFIT_GQ
     , EN_TURN_PROFIT_GQ
     , EN_NET_GAIN_GQ
     , EN_UNCARRYOVER_NET_GAIN_GQ
     , EN_INTEREST_PROFIT_GQ
     , EN_TURN_INTEREST_PROFIT_GQ
     , EN_INTEREST_GAIN_GQ
     , EN_TURN_INTEREST_GAIN_GQ
     , EN_BEGINYEAR_TURN_PROFIT_GQ
     , EN_BEGINYEAR_UNTURN_PROFIT_GQ
     , EN_GOLD_ASSET
     , EN_GOLD_PROFIT
     , EN_GOLD_DEPOSIT
     , EN_GOLD_EQUITY
     , EN_GOLD_SPOT
     , EN_STOCK_ASSET_GGT
     , EN_STOCK_ASSET_NOGGT
     , EN_BROKER_BALANCE
     , EN_ENERALHG_DEPOSIT
     , EN_AVG_FUND_VALUE
     , EN_IRS_DEPOSIT
     , EN_FINADEBT_ASSET
     , EN_FINADEBT_INTEREST
     , EN_IRS_FROZEN_DEPOSIT
     , EN_DERIVATIVES_ASSET
     , EN_PRENETBUY_BALANCE
     , EN_GURANTEESECFUT_BALANCE
     , EN_FUND_ASSET_GGT
     , EN_FUND_ASSET_NOGGT
     , EN_DF_BOND_ASSET_TOTAL
     , EN_DF_BOND_ASSET
     , EN_DX_BOND_ASSET_TOTAL
     , EN_DX_BOND_ASSET
     , EN_DEVALUE_VALUE
     , EN_PREPAY_BALANCE_DIFF
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TFUNDASSET_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDASSET_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFUNDASSET_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFUNDASSET_PFD成功"
      exit 0
   fi
fi
