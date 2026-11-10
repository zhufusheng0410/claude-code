#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TACCOINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TACCOINFO_PFD_TMP(
  VC_CUSTNO  STRING  COMMENT  '客户编号',
  VC_TRADEACCO  STRING  COMMENT  '交易账号',
  C_CUSTTYPE  STRING  COMMENT  '客户类别',
  VC_ACCONAME  STRING  COMMENT  '交易账户名称',
  C_MAINFLAG  STRING  COMMENT  '主账号标识',
  VC_ACCOCARD  STRING  COMMENT  '卡号',
  VC_PHONE  STRING  COMMENT  '联系电话',
  VC_CONTACT  STRING  COMMENT  '经办人姓名',
  C_CONTTYPE  STRING  COMMENT  '经办人证件类型',
  VC_CONTNO  STRING  COMMENT  '经办人证件号码',
  VC_CONTPHONE  STRING  COMMENT  '经办人联系电话',
  C_BILLWAY  STRING  COMMENT  '对帐单寄送方式',
  VC_ADDRESS  STRING  COMMENT  '通讯地址',
  VC_ZIP  STRING  COMMENT  '邮编',
  VC_MOBILENO  STRING  COMMENT  '手机',
  VC_PAGENO  STRING  COMMENT  '传呼',
  VC_FAXNO  STRING  COMMENT  '传真',
  VC_EMAIL  STRING  COMMENT  '电子信箱',
  C_CALLCENTER  STRING  COMMENT  '电话委托',
  C_INTERNET  STRING  COMMENT  '网上委托',
  C_SELFHELP  STRING  COMMENT  '自助委托',
  C_FAXTRUST  STRING  COMMENT  '传真委托',
  C_BROKERTRUST  STRING  COMMENT  '经纪人委托',
  C_OTHERTRUST  STRING  COMMENT  '其他委托',
  VC_DEALPWD  STRING  COMMENT  '交易密码',
  VC_QUERYPWD  STRING  COMMENT  '查询密码',
  VC_CIPHERTEXT  STRING  COMMENT  '密函编号',
  C_DIVIDENDMETHOD  STRING  COMMENT  '分红方式',
  VC_OPENDATE  STRING  COMMENT  '开户日期',
  VC_NETNO  STRING  COMMENT  '开户网点',
  L_PASSWDERR  DECIMAL(2,0)  COMMENT  '密码错误次数',
  C_CAPITALMODE  STRING  COMMENT  '资金方式',
  C_STATE  STRING  COMMENT  '状态',
  VC_BROKER  STRING  COMMENT  '经纪人',
  EN_DISCOUNT  DECIMAL(5,4)  COMMENT  '折扣率',
  VC_LASTDATE  STRING  COMMENT  '最后修改日期',
  L_REALLOTNUM  DECIMAL(2,0)  COMMENT  '重新再投资次数',
  C_AUTOFLAG  STRING  COMMENT  '自动划款标志',
  VC_CENTERNO  STRING  COMMENT  '开户分中心',
  VC_CITYNO  STRING  COMMENT  '开户城市',
  VC_SELLER  STRING  COMMENT  '业务员',
  VC_SPELL  STRING  COMMENT  '拼音缩写',
  VC_CDCARD  STRING  COMMENT  '银联卡',
  C_BILLPATH  STRING  COMMENT  '对账单寄送途径',
  D_ERRDATE  STRING  COMMENT  '锁定日期',
  C_USERTYPE  STRING  COMMENT  '用户类型',
  C_TRUENAMEFLAG  STRING  COMMENT  '客户实名状态',
  VC_SPECIAL  STRING  COMMENT  '特殊代码',
  VC_OFFICE  STRING  COMMENT  '工作单位名称',
  VC_OFFICETEL  STRING  COMMENT  '工作单位电话',
  C_CUSTKIND  STRING  COMMENT  '客户分类',
  EN_YEARRATE  DECIMAL(5,4)  COMMENT  '年利率',
  C_RATEGROUP  STRING  COMMENT  '利率类别',
  VC_EXPLAIN  STRING  COMMENT  '备注',
  C_NEEDACTIVE  STRING  COMMENT  '激活状态',
  VC_TRADECONTACT  STRING  COMMENT  '交易经办人',
  C_PROVINCECODE  STRING  COMMENT  '省份代码',
  VC_COUNTYNO  STRING  COMMENT  '县区代码',
  C_MOBILE  STRING  COMMENT  '手机委托',
  VC_CONTVALIDATE  STRING  COMMENT  '经办人证件有效期',
  VC_RECIPIENTSTYPE  STRING  COMMENT  '账单收件人证件类型',
  VC_RECIPIENTSNO  STRING  COMMENT  '账单收件人证件号码',
  VC_RECIPIENTSVALIDATE  STRING  COMMENT  '账单收件人证件有效期',
  C_PRINCIPALTYPE  STRING  COMMENT  '负责人证件类型',
  VC_PRINCIPALNO  STRING  COMMENT  '负责人证件号码',
  VC_PRINCIPALVALIDATE  STRING  COMMENT  '负责人证件有效期',
  VC_RECOMMENDER  STRING  COMMENT  '推荐人',
  VC_RECIPIENTSNAME  STRING  COMMENT  '账单收件人姓名',
  VC_PRINCIPALNAME  STRING  COMMENT  '负责人姓名',
  VC_BENEFICIARY  STRING  COMMENT  '账户实际受益人',
  VC_BUSINESSRANGE  STRING  COMMENT  '经营范围',
  C_ISTRUSTFLAG  STRING  COMMENT  '是否信托资产',
  VC_TRUSTCLIENT  STRING  COMMENT  '信托委托人名称',
  VC_TRUSTPHONE  STRING  COMMENT  '信托委托人联系电话',
  C_RECOMMENDERTYPE  STRING  COMMENT  '推荐人类型',
  C_TRUSTTYPE  STRING  COMMENT  '委托人证件类型',
  VC_TRUSTNO  STRING  COMMENT  '委托人证件号码',
  VC_TRUSTCONTACT  STRING  COMMENT  '委托经办人',
  VC_TRUSTADDRESS  STRING  COMMENT  '委托人地址',
  VC_TRUSTFAXNO  STRING  COMMENT  '委托人传真',
  C_ISANNUITYFLAG  STRING  COMMENT  '',
  C_ISSOCIALFLAG  STRING  COMMENT  '',
  VC_TRADEPURPOSE  STRING  COMMENT  '',
  VC_CONTADDRESS  STRING  COMMENT  '',
  VC_CONTZIP  STRING  COMMENT  '',
  VC_CONTEXPLAIN  STRING  COMMENT  '',
  C_CONTRIGHT  STRING  COMMENT  '',
  VC_CONTRELATION  STRING  COMMENT  '',
  VC_LOCATIONZIP  STRING  COMMENT  '',
  VC_MSGSENDTYPE  STRING  COMMENT  '',
  C_REMINDFLAG  STRING  COMMENT  '',
  VC_LASTPASSWDDATE  STRING  COMMENT  '',
  VC_CONTWARRANTVALIDATE  STRING  COMMENT  '',
  VC_CONTEMAIL  STRING  COMMENT  '',
  VC_RECOMMENDERPHONE  STRING  COMMENT  '',
  VC_RECOMMENDERPROVINCE  STRING  COMMENT  '',
  VC_RECOMMENDERCITYNO  STRING  COMMENT  '',
  VC_CONTMOBILENO  STRING  COMMENT  '',
  C_PREUSERFLAG  STRING  COMMENT  '',
  C_CONTIDENTIFICATIONMODE  STRING  COMMENT  '',
  VC_SOURCETRADEACCO  STRING  COMMENT  '',
  VC_ACCOUSAGE  STRING  COMMENT  '',
  L_RESTRICTEDPERIOD  DECIMAL(3,0)  COMMENT  '',
  VC_LINKMAN  STRING  COMMENT  '',
  VC_BANKIDNO  STRING  COMMENT  '',
  VC_PRINCIPALTELNO  STRING  COMMENT  '',
  VC_COMEFROM  STRING  COMMENT  '',
  VC_LONGCDCARD  STRING  COMMENT  '',
  EN_CHECKBALANCE  DECIMAL(16,2)  COMMENT  '',
  VC_OTHERUSERID  STRING  COMMENT  '',
  VC_PARTNERID  STRING  COMMENT  '',
  C_LONGBILLPATH  STRING  COMMENT  '',
  VC_MANAGERCODE  STRING  COMMENT  '',
  VC_RECOMMENDEROFFICE  STRING  COMMENT  '',
  VC_CUSTADDNAME  STRING  COMMENT  '',
  EN_REMAINBALA  DECIMAL(16,2)  COMMENT  '',
  VC_REMAINFUNDCODE  STRING  COMMENT  '',
  VC_TRADECOMEFROM  STRING  COMMENT  '',
  VC_PERMANENTADDRESS  STRING  COMMENT  '',
  C_FATCATYPE  STRING  COMMENT  '',
  C_FATCAINDUSTRYTYPE  STRING  COMMENT  '',
  VC_TINNO  STRING  COMMENT  '',
  VC_EINGINNNO  STRING  COMMENT  '',
  VC_DUEDILIGENCEDATE  STRING  COMMENT  '',
  VC_NATIONALITY  STRING  COMMENT  '',
  VC_NOGIININST  STRING  COMMENT  '',
  VC_SPECIALACCO  STRING  COMMENT  '',
  C_GZBSIGNFLAG  STRING  COMMENT  '',
  C_CANMODIFYBANKINFO  STRING  COMMENT  '',
  C_MOBILEVALIDATEFLAG  STRING  COMMENT  '',
  VC_OLDTRADEACCO  STRING  COMMENT  '',
  C_BENEFICIARYIDTYPE  STRING  COMMENT  '',
  VC_BENEFICIARYIDNO  STRING  COMMENT  '',
  VC_BENEFICIARYIDVALIDATE  STRING  COMMENT  '',
  VC_BENEFICIARYCUSTTYPE  STRING  COMMENT  '',
  VC_PRODUCTID  STRING  COMMENT  '',
  C_AUTHORFLAG  STRING  COMMENT  '',
  VC_TOWNNO  STRING  COMMENT  '',
  VC_VILLAGENO  STRING  COMMENT  '',
  VC_ADDRESSDETAIL  STRING  COMMENT  '',
  VC_PORTFOLIOCODE  STRING  COMMENT  '',
  VC_LIVENATION  STRING  COMMENT  '',
  VC_OFFICENATION  STRING  COMMENT  '',
  VC_REGNATION  STRING  COMMENT  '',
  VC_PRINCIPALEMAIL  STRING  COMMENT  '',
  VC_INTRODEPT  STRING  COMMENT  '',
  VC_INTRODUCER  STRING  COMMENT  '',
  VC_BRANCHOFFICE  STRING  COMMENT  '',
  VC_BUSINDEPT  STRING  COMMENT  '',
  VC_BUSINDEPTINTRO  STRING  COMMENT  '',
  VC_ASSETSELEMENT  STRING  COMMENT  '',
  VC_PLATFORMNO  STRING  COMMENT  '',
  VC_BILLEMAILL  STRING  COMMENT  '',
  C_TRUSTCUSTTYPE  STRING  COMMENT  '',
  VC_LINKTRADEACCO  STRING  COMMENT  ''
)
COMMENT '交易账号信息表'
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
            "username": "${hsds_username}",
            "password": "${hsds_password}",
            "connection": [{
              "querySql": ["SELECT  VC_CUSTNO\n                                   , VC_TRADEACCO\n                                   , C_CUSTTYPE\n                                   , VC_ACCONAME\n                                   , C_MAINFLAG\n                                   , VC_ACCOCARD\n                                   , VC_PHONE\n                                   , VC_CONTACT\n                                   , C_CONTTYPE\n                                   , VC_CONTNO\n                                   , VC_CONTPHONE\n                                   , C_BILLWAY\n                                   , VC_ADDRESS\n                                   , VC_ZIP\n                                   , VC_MOBILENO\n                                   , VC_PAGENO\n                                   , VC_FAXNO\n                                   , VC_EMAIL\n                                   , C_CALLCENTER\n                                   , C_INTERNET\n                                   , C_SELFHELP\n                                   , C_FAXTRUST\n                                   , C_BROKERTRUST\n                                   , C_OTHERTRUST\n                                   , VC_DEALPWD\n                                   , VC_QUERYPWD\n                                   , VC_CIPHERTEXT\n                                   , C_DIVIDENDMETHOD\n                                   , VC_OPENDATE\n                                   , VC_NETNO\n                                   , L_PASSWDERR\n                                   , C_CAPITALMODE\n                                   , C_STATE\n                                   , VC_BROKER\n                                   , EN_DISCOUNT\n                                   , VC_LASTDATE\n                                   , L_REALLOTNUM\n                                   , C_AUTOFLAG\n                                   , VC_CENTERNO\n                                   , VC_CITYNO\n                                   , VC_SELLER\n                                   , VC_SPELL\n                                   , VC_CDCARD\n                                   , C_BILLPATH\n                                   , D_ERRDATE\n                                   , C_USERTYPE\n                                   , C_TRUENAMEFLAG\n                                   , VC_SPECIAL\n                                   , VC_OFFICE\n                                   , VC_OFFICETEL\n                                   , C_CUSTKIND\n                                   , EN_YEARRATE\n                                   , C_RATEGROUP\n                                   , VC_EXPLAIN\n                                   , C_NEEDACTIVE\n                                   , VC_TRADECONTACT\n                                   , C_PROVINCECODE\n                                   , VC_COUNTYNO\n                                   , C_MOBILE\n                                   , VC_CONTVALIDATE\n                                   , VC_RECIPIENTSTYPE\n                                   , VC_RECIPIENTSNO\n                                   , VC_RECIPIENTSVALIDATE\n                                   , C_PRINCIPALTYPE\n                                   , VC_PRINCIPALNO\n                                   , VC_PRINCIPALVALIDATE\n                                   , VC_RECOMMENDER\n                                   , VC_RECIPIENTSNAME\n                                   , VC_PRINCIPALNAME\n                                   , VC_BENEFICIARY\n                                   , VC_BUSINESSRANGE\n                                   , C_ISTRUSTFLAG\n                                   , VC_TRUSTCLIENT\n                                   , VC_TRUSTPHONE\n                                   , C_RECOMMENDERTYPE\n                                   , C_TRUSTTYPE\n                                   , VC_TRUSTNO\n                                   , VC_TRUSTCONTACT\n                                   , VC_TRUSTADDRESS\n                                   , VC_TRUSTFAXNO\n                                   , C_ISANNUITYFLAG\n                                   , C_ISSOCIALFLAG\n                                   , VC_TRADEPURPOSE\n                                   , VC_CONTADDRESS\n                                   , VC_CONTZIP\n                                   , VC_CONTEXPLAIN\n                                   , C_CONTRIGHT\n                                   , VC_CONTRELATION\n                                   , VC_LOCATIONZIP\n                                   , VC_MSGSENDTYPE\n                                   , C_REMINDFLAG\n                                   , VC_LASTPASSWDDATE\n                                   , VC_CONTWARRANTVALIDATE\n                                   , VC_CONTEMAIL\n                                   , VC_RECOMMENDERPHONE\n                                   , VC_RECOMMENDERPROVINCE\n                                   , VC_RECOMMENDERCITYNO\n                                   , VC_CONTMOBILENO\n                                   , C_PREUSERFLAG\n                                   , C_CONTIDENTIFICATIONMODE\n                                   , VC_SOURCETRADEACCO\n                                   , VC_ACCOUSAGE\n                                   , L_RESTRICTEDPERIOD\n                                   , VC_LINKMAN\n                                   , VC_BANKIDNO\n                                   , VC_PRINCIPALTELNO\n                                   , VC_COMEFROM\n                                   , VC_LONGCDCARD\n                                   , EN_CHECKBALANCE\n                                   , VC_OTHERUSERID\n                                   , VC_PARTNERID\n                                   , C_LONGBILLPATH\n                                   , VC_MANAGERCODE\n                                   , VC_RECOMMENDEROFFICE\n                                   , VC_CUSTADDNAME\n                                   , EN_REMAINBALA\n                                   , VC_REMAINFUNDCODE\n                                   , VC_TRADECOMEFROM\n                                   , VC_PERMANENTADDRESS\n                                   , C_FATCATYPE\n                                   , C_FATCAINDUSTRYTYPE\n                                   , VC_TINNO\n                                   , VC_EINGINNNO\n                                   , VC_DUEDILIGENCEDATE\n                                   , VC_NATIONALITY\n                                   , VC_NOGIININST\n                                   , VC_SPECIALACCO\n                                   , C_GZBSIGNFLAG\n                                   , C_CANMODIFYBANKINFO\n                                   , C_MOBILEVALIDATEFLAG\n                                   , VC_OLDTRADEACCO\n                                   , C_BENEFICIARYIDTYPE\n                                   , VC_BENEFICIARYIDNO\n                                   , VC_BENEFICIARYIDVALIDATE\n                                   , VC_BENEFICIARYCUSTTYPE\n                                   , VC_PRODUCTID\n                                   , C_AUTHORFLAG\n                                   , VC_TOWNNO\n                                   , VC_VILLAGENO\n                                   , VC_ADDRESSDETAIL\n                                   , VC_PORTFOLIOCODE\n                                   , VC_LIVENATION\n                                   , VC_OFFICENATION\n                                   , VC_REGNATION\n                                   , VC_PRINCIPALEMAIL\n                                   , VC_INTRODEPT\n                                   , VC_INTRODUCER\n                                   , VC_BRANCHOFFICE\n                                   , VC_BUSINDEPT\n                                   , VC_BUSINDEPTINTRO\n                                   , VC_ASSETSELEMENT\n                                   , VC_PLATFORMNO\n                                   , VC_BILLEMAILL\n                                   , C_TRUSTCUSTTYPE\n                                   , VC_LINKTRADEACCO\n                                FROM ${hsds_src_schema}.TACCOINFO"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_CUSTNO", "type": "STRING"}, {"name": "VC_TRADEACCO", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "VC_ACCONAME", "type": "STRING"}, {"name": "C_MAINFLAG", "type": "STRING"}, {"name": "VC_ACCOCARD", "type": "STRING"}, {"name": "VC_PHONE", "type": "STRING"}, {"name": "VC_CONTACT", "type": "STRING"}, {"name": "C_CONTTYPE", "type": "STRING"}, {"name": "VC_CONTNO", "type": "STRING"}, {"name": "VC_CONTPHONE", "type": "STRING"}, {"name": "C_BILLWAY", "type": "STRING"}, {"name": "VC_ADDRESS", "type": "STRING"}, {"name": "VC_ZIP", "type": "STRING"}, {"name": "VC_MOBILENO", "type": "STRING"}, {"name": "VC_PAGENO", "type": "STRING"}, {"name": "VC_FAXNO", "type": "STRING"}, {"name": "VC_EMAIL", "type": "STRING"}, {"name": "C_CALLCENTER", "type": "STRING"}, {"name": "C_INTERNET", "type": "STRING"}, {"name": "C_SELFHELP", "type": "STRING"}, {"name": "C_FAXTRUST", "type": "STRING"}, {"name": "C_BROKERTRUST", "type": "STRING"}, {"name": "C_OTHERTRUST", "type": "STRING"}, {"name": "VC_DEALPWD", "type": "STRING"}, {"name": "VC_QUERYPWD", "type": "STRING"}, {"name": "VC_CIPHERTEXT", "type": "STRING"}, {"name": "C_DIVIDENDMETHOD", "type": "STRING"}, {"name": "VC_OPENDATE", "type": "STRING"}, {"name": "VC_NETNO", "type": "STRING"}, {"name": "L_PASSWDERR", "type": "DOUBLE"}, {"name": "C_CAPITALMODE", "type": "STRING"}, {"name": "C_STATE", "type": "STRING"}, {"name": "VC_BROKER", "type": "STRING"}, {"name": "EN_DISCOUNT", "type": "DOUBLE"}, {"name": "VC_LASTDATE", "type": "STRING"}, {"name": "L_REALLOTNUM", "type": "DOUBLE"}, {"name": "C_AUTOFLAG", "type": "STRING"}, {"name": "VC_CENTERNO", "type": "STRING"}, {"name": "VC_CITYNO", "type": "STRING"}, {"name": "VC_SELLER", "type": "STRING"}, {"name": "VC_SPELL", "type": "STRING"}, {"name": "VC_CDCARD", "type": "STRING"}, {"name": "C_BILLPATH", "type": "STRING"}, {"name": "D_ERRDATE", "type": "STRING"}, {"name": "C_USERTYPE", "type": "STRING"}, {"name": "C_TRUENAMEFLAG", "type": "STRING"}, {"name": "VC_SPECIAL", "type": "STRING"}, {"name": "VC_OFFICE", "type": "STRING"}, {"name": "VC_OFFICETEL", "type": "STRING"}, {"name": "C_CUSTKIND", "type": "STRING"}, {"name": "EN_YEARRATE", "type": "DOUBLE"}, {"name": "C_RATEGROUP", "type": "STRING"}, {"name": "VC_EXPLAIN", "type": "STRING"}, {"name": "C_NEEDACTIVE", "type": "STRING"}, {"name": "VC_TRADECONTACT", "type": "STRING"}, {"name": "C_PROVINCECODE", "type": "STRING"}, {"name": "VC_COUNTYNO", "type": "STRING"}, {"name": "C_MOBILE", "type": "STRING"}, {"name": "VC_CONTVALIDATE", "type": "STRING"}, {"name": "VC_RECIPIENTSTYPE", "type": "STRING"}, {"name": "VC_RECIPIENTSNO", "type": "STRING"}, {"name": "VC_RECIPIENTSVALIDATE", "type": "STRING"}, {"name": "C_PRINCIPALTYPE", "type": "STRING"}, {"name": "VC_PRINCIPALNO", "type": "STRING"}, {"name": "VC_PRINCIPALVALIDATE", "type": "STRING"}, {"name": "VC_RECOMMENDER", "type": "STRING"}, {"name": "VC_RECIPIENTSNAME", "type": "STRING"}, {"name": "VC_PRINCIPALNAME", "type": "STRING"}, {"name": "VC_BENEFICIARY", "type": "STRING"}, {"name": "VC_BUSINESSRANGE", "type": "STRING"}, {"name": "C_ISTRUSTFLAG", "type": "STRING"}, {"name": "VC_TRUSTCLIENT", "type": "STRING"}, {"name": "VC_TRUSTPHONE", "type": "STRING"}, {"name": "C_RECOMMENDERTYPE", "type": "STRING"}, {"name": "C_TRUSTTYPE", "type": "STRING"}, {"name": "VC_TRUSTNO", "type": "STRING"}, {"name": "VC_TRUSTCONTACT", "type": "STRING"}, {"name": "VC_TRUSTADDRESS", "type": "STRING"}, {"name": "VC_TRUSTFAXNO", "type": "STRING"}, {"name": "C_ISANNUITYFLAG", "type": "STRING"}, {"name": "C_ISSOCIALFLAG", "type": "STRING"}, {"name": "VC_TRADEPURPOSE", "type": "STRING"}, {"name": "VC_CONTADDRESS", "type": "STRING"}, {"name": "VC_CONTZIP", "type": "STRING"}, {"name": "VC_CONTEXPLAIN", "type": "STRING"}, {"name": "C_CONTRIGHT", "type": "STRING"}, {"name": "VC_CONTRELATION", "type": "STRING"}, {"name": "VC_LOCATIONZIP", "type": "STRING"}, {"name": "VC_MSGSENDTYPE", "type": "STRING"}, {"name": "C_REMINDFLAG", "type": "STRING"}, {"name": "VC_LASTPASSWDDATE", "type": "STRING"}, {"name": "VC_CONTWARRANTVALIDATE", "type": "STRING"}, {"name": "VC_CONTEMAIL", "type": "STRING"}, {"name": "VC_RECOMMENDERPHONE", "type": "STRING"}, {"name": "VC_RECOMMENDERPROVINCE", "type": "STRING"}, {"name": "VC_RECOMMENDERCITYNO", "type": "STRING"}, {"name": "VC_CONTMOBILENO", "type": "STRING"}, {"name": "C_PREUSERFLAG", "type": "STRING"}, {"name": "C_CONTIDENTIFICATIONMODE", "type": "STRING"}, {"name": "VC_SOURCETRADEACCO", "type": "STRING"}, {"name": "VC_ACCOUSAGE", "type": "STRING"}, {"name": "L_RESTRICTEDPERIOD", "type": "DOUBLE"}, {"name": "VC_LINKMAN", "type": "STRING"}, {"name": "VC_BANKIDNO", "type": "STRING"}, {"name": "VC_PRINCIPALTELNO", "type": "STRING"}, {"name": "VC_COMEFROM", "type": "STRING"}, {"name": "VC_LONGCDCARD", "type": "STRING"}, {"name": "EN_CHECKBALANCE", "type": "DOUBLE"}, {"name": "VC_OTHERUSERID", "type": "STRING"}, {"name": "VC_PARTNERID", "type": "STRING"}, {"name": "C_LONGBILLPATH", "type": "STRING"}, {"name": "VC_MANAGERCODE", "type": "STRING"}, {"name": "VC_RECOMMENDEROFFICE", "type": "STRING"}, {"name": "VC_CUSTADDNAME", "type": "STRING"}, {"name": "EN_REMAINBALA", "type": "DOUBLE"}, {"name": "VC_REMAINFUNDCODE", "type": "STRING"}, {"name": "VC_TRADECOMEFROM", "type": "STRING"}, {"name": "VC_PERMANENTADDRESS", "type": "STRING"}, {"name": "C_FATCATYPE", "type": "STRING"}, {"name": "C_FATCAINDUSTRYTYPE", "type": "STRING"}, {"name": "VC_TINNO", "type": "STRING"}, {"name": "VC_EINGINNNO", "type": "STRING"}, {"name": "VC_DUEDILIGENCEDATE", "type": "STRING"}, {"name": "VC_NATIONALITY", "type": "STRING"}, {"name": "VC_NOGIININST", "type": "STRING"}, {"name": "VC_SPECIALACCO", "type": "STRING"}, {"name": "C_GZBSIGNFLAG", "type": "STRING"}, {"name": "C_CANMODIFYBANKINFO", "type": "STRING"}, {"name": "C_MOBILEVALIDATEFLAG", "type": "STRING"}, {"name": "VC_OLDTRADEACCO", "type": "STRING"}, {"name": "C_BENEFICIARYIDTYPE", "type": "STRING"}, {"name": "VC_BENEFICIARYIDNO", "type": "STRING"}, {"name": "VC_BENEFICIARYIDVALIDATE", "type": "STRING"}, {"name": "VC_BENEFICIARYCUSTTYPE", "type": "STRING"}, {"name": "VC_PRODUCTID", "type": "STRING"}, {"name": "C_AUTHORFLAG", "type": "STRING"}, {"name": "VC_TOWNNO", "type": "STRING"}, {"name": "VC_VILLAGENO", "type": "STRING"}, {"name": "VC_ADDRESSDETAIL", "type": "STRING"}, {"name": "VC_PORTFOLIOCODE", "type": "STRING"}, {"name": "VC_LIVENATION", "type": "STRING"}, {"name": "VC_OFFICENATION", "type": "STRING"}, {"name": "VC_REGNATION", "type": "STRING"}, {"name": "VC_PRINCIPALEMAIL", "type": "STRING"}, {"name": "VC_INTRODEPT", "type": "STRING"}, {"name": "VC_INTRODUCER", "type": "STRING"}, {"name": "VC_BRANCHOFFICE", "type": "STRING"}, {"name": "VC_BUSINDEPT", "type": "STRING"}, {"name": "VC_BUSINDEPTINTRO", "type": "STRING"}, {"name": "VC_ASSETSELEMENT", "type": "STRING"}, {"name": "VC_PLATFORMNO", "type": "STRING"}, {"name": "VC_BILLEMAILL", "type": "STRING"}, {"name": "C_TRUSTCUSTTYPE", "type": "STRING"}, {"name": "VC_LINKTRADEACCO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_taccoinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_taccoinfo_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_taccoinfo_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_taccoinfo_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TACCOINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TACCOINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_taccoinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TACCOINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_CUSTNO
     , VC_TRADEACCO
     , C_CUSTTYPE
     , VC_ACCONAME
     , C_MAINFLAG
     , VC_ACCOCARD
     , VC_PHONE
     , VC_CONTACT
     , C_CONTTYPE
     , VC_CONTNO
     , VC_CONTPHONE
     , C_BILLWAY
     , VC_ADDRESS
     , VC_ZIP
     , VC_MOBILENO
     , VC_PAGENO
     , VC_FAXNO
     , VC_EMAIL
     , C_CALLCENTER
     , C_INTERNET
     , C_SELFHELP
     , C_FAXTRUST
     , C_BROKERTRUST
     , C_OTHERTRUST
     , VC_DEALPWD
     , VC_QUERYPWD
     , VC_CIPHERTEXT
     , C_DIVIDENDMETHOD
     , VC_OPENDATE
     , VC_NETNO
     , L_PASSWDERR
     , C_CAPITALMODE
     , C_STATE
     , VC_BROKER
     , EN_DISCOUNT
     , VC_LASTDATE
     , L_REALLOTNUM
     , C_AUTOFLAG
     , VC_CENTERNO
     , VC_CITYNO
     , VC_SELLER
     , VC_SPELL
     , VC_CDCARD
     , C_BILLPATH
     , D_ERRDATE
     , C_USERTYPE
     , C_TRUENAMEFLAG
     , VC_SPECIAL
     , VC_OFFICE
     , VC_OFFICETEL
     , C_CUSTKIND
     , EN_YEARRATE
     , C_RATEGROUP
     , VC_EXPLAIN
     , C_NEEDACTIVE
     , VC_TRADECONTACT
     , C_PROVINCECODE
     , VC_COUNTYNO
     , C_MOBILE
     , VC_CONTVALIDATE
     , VC_RECIPIENTSTYPE
     , VC_RECIPIENTSNO
     , VC_RECIPIENTSVALIDATE
     , C_PRINCIPALTYPE
     , VC_PRINCIPALNO
     , VC_PRINCIPALVALIDATE
     , VC_RECOMMENDER
     , VC_RECIPIENTSNAME
     , VC_PRINCIPALNAME
     , VC_BENEFICIARY
     , VC_BUSINESSRANGE
     , C_ISTRUSTFLAG
     , VC_TRUSTCLIENT
     , VC_TRUSTPHONE
     , C_RECOMMENDERTYPE
     , C_TRUSTTYPE
     , VC_TRUSTNO
     , VC_TRUSTCONTACT
     , VC_TRUSTADDRESS
     , VC_TRUSTFAXNO
     , C_ISANNUITYFLAG
     , C_ISSOCIALFLAG
     , VC_TRADEPURPOSE
     , VC_CONTADDRESS
     , VC_CONTZIP
     , VC_CONTEXPLAIN
     , C_CONTRIGHT
     , VC_CONTRELATION
     , VC_LOCATIONZIP
     , VC_MSGSENDTYPE
     , C_REMINDFLAG
     , VC_LASTPASSWDDATE
     , VC_CONTWARRANTVALIDATE
     , VC_CONTEMAIL
     , VC_RECOMMENDERPHONE
     , VC_RECOMMENDERPROVINCE
     , VC_RECOMMENDERCITYNO
     , VC_CONTMOBILENO
     , C_PREUSERFLAG
     , C_CONTIDENTIFICATIONMODE
     , VC_SOURCETRADEACCO
     , VC_ACCOUSAGE
     , L_RESTRICTEDPERIOD
     , VC_LINKMAN
     , VC_BANKIDNO
     , VC_PRINCIPALTELNO
     , VC_COMEFROM
     , VC_LONGCDCARD
     , EN_CHECKBALANCE
     , VC_OTHERUSERID
     , VC_PARTNERID
     , C_LONGBILLPATH
     , VC_MANAGERCODE
     , VC_RECOMMENDEROFFICE
     , VC_CUSTADDNAME
     , EN_REMAINBALA
     , VC_REMAINFUNDCODE
     , VC_TRADECOMEFROM
     , VC_PERMANENTADDRESS
     , C_FATCATYPE
     , C_FATCAINDUSTRYTYPE
     , VC_TINNO
     , VC_EINGINNNO
     , VC_DUEDILIGENCEDATE
     , VC_NATIONALITY
     , VC_NOGIININST
     , VC_SPECIALACCO
     , C_GZBSIGNFLAG
     , C_CANMODIFYBANKINFO
     , C_MOBILEVALIDATEFLAG
     , VC_OLDTRADEACCO
     , C_BENEFICIARYIDTYPE
     , VC_BENEFICIARYIDNO
     , VC_BENEFICIARYIDVALIDATE
     , VC_BENEFICIARYCUSTTYPE
     , VC_PRODUCTID
     , C_AUTHORFLAG
     , VC_TOWNNO
     , VC_VILLAGENO
     , VC_ADDRESSDETAIL
     , VC_PORTFOLIOCODE
     , VC_LIVENATION
     , VC_OFFICENATION
     , VC_REGNATION
     , VC_PRINCIPALEMAIL
     , VC_INTRODEPT
     , VC_INTRODUCER
     , VC_BRANCHOFFICE
     , VC_BUSINDEPT
     , VC_BUSINDEPTINTRO
     , VC_ASSETSELEMENT
     , VC_PLATFORMNO
     , VC_BILLEMAILL
     , C_TRUSTCUSTTYPE
     , VC_LINKTRADEACCO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TACCOINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TACCOINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TACCOINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TACCOINFO_PFD成功"
      exit 0
   fi
fi
