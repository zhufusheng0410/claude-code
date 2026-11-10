#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_FUNDNAME  STRING  COMMENT  '基金名称',
  C_MONEYTYPE  STRING  COMMENT  '币种编号',
  C_MANAGERNAME  STRING  COMMENT  '管理人名称',
  C_TRUSTEECODE  STRING  COMMENT  '托管人编号',
  F_PARVALUE  DECIMAL(16,8)  COMMENT  '基金面值',
  F_ISSUEPRICE  DECIMAL(16,8)  COMMENT  '基金发行价格',
  C_TRUSTEEACCO  STRING  COMMENT  '基金托管帐号',
  D_ISSUEDATE  STRING  COMMENT  '基金发行日期',
  D_SETUPDATE  STRING  COMMENT  '基金成立日期',
  F_MAXBALA  DECIMAL(16,2)  COMMENT  '最高募集金额',
  F_MAXSHARES  DECIMAL(16,2)  COMMENT  '投资者申请份额上限',
  F_MINBALA  DECIMAL(16,2)  COMMENT  '最低募集金额',
  F_MINSHARES  DECIMAL(16,2)  COMMENT  '',
  L_ELIMITDAY  DECIMAL(10,0)  COMMENT  '份额过低期限',
  L_SLIMITDAY  DECIMAL(10,0)  COMMENT  '基金认购期限',
  L_ALIMITDAY  DECIMAL(10,0)  COMMENT  '',
  L_MINCOUNT  DECIMAL(10,0)  COMMENT  '最低开户数量',
  L_CLIMITDAY  DECIMAL(10,0)  COMMENT  '客户过少期限',
  F_MAXALLOT  DECIMAL(9,8)  COMMENT  '超额申购比例',
  F_MAXREDEEM  DECIMAL(9,8)  COMMENT  '巨额赎回比例',
  C_FUNDCHARACTER  STRING  COMMENT  '基金特征',
  C_FUNDSTATUS  STRING  COMMENT  '基金状态',
  C_SUBSCRIBEMODE  STRING  COMMENT  '',
  L_TIMELIMIT  DECIMAL(10,0)  COMMENT  '存续期限',
  L_SUBSCRIBEUNIT  DECIMAL(10,0)  COMMENT  '',
  C_SHARETYPES  STRING  COMMENT  '支持份额分类',
  C_ISSUETYPE  STRING  COMMENT  '基金发行方式',
  F_FACTCOLLECT  DECIMAL(16,2)  COMMENT  '实际募集金额',
  D_FAILUEDATE  STRING  COMMENT  '募集失败日期',
  F_ALLOTRATIO  DECIMAL(9,8)  COMMENT  '基金成立确认比例',
  C_FEERATIOTYPE1  STRING  COMMENT  '费率计算方式1',
  C_FEERATIOTYPE2  STRING  COMMENT  '费率合并方式',
  C_FEETYPE  STRING  COMMENT  '',
  C_EXCEEDPART  STRING  COMMENT  '超额认申购_部分确认',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_FORCEREDEEM  STRING  COMMENT  '强制赎回最低份额标志',
  C_INTERESTDEALTYPE  STRING  COMMENT  '认购利息处理方式',
  F_REDEEMFARERATIO  DECIMAL(5,4)  COMMENT  '',
  F_CHANGEFARERATIO  DECIMAL(5,4)  COMMENT  '',
  F_MANAGERFEE  DECIMAL(6,5)  COMMENT  '管理费计提比例',
  F_RIGHT  DECIMAL(5,4)  COMMENT  '累积权权重',
  C_PROPERTY  STRING  COMMENT  '基金类型',
  D_EVENDATE  STRING  COMMENT  '保本到期日',
  F_TOTALBONUS  DECIMAL(16,8)  COMMENT  '',
  C_CHANGEFREE  STRING  COMMENT  '',
  C_REPORTCODE  STRING  COMMENT  '',
  C_BACKFARECAL  STRING  COMMENT  '后收费用计算方式',
  L_MONEYDATE  DECIMAL(10,0)  COMMENT  '货币基金收益兑付日期',
  L_NETPRECISION  DECIMAL(10,0)  COMMENT  '单位净值长度',
  C_CORPUSCONTENT  STRING  COMMENT  '',
  F_CORPUSRATIO  DECIMAL(5,4)  COMMENT  '',
  C_FARECALTYPE  STRING  COMMENT  '认申购费用计算方式',
  L_LIQUIDATEALLOT  DECIMAL(10,0)  COMMENT  '申购清算天数',
  L_LIQUIDATEREDEEM  DECIMAL(10,0)  COMMENT  '赎回清算天数',
  L_LIQUIDATEBONUS  DECIMAL(10,0)  COMMENT  '分红清算天数',
  L_TASPECIALACCO  DECIMAL(10,0)  COMMENT  'TA专户ID',
  C_FAREPRECISION  STRING  COMMENT  '费用的精度处理方式',
  D_ISSUEENDDATE  STRING  COMMENT  '基金募集结束日期',
  C_FAREBELONGASSET  STRING  COMMENT  '赎回费归基金资产比例方式',
  L_LIQUIDATECHANGE  DECIMAL(10,0)  COMMENT  '转换出清算天数',
  L_LIQUIDATEFAIL  DECIMAL(10,0)  COMMENT  '发行失败清算天数',
  L_LIQUIDATEEND  DECIMAL(10,0)  COMMENT  '清盘清算天数',
  C_SHAREDETAIL  STRING  COMMENT  '赎回份额明细处理',
  C_TRUSTEEBANKNAME  STRING  COMMENT  '',
  C_BOURSETRADEFLAG  STRING  COMMENT  '开通交易所交易标志',
  C_FUNDENGLISHNAME  STRING  COMMENT  '基金英文名',
  L_BANKACCONO  STRING  COMMENT  '托管行银行帐号编号',
  C_CLEANFLAG  STRING  COMMENT  '清算轧差标志',
  C_PRECISION  STRING  COMMENT  '归资产费用的精度处理方式',
  C_UPGRADEFLAG  STRING  COMMENT  '是否参与升降级',
  C_ISDEAL  STRING  COMMENT  '',
  C_FARECLTPRECISION  STRING  COMMENT  '费用的精度处理方式',
  C_BALANCEPRECISION  STRING  COMMENT  '金额的精度处理方式',
  C_SHAREPRECISION  STRING  COMMENT  '份额的精度处理方式',
  C_BONUSPRECISION  STRING  COMMENT  '分红的精度处理方式',
  C_INTERESTPRECISION  STRING  COMMENT  '利息的精度处理方式',
  F_MAXALLOTASSET  DECIMAL(16,2)  COMMENT  '最高基金规模金额',
  F_MAXALLOTSHARES  DECIMAL(16,2)  COMMENT  '最高基金规模份额',
  C_FOREIGNTRUSTEE  STRING  COMMENT  '',
  L_TNCONFIRM  DECIMAL(3,0)  COMMENT  '申请确认天数',
  C_RATIONALLOTSTATUS  STRING  COMMENT  '',
  L_LIQUIDATECHANGEIN  DECIMAL(10,0)  COMMENT  '转换入清算天数',
  C_GRADETYPE  STRING  COMMENT  '级差的处理方式',
  C_EXCESSALLOT  STRING  COMMENT  '超额申购判断',
  C_EXTRADEALTYPE  STRING  COMMENT  '超额申购的处理模式',
  ISZDPRECALCULATEFEE  STRING  COMMENT  '',
  L_MAXCOUNT  DECIMAL(10,0)  COMMENT  '最大账户数(户)',
  C_ORDERMODE  STRING  COMMENT  '户数限制处理方式',
  D_ACCOUTLASTDATE  STRING  COMMENT  '',
  D_ASSETLASTDATE  STRING  COMMENT  '',
  C_ASSETTYPE  STRING  COMMENT  '资产过低判断类型',
  F_MINASSET  DECIMAL(16,2)  COMMENT  '最低资产限额',
  C_INTERESTTYPE  STRING  COMMENT  '利率类型',
  C_NAVPUBLISHDAY  STRING  COMMENT  '净值公布日',
  C_INTERESTINCLUDEFARE  STRING  COMMENT  '利息计算是否含费',
  C_UNRESERVEREDEEMTYPE  STRING  COMMENT  '',
  C_RESERVEREDEEMTYPE  STRING  COMMENT  '',
  C_RAISETYPE  STRING  COMMENT  '',
  C_CFMFREQUENCY  STRING  COMMENT  '封闭期清算频率',
  D_LASTINPUTDATE  STRING  COMMENT  '',
  D_LASTINPUTTIME  STRING  COMMENT  '最后导入时间',
  C_RDFARECACL  STRING  COMMENT  '',
  C_CHECKSHARE  STRING  COMMENT  '行情导入是否校验份额',
  C_FUNDFARETYPE  STRING  COMMENT  '',
  C_MODIFYHISBONUSTYPE  STRING  COMMENT  '',
  C_CHECKBEFOREADJUST  STRING  COMMENT  '',
  C_NAVEPUBLISHFREQUENCY  STRING  COMMENT  '净值公布频率',
  C_CONTRACTTYPE  STRING  COMMENT  '合同类型',
  C_IMPROPERRDMTRDFEE  STRING  COMMENT  '',
  F_MAXADDBAL  DECIMAL(16,2)  COMMENT  '',
  C_DECMANAGEFARE  STRING  COMMENT  '',
  C_FULLCODE  STRING  COMMENT  '专户代码',
  L_MINIHOLDDAYS  DECIMAL(10,0)  COMMENT  '赎回最少持有天/月数',
  C_INTERFACECODE  STRING  COMMENT  '',
  L_YEARDAYS  DECIMAL(3,0)  COMMENT  '尾随佣金年天数',
  C_FUNDCHGRGDATE  STRING  COMMENT  '',
  C_UNTRDRGDATE  STRING  COMMENT  '',
  C_COMPSHAREDETAIL  STRING  COMMENT  '',
  C_MINSHAREDEALTYPE  STRING  COMMENT  '',
  L_HINTENDDAY  DECIMAL(4,0)  COMMENT  '到期前n天提醒',
  C_EXPATNOTOPENDAYS  STRING  COMMENT  '',
  C_YIELDPRECISION  STRING  COMMENT  '收益率的精度处理方式',
  F_MAXACCUADDBAL  DECIMAL(16,2)  COMMENT  '',
  C_ISINNOVATECLOSEFUND  STRING  COMMENT  '',
  C_SHARECHECKPRECISION  STRING  COMMENT  '',
  D_CONTRACTBEGDATE  STRING  COMMENT  '',
  F_LARGETRADEBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_LARGETRADERATIO  DECIMAL(5,4)  COMMENT  '',
  C_RGRADETYPE  STRING  COMMENT  '',
  L_PERIODS  DECIMAL(4,0)  COMMENT  '当前保本期数',
  C_ISALLFAILEDSAMEREQTIME  STRING  COMMENT  '',
  F_VASTASSET  DECIMAL(16,2)  COMMENT  '',
  C_SUBRATIOMODE  STRING  COMMENT  '末日比例配售确认方式',
  C_CMINSHARESDEALTYPE  STRING  COMMENT  '',
  C_PUBLISHENDNAV  STRING  COMMENT  '',
  C_TWICEJUDGE  STRING  COMMENT  '首次/追加投资的判断依据',
  C_RFIRSTSTEPLIMIT  STRING  COMMENT  '',
  F_INTERESTRATE  DECIMAL(6,5)  COMMENT  '',
  L_INTERESTSTARTDAYS  DECIMAL(10,0)  COMMENT  '',
  D_INTERESTENDDATE  STRING  COMMENT  '',
  C_CLTINTERESTMODE  STRING  COMMENT  '',
  D_LISTINGDATE  STRING  COMMENT  '',
  L_SHORTREDEEMDAYS  DECIMAL(4,0)  COMMENT  '',
  C_EXCEEDFLAG  STRING  COMMENT  '巨额赎回处理标志',
  C_MODIFYBONUSFLAG  STRING  COMMENT  '',
  C_INBOURSETOOUTCALCFARETYPE  STRING  COMMENT  '',
  C_FUSIONTYPE  STRING  COMMENT  '',
  C_FUSIONID  STRING  COMMENT  '',
  C_TAILDECIMAL  STRING  COMMENT  '收益尾差处理方式',
  F_CHANGENEGATIVERATIO  DECIMAL(16,4)  COMMENT  '',
  C_SHORTCYCLEFINANCE  STRING  COMMENT  '',
  C_INCOMEJOINASSIGN  STRING  COMMENT  '',
  C_INCOMEINTOSHARE  STRING  COMMENT  '',
  C_CLERKLIMIT  STRING  COMMENT  '',
  D_CLERKLIMITSTARTDATE  STRING  COMMENT  '',
  C_CLERKBONUSSHARELIMIT  STRING  COMMENT  '',
  C_OPENCYCLE  STRING  COMMENT  '',
  D_STARTOPENDAY  STRING  COMMENT  '',
  D_ENDOPENDAY  STRING  COMMENT  '',
  C_ACNTLMTDEALMODE  STRING  COMMENT  '',
  C_ALLOTCALINTERST  STRING  COMMENT  '',
  C_ALLOWPARTREDEEM  STRING  COMMENT  '允许部分赎回',
  C_CANEARLYRDM  STRING  COMMENT  '',
  C_CUSTOMERMANAGER  STRING  COMMENT  '',
  C_DEDUCTSCHEMECODE  STRING  COMMENT  '',
  C_EARLYEXITFEECALC  STRING  COMMENT  '违约退出罚金计算方式',
  C_EARLYRDMCTRLBYSTATUS  STRING  COMMENT  '违约赎回受产品状态影响',
  C_EXITALLOT  STRING  COMMENT  '份额完全退出后允许再次申购',
  C_EXPNAVBYFQY  STRING  COMMENT  '',
  C_FARECALCULATETYPE  STRING  COMMENT  '',
  C_FINANCETYPE  STRING  COMMENT  '',
  C_FIXEDDIVIDWAY  STRING  COMMENT  '是否固定分红方式',
  C_FUNDDAYEXPDAY  STRING  COMMENT  '',
  C_FUNDENDCALCRDMFEE  STRING  COMMENT  '',
  C_FUNDENDMODE  STRING  COMMENT  '',
  C_FUNDENDSENDMODE  STRING  COMMENT  '',
  C_FUNDRISK  STRING  COMMENT  '',
  C_GRADEBASE  STRING  COMMENT  '',
  C_ISBOUNDED  STRING  COMMENT  '',
  C_LIMITMODE  STRING  COMMENT  '',
  C_LIQUIDATIONSAVEDEDUCT  STRING  COMMENT  '',
  C_MAXREDEEMDEAL  STRING  COMMENT  '',
  C_MINBALALIMITISCONFIRM  STRING  COMMENT  '',
  C_QRYFREQTYPE  STRING  COMMENT  '',
  C_REDEEMTWICEMETHOD  STRING  COMMENT  '',
  C_SALETYPE  STRING  COMMENT  '',
  C_TALAUNCHDEPENDSTATUS  STRING  COMMENT  'TA发起的赎回业务受行情状态影响',
  C_TEMPLATEID  STRING  COMMENT  '',
  C_USEINOPENDAY  STRING  COMMENT  '开放期申购份额是否可用',
  C_WHETHERDIVID  STRING  COMMENT  '是否分红',
  D_CHECKUPDATE  STRING  COMMENT  '',
  D_EXPNAVAFSETUP  STRING  COMMENT  '',
  D_STARTDATE  STRING  COMMENT  '生效日期',
  F_DEDUCTRATIO  DECIMAL(5,4)  COMMENT  '',
  F_FUNDENDAGIO  DECIMAL(10,9)  COMMENT  '',
  F_LIQASSET  DECIMAL(16,2)  COMMENT  '',
  F_PR0  DECIMAL(7,4)  COMMENT  '',
  F_REDEEMPROMPTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_TRUSTEEFEE  DECIMAL(5,4)  COMMENT  '',
  L_BONUSALERTDAYS  DECIMAL(3,0)  COMMENT  '',
  L_BONUSFQY  DECIMAL(2,0)  COMMENT  '',
  L_INFORMDAYS  DECIMAL(2,0)  COMMENT  '',
  L_MINHOLDDATE  DECIMAL(4,0)  COMMENT  '',
  L_OPENDAYINFORMDAYS  DECIMAL(3,0)  COMMENT  '',
  L_QRYDAYSLTD  DECIMAL(2,0)  COMMENT  '',
  L_ZHALLOTEXPDAYS  DECIMAL(10,0)  COMMENT  '',
  L_ZHALLOTLIQDAYS  DECIMAL(10,0)  COMMENT  '',
  L_ZHREDEEMEXPDAYS  DECIMAL(10,0)  COMMENT  '',
  L_ZHREDEEMLIQDAYS  DECIMAL(10,0)  COMMENT  '',
  C_SCALECUSTMODE  STRING  COMMENT  '',
  F_PARDONACCOMINBALA  DECIMAL(16,2)  COMMENT  '不受账户数控制最低金额',
  C_DSRDMFAREBELONGFUND  STRING  COMMENT  '',
  C_KEYACCOMODE  STRING  COMMENT  '',
  C_SHORTCFRDMBOOKING  STRING  COMMENT  '',
  C_REGISTERATT0  STRING  COMMENT  '',
  C_MANAGERCODE  STRING  COMMENT  '',
  C_LONGRATIONFUND  STRING  COMMENT  '',
  C_T0LIQUDIATE  STRING  COMMENT  '是否T+0清算',
  C_PURBALADEALTYPE  STRING  COMMENT  '',
  C_MINSHAREADDINCOME  STRING  COMMENT  '赎回最低账面金额含收益',
  C_RDMMINSHARECHK  STRING  COMMENT  '',
  C_NAVSENDTOZDTA  STRING  COMMENT  '',
  C_VASTREDEEMDEALTYPE  STRING  COMMENT  '',
  F_MINSCALESHARES  DECIMAL(16,2)  COMMENT  '',
  L_LONGRDMFREEDAYS  DECIMAL(10,0)  COMMENT  '',
  C_SUBDIFFERNEWOLDCUST  STRING  COMMENT  '',
  C_ISBANISHNETREDEEM  STRING  COMMENT  '',
  C_ISOTC  STRING  COMMENT  '是否OTC产品',
  C_OTCFUNDTYPE  STRING  COMMENT  'OTC产品类别',
  C_RDMFARERATIOTYPE  STRING  COMMENT  '',
  C_CASHUNIONSTOCK  STRING  COMMENT  '',
  C_MANGERTYPE  STRING  COMMENT  '',
  C_PHBUSINESS  STRING  COMMENT  '',
  C_SHBOURSEMONEYMARKET  STRING  COMMENT  '',
  C_OTCFUNDNO  STRING  COMMENT  '',
  D_STOCKISSUEENDDATE  STRING  COMMENT  '',
  D_STOCKSUBDATE  STRING  COMMENT  '',
  C_SUBACCO  STRING  COMMENT  '',
  C_SUBSEAT  STRING  COMMENT  '',
  C_ETFACCO  STRING  COMMENT  '',
  C_ETFSEAT  STRING  COMMENT  '',
  F_MINSHARE  DECIMAL(16,2)  COMMENT  '',
  C_STOCKFARECALTYPE  STRING  COMMENT  '',
  C_SPANMARKETFLAG  STRING  COMMENT  '',
  C_DSFARECALTYPE  STRING  COMMENT  '',
  F_SUBRANGE  DECIMAL(16,2)  COMMENT  '',
  C_ISSTOCKREDEMPTION  STRING  COMMENT  '',
  D_INTERESTDATE  STRING  COMMENT  '',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_ISSTRUCTUREDPRODUCT  STRING  COMMENT  '',
  C_PRIORFUNDCODE  STRING  COMMENT  '',
  F_CAPITALRATIO  DECIMAL(16,4)  COMMENT  '资金配比',
  C_CHECKNAVSERVICEFARE  STRING  COMMENT  '',
  C_EXPPHMARKET  STRING  COMMENT  '',
  C_ISPUBLISHTOTALVALUE  STRING  COMMENT  '行情的累计净值是否从NAV文件中读取',
  C_SHLOF  STRING  COMMENT  '',
  C_FUNDFARECALCTYPE  STRING  COMMENT  '',
  C_ISCHKBOOKINGTRADE  STRING  COMMENT  '',
  C_NEEDBOOKINGBUSINTYPE  STRING  COMMENT  '',
  C_HASBOOKINGDEALTYPE  STRING  COMMENT  '',
  C_NOTBOOKINGDEALTYPE  STRING  COMMENT  '',
  C_FUNDOPENTYPE  STRING  COMMENT  '',
  C_ALLOWMARKETTRADE  STRING  COMMENT  '',
  C_ISEARLYLIQUIDFLAG  STRING  COMMENT  '',
  C_ISYUEBAO  STRING  COMMENT  '是否为余额理财基金',
  C_NAVPUBLISHMONTH  STRING  COMMENT  '净值公布月',
  C_RDMFREEINVEST  STRING  COMMENT  '',
  C_FINALFEERATIOLIMIT  STRING  COMMENT  '',
  C_ISSLBAO  STRING  COMMENT  '',
  C_OTCNEEDPROFIT  STRING  COMMENT  'OTC份额转让是否业绩提成',
  C_OTCPROFITNETVALUE  STRING  COMMENT  '',
  C_EVERYDAYCHANGE  STRING  COMMENT  '',
  C_NEWINCOMEISCHANGE  STRING  COMMENT  '当日新增收益是否参与兑付',
  C_FUNDTYPECLASS  STRING  COMMENT  '',
  C_INCOMECHANGETYPE  STRING  COMMENT  '',
  C_AUTODEALCLASSFUNDRDM  STRING  COMMENT  '',
  C_INCOMERATIOTYPE  STRING  COMMENT  '',
  C_REINVESTDEUDCTMODE  STRING  COMMENT  '',
  C_RPTISSEND  STRING  COMMENT  '是否上报证监会报表',
  F_CLERKMAXBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_CLERKMAXRATIO  DECIMAL(9,8)  COMMENT  '',
  C_DAYINVESTSHAREDETAIL  STRING  COMMENT  '',
  C_VASTAMOUNTTYPE  STRING  COMMENT  '',
  C_INCOMEINTOSHARETZJY  STRING  COMMENT  '',
  C_NGTVSPLITRDCTYPEDEFAULT  STRING  COMMENT  '',
  C_PSTVSPLITDTLDEALDEFAULT  STRING  COMMENT  '',
  C_SHAREBATCHMODELDEFAULT  STRING  COMMENT  '',
  C_ISSPLITADJUSTSENDTOFA  STRING  COMMENT  '拆分引起份额调整数据是否导出给估值/托管行',
  C_NGTSPLTRDMCFMTYPE  STRING  COMMENT  '',
  C_PSTSPLTRDMCFMTYPE  STRING  COMMENT  '',
  C_SHORTOPENFUNDTYPE  STRING  COMMENT  '',
  D_DISTRIBUTEDATE  STRING  COMMENT  '红利发放日期',
  C_CHKSHRINCNEWINCOME  STRING  COMMENT  '',
  C_PROFITREFLECTTYPE  STRING  COMMENT  '',
  C_RISKCLASS  STRING  COMMENT  '',
  C_SPLITSUPPORTDEDUCT  STRING  COMMENT  '',
  C_ISSZQUOTEREPSPEFUND  STRING  COMMENT  '',
  C_PROFITHOLD  STRING  COMMENT  '',
  C_ACCOINCOMEDEALTYPE  STRING  COMMENT  '账户收益分配方式',
  C_CLEARINGBANKNAME  STRING  COMMENT  '',
  C_CLOSEDAYFUNDSTATUS  STRING  COMMENT  '',
  C_SUPPORTSTAGE  STRING  COMMENT  '',
  C_SPLITTAILPRECISION  STRING  COMMENT  '',
  C_SERVICEFARETYPE  STRING  COMMENT  '销售服务费计算方式',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  C_LARGECHANGELIMIT  STRING  COMMENT  '是否包含转换入',
  C_ISENDOWFIXRATE  STRING  COMMENT  '',
  F_ENDOWFIXFARE  DECIMAL(10,2)  COMMENT  '',
  C_SHPROVISIONSACCO  STRING  COMMENT  '',
  C_SZPROVISIONSACCO  STRING  COMMENT  '',
  C_ISSHREALTIMEMONETARY  STRING  COMMENT  '',
  L_AGELIMITTRADE  DECIMAL(10,0)  COMMENT  '',
  C_BEAUTIFULINVEST  STRING  COMMENT  '',
  C_LARGELIMITOLDCUST  STRING  COMMENT  '',
  C_ZCBFUNDCODE  STRING  COMMENT  '',
  C_FOREIGNCURRENCYFUNDFLAG  STRING  COMMENT  '是否为外币基金',
  F_INCOMEUNITPRECISION  DECIMAL(10,0)  COMMENT  '',
  C_ISEXPKJDATA  STRING  COMMENT  '',
  C_EXPTZJYSETUPDATA  STRING  COMMENT  '投资交易导出成立数据',
  D_CHDATE  STRING  COMMENT  '指定收益结转日期',
  C_CLASSAMTCTLMODE  STRING  COMMENT  '',
  C_OUTPROPERTY  STRING  COMMENT  '对外公告基金类型',
  C_INVESTMERGERDETAIL  STRING  COMMENT  '',
  C_SZBOURSEQPSTATUS  STRING  COMMENT  '',
  C_PROFITRETAINTRUSTEE  STRING  COMMENT  '',
  F_ENDOWREDEEMAGIO  DECIMAL(5,4)  COMMENT  '',
  C_REDEEMHOLDLIMITTYPE  STRING  COMMENT  '',
  C_SUSPENDTRADEEXPRULE  STRING  COMMENT  '',
  C_FUNDOPENBALINC  STRING  COMMENT  '',
  C_NOSHRALLOTLIMITTYPE  STRING  COMMENT  '',
  D_SUBSHAREDEDUCTBEGDATE  STRING  COMMENT  '',
  F_PARDONACCOMINBALAHIS  DECIMAL(16,2)  COMMENT  '',
  C_OTCCHGSHAREDEALTYPE  STRING  COMMENT  '',
  C_CHGONLYFUNDFARE  STRING  COMMENT  '',
  C_TODAYHASSETUPDATA  STRING  COMMENT  '',
  D_LASTALLOTDATE  STRING  COMMENT  '',
  C_SPREDEEMDEAL  STRING  COMMENT  '赎回后资产低于最低保有金额',
  C_SUBTACALCULATEFEE  STRING  COMMENT  '',
  C_LARGETRADEFILTERDS  STRING  COMMENT  '',
  C_BOURSESETUPED  STRING  COMMENT  '',
  C_ISTENPAY  STRING  COMMENT  '',
  C_FUNDISINCODE  STRING  COMMENT  'ISIN编码',
  C_CALRDMFARETYPE  STRING  COMMENT  '',
  C_TOTALNETVALUEBYNAV  STRING  COMMENT  '',
  C_NEEDDATECALCBYZD  STRING  COMMENT  '',
  C_MINHOLDUNIT  STRING  COMMENT  '',
  C_NOTSETALLFUNDAGENCY  STRING  COMMENT  '',
  F_STANALLOTRATIO  DECIMAL(6,5)  COMMENT  '',
  F_STANRDMRATIO  DECIMAL(6,5)  COMMENT  '',
  C_EARLYRDMFUNDDAY  STRING  COMMENT  '',
  C_VASTMERGCHECKTYPE  STRING  COMMENT  '',
  C_RDMLIMITISPROFIT  STRING  COMMENT  '',
  F_PLEDGEDPERCENT  DECIMAL(9,8)  COMMENT  '',
  C_FUNDFEERATIOLIMIT  STRING  COMMENT  '',
  C_ISEXPKFFUNDDAY  STRING  COMMENT  '',
  C_FUNDSHORTNAME  STRING  COMMENT  '基金简称',
  C_SZSTOCKACCOUNT  STRING  COMMENT  '深圳股票账户',
  C_SHSTOCKACCOUNT  STRING  COMMENT  '上海股票账户',
  C_ISCALCRDMFEE  STRING  COMMENT  '',
  C_ISCROSSTAGRADEFUND  STRING  COMMENT  '',
  C_MAXAGIODEALTYPE  STRING  COMMENT  '',
  F_BROKERAGERATIO  DECIMAL(9,6)  COMMENT  '',
  C_CHANGENEGATIVE  STRING  COMMENT  '',
  C_ISRDMBYALLOT  STRING  COMMENT  '',
  C_VASTREDEEMCALTYPE  STRING  COMMENT  '',
  C_ISHKPRODUCT  STRING  COMMENT  '是否在香港销售',
  C_ZHFUNDTYPE  STRING  COMMENT  '专户产品类型',
  C_SERVICERATIOTYPE  STRING  COMMENT  '',
  F_SERVICERATIO  DECIMAL(7,6)  COMMENT  '销售服务费率',
  L_SERVICEDAYS  DECIMAL(4,0)  COMMENT  '',
  C_REINVCALREDEEMFEE  STRING  COMMENT  '',
  C_REDEEMFEETYPE  STRING  COMMENT  '',
  F_NAVWAVEWARNING  DECIMAL(16,8)  COMMENT  '',
  C_CLERKFREE  STRING  COMMENT  '',
  F_MAINAGCTAILRATIO  DECIMAL(7,6)  COMMENT  '',
  C_SUBDIFFERNEWOLDMODE  STRING  COMMENT  '',
  C_CLERKFREETYPE  STRING  COMMENT  '',
  D_INVESTDATE  STRING  COMMENT  '',
  C_INCLUDEPURCHASE  STRING  COMMENT  '',
  C_NOUPGRADEAGENCY  STRING  COMMENT  '',
  C_SENDLIQDATA  STRING  COMMENT  '',
  C_ISALONEFUND  STRING  COMMENT  '',
  C_SHLOFSHRIN2OUTREGMODE  STRING  COMMENT  '',
  C_KFEXPSHRDTLRULE  STRING  COMMENT  '',
  D_QUARTER  STRING  COMMENT  '',
  F_LASTINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  C_SPLTRDMRATIOCFMCONTCHG  STRING  COMMENT  '',
  C_APPOINTTRANSFER  STRING  COMMENT  '',
  C_ISFIRSTDEALFUND  STRING  COMMENT  '',
  C_SZLOFNEW  STRING  COMMENT  '',
  C_BONUSREALBALBYZD  STRING  COMMENT  '',
  D_ESTABLISHMENTDATE  STRING  COMMENT  '',
  C_INCOMEDIVDETAILFUND  STRING  COMMENT  '',
  C_FUNDSTATUSTOPAY  STRING  COMMENT  '',
  C_FOFCALCFAREMODE  STRING  COMMENT  '',
  C_PRECHGSTATUS  STRING  COMMENT  '',
  F_RDMTHRESHOLD  DECIMAL(9,8)  COMMENT  '',
  C_RDMREINVESTSHR  STRING  COMMENT  '',
  C_REINVESTMODE  STRING  COMMENT  '',
  C_FIRSTLIMITINCLUDECHG  STRING  COMMENT  '',
  C_EXPJZBFDATA  STRING  COMMENT  '',
  C_CENTRALIZETYPE  STRING  COMMENT  '',
  C_FORMALFUNDCODE  STRING  COMMENT  '',
  F_LEVERAGEMULTIPLE  DECIMAL(10,4)  COMMENT  '',
  C_INVESTADNAME  STRING  COMMENT  '',
  C_INVESTADBUSCODE  STRING  COMMENT  '',
  C_INVESTADMANCODE  STRING  COMMENT  '',
  C_NGVSPLITUPDATECOSTPRICE  STRING  COMMENT  '',
  C_MAINFUNDCODE  STRING  COMMENT  '',
  C_CLASSFLAG  STRING  COMMENT  '',
  C_PRIORFLAG  STRING  COMMENT  '',
  F_PRIORSEQUENCE  DECIMAL(2,0)  COMMENT  '',
  C_FUNDMANAGERCODE  STRING  COMMENT  '',
  C_LOFINCALFAREBYHOLD  STRING  COMMENT  '',
  C_LOFINCALCFUNDFAREBYHOLD  STRING  COMMENT  '',
  C_LOFINDEALDETAIL  STRING  COMMENT  '',
  F_ACCORDMRATIO  DECIMAL(5,4)  COMMENT  '',
  C_ISCHECKSHAREASNETDATE  STRING  COMMENT  '',
  C_RDMDEALTYPE  STRING  COMMENT  '',
  C_LARGEEXCEEDPART  STRING  COMMENT  '',
  F_NAVCHANGLIMIT  DECIMAL(9,6)  COMMENT  '',
  F_LEVERAGERATE  DECIMAL(16,4)  COMMENT  '',
  C_EXPSHARETATIO  STRING  COMMENT  '',
  C_SALESTATORIBALATYPE  STRING  COMMENT  '',
  C_DELAYRDMDEALTYPE  STRING  COMMENT  '',
  C_TRDWHITELIST  STRING  COMMENT  '',
  C_EXP67HIDEFUNDTOTAL  STRING  COMMENT  '',
  C_FUNDASSORTMENT  STRING  COMMENT  '',
  C_HINTNOTIMPNAV  STRING  COMMENT  '',
  C_LARGETRADELIMITIDTYPE  STRING  COMMENT  '',
  C_FOREIGNCURRENCYFARERATE  STRING  COMMENT  '',
  C_CHECKCUSTMAXBALATYPE  STRING  COMMENT  '',
  C_REDEEMSPLITSHARES  STRING  COMMENT  '',
  C_PRIVATEFOF  STRING  COMMENT  '',
  C_EQUITYSUBAGCMERGECTL  STRING  COMMENT  '',
  C_LARGELIMITBYCNCW  STRING  COMMENT  '',
  F_ORILASTINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  D_ORIQUARTER  STRING  COMMENT  '',
  C_SOURCESOFFUNDSRPT  STRING  COMMENT  '',
  D_LARGETRADEBEGIN  STRING  COMMENT  '',
  D_LARGETRADEEND  STRING  COMMENT  '',
  C_STANDARDBONDCODE  STRING  COMMENT  '',
  C_FORCERDMJUDGETYPE  STRING  COMMENT  '',
  C_CHECKMINCOUNT  STRING  COMMENT  '',
  C_MANAGERFAREFREE  STRING  COMMENT  '',
  L_MFAREFREEHOLD  DECIMAL(10,0)  COMMENT  '',
  C_MFAREFREEHOLDUNIT  STRING  COMMENT  '',
  C_CLOSEDTYPE  STRING  COMMENT  '',
  F_CLOSEDLENGTH  DECIMAL(16,2)  COMMENT  '',
  C_CLOSEDUNIT  STRING  COMMENT  '',
  C_HOLDTERMLIMITDATERANGE  STRING  COMMENT  '',
  C_HOLDTERMLIMITMONTHLY  STRING  COMMENT  '',
  C_LARGETRADELIMITTYPE  STRING  COMMENT  '',
  D_DEADLINE  STRING  COMMENT  '',
  C_CHECKCUSTMINBALA  STRING  COMMENT  '',
  C_FORCERDMINCALLOT  STRING  COMMENT  '',
  C_ENDOWFIXAGIO  STRING  COMMENT  '',
  C_CHECKACCOMINCOUNT  STRING  COMMENT  '',
  C_IACALCFAREMODE  STRING  COMMENT  '',
  C_AMLLIMIT  STRING  COMMENT  '',
  C_EXPKFFUNDDAYBYPUBDAY  STRING  COMMENT  '',
  C_SIDEBAGFLAG  STRING  COMMENT  '',
  C_ISPUBLICFUND  STRING  COMMENT  '',
  F_FACTTOTALBONUS  DECIMAL(17,14)  COMMENT  '',
  C_FORCERDMDEALTYPE  STRING  COMMENT  '',
  C_REDEEMFAREBYINCOME  STRING  COMMENT  '',
  F_RDMBYINCOMERATIO  DECIMAL(9,8)  COMMENT  '',
  C_EXCCHANGESAMERATIO  STRING  COMMENT  '',
  C_SHOUTERBOURSETRANSFER  STRING  COMMENT  '',
  F_MAXADDBALOPENDAY  DECIMAL(16,2)  COMMENT  '',
  C_PROFITNOHOLDLIMIT  STRING  COMMENT  '',
  C_ALLRDMCHECKMODE  STRING  COMMENT  '',
  D_JUDGEINVESTED  STRING  COMMENT  '',
  C_FUNDOUTERBOURSETRANSFER  STRING  COMMENT  '',
  C_AOPCTLSCALEFUNC  STRING  COMMENT  ''
)
COMMENT '基金基本信息'
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , C_FUNDNAME
                                   , C_MONEYTYPE
                                   , C_MANAGERNAME
                                   , C_TRUSTEECODE
                                   , F_PARVALUE
                                   , F_ISSUEPRICE
                                   , C_TRUSTEEACCO
                                   , D_ISSUEDATE
                                   , D_SETUPDATE
                                   , F_MAXBALA
                                   , F_MAXSHARES
                                   , F_MINBALA
                                   , F_MINSHARES
                                   , L_ELIMITDAY
                                   , L_SLIMITDAY
                                   , L_ALIMITDAY
                                   , L_MINCOUNT
                                   , L_CLIMITDAY
                                   , F_MAXALLOT
                                   , F_MAXREDEEM
                                   , C_FUNDCHARACTER
                                   , C_FUNDSTATUS
                                   , C_SUBSCRIBEMODE
                                   , L_TIMELIMIT
                                   , L_SUBSCRIBEUNIT
                                   , C_SHARETYPES
                                   , C_ISSUETYPE
                                   , F_FACTCOLLECT
                                   , D_FAILUEDATE
                                   , F_ALLOTRATIO
                                   , C_FEERATIOTYPE1
                                   , C_FEERATIOTYPE2
                                   , C_FEETYPE
                                   , C_EXCEEDPART
                                   , C_BONUSTYPE
                                   , C_FORCEREDEEM
                                   , C_INTERESTDEALTYPE
                                   , F_REDEEMFARERATIO
                                   , F_CHANGEFARERATIO
                                   , F_MANAGERFEE
                                   , F_RIGHT
                                   , C_PROPERTY
                                   , D_EVENDATE
                                   , F_TOTALBONUS
                                   , C_CHANGEFREE
                                   , C_REPORTCODE
                                   , C_BACKFARECAL
                                   , L_MONEYDATE
                                   , L_NETPRECISION
                                   , C_CORPUSCONTENT
                                   , F_CORPUSRATIO
                                   , C_FARECALTYPE
                                   , L_LIQUIDATEALLOT
                                   , L_LIQUIDATEREDEEM
                                   , L_LIQUIDATEBONUS
                                   , L_TASPECIALACCO
                                   , C_FAREPRECISION
                                   , D_ISSUEENDDATE
                                   , C_FAREBELONGASSET
                                   , L_LIQUIDATECHANGE
                                   , L_LIQUIDATEFAIL
                                   , L_LIQUIDATEEND
                                   , C_SHAREDETAIL
                                   , C_TRUSTEEBANKNAME
                                   , C_BOURSETRADEFLAG
                                   , C_FUNDENGLISHNAME
                                   , L_BANKACCONO
                                   , C_CLEANFLAG
                                   , C_PRECISION
                                   , C_UPGRADEFLAG
                                   , C_ISDEAL
                                   , C_FARECLTPRECISION
                                   , C_BALANCEPRECISION
                                   , C_SHAREPRECISION
                                   , C_BONUSPRECISION
                                   , C_INTERESTPRECISION
                                   , F_MAXALLOTASSET
                                   , F_MAXALLOTSHARES
                                   , C_FOREIGNTRUSTEE
                                   , L_TNCONFIRM
                                   , C_RATIONALLOTSTATUS
                                   , L_LIQUIDATECHANGEIN
                                   , C_GRADETYPE
                                   , C_EXCESSALLOT
                                   , C_EXTRADEALTYPE
                                   , ISZDPRECALCULATEFEE
                                   , L_MAXCOUNT
                                   , C_ORDERMODE
                                   , D_ACCOUTLASTDATE
                                   , D_ASSETLASTDATE
                                   , C_ASSETTYPE
                                   , F_MINASSET
                                   , C_INTERESTTYPE
                                   , C_NAVPUBLISHDAY
                                   , C_INTERESTINCLUDEFARE
                                   , C_UNRESERVEREDEEMTYPE
                                   , C_RESERVEREDEEMTYPE
                                   , C_RAISETYPE
                                   , C_CFMFREQUENCY
                                   , D_LASTINPUTDATE
                                   , D_LASTINPUTTIME
                                   , C_RDFARECACL
                                   , C_CHECKSHARE
                                   , C_FUNDFARETYPE
                                   , C_MODIFYHISBONUSTYPE
                                   , C_CHECKBEFOREADJUST
                                   , C_NAVEPUBLISHFREQUENCY
                                   , C_CONTRACTTYPE
                                   , C_IMPROPERRDMTRDFEE
                                   , F_MAXADDBAL
                                   , C_DECMANAGEFARE
                                   , C_FULLCODE
                                   , L_MINIHOLDDAYS
                                   , C_INTERFACECODE
                                   , L_YEARDAYS
                                   , C_FUNDCHGRGDATE
                                   , C_UNTRDRGDATE
                                   , C_COMPSHAREDETAIL
                                   , C_MINSHAREDEALTYPE
                                   , L_HINTENDDAY
                                   , C_EXPATNOTOPENDAYS
                                   , C_YIELDPRECISION
                                   , F_MAXACCUADDBAL
                                   , C_ISINNOVATECLOSEFUND
                                   , C_SHARECHECKPRECISION
                                   , D_CONTRACTBEGDATE
                                   , F_LARGETRADEBALANCE
                                   , F_LARGETRADERATIO
                                   , C_RGRADETYPE
                                   , L_PERIODS
                                   , C_ISALLFAILEDSAMEREQTIME
                                   , F_VASTASSET
                                   , C_SUBRATIOMODE
                                   , C_CMINSHARESDEALTYPE
                                   , C_PUBLISHENDNAV
                                   , C_TWICEJUDGE
                                   , C_RFIRSTSTEPLIMIT
                                   , F_INTERESTRATE
                                   , L_INTERESTSTARTDAYS
                                   , D_INTERESTENDDATE
                                   , C_CLTINTERESTMODE
                                   , D_LISTINGDATE
                                   , L_SHORTREDEEMDAYS
                                   , C_EXCEEDFLAG
                                   , C_MODIFYBONUSFLAG
                                   , C_INBOURSETOOUTCALCFARETYPE
                                   , C_FUSIONTYPE
                                   , C_FUSIONID
                                   , C_TAILDECIMAL
                                   , F_CHANGENEGATIVERATIO
                                   , C_SHORTCYCLEFINANCE
                                   , C_INCOMEJOINASSIGN
                                   , C_INCOMEINTOSHARE
                                   , C_CLERKLIMIT
                                   , D_CLERKLIMITSTARTDATE
                                   , C_CLERKBONUSSHARELIMIT
                                   , C_OPENCYCLE
                                   , D_STARTOPENDAY
                                   , D_ENDOPENDAY
                                   , C_ACNTLMTDEALMODE
                                   , C_ALLOTCALINTERST
                                   , C_ALLOWPARTREDEEM
                                   , C_CANEARLYRDM
                                   , C_CUSTOMERMANAGER
                                   , C_DEDUCTSCHEMECODE
                                   , C_EARLYEXITFEECALC
                                   , C_EARLYRDMCTRLBYSTATUS
                                   , C_EXITALLOT
                                   , C_EXPNAVBYFQY
                                   , C_FARECALCULATETYPE
                                   , C_FINANCETYPE
                                   , C_FIXEDDIVIDWAY
                                   , C_FUNDDAYEXPDAY
                                   , C_FUNDENDCALCRDMFEE
                                   , C_FUNDENDMODE
                                   , C_FUNDENDSENDMODE
                                   , C_FUNDRISK
                                   , C_GRADEBASE
                                   , C_ISBOUNDED
                                   , C_LIMITMODE
                                   , C_LIQUIDATIONSAVEDEDUCT
                                   , C_MAXREDEEMDEAL
                                   , C_MINBALALIMITISCONFIRM
                                   , C_QRYFREQTYPE
                                   , C_REDEEMTWICEMETHOD
                                   , C_SALETYPE
                                   , C_TALAUNCHDEPENDSTATUS
                                   , C_TEMPLATEID
                                   , C_USEINOPENDAY
                                   , C_WHETHERDIVID
                                   , D_CHECKUPDATE
                                   , D_EXPNAVAFSETUP
                                   , D_STARTDATE
                                   , F_DEDUCTRATIO
                                   , F_FUNDENDAGIO
                                   , F_LIQASSET
                                   , F_PR0
                                   , F_REDEEMPROMPTBALANCE
                                   , F_TRUSTEEFEE
                                   , L_BONUSALERTDAYS
                                   , L_BONUSFQY
                                   , L_INFORMDAYS
                                   , L_MINHOLDDATE
                                   , L_OPENDAYINFORMDAYS
                                   , L_QRYDAYSLTD
                                   , L_ZHALLOTEXPDAYS
                                   , L_ZHALLOTLIQDAYS
                                   , L_ZHREDEEMEXPDAYS
                                   , L_ZHREDEEMLIQDAYS
                                   , C_SCALECUSTMODE
                                   , F_PARDONACCOMINBALA
                                   , C_DSRDMFAREBELONGFUND
                                   , C_KEYACCOMODE
                                   , C_SHORTCFRDMBOOKING
                                   , C_REGISTERATT0
                                   , C_MANAGERCODE
                                   , C_LONGRATIONFUND
                                   , C_T0LIQUDIATE
                                   , C_PURBALADEALTYPE
                                   , C_MINSHAREADDINCOME
                                   , C_RDMMINSHARECHK
                                   , C_NAVSENDTOZDTA
                                   , C_VASTREDEEMDEALTYPE
                                   , F_MINSCALESHARES
                                   , L_LONGRDMFREEDAYS
                                   , C_SUBDIFFERNEWOLDCUST
                                   , C_ISBANISHNETREDEEM
                                   , C_ISOTC
                                   , C_OTCFUNDTYPE
                                   , C_RDMFARERATIOTYPE
                                   , C_CASHUNIONSTOCK
                                   , C_MANGERTYPE
                                   , C_PHBUSINESS
                                   , C_SHBOURSEMONEYMARKET
                                   , C_OTCFUNDNO
                                   , D_STOCKISSUEENDDATE
                                   , D_STOCKSUBDATE
                                   , C_SUBACCO
                                   , C_SUBSEAT
                                   , C_ETFACCO
                                   , C_ETFSEAT
                                   , F_MINSHARE
                                   , C_STOCKFARECALTYPE
                                   , C_SPANMARKETFLAG
                                   , C_DSFARECALTYPE
                                   , F_SUBRANGE
                                   , C_ISSTOCKREDEMPTION
                                   , D_INTERESTDATE
                                   , C_BOURSEFLAG
                                   , C_ISSTRUCTUREDPRODUCT
                                   , C_PRIORFUNDCODE
                                   , F_CAPITALRATIO
                                   , C_CHECKNAVSERVICEFARE
                                   , C_EXPPHMARKET
                                   , C_ISPUBLISHTOTALVALUE
                                   , C_SHLOF
                                   , C_FUNDFARECALCTYPE
                                   , C_ISCHKBOOKINGTRADE
                                   , C_NEEDBOOKINGBUSINTYPE
                                   , C_HASBOOKINGDEALTYPE
                                   , C_NOTBOOKINGDEALTYPE
                                   , C_FUNDOPENTYPE
                                   , C_ALLOWMARKETTRADE
                                   , C_ISEARLYLIQUIDFLAG
                                   , C_ISYUEBAO
                                   , C_NAVPUBLISHMONTH
                                   , C_RDMFREEINVEST
                                   , C_FINALFEERATIOLIMIT
                                   , C_ISSLBAO
                                   , C_OTCNEEDPROFIT
                                   , C_OTCPROFITNETVALUE
                                   , C_EVERYDAYCHANGE
                                   , C_NEWINCOMEISCHANGE
                                   , C_FUNDTYPECLASS
                                   , C_INCOMECHANGETYPE
                                   , C_AUTODEALCLASSFUNDRDM
                                   , C_INCOMERATIOTYPE
                                   , C_REINVESTDEUDCTMODE
                                   , C_RPTISSEND
                                   , F_CLERKMAXBALANCE
                                   , F_CLERKMAXRATIO
                                   , C_DAYINVESTSHAREDETAIL
                                   , C_VASTAMOUNTTYPE
                                   , C_INCOMEINTOSHARETZJY
                                   , C_NGTVSPLITRDCTYPEDEFAULT
                                   , C_PSTVSPLITDTLDEALDEFAULT
                                   , C_SHAREBATCHMODELDEFAULT
                                   , C_ISSPLITADJUSTSENDTOFA
                                   , C_NGTSPLTRDMCFMTYPE
                                   , C_PSTSPLTRDMCFMTYPE
                                   , C_SHORTOPENFUNDTYPE
                                   , D_DISTRIBUTEDATE
                                   , C_CHKSHRINCNEWINCOME
                                   , C_PROFITREFLECTTYPE
                                   , C_RISKCLASS
                                   , C_SPLITSUPPORTDEDUCT
                                   , C_ISSZQUOTEREPSPEFUND
                                   , C_PROFITHOLD
                                   , C_ACCOINCOMEDEALTYPE
                                   , C_CLEARINGBANKNAME
                                   , C_CLOSEDAYFUNDSTATUS
                                   , C_SUPPORTSTAGE
                                   , C_SPLITTAILPRECISION
                                   , C_SERVICEFARETYPE
                                   , C_SUBFUNDCODE
                                   , C_LARGECHANGELIMIT
                                   , C_ISENDOWFIXRATE
                                   , F_ENDOWFIXFARE
                                   , C_SHPROVISIONSACCO
                                   , C_SZPROVISIONSACCO
                                   , C_ISSHREALTIMEMONETARY
                                   , L_AGELIMITTRADE
                                   , C_BEAUTIFULINVEST
                                   , C_LARGELIMITOLDCUST
                                   , C_ZCBFUNDCODE
                                   , C_FOREIGNCURRENCYFUNDFLAG
                                   , F_INCOMEUNITPRECISION
                                   , C_ISEXPKJDATA
                                   , C_EXPTZJYSETUPDATA
                                   , D_CHDATE
                                   , C_CLASSAMTCTLMODE
                                   , C_OUTPROPERTY
                                   , C_INVESTMERGERDETAIL
                                   , C_SZBOURSEQPSTATUS
                                   , C_PROFITRETAINTRUSTEE
                                   , F_ENDOWREDEEMAGIO
                                   , C_REDEEMHOLDLIMITTYPE
                                   , C_SUSPENDTRADEEXPRULE
                                   , C_FUNDOPENBALINC
                                   , C_NOSHRALLOTLIMITTYPE
                                   , D_SUBSHAREDEDUCTBEGDATE
                                   , F_PARDONACCOMINBALAHIS
                                   , C_OTCCHGSHAREDEALTYPE
                                   , C_CHGONLYFUNDFARE
                                   , C_TODAYHASSETUPDATA
                                   , D_LASTALLOTDATE
                                   , C_SPREDEEMDEAL
                                   , C_SUBTACALCULATEFEE
                                   , C_LARGETRADEFILTERDS
                                   , C_BOURSESETUPED
                                   , C_ISTENPAY
                                   , C_FUNDISINCODE
                                   , C_CALRDMFARETYPE
                                   , C_TOTALNETVALUEBYNAV
                                   , C_NEEDDATECALCBYZD
                                   , C_MINHOLDUNIT
                                   , C_NOTSETALLFUNDAGENCY
                                   , F_STANALLOTRATIO
                                   , F_STANRDMRATIO
                                   , C_EARLYRDMFUNDDAY
                                   , C_VASTMERGCHECKTYPE
                                   , C_RDMLIMITISPROFIT
                                   , F_PLEDGEDPERCENT
                                   , C_FUNDFEERATIOLIMIT
                                   , C_ISEXPKFFUNDDAY
                                   , C_FUNDSHORTNAME
                                   , C_SZSTOCKACCOUNT
                                   , C_SHSTOCKACCOUNT
                                   , C_ISCALCRDMFEE
                                   , C_ISCROSSTAGRADEFUND
                                   , C_MAXAGIODEALTYPE
                                   , F_BROKERAGERATIO
                                   , C_CHANGENEGATIVE
                                   , C_ISRDMBYALLOT
                                   , C_VASTREDEEMCALTYPE
                                   , C_ISHKPRODUCT
                                   , C_ZHFUNDTYPE
                                   , C_SERVICERATIOTYPE
                                   , F_SERVICERATIO
                                   , L_SERVICEDAYS
                                   , C_REINVCALREDEEMFEE
                                   , C_REDEEMFEETYPE
                                   , F_NAVWAVEWARNING
                                   , C_CLERKFREE
                                   , F_MAINAGCTAILRATIO
                                   , C_SUBDIFFERNEWOLDMODE
                                   , C_CLERKFREETYPE
                                   , D_INVESTDATE
                                   , C_INCLUDEPURCHASE
                                   , C_NOUPGRADEAGENCY
                                   , C_SENDLIQDATA
                                   , C_ISALONEFUND
                                   , C_SHLOFSHRIN2OUTREGMODE
                                   , C_KFEXPSHRDTLRULE
                                   , D_QUARTER
                                   , F_LASTINCOMERATIO
                                   , C_SPLTRDMRATIOCFMCONTCHG
                                   , C_APPOINTTRANSFER
                                   , C_ISFIRSTDEALFUND
                                   , C_SZLOFNEW
                                   , C_BONUSREALBALBYZD
                                   , D_ESTABLISHMENTDATE
                                   , C_INCOMEDIVDETAILFUND
                                   , C_FUNDSTATUSTOPAY
                                   , C_FOFCALCFAREMODE
                                   , C_PRECHGSTATUS
                                   , F_RDMTHRESHOLD
                                   , C_RDMREINVESTSHR
                                   , C_REINVESTMODE
                                   , C_FIRSTLIMITINCLUDECHG
                                   , C_EXPJZBFDATA
                                   , C_CENTRALIZETYPE
                                   , C_FORMALFUNDCODE
                                   , F_LEVERAGEMULTIPLE
                                   , C_INVESTADNAME
                                   , C_INVESTADBUSCODE
                                   , C_INVESTADMANCODE
                                   , C_NGVSPLITUPDATECOSTPRICE
                                   , C_MAINFUNDCODE
                                   , C_CLASSFLAG
                                   , C_PRIORFLAG
                                   , F_PRIORSEQUENCE
                                   , C_FUNDMANAGERCODE
                                   , C_LOFINCALFAREBYHOLD
                                   , C_LOFINCALCFUNDFAREBYHOLD
                                   , C_LOFINDEALDETAIL
                                   , F_ACCORDMRATIO
                                   , C_ISCHECKSHAREASNETDATE
                                   , C_RDMDEALTYPE
                                   , C_LARGEEXCEEDPART
                                   , F_NAVCHANGLIMIT
                                   , F_LEVERAGERATE
                                   , C_EXPSHARETATIO
                                   , C_SALESTATORIBALATYPE
                                   , C_DELAYRDMDEALTYPE
                                   , C_TRDWHITELIST
                                   , C_EXP67HIDEFUNDTOTAL
                                   , C_FUNDASSORTMENT
                                   , C_HINTNOTIMPNAV
                                   , C_LARGETRADELIMITIDTYPE
                                   , C_FOREIGNCURRENCYFARERATE
                                   , C_CHECKCUSTMAXBALATYPE
                                   , C_REDEEMSPLITSHARES
                                   , C_PRIVATEFOF
                                   , C_EQUITYSUBAGCMERGECTL
                                   , C_LARGELIMITBYCNCW
                                   , F_ORILASTINCOMERATIO
                                   , D_ORIQUARTER
                                   , C_SOURCESOFFUNDSRPT
                                   , D_LARGETRADEBEGIN
                                   , D_LARGETRADEEND
                                   , C_STANDARDBONDCODE
                                   , C_FORCERDMJUDGETYPE
                                   , C_CHECKMINCOUNT
                                   , C_MANAGERFAREFREE
                                   , L_MFAREFREEHOLD
                                   , C_MFAREFREEHOLDUNIT
                                   , C_CLOSEDTYPE
                                   , F_CLOSEDLENGTH
                                   , C_CLOSEDUNIT
                                   , C_HOLDTERMLIMITDATERANGE
                                   , C_HOLDTERMLIMITMONTHLY
                                   , C_LARGETRADELIMITTYPE
                                   , D_DEADLINE
                                   , C_CHECKCUSTMINBALA
                                   , C_FORCERDMINCALLOT
                                   , C_ENDOWFIXAGIO
                                   , C_CHECKACCOMINCOUNT
                                   , C_IACALCFAREMODE
                                   , C_AMLLIMIT
                                   , C_EXPKFFUNDDAYBYPUBDAY
                                   , C_SIDEBAGFLAG
                                   , C_ISPUBLICFUND
                                   , F_FACTTOTALBONUS
                                   , C_FORCERDMDEALTYPE
                                   , C_REDEEMFAREBYINCOME
                                   , F_RDMBYINCOMERATIO
                                   , C_EXCCHANGESAMERATIO
                                   , C_SHOUTERBOURSETRANSFER
                                   , F_MAXADDBALOPENDAY
                                   , C_PROFITNOHOLDLIMIT
                                   , C_ALLRDMCHECKMODE
                                   , D_JUDGEINVESTED
                                   , C_FUNDOUTERBOURSETRANSFER
                                   , C_AOPCTLSCALEFUNC
                                FROM ${hsfta_src_schema}.TFUNDINFO"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_FUNDNAME", "type": "STRING"}, {"name": "C_MONEYTYPE", "type": "STRING"}, {"name": "C_MANAGERNAME", "type": "STRING"}, {"name": "C_TRUSTEECODE", "type": "STRING"}, {"name": "F_PARVALUE", "type": "DOUBLE"}, {"name": "F_ISSUEPRICE", "type": "DOUBLE"}, {"name": "C_TRUSTEEACCO", "type": "STRING"}, {"name": "D_ISSUEDATE", "type": "STRING"}, {"name": "D_SETUPDATE", "type": "STRING"}, {"name": "F_MAXBALA", "type": "DOUBLE"}, {"name": "F_MAXSHARES", "type": "DOUBLE"}, {"name": "F_MINBALA", "type": "DOUBLE"}, {"name": "F_MINSHARES", "type": "DOUBLE"}, {"name": "L_ELIMITDAY", "type": "DOUBLE"}, {"name": "L_SLIMITDAY", "type": "DOUBLE"}, {"name": "L_ALIMITDAY", "type": "DOUBLE"}, {"name": "L_MINCOUNT", "type": "DOUBLE"}, {"name": "L_CLIMITDAY", "type": "DOUBLE"}, {"name": "F_MAXALLOT", "type": "DOUBLE"}, {"name": "F_MAXREDEEM", "type": "DOUBLE"}, {"name": "C_FUNDCHARACTER", "type": "STRING"}, {"name": "C_FUNDSTATUS", "type": "STRING"}, {"name": "C_SUBSCRIBEMODE", "type": "STRING"}, {"name": "L_TIMELIMIT", "type": "DOUBLE"}, {"name": "L_SUBSCRIBEUNIT", "type": "DOUBLE"}, {"name": "C_SHARETYPES", "type": "STRING"}, {"name": "C_ISSUETYPE", "type": "STRING"}, {"name": "F_FACTCOLLECT", "type": "DOUBLE"}, {"name": "D_FAILUEDATE", "type": "STRING"}, {"name": "F_ALLOTRATIO", "type": "DOUBLE"}, {"name": "C_FEERATIOTYPE1", "type": "STRING"}, {"name": "C_FEERATIOTYPE2", "type": "STRING"}, {"name": "C_FEETYPE", "type": "STRING"}, {"name": "C_EXCEEDPART", "type": "STRING"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_FORCEREDEEM", "type": "STRING"}, {"name": "C_INTERESTDEALTYPE", "type": "STRING"}, {"name": "F_REDEEMFARERATIO", "type": "DOUBLE"}, {"name": "F_CHANGEFARERATIO", "type": "DOUBLE"}, {"name": "F_MANAGERFEE", "type": "DOUBLE"}, {"name": "F_RIGHT", "type": "DOUBLE"}, {"name": "C_PROPERTY", "type": "STRING"}, {"name": "D_EVENDATE", "type": "STRING"}, {"name": "F_TOTALBONUS", "type": "DOUBLE"}, {"name": "C_CHANGEFREE", "type": "STRING"}, {"name": "C_REPORTCODE", "type": "STRING"}, {"name": "C_BACKFARECAL", "type": "STRING"}, {"name": "L_MONEYDATE", "type": "DOUBLE"}, {"name": "L_NETPRECISION", "type": "DOUBLE"}, {"name": "C_CORPUSCONTENT", "type": "STRING"}, {"name": "F_CORPUSRATIO", "type": "DOUBLE"}, {"name": "C_FARECALTYPE", "type": "STRING"}, {"name": "L_LIQUIDATEALLOT", "type": "DOUBLE"}, {"name": "L_LIQUIDATEREDEEM", "type": "DOUBLE"}, {"name": "L_LIQUIDATEBONUS", "type": "DOUBLE"}, {"name": "L_TASPECIALACCO", "type": "DOUBLE"}, {"name": "C_FAREPRECISION", "type": "STRING"}, {"name": "D_ISSUEENDDATE", "type": "STRING"}, {"name": "C_FAREBELONGASSET", "type": "STRING"}, {"name": "L_LIQUIDATECHANGE", "type": "DOUBLE"}, {"name": "L_LIQUIDATEFAIL", "type": "DOUBLE"}, {"name": "L_LIQUIDATEEND", "type": "DOUBLE"}, {"name": "C_SHAREDETAIL", "type": "STRING"}, {"name": "C_TRUSTEEBANKNAME", "type": "STRING"}, {"name": "C_BOURSETRADEFLAG", "type": "STRING"}, {"name": "C_FUNDENGLISHNAME", "type": "STRING"}, {"name": "L_BANKACCONO", "type": "DOUBLE"}, {"name": "C_CLEANFLAG", "type": "STRING"}, {"name": "C_PRECISION", "type": "STRING"}, {"name": "C_UPGRADEFLAG", "type": "STRING"}, {"name": "C_ISDEAL", "type": "STRING"}, {"name": "C_FARECLTPRECISION", "type": "STRING"}, {"name": "C_BALANCEPRECISION", "type": "STRING"}, {"name": "C_SHAREPRECISION", "type": "STRING"}, {"name": "C_BONUSPRECISION", "type": "STRING"}, {"name": "C_INTERESTPRECISION", "type": "STRING"}, {"name": "F_MAXALLOTASSET", "type": "DOUBLE"}, {"name": "F_MAXALLOTSHARES", "type": "DOUBLE"}, {"name": "C_FOREIGNTRUSTEE", "type": "STRING"}, {"name": "L_TNCONFIRM", "type": "DOUBLE"}, {"name": "C_RATIONALLOTSTATUS", "type": "STRING"}, {"name": "L_LIQUIDATECHANGEIN", "type": "DOUBLE"}, {"name": "C_GRADETYPE", "type": "STRING"}, {"name": "C_EXCESSALLOT", "type": "STRING"}, {"name": "C_EXTRADEALTYPE", "type": "STRING"}, {"name": "ISZDPRECALCULATEFEE", "type": "STRING"}, {"name": "L_MAXCOUNT", "type": "DOUBLE"}, {"name": "C_ORDERMODE", "type": "STRING"}, {"name": "D_ACCOUTLASTDATE", "type": "STRING"}, {"name": "D_ASSETLASTDATE", "type": "STRING"}, {"name": "C_ASSETTYPE", "type": "STRING"}, {"name": "F_MINASSET", "type": "DOUBLE"}, {"name": "C_INTERESTTYPE", "type": "STRING"}, {"name": "C_NAVPUBLISHDAY", "type": "STRING"}, {"name": "C_INTERESTINCLUDEFARE", "type": "STRING"}, {"name": "C_UNRESERVEREDEEMTYPE", "type": "STRING"}, {"name": "C_RESERVEREDEEMTYPE", "type": "STRING"}, {"name": "C_RAISETYPE", "type": "STRING"}, {"name": "C_CFMFREQUENCY", "type": "STRING"}, {"name": "D_LASTINPUTDATE", "type": "STRING"}, {"name": "D_LASTINPUTTIME", "type": "STRING"}, {"name": "C_RDFARECACL", "type": "STRING"}, {"name": "C_CHECKSHARE", "type": "STRING"}, {"name": "C_FUNDFARETYPE", "type": "STRING"}, {"name": "C_MODIFYHISBONUSTYPE", "type": "STRING"}, {"name": "C_CHECKBEFOREADJUST", "type": "STRING"}, {"name": "C_NAVEPUBLISHFREQUENCY", "type": "STRING"}, {"name": "C_CONTRACTTYPE", "type": "STRING"}, {"name": "C_IMPROPERRDMTRDFEE", "type": "STRING"}, {"name": "F_MAXADDBAL", "type": "DOUBLE"}, {"name": "C_DECMANAGEFARE", "type": "STRING"}, {"name": "C_FULLCODE", "type": "STRING"}, {"name": "L_MINIHOLDDAYS", "type": "DOUBLE"}, {"name": "C_INTERFACECODE", "type": "STRING"}, {"name": "L_YEARDAYS", "type": "DOUBLE"}, {"name": "C_FUNDCHGRGDATE", "type": "STRING"}, {"name": "C_UNTRDRGDATE", "type": "STRING"}, {"name": "C_COMPSHAREDETAIL", "type": "STRING"}, {"name": "C_MINSHAREDEALTYPE", "type": "STRING"}, {"name": "L_HINTENDDAY", "type": "DOUBLE"}, {"name": "C_EXPATNOTOPENDAYS", "type": "STRING"}, {"name": "C_YIELDPRECISION", "type": "STRING"}, {"name": "F_MAXACCUADDBAL", "type": "DOUBLE"}, {"name": "C_ISINNOVATECLOSEFUND", "type": "STRING"}, {"name": "C_SHARECHECKPRECISION", "type": "STRING"}, {"name": "D_CONTRACTBEGDATE", "type": "STRING"}, {"name": "F_LARGETRADEBALANCE", "type": "DOUBLE"}, {"name": "F_LARGETRADERATIO", "type": "DOUBLE"}, {"name": "C_RGRADETYPE", "type": "STRING"}, {"name": "L_PERIODS", "type": "DOUBLE"}, {"name": "C_ISALLFAILEDSAMEREQTIME", "type": "STRING"}, {"name": "F_VASTASSET", "type": "DOUBLE"}, {"name": "C_SUBRATIOMODE", "type": "STRING"}, {"name": "C_CMINSHARESDEALTYPE", "type": "STRING"}, {"name": "C_PUBLISHENDNAV", "type": "STRING"}, {"name": "C_TWICEJUDGE", "type": "STRING"}, {"name": "C_RFIRSTSTEPLIMIT", "type": "STRING"}, {"name": "F_INTERESTRATE", "type": "DOUBLE"}, {"name": "L_INTERESTSTARTDAYS", "type": "DOUBLE"}, {"name": "D_INTERESTENDDATE", "type": "STRING"}, {"name": "C_CLTINTERESTMODE", "type": "STRING"}, {"name": "D_LISTINGDATE", "type": "STRING"}, {"name": "L_SHORTREDEEMDAYS", "type": "DOUBLE"}, {"name": "C_EXCEEDFLAG", "type": "STRING"}, {"name": "C_MODIFYBONUSFLAG", "type": "STRING"}, {"name": "C_INBOURSETOOUTCALCFARETYPE", "type": "STRING"}, {"name": "C_FUSIONTYPE", "type": "STRING"}, {"name": "C_FUSIONID", "type": "STRING"}, {"name": "C_TAILDECIMAL", "type": "STRING"}, {"name": "F_CHANGENEGATIVERATIO", "type": "DOUBLE"}, {"name": "C_SHORTCYCLEFINANCE", "type": "STRING"}, {"name": "C_INCOMEJOINASSIGN", "type": "STRING"}, {"name": "C_INCOMEINTOSHARE", "type": "STRING"}, {"name": "C_CLERKLIMIT", "type": "STRING"}, {"name": "D_CLERKLIMITSTARTDATE", "type": "STRING"}, {"name": "C_CLERKBONUSSHARELIMIT", "type": "STRING"}, {"name": "C_OPENCYCLE", "type": "STRING"}, {"name": "D_STARTOPENDAY", "type": "STRING"}, {"name": "D_ENDOPENDAY", "type": "STRING"}, {"name": "C_ACNTLMTDEALMODE", "type": "STRING"}, {"name": "C_ALLOTCALINTERST", "type": "STRING"}, {"name": "C_ALLOWPARTREDEEM", "type": "STRING"}, {"name": "C_CANEARLYRDM", "type": "STRING"}, {"name": "C_CUSTOMERMANAGER", "type": "STRING"}, {"name": "C_DEDUCTSCHEMECODE", "type": "STRING"}, {"name": "C_EARLYEXITFEECALC", "type": "STRING"}, {"name": "C_EARLYRDMCTRLBYSTATUS", "type": "STRING"}, {"name": "C_EXITALLOT", "type": "STRING"}, {"name": "C_EXPNAVBYFQY", "type": "STRING"}, {"name": "C_FARECALCULATETYPE", "type": "STRING"}, {"name": "C_FINANCETYPE", "type": "STRING"}, {"name": "C_FIXEDDIVIDWAY", "type": "STRING"}, {"name": "C_FUNDDAYEXPDAY", "type": "STRING"}, {"name": "C_FUNDENDCALCRDMFEE", "type": "STRING"}, {"name": "C_FUNDENDMODE", "type": "STRING"}, {"name": "C_FUNDENDSENDMODE", "type": "STRING"}, {"name": "C_FUNDRISK", "type": "STRING"}, {"name": "C_GRADEBASE", "type": "STRING"}, {"name": "C_ISBOUNDED", "type": "STRING"}, {"name": "C_LIMITMODE", "type": "STRING"}, {"name": "C_LIQUIDATIONSAVEDEDUCT", "type": "STRING"}, {"name": "C_MAXREDEEMDEAL", "type": "STRING"}, {"name": "C_MINBALALIMITISCONFIRM", "type": "STRING"}, {"name": "C_QRYFREQTYPE", "type": "STRING"}, {"name": "C_REDEEMTWICEMETHOD", "type": "STRING"}, {"name": "C_SALETYPE", "type": "STRING"}, {"name": "C_TALAUNCHDEPENDSTATUS", "type": "STRING"}, {"name": "C_TEMPLATEID", "type": "STRING"}, {"name": "C_USEINOPENDAY", "type": "STRING"}, {"name": "C_WHETHERDIVID", "type": "STRING"}, {"name": "D_CHECKUPDATE", "type": "STRING"}, {"name": "D_EXPNAVAFSETUP", "type": "STRING"}, {"name": "D_STARTDATE", "type": "STRING"}, {"name": "F_DEDUCTRATIO", "type": "DOUBLE"}, {"name": "F_FUNDENDAGIO", "type": "DOUBLE"}, {"name": "F_LIQASSET", "type": "DOUBLE"}, {"name": "F_PR0", "type": "DOUBLE"}, {"name": "F_REDEEMPROMPTBALANCE", "type": "DOUBLE"}, {"name": "F_TRUSTEEFEE", "type": "DOUBLE"}, {"name": "L_BONUSALERTDAYS", "type": "DOUBLE"}, {"name": "L_BONUSFQY", "type": "DOUBLE"}, {"name": "L_INFORMDAYS", "type": "DOUBLE"}, {"name": "L_MINHOLDDATE", "type": "DOUBLE"}, {"name": "L_OPENDAYINFORMDAYS", "type": "DOUBLE"}, {"name": "L_QRYDAYSLTD", "type": "DOUBLE"}, {"name": "L_ZHALLOTEXPDAYS", "type": "DOUBLE"}, {"name": "L_ZHALLOTLIQDAYS", "type": "DOUBLE"}, {"name": "L_ZHREDEEMEXPDAYS", "type": "DOUBLE"}, {"name": "L_ZHREDEEMLIQDAYS", "type": "DOUBLE"}, {"name": "C_SCALECUSTMODE", "type": "STRING"}, {"name": "F_PARDONACCOMINBALA", "type": "DOUBLE"}, {"name": "C_DSRDMFAREBELONGFUND", "type": "STRING"}, {"name": "C_KEYACCOMODE", "type": "STRING"}, {"name": "C_SHORTCFRDMBOOKING", "type": "STRING"}, {"name": "C_REGISTERATT0", "type": "STRING"}, {"name": "C_MANAGERCODE", "type": "STRING"}, {"name": "C_LONGRATIONFUND", "type": "STRING"}, {"name": "C_T0LIQUDIATE", "type": "STRING"}, {"name": "C_PURBALADEALTYPE", "type": "STRING"}, {"name": "C_MINSHAREADDINCOME", "type": "STRING"}, {"name": "C_RDMMINSHARECHK", "type": "STRING"}, {"name": "C_NAVSENDTOZDTA", "type": "STRING"}, {"name": "C_VASTREDEEMDEALTYPE", "type": "STRING"}, {"name": "F_MINSCALESHARES", "type": "DOUBLE"}, {"name": "L_LONGRDMFREEDAYS", "type": "DOUBLE"}, {"name": "C_SUBDIFFERNEWOLDCUST", "type": "STRING"}, {"name": "C_ISBANISHNETREDEEM", "type": "STRING"}, {"name": "C_ISOTC", "type": "STRING"}, {"name": "C_OTCFUNDTYPE", "type": "STRING"}, {"name": "C_RDMFARERATIOTYPE", "type": "STRING"}, {"name": "C_CASHUNIONSTOCK", "type": "STRING"}, {"name": "C_MANGERTYPE", "type": "STRING"}, {"name": "C_PHBUSINESS", "type": "STRING"}, {"name": "C_SHBOURSEMONEYMARKET", "type": "STRING"}, {"name": "C_OTCFUNDNO", "type": "STRING"}, {"name": "D_STOCKISSUEENDDATE", "type": "STRING"}, {"name": "D_STOCKSUBDATE", "type": "STRING"}, {"name": "C_SUBACCO", "type": "STRING"}, {"name": "C_SUBSEAT", "type": "STRING"}, {"name": "C_ETFACCO", "type": "STRING"}, {"name": "C_ETFSEAT", "type": "STRING"}, {"name": "F_MINSHARE", "type": "DOUBLE"}, {"name": "C_STOCKFARECALTYPE", "type": "STRING"}, {"name": "C_SPANMARKETFLAG", "type": "STRING"}, {"name": "C_DSFARECALTYPE", "type": "STRING"}, {"name": "F_SUBRANGE", "type": "DOUBLE"}, {"name": "C_ISSTOCKREDEMPTION", "type": "STRING"}, {"name": "D_INTERESTDATE", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_ISSTRUCTUREDPRODUCT", "type": "STRING"}, {"name": "C_PRIORFUNDCODE", "type": "STRING"}, {"name": "F_CAPITALRATIO", "type": "DOUBLE"}, {"name": "C_CHECKNAVSERVICEFARE", "type": "STRING"}, {"name": "C_EXPPHMARKET", "type": "STRING"}, {"name": "C_ISPUBLISHTOTALVALUE", "type": "STRING"}, {"name": "C_SHLOF", "type": "STRING"}, {"name": "C_FUNDFARECALCTYPE", "type": "STRING"}, {"name": "C_ISCHKBOOKINGTRADE", "type": "STRING"}, {"name": "C_NEEDBOOKINGBUSINTYPE", "type": "STRING"}, {"name": "C_HASBOOKINGDEALTYPE", "type": "STRING"}, {"name": "C_NOTBOOKINGDEALTYPE", "type": "STRING"}, {"name": "C_FUNDOPENTYPE", "type": "STRING"}, {"name": "C_ALLOWMARKETTRADE", "type": "STRING"}, {"name": "C_ISEARLYLIQUIDFLAG", "type": "STRING"}, {"name": "C_ISYUEBAO", "type": "STRING"}, {"name": "C_NAVPUBLISHMONTH", "type": "STRING"}, {"name": "C_RDMFREEINVEST", "type": "STRING"}, {"name": "C_FINALFEERATIOLIMIT", "type": "STRING"}, {"name": "C_ISSLBAO", "type": "STRING"}, {"name": "C_OTCNEEDPROFIT", "type": "STRING"}, {"name": "C_OTCPROFITNETVALUE", "type": "STRING"}, {"name": "C_EVERYDAYCHANGE", "type": "STRING"}, {"name": "C_NEWINCOMEISCHANGE", "type": "STRING"}, {"name": "C_FUNDTYPECLASS", "type": "STRING"}, {"name": "C_INCOMECHANGETYPE", "type": "STRING"}, {"name": "C_AUTODEALCLASSFUNDRDM", "type": "STRING"}, {"name": "C_INCOMERATIOTYPE", "type": "STRING"}, {"name": "C_REINVESTDEUDCTMODE", "type": "STRING"}, {"name": "C_RPTISSEND", "type": "STRING"}, {"name": "F_CLERKMAXBALANCE", "type": "DOUBLE"}, {"name": "F_CLERKMAXRATIO", "type": "DOUBLE"}, {"name": "C_DAYINVESTSHAREDETAIL", "type": "STRING"}, {"name": "C_VASTAMOUNTTYPE", "type": "STRING"}, {"name": "C_INCOMEINTOSHARETZJY", "type": "STRING"}, {"name": "C_NGTVSPLITRDCTYPEDEFAULT", "type": "STRING"}, {"name": "C_PSTVSPLITDTLDEALDEFAULT", "type": "STRING"}, {"name": "C_SHAREBATCHMODELDEFAULT", "type": "STRING"}, {"name": "C_ISSPLITADJUSTSENDTOFA", "type": "STRING"}, {"name": "C_NGTSPLTRDMCFMTYPE", "type": "STRING"}, {"name": "C_PSTSPLTRDMCFMTYPE", "type": "STRING"}, {"name": "C_SHORTOPENFUNDTYPE", "type": "STRING"}, {"name": "D_DISTRIBUTEDATE", "type": "STRING"}, {"name": "C_CHKSHRINCNEWINCOME", "type": "STRING"}, {"name": "C_PROFITREFLECTTYPE", "type": "STRING"}, {"name": "C_RISKCLASS", "type": "STRING"}, {"name": "C_SPLITSUPPORTDEDUCT", "type": "STRING"}, {"name": "C_ISSZQUOTEREPSPEFUND", "type": "STRING"}, {"name": "C_PROFITHOLD", "type": "STRING"}, {"name": "C_ACCOINCOMEDEALTYPE", "type": "STRING"}, {"name": "C_CLEARINGBANKNAME", "type": "STRING"}, {"name": "C_CLOSEDAYFUNDSTATUS", "type": "STRING"}, {"name": "C_SUPPORTSTAGE", "type": "STRING"}, {"name": "C_SPLITTAILPRECISION", "type": "STRING"}, {"name": "C_SERVICEFARETYPE", "type": "STRING"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "C_LARGECHANGELIMIT", "type": "STRING"}, {"name": "C_ISENDOWFIXRATE", "type": "STRING"}, {"name": "F_ENDOWFIXFARE", "type": "DOUBLE"}, {"name": "C_SHPROVISIONSACCO", "type": "STRING"}, {"name": "C_SZPROVISIONSACCO", "type": "STRING"}, {"name": "C_ISSHREALTIMEMONETARY", "type": "STRING"}, {"name": "L_AGELIMITTRADE", "type": "DOUBLE"}, {"name": "C_BEAUTIFULINVEST", "type": "STRING"}, {"name": "C_LARGELIMITOLDCUST", "type": "STRING"}, {"name": "C_ZCBFUNDCODE", "type": "STRING"}, {"name": "C_FOREIGNCURRENCYFUNDFLAG", "type": "STRING"}, {"name": "F_INCOMEUNITPRECISION", "type": "DOUBLE"}, {"name": "C_ISEXPKJDATA", "type": "STRING"}, {"name": "C_EXPTZJYSETUPDATA", "type": "STRING"}, {"name": "D_CHDATE", "type": "STRING"}, {"name": "C_CLASSAMTCTLMODE", "type": "STRING"}, {"name": "C_OUTPROPERTY", "type": "STRING"}, {"name": "C_INVESTMERGERDETAIL", "type": "STRING"}, {"name": "C_SZBOURSEQPSTATUS", "type": "STRING"}, {"name": "C_PROFITRETAINTRUSTEE", "type": "STRING"}, {"name": "F_ENDOWREDEEMAGIO", "type": "DOUBLE"}, {"name": "C_REDEEMHOLDLIMITTYPE", "type": "STRING"}, {"name": "C_SUSPENDTRADEEXPRULE", "type": "STRING"}, {"name": "C_FUNDOPENBALINC", "type": "STRING"}, {"name": "C_NOSHRALLOTLIMITTYPE", "type": "STRING"}, {"name": "D_SUBSHAREDEDUCTBEGDATE", "type": "STRING"}, {"name": "F_PARDONACCOMINBALAHIS", "type": "DOUBLE"}, {"name": "C_OTCCHGSHAREDEALTYPE", "type": "STRING"}, {"name": "C_CHGONLYFUNDFARE", "type": "STRING"}, {"name": "C_TODAYHASSETUPDATA", "type": "STRING"}, {"name": "D_LASTALLOTDATE", "type": "STRING"}, {"name": "C_SPREDEEMDEAL", "type": "STRING"}, {"name": "C_SUBTACALCULATEFEE", "type": "STRING"}, {"name": "C_LARGETRADEFILTERDS", "type": "STRING"}, {"name": "C_BOURSESETUPED", "type": "STRING"}, {"name": "C_ISTENPAY", "type": "STRING"}, {"name": "C_FUNDISINCODE", "type": "STRING"}, {"name": "C_CALRDMFARETYPE", "type": "STRING"}, {"name": "C_TOTALNETVALUEBYNAV", "type": "STRING"}, {"name": "C_NEEDDATECALCBYZD", "type": "STRING"}, {"name": "C_MINHOLDUNIT", "type": "STRING"}, {"name": "C_NOTSETALLFUNDAGENCY", "type": "STRING"}, {"name": "F_STANALLOTRATIO", "type": "DOUBLE"}, {"name": "F_STANRDMRATIO", "type": "DOUBLE"}, {"name": "C_EARLYRDMFUNDDAY", "type": "STRING"}, {"name": "C_VASTMERGCHECKTYPE", "type": "STRING"}, {"name": "C_RDMLIMITISPROFIT", "type": "STRING"}, {"name": "F_PLEDGEDPERCENT", "type": "DOUBLE"}, {"name": "C_FUNDFEERATIOLIMIT", "type": "STRING"}, {"name": "C_ISEXPKFFUNDDAY", "type": "STRING"}, {"name": "C_FUNDSHORTNAME", "type": "STRING"}, {"name": "C_SZSTOCKACCOUNT", "type": "STRING"}, {"name": "C_SHSTOCKACCOUNT", "type": "STRING"}, {"name": "C_ISCALCRDMFEE", "type": "STRING"}, {"name": "C_ISCROSSTAGRADEFUND", "type": "STRING"}, {"name": "C_MAXAGIODEALTYPE", "type": "STRING"}, {"name": "F_BROKERAGERATIO", "type": "DOUBLE"}, {"name": "C_CHANGENEGATIVE", "type": "STRING"}, {"name": "C_ISRDMBYALLOT", "type": "STRING"}, {"name": "C_VASTREDEEMCALTYPE", "type": "STRING"}, {"name": "C_ISHKPRODUCT", "type": "STRING"}, {"name": "C_ZHFUNDTYPE", "type": "STRING"}, {"name": "C_SERVICERATIOTYPE", "type": "STRING"}, {"name": "F_SERVICERATIO", "type": "DOUBLE"}, {"name": "L_SERVICEDAYS", "type": "DOUBLE"}, {"name": "C_REINVCALREDEEMFEE", "type": "STRING"}, {"name": "C_REDEEMFEETYPE", "type": "STRING"}, {"name": "F_NAVWAVEWARNING", "type": "DOUBLE"}, {"name": "C_CLERKFREE", "type": "STRING"}, {"name": "F_MAINAGCTAILRATIO", "type": "DOUBLE"}, {"name": "C_SUBDIFFERNEWOLDMODE", "type": "STRING"}, {"name": "C_CLERKFREETYPE", "type": "STRING"}, {"name": "D_INVESTDATE", "type": "STRING"}, {"name": "C_INCLUDEPURCHASE", "type": "STRING"}, {"name": "C_NOUPGRADEAGENCY", "type": "STRING"}, {"name": "C_SENDLIQDATA", "type": "STRING"}, {"name": "C_ISALONEFUND", "type": "STRING"}, {"name": "C_SHLOFSHRIN2OUTREGMODE", "type": "STRING"}, {"name": "C_KFEXPSHRDTLRULE", "type": "STRING"}, {"name": "D_QUARTER", "type": "STRING"}, {"name": "F_LASTINCOMERATIO", "type": "DOUBLE"}, {"name": "C_SPLTRDMRATIOCFMCONTCHG", "type": "STRING"}, {"name": "C_APPOINTTRANSFER", "type": "STRING"}, {"name": "C_ISFIRSTDEALFUND", "type": "STRING"}, {"name": "C_SZLOFNEW", "type": "STRING"}, {"name": "C_BONUSREALBALBYZD", "type": "STRING"}, {"name": "D_ESTABLISHMENTDATE", "type": "STRING"}, {"name": "C_INCOMEDIVDETAILFUND", "type": "STRING"}, {"name": "C_FUNDSTATUSTOPAY", "type": "STRING"}, {"name": "C_FOFCALCFAREMODE", "type": "STRING"}, {"name": "C_PRECHGSTATUS", "type": "STRING"}, {"name": "F_RDMTHRESHOLD", "type": "DOUBLE"}, {"name": "C_RDMREINVESTSHR", "type": "STRING"}, {"name": "C_REINVESTMODE", "type": "STRING"}, {"name": "C_FIRSTLIMITINCLUDECHG", "type": "STRING"}, {"name": "C_EXPJZBFDATA", "type": "STRING"}, {"name": "C_CENTRALIZETYPE", "type": "STRING"}, {"name": "C_FORMALFUNDCODE", "type": "STRING"}, {"name": "F_LEVERAGEMULTIPLE", "type": "DOUBLE"}, {"name": "C_INVESTADNAME", "type": "STRING"}, {"name": "C_INVESTADBUSCODE", "type": "STRING"}, {"name": "C_INVESTADMANCODE", "type": "STRING"}, {"name": "C_NGVSPLITUPDATECOSTPRICE", "type": "STRING"}, {"name": "C_MAINFUNDCODE", "type": "STRING"}, {"name": "C_CLASSFLAG", "type": "STRING"}, {"name": "C_PRIORFLAG", "type": "STRING"}, {"name": "F_PRIORSEQUENCE", "type": "DOUBLE"}, {"name": "C_FUNDMANAGERCODE", "type": "STRING"}, {"name": "C_LOFINCALFAREBYHOLD", "type": "STRING"}, {"name": "C_LOFINCALCFUNDFAREBYHOLD", "type": "STRING"}, {"name": "C_LOFINDEALDETAIL", "type": "STRING"}, {"name": "F_ACCORDMRATIO", "type": "DOUBLE"}, {"name": "C_ISCHECKSHAREASNETDATE", "type": "STRING"}, {"name": "C_RDMDEALTYPE", "type": "STRING"}, {"name": "C_LARGEEXCEEDPART", "type": "STRING"}, {"name": "F_NAVCHANGLIMIT", "type": "DOUBLE"}, {"name": "F_LEVERAGERATE", "type": "DOUBLE"}, {"name": "C_EXPSHARETATIO", "type": "STRING"}, {"name": "C_SALESTATORIBALATYPE", "type": "STRING"}, {"name": "C_DELAYRDMDEALTYPE", "type": "STRING"}, {"name": "C_TRDWHITELIST", "type": "STRING"}, {"name": "C_EXP67HIDEFUNDTOTAL", "type": "STRING"}, {"name": "C_FUNDASSORTMENT", "type": "STRING"}, {"name": "C_HINTNOTIMPNAV", "type": "STRING"}, {"name": "C_LARGETRADELIMITIDTYPE", "type": "STRING"}, {"name": "C_FOREIGNCURRENCYFARERATE", "type": "STRING"}, {"name": "C_CHECKCUSTMAXBALATYPE", "type": "STRING"}, {"name": "C_REDEEMSPLITSHARES", "type": "STRING"}, {"name": "C_PRIVATEFOF", "type": "STRING"}, {"name": "C_EQUITYSUBAGCMERGECTL", "type": "STRING"}, {"name": "C_LARGELIMITBYCNCW", "type": "STRING"}, {"name": "F_ORILASTINCOMERATIO", "type": "DOUBLE"}, {"name": "D_ORIQUARTER", "type": "STRING"}, {"name": "C_SOURCESOFFUNDSRPT", "type": "STRING"}, {"name": "D_LARGETRADEBEGIN", "type": "STRING"}, {"name": "D_LARGETRADEEND", "type": "STRING"}, {"name": "C_STANDARDBONDCODE", "type": "STRING"}, {"name": "C_FORCERDMJUDGETYPE", "type": "STRING"}, {"name": "C_CHECKMINCOUNT", "type": "STRING"}, {"name": "C_MANAGERFAREFREE", "type": "STRING"}, {"name": "L_MFAREFREEHOLD", "type": "DOUBLE"}, {"name": "C_MFAREFREEHOLDUNIT", "type": "STRING"}, {"name": "C_CLOSEDTYPE", "type": "STRING"}, {"name": "F_CLOSEDLENGTH", "type": "DOUBLE"}, {"name": "C_CLOSEDUNIT", "type": "STRING"}, {"name": "C_HOLDTERMLIMITDATERANGE", "type": "STRING"}, {"name": "C_HOLDTERMLIMITMONTHLY", "type": "STRING"}, {"name": "C_LARGETRADELIMITTYPE", "type": "STRING"}, {"name": "D_DEADLINE", "type": "STRING"}, {"name": "C_CHECKCUSTMINBALA", "type": "STRING"}, {"name": "C_FORCERDMINCALLOT", "type": "STRING"}, {"name": "C_ENDOWFIXAGIO", "type": "STRING"}, {"name": "C_CHECKACCOMINCOUNT", "type": "STRING"}, {"name": "C_IACALCFAREMODE", "type": "STRING"}, {"name": "C_AMLLIMIT", "type": "STRING"}, {"name": "C_EXPKFFUNDDAYBYPUBDAY", "type": "STRING"}, {"name": "C_SIDEBAGFLAG", "type": "STRING"}, {"name": "C_ISPUBLICFUND", "type": "STRING"}, {"name": "F_FACTTOTALBONUS", "type": "DOUBLE"}, {"name": "C_FORCERDMDEALTYPE", "type": "STRING"}, {"name": "C_REDEEMFAREBYINCOME", "type": "STRING"}, {"name": "F_RDMBYINCOMERATIO", "type": "DOUBLE"}, {"name": "C_EXCCHANGESAMERATIO", "type": "STRING"}, {"name": "C_SHOUTERBOURSETRANSFER", "type": "STRING"}, {"name": "F_MAXADDBALOPENDAY", "type": "DOUBLE"}, {"name": "C_PROFITNOHOLDLIMIT", "type": "STRING"}, {"name": "C_ALLRDMCHECKMODE", "type": "STRING"}, {"name": "D_JUDGEINVESTED", "type": "STRING"}, {"name": "C_FUNDOUTERBOURSETRANSFER", "type": "STRING"}, {"name": "C_AOPCTLSCALEFUNC", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tfundinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tfundinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tfundinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tfundinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TFUNDINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TFUNDINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tfundinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_FUNDNAME
     , C_MONEYTYPE
     , C_MANAGERNAME
     , C_TRUSTEECODE
     , F_PARVALUE
     , F_ISSUEPRICE
     , C_TRUSTEEACCO
     , D_ISSUEDATE
     , D_SETUPDATE
     , F_MAXBALA
     , F_MAXSHARES
     , F_MINBALA
     , F_MINSHARES
     , L_ELIMITDAY
     , L_SLIMITDAY
     , L_ALIMITDAY
     , L_MINCOUNT
     , L_CLIMITDAY
     , F_MAXALLOT
     , F_MAXREDEEM
     , C_FUNDCHARACTER
     , C_FUNDSTATUS
     , C_SUBSCRIBEMODE
     , L_TIMELIMIT
     , L_SUBSCRIBEUNIT
     , C_SHARETYPES
     , C_ISSUETYPE
     , F_FACTCOLLECT
     , D_FAILUEDATE
     , F_ALLOTRATIO
     , C_FEERATIOTYPE1
     , C_FEERATIOTYPE2
     , C_FEETYPE
     , C_EXCEEDPART
     , C_BONUSTYPE
     , C_FORCEREDEEM
     , C_INTERESTDEALTYPE
     , F_REDEEMFARERATIO
     , F_CHANGEFARERATIO
     , F_MANAGERFEE
     , F_RIGHT
     , C_PROPERTY
     , D_EVENDATE
     , F_TOTALBONUS
     , C_CHANGEFREE
     , C_REPORTCODE
     , C_BACKFARECAL
     , L_MONEYDATE
     , L_NETPRECISION
     , C_CORPUSCONTENT
     , F_CORPUSRATIO
     , C_FARECALTYPE
     , L_LIQUIDATEALLOT
     , L_LIQUIDATEREDEEM
     , L_LIQUIDATEBONUS
     , L_TASPECIALACCO
     , C_FAREPRECISION
     , D_ISSUEENDDATE
     , C_FAREBELONGASSET
     , L_LIQUIDATECHANGE
     , L_LIQUIDATEFAIL
     , L_LIQUIDATEEND
     , C_SHAREDETAIL
     , C_TRUSTEEBANKNAME
     , C_BOURSETRADEFLAG
     , C_FUNDENGLISHNAME
     , L_BANKACCONO
     , C_CLEANFLAG
     , C_PRECISION
     , C_UPGRADEFLAG
     , C_ISDEAL
     , C_FARECLTPRECISION
     , C_BALANCEPRECISION
     , C_SHAREPRECISION
     , C_BONUSPRECISION
     , C_INTERESTPRECISION
     , F_MAXALLOTASSET
     , F_MAXALLOTSHARES
     , C_FOREIGNTRUSTEE
     , L_TNCONFIRM
     , C_RATIONALLOTSTATUS
     , L_LIQUIDATECHANGEIN
     , C_GRADETYPE
     , C_EXCESSALLOT
     , C_EXTRADEALTYPE
     , ISZDPRECALCULATEFEE
     , L_MAXCOUNT
     , C_ORDERMODE
     , D_ACCOUTLASTDATE
     , D_ASSETLASTDATE
     , C_ASSETTYPE
     , F_MINASSET
     , C_INTERESTTYPE
     , C_NAVPUBLISHDAY
     , C_INTERESTINCLUDEFARE
     , C_UNRESERVEREDEEMTYPE
     , C_RESERVEREDEEMTYPE
     , C_RAISETYPE
     , C_CFMFREQUENCY
     , D_LASTINPUTDATE
     , D_LASTINPUTTIME
     , C_RDFARECACL
     , C_CHECKSHARE
     , C_FUNDFARETYPE
     , C_MODIFYHISBONUSTYPE
     , C_CHECKBEFOREADJUST
     , C_NAVEPUBLISHFREQUENCY
     , C_CONTRACTTYPE
     , C_IMPROPERRDMTRDFEE
     , F_MAXADDBAL
     , C_DECMANAGEFARE
     , C_FULLCODE
     , L_MINIHOLDDAYS
     , C_INTERFACECODE
     , L_YEARDAYS
     , C_FUNDCHGRGDATE
     , C_UNTRDRGDATE
     , C_COMPSHAREDETAIL
     , C_MINSHAREDEALTYPE
     , L_HINTENDDAY
     , C_EXPATNOTOPENDAYS
     , C_YIELDPRECISION
     , F_MAXACCUADDBAL
     , C_ISINNOVATECLOSEFUND
     , C_SHARECHECKPRECISION
     , D_CONTRACTBEGDATE
     , F_LARGETRADEBALANCE
     , F_LARGETRADERATIO
     , C_RGRADETYPE
     , L_PERIODS
     , C_ISALLFAILEDSAMEREQTIME
     , F_VASTASSET
     , C_SUBRATIOMODE
     , C_CMINSHARESDEALTYPE
     , C_PUBLISHENDNAV
     , C_TWICEJUDGE
     , C_RFIRSTSTEPLIMIT
     , F_INTERESTRATE
     , L_INTERESTSTARTDAYS
     , D_INTERESTENDDATE
     , C_CLTINTERESTMODE
     , D_LISTINGDATE
     , L_SHORTREDEEMDAYS
     , C_EXCEEDFLAG
     , C_MODIFYBONUSFLAG
     , C_INBOURSETOOUTCALCFARETYPE
     , C_FUSIONTYPE
     , C_FUSIONID
     , C_TAILDECIMAL
     , F_CHANGENEGATIVERATIO
     , C_SHORTCYCLEFINANCE
     , C_INCOMEJOINASSIGN
     , C_INCOMEINTOSHARE
     , C_CLERKLIMIT
     , D_CLERKLIMITSTARTDATE
     , C_CLERKBONUSSHARELIMIT
     , C_OPENCYCLE
     , D_STARTOPENDAY
     , D_ENDOPENDAY
     , C_ACNTLMTDEALMODE
     , C_ALLOTCALINTERST
     , C_ALLOWPARTREDEEM
     , C_CANEARLYRDM
     , C_CUSTOMERMANAGER
     , C_DEDUCTSCHEMECODE
     , C_EARLYEXITFEECALC
     , C_EARLYRDMCTRLBYSTATUS
     , C_EXITALLOT
     , C_EXPNAVBYFQY
     , C_FARECALCULATETYPE
     , C_FINANCETYPE
     , C_FIXEDDIVIDWAY
     , C_FUNDDAYEXPDAY
     , C_FUNDENDCALCRDMFEE
     , C_FUNDENDMODE
     , C_FUNDENDSENDMODE
     , C_FUNDRISK
     , C_GRADEBASE
     , C_ISBOUNDED
     , C_LIMITMODE
     , C_LIQUIDATIONSAVEDEDUCT
     , C_MAXREDEEMDEAL
     , C_MINBALALIMITISCONFIRM
     , C_QRYFREQTYPE
     , C_REDEEMTWICEMETHOD
     , C_SALETYPE
     , C_TALAUNCHDEPENDSTATUS
     , C_TEMPLATEID
     , C_USEINOPENDAY
     , C_WHETHERDIVID
     , D_CHECKUPDATE
     , D_EXPNAVAFSETUP
     , D_STARTDATE
     , F_DEDUCTRATIO
     , F_FUNDENDAGIO
     , F_LIQASSET
     , F_PR0
     , F_REDEEMPROMPTBALANCE
     , F_TRUSTEEFEE
     , L_BONUSALERTDAYS
     , L_BONUSFQY
     , L_INFORMDAYS
     , L_MINHOLDDATE
     , L_OPENDAYINFORMDAYS
     , L_QRYDAYSLTD
     , L_ZHALLOTEXPDAYS
     , L_ZHALLOTLIQDAYS
     , L_ZHREDEEMEXPDAYS
     , L_ZHREDEEMLIQDAYS
     , C_SCALECUSTMODE
     , F_PARDONACCOMINBALA
     , C_DSRDMFAREBELONGFUND
     , C_KEYACCOMODE
     , C_SHORTCFRDMBOOKING
     , C_REGISTERATT0
     , C_MANAGERCODE
     , C_LONGRATIONFUND
     , C_T0LIQUDIATE
     , C_PURBALADEALTYPE
     , C_MINSHAREADDINCOME
     , C_RDMMINSHARECHK
     , C_NAVSENDTOZDTA
     , C_VASTREDEEMDEALTYPE
     , F_MINSCALESHARES
     , L_LONGRDMFREEDAYS
     , C_SUBDIFFERNEWOLDCUST
     , C_ISBANISHNETREDEEM
     , C_ISOTC
     , C_OTCFUNDTYPE
     , C_RDMFARERATIOTYPE
     , C_CASHUNIONSTOCK
     , C_MANGERTYPE
     , C_PHBUSINESS
     , C_SHBOURSEMONEYMARKET
     , C_OTCFUNDNO
     , D_STOCKISSUEENDDATE
     , D_STOCKSUBDATE
     , C_SUBACCO
     , C_SUBSEAT
     , C_ETFACCO
     , C_ETFSEAT
     , F_MINSHARE
     , C_STOCKFARECALTYPE
     , C_SPANMARKETFLAG
     , C_DSFARECALTYPE
     , F_SUBRANGE
     , C_ISSTOCKREDEMPTION
     , D_INTERESTDATE
     , C_BOURSEFLAG
     , C_ISSTRUCTUREDPRODUCT
     , C_PRIORFUNDCODE
     , F_CAPITALRATIO
     , C_CHECKNAVSERVICEFARE
     , C_EXPPHMARKET
     , C_ISPUBLISHTOTALVALUE
     , C_SHLOF
     , C_FUNDFARECALCTYPE
     , C_ISCHKBOOKINGTRADE
     , C_NEEDBOOKINGBUSINTYPE
     , C_HASBOOKINGDEALTYPE
     , C_NOTBOOKINGDEALTYPE
     , C_FUNDOPENTYPE
     , C_ALLOWMARKETTRADE
     , C_ISEARLYLIQUIDFLAG
     , C_ISYUEBAO
     , C_NAVPUBLISHMONTH
     , C_RDMFREEINVEST
     , C_FINALFEERATIOLIMIT
     , C_ISSLBAO
     , C_OTCNEEDPROFIT
     , C_OTCPROFITNETVALUE
     , C_EVERYDAYCHANGE
     , C_NEWINCOMEISCHANGE
     , C_FUNDTYPECLASS
     , C_INCOMECHANGETYPE
     , C_AUTODEALCLASSFUNDRDM
     , C_INCOMERATIOTYPE
     , C_REINVESTDEUDCTMODE
     , C_RPTISSEND
     , F_CLERKMAXBALANCE
     , F_CLERKMAXRATIO
     , C_DAYINVESTSHAREDETAIL
     , C_VASTAMOUNTTYPE
     , C_INCOMEINTOSHARETZJY
     , C_NGTVSPLITRDCTYPEDEFAULT
     , C_PSTVSPLITDTLDEALDEFAULT
     , C_SHAREBATCHMODELDEFAULT
     , C_ISSPLITADJUSTSENDTOFA
     , C_NGTSPLTRDMCFMTYPE
     , C_PSTSPLTRDMCFMTYPE
     , C_SHORTOPENFUNDTYPE
     , D_DISTRIBUTEDATE
     , C_CHKSHRINCNEWINCOME
     , C_PROFITREFLECTTYPE
     , C_RISKCLASS
     , C_SPLITSUPPORTDEDUCT
     , C_ISSZQUOTEREPSPEFUND
     , C_PROFITHOLD
     , C_ACCOINCOMEDEALTYPE
     , C_CLEARINGBANKNAME
     , C_CLOSEDAYFUNDSTATUS
     , C_SUPPORTSTAGE
     , C_SPLITTAILPRECISION
     , C_SERVICEFARETYPE
     , C_SUBFUNDCODE
     , C_LARGECHANGELIMIT
     , C_ISENDOWFIXRATE
     , F_ENDOWFIXFARE
     , C_SHPROVISIONSACCO
     , C_SZPROVISIONSACCO
     , C_ISSHREALTIMEMONETARY
     , L_AGELIMITTRADE
     , C_BEAUTIFULINVEST
     , C_LARGELIMITOLDCUST
     , C_ZCBFUNDCODE
     , C_FOREIGNCURRENCYFUNDFLAG
     , F_INCOMEUNITPRECISION
     , C_ISEXPKJDATA
     , C_EXPTZJYSETUPDATA
     , D_CHDATE
     , C_CLASSAMTCTLMODE
     , C_OUTPROPERTY
     , C_INVESTMERGERDETAIL
     , C_SZBOURSEQPSTATUS
     , C_PROFITRETAINTRUSTEE
     , F_ENDOWREDEEMAGIO
     , C_REDEEMHOLDLIMITTYPE
     , C_SUSPENDTRADEEXPRULE
     , C_FUNDOPENBALINC
     , C_NOSHRALLOTLIMITTYPE
     , D_SUBSHAREDEDUCTBEGDATE
     , F_PARDONACCOMINBALAHIS
     , C_OTCCHGSHAREDEALTYPE
     , C_CHGONLYFUNDFARE
     , C_TODAYHASSETUPDATA
     , D_LASTALLOTDATE
     , C_SPREDEEMDEAL
     , C_SUBTACALCULATEFEE
     , C_LARGETRADEFILTERDS
     , C_BOURSESETUPED
     , C_ISTENPAY
     , C_FUNDISINCODE
     , C_CALRDMFARETYPE
     , C_TOTALNETVALUEBYNAV
     , C_NEEDDATECALCBYZD
     , C_MINHOLDUNIT
     , C_NOTSETALLFUNDAGENCY
     , F_STANALLOTRATIO
     , F_STANRDMRATIO
     , C_EARLYRDMFUNDDAY
     , C_VASTMERGCHECKTYPE
     , C_RDMLIMITISPROFIT
     , F_PLEDGEDPERCENT
     , C_FUNDFEERATIOLIMIT
     , C_ISEXPKFFUNDDAY
     , C_FUNDSHORTNAME
     , C_SZSTOCKACCOUNT
     , C_SHSTOCKACCOUNT
     , C_ISCALCRDMFEE
     , C_ISCROSSTAGRADEFUND
     , C_MAXAGIODEALTYPE
     , F_BROKERAGERATIO
     , C_CHANGENEGATIVE
     , C_ISRDMBYALLOT
     , C_VASTREDEEMCALTYPE
     , C_ISHKPRODUCT
     , C_ZHFUNDTYPE
     , C_SERVICERATIOTYPE
     , F_SERVICERATIO
     , L_SERVICEDAYS
     , C_REINVCALREDEEMFEE
     , C_REDEEMFEETYPE
     , F_NAVWAVEWARNING
     , C_CLERKFREE
     , F_MAINAGCTAILRATIO
     , C_SUBDIFFERNEWOLDMODE
     , C_CLERKFREETYPE
     , D_INVESTDATE
     , C_INCLUDEPURCHASE
     , C_NOUPGRADEAGENCY
     , C_SENDLIQDATA
     , C_ISALONEFUND
     , C_SHLOFSHRIN2OUTREGMODE
     , C_KFEXPSHRDTLRULE
     , D_QUARTER
     , F_LASTINCOMERATIO
     , C_SPLTRDMRATIOCFMCONTCHG
     , C_APPOINTTRANSFER
     , C_ISFIRSTDEALFUND
     , C_SZLOFNEW
     , C_BONUSREALBALBYZD
     , D_ESTABLISHMENTDATE
     , C_INCOMEDIVDETAILFUND
     , C_FUNDSTATUSTOPAY
     , C_FOFCALCFAREMODE
     , C_PRECHGSTATUS
     , F_RDMTHRESHOLD
     , C_RDMREINVESTSHR
     , C_REINVESTMODE
     , C_FIRSTLIMITINCLUDECHG
     , C_EXPJZBFDATA
     , C_CENTRALIZETYPE
     , C_FORMALFUNDCODE
     , F_LEVERAGEMULTIPLE
     , C_INVESTADNAME
     , C_INVESTADBUSCODE
     , C_INVESTADMANCODE
     , C_NGVSPLITUPDATECOSTPRICE
     , C_MAINFUNDCODE
     , C_CLASSFLAG
     , C_PRIORFLAG
     , F_PRIORSEQUENCE
     , C_FUNDMANAGERCODE
     , C_LOFINCALFAREBYHOLD
     , C_LOFINCALCFUNDFAREBYHOLD
     , C_LOFINDEALDETAIL
     , F_ACCORDMRATIO
     , C_ISCHECKSHAREASNETDATE
     , C_RDMDEALTYPE
     , C_LARGEEXCEEDPART
     , F_NAVCHANGLIMIT
     , F_LEVERAGERATE
     , C_EXPSHARETATIO
     , C_SALESTATORIBALATYPE
     , C_DELAYRDMDEALTYPE
     , C_TRDWHITELIST
     , C_EXP67HIDEFUNDTOTAL
     , C_FUNDASSORTMENT
     , C_HINTNOTIMPNAV
     , C_LARGETRADELIMITIDTYPE
     , C_FOREIGNCURRENCYFARERATE
     , C_CHECKCUSTMAXBALATYPE
     , C_REDEEMSPLITSHARES
     , C_PRIVATEFOF
     , C_EQUITYSUBAGCMERGECTL
     , C_LARGELIMITBYCNCW
     , F_ORILASTINCOMERATIO
     , D_ORIQUARTER
     , C_SOURCESOFFUNDSRPT
     , D_LARGETRADEBEGIN
     , D_LARGETRADEEND
     , C_STANDARDBONDCODE
     , C_FORCERDMJUDGETYPE
     , C_CHECKMINCOUNT
     , C_MANAGERFAREFREE
     , L_MFAREFREEHOLD
     , C_MFAREFREEHOLDUNIT
     , C_CLOSEDTYPE
     , F_CLOSEDLENGTH
     , C_CLOSEDUNIT
     , C_HOLDTERMLIMITDATERANGE
     , C_HOLDTERMLIMITMONTHLY
     , C_LARGETRADELIMITTYPE
     , D_DEADLINE
     , C_CHECKCUSTMINBALA
     , C_FORCERDMINCALLOT
     , C_ENDOWFIXAGIO
     , C_CHECKACCOMINCOUNT
     , C_IACALCFAREMODE
     , C_AMLLIMIT
     , C_EXPKFFUNDDAYBYPUBDAY
     , C_SIDEBAGFLAG
     , C_ISPUBLICFUND
     , F_FACTTOTALBONUS
     , C_FORCERDMDEALTYPE
     , C_REDEEMFAREBYINCOME
     , F_RDMBYINCOMERATIO
     , C_EXCCHANGESAMERATIO
     , C_SHOUTERBOURSETRANSFER
     , F_MAXADDBALOPENDAY
     , C_PROFITNOHOLDLIMIT
     , C_ALLRDMCHECKMODE
     , D_JUDGEINVESTED
     , C_FUNDOUTERBOURSETRANSFER
     , C_AOPCTLSCALEFUNC
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TFUNDINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TFUNDINFO_PFD成功"
      exit 0
   fi
fi
