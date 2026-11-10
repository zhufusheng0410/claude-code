#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TZQLL_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZQLL_PFD_TMP(
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  D_TXRQ  STRING  COMMENT  '调息日期',
  EN_JXLL  DECIMAL(14,8)  COMMENT  '计息利率',
  C_SYNCHRO_FLAG  STRING  COMMENT  '同步标志',
  D_SYNCHRO_TIME  STRING  COMMENT  '同步时间',
  VC_LLR  STRING  COMMENT  '录入人',
  VC_FHR  STRING  COMMENT  '复核人'
)
COMMENT '浮息债利率表'
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
              "querySql": ["SELECT  L_ZQNM
                                   , VC_ZQDM
                                   , D_TXRQ
                                   , EN_JXLL
                                   , C_SYNCHRO_FLAG
                                   , D_SYNCHRO_TIME
                                   , VC_LLR
                                   , VC_FHR
                                FROM ${hsfa_src_schema}.TZQLL"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "D_TXRQ", "type": "STRING"}, {"name": "EN_JXLL", "type": "DOUBLE"}, {"name": "C_SYNCHRO_FLAG", "type": "STRING"}, {"name": "D_SYNCHRO_TIME", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tzqll_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tzqll_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tzqll_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tzqll_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TZQLL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TZQLL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tzqll_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZQLL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZQNM
     , VC_ZQDM
     , D_TXRQ
     , EN_JXLL
     , C_SYNCHRO_FLAG
     , D_SYNCHRO_TIME
     , VC_LLR
     , VC_FHR
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TZQLL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZQLL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TZQLL_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TZQLL_PFD成功"
      exit 0
   fi
fi
