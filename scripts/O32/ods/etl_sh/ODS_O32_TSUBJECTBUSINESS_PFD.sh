#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSUBJECTBUSINESS_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTBUSINESS_PFD_TMP(
  L_BUSIN_NO  DECIMAL(10,0)  COMMENT  '业务序号',
  L_BATCH_NO  DECIMAL(10,0)  COMMENT  '批号',
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_TIME  DECIMAL(6,0)  COMMENT  '发生时间',
  VC_BUSIN_OPFLAG  STRING  COMMENT  '业务操作类型',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  L_SUBJECT_NO  STRING  COMMENT  'o3科目编号',
  EN_OCCUR_BALANCE  DECIMAL(16,2)  COMMENT  '发生金额',
  C_ADJUST_ASSET  STRING  COMMENT  '同步调整资金',
  L_OPERATOR_NO  STRING  COMMENT  '操作员代码',
  VC_MEMO  STRING  COMMENT  '备注',
  L_CHECK_DATE  DECIMAL(8,0)  COMMENT  '复核日期',
  L_CHECK_TIME  DECIMAL(6,0)  COMMENT  '复核时间',
  L_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  '复核人员',
  C_CHECK_FLAG  STRING  COMMENT  '复核标志',
  VC_CHECK_MEMO  STRING  COMMENT  '复核备注',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  D_DATETIME  STRING  COMMENT  '时间戳',
  L_OPERATE_ENABLE_DATE  DECIMAL(8,0)  COMMENT  '操作生效日期',
  C_DEL_STATUS  STRING  COMMENT  '删除状态',
  L_DEL_OPERATOR  DECIMAL(8,0)  COMMENT  '删除操作员',
  L_DEL_DATE  DECIMAL(8,0)  COMMENT  '删除日期',
  L_DEL_TIME  DECIMAL(6,0)  COMMENT  '删除时间',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  L_BUSINESS_DATE  DECIMAL(8,0)  COMMENT  '业务日期',
  C_ADJUST_TYPE  STRING  COMMENT  '科目调整类型'
)
COMMENT '科目类业务表'
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
              "querySql": ["SELECT  L_BUSIN_NO
                                   , L_BATCH_NO
                                   , L_DATE
                                   , L_TIME
                                   , VC_BUSIN_OPFLAG
                                   , L_FUND_ID
                                   , L_ASSET_ID
                                   , L_SUBJECT_NO
                                   , EN_OCCUR_BALANCE
                                   , C_ADJUST_ASSET
                                   , L_OPERATOR_NO
                                   , VC_MEMO
                                   , L_CHECK_DATE
                                   , L_CHECK_TIME
                                   , L_CHECK_OPERATOR
                                   , C_CHECK_FLAG
                                   , VC_CHECK_MEMO
                                   , C_DEAL_FLAG
                                   , D_DATETIME
                                   , L_OPERATE_ENABLE_DATE
                                   , C_DEL_STATUS
                                   , L_DEL_OPERATOR
                                   , L_DEL_DATE
                                   , L_DEL_TIME
                                   , VC_CURRENCY_NO
                                   , L_BUSINESS_DATE
                                   , C_ADJUST_TYPE
                                FROM ${o32_src_schema}.TSUBJECTBUSINESS"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BUSIN_NO", "type": "DOUBLE"}, {"name": "L_BATCH_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "VC_BUSIN_OPFLAG", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_SUBJECT_NO", "type": "DOUBLE"}, {"name": "EN_OCCUR_BALANCE", "type": "DOUBLE"}, {"name": "C_ADJUST_ASSET", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "VC_MEMO", "type": "STRING"}, {"name": "L_CHECK_DATE", "type": "DOUBLE"}, {"name": "L_CHECK_TIME", "type": "DOUBLE"}, {"name": "L_CHECK_OPERATOR", "type": "DOUBLE"}, {"name": "C_CHECK_FLAG", "type": "STRING"}, {"name": "VC_CHECK_MEMO", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "L_OPERATE_ENABLE_DATE", "type": "DOUBLE"}, {"name": "C_DEL_STATUS", "type": "STRING"}, {"name": "L_DEL_OPERATOR", "type": "DOUBLE"}, {"name": "L_DEL_DATE", "type": "DOUBLE"}, {"name": "L_DEL_TIME", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "L_BUSINESS_DATE", "type": "DOUBLE"}, {"name": "C_ADJUST_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tsubjectbusiness_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tsubjectbusiness_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tsubjectbusiness_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tsubjectbusiness_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSUBJECTBUSINESS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSUBJECTBUSINESS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tsubjectbusiness_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTBUSINESS_PFD PARTITION(P_DT)
SELECT
       L_BUSIN_NO
     , L_BATCH_NO
     , L_DATE
     , L_TIME
     , VC_BUSIN_OPFLAG
     , L_FUND_ID
     , L_ASSET_ID
     , L_SUBJECT_NO
     , EN_OCCUR_BALANCE
     , C_ADJUST_ASSET
     , L_OPERATOR_NO
     , VC_MEMO
     , L_CHECK_DATE
     , L_CHECK_TIME
     , L_CHECK_OPERATOR
     , C_CHECK_FLAG
     , VC_CHECK_MEMO
     , C_DEAL_FLAG
     , D_DATETIME
     , L_OPERATE_ENABLE_DATE
     , C_DEL_STATUS
     , L_DEL_OPERATOR
     , L_DEL_DATE
     , L_DEL_TIME
     , VC_CURRENCY_NO
     , L_BUSINESS_DATE
     , C_ADJUST_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , '${p_end_dt}' P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSUBJECTBUSINESS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSUBJECTBUSINESS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSUBJECTBUSINESS_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSUBJECTBUSINESS_PFD成功"
      exit 0
   fi
fi
