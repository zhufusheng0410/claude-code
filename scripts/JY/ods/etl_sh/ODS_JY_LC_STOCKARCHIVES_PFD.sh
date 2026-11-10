#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_STOCKARCHIVES_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_STOCKARCHIVES_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  STATE  DECIMAL(10,0)  COMMENT  '国别',
  SECRETARYBD  STRING  COMMENT  '董事会秘书',
  SECUAFFAIRSREPR  STRING  COMMENT  '证券/股证事务代表',
  AUTHREPRSBD  STRING  COMMENT  '董秘授权代表',
  CONTACTTEL  STRING  COMMENT  '联系人电话',
  CONTACTFAX  STRING  COMMENT  '联系人传真',
  CONTACTEMAIL  STRING  COMMENT  '联系人电子邮箱',
  REGADDR  STRING  COMMENT  '公司注册地址',
  REGZIPCODE  STRING  COMMENT  '公司注册地址邮编',
  OFFICEADDR  STRING  COMMENT  '公司办公地址',
  OFFICEZIPCODE  STRING  COMMENT  '公司办公地址邮编',
  CONTACTADDR  STRING  COMMENT  '公司联系地址',
  CONATACTZIPCODE  STRING  COMMENT  '公司联系地址邮编',
  EMAIL  STRING  COMMENT  '邮箱',
  WEBSITE  STRING  COMMENT  '公司网址',
  DISCLOSUREWEBSITES  STRING  COMMENT  '信息披露网址',
  DISCLOSUREPAPERS  STRING  COMMENT  '信息披露报纸',
  ESTABLISHMENTDATE  STRING  COMMENT  '公司成立日期',
  IREGPLACE  STRING  COMMENT  '首次注册登记地点',
  LEGALREPR  STRING  COMMENT  '法人代表',
  GENERALMANAGER  STRING  COMMENT  '总经理',
  LEGALCONSULTANT  STRING  COMMENT  '法律顾问',
  ACCOUNTINGFIRM  STRING  COMMENT  '会计师事务所',
  INDUCSRC  DECIMAL(10,0)  COMMENT  '公司所属证监会行业(聚源)',
  BUSINESSMAJOR  STRING  COMMENT  '经营范围-主营',
  BUSINESSMINOR  STRING  COMMENT  '经营范围-兼营',
  ASHAREABBR  STRING  COMMENT  'A股证券简称',
  ASTOCKCODE  STRING  COMMENT  'A股证券代码',
  BSHAREABBR  STRING  COMMENT  'B股证券简称',
  BSTOCKCODE  STRING  COMMENT  'B股证券代码',
  HSHAREABBR  STRING  COMMENT  'H股证券简称',
  HSTOCKCODE  STRING  COMMENT  'H股证券代码',
  BRIEFINTROTEXT  STRING  COMMENT  '公司简介',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  CHINAME  STRING  COMMENT  '中文名称',
  BUSINESSREGNUMBER  STRING  COMMENT  '企业法人营业执照注册号',
  SECRETARYBDTEL  STRING  COMMENT  '董秘电话',
  SECRETARYBDFAX  STRING  COMMENT  '董秘传真',
  SECRETARYBDEMAIL  STRING  COMMENT  '董秘电子邮件',
  SECUAFFAIRSREPRTEL  STRING  COMMENT  '证券事务代表电话',
  SECUAFFAIRSREPRFAX  STRING  COMMENT  '证券事务代表传真',
  SECUAFFAIRSREPREMAIL  STRING  COMMENT  '证券事务代表电子邮件',
  CITYCODE  STRING  COMMENT  '地区代码',
  CDRSHAREABBR  STRING  COMMENT  'CDR证券简称',
  CDRSTOCKCODE  STRING  COMMENT  'CDR证券代码',
  EXTENDEDABBR  STRING  COMMENT  '扩位简称',
  UNPROFITABLEMARK  STRING  COMMENT  '尚未盈利标识',
  SPECIALVOTEMARK  STRING  COMMENT  '特殊表决权标识',
  VIEMARK  STRING  COMMENT  '协议控制架构标识',
  REDCHIPMARK  STRING  COMMENT  '红筹企业标识',
  REGAREA  DECIMAL(10,0)  COMMENT  '所属区县'
)
COMMENT '公司概况'
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
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , COMPANYCODE
                                   , STATE
                                   , SECRETARYBD
                                   , SECUAFFAIRSREPR
                                   , AUTHREPRSBD
                                   , CONTACTTEL
                                   , CONTACTFAX
                                   , CONTACTEMAIL
                                   , REGADDR
                                   , REGZIPCODE
                                   , OFFICEADDR
                                   , OFFICEZIPCODE
                                   , CONTACTADDR
                                   , CONATACTZIPCODE
                                   , EMAIL
                                   , WEBSITE
                                   , DISCLOSUREWEBSITES
                                   , DISCLOSUREPAPERS
                                   , ESTABLISHMENTDATE
                                   , IREGPLACE
                                   , LEGALREPR
                                   , GENERALMANAGER
                                   , LEGALCONSULTANT
                                   , ACCOUNTINGFIRM
                                   , INDUCSRC
                                   , BUSINESSMAJOR
                                   , BUSINESSMINOR
                                   , ASHAREABBR
                                   , ASTOCKCODE
                                   , BSHAREABBR
                                   , BSTOCKCODE
                                   , HSHAREABBR
                                   , HSTOCKCODE
                                   , BRIEFINTROTEXT
                                   , XGRQ
                                   , JSID
                                   , CHINAME
                                   , BUSINESSREGNUMBER
                                   , SECRETARYBDTEL
                                   , SECRETARYBDFAX
                                   , SECRETARYBDEMAIL
                                   , SECUAFFAIRSREPRTEL
                                   , SECUAFFAIRSREPRFAX
                                   , SECUAFFAIRSREPREMAIL
                                   , CITYCODE
                                   , CDRSHAREABBR
                                   , CDRSTOCKCODE
                                   , EXTENDEDABBR
                                   , UNPROFITABLEMARK
                                   , SPECIALVOTEMARK
                                   , VIEMARK
                                   , REDCHIPMARK
                                   , REGAREA
                                FROM ${jy_src_schema}.LC_STOCKARCHIVES"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "STATE", "type": "DOUBLE"}, {"name": "SECRETARYBD", "type": "STRING"}, {"name": "SECUAFFAIRSREPR", "type": "STRING"}, {"name": "AUTHREPRSBD", "type": "STRING"}, {"name": "CONTACTTEL", "type": "STRING"}, {"name": "CONTACTFAX", "type": "STRING"}, {"name": "CONTACTEMAIL", "type": "STRING"}, {"name": "REGADDR", "type": "STRING"}, {"name": "REGZIPCODE", "type": "STRING"}, {"name": "OFFICEADDR", "type": "STRING"}, {"name": "OFFICEZIPCODE", "type": "STRING"}, {"name": "CONTACTADDR", "type": "STRING"}, {"name": "CONATACTZIPCODE", "type": "STRING"}, {"name": "EMAIL", "type": "STRING"}, {"name": "WEBSITE", "type": "STRING"}, {"name": "DISCLOSUREWEBSITES", "type": "STRING"}, {"name": "DISCLOSUREPAPERS", "type": "STRING"}, {"name": "ESTABLISHMENTDATE", "type": "STRING"}, {"name": "IREGPLACE", "type": "STRING"}, {"name": "LEGALREPR", "type": "STRING"}, {"name": "GENERALMANAGER", "type": "STRING"}, {"name": "LEGALCONSULTANT", "type": "STRING"}, {"name": "ACCOUNTINGFIRM", "type": "STRING"}, {"name": "INDUCSRC", "type": "DOUBLE"}, {"name": "BUSINESSMAJOR", "type": "STRING"}, {"name": "BUSINESSMINOR", "type": "STRING"}, {"name": "ASHAREABBR", "type": "STRING"}, {"name": "ASTOCKCODE", "type": "STRING"}, {"name": "BSHAREABBR", "type": "STRING"}, {"name": "BSTOCKCODE", "type": "STRING"}, {"name": "HSHAREABBR", "type": "STRING"}, {"name": "HSTOCKCODE", "type": "STRING"}, {"name": "BRIEFINTROTEXT", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "CHINAME", "type": "STRING"}, {"name": "BUSINESSREGNUMBER", "type": "STRING"}, {"name": "SECRETARYBDTEL", "type": "STRING"}, {"name": "SECRETARYBDFAX", "type": "STRING"}, {"name": "SECRETARYBDEMAIL", "type": "STRING"}, {"name": "SECUAFFAIRSREPRTEL", "type": "STRING"}, {"name": "SECUAFFAIRSREPRFAX", "type": "STRING"}, {"name": "SECUAFFAIRSREPREMAIL", "type": "STRING"}, {"name": "CITYCODE", "type": "DOUBLE"}, {"name": "CDRSHAREABBR", "type": "STRING"}, {"name": "CDRSTOCKCODE", "type": "STRING"}, {"name": "EXTENDEDABBR", "type": "STRING"}, {"name": "UNPROFITABLEMARK", "type": "STRING"}, {"name": "SPECIALVOTEMARK", "type": "STRING"}, {"name": "VIEMARK", "type": "STRING"}, {"name": "REDCHIPMARK", "type": "STRING"}, {"name": "REGAREA", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_stockarchives_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_stockarchives_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_stockarchives_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_stockarchives_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_STOCKARCHIVES_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_STOCKARCHIVES_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_stockarchives_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_STOCKARCHIVES_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , STATE
     , SECRETARYBD
     , SECUAFFAIRSREPR
     , AUTHREPRSBD
     , CONTACTTEL
     , CONTACTFAX
     , CONTACTEMAIL
     , REGADDR
     , REGZIPCODE
     , OFFICEADDR
     , OFFICEZIPCODE
     , CONTACTADDR
     , CONATACTZIPCODE
     , EMAIL
     , WEBSITE
     , DISCLOSUREWEBSITES
     , DISCLOSUREPAPERS
     , ESTABLISHMENTDATE
     , IREGPLACE
     , LEGALREPR
     , GENERALMANAGER
     , LEGALCONSULTANT
     , ACCOUNTINGFIRM
     , INDUCSRC
     , BUSINESSMAJOR
     , BUSINESSMINOR
     , ASHAREABBR
     , ASTOCKCODE
     , BSHAREABBR
     , BSTOCKCODE
     , HSHAREABBR
     , HSTOCKCODE
     , BRIEFINTROTEXT
     , XGRQ
     , JSID
     , CHINAME
     , BUSINESSREGNUMBER
     , SECRETARYBDTEL
     , SECRETARYBDFAX
     , SECRETARYBDEMAIL
     , SECUAFFAIRSREPRTEL
     , SECUAFFAIRSREPRFAX
     , SECUAFFAIRSREPREMAIL
     , CITYCODE
     , CDRSHAREABBR
     , CDRSTOCKCODE
     , EXTENDEDABBR
     , UNPROFITABLEMARK
     , SPECIALVOTEMARK
     , VIEMARK
     , REDCHIPMARK
     , REGAREA
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_STOCKARCHIVES_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_STOCKARCHIVES_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_STOCKARCHIVES_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_STOCKARCHIVES_PFD成功"
      exit 0
   fi
fi
