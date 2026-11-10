#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_COMPINTRODUCTION_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_COMPINTRODUCTION_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  COMP_ID  STRING  COMMENT  '公司ID',
  COMP_NAME  STRING  COMMENT  '公司名称',
  COMP_SNAME  STRING  COMMENT  '公司中文简称',
  COMP_NAME_ENG  STRING  COMMENT  '英文名称',
  COMP_SNAMEENG  STRING  COMMENT  '英文名称缩写',
  PROVINCE  STRING  COMMENT  '省份',
  CITY  STRING  COMMENT  '城市',
  ADDRESS  STRING  COMMENT  '注册地址',
  OFFICE  STRING  COMMENT  '办公地址',
  ZIPCODE  STRING  COMMENT  '邮编',
  PHONE  STRING  COMMENT  '电话',
  FAX  STRING  COMMENT  '传真',
  EMAIL  STRING  COMMENT  '电子邮件',
  WEBSITE  STRING  COMMENT  '公司网址',
  REGISTERNUMBER  STRING  COMMENT  '统一社会信用代码',
  CHAIRMAN  STRING  COMMENT  '法定代表人',
  PRESIDENT  STRING  COMMENT  '总经理',
  DISCLOSER  STRING  COMMENT  '信息披露人',
  REGCAPITAL  DECIMAL(18,2)  COMMENT  '注册资本',
  CURRENCYCODE  STRING  COMMENT  '货币代码',
  FOUNDDATE  STRING  COMMENT  '成立日期',
  ENDDATE  STRING  COMMENT  '公司终止日期',
  BRIEFING  STRING  COMMENT  '公司简介',
  COMP_TYPE  STRING  COMMENT  '公司类型',
  COMP_PROPERTY  STRING  COMMENT  '企业性质',
  COUNTRY  STRING  COMMENT  '国籍',
  BUSINESSSCOPE  STRING  COMMENT  '经营范围',
  COMPANY_TYPE  STRING  COMMENT  '公司类别',
  S_INFO_TOTALEMPLOYEES  DECIMAL(18,2)  COMMENT  '员工总数(人)',
  MAIN_BUSINESS  STRING  COMMENT  '主要产品及业务',
  SOCIAL_CREDIT_CODE  STRING  COMMENT  '统一社会信用编码(废弃)',
  S_INFO_ORG_CODE  STRING  COMMENT  '组织机构代码',
  IS_LISTED  DECIMAL(18,2)  COMMENT  '是否上市公司',
  S_INFO_COMPTYPE  STRING  COMMENT  '公司类型',
  IS_REGISTERED  DECIMAL(18,2)  COMMENT  '是否工商注册企业',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '公司简介'
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
            "username": "${wind_username}",
            "password": "${wind_password}",
            "connection": [{
              "querySql": ["SELECT  OBJECT_ID
                                   , COMP_ID
                                   , COMP_NAME
                                   , COMP_SNAME
                                   , COMP_NAME_ENG
                                   , COMP_SNAMEENG
                                   , PROVINCE
                                   , CITY
                                   , ADDRESS
                                   , OFFICE
                                   , ZIPCODE
                                   , PHONE
                                   , FAX
                                   , EMAIL
                                   , WEBSITE
                                   , REGISTERNUMBER
                                   , CHAIRMAN
                                   , PRESIDENT
                                   , DISCLOSER
                                   , REGCAPITAL
                                   , CURRENCYCODE
                                   , FOUNDDATE
                                   , ENDDATE
                                   , BRIEFING
                                   , COMP_TYPE
                                   , COMP_PROPERTY
                                   , COUNTRY
                                   , BUSINESSSCOPE
                                   , COMPANY_TYPE
                                   , S_INFO_TOTALEMPLOYEES
                                   , MAIN_BUSINESS
                                   , SOCIAL_CREDIT_CODE
                                   , S_INFO_ORG_CODE
                                   , IS_LISTED
                                   , S_INFO_COMPTYPE
                                   , IS_REGISTERED
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.COMPINTRODUCTION"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "COMP_ID", "type": "STRING"}, {"name": "COMP_NAME", "type": "STRING"}, {"name": "COMP_SNAME", "type": "STRING"}, {"name": "COMP_NAME_ENG", "type": "STRING"}, {"name": "COMP_SNAMEENG", "type": "STRING"}, {"name": "PROVINCE", "type": "STRING"}, {"name": "CITY", "type": "STRING"}, {"name": "ADDRESS", "type": "STRING"}, {"name": "OFFICE", "type": "STRING"}, {"name": "ZIPCODE", "type": "STRING"}, {"name": "PHONE", "type": "STRING"}, {"name": "FAX", "type": "STRING"}, {"name": "EMAIL", "type": "STRING"}, {"name": "WEBSITE", "type": "STRING"}, {"name": "REGISTERNUMBER", "type": "STRING"}, {"name": "CHAIRMAN", "type": "STRING"}, {"name": "PRESIDENT", "type": "STRING"}, {"name": "DISCLOSER", "type": "STRING"}, {"name": "REGCAPITAL", "type": "DOUBLE"}, {"name": "CURRENCYCODE", "type": "STRING"}, {"name": "FOUNDDATE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "BRIEFING", "type": "STRING"}, {"name": "COMP_TYPE", "type": "STRING"}, {"name": "COMP_PROPERTY", "type": "STRING"}, {"name": "COUNTRY", "type": "STRING"}, {"name": "BUSINESSSCOPE", "type": "STRING"}, {"name": "COMPANY_TYPE", "type": "STRING"}, {"name": "S_INFO_TOTALEMPLOYEES", "type": "DOUBLE"}, {"name": "MAIN_BUSINESS", "type": "STRING"}, {"name": "SOCIAL_CREDIT_CODE", "type": "STRING"}, {"name": "S_INFO_ORG_CODE", "type": "STRING"}, {"name": "IS_LISTED", "type": "DOUBLE"}, {"name": "S_INFO_COMPTYPE", "type": "STRING"}, {"name": "IS_REGISTERED", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_compintroduction_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_compintroduction_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_compintroduction_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_compintroduction_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_COMPINTRODUCTION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_COMPINTRODUCTION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_compintroduction_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_COMPINTRODUCTION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , COMP_ID
     , COMP_NAME
     , COMP_SNAME
     , COMP_NAME_ENG
     , COMP_SNAMEENG
     , PROVINCE
     , CITY
     , ADDRESS
     , OFFICE
     , ZIPCODE
     , PHONE
     , FAX
     , EMAIL
     , WEBSITE
     , REGISTERNUMBER
     , CHAIRMAN
     , PRESIDENT
     , DISCLOSER
     , REGCAPITAL
     , CURRENCYCODE
     , FOUNDDATE
     , ENDDATE
     , BRIEFING
     , COMP_TYPE
     , COMP_PROPERTY
     , COUNTRY
     , BUSINESSSCOPE
     , COMPANY_TYPE
     , S_INFO_TOTALEMPLOYEES
     , MAIN_BUSINESS
     , SOCIAL_CREDIT_CODE
     , S_INFO_ORG_CODE
     , IS_LISTED
     , S_INFO_COMPTYPE
     , IS_REGISTERED
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_COMPINTRODUCTION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_COMPINTRODUCTION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_COMPINTRODUCTION_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_COMPINTRODUCTION_PFD成功"
      exit 0
   fi
fi
