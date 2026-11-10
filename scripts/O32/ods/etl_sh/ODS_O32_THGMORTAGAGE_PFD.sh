#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_THGMORTAGAGE_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_THGMORTAGAGE_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合序号',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_RATIO  DECIMAL(9,4)  COMMENT  '质押比例',
  L_MORTAGAGE_AMOUNT  DECIMAL(16,2)  COMMENT  '质押数量',
  C_MORTAGAGE_SIDE  STRING  COMMENT  '#履约保证提交方',
  C_BAIL_TYPE  STRING  COMMENT  '#抵押物类别',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '#资产单元',
  L_MORTGAGE_DATE  DECIMAL(8,0)  COMMENT  '#提交日期',
  C_STATUS  STRING  COMMENT  '状态',
  C_EFFECT_STATUS  STRING  COMMENT  '是否有效',
  L_LOSE_EFFICACY_DATE  DECIMAL(8,0)  COMMENT  '失效日期',
  EN_ORIGINAL_INTEREST  DECIMAL(17,2)  COMMENT  '',
  EN_ORIGINAL_BALANCE  DECIMAL(17,2)  COMMENT  '',
  EN_MORTGAGE_INTEREST  DECIMAL(17,2)  COMMENT  '',
  EN_MORTGAGE_BALANCE  DECIMAL(17,2)  COMMENT  '',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  L_ARCHIVE_DATE  DECIMAL(8,0)  COMMENT  '',
  EN_MORTAGAGE_BALANCE  DECIMAL(18,2)  COMMENT  ''
)
COMMENT '在途回购质押债券表'
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
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , C_INVEST_TYPE
                                   , VC_INTER_CODE
                                   , EN_RATIO
                                   , L_MORTAGAGE_AMOUNT
                                   , C_MORTAGAGE_SIDE
                                   , C_BAIL_TYPE
                                   , L_ASSET_ID
                                   , L_MORTGAGE_DATE
                                   , C_STATUS
                                   , C_EFFECT_STATUS
                                   , L_LOSE_EFFICACY_DATE
                                   , EN_ORIGINAL_INTEREST
                                   , EN_ORIGINAL_BALANCE
                                   , EN_MORTGAGE_INTEREST
                                   , EN_MORTGAGE_BALANCE
                                   , VC_DEAL_NO
                                   , L_ARCHIVE_DATE
                                   , EN_MORTAGAGE_BALANCE
                                FROM ${o32_src_schema}.THISHGMORTAGAGE"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_RATIO", "type": "DOUBLE"}, {"name": "L_MORTAGAGE_AMOUNT", "type": "DOUBLE"}, {"name": "C_MORTAGAGE_SIDE", "type": "STRING"}, {"name": "C_BAIL_TYPE", "type": "STRING"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_MORTGAGE_DATE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_EFFECT_STATUS", "type": "STRING"}, {"name": "L_LOSE_EFFICACY_DATE", "type": "DOUBLE"}, {"name": "EN_ORIGINAL_INTEREST", "type": "DOUBLE"}, {"name": "EN_ORIGINAL_BALANCE", "type": "DOUBLE"}, {"name": "EN_MORTGAGE_INTEREST", "type": "DOUBLE"}, {"name": "EN_MORTGAGE_BALANCE", "type": "DOUBLE"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "L_ARCHIVE_DATE", "type": "DOUBLE"}, {"name": "EN_MORTAGAGE_BALANCE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_thgmortagage_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_thgmortagage_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_thgmortagage_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_thgmortagage_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_THGMORTAGAGE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_THGMORTAGAGE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_thgmortagage_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_THGMORTAGAGE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DATE
     , L_SERIAL_NO
     , L_FUND_ID
     , L_BASECOMBI_ID
     , C_INVEST_TYPE
     , VC_INTER_CODE
     , EN_RATIO
     , L_MORTAGAGE_AMOUNT
     , C_MORTAGAGE_SIDE
     , C_BAIL_TYPE
     , L_ASSET_ID
     , L_MORTGAGE_DATE
     , C_STATUS
     , C_EFFECT_STATUS
     , L_LOSE_EFFICACY_DATE
     , EN_ORIGINAL_INTEREST
     , EN_ORIGINAL_BALANCE
     , EN_MORTGAGE_INTEREST
     , EN_MORTGAGE_BALANCE
     , VC_DEAL_NO
     , L_ARCHIVE_DATE
     , EN_MORTAGAGE_BALANCE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_THGMORTAGAGE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_THGMORTAGAGE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_THGMORTAGAGE_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_THGMORTAGAGE_PFD成功"
      exit 0
   fi
fi
