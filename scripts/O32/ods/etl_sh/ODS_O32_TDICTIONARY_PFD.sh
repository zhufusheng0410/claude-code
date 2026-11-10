#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TDICTIONARY_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TDICTIONARY_PFD_TMP(
  L_DICTIONARY_NO  DECIMAL(6,0)  COMMENT  '字典类别',
  C_LEMMA_ITEM  STRING  COMMENT  '词条键值',
  VC_ITEM_NAME  STRING  COMMENT  '中文说明',
  C_ALLOW_EDIT  STRING  COMMENT  '允许修改',
  L_CODE_LENGTH  STRING  COMMENT  '代码长度',
  C_LEMMA_TYPE  STRING  COMMENT  '键值类型',
  L_OPPOSITE_NO  DECIMAL(6,0)  COMMENT  '对应的数据字典',
  VC_OPPOSITE_ITEM  STRING  COMMENT  '对应的tem',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_CODE_MIN_LENGTH  DECIMAL(2,0)  COMMENT  ''
)
COMMENT '数据字典表'
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
              "querySql": ["SELECT  L_DICTIONARY_NO
                                   , C_LEMMA_ITEM
                                   , VC_ITEM_NAME
                                   , C_ALLOW_EDIT
                                   , L_CODE_LENGTH
                                   , C_LEMMA_TYPE
                                   , L_OPPOSITE_NO
                                   , VC_OPPOSITE_ITEM
                                   , L_VIRTUAL_KEY
                                   , VC_TIMESTAMP
                                   , L_CODE_MIN_LENGTH
                                FROM ${o32_src_schema}.TDICTIONARY"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DICTIONARY_NO", "type": "DOUBLE"}, {"name": "C_LEMMA_ITEM", "type": "STRING"}, {"name": "VC_ITEM_NAME", "type": "STRING"}, {"name": "C_ALLOW_EDIT", "type": "STRING"}, {"name": "L_CODE_LENGTH", "type": "DOUBLE"}, {"name": "C_LEMMA_TYPE", "type": "STRING"}, {"name": "L_OPPOSITE_NO", "type": "DOUBLE"}, {"name": "VC_OPPOSITE_ITEM", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_CODE_MIN_LENGTH", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tdictionary_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tdictionary_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tdictionary_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tdictionary_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TDICTIONARY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TDICTIONARY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tdictionary_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TDICTIONARY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DICTIONARY_NO
     , C_LEMMA_ITEM
     , VC_ITEM_NAME
     , C_ALLOW_EDIT
     , L_CODE_LENGTH
     , C_LEMMA_TYPE
     , L_OPPOSITE_NO
     , VC_OPPOSITE_ITEM
     , L_VIRTUAL_KEY
     , VC_TIMESTAMP
     , L_CODE_MIN_LENGTH
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TDICTIONARY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TDICTIONARY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TDICTIONARY_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TDICTIONARY_PFD成功"
      exit 0
   fi
fi
