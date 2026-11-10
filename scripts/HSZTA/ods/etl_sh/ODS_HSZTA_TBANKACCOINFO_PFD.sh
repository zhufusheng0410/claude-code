#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TBANKACCOINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TBANKACCOINFO_PFD_TMP(
  L_BANKACCONO  DECIMAL(10,0)  COMMENT  '',
  C_BANKACCONAME  STRING  COMMENT  '',
  C_BANKNO  STRING  COMMENT  '',
  C_BANKACCO  STRING  COMMENT  '',
  C_NAMEINBANK  STRING  COMMENT  '',
  C_BANKNAME  STRING  COMMENT  '',
  C_PROVINCE  STRING  COMMENT  '',
  C_CITY  STRING  COMMENT  '',
  C_REGIONNO  STRING  COMMENT  '',
  C_BRANCHCODE  STRING  COMMENT  '',
  C_BANKUNIONNO  STRING  COMMENT  '',
  C_EMAIL  STRING  COMMENT  '',
  C_MOBILENO  STRING  COMMENT  '',
  C_FAXNO  STRING  COMMENT  '',
  C_ACCOTYPE  STRING  COMMENT  '',
  C_ADDRESS  STRING  COMMENT  ''
)
COMMENT '银行账户信息表'
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  L_BANKACCONO
                                   , C_BANKACCONAME
                                   , C_BANKNO
                                   , C_BANKACCO
                                   , C_NAMEINBANK
                                   , C_BANKNAME
                                   , C_PROVINCE
                                   , C_CITY
                                   , C_REGIONNO
                                   , C_BRANCHCODE
                                   , C_BANKUNIONNO
                                   , C_EMAIL
                                   , C_MOBILENO
                                   , C_FAXNO
                                   , C_ACCOTYPE
                                   , C_ADDRESS
                                FROM ${hszta_src_schema}.TBANKACCOINFO"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BANKACCONO", "type": "DOUBLE"}, {"name": "C_BANKACCONAME", "type": "STRING"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_BANKACCO", "type": "STRING"}, {"name": "C_NAMEINBANK", "type": "STRING"}, {"name": "C_BANKNAME", "type": "STRING"}, {"name": "C_PROVINCE", "type": "STRING"}, {"name": "C_CITY", "type": "STRING"}, {"name": "C_REGIONNO", "type": "STRING"}, {"name": "C_BRANCHCODE", "type": "STRING"}, {"name": "C_BANKUNIONNO", "type": "STRING"}, {"name": "C_EMAIL", "type": "STRING"}, {"name": "C_MOBILENO", "type": "STRING"}, {"name": "C_FAXNO", "type": "STRING"}, {"name": "C_ACCOTYPE", "type": "STRING"}, {"name": "C_ADDRESS", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tbankaccoinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tbankaccoinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tbankaccoinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tbankaccoinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TBANKACCOINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TBANKACCOINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tbankaccoinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TBANKACCOINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BANKACCONO
     , C_BANKACCONAME
     , C_BANKNO
     , C_BANKACCO
     , C_NAMEINBANK
     , C_BANKNAME
     , C_PROVINCE
     , C_CITY
     , C_REGIONNO
     , C_BRANCHCODE
     , C_BANKUNIONNO
     , C_EMAIL
     , C_MOBILENO
     , C_FAXNO
     , C_ACCOTYPE
     , C_ADDRESS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TBANKACCOINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TBANKACCOINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TBANKACCOINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TBANKACCOINFO_PFD成功"
      exit 0
   fi
fi
