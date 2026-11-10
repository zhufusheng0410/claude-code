#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFUTURESINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFUTURESINFO_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_SETTLEMENT_GROUP  STRING  COMMENT  '结算组代码',
  VC_PRODUCT_GROUP  STRING  COMMENT  '产品组代码',
  VC_PRODUCT  STRING  COMMENT  '产品代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  VC_MONTH  STRING  COMMENT  '合约月份',
  C_TARGET_MARKET  STRING  COMMENT  '标的物市场代码',
  VC_TARGET_CODE  STRING  COMMENT  '标的代码',
  L_MULTIPLE  DECIMAL(10,0)  COMMENT  '合约乘数',
  L_LAST_TRADE_DATE  DECIMAL(8,0)  COMMENT  '最后交易日',
  L_LAST_SETTLEMENT_DATE  DECIMAL(8,0)  COMMENT  '交割日',
  L_LAST_TRADE_TIME  DECIMAL(6,0)  COMMENT  '最后交易日时间',
  EN_PRICE  DECIMAL(16,8)  COMMENT  '结算价',
  EN_PRE_PRICE  DECIMAL(16,8)  COMMENT  '前结算价',
  EN_POSITION_AMOUNT  DECIMAL(12,0)  COMMENT  '持仓量',
  EN_POSITION_AMOUNT_PRE  DECIMAL(12,0)  COMMENT  '前持仓量',
  C_STATUS  STRING  COMMENT  '状态',
  EN_REAL_PRICE  DECIMAL(16,8)  COMMENT  '实时行情的结算价',
  C_MARKET_PRICE  STRING  COMMENT  '允许市价',
  L_KIND_NO  DECIMAL(3,0)  COMMENT  '期货品种',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  EN_YESTERDAY_DEAL_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  VC_CTD_CODE  STRING  COMMENT  '',
  C_IS_HISDATA  STRING  COMMENT  ''
)
COMMENT '期货信息表'
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
                                   , VC_SETTLEMENT_GROUP
                                   , VC_PRODUCT_GROUP
                                   , VC_PRODUCT
                                   , VC_INTER_CODE
                                   , VC_MONTH
                                   , C_TARGET_MARKET
                                   , VC_TARGET_CODE
                                   , L_MULTIPLE
                                   , L_LAST_TRADE_DATE
                                   , L_LAST_SETTLEMENT_DATE
                                   , L_LAST_TRADE_TIME
                                   , EN_PRICE
                                   , EN_PRE_PRICE
                                   , EN_POSITION_AMOUNT
                                   , EN_POSITION_AMOUNT_PRE
                                   , C_STATUS
                                   , EN_REAL_PRICE
                                   , C_MARKET_PRICE
                                   , L_KIND_NO
                                   , L_VIRTUAL_KEY
                                   , VC_TIMESTAMP
                                   , EN_YESTERDAY_DEAL_AMOUNT
                                   , VC_CTD_CODE
                                   , C_IS_HISDATA
                                FROM ${o32_src_schema}.THISFUTURESINFO
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_SETTLEMENT_GROUP", "type": "STRING"}, {"name": "VC_PRODUCT_GROUP", "type": "STRING"}, {"name": "VC_PRODUCT", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "VC_MONTH", "type": "STRING"}, {"name": "C_TARGET_MARKET", "type": "STRING"}, {"name": "VC_TARGET_CODE", "type": "STRING"}, {"name": "L_MULTIPLE", "type": "DOUBLE"}, {"name": "L_LAST_TRADE_DATE", "type": "DOUBLE"}, {"name": "L_LAST_SETTLEMENT_DATE", "type": "DOUBLE"}, {"name": "L_LAST_TRADE_TIME", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "EN_PRE_PRICE", "type": "DOUBLE"}, {"name": "EN_POSITION_AMOUNT", "type": "DOUBLE"}, {"name": "EN_POSITION_AMOUNT_PRE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "EN_REAL_PRICE", "type": "DOUBLE"}, {"name": "C_MARKET_PRICE", "type": "STRING"}, {"name": "L_KIND_NO", "type": "DOUBLE"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "EN_YESTERDAY_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "VC_CTD_CODE", "type": "STRING"}, {"name": "C_IS_HISDATA", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfuturesinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfuturesinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfuturesinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfuturesinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFUTURESINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFUTURESINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfuturesinfo_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFUTURESINFO_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_SETTLEMENT_GROUP
     , VC_PRODUCT_GROUP
     , VC_PRODUCT
     , VC_INTER_CODE
     , VC_MONTH
     , C_TARGET_MARKET
     , VC_TARGET_CODE
     , L_MULTIPLE
     , L_LAST_TRADE_DATE
     , L_LAST_SETTLEMENT_DATE
     , L_LAST_TRADE_TIME
     , EN_PRICE
     , EN_PRE_PRICE
     , EN_POSITION_AMOUNT
     , EN_POSITION_AMOUNT_PRE
     , C_STATUS
     , EN_REAL_PRICE
     , C_MARKET_PRICE
     , L_KIND_NO
     , L_VIRTUAL_KEY
     , VC_TIMESTAMP
     , EN_YESTERDAY_DEAL_AMOUNT
     , VC_CTD_CODE
     , C_IS_HISDATA
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TFUTURESINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFUTURESINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFUTURESINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFUTURESINFO_PFD成功"
      exit 0
   fi
fi
