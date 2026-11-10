#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TDEPOSITCONTRACT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TDEPOSITCONTRACT_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '*合同日期',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  VC_INTER_NO  STRING  COMMENT  '内部合同号',
  VC_CONTRACT_NO  STRING  COMMENT  '合同号',
  VC_CONTRACT_NAME  STRING  COMMENT  '合同名称',
  VC_CONTRACT_OWNER  STRING  COMMENT  '合同所有人',
  VC_ACCOUNT_NAME  STRING  COMMENT  '开户名称',
  L_BANK  DECIMAL(10,0)  COMMENT  '银行总行',
  VC_AFFIX_OPERATOR  STRING  COMMENT  '我方签署人',
  VC_ADVERSARY_OPERATOR  STRING  COMMENT  '对方签署人',
  L_AFFIX_DATE  DECIMAL(8,0)  COMMENT  '签署日期',
  L_LIMIT_TIME  DECIMAL(4,0)  COMMENT  '合同期限',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '合同金额',
  EN_INTEREST_RATE  DECIMAL(16,12)  COMMENT  '合同利率',
  C_RATE_TYPE  STRING  COMMENT  '利率类型',
  EN_FLOAT_RATE  DECIMAL(16,12)  COMMENT  '浮动比例',
  C_FLOAT_TYPE  STRING  COMMENT  '基准利率类型',
  EN_BASIC_RATE  DECIMAL(16,12)  COMMENT  '基本利差',
  EN_LEAST_RATE  DECIMAL(16,12)  COMMENT  '保底利率',
  L_PAY_INTEVAL  DECIMAL(10,0)  COMMENT  '付息间隔',
  C_DAY_TYPE  STRING  COMMENT  '计息天数',
  C_CAL_TYPE  STRING  COMMENT  '计息规则',
  C_INTEREST_CAL_TYPE  STRING  COMMENT  '＃利息计算方式',
  C_DATE_TYPE  STRING  COMMENT  '＃付息日计算模式',
  L_BASE_DATE  DECIMAL(8,0)  COMMENT  '调息基准日期',
  L_BASE_DAYS  DECIMAL(8,0)  COMMENT  '调息基准工作日',
  C_BEGIN_PAY_TYPE  STRING  COMMENT  '＃开始的付息模式',
  C_END_PAY_TYPE  STRING  COMMENT  '＃最后的付息模式',
  C_CANCEL_TYPE  STRING  COMMENT  '是否可解约',
  VC_REMARK  STRING  COMMENT  '备注',
  L_OPERATOR_NO  DECIMAL(8,0)  COMMENT  '＃操作员',
  L_ADD_DATE  DECIMAL(8,0)  COMMENT  '＃输入日期',
  C_STATUS  STRING  COMMENT  '＃合同状态',
  VC_FUND_IDS  STRING  COMMENT  '基金序号',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '到期日期',
  EN_HIGHEST_RATE  DECIMAL(16,12)  COMMENT  '封顶利率',
  EN_ADVANCE_RATE  DECIMAL(16,12)  COMMENT  '提前支取利率',
  C_LIMIT_UNIT  STRING  COMMENT  '合同期限单位',
  L_ADVANCE_COUNT  DECIMAL(10,0)  COMMENT  '提前支取次数',
  L_ADVANCE_DEAL_COUNT  DECIMAL(10,0)  COMMENT  '已取次数',
  L_ADVANCE_DATE  DECIMAL(8,0)  COMMENT  '可提前支取日期',
  C_DEPOSIT_TYPE  STRING  COMMENT  '存款类型',
  C_PAY_INTEVAL_UNIT  STRING  COMMENT  '付息间隔单位',
  L_ADVANCE_DAYS  DECIMAL(3,0)  COMMENT  '#提前支取通知天数',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司号',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '部门号',
  C_INTEREST_PAY_TYPE  STRING  COMMENT  '付息方式',
  C_INTEREST_DEPOSIT  STRING  COMMENT  '利息转存',
  C_NEED_REPO  STRING  COMMENT  ''
)
COMMENT '存款合同表'
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
                                   , VC_INTER_NO
                                   , VC_CONTRACT_NO
                                   , VC_CONTRACT_NAME
                                   , VC_CONTRACT_OWNER
                                   , VC_ACCOUNT_NAME
                                   , L_BANK
                                   , VC_AFFIX_OPERATOR
                                   , VC_ADVERSARY_OPERATOR
                                   , L_AFFIX_DATE
                                   , L_LIMIT_TIME
                                   , EN_BALANCE
                                   , EN_INTEREST_RATE
                                   , C_RATE_TYPE
                                   , EN_FLOAT_RATE
                                   , C_FLOAT_TYPE
                                   , EN_BASIC_RATE
                                   , EN_LEAST_RATE
                                   , L_PAY_INTEVAL
                                   , C_DAY_TYPE
                                   , C_CAL_TYPE
                                   , C_INTEREST_CAL_TYPE
                                   , C_DATE_TYPE
                                   , L_BASE_DATE
                                   , L_BASE_DAYS
                                   , C_BEGIN_PAY_TYPE
                                   , C_END_PAY_TYPE
                                   , C_CANCEL_TYPE
                                   , VC_REMARK
                                   , L_OPERATOR_NO
                                   , L_ADD_DATE
                                   , C_STATUS
                                   , VC_FUND_IDS
                                   , L_END_DATE
                                   , EN_HIGHEST_RATE
                                   , EN_ADVANCE_RATE
                                   , C_LIMIT_UNIT
                                   , L_ADVANCE_COUNT
                                   , L_ADVANCE_DEAL_COUNT
                                   , L_ADVANCE_DATE
                                   , C_DEPOSIT_TYPE
                                   , C_PAY_INTEVAL_UNIT
                                   , L_ADVANCE_DAYS
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , C_INTEREST_PAY_TYPE
                                   , C_INTEREST_DEPOSIT
                                   , C_NEED_REPO
                                FROM ${o32_src_schema}.TDEPOSITCONTRACT"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "VC_INTER_NO", "type": "STRING"}, {"name": "VC_CONTRACT_NO", "type": "STRING"}, {"name": "VC_CONTRACT_NAME", "type": "STRING"}, {"name": "VC_CONTRACT_OWNER", "type": "STRING"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "L_BANK", "type": "DOUBLE"}, {"name": "VC_AFFIX_OPERATOR", "type": "STRING"}, {"name": "VC_ADVERSARY_OPERATOR", "type": "STRING"}, {"name": "L_AFFIX_DATE", "type": "DOUBLE"}, {"name": "L_LIMIT_TIME", "type": "DOUBLE"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_INTEREST_RATE", "type": "DOUBLE"}, {"name": "C_RATE_TYPE", "type": "STRING"}, {"name": "EN_FLOAT_RATE", "type": "DOUBLE"}, {"name": "C_FLOAT_TYPE", "type": "STRING"}, {"name": "EN_BASIC_RATE", "type": "DOUBLE"}, {"name": "EN_LEAST_RATE", "type": "DOUBLE"}, {"name": "L_PAY_INTEVAL", "type": "DOUBLE"}, {"name": "C_DAY_TYPE", "type": "STRING"}, {"name": "C_CAL_TYPE", "type": "STRING"}, {"name": "C_INTEREST_CAL_TYPE", "type": "STRING"}, {"name": "C_DATE_TYPE", "type": "STRING"}, {"name": "L_BASE_DATE", "type": "DOUBLE"}, {"name": "L_BASE_DAYS", "type": "DOUBLE"}, {"name": "C_BEGIN_PAY_TYPE", "type": "STRING"}, {"name": "C_END_PAY_TYPE", "type": "STRING"}, {"name": "C_CANCEL_TYPE", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_ADD_DATE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_FUND_IDS", "type": "STRING"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "EN_HIGHEST_RATE", "type": "DOUBLE"}, {"name": "EN_ADVANCE_RATE", "type": "DOUBLE"}, {"name": "C_LIMIT_UNIT", "type": "STRING"}, {"name": "L_ADVANCE_COUNT", "type": "DOUBLE"}, {"name": "L_ADVANCE_DEAL_COUNT", "type": "DOUBLE"}, {"name": "L_ADVANCE_DATE", "type": "DOUBLE"}, {"name": "C_DEPOSIT_TYPE", "type": "STRING"}, {"name": "C_PAY_INTEVAL_UNIT", "type": "STRING"}, {"name": "L_ADVANCE_DAYS", "type": "DOUBLE"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "C_INTEREST_PAY_TYPE", "type": "STRING"}, {"name": "C_INTEREST_DEPOSIT", "type": "STRING"}, {"name": "C_NEED_REPO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tdepositcontract_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tdepositcontract_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tdepositcontract_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tdepositcontract_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TDEPOSITCONTRACT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TDEPOSITCONTRACT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tdepositcontract_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TDEPOSITCONTRACT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DATE
     , VC_INTER_CODE
     , VC_INTER_NO
     , VC_CONTRACT_NO
     , VC_CONTRACT_NAME
     , VC_CONTRACT_OWNER
     , VC_ACCOUNT_NAME
     , L_BANK
     , VC_AFFIX_OPERATOR
     , VC_ADVERSARY_OPERATOR
     , L_AFFIX_DATE
     , L_LIMIT_TIME
     , EN_BALANCE
     , EN_INTEREST_RATE
     , C_RATE_TYPE
     , EN_FLOAT_RATE
     , C_FLOAT_TYPE
     , EN_BASIC_RATE
     , EN_LEAST_RATE
     , L_PAY_INTEVAL
     , C_DAY_TYPE
     , C_CAL_TYPE
     , C_INTEREST_CAL_TYPE
     , C_DATE_TYPE
     , L_BASE_DATE
     , L_BASE_DAYS
     , C_BEGIN_PAY_TYPE
     , C_END_PAY_TYPE
     , C_CANCEL_TYPE
     , VC_REMARK
     , L_OPERATOR_NO
     , L_ADD_DATE
     , C_STATUS
     , VC_FUND_IDS
     , L_END_DATE
     , EN_HIGHEST_RATE
     , EN_ADVANCE_RATE
     , C_LIMIT_UNIT
     , L_ADVANCE_COUNT
     , L_ADVANCE_DEAL_COUNT
     , L_ADVANCE_DATE
     , C_DEPOSIT_TYPE
     , C_PAY_INTEVAL_UNIT
     , L_ADVANCE_DAYS
     , L_ORG_ID
     , L_DEPT_ID
     , C_INTEREST_PAY_TYPE
     , C_INTEREST_DEPOSIT
     , C_NEED_REPO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TDEPOSITCONTRACT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TDEPOSITCONTRACT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TDEPOSITCONTRACT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TDEPOSITCONTRACT_PFD成功"
      exit 0
   fi
fi
