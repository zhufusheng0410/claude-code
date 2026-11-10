#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAYRULE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAYRULE_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '',
  C_OPENSTATUS  STRING  COMMENT  '',
  C_CYCLETYPE  STRING  COMMENT  '',
  L_DAYS  STRING  COMMENT  '',
  C_ALLOTMODE  STRING  COMMENT  '',
  L_ALLOTDAYS  DECIMAL(10,0)  COMMENT  '',
  C_REDEEMMODE  STRING  COMMENT  '',
  L_REDEEMDAYS  DECIMAL(10,0)  COMMENT  '',
  C_CALOPENDAYTYPE  STRING  COMMENT  '',
  D_BEGINDATE  STRING  COMMENT  '',
  C_RESTDAYDEALTYPE  STRING  COMMENT  '',
  D_ENDDATE  STRING  COMMENT  '',
  L_MONTHS  STRING  COMMENT  '',
  L_WEEKN  STRING  COMMENT  '',
  L_OFFSET  DECIMAL(2,0)  COMMENT  '',
  C_ENDINCOMEDEALTYPE  STRING  COMMENT  '',
  C_ISINVETRDM  STRING  COMMENT  '',
  C_GETINCOMETYPE  STRING  COMMENT  '',
  F_TOTALINCOME  DECIMAL(16,2)  COMMENT  '',
  C_CALRATIOTYPE  STRING  COMMENT  '',
  F_YEARRATIO  DECIMAL(9,8)  COMMENT  '',
  C_YEARDAYS  STRING  COMMENT  '',
  C_ENDSHAREDEALTYPE  STRING  COMMENT  '',
  C_ROLLFUND  STRING  COMMENT  '',
  D_LASTENDDATE  STRING  COMMENT  '',
  D_DATUMDATE  STRING  COMMENT  '',
  C_FREQUENCYUNIT  STRING  COMMENT  '',
  L_FREQUENCY  DECIMAL(4,0)  COMMENT  '',
  C_INCLUDENEXTSAMEDAY  STRING  COMMENT  '',
  C_OPENDAYZEROTYPE  STRING  COMMENT  '',
  C_ZERORESTDAYDEALTYPE  STRING  COMMENT  '',
  C_FUNDALLOPENDAY  STRING  COMMENT  '',
  C_ISNEEDSPLIT  STRING  COMMENT  '',
  C_PURCHASETNCONFIRMCALINTEREST  STRING  COMMENT  '',
  C_POSTPONEINCYCLE  STRING  COMMENT  '',
  C_ISGETNEXTNWORKDAYS  STRING  COMMENT  '',
  L_NEXTNWORKDAYS  DECIMAL(10,0)  COMMENT  '',
  C_MEMO  STRING  COMMENT  '',
  C_ISCONTINUEOPEN  STRING  COMMENT  '',
  L_OPENDAYS  DECIMAL(10,0)  COMMENT  '',
  C_TEMPOPENFLAG  STRING  COMMENT  '',
  C_BASEONLASTDAY  STRING  COMMENT  '',
  C_ALLOPENDAYRULE  STRING  COMMENT  '',
  C_NATUREWEEKTYPE  STRING  COMMENT  '',
  L_MWEEK  STRING  COMMENT  '',
  L_INTERVALWEEKS  DECIMAL(3,0)  COMMENT  '',
  C_RECWORKDAY  STRING  COMMENT  '',
  C_NOEXISTDAYDEALTYPE  STRING  COMMENT  '',
  C_CENTRALIZECFMMODE  STRING  COMMENT  '',
  C_CALCFMDAYTYPE  STRING  COMMENT  ''
)
COMMENT ''
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
                                   , C_OPENSTATUS
                                   , C_CYCLETYPE
                                   , L_DAYS
                                   , C_ALLOTMODE
                                   , L_ALLOTDAYS
                                   , C_REDEEMMODE
                                   , L_REDEEMDAYS
                                   , C_CALOPENDAYTYPE
                                   , D_BEGINDATE
                                   , C_RESTDAYDEALTYPE
                                   , D_ENDDATE
                                   , L_MONTHS
                                   , L_WEEKN
                                   , L_OFFSET
                                   , C_ENDINCOMEDEALTYPE
                                   , C_ISINVETRDM
                                   , C_GETINCOMETYPE
                                   , F_TOTALINCOME
                                   , C_CALRATIOTYPE
                                   , F_YEARRATIO
                                   , C_YEARDAYS
                                   , C_ENDSHAREDEALTYPE
                                   , C_ROLLFUND
                                   , D_LASTENDDATE
                                   , D_DATUMDATE
                                   , C_FREQUENCYUNIT
                                   , L_FREQUENCY
                                   , C_INCLUDENEXTSAMEDAY
                                   , C_OPENDAYZEROTYPE
                                   , C_ZERORESTDAYDEALTYPE
                                   , C_FUNDALLOPENDAY
                                   , C_ISNEEDSPLIT
                                   , C_PURCHASETNCONFIRMCALINTEREST
                                   , C_POSTPONEINCYCLE
                                   , C_ISGETNEXTNWORKDAYS
                                   , L_NEXTNWORKDAYS
                                   , C_MEMO
                                   , C_ISCONTINUEOPEN
                                   , L_OPENDAYS
                                   , C_TEMPOPENFLAG
                                   , C_BASEONLASTDAY
                                   , C_ALLOPENDAYRULE
                                   , C_NATUREWEEKTYPE
                                   , L_MWEEK
                                   , L_INTERVALWEEKS
                                   , C_RECWORKDAY
                                   , C_NOEXISTDAYDEALTYPE
                                   , C_CENTRALIZECFMMODE
                                   , C_CALCFMDAYTYPE
                                FROM ${hszta_src_schema}.TFUNDOPENDAYRULE"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_OPENSTATUS", "type": "STRING"}, {"name": "C_CYCLETYPE", "type": "STRING"}, {"name": "L_DAYS", "type": "STRING"}, {"name": "C_ALLOTMODE", "type": "STRING"}, {"name": "L_ALLOTDAYS", "type": "DOUBLE"}, {"name": "C_REDEEMMODE", "type": "STRING"}, {"name": "L_REDEEMDAYS", "type": "DOUBLE"}, {"name": "C_CALOPENDAYTYPE", "type": "STRING"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "C_RESTDAYDEALTYPE", "type": "STRING"}, {"name": "D_ENDDATE", "type": "STRING"}, {"name": "L_MONTHS", "type": "STRING"}, {"name": "L_WEEKN", "type": "STRING"}, {"name": "L_OFFSET", "type": "DOUBLE"}, {"name": "C_ENDINCOMEDEALTYPE", "type": "STRING"}, {"name": "C_ISINVETRDM", "type": "STRING"}, {"name": "C_GETINCOMETYPE", "type": "STRING"}, {"name": "F_TOTALINCOME", "type": "DOUBLE"}, {"name": "C_CALRATIOTYPE", "type": "STRING"}, {"name": "F_YEARRATIO", "type": "DOUBLE"}, {"name": "C_YEARDAYS", "type": "STRING"}, {"name": "C_ENDSHAREDEALTYPE", "type": "STRING"}, {"name": "C_ROLLFUND", "type": "STRING"}, {"name": "D_LASTENDDATE", "type": "STRING"}, {"name": "D_DATUMDATE", "type": "STRING"}, {"name": "C_FREQUENCYUNIT", "type": "STRING"}, {"name": "L_FREQUENCY", "type": "DOUBLE"}, {"name": "C_INCLUDENEXTSAMEDAY", "type": "STRING"}, {"name": "C_OPENDAYZEROTYPE", "type": "STRING"}, {"name": "C_ZERORESTDAYDEALTYPE", "type": "STRING"}, {"name": "C_FUNDALLOPENDAY", "type": "STRING"}, {"name": "C_ISNEEDSPLIT", "type": "STRING"}, {"name": "C_PURCHASETNCONFIRMCALINTEREST", "type": "STRING"}, {"name": "C_POSTPONEINCYCLE", "type": "STRING"}, {"name": "C_ISGETNEXTNWORKDAYS", "type": "STRING"}, {"name": "L_NEXTNWORKDAYS", "type": "DOUBLE"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "C_ISCONTINUEOPEN", "type": "STRING"}, {"name": "L_OPENDAYS", "type": "DOUBLE"}, {"name": "C_TEMPOPENFLAG", "type": "STRING"}, {"name": "C_BASEONLASTDAY", "type": "STRING"}, {"name": "C_ALLOPENDAYRULE", "type": "STRING"}, {"name": "C_NATUREWEEKTYPE", "type": "STRING"}, {"name": "L_MWEEK", "type": "STRING"}, {"name": "L_INTERVALWEEKS", "type": "DOUBLE"}, {"name": "C_RECWORKDAY", "type": "STRING"}, {"name": "C_NOEXISTDAYDEALTYPE", "type": "STRING"}, {"name": "C_CENTRALIZECFMMODE", "type": "STRING"}, {"name": "C_CALCFMDAYTYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tfundopendayrule_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tfundopendayrule_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tfundopendayrule_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tfundopendayrule_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TFUNDOPENDAYRULE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TFUNDOPENDAYRULE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tfundopendayrule_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAYRULE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_OPENSTATUS
     , C_CYCLETYPE
     , L_DAYS
     , C_ALLOTMODE
     , L_ALLOTDAYS
     , C_REDEEMMODE
     , L_REDEEMDAYS
     , C_CALOPENDAYTYPE
     , D_BEGINDATE
     , C_RESTDAYDEALTYPE
     , D_ENDDATE
     , L_MONTHS
     , L_WEEKN
     , L_OFFSET
     , C_ENDINCOMEDEALTYPE
     , C_ISINVETRDM
     , C_GETINCOMETYPE
     , F_TOTALINCOME
     , C_CALRATIOTYPE
     , F_YEARRATIO
     , C_YEARDAYS
     , C_ENDSHAREDEALTYPE
     , C_ROLLFUND
     , D_LASTENDDATE
     , D_DATUMDATE
     , C_FREQUENCYUNIT
     , L_FREQUENCY
     , C_INCLUDENEXTSAMEDAY
     , C_OPENDAYZEROTYPE
     , C_ZERORESTDAYDEALTYPE
     , C_FUNDALLOPENDAY
     , C_ISNEEDSPLIT
     , C_PURCHASETNCONFIRMCALINTEREST
     , C_POSTPONEINCYCLE
     , C_ISGETNEXTNWORKDAYS
     , L_NEXTNWORKDAYS
     , C_MEMO
     , C_ISCONTINUEOPEN
     , L_OPENDAYS
     , C_TEMPOPENFLAG
     , C_BASEONLASTDAY
     , C_ALLOPENDAYRULE
     , C_NATUREWEEKTYPE
     , L_MWEEK
     , L_INTERVALWEEKS
     , C_RECWORKDAY
     , C_NOEXISTDAYDEALTYPE
     , C_CENTRALIZECFMMODE
     , C_CALCFMDAYTYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAYRULE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAYRULE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TFUNDOPENDAYRULE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TFUNDOPENDAYRULE_PFD成功"
      exit 0
   fi
fi
