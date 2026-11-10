#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TSALESTAT_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSALESTAT_PTD_TMP(
  D_CDATE  STRING  COMMENT  '确认日期',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_AGENCYNO  STRING  COMMENT  '销售商代码',
  F_SHARE  DECIMAL(16,2)  COMMENT  '保有份额',
  F_BALANCE  DECIMAL(16,2)  COMMENT  '保有金额',
  F_ORIBALANCE  DECIMAL(16,2)  COMMENT  '按成本价的保有金额',
  F_MANAGERFEE  DECIMAL(6,5)  COMMENT  '管理费计提比例',
  F_TAILRATIO  DECIMAL(9,8)  COMMENT  '尾随佣金比例',
  D_HOLDDATE  STRING  COMMENT  '份额持有日期',
  F_HOLDRATIO  DECIMAL(9,8)  COMMENT  '保有比例',
  F_SERVICEFARE  DECIMAL(16,2)  COMMENT  '销售服务费',
  F_INCOME  DECIMAL(16,2)  COMMENT  '保有的未付收益',
  F_REINVESTSHARE  DECIMAL(16,2)  COMMENT  '保有再投资份额',
  F_REINVESTBALANCE  DECIMAL(16,2)  COMMENT  '保有再投资金额',
  F_REINVESTORIBALANCE  DECIMAL(16,2)  COMMENT  '按成本价的再投资金额',
  F_OUTERSHARES  DECIMAL(16,2)  COMMENT  '',
  F_OUTERBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_INNERSHARES  DECIMAL(16,2)  COMMENT  '',
  F_INNERBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_TAILFARE  DECIMAL(16,2)  COMMENT  '',
  F_TAILFARE2  DECIMAL(16,2)  COMMENT  '',
  F_TAILRATIO2  DECIMAL(9,8)  COMMENT  '',
  F_PROTECTSHARES  DECIMAL(16,2)  COMMENT  '保底份额',
  F_PROTECTBALANCE  DECIMAL(16,2)  COMMENT  '',
  D_LASTSERVICEFAREDATE  STRING  COMMENT  '',
  F_SERVICERATIO  DECIMAL(7,6)  COMMENT  '销售服务费率',
  F_TAILRATIO3  DECIMAL(9,8)  COMMENT  '',
  F_TAILFARE3  DECIMAL(16,2)  COMMENT  '',
  F_TAILRATIO4  DECIMAL(9,8)  COMMENT  '',
  F_TAILFARE4  DECIMAL(16,2)  COMMENT  '',
  F_INVESTSHARE  DECIMAL(16,2)  COMMENT  '',
  F_INVESTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_TAILRATIO5  DECIMAL(9,8)  COMMENT  '',
  F_TAILFARE5  DECIMAL(16,2)  COMMENT  '',
  F_REITSINVESTORSHARE  DECIMAL(16,2)  COMMENT  '',
  F_REITSINVESTORBALANCE  DECIMAL(16,2)  COMMENT  ''
)
COMMENT '销售业绩统计表'
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
                                   , C_FUNDCODE
                                   , C_AGENCYNO
                                   , F_SHARE
                                   , F_BALANCE
                                   , F_ORIBALANCE
                                   , F_MANAGERFEE
                                   , F_TAILRATIO
                                   , D_HOLDDATE
                                   , F_HOLDRATIO
                                   , F_SERVICEFARE
                                   , F_INCOME
                                   , F_REINVESTSHARE
                                   , F_REINVESTBALANCE
                                   , F_REINVESTORIBALANCE
                                   , F_OUTERSHARES
                                   , F_OUTERBALANCE
                                   , F_INNERSHARES
                                   , F_INNERBALANCE
                                   , F_TAILFARE
                                   , F_TAILFARE2
                                   , F_TAILRATIO2
                                   , F_PROTECTSHARES
                                   , F_PROTECTBALANCE
                                   , D_LASTSERVICEFAREDATE
                                   , F_SERVICERATIO
                                   , F_TAILRATIO3
                                   , F_TAILFARE3
                                   , F_TAILRATIO4
                                   , F_TAILFARE4
                                   , F_INVESTSHARE
                                   , F_INVESTBALANCE
                                   , F_TAILRATIO5
                                   , F_TAILFARE5
                                   , F_REITSINVESTORSHARE
                                   , F_REITSINVESTORBALANCE
                                FROM ${hsfta_src_schema}.TSALESTAT
                                WHERE D_CDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_CDATE", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "F_SHARE", "type": "DOUBLE"}, {"name": "F_BALANCE", "type": "DOUBLE"}, {"name": "F_ORIBALANCE", "type": "DOUBLE"}, {"name": "F_MANAGERFEE", "type": "DOUBLE"}, {"name": "F_TAILRATIO", "type": "DOUBLE"}, {"name": "D_HOLDDATE", "type": "STRING"}, {"name": "F_HOLDRATIO", "type": "DOUBLE"}, {"name": "F_SERVICEFARE", "type": "DOUBLE"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_REINVESTSHARE", "type": "DOUBLE"}, {"name": "F_REINVESTBALANCE", "type": "DOUBLE"}, {"name": "F_REINVESTORIBALANCE", "type": "DOUBLE"}, {"name": "F_OUTERSHARES", "type": "DOUBLE"}, {"name": "F_OUTERBALANCE", "type": "DOUBLE"}, {"name": "F_INNERSHARES", "type": "DOUBLE"}, {"name": "F_INNERBALANCE", "type": "DOUBLE"}, {"name": "F_TAILFARE", "type": "DOUBLE"}, {"name": "F_TAILFARE2", "type": "DOUBLE"}, {"name": "F_TAILRATIO2", "type": "DOUBLE"}, {"name": "F_PROTECTSHARES", "type": "DOUBLE"}, {"name": "F_PROTECTBALANCE", "type": "DOUBLE"}, {"name": "D_LASTSERVICEFAREDATE", "type": "STRING"}, {"name": "F_SERVICERATIO", "type": "DOUBLE"}, {"name": "F_TAILRATIO3", "type": "DOUBLE"}, {"name": "F_TAILFARE3", "type": "DOUBLE"}, {"name": "F_TAILRATIO4", "type": "DOUBLE"}, {"name": "F_TAILFARE4", "type": "DOUBLE"}, {"name": "F_INVESTSHARE", "type": "DOUBLE"}, {"name": "F_INVESTBALANCE", "type": "DOUBLE"}, {"name": "F_TAILRATIO5", "type": "DOUBLE"}, {"name": "F_TAILFARE5", "type": "DOUBLE"}, {"name": "F_REITSINVESTORSHARE", "type": "DOUBLE"}, {"name": "F_REITSINVESTORBALANCE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tsalestat_ptd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tsalestat_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tsalestat_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tsalestat_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TSALESTAT_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TSALESTAT_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tsalestat_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSALESTAT_PTD PARTITION(P_DT)
SELECT
       D_CDATE
     , C_FUNDCODE
     , C_AGENCYNO
     , F_SHARE
     , F_BALANCE
     , F_ORIBALANCE
     , F_MANAGERFEE
     , F_TAILRATIO
     , D_HOLDDATE
     , F_HOLDRATIO
     , F_SERVICEFARE
     , F_INCOME
     , F_REINVESTSHARE
     , F_REINVESTBALANCE
     , F_REINVESTORIBALANCE
     , F_OUTERSHARES
     , F_OUTERBALANCE
     , F_INNERSHARES
     , F_INNERBALANCE
     , F_TAILFARE
     , F_TAILFARE2
     , F_TAILRATIO2
     , F_PROTECTSHARES
     , F_PROTECTBALANCE
     , D_LASTSERVICEFAREDATE
     , F_SERVICERATIO
     , F_TAILRATIO3
     , F_TAILFARE3
     , F_TAILRATIO4
     , F_TAILFARE4
     , F_INVESTSHARE
     , F_INVESTBALANCE
     , F_TAILRATIO5
     , F_TAILFARE5
     , F_REITSINVESTORSHARE
     , F_REITSINVESTORBALANCE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_CDATE,'-','') P_DT
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSALESTAT_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSALESTAT_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TSALESTAT_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TSALESTAT_PTD成功"
      exit 0
   fi
fi
