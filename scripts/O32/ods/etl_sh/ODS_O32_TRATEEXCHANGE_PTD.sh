#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TRATEEXCHANGE_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TRATEEXCHANGE_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  C_EXCHANGE_TYPE  STRING  COMMENT  '互换类型',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '起息日',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日',
  L_FIRST_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '首期起息日',
  C_OWNER_RATE_TYPE  STRING  COMMENT  '本方利率类型',
  EN_OWNER_RATE  DECIMAL(9,8)  COMMENT  '本方利率',
  C_OWNER_CALC_METHOD  STRING  COMMENT  '本方计息方法',
  C_OWNER_DAY_TYPE  STRING  COMMENT  '本方计息基准',
  L_OWNER_FIRST_RATE_DATE  DECIMAL(8,0)  COMMENT  '本方首次利率确定日',
  L_OWNER_FIRST_PAY_DATE  DECIMAL(8,0)  COMMENT  '本方首期定期支付日',
  C_OWNER_CALC_DAYS_TYPE  STRING  COMMENT  '本方计息天数调整',
  C_OWNER_PAY_DATE_TYPE  STRING  COMMENT  '本方支付日调整',
  C_OWNER_BAIL_CHANGEFLAG  STRING  COMMENT  '本方保证品变动标识',
  L_OWNER_BAIL_SUBMIT_DATE  DECIMAL(8,0)  COMMENT  '本方保证品提交日',
  C_RIVAL_RATE_TYPE  STRING  COMMENT  '对手方利率类型',
  EN_RIVAL_RATE  DECIMAL(9,8)  COMMENT  '对手方利率',
  C_RIVAL_CALC_METHOD  STRING  COMMENT  '对手方计息方法',
  C_RIVAL_DAY_TYPE  STRING  COMMENT  '对手方计息基准',
  L_RIVAL_FIRST_RATE_DATE  DECIMAL(8,0)  COMMENT  '对手方首次利率确定日',
  L_RIVAL_FIRST_PAY_DATE  DECIMAL(8,0)  COMMENT  '对手方首期定期支付日',
  C_RIVAL_CALC_DAYS_TYPE  STRING  COMMENT  '对手方计息天数调整',
  C_RIVAL_PAY_DATE_TYPE  STRING  COMMENT  '对手方支付日调整',
  C_RIVAL_BAIL_CHANGEFLAG  STRING  COMMENT  '对手方保证品变动标识',
  L_RIVAL_BAIL_SUBMIT_DATE  DECIMAL(8,0)  COMMENT  '对手方保证品提交日',
  VC_LIMIT_TIME  STRING  COMMENT  '期限',
  VC_OWNER_PAY_PERIOD  STRING  COMMENT  '本方支付周期',
  VC_OWNER_RATE_PERIOD  STRING  COMMENT  '本方重置频率',
  VC_RIVAL_PAY_PERIOD  STRING  COMMENT  '对手方支付周期',
  VC_RIVAL_RATE_PERIOD  STRING  COMMENT  '对手方重置频率',
  L_TRADE_DATE  DECIMAL(8,0)  COMMENT  '#交易日期',
  EN_DV01  DECIMAL(18,4)  COMMENT  '',
  EN_IRS_VALUE  DECIMAL(16,2)  COMMENT  '',
  C_IRS_INTERFACE_TYPE  STRING  COMMENT  '',
  VC_IRS_INTER_CODE  STRING  COMMENT  ''
)
COMMENT '＃利率互换指令明细表'
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
                                   , L_DAILY_INSTRUCTION_NO
                                   , L_INDEX_DAILY_MODIFY
                                   , C_EXCHANGE_TYPE
                                   , L_BEGIN_DATE
                                   , L_END_DATE
                                   , L_FIRST_BEGIN_DATE
                                   , C_OWNER_RATE_TYPE
                                   , EN_OWNER_RATE
                                   , C_OWNER_CALC_METHOD
                                   , C_OWNER_DAY_TYPE
                                   , L_OWNER_FIRST_RATE_DATE
                                   , L_OWNER_FIRST_PAY_DATE
                                   , C_OWNER_CALC_DAYS_TYPE
                                   , C_OWNER_PAY_DATE_TYPE
                                   , C_OWNER_BAIL_CHANGEFLAG
                                   , L_OWNER_BAIL_SUBMIT_DATE
                                   , C_RIVAL_RATE_TYPE
                                   , EN_RIVAL_RATE
                                   , C_RIVAL_CALC_METHOD
                                   , C_RIVAL_DAY_TYPE
                                   , L_RIVAL_FIRST_RATE_DATE
                                   , L_RIVAL_FIRST_PAY_DATE
                                   , C_RIVAL_CALC_DAYS_TYPE
                                   , C_RIVAL_PAY_DATE_TYPE
                                   , C_RIVAL_BAIL_CHANGEFLAG
                                   , L_RIVAL_BAIL_SUBMIT_DATE
                                   , VC_LIMIT_TIME
                                   , VC_OWNER_PAY_PERIOD
                                   , VC_OWNER_RATE_PERIOD
                                   , VC_RIVAL_PAY_PERIOD
                                   , VC_RIVAL_RATE_PERIOD
                                   , L_TRADE_DATE
                                   , EN_DV01
                                   , EN_IRS_VALUE
                                   , C_IRS_INTERFACE_TYPE
                                   , VC_IRS_INTER_CODE
                                FROM ${o32_src_schema}.THISRATEEXCHANGE
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "C_EXCHANGE_TYPE", "type": "STRING"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_FIRST_BEGIN_DATE", "type": "DOUBLE"}, {"name": "C_OWNER_RATE_TYPE", "type": "STRING"}, {"name": "EN_OWNER_RATE", "type": "DOUBLE"}, {"name": "C_OWNER_CALC_METHOD", "type": "STRING"}, {"name": "C_OWNER_DAY_TYPE", "type": "STRING"}, {"name": "L_OWNER_FIRST_RATE_DATE", "type": "DOUBLE"}, {"name": "L_OWNER_FIRST_PAY_DATE", "type": "DOUBLE"}, {"name": "C_OWNER_CALC_DAYS_TYPE", "type": "STRING"}, {"name": "C_OWNER_PAY_DATE_TYPE", "type": "STRING"}, {"name": "C_OWNER_BAIL_CHANGEFLAG", "type": "STRING"}, {"name": "L_OWNER_BAIL_SUBMIT_DATE", "type": "DOUBLE"}, {"name": "C_RIVAL_RATE_TYPE", "type": "STRING"}, {"name": "EN_RIVAL_RATE", "type": "DOUBLE"}, {"name": "C_RIVAL_CALC_METHOD", "type": "STRING"}, {"name": "C_RIVAL_DAY_TYPE", "type": "STRING"}, {"name": "L_RIVAL_FIRST_RATE_DATE", "type": "DOUBLE"}, {"name": "L_RIVAL_FIRST_PAY_DATE", "type": "DOUBLE"}, {"name": "C_RIVAL_CALC_DAYS_TYPE", "type": "STRING"}, {"name": "C_RIVAL_PAY_DATE_TYPE", "type": "STRING"}, {"name": "C_RIVAL_BAIL_CHANGEFLAG", "type": "STRING"}, {"name": "L_RIVAL_BAIL_SUBMIT_DATE", "type": "DOUBLE"}, {"name": "VC_LIMIT_TIME", "type": "STRING"}, {"name": "VC_OWNER_PAY_PERIOD", "type": "STRING"}, {"name": "VC_OWNER_RATE_PERIOD", "type": "STRING"}, {"name": "VC_RIVAL_PAY_PERIOD", "type": "STRING"}, {"name": "VC_RIVAL_RATE_PERIOD", "type": "STRING"}, {"name": "L_TRADE_DATE", "type": "DOUBLE"}, {"name": "EN_DV01", "type": "DOUBLE"}, {"name": "EN_IRS_VALUE", "type": "DOUBLE"}, {"name": "C_IRS_INTERFACE_TYPE", "type": "STRING"}, {"name": "VC_IRS_INTER_CODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_trateexchange_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_trateexchange_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_trateexchange_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_trateexchange_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TRATEEXCHANGE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TRATEEXCHANGE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_trateexchange_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TRATEEXCHANGE_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , C_EXCHANGE_TYPE
     , L_BEGIN_DATE
     , L_END_DATE
     , L_FIRST_BEGIN_DATE
     , C_OWNER_RATE_TYPE
     , EN_OWNER_RATE
     , C_OWNER_CALC_METHOD
     , C_OWNER_DAY_TYPE
     , L_OWNER_FIRST_RATE_DATE
     , L_OWNER_FIRST_PAY_DATE
     , C_OWNER_CALC_DAYS_TYPE
     , C_OWNER_PAY_DATE_TYPE
     , C_OWNER_BAIL_CHANGEFLAG
     , L_OWNER_BAIL_SUBMIT_DATE
     , C_RIVAL_RATE_TYPE
     , EN_RIVAL_RATE
     , C_RIVAL_CALC_METHOD
     , C_RIVAL_DAY_TYPE
     , L_RIVAL_FIRST_RATE_DATE
     , L_RIVAL_FIRST_PAY_DATE
     , C_RIVAL_CALC_DAYS_TYPE
     , C_RIVAL_PAY_DATE_TYPE
     , C_RIVAL_BAIL_CHANGEFLAG
     , L_RIVAL_BAIL_SUBMIT_DATE
     , VC_LIMIT_TIME
     , VC_OWNER_PAY_PERIOD
     , VC_OWNER_RATE_PERIOD
     , VC_RIVAL_PAY_PERIOD
     , VC_RIVAL_RATE_PERIOD
     , L_TRADE_DATE
     , EN_DV01
     , EN_IRS_VALUE
     , C_IRS_INTERFACE_TYPE
     , VC_IRS_INTER_CODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TRATEEXCHANGE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TRATEEXCHANGE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TRATEEXCHANGE_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TRATEEXCHANGE_PTD成功"
      exit 0
   fi
fi
