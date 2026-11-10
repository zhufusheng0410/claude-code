#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TMARKETINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TMARKETINFO_PFD_TMP(
  C_MARKET_NO  STRING  COMMENT  '交易市场内部编号',
  VC_MARKET_CHAR  STRING  COMMENT  '交易市场简码',
  VC_MARKET_NAME  STRING  COMMENT  '交易市场简称',
  VC_MARKET_CAPTION  STRING  COMMENT  '交易市场全称',
  C_STOP  STRING  COMMENT  '停市标志',
  L_MORNING_OPEN_TIME  DECIMAL(6,0)  COMMENT  '上午开市时间',
  L_MORNING_CLOSE_TIME  DECIMAL(6,0)  COMMENT  '上午闭市时间',
  L_AFTERNOON_OPEN_TIME  DECIMAL(6,0)  COMMENT  '下午开市时间',
  L_AFTERNOON_CLOSE_TIME  DECIMAL(6,0)  COMMENT  '下午闭市时间',
  L_NIGHT_OPEN_TIME  DECIMAL(6,0)  COMMENT  '晚上开市时间',
  L_NIGHT_CLOSE_TIME  DECIMAL(6,0)  COMMENT  '晚上闭市时间',
  VC_COUNTRY_NO  STRING  COMMENT  '国家或地区',
  VC_CURRENCY_NO  STRING  COMMENT  '缺省币种',
  VC_EXCHANGE_CODE  STRING  COMMENT  '市场代码',
  C_STOP_TRADE  STRING  COMMENT  '证券停牌后是否允许委托',
  L_LENGTH_MIN  STRING  COMMENT  '代码最小长度',
  L_LENGTH_MAX  STRING  COMMENT  '代码最大长度',
  C_CURRENCY_SINGLE  STRING  COMMENT  '单一币种',
  C_INSTRUCTION_MULTIDAY  STRING  COMMENT  '支持多日指令',
  C_ENTRUST_MULTIDAY  STRING  COMMENT  '支持多日委托',
  VC_TRADEDAY_TYPE  STRING  COMMENT  '使用哪套交易日',
  EN_TIME_ZONE  DECIMAL(3,1)  COMMENT  '时区',
  C_MARKETINFO_TYPE  STRING  COMMENT  '行情方式',
  C_MARKET_TYPE  STRING  COMMENT  '交易市场类别',
  VC_YESTERDAY_CLOSE_PRICE  STRING  COMMENT  '昨收盘价',
  VC_OPEN_PRICE  STRING  COMMENT  '今开盘价',
  VC_UPLIMITED_PRICE  STRING  COMMENT  '涨停板价格',
  VC_DOWNLIMITED_PRICE  STRING  COMMENT  '跌停板价格',
  VC_LAST_PRICE  STRING  COMMENT  '最新价/今收盘价',
  VC_AVG_PRICE  STRING  COMMENT  '平均价格',
  VC_MAX_PRICE  STRING  COMMENT  '今最高价',
  VC_MIN_PRICE  STRING  COMMENT  '今最低价',
  VC_MARKET_DEAL_AMOUNT  STRING  COMMENT  '市场成交数量',
  VC_MARKET_DEAL_BALANCE  STRING  COMMENT  '市场成交金额',
  VC_BUY_PRICE1  STRING  COMMENT  '买一价',
  VC_BUY_AMOUNT1  STRING  COMMENT  '买一数量',
  VC_BUY_PRICE2  STRING  COMMENT  '买二价',
  VC_BUY_AMOUNT2  STRING  COMMENT  '买二数量',
  VC_BUY_PRICE3  STRING  COMMENT  '买三价',
  VC_BUY_AMOUNT3  STRING  COMMENT  '买三数量',
  VC_BUY_PRICE4  STRING  COMMENT  '买四价',
  VC_BUY_AMOUNT4  STRING  COMMENT  '买四数量',
  VC_BUY_PRICE5  STRING  COMMENT  '买五价',
  VC_BUY_AMOUNT5  STRING  COMMENT  '买五数量',
  VC_SALE_PRICE1  STRING  COMMENT  '卖一价',
  VC_SALE_AMOUNT1  STRING  COMMENT  '卖一数量',
  VC_SALE_PRICE2  STRING  COMMENT  '卖二价',
  VC_SALE_AMOUNT2  STRING  COMMENT  '卖二数量',
  VC_SALE_PRICE3  STRING  COMMENT  '卖三价',
  VC_SALE_AMOUNT3  STRING  COMMENT  '卖三数量',
  VC_SALE_PRICE4  STRING  COMMENT  '卖四价',
  VC_SALE_AMOUNT4  STRING  COMMENT  '卖四数量',
  VC_SALE_PRICE5  STRING  COMMENT  '卖五价',
  VC_SALE_AMOUNT5  STRING  COMMENT  '卖五数量',
  VC_PRICE_EARNING_RATIO  STRING  COMMENT  '市盈率',
  VC_BUSIN_CLASSES  STRING  COMMENT  '包含的业务分类',
  C_ENTRUSTS_COMBI  STRING  COMMENT  '＃支持合笔委托',
  C_DMA  STRING  COMMENT  '＃支持dma',
  VC_DMA_ENTRUST  STRING  COMMENT  'dma委托有效类型',
  VC_EDA_ENTRUST  STRING  COMMENT  '非dma委托有效类型',
  C_SIGNED_MOU  STRING  COMMENT  '是否签署mou',
  VC_RIC_MARKET_NO  STRING  COMMENT  '路透市场代码',
  VC_ISO_MARKET_CODE  STRING  COMMENT  'iso市场代码',
  VC_SAME_MARKETS  STRING  COMMENT  '统一处理市场代码',
  L_LASTSTORE_DATE  DECIMAL(10,0)  COMMENT  '最后更新时间',
  VC_AREA  STRING  COMMENT  '区域',
  L_DZJY_CLOSE_TIME  DECIMAL(6,0)  COMMENT  '大宗交易闭市时间',
  L_GDSY_CLOSE_TIME  DECIMAL(6,0)  COMMENT  '固定收益闭市时间',
  L_LAST_TRADE_DATE  DECIMAL(8,0)  COMMENT  '上一个交易日',
  L_NEXT_TRADE_DATE  DECIMAL(8,0)  COMMENT  '下一个交易日',
  VC_IOPV_MARKET_CODE  STRING  COMMENT  'iopv系统市场代码',
  L_DAILY_REMAIN_AMOUNT  DECIMAL(13,0)  COMMENT  '日中剩余额度',
  VC_MARKET_STATUS  STRING  COMMENT  '市场状态',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_TIME_SCALE  STRING  COMMENT  '时间段设置',
  L_NEXT2_TRADE_DATE  DECIMAL(8,0)  COMMENT  '',
  L_GDSY_OPEN_TIME  DECIMAL(6,0)  COMMENT  ''
)
COMMENT '交易市场信息表'
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
              "querySql": ["SELECT  C_MARKET_NO
                                   , VC_MARKET_CHAR
                                   , VC_MARKET_NAME
                                   , VC_MARKET_CAPTION
                                   , C_STOP
                                   , L_MORNING_OPEN_TIME
                                   , L_MORNING_CLOSE_TIME
                                   , L_AFTERNOON_OPEN_TIME
                                   , L_AFTERNOON_CLOSE_TIME
                                   , L_NIGHT_OPEN_TIME
                                   , L_NIGHT_CLOSE_TIME
                                   , VC_COUNTRY_NO
                                   , VC_CURRENCY_NO
                                   , VC_EXCHANGE_CODE
                                   , C_STOP_TRADE
                                   , L_LENGTH_MIN
                                   , L_LENGTH_MAX
                                   , C_CURRENCY_SINGLE
                                   , C_INSTRUCTION_MULTIDAY
                                   , C_ENTRUST_MULTIDAY
                                   , VC_TRADEDAY_TYPE
                                   , EN_TIME_ZONE
                                   , C_MARKETINFO_TYPE
                                   , C_MARKET_TYPE
                                   , VC_YESTERDAY_CLOSE_PRICE
                                   , VC_OPEN_PRICE
                                   , VC_UPLIMITED_PRICE
                                   , VC_DOWNLIMITED_PRICE
                                   , VC_LAST_PRICE
                                   , VC_AVG_PRICE
                                   , VC_MAX_PRICE
                                   , VC_MIN_PRICE
                                   , VC_MARKET_DEAL_AMOUNT
                                   , VC_MARKET_DEAL_BALANCE
                                   , VC_BUY_PRICE1
                                   , VC_BUY_AMOUNT1
                                   , VC_BUY_PRICE2
                                   , VC_BUY_AMOUNT2
                                   , VC_BUY_PRICE3
                                   , VC_BUY_AMOUNT3
                                   , VC_BUY_PRICE4
                                   , VC_BUY_AMOUNT4
                                   , VC_BUY_PRICE5
                                   , VC_BUY_AMOUNT5
                                   , VC_SALE_PRICE1
                                   , VC_SALE_AMOUNT1
                                   , VC_SALE_PRICE2
                                   , VC_SALE_AMOUNT2
                                   , VC_SALE_PRICE3
                                   , VC_SALE_AMOUNT3
                                   , VC_SALE_PRICE4
                                   , VC_SALE_AMOUNT4
                                   , VC_SALE_PRICE5
                                   , VC_SALE_AMOUNT5
                                   , VC_PRICE_EARNING_RATIO
                                   , VC_BUSIN_CLASSES
                                   , C_ENTRUSTS_COMBI
                                   , C_DMA
                                   , VC_DMA_ENTRUST
                                   , VC_EDA_ENTRUST
                                   , C_SIGNED_MOU
                                   , VC_RIC_MARKET_NO
                                   , VC_ISO_MARKET_CODE
                                   , VC_SAME_MARKETS
                                   , L_LASTSTORE_DATE
                                   , VC_AREA
                                   , L_DZJY_CLOSE_TIME
                                   , L_GDSY_CLOSE_TIME
                                   , L_LAST_TRADE_DATE
                                   , L_NEXT_TRADE_DATE
                                   , VC_IOPV_MARKET_CODE
                                   , L_DAILY_REMAIN_AMOUNT
                                   , VC_MARKET_STATUS
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , VC_TIME_SCALE
                                   , L_NEXT2_TRADE_DATE
                                   , L_GDSY_OPEN_TIME
                                FROM ${o32_src_schema}.TMARKETINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_MARKET_CHAR", "type": "STRING"}, {"name": "VC_MARKET_NAME", "type": "STRING"}, {"name": "VC_MARKET_CAPTION", "type": "STRING"}, {"name": "C_STOP", "type": "STRING"}, {"name": "L_MORNING_OPEN_TIME", "type": "DOUBLE"}, {"name": "L_MORNING_CLOSE_TIME", "type": "DOUBLE"}, {"name": "L_AFTERNOON_OPEN_TIME", "type": "DOUBLE"}, {"name": "L_AFTERNOON_CLOSE_TIME", "type": "DOUBLE"}, {"name": "L_NIGHT_OPEN_TIME", "type": "DOUBLE"}, {"name": "L_NIGHT_CLOSE_TIME", "type": "DOUBLE"}, {"name": "VC_COUNTRY_NO", "type": "STRING"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "VC_EXCHANGE_CODE", "type": "STRING"}, {"name": "C_STOP_TRADE", "type": "STRING"}, {"name": "L_LENGTH_MIN", "type": "DOUBLE"}, {"name": "L_LENGTH_MAX", "type": "DOUBLE"}, {"name": "C_CURRENCY_SINGLE", "type": "STRING"}, {"name": "C_INSTRUCTION_MULTIDAY", "type": "STRING"}, {"name": "C_ENTRUST_MULTIDAY", "type": "STRING"}, {"name": "VC_TRADEDAY_TYPE", "type": "STRING"}, {"name": "EN_TIME_ZONE", "type": "DOUBLE"}, {"name": "C_MARKETINFO_TYPE", "type": "STRING"}, {"name": "C_MARKET_TYPE", "type": "STRING"}, {"name": "VC_YESTERDAY_CLOSE_PRICE", "type": "STRING"}, {"name": "VC_OPEN_PRICE", "type": "STRING"}, {"name": "VC_UPLIMITED_PRICE", "type": "STRING"}, {"name": "VC_DOWNLIMITED_PRICE", "type": "STRING"}, {"name": "VC_LAST_PRICE", "type": "STRING"}, {"name": "VC_AVG_PRICE", "type": "STRING"}, {"name": "VC_MAX_PRICE", "type": "STRING"}, {"name": "VC_MIN_PRICE", "type": "STRING"}, {"name": "VC_MARKET_DEAL_AMOUNT", "type": "STRING"}, {"name": "VC_MARKET_DEAL_BALANCE", "type": "STRING"}, {"name": "VC_BUY_PRICE1", "type": "STRING"}, {"name": "VC_BUY_AMOUNT1", "type": "STRING"}, {"name": "VC_BUY_PRICE2", "type": "STRING"}, {"name": "VC_BUY_AMOUNT2", "type": "STRING"}, {"name": "VC_BUY_PRICE3", "type": "STRING"}, {"name": "VC_BUY_AMOUNT3", "type": "STRING"}, {"name": "VC_BUY_PRICE4", "type": "STRING"}, {"name": "VC_BUY_AMOUNT4", "type": "STRING"}, {"name": "VC_BUY_PRICE5", "type": "STRING"}, {"name": "VC_BUY_AMOUNT5", "type": "STRING"}, {"name": "VC_SALE_PRICE1", "type": "STRING"}, {"name": "VC_SALE_AMOUNT1", "type": "STRING"}, {"name": "VC_SALE_PRICE2", "type": "STRING"}, {"name": "VC_SALE_AMOUNT2", "type": "STRING"}, {"name": "VC_SALE_PRICE3", "type": "STRING"}, {"name": "VC_SALE_AMOUNT3", "type": "STRING"}, {"name": "VC_SALE_PRICE4", "type": "STRING"}, {"name": "VC_SALE_AMOUNT4", "type": "STRING"}, {"name": "VC_SALE_PRICE5", "type": "STRING"}, {"name": "VC_SALE_AMOUNT5", "type": "STRING"}, {"name": "VC_PRICE_EARNING_RATIO", "type": "STRING"}, {"name": "VC_BUSIN_CLASSES", "type": "STRING"}, {"name": "C_ENTRUSTS_COMBI", "type": "STRING"}, {"name": "C_DMA", "type": "STRING"}, {"name": "VC_DMA_ENTRUST", "type": "STRING"}, {"name": "VC_EDA_ENTRUST", "type": "STRING"}, {"name": "C_SIGNED_MOU", "type": "STRING"}, {"name": "VC_RIC_MARKET_NO", "type": "STRING"}, {"name": "VC_ISO_MARKET_CODE", "type": "STRING"}, {"name": "VC_SAME_MARKETS", "type": "STRING"}, {"name": "L_LASTSTORE_DATE", "type": "DOUBLE"}, {"name": "VC_AREA", "type": "STRING"}, {"name": "L_DZJY_CLOSE_TIME", "type": "DOUBLE"}, {"name": "L_GDSY_CLOSE_TIME", "type": "DOUBLE"}, {"name": "L_LAST_TRADE_DATE", "type": "DOUBLE"}, {"name": "L_NEXT_TRADE_DATE", "type": "DOUBLE"}, {"name": "VC_IOPV_MARKET_CODE", "type": "STRING"}, {"name": "L_DAILY_REMAIN_AMOUNT", "type": "DOUBLE"}, {"name": "VC_MARKET_STATUS", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_TIME_SCALE", "type": "STRING"}, {"name": "L_NEXT2_TRADE_DATE", "type": "DOUBLE"}, {"name": "L_GDSY_OPEN_TIME", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tmarketinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tmarketinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tmarketinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tmarketinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TMARKETINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TMARKETINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tmarketinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TMARKETINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_MARKET_NO
     , VC_MARKET_CHAR
     , VC_MARKET_NAME
     , VC_MARKET_CAPTION
     , C_STOP
     , L_MORNING_OPEN_TIME
     , L_MORNING_CLOSE_TIME
     , L_AFTERNOON_OPEN_TIME
     , L_AFTERNOON_CLOSE_TIME
     , L_NIGHT_OPEN_TIME
     , L_NIGHT_CLOSE_TIME
     , VC_COUNTRY_NO
     , VC_CURRENCY_NO
     , VC_EXCHANGE_CODE
     , C_STOP_TRADE
     , L_LENGTH_MIN
     , L_LENGTH_MAX
     , C_CURRENCY_SINGLE
     , C_INSTRUCTION_MULTIDAY
     , C_ENTRUST_MULTIDAY
     , VC_TRADEDAY_TYPE
     , EN_TIME_ZONE
     , C_MARKETINFO_TYPE
     , C_MARKET_TYPE
     , VC_YESTERDAY_CLOSE_PRICE
     , VC_OPEN_PRICE
     , VC_UPLIMITED_PRICE
     , VC_DOWNLIMITED_PRICE
     , VC_LAST_PRICE
     , VC_AVG_PRICE
     , VC_MAX_PRICE
     , VC_MIN_PRICE
     , VC_MARKET_DEAL_AMOUNT
     , VC_MARKET_DEAL_BALANCE
     , VC_BUY_PRICE1
     , VC_BUY_AMOUNT1
     , VC_BUY_PRICE2
     , VC_BUY_AMOUNT2
     , VC_BUY_PRICE3
     , VC_BUY_AMOUNT3
     , VC_BUY_PRICE4
     , VC_BUY_AMOUNT4
     , VC_BUY_PRICE5
     , VC_BUY_AMOUNT5
     , VC_SALE_PRICE1
     , VC_SALE_AMOUNT1
     , VC_SALE_PRICE2
     , VC_SALE_AMOUNT2
     , VC_SALE_PRICE3
     , VC_SALE_AMOUNT3
     , VC_SALE_PRICE4
     , VC_SALE_AMOUNT4
     , VC_SALE_PRICE5
     , VC_SALE_AMOUNT5
     , VC_PRICE_EARNING_RATIO
     , VC_BUSIN_CLASSES
     , C_ENTRUSTS_COMBI
     , C_DMA
     , VC_DMA_ENTRUST
     , VC_EDA_ENTRUST
     , C_SIGNED_MOU
     , VC_RIC_MARKET_NO
     , VC_ISO_MARKET_CODE
     , VC_SAME_MARKETS
     , L_LASTSTORE_DATE
     , VC_AREA
     , L_DZJY_CLOSE_TIME
     , L_GDSY_CLOSE_TIME
     , L_LAST_TRADE_DATE
     , L_NEXT_TRADE_DATE
     , VC_IOPV_MARKET_CODE
     , L_DAILY_REMAIN_AMOUNT
     , VC_MARKET_STATUS
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , VC_TIME_SCALE
     , L_NEXT2_TRADE_DATE
     , L_GDSY_OPEN_TIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TMARKETINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TMARKETINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TMARKETINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TMARKETINFO_PFD成功"
      exit 0
   fi
fi
