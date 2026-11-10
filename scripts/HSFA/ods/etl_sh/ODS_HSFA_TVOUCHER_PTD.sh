#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TVOUCHER_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TVOUCHER_PTD_TMP(
  L_ID  STRING  COMMENT  '唯一编号',
  L_FUNDID  DECIMAL(9,0)  COMMENT  '帐套id',
  L_YEAR  DECIMAL(4,0)  COMMENT  '会计年份',
  L_MONTH  DECIMAL(2,0)  COMMENT  '会计期间',
  L_NO  STRING  COMMENT  '凭证编号',
  L_DOCS  DECIMAL(4,0)  COMMENT  '附单据数',
  D_MAKE  STRING  COMMENT  '制单日期',
  VC_MAKER  STRING  COMMENT  '制单人',
  VC_CHECKER  STRING  COMMENT  '审核人',
  VC_BOOKER  STRING  COMMENT  '记账人',
  VC_CASHIER  STRING  COMMENT  '出纳',
  VC_ADMIN  STRING  COMMENT  '会计主管',
  L_STATE  DECIMAL(4,0)  COMMENT  '凭证状态',
  L_CONTRA  STRING  COMMENT  '对冲凭证编号',
  L_TURN  DECIMAL(4,0)  COMMENT  '是否转账凭证',
  D_CHECKSJ  STRING  COMMENT  '审核时间',
  D_BOOKSJ  STRING  COMMENT  '记账时间',
  L_ZZGSBH  STRING  COMMENT  '转账公式编号',
  L_CONTRAFLAG  STRING  COMMENT  '冲销标志',
  VC_FHR  STRING  COMMENT  '复核人',
  L_CZBZID  DECIMAL(4,0)  COMMENT  ''
)
COMMENT '凭证主表'
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_ID
                                   , L_FUNDID
                                   , L_YEAR
                                   , L_MONTH
                                   , L_NO
                                   , L_DOCS
                                   , TO_CHAR(D_MAKE,'YYYYMMDD') D_MAKE
                                   , VC_MAKER
                                   , VC_CHECKER
                                   , VC_BOOKER
                                   , VC_CASHIER
                                   , VC_ADMIN
                                   , L_STATE
                                   , L_CONTRA
                                   , L_TURN
                                   , D_CHECKSJ
                                   , D_BOOKSJ
                                   , L_ZZGSBH
                                   , L_CONTRAFLAG
                                   , VC_FHR
                                   , L_CZBZID
                                FROM ${hsfa_src_schema}.T_H_VOUCHER
                                WHERE D_MAKE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "L_FUNDID", "type": "DOUBLE"}, {"name": "L_YEAR", "type": "DOUBLE"}, {"name": "L_MONTH", "type": "DOUBLE"}, {"name": "L_NO", "type": "DOUBLE"}, {"name": "L_DOCS", "type": "DOUBLE"}, {"name": "D_MAKE", "type": "STRING"}, {"name": "VC_MAKER", "type": "STRING"}, {"name": "VC_CHECKER", "type": "STRING"}, {"name": "VC_BOOKER", "type": "STRING"}, {"name": "VC_CASHIER", "type": "STRING"}, {"name": "VC_ADMIN", "type": "STRING"}, {"name": "L_STATE", "type": "DOUBLE"}, {"name": "L_CONTRA", "type": "DOUBLE"}, {"name": "L_TURN", "type": "DOUBLE"}, {"name": "D_CHECKSJ", "type": "STRING"}, {"name": "D_BOOKSJ", "type": "STRING"}, {"name": "L_ZZGSBH", "type": "DOUBLE"}, {"name": "L_CONTRAFLAG", "type": "DOUBLE"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "L_CZBZID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tvoucher_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tvoucher_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tvoucher_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tvoucher_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TVOUCHER_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TVOUCHER_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tvoucher_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TVOUCHER_PTD PARTITION(P_DT)
SELECT
       L_ID
     , L_FUNDID
     , L_YEAR
     , L_MONTH
     , L_NO
     , L_DOCS
     , D_MAKE
     , VC_MAKER
     , VC_CHECKER
     , VC_BOOKER
     , VC_CASHIER
     , VC_ADMIN
     , L_STATE
     , L_CONTRA
     , L_TURN
     , D_CHECKSJ
     , D_BOOKSJ
     , L_ZZGSBH
     , L_CONTRAFLAG
     , VC_FHR
     , L_CZBZID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_MAKE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TVOUCHER_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TVOUCHER_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TVOUCHER_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TVOUCHER_PTD成功"
      exit 0
   fi
fi
