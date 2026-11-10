#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TPENDSETTLE_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TPENDSETTLE_PTD_TMP(
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '待交割序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合序号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_BIND_SEAT  STRING  COMMENT  '席位代码',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  C_MARKET_NO  STRING  COMMENT  '市场代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_STOCK_DIRECTION  STRING  COMMENT  '证券变化方向',
  C_CASH_DIRECTION  STRING  COMMENT  '资金变化方向',
  L_TRADE_DATE  DECIMAL(8,0)  COMMENT  '交易日',
  L_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '交割日',
  C_CLEAR_SPEED  STRING  COMMENT  '清算速度',
  L_ENTRUST_SERIAL_NO  DECIMAL(12,0)  COMMENT  '委托序号',
  L_SETTLE_AMOUNT  DECIMAL(20,4)  COMMENT  '交割数量',
  EN_SETTLE_BALANCE  DECIMAL(18,2)  COMMENT  '交割金额',
  EN_NET_BALANCE  DECIMAL(18,2)  COMMENT  '净价金额',
  EN_FULL_BALANCE  DECIMAL(18,2)  COMMENT  '全价金额',
  EN_FEE_TOTAL  DECIMAL(16,2)  COMMENT  '总费用',
  EN_FEE_JY  DECIMAL(16,2)  COMMENT  '交易费',
  EN_FEE_YH  DECIMAL(16,2)  COMMENT  '印花税',
  EN_FEE_GH  DECIMAL(16,2)  COMMENT  '过户费',
  EN_FEE_YJ  DECIMAL(16,2)  COMMENT  '佣金费',
  EN_FEE_JS  DECIMAL(16,2)  COMMENT  '经手费',
  EN_FEE_ZG  DECIMAL(16,2)  COMMENT  '证管费',
  EN_FEE_OTHER  DECIMAL(16,2)  COMMENT  '其他费用',
  EN_HG_INTEREST  DECIMAL(16,2)  COMMENT  '回购利息',
  EN_RISK_FUND  DECIMAL(12,2)  COMMENT  '结算风险基金',
  L_ASSET_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '资产处理日期',
  C_ASSET_SETTLE_POINT  STRING  COMMENT  '资产处理时点',
  C_ASSET_SETTLE_FLAG  STRING  COMMENT  '资产处理标志',
  C_DEAL_CASH_FROZEN_TYPE  STRING  COMMENT  '成交时的资金冻结处理',
  C_DEAL_STOCK_FROZEN_TYPE  STRING  COMMENT  '成交时的证券冻结处理',
  C_SETTLE_CASH_FROZEN_TYPE  STRING  COMMENT  '资产处理时的资金冻结处理',
  C_SETTLE_STOCK_FROZEN_TYPE  STRING  COMMENT  '资产处理时的证券冻结处理',
  L_CASH_ENABLE_CHANGE_DATE  DECIMAL(8,0)  COMMENT  '资金可用日期',
  L_STOCK_ENABLE_CHANGE_DATE  DECIMAL(8,0)  COMMENT  '证券可用日期',
  C_ENABLE_CHANGE_POINT  STRING  COMMENT  '增加部分的可用变化时点',
  C_STOCK_ENABLE_CHANGE_FLAG  STRING  COMMENT  '证券可用处理标志',
  C_CASH_ENABLE_CHANGE_FLAG  STRING  COMMENT  '资金可用处理标志',
  C_STATUS  STRING  COMMENT  '状态',
  VC_ORIGINAL_NO  STRING  COMMENT  '原业务编号',
  L_RELATE_NO  DECIMAL(10,0)  COMMENT  '关联待交割序号',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  EN_PRICE  DECIMAL(20,12)  COMMENT  '价格',
  EN_FEE_JS2  DECIMAL(12,2)  COMMENT  '结算费',
  EN_FEE_JG  DECIMAL(12,2)  COMMENT  '交割费',
  C_STOCKSETTLE_FLAG  STRING  COMMENT  '证券交收处理标志',
  C_CASHSETTLE_FLAG  STRING  COMMENT  '资金交收处理标志',
  C_BUSIN_PRO_TYPE  STRING  COMMENT  '业务过程分类',
  L_BUSIN_FLAG  DECIMAL(10,0)  COMMENT  '业务类别',
  C_SETTLE_TYPE  STRING  COMMENT  '结算方式',
  C_BUSIN_CLASS  STRING  COMMENT  '业务分类',
  L_PAPER_NO  STRING  COMMENT  '划款指令单编号',
  L_TRADE_RIVAL_NO  DECIMAL(10,0)  COMMENT  '交易对手',
  L_SETTLE_FROZEN_DATE  DECIMAL(8,0)  COMMENT  '交收后冻结到的日期',
  VC_REMARK  STRING  COMMENT  '备注',
  C_CASH_STATUS  STRING  COMMENT  '资金划拨指令状态',
  C_GX_CASH_LINKED_STATUS  STRING  COMMENT  '资金联动状态',
  L_CTRCT_DATE  DECIMAL(8,0)  COMMENT  '合同日期',
  L_HTSERIAL_NO  DECIMAL(10,0)  COMMENT  '合同序号',
  C_TRUSTEE  STRING  COMMENT  '托管机构',
  VC_CONFIRM_NO  STRING  COMMENT  '确认编号',
  C_ZZD_INSTR_STATUS  STRING  COMMENT  '中债登结算指令状态',
  C_ZZD_CONTRACT_STATUS  STRING  COMMENT  '中债登结算合同状态',
  L_INSTANCE_ID  DECIMAL(12,0)  COMMENT  '实例id',
  EN_FEE_JY_TRUE  DECIMAL(19,2)  COMMENT  '实际交易费',
  EN_FEE_YJ_TRUE  DECIMAL(19,2)  COMMENT  '实际佣金',
  EN_FEE_GH_TOTAL  DECIMAL(19,2)  COMMENT  '全额过户费',
  C_SQS_INSTR_STATUS  STRING  COMMENT  '上清所结算指令状态',
  C_SQS_CONTRACT_STATUS  STRING  COMMENT  '上清所结算合同状态',
  L_QS_PENDSETTLE_SERIAL_NO  DECIMAL(8,0)  COMMENT  'o4待交割序号',
  VC_EXPORT_FLAG  STRING  COMMENT  '导出标志',
  C_EXTERDEAL_FLAG  STRING  COMMENT  '外部执行确认状态',
  C_CHANNEL_NO  STRING  COMMENT  '通道号',
  L_CASH_DATETIME  DECIMAL(14,0)  COMMENT  '兑付日期',
  C_PRODUCE_MARK  STRING  COMMENT  '数据来源标志',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  C_CLEAR_TYPE  STRING  COMMENT  '清算类型',
  L_INSTR_DATE  DECIMAL(8,0)  COMMENT  '结算指令日期',
  VC_TRADEID  STRING  COMMENT  '',
  D_CREATE_TIME  STRING  COMMENT  '生成时间',
  VC_UNIQUE_DEAL_SERIAL_NO  STRING  COMMENT  '对接外部系统唯一成交标识',
  L_FROZEN_BALANCE_DATE  DECIMAL(8,0)  COMMENT  '',
  C_HGOCCUPYDAYS_FLAG  STRING  COMMENT  '',
  C_SETTLE_FLAG  STRING  COMMENT  '交收失败标识',
  C_TREATYHG_FLAG  STRING  COMMENT  '协议回购标志',
  L_HG_BATCH_NO  DECIMAL(10,0)  COMMENT  '协议回购批号',
  L_BONDLENDING_AMOUNT  DECIMAL(20,4)  COMMENT  '银行间债券卖空',
  VC_CHANNEL_CODE  STRING  COMMENT  '渠道',
  C_HGCHECK_FLAG  STRING  COMMENT  '',
  EN_INTEREST_PAYMENT_BALANCE  DECIMAL(16,2)  COMMENT  '中途付息金额',
  C_INTEREST_PAYMENT_FLAG  STRING  COMMENT  '',
  C_SETTLE_PROCESS  STRING  COMMENT  '交收方式',
  C_SECRSETTLE_PROCESS  STRING  COMMENT  '',
  C_CAHSETTLE_FLAG  STRING  COMMENT  '',
  C_SECRSETTLE_FLAG  STRING  COMMENT  '',
  C_SETTLE_DFAULTD_STATUS  STRING  COMMENT  '',
  L_SETTLE_DFAULTD_DATE  DECIMAL(8,0)  COMMENT  '',
  L_DEAL_DATE  DECIMAL(8,0)  COMMENT  'ta确认日期',
  EN_ACT_SETTLE_BALANCE  DECIMAL(18,2)  COMMENT  '',
  L_BUYOUT_AMOUNT  DECIMAL(20,4)  COMMENT  '卖出数量',
  C_KTGJG_FLAG  STRING  COMMENT  '',
  L_SETTLE_TIME  DECIMAL(6,0)  COMMENT  '交收时间',
  EN_INTEREST_SUBJECT_BALANCE  DECIMAL(18,2)  COMMENT  '',
  C_CROSS_DAY_COLLECT  STRING  COMMENT  '',
  L_NETTING_DATE  DECIMAL(8,0)  COMMENT  '',
  C_UNFROZEN_STATUS  STRING  COMMENT  '',
  C_KS_LOCK_STATUS  STRING  COMMENT  '',
  C_ALLOW_SETTLE_FLAG  STRING  COMMENT  '',
  C_SPECIAL_TRADE_DATE  STRING  COMMENT  ''
)
COMMENT '待交割表'
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
              "querySql": ["SELECT  L_SERIAL_NO
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_STOCKHOLDER_ID
                                   , VC_BIND_SEAT
                                   , C_INVEST_TYPE
                                   , C_STOCK_TYPE
                                   , C_MARKET_NO
                                   , VC_INTER_CODE
                                   , C_ENTRUST_DIRECTION
                                   , C_STOCK_DIRECTION
                                   , C_CASH_DIRECTION
                                   , L_TRADE_DATE
                                   , L_SETTLE_DATE
                                   , C_CLEAR_SPEED
                                   , L_ENTRUST_SERIAL_NO
                                   , L_SETTLE_AMOUNT
                                   , EN_SETTLE_BALANCE
                                   , EN_NET_BALANCE
                                   , EN_FULL_BALANCE
                                   , EN_FEE_TOTAL
                                   , EN_FEE_JY
                                   , EN_FEE_YH
                                   , EN_FEE_GH
                                   , EN_FEE_YJ
                                   , EN_FEE_JS
                                   , EN_FEE_ZG
                                   , EN_FEE_OTHER
                                   , EN_HG_INTEREST
                                   , EN_RISK_FUND
                                   , L_ASSET_SETTLE_DATE
                                   , C_ASSET_SETTLE_POINT
                                   , C_ASSET_SETTLE_FLAG
                                   , C_DEAL_CASH_FROZEN_TYPE
                                   , C_DEAL_STOCK_FROZEN_TYPE
                                   , C_SETTLE_CASH_FROZEN_TYPE
                                   , C_SETTLE_STOCK_FROZEN_TYPE
                                   , L_CASH_ENABLE_CHANGE_DATE
                                   , L_STOCK_ENABLE_CHANGE_DATE
                                   , C_ENABLE_CHANGE_POINT
                                   , C_STOCK_ENABLE_CHANGE_FLAG
                                   , C_CASH_ENABLE_CHANGE_FLAG
                                   , C_STATUS
                                   , VC_ORIGINAL_NO
                                   , L_RELATE_NO
                                   , L_DATE
                                   , VC_CURRENCY_NO
                                   , EN_PRICE
                                   , EN_FEE_JS2
                                   , EN_FEE_JG
                                   , C_STOCKSETTLE_FLAG
                                   , C_CASHSETTLE_FLAG
                                   , C_BUSIN_PRO_TYPE
                                   , L_BUSIN_FLAG
                                   , C_SETTLE_TYPE
                                   , C_BUSIN_CLASS
                                   , L_PAPER_NO
                                   , L_TRADE_RIVAL_NO
                                   , L_SETTLE_FROZEN_DATE
                                   , VC_REMARK
                                   , C_CASH_STATUS
                                   , C_GX_CASH_LINKED_STATUS
                                   , L_CTRCT_DATE
                                   , L_HTSERIAL_NO
                                   , C_TRUSTEE
                                   , VC_CONFIRM_NO
                                   , C_ZZD_INSTR_STATUS
                                   , C_ZZD_CONTRACT_STATUS
                                   , L_INSTANCE_ID
                                   , EN_FEE_JY_TRUE
                                   , EN_FEE_YJ_TRUE
                                   , EN_FEE_GH_TOTAL
                                   , C_SQS_INSTR_STATUS
                                   , C_SQS_CONTRACT_STATUS
                                   , L_QS_PENDSETTLE_SERIAL_NO
                                   , VC_EXPORT_FLAG
                                   , C_EXTERDEAL_FLAG
                                   , C_CHANNEL_NO
                                   , L_CASH_DATETIME
                                   , C_PRODUCE_MARK
                                   , VC_DEAL_NO
                                   , C_CLEAR_TYPE
                                   , L_INSTR_DATE
                                   , VC_TRADEID
                                   , D_CREATE_TIME
                                   , VC_UNIQUE_DEAL_SERIAL_NO
                                   , L_FROZEN_BALANCE_DATE
                                   , C_HGOCCUPYDAYS_FLAG
                                   , C_SETTLE_FLAG
                                   , C_TREATYHG_FLAG
                                   , L_HG_BATCH_NO
                                   , L_BONDLENDING_AMOUNT
                                   , VC_CHANNEL_CODE
                                   , C_HGCHECK_FLAG
                                   , EN_INTEREST_PAYMENT_BALANCE
                                   , C_INTEREST_PAYMENT_FLAG
                                   , C_SETTLE_PROCESS
                                   , C_SECRSETTLE_PROCESS
                                   , C_CAHSETTLE_FLAG
                                   , C_SECRSETTLE_FLAG
                                   , C_SETTLE_DFAULTD_STATUS
                                   , L_SETTLE_DFAULTD_DATE
                                   , L_DEAL_DATE
                                   , EN_ACT_SETTLE_BALANCE
                                   , L_BUYOUT_AMOUNT
                                   , C_KTGJG_FLAG
                                   , L_SETTLE_TIME
                                   , EN_INTEREST_SUBJECT_BALANCE
                                   , C_CROSS_DAY_COLLECT
                                   , L_NETTING_DATE
                                   , C_UNFROZEN_STATUS
                                   , C_KS_LOCK_STATUS
                                   , C_ALLOW_SETTLE_FLAG
                                   , C_SPECIAL_TRADE_DATE
                                FROM ${o32_src_schema}.THISPENDSETTLE
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_STOCK_DIRECTION", "type": "STRING"}, {"name": "C_CASH_DIRECTION", "type": "STRING"}, {"name": "L_TRADE_DATE", "type": "DOUBLE"}, {"name": "L_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_CLEAR_SPEED", "type": "STRING"}, {"name": "L_ENTRUST_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_SETTLE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_SETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_NET_BALANCE", "type": "DOUBLE"}, {"name": "EN_FULL_BALANCE", "type": "DOUBLE"}, {"name": "EN_FEE_TOTAL", "type": "DOUBLE"}, {"name": "EN_FEE_JY", "type": "DOUBLE"}, {"name": "EN_FEE_YH", "type": "DOUBLE"}, {"name": "EN_FEE_GH", "type": "DOUBLE"}, {"name": "EN_FEE_YJ", "type": "DOUBLE"}, {"name": "EN_FEE_JS", "type": "DOUBLE"}, {"name": "EN_FEE_ZG", "type": "DOUBLE"}, {"name": "EN_FEE_OTHER", "type": "DOUBLE"}, {"name": "EN_HG_INTEREST", "type": "DOUBLE"}, {"name": "EN_RISK_FUND", "type": "DOUBLE"}, {"name": "L_ASSET_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_ASSET_SETTLE_POINT", "type": "STRING"}, {"name": "C_ASSET_SETTLE_FLAG", "type": "STRING"}, {"name": "C_DEAL_CASH_FROZEN_TYPE", "type": "STRING"}, {"name": "C_DEAL_STOCK_FROZEN_TYPE", "type": "STRING"}, {"name": "C_SETTLE_CASH_FROZEN_TYPE", "type": "STRING"}, {"name": "C_SETTLE_STOCK_FROZEN_TYPE", "type": "STRING"}, {"name": "L_CASH_ENABLE_CHANGE_DATE", "type": "DOUBLE"}, {"name": "L_STOCK_ENABLE_CHANGE_DATE", "type": "DOUBLE"}, {"name": "C_ENABLE_CHANGE_POINT", "type": "STRING"}, {"name": "C_STOCK_ENABLE_CHANGE_FLAG", "type": "STRING"}, {"name": "C_CASH_ENABLE_CHANGE_FLAG", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_ORIGINAL_NO", "type": "STRING"}, {"name": "L_RELATE_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "EN_FEE_JS2", "type": "DOUBLE"}, {"name": "EN_FEE_JG", "type": "DOUBLE"}, {"name": "C_STOCKSETTLE_FLAG", "type": "STRING"}, {"name": "C_CASHSETTLE_FLAG", "type": "STRING"}, {"name": "C_BUSIN_PRO_TYPE", "type": "STRING"}, {"name": "L_BUSIN_FLAG", "type": "DOUBLE"}, {"name": "C_SETTLE_TYPE", "type": "STRING"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "L_PAPER_NO", "type": "DOUBLE"}, {"name": "L_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "L_SETTLE_FROZEN_DATE", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_CASH_STATUS", "type": "STRING"}, {"name": "C_GX_CASH_LINKED_STATUS", "type": "STRING"}, {"name": "L_CTRCT_DATE", "type": "DOUBLE"}, {"name": "L_HTSERIAL_NO", "type": "DOUBLE"}, {"name": "C_TRUSTEE", "type": "STRING"}, {"name": "VC_CONFIRM_NO", "type": "STRING"}, {"name": "C_ZZD_INSTR_STATUS", "type": "STRING"}, {"name": "C_ZZD_CONTRACT_STATUS", "type": "STRING"}, {"name": "L_INSTANCE_ID", "type": "DOUBLE"}, {"name": "EN_FEE_JY_TRUE", "type": "DOUBLE"}, {"name": "EN_FEE_YJ_TRUE", "type": "DOUBLE"}, {"name": "EN_FEE_GH_TOTAL", "type": "DOUBLE"}, {"name": "C_SQS_INSTR_STATUS", "type": "STRING"}, {"name": "C_SQS_CONTRACT_STATUS", "type": "STRING"}, {"name": "L_QS_PENDSETTLE_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_EXPORT_FLAG", "type": "STRING"}, {"name": "C_EXTERDEAL_FLAG", "type": "STRING"}, {"name": "C_CHANNEL_NO", "type": "STRING"}, {"name": "L_CASH_DATETIME", "type": "DOUBLE"}, {"name": "C_PRODUCE_MARK", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "C_CLEAR_TYPE", "type": "STRING"}, {"name": "L_INSTR_DATE", "type": "DOUBLE"}, {"name": "VC_TRADEID", "type": "STRING"}, {"name": "D_CREATE_TIME", "type": "STRING"}, {"name": "VC_UNIQUE_DEAL_SERIAL_NO", "type": "STRING"}, {"name": "L_FROZEN_BALANCE_DATE", "type": "DOUBLE"}, {"name": "C_HGOCCUPYDAYS_FLAG", "type": "STRING"}, {"name": "C_SETTLE_FLAG", "type": "STRING"}, {"name": "C_TREATYHG_FLAG", "type": "STRING"}, {"name": "L_HG_BATCH_NO", "type": "DOUBLE"}, {"name": "L_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "VC_CHANNEL_CODE", "type": "STRING"}, {"name": "C_HGCHECK_FLAG", "type": "STRING"}, {"name": "EN_INTEREST_PAYMENT_BALANCE", "type": "DOUBLE"}, {"name": "C_INTEREST_PAYMENT_FLAG", "type": "STRING"}, {"name": "C_SETTLE_PROCESS", "type": "STRING"}, {"name": "C_SECRSETTLE_PROCESS", "type": "STRING"}, {"name": "C_CAHSETTLE_FLAG", "type": "STRING"}, {"name": "C_SECRSETTLE_FLAG", "type": "STRING"}, {"name": "C_SETTLE_DFAULTD_STATUS", "type": "STRING"}, {"name": "L_SETTLE_DFAULTD_DATE", "type": "DOUBLE"}, {"name": "L_DEAL_DATE", "type": "DOUBLE"}, {"name": "EN_ACT_SETTLE_BALANCE", "type": "DOUBLE"}, {"name": "L_BUYOUT_AMOUNT", "type": "DOUBLE"}, {"name": "C_KTGJG_FLAG", "type": "STRING"}, {"name": "L_SETTLE_TIME", "type": "DOUBLE"}, {"name": "EN_INTEREST_SUBJECT_BALANCE", "type": "DOUBLE"}, {"name": "C_CROSS_DAY_COLLECT", "type": "STRING"}, {"name": "L_NETTING_DATE", "type": "DOUBLE"}, {"name": "C_UNFROZEN_STATUS", "type": "STRING"}, {"name": "C_KS_LOCK_STATUS", "type": "STRING"}, {"name": "C_ALLOW_SETTLE_FLAG", "type": "STRING"}, {"name": "C_SPECIAL_TRADE_DATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tpendsettle_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tpendsettle_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tpendsettle_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tpendsettle_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TPENDSETTLE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TPENDSETTLE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tpendsettle_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TPENDSETTLE_PTD PARTITION(P_DT)
SELECT
       L_SERIAL_NO
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_STOCKHOLDER_ID
     , VC_BIND_SEAT
     , C_INVEST_TYPE
     , C_STOCK_TYPE
     , C_MARKET_NO
     , VC_INTER_CODE
     , C_ENTRUST_DIRECTION
     , C_STOCK_DIRECTION
     , C_CASH_DIRECTION
     , L_TRADE_DATE
     , L_SETTLE_DATE
     , C_CLEAR_SPEED
     , L_ENTRUST_SERIAL_NO
     , L_SETTLE_AMOUNT
     , EN_SETTLE_BALANCE
     , EN_NET_BALANCE
     , EN_FULL_BALANCE
     , EN_FEE_TOTAL
     , EN_FEE_JY
     , EN_FEE_YH
     , EN_FEE_GH
     , EN_FEE_YJ
     , EN_FEE_JS
     , EN_FEE_ZG
     , EN_FEE_OTHER
     , EN_HG_INTEREST
     , EN_RISK_FUND
     , L_ASSET_SETTLE_DATE
     , C_ASSET_SETTLE_POINT
     , C_ASSET_SETTLE_FLAG
     , C_DEAL_CASH_FROZEN_TYPE
     , C_DEAL_STOCK_FROZEN_TYPE
     , C_SETTLE_CASH_FROZEN_TYPE
     , C_SETTLE_STOCK_FROZEN_TYPE
     , L_CASH_ENABLE_CHANGE_DATE
     , L_STOCK_ENABLE_CHANGE_DATE
     , C_ENABLE_CHANGE_POINT
     , C_STOCK_ENABLE_CHANGE_FLAG
     , C_CASH_ENABLE_CHANGE_FLAG
     , C_STATUS
     , VC_ORIGINAL_NO
     , L_RELATE_NO
     , L_DATE
     , VC_CURRENCY_NO
     , EN_PRICE
     , EN_FEE_JS2
     , EN_FEE_JG
     , C_STOCKSETTLE_FLAG
     , C_CASHSETTLE_FLAG
     , C_BUSIN_PRO_TYPE
     , L_BUSIN_FLAG
     , C_SETTLE_TYPE
     , C_BUSIN_CLASS
     , L_PAPER_NO
     , L_TRADE_RIVAL_NO
     , L_SETTLE_FROZEN_DATE
     , VC_REMARK
     , C_CASH_STATUS
     , C_GX_CASH_LINKED_STATUS
     , L_CTRCT_DATE
     , L_HTSERIAL_NO
     , C_TRUSTEE
     , VC_CONFIRM_NO
     , C_ZZD_INSTR_STATUS
     , C_ZZD_CONTRACT_STATUS
     , L_INSTANCE_ID
     , EN_FEE_JY_TRUE
     , EN_FEE_YJ_TRUE
     , EN_FEE_GH_TOTAL
     , C_SQS_INSTR_STATUS
     , C_SQS_CONTRACT_STATUS
     , L_QS_PENDSETTLE_SERIAL_NO
     , VC_EXPORT_FLAG
     , C_EXTERDEAL_FLAG
     , C_CHANNEL_NO
     , L_CASH_DATETIME
     , C_PRODUCE_MARK
     , VC_DEAL_NO
     , C_CLEAR_TYPE
     , L_INSTR_DATE
     , VC_TRADEID
     , D_CREATE_TIME
     , VC_UNIQUE_DEAL_SERIAL_NO
     , L_FROZEN_BALANCE_DATE
     , C_HGOCCUPYDAYS_FLAG
     , C_SETTLE_FLAG
     , C_TREATYHG_FLAG
     , L_HG_BATCH_NO
     , L_BONDLENDING_AMOUNT
     , VC_CHANNEL_CODE
     , C_HGCHECK_FLAG
     , EN_INTEREST_PAYMENT_BALANCE
     , C_INTEREST_PAYMENT_FLAG
     , C_SETTLE_PROCESS
     , C_SECRSETTLE_PROCESS
     , C_CAHSETTLE_FLAG
     , C_SECRSETTLE_FLAG
     , C_SETTLE_DFAULTD_STATUS
     , L_SETTLE_DFAULTD_DATE
     , L_DEAL_DATE
     , EN_ACT_SETTLE_BALANCE
     , L_BUYOUT_AMOUNT
     , C_KTGJG_FLAG
     , L_SETTLE_TIME
     , EN_INTEREST_SUBJECT_BALANCE
     , C_CROSS_DAY_COLLECT
     , L_NETTING_DATE
     , C_UNFROZEN_STATUS
     , C_KS_LOCK_STATUS
     , C_ALLOW_SETTLE_FLAG
     , C_SPECIAL_TRADE_DATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TPENDSETTLE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TPENDSETTLE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TPENDSETTLE_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TPENDSETTLE_PTD成功"
      exit 0
   fi
fi
