#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TSTATICSHARE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TSTATICSHARE_PFD_TMP(
  C_CUSTTYPE  STRING  COMMENT  '',
  VC_FUNDACCO  STRING  COMMENT  '基金账号',
  VC_TRADEACCO  STRING  COMMENT  '交易账号',
  VC_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  EN_TOTALSHARE  DECIMAL(16,2)  COMMENT  '份额余额',
  EN_FROZENSHARE  DECIMAL(16,2)  COMMENT  '冻结份额',
  EN_REQUESTSHARE  DECIMAL(16,2)  COMMENT  '交易冻结份额',
  C_DIVIDENDMETHOD  STRING  COMMENT  '分红方式',
  C_FLAG  STRING  COMMENT  '标志',
  EN_COST  DECIMAL(16,2)  COMMENT  '成本（含费、备用）',
  EN_FARE  DECIMAL(16,2)  COMMENT  '手续费（备用）',
  VC_LASTDATE  STRING  COMMENT  '最后修改日期',
  EN_INCOME  DECIMAL(16,2)  COMMENT  '未付收益',
  EN_FROZENINCOME  DECIMAL(16,2)  COMMENT  '冻结的未付收益',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  VC_BRANCHCODE  STRING  COMMENT  '托管网点',
  EN_DAYINCOME  DECIMAL(16,2)  COMMENT  '',
  EN_TOTALINCOME  DECIMAL(16,2)  COMMENT  '',
  C_INCOMECARRYFLAG  STRING  COMMENT  '',
  EN_RESERVEDINCOME  DECIMAL(16,2)  COMMENT  '',
  EN_RESERVEDDAYINCOME  DECIMAL(16,2)  COMMENT  '',
  EN_24TOTALSHARE  DECIMAL(16,2)  COMMENT  '',
  C_RESERVEDFLAG  STRING  COMMENT  '',
  EN_LASTTOTALSHARE  DECIMAL(16,2)  COMMENT  '',
  EN_OTHERFEE  DECIMAL(16,2)  COMMENT  '',
  EN_SUMCASHDIVIDENDBALA  DECIMAL(16,2)  COMMENT  '',
  C_RENEWALSTATUS  STRING  COMMENT  '',
  VC_TACODE  STRING  COMMENT  '',
  EN_LAST24TOTALSHARE  DECIMAL(16,2)  COMMENT  '',
  C_BONUSFLAG  STRING  COMMENT  '',
  C_RETURNPATH  STRING  COMMENT  '',
  EN_TOTALCOST  DECIMAL(16,2)  COMMENT  '',
  EN_DAYINCOMEBASE  DECIMAL(16,2)  COMMENT  '',
  EN_REQUEST2FROZENSHARE  DECIMAL(16,2)  COMMENT  '',
  EN_LAST24REVOKESHARE  DECIMAL(16,2)  COMMENT  '',
  C_SIDEBAGFLAG  STRING  COMMENT  ''
)
COMMENT '静态份额表'
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
            "username": "${hsds_username}",
            "password": "${hsds_password}",
            "connection": [{
              "querySql": ["SELECT  C_CUSTTYPE\n                                   , VC_FUNDACCO\n                                   , VC_TRADEACCO\n                                   , VC_FUNDCODE\n                                   , C_SHARETYPE\n                                   , EN_TOTALSHARE\n                                   , EN_FROZENSHARE\n                                   , EN_REQUESTSHARE\n                                   , C_DIVIDENDMETHOD\n                                   , C_FLAG\n                                   , EN_COST\n                                   , EN_FARE\n                                   , VC_LASTDATE\n                                   , EN_INCOME\n                                   , EN_FROZENINCOME\n                                   , C_SHARECLASS\n                                   , VC_BRANCHCODE\n                                   , EN_DAYINCOME\n                                   , EN_TOTALINCOME\n                                   , C_INCOMECARRYFLAG\n                                   , EN_RESERVEDINCOME\n                                   , EN_RESERVEDDAYINCOME\n                                   , EN_24TOTALSHARE\n                                   , C_RESERVEDFLAG\n                                   , EN_LASTTOTALSHARE\n                                   , EN_OTHERFEE\n                                   , EN_SUMCASHDIVIDENDBALA\n                                   , C_RENEWALSTATUS\n                                   , VC_TACODE\n                                   , EN_LAST24TOTALSHARE\n                                   , C_BONUSFLAG\n                                   , C_RETURNPATH\n                                   , EN_TOTALCOST\n                                   , EN_DAYINCOMEBASE\n                                   , EN_REQUEST2FROZENSHARE\n                                   , EN_LAST24REVOKESHARE\n                                   , C_SIDEBAGFLAG\n                                FROM ${hsds_src_schema}.TSTATICSHARE"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "VC_FUNDACCO", "type": "STRING"}, {"name": "VC_TRADEACCO", "type": "STRING"}, {"name": "VC_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "EN_TOTALSHARE", "type": "DOUBLE"}, {"name": "EN_FROZENSHARE", "type": "DOUBLE"}, {"name": "EN_REQUESTSHARE", "type": "DOUBLE"}, {"name": "C_DIVIDENDMETHOD", "type": "STRING"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "EN_COST", "type": "DOUBLE"}, {"name": "EN_FARE", "type": "DOUBLE"}, {"name": "VC_LASTDATE", "type": "STRING"}, {"name": "EN_INCOME", "type": "DOUBLE"}, {"name": "EN_FROZENINCOME", "type": "DOUBLE"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "VC_BRANCHCODE", "type": "STRING"}, {"name": "EN_DAYINCOME", "type": "DOUBLE"}, {"name": "EN_TOTALINCOME", "type": "DOUBLE"}, {"name": "C_INCOMECARRYFLAG", "type": "STRING"}, {"name": "EN_RESERVEDINCOME", "type": "DOUBLE"}, {"name": "EN_RESERVEDDAYINCOME", "type": "DOUBLE"}, {"name": "EN_24TOTALSHARE", "type": "DOUBLE"}, {"name": "C_RESERVEDFLAG", "type": "STRING"}, {"name": "EN_LASTTOTALSHARE", "type": "DOUBLE"}, {"name": "EN_OTHERFEE", "type": "DOUBLE"}, {"name": "EN_SUMCASHDIVIDENDBALA", "type": "DOUBLE"}, {"name": "C_RENEWALSTATUS", "type": "STRING"}, {"name": "VC_TACODE", "type": "STRING"}, {"name": "EN_LAST24TOTALSHARE", "type": "DOUBLE"}, {"name": "C_BONUSFLAG", "type": "STRING"}, {"name": "C_RETURNPATH", "type": "STRING"}, {"name": "EN_TOTALCOST", "type": "DOUBLE"}, {"name": "EN_DAYINCOMEBASE", "type": "DOUBLE"}, {"name": "EN_REQUEST2FROZENSHARE", "type": "DOUBLE"}, {"name": "EN_LAST24REVOKESHARE", "type": "DOUBLE"}, {"name": "C_SIDEBAGFLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_tstaticshare_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_tstaticshare_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_tstaticshare_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_tstaticshare_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TSTATICSHARE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TSTATICSHARE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_tstaticshare_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TSTATICSHARE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_CUSTTYPE
     , VC_FUNDACCO
     , VC_TRADEACCO
     , VC_FUNDCODE
     , C_SHARETYPE
     , EN_TOTALSHARE
     , EN_FROZENSHARE
     , EN_REQUESTSHARE
     , C_DIVIDENDMETHOD
     , C_FLAG
     , EN_COST
     , EN_FARE
     , VC_LASTDATE
     , EN_INCOME
     , EN_FROZENINCOME
     , C_SHARECLASS
     , VC_BRANCHCODE
     , EN_DAYINCOME
     , EN_TOTALINCOME
     , C_INCOMECARRYFLAG
     , EN_RESERVEDINCOME
     , EN_RESERVEDDAYINCOME
     , EN_24TOTALSHARE
     , C_RESERVEDFLAG
     , EN_LASTTOTALSHARE
     , EN_OTHERFEE
     , EN_SUMCASHDIVIDENDBALA
     , C_RENEWALSTATUS
     , VC_TACODE
     , EN_LAST24TOTALSHARE
     , C_BONUSFLAG
     , C_RETURNPATH
     , EN_TOTALCOST
     , EN_DAYINCOMEBASE
     , EN_REQUEST2FROZENSHARE
     , EN_LAST24REVOKESHARE
     , C_SIDEBAGFLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TSTATICSHARE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TSTATICSHARE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TSTATICSHARE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TSTATICSHARE_PFD成功"
      exit 0
   fi
fi
