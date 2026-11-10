#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_THKZH_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_THKZH_PFD_TMP(
  L_ID  DECIMAL(8,0)  COMMENT  '',
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  L_ZHLB  DECIMAL(4,0)  COMMENT  '',
  VC_MC  STRING  COMMENT  '',
  VC_KHH  STRING  COMMENT  '',
  VC_ZH  STRING  COMMENT  '',
  VC_DSBH  STRING  COMMENT  '',
  VC_YT  STRING  COMMENT  '',
  VC_BZ  STRING  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  VC_MAKER  STRING  COMMENT  '',
  VC_KMDM  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  VC_DEZFH  STRING  COMMENT  '',
  VC_KHD  STRING  COMMENT  '',
  VC_ZFXTH  STRING  COMMENT  '',
  VC_ZDTABFJZH  STRING  COMMENT  '',
  L_XYZH  DECIMAL(1,0)  COMMENT  '',
  VC_QHSBH  STRING  COMMENT  '',
  VC_QHSMC  STRING  COMMENT  '',
  VC_ZQGSMC  STRING  COMMENT  '',
  VC_HKHZH  STRING  COMMENT  '',
  L_ZHLX  DECIMAL(2,0)  COMMENT  '',
  VC_QSBH  STRING  COMMENT  ''
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
              "querySql": ["SELECT  L_ID
                                   , L_ZTBH
                                   , L_ZHLB
                                   , VC_MC
                                   , VC_KHH
                                   , VC_ZH
                                   , VC_DSBH
                                   , VC_YT
                                   , VC_BZ
                                   , D_MODIFY
                                   , VC_MAKER
                                   , VC_KMDM
                                   , VC_FHR
                                   , VC_DEZFH
                                   , VC_KHD
                                   , VC_ZFXTH
                                   , VC_ZDTABFJZH
                                   , L_XYZH
                                   , VC_QHSBH
                                   , VC_QHSMC
                                   , VC_ZQGSMC
                                   , VC_HKHZH
                                   , L_ZHLX
                                   , VC_QSBH
                                FROM ${hsfa_src_schema}.THKZH"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_ZHLB", "type": "DOUBLE"}, {"name": "VC_MC", "type": "STRING"}, {"name": "VC_KHH", "type": "STRING"}, {"name": "VC_ZH", "type": "STRING"}, {"name": "VC_DSBH", "type": "STRING"}, {"name": "VC_YT", "type": "STRING"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "VC_MAKER", "type": "STRING"}, {"name": "VC_KMDM", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_DEZFH", "type": "STRING"}, {"name": "VC_KHD", "type": "STRING"}, {"name": "VC_ZFXTH", "type": "STRING"}, {"name": "VC_ZDTABFJZH", "type": "STRING"}, {"name": "L_XYZH", "type": "DOUBLE"}, {"name": "VC_QHSBH", "type": "STRING"}, {"name": "VC_QHSMC", "type": "STRING"}, {"name": "VC_ZQGSMC", "type": "STRING"}, {"name": "VC_HKHZH", "type": "STRING"}, {"name": "L_ZHLX", "type": "DOUBLE"}, {"name": "VC_QSBH", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_thkzh_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_thkzh_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_thkzh_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_thkzh_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_THKZH_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_THKZH_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_thkzh_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_THKZH_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ID
     , L_ZTBH
     , L_ZHLB
     , VC_MC
     , VC_KHH
     , VC_ZH
     , VC_DSBH
     , VC_YT
     , VC_BZ
     , D_MODIFY
     , VC_MAKER
     , VC_KMDM
     , VC_FHR
     , VC_DEZFH
     , VC_KHD
     , VC_ZFXTH
     , VC_ZDTABFJZH
     , L_XYZH
     , VC_QHSBH
     , VC_QHSMC
     , VC_ZQGSMC
     , VC_HKHZH
     , L_ZHLX
     , VC_QSBH
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_THKZH_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_THKZH_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_THKZH_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_THKZH_PFD成功"
      exit 0
   fi
fi
