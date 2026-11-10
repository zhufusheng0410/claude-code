#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLS_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLS_PTD_TMP(
  L_ZTBH  STRING  COMMENT  '账套编号',
  L_CKID  DECIMAL(20,0)  COMMENT  '存款序号',
  L_LSID  DECIMAL(12,0)  COMMENT  '业务流水序号',
  VC_TYPE  STRING  COMMENT  '流水类别',
  D_DATE  STRING  COMMENT  '业务日期',
  D_EDATE  STRING  COMMENT  '展期日期',
  L_STATE  DECIMAL(3,0)  COMMENT  '流水状态',
  EN_BJBD  DECIMAL(19,4)  COMMENT  '本金变动',
  EN_LXBD  DECIMAL(19,4)  COMMENT  '利息变动',
  VC_BJDYKM  STRING  COMMENT  '本金对应科目',
  L_CZR  DECIMAL(4,0)  COMMENT  '操作人',
  L_FHR  DECIMAL(4,0)  COMMENT  '复核人',
  EN_EXCH  DECIMAL(18,14)  COMMENT  '汇率',
  L_CLBZ  STRING  COMMENT  '处理标志',
  VC_BZ  STRING  COMMENT  '备注',
  L_BFZQLX  DECIMAL(4,0)  COMMENT  '',
  VC_SJLY  STRING  COMMENT  '',
  L_ID  DECIMAL(8,0)  COMMENT  '',
  D_JXRQ  STRING  COMMENT  '',
  EN_ZLX  DECIMAL(19,4)  COMMENT  '',
  L_JZJD  DECIMAL(1,0)  COMMENT  '',
  EN_ZCJZZB  DECIMAL(19,4)  COMMENT  '',
  EN_ZCLX  DECIMAL(19,4)  COMMENT  '',
  EN_SRJZYE  DECIMAL(19,4)  COMMENT  '',
  L_SRJZJD  DECIMAL(1,0)  COMMENT  ''
)
COMMENT '存款业务交易流水表'
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
                                   , L_LSID
                                   , VC_TYPE
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , D_EDATE
                                   , L_STATE
                                   , EN_BJBD
                                   , EN_LXBD
                                   , VC_BJDYKM
                                   , L_CZR
                                   , L_FHR
                                   , EN_EXCH
                                   , L_CLBZ
                                   , VC_BZ
                                   , L_BFZQLX
                                   , VC_SJLY
                                   , L_ID
                                   , D_JXRQ
                                   , EN_ZLX
                                   , L_JZJD
                                   , EN_ZCJZZB
                                   , EN_ZCLX
                                   , EN_SRJZYE
                                   , L_SRJZJD
                                FROM ${hsfa_src_schema}.TCAP_CKYWLS
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_CKID", "type": "DOUBLE"}, {"name": "L_LSID", "type": "DOUBLE"}, {"name": "VC_TYPE", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "D_EDATE", "type": "STRING"}, {"name": "L_STATE", "type": "DOUBLE"}, {"name": "EN_BJBD", "type": "DOUBLE"}, {"name": "EN_LXBD", "type": "DOUBLE"}, {"name": "VC_BJDYKM", "type": "STRING"}, {"name": "L_CZR", "type": "DOUBLE"}, {"name": "L_FHR", "type": "DOUBLE"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "L_BFZQLX", "type": "DOUBLE"}, {"name": "VC_SJLY", "type": "STRING"}, {"name": "L_ID", "type": "DOUBLE"}, {"name": "D_JXRQ", "type": "STRING"}, {"name": "EN_ZLX", "type": "DOUBLE"}, {"name": "L_JZJD", "type": "DOUBLE"}, {"name": "EN_ZCJZZB", "type": "DOUBLE"}, {"name": "EN_ZCLX", "type": "DOUBLE"}, {"name": "EN_SRJZYE", "type": "DOUBLE"}, {"name": "L_SRJZJD", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tcap_ckywls_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tcap_ckywls_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tcap_ckywls_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tcap_ckywls_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TCAP_CKYWLS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TCAP_CKYWLS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tcap_ckywls_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLS_PTD PARTITION(P_DT)
SELECT
       L_ZTBH
     , L_CKID
     , L_LSID
     , VC_TYPE
     , D_DATE
     , D_EDATE
     , L_STATE
     , EN_BJBD
     , EN_LXBD
     , VC_BJDYKM
     , L_CZR
     , L_FHR
     , EN_EXCH
     , L_CLBZ
     , VC_BZ
     , L_BFZQLX
     , VC_SJLY
     , L_ID
     , D_JXRQ
     , EN_ZLX
     , L_JZJD
     , EN_ZCJZZB
     , EN_ZCLX
     , EN_SRJZYE
     , L_SRJZJD
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYWLS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TCAP_CKYWLS_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TCAP_CKYWLS_PTD成功"
      exit 0
   fi
fi
