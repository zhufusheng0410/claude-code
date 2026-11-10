#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TUNCOMPLETELOG_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TUNCOMPLETELOG_PTD_TMP(
  L_TRADE_DATE  DECIMAL(8,0)  COMMENT  '交易日期',
  L_COMPLETE_DATE  DECIMAL(8,0)  COMMENT  '结束��期',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资��单元序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  L_AMOUNT  DECIMAL(18,2)  COMMENT  '数量',
  EN_BANLANCE  DECIMAL(18,2)  COMMENT  '金额',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  VC_REMARK  STRING  COMMENT  '备注',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  L_BUSIN_FLAG  DECIMAL(8,0)  COMMENT  '业务类别',
  EN_BACK_BALANCE  DECIMAL(18,2)  COMMENT  '返款金额',
  L_BACK_DATE  DECIMAL(8,0)  COMMENT  '返款日期',
  C_CASH_TRANSFER  STRING  COMMENT  '是否划转资金',
  L_IN_ASSET_ID  DECIMAL(8,0)  COMMENT  '转入资产单元',
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '序���',
  L_DEAL_SERAIL_NO  DECIMAL(8,0)  COMMENT  '成交序号',
  VC_PURCHASING_CODE  STRING  COMMENT  '收购代码',
  VC_DEAL_NO  STRING  COMMENT  '成���编号',
  VC_REPORT_ID  STRING  COMMENT  '',
  C_PRODUCE_MARK  STRING  COMMENT  '数据来源标志',
  EN_FEE  DECIMAL(18,2)  COMMENT  '费用',
  L_INSTANCE_ID  DECIMAL(12,0)  COMMENT  '实例ID',
  C_BUSIN_CLASS  STRING  COMMENT  '业务类别',
  C_RESTRICTED_FLAG  STRING  COMMENT  ''
)
COMMENT '未完成业务表'
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
              "querySql": ["SELECT  L_TRADE_DATE
                                   , L_COMPLETE_DATE
                                   , L_FUND_ID
                                   , L_ASSET_ID
                                   , L_BASECOMBI_ID
                                   , C_MARKET_NO
                                   , VC_STOCKHOLDER_ID
                                   , VC_SEAT_ID
                                   , VC_INTER_CODE
                                   , C_ENTRUST_DIRECTION
                                   , L_AMOUNT
                                   , EN_BANLANCE
                                   , C_DEAL_FLAG
                                   , VC_REMARK
                                   , C_INVEST_TYPE
                                   , L_BUSIN_FLAG
                                   , EN_BACK_BALANCE
                                   , L_BACK_DATE
                                   , C_CASH_TRANSFER
                                   , L_IN_ASSET_ID
                                   , L_SERIAL_NO
                                   , L_DEAL_SERAIL_NO
                                   , VC_PURCHASING_CODE
                                   , VC_DEAL_NO
                                   , VC_REPORT_ID
                                   , C_PRODUCE_MARK
                                   , EN_FEE
                                   , L_INSTANCE_ID
                                   , C_BUSIN_CLASS
                                   , C_RESTRICTED_FLAG
                                FROM ${o32_src_schema}.TUNCOMPLETELOG"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_TRADE_DATE", "type": "DOUBLE"}, {"name": "L_COMPLETE_DATE", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "L_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BANLANCE", "type": "DOUBLE"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "L_BUSIN_FLAG", "type": "DOUBLE"}, {"name": "EN_BACK_BALANCE", "type": "DOUBLE"}, {"name": "L_BACK_DATE", "type": "DOUBLE"}, {"name": "C_CASH_TRANSFER", "type": "STRING"}, {"name": "L_IN_ASSET_ID", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_DEAL_SERAIL_NO", "type": "DOUBLE"}, {"name": "VC_PURCHASING_CODE", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "VC_REPORT_ID", "type": "STRING"}, {"name": "C_PRODUCE_MARK", "type": "STRING"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "L_INSTANCE_ID", "type": "DOUBLE"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "C_RESTRICTED_FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tuncompletelog_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tuncompletelog_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tuncompletelog_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tuncompletelog_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TUNCOMPLETELOG_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TUNCOMPLETELOG_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tuncompletelog_ptd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TUNCOMPLETELOG_PTD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_TRADE_DATE
     , L_COMPLETE_DATE
     , L_FUND_ID
     , L_ASSET_ID
     , L_BASECOMBI_ID
     , C_MARKET_NO
     , VC_STOCKHOLDER_ID
     , VC_SEAT_ID
     , VC_INTER_CODE
     , C_ENTRUST_DIRECTION
     , L_AMOUNT
     , EN_BANLANCE
     , C_DEAL_FLAG
     , VC_REMARK
     , C_INVEST_TYPE
     , L_BUSIN_FLAG
     , EN_BACK_BALANCE
     , L_BACK_DATE
     , C_CASH_TRANSFER
     , L_IN_ASSET_ID
     , L_SERIAL_NO
     , L_DEAL_SERAIL_NO
     , VC_PURCHASING_CODE
     , VC_DEAL_NO
     , VC_REPORT_ID
     , C_PRODUCE_MARK
     , EN_FEE
     , L_INSTANCE_ID
     , C_BUSIN_CLASS
     , C_RESTRICTED_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TUNCOMPLETELOG_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TUNCOMPLETELOG_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TUNCOMPLETELOG_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TUNCOMPLETELOG_PTD成功"
      exit 0
   fi
fi
