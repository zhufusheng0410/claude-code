#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TJYDS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJYDS_PFD_TMP(
  VC_DSBH  STRING  COMMENT  '',
  VC_NAME  STRING  COMMENT  '',
  VC_LX  STRING  COMMENT  '',
  C_SYNCHRO_FLAG  STRING  COMMENT  '',
  D_SYNCHRO_TIME  STRING  COMMENT  '',
  L_LB  DECIMAL(1,0)  COMMENT  '',
  VC_XYDJ  STRING  COMMENT  '',
  VC_FULLNAME  STRING  COMMENT  '',
  VC_ORGNO  STRING  COMMENT  '',
  L_GPBZ  DECIMAL(1,0)  COMMENT  '',
  L_GLBZ  DECIMAL(1,0)  COMMENT  '',
  L_GLLX  DECIMAL(4,0)  COMMENT  '',
  EN_CFNL  DECIMAL(19,4)  COMMENT  '',
  EN_ZBCZL  DECIMAL(19,4)  COMMENT  '',
  L_FXJG  DECIMAL(1,0)  COMMENT  '',
  VC_LXMX  STRING  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  VC_TYSHXYDM  STRING  COMMENT  '',
  VC_JGLX_RHBS  STRING  COMMENT  ''
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
              "querySql": ["SELECT  VC_DSBH
                                   , VC_NAME
                                   , VC_LX
                                   , C_SYNCHRO_FLAG
                                   , D_SYNCHRO_TIME
                                   , L_LB
                                   , VC_XYDJ
                                   , VC_FULLNAME
                                   , VC_ORGNO
                                   , L_GPBZ
                                   , L_GLBZ
                                   , L_GLLX
                                   , EN_CFNL
                                   , EN_ZBCZL
                                   , L_FXJG
                                   , VC_LXMX
                                   , D_MODIFY
                                   , VC_TYSHXYDM
                                   , VC_JGLX_RHBS
                                FROM ${hsfa_src_schema}.TJYDS"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_DSBH", "type": "STRING"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "VC_LX", "type": "STRING"}, {"name": "C_SYNCHRO_FLAG", "type": "STRING"}, {"name": "D_SYNCHRO_TIME", "type": "STRING"}, {"name": "L_LB", "type": "DOUBLE"}, {"name": "VC_XYDJ", "type": "STRING"}, {"name": "VC_FULLNAME", "type": "STRING"}, {"name": "VC_ORGNO", "type": "STRING"}, {"name": "L_GPBZ", "type": "DOUBLE"}, {"name": "L_GLBZ", "type": "DOUBLE"}, {"name": "L_GLLX", "type": "DOUBLE"}, {"name": "EN_CFNL", "type": "DOUBLE"}, {"name": "EN_ZBCZL", "type": "DOUBLE"}, {"name": "L_FXJG", "type": "DOUBLE"}, {"name": "VC_LXMX", "type": "STRING"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "VC_TYSHXYDM", "type": "STRING"}, {"name": "VC_JGLX_RHBS", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tjyds_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tjyds_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tjyds_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tjyds_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TJYDS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TJYDS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tjyds_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJYDS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_DSBH
     , VC_NAME
     , VC_LX
     , C_SYNCHRO_FLAG
     , D_SYNCHRO_TIME
     , L_LB
     , VC_XYDJ
     , VC_FULLNAME
     , VC_ORGNO
     , L_GPBZ
     , L_GLBZ
     , L_GLLX
     , EN_CFNL
     , EN_ZBCZL
     , L_FXJG
     , VC_LXMX
     , D_MODIFY
     , VC_TYSHXYDM
     , VC_JGLX_RHBS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TJYDS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJYDS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TJYDS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TJYDS_PFD成功"
      exit 0
   fi
fi
