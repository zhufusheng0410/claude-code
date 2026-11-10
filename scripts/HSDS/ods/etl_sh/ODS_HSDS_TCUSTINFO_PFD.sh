#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD_TMP(
  VC_CUSTNO  STRING  COMMENT  '客户编号',
  C_CUSTTYPE  STRING  COMMENT  '客户类别',
  VC_CUSTOMNAME  STRING  COMMENT  '客户名称',
  VC_SHORTNAME  STRING  COMMENT  '客户简称',
  C_IDENTITYTYPE  STRING  COMMENT  '证件类型',
  VC_IDENTITYNO  STRING  COMMENT  '证件号码',
  C_MODIFYFLAG  STRING  COMMENT  '修改标识',
  VC_INSTREPRNAME  STRING  COMMENT  '法人代表姓名',
  C_INSTREPRTYPE  STRING  COMMENT  '法人证件类型',
  VC_INSTREPRNO  STRING  COMMENT  '法人证件号码',
  C_TRADE  STRING  COMMENT  '行业',
  C_CORPROPERTIY  STRING  COMMENT  '企业性质',
  C_REGISTCAPITAL  STRING  COMMENT  '注册资本',
  C_VOCATION  STRING  COMMENT  '职业',
  C_EDUCATION  STRING  COMMENT  '学历',
  L_INCOME  DECIMAL(16,0)  COMMENT  '年收入',
  C_SEX  STRING  COMMENT  '性别',
  C_MARRIAGE  STRING  COMMENT  '婚姻',
  VC_BIRTHDAY  STRING  COMMENT  '出生日期',
  C_INVEST  STRING  COMMENT  '帐户备注',
  VC_SZACCO  STRING  COMMENT  '深交所股东账号',
  VC_SHACCO  STRING  COMMENT  '上交所股东账号',
  C_STATE  STRING  COMMENT  '状态',
  VC_SPELL  STRING  COMMENT  '简拼',
  C_WORKTIME  STRING  COMMENT  '职业状况',
  C_INVESTEXP  STRING  COMMENT  '投资状况',
  C_INVESTYEARS  STRING  COMMENT  '投资年限',
  C_INVESTASSETS  STRING  COMMENT  '投资比例',
  C_INVESTTOOLS  STRING  COMMENT  '投资工具',
  C_INVESTWHYS  STRING  COMMENT  '投资目的',
  C_INVESTHIGHEST  STRING  COMMENT  '投资最高金额',
  C_INVESTAFFECT  STRING  COMMENT  '投资影响',
  C_CAPITALSOURCE  STRING  COMMENT  '资金来源',
  C_RISKENDURE  STRING  COMMENT  '承受风险承担',
  C_EXPECTRESPOND  STRING  COMMENT  '期望回报',
  C_DUTY  STRING  COMMENT  '职位',
  VC_QUESTIONARYDATE  STRING  COMMENT  '问卷日期',
  VC_FIRSTNAME  STRING  COMMENT  '英文名',
  VC_LASTNAME  STRING  COMMENT  '英文姓',
  C_EMPLOYEENUM  STRING  COMMENT  '企业员工数量',
  C_INTEREST  STRING  COMMENT  '',
  VC_NATIONALITY  STRING  COMMENT  '国籍',
  VC_IDVALIDATE  STRING  COMMENT  '开户证件有效期',
  VC_ORGANIZATIONNO  STRING  COMMENT  '组织机构代码',
  VC_TAXNO  STRING  COMMENT  '税务登记证号码',
  VC_INSTREPRVALIDATE  STRING  COMMENT  '法人证件有效期',
  C_AGEFLAG  STRING  COMMENT  '年龄标志',
  VC_WARRANTYVALIDATE  STRING  COMMENT  '授权委托书有效期',
  C_AMLRISKTYPE  STRING  COMMENT  '反洗钱风险类型',
  VC_ORNOVALIDATE  STRING  COMMENT  '组织代码证有效期',
  C_QUALIFICATIONTYPE  STRING  COMMENT  '资格证书类型',
  VC_QUALIFICATIONNO  STRING  COMMENT  '资格证书号码',
  VC_QUALIFICATIONVALIDATE  STRING  COMMENT  '资格证书有效期',
  VC_HOLDINGNAME  STRING  COMMENT  '控股股东名称',
  C_HOLDINGIDTYPE  STRING  COMMENT  '控股股东证件类型',
  VC_HOLDINGIDNO  STRING  COMMENT  '控股股东证件号码',
  VC_HOLDINGIDVALIDATE  STRING  COMMENT  '控股股东证件有效期',
  VC_HOLDINGORNO  STRING  COMMENT  '控股股东组织代码证号码',
  VC_HOLDINGTAXNO  STRING  COMMENT  '控股股东税务登记证号码',
  C_TRUSTINESS  STRING  COMMENT  '授信客户标识',
  VC_CHECKIDVALIDATE  STRING  COMMENT  '开户证件年检有效期',
  VC_AMLEXPLAIN  STRING  COMMENT  '反洗钱备注',
  VC_REGADDRESS  STRING  COMMENT  '注册地址',
  C_HOLDINGTYPE  STRING  COMMENT  '控股股东类别',
  C_SLEEPFLAG  STRING  COMMENT  '',
  VC_ORGHOLDINGNAME  STRING  COMMENT  '',
  VC_TAXBODIES  STRING  COMMENT  '',
  C_OPENFAREFLAG  STRING  COMMENT  '',
  C_FIRSTTRADEFLAG  STRING  COMMENT  '',
  C_SELFCLEARPASSWD  STRING  COMMENT  '',
  VC_SUMMARY  STRING  COMMENT  '',
  VC_SIGNCARDSTARTDATE  STRING  COMMENT  '',
  EN_REGISTCAPITAL  DECIMAL(16,2)  COMMENT  '',
  C_NETCHECKFLAG  STRING  COMMENT  '',
  VC_AGREEMENTSIGNSTATE  STRING  COMMENT  '',
  VC_OPENDATE  STRING  COMMENT  '',
  VC_LASTDATE  STRING  COMMENT  '',
  C_EMONEYFUNDFLAG  STRING  COMMENT  '',
  VC_EXTCUSTNO  STRING  COMMENT  '',
  VC_FULLCUSTOMNAME  STRING  COMMENT  '',
  C_NETSHOWDESTROYACCO  STRING  COMMENT  '',
  VC_ORGANNO  STRING  COMMENT  '',
  C_PHONEVERIFY  STRING  COMMENT  '',
  C_CUSTLEVEL  STRING  COMMENT  '',
  VC_CUSTENGLISHNAME  STRING  COMMENT  '',
  VC_IDENTITYNOEIGHTEEN  STRING  COMMENT  '',
  VC_EXTCOMPANY  STRING  COMMENT  '',
  VC_OFFICEDUTY  STRING  COMMENT  '',
  C_MONEYSOURCE  STRING  COMMENT  '',
  VC_BIRTHPLACE  STRING  COMMENT  '',
  C_INCOMESOURCE  STRING  COMMENT  '',
  C_NORTHAMERICAN  STRING  COMMENT  '',
  C_TRADEKIND  STRING  COMMENT  '',
  C_ASSETSIZE  STRING  COMMENT  '',
  C_ACUTALBUSINRANGE  STRING  COMMENT  '',
  VC_TRUSTBENEFICIARYNAME  STRING  COMMENT  '',
  VC_TRUSTBENEFICIARYPHONE  STRING  COMMENT  '',
  VC_SMSFLAG  STRING  COMMENT  '',
  VC_ACCOUNTHOLDER  STRING  COMMENT  '',
  VC_CUSTCONSIGNEE  STRING  COMMENT  '',
  C_NOSURVEYFLAG  STRING  COMMENT  '',
  VC_ACCOMANAGER  STRING  COMMENT  '',
  VC_ACCOTGR  STRING  COMMENT  '',
  VC_KJZTCOMPANYNO  STRING  COMMENT  '',
  C_HGFLAG  STRING  COMMENT  '',
  VC_EFFECTDATE  STRING  COMMENT  '',
  VC_EFFECTENDDATE  STRING  COMMENT  '',
  VC_ICEMPNO  STRING  COMMENT  '',
  VC_ICEMPNAME  STRING  COMMENT  '',
  C_PROFESSIONFLAG  STRING  COMMENT  '',
  EN_CUSTFUNDTIMELIMIT  DECIMAL(5,0)  COMMENT  '',
  C_INSTREPRNTYPE  STRING  COMMENT  '',
  C_PUBPROFESSIONVALIDDATE  STRING  COMMENT  '',
  C_PUBPROFESSIONSUBTYPE  STRING  COMMENT  '',
  C_PUBPROFESSIONFLAG  STRING  COMMENT  '',
  C_PUBHGFLAG  STRING  COMMENT  '',
  VC_BADINTEGRITY  STRING  COMMENT  '',
  VC_BADINTEGRITYDESC  STRING  COMMENT  '',
  C_INVESTMENTVARIETIES  STRING  COMMENT  '',
  C_PREYIELDFLAG  STRING  COMMENT  '',
  VC_CUSTIDENTITYNAME  STRING  COMMENT  '',
  VC_TAXVALIDATE  STRING  COMMENT  '',
  C_AUTOBUYFUNDFLAG  STRING  COMMENT  '',
  VC_ORGANIZATIONNOBEGINDATE  STRING  COMMENT  '',
  VC_TAXBEGINDATE  STRING  COMMENT  '',
  VC_HOLDINGIDVALIBEGINDATE  STRING  COMMENT  '',
  VC_INSTREPRNOBEGINDATE  STRING  COMMENT  '',
  VC_INSTREPRPHONE  STRING  COMMENT  '',
  VC_CERTIFICATEUNIT  STRING  COMMENT  '',
  VC_BUSINMODE  STRING  COMMENT  '',
  C_LISTEDCOMPANYMODE  STRING  COMMENT  '',
  C_STATEOWNEDENTERPRISE  STRING  COMMENT  '',
  C_MONEYTYPE  STRING  COMMENT  '',
  C_ORGTYPE  STRING  COMMENT  '',
  VC_INSTREPRPOST  STRING  COMMENT  '',
  VC_INSTREPRBIRTHDAY  STRING  COMMENT  '',
  C_INSTREPRSEX  STRING  COMMENT  '',
  VC_INSTREPROFFICEZIP  STRING  COMMENT  '',
  VC_INSTREPROFFICEADDRESS  STRING  COMMENT  '',
  VC_SPECINFO  STRING  COMMENT  '',
  C_BENEFICIARYIDTYPE  STRING  COMMENT  '',
  VC_BENEFICIARYIDNO  STRING  COMMENT  '',
  VC_BENEFICIARYIDVALIDATE  STRING  COMMENT  '',
  C_HOLDIDENTITYTYPE  STRING  COMMENT  '',
  VC_HOLDIDENTITYNO  STRING  COMMENT  '',
  VC_HOLDIDVALIDATE  STRING  COMMENT  '',
  C_BENEFICIARYCUSTTYPE  STRING  COMMENT  '',
  C_HOLDIDENTITYCUSTTYPE  STRING  COMMENT  '',
  VC_CAPITALPROPERTY  STRING  COMMENT  '',
  VC_EQUITYCONTROLCOMPOSITION  STRING  COMMENT  '',
  C_CUSTINFOCOMPLETE  STRING  COMMENT  '',
  C_CUSTFUNDTIMELIMITFLAG  STRING  COMMENT  '',
  C_SCHGFLAG  STRING  COMMENT  '',
  VC_SCEFFECTDATE  STRING  COMMENT  '',
  VC_SCEFFECTENDDATE  STRING  COMMENT  '',
  VC_PRODUCTID  STRING  COMMENT  '',
  C_NONPERCUSTTYPE  STRING  COMMENT  '',
  VC_VOCATIONDETAIL  STRING  COMMENT  '',
  VC_OLDCUSTNO  STRING  COMMENT  '',
  VC_HOLDIDENTITYCUSTTYPE  STRING  COMMENT  '',
  VC_INVESTMANAGERCODE  STRING  COMMENT  '',
  C_ADMINTANCETYPE  STRING  COMMENT  '',
  VC_ADMINTANCEVALIDDATE  STRING  COMMENT  '',
  C_NOPASSWORD  STRING  COMMENT  '',
  C_SYNECIF  STRING  COMMENT  '',
  VC_ECIFNO  STRING  COMMENT  '',
  VC_TRUSTEENAME  STRING  COMMENT  '',
  VC_RELATEDMODIFYDATE  STRING  COMMENT  '',
  VC_RELATEDMODIFYTIME  STRING  COMMENT  '',
  VC_INVERSTNAME  STRING  COMMENT  '',
  VC_INSTREPRMOBILENO  STRING  COMMENT  '',
  VC_INSTREPREMAIL  STRING  COMMENT  '',
  C_PUBTPRIPROTOCOL  STRING  COMMENT  '',
  VC_LONGREGADDRESS  STRING  COMMENT  '',
  VC_PROFFICEADDRESS  STRING  COMMENT  '',
  VC_INVESTACCO  STRING  COMMENT  '',
  C_ANNUITIESFLAG  STRING  COMMENT  '',
  C_INTERNALACCOFLAG  STRING  COMMENT  '',
  VC_OTHERACCOMANAGER  STRING  COMMENT  '',
  C_REGISTMONEYTYPE  STRING  COMMENT  '',
  VC_HOLDINGPHONE  STRING  COMMENT  '',
  VC_HOLDINGEMAIL  STRING  COMMENT  '',
  VC_HOLDIDPHONE  STRING  COMMENT  '',
  VC_HOLDIDEMAIL  STRING  COMMENT  '',
  C_ASSISTIDTYPE  STRING  COMMENT  '',
  VC_ASSISTIDNO  STRING  COMMENT  '',
  VC_ASSISTIDVALIDATE  STRING  COMMENT  '',
  VC_INDUSTRYDETAIL  STRING  COMMENT  '',
  VC_AMLSYNCDATE  STRING  COMMENT  '',
  C_MYSELFISBFCY  STRING  COMMENT  '',
  C_MYSELFISCONTORLER  STRING  COMMENT  '',
  C_HOLDINGRELATION  STRING  COMMENT  '',
  C_BENEFICIARYRELATION  STRING  COMMENT  '',
  VC_BENEFICIARYADDRESS  STRING  COMMENT  '',
  VC_HOLDINGNAMEADDRESS  STRING  COMMENT  '',
  VC_INSTREPRNATION  STRING  COMMENT  '',
  VC_NAMEOFACCOUNTBELONGS  STRING  COMMENT  '',
  VC_ADMINTANCEBEGINDATE  STRING  COMMENT  '',
  C_DUEDILIGENCE  STRING  COMMENT  '',
  C_NETSIGNCONTRACTONLY  STRING  COMMENT  '',
  C_INCOME  STRING  COMMENT  '',
  VC_ENCRYPTCLASSNAME  STRING  COMMENT  '',
  VC_FINANCIALADVISOR  STRING  COMMENT  '',
  VC_FINANCIALPLANNER  STRING  COMMENT  '',
  VC_FINANCIALCHANNEL  STRING  COMMENT  '',
  VC_REFERRALCODE  STRING  COMMENT  '',
  C_ISOWNER  STRING  COMMENT  '',
  VC_PARKNO  STRING  COMMENT  '',
  C_COMPANYMAJORINCOME  STRING  COMMENT  '',
  C_COMPANYASSETSIZE  STRING  COMMENT  '',
  C_COMPANYINCOME  STRING  COMMENT  '',
  C_COMPANYECURITYASSET  STRING  COMMENT  '',
  C_COMPANYDEBT  STRING  COMMENT  '',
  VC_OCRADDRESS  STRING  COMMENT  '',
  C_ACTUALFLAG  STRING  COMMENT  '',
  VC_ACTUALRELATYPE  STRING  COMMENT  '',
  VC_ACTUALEXPLAIN  STRING  COMMENT  '',
  C_SXGFLAG  STRING  COMMENT  '',
  C_NESTACCOTYPE  STRING  COMMENT  '',
  C_HOLDINANDBENEFICIARYINFO  STRING  COMMENT  '',
  VC_CIP  STRING  COMMENT  '',
  C_IDSTATUS  STRING  COMMENT  ''
)
COMMENT '客户资料表'
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
              "querySql": ["SELECT  VC_CUSTNO\n                                   , C_CUSTTYPE\n                                   , VC_CUSTOMNAME\n                                   , VC_SHORTNAME\n                                   , C_IDENTITYTYPE\n                                   , VC_IDENTITYNO\n                                   , C_MODIFYFLAG\n                                   , VC_INSTREPRNAME\n                                   , C_INSTREPRTYPE\n                                   , VC_INSTREPRNO\n                                   , C_TRADE\n                                   , C_CORPROPERTIY\n                                   , C_REGISTCAPITAL\n                                   , C_VOCATION\n                                   , C_EDUCATION\n                                   , L_INCOME\n                                   , C_SEX\n                                   , C_MARRIAGE\n                                   , VC_BIRTHDAY\n                                   , C_INVEST\n                                   , VC_SZACCO\n                                   , VC_SHACCO\n                                   , C_STATE\n                                   , VC_SPELL\n                                   , C_WORKTIME\n                                   , C_INVESTEXP\n                                   , C_INVESTYEARS\n                                   , C_INVESTASSETS\n                                   , C_INVESTTOOLS\n                                   , C_INVESTWHYS\n                                   , C_INVESTHIGHEST\n                                   , C_INVESTAFFECT\n                                   , C_CAPITALSOURCE\n                                   , C_RISKENDURE\n                                   , C_EXPECTRESPOND\n                                   , C_DUTY\n                                   , VC_QUESTIONARYDATE\n                                   , VC_FIRSTNAME\n                                   , VC_LASTNAME\n                                   , C_EMPLOYEENUM\n                                   , C_INTEREST\n                                   , VC_NATIONALITY\n                                   , VC_IDVALIDATE\n                                   , VC_ORGANIZATIONNO\n                                   , VC_TAXNO\n                                   , VC_INSTREPRVALIDATE\n                                   , C_AGEFLAG\n                                   , VC_WARRANTYVALIDATE\n                                   , C_AMLRISKTYPE\n                                   , VC_ORNOVALIDATE\n                                   , C_QUALIFICATIONTYPE\n                                   , VC_QUALIFICATIONNO\n                                   , VC_QUALIFICATIONVALIDATE\n                                   , VC_HOLDINGNAME\n                                   , C_HOLDINGIDTYPE\n                                   , VC_HOLDINGIDNO\n                                   , VC_HOLDINGIDVALIDATE\n                                   , VC_HOLDINGORNO\n                                   , VC_HOLDINGTAXNO\n                                   , C_TRUSTINESS\n                                   , VC_CHECKIDVALIDATE\n                                   , VC_AMLEXPLAIN\n                                   , VC_REGADDRESS\n                                   , C_HOLDINGTYPE\n                                   , C_SLEEPFLAG\n                                   , VC_ORGHOLDINGNAME\n                                   , VC_TAXBODIES\n                                   , C_OPENFAREFLAG\n                                   , C_FIRSTTRADEFLAG\n                                   , C_SELFCLEARPASSWD\n                                   , VC_SUMMARY\n                                   , VC_SIGNCARDSTARTDATE\n                                   , EN_REGISTCAPITAL\n                                   , C_NETCHECKFLAG\n                                   , VC_AGREEMENTSIGNSTATE\n                                   , VC_OPENDATE\n                                   , VC_LASTDATE\n                                   , C_EMONEYFUNDFLAG\n                                   , VC_EXTCUSTNO\n                                   , VC_FULLCUSTOMNAME\n                                   , C_NETSHOWDESTROYACCO\n                                   , VC_ORGANNO\n                                   , C_PHONEVERIFY\n                                   , C_CUSTLEVEL\n                                   , VC_CUSTENGLISHNAME\n                                   , VC_IDENTITYNOEIGHTEEN\n                                   , VC_EXTCOMPANY\n                                   , VC_OFFICEDUTY\n                                   , C_MONEYSOURCE\n                                   , VC_BIRTHPLACE\n                                   , C_INCOMESOURCE\n                                   , C_NORTHAMERICAN\n                                   , C_TRADEKIND\n                                   , C_ASSETSIZE\n                                   , C_ACUTALBUSINRANGE\n                                   , VC_TRUSTBENEFICIARYNAME\n                                   , VC_TRUSTBENEFICIARYPHONE\n                                   , VC_SMSFLAG\n                                   , VC_ACCOUNTHOLDER\n                                   , VC_CUSTCONSIGNEE\n                                   , C_NOSURVEYFLAG\n                                   , VC_ACCOMANAGER\n                                   , VC_ACCOTGR\n                                   , VC_KJZTCOMPANYNO\n                                   , C_HGFLAG\n                                   , VC_EFFECTDATE\n                                   , VC_EFFECTENDDATE\n                                   , VC_ICEMPNO\n                                   , VC_ICEMPNAME\n                                   , C_PROFESSIONFLAG\n                                   , EN_CUSTFUNDTIMELIMIT\n                                   , C_INSTREPRNTYPE\n                                   , C_PUBPROFESSIONVALIDDATE\n                                   , C_PUBPROFESSIONSUBTYPE\n                                   , C_PUBPROFESSIONFLAG\n                                   , C_PUBHGFLAG\n                                   , VC_BADINTEGRITY\n                                   , VC_BADINTEGRITYDESC\n                                   , C_INVESTMENTVARIETIES\n                                   , C_PREYIELDFLAG\n                                   , VC_CUSTIDENTITYNAME\n                                   , VC_TAXVALIDATE\n                                   , C_AUTOBUYFUNDFLAG\n                                   , VC_ORGANIZATIONNOBEGINDATE\n                                   , VC_TAXBEGINDATE\n                                   , VC_HOLDINGIDVALIBEGINDATE\n                                   , VC_INSTREPRNOBEGINDATE\n                                   , VC_INSTREPRPHONE\n                                   , VC_CERTIFICATEUNIT\n                                   , VC_BUSINMODE\n                                   , C_LISTEDCOMPANYMODE\n                                   , C_STATEOWNEDENTERPRISE\n                                   , C_MONEYTYPE\n                                   , C_ORGTYPE\n                                   , VC_INSTREPRPOST\n                                   , VC_INSTREPRBIRTHDAY\n                                   , C_INSTREPRSEX\n                                   , VC_INSTREPROFFICEZIP\n                                   , VC_INSTREPROFFICEADDRESS\n                                   , VC_SPECINFO\n                                   , C_BENEFICIARYIDTYPE\n                                   , VC_BENEFICIARYIDNO\n                                   , VC_BENEFICIARYIDVALIDATE\n                                   , C_HOLDIDENTITYTYPE\n                                   , VC_HOLDIDENTITYNO\n                                   , VC_HOLDIDVALIDATE\n                                   , C_BENEFICIARYCUSTTYPE\n                                   , C_HOLDIDENTITYCUSTTYPE\n                                   , VC_CAPITALPROPERTY\n                                   , VC_EQUITYCONTROLCOMPOSITION\n                                   , C_CUSTINFOCOMPLETE\n                                   , C_CUSTFUNDTIMELIMITFLAG\n                                   , C_SCHGFLAG\n                                   , VC_SCEFFECTDATE\n                                   , VC_SCEFFECTENDDATE\n                                   , VC_PRODUCTID\n                                   , C_NONPERCUSTTYPE\n                                   , VC_VOCATIONDETAIL\n                                   , VC_OLDCUSTNO\n                                   , VC_HOLDIDENTITYCUSTTYPE\n                                   , VC_INVESTMANAGERCODE\n                                   , C_ADMINTANCETYPE\n                                   , VC_ADMINTANCEVALIDDATE\n                                   , C_NOPASSWORD\n                                   , C_SYNECIF\n                                   , VC_ECIFNO\n                                   , VC_TRUSTEENAME\n                                   , VC_RELATEDMODIFYDATE\n                                   , VC_RELATEDMODIFYTIME\n                                   , VC_INVERSTNAME\n                                   , VC_INSTREPRMOBILENO\n                                   , VC_INSTREPREMAIL\n                                   , C_PUBTPRIPROTOCOL\n                                   , VC_LONGREGADDRESS\n                                   , VC_PROFFICEADDRESS\n                                   , VC_INVESTACCO\n                                   , C_ANNUITIESFLAG\n                                   , C_INTERNALACCOFLAG\n                                   , VC_OTHERACCOMANAGER\n                                   , C_REGISTMONEYTYPE\n                                   , VC_HOLDINGPHONE\n                                   , VC_HOLDINGEMAIL\n                                   , VC_HOLDIDPHONE\n                                   , VC_HOLDIDEMAIL\n                                   , C_ASSISTIDTYPE\n                                   , VC_ASSISTIDNO\n                                   , VC_ASSISTIDVALIDATE\n                                   , VC_INDUSTRYDETAIL\n                                   , VC_AMLSYNCDATE\n                                   , C_MYSELFISBFCY\n                                   , C_MYSELFISCONTORLER\n                                   , C_HOLDINGRELATION\n                                   , C_BENEFICIARYRELATION\n                                   , VC_BENEFICIARYADDRESS\n                                   , VC_HOLDINGNAMEADDRESS\n                                   , VC_INSTREPRNATION\n                                   , VC_NAMEOFACCOUNTBELONGS\n                                   , VC_ADMINTANCEBEGINDATE\n                                   , C_DUEDILIGENCE\n                                   , C_NETSIGNCONTRACTONLY\n                                   , C_INCOME\n                                   , VC_ENCRYPTCLASSNAME\n                                   , VC_FINANCIALADVISOR\n                                   , VC_FINANCIALPLANNER\n                                   , VC_FINANCIALCHANNEL\n                                   , VC_REFERRALCODE\n                                   , C_ISOWNER\n                                   , VC_PARKNO\n                                   , C_COMPANYMAJORINCOME\n                                   , C_COMPANYASSETSIZE\n                                   , C_COMPANYINCOME\n                                   , C_COMPANYECURITYASSET\n                                   , C_COMPANYDEBT\n                                   , VC_OCRADDRESS\n                                   , C_ACTUALFLAG\n                                   , VC_ACTUALRELATYPE\n                                   , VC_ACTUALEXPLAIN\n                                   , C_SXGFLAG\n                                   , C_NESTACCOTYPE\n                                   , C_HOLDINANDBENEFICIARYINFO\n                                   , VC_CIP\n                                   , C_IDSTATUS\n                                FROM ${hsds_src_schema}.TCUSTINFO"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_CUSTNO", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "VC_CUSTOMNAME", "type": "STRING"}, {"name": "VC_SHORTNAME", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "VC_IDENTITYNO", "type": "STRING"}, {"name": "C_MODIFYFLAG", "type": "STRING"}, {"name": "VC_INSTREPRNAME", "type": "STRING"}, {"name": "C_INSTREPRTYPE", "type": "STRING"}, {"name": "VC_INSTREPRNO", "type": "STRING"}, {"name": "C_TRADE", "type": "STRING"}, {"name": "C_CORPROPERTIY", "type": "STRING"}, {"name": "C_REGISTCAPITAL", "type": "STRING"}, {"name": "C_VOCATION", "type": "STRING"}, {"name": "C_EDUCATION", "type": "STRING"}, {"name": "L_INCOME", "type": "DOUBLE"}, {"name": "C_SEX", "type": "STRING"}, {"name": "C_MARRIAGE", "type": "STRING"}, {"name": "VC_BIRTHDAY", "type": "STRING"}, {"name": "C_INVEST", "type": "STRING"}, {"name": "VC_SZACCO", "type": "STRING"}, {"name": "VC_SHACCO", "type": "STRING"}, {"name": "C_STATE", "type": "STRING"}, {"name": "VC_SPELL", "type": "STRING"}, {"name": "C_WORKTIME", "type": "STRING"}, {"name": "C_INVESTEXP", "type": "STRING"}, {"name": "C_INVESTYEARS", "type": "STRING"}, {"name": "C_INVESTASSETS", "type": "STRING"}, {"name": "C_INVESTTOOLS", "type": "STRING"}, {"name": "C_INVESTWHYS", "type": "STRING"}, {"name": "C_INVESTHIGHEST", "type": "STRING"}, {"name": "C_INVESTAFFECT", "type": "STRING"}, {"name": "C_CAPITALSOURCE", "type": "STRING"}, {"name": "C_RISKENDURE", "type": "STRING"}, {"name": "C_EXPECTRESPOND", "type": "STRING"}, {"name": "C_DUTY", "type": "STRING"}, {"name": "VC_QUESTIONARYDATE", "type": "STRING"}, {"name": "VC_FIRSTNAME", "type": "STRING"}, {"name": "VC_LASTNAME", "type": "STRING"}, {"name": "C_EMPLOYEENUM", "type": "STRING"}, {"name": "C_INTEREST", "type": "STRING"}, {"name": "VC_NATIONALITY", "type": "STRING"}, {"name": "VC_IDVALIDATE", "type": "STRING"}, {"name": "VC_ORGANIZATIONNO", "type": "STRING"}, {"name": "VC_TAXNO", "type": "STRING"}, {"name": "VC_INSTREPRVALIDATE", "type": "STRING"}, {"name": "C_AGEFLAG", "type": "STRING"}, {"name": "VC_WARRANTYVALIDATE", "type": "STRING"}, {"name": "C_AMLRISKTYPE", "type": "STRING"}, {"name": "VC_ORNOVALIDATE", "type": "STRING"}, {"name": "C_QUALIFICATIONTYPE", "type": "STRING"}, {"name": "VC_QUALIFICATIONNO", "type": "STRING"}, {"name": "VC_QUALIFICATIONVALIDATE", "type": "STRING"}, {"name": "VC_HOLDINGNAME", "type": "STRING"}, {"name": "C_HOLDINGIDTYPE", "type": "STRING"}, {"name": "VC_HOLDINGIDNO", "type": "STRING"}, {"name": "VC_HOLDINGIDVALIDATE", "type": "STRING"}, {"name": "VC_HOLDINGORNO", "type": "STRING"}, {"name": "VC_HOLDINGTAXNO", "type": "STRING"}, {"name": "C_TRUSTINESS", "type": "STRING"}, {"name": "VC_CHECKIDVALIDATE", "type": "STRING"}, {"name": "VC_AMLEXPLAIN", "type": "STRING"}, {"name": "VC_REGADDRESS", "type": "STRING"}, {"name": "C_HOLDINGTYPE", "type": "STRING"}, {"name": "C_SLEEPFLAG", "type": "STRING"}, {"name": "VC_ORGHOLDINGNAME", "type": "STRING"}, {"name": "VC_TAXBODIES", "type": "STRING"}, {"name": "C_OPENFAREFLAG", "type": "STRING"}, {"name": "C_FIRSTTRADEFLAG", "type": "STRING"}, {"name": "C_SELFCLEARPASSWD", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "VC_SIGNCARDSTARTDATE", "type": "STRING"}, {"name": "EN_REGISTCAPITAL", "type": "DOUBLE"}, {"name": "C_NETCHECKFLAG", "type": "STRING"}, {"name": "VC_AGREEMENTSIGNSTATE", "type": "STRING"}, {"name": "VC_OPENDATE", "type": "STRING"}, {"name": "VC_LASTDATE", "type": "STRING"}, {"name": "C_EMONEYFUNDFLAG", "type": "STRING"}, {"name": "VC_EXTCUSTNO", "type": "STRING"}, {"name": "VC_FULLCUSTOMNAME", "type": "STRING"}, {"name": "C_NETSHOWDESTROYACCO", "type": "STRING"}, {"name": "VC_ORGANNO", "type": "STRING"}, {"name": "C_PHONEVERIFY", "type": "STRING"}, {"name": "C_CUSTLEVEL", "type": "STRING"}, {"name": "VC_CUSTENGLISHNAME", "type": "STRING"}, {"name": "VC_IDENTITYNOEIGHTEEN", "type": "STRING"}, {"name": "VC_EXTCOMPANY", "type": "STRING"}, {"name": "VC_OFFICEDUTY", "type": "STRING"}, {"name": "C_MONEYSOURCE", "type": "STRING"}, {"name": "VC_BIRTHPLACE", "type": "STRING"}, {"name": "C_INCOMESOURCE", "type": "STRING"}, {"name": "C_NORTHAMERICAN", "type": "STRING"}, {"name": "C_TRADEKIND", "type": "STRING"}, {"name": "C_ASSETSIZE", "type": "STRING"}, {"name": "C_ACUTALBUSINRANGE", "type": "STRING"}, {"name": "VC_TRUSTBENEFICIARYNAME", "type": "STRING"}, {"name": "VC_TRUSTBENEFICIARYPHONE", "type": "STRING"}, {"name": "VC_SMSFLAG", "type": "STRING"}, {"name": "VC_ACCOUNTHOLDER", "type": "STRING"}, {"name": "VC_CUSTCONSIGNEE", "type": "STRING"}, {"name": "C_NOSURVEYFLAG", "type": "STRING"}, {"name": "VC_ACCOMANAGER", "type": "STRING"}, {"name": "VC_ACCOTGR", "type": "STRING"}, {"name": "VC_KJZTCOMPANYNO", "type": "STRING"}, {"name": "C_HGFLAG", "type": "STRING"}, {"name": "VC_EFFECTDATE", "type": "STRING"}, {"name": "VC_EFFECTENDDATE", "type": "STRING"}, {"name": "VC_ICEMPNO", "type": "STRING"}, {"name": "VC_ICEMPNAME", "type": "STRING"}, {"name": "C_PROFESSIONFLAG", "type": "STRING"}, {"name": "EN_CUSTFUNDTIMELIMIT", "type": "DOUBLE"}, {"name": "C_INSTREPRNTYPE", "type": "STRING"}, {"name": "C_PUBPROFESSIONVALIDDATE", "type": "STRING"}, {"name": "C_PUBPROFESSIONSUBTYPE", "type": "STRING"}, {"name": "C_PUBPROFESSIONFLAG", "type": "STRING"}, {"name": "C_PUBHGFLAG", "type": "STRING"}, {"name": "VC_BADINTEGRITY", "type": "STRING"}, {"name": "VC_BADINTEGRITYDESC", "type": "STRING"}, {"name": "C_INVESTMENTVARIETIES", "type": "STRING"}, {"name": "C_PREYIELDFLAG", "type": "STRING"}, {"name": "VC_CUSTIDENTITYNAME", "type": "STRING"}, {"name": "VC_TAXVALIDATE", "type": "STRING"}, {"name": "C_AUTOBUYFUNDFLAG", "type": "STRING"}, {"name": "VC_ORGANIZATIONNOBEGINDATE", "type": "STRING"}, {"name": "VC_TAXBEGINDATE", "type": "STRING"}, {"name": "VC_HOLDINGIDVALIBEGINDATE", "type": "STRING"}, {"name": "VC_INSTREPRNOBEGINDATE", "type": "STRING"}, {"name": "VC_INSTREPRPHONE", "type": "STRING"}, {"name": "VC_CERTIFICATEUNIT", "type": "STRING"}, {"name": "VC_BUSINMODE", "type": "STRING"}, {"name": "C_LISTEDCOMPANYMODE", "type": "STRING"}, {"name": "C_STATEOWNEDENTERPRISE", "type": "STRING"}, {"name": "C_MONEYTYPE", "type": "STRING"}, {"name": "C_ORGTYPE", "type": "STRING"}, {"name": "VC_INSTREPRPOST", "type": "STRING"}, {"name": "VC_INSTREPRBIRTHDAY", "type": "STRING"}, {"name": "C_INSTREPRSEX", "type": "STRING"}, {"name": "VC_INSTREPROFFICEZIP", "type": "STRING"}, {"name": "VC_INSTREPROFFICEADDRESS", "type": "STRING"}, {"name": "VC_SPECINFO", "type": "STRING"}, {"name": "C_BENEFICIARYIDTYPE", "type": "STRING"}, {"name": "VC_BENEFICIARYIDNO", "type": "STRING"}, {"name": "VC_BENEFICIARYIDVALIDATE", "type": "STRING"}, {"name": "C_HOLDIDENTITYTYPE", "type": "STRING"}, {"name": "VC_HOLDIDENTITYNO", "type": "STRING"}, {"name": "VC_HOLDIDVALIDATE", "type": "STRING"}, {"name": "C_BENEFICIARYCUSTTYPE", "type": "STRING"}, {"name": "C_HOLDIDENTITYCUSTTYPE", "type": "STRING"}, {"name": "VC_CAPITALPROPERTY", "type": "STRING"}, {"name": "VC_EQUITYCONTROLCOMPOSITION", "type": "STRING"}, {"name": "C_CUSTINFOCOMPLETE", "type": "STRING"}, {"name": "C_CUSTFUNDTIMELIMITFLAG", "type": "STRING"}, {"name": "C_SCHGFLAG", "type": "STRING"}, {"name": "VC_SCEFFECTDATE", "type": "STRING"}, {"name": "VC_SCEFFECTENDDATE", "type": "STRING"}, {"name": "VC_PRODUCTID", "type": "STRING"}, {"name": "C_NONPERCUSTTYPE", "type": "STRING"}, {"name": "VC_VOCATIONDETAIL", "type": "STRING"}, {"name": "VC_OLDCUSTNO", "type": "STRING"}, {"name": "VC_HOLDIDENTITYCUSTTYPE", "type": "STRING"}, {"name": "VC_INVESTMANAGERCODE", "type": "STRING"}, {"name": "C_ADMINTANCETYPE", "type": "STRING"}, {"name": "VC_ADMINTANCEVALIDDATE", "type": "STRING"}, {"name": "C_NOPASSWORD", "type": "STRING"}, {"name": "C_SYNECIF", "type": "STRING"}, {"name": "VC_ECIFNO", "type": "STRING"}, {"name": "VC_TRUSTEENAME", "type": "STRING"}, {"name": "VC_RELATEDMODIFYDATE", "type": "STRING"}, {"name": "VC_RELATEDMODIFYTIME", "type": "STRING"}, {"name": "VC_INVERSTNAME", "type": "STRING"}, {"name": "VC_INSTREPRMOBILENO", "type": "STRING"}, {"name": "VC_INSTREPREMAIL", "type": "STRING"}, {"name": "C_PUBTPRIPROTOCOL", "type": "STRING"}, {"name": "VC_LONGREGADDRESS", "type": "STRING"}, {"name": "VC_PROFFICEADDRESS", "type": "STRING"}, {"name": "VC_INVESTACCO", "type": "STRING"}, {"name": "C_ANNUITIESFLAG", "type": "STRING"}, {"name": "C_INTERNALACCOFLAG", "type": "STRING"}, {"name": "VC_OTHERACCOMANAGER", "type": "STRING"}, {"name": "C_REGISTMONEYTYPE", "type": "STRING"}, {"name": "VC_HOLDINGPHONE", "type": "STRING"}, {"name": "VC_HOLDINGEMAIL", "type": "STRING"}, {"name": "VC_HOLDIDPHONE", "type": "STRING"}, {"name": "VC_HOLDIDEMAIL", "type": "STRING"}, {"name": "C_ASSISTIDTYPE", "type": "STRING"}, {"name": "VC_ASSISTIDNO", "type": "STRING"}, {"name": "VC_ASSISTIDVALIDATE", "type": "STRING"}, {"name": "VC_INDUSTRYDETAIL", "type": "STRING"}, {"name": "VC_AMLSYNCDATE", "type": "STRING"}, {"name": "C_MYSELFISBFCY", "type": "STRING"}, {"name": "C_MYSELFISCONTORLER", "type": "STRING"}, {"name": "C_HOLDINGRELATION", "type": "STRING"}, {"name": "C_BENEFICIARYRELATION", "type": "STRING"}, {"name": "VC_BENEFICIARYADDRESS", "type": "STRING"}, {"name": "VC_HOLDINGNAMEADDRESS", "type": "STRING"}, {"name": "VC_INSTREPRNATION", "type": "STRING"}, {"name": "VC_NAMEOFACCOUNTBELONGS", "type": "STRING"}, {"name": "VC_ADMINTANCEBEGINDATE", "type": "STRING"}, {"name": "C_DUEDILIGENCE", "type": "STRING"}, {"name": "C_NETSIGNCONTRACTONLY", "type": "STRING"}, {"name": "C_INCOME", "type": "STRING"}, {"name": "VC_ENCRYPTCLASSNAME", "type": "STRING"}, {"name": "VC_FINANCIALADVISOR", "type": "STRING"}, {"name": "VC_FINANCIALPLANNER", "type": "STRING"}, {"name": "VC_FINANCIALCHANNEL", "type": "STRING"}, {"name": "VC_REFERRALCODE", "type": "STRING"}, {"name": "C_ISOWNER", "type": "STRING"}, {"name": "VC_PARKNO", "type": "STRING"}, {"name": "C_COMPANYMAJORINCOME", "type": "STRING"}, {"name": "C_COMPANYASSETSIZE", "type": "STRING"}, {"name": "C_COMPANYINCOME", "type": "STRING"}, {"name": "C_COMPANYECURITYASSET", "type": "STRING"}, {"name": "C_COMPANYDEBT", "type": "STRING"}, {"name": "VC_OCRADDRESS", "type": "STRING"}, {"name": "C_ACTUALFLAG", "type": "STRING"}, {"name": "VC_ACTUALRELATYPE", "type": "STRING"}, {"name": "VC_ACTUALEXPLAIN", "type": "STRING"}, {"name": "C_SXGFLAG", "type": "STRING"}, {"name": "C_NESTACCOTYPE", "type": "STRING"}, {"name": "C_HOLDINANDBENEFICIARYINFO", "type": "STRING"}, {"name": "VC_CIP", "type": "STRING"}, {"name": "C_IDSTATUS", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_tcustinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_tcustinfo_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_tcustinfo_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_tcustinfo_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TCUSTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TCUSTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_tcustinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_CUSTNO
     , C_CUSTTYPE
     , VC_CUSTOMNAME
     , VC_SHORTNAME
     , C_IDENTITYTYPE
     , VC_IDENTITYNO
     , C_MODIFYFLAG
     , VC_INSTREPRNAME
     , C_INSTREPRTYPE
     , VC_INSTREPRNO
     , C_TRADE
     , C_CORPROPERTIY
     , C_REGISTCAPITAL
     , C_VOCATION
     , C_EDUCATION
     , L_INCOME
     , C_SEX
     , C_MARRIAGE
     , VC_BIRTHDAY
     , C_INVEST
     , VC_SZACCO
     , VC_SHACCO
     , C_STATE
     , VC_SPELL
     , C_WORKTIME
     , C_INVESTEXP
     , C_INVESTYEARS
     , C_INVESTASSETS
     , C_INVESTTOOLS
     , C_INVESTWHYS
     , C_INVESTHIGHEST
     , C_INVESTAFFECT
     , C_CAPITALSOURCE
     , C_RISKENDURE
     , C_EXPECTRESPOND
     , C_DUTY
     , VC_QUESTIONARYDATE
     , VC_FIRSTNAME
     , VC_LASTNAME
     , C_EMPLOYEENUM
     , C_INTEREST
     , VC_NATIONALITY
     , VC_IDVALIDATE
     , VC_ORGANIZATIONNO
     , VC_TAXNO
     , VC_INSTREPRVALIDATE
     , C_AGEFLAG
     , VC_WARRANTYVALIDATE
     , C_AMLRISKTYPE
     , VC_ORNOVALIDATE
     , C_QUALIFICATIONTYPE
     , VC_QUALIFICATIONNO
     , VC_QUALIFICATIONVALIDATE
     , VC_HOLDINGNAME
     , C_HOLDINGIDTYPE
     , VC_HOLDINGIDNO
     , VC_HOLDINGIDVALIDATE
     , VC_HOLDINGORNO
     , VC_HOLDINGTAXNO
     , C_TRUSTINESS
     , VC_CHECKIDVALIDATE
     , VC_AMLEXPLAIN
     , VC_REGADDRESS
     , C_HOLDINGTYPE
     , C_SLEEPFLAG
     , VC_ORGHOLDINGNAME
     , VC_TAXBODIES
     , C_OPENFAREFLAG
     , C_FIRSTTRADEFLAG
     , C_SELFCLEARPASSWD
     , VC_SUMMARY
     , VC_SIGNCARDSTARTDATE
     , EN_REGISTCAPITAL
     , C_NETCHECKFLAG
     , VC_AGREEMENTSIGNSTATE
     , VC_OPENDATE
     , VC_LASTDATE
     , C_EMONEYFUNDFLAG
     , VC_EXTCUSTNO
     , VC_FULLCUSTOMNAME
     , C_NETSHOWDESTROYACCO
     , VC_ORGANNO
     , C_PHONEVERIFY
     , C_CUSTLEVEL
     , VC_CUSTENGLISHNAME
     , VC_IDENTITYNOEIGHTEEN
     , VC_EXTCOMPANY
     , VC_OFFICEDUTY
     , C_MONEYSOURCE
     , VC_BIRTHPLACE
     , C_INCOMESOURCE
     , C_NORTHAMERICAN
     , C_TRADEKIND
     , C_ASSETSIZE
     , C_ACUTALBUSINRANGE
     , VC_TRUSTBENEFICIARYNAME
     , VC_TRUSTBENEFICIARYPHONE
     , VC_SMSFLAG
     , VC_ACCOUNTHOLDER
     , VC_CUSTCONSIGNEE
     , C_NOSURVEYFLAG
     , VC_ACCOMANAGER
     , VC_ACCOTGR
     , VC_KJZTCOMPANYNO
     , C_HGFLAG
     , VC_EFFECTDATE
     , VC_EFFECTENDDATE
     , VC_ICEMPNO
     , VC_ICEMPNAME
     , C_PROFESSIONFLAG
     , EN_CUSTFUNDTIMELIMIT
     , C_INSTREPRNTYPE
     , C_PUBPROFESSIONVALIDDATE
     , C_PUBPROFESSIONSUBTYPE
     , C_PUBPROFESSIONFLAG
     , C_PUBHGFLAG
     , VC_BADINTEGRITY
     , VC_BADINTEGRITYDESC
     , C_INVESTMENTVARIETIES
     , C_PREYIELDFLAG
     , VC_CUSTIDENTITYNAME
     , VC_TAXVALIDATE
     , C_AUTOBUYFUNDFLAG
     , VC_ORGANIZATIONNOBEGINDATE
     , VC_TAXBEGINDATE
     , VC_HOLDINGIDVALIBEGINDATE
     , VC_INSTREPRNOBEGINDATE
     , VC_INSTREPRPHONE
     , VC_CERTIFICATEUNIT
     , VC_BUSINMODE
     , C_LISTEDCOMPANYMODE
     , C_STATEOWNEDENTERPRISE
     , C_MONEYTYPE
     , C_ORGTYPE
     , VC_INSTREPRPOST
     , VC_INSTREPRBIRTHDAY
     , C_INSTREPRSEX
     , VC_INSTREPROFFICEZIP
     , VC_INSTREPROFFICEADDRESS
     , VC_SPECINFO
     , C_BENEFICIARYIDTYPE
     , VC_BENEFICIARYIDNO
     , VC_BENEFICIARYIDVALIDATE
     , C_HOLDIDENTITYTYPE
     , VC_HOLDIDENTITYNO
     , VC_HOLDIDVALIDATE
     , C_BENEFICIARYCUSTTYPE
     , C_HOLDIDENTITYCUSTTYPE
     , VC_CAPITALPROPERTY
     , VC_EQUITYCONTROLCOMPOSITION
     , C_CUSTINFOCOMPLETE
     , C_CUSTFUNDTIMELIMITFLAG
     , C_SCHGFLAG
     , VC_SCEFFECTDATE
     , VC_SCEFFECTENDDATE
     , VC_PRODUCTID
     , C_NONPERCUSTTYPE
     , VC_VOCATIONDETAIL
     , VC_OLDCUSTNO
     , VC_HOLDIDENTITYCUSTTYPE
     , VC_INVESTMANAGERCODE
     , C_ADMINTANCETYPE
     , VC_ADMINTANCEVALIDDATE
     , C_NOPASSWORD
     , C_SYNECIF
     , VC_ECIFNO
     , VC_TRUSTEENAME
     , VC_RELATEDMODIFYDATE
     , VC_RELATEDMODIFYTIME
     , VC_INVERSTNAME
     , VC_INSTREPRMOBILENO
     , VC_INSTREPREMAIL
     , C_PUBTPRIPROTOCOL
     , VC_LONGREGADDRESS
     , VC_PROFFICEADDRESS
     , VC_INVESTACCO
     , C_ANNUITIESFLAG
     , C_INTERNALACCOFLAG
     , VC_OTHERACCOMANAGER
     , C_REGISTMONEYTYPE
     , VC_HOLDINGPHONE
     , VC_HOLDINGEMAIL
     , VC_HOLDIDPHONE
     , VC_HOLDIDEMAIL
     , C_ASSISTIDTYPE
     , VC_ASSISTIDNO
     , VC_ASSISTIDVALIDATE
     , VC_INDUSTRYDETAIL
     , VC_AMLSYNCDATE
     , C_MYSELFISBFCY
     , C_MYSELFISCONTORLER
     , C_HOLDINGRELATION
     , C_BENEFICIARYRELATION
     , VC_BENEFICIARYADDRESS
     , VC_HOLDINGNAMEADDRESS
     , VC_INSTREPRNATION
     , VC_NAMEOFACCOUNTBELONGS
     , VC_ADMINTANCEBEGINDATE
     , C_DUEDILIGENCE
     , C_NETSIGNCONTRACTONLY
     , C_INCOME
     , VC_ENCRYPTCLASSNAME
     , VC_FINANCIALADVISOR
     , VC_FINANCIALPLANNER
     , VC_FINANCIALCHANNEL
     , VC_REFERRALCODE
     , C_ISOWNER
     , VC_PARKNO
     , C_COMPANYMAJORINCOME
     , C_COMPANYASSETSIZE
     , C_COMPANYINCOME
     , C_COMPANYECURITYASSET
     , C_COMPANYDEBT
     , VC_OCRADDRESS
     , C_ACTUALFLAG
     , VC_ACTUALRELATYPE
     , VC_ACTUALEXPLAIN
     , C_SXGFLAG
     , C_NESTACCOTYPE
     , C_HOLDINANDBENEFICIARYINFO
     , VC_CIP
     , C_IDSTATUS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCUSTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TCUSTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TCUSTINFO_PFD成功"
      exit 0
   fi
fi
