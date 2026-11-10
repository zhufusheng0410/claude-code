#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TUNSENDDIVIDEND_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TUNSENDDIVIDEND_PFD_TMP(
  D_REGDATE  STRING  COMMENT  '',
  D_CDATE  STRING  COMMENT  '',
  D_DATE  STRING  COMMENT  '',
  D_LASTDATE  STRING  COMMENT  '',
  C_CSERIALNO  STRING  COMMENT  '',
  C_CSERIALNOTOTAL  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '',
  C_AGENCYNO  STRING  COMMENT  '',
  C_NETNO  STRING  COMMENT  '',
  C_TRADEACCO  STRING  COMMENT  '',
  C_FUNDCODE  STRING  COMMENT  '',
  C_SHARETYPE  STRING  COMMENT  '',
  C_FLAG  STRING  COMMENT  '',
  F_TOTALSHARE  DECIMAL(16,2)  COMMENT  '',
  F_UNITPROFIT  DECIMAL(16,8)  COMMENT  '',
  F_TOTALPROFIT  DECIMAL(16,2)  COMMENT  '',
  F_REALBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_REALSHARES  DECIMAL(16,2)  COMMENT  '',
  F_TAX  DECIMAL(16,2)  COMMENT  '',
  F_FARE  DECIMAL(16,2)  COMMENT  '',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '',
  F_FROZENBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_FROZENSHARES  DECIMAL(16,2)  COMMENT  '',
  F_INCOMETAX  DECIMAL(9,4)  COMMENT  '',
  C_RESERVE  STRING  COMMENT  '',
  C_DELAYCAUSE  STRING  COMMENT  '',
  C_FROZENNO  STRING  COMMENT  '',
  D_SENDDATE  STRING  COMMENT  '',
  F_UNFROZENBLANCE  DECIMAL(16,2)  COMMENT  '',
  F_DEDUCTBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_SECONDACCO  STRING  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  C_SCHEMANO  STRING  COMMENT  '',
  C_CREDITACCOFLAG  STRING  COMMENT  '',
  C_ISFUNDEND  STRING  COMMENT  '',
  D_ORIREGISTERDATE  STRING  COMMENT  '',
  D_ORIREINVESTDATE  STRING  COMMENT  '',
  C_DTLREQUESTNO  STRING  COMMENT  '',
  C_BONUSFLAG  STRING  COMMENT  '',
  D_DTLCYCLEENDDATE  STRING  COMMENT  '',
  D_INCSHAREDATE  STRING  COMMENT  '',
  D_DTLLASTDEDUCTDATE  STRING  COMMENT  '',
  C_ISZSBLACKFLAG  STRING  COMMENT  '',
  C_IS05OR11FLAG  STRING  COMMENT  ''
)
COMMENT '未发放分红明细表'
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
              "querySql": ["SELECT  D_REGDATE
                                   , D_CDATE
                                   , D_DATE
                                   , D_LASTDATE
                                   , C_CSERIALNO
                                   , C_CSERIALNOTOTAL
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_FLAG
                                   , F_TOTALSHARE
                                   , F_UNITPROFIT
                                   , F_TOTALPROFIT
                                   , F_REALBALANCE
                                   , F_REALSHARES
                                   , F_TAX
                                   , F_FARE
                                   , F_NETVALUE
                                   , F_FROZENBALANCE
                                   , F_FROZENSHARES
                                   , F_INCOMETAX
                                   , C_RESERVE
                                   , C_DELAYCAUSE
                                   , C_FROZENNO
                                   , D_SENDDATE
                                   , F_UNFROZENBLANCE
                                   , F_DEDUCTBALANCE
                                   , C_SECONDACCO
                                   , C_SPECIALACCOFLAG
                                   , C_PARTNERID
                                   , C_SCHEMANO
                                   , C_CREDITACCOFLAG
                                   , C_ISFUNDEND
                                   , D_ORIREGISTERDATE
                                   , D_ORIREINVESTDATE
                                   , C_DTLREQUESTNO
                                   , C_BONUSFLAG
                                   , D_DTLCYCLEENDDATE
                                   , D_INCSHAREDATE
                                   , D_DTLLASTDEDUCTDATE
                                   , C_ISZSBLACKFLAG
                                   , C_IS05OR11FLAG
                                FROM ${hszta_src_schema}.TUNSENDDIVIDEND"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_REGDATE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "D_LASTDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_CSERIALNOTOTAL", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "F_TOTALSHARE", "type": "DOUBLE"}, {"name": "F_UNITPROFIT", "type": "DOUBLE"}, {"name": "F_TOTALPROFIT", "type": "DOUBLE"}, {"name": "F_REALBALANCE", "type": "DOUBLE"}, {"name": "F_REALSHARES", "type": "DOUBLE"}, {"name": "F_TAX", "type": "DOUBLE"}, {"name": "F_FARE", "type": "DOUBLE"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_FROZENBALANCE", "type": "DOUBLE"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "F_INCOMETAX", "type": "DOUBLE"}, {"name": "C_RESERVE", "type": "STRING"}, {"name": "C_DELAYCAUSE", "type": "STRING"}, {"name": "C_FROZENNO", "type": "STRING"}, {"name": "D_SENDDATE", "type": "STRING"}, {"name": "F_UNFROZENBLANCE", "type": "DOUBLE"}, {"name": "F_DEDUCTBALANCE", "type": "DOUBLE"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_SCHEMANO", "type": "STRING"}, {"name": "C_CREDITACCOFLAG", "type": "STRING"}, {"name": "C_ISFUNDEND", "type": "STRING"}, {"name": "D_ORIREGISTERDATE", "type": "STRING"}, {"name": "D_ORIREINVESTDATE", "type": "STRING"}, {"name": "C_DTLREQUESTNO", "type": "STRING"}, {"name": "C_BONUSFLAG", "type": "STRING"}, {"name": "D_DTLCYCLEENDDATE", "type": "STRING"}, {"name": "D_INCSHAREDATE", "type": "STRING"}, {"name": "D_DTLLASTDEDUCTDATE", "type": "STRING"}, {"name": "C_ISZSBLACKFLAG", "type": "STRING"}, {"name": "C_IS05OR11FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tunsenddividend_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tunsenddividend_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tunsenddividend_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tunsenddividend_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TUNSENDDIVIDEND_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TUNSENDDIVIDEND_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tunsenddividend_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TUNSENDDIVIDEND_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       D_REGDATE
     , D_CDATE
     , D_DATE
     , D_LASTDATE
     , C_CSERIALNO
     , C_CSERIALNOTOTAL
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , C_FLAG
     , F_TOTALSHARE
     , F_UNITPROFIT
     , F_TOTALPROFIT
     , F_REALBALANCE
     , F_REALSHARES
     , F_TAX
     , F_FARE
     , F_NETVALUE
     , F_FROZENBALANCE
     , F_FROZENSHARES
     , F_INCOMETAX
     , C_RESERVE
     , C_DELAYCAUSE
     , C_FROZENNO
     , D_SENDDATE
     , F_UNFROZENBLANCE
     , F_DEDUCTBALANCE
     , C_SECONDACCO
     , C_SPECIALACCOFLAG
     , C_PARTNERID
     , C_SCHEMANO
     , C_CREDITACCOFLAG
     , C_ISFUNDEND
     , D_ORIREGISTERDATE
     , D_ORIREINVESTDATE
     , C_DTLREQUESTNO
     , C_BONUSFLAG
     , D_DTLCYCLEENDDATE
     , D_INCSHAREDATE
     , D_DTLLASTDEDUCTDATE
     , C_ISZSBLACKFLAG
     , C_IS05OR11FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TUNSENDDIVIDEND_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TUNSENDDIVIDEND_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TUNSENDDIVIDEND_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TUNSENDDIVIDEND_PFD成功"
      exit 0
   fi
fi
