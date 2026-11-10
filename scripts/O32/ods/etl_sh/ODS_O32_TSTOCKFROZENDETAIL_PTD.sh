#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTOCKFROZENDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKFROZENDETAIL_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_SERIAL_NO  DECIMAL(12,0)  COMMENT  '流水序号',
  L_OPERATOR_NO  STRING  COMMENT  '操作员代码',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_STOCK_EXPIRE_DATE  DECIMAL(8,0)  COMMENT  '到期日',
  L_STOCK_CANCEL_DATE  DECIMAL(8,0)  COMMENT  '手工取消日期',
  C_STOCK_BACK_FLAG  STRING  COMMENT  '冻结解冻类型',
  C_STATUS  STRING  COMMENT  '*状态',
  VC_REMARKS  STRING  COMMENT  '备注',
  C_EXPIRE_POINT  STRING  COMMENT  '到期时点',
  L_BUSIN_NO  DECIMAL(10,0)  COMMENT  '业务序号',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  L_BATCH_NO  DECIMAL(10,0)  COMMENT  '操作批号',
  L_BUSIN_FLAG  DECIMAL(8,0)  COMMENT  '业务类别',
  C_POSITION_FLAG  STRING  COMMENT  '多空标志',
  C_SOURCE_NO  STRING  COMMENT  '',
  L_BAIL_AMOUNT  DECIMAL(20,4)  COMMENT  '*发生数量'
)
COMMENT '证券冻结解冻明细表'
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
                                   , L_SERIAL_NO
                                   , L_OPERATOR_NO
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_STOCKHOLDER_ID
                                   , VC_SEAT_ID
                                   , VC_INTER_CODE
                                   , L_STOCK_EXPIRE_DATE
                                   , L_STOCK_CANCEL_DATE
                                   , C_STOCK_BACK_FLAG
                                   , C_STATUS
                                   , VC_REMARKS
                                   , C_EXPIRE_POINT
                                   , L_BUSIN_NO
                                   , C_INVEST_TYPE
                                   , L_BATCH_NO
                                   , L_BUSIN_FLAG
                                   , C_POSITION_FLAG
                                   , C_SOURCE_NO
                                   , L_BAIL_AMOUNT
                                FROM ${o32_src_schema}.TSTOCKFROZENDETAIL
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_STOCK_EXPIRE_DATE", "type": "DOUBLE"}, {"name": "L_STOCK_CANCEL_DATE", "type": "DOUBLE"}, {"name": "C_STOCK_BACK_FLAG", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "C_EXPIRE_POINT", "type": "STRING"}, {"name": "L_BUSIN_NO", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "L_BATCH_NO", "type": "DOUBLE"}, {"name": "L_BUSIN_FLAG", "type": "DOUBLE"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "C_SOURCE_NO", "type": "STRING"}, {"name": "L_BAIL_AMOUNT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstockfrozendetail_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstockfrozendetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstockfrozendetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstockfrozendetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTOCKFROZENDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTOCKFROZENDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstockfrozendetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKFROZENDETAIL_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_SERIAL_NO
     , L_OPERATOR_NO
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_STOCKHOLDER_ID
     , VC_SEAT_ID
     , VC_INTER_CODE
     , L_STOCK_EXPIRE_DATE
     , L_STOCK_CANCEL_DATE
     , C_STOCK_BACK_FLAG
     , C_STATUS
     , VC_REMARKS
     , C_EXPIRE_POINT
     , L_BUSIN_NO
     , C_INVEST_TYPE
     , L_BATCH_NO
     , L_BUSIN_FLAG
     , C_POSITION_FLAG
     , C_SOURCE_NO
     , L_BAIL_AMOUNT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSTOCKFROZENDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKFROZENDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTOCKFROZENDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTOCKFROZENDETAIL_PTD成功"
      exit 0
   fi
fi
