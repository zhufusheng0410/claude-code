#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TXTCS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXTCS_PFD_TMP(
  L_ZTBH  STRING  COMMENT  '帐套编号',
  VC_CSDM  STRING  COMMENT  '参数代码',
  VC_CSMC  STRING  COMMENT  '参数名称',
  VC_CSZ  STRING  COMMENT  '参数值',
  VC_CSSM  STRING  COMMENT  '参数说明',
  L_FLAG  DECIMAL(1,0)  COMMENT  '参数标记',
  VC_CSLX  STRING  COMMENT  '参数类型',
  VC_CSDL  STRING  COMMENT  '参数大类',
  L_CSSX  DECIMAL(8,0)  COMMENT  '参数顺序',
  VC_DQFS  STRING  COMMENT  '对齐方式',
  VC_JMBZ  STRING  COMMENT  '加密标志',
  L_SFYXBJ  DECIMAL(1,0)  COMMENT  '编辑状态',
  VC_CSNR  STRING  COMMENT  '参数内容',
  VC_CSXL  STRING  COMMENT  '参数小类',
  C_MULTI  STRING  COMMENT  '多选方式',
  L_SFKK  DECIMAL(1,0)  COMMENT  '是否可以为空',
  L_TYPE  STRING  COMMENT  '参数类型',
  VC_XGCSZ  STRING  COMMENT  '',
  VC_MAKER  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  L_STATE  DECIMAL(1,0)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  VC_JMFS  STRING  COMMENT  '',
  VC_ZZMK  STRING  COMMENT  '',
  VC_ZYKH  STRING  COMMENT  ''
)
COMMENT '系统参数表'
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
                                   , VC_CSDM
                                   , VC_CSMC
                                   , VC_CSZ
                                   , VC_CSSM
                                   , L_FLAG
                                   , VC_CSLX
                                   , VC_CSDL
                                   , L_CSSX
                                   , VC_DQFS
                                   , VC_JMBZ
                                   , L_SFYXBJ
                                   , VC_CSNR
                                   , VC_CSXL
                                   , C_MULTI
                                   , L_SFKK
                                   , L_TYPE
                                   , VC_XGCSZ
                                   , VC_MAKER
                                   , VC_FHR
                                   , L_STATE
                                   , D_MODIFY
                                   , VC_JMFS
                                   , VC_ZZMK
                                   , VC_ZYKH
                                FROM ${hsfa_src_schema}.TXTCS"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_CSDM", "type": "STRING"}, {"name": "VC_CSMC", "type": "STRING"}, {"name": "VC_CSZ", "type": "STRING"}, {"name": "VC_CSSM", "type": "STRING"}, {"name": "L_FLAG", "type": "DOUBLE"}, {"name": "VC_CSLX", "type": "STRING"}, {"name": "VC_CSDL", "type": "STRING"}, {"name": "L_CSSX", "type": "DOUBLE"}, {"name": "VC_DQFS", "type": "STRING"}, {"name": "VC_JMBZ", "type": "STRING"}, {"name": "L_SFYXBJ", "type": "DOUBLE"}, {"name": "VC_CSNR", "type": "STRING"}, {"name": "VC_CSXL", "type": "STRING"}, {"name": "C_MULTI", "type": "STRING"}, {"name": "L_SFKK", "type": "DOUBLE"}, {"name": "L_TYPE", "type": "DOUBLE"}, {"name": "VC_XGCSZ", "type": "STRING"}, {"name": "VC_MAKER", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "L_STATE", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "VC_JMFS", "type": "STRING"}, {"name": "VC_ZZMK", "type": "STRING"}, {"name": "VC_ZYKH", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_txtcs_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_txtcs_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_txtcs_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_txtcs_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TXTCS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TXTCS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_txtcs_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXTCS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZTBH
     , VC_CSDM
     , VC_CSMC
     , VC_CSZ
     , VC_CSSM
     , L_FLAG
     , VC_CSLX
     , VC_CSDL
     , L_CSSX
     , VC_DQFS
     , VC_JMBZ
     , L_SFYXBJ
     , VC_CSNR
     , VC_CSXL
     , C_MULTI
     , L_SFKK
     , L_TYPE
     , VC_XGCSZ
     , VC_MAKER
     , VC_FHR
     , L_STATE
     , D_MODIFY
     , VC_JMFS
     , VC_ZZMK
     , VC_ZYKH
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TXTCS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXTCS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TXTCS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TXTCS_PFD成功"
      exit 0
   fi
fi
