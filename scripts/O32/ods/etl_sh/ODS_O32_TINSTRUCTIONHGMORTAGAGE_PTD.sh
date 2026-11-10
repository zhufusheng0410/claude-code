#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '指令序号',
  L_INDEX_DAILY_MODIFY  DECIMAL(10,0)  COMMENT  '指令修改次序',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合序号',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_RATIO  DECIMAL(9,4)  COMMENT  '质押比例',
  L_MORTAGAGE_AMOUNT  DECIMAL(16,2)  COMMENT  '质押数量',
  L_DEAL_MORTAGAGE_AMOUNT  DECIMAL(10,0)  COMMENT  '成交质押数量',
  C_MORTAGAGE_SIDE  STRING  COMMENT  '#提供方',
  C_BAIL_TYPE  STRING  COMMENT  '#质押物类别',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '#资产单元',
  C_MULTI_INS_RELATE_FLAG  STRING  COMMENT  '指令证券关联标志',
  L_ENTR_MORTAGAGE_AMOUNT  DECIMAL(10,0)  COMMENT  '',
  EN_HG_BALANCE  DECIMAL(16,2)  COMMENT  '',
  C_EFFECT_STATUS  STRING  COMMENT  '',
  C_JUDGE_AVAILABLE  STRING  COMMENT  '判断可用',
  L_OLD_MORTAGAGE_AMOUNT  DECIMAL(16,2)  COMMENT  '',
  L_MORTAGAGE_INDEX  DECIMAL(8,0)  COMMENT  '',
  EN_MORTAGAGE_BALANCE  DECIMAL(18,2)  COMMENT  ''
)
COMMENT '银行间指令质押信息表'
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
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , C_INVEST_TYPE
                                   , VC_INTER_CODE
                                   , EN_RATIO
                                   , L_MORTAGAGE_AMOUNT
                                   , L_DEAL_MORTAGAGE_AMOUNT
                                   , C_MORTAGAGE_SIDE
                                   , C_BAIL_TYPE
                                   , L_ASSET_ID
                                   , C_MULTI_INS_RELATE_FLAG
                                   , L_ENTR_MORTAGAGE_AMOUNT
                                   , EN_HG_BALANCE
                                   , C_EFFECT_STATUS
                                   , C_JUDGE_AVAILABLE
                                   , L_OLD_MORTAGAGE_AMOUNT
                                   , L_MORTAGAGE_INDEX
                                   , EN_MORTAGAGE_BALANCE
                                FROM ${o32_src_schema}.THISINSTRUCTIONHGMORTAGAGE
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_DAILY_MODIFY", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_RATIO", "type": "DOUBLE"}, {"name": "L_MORTAGAGE_AMOUNT", "type": "DOUBLE"}, {"name": "L_DEAL_MORTAGAGE_AMOUNT", "type": "DOUBLE"}, {"name": "C_MORTAGAGE_SIDE", "type": "STRING"}, {"name": "C_BAIL_TYPE", "type": "STRING"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "C_MULTI_INS_RELATE_FLAG", "type": "STRING"}, {"name": "L_ENTR_MORTAGAGE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_HG_BALANCE", "type": "DOUBLE"}, {"name": "C_EFFECT_STATUS", "type": "STRING"}, {"name": "C_JUDGE_AVAILABLE", "type": "STRING"}, {"name": "L_OLD_MORTAGAGE_AMOUNT", "type": "DOUBLE"}, {"name": "L_MORTAGAGE_INDEX", "type": "DOUBLE"}, {"name": "EN_MORTAGAGE_BALANCE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tinstructionhgmortagage_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tinstructionhgmortagage_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tinstructionhgmortagage_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tinstructionhgmortagage_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tinstructionhgmortagage_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_DAILY_INSTRUCTION_NO
     , L_INDEX_DAILY_MODIFY
     , L_FUND_ID
     , L_BASECOMBI_ID
     , C_INVEST_TYPE
     , VC_INTER_CODE
     , EN_RATIO
     , L_MORTAGAGE_AMOUNT
     , L_DEAL_MORTAGAGE_AMOUNT
     , C_MORTAGAGE_SIDE
     , C_BAIL_TYPE
     , L_ASSET_ID
     , C_MULTI_INS_RELATE_FLAG
     , L_ENTR_MORTAGAGE_AMOUNT
     , EN_HG_BALANCE
     , C_EFFECT_STATUS
     , C_JUDGE_AVAILABLE
     , L_OLD_MORTAGAGE_AMOUNT
     , L_MORTAGAGE_INDEX
     , EN_MORTAGAGE_BALANCE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TINSTRUCTIONHGMORTAGAGE_PTD成功"
      exit 0
   fi
fi
