#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESQUOTE_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESQUOTE_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '报价日期',
  L_TIME  DECIMAL(6,0)  COMMENT  '报价时间',
  VC_MARKET_INDICATOR  STRING  COMMENT  '市场标识',
  VC_CLORDID  STRING  COMMENT  '订单号',
  VC_ORDTYPE  STRING  COMMENT  '价格类型',
  VC_EXECINST  STRING  COMMENT  '数量类型',
  VC_TRANSTIME  STRING  COMMENT  '更新日',
  VC_ID  STRING  COMMENT  '报价编号',
  VC_QUOTETYPE  STRING  COMMENT  '报价类型',
  C_IOITRTYPE  STRING  COMMENT  '双向报价会话类型',
  C_QSTATUS  STRING  COMMENT  '报价状态',
  C_TRADETYPE  STRING  COMMENT  '成交类别',
  L_IOI_QTY  DECIMAL(10,0)  COMMENT  '报价数量',
  EN_TRADE_CASH_AMT  DECIMAL(16,2)  COMMENT  '交易金额',
  EN_PRICE  DECIMAL(16,8)  COMMENT  '价格',
  EN_FULL_PRICE  DECIMAL(16,8)  COMMENT  '全价',
  VC_REPORT_CODE  STRING  COMMENT  '证券代码',
  C_SIDE  STRING  COMMENT  '交易方向',
  VC_NAME  STRING  COMMENT  '证券名称',
  VC_CAPTION  STRING  COMMENT  '备注',
  VC_VALID_TIME  STRING  COMMENT  '报价有效时间',
  L_SETTLE_TYPE  DECIMAL(10,0)  COMMENT  '清算速度',
  L_CASH_HOLD_DAYS  DECIMAL(10,0)  COMMENT  '占款天数',
  C_SPLIT_INDICATOR  STRING  COMMENT  '分拆标识',
  L_INT_FIX_DATE  DECIMAL(8,0)  COMMENT  '利率确定日',
  C_MARGIN_REQUIRED  STRING  COMMENT  '有无保证品',
  L_NEG_COUNT  DECIMAL(10,0)  COMMENT  '交谈历史轮次',
  C_INI_EX_REQ  STRING  COMMENT  '初始互换标识',
  C_QTY_RESET  STRING  COMMENT  '本金重置标识',
  VC_TIMEINFORCE  STRING  COMMENT  '时间类型',
  L_STUB  STRING  COMMENT  '前端残段标识',
  L_CALC_AGENCY  DECIMAL(10,0)  COMMENT  '计算代理方',
  L_LAST_QTY  DECIMAL(10,0)  COMMENT  '已成交券面总额',
  EN_END_YLD  DECIMAL(16,8)  COMMENT  '到期收益率',
  EN_LIMIT_YLD  DECIMAL(14,8)  COMMENT  '限价收益率',
  EN_MIN_QTY  DECIMAL(16,2)  COMMENT  '最小成交券面总额',
  EN_MAX_FLOOR  DECIMAL(16,2)  COMMENT  '最大显示券面总额',
  EN_MAX_QTY  DECIMAL(16,2)  COMMENT  '最大成交券面总额',
  EN_MIN_TICK_SIZE  DECIMAL(16,2)  COMMENT  '最小变动单位',
  EN_PRINCIPAL  DECIMAL(16,2)  COMMENT  '每百元本金',
  EN_TOTAL_PRNCP  DECIMAL(16,2)  COMMENT  '当前本金',
  L_TRADE_FWD_DAYS  DECIMAL(10,0)  COMMENT  '远期期限',
  VC_BENCH_NAME  STRING  COMMENT  '参考利率名',
  EN_BENCH_PRICE  DECIMAL(16,8)  COMMENT  '浮动利率',
  VC_DELIVERY_TYPE1  STRING  COMMENT  '首次结算方式',
  C_DELIVERY_TYPE2  STRING  COMMENT  '到期结算方式',
  EN_SETTLAMT  DECIMAL(16,2)  COMMENT  '首次结算金额',
  EN_SETTLAMT2  DECIMAL(16,2)  COMMENT  '到期结算金额',
  L_TRADE_LIMIT_DAYS  DECIMAL(10,0)  COMMENT  '期限',
  EN_ACC_INTREST_AMT  DECIMAL(22,12)  COMMENT  '应计利息',
  EN_TOTAL_INTREST_AMT  DECIMAL(16,2)  COMMENT  '应计利息总和',
  VC_BUY_PARTY_ID  STRING  COMMENT  '买方会员代码',
  VC_BUY_PARTY_NAME  STRING  COMMENT  '买方会员简称',
  VC_BUY_PARTY_FULL_NAME  STRING  COMMENT  '买方会员全称',
  VC_BUY_TRADE_CODE  STRING  COMMENT  '买方交易员代码',
  VC_SELL_PARTY_ID  STRING  COMMENT  '卖方会员代码',
  VC_SELL_PARTY_NAME  STRING  COMMENT  '卖方会员简称',
  VC_SELL_PARTY_FULL_NAME  STRING  COMMENT  '卖方会员全称',
  VC_SELL_TRADE_CODE  STRING  COMMENT  '卖方交易员代码',
  EN_BLEGIOI_QTY  DECIMAL(16,2)  COMMENT  '买方拆入金额',
  EN_BLEG_PRICE  DECIMAL(16,8)  COMMENT  '买方价格',
  EN_BLEGSETTLCURR_AMT  DECIMAL(16,2)  COMMENT  '买方首次结算金额',
  EN_BLEGSETTLCURR_AMT2  DECIMAL(16,2)  COMMENT  '买方到期结算金额',
  EN_BLEGTRADECASH_AMT  DECIMAL(16,2)  COMMENT  '买方交易金额',
  EN_BLEGACCRUEDINT_AMT  DECIMAL(22,12)  COMMENT  '买方应计利息',
  C_BLEGDELIVERY_TYPE  STRING  COMMENT  '买方首次结算方式',
  C_BLEGDELIVERY_TYPE2  STRING  COMMENT  '买方到期结算方式',
  EN_BLEGTOTAL_PRINCIPAL  DECIMAL(16,2)  COMMENT  '买方当前本金额',
  EN_BLEGDIRTY_PRICE  DECIMAL(16,8)  COMMENT  '买方到期全价',
  EN_BLEGORDER_QTY  DECIMAL(16,2)  COMMENT  '买方券面总额',
  EN_BLEGLAST_QTY  DECIMAL(16,2)  COMMENT  '买方成交券面总额',
  EN_BLEGACCRUEDINTOTAL_AMT  DECIMAL(16,2)  COMMENT  '买方应计利息总额',
  EN_BLEG_YIELD  DECIMAL(14,8)  COMMENT  '买方收益率',
  EN_BLEG_TYPE  DECIMAL(10,0)  COMMENT  '买方清算速度',
  EN_BLEG_PRIN  DECIMAL(16,2)  COMMENT  '买方每百元本金额',
  EN_SLEGIOI_QTY  DECIMAL(16,2)  COMMENT  '卖方拆入金额',
  EN_SLEG_PRICE  DECIMAL(16,8)  COMMENT  '卖方价格',
  EN_SLEGSCAMT  DECIMAL(16,2)  COMMENT  '卖方首次结算金额',
  EN_SLEGSETTLCURR_AMT2  DECIMAL(16,2)  COMMENT  '卖方到期结算金额',
  EN_SLEGTRADECASH_AMT  DECIMAL(16,2)  COMMENT  '卖方交易金额',
  EN_SLEGACCRUEDINT_AMT  DECIMAL(22,12)  COMMENT  '卖方应计利息',
  C_SLEGDELIVERYTYPE  STRING  COMMENT  '卖方首次结算方式',
  C_SLEGDELIVERYTYPE2  STRING  COMMENT  '卖方到期结算方式',
  EN_SLEGTOTAL_PRINCIPAL  DECIMAL(16,2)  COMMENT  '卖方当前本金额',
  EN_SLEGDIRTY_PRICE  DECIMAL(16,8)  COMMENT  '卖方到期全价',
  EN_SLEGORDER_QTY  DECIMAL(16,2)  COMMENT  '卖方券面总额',
  EN_SLEGLAST_QTY  DECIMAL(16,2)  COMMENT  '卖方成交券面总额',
  EN_SLEGAIT_AMT  DECIMAL(16,2)  COMMENT  '卖方应计利息总额',
  EN_SLEG_YIELD  DECIMAL(14,8)  COMMENT  '卖方收益率',
  EN_SLEG_TYPE  DECIMAL(10,0)  COMMENT  '卖方清算速度',
  EN_SLEG_PRIN  DECIMAL(16,2)  COMMENT  '卖方每百元本金额',
  EN_STRIKE_YLD  DECIMAL(14,8)  COMMENT  '行权收益率',
  EN_BLEGSTK_YLD  DECIMAL(14,8)  COMMENT  '买方行权收益率',
  EN_SLEGSTK_YLD  DECIMAL(14,8)  COMMENT  '卖方行权收益率',
  EN_MISCFEE_AMT  DECIMAL(16,2)  COMMENT  '借贷费用',
  C_ANONYMOUS_INDICATOR  STRING  COMMENT  '匿名标识',
  L_START_DATE  DECIMAL(8,0)  COMMENT  '起息日',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日',
  L_FIRST_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '首次结算日',
  L_END_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '到期结算日',
  C_CONTINGENCY_INDICATOR  STRING  COMMENT  '应急标识',
  VC_BUY_TRADER_NAME  STRING  COMMENT  '买方交易员名称',
  VC_SELL_TRADER_NAME  STRING  COMMENT  '卖方交易员名称'
)
COMMENT '银行间交易关联机构报价表'
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
                                   , VC_CLORDID
                                   , VC_ORDTYPE
                                   , VC_EXECINST
                                   , VC_TRANSTIME
                                   , VC_ID
                                   , VC_QUOTETYPE
                                   , C_IOITRTYPE
                                   , C_QSTATUS
                                   , C_TRADETYPE
                                   , L_IOI_QTY
                                   , EN_TRADE_CASH_AMT
                                   , EN_PRICE
                                   , EN_FULL_PRICE
                                   , VC_REPORT_CODE
                                   , C_SIDE
                                   , VC_NAME
                                   , VC_CAPTION
                                   , VC_VALID_TIME
                                   , L_SETTLE_TYPE
                                   , L_CASH_HOLD_DAYS
                                   , C_SPLIT_INDICATOR
                                   , L_INT_FIX_DATE
                                   , C_MARGIN_REQUIRED
                                   , L_NEG_COUNT
                                   , C_INI_EX_REQ
                                   , C_QTY_RESET
                                   , VC_TIMEINFORCE
                                   , L_STUB
                                   , L_CALC_AGENCY
                                   , L_LAST_QTY
                                   , EN_END_YLD
                                   , EN_LIMIT_YLD
                                   , EN_MIN_QTY
                                   , EN_MAX_FLOOR
                                   , EN_MAX_QTY
                                   , EN_MIN_TICK_SIZE
                                   , EN_PRINCIPAL
                                   , EN_TOTAL_PRNCP
                                   , L_TRADE_FWD_DAYS
                                   , VC_BENCH_NAME
                                   , EN_BENCH_PRICE
                                   , VC_DELIVERY_TYPE1
                                   , C_DELIVERY_TYPE2
                                   , EN_SETTLAMT
                                   , EN_SETTLAMT2
                                   , L_TRADE_LIMIT_DAYS
                                   , EN_ACC_INTREST_AMT
                                   , EN_TOTAL_INTREST_AMT
                                   , VC_BUY_PARTY_ID
                                   , VC_BUY_PARTY_NAME
                                   , VC_BUY_PARTY_FULL_NAME
                                   , VC_BUY_TRADE_CODE
                                   , VC_SELL_PARTY_ID
                                   , VC_SELL_PARTY_NAME
                                   , VC_SELL_PARTY_FULL_NAME
                                   , VC_SELL_TRADE_CODE
                                   , EN_BLEGIOI_QTY
                                   , EN_BLEG_PRICE
                                   , EN_BLEGSETTLCURR_AMT
                                   , EN_BLEGSETTLCURR_AMT2
                                   , EN_BLEGTRADECASH_AMT
                                   , EN_BLEGACCRUEDINT_AMT
                                   , C_BLEGDELIVERY_TYPE
                                   , C_BLEGDELIVERY_TYPE2
                                   , EN_BLEGTOTAL_PRINCIPAL
                                   , EN_BLEGDIRTY_PRICE
                                   , EN_BLEGORDER_QTY
                                   , EN_BLEGLAST_QTY
                                   , EN_BLEGACCRUEDINTOTAL_AMT
                                   , EN_BLEG_YIELD
                                   , EN_BLEG_TYPE
                                   , EN_BLEG_PRIN
                                   , EN_SLEGIOI_QTY
                                   , EN_SLEG_PRICE
                                   , EN_SLEGSCAMT
                                   , EN_SLEGSETTLCURR_AMT2
                                   , EN_SLEGTRADECASH_AMT
                                   , EN_SLEGACCRUEDINT_AMT
                                   , C_SLEGDELIVERYTYPE
                                   , C_SLEGDELIVERYTYPE2
                                   , EN_SLEGTOTAL_PRINCIPAL
                                   , EN_SLEGDIRTY_PRICE
                                   , EN_SLEGORDER_QTY
                                   , EN_SLEGLAST_QTY
                                   , EN_SLEGAIT_AMT
                                   , EN_SLEG_YIELD
                                   , EN_SLEG_TYPE
                                   , EN_SLEG_PRIN
                                   , EN_STRIKE_YLD
                                   , EN_BLEGSTK_YLD
                                   , EN_SLEGSTK_YLD
                                   , EN_MISCFEE_AMT
                                   , C_ANONYMOUS_INDICATOR
                                   , L_START_DATE
                                   , L_END_DATE
                                   , L_FIRST_SETTLE_DATE
                                   , L_END_SETTLE_DATE
                                   , C_CONTINGENCY_INDICATOR
                                   , VC_BUY_TRADER_NAME
                                   , VC_SELL_TRADER_NAME
                                FROM ${o32_src_schema}.THISBANKAFFILIATESQUOTE
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "VC_MARKET_INDICATOR", "type": "STRING"}, {"name": "VC_CLORDID", "type": "STRING"}, {"name": "VC_ORDTYPE", "type": "STRING"}, {"name": "VC_EXECINST", "type": "STRING"}, {"name": "VC_TRANSTIME", "type": "STRING"}, {"name": "VC_ID", "type": "STRING"}, {"name": "VC_QUOTETYPE", "type": "STRING"}, {"name": "C_IOITRTYPE", "type": "STRING"}, {"name": "C_QSTATUS", "type": "STRING"}, {"name": "C_TRADETYPE", "type": "STRING"}, {"name": "L_IOI_QTY", "type": "DOUBLE"}, {"name": "EN_TRADE_CASH_AMT", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "EN_FULL_PRICE", "type": "DOUBLE"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "C_SIDE", "type": "STRING"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "VC_CAPTION", "type": "STRING"}, {"name": "VC_VALID_TIME", "type": "STRING"}, {"name": "L_SETTLE_TYPE", "type": "DOUBLE"}, {"name": "L_CASH_HOLD_DAYS", "type": "DOUBLE"}, {"name": "C_SPLIT_INDICATOR", "type": "STRING"}, {"name": "L_INT_FIX_DATE", "type": "DOUBLE"}, {"name": "C_MARGIN_REQUIRED", "type": "STRING"}, {"name": "L_NEG_COUNT", "type": "DOUBLE"}, {"name": "C_INI_EX_REQ", "type": "STRING"}, {"name": "C_QTY_RESET", "type": "STRING"}, {"name": "VC_TIMEINFORCE", "type": "STRING"}, {"name": "L_STUB", "type": "DOUBLE"}, {"name": "L_CALC_AGENCY", "type": "DOUBLE"}, {"name": "L_LAST_QTY", "type": "DOUBLE"}, {"name": "EN_END_YLD", "type": "DOUBLE"}, {"name": "EN_LIMIT_YLD", "type": "DOUBLE"}, {"name": "EN_MIN_QTY", "type": "DOUBLE"}, {"name": "EN_MAX_FLOOR", "type": "DOUBLE"}, {"name": "EN_MAX_QTY", "type": "DOUBLE"}, {"name": "EN_MIN_TICK_SIZE", "type": "DOUBLE"}, {"name": "EN_PRINCIPAL", "type": "DOUBLE"}, {"name": "EN_TOTAL_PRNCP", "type": "DOUBLE"}, {"name": "L_TRADE_FWD_DAYS", "type": "DOUBLE"}, {"name": "VC_BENCH_NAME", "type": "STRING"}, {"name": "EN_BENCH_PRICE", "type": "DOUBLE"}, {"name": "VC_DELIVERY_TYPE1", "type": "STRING"}, {"name": "C_DELIVERY_TYPE2", "type": "STRING"}, {"name": "EN_SETTLAMT", "type": "DOUBLE"}, {"name": "EN_SETTLAMT2", "type": "DOUBLE"}, {"name": "L_TRADE_LIMIT_DAYS", "type": "DOUBLE"}, {"name": "EN_ACC_INTREST_AMT", "type": "DOUBLE"}, {"name": "EN_TOTAL_INTREST_AMT", "type": "DOUBLE"}, {"name": "VC_BUY_PARTY_ID", "type": "STRING"}, {"name": "VC_BUY_PARTY_NAME", "type": "STRING"}, {"name": "VC_BUY_PARTY_FULL_NAME", "type": "STRING"}, {"name": "VC_BUY_TRADE_CODE", "type": "STRING"}, {"name": "VC_SELL_PARTY_ID", "type": "STRING"}, {"name": "VC_SELL_PARTY_NAME", "type": "STRING"}, {"name": "VC_SELL_PARTY_FULL_NAME", "type": "STRING"}, {"name": "VC_SELL_TRADE_CODE", "type": "STRING"}, {"name": "EN_BLEGIOI_QTY", "type": "DOUBLE"}, {"name": "EN_BLEG_PRICE", "type": "DOUBLE"}, {"name": "EN_BLEGSETTLCURR_AMT", "type": "DOUBLE"}, {"name": "EN_BLEGSETTLCURR_AMT2", "type": "DOUBLE"}, {"name": "EN_BLEGTRADECASH_AMT", "type": "DOUBLE"}, {"name": "EN_BLEGACCRUEDINT_AMT", "type": "DOUBLE"}, {"name": "C_BLEGDELIVERY_TYPE", "type": "STRING"}, {"name": "C_BLEGDELIVERY_TYPE2", "type": "STRING"}, {"name": "EN_BLEGTOTAL_PRINCIPAL", "type": "DOUBLE"}, {"name": "EN_BLEGDIRTY_PRICE", "type": "DOUBLE"}, {"name": "EN_BLEGORDER_QTY", "type": "DOUBLE"}, {"name": "EN_BLEGLAST_QTY", "type": "DOUBLE"}, {"name": "EN_BLEGACCRUEDINTOTAL_AMT", "type": "DOUBLE"}, {"name": "EN_BLEG_YIELD", "type": "DOUBLE"}, {"name": "EN_BLEG_TYPE", "type": "DOUBLE"}, {"name": "EN_BLEG_PRIN", "type": "DOUBLE"}, {"name": "EN_SLEGIOI_QTY", "type": "DOUBLE"}, {"name": "EN_SLEG_PRICE", "type": "DOUBLE"}, {"name": "EN_SLEGSCAMT", "type": "DOUBLE"}, {"name": "EN_SLEGSETTLCURR_AMT2", "type": "DOUBLE"}, {"name": "EN_SLEGTRADECASH_AMT", "type": "DOUBLE"}, {"name": "EN_SLEGACCRUEDINT_AMT", "type": "DOUBLE"}, {"name": "C_SLEGDELIVERYTYPE", "type": "STRING"}, {"name": "C_SLEGDELIVERYTYPE2", "type": "STRING"}, {"name": "EN_SLEGTOTAL_PRINCIPAL", "type": "DOUBLE"}, {"name": "EN_SLEGDIRTY_PRICE", "type": "DOUBLE"}, {"name": "EN_SLEGORDER_QTY", "type": "DOUBLE"}, {"name": "EN_SLEGLAST_QTY", "type": "DOUBLE"}, {"name": "EN_SLEGAIT_AMT", "type": "DOUBLE"}, {"name": "EN_SLEG_YIELD", "type": "DOUBLE"}, {"name": "EN_SLEG_TYPE", "type": "DOUBLE"}, {"name": "EN_SLEG_PRIN", "type": "DOUBLE"}, {"name": "EN_STRIKE_YLD", "type": "DOUBLE"}, {"name": "EN_BLEGSTK_YLD", "type": "DOUBLE"}, {"name": "EN_SLEGSTK_YLD", "type": "DOUBLE"}, {"name": "EN_MISCFEE_AMT", "type": "DOUBLE"}, {"name": "C_ANONYMOUS_INDICATOR", "type": "STRING"}, {"name": "L_START_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_FIRST_SETTLE_DATE", "type": "DOUBLE"}, {"name": "L_END_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_CONTINGENCY_INDICATOR", "type": "STRING"}, {"name": "VC_BUY_TRADER_NAME", "type": "STRING"}, {"name": "VC_SELL_TRADER_NAME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbankaffiliatesquote_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbankaffiliatesquote_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbankaffiliatesquote_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbankaffiliatesquote_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBANKAFFILIATESQUOTE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBANKAFFILIATESQUOTE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbankaffiliatesquote_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESQUOTE_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_TIME
     , VC_MARKET_INDICATOR
     , VC_CLORDID
     , VC_ORDTYPE
     , VC_EXECINST
     , VC_TRANSTIME
     , VC_ID
     , VC_QUOTETYPE
     , C_IOITRTYPE
     , C_QSTATUS
     , C_TRADETYPE
     , L_IOI_QTY
     , EN_TRADE_CASH_AMT
     , EN_PRICE
     , EN_FULL_PRICE
     , VC_REPORT_CODE
     , C_SIDE
     , VC_NAME
     , VC_CAPTION
     , VC_VALID_TIME
     , L_SETTLE_TYPE
     , L_CASH_HOLD_DAYS
     , C_SPLIT_INDICATOR
     , L_INT_FIX_DATE
     , C_MARGIN_REQUIRED
     , L_NEG_COUNT
     , C_INI_EX_REQ
     , C_QTY_RESET
     , VC_TIMEINFORCE
     , L_STUB
     , L_CALC_AGENCY
     , L_LAST_QTY
     , EN_END_YLD
     , EN_LIMIT_YLD
     , EN_MIN_QTY
     , EN_MAX_FLOOR
     , EN_MAX_QTY
     , EN_MIN_TICK_SIZE
     , EN_PRINCIPAL
     , EN_TOTAL_PRNCP
     , L_TRADE_FWD_DAYS
     , VC_BENCH_NAME
     , EN_BENCH_PRICE
     , VC_DELIVERY_TYPE1
     , C_DELIVERY_TYPE2
     , EN_SETTLAMT
     , EN_SETTLAMT2
     , L_TRADE_LIMIT_DAYS
     , EN_ACC_INTREST_AMT
     , EN_TOTAL_INTREST_AMT
     , VC_BUY_PARTY_ID
     , VC_BUY_PARTY_NAME
     , VC_BUY_PARTY_FULL_NAME
     , VC_BUY_TRADE_CODE
     , VC_SELL_PARTY_ID
     , VC_SELL_PARTY_NAME
     , VC_SELL_PARTY_FULL_NAME
     , VC_SELL_TRADE_CODE
     , EN_BLEGIOI_QTY
     , EN_BLEG_PRICE
     , EN_BLEGSETTLCURR_AMT
     , EN_BLEGSETTLCURR_AMT2
     , EN_BLEGTRADECASH_AMT
     , EN_BLEGACCRUEDINT_AMT
     , C_BLEGDELIVERY_TYPE
     , C_BLEGDELIVERY_TYPE2
     , EN_BLEGTOTAL_PRINCIPAL
     , EN_BLEGDIRTY_PRICE
     , EN_BLEGORDER_QTY
     , EN_BLEGLAST_QTY
     , EN_BLEGACCRUEDINTOTAL_AMT
     , EN_BLEG_YIELD
     , EN_BLEG_TYPE
     , EN_BLEG_PRIN
     , EN_SLEGIOI_QTY
     , EN_SLEG_PRICE
     , EN_SLEGSCAMT
     , EN_SLEGSETTLCURR_AMT2
     , EN_SLEGTRADECASH_AMT
     , EN_SLEGACCRUEDINT_AMT
     , C_SLEGDELIVERYTYPE
     , C_SLEGDELIVERYTYPE2
     , EN_SLEGTOTAL_PRINCIPAL
     , EN_SLEGDIRTY_PRICE
     , EN_SLEGORDER_QTY
     , EN_SLEGLAST_QTY
     , EN_SLEGAIT_AMT
     , EN_SLEG_YIELD
     , EN_SLEG_TYPE
     , EN_SLEG_PRIN
     , EN_STRIKE_YLD
     , EN_BLEGSTK_YLD
     , EN_SLEGSTK_YLD
     , EN_MISCFEE_AMT
     , C_ANONYMOUS_INDICATOR
     , L_START_DATE
     , L_END_DATE
     , L_FIRST_SETTLE_DATE
     , L_END_SETTLE_DATE
     , C_CONTINGENCY_INDICATOR
     , VC_BUY_TRADER_NAME
     , VC_SELL_TRADER_NAME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESQUOTE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBANKAFFILIATESQUOTE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBANKAFFILIATESQUOTE_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBANKAFFILIATESQUOTE_PTD成功"
      exit 0
   fi
fi
