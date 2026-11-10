#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TFLMX_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFLMX_PFD_TMP(
  L_ID  DECIMAL(10,0)  COMMENT  '',
  L_ZBBH  STRING  COMMENT  '主表编号',
  EN_JSDJ  DECIMAL(26,11)  COMMENT  '计算单价',
  EN_GDZ  DECIMAL(25,10)  COMMENT  '固定值',
  EN_MIN  DECIMAL(25,12)  COMMENT  '最小值',
  EN_MAX  DECIMAL(25,12)  COMMENT  '最大值',
  VC_TJSX  STRING  COMMENT  '条件上限',
  VC_TJXX  STRING  COMMENT  '条件下限',
  VC_BHSX  STRING  COMMENT  '包含上限',
  VC_BHXX  STRING  COMMENT  '包含下限',
  VC_JSFS  STRING  COMMENT  '计算方式',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  EN_ZKL  DECIMAL(10,9)  COMMENT  ''
)
COMMENT '费率明细表'
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
                                   , L_ZBBH
                                   , EN_JSDJ
                                   , EN_GDZ
                                   , EN_MIN
                                   , EN_MAX
                                   , VC_TJSX
                                   , VC_TJXX
                                   , VC_BHSX
                                   , VC_BHXX
                                   , VC_JSFS
                                   , VC_LLR
                                   , VC_FHR
                                   , EN_ZKL
                                FROM ${hsfa_src_schema}.TFLMX"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "L_ZBBH", "type": "DOUBLE"}, {"name": "EN_JSDJ", "type": "DOUBLE"}, {"name": "EN_GDZ", "type": "DOUBLE"}, {"name": "EN_MIN", "type": "DOUBLE"}, {"name": "EN_MAX", "type": "DOUBLE"}, {"name": "VC_TJSX", "type": "STRING"}, {"name": "VC_TJXX", "type": "STRING"}, {"name": "VC_BHSX", "type": "STRING"}, {"name": "VC_BHXX", "type": "STRING"}, {"name": "VC_JSFS", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "EN_ZKL", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tflmx_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tflmx_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tflmx_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tflmx_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TFLMX_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TFLMX_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tflmx_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFLMX_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ID
     , L_ZBBH
     , EN_JSDJ
     , EN_GDZ
     , EN_MIN
     , EN_MAX
     , VC_TJSX
     , VC_TJXX
     , VC_BHSX
     , VC_BHXX
     , VC_JSFS
     , VC_LLR
     , VC_FHR
     , EN_ZKL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFLMX_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFLMX_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TFLMX_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TFLMX_PFD成功"
      exit 0
   fi
fi
