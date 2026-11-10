#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TFROZENDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFROZENDETAIL_PTD_TMP(
  C_CSERIALNO  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '',
  C_TRADEACCO  STRING  COMMENT  '',
  C_FUNDCODE  STRING  COMMENT  '',
  C_SHARETYPE  STRING  COMMENT  '',
  C_AGENCYNO  STRING  COMMENT  '',
  C_NETNO  STRING  COMMENT  '',
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
  C_RESERVE  STRING  COMMENT  '',
  F_FROZENINCOME  DECIMAL(16,2)  COMMENT  '',
  F_TOTALBONUSFROZENSHARES  DECIMAL(16,2)  COMMENT  '',
  F_UNFREEZESHARES  DECIMAL(16,2)  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  D_APPENDDATE  STRING  COMMENT  ''
)
COMMENT '冻结明细表'
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
              "querySql": ["SELECT  C_CSERIALNO
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , TO_CHAR(D_FROZENDATE,'YYYYMMDD') D_FROZENDATE
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
                                   , C_RESERVE
                                   , F_FROZENINCOME
                                   , F_TOTALBONUSFROZENSHARES
                                   , F_UNFREEZESHARES
                                   , C_SPECIALACCOFLAG
                                   , C_PARTNERID
                                   , D_APPENDDATE
                                FROM ${hsfta_src_schema}.TFROZENDETAIL
                                WHERE D_FROZENDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "D_FROZENDATE", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "C_FREEZETYPE", "type": "STRING"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "C_BACKDATE", "type": "STRING"}, {"name": "C_FROZENRIGHT", "type": "STRING"}, {"name": "F_BALANCERIGHT", "type": "DOUBLE"}, {"name": "F_SHARERIGHT", "type": "DOUBLE"}, {"name": "F_LASTBALANCE", "type": "DOUBLE"}, {"name": "F_LASTSHARES", "type": "DOUBLE"}, {"name": "C_TAFLAG", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "C_UNFREEZEFLAG", "type": "STRING"}, {"name": "C_RESERVE", "type": "STRING"}, {"name": "F_FROZENINCOME", "type": "DOUBLE"}, {"name": "F_TOTALBONUSFROZENSHARES", "type": "DOUBLE"}, {"name": "F_UNFREEZESHARES", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "D_APPENDDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tfrozendetail_ptd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tfrozendetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tfrozendetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tfrozendetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TFROZENDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TFROZENDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tfrozendetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFROZENDETAIL_PTD PARTITION(P_DT)
SELECT
       C_CSERIALNO
     , C_FUNDACCO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , C_AGENCYNO
     , C_NETNO
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
     , C_RESERVE
     , F_FROZENINCOME
     , F_TOTALBONUSFROZENSHARES
     , F_UNFREEZESHARES
     , C_SPECIALACCOFLAG
     , C_PARTNERID
     , D_APPENDDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_FROZENDATE,'-','') P_DT
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFROZENDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFROZENDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TFROZENDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TFROZENDETAIL_PTD成功"
      exit 0
   fi
fi
