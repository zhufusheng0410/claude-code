#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TCLERKLIST_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCLERKLIST_PFD_TMP(
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_CLERKNO  STRING  COMMENT  '',
  L_CLERKLIMITDAYS  DECIMAL(5,0)  COMMENT  '',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  D_BEGINDATE  STRING  COMMENT  '启用日期',
  C_CLERKLIMITUNIT  STRING  COMMENT  '',
  C_POST  STRING  COMMENT  '',
  C_COMPANY  STRING  COMMENT  ''
)
COMMENT '基金公司员工列表'
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDACCO
                                   , C_CLERKNO
                                   , L_CLERKLIMITDAYS
                                   , C_FUNDCODE
                                   , C_AGENCYNO
                                   , C_TRADEACCO
                                   , D_BEGINDATE
                                   , C_CLERKLIMITUNIT
                                   , C_POST
                                   , C_COMPANY
                                FROM ${hsfta_src_schema}.TCLERKLIST"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_CLERKNO", "type": "STRING"}, {"name": "L_CLERKLIMITDAYS", "type": "DOUBLE"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "C_CLERKLIMITUNIT", "type": "STRING"}, {"name": "C_POST", "type": "STRING"}, {"name": "C_COMPANY", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tclerklist_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tclerklist_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tclerklist_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tclerklist_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TCLERKLIST_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TCLERKLIST_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tclerklist_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCLERKLIST_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDACCO
     , C_CLERKNO
     , L_CLERKLIMITDAYS
     , C_FUNDCODE
     , C_AGENCYNO
     , C_TRADEACCO
     , D_BEGINDATE
     , C_CLERKLIMITUNIT
     , C_POST
     , C_COMPANY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCLERKLIST_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCLERKLIST_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TCLERKLIST_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TCLERKLIST_PFD成功"
      exit 0
   fi
fi
