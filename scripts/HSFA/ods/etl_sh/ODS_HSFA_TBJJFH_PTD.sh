#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TBJJFH_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TBJJFH_PTD_TMP(
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  L_TYPE  DECIMAL(1,0)  COMMENT  '',
  D_CQRQ  STRING  COMMENT  '',
  VC_FUNDCODE  STRING  COMMENT  '',
  EN_DWSQJE  DECIMAL(24,12)  COMMENT  '',
  EN_CFBL  DECIMAL(12,10)  COMMENT  '',
  EN_QYJE  DECIMAL(19,4)  COMMENT  '',
  EN_QYFE  DECIMAL(21,6)  COMMENT  '',
  D_DJRQ  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  L_ID  DECIMAL(18,2)  COMMENT  '',
  D_YWRQ  STRING  COMMENT  '',
  L_CLBZ  DECIMAL(1,0)  COMMENT  '',
  L_SFSCLS  DECIMAL(1,0)  COMMENT  '',
  L_JJJB  DECIMAL(4,0)  COMMENT  ''
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
              "querySql": ["SELECT  L_ZTBH
                                   , L_TYPE
                                   , D_CQRQ
                                   , VC_FUNDCODE
                                   , EN_DWSQJE
                                   , EN_CFBL
                                   , EN_QYJE
                                   , EN_QYFE
                                   , D_DJRQ
                                   , VC_FHR
                                   , VC_LLR
                                   , L_ID
                                   , TO_CHAR(D_YWRQ,'YYYYMMDD') D_YWRQ
                                   , L_CLBZ
                                   , L_SFSCLS
                                   , L_JJJB
                                FROM ${hsfa_src_schema}.TBJJFH
                                WHERE D_YWRQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_TYPE", "type": "DOUBLE"}, {"name": "D_CQRQ", "type": "STRING"}, {"name": "VC_FUNDCODE", "type": "STRING"}, {"name": "EN_DWSQJE", "type": "DOUBLE"}, {"name": "EN_CFBL", "type": "DOUBLE"}, {"name": "EN_QYJE", "type": "DOUBLE"}, {"name": "EN_QYFE", "type": "DOUBLE"}, {"name": "D_DJRQ", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "L_ID", "type": "DOUBLE"}, {"name": "D_YWRQ", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "L_SFSCLS", "type": "DOUBLE"}, {"name": "L_JJJB", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tbjjfh_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tbjjfh_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tbjjfh_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tbjjfh_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TBJJFH_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TBJJFH_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tbjjfh_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TBJJFH_PTD PARTITION(P_DT)
SELECT
       L_ZTBH
     , L_TYPE
     , D_CQRQ
     , VC_FUNDCODE
     , EN_DWSQJE
     , EN_CFBL
     , EN_QYJE
     , EN_QYFE
     , D_DJRQ
     , VC_FHR
     , VC_LLR
     , L_ID
     , D_YWRQ
     , L_CLBZ
     , L_SFSCLS
     , L_JJJB
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_YWRQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TBJJFH_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TBJJFH_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TBJJFH_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TBJJFH_PTD成功"
      exit 0
   fi
fi
