#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFADATA_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFADATA_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  C_LAYER  STRING  COMMENT  '科目层次',
  L_LAYER_ID  DECIMAL(10,0)  COMMENT  '层次序号',
  VC_FINANCE_SUBJECT  STRING  COMMENT  '财务系统科目编号',
  VC_FINANCE_NAME  STRING  COMMENT  '科目名称',
  EN_FA_VALUE  DECIMAL(18,4)  COMMENT  '财务科目余额',
  C_STOCK_FLAG  STRING  COMMENT  '证券持仓标志',
  C_MARKET_NO  STRING  COMMENT  '市场编号',
  L_STOCK_AMOUNT  DECIMAL(16,2)  COMMENT  '证券数量',
  EN_UNIT_INVEST  DECIMAL(20,8)  COMMENT  '证券单位成本',
  EN_TOTAL_INVEST  DECIMAL(18,4)  COMMENT  '证券持仓成本',
  EN_PRICE  DECIMAL(18,8)  COMMENT  '证券价格',
  EN_STOCK_ASSET  DECIMAL(18,4)  COMMENT  '证券市值',
  EN_BOND_INTEREST  DECIMAL(18,12)  COMMENT  '百元债券��息',
  C_ASSET_CLASS  STRING  COMMENT  '资产类别',
  C_FROZEN_FLAG  STRING  COMMENT  '冻结标志',
  VC_SUMMARY  STRING  COMMENT  '备注',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_VALID_FLAG  STRING  COMMENT  '有效标���**',
  C_DIRECTION  STRING  COMMENT  '方向',
  L_SUBJECT_NO  DECIMAL(10,0)  COMMENT  '系统科目',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  VC_REPORT_CODE  STRING  COMMENT  '申报代码',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_TURNOVER_TYPE  STRING  COMMENT  '流通类型',
  L_BUSINESS_DATE  DECIMAL(8,0)  COMMENT  '业务日期',
  EN_EXCHANGE_PRICE  DECIMAL(16,9)  COMMENT  '汇率',
  EN_FA_VALUE_STANDARD  DECIMAL(18,4)  COMMENT  '财务科目余���_本币',
  EN_UNIT_INVEST_STANDARD  DECIMAL(20,8)  COMMENT  '证券��位成本_本币',
  EN_TOTAL_INVEST_STANDARD  DECIMAL(18,4)  COMMENT  '证券持仓成本_本币',
  EN_PRICE_STANDARD  DECIMAL(18,8)  COMMENT  '证券��格_本币',
  C_POSITION_FLAG  STRING  COMMENT  '多空标志',
  C_RESTRICTED_TYPE  STRING  COMMENT  '受限类型',
  D_DATETIME  STRING  COMMENT  ''
)
COMMENT '财务科目数据'
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
                                   , C_LAYER
                                   , L_LAYER_ID
                                   , VC_FINANCE_SUBJECT
                                   , VC_FINANCE_NAME
                                   , EN_FA_VALUE
                                   , C_STOCK_FLAG
                                   , C_MARKET_NO
                                   , L_STOCK_AMOUNT
                                   , EN_UNIT_INVEST
                                   , EN_TOTAL_INVEST
                                   , EN_PRICE
                                   , EN_STOCK_ASSET
                                   , EN_BOND_INTEREST
                                   , C_ASSET_CLASS
                                   , C_FROZEN_FLAG
                                   , VC_SUMMARY
                                   , VC_INTER_CODE
                                   , C_VALID_FLAG
                                   , C_DIRECTION
                                   , L_SUBJECT_NO
                                   , VC_CURRENCY_NO
                                   , VC_REPORT_CODE
                                   , C_INVEST_TYPE
                                   , C_TURNOVER_TYPE
                                   , L_BUSINESS_DATE
                                   , EN_EXCHANGE_PRICE
                                   , EN_FA_VALUE_STANDARD
                                   , EN_UNIT_INVEST_STANDARD
                                   , EN_TOTAL_INVEST_STANDARD
                                   , EN_PRICE_STANDARD
                                   , C_POSITION_FLAG
                                   , C_RESTRICTED_TYPE
                                   , D_DATETIME
                                FROM ${o32_src_schema}.THISFADATA
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "C_LAYER", "type": "STRING"}, {"name": "L_LAYER_ID", "type": "DOUBLE"}, {"name": "VC_FINANCE_SUBJECT", "type": "STRING"}, {"name": "VC_FINANCE_NAME", "type": "STRING"}, {"name": "EN_FA_VALUE", "type": "DOUBLE"}, {"name": "C_STOCK_FLAG", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "L_STOCK_AMOUNT", "type": "DOUBLE"}, {"name": "EN_UNIT_INVEST", "type": "DOUBLE"}, {"name": "EN_TOTAL_INVEST", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "EN_STOCK_ASSET", "type": "DOUBLE"}, {"name": "EN_BOND_INTEREST", "type": "DOUBLE"}, {"name": "C_ASSET_CLASS", "type": "STRING"}, {"name": "C_FROZEN_FLAG", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_VALID_FLAG", "type": "STRING"}, {"name": "C_DIRECTION", "type": "STRING"}, {"name": "L_SUBJECT_NO", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_TURNOVER_TYPE", "type": "STRING"}, {"name": "L_BUSINESS_DATE", "type": "DOUBLE"}, {"name": "EN_EXCHANGE_PRICE", "type": "DOUBLE"}, {"name": "EN_FA_VALUE_STANDARD", "type": "DOUBLE"}, {"name": "EN_UNIT_INVEST_STANDARD", "type": "DOUBLE"}, {"name": "EN_TOTAL_INVEST_STANDARD", "type": "DOUBLE"}, {"name": "EN_PRICE_STANDARD", "type": "DOUBLE"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "C_RESTRICTED_TYPE", "type": "STRING"}, {"name": "D_DATETIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfadata_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfadata_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfadata_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfadata_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFADATA_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFADATA_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfadata_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFADATA_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , C_LAYER
     , L_LAYER_ID
     , VC_FINANCE_SUBJECT
     , VC_FINANCE_NAME
     , EN_FA_VALUE
     , C_STOCK_FLAG
     , C_MARKET_NO
     , L_STOCK_AMOUNT
     , EN_UNIT_INVEST
     , EN_TOTAL_INVEST
     , EN_PRICE
     , EN_STOCK_ASSET
     , EN_BOND_INTEREST
     , C_ASSET_CLASS
     , C_FROZEN_FLAG
     , VC_SUMMARY
     , VC_INTER_CODE
     , C_VALID_FLAG
     , C_DIRECTION
     , L_SUBJECT_NO
     , VC_CURRENCY_NO
     , VC_REPORT_CODE
     , C_INVEST_TYPE
     , C_TURNOVER_TYPE
     , L_BUSINESS_DATE
     , EN_EXCHANGE_PRICE
     , EN_FA_VALUE_STANDARD
     , EN_UNIT_INVEST_STANDARD
     , EN_TOTAL_INVEST_STANDARD
     , EN_PRICE_STANDARD
     , C_POSITION_FLAG
     , C_RESTRICTED_TYPE
     , D_DATETIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TFADATA_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFADATA_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFADATA_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFADATA_PTD成功"
      exit 0
   fi
fi
