#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TLIQUIDATEDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TLIQUIDATEDETAIL_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '清算日期',
  L_SERIAL_NO  DECIMAL(12,0)  COMMENT  '清算序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  L_BUSIN_FLAG  STRING  COMMENT  '业务标志',
  L_TIME  DECIMAL(6,0)  COMMENT  '发生时间',
  EN_OCCUR_BALANCE  DECIMAL(18,2)  COMMENT  '资金发生额',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_STOCK_DIRECTION  STRING  COMMENT  '证券方向',
  C_FUND_DIRECTION  STRING  COMMENT  '资金方向',
  VC_REPORT_DIRECTION  STRING  COMMENT  '申报方向',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  L_DEAL_AMOUNT  DECIMAL(18,2)  COMMENT  '成交数量',
  EN_DEAL_PRICE  DECIMAL(16,8)  COMMENT  '成交价格',
  EN_DEAL_BALANCE  DECIMAL(18,2)  COMMENT  '成交金额',
  L_STOCK_AMOUNT  DECIMAL(12,0)  COMMENT  '证券余额',
  L_REPORT_TIME  DECIMAL(6,0)  COMMENT  '申报时间',
  L_DEAL_TIMES  DECIMAL(8,0)  COMMENT  '成交次数',
  L_FBUSINESS_TIME  DECIMAL(6,0)  COMMENT  '首成交时间',
  L_LBUSINESS_TIME  DECIMAL(6,0)  COMMENT  '末成交时间',
  EN_FEE_JY  DECIMAL(12,2)  COMMENT  '交易费',
  EN_FEE_YH  DECIMAL(12,2)  COMMENT  '印花税',
  EN_FEE_GH  DECIMAL(12,2)  COMMENT  '过户费',
  EN_FEE_YJ  DECIMAL(12,2)  COMMENT  '佣金费',
  EN_FEE_JS  DECIMAL(12,2)  COMMENT  '经手费',
  EN_FEE_ZG  DECIMAL(12,2)  COMMENT  '证管费',
  EN_FEE_QT  DECIMAL(12,2)  COMMENT  '其它费',
  EN_HGPROFIT  DECIMAL(12,2)  COMMENT  '回购利息',
  L_OPERATOR_NO  STRING  COMMENT  '交易员代码',
  L_LUCK_BEGING_NO  DECIMAL(12,0)  COMMENT  '配号',
  C_MATCH_STATUS  STRING  COMMENT  '配对状态',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  EN_FEE_JS2  DECIMAL(12,2)  COMMENT  '结算费',
  EN_FEE_JG  DECIMAL(12,2)  COMMENT  '交割费',
  EN_RISK_FUND  DECIMAL(12,2)  COMMENT  '结算风险基金',
  C_CLOSE_TYPE  STRING  COMMENT  '平仓类型',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  C_BUSIN_CLASS  STRING  COMMENT  '＃业务分类',
  VC_ORIGINAL_DEAL_NO  STRING  COMMENT  '原成交编号',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  L_BUSINESS_DATE  DECIMAL(8,0)  COMMENT  '业务日期',
  VC_REPORT_ID  STRING  COMMENT  '申报编号',
  C_LAUNCH_FLAG  STRING  COMMENT  '发起标志',
  L_BATCH_SERIAL_NO  DECIMAL(10,0)  COMMENT  '委托批号',
  L_INSTANCE_ID  DECIMAL(12,0)  COMMENT  '交易实例序号',
  L_SETTLE_SPEED  DECIMAL(4,0)  COMMENT  '清算速度',
  L_RESULT_FLAG  STRING  COMMENT  '结果标志',
  EN_FEE_JY_GGT  DECIMAL(19,2)  COMMENT  '港币交易费',
  EN_FEE_YH_GGT  DECIMAL(19,2)  COMMENT  '港币印花税',
  EN_FEE_GH_GGT  DECIMAL(19,2)  COMMENT  '港币过户费',
  EN_FEE_YJ_GGT  DECIMAL(19,2)  COMMENT  '港币佣金',
  EN_OCCUR_BALANCE_GGT  DECIMAL(19,2)  COMMENT  '港币实际收付',
  EN_DEAL_BALANCE_GGT  DECIMAL(19,2)  COMMENT  '港币成交金额',
  EN_FEE_JY_TRUE  DECIMAL(19,2)  COMMENT  '实际交易费',
  EN_FEE_YJ_TRUE  DECIMAL(19,2)  COMMENT  '实际佣金',
  EN_FEE_GH_TOTAL  DECIMAL(19,2)  COMMENT  '全额过户费',
  EN_FEE_QT_GGT  DECIMAL(19,2)  COMMENT  '港币其他费用',
  EN_FEE_JS2_GGT  DECIMAL(19,2)  COMMENT  '港币结算费',
  EN_FEE_JS_GGT  DECIMAL(19,2)  COMMENT  '港币经手费',
  EN_DEAL_BALANCE1  DECIMAL(18,2)  COMMENT  '交易金额1',
  EN_DEAL_BALANCE2  DECIMAL(18,2)  COMMENT  '交易金额2',
  C_ADDITIONAL_MARK  STRING  COMMENT  '',
  L_UNSECURED_FLAG  DECIMAL(8,0)  COMMENT  '',
  EN_PRICE  DECIMAL(14,8)  COMMENT  '单价',
  L_BONDLENDING_AMOUNT  DECIMAL(20,4)  COMMENT  '银行间债券卖空',
  VC_BY1  STRING  COMMENT  '',
  VC_BY2  STRING  COMMENT  '',
  L_REDEEM_DAYS  DECIMAL(10,0)  COMMENT  '赎回交收天数',
  C_NEED_LIQMATCH  STRING  COMMENT  '',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '',
  L_ENTRUST_SERIAL_NO  DECIMAL(10,0)  COMMENT  '合笔委托序号',
  C_SPECIAL_FLAG  STRING  COMMENT  '特殊业务标识',
  L_ORIGIN_OPEN_DATE  DECIMAL(8,0)  COMMENT  '原开仓日期'
)
COMMENT '清算配对表'
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
                                   , L_SERIAL_NO
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , L_BUSIN_FLAG
                                   , L_TIME
                                   , EN_OCCUR_BALANCE
                                   , C_ENTRUST_DIRECTION
                                   , C_STOCK_DIRECTION
                                   , C_FUND_DIRECTION
                                   , VC_REPORT_DIRECTION
                                   , C_MARKET_NO
                                   , VC_STOCKHOLDER_ID
                                   , VC_SEAT_ID
                                   , VC_INTER_CODE
                                   , C_STOCK_TYPE
                                   , L_DEAL_AMOUNT
                                   , EN_DEAL_PRICE
                                   , EN_DEAL_BALANCE
                                   , L_STOCK_AMOUNT
                                   , L_REPORT_TIME
                                   , L_DEAL_TIMES
                                   , L_FBUSINESS_TIME
                                   , L_LBUSINESS_TIME
                                   , EN_FEE_JY
                                   , EN_FEE_YH
                                   , EN_FEE_GH
                                   , EN_FEE_YJ
                                   , EN_FEE_JS
                                   , EN_FEE_ZG
                                   , EN_FEE_QT
                                   , EN_HGPROFIT
                                   , L_OPERATOR_NO
                                   , L_LUCK_BEGING_NO
                                   , C_MATCH_STATUS
                                   , C_INVEST_TYPE
                                   , EN_FEE_JS2
                                   , EN_FEE_JG
                                   , EN_RISK_FUND
                                   , C_CLOSE_TYPE
                                   , VC_CURRENCY_NO
                                   , C_BUSIN_CLASS
                                   , VC_ORIGINAL_DEAL_NO
                                   , VC_DEAL_NO
                                   , L_BUSINESS_DATE
                                   , VC_REPORT_ID
                                   , C_LAUNCH_FLAG
                                   , L_BATCH_SERIAL_NO
                                   , L_INSTANCE_ID
                                   , L_SETTLE_SPEED
                                   , L_RESULT_FLAG
                                   , EN_FEE_JY_GGT
                                   , EN_FEE_YH_GGT
                                   , EN_FEE_GH_GGT
                                   , EN_FEE_YJ_GGT
                                   , EN_OCCUR_BALANCE_GGT
                                   , EN_DEAL_BALANCE_GGT
                                   , EN_FEE_JY_TRUE
                                   , EN_FEE_YJ_TRUE
                                   , EN_FEE_GH_TOTAL
                                   , EN_FEE_QT_GGT
                                   , EN_FEE_JS2_GGT
                                   , EN_FEE_JS_GGT
                                   , EN_DEAL_BALANCE1
                                   , EN_DEAL_BALANCE2
                                   , C_ADDITIONAL_MARK
                                   , L_UNSECURED_FLAG
                                   , EN_PRICE
                                   , L_BONDLENDING_AMOUNT
                                   , VC_BY1
                                   , VC_BY2
                                   , L_REDEEM_DAYS
                                   , C_NEED_LIQMATCH
                                   , L_INDEX_DAILY_MODIFY
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_ENTRUST_SERIAL_NO
                                   , C_SPECIAL_FLAG
                                   , L_ORIGIN_OPEN_DATE
                                FROM ${o32_src_schema}.THISLIQUIDATEDETAIL
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_BUSIN_FLAG", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "EN_OCCUR_BALANCE", "type": "DOUBLE"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_STOCK_DIRECTION", "type": "STRING"}, {"name": "C_FUND_DIRECTION", "type": "STRING"}, {"name": "VC_REPORT_DIRECTION", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "L_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DEAL_PRICE", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_STOCK_AMOUNT", "type": "DOUBLE"}, {"name": "L_REPORT_TIME", "type": "DOUBLE"}, {"name": "L_DEAL_TIMES", "type": "DOUBLE"}, {"name": "L_FBUSINESS_TIME", "type": "DOUBLE"}, {"name": "L_LBUSINESS_TIME", "type": "DOUBLE"}, {"name": "EN_FEE_JY", "type": "DOUBLE"}, {"name": "EN_FEE_YH", "type": "DOUBLE"}, {"name": "EN_FEE_GH", "type": "DOUBLE"}, {"name": "EN_FEE_YJ", "type": "DOUBLE"}, {"name": "EN_FEE_JS", "type": "DOUBLE"}, {"name": "EN_FEE_ZG", "type": "DOUBLE"}, {"name": "EN_FEE_QT", "type": "DOUBLE"}, {"name": "EN_HGPROFIT", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_LUCK_BEGING_NO", "type": "DOUBLE"}, {"name": "C_MATCH_STATUS", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "EN_FEE_JS2", "type": "DOUBLE"}, {"name": "EN_FEE_JG", "type": "DOUBLE"}, {"name": "EN_RISK_FUND", "type": "DOUBLE"}, {"name": "C_CLOSE_TYPE", "type": "STRING"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "VC_ORIGINAL_DEAL_NO", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "L_BUSINESS_DATE", "type": "DOUBLE"}, {"name": "VC_REPORT_ID", "type": "STRING"}, {"name": "C_LAUNCH_FLAG", "type": "STRING"}, {"name": "L_BATCH_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_INSTANCE_ID", "type": "DOUBLE"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "L_RESULT_FLAG", "type": "DOUBLE"}, {"name": "EN_FEE_JY_GGT", "type": "DOUBLE"}, {"name": "EN_FEE_YH_GGT", "type": "DOUBLE"}, {"name": "EN_FEE_GH_GGT", "type": "DOUBLE"}, {"name": "EN_FEE_YJ_GGT", "type": "DOUBLE"}, {"name": "EN_OCCUR_BALANCE_GGT", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE_GGT", "type": "DOUBLE"}, {"name": "EN_FEE_JY_TRUE", "type": "DOUBLE"}, {"name": "EN_FEE_YJ_TRUE", "type": "DOUBLE"}, {"name": "EN_FEE_GH_TOTAL", "type": "DOUBLE"}, {"name": "EN_FEE_QT_GGT", "type": "DOUBLE"}, {"name": "EN_FEE_JS2_GGT", "type": "DOUBLE"}, {"name": "EN_FEE_JS_GGT", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE1", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE2", "type": "DOUBLE"}, {"name": "C_ADDITIONAL_MARK", "type": "STRING"}, {"name": "L_UNSECURED_FLAG", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "L_BONDLENDING_AMOUNT", "type": "DOUBLE"}, {"name": "VC_BY1", "type": "STRING"}, {"name": "VC_BY2", "type": "STRING"}, {"name": "L_REDEEM_DAYS", "type": "DOUBLE"}, {"name": "C_NEED_LIQMATCH", "type": "STRING"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_ENTRUST_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_SPECIAL_FLAG", "type": "STRING"}, {"name": "L_ORIGIN_OPEN_DATE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tliquidatedetail_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tliquidatedetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tliquidatedetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tliquidatedetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TLIQUIDATEDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TLIQUIDATEDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tliquidatedetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TLIQUIDATEDETAIL_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_SERIAL_NO
     , L_FUND_ID
     , L_BASECOMBI_ID
     , L_BUSIN_FLAG
     , L_TIME
     , EN_OCCUR_BALANCE
     , C_ENTRUST_DIRECTION
     , C_STOCK_DIRECTION
     , C_FUND_DIRECTION
     , VC_REPORT_DIRECTION
     , C_MARKET_NO
     , VC_STOCKHOLDER_ID
     , VC_SEAT_ID
     , VC_INTER_CODE
     , C_STOCK_TYPE
     , L_DEAL_AMOUNT
     , EN_DEAL_PRICE
     , EN_DEAL_BALANCE
     , L_STOCK_AMOUNT
     , L_REPORT_TIME
     , L_DEAL_TIMES
     , L_FBUSINESS_TIME
     , L_LBUSINESS_TIME
     , EN_FEE_JY
     , EN_FEE_YH
     , EN_FEE_GH
     , EN_FEE_YJ
     , EN_FEE_JS
     , EN_FEE_ZG
     , EN_FEE_QT
     , EN_HGPROFIT
     , L_OPERATOR_NO
     , L_LUCK_BEGING_NO
     , C_MATCH_STATUS
     , C_INVEST_TYPE
     , EN_FEE_JS2
     , EN_FEE_JG
     , EN_RISK_FUND
     , C_CLOSE_TYPE
     , VC_CURRENCY_NO
     , C_BUSIN_CLASS
     , VC_ORIGINAL_DEAL_NO
     , VC_DEAL_NO
     , L_BUSINESS_DATE
     , VC_REPORT_ID
     , C_LAUNCH_FLAG
     , L_BATCH_SERIAL_NO
     , L_INSTANCE_ID
     , L_SETTLE_SPEED
     , L_RESULT_FLAG
     , EN_FEE_JY_GGT
     , EN_FEE_YH_GGT
     , EN_FEE_GH_GGT
     , EN_FEE_YJ_GGT
     , EN_OCCUR_BALANCE_GGT
     , EN_DEAL_BALANCE_GGT
     , EN_FEE_JY_TRUE
     , EN_FEE_YJ_TRUE
     , EN_FEE_GH_TOTAL
     , EN_FEE_QT_GGT
     , EN_FEE_JS2_GGT
     , EN_FEE_JS_GGT
     , EN_DEAL_BALANCE1
     , EN_DEAL_BALANCE2
     , C_ADDITIONAL_MARK
     , L_UNSECURED_FLAG
     , EN_PRICE
     , L_BONDLENDING_AMOUNT
     , VC_BY1
     , VC_BY2
     , L_REDEEM_DAYS
     , C_NEED_LIQMATCH
     , L_INDEX_DAILY_MODIFY
     , L_DAILY_INSTRUCTION_NO
     , L_ENTRUST_SERIAL_NO
     , C_SPECIAL_FLAG
     , L_ORIGIN_OPEN_DATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TLIQUIDATEDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TLIQUIDATEDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TLIQUIDATEDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TLIQUIDATEDETAIL_PTD成功"
      exit 0
   fi
fi
