#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TDIMENSIONCLASS_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TDIMENSIONCLASS_PFD_TMP(
  C_DIMENSION_CODE  STRING  COMMENT  '维度类别编号',
  VC_DIMENSION_NAME  STRING  COMMENT  '维度类别名称',
  C_TYPE  STRING  COMMENT  '类型',
  C_LEVEL_FLAG  STRING  COMMENT  '级别标志',
  C_FUND_SPEC  STRING  COMMENT  '允许单基金特殊',
  C_LEVEL_POWER  STRING  COMMENT  '分支是否有权重',
  C_STOCK_POWER  STRING  COMMENT  '证券是否有权重',
  C_MUTEX  STRING  COMMENT  '同级互斥',
  C_CONTAIN  STRING  COMMENT  '上级包含下级',
  C_COMPANY_RELATION  STRING  COMMENT  '基金级与公司级关系'
)
COMMENT '维度类别定义表'
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
              "querySql": ["SELECT  C_DIMENSION_CODE
                                   , VC_DIMENSION_NAME
                                   , C_TYPE
                                   , C_LEVEL_FLAG
                                   , C_FUND_SPEC
                                   , C_LEVEL_POWER
                                   , C_STOCK_POWER
                                   , C_MUTEX
                                   , C_CONTAIN
                                   , C_COMPANY_RELATION
                                FROM ${o32_src_schema}.TDIMENSIONCLASS"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_DIMENSION_CODE", "type": "STRING"}, {"name": "VC_DIMENSION_NAME", "type": "STRING"}, {"name": "C_TYPE", "type": "STRING"}, {"name": "C_LEVEL_FLAG", "type": "STRING"}, {"name": "C_FUND_SPEC", "type": "STRING"}, {"name": "C_LEVEL_POWER", "type": "STRING"}, {"name": "C_STOCK_POWER", "type": "STRING"}, {"name": "C_MUTEX", "type": "STRING"}, {"name": "C_CONTAIN", "type": "STRING"}, {"name": "C_COMPANY_RELATION", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tdimensionclass_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tdimensionclass_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tdimensionclass_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tdimensionclass_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TDIMENSIONCLASS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TDIMENSIONCLASS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tdimensionclass_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TDIMENSIONCLASS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_DIMENSION_CODE
     , VC_DIMENSION_NAME
     , C_TYPE
     , C_LEVEL_FLAG
     , C_FUND_SPEC
     , C_LEVEL_POWER
     , C_STOCK_POWER
     , C_MUTEX
     , C_CONTAIN
     , C_COMPANY_RELATION
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TDIMENSIONCLASS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TDIMENSIONCLASS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TDIMENSIONCLASS_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TDIMENSIONCLASS_PFD成功"
      exit 0
   fi
fi
