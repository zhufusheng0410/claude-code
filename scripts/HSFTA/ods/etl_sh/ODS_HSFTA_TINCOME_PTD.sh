#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TINCOME_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TINCOME_PTD_TMP(
  D_CDATE  STRING  COMMENT  '确认日期',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  F_INCOME  DECIMAL(16,2)  COMMENT  '昨日基金收益',
  F_FROZENINCOME  DECIMAL(16,2)  COMMENT  '冻结未付收益',
  F_NEWINCOME  DECIMAL(16,2)  COMMENT  '当天新增未付收益',
  F_REALSHARES  DECIMAL(16,2)  COMMENT  '份额余额',
  F_FROZENSHARES  DECIMAL(16,2)  COMMENT  '冻结份额',
  F_RETURNFARE  DECIMAL(16,9)  COMMENT  '累计未返还费用',
  F_RETURNFARENEW  DECIMAL(16,9)  COMMENT  '新增未返还费用',
  C_DETAILFLAG  STRING  COMMENT  '',
  D_REGISTDATE  STRING  COMMENT  '份额注册日期',
  C_ORIGINALNO  STRING  COMMENT  '',
  F_ACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_ORINEWINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ORIREALSHARESINCOME  DECIMAL(16,2)  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  F_T0LIQINCOME  DECIMAL(16,2)  COMMENT  '',
  F_T0LIQSHARES  DECIMAL(16,2)  COMMENT  '',
  F_REALNEWINCOME  DECIMAL(16,2)  COMMENT  '',
  F_HAVECALMGRINCOME  DECIMAL(16,2)  COMMENT  '',
  F_FROZENNEWINCOME  DECIMAL(16,2)  COMMENT  '',
  F_TOTALINCOME  DECIMAL(16,2)  COMMENT  ''
)
COMMENT '账户未付收益表'
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
              "querySql": ["SELECT  TO_CHAR(D_CDATE,'YYYYMMDD') D_CDATE
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , F_INCOME
                                   , F_FROZENINCOME
                                   , F_NEWINCOME
                                   , F_REALSHARES
                                   , F_FROZENSHARES
                                   , F_RETURNFARE
                                   , F_RETURNFARENEW
                                   , C_DETAILFLAG
                                   , D_REGISTDATE
                                   , C_ORIGINALNO
                                   , F_ACCUMSHARES
                                   , F_ORINEWINCOME
                                   , F_ORIREALSHARESINCOME
                                   , C_SPECIALACCOFLAG
                                   , C_PARTNERID
                                   , F_T0LIQINCOME
                                   , F_T0LIQSHARES
                                   , F_REALNEWINCOME
                                   , F_HAVECALMGRINCOME
                                   , F_FROZENNEWINCOME
                                   , F_TOTALINCOME
                                FROM ${hsfta_src_schema}.TINCOME
                                WHERE D_CDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_CDATE", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_FROZENINCOME", "type": "DOUBLE"}, {"name": "F_NEWINCOME", "type": "DOUBLE"}, {"name": "F_REALSHARES", "type": "DOUBLE"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "F_RETURNFARE", "type": "DOUBLE"}, {"name": "F_RETURNFARENEW", "type": "DOUBLE"}, {"name": "C_DETAILFLAG", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "C_ORIGINALNO", "type": "STRING"}, {"name": "F_ACCUMSHARES", "type": "DOUBLE"}, {"name": "F_ORINEWINCOME", "type": "DOUBLE"}, {"name": "F_ORIREALSHARESINCOME", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "F_T0LIQINCOME", "type": "DOUBLE"}, {"name": "F_T0LIQSHARES", "type": "DOUBLE"}, {"name": "F_REALNEWINCOME", "type": "DOUBLE"}, {"name": "F_HAVECALMGRINCOME", "type": "DOUBLE"}, {"name": "F_FROZENNEWINCOME", "type": "DOUBLE"}, {"name": "F_TOTALINCOME", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tincome_ptd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tincome_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tincome_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tincome_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TINCOME_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TINCOME_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tincome_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TINCOME_PTD PARTITION(P_DT)
SELECT
       D_CDATE
     , C_FUNDACCO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , C_AGENCYNO
     , C_NETNO
     , F_INCOME
     , F_FROZENINCOME
     , F_NEWINCOME
     , F_REALSHARES
     , F_FROZENSHARES
     , F_RETURNFARE
     , F_RETURNFARENEW
     , C_DETAILFLAG
     , D_REGISTDATE
     , C_ORIGINALNO
     , F_ACCUMSHARES
     , F_ORINEWINCOME
     , F_ORIREALSHARESINCOME
     , C_SPECIALACCOFLAG
     , C_PARTNERID
     , F_T0LIQINCOME
     , F_T0LIQSHARES
     , F_REALNEWINCOME
     , F_HAVECALMGRINCOME
     , F_FROZENNEWINCOME
     , F_TOTALINCOME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_CDATE,'-','') P_DT
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TINCOME_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TINCOME_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TINCOME_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TINCOME_PTD成功"
      exit 0
   fi
fi
