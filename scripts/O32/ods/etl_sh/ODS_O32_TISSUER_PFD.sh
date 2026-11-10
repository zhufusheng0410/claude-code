#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TISSUER_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TISSUER_PFD_TMP(
  L_ISSUER_ID  DECIMAL(10,0)  COMMENT  '发行人序号',
  VC_ISSUER_NAME  STRING  COMMENT  '发行人名称',
  L_MOTHER_ISSUER_ID  DECIMAL(10,0)  COMMENT  '母发行人序号',
  VC_LINKMAN  STRING  COMMENT  '联系人',
  VC_ADDRESS  STRING  COMMENT  '地址',
  VC_PHONE  STRING  COMMENT  '联系电话',
  VC_FAX  STRING  COMMENT  '传真',
  C_OUTER_APPRAISE  STRING  COMMENT  '外部评级',
  VC_APPRAISE_ORGAN  STRING  COMMENT  '外部评级机构',
  C_INSIDE_APPRAISE  STRING  COMMENT  '内部评级',
  C_APPRAISE  STRING  COMMENT  '综合评级',
  VC_SUMMARY  STRING  COMMENT  '备注',
  VC_FULL_NAME  STRING  COMMENT  '＃发行人全称',
  VC_ISSUER_TYPE  STRING  COMMENT  '',
  VC_TRANSACTOR_NAME  STRING  COMMENT  '＃经办人姓名',
  VC_TRANSACTOR_ID_TYPE  STRING  COMMENT  '＃经办人证件类型',
  VC_TRANSACTOR_ID  STRING  COMMENT  '＃经办人证件号码',
  VC_TRANSACTOR_PHONE  STRING  COMMENT  '＃经办人联系电话',
  VC_TRANSACTOR_FAX  STRING  COMMENT  '＃经办人传真',
  VC_TRANSACTOR_STAMP  STRING  COMMENT  '＃经办人签章文件名',
  VC_PRE_STAMP  STRING  COMMENT  '＃预留签章文件名',
  VC_ISSUER_CODE  STRING  COMMENT  '发行人编号',
  EN_ISSUER_ASSET  DECIMAL(16,2)  COMMENT  '净资产',
  VC_ASSET_CURRENCY_NO  STRING  COMMENT  '净资产币种',
  VC_COUNTRY_NO  STRING  COMMENT  '国家',
  L_TRANSACTOR_VALIDITY  DECIMAL(8,0)  COMMENT  '经办人有效期',
  EN_CREDIT_LIMIT  DECIMAL(16,2)  COMMENT  '授信额度',
  C_GUARANTOR_APPRAISE  STRING  COMMENT  '担保人评级',
  VC_EXTERNAL_CODE  STRING  COMMENT  '外部编号',
  VC_ZX_IP  STRING  COMMENT  '直销服务器地址',
  VC_ZX_PORT  STRING  COMMENT  '直销服务器端口',
  VC_ZX_USER  STRING  COMMENT  '直销用户名',
  VC_ZX_PASS  STRING  COMMENT  '直销密码',
  L_OUTER_APPRAISE_DATE  DECIMAL(8,0)  COMMENT  '外部评级时间',
  L_TOTAL_ASSET_AMOUNT  DECIMAL(16,2)  COMMENT  '发行人总资产',
  EN_GUARANTOR_LIMIT  DECIMAL(16,2)  COMMENT  '担保额度',
  VC_PRE_STAMP2  STRING  COMMENT  '预留签章2',
  C_OUTER_APPRAISE1  STRING  COMMENT  '外部评级孰低',
  L_LASTQUARTER_ASSET  DECIMAL(16,2)  COMMENT  '最近季度末净资产',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  C_LEVEL_EXPECTATION  STRING  COMMENT  '评级展望',
  EN_LAST_YEAR_NET  DECIMAL(16,2)  COMMENT  '上一年度净利润',
  C_ISSUER_OTHER_APPRAISE_ONE  STRING  COMMENT  '其他评级一',
  C_ISSUER_OTHER_APPRAISE_TWO  STRING  COMMENT  '其他评级二',
  VC_PROVINCECODE  STRING  COMMENT  '省份',
  EN_ASSET_LIABILITY_RATIO  DECIMAL(16,8)  COMMENT  '资产负债率',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  EN_SURPLUS_AMOUNT  DECIMAL(16,2)  COMMENT  '',
  EN_INTEREST_EARNED_RATIO  DECIMAL(16,8)  COMMENT  '',
  C_ORG_TYPE  STRING  COMMENT  '',
  VC_SEC_CREDIT_CODE  STRING  COMMENT  '',
  VC_FINANCIALORG_CODE  STRING  COMMENT  '',
  VC_AGENCY_CODE  STRING  COMMENT  '',
  EN_LASTYEAR_ASSET  DECIMAL(16,2)  COMMENT  '上一年度总资产',
  C_FINANCE_ORG  STRING  COMMENT  '',
  L_HIGHER_ISSUER_ID  DECIMAL(10,0)  COMMENT  '',
  C_IS_RELATEDPARTY  STRING  COMMENT  '',
  VC_INTER_APPRAISE_NAME  STRING  COMMENT  '',
  L_INTER_APPRAISE_DATE  DECIMAL(8,0)  COMMENT  '',
  VC_CA_STAMP  STRING  COMMENT  '',
  VC_EMAIL  STRING  COMMENT  '电子邮箱',
  EN_BELONG_MOTHER_ASSET  DECIMAL(16,2)  COMMENT  '',
  VC_ISSUER_INDUSTRY  STRING  COMMENT  '',
  C_ISSUER_PROPERTY  STRING  COMMENT  '',
  C_GUARANTOR_APPRAISE2  STRING  COMMENT  '',
  VC_CITY  STRING  COMMENT  '',
  C_OTHER_APPRAISE_THREE  STRING  COMMENT  '其他评级三',
  C_OTHER_APPRAISE_FOUR  STRING  COMMENT  '其他评级四',
  VC_TIMESTAMP3  STRING  COMMENT  '',
  VC_TRANSACTOR_EMAIL  STRING  COMMENT  '',
  VC_TRANSACTOR_ADDRESS  STRING  COMMENT  '',
  VC_COUNTY  STRING  COMMENT  ''
)
COMMENT '发行人信息表'
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
              "querySql": ["SELECT  L_ISSUER_ID
                                   , VC_ISSUER_NAME
                                   , L_MOTHER_ISSUER_ID
                                   , VC_LINKMAN
                                   , VC_ADDRESS
                                   , VC_PHONE
                                   , VC_FAX
                                   , C_OUTER_APPRAISE
                                   , VC_APPRAISE_ORGAN
                                   , C_INSIDE_APPRAISE
                                   , C_APPRAISE
                                   , VC_SUMMARY
                                   , VC_FULL_NAME
                                   , VC_ISSUER_TYPE
                                   , VC_TRANSACTOR_NAME
                                   , VC_TRANSACTOR_ID_TYPE
                                   , VC_TRANSACTOR_ID
                                   , VC_TRANSACTOR_PHONE
                                   , VC_TRANSACTOR_FAX
                                   , VC_TRANSACTOR_STAMP
                                   , VC_PRE_STAMP
                                   , VC_ISSUER_CODE
                                   , EN_ISSUER_ASSET
                                   , VC_ASSET_CURRENCY_NO
                                   , VC_COUNTRY_NO
                                   , L_TRANSACTOR_VALIDITY
                                   , EN_CREDIT_LIMIT
                                   , C_GUARANTOR_APPRAISE
                                   , VC_EXTERNAL_CODE
                                   , VC_ZX_IP
                                   , VC_ZX_PORT
                                   , VC_ZX_USER
                                   , VC_ZX_PASS
                                   , L_OUTER_APPRAISE_DATE
                                   , L_TOTAL_ASSET_AMOUNT
                                   , EN_GUARANTOR_LIMIT
                                   , VC_PRE_STAMP2
                                   , C_OUTER_APPRAISE1
                                   , L_LASTQUARTER_ASSET
                                   , VC_TIMESTAMP
                                   , C_LEVEL_EXPECTATION
                                   , EN_LAST_YEAR_NET
                                   , C_ISSUER_OTHER_APPRAISE_ONE
                                   , C_ISSUER_OTHER_APPRAISE_TWO
                                   , VC_PROVINCECODE
                                   , EN_ASSET_LIABILITY_RATIO
                                   , L_DATE
                                   , EN_SURPLUS_AMOUNT
                                   , EN_INTEREST_EARNED_RATIO
                                   , C_ORG_TYPE
                                   , VC_SEC_CREDIT_CODE
                                   , VC_FINANCIALORG_CODE
                                   , VC_AGENCY_CODE
                                   , EN_LASTYEAR_ASSET
                                   , C_FINANCE_ORG
                                   , L_HIGHER_ISSUER_ID
                                   , C_IS_RELATEDPARTY
                                   , VC_INTER_APPRAISE_NAME
                                   , L_INTER_APPRAISE_DATE
                                   , VC_CA_STAMP
                                   , VC_EMAIL
                                   , EN_BELONG_MOTHER_ASSET
                                   , VC_ISSUER_INDUSTRY
                                   , C_ISSUER_PROPERTY
                                   , C_GUARANTOR_APPRAISE2
                                   , VC_CITY
                                   , C_OTHER_APPRAISE_THREE
                                   , C_OTHER_APPRAISE_FOUR
                                   , VC_TIMESTAMP3
                                   , VC_TRANSACTOR_EMAIL
                                   , VC_TRANSACTOR_ADDRESS
                                   , VC_COUNTY
                                FROM ${o32_src_schema}.THISISSUER
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ISSUER_ID", "type": "DOUBLE"}, {"name": "VC_ISSUER_NAME", "type": "STRING"}, {"name": "L_MOTHER_ISSUER_ID", "type": "DOUBLE"}, {"name": "VC_LINKMAN", "type": "STRING"}, {"name": "VC_ADDRESS", "type": "STRING"}, {"name": "VC_PHONE", "type": "STRING"}, {"name": "VC_FAX", "type": "STRING"}, {"name": "C_OUTER_APPRAISE", "type": "STRING"}, {"name": "VC_APPRAISE_ORGAN", "type": "STRING"}, {"name": "C_INSIDE_APPRAISE", "type": "STRING"}, {"name": "C_APPRAISE", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "VC_FULL_NAME", "type": "STRING"}, {"name": "VC_ISSUER_TYPE", "type": "STRING"}, {"name": "VC_TRANSACTOR_NAME", "type": "STRING"}, {"name": "VC_TRANSACTOR_ID_TYPE", "type": "STRING"}, {"name": "VC_TRANSACTOR_ID", "type": "STRING"}, {"name": "VC_TRANSACTOR_PHONE", "type": "STRING"}, {"name": "VC_TRANSACTOR_FAX", "type": "STRING"}, {"name": "VC_TRANSACTOR_STAMP", "type": "STRING"}, {"name": "VC_PRE_STAMP", "type": "STRING"}, {"name": "VC_ISSUER_CODE", "type": "STRING"}, {"name": "EN_ISSUER_ASSET", "type": "DOUBLE"}, {"name": "VC_ASSET_CURRENCY_NO", "type": "STRING"}, {"name": "VC_COUNTRY_NO", "type": "STRING"}, {"name": "L_TRANSACTOR_VALIDITY", "type": "DOUBLE"}, {"name": "EN_CREDIT_LIMIT", "type": "DOUBLE"}, {"name": "C_GUARANTOR_APPRAISE", "type": "STRING"}, {"name": "VC_EXTERNAL_CODE", "type": "STRING"}, {"name": "VC_ZX_IP", "type": "STRING"}, {"name": "VC_ZX_PORT", "type": "STRING"}, {"name": "VC_ZX_USER", "type": "STRING"}, {"name": "VC_ZX_PASS", "type": "STRING"}, {"name": "L_OUTER_APPRAISE_DATE", "type": "DOUBLE"}, {"name": "L_TOTAL_ASSET_AMOUNT", "type": "DOUBLE"}, {"name": "EN_GUARANTOR_LIMIT", "type": "DOUBLE"}, {"name": "VC_PRE_STAMP2", "type": "STRING"}, {"name": "C_OUTER_APPRAISE1", "type": "STRING"}, {"name": "L_LASTQUARTER_ASSET", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "C_LEVEL_EXPECTATION", "type": "STRING"}, {"name": "EN_LAST_YEAR_NET", "type": "DOUBLE"}, {"name": "C_ISSUER_OTHER_APPRAISE_ONE", "type": "STRING"}, {"name": "C_ISSUER_OTHER_APPRAISE_TWO", "type": "STRING"}, {"name": "VC_PROVINCECODE", "type": "STRING"}, {"name": "EN_ASSET_LIABILITY_RATIO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "EN_SURPLUS_AMOUNT", "type": "DOUBLE"}, {"name": "EN_INTEREST_EARNED_RATIO", "type": "DOUBLE"}, {"name": "C_ORG_TYPE", "type": "STRING"}, {"name": "VC_SEC_CREDIT_CODE", "type": "STRING"}, {"name": "VC_FINANCIALORG_CODE", "type": "STRING"}, {"name": "VC_AGENCY_CODE", "type": "STRING"}, {"name": "EN_LASTYEAR_ASSET", "type": "DOUBLE"}, {"name": "C_FINANCE_ORG", "type": "STRING"}, {"name": "L_HIGHER_ISSUER_ID", "type": "DOUBLE"}, {"name": "C_IS_RELATEDPARTY", "type": "STRING"}, {"name": "VC_INTER_APPRAISE_NAME", "type": "STRING"}, {"name": "L_INTER_APPRAISE_DATE", "type": "DOUBLE"}, {"name": "VC_CA_STAMP", "type": "STRING"}, {"name": "VC_EMAIL", "type": "STRING"}, {"name": "EN_BELONG_MOTHER_ASSET", "type": "DOUBLE"}, {"name": "VC_ISSUER_INDUSTRY", "type": "STRING"}, {"name": "C_ISSUER_PROPERTY", "type": "STRING"}, {"name": "C_GUARANTOR_APPRAISE2", "type": "STRING"}, {"name": "VC_CITY", "type": "STRING"}, {"name": "C_OTHER_APPRAISE_THREE", "type": "STRING"}, {"name": "C_OTHER_APPRAISE_FOUR", "type": "STRING"}, {"name": "VC_TIMESTAMP3", "type": "STRING"}, {"name": "VC_TRANSACTOR_EMAIL", "type": "STRING"}, {"name": "VC_TRANSACTOR_ADDRESS", "type": "STRING"}, {"name": "VC_COUNTY", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tissuer_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tissuer_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tissuer_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tissuer_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TISSUER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TISSUER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tissuer_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TISSUER_PFD PARTITION(P_DT)
SELECT
       L_ISSUER_ID
     , VC_ISSUER_NAME
     , L_MOTHER_ISSUER_ID
     , VC_LINKMAN
     , VC_ADDRESS
     , VC_PHONE
     , VC_FAX
     , C_OUTER_APPRAISE
     , VC_APPRAISE_ORGAN
     , C_INSIDE_APPRAISE
     , C_APPRAISE
     , VC_SUMMARY
     , VC_FULL_NAME
     , VC_ISSUER_TYPE
     , VC_TRANSACTOR_NAME
     , VC_TRANSACTOR_ID_TYPE
     , VC_TRANSACTOR_ID
     , VC_TRANSACTOR_PHONE
     , VC_TRANSACTOR_FAX
     , VC_TRANSACTOR_STAMP
     , VC_PRE_STAMP
     , VC_ISSUER_CODE
     , EN_ISSUER_ASSET
     , VC_ASSET_CURRENCY_NO
     , VC_COUNTRY_NO
     , L_TRANSACTOR_VALIDITY
     , EN_CREDIT_LIMIT
     , C_GUARANTOR_APPRAISE
     , VC_EXTERNAL_CODE
     , VC_ZX_IP
     , VC_ZX_PORT
     , VC_ZX_USER
     , VC_ZX_PASS
     , L_OUTER_APPRAISE_DATE
     , L_TOTAL_ASSET_AMOUNT
     , EN_GUARANTOR_LIMIT
     , VC_PRE_STAMP2
     , C_OUTER_APPRAISE1
     , L_LASTQUARTER_ASSET
     , VC_TIMESTAMP
     , C_LEVEL_EXPECTATION
     , EN_LAST_YEAR_NET
     , C_ISSUER_OTHER_APPRAISE_ONE
     , C_ISSUER_OTHER_APPRAISE_TWO
     , VC_PROVINCECODE
     , EN_ASSET_LIABILITY_RATIO
     , L_DATE
     , EN_SURPLUS_AMOUNT
     , EN_INTEREST_EARNED_RATIO
     , C_ORG_TYPE
     , VC_SEC_CREDIT_CODE
     , VC_FINANCIALORG_CODE
     , VC_AGENCY_CODE
     , EN_LASTYEAR_ASSET
     , C_FINANCE_ORG
     , L_HIGHER_ISSUER_ID
     , C_IS_RELATEDPARTY
     , VC_INTER_APPRAISE_NAME
     , L_INTER_APPRAISE_DATE
     , VC_CA_STAMP
     , VC_EMAIL
     , EN_BELONG_MOTHER_ASSET
     , VC_ISSUER_INDUSTRY
     , C_ISSUER_PROPERTY
     , C_GUARANTOR_APPRAISE2
     , VC_CITY
     , C_OTHER_APPRAISE_THREE
     , C_OTHER_APPRAISE_FOUR
     , VC_TIMESTAMP3
     , VC_TRANSACTOR_EMAIL
     , VC_TRANSACTOR_ADDRESS
     , VC_COUNTY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TISSUER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TISSUER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TISSUER_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TISSUER_PFD成功"
      exit 0
   fi
fi
