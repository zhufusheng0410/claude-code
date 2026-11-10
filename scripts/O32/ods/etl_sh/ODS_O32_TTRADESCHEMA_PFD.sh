#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTRADESCHEMA_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTRADESCHEMA_PFD_TMP(
  VC_SCHEMA_NAME  STRING  COMMENT  '方案名称',
  L_CREATE_OPERATOR  DECIMAL(10,0)  COMMENT  '创建人',
  D_CREATE_TIME  STRING  COMMENT  '创建时间',
  VC_TRADERS  STRING  COMMENT  '参与人',
  VC_REMARKS  STRING  COMMENT  '备注',
  C_STATUS  STRING  COMMENT  '状态',
  C_TRADE_PURPOSE  STRING  COMMENT  '交易目的',
  C_TYPE  STRING  COMMENT  '方案类型',
  C_MATCH_CLASS  STRING  COMMENT  '撮合业务类型',
  VC_SCHEMA_NO  STRING  COMMENT  '方案编号',
  C_COMMIT_STATUS  STRING  COMMENT  '提交状态',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '开始日期',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '结束日期',
  C_MSG_SEND  STRING  COMMENT  '消息通知',
  C_DATE_MODE  STRING  COMMENT  '多日模式',
  D_COMMIT_TIME  STRING  COMMENT  '提交时间',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司号',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '部门号',
  L_NETTING_BALANCE  DECIMAL(16,2)  COMMENT  '',
  L_TRADE_RIVAL  DECIMAL(10,0)  COMMENT  '',
  VC_LIMIT_OPERATORS  STRING  COMMENT  '',
  VC_OPERLOG  STRING  COMMENT  '',
  C_ARCHIVE_STATUS  STRING  COMMENT  '',
  VC_APPROVE_INDEX  STRING  COMMENT  '',
  VC_APPROVE_OVERVIEW  STRING  COMMENT  '',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '组合序号',
  L_NETTING_AMOUNT  DECIMAL(18,4)  COMMENT  ''
)
COMMENT '交易方案表'
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
              "querySql": ["SELECT  VC_SCHEMA_NAME
                                   , L_CREATE_OPERATOR
                                   , D_CREATE_TIME
                                   , VC_TRADERS
                                   , VC_REMARKS
                                   , C_STATUS
                                   , C_TRADE_PURPOSE
                                   , C_TYPE
                                   , C_MATCH_CLASS
                                   , VC_SCHEMA_NO
                                   , C_COMMIT_STATUS
                                   , L_BEGIN_DATE
                                   , L_END_DATE
                                   , C_MSG_SEND
                                   , C_DATE_MODE
                                   , D_COMMIT_TIME
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , L_NETTING_BALANCE
                                   , L_TRADE_RIVAL
                                   , VC_LIMIT_OPERATORS
                                   , VC_OPERLOG
                                   , C_ARCHIVE_STATUS
                                   , VC_APPROVE_INDEX
                                   , VC_APPROVE_OVERVIEW
                                   , L_BASECOMBI_ID
                                   , L_NETTING_AMOUNT
                                FROM ${o32_src_schema}.TTRADESCHEMA"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_SCHEMA_NAME", "type": "STRING"}, {"name": "L_CREATE_OPERATOR", "type": "DOUBLE"}, {"name": "D_CREATE_TIME", "type": "STRING"}, {"name": "VC_TRADERS", "type": "STRING"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_TRADE_PURPOSE", "type": "STRING"}, {"name": "C_TYPE", "type": "STRING"}, {"name": "C_MATCH_CLASS", "type": "STRING"}, {"name": "VC_SCHEMA_NO", "type": "STRING"}, {"name": "C_COMMIT_STATUS", "type": "STRING"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "C_MSG_SEND", "type": "STRING"}, {"name": "C_DATE_MODE", "type": "STRING"}, {"name": "D_COMMIT_TIME", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "L_NETTING_BALANCE", "type": "DOUBLE"}, {"name": "L_TRADE_RIVAL", "type": "DOUBLE"}, {"name": "VC_LIMIT_OPERATORS", "type": "STRING"}, {"name": "VC_OPERLOG", "type": "STRING"}, {"name": "C_ARCHIVE_STATUS", "type": "STRING"}, {"name": "VC_APPROVE_INDEX", "type": "STRING"}, {"name": "VC_APPROVE_OVERVIEW", "type": "STRING"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "L_NETTING_AMOUNT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_ttradeschema_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_ttradeschema_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_ttradeschema_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_ttradeschema_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTRADESCHEMA_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTRADESCHEMA_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_ttradeschema_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTRADESCHEMA_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_SCHEMA_NAME
     , L_CREATE_OPERATOR
     , D_CREATE_TIME
     , VC_TRADERS
     , VC_REMARKS
     , C_STATUS
     , C_TRADE_PURPOSE
     , C_TYPE
     , C_MATCH_CLASS
     , VC_SCHEMA_NO
     , C_COMMIT_STATUS
     , L_BEGIN_DATE
     , L_END_DATE
     , C_MSG_SEND
     , C_DATE_MODE
     , D_COMMIT_TIME
     , L_ORG_ID
     , L_DEPT_ID
     , L_NETTING_BALANCE
     , L_TRADE_RIVAL
     , VC_LIMIT_OPERATORS
     , VC_OPERLOG
     , C_ARCHIVE_STATUS
     , VC_APPROVE_INDEX
     , VC_APPROVE_OVERVIEW
     , L_BASECOMBI_ID
     , L_NETTING_AMOUNT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TTRADESCHEMA_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTRADESCHEMA_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTRADESCHEMA_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTRADESCHEMA_PFD成功"
      exit 0
   fi
fi
