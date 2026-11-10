#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDSTATUS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDSTATUS_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  D_CDATE  STRING  COMMENT  '预设日期',
  C_FUNDSTATUS  STRING  COMMENT  '基金状态',
  F_NETVALUE  DECIMAL(20,8)  COMMENT  '基金净值（成交价）',
  C_TODAYTRFSTATUS  STRING  COMMENT  '',
  C_TODAYCHGSTATUS  STRING  COMMENT  '',
  C_TODAYPCSSTATUS  STRING  COMMENT  '',
  C_TODAYSPLITSTATUS  STRING  COMMENT  '',
  C_ISSPLITDAY  STRING  COMMENT  '',
  C_ACCOUNTINGDAY  STRING  COMMENT  '估值日标志',
  C_ISMATCHDAY  STRING  COMMENT  '',
  F_PMAXBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '',
  F_EMAXBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '',
  F_PMAXSUMBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '',
  F_EMAXSUMBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '',
  F_PMAXREDSVOL  DECIMAL(16,2)  COMMENT  '',
  F_EMAXREDSVOL  DECIMAL(16,2)  COMMENT  '',
  F_PMAXSUMREDSVOL  DECIMAL(16,2)  COMMENT  '',
  F_EMAXSUMREDSVOL  DECIMAL(16,2)  COMMENT  '',
  C_ISNEEDRDMBYALLOT  STRING  COMMENT  ''
)
COMMENT '预设基金状态'
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
              "querySql": ["SELECT  C_FUNDCODE
                                   , D_CDATE
                                   , C_FUNDSTATUS
                                   , F_NETVALUE
                                   , C_TODAYTRFSTATUS
                                   , C_TODAYCHGSTATUS
                                   , C_TODAYPCSSTATUS
                                   , C_TODAYSPLITSTATUS
                                   , C_ISSPLITDAY
                                   , C_ACCOUNTINGDAY
                                   , C_ISMATCHDAY
                                   , F_PMAXBIDSAMOUNT
                                   , F_EMAXBIDSAMOUNT
                                   , F_PMAXSUMBIDSAMOUNT
                                   , F_EMAXSUMBIDSAMOUNT
                                   , F_PMAXREDSVOL
                                   , F_EMAXREDSVOL
                                   , F_PMAXSUMREDSVOL
                                   , F_EMAXSUMREDSVOL
                                   , C_ISNEEDRDMBYALLOT
                                FROM ${hsfta_src_schema}.TFUNDSTATUS"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_FUNDSTATUS", "type": "STRING"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "C_TODAYTRFSTATUS", "type": "STRING"}, {"name": "C_TODAYCHGSTATUS", "type": "STRING"}, {"name": "C_TODAYPCSSTATUS", "type": "STRING"}, {"name": "C_TODAYSPLITSTATUS", "type": "STRING"}, {"name": "C_ISSPLITDAY", "type": "STRING"}, {"name": "C_ACCOUNTINGDAY", "type": "STRING"}, {"name": "C_ISMATCHDAY", "type": "STRING"}, {"name": "F_PMAXBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_EMAXBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_PMAXSUMBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_EMAXSUMBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_PMAXREDSVOL", "type": "DOUBLE"}, {"name": "F_EMAXREDSVOL", "type": "DOUBLE"}, {"name": "F_PMAXSUMREDSVOL", "type": "DOUBLE"}, {"name": "F_EMAXSUMREDSVOL", "type": "DOUBLE"}, {"name": "C_ISNEEDRDMBYALLOT", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tfundstatus_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tfundstatus_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tfundstatus_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tfundstatus_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TFUNDSTATUS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TFUNDSTATUS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tfundstatus_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDSTATUS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , D_CDATE
     , C_FUNDSTATUS
     , F_NETVALUE
     , C_TODAYTRFSTATUS
     , C_TODAYCHGSTATUS
     , C_TODAYPCSSTATUS
     , C_TODAYSPLITSTATUS
     , C_ISSPLITDAY
     , C_ACCOUNTINGDAY
     , C_ISMATCHDAY
     , F_PMAXBIDSAMOUNT
     , F_EMAXBIDSAMOUNT
     , F_PMAXSUMBIDSAMOUNT
     , F_EMAXSUMBIDSAMOUNT
     , F_PMAXREDSVOL
     , F_EMAXREDSVOL
     , F_PMAXSUMREDSVOL
     , F_EMAXSUMREDSVOL
     , C_ISNEEDRDMBYALLOT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDSTATUS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDSTATUS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TFUNDSTATUS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TFUNDSTATUS_PFD成功"
      exit 0
   fi
fi
