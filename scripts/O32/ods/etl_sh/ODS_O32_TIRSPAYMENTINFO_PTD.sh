#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TIRSPAYMENTINFO_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TIRSPAYMENTINFO_PTD_TMP(
  L_CONFIRM_NO  STRING  COMMENT  '确认编号',
  L_DATE  DECIMAL(8,0)  COMMENT  '互换日期',
  C_EXCHANGE_TYPE  STRING  COMMENT  '收付类型',
  L_PAY_DATE  DECIMAL(8,0)  COMMENT  '支付日期',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '开始日期',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '结束日期',
  L_RATE_DATE  DECIMAL(8,0)  COMMENT  '定息日期',
  EN_RATE  DECIMAL(17,16)  COMMENT  '定息利率',
  VC_RATE_TYPE  STRING  COMMENT  '定息系数',
  EN_RATE_SPREADS  DECIMAL(17,16)  COMMENT  '利息利差',
  EN_RATE_TIME  DECIMAL(18,16)  COMMENT  '计息长度',
  C_RATE_TYPE  STRING  COMMENT  '利率类型',
  C_UPDATE  STRING  COMMENT  '更新状态'
)
COMMENT '利率互换支付信息表'
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
              "querySql": ["SELECT  L_CONFIRM_NO
                                   , L_DATE
                                   , C_EXCHANGE_TYPE
                                   , L_PAY_DATE
                                   , L_BEGIN_DATE
                                   , L_END_DATE
                                   , L_RATE_DATE
                                   , EN_RATE
                                   , VC_RATE_TYPE
                                   , EN_RATE_SPREADS
                                   , EN_RATE_TIME
                                   , C_RATE_TYPE
                                   , C_UPDATE
                                FROM ${o32_src_schema}.THISIRSPAYMENTINFO
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_CONFIRM_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "C_EXCHANGE_TYPE", "type": "STRING"}, {"name": "L_PAY_DATE", "type": "DOUBLE"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_RATE_DATE", "type": "DOUBLE"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "VC_RATE_TYPE", "type": "STRING"}, {"name": "EN_RATE_SPREADS", "type": "DOUBLE"}, {"name": "EN_RATE_TIME", "type": "DOUBLE"}, {"name": "C_RATE_TYPE", "type": "STRING"}, {"name": "C_UPDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tirspaymentinfo_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tirspaymentinfo_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tirspaymentinfo_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tirspaymentinfo_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TIRSPAYMENTINFO_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TIRSPAYMENTINFO_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tirspaymentinfo_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TIRSPAYMENTINFO_PTD PARTITION(P_DT)
SELECT
       L_CONFIRM_NO
     , L_DATE
     , C_EXCHANGE_TYPE
     , L_PAY_DATE
     , L_BEGIN_DATE
     , L_END_DATE
     , L_RATE_DATE
     , EN_RATE
     , VC_RATE_TYPE
     , EN_RATE_SPREADS
     , EN_RATE_TIME
     , C_RATE_TYPE
     , C_UPDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TIRSPAYMENTINFO_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TIRSPAYMENTINFO_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TIRSPAYMENTINFO_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TIRSPAYMENTINFO_PTD成功"
      exit 0
   fi
fi
