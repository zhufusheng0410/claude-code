#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_CSZQXX_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_CSZQXX_PFD_TMP(
  FZQDM  STRING  COMMENT  '',
  FJJDM  STRING  COMMENT  '',
  FJXQSR  STRING  COMMENT  '',
  FJXJZR  STRING  COMMENT  '',
  FPMLV  DECIMAL(18,2)  COMMENT  '',
  FPMJE  DECIMAL(18,2)  COMMENT  '',
  FFXQX  DECIMAL(4,0)  COMMENT  '',
  FFXCS  DECIMAL(18,2)  COMMENT  '',
  FZQLB  STRING  COMMENT  '',
  FCXQSR  STRING  COMMENT  '',
  FCXJZR  STRING  COMMENT  '',
  FSQPMLV  DECIMAL(18,2)  COMMENT  '',
  FFXJG  DECIMAL(18,2)  COMMENT  '',
  FFXFS  DECIMAL(4,0)  COMMENT  '',
  FSH  DECIMAL(6,0)  COMMENT  '',
  FZZR  STRING  COMMENT  '',
  FCHK  STRING  COMMENT  '',
  FAN  DECIMAL(11,0)  COMMENT  '',
  FSCDM  STRING  COMMENT  '',
  FMEMO  STRING  COMMENT  '',
  FPZLB  STRING  COMMENT  '',
  FFXMS  STRING  COMMENT  '',
  FLEAPY  DECIMAL(18,2)  COMMENT  '',
  FDCHBFX  DECIMAL(11,0)  COMMENT  '',
  FJXNTS  DECIMAL(11,0)  COMMENT  '',
  FLXSDSV  DECIMAL(18,2)  COMMENT  '',
  FSZSH  STRING  COMMENT  '',
  FXZQLX  STRING  COMMENT  '',
  FXZQRQ  STRING  COMMENT  '',
  FXZQST  STRING  COMMENT  '',
  FXZQLV  DECIMAL(18,2)  COMMENT  '',
  FZQMC  STRING  COMMENT  '',
  FQXLXSZ  DECIMAL(18,2)  COMMENT  '',
  FGLDM  STRING  COMMENT  '',
  FBDLV  DECIMAL(18,2)  COMMENT  '',
  FJYFS  STRING  COMMENT  '',
  FXYPJ  STRING  COMMENT  '',
  FFXZT  STRING  COMMENT  ''
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
              "querySql": ["SELECT  FZQDM
                                   , FJJDM
                                   , FJXQSR
                                   , FJXJZR
                                   , FPMLV
                                   , FPMJE
                                   , FFXQX
                                   , FFXCS
                                   , FZQLB
                                   , FCXQSR
                                   , FCXJZR
                                   , FSQPMLV
                                   , FFXJG
                                   , FFXFS
                                   , FSH
                                   , FZZR
                                   , FCHK
                                   , FAN
                                   , FSCDM
                                   , FMEMO
                                   , FPZLB
                                   , FFXMS
                                   , FLEAPY
                                   , FDCHBFX
                                   , FJXNTS
                                   , FLXSDSV
                                   , FSZSH
                                   , FXZQLX
                                   , FXZQRQ
                                   , FXZQST
                                   , FXZQLV
                                   , FZQMC
                                   , FQXLXSZ
                                   , FGLDM
                                   , FBDLV
                                   , FJYFS
                                   , FXYPJ
                                   , FFXZT
                                FROM ${hsfa_src_schema}.CSZQXX"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "FZQDM", "type": "STRING"}, {"name": "FJJDM", "type": "STRING"}, {"name": "FJXQSR", "type": "STRING"}, {"name": "FJXJZR", "type": "STRING"}, {"name": "FPMLV", "type": "DOUBLE"}, {"name": "FPMJE", "type": "DOUBLE"}, {"name": "FFXQX", "type": "DOUBLE"}, {"name": "FFXCS", "type": "DOUBLE"}, {"name": "FZQLB", "type": "STRING"}, {"name": "FCXQSR", "type": "STRING"}, {"name": "FCXJZR", "type": "STRING"}, {"name": "FSQPMLV", "type": "DOUBLE"}, {"name": "FFXJG", "type": "DOUBLE"}, {"name": "FFXFS", "type": "DOUBLE"}, {"name": "FSH", "type": "DOUBLE"}, {"name": "FZZR", "type": "STRING"}, {"name": "FCHK", "type": "STRING"}, {"name": "FAN", "type": "DOUBLE"}, {"name": "FSCDM", "type": "STRING"}, {"name": "FMEMO", "type": "STRING"}, {"name": "FPZLB", "type": "STRING"}, {"name": "FFXMS", "type": "STRING"}, {"name": "FLEAPY", "type": "DOUBLE"}, {"name": "FDCHBFX", "type": "DOUBLE"}, {"name": "FJXNTS", "type": "DOUBLE"}, {"name": "FLXSDSV", "type": "DOUBLE"}, {"name": "FSZSH", "type": "STRING"}, {"name": "FXZQLX", "type": "STRING"}, {"name": "FXZQRQ", "type": "STRING"}, {"name": "FXZQST", "type": "STRING"}, {"name": "FXZQLV", "type": "DOUBLE"}, {"name": "FZQMC", "type": "STRING"}, {"name": "FQXLXSZ", "type": "DOUBLE"}, {"name": "FGLDM", "type": "STRING"}, {"name": "FBDLV", "type": "DOUBLE"}, {"name": "FJYFS", "type": "STRING"}, {"name": "FXYPJ", "type": "STRING"}, {"name": "FFXZT", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_cszqxx_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_cszqxx_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_cszqxx_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_cszqxx_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_CSZQXX_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_CSZQXX_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_cszqxx_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_CSZQXX_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       FZQDM
     , FJJDM
     , FJXQSR
     , FJXJZR
     , FPMLV
     , FPMJE
     , FFXQX
     , FFXCS
     , FZQLB
     , FCXQSR
     , FCXJZR
     , FSQPMLV
     , FFXJG
     , FFXFS
     , FSH
     , FZZR
     , FCHK
     , FAN
     , FSCDM
     , FMEMO
     , FPZLB
     , FFXMS
     , FLEAPY
     , FDCHBFX
     , FJXNTS
     , FLXSDSV
     , FSZSH
     , FXZQLX
     , FXZQRQ
     , FXZQST
     , FXZQLV
     , FZQMC
     , FQXLXSZ
     , FGLDM
     , FBDLV
     , FJYFS
     , FXYPJ
     , FFXZT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_CSZQXX_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_CSZQXX_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_CSZQXX_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_CSZQXX_PFD成功"
      exit 0
   fi
fi
