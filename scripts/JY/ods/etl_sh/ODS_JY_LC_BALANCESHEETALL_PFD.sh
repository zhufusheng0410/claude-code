#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_BALANCESHEETALL_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_BALANCESHEETALL_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  BULLETINTYPE  DECIMAL(10,0)  COMMENT  '公告类别',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  ENDDATE  STRING  COMMENT  '日期',
  IFADJUSTED  DECIMAL(10,0)  COMMENT  '是否调整',
  IFMERGED  STRING  COMMENT  '合并标志',
  ACCOUNTINGSTANDARDS  DECIMAL(10,0)  COMMENT  '会计准则',
  ENTERPRISETYPE  STRING  COMMENT  '工业企业类型',
  CASHEQUIVALENTS  DECIMAL(19,4)  COMMENT  '货币资金/现金及存放中央银行款项(元)',
  CLIENTDEPOSIT  DECIMAL(19,4)  COMMENT  '其中:客户资金存款(元)',
  TRADINGASSETS  DECIMAL(19,4)  COMMENT  '交易性金融资产(元)',
  BILLRECEIVABLE  DECIMAL(19,4)  COMMENT  '应收票据(元)',
  DIVIDENDRECEIVABLE  DECIMAL(19,4)  COMMENT  '应收股利(元)',
  INTERESTRECEIVABLE  DECIMAL(19,4)  COMMENT  '应收利息(元)',
  ACCOUNTRECEIVABLE  DECIMAL(19,4)  COMMENT  '应收账款(元)',
  OTHERRECEIVABLE  DECIMAL(19,4)  COMMENT  '其他应收款(元)',
  ADVANCEPAYMENT  DECIMAL(19,4)  COMMENT  '预付款项(元)',
  INVENTORIES  DECIMAL(19,4)  COMMENT  '存货(元)',
  BEARERBIOLOGICALASSETS  DECIMAL(19,4)  COMMENT  '其中:消耗性生物资产',
  DEFERREDEXPENSE  DECIMAL(19,4)  COMMENT  '待摊费用(元)',
  NONCURRENTASSETIN1YEAR  DECIMAL(19,4)  COMMENT  '一年内到期的非流动资产',
  OTHERCURRENTASSETS  DECIMAL(19,4)  COMMENT  '其他流动资产',
  CAEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##流动资产特殊项目',
  CAADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##流动资产调整项目',
  TOTALCURRENTASSETS  DECIMAL(19,4)  COMMENT  '流动资产合计',
  HOLDFORSALEASSETS  DECIMAL(19,4)  COMMENT  '可供出售金融资产',
  HOLDTOMATURITYINVESTMENTS  DECIMAL(19,4)  COMMENT  '持有至到期投资',
  INVESTMENTPROPERTY  DECIMAL(19,4)  COMMENT  '投资性房地产',
  LONGTERMEQUITYINVEST  DECIMAL(19,4)  COMMENT  '长期股权投资(元)',
  LONGTERMRECEIVABLEACCOUNT  DECIMAL(19,4)  COMMENT  '长期应收款',
  FIXEDASSETS  DECIMAL(19,4)  COMMENT  '固定资产(元)',
  CONSTRUCTIONMATERIALS  DECIMAL(19,4)  COMMENT  '工程物资(元)',
  CONSTRUINPROCESS  DECIMAL(19,4)  COMMENT  '在建工程(元)',
  FIXEDASSETSLIQUIDATION  DECIMAL(19,4)  COMMENT  '固定资产清理(元)',
  BIOLOGICALASSETS  DECIMAL(19,4)  COMMENT  '生产性生物资产',
  OILGASASSETS  DECIMAL(19,4)  COMMENT  '油气资产(元)',
  INTANGIBLEASSETS  DECIMAL(19,4)  COMMENT  '无形资产(元)',
  SEATCOSTS  DECIMAL(19,4)  COMMENT  '其中:交易席位费(元)',
  DEVELOPMENTEXPENDITURE  DECIMAL(19,4)  COMMENT  '开发支出',
  GOODWILL  DECIMAL(19,4)  COMMENT  '商誉(元)',
  LONGDEFERREDEXPENSE  DECIMAL(19,4)  COMMENT  '长期待摊费用(元)',
  DEFERREDTAXASSETS  DECIMAL(19,4)  COMMENT  '递延所得税资产',
  OTHERNONCURRENTASSETS  DECIMAL(19,4)  COMMENT  '其他非流动资产',
  NCAEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##非流动资产特殊项目',
  NCAADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##非流动资产调整项目',
  TOTALNONCURRENTASSETS  DECIMAL(19,4)  COMMENT  '非流动资产合计',
  LOANANDACCOUNTRECEIVABLES  DECIMAL(19,4)  COMMENT  '投资-贷款及应收款项(应收款项类投资)',
  SETTLEMENTPROVI  DECIMAL(19,4)  COMMENT  '结算备付金(元)',
  CLIENTPROVI  DECIMAL(19,4)  COMMENT  '其中:客户备付金(元)',
  DEPOSITININTERBANK  DECIMAL(19,4)  COMMENT  '存放同业(元)',
  RMETAL  DECIMAL(19,4)  COMMENT  '贵金属(元)',
  LENDCAPITAL  DECIMAL(19,4)  COMMENT  '拆出资金(元)',
  DERIVATIVEASSETS  DECIMAL(19,4)  COMMENT  '衍生金融资产',
  BOUGHTSELLBACKASSETS  DECIMAL(19,4)  COMMENT  '买入返售金融资产',
  LOANANDADVANCE  DECIMAL(19,4)  COMMENT  '发放贷款和垫款(元)',
  INSURANCERECEIVABLES  DECIMAL(19,4)  COMMENT  '应收保费',
  RECEIVABLESUBROGATIONFEE  DECIMAL(19,4)  COMMENT  '应收代位追偿款',
  REINSURANCERECEIVABLES  DECIMAL(19,4)  COMMENT  '应收分保账款',
  RECEIVABLEUNEARNEDR  DECIMAL(19,4)  COMMENT  '应收分保未到期责任准备金',
  RECEIVABLECLAIMSR  DECIMAL(19,4)  COMMENT  '应收分保未决赔款准备金',
  RECEIVABLELIFER  DECIMAL(19,4)  COMMENT  '应收分保寿险责任准备金(元)',
  RECEIVABLELTHEALTHR  DECIMAL(19,4)  COMMENT  '应收分保长期健康险责任准备金',
  INSURERIMPAWNLOAN  DECIMAL(19,4)  COMMENT  '保户质押贷款',
  FIXEDDEPOSIT  DECIMAL(19,4)  COMMENT  '定期存款(元)',
  REFUNDABLEDEPOSIT  DECIMAL(19,4)  COMMENT  '存出保证金',
  REFUNDABLECAPITALDEPOSIT  DECIMAL(19,4)  COMMENT  '存出资本保证金',
  INDEPENDENCEACCOUNTASSETS  DECIMAL(19,4)  COMMENT  '独立账户资产',
  OTHERASSETS  DECIMAL(19,4)  COMMENT  '其他资产(元)',
  AEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##资产特殊项目',
  AADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##资产调整项目',
  TOTALASSETS  DECIMAL(19,4)  COMMENT  '资产总计(元)',
  SHORTTERMLOAN  DECIMAL(19,4)  COMMENT  '短期借款(元)',
  IMPAWNEDLOAN  DECIMAL(19,4)  COMMENT  '其中:质押借款(元)',
  TRADINGLIABILITY  DECIMAL(19,4)  COMMENT  '交易性金融负债',
  NOTESPAYABLE  DECIMAL(19,4)  COMMENT  '应付票据(元)',
  ACCOUNTSPAYABLE  DECIMAL(19,4)  COMMENT  '应付账款(元)',
  STBONDSPAYABLE  DECIMAL(19,4)  COMMENT  '应付短期债券(元)',
  ADVANCERECEIPTS  DECIMAL(19,4)  COMMENT  '预收款项(元)',
  SALARIESPAYABLE  DECIMAL(19,4)  COMMENT  '应付职工薪酬(元)',
  DIVIDENDPAYABLE  DECIMAL(19,4)  COMMENT  '应付股利(元)',
  TAXSPAYABLE  DECIMAL(19,4)  COMMENT  '应交税费(元)',
  INTERESTPAYABLE  DECIMAL(19,4)  COMMENT  '应付利息(元)',
  OTHERPAYABLE  DECIMAL(19,4)  COMMENT  '其他应付款(元)',
  ACCRUEDEXPENSE  DECIMAL(19,4)  COMMENT  '预提费用(元)',
  DEFERREDPROCEEDS  DECIMAL(19,4)  COMMENT  '递延收益',
  NONCURRENTLIABILITYIN1YEAR  DECIMAL(19,4)  COMMENT  '一年内到期的非流动负债',
  OTHERCURRENTLIABILITY  DECIMAL(19,4)  COMMENT  '其他流动负债(元)',
  CLEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##流动负债特殊项目',
  CLADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##流动负债调整项目',
  TOTALCURRENTLIABILITY  DECIMAL(19,4)  COMMENT  '流动负债合计(元)',
  LONGTERMLOAN  DECIMAL(19,4)  COMMENT  '长期借款(元)',
  BONDSPAYABLE  DECIMAL(19,4)  COMMENT  '应付债券(元)',
  LONGTERMACCOUNTPAYABLE  DECIMAL(19,4)  COMMENT  '长期应付款(元)',
  SPECIFICACCOUNTPAYABLE  DECIMAL(19,4)  COMMENT  '专项应付款(元)',
  ESTIMATELIABILITY  DECIMAL(19,4)  COMMENT  '预计负债(元)',
  DEFERREDTAXLIABILITY  DECIMAL(19,4)  COMMENT  '递延所得税负债',
  OTHERNONCURRENTLIABILITY  DECIMAL(19,4)  COMMENT  '其他非流动负债',
  NCLEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##非流动负债特殊项目',
  NCLADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##非流动负债调整项目',
  TOTALNONCURRENTLIABILITY  DECIMAL(19,4)  COMMENT  '非流动负债合计',
  BORROWINGFROMCENTRALBANK  DECIMAL(19,4)  COMMENT  '向中央银行借款',
  DEPOSITOFINTERBANK  DECIMAL(19,4)  COMMENT  '同业及其他金融机构存放款项',
  BORROWINGCAPITAL  DECIMAL(19,4)  COMMENT  '拆入资金(元)',
  DERIVATIVELIABILITY  DECIMAL(19,4)  COMMENT  '衍生金融负债',
  SOLDBUYBACKSECUPROCEEDS  DECIMAL(19,4)  COMMENT  '卖出回购证券款(元)',
  DEPOSIT  DECIMAL(19,4)  COMMENT  '吸收存款(元)',
  PROXYSECUPROCEEDS  DECIMAL(19,4)  COMMENT  '代理买卖证券款',
  SUBISSUESECUPROCEEDS  DECIMAL(19,4)  COMMENT  '代发行证券款(元)',
  DEPOSITSRECEIVED  DECIMAL(19,4)  COMMENT  '存入保证金',
  ADVANCEINSURANCE  DECIMAL(19,4)  COMMENT  '预收保费',
  COMMISSIONPAYABLE  DECIMAL(19,4)  COMMENT  '应付手续费及佣金',
  REINSURANCEPAYABLES  DECIMAL(19,4)  COMMENT  '应付分保账款',
  COMPENSATIONPAYABLE  DECIMAL(19,4)  COMMENT  '应付赔付款',
  POLICYDIVIDENDPAYABLE  DECIMAL(19,4)  COMMENT  '应付保单红利',
  INSURERDEPOSITINVESTMENT  DECIMAL(19,4)  COMMENT  '保户储金及投资款',
  UNEARNEDPREMIUMRESERVE  DECIMAL(19,4)  COMMENT  '未到期责任准备金',
  OUTSTANDINGCLAIMRESERVE  DECIMAL(19,4)  COMMENT  '未决赔款准备金',
  LIFEINSURANCERESERVE  DECIMAL(19,4)  COMMENT  '寿险责任准备金',
  LTHEALTHINSURANCELR  DECIMAL(19,4)  COMMENT  '长期健康险责任准备金',
  INDEPENDENCELIABILITY  DECIMAL(19,4)  COMMENT  '独立账户负债',
  OTHERLIABILITY  DECIMAL(19,4)  COMMENT  '其他负债(元)',
  LEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##负债特殊项目',
  LADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##负债调整项目',
  TOTALLIABILITY  DECIMAL(19,4)  COMMENT  '负债合计(元)',
  PAIDINCAPITAL  DECIMAL(19,4)  COMMENT  '实收资本(或股本)(元)',
  CAPITALRESERVEFUND  DECIMAL(19,4)  COMMENT  '资本公积(元)',
  SURPLUSRESERVEFUND  DECIMAL(19,4)  COMMENT  '盈余公积(元)',
  RETAINEDPROFIT  DECIMAL(19,4)  COMMENT  '未分配利润(元)',
  TREASURYSTOCK  DECIMAL(19,4)  COMMENT  '减:库存股(元)',
  ORDINARYRISKRESERVEFUND  DECIMAL(19,4)  COMMENT  '一般风险准备/信托赔偿准备金(元)',
  FOREIGNCURRENCYREPORTCONVDIFF  DECIMAL(19,4)  COMMENT  '外币报表折算差额/资本汇差调整(元)',
  UNCERTAINEDINVESTMENTLOSS  DECIMAL(19,4)  COMMENT  '未确认投资损失',
  OTHERRESERVES  DECIMAL(19,4)  COMMENT  '其他储备(公允价值变动储备)(元)',
  SPECIFICRESERVES  DECIMAL(19,4)  COMMENT  '专项储备',
  SEEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##所有者权益特殊项目',
  SEADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##所有者权益调整项目',
  SEWITHOUTMI  DECIMAL(19,4)  COMMENT  '归属于母公司所有者权益合计(元)',
  MINORITYINTERESTS  DECIMAL(19,4)  COMMENT  '少数股东权益(元)',
  OTHERITEMSEFFECTINGSE  DECIMAL(19,4)  COMMENT  '影响所有者权益的其他科目',
  TOTALSHAREHOLDEREQUITY  DECIMAL(19,4)  COMMENT  '股东权益合计(元)',
  LEEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##负债和权益特殊项目',
  LEADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##负债和权益调整项目',
  TOTALLIABILITYANDEQUITY  DECIMAL(19,4)  COMMENT  '负债及股东权益总计(元)',
  SPECIALFIELDREMARK  STRING  COMMENT  '特殊字段说明',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  IFCOMPLETE  STRING  COMMENT  '完整标志',
  LPREFERSTOCK  DECIMAL(19,4)  COMMENT  '其中:优先股(应付债券)(元)',
  LPERPETUALDEBT  DECIMAL(19,4)  COMMENT  '其中:永续债(应付债券)(元)',
  OTHEREQUITYINSTRUMENTS  DECIMAL(19,4)  COMMENT  '其他权益工具',
  EPREFERSTOCK  DECIMAL(19,4)  COMMENT  '其中:优先股(其他权益工具)(元)',
  EPERPETUALDEBT  DECIMAL(19,4)  COMMENT  '其中:永续债(其他权益工具)(元)',
  OTHERCOMPOSITEINCOME  DECIMAL(19,4)  COMMENT  '其他综合收益',
  HOLDANDFSASSETS  DECIMAL(19,4)  COMMENT  '划分为持有待售的资产(元)',
  HOLDANDFSLI  DECIMAL(19,4)  COMMENT  '划分为持有待售的负债(元)',
  LONGSALARIESPAY  DECIMAL(19,4)  COMMENT  '长期应付职工薪酬(元)',
  LONGDEFERINCOME  DECIMAL(19,4)  COMMENT  '长期递延收益(元)',
  BILLACCRECEIVABLE  DECIMAL(19,4)  COMMENT  '应收票据及应收账款',
  CONTRACTUALASSETS  DECIMAL(19,4)  COMMENT  '合同资产',
  DEBTINVESTMENT  DECIMAL(19,4)  COMMENT  '债权投资',
  OTHDEBTINVESTMENT  DECIMAL(19,4)  COMMENT  '其他债权投资',
  OTHEQUITYINSTRUMENT  DECIMAL(19,4)  COMMENT  '其他权益工具投资',
  OTHNONCURFINASSETS  DECIMAL(19,4)  COMMENT  '其他非流动金融资产',
  NOTACCOUNTSPAYABLE  DECIMAL(19,4)  COMMENT  '应付票据及应付账款',
  CONTRACTLIABILITY  DECIMAL(19,4)  COMMENT  '合同负债',
  TRADERISKRSRVFD  DECIMAL(19,4)  COMMENT  '交易风险准备',
  OTHERRECEIVABLEED  DECIMAL(19,4)  COMMENT  '其他应收款(含利息和股利)',
  OTHERPAYABLEED  DECIMAL(19,4)  COMMENT  '其他应付款(含利息和股利)',
  RECEIVABLESFIN  DECIMAL(19,4)  COMMENT  '应收款项融资',
  FINANCING  DECIMAL(19,4)  COMMENT  '融出资金',
  FINLEASERECEIVABLE  DECIMAL(19,4)  COMMENT  '应收融资租赁款',
  RESREIRECECONTRACTS  DECIMAL(19,4)  COMMENT  '应收分保合同准备金',
  USUFRUCTASSETS  DECIMAL(19,4)  COMMENT  '使用权资产',
  ABSINTERDEPOSITS  DECIMAL(19,4)  COMMENT  '吸收存款及同业存款',
  INSCONTRACTRESERVE  DECIMAL(19,4)  COMMENT  '保险合同准备金',
  LEASELIABILITIES  DECIMAL(19,4)  COMMENT  '租赁负债',
  FINLEASESPAYABLE  DECIMAL(19,4)  COMMENT  '应付融资租赁款',
  TOTALFIXEDASSET  DECIMAL(19,4)  COMMENT  '固定资产合计1',
  TCONSTRUINPROCESS  DECIMAL(19,4)  COMMENT  '在建工程合计',
  DEPOSITINASSOCIATE  DECIMAL(19,4)  COMMENT  '存放联行款项',
  DEBTASSETS  DECIMAL(19,4)  COMMENT  '抵债资产',
  DEBITOFASSOCIATE  DECIMAL(19,4)  COMMENT  '联行存放款项',
  INFOSOURCECODE  STRING  COMMENT  '信息来源编码',
  INSERTTIME  STRING  COMMENT  '添加列InsertTime',
  CASH  DECIMAL(19,4)  COMMENT  '其中:货币资金',
  DEPOSITINCENTRALBANK  DECIMAL(19,4)  COMMENT  '其中:现金及存放中央银行款项',
  AMONGTRADINGASSETS  DECIMAL(19,4)  COMMENT  '其中:交易性金融资产',
  AMONGFINAETATFVALTPL  DECIMAL(19,4)  COMMENT  '其中:以公允价值计量且其变动计入当期损益的金融资产',
  RECEIVABLES  DECIMAL(19,4)  COMMENT  '应收款项',
  CASHDEPOSITRECEIVE  DECIMAL(19,4)  COMMENT  '应收货币保证金',
  PLEDGDEPOSITRECEIVE  DECIMAL(19,4)  COMMENT  '应收质押保证金',
  SETTLEMENTRECEIVE  DECIMAL(19,4)  COMMENT  '应收结算担保金',
  RISKOFLOSSRECEIVE  DECIMAL(19,4)  COMMENT  '应收风险损失款',
  FEECOMMISSIONRECEIVE  DECIMAL(19,4)  COMMENT  '应收手续费及佣金',
  AMONGDEBTINVESTMENT  DECIMAL(19,4)  COMMENT  '其中:债权投资',
  AMONGFINAETATAMORCOST  DECIMAL(19,4)  COMMENT  '其中:以摊余成本计量的金融资产',
  AMONGOTHDEBTINVEST  DECIMAL(19,4)  COMMENT  '其中:其他债权投资',
  AMONGFINAETATFVALTOCI  DECIMAL(19,4)  COMMENT  '其中:以公允价值计量且其变动计入其他综合收益的金融投资',
  AMONGOTHEQUINSTRUMENT  DECIMAL(19,4)  COMMENT  '其中:其他权益工具投资',
  AMONGEQUINSATFVALTOCI  DECIMAL(19,4)  COMMENT  '其中:以公允价值计量且其变动计入其他综合收益的非交易性权益工具投',
  FUTUREMEMBERINVESTMENT  DECIMAL(19,4)  COMMENT  '期货会员资格投资',
  FINANCIALINVESTMENT  DECIMAL(19,4)  COMMENT  '金融投资',
  SHORTTERMBONDPAY  DECIMAL(19,4)  COMMENT  '应付短期融资款',
  AMONGTRADINGLIABILITY  DECIMAL(19,4)  COMMENT  '其中:交易性金融负债',
  AMONGFINLIAATFVALTPL  DECIMAL(19,4)  COMMENT  '其中:以公允价值计量且其变动计入当期损益的金融负债',
  PAYABLES  DECIMAL(19,4)  COMMENT  '应付款项1',
  CASHDEPOSITPAY  DECIMAL(19,4)  COMMENT  '应付货币保证金',
  PLEDGDEPOSITPAY  DECIMAL(19,4)  COMMENT  '应付质押保证金',
  FUTUREPROTECTFUNDPAY  DECIMAL(19,4)  COMMENT  '应付期货投资者保障基金',
  GUARANTCOMPENSATERSRV  DECIMAL(19,4)  COMMENT  '担保赔偿准备金',
  GUARANTEERESERVE  DECIMAL(19,4)  COMMENT  '担保业务准备金',
  FUTURERISKRESERVE  DECIMAL(19,4)  COMMENT  '期货风险准备金',
  LTINSCONTRACTRESERVE  DECIMAL(19,4)  COMMENT  '长期保险合同准备金',
  LTACCOUNTPAYABLETOTAL  DECIMAL(19,4)  COMMENT  '长期应付款合计'
)
COMMENT '资产负债表_新会计准则'
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
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , BULLETINTYPE
                                   , COMPANYCODE
                                   , ENDDATE
                                   , IFADJUSTED
                                   , IFMERGED
                                   , ACCOUNTINGSTANDARDS
                                   , ENTERPRISETYPE
                                   , CASHEQUIVALENTS
                                   , CLIENTDEPOSIT
                                   , TRADINGASSETS
                                   , BILLRECEIVABLE
                                   , DIVIDENDRECEIVABLE
                                   , INTERESTRECEIVABLE
                                   , ACCOUNTRECEIVABLE
                                   , OTHERRECEIVABLE
                                   , ADVANCEPAYMENT
                                   , INVENTORIES
                                   , BEARERBIOLOGICALASSETS
                                   , DEFERREDEXPENSE
                                   , NONCURRENTASSETIN1YEAR
                                   , OTHERCURRENTASSETS
                                   , CAEXCEPTIONALITEMS
                                   , CAADJUSTMENTITEMS
                                   , TOTALCURRENTASSETS
                                   , HOLDFORSALEASSETS
                                   , HOLDTOMATURITYINVESTMENTS
                                   , INVESTMENTPROPERTY
                                   , LONGTERMEQUITYINVEST
                                   , LONGTERMRECEIVABLEACCOUNT
                                   , FIXEDASSETS
                                   , CONSTRUCTIONMATERIALS
                                   , CONSTRUINPROCESS
                                   , FIXEDASSETSLIQUIDATION
                                   , BIOLOGICALASSETS
                                   , OILGASASSETS
                                   , INTANGIBLEASSETS
                                   , SEATCOSTS
                                   , DEVELOPMENTEXPENDITURE
                                   , GOODWILL
                                   , LONGDEFERREDEXPENSE
                                   , DEFERREDTAXASSETS
                                   , OTHERNONCURRENTASSETS
                                   , NCAEXCEPTIONALITEMS
                                   , NCAADJUSTMENTITEMS
                                   , TOTALNONCURRENTASSETS
                                   , LOANANDACCOUNTRECEIVABLES
                                   , SETTLEMENTPROVI
                                   , CLIENTPROVI
                                   , DEPOSITININTERBANK
                                   , RMETAL
                                   , LENDCAPITAL
                                   , DERIVATIVEASSETS
                                   , BOUGHTSELLBACKASSETS
                                   , LOANANDADVANCE
                                   , INSURANCERECEIVABLES
                                   , RECEIVABLESUBROGATIONFEE
                                   , REINSURANCERECEIVABLES
                                   , RECEIVABLEUNEARNEDR
                                   , RECEIVABLECLAIMSR
                                   , RECEIVABLELIFER
                                   , RECEIVABLELTHEALTHR
                                   , INSURERIMPAWNLOAN
                                   , FIXEDDEPOSIT
                                   , REFUNDABLEDEPOSIT
                                   , REFUNDABLECAPITALDEPOSIT
                                   , INDEPENDENCEACCOUNTASSETS
                                   , OTHERASSETS
                                   , AEXCEPTIONALITEMS
                                   , AADJUSTMENTITEMS
                                   , TOTALASSETS
                                   , SHORTTERMLOAN
                                   , IMPAWNEDLOAN
                                   , TRADINGLIABILITY
                                   , NOTESPAYABLE
                                   , ACCOUNTSPAYABLE
                                   , STBONDSPAYABLE
                                   , ADVANCERECEIPTS
                                   , SALARIESPAYABLE
                                   , DIVIDENDPAYABLE
                                   , TAXSPAYABLE
                                   , INTERESTPAYABLE
                                   , OTHERPAYABLE
                                   , ACCRUEDEXPENSE
                                   , DEFERREDPROCEEDS
                                   , NONCURRENTLIABILITYIN1YEAR
                                   , OTHERCURRENTLIABILITY
                                   , CLEXCEPTIONALITEMS
                                   , CLADJUSTMENTITEMS
                                   , TOTALCURRENTLIABILITY
                                   , LONGTERMLOAN
                                   , BONDSPAYABLE
                                   , LONGTERMACCOUNTPAYABLE
                                   , SPECIFICACCOUNTPAYABLE
                                   , ESTIMATELIABILITY
                                   , DEFERREDTAXLIABILITY
                                   , OTHERNONCURRENTLIABILITY
                                   , NCLEXCEPTIONALITEMS
                                   , NCLADJUSTMENTITEMS
                                   , TOTALNONCURRENTLIABILITY
                                   , BORROWINGFROMCENTRALBANK
                                   , DEPOSITOFINTERBANK
                                   , BORROWINGCAPITAL
                                   , DERIVATIVELIABILITY
                                   , SOLDBUYBACKSECUPROCEEDS
                                   , DEPOSIT
                                   , PROXYSECUPROCEEDS
                                   , SUBISSUESECUPROCEEDS
                                   , DEPOSITSRECEIVED
                                   , ADVANCEINSURANCE
                                   , COMMISSIONPAYABLE
                                   , REINSURANCEPAYABLES
                                   , COMPENSATIONPAYABLE
                                   , POLICYDIVIDENDPAYABLE
                                   , INSURERDEPOSITINVESTMENT
                                   , UNEARNEDPREMIUMRESERVE
                                   , OUTSTANDINGCLAIMRESERVE
                                   , LIFEINSURANCERESERVE
                                   , LTHEALTHINSURANCELR
                                   , INDEPENDENCELIABILITY
                                   , OTHERLIABILITY
                                   , LEXCEPTIONALITEMS
                                   , LADJUSTMENTITEMS
                                   , TOTALLIABILITY
                                   , PAIDINCAPITAL
                                   , CAPITALRESERVEFUND
                                   , SURPLUSRESERVEFUND
                                   , RETAINEDPROFIT
                                   , TREASURYSTOCK
                                   , ORDINARYRISKRESERVEFUND
                                   , FOREIGNCURRENCYREPORTCONVDIFF
                                   , UNCERTAINEDINVESTMENTLOSS
                                   , OTHERRESERVES
                                   , SPECIFICRESERVES
                                   , SEEXCEPTIONALITEMS
                                   , SEADJUSTMENTITEMS
                                   , SEWITHOUTMI
                                   , MINORITYINTERESTS
                                   , OTHERITEMSEFFECTINGSE
                                   , TOTALSHAREHOLDEREQUITY
                                   , LEEXCEPTIONALITEMS
                                   , LEADJUSTMENTITEMS
                                   , TOTALLIABILITYANDEQUITY
                                   , SPECIALFIELDREMARK
                                   , UPDATETIME
                                   , JSID
                                   , IFCOMPLETE
                                   , LPREFERSTOCK
                                   , LPERPETUALDEBT
                                   , OTHEREQUITYINSTRUMENTS
                                   , EPREFERSTOCK
                                   , EPERPETUALDEBT
                                   , OTHERCOMPOSITEINCOME
                                   , HOLDANDFSASSETS
                                   , HOLDANDFSLI
                                   , LONGSALARIESPAY
                                   , LONGDEFERINCOME
                                   , BILLACCRECEIVABLE
                                   , CONTRACTUALASSETS
                                   , DEBTINVESTMENT
                                   , OTHDEBTINVESTMENT
                                   , OTHEQUITYINSTRUMENT
                                   , OTHNONCURFINASSETS
                                   , NOTACCOUNTSPAYABLE
                                   , CONTRACTLIABILITY
                                   , TRADERISKRSRVFD
                                   , OTHERRECEIVABLEED
                                   , OTHERPAYABLEED
                                   , RECEIVABLESFIN
                                   , FINANCING
                                   , FINLEASERECEIVABLE
                                   , RESREIRECECONTRACTS
                                   , USUFRUCTASSETS
                                   , ABSINTERDEPOSITS
                                   , INSCONTRACTRESERVE
                                   , LEASELIABILITIES
                                   , FINLEASESPAYABLE
                                   , TOTALFIXEDASSET
                                   , TCONSTRUINPROCESS
                                   , DEPOSITINASSOCIATE
                                   , DEBTASSETS
                                   , DEBITOFASSOCIATE
                                   , INFOSOURCECODE
                                   , INSERTTIME
                                   , CASH
                                   , DEPOSITINCENTRALBANK
                                   , AMONGTRADINGASSETS
                                   , AMONGFINAETATFVALTPL
                                   , RECEIVABLES
                                   , CASHDEPOSITRECEIVE
                                   , PLEDGDEPOSITRECEIVE
                                   , SETTLEMENTRECEIVE
                                   , RISKOFLOSSRECEIVE
                                   , FEECOMMISSIONRECEIVE
                                   , AMONGDEBTINVESTMENT
                                   , AMONGFINAETATAMORCOST
                                   , AMONGOTHDEBTINVEST
                                   , AMONGFINAETATFVALTOCI
                                   , AMONGOTHEQUINSTRUMENT
                                   , AMONGEQUINSATFVALTOCI
                                   , FUTUREMEMBERINVESTMENT
                                   , FINANCIALINVESTMENT
                                   , SHORTTERMBONDPAY
                                   , AMONGTRADINGLIABILITY
                                   , AMONGFINLIAATFVALTPL
                                   , PAYABLES
                                   , CASHDEPOSITPAY
                                   , PLEDGDEPOSITPAY
                                   , FUTUREPROTECTFUNDPAY
                                   , GUARANTCOMPENSATERSRV
                                   , GUARANTEERESERVE
                                   , FUTURERISKRESERVE
                                   , LTINSCONTRACTRESERVE
                                   , LTACCOUNTPAYABLETOTAL
                                FROM ${jy_src_schema}.LC_BALANCESHEETALL"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "BULLETINTYPE", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "IFADJUSTED", "type": "DOUBLE"}, {"name": "IFMERGED", "type": "DOUBLE"}, {"name": "ACCOUNTINGSTANDARDS", "type": "DOUBLE"}, {"name": "ENTERPRISETYPE", "type": "DOUBLE"}, {"name": "CASHEQUIVALENTS", "type": "DOUBLE"}, {"name": "CLIENTDEPOSIT", "type": "DOUBLE"}, {"name": "TRADINGASSETS", "type": "DOUBLE"}, {"name": "BILLRECEIVABLE", "type": "DOUBLE"}, {"name": "DIVIDENDRECEIVABLE", "type": "DOUBLE"}, {"name": "INTERESTRECEIVABLE", "type": "DOUBLE"}, {"name": "ACCOUNTRECEIVABLE", "type": "DOUBLE"}, {"name": "OTHERRECEIVABLE", "type": "DOUBLE"}, {"name": "ADVANCEPAYMENT", "type": "DOUBLE"}, {"name": "INVENTORIES", "type": "DOUBLE"}, {"name": "BEARERBIOLOGICALASSETS", "type": "DOUBLE"}, {"name": "DEFERREDEXPENSE", "type": "DOUBLE"}, {"name": "NONCURRENTASSETIN1YEAR", "type": "DOUBLE"}, {"name": "OTHERCURRENTASSETS", "type": "DOUBLE"}, {"name": "CAEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "CAADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALCURRENTASSETS", "type": "DOUBLE"}, {"name": "HOLDFORSALEASSETS", "type": "DOUBLE"}, {"name": "HOLDTOMATURITYINVESTMENTS", "type": "DOUBLE"}, {"name": "INVESTMENTPROPERTY", "type": "DOUBLE"}, {"name": "LONGTERMEQUITYINVEST", "type": "DOUBLE"}, {"name": "LONGTERMRECEIVABLEACCOUNT", "type": "DOUBLE"}, {"name": "FIXEDASSETS", "type": "DOUBLE"}, {"name": "CONSTRUCTIONMATERIALS", "type": "DOUBLE"}, {"name": "CONSTRUINPROCESS", "type": "DOUBLE"}, {"name": "FIXEDASSETSLIQUIDATION", "type": "DOUBLE"}, {"name": "BIOLOGICALASSETS", "type": "DOUBLE"}, {"name": "OILGASASSETS", "type": "DOUBLE"}, {"name": "INTANGIBLEASSETS", "type": "DOUBLE"}, {"name": "SEATCOSTS", "type": "DOUBLE"}, {"name": "DEVELOPMENTEXPENDITURE", "type": "DOUBLE"}, {"name": "GOODWILL", "type": "DOUBLE"}, {"name": "LONGDEFERREDEXPENSE", "type": "DOUBLE"}, {"name": "DEFERREDTAXASSETS", "type": "DOUBLE"}, {"name": "OTHERNONCURRENTASSETS", "type": "DOUBLE"}, {"name": "NCAEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "NCAADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALNONCURRENTASSETS", "type": "DOUBLE"}, {"name": "LOANANDACCOUNTRECEIVABLES", "type": "DOUBLE"}, {"name": "SETTLEMENTPROVI", "type": "DOUBLE"}, {"name": "CLIENTPROVI", "type": "DOUBLE"}, {"name": "DEPOSITININTERBANK", "type": "DOUBLE"}, {"name": "RMETAL", "type": "DOUBLE"}, {"name": "LENDCAPITAL", "type": "DOUBLE"}, {"name": "DERIVATIVEASSETS", "type": "DOUBLE"}, {"name": "BOUGHTSELLBACKASSETS", "type": "DOUBLE"}, {"name": "LOANANDADVANCE", "type": "DOUBLE"}, {"name": "INSURANCERECEIVABLES", "type": "DOUBLE"}, {"name": "RECEIVABLESUBROGATIONFEE", "type": "DOUBLE"}, {"name": "REINSURANCERECEIVABLES", "type": "DOUBLE"}, {"name": "RECEIVABLEUNEARNEDR", "type": "DOUBLE"}, {"name": "RECEIVABLECLAIMSR", "type": "DOUBLE"}, {"name": "RECEIVABLELIFER", "type": "DOUBLE"}, {"name": "RECEIVABLELTHEALTHR", "type": "DOUBLE"}, {"name": "INSURERIMPAWNLOAN", "type": "DOUBLE"}, {"name": "FIXEDDEPOSIT", "type": "DOUBLE"}, {"name": "REFUNDABLEDEPOSIT", "type": "DOUBLE"}, {"name": "REFUNDABLECAPITALDEPOSIT", "type": "DOUBLE"}, {"name": "INDEPENDENCEACCOUNTASSETS", "type": "DOUBLE"}, {"name": "OTHERASSETS", "type": "DOUBLE"}, {"name": "AEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "AADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALASSETS", "type": "DOUBLE"}, {"name": "SHORTTERMLOAN", "type": "DOUBLE"}, {"name": "IMPAWNEDLOAN", "type": "DOUBLE"}, {"name": "TRADINGLIABILITY", "type": "DOUBLE"}, {"name": "NOTESPAYABLE", "type": "DOUBLE"}, {"name": "ACCOUNTSPAYABLE", "type": "DOUBLE"}, {"name": "STBONDSPAYABLE", "type": "DOUBLE"}, {"name": "ADVANCERECEIPTS", "type": "DOUBLE"}, {"name": "SALARIESPAYABLE", "type": "DOUBLE"}, {"name": "DIVIDENDPAYABLE", "type": "DOUBLE"}, {"name": "TAXSPAYABLE", "type": "DOUBLE"}, {"name": "INTERESTPAYABLE", "type": "DOUBLE"}, {"name": "OTHERPAYABLE", "type": "DOUBLE"}, {"name": "ACCRUEDEXPENSE", "type": "DOUBLE"}, {"name": "DEFERREDPROCEEDS", "type": "DOUBLE"}, {"name": "NONCURRENTLIABILITYIN1YEAR", "type": "DOUBLE"}, {"name": "OTHERCURRENTLIABILITY", "type": "DOUBLE"}, {"name": "CLEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "CLADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALCURRENTLIABILITY", "type": "DOUBLE"}, {"name": "LONGTERMLOAN", "type": "DOUBLE"}, {"name": "BONDSPAYABLE", "type": "DOUBLE"}, {"name": "LONGTERMACCOUNTPAYABLE", "type": "DOUBLE"}, {"name": "SPECIFICACCOUNTPAYABLE", "type": "DOUBLE"}, {"name": "ESTIMATELIABILITY", "type": "DOUBLE"}, {"name": "DEFERREDTAXLIABILITY", "type": "DOUBLE"}, {"name": "OTHERNONCURRENTLIABILITY", "type": "DOUBLE"}, {"name": "NCLEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "NCLADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALNONCURRENTLIABILITY", "type": "DOUBLE"}, {"name": "BORROWINGFROMCENTRALBANK", "type": "DOUBLE"}, {"name": "DEPOSITOFINTERBANK", "type": "DOUBLE"}, {"name": "BORROWINGCAPITAL", "type": "DOUBLE"}, {"name": "DERIVATIVELIABILITY", "type": "DOUBLE"}, {"name": "SOLDBUYBACKSECUPROCEEDS", "type": "DOUBLE"}, {"name": "DEPOSIT", "type": "DOUBLE"}, {"name": "PROXYSECUPROCEEDS", "type": "DOUBLE"}, {"name": "SUBISSUESECUPROCEEDS", "type": "DOUBLE"}, {"name": "DEPOSITSRECEIVED", "type": "DOUBLE"}, {"name": "ADVANCEINSURANCE", "type": "DOUBLE"}, {"name": "COMMISSIONPAYABLE", "type": "DOUBLE"}, {"name": "REINSURANCEPAYABLES", "type": "DOUBLE"}, {"name": "COMPENSATIONPAYABLE", "type": "DOUBLE"}, {"name": "POLICYDIVIDENDPAYABLE", "type": "DOUBLE"}, {"name": "INSURERDEPOSITINVESTMENT", "type": "DOUBLE"}, {"name": "UNEARNEDPREMIUMRESERVE", "type": "DOUBLE"}, {"name": "OUTSTANDINGCLAIMRESERVE", "type": "DOUBLE"}, {"name": "LIFEINSURANCERESERVE", "type": "DOUBLE"}, {"name": "LTHEALTHINSURANCELR", "type": "DOUBLE"}, {"name": "INDEPENDENCELIABILITY", "type": "DOUBLE"}, {"name": "OTHERLIABILITY", "type": "DOUBLE"}, {"name": "LEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "LADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALLIABILITY", "type": "DOUBLE"}, {"name": "PAIDINCAPITAL", "type": "DOUBLE"}, {"name": "CAPITALRESERVEFUND", "type": "DOUBLE"}, {"name": "SURPLUSRESERVEFUND", "type": "DOUBLE"}, {"name": "RETAINEDPROFIT", "type": "DOUBLE"}, {"name": "TREASURYSTOCK", "type": "DOUBLE"}, {"name": "ORDINARYRISKRESERVEFUND", "type": "DOUBLE"}, {"name": "FOREIGNCURRENCYREPORTCONVDIFF", "type": "DOUBLE"}, {"name": "UNCERTAINEDINVESTMENTLOSS", "type": "DOUBLE"}, {"name": "OTHERRESERVES", "type": "DOUBLE"}, {"name": "SPECIFICRESERVES", "type": "DOUBLE"}, {"name": "SEEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "SEADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "SEWITHOUTMI", "type": "DOUBLE"}, {"name": "MINORITYINTERESTS", "type": "DOUBLE"}, {"name": "OTHERITEMSEFFECTINGSE", "type": "DOUBLE"}, {"name": "TOTALSHAREHOLDEREQUITY", "type": "DOUBLE"}, {"name": "LEEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "LEADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALLIABILITYANDEQUITY", "type": "DOUBLE"}, {"name": "SPECIALFIELDREMARK", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "IFCOMPLETE", "type": "DOUBLE"}, {"name": "LPREFERSTOCK", "type": "DOUBLE"}, {"name": "LPERPETUALDEBT", "type": "DOUBLE"}, {"name": "OTHEREQUITYINSTRUMENTS", "type": "DOUBLE"}, {"name": "EPREFERSTOCK", "type": "DOUBLE"}, {"name": "EPERPETUALDEBT", "type": "DOUBLE"}, {"name": "OTHERCOMPOSITEINCOME", "type": "DOUBLE"}, {"name": "HOLDANDFSASSETS", "type": "DOUBLE"}, {"name": "HOLDANDFSLI", "type": "DOUBLE"}, {"name": "LONGSALARIESPAY", "type": "DOUBLE"}, {"name": "LONGDEFERINCOME", "type": "DOUBLE"}, {"name": "BILLACCRECEIVABLE", "type": "DOUBLE"}, {"name": "CONTRACTUALASSETS", "type": "DOUBLE"}, {"name": "DEBTINVESTMENT", "type": "DOUBLE"}, {"name": "OTHDEBTINVESTMENT", "type": "DOUBLE"}, {"name": "OTHEQUITYINSTRUMENT", "type": "DOUBLE"}, {"name": "OTHNONCURFINASSETS", "type": "DOUBLE"}, {"name": "NOTACCOUNTSPAYABLE", "type": "DOUBLE"}, {"name": "CONTRACTLIABILITY", "type": "DOUBLE"}, {"name": "TRADERISKRSRVFD", "type": "DOUBLE"}, {"name": "OTHERRECEIVABLEED", "type": "DOUBLE"}, {"name": "OTHERPAYABLEED", "type": "DOUBLE"}, {"name": "RECEIVABLESFIN", "type": "DOUBLE"}, {"name": "FINANCING", "type": "DOUBLE"}, {"name": "FINLEASERECEIVABLE", "type": "DOUBLE"}, {"name": "RESREIRECECONTRACTS", "type": "DOUBLE"}, {"name": "USUFRUCTASSETS", "type": "DOUBLE"}, {"name": "ABSINTERDEPOSITS", "type": "DOUBLE"}, {"name": "INSCONTRACTRESERVE", "type": "DOUBLE"}, {"name": "LEASELIABILITIES", "type": "DOUBLE"}, {"name": "FINLEASESPAYABLE", "type": "DOUBLE"}, {"name": "TOTALFIXEDASSET", "type": "DOUBLE"}, {"name": "TCONSTRUINPROCESS", "type": "DOUBLE"}, {"name": "DEPOSITINASSOCIATE", "type": "DOUBLE"}, {"name": "DEBTASSETS", "type": "DOUBLE"}, {"name": "DEBITOFASSOCIATE", "type": "DOUBLE"}, {"name": "INFOSOURCECODE", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "CASH", "type": "DOUBLE"}, {"name": "DEPOSITINCENTRALBANK", "type": "DOUBLE"}, {"name": "AMONGTRADINGASSETS", "type": "DOUBLE"}, {"name": "AMONGFINAETATFVALTPL", "type": "DOUBLE"}, {"name": "RECEIVABLES", "type": "DOUBLE"}, {"name": "CASHDEPOSITRECEIVE", "type": "DOUBLE"}, {"name": "PLEDGDEPOSITRECEIVE", "type": "DOUBLE"}, {"name": "SETTLEMENTRECEIVE", "type": "DOUBLE"}, {"name": "RISKOFLOSSRECEIVE", "type": "DOUBLE"}, {"name": "FEECOMMISSIONRECEIVE", "type": "DOUBLE"}, {"name": "AMONGDEBTINVESTMENT", "type": "DOUBLE"}, {"name": "AMONGFINAETATAMORCOST", "type": "DOUBLE"}, {"name": "AMONGOTHDEBTINVEST", "type": "DOUBLE"}, {"name": "AMONGFINAETATFVALTOCI", "type": "DOUBLE"}, {"name": "AMONGOTHEQUINSTRUMENT", "type": "DOUBLE"}, {"name": "AMONGEQUINSATFVALTOCI", "type": "DOUBLE"}, {"name": "FUTUREMEMBERINVESTMENT", "type": "DOUBLE"}, {"name": "FINANCIALINVESTMENT", "type": "DOUBLE"}, {"name": "SHORTTERMBONDPAY", "type": "DOUBLE"}, {"name": "AMONGTRADINGLIABILITY", "type": "DOUBLE"}, {"name": "AMONGFINLIAATFVALTPL", "type": "DOUBLE"}, {"name": "PAYABLES", "type": "DOUBLE"}, {"name": "CASHDEPOSITPAY", "type": "DOUBLE"}, {"name": "PLEDGDEPOSITPAY", "type": "DOUBLE"}, {"name": "FUTUREPROTECTFUNDPAY", "type": "DOUBLE"}, {"name": "GUARANTCOMPENSATERSRV", "type": "DOUBLE"}, {"name": "GUARANTEERESERVE", "type": "DOUBLE"}, {"name": "FUTURERISKRESERVE", "type": "DOUBLE"}, {"name": "LTINSCONTRACTRESERVE", "type": "DOUBLE"}, {"name": "LTACCOUNTPAYABLETOTAL", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_balancesheetall_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_balancesheetall_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_balancesheetall_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_balancesheetall_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_BALANCESHEETALL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_BALANCESHEETALL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_balancesheetall_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_BALANCESHEETALL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INFOPUBLDATE
     , INFOSOURCE
     , BULLETINTYPE
     , COMPANYCODE
     , ENDDATE
     , IFADJUSTED
     , IFMERGED
     , ACCOUNTINGSTANDARDS
     , ENTERPRISETYPE
     , CASHEQUIVALENTS
     , CLIENTDEPOSIT
     , TRADINGASSETS
     , BILLRECEIVABLE
     , DIVIDENDRECEIVABLE
     , INTERESTRECEIVABLE
     , ACCOUNTRECEIVABLE
     , OTHERRECEIVABLE
     , ADVANCEPAYMENT
     , INVENTORIES
     , BEARERBIOLOGICALASSETS
     , DEFERREDEXPENSE
     , NONCURRENTASSETIN1YEAR
     , OTHERCURRENTASSETS
     , CAEXCEPTIONALITEMS
     , CAADJUSTMENTITEMS
     , TOTALCURRENTASSETS
     , HOLDFORSALEASSETS
     , HOLDTOMATURITYINVESTMENTS
     , INVESTMENTPROPERTY
     , LONGTERMEQUITYINVEST
     , LONGTERMRECEIVABLEACCOUNT
     , FIXEDASSETS
     , CONSTRUCTIONMATERIALS
     , CONSTRUINPROCESS
     , FIXEDASSETSLIQUIDATION
     , BIOLOGICALASSETS
     , OILGASASSETS
     , INTANGIBLEASSETS
     , SEATCOSTS
     , DEVELOPMENTEXPENDITURE
     , GOODWILL
     , LONGDEFERREDEXPENSE
     , DEFERREDTAXASSETS
     , OTHERNONCURRENTASSETS
     , NCAEXCEPTIONALITEMS
     , NCAADJUSTMENTITEMS
     , TOTALNONCURRENTASSETS
     , LOANANDACCOUNTRECEIVABLES
     , SETTLEMENTPROVI
     , CLIENTPROVI
     , DEPOSITININTERBANK
     , RMETAL
     , LENDCAPITAL
     , DERIVATIVEASSETS
     , BOUGHTSELLBACKASSETS
     , LOANANDADVANCE
     , INSURANCERECEIVABLES
     , RECEIVABLESUBROGATIONFEE
     , REINSURANCERECEIVABLES
     , RECEIVABLEUNEARNEDR
     , RECEIVABLECLAIMSR
     , RECEIVABLELIFER
     , RECEIVABLELTHEALTHR
     , INSURERIMPAWNLOAN
     , FIXEDDEPOSIT
     , REFUNDABLEDEPOSIT
     , REFUNDABLECAPITALDEPOSIT
     , INDEPENDENCEACCOUNTASSETS
     , OTHERASSETS
     , AEXCEPTIONALITEMS
     , AADJUSTMENTITEMS
     , TOTALASSETS
     , SHORTTERMLOAN
     , IMPAWNEDLOAN
     , TRADINGLIABILITY
     , NOTESPAYABLE
     , ACCOUNTSPAYABLE
     , STBONDSPAYABLE
     , ADVANCERECEIPTS
     , SALARIESPAYABLE
     , DIVIDENDPAYABLE
     , TAXSPAYABLE
     , INTERESTPAYABLE
     , OTHERPAYABLE
     , ACCRUEDEXPENSE
     , DEFERREDPROCEEDS
     , NONCURRENTLIABILITYIN1YEAR
     , OTHERCURRENTLIABILITY
     , CLEXCEPTIONALITEMS
     , CLADJUSTMENTITEMS
     , TOTALCURRENTLIABILITY
     , LONGTERMLOAN
     , BONDSPAYABLE
     , LONGTERMACCOUNTPAYABLE
     , SPECIFICACCOUNTPAYABLE
     , ESTIMATELIABILITY
     , DEFERREDTAXLIABILITY
     , OTHERNONCURRENTLIABILITY
     , NCLEXCEPTIONALITEMS
     , NCLADJUSTMENTITEMS
     , TOTALNONCURRENTLIABILITY
     , BORROWINGFROMCENTRALBANK
     , DEPOSITOFINTERBANK
     , BORROWINGCAPITAL
     , DERIVATIVELIABILITY
     , SOLDBUYBACKSECUPROCEEDS
     , DEPOSIT
     , PROXYSECUPROCEEDS
     , SUBISSUESECUPROCEEDS
     , DEPOSITSRECEIVED
     , ADVANCEINSURANCE
     , COMMISSIONPAYABLE
     , REINSURANCEPAYABLES
     , COMPENSATIONPAYABLE
     , POLICYDIVIDENDPAYABLE
     , INSURERDEPOSITINVESTMENT
     , UNEARNEDPREMIUMRESERVE
     , OUTSTANDINGCLAIMRESERVE
     , LIFEINSURANCERESERVE
     , LTHEALTHINSURANCELR
     , INDEPENDENCELIABILITY
     , OTHERLIABILITY
     , LEXCEPTIONALITEMS
     , LADJUSTMENTITEMS
     , TOTALLIABILITY
     , PAIDINCAPITAL
     , CAPITALRESERVEFUND
     , SURPLUSRESERVEFUND
     , RETAINEDPROFIT
     , TREASURYSTOCK
     , ORDINARYRISKRESERVEFUND
     , FOREIGNCURRENCYREPORTCONVDIFF
     , UNCERTAINEDINVESTMENTLOSS
     , OTHERRESERVES
     , SPECIFICRESERVES
     , SEEXCEPTIONALITEMS
     , SEADJUSTMENTITEMS
     , SEWITHOUTMI
     , MINORITYINTERESTS
     , OTHERITEMSEFFECTINGSE
     , TOTALSHAREHOLDEREQUITY
     , LEEXCEPTIONALITEMS
     , LEADJUSTMENTITEMS
     , TOTALLIABILITYANDEQUITY
     , SPECIALFIELDREMARK
     , UPDATETIME
     , JSID
     , IFCOMPLETE
     , LPREFERSTOCK
     , LPERPETUALDEBT
     , OTHEREQUITYINSTRUMENTS
     , EPREFERSTOCK
     , EPERPETUALDEBT
     , OTHERCOMPOSITEINCOME
     , HOLDANDFSASSETS
     , HOLDANDFSLI
     , LONGSALARIESPAY
     , LONGDEFERINCOME
     , BILLACCRECEIVABLE
     , CONTRACTUALASSETS
     , DEBTINVESTMENT
     , OTHDEBTINVESTMENT
     , OTHEQUITYINSTRUMENT
     , OTHNONCURFINASSETS
     , NOTACCOUNTSPAYABLE
     , CONTRACTLIABILITY
     , TRADERISKRSRVFD
     , OTHERRECEIVABLEED
     , OTHERPAYABLEED
     , RECEIVABLESFIN
     , FINANCING
     , FINLEASERECEIVABLE
     , RESREIRECECONTRACTS
     , USUFRUCTASSETS
     , ABSINTERDEPOSITS
     , INSCONTRACTRESERVE
     , LEASELIABILITIES
     , FINLEASESPAYABLE
     , TOTALFIXEDASSET
     , TCONSTRUINPROCESS
     , DEPOSITINASSOCIATE
     , DEBTASSETS
     , DEBITOFASSOCIATE
     , INFOSOURCECODE
     , INSERTTIME
     , CASH
     , DEPOSITINCENTRALBANK
     , AMONGTRADINGASSETS
     , AMONGFINAETATFVALTPL
     , RECEIVABLES
     , CASHDEPOSITRECEIVE
     , PLEDGDEPOSITRECEIVE
     , SETTLEMENTRECEIVE
     , RISKOFLOSSRECEIVE
     , FEECOMMISSIONRECEIVE
     , AMONGDEBTINVESTMENT
     , AMONGFINAETATAMORCOST
     , AMONGOTHDEBTINVEST
     , AMONGFINAETATFVALTOCI
     , AMONGOTHEQUINSTRUMENT
     , AMONGEQUINSATFVALTOCI
     , FUTUREMEMBERINVESTMENT
     , FINANCIALINVESTMENT
     , SHORTTERMBONDPAY
     , AMONGTRADINGLIABILITY
     , AMONGFINLIAATFVALTPL
     , PAYABLES
     , CASHDEPOSITPAY
     , PLEDGDEPOSITPAY
     , FUTUREPROTECTFUNDPAY
     , GUARANTCOMPENSATERSRV
     , GUARANTEERESERVE
     , FUTURERISKRESERVE
     , LTINSCONTRACTRESERVE
     , LTACCOUNTPAYABLETOTAL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_BALANCESHEETALL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_BALANCESHEETALL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_BALANCESHEETALL_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_BALANCESHEETALL_PFD成功"
      exit 0
   fi
fi
