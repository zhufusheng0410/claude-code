#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_FUND_PFD_TMP;
CREATE TABLE ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_FUND_PFD_TMP(
  C_FUND_MANAGER_ID  STRING  COMMENT  '基金经理编号',
  C_INDEX_FUNDCODE  STRING  COMMENT  '基金代码',
  D_BEGIN_DATE  STRING  COMMENT  '任职开始日期',
  D_END_DATE  STRING  COMMENT  '结束日期',
  F_NO  DECIMAL(16,8)  COMMENT  '',
  F_NO1  DECIMAL(16,8)  COMMENT  '',
  C_RR_SINCESTART  STRING  COMMENT  '',
  C_SOURCE  STRING  COMMENT  '',
  D_UPDATE_TIME  STRING  COMMENT  '',
  C_FUND_CODE_SOURCE  STRING  COMMENT  ''
)
COMMENT '网站基金信息'
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
              "querySql": ["SELECT  C_FUND_MANAGER_ID
                                   , C_INDEX_FUNDCODE
                                   , D_BEGIN_DATE
                                   , D_END_DATE
                                   , F_NO
                                   , F_NO1
                                   , C_RR_SINCESTART
                                   , C_SOURCE
                                   , D_UPDATE_TIME
                                   , C_FUND_CODE_SOURCE
                                FROM ${offw_src_schema}.WN_FUND_MANAGER_FUND"],
              "jdbcUrl": ["${offw_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUND_MANAGER_ID", "type": "STRING"}, {"name": "C_INDEX_FUNDCODE", "type": "STRING"}, {"name": "D_BEGIN_DATE", "type": "STRING"}, {"name": "D_END_DATE", "type": "STRING"}, {"name": "F_NO", "type": "DOUBLE"}, {"name": "F_NO1", "type": "DOUBLE"}, {"name": "C_RR_SINCESTART", "type": "STRING"}, {"name": "C_SOURCE", "type": "STRING"}, {"name": "D_UPDATE_TIME", "type": "STRING"}, {"name": "C_FUND_CODE_SOURCE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_offw_wn_fund_manager_fund_pfd_tmp",
            "fileType": "text",
            "path": "${offw_path}/ods_offw_wn_fund_manager_fund_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_offw_wn_fund_manager_fund_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_offw_wn_fund_manager_fund_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_OFFW_WN_FUND_MANAGER_FUND_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_OFFW_WN_FUND_MANAGER_FUND_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_offw_wn_fund_manager_fund_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_FUND_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUND_MANAGER_ID
     , C_INDEX_FUNDCODE
     , D_BEGIN_DATE
     , D_END_DATE
     , F_NO
     , F_NO1
     , C_RR_SINCESTART
     , C_SOURCE
     , D_UPDATE_TIME
     , C_FUND_CODE_SOURCE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_FUND_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_OFFW.ODS_OFFW_WN_FUND_MANAGER_FUND_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_OFFW_WN_FUND_MANAGER_FUND_PFD失败"
      exit 1
   else
      echo "插入到ODS_OFFW_WN_FUND_MANAGER_FUND_PFD成功"
      exit 0
   fi
fi
