#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTRUSTCONTRACT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTRUSTCONTRACT_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_CONTRACT_ID  DECIMAL(10,0)  COMMENT  '合同序号',
  VC_FUND_IDS  STRING  COMMENT  '使用的基金',
  C_CONTRACT_TYPE  STRING  COMMENT  '合同类型',
  VC_CONTRACT_NO  STRING  COMMENT  '合同编号',
  VC_CONTRACT_NAME  STRING  COMMENT  '合同名称',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '合同金额',
  C_NOTE_TYPE  STRING  COMMENT  '票据类型',
  L_AFFIX_DATE  DECIMAL(8,0)  COMMENT  '签约日期',
  L_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '开始日期',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日期',
  C_PRE_TERMINATE  STRING  COMMENT  '是否可提前终止',
  C_CANCEL_TYPE  STRING  COMMENT  '是否可解约',
  VC_GRANTER  STRING  COMMENT  '出让方',
  EN_RATE  DECIMAL(9,8)  COMMENT  '利率',
  C_TRANSFER_PATTERN  STRING  COMMENT  '转让方式',
  VC_ACCEPTOR  STRING  COMMENT  '承兑人',
  VC_ACCEPTING_BANK  STRING  COMMENT  '承兑行',
  VC_DRAWER  STRING  COMMENT  '出票人',
  C_PAYMENT_CYCLE  STRING  COMMENT  '付息周期',
  EN_PUNITIVE_RATE  DECIMAL(9,8)  COMMENT  '罚息利率',
  C_CREDIT_RATING  STRING  COMMENT  '信用评级',
  VC_BORROWER  STRING  COMMENT  '借款方',
  VC_ENTRUSTER  STRING  COMMENT  '委托人',
  VC_ENTRUST_BANK  STRING  COMMENT  '委贷行',
  C_REPAYMENT_TYPE  STRING  COMMENT  '还款方式',
  VC_GUARANTEE_SITUATION  STRING  COMMENT  '担保情况',
  C_SHAREHOLDING_TYPE  STRING  COMMENT  '股权分类',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_HOLD_AMOUNT  DECIMAL(20,4)  COMMENT  '持股数量',
  C_EXIT_TYPE  STRING  COMMENT  '退出方式',
  EN_HOLD_RATIO  DECIMAL(9,8)  COMMENT  '持股比例',
  VC_PURPOSE  STRING  COMMENT  '用途',
  VC_REMARK  STRING  COMMENT  '备注',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '操作员',
  C_STATUS  STRING  COMMENT  '合同状态',
  EN_DUE_BALANCE  DECIMAL(16,2)  COMMENT  '到期还款金额',
  C_INVEST_PROPERTY  STRING  COMMENT  '投资性质',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  L_FIRST_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '首次结息日',
  C_OTHER_INCOME_TYPE  STRING  COMMENT  '其它收益权类别',
  C_DAY_TYPE  STRING  COMMENT  '计息方式',
  L_YEAR_DAYS  DECIMAL(10,0)  COMMENT  '计息天数',
  C_INTEREST_TYPE  STRING  COMMENT  '利率类别',
  VC_ASSETPKG_NAME  STRING  COMMENT  '资产包名称',
  C_EXECUTOR_APPRAISE  STRING  COMMENT  '主体信用级别',
  C_RATE_TYPE  STRING  COMMENT  '利率类型',
  C_SETTLE_WAY  STRING  COMMENT  '结算处理方式',
  L_BASE_TYPE  STRING  COMMENT  '基准利率类型',
  VC_CURRENCY_NO  STRING  COMMENT  '货币类别',
  C_FLOAT_DIR  STRING  COMMENT  '浮动方向',
  C_CHANGE_TYPE  STRING  COMMENT  '调整方式',
  C_CHANGE_CYCLE  STRING  COMMENT  '调整周期',
  L_FIRST_CHANGE_DATE  DECIMAL(8,0)  COMMENT  '调整日期',
  C_FLOAT_ALGORITHM  STRING  COMMENT  '浮动算法',
  EN_ARITHMETIC_FLOAT  DECIMAL(9,8)  COMMENT  '等差浮动比例',
  EN_PERCENT_FLOAT  DECIMAL(9,8)  COMMENT  '等比浮动比例',
  EN_MAX_RATE  DECIMAL(9,8)  COMMENT  '利率上限',
  EN_MIN_RATE  DECIMAL(9,8)  COMMENT  '利率下限',
  EN_DISCOUNT_RATE  DECIMAL(9,8)  COMMENT  '贴水利率',
  L_ASSETPKG_ID  STRING  COMMENT  '资产包编号',
  C_DRAW_FLAG  STRING  COMMENT  '是否计提',
  C_CONTRACT_PROPERTY  STRING  COMMENT  '',
  VC_BORROWER_NO  STRING  COMMENT  '',
  VC_BORROWER_REAL_CONTROLLER  STRING  COMMENT  '',
  VC_BORROWER_INDUSTRY_CODE  STRING  COMMENT  '',
  VC_BORROWER_ONE_INDUSTRY  STRING  COMMENT  '',
  VC_BORROWER_TWO_INDUSTRY  STRING  COMMENT  '',
  VC_IOU_NO  STRING  COMMENT  '',
  C_FIVE_LEVEL_LOAN  STRING  COMMENT  '',
  VC_LOAN_ACCOUNT  STRING  COMMENT  '',
  VC_LOAN_CATEGORY  STRING  COMMENT  '',
  VC_CM2002_NO  STRING  COMMENT  '',
  VC_LOAN_TYPE  STRING  COMMENT  '',
  VC_GUARANTEE_CONTRACT_NO  STRING  COMMENT  '',
  VC_GUARANTEE  STRING  COMMENT  '',
  VC_GUARANTEE_REAL_CONTROLLER  STRING  COMMENT  '',
  VC_GUARANTEE_INDUSTRY_CODE  STRING  COMMENT  '',
  VC_GUARANTEE_ONE_INDUSTRY  STRING  COMMENT  '',
  VC_GUARANTEE_TWO_INDUSTRY  STRING  COMMENT  '',
  C_GUARANTEE_CREDIT_RATING  STRING  COMMENT  '',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司号',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '部门号'
)
COMMENT '非标合同表'
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
                                   , L_CONTRACT_ID
                                   , VC_FUND_IDS
                                   , C_CONTRACT_TYPE
                                   , VC_CONTRACT_NO
                                   , VC_CONTRACT_NAME
                                   , EN_BALANCE
                                   , C_NOTE_TYPE
                                   , L_AFFIX_DATE
                                   , L_BEGIN_DATE
                                   , L_END_DATE
                                   , C_PRE_TERMINATE
                                   , C_CANCEL_TYPE
                                   , VC_GRANTER
                                   , EN_RATE
                                   , C_TRANSFER_PATTERN
                                   , VC_ACCEPTOR
                                   , VC_ACCEPTING_BANK
                                   , VC_DRAWER
                                   , C_PAYMENT_CYCLE
                                   , EN_PUNITIVE_RATE
                                   , C_CREDIT_RATING
                                   , VC_BORROWER
                                   , VC_ENTRUSTER
                                   , VC_ENTRUST_BANK
                                   , C_REPAYMENT_TYPE
                                   , VC_GUARANTEE_SITUATION
                                   , C_SHAREHOLDING_TYPE
                                   , VC_INTER_CODE
                                   , L_HOLD_AMOUNT
                                   , C_EXIT_TYPE
                                   , EN_HOLD_RATIO
                                   , VC_PURPOSE
                                   , VC_REMARK
                                   , L_OPERATOR_NO
                                   , C_STATUS
                                   , EN_DUE_BALANCE
                                   , C_INVEST_PROPERTY
                                   , C_INVEST_TYPE
                                   , L_FIRST_SETTLE_DATE
                                   , C_OTHER_INCOME_TYPE
                                   , C_DAY_TYPE
                                   , L_YEAR_DAYS
                                   , C_INTEREST_TYPE
                                   , VC_ASSETPKG_NAME
                                   , C_EXECUTOR_APPRAISE
                                   , C_RATE_TYPE
                                   , C_SETTLE_WAY
                                   , L_BASE_TYPE
                                   , VC_CURRENCY_NO
                                   , C_FLOAT_DIR
                                   , C_CHANGE_TYPE
                                   , C_CHANGE_CYCLE
                                   , L_FIRST_CHANGE_DATE
                                   , C_FLOAT_ALGORITHM
                                   , EN_ARITHMETIC_FLOAT
                                   , EN_PERCENT_FLOAT
                                   , EN_MAX_RATE
                                   , EN_MIN_RATE
                                   , EN_DISCOUNT_RATE
                                   , L_ASSETPKG_ID
                                   , C_DRAW_FLAG
                                   , C_CONTRACT_PROPERTY
                                   , VC_BORROWER_NO
                                   , VC_BORROWER_REAL_CONTROLLER
                                   , VC_BORROWER_INDUSTRY_CODE
                                   , VC_BORROWER_ONE_INDUSTRY
                                   , VC_BORROWER_TWO_INDUSTRY
                                   , VC_IOU_NO
                                   , C_FIVE_LEVEL_LOAN
                                   , VC_LOAN_ACCOUNT
                                   , VC_LOAN_CATEGORY
                                   , VC_CM2002_NO
                                   , VC_LOAN_TYPE
                                   , VC_GUARANTEE_CONTRACT_NO
                                   , VC_GUARANTEE
                                   , VC_GUARANTEE_REAL_CONTROLLER
                                   , VC_GUARANTEE_INDUSTRY_CODE
                                   , VC_GUARANTEE_ONE_INDUSTRY
                                   , VC_GUARANTEE_TWO_INDUSTRY
                                   , C_GUARANTEE_CREDIT_RATING
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                FROM ${o32_src_schema}.THISTRUSTCONTRACT
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_CONTRACT_ID", "type": "DOUBLE"}, {"name": "VC_FUND_IDS", "type": "STRING"}, {"name": "C_CONTRACT_TYPE", "type": "STRING"}, {"name": "VC_CONTRACT_NO", "type": "STRING"}, {"name": "VC_CONTRACT_NAME", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "C_NOTE_TYPE", "type": "STRING"}, {"name": "L_AFFIX_DATE", "type": "DOUBLE"}, {"name": "L_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "C_PRE_TERMINATE", "type": "STRING"}, {"name": "C_CANCEL_TYPE", "type": "STRING"}, {"name": "VC_GRANTER", "type": "STRING"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "C_TRANSFER_PATTERN", "type": "STRING"}, {"name": "VC_ACCEPTOR", "type": "STRING"}, {"name": "VC_ACCEPTING_BANK", "type": "STRING"}, {"name": "VC_DRAWER", "type": "STRING"}, {"name": "C_PAYMENT_CYCLE", "type": "STRING"}, {"name": "EN_PUNITIVE_RATE", "type": "DOUBLE"}, {"name": "C_CREDIT_RATING", "type": "STRING"}, {"name": "VC_BORROWER", "type": "STRING"}, {"name": "VC_ENTRUSTER", "type": "STRING"}, {"name": "VC_ENTRUST_BANK", "type": "STRING"}, {"name": "C_REPAYMENT_TYPE", "type": "STRING"}, {"name": "VC_GUARANTEE_SITUATION", "type": "STRING"}, {"name": "C_SHAREHOLDING_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_HOLD_AMOUNT", "type": "DOUBLE"}, {"name": "C_EXIT_TYPE", "type": "STRING"}, {"name": "EN_HOLD_RATIO", "type": "DOUBLE"}, {"name": "VC_PURPOSE", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "EN_DUE_BALANCE", "type": "DOUBLE"}, {"name": "C_INVEST_PROPERTY", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "L_FIRST_SETTLE_DATE", "type": "DOUBLE"}, {"name": "C_OTHER_INCOME_TYPE", "type": "STRING"}, {"name": "C_DAY_TYPE", "type": "STRING"}, {"name": "L_YEAR_DAYS", "type": "DOUBLE"}, {"name": "C_INTEREST_TYPE", "type": "STRING"}, {"name": "VC_ASSETPKG_NAME", "type": "STRING"}, {"name": "C_EXECUTOR_APPRAISE", "type": "STRING"}, {"name": "C_RATE_TYPE", "type": "STRING"}, {"name": "C_SETTLE_WAY", "type": "STRING"}, {"name": "L_BASE_TYPE", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "C_FLOAT_DIR", "type": "STRING"}, {"name": "C_CHANGE_TYPE", "type": "STRING"}, {"name": "C_CHANGE_CYCLE", "type": "STRING"}, {"name": "L_FIRST_CHANGE_DATE", "type": "DOUBLE"}, {"name": "C_FLOAT_ALGORITHM", "type": "STRING"}, {"name": "EN_ARITHMETIC_FLOAT", "type": "DOUBLE"}, {"name": "EN_PERCENT_FLOAT", "type": "DOUBLE"}, {"name": "EN_MAX_RATE", "type": "DOUBLE"}, {"name": "EN_MIN_RATE", "type": "DOUBLE"}, {"name": "EN_DISCOUNT_RATE", "type": "DOUBLE"}, {"name": "L_ASSETPKG_ID", "type": "DOUBLE"}, {"name": "C_DRAW_FLAG", "type": "STRING"}, {"name": "C_CONTRACT_PROPERTY", "type": "STRING"}, {"name": "VC_BORROWER_NO", "type": "STRING"}, {"name": "VC_BORROWER_REAL_CONTROLLER", "type": "STRING"}, {"name": "VC_BORROWER_INDUSTRY_CODE", "type": "STRING"}, {"name": "VC_BORROWER_ONE_INDUSTRY", "type": "STRING"}, {"name": "VC_BORROWER_TWO_INDUSTRY", "type": "STRING"}, {"name": "VC_IOU_NO", "type": "STRING"}, {"name": "C_FIVE_LEVEL_LOAN", "type": "STRING"}, {"name": "VC_LOAN_ACCOUNT", "type": "STRING"}, {"name": "VC_LOAN_CATEGORY", "type": "STRING"}, {"name": "VC_CM2002_NO", "type": "STRING"}, {"name": "VC_LOAN_TYPE", "type": "STRING"}, {"name": "VC_GUARANTEE_CONTRACT_NO", "type": "STRING"}, {"name": "VC_GUARANTEE", "type": "STRING"}, {"name": "VC_GUARANTEE_REAL_CONTROLLER", "type": "STRING"}, {"name": "VC_GUARANTEE_INDUSTRY_CODE", "type": "STRING"}, {"name": "VC_GUARANTEE_ONE_INDUSTRY", "type": "STRING"}, {"name": "VC_GUARANTEE_TWO_INDUSTRY", "type": "STRING"}, {"name": "C_GUARANTEE_CREDIT_RATING", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_ttrustcontract_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_ttrustcontract_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_ttrustcontract_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_ttrustcontract_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTRUSTCONTRACT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTRUSTCONTRACT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_ttrustcontract_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTRUSTCONTRACT_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , L_CONTRACT_ID
     , VC_FUND_IDS
     , C_CONTRACT_TYPE
     , VC_CONTRACT_NO
     , VC_CONTRACT_NAME
     , EN_BALANCE
     , C_NOTE_TYPE
     , L_AFFIX_DATE
     , L_BEGIN_DATE
     , L_END_DATE
     , C_PRE_TERMINATE
     , C_CANCEL_TYPE
     , VC_GRANTER
     , EN_RATE
     , C_TRANSFER_PATTERN
     , VC_ACCEPTOR
     , VC_ACCEPTING_BANK
     , VC_DRAWER
     , C_PAYMENT_CYCLE
     , EN_PUNITIVE_RATE
     , C_CREDIT_RATING
     , VC_BORROWER
     , VC_ENTRUSTER
     , VC_ENTRUST_BANK
     , C_REPAYMENT_TYPE
     , VC_GUARANTEE_SITUATION
     , C_SHAREHOLDING_TYPE
     , VC_INTER_CODE
     , L_HOLD_AMOUNT
     , C_EXIT_TYPE
     , EN_HOLD_RATIO
     , VC_PURPOSE
     , VC_REMARK
     , L_OPERATOR_NO
     , C_STATUS
     , EN_DUE_BALANCE
     , C_INVEST_PROPERTY
     , C_INVEST_TYPE
     , L_FIRST_SETTLE_DATE
     , C_OTHER_INCOME_TYPE
     , C_DAY_TYPE
     , L_YEAR_DAYS
     , C_INTEREST_TYPE
     , VC_ASSETPKG_NAME
     , C_EXECUTOR_APPRAISE
     , C_RATE_TYPE
     , C_SETTLE_WAY
     , L_BASE_TYPE
     , VC_CURRENCY_NO
     , C_FLOAT_DIR
     , C_CHANGE_TYPE
     , C_CHANGE_CYCLE
     , L_FIRST_CHANGE_DATE
     , C_FLOAT_ALGORITHM
     , EN_ARITHMETIC_FLOAT
     , EN_PERCENT_FLOAT
     , EN_MAX_RATE
     , EN_MIN_RATE
     , EN_DISCOUNT_RATE
     , L_ASSETPKG_ID
     , C_DRAW_FLAG
     , C_CONTRACT_PROPERTY
     , VC_BORROWER_NO
     , VC_BORROWER_REAL_CONTROLLER
     , VC_BORROWER_INDUSTRY_CODE
     , VC_BORROWER_ONE_INDUSTRY
     , VC_BORROWER_TWO_INDUSTRY
     , VC_IOU_NO
     , C_FIVE_LEVEL_LOAN
     , VC_LOAN_ACCOUNT
     , VC_LOAN_CATEGORY
     , VC_CM2002_NO
     , VC_LOAN_TYPE
     , VC_GUARANTEE_CONTRACT_NO
     , VC_GUARANTEE
     , VC_GUARANTEE_REAL_CONTROLLER
     , VC_GUARANTEE_INDUSTRY_CODE
     , VC_GUARANTEE_ONE_INDUSTRY
     , VC_GUARANTEE_TWO_INDUSTRY
     , C_GUARANTEE_CREDIT_RATING
     , L_ORG_ID
     , L_DEPT_ID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TTRUSTCONTRACT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTRUSTCONTRACT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTRUSTCONTRACT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTRUSTCONTRACT_PFD成功"
      exit 0
   fi
fi
