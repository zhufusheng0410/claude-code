#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TRESTRICTEDSTOCK_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TRESTRICTEDSTOCK_PFD_TMP(
  L_UNIT_ID  DECIMAL(10,0)  COMMENT  '投资单元序号',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_RESTRICTED_AMOUNT  DECIMAL(20,4)  COMMENT  '受限股数量',
  C_RESTRICTED_TYPE  STRING  COMMENT  '受限类型',
  L_RSEND_DATE  DECIMAL(8,0)  COMMENT  '受限结束日',
  EN_BUY_BALANCE  DECIMAL(18,2)  COMMENT  '买入金额',
  EN_BUY_FEE  DECIMAL(18,2)  COMMENT  '买入费用',
  L_SALE_AMOUNT  DECIMAL(20,4)  COMMENT  '卖出数量',
  EN_UNTRANSFERED_INVEST  DECIMAL(18,2)  COMMENT  '结转过的期初成本',
  C_LOCKRESTRICTED_TYPE  STRING  COMMENT  '锁定受限类型',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  L_ADJUST_AMOUNT  DECIMAL(20,4)  COMMENT  '调整数量',
  L_STGPLC_FROZEN_AMOUNT  DECIMAL(18,2)  COMMENT  '',
  VC_CUSTOM_RESTRICTED  STRING  COMMENT  '',
  L_FROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  C_RSEND_FLAG  STRING  COMMENT  ''
)
COMMENT '受限股持仓明细表'
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
              "querySql": ["SELECT  L_UNIT_ID
                                   , L_DATE
                                   , L_RESTRICTED_AMOUNT
                                   , C_RESTRICTED_TYPE
                                   , L_RSEND_DATE
                                   , EN_BUY_BALANCE
                                   , EN_BUY_FEE
                                   , L_SALE_AMOUNT
                                   , EN_UNTRANSFERED_INVEST
                                   , C_LOCKRESTRICTED_TYPE
                                   , C_DEAL_FLAG
                                   , L_ADJUST_AMOUNT
                                   , L_STGPLC_FROZEN_AMOUNT
                                   , VC_CUSTOM_RESTRICTED
                                   , L_FROZEN_AMOUNT
                                   , C_RSEND_FLAG
                                FROM ${o32_src_schema}.THISRESTRICTEDSTOCK
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_UNIT_ID", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_RESTRICTED_AMOUNT", "type": "DOUBLE"}, {"name": "C_RESTRICTED_TYPE", "type": "STRING"}, {"name": "L_RSEND_DATE", "type": "DOUBLE"}, {"name": "EN_BUY_BALANCE", "type": "DOUBLE"}, {"name": "EN_BUY_FEE", "type": "DOUBLE"}, {"name": "L_SALE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_UNTRANSFERED_INVEST", "type": "DOUBLE"}, {"name": "C_LOCKRESTRICTED_TYPE", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "L_ADJUST_AMOUNT", "type": "DOUBLE"}, {"name": "L_STGPLC_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "VC_CUSTOM_RESTRICTED", "type": "STRING"}, {"name": "L_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "C_RSEND_FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_trestrictedstock_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_trestrictedstock_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_trestrictedstock_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_trestrictedstock_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TRESTRICTEDSTOCK_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TRESTRICTEDSTOCK_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_trestrictedstock_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TRESTRICTEDSTOCK_PFD PARTITION(P_DT)
SELECT
       L_UNIT_ID
     , L_DATE
     , L_RESTRICTED_AMOUNT
     , C_RESTRICTED_TYPE
     , L_RSEND_DATE
     , EN_BUY_BALANCE
     , EN_BUY_FEE
     , L_SALE_AMOUNT
     , EN_UNTRANSFERED_INVEST
     , C_LOCKRESTRICTED_TYPE
     , C_DEAL_FLAG
     , L_ADJUST_AMOUNT
     , L_STGPLC_FROZEN_AMOUNT
     , VC_CUSTOM_RESTRICTED
     , L_FROZEN_AMOUNT
     , C_RSEND_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TRESTRICTEDSTOCK_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TRESTRICTEDSTOCK_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TRESTRICTEDSTOCK_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TRESTRICTEDSTOCK_PFD成功"
      exit 0
   fi
fi
