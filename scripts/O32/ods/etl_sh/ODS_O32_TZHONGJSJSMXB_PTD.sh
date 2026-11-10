#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TZHONGJSJSMXB_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TZHONGJSJSMXB_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_TRADE_MEMBER  STRING  COMMENT  '非结算会员号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_INTER_CODE  STRING  COMMENT  '合约代码',
  EN_SETTLEMENT_PRICE  DECIMAL(16,8)  COMMENT  '结算价',
  EN_BUY_OPEN  DECIMAL(12,0)  COMMENT  '买开成交量',
  EN_BUY_CLOSE  DECIMAL(12,0)  COMMENT  '买平成交量',
  EN_BUY_TOTAL  DECIMAL(12,0)  COMMENT  '买成交量合计',
  EN_SALE_OPEN  DECIMAL(12,0)  COMMENT  '卖开成交量',
  EN_SALE_CLOSE  DECIMAL(12,0)  COMMENT  '卖平成交量',
  EN_SALE_TOTAL  DECIMAL(12,0)  COMMENT  '卖成交量合计',
  EN_BUY_BALANCE  DECIMAL(16,2)  COMMENT  '买入成交额',
  EN_SALE_BALANCE  DECIMAL(16,2)  COMMENT  '卖出成交额',
  EN_BUY_POSITION  DECIMAL(12,0)  COMMENT  '买持仓量合计',
  EN_SALE_POSITION  DECIMAL(12,0)  COMMENT  '卖持仓量合计',
  EN_DEPOSIT  DECIMAL(16,2)  COMMENT  '交易保证金',
  EN_PROFIT  DECIMAL(16,2)  COMMENT  '当日盈亏',
  EN_FARE  DECIMAL(16,2)  COMMENT  '费用合计',
  L_SECURITIES_BRANCH  DECIMAL(10,0)  COMMENT  '分仓营业部',
  EN_PREMIUM  DECIMAL(16,2)  COMMENT  '期权保证金'
)
COMMENT '中金所结算明细表'
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
                                   , VC_TRADE_MEMBER
                                   , VC_STOCKHOLDER_ID
                                   , VC_INTER_CODE
                                   , EN_SETTLEMENT_PRICE
                                   , EN_BUY_OPEN
                                   , EN_BUY_CLOSE
                                   , EN_BUY_TOTAL
                                   , EN_SALE_OPEN
                                   , EN_SALE_CLOSE
                                   , EN_SALE_TOTAL
                                   , EN_BUY_BALANCE
                                   , EN_SALE_BALANCE
                                   , EN_BUY_POSITION
                                   , EN_SALE_POSITION
                                   , EN_DEPOSIT
                                   , EN_PROFIT
                                   , EN_FARE
                                   , L_SECURITIES_BRANCH
                                   , EN_PREMIUM
                                FROM ${o32_src_schema}.THISZHONGJSJSMXB
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_TRADE_MEMBER", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_SETTLEMENT_PRICE", "type": "DOUBLE"}, {"name": "EN_BUY_OPEN", "type": "DOUBLE"}, {"name": "EN_BUY_CLOSE", "type": "DOUBLE"}, {"name": "EN_BUY_TOTAL", "type": "DOUBLE"}, {"name": "EN_SALE_OPEN", "type": "DOUBLE"}, {"name": "EN_SALE_CLOSE", "type": "DOUBLE"}, {"name": "EN_SALE_TOTAL", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_POSITION", "type": "DOUBLE"}, {"name": "EN_SALE_POSITION", "type": "DOUBLE"}, {"name": "EN_DEPOSIT", "type": "DOUBLE"}, {"name": "EN_PROFIT", "type": "DOUBLE"}, {"name": "EN_FARE", "type": "DOUBLE"}, {"name": "L_SECURITIES_BRANCH", "type": "DOUBLE"}, {"name": "EN_PREMIUM", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tzhongjsjsmxb_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tzhongjsjsmxb_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tzhongjsjsmxb_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tzhongjsjsmxb_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TZHONGJSJSMXB_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TZHONGJSJSMXB_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tzhongjsjsmxb_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TZHONGJSJSMXB_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_TRADE_MEMBER
     , VC_STOCKHOLDER_ID
     , VC_INTER_CODE
     , EN_SETTLEMENT_PRICE
     , EN_BUY_OPEN
     , EN_BUY_CLOSE
     , EN_BUY_TOTAL
     , EN_SALE_OPEN
     , EN_SALE_CLOSE
     , EN_SALE_TOTAL
     , EN_BUY_BALANCE
     , EN_SALE_BALANCE
     , EN_BUY_POSITION
     , EN_SALE_POSITION
     , EN_DEPOSIT
     , EN_PROFIT
     , EN_FARE
     , L_SECURITIES_BRANCH
     , EN_PREMIUM
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TZHONGJSJSMXB_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TZHONGJSJSMXB_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TZHONGJSJSMXB_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TZHONGJSJSMXB_PTD成功"
      exit 0
   fi
fi
