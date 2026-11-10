#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TFUNDINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TFUNDINFO_PFD_TMP(
  VC_FUNDCODE  STRING  COMMENT  '基金代码',
  VC_FUNDNAME  STRING  COMMENT  '基金名称',
  C_MONEYTYPE  STRING  COMMENT  '币种',
  EN_FACEVALUE  DECIMAL(16,8)  COMMENT  '基金面值',
  EN_ISSUEPRICE  DECIMAL(7,4)  COMMENT  '发行价格',
  VC_MANAGER  STRING  COMMENT  '基金管理人',
  VC_TRUSTEE  STRING  COMMENT  '基金托管人',
  VC_TA  STRING  COMMENT  '注册登记机构',
  VC_ISSUEDATE  STRING  COMMENT  '基金发行日期',
  VC_SETUPDATE  STRING  COMMENT  '基金成立日期',
  EN_MANAGERATIO  DECIMAL(7,6)  COMMENT  '管理费率',
  C_STATE  STRING  COMMENT  '状态',
  C_FEETYPE  STRING  COMMENT  '费用计算方式',
  VC_TACODE  STRING  COMMENT  'ta代码',
  C_TYPE  STRING  COMMENT  '费用扣除方式',
  EN_MINSHARE  DECIMAL(16,2)  COMMENT  '资金交收方式',
  C_MINUSTYPE  STRING  COMMENT  '销售服务费率',
  C_NETLIQUIDATE  STRING  COMMENT  '基金类别',
  EN_SERVICERATE  DECIMAL(7,6)  COMMENT  '最小持有份额',
  C_ACCOID  STRING  COMMENT  '回款帐户',
  C_SHAREDETAIL  STRING  COMMENT  '份额明细是否合并',
  EN_TARATIO  DECIMAL(5,4)  COMMENT  '赎回费归ta比例',
  L_ETFCONFIRMDAY  DECIMAL(3,0)  COMMENT  'etf二次确认天数',
  L_QDIICONFIRMDAY  DECIMAL(3,0)  COMMENT  'qdii确认天数',
  VC_WORKTIME  STRING  COMMENT  'qdii交易截止时间',
  VC_NETWORKTIME  STRING  COMMENT  'qdii网上交易截止时间',
  C_FUNDRISKLEVEL  STRING  COMMENT  '基金风险等级',
  C_LIMITFLAG  STRING  COMMENT  '是否达到限制',
  VC_ADDRESS  STRING  COMMENT  '注册地址',
  VC_PRINCIPAL  STRING  COMMENT  '负责人',
  EN_FUNDYIELD  DECIMAL(7,4)  COMMENT  '基金收益率',
  VC_EXPFUNDCODE  STRING  COMMENT  '报送基金代码',
  C_FIXDELAYBYFUNDSTATE  STRING  COMMENT  '报送基金状态',
  EN_DELTABALA  DECIMAL(16,2)  COMMENT  '',
  C_GRADEFLAG  STRING  COMMENT  '',
  VC_UNPAYDAY  STRING  COMMENT  '',
  VC_FULLFUNDNAME  STRING  COMMENT  '',
  C_FIXALLOTSTATEFLAG  STRING  COMMENT  '',
  C_CONTRACTFLAG  STRING  COMMENT  '',
  VC_CONTRACTFILE  STRING  COMMENT  '',
  VC_RISKANNOUNCEFILE  STRING  COMMENT  '',
  C_DIVIDENDMETHOD  STRING  COMMENT  '',
  C_CONVERTSHARETYPEFREE  STRING  COMMENT  '',
  C_HOPEREDEEMTOSUBSCRB  STRING  COMMENT  '',
  EN_DIFFSCALE  DECIMAL(9,6)  COMMENT  '',
  VC_MANAGERCODE  STRING  COMMENT  '',
  VC_FUNDNAME_EN  STRING  COMMENT  '',
  EN_FAREPAYRATE  DECIMAL(5,4)  COMMENT  '',
  EN_SERVICEPAYRATE  DECIMAL(5,4)  COMMENT  '',
  EN_REDEEMFAREPAYRATE  DECIMAL(5,4)  COMMENT  '',
  L_FUNDEFFECTDAY  DECIMAL(3,0)  COMMENT  '',
  C_CYCLETYPE  STRING  COMMENT  '',
  L_CYCLESTEP  DECIMAL(10,0)  COMMENT  '',
  C_SHAREOUTMODE  STRING  COMMENT  '',
  C_CARRYSHAREOUTMODE  STRING  COMMENT  '',
  VC_FINISHDATE  STRING  COMMENT  '',
  C_BREAKREDEEM  STRING  COMMENT  '',
  C_SUBTYPE  STRING  COMMENT  '',
  C_MASTERFUNDLIMIT  STRING  COMMENT  '',
  C_FORBIDBONUSTYPE  STRING  COMMENT  '',
  C_PROMISEFLAG  STRING  COMMENT  '',
  C_FASTTRANSFERFLAG  STRING  COMMENT  '',
  VC_FUNDLEVEL  STRING  COMMENT  '',
  C_TDAYCONFIRM  STRING  COMMENT  '',
  C_REQULARLIQ  STRING  COMMENT  '',
  C_KJZFFLAG  STRING  COMMENT  '',
  C_HBZFFLAG  STRING  COMMENT  '',
  C_INSERTFLAG  STRING  COMMENT  '',
  VC_LIQUIDATEBANK  STRING  COMMENT  '',
  C_SFTRADELIMIT  STRING  COMMENT  '',
  C_MIXINDISCOUNT  STRING  COMMENT  '',
  EN_CUMULMINBALA  DECIMAL(16,2)  COMMENT  '',
  EN_CUMULDISCOUNT  DECIMAL(5,4)  COMMENT  '',
  EN_PREYIELD  DECIMAL(8,5)  COMMENT  '',
  VC_EXPIREDATE  STRING  COMMENT  '',
  EN_EXPECTYRR  DECIMAL(9,4)  COMMENT  '',
  EN_PRODUCTDUETIME  DECIMAL(5,0)  COMMENT  '',
  VC_COUNTERWORKTIME  STRING  COMMENT  '',
  VC_VALUEDATE  STRING  COMMENT  '',
  EN_TDAYFUNDTOTALRATIOLIMIT  DECIMAL(5,4)  COMMENT  '',
  EN_TDAYFUNDTOTALSHARELIMIT  DECIMAL(16,2)  COMMENT  '',
  VC_ALLOWBUSIN  STRING  COMMENT  '',
  C_EXPIREDATEALLOT  STRING  COMMENT  '',
  VC_FUNDGROUPCODE  STRING  COMMENT  '',
  VC_CTRWORKTIMEBUSIN  STRING  COMMENT  '',
  EN_PDELTABALA  DECIMAL(16,2)  COMMENT  '',
  EN_CSECONDDELTABALA  DECIMAL(16,2)  COMMENT  '',
  EN_PSECONDDELTABALA  DECIMAL(16,2)  COMMENT  '',
  C_FORBIDXJBCONVERT  STRING  COMMENT  '',
  C_TRADEBYORDER  STRING  COMMENT  '',
  C_NEEDFUNDDOC  STRING  COMMENT  '',
  VC_FUNDINVESTFILE  STRING  COMMENT  '',
  VC_IDENTIFIEDCODE  STRING  COMMENT  '',
  VC_CONTRACTVERSION  STRING  COMMENT  '',
  VC_RISKANNOUNCEVERSION  STRING  COMMENT  '',
  EN_MAXSHARE  DECIMAL(16,2)  COMMENT  '',
  EN_MAXSUBBALA  DECIMAL(16,2)  COMMENT  '',
  C_SUPVISUALCONVET  STRING  COMMENT  '',
  C_FARETYPE  STRING  COMMENT  '',
  C_RESERVEFLAG  STRING  COMMENT  '',
  C_CHECKTRADELIMIT  STRING  COMMENT  '',
  VC_MODIFYDATE  STRING  COMMENT  '',
  VC_ZHDETAILTYPE  STRING  COMMENT  '',
  VC_HOPEDATE  STRING  COMMENT  '',
  C_FUNDNAVVISBLE  STRING  COMMENT  '',
  C_COLLECTPRODCT  STRING  COMMENT  '',
  EN_OTHERRATIO  DECIMAL(5,4)  COMMENT  '',
  C_SHORTFUNDTYPE  STRING  COMMENT  '',
  C_SHOWDIVIDENDVISBLE  STRING  COMMENT  '',
  C_NEEDSURVEYFLAG  STRING  COMMENT  '',
  C_ISUNVISIBLE  STRING  COMMENT  '',
  C_TARGETCUSTTYPE  STRING  COMMENT  '',
  C_NEEDRECOMMENDER  STRING  COMMENT  '',
  C_PRECONVERSIONFLAG  STRING  COMMENT  '',
  VC_CONVERSIONDATE  STRING  COMMENT  '',
  VC_WEBADDRESS  STRING  COMMENT  '',
  C_FUSEAFFECTFLAG  STRING  COMMENT  '',
  L_MINAGE  DECIMAL(3,0)  COMMENT  '',
  C_PRIVATEFLAG  STRING  COMMENT  '',
  L_MAXAGE  DECIMAL(3,0)  COMMENT  '',
  C_XJBFUND  STRING  COMMENT  '',
  EN_MAXREDEEMSCALE  DECIMAL(6,4)  COMMENT  '',
  EN_MAXREDEEMRATIO  DECIMAL(5,4)  COMMENT  '',
  C_ESTIMATEDATE  STRING  COMMENT  '',
  C_SECONDTYPE  STRING  COMMENT  '',
  EN_MINSHARENET  DECIMAL(16,2)  COMMENT  '',
  L_VALIDDATECNT  DECIMAL(10,0)  COMMENT  '',
  C_PRITOPUB  STRING  COMMENT  '',
  C_RISKMATCHINGCHECK  STRING  COMMENT  '',
  EN_ORGMINSHARE  DECIMAL(16,2)  COMMENT  '',
  C_PARENTFUND  STRING  COMMENT  '',
  C_ISNEEDCALLBACK  STRING  COMMENT  '',
  C_CONVERSIONSTATUS  STRING  COMMENT  '',
  VC_FULLMANAGER  STRING  COMMENT  '',
  VC_FORBIDBUSIN  STRING  COMMENT  '',
  VC_IRREGULARCONVDATE  STRING  COMMENT  '',
  EN_FOFSCALE  DECIMAL(7,4)  COMMENT  '',
  EN_TRUSTONELIMIT  DECIMAL(16,2)  COMMENT  '',
  EN_TRUSTALLLIMIT  DECIMAL(16,2)  COMMENT  '',
  VC_RISKCHANGEDATE  STRING  COMMENT  '',
  C_OLDRISKLEVEL  STRING  COMMENT  '',
  C_INVESTMENTVARIETIES  STRING  COMMENT  '',
  C_PREYIELDFLAG  STRING  COMMENT  '',
  C_MONFUNDTOPRIVATE  STRING  COMMENT  '',
  C_NEEDCOOLTIME  STRING  COMMENT  '',
  EN_TOTALAVAILABLEHEAD  DECIMAL(16,0)  COMMENT  '',
  EN_TOTALAVAILABLEVOL  DECIMAL(16,2)  COMMENT  '',
  L_ALLOTCONFIRMDAY  DECIMAL(10,0)  COMMENT  '',
  L_REDEEMCONFIRMDAY  DECIMAL(10,0)  COMMENT  '',
  C_SUPPORTSHARETRANSFER  STRING  COMMENT  '',
  C_DEALFLAG  STRING  COMMENT  '',
  VC_OUTFUNDCODE  STRING  COMMENT  '',
  VC_SUMFUNDCODE  STRING  COMMENT  '',
  C_FORCECHANGEFLAG  STRING  COMMENT  '',
  C_FUNDWHITELIST  STRING  COMMENT  '',
  C_SECONDINVESTCON  STRING  COMMENT  '',
  C_TIMELIMITUNIT  STRING  COMMENT  '',
  C_SUPPORTHALFDAYREDEEM  STRING  COMMENT  '',
  C_EXPCAPITALLIQFILE  STRING  COMMENT  '',
  L_CALMCYCLE  DECIMAL(10,0)  COMMENT  '',
  EN_FUNDRATIO  DECIMAL(5,4)  COMMENT  '',
  C_ALLPRECLEAR  STRING  COMMENT  '',
  C_TGRACCOID  STRING  COMMENT  '',
  L_FUNDSTYPE  DECIMAL(3,0)  COMMENT  '',
  L_YEARLIMIT  DECIMAL(3,0)  COMMENT  '',
  C_DAYCARRYINCOME  STRING  COMMENT  '',
  C_DAYCONFIRMSHARE  STRING  COMMENT  '',
  C_TEMPORARYRESTFLAG  STRING  COMMENT  '',
  C_MERGEINCOME  STRING  COMMENT  '',
  C_SFINCOMEMERGE  STRING  COMMENT  '',
  C_RETURNOFINCOMEMODE  STRING  COMMENT  '',
  C_ISSUPERCONVERTMONEYFUND  STRING  COMMENT  '',
  C_T0SUBSCRIBE  STRING  COMMENT  '',
  C_T0ALLOT  STRING  COMMENT  '',
  C_T0REDEEM  STRING  COMMENT  '',
  C_CROSSTAFUNDCONVERT  STRING  COMMENT  '',
  VC_INSTRUCTIONSFILE  STRING  COMMENT  '',
  VC_ENGAGEMENTFILE  STRING  COMMENT  '',
  VC_MODREQUESTFILE  STRING  COMMENT  '',
  VC_SUPPLEMENTARYFILE  STRING  COMMENT  '',
  VC_MODVERSIONFILE  STRING  COMMENT  '',
  VC_PRODUCTDESCFILE  STRING  COMMENT  '',
  VC_ANNOUNCEMENTFILE  STRING  COMMENT  '',
  VC_RISKCHANGETIME  STRING  COMMENT  '',
  C_HOLIDAYMARKET  STRING  COMMENT  '',
  C_SUPYELC  STRING  COMMENT  '',
  C_SUPYELCSYMODE  STRING  COMMENT  '',
  C_YELCSYEXPORTMODE  STRING  COMMENT  '',
  C_EXPIREDATETYPE  STRING  COMMENT  '',
  VC_DIVIDENDDATE  STRING  COMMENT  '',
  VC_OPENDATE  STRING  COMMENT  '',
  VC_HOPEREDEEMENDDATE  STRING  COMMENT  '',
  C_SUPGSDY  STRING  COMMENT  '',
  C_DAYSHAREREDEEMFLAG  STRING  COMMENT  '',
  EN_PRECISION  DECIMAL(1,0)  COMMENT  '',
  EN_PAYMENTRATIO  DECIMAL(5,4)  COMMENT  '',
  C_SUPBALAREDEEMFLAG  STRING  COMMENT  '',
  C_SHAREVALIDCTRLFLAG  STRING  COMMENT  '',
  C_SHAREVALIDCTRLMODE  STRING  COMMENT  '',
  C_SUPPTRYCALGETPAY  STRING  COMMENT  '',
  EN_FLOATMANAFEEBEGINYIELD  DECIMAL(6,5)  COMMENT  '',
  EN_FLOATMANAFEERATIO  DECIMAL(6,5)  COMMENT  '',
  VC_NETNO  STRING  COMMENT  '',
  C_ISSUETYPE  STRING  COMMENT  '',
  VC_ISSUENO  STRING  COMMENT  '',
  VC_ISSUENAME  STRING  COMMENT  '',
  C_PRODUCTTYPE  STRING  COMMENT  '',
  C_REVENUECHARACTERISTICS  STRING  COMMENT  '',
  C_ISSTRUCTURALPRODUCT  STRING  COMMENT  '',
  VC_BEGINDATE  STRING  COMMENT  '',
  VC_ENDDATE  STRING  COMMENT  '',
  VC_EXPLAIN  STRING  COMMENT  '',
  C_EXPORTMODE26EXPIREDATE  STRING  COMMENT  '',
  C_NOEXPORTFISP  STRING  COMMENT  '',
  VC_ANNUITYCODE  STRING  COMMENT  '',
  C_PRODUCTCLASS  STRING  COMMENT  '',
  C_SFGLFGLDCP  STRING  COMMENT  '',
  C_NEWTHIRDBOARD  STRING  COMMENT  '',
  C_SUBSCRIBEACCOID  STRING  COMMENT  '',
  VC_PROMPTREMARKS  STRING  COMMENT  '',
  C_CHECKHOPECODELIMITFLAG  STRING  COMMENT  '',
  C_CHECKFUNDCOOLLIMITFLAG  STRING  COMMENT  '',
  VC_PRODUCTINTERCODE  STRING  COMMENT  '',
  C_SALEMODE  STRING  COMMENT  '',
  VC_ENDLIQDATE  STRING  COMMENT  '',
  EN_ESCROWRATE  DECIMAL(7,6)  COMMENT  '',
  C_REITS  STRING  COMMENT  '',
  VC_RESPONDEDDAYE  STRING  COMMENT  '',
  L_FUNDOPENDAY  DECIMAL(3,0)  COMMENT  '',
  C_CATYPE  STRING  COMMENT  '',
  C_REPLENISHSIGNTYPE  STRING  COMMENT  '',
  C_ISEXPJGBS  STRING  COMMENT  '',
  C_LOADPATHFLAG  STRING  COMMENT  '',
  VC_RECORDCODE  STRING  COMMENT  '',
  VC_MAINFUNDCODE  STRING  COMMENT  '',
  C_SIDEBAGFLAG  STRING  COMMENT  '',
  VC_SIDEBAGSTARTDATE  STRING  COMMENT  '',
  C_AUTOEXPORTPRECLEAR  STRING  COMMENT  '',
  C_T0CONVERT  STRING  COMMENT  '',
  C_T0OUTERTRUST  STRING  COMMENT  '',
  C_T0TRANSFER  STRING  COMMENT  '',
  C_SECONDINVESTINFUND  STRING  COMMENT  '',
  C_CHECKFUNDRECORDFLAG  STRING  COMMENT  '',
  C_PROFESSIONDIFF  STRING  COMMENT  '',
  C_PROFESSIONFIRST  STRING  COMMENT  '',
  C_PROFESSIONSECOND  STRING  COMMENT  '',
  C_LIMITMINUSFARE  STRING  COMMENT  ''
)
COMMENT '基金基本信息表'
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
              "querySql": ["SELECT  VC_FUNDCODE\n                                   , VC_FUNDNAME\n                                   , C_MONEYTYPE\n                                   , EN_FACEVALUE\n                                   , EN_ISSUEPRICE\n                                   , VC_MANAGER\n                                   , VC_TRUSTEE\n                                   , VC_TA\n                                   , VC_ISSUEDATE\n                                   , VC_SETUPDATE\n                                   , EN_MANAGERATIO\n                                   , C_STATE\n                                   , C_FEETYPE\n                                   , VC_TACODE\n                                   , C_TYPE\n                                   , EN_MINSHARE\n                                   , C_MINUSTYPE\n                                   , C_NETLIQUIDATE\n                                   , EN_SERVICERATE\n                                   , C_ACCOID\n                                   , C_SHAREDETAIL\n                                   , EN_TARATIO\n                                   , L_ETFCONFIRMDAY\n                                   , L_QDIICONFIRMDAY\n                                   , VC_WORKTIME\n                                   , VC_NETWORKTIME\n                                   , C_FUNDRISKLEVEL\n                                   , C_LIMITFLAG\n                                   , VC_ADDRESS\n                                   , VC_PRINCIPAL\n                                   , EN_FUNDYIELD\n                                   , VC_EXPFUNDCODE\n                                   , C_FIXDELAYBYFUNDSTATE\n                                   , EN_DELTABALA\n                                   , C_GRADEFLAG\n                                   , VC_UNPAYDAY\n                                   , VC_FULLFUNDNAME\n                                   , C_FIXALLOTSTATEFLAG\n                                   , C_CONTRACTFLAG\n                                   , VC_CONTRACTFILE\n                                   , VC_RISKANNOUNCEFILE\n                                   , C_DIVIDENDMETHOD\n                                   , C_CONVERTSHARETYPEFREE\n                                   , C_HOPEREDEEMTOSUBSCRB\n                                   , EN_DIFFSCALE\n                                   , VC_MANAGERCODE\n                                   , VC_FUNDNAME_EN\n                                   , EN_FAREPAYRATE\n                                   , EN_SERVICEPAYRATE\n                                   , EN_REDEEMFAREPAYRATE\n                                   , L_FUNDEFFECTDAY\n                                   , C_CYCLETYPE\n                                   , L_CYCLESTEP\n                                   , C_SHAREOUTMODE\n                                   , C_CARRYSHAREOUTMODE\n                                   , VC_FINISHDATE\n                                   , C_BREAKREDEEM\n                                   , C_SUBTYPE\n                                   , C_MASTERFUNDLIMIT\n                                   , C_FORBIDBONUSTYPE\n                                   , C_PROMISEFLAG\n                                   , C_FASTTRANSFERFLAG\n                                   , VC_FUNDLEVEL\n                                   , C_TDAYCONFIRM\n                                   , C_REQULARLIQ\n                                   , C_KJZFFLAG\n                                   , C_HBZFFLAG\n                                   , C_INSERTFLAG\n                                   , VC_LIQUIDATEBANK\n                                   , C_SFTRADELIMIT\n                                   , C_MIXINDISCOUNT\n                                   , EN_CUMULMINBALA\n                                   , EN_CUMULDISCOUNT\n                                   , EN_PREYIELD\n                                   , VC_EXPIREDATE\n                                   , EN_EXPECTYRR\n                                   , EN_PRODUCTDUETIME\n                                   , VC_COUNTERWORKTIME\n                                   , VC_VALUEDATE\n                                   , EN_TDAYFUNDTOTALRATIOLIMIT\n                                   , EN_TDAYFUNDTOTALSHARELIMIT\n                                   , VC_ALLOWBUSIN\n                                   , C_EXPIREDATEALLOT\n                                   , VC_FUNDGROUPCODE\n                                   , VC_CTRWORKTIMEBUSIN\n                                   , EN_PDELTABALA\n                                   , EN_CSECONDDELTABALA\n                                   , EN_PSECONDDELTABALA\n                                   , C_FORBIDXJBCONVERT\n                                   , C_TRADEBYORDER\n                                   , C_NEEDFUNDDOC\n                                   , VC_FUNDINVESTFILE\n                                   , VC_IDENTIFIEDCODE\n                                   , VC_CONTRACTVERSION\n                                   , VC_RISKANNOUNCEVERSION\n                                   , EN_MAXSHARE\n                                   , EN_MAXSUBBALA\n                                   , C_SUPVISUALCONVET\n                                   , C_FARETYPE\n                                   , C_RESERVEFLAG\n                                   , C_CHECKTRADELIMIT\n                                   , VC_MODIFYDATE\n                                   , VC_ZHDETAILTYPE\n                                   , VC_HOPEDATE\n                                   , C_FUNDNAVVISBLE\n                                   , C_COLLECTPRODCT\n                                   , EN_OTHERRATIO\n                                   , C_SHORTFUNDTYPE\n                                   , C_SHOWDIVIDENDVISBLE\n                                   , C_NEEDSURVEYFLAG\n                                   , C_ISUNVISIBLE\n                                   , C_TARGETCUSTTYPE\n                                   , C_NEEDRECOMMENDER\n                                   , C_PRECONVERSIONFLAG\n                                   , VC_CONVERSIONDATE\n                                   , VC_WEBADDRESS\n                                   , C_FUSEAFFECTFLAG\n                                   , L_MINAGE\n                                   , C_PRIVATEFLAG\n                                   , L_MAXAGE\n                                   , C_XJBFUND\n                                   , EN_MAXREDEEMSCALE\n                                   , EN_MAXREDEEMRATIO\n                                   , C_ESTIMATEDATE\n                                   , C_SECONDTYPE\n                                   , EN_MINSHARENET\n                                   , L_VALIDDATECNT\n                                   , C_PRITOPUB\n                                   , C_RISKMATCHINGCHECK\n                                   , EN_ORGMINSHARE\n                                   , C_PARENTFUND\n                                   , C_ISNEEDCALLBACK\n                                   , C_CONVERSIONSTATUS\n                                   , VC_FULLMANAGER\n                                   , VC_FORBIDBUSIN\n                                   , VC_IRREGULARCONVDATE\n                                   , EN_FOFSCALE\n                                   , EN_TRUSTONELIMIT\n                                   , EN_TRUSTALLLIMIT\n                                   , VC_RISKCHANGEDATE\n                                   , C_OLDRISKLEVEL\n                                   , C_INVESTMENTVARIETIES\n                                   , C_PREYIELDFLAG\n                                   , C_MONFUNDTOPRIVATE\n                                   , C_NEEDCOOLTIME\n                                   , EN_TOTALAVAILABLEHEAD\n                                   , EN_TOTALAVAILABLEVOL\n                                   , L_ALLOTCONFIRMDAY\n                                   , L_REDEEMCONFIRMDAY\n                                   , C_SUPPORTSHARETRANSFER\n                                   , C_DEALFLAG\n                                   , VC_OUTFUNDCODE\n                                   , VC_SUMFUNDCODE\n                                   , C_FORCECHANGEFLAG\n                                   , C_FUNDWHITELIST\n                                   , C_SECONDINVESTCON\n                                   , C_TIMELIMITUNIT\n                                   , C_SUPPORTHALFDAYREDEEM\n                                   , C_EXPCAPITALLIQFILE\n                                   , L_CALMCYCLE\n                                   , EN_FUNDRATIO\n                                   , C_ALLPRECLEAR\n                                   , C_TGRACCOID\n                                   , L_FUNDSTYPE\n                                   , L_YEARLIMIT\n                                   , C_DAYCARRYINCOME\n                                   , C_DAYCONFIRMSHARE\n                                   , C_TEMPORARYRESTFLAG\n                                   , C_MERGEINCOME\n                                   , C_SFINCOMEMERGE\n                                   , C_RETURNOFINCOMEMODE\n                                   , C_ISSUPERCONVERTMONEYFUND\n                                   , C_T0SUBSCRIBE\n                                   , C_T0ALLOT\n                                   , C_T0REDEEM\n                                   , C_CROSSTAFUNDCONVERT\n                                   , VC_INSTRUCTIONSFILE\n                                   , VC_ENGAGEMENTFILE\n                                   , VC_MODREQUESTFILE\n                                   , VC_SUPPLEMENTARYFILE\n                                   , VC_MODVERSIONFILE\n                                   , VC_PRODUCTDESCFILE\n                                   , VC_ANNOUNCEMENTFILE\n                                   , VC_RISKCHANGETIME\n                                   , C_HOLIDAYMARKET\n                                   , C_SUPYELC\n                                   , C_SUPYELCSYMODE\n                                   , C_YELCSYEXPORTMODE\n                                   , C_EXPIREDATETYPE\n                                   , VC_DIVIDENDDATE\n                                   , VC_OPENDATE\n                                   , VC_HOPEREDEEMENDDATE\n                                   , C_SUPGSDY\n                                   , C_DAYSHAREREDEEMFLAG\n                                   , EN_PRECISION\n                                   , EN_PAYMENTRATIO\n                                   , C_SUPBALAREDEEMFLAG\n                                   , C_SHAREVALIDCTRLFLAG\n                                   , C_SHAREVALIDCTRLMODE\n                                   , C_SUPPTRYCALGETPAY\n                                   , EN_FLOATMANAFEEBEGINYIELD\n                                   , EN_FLOATMANAFEERATIO\n                                   , VC_NETNO\n                                   , C_ISSUETYPE\n                                   , VC_ISSUENO\n                                   , VC_ISSUENAME\n                                   , C_PRODUCTTYPE\n                                   , C_REVENUECHARACTERISTICS\n                                   , C_ISSTRUCTURALPRODUCT\n                                   , VC_BEGINDATE\n                                   , VC_ENDDATE\n                                   , VC_EXPLAIN\n                                   , C_EXPORTMODE26EXPIREDATE\n                                   , C_NOEXPORTFISP\n                                   , VC_ANNUITYCODE\n                                   , C_PRODUCTCLASS\n                                   , C_SFGLFGLDCP\n                                   , C_NEWTHIRDBOARD\n                                   , C_SUBSCRIBEACCOID\n                                   , VC_PROMPTREMARKS\n                                   , C_CHECKHOPECODELIMITFLAG\n                                   , C_CHECKFUNDCOOLLIMITFLAG\n                                   , VC_PRODUCTINTERCODE\n                                   , C_SALEMODE\n                                   , VC_ENDLIQDATE\n                                   , EN_ESCROWRATE\n                                   , C_REITS\n                                   , VC_RESPONDEDDAYE\n                                   , L_FUNDOPENDAY\n                                   , C_CATYPE\n                                   , C_REPLENISHSIGNTYPE\n                                   , C_ISEXPJGBS\n                                   , C_LOADPATHFLAG\n                                   , VC_RECORDCODE\n                                   , VC_MAINFUNDCODE\n                                   , C_SIDEBAGFLAG\n                                   , VC_SIDEBAGSTARTDATE\n                                   , C_AUTOEXPORTPRECLEAR\n                                   , C_T0CONVERT\n                                   , C_T0OUTERTRUST\n                                   , C_T0TRANSFER\n                                   , C_SECONDINVESTINFUND\n                                   , C_CHECKFUNDRECORDFLAG\n                                   , C_PROFESSIONDIFF\n                                   , C_PROFESSIONFIRST\n                                   , C_PROFESSIONSECOND\n                                   , C_LIMITMINUSFARE\n                                FROM ${hsds_src_schema}.TFUNDINFO"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_FUNDCODE", "type": "STRING"}, {"name": "VC_FUNDNAME", "type": "STRING"}, {"name": "C_MONEYTYPE", "type": "STRING"}, {"name": "EN_FACEVALUE", "type": "DOUBLE"}, {"name": "EN_ISSUEPRICE", "type": "DOUBLE"}, {"name": "VC_MANAGER", "type": "STRING"}, {"name": "VC_TRUSTEE", "type": "STRING"}, {"name": "VC_TA", "type": "STRING"}, {"name": "VC_ISSUEDATE", "type": "STRING"}, {"name": "VC_SETUPDATE", "type": "STRING"}, {"name": "EN_MANAGERATIO", "type": "DOUBLE"}, {"name": "C_STATE", "type": "STRING"}, {"name": "C_FEETYPE", "type": "STRING"}, {"name": "VC_TACODE", "type": "STRING"}, {"name": "C_TYPE", "type": "STRING"}, {"name": "EN_MINSHARE", "type": "DOUBLE"}, {"name": "C_MINUSTYPE", "type": "STRING"}, {"name": "C_NETLIQUIDATE", "type": "STRING"}, {"name": "EN_SERVICERATE", "type": "DOUBLE"}, {"name": "C_ACCOID", "type": "STRING"}, {"name": "C_SHAREDETAIL", "type": "STRING"}, {"name": "EN_TARATIO", "type": "DOUBLE"}, {"name": "L_ETFCONFIRMDAY", "type": "DOUBLE"}, {"name": "L_QDIICONFIRMDAY", "type": "DOUBLE"}, {"name": "VC_WORKTIME", "type": "STRING"}, {"name": "VC_NETWORKTIME", "type": "STRING"}, {"name": "C_FUNDRISKLEVEL", "type": "STRING"}, {"name": "C_LIMITFLAG", "type": "STRING"}, {"name": "VC_ADDRESS", "type": "STRING"}, {"name": "VC_PRINCIPAL", "type": "STRING"}, {"name": "EN_FUNDYIELD", "type": "DOUBLE"}, {"name": "VC_EXPFUNDCODE", "type": "STRING"}, {"name": "C_FIXDELAYBYFUNDSTATE", "type": "STRING"}, {"name": "EN_DELTABALA", "type": "DOUBLE"}, {"name": "C_GRADEFLAG", "type": "STRING"}, {"name": "VC_UNPAYDAY", "type": "STRING"}, {"name": "VC_FULLFUNDNAME", "type": "STRING"}, {"name": "C_FIXALLOTSTATEFLAG", "type": "STRING"}, {"name": "C_CONTRACTFLAG", "type": "STRING"}, {"name": "VC_CONTRACTFILE", "type": "STRING"}, {"name": "VC_RISKANNOUNCEFILE", "type": "STRING"}, {"name": "C_DIVIDENDMETHOD", "type": "STRING"}, {"name": "C_CONVERTSHARETYPEFREE", "type": "STRING"}, {"name": "C_HOPEREDEEMTOSUBSCRB", "type": "STRING"}, {"name": "EN_DIFFSCALE", "type": "DOUBLE"}, {"name": "VC_MANAGERCODE", "type": "STRING"}, {"name": "VC_FUNDNAME_EN", "type": "STRING"}, {"name": "EN_FAREPAYRATE", "type": "DOUBLE"}, {"name": "EN_SERVICEPAYRATE", "type": "DOUBLE"}, {"name": "EN_REDEEMFAREPAYRATE", "type": "DOUBLE"}, {"name": "L_FUNDEFFECTDAY", "type": "DOUBLE"}, {"name": "C_CYCLETYPE", "type": "STRING"}, {"name": "L_CYCLESTEP", "type": "DOUBLE"}, {"name": "C_SHAREOUTMODE", "type": "STRING"}, {"name": "C_CARRYSHAREOUTMODE", "type": "STRING"}, {"name": "VC_FINISHDATE", "type": "STRING"}, {"name": "C_BREAKREDEEM", "type": "STRING"}, {"name": "C_SUBTYPE", "type": "STRING"}, {"name": "C_MASTERFUNDLIMIT", "type": "STRING"}, {"name": "C_FORBIDBONUSTYPE", "type": "STRING"}, {"name": "C_PROMISEFLAG", "type": "STRING"}, {"name": "C_FASTTRANSFERFLAG", "type": "STRING"}, {"name": "VC_FUNDLEVEL", "type": "STRING"}, {"name": "C_TDAYCONFIRM", "type": "STRING"}, {"name": "C_REQULARLIQ", "type": "STRING"}, {"name": "C_KJZFFLAG", "type": "STRING"}, {"name": "C_HBZFFLAG", "type": "STRING"}, {"name": "C_INSERTFLAG", "type": "STRING"}, {"name": "VC_LIQUIDATEBANK", "type": "STRING"}, {"name": "C_SFTRADELIMIT", "type": "STRING"}, {"name": "C_MIXINDISCOUNT", "type": "STRING"}, {"name": "EN_CUMULMINBALA", "type": "DOUBLE"}, {"name": "EN_CUMULDISCOUNT", "type": "DOUBLE"}, {"name": "EN_PREYIELD", "type": "DOUBLE"}, {"name": "VC_EXPIREDATE", "type": "STRING"}, {"name": "EN_EXPECTYRR", "type": "DOUBLE"}, {"name": "EN_PRODUCTDUETIME", "type": "DOUBLE"}, {"name": "VC_COUNTERWORKTIME", "type": "STRING"}, {"name": "VC_VALUEDATE", "type": "STRING"}, {"name": "EN_TDAYFUNDTOTALRATIOLIMIT", "type": "DOUBLE"}, {"name": "EN_TDAYFUNDTOTALSHARELIMIT", "type": "DOUBLE"}, {"name": "VC_ALLOWBUSIN", "type": "STRING"}, {"name": "C_EXPIREDATEALLOT", "type": "STRING"}, {"name": "VC_FUNDGROUPCODE", "type": "STRING"}, {"name": "VC_CTRWORKTIMEBUSIN", "type": "STRING"}, {"name": "EN_PDELTABALA", "type": "DOUBLE"}, {"name": "EN_CSECONDDELTABALA", "type": "DOUBLE"}, {"name": "EN_PSECONDDELTABALA", "type": "DOUBLE"}, {"name": "C_FORBIDXJBCONVERT", "type": "STRING"}, {"name": "C_TRADEBYORDER", "type": "STRING"}, {"name": "C_NEEDFUNDDOC", "type": "STRING"}, {"name": "VC_FUNDINVESTFILE", "type": "STRING"}, {"name": "VC_IDENTIFIEDCODE", "type": "STRING"}, {"name": "VC_CONTRACTVERSION", "type": "STRING"}, {"name": "VC_RISKANNOUNCEVERSION", "type": "STRING"}, {"name": "EN_MAXSHARE", "type": "DOUBLE"}, {"name": "EN_MAXSUBBALA", "type": "DOUBLE"}, {"name": "C_SUPVISUALCONVET", "type": "STRING"}, {"name": "C_FARETYPE", "type": "STRING"}, {"name": "C_RESERVEFLAG", "type": "STRING"}, {"name": "C_CHECKTRADELIMIT", "type": "STRING"}, {"name": "VC_MODIFYDATE", "type": "STRING"}, {"name": "VC_ZHDETAILTYPE", "type": "STRING"}, {"name": "VC_HOPEDATE", "type": "STRING"}, {"name": "C_FUNDNAVVISBLE", "type": "STRING"}, {"name": "C_COLLECTPRODCT", "type": "STRING"}, {"name": "EN_OTHERRATIO", "type": "DOUBLE"}, {"name": "C_SHORTFUNDTYPE", "type": "STRING"}, {"name": "C_SHOWDIVIDENDVISBLE", "type": "STRING"}, {"name": "C_NEEDSURVEYFLAG", "type": "STRING"}, {"name": "C_ISUNVISIBLE", "type": "STRING"}, {"name": "C_TARGETCUSTTYPE", "type": "STRING"}, {"name": "C_NEEDRECOMMENDER", "type": "STRING"}, {"name": "C_PRECONVERSIONFLAG", "type": "STRING"}, {"name": "VC_CONVERSIONDATE", "type": "STRING"}, {"name": "VC_WEBADDRESS", "type": "STRING"}, {"name": "C_FUSEAFFECTFLAG", "type": "STRING"}, {"name": "L_MINAGE", "type": "DOUBLE"}, {"name": "C_PRIVATEFLAG", "type": "STRING"}, {"name": "L_MAXAGE", "type": "DOUBLE"}, {"name": "C_XJBFUND", "type": "STRING"}, {"name": "EN_MAXREDEEMSCALE", "type": "DOUBLE"}, {"name": "EN_MAXREDEEMRATIO", "type": "DOUBLE"}, {"name": "C_ESTIMATEDATE", "type": "STRING"}, {"name": "C_SECONDTYPE", "type": "STRING"}, {"name": "EN_MINSHARENET", "type": "DOUBLE"}, {"name": "L_VALIDDATECNT", "type": "DOUBLE"}, {"name": "C_PRITOPUB", "type": "STRING"}, {"name": "C_RISKMATCHINGCHECK", "type": "STRING"}, {"name": "EN_ORGMINSHARE", "type": "DOUBLE"}, {"name": "C_PARENTFUND", "type": "STRING"}, {"name": "C_ISNEEDCALLBACK", "type": "STRING"}, {"name": "C_CONVERSIONSTATUS", "type": "STRING"}, {"name": "VC_FULLMANAGER", "type": "STRING"}, {"name": "VC_FORBIDBUSIN", "type": "STRING"}, {"name": "VC_IRREGULARCONVDATE", "type": "STRING"}, {"name": "EN_FOFSCALE", "type": "DOUBLE"}, {"name": "EN_TRUSTONELIMIT", "type": "DOUBLE"}, {"name": "EN_TRUSTALLLIMIT", "type": "DOUBLE"}, {"name": "VC_RISKCHANGEDATE", "type": "STRING"}, {"name": "C_OLDRISKLEVEL", "type": "STRING"}, {"name": "C_INVESTMENTVARIETIES", "type": "STRING"}, {"name": "C_PREYIELDFLAG", "type": "STRING"}, {"name": "C_MONFUNDTOPRIVATE", "type": "STRING"}, {"name": "C_NEEDCOOLTIME", "type": "STRING"}, {"name": "EN_TOTALAVAILABLEHEAD", "type": "DOUBLE"}, {"name": "EN_TOTALAVAILABLEVOL", "type": "DOUBLE"}, {"name": "L_ALLOTCONFIRMDAY", "type": "DOUBLE"}, {"name": "L_REDEEMCONFIRMDAY", "type": "DOUBLE"}, {"name": "C_SUPPORTSHARETRANSFER", "type": "STRING"}, {"name": "C_DEALFLAG", "type": "STRING"}, {"name": "VC_OUTFUNDCODE", "type": "STRING"}, {"name": "VC_SUMFUNDCODE", "type": "STRING"}, {"name": "C_FORCECHANGEFLAG", "type": "STRING"}, {"name": "C_FUNDWHITELIST", "type": "STRING"}, {"name": "C_SECONDINVESTCON", "type": "STRING"}, {"name": "C_TIMELIMITUNIT", "type": "STRING"}, {"name": "C_SUPPORTHALFDAYREDEEM", "type": "STRING"}, {"name": "C_EXPCAPITALLIQFILE", "type": "STRING"}, {"name": "L_CALMCYCLE", "type": "DOUBLE"}, {"name": "EN_FUNDRATIO", "type": "DOUBLE"}, {"name": "C_ALLPRECLEAR", "type": "STRING"}, {"name": "C_TGRACCOID", "type": "STRING"}, {"name": "L_FUNDSTYPE", "type": "DOUBLE"}, {"name": "L_YEARLIMIT", "type": "DOUBLE"}, {"name": "C_DAYCARRYINCOME", "type": "STRING"}, {"name": "C_DAYCONFIRMSHARE", "type": "STRING"}, {"name": "C_TEMPORARYRESTFLAG", "type": "STRING"}, {"name": "C_MERGEINCOME", "type": "STRING"}, {"name": "C_SFINCOMEMERGE", "type": "STRING"}, {"name": "C_RETURNOFINCOMEMODE", "type": "STRING"}, {"name": "C_ISSUPERCONVERTMONEYFUND", "type": "STRING"}, {"name": "C_T0SUBSCRIBE", "type": "STRING"}, {"name": "C_T0ALLOT", "type": "STRING"}, {"name": "C_T0REDEEM", "type": "STRING"}, {"name": "C_CROSSTAFUNDCONVERT", "type": "STRING"}, {"name": "VC_INSTRUCTIONSFILE", "type": "STRING"}, {"name": "VC_ENGAGEMENTFILE", "type": "STRING"}, {"name": "VC_MODREQUESTFILE", "type": "STRING"}, {"name": "VC_SUPPLEMENTARYFILE", "type": "STRING"}, {"name": "VC_MODVERSIONFILE", "type": "STRING"}, {"name": "VC_PRODUCTDESCFILE", "type": "STRING"}, {"name": "VC_ANNOUNCEMENTFILE", "type": "STRING"}, {"name": "VC_RISKCHANGETIME", "type": "STRING"}, {"name": "C_HOLIDAYMARKET", "type": "STRING"}, {"name": "C_SUPYELC", "type": "STRING"}, {"name": "C_SUPYELCSYMODE", "type": "STRING"}, {"name": "C_YELCSYEXPORTMODE", "type": "STRING"}, {"name": "C_EXPIREDATETYPE", "type": "STRING"}, {"name": "VC_DIVIDENDDATE", "type": "STRING"}, {"name": "VC_OPENDATE", "type": "STRING"}, {"name": "VC_HOPEREDEEMENDDATE", "type": "STRING"}, {"name": "C_SUPGSDY", "type": "STRING"}, {"name": "C_DAYSHAREREDEEMFLAG", "type": "STRING"}, {"name": "EN_PRECISION", "type": "DOUBLE"}, {"name": "EN_PAYMENTRATIO", "type": "DOUBLE"}, {"name": "C_SUPBALAREDEEMFLAG", "type": "STRING"}, {"name": "C_SHAREVALIDCTRLFLAG", "type": "STRING"}, {"name": "C_SHAREVALIDCTRLMODE", "type": "STRING"}, {"name": "C_SUPPTRYCALGETPAY", "type": "STRING"}, {"name": "EN_FLOATMANAFEEBEGINYIELD", "type": "DOUBLE"}, {"name": "EN_FLOATMANAFEERATIO", "type": "DOUBLE"}, {"name": "VC_NETNO", "type": "STRING"}, {"name": "C_ISSUETYPE", "type": "STRING"}, {"name": "VC_ISSUENO", "type": "STRING"}, {"name": "VC_ISSUENAME", "type": "STRING"}, {"name": "C_PRODUCTTYPE", "type": "STRING"}, {"name": "C_REVENUECHARACTERISTICS", "type": "STRING"}, {"name": "C_ISSTRUCTURALPRODUCT", "type": "STRING"}, {"name": "VC_BEGINDATE", "type": "STRING"}, {"name": "VC_ENDDATE", "type": "STRING"}, {"name": "VC_EXPLAIN", "type": "STRING"}, {"name": "C_EXPORTMODE26EXPIREDATE", "type": "STRING"}, {"name": "C_NOEXPORTFISP", "type": "STRING"}, {"name": "VC_ANNUITYCODE", "type": "STRING"}, {"name": "C_PRODUCTCLASS", "type": "STRING"}, {"name": "C_SFGLFGLDCP", "type": "STRING"}, {"name": "C_NEWTHIRDBOARD", "type": "STRING"}, {"name": "C_SUBSCRIBEACCOID", "type": "STRING"}, {"name": "VC_PROMPTREMARKS", "type": "STRING"}, {"name": "C_CHECKHOPECODELIMITFLAG", "type": "STRING"}, {"name": "C_CHECKFUNDCOOLLIMITFLAG", "type": "STRING"}, {"name": "VC_PRODUCTINTERCODE", "type": "STRING"}, {"name": "C_SALEMODE", "type": "STRING"}, {"name": "VC_ENDLIQDATE", "type": "STRING"}, {"name": "EN_ESCROWRATE", "type": "DOUBLE"}, {"name": "C_REITS", "type": "STRING"}, {"name": "VC_RESPONDEDDAYE", "type": "STRING"}, {"name": "L_FUNDOPENDAY", "type": "DOUBLE"}, {"name": "C_CATYPE", "type": "STRING"}, {"name": "C_REPLENISHSIGNTYPE", "type": "STRING"}, {"name": "C_ISEXPJGBS", "type": "STRING"}, {"name": "C_LOADPATHFLAG", "type": "STRING"}, {"name": "VC_RECORDCODE", "type": "STRING"}, {"name": "VC_MAINFUNDCODE", "type": "STRING"}, {"name": "C_SIDEBAGFLAG", "type": "STRING"}, {"name": "VC_SIDEBAGSTARTDATE", "type": "STRING"}, {"name": "C_AUTOEXPORTPRECLEAR", "type": "STRING"}, {"name": "C_T0CONVERT", "type": "STRING"}, {"name": "C_T0OUTERTRUST", "type": "STRING"}, {"name": "C_T0TRANSFER", "type": "STRING"}, {"name": "C_SECONDINVESTINFUND", "type": "STRING"}, {"name": "C_CHECKFUNDRECORDFLAG", "type": "STRING"}, {"name": "C_PROFESSIONDIFF", "type": "STRING"}, {"name": "C_PROFESSIONFIRST", "type": "STRING"}, {"name": "C_PROFESSIONSECOND", "type": "STRING"}, {"name": "C_LIMITMINUSFARE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_tfundinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_tfundinfo_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_tfundinfo_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_tfundinfo_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TFUNDINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TFUNDINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_tfundinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TFUNDINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_FUNDCODE
     , VC_FUNDNAME
     , C_MONEYTYPE
     , EN_FACEVALUE
     , EN_ISSUEPRICE
     , VC_MANAGER
     , VC_TRUSTEE
     , VC_TA
     , VC_ISSUEDATE
     , VC_SETUPDATE
     , EN_MANAGERATIO
     , C_STATE
     , C_FEETYPE
     , VC_TACODE
     , C_TYPE
     , EN_MINSHARE
     , C_MINUSTYPE
     , C_NETLIQUIDATE
     , EN_SERVICERATE
     , C_ACCOID
     , C_SHAREDETAIL
     , EN_TARATIO
     , L_ETFCONFIRMDAY
     , L_QDIICONFIRMDAY
     , VC_WORKTIME
     , VC_NETWORKTIME
     , C_FUNDRISKLEVEL
     , C_LIMITFLAG
     , VC_ADDRESS
     , VC_PRINCIPAL
     , EN_FUNDYIELD
     , VC_EXPFUNDCODE
     , C_FIXDELAYBYFUNDSTATE
     , EN_DELTABALA
     , C_GRADEFLAG
     , VC_UNPAYDAY
     , VC_FULLFUNDNAME
     , C_FIXALLOTSTATEFLAG
     , C_CONTRACTFLAG
     , VC_CONTRACTFILE
     , VC_RISKANNOUNCEFILE
     , C_DIVIDENDMETHOD
     , C_CONVERTSHARETYPEFREE
     , C_HOPEREDEEMTOSUBSCRB
     , EN_DIFFSCALE
     , VC_MANAGERCODE
     , VC_FUNDNAME_EN
     , EN_FAREPAYRATE
     , EN_SERVICEPAYRATE
     , EN_REDEEMFAREPAYRATE
     , L_FUNDEFFECTDAY
     , C_CYCLETYPE
     , L_CYCLESTEP
     , C_SHAREOUTMODE
     , C_CARRYSHAREOUTMODE
     , VC_FINISHDATE
     , C_BREAKREDEEM
     , C_SUBTYPE
     , C_MASTERFUNDLIMIT
     , C_FORBIDBONUSTYPE
     , C_PROMISEFLAG
     , C_FASTTRANSFERFLAG
     , VC_FUNDLEVEL
     , C_TDAYCONFIRM
     , C_REQULARLIQ
     , C_KJZFFLAG
     , C_HBZFFLAG
     , C_INSERTFLAG
     , VC_LIQUIDATEBANK
     , C_SFTRADELIMIT
     , C_MIXINDISCOUNT
     , EN_CUMULMINBALA
     , EN_CUMULDISCOUNT
     , EN_PREYIELD
     , VC_EXPIREDATE
     , EN_EXPECTYRR
     , EN_PRODUCTDUETIME
     , VC_COUNTERWORKTIME
     , VC_VALUEDATE
     , EN_TDAYFUNDTOTALRATIOLIMIT
     , EN_TDAYFUNDTOTALSHARELIMIT
     , VC_ALLOWBUSIN
     , C_EXPIREDATEALLOT
     , VC_FUNDGROUPCODE
     , VC_CTRWORKTIMEBUSIN
     , EN_PDELTABALA
     , EN_CSECONDDELTABALA
     , EN_PSECONDDELTABALA
     , C_FORBIDXJBCONVERT
     , C_TRADEBYORDER
     , C_NEEDFUNDDOC
     , VC_FUNDINVESTFILE
     , VC_IDENTIFIEDCODE
     , VC_CONTRACTVERSION
     , VC_RISKANNOUNCEVERSION
     , EN_MAXSHARE
     , EN_MAXSUBBALA
     , C_SUPVISUALCONVET
     , C_FARETYPE
     , C_RESERVEFLAG
     , C_CHECKTRADELIMIT
     , VC_MODIFYDATE
     , VC_ZHDETAILTYPE
     , VC_HOPEDATE
     , C_FUNDNAVVISBLE
     , C_COLLECTPRODCT
     , EN_OTHERRATIO
     , C_SHORTFUNDTYPE
     , C_SHOWDIVIDENDVISBLE
     , C_NEEDSURVEYFLAG
     , C_ISUNVISIBLE
     , C_TARGETCUSTTYPE
     , C_NEEDRECOMMENDER
     , C_PRECONVERSIONFLAG
     , VC_CONVERSIONDATE
     , VC_WEBADDRESS
     , C_FUSEAFFECTFLAG
     , L_MINAGE
     , C_PRIVATEFLAG
     , L_MAXAGE
     , C_XJBFUND
     , EN_MAXREDEEMSCALE
     , EN_MAXREDEEMRATIO
     , C_ESTIMATEDATE
     , C_SECONDTYPE
     , EN_MINSHARENET
     , L_VALIDDATECNT
     , C_PRITOPUB
     , C_RISKMATCHINGCHECK
     , EN_ORGMINSHARE
     , C_PARENTFUND
     , C_ISNEEDCALLBACK
     , C_CONVERSIONSTATUS
     , VC_FULLMANAGER
     , VC_FORBIDBUSIN
     , VC_IRREGULARCONVDATE
     , EN_FOFSCALE
     , EN_TRUSTONELIMIT
     , EN_TRUSTALLLIMIT
     , VC_RISKCHANGEDATE
     , C_OLDRISKLEVEL
     , C_INVESTMENTVARIETIES
     , C_PREYIELDFLAG
     , C_MONFUNDTOPRIVATE
     , C_NEEDCOOLTIME
     , EN_TOTALAVAILABLEHEAD
     , EN_TOTALAVAILABLEVOL
     , L_ALLOTCONFIRMDAY
     , L_REDEEMCONFIRMDAY
     , C_SUPPORTSHARETRANSFER
     , C_DEALFLAG
     , VC_OUTFUNDCODE
     , VC_SUMFUNDCODE
     , C_FORCECHANGEFLAG
     , C_FUNDWHITELIST
     , C_SECONDINVESTCON
     , C_TIMELIMITUNIT
     , C_SUPPORTHALFDAYREDEEM
     , C_EXPCAPITALLIQFILE
     , L_CALMCYCLE
     , EN_FUNDRATIO
     , C_ALLPRECLEAR
     , C_TGRACCOID
     , L_FUNDSTYPE
     , L_YEARLIMIT
     , C_DAYCARRYINCOME
     , C_DAYCONFIRMSHARE
     , C_TEMPORARYRESTFLAG
     , C_MERGEINCOME
     , C_SFINCOMEMERGE
     , C_RETURNOFINCOMEMODE
     , C_ISSUPERCONVERTMONEYFUND
     , C_T0SUBSCRIBE
     , C_T0ALLOT
     , C_T0REDEEM
     , C_CROSSTAFUNDCONVERT
     , VC_INSTRUCTIONSFILE
     , VC_ENGAGEMENTFILE
     , VC_MODREQUESTFILE
     , VC_SUPPLEMENTARYFILE
     , VC_MODVERSIONFILE
     , VC_PRODUCTDESCFILE
     , VC_ANNOUNCEMENTFILE
     , VC_RISKCHANGETIME
     , C_HOLIDAYMARKET
     , C_SUPYELC
     , C_SUPYELCSYMODE
     , C_YELCSYEXPORTMODE
     , C_EXPIREDATETYPE
     , VC_DIVIDENDDATE
     , VC_OPENDATE
     , VC_HOPEREDEEMENDDATE
     , C_SUPGSDY
     , C_DAYSHAREREDEEMFLAG
     , EN_PRECISION
     , EN_PAYMENTRATIO
     , C_SUPBALAREDEEMFLAG
     , C_SHAREVALIDCTRLFLAG
     , C_SHAREVALIDCTRLMODE
     , C_SUPPTRYCALGETPAY
     , EN_FLOATMANAFEEBEGINYIELD
     , EN_FLOATMANAFEERATIO
     , VC_NETNO
     , C_ISSUETYPE
     , VC_ISSUENO
     , VC_ISSUENAME
     , C_PRODUCTTYPE
     , C_REVENUECHARACTERISTICS
     , C_ISSTRUCTURALPRODUCT
     , VC_BEGINDATE
     , VC_ENDDATE
     , VC_EXPLAIN
     , C_EXPORTMODE26EXPIREDATE
     , C_NOEXPORTFISP
     , VC_ANNUITYCODE
     , C_PRODUCTCLASS
     , C_SFGLFGLDCP
     , C_NEWTHIRDBOARD
     , C_SUBSCRIBEACCOID
     , VC_PROMPTREMARKS
     , C_CHECKHOPECODELIMITFLAG
     , C_CHECKFUNDCOOLLIMITFLAG
     , VC_PRODUCTINTERCODE
     , C_SALEMODE
     , VC_ENDLIQDATE
     , EN_ESCROWRATE
     , C_REITS
     , VC_RESPONDEDDAYE
     , L_FUNDOPENDAY
     , C_CATYPE
     , C_REPLENISHSIGNTYPE
     , C_ISEXPJGBS
     , C_LOADPATHFLAG
     , VC_RECORDCODE
     , VC_MAINFUNDCODE
     , C_SIDEBAGFLAG
     , VC_SIDEBAGSTARTDATE
     , C_AUTOEXPORTPRECLEAR
     , C_T0CONVERT
     , C_T0OUTERTRUST
     , C_T0TRANSFER
     , C_SECONDINVESTINFUND
     , C_CHECKFUNDRECORDFLAG
     , C_PROFESSIONDIFF
     , C_PROFESSIONFIRST
     , C_PROFESSIONSECOND
     , C_LIMITMINUSFARE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TFUNDINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TFUNDINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TFUNDINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TFUNDINFO_PFD成功"
      exit 0
   fi
fi
