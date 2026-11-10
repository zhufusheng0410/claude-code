#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFUTUREKIND_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFUTUREKIND_PFD_TMP(
  L_KIND_NO  DECIMAL(3,0)  COMMENT  '品种序号',
  C_MARKET_NO  STRING  COMMENT  '市场代码',
  VC_KIND_CODE  STRING  COMMENT  '品种编号',
  VC_KIND_NAME  STRING  COMMENT  '品种名称',
  L_MARKET_BUY_MAX  DECIMAL(14,2)  COMMENT  '市价最大买入数量',
  L_MARKET_SALE_MAX  DECIMAL(14,2)  COMMENT  '市价最大卖出数量',
  L_BUY_MAX  DECIMAL(14,2)  COMMENT  '买入最大数量',
  L_SALE_MAX  DECIMAL(14,2)  COMMENT  '卖出最大数量',
  L_MULTIPLICATOR  DECIMAL(10,0)  COMMENT  '合约乘数',
  VC_DATECALC_TYPE  STRING  COMMENT  '交易日计算模式',
  VC_CONTRACT_RULE  STRING  COMMENT  '合约规则',
  VC_TRADE_MONTH  STRING  COMMENT  '交易月份',
  C_TYPE  STRING  COMMENT  '品种类型',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  VC_TARGET_CODE  STRING  COMMENT  '标的券内码',
  VC_KIND_CLASS  STRING  COMMENT  '品类',
  C_ISOPENTODAY  STRING  COMMENT  '是否支持开今优惠',
  VC_KIND_GROUP  STRING  COMMENT  '跨品种组别',
  C_KIND_STATUS  STRING  COMMENT  '期货品种状态',
  L_AGGREGATE_AUCTION_BEGDATE  DECIMAL(8,0)  COMMENT  '',
  L_AGGREGATE_AUCTION_ENDDATE  DECIMAL(8,0)  COMMENT  '',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  EN_DEPOSITCHANGE_RATO1  DECIMAL(16,8)  COMMENT  '',
  EN_DEPOSITCHANGE_RATO2  DECIMAL(16,8)  COMMENT  '',
  L_MIN_OPEN_AMOUNT  DECIMAL(10,0)  COMMENT  ''
)
COMMENT '期货期权品种信息表'
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
              "querySql": ["SELECT  L_KIND_NO
                                   , C_MARKET_NO
                                   , VC_KIND_CODE
                                   , VC_KIND_NAME
                                   , L_MARKET_BUY_MAX
                                   , L_MARKET_SALE_MAX
                                   , L_BUY_MAX
                                   , L_SALE_MAX
                                   , L_MULTIPLICATOR
                                   , VC_DATECALC_TYPE
                                   , VC_CONTRACT_RULE
                                   , VC_TRADE_MONTH
                                   , C_TYPE
                                   , C_STOCK_TYPE
                                   , VC_TARGET_CODE
                                   , VC_KIND_CLASS
                                   , C_ISOPENTODAY
                                   , VC_KIND_GROUP
                                   , C_KIND_STATUS
                                   , L_AGGREGATE_AUCTION_BEGDATE
                                   , L_AGGREGATE_AUCTION_ENDDATE
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , EN_DEPOSITCHANGE_RATO1
                                   , EN_DEPOSITCHANGE_RATO2
                                   , L_MIN_OPEN_AMOUNT
                                FROM ${o32_src_schema}.TFUTUREKIND"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_KIND_NO", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_KIND_CODE", "type": "STRING"}, {"name": "VC_KIND_NAME", "type": "STRING"}, {"name": "L_MARKET_BUY_MAX", "type": "DOUBLE"}, {"name": "L_MARKET_SALE_MAX", "type": "DOUBLE"}, {"name": "L_BUY_MAX", "type": "DOUBLE"}, {"name": "L_SALE_MAX", "type": "DOUBLE"}, {"name": "L_MULTIPLICATOR", "type": "DOUBLE"}, {"name": "VC_DATECALC_TYPE", "type": "STRING"}, {"name": "VC_CONTRACT_RULE", "type": "STRING"}, {"name": "VC_TRADE_MONTH", "type": "STRING"}, {"name": "C_TYPE", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "VC_TARGET_CODE", "type": "STRING"}, {"name": "VC_KIND_CLASS", "type": "STRING"}, {"name": "C_ISOPENTODAY", "type": "STRING"}, {"name": "VC_KIND_GROUP", "type": "STRING"}, {"name": "C_KIND_STATUS", "type": "STRING"}, {"name": "L_AGGREGATE_AUCTION_BEGDATE", "type": "DOUBLE"}, {"name": "L_AGGREGATE_AUCTION_ENDDATE", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "EN_DEPOSITCHANGE_RATO1", "type": "DOUBLE"}, {"name": "EN_DEPOSITCHANGE_RATO2", "type": "DOUBLE"}, {"name": "L_MIN_OPEN_AMOUNT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfuturekind_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfuturekind_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfuturekind_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfuturekind_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFUTUREKIND_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFUTUREKIND_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfuturekind_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFUTUREKIND_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_KIND_NO
     , C_MARKET_NO
     , VC_KIND_CODE
     , VC_KIND_NAME
     , L_MARKET_BUY_MAX
     , L_MARKET_SALE_MAX
     , L_BUY_MAX
     , L_SALE_MAX
     , L_MULTIPLICATOR
     , VC_DATECALC_TYPE
     , VC_CONTRACT_RULE
     , VC_TRADE_MONTH
     , C_TYPE
     , C_STOCK_TYPE
     , VC_TARGET_CODE
     , VC_KIND_CLASS
     , C_ISOPENTODAY
     , VC_KIND_GROUP
     , C_KIND_STATUS
     , L_AGGREGATE_AUCTION_BEGDATE
     , L_AGGREGATE_AUCTION_ENDDATE
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , EN_DEPOSITCHANGE_RATO1
     , EN_DEPOSITCHANGE_RATO2
     , L_MIN_OPEN_AMOUNT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TFUTUREKIND_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFUTUREKIND_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFUTUREKIND_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFUTUREKIND_PFD成功"
      exit 0
   fi
fi
