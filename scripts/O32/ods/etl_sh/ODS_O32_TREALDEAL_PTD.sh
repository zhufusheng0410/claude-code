#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TREALDEAL_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TREALDEAL_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '成交日期',
  L_REALDEAL_SERIAL_NO  DECIMAL(10,0)  COMMENT  '成交序号',
  L_ENTRUST_SERIAL_NO  DECIMAL(10,0)  COMMENT  '委托序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_REPORT_SEAT  STRING  COMMENT  '申报席位',
  VC_REPORT_CODE  STRING  COMMENT  '申报代码',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  L_BUSINESS_TIME  DECIMAL(6,0)  COMMENT  '交易所实际成交时间，成交回报返回',
  L_DEAL_AMOUNT  DECIMAL(16,0)  COMMENT  '成交数量',
  EN_DEAL_PRICE  DECIMAL(16,8)  COMMENT  '成交价格',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改序号',
  L_REPORT_SERIAL_NO  STRING  COMMENT  '申报编号',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '投资组合序号',
  L_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '交割日期',
  C_CLOSE_TYPE  STRING  COMMENT  '平仓类型',
  EN_FEE_JY  DECIMAL(12,2)  COMMENT  '交易费',
  EN_FEE_YH  DECIMAL(12,2)  COMMENT  '印花税',
  EN_FEE_GH  DECIMAL(12,2)  COMMENT  '过户费',
  EN_FEE_YJ  DECIMAL(12,2)  COMMENT  '佣金',
  EN_FEE_JS  DECIMAL(12,2)  COMMENT  '经手费',
  EN_FEE_ZG  DECIMAL(12,2)  COMMENT  '证管费',
  EN_FEE_QT  DECIMAL(12,2)  COMMENT  '其他费用',
  EN_FEE_JS2  DECIMAL(12,2)  COMMENT  '结算费',
  EN_FEE_JG  DECIMAL(12,2)  COMMENT  '交割费',
  D_DATETIME  STRING  COMMENT  '时间戳',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  L_MARKET_DATE  DECIMAL(8,0)  COMMENT  '市场成交日期',
  C_CANCEL_TIME  DECIMAL(6,0)  COMMENT  '撤销时间',
  C_SOURCE  STRING  COMMENT  '数据来源',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '操作员',
  C_MATCH_FLAG  STRING  COMMENT  '配对标志',
  C_VALID  STRING  COMMENT  '有效状态',
  VC_BROKER_NO  STRING  COMMENT  '券商编号',
  C_BUSIN_CLASS  STRING  COMMENT  '业务分类',
  L_REALDEAL_CANCEL_NO  DECIMAL(10,0)  COMMENT  '成交交撤销序号',
  C_EXTERNAL_DEAL_FLAG  STRING  COMMENT  '外部处理标志',
  C_FIXSEND_FLAG  STRING  COMMENT  'fix发送标志',
  C_TRADE_OPTION  STRING  COMMENT  '是否备兑',
  EN_FEE_JY_TRUE  DECIMAL(19,2)  COMMENT  '实际交易费',
  EN_FEE_YJ_TRUE  DECIMAL(19,2)  COMMENT  '实际佣金',
  EN_FEE_GH_TOTAL  DECIMAL(19,2)  COMMENT  '全额过户费',
  EN_BALANCE  DECIMAL(18,2)  COMMENT  '金额',
  C_MARGINED_OUT  STRING  COMMENT  '是否强平',
  L_TRADE_RIVAL_NO  DECIMAL(10,0)  COMMENT  '交易对手',
  L_HG_DAYS  DECIMAL(10,0)  COMMENT  '回购天数',
  L_ORIGIN_OPEN_DATE  DECIMAL(8,0)  COMMENT  '原开仓日期',
  VC_ORIGIN_DEAL_NO  STRING  COMMENT  '原成交编号',
  C_SPECIAL_FLAG  STRING  COMMENT  '特殊业务标识',
  VC_CONTRACT_NO  STRING  COMMENT  '合同编号',
  C_HGXZ  STRING  COMMENT  '回购续做标记',
  VC_RIVALTRADER_ID  STRING  COMMENT  '对手交易员',
  EN_FUT_CLOSE_PROFIT  DECIMAL(16,2)  COMMENT  '平仓盈亏',
  VC_SUMMARY  STRING  COMMENT  '备注',
  L_NATURAL_DAY  DECIMAL(8,0)  COMMENT  '自然日',
  C_SETTLE_FLAG  STRING  COMMENT  '清算标志',
  C_TREATYHG_FLAG  STRING  COMMENT  '协议回购标志',
  L_HG_BATCH_NO  DECIMAL(10,0)  COMMENT  '协议回购批号',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_MORTAGAGE_SIDE  STRING  COMMENT  'c_mortagage_side',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志'
)
COMMENT '实时成交流水表'
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
                                   , L_REALDEAL_SERIAL_NO
                                   , L_ENTRUST_SERIAL_NO
                                   , L_FUND_ID
                                   , C_MARKET_NO
                                   , VC_STOCKHOLDER_ID
                                   , VC_REPORT_SEAT
                                   , VC_REPORT_CODE
                                   , C_STOCK_TYPE
                                   , C_ENTRUST_DIRECTION
                                   , L_BUSINESS_TIME
                                   , L_DEAL_AMOUNT
                                   , EN_DEAL_PRICE
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INDEX_DAILY_MODIFY
                                   , L_REPORT_SERIAL_NO
                                   , VC_INTER_CODE
                                   , L_BASECOMBI_ID
                                   , L_SETTLE_DATE
                                   , C_CLOSE_TYPE
                                   , EN_FEE_JY
                                   , EN_FEE_YH
                                   , EN_FEE_GH
                                   , EN_FEE_YJ
                                   , EN_FEE_JS
                                   , EN_FEE_ZG
                                   , EN_FEE_QT
                                   , EN_FEE_JS2
                                   , EN_FEE_JG
                                   , D_DATETIME
                                   , VC_DEAL_NO
                                   , L_MARKET_DATE
                                   , C_CANCEL_TIME
                                   , C_SOURCE
                                   , L_OPERATOR_NO
                                   , C_MATCH_FLAG
                                   , C_VALID
                                   , VC_BROKER_NO
                                   , C_BUSIN_CLASS
                                   , L_REALDEAL_CANCEL_NO
                                   , C_EXTERNAL_DEAL_FLAG
                                   , C_FIXSEND_FLAG
                                   , C_TRADE_OPTION
                                   , EN_FEE_JY_TRUE
                                   , EN_FEE_YJ_TRUE
                                   , EN_FEE_GH_TOTAL
                                   , EN_BALANCE
                                   , C_MARGINED_OUT
                                   , L_TRADE_RIVAL_NO
                                   , L_HG_DAYS
                                   , L_ORIGIN_OPEN_DATE
                                   , VC_ORIGIN_DEAL_NO
                                   , C_SPECIAL_FLAG
                                   , VC_CONTRACT_NO
                                   , C_HGXZ
                                   , VC_RIVALTRADER_ID
                                   , EN_FUT_CLOSE_PROFIT
                                   , VC_SUMMARY
                                   , L_NATURAL_DAY
                                   , C_SETTLE_FLAG
                                   , C_TREATYHG_FLAG
                                   , L_HG_BATCH_NO
                                   , C_INVEST_TYPE
                                   , C_MORTAGAGE_SIDE
                                   , C_DEAL_FLAG
                                FROM ${o32_src_schema}.THISREALDEAL
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_REALDEAL_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_ENTRUST_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_REPORT_SEAT", "type": "STRING"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "L_BUSINESS_TIME", "type": "DOUBLE"}, {"name": "L_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DEAL_PRICE", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_REPORT_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_CLOSE_TYPE", "type": "STRING"}, {"name": "EN_FEE_JY", "type": "DOUBLE"}, {"name": "EN_FEE_YH", "type": "DOUBLE"}, {"name": "EN_FEE_GH", "type": "DOUBLE"}, {"name": "EN_FEE_YJ", "type": "DOUBLE"}, {"name": "EN_FEE_JS", "type": "DOUBLE"}, {"name": "EN_FEE_ZG", "type": "DOUBLE"}, {"name": "EN_FEE_QT", "type": "DOUBLE"}, {"name": "EN_FEE_JS2", "type": "DOUBLE"}, {"name": "EN_FEE_JG", "type": "DOUBLE"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "L_MARKET_DATE", "type": "DOUBLE"}, {"name": "C_CANCEL_TIME", "type": "DOUBLE"}, {"name": "C_SOURCE", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "C_MATCH_FLAG", "type": "STRING"}, {"name": "C_VALID", "type": "STRING"}, {"name": "VC_BROKER_NO", "type": "STRING"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "L_REALDEAL_CANCEL_NO", "type": "DOUBLE"}, {"name": "C_EXTERNAL_DEAL_FLAG", "type": "STRING"}, {"name": "C_FIXSEND_FLAG", "type": "STRING"}, {"name": "C_TRADE_OPTION", "type": "STRING"}, {"name": "EN_FEE_JY_TRUE", "type": "DOUBLE"}, {"name": "EN_FEE_YJ_TRUE", "type": "DOUBLE"}, {"name": "EN_FEE_GH_TOTAL", "type": "DOUBLE"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "C_MARGINED_OUT", "type": "STRING"}, {"name": "L_TRADE_RIVAL_NO", "type": "DOUBLE"}, {"name": "L_HG_DAYS", "type": "DOUBLE"}, {"name": "L_ORIGIN_OPEN_DATE", "type": "DOUBLE"}, {"name": "VC_ORIGIN_DEAL_NO", "type": "STRING"}, {"name": "C_SPECIAL_FLAG", "type": "STRING"}, {"name": "VC_CONTRACT_NO", "type": "STRING"}, {"name": "C_HGXZ", "type": "STRING"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "EN_FUT_CLOSE_PROFIT", "type": "DOUBLE"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "L_NATURAL_DAY", "type": "DOUBLE"}, {"name": "C_SETTLE_FLAG", "type": "STRING"}, {"name": "C_TREATYHG_FLAG", "type": "STRING"}, {"name": "L_HG_BATCH_NO", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_MORTAGAGE_SIDE", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_trealdeal_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_trealdeal_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_trealdeal_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_trealdeal_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TREALDEAL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TREALDEAL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_trealdeal_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TREALDEAL_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_REALDEAL_SERIAL_NO
     , L_ENTRUST_SERIAL_NO
     , L_FUND_ID
     , C_MARKET_NO
     , VC_STOCKHOLDER_ID
     , VC_REPORT_SEAT
     , VC_REPORT_CODE
     , C_STOCK_TYPE
     , C_ENTRUST_DIRECTION
     , L_BUSINESS_TIME
     , L_DEAL_AMOUNT
     , EN_DEAL_PRICE
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , L_REPORT_SERIAL_NO
     , VC_INTER_CODE
     , L_BASECOMBI_ID
     , L_SETTLE_DATE
     , C_CLOSE_TYPE
     , EN_FEE_JY
     , EN_FEE_YH
     , EN_FEE_GH
     , EN_FEE_YJ
     , EN_FEE_JS
     , EN_FEE_ZG
     , EN_FEE_QT
     , EN_FEE_JS2
     , EN_FEE_JG
     , D_DATETIME
     , VC_DEAL_NO
     , L_MARKET_DATE
     , C_CANCEL_TIME
     , C_SOURCE
     , L_OPERATOR_NO
     , C_MATCH_FLAG
     , C_VALID
     , VC_BROKER_NO
     , C_BUSIN_CLASS
     , L_REALDEAL_CANCEL_NO
     , C_EXTERNAL_DEAL_FLAG
     , C_FIXSEND_FLAG
     , C_TRADE_OPTION
     , EN_FEE_JY_TRUE
     , EN_FEE_YJ_TRUE
     , EN_FEE_GH_TOTAL
     , EN_BALANCE
     , C_MARGINED_OUT
     , L_TRADE_RIVAL_NO
     , L_HG_DAYS
     , L_ORIGIN_OPEN_DATE
     , VC_ORIGIN_DEAL_NO
     , C_SPECIAL_FLAG
     , VC_CONTRACT_NO
     , C_HGXZ
     , VC_RIVALTRADER_ID
     , EN_FUT_CLOSE_PROFIT
     , VC_SUMMARY
     , L_NATURAL_DAY
     , C_SETTLE_FLAG
     , C_TREATYHG_FLAG
     , L_HG_BATCH_NO
     , C_INVEST_TYPE
     , C_MORTAGAGE_SIDE
     , C_DEAL_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TREALDEAL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TREALDEAL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TREALDEAL_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TREALDEAL_PTD成功"
      exit 0
   fi
fi
