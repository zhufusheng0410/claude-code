#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TXM_LL_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_LL_PFD_TMP(
  L_BH  DECIMAL(8,0)  COMMENT  '',
  D_DATE  STRING  COMMENT  '',
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  EN_NLL  DECIMAL(12,8)  COMMENT  '',
  L_JXNTS  DECIMAL(4,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  L_CLBZ  DECIMAL(4,0)  COMMENT  '',
  D_SCSJ  STRING  COMMENT  ''
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_BH
                                   , D_DATE
                                   , L_ZTBH
                                   , EN_NLL
                                   , L_JXNTS
                                   , VC_LLR
                                   , VC_FHR
                                   , L_CLBZ
                                   , D_SCSJ
                                FROM ${hsfa_src_schema}.TXM_LL"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "D_DATE", "type": "STRING"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "EN_NLL", "type": "DOUBLE"}, {"name": "L_JXNTS", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "D_SCSJ", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_txm_ll_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_txm_ll_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_txm_ll_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_txm_ll_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TXM_LL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TXM_LL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_txm_ll_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_LL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BH
     , D_DATE
     , L_ZTBH
     , EN_NLL
     , L_JXNTS
     , VC_LLR
     , VC_FHR
     , L_CLBZ
     , D_SCSJ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TXM_LL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_LL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TXM_LL_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TXM_LL_PFD成功"
      exit 0
   fi
fi
