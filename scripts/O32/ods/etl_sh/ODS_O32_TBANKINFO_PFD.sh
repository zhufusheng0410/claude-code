#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBANKINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBANKINFO_PFD_TMP(
  L_BANK_NO  DECIMAL(10,0)  COMMENT  '银行序号',
  VC_BANK_NAME  STRING  COMMENT  '银行名称',
  VC_COUNTRY_NO  STRING  COMMENT  '国家',
  C_CUSTODIAN  STRING  COMMENT  '基金托管/代销资格',
  EN_LASTYEAR_CAPITAL  DECIMAL(15,0)  COMMENT  '上年度资本金',
  EN_CAPITAL_RATIO  DECIMAL(7,4)  COMMENT  '资本充足率',
  VC_BALANCE_SETTING  STRING  COMMENT  '资金余额位置',
  VC_EXPORT_NAME  STRING  COMMENT  '交收文件接口名称',
  VC_HOLDING_SETTING  STRING  COMMENT  '持仓核对数据位置',
  VC_BIC_CODE  STRING  COMMENT  'bic代码',
  VC_BANK_NO  STRING  COMMENT  '银行编号',
  EN_CORE_CAPITAL_RATIO  DECIMAL(7,4)  COMMENT  '核心资本充足率',
  L_ISSUER_ID  STRING  COMMENT  '发行人编号',
  EN_LASTYEAR_ASSET  DECIMAL(15,0)  COMMENT  '上一年度总资产',
  C_BANK_TYPE  STRING  COMMENT  '银行分类',
  C_OUTER_APPRAISE  STRING  COMMENT  '外部评级',
  C_INSIDE_APPRAISE  STRING  COMMENT  '内部评级',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  VC_FISP_BANK_NO  STRING  COMMENT  'fisp银行编号',
  C_STATUS  STRING  COMMENT  '同步状态',
  L_HEAD_BANK_NO  DECIMAL(10,0)  COMMENT  ''
)
COMMENT '银行信息'
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
              "querySql": ["SELECT  L_BANK_NO
                                   , VC_BANK_NAME
                                   , VC_COUNTRY_NO
                                   , C_CUSTODIAN
                                   , EN_LASTYEAR_CAPITAL
                                   , EN_CAPITAL_RATIO
                                   , VC_BALANCE_SETTING
                                   , VC_EXPORT_NAME
                                   , VC_HOLDING_SETTING
                                   , VC_BIC_CODE
                                   , VC_BANK_NO
                                   , EN_CORE_CAPITAL_RATIO
                                   , L_ISSUER_ID
                                   , EN_LASTYEAR_ASSET
                                   , C_BANK_TYPE
                                   , C_OUTER_APPRAISE
                                   , C_INSIDE_APPRAISE
                                   , VC_TIMESTAMP
                                   , VC_FISP_BANK_NO
                                   , C_STATUS
                                   , L_HEAD_BANK_NO
                                FROM ${o32_src_schema}.TBANKINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BANK_NO", "type": "DOUBLE"}, {"name": "VC_BANK_NAME", "type": "STRING"}, {"name": "VC_COUNTRY_NO", "type": "STRING"}, {"name": "C_CUSTODIAN", "type": "STRING"}, {"name": "EN_LASTYEAR_CAPITAL", "type": "DOUBLE"}, {"name": "EN_CAPITAL_RATIO", "type": "DOUBLE"}, {"name": "VC_BALANCE_SETTING", "type": "STRING"}, {"name": "VC_EXPORT_NAME", "type": "STRING"}, {"name": "VC_HOLDING_SETTING", "type": "STRING"}, {"name": "VC_BIC_CODE", "type": "STRING"}, {"name": "VC_BANK_NO", "type": "STRING"}, {"name": "EN_CORE_CAPITAL_RATIO", "type": "DOUBLE"}, {"name": "L_ISSUER_ID", "type": "DOUBLE"}, {"name": "EN_LASTYEAR_ASSET", "type": "DOUBLE"}, {"name": "C_BANK_TYPE", "type": "STRING"}, {"name": "C_OUTER_APPRAISE", "type": "STRING"}, {"name": "C_INSIDE_APPRAISE", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "VC_FISP_BANK_NO", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_HEAD_BANK_NO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbankinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbankinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbankinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbankinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBANKINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBANKINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbankinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBANKINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BANK_NO
     , VC_BANK_NAME
     , VC_COUNTRY_NO
     , C_CUSTODIAN
     , EN_LASTYEAR_CAPITAL
     , EN_CAPITAL_RATIO
     , VC_BALANCE_SETTING
     , VC_EXPORT_NAME
     , VC_HOLDING_SETTING
     , VC_BIC_CODE
     , VC_BANK_NO
     , EN_CORE_CAPITAL_RATIO
     , L_ISSUER_ID
     , EN_LASTYEAR_ASSET
     , C_BANK_TYPE
     , C_OUTER_APPRAISE
     , C_INSIDE_APPRAISE
     , VC_TIMESTAMP
     , VC_FISP_BANK_NO
     , C_STATUS
     , L_HEAD_BANK_NO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TBANKINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBANKINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBANKINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBANKINFO_PFD成功"
      exit 0
   fi
fi
