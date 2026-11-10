#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLL_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLL_PFD_TMP(
  L_CKID  DECIMAL(20,0)  COMMENT  '存款序号',
  D_KSRQ  STRING  COMMENT  '开始日期',
  EN_LL  DECIMAL(9,6)  COMMENT  '利率',
  EN_FDXX  DECIMAL(19,4)  COMMENT  '分段下限',
  EN_FDSX  DECIMAL(19,4)  COMMENT  '分段上限',
  L_CLBZ  DECIMAL(4,0)  COMMENT  '',
  L_ID  DECIMAL(38,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  ''
)
COMMENT '存款业务利率表'
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
              "querySql": ["SELECT  L_CKID
                                   , D_KSRQ
                                   , EN_LL
                                   , EN_FDXX
                                   , EN_FDSX
                                   , L_CLBZ
                                   , L_ID
                                   , VC_LLR
                                   , VC_FHR
                                FROM ${hsfa_src_schema}.TCAP_CKYWLL"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_CKID", "type": "DOUBLE"}, {"name": "D_KSRQ", "type": "STRING"}, {"name": "EN_LL", "type": "DOUBLE"}, {"name": "EN_FDXX", "type": "DOUBLE"}, {"name": "EN_FDSX", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "L_ID", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tcap_ckywll_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tcap_ckywll_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tcap_ckywll_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tcap_ckywll_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TCAP_CKYWLL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TCAP_CKYWLL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tcap_ckywll_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_CKID
     , D_KSRQ
     , EN_LL
     , EN_FDXX
     , EN_FDSX
     , L_CLBZ
     , L_ID
     , VC_LLR
     , VC_FHR
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TCAP_CKYWLL_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TCAP_CKYWLL_PFD成功"
      exit 0
   fi
fi
