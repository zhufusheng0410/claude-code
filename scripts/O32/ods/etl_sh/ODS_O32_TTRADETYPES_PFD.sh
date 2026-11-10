#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD_TMP(
  L_SERIAL_ID  DECIMAL(8,0)  COMMENT  '维度序号',
  C_TRADE_TYPE  STRING  COMMENT  '维度类别',
  VC_TRADE_LEVEL  STRING  COMMENT  '维度级别',
  L_PARENT_ID  DECIMAL(8,0)  COMMENT  '上级序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  VC_TRADE_NO  STRING  COMMENT  '维度代码2',
  VC_TRADE_NAME  STRING  COMMENT  '维度名称',
  C_CALCULATE_TYPE  STRING  COMMENT  '计算方式＃',
  C_CALCULATE_MODEL  STRING  COMMENT  '计算模型编号＃',
  L_CALCULATE_CIRCLE  DECIMAL(8,0)  COMMENT  '计算周期＃',
  L_LAST_DATE  DECIMAL(8,0)  COMMENT  '最后计算日期＃',
  C_TRADE_STATUS  STRING  COMMENT  '维度状态＃',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '创建人',
  C_SHARE_FLAG  STRING  COMMENT  '共用标志＃',
  VC_REMARKS  STRING  COMMENT  '备注',
  C_STOCKPOOL_TYPE  STRING  COMMENT  '股票池类别',
  EN_TRADE_POWER  DECIMAL(16,8)  COMMENT  '维度权重',
  L_ROOT_ID  DECIMAL(8,0)  COMMENT  '顶级序号',
  L_MAX_AMOUNT  DECIMAL(10,0)  COMMENT  '证券最大数量',
  VC_DYNAMIC_SQL  STRING  COMMENT  '动态维度sql语句',
  L_COMPANY_ID  DECIMAL(10,0)  COMMENT  '公司级的维度序号',
  VC_PARAM1_VALUE  STRING  COMMENT  '参数1',
  VC_PARAM2_VALUE  STRING  COMMENT  '参数2',
  VC_PARAM3_VALUE  STRING  COMMENT  '参数3',
  VC_PARAM1_NAME  STRING  COMMENT  '参数1字段名',
  VC_PARAM2_NAME  STRING  COMMENT  '参数2字段名',
  VC_PARAM3_NAME  STRING  COMMENT  '参数3字段名',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_FILE_PATH  STRING  COMMENT  '导入文件路径',
  C_COMPANY_RALATION  STRING  COMMENT  '与公司同类型股票池关系',
  VC_UNDERLYING_INDEX  STRING  COMMENT  '对应指数代码',
  L_DIMLAYER_ID  DECIMAL(10,0)  COMMENT  '维度层次序号',
  VC_COMPANY_MUTEX_IDS  STRING  COMMENT  '互斥公司级股票池id',
  VC_RELATION_TRADE_IDS  STRING  COMMENT  '#公司同类型股票池序号',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  VC_DYNAMIC_CONDITION  STRING  COMMENT  '动态维度条件'
)
COMMENT '维度定义表'
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
              "querySql": ["SELECT  L_SERIAL_ID
                                   , C_TRADE_TYPE
                                   , VC_TRADE_LEVEL
                                   , L_PARENT_ID
                                   , L_FUND_ID
                                   , VC_TRADE_NO
                                   , VC_TRADE_NAME
                                   , C_CALCULATE_TYPE
                                   , C_CALCULATE_MODEL
                                   , L_CALCULATE_CIRCLE
                                   , L_LAST_DATE
                                   , C_TRADE_STATUS
                                   , L_OPERATOR_NO
                                   , C_SHARE_FLAG
                                   , VC_REMARKS
                                   , C_STOCKPOOL_TYPE
                                   , EN_TRADE_POWER
                                   , L_ROOT_ID
                                   , L_MAX_AMOUNT
                                   , VC_DYNAMIC_SQL
                                   , L_COMPANY_ID
                                   , VC_PARAM1_VALUE
                                   , VC_PARAM2_VALUE
                                   , VC_PARAM3_VALUE
                                   , VC_PARAM1_NAME
                                   , VC_PARAM2_NAME
                                   , VC_PARAM3_NAME
                                   , L_DATE
                                   , VC_FILE_PATH
                                   , C_COMPANY_RALATION
                                   , VC_UNDERLYING_INDEX
                                   , L_DIMLAYER_ID
                                   , VC_COMPANY_MUTEX_IDS
                                   , VC_RELATION_TRADE_IDS
                                   , VC_TIMESTAMP
                                   , VC_DYNAMIC_CONDITION
                                FROM ${o32_src_schema}.THISTRADETYPES
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SERIAL_ID", "type": "DOUBLE"}, {"name": "C_TRADE_TYPE", "type": "STRING"}, {"name": "VC_TRADE_LEVEL", "type": "STRING"}, {"name": "L_PARENT_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_TRADE_NO", "type": "STRING"}, {"name": "VC_TRADE_NAME", "type": "STRING"}, {"name": "C_CALCULATE_TYPE", "type": "STRING"}, {"name": "C_CALCULATE_MODEL", "type": "STRING"}, {"name": "L_CALCULATE_CIRCLE", "type": "DOUBLE"}, {"name": "L_LAST_DATE", "type": "DOUBLE"}, {"name": "C_TRADE_STATUS", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "C_SHARE_FLAG", "type": "STRING"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "C_STOCKPOOL_TYPE", "type": "STRING"}, {"name": "EN_TRADE_POWER", "type": "DOUBLE"}, {"name": "L_ROOT_ID", "type": "DOUBLE"}, {"name": "L_MAX_AMOUNT", "type": "DOUBLE"}, {"name": "VC_DYNAMIC_SQL", "type": "STRING"}, {"name": "L_COMPANY_ID", "type": "DOUBLE"}, {"name": "VC_PARAM1_VALUE", "type": "STRING"}, {"name": "VC_PARAM2_VALUE", "type": "STRING"}, {"name": "VC_PARAM3_VALUE", "type": "STRING"}, {"name": "VC_PARAM1_NAME", "type": "STRING"}, {"name": "VC_PARAM2_NAME", "type": "STRING"}, {"name": "VC_PARAM3_NAME", "type": "STRING"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_FILE_PATH", "type": "STRING"}, {"name": "C_COMPANY_RALATION", "type": "STRING"}, {"name": "VC_UNDERLYING_INDEX", "type": "STRING"}, {"name": "L_DIMLAYER_ID", "type": "DOUBLE"}, {"name": "VC_COMPANY_MUTEX_IDS", "type": "STRING"}, {"name": "VC_RELATION_TRADE_IDS", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "VC_DYNAMIC_CONDITION", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_ttradetypes_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_ttradetypes_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_ttradetypes_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_ttradetypes_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTRADETYPES_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTRADETYPES_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_ttradetypes_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD PARTITION(P_DT)
SELECT
       L_SERIAL_ID
     , C_TRADE_TYPE
     , VC_TRADE_LEVEL
     , L_PARENT_ID
     , L_FUND_ID
     , VC_TRADE_NO
     , VC_TRADE_NAME
     , C_CALCULATE_TYPE
     , C_CALCULATE_MODEL
     , L_CALCULATE_CIRCLE
     , L_LAST_DATE
     , C_TRADE_STATUS
     , L_OPERATOR_NO
     , C_SHARE_FLAG
     , VC_REMARKS
     , C_STOCKPOOL_TYPE
     , EN_TRADE_POWER
     , L_ROOT_ID
     , L_MAX_AMOUNT
     , VC_DYNAMIC_SQL
     , L_COMPANY_ID
     , VC_PARAM1_VALUE
     , VC_PARAM2_VALUE
     , VC_PARAM3_VALUE
     , VC_PARAM1_NAME
     , VC_PARAM2_NAME
     , VC_PARAM3_NAME
     , L_DATE
     , VC_FILE_PATH
     , C_COMPANY_RALATION
     , VC_UNDERLYING_INDEX
     , L_DIMLAYER_ID
     , VC_COMPANY_MUTEX_IDS
     , VC_RELATION_TRADE_IDS
     , VC_TIMESTAMP
     , VC_DYNAMIC_CONDITION
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTRADETYPES_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTRADETYPES_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTRADETYPES_PFD成功"
      exit 0
   fi
fi
