#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TYTTX_FDSZ_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYTTX_FDSZ_PFD_TMP(
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  L_ZBBH  DECIMAL(10,0)  COMMENT  '',
  EN_FDTJMAX  DECIMAL(19,4)  COMMENT  '',
  EN_FDTJMIN  DECIMAL(19,4)  COMMENT  '',
  EN_JTBL  DECIMAL(15,15)  COMMENT  '',
  C_BHJMAX  STRING  COMMENT  '',
  C_BHJMIN  STRING  COMMENT  '',
  EN_YJBJJZ  DECIMAL(19,4)  COMMENT  ''
)
COMMENT '预提摊销-浮动设置'
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
                                   , L_ZBBH
                                   , EN_FDTJMAX
                                   , EN_FDTJMIN
                                   , EN_JTBL
                                   , C_BHJMAX
                                   , C_BHJMIN
                                   , EN_YJBJJZ
                                FROM ${hsfa_src_schema}.TYTTX_FDSZ"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_ZBBH", "type": "DOUBLE"}, {"name": "EN_FDTJMAX", "type": "DOUBLE"}, {"name": "EN_FDTJMIN", "type": "DOUBLE"}, {"name": "EN_JTBL", "type": "DOUBLE"}, {"name": "C_BHJMAX", "type": "STRING"}, {"name": "C_BHJMIN", "type": "STRING"}, {"name": "EN_YJBJJZ", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tyttx_fdsz_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tyttx_fdsz_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tyttx_fdsz_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tyttx_fdsz_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TYTTX_FDSZ_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TYTTX_FDSZ_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tyttx_fdsz_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYTTX_FDSZ_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZTBH
     , L_ZBBH
     , EN_FDTJMAX
     , EN_FDTJMIN
     , EN_JTBL
     , C_BHJMAX
     , C_BHJMIN
     , EN_YJBJJZ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TYTTX_FDSZ_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYTTX_FDSZ_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TYTTX_FDSZ_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TYTTX_FDSZ_PFD成功"
      exit 0
   fi
fi
