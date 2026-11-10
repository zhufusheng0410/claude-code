#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_ASHAREIPO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHAREIPO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  INTENTLETTERPUBLDATE  STRING  COMMENT  '招股公告日(招股意向书发布日期)',
  INTENTLETTERSIGNDATE  STRING  COMMENT  '招股意向书签署日期',
  PROSPECTUSPUBLDATE  STRING  COMMENT  '招股说明书发布日期',
  PROSPECTUSSIGNDATE  STRING  COMMENT  '招股说明书签署日期',
  LISTANNOUNCEMENTDATE  STRING  COMMENT  '上市公告日(上市公告书发布日期)',
  RAISINGMETHOD  DECIMAL(10,0)  COMMENT  '募资方式',
  STOCKTYPE  STRING  COMMENT  '发行股票类型',
  ISSUEPRICECEILING  DECIMAL(19,4)  COMMENT  '发行价上限(最高价)(元)',
  ISSUEPRICEFLOOR  DECIMAL(19,4)  COMMENT  '发行价下限(元)',
  ISSUEVOLCEILING  DECIMAL(16,0)  COMMENT  '发行量上限(不多于)(股)',
  ISSUEVOLFLOOR  DECIMAL(16,0)  COMMENT  '发行量下限(股)',
  OVERALLOTMENTOPTION  DECIMAL(16,0)  COMMENT  '超额配售权(股)',
  PARVALUE  DECIMAL(25,10)  COMMENT  '面值(人民币)',
  ISSUEPRICE  DECIMAL(19,4)  COMMENT  '实际发行价(元)',
  STATESHARESISSUEPRICE  DECIMAL(19,4)  COMMENT  '*国有股存量发行每股发行价(元)',
  WEIGHTEDPERATIO  DECIMAL(19,8)  COMMENT  '发行市盈率(加权平均)(倍)',
  DILUTEDPERATIO  DECIMAL(19,8)  COMMENT  '发行市盈率(全面摊薄)(倍)',
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
  ISSUECOSTPERSHARE  DECIMAL(18,6)  COMMENT  '每股发行费用(元/股)',
  IPOPROCEEDS  DECIMAL(19,4)  COMMENT  '募集资金总额(元)',
  IPONETPROCEEDS  DECIMAL(19,4)  COMMENT  '募集资金净额(元)',
  STATESHARESPROCEEDS  DECIMAL(19,4)  COMMENT  '*国有股存量发行收入总额(元)',
  STATESHARESNETPROCEEDS  DECIMAL(19,4)  COMMENT  '*国有股存量发行收入净额(元)',
  MONEYTOACCOUNT  DECIMAL(19,4)  COMMENT  '募集资金到帐金额(元)',
  DATETOACCOUNT  STRING  COMMENT  '募集资金到帐时间',
  PRICINGMODEL  DECIMAL(10,0)  COMMENT  '定价方式',
  RATIONMODEL  DECIMAL(10,0)  COMMENT  '发行量定量方式',
  ISSUEMETHOD  DECIMAL(10,0)  COMMENT  '发行方式',
  ISSUEOBJECT  STRING  COMMENT  '发行对象',
  ISSUESTARTDATE  STRING  COMMENT  '发行日期上限',
  ISSUEENDDATE  STRING  COMMENT  '发行日期下限',
  ONLINESTARTDATE  STRING  COMMENT  '网上申购日期上限',
  ONLINEENDDATE  STRING  COMMENT  '网上申购日期下限',
  BOOKINGSTARTDATELP  STRING  COMMENT  '网下申购日期上限',
  BOOKINGENDDATELP  STRING  COMMENT  '网下申购日期下限',
  PAYSTARTDATELP  STRING  COMMENT  '*法人配售缴款期上限',
  PAYENDDATELP  STRING  COMMENT  '*法人配售缴款期下限',
  APPLYSTARTDATEF  STRING  COMMENT  '*基金优先配售申购日期上限',
  APPLYENDDATEF  STRING  COMMENT  '*基金优先配售申购日期下限',
  PAYSTARTDATEF  STRING  COMMENT  '*基金优先配售缴款期下限',
  PAYENDDATEF  STRING  COMMENT  '*基金优先配售缴款期上限',
  SECMARKETPLACINGDATE  STRING  COMMENT  '*二级市场配售日期',
  PAYSTARTDATESM  STRING  COMMENT  '*二级市场配售缴款日上限',
  PAYENDDATESM  STRING  COMMENT  '*二级市场配售缴款日下限',
  UNDERWRITINGSIGNDATE  STRING  COMMENT  '*承销协议签署日',
  UNDERWRITINGSTARTDATE  STRING  COMMENT  '*承销期上限',
  UNDERWRITINGENDDATE  STRING  COMMENT  '*承销期下限',
  PREPAREDLISTEXCHANGE  DECIMAL(10,0)  COMMENT  '上市地',
  LISTDATE  STRING  COMMENT  '上市日期',
  STAFFSHARESLISTDATE  STRING  COMMENT  '内部职工股上市日期',
  STAFFSHARESLISTTERM  DECIMAL(9,4)  COMMENT  '内部职工股上市期限(年)',
  OUTSTANDINGSHARES  DECIMAL(16,0)  COMMENT  '本次上市流通股数(股)',
  NUMOVER1000SHARES  DECIMAL(10,0)  COMMENT  '持1000股以上股东户数(户)',
  FIRSTOPENPRICE  DECIMAL(19,4)  COMMENT  '上市首日开盘价(元)',
  FIRSTCLOSEPRICE  DECIMAL(19,4)  COMMENT  '上市首日收盘价(元)',
  FIRSTHIGHPRICE  DECIMAL(19,4)  COMMENT  '上市首日最高价(元)',
  FIRSTLOWPRICE  DECIMAL(19,4)  COMMENT  '上市首日最低价(元)',
  FIRSTTURNOVER  DECIMAL(18,6)  COMMENT  '上市首日换手率(%)',
  APPLYCODEONLINE  STRING  COMMENT  '上网发行申购代码',
  SHARESONLINE  DECIMAL(16,0)  COMMENT  '网上实际发行股数(股)',
  APPLYUNITONLINE  DECIMAL(10,0)  COMMENT  '上网发行认购单位(股)',
  APPLYMAXONLINE  DECIMAL(16,0)  COMMENT  '上网发行申购上限(股)',
  VALIDAPPLYVOLONLINE  DECIMAL(16,0)  COMMENT  '网上发行有效申购总量(股)',
  VALIDAPPLYNUMONLINE  DECIMAL(10,0)  COMMENT  '网上发行有效申购户数(户)',
  OVERSUBSTIMESONLINE  DECIMAL(18,6)  COMMENT  '网上发行超额认购倍数(倍)',
  NUMALLOTEDONLINE  DECIMAL(10,0)  COMMENT  '网上发行配号总数(个)',
  FREEZEDMONEYONLINE  DECIMAL(19,4)  COMMENT  '网上发行冻结资金(元)',
  LOTRATEONLINE  DECIMAL(18,15)  COMMENT  '网上发行中签率',
  APPLYCODESM  STRING  COMMENT  '*二级市场配售申购代码',
  APPLYMAXSM  DECIMAL(16,0)  COMMENT  '*二级市场配售申购上限(股)',
  PLACINGSHARESSM  DECIMAL(16,0)  COMMENT  '*二级市场实际配售股数(股)',
  APPLYUNITSM  DECIMAL(10,0)  COMMENT  '*二级市场配售认购单位(股)',
  VALIDAPPLYVOLSM  DECIMAL(16,0)  COMMENT  '*二级市场配售有效申购总量(股)',
  VALIDAPPLYNUMSM  DECIMAL(10,0)  COMMENT  '*二级市场配售有效申购户数(户)',
  OVERSUBSTIMESSM  DECIMAL(9,4)  COMMENT  '*二级市场配售超额认购倍数(倍)',
  NUMALLOTEDSM  DECIMAL(10,0)  COMMENT  '*二级市场配售配号总数(个)',
  LOTRATESM  DECIMAL(18,15)  COMMENT  '*二级市场配售中签率',
  PLACINGSHARESLP  DECIMAL(16,0)  COMMENT  '网下实际配售股数(股)',
  APPLYUNITLP  DECIMAL(10,0)  COMMENT  '法人配售认购单位(股)',
  APPLYMAXLP  DECIMAL(16,0)  COMMENT  '法人配售申购上限(股)',
  APPLYMINLP  DECIMAL(16,0)  COMMENT  '法人配售申购下限(股)',
  VALIDAPPLYVOLLP  DECIMAL(16,0)  COMMENT  '配售有效申购总量(股)',
  VALIDAPPLYNUMLP  DECIMAL(10,0)  COMMENT  '配售有效申购户数(户)',
  OVERSUBSTIMESLP  DECIMAL(9,4)  COMMENT  '配售超额认购倍数(倍)',
  APPLYMONEYLP  DECIMAL(19,4)  COMMENT  '配售申购资金(元)',
  LOTRATELP  DECIMAL(18,15)  COMMENT  '配售中签率',
  FUNDPREFALLOTMENT  DECIMAL(18,6)  COMMENT  '*投资基金优先配售限额(占发行量)',
  SINGLEFUNDPREFALLOTMENT  DECIMAL(18,6)  COMMENT  '*单个基金优先配售限额(占发行量)',
  FUNPREFALLOTMENTSHARES  DECIMAL(16,0)  COMMENT  '*投资基金优先配售股数(股)',
  FUNPREFALLOTMENTHOLDTERM  DECIMAL(9,4)  COMMENT  '*投资基金优先配售持股期限(月)',
  STAQNETALLOTMENT  DECIMAL(16,0)  COMMENT  'STAQ/NET拟定向配售股数(股)',
  STAQNETSUBSCRIPTION  DECIMAL(16,0)  COMMENT  'STAQ/NET定向配售实际认购数(股)',
  STAFFALLOTMENT  DECIMAL(16,0)  COMMENT  '公司职工配售股数(股)',
  EARNINGFORECASTYEAR  STRING  COMMENT  '盈利预测年度',
  MAININCOMEFORECAST  DECIMAL(19,4)  COMMENT  '主营业务收入预测(元)',
  NETPROFITFORECAST  DECIMAL(19,4)  COMMENT  '净利润预测(元)',
  DILUTEDEPSFORECAST  DECIMAL(19,4)  COMMENT  '全面摊薄每股盈利预测(元)',
  DIVIDENDPOLICY  STRING  COMMENT  '股利分配政策',
  ESTIMATEDFIRSTDIVIDATE  STRING  COMMENT  '预计首次分配时间',
  UNDERWRITINGMODE  DECIMAL(10,0)  COMMENT  '承销方式',
  UNDERWRITERBOUGHTVOL  DECIMAL(16,0)  COMMENT  '余股包销数量(股)',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  PERATIOBEFOREISSUE  DECIMAL(19,8)  COMMENT  '发行市盈率(按发行前总股本)(倍)',
  PERATIOAFTERISSUE  DECIMAL(19,8)  COMMENT  '发行市盈率(按发行后总股本预测利润)(倍)',
  BIDDERNUMBERLP  DECIMAL(16,0)  COMMENT  '配售投标询价对象家数(家)',
  PLACINGNUMBERLP  DECIMAL(10,0)  COMMENT  '配售对象家数(家)',
  APPLYVOLLP  DECIMAL(16,0)  COMMENT  '配售申购总量(股)',
  TAILOREDPLAVOLLP  DECIMAL(16,0)  COMMENT  '法人定向配售股数/战略定向配售(股)',
  ONLINEISSUEPLAN  DECIMAL(19,2)  COMMENT  '网上发行计划(股)',
  OFFLINEAPPLYPLAN  DECIMAL(19,2)  COMMENT  '网下配售计划(股)',
  STRATEGYAPPLYPLAN  DECIMAL(19,2)  COMMENT  '战略配售计划(股)',
  REFUNDMENTDATE_OFFLINE  STRING  COMMENT  '网下申购资金退款日',
  REFUNDMENTDATE_ONLINE  STRING  COMMENT  '网上申购资金解冻日',
  ISSUENAMEABBR_ONLINE  STRING  COMMENT  '上网发行申购简称',
  APPLYFLOOR_ONLINE  DECIMAL(10,0)  COMMENT  '上网发行申购下限(至少)(股)',
  LOACCUAPPLYCEILING  DECIMAL(19,2)  COMMENT  '法定机构帐户累计申购上限(股)',
  OFFLINELOCKPERIOD  DECIMAL(10,0)  COMMENT  '网下配售股票锁定期(月)',
  OVERSUBSUM  DECIMAL(19,2)  COMMENT  '发行时超额配售股数(股)',
  EXGSOPTIONPUBLDATE  STRING  COMMENT  '绿鞋行使情况公告日',
  EXGSOPTIONENDDATE  STRING  COMMENT  '绿鞋行使截止日',
  SLBUYSUM  DECIMAL(19,2)  COMMENT  '二级买入股数(股)',
  EXGSOPTIONOVERSUBSUM  DECIMAL(19,2)  COMMENT  '绿鞋行使超额配售股数(股)',
  NAPSBEFOREISSUE  DECIMAL(19,4)  COMMENT  '发行前每股净资产',
  NAPSAFTERISSUE  DECIMAL(19,4)  COMMENT  '发行后每股净资产',
  ISSUERESULTPUBLDATE  STRING  COMMENT  '中签率公告日',
  NORMALLEGALPERSONSHARELD  STRING  COMMENT  '向一般法人配售部分上市日期',
  STRATEGICINVESTORSHARELD  STRING  COMMENT  '向战略投资者配售部分上市日期',
  LEADUNDERWRITER  STRING  COMMENT  '主承销商',
  COLEADUNDERWRITER  STRING  COMMENT  '副主承销商',
  LISTINGSPONSOR  STRING  COMMENT  '上市推荐人',
  DISTRIBUTOR  STRING  COMMENT  '分销商',
  INTERNATIONALCOORDINATOR  STRING  COMMENT  '国际协调人',
  NORMALLEGALPERSONSHARE  DECIMAL(16,0)  COMMENT  '其中:向一般法人配售数量(股)',
  STRATEGICINVESTORSHARE  DECIMAL(16,0)  COMMENT  '向战略投资者配售数量(股)',
  OTHERPLACINGSHARE  DECIMAL(16,0)  COMMENT  '其他发行数量(股)',
  PLACINGSHAREPROPORTION  DECIMAL(18,6)  COMMENT  '网下申购配售比例(%)',
  TOTALSHARESLISTDATE  DECIMAL(16,0)  COMMENT  '首发后总股本_上市日(股)',
  TOTALSHARESBEFOREISSUE  DECIMAL(16,0)  COMMENT  '首发前总股本(股)',
  FIRSTAVGPRICE  DECIMAL(19,4)  COMMENT  '上市首日成交均价(元)',
  FIRSTTURNOVERVOLUME  DECIMAL(16,0)  COMMENT  '上市首日成交量(股)',
  FIRSTTURNOVERVALUE  DECIMAL(19,4)  COMMENT  '上市首日成交额(元)',
  FIRSTCHANGEPCT  DECIMAL(18,6)  COMMENT  '上市首日涨跌幅(%)',
  SECUCODE  STRING  COMMENT  '证券代码',
  PLANNEDPROCEEDS  DECIMAL(19,4)  COMMENT  '拟募集资金总额(元)',
  PRICENUMBERPI  DECIMAL(10,0)  COMMENT  '初步询价价位个数',
  MINPROGRESSIVEPRICEPI  DECIMAL(9,4)  COMMENT  '初步询价最小累进价格',
  MINAPPLYINGPRICEPI  DECIMAL(9,4)  COMMENT  '初步询价最低申购价格',
  PRICENUMBERBB  DECIMAL(10,0)  COMMENT  '累计询价价位个数',
  MINPROGRESSIVEPRICEBB  DECIMAL(9,4)  COMMENT  '累计询价最小累进价格',
  MAXAPPLYINGRATIOBB  DECIMAL(9,6)  COMMENT  '累计询价申购数量上限比例(%)',
  SECURITYABBR  STRING  COMMENT  '证券简称',
  ISSUEPROCESSCODE  DECIMAL(10,0)  COMMENT  '发行进程',
  TIMESBB  DECIMAL(19,8)  COMMENT  '询价累积报价倍数',
  ORIGINALVOLCEILING  DECIMAL(16,0)  COMMENT  '老股转让发行量上限(股)',
  ORIGINALVOL  DECIMAL(16,0)  COMMENT  '其中老股转让发行量(股)',
  OLBEFPUTBACK  DECIMAL(19,4)  COMMENT  '网上发行量(回拨前)(万股)',
  OFFLBEFPUTBACK  DECIMAL(19,4)  COMMENT  '网下发行量(回拨前)(万股)',
  PAYDATEONLINE  STRING  COMMENT  '网上申购缴款日期',
  PAYDATEOFFLINE  STRING  COMMENT  '网下申购缴款日期',
  ISSUEPUBLDATE  STRING  COMMENT  '发行公告日',
  RESULTPULBDATE  STRING  COMMENT  '发行结果公告日',
  SUBSSHAREOL  DECIMAL(19,4)  COMMENT  '投资者缴款认购股数(股)(网上)',
  SUBSMONEYOL  DECIMAL(19,4)  COMMENT  '投资者缴款认购金额(网上)',
  ABANDONSUBSSOL  DECIMAL(19,2)  COMMENT  '投资者放弃认购股数(股)(网上)',
  ABANDONSUBSMOL  DECIMAL(19,4)  COMMENT  '投资者放弃认购金额(网上)',
  UNDERWRITSOL  DECIMAL(19,2)  COMMENT  '包销股数(网上放弃)',
  UNDERWRITMOL  DECIMAL(19,4)  COMMENT  '包销金额(网上放弃)',
  UNDERWRITPOL  DECIMAL(19,4)  COMMENT  '包销比例(网上放弃)',
  SUBSSHAREFL  DECIMAL(19,4)  COMMENT  '投资者缴款认购股数(股)(网下)',
  SUBSMONEYFL  DECIMAL(19,4)  COMMENT  '投资者缴款认购金额(网下)',
  ABANDONSUBSSFL  DECIMAL(19,2)  COMMENT  '投资者放弃认购股数(股)(网下)',
  ABANDONSUBSMFL  DECIMAL(19,4)  COMMENT  '投资者放弃认购金额(网下)',
  UNDERWRITSFL  DECIMAL(19,2)  COMMENT  '包销股数(网下放弃)',
  UNDERWRITMFL  DECIMAL(19,4)  COMMENT  '包销金额(网下放弃)',
  UNDERWRITPFL  DECIMAL(19,4)  COMMENT  '包销比例(网下放弃)',
  MARKVALUEFLOOR  DECIMAL(19,8)  COMMENT  '网下发行询价资格所需持有市值下限(元)',
  MARKVALUESTATMT  STRING  COMMENT  '网下发行询价资格所需持有市值说明',
  LOTNUMONLINE  STRING  COMMENT  '网上发行中签号',
  ESTIISSUEPRICE  DECIMAL(19,4)  COMMENT  '预估发行价(元)',
  ESTIAPMAXONLINE  DECIMAL(16,0)  COMMENT  '预估上网发行申购上限(最多股)',
  ALOTRATELP  DECIMAL(12,10)  COMMENT  '其中:A类投资者配售中签率',
  BLOTRATELP  DECIMAL(12,10)  COMMENT  '其中:B类投资者配售中签率',
  CLOTRATELP  DECIMAL(12,10)  COMMENT  '其中:C类投资者配售中签率',
  ESTIPERATIO  DECIMAL(19,8)  COMMENT  '预估市盈率(倍)',
  FUNDMARKVALUEFLOOR  DECIMAL(19,4)  COMMENT  '公募、养老和社保基金所需持有市值下限(元)',
  OTHERMARKVALUEFLOOR  DECIMAL(19,4)  COMMENT  '其他网下投资者所需持有市值下限(元)',
  MAXAPPLYINGPRICEPI  DECIMAL(19,4)  COMMENT  '初步询价最高申购价格(元)',
  QUOTEMEDIAN  DECIMAL(19,4)  COMMENT  '网下投资者全部报价中位数(元/股)',
  WEIGHTEDQUOTATION  DECIMAL(19,4)  COMMENT  '网下投资者全部加权平均报价(元/股)',
  FUNDQUOTEMEDIAN  DECIMAL(19,4)  COMMENT  '公募基金报价中位数(元/股)',
  FUNDWEIGHTEDQUOTATION  DECIMAL(19,4)  COMMENT  '公募基金加权平均报价(元/股)',
  EXHIGHPRICEMEDIAN  DECIMAL(19,4)  COMMENT  '剔除最高报价网下投资者报价中位数(元/股)',
  EXHIGHPRICEWQ  DECIMAL(19,4)  COMMENT  '剔除最高报价网下投资者加权平均报价(元/股)',
  EXHIGHPRICEFUNDMEDIAN  DECIMAL(19,4)  COMMENT  '剔除最高报价公募基金报价中位数(元/股)',
  EXHIGHPRICEFUNDWQ  DECIMAL(19,4)  COMMENT  '剔除最高报价公募基金加权平均报价(元/股)',
  PERBEFOREISSUENCUTNP  DECIMAL(19,8)  COMMENT  '##扣非净利润前发行市盈率(按发行前总股本)(倍)',
  PERBEFOREISSUECUTNP  DECIMAL(19,8)  COMMENT  '##扣非净利润后发行市盈率(按发行前总股本)(倍)',
  PERAFTERISSUENCUTNP  DECIMAL(19,8)  COMMENT  '##扣非净利润前发行市盈率(按发行后总股本)(倍)',
  PERAFTERISSUECUTNP  DECIMAL(19,8)  COMMENT  '##扣非净利润后发行市盈率(按发行后总股本)(倍)',
  INITIALINVESTORNUM  DECIMAL(10,0)  COMMENT  '初步询价投资者家数(家)',
  INITIALAPPLYVOL  DECIMAL(16,0)  COMMENT  '初步询价申报总量(股)',
  CONFORMINVESTORNUM  DECIMAL(10,0)  COMMENT  '符合规定投资者家数(家)',
  CONFORMBIDDERNUM  DECIMAL(10,0)  COMMENT  '符合规定投资者家数(家)',
  CONFORMAPPLYVOL  DECIMAL(16,0)  COMMENT  '符合规定询价申报总量(股)',
  VALIDQUOTEINVESTORNUM  DECIMAL(10,0)  COMMENT  '有效报价投资者家数(家)',
  VALIDAPPLYINVESTORNUM  DECIMAL(10,0)  COMMENT  '法人配售有效申购投资者家数(家)',
  EXABANDONAPPLYNUMLP  DECIMAL(10,0)  COMMENT  '剔除放弃认购后有效申购配售对象家数(家)',
  EXABANDONAPPLYVOLLP  DECIMAL(16,0)  COMMENT  '剔除放弃认购后有效申购总量(股)',
  OFFLINELOCKARRANGE  DECIMAL(10,0)  COMMENT  '网下配售锁定期安排',
  AVERAGESTATICPE  DECIMAL(19,8)  COMMENT  '中证行业平均静态市盈率',
  PEEFFECTIVEDATE  STRING  COMMENT  '行业市盈率生效日期',
  LISTSTANDARD  DECIMAL(10,0)  COMMENT  '上市标准',
  EXABOVEPRICE  DECIMAL(19,4)  COMMENT  '申购价格(元)',
  APPLYPERATIO  DECIMAL(19,8)  COMMENT  '申购市盈率(倍)',
  UNDERWRITAOL  DECIMAL(19,2)  COMMENT  '包销股数(未达网上申购单位余股)',
  PARVALUECURRENCYUNIT  DECIMAL(10,0)  COMMENT  '每股面值货币单位',
  CEFUNDMARKVALUEFLOOR  DECIMAL(19,4)  COMMENT  '其中:创业板主题封闭基金所需持有市值下限(元)',
  PLANNEDNETPROCEEDS  DECIMAL(19,4)  COMMENT  '拟募集资金净额(元)',
  CORESTAFFSSHAREPLAN  DECIMAL(19,2)  COMMENT  '其中:高管、员工计划参与战略配售数量(股)(份)',
  CORESTAFFSRATIOPLAN  DECIMAL(19,8)  COMMENT  '其中:高管、员工计划参与战略配售占比(%)',
  SPONSORSHAREPLAN  DECIMAL(19,2)  COMMENT  '其中:保荐机构及相关子公司计划参与战略配售数量(股)(份)',
  SPONSORRATIOPLAN  DECIMAL(19,8)  COMMENT  '其中:保荐机构及相关子公司计划参与战略配售占比(%)',
  OTHERSTRASHVOL  DECIMAL(19,2)  COMMENT  '其中:其他参与战略配售计划数量(股)(份)',
  OTHERSTRASHRAT  DECIMAL(19,8)  COMMENT  '其中:其他计划参与战略配售占比(%)',
  CORESTAFFSSHARE  DECIMAL(16,0)  COMMENT  '其中:向高管、员工战略配售数量(股)(份)',
  SPONSORSHARE  DECIMAL(16,0)  COMMENT  '其中:向保荐机构及相关子公司战略配售数量(股)(份)',
  OTHERSHARE  DECIMAL(16,0)  COMMENT  '其中:向其他参与战略配售股数(股)(份)',
  APLACINGSHARESLP  DECIMAL(16,0)  COMMENT  '其中:A类实际配售股数(股)(份)',
  BPLACINGSHARESLP  DECIMAL(16,0)  COMMENT  '其中:B类实际配售股数(股)(份)',
  CPLACINGSHARESLP  DECIMAL(16,0)  COMMENT  '其中:C类实际配售股数(股)(份)',
  AVALIDAPPLYVOLLP  DECIMAL(16,0)  COMMENT  '其中:A类有效申购总量(股)(份)',
  BVALIDAPPLYVOLLP  DECIMAL(16,0)  COMMENT  '其中:B类有效申购总量(股)(份)',
  CVALIDAPPLYVOLLP  DECIMAL(16,0)  COMMENT  '其中:C类有效申购总量(股)(份)',
  ONLINEISSUEEXOVER  DECIMAL(16,0)  COMMENT  '网上发行计划(剔除超额)(股)(份)',
  INSERTTIME  STRING  COMMENT  '发布时间',
  PLANNEDPROCEEDSEXGS  DECIMAL(19,4)  COMMENT  '拟募集资金总额(超额配售全额行使后)(元)',
  PLANNEDNPROCEEDSEXGS  DECIMAL(19,4)  COMMENT  '拟募集资金净额(超额配售全额行使后)(元)',
  OLBEFPUTBACKEXGS  DECIMAL(19,4)  COMMENT  '网上发行量(回拨前)(超额配售选择权行使后)(万股)(万份)',
  PLACINGNUMBERONLINE  DECIMAL(16,0)  COMMENT  '网上发行获配户数(户)',
  PLACINGSHARESONLINE  DECIMAL(16,0)  COMMENT  '网上发行获配股数(股)(份)',
  PLACINGRATEONLINE  DECIMAL(19,8)  COMMENT  '网上发行获配比例(%)',
  GSBUYMAXPRICESM  DECIMAL(19,8)  COMMENT  '二级买入每股最高价(元)',
  GSBUYMINPRICESM  DECIMAL(19,8)  COMMENT  '二级买入每股最低价(元)',
  GSBUYAVGPRICESM  DECIMAL(19,8)  COMMENT  '二级买入每股平均价(元)',
  GSTOTALCONSIDERATIONSM  DECIMAL(19,4)  COMMENT  '二级买入支付对价总额(元)',
  GSMONEYTOACCOUNT  DECIMAL(19,4)  COMMENT  '绿鞋行使募集资金到帐金额(元)',
  GSDATETOACCOUNT  STRING  COMMENT  '绿鞋行使募集资金到帐时间',
  ISSUEVOLEXGS  DECIMAL(16,0)  COMMENT  '发行量(超额配售选择权行使后)(股)(份)',
  TOTALISSUEMVEXGS  DECIMAL(19,4)  COMMENT  '发行总市值(超额配售选择权行使后)(元)',
  DILUTEDPERATIOFEXGS  DECIMAL(19,8)  COMMENT  '发行市盈率(按全额行使超额配售后总股本)(倍)',
  PERAISSUENCUTNPFEXGS  DECIMAL(19,8)  COMMENT  '##扣非净利润前发行市盈率(全额行使超额配售后)(倍)',
  PERAISSUECUTNPFEXGS  DECIMAL(19,8)  COMMENT  '##扣非净利润后发行市盈率(全额行使超额配售后)(倍)',
  PBRATIOBEFOREISSUE  DECIMAL(19,8)  COMMENT  '发行市净率(按发行前总股本)(倍)',
  PBRATIOAFTERISSUE  DECIMAL(19,8)  COMMENT  '发行市净率(按发行后总股本)(倍)',
  PBRATIOAFTERISSUEFEXGS  DECIMAL(19,8)  COMMENT  '发行市净率(按全额行使超额配售后总股本)(倍)',
  NAPSAFTERISSUEFEXGS  DECIMAL(19,8)  COMMENT  '发行后每股净资产(超额配售选择权全额行使后)',
  LATESTINFOPUBLDATE  STRING  COMMENT  '最新公告日期',
  PROPOSEDLISTDATE  STRING  COMMENT  '预计上市日期1',
  MVAPPLYREGDATEONLINE  STRING  COMMENT  '网上市值申购登记日',
  MVCALREFDAYONLINE  STRING  COMMENT  '网下市值计算参考日',
  DATASUBMITENDDATEOFFLINE  STRING  COMMENT  '网下核查材料报备截止日期',
  DATASUBMITENDTIMEOFFLINE  STRING  COMMENT  '网下核查材料报备截止时间',
  EXABANDONOVERSUBSTLP  DECIMAL(9,4)  COMMENT  '法人配售(剔除放弃认购)超额认购倍数',
  EXABANDONLOTRATELP  DECIMAL(12,10)  COMMENT  '法人配售(剔除放弃认购)中签率(%)',
  CALLBACKVOL  DECIMAL(19,2)  COMMENT  '回拨股数(股)',
  CALLBACKRATIO  DECIMAL(9,4)  COMMENT  '回拨比例(%)',
  CALLBACKDIRECTION  STRING  COMMENT  '回拨方向'
)
COMMENT 'A股发行与上市'
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
                                   , INTENTLETTERPUBLDATE
                                   , INTENTLETTERSIGNDATE
                                   , PROSPECTUSPUBLDATE
                                   , PROSPECTUSSIGNDATE
                                   , LISTANNOUNCEMENTDATE
                                   , RAISINGMETHOD
                                   , STOCKTYPE
                                   , ISSUEPRICECEILING
                                   , ISSUEPRICEFLOOR
                                   , ISSUEVOLCEILING
                                   , ISSUEVOLFLOOR
                                   , OVERALLOTMENTOPTION
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
                                   , IPOPROCEEDS
                                   , IPONETPROCEEDS
                                   , STATESHARESPROCEEDS
                                   , STATESHARESNETPROCEEDS
                                   , MONEYTOACCOUNT
                                   , DATETOACCOUNT
                                   , PRICINGMODEL
                                   , RATIONMODEL
                                   , ISSUEMETHOD
                                   , ISSUEOBJECT
                                   , ISSUESTARTDATE
                                   , ISSUEENDDATE
                                   , ONLINESTARTDATE
                                   , ONLINEENDDATE
                                   , BOOKINGSTARTDATELP
                                   , BOOKINGENDDATELP
                                   , PAYSTARTDATELP
                                   , PAYENDDATELP
                                   , APPLYSTARTDATEF
                                   , APPLYENDDATEF
                                   , PAYSTARTDATEF
                                   , PAYENDDATEF
                                   , SECMARKETPLACINGDATE
                                   , PAYSTARTDATESM
                                   , PAYENDDATESM
                                   , UNDERWRITINGSIGNDATE
                                   , UNDERWRITINGSTARTDATE
                                   , UNDERWRITINGENDDATE
                                   , PREPAREDLISTEXCHANGE
                                   , LISTDATE
                                   , STAFFSHARESLISTDATE
                                   , STAFFSHARESLISTTERM
                                   , OUTSTANDINGSHARES
                                   , NUMOVER1000SHARES
                                   , FIRSTOPENPRICE
                                   , FIRSTCLOSEPRICE
                                   , FIRSTHIGHPRICE
                                   , FIRSTLOWPRICE
                                   , FIRSTTURNOVER
                                   , APPLYCODEONLINE
                                   , SHARESONLINE
                                   , APPLYUNITONLINE
                                   , APPLYMAXONLINE
                                   , VALIDAPPLYVOLONLINE
                                   , VALIDAPPLYNUMONLINE
                                   , OVERSUBSTIMESONLINE
                                   , NUMALLOTEDONLINE
                                   , FREEZEDMONEYONLINE
                                   , LOTRATEONLINE
                                   , APPLYCODESM
                                   , APPLYMAXSM
                                   , PLACINGSHARESSM
                                   , APPLYUNITSM
                                   , VALIDAPPLYVOLSM
                                   , VALIDAPPLYNUMSM
                                   , OVERSUBSTIMESSM
                                   , NUMALLOTEDSM
                                   , LOTRATESM
                                   , PLACINGSHARESLP
                                   , APPLYUNITLP
                                   , APPLYMAXLP
                                   , APPLYMINLP
                                   , VALIDAPPLYVOLLP
                                   , VALIDAPPLYNUMLP
                                   , OVERSUBSTIMESLP
                                   , APPLYMONEYLP
                                   , LOTRATELP
                                   , FUNDPREFALLOTMENT
                                   , SINGLEFUNDPREFALLOTMENT
                                   , FUNPREFALLOTMENTSHARES
                                   , FUNPREFALLOTMENTHOLDTERM
                                   , STAQNETALLOTMENT
                                   , STAQNETSUBSCRIPTION
                                   , STAFFALLOTMENT
                                   , EARNINGFORECASTYEAR
                                   , MAININCOMEFORECAST
                                   , NETPROFITFORECAST
                                   , DILUTEDEPSFORECAST
                                   , DIVIDENDPOLICY
                                   , ESTIMATEDFIRSTDIVIDATE
                                   , UNDERWRITINGMODE
                                   , UNDERWRITERBOUGHTVOL
                                   , XGRQ
                                   , JSID
                                   , PERATIOBEFOREISSUE
                                   , PERATIOAFTERISSUE
                                   , BIDDERNUMBERLP
                                   , PLACINGNUMBERLP
                                   , APPLYVOLLP
                                   , TAILOREDPLAVOLLP
                                   , ONLINEISSUEPLAN
                                   , OFFLINEAPPLYPLAN
                                   , STRATEGYAPPLYPLAN
                                   , REFUNDMENTDATE_OFFLINE
                                   , REFUNDMENTDATE_ONLINE
                                   , ISSUENAMEABBR_ONLINE
                                   , APPLYFLOOR_ONLINE
                                   , LOACCUAPPLYCEILING
                                   , OFFLINELOCKPERIOD
                                   , OVERSUBSUM
                                   , EXGSOPTIONPUBLDATE
                                   , EXGSOPTIONENDDATE
                                   , SLBUYSUM
                                   , EXGSOPTIONOVERSUBSUM
                                   , NAPSBEFOREISSUE
                                   , NAPSAFTERISSUE
                                   , ISSUERESULTPUBLDATE
                                   , NORMALLEGALPERSONSHARELD
                                   , STRATEGICINVESTORSHARELD
                                   , LEADUNDERWRITER
                                   , COLEADUNDERWRITER
                                   , LISTINGSPONSOR
                                   , DISTRIBUTOR
                                   , INTERNATIONALCOORDINATOR
                                   , NORMALLEGALPERSONSHARE
                                   , STRATEGICINVESTORSHARE
                                   , OTHERPLACINGSHARE
                                   , PLACINGSHAREPROPORTION
                                   , TOTALSHARESLISTDATE
                                   , TOTALSHARESBEFOREISSUE
                                   , FIRSTAVGPRICE
                                   , FIRSTTURNOVERVOLUME
                                   , FIRSTTURNOVERVALUE
                                   , FIRSTCHANGEPCT
                                   , SECUCODE
                                   , PLANNEDPROCEEDS
                                   , PRICENUMBERPI
                                   , MINPROGRESSIVEPRICEPI
                                   , MINAPPLYINGPRICEPI
                                   , PRICENUMBERBB
                                   , MINPROGRESSIVEPRICEBB
                                   , MAXAPPLYINGRATIOBB
                                   , SECURITYABBR
                                   , ISSUEPROCESSCODE
                                   , TIMESBB
                                   , ORIGINALVOLCEILING
                                   , ORIGINALVOL
                                   , OLBEFPUTBACK
                                   , OFFLBEFPUTBACK
                                   , PAYDATEONLINE
                                   , PAYDATEOFFLINE
                                   , ISSUEPUBLDATE
                                   , RESULTPULBDATE
                                   , SUBSSHAREOL
                                   , SUBSMONEYOL
                                   , ABANDONSUBSSOL
                                   , ABANDONSUBSMOL
                                   , UNDERWRITSOL
                                   , UNDERWRITMOL
                                   , UNDERWRITPOL
                                   , SUBSSHAREFL
                                   , SUBSMONEYFL
                                   , ABANDONSUBSSFL
                                   , ABANDONSUBSMFL
                                   , UNDERWRITSFL
                                   , UNDERWRITMFL
                                   , UNDERWRITPFL
                                   , MARKVALUEFLOOR
                                   , MARKVALUESTATMT
                                   , LOTNUMONLINE
                                   , ESTIISSUEPRICE
                                   , ESTIAPMAXONLINE
                                   , ALOTRATELP
                                   , BLOTRATELP
                                   , CLOTRATELP
                                   , ESTIPERATIO
                                   , FUNDMARKVALUEFLOOR
                                   , OTHERMARKVALUEFLOOR
                                   , MAXAPPLYINGPRICEPI
                                   , QUOTEMEDIAN
                                   , WEIGHTEDQUOTATION
                                   , FUNDQUOTEMEDIAN
                                   , FUNDWEIGHTEDQUOTATION
                                   , EXHIGHPRICEMEDIAN
                                   , EXHIGHPRICEWQ
                                   , EXHIGHPRICEFUNDMEDIAN
                                   , EXHIGHPRICEFUNDWQ
                                   , PERBEFOREISSUENCUTNP
                                   , PERBEFOREISSUECUTNP
                                   , PERAFTERISSUENCUTNP
                                   , PERAFTERISSUECUTNP
                                   , INITIALINVESTORNUM
                                   , INITIALAPPLYVOL
                                   , CONFORMINVESTORNUM
                                   , CONFORMBIDDERNUM
                                   , CONFORMAPPLYVOL
                                   , VALIDQUOTEINVESTORNUM
                                   , VALIDAPPLYINVESTORNUM
                                   , EXABANDONAPPLYNUMLP
                                   , EXABANDONAPPLYVOLLP
                                   , OFFLINELOCKARRANGE
                                   , AVERAGESTATICPE
                                   , PEEFFECTIVEDATE
                                   , LISTSTANDARD
                                   , EXABOVEPRICE
                                   , APPLYPERATIO
                                   , UNDERWRITAOL
                                   , PARVALUECURRENCYUNIT
                                   , CEFUNDMARKVALUEFLOOR
                                   , PLANNEDNETPROCEEDS
                                   , CORESTAFFSSHAREPLAN
                                   , CORESTAFFSRATIOPLAN
                                   , SPONSORSHAREPLAN
                                   , SPONSORRATIOPLAN
                                   , OTHERSTRASHVOL
                                   , OTHERSTRASHRAT
                                   , CORESTAFFSSHARE
                                   , SPONSORSHARE
                                   , OTHERSHARE
                                   , APLACINGSHARESLP
                                   , BPLACINGSHARESLP
                                   , CPLACINGSHARESLP
                                   , AVALIDAPPLYVOLLP
                                   , BVALIDAPPLYVOLLP
                                   , CVALIDAPPLYVOLLP
                                   , ONLINEISSUEEXOVER
                                   , INSERTTIME
                                   , PLANNEDPROCEEDSEXGS
                                   , PLANNEDNPROCEEDSEXGS
                                   , OLBEFPUTBACKEXGS
                                   , PLACINGNUMBERONLINE
                                   , PLACINGSHARESONLINE
                                   , PLACINGRATEONLINE
                                   , GSBUYMAXPRICESM
                                   , GSBUYMINPRICESM
                                   , GSBUYAVGPRICESM
                                   , GSTOTALCONSIDERATIONSM
                                   , GSMONEYTOACCOUNT
                                   , GSDATETOACCOUNT
                                   , ISSUEVOLEXGS
                                   , TOTALISSUEMVEXGS
                                   , DILUTEDPERATIOFEXGS
                                   , PERAISSUENCUTNPFEXGS
                                   , PERAISSUECUTNPFEXGS
                                   , PBRATIOBEFOREISSUE
                                   , PBRATIOAFTERISSUE
                                   , PBRATIOAFTERISSUEFEXGS
                                   , NAPSAFTERISSUEFEXGS
                                   , LATESTINFOPUBLDATE
                                   , PROPOSEDLISTDATE
                                   , MVAPPLYREGDATEONLINE
                                   , MVCALREFDAYONLINE
                                   , DATASUBMITENDDATEOFFLINE
                                   , DATASUBMITENDTIMEOFFLINE
                                   , EXABANDONOVERSUBSTLP
                                   , EXABANDONLOTRATELP
                                   , CALLBACKVOL
                                   , CALLBACKRATIO
                                   , CALLBACKDIRECTION
                                FROM ${jy_src_schema}.LC_ASHAREIPO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "INTENTLETTERPUBLDATE", "type": "STRING"}, {"name": "INTENTLETTERSIGNDATE", "type": "STRING"}, {"name": "PROSPECTUSPUBLDATE", "type": "STRING"}, {"name": "PROSPECTUSSIGNDATE", "type": "STRING"}, {"name": "LISTANNOUNCEMENTDATE", "type": "STRING"}, {"name": "RAISINGMETHOD", "type": "DOUBLE"}, {"name": "STOCKTYPE", "type": "DOUBLE"}, {"name": "ISSUEPRICECEILING", "type": "DOUBLE"}, {"name": "ISSUEPRICEFLOOR", "type": "DOUBLE"}, {"name": "ISSUEVOLCEILING", "type": "DOUBLE"}, {"name": "ISSUEVOLFLOOR", "type": "DOUBLE"}, {"name": "OVERALLOTMENTOPTION", "type": "DOUBLE"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "ISSUEPRICE", "type": "DOUBLE"}, {"name": "STATESHARESISSUEPRICE", "type": "DOUBLE"}, {"name": "WEIGHTEDPERATIO", "type": "DOUBLE"}, {"name": "DILUTEDPERATIO", "type": "DOUBLE"}, {"name": "ISSUEVOL", "type": "DOUBLE"}, {"name": "STATESHARESISSUED", "type": "DOUBLE"}, {"name": "TOTALISSUEMV", "type": "DOUBLE"}, {"name": "ISSUECOST", "type": "DOUBLE"}, {"name": "UNDERWRITINGFEE", "type": "DOUBLE"}, {"name": "CPAFEE", "type": "DOUBLE"}, {"name": "ASSETAPPRAISALFEE", "type": "DOUBLE"}, {"name": "LANDEVALUATIONFEE", "type": "DOUBLE"}, {"name": "ATTORNEYFEE", "type": "DOUBLE"}, {"name": "TOTALAGENTFEE", "type": "DOUBLE"}, {"name": "ONLINEISSUEFEE", "type": "DOUBLE"}, {"name": "SCRIPFEE", "type": "DOUBLE"}, {"name": "SPONSORFEE", "type": "DOUBLE"}, {"name": "OTHERFEE", "type": "DOUBLE"}, {"name": "ISSUECOSTPERSHARE", "type": "DOUBLE"}, {"name": "IPOPROCEEDS", "type": "DOUBLE"}, {"name": "IPONETPROCEEDS", "type": "DOUBLE"}, {"name": "STATESHARESPROCEEDS", "type": "DOUBLE"}, {"name": "STATESHARESNETPROCEEDS", "type": "DOUBLE"}, {"name": "MONEYTOACCOUNT", "type": "DOUBLE"}, {"name": "DATETOACCOUNT", "type": "STRING"}, {"name": "PRICINGMODEL", "type": "DOUBLE"}, {"name": "RATIONMODEL", "type": "DOUBLE"}, {"name": "ISSUEMETHOD", "type": "DOUBLE"}, {"name": "ISSUEOBJECT", "type": "STRING"}, {"name": "ISSUESTARTDATE", "type": "STRING"}, {"name": "ISSUEENDDATE", "type": "STRING"}, {"name": "ONLINESTARTDATE", "type": "STRING"}, {"name": "ONLINEENDDATE", "type": "STRING"}, {"name": "BOOKINGSTARTDATELP", "type": "STRING"}, {"name": "BOOKINGENDDATELP", "type": "STRING"}, {"name": "PAYSTARTDATELP", "type": "STRING"}, {"name": "PAYENDDATELP", "type": "STRING"}, {"name": "APPLYSTARTDATEF", "type": "STRING"}, {"name": "APPLYENDDATEF", "type": "STRING"}, {"name": "PAYSTARTDATEF", "type": "STRING"}, {"name": "PAYENDDATEF", "type": "STRING"}, {"name": "SECMARKETPLACINGDATE", "type": "STRING"}, {"name": "PAYSTARTDATESM", "type": "STRING"}, {"name": "PAYENDDATESM", "type": "STRING"}, {"name": "UNDERWRITINGSIGNDATE", "type": "STRING"}, {"name": "UNDERWRITINGSTARTDATE", "type": "STRING"}, {"name": "UNDERWRITINGENDDATE", "type": "STRING"}, {"name": "PREPAREDLISTEXCHANGE", "type": "DOUBLE"}, {"name": "LISTDATE", "type": "STRING"}, {"name": "STAFFSHARESLISTDATE", "type": "STRING"}, {"name": "STAFFSHARESLISTTERM", "type": "DOUBLE"}, {"name": "OUTSTANDINGSHARES", "type": "DOUBLE"}, {"name": "NUMOVER1000SHARES", "type": "DOUBLE"}, {"name": "FIRSTOPENPRICE", "type": "DOUBLE"}, {"name": "FIRSTCLOSEPRICE", "type": "DOUBLE"}, {"name": "FIRSTHIGHPRICE", "type": "DOUBLE"}, {"name": "FIRSTLOWPRICE", "type": "DOUBLE"}, {"name": "FIRSTTURNOVER", "type": "DOUBLE"}, {"name": "APPLYCODEONLINE", "type": "STRING"}, {"name": "SHARESONLINE", "type": "DOUBLE"}, {"name": "APPLYUNITONLINE", "type": "DOUBLE"}, {"name": "APPLYMAXONLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYVOLONLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYNUMONLINE", "type": "DOUBLE"}, {"name": "OVERSUBSTIMESONLINE", "type": "DOUBLE"}, {"name": "NUMALLOTEDONLINE", "type": "DOUBLE"}, {"name": "FREEZEDMONEYONLINE", "type": "DOUBLE"}, {"name": "LOTRATEONLINE", "type": "DOUBLE"}, {"name": "APPLYCODESM", "type": "DOUBLE"}, {"name": "APPLYMAXSM", "type": "DOUBLE"}, {"name": "PLACINGSHARESSM", "type": "DOUBLE"}, {"name": "APPLYUNITSM", "type": "DOUBLE"}, {"name": "VALIDAPPLYVOLSM", "type": "DOUBLE"}, {"name": "VALIDAPPLYNUMSM", "type": "DOUBLE"}, {"name": "OVERSUBSTIMESSM", "type": "DOUBLE"}, {"name": "NUMALLOTEDSM", "type": "DOUBLE"}, {"name": "LOTRATESM", "type": "DOUBLE"}, {"name": "PLACINGSHARESLP", "type": "DOUBLE"}, {"name": "APPLYUNITLP", "type": "DOUBLE"}, {"name": "APPLYMAXLP", "type": "DOUBLE"}, {"name": "APPLYMINLP", "type": "DOUBLE"}, {"name": "VALIDAPPLYVOLLP", "type": "DOUBLE"}, {"name": "VALIDAPPLYNUMLP", "type": "DOUBLE"}, {"name": "OVERSUBSTIMESLP", "type": "DOUBLE"}, {"name": "APPLYMONEYLP", "type": "DOUBLE"}, {"name": "LOTRATELP", "type": "DOUBLE"}, {"name": "FUNDPREFALLOTMENT", "type": "DOUBLE"}, {"name": "SINGLEFUNDPREFALLOTMENT", "type": "DOUBLE"}, {"name": "FUNPREFALLOTMENTSHARES", "type": "DOUBLE"}, {"name": "FUNPREFALLOTMENTHOLDTERM", "type": "DOUBLE"}, {"name": "STAQNETALLOTMENT", "type": "DOUBLE"}, {"name": "STAQNETSUBSCRIPTION", "type": "DOUBLE"}, {"name": "STAFFALLOTMENT", "type": "DOUBLE"}, {"name": "EARNINGFORECASTYEAR", "type": "STRING"}, {"name": "MAININCOMEFORECAST", "type": "DOUBLE"}, {"name": "NETPROFITFORECAST", "type": "DOUBLE"}, {"name": "DILUTEDEPSFORECAST", "type": "DOUBLE"}, {"name": "DIVIDENDPOLICY", "type": "STRING"}, {"name": "ESTIMATEDFIRSTDIVIDATE", "type": "STRING"}, {"name": "UNDERWRITINGMODE", "type": "DOUBLE"}, {"name": "UNDERWRITERBOUGHTVOL", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "PERATIOBEFOREISSUE", "type": "DOUBLE"}, {"name": "PERATIOAFTERISSUE", "type": "DOUBLE"}, {"name": "BIDDERNUMBERLP", "type": "DOUBLE"}, {"name": "PLACINGNUMBERLP", "type": "DOUBLE"}, {"name": "APPLYVOLLP", "type": "DOUBLE"}, {"name": "TAILOREDPLAVOLLP", "type": "DOUBLE"}, {"name": "ONLINEISSUEPLAN", "type": "DOUBLE"}, {"name": "OFFLINEAPPLYPLAN", "type": "DOUBLE"}, {"name": "STRATEGYAPPLYPLAN", "type": "DOUBLE"}, {"name": "REFUNDMENTDATE_OFFLINE", "type": "STRING"}, {"name": "REFUNDMENTDATE_ONLINE", "type": "STRING"}, {"name": "ISSUENAMEABBR_ONLINE", "type": "STRING"}, {"name": "APPLYFLOOR_ONLINE", "type": "DOUBLE"}, {"name": "LOACCUAPPLYCEILING", "type": "DOUBLE"}, {"name": "OFFLINELOCKPERIOD", "type": "DOUBLE"}, {"name": "OVERSUBSUM", "type": "DOUBLE"}, {"name": "EXGSOPTIONPUBLDATE", "type": "STRING"}, {"name": "EXGSOPTIONENDDATE", "type": "STRING"}, {"name": "SLBUYSUM", "type": "DOUBLE"}, {"name": "EXGSOPTIONOVERSUBSUM", "type": "DOUBLE"}, {"name": "NAPSBEFOREISSUE", "type": "DOUBLE"}, {"name": "NAPSAFTERISSUE", "type": "DOUBLE"}, {"name": "ISSUERESULTPUBLDATE", "type": "STRING"}, {"name": "NORMALLEGALPERSONSHARELD", "type": "STRING"}, {"name": "STRATEGICINVESTORSHARELD", "type": "STRING"}, {"name": "LEADUNDERWRITER", "type": "STRING"}, {"name": "COLEADUNDERWRITER", "type": "STRING"}, {"name": "LISTINGSPONSOR", "type": "STRING"}, {"name": "DISTRIBUTOR", "type": "STRING"}, {"name": "INTERNATIONALCOORDINATOR", "type": "STRING"}, {"name": "NORMALLEGALPERSONSHARE", "type": "DOUBLE"}, {"name": "STRATEGICINVESTORSHARE", "type": "DOUBLE"}, {"name": "OTHERPLACINGSHARE", "type": "DOUBLE"}, {"name": "PLACINGSHAREPROPORTION", "type": "DOUBLE"}, {"name": "TOTALSHARESLISTDATE", "type": "DOUBLE"}, {"name": "TOTALSHARESBEFOREISSUE", "type": "DOUBLE"}, {"name": "FIRSTAVGPRICE", "type": "DOUBLE"}, {"name": "FIRSTTURNOVERVOLUME", "type": "DOUBLE"}, {"name": "FIRSTTURNOVERVALUE", "type": "DOUBLE"}, {"name": "FIRSTCHANGEPCT", "type": "DOUBLE"}, {"name": "SECUCODE", "type": "STRING"}, {"name": "PLANNEDPROCEEDS", "type": "DOUBLE"}, {"name": "PRICENUMBERPI", "type": "DOUBLE"}, {"name": "MINPROGRESSIVEPRICEPI", "type": "DOUBLE"}, {"name": "MINAPPLYINGPRICEPI", "type": "DOUBLE"}, {"name": "PRICENUMBERBB", "type": "DOUBLE"}, {"name": "MINPROGRESSIVEPRICEBB", "type": "DOUBLE"}, {"name": "MAXAPPLYINGRATIOBB", "type": "DOUBLE"}, {"name": "SECURITYABBR", "type": "STRING"}, {"name": "ISSUEPROCESSCODE", "type": "DOUBLE"}, {"name": "TIMESBB", "type": "DOUBLE"}, {"name": "ORIGINALVOLCEILING", "type": "DOUBLE"}, {"name": "ORIGINALVOL", "type": "DOUBLE"}, {"name": "OLBEFPUTBACK", "type": "DOUBLE"}, {"name": "OFFLBEFPUTBACK", "type": "DOUBLE"}, {"name": "PAYDATEONLINE", "type": "STRING"}, {"name": "PAYDATEOFFLINE", "type": "STRING"}, {"name": "ISSUEPUBLDATE", "type": "STRING"}, {"name": "RESULTPULBDATE", "type": "STRING"}, {"name": "SUBSSHAREOL", "type": "DOUBLE"}, {"name": "SUBSMONEYOL", "type": "DOUBLE"}, {"name": "ABANDONSUBSSOL", "type": "DOUBLE"}, {"name": "ABANDONSUBSMOL", "type": "DOUBLE"}, {"name": "UNDERWRITSOL", "type": "DOUBLE"}, {"name": "UNDERWRITMOL", "type": "DOUBLE"}, {"name": "UNDERWRITPOL", "type": "DOUBLE"}, {"name": "SUBSSHAREFL", "type": "DOUBLE"}, {"name": "SUBSMONEYFL", "type": "DOUBLE"}, {"name": "ABANDONSUBSSFL", "type": "DOUBLE"}, {"name": "ABANDONSUBSMFL", "type": "DOUBLE"}, {"name": "UNDERWRITSFL", "type": "DOUBLE"}, {"name": "UNDERWRITMFL", "type": "DOUBLE"}, {"name": "UNDERWRITPFL", "type": "DOUBLE"}, {"name": "MARKVALUEFLOOR", "type": "DOUBLE"}, {"name": "MARKVALUESTATMT", "type": "STRING"}, {"name": "LOTNUMONLINE", "type": "STRING"}, {"name": "ESTIISSUEPRICE", "type": "DOUBLE"}, {"name": "ESTIAPMAXONLINE", "type": "DOUBLE"}, {"name": "ALOTRATELP", "type": "DOUBLE"}, {"name": "BLOTRATELP", "type": "DOUBLE"}, {"name": "CLOTRATELP", "type": "DOUBLE"}, {"name": "ESTIPERATIO", "type": "DOUBLE"}, {"name": "FUNDMARKVALUEFLOOR", "type": "DOUBLE"}, {"name": "OTHERMARKVALUEFLOOR", "type": "DOUBLE"}, {"name": "MAXAPPLYINGPRICEPI", "type": "DOUBLE"}, {"name": "QUOTEMEDIAN", "type": "DOUBLE"}, {"name": "WEIGHTEDQUOTATION", "type": "DOUBLE"}, {"name": "FUNDQUOTEMEDIAN", "type": "DOUBLE"}, {"name": "FUNDWEIGHTEDQUOTATION", "type": "DOUBLE"}, {"name": "EXHIGHPRICEMEDIAN", "type": "DOUBLE"}, {"name": "EXHIGHPRICEWQ", "type": "DOUBLE"}, {"name": "EXHIGHPRICEFUNDMEDIAN", "type": "DOUBLE"}, {"name": "EXHIGHPRICEFUNDWQ", "type": "DOUBLE"}, {"name": "PERBEFOREISSUENCUTNP", "type": "DOUBLE"}, {"name": "PERBEFOREISSUECUTNP", "type": "DOUBLE"}, {"name": "PERAFTERISSUENCUTNP", "type": "DOUBLE"}, {"name": "PERAFTERISSUECUTNP", "type": "DOUBLE"}, {"name": "INITIALINVESTORNUM", "type": "DOUBLE"}, {"name": "INITIALAPPLYVOL", "type": "DOUBLE"}, {"name": "CONFORMINVESTORNUM", "type": "DOUBLE"}, {"name": "CONFORMBIDDERNUM", "type": "DOUBLE"}, {"name": "CONFORMAPPLYVOL", "type": "DOUBLE"}, {"name": "VALIDQUOTEINVESTORNUM", "type": "DOUBLE"}, {"name": "VALIDAPPLYINVESTORNUM", "type": "DOUBLE"}, {"name": "EXABANDONAPPLYNUMLP", "type": "DOUBLE"}, {"name": "EXABANDONAPPLYVOLLP", "type": "DOUBLE"}, {"name": "OFFLINELOCKARRANGE", "type": "DOUBLE"}, {"name": "AVERAGESTATICPE", "type": "DOUBLE"}, {"name": "PEEFFECTIVEDATE", "type": "STRING"}, {"name": "LISTSTANDARD", "type": "DOUBLE"}, {"name": "EXABOVEPRICE", "type": "DOUBLE"}, {"name": "APPLYPERATIO", "type": "DOUBLE"}, {"name": "UNDERWRITAOL", "type": "DOUBLE"}, {"name": "PARVALUECURRENCYUNIT", "type": "DOUBLE"}, {"name": "CEFUNDMARKVALUEFLOOR", "type": "DOUBLE"}, {"name": "PLANNEDNETPROCEEDS", "type": "DOUBLE"}, {"name": "CORESTAFFSSHAREPLAN", "type": "DOUBLE"}, {"name": "CORESTAFFSRATIOPLAN", "type": "DOUBLE"}, {"name": "SPONSORSHAREPLAN", "type": "DOUBLE"}, {"name": "SPONSORRATIOPLAN", "type": "DOUBLE"}, {"name": "OTHERSTRASHVOL", "type": "DOUBLE"}, {"name": "OTHERSTRASHRAT", "type": "DOUBLE"}, {"name": "CORESTAFFSSHARE", "type": "DOUBLE"}, {"name": "SPONSORSHARE", "type": "DOUBLE"}, {"name": "OTHERSHARE", "type": "DOUBLE"}, {"name": "APLACINGSHARESLP", "type": "DOUBLE"}, {"name": "BPLACINGSHARESLP", "type": "DOUBLE"}, {"name": "CPLACINGSHARESLP", "type": "DOUBLE"}, {"name": "AVALIDAPPLYVOLLP", "type": "DOUBLE"}, {"name": "BVALIDAPPLYVOLLP", "type": "DOUBLE"}, {"name": "CVALIDAPPLYVOLLP", "type": "DOUBLE"}, {"name": "ONLINEISSUEEXOVER", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "PLANNEDPROCEEDSEXGS", "type": "DOUBLE"}, {"name": "PLANNEDNPROCEEDSEXGS", "type": "DOUBLE"}, {"name": "OLBEFPUTBACKEXGS", "type": "DOUBLE"}, {"name": "PLACINGNUMBERONLINE", "type": "DOUBLE"}, {"name": "PLACINGSHARESONLINE", "type": "DOUBLE"}, {"name": "PLACINGRATEONLINE", "type": "DOUBLE"}, {"name": "GSBUYMAXPRICESM", "type": "DOUBLE"}, {"name": "GSBUYMINPRICESM", "type": "DOUBLE"}, {"name": "GSBUYAVGPRICESM", "type": "DOUBLE"}, {"name": "GSTOTALCONSIDERATIONSM", "type": "DOUBLE"}, {"name": "GSMONEYTOACCOUNT", "type": "DOUBLE"}, {"name": "GSDATETOACCOUNT", "type": "STRING"}, {"name": "ISSUEVOLEXGS", "type": "DOUBLE"}, {"name": "TOTALISSUEMVEXGS", "type": "DOUBLE"}, {"name": "DILUTEDPERATIOFEXGS", "type": "DOUBLE"}, {"name": "PERAISSUENCUTNPFEXGS", "type": "DOUBLE"}, {"name": "PERAISSUECUTNPFEXGS", "type": "DOUBLE"}, {"name": "PBRATIOBEFOREISSUE", "type": "DOUBLE"}, {"name": "PBRATIOAFTERISSUE", "type": "DOUBLE"}, {"name": "PBRATIOAFTERISSUEFEXGS", "type": "DOUBLE"}, {"name": "NAPSAFTERISSUEFEXGS", "type": "DOUBLE"}, {"name": "LATESTINFOPUBLDATE", "type": "STRING"}, {"name": "PROPOSEDLISTDATE", "type": "STRING"}, {"name": "MVAPPLYREGDATEONLINE", "type": "STRING"}, {"name": "MVCALREFDAYONLINE", "type": "STRING"}, {"name": "DATASUBMITENDDATEOFFLINE", "type": "STRING"}, {"name": "DATASUBMITENDTIMEOFFLINE", "type": "STRING"}, {"name": "EXABANDONOVERSUBSTLP", "type": "DOUBLE"}, {"name": "EXABANDONLOTRATELP", "type": "DOUBLE"}, {"name": "CALLBACKVOL", "type": "DOUBLE"}, {"name": "CALLBACKRATIO", "type": "DOUBLE"}, {"name": "CALLBACKDIRECTION", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_ashareipo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_ashareipo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_ashareipo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_ashareipo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_ASHAREIPO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_ASHAREIPO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_ashareipo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHAREIPO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INITIALINFOPUBLDATE
     , INTENTLETTERPUBLDATE
     , INTENTLETTERSIGNDATE
     , PROSPECTUSPUBLDATE
     , PROSPECTUSSIGNDATE
     , LISTANNOUNCEMENTDATE
     , RAISINGMETHOD
     , STOCKTYPE
     , ISSUEPRICECEILING
     , ISSUEPRICEFLOOR
     , ISSUEVOLCEILING
     , ISSUEVOLFLOOR
     , OVERALLOTMENTOPTION
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
     , IPOPROCEEDS
     , IPONETPROCEEDS
     , STATESHARESPROCEEDS
     , STATESHARESNETPROCEEDS
     , MONEYTOACCOUNT
     , DATETOACCOUNT
     , PRICINGMODEL
     , RATIONMODEL
     , ISSUEMETHOD
     , ISSUEOBJECT
     , ISSUESTARTDATE
     , ISSUEENDDATE
     , ONLINESTARTDATE
     , ONLINEENDDATE
     , BOOKINGSTARTDATELP
     , BOOKINGENDDATELP
     , PAYSTARTDATELP
     , PAYENDDATELP
     , APPLYSTARTDATEF
     , APPLYENDDATEF
     , PAYSTARTDATEF
     , PAYENDDATEF
     , SECMARKETPLACINGDATE
     , PAYSTARTDATESM
     , PAYENDDATESM
     , UNDERWRITINGSIGNDATE
     , UNDERWRITINGSTARTDATE
     , UNDERWRITINGENDDATE
     , PREPAREDLISTEXCHANGE
     , LISTDATE
     , STAFFSHARESLISTDATE
     , STAFFSHARESLISTTERM
     , OUTSTANDINGSHARES
     , NUMOVER1000SHARES
     , FIRSTOPENPRICE
     , FIRSTCLOSEPRICE
     , FIRSTHIGHPRICE
     , FIRSTLOWPRICE
     , FIRSTTURNOVER
     , APPLYCODEONLINE
     , SHARESONLINE
     , APPLYUNITONLINE
     , APPLYMAXONLINE
     , VALIDAPPLYVOLONLINE
     , VALIDAPPLYNUMONLINE
     , OVERSUBSTIMESONLINE
     , NUMALLOTEDONLINE
     , FREEZEDMONEYONLINE
     , LOTRATEONLINE
     , APPLYCODESM
     , APPLYMAXSM
     , PLACINGSHARESSM
     , APPLYUNITSM
     , VALIDAPPLYVOLSM
     , VALIDAPPLYNUMSM
     , OVERSUBSTIMESSM
     , NUMALLOTEDSM
     , LOTRATESM
     , PLACINGSHARESLP
     , APPLYUNITLP
     , APPLYMAXLP
     , APPLYMINLP
     , VALIDAPPLYVOLLP
     , VALIDAPPLYNUMLP
     , OVERSUBSTIMESLP
     , APPLYMONEYLP
     , LOTRATELP
     , FUNDPREFALLOTMENT
     , SINGLEFUNDPREFALLOTMENT
     , FUNPREFALLOTMENTSHARES
     , FUNPREFALLOTMENTHOLDTERM
     , STAQNETALLOTMENT
     , STAQNETSUBSCRIPTION
     , STAFFALLOTMENT
     , EARNINGFORECASTYEAR
     , MAININCOMEFORECAST
     , NETPROFITFORECAST
     , DILUTEDEPSFORECAST
     , DIVIDENDPOLICY
     , ESTIMATEDFIRSTDIVIDATE
     , UNDERWRITINGMODE
     , UNDERWRITERBOUGHTVOL
     , XGRQ
     , JSID
     , PERATIOBEFOREISSUE
     , PERATIOAFTERISSUE
     , BIDDERNUMBERLP
     , PLACINGNUMBERLP
     , APPLYVOLLP
     , TAILOREDPLAVOLLP
     , ONLINEISSUEPLAN
     , OFFLINEAPPLYPLAN
     , STRATEGYAPPLYPLAN
     , REFUNDMENTDATE_OFFLINE
     , REFUNDMENTDATE_ONLINE
     , ISSUENAMEABBR_ONLINE
     , APPLYFLOOR_ONLINE
     , LOACCUAPPLYCEILING
     , OFFLINELOCKPERIOD
     , OVERSUBSUM
     , EXGSOPTIONPUBLDATE
     , EXGSOPTIONENDDATE
     , SLBUYSUM
     , EXGSOPTIONOVERSUBSUM
     , NAPSBEFOREISSUE
     , NAPSAFTERISSUE
     , ISSUERESULTPUBLDATE
     , NORMALLEGALPERSONSHARELD
     , STRATEGICINVESTORSHARELD
     , LEADUNDERWRITER
     , COLEADUNDERWRITER
     , LISTINGSPONSOR
     , DISTRIBUTOR
     , INTERNATIONALCOORDINATOR
     , NORMALLEGALPERSONSHARE
     , STRATEGICINVESTORSHARE
     , OTHERPLACINGSHARE
     , PLACINGSHAREPROPORTION
     , TOTALSHARESLISTDATE
     , TOTALSHARESBEFOREISSUE
     , FIRSTAVGPRICE
     , FIRSTTURNOVERVOLUME
     , FIRSTTURNOVERVALUE
     , FIRSTCHANGEPCT
     , SECUCODE
     , PLANNEDPROCEEDS
     , PRICENUMBERPI
     , MINPROGRESSIVEPRICEPI
     , MINAPPLYINGPRICEPI
     , PRICENUMBERBB
     , MINPROGRESSIVEPRICEBB
     , MAXAPPLYINGRATIOBB
     , SECURITYABBR
     , ISSUEPROCESSCODE
     , TIMESBB
     , ORIGINALVOLCEILING
     , ORIGINALVOL
     , OLBEFPUTBACK
     , OFFLBEFPUTBACK
     , PAYDATEONLINE
     , PAYDATEOFFLINE
     , ISSUEPUBLDATE
     , RESULTPULBDATE
     , SUBSSHAREOL
     , SUBSMONEYOL
     , ABANDONSUBSSOL
     , ABANDONSUBSMOL
     , UNDERWRITSOL
     , UNDERWRITMOL
     , UNDERWRITPOL
     , SUBSSHAREFL
     , SUBSMONEYFL
     , ABANDONSUBSSFL
     , ABANDONSUBSMFL
     , UNDERWRITSFL
     , UNDERWRITMFL
     , UNDERWRITPFL
     , MARKVALUEFLOOR
     , MARKVALUESTATMT
     , LOTNUMONLINE
     , ESTIISSUEPRICE
     , ESTIAPMAXONLINE
     , ALOTRATELP
     , BLOTRATELP
     , CLOTRATELP
     , ESTIPERATIO
     , FUNDMARKVALUEFLOOR
     , OTHERMARKVALUEFLOOR
     , MAXAPPLYINGPRICEPI
     , QUOTEMEDIAN
     , WEIGHTEDQUOTATION
     , FUNDQUOTEMEDIAN
     , FUNDWEIGHTEDQUOTATION
     , EXHIGHPRICEMEDIAN
     , EXHIGHPRICEWQ
     , EXHIGHPRICEFUNDMEDIAN
     , EXHIGHPRICEFUNDWQ
     , PERBEFOREISSUENCUTNP
     , PERBEFOREISSUECUTNP
     , PERAFTERISSUENCUTNP
     , PERAFTERISSUECUTNP
     , INITIALINVESTORNUM
     , INITIALAPPLYVOL
     , CONFORMINVESTORNUM
     , CONFORMBIDDERNUM
     , CONFORMAPPLYVOL
     , VALIDQUOTEINVESTORNUM
     , VALIDAPPLYINVESTORNUM
     , EXABANDONAPPLYNUMLP
     , EXABANDONAPPLYVOLLP
     , OFFLINELOCKARRANGE
     , AVERAGESTATICPE
     , PEEFFECTIVEDATE
     , LISTSTANDARD
     , EXABOVEPRICE
     , APPLYPERATIO
     , UNDERWRITAOL
     , PARVALUECURRENCYUNIT
     , CEFUNDMARKVALUEFLOOR
     , PLANNEDNETPROCEEDS
     , CORESTAFFSSHAREPLAN
     , CORESTAFFSRATIOPLAN
     , SPONSORSHAREPLAN
     , SPONSORRATIOPLAN
     , OTHERSTRASHVOL
     , OTHERSTRASHRAT
     , CORESTAFFSSHARE
     , SPONSORSHARE
     , OTHERSHARE
     , APLACINGSHARESLP
     , BPLACINGSHARESLP
     , CPLACINGSHARESLP
     , AVALIDAPPLYVOLLP
     , BVALIDAPPLYVOLLP
     , CVALIDAPPLYVOLLP
     , ONLINEISSUEEXOVER
     , INSERTTIME
     , PLANNEDPROCEEDSEXGS
     , PLANNEDNPROCEEDSEXGS
     , OLBEFPUTBACKEXGS
     , PLACINGNUMBERONLINE
     , PLACINGSHARESONLINE
     , PLACINGRATEONLINE
     , GSBUYMAXPRICESM
     , GSBUYMINPRICESM
     , GSBUYAVGPRICESM
     , GSTOTALCONSIDERATIONSM
     , GSMONEYTOACCOUNT
     , GSDATETOACCOUNT
     , ISSUEVOLEXGS
     , TOTALISSUEMVEXGS
     , DILUTEDPERATIOFEXGS
     , PERAISSUENCUTNPFEXGS
     , PERAISSUECUTNPFEXGS
     , PBRATIOBEFOREISSUE
     , PBRATIOAFTERISSUE
     , PBRATIOAFTERISSUEFEXGS
     , NAPSAFTERISSUEFEXGS
     , LATESTINFOPUBLDATE
     , PROPOSEDLISTDATE
     , MVAPPLYREGDATEONLINE
     , MVCALREFDAYONLINE
     , DATASUBMITENDDATEOFFLINE
     , DATASUBMITENDTIMEOFFLINE
     , EXABANDONOVERSUBSTLP
     , EXABANDONLOTRATELP
     , CALLBACKVOL
     , CALLBACKRATIO
     , CALLBACKDIRECTION
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_ASHAREIPO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHAREIPO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_ASHAREIPO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_ASHAREIPO_PFD成功"
      exit 0
   fi
fi
