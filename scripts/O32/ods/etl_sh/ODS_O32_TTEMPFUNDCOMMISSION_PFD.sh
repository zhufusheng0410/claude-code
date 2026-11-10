#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTEMPFUNDCOMMISSION_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTEMPFUNDCOMMISSION_PFD_TMP(
  L_DONE_ID  DECIMAL(12,0)  COMMENT  '操作序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  VC_COMPANY_NO  STRING  COMMENT  '所属公司编号',
  EN_BUSINESS_BALANCE  DECIMAL(16,2)  COMMENT  '成交金额',
  EN_COMMISSION  DECIMAL(16,2)  COMMENT  '佣金',
  EN_RATIO  DECIMAL(9,8)  COMMENT  '佣金比例'
)
COMMENT '席位佣金表'
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
              "querySql": ["SELECT  L_DONE_ID
                                   , L_FUND_ID
                                   , VC_COMPANY_NO
                                   , EN_BUSINESS_BALANCE
                                   , EN_COMMISSION
                                   , EN_RATIO
                                FROM ${o32_src_schema}.TTEMPFUNDCOMMISSION"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DONE_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_COMPANY_NO", "type": "STRING"}, {"name": "EN_BUSINESS_BALANCE", "type": "DOUBLE"}, {"name": "EN_COMMISSION", "type": "DOUBLE"}, {"name": "EN_RATIO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_ttempfundcommission_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_ttempfundcommission_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_ttempfundcommission_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_ttempfundcommission_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTEMPFUNDCOMMISSION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTEMPFUNDCOMMISSION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_ttempfundcommission_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTEMPFUNDCOMMISSION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DONE_ID
     , L_FUND_ID
     , VC_COMPANY_NO
     , EN_BUSINESS_BALANCE
     , EN_COMMISSION
     , EN_RATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TTEMPFUNDCOMMISSION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTEMPFUNDCOMMISSION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTEMPFUNDCOMMISSION_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTEMPFUNDCOMMISSION_PFD成功"
      exit 0
   fi
fi
