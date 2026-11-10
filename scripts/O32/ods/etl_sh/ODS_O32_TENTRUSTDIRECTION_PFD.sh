#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTION_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTION_PFD_TMP(
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_ENTRUSTDIR_NAME  STRING  COMMENT  '委托方向名称',
  C_STOCK_DIRECTION  STRING  COMMENT  '证券方向',
  C_FUND_DIRECTION  STRING  COMMENT  '资金方向',
  VC_REPORT_DIRECTION  STRING  COMMENT  '申报方向',
  VC_BUSIN_FLAG  STRING  COMMENT  '业务标志',
  C_TRADE_AMOUNT_TYPE  STRING  COMMENT  '指令数量类型',
  C_TRADE_PRICE_TYPE  STRING  COMMENT  '交易价格类型',
  C_BRANCH_PROP  STRING  COMMENT  '分仓委托属性',
  C_BRANCH_BS  STRING  COMMENT  '分仓买卖方向',
  VC_BUSIN_CLASS  STRING  COMMENT  '业务分类',
  C_PRICEMODE  STRING  COMMENT  '价格模式',
  L_LIST_ORDER  DECIMAL(10,0)  COMMENT  '显示顺序',
  VC_MSGTYPE  STRING  COMMENT  '消息类型',
  VC_CANCEL_MSGTYPE  STRING  COMMENT  '撤单消息类型',
  VC_APPLID  STRING  COMMENT  '应用标识',
  C_SIDE  STRING  COMMENT  '买卖方向',
  C_PLATFORM_TYPE  STRING  COMMENT  '平台类型',
  VC_BINARY_MSGTYPE  STRING  COMMENT  '',
  VC_BINARY_CANCEL_MSGTYPE  STRING  COMMENT  '',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  C_DEAL_EXECUTE_FLAG  STRING  COMMENT  ''
)
COMMENT '委托方向表'
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
              "querySql": ["SELECT  C_ENTRUST_DIRECTION
                                   , C_MARKET_NO
                                   , VC_ENTRUSTDIR_NAME
                                   , C_STOCK_DIRECTION
                                   , C_FUND_DIRECTION
                                   , VC_REPORT_DIRECTION
                                   , VC_BUSIN_FLAG
                                   , C_TRADE_AMOUNT_TYPE
                                   , C_TRADE_PRICE_TYPE
                                   , C_BRANCH_PROP
                                   , C_BRANCH_BS
                                   , VC_BUSIN_CLASS
                                   , C_PRICEMODE
                                   , L_LIST_ORDER
                                   , VC_MSGTYPE
                                   , VC_CANCEL_MSGTYPE
                                   , VC_APPLID
                                   , C_SIDE
                                   , C_PLATFORM_TYPE
                                   , VC_BINARY_MSGTYPE
                                   , VC_BINARY_CANCEL_MSGTYPE
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , C_DEAL_EXECUTE_FLAG
                                FROM ${o32_src_schema}.TENTRUSTDIRECTION"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_ENTRUSTDIR_NAME", "type": "STRING"}, {"name": "C_STOCK_DIRECTION", "type": "STRING"}, {"name": "C_FUND_DIRECTION", "type": "STRING"}, {"name": "VC_REPORT_DIRECTION", "type": "STRING"}, {"name": "VC_BUSIN_FLAG", "type": "STRING"}, {"name": "C_TRADE_AMOUNT_TYPE", "type": "STRING"}, {"name": "C_TRADE_PRICE_TYPE", "type": "STRING"}, {"name": "C_BRANCH_PROP", "type": "STRING"}, {"name": "C_BRANCH_BS", "type": "STRING"}, {"name": "VC_BUSIN_CLASS", "type": "STRING"}, {"name": "C_PRICEMODE", "type": "STRING"}, {"name": "L_LIST_ORDER", "type": "DOUBLE"}, {"name": "VC_MSGTYPE", "type": "STRING"}, {"name": "VC_CANCEL_MSGTYPE", "type": "STRING"}, {"name": "VC_APPLID", "type": "STRING"}, {"name": "C_SIDE", "type": "STRING"}, {"name": "C_PLATFORM_TYPE", "type": "STRING"}, {"name": "VC_BINARY_MSGTYPE", "type": "STRING"}, {"name": "VC_BINARY_CANCEL_MSGTYPE", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "C_DEAL_EXECUTE_FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tentrustdirection_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tentrustdirection_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tentrustdirection_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tentrustdirection_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TENTRUSTDIRECTION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TENTRUSTDIRECTION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tentrustdirection_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_ENTRUST_DIRECTION
     , C_MARKET_NO
     , VC_ENTRUSTDIR_NAME
     , C_STOCK_DIRECTION
     , C_FUND_DIRECTION
     , VC_REPORT_DIRECTION
     , VC_BUSIN_FLAG
     , C_TRADE_AMOUNT_TYPE
     , C_TRADE_PRICE_TYPE
     , C_BRANCH_PROP
     , C_BRANCH_BS
     , VC_BUSIN_CLASS
     , C_PRICEMODE
     , L_LIST_ORDER
     , VC_MSGTYPE
     , VC_CANCEL_MSGTYPE
     , VC_APPLID
     , C_SIDE
     , C_PLATFORM_TYPE
     , VC_BINARY_MSGTYPE
     , VC_BINARY_CANCEL_MSGTYPE
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , C_DEAL_EXECUTE_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TENTRUSTDIRECTION_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TENTRUSTDIRECTION_PFD成功"
      exit 0
   fi
fi
