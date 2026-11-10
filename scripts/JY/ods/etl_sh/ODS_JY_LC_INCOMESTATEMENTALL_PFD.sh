#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_INCOMESTATEMENTALL_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_INCOMESTATEMENTALL_PFD_TMP(
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
  TOTALOPERATINGREVENUE  DECIMAL(19,4)  COMMENT  '一、营业总收入',
  OPERATINGREVENUE  DECIMAL(19,4)  COMMENT  '一、营业收入',
  NETINTERESTINCOME  DECIMAL(19,4)  COMMENT  '利息净收入',
  INTERESTINCOME  DECIMAL(19,4)  COMMENT  '其中:利息收入(元)',
  INTERESTEXPENSE  DECIMAL(19,4)  COMMENT  '其中:利息支出(元)',
  NETCOMMISSIONINCOME  DECIMAL(19,4)  COMMENT  '手续费及佣金净收入',
  COMMISSIONINCOME  DECIMAL(19,4)  COMMENT  '手续费收入(元)',
  COMMISSIONEXPENSE  DECIMAL(19,4)  COMMENT  '手续费支出(元)',
  NETPROXYSECUINCOME  DECIMAL(19,4)  COMMENT  '其中:代理买卖证券业务净收入',
  NETSUBISSUESECUINCOME  DECIMAL(19,4)  COMMENT  '其中:证券承销业务净收入',
  NETTRUSTINCOME  DECIMAL(19,4)  COMMENT  '其中:受托客户资产管理业务净收入(元)',
  PREMIUMSEARNED  DECIMAL(19,4)  COMMENT  '已赚保费(元)',
  PREMIUMSINCOME  DECIMAL(19,4)  COMMENT  '保险业务收入(元)',
  REINSURANCEINCOME  DECIMAL(19,4)  COMMENT  '其中:分保费收入',
  REINSURANCE  DECIMAL(19,4)  COMMENT  '减:分出保费(元)',
  UNEARNEDPREMIUMRESERVE  DECIMAL(19,4)  COMMENT  '未到期责任准备金',
  OTHEROPERATINGREVENUE  DECIMAL(19,4)  COMMENT  '其他营业收入',
  SPECIALITEMSOR  DECIMAL(19,4)  COMMENT  '##营业收入特殊项目(元)',
  ADJUSTMENTITEMSOR  DECIMAL(19,4)  COMMENT  '##营业收入调整项目',
  TOTALOPERATINGCOST  DECIMAL(19,4)  COMMENT  '二、营业总成本',
  OPERATINGPAYOUT  DECIMAL(19,4)  COMMENT  '营业支出(元)',
  REFUNDEDPREMIUMS  DECIMAL(19,4)  COMMENT  '退保金',
  COMPENSATIONEXPENSE  DECIMAL(19,4)  COMMENT  '赔付支出',
  AMORTIZATIONEXPENSE  DECIMAL(19,4)  COMMENT  '减:摊回赔付支出',
  PREMIUMRESERVE  DECIMAL(19,4)  COMMENT  '提取保险责任准备金(元)',
  AMORTIZATIONPREMIUMRESERVE  DECIMAL(19,4)  COMMENT  '减:摊回保险责任准备金',
  POLICYDIVIDENDPAYOUT  DECIMAL(19,4)  COMMENT  '保单红利支出',
  REINSURANCECOST  DECIMAL(19,4)  COMMENT  '分保费用(元)',
  OPERATINGANDADMINEXPENSE  DECIMAL(19,4)  COMMENT  '业务及管理费',
  AMORTIZATIONREINSURANCECOST  DECIMAL(19,4)  COMMENT  '减:摊回分保费用',
  INSURANCECOMMISSIONEXPENSE  DECIMAL(19,4)  COMMENT  '保险手续费及佣金支出',
  OTHEROPERATINGCOST  DECIMAL(19,4)  COMMENT  '其他业务成本',
  OPERATINGCOST  DECIMAL(19,4)  COMMENT  '减:营业成本(元)',
  OPERATINGTAXSURCHARGES  DECIMAL(19,4)  COMMENT  '营业税金及附加',
  OPERATINGEXPENSE  DECIMAL(19,4)  COMMENT  '营业费用(元)',
  ADMINISTRATIONEXPENSE  DECIMAL(19,4)  COMMENT  '管理费用(元)',
  FINANCIALEXPENSE  DECIMAL(19,4)  COMMENT  '财务费用(元)',
  ASSETIMPAIRMENTLOSS  DECIMAL(19,4)  COMMENT  '资产减值损失',
  SPECIALITEMSTOC  DECIMAL(19,4)  COMMENT  '##营业支出特殊项目(元)',
  ADJUSTMENTITEMSTOC  DECIMAL(19,4)  COMMENT  '##营业总成本调整项目',
  OTHERNETREVENUE  DECIMAL(19,4)  COMMENT  '三、非经营性净收益',
  FAIRVALUECHANGEINCOME  DECIMAL(19,4)  COMMENT  '公允价值变动净收益',
  INVESTINCOME  DECIMAL(19,4)  COMMENT  '加:投资净收益(元)',
  INVESTINCOMEASSOCIATES  DECIMAL(19,4)  COMMENT  '其中:对联营合营企业的投资收益',
  EXCHANGEINCOME  DECIMAL(19,4)  COMMENT  '汇兑收益(元)',
  OTHERITEMSEFFECTINGOP  DECIMAL(19,4)  COMMENT  '##加:影响营业利润的其他科目',
  ADJUSTEDITEMSEFFECTINGOP  DECIMAL(19,4)  COMMENT  '##加:影响营业利润的调整项目',
  OPERATINGPROFIT  DECIMAL(19,4)  COMMENT  '二、营业利润(元)',
  NONOPERATINGINCOME  DECIMAL(19,4)  COMMENT  '营业外收入(元)',
  NONOPERATINGEXPENSE  DECIMAL(19,4)  COMMENT  '减：营业外支出(元)',
  NONCURRENTASSETSSDEALLOSS  DECIMAL(19,4)  COMMENT  '其中:非流动资产处置净损失',
  OTHERITEMSEFFECTINGTP  DECIMAL(19,4)  COMMENT  '##加:影响利润总额的其他科目',
  ADJUSTEDITEMSEFFECTINGTP  DECIMAL(19,4)  COMMENT  '##加:影响利润总额的调整项目',
  TOTALPROFIT  DECIMAL(19,4)  COMMENT  '利润总额(元)',
  INCOMETAXCOST  DECIMAL(19,4)  COMMENT  '减:所得税(元)',
  UNCERTAINEDINVESTMENTLOSSES  DECIMAL(19,4)  COMMENT  '加:未确认的投资损失',
  OTHERITEMSEFFECTINGNP  DECIMAL(19,4)  COMMENT  '##加:影响净利润的其他科目',
  ADJUSTEDITEMSEFFECTINGNP  DECIMAL(19,4)  COMMENT  '##加:影响净利润的调整项目',
  NETPROFIT  DECIMAL(19,4)  COMMENT  '四、净利润(元)',
  NPPARENTCOMPANYOWNERS  DECIMAL(19,4)  COMMENT  '归属于母公司所有者的净利润',
  MINORITYPROFIT  DECIMAL(19,4)  COMMENT  '少数股东损益(元)',
  OTHERITEMSEFFECTINGNPP  DECIMAL(19,4)  COMMENT  '##加:影响母公司净利润的特殊项目',
  ADJUSTEDITEMSEFFECTINGNPP  DECIMAL(19,4)  COMMENT  '##加:影响母公司净利润的调整项目',
  OTHERCOMPOSITEINCOME  DECIMAL(19,4)  COMMENT  '其他综合收益',
  ADJUSTEDITEMSEFFECTINGCI  DECIMAL(19,4)  COMMENT  '##加:影响综合收益总额的调整项目',
  TOTALCOMPOSITEINCOME  DECIMAL(19,4)  COMMENT  '七、综合收益总额',
  CIPARENTCOMPANYOWNERS  DECIMAL(19,4)  COMMENT  '归属于母公司所有者的综合收益总额',
  CIMINORITYOWNERS  DECIMAL(19,4)  COMMENT  '归属于少数股东的综合收益总额',
  ADJUSTEDITEMSEFFECTINGPCI  DECIMAL(19,4)  COMMENT  '##加:影响母公司综合收益总额的调整项目',
  BASICEPS  DECIMAL(19,4)  COMMENT  '基本每股收益(元/股)',
  DILUTEDEPS  DECIMAL(19,4)  COMMENT  '稀释每股收益(元/股)',
  SPECIALFIELDREMARK  STRING  COMMENT  '特殊字段说明',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  IFCOMPLETE  STRING  COMMENT  '完整标志',
  OCIPARENTCOMPANYOWNERS  DECIMAL(19,4)  COMMENT  '归属于母公司所有者的其他综合收益总额',
  OCINOTININCOMESTATEMENT  DECIMAL(19,4)  COMMENT  '#以后不能重分类进损益表的其他综合收益',
  OCIREMEARSURE  DECIMAL(19,4)  COMMENT  '1.1重新计量设定收益计划净负债或净资产的变动(元)',
  OCIEQUITYNOTINIS  DECIMAL(19,4)  COMMENT  '##权益法下在被投资单位不能重分类进损益表的其他综合收益中享有的',
  OCIININCOMESTATEMENT  DECIMAL(19,4)  COMMENT  '#以后能重分类进损益表的其他综合收益',
  OCIEQUITYINIS  DECIMAL(19,4)  COMMENT  '2.1权益法下在被投资单位以后将重分类进损益表的其他综合收益中享',
  OCIFAIRVALUE  DECIMAL(19,4)  COMMENT  '2.2可供出售金融资产公允价值变动损益(元)',
  OCITOMATURITYFA  DECIMAL(19,4)  COMMENT  '2.3持有至到期投资重分类为可供出售金融资产损益(元)',
  OCICFLOSS  DECIMAL(19,4)  COMMENT  '2.4现金流量套期损益的有效部分(元)',
  OCIFOREIGNCURRENCYFSA  DECIMAL(19,4)  COMMENT  'WBCWNCFL',
  OCIOTHERS  DECIMAL(19,4)  COMMENT  '2.6其他(以后能重分类进损益表的其他综合收益)(元)',
  OCIMINORITYOWNERS  DECIMAL(19,4)  COMMENT  '归属于少数股东的其他综合收益总额',
  OTHERREVENUE  DECIMAL(19,4)  COMMENT  '其他收益',
  ASSETDEALINCOME  DECIMAL(19,4)  COMMENT  '资产处置收益',
  OPERSUSTCATEG  DECIMAL(19,4)  COMMENT  '(一)按经营持续性分类',
  OPERSUSTNETP  DECIMAL(19,4)  COMMENT  '持续经营净利润',
  DISCONOPERNETP  DECIMAL(19,4)  COMMENT  '终止经营净利润',
  OWNERSHIPCATEG  DECIMAL(19,4)  COMMENT  '(二)按所有权归属分类',
  RANDD  DECIMAL(19,4)  COMMENT  '',
  CREDITIMPAIRMENTL  DECIMAL(19,4)  COMMENT  '',
  NETOPENHEDGEINCOME  DECIMAL(19,4)  COMMENT  '',
  INTERESTFINEXP  DECIMAL(19,4)  COMMENT  '',
  INTERESTINCOMEFIN  DECIMAL(19,4)  COMMENT  '',
  OTHEQUFVCHANGE  DECIMAL(19,4)  COMMENT  '',
  CORPORATECRCHANGE  DECIMAL(19,4)  COMMENT  '',
  OTHDEBTINVESCHANGE  DECIMAL(19,4)  COMMENT  '',
  FINASSETROTHERCI  DECIMAL(19,4)  COMMENT  '',
  OTHERDEBTINVESTCIP  DECIMAL(19,4)  COMMENT  '',
  PREINSURRSRV  DECIMAL(19,4)  COMMENT  '提取保费准备金',
  NETCLAIMINCURRED  DECIMAL(19,4)  COMMENT  '赔付支出净额',
  NETPREMIUMRESERVE  DECIMAL(19,4)  COMMENT  '提取保险责任准备金净额',
  AMORTISEDCOSTINCOME  DECIMAL(19,4)  COMMENT  '以摊余成本计量的金融资产终止确认收益',
  INFOSOURCECODE  STRING  COMMENT  '信息来源编码',
  INSERTTIME  STRING  COMMENT  '发布时间',
  SALESREVENUE  DECIMAL(19,4)  COMMENT  '其中:主营业务收入',
  OTHEROPERATINGINCOME  DECIMAL(19,4)  COMMENT  '其中:其他业务收入',
  GUARANTEEINCOME  DECIMAL(19,4)  COMMENT  '其中:担保业务收入',
  BROKERAGEINCOME  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:经纪业务手续费收入',
  INVESTBANKINCOME  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:投资银行业务手续费收入',
  ASSETMANAGEINCOME  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:资产管理业务手续费收入',
  FUNDMANAGEINCOME  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:基金管理业务手续费收入',
  INVESTCONSULTINCOME  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:投资咨询业务收入',
  RISKMANAGEINCOME  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:风险管理业务收入',
  INVESTMANAGEINCOME  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:投资管理业务收入',
  OTHERAGENCYINCOME  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:其他代理业务收入',
  BROKERAGEEXPENSE  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金支出:经纪业务手续费支出',
  INVESTBANKEXPENSE  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金支出:投资银行业务手续费支出',
  ASSETMANAGEEXPENSE  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金支出:资产管理业务手续费支出',
  FUNDMANAGEEXPENSE  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金收入:基金管理业务手续费支出',
  INVESTCONSULTEXPENSE  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金支出:投资咨询业务支出',
  RISKMANAGEEXPENSE  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金支出:风险管理业务支出',
  INVESTMANAGEEXPENSE  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金支出:投资管理业务支出',
  OTHERAGENCYEXPENSE  DECIMAL(19,4)  COMMENT  '其中:手续费及佣金支出:其他代理业务支出',
  NETFUNDMGTINCOME  DECIMAL(19,4)  COMMENT  '其中:基金管理业务手续费净收入',
  EXTRACTFUTURERISK  DECIMAL(19,4)  COMMENT  '提取期货风险准备金',
  WITHDRAWGUARANTEERESER  DECIMAL(19,4)  COMMENT  '提取担保业务准备金',
  GUARANTCOMPRSRV  DECIMAL(19,4)  COMMENT  '提取担保赔偿准备金',
  SALESCOST  DECIMAL(19,4)  COMMENT  '其中:主营业务成本',
  OTHEROPERATIONALCOST  DECIMAL(19,4)  COMMENT  '其中:其他业务成本',
  TOTALADMINEXPENSE  DECIMAL(19,4)  COMMENT  '管理费用合计',
  EXPLORATIONCOST  DECIMAL(19,4)  COMMENT  '勘探费用',
  CREDITIMPAIRMENTP  DECIMAL(19,4)  COMMENT  '信用减值损失(利润)',
  ASSETIMPAIRMENTLOSSP  DECIMAL(19,4)  COMMENT  '资产减值损失(利润)'
)
COMMENT '利润分配表_新会计准则'
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
                                   , TOTALOPERATINGREVENUE
                                   , OPERATINGREVENUE
                                   , NETINTERESTINCOME
                                   , INTERESTINCOME
                                   , INTERESTEXPENSE
                                   , NETCOMMISSIONINCOME
                                   , COMMISSIONINCOME
                                   , COMMISSIONEXPENSE
                                   , NETPROXYSECUINCOME
                                   , NETSUBISSUESECUINCOME
                                   , NETTRUSTINCOME
                                   , PREMIUMSEARNED
                                   , PREMIUMSINCOME
                                   , REINSURANCEINCOME
                                   , REINSURANCE
                                   , UNEARNEDPREMIUMRESERVE
                                   , OTHEROPERATINGREVENUE
                                   , SPECIALITEMSOR
                                   , ADJUSTMENTITEMSOR
                                   , TOTALOPERATINGCOST
                                   , OPERATINGPAYOUT
                                   , REFUNDEDPREMIUMS
                                   , COMPENSATIONEXPENSE
                                   , AMORTIZATIONEXPENSE
                                   , PREMIUMRESERVE
                                   , AMORTIZATIONPREMIUMRESERVE
                                   , POLICYDIVIDENDPAYOUT
                                   , REINSURANCECOST
                                   , OPERATINGANDADMINEXPENSE
                                   , AMORTIZATIONREINSURANCECOST
                                   , INSURANCECOMMISSIONEXPENSE
                                   , OTHEROPERATINGCOST
                                   , OPERATINGCOST
                                   , OPERATINGTAXSURCHARGES
                                   , OPERATINGEXPENSE
                                   , ADMINISTRATIONEXPENSE
                                   , FINANCIALEXPENSE
                                   , ASSETIMPAIRMENTLOSS
                                   , SPECIALITEMSTOC
                                   , ADJUSTMENTITEMSTOC
                                   , OTHERNETREVENUE
                                   , FAIRVALUECHANGEINCOME
                                   , INVESTINCOME
                                   , INVESTINCOMEASSOCIATES
                                   , EXCHANGEINCOME
                                   , OTHERITEMSEFFECTINGOP
                                   , ADJUSTEDITEMSEFFECTINGOP
                                   , OPERATINGPROFIT
                                   , NONOPERATINGINCOME
                                   , NONOPERATINGEXPENSE
                                   , NONCURRENTASSETSSDEALLOSS
                                   , OTHERITEMSEFFECTINGTP
                                   , ADJUSTEDITEMSEFFECTINGTP
                                   , TOTALPROFIT
                                   , INCOMETAXCOST
                                   , UNCERTAINEDINVESTMENTLOSSES
                                   , OTHERITEMSEFFECTINGNP
                                   , ADJUSTEDITEMSEFFECTINGNP
                                   , NETPROFIT
                                   , NPPARENTCOMPANYOWNERS
                                   , MINORITYPROFIT
                                   , OTHERITEMSEFFECTINGNPP
                                   , ADJUSTEDITEMSEFFECTINGNPP
                                   , OTHERCOMPOSITEINCOME
                                   , ADJUSTEDITEMSEFFECTINGCI
                                   , TOTALCOMPOSITEINCOME
                                   , CIPARENTCOMPANYOWNERS
                                   , CIMINORITYOWNERS
                                   , ADJUSTEDITEMSEFFECTINGPCI
                                   , BASICEPS
                                   , DILUTEDEPS
                                   , SPECIALFIELDREMARK
                                   , UPDATETIME
                                   , JSID
                                   , IFCOMPLETE
                                   , OCIPARENTCOMPANYOWNERS
                                   , OCINOTININCOMESTATEMENT
                                   , OCIREMEARSURE
                                   , OCIEQUITYNOTINIS
                                   , OCIININCOMESTATEMENT
                                   , OCIEQUITYINIS
                                   , OCIFAIRVALUE
                                   , OCITOMATURITYFA
                                   , OCICFLOSS
                                   , OCIFOREIGNCURRENCYFSA
                                   , OCIOTHERS
                                   , OCIMINORITYOWNERS
                                   , OTHERREVENUE
                                   , ASSETDEALINCOME
                                   , OPERSUSTCATEG
                                   , OPERSUSTNETP
                                   , DISCONOPERNETP
                                   , OWNERSHIPCATEG
                                   , RANDD
                                   , CREDITIMPAIRMENTL
                                   , NETOPENHEDGEINCOME
                                   , INTERESTFINEXP
                                   , INTERESTINCOMEFIN
                                   , OTHEQUFVCHANGE
                                   , CORPORATECRCHANGE
                                   , OTHDEBTINVESCHANGE
                                   , FINASSETROTHERCI
                                   , OTHERDEBTINVESTCIP
                                   , PREINSURRSRV
                                   , NETCLAIMINCURRED
                                   , NETPREMIUMRESERVE
                                   , AMORTISEDCOSTINCOME
                                   , INFOSOURCECODE
                                   , INSERTTIME
                                   , SALESREVENUE
                                   , OTHEROPERATINGINCOME
                                   , GUARANTEEINCOME
                                   , BROKERAGEINCOME
                                   , INVESTBANKINCOME
                                   , ASSETMANAGEINCOME
                                   , FUNDMANAGEINCOME
                                   , INVESTCONSULTINCOME
                                   , RISKMANAGEINCOME
                                   , INVESTMANAGEINCOME
                                   , OTHERAGENCYINCOME
                                   , BROKERAGEEXPENSE
                                   , INVESTBANKEXPENSE
                                   , ASSETMANAGEEXPENSE
                                   , FUNDMANAGEEXPENSE
                                   , INVESTCONSULTEXPENSE
                                   , RISKMANAGEEXPENSE
                                   , INVESTMANAGEEXPENSE
                                   , OTHERAGENCYEXPENSE
                                   , NETFUNDMGTINCOME
                                   , EXTRACTFUTURERISK
                                   , WITHDRAWGUARANTEERESER
                                   , GUARANTCOMPRSRV
                                   , SALESCOST
                                   , OTHEROPERATIONALCOST
                                   , TOTALADMINEXPENSE
                                   , EXPLORATIONCOST
                                   , CREDITIMPAIRMENTP
                                   , ASSETIMPAIRMENTLOSSP
                                FROM ${jy_src_schema}.LC_INCOMESTATEMENTALL"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "BULLETINTYPE", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "IFADJUSTED", "type": "DOUBLE"}, {"name": "IFMERGED", "type": "DOUBLE"}, {"name": "ACCOUNTINGSTANDARDS", "type": "DOUBLE"}, {"name": "ENTERPRISETYPE", "type": "DOUBLE"}, {"name": "TOTALOPERATINGREVENUE", "type": "DOUBLE"}, {"name": "OPERATINGREVENUE", "type": "DOUBLE"}, {"name": "NETINTERESTINCOME", "type": "DOUBLE"}, {"name": "INTERESTINCOME", "type": "DOUBLE"}, {"name": "INTERESTEXPENSE", "type": "DOUBLE"}, {"name": "NETCOMMISSIONINCOME", "type": "DOUBLE"}, {"name": "COMMISSIONINCOME", "type": "DOUBLE"}, {"name": "COMMISSIONEXPENSE", "type": "DOUBLE"}, {"name": "NETPROXYSECUINCOME", "type": "DOUBLE"}, {"name": "NETSUBISSUESECUINCOME", "type": "DOUBLE"}, {"name": "NETTRUSTINCOME", "type": "DOUBLE"}, {"name": "PREMIUMSEARNED", "type": "DOUBLE"}, {"name": "PREMIUMSINCOME", "type": "DOUBLE"}, {"name": "REINSURANCEINCOME", "type": "DOUBLE"}, {"name": "REINSURANCE", "type": "DOUBLE"}, {"name": "UNEARNEDPREMIUMRESERVE", "type": "DOUBLE"}, {"name": "OTHEROPERATINGREVENUE", "type": "DOUBLE"}, {"name": "SPECIALITEMSOR", "type": "DOUBLE"}, {"name": "ADJUSTMENTITEMSOR", "type": "DOUBLE"}, {"name": "TOTALOPERATINGCOST", "type": "DOUBLE"}, {"name": "OPERATINGPAYOUT", "type": "DOUBLE"}, {"name": "REFUNDEDPREMIUMS", "type": "DOUBLE"}, {"name": "COMPENSATIONEXPENSE", "type": "DOUBLE"}, {"name": "AMORTIZATIONEXPENSE", "type": "DOUBLE"}, {"name": "PREMIUMRESERVE", "type": "DOUBLE"}, {"name": "AMORTIZATIONPREMIUMRESERVE", "type": "DOUBLE"}, {"name": "POLICYDIVIDENDPAYOUT", "type": "DOUBLE"}, {"name": "REINSURANCECOST", "type": "DOUBLE"}, {"name": "OPERATINGANDADMINEXPENSE", "type": "DOUBLE"}, {"name": "AMORTIZATIONREINSURANCECOST", "type": "DOUBLE"}, {"name": "INSURANCECOMMISSIONEXPENSE", "type": "DOUBLE"}, {"name": "OTHEROPERATINGCOST", "type": "DOUBLE"}, {"name": "OPERATINGCOST", "type": "DOUBLE"}, {"name": "OPERATINGTAXSURCHARGES", "type": "DOUBLE"}, {"name": "OPERATINGEXPENSE", "type": "DOUBLE"}, {"name": "ADMINISTRATIONEXPENSE", "type": "DOUBLE"}, {"name": "FINANCIALEXPENSE", "type": "DOUBLE"}, {"name": "ASSETIMPAIRMENTLOSS", "type": "DOUBLE"}, {"name": "SPECIALITEMSTOC", "type": "DOUBLE"}, {"name": "ADJUSTMENTITEMSTOC", "type": "DOUBLE"}, {"name": "OTHERNETREVENUE", "type": "DOUBLE"}, {"name": "FAIRVALUECHANGEINCOME", "type": "DOUBLE"}, {"name": "INVESTINCOME", "type": "DOUBLE"}, {"name": "INVESTINCOMEASSOCIATES", "type": "DOUBLE"}, {"name": "EXCHANGEINCOME", "type": "DOUBLE"}, {"name": "OTHERITEMSEFFECTINGOP", "type": "DOUBLE"}, {"name": "ADJUSTEDITEMSEFFECTINGOP", "type": "DOUBLE"}, {"name": "OPERATINGPROFIT", "type": "DOUBLE"}, {"name": "NONOPERATINGINCOME", "type": "DOUBLE"}, {"name": "NONOPERATINGEXPENSE", "type": "DOUBLE"}, {"name": "NONCURRENTASSETSSDEALLOSS", "type": "DOUBLE"}, {"name": "OTHERITEMSEFFECTINGTP", "type": "DOUBLE"}, {"name": "ADJUSTEDITEMSEFFECTINGTP", "type": "DOUBLE"}, {"name": "TOTALPROFIT", "type": "DOUBLE"}, {"name": "INCOMETAXCOST", "type": "DOUBLE"}, {"name": "UNCERTAINEDINVESTMENTLOSSES", "type": "DOUBLE"}, {"name": "OTHERITEMSEFFECTINGNP", "type": "DOUBLE"}, {"name": "ADJUSTEDITEMSEFFECTINGNP", "type": "DOUBLE"}, {"name": "NETPROFIT", "type": "DOUBLE"}, {"name": "NPPARENTCOMPANYOWNERS", "type": "DOUBLE"}, {"name": "MINORITYPROFIT", "type": "DOUBLE"}, {"name": "OTHERITEMSEFFECTINGNPP", "type": "DOUBLE"}, {"name": "ADJUSTEDITEMSEFFECTINGNPP", "type": "DOUBLE"}, {"name": "OTHERCOMPOSITEINCOME", "type": "DOUBLE"}, {"name": "ADJUSTEDITEMSEFFECTINGCI", "type": "DOUBLE"}, {"name": "TOTALCOMPOSITEINCOME", "type": "DOUBLE"}, {"name": "CIPARENTCOMPANYOWNERS", "type": "DOUBLE"}, {"name": "CIMINORITYOWNERS", "type": "DOUBLE"}, {"name": "ADJUSTEDITEMSEFFECTINGPCI", "type": "DOUBLE"}, {"name": "BASICEPS", "type": "DOUBLE"}, {"name": "DILUTEDEPS", "type": "DOUBLE"}, {"name": "SPECIALFIELDREMARK", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "IFCOMPLETE", "type": "DOUBLE"}, {"name": "OCIPARENTCOMPANYOWNERS", "type": "DOUBLE"}, {"name": "OCINOTININCOMESTATEMENT", "type": "DOUBLE"}, {"name": "OCIREMEARSURE", "type": "DOUBLE"}, {"name": "OCIEQUITYNOTINIS", "type": "DOUBLE"}, {"name": "OCIININCOMESTATEMENT", "type": "DOUBLE"}, {"name": "OCIEQUITYINIS", "type": "DOUBLE"}, {"name": "OCIFAIRVALUE", "type": "DOUBLE"}, {"name": "OCITOMATURITYFA", "type": "DOUBLE"}, {"name": "OCICFLOSS", "type": "DOUBLE"}, {"name": "OCIFOREIGNCURRENCYFSA", "type": "DOUBLE"}, {"name": "OCIOTHERS", "type": "DOUBLE"}, {"name": "OCIMINORITYOWNERS", "type": "DOUBLE"}, {"name": "OTHERREVENUE", "type": "DOUBLE"}, {"name": "ASSETDEALINCOME", "type": "DOUBLE"}, {"name": "OPERSUSTCATEG", "type": "DOUBLE"}, {"name": "OPERSUSTNETP", "type": "DOUBLE"}, {"name": "DISCONOPERNETP", "type": "DOUBLE"}, {"name": "OWNERSHIPCATEG", "type": "DOUBLE"}, {"name": "RANDD", "type": "DOUBLE"}, {"name": "CREDITIMPAIRMENTL", "type": "DOUBLE"}, {"name": "NETOPENHEDGEINCOME", "type": "DOUBLE"}, {"name": "INTERESTFINEXP", "type": "DOUBLE"}, {"name": "INTERESTINCOMEFIN", "type": "DOUBLE"}, {"name": "OTHEQUFVCHANGE", "type": "DOUBLE"}, {"name": "CORPORATECRCHANGE", "type": "DOUBLE"}, {"name": "OTHDEBTINVESCHANGE", "type": "DOUBLE"}, {"name": "FINASSETROTHERCI", "type": "DOUBLE"}, {"name": "OTHERDEBTINVESTCIP", "type": "DOUBLE"}, {"name": "PREINSURRSRV", "type": "DOUBLE"}, {"name": "NETCLAIMINCURRED", "type": "DOUBLE"}, {"name": "NETPREMIUMRESERVE", "type": "DOUBLE"}, {"name": "AMORTISEDCOSTINCOME", "type": "DOUBLE"}, {"name": "INFOSOURCECODE", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "SALESREVENUE", "type": "DOUBLE"}, {"name": "OTHEROPERATINGINCOME", "type": "DOUBLE"}, {"name": "GUARANTEEINCOME", "type": "DOUBLE"}, {"name": "BROKERAGEINCOME", "type": "DOUBLE"}, {"name": "INVESTBANKINCOME", "type": "DOUBLE"}, {"name": "ASSETMANAGEINCOME", "type": "DOUBLE"}, {"name": "FUNDMANAGEINCOME", "type": "DOUBLE"}, {"name": "INVESTCONSULTINCOME", "type": "DOUBLE"}, {"name": "RISKMANAGEINCOME", "type": "DOUBLE"}, {"name": "INVESTMANAGEINCOME", "type": "DOUBLE"}, {"name": "OTHERAGENCYINCOME", "type": "DOUBLE"}, {"name": "BROKERAGEEXPENSE", "type": "DOUBLE"}, {"name": "INVESTBANKEXPENSE", "type": "DOUBLE"}, {"name": "ASSETMANAGEEXPENSE", "type": "DOUBLE"}, {"name": "FUNDMANAGEEXPENSE", "type": "DOUBLE"}, {"name": "INVESTCONSULTEXPENSE", "type": "DOUBLE"}, {"name": "RISKMANAGEEXPENSE", "type": "DOUBLE"}, {"name": "INVESTMANAGEEXPENSE", "type": "DOUBLE"}, {"name": "OTHERAGENCYEXPENSE", "type": "DOUBLE"}, {"name": "NETFUNDMGTINCOME", "type": "DOUBLE"}, {"name": "EXTRACTFUTURERISK", "type": "DOUBLE"}, {"name": "WITHDRAWGUARANTEERESER", "type": "DOUBLE"}, {"name": "GUARANTCOMPRSRV", "type": "DOUBLE"}, {"name": "SALESCOST", "type": "DOUBLE"}, {"name": "OTHEROPERATIONALCOST", "type": "DOUBLE"}, {"name": "TOTALADMINEXPENSE", "type": "DOUBLE"}, {"name": "EXPLORATIONCOST", "type": "DOUBLE"}, {"name": "CREDITIMPAIRMENTP", "type": "DOUBLE"}, {"name": "ASSETIMPAIRMENTLOSSP", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_incomestatementall_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_incomestatementall_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_incomestatementall_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_incomestatementall_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_INCOMESTATEMENTALL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_INCOMESTATEMENTALL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_incomestatementall_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_INCOMESTATEMENTALL_PFD PARTITION(P_DT='${p_end_dt}')
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
     , TOTALOPERATINGREVENUE
     , OPERATINGREVENUE
     , NETINTERESTINCOME
     , INTERESTINCOME
     , INTERESTEXPENSE
     , NETCOMMISSIONINCOME
     , COMMISSIONINCOME
     , COMMISSIONEXPENSE
     , NETPROXYSECUINCOME
     , NETSUBISSUESECUINCOME
     , NETTRUSTINCOME
     , PREMIUMSEARNED
     , PREMIUMSINCOME
     , REINSURANCEINCOME
     , REINSURANCE
     , UNEARNEDPREMIUMRESERVE
     , OTHEROPERATINGREVENUE
     , SPECIALITEMSOR
     , ADJUSTMENTITEMSOR
     , TOTALOPERATINGCOST
     , OPERATINGPAYOUT
     , REFUNDEDPREMIUMS
     , COMPENSATIONEXPENSE
     , AMORTIZATIONEXPENSE
     , PREMIUMRESERVE
     , AMORTIZATIONPREMIUMRESERVE
     , POLICYDIVIDENDPAYOUT
     , REINSURANCECOST
     , OPERATINGANDADMINEXPENSE
     , AMORTIZATIONREINSURANCECOST
     , INSURANCECOMMISSIONEXPENSE
     , OTHEROPERATINGCOST
     , OPERATINGCOST
     , OPERATINGTAXSURCHARGES
     , OPERATINGEXPENSE
     , ADMINISTRATIONEXPENSE
     , FINANCIALEXPENSE
     , ASSETIMPAIRMENTLOSS
     , SPECIALITEMSTOC
     , ADJUSTMENTITEMSTOC
     , OTHERNETREVENUE
     , FAIRVALUECHANGEINCOME
     , INVESTINCOME
     , INVESTINCOMEASSOCIATES
     , EXCHANGEINCOME
     , OTHERITEMSEFFECTINGOP
     , ADJUSTEDITEMSEFFECTINGOP
     , OPERATINGPROFIT
     , NONOPERATINGINCOME
     , NONOPERATINGEXPENSE
     , NONCURRENTASSETSSDEALLOSS
     , OTHERITEMSEFFECTINGTP
     , ADJUSTEDITEMSEFFECTINGTP
     , TOTALPROFIT
     , INCOMETAXCOST
     , UNCERTAINEDINVESTMENTLOSSES
     , OTHERITEMSEFFECTINGNP
     , ADJUSTEDITEMSEFFECTINGNP
     , NETPROFIT
     , NPPARENTCOMPANYOWNERS
     , MINORITYPROFIT
     , OTHERITEMSEFFECTINGNPP
     , ADJUSTEDITEMSEFFECTINGNPP
     , OTHERCOMPOSITEINCOME
     , ADJUSTEDITEMSEFFECTINGCI
     , TOTALCOMPOSITEINCOME
     , CIPARENTCOMPANYOWNERS
     , CIMINORITYOWNERS
     , ADJUSTEDITEMSEFFECTINGPCI
     , BASICEPS
     , DILUTEDEPS
     , SPECIALFIELDREMARK
     , UPDATETIME
     , JSID
     , IFCOMPLETE
     , OCIPARENTCOMPANYOWNERS
     , OCINOTININCOMESTATEMENT
     , OCIREMEARSURE
     , OCIEQUITYNOTINIS
     , OCIININCOMESTATEMENT
     , OCIEQUITYINIS
     , OCIFAIRVALUE
     , OCITOMATURITYFA
     , OCICFLOSS
     , OCIFOREIGNCURRENCYFSA
     , OCIOTHERS
     , OCIMINORITYOWNERS
     , OTHERREVENUE
     , ASSETDEALINCOME
     , OPERSUSTCATEG
     , OPERSUSTNETP
     , DISCONOPERNETP
     , OWNERSHIPCATEG
     , RANDD
     , CREDITIMPAIRMENTL
     , NETOPENHEDGEINCOME
     , INTERESTFINEXP
     , INTERESTINCOMEFIN
     , OTHEQUFVCHANGE
     , CORPORATECRCHANGE
     , OTHDEBTINVESCHANGE
     , FINASSETROTHERCI
     , OTHERDEBTINVESTCIP
     , PREINSURRSRV
     , NETCLAIMINCURRED
     , NETPREMIUMRESERVE
     , AMORTISEDCOSTINCOME
     , INFOSOURCECODE
     , INSERTTIME
     , SALESREVENUE
     , OTHEROPERATINGINCOME
     , GUARANTEEINCOME
     , BROKERAGEINCOME
     , INVESTBANKINCOME
     , ASSETMANAGEINCOME
     , FUNDMANAGEINCOME
     , INVESTCONSULTINCOME
     , RISKMANAGEINCOME
     , INVESTMANAGEINCOME
     , OTHERAGENCYINCOME
     , BROKERAGEEXPENSE
     , INVESTBANKEXPENSE
     , ASSETMANAGEEXPENSE
     , FUNDMANAGEEXPENSE
     , INVESTCONSULTEXPENSE
     , RISKMANAGEEXPENSE
     , INVESTMANAGEEXPENSE
     , OTHERAGENCYEXPENSE
     , NETFUNDMGTINCOME
     , EXTRACTFUTURERISK
     , WITHDRAWGUARANTEERESER
     , GUARANTCOMPRSRV
     , SALESCOST
     , OTHEROPERATIONALCOST
     , TOTALADMINEXPENSE
     , EXPLORATIONCOST
     , CREDITIMPAIRMENTP
     , ASSETIMPAIRMENTLOSSP
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_INCOMESTATEMENTALL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_INCOMESTATEMENTALL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_INCOMESTATEMENTALL_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_INCOMESTATEMENTALL_PFD成功"
      exit 0
   fi
fi
