#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TXM_LS_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_LS_PTD_TMP(
  L_LSBH  DECIMAL(16,0)  COMMENT  '',
  L_BH  DECIMAL(8,0)  COMMENT  '',
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  D_DATE  STRING  COMMENT  '',
  L_YWLB  DECIMAL(4,0)  COMMENT  '',
  VC_TYPE  STRING  COMMENT  '',
  EN_BJBD  DECIMAL(19,4)  COMMENT  '',
  EN_LXBD  DECIMAL(19,4)  COMMENT  '',
  EN_FY  DECIMAL(19,4)  COMMENT  '',
  D_YERQ  STRING  COMMENT  '',
  EN_ZCLX  DECIMAL(19,4)  COMMENT  '',
  VC_JSBZ  STRING  COMMENT  '',
  EN_EXCH  DECIMAL(14,10)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  L_CLBZ  DECIMAL(4,0)  COMMENT  '',
  D_SCSJ  STRING  COMMENT  '',
  D_JXRQ  STRING  COMMENT  '',
  VC_BFZH  STRING  COMMENT  '',
  VC_SJLY  STRING  COMMENT  '',
  L_BDSL  DECIMAL(19,4)  COMMENT  '',
  EN_YJ  DECIMAL(19,4)  COMMENT  '',
  EN_CJJE  DECIMAL(19,4)  COMMENT  '',
  EN_QZHKLX  DECIMAL(19,4)  COMMENT  '',
  VC_BZ  STRING  COMMENT  '',
  L_JZJD  DECIMAL(1,0)  COMMENT  '',
  EN_ZCJZZB  DECIMAL(19,4)  COMMENT  '',
  EN_SRJZYE  DECIMAL(19,4)  COMMENT  '',
  L_SRJZJD  DECIMAL(1,0)  COMMENT  '',
  L_XZBZ  DECIMAL(2,0)  COMMENT  ''
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
              "querySql": ["SELECT  L_LSBH
                                   , L_BH
                                   , L_ZTBH
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , L_YWLB
                                   , VC_TYPE
                                   , EN_BJBD
                                   , EN_LXBD
                                   , EN_FY
                                   , D_YERQ
                                   , EN_ZCLX
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , VC_LLR
                                   , VC_FHR
                                   , L_CLBZ
                                   , D_SCSJ
                                   , D_JXRQ
                                   , VC_BFZH
                                   , VC_SJLY
                                   , L_BDSL
                                   , EN_YJ
                                   , EN_CJJE
                                   , EN_QZHKLX
                                   , VC_BZ
                                   , L_JZJD
                                   , EN_ZCJZZB
                                   , EN_SRJZYE
                                   , L_SRJZJD
                                   , L_XZBZ
                                FROM ${hsfa_src_schema}.TXM_LS
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_LSBH", "type": "DOUBLE"}, {"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "D_DATE", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "VC_TYPE", "type": "STRING"}, {"name": "EN_BJBD", "type": "DOUBLE"}, {"name": "EN_LXBD", "type": "DOUBLE"}, {"name": "EN_FY", "type": "DOUBLE"}, {"name": "D_YERQ", "type": "STRING"}, {"name": "EN_ZCLX", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "D_SCSJ", "type": "STRING"}, {"name": "D_JXRQ", "type": "STRING"}, {"name": "VC_BFZH", "type": "STRING"}, {"name": "VC_SJLY", "type": "STRING"}, {"name": "L_BDSL", "type": "DOUBLE"}, {"name": "EN_YJ", "type": "DOUBLE"}, {"name": "EN_CJJE", "type": "DOUBLE"}, {"name": "EN_QZHKLX", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "L_JZJD", "type": "DOUBLE"}, {"name": "EN_ZCJZZB", "type": "DOUBLE"}, {"name": "EN_SRJZYE", "type": "DOUBLE"}, {"name": "L_SRJZJD", "type": "DOUBLE"}, {"name": "L_XZBZ", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_txm_ls_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_txm_ls_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_txm_ls_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_txm_ls_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TXM_LS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TXM_LS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_txm_ls_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_LS_PTD PARTITION(P_DT)
SELECT
       L_LSBH
     , L_BH
     , L_ZTBH
     , D_DATE
     , L_YWLB
     , VC_TYPE
     , EN_BJBD
     , EN_LXBD
     , EN_FY
     , D_YERQ
     , EN_ZCLX
     , VC_JSBZ
     , EN_EXCH
     , VC_LLR
     , VC_FHR
     , L_CLBZ
     , D_SCSJ
     , D_JXRQ
     , VC_BFZH
     , VC_SJLY
     , L_BDSL
     , EN_YJ
     , EN_CJJE
     , EN_QZHKLX
     , VC_BZ
     , L_JZJD
     , EN_ZCJZZB
     , EN_SRJZYE
     , L_SRJZJD
     , L_XZBZ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TXM_LS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_LS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TXM_LS_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TXM_LS_PTD成功"
      exit 0
   fi
fi
