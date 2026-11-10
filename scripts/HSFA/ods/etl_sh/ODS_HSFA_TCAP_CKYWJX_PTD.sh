#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWJX_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWJX_PTD_TMP(
  L_ZTBH  STRING  COMMENT  '帐套编号',
  L_CKID  DECIMAL(20,0)  COMMENT  '存款序号',
  D_DATE  STRING  COMMENT  '计息日期',
  EN_YJLX  DECIMAL(19,4)  COMMENT  '应计利息',
  EN_LJLX  DECIMAL(19,4)  COMMENT  '累计利息',
  EN_EXCH  DECIMAL(18,14)  COMMENT  '汇率'
)
COMMENT '存款业务计息表'
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
                                   , L_CKID
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , EN_YJLX
                                   , EN_LJLX
                                   , EN_EXCH
                                FROM ${hsfa_src_schema}.TCAP_CKYWJX
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_CKID", "type": "DOUBLE"}, {"name": "D_DATE", "type": "STRING"}, {"name": "EN_YJLX", "type": "DOUBLE"}, {"name": "EN_LJLX", "type": "DOUBLE"}, {"name": "EN_EXCH", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tcap_ckywjx_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tcap_ckywjx_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tcap_ckywjx_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tcap_ckywjx_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TCAP_CKYWJX_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TCAP_CKYWJX_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tcap_ckywjx_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWJX_PTD PARTITION(P_DT)
SELECT
       L_ZTBH
     , L_CKID
     , D_DATE
     , EN_YJLX
     , EN_LJLX
     , EN_EXCH
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWJX_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWJX_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TCAP_CKYWJX_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TCAP_CKYWJX_PTD成功"
      exit 0
   fi
fi
