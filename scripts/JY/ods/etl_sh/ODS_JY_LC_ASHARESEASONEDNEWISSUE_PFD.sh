#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  ADVANCEDATE  STRING  COMMENT  '预案发布日期',
  SMDECIPUBLDATE  STRING  COMMENT  '股东大会决议公告日期',
  ADVANCEVALIDSTARTDATE  STRING  COMMENT  '预案有效期起始日',
  ADVANCEVALIDENDDATE  STRING  COMMENT  '预案有效期截止日',
  INTENTLETTERPUBLDATE  STRING  COMMENT  '招股公告日(招股意向书发布日期)',
  PROSPECTUSPUBLDATE  STRING  COMMENT  '招股说明书发布日期',
  STOCKTYPE  STRING  COMMENT  '发行股票类型',
  PRICEINTERVALSTATEMENT  STRING  COMMENT  '发行价区间确定方式说明',
  PRICINGMODEL  DECIMAL(10,0)  COMMENT  '定价方式',
  RATIONMODEL  DECIMAL(10,0)  COMMENT  '发行量定量方式',
  ISSUEMETHOD  DECIMAL(10,0)  COMMENT  '发行方式',
  ISSUEOBJECT  STRING  COMMENT  '发行对象',
  ISSUEPRICECEILING  DECIMAL(19,4)  COMMENT  '发行价上限(最高价)(元)',
  ISSUEPRICEFLOOR  DECIMAL(19,4)  COMMENT  '发行价下限(元)',
  REFERRINGPRICE  DECIMAL(19,4)  COMMENT  '承销商指导价格(元)',
  ISSUEVOLCEILING  DECIMAL(16,0)  COMMENT  '发行量上限(不多于)(股)',
  ISSUEVOLFLOOR  DECIMAL(16,0)  COMMENT  '发行量下限(股)',
  OVERALLOTMENTOPTION  DECIMAL(16,0)  COMMENT  '超额配售权(股)',
  ISSUESTARTDATE  STRING  COMMENT  '发行日期上限',
  ISSUEENDDATE  STRING  COMMENT  '发行日期下限',
  UNDERWRITINGSTARTDATE  STRING  COMMENT  '*承销期上限',
  UNDERWRITINGENDDATE  STRING  COMMENT  '*承销期下限',
  IFEXRIGHTASHARE  DECIMAL(10,0)  COMMENT  'A股除权与否',
  RIGHTREGDATE  STRING  COMMENT  '股权登记日',
  EXRIGHTDATE  STRING  COMMENT  '除权日',
  SUSPENDSTARTDATE  STRING  COMMENT  '停牌时间起始日',
  SUSPENDENDDATE  STRING  COMMENT  '停牌时间截止日',
  PREFPLADATEH  STRING  COMMENT  '老股东优先配售日期',
  PREFPLARATIOH  DECIMAL(9,4)  COMMENT  '老股东优先配售比例(10配X)',
  PREFPLAAPPLYCODEH  STRING  COMMENT  '老股东优先配售申购代码',
  PREFPLAAPPLYABBRNAMEH  STRING  COMMENT  '老股东优先配售申购简称',
  ISSUEDATEONLINE  STRING  COMMENT  '上网公开发行日期',
  APPLYCODEONLINE  STRING  COMMENT  '上网发行申购代码',
  APPLYABBRNAMEONLINE  STRING  COMMENT  '上网发行申购简称',
  APPLYUNITONLINE  DECIMAL(10,0)  COMMENT  '上网发行认购单位(股)',
  APPLYMAXONLINE  DECIMAL(16,0)  COMMENT  '上网发行申购上限(股)',
  APPLYSTARTDATELPOFFLINE  STRING  COMMENT  '法人网下配售申购日期起始日',
  APPLYENDDATELPOFFLINE  STRING  COMMENT  '法人网下配售申购日期截止日',
  PAYSTARTDATELPOFFLINE  STRING  COMMENT  '法人网下申购缴款开始日',
  PLAPAYENDDATELPOFFLINE  STRING  COMMENT  '法人网下申购缴款截止日',
  APPLYUNITLPOFFLINE  DECIMAL(10,0)  COMMENT  '法人网下配售认购单位(股)',
  APPLYMINLPOFFLINE  DECIMAL(10,0)  COMMENT  '法人网下配售申购下限(股)',
  APPLYMAXLPOFFLINE  DECIMAL(16,0)  COMMENT  '法人网下配售申购上限(股)',
  VALIDAPPLYTIMESLPOFFLINE  DECIMAL(10,0)  COMMENT  '法人网下配售有效申购次数限定',
  APPLYSTARTDATEF  STRING  COMMENT  '*基金优先配售申购日期上限',
  APPLYENDDATEF  STRING  COMMENT  '*基金优先配售申购日期下限',
  PAYSTARTDATEF  STRING  COMMENT  '*基金优先配售缴款期下限',
  PAYENDDATEF  STRING  COMMENT  '*基金优先配售缴款期上限',
  PREFALLOTMENTF  DECIMAL(16,0)  COMMENT  '投资基金配售限额(股)',
  PREFALLOTMENTSINGLEF  DECIMAL(16,0)  COMMENT  '单个基金配售限额(股)',
  STAQNETPLASTARTDATE  STRING  COMMENT  'STAQ/NET定向配售时间起始日',
  STAQNETPLAENDDATE  STRING  COMMENT  'STAQ/NET定向配售时间截止日',
  STAQNETPLARATIO  DECIMAL(9,4)  COMMENT  'STAQ/NET定向配售比例(10配X)',
  QUOTATIONUNITONLINE  DECIMAL(19,4)  COMMENT  '网上申购报价单位(元)',
  QUOTATIONUNITOFFLINE  DECIMAL(19,4)  COMMENT  '网下申购报价单位(元)',
  ODDLOTSTREATMENT  STRING  COMMENT  '零股处理方法',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  ISSUEPRICE  DECIMAL(19,4)  COMMENT  '实际发行价(元)',
  STATESHARESISSUEPRICE  DECIMAL(19,4)  COMMENT  '*国有股存量发行每股发行价(元)',
  WEIGHTEDPERATIO  DECIMAL(30,8)  COMMENT  '发行市盈率(加权平均)(倍)',
  DILUTEDPERATIO  DECIMAL(30,8)  COMMENT  '发行市盈率(全面摊薄)(倍)',
  ISSUEVOL  DECIMAL(16,0)  COMMENT  '发行量(股)',
  STATESHARESISSUED  DECIMAL(16,0)  COMMENT  '*国有股存量发行股数(股)',
  TOTALISSUEMV  DECIMAL(19,4)  COMMENT  '发行总市值(元)',
  ISSUECOST  DECIMAL(19,4)  COMMENT  '发行费用总额(元)',
  UNDERWRITINGFEE  DECIMAL(19,4)  COMMENT  '承销费用(元)',
  CPAFEE  DECIMAL(19,4)  COMMENT  '注册会计师费用(元)',
  ASSETAPPRAISALFEE  DECIMAL(19,4)  COMMENT  '资产评估费用(元)',
  LANDEVALUATIONFEE  DECIMAL(19,4)  COMMENT  '土地评估费用(元)',
  ATTORNEYFEE  DECIMAL(19,4)  COMMENT  '律师费用(元)',
  TOTALAGENTFEE  DECIMAL(19,4)  COMMENT  '中介机构费合计(元)',
  ONLINEISSUEFEE  DECIMAL(19,4)  COMMENT  '上网发行费用(元)',
  SCRIPFEE  DECIMAL(19,4)  COMMENT  '股票登记费用(元)',
  SPONSORFEE  DECIMAL(19,4)  COMMENT  '上市推荐费用(元)',
  OTHERFEE  DECIMAL(19,4)  COMMENT  '其他费用(元)',
  ISSUECOSTPERSHARE  DECIMAL(19,4)  COMMENT  '每股发行费用(元/股)',
  FREEZEDMONEY  DECIMAL(19,4)  COMMENT  '冻结资金(元)',
  SNIPROCEEDS  DECIMAL(19,4)  COMMENT  '增发新股募集资金总额(元)',
  SNINETPROCEEDS  DECIMAL(19,4)  COMMENT  '增发新股募集资金净额(元)',
  STATESHARESPROCEEDS  DECIMAL(19,4)  COMMENT  '*国有股存量发行收入总额(元)',
  STATESHARESNETPROCEEDS  DECIMAL(19,4)  COMMENT  '*国有股存量发行收入净额(元)',
  MONEYTOACCOUNT  DECIMAL(19,4)  COMMENT  '募集资金到帐金额(元)',
  DATETOACCOUNT  STRING  COMMENT  '募集资金到帐时间',
  NEWSHARELISTDATE  STRING  COMMENT  '增发股份上市日期',
  OUTSTANDINGSHARES  DECIMAL(16,0)  COMMENT  '本次上市流通股数(股)',
  PUTBACKVOL  DECIMAL(16,0)  COMMENT  '网上网下回拨股数(股)',
  PREFPLAVOLH  DECIMAL(16,0)  COMMENT  '原股东优先配售股数(股)',
  PUBLICOFFERVOLONLINE  DECIMAL(16,0)  COMMENT  '上网公开发行股数(股)',
  VALIDAPPLYVOLONLINE  DECIMAL(16,0)  COMMENT  '网上发行有效申购总量(股)',
  VALIDAPPLYNUMONLINE  DECIMAL(10,0)  COMMENT  '网上发行有效申购户数(户)',
  OVERSUBSTIMESONLINE  DECIMAL(9,4)  COMMENT  '网上发行超额认购倍数(倍)',
  LOTRATEONLINE  DECIMAL(18,15)  COMMENT  '网上发行中签率',
  PLAVOLLPOFFLINE  DECIMAL(16,0)  COMMENT  '法人网下配售股数(股)',
  VALIDAPPLYVOLLPOFFLINE  DECIMAL(16,0)  COMMENT  '法人网下配售有效申购总量(股)',
  VALIDAPPLYNUMLPOFFLINE  DECIMAL(10,0)  COMMENT  '法人网下配售有效申购户数(户)',
  OVERSUBSTIMESLPOFFLINE  DECIMAL(9,4)  COMMENT  '法人网下配售超额认购倍数(倍)',
  LOTRATELPOFFLINE  DECIMAL(18,15)  COMMENT  '法人网下配售中签率',
  PLAVOLF  DECIMAL(16,0)  COMMENT  '投资基金配售股数(股)',
  PLAVOLSTAQNET  DECIMAL(16,0)  COMMENT  'STAQ/NET定向配售股数(股)',
  TAILOREDPLAVOLLP  DECIMAL(16,0)  COMMENT  '法人定向配售股数/战略定向配售(股)',
  EARNINGFORECASTYEAR  STRING  COMMENT  '盈利预测年度',
  MAININCOMEFORECAST  DECIMAL(19,4)  COMMENT  '主营业务收入预测(元)',
  NETPROFITFORECAST  DECIMAL(19,4)  COMMENT  '净利润预测(元)',
  DILUTEDEPSFORECAST  DECIMAL(19,4)  COMMENT  '全面摊薄每股盈利预测(元)',
  UNDERWRITINGMODE  DECIMAL(10,0)  COMMENT  '承销方式',
  UNDERWRITERBOUGHTVOL  DECIMAL(16,0)  COMMENT  '余股包销数量(股)',
  CHANGESTATEMENT  STRING  COMMENT  '方案变动说明',
  CHANGETYPE  DECIMAL(10,0)  COMMENT  '变动原因',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  PERATIOBEFOREISSUE  DECIMAL(30,8)  COMMENT  '发行市盈率(按发行前总股本)(倍)',
  PERATIOAFTERISSUE  DECIMAL(30,8)  COMMENT  '发行市盈率(按发行后总股本预测利润)(倍)',
  PREFPLAVOLHMAX  DECIMAL(16,0)  COMMENT  '原股东可配售股数(最多)(股)',
  PREFPLAVOLHONLINE  DECIMAL(16,0)  COMMENT  '原股东网上认购优先配售(股)',
  PREFPLAVOLHOFFLINE  DECIMAL(16,0)  COMMENT  '原股东网下认购优先配售(股)',
  VALIDAPPLYHNUM  DECIMAL(10,0)  COMMENT  '原股东有效申购户数(户)',
  VALIDAPPLYNUMHONLINE  DECIMAL(10,0)  COMMENT  '原股东网上认购有效申购户数(户)',
  VALIDAPPLYNUMHOFFLINE  DECIMAL(10,0)  COMMENT  '原股东网下认购有效申购户数(户)',
  APLAVOLLPOFFLINE  DECIMAL(16,0)  COMMENT  'A类法人网下配售股数(股)',
  AVALIDAPPLYVOLLPOFFLINE  DECIMAL(16,0)  COMMENT  'A类法人网下配售有效申购总量(股)',
  AVALIDAPPLYNUMLPOFFLINE  DECIMAL(10,0)  COMMENT  'A类法人网下配售有效申购户数(户)',
  ALOTRATELPOFFLINE  DECIMAL(18,15)  COMMENT  'A类法人网下配售中签率',
  BPLAVOLLPOFFLINE  DECIMAL(16,0)  COMMENT  'B类法人网下配售股数(股)',
  BVALIDAPPLYVOLLPOFFLINE  DECIMAL(16,0)  COMMENT  'B类法人网下配售有效申购总量(股)',
  BVALIDAPPLYNUMLPOFFLINE  DECIMAL(16,0)  COMMENT  'B类法人网下配售有效申购户数(户)',
  BLOTRATELPOFFLINE  DECIMAL(18,15)  COMMENT  'B类法人网下配售中签率',
  PLAVOLHOFFLINE  DECIMAL(16,0)  COMMENT  '原股东网下配售股数(股)',
  VALIDPLAVOLHOFFLINE  DECIMAL(16,0)  COMMENT  '原股东网下配售有效申购总量(股)',
  VALIDPLANUMHOFFLINE  DECIMAL(10,0)  COMMENT  '原股东网下配售有效申购户数(户)',
  LOTRATEHOFFLINE  DECIMAL(18,15)  COMMENT  '原股东网下配售中签率',
  SASACAPPROVALPUBLDATE  STRING  COMMENT  '国资委通过公告日',
  CSRCAPPROVALPUBLDATE  STRING  COMMENT  '证监会批准公告日',
  EVENTPROCEDURECODE  DECIMAL(10,0)  COMMENT  '事件进程',
  ISOBTYPECODE  STRING  COMMENT  '发行对象类型',
  ADJUSTEDISSUEPRICE  DECIMAL(19,4)  COMMENT  '最新发行价下限(元)',
  PRICEADJUSTEDDATE  STRING  COMMENT  '最新发行价调整日',
  SCHEMECHANGEPUBLDATE  STRING  COMMENT  '方案变动公告日',
  LISTANNOUNCEDATE  STRING  COMMENT  '增发新股上市公告日期',
  PROJINFOSOURCE  STRING  COMMENT  '预案信息来源',
  ISSUERESULTINFOSOURCE  STRING  COMMENT  '发行结果信息来源',
  ADJUSTEDISSUEVOL  DECIMAL(16,0)  COMMENT  '最新发行量上限(股)',
  PRICEVOLADJUSTEDDATE  STRING  COMMENT  '最新发行价及发行量调整日',
  ISSUEPURPOSE  STRING  COMMENT  '发行目的',
  PRICINGBASEDATE  STRING  COMMENT  '定价基准日',
  PRICINGBASEDATEDESC  STRING  COMMENT  '定价基准日描述',
  ISSUETYPE  DECIMAL(10,0)  COMMENT  '增发类别',
  IFEFFECTED  DECIMAL(10,0)  COMMENT  '是否有效',
  SUBSCRIBEMETHOD  DECIMAL(10,0)  COMMENT  '认购方式1',
  LARGESHSUBMETHOD  DECIMAL(10,0)  COMMENT  '控股股东认购方式',
  LARGESHSUBSSUM  DECIMAL(16,0)  COMMENT  '控股股东认购数量(股)',
  LARGESHSUBSRATIO  DECIMAL(19,8)  COMMENT  '控股股东认购比例(%)',
  PLANNEDPROCEEDS  DECIMAL(19,4)  COMMENT  '预计募集资金总额(元)',
  CURRENCYPROCEEDS  DECIMAL(19,4)  COMMENT  '货币募集资金总额(元)',
  NONCURRENCYPROCEEDS  DECIMAL(19,4)  COMMENT  '非货币募集资金总额(元)',
  ASSETPROCEEDS  DECIMAL(19,4)  COMMENT  '其中:资产募集资金总额(元)',
  DEBTPROCEEDS  DECIMAL(19,4)  COMMENT  '其中:债权募集资金总额(元)',
  UWSPONFEE  DECIMAL(19,4)  COMMENT  '1)承销保荐费用合计(元)',
  CPAAPPRAISALFEE  DECIMAL(19,4)  COMMENT  '2)审计验资及评估费用合计(元)',
  PARVALUECURRENCYUNIT  DECIMAL(10,0)  COMMENT  '每股面值货币单位',
  ADJUSTEDVOLFLOOR  DECIMAL(16,0)  COMMENT  '最新发行量下限(股)',
  ADJUSTEDPRICECEILING  DECIMAL(19,4)  COMMENT  '最新发行价上限(元)',
  DISCOUNTRATEPERSHARE  DECIMAL(19,8)  COMMENT  '每股发行价折扣率(%)',
  SUBSCRIPTIONOFFERDATE  STRING  COMMENT  '认购邀请书发送日',
  ORGPRICEBASEPRATIO  DECIMAL(19,8)  COMMENT  '预案价格相对基准价格比例(%)',
  ACTPRICEBASEPRATIO  DECIMAL(19,8)  COMMENT  '实施价格相对基准价格比例(%)',
  ADDSUBSCRIPTIONSDATE  STRING  COMMENT  '追加认购起始日',
  ADDSUBSCRIPTIONEDATE  STRING  COMMENT  '追加认购截止日',
  VERIFICATIONDATE  STRING  COMMENT  '募集资金验资日',
  LATESTADVANCEDATE  STRING  COMMENT  '最新预案公布日期'
)
COMMENT '增发A股'
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
                                   , INNERCODE
                                   , INITIALINFOPUBLDATE
                                   , ADVANCEDATE
                                   , SMDECIPUBLDATE
                                   , ADVANCEVALIDSTARTDATE
                                   , ADVANCEVALIDENDDATE
                                   , INTENTLETTERPUBLDATE
                                   , PROSPECTUSPUBLDATE
                                   , STOCKTYPE
                                   , PRICEINTERVALSTATEMENT
                                   , PRICINGMODEL
                                   , RATIONMODEL
                                   , ISSUEMETHOD
                                   , ISSUEOBJECT
                                   , ISSUEPRICECEILING
                                   , ISSUEPRICEFLOOR
                                   , REFERRINGPRICE
                                   , ISSUEVOLCEILING
                                   , ISSUEVOLFLOOR
                                   , OVERALLOTMENTOPTION
                                   , ISSUESTARTDATE
                                   , ISSUEENDDATE
                                   , UNDERWRITINGSTARTDATE
                                   , UNDERWRITINGENDDATE
                                   , IFEXRIGHTASHARE
                                   , RIGHTREGDATE
                                   , EXRIGHTDATE
                                   , SUSPENDSTARTDATE
                                   , SUSPENDENDDATE
                                   , PREFPLADATEH
                                   , PREFPLARATIOH
                                   , PREFPLAAPPLYCODEH
                                   , PREFPLAAPPLYABBRNAMEH
                                   , ISSUEDATEONLINE
                                   , APPLYCODEONLINE
                                   , APPLYABBRNAMEONLINE
                                   , APPLYUNITONLINE
                                   , APPLYMAXONLINE
                                   , APPLYSTARTDATELPOFFLINE
                                   , APPLYENDDATELPOFFLINE
                                   , PAYSTARTDATELPOFFLINE
                                   , PLAPAYENDDATELPOFFLINE
                                   , APPLYUNITLPOFFLINE
                                   , APPLYMINLPOFFLINE
                                   , APPLYMAXLPOFFLINE
                                   , VALIDAPPLYTIMESLPOFFLINE
                                   , APPLYSTARTDATEF
                                   , APPLYENDDATEF
                                   , PAYSTARTDATEF
                                   , PAYENDDATEF
                                   , PREFALLOTMENTF
                                   , PREFALLOTMENTSINGLEF
                                   , STAQNETPLASTARTDATE
                                   , STAQNETPLAENDDATE
                                   , STAQNETPLARATIO
                                   , QUOTATIONUNITONLINE
                                   , QUOTATIONUNITOFFLINE
                                   , ODDLOTSTREATMENT
                                   , PARVALUE
                                   , ISSUEPRICE
                                   , STATESHARESISSUEPRICE
                                   , WEIGHTEDPERATIO
                                   , DILUTEDPERATIO
                                   , ISSUEVOL
                                   , STATESHARESISSUED
                                   , TOTALISSUEMV
                                   , ISSUECOST
                                   , UNDERWRITINGFEE
                                   , CPAFEE
                                   , ASSETAPPRAISALFEE
                                   , LANDEVALUATIONFEE
                                   , ATTORNEYFEE
                                   , TOTALAGENTFEE
                                   , ONLINEISSUEFEE
                                   , SCRIPFEE
                                   , SPONSORFEE
                                   , OTHERFEE
                                   , ISSUECOSTPERSHARE
                                   , FREEZEDMONEY
                                   , SNIPROCEEDS
                                   , SNINETPROCEEDS
                                   , STATESHARESPROCEEDS
                                   , STATESHARESNETPROCEEDS
                                   , MONEYTOACCOUNT
                                   , DATETOACCOUNT
                                   , NEWSHARELISTDATE
                                   , OUTSTANDINGSHARES
                                   , PUTBACKVOL
                                   , PREFPLAVOLH
                                   , PUBLICOFFERVOLONLINE
                                   , VALIDAPPLYVOLONLINE
                                   , VALIDAPPLYNUMONLINE
                                   , OVERSUBSTIMESONLINE
                                   , LOTRATEONLINE
                                   , PLAVOLLPOFFLINE
                                   , VALIDAPPLYVOLLPOFFLINE
                                   , VALIDAPPLYNUMLPOFFLINE
                                   , OVERSUBSTIMESLPOFFLINE
                                   , LOTRATELPOFFLINE
                                   , PLAVOLF
                                   , PLAVOLSTAQNET
                                   , TAILOREDPLAVOLLP
                                   , EARNINGFORECASTYEAR
                                   , MAININCOMEFORECAST
                                   , NETPROFITFORECAST
                                   , DILUTEDEPSFORECAST
                                   , UNDERWRITINGMODE
                                   , UNDERWRITERBOUGHTVOL
                                   , CHANGESTATEMENT
                                   , CHANGETYPE
                                   , XGRQ
                                   , JSID
                                   , PERATIOBEFOREISSUE
                                   , PERATIOAFTERISSUE
                                   , PREFPLAVOLHMAX
                                   , PREFPLAVOLHONLINE
                                   , PREFPLAVOLHOFFLINE
                                   , VALIDAPPLYHNUM
                                   , VALIDAPPLYNUMHONLINE
                                   , VALIDAPPLYNUMHOFFLINE
                                   , APLAVOLLPOFFLINE
                                   , AVALIDAPPLYVOLLPOFFLINE
                                   , AVALIDAPPLYNUMLPOFFLINE
                                   , ALOTRATELPOFFLINE
                                   , BPLAVOLLPOFFLINE
                                   , BVALIDAPPLYVOLLPOFFLINE
                                   , BVALIDAPPLYNUMLPOFFLINE
                                   , BLOTRATELPOFFLINE
                                   , PLAVOLHOFFLINE
                                   , VALIDPLAVOLHOFFLINE
                                   , VALIDPLANUMHOFFLINE
                                   , LOTRATEHOFFLINE
                                   , SASACAPPROVALPUBLDATE
                                   , CSRCAPPROVALPUBLDATE
                                   , EVENTPROCEDURECODE
                                   , ISOBTYPECODE
                                   , ADJUSTEDISSUEPRICE
                                   , PRICEADJUSTEDDATE
                                   , SCHEMECHANGEPUBLDATE
                                   , LISTANNOUNCEDATE
                                   , PROJINFOSOURCE
                                   , ISSUERESULTINFOSOURCE
                                   , ADJUSTEDISSUEVOL
                                   , PRICEVOLADJUSTEDDATE
                                   , ISSUEPURPOSE
                                   , PRICINGBASEDATE
                                   , PRICINGBASEDATEDESC
                                   , ISSUETYPE
                                   , IFEFFECTED
                                   , SUBSCRIBEMETHOD
                                   , LARGESHSUBMETHOD
                                   , LARGESHSUBSSUM
                                   , LARGESHSUBSRATIO
                                   , PLANNEDPROCEEDS
                                   , CURRENCYPROCEEDS
                                   , NONCURRENCYPROCEEDS
                                   , ASSETPROCEEDS
                                   , DEBTPROCEEDS
                                   , UWSPONFEE
                                   , CPAAPPRAISALFEE
                                   , PARVALUECURRENCYUNIT
                                   , ADJUSTEDVOLFLOOR
                                   , ADJUSTEDPRICECEILING
                                   , DISCOUNTRATEPERSHARE
                                   , SUBSCRIPTIONOFFERDATE
                                   , ORGPRICEBASEPRATIO
                                   , ACTPRICEBASEPRATIO
                                   , ADDSUBSCRIPTIONSDATE
                                   , ADDSUBSCRIPTIONEDATE
                                   , VERIFICATIONDATE
                                   , LATESTADVANCEDATE
                                FROM ${jy_src_schema}.LC_ASHARESEASONEDNEWISSUE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "ADVANCEDATE", "type": "STRING"}, {"name": "SMDECIPUBLDATE", "type": "STRING"}, {"name": "ADVANCEVALIDSTARTDATE", "type": "STRING"}, {"name": "ADVANCEVALIDENDDATE", "type": "STRING"}, {"name": "INTENTLETTERPUBLDATE", "type": "STRING"}, {"name": "PROSPECTUSPUBLDATE", "type": "STRING"}, {"name": "STOCKTYPE", "type": "DOUBLE"}, {"name": "PRICEINTERVALSTATEMENT", "type": "STRING"}, {"name": "PRICINGMODEL", "type": "DOUBLE"}, {"name": "RATIONMODEL", "type": "DOUBLE"}, {"name": "ISSUEMETHOD", "type": "DOUBLE"}, {"name": "ISSUEOBJECT", "type": "STRING"}, {"name": "ISSUEPRICECEILING", "type": "DOUBLE"}, {"name": "ISSUEPRICEFLOOR", "type": "DOUBLE"}, {"name": "REFERRINGPRICE", "type": "DOUBLE"}, {"name": "ISSUEVOLCEILING", "type": "DOUBLE"}, {"name": "ISSUEVOLFLOOR", "type": "DOUBLE"}, {"name": "OVERALLOTMENTOPTION", "type": "DOUBLE"}, {"name": "ISSUESTARTDATE", "type": "STRING"}, {"name": "ISSUEENDDATE", "type": "STRING"}, {"name": "UNDERWRITINGSTARTDATE", "type": "STRING"}, {"name": "UNDERWRITINGENDDATE", "type": "STRING"}, {"name": "IFEXRIGHTASHARE", "type": "DOUBLE"}, {"name": "RIGHTREGDATE", "type": "STRING"}, {"name": "EXRIGHTDATE", "type": "STRING"}, {"name": "SUSPENDSTARTDATE", "type": "STRING"}, {"name": "SUSPENDENDDATE", "type": "STRING"}, {"name": "PREFPLADATEH", "type": "STRING"}, {"name": "PREFPLARATIOH", "type": "DOUBLE"}, {"name": "PREFPLAAPPLYCODEH", "type": "STRING"}, {"name": "PREFPLAAPPLYABBRNAMEH", "type": "STRING"}, {"name": "ISSUEDATEONLINE", "type": "STRING"}, {"name": "APPLYCODEONLINE", "type": "STRING"}, {"name": "APPLYABBRNAMEONLINE", "type": "STRING"}, {"name": "APPLYUNITONLINE", "type": "DOUBLE"}, {"name": "APPLYMAXONLINE", "type": "DOUBLE"}, {"name": "APPLYSTARTDATELPOFFLINE", "type": "STRING"}, {"name": "APPLYENDDATELPOFFLINE", "type": "STRING"}, {"name": "PAYSTARTDATELPOFFLINE", "type": "STRING"}, {"name": "PLAPAYENDDATELPOFFLINE", "type": "STRING"}, {"name": "APPLYUNITLPOFFLINE", "type": "DOUBLE"}, {"name": "APPLYMINLPOFFLINE", "type": "DOUBLE"}, {"name": "APPLYMAXLPOFFLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYTIMESLPOFFLINE", "type": "DOUBLE"}, {"name": "APPLYSTARTDATEF", "type": "STRING"}, {"name": "APPLYENDDATEF", "type": "STRING"}, {"name": "PAYSTARTDATEF", "type": "STRING"}, {"name": "PAYENDDATEF", "type": "STRING"}, {"name": "PREFALLOTMENTF", "type": "DOUBLE"}, {"name": "PREFALLOTMENTSINGLEF", "type": "DOUBLE"}, {"name": "STAQNETPLASTARTDATE", "type": "STRING"}, {"name": "STAQNETPLAENDDATE", "type": "STRING"}, {"name": "STAQNETPLARATIO", "type": "DOUBLE"}, {"name": "QUOTATIONUNITONLINE", "type": "DOUBLE"}, {"name": "QUOTATIONUNITOFFLINE", "type": "DOUBLE"}, {"name": "ODDLOTSTREATMENT", "type": "STRING"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "ISSUEPRICE", "type": "DOUBLE"}, {"name": "STATESHARESISSUEPRICE", "type": "DOUBLE"}, {"name": "WEIGHTEDPERATIO", "type": "DOUBLE"}, {"name": "DILUTEDPERATIO", "type": "DOUBLE"}, {"name": "ISSUEVOL", "type": "DOUBLE"}, {"name": "STATESHARESISSUED", "type": "DOUBLE"}, {"name": "TOTALISSUEMV", "type": "DOUBLE"}, {"name": "ISSUECOST", "type": "DOUBLE"}, {"name": "UNDERWRITINGFEE", "type": "DOUBLE"}, {"name": "CPAFEE", "type": "DOUBLE"}, {"name": "ASSETAPPRAISALFEE", "type": "DOUBLE"}, {"name": "LANDEVALUATIONFEE", "type": "DOUBLE"}, {"name": "ATTORNEYFEE", "type": "DOUBLE"}, {"name": "TOTALAGENTFEE", "type": "DOUBLE"}, {"name": "ONLINEISSUEFEE", "type": "DOUBLE"}, {"name": "SCRIPFEE", "type": "DOUBLE"}, {"name": "SPONSORFEE", "type": "DOUBLE"}, {"name": "OTHERFEE", "type": "DOUBLE"}, {"name": "ISSUECOSTPERSHARE", "type": "DOUBLE"}, {"name": "FREEZEDMONEY", "type": "DOUBLE"}, {"name": "SNIPROCEEDS", "type": "DOUBLE"}, {"name": "SNINETPROCEEDS", "type": "DOUBLE"}, {"name": "STATESHARESPROCEEDS", "type": "DOUBLE"}, {"name": "STATESHARESNETPROCEEDS", "type": "DOUBLE"}, {"name": "MONEYTOACCOUNT", "type": "DOUBLE"}, {"name": "DATETOACCOUNT", "type": "STRING"}, {"name": "NEWSHARELISTDATE", "type": "STRING"}, {"name": "OUTSTANDINGSHARES", "type": "DOUBLE"}, {"name": "PUTBACKVOL", "type": "DOUBLE"}, {"name": "PREFPLAVOLH", "type": "DOUBLE"}, {"name": "PUBLICOFFERVOLONLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYVOLONLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYNUMONLINE", "type": "DOUBLE"}, {"name": "OVERSUBSTIMESONLINE", "type": "DOUBLE"}, {"name": "LOTRATEONLINE", "type": "DOUBLE"}, {"name": "PLAVOLLPOFFLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYVOLLPOFFLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYNUMLPOFFLINE", "type": "DOUBLE"}, {"name": "OVERSUBSTIMESLPOFFLINE", "type": "DOUBLE"}, {"name": "LOTRATELPOFFLINE", "type": "DOUBLE"}, {"name": "PLAVOLF", "type": "DOUBLE"}, {"name": "PLAVOLSTAQNET", "type": "DOUBLE"}, {"name": "TAILOREDPLAVOLLP", "type": "DOUBLE"}, {"name": "EARNINGFORECASTYEAR", "type": "STRING"}, {"name": "MAININCOMEFORECAST", "type": "DOUBLE"}, {"name": "NETPROFITFORECAST", "type": "DOUBLE"}, {"name": "DILUTEDEPSFORECAST", "type": "DOUBLE"}, {"name": "UNDERWRITINGMODE", "type": "DOUBLE"}, {"name": "UNDERWRITERBOUGHTVOL", "type": "DOUBLE"}, {"name": "CHANGESTATEMENT", "type": "STRING"}, {"name": "CHANGETYPE", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "PERATIOBEFOREISSUE", "type": "DOUBLE"}, {"name": "PERATIOAFTERISSUE", "type": "DOUBLE"}, {"name": "PREFPLAVOLHMAX", "type": "DOUBLE"}, {"name": "PREFPLAVOLHONLINE", "type": "DOUBLE"}, {"name": "PREFPLAVOLHOFFLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYHNUM", "type": "DOUBLE"}, {"name": "VALIDAPPLYNUMHONLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYNUMHOFFLINE", "type": "DOUBLE"}, {"name": "APLAVOLLPOFFLINE", "type": "DOUBLE"}, {"name": "AVALIDAPPLYVOLLPOFFLINE", "type": "DOUBLE"}, {"name": "AVALIDAPPLYNUMLPOFFLINE", "type": "DOUBLE"}, {"name": "ALOTRATELPOFFLINE", "type": "DOUBLE"}, {"name": "BPLAVOLLPOFFLINE", "type": "DOUBLE"}, {"name": "BVALIDAPPLYVOLLPOFFLINE", "type": "DOUBLE"}, {"name": "BVALIDAPPLYNUMLPOFFLINE", "type": "DOUBLE"}, {"name": "BLOTRATELPOFFLINE", "type": "DOUBLE"}, {"name": "PLAVOLHOFFLINE", "type": "DOUBLE"}, {"name": "VALIDPLAVOLHOFFLINE", "type": "DOUBLE"}, {"name": "VALIDPLANUMHOFFLINE", "type": "DOUBLE"}, {"name": "LOTRATEHOFFLINE", "type": "DOUBLE"}, {"name": "SASACAPPROVALPUBLDATE", "type": "STRING"}, {"name": "CSRCAPPROVALPUBLDATE", "type": "STRING"}, {"name": "EVENTPROCEDURECODE", "type": "DOUBLE"}, {"name": "ISOBTYPECODE", "type": "DOUBLE"}, {"name": "ADJUSTEDISSUEPRICE", "type": "DOUBLE"}, {"name": "PRICEADJUSTEDDATE", "type": "STRING"}, {"name": "SCHEMECHANGEPUBLDATE", "type": "STRING"}, {"name": "LISTANNOUNCEDATE", "type": "STRING"}, {"name": "PROJINFOSOURCE", "type": "STRING"}, {"name": "ISSUERESULTINFOSOURCE", "type": "STRING"}, {"name": "ADJUSTEDISSUEVOL", "type": "DOUBLE"}, {"name": "PRICEVOLADJUSTEDDATE", "type": "STRING"}, {"name": "ISSUEPURPOSE", "type": "STRING"}, {"name": "PRICINGBASEDATE", "type": "STRING"}, {"name": "PRICINGBASEDATEDESC", "type": "STRING"}, {"name": "ISSUETYPE", "type": "DOUBLE"}, {"name": "IFEFFECTED", "type": "DOUBLE"}, {"name": "SUBSCRIBEMETHOD", "type": "DOUBLE"}, {"name": "LARGESHSUBMETHOD", "type": "DOUBLE"}, {"name": "LARGESHSUBSSUM", "type": "DOUBLE"}, {"name": "LARGESHSUBSRATIO", "type": "DOUBLE"}, {"name": "PLANNEDPROCEEDS", "type": "DOUBLE"}, {"name": "CURRENCYPROCEEDS", "type": "DOUBLE"}, {"name": "NONCURRENCYPROCEEDS", "type": "DOUBLE"}, {"name": "ASSETPROCEEDS", "type": "DOUBLE"}, {"name": "DEBTPROCEEDS", "type": "DOUBLE"}, {"name": "UWSPONFEE", "type": "DOUBLE"}, {"name": "CPAAPPRAISALFEE", "type": "DOUBLE"}, {"name": "PARVALUECURRENCYUNIT", "type": "DOUBLE"}, {"name": "ADJUSTEDVOLFLOOR", "type": "DOUBLE"}, {"name": "ADJUSTEDPRICECEILING", "type": "DOUBLE"}, {"name": "DISCOUNTRATEPERSHARE", "type": "DOUBLE"}, {"name": "SUBSCRIPTIONOFFERDATE", "type": "STRING"}, {"name": "ORGPRICEBASEPRATIO", "type": "DOUBLE"}, {"name": "ACTPRICEBASEPRATIO", "type": "DOUBLE"}, {"name": "ADDSUBSCRIPTIONSDATE", "type": "STRING"}, {"name": "ADDSUBSCRIPTIONEDATE", "type": "STRING"}, {"name": "VERIFICATIONDATE", "type": "STRING"}, {"name": "LATESTADVANCEDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_ashareseasonednewissue_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_ashareseasonednewissue_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_ashareseasonednewissue_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_ashareseasonednewissue_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_ashareseasonednewissue_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INITIALINFOPUBLDATE
     , ADVANCEDATE
     , SMDECIPUBLDATE
     , ADVANCEVALIDSTARTDATE
     , ADVANCEVALIDENDDATE
     , INTENTLETTERPUBLDATE
     , PROSPECTUSPUBLDATE
     , STOCKTYPE
     , PRICEINTERVALSTATEMENT
     , PRICINGMODEL
     , RATIONMODEL
     , ISSUEMETHOD
     , ISSUEOBJECT
     , ISSUEPRICECEILING
     , ISSUEPRICEFLOOR
     , REFERRINGPRICE
     , ISSUEVOLCEILING
     , ISSUEVOLFLOOR
     , OVERALLOTMENTOPTION
     , ISSUESTARTDATE
     , ISSUEENDDATE
     , UNDERWRITINGSTARTDATE
     , UNDERWRITINGENDDATE
     , IFEXRIGHTASHARE
     , RIGHTREGDATE
     , EXRIGHTDATE
     , SUSPENDSTARTDATE
     , SUSPENDENDDATE
     , PREFPLADATEH
     , PREFPLARATIOH
     , PREFPLAAPPLYCODEH
     , PREFPLAAPPLYABBRNAMEH
     , ISSUEDATEONLINE
     , APPLYCODEONLINE
     , APPLYABBRNAMEONLINE
     , APPLYUNITONLINE
     , APPLYMAXONLINE
     , APPLYSTARTDATELPOFFLINE
     , APPLYENDDATELPOFFLINE
     , PAYSTARTDATELPOFFLINE
     , PLAPAYENDDATELPOFFLINE
     , APPLYUNITLPOFFLINE
     , APPLYMINLPOFFLINE
     , APPLYMAXLPOFFLINE
     , VALIDAPPLYTIMESLPOFFLINE
     , APPLYSTARTDATEF
     , APPLYENDDATEF
     , PAYSTARTDATEF
     , PAYENDDATEF
     , PREFALLOTMENTF
     , PREFALLOTMENTSINGLEF
     , STAQNETPLASTARTDATE
     , STAQNETPLAENDDATE
     , STAQNETPLARATIO
     , QUOTATIONUNITONLINE
     , QUOTATIONUNITOFFLINE
     , ODDLOTSTREATMENT
     , PARVALUE
     , ISSUEPRICE
     , STATESHARESISSUEPRICE
     , WEIGHTEDPERATIO
     , DILUTEDPERATIO
     , ISSUEVOL
     , STATESHARESISSUED
     , TOTALISSUEMV
     , ISSUECOST
     , UNDERWRITINGFEE
     , CPAFEE
     , ASSETAPPRAISALFEE
     , LANDEVALUATIONFEE
     , ATTORNEYFEE
     , TOTALAGENTFEE
     , ONLINEISSUEFEE
     , SCRIPFEE
     , SPONSORFEE
     , OTHERFEE
     , ISSUECOSTPERSHARE
     , FREEZEDMONEY
     , SNIPROCEEDS
     , SNINETPROCEEDS
     , STATESHARESPROCEEDS
     , STATESHARESNETPROCEEDS
     , MONEYTOACCOUNT
     , DATETOACCOUNT
     , NEWSHARELISTDATE
     , OUTSTANDINGSHARES
     , PUTBACKVOL
     , PREFPLAVOLH
     , PUBLICOFFERVOLONLINE
     , VALIDAPPLYVOLONLINE
     , VALIDAPPLYNUMONLINE
     , OVERSUBSTIMESONLINE
     , LOTRATEONLINE
     , PLAVOLLPOFFLINE
     , VALIDAPPLYVOLLPOFFLINE
     , VALIDAPPLYNUMLPOFFLINE
     , OVERSUBSTIMESLPOFFLINE
     , LOTRATELPOFFLINE
     , PLAVOLF
     , PLAVOLSTAQNET
     , TAILOREDPLAVOLLP
     , EARNINGFORECASTYEAR
     , MAININCOMEFORECAST
     , NETPROFITFORECAST
     , DILUTEDEPSFORECAST
     , UNDERWRITINGMODE
     , UNDERWRITERBOUGHTVOL
     , CHANGESTATEMENT
     , CHANGETYPE
     , XGRQ
     , JSID
     , PERATIOBEFOREISSUE
     , PERATIOAFTERISSUE
     , PREFPLAVOLHMAX
     , PREFPLAVOLHONLINE
     , PREFPLAVOLHOFFLINE
     , VALIDAPPLYHNUM
     , VALIDAPPLYNUMHONLINE
     , VALIDAPPLYNUMHOFFLINE
     , APLAVOLLPOFFLINE
     , AVALIDAPPLYVOLLPOFFLINE
     , AVALIDAPPLYNUMLPOFFLINE
     , ALOTRATELPOFFLINE
     , BPLAVOLLPOFFLINE
     , BVALIDAPPLYVOLLPOFFLINE
     , BVALIDAPPLYNUMLPOFFLINE
     , BLOTRATELPOFFLINE
     , PLAVOLHOFFLINE
     , VALIDPLAVOLHOFFLINE
     , VALIDPLANUMHOFFLINE
     , LOTRATEHOFFLINE
     , SASACAPPROVALPUBLDATE
     , CSRCAPPROVALPUBLDATE
     , EVENTPROCEDURECODE
     , ISOBTYPECODE
     , ADJUSTEDISSUEPRICE
     , PRICEADJUSTEDDATE
     , SCHEMECHANGEPUBLDATE
     , LISTANNOUNCEDATE
     , PROJINFOSOURCE
     , ISSUERESULTINFOSOURCE
     , ADJUSTEDISSUEVOL
     , PRICEVOLADJUSTEDDATE
     , ISSUEPURPOSE
     , PRICINGBASEDATE
     , PRICINGBASEDATEDESC
     , ISSUETYPE
     , IFEFFECTED
     , SUBSCRIBEMETHOD
     , LARGESHSUBMETHOD
     , LARGESHSUBSSUM
     , LARGESHSUBSRATIO
     , PLANNEDPROCEEDS
     , CURRENCYPROCEEDS
     , NONCURRENCYPROCEEDS
     , ASSETPROCEEDS
     , DEBTPROCEEDS
     , UWSPONFEE
     , CPAAPPRAISALFEE
     , PARVALUECURRENCYUNIT
     , ADJUSTEDVOLFLOOR
     , ADJUSTEDPRICECEILING
     , DISCOUNTRATEPERSHARE
     , SUBSCRIPTIONOFFERDATE
     , ORGPRICEBASEPRATIO
     , ACTPRICEBASEPRATIO
     , ADDSUBSCRIPTIONSDATE
     , ADDSUBSCRIPTIONEDATE
     , VERIFICATIONDATE
     , LATESTADVANCEDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_ASHARESEASONEDNEWISSUE_PFD成功"
      exit 0
   fi
fi
