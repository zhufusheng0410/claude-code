#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSUBJECTSTOCK_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTSTOCK_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  'L_DATE',
  L_UNIT_ID  DECIMAL(10,0)  COMMENT  'L_UNIT_ID',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  'L_BASECOMBI_ID',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  'L_FUND_ID',
  C_INVEST_TYPE  STRING  COMMENT  'C_INVEST_TYPE',
  VC_BIND_SEAT  STRING  COMMENT  'VC_BIND_SEAT',
  VC_STOCKHOLDER_ID  STRING  COMMENT  'VC_STOCKHOLDER_ID',
  VC_INTER_CODE  STRING  COMMENT  'VC_INTER_CODE',
  C_MARKET_NO  STRING  COMMENT  'C_MARKET_NO',
  L_BEGIN_AMOUNT  DECIMAL(20,4)  COMMENT  'L_BEGIN_AMOUNT',
  L_CURRENT_AMOUNT  DECIMAL(20,4)  COMMENT  'L_CURRENT_AMOUNT',
  L_FROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  'L_FROZEN_AMOUNT',
  L_UNFROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  'L_UNFROZEN_AMOUNT',
  L_BUY_AMOUNT  DECIMAL(20,4)  COMMENT  'L_BUY_AMOUNT',
  L_SALE_AMOUNT  DECIMAL(20,4)  COMMENT  'L_SALE_AMOUNT',
  L_PREBUY_AMOUNT  DECIMAL(20,4)  COMMENT  'L_PREBUY_AMOUNT',
  L_PRESALE_AMOUNT  DECIMAL(20,4)  COMMENT  'L_PRESALE_AMOUNT',
  L_TEMP_FROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  'L_TEMP_FROZEN_AMOUNT',
  L_TEMP_UNFROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  'L_TEMP_UNFROZEN_AMOUNT',
  L_T1_TEMP_FROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  'L_T1_TEMP_FROZEN_AMOUNT',
  L_T1_FROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  'L_T1_FROZEN_AMOUNT',
  EN_BUY_BALANCE  DECIMAL(18,2)  COMMENT  'EN_BUY_BALANCE',
  EN_SALE_BALANCE  DECIMAL(18,2)  COMMENT  'EN_SALE_BALANCE',
  EN_BUY_FEE  DECIMAL(18,2)  COMMENT  'EN_BUY_FEE',
  EN_SALE_FEE  DECIMAL(18,2)  COMMENT  'EN_SALE_FEE',
  EN_UNTRANSFERED_INVEST  DECIMAL(18,2)  COMMENT  'EN_UNTRANSFERED_INVEST',
  EN_INTEREST_INVEST  DECIMAL(18,2)  COMMENT  'EN_INTEREST_INVEST',
  EN_ACCUMULATE_PROFIT  DECIMAL(18,2)  COMMENT  'EN_ACCUMULATE_PROFIT',
  EN_TURN_INVEST  DECIMAL(18,2)  COMMENT  'EN_TURN_INVEST',
  EN_TURN_INTEREST_INVEST  DECIMAL(18,2)  COMMENT  'EN_TURN_INTEREST_INVEST',
  EN_TURN_PROFIT  DECIMAL(18,2)  COMMENT  'EN_TURN_PROFIT',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  'L_ASSET_ID',
  L_BUY_UNSETTLE_AMOUNT  DECIMAL(20,4)  COMMENT  'L_BUY_UNSETTLE_AMOUNT',
  L_SALE_UNSETTLE_AMOUNT  DECIMAL(20,4)  COMMENT  'L_SALE_UNSETTLE_AMOUNT',
  EN_BUY_UNSETTLE_BALANCE  DECIMAL(18,2)  COMMENT  'EN_BUY_UNSETTLE_BALANCE',
  EN_SALE_UNSETTLE_BALANCE  DECIMAL(18,2)  COMMENT  'EN_SALE_UNSETTLE_BALANCE',
  EN_TODAY_PROFIT  DECIMAL(18,2)  COMMENT  'EN_TODAY_PROFIT',
  EN_CURRENT_COST  DECIMAL(18,2)  COMMENT  'EN_CURRENT_COST',
  C_POSITION_FLAG  STRING  COMMENT  'C_POSITION_FLAG',
  EN_TRADE_BALANCE  DECIMAL(18,2)  COMMENT  'EN_TRADE_BALANCE',
  EN_REAL_BUY_FEE  DECIMAL(18,2)  COMMENT  'EN_REAL_BUY_FEE',
  EN_REAL_SALE_FEE  DECIMAL(18,2)  COMMENT  'EN_REAL_SALE_FEE',
  EN_REAL_COST  DECIMAL(18,2)  COMMENT  'EN_REAL_COST',
  EN_UNCARRYOVER_REAL_COST  DECIMAL(18,2)  COMMENT  'EN_UNCARRYOVER_REAL_COST',
  EN_NET_GAIN  DECIMAL(18,2)  COMMENT  'EN_NET_GAIN',
  EN_UNCARRYOVER_NET_GAIN  DECIMAL(18,2)  COMMENT  'EN_UNCARRYOVER_NET_GAIN',
  EN_UNCARRYOVER_DIVIDEND  DECIMAL(18,2)  COMMENT  'EN_UNCARRYOVER_DIVIDEND',
  EN_DIVIDEND  DECIMAL(18,2)  COMMENT  'EN_DIVIDEND',
  EN_TRADING_FEE  DECIMAL(18,2)  COMMENT  'EN_TRADING_FEE',
  EN_UNCARRYOVER_TRADING_FEE  DECIMAL(18,2)  COMMENT  'EN_UNCARRYOVER_TRADING_FEE',
  EN_INTEREST_PROFIT  DECIMAL(18,2)  COMMENT  'EN_INTEREST_PROFIT',
  EN_TURN_INTEREST_PROFIT  DECIMAL(18,2)  COMMENT  'EN_TURN_INTEREST_PROFIT',
  EN_BEGINYEAR_TURN_PROFIT  DECIMAL(18,2)  COMMENT  'EN_BEGINYEAR_TURN_PROFIT',
  EN_BEGINYEAR_UNTURN_PROFIT  DECIMAL(18,2)  COMMENT  'EN_BEGINYEAR_UNTURN_PROFIT'
)
COMMENT '科目证券持仓表'
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
                                   , L_UNIT_ID
                                   , L_BASECOMBI_ID
                                   , L_FUND_ID
                                   , C_INVEST_TYPE
                                   , VC_BIND_SEAT
                                   , VC_STOCKHOLDER_ID
                                   , VC_INTER_CODE
                                   , C_MARKET_NO
                                   , L_BEGIN_AMOUNT
                                   , L_CURRENT_AMOUNT
                                   , L_FROZEN_AMOUNT
                                   , L_UNFROZEN_AMOUNT
                                   , L_BUY_AMOUNT
                                   , L_SALE_AMOUNT
                                   , L_PREBUY_AMOUNT
                                   , L_PRESALE_AMOUNT
                                   , L_TEMP_FROZEN_AMOUNT
                                   , L_TEMP_UNFROZEN_AMOUNT
                                   , L_T1_TEMP_FROZEN_AMOUNT
                                   , L_T1_FROZEN_AMOUNT
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
                                   , L_ASSET_ID
                                   , L_BUY_UNSETTLE_AMOUNT
                                   , L_SALE_UNSETTLE_AMOUNT
                                   , EN_BUY_UNSETTLE_BALANCE
                                   , EN_SALE_UNSETTLE_BALANCE
                                   , EN_TODAY_PROFIT
                                   , EN_CURRENT_COST
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
                                FROM ${o32_src_schema}.THISSUBJECTSTOCK"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_UNIT_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "L_BEGIN_AMOUNT", "type": "DOUBLE"}, {"name": "L_CURRENT_AMOUNT", "type": "DOUBLE"}, {"name": "L_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "L_UNFROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "L_BUY_AMOUNT", "type": "DOUBLE"}, {"name": "L_SALE_AMOUNT", "type": "DOUBLE"}, {"name": "L_PREBUY_AMOUNT", "type": "DOUBLE"}, {"name": "L_PRESALE_AMOUNT", "type": "DOUBLE"}, {"name": "L_TEMP_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "L_TEMP_UNFROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "L_T1_TEMP_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "L_T1_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_FEE", "type": "DOUBLE"}, {"name": "EN_SALE_FEE", "type": "DOUBLE"}, {"name": "EN_UNTRANSFERED_INVEST", "type": "DOUBLE"}, {"name": "EN_INTEREST_INVEST", "type": "DOUBLE"}, {"name": "EN_ACCUMULATE_PROFIT", "type": "DOUBLE"}, {"name": "EN_TURN_INVEST", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_INVEST", "type": "DOUBLE"}, {"name": "EN_TURN_PROFIT", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_BUY_UNSETTLE_AMOUNT", "type": "DOUBLE"}, {"name": "L_SALE_UNSETTLE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BUY_UNSETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_UNSETTLE_BALANCE", "type": "DOUBLE"}, {"name": "EN_TODAY_PROFIT", "type": "DOUBLE"}, {"name": "EN_CURRENT_COST", "type": "DOUBLE"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "EN_TRADE_BALANCE", "type": "DOUBLE"}, {"name": "EN_REAL_BUY_FEE", "type": "DOUBLE"}, {"name": "EN_REAL_SALE_FEE", "type": "DOUBLE"}, {"name": "EN_REAL_COST", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_REAL_COST", "type": "DOUBLE"}, {"name": "EN_NET_GAIN", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_NET_GAIN", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_DIVIDEND", "type": "DOUBLE"}, {"name": "EN_DIVIDEND", "type": "DOUBLE"}, {"name": "EN_TRADING_FEE", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_TRADING_FEE", "type": "DOUBLE"}, {"name": "EN_INTEREST_PROFIT", "type": "DOUBLE"}, {"name": "EN_TURN_INTEREST_PROFIT", "type": "DOUBLE"}, {"name": "EN_BEGINYEAR_TURN_PROFIT", "type": "DOUBLE"}, {"name": "EN_BEGINYEAR_UNTURN_PROFIT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tsubjectstock_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tsubjectstock_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tsubjectstock_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tsubjectstock_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSUBJECTSTOCK_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSUBJECTSTOCK_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tsubjectstock_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTSTOCK_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DATE
     , L_UNIT_ID
     , L_BASECOMBI_ID
     , L_FUND_ID
     , C_INVEST_TYPE
     , VC_BIND_SEAT
     , VC_STOCKHOLDER_ID
     , VC_INTER_CODE
     , C_MARKET_NO
     , L_BEGIN_AMOUNT
     , L_CURRENT_AMOUNT
     , L_FROZEN_AMOUNT
     , L_UNFROZEN_AMOUNT
     , L_BUY_AMOUNT
     , L_SALE_AMOUNT
     , L_PREBUY_AMOUNT
     , L_PRESALE_AMOUNT
     , L_TEMP_FROZEN_AMOUNT
     , L_TEMP_UNFROZEN_AMOUNT
     , L_T1_TEMP_FROZEN_AMOUNT
     , L_T1_FROZEN_AMOUNT
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
     , L_ASSET_ID
     , L_BUY_UNSETTLE_AMOUNT
     , L_SALE_UNSETTLE_AMOUNT
     , EN_BUY_UNSETTLE_BALANCE
     , EN_SALE_UNSETTLE_BALANCE
     , EN_TODAY_PROFIT
     , EN_CURRENT_COST
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
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSUBJECTSTOCK_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTSTOCK_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSUBJECTSTOCK_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSUBJECTSTOCK_PFD成功"
      exit 0
   fi
fi
