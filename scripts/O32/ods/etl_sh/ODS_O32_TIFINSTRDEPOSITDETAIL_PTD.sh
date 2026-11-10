#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TIFINSTRDEPOSITDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TIFINSTRDEPOSITDETAIL_PTD_TMP(
  VC_ORDER_NO  STRING  COMMENT  '#外部指令号',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_INTER_NO  STRING  COMMENT  '内部合同号',
  VC_ACCOUNT_NO  STRING  COMMENT  '存款帐号',
  VC_ACCOUNT_NAME  STRING  COMMENT  '账户名称',
  VC_PLACE  STRING  COMMENT  '存款地',
  L_BANK  DECIMAL(10,0)  COMMENT  '银行总行',
  VC_MINOR_BANK  STRING  COMMENT  '存款支行',
  VC_DEPOSIT_OWNER  STRING  COMMENT  '存款人',
  EN_RATE  DECIMAL(16,12)  COMMENT  '利率',
  L_LIMIT_TIME  DECIMAL(4,0)  COMMENT  '存款期限',
  VC_REMARK  STRING  COMMENT  '备注',
  L_FUND_ID  STRING  COMMENT  '基金编号',
  L_NOTIFY_DAYS  DECIMAL(4,0)  COMMENT  '通知天数',
  L_DRAW_DATE  DECIMAL(8,0)  COMMENT  '支取日期',
  C_DRAW_TYPE  STRING  COMMENT  '支取类型',
  L_NOTIFY_DATE  DECIMAL(8,0)  COMMENT  '通知日',
  L_DEPOSIT_CONFIRM_NO  DECIMAL(4,0)  COMMENT  '存单确认序号',
  L_CONFIRM_NO  STRING  COMMENT  '确认编号',
  L_INTEREST_START_DATE  DECIMAL(8,0)  COMMENT  '起息日',
  C_AUTO_REDEPOSIT  STRING  COMMENT  '约定转存',
  C_INTEREST_DEPOSIT  STRING  COMMENT  '利息转存',
  VC_RECEIPT_NO  STRING  COMMENT  '存单编号',
  C_INTEREST_PAY_TYPE  STRING  COMMENT  '付息方式',
  C_DEPOSIT_TYPE  STRING  COMMENT  '存款类型',
  VC_PROVINCECODE  STRING  COMMENT  '省份',
  VC_CITYNO  STRING  COMMENT  '城市',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '#组合序号',
  C_ADVANCE_LIMIT_FLAG  STRING  COMMENT  '#提前支取限制',
  C_LIMIT_UNIT  STRING  COMMENT  '#合同期限单位',
  VC_LIST_ID  STRING  COMMENT  '#清单编号'
)
COMMENT '存款指令明细接口表'
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
              "querySql": ["SELECT  VC_ORDER_NO
                                   , L_DATE
                                   , VC_INTER_NO
                                   , VC_ACCOUNT_NO
                                   , VC_ACCOUNT_NAME
                                   , VC_PLACE
                                   , L_BANK
                                   , VC_MINOR_BANK
                                   , VC_DEPOSIT_OWNER
                                   , EN_RATE
                                   , L_LIMIT_TIME
                                   , VC_REMARK
                                   , L_FUND_ID
                                   , L_NOTIFY_DAYS
                                   , L_DRAW_DATE
                                   , C_DRAW_TYPE
                                   , L_NOTIFY_DATE
                                   , L_DEPOSIT_CONFIRM_NO
                                   , L_CONFIRM_NO
                                   , L_INTEREST_START_DATE
                                   , C_AUTO_REDEPOSIT
                                   , C_INTEREST_DEPOSIT
                                   , VC_RECEIPT_NO
                                   , C_INTEREST_PAY_TYPE
                                   , C_DEPOSIT_TYPE
                                   , VC_PROVINCECODE
                                   , VC_CITYNO
                                   , L_BASECOMBI_ID
                                   , C_ADVANCE_LIMIT_FLAG
                                   , C_LIMIT_UNIT
                                   , VC_LIST_ID
                                FROM ${o32_src_schema}.THISIFINSTRDEPOSITDETAIL
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_ORDER_NO", "type": "STRING"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_INTER_NO", "type": "STRING"}, {"name": "VC_ACCOUNT_NO", "type": "STRING"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "VC_PLACE", "type": "STRING"}, {"name": "L_BANK", "type": "DOUBLE"}, {"name": "VC_MINOR_BANK", "type": "STRING"}, {"name": "VC_DEPOSIT_OWNER", "type": "STRING"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "L_LIMIT_TIME", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_NOTIFY_DAYS", "type": "DOUBLE"}, {"name": "L_DRAW_DATE", "type": "DOUBLE"}, {"name": "C_DRAW_TYPE", "type": "STRING"}, {"name": "L_NOTIFY_DATE", "type": "DOUBLE"}, {"name": "L_DEPOSIT_CONFIRM_NO", "type": "DOUBLE"}, {"name": "L_CONFIRM_NO", "type": "DOUBLE"}, {"name": "L_INTEREST_START_DATE", "type": "DOUBLE"}, {"name": "C_AUTO_REDEPOSIT", "type": "STRING"}, {"name": "C_INTEREST_DEPOSIT", "type": "STRING"}, {"name": "VC_RECEIPT_NO", "type": "STRING"}, {"name": "C_INTEREST_PAY_TYPE", "type": "STRING"}, {"name": "C_DEPOSIT_TYPE", "type": "STRING"}, {"name": "VC_PROVINCECODE", "type": "STRING"}, {"name": "VC_CITYNO", "type": "STRING"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_ADVANCE_LIMIT_FLAG", "type": "STRING"}, {"name": "C_LIMIT_UNIT", "type": "STRING"}, {"name": "VC_LIST_ID", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tifinstrdepositdetail_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tifinstrdepositdetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tifinstrdepositdetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tifinstrdepositdetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TIFINSTRDEPOSITDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TIFINSTRDEPOSITDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tifinstrdepositdetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TIFINSTRDEPOSITDETAIL_PTD PARTITION(P_DT)
SELECT
       VC_ORDER_NO
     , L_DATE
     , VC_INTER_NO
     , VC_ACCOUNT_NO
     , VC_ACCOUNT_NAME
     , VC_PLACE
     , L_BANK
     , VC_MINOR_BANK
     , VC_DEPOSIT_OWNER
     , EN_RATE
     , L_LIMIT_TIME
     , VC_REMARK
     , L_FUND_ID
     , L_NOTIFY_DAYS
     , L_DRAW_DATE
     , C_DRAW_TYPE
     , L_NOTIFY_DATE
     , L_DEPOSIT_CONFIRM_NO
     , L_CONFIRM_NO
     , L_INTEREST_START_DATE
     , C_AUTO_REDEPOSIT
     , C_INTEREST_DEPOSIT
     , VC_RECEIPT_NO
     , C_INTEREST_PAY_TYPE
     , C_DEPOSIT_TYPE
     , VC_PROVINCECODE
     , VC_CITYNO
     , L_BASECOMBI_ID
     , C_ADVANCE_LIMIT_FLAG
     , C_LIMIT_UNIT
     , VC_LIST_ID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TIFINSTRDEPOSITDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TIFINSTRDEPOSITDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TIFINSTRDEPOSITDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TIFINSTRDEPOSITDETAIL_PTD成功"
      exit 0
   fi
fi
