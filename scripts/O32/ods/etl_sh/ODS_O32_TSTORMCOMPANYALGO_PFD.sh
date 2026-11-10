#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTORMCOMPANYALGO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTORMCOMPANYALGO_PFD_TMP(
  L_COMP_ID  DECIMAL(10,0)  COMMENT  '提供商序号',
  VC_STRATEGY_NAME  STRING  COMMENT  '算法名称',
  L_ORDER  DECIMAL(10,0)  COMMENT  '算法次序',
  C_ENABLE_FLAG  STRING  COMMENT  '启用标志',
  VC_DESCRIPTION  STRING  COMMENT  '算法描述',
  VC_DESCRIPTION_DETAIL  STRING  COMMENT  '算法详细描述',
  C_ENABLE_FAIR  STRING  COMMENT  '支持公平交易',
  VC_STOCK_TARGET_TYPES  STRING  COMMENT  '支持的控制方式',
  VC_STOCK_TYPES  STRING  COMMENT  '支持的证券类别',
  VC_ENTRUST_DIRECTIONS  STRING  COMMENT  '支持的委托方向',
  VC_ORDER_TYPES  STRING  COMMENT  '订单类型',
  VC_MI_TARGET_TYPES  STRING  COMMENT  '人工干预控制方式',
  L_SCHEMA_COUNT  DECIMAL(10,0)  COMMENT  '母单数量',
  C_BUSIN_CLASS  STRING  COMMENT  '业务类别',
  C_CUSTOM_TYPE  STRING  COMMENT  '用户自定义',
  C_ALGO_BUSIN_CLASS  STRING  COMMENT  '业务类别新',
  L_FUNCTION_NUMBER  DECIMAL(10,0)  COMMENT  '',
  C_STRATE_TYPE  STRING  COMMENT  '',
  VC_SPECIAL  STRING  COMMENT  '',
  STRATEGY_CONFIG_PROPERTY  STRING  COMMENT  '',
  VC_STRATEGY_TYPE  STRING  COMMENT  '',
  VC_ALLOW_OPERATORS  STRING  COMMENT  ''
)
COMMENT '算法定义表'
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
              "querySql": ["SELECT  L_COMP_ID
                                   , VC_STRATEGY_NAME
                                   , L_ORDER
                                   , C_ENABLE_FLAG
                                   , VC_DESCRIPTION
                                   , VC_DESCRIPTION_DETAIL
                                   , C_ENABLE_FAIR
                                   , VC_STOCK_TARGET_TYPES
                                   , VC_STOCK_TYPES
                                   , VC_ENTRUST_DIRECTIONS
                                   , VC_ORDER_TYPES
                                   , VC_MI_TARGET_TYPES
                                   , L_SCHEMA_COUNT
                                   , C_BUSIN_CLASS
                                   , C_CUSTOM_TYPE
                                   , C_ALGO_BUSIN_CLASS
                                   , L_FUNCTION_NUMBER
                                   , C_STRATE_TYPE
                                   , VC_SPECIAL
                                   , STRATEGY_CONFIG_PROPERTY
                                   , VC_STRATEGY_TYPE
                                   , VC_ALLOW_OPERATORS
                                FROM ${o32_src_schema}.TSTORMCOMPANYALGO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_COMP_ID", "type": "DOUBLE"}, {"name": "VC_STRATEGY_NAME", "type": "STRING"}, {"name": "L_ORDER", "type": "DOUBLE"}, {"name": "C_ENABLE_FLAG", "type": "STRING"}, {"name": "VC_DESCRIPTION", "type": "STRING"}, {"name": "VC_DESCRIPTION_DETAIL", "type": "STRING"}, {"name": "C_ENABLE_FAIR", "type": "STRING"}, {"name": "VC_STOCK_TARGET_TYPES", "type": "STRING"}, {"name": "VC_STOCK_TYPES", "type": "STRING"}, {"name": "VC_ENTRUST_DIRECTIONS", "type": "STRING"}, {"name": "VC_ORDER_TYPES", "type": "STRING"}, {"name": "VC_MI_TARGET_TYPES", "type": "STRING"}, {"name": "L_SCHEMA_COUNT", "type": "DOUBLE"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "C_CUSTOM_TYPE", "type": "STRING"}, {"name": "C_ALGO_BUSIN_CLASS", "type": "STRING"}, {"name": "L_FUNCTION_NUMBER", "type": "DOUBLE"}, {"name": "C_STRATE_TYPE", "type": "STRING"}, {"name": "VC_SPECIAL", "type": "STRING"}, {"name": "STRATEGY_CONFIG_PROPERTY", "type": "STRING"}, {"name": "VC_STRATEGY_TYPE", "type": "STRING"}, {"name": "VC_ALLOW_OPERATORS", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstormcompanyalgo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstormcompanyalgo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstormcompanyalgo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstormcompanyalgo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTORMCOMPANYALGO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTORMCOMPANYALGO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstormcompanyalgo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTORMCOMPANYALGO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_COMP_ID
     , VC_STRATEGY_NAME
     , L_ORDER
     , C_ENABLE_FLAG
     , VC_DESCRIPTION
     , VC_DESCRIPTION_DETAIL
     , C_ENABLE_FAIR
     , VC_STOCK_TARGET_TYPES
     , VC_STOCK_TYPES
     , VC_ENTRUST_DIRECTIONS
     , VC_ORDER_TYPES
     , VC_MI_TARGET_TYPES
     , L_SCHEMA_COUNT
     , C_BUSIN_CLASS
     , C_CUSTOM_TYPE
     , C_ALGO_BUSIN_CLASS
     , L_FUNCTION_NUMBER
     , C_STRATE_TYPE
     , VC_SPECIAL
     , STRATEGY_CONFIG_PROPERTY
     , VC_STRATEGY_TYPE
     , VC_ALLOW_OPERATORS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSTORMCOMPANYALGO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTORMCOMPANYALGO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTORMCOMPANYALGO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTORMCOMPANYALGO_PFD成功"
      exit 0
   fi
fi
