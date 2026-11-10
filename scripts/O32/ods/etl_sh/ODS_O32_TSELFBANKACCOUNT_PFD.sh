#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSELFBANKACCOUNT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSELFBANKACCOUNT_PFD_TMP(
  L_ACCOUNT_ID  DECIMAL(8,0)  COMMENT  '账户序号',
  VC_BANK_ACCOUNT  STRING  COMMENT  '银行/内部帐号',
  VC_BANK_NO  STRING  COMMENT  '开户总行',
  VC_SUBBANK_NO  STRING  COMMENT  '开户分/支行',
  VC_BANK_NAME  STRING  COMMENT  '开户行名称',
  VC_ACCOUNT_NAME  STRING  COMMENT  '开户户名',
  VC_PAY_NO  STRING  COMMENT  '支付系统号',
  VC_INTRABANK_NO  STRING  COMMENT  '联行号',
  VC_PROVINCECODE  STRING  COMMENT  '开户行所在省市',
  VC_CITYNO  STRING  COMMENT  '开户行所在城市',
  C_ACTUAL_ACCOUNT  STRING  COMMENT  '是否银行账户',
  C_ACCOUNT_TYPE  STRING  COMMENT  '账户类型',
  C_ACCOUNT_MANAGE_TYPE  STRING  COMMENT  '账户管理模式',
  VC_MARGIN_ACCOUNT  STRING  COMMENT  '保证金账户',
  C_DVP  STRING  COMMENT  '是否是dvp交收账户',
  C_STATUS  STRING  COMMENT  '账户状态',
  L_PARENT_ACCOUNT_ID  DECIMAL(8,0)  COMMENT  '上级账户序号',
  L_OPEN_DATE  DECIMAL(8,0)  COMMENT  '开户日期',
  L_CLOSE_DATE  DECIMAL(8,0)  COMMENT  '销户日期',
  VC_BANK_LINKMAN  STRING  COMMENT  '银行联系人',
  VC_BANK_PHONE  STRING  COMMENT  '银行联系电话',
  VC_BANK_FAX  STRING  COMMENT  '银行传真',
  VC_MEMO  STRING  COMMENT  '备注',
  VC_FUND_IDS  STRING  COMMENT  '作为结算户的基金',
  VC_ASSET_IDS  STRING  COMMENT  '作为结算户的资产单元',
  L_RECEIVE_DVP_ID  DECIMAL(8,0)  COMMENT  'dvp账户汇出汇路的账户序号',
  C_BANKMARKET_RESERVE  STRING  COMMENT  '是否为外汇交易中心预留账户',
  VC_USED_FUND_IDS  STRING  COMMENT  '可以使用的基金',
  VC_USED_ASSET_IDS  STRING  COMMENT  '可以使用的资产单元',
  VC_YZZZDM  STRING  COMMENT  '银证转帐代码',
  C_BANK_LIQUIDATE  STRING  COMMENT  '银行间清算账户',
  L_LAST_CHANGE_DATE  DECIMAL(8,0)  COMMENT  '新增日期',
  VC_ZZD_ACCOUNT  STRING  COMMENT  '中债登资金总帐号',
  VC_DVP_ACCOUNT_NAME  STRING  COMMENT  'dvp托管账号简称',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '所属公司',
  VC_EMAIL  STRING  COMMENT  '银行邮箱地址',
  VC_BANK_ADDRESS  STRING  COMMENT  '',
  C_TRIPARTY_CUSTODY_TYPE  STRING  COMMENT  '',
  VC_BUSIN_CLASSES  STRING  COMMENT  '业务分类'
)
COMMENT '本方账户信息表'
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
              "querySql": ["SELECT  L_ACCOUNT_ID
                                   , VC_BANK_ACCOUNT
                                   , VC_BANK_NO
                                   , VC_SUBBANK_NO
                                   , VC_BANK_NAME
                                   , VC_ACCOUNT_NAME
                                   , VC_PAY_NO
                                   , VC_INTRABANK_NO
                                   , VC_PROVINCECODE
                                   , VC_CITYNO
                                   , C_ACTUAL_ACCOUNT
                                   , C_ACCOUNT_TYPE
                                   , C_ACCOUNT_MANAGE_TYPE
                                   , VC_MARGIN_ACCOUNT
                                   , C_DVP
                                   , C_STATUS
                                   , L_PARENT_ACCOUNT_ID
                                   , L_OPEN_DATE
                                   , L_CLOSE_DATE
                                   , VC_BANK_LINKMAN
                                   , VC_BANK_PHONE
                                   , VC_BANK_FAX
                                   , VC_MEMO
                                   , VC_FUND_IDS
                                   , VC_ASSET_IDS
                                   , L_RECEIVE_DVP_ID
                                   , C_BANKMARKET_RESERVE
                                   , VC_USED_FUND_IDS
                                   , VC_USED_ASSET_IDS
                                   , VC_YZZZDM
                                   , C_BANK_LIQUIDATE
                                   , L_LAST_CHANGE_DATE
                                   , VC_ZZD_ACCOUNT
                                   , VC_DVP_ACCOUNT_NAME
                                   , L_ORG_ID
                                   , VC_EMAIL
                                   , VC_BANK_ADDRESS
                                   , C_TRIPARTY_CUSTODY_TYPE
                                   , VC_BUSIN_CLASSES
                                FROM ${o32_src_schema}.TSELFBANKACCOUNT"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ACCOUNT_ID", "type": "DOUBLE"}, {"name": "VC_BANK_ACCOUNT", "type": "STRING"}, {"name": "VC_BANK_NO", "type": "STRING"}, {"name": "VC_SUBBANK_NO", "type": "STRING"}, {"name": "VC_BANK_NAME", "type": "STRING"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "VC_PAY_NO", "type": "STRING"}, {"name": "VC_INTRABANK_NO", "type": "STRING"}, {"name": "VC_PROVINCECODE", "type": "STRING"}, {"name": "VC_CITYNO", "type": "STRING"}, {"name": "C_ACTUAL_ACCOUNT", "type": "STRING"}, {"name": "C_ACCOUNT_TYPE", "type": "STRING"}, {"name": "C_ACCOUNT_MANAGE_TYPE", "type": "STRING"}, {"name": "VC_MARGIN_ACCOUNT", "type": "STRING"}, {"name": "C_DVP", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_PARENT_ACCOUNT_ID", "type": "DOUBLE"}, {"name": "L_OPEN_DATE", "type": "DOUBLE"}, {"name": "L_CLOSE_DATE", "type": "DOUBLE"}, {"name": "VC_BANK_LINKMAN", "type": "STRING"}, {"name": "VC_BANK_PHONE", "type": "STRING"}, {"name": "VC_BANK_FAX", "type": "STRING"}, {"name": "VC_MEMO", "type": "STRING"}, {"name": "VC_FUND_IDS", "type": "STRING"}, {"name": "VC_ASSET_IDS", "type": "STRING"}, {"name": "L_RECEIVE_DVP_ID", "type": "DOUBLE"}, {"name": "C_BANKMARKET_RESERVE", "type": "STRING"}, {"name": "VC_USED_FUND_IDS", "type": "STRING"}, {"name": "VC_USED_ASSET_IDS", "type": "STRING"}, {"name": "VC_YZZZDM", "type": "STRING"}, {"name": "C_BANK_LIQUIDATE", "type": "STRING"}, {"name": "L_LAST_CHANGE_DATE", "type": "DOUBLE"}, {"name": "VC_ZZD_ACCOUNT", "type": "STRING"}, {"name": "VC_DVP_ACCOUNT_NAME", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "VC_EMAIL", "type": "STRING"}, {"name": "VC_BANK_ADDRESS", "type": "STRING"}, {"name": "C_TRIPARTY_CUSTODY_TYPE", "type": "STRING"}, {"name": "VC_BUSIN_CLASSES", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tselfbankaccount_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tselfbankaccount_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tselfbankaccount_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tselfbankaccount_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSELFBANKACCOUNT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSELFBANKACCOUNT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tselfbankaccount_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSELFBANKACCOUNT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ACCOUNT_ID
     , VC_BANK_ACCOUNT
     , VC_BANK_NO
     , VC_SUBBANK_NO
     , VC_BANK_NAME
     , VC_ACCOUNT_NAME
     , VC_PAY_NO
     , VC_INTRABANK_NO
     , VC_PROVINCECODE
     , VC_CITYNO
     , C_ACTUAL_ACCOUNT
     , C_ACCOUNT_TYPE
     , C_ACCOUNT_MANAGE_TYPE
     , VC_MARGIN_ACCOUNT
     , C_DVP
     , C_STATUS
     , L_PARENT_ACCOUNT_ID
     , L_OPEN_DATE
     , L_CLOSE_DATE
     , VC_BANK_LINKMAN
     , VC_BANK_PHONE
     , VC_BANK_FAX
     , VC_MEMO
     , VC_FUND_IDS
     , VC_ASSET_IDS
     , L_RECEIVE_DVP_ID
     , C_BANKMARKET_RESERVE
     , VC_USED_FUND_IDS
     , VC_USED_ASSET_IDS
     , VC_YZZZDM
     , C_BANK_LIQUIDATE
     , L_LAST_CHANGE_DATE
     , VC_ZZD_ACCOUNT
     , VC_DVP_ACCOUNT_NAME
     , L_ORG_ID
     , VC_EMAIL
     , VC_BANK_ADDRESS
     , C_TRIPARTY_CUSTODY_TYPE
     , VC_BUSIN_CLASSES
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSELFBANKACCOUNT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSELFBANKACCOUNT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSELFBANKACCOUNT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSELFBANKACCOUNT_PFD成功"
      exit 0
   fi
fi
