#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRM_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRM_PTD_TMP(
  C_CUSTNO  STRING  COMMENT  '客户编号',
  C_BUSINFLAG  STRING  COMMENT  '业务代码',
  D_CDATE  STRING  COMMENT  '确认日期',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  D_REQUESTDATE  STRING  COMMENT  '申请日期',
  D_REQUESTTIME  STRING  COMMENT  '申请时间',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  F_CONFIRMBALANCE  DECIMAL(16,2)  COMMENT  '确认金额',
  F_CONFIRMSHARES  DECIMAL(16,2)  COMMENT  '确认份额',
  F_TRADEFARE  DECIMAL(16,2)  COMMENT  '交易费',
  F_TAFARE  DECIMAL(16,2)  COMMENT  '过户费',
  F_STAMPTAX  DECIMAL(16,2)  COMMENT  '印花税',
  F_BACKFARE  DECIMAL(16,2)  COMMENT  '后收手续费',
  F_OTHERFARE1  DECIMAL(16,2)  COMMENT  '其他费用1',
  F_BREACHFARE  DECIMAL(16,2)  COMMENT  '违约金',
  F_PROFITBALANCE  DECIMAL(16,2)  COMMENT  '业绩报酬',
  F_TOTALFARE  DECIMAL(16,2)  COMMENT  '总费用',
  F_TRADEFARE4AGT  DECIMAL(16,2)  COMMENT  '交易费归销售机构费用',
  F_TRADEFARE4FUND  DECIMAL(16,2)  COMMENT  '交易费归基金资产费用',
  F_TAFARE4AGT  DECIMAL(16,2)  COMMENT  '过户费归销售机构费用',
  F_TAFARE4FUND  DECIMAL(16,2)  COMMENT  '过户费归基金资产费用',
  F_BACKFARE4AGT  DECIMAL(16,2)  COMMENT  '后收费归销售机构费用',
  F_BACKFARE4FUND  DECIMAL(16,2)  COMMENT  '后收费归基金资产费用',
  F_OTHERFARE14AGT  DECIMAL(16,2)  COMMENT  '其他费归销售机构费用',
  F_OTHERFARE14FUND  DECIMAL(16,2)  COMMENT  '其他费归基金资产费用',
  F_BREACHFARE4AGT  DECIMAL(16,2)  COMMENT  '违约金归销售机构费用',
  F_BREACHFARE4FUND  DECIMAL(16,2)  COMMENT  '违约金归基金资产费用',
  F_PROFITBALANCE4AGT  DECIMAL(16,2)  COMMENT  '业绩提成归销售商费用',
  F_PROFITBALANCE4FUND  DECIMAL(16,2)  COMMENT  '业绩报酬归基金资产费用',
  F_INTEREST  DECIMAL(16,2)  COMMENT  '利息',
  F_INTERESTTAX  DECIMAL(16,2)  COMMENT  '利息税',
  F_INTERESTSHARE  DECIMAL(16,2)  COMMENT  '利息转份额',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '基金净值（成交价）',
  F_PRICE  DECIMAL(16,8)  COMMENT  '设置成交价格',
  F_FROZENBALANCE  DECIMAL(16,2)  COMMENT  '确认冻结资金',
  F_UNFROZENBALANCE  DECIMAL(16,2)  COMMENT  '确认解冻金额',
  C_STATUS  STRING  COMMENT  '处理标志',
  C_CAUSE  STRING  COMMENT  '失败原因',
  C_TAFLAG  STRING  COMMENT  'TA发起标志',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_REQUESTENDFLAG  STRING  COMMENT  '申请结束标志',
  F_CHINCOME  DECIMAL(16,2)  COMMENT  '兑现的未付收益',
  F_CHSHARE  DECIMAL(16,2)  COMMENT  '兑现的份额',
  F_CONFIRMINCOME  DECIMAL(16,2)  COMMENT  '确认的未付收益',
  F_INCOME  DECIMAL(16,2)  COMMENT  '昨日基金收益',
  F_CONFIRMRATIO  DECIMAL(9,8)  COMMENT  '确认比例',
  F_ORITRADEFARE  DECIMAL(16,2)  COMMENT  '打折前交易费',
  F_ORITAFARE  DECIMAL(16,2)  COMMENT  '打折前过户费',
  F_ORIBACKFARE  DECIMAL(16,2)  COMMENT  '打折前后收费',
  F_ORIOTHERFARE1  DECIMAL(16,2)  COMMENT  '打折前其它费',
  F_ORIBREACHFARE  DECIMAL(16,2)  COMMENT  '',
  C_REQUESTNO  STRING  COMMENT  '申请编号',
  F_BALANCE  DECIMAL(16,2)  COMMENT  '申请金额',
  F_SHARES  DECIMAL(16,2)  COMMENT  '申请份额',
  F_AGIO  DECIMAL(5,4)  COMMENT  '费率折扣',
  C_OTHERCODE  STRING  COMMENT  '对方基金代码',
  C_OTHERSHARE  STRING  COMMENT  '对方份额类别',
  F_OTHERPRICE  DECIMAL(16,8)  COMMENT  '设置的对方价格',
  C_OTHERACCO  STRING  COMMENT  '对方基金账号',
  C_OTHERAGENCY  STRING  COMMENT  '对方销售商',
  C_OTHERNETNO  STRING  COMMENT  '对方网点',
  C_OTHERTRADEACCO  STRING  COMMENT  '对方交易账号',
  D_HOPEDATE  STRING  COMMENT  '希望处理日期',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_ORIREQUESTNO  STRING  COMMENT  '原申请编号',
  C_EXCEEDFLAG  STRING  COMMENT  '巨额赎回处理标志',
  C_CHILDNETNO  STRING  COMMENT  '操作网点编号',
  C_FREEZECAUSE  STRING  COMMENT  '冻结原因',
  C_FREEZEENDDATE  STRING  COMMENT  '冻结截止日期',
  C_FREEZENO  STRING  COMMENT  '冻结法律文书号',
  C_REQTRADEACCO  STRING  COMMENT  '',
  C_OUTBUSINFLAG  STRING  COMMENT  '外部业务标志',
  C_PROTOCOLNO  STRING  COMMENT  '协议号',
  L_RATIONDATE  DECIMAL(4,0)  COMMENT  '定期日期',
  C_RATIONTERM  STRING  COMMENT  '定期定额周期',
  D_PROTOCOLENDDATE  STRING  COMMENT  '协议截止日期',
  C_ACCEPTMODE  STRING  COMMENT  '交易方式',
  F_ORIAGIO  DECIMAL(5,4)  COMMENT  '原始费率折扣',
  F_ORIBACKFAREAGIO  DECIMAL(5,4)  COMMENT  '后收费折扣率',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_FUNDMETHOD  STRING  COMMENT  '资金方式',
  F_BACKFAREAGIO  DECIMAL(5,4)  COMMENT  '转换补差费折扣率',
  C_BANKNO  STRING  COMMENT  '银行编号',
  C_SUBFUNDMETHOD  STRING  COMMENT  '明细资金方式',
  C_COMBCODE  STRING  COMMENT  '组合编号',
  F_RETURNFARE  DECIMAL(16,2)  COMMENT  '',
  C_CITYNO  STRING  COMMENT  '城市编号(地区)',
  C_AUDITFLAG  STRING  COMMENT  '复核标志',
  C_OPERATOR  STRING  COMMENT  '操作员',
  C_TRANSFERCAUSE  STRING  COMMENT  '过户原因',
  C_IMPROPERREDEEM  STRING  COMMENT  '',
  F_PUNISHRATIO  DECIMAL(5,4)  COMMENT  '',
  C_MAINTRDACCO  STRING  COMMENT  '',
  D_REGISTDATE  STRING  COMMENT  '份额注册日期',
  D_ORIGINALDATE  STRING  COMMENT  '份额原确认日期',
  C_ORICSERIALNO  STRING  COMMENT  '',
  C_RECFLAG  STRING  COMMENT  '数据标志',
  C_ORIFUNDCODE  STRING  COMMENT  '',
  C_ADJUSTCAUSE  STRING  COMMENT  '',
  L_BATCHNO  DECIMAL(2,0)  COMMENT  '销售商所处清算批次号',
  C_SYSROLE  STRING  COMMENT  '系统角色',
  C_SPECIALCODE  STRING  COMMENT  '特殊代码',
  C_RATIONVARIETY  STRING  COMMENT  '',
  C_RATIONSERIALNO  STRING  COMMENT  '',
  C_RATIONTYPE  STRING  COMMENT  '定期定额类型',
  D_PROTOCOLBEGINDATE  STRING  COMMENT  '',
  C_BROKER  STRING  COMMENT  '经纪人',
  C_RATIONPURPOSE  STRING  COMMENT  '',
  L_RATIONFREQUENCY  DECIMAL(5,0)  COMMENT  '',
  C_RATIONTIMEUNIT  STRING  COMMENT  '',
  F_RATIONNUM  DECIMAL(16,2)  COMMENT  '',
  C_TRADEMETHOD  STRING  COMMENT  '',
  C_SOLUTIONID  STRING  COMMENT  '计划代码',
  C_TACODE  STRING  COMMENT  'TA代码',
  D_FACTDATE  STRING  COMMENT  '',
  C_FORCEREDEMPTIONTYPE  STRING  COMMENT  '',
  C_SECONDACCO  STRING  COMMENT  '强增账户的二级账号',
  F_ONTHEWAYCFMSHR  DECIMAL(16,2)  COMMENT  '',
  F_MGRINCOME  DECIMAL(16,2)  COMMENT  '',
  C_ISRDMTOTAL  STRING  COMMENT  '',
  F_EVENNETVALUE  DECIMAL(17,9)  COMMENT  '保本单位净值',
  F_UNSHARES  DECIMAL(16,2)  COMMENT  '未确认份额',
  C_PARTNERID  STRING  COMMENT  '',
  C_OUTFUNDCODE  STRING  COMMENT  '对外基金代码',
  C_FORCERDMTYPE  STRING  COMMENT  '到期份额退出处理方式',
  F_ORIREQSHARES  DECIMAL(16,2)  COMMENT  '',
  D_SCF02REQDATE  STRING  COMMENT  '',
  F_SCF02REQBANLANCE  DECIMAL(16,2)  COMMENT  '',
  F_TOTALBACKENDLOAD  DECIMAL(16,2)  COMMENT  '',
  D_ORI02REQDATE  STRING  COMMENT  '',
  F_SCFMGRINCOME  DECIMAL(16,2)  COMMENT  '',
  F_VALUEADDEDFARE  DECIMAL(16,2)  COMMENT  '',
  F_PROFITCOMPENSATION  DECIMAL(16,2)  COMMENT  '',
  F_ONTHEWAYREQSHR  DECIMAL(16,2)  COMMENT  '',
  C_TRANONWAYSHRFLAG  STRING  COMMENT  '',
  C_ORICUSTYPE  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '备注',
  F_PROTECTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_RDMFEESHARES  DECIMAL(16,2)  COMMENT  '',
  C_FIXEDFAREFLAG  STRING  COMMENT  '',
  F_DEFINEDRATIO  DECIMAL(9,8)  COMMENT  '',
  F_REQRDMBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_TODAYNODEALFLAG  STRING  COMMENT  '',
  C_T0BULLBEARFLAG  STRING  COMMENT  '',
  F_DEFINEDFEE  DECIMAL(16,2)  COMMENT  '',
  F_USDMONTHINCOME  DECIMAL(16,2)  COMMENT  '',
  D_CDATE1  STRING  COMMENT  '',
  C_MONEYTYPE  STRING  COMMENT  '',
  C_REQDATATYPE  STRING  COMMENT  '',
  C_CHAGETYPE  STRING  COMMENT  '',
  D_LASTDEDUCTDATE  STRING  COMMENT  '',
  F_AGENCYINTEREST  DECIMAL(16,2)  COMMENT  '',
  F_TADEFINEDFEE  DECIMAL(16,2)  COMMENT  '',
  C_IMPAGENCYNO  STRING  COMMENT  '',
  L_LONGRATIONCOUNT  DECIMAL(10,0)  COMMENT  '',
  F_LONGALLOTPAY  DECIMAL(16,2)  COMMENT  '',
  F_LONGREGISTPAY  DECIMAL(16,2)  COMMENT  '',
  F_T0FAILSHARES  DECIMAL(16,2)  COMMENT  '',
  F_EXCHANGEBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_EXCHANGECONFBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_MANAGEFARE4CUST  DECIMAL(16,2)  COMMENT  '',
  F_MANAGEFARE4REGIST  DECIMAL(16,2)  COMMENT  '',
  C_ISPFTRDMFLAG  STRING  COMMENT  '',
  F_OTHERFARE2  DECIMAL(16,2)  COMMENT  '',
  C_TAKEINCOME  STRING  COMMENT  '',
  C_CHECKER  STRING  COMMENT  '',
  C_IMPYEBBYFILE  STRING  COMMENT  '',
  C_VIRTUALTACODE  STRING  COMMENT  '',
  D_ORI02CFMDATE  STRING  COMMENT  '',
  F_PFTREDRESSBAL  DECIMAL(16,2)  COMMENT  '',
  F_PROFITREDRESS  DECIMAL(16,2)  COMMENT  '',
  C_BLACKLEVEL  STRING  COMMENT  '',
  C_IPADDRESS  STRING  COMMENT  '',
  C_MACADDRESS  STRING  COMMENT  '',
  C_IMEI  STRING  COMMENT  '',
  C_UUID  STRING  COMMENT  '',
  C_NAMEINBANK  STRING  COMMENT  '',
  C_BANKACCO  STRING  COMMENT  '',
  D_DEFINENAVDATE  STRING  COMMENT  '',
  F_MANUALDEALSHARES  DECIMAL(16,2)  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  C_XTFUNDACCO  STRING  COMMENT  '',
  F_PROFITBALANCE4ATTEND  DECIMAL(16,2)  COMMENT  '',
  C_ACTCODE  STRING  COMMENT  '',
  F_SVRRETFARE  DECIMAL(16,2)  COMMENT  '',
  F_SVRRETFARE4CUST  DECIMAL(16,2)  COMMENT  '',
  F_SVRRETFARE4AGC  DECIMAL(16,2)  COMMENT  '',
  F_FLOATMANAGEFEE  DECIMAL(16,2)  COMMENT  '',
  D_DEFPURDATE  STRING  COMMENT  '',
  C_ICDATA  STRING  COMMENT  '',
  F_PFTBAL2MACCO  DECIMAL(16,6)  COMMENT  '',
  C_SUBAGENCYNO  STRING  COMMENT  '',
  F_DEFINEBREAKRATIO  DECIMAL(9,8)  COMMENT  '',
  C_AUTOUNFRZ  STRING  COMMENT  '',
  C_RDMREASON  STRING  COMMENT  ''
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_CUSTNO
                                   , C_BUSINFLAG
                                   , D_CDATE
                                   , C_CSERIALNO
                                   , D_REQUESTDATE
                                   , D_REQUESTTIME
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , F_CONFIRMBALANCE
                                   , F_CONFIRMSHARES
                                   , F_TRADEFARE
                                   , F_TAFARE
                                   , F_STAMPTAX
                                   , F_BACKFARE
                                   , F_OTHERFARE1
                                   , F_BREACHFARE
                                   , F_PROFITBALANCE
                                   , F_TOTALFARE
                                   , F_TRADEFARE4AGT
                                   , F_TRADEFARE4FUND
                                   , F_TAFARE4AGT
                                   , F_TAFARE4FUND
                                   , F_BACKFARE4AGT
                                   , F_BACKFARE4FUND
                                   , F_OTHERFARE14AGT
                                   , F_OTHERFARE14FUND
                                   , F_BREACHFARE4AGT
                                   , F_BREACHFARE4FUND
                                   , F_PROFITBALANCE4AGT
                                   , F_PROFITBALANCE4FUND
                                   , F_INTEREST
                                   , F_INTERESTTAX
                                   , F_INTERESTSHARE
                                   , F_NETVALUE
                                   , F_PRICE
                                   , F_FROZENBALANCE
                                   , F_UNFROZENBALANCE
                                   , C_STATUS
                                   , C_CAUSE
                                   , C_TAFLAG
                                   , C_CUSTTYPE
                                   , C_REQUESTENDFLAG
                                   , F_CHINCOME
                                   , F_CHSHARE
                                   , F_CONFIRMINCOME
                                   , F_INCOME
                                   , F_CONFIRMRATIO
                                   , F_ORITRADEFARE
                                   , F_ORITAFARE
                                   , F_ORIBACKFARE
                                   , F_ORIOTHERFARE1
                                   , F_ORIBREACHFARE
                                   , C_REQUESTNO
                                   , F_BALANCE
                                   , F_SHARES
                                   , F_AGIO
                                   , C_OTHERCODE
                                   , C_OTHERSHARE
                                   , F_OTHERPRICE
                                   , C_OTHERACCO
                                   , C_OTHERAGENCY
                                   , C_OTHERNETNO
                                   , C_OTHERTRADEACCO
                                   , D_HOPEDATE
                                   , C_BONUSTYPE
                                   , C_ORIREQUESTNO
                                   , C_EXCEEDFLAG
                                   , C_CHILDNETNO
                                   , C_FREEZECAUSE
                                   , C_FREEZEENDDATE
                                   , C_FREEZENO
                                   , C_REQTRADEACCO
                                   , C_OUTBUSINFLAG
                                   , C_PROTOCOLNO
                                   , L_RATIONDATE
                                   , C_RATIONTERM
                                   , D_PROTOCOLENDDATE
                                   , C_ACCEPTMODE
                                   , F_ORIAGIO
                                   , F_ORIBACKFAREAGIO
                                   , C_SHARECLASS
                                   , C_BOURSEFLAG
                                   , C_FUNDMETHOD
                                   , F_BACKFAREAGIO
                                   , C_BANKNO
                                   , C_SUBFUNDMETHOD
                                   , C_COMBCODE
                                   , F_RETURNFARE
                                   , C_CITYNO
                                   , C_AUDITFLAG
                                   , C_OPERATOR
                                   , C_TRANSFERCAUSE
                                   , C_IMPROPERREDEEM
                                   , F_PUNISHRATIO
                                   , C_MAINTRDACCO
                                   , D_REGISTDATE
                                   , D_ORIGINALDATE
                                   , C_ORICSERIALNO
                                   , C_RECFLAG
                                   , C_ORIFUNDCODE
                                   , C_ADJUSTCAUSE
                                   , L_BATCHNO
                                   , C_SYSROLE
                                   , C_SPECIALCODE
                                   , C_RATIONVARIETY
                                   , C_RATIONSERIALNO
                                   , C_RATIONTYPE
                                   , D_PROTOCOLBEGINDATE
                                   , C_BROKER
                                   , C_RATIONPURPOSE
                                   , L_RATIONFREQUENCY
                                   , C_RATIONTIMEUNIT
                                   , F_RATIONNUM
                                   , C_TRADEMETHOD
                                   , C_SOLUTIONID
                                   , C_TACODE
                                   , D_FACTDATE
                                   , C_FORCEREDEMPTIONTYPE
                                   , C_SECONDACCO
                                   , F_ONTHEWAYCFMSHR
                                   , F_MGRINCOME
                                   , C_ISRDMTOTAL
                                   , F_EVENNETVALUE
                                   , F_UNSHARES
                                   , C_PARTNERID
                                   , C_OUTFUNDCODE
                                   , C_FORCERDMTYPE
                                   , F_ORIREQSHARES
                                   , D_SCF02REQDATE
                                   , F_SCF02REQBANLANCE
                                   , F_TOTALBACKENDLOAD
                                   , D_ORI02REQDATE
                                   , F_SCFMGRINCOME
                                   , F_VALUEADDEDFARE
                                   , F_PROFITCOMPENSATION
                                   , F_ONTHEWAYREQSHR
                                   , C_TRANONWAYSHRFLAG
                                   , C_ORICUSTYPE
                                   , C_MEMO
                                   , F_PROTECTBALANCE
                                   , F_RDMFEESHARES
                                   , C_FIXEDFAREFLAG
                                   , F_DEFINEDRATIO
                                   , F_REQRDMBALANCE
                                   , C_TODAYNODEALFLAG
                                   , C_T0BULLBEARFLAG
                                   , F_DEFINEDFEE
                                   , F_USDMONTHINCOME
                                   , D_CDATE1
                                   , C_MONEYTYPE
                                   , C_REQDATATYPE
                                   , C_CHAGETYPE
                                   , D_LASTDEDUCTDATE
                                   , F_AGENCYINTEREST
                                   , F_TADEFINEDFEE
                                   , C_IMPAGENCYNO
                                   , L_LONGRATIONCOUNT
                                   , F_LONGALLOTPAY
                                   , F_LONGREGISTPAY
                                   , F_T0FAILSHARES
                                   , F_EXCHANGEBALANCE
                                   , F_EXCHANGECONFBALANCE
                                   , F_MANAGEFARE4CUST
                                   , F_MANAGEFARE4REGIST
                                   , C_ISPFTRDMFLAG
                                   , F_OTHERFARE2
                                   , C_TAKEINCOME
                                   , C_CHECKER
                                   , C_IMPYEBBYFILE
                                   , C_VIRTUALTACODE
                                   , D_ORI02CFMDATE
                                   , F_PFTREDRESSBAL
                                   , F_PROFITREDRESS
                                   , C_BLACKLEVEL
                                   , C_IPADDRESS
                                   , C_MACADDRESS
                                   , C_IMEI
                                   , C_UUID
                                   , C_NAMEINBANK
                                   , C_BANKACCO
                                   , D_DEFINENAVDATE
                                   , F_MANUALDEALSHARES
                                   , C_SUBFUNDCODE
                                   , C_XTFUNDACCO
                                   , F_PROFITBALANCE4ATTEND
                                   , C_ACTCODE
                                   , F_SVRRETFARE
                                   , F_SVRRETFARE4CUST
                                   , F_SVRRETFARE4AGC
                                   , F_FLOATMANAGEFEE
                                   , D_DEFPURDATE
                                   , C_ICDATA
                                   , F_PFTBAL2MACCO
                                   , C_SUBAGENCYNO
                                   , F_DEFINEBREAKRATIO
                                   , C_AUTOUNFRZ
                                   , C_RDMREASON
                                FROM ${hszta_src_schema}.TCONFIRM
                                WHERE D_CDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CUSTNO", "type": "STRING"}, {"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "D_REQUESTDATE", "type": "STRING"}, {"name": "D_REQUESTTIME", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "F_CONFIRMBALANCE", "type": "DOUBLE"}, {"name": "F_CONFIRMSHARES", "type": "DOUBLE"}, {"name": "F_TRADEFARE", "type": "DOUBLE"}, {"name": "F_TAFARE", "type": "DOUBLE"}, {"name": "F_STAMPTAX", "type": "DOUBLE"}, {"name": "F_BACKFARE", "type": "DOUBLE"}, {"name": "F_OTHERFARE1", "type": "DOUBLE"}, {"name": "F_BREACHFARE", "type": "DOUBLE"}, {"name": "F_PROFITBALANCE", "type": "DOUBLE"}, {"name": "F_TOTALFARE", "type": "DOUBLE"}, {"name": "F_TRADEFARE4AGT", "type": "DOUBLE"}, {"name": "F_TRADEFARE4FUND", "type": "DOUBLE"}, {"name": "F_TAFARE4AGT", "type": "DOUBLE"}, {"name": "F_TAFARE4FUND", "type": "DOUBLE"}, {"name": "F_BACKFARE4AGT", "type": "DOUBLE"}, {"name": "F_BACKFARE4FUND", "type": "DOUBLE"}, {"name": "F_OTHERFARE14AGT", "type": "DOUBLE"}, {"name": "F_OTHERFARE14FUND", "type": "DOUBLE"}, {"name": "F_BREACHFARE4AGT", "type": "DOUBLE"}, {"name": "F_BREACHFARE4FUND", "type": "DOUBLE"}, {"name": "F_PROFITBALANCE4AGT", "type": "DOUBLE"}, {"name": "F_PROFITBALANCE4FUND", "type": "DOUBLE"}, {"name": "F_INTEREST", "type": "DOUBLE"}, {"name": "F_INTERESTTAX", "type": "DOUBLE"}, {"name": "F_INTERESTSHARE", "type": "DOUBLE"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_PRICE", "type": "DOUBLE"}, {"name": "F_FROZENBALANCE", "type": "DOUBLE"}, {"name": "F_UNFROZENBALANCE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_CAUSE", "type": "STRING"}, {"name": "C_TAFLAG", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_REQUESTENDFLAG", "type": "STRING"}, {"name": "F_CHINCOME", "type": "DOUBLE"}, {"name": "F_CHSHARE", "type": "DOUBLE"}, {"name": "F_CONFIRMINCOME", "type": "DOUBLE"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_CONFIRMRATIO", "type": "DOUBLE"}, {"name": "F_ORITRADEFARE", "type": "DOUBLE"}, {"name": "F_ORITAFARE", "type": "DOUBLE"}, {"name": "F_ORIBACKFARE", "type": "DOUBLE"}, {"name": "F_ORIOTHERFARE1", "type": "DOUBLE"}, {"name": "F_ORIBREACHFARE", "type": "DOUBLE"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "F_BALANCE", "type": "DOUBLE"}, {"name": "F_SHARES", "type": "DOUBLE"}, {"name": "F_AGIO", "type": "DOUBLE"}, {"name": "C_OTHERCODE", "type": "STRING"}, {"name": "C_OTHERSHARE", "type": "STRING"}, {"name": "F_OTHERPRICE", "type": "DOUBLE"}, {"name": "C_OTHERACCO", "type": "STRING"}, {"name": "C_OTHERAGENCY", "type": "STRING"}, {"name": "C_OTHERNETNO", "type": "STRING"}, {"name": "C_OTHERTRADEACCO", "type": "STRING"}, {"name": "D_HOPEDATE", "type": "STRING"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_ORIREQUESTNO", "type": "STRING"}, {"name": "C_EXCEEDFLAG", "type": "STRING"}, {"name": "C_CHILDNETNO", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "C_FREEZEENDDATE", "type": "STRING"}, {"name": "C_FREEZENO", "type": "STRING"}, {"name": "C_REQTRADEACCO", "type": "STRING"}, {"name": "C_OUTBUSINFLAG", "type": "STRING"}, {"name": "C_PROTOCOLNO", "type": "STRING"}, {"name": "L_RATIONDATE", "type": "DOUBLE"}, {"name": "C_RATIONTERM", "type": "STRING"}, {"name": "D_PROTOCOLENDDATE", "type": "STRING"}, {"name": "C_ACCEPTMODE", "type": "STRING"}, {"name": "F_ORIAGIO", "type": "DOUBLE"}, {"name": "F_ORIBACKFAREAGIO", "type": "DOUBLE"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_FUNDMETHOD", "type": "STRING"}, {"name": "F_BACKFAREAGIO", "type": "DOUBLE"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_SUBFUNDMETHOD", "type": "STRING"}, {"name": "C_COMBCODE", "type": "STRING"}, {"name": "F_RETURNFARE", "type": "DOUBLE"}, {"name": "C_CITYNO", "type": "STRING"}, {"name": "C_AUDITFLAG", "type": "STRING"}, {"name": "C_OPERATOR", "type": "STRING"}, {"name": "C_TRANSFERCAUSE", "type": "STRING"}, {"name": "C_IMPROPERREDEEM", "type": "STRING"}, {"name": "F_PUNISHRATIO", "type": "DOUBLE"}, {"name": "C_MAINTRDACCO", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "D_ORIGINALDATE", "type": "STRING"}, {"name": "C_ORICSERIALNO", "type": "STRING"}, {"name": "C_RECFLAG", "type": "STRING"}, {"name": "C_ORIFUNDCODE", "type": "STRING"}, {"name": "C_ADJUSTCAUSE", "type": "STRING"}, {"name": "L_BATCHNO", "type": "DOUBLE"}, {"name": "C_SYSROLE", "type": "STRING"}, {"name": "C_SPECIALCODE", "type": "STRING"}, {"name": "C_RATIONVARIETY", "type": "STRING"}, {"name": "C_RATIONSERIALNO", "type": "STRING"}, {"name": "C_RATIONTYPE", "type": "STRING"}, {"name": "D_PROTOCOLBEGINDATE", "type": "STRING"}, {"name": "C_BROKER", "type": "STRING"}, {"name": "C_RATIONPURPOSE", "type": "STRING"}, {"name": "L_RATIONFREQUENCY", "type": "DOUBLE"}, {"name": "C_RATIONTIMEUNIT", "type": "STRING"}, {"name": "F_RATIONNUM", "type": "DOUBLE"}, {"name": "C_TRADEMETHOD", "type": "STRING"}, {"name": "C_SOLUTIONID", "type": "STRING"}, {"name": "C_TACODE", "type": "STRING"}, {"name": "D_FACTDATE", "type": "STRING"}, {"name": "C_FORCEREDEMPTIONTYPE", "type": "STRING"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "F_ONTHEWAYCFMSHR", "type": "DOUBLE"}, {"name": "F_MGRINCOME", "type": "DOUBLE"}, {"name": "C_ISRDMTOTAL", "type": "STRING"}, {"name": "F_EVENNETVALUE", "type": "DOUBLE"}, {"name": "F_UNSHARES", "type": "DOUBLE"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_OUTFUNDCODE", "type": "STRING"}, {"name": "C_FORCERDMTYPE", "type": "STRING"}, {"name": "F_ORIREQSHARES", "type": "DOUBLE"}, {"name": "D_SCF02REQDATE", "type": "STRING"}, {"name": "F_SCF02REQBANLANCE", "type": "DOUBLE"}, {"name": "F_TOTALBACKENDLOAD", "type": "DOUBLE"}, {"name": "D_ORI02REQDATE", "type": "STRING"}, {"name": "F_SCFMGRINCOME", "type": "DOUBLE"}, {"name": "F_VALUEADDEDFARE", "type": "DOUBLE"}, {"name": "F_PROFITCOMPENSATION", "type": "DOUBLE"}, {"name": "F_ONTHEWAYREQSHR", "type": "DOUBLE"}, {"name": "C_TRANONWAYSHRFLAG", "type": "STRING"}, {"name": "C_ORICUSTYPE", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "F_PROTECTBALANCE", "type": "DOUBLE"}, {"name": "F_RDMFEESHARES", "type": "DOUBLE"}, {"name": "C_FIXEDFAREFLAG", "type": "STRING"}, {"name": "F_DEFINEDRATIO", "type": "DOUBLE"}, {"name": "F_REQRDMBALANCE", "type": "DOUBLE"}, {"name": "C_TODAYNODEALFLAG", "type": "STRING"}, {"name": "C_T0BULLBEARFLAG", "type": "STRING"}, {"name": "F_DEFINEDFEE", "type": "DOUBLE"}, {"name": "F_USDMONTHINCOME", "type": "DOUBLE"}, {"name": "D_CDATE1", "type": "STRING"}, {"name": "C_MONEYTYPE", "type": "STRING"}, {"name": "C_REQDATATYPE", "type": "STRING"}, {"name": "C_CHAGETYPE", "type": "STRING"}, {"name": "D_LASTDEDUCTDATE", "type": "STRING"}, {"name": "F_AGENCYINTEREST", "type": "DOUBLE"}, {"name": "F_TADEFINEDFEE", "type": "DOUBLE"}, {"name": "C_IMPAGENCYNO", "type": "STRING"}, {"name": "L_LONGRATIONCOUNT", "type": "DOUBLE"}, {"name": "F_LONGALLOTPAY", "type": "DOUBLE"}, {"name": "F_LONGREGISTPAY", "type": "DOUBLE"}, {"name": "F_T0FAILSHARES", "type": "DOUBLE"}, {"name": "F_EXCHANGEBALANCE", "type": "DOUBLE"}, {"name": "F_EXCHANGECONFBALANCE", "type": "DOUBLE"}, {"name": "F_MANAGEFARE4CUST", "type": "DOUBLE"}, {"name": "F_MANAGEFARE4REGIST", "type": "DOUBLE"}, {"name": "C_ISPFTRDMFLAG", "type": "STRING"}, {"name": "F_OTHERFARE2", "type": "DOUBLE"}, {"name": "C_TAKEINCOME", "type": "STRING"}, {"name": "C_CHECKER", "type": "STRING"}, {"name": "C_IMPYEBBYFILE", "type": "STRING"}, {"name": "C_VIRTUALTACODE", "type": "STRING"}, {"name": "D_ORI02CFMDATE", "type": "STRING"}, {"name": "F_PFTREDRESSBAL", "type": "DOUBLE"}, {"name": "F_PROFITREDRESS", "type": "DOUBLE"}, {"name": "C_BLACKLEVEL", "type": "STRING"}, {"name": "C_IPADDRESS", "type": "STRING"}, {"name": "C_MACADDRESS", "type": "STRING"}, {"name": "C_IMEI", "type": "STRING"}, {"name": "C_UUID", "type": "STRING"}, {"name": "C_NAMEINBANK", "type": "STRING"}, {"name": "C_BANKACCO", "type": "STRING"}, {"name": "D_DEFINENAVDATE", "type": "STRING"}, {"name": "F_MANUALDEALSHARES", "type": "DOUBLE"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "C_XTFUNDACCO", "type": "STRING"}, {"name": "F_PROFITBALANCE4ATTEND", "type": "DOUBLE"}, {"name": "C_ACTCODE", "type": "STRING"}, {"name": "F_SVRRETFARE", "type": "DOUBLE"}, {"name": "F_SVRRETFARE4CUST", "type": "DOUBLE"}, {"name": "F_SVRRETFARE4AGC", "type": "DOUBLE"}, {"name": "F_FLOATMANAGEFEE", "type": "DOUBLE"}, {"name": "D_DEFPURDATE", "type": "STRING"}, {"name": "C_ICDATA", "type": "STRING"}, {"name": "F_PFTBAL2MACCO", "type": "DOUBLE"}, {"name": "C_SUBAGENCYNO", "type": "STRING"}, {"name": "F_DEFINEBREAKRATIO", "type": "DOUBLE"}, {"name": "C_AUTOUNFRZ", "type": "STRING"}, {"name": "C_RDMREASON", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tconfirm_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tconfirm_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tconfirm_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tconfirm_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TCONFIRM_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TCONFIRM_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tconfirm_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRM_PTD PARTITION(P_DT)
SELECT
       C_CUSTNO
     , C_BUSINFLAG
     , D_CDATE
     , C_CSERIALNO
     , D_REQUESTDATE
     , D_REQUESTTIME
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , F_CONFIRMBALANCE
     , F_CONFIRMSHARES
     , F_TRADEFARE
     , F_TAFARE
     , F_STAMPTAX
     , F_BACKFARE
     , F_OTHERFARE1
     , F_BREACHFARE
     , F_PROFITBALANCE
     , F_TOTALFARE
     , F_TRADEFARE4AGT
     , F_TRADEFARE4FUND
     , F_TAFARE4AGT
     , F_TAFARE4FUND
     , F_BACKFARE4AGT
     , F_BACKFARE4FUND
     , F_OTHERFARE14AGT
     , F_OTHERFARE14FUND
     , F_BREACHFARE4AGT
     , F_BREACHFARE4FUND
     , F_PROFITBALANCE4AGT
     , F_PROFITBALANCE4FUND
     , F_INTEREST
     , F_INTERESTTAX
     , F_INTERESTSHARE
     , F_NETVALUE
     , F_PRICE
     , F_FROZENBALANCE
     , F_UNFROZENBALANCE
     , C_STATUS
     , C_CAUSE
     , C_TAFLAG
     , C_CUSTTYPE
     , C_REQUESTENDFLAG
     , F_CHINCOME
     , F_CHSHARE
     , F_CONFIRMINCOME
     , F_INCOME
     , F_CONFIRMRATIO
     , F_ORITRADEFARE
     , F_ORITAFARE
     , F_ORIBACKFARE
     , F_ORIOTHERFARE1
     , F_ORIBREACHFARE
     , C_REQUESTNO
     , F_BALANCE
     , F_SHARES
     , F_AGIO
     , C_OTHERCODE
     , C_OTHERSHARE
     , F_OTHERPRICE
     , C_OTHERACCO
     , C_OTHERAGENCY
     , C_OTHERNETNO
     , C_OTHERTRADEACCO
     , D_HOPEDATE
     , C_BONUSTYPE
     , C_ORIREQUESTNO
     , C_EXCEEDFLAG
     , C_CHILDNETNO
     , C_FREEZECAUSE
     , C_FREEZEENDDATE
     , C_FREEZENO
     , C_REQTRADEACCO
     , C_OUTBUSINFLAG
     , C_PROTOCOLNO
     , L_RATIONDATE
     , C_RATIONTERM
     , D_PROTOCOLENDDATE
     , C_ACCEPTMODE
     , F_ORIAGIO
     , F_ORIBACKFAREAGIO
     , C_SHARECLASS
     , C_BOURSEFLAG
     , C_FUNDMETHOD
     , F_BACKFAREAGIO
     , C_BANKNO
     , C_SUBFUNDMETHOD
     , C_COMBCODE
     , F_RETURNFARE
     , C_CITYNO
     , C_AUDITFLAG
     , C_OPERATOR
     , C_TRANSFERCAUSE
     , C_IMPROPERREDEEM
     , F_PUNISHRATIO
     , C_MAINTRDACCO
     , D_REGISTDATE
     , D_ORIGINALDATE
     , C_ORICSERIALNO
     , C_RECFLAG
     , C_ORIFUNDCODE
     , C_ADJUSTCAUSE
     , L_BATCHNO
     , C_SYSROLE
     , C_SPECIALCODE
     , C_RATIONVARIETY
     , C_RATIONSERIALNO
     , C_RATIONTYPE
     , D_PROTOCOLBEGINDATE
     , C_BROKER
     , C_RATIONPURPOSE
     , L_RATIONFREQUENCY
     , C_RATIONTIMEUNIT
     , F_RATIONNUM
     , C_TRADEMETHOD
     , C_SOLUTIONID
     , C_TACODE
     , D_FACTDATE
     , C_FORCEREDEMPTIONTYPE
     , C_SECONDACCO
     , F_ONTHEWAYCFMSHR
     , F_MGRINCOME
     , C_ISRDMTOTAL
     , F_EVENNETVALUE
     , F_UNSHARES
     , C_PARTNERID
     , C_OUTFUNDCODE
     , C_FORCERDMTYPE
     , F_ORIREQSHARES
     , D_SCF02REQDATE
     , F_SCF02REQBANLANCE
     , F_TOTALBACKENDLOAD
     , D_ORI02REQDATE
     , F_SCFMGRINCOME
     , F_VALUEADDEDFARE
     , F_PROFITCOMPENSATION
     , F_ONTHEWAYREQSHR
     , C_TRANONWAYSHRFLAG
     , C_ORICUSTYPE
     , C_MEMO
     , F_PROTECTBALANCE
     , F_RDMFEESHARES
     , C_FIXEDFAREFLAG
     , F_DEFINEDRATIO
     , F_REQRDMBALANCE
     , C_TODAYNODEALFLAG
     , C_T0BULLBEARFLAG
     , F_DEFINEDFEE
     , F_USDMONTHINCOME
     , D_CDATE1
     , C_MONEYTYPE
     , C_REQDATATYPE
     , C_CHAGETYPE
     , D_LASTDEDUCTDATE
     , F_AGENCYINTEREST
     , F_TADEFINEDFEE
     , C_IMPAGENCYNO
     , L_LONGRATIONCOUNT
     , F_LONGALLOTPAY
     , F_LONGREGISTPAY
     , F_T0FAILSHARES
     , F_EXCHANGEBALANCE
     , F_EXCHANGECONFBALANCE
     , F_MANAGEFARE4CUST
     , F_MANAGEFARE4REGIST
     , C_ISPFTRDMFLAG
     , F_OTHERFARE2
     , C_TAKEINCOME
     , C_CHECKER
     , C_IMPYEBBYFILE
     , C_VIRTUALTACODE
     , D_ORI02CFMDATE
     , F_PFTREDRESSBAL
     , F_PROFITREDRESS
     , C_BLACKLEVEL
     , C_IPADDRESS
     , C_MACADDRESS
     , C_IMEI
     , C_UUID
     , C_NAMEINBANK
     , C_BANKACCO
     , D_DEFINENAVDATE
     , F_MANUALDEALSHARES
     , C_SUBFUNDCODE
     , C_XTFUNDACCO
     , F_PROFITBALANCE4ATTEND
     , C_ACTCODE
     , F_SVRRETFARE
     , F_SVRRETFARE4CUST
     , F_SVRRETFARE4AGC
     , F_FLOATMANAGEFEE
     , D_DEFPURDATE
     , C_ICDATA
     , F_PFTBAL2MACCO
     , C_SUBAGENCYNO
     , F_DEFINEBREAKRATIO
     , C_AUTOUNFRZ
     , C_RDMREASON
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_CDATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRM_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRM_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TCONFIRM_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TCONFIRM_PTD成功"
      exit 0
   fi
fi
