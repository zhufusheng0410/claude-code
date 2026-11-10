#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_THKUNCOMPLETELOG_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_THKUNCOMPLETELOG_PTD_TMP(
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '序号',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_TRADE_DATE  DECIMAL(8,0)  COMMENT  '交易日期',
  L_COMPLETE_DATE  DECIMAL(8,0)  COMMENT  '结束日期',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  VC_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  L_AMOUNT  DECIMAL(18,2)  COMMENT  '数量',
  EN_BANLANCE  DECIMAL(18,2)  COMMENT  '金额',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  VC_REMARK  STRING  COMMENT  '备注',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  L_BUSIN_FLAG  DECIMAL(8,0)  COMMENT  '业务类别',
  VC_REPORT_ID  STRING  COMMENT  '',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  EN_FEE_JY  DECIMAL(12,2)  COMMENT  '交���费',
  EN_FEE_YH  DECIMAL(12,2)  COMMENT  '印花税',
  EN_FEE_GH  DECIMAL(12,2)  COMMENT  '过户费',
  EN_FEE_YJ  DECIMAL(12,2)  COMMENT  '佣金',
  EN_FEE_JS  DECIMAL(12,2)  COMMENT  '经手费',
  EN_FEE_OTHER  DECIMAL(12,2)  COMMENT  '',
  EN_FEE_JS2  DECIMAL(12,2)  COMMENT  '结算费',
  EN_ENTRUST_PRICE  DECIMAL(16,8)  COMMENT  '委托价格',
  EN_OCCUR_BALANCE  DECIMAL(18,2)  COMMENT  '资金发生额',
  EN_TAIL_BALANCE  DECIMAL(18,2)  COMMENT  '尾差',
  L_BUSIN_NO  DECIMAL(10,0)  COMMENT  '业务序号',
  L_AMOUNT_GGT  DECIMAL(18,2)  COMMENT  '',
  EN_BANLANCE_GGT  DECIMAL(18,2)  COMMENT  '',
  EN_FEE_ZG  DECIMAL(12,2)  COMMENT  '证管费',
  L_NETTING_DATE  DECIMAL(8,0)  COMMENT  '',
  C_NETBUY_FLAG  STRING  COMMENT  ''
)
COMMENT '港股通未完成业务表'
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
              "querySql": ["SELECT  L_SERIAL_NO
                                   , L_DATE
                                   , L_TRADE_DATE
                                   , L_COMPLETE_DATE
                                   , L_FUND_ID
                                   , L_ASSET_ID
                                   , L_BASECOMBI_ID
                                   , C_MARKET_NO
                                   , VC_STOCKHOLDER_ID
                                   , VC_SEAT_ID
                                   , VC_INTER_CODE
                                   , VC_ENTRUST_DIRECTION
                                   , L_AMOUNT
                                   , EN_BANLANCE
                                   , C_DEAL_FLAG
                                   , VC_REMARK
                                   , C_INVEST_TYPE
                                   , L_BUSIN_FLAG
                                   , VC_REPORT_ID
                                   , VC_DEAL_NO
                                   , EN_FEE_JY
                                   , EN_FEE_YH
                                   , EN_FEE_GH
                                   , EN_FEE_YJ
                                   , EN_FEE_JS
                                   , EN_FEE_OTHER
                                   , EN_FEE_JS2
                                   , EN_ENTRUST_PRICE
                                   , EN_OCCUR_BALANCE
                                   , EN_TAIL_BALANCE
                                   , L_BUSIN_NO
                                   , L_AMOUNT_GGT
                                   , EN_BANLANCE_GGT
                                   , EN_FEE_ZG
                                   , L_NETTING_DATE
                                   , C_NETBUY_FLAG
                                FROM ${o32_src_schema}.THKUNCOMPLETELOG
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TRADE_DATE", "type": "DOUBLE"}, {"name": "L_COMPLETE_DATE", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "VC_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "L_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BANLANCE", "type": "DOUBLE"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "L_BUSIN_FLAG", "type": "DOUBLE"}, {"name": "VC_REPORT_ID", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "EN_FEE_JY", "type": "DOUBLE"}, {"name": "EN_FEE_YH", "type": "DOUBLE"}, {"name": "EN_FEE_GH", "type": "DOUBLE"}, {"name": "EN_FEE_YJ", "type": "DOUBLE"}, {"name": "EN_FEE_JS", "type": "DOUBLE"}, {"name": "EN_FEE_OTHER", "type": "DOUBLE"}, {"name": "EN_FEE_JS2", "type": "DOUBLE"}, {"name": "EN_ENTRUST_PRICE", "type": "DOUBLE"}, {"name": "EN_OCCUR_BALANCE", "type": "DOUBLE"}, {"name": "EN_TAIL_BALANCE", "type": "DOUBLE"}, {"name": "L_BUSIN_NO", "type": "DOUBLE"}, {"name": "L_AMOUNT_GGT", "type": "DOUBLE"}, {"name": "EN_BANLANCE_GGT", "type": "DOUBLE"}, {"name": "EN_FEE_ZG", "type": "DOUBLE"}, {"name": "L_NETTING_DATE", "type": "DOUBLE"}, {"name": "C_NETBUY_FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_thkuncompletelog_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_thkuncompletelog_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_thkuncompletelog_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_thkuncompletelog_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_THKUNCOMPLETELOG_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_THKUNCOMPLETELOG_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_thkuncompletelog_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_THKUNCOMPLETELOG_PTD PARTITION(P_DT)
SELECT
       L_SERIAL_NO
     , L_DATE
     , L_TRADE_DATE
     , L_COMPLETE_DATE
     , L_FUND_ID
     , L_ASSET_ID
     , L_BASECOMBI_ID
     , C_MARKET_NO
     , VC_STOCKHOLDER_ID
     , VC_SEAT_ID
     , VC_INTER_CODE
     , VC_ENTRUST_DIRECTION
     , L_AMOUNT
     , EN_BANLANCE
     , C_DEAL_FLAG
     , VC_REMARK
     , C_INVEST_TYPE
     , L_BUSIN_FLAG
     , VC_REPORT_ID
     , VC_DEAL_NO
     , EN_FEE_JY
     , EN_FEE_YH
     , EN_FEE_GH
     , EN_FEE_YJ
     , EN_FEE_JS
     , EN_FEE_OTHER
     , EN_FEE_JS2
     , EN_ENTRUST_PRICE
     , EN_OCCUR_BALANCE
     , EN_TAIL_BALANCE
     , L_BUSIN_NO
     , L_AMOUNT_GGT
     , EN_BANLANCE_GGT
     , EN_FEE_ZG
     , L_NETTING_DATE
     , C_NETBUY_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_THKUNCOMPLETELOG_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_THKUNCOMPLETELOG_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_THKUNCOMPLETELOG_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_THKUNCOMPLETELOG_PTD成功"
      exit 0
   fi
fi
