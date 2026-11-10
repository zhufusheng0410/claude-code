#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TECONTRACTINFO_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TECONTRACTINFO_PTD_TMP(
  C_FUNDCODE  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '',
  C_CONTRACTTYPE  STRING  COMMENT  '',
  C_CONTRACTNO  STRING  COMMENT  '',
  C_CONFIRMSTATUSMANAGER  STRING  COMMENT  '',
  C_CONFIRMSTATUSCUSTOD  STRING  COMMENT  '',
  C_DISTRIBUTORCODE  STRING  COMMENT  '',
  C_FUNDMANAGERCODE  STRING  COMMENT  '',
  C_CUSTODIANCODE  STRING  COMMENT  '',
  C_CUSTNAME  STRING  COMMENT  '',
  C_CUSTTYPE  STRING  COMMENT  '',
  C_IDENTITYTYPE  STRING  COMMENT  '',
  C_IDENTITYNO  STRING  COMMENT  '',
  D_SIGNDATE  STRING  COMMENT  '',
  D_SIGNTIME  STRING  COMMENT  '',
  C_SIGNCHANNEL  STRING  COMMENT  '',
  C_SIGNMACHINE  STRING  COMMENT  '',
  C_NETNO  STRING  COMMENT  '',
  C_NOTESAGENT  STRING  COMMENT  '',
  C_NOTESMANAGER  STRING  COMMENT  '',
  C_NOTESCUSTOD  STRING  COMMENT  '',
  D_DATE  STRING  COMMENT  '',
  D_CDATE  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '',
  D_MODIFYDATECUSTOD  STRING  COMMENT  '',
  L_SERIALNO  DECIMAL(12,0)  COMMENT  '',
  C_POSTZD  STRING  COMMENT  '',
  C_NOTES  STRING  COMMENT  '',
  C_ADDR  STRING  COMMENT  '',
  C_POSTCODE  STRING  COMMENT  '',
  C_EMAIL  STRING  COMMENT  '',
  C_MOBILENO  STRING  COMMENT  '',
  C_TELNO  STRING  COMMENT  '',
  C_CARDNO  STRING  COMMENT  '',
  D_MODIFYDATEMANAGER  STRING  COMMENT  '',
  D_MODIFYDATEAGENT  STRING  COMMENT  '',
  C_ISSIGNRISKBOARD  STRING  COMMENT  '',
  C_ISRISKMATCHING  STRING  COMMENT  '',
  C_RISKABILITYRESULT  STRING  COMMENT  '',
  D_APPENDDATE  STRING  COMMENT  '',
  D_LASTMODIFY  STRING  COMMENT  '',
  C_TRADEACCO  STRING  COMMENT  '',
  C_CONTRACTVERSION  STRING  COMMENT  '',
  C_SIGNTYPE  STRING  COMMENT  '',
  C_RESERVEDFIELD1  STRING  COMMENT  '',
  C_RESERVEDFIELD2  STRING  COMMENT  '',
  C_RESERVEDFIELD3  STRING  COMMENT  '',
  F_RESERVEDFIELD4  DECIMAL(16,2)  COMMENT  '',
  F_RESERVEDFIELD5  DECIMAL(16,2)  COMMENT  '',
  C_SOURCETYPE  STRING  COMMENT  '',
  C_BUSINCODE  STRING  COMMENT  '',
  C_IDCARD18LEN  STRING  COMMENT  ''
)
COMMENT '合同信息表'
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , C_FUNDACCO
                                   , C_CONTRACTTYPE
                                   , C_CONTRACTNO
                                   , C_CONFIRMSTATUSMANAGER
                                   , C_CONFIRMSTATUSCUSTOD
                                   , C_DISTRIBUTORCODE
                                   , C_FUNDMANAGERCODE
                                   , C_CUSTODIANCODE
                                   , C_CUSTNAME
                                   , C_CUSTTYPE
                                   , C_IDENTITYTYPE
                                   , C_IDENTITYNO
                                   , D_SIGNDATE
                                   , D_SIGNTIME
                                   , C_SIGNCHANNEL
                                   , C_SIGNMACHINE
                                   , C_NETNO
                                   , C_NOTESAGENT
                                   , C_NOTESMANAGER
                                   , C_NOTESCUSTOD
                                   , D_DATE
                                   , D_CDATE
                                   , C_MEMO
                                   , D_MODIFYDATECUSTOD
                                   , L_SERIALNO
                                   , C_POSTZD
                                   , C_NOTES
                                   , C_ADDR
                                   , C_POSTCODE
                                   , C_EMAIL
                                   , C_MOBILENO
                                   , C_TELNO
                                   , C_CARDNO
                                   , D_MODIFYDATEMANAGER
                                   , D_MODIFYDATEAGENT
                                   , C_ISSIGNRISKBOARD
                                   , C_ISRISKMATCHING
                                   , C_RISKABILITYRESULT
                                   , D_APPENDDATE
                                   , D_LASTMODIFY
                                   , C_TRADEACCO
                                   , C_CONTRACTVERSION
                                   , C_SIGNTYPE
                                   , C_RESERVEDFIELD1
                                   , C_RESERVEDFIELD2
                                   , C_RESERVEDFIELD3
                                   , F_RESERVEDFIELD4
                                   , F_RESERVEDFIELD5
                                   , C_SOURCETYPE
                                   , C_BUSINCODE
                                   , C_IDCARD18LEN
                                FROM ${hszta_src_schema}.TECONTRACTINFO
                                WHERE D_CDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_CONTRACTTYPE", "type": "STRING"}, {"name": "C_CONTRACTNO", "type": "STRING"}, {"name": "C_CONFIRMSTATUSMANAGER", "type": "STRING"}, {"name": "C_CONFIRMSTATUSCUSTOD", "type": "STRING"}, {"name": "C_DISTRIBUTORCODE", "type": "STRING"}, {"name": "C_FUNDMANAGERCODE", "type": "STRING"}, {"name": "C_CUSTODIANCODE", "type": "STRING"}, {"name": "C_CUSTNAME", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "C_IDENTITYNO", "type": "STRING"}, {"name": "D_SIGNDATE", "type": "STRING"}, {"name": "D_SIGNTIME", "type": "STRING"}, {"name": "C_SIGNCHANNEL", "type": "STRING"}, {"name": "C_SIGNMACHINE", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_NOTESAGENT", "type": "STRING"}, {"name": "C_NOTESMANAGER", "type": "STRING"}, {"name": "C_NOTESCUSTOD", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "D_MODIFYDATECUSTOD", "type": "STRING"}, {"name": "L_SERIALNO", "type": "DOUBLE"}, {"name": "C_POSTZD", "type": "STRING"}, {"name": "C_NOTES", "type": "STRING"}, {"name": "C_ADDR", "type": "STRING"}, {"name": "C_POSTCODE", "type": "STRING"}, {"name": "C_EMAIL", "type": "STRING"}, {"name": "C_MOBILENO", "type": "STRING"}, {"name": "C_TELNO", "type": "STRING"}, {"name": "C_CARDNO", "type": "STRING"}, {"name": "D_MODIFYDATEMANAGER", "type": "STRING"}, {"name": "D_MODIFYDATEAGENT", "type": "STRING"}, {"name": "C_ISSIGNRISKBOARD", "type": "STRING"}, {"name": "C_ISRISKMATCHING", "type": "STRING"}, {"name": "C_RISKABILITYRESULT", "type": "STRING"}, {"name": "D_APPENDDATE", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_CONTRACTVERSION", "type": "STRING"}, {"name": "C_SIGNTYPE", "type": "STRING"}, {"name": "C_RESERVEDFIELD1", "type": "STRING"}, {"name": "C_RESERVEDFIELD2", "type": "STRING"}, {"name": "C_RESERVEDFIELD3", "type": "STRING"}, {"name": "F_RESERVEDFIELD4", "type": "DOUBLE"}, {"name": "F_RESERVEDFIELD5", "type": "DOUBLE"}, {"name": "C_SOURCETYPE", "type": "STRING"}, {"name": "C_BUSINCODE", "type": "STRING"}, {"name": "C_IDCARD18LEN", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tecontractinfo_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tecontractinfo_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tecontractinfo_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tecontractinfo_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TECONTRACTINFO_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TECONTRACTINFO_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tecontractinfo_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TECONTRACTINFO_PTD PARTITION(P_DT)
SELECT
       C_FUNDCODE
     , C_FUNDACCO
     , C_CONTRACTTYPE
     , C_CONTRACTNO
     , C_CONFIRMSTATUSMANAGER
     , C_CONFIRMSTATUSCUSTOD
     , C_DISTRIBUTORCODE
     , C_FUNDMANAGERCODE
     , C_CUSTODIANCODE
     , C_CUSTNAME
     , C_CUSTTYPE
     , C_IDENTITYTYPE
     , C_IDENTITYNO
     , D_SIGNDATE
     , D_SIGNTIME
     , C_SIGNCHANNEL
     , C_SIGNMACHINE
     , C_NETNO
     , C_NOTESAGENT
     , C_NOTESMANAGER
     , C_NOTESCUSTOD
     , D_DATE
     , D_CDATE
     , C_MEMO
     , D_MODIFYDATECUSTOD
     , L_SERIALNO
     , C_POSTZD
     , C_NOTES
     , C_ADDR
     , C_POSTCODE
     , C_EMAIL
     , C_MOBILENO
     , C_TELNO
     , C_CARDNO
     , D_MODIFYDATEMANAGER
     , D_MODIFYDATEAGENT
     , C_ISSIGNRISKBOARD
     , C_ISRISKMATCHING
     , C_RISKABILITYRESULT
     , D_APPENDDATE
     , D_LASTMODIFY
     , C_TRADEACCO
     , C_CONTRACTVERSION
     , C_SIGNTYPE
     , C_RESERVEDFIELD1
     , C_RESERVEDFIELD2
     , C_RESERVEDFIELD3
     , F_RESERVEDFIELD4
     , F_RESERVEDFIELD5
     , C_SOURCETYPE
     , C_BUSINCODE
     , C_IDCARD18LEN
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_CDATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TECONTRACTINFO_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TECONTRACTINFO_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TECONTRACTINFO_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TECONTRACTINFO_PTD成功"
      exit 0
   fi
fi
