#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TJJMRHJSJ_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJMRHJSJ_PTD_TMP(
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  D_RQ  STRING  COMMENT  '',
  VC_JJDM  STRING  COMMENT  '',
  VC_FJJJDM  STRING  COMMENT  '',
  EN_ZCHJ  DECIMAL(30,2)  COMMENT  '',
  EN_FZHJ  DECIMAL(30,2)  COMMENT  '',
  EN_ZCJZ  DECIMAL(30,2)  COMMENT  '',
  EN_ZCFE  DECIMAL(34,6)  COMMENT  '',
  EN_DWJZ  DECIMAL(18,2)  COMMENT  '',
  EN_JJSY  DECIMAL(30,2)  COMMENT  '',
  EN_DWJJSY  DECIMAL(23,8)  COMMENT  '',
  EN_NSYL  DECIMAL(19,4)  COMMENT  '',
  EN_XSFWF  DECIMAL(30,2)  COMMENT  '',
  EN_LJDWJZ  DECIMAL(18,2)  COMMENT  '',
  EN_GPSZ  DECIMAL(30,2)  COMMENT  '',
  EN_GPCB  DECIMAL(30,2)  COMMENT  '',
  EN_ZQSZ  DECIMAL(30,2)  COMMENT  '',
  EN_ZQCB  DECIMAL(30,2)  COMMENT  '',
  EN_QZSZ  DECIMAL(30,2)  COMMENT  '',
  EN_QZCB  DECIMAL(30,2)  COMMENT  '',
  EN_JJSZ  DECIMAL(30,2)  COMMENT  '',
  EN_JJCB  DECIMAL(30,2)  COMMENT  '',
  EN_BNYSXSY  DECIMAL(30,2)  COMMENT  '',
  EN_LJYSXSY  DECIMAL(30,2)  COMMENT  '',
  EN_LJKFPSY  DECIMAL(30,2)  COMMENT  '',
  EN_ZCCB  DECIMAL(19,2)  COMMENT  '',
  EN_CBDWJZ  DECIMAL(18,2)  COMMENT  '',
  VC_JJMC  STRING  COMMENT  '',
  EN_ZQZYJ  DECIMAL(30,2)  COMMENT  '',
  L_JJJB  DECIMAL(4,0)  COMMENT  '',
  EN_JDNHSYL  DECIMAL(19,6)  COMMENT  '',
  EN_DWXJCE  DECIMAL(19,4)  COMMENT  '',
  EN_QTTZSZ  DECIMAL(30,2)  COMMENT  '',
  EN_QTTZCB  DECIMAL(30,2)  COMMENT  '',
  EN_FDSY  DECIMAL(19,4)  COMMENT  '',
  EN_FDSYL  DECIMAL(19,6)  COMMENT  '',
  EN_GDSYL  DECIMAL(19,6)  COMMENT  '',
  EN_RNHSYL  DECIMAL(9,4)  COMMENT  '',
  EN_QJNHSYL  DECIMAL(19,6)  COMMENT  '',
  EN_FD7SYL  DECIMAL(19,6)  COMMENT  '',
  EN_GD7SYL  DECIMAL(19,6)  COMMENT  '',
  EN_JJRWFSY  DECIMAL(19,6)  COMMENT  '',
  EN_BYYSXSY  DECIMAL(30,2)  COMMENT  '',
  EN_FZCB  DECIMAL(30,2)  COMMENT  '',
  EN_WFSY  DECIMAL(34,19)  COMMENT  '',
  EN_LCCPZYJ  DECIMAL(30,2)  COMMENT  ''
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
                                   , TO_CHAR(D_RQ,'YYYYMMDD') D_RQ
                                   , VC_JJDM
                                   , VC_FJJJDM
                                   , EN_ZCHJ
                                   , EN_FZHJ
                                   , EN_ZCJZ
                                   , EN_ZCFE
                                   , EN_DWJZ
                                   , EN_JJSY
                                   , EN_DWJJSY
                                   , EN_NSYL
                                   , EN_XSFWF
                                   , EN_LJDWJZ
                                   , EN_GPSZ
                                   , EN_GPCB
                                   , EN_ZQSZ
                                   , EN_ZQCB
                                   , EN_QZSZ
                                   , EN_QZCB
                                   , EN_JJSZ
                                   , EN_JJCB
                                   , EN_BNYSXSY
                                   , EN_LJYSXSY
                                   , EN_LJKFPSY
                                   , EN_ZCCB
                                   , EN_CBDWJZ
                                   , VC_JJMC
                                   , EN_ZQZYJ
                                   , L_JJJB
                                   , EN_JDNHSYL
                                   , EN_DWXJCE
                                   , EN_QTTZSZ
                                   , EN_QTTZCB
                                   , EN_FDSY
                                   , EN_FDSYL
                                   , EN_GDSYL
                                   , EN_RNHSYL
                                   , EN_QJNHSYL
                                   , EN_FD7SYL
                                   , EN_GD7SYL
                                   , EN_JJRWFSY
                                   , EN_BYYSXSY
                                   , EN_FZCB
                                   , EN_WFSY
                                   , EN_LCCPZYJ
                                FROM ${hsfa_src_schema}.TJJMRHJSJ
                                WHERE D_RQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "D_RQ", "type": "STRING"}, {"name": "VC_JJDM", "type": "STRING"}, {"name": "VC_FJJJDM", "type": "STRING"}, {"name": "EN_ZCHJ", "type": "DOUBLE"}, {"name": "EN_FZHJ", "type": "DOUBLE"}, {"name": "EN_ZCJZ", "type": "DOUBLE"}, {"name": "EN_ZCFE", "type": "DOUBLE"}, {"name": "EN_DWJZ", "type": "DOUBLE"}, {"name": "EN_JJSY", "type": "DOUBLE"}, {"name": "EN_DWJJSY", "type": "DOUBLE"}, {"name": "EN_NSYL", "type": "DOUBLE"}, {"name": "EN_XSFWF", "type": "DOUBLE"}, {"name": "EN_LJDWJZ", "type": "DOUBLE"}, {"name": "EN_GPSZ", "type": "DOUBLE"}, {"name": "EN_GPCB", "type": "DOUBLE"}, {"name": "EN_ZQSZ", "type": "DOUBLE"}, {"name": "EN_ZQCB", "type": "DOUBLE"}, {"name": "EN_QZSZ", "type": "DOUBLE"}, {"name": "EN_QZCB", "type": "DOUBLE"}, {"name": "EN_JJSZ", "type": "DOUBLE"}, {"name": "EN_JJCB", "type": "DOUBLE"}, {"name": "EN_BNYSXSY", "type": "DOUBLE"}, {"name": "EN_LJYSXSY", "type": "DOUBLE"}, {"name": "EN_LJKFPSY", "type": "DOUBLE"}, {"name": "EN_ZCCB", "type": "DOUBLE"}, {"name": "EN_CBDWJZ", "type": "DOUBLE"}, {"name": "VC_JJMC", "type": "STRING"}, {"name": "EN_ZQZYJ", "type": "DOUBLE"}, {"name": "L_JJJB", "type": "DOUBLE"}, {"name": "EN_JDNHSYL", "type": "DOUBLE"}, {"name": "EN_DWXJCE", "type": "DOUBLE"}, {"name": "EN_QTTZSZ", "type": "DOUBLE"}, {"name": "EN_QTTZCB", "type": "DOUBLE"}, {"name": "EN_FDSY", "type": "DOUBLE"}, {"name": "EN_FDSYL", "type": "DOUBLE"}, {"name": "EN_GDSYL", "type": "DOUBLE"}, {"name": "EN_RNHSYL", "type": "DOUBLE"}, {"name": "EN_QJNHSYL", "type": "DOUBLE"}, {"name": "EN_FD7SYL", "type": "DOUBLE"}, {"name": "EN_GD7SYL", "type": "DOUBLE"}, {"name": "EN_JJRWFSY", "type": "DOUBLE"}, {"name": "EN_BYYSXSY", "type": "DOUBLE"}, {"name": "EN_FZCB", "type": "DOUBLE"}, {"name": "EN_WFSY", "type": "DOUBLE"}, {"name": "EN_LCCPZYJ", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tjjmrhjsj_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tjjmrhjsj_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tjjmrhjsj_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tjjmrhjsj_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TJJMRHJSJ_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TJJMRHJSJ_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tjjmrhjsj_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJMRHJSJ_PTD PARTITION(P_DT)
SELECT
       L_ZTBH
     , D_RQ
     , VC_JJDM
     , VC_FJJJDM
     , EN_ZCHJ
     , EN_FZHJ
     , EN_ZCJZ
     , EN_ZCFE
     , EN_DWJZ
     , EN_JJSY
     , EN_DWJJSY
     , EN_NSYL
     , EN_XSFWF
     , EN_LJDWJZ
     , EN_GPSZ
     , EN_GPCB
     , EN_ZQSZ
     , EN_ZQCB
     , EN_QZSZ
     , EN_QZCB
     , EN_JJSZ
     , EN_JJCB
     , EN_BNYSXSY
     , EN_LJYSXSY
     , EN_LJKFPSY
     , EN_ZCCB
     , EN_CBDWJZ
     , VC_JJMC
     , EN_ZQZYJ
     , L_JJJB
     , EN_JDNHSYL
     , EN_DWXJCE
     , EN_QTTZSZ
     , EN_QTTZCB
     , EN_FDSY
     , EN_FDSYL
     , EN_GDSYL
     , EN_RNHSYL
     , EN_QJNHSYL
     , EN_FD7SYL
     , EN_GD7SYL
     , EN_JJRWFSY
     , EN_BYYSXSY
     , EN_FZCB
     , EN_WFSY
     , EN_LCCPZYJ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_RQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TJJMRHJSJ_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJMRHJSJ_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TJJMRHJSJ_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TJJMRHJSJ_PTD成功"
      exit 0
   fi
fi
