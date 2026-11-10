#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TCHECKRESULTS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCHECKRESULTS_PFD_TMP(
  D_REQUESTDATE  STRING  COMMENT  '',
  C_AGENCYNO  STRING  COMMENT  '',
  C_NETNO  STRING  COMMENT  '',
  C_REQUESTNO  STRING  COMMENT  '',
  F_FAILEDNUM  DECIMAL(16,2)  COMMENT  '',
  C_STATUS  STRING  COMMENT  '',
  C_CAUSE  STRING  COMMENT  '',
  F_CONFIRMRATIO  DECIMAL(9,8)  COMMENT  '',
  C_FLAG  STRING  COMMENT  '',
  C_NODEALFLAG  STRING  COMMENT  '',
  C_STATFLAG  STRING  COMMENT  '',
  C_IMPROPERREDEEM  STRING  COMMENT  '',
  C_OTHERTRADEACCO  STRING  COMMENT  '',
  F_PRECFMFEE  DECIMAL(16,2)  COMMENT  '',
  F_LASTFEE  DECIMAL(16,2)  COMMENT  '',
  C_ISFIXED  STRING  COMMENT  '',
  F_PRECFMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_PRECFMBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_PRICE  DECIMAL(16,8)  COMMENT  '',
  F_EXTENDSHARES  DECIMAL(16,2)  COMMENT  '',
  F_CONTROLRATIO  DECIMAL(9,8)  COMMENT  '',
  F_AGIO  DECIMAL(5,4)  COMMENT  '',
  F_RELATEDRATIO  DECIMAL(9,8)  COMMENT  '',
  C_CHKMANUALCODE  STRING  COMMENT  '',
  F_INTERBANKRATIO  DECIMAL(9,8)  COMMENT  ''
)
COMMENT '销售商申请检查结果表'
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
              "querySql": ["SELECT  D_REQUESTDATE
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_REQUESTNO
                                   , F_FAILEDNUM
                                   , C_STATUS
                                   , C_CAUSE
                                   , F_CONFIRMRATIO
                                   , C_FLAG
                                   , C_NODEALFLAG
                                   , C_STATFLAG
                                   , C_IMPROPERREDEEM
                                   , C_OTHERTRADEACCO
                                   , F_PRECFMFEE
                                   , F_LASTFEE
                                   , C_ISFIXED
                                   , F_PRECFMSHARES
                                   , F_PRECFMBALANCE
                                   , F_PRICE
                                   , F_EXTENDSHARES
                                   , F_CONTROLRATIO
                                   , F_AGIO
                                   , F_RELATEDRATIO
                                   , C_CHKMANUALCODE
                                   , F_INTERBANKRATIO
                                FROM ${hszta_src_schema}.TCHECKRESULTS"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_REQUESTDATE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "F_FAILEDNUM", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_CAUSE", "type": "STRING"}, {"name": "F_CONFIRMRATIO", "type": "DOUBLE"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "C_NODEALFLAG", "type": "STRING"}, {"name": "C_STATFLAG", "type": "STRING"}, {"name": "C_IMPROPERREDEEM", "type": "STRING"}, {"name": "C_OTHERTRADEACCO", "type": "STRING"}, {"name": "F_PRECFMFEE", "type": "DOUBLE"}, {"name": "F_LASTFEE", "type": "DOUBLE"}, {"name": "C_ISFIXED", "type": "STRING"}, {"name": "F_PRECFMSHARES", "type": "DOUBLE"}, {"name": "F_PRECFMBALANCE", "type": "DOUBLE"}, {"name": "F_PRICE", "type": "DOUBLE"}, {"name": "F_EXTENDSHARES", "type": "DOUBLE"}, {"name": "F_CONTROLRATIO", "type": "DOUBLE"}, {"name": "F_AGIO", "type": "DOUBLE"}, {"name": "F_RELATEDRATIO", "type": "DOUBLE"}, {"name": "C_CHKMANUALCODE", "type": "STRING"}, {"name": "F_INTERBANKRATIO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tcheckresults_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tcheckresults_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tcheckresults_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tcheckresults_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TCHECKRESULTS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TCHECKRESULTS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tcheckresults_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCHECKRESULTS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       D_REQUESTDATE
     , C_AGENCYNO
     , C_NETNO
     , C_REQUESTNO
     , F_FAILEDNUM
     , C_STATUS
     , C_CAUSE
     , F_CONFIRMRATIO
     , C_FLAG
     , C_NODEALFLAG
     , C_STATFLAG
     , C_IMPROPERREDEEM
     , C_OTHERTRADEACCO
     , F_PRECFMFEE
     , F_LASTFEE
     , C_ISFIXED
     , F_PRECFMSHARES
     , F_PRECFMBALANCE
     , F_PRICE
     , F_EXTENDSHARES
     , F_CONTROLRATIO
     , F_AGIO
     , F_RELATEDRATIO
     , C_CHKMANUALCODE
     , F_INTERBANKRATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCHECKRESULTS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCHECKRESULTS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TCHECKRESULTS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TCHECKRESULTS_PFD成功"
      exit 0
   fi
fi
