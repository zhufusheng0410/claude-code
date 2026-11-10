#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAY_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAY_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  D_BEGINDATE  STRING  COMMENT  '开始日期',
  D_ENDDATE  STRING  COMMENT  '结束日期',
  C_OPENSTATUS  STRING  COMMENT  '开放状态',
  C_ALLOTMODE  STRING  COMMENT  '申购方式',
  D_ALLOTCFMDATE  STRING  COMMENT  '申购确认日期',
  C_REDEEMMODE  STRING  COMMENT  '赎回方式',
  D_REDEEMCFMDATE  STRING  COMMENT  '赎回确认日期',
  C_PURCHASEBYOLDCUSTONLY  STRING  COMMENT  '',
  C_ISNEEDSPLIT  STRING  COMMENT  '是否需要拆分',
  C_ONLINEINPUTDATE  STRING  COMMENT  '',
  C_TEMPOPENFLAG  STRING  COMMENT  '',
  C_ISSHORTREGULARFUND  STRING  COMMENT  '',
  C_SHORTREGULARSTATUS  STRING  COMMENT  '',
  C_ISREQDATENETVALUE  STRING  COMMENT  '',
  C_PURCHASETNCONFIRMCALINTEREST  STRING  COMMENT  '',
  C_FUNDALLOPENDAY  STRING  COMMENT  '基金申购开放日期',
  D_IMPORTDATE  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '',
  C_CONCATPROJ  STRING  COMMENT  '',
  C_ORIOPENSTATUS  STRING  COMMENT  '源开放状态'
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
                                   , D_BEGINDATE
                                   , D_ENDDATE
                                   , C_OPENSTATUS
                                   , C_ALLOTMODE
                                   , D_ALLOTCFMDATE
                                   , C_REDEEMMODE
                                   , D_REDEEMCFMDATE
                                   , C_PURCHASEBYOLDCUSTONLY
                                   , C_ISNEEDSPLIT
                                   , C_ONLINEINPUTDATE
                                   , C_TEMPOPENFLAG
                                   , C_ISSHORTREGULARFUND
                                   , C_SHORTREGULARSTATUS
                                   , C_ISREQDATENETVALUE
                                   , C_PURCHASETNCONFIRMCALINTEREST
                                   , C_FUNDALLOPENDAY
                                   , D_IMPORTDATE
                                   , C_MEMO
                                   , C_CONCATPROJ
                                   , C_ORIOPENSTATUS
                                FROM ${hszta_src_schema}.TFUNDOPENDAY"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "D_ENDDATE", "type": "STRING"}, {"name": "C_OPENSTATUS", "type": "STRING"}, {"name": "C_ALLOTMODE", "type": "STRING"}, {"name": "D_ALLOTCFMDATE", "type": "STRING"}, {"name": "C_REDEEMMODE", "type": "STRING"}, {"name": "D_REDEEMCFMDATE", "type": "STRING"}, {"name": "C_PURCHASEBYOLDCUSTONLY", "type": "STRING"}, {"name": "C_ISNEEDSPLIT", "type": "STRING"}, {"name": "C_ONLINEINPUTDATE", "type": "STRING"}, {"name": "C_TEMPOPENFLAG", "type": "STRING"}, {"name": "C_ISSHORTREGULARFUND", "type": "STRING"}, {"name": "C_SHORTREGULARSTATUS", "type": "STRING"}, {"name": "C_ISREQDATENETVALUE", "type": "STRING"}, {"name": "C_PURCHASETNCONFIRMCALINTEREST", "type": "STRING"}, {"name": "C_FUNDALLOPENDAY", "type": "STRING"}, {"name": "D_IMPORTDATE", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "C_CONCATPROJ", "type": "STRING"}, {"name": "C_ORIOPENSTATUS", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tfundopenday_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tfundopenday_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tfundopenday_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tfundopenday_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TFUNDOPENDAY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TFUNDOPENDAY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tfundopenday_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , D_BEGINDATE
     , D_ENDDATE
     , C_OPENSTATUS
     , C_ALLOTMODE
     , D_ALLOTCFMDATE
     , C_REDEEMMODE
     , D_REDEEMCFMDATE
     , C_PURCHASEBYOLDCUSTONLY
     , C_ISNEEDSPLIT
     , C_ONLINEINPUTDATE
     , C_TEMPOPENFLAG
     , C_ISSHORTREGULARFUND
     , C_SHORTREGULARSTATUS
     , C_ISREQDATENETVALUE
     , C_PURCHASETNCONFIRMCALINTEREST
     , C_FUNDALLOPENDAY
     , D_IMPORTDATE
     , C_MEMO
     , C_CONCATPROJ
     , C_ORIOPENSTATUS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDOPENDAY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TFUNDOPENDAY_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TFUNDOPENDAY_PFD成功"
      exit 0
   fi
fi
