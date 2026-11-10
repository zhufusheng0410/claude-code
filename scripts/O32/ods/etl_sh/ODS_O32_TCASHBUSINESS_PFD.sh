#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TCASHBUSINESS_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TCASHBUSINESS_PFD_TMP(
  L_BUSIN_NO  DECIMAL(10,0)  COMMENT  '业务序号',
  L_BATCH_NO  DECIMAL(10,0)  COMMENT  '批号',
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_TIME  DECIMAL(6,0)  COMMENT  '发生时间',
  VC_BUSIN_OPFLAG  STRING  COMMENT  '业务操作类型',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  L_TARGET_FUND  DECIMAL(8,0)  COMMENT  '目标基金',
  L_TARGET_ASSET  DECIMAL(8,0)  COMMENT  '目标资产单元',
  EN_OCCUR_BALANCE  DECIMAL(18,2)  COMMENT  '发生金额',
  L_OPERATE_ENABLE_DATE  DECIMAL(8,0)  COMMENT  '冻结解冻起始日期',
  L_OPERATE_DISABLE_DATE  DECIMAL(8,0)  COMMENT  '冻结解冻终止日期',
  L_OPERATOR_NO  STRING  COMMENT  '操作员代码',
  L_CHECK_DATE  DECIMAL(8,0)  COMMENT  '复核日期',
  L_CHECK_TIME  DECIMAL(6,0)  COMMENT  '复核时间',
  L_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  '复核人员',
  C_CHECK_FLAG  STRING  COMMENT  '复核标志',
  VC_CHECK_MEMO  STRING  COMMENT  '复核备注',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  L_FROZEN_NO  DECIMAL(10,0)  COMMENT  '冻结流水序号',
  C_ENABLE_FLAG  STRING  COMMENT  '可用标志',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  D_DATETIME  STRING  COMMENT  '时间戳',
  VC_RELATE_NO  STRING  COMMENT  '关联编号',
  EN_OCCUR_SHARE  DECIMAL(16,2)  COMMENT  '发生份额',
  C_DEL_STATUS  STRING  COMMENT  '删除状态',
  L_DEL_OPERATOR  DECIMAL(8,0)  COMMENT  '删除操作员',
  L_DEL_DATE  DECIMAL(8,0)  COMMENT  '删除日期',
  L_DEL_TIME  DECIMAL(6,0)  COMMENT  '删除时间',
  C_ENABLE_POINT  STRING  COMMENT  '生效时点',
  L_RETURN_DATE  DECIMAL(8,0)  COMMENT  '返还日期',
  C_RETURN_POINT  STRING  COMMENT  '返还时点',
  C_RETURN_DEAL_FLAG  STRING  COMMENT  '返还处理标志',
  C_PRINT_PAYMENT_PAPER  STRING  COMMENT  '是否打印划款单',
  L_PAPER_NO  STRING  COMMENT  '划款指令单编号',
  C_GX_CASH_LINKED_STATUS  STRING  COMMENT  '资金联动状态',
  C_FUTURE_ENABLE_FLAG  STRING  COMMENT  '远期业务影响可用标志',
  C_INFLUENCE_T0  STRING  COMMENT  '是否影响t+',
  C_OUTINCASH_FLAG  STRING  COMMENT  '出入金标志',
  VC_MEMO  STRING  COMMENT  '备注',
  C_EXPIRE_POINT  STRING  COMMENT  '',
  C_SOURCE_NO  STRING  COMMENT  '',
  C_DEL_CHECK_STATUS  STRING  COMMENT  '',
  L_DEL_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  ''
)
COMMENT '资金类业务表'
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
                                   , L_TARGET_FUND
                                   , L_TARGET_ASSET
                                   , EN_OCCUR_BALANCE
                                   , L_OPERATE_ENABLE_DATE
                                   , L_OPERATE_DISABLE_DATE
                                   , L_OPERATOR_NO
                                   , L_CHECK_DATE
                                   , L_CHECK_TIME
                                   , L_CHECK_OPERATOR
                                   , C_CHECK_FLAG
                                   , VC_CHECK_MEMO
                                   , C_DEAL_FLAG
                                   , L_FROZEN_NO
                                   , C_ENABLE_FLAG
                                   , VC_CURRENCY_NO
                                   , D_DATETIME
                                   , VC_RELATE_NO
                                   , EN_OCCUR_SHARE
                                   , C_DEL_STATUS
                                   , L_DEL_OPERATOR
                                   , L_DEL_DATE
                                   , L_DEL_TIME
                                   , C_ENABLE_POINT
                                   , L_RETURN_DATE
                                   , C_RETURN_POINT
                                   , C_RETURN_DEAL_FLAG
                                   , C_PRINT_PAYMENT_PAPER
                                   , L_PAPER_NO
                                   , C_GX_CASH_LINKED_STATUS
                                   , C_FUTURE_ENABLE_FLAG
                                   , C_INFLUENCE_T0
                                   , C_OUTINCASH_FLAG
                                   , VC_MEMO
                                   , C_EXPIRE_POINT
                                   , C_SOURCE_NO
                                   , C_DEL_CHECK_STATUS
                                   , L_DEL_CHECK_OPERATOR
                                FROM ${o32_src_schema}.THISCASHBUSINESS"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BUSIN_NO", "type": "DOUBLE"}, {"name": "L_BATCH_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "VC_BUSIN_OPFLAG", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_TARGET_FUND", "type": "DOUBLE"}, {"name": "L_TARGET_ASSET", "type": "DOUBLE"}, {"name": "EN_OCCUR_BALANCE", "type": "DOUBLE"}, {"name": "L_OPERATE_ENABLE_DATE", "type": "DOUBLE"}, {"name": "L_OPERATE_DISABLE_DATE", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_CHECK_DATE", "type": "DOUBLE"}, {"name": "L_CHECK_TIME", "type": "DOUBLE"}, {"name": "L_CHECK_OPERATOR", "type": "DOUBLE"}, {"name": "C_CHECK_FLAG", "type": "STRING"}, {"name": "VC_CHECK_MEMO", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "L_FROZEN_NO", "type": "DOUBLE"}, {"name": "C_ENABLE_FLAG", "type": "STRING"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "VC_RELATE_NO", "type": "STRING"}, {"name": "EN_OCCUR_SHARE", "type": "DOUBLE"}, {"name": "C_DEL_STATUS", "type": "STRING"}, {"name": "L_DEL_OPERATOR", "type": "DOUBLE"}, {"name": "L_DEL_DATE", "type": "DOUBLE"}, {"name": "L_DEL_TIME", "type": "DOUBLE"}, {"name": "C_ENABLE_POINT", "type": "STRING"}, {"name": "L_RETURN_DATE", "type": "DOUBLE"}, {"name": "C_RETURN_POINT", "type": "STRING"}, {"name": "C_RETURN_DEAL_FLAG", "type": "STRING"}, {"name": "C_PRINT_PAYMENT_PAPER", "type": "STRING"}, {"name": "L_PAPER_NO", "type": "DOUBLE"}, {"name": "C_GX_CASH_LINKED_STATUS", "type": "STRING"}, {"name": "C_FUTURE_ENABLE_FLAG", "type": "STRING"}, {"name": "C_INFLUENCE_T0", "type": "STRING"}, {"name": "C_OUTINCASH_FLAG", "type": "STRING"}, {"name": "VC_MEMO", "type": "STRING"}, {"name": "C_EXPIRE_POINT", "type": "STRING"}, {"name": "C_SOURCE_NO", "type": "STRING"}, {"name": "C_DEL_CHECK_STATUS", "type": "STRING"}, {"name": "L_DEL_CHECK_OPERATOR", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tcashbusiness_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tcashbusiness_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tcashbusiness_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tcashbusiness_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TCASHBUSINESS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TCASHBUSINESS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tcashbusiness_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TCASHBUSINESS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BUSIN_NO
     , L_BATCH_NO
     , L_DATE
     , L_TIME
     , VC_BUSIN_OPFLAG
     , L_FUND_ID
     , L_ASSET_ID
     , L_TARGET_FUND
     , L_TARGET_ASSET
     , EN_OCCUR_BALANCE
     , L_OPERATE_ENABLE_DATE
     , L_OPERATE_DISABLE_DATE
     , L_OPERATOR_NO
     , L_CHECK_DATE
     , L_CHECK_TIME
     , L_CHECK_OPERATOR
     , C_CHECK_FLAG
     , VC_CHECK_MEMO
     , C_DEAL_FLAG
     , L_FROZEN_NO
     , C_ENABLE_FLAG
     , VC_CURRENCY_NO
     , D_DATETIME
     , VC_RELATE_NO
     , EN_OCCUR_SHARE
     , C_DEL_STATUS
     , L_DEL_OPERATOR
     , L_DEL_DATE
     , L_DEL_TIME
     , C_ENABLE_POINT
     , L_RETURN_DATE
     , C_RETURN_POINT
     , C_RETURN_DEAL_FLAG
     , C_PRINT_PAYMENT_PAPER
     , L_PAPER_NO
     , C_GX_CASH_LINKED_STATUS
     , C_FUTURE_ENABLE_FLAG
     , C_INFLUENCE_T0
     , C_OUTINCASH_FLAG
     , VC_MEMO
     , C_EXPIRE_POINT
     , C_SOURCE_NO
     , C_DEL_CHECK_STATUS
     , L_DEL_CHECK_OPERATOR
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TCASHBUSINESS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TCASHBUSINESS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TCASHBUSINESS_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TCASHBUSINESS_PFD成功"
      exit 0
   fi
fi
