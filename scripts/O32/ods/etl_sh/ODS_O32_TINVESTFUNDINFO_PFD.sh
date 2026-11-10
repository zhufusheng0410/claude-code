#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TINVESTFUNDINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TINVESTFUNDINFO_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_FUND_INVEST_TYPE  STRING  COMMENT  '基金投资分类',
  C_ISSUE_TYPE  STRING  COMMENT  '基金发行分类',
  C_FEE_TYPE  STRING  COMMENT  '收费方式',
  L_REDEEM_DAYS  DECIMAL(10,0)  COMMENT  '赎回交收天数',
  VC_MEMO  STRING  COMMENT  '备注',
  C_TA_TYPE  STRING  COMMENT  'ta类型',
  VC_SUSPEND_STATUS  STRING  COMMENT  '申购暂停状态',
  EN_PURCHASE_LIMIT  DECIMAL(16,2)  COMMENT  '申购限额',
  EN_CLASSIFY_MONEY  DECIMAL(16,2)  COMMENT  '分级线金额',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日期',
  L_RATE_DAYS  DECIMAL(10,0)  COMMENT  '计息天数',
  C_CAL_TYPE  STRING  COMMENT  '计息规则',
  C_YIELD_RATIO_TYPE  STRING  COMMENT  '收益率类型',
  EN_YIELD_RATIO_PRE  DECIMAL(9,8)  COMMENT  '预计收益率',
  EN_YIELD_RATIO_BASE  DECIMAL(9,8)  COMMENT  '基准收益率',
  EN_YIELD_RATIO_CHANGE  DECIMAL(9,8)  COMMENT  '浮动收益率',
  EN_YIELD_RATIO_LATER  DECIMAL(9,8)  COMMENT  '延期收益率',
  EN_YIELD_RATIO_BEFORE  DECIMAL(9,8)  COMMENT  '处置收益率',
  C_USE_TYPE  STRING  COMMENT  '运用方向',
  L_DISPOSE_DATE  DECIMAL(8,0)  COMMENT  '处置日期',
  EN_PURCHASE_DOWN_LIMIT  DECIMAL(16,2)  COMMENT  '申购最低限额',
  C_YIELD_TYPE  STRING  COMMENT  '收益类型',
  C_INSIDE_APPRAISE  STRING  COMMENT  '内部评级',
  C_OUTER_APPRAISE  STRING  COMMENT  '外部评级',
  L_OPEN_PERIOD  DECIMAL(16,6)  COMMENT  '开放周期月',
  C_PAYMENT_CYCLE  STRING  COMMENT  '付息周期',
  L_INTEREST_PAY_DATE  DECIMAL(8,0)  COMMENT  '首次付息日期',
  C_SELL_PLATFORM  STRING  COMMENT  '销售平台',
  L_BACK_DAYS  DECIMAL(10,0)  COMMENT  '返款到账天数',
  VC_TA_NO  STRING  COMMENT  'ta账号',
  C_ALLOWED_MOD_AUTO_BUY  STRING  COMMENT  '是否允许修改分红方式',
  C_DEFAULT_AUTO_BUY  STRING  COMMENT  '默认分红方式',
  VC_COMPANY_ID  STRING  COMMENT  '',
  VC_PUB_KEY_CODE  STRING  COMMENT  '公钥',
  VC_PUB_KEY_CONTENT  STRING  COMMENT  '',
  C_HBJJSYJT_TYPE  STRING  COMMENT  '货币基金收益计提方式',
  C_RATE_TIME_TYPE  STRING  COMMENT  '计息时间单位',
  L_INTER_FUND_ID  DECIMAL(8,0)  COMMENT  '',
  L_CREATE_DATE  DECIMAL(8,0)  COMMENT  '创建日期',
  L_RUN_SCALE  DECIMAL(18,2)  COMMENT  '披露规模',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  EN_LAST_ASSET  DECIMAL(16,2)  COMMENT  '最近一次披露净资产',
  VC_CLOSE_RANGE  STRING  COMMENT  '',
  L_NEXT_REDEMPTION_DAY  DECIMAL(8,0)  COMMENT  '',
  C_CARRYOVERENABLE  STRING  COMMENT  '',
  VC_TA_CODE  STRING  COMMENT  'ta编号',
  VC_TA_TYPE  STRING  COMMENT  '',
  C_RAISE_TYPE  STRING  COMMENT  '',
  L_WS_CASH_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '网上现金认购开始日期',
  L_WS_CASH_END_DATE  DECIMAL(8,0)  COMMENT  '网上现金认购结束日期',
  VC_TIMESTAMP3  STRING  COMMENT  '',
  L_FUND_TRANSFORM_DATE  DECIMAL(8,0)  COMMENT  '',
  C_INTERNAL_PRODUCT  STRING  COMMENT  '',
  EN_LAST_FUND_SHARE  DECIMAL(18,2)  COMMENT  ''
)
COMMENT '投资基金信息表'
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
                                   , VC_INTER_CODE
                                   , C_FUND_INVEST_TYPE
                                   , C_ISSUE_TYPE
                                   , C_FEE_TYPE
                                   , L_REDEEM_DAYS
                                   , VC_MEMO
                                   , C_TA_TYPE
                                   , VC_SUSPEND_STATUS
                                   , EN_PURCHASE_LIMIT
                                   , EN_CLASSIFY_MONEY
                                   , L_END_DATE
                                   , L_RATE_DAYS
                                   , C_CAL_TYPE
                                   , C_YIELD_RATIO_TYPE
                                   , EN_YIELD_RATIO_PRE
                                   , EN_YIELD_RATIO_BASE
                                   , EN_YIELD_RATIO_CHANGE
                                   , EN_YIELD_RATIO_LATER
                                   , EN_YIELD_RATIO_BEFORE
                                   , C_USE_TYPE
                                   , L_DISPOSE_DATE
                                   , EN_PURCHASE_DOWN_LIMIT
                                   , C_YIELD_TYPE
                                   , C_INSIDE_APPRAISE
                                   , C_OUTER_APPRAISE
                                   , L_OPEN_PERIOD
                                   , C_PAYMENT_CYCLE
                                   , L_INTEREST_PAY_DATE
                                   , C_SELL_PLATFORM
                                   , L_BACK_DAYS
                                   , VC_TA_NO
                                   , C_ALLOWED_MOD_AUTO_BUY
                                   , C_DEFAULT_AUTO_BUY
                                   , VC_COMPANY_ID
                                   , VC_PUB_KEY_CODE
                                   , VC_PUB_KEY_CONTENT
                                   , C_HBJJSYJT_TYPE
                                   , C_RATE_TIME_TYPE
                                   , L_INTER_FUND_ID
                                   , L_CREATE_DATE
                                   , L_RUN_SCALE
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , EN_LAST_ASSET
                                   , VC_CLOSE_RANGE
                                   , L_NEXT_REDEMPTION_DAY
                                   , C_CARRYOVERENABLE
                                   , VC_TA_CODE
                                   , VC_TA_TYPE
                                   , C_RAISE_TYPE
                                   , L_WS_CASH_BEGIN_DATE
                                   , L_WS_CASH_END_DATE
                                   , VC_TIMESTAMP3
                                   , L_FUND_TRANSFORM_DATE
                                   , C_INTERNAL_PRODUCT
                                   , EN_LAST_FUND_SHARE
                                FROM ${o32_src_schema}.TINVESTFUNDINFO
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_FUND_INVEST_TYPE", "type": "STRING"}, {"name": "C_ISSUE_TYPE", "type": "STRING"}, {"name": "C_FEE_TYPE", "type": "STRING"}, {"name": "L_REDEEM_DAYS", "type": "DOUBLE"}, {"name": "VC_MEMO", "type": "STRING"}, {"name": "C_TA_TYPE", "type": "STRING"}, {"name": "VC_SUSPEND_STATUS", "type": "STRING"}, {"name": "EN_PURCHASE_LIMIT", "type": "DOUBLE"}, {"name": "EN_CLASSIFY_MONEY", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_RATE_DAYS", "type": "DOUBLE"}, {"name": "C_CAL_TYPE", "type": "STRING"}, {"name": "C_YIELD_RATIO_TYPE", "type": "STRING"}, {"name": "EN_YIELD_RATIO_PRE", "type": "DOUBLE"}, {"name": "EN_YIELD_RATIO_BASE", "type": "DOUBLE"}, {"name": "EN_YIELD_RATIO_CHANGE", "type": "DOUBLE"}, {"name": "EN_YIELD_RATIO_LATER", "type": "DOUBLE"}, {"name": "EN_YIELD_RATIO_BEFORE", "type": "DOUBLE"}, {"name": "C_USE_TYPE", "type": "STRING"}, {"name": "L_DISPOSE_DATE", "type": "DOUBLE"}, {"name": "EN_PURCHASE_DOWN_LIMIT", "type": "DOUBLE"}, {"name": "C_YIELD_TYPE", "type": "STRING"}, {"name": "C_INSIDE_APPRAISE", "type": "STRING"}, {"name": "C_OUTER_APPRAISE", "type": "STRING"}, {"name": "L_OPEN_PERIOD", "type": "DOUBLE"}, {"name": "C_PAYMENT_CYCLE", "type": "STRING"}, {"name": "L_INTEREST_PAY_DATE", "type": "DOUBLE"}, {"name": "C_SELL_PLATFORM", "type": "STRING"}, {"name": "L_BACK_DAYS", "type": "DOUBLE"}, {"name": "VC_TA_NO", "type": "STRING"}, {"name": "C_ALLOWED_MOD_AUTO_BUY", "type": "STRING"}, {"name": "C_DEFAULT_AUTO_BUY", "type": "STRING"}, {"name": "VC_COMPANY_ID", "type": "STRING"}, {"name": "VC_PUB_KEY_CODE", "type": "STRING"}, {"name": "VC_PUB_KEY_CONTENT", "type": "STRING"}, {"name": "C_HBJJSYJT_TYPE", "type": "STRING"}, {"name": "C_RATE_TIME_TYPE", "type": "STRING"}, {"name": "L_INTER_FUND_ID", "type": "DOUBLE"}, {"name": "L_CREATE_DATE", "type": "DOUBLE"}, {"name": "L_RUN_SCALE", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "EN_LAST_ASSET", "type": "DOUBLE"}, {"name": "VC_CLOSE_RANGE", "type": "STRING"}, {"name": "L_NEXT_REDEMPTION_DAY", "type": "DOUBLE"}, {"name": "C_CARRYOVERENABLE", "type": "STRING"}, {"name": "VC_TA_CODE", "type": "STRING"}, {"name": "VC_TA_TYPE", "type": "STRING"}, {"name": "C_RAISE_TYPE", "type": "STRING"}, {"name": "L_WS_CASH_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_WS_CASH_END_DATE", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP3", "type": "STRING"}, {"name": "L_FUND_TRANSFORM_DATE", "type": "DOUBLE"}, {"name": "C_INTERNAL_PRODUCT", "type": "STRING"}, {"name": "EN_LAST_FUND_SHARE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tinvestfundinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tinvestfundinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tinvestfundinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tinvestfundinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TINVESTFUNDINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TINVESTFUNDINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tinvestfundinfo_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TINVESTFUNDINFO_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_INTER_CODE
     , C_FUND_INVEST_TYPE
     , C_ISSUE_TYPE
     , C_FEE_TYPE
     , L_REDEEM_DAYS
     , VC_MEMO
     , C_TA_TYPE
     , VC_SUSPEND_STATUS
     , EN_PURCHASE_LIMIT
     , EN_CLASSIFY_MONEY
     , L_END_DATE
     , L_RATE_DAYS
     , C_CAL_TYPE
     , C_YIELD_RATIO_TYPE
     , EN_YIELD_RATIO_PRE
     , EN_YIELD_RATIO_BASE
     , EN_YIELD_RATIO_CHANGE
     , EN_YIELD_RATIO_LATER
     , EN_YIELD_RATIO_BEFORE
     , C_USE_TYPE
     , L_DISPOSE_DATE
     , EN_PURCHASE_DOWN_LIMIT
     , C_YIELD_TYPE
     , C_INSIDE_APPRAISE
     , C_OUTER_APPRAISE
     , L_OPEN_PERIOD
     , C_PAYMENT_CYCLE
     , L_INTEREST_PAY_DATE
     , C_SELL_PLATFORM
     , L_BACK_DAYS
     , VC_TA_NO
     , C_ALLOWED_MOD_AUTO_BUY
     , C_DEFAULT_AUTO_BUY
     , VC_COMPANY_ID
     , VC_PUB_KEY_CODE
     , VC_PUB_KEY_CONTENT
     , C_HBJJSYJT_TYPE
     , C_RATE_TIME_TYPE
     , L_INTER_FUND_ID
     , L_CREATE_DATE
     , L_RUN_SCALE
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , EN_LAST_ASSET
     , VC_CLOSE_RANGE
     , L_NEXT_REDEMPTION_DAY
     , C_CARRYOVERENABLE
     , VC_TA_CODE
     , VC_TA_TYPE
     , C_RAISE_TYPE
     , L_WS_CASH_BEGIN_DATE
     , L_WS_CASH_END_DATE
     , VC_TIMESTAMP3
     , L_FUND_TRANSFORM_DATE
     , C_INTERNAL_PRODUCT
     , EN_LAST_FUND_SHARE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TINVESTFUNDINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TINVESTFUNDINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TINVESTFUNDINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TINVESTFUNDINFO_PFD成功"
      exit 0
   fi
fi
