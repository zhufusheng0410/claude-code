#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD_TMP(
  C_CUSTNO  STRING  COMMENT  '客户编号',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_CUSTNAME  STRING  COMMENT  '客户全称',
  C_SHORTNAME  STRING  COMMENT  '客户简称',
  C_HELPCODE  STRING  COMMENT  '',
  C_IDENTITYTYPE  STRING  COMMENT  '客户证件类型',
  C_IDENTITYNO  STRING  COMMENT  '客户证件号码',
  C_ZIPCODE  STRING  COMMENT  '邮政编码',
  C_ADDRESS  STRING  COMMENT  '通讯地址',
  C_PHONE  STRING  COMMENT  '联系电话',
  C_FAXNO  STRING  COMMENT  '传真号码',
  C_MOBILENO  STRING  COMMENT  '手机号码',
  C_EMAIL  STRING  COMMENT  'Email地址',
  C_SEX  STRING  COMMENT  '客户性别',
  C_BIRTHDAY  STRING  COMMENT  '客户生日',
  C_VOCATION  STRING  COMMENT  '职业',
  C_EDUCATION  STRING  COMMENT  '学历',
  C_INCOME  STRING  COMMENT  '年收入',
  C_CONTACT  STRING  COMMENT  '经办人姓名',
  C_CONTYPE  STRING  COMMENT  '经办人证件类型',
  C_CONTNO  STRING  COMMENT  '经办人证件号码',
  C_BILLSENDFLAG  STRING  COMMENT  '对帐单寄送方式',
  C_CALLCENTER  STRING  COMMENT  '开通CallCenter标志',
  C_INTERNET  STRING  COMMENT  '开通网上交易标志',
  C_SECRETCODE  STRING  COMMENT  '密函号码',
  C_NATIONALITY  STRING  COMMENT  '国籍',
  C_CITYNO  STRING  COMMENT  '城市编号(地区)',
  C_LAWNAME  STRING  COMMENT  '法人姓名',
  C_SHACCO  STRING  COMMENT  '上交所股东',
  C_SZACCO  STRING  COMMENT  '深交所股东',
  C_BROKER  STRING  COMMENT  '经纪人',
  F_AGIO  DECIMAL(5,4)  COMMENT  '费率折扣',
  C_MEMO  STRING  COMMENT  '备注',
  C_RESERVE  STRING  COMMENT  '保留字段',
  C_CORPNAME  STRING  COMMENT  '工作单位名称',
  C_CORPTEL  STRING  COMMENT  '工作单位电话',
  C_SPECIALCODE  STRING  COMMENT  '特殊代码',
  C_ACTCODE  STRING  COMMENT  '活动代码',
  C_BILLSENDPASS  STRING  COMMENT  '对帐单寄送途径',
  C_ADDRESSINVALID  STRING  COMMENT  '地址无效标志',
  D_APPENDDATE  STRING  COMMENT  '记录新增日期',
  D_BACKDATE  STRING  COMMENT  '退信日期',
  C_INVALIDADDRESS  STRING  COMMENT  '退信地址',
  C_BACKREASON  STRING  COMMENT  '退信原因',
  C_MODIFYINFO  STRING  COMMENT  '修改重要内容信息',
  C_RECOMMENDER  STRING  COMMENT  '',
  C_RECOMMENDERTYPE  STRING  COMMENT  '',
  D_IDNOVALIDDATE  STRING  COMMENT  '',
  C_INSTREPRIDCODE  STRING  COMMENT  '',
  C_INSTREPRIDTYPE  STRING  COMMENT  '',
  D_CONTIDNOVALIDDATE  STRING  COMMENT  '',
  D_LAWIDNOVALIDDATE  STRING  COMMENT  '',
  C_INSTITUTIONTYPE  STRING  COMMENT  '',
  C_SPECIALFUNDACCO  STRING  COMMENT  '',
  C_ISGLFACCO  STRING  COMMENT  '',
  C_CITY  STRING  COMMENT  '',
  C_COMPANYCHAR  STRING  COMMENT  '',
  C_COUNTY  STRING  COMMENT  '',
  C_ENGLISHFAMLIYNAME  STRING  COMMENT  '',
  C_ENGLISHFIRSTNAME  STRING  COMMENT  '',
  C_MANAGERANGE  STRING  COMMENT  '',
  C_MARITAL  STRING  COMMENT  '',
  C_PROVINCE  STRING  COMMENT  '',
  F_EMPLOYEENUM  DECIMAL(16,2)  COMMENT  '',
  C_CLIENTRISKRATE  STRING  COMMENT  '',
  C_INVESTORTYPE  STRING  COMMENT  '',
  C_INVESTORPROCODE  STRING  COMMENT  '',
  C_AUXCERTTYPE  STRING  COMMENT  '',
  C_AUXCERTCODE  STRING  COMMENT  '',
  D_AUXCERTVALIDDATE  STRING  COMMENT  '',
  D_CERTVALIDDATE  STRING  COMMENT  '',
  D_INSTREPRCERTVALIDDATE  STRING  COMMENT  '',
  D_INSTTRANCERTVALIDDATE  STRING  COMMENT  '',
  C_SPECIFICATION  STRING  COMMENT  '',
  C_IPADDRESS  STRING  COMMENT  '',
  C_MACADDRESS  STRING  COMMENT  '',
  C_IMEI  STRING  COMMENT  '',
  C_UUID  STRING  COMMENT  '',
  C_ACCTNAMEOFCLEARINGAGENCY  STRING  COMMENT  '',
  C_ACCTNOOFCLEARINGAGENCY  STRING  COMMENT  '',
  C_CLEARINGAGENCY  STRING  COMMENT  '',
  D_LASTTRADEDATE  STRING  COMMENT  '',
  D_LASTACCODATE  STRING  COMMENT  '',
  L_FAMILYNUM  DECIMAL(2,0)  COMMENT  '',
  F_PENATES  DECIMAL(16,2)  COMMENT  '',
  C_MEDIAHOBBY  STRING  COMMENT  '',
  C_INDUSTRY  STRING  COMMENT  '',
  C_HOBBYTYPE  STRING  COMMENT  '',
  C_ACCEPTMETHOD  STRING  COMMENT  '',
  D_X1IDNOVALIDDATE  STRING  COMMENT  '',
  C_ISIDNOCHANGED  STRING  COMMENT  '',
  D_CERTVALIDDATE4MDF  STRING  COMMENT  '',
  D_LASTCERTVALIDDATE  STRING  COMMENT  '',
  D_LASTX1IDNOVALIDDATE  STRING  COMMENT  ''
)
COMMENT '客户基本信息'
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_CUSTNO
                                   , C_CUSTTYPE
                                   , C_CUSTNAME
                                   , C_SHORTNAME
                                   , C_HELPCODE
                                   , C_IDENTITYTYPE
                                   , C_IDENTITYNO
                                   , C_ZIPCODE
                                   , C_ADDRESS
                                   , C_PHONE
                                   , C_FAXNO
                                   , C_MOBILENO
                                   , C_EMAIL
                                   , C_SEX
                                   , C_BIRTHDAY
                                   , C_VOCATION
                                   , C_EDUCATION
                                   , C_INCOME
                                   , C_CONTACT
                                   , C_CONTYPE
                                   , C_CONTNO
                                   , C_BILLSENDFLAG
                                   , C_CALLCENTER
                                   , C_INTERNET
                                   , C_SECRETCODE
                                   , C_NATIONALITY
                                   , C_CITYNO
                                   , C_LAWNAME
                                   , C_SHACCO
                                   , C_SZACCO
                                   , C_BROKER
                                   , F_AGIO
                                   , C_MEMO
                                   , C_RESERVE
                                   , C_CORPNAME
                                   , C_CORPTEL
                                   , C_SPECIALCODE
                                   , C_ACTCODE
                                   , C_BILLSENDPASS
                                   , C_ADDRESSINVALID
                                   , D_APPENDDATE
                                   , D_BACKDATE
                                   , C_INVALIDADDRESS
                                   , C_BACKREASON
                                   , C_MODIFYINFO
                                   , C_RECOMMENDER
                                   , C_RECOMMENDERTYPE
                                   , D_IDNOVALIDDATE
                                   , C_INSTREPRIDCODE
                                   , C_INSTREPRIDTYPE
                                   , D_CONTIDNOVALIDDATE
                                   , D_LAWIDNOVALIDDATE
                                   , C_INSTITUTIONTYPE
                                   , C_SPECIALFUNDACCO
                                   , C_ISGLFACCO
                                   , C_CITY
                                   , C_COMPANYCHAR
                                   , C_COUNTY
                                   , C_ENGLISHFAMLIYNAME
                                   , C_ENGLISHFIRSTNAME
                                   , C_MANAGERANGE
                                   , C_MARITAL
                                   , C_PROVINCE
                                   , F_EMPLOYEENUM
                                   , C_CLIENTRISKRATE
                                   , C_INVESTORTYPE
                                   , C_INVESTORPROCODE
                                   , C_AUXCERTTYPE
                                   , C_AUXCERTCODE
                                   , D_AUXCERTVALIDDATE
                                   , D_CERTVALIDDATE
                                   , D_INSTREPRCERTVALIDDATE
                                   , D_INSTTRANCERTVALIDDATE
                                   , C_SPECIFICATION
                                   , C_IPADDRESS
                                   , C_MACADDRESS
                                   , C_IMEI
                                   , C_UUID
                                   , C_ACCTNAMEOFCLEARINGAGENCY
                                   , C_ACCTNOOFCLEARINGAGENCY
                                   , C_CLEARINGAGENCY
                                   , D_LASTTRADEDATE
                                   , D_LASTACCODATE
                                   , L_FAMILYNUM
                                   , F_PENATES
                                   , C_MEDIAHOBBY
                                   , C_INDUSTRY
                                   , C_HOBBYTYPE
                                   , C_ACCEPTMETHOD
                                   , D_X1IDNOVALIDDATE
                                   , C_ISIDNOCHANGED
                                   , D_CERTVALIDDATE4MDF
                                   , D_LASTCERTVALIDDATE
                                   , D_LASTX1IDNOVALIDDATE
                                FROM ${hsfta_src_schema}.TCUSTOMERINFO"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CUSTNO", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_CUSTNAME", "type": "STRING"}, {"name": "C_SHORTNAME", "type": "STRING"}, {"name": "C_HELPCODE", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "C_IDENTITYNO", "type": "STRING"}, {"name": "C_ZIPCODE", "type": "STRING"}, {"name": "C_ADDRESS", "type": "STRING"}, {"name": "C_PHONE", "type": "STRING"}, {"name": "C_FAXNO", "type": "STRING"}, {"name": "C_MOBILENO", "type": "STRING"}, {"name": "C_EMAIL", "type": "STRING"}, {"name": "C_SEX", "type": "STRING"}, {"name": "C_BIRTHDAY", "type": "STRING"}, {"name": "C_VOCATION", "type": "STRING"}, {"name": "C_EDUCATION", "type": "STRING"}, {"name": "C_INCOME", "type": "STRING"}, {"name": "C_CONTACT", "type": "STRING"}, {"name": "C_CONTYPE", "type": "STRING"}, {"name": "C_CONTNO", "type": "STRING"}, {"name": "C_BILLSENDFLAG", "type": "STRING"}, {"name": "C_CALLCENTER", "type": "STRING"}, {"name": "C_INTERNET", "type": "STRING"}, {"name": "C_SECRETCODE", "type": "STRING"}, {"name": "C_NATIONALITY", "type": "STRING"}, {"name": "C_CITYNO", "type": "STRING"}, {"name": "C_LAWNAME", "type": "STRING"}, {"name": "C_SHACCO", "type": "STRING"}, {"name": "C_SZACCO", "type": "STRING"}, {"name": "C_BROKER", "type": "STRING"}, {"name": "F_AGIO", "type": "DOUBLE"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "C_RESERVE", "type": "STRING"}, {"name": "C_CORPNAME", "type": "STRING"}, {"name": "C_CORPTEL", "type": "STRING"}, {"name": "C_SPECIALCODE", "type": "STRING"}, {"name": "C_ACTCODE", "type": "STRING"}, {"name": "C_BILLSENDPASS", "type": "STRING"}, {"name": "C_ADDRESSINVALID", "type": "STRING"}, {"name": "D_APPENDDATE", "type": "STRING"}, {"name": "D_BACKDATE", "type": "STRING"}, {"name": "C_INVALIDADDRESS", "type": "STRING"}, {"name": "C_BACKREASON", "type": "STRING"}, {"name": "C_MODIFYINFO", "type": "STRING"}, {"name": "C_RECOMMENDER", "type": "STRING"}, {"name": "C_RECOMMENDERTYPE", "type": "STRING"}, {"name": "D_IDNOVALIDDATE", "type": "STRING"}, {"name": "C_INSTREPRIDCODE", "type": "STRING"}, {"name": "C_INSTREPRIDTYPE", "type": "STRING"}, {"name": "D_CONTIDNOVALIDDATE", "type": "STRING"}, {"name": "D_LAWIDNOVALIDDATE", "type": "STRING"}, {"name": "C_INSTITUTIONTYPE", "type": "STRING"}, {"name": "C_SPECIALFUNDACCO", "type": "STRING"}, {"name": "C_ISGLFACCO", "type": "STRING"}, {"name": "C_CITY", "type": "STRING"}, {"name": "C_COMPANYCHAR", "type": "STRING"}, {"name": "C_COUNTY", "type": "STRING"}, {"name": "C_ENGLISHFAMLIYNAME", "type": "STRING"}, {"name": "C_ENGLISHFIRSTNAME", "type": "STRING"}, {"name": "C_MANAGERANGE", "type": "STRING"}, {"name": "C_MARITAL", "type": "STRING"}, {"name": "C_PROVINCE", "type": "STRING"}, {"name": "F_EMPLOYEENUM", "type": "DOUBLE"}, {"name": "C_CLIENTRISKRATE", "type": "STRING"}, {"name": "C_INVESTORTYPE", "type": "STRING"}, {"name": "C_INVESTORPROCODE", "type": "STRING"}, {"name": "C_AUXCERTTYPE", "type": "STRING"}, {"name": "C_AUXCERTCODE", "type": "STRING"}, {"name": "D_AUXCERTVALIDDATE", "type": "STRING"}, {"name": "D_CERTVALIDDATE", "type": "STRING"}, {"name": "D_INSTREPRCERTVALIDDATE", "type": "STRING"}, {"name": "D_INSTTRANCERTVALIDDATE", "type": "STRING"}, {"name": "C_SPECIFICATION", "type": "STRING"}, {"name": "C_IPADDRESS", "type": "STRING"}, {"name": "C_MACADDRESS", "type": "STRING"}, {"name": "C_IMEI", "type": "STRING"}, {"name": "C_UUID", "type": "STRING"}, {"name": "C_ACCTNAMEOFCLEARINGAGENCY", "type": "STRING"}, {"name": "C_ACCTNOOFCLEARINGAGENCY", "type": "STRING"}, {"name": "C_CLEARINGAGENCY", "type": "STRING"}, {"name": "D_LASTTRADEDATE", "type": "STRING"}, {"name": "D_LASTACCODATE", "type": "STRING"}, {"name": "L_FAMILYNUM", "type": "DOUBLE"}, {"name": "F_PENATES", "type": "DOUBLE"}, {"name": "C_MEDIAHOBBY", "type": "STRING"}, {"name": "C_INDUSTRY", "type": "STRING"}, {"name": "C_HOBBYTYPE", "type": "STRING"}, {"name": "C_ACCEPTMETHOD", "type": "STRING"}, {"name": "D_X1IDNOVALIDDATE", "type": "STRING"}, {"name": "C_ISIDNOCHANGED", "type": "STRING"}, {"name": "D_CERTVALIDDATE4MDF", "type": "STRING"}, {"name": "D_LASTCERTVALIDDATE", "type": "STRING"}, {"name": "D_LASTX1IDNOVALIDDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tcustomerinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tcustomerinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tcustomerinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tcustomerinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TCUSTOMERINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TCUSTOMERINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tcustomerinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_CUSTNO
     , C_CUSTTYPE
     , C_CUSTNAME
     , C_SHORTNAME
     , C_HELPCODE
     , C_IDENTITYTYPE
     , C_IDENTITYNO
     , C_ZIPCODE
     , C_ADDRESS
     , C_PHONE
     , C_FAXNO
     , C_MOBILENO
     , C_EMAIL
     , C_SEX
     , C_BIRTHDAY
     , C_VOCATION
     , C_EDUCATION
     , C_INCOME
     , C_CONTACT
     , C_CONTYPE
     , C_CONTNO
     , C_BILLSENDFLAG
     , C_CALLCENTER
     , C_INTERNET
     , C_SECRETCODE
     , C_NATIONALITY
     , C_CITYNO
     , C_LAWNAME
     , C_SHACCO
     , C_SZACCO
     , C_BROKER
     , F_AGIO
     , C_MEMO
     , C_RESERVE
     , C_CORPNAME
     , C_CORPTEL
     , C_SPECIALCODE
     , C_ACTCODE
     , C_BILLSENDPASS
     , C_ADDRESSINVALID
     , D_APPENDDATE
     , D_BACKDATE
     , C_INVALIDADDRESS
     , C_BACKREASON
     , C_MODIFYINFO
     , C_RECOMMENDER
     , C_RECOMMENDERTYPE
     , D_IDNOVALIDDATE
     , C_INSTREPRIDCODE
     , C_INSTREPRIDTYPE
     , D_CONTIDNOVALIDDATE
     , D_LAWIDNOVALIDDATE
     , C_INSTITUTIONTYPE
     , C_SPECIALFUNDACCO
     , C_ISGLFACCO
     , C_CITY
     , C_COMPANYCHAR
     , C_COUNTY
     , C_ENGLISHFAMLIYNAME
     , C_ENGLISHFIRSTNAME
     , C_MANAGERANGE
     , C_MARITAL
     , C_PROVINCE
     , F_EMPLOYEENUM
     , C_CLIENTRISKRATE
     , C_INVESTORTYPE
     , C_INVESTORPROCODE
     , C_AUXCERTTYPE
     , C_AUXCERTCODE
     , D_AUXCERTVALIDDATE
     , D_CERTVALIDDATE
     , D_INSTREPRCERTVALIDDATE
     , D_INSTTRANCERTVALIDDATE
     , C_SPECIFICATION
     , C_IPADDRESS
     , C_MACADDRESS
     , C_IMEI
     , C_UUID
     , C_ACCTNAMEOFCLEARINGAGENCY
     , C_ACCTNOOFCLEARINGAGENCY
     , C_CLEARINGAGENCY
     , D_LASTTRADEDATE
     , D_LASTACCODATE
     , L_FAMILYNUM
     , F_PENATES
     , C_MEDIAHOBBY
     , C_INDUSTRY
     , C_HOBBYTYPE
     , C_ACCEPTMETHOD
     , D_X1IDNOVALIDDATE
     , C_ISIDNOCHANGED
     , D_CERTVALIDDATE4MDF
     , D_LASTCERTVALIDDATE
     , D_LASTX1IDNOVALIDDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCUSTOMERINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TCUSTOMERINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TCUSTOMERINFO_PFD成功"
      exit 0
   fi
fi
