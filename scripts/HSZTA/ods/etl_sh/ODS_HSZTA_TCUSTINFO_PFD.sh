#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD_TMP(
  C_CUSTNO  STRING  COMMENT  '客户编号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_ACCOUNTTYPE  STRING  COMMENT  '账户类型',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_CUSTNAME  STRING  COMMENT  '客户全称',
  C_SHORTNAME  STRING  COMMENT  '客户简称',
  C_IDENTITYTYPE  STRING  COMMENT  '客户证件类型',
  C_IDENTITYNO  STRING  COMMENT  '客户证件号码',
  D_IDNOVALIDDATE  STRING  COMMENT  '',
  C_IDCARD18LEN  STRING  COMMENT  '身份证18位标志',
  D_OPENDATE  STRING  COMMENT  '',
  D_LASTMODIFY  STRING  COMMENT  '最后修改日期',
  C_ACCOSTATUS  STRING  COMMENT  '账户状态',
  L_CHANGETIME  DECIMAL(4,0)  COMMENT  '',
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
  C_CORPNAME  STRING  COMMENT  '工作单位名称',
  C_CORPTEL  STRING  COMMENT  '工作单位电话',
  C_CONTACT  STRING  COMMENT  '经办人姓名',
  C_CONTYPE  STRING  COMMENT  '经办人证件类型',
  C_CONTNO  STRING  COMMENT  '经办人证件号码',
  C_CONIDCARD18LEN  STRING  COMMENT  '',
  C_BILLSENDFLAG  STRING  COMMENT  '对帐单寄送方式',
  C_CALLCENTER  STRING  COMMENT  '开通CallCenter标志',
  C_INTERNET  STRING  COMMENT  '开通网上交易标志',
  C_BILLSENDPASS  STRING  COMMENT  '对帐单寄送途径',
  C_NATIONALITY  STRING  COMMENT  '国籍',
  C_LAWNAME  STRING  COMMENT  '法人姓名',
  C_LAWIDTYPE  STRING  COMMENT  '法人类型',
  C_LAWIDNO  STRING  COMMENT  '法人编号',
  C_BROKER  STRING  COMMENT  '经纪人',
  C_RECOMMENDER  STRING  COMMENT  '',
  C_RECOMMENDERTYPE  STRING  COMMENT  '',
  C_CITYNO  STRING  COMMENT  '城市编号(地区)',
  C_MODIFYINFO  STRING  COMMENT  '',
  C_FREEZECAUSE  STRING  COMMENT  '冻结原因',
  C_SPECIALCODE  STRING  COMMENT  '特殊代码',
  C_BACKREASON  STRING  COMMENT  '',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_SYSROLE  STRING  COMMENT  '系统角色',
  C_INSTREPRIDCODE  STRING  COMMENT  '',
  C_INSTREPRIDTYPE  STRING  COMMENT  '',
  C_HOMETELNO  STRING  COMMENT  '',
  C_SHACCO  STRING  COMMENT  '上交所股东',
  C_SZACCO  STRING  COMMENT  '深交所股东',
  C_MINORFLAG  STRING  COMMENT  '',
  C_TRANSACTTYPE  STRING  COMMENT  '',
  D_CONTIDNOVALIDDATE  STRING  COMMENT  '',
  D_LAWIDNOVALIDDATE  STRING  COMMENT  '',
  C_RISKLEVEL  STRING  COMMENT  '风险等级',
  C_MANAGERANGE  STRING  COMMENT  '',
  C_CONTROLHOLDER  STRING  COMMENT  '',
  C_ACTUALCONTROLLER  STRING  COMMENT  '',
  C_MARITAL  STRING  COMMENT  '',
  L_FAMILYNUM  DECIMAL(2,0)  COMMENT  '',
  F_PENATES  DECIMAL(16,2)  COMMENT  '',
  C_MEDIAHOBBY  STRING  COMMENT  '',
  C_INSTITUTIONTYPE  STRING  COMMENT  '',
  C_ENGLISHFIRSTNAME  STRING  COMMENT  '',
  C_ENGLISHFAMLIYNAME  STRING  COMMENT  '',
  C_INDUSTRY  STRING  COMMENT  '',
  C_COMPANYCHAR  STRING  COMMENT  '',
  F_EMPLOYEENUM  DECIMAL(16,2)  COMMENT  '',
  C_INTERESTTYPE  STRING  COMMENT  '利率类型',
  C_PROVINCE  STRING  COMMENT  '省份',
  C_CITY  STRING  COMMENT  '开户地城市',
  C_COUNTY  STRING  COMMENT  '',
  L_MODCUSTNAMECOUNT  DECIMAL(10,0)  COMMENT  '',
  D_CLOSEDATE  STRING  COMMENT  '',
  C_OPENAGENCYNO  STRING  COMMENT  '',
  C_MANAGERREGISCODE  STRING  COMMENT  '',
  C_ACCOUNTCARDID  STRING  COMMENT  '',
  C_TRADEVOLUME  STRING  COMMENT  '',
  C_TRADEFREQUENCY  STRING  COMMENT  '',
  C_ANNUITYCOMBCODE  STRING  COMMENT  '',
  C_INVESTORPROCODE  STRING  COMMENT  '',
  C_AUXCERTTYPE  STRING  COMMENT  '',
  C_AUXCERTCODE  STRING  COMMENT  '',
  D_AUXCERTVALIDDATE  STRING  COMMENT  '',
  D_X1IDNOVALIDDATE  STRING  COMMENT  '',
  C_MODIFYINFOIDTYPE  STRING  COMMENT  '',
  C_OPENNETNO  STRING  COMMENT  '',
  C_ACCOSOURCE  STRING  COMMENT  '',
  C_LONGTMACCOFLAG  STRING  COMMENT  '',
  C_AGCCUSTNO  STRING  COMMENT  '',
  C_ICSECONDACCO  STRING  COMMENT  '',
  C_FOREIGN  STRING  COMMENT  ''
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_CUSTNO
                                   , C_FUNDACCO
                                   , C_ACCOUNTTYPE
                                   , C_CUSTTYPE
                                   , C_CUSTNAME
                                   , C_SHORTNAME
                                   , C_IDENTITYTYPE
                                   , C_IDENTITYNO
                                   , D_IDNOVALIDDATE
                                   , C_IDCARD18LEN
                                   , D_OPENDATE
                                   , D_LASTMODIFY
                                   , C_ACCOSTATUS
                                   , L_CHANGETIME
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
                                   , C_CORPNAME
                                   , C_CORPTEL
                                   , C_CONTACT
                                   , C_CONTYPE
                                   , C_CONTNO
                                   , C_CONIDCARD18LEN
                                   , C_BILLSENDFLAG
                                   , C_CALLCENTER
                                   , C_INTERNET
                                   , C_BILLSENDPASS
                                   , C_NATIONALITY
                                   , C_LAWNAME
                                   , C_LAWIDTYPE
                                   , C_LAWIDNO
                                   , C_BROKER
                                   , C_RECOMMENDER
                                   , C_RECOMMENDERTYPE
                                   , C_CITYNO
                                   , C_MODIFYINFO
                                   , C_FREEZECAUSE
                                   , C_SPECIALCODE
                                   , C_BACKREASON
                                   , C_BOURSEFLAG
                                   , C_SYSROLE
                                   , C_INSTREPRIDCODE
                                   , C_INSTREPRIDTYPE
                                   , C_HOMETELNO
                                   , C_SHACCO
                                   , C_SZACCO
                                   , C_MINORFLAG
                                   , C_TRANSACTTYPE
                                   , D_CONTIDNOVALIDDATE
                                   , D_LAWIDNOVALIDDATE
                                   , C_RISKLEVEL
                                   , C_MANAGERANGE
                                   , C_CONTROLHOLDER
                                   , C_ACTUALCONTROLLER
                                   , C_MARITAL
                                   , L_FAMILYNUM
                                   , F_PENATES
                                   , C_MEDIAHOBBY
                                   , C_INSTITUTIONTYPE
                                   , C_ENGLISHFIRSTNAME
                                   , C_ENGLISHFAMLIYNAME
                                   , C_INDUSTRY
                                   , C_COMPANYCHAR
                                   , F_EMPLOYEENUM
                                   , C_INTERESTTYPE
                                   , C_PROVINCE
                                   , C_CITY
                                   , C_COUNTY
                                   , L_MODCUSTNAMECOUNT
                                   , D_CLOSEDATE
                                   , C_OPENAGENCYNO
                                   , C_MANAGERREGISCODE
                                   , C_ACCOUNTCARDID
                                   , C_TRADEVOLUME
                                   , C_TRADEFREQUENCY
                                   , C_ANNUITYCOMBCODE
                                   , C_INVESTORPROCODE
                                   , C_AUXCERTTYPE
                                   , C_AUXCERTCODE
                                   , D_AUXCERTVALIDDATE
                                   , D_X1IDNOVALIDDATE
                                   , C_MODIFYINFOIDTYPE
                                   , C_OPENNETNO
                                   , C_ACCOSOURCE
                                   , C_LONGTMACCOFLAG
                                   , C_AGCCUSTNO
                                   , C_ICSECONDACCO
                                   , C_FOREIGN
                                FROM ${hszta_src_schema}.TCUSTINFO"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CUSTNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_ACCOUNTTYPE", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_CUSTNAME", "type": "STRING"}, {"name": "C_SHORTNAME", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "C_IDENTITYNO", "type": "STRING"}, {"name": "D_IDNOVALIDDATE", "type": "STRING"}, {"name": "C_IDCARD18LEN", "type": "STRING"}, {"name": "D_OPENDATE", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "C_ACCOSTATUS", "type": "STRING"}, {"name": "L_CHANGETIME", "type": "DOUBLE"}, {"name": "C_ZIPCODE", "type": "STRING"}, {"name": "C_ADDRESS", "type": "STRING"}, {"name": "C_PHONE", "type": "STRING"}, {"name": "C_FAXNO", "type": "STRING"}, {"name": "C_MOBILENO", "type": "STRING"}, {"name": "C_EMAIL", "type": "STRING"}, {"name": "C_SEX", "type": "STRING"}, {"name": "C_BIRTHDAY", "type": "STRING"}, {"name": "C_VOCATION", "type": "STRING"}, {"name": "C_EDUCATION", "type": "STRING"}, {"name": "C_INCOME", "type": "STRING"}, {"name": "C_CORPNAME", "type": "STRING"}, {"name": "C_CORPTEL", "type": "STRING"}, {"name": "C_CONTACT", "type": "STRING"}, {"name": "C_CONTYPE", "type": "STRING"}, {"name": "C_CONTNO", "type": "STRING"}, {"name": "C_CONIDCARD18LEN", "type": "STRING"}, {"name": "C_BILLSENDFLAG", "type": "STRING"}, {"name": "C_CALLCENTER", "type": "STRING"}, {"name": "C_INTERNET", "type": "STRING"}, {"name": "C_BILLSENDPASS", "type": "STRING"}, {"name": "C_NATIONALITY", "type": "STRING"}, {"name": "C_LAWNAME", "type": "STRING"}, {"name": "C_LAWIDTYPE", "type": "STRING"}, {"name": "C_LAWIDNO", "type": "STRING"}, {"name": "C_BROKER", "type": "STRING"}, {"name": "C_RECOMMENDER", "type": "STRING"}, {"name": "C_RECOMMENDERTYPE", "type": "STRING"}, {"name": "C_CITYNO", "type": "STRING"}, {"name": "C_MODIFYINFO", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "C_SPECIALCODE", "type": "STRING"}, {"name": "C_BACKREASON", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_SYSROLE", "type": "STRING"}, {"name": "C_INSTREPRIDCODE", "type": "STRING"}, {"name": "C_INSTREPRIDTYPE", "type": "STRING"}, {"name": "C_HOMETELNO", "type": "STRING"}, {"name": "C_SHACCO", "type": "STRING"}, {"name": "C_SZACCO", "type": "STRING"}, {"name": "C_MINORFLAG", "type": "STRING"}, {"name": "C_TRANSACTTYPE", "type": "STRING"}, {"name": "D_CONTIDNOVALIDDATE", "type": "STRING"}, {"name": "D_LAWIDNOVALIDDATE", "type": "STRING"}, {"name": "C_RISKLEVEL", "type": "STRING"}, {"name": "C_MANAGERANGE", "type": "STRING"}, {"name": "C_CONTROLHOLDER", "type": "STRING"}, {"name": "C_ACTUALCONTROLLER", "type": "STRING"}, {"name": "C_MARITAL", "type": "STRING"}, {"name": "L_FAMILYNUM", "type": "DOUBLE"}, {"name": "F_PENATES", "type": "DOUBLE"}, {"name": "C_MEDIAHOBBY", "type": "STRING"}, {"name": "C_INSTITUTIONTYPE", "type": "STRING"}, {"name": "C_ENGLISHFIRSTNAME", "type": "STRING"}, {"name": "C_ENGLISHFAMLIYNAME", "type": "STRING"}, {"name": "C_INDUSTRY", "type": "STRING"}, {"name": "C_COMPANYCHAR", "type": "STRING"}, {"name": "F_EMPLOYEENUM", "type": "DOUBLE"}, {"name": "C_INTERESTTYPE", "type": "STRING"}, {"name": "C_PROVINCE", "type": "STRING"}, {"name": "C_CITY", "type": "STRING"}, {"name": "C_COUNTY", "type": "STRING"}, {"name": "L_MODCUSTNAMECOUNT", "type": "DOUBLE"}, {"name": "D_CLOSEDATE", "type": "STRING"}, {"name": "C_OPENAGENCYNO", "type": "STRING"}, {"name": "C_MANAGERREGISCODE", "type": "STRING"}, {"name": "C_ACCOUNTCARDID", "type": "STRING"}, {"name": "C_TRADEVOLUME", "type": "STRING"}, {"name": "C_TRADEFREQUENCY", "type": "STRING"}, {"name": "C_ANNUITYCOMBCODE", "type": "STRING"}, {"name": "C_INVESTORPROCODE", "type": "STRING"}, {"name": "C_AUXCERTTYPE", "type": "STRING"}, {"name": "C_AUXCERTCODE", "type": "STRING"}, {"name": "D_AUXCERTVALIDDATE", "type": "STRING"}, {"name": "D_X1IDNOVALIDDATE", "type": "STRING"}, {"name": "C_MODIFYINFOIDTYPE", "type": "STRING"}, {"name": "C_OPENNETNO", "type": "STRING"}, {"name": "C_ACCOSOURCE", "type": "STRING"}, {"name": "C_LONGTMACCOFLAG", "type": "STRING"}, {"name": "C_AGCCUSTNO", "type": "STRING"}, {"name": "C_ICSECONDACCO", "type": "STRING"}, {"name": "C_FOREIGN", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tcustinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tcustinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tcustinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tcustinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TCUSTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TCUSTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tcustinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_CUSTNO
     , C_FUNDACCO
     , C_ACCOUNTTYPE
     , C_CUSTTYPE
     , C_CUSTNAME
     , C_SHORTNAME
     , C_IDENTITYTYPE
     , C_IDENTITYNO
     , D_IDNOVALIDDATE
     , C_IDCARD18LEN
     , D_OPENDATE
     , D_LASTMODIFY
     , C_ACCOSTATUS
     , L_CHANGETIME
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
     , C_CORPNAME
     , C_CORPTEL
     , C_CONTACT
     , C_CONTYPE
     , C_CONTNO
     , C_CONIDCARD18LEN
     , C_BILLSENDFLAG
     , C_CALLCENTER
     , C_INTERNET
     , C_BILLSENDPASS
     , C_NATIONALITY
     , C_LAWNAME
     , C_LAWIDTYPE
     , C_LAWIDNO
     , C_BROKER
     , C_RECOMMENDER
     , C_RECOMMENDERTYPE
     , C_CITYNO
     , C_MODIFYINFO
     , C_FREEZECAUSE
     , C_SPECIALCODE
     , C_BACKREASON
     , C_BOURSEFLAG
     , C_SYSROLE
     , C_INSTREPRIDCODE
     , C_INSTREPRIDTYPE
     , C_HOMETELNO
     , C_SHACCO
     , C_SZACCO
     , C_MINORFLAG
     , C_TRANSACTTYPE
     , D_CONTIDNOVALIDDATE
     , D_LAWIDNOVALIDDATE
     , C_RISKLEVEL
     , C_MANAGERANGE
     , C_CONTROLHOLDER
     , C_ACTUALCONTROLLER
     , C_MARITAL
     , L_FAMILYNUM
     , F_PENATES
     , C_MEDIAHOBBY
     , C_INSTITUTIONTYPE
     , C_ENGLISHFIRSTNAME
     , C_ENGLISHFAMLIYNAME
     , C_INDUSTRY
     , C_COMPANYCHAR
     , F_EMPLOYEENUM
     , C_INTERESTTYPE
     , C_PROVINCE
     , C_CITY
     , C_COUNTY
     , L_MODCUSTNAMECOUNT
     , D_CLOSEDATE
     , C_OPENAGENCYNO
     , C_MANAGERREGISCODE
     , C_ACCOUNTCARDID
     , C_TRADEVOLUME
     , C_TRADEFREQUENCY
     , C_ANNUITYCOMBCODE
     , C_INVESTORPROCODE
     , C_AUXCERTTYPE
     , C_AUXCERTCODE
     , D_AUXCERTVALIDDATE
     , D_X1IDNOVALIDDATE
     , C_MODIFYINFOIDTYPE
     , C_OPENNETNO
     , C_ACCOSOURCE
     , C_LONGTMACCOFLAG
     , C_AGCCUSTNO
     , C_ICSECONDACCO
     , C_FOREIGN
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCUSTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TCUSTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TCUSTINFO_PFD成功"
      exit 0
   fi
fi
