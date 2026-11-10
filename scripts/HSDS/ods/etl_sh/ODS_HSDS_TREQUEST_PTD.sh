#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TREQUEST_PTD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TREQUEST_PTD_TMP(
  C_CUSTTYPE  STRING  COMMENT  '客户类别',
  VC_FUNDACCO  STRING  COMMENT  '基金账号',
  VC_TRADEACCO  STRING  COMMENT  '交易账号',
  VC_REQUESTNO  STRING  COMMENT  '申请编号',
  VC_VOUCHERNO  STRING  COMMENT  '凭证编号',
  VC_NETNO  STRING  COMMENT  '网点',
  VC_CENTERNO  STRING  COMMENT  '分中心',
  VC_REQUESTDATE  STRING  COMMENT  '申请日期',
  VC_REQUESTTIME  STRING  COMMENT  '申请时间',
  C_BUSINFLAG  STRING  COMMENT  '业务代码',
  C_TRADEFLAG  STRING  COMMENT  '交易标识',
  C_REALLOTFLAG  STRING  COMMENT  '重新再投资标志',
  C_PROMISEFLAG  STRING  COMMENT  '承诺优惠标志',
  VC_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  C_TRUST  STRING  COMMENT  '委托方式',
  EN_BALANCE  DECIMAL(16,2)  COMMENT  '申请金额',
  EN_SHARE  DECIMAL(16,2)  COMMENT  '申请份额',
  EN_DISCOUNT  DECIMAL(5,4)  COMMENT  '折扣率',
  C_SENDSTATE  STRING  COMMENT  '发送状态',
  C_STATE  STRING  COMMENT  '申请校验',
  C_CONFIRMFLAG  STRING  COMMENT  '确认标志',
  C_FROZENFLAG  STRING  COMMENT  '冻结标志',
  C_MONEYTYPE  STRING  COMMENT  '币种',
  EN_CONFIRMSHARE  DECIMAL(16,2)  COMMENT  '确认份额',
  EN_CONFIRMBALA  DECIMAL(16,2)  COMMENT  '确认金额',
  VC_OPERATORNO  STRING  COMMENT  '操作员',
  VC_CHECKNO  STRING  COMMENT  '主管',
  VC_BROKER  STRING  COMMENT  '经纪人',
  C_EXCEEDFLAG  STRING  COMMENT  '巨额赎回标志',
  VC_HOPEDATE  STRING  COMMENT  '预约日期',
  C_ORIGINFLAG  STRING  COMMENT  '原始业务代码',
  VC_ORIGINNO  STRING  COMMENT  '原申请编号',
  VC_ORIGINDATE  STRING  COMMENT  '原申请日期',
  VC_ORIGINCONFIRMNO  STRING  COMMENT  '原确认编号',
  VC_ORIGINCONFIRMDATE  STRING  COMMENT  '原确认日期',
  C_BANKNO  STRING  COMMENT  '银行编号',
  VC_BANKNAME  STRING  COMMENT  '银行名称',
  VC_NAMEINBANK  STRING  COMMENT  '银行户名',
  VC_BANKACCO  STRING  COMMENT  '银行账号',
  C_CHANGETYPE  STRING  COMMENT  '过户类别',
  VC_OTHERACCO  STRING  COMMENT  '对方基金账号',
  VC_OTHERTRADEACCO  STRING  COMMENT  '对方交易账号',
  VC_OTHERFUNDCODE  STRING  COMMENT  '对方基金代码',
  C_OTHERSHARETYPE  STRING  COMMENT  '对方份额类别',
  C_OTHERAGENCYNO  STRING  COMMENT  '对方销售商',
  VC_OTHERNETNO  STRING  COMMENT  '对方网点',
  C_DIVIDENDMETHOD  STRING  COMMENT  '分红方式',
  C_FROZENCAUSE  STRING  COMMENT  '冻结原因',
  VC_EXPLAIN  STRING  COMMENT  '备注',
  C_CAPITALMODE  STRING  COMMENT  '资金方式',
  VC_PROTOCOL  STRING  COMMENT  '协议号',
  L_DELAYDAY  DECIMAL(4,0)  COMMENT  '允许顺延天数',
  L_PERMITNUM  DECIMAL(2,0)  COMMENT  '允许失败次数（备用）',
  VC_ENDDATE  STRING  COMMENT  '终止日期',
  VC_BEGINDATE  STRING  COMMENT  '首次交易日期',
  VC_BOOKNO  STRING  COMMENT  '协议书号',
  VC_CYCLE  STRING  COMMENT  '交易周期',
  VC_PROMISEDATE  STRING  COMMENT  '协议截止期限',
  VC_REGDATE  STRING  COMMENT  '份额注册日期',
  VC_CITYNO  STRING  COMMENT  '城市',
  VC_SELLER  STRING  COMMENT  '业务员',
  VC_TACODE  STRING  COMMENT  'ta代码',
  VC_DISCOUNTDATE  STRING  COMMENT  '折扣起始日',
  VC_FIXDAY  STRING  COMMENT  '交易日期',
  VC_COMBCODE  STRING  COMMENT  '组合编号',
  VC_COMBREQUESTNO  STRING  COMMENT  '组合申请号',
  EN_INVESTSCALE  DECIMAL(3,2)  COMMENT  '投资比例',
  C_AUDITFLAG  STRING  COMMENT  '复核标志',
  VC_AUDITNO  STRING  COMMENT  '复核员',
  EN_INVESTSHARE  DECIMAL(16,2)  COMMENT  '兑付份额',
  EN_ENDDISCOUNT  DECIMAL(5,4)  COMMENT  '后收费折扣',
  EN_OTHERDISCOUNT  DECIMAL(5,4)  COMMENT  '其他费折扣',
  C_CHECKFLAG  STRING  COMMENT  '审批标志',
  C_PROMOTION  STRING  COMMENT  '活动代码',
  VC_ACCEPTDATE  STRING  COMMENT  '下单日期',
  C_CUSTCONFIRM  STRING  COMMENT  '客户确认标志',
  VC_EXPONENTCODE  STRING  COMMENT  '指数代码',
  C_EXPONENTFLAG  STRING  COMMENT  '指数类别',
  EN_EXPONENTVALUE  DECIMAL(18,4)  COMMENT  '指数点位',
  EN_FACTBALA  DECIMAL(16,2)  COMMENT  '到帐金额',
  C_PARTFLAG  STRING  COMMENT  '部分扣款成功',
  EN_DUEFARE  DECIMAL(16,2)  COMMENT  '预估费用',
  VC_BRANCHCODE  STRING  COMMENT  '托管网点',
  C_FIXBUSINFLAG  STRING  COMMENT  '业务辅助代码',
  VC_SYSDATE  STRING  COMMENT  '系统日期',
  VC_PROCEDURENAME  STRING  COMMENT  '清算流程名',
  C_ACCOFLAG  STRING  COMMENT  '资金帐户标识',
  C_CPFLAG  STRING  COMMENT  '银联确认结果',
  C_DELETE  STRING  COMMENT  '删除标志',
  C_INVESTFLAG  STRING  COMMENT  '帐户备注',
  EN_PROMISEBALA  DECIMAL(22,2)  COMMENT  '承诺金额',
  EN_TRANSFERFEE  DECIMAL(22,2)  COMMENT  '转帐费',
  VC_BANKID  STRING  COMMENT  '银行id',
  VC_CPERRORCODE  STRING  COMMENT  '银联错误代码',
  VC_DEALPWD  STRING  COMMENT  '交易密码',
  VC_INVESTCONTENT  STRING  COMMENT  '投资内容',
  VC_OTHERSERIALNO  STRING  COMMENT  '对方资金流水号',
  VC_TRANSFERDATE  STRING  COMMENT  '划款日期',
  VC_SERVICENAME  STRING  COMMENT  '服务名',
  C_FUNCTIONNO  STRING  COMMENT  '功能号',
  VC_MACHINEDATE  STRING  COMMENT  '机器时间',
  C_RETURNFLAG  STRING  COMMENT  '返回标记',
  C_DISCOUNTFLAG  STRING  COMMENT  '强制折扣标志',
  C_SUBCAPITALMODE  STRING  COMMENT  '明细资金方式',
  VC_CONFIRMDATE  STRING  COMMENT  '确认日期',
  VC_BANKNETDATE  STRING  COMMENT  '银行网络时间',
  C_EXPORT  STRING  COMMENT  '指数类型',
  VC_TRADECONTACT  STRING  COMMENT  '交易经办人',
  VC_SECURITIESACCOUNT  STRING  COMMENT  '股东帐号',
  C_RISKFLAG  STRING  COMMENT  '预警标志',
  VC_BATCHNO  STRING  COMMENT  '批次号',
  VC_PROTOCOLNAME  STRING  COMMENT  '协议名称',
  C_CYCLEUNIT  STRING  COMMENT  '协议周期单位',
  C_EXPTYPE  STRING  COMMENT  '指数类型',
  L_MAXSUCCESSNUM  DECIMAL(10,0)  COMMENT  '最大成功次数',
  EN_MAXVALUE  DECIMAL(16,2)  COMMENT  '最大成功金额或份额',
  EN_MINSCALE1  DECIMAL(16,4)  COMMENT  '区间1涨跌幅左值',
  EN_MAXSCALE1  DECIMAL(16,4)  COMMENT  '区间1涨跌幅右值',
  EN_SCALBALANCE1  DECIMAL(16,2)  COMMENT  '区间1指定金额',
  EN_MINSCALE2  DECIMAL(16,4)  COMMENT  '区间2涨跌幅左值',
  EN_MAXSCALE2  DECIMAL(16,4)  COMMENT  '区间2涨跌幅右值',
  EN_SCALBALANCE2  DECIMAL(16,2)  COMMENT  '区间2指定金额',
  EN_MINSCALE3  DECIMAL(16,4)  COMMENT  '区间3涨跌幅左值',
  EN_MAXSCALE3  DECIMAL(16,4)  COMMENT  '区间3涨跌幅右值',
  EN_SCALBALANCE3  DECIMAL(16,2)  COMMENT  '区间3指定金额',
  C_ALLOWDEDUCT  STRING  COMMENT  '待查',
  C_AVGEXPONENTTYPE  STRING  COMMENT  '待查',
  EN_DIFFSCALE  DECIMAL(7,4)  COMMENT  '待查',
  C_AMLFULLFLAG  STRING  COMMENT  '',
  C_CUSTRISKTYPE  STRING  COMMENT  '',
  C_FUNDRISKLEVEL  STRING  COMMENT  '',
  VC_TRADEPURPOSE  STRING  COMMENT  '',
  C_BUSINTYPE  STRING  COMMENT  '',
  EN_UPPERLIMIT  DECIMAL(16,2)  COMMENT  '',
  EN_LOWERLIMIT  DECIMAL(16,2)  COMMENT  '',
  VC_LINKDEDUCTNO  STRING  COMMENT  '',
  VC_RECOVERDATE  STRING  COMMENT  '',
  VC_LASTDEDUCTTIME  STRING  COMMENT  '',
  L_COMMERRORNO  DECIMAL(3,0)  COMMENT  '',
  VC_COMMERRORMSG  STRING  COMMENT  '',
  VC_CPERRORMSG  STRING  COMMENT  '',
  C_SCANFLAG  STRING  COMMENT  '',
  L_SECTIONSCHEMANO  DECIMAL(9,0)  COMMENT  '',
  VC_SECTIONSCHEMATYPE  STRING  COMMENT  '',
  VC_FIXMONTH  STRING  COMMENT  '',
  EN_INVENSTRATE  DECIMAL(16,4)  COMMENT  '',
  VC_RECOMMENDER  STRING  COMMENT  '',
  VC_RECOMMENDERPHONE  STRING  COMMENT  '',
  VC_RECOMMENDERPROVINCE  STRING  COMMENT  '',
  VC_RECOMMENDERCITYNO  STRING  COMMENT  '',
  VC_COMEFROM  STRING  COMMENT  '',
  VC_SOURCEIPADDR  STRING  COMMENT  '',
  C_AUTOREQUEST  STRING  COMMENT  '',
  VC_DEDUCTFUNDCODE  STRING  COMMENT  '',
  VC_SUBACCONO  STRING  COMMENT  '',
  VC_SUBACCOAUDITNO  STRING  COMMENT  '',
  L_SPECIALLIQDAY  DECIMAL(3,0)  COMMENT  '',
  VC_INVESTORSYSTEMID  STRING  COMMENT  '',
  EN_MAXVALUEONCE  DECIMAL(16,2)  COMMENT  '',
  EN_MINRETAINEDBALA  DECIMAL(16,2)  COMMENT  '',
  EN_LOWERDEDUCTBALA  DECIMAL(16,2)  COMMENT  '',
  VC_CUSTNO  STRING  COMMENT  '',
  C_FIXCOMBTYPE  STRING  COMMENT  '',
  VC_BATCHSELECTNO  STRING  COMMENT  '',
  VC_HEDGEFUNDCODE  STRING  COMMENT  '',
  C_HEDGESHARETYPE  STRING  COMMENT  '',
  C_SHORTAVGEXPONENTTYPE  STRING  COMMENT  '',
  C_MEDIUMAVGEXPONENTTYPE  STRING  COMMENT  '',
  C_LONGAVGEXPONENTTYPE  STRING  COMMENT  '',
  VC_HEDGEPROTOCOL  STRING  COMMENT  '',
  C_BREAKFLAG  STRING  COMMENT  '',
  VC_BATCHREQUESTNO  STRING  COMMENT  '',
  VC_SELFCOMBCODE  STRING  COMMENT  '',
  VC_MATCHNO  STRING  COMMENT  '',
  VC_MATCHAUDITNO  STRING  COMMENT  '',
  VC_CONTRACTNO  STRING  COMMENT  '',
  C_REDEEMUSEFLAG  STRING  COMMENT  '',
  C_RECREATEBATCHNO  STRING  COMMENT  '',
  VC_CONFIRMSETTLEDATE  STRING  COMMENT  '',
  VC_REQUESTSETTLEDATE  STRING  COMMENT  '',
  VC_CONTRACTSERIALNO  STRING  COMMENT  '',
  C_PROFITCLASS  STRING  COMMENT  '',
  VC_REJECTREASON  STRING  COMMENT  '',
  VC_EXTCOMBCODE  STRING  COMMENT  '',
  C_NONWORKDAYDELAY  STRING  COMMENT  '',
  VC_PAYMENTACCONO  STRING  COMMENT  '',
  VC_PAYMENTDATE  STRING  COMMENT  '',
  VC_PAYMENTTYPE  STRING  COMMENT  '',
  C_INTERFACETYPE  STRING  COMMENT  '',
  VC_CDCARD  STRING  COMMENT  '',
  VC_CHINAPAYSERIALNO  STRING  COMMENT  '',
  C_PAYMENTBALATYPE  STRING  COMMENT  '',
  EN_INCOME  DECIMAL(16,2)  COMMENT  '',
  C_DEALFLAG  STRING  COMMENT  '',
  C_LOANFLAG  STRING  COMMENT  '',
  C_SYNSTATE  STRING  COMMENT  '',
  C_NEEDDEDUCT  STRING  COMMENT  '',
  C_NEEDTRANSFER  STRING  COMMENT  '',
  C_CHANGEDIRECT  STRING  COMMENT  '',
  C_HKCAPITALMODE  STRING  COMMENT  '',
  VC_LONGCDCARD  STRING  COMMENT  '',
  VC_BILLSERIALNO  STRING  COMMENT  '',
  VC_USECONTENT  STRING  COMMENT  '',
  C_FTREDEEMMODE  STRING  COMMENT  '',
  VC_BANKNETTIME  STRING  COMMENT  '',
  VC_BOOKID  STRING  COMMENT  '',
  VC_UNFROZENDATE  STRING  COMMENT  '',
  VC_INVESTDATE  STRING  COMMENT  '',
  VC_NEEDDATE  STRING  COMMENT  '',
  C_BANKPROVINCECODE  STRING  COMMENT  '',
  VC_BANKCITYNO  STRING  COMMENT  '',
  C_ACCOID  STRING  COMMENT  '',
  VC_CONFIRMBENEFITSERIALNO  STRING  COMMENT  '',
  C_FTRDMTRANSMODE  STRING  COMMENT  '',
  C_CAPINFLAG  STRING  COMMENT  '',
  C_NEEDFROZENSHARE  STRING  COMMENT  '',
  C_IDENTITYTYPEINBANK  STRING  COMMENT  '',
  VC_IDENTITYNOINBANK  STRING  COMMENT  '',
  VC_LIQUIDATEDATE  STRING  COMMENT  '',
  VC_FUSEORIDATE  STRING  COMMENT  '',
  EN_COUPON  DECIMAL(16,2)  COMMENT  '',
  EN_NAV  DECIMAL(8,5)  COMMENT  '',
  VC_SHAREEXPIREDATE  STRING  COMMENT  '',
  VC_OUTREQUESTNO  STRING  COMMENT  '',
  EN_GRAMNUM  DECIMAL(16,4)  COMMENT  '',
  VC_RESUBDATE  STRING  COMMENT  '',
  VC_CALMTIME  STRING  COMMENT  '',
  VC_REGISTERSERIALNO  STRING  COMMENT  '',
  VC_FULLNAMEINBANK  STRING  COMMENT  '',
  VC_ORIOPERATORNO  STRING  COMMENT  '',
  C_CUSTFUNDTIMELIMITMATCHFLAG  STRING  COMMENT  '',
  C_INVESTVARIETIESMATCHFLAG  STRING  COMMENT  '',
  C_CUSTINVESTMENTVARIETIES  STRING  COMMENT  '',
  C_FUNDINVESTMENTVARIETIES  STRING  COMMENT  '',
  EN_CUSTTIMELIMIT  DECIMAL(8,0)  COMMENT  '',
  EN_FUNDTIMELIMIT  DECIMAL(8,0)  COMMENT  '',
  VC_COOLSTARTTIME  STRING  COMMENT  '',
  VC_ERRORINFO  STRING  COMMENT  '',
  VC_TRADECONFIRMNO  STRING  COMMENT  '',
  EN_CONFIRMNAV  DECIMAL(8,5)  COMMENT  '',
  C_SPLITFLAG  STRING  COMMENT  '',
  EN_ORIBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_RENEWALSTATUS  STRING  COMMENT  '',
  EN_CONFIRMFARE  DECIMAL(16,2)  COMMENT  '',
  C_ORICAPITALMODE  STRING  COMMENT  '',
  EN_CUTSHARE  DECIMAL(16,2)  COMMENT  '',
  EN_CUTBALA  DECIMAL(16,2)  COMMENT  '',
  C_EXPORTSTATE  STRING  COMMENT  '',
  C_RECORD  STRING  COMMENT  '',
  C_PLEDGEFLAG  STRING  COMMENT  '',
  C_AUTOCAPIN  STRING  COMMENT  '',
  C_LIMITFLAG  STRING  COMMENT  '',
  VC_RECORDSERIALNO  STRING  COMMENT  '',
  VC_SPECIFYREQUESTDATE  STRING  COMMENT  '',
  EN_TARGETBALANCE  DECIMAL(16,2)  COMMENT  '',
  VC_FIXTHEME  STRING  COMMENT  '',
  C_AUTOBUYFUNDFLAG  STRING  COMMENT  '',
  EN_COMBREDEEMSCALE  DECIMAL(5,4)  COMMENT  '',
  C_CHARGEWAY  STRING  COMMENT  '',
  VC_PARTNERDATETIME  STRING  COMMENT  '',
  VC_TIMESTAMP  STRING  COMMENT  '',
  C_STOPPROFIT  STRING  COMMENT  '',
  EN_DEDUCTREGSHARE  DECIMAL(16,2)  COMMENT  '',
  EN_DEDUCTONWAYSHARE  DECIMAL(16,2)  COMMENT  '',
  EN_CURRENTFUND  DECIMAL(16,2)  COMMENT  '',
  C_STRATEGYTYPE  STRING  COMMENT  '',
  VC_ELECFAXNO  STRING  COMMENT  '',
  VC_RESUBSCRIBEDATE  STRING  COMMENT  '',
  VC_COUPONIDNO  STRING  COMMENT  '',
  C_PENATRATEFLAG  STRING  COMMENT  '',
  VC_SUBFUNDCODE  STRING  COMMENT  '',
  VC_MERCHANTNO  STRING  COMMENT  '',
  VC_INTRODEPT  STRING  COMMENT  '',
  VC_INTRODUCER  STRING  COMMENT  '',
  VC_BRANCHOFFICE  STRING  COMMENT  '',
  VC_BUSINDEPT  STRING  COMMENT  '',
  VC_BUSINDEPTINTRO  STRING  COMMENT  '',
  VC_CARRYDAY  STRING  COMMENT  '',
  EN_TRANSINFEE  DECIMAL(16,2)  COMMENT  '',
  EN_TRANSOUTFEE  DECIMAL(16,2)  COMMENT  '',
  VC_PLATFORMNO  STRING  COMMENT  '',
  VC_BATCHOTHERSERIALNO  STRING  COMMENT  '',
  VC_HEDGETRADEACCO  STRING  COMMENT  '',
  EN_REALOTHERDISCOUNT  DECIMAL(5,4)  COMMENT  '',
  C_CHANGEHOLDINGSTATE  STRING  COMMENT  '',
  C_CHANGEHOLDINGSTATEBAK  STRING  COMMENT  '',
  VC_VIDEOID  STRING  COMMENT  '',
  L_T0EXPORTBATCHNO  DECIMAL(4,0)  COMMENT  '',
  C_ACTIVATIONFLAG  STRING  COMMENT  '',
  C_REVIEWSLEEPFLAG  STRING  COMMENT  '',
  VC_RECORDDATETIME  STRING  COMMENT  '',
  C_RECORDTYPE  STRING  COMMENT  '',
  C_NEEDRECORD  STRING  COMMENT  '',
  C_POSTPONE  STRING  COMMENT  ''
)
COMMENT '交易申请表'
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
              "querySql": ["SELECT  C_CUSTTYPE\n                                   , VC_FUNDACCO\n                                   , VC_TRADEACCO\n                                   , VC_REQUESTNO\n                                   , VC_VOUCHERNO\n                                   , VC_NETNO\n                                   , VC_CENTERNO\n                                   , VC_REQUESTDATE\n                                   , VC_REQUESTTIME\n                                   , C_BUSINFLAG\n                                   , C_TRADEFLAG\n                                   , C_REALLOTFLAG\n                                   , C_PROMISEFLAG\n                                   , VC_FUNDCODE\n                                   , C_SHARETYPE\n                                   , C_TRUST\n                                   , EN_BALANCE\n                                   , EN_SHARE\n                                   , EN_DISCOUNT\n                                   , C_SENDSTATE\n                                   , C_STATE\n                                   , C_CONFIRMFLAG\n                                   , C_FROZENFLAG\n                                   , C_MONEYTYPE\n                                   , EN_CONFIRMSHARE\n                                   , EN_CONFIRMBALA\n                                   , VC_OPERATORNO\n                                   , VC_CHECKNO\n                                   , VC_BROKER\n                                   , C_EXCEEDFLAG\n                                   , VC_HOPEDATE\n                                   , C_ORIGINFLAG\n                                   , VC_ORIGINNO\n                                   , VC_ORIGINDATE\n                                   , VC_ORIGINCONFIRMNO\n                                   , VC_ORIGINCONFIRMDATE\n                                   , C_BANKNO\n                                   , VC_BANKNAME\n                                   , VC_NAMEINBANK\n                                   , VC_BANKACCO\n                                   , C_CHANGETYPE\n                                   , VC_OTHERACCO\n                                   , VC_OTHERTRADEACCO\n                                   , VC_OTHERFUNDCODE\n                                   , C_OTHERSHARETYPE\n                                   , C_OTHERAGENCYNO\n                                   , VC_OTHERNETNO\n                                   , C_DIVIDENDMETHOD\n                                   , C_FROZENCAUSE\n                                   , VC_EXPLAIN\n                                   , C_CAPITALMODE\n                                   , VC_PROTOCOL\n                                   , L_DELAYDAY\n                                   , L_PERMITNUM\n                                   , VC_ENDDATE\n                                   , VC_BEGINDATE\n                                   , VC_BOOKNO\n                                   , VC_CYCLE\n                                   , VC_PROMISEDATE\n                                   , VC_REGDATE\n                                   , VC_CITYNO\n                                   , VC_SELLER\n                                   , VC_TACODE\n                                   , VC_DISCOUNTDATE\n                                   , VC_FIXDAY\n                                   , VC_COMBCODE\n                                   , VC_COMBREQUESTNO\n                                   , EN_INVESTSCALE\n                                   , C_AUDITFLAG\n                                   , VC_AUDITNO\n                                   , EN_INVESTSHARE\n                                   , EN_ENDDISCOUNT\n                                   , EN_OTHERDISCOUNT\n                                   , C_CHECKFLAG\n                                   , C_PROMOTION\n                                   , VC_ACCEPTDATE\n                                   , C_CUSTCONFIRM\n                                   , VC_EXPONENTCODE\n                                   , C_EXPONENTFLAG\n                                   , EN_EXPONENTVALUE\n                                   , EN_FACTBALA\n                                   , C_PARTFLAG\n                                   , EN_DUEFARE\n                                   , VC_BRANCHCODE\n                                   , C_FIXBUSINFLAG\n                                   , VC_SYSDATE\n                                   , VC_PROCEDURENAME\n                                   , C_ACCOFLAG\n                                   , C_CPFLAG\n                                   , C_DELETE\n                                   , C_INVESTFLAG\n                                   , EN_PROMISEBALA\n                                   , EN_TRANSFERFEE\n                                   , VC_BANKID\n                                   , VC_CPERRORCODE\n                                   , VC_DEALPWD\n                                   , VC_INVESTCONTENT\n                                   , VC_OTHERSERIALNO\n                                   , VC_TRANSFERDATE\n                                   , VC_SERVICENAME\n                                   , C_FUNCTIONNO\n                                   , VC_MACHINEDATE\n                                   , C_RETURNFLAG\n                                   , C_DISCOUNTFLAG\n                                   , C_SUBCAPITALMODE\n                                   , VC_CONFIRMDATE\n                                   , VC_BANKNETDATE\n                                   , C_EXPORT\n                                   , VC_TRADECONTACT\n                                   , VC_SECURITIESACCOUNT\n                                   , C_RISKFLAG\n                                   , VC_BATCHNO\n                                   , VC_PROTOCOLNAME\n                                   , C_CYCLEUNIT\n                                   , C_EXPTYPE\n                                   , L_MAXSUCCESSNUM\n                                   , EN_MAXVALUE\n                                   , EN_MINSCALE1\n                                   , EN_MAXSCALE1\n                                   , EN_SCALBALANCE1\n                                   , EN_MINSCALE2\n                                   , EN_MAXSCALE2\n                                   , EN_SCALBALANCE2\n                                   , EN_MINSCALE3\n                                   , EN_MAXSCALE3\n                                   , EN_SCALBALANCE3\n                                   , C_ALLOWDEDUCT\n                                   , C_AVGEXPONENTTYPE\n                                   , EN_DIFFSCALE\n                                   , C_AMLFULLFLAG\n                                   , C_CUSTRISKTYPE\n                                   , C_FUNDRISKLEVEL\n                                   , VC_TRADEPURPOSE\n                                   , C_BUSINTYPE\n                                   , EN_UPPERLIMIT\n                                   , EN_LOWERLIMIT\n                                   , VC_LINKDEDUCTNO\n                                   , VC_RECOVERDATE\n                                   , VC_LASTDEDUCTTIME\n                                   , L_COMMERRORNO\n                                   , VC_COMMERRORMSG\n                                   , VC_CPERRORMSG\n                                   , C_SCANFLAG\n                                   , L_SECTIONSCHEMANO\n                                   , VC_SECTIONSCHEMATYPE\n                                   , VC_FIXMONTH\n                                   , EN_INVENSTRATE\n                                   , VC_RECOMMENDER\n                                   , VC_RECOMMENDERPHONE\n                                   , VC_RECOMMENDERPROVINCE\n                                   , VC_RECOMMENDERCITYNO\n                                   , VC_COMEFROM\n                                   , VC_SOURCEIPADDR\n                                   , C_AUTOREQUEST\n                                   , VC_DEDUCTFUNDCODE\n                                   , VC_SUBACCONO\n                                   , VC_SUBACCOAUDITNO\n                                   , L_SPECIALLIQDAY\n                                   , VC_INVESTORSYSTEMID\n                                   , EN_MAXVALUEONCE\n                                   , EN_MINRETAINEDBALA\n                                   , EN_LOWERDEDUCTBALA\n                                   , VC_CUSTNO\n                                   , C_FIXCOMBTYPE\n                                   , VC_BATCHSELECTNO\n                                   , VC_HEDGEFUNDCODE\n                                   , C_HEDGESHARETYPE\n                                   , C_SHORTAVGEXPONENTTYPE\n                                   , C_MEDIUMAVGEXPONENTTYPE\n                                   , C_LONGAVGEXPONENTTYPE\n                                   , VC_HEDGEPROTOCOL\n                                   , C_BREAKFLAG\n                                   , VC_BATCHREQUESTNO\n                                   , VC_SELFCOMBCODE\n                                   , VC_MATCHNO\n                                   , VC_MATCHAUDITNO\n                                   , VC_CONTRACTNO\n                                   , C_REDEEMUSEFLAG\n                                   , C_RECREATEBATCHNO\n                                   , VC_CONFIRMSETTLEDATE\n                                   , VC_REQUESTSETTLEDATE\n                                   , VC_CONTRACTSERIALNO\n                                   , C_PROFITCLASS\n                                   , VC_REJECTREASON\n                                   , VC_EXTCOMBCODE\n                                   , C_NONWORKDAYDELAY\n                                   , VC_PAYMENTACCONO\n                                   , VC_PAYMENTDATE\n                                   , VC_PAYMENTTYPE\n                                   , C_INTERFACETYPE\n                                   , VC_CDCARD\n                                   , VC_CHINAPAYSERIALNO\n                                   , C_PAYMENTBALATYPE\n                                   , EN_INCOME\n                                   , C_DEALFLAG\n                                   , C_LOANFLAG\n                                   , C_SYNSTATE\n                                   , C_NEEDDEDUCT\n                                   , C_NEEDTRANSFER\n                                   , C_CHANGEDIRECT\n                                   , C_HKCAPITALMODE\n                                   , VC_LONGCDCARD\n                                   , VC_BILLSERIALNO\n                                   , VC_USECONTENT\n                                   , C_FTREDEEMMODE\n                                   , VC_BANKNETTIME\n                                   , VC_BOOKID\n                                   , VC_UNFROZENDATE\n                                   , VC_INVESTDATE\n                                   , VC_NEEDDATE\n                                   , C_BANKPROVINCECODE\n                                   , VC_BANKCITYNO\n                                   , C_ACCOID\n                                   , VC_CONFIRMBENEFITSERIALNO\n                                   , C_FTRDMTRANSMODE\n                                   , C_CAPINFLAG\n                                   , C_NEEDFROZENSHARE\n                                   , C_IDENTITYTYPEINBANK\n                                   , VC_IDENTITYNOINBANK\n                                   , VC_LIQUIDATEDATE\n                                   , VC_FUSEORIDATE\n                                   , EN_COUPON\n                                   , EN_NAV\n                                   , VC_SHAREEXPIREDATE\n                                   , VC_OUTREQUESTNO\n                                   , EN_GRAMNUM\n                                   , VC_RESUBDATE\n                                   , VC_CALMTIME\n                                   , VC_REGISTERSERIALNO\n                                   , VC_FULLNAMEINBANK\n                                   , VC_ORIOPERATORNO\n                                   , C_CUSTFUNDTIMELIMITMATCHFLAG\n                                   , C_INVESTVARIETIESMATCHFLAG\n                                   , C_CUSTINVESTMENTVARIETIES\n                                   , C_FUNDINVESTMENTVARIETIES\n                                   , EN_CUSTTIMELIMIT\n                                   , EN_FUNDTIMELIMIT\n                                   , VC_COOLSTARTTIME\n                                   , VC_ERRORINFO\n                                   , VC_TRADECONFIRMNO\n                                   , EN_CONFIRMNAV\n                                   , C_SPLITFLAG\n                                   , EN_ORIBALANCE\n                                   , C_RENEWALSTATUS\n                                   , EN_CONFIRMFARE\n                                   , C_ORICAPITALMODE\n                                   , EN_CUTSHARE\n                                   , EN_CUTBALA\n                                   , C_EXPORTSTATE\n                                   , C_RECORD\n                                   , C_PLEDGEFLAG\n                                   , C_AUTOCAPIN\n                                   , C_LIMITFLAG\n                                   , VC_RECORDSERIALNO\n                                   , VC_SPECIFYREQUESTDATE\n                                   , EN_TARGETBALANCE\n                                   , VC_FIXTHEME\n                                   , C_AUTOBUYFUNDFLAG\n                                   , EN_COMBREDEEMSCALE\n                                   , C_CHARGEWAY\n                                   , VC_PARTNERDATETIME\n                                   , VC_TIMESTAMP\n                                   , C_STOPPROFIT\n                                   , EN_DEDUCTREGSHARE\n                                   , EN_DEDUCTONWAYSHARE\n                                   , EN_CURRENTFUND\n                                   , C_STRATEGYTYPE\n                                   , VC_ELECFAXNO\n                                   , VC_RESUBSCRIBEDATE\n                                   , VC_COUPONIDNO\n                                   , C_PENATRATEFLAG\n                                   , VC_SUBFUNDCODE\n                                   , VC_MERCHANTNO\n                                   , VC_INTRODEPT\n                                   , VC_INTRODUCER\n                                   , VC_BRANCHOFFICE\n                                   , VC_BUSINDEPT\n                                   , VC_BUSINDEPTINTRO\n                                   , VC_CARRYDAY\n                                   , EN_TRANSINFEE\n                                   , EN_TRANSOUTFEE\n                                   , VC_PLATFORMNO\n                                   , VC_BATCHOTHERSERIALNO\n                                   , VC_HEDGETRADEACCO\n                                   , EN_REALOTHERDISCOUNT\n                                   , C_CHANGEHOLDINGSTATE\n                                   , C_CHANGEHOLDINGSTATEBAK\n                                   , VC_VIDEOID\n                                   , L_T0EXPORTBATCHNO\n                                   , C_ACTIVATIONFLAG\n                                   , C_REVIEWSLEEPFLAG\n                                   , VC_RECORDDATETIME\n                                   , C_RECORDTYPE\n                                   , C_NEEDRECORD\n                                   , C_POSTPONE\n                                FROM ${hsds_src_schema}.TREQUEST\n                                WHERE VC_REQUESTDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "VC_FUNDACCO", "type": "STRING"}, {"name": "VC_TRADEACCO", "type": "STRING"}, {"name": "VC_REQUESTNO", "type": "STRING"}, {"name": "VC_VOUCHERNO", "type": "STRING"}, {"name": "VC_NETNO", "type": "STRING"}, {"name": "VC_CENTERNO", "type": "STRING"}, {"name": "VC_REQUESTDATE", "type": "STRING"}, {"name": "VC_REQUESTTIME", "type": "STRING"}, {"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "C_TRADEFLAG", "type": "STRING"}, {"name": "C_REALLOTFLAG", "type": "STRING"}, {"name": "C_PROMISEFLAG", "type": "STRING"}, {"name": "VC_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_TRUST", "type": "STRING"}, {"name": "EN_BALANCE", "type": "DOUBLE"}, {"name": "EN_SHARE", "type": "DOUBLE"}, {"name": "EN_DISCOUNT", "type": "DOUBLE"}, {"name": "C_SENDSTATE", "type": "STRING"}, {"name": "C_STATE", "type": "STRING"}, {"name": "C_CONFIRMFLAG", "type": "STRING"}, {"name": "C_FROZENFLAG", "type": "STRING"}, {"name": "C_MONEYTYPE", "type": "STRING"}, {"name": "EN_CONFIRMSHARE", "type": "DOUBLE"}, {"name": "EN_CONFIRMBALA", "type": "DOUBLE"}, {"name": "VC_OPERATORNO", "type": "STRING"}, {"name": "VC_CHECKNO", "type": "STRING"}, {"name": "VC_BROKER", "type": "STRING"}, {"name": "C_EXCEEDFLAG", "type": "STRING"}, {"name": "VC_HOPEDATE", "type": "STRING"}, {"name": "C_ORIGINFLAG", "type": "STRING"}, {"name": "VC_ORIGINNO", "type": "STRING"}, {"name": "VC_ORIGINDATE", "type": "STRING"}, {"name": "VC_ORIGINCONFIRMNO", "type": "STRING"}, {"name": "VC_ORIGINCONFIRMDATE", "type": "STRING"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "VC_BANKNAME", "type": "STRING"}, {"name": "VC_NAMEINBANK", "type": "STRING"}, {"name": "VC_BANKACCO", "type": "STRING"}, {"name": "C_CHANGETYPE", "type": "STRING"}, {"name": "VC_OTHERACCO", "type": "STRING"}, {"name": "VC_OTHERTRADEACCO", "type": "STRING"}, {"name": "VC_OTHERFUNDCODE", "type": "STRING"}, {"name": "C_OTHERSHARETYPE", "type": "STRING"}, {"name": "C_OTHERAGENCYNO", "type": "STRING"}, {"name": "VC_OTHERNETNO", "type": "STRING"}, {"name": "C_DIVIDENDMETHOD", "type": "STRING"}, {"name": "C_FROZENCAUSE", "type": "STRING"}, {"name": "VC_EXPLAIN", "type": "STRING"}, {"name": "C_CAPITALMODE", "type": "STRING"}, {"name": "VC_PROTOCOL", "type": "STRING"}, {"name": "L_DELAYDAY", "type": "DOUBLE"}, {"name": "L_PERMITNUM", "type": "DOUBLE"}, {"name": "VC_ENDDATE", "type": "STRING"}, {"name": "VC_BEGINDATE", "type": "STRING"}, {"name": "VC_BOOKNO", "type": "STRING"}, {"name": "VC_CYCLE", "type": "STRING"}, {"name": "VC_PROMISEDATE", "type": "STRING"}, {"name": "VC_REGDATE", "type": "STRING"}, {"name": "VC_CITYNO", "type": "STRING"}, {"name": "VC_SELLER", "type": "STRING"}, {"name": "VC_TACODE", "type": "STRING"}, {"name": "VC_DISCOUNTDATE", "type": "STRING"}, {"name": "VC_FIXDAY", "type": "STRING"}, {"name": "VC_COMBCODE", "type": "STRING"}, {"name": "VC_COMBREQUESTNO", "type": "STRING"}, {"name": "EN_INVESTSCALE", "type": "DOUBLE"}, {"name": "C_AUDITFLAG", "type": "STRING"}, {"name": "VC_AUDITNO", "type": "STRING"}, {"name": "EN_INVESTSHARE", "type": "DOUBLE"}, {"name": "EN_ENDDISCOUNT", "type": "DOUBLE"}, {"name": "EN_OTHERDISCOUNT", "type": "DOUBLE"}, {"name": "C_CHECKFLAG", "type": "STRING"}, {"name": "C_PROMOTION", "type": "STRING"}, {"name": "VC_ACCEPTDATE", "type": "STRING"}, {"name": "C_CUSTCONFIRM", "type": "STRING"}, {"name": "VC_EXPONENTCODE", "type": "STRING"}, {"name": "C_EXPONENTFLAG", "type": "STRING"}, {"name": "EN_EXPONENTVALUE", "type": "DOUBLE"}, {"name": "EN_FACTBALA", "type": "DOUBLE"}, {"name": "C_PARTFLAG", "type": "STRING"}, {"name": "EN_DUEFARE", "type": "DOUBLE"}, {"name": "VC_BRANCHCODE", "type": "STRING"}, {"name": "C_FIXBUSINFLAG", "type": "STRING"}, {"name": "VC_SYSDATE", "type": "STRING"}, {"name": "VC_PROCEDURENAME", "type": "STRING"}, {"name": "C_ACCOFLAG", "type": "STRING"}, {"name": "C_CPFLAG", "type": "STRING"}, {"name": "C_DELETE", "type": "STRING"}, {"name": "C_INVESTFLAG", "type": "STRING"}, {"name": "EN_PROMISEBALA", "type": "DOUBLE"}, {"name": "EN_TRANSFERFEE", "type": "DOUBLE"}, {"name": "VC_BANKID", "type": "STRING"}, {"name": "VC_CPERRORCODE", "type": "STRING"}, {"name": "VC_DEALPWD", "type": "STRING"}, {"name": "VC_INVESTCONTENT", "type": "STRING"}, {"name": "VC_OTHERSERIALNO", "type": "STRING"}, {"name": "VC_TRANSFERDATE", "type": "STRING"}, {"name": "VC_SERVICENAME", "type": "STRING"}, {"name": "C_FUNCTIONNO", "type": "STRING"}, {"name": "VC_MACHINEDATE", "type": "STRING"}, {"name": "C_RETURNFLAG", "type": "STRING"}, {"name": "C_DISCOUNTFLAG", "type": "STRING"}, {"name": "C_SUBCAPITALMODE", "type": "STRING"}, {"name": "VC_CONFIRMDATE", "type": "STRING"}, {"name": "VC_BANKNETDATE", "type": "STRING"}, {"name": "C_EXPORT", "type": "STRING"}, {"name": "VC_TRADECONTACT", "type": "STRING"}, {"name": "VC_SECURITIESACCOUNT", "type": "STRING"}, {"name": "C_RISKFLAG", "type": "STRING"}, {"name": "VC_BATCHNO", "type": "STRING"}, {"name": "VC_PROTOCOLNAME", "type": "STRING"}, {"name": "C_CYCLEUNIT", "type": "STRING"}, {"name": "C_EXPTYPE", "type": "STRING"}, {"name": "L_MAXSUCCESSNUM", "type": "DOUBLE"}, {"name": "EN_MAXVALUE", "type": "DOUBLE"}, {"name": "EN_MINSCALE1", "type": "DOUBLE"}, {"name": "EN_MAXSCALE1", "type": "DOUBLE"}, {"name": "EN_SCALBALANCE1", "type": "DOUBLE"}, {"name": "EN_MINSCALE2", "type": "DOUBLE"}, {"name": "EN_MAXSCALE2", "type": "DOUBLE"}, {"name": "EN_SCALBALANCE2", "type": "DOUBLE"}, {"name": "EN_MINSCALE3", "type": "DOUBLE"}, {"name": "EN_MAXSCALE3", "type": "DOUBLE"}, {"name": "EN_SCALBALANCE3", "type": "DOUBLE"}, {"name": "C_ALLOWDEDUCT", "type": "STRING"}, {"name": "C_AVGEXPONENTTYPE", "type": "STRING"}, {"name": "EN_DIFFSCALE", "type": "DOUBLE"}, {"name": "C_AMLFULLFLAG", "type": "STRING"}, {"name": "C_CUSTRISKTYPE", "type": "STRING"}, {"name": "C_FUNDRISKLEVEL", "type": "STRING"}, {"name": "VC_TRADEPURPOSE", "type": "STRING"}, {"name": "C_BUSINTYPE", "type": "STRING"}, {"name": "EN_UPPERLIMIT", "type": "DOUBLE"}, {"name": "EN_LOWERLIMIT", "type": "DOUBLE"}, {"name": "VC_LINKDEDUCTNO", "type": "STRING"}, {"name": "VC_RECOVERDATE", "type": "STRING"}, {"name": "VC_LASTDEDUCTTIME", "type": "STRING"}, {"name": "L_COMMERRORNO", "type": "DOUBLE"}, {"name": "VC_COMMERRORMSG", "type": "STRING"}, {"name": "VC_CPERRORMSG", "type": "STRING"}, {"name": "C_SCANFLAG", "type": "STRING"}, {"name": "L_SECTIONSCHEMANO", "type": "DOUBLE"}, {"name": "VC_SECTIONSCHEMATYPE", "type": "STRING"}, {"name": "VC_FIXMONTH", "type": "STRING"}, {"name": "EN_INVENSTRATE", "type": "DOUBLE"}, {"name": "VC_RECOMMENDER", "type": "STRING"}, {"name": "VC_RECOMMENDERPHONE", "type": "STRING"}, {"name": "VC_RECOMMENDERPROVINCE", "type": "STRING"}, {"name": "VC_RECOMMENDERCITYNO", "type": "STRING"}, {"name": "VC_COMEFROM", "type": "STRING"}, {"name": "VC_SOURCEIPADDR", "type": "STRING"}, {"name": "C_AUTOREQUEST", "type": "STRING"}, {"name": "VC_DEDUCTFUNDCODE", "type": "STRING"}, {"name": "VC_SUBACCONO", "type": "STRING"}, {"name": "VC_SUBACCOAUDITNO", "type": "STRING"}, {"name": "L_SPECIALLIQDAY", "type": "DOUBLE"}, {"name": "VC_INVESTORSYSTEMID", "type": "STRING"}, {"name": "EN_MAXVALUEONCE", "type": "DOUBLE"}, {"name": "EN_MINRETAINEDBALA", "type": "DOUBLE"}, {"name": "EN_LOWERDEDUCTBALA", "type": "DOUBLE"}, {"name": "VC_CUSTNO", "type": "STRING"}, {"name": "C_FIXCOMBTYPE", "type": "STRING"}, {"name": "VC_BATCHSELECTNO", "type": "STRING"}, {"name": "VC_HEDGEFUNDCODE", "type": "STRING"}, {"name": "C_HEDGESHARETYPE", "type": "STRING"}, {"name": "C_SHORTAVGEXPONENTTYPE", "type": "STRING"}, {"name": "C_MEDIUMAVGEXPONENTTYPE", "type": "STRING"}, {"name": "C_LONGAVGEXPONENTTYPE", "type": "STRING"}, {"name": "VC_HEDGEPROTOCOL", "type": "STRING"}, {"name": "C_BREAKFLAG", "type": "STRING"}, {"name": "VC_BATCHREQUESTNO", "type": "STRING"}, {"name": "VC_SELFCOMBCODE", "type": "STRING"}, {"name": "VC_MATCHNO", "type": "STRING"}, {"name": "VC_MATCHAUDITNO", "type": "STRING"}, {"name": "VC_CONTRACTNO", "type": "STRING"}, {"name": "C_REDEEMUSEFLAG", "type": "STRING"}, {"name": "C_RECREATEBATCHNO", "type": "STRING"}, {"name": "VC_CONFIRMSETTLEDATE", "type": "STRING"}, {"name": "VC_REQUESTSETTLEDATE", "type": "STRING"}, {"name": "VC_CONTRACTSERIALNO", "type": "STRING"}, {"name": "C_PROFITCLASS", "type": "STRING"}, {"name": "VC_REJECTREASON", "type": "STRING"}, {"name": "VC_EXTCOMBCODE", "type": "STRING"}, {"name": "C_NONWORKDAYDELAY", "type": "STRING"}, {"name": "VC_PAYMENTACCONO", "type": "STRING"}, {"name": "VC_PAYMENTDATE", "type": "STRING"}, {"name": "VC_PAYMENTTYPE", "type": "STRING"}, {"name": "C_INTERFACETYPE", "type": "STRING"}, {"name": "VC_CDCARD", "type": "STRING"}, {"name": "VC_CHINAPAYSERIALNO", "type": "STRING"}, {"name": "C_PAYMENTBALATYPE", "type": "STRING"}, {"name": "EN_INCOME", "type": "DOUBLE"}, {"name": "C_DEALFLAG", "type": "STRING"}, {"name": "C_LOANFLAG", "type": "STRING"}, {"name": "C_SYNSTATE", "type": "STRING"}, {"name": "C_NEEDDEDUCT", "type": "STRING"}, {"name": "C_NEEDTRANSFER", "type": "STRING"}, {"name": "C_CHANGEDIRECT", "type": "STRING"}, {"name": "C_HKCAPITALMODE", "type": "STRING"}, {"name": "VC_LONGCDCARD", "type": "STRING"}, {"name": "VC_BILLSERIALNO", "type": "STRING"}, {"name": "VC_USECONTENT", "type": "STRING"}, {"name": "C_FTREDEEMMODE", "type": "STRING"}, {"name": "VC_BANKNETTIME", "type": "STRING"}, {"name": "VC_BOOKID", "type": "STRING"}, {"name": "VC_UNFROZENDATE", "type": "STRING"}, {"name": "VC_INVESTDATE", "type": "STRING"}, {"name": "VC_NEEDDATE", "type": "STRING"}, {"name": "C_BANKPROVINCECODE", "type": "STRING"}, {"name": "VC_BANKCITYNO", "type": "STRING"}, {"name": "C_ACCOID", "type": "STRING"}, {"name": "VC_CONFIRMBENEFITSERIALNO", "type": "STRING"}, {"name": "C_FTRDMTRANSMODE", "type": "STRING"}, {"name": "C_CAPINFLAG", "type": "STRING"}, {"name": "C_NEEDFROZENSHARE", "type": "STRING"}, {"name": "C_IDENTITYTYPEINBANK", "type": "STRING"}, {"name": "VC_IDENTITYNOINBANK", "type": "STRING"}, {"name": "VC_LIQUIDATEDATE", "type": "STRING"}, {"name": "VC_FUSEORIDATE", "type": "STRING"}, {"name": "EN_COUPON", "type": "DOUBLE"}, {"name": "EN_NAV", "type": "DOUBLE"}, {"name": "VC_SHAREEXPIREDATE", "type": "STRING"}, {"name": "VC_OUTREQUESTNO", "type": "STRING"}, {"name": "EN_GRAMNUM", "type": "DOUBLE"}, {"name": "VC_RESUBDATE", "type": "STRING"}, {"name": "VC_CALMTIME", "type": "STRING"}, {"name": "VC_REGISTERSERIALNO", "type": "STRING"}, {"name": "VC_FULLNAMEINBANK", "type": "STRING"}, {"name": "VC_ORIOPERATORNO", "type": "STRING"}, {"name": "C_CUSTFUNDTIMELIMITMATCHFLAG", "type": "STRING"}, {"name": "C_INVESTVARIETIESMATCHFLAG", "type": "STRING"}, {"name": "C_CUSTINVESTMENTVARIETIES", "type": "STRING"}, {"name": "C_FUNDINVESTMENTVARIETIES", "type": "STRING"}, {"name": "EN_CUSTTIMELIMIT", "type": "DOUBLE"}, {"name": "EN_FUNDTIMELIMIT", "type": "DOUBLE"}, {"name": "VC_COOLSTARTTIME", "type": "STRING"}, {"name": "VC_ERRORINFO", "type": "STRING"}, {"name": "VC_TRADECONFIRMNO", "type": "STRING"}, {"name": "EN_CONFIRMNAV", "type": "DOUBLE"}, {"name": "C_SPLITFLAG", "type": "STRING"}, {"name": "EN_ORIBALANCE", "type": "DOUBLE"}, {"name": "C_RENEWALSTATUS", "type": "STRING"}, {"name": "EN_CONFIRMFARE", "type": "DOUBLE"}, {"name": "C_ORICAPITALMODE", "type": "STRING"}, {"name": "EN_CUTSHARE", "type": "DOUBLE"}, {"name": "EN_CUTBALA", "type": "DOUBLE"}, {"name": "C_EXPORTSTATE", "type": "STRING"}, {"name": "C_RECORD", "type": "STRING"}, {"name": "C_PLEDGEFLAG", "type": "STRING"}, {"name": "C_AUTOCAPIN", "type": "STRING"}, {"name": "C_LIMITFLAG", "type": "STRING"}, {"name": "VC_RECORDSERIALNO", "type": "STRING"}, {"name": "VC_SPECIFYREQUESTDATE", "type": "STRING"}, {"name": "EN_TARGETBALANCE", "type": "DOUBLE"}, {"name": "VC_FIXTHEME", "type": "STRING"}, {"name": "C_AUTOBUYFUNDFLAG", "type": "STRING"}, {"name": "EN_COMBREDEEMSCALE", "type": "DOUBLE"}, {"name": "C_CHARGEWAY", "type": "STRING"}, {"name": "VC_PARTNERDATETIME", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "C_STOPPROFIT", "type": "STRING"}, {"name": "EN_DEDUCTREGSHARE", "type": "DOUBLE"}, {"name": "EN_DEDUCTONWAYSHARE", "type": "DOUBLE"}, {"name": "EN_CURRENTFUND", "type": "DOUBLE"}, {"name": "C_STRATEGYTYPE", "type": "STRING"}, {"name": "VC_ELECFAXNO", "type": "STRING"}, {"name": "VC_RESUBSCRIBEDATE", "type": "STRING"}, {"name": "VC_COUPONIDNO", "type": "STRING"}, {"name": "C_PENATRATEFLAG", "type": "STRING"}, {"name": "VC_SUBFUNDCODE", "type": "STRING"}, {"name": "VC_MERCHANTNO", "type": "STRING"}, {"name": "VC_INTRODEPT", "type": "STRING"}, {"name": "VC_INTRODUCER", "type": "STRING"}, {"name": "VC_BRANCHOFFICE", "type": "STRING"}, {"name": "VC_BUSINDEPT", "type": "STRING"}, {"name": "VC_BUSINDEPTINTRO", "type": "STRING"}, {"name": "VC_CARRYDAY", "type": "STRING"}, {"name": "EN_TRANSINFEE", "type": "DOUBLE"}, {"name": "EN_TRANSOUTFEE", "type": "DOUBLE"}, {"name": "VC_PLATFORMNO", "type": "STRING"}, {"name": "VC_BATCHOTHERSERIALNO", "type": "STRING"}, {"name": "VC_HEDGETRADEACCO", "type": "STRING"}, {"name": "EN_REALOTHERDISCOUNT", "type": "DOUBLE"}, {"name": "C_CHANGEHOLDINGSTATE", "type": "STRING"}, {"name": "C_CHANGEHOLDINGSTATEBAK", "type": "STRING"}, {"name": "VC_VIDEOID", "type": "STRING"}, {"name": "L_T0EXPORTBATCHNO", "type": "DOUBLE"}, {"name": "C_ACTIVATIONFLAG", "type": "STRING"}, {"name": "C_REVIEWSLEEPFLAG", "type": "STRING"}, {"name": "VC_RECORDDATETIME", "type": "STRING"}, {"name": "C_RECORDTYPE", "type": "STRING"}, {"name": "C_NEEDRECORD", "type": "STRING"}, {"name": "C_POSTPONE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_trequest_ptd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_trequest_ptd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_trequest_ptd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_trequest_ptd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TREQUEST_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TREQUEST_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_trequest_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TREQUEST_PTD PARTITION(P_DT)
SELECT
       C_CUSTTYPE
     , VC_FUNDACCO
     , VC_TRADEACCO
     , VC_REQUESTNO
     , VC_VOUCHERNO
     , VC_NETNO
     , VC_CENTERNO
     , VC_REQUESTDATE
     , VC_REQUESTTIME
     , C_BUSINFLAG
     , C_TRADEFLAG
     , C_REALLOTFLAG
     , C_PROMISEFLAG
     , VC_FUNDCODE
     , C_SHARETYPE
     , C_TRUST
     , EN_BALANCE
     , EN_SHARE
     , EN_DISCOUNT
     , C_SENDSTATE
     , C_STATE
     , C_CONFIRMFLAG
     , C_FROZENFLAG
     , C_MONEYTYPE
     , EN_CONFIRMSHARE
     , EN_CONFIRMBALA
     , VC_OPERATORNO
     , VC_CHECKNO
     , VC_BROKER
     , C_EXCEEDFLAG
     , VC_HOPEDATE
     , C_ORIGINFLAG
     , VC_ORIGINNO
     , VC_ORIGINDATE
     , VC_ORIGINCONFIRMNO
     , VC_ORIGINCONFIRMDATE
     , C_BANKNO
     , VC_BANKNAME
     , VC_NAMEINBANK
     , VC_BANKACCO
     , C_CHANGETYPE
     , VC_OTHERACCO
     , VC_OTHERTRADEACCO
     , VC_OTHERFUNDCODE
     , C_OTHERSHARETYPE
     , C_OTHERAGENCYNO
     , VC_OTHERNETNO
     , C_DIVIDENDMETHOD
     , C_FROZENCAUSE
     , VC_EXPLAIN
     , C_CAPITALMODE
     , VC_PROTOCOL
     , L_DELAYDAY
     , L_PERMITNUM
     , VC_ENDDATE
     , VC_BEGINDATE
     , VC_BOOKNO
     , VC_CYCLE
     , VC_PROMISEDATE
     , VC_REGDATE
     , VC_CITYNO
     , VC_SELLER
     , VC_TACODE
     , VC_DISCOUNTDATE
     , VC_FIXDAY
     , VC_COMBCODE
     , VC_COMBREQUESTNO
     , EN_INVESTSCALE
     , C_AUDITFLAG
     , VC_AUDITNO
     , EN_INVESTSHARE
     , EN_ENDDISCOUNT
     , EN_OTHERDISCOUNT
     , C_CHECKFLAG
     , C_PROMOTION
     , VC_ACCEPTDATE
     , C_CUSTCONFIRM
     , VC_EXPONENTCODE
     , C_EXPONENTFLAG
     , EN_EXPONENTVALUE
     , EN_FACTBALA
     , C_PARTFLAG
     , EN_DUEFARE
     , VC_BRANCHCODE
     , C_FIXBUSINFLAG
     , VC_SYSDATE
     , VC_PROCEDURENAME
     , C_ACCOFLAG
     , C_CPFLAG
     , C_DELETE
     , C_INVESTFLAG
     , EN_PROMISEBALA
     , EN_TRANSFERFEE
     , VC_BANKID
     , VC_CPERRORCODE
     , VC_DEALPWD
     , VC_INVESTCONTENT
     , VC_OTHERSERIALNO
     , VC_TRANSFERDATE
     , VC_SERVICENAME
     , C_FUNCTIONNO
     , VC_MACHINEDATE
     , C_RETURNFLAG
     , C_DISCOUNTFLAG
     , C_SUBCAPITALMODE
     , VC_CONFIRMDATE
     , VC_BANKNETDATE
     , C_EXPORT
     , VC_TRADECONTACT
     , VC_SECURITIESACCOUNT
     , C_RISKFLAG
     , VC_BATCHNO
     , VC_PROTOCOLNAME
     , C_CYCLEUNIT
     , C_EXPTYPE
     , L_MAXSUCCESSNUM
     , EN_MAXVALUE
     , EN_MINSCALE1
     , EN_MAXSCALE1
     , EN_SCALBALANCE1
     , EN_MINSCALE2
     , EN_MAXSCALE2
     , EN_SCALBALANCE2
     , EN_MINSCALE3
     , EN_MAXSCALE3
     , EN_SCALBALANCE3
     , C_ALLOWDEDUCT
     , C_AVGEXPONENTTYPE
     , EN_DIFFSCALE
     , C_AMLFULLFLAG
     , C_CUSTRISKTYPE
     , C_FUNDRISKLEVEL
     , VC_TRADEPURPOSE
     , C_BUSINTYPE
     , EN_UPPERLIMIT
     , EN_LOWERLIMIT
     , VC_LINKDEDUCTNO
     , VC_RECOVERDATE
     , VC_LASTDEDUCTTIME
     , L_COMMERRORNO
     , VC_COMMERRORMSG
     , VC_CPERRORMSG
     , C_SCANFLAG
     , L_SECTIONSCHEMANO
     , VC_SECTIONSCHEMATYPE
     , VC_FIXMONTH
     , EN_INVENSTRATE
     , VC_RECOMMENDER
     , VC_RECOMMENDERPHONE
     , VC_RECOMMENDERPROVINCE
     , VC_RECOMMENDERCITYNO
     , VC_COMEFROM
     , VC_SOURCEIPADDR
     , C_AUTOREQUEST
     , VC_DEDUCTFUNDCODE
     , VC_SUBACCONO
     , VC_SUBACCOAUDITNO
     , L_SPECIALLIQDAY
     , VC_INVESTORSYSTEMID
     , EN_MAXVALUEONCE
     , EN_MINRETAINEDBALA
     , EN_LOWERDEDUCTBALA
     , VC_CUSTNO
     , C_FIXCOMBTYPE
     , VC_BATCHSELECTNO
     , VC_HEDGEFUNDCODE
     , C_HEDGESHARETYPE
     , C_SHORTAVGEXPONENTTYPE
     , C_MEDIUMAVGEXPONENTTYPE
     , C_LONGAVGEXPONENTTYPE
     , VC_HEDGEPROTOCOL
     , C_BREAKFLAG
     , VC_BATCHREQUESTNO
     , VC_SELFCOMBCODE
     , VC_MATCHNO
     , VC_MATCHAUDITNO
     , VC_CONTRACTNO
     , C_REDEEMUSEFLAG
     , C_RECREATEBATCHNO
     , VC_CONFIRMSETTLEDATE
     , VC_REQUESTSETTLEDATE
     , VC_CONTRACTSERIALNO
     , C_PROFITCLASS
     , VC_REJECTREASON
     , VC_EXTCOMBCODE
     , C_NONWORKDAYDELAY
     , VC_PAYMENTACCONO
     , VC_PAYMENTDATE
     , VC_PAYMENTTYPE
     , C_INTERFACETYPE
     , VC_CDCARD
     , VC_CHINAPAYSERIALNO
     , C_PAYMENTBALATYPE
     , EN_INCOME
     , C_DEALFLAG
     , C_LOANFLAG
     , C_SYNSTATE
     , C_NEEDDEDUCT
     , C_NEEDTRANSFER
     , C_CHANGEDIRECT
     , C_HKCAPITALMODE
     , VC_LONGCDCARD
     , VC_BILLSERIALNO
     , VC_USECONTENT
     , C_FTREDEEMMODE
     , VC_BANKNETTIME
     , VC_BOOKID
     , VC_UNFROZENDATE
     , VC_INVESTDATE
     , VC_NEEDDATE
     , C_BANKPROVINCECODE
     , VC_BANKCITYNO
     , C_ACCOID
     , VC_CONFIRMBENEFITSERIALNO
     , C_FTRDMTRANSMODE
     , C_CAPINFLAG
     , C_NEEDFROZENSHARE
     , C_IDENTITYTYPEINBANK
     , VC_IDENTITYNOINBANK
     , VC_LIQUIDATEDATE
     , VC_FUSEORIDATE
     , EN_COUPON
     , EN_NAV
     , VC_SHAREEXPIREDATE
     , VC_OUTREQUESTNO
     , EN_GRAMNUM
     , VC_RESUBDATE
     , VC_CALMTIME
     , VC_REGISTERSERIALNO
     , VC_FULLNAMEINBANK
     , VC_ORIOPERATORNO
     , C_CUSTFUNDTIMELIMITMATCHFLAG
     , C_INVESTVARIETIESMATCHFLAG
     , C_CUSTINVESTMENTVARIETIES
     , C_FUNDINVESTMENTVARIETIES
     , EN_CUSTTIMELIMIT
     , EN_FUNDTIMELIMIT
     , VC_COOLSTARTTIME
     , VC_ERRORINFO
     , VC_TRADECONFIRMNO
     , EN_CONFIRMNAV
     , C_SPLITFLAG
     , EN_ORIBALANCE
     , C_RENEWALSTATUS
     , EN_CONFIRMFARE
     , C_ORICAPITALMODE
     , EN_CUTSHARE
     , EN_CUTBALA
     , C_EXPORTSTATE
     , C_RECORD
     , C_PLEDGEFLAG
     , C_AUTOCAPIN
     , C_LIMITFLAG
     , VC_RECORDSERIALNO
     , VC_SPECIFYREQUESTDATE
     , EN_TARGETBALANCE
     , VC_FIXTHEME
     , C_AUTOBUYFUNDFLAG
     , EN_COMBREDEEMSCALE
     , C_CHARGEWAY
     , VC_PARTNERDATETIME
     , VC_TIMESTAMP
     , C_STOPPROFIT
     , EN_DEDUCTREGSHARE
     , EN_DEDUCTONWAYSHARE
     , EN_CURRENTFUND
     , C_STRATEGYTYPE
     , VC_ELECFAXNO
     , VC_RESUBSCRIBEDATE
     , VC_COUPONIDNO
     , C_PENATRATEFLAG
     , VC_SUBFUNDCODE
     , VC_MERCHANTNO
     , VC_INTRODEPT
     , VC_INTRODUCER
     , VC_BRANCHOFFICE
     , VC_BUSINDEPT
     , VC_BUSINDEPTINTRO
     , VC_CARRYDAY
     , EN_TRANSINFEE
     , EN_TRANSOUTFEE
     , VC_PLATFORMNO
     , VC_BATCHOTHERSERIALNO
     , VC_HEDGETRADEACCO
     , EN_REALOTHERDISCOUNT
     , C_CHANGEHOLDINGSTATE
     , C_CHANGEHOLDINGSTATEBAK
     , VC_VIDEOID
     , L_T0EXPORTBATCHNO
     , C_ACTIVATIONFLAG
     , C_REVIEWSLEEPFLAG
     , VC_RECORDDATETIME
     , C_RECORDTYPE
     , C_NEEDRECORD
     , C_POSTPONE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , VC_REQUESTDATE P_DT
  FROM ODS_XDAY_HSDS.ODS_HSDS_TREQUEST_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TREQUEST_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TREQUEST_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TREQUEST_PTD成功"
      exit 0
   fi
fi
