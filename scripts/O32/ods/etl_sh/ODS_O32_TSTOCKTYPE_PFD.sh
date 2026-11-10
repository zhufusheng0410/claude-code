#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTOCKTYPE_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKTYPE_PFD_TMP(
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  C_ASSET_CLASS  STRING  COMMENT  '资产类别',
  VC_STOCKTYPE_NAME  STRING  COMMENT  '证券类别简称',
  C_FUND_FROZEN_CLASS  STRING  COMMENT  '资金冻结方式*',
  L_AMOUNT_PER_HAND  DECIMAL(10,0)  COMMENT  '每手股数＃',
  L_BUY_UNIT  DECIMAL(20,4)  COMMENT  '买入最小单位',
  L_SALE_UNIT  DECIMAL(20,4)  COMMENT  '卖出最小单位',
  EN_FACE_VALUES  DECIMAL(14,8)  COMMENT  '面值',
  EN_MINDIFFERENCE_PRICE  DECIMAL(16,8)  COMMENT  '最小价差',
  VC_ENTRUST_RIGHT  STRING  COMMENT  '委托方向权限',
  VC_ENTRUST_CLASS  STRING  COMMENT  '委托方式权限',
  C_REPORT_UNIT  STRING  COMMENT  '申报单位',
  C_DEFAULT_PRICE  STRING  COMMENT  '价格模式',
  VC_INSTRUCTION_INTERFACE  STRING  COMMENT  '对应指令下达界面',
  L_BUY_MAX  DECIMAL(20,4)  COMMENT  '买入最大数量',
  L_SALE_MAX  DECIMAL(20,4)  COMMENT  '卖出最大数量',
  C_TYPE_UNIT  STRING  COMMENT  '类别单位',
  C_CAN_SPLIT  STRING  COMMENT  '委托数量拆分标志',
  C_UNIT_CONTROL_TYPE  STRING  COMMENT  '＃买卖最小单位控制方式',
  VC_OMGEO_STOCK_TYPE  STRING  COMMENT  'omgeo证券类别',
  VC_PERMIT_INVEST_TYPES  STRING  COMMENT  '允许的投资类型',
  VC_ALERT_STOCK_TYPE  STRING  COMMENT  'alert证券类别',
  VC_SPECIAL_CODE  STRING  COMMENT  '特征附加码',
  EN_MARKET_LIMIT_PRICE  DECIMAL(16,8)  COMMENT  '市场价格上限',
  VC_FOREIGN_STOCK_TYPE  STRING  COMMENT  '境外证券类别',
  VC_FEE_TYPES  STRING  COMMENT  'VC_FEE_TYPES',
  EN_MIN_QUANTITY_UNIT  DECIMAL(20,4)  COMMENT  '最小数量单位',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键'
)
COMMENT '证券类别表'
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
              "querySql": ["SELECT  C_STOCK_TYPE
                                   , C_MARKET_NO
                                   , C_ASSET_CLASS
                                   , VC_STOCKTYPE_NAME
                                   , C_FUND_FROZEN_CLASS
                                   , L_AMOUNT_PER_HAND
                                   , L_BUY_UNIT
                                   , L_SALE_UNIT
                                   , EN_FACE_VALUES
                                   , EN_MINDIFFERENCE_PRICE
                                   , VC_ENTRUST_RIGHT
                                   , VC_ENTRUST_CLASS
                                   , C_REPORT_UNIT
                                   , C_DEFAULT_PRICE
                                   , VC_INSTRUCTION_INTERFACE
                                   , L_BUY_MAX
                                   , L_SALE_MAX
                                   , C_TYPE_UNIT
                                   , C_CAN_SPLIT
                                   , C_UNIT_CONTROL_TYPE
                                   , VC_OMGEO_STOCK_TYPE
                                   , VC_PERMIT_INVEST_TYPES
                                   , VC_ALERT_STOCK_TYPE
                                   , VC_SPECIAL_CODE
                                   , EN_MARKET_LIMIT_PRICE
                                   , VC_FOREIGN_STOCK_TYPE
                                   , VC_FEE_TYPES
                                   , EN_MIN_QUANTITY_UNIT
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                FROM ${o32_src_schema}.TSTOCKTYPE"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "C_ASSET_CLASS", "type": "STRING"}, {"name": "VC_STOCKTYPE_NAME", "type": "STRING"}, {"name": "C_FUND_FROZEN_CLASS", "type": "STRING"}, {"name": "L_AMOUNT_PER_HAND", "type": "DOUBLE"}, {"name": "L_BUY_UNIT", "type": "DOUBLE"}, {"name": "L_SALE_UNIT", "type": "DOUBLE"}, {"name": "EN_FACE_VALUES", "type": "DOUBLE"}, {"name": "EN_MINDIFFERENCE_PRICE", "type": "DOUBLE"}, {"name": "VC_ENTRUST_RIGHT", "type": "STRING"}, {"name": "VC_ENTRUST_CLASS", "type": "STRING"}, {"name": "C_REPORT_UNIT", "type": "STRING"}, {"name": "C_DEFAULT_PRICE", "type": "STRING"}, {"name": "VC_INSTRUCTION_INTERFACE", "type": "STRING"}, {"name": "L_BUY_MAX", "type": "DOUBLE"}, {"name": "L_SALE_MAX", "type": "DOUBLE"}, {"name": "C_TYPE_UNIT", "type": "STRING"}, {"name": "C_CAN_SPLIT", "type": "STRING"}, {"name": "C_UNIT_CONTROL_TYPE", "type": "STRING"}, {"name": "VC_OMGEO_STOCK_TYPE", "type": "STRING"}, {"name": "VC_PERMIT_INVEST_TYPES", "type": "STRING"}, {"name": "VC_ALERT_STOCK_TYPE", "type": "STRING"}, {"name": "VC_SPECIAL_CODE", "type": "STRING"}, {"name": "EN_MARKET_LIMIT_PRICE", "type": "DOUBLE"}, {"name": "VC_FOREIGN_STOCK_TYPE", "type": "STRING"}, {"name": "VC_FEE_TYPES", "type": "STRING"}, {"name": "EN_MIN_QUANTITY_UNIT", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstocktype_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstocktype_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstocktype_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstocktype_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTOCKTYPE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTOCKTYPE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstocktype_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKTYPE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_STOCK_TYPE
     , C_MARKET_NO
     , C_ASSET_CLASS
     , VC_STOCKTYPE_NAME
     , C_FUND_FROZEN_CLASS
     , L_AMOUNT_PER_HAND
     , L_BUY_UNIT
     , L_SALE_UNIT
     , EN_FACE_VALUES
     , EN_MINDIFFERENCE_PRICE
     , VC_ENTRUST_RIGHT
     , VC_ENTRUST_CLASS
     , C_REPORT_UNIT
     , C_DEFAULT_PRICE
     , VC_INSTRUCTION_INTERFACE
     , L_BUY_MAX
     , L_SALE_MAX
     , C_TYPE_UNIT
     , C_CAN_SPLIT
     , C_UNIT_CONTROL_TYPE
     , VC_OMGEO_STOCK_TYPE
     , VC_PERMIT_INVEST_TYPES
     , VC_ALERT_STOCK_TYPE
     , VC_SPECIAL_CODE
     , EN_MARKET_LIMIT_PRICE
     , VC_FOREIGN_STOCK_TYPE
     , VC_FEE_TYPES
     , EN_MIN_QUANTITY_UNIT
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSTOCKTYPE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKTYPE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTOCKTYPE_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTOCKTYPE_PFD成功"
      exit 0
   fi
fi
