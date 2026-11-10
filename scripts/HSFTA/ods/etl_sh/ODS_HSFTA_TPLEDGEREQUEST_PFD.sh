#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TPLEDGEREQUEST_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPLEDGEREQUEST_PFD_TMP(
  C_BUSINFLAG  STRING  COMMENT  '',
  C_ORGANIZATIONCODE  STRING  COMMENT  '',
  C_REQUESTNO  STRING  COMMENT  '',
  C_REQUESTDETAILNO  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '',
  C_AGENCYNO  STRING  COMMENT  '',
  C_NETNO  STRING  COMMENT  '',
  C_TRADEACCO  STRING  COMMENT  '',
  C_SHARETYPE  STRING  COMMENT  '',
  C_FUNDCODE  STRING  COMMENT  '',
  F_SHARES  DECIMAL(16,2)  COMMENT  '',
  F_BALANCE  DECIMAL(16,2)  COMMENT  '',
  D_BEGINDATE  STRING  COMMENT  '',
  D_ENDDATE  STRING  COMMENT  '',
  C_OTHERACCO  STRING  COMMENT  '',
  C_OTHERTRADEACCO  STRING  COMMENT  '',
  C_OTHERAGENCY  STRING  COMMENT  '',
  C_ORIREQUESTNO  STRING  COMMENT  '',
  C_ORIREQUESTDETAILNO  STRING  COMMENT  '',
  C_OTHERNETNO  STRING  COMMENT  '',
  C_CAUSE  STRING  COMMENT  '',
  C_PLEDGETYPE  STRING  COMMENT  '',
  C_UNPLEDGETYPE  STRING  COMMENT  '',
  C_BREAKTYPE  STRING  COMMENT  '',
  C_STATUS  STRING  COMMENT  '',
  D_CDATE  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '',
  D_DATE  STRING  COMMENT  ''
)
COMMENT '销售商质押请求'
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
              "querySql": ["SELECT  C_BUSINFLAG
                                   , C_ORGANIZATIONCODE
                                   , C_REQUESTNO
                                   , C_REQUESTDETAILNO
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_SHARETYPE
                                   , C_FUNDCODE
                                   , F_SHARES
                                   , F_BALANCE
                                   , D_BEGINDATE
                                   , D_ENDDATE
                                   , C_OTHERACCO
                                   , C_OTHERTRADEACCO
                                   , C_OTHERAGENCY
                                   , C_ORIREQUESTNO
                                   , C_ORIREQUESTDETAILNO
                                   , C_OTHERNETNO
                                   , C_CAUSE
                                   , C_PLEDGETYPE
                                   , C_UNPLEDGETYPE
                                   , C_BREAKTYPE
                                   , C_STATUS
                                   , D_CDATE
                                   , C_MEMO
                                   , D_DATE
                                FROM ${hsfta_src_schema}.TPLEDGEREQUEST"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "C_ORGANIZATIONCODE", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "C_REQUESTDETAILNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "F_SHARES", "type": "DOUBLE"}, {"name": "F_BALANCE", "type": "DOUBLE"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "D_ENDDATE", "type": "STRING"}, {"name": "C_OTHERACCO", "type": "STRING"}, {"name": "C_OTHERTRADEACCO", "type": "STRING"}, {"name": "C_OTHERAGENCY", "type": "STRING"}, {"name": "C_ORIREQUESTNO", "type": "STRING"}, {"name": "C_ORIREQUESTDETAILNO", "type": "STRING"}, {"name": "C_OTHERNETNO", "type": "STRING"}, {"name": "C_CAUSE", "type": "STRING"}, {"name": "C_PLEDGETYPE", "type": "STRING"}, {"name": "C_UNPLEDGETYPE", "type": "STRING"}, {"name": "C_BREAKTYPE", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tpledgerequest_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tpledgerequest_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tpledgerequest_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tpledgerequest_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TPLEDGEREQUEST_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TPLEDGEREQUEST_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tpledgerequest_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPLEDGEREQUEST_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_BUSINFLAG
     , C_ORGANIZATIONCODE
     , C_REQUESTNO
     , C_REQUESTDETAILNO
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_SHARETYPE
     , C_FUNDCODE
     , F_SHARES
     , F_BALANCE
     , D_BEGINDATE
     , D_ENDDATE
     , C_OTHERACCO
     , C_OTHERTRADEACCO
     , C_OTHERAGENCY
     , C_ORIREQUESTNO
     , C_ORIREQUESTDETAILNO
     , C_OTHERNETNO
     , C_CAUSE
     , C_PLEDGETYPE
     , C_UNPLEDGETYPE
     , C_BREAKTYPE
     , C_STATUS
     , D_CDATE
     , C_MEMO
     , D_DATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TPLEDGEREQUEST_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPLEDGEREQUEST_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TPLEDGEREQUEST_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TPLEDGEREQUEST_PFD成功"
      exit 0
   fi
fi
