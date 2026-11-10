#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_THOLDINGDETAIL_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_THOLDINGDETAIL_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '业务日期',
  L_DETAIL_ID  DECIMAL(10,0)  COMMENT  '明细序号',
  L_UNIT_ID  DECIMAL(10,0)  COMMENT  '投资单元序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '投资组合序号',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_BIND_SEAT  STRING  COMMENT  '托管席位',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_POSITION_FLAG  STRING  COMMENT  '持仓多空标志',
  VC_INTER_CODE  STRING  COMMENT  '合约代码',
  L_HOLDING_AMOUNT  DECIMAL(16,2)  COMMENT  '当前持仓数量',
  L_OPEN_DATE  DECIMAL(8,0)  COMMENT  '开仓日期',
  L_OPEN_TIME  DECIMAL(6,0)  COMMENT  '开仓时间',
  EN_OPEN_PRICE  DECIMAL(18,3)  COMMENT  '开仓价格',
  L_OPEN_AMOUNT  DECIMAL(16,2)  COMMENT  '开仓数量',
  EN_CLOSED_PROFIT  DECIMAL(16,2)  COMMENT  '结算和平仓收益',
  EN_TOTAL_FEE  DECIMAL(16,2)  COMMENT  '费用',
  EN_TODAY_CLOSED_PROFIT  DECIMAL(16,2)  COMMENT  '当天平仓收益',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  C_SPECIAL_FLAG  STRING  COMMENT  '特殊业务标识',
  EN_BAILCOMB_AMOUNT  DECIMAL(18,2)  COMMENT  '保证金优惠已组合数量',
  EN_FLOAT_PROFIT  DECIMAL(16,2)  COMMENT  ''
)
COMMENT '持仓明细表'
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
                                   , L_DETAIL_ID
                                   , L_UNIT_ID
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , L_ASSET_ID
                                   , VC_STOCKHOLDER_ID
                                   , VC_BIND_SEAT
                                   , C_INVEST_TYPE
                                   , C_POSITION_FLAG
                                   , VC_INTER_CODE
                                   , L_HOLDING_AMOUNT
                                   , L_OPEN_DATE
                                   , L_OPEN_TIME
                                   , EN_OPEN_PRICE
                                   , L_OPEN_AMOUNT
                                   , EN_CLOSED_PROFIT
                                   , EN_TOTAL_FEE
                                   , EN_TODAY_CLOSED_PROFIT
                                   , VC_DEAL_NO
                                   , C_SPECIAL_FLAG
                                   , EN_BAILCOMB_AMOUNT
                                   , EN_FLOAT_PROFIT
                                FROM ${o32_src_schema}.THISHOLDINGDETAIL
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_DETAIL_ID", "type": "DOUBLE"}, {"name": "L_UNIT_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_HOLDING_AMOUNT", "type": "DOUBLE"}, {"name": "L_OPEN_DATE", "type": "DOUBLE"}, {"name": "L_OPEN_TIME", "type": "DOUBLE"}, {"name": "EN_OPEN_PRICE", "type": "DOUBLE"}, {"name": "L_OPEN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_CLOSED_PROFIT", "type": "DOUBLE"}, {"name": "EN_TOTAL_FEE", "type": "DOUBLE"}, {"name": "EN_TODAY_CLOSED_PROFIT", "type": "DOUBLE"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "C_SPECIAL_FLAG", "type": "STRING"}, {"name": "EN_BAILCOMB_AMOUNT", "type": "DOUBLE"}, {"name": "EN_FLOAT_PROFIT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tholdingdetail_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tholdingdetail_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tholdingdetail_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tholdingdetail_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_THOLDINGDETAIL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_THOLDINGDETAIL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tholdingdetail_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_THOLDINGDETAIL_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , L_DETAIL_ID
     , L_UNIT_ID
     , L_FUND_ID
     , L_BASECOMBI_ID
     , L_ASSET_ID
     , VC_STOCKHOLDER_ID
     , VC_BIND_SEAT
     , C_INVEST_TYPE
     , C_POSITION_FLAG
     , VC_INTER_CODE
     , L_HOLDING_AMOUNT
     , L_OPEN_DATE
     , L_OPEN_TIME
     , EN_OPEN_PRICE
     , L_OPEN_AMOUNT
     , EN_CLOSED_PROFIT
     , EN_TOTAL_FEE
     , EN_TODAY_CLOSED_PROFIT
     , VC_DEAL_NO
     , C_SPECIAL_FLAG
     , EN_BAILCOMB_AMOUNT
     , EN_FLOAT_PROFIT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_THOLDINGDETAIL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_THOLDINGDETAIL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_THOLDINGDETAIL_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_THOLDINGDETAIL_PFD成功"
      exit 0
   fi
fi
