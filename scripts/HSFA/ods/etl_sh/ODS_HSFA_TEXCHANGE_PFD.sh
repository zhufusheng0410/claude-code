#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TEXCHANGE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TEXCHANGE_PFD_TMP(
  L_ID  DECIMAL(4,0)  COMMENT  '币种ID',
  VC_NAME  STRING  COMMENT  '币种名称',
  L_DECIMAL  DECIMAL(2,0)  COMMENT  '放弃使用',
  D_CREATE  STRING  COMMENT  '创建日期',
  D_DESTORY  STRING  COMMENT  '终止日期',
  L_VOID  DECIMAL(1,0)  COMMENT  '废除标记',
  VC_GJBM  STRING  COMMENT  '国际编码',
  L_FUNDID  DECIMAL(9,0)  COMMENT  ''
)
COMMENT '币种信息表'
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
                                   , VC_NAME
                                   , L_DECIMAL
                                   , D_CREATE
                                   , D_DESTORY
                                   , L_VOID
                                   , VC_GJBM
                                   , L_FUNDID
                                FROM ${hsfa_src_schema}.TEXCHANGE"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "L_DECIMAL", "type": "DOUBLE"}, {"name": "D_CREATE", "type": "STRING"}, {"name": "D_DESTORY", "type": "STRING"}, {"name": "L_VOID", "type": "DOUBLE"}, {"name": "VC_GJBM", "type": "STRING"}, {"name": "L_FUNDID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_texchange_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_texchange_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_texchange_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_texchange_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TEXCHANGE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TEXCHANGE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_texchange_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TEXCHANGE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ID
     , VC_NAME
     , L_DECIMAL
     , D_CREATE
     , D_DESTORY
     , L_VOID
     , VC_GJBM
     , L_FUNDID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TEXCHANGE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TEXCHANGE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TEXCHANGE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TEXCHANGE_PFD成功"
      exit 0
   fi
fi
