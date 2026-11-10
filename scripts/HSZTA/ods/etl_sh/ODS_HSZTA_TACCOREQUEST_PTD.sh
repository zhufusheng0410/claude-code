#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TACCOREQUEST_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TACCOREQUEST_PTD_TMP(
  C_BUSINFLAG  STRING  COMMENT  '业务代码',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  D_REQUESTDATE  STRING  COMMENT  '申请日期',
  D_REQUESTTIME  STRING  COMMENT  '申请时间',
  C_REQUESTNO  STRING  COMMENT  '申请编号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_CUSTNAME  STRING  COMMENT  '客户全称',
  C_SHORTNAME  STRING  COMMENT  '客户简称',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_IDENTITYTYPE  STRING  COMMENT  '客户证件类型',
  C_IDENTITYNO  STRING  COMMENT  '客户证件号码',
  D_IDNOVALIDDATE  STRING  COMMENT  '',
  C_IDCARD18LEN  STRING  COMMENT  '身份证18位标志',
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
  C_CONIDCARD18LEN  STRING  COMMENT  '是否18位卡号',
  C_BILLSENDFLAG  STRING  COMMENT  '对帐单寄送方式',
  C_CALLCENTER  STRING  COMMENT  '开通CallCenter标志',
  C_INTERNET  STRING  COMMENT  '开通网上交易标志',
  C_ACCEPTMODE  STRING  COMMENT  '交易方式',
  C_BILLSENDPASS  STRING  COMMENT  '对帐单寄送途径',
  C_NATIONALITY  STRING  COMMENT  '国籍',
  C_LAWNAME  STRING  COMMENT  '法人姓名',
  C_LAWIDTYPE  STRING  COMMENT  '法人类型',
  C_LAWIDNO  STRING  COMMENT  '法人编号',
  C_BANKNO  STRING  COMMENT  '交收行名称',
  C_BANKACCO  STRING  COMMENT  '交收行账号',
  C_NAMEINBANK  STRING  COMMENT  '交收行户名',
  C_ACCOUNTTYPE  STRING  COMMENT  '账户类型',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_BROKER  STRING  COMMENT  '经纪人',
  C_RECOMMENDER  STRING  COMMENT  '推荐人',
  C_RECOMMENDERTYPE  STRING  COMMENT  '推荐类型',
  C_FREEZECAUSE  STRING  COMMENT  '冻结原因',
  C_LAWFILENO  STRING  COMMENT  '法律文件编号',
  D_BACKDATE  STRING  COMMENT  '有效截止日期',
  C_ORIREQUESTNO  STRING  COMMENT  '原申请编号',
  C_CHILDNETNO  STRING  COMMENT  '操作网点编号',
  C_CITYNO  STRING  COMMENT  '城市编号(地区)',
  C_OUTBUSINFLAG  STRING  COMMENT  '外部业务标志',
  C_REQTRADEACCO  STRING  COMMENT  '',
  C_ORITRADEACCO  STRING  COMMENT  '',
  C_SPECIALCODE  STRING  COMMENT  '特殊代码',
  C_TRADEMETHOD  STRING  COMMENT  '',
  C_DELIVERWAY  STRING  COMMENT  '',
  C_TAFLAG  STRING  COMMENT  'TA发起标志',
  C_AUDITFLAG  STRING  COMMENT  '复核标志',
  C_OPERATOR  STRING  COMMENT  '操作员',
  C_IMPORTFLAG  STRING  COMMENT  '',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  C_STATUS  STRING  COMMENT  '确认结果',
  C_NODEALFLAG  STRING  COMMENT  '不用处理标志',
  C_CAUSE_OPEN  STRING  COMMENT  '错误代码',
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
  C_BANKNAME  STRING  COMMENT  '开卡银行名称',
  C_BRANCHBANK  STRING  COMMENT  '',
  C_BANKPROVINCE  STRING  COMMENT  '',
  C_BANKCITYNO  STRING  COMMENT  '',
  C_BOURSENO  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '备注',
  D_FACTDATE  STRING  COMMENT  '',
  C_MANAGERREGISCODE  STRING  COMMENT  '',
  C_WECHATREQUESTNO  STRING  COMMENT  '',
  C_ACCOUNTCARDID  STRING  COMMENT  '',
  C_IMPAGENCYNO  STRING  COMMENT  '',
  F_T0FAILSHARES  DECIMAL(16,2)  COMMENT  '',
  C_VIRTUALTACODE  STRING  COMMENT  '',
  C_ACCTNOOFFMINCLEARINGAGENCY  STRING  COMMENT  '',
  C_ORIGINALSERIALNO  STRING  COMMENT  '',
  C_MULTIACCTFLAG  STRING  COMMENT  '',
  C_BLACKLEVEL  STRING  COMMENT  '',
  C_INVESTORPROCODE  STRING  COMMENT  '',
  C_AUXCERTTYPE  STRING  COMMENT  '',
  C_AUXCERTCODE  STRING  COMMENT  '',
  D_AUXCERTVALIDDATE  STRING  COMMENT  '',
  C_IPADDRESS  STRING  COMMENT  '',
  C_MACADDRESS  STRING  COMMENT  '',
  C_IMEI  STRING  COMMENT  '',
  C_UUID  STRING  COMMENT  '',
  C_CAUSE_CIE  STRING  COMMENT  '',
  C_ERRORMSG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  C_TADEREGAGCALLDATA  STRING  COMMENT  '',
  C_SUBAGENCYNO  STRING  COMMENT  ''
)
COMMENT '账户申请确认表'
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
              "querySql": ["SELECT  C_BUSINFLAG
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , D_REQUESTDATE
                                   , D_REQUESTTIME
                                   , C_REQUESTNO
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_CUSTNAME
                                   , C_SHORTNAME
                                   , C_CUSTTYPE
                                   , C_IDENTITYTYPE
                                   , C_IDENTITYNO
                                   , D_IDNOVALIDDATE
                                   , C_IDCARD18LEN
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
                                   , C_ACCEPTMODE
                                   , C_BILLSENDPASS
                                   , C_NATIONALITY
                                   , C_LAWNAME
                                   , C_LAWIDTYPE
                                   , C_LAWIDNO
                                   , C_BANKNO
                                   , C_BANKACCO
                                   , C_NAMEINBANK
                                   , C_ACCOUNTTYPE
                                   , C_BONUSTYPE
                                   , C_BROKER
                                   , C_RECOMMENDER
                                   , C_RECOMMENDERTYPE
                                   , C_FREEZECAUSE
                                   , C_LAWFILENO
                                   , D_BACKDATE
                                   , C_ORIREQUESTNO
                                   , C_CHILDNETNO
                                   , C_CITYNO
                                   , C_OUTBUSINFLAG
                                   , C_REQTRADEACCO
                                   , C_ORITRADEACCO
                                   , C_SPECIALCODE
                                   , C_TRADEMETHOD
                                   , C_DELIVERWAY
                                   , C_TAFLAG
                                   , C_AUDITFLAG
                                   , C_OPERATOR
                                   , C_IMPORTFLAG
                                   , C_CSERIALNO
                                   , C_STATUS
                                   , C_NODEALFLAG
                                   , C_CAUSE_OPEN
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
                                   , C_BANKNAME
                                   , C_BRANCHBANK
                                   , C_BANKPROVINCE
                                   , C_BANKCITYNO
                                   , C_BOURSENO
                                   , C_MEMO
                                   , D_FACTDATE
                                   , C_MANAGERREGISCODE
                                   , C_WECHATREQUESTNO
                                   , C_ACCOUNTCARDID
                                   , C_IMPAGENCYNO
                                   , F_T0FAILSHARES
                                   , C_VIRTUALTACODE
                                   , C_ACCTNOOFFMINCLEARINGAGENCY
                                   , C_ORIGINALSERIALNO
                                   , C_MULTIACCTFLAG
                                   , C_BLACKLEVEL
                                   , C_INVESTORPROCODE
                                   , C_AUXCERTTYPE
                                   , C_AUXCERTCODE
                                   , D_AUXCERTVALIDDATE
                                   , C_IPADDRESS
                                   , C_MACADDRESS
                                   , C_IMEI
                                   , C_UUID
                                   , C_CAUSE_CIE
                                   , C_ERRORMSG
                                   , C_PARTNERID
                                   , C_TADEREGAGCALLDATA
                                   , C_SUBAGENCYNO
                                FROM ${hszta_src_schema}.TACCOREQUEST
                                WHERE D_REQUESTDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "D_REQUESTDATE", "type": "STRING"}, {"name": "D_REQUESTTIME", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_CUSTNAME", "type": "STRING"}, {"name": "C_SHORTNAME", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "C_IDENTITYNO", "type": "STRING"}, {"name": "D_IDNOVALIDDATE", "type": "STRING"}, {"name": "C_IDCARD18LEN", "type": "STRING"}, {"name": "C_ZIPCODE", "type": "STRING"}, {"name": "C_ADDRESS", "type": "STRING"}, {"name": "C_PHONE", "type": "STRING"}, {"name": "C_FAXNO", "type": "STRING"}, {"name": "C_MOBILENO", "type": "STRING"}, {"name": "C_EMAIL", "type": "STRING"}, {"name": "C_SEX", "type": "STRING"}, {"name": "C_BIRTHDAY", "type": "STRING"}, {"name": "C_VOCATION", "type": "STRING"}, {"name": "C_EDUCATION", "type": "STRING"}, {"name": "C_INCOME", "type": "STRING"}, {"name": "C_CORPNAME", "type": "STRING"}, {"name": "C_CORPTEL", "type": "STRING"}, {"name": "C_CONTACT", "type": "STRING"}, {"name": "C_CONTYPE", "type": "STRING"}, {"name": "C_CONTNO", "type": "STRING"}, {"name": "C_CONIDCARD18LEN", "type": "STRING"}, {"name": "C_BILLSENDFLAG", "type": "STRING"}, {"name": "C_CALLCENTER", "type": "STRING"}, {"name": "C_INTERNET", "type": "STRING"}, {"name": "C_ACCEPTMODE", "type": "STRING"}, {"name": "C_BILLSENDPASS", "type": "STRING"}, {"name": "C_NATIONALITY", "type": "STRING"}, {"name": "C_LAWNAME", "type": "STRING"}, {"name": "C_LAWIDTYPE", "type": "STRING"}, {"name": "C_LAWIDNO", "type": "STRING"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_BANKACCO", "type": "STRING"}, {"name": "C_NAMEINBANK", "type": "STRING"}, {"name": "C_ACCOUNTTYPE", "type": "STRING"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_BROKER", "type": "STRING"}, {"name": "C_RECOMMENDER", "type": "STRING"}, {"name": "C_RECOMMENDERTYPE", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "C_LAWFILENO", "type": "STRING"}, {"name": "D_BACKDATE", "type": "STRING"}, {"name": "C_ORIREQUESTNO", "type": "STRING"}, {"name": "C_CHILDNETNO", "type": "STRING"}, {"name": "C_CITYNO", "type": "STRING"}, {"name": "C_OUTBUSINFLAG", "type": "STRING"}, {"name": "C_REQTRADEACCO", "type": "STRING"}, {"name": "C_ORITRADEACCO", "type": "STRING"}, {"name": "C_SPECIALCODE", "type": "STRING"}, {"name": "C_TRADEMETHOD", "type": "STRING"}, {"name": "C_DELIVERWAY", "type": "STRING"}, {"name": "C_TAFLAG", "type": "STRING"}, {"name": "C_AUDITFLAG", "type": "STRING"}, {"name": "C_OPERATOR", "type": "STRING"}, {"name": "C_IMPORTFLAG", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_NODEALFLAG", "type": "STRING"}, {"name": "C_CAUSE_OPEN", "type": "STRING"}, {"name": "C_SYSROLE", "type": "STRING"}, {"name": "C_INSTREPRIDCODE", "type": "STRING"}, {"name": "C_INSTREPRIDTYPE", "type": "STRING"}, {"name": "C_HOMETELNO", "type": "STRING"}, {"name": "C_SHACCO", "type": "STRING"}, {"name": "C_SZACCO", "type": "STRING"}, {"name": "C_MINORFLAG", "type": "STRING"}, {"name": "C_TRANSACTTYPE", "type": "STRING"}, {"name": "D_CONTIDNOVALIDDATE", "type": "STRING"}, {"name": "D_LAWIDNOVALIDDATE", "type": "STRING"}, {"name": "C_RISKLEVEL", "type": "STRING"}, {"name": "C_MANAGERANGE", "type": "STRING"}, {"name": "C_CONTROLHOLDER", "type": "STRING"}, {"name": "C_ACTUALCONTROLLER", "type": "STRING"}, {"name": "C_MARITAL", "type": "STRING"}, {"name": "L_FAMILYNUM", "type": "DOUBLE"}, {"name": "F_PENATES", "type": "DOUBLE"}, {"name": "C_MEDIAHOBBY", "type": "STRING"}, {"name": "C_INSTITUTIONTYPE", "type": "STRING"}, {"name": "C_ENGLISHFIRSTNAME", "type": "STRING"}, {"name": "C_ENGLISHFAMLIYNAME", "type": "STRING"}, {"name": "C_INDUSTRY", "type": "STRING"}, {"name": "C_COMPANYCHAR", "type": "STRING"}, {"name": "F_EMPLOYEENUM", "type": "DOUBLE"}, {"name": "C_INTERESTTYPE", "type": "STRING"}, {"name": "C_PROVINCE", "type": "STRING"}, {"name": "C_CITY", "type": "STRING"}, {"name": "C_COUNTY", "type": "STRING"}, {"name": "C_BANKNAME", "type": "STRING"}, {"name": "C_BRANCHBANK", "type": "STRING"}, {"name": "C_BANKPROVINCE", "type": "STRING"}, {"name": "C_BANKCITYNO", "type": "STRING"}, {"name": "C_BOURSENO", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "D_FACTDATE", "type": "STRING"}, {"name": "C_MANAGERREGISCODE", "type": "STRING"}, {"name": "C_WECHATREQUESTNO", "type": "STRING"}, {"name": "C_ACCOUNTCARDID", "type": "STRING"}, {"name": "C_IMPAGENCYNO", "type": "STRING"}, {"name": "F_T0FAILSHARES", "type": "DOUBLE"}, {"name": "C_VIRTUALTACODE", "type": "STRING"}, {"name": "C_ACCTNOOFFMINCLEARINGAGENCY", "type": "STRING"}, {"name": "C_ORIGINALSERIALNO", "type": "STRING"}, {"name": "C_MULTIACCTFLAG", "type": "STRING"}, {"name": "C_BLACKLEVEL", "type": "STRING"}, {"name": "C_INVESTORPROCODE", "type": "STRING"}, {"name": "C_AUXCERTTYPE", "type": "STRING"}, {"name": "C_AUXCERTCODE", "type": "STRING"}, {"name": "D_AUXCERTVALIDDATE", "type": "STRING"}, {"name": "C_IPADDRESS", "type": "STRING"}, {"name": "C_MACADDRESS", "type": "STRING"}, {"name": "C_IMEI", "type": "STRING"}, {"name": "C_UUID", "type": "STRING"}, {"name": "C_CAUSE_CIE", "type": "STRING"}, {"name": "C_ERRORMSG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_TADEREGAGCALLDATA", "type": "STRING"}, {"name": "C_SUBAGENCYNO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_taccorequest_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_taccorequest_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_taccorequest_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_taccorequest_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TACCOREQUEST_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TACCOREQUEST_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_taccorequest_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TACCOREQUEST_PTD PARTITION(P_DT)
SELECT
       C_BUSINFLAG
     , C_AGENCYNO
     , C_NETNO
     , D_REQUESTDATE
     , D_REQUESTTIME
     , C_REQUESTNO
     , C_FUNDACCO
     , C_TRADEACCO
     , C_CUSTNAME
     , C_SHORTNAME
     , C_CUSTTYPE
     , C_IDENTITYTYPE
     , C_IDENTITYNO
     , D_IDNOVALIDDATE
     , C_IDCARD18LEN
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
     , C_ACCEPTMODE
     , C_BILLSENDPASS
     , C_NATIONALITY
     , C_LAWNAME
     , C_LAWIDTYPE
     , C_LAWIDNO
     , C_BANKNO
     , C_BANKACCO
     , C_NAMEINBANK
     , C_ACCOUNTTYPE
     , C_BONUSTYPE
     , C_BROKER
     , C_RECOMMENDER
     , C_RECOMMENDERTYPE
     , C_FREEZECAUSE
     , C_LAWFILENO
     , D_BACKDATE
     , C_ORIREQUESTNO
     , C_CHILDNETNO
     , C_CITYNO
     , C_OUTBUSINFLAG
     , C_REQTRADEACCO
     , C_ORITRADEACCO
     , C_SPECIALCODE
     , C_TRADEMETHOD
     , C_DELIVERWAY
     , C_TAFLAG
     , C_AUDITFLAG
     , C_OPERATOR
     , C_IMPORTFLAG
     , C_CSERIALNO
     , C_STATUS
     , C_NODEALFLAG
     , C_CAUSE_OPEN
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
     , C_BANKNAME
     , C_BRANCHBANK
     , C_BANKPROVINCE
     , C_BANKCITYNO
     , C_BOURSENO
     , C_MEMO
     , D_FACTDATE
     , C_MANAGERREGISCODE
     , C_WECHATREQUESTNO
     , C_ACCOUNTCARDID
     , C_IMPAGENCYNO
     , F_T0FAILSHARES
     , C_VIRTUALTACODE
     , C_ACCTNOOFFMINCLEARINGAGENCY
     , C_ORIGINALSERIALNO
     , C_MULTIACCTFLAG
     , C_BLACKLEVEL
     , C_INVESTORPROCODE
     , C_AUXCERTTYPE
     , C_AUXCERTCODE
     , D_AUXCERTVALIDDATE
     , C_IPADDRESS
     , C_MACADDRESS
     , C_IMEI
     , C_UUID
     , C_CAUSE_CIE
     , C_ERRORMSG
     , C_PARTNERID
     , C_TADEREGAGCALLDATA
     , C_SUBAGENCYNO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_REQUESTDATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TACCOREQUEST_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TACCOREQUEST_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TACCOREQUEST_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TACCOREQUEST_PTD成功"
      exit 0
   fi
fi
