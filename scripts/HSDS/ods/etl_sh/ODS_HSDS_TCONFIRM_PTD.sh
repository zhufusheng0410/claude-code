#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TCONFIRM_PTD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCONFIRM_PTD_TMP(
  C_CUSTTYPE  STRING  COMMENT  '客户类别',
  VC_FUNDACCO  STRING  COMMENT  '基金账号',
  VC_TRADEACCO  STRING  COMMENT  '交易账号',
  C_TRUST  STRING  COMMENT  '委托方式',
  VC_REQUESTDATE  STRING  COMMENT  '申请日期',
  VC_REQUESTNO  STRING  COMMENT  '申请编号',
  VC_CONFIRMNO  STRING  COMMENT  '确认编号',
  VC_CONFIRMDATE  STRING  COMMENT  '确认日期',
  VC_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  VC_NETNO  STRING  COMMENT  '网点',
  VC_CENTERNO  STRING  COMMENT  '分中心',
  EN_RATIO  DECIMAL(9,8)  COMMENT  '费率',
  EN_NAV  DECIMAL(16,8)  COMMENT  '净值',
  EN_PROFIT  DECIMAL(16,2)  COMMENT  '收益',
  C_BUSINFLAG  STRING  COMMENT  '业务代码',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '申请金额',
  EN_SHARE  DECIMAL(16,2)  COMMENT  '申请份额',
  EN_CONFIRMBALA  DECIMAL(16,2)  COMMENT  '确认金额',
  C_MONEYTYPE  STRING  COMMENT  '币种',
  EN_CONFIRMSHARE  DECIMAL(16,2)  COMMENT  '确认份额',
  EN_FARE  DECIMAL(16,2)  COMMENT  '手续费',
  EN_DEALFARE  DECIMAL(16,2)  COMMENT  '交易费',
  EN_TAFARE  DECIMAL(16,2)  COMMENT  '过户费',
  EN_AFTERFARE  DECIMAL(16,2)  COMMENT  '后手续费',
  EN_AGENCYFARE  DECIMAL(16,2)  COMMENT  '代理费',
  EN_STAMPTAX  DECIMAL(16,2)  COMMENT  '印花税',
  C_CONFIRMFLAG  STRING  COMMENT  '确认标志',
  VC_ERRORCODE  STRING  COMMENT  '失败代码',
  VC_ERRORCAUSE  STRING  COMMENT  '失败原因',
  C_VOUCHERFLAG  STRING  COMMENT  '凭证打印标志',
  EN_INTEREST  DECIMAL(16,2)  COMMENT  '利息',
  EN_INTERESTTAX  DECIMAL(16,2)  COMMENT  '利息税',
  C_ORGANIGER  STRING  COMMENT  '业务发起人',
  VC_OTHERACCO  STRING  COMMENT  '对方基金账号',
  VC_OTHERTRADEACCO  STRING  COMMENT  '对方交易账号',
  C_OTHERAGENCYNO  STRING  COMMENT  '对方销售商',
  VC_OTHERNETNO  STRING  COMMENT  '对方网点',
  VC_OTHERFUNDCODE  STRING  COMMENT  '对方基金代码',
  C_OTHERSHARETYPE  STRING  COMMENT  '对方份额类别',
  EN_UNFROZENBALA  DECIMAL(16,2)  COMMENT  '解冻红利',
  EN_RETURNFARE  DECIMAL(16,2)  COMMENT  '返还费用',
  EN_ORIGINFARE  DECIMAL(16,2)  COMMENT  '应收手续费',
  VC_BROKER  STRING  COMMENT  '经纪人',
  C_DIVIDENDMETHOD  STRING  COMMENT  '分红方式',
  C_FROZENCAUSE  STRING  COMMENT  '冻结原因',
  VC_ORIGINNO  STRING  COMMENT  '原申请编号',
  VC_CITYNO  STRING  COMMENT  '城市',
  VC_SELLER  STRING  COMMENT  '业务员',
  VC_TACODE  STRING  COMMENT  'ta代码',
  EN_DISCOUNT  DECIMAL(5,4)  COMMENT  '折扣费率',
  EN_INCOME  DECIMAL(16,2)  COMMENT  '未付收益',
  EN_INVESTINCOME  DECIMAL(16,2)  COMMENT  '兑付的未付收益',
  EN_INVESTSHARE  DECIMAL(16,2)  COMMENT  '兑付的份额',
  C_FINISHFLAG  STRING  COMMENT  '业务结束标志',
  C_CONFIRMSTATUS  STRING  COMMENT  '确认性质',
  C_INTERESTFLAG  STRING  COMMENT  '利息标志',
  EN_ENDDISCOUNT  DECIMAL(7,4)  COMMENT  '后收费折扣',
  EN_OTHERDISCOUNT  DECIMAL(5,4)  COMMENT  '补差费折扣',
  VC_LIQUIDATEDATE  STRING  COMMENT  '清算日期',
  C_SENDFLAG  STRING  COMMENT  '发送标志',
  VC_BRANCHCODE  STRING  COMMENT  '托管网点',
  C_FIXBUSINFLAG  STRING  COMMENT  '业务辅助代码',
  EN_OTHERNAV  DECIMAL(16,8)  COMMENT  '对方净值',
  EN_OTHERCONFIRMSHARE  DECIMAL(16,2)  COMMENT  '对方确认份额',
  EN_OTHERORIGINFARE  DECIMAL(16,2)  COMMENT  '对方应收手续费',
  C_CAPITALMODE  STRING  COMMENT  '资金方式',
  C_SUBCAPITALMODE  STRING  COMMENT  '明细资金方式',
  VC_ORIGINCONFIRMNO  STRING  COMMENT  '拆分前确认编号',
  C_BUSINTYPE  STRING  COMMENT  '',
  L_SECTIONSCHEMANO  DECIMAL(9,0)  COMMENT  '',
  C_EXPTYPE  STRING  COMMENT  '',
  C_SHAREADJUSTFLAG  STRING  COMMENT  '',
  C_INCOMEFLAG  STRING  COMMENT  '',
  EN_ACHIEVEMENTPAY  DECIMAL(16,2)  COMMENT  '',
  EN_BREACHFEE  DECIMAL(16,2)  COMMENT  '',
  VC_COMEFROM  STRING  COMMENT  '',
  VC_INVESTORSYSTEMID  STRING  COMMENT  '',
  VC_VOUCHERNO  STRING  COMMENT  '',
  C_BANKNO  STRING  COMMENT  '',
  VC_BANKNAME  STRING  COMMENT  '',
  VC_NAMEINBANK  STRING  COMMENT  '',
  VC_BANKACCO  STRING  COMMENT  '',
  VC_CUSTNO  STRING  COMMENT  '',
  VC_CONFIRMSETTLEDATE  STRING  COMMENT  '',
  VC_REQUESTSETTLEDATE  STRING  COMMENT  '',
  VC_CONTRACTSERIALNO  STRING  COMMENT  '',
  C_PROFITCLASS  STRING  COMMENT  '',
  VC_COMBREQUESTNO  STRING  COMMENT  '',
  VC_COMBCODE  STRING  COMMENT  '',
  C_AUTOREQUEST  STRING  COMMENT  '',
  VC_EXPLAIN  STRING  COMMENT  '',
  C_INTERFACETYPE  STRING  COMMENT  '',
  EN_OTHERFEE1  DECIMAL(16,2)  COMMENT  '',
  EN_OTHERFEE2  DECIMAL(16,2)  COMMENT  '',
  C_MATCHFLAG  STRING  COMMENT  '',
  VC_BOOKID  STRING  COMMENT  '',
  EN_GRAMNUM  DECIMAL(16,4)  COMMENT  '',
  C_FORCEREDEEMREASON  STRING  COMMENT  '',
  EN_TOTALFROZENSHARE  DECIMAL(16,2)  COMMENT  '',
  EN_FUNDSHAREBALANCE  DECIMAL(16,2)  COMMENT  '',
  EN_FROZENBALANCE  DECIMAL(16,2)  COMMENT  '',
  VC_FUTURESUBSCRIBEDATE  STRING  COMMENT  '',
  VC_TRANSFERDATEFROMAGENCY  STRING  COMMENT  '',
  EN_TAXADVANAMOUNT  DECIMAL(16,2)  COMMENT  '',
  VC_TAXADVANCODE  STRING  COMMENT  '',
  VC_OTHERSERIALNO  STRING  COMMENT  '',
  C_ATTENDQUITFLAG  STRING  COMMENT  '',
  VC_CUSTOMNAME_GS  STRING  COMMENT  '',
  C_IDENTITYTYPE_GS  STRING  COMMENT  '',
  VC_IDENTITYNO_GS  STRING  COMMENT  '',
  VC_NATIONALITY_GS  STRING  COMMENT  '',
  VC_CERTCODE_GS  STRING  COMMENT  '',
  VC_CERTDATE_GS  STRING  COMMENT  '',
  EN_ACCTAXPRETAKEOFF_GS  DECIMAL(16,2)  COMMENT  '',
  C_CHANGETYPE  STRING  COMMENT  '',
  C_PENATRATEFLAG  STRING  COMMENT  '',
  VC_ALLOTHEDGEFUNDNO  STRING  COMMENT  ''
)
COMMENT '交易确认表'
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
              "querySql": ["SELECT  C_CUSTTYPE\n                                   , VC_FUNDACCO\n                                   , VC_TRADEACCO\n                                   , C_TRUST\n                                   , VC_REQUESTDATE\n                                   , VC_REQUESTNO\n                                   , VC_CONFIRMNO\n                                   , VC_CONFIRMDATE\n                                   , VC_FUNDCODE\n                                   , C_SHARETYPE\n                                   , VC_NETNO\n                                   , VC_CENTERNO\n                                   , EN_RATIO\n                                   , EN_NAV\n                                   , EN_PROFIT\n                                   , C_BUSINFLAG\n                                   , EN_BALANCE\n                                   , EN_SHARE\n                                   , EN_CONFIRMBALA\n                                   , C_MONEYTYPE\n                                   , EN_CONFIRMSHARE\n                                   , EN_FARE\n                                   , EN_DEALFARE\n                                   , EN_TAFARE\n                                   , EN_AFTERFARE\n                                   , EN_AGENCYFARE\n                                   , EN_STAMPTAX\n                                   , C_CONFIRMFLAG\n                                   , VC_ERRORCODE\n                                   , VC_ERRORCAUSE\n                                   , C_VOUCHERFLAG\n                                   , EN_INTEREST\n                                   , EN_INTERESTTAX\n                                   , C_ORGANIGER\n                                   , VC_OTHERACCO\n                                   , VC_OTHERTRADEACCO\n                                   , C_OTHERAGENCYNO\n                                   , VC_OTHERNETNO\n                                   , VC_OTHERFUNDCODE\n                                   , C_OTHERSHARETYPE\n                                   , EN_UNFROZENBALA\n                                   , EN_RETURNFARE\n                                   , EN_ORIGINFARE\n                                   , VC_BROKER\n                                   , C_DIVIDENDMETHOD\n                                   , C_FROZENCAUSE\n                                   , VC_ORIGINNO\n                                   , VC_CITYNO\n                                   , VC_SELLER\n                                   , VC_TACODE\n                                   , EN_DISCOUNT\n                                   , EN_INCOME\n                                   , EN_INVESTINCOME\n                                   , EN_INVESTSHARE\n                                   , C_FINISHFLAG\n                                   , C_CONFIRMSTATUS\n                                   , C_INTERESTFLAG\n                                   , EN_ENDDISCOUNT\n                                   , EN_OTHERDISCOUNT\n                                   , VC_LIQUIDATEDATE\n                                   , C_SENDFLAG\n                                   , VC_BRANCHCODE\n                                   , C_FIXBUSINFLAG\n                                   , EN_OTHERNAV\n                                   , EN_OTHERCONFIRMSHARE\n                                   , EN_OTHERORIGINFARE\n                                   , C_CAPITALMODE\n                                   , C_SUBCAPITALMODE\n                                   , VC_ORIGINCONFIRMNO\n                                   , C_BUSINTYPE\n                                   , L_SECTIONSCHEMANO\n                                   , C_EXPTYPE\n                                   , C_SHAREADJUSTFLAG\n                                   , C_INCOMEFLAG\n                                   , EN_ACHIEVEMENTPAY\n                                   , EN_BREACHFEE\n                                   , VC_COMEFROM\n                                   , VC_INVESTORSYSTEMID\n                                   , VC_VOUCHERNO\n                                   , C_BANKNO\n                                   , VC_BANKNAME\n                                   , VC_NAMEINBANK\n                                   , VC_BANKACCO\n                                   , VC_CUSTNO\n                                   , VC_CONFIRMSETTLEDATE\n                                   , VC_REQUESTSETTLEDATE\n                                   , VC_CONTRACTSERIALNO\n                                   , C_PROFITCLASS\n                                   , VC_COMBREQUESTNO\n                                   , VC_COMBCODE\n                                   , C_AUTOREQUEST\n                                   , VC_EXPLAIN\n                                   , C_INTERFACETYPE\n                                   , EN_OTHERFEE1\n                                   , EN_OTHERFEE2\n                                   , C_MATCHFLAG\n                                   , VC_BOOKID\n                                   , EN_GRAMNUM\n                                   , C_FORCEREDEEMREASON\n                                   , EN_TOTALFROZENSHARE\n                                   , EN_FUNDSHAREBALANCE\n                                   , EN_FROZENBALANCE\n                                   , VC_FUTURESUBSCRIBEDATE\n                                   , VC_TRANSFERDATEFROMAGENCY\n                                   , EN_TAXADVANAMOUNT\n                                   , VC_TAXADVANCODE\n                                   , VC_OTHERSERIALNO\n                                   , C_ATTENDQUITFLAG\n                                   , VC_CUSTOMNAME_GS\n                                   , C_IDENTITYTYPE_GS\n                                   , VC_IDENTITYNO_GS\n                                   , VC_NATIONALITY_GS\n                                   , VC_CERTCODE_GS\n                                   , VC_CERTDATE_GS\n                                   , EN_ACCTAXPRETAKEOFF_GS\n                                   , C_CHANGETYPE\n                                   , C_PENATRATEFLAG\n                                   , VC_ALLOTHEDGEFUNDNO\n                                FROM ${hsds_src_schema}.TCONFIRM\n                                WHERE VC_CONFIRMDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "VC_FUNDACCO", "type": "STRING"}, {"name": "VC_TRADEACCO", "type": "STRING"}, {"name": "C_TRUST", "type": "STRING"}, {"name": "VC_REQUESTDATE", "type": "STRING"}, {"name": "VC_REQUESTNO", "type": "STRING"}, {"name": "VC_CONFIRMNO", "type": "STRING"}, {"name": "VC_CONFIRMDATE", "type": "STRING"}, {"name": "VC_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "VC_NETNO", "type": "STRING"}, {"name": "VC_CENTERNO", "type": "STRING"}, {"name": "EN_RATIO", "type": "DOUBLE"}, {"name": "EN_NAV", "type": "DOUBLE"}, {"name": "EN_PROFIT", "type": "DOUBLE"}, {"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_SHARE", "type": "DOUBLE"}, {"name": "EN_CONFIRMBALA", "type": "DOUBLE"}, {"name": "C_MONEYTYPE", "type": "STRING"}, {"name": "EN_CONFIRMSHARE", "type": "DOUBLE"}, {"name": "EN_FARE", "type": "DOUBLE"}, {"name": "EN_DEALFARE", "type": "DOUBLE"}, {"name": "EN_TAFARE", "type": "DOUBLE"}, {"name": "EN_AFTERFARE", "type": "DOUBLE"}, {"name": "EN_AGENCYFARE", "type": "DOUBLE"}, {"name": "EN_STAMPTAX", "type": "DOUBLE"}, {"name": "C_CONFIRMFLAG", "type": "STRING"}, {"name": "VC_ERRORCODE", "type": "STRING"}, {"name": "VC_ERRORCAUSE", "type": "STRING"}, {"name": "C_VOUCHERFLAG", "type": "STRING"}, {"name": "EN_INTEREST", "type": "DOUBLE"}, {"name": "EN_INTERESTTAX", "type": "DOUBLE"}, {"name": "C_ORGANIGER", "type": "STRING"}, {"name": "VC_OTHERACCO", "type": "STRING"}, {"name": "VC_OTHERTRADEACCO", "type": "STRING"}, {"name": "C_OTHERAGENCYNO", "type": "STRING"}, {"name": "VC_OTHERNETNO", "type": "STRING"}, {"name": "VC_OTHERFUNDCODE", "type": "STRING"}, {"name": "C_OTHERSHARETYPE", "type": "STRING"}, {"name": "EN_UNFROZENBALA", "type": "DOUBLE"}, {"name": "EN_RETURNFARE", "type": "DOUBLE"}, {"name": "EN_ORIGINFARE", "type": "DOUBLE"}, {"name": "VC_BROKER", "type": "STRING"}, {"name": "C_DIVIDENDMETHOD", "type": "STRING"}, {"name": "C_FROZENCAUSE", "type": "STRING"}, {"name": "VC_ORIGINNO", "type": "STRING"}, {"name": "VC_CITYNO", "type": "STRING"}, {"name": "VC_SELLER", "type": "STRING"}, {"name": "VC_TACODE", "type": "STRING"}, {"name": "EN_DISCOUNT", "type": "DOUBLE"}, {"name": "EN_INCOME", "type": "DOUBLE"}, {"name": "EN_INVESTINCOME", "type": "DOUBLE"}, {"name": "EN_INVESTSHARE", "type": "DOUBLE"}, {"name": "C_FINISHFLAG", "type": "STRING"}, {"name": "C_CONFIRMSTATUS", "type": "STRING"}, {"name": "C_INTERESTFLAG", "type": "STRING"}, {"name": "EN_ENDDISCOUNT", "type": "DOUBLE"}, {"name": "EN_OTHERDISCOUNT", "type": "DOUBLE"}, {"name": "VC_LIQUIDATEDATE", "type": "STRING"}, {"name": "C_SENDFLAG", "type": "STRING"}, {"name": "VC_BRANCHCODE", "type": "STRING"}, {"name": "C_FIXBUSINFLAG", "type": "STRING"}, {"name": "EN_OTHERNAV", "type": "DOUBLE"}, {"name": "EN_OTHERCONFIRMSHARE", "type": "DOUBLE"}, {"name": "EN_OTHERORIGINFARE", "type": "DOUBLE"}, {"name": "C_CAPITALMODE", "type": "STRING"}, {"name": "C_SUBCAPITALMODE", "type": "STRING"}, {"name": "VC_ORIGINCONFIRMNO", "type": "STRING"}, {"name": "C_BUSINTYPE", "type": "STRING"}, {"name": "L_SECTIONSCHEMANO", "type": "DOUBLE"}, {"name": "C_EXPTYPE", "type": "STRING"}, {"name": "C_SHAREADJUSTFLAG", "type": "STRING"}, {"name": "C_INCOMEFLAG", "type": "STRING"}, {"name": "EN_ACHIEVEMENTPAY", "type": "DOUBLE"}, {"name": "EN_BREACHFEE", "type": "DOUBLE"}, {"name": "VC_COMEFROM", "type": "STRING"}, {"name": "VC_INVESTORSYSTEMID", "type": "STRING"}, {"name": "VC_VOUCHERNO", "type": "STRING"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "VC_BANKNAME", "type": "STRING"}, {"name": "VC_NAMEINBANK", "type": "STRING"}, {"name": "VC_BANKACCO", "type": "STRING"}, {"name": "VC_CUSTNO", "type": "STRING"}, {"name": "VC_CONFIRMSETTLEDATE", "type": "STRING"}, {"name": "VC_REQUESTSETTLEDATE", "type": "STRING"}, {"name": "VC_CONTRACTSERIALNO", "type": "STRING"}, {"name": "C_PROFITCLASS", "type": "STRING"}, {"name": "VC_COMBREQUESTNO", "type": "STRING"}, {"name": "VC_COMBCODE", "type": "STRING"}, {"name": "C_AUTOREQUEST", "type": "STRING"}, {"name": "VC_EXPLAIN", "type": "STRING"}, {"name": "C_INTERFACETYPE", "type": "STRING"}, {"name": "EN_OTHERFEE1", "type": "DOUBLE"}, {"name": "EN_OTHERFEE2", "type": "DOUBLE"}, {"name": "C_MATCHFLAG", "type": "STRING"}, {"name": "VC_BOOKID", "type": "STRING"}, {"name": "EN_GRAMNUM", "type": "DOUBLE"}, {"name": "C_FORCEREDEEMREASON", "type": "STRING"}, {"name": "EN_TOTALFROZENSHARE", "type": "DOUBLE"}, {"name": "EN_FUNDSHAREBALANCE", "type": "DOUBLE"}, {"name": "EN_FROZENBALANCE", "type": "DOUBLE"}, {"name": "VC_FUTURESUBSCRIBEDATE", "type": "STRING"}, {"name": "VC_TRANSFERDATEFROMAGENCY", "type": "STRING"}, {"name": "EN_TAXADVANAMOUNT", "type": "DOUBLE"}, {"name": "VC_TAXADVANCODE", "type": "STRING"}, {"name": "VC_OTHERSERIALNO", "type": "STRING"}, {"name": "C_ATTENDQUITFLAG", "type": "STRING"}, {"name": "VC_CUSTOMNAME_GS", "type": "STRING"}, {"name": "C_IDENTITYTYPE_GS", "type": "STRING"}, {"name": "VC_IDENTITYNO_GS", "type": "STRING"}, {"name": "VC_NATIONALITY_GS", "type": "STRING"}, {"name": "VC_CERTCODE_GS", "type": "STRING"}, {"name": "VC_CERTDATE_GS", "type": "STRING"}, {"name": "EN_ACCTAXPRETAKEOFF_GS", "type": "DOUBLE"}, {"name": "C_CHANGETYPE", "type": "STRING"}, {"name": "C_PENATRATEFLAG", "type": "STRING"}, {"name": "VC_ALLOTHEDGEFUNDNO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_tconfirm_ptd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_tconfirm_ptd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_tconfirm_ptd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_tconfirm_ptd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TCONFIRM_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TCONFIRM_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_tconfirm_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCONFIRM_PTD PARTITION(P_DT)
SELECT
       C_CUSTTYPE
     , VC_FUNDACCO
     , VC_TRADEACCO
     , C_TRUST
     , VC_REQUESTDATE
     , VC_REQUESTNO
     , VC_CONFIRMNO
     , VC_CONFIRMDATE
     , VC_FUNDCODE
     , C_SHARETYPE
     , VC_NETNO
     , VC_CENTERNO
     , EN_RATIO
     , EN_NAV
     , EN_PROFIT
     , C_BUSINFLAG
     , EN_BALANCE
     , EN_SHARE
     , EN_CONFIRMBALA
     , C_MONEYTYPE
     , EN_CONFIRMSHARE
     , EN_FARE
     , EN_DEALFARE
     , EN_TAFARE
     , EN_AFTERFARE
     , EN_AGENCYFARE
     , EN_STAMPTAX
     , C_CONFIRMFLAG
     , VC_ERRORCODE
     , VC_ERRORCAUSE
     , C_VOUCHERFLAG
     , EN_INTEREST
     , EN_INTERESTTAX
     , C_ORGANIGER
     , VC_OTHERACCO
     , VC_OTHERTRADEACCO
     , C_OTHERAGENCYNO
     , VC_OTHERNETNO
     , VC_OTHERFUNDCODE
     , C_OTHERSHARETYPE
     , EN_UNFROZENBALA
     , EN_RETURNFARE
     , EN_ORIGINFARE
     , VC_BROKER
     , C_DIVIDENDMETHOD
     , C_FROZENCAUSE
     , VC_ORIGINNO
     , VC_CITYNO
     , VC_SELLER
     , VC_TACODE
     , EN_DISCOUNT
     , EN_INCOME
     , EN_INVESTINCOME
     , EN_INVESTSHARE
     , C_FINISHFLAG
     , C_CONFIRMSTATUS
     , C_INTERESTFLAG
     , EN_ENDDISCOUNT
     , EN_OTHERDISCOUNT
     , VC_LIQUIDATEDATE
     , C_SENDFLAG
     , VC_BRANCHCODE
     , C_FIXBUSINFLAG
     , EN_OTHERNAV
     , EN_OTHERCONFIRMSHARE
     , EN_OTHERORIGINFARE
     , C_CAPITALMODE
     , C_SUBCAPITALMODE
     , VC_ORIGINCONFIRMNO
     , C_BUSINTYPE
     , L_SECTIONSCHEMANO
     , C_EXPTYPE
     , C_SHAREADJUSTFLAG
     , C_INCOMEFLAG
     , EN_ACHIEVEMENTPAY
     , EN_BREACHFEE
     , VC_COMEFROM
     , VC_INVESTORSYSTEMID
     , VC_VOUCHERNO
     , C_BANKNO
     , VC_BANKNAME
     , VC_NAMEINBANK
     , VC_BANKACCO
     , VC_CUSTNO
     , VC_CONFIRMSETTLEDATE
     , VC_REQUESTSETTLEDATE
     , VC_CONTRACTSERIALNO
     , C_PROFITCLASS
     , VC_COMBREQUESTNO
     , VC_COMBCODE
     , C_AUTOREQUEST
     , VC_EXPLAIN
     , C_INTERFACETYPE
     , EN_OTHERFEE1
     , EN_OTHERFEE2
     , C_MATCHFLAG
     , VC_BOOKID
     , EN_GRAMNUM
     , C_FORCEREDEEMREASON
     , EN_TOTALFROZENSHARE
     , EN_FUNDSHAREBALANCE
     , EN_FROZENBALANCE
     , VC_FUTURESUBSCRIBEDATE
     , VC_TRANSFERDATEFROMAGENCY
     , EN_TAXADVANAMOUNT
     , VC_TAXADVANCODE
     , VC_OTHERSERIALNO
     , C_ATTENDQUITFLAG
     , VC_CUSTOMNAME_GS
     , C_IDENTITYTYPE_GS
     , VC_IDENTITYNO_GS
     , VC_NATIONALITY_GS
     , VC_CERTCODE_GS
     , VC_CERTDATE_GS
     , EN_ACCTAXPRETAKEOFF_GS
     , C_CHANGETYPE
     , C_PENATRATEFLAG
     , VC_ALLOTHEDGEFUNDNO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , VC_CONFIRMDATE P_DT
  FROM ODS_XDAY_HSDS.ODS_HSDS_TCONFIRM_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCONFIRM_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TCONFIRM_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TCONFIRM_PTD成功"
      exit 0
   fi
fi
