#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TFROZENDETAIL_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFROZENDETAIL_PFD_TMP(
  C_CSERIALNO  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '',
  C_AGENCYNO  STRING  COMMENT  '',
  C_NETNO  STRING  COMMENT  '',
  C_TRADEACCO  STRING  COMMENT  '',
  C_FUNDCODE  STRING  COMMENT  '',
  C_SHARETYPE  STRING  COMMENT  '',
  D_FROZENDATE  STRING  COMMENT  '',
  C_REQUESTNO  STRING  COMMENT  '',
  C_FREEZECAUSE  STRING  COMMENT  '',
  C_FREEZETYPE  STRING  COMMENT  '',
  F_FROZENSHARES  DECIMAL(16,2)  COMMENT  '',
  C_BACKDATE  STRING  COMMENT  '',
  C_FROZENRIGHT  STRING  COMMENT  '',
  F_BALANCERIGHT  DECIMAL(16,2)  COMMENT  '',
  F_SHARERIGHT  DECIMAL(16,2)  COMMENT  '',
  F_LASTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_LASTSHARES  DECIMAL(16,2)  COMMENT  '',
  C_TAFLAG  STRING  COMMENT  '',
  D_LASTMODIFY  STRING  COMMENT  '',
  C_UNFREEZEFLAG  STRING  COMMENT  '',
  F_FROZENINCOME  DECIMAL(16,2)  COMMENT  '',
  D_APPENDDATE  STRING  COMMENT  '',
  C_SYSROLE  STRING  COMMENT  '',
  C_SECONDACCO  STRING  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '',
  F_FROZENINCOMEBAK  DECIMAL(16,2)  COMMENT  '',
  C_FRZLAWFILENO  STRING  COMMENT  '',
  C_DFRZLAWFILENO  STRING  COMMENT  '',
  C_AUTOUNFRZ  STRING  COMMENT  ''
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
              "querySql": ["SELECT  C_CSERIALNO
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , D_FROZENDATE
                                   , C_REQUESTNO
                                   , C_FREEZECAUSE
                                   , C_FREEZETYPE
                                   , F_FROZENSHARES
                                   , C_BACKDATE
                                   , C_FROZENRIGHT
                                   , F_BALANCERIGHT
                                   , F_SHARERIGHT
                                   , F_LASTBALANCE
                                   , F_LASTSHARES
                                   , C_TAFLAG
                                   , D_LASTMODIFY
                                   , C_UNFREEZEFLAG
                                   , F_FROZENINCOME
                                   , D_APPENDDATE
                                   , C_SYSROLE
                                   , C_SECONDACCO
                                   , C_SPECIALACCOFLAG
                                   , C_PARTNERID
                                   , C_MEMO
                                   , F_FROZENINCOMEBAK
                                   , C_FRZLAWFILENO
                                   , C_DFRZLAWFILENO
                                   , C_AUTOUNFRZ
                                FROM ${hszta_src_schema}.TFROZENDETAIL"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "D_FROZENDATE", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "C_FREEZETYPE", "type": "STRING"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "C_BACKDATE", "type": "STRING"}, {"name": "C_FROZENRIGHT", "type": "STRING"}, {"name": "F_BALANCERIGHT", "type": "DOUBLE"}, {"name": "F_SHARERIGHT", "type": "DOUBLE"}, {"name": "F_LASTBALANCE", "type": "DOUBLE"}, {"name": "F_LASTSHARES", "type": "DOUBLE"}, {"name": "C_TAFLAG", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "C_UNFREEZEFLAG", "type": "STRING"}, {"name": "F_FROZENINCOME", "type": "DOUBLE"}, {"name": "D_APPENDDATE", "type": "STRING"}, {"name": "C_SYSROLE", "type": "STRING"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "F_FROZENINCOMEBAK", "type": "DOUBLE"}, {"name": "C_FRZLAWFILENO", "type": "STRING"}, {"name": "C_DFRZLAWFILENO", "type": "STRING"}, {"name": "C_AUTOUNFRZ", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tfrozendetail_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tfrozendetail_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tfrozendetail_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tfrozendetail_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TFROZENDETAIL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TFROZENDETAIL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tfrozendetail_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFROZENDETAIL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_CSERIALNO
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , D_FROZENDATE
     , C_REQUESTNO
     , C_FREEZECAUSE
     , C_FREEZETYPE
     , F_FROZENSHARES
     , C_BACKDATE
     , C_FROZENRIGHT
     , F_BALANCERIGHT
     , F_SHARERIGHT
     , F_LASTBALANCE
     , F_LASTSHARES
     , C_TAFLAG
     , D_LASTMODIFY
     , C_UNFREEZEFLAG
     , F_FROZENINCOME
     , D_APPENDDATE
     , C_SYSROLE
     , C_SECONDACCO
     , C_SPECIALACCOFLAG
     , C_PARTNERID
     , C_MEMO
     , F_FROZENINCOMEBAK
     , C_FRZLAWFILENO
     , C_DFRZLAWFILENO
     , C_AUTOUNFRZ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFROZENDETAIL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFROZENDETAIL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TFROZENDETAIL_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TFROZENDETAIL_PFD成功"
      exit 0
   fi
fi
