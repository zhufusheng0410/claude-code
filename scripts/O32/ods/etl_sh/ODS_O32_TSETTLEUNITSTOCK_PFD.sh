#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSETTLEUNITSTOCK_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSETTLEUNITSTOCK_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_UNIT_ID  DECIMAL(10,0)  COMMENT  '投资单元序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '投资组合序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_POSITION_FLAG  STRING  COMMENT  '持仓多空标志',
  VC_BIND_SEAT  STRING  COMMENT  '托管席位',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  L_CURRENT_AMOUNT  DECIMAL(20,4)  COMMENT  '*当前数量',
  L_BUY_AMOUNT  DECIMAL(20,4)  COMMENT  '*当日买入数量',
  L_SALE_AMOUNT  DECIMAL(20,4)  COMMENT  '*当日卖出数量',
  EN_BUY_BALANCE  DECIMAL(18,2)  COMMENT  '当日买入金额',
  EN_SALE_BALANCE  DECIMAL(18,2)  COMMENT  '当日卖出金额',
  EN_BUY_FEE  DECIMAL(18,2)  COMMENT  '当日买入费用',
  EN_SALE_FEE  DECIMAL(18,2)  COMMENT  '当日卖出费用',
  EN_UNTRANSFERED_INVEST  DECIMAL(18,2)  COMMENT  '结转过的期初成本',
  EN_ACCUMULATE_PROFIT  DECIMAL(18,2)  COMMENT  '累计实现收益',
  EN_TURN_INVEST  DECIMAL(18,2)  COMMENT  '原始的期初成本',
  EN_TURN_PROFIT  DECIMAL(18,2)  COMMENT  '原始结转收益',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  EN_REAL_BUY_FEE  DECIMAL(18,2)  COMMENT  '实际当日买入费用',
  EN_REAL_SALE_FEE  DECIMAL(18,2)  COMMENT  '实际当日卖出费用',
  EN_REAL_COST  DECIMAL(18,2)  COMMENT  '结转后含费用期初成本',
  EN_UNCARRYOVER_REAL_COST  DECIMAL(18,2)  COMMENT  '未结转期初含费用成本',
  EN_NET_GAIN  DECIMAL(18,2)  COMMENT  '结转后扣费用累计收益',
  EN_UNCARRYOVER_NET_GAIN  DECIMAL(18,2)  COMMENT  '未结转扣费用期初收益',
  EN_UNCARRYOVER_DIVIDEND  DECIMAL(18,2)  COMMENT  '未结转期初累计分红金额',
  EN_DIVIDEND  DECIMAL(18,2)  COMMENT  '结转期初累计分红金额'
)
COMMENT '结算币种持仓表'
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
                                   , C_POSITION_FLAG
                                   , VC_BIND_SEAT
                                   , VC_STOCKHOLDER_ID
                                   , VC_INTER_CODE
                                   , C_MARKET_NO
                                   , L_CURRENT_AMOUNT
                                   , L_BUY_AMOUNT
                                   , L_SALE_AMOUNT
                                   , EN_BUY_BALANCE
                                   , EN_SALE_BALANCE
                                   , EN_BUY_FEE
                                   , EN_SALE_FEE
                                   , EN_UNTRANSFERED_INVEST
                                   , EN_ACCUMULATE_PROFIT
                                   , EN_TURN_INVEST
                                   , EN_TURN_PROFIT
                                   , L_ASSET_ID
                                   , EN_REAL_BUY_FEE
                                   , EN_REAL_SALE_FEE
                                   , EN_REAL_COST
                                   , EN_UNCARRYOVER_REAL_COST
                                   , EN_NET_GAIN
                                   , EN_UNCARRYOVER_NET_GAIN
                                   , EN_UNCARRYOVER_DIVIDEND
                                   , EN_DIVIDEND
                                FROM ${o32_src_schema}.TSETTLEUNITSTOCK
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_UNIT_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "L_CURRENT_AMOUNT", "type": "DOUBLE"}, {"name": "L_BUY_AMOUNT", "type": "DOUBLE"}, {"name": "L_SALE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_SALE_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_FEE", "type": "DOUBLE"}, {"name": "EN_SALE_FEE", "type": "DOUBLE"}, {"name": "EN_UNTRANSFERED_INVEST", "type": "DOUBLE"}, {"name": "EN_ACCUMULATE_PROFIT", "type": "DOUBLE"}, {"name": "EN_TURN_INVEST", "type": "DOUBLE"}, {"name": "EN_TURN_PROFIT", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "EN_REAL_BUY_FEE", "type": "DOUBLE"}, {"name": "EN_REAL_SALE_FEE", "type": "DOUBLE"}, {"name": "EN_REAL_COST", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_REAL_COST", "type": "DOUBLE"}, {"name": "EN_NET_GAIN", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_NET_GAIN", "type": "DOUBLE"}, {"name": "EN_UNCARRYOVER_DIVIDEND", "type": "DOUBLE"}, {"name": "EN_DIVIDEND", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tsettleunitstock_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tsettleunitstock_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tsettleunitstock_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tsettleunitstock_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSETTLEUNITSTOCK_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSETTLEUNITSTOCK_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tsettleunitstock_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSETTLEUNITSTOCK_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , L_UNIT_ID
     , L_BASECOMBI_ID
     , L_FUND_ID
     , C_INVEST_TYPE
     , C_POSITION_FLAG
     , VC_BIND_SEAT
     , VC_STOCKHOLDER_ID
     , VC_INTER_CODE
     , C_MARKET_NO
     , L_CURRENT_AMOUNT
     , L_BUY_AMOUNT
     , L_SALE_AMOUNT
     , EN_BUY_BALANCE
     , EN_SALE_BALANCE
     , EN_BUY_FEE
     , EN_SALE_FEE
     , EN_UNTRANSFERED_INVEST
     , EN_ACCUMULATE_PROFIT
     , EN_TURN_INVEST
     , EN_TURN_PROFIT
     , L_ASSET_ID
     , EN_REAL_BUY_FEE
     , EN_REAL_SALE_FEE
     , EN_REAL_COST
     , EN_UNCARRYOVER_REAL_COST
     , EN_NET_GAIN
     , EN_UNCARRYOVER_NET_GAIN
     , EN_UNCARRYOVER_DIVIDEND
     , EN_DIVIDEND
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSETTLEUNITSTOCK_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSETTLEUNITSTOCK_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSETTLEUNITSTOCK_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSETTLEUNITSTOCK_PFD成功"
      exit 0
   fi
fi
