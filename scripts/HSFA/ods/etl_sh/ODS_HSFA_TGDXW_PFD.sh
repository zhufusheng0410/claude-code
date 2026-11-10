#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TGDXW_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGDXW_PFD_TMP(
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  L_LB  DECIMAL(1,0)  COMMENT  '',
  VC_CODE  STRING  COMMENT  '',
  L_SCLB  DECIMAL(2,0)  COMMENT  '',
  VC_XWLX  STRING  COMMENT  '',
  L_TZLX  DECIMAL(1,0)  COMMENT  '',
  L_JGHF  DECIMAL(1,0)  COMMENT  '',
  VC_NAME  STRING  COMMENT  '',
  VC_ZJZH  STRING  COMMENT  '',
  L_TQBZ  DECIMAL(4,0)  COMMENT  '',
  L_JSJG  DECIMAL(1,0)  COMMENT  '',
  VC_QSBH  STRING  COMMENT  '',
  VC_JYHY  STRING  COMMENT  '',
  L_ID  DECIMAL(10,0)  COMMENT  '',
  L_XYZH  DECIMAL(1,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  VC_COMMENT  STRING  COMMENT  '',
  D_BEGIN  STRING  COMMENT  '',
  D_END  STRING  COMMENT  '',
  VC_GDBH  STRING  COMMENT  '',
  L_JCHJZF  DECIMAL(1,0)  COMMENT  '',
  L_YJJSXF  DECIMAL(1,0)  COMMENT  '',
  L_YJJJSF  DECIMAL(1,0)  COMMENT  '',
  L_YJJZGF  DECIMAL(1,0)  COMMENT  ''
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
                                   , L_LB
                                   , VC_CODE
                                   , L_SCLB
                                   , VC_XWLX
                                   , L_TZLX
                                   , L_JGHF
                                   , VC_NAME
                                   , VC_ZJZH
                                   , L_TQBZ
                                   , L_JSJG
                                   , VC_QSBH
                                   , VC_JYHY
                                   , L_ID
                                   , L_XYZH
                                   , VC_LLR
                                   , VC_FHR
                                   , VC_COMMENT
                                   , D_BEGIN
                                   , D_END
                                   , VC_GDBH
                                   , L_JCHJZF
                                   , L_YJJSXF
                                   , L_YJJJSF
                                   , L_YJJZGF
                                FROM ${hsfa_src_schema}.TGDXW"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_LB", "type": "DOUBLE"}, {"name": "VC_CODE", "type": "STRING"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "VC_XWLX", "type": "STRING"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "L_JGHF", "type": "DOUBLE"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "VC_ZJZH", "type": "STRING"}, {"name": "L_TQBZ", "type": "DOUBLE"}, {"name": "L_JSJG", "type": "DOUBLE"}, {"name": "VC_QSBH", "type": "STRING"}, {"name": "VC_JYHY", "type": "STRING"}, {"name": "L_ID", "type": "DOUBLE"}, {"name": "L_XYZH", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_COMMENT", "type": "STRING"}, {"name": "D_BEGIN", "type": "STRING"}, {"name": "D_END", "type": "STRING"}, {"name": "VC_GDBH", "type": "STRING"}, {"name": "L_JCHJZF", "type": "DOUBLE"}, {"name": "L_YJJSXF", "type": "DOUBLE"}, {"name": "L_YJJJSF", "type": "DOUBLE"}, {"name": "L_YJJZGF", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tgdxw_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tgdxw_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tgdxw_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tgdxw_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TGDXW_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TGDXW_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tgdxw_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGDXW_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZTBH
     , L_LB
     , VC_CODE
     , L_SCLB
     , VC_XWLX
     , L_TZLX
     , L_JGHF
     , VC_NAME
     , VC_ZJZH
     , L_TQBZ
     , L_JSJG
     , VC_QSBH
     , VC_JYHY
     , L_ID
     , L_XYZH
     , VC_LLR
     , VC_FHR
     , VC_COMMENT
     , D_BEGIN
     , D_END
     , VC_GDBH
     , L_JCHJZF
     , L_YJJSXF
     , L_YJJJSF
     , L_YJJZGF
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TGDXW_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGDXW_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TGDXW_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TGDXW_PFD成功"
      exit 0
   fi
fi
