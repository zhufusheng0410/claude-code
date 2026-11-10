#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TINTERESTLOG_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TINTERESTLOG_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_OP_DATE  DECIMAL(8,0)  COMMENT  '操作日期',
  L_RECORD_DATE  DECIMAL(8,0)  COMMENT  'dbf库记录日期',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代��',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  L_INTERSET_AMOUNT  DECIMAL(16,0)  COMMENT  '权益数量',
  EN_BUSINESS_PRICE  DECIMAL(16,8)  COMMENT  '权益价格',
  EN_INTEREST_BALANCE  DECIMAL(18,2)  COMMENT  '权益金额',
  C_ENTER_STATUS  STRING  COMMENT  '是��已经入帐',
  VC_REMARKS  STRING  COMMENT  '备注',
  L_BUSIN_FLAG  STRING  COMMENT  '业务标志'
)
COMMENT '权益流水表'
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
                                   , L_OP_DATE
                                   , L_RECORD_DATE
                                   , C_MARKET_NO
                                   , C_ENTRUST_DIRECTION
                                   , VC_INTER_CODE
                                   , VC_STOCKHOLDER_ID
                                   , VC_SEAT_ID
                                   , L_INTERSET_AMOUNT
                                   , EN_BUSINESS_PRICE
                                   , EN_INTEREST_BALANCE
                                   , C_ENTER_STATUS
                                   , VC_REMARKS
                                   , L_BUSIN_FLAG
                                FROM ${o32_src_schema}.THISINTERESTLOG
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_OP_DATE", "type": "DOUBLE"}, {"name": "L_RECORD_DATE", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "L_INTERSET_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BUSINESS_PRICE", "type": "DOUBLE"}, {"name": "EN_INTEREST_BALANCE", "type": "DOUBLE"}, {"name": "C_ENTER_STATUS", "type": "STRING"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "L_BUSIN_FLAG", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tinterestlog_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tinterestlog_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tinterestlog_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tinterestlog_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TINTERESTLOG_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TINTERESTLOG_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tinterestlog_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TINTERESTLOG_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_OP_DATE
     , L_RECORD_DATE
     , C_MARKET_NO
     , C_ENTRUST_DIRECTION
     , VC_INTER_CODE
     , VC_STOCKHOLDER_ID
     , VC_SEAT_ID
     , L_INTERSET_AMOUNT
     , EN_BUSINESS_PRICE
     , EN_INTEREST_BALANCE
     , C_ENTER_STATUS
     , VC_REMARKS
     , L_BUSIN_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TINTERESTLOG_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TINTERESTLOG_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TINTERESTLOG_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TINTERESTLOG_PTD成功"
      exit 0
   fi
fi
