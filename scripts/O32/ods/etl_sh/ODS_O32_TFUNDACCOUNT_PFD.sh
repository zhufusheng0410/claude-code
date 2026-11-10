#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFUNDACCOUNT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDACCOUNT_PFD_TMP(
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_ISSUER_ID  DECIMAL(10,0)  COMMENT  '基金管理公司',
  VC_ACCOUNT_NAME  STRING  COMMENT  '开户名称',
  VC_ID_TYPE  STRING  COMMENT  '证件类型',
  VC_ID_NO  STRING  COMMENT  '证件号码',
  VC_FUND_ACCOUNT  STRING  COMMENT  '基金账号',
  VC_TRADE_ACCOUNT  STRING  COMMENT  '交易账号',
  C_TA_TYPE  STRING  COMMENT  'ta类型',
  VC_TRANSACTOR_NAME  STRING  COMMENT  '经办人姓名',
  VC_TRANSACTOR_ID_TYPE  STRING  COMMENT  '经办人证件类型',
  VC_TRANSACTOR_ID  STRING  COMMENT  '经办人证件号码',
  VC_TRANSACTOR_PHONE  STRING  COMMENT  '经办人联系电话',
  VC_TRANSACTOR_FAX  STRING  COMMENT  '经办人传真',
  VC_TRANSACTOR_STAMP  STRING  COMMENT  '经办人签章文件名',
  L_TRANSACTOR_VALIDITY  DECIMAL(8,0)  COMMENT  '经办人有效期',
  VC_PRE_STAMP  STRING  COMMENT  '预留签章',
  VC_CAPITAL_ACCOUNT  STRING  COMMENT  '资金帐号',
  C_STATUS  STRING  COMMENT  '状态',
  VC_PRE_STAMP2  STRING  COMMENT  '预留签章2',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  VC_REGISTER_SALEORG  STRING  COMMENT  '',
  VC_INVESTOR_NAME  STRING  COMMENT  '',
  L_ID_VALID_DATE  DECIMAL(8,0)  COMMENT  '',
  C_CERTIFICATE_TYPE  STRING  COMMENT  '投资者证件类型',
  VC_CERTIFICATE_NO  STRING  COMMENT  '投资者证件号码',
  L_CERTVALID_DATE  DECIMAL(8,0)  COMMENT  '投资者证件有效期',
  VC_SHSTOCKACCOUNT_ID  STRING  COMMENT  '上交所证券账号',
  VC_SZSTOCKACCOUNT_ID  STRING  COMMENT  '深交所证券账号',
  VC_ACCOUNT_CARD_ID  STRING  COMMENT  '',
  C_INDIVIDUALORINSTITUTION  STRING  COMMENT  '',
  VC_INSTITUTION_TYPE  STRING  COMMENT  '',
  VC_INSTREPRMANAGERANGE  STRING  COMMENT  '机构法人经营范围反洗钱信息',
  VC_INSTREPR_NAME  STRING  COMMENT  '法人代表姓名',
  C_INSTREPRID_TYPE  STRING  COMMENT  '法人代表身份证件类型',
  VC_INSTREPRID_CODE  STRING  COMMENT  '法人代表身份证件代码',
  VC_INSTREPRID_TEL_NO  STRING  COMMENT  '',
  VC_INSTREPRID_ADDRESS  STRING  COMMENT  '',
  L_IR_CERTVALID_DATE  DECIMAL(8,0)  COMMENT  '法人证件有效期',
  VC_TACODE  STRING  COMMENT  '',
  L_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '修改日期',
  L_MODIFY_OPERATOR  DECIMAL(8,0)  COMMENT  '修改人',
  VC_ORGNO  STRING  COMMENT  '组织机构代码反洗钱信息',
  VC_TAXNO  STRING  COMMENT  '税务登记证号码反洗钱信息',
  C_RISKTYPE  STRING  COMMENT  '',
  VC_ORGNOVALIDDATE  STRING  COMMENT  '',
  C_QUALIFICATIONTYPE  STRING  COMMENT  '',
  VC_QUALIFICATIONNO  STRING  COMMENT  '',
  VC_QUALIFICATIONVALIDDATE  STRING  COMMENT  '',
  C_BILLRECIPIENTTYPE  STRING  COMMENT  '',
  VC_BILLRECIPIENTNO  STRING  COMMENT  '',
  VC_BILLRECIPIENTVALIDDATE  STRING  COMMENT  '',
  C_RESPONSIBLECERTYPE  STRING  COMMENT  '',
  VC_RESPONSIBLECERNO  STRING  COMMENT  '',
  VC_RESPONSIBLECERVALIDDATE  STRING  COMMENT  '',
  VC_ACCOUNTCONTROLLER  STRING  COMMENT  '',
  C_SHAREHOLDERCERTYPE  STRING  COMMENT  '',
  VC_SHAREHOLDERCERNO  STRING  COMMENT  '',
  VC_SHAREHOLDERCERVALIDDATE  STRING  COMMENT  '',
  VC_SHAREHOLDERORGNO  STRING  COMMENT  '',
  VC_SHAREHOLDERTAXNO  STRING  COMMENT  '',
  VC_BILLRECIPIENTNAME  STRING  COMMENT  '',
  VC_RESPONSIBLENAME  STRING  COMMENT  '',
  VC_AMLREMARKS  STRING  COMMENT  '',
  VC_ACCOUNTBENEFICIARY  STRING  COMMENT  '',
  C_TRUSTASSETSFLG  STRING  COMMENT  '',
  VC_CLIENTNAME  STRING  COMMENT  '',
  VC_CLIENTTEL  STRING  COMMENT  '',
  C_SHAREHOLDERTYPE  STRING  COMMENT  '',
  C_CLIENTCERTYPE  STRING  COMMENT  '',
  VC_CLIENTCERNO  STRING  COMMENT  '',
  VC_OPERATOR  STRING  COMMENT  '操作员',
  VC_OPERATORADDR  STRING  COMMENT  '',
  VC_OPERATORFAX  STRING  COMMENT  '',
  VC_INFOSENDTYPE  STRING  COMMENT  '',
  VC_INCOMESOURCE  STRING  COMMENT  '',
  C_CUSTOMERTRADETYPE  STRING  COMMENT  '',
  C_EXPECTEDACCOUNTSIZE  STRING  COMMENT  '',
  C_ACTUALBUSINESS  STRING  COMMENT  '',
  C_FUNDSOURCE  STRING  COMMENT  '',
  C_SUITABLYINVESTORSFLG  STRING  COMMENT  '',
  C_SUITABLYINVESTORSTYPE  STRING  COMMENT  '',
  C_ACCESSQUALIFICATIONFLG  STRING  COMMENT  '',
  VC_SUITABLYINVESTORSVALIDDATE  STRING  COMMENT  '',
  VC_BADCREDITRECOR  STRING  COMMENT  '',
  VC_BADCREDITEXPLAIN  STRING  COMMENT  '',
  C_CRSACCOUNTTYPE  STRING  COMMENT  '',
  C_CRSORGTYPE  STRING  COMMENT  '',
  C_CRSNONRESIDEFLG  STRING  COMMENT  '',
  C_CRSEXISTNONRESIDE  STRING  COMMENT  '',
  VC_CRSREGISTEREDCOUNTRY  STRING  COMMENT  '',
  VC_CRSCUROFFICEADDR  STRING  COMMENT  '',
  VC_CRSCUROFFICECOUNTRY  STRING  COMMENT  '',
  VC_CRSMAILINGADDR  STRING  COMMENT  '',
  VC_CRSMAILINGADDRCOUNTRY  STRING  COMMENT  '',
  C_CRSCUSTOMERTYPE  STRING  COMMENT  '',
  VC_CRSBIRTHCOUNTRY  STRING  COMMENT  '',
  VC_CRSCURADDRESS  STRING  COMMENT  '',
  VC_CRSPYNAME  STRING  COMMENT  '',
  VC_CRSPYBIRTHPLACE  STRING  COMMENT  '',
  VC_CRSPYCURADDRESS  STRING  COMMENT  '',
  VC_CRSTAXINFOMAINID  STRING  COMMENT  '',
  C_CRSMAINTAXINFOFLG  STRING  COMMENT  '',
  VC_CRSCONTACTCITY  STRING  COMMENT  '',
  VC_CRSENCONTACTCOUNTRY  STRING  COMMENT  '',
  VC_CRSENCONTACTCITY  STRING  COMMENT  '',
  VC_CRSENCONTACTADDR  STRING  COMMENT  '',
  VC_CRSCUROFFICECITY  STRING  COMMENT  '',
  VC_CRSENCUROFFICECOUNTRY  STRING  COMMENT  '',
  VC_CRSENNAME  STRING  COMMENT  '',
  VC_CRSBIRTHCITY  STRING  COMMENT  '',
  VC_CRSENBIRTHCOUNTRY  STRING  COMMENT  '',
  VC_CRSDOCUMENTSIGNER  STRING  COMMENT  '',
  VC_CRSLASTUPDATEDATE  STRING  COMMENT  '',
  VC_CRSREGISTERCITY  STRING  COMMENT  '',
  VC_CRSREGISTERADDR  STRING  COMMENT  '',
  VC_CRSENREGISTERCOUNTRY  STRING  COMMENT  '',
  VC_CRSENREGISTERCITY  STRING  COMMENT  '',
  VC_CRSENREGISTERADDR  STRING  COMMENT  '',
  VC_CRSMAILCITYNO  STRING  COMMENT  '',
  VC_CRSMAILPROVINCENO  STRING  COMMENT  '',
  VC_CRSCUROFFICECITYNO  STRING  COMMENT  '',
  VC_CRSCUROFFICEPROVINCENO  STRING  COMMENT  '',
  VC_CRSREGISTERCITYNO  STRING  COMMENT  '',
  VC_CRSPROVINCENO  STRING  COMMENT  '',
  VC_CRSACCOUNTADMINID  STRING  COMMENT  '',
  VC_CRSORGNAME  STRING  COMMENT  '',
  C_CRSCERTYPE  STRING  COMMENT  '',
  VC_CRSCERNO  STRING  COMMENT  '',
  VC_CRSZIPCODE  STRING  COMMENT  '',
  VC_CRSFIRSTSENDDATE  STRING  COMMENT  '',
  VC_CRSCDDDATE  STRING  COMMENT  '',
  C_CRSOBTAINSTATEMENTFLG  STRING  COMMENT  '',
  C_CRSREPORTADDRTYPE  STRING  COMMENT  '',
  C_BIOPENCUSTOMERTYPE  STRING  COMMENT  '',
  VC_BIOPENCUSTOMERNAME  STRING  COMMENT  '',
  C_BIOPENCERTYPE  STRING  COMMENT  '',
  VC_BIOPENCERNO  STRING  COMMENT  '',
  VC_BIOPENNATIONALITY  STRING  COMMENT  '',
  VC_BIID  STRING  COMMENT  '',
  VC_BINAME  STRING  COMMENT  '',
  VC_BITYPE  STRING  COMMENT  '',
  VC_BINATIONALITY  STRING  COMMENT  '',
  C_BICERTYPE  STRING  COMMENT  '',
  VC_BICERNO  STRING  COMMENT  '',
  VC_BICERVALIDDATE  STRING  COMMENT  '',
  VC_BIADDR  STRING  COMMENT  '',
  C_BINONPERSONTYPE  STRING  COMMENT  '',
  EN_BISHAREHOLDINGRATIO  DECIMAL(5,2)  COMMENT  '',
  C_SIOPENCUSTOMERTYPE  STRING  COMMENT  '',
  VC_SIOPENCUSTOMERNAME  STRING  COMMENT  '',
  C_SIOPENCERTYPE  STRING  COMMENT  '',
  VC_SIOPENCERNO  STRING  COMMENT  '',
  VC_SIOPENNATIONALITY  STRING  COMMENT  '',
  VC_SIID  STRING  COMMENT  '',
  VC_SINAME  STRING  COMMENT  '',
  C_SITYPE  STRING  COMMENT  '',
  VC_SINATIONALITY  STRING  COMMENT  '',
  C_SICERTYPE  STRING  COMMENT  '',
  VC_SICERNO  STRING  COMMENT  '',
  VC_SICERVALIDDATE  STRING  COMMENT  '',
  EN_SISHAREHOLDINGQUANTITY  DECIMAL(16,2)  COMMENT  '',
  C_SISHAREHOLDERTYPE  STRING  COMMENT  '',
  VC_SISHAREHOLDEREXPLAIN  STRING  COMMENT  '',
  L_APPNO  DECIMAL(10,0)  COMMENT  '',
  C_INVESTMENTVARIETY  STRING  COMMENT  '',
  C_INVESTMENTTERM  STRING  COMMENT  '',
  VC_INVESTORABBREVIATION  STRING  COMMENT  '',
  VC_UNIONPAYCDNO  STRING  COMMENT  '',
  VC_CEREXPIRYDATE  STRING  COMMENT  '',
  VC_OPERATORTEL  STRING  COMMENT  '',
  VC_OPERATORAUTHOREXPIRYDATE  STRING  COMMENT  '',
  C_CORPORATESEX  STRING  COMMENT  '',
  VC_CORPORATEDUTY  STRING  COMMENT  '',
  VC_CORPORATEOFFICEMAIL  STRING  COMMENT  '',
  VC_CORPORATEMOBILE  STRING  COMMENT  '',
  VC_CORPORATEMAIL  STRING  COMMENT  '',
  C_NATURE  STRING  COMMENT  '',
  VC_REGISTEREDADDRESS  STRING  COMMENT  '',
  C_EMPLOYEESNUMBER  STRING  COMMENT  '',
  EN_REGISTEREDCAPITAL  DECIMAL(16,2)  COMMENT  '',
  VC_COUNTRY  STRING  COMMENT  '',
  VC_PROVINCE  STRING  COMMENT  '',
  VC_FACITY  STRING  COMMENT  '',
  VC_POSTALCODE  STRING  COMMENT  '',
  VC_POSTALADDRESS  STRING  COMMENT  '',
  VC_TEL  STRING  COMMENT  '联系电话',
  VC_MOBILE  STRING  COMMENT  '',
  VC_FAX  STRING  COMMENT  '传真',
  VC_MAIL  STRING  COMMENT  '',
  C_BILLSENDMODE  STRING  COMMENT  '',
  C_BILLSENDWAY  STRING  COMMENT  '',
  VC_BILLSENDCITY  STRING  COMMENT  '',
  VC_AGENTPRODUCTIONNO  STRING  COMMENT  '',
  VC_FILENUMBER  STRING  COMMENT  '',
  VC_CA_STAMP  STRING  COMMENT  '',
  VC_REGACCOUNTNAME  STRING  COMMENT  '',
  VC_TRANSACTOR_EMAIL  STRING  COMMENT  '',
  VC_TRANSACTOR_ADDRESS  STRING  COMMENT  ''
)
COMMENT '基金账号信息表'
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
              "querySql": ["SELECT  L_FUND_ID
                                   , L_ISSUER_ID
                                   , VC_ACCOUNT_NAME
                                   , VC_ID_TYPE
                                   , VC_ID_NO
                                   , VC_FUND_ACCOUNT
                                   , VC_TRADE_ACCOUNT
                                   , C_TA_TYPE
                                   , VC_TRANSACTOR_NAME
                                   , VC_TRANSACTOR_ID_TYPE
                                   , VC_TRANSACTOR_ID
                                   , VC_TRANSACTOR_PHONE
                                   , VC_TRANSACTOR_FAX
                                   , VC_TRANSACTOR_STAMP
                                   , L_TRANSACTOR_VALIDITY
                                   , VC_PRE_STAMP
                                   , VC_CAPITAL_ACCOUNT
                                   , C_STATUS
                                   , VC_PRE_STAMP2
                                   , L_ASSET_ID
                                   , VC_REGISTER_SALEORG
                                   , VC_INVESTOR_NAME
                                   , L_ID_VALID_DATE
                                   , C_CERTIFICATE_TYPE
                                   , VC_CERTIFICATE_NO
                                   , L_CERTVALID_DATE
                                   , VC_SHSTOCKACCOUNT_ID
                                   , VC_SZSTOCKACCOUNT_ID
                                   , VC_ACCOUNT_CARD_ID
                                   , C_INDIVIDUALORINSTITUTION
                                   , VC_INSTITUTION_TYPE
                                   , VC_INSTREPRMANAGERANGE
                                   , VC_INSTREPR_NAME
                                   , C_INSTREPRID_TYPE
                                   , VC_INSTREPRID_CODE
                                   , VC_INSTREPRID_TEL_NO
                                   , VC_INSTREPRID_ADDRESS
                                   , L_IR_CERTVALID_DATE
                                   , VC_TACODE
                                   , L_MODIFY_DATE
                                   , L_MODIFY_OPERATOR
                                   , VC_ORGNO
                                   , VC_TAXNO
                                   , C_RISKTYPE
                                   , VC_ORGNOVALIDDATE
                                   , C_QUALIFICATIONTYPE
                                   , VC_QUALIFICATIONNO
                                   , VC_QUALIFICATIONVALIDDATE
                                   , C_BILLRECIPIENTTYPE
                                   , VC_BILLRECIPIENTNO
                                   , VC_BILLRECIPIENTVALIDDATE
                                   , C_RESPONSIBLECERTYPE
                                   , VC_RESPONSIBLECERNO
                                   , VC_RESPONSIBLECERVALIDDATE
                                   , VC_ACCOUNTCONTROLLER
                                   , C_SHAREHOLDERCERTYPE
                                   , VC_SHAREHOLDERCERNO
                                   , VC_SHAREHOLDERCERVALIDDATE
                                   , VC_SHAREHOLDERORGNO
                                   , VC_SHAREHOLDERTAXNO
                                   , VC_BILLRECIPIENTNAME
                                   , VC_RESPONSIBLENAME
                                   , VC_AMLREMARKS
                                   , VC_ACCOUNTBENEFICIARY
                                   , C_TRUSTASSETSFLG
                                   , VC_CLIENTNAME
                                   , VC_CLIENTTEL
                                   , C_SHAREHOLDERTYPE
                                   , C_CLIENTCERTYPE
                                   , VC_CLIENTCERNO
                                   , VC_OPERATOR
                                   , VC_OPERATORADDR
                                   , VC_OPERATORFAX
                                   , VC_INFOSENDTYPE
                                   , VC_INCOMESOURCE
                                   , C_CUSTOMERTRADETYPE
                                   , C_EXPECTEDACCOUNTSIZE
                                   , C_ACTUALBUSINESS
                                   , C_FUNDSOURCE
                                   , C_SUITABLYINVESTORSFLG
                                   , C_SUITABLYINVESTORSTYPE
                                   , C_ACCESSQUALIFICATIONFLG
                                   , VC_SUITABLYINVESTORSVALIDDATE
                                   , VC_BADCREDITRECOR
                                   , VC_BADCREDITEXPLAIN
                                   , C_CRSACCOUNTTYPE
                                   , C_CRSORGTYPE
                                   , C_CRSNONRESIDEFLG
                                   , C_CRSEXISTNONRESIDE
                                   , VC_CRSREGISTEREDCOUNTRY
                                   , VC_CRSCUROFFICEADDR
                                   , VC_CRSCUROFFICECOUNTRY
                                   , VC_CRSMAILINGADDR
                                   , VC_CRSMAILINGADDRCOUNTRY
                                   , C_CRSCUSTOMERTYPE
                                   , VC_CRSBIRTHCOUNTRY
                                   , VC_CRSCURADDRESS
                                   , VC_CRSPYNAME
                                   , VC_CRSPYBIRTHPLACE
                                   , VC_CRSPYCURADDRESS
                                   , VC_CRSTAXINFOMAINID
                                   , C_CRSMAINTAXINFOFLG
                                   , VC_CRSCONTACTCITY
                                   , VC_CRSENCONTACTCOUNTRY
                                   , VC_CRSENCONTACTCITY
                                   , VC_CRSENCONTACTADDR
                                   , VC_CRSCUROFFICECITY
                                   , VC_CRSENCUROFFICECOUNTRY
                                   , VC_CRSENNAME
                                   , VC_CRSBIRTHCITY
                                   , VC_CRSENBIRTHCOUNTRY
                                   , VC_CRSDOCUMENTSIGNER
                                   , VC_CRSLASTUPDATEDATE
                                   , VC_CRSREGISTERCITY
                                   , VC_CRSREGISTERADDR
                                   , VC_CRSENREGISTERCOUNTRY
                                   , VC_CRSENREGISTERCITY
                                   , VC_CRSENREGISTERADDR
                                   , VC_CRSMAILCITYNO
                                   , VC_CRSMAILPROVINCENO
                                   , VC_CRSCUROFFICECITYNO
                                   , VC_CRSCUROFFICEPROVINCENO
                                   , VC_CRSREGISTERCITYNO
                                   , VC_CRSPROVINCENO
                                   , VC_CRSACCOUNTADMINID
                                   , VC_CRSORGNAME
                                   , C_CRSCERTYPE
                                   , VC_CRSCERNO
                                   , VC_CRSZIPCODE
                                   , VC_CRSFIRSTSENDDATE
                                   , VC_CRSCDDDATE
                                   , C_CRSOBTAINSTATEMENTFLG
                                   , C_CRSREPORTADDRTYPE
                                   , C_BIOPENCUSTOMERTYPE
                                   , VC_BIOPENCUSTOMERNAME
                                   , C_BIOPENCERTYPE
                                   , VC_BIOPENCERNO
                                   , VC_BIOPENNATIONALITY
                                   , VC_BIID
                                   , VC_BINAME
                                   , VC_BITYPE
                                   , VC_BINATIONALITY
                                   , C_BICERTYPE
                                   , VC_BICERNO
                                   , VC_BICERVALIDDATE
                                   , VC_BIADDR
                                   , C_BINONPERSONTYPE
                                   , EN_BISHAREHOLDINGRATIO
                                   , C_SIOPENCUSTOMERTYPE
                                   , VC_SIOPENCUSTOMERNAME
                                   , C_SIOPENCERTYPE
                                   , VC_SIOPENCERNO
                                   , VC_SIOPENNATIONALITY
                                   , VC_SIID
                                   , VC_SINAME
                                   , C_SITYPE
                                   , VC_SINATIONALITY
                                   , C_SICERTYPE
                                   , VC_SICERNO
                                   , VC_SICERVALIDDATE
                                   , EN_SISHAREHOLDINGQUANTITY
                                   , C_SISHAREHOLDERTYPE
                                   , VC_SISHAREHOLDEREXPLAIN
                                   , L_APPNO
                                   , C_INVESTMENTVARIETY
                                   , C_INVESTMENTTERM
                                   , VC_INVESTORABBREVIATION
                                   , VC_UNIONPAYCDNO
                                   , VC_CEREXPIRYDATE
                                   , VC_OPERATORTEL
                                   , VC_OPERATORAUTHOREXPIRYDATE
                                   , C_CORPORATESEX
                                   , VC_CORPORATEDUTY
                                   , VC_CORPORATEOFFICEMAIL
                                   , VC_CORPORATEMOBILE
                                   , VC_CORPORATEMAIL
                                   , C_NATURE
                                   , VC_REGISTEREDADDRESS
                                   , C_EMPLOYEESNUMBER
                                   , EN_REGISTEREDCAPITAL
                                   , VC_COUNTRY
                                   , VC_PROVINCE
                                   , VC_FACITY
                                   , VC_POSTALCODE
                                   , VC_POSTALADDRESS
                                   , VC_TEL
                                   , VC_MOBILE
                                   , VC_FAX
                                   , VC_MAIL
                                   , C_BILLSENDMODE
                                   , C_BILLSENDWAY
                                   , VC_BILLSENDCITY
                                   , VC_AGENTPRODUCTIONNO
                                   , VC_FILENUMBER
                                   , VC_CA_STAMP
                                   , VC_REGACCOUNTNAME
                                   , VC_TRANSACTOR_EMAIL
                                   , VC_TRANSACTOR_ADDRESS
                                FROM ${o32_src_schema}.TFUNDACCOUNT"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ISSUER_ID", "type": "DOUBLE"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "VC_ID_TYPE", "type": "STRING"}, {"name": "VC_ID_NO", "type": "STRING"}, {"name": "VC_FUND_ACCOUNT", "type": "STRING"}, {"name": "VC_TRADE_ACCOUNT", "type": "STRING"}, {"name": "C_TA_TYPE", "type": "STRING"}, {"name": "VC_TRANSACTOR_NAME", "type": "STRING"}, {"name": "VC_TRANSACTOR_ID_TYPE", "type": "STRING"}, {"name": "VC_TRANSACTOR_ID", "type": "STRING"}, {"name": "VC_TRANSACTOR_PHONE", "type": "STRING"}, {"name": "VC_TRANSACTOR_FAX", "type": "STRING"}, {"name": "VC_TRANSACTOR_STAMP", "type": "STRING"}, {"name": "L_TRANSACTOR_VALIDITY", "type": "DOUBLE"}, {"name": "VC_PRE_STAMP", "type": "STRING"}, {"name": "VC_CAPITAL_ACCOUNT", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_PRE_STAMP2", "type": "STRING"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "VC_REGISTER_SALEORG", "type": "STRING"}, {"name": "VC_INVESTOR_NAME", "type": "STRING"}, {"name": "L_ID_VALID_DATE", "type": "DOUBLE"}, {"name": "C_CERTIFICATE_TYPE", "type": "STRING"}, {"name": "VC_CERTIFICATE_NO", "type": "STRING"}, {"name": "L_CERTVALID_DATE", "type": "DOUBLE"}, {"name": "VC_SHSTOCKACCOUNT_ID", "type": "STRING"}, {"name": "VC_SZSTOCKACCOUNT_ID", "type": "STRING"}, {"name": "VC_ACCOUNT_CARD_ID", "type": "STRING"}, {"name": "C_INDIVIDUALORINSTITUTION", "type": "STRING"}, {"name": "VC_INSTITUTION_TYPE", "type": "STRING"}, {"name": "VC_INSTREPRMANAGERANGE", "type": "STRING"}, {"name": "VC_INSTREPR_NAME", "type": "STRING"}, {"name": "C_INSTREPRID_TYPE", "type": "STRING"}, {"name": "VC_INSTREPRID_CODE", "type": "STRING"}, {"name": "VC_INSTREPRID_TEL_NO", "type": "STRING"}, {"name": "VC_INSTREPRID_ADDRESS", "type": "STRING"}, {"name": "L_IR_CERTVALID_DATE", "type": "DOUBLE"}, {"name": "VC_TACODE", "type": "STRING"}, {"name": "L_MODIFY_DATE", "type": "DOUBLE"}, {"name": "L_MODIFY_OPERATOR", "type": "DOUBLE"}, {"name": "VC_ORGNO", "type": "STRING"}, {"name": "VC_TAXNO", "type": "STRING"}, {"name": "C_RISKTYPE", "type": "STRING"}, {"name": "VC_ORGNOVALIDDATE", "type": "STRING"}, {"name": "C_QUALIFICATIONTYPE", "type": "STRING"}, {"name": "VC_QUALIFICATIONNO", "type": "STRING"}, {"name": "VC_QUALIFICATIONVALIDDATE", "type": "STRING"}, {"name": "C_BILLRECIPIENTTYPE", "type": "STRING"}, {"name": "VC_BILLRECIPIENTNO", "type": "STRING"}, {"name": "VC_BILLRECIPIENTVALIDDATE", "type": "STRING"}, {"name": "C_RESPONSIBLECERTYPE", "type": "STRING"}, {"name": "VC_RESPONSIBLECERNO", "type": "STRING"}, {"name": "VC_RESPONSIBLECERVALIDDATE", "type": "STRING"}, {"name": "VC_ACCOUNTCONTROLLER", "type": "STRING"}, {"name": "C_SHAREHOLDERCERTYPE", "type": "STRING"}, {"name": "VC_SHAREHOLDERCERNO", "type": "STRING"}, {"name": "VC_SHAREHOLDERCERVALIDDATE", "type": "STRING"}, {"name": "VC_SHAREHOLDERORGNO", "type": "STRING"}, {"name": "VC_SHAREHOLDERTAXNO", "type": "STRING"}, {"name": "VC_BILLRECIPIENTNAME", "type": "STRING"}, {"name": "VC_RESPONSIBLENAME", "type": "STRING"}, {"name": "VC_AMLREMARKS", "type": "STRING"}, {"name": "VC_ACCOUNTBENEFICIARY", "type": "STRING"}, {"name": "C_TRUSTASSETSFLG", "type": "STRING"}, {"name": "VC_CLIENTNAME", "type": "STRING"}, {"name": "VC_CLIENTTEL", "type": "STRING"}, {"name": "C_SHAREHOLDERTYPE", "type": "STRING"}, {"name": "C_CLIENTCERTYPE", "type": "STRING"}, {"name": "VC_CLIENTCERNO", "type": "STRING"}, {"name": "VC_OPERATOR", "type": "STRING"}, {"name": "VC_OPERATORADDR", "type": "STRING"}, {"name": "VC_OPERATORFAX", "type": "STRING"}, {"name": "VC_INFOSENDTYPE", "type": "STRING"}, {"name": "VC_INCOMESOURCE", "type": "STRING"}, {"name": "C_CUSTOMERTRADETYPE", "type": "STRING"}, {"name": "C_EXPECTEDACCOUNTSIZE", "type": "STRING"}, {"name": "C_ACTUALBUSINESS", "type": "STRING"}, {"name": "C_FUNDSOURCE", "type": "STRING"}, {"name": "C_SUITABLYINVESTORSFLG", "type": "STRING"}, {"name": "C_SUITABLYINVESTORSTYPE", "type": "STRING"}, {"name": "C_ACCESSQUALIFICATIONFLG", "type": "STRING"}, {"name": "VC_SUITABLYINVESTORSVALIDDATE", "type": "STRING"}, {"name": "VC_BADCREDITRECOR", "type": "STRING"}, {"name": "VC_BADCREDITEXPLAIN", "type": "STRING"}, {"name": "C_CRSACCOUNTTYPE", "type": "STRING"}, {"name": "C_CRSORGTYPE", "type": "STRING"}, {"name": "C_CRSNONRESIDEFLG", "type": "STRING"}, {"name": "C_CRSEXISTNONRESIDE", "type": "STRING"}, {"name": "VC_CRSREGISTEREDCOUNTRY", "type": "STRING"}, {"name": "VC_CRSCUROFFICEADDR", "type": "STRING"}, {"name": "VC_CRSCUROFFICECOUNTRY", "type": "STRING"}, {"name": "VC_CRSMAILINGADDR", "type": "STRING"}, {"name": "VC_CRSMAILINGADDRCOUNTRY", "type": "STRING"}, {"name": "C_CRSCUSTOMERTYPE", "type": "STRING"}, {"name": "VC_CRSBIRTHCOUNTRY", "type": "STRING"}, {"name": "VC_CRSCURADDRESS", "type": "STRING"}, {"name": "VC_CRSPYNAME", "type": "STRING"}, {"name": "VC_CRSPYBIRTHPLACE", "type": "STRING"}, {"name": "VC_CRSPYCURADDRESS", "type": "STRING"}, {"name": "VC_CRSTAXINFOMAINID", "type": "STRING"}, {"name": "C_CRSMAINTAXINFOFLG", "type": "STRING"}, {"name": "VC_CRSCONTACTCITY", "type": "STRING"}, {"name": "VC_CRSENCONTACTCOUNTRY", "type": "STRING"}, {"name": "VC_CRSENCONTACTCITY", "type": "STRING"}, {"name": "VC_CRSENCONTACTADDR", "type": "STRING"}, {"name": "VC_CRSCUROFFICECITY", "type": "STRING"}, {"name": "VC_CRSENCUROFFICECOUNTRY", "type": "STRING"}, {"name": "VC_CRSENNAME", "type": "STRING"}, {"name": "VC_CRSBIRTHCITY", "type": "STRING"}, {"name": "VC_CRSENBIRTHCOUNTRY", "type": "STRING"}, {"name": "VC_CRSDOCUMENTSIGNER", "type": "STRING"}, {"name": "VC_CRSLASTUPDATEDATE", "type": "STRING"}, {"name": "VC_CRSREGISTERCITY", "type": "STRING"}, {"name": "VC_CRSREGISTERADDR", "type": "STRING"}, {"name": "VC_CRSENREGISTERCOUNTRY", "type": "STRING"}, {"name": "VC_CRSENREGISTERCITY", "type": "STRING"}, {"name": "VC_CRSENREGISTERADDR", "type": "STRING"}, {"name": "VC_CRSMAILCITYNO", "type": "STRING"}, {"name": "VC_CRSMAILPROVINCENO", "type": "STRING"}, {"name": "VC_CRSCUROFFICECITYNO", "type": "STRING"}, {"name": "VC_CRSCUROFFICEPROVINCENO", "type": "STRING"}, {"name": "VC_CRSREGISTERCITYNO", "type": "STRING"}, {"name": "VC_CRSPROVINCENO", "type": "STRING"}, {"name": "VC_CRSACCOUNTADMINID", "type": "STRING"}, {"name": "VC_CRSORGNAME", "type": "STRING"}, {"name": "C_CRSCERTYPE", "type": "STRING"}, {"name": "VC_CRSCERNO", "type": "STRING"}, {"name": "VC_CRSZIPCODE", "type": "STRING"}, {"name": "VC_CRSFIRSTSENDDATE", "type": "STRING"}, {"name": "VC_CRSCDDDATE", "type": "STRING"}, {"name": "C_CRSOBTAINSTATEMENTFLG", "type": "STRING"}, {"name": "C_CRSREPORTADDRTYPE", "type": "STRING"}, {"name": "C_BIOPENCUSTOMERTYPE", "type": "STRING"}, {"name": "VC_BIOPENCUSTOMERNAME", "type": "STRING"}, {"name": "C_BIOPENCERTYPE", "type": "STRING"}, {"name": "VC_BIOPENCERNO", "type": "STRING"}, {"name": "VC_BIOPENNATIONALITY", "type": "STRING"}, {"name": "VC_BIID", "type": "STRING"}, {"name": "VC_BINAME", "type": "STRING"}, {"name": "VC_BITYPE", "type": "STRING"}, {"name": "VC_BINATIONALITY", "type": "STRING"}, {"name": "C_BICERTYPE", "type": "STRING"}, {"name": "VC_BICERNO", "type": "STRING"}, {"name": "VC_BICERVALIDDATE", "type": "STRING"}, {"name": "VC_BIADDR", "type": "STRING"}, {"name": "C_BINONPERSONTYPE", "type": "STRING"}, {"name": "EN_BISHAREHOLDINGRATIO", "type": "DOUBLE"}, {"name": "C_SIOPENCUSTOMERTYPE", "type": "STRING"}, {"name": "VC_SIOPENCUSTOMERNAME", "type": "STRING"}, {"name": "C_SIOPENCERTYPE", "type": "STRING"}, {"name": "VC_SIOPENCERNO", "type": "STRING"}, {"name": "VC_SIOPENNATIONALITY", "type": "STRING"}, {"name": "VC_SIID", "type": "STRING"}, {"name": "VC_SINAME", "type": "STRING"}, {"name": "C_SITYPE", "type": "STRING"}, {"name": "VC_SINATIONALITY", "type": "STRING"}, {"name": "C_SICERTYPE", "type": "STRING"}, {"name": "VC_SICERNO", "type": "STRING"}, {"name": "VC_SICERVALIDDATE", "type": "STRING"}, {"name": "EN_SISHAREHOLDINGQUANTITY", "type": "DOUBLE"}, {"name": "C_SISHAREHOLDERTYPE", "type": "STRING"}, {"name": "VC_SISHAREHOLDEREXPLAIN", "type": "STRING"}, {"name": "L_APPNO", "type": "DOUBLE"}, {"name": "C_INVESTMENTVARIETY", "type": "STRING"}, {"name": "C_INVESTMENTTERM", "type": "STRING"}, {"name": "VC_INVESTORABBREVIATION", "type": "STRING"}, {"name": "VC_UNIONPAYCDNO", "type": "STRING"}, {"name": "VC_CEREXPIRYDATE", "type": "STRING"}, {"name": "VC_OPERATORTEL", "type": "STRING"}, {"name": "VC_OPERATORAUTHOREXPIRYDATE", "type": "STRING"}, {"name": "C_CORPORATESEX", "type": "STRING"}, {"name": "VC_CORPORATEDUTY", "type": "STRING"}, {"name": "VC_CORPORATEOFFICEMAIL", "type": "STRING"}, {"name": "VC_CORPORATEMOBILE", "type": "STRING"}, {"name": "VC_CORPORATEMAIL", "type": "STRING"}, {"name": "C_NATURE", "type": "STRING"}, {"name": "VC_REGISTEREDADDRESS", "type": "STRING"}, {"name": "C_EMPLOYEESNUMBER", "type": "STRING"}, {"name": "EN_REGISTEREDCAPITAL", "type": "DOUBLE"}, {"name": "VC_COUNTRY", "type": "STRING"}, {"name": "VC_PROVINCE", "type": "STRING"}, {"name": "VC_FACITY", "type": "STRING"}, {"name": "VC_POSTALCODE", "type": "STRING"}, {"name": "VC_POSTALADDRESS", "type": "STRING"}, {"name": "VC_TEL", "type": "STRING"}, {"name": "VC_MOBILE", "type": "STRING"}, {"name": "VC_FAX", "type": "STRING"}, {"name": "VC_MAIL", "type": "STRING"}, {"name": "C_BILLSENDMODE", "type": "STRING"}, {"name": "C_BILLSENDWAY", "type": "STRING"}, {"name": "VC_BILLSENDCITY", "type": "STRING"}, {"name": "VC_AGENTPRODUCTIONNO", "type": "STRING"}, {"name": "VC_FILENUMBER", "type": "STRING"}, {"name": "VC_CA_STAMP", "type": "STRING"}, {"name": "VC_REGACCOUNTNAME", "type": "STRING"}, {"name": "VC_TRANSACTOR_EMAIL", "type": "STRING"}, {"name": "VC_TRANSACTOR_ADDRESS", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfundaccount_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfundaccount_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfundaccount_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfundaccount_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFUNDACCOUNT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFUNDACCOUNT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfundaccount_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFUNDACCOUNT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_FUND_ID
     , L_ISSUER_ID
     , VC_ACCOUNT_NAME
     , VC_ID_TYPE
     , VC_ID_NO
     , VC_FUND_ACCOUNT
     , VC_TRADE_ACCOUNT
     , C_TA_TYPE
     , VC_TRANSACTOR_NAME
     , VC_TRANSACTOR_ID_TYPE
     , VC_TRANSACTOR_ID
     , VC_TRANSACTOR_PHONE
     , VC_TRANSACTOR_FAX
     , VC_TRANSACTOR_STAMP
     , L_TRANSACTOR_VALIDITY
     , VC_PRE_STAMP
     , VC_CAPITAL_ACCOUNT
     , C_STATUS
     , VC_PRE_STAMP2
     , L_ASSET_ID
     , VC_REGISTER_SALEORG
     , VC_INVESTOR_NAME
     , L_ID_VALID_DATE
     , C_CERTIFICATE_TYPE
     , VC_CERTIFICATE_NO
     , L_CERTVALID_DATE
     , VC_SHSTOCKACCOUNT_ID
     , VC_SZSTOCKACCOUNT_ID
     , VC_ACCOUNT_CARD_ID
     , C_INDIVIDUALORINSTITUTION
     , VC_INSTITUTION_TYPE
     , VC_INSTREPRMANAGERANGE
     , VC_INSTREPR_NAME
     , C_INSTREPRID_TYPE
     , VC_INSTREPRID_CODE
     , VC_INSTREPRID_TEL_NO
     , VC_INSTREPRID_ADDRESS
     , L_IR_CERTVALID_DATE
     , VC_TACODE
     , L_MODIFY_DATE
     , L_MODIFY_OPERATOR
     , VC_ORGNO
     , VC_TAXNO
     , C_RISKTYPE
     , VC_ORGNOVALIDDATE
     , C_QUALIFICATIONTYPE
     , VC_QUALIFICATIONNO
     , VC_QUALIFICATIONVALIDDATE
     , C_BILLRECIPIENTTYPE
     , VC_BILLRECIPIENTNO
     , VC_BILLRECIPIENTVALIDDATE
     , C_RESPONSIBLECERTYPE
     , VC_RESPONSIBLECERNO
     , VC_RESPONSIBLECERVALIDDATE
     , VC_ACCOUNTCONTROLLER
     , C_SHAREHOLDERCERTYPE
     , VC_SHAREHOLDERCERNO
     , VC_SHAREHOLDERCERVALIDDATE
     , VC_SHAREHOLDERORGNO
     , VC_SHAREHOLDERTAXNO
     , VC_BILLRECIPIENTNAME
     , VC_RESPONSIBLENAME
     , VC_AMLREMARKS
     , VC_ACCOUNTBENEFICIARY
     , C_TRUSTASSETSFLG
     , VC_CLIENTNAME
     , VC_CLIENTTEL
     , C_SHAREHOLDERTYPE
     , C_CLIENTCERTYPE
     , VC_CLIENTCERNO
     , VC_OPERATOR
     , VC_OPERATORADDR
     , VC_OPERATORFAX
     , VC_INFOSENDTYPE
     , VC_INCOMESOURCE
     , C_CUSTOMERTRADETYPE
     , C_EXPECTEDACCOUNTSIZE
     , C_ACTUALBUSINESS
     , C_FUNDSOURCE
     , C_SUITABLYINVESTORSFLG
     , C_SUITABLYINVESTORSTYPE
     , C_ACCESSQUALIFICATIONFLG
     , VC_SUITABLYINVESTORSVALIDDATE
     , VC_BADCREDITRECOR
     , VC_BADCREDITEXPLAIN
     , C_CRSACCOUNTTYPE
     , C_CRSORGTYPE
     , C_CRSNONRESIDEFLG
     , C_CRSEXISTNONRESIDE
     , VC_CRSREGISTEREDCOUNTRY
     , VC_CRSCUROFFICEADDR
     , VC_CRSCUROFFICECOUNTRY
     , VC_CRSMAILINGADDR
     , VC_CRSMAILINGADDRCOUNTRY
     , C_CRSCUSTOMERTYPE
     , VC_CRSBIRTHCOUNTRY
     , VC_CRSCURADDRESS
     , VC_CRSPYNAME
     , VC_CRSPYBIRTHPLACE
     , VC_CRSPYCURADDRESS
     , VC_CRSTAXINFOMAINID
     , C_CRSMAINTAXINFOFLG
     , VC_CRSCONTACTCITY
     , VC_CRSENCONTACTCOUNTRY
     , VC_CRSENCONTACTCITY
     , VC_CRSENCONTACTADDR
     , VC_CRSCUROFFICECITY
     , VC_CRSENCUROFFICECOUNTRY
     , VC_CRSENNAME
     , VC_CRSBIRTHCITY
     , VC_CRSENBIRTHCOUNTRY
     , VC_CRSDOCUMENTSIGNER
     , VC_CRSLASTUPDATEDATE
     , VC_CRSREGISTERCITY
     , VC_CRSREGISTERADDR
     , VC_CRSENREGISTERCOUNTRY
     , VC_CRSENREGISTERCITY
     , VC_CRSENREGISTERADDR
     , VC_CRSMAILCITYNO
     , VC_CRSMAILPROVINCENO
     , VC_CRSCUROFFICECITYNO
     , VC_CRSCUROFFICEPROVINCENO
     , VC_CRSREGISTERCITYNO
     , VC_CRSPROVINCENO
     , VC_CRSACCOUNTADMINID
     , VC_CRSORGNAME
     , C_CRSCERTYPE
     , VC_CRSCERNO
     , VC_CRSZIPCODE
     , VC_CRSFIRSTSENDDATE
     , VC_CRSCDDDATE
     , C_CRSOBTAINSTATEMENTFLG
     , C_CRSREPORTADDRTYPE
     , C_BIOPENCUSTOMERTYPE
     , VC_BIOPENCUSTOMERNAME
     , C_BIOPENCERTYPE
     , VC_BIOPENCERNO
     , VC_BIOPENNATIONALITY
     , VC_BIID
     , VC_BINAME
     , VC_BITYPE
     , VC_BINATIONALITY
     , C_BICERTYPE
     , VC_BICERNO
     , VC_BICERVALIDDATE
     , VC_BIADDR
     , C_BINONPERSONTYPE
     , EN_BISHAREHOLDINGRATIO
     , C_SIOPENCUSTOMERTYPE
     , VC_SIOPENCUSTOMERNAME
     , C_SIOPENCERTYPE
     , VC_SIOPENCERNO
     , VC_SIOPENNATIONALITY
     , VC_SIID
     , VC_SINAME
     , C_SITYPE
     , VC_SINATIONALITY
     , C_SICERTYPE
     , VC_SICERNO
     , VC_SICERVALIDDATE
     , EN_SISHAREHOLDINGQUANTITY
     , C_SISHAREHOLDERTYPE
     , VC_SISHAREHOLDEREXPLAIN
     , L_APPNO
     , C_INVESTMENTVARIETY
     , C_INVESTMENTTERM
     , VC_INVESTORABBREVIATION
     , VC_UNIONPAYCDNO
     , VC_CEREXPIRYDATE
     , VC_OPERATORTEL
     , VC_OPERATORAUTHOREXPIRYDATE
     , C_CORPORATESEX
     , VC_CORPORATEDUTY
     , VC_CORPORATEOFFICEMAIL
     , VC_CORPORATEMOBILE
     , VC_CORPORATEMAIL
     , C_NATURE
     , VC_REGISTEREDADDRESS
     , C_EMPLOYEESNUMBER
     , EN_REGISTEREDCAPITAL
     , VC_COUNTRY
     , VC_PROVINCE
     , VC_FACITY
     , VC_POSTALCODE
     , VC_POSTALADDRESS
     , VC_TEL
     , VC_MOBILE
     , VC_FAX
     , VC_MAIL
     , C_BILLSENDMODE
     , C_BILLSENDWAY
     , VC_BILLSENDCITY
     , VC_AGENTPRODUCTIONNO
     , VC_FILENUMBER
     , VC_CA_STAMP
     , VC_REGACCOUNTNAME
     , VC_TRANSACTOR_EMAIL
     , VC_TRANSACTOR_ADDRESS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TFUNDACCOUNT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFUNDACCOUNT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFUNDACCOUNT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFUNDACCOUNT_PFD成功"
      exit 0
   fi
fi
