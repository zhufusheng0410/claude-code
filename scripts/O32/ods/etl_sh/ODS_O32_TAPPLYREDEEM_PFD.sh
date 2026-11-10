#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TAPPLYREDEEM_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TAPPLYREDEEM_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_BUSIN_FLAG  STRING  COMMENT  '业务类型',
  L_TRADE_DATE  DECIMAL(8,0)  COMMENT  '交易日期',
  L_COMPLETE_DATE  DECIMAL(8,0)  COMMENT  '资金交收日期',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '序号',
  EN_SHARES  DECIMAL(16,2)  COMMENT  '成交份额',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '成交金额',
  C_SUBJECT_FLAG  STRING  COMMENT  '科目处理标志',
  C_FORZEN_FLAG  STRING  COMMENT  '冻结标志',
  EN_FROZEN_BALANCE  DECIMAL(16,2)  COMMENT  '冻结金额',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  EN_UNIT_DIVIDENDS  DECIMAL(8,4)  COMMENT  '单位分红',
  VC_ORIGINAL_BUSIN_FLAG  STRING  COMMENT  '原业务类型',
  VC_AGENCY  STRING  COMMENT  '销售机构',
  EN_FEE  DECIMAL(16,2)  COMMENT  '费用',
  EN_FEE_JY  DECIMAL(16,2)  COMMENT  '交易费',
  EN_FEE_GH  DECIMAL(16,2)  COMMENT  '过户费',
  EN_FEE_YH  DECIMAL(16,2)  COMMENT  '印花税',
  EN_FEE_HS  DECIMAL(16,2)  COMMENT  '后收费',
  EN_FEE_QT  DECIMAL(16,2)  COMMENT  '其他费用',
  EN_FEE_GJJZC  DECIMAL(16,2)  COMMENT  '归基金资产费用',
  VC_ASSET_NO  STRING  COMMENT  '',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号'
)
COMMENT '开放式基金申购赎回表'
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
                                   , VC_BUSIN_FLAG
                                   , L_TRADE_DATE
                                   , L_COMPLETE_DATE
                                   , L_FUND_ID
                                   , L_SERIAL_NO
                                   , EN_SHARES
                                   , EN_BALANCE
                                   , C_SUBJECT_FLAG
                                   , C_FORZEN_FLAG
                                   , EN_FROZEN_BALANCE
                                   , C_DEAL_FLAG
                                   , VC_CURRENCY_NO
                                   , EN_UNIT_DIVIDENDS
                                   , VC_ORIGINAL_BUSIN_FLAG
                                   , VC_AGENCY
                                   , EN_FEE
                                   , EN_FEE_JY
                                   , EN_FEE_GH
                                   , EN_FEE_YH
                                   , EN_FEE_HS
                                   , EN_FEE_QT
                                   , EN_FEE_GJJZC
                                   , VC_ASSET_NO
                                   , L_ASSET_ID
                                FROM ${o32_src_schema}.TAPPLYREDEEM"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_BUSIN_FLAG", "type": "STRING"}, {"name": "L_TRADE_DATE", "type": "DOUBLE"}, {"name": "L_COMPLETE_DATE", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "EN_SHARES", "type": "DOUBLE"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "C_SUBJECT_FLAG", "type": "STRING"}, {"name": "C_FORZEN_FLAG", "type": "STRING"}, {"name": "EN_FROZEN_BALANCE", "type": "DOUBLE"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "EN_UNIT_DIVIDENDS", "type": "DOUBLE"}, {"name": "VC_ORIGINAL_BUSIN_FLAG", "type": "STRING"}, {"name": "VC_AGENCY", "type": "STRING"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "EN_FEE_JY", "type": "DOUBLE"}, {"name": "EN_FEE_GH", "type": "DOUBLE"}, {"name": "EN_FEE_YH", "type": "DOUBLE"}, {"name": "EN_FEE_HS", "type": "DOUBLE"}, {"name": "EN_FEE_QT", "type": "DOUBLE"}, {"name": "EN_FEE_GJJZC", "type": "DOUBLE"}, {"name": "VC_ASSET_NO", "type": "STRING"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tapplyredeem_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tapplyredeem_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tapplyredeem_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tapplyredeem_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TAPPLYREDEEM_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TAPPLYREDEEM_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tapplyredeem_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TAPPLYREDEEM_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DATE
     , VC_BUSIN_FLAG
     , L_TRADE_DATE
     , L_COMPLETE_DATE
     , L_FUND_ID
     , L_SERIAL_NO
     , EN_SHARES
     , EN_BALANCE
     , C_SUBJECT_FLAG
     , C_FORZEN_FLAG
     , EN_FROZEN_BALANCE
     , C_DEAL_FLAG
     , VC_CURRENCY_NO
     , EN_UNIT_DIVIDENDS
     , VC_ORIGINAL_BUSIN_FLAG
     , VC_AGENCY
     , EN_FEE
     , EN_FEE_JY
     , EN_FEE_GH
     , EN_FEE_YH
     , EN_FEE_HS
     , EN_FEE_QT
     , EN_FEE_GJJZC
     , VC_ASSET_NO
     , L_ASSET_ID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TAPPLYREDEEM_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TAPPLYREDEEM_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TAPPLYREDEEM_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TAPPLYREDEEM_PFD成功"
      exit 0
   fi
fi
