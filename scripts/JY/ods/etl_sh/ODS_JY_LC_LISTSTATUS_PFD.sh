#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_LISTSTATUS_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_LISTSTATUS_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  CHANGEDATE  STRING  COMMENT  '全称更改日期',
  SECUMARKET  DECIMAL(10,0)  COMMENT  '证券市场',
  CHANGETYPE  DECIMAL(10,0)  COMMENT  '变动原因',
  CHANGEREASON  DECIMAL(10,0)  COMMENT  '简称变更原因',
  STATEMENT  STRING  COMMENT  '备注说明',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  LARGEAPPLYINGMAX  DECIMAL(19,4)  COMMENT  '基金大额申购上限(元)',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '上市状态更改'
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
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , INNERCODE
                                   , CHANGEDATE
                                   , SECUMARKET
                                   , CHANGETYPE
                                   , CHANGEREASON
                                   , STATEMENT
                                   , XGRQ
                                   , JSID
                                   , LARGEAPPLYINGMAX
                                   , INSERTTIME
                                FROM ${jy_src_schema}.LC_LISTSTATUS"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "CHANGEDATE", "type": "STRING"}, {"name": "SECUMARKET", "type": "DOUBLE"}, {"name": "CHANGETYPE", "type": "DOUBLE"}, {"name": "CHANGEREASON", "type": "DOUBLE"}, {"name": "STATEMENT", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "LARGEAPPLYINGMAX", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_liststatus_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_liststatus_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_liststatus_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_liststatus_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_LISTSTATUS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_LISTSTATUS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_liststatus_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_LISTSTATUS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , CHANGEDATE
     , SECUMARKET
     , CHANGETYPE
     , CHANGEREASON
     , STATEMENT
     , XGRQ
     , JSID
     , LARGEAPPLYINGMAX
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_LISTSTATUS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_LISTSTATUS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_LISTSTATUS_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_LISTSTATUS_PFD成功"
      exit 0
   fi
fi
