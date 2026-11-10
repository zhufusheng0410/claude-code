#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TARLIMIT_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TARLIMIT_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  F_OMINBALA  DECIMAL(16,2)  COMMENT  '首次投资最低金额',
  F_STEPBALA  DECIMAL(16,2)  COMMENT  '最少追加金额',
  F_OMAXBALA  DECIMAL(16,2)  COMMENT  '最高认购限额',
  F_HMAXRATIO  DECIMAL(9,8)  COMMENT  '最高持有比例',
  F_HMAXBALA  DECIMAL(16,2)  COMMENT  '最高持有金额',
  F_RMINSHARES  DECIMAL(16,2)  COMMENT  '赎回最低份额',
  F_HMINSHARES  DECIMAL(16,2)  COMMENT  '最低帐面份额',
  F_CMINSHARES  DECIMAL(16,2)  COMMENT  '最低转换份额',
  F_RATIONMINBALA  DECIMAL(16,2)  COMMENT  '定期定额最低金额',
  F_SWITCHINBALA  DECIMAL(16,2)  COMMENT  '转换入最低金额(含费)',
  F_RATIONREDEEMMIN  DECIMAL(16,2)  COMMENT  '定期定额赎回最低份额',
  F_MAXALLOTBALA  DECIMAL(16,2)  COMMENT  '大额申购最高金额',
  F_HMINBALA  DECIMAL(16,2)  COMMENT  '最低账面金额',
  F_GRADEDIFF  DECIMAL(16,2)  COMMENT  '级差金额',
  F_MAXBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '最大申购金额',
  F_MAXSUMBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '当日累计申购最大金额',
  F_MAXREDSVOL  DECIMAL(16,2)  COMMENT  '最大赎回份额',
  F_MAXSUMREDSVOL  DECIMAL(16,2)  COMMENT  '当日累计赎回最大份额',
  F_RATIONMAXBALA  DECIMAL(16,2)  COMMENT  '定期定额最高金额',
  C_NETNO  STRING  COMMENT  '网点编号',
  F_STEPSWITCHINBALA  DECIMAL(16,2)  COMMENT  '',
  F_HMINASSET  DECIMAL(16,2)  COMMENT  '',
  F_OMINBALAPUR  DECIMAL(16,2)  COMMENT  '',
  F_STEPBALAPUR  DECIMAL(16,2)  COMMENT  '',
  F_GRADEDIFFSHARE  DECIMAL(16,2)  COMMENT  '',
  F_GRADEDIFFSTEP  DECIMAL(16,2)  COMMENT  '',
  F_RMINBALA  DECIMAL(16,2)  COMMENT  '最低持有金额',
  F_SUBSGLMAXBALA  DECIMAL(16,2)  COMMENT  '',
  F_CHGMINBALA  DECIMAL(16,2)  COMMENT  '',
  F_PURSGLMAXBALA  DECIMAL(16,2)  COMMENT  '',
  F_RMBHMINBALA  DECIMAL(16,2)  COMMENT  '',
  F_MAXSUMSUBAMOUNT  DECIMAL(16,2)  COMMENT  '',
  C_RATIONMAXDEALTYPE  STRING  COMMENT  '',
  F_SUBDAYMAXBALA  DECIMAL(16,2)  COMMENT  '',
  F_HMAXSHARES  DECIMAL(16,2)  COMMENT  '最高持有份额'
)
COMMENT '交易限制'
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
                                   , C_CUSTTYPE
                                   , C_AGENCYNO
                                   , F_OMINBALA
                                   , F_STEPBALA
                                   , F_OMAXBALA
                                   , F_HMAXRATIO
                                   , F_HMAXBALA
                                   , F_RMINSHARES
                                   , F_HMINSHARES
                                   , F_CMINSHARES
                                   , F_RATIONMINBALA
                                   , F_SWITCHINBALA
                                   , F_RATIONREDEEMMIN
                                   , F_MAXALLOTBALA
                                   , F_HMINBALA
                                   , F_GRADEDIFF
                                   , F_MAXBIDSAMOUNT
                                   , F_MAXSUMBIDSAMOUNT
                                   , F_MAXREDSVOL
                                   , F_MAXSUMREDSVOL
                                   , F_RATIONMAXBALA
                                   , C_NETNO
                                   , F_STEPSWITCHINBALA
                                   , F_HMINASSET
                                   , F_OMINBALAPUR
                                   , F_STEPBALAPUR
                                   , F_GRADEDIFFSHARE
                                   , F_GRADEDIFFSTEP
                                   , F_RMINBALA
                                   , F_SUBSGLMAXBALA
                                   , F_CHGMINBALA
                                   , F_PURSGLMAXBALA
                                   , F_RMBHMINBALA
                                   , F_MAXSUMSUBAMOUNT
                                   , C_RATIONMAXDEALTYPE
                                   , F_SUBDAYMAXBALA
                                   , F_HMAXSHARES
                                FROM ${hszta_src_schema}.TARLIMIT"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "F_OMINBALA", "type": "DOUBLE"}, {"name": "F_STEPBALA", "type": "DOUBLE"}, {"name": "F_OMAXBALA", "type": "DOUBLE"}, {"name": "F_HMAXRATIO", "type": "DOUBLE"}, {"name": "F_HMAXBALA", "type": "DOUBLE"}, {"name": "F_RMINSHARES", "type": "DOUBLE"}, {"name": "F_HMINSHARES", "type": "DOUBLE"}, {"name": "F_CMINSHARES", "type": "DOUBLE"}, {"name": "F_RATIONMINBALA", "type": "DOUBLE"}, {"name": "F_SWITCHINBALA", "type": "DOUBLE"}, {"name": "F_RATIONREDEEMMIN", "type": "DOUBLE"}, {"name": "F_MAXALLOTBALA", "type": "DOUBLE"}, {"name": "F_HMINBALA", "type": "DOUBLE"}, {"name": "F_GRADEDIFF", "type": "DOUBLE"}, {"name": "F_MAXBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_MAXSUMBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_MAXREDSVOL", "type": "DOUBLE"}, {"name": "F_MAXSUMREDSVOL", "type": "DOUBLE"}, {"name": "F_RATIONMAXBALA", "type": "DOUBLE"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "F_STEPSWITCHINBALA", "type": "DOUBLE"}, {"name": "F_HMINASSET", "type": "DOUBLE"}, {"name": "F_OMINBALAPUR", "type": "DOUBLE"}, {"name": "F_STEPBALAPUR", "type": "DOUBLE"}, {"name": "F_GRADEDIFFSHARE", "type": "DOUBLE"}, {"name": "F_GRADEDIFFSTEP", "type": "DOUBLE"}, {"name": "F_RMINBALA", "type": "DOUBLE"}, {"name": "F_SUBSGLMAXBALA", "type": "DOUBLE"}, {"name": "F_CHGMINBALA", "type": "DOUBLE"}, {"name": "F_PURSGLMAXBALA", "type": "DOUBLE"}, {"name": "F_RMBHMINBALA", "type": "DOUBLE"}, {"name": "F_MAXSUMSUBAMOUNT", "type": "DOUBLE"}, {"name": "C_RATIONMAXDEALTYPE", "type": "STRING"}, {"name": "F_SUBDAYMAXBALA", "type": "DOUBLE"}, {"name": "F_HMAXSHARES", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tarlimit_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tarlimit_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tarlimit_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tarlimit_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TARLIMIT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TARLIMIT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tarlimit_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TARLIMIT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_CUSTTYPE
     , C_AGENCYNO
     , F_OMINBALA
     , F_STEPBALA
     , F_OMAXBALA
     , F_HMAXRATIO
     , F_HMAXBALA
     , F_RMINSHARES
     , F_HMINSHARES
     , F_CMINSHARES
     , F_RATIONMINBALA
     , F_SWITCHINBALA
     , F_RATIONREDEEMMIN
     , F_MAXALLOTBALA
     , F_HMINBALA
     , F_GRADEDIFF
     , F_MAXBIDSAMOUNT
     , F_MAXSUMBIDSAMOUNT
     , F_MAXREDSVOL
     , F_MAXSUMREDSVOL
     , F_RATIONMAXBALA
     , C_NETNO
     , F_STEPSWITCHINBALA
     , F_HMINASSET
     , F_OMINBALAPUR
     , F_STEPBALAPUR
     , F_GRADEDIFFSHARE
     , F_GRADEDIFFSTEP
     , F_RMINBALA
     , F_SUBSGLMAXBALA
     , F_CHGMINBALA
     , F_PURSGLMAXBALA
     , F_RMBHMINBALA
     , F_MAXSUMSUBAMOUNT
     , C_RATIONMAXDEALTYPE
     , F_SUBDAYMAXBALA
     , F_HMAXSHARES
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TARLIMIT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TARLIMIT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TARLIMIT_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TARLIMIT_PFD成功"
      exit 0
   fi
fi
