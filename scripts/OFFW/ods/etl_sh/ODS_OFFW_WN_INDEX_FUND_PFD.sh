#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_OFFW.ODS_OFFW_WN_INDEX_FUND_PFD_TMP;
CREATE TABLE ODS_XDAY_OFFW.ODS_OFFW_WN_INDEX_FUND_PFD_TMP(
  C_INDEX_FUND_ID  STRING  COMMENT  '基金编号',
  C_INDEX_FUND_TYPE  STRING  COMMENT  '基金类型',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_DESCRIPTION  STRING  COMMENT  '描述',
  F_NO  DECIMAL(16,8)  COMMENT  '',
  C_SITEID  STRING  COMMENT  '',
  C_CLOSE  STRING  COMMENT  '',
  C_STATUS  STRING  COMMENT  '状态',
  C_VISIBLE  STRING  COMMENT  '',
  C_SHORTNAME  STRING  COMMENT  '',
  C_LEVEL_OF_RISK  STRING  COMMENT  '',
  C_URL1  STRING  COMMENT  '',
  C_URL2  STRING  COMMENT  '',
  C_URL3  STRING  COMMENT  '',
  C_SHOW_ASSETVALUE  STRING  COMMENT  '',
  C_FUNDGROUP  STRING  COMMENT  '基金组',
  D_INDEX_SETUPDATE  STRING  COMMENT  '',
  C_DECIMAL_PLACE  STRING  COMMENT  '',
  C_VALUAGR_STATE  STRING  COMMENT  '',
  C_HOT  STRING  COMMENT  '',
  C_INDEX_FUND_SUB_TYPE  STRING  COMMENT  '',
  C_FUNDRATE  STRING  COMMENT  '',
  C_LIMITMONEY  STRING  COMMENT  '',
  C_BUYPOINT  STRING  COMMENT  '',
  C_INDEX_HOT_INC  STRING  COMMENT  '',
  C_FUNDFULLNAME  STRING  COMMENT  '',
  C_PROPERTY  STRING  COMMENT  '',
  C_MANAGERNAME  STRING  COMMENT  '',
  C_TRUSTEENAME  STRING  COMMENT  '',
  C_OPERATIONMODE  STRING  COMMENT  '',
  C_PERFORMANCEBENCHMARK  STRING  COMMENT  '',
  C_INVESTMENTIDEA  STRING  COMMENT  '',
  C_INVESTMENTSCOPE  STRING  COMMENT  '',
  C_INVESTMENTSTRATEGY  STRING  COMMENT  '',
  C_INVESTMENTTARGET  STRING  COMMENT  '',
  C_RISKFEATURE  STRING  COMMENT  '',
  D_ACTIVATION_DATE  STRING  COMMENT  '',
  D_SUBSCRIPTION_BEGIN_DATE  STRING  COMMENT  '',
  D_SUBSCRIPTION_END_DATE  STRING  COMMENT  '',
  C_FUND_NAME_EN  STRING  COMMENT  '',
  C_TAGS  STRING  COMMENT  '',
  C_EXTEND  STRING  COMMENT  '',
  C_BROKER_NAME  STRING  COMMENT  '',
  C_FUND_ASSET_SCALE  STRING  COMMENT  '',
  C_INVESTMENT_PROPORTION  STRING  COMMENT  ''
)
COMMENT '基金经理管理基金'
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
            "username": "${offw_username}",
            "password": "${offw_password}",
            "connection": [{
              "querySql": ["SELECT  C_INDEX_FUND_ID
                                   , C_INDEX_FUND_TYPE
                                   , C_FUNDCODE
                                   , C_DESCRIPTION
                                   , F_NO
                                   , C_SITEID
                                   , C_CLOSE
                                   , C_STATUS
                                   , C_VISIBLE
                                   , C_SHORTNAME
                                   , C_LEVEL_OF_RISK
                                   , C_URL1
                                   , C_URL2
                                   , C_URL3
                                   , C_SHOW_ASSETVALUE
                                   , C_FUNDGROUP
                                   , D_INDEX_SETUPDATE
                                   , C_DECIMAL_PLACE
                                   , C_VALUAGR_STATE
                                   , C_HOT
                                   , C_INDEX_FUND_SUB_TYPE
                                   , C_FUNDRATE
                                   , C_LIMITMONEY
                                   , C_BUYPOINT
                                   , C_INDEX_HOT_INC
                                   , C_FUNDFULLNAME
                                   , C_PROPERTY
                                   , C_MANAGERNAME
                                   , C_TRUSTEENAME
                                   , C_OPERATIONMODE
                                   , C_PERFORMANCEBENCHMARK
                                   , C_INVESTMENTIDEA
                                   , C_INVESTMENTSCOPE
                                   , C_INVESTMENTSTRATEGY
                                   , C_INVESTMENTTARGET
                                   , C_RISKFEATURE
                                   , D_ACTIVATION_DATE
                                   , D_SUBSCRIPTION_BEGIN_DATE
                                   , D_SUBSCRIPTION_END_DATE
                                   , C_FUND_NAME_EN
                                   , C_TAGS
                                   , C_EXTEND
                                   , C_BROKER_NAME
                                   , C_FUND_ASSET_SCALE
                                   , C_INVESTMENT_PROPORTION
                                FROM ${offw_src_schema}.WN_INDEX_FUND"],
              "jdbcUrl": ["${offw_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_INDEX_FUND_ID", "type": "STRING"}, {"name": "C_INDEX_FUND_TYPE", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_DESCRIPTION", "type": "STRING"}, {"name": "F_NO", "type": "DOUBLE"}, {"name": "C_SITEID", "type": "STRING"}, {"name": "C_CLOSE", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_VISIBLE", "type": "STRING"}, {"name": "C_SHORTNAME", "type": "STRING"}, {"name": "C_LEVEL_OF_RISK", "type": "STRING"}, {"name": "C_URL1", "type": "STRING"}, {"name": "C_URL2", "type": "STRING"}, {"name": "C_URL3", "type": "STRING"}, {"name": "C_SHOW_ASSETVALUE", "type": "STRING"}, {"name": "C_FUNDGROUP", "type": "STRING"}, {"name": "D_INDEX_SETUPDATE", "type": "STRING"}, {"name": "C_DECIMAL_PLACE", "type": "STRING"}, {"name": "C_VALUAGR_STATE", "type": "STRING"}, {"name": "C_HOT", "type": "STRING"}, {"name": "C_INDEX_FUND_SUB_TYPE", "type": "STRING"}, {"name": "C_FUNDRATE", "type": "STRING"}, {"name": "C_LIMITMONEY", "type": "STRING"}, {"name": "C_BUYPOINT", "type": "STRING"}, {"name": "C_INDEX_HOT_INC", "type": "STRING"}, {"name": "C_FUNDFULLNAME", "type": "STRING"}, {"name": "C_PROPERTY", "type": "STRING"}, {"name": "C_MANAGERNAME", "type": "STRING"}, {"name": "C_TRUSTEENAME", "type": "STRING"}, {"name": "C_OPERATIONMODE", "type": "STRING"}, {"name": "C_PERFORMANCEBENCHMARK", "type": "STRING"}, {"name": "C_INVESTMENTIDEA", "type": "STRING"}, {"name": "C_INVESTMENTSCOPE", "type": "STRING"}, {"name": "C_INVESTMENTSTRATEGY", "type": "STRING"}, {"name": "C_INVESTMENTTARGET", "type": "STRING"}, {"name": "C_RISKFEATURE", "type": "STRING"}, {"name": "D_ACTIVATION_DATE", "type": "STRING"}, {"name": "D_SUBSCRIPTION_BEGIN_DATE", "type": "STRING"}, {"name": "D_SUBSCRIPTION_END_DATE", "type": "STRING"}, {"name": "C_FUND_NAME_EN", "type": "STRING"}, {"name": "C_TAGS", "type": "STRING"}, {"name": "C_EXTEND", "type": "STRING"}, {"name": "C_BROKER_NAME", "type": "STRING"}, {"name": "C_FUND_ASSET_SCALE", "type": "STRING"}, {"name": "C_INVESTMENT_PROPORTION", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_offw_wn_index_fund_pfd_tmp",
            "fileType": "text",
            "path": "${offw_path}/ods_offw_wn_index_fund_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_offw_wn_index_fund_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_offw_wn_index_fund_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_OFFW_WN_INDEX_FUND_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_OFFW_WN_INDEX_FUND_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_offw_wn_index_fund_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_OFFW.ODS_OFFW_WN_INDEX_FUND_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_INDEX_FUND_ID
     , C_INDEX_FUND_TYPE
     , C_FUNDCODE
     , C_DESCRIPTION
     , F_NO
     , C_SITEID
     , C_CLOSE
     , C_STATUS
     , C_VISIBLE
     , C_SHORTNAME
     , C_LEVEL_OF_RISK
     , C_URL1
     , C_URL2
     , C_URL3
     , C_SHOW_ASSETVALUE
     , C_FUNDGROUP
     , D_INDEX_SETUPDATE
     , C_DECIMAL_PLACE
     , C_VALUAGR_STATE
     , C_HOT
     , C_INDEX_FUND_SUB_TYPE
     , C_FUNDRATE
     , C_LIMITMONEY
     , C_BUYPOINT
     , C_INDEX_HOT_INC
     , C_FUNDFULLNAME
     , C_PROPERTY
     , C_MANAGERNAME
     , C_TRUSTEENAME
     , C_OPERATIONMODE
     , C_PERFORMANCEBENCHMARK
     , C_INVESTMENTIDEA
     , C_INVESTMENTSCOPE
     , C_INVESTMENTSTRATEGY
     , C_INVESTMENTTARGET
     , C_RISKFEATURE
     , D_ACTIVATION_DATE
     , D_SUBSCRIPTION_BEGIN_DATE
     , D_SUBSCRIPTION_END_DATE
     , C_FUND_NAME_EN
     , C_TAGS
     , C_EXTEND
     , C_BROKER_NAME
     , C_FUND_ASSET_SCALE
     , C_INVESTMENT_PROPORTION
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_OFFW.ODS_OFFW_WN_INDEX_FUND_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_OFFW.ODS_OFFW_WN_INDEX_FUND_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_OFFW_WN_INDEX_FUND_PFD失败"
      exit 1
   else
      echo "插入到ODS_OFFW_WN_INDEX_FUND_PFD成功"
      exit 0
   fi
fi
