#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TSYSPARAMETER_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSYSPARAMETER_PFD_TMP(
  C_CLASS  STRING  COMMENT  '系统名称',
  C_ITEM  STRING  COMMENT  '分类',
  C_VALUE  STRING  COMMENT  '参数项',
  C_MODIFY  STRING  COMMENT  '参数值',
  C_DESCRIBE  STRING  COMMENT  '用户修改标志',
  C_CRYPTFLAG  STRING  COMMENT  '描述',
  C_TYPE  STRING  COMMENT  '加密标志',
  C_VALUEBOUND  STRING  COMMENT  '类型',
  C_SHOWCLASS  STRING  COMMENT  '值域',
  C_SHOWSUBCLASS  STRING  COMMENT  '显示大类',
  L_ORDER  DECIMAL(10,0)  COMMENT  '显示子类',
  C_SYSNAME  STRING  COMMENT  '顺序',
  C_FULLDESCRIBE  STRING  COMMENT  '详细说明'
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_CLASS
                                   , C_ITEM
                                   , C_VALUE
                                   , C_MODIFY
                                   , C_DESCRIBE
                                   , C_CRYPTFLAG
                                   , C_TYPE
                                   , C_VALUEBOUND
                                   , C_SHOWCLASS
                                   , C_SHOWSUBCLASS
                                   , L_ORDER
                                   , C_SYSNAME
                                   , C_FULLDESCRIBE
                                FROM ${hsfta_src_schema}.TSYSPARAMETER"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CLASS", "type": "STRING"}, {"name": "C_ITEM", "type": "STRING"}, {"name": "C_VALUE", "type": "STRING"}, {"name": "C_MODIFY", "type": "STRING"}, {"name": "C_DESCRIBE", "type": "STRING"}, {"name": "C_CRYPTFLAG", "type": "STRING"}, {"name": "C_TYPE", "type": "STRING"}, {"name": "C_VALUEBOUND", "type": "STRING"}, {"name": "C_SHOWCLASS", "type": "STRING"}, {"name": "C_SHOWSUBCLASS", "type": "STRING"}, {"name": "L_ORDER", "type": "DOUBLE"}, {"name": "C_SYSNAME", "type": "STRING"}, {"name": "C_FULLDESCRIBE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tsysparameter_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tsysparameter_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tsysparameter_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tsysparameter_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TSYSPARAMETER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TSYSPARAMETER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tsysparameter_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSYSPARAMETER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_CLASS
     , C_ITEM
     , C_VALUE
     , C_MODIFY
     , C_DESCRIBE
     , C_CRYPTFLAG
     , C_TYPE
     , C_VALUEBOUND
     , C_SHOWCLASS
     , C_SHOWSUBCLASS
     , L_ORDER
     , C_SYSNAME
     , C_FULLDESCRIBE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSYSPARAMETER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSYSPARAMETER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TSYSPARAMETER_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TSYSPARAMETER_PFD成功"
      exit 0
   fi
fi
