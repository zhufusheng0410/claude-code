#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBONDDETAILPROPERTY_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBONDDETAILPROPERTY_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  C_TAX_TYPE  STRING  COMMENT  '税率类型',
  C_PLAN_TYPE  STRING  COMMENT  '投资计划类型',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  EN_INTEREST_TAX  DECIMAL(9,8)  COMMENT  '利息税率',
  L_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '维护日期',
  C_MARKET_NO  STRING  COMMENT  '市场编号',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键'
)
COMMENT '债券附加属性表'
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
              "querySql": ["SELECT  L_DATE
                                   , C_TAX_TYPE
                                   , C_PLAN_TYPE
                                   , C_STOCK_TYPE
                                   , EN_INTEREST_TAX
                                   , L_MODIFY_DATE
                                   , C_MARKET_NO
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                FROM ${o32_src_schema}.THISBONDDETAILPROPERTY
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "C_TAX_TYPE", "type": "STRING"}, {"name": "C_PLAN_TYPE", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "EN_INTEREST_TAX", "type": "DOUBLE"}, {"name": "L_MODIFY_DATE", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbonddetailproperty_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbonddetailproperty_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbonddetailproperty_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbonddetailproperty_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBONDDETAILPROPERTY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBONDDETAILPROPERTY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbonddetailproperty_pfd_tmp.json

inceptor_beeline "
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBONDDETAILPROPERTY_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , C_TAX_TYPE
     , C_PLAN_TYPE
     , C_STOCK_TYPE
     , EN_INTEREST_TAX
     , L_MODIFY_DATE
     , C_MARKET_NO
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TBONDDETAILPROPERTY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBONDDETAILPROPERTY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBONDDETAILPROPERTY_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBONDDETAILPROPERTY_PFD成功"
      exit 0
   fi
fi
