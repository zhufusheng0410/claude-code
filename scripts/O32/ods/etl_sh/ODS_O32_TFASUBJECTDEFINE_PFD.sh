#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFASUBJECTDEFINE_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFASUBJECTDEFINE_PFD_TMP(
  C_ACCOUNT_TYPE  STRING  COMMENT  '账套类型',
  VC_FINANCE_SUBJECT  STRING  COMMENT  '财务系统科目编号',
  VC_FINANCE_NAME  STRING  COMMENT  '科目名称',
  C_ASSET_CLASS  STRING  COMMENT  '资产类别',
  C_FROZEN_FLAG  STRING  COMMENT  '冻结标志',
  VC_SUMMARY  STRING  COMMENT  '备注',
  C_MARKET_NO  STRING  COMMENT  '市场',
  C_DIRECTION  STRING  COMMENT  '方向',
  L_SUBJECT_NO  DECIMAL(10,0)  COMMENT  '系统科目',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  C_POSITION_FLAG  STRING  COMMENT  '多空标志',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键'
)
COMMENT '财务科目定义表'
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
            "username": "${o32_username}",
            "password": "${o32_password}",
            "connection": [{
              "querySql": ["SELECT  C_ACCOUNT_TYPE
                                   , VC_FINANCE_SUBJECT
                                   , VC_FINANCE_NAME
                                   , C_ASSET_CLASS
                                   , C_FROZEN_FLAG
                                   , VC_SUMMARY
                                   , C_MARKET_NO
                                   , C_DIRECTION
                                   , L_SUBJECT_NO
                                   , VC_CURRENCY_NO
                                   , C_POSITION_FLAG
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                FROM ${o32_src_schema}.TFASUBJECTDEFINE"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_ACCOUNT_TYPE", "type": "STRING"}, {"name": "VC_FINANCE_SUBJECT", "type": "STRING"}, {"name": "VC_FINANCE_NAME", "type": "STRING"}, {"name": "C_ASSET_CLASS", "type": "STRING"}, {"name": "C_FROZEN_FLAG", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "C_DIRECTION", "type": "STRING"}, {"name": "L_SUBJECT_NO", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfasubjectdefine_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfasubjectdefine_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfasubjectdefine_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfasubjectdefine_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFASUBJECTDEFINE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFASUBJECTDEFINE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfasubjectdefine_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFASUBJECTDEFINE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_ACCOUNT_TYPE
     , VC_FINANCE_SUBJECT
     , VC_FINANCE_NAME
     , C_ASSET_CLASS
     , C_FROZEN_FLAG
     , VC_SUMMARY
     , C_MARKET_NO
     , C_DIRECTION
     , L_SUBJECT_NO
     , VC_CURRENCY_NO
     , C_POSITION_FLAG
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TFASUBJECTDEFINE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFASUBJECTDEFINE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFASUBJECTDEFINE_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFASUBJECTDEFINE_PFD成功"
      exit 0
   fi
fi
