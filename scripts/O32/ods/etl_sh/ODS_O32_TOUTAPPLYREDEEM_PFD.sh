#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TOUTAPPLYREDEEM_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TOUTAPPLYREDEEM_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_INSTRUCTION_NO  DECIMAL(14,0)  COMMENT  '指令序号',
  L_INDEX_MODIFY_INSTRUCTION  DECIMAL(4,0)  COMMENT  '指令修改次序',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_INTER_CODE  STRING  COMMENT  '基金代码',
  C_OPERATION_TYPE  STRING  COMMENT  '业务类别',
  EN_HOLDER_AMOUNT  DECIMAL(14,2)  COMMENT  '持仓数量',
  EN_FUND_NAV  DECIMAL(8,4)  COMMENT  '单位净值',
  EN_AMOUNT  DECIMAL(14,2)  COMMENT  '交易份额',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '交易金额',
  EN_FEE  DECIMAL(16,2)  COMMENT  '交易手续费',
  EN_FEE_RATIO  DECIMAL(9,8)  COMMENT  '交易费率',
  EN_PUNISH_BALANCE  DECIMAL(16,2)  COMMENT  '罚息金额',
  VC_REMARK  STRING  COMMENT  '备注',
  EN_OPEN_FUND_NAV  DECIMAL(8,4)  COMMENT  ''
)
COMMENT '场外开放式基金申购赎回表'
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
                                   , L_INSTRUCTION_NO
                                   , L_INDEX_MODIFY_INSTRUCTION
                                   , L_FUND_ID
                                   , L_ASSET_ID
                                   , L_BASECOMBI_ID
                                   , C_INVEST_TYPE
                                   , VC_INTER_CODE
                                   , C_OPERATION_TYPE
                                   , EN_HOLDER_AMOUNT
                                   , EN_FUND_NAV
                                   , EN_AMOUNT
                                   , EN_BALANCE
                                   , EN_FEE
                                   , EN_FEE_RATIO
                                   , EN_PUNISH_BALANCE
                                   , VC_REMARK
                                   , EN_OPEN_FUND_NAV
                                FROM ${o32_src_schema}.THISOUTAPPLYREDEEM
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "L_INDEX_MODIFY_INSTRUCTION", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_OPERATION_TYPE", "type": "STRING"}, {"name": "EN_HOLDER_AMOUNT", "type": "DOUBLE"}, {"name": "EN_FUND_NAV", "type": "DOUBLE"}, {"name": "EN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "EN_FEE_RATIO", "type": "DOUBLE"}, {"name": "EN_PUNISH_BALANCE", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "EN_OPEN_FUND_NAV", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_toutapplyredeem_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_toutapplyredeem_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_toutapplyredeem_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_toutapplyredeem_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TOUTAPPLYREDEEM_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TOUTAPPLYREDEEM_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_toutapplyredeem_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TOUTAPPLYREDEEM_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , L_INSTRUCTION_NO
     , L_INDEX_MODIFY_INSTRUCTION
     , L_FUND_ID
     , L_ASSET_ID
     , L_BASECOMBI_ID
     , C_INVEST_TYPE
     , VC_INTER_CODE
     , C_OPERATION_TYPE
     , EN_HOLDER_AMOUNT
     , EN_FUND_NAV
     , EN_AMOUNT
     , EN_BALANCE
     , EN_FEE
     , EN_FEE_RATIO
     , EN_PUNISH_BALANCE
     , VC_REMARK
     , EN_OPEN_FUND_NAV
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TOUTAPPLYREDEEM_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TOUTAPPLYREDEEM_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TOUTAPPLYREDEEM_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TOUTAPPLYREDEEM_PFD成功"
      exit 0
   fi
fi
