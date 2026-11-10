#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD_TMP(
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_AGENCYNAME  STRING  COMMENT  '销售商名称',
  C_AGENCYADDRESS  STRING  COMMENT  '总部地址',
  C_AGENCYZIPCODE  STRING  COMMENT  '邮政编码',
  C_AGENCYCONTACT  STRING  COMMENT  '销售商联系人',
  C_AGENCYPHONE  STRING  COMMENT  '销售商联系电话',
  C_AGENCYFAXNO  STRING  COMMENT  '销售商传真号码',
  C_AGENCYMAIL  STRING  COMMENT  '销售商Email',
  C_AGENCYSTATUS  STRING  COMMENT  '销售商状态',
  D_LASTDATE  STRING  COMMENT  '数据最后导入日期',
  C_AGENCYTYPE  STRING  COMMENT  '销售商类型',
  C_DETAIL  STRING  COMMENT  '是否有份额明细',
  C_ZDCODE  STRING  COMMENT  '中国证券登记中心代码',
  C_SHARETYPES  STRING  COMMENT  '支持份额分类',
  C_ZTGONESTEP  STRING  COMMENT  '支持单步转托管入',
  C_PREASSIGN  STRING  COMMENT  '账号预分配',
  L_CSERIALNO  DECIMAL(10,0)  COMMENT  '当前确认序号',
  C_COMPARETYPE  STRING  COMMENT  '对账方式',
  C_MULTITRADEACCO  STRING  COMMENT  '是否支持多交易账号',
  C_IVERSION  STRING  COMMENT  '接口配置版本',
  C_CHANGEONSTEP  STRING  COMMENT  '基金转换确认方式',
  C_CENTERFLAG  STRING  COMMENT  '是否大集中',
  C_LITTLEDEALTYPE  STRING  COMMENT  '小份额处理方式',
  C_OVERTIMEDEAL  STRING  COMMENT  '申请超时处理方式',
  D_LASTINPUTTIME  STRING  COMMENT  '最后导入时间',
  C_CLEARSITE  STRING  COMMENT  '中登清算点',
  C_AGENCYENGLISHNAME  STRING  COMMENT  '销售商英文简称',
  L_FUNDACCONO  DECIMAL(10,0)  COMMENT  '当前基金帐号序列',
  C_RATIONFLAG  STRING  COMMENT  '定期定额上传协议',
  D_OUTPUTDATE  STRING  COMMENT  '数据最后导出日期',
  C_FUNDCODEDEALTYPE  STRING  COMMENT  '分级基金代码处理方式',
  C_MODIFYTRADEACCO  STRING  COMMENT  '数据最后导出日期',
  C_DATAISSUETYPE  STRING  COMMENT  '认购确认失败处理方式',
  C_REGMODIFYINFO  STRING  COMMENT  '账户登记是否修改客户资料',
  C_SCFRDMDEALTYPE  STRING  COMMENT  '短期理财基金赎回方式',
  C_SCFCOMPARETYPE  STRING  COMMENT  '短期理财明细对账方式',
  C_EXPORTC626  STRING  COMMENT  '是否导出C6和26文件',
  C_MGRCODE  STRING  COMMENT  '管理人名称',
  C_LIMITDAYRDMPARTCFM  STRING  COMMENT  '',
  C_CYCLEPRODUCTAGENCYFLAG  STRING  COMMENT  '是否是周期理财销售商',
  C_ISOTC  STRING  COMMENT  '是否OTC产品',
  C_SHORTCFRDMPARTCFM  STRING  COMMENT  '短期理财违约赎回部分确认方式',
  C_CONFIRMCANUSE  STRING  COMMENT  'T日确认的份额T+1日可用',
  C_REALTIMEACCO  STRING  COMMENT  '是否支持实时开户',
  C_IMPECNTRCT  STRING  COMMENT  '导入电子合同',
  C_EXPPARAMFILES  STRING  COMMENT  '导出参数文件(C1~C5)',
  C_ECNTRCTVERSION  STRING  COMMENT  '电子合同接口版本',
  C_EXPORTNAVAFTERFAILOREND  STRING  COMMENT  '导出发行失败或终止状态',
  C_CONFIRMRIGHT  STRING  COMMENT  '确权申请开通标志',
  C_EXPNATURALINCOME  STRING  COMMENT  '',
  C_SUPPORTESHARES  STRING  COMMENT  '现金宝转托管入处理',
  C_NEEDQUOTEFILE  STRING  COMMENT  '',
  C_NEWNAVDATE  STRING  COMMENT  '行情文件使用最新净值日期',
  C_EXPZHENDDATE  STRING  COMMENT  '行情导出专户申赎预约截止日',
  C_EXPNEWINCOME  STRING  COMMENT  '是否导出每日新增收益',
  C_FAILREGTOOPEN  STRING  COMMENT  '',
  C_CANCELCHKTRADEACCO  STRING  COMMENT  '销户时检查交易账号是否登记',
  C_ISRECEIVEBROADCAST  STRING  COMMENT  '',
  C_EXPORTHIFASFILE  STRING  COMMENT  '是否导入HIFAS管理费文件',
  C_OTCVERSION  STRING  COMMENT  '',
  C_ADVANCEEXP  STRING  COMMENT  '',
  C_ISYUEBAO  STRING  COMMENT  '是否为余额理财基金',
  C_EXPYEBDATA  STRING  COMMENT  '是否需要导出余额理财数据',
  C_EXPSCF26DATERULE  STRING  COMMENT  '26文件延期导出下一个可赎回日',
  C_FEDJJDTALAUNCH  STRING  COMMENT  '份额冻结解冻由TA发起',
  L_BATCHNO  DECIMAL(4,0)  COMMENT  '销售商所处清算批次号',
  C_ABCONFREQUESTNO  STRING  COMMENT  '',
  C_ABCONFDATE  STRING  COMMENT  '',
  C_PAWNEE  STRING  COMMENT  '质权人',
  C_PCSFIXEDFEEAGIO  STRING  COMMENT  '认申购固定费用是否打折',
  C_EXPRESTDAYNAV  STRING  COMMENT  '',
  C_AGENCYQRYTYPE  STRING  COMMENT  '销售商机构类别',
  C_ALLOWPLEDGE  STRING  COMMENT  '',
  C_EXP02REALDATA  STRING  COMMENT  '',
  C_AGECREDITCODE  STRING  COMMENT  '销售机构社会信用代码',
  C_AGEREGION  STRING  COMMENT  '销售商所属国家地区',
  C_RDMNOSHAREDEALTYPE  STRING  COMMENT  '赎回确认可用份额不足处理方式',
  C_REGADDRESS  STRING  COMMENT  '注册地址',
  C_LEGALREPRESEN  STRING  COMMENT  '法定代表人',
  C_CUSTSERTEL  STRING  COMMENT  '客服服务电话',
  C_URL  STRING  COMMENT  '网址',
  C_PUBLISHPERSON  STRING  COMMENT  '信息披露人',
  C_DEPCOMPARETYPE  STRING  COMMENT  '',
  C_ALLOWINSTMULTIOPEN  STRING  COMMENT  '是否允许机构客户用一套身份开多个账户',
  C_ISSTANDARD400  STRING  COMMENT  '',
  C_FINALRATIOLIMITCUSTTYPE  STRING  COMMENT  '',
  C_ISEXPXT  STRING  COMMENT  '',
  C_05SHARECLASSCHANGE  STRING  COMMENT  '',
  C_NETNODEALTYPE  STRING  COMMENT  '',
  C_SUBMANULFAILATONCE  STRING  COMMENT  '',
  C_DEPOSITIVER  STRING  COMMENT  '',
  C_SUPPORTCREDITACCO  STRING  COMMENT  '',
  C_CREDITACCOPREFIX  STRING  COMMENT  '',
  C_CHAGETYPE  STRING  COMMENT  '',
  C_ISINPUTENDAGM  STRING  COMMENT  '',
  C_CONFILEDISBATCHNO  STRING  COMMENT  '',
  L_ADVANCENDAYS  DECIMAL(10,0)  COMMENT  '',
  C_05FILEEXPYEBDATA  STRING  COMMENT  '',
  C_PRIVATESHARETRANS  STRING  COMMENT  '',
  C_EXP051ZEROSHARE  STRING  COMMENT  '',
  C_UNTRDTSFSAMEAGEEXPTWOCFM  STRING  COMMENT  '',
  C_02FILEEXPYEBDATA  STRING  COMMENT  '',
  C_MULBATCHALLIMP  STRING  COMMENT  '',
  C_ECNTRCTDELAYCFM  STRING  COMMENT  '',
  C_ISFORMALCODE  STRING  COMMENT  '',
  C_XTVIRTUALAGENCYNO  STRING  COMMENT  '',
  C_FOREIGNRATETYPE  STRING  COMMENT  '',
  C_EXPDEP06_1FILE  STRING  COMMENT  '',
  C_EXPCENTRALIZEDATA  STRING  COMMENT  '',
  C_SHORTCYCLE26FILEEXPTYPE  STRING  COMMENT  '',
  C_CALINTEREST  STRING  COMMENT  '',
  F_AGENCYFEERATIO  DECIMAL(8,7)  COMMENT  '',
  C_SYFILEEXPDETAILDATA  STRING  COMMENT  '',
  C_SUBFAILCALINTEREST  STRING  COMMENT  '',
  C_06FILEEXPYEBDATA  STRING  COMMENT  '',
  C_EXPAGEBYNATURALDAY  STRING  COMMENT  '',
  C_SUPPORTNEW400  STRING  COMMENT  '',
  C_SUPPORTCRSR2  STRING  COMMENT  '',
  C_TRADEACCODIFFNETNO  STRING  COMMENT  '',
  C_06EXPZEROBONUS  STRING  COMMENT  '',
  C_26EXPNEWINCOME  STRING  COMMENT  '',
  C_EXPDEPAGENCY02DATA  STRING  COMMENT  '',
  C_NEW400EXP04FIELD  STRING  COMMENT  '',
  C_INOTHERAGCUPGRADE  STRING  COMMENT  '',
  C_IMPUNIFIEDACTIONMAN  STRING  COMMENT  '',
  C_ISINCOMEHOLDBACK  STRING  COMMENT  '',
  C_GROUPUPPROPERTY  STRING  COMMENT  '',
  C_CHECKINSTITUTIONTYPE  STRING  COMMENT  '',
  L_ACCOPRIORITYNO  DECIMAL(2,0)  COMMENT  '',
  C_EXPORTPF26  STRING  COMMENT  '',
  C_FIXEDFAREAGIO  STRING  COMMENT  '',
  C_EXPFOFEXTRATIO  STRING  COMMENT  '',
  C_AGENTCATEGORY  STRING  COMMENT  '',
  C_ISAUTOAGEFINISH  STRING  COMMENT  '',
  C_ISNETTRADEACCO  STRING  COMMENT  '',
  C_IMPYEBBYFILE  STRING  COMMENT  '',
  C_EXPT0FUNDDAY  STRING  COMMENT  '',
  C_CENTRALIZECODE  STRING  COMMENT  '',
  C_CHGADDFAREDIFFAGIO  STRING  COMMENT  '',
  C_ISNOUPGRADE  STRING  COMMENT  '',
  C_ISEXPREPORT  STRING  COMMENT  '',
  C_ISEXPREPORTOK  STRING  COMMENT  '',
  C_ISEXPREPORTDIR  STRING  COMMENT  '',
  C_EXP05NOTSUBSFUND  STRING  COMMENT  '',
  C_BSHARENOAGCFEE  STRING  COMMENT  '',
  C_YEBMFACCOREDEEMTYPE  STRING  COMMENT  '',
  C_EXPDETAILREQNO  STRING  COMMENT  '',
  C_T0RDMTNPAYINCOME  STRING  COMMENT  '',
  C_TNAGENCYIMPINDEX  STRING  COMMENT  '',
  C_AGENCYCODE  STRING  COMMENT  '',
  C_EXP05BYTABUSIN  STRING  COMMENT  '',
  C_25FILEDISNETNO  STRING  COMMENT  '',
  C_ALLOWNORATION  STRING  COMMENT  '',
  C_ARLIMITEXPTYPE  STRING  COMMENT  '',
  C_EXPYEBACCODATA  STRING  COMMENT  '',
  C_SUPPORTAMLX2X4  STRING  COMMENT  '',
  C_CONDATABATCHEXP  STRING  COMMENT  '',
  C_EXP05TOTALDATA  STRING  COMMENT  '',
  C_ISCHGAGCFILETA  STRING  COMMENT  '',
  C_AGCFILETACODE  STRING  COMMENT  '',
  C_C5EXPCHANGZONE  STRING  COMMENT  '',
  C_REGUPDIDVALIDDATE  STRING  COMMENT  '',
  C_EXPCFM401VER  STRING  COMMENT  '',
  C_EXPYEB098DATA  STRING  COMMENT  '',
  C_EXPHOLD26DATERULE  STRING  COMMENT  '',
  C_CLOSEACCOTYPE  STRING  COMMENT  '',
  C_YEBFILEVERSION  STRING  COMMENT  '',
  C_YEBREQINR1  STRING  COMMENT  '',
  C_YEBREQINX1X3  STRING  COMMENT  '',
  C_C4EXPUNITPROFIT  STRING  COMMENT  '',
  C_SUPPORTSQS  STRING  COMMENT  '',
  C_MULBATCHADDIMP  STRING  COMMENT  '',
  C_T0MULBATCHTYPE  STRING  COMMENT  '',
  C_0506NATURALMS  STRING  COMMENT  '',
  L_AGENCYIMPEXPORDER  DECIMAL(10,0)  COMMENT  '',
  C_EXPPARAMFILEC2  STRING  COMMENT  '',
  C_134WRITEORIREQNO  STRING  COMMENT  '',
  C_CHGBUSFLAGRULE  STRING  COMMENT  '',
  C_EXPTWICEFILE  STRING  COMMENT  '',
  C_NOAMLCONTRLTRADE  STRING  COMMENT  '',
  C_AGENCYBANKNO  STRING  COMMENT  '',
  C_AGENCYBANKACCO  STRING  COMMENT  '',
  C_AGENCYNAMEINBANK  STRING  COMMENT  '',
  C_LARGEPAYBANKNO  STRING  COMMENT  '',
  C_NAVC1MANAGERCODE  STRING  COMMENT  '',
  C_ANTSFEEFILE  STRING  COMMENT  '',
  C_REALTIMECHKVER  STRING  COMMENT  '',
  C_ISSETFINISH  STRING  COMMENT  '',
  C_SCF26EXPFIRSTEND  STRING  COMMENT  '',
  C_SUPPORTRTTACHK  STRING  COMMENT  '',
  C_INTERFACETYPE  STRING  COMMENT  '',
  F_AGENCYFEERATIOFORPERS  DECIMAL(8,7)  COMMENT  '',
  F_AGENCYFEERATIOFORINDUST  DECIMAL(8,7)  COMMENT  '',
  C_AGENCYORGANNO  STRING  COMMENT  '',
  C_ADVANCEEXPAJSHARE  STRING  COMMENT  '',
  C_T0EMERGENCYDEAL  STRING  COMMENT  '',
  C_IMPT0REQ  STRING  COMMENT  '',
  C_AUTOXTEXP  STRING  COMMENT  '',
  C_HIDEFUNDTOTAL  STRING  COMMENT  '',
  C_ISPURCFMSHRZERO  STRING  COMMENT  '',
  C_EXPHBAGENYCNO  STRING  COMMENT  '',
  C_AGENCYFULLNAME  STRING  COMMENT  '',
  C_ZTGOTHTRDACCODEAL  STRING  COMMENT  '',
  C_MODIFYIDORNAME  STRING  COMMENT  '',
  C_ISCALRDMDAY  STRING  COMMENT  '',
  C_NAVEXPTIME  STRING  COMMENT  '',
  C_25FILEEXP54BUSCODERULE  STRING  COMMENT  '',
  C_ECNTRCTFILEVER  STRING  COMMENT  '',
  C_PREASSIGNACCORULE  STRING  COMMENT  '',
  D_ISHOLDYIELDCAL  STRING  COMMENT  '',
  C_DELAYEXPCFMPUBSIDE  STRING  COMMENT  '',
  C_SPTMULTIPATHIO  STRING  COMMENT  '',
  C_I3VERSION  STRING  COMMENT  '',
  C_FUNDENDBIZ  STRING  COMMENT  '',
  C_04CHANGEOUTBALFARE  STRING  COMMENT  '',
  C_25CHANGEOUTBALFARE  STRING  COMMENT  '',
  C_EXP04NOBUSDATA  STRING  COMMENT  '',
  C_EXP26DELSHAREDTL  STRING  COMMENT  '',
  C_05FILEEXPDETAILTYPE  STRING  COMMENT  '',
  C_YEB05TOTALDATA  STRING  COMMENT  '',
  C_01INCLUDEYEBDATA  STRING  COMMENT  '',
  C_FUNDDAYDIR  STRING  COMMENT  '',
  C_CFMEXPDIR  STRING  COMMENT  '',
  C_IMPDEPAGCVERRULE  STRING  COMMENT  '',
  C_CHGFEEREBATE  STRING  COMMENT  '',
  C_SUBRATIOMODE  STRING  COMMENT  '',
  C_IMPKT  STRING  COMMENT  '',
  C_TRDACCOSUPYEB  STRING  COMMENT  '',
  C_DIRECTAGCEXPCON  STRING  COMMENT  '',
  C_REQ0AGIODEAL  STRING  COMMENT  '',
  C_T0UNTRDTSFFACTDATERULE  STRING  COMMENT  '',
  C_07EXPCHGLIMIT  STRING  COMMENT  '',
  C_CHG6TDEFARETYPE  STRING  COMMENT  '',
  C_CALSIXFIXDIFFAGIOLIMIT  STRING  COMMENT  '',
  D_AGENCYREGDATE  STRING  COMMENT  '',
  C_C5EXPSERVICEFARE  STRING  COMMENT  '',
  C_CHGFIXEDFEEAGIO  STRING  COMMENT  '',
  C_AGCACCOUNT  STRING  COMMENT  '',
  C_AGCACCOUNTNAME  STRING  COMMENT  '',
  C_ISEXPREPORTNAME  STRING  COMMENT  '',
  C_BYFUNDMETHOD  STRING  COMMENT  '',
  C_25CFMBALNOPROFIT  STRING  COMMENT  '',
  C_CHANNEL  STRING  COMMENT  '',
  C_REQFILEMULTIIMP  STRING  COMMENT  '',
  C_EXPGFUND26FILE  STRING  COMMENT  '',
  C_GFCOMPARETYPE  STRING  COMMENT  '',
  C_YEBCHKAGCFAILOPENACCO  STRING  COMMENT  ''
)
COMMENT '销售商信息'
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
              "querySql": ["SELECT  C_AGENCYNO
                                   , C_AGENCYNAME
                                   , C_AGENCYADDRESS
                                   , C_AGENCYZIPCODE
                                   , C_AGENCYCONTACT
                                   , C_AGENCYPHONE
                                   , C_AGENCYFAXNO
                                   , C_AGENCYMAIL
                                   , C_AGENCYSTATUS
                                   , D_LASTDATE
                                   , C_AGENCYTYPE
                                   , C_DETAIL
                                   , C_ZDCODE
                                   , C_SHARETYPES
                                   , C_ZTGONESTEP
                                   , C_PREASSIGN
                                   , L_CSERIALNO
                                   , C_COMPARETYPE
                                   , C_MULTITRADEACCO
                                   , C_IVERSION
                                   , C_CHANGEONSTEP
                                   , C_CENTERFLAG
                                   , C_LITTLEDEALTYPE
                                   , C_OVERTIMEDEAL
                                   , D_LASTINPUTTIME
                                   , C_CLEARSITE
                                   , C_AGENCYENGLISHNAME
                                   , L_FUNDACCONO
                                   , C_RATIONFLAG
                                   , D_OUTPUTDATE
                                   , C_FUNDCODEDEALTYPE
                                   , C_MODIFYTRADEACCO
                                   , C_DATAISSUETYPE
                                   , C_REGMODIFYINFO
                                   , C_SCFRDMDEALTYPE
                                   , C_SCFCOMPARETYPE
                                   , C_EXPORTC626
                                   , C_MGRCODE
                                   , C_LIMITDAYRDMPARTCFM
                                   , C_CYCLEPRODUCTAGENCYFLAG
                                   , C_ISOTC
                                   , C_SHORTCFRDMPARTCFM
                                   , C_CONFIRMCANUSE
                                   , C_REALTIMEACCO
                                   , C_IMPECNTRCT
                                   , C_EXPPARAMFILES
                                   , C_ECNTRCTVERSION
                                   , C_EXPORTNAVAFTERFAILOREND
                                   , C_CONFIRMRIGHT
                                   , C_EXPNATURALINCOME
                                   , C_SUPPORTESHARES
                                   , C_NEEDQUOTEFILE
                                   , C_NEWNAVDATE
                                   , C_EXPZHENDDATE
                                   , C_EXPNEWINCOME
                                   , C_FAILREGTOOPEN
                                   , C_CANCELCHKTRADEACCO
                                   , C_ISRECEIVEBROADCAST
                                   , C_EXPORTHIFASFILE
                                   , C_OTCVERSION
                                   , C_ADVANCEEXP
                                   , C_ISYUEBAO
                                   , C_EXPYEBDATA
                                   , C_EXPSCF26DATERULE
                                   , C_FEDJJDTALAUNCH
                                   , L_BATCHNO
                                   , C_ABCONFREQUESTNO
                                   , C_ABCONFDATE
                                   , C_PAWNEE
                                   , C_PCSFIXEDFEEAGIO
                                   , C_EXPRESTDAYNAV
                                   , C_AGENCYQRYTYPE
                                   , C_ALLOWPLEDGE
                                   , C_EXP02REALDATA
                                   , C_AGECREDITCODE
                                   , C_AGEREGION
                                   , C_RDMNOSHAREDEALTYPE
                                   , C_REGADDRESS
                                   , C_LEGALREPRESEN
                                   , C_CUSTSERTEL
                                   , C_URL
                                   , C_PUBLISHPERSON
                                   , C_DEPCOMPARETYPE
                                   , C_ALLOWINSTMULTIOPEN
                                   , C_ISSTANDARD400
                                   , C_FINALRATIOLIMITCUSTTYPE
                                   , C_ISEXPXT
                                   , C_05SHARECLASSCHANGE
                                   , C_NETNODEALTYPE
                                   , C_SUBMANULFAILATONCE
                                   , C_DEPOSITIVER
                                   , C_SUPPORTCREDITACCO
                                   , C_CREDITACCOPREFIX
                                   , C_CHAGETYPE
                                   , C_ISINPUTENDAGM
                                   , C_CONFILEDISBATCHNO
                                   , L_ADVANCENDAYS
                                   , C_05FILEEXPYEBDATA
                                   , C_PRIVATESHARETRANS
                                   , C_EXP051ZEROSHARE
                                   , C_UNTRDTSFSAMEAGEEXPTWOCFM
                                   , C_02FILEEXPYEBDATA
                                   , C_MULBATCHALLIMP
                                   , C_ECNTRCTDELAYCFM
                                   , C_ISFORMALCODE
                                   , C_XTVIRTUALAGENCYNO
                                   , C_FOREIGNRATETYPE
                                   , C_EXPDEP06_1FILE
                                   , C_EXPCENTRALIZEDATA
                                   , C_SHORTCYCLE26FILEEXPTYPE
                                   , C_CALINTEREST
                                   , F_AGENCYFEERATIO
                                   , C_SYFILEEXPDETAILDATA
                                   , C_SUBFAILCALINTEREST
                                   , C_06FILEEXPYEBDATA
                                   , C_EXPAGEBYNATURALDAY
                                   , C_SUPPORTNEW400
                                   , C_SUPPORTCRSR2
                                   , C_TRADEACCODIFFNETNO
                                   , C_06EXPZEROBONUS
                                   , C_26EXPNEWINCOME
                                   , C_EXPDEPAGENCY02DATA
                                   , C_NEW400EXP04FIELD
                                   , C_INOTHERAGCUPGRADE
                                   , C_IMPUNIFIEDACTIONMAN
                                   , C_ISINCOMEHOLDBACK
                                   , C_GROUPUPPROPERTY
                                   , C_CHECKINSTITUTIONTYPE
                                   , L_ACCOPRIORITYNO
                                   , C_EXPORTPF26
                                   , C_FIXEDFAREAGIO
                                   , C_EXPFOFEXTRATIO
                                   , C_AGENTCATEGORY
                                   , C_ISAUTOAGEFINISH
                                   , C_ISNETTRADEACCO
                                   , C_IMPYEBBYFILE
                                   , C_EXPT0FUNDDAY
                                   , C_CENTRALIZECODE
                                   , C_CHGADDFAREDIFFAGIO
                                   , C_ISNOUPGRADE
                                   , C_ISEXPREPORT
                                   , C_ISEXPREPORTOK
                                   , C_ISEXPREPORTDIR
                                   , C_EXP05NOTSUBSFUND
                                   , C_BSHARENOAGCFEE
                                   , C_YEBMFACCOREDEEMTYPE
                                   , C_EXPDETAILREQNO
                                   , C_T0RDMTNPAYINCOME
                                   , C_TNAGENCYIMPINDEX
                                   , C_AGENCYCODE
                                   , C_EXP05BYTABUSIN
                                   , C_25FILEDISNETNO
                                   , C_ALLOWNORATION
                                   , C_ARLIMITEXPTYPE
                                   , C_EXPYEBACCODATA
                                   , C_SUPPORTAMLX2X4
                                   , C_CONDATABATCHEXP
                                   , C_EXP05TOTALDATA
                                   , C_ISCHGAGCFILETA
                                   , C_AGCFILETACODE
                                   , C_C5EXPCHANGZONE
                                   , C_REGUPDIDVALIDDATE
                                   , C_EXPCFM401VER
                                   , C_EXPYEB098DATA
                                   , C_EXPHOLD26DATERULE
                                   , C_CLOSEACCOTYPE
                                   , C_YEBFILEVERSION
                                   , C_YEBREQINR1
                                   , C_YEBREQINX1X3
                                   , C_C4EXPUNITPROFIT
                                   , C_SUPPORTSQS
                                   , C_MULBATCHADDIMP
                                   , C_T0MULBATCHTYPE
                                   , C_0506NATURALMS
                                   , L_AGENCYIMPEXPORDER
                                   , C_EXPPARAMFILEC2
                                   , C_134WRITEORIREQNO
                                   , C_CHGBUSFLAGRULE
                                   , C_EXPTWICEFILE
                                   , C_NOAMLCONTRLTRADE
                                   , C_AGENCYBANKNO
                                   , C_AGENCYBANKACCO
                                   , C_AGENCYNAMEINBANK
                                   , C_LARGEPAYBANKNO
                                   , C_NAVC1MANAGERCODE
                                   , C_ANTSFEEFILE
                                   , C_REALTIMECHKVER
                                   , C_ISSETFINISH
                                   , C_SCF26EXPFIRSTEND
                                   , C_SUPPORTRTTACHK
                                   , C_INTERFACETYPE
                                   , F_AGENCYFEERATIOFORPERS
                                   , F_AGENCYFEERATIOFORINDUST
                                   , C_AGENCYORGANNO
                                   , C_ADVANCEEXPAJSHARE
                                   , C_T0EMERGENCYDEAL
                                   , C_IMPT0REQ
                                   , C_AUTOXTEXP
                                   , C_HIDEFUNDTOTAL
                                   , C_ISPURCFMSHRZERO
                                   , C_EXPHBAGENYCNO
                                   , C_AGENCYFULLNAME
                                   , C_ZTGOTHTRDACCODEAL
                                   , C_MODIFYIDORNAME
                                   , C_ISCALRDMDAY
                                   , C_NAVEXPTIME
                                   , C_25FILEEXP54BUSCODERULE
                                   , C_ECNTRCTFILEVER
                                   , C_PREASSIGNACCORULE
                                   , D_ISHOLDYIELDCAL
                                   , C_DELAYEXPCFMPUBSIDE
                                   , C_SPTMULTIPATHIO
                                   , C_I3VERSION
                                   , C_FUNDENDBIZ
                                   , C_04CHANGEOUTBALFARE
                                   , C_25CHANGEOUTBALFARE
                                   , C_EXP04NOBUSDATA
                                   , C_EXP26DELSHAREDTL
                                   , C_05FILEEXPDETAILTYPE
                                   , C_YEB05TOTALDATA
                                   , C_01INCLUDEYEBDATA
                                   , C_FUNDDAYDIR
                                   , C_CFMEXPDIR
                                   , C_IMPDEPAGCVERRULE
                                   , C_CHGFEEREBATE
                                   , C_SUBRATIOMODE
                                   , C_IMPKT
                                   , C_TRDACCOSUPYEB
                                   , C_DIRECTAGCEXPCON
                                   , C_REQ0AGIODEAL
                                   , C_T0UNTRDTSFFACTDATERULE
                                   , C_07EXPCHGLIMIT
                                   , C_CHG6TDEFARETYPE
                                   , C_CALSIXFIXDIFFAGIOLIMIT
                                   , D_AGENCYREGDATE
                                   , C_C5EXPSERVICEFARE
                                   , C_CHGFIXEDFEEAGIO
                                   , C_AGCACCOUNT
                                   , C_AGCACCOUNTNAME
                                   , C_ISEXPREPORTNAME
                                   , C_BYFUNDMETHOD
                                   , C_25CFMBALNOPROFIT
                                   , C_CHANNEL
                                   , C_REQFILEMULTIIMP
                                   , C_EXPGFUND26FILE
                                   , C_GFCOMPARETYPE
                                   , C_YEBCHKAGCFAILOPENACCO
                                FROM ${hszta_src_schema}.TAGENCYINFO"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_AGENCYNAME", "type": "STRING"}, {"name": "C_AGENCYADDRESS", "type": "STRING"}, {"name": "C_AGENCYZIPCODE", "type": "STRING"}, {"name": "C_AGENCYCONTACT", "type": "STRING"}, {"name": "C_AGENCYPHONE", "type": "STRING"}, {"name": "C_AGENCYFAXNO", "type": "STRING"}, {"name": "C_AGENCYMAIL", "type": "STRING"}, {"name": "C_AGENCYSTATUS", "type": "STRING"}, {"name": "D_LASTDATE", "type": "STRING"}, {"name": "C_AGENCYTYPE", "type": "STRING"}, {"name": "C_DETAIL", "type": "STRING"}, {"name": "C_ZDCODE", "type": "STRING"}, {"name": "C_SHARETYPES", "type": "STRING"}, {"name": "C_ZTGONESTEP", "type": "STRING"}, {"name": "C_PREASSIGN", "type": "STRING"}, {"name": "L_CSERIALNO", "type": "DOUBLE"}, {"name": "C_COMPARETYPE", "type": "STRING"}, {"name": "C_MULTITRADEACCO", "type": "STRING"}, {"name": "C_IVERSION", "type": "STRING"}, {"name": "C_CHANGEONSTEP", "type": "STRING"}, {"name": "C_CENTERFLAG", "type": "STRING"}, {"name": "C_LITTLEDEALTYPE", "type": "STRING"}, {"name": "C_OVERTIMEDEAL", "type": "STRING"}, {"name": "D_LASTINPUTTIME", "type": "STRING"}, {"name": "C_CLEARSITE", "type": "STRING"}, {"name": "C_AGENCYENGLISHNAME", "type": "STRING"}, {"name": "L_FUNDACCONO", "type": "DOUBLE"}, {"name": "C_RATIONFLAG", "type": "STRING"}, {"name": "D_OUTPUTDATE", "type": "STRING"}, {"name": "C_FUNDCODEDEALTYPE", "type": "STRING"}, {"name": "C_MODIFYTRADEACCO", "type": "STRING"}, {"name": "C_DATAISSUETYPE", "type": "STRING"}, {"name": "C_REGMODIFYINFO", "type": "STRING"}, {"name": "C_SCFRDMDEALTYPE", "type": "STRING"}, {"name": "C_SCFCOMPARETYPE", "type": "STRING"}, {"name": "C_EXPORTC626", "type": "STRING"}, {"name": "C_MGRCODE", "type": "STRING"}, {"name": "C_LIMITDAYRDMPARTCFM", "type": "STRING"}, {"name": "C_CYCLEPRODUCTAGENCYFLAG", "type": "STRING"}, {"name": "C_ISOTC", "type": "STRING"}, {"name": "C_SHORTCFRDMPARTCFM", "type": "STRING"}, {"name": "C_CONFIRMCANUSE", "type": "STRING"}, {"name": "C_REALTIMEACCO", "type": "STRING"}, {"name": "C_IMPECNTRCT", "type": "STRING"}, {"name": "C_EXPPARAMFILES", "type": "STRING"}, {"name": "C_ECNTRCTVERSION", "type": "STRING"}, {"name": "C_EXPORTNAVAFTERFAILOREND", "type": "STRING"}, {"name": "C_CONFIRMRIGHT", "type": "STRING"}, {"name": "C_EXPNATURALINCOME", "type": "STRING"}, {"name": "C_SUPPORTESHARES", "type": "STRING"}, {"name": "C_NEEDQUOTEFILE", "type": "STRING"}, {"name": "C_NEWNAVDATE", "type": "STRING"}, {"name": "C_EXPZHENDDATE", "type": "STRING"}, {"name": "C_EXPNEWINCOME", "type": "STRING"}, {"name": "C_FAILREGTOOPEN", "type": "STRING"}, {"name": "C_CANCELCHKTRADEACCO", "type": "STRING"}, {"name": "C_ISRECEIVEBROADCAST", "type": "STRING"}, {"name": "C_EXPORTHIFASFILE", "type": "STRING"}, {"name": "C_OTCVERSION", "type": "STRING"}, {"name": "C_ADVANCEEXP", "type": "STRING"}, {"name": "C_ISYUEBAO", "type": "STRING"}, {"name": "C_EXPYEBDATA", "type": "STRING"}, {"name": "C_EXPSCF26DATERULE", "type": "STRING"}, {"name": "C_FEDJJDTALAUNCH", "type": "STRING"}, {"name": "L_BATCHNO", "type": "DOUBLE"}, {"name": "C_ABCONFREQUESTNO", "type": "STRING"}, {"name": "C_ABCONFDATE", "type": "STRING"}, {"name": "C_PAWNEE", "type": "STRING"}, {"name": "C_PCSFIXEDFEEAGIO", "type": "STRING"}, {"name": "C_EXPRESTDAYNAV", "type": "STRING"}, {"name": "C_AGENCYQRYTYPE", "type": "STRING"}, {"name": "C_ALLOWPLEDGE", "type": "STRING"}, {"name": "C_EXP02REALDATA", "type": "STRING"}, {"name": "C_AGECREDITCODE", "type": "STRING"}, {"name": "C_AGEREGION", "type": "STRING"}, {"name": "C_RDMNOSHAREDEALTYPE", "type": "STRING"}, {"name": "C_REGADDRESS", "type": "STRING"}, {"name": "C_LEGALREPRESEN", "type": "STRING"}, {"name": "C_CUSTSERTEL", "type": "STRING"}, {"name": "C_URL", "type": "STRING"}, {"name": "C_PUBLISHPERSON", "type": "STRING"}, {"name": "C_DEPCOMPARETYPE", "type": "STRING"}, {"name": "C_ALLOWINSTMULTIOPEN", "type": "STRING"}, {"name": "C_ISSTANDARD400", "type": "STRING"}, {"name": "C_FINALRATIOLIMITCUSTTYPE", "type": "STRING"}, {"name": "C_ISEXPXT", "type": "STRING"}, {"name": "C_05SHARECLASSCHANGE", "type": "STRING"}, {"name": "C_NETNODEALTYPE", "type": "STRING"}, {"name": "C_SUBMANULFAILATONCE", "type": "STRING"}, {"name": "C_DEPOSITIVER", "type": "STRING"}, {"name": "C_SUPPORTCREDITACCO", "type": "STRING"}, {"name": "C_CREDITACCOPREFIX", "type": "STRING"}, {"name": "C_CHAGETYPE", "type": "STRING"}, {"name": "C_ISINPUTENDAGM", "type": "STRING"}, {"name": "C_CONFILEDISBATCHNO", "type": "STRING"}, {"name": "L_ADVANCENDAYS", "type": "DOUBLE"}, {"name": "C_05FILEEXPYEBDATA", "type": "STRING"}, {"name": "C_PRIVATESHARETRANS", "type": "STRING"}, {"name": "C_EXP051ZEROSHARE", "type": "STRING"}, {"name": "C_UNTRDTSFSAMEAGEEXPTWOCFM", "type": "STRING"}, {"name": "C_02FILEEXPYEBDATA", "type": "STRING"}, {"name": "C_MULBATCHALLIMP", "type": "STRING"}, {"name": "C_ECNTRCTDELAYCFM", "type": "STRING"}, {"name": "C_ISFORMALCODE", "type": "STRING"}, {"name": "C_XTVIRTUALAGENCYNO", "type": "STRING"}, {"name": "C_FOREIGNRATETYPE", "type": "STRING"}, {"name": "C_EXPDEP06_1FILE", "type": "STRING"}, {"name": "C_EXPCENTRALIZEDATA", "type": "STRING"}, {"name": "C_SHORTCYCLE26FILEEXPTYPE", "type": "STRING"}, {"name": "C_CALINTEREST", "type": "STRING"}, {"name": "F_AGENCYFEERATIO", "type": "DOUBLE"}, {"name": "C_SYFILEEXPDETAILDATA", "type": "STRING"}, {"name": "C_SUBFAILCALINTEREST", "type": "STRING"}, {"name": "C_06FILEEXPYEBDATA", "type": "STRING"}, {"name": "C_EXPAGEBYNATURALDAY", "type": "STRING"}, {"name": "C_SUPPORTNEW400", "type": "STRING"}, {"name": "C_SUPPORTCRSR2", "type": "STRING"}, {"name": "C_TRADEACCODIFFNETNO", "type": "STRING"}, {"name": "C_06EXPZEROBONUS", "type": "STRING"}, {"name": "C_26EXPNEWINCOME", "type": "STRING"}, {"name": "C_EXPDEPAGENCY02DATA", "type": "STRING"}, {"name": "C_NEW400EXP04FIELD", "type": "STRING"}, {"name": "C_INOTHERAGCUPGRADE", "type": "STRING"}, {"name": "C_IMPUNIFIEDACTIONMAN", "type": "STRING"}, {"name": "C_ISINCOMEHOLDBACK", "type": "STRING"}, {"name": "C_GROUPUPPROPERTY", "type": "STRING"}, {"name": "C_CHECKINSTITUTIONTYPE", "type": "STRING"}, {"name": "L_ACCOPRIORITYNO", "type": "DOUBLE"}, {"name": "C_EXPORTPF26", "type": "STRING"}, {"name": "C_FIXEDFAREAGIO", "type": "STRING"}, {"name": "C_EXPFOFEXTRATIO", "type": "STRING"}, {"name": "C_AGENTCATEGORY", "type": "STRING"}, {"name": "C_ISAUTOAGEFINISH", "type": "STRING"}, {"name": "C_ISNETTRADEACCO", "type": "STRING"}, {"name": "C_IMPYEBBYFILE", "type": "STRING"}, {"name": "C_EXPT0FUNDDAY", "type": "STRING"}, {"name": "C_CENTRALIZECODE", "type": "STRING"}, {"name": "C_CHGADDFAREDIFFAGIO", "type": "STRING"}, {"name": "C_ISNOUPGRADE", "type": "STRING"}, {"name": "C_ISEXPREPORT", "type": "STRING"}, {"name": "C_ISEXPREPORTOK", "type": "STRING"}, {"name": "C_ISEXPREPORTDIR", "type": "STRING"}, {"name": "C_EXP05NOTSUBSFUND", "type": "STRING"}, {"name": "C_BSHARENOAGCFEE", "type": "STRING"}, {"name": "C_YEBMFACCOREDEEMTYPE", "type": "STRING"}, {"name": "C_EXPDETAILREQNO", "type": "STRING"}, {"name": "C_T0RDMTNPAYINCOME", "type": "STRING"}, {"name": "C_TNAGENCYIMPINDEX", "type": "STRING"}, {"name": "C_AGENCYCODE", "type": "STRING"}, {"name": "C_EXP05BYTABUSIN", "type": "STRING"}, {"name": "C_25FILEDISNETNO", "type": "STRING"}, {"name": "C_ALLOWNORATION", "type": "STRING"}, {"name": "C_ARLIMITEXPTYPE", "type": "STRING"}, {"name": "C_EXPYEBACCODATA", "type": "STRING"}, {"name": "C_SUPPORTAMLX2X4", "type": "STRING"}, {"name": "C_CONDATABATCHEXP", "type": "STRING"}, {"name": "C_EXP05TOTALDATA", "type": "STRING"}, {"name": "C_ISCHGAGCFILETA", "type": "STRING"}, {"name": "C_AGCFILETACODE", "type": "STRING"}, {"name": "C_C5EXPCHANGZONE", "type": "STRING"}, {"name": "C_REGUPDIDVALIDDATE", "type": "STRING"}, {"name": "C_EXPCFM401VER", "type": "STRING"}, {"name": "C_EXPYEB098DATA", "type": "STRING"}, {"name": "C_EXPHOLD26DATERULE", "type": "STRING"}, {"name": "C_CLOSEACCOTYPE", "type": "STRING"}, {"name": "C_YEBFILEVERSION", "type": "STRING"}, {"name": "C_YEBREQINR1", "type": "STRING"}, {"name": "C_YEBREQINX1X3", "type": "STRING"}, {"name": "C_C4EXPUNITPROFIT", "type": "STRING"}, {"name": "C_SUPPORTSQS", "type": "STRING"}, {"name": "C_MULBATCHADDIMP", "type": "STRING"}, {"name": "C_T0MULBATCHTYPE", "type": "STRING"}, {"name": "C_0506NATURALMS", "type": "STRING"}, {"name": "L_AGENCYIMPEXPORDER", "type": "DOUBLE"}, {"name": "C_EXPPARAMFILEC2", "type": "STRING"}, {"name": "C_134WRITEORIREQNO", "type": "STRING"}, {"name": "C_CHGBUSFLAGRULE", "type": "STRING"}, {"name": "C_EXPTWICEFILE", "type": "STRING"}, {"name": "C_NOAMLCONTRLTRADE", "type": "STRING"}, {"name": "C_AGENCYBANKNO", "type": "STRING"}, {"name": "C_AGENCYBANKACCO", "type": "STRING"}, {"name": "C_AGENCYNAMEINBANK", "type": "STRING"}, {"name": "C_LARGEPAYBANKNO", "type": "STRING"}, {"name": "C_NAVC1MANAGERCODE", "type": "STRING"}, {"name": "C_ANTSFEEFILE", "type": "STRING"}, {"name": "C_REALTIMECHKVER", "type": "STRING"}, {"name": "C_ISSETFINISH", "type": "STRING"}, {"name": "C_SCF26EXPFIRSTEND", "type": "STRING"}, {"name": "C_SUPPORTRTTACHK", "type": "STRING"}, {"name": "C_INTERFACETYPE", "type": "STRING"}, {"name": "F_AGENCYFEERATIOFORPERS", "type": "DOUBLE"}, {"name": "F_AGENCYFEERATIOFORINDUST", "type": "DOUBLE"}, {"name": "C_AGENCYORGANNO", "type": "STRING"}, {"name": "C_ADVANCEEXPAJSHARE", "type": "STRING"}, {"name": "C_T0EMERGENCYDEAL", "type": "STRING"}, {"name": "C_IMPT0REQ", "type": "STRING"}, {"name": "C_AUTOXTEXP", "type": "STRING"}, {"name": "C_HIDEFUNDTOTAL", "type": "STRING"}, {"name": "C_ISPURCFMSHRZERO", "type": "STRING"}, {"name": "C_EXPHBAGENYCNO", "type": "STRING"}, {"name": "C_AGENCYFULLNAME", "type": "STRING"}, {"name": "C_ZTGOTHTRDACCODEAL", "type": "STRING"}, {"name": "C_MODIFYIDORNAME", "type": "STRING"}, {"name": "C_ISCALRDMDAY", "type": "STRING"}, {"name": "C_NAVEXPTIME", "type": "STRING"}, {"name": "C_25FILEEXP54BUSCODERULE", "type": "STRING"}, {"name": "C_ECNTRCTFILEVER", "type": "STRING"}, {"name": "C_PREASSIGNACCORULE", "type": "STRING"}, {"name": "D_ISHOLDYIELDCAL", "type": "STRING"}, {"name": "C_DELAYEXPCFMPUBSIDE", "type": "STRING"}, {"name": "C_SPTMULTIPATHIO", "type": "STRING"}, {"name": "C_I3VERSION", "type": "STRING"}, {"name": "C_FUNDENDBIZ", "type": "STRING"}, {"name": "C_04CHANGEOUTBALFARE", "type": "STRING"}, {"name": "C_25CHANGEOUTBALFARE", "type": "STRING"}, {"name": "C_EXP04NOBUSDATA", "type": "STRING"}, {"name": "C_EXP26DELSHAREDTL", "type": "STRING"}, {"name": "C_05FILEEXPDETAILTYPE", "type": "STRING"}, {"name": "C_YEB05TOTALDATA", "type": "STRING"}, {"name": "C_01INCLUDEYEBDATA", "type": "STRING"}, {"name": "C_FUNDDAYDIR", "type": "STRING"}, {"name": "C_CFMEXPDIR", "type": "STRING"}, {"name": "C_IMPDEPAGCVERRULE", "type": "STRING"}, {"name": "C_CHGFEEREBATE", "type": "STRING"}, {"name": "C_SUBRATIOMODE", "type": "STRING"}, {"name": "C_IMPKT", "type": "STRING"}, {"name": "C_TRDACCOSUPYEB", "type": "STRING"}, {"name": "C_DIRECTAGCEXPCON", "type": "STRING"}, {"name": "C_REQ0AGIODEAL", "type": "STRING"}, {"name": "C_T0UNTRDTSFFACTDATERULE", "type": "STRING"}, {"name": "C_07EXPCHGLIMIT", "type": "STRING"}, {"name": "C_CHG6TDEFARETYPE", "type": "STRING"}, {"name": "C_CALSIXFIXDIFFAGIOLIMIT", "type": "STRING"}, {"name": "D_AGENCYREGDATE", "type": "STRING"}, {"name": "C_C5EXPSERVICEFARE", "type": "STRING"}, {"name": "C_CHGFIXEDFEEAGIO", "type": "STRING"}, {"name": "C_AGCACCOUNT", "type": "STRING"}, {"name": "C_AGCACCOUNTNAME", "type": "STRING"}, {"name": "C_ISEXPREPORTNAME", "type": "STRING"}, {"name": "C_BYFUNDMETHOD", "type": "STRING"}, {"name": "C_25CFMBALNOPROFIT", "type": "STRING"}, {"name": "C_CHANNEL", "type": "STRING"}, {"name": "C_REQFILEMULTIIMP", "type": "STRING"}, {"name": "C_EXPGFUND26FILE", "type": "STRING"}, {"name": "C_GFCOMPARETYPE", "type": "STRING"}, {"name": "C_YEBCHKAGCFAILOPENACCO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tagencyinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tagencyinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tagencyinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tagencyinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TAGENCYINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TAGENCYINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tagencyinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_AGENCYNO
     , C_AGENCYNAME
     , C_AGENCYADDRESS
     , C_AGENCYZIPCODE
     , C_AGENCYCONTACT
     , C_AGENCYPHONE
     , C_AGENCYFAXNO
     , C_AGENCYMAIL
     , C_AGENCYSTATUS
     , D_LASTDATE
     , C_AGENCYTYPE
     , C_DETAIL
     , C_ZDCODE
     , C_SHARETYPES
     , C_ZTGONESTEP
     , C_PREASSIGN
     , L_CSERIALNO
     , C_COMPARETYPE
     , C_MULTITRADEACCO
     , C_IVERSION
     , C_CHANGEONSTEP
     , C_CENTERFLAG
     , C_LITTLEDEALTYPE
     , C_OVERTIMEDEAL
     , D_LASTINPUTTIME
     , C_CLEARSITE
     , C_AGENCYENGLISHNAME
     , L_FUNDACCONO
     , C_RATIONFLAG
     , D_OUTPUTDATE
     , C_FUNDCODEDEALTYPE
     , C_MODIFYTRADEACCO
     , C_DATAISSUETYPE
     , C_REGMODIFYINFO
     , C_SCFRDMDEALTYPE
     , C_SCFCOMPARETYPE
     , C_EXPORTC626
     , C_MGRCODE
     , C_LIMITDAYRDMPARTCFM
     , C_CYCLEPRODUCTAGENCYFLAG
     , C_ISOTC
     , C_SHORTCFRDMPARTCFM
     , C_CONFIRMCANUSE
     , C_REALTIMEACCO
     , C_IMPECNTRCT
     , C_EXPPARAMFILES
     , C_ECNTRCTVERSION
     , C_EXPORTNAVAFTERFAILOREND
     , C_CONFIRMRIGHT
     , C_EXPNATURALINCOME
     , C_SUPPORTESHARES
     , C_NEEDQUOTEFILE
     , C_NEWNAVDATE
     , C_EXPZHENDDATE
     , C_EXPNEWINCOME
     , C_FAILREGTOOPEN
     , C_CANCELCHKTRADEACCO
     , C_ISRECEIVEBROADCAST
     , C_EXPORTHIFASFILE
     , C_OTCVERSION
     , C_ADVANCEEXP
     , C_ISYUEBAO
     , C_EXPYEBDATA
     , C_EXPSCF26DATERULE
     , C_FEDJJDTALAUNCH
     , L_BATCHNO
     , C_ABCONFREQUESTNO
     , C_ABCONFDATE
     , C_PAWNEE
     , C_PCSFIXEDFEEAGIO
     , C_EXPRESTDAYNAV
     , C_AGENCYQRYTYPE
     , C_ALLOWPLEDGE
     , C_EXP02REALDATA
     , C_AGECREDITCODE
     , C_AGEREGION
     , C_RDMNOSHAREDEALTYPE
     , C_REGADDRESS
     , C_LEGALREPRESEN
     , C_CUSTSERTEL
     , C_URL
     , C_PUBLISHPERSON
     , C_DEPCOMPARETYPE
     , C_ALLOWINSTMULTIOPEN
     , C_ISSTANDARD400
     , C_FINALRATIOLIMITCUSTTYPE
     , C_ISEXPXT
     , C_05SHARECLASSCHANGE
     , C_NETNODEALTYPE
     , C_SUBMANULFAILATONCE
     , C_DEPOSITIVER
     , C_SUPPORTCREDITACCO
     , C_CREDITACCOPREFIX
     , C_CHAGETYPE
     , C_ISINPUTENDAGM
     , C_CONFILEDISBATCHNO
     , L_ADVANCENDAYS
     , C_05FILEEXPYEBDATA
     , C_PRIVATESHARETRANS
     , C_EXP051ZEROSHARE
     , C_UNTRDTSFSAMEAGEEXPTWOCFM
     , C_02FILEEXPYEBDATA
     , C_MULBATCHALLIMP
     , C_ECNTRCTDELAYCFM
     , C_ISFORMALCODE
     , C_XTVIRTUALAGENCYNO
     , C_FOREIGNRATETYPE
     , C_EXPDEP06_1FILE
     , C_EXPCENTRALIZEDATA
     , C_SHORTCYCLE26FILEEXPTYPE
     , C_CALINTEREST
     , F_AGENCYFEERATIO
     , C_SYFILEEXPDETAILDATA
     , C_SUBFAILCALINTEREST
     , C_06FILEEXPYEBDATA
     , C_EXPAGEBYNATURALDAY
     , C_SUPPORTNEW400
     , C_SUPPORTCRSR2
     , C_TRADEACCODIFFNETNO
     , C_06EXPZEROBONUS
     , C_26EXPNEWINCOME
     , C_EXPDEPAGENCY02DATA
     , C_NEW400EXP04FIELD
     , C_INOTHERAGCUPGRADE
     , C_IMPUNIFIEDACTIONMAN
     , C_ISINCOMEHOLDBACK
     , C_GROUPUPPROPERTY
     , C_CHECKINSTITUTIONTYPE
     , L_ACCOPRIORITYNO
     , C_EXPORTPF26
     , C_FIXEDFAREAGIO
     , C_EXPFOFEXTRATIO
     , C_AGENTCATEGORY
     , C_ISAUTOAGEFINISH
     , C_ISNETTRADEACCO
     , C_IMPYEBBYFILE
     , C_EXPT0FUNDDAY
     , C_CENTRALIZECODE
     , C_CHGADDFAREDIFFAGIO
     , C_ISNOUPGRADE
     , C_ISEXPREPORT
     , C_ISEXPREPORTOK
     , C_ISEXPREPORTDIR
     , C_EXP05NOTSUBSFUND
     , C_BSHARENOAGCFEE
     , C_YEBMFACCOREDEEMTYPE
     , C_EXPDETAILREQNO
     , C_T0RDMTNPAYINCOME
     , C_TNAGENCYIMPINDEX
     , C_AGENCYCODE
     , C_EXP05BYTABUSIN
     , C_25FILEDISNETNO
     , C_ALLOWNORATION
     , C_ARLIMITEXPTYPE
     , C_EXPYEBACCODATA
     , C_SUPPORTAMLX2X4
     , C_CONDATABATCHEXP
     , C_EXP05TOTALDATA
     , C_ISCHGAGCFILETA
     , C_AGCFILETACODE
     , C_C5EXPCHANGZONE
     , C_REGUPDIDVALIDDATE
     , C_EXPCFM401VER
     , C_EXPYEB098DATA
     , C_EXPHOLD26DATERULE
     , C_CLOSEACCOTYPE
     , C_YEBFILEVERSION
     , C_YEBREQINR1
     , C_YEBREQINX1X3
     , C_C4EXPUNITPROFIT
     , C_SUPPORTSQS
     , C_MULBATCHADDIMP
     , C_T0MULBATCHTYPE
     , C_0506NATURALMS
     , L_AGENCYIMPEXPORDER
     , C_EXPPARAMFILEC2
     , C_134WRITEORIREQNO
     , C_CHGBUSFLAGRULE
     , C_EXPTWICEFILE
     , C_NOAMLCONTRLTRADE
     , C_AGENCYBANKNO
     , C_AGENCYBANKACCO
     , C_AGENCYNAMEINBANK
     , C_LARGEPAYBANKNO
     , C_NAVC1MANAGERCODE
     , C_ANTSFEEFILE
     , C_REALTIMECHKVER
     , C_ISSETFINISH
     , C_SCF26EXPFIRSTEND
     , C_SUPPORTRTTACHK
     , C_INTERFACETYPE
     , F_AGENCYFEERATIOFORPERS
     , F_AGENCYFEERATIOFORINDUST
     , C_AGENCYORGANNO
     , C_ADVANCEEXPAJSHARE
     , C_T0EMERGENCYDEAL
     , C_IMPT0REQ
     , C_AUTOXTEXP
     , C_HIDEFUNDTOTAL
     , C_ISPURCFMSHRZERO
     , C_EXPHBAGENYCNO
     , C_AGENCYFULLNAME
     , C_ZTGOTHTRDACCODEAL
     , C_MODIFYIDORNAME
     , C_ISCALRDMDAY
     , C_NAVEXPTIME
     , C_25FILEEXP54BUSCODERULE
     , C_ECNTRCTFILEVER
     , C_PREASSIGNACCORULE
     , D_ISHOLDYIELDCAL
     , C_DELAYEXPCFMPUBSIDE
     , C_SPTMULTIPATHIO
     , C_I3VERSION
     , C_FUNDENDBIZ
     , C_04CHANGEOUTBALFARE
     , C_25CHANGEOUTBALFARE
     , C_EXP04NOBUSDATA
     , C_EXP26DELSHAREDTL
     , C_05FILEEXPDETAILTYPE
     , C_YEB05TOTALDATA
     , C_01INCLUDEYEBDATA
     , C_FUNDDAYDIR
     , C_CFMEXPDIR
     , C_IMPDEPAGCVERRULE
     , C_CHGFEEREBATE
     , C_SUBRATIOMODE
     , C_IMPKT
     , C_TRDACCOSUPYEB
     , C_DIRECTAGCEXPCON
     , C_REQ0AGIODEAL
     , C_T0UNTRDTSFFACTDATERULE
     , C_07EXPCHGLIMIT
     , C_CHG6TDEFARETYPE
     , C_CALSIXFIXDIFFAGIOLIMIT
     , D_AGENCYREGDATE
     , C_C5EXPSERVICEFARE
     , C_CHGFIXEDFEEAGIO
     , C_AGCACCOUNT
     , C_AGCACCOUNTNAME
     , C_ISEXPREPORTNAME
     , C_BYFUNDMETHOD
     , C_25CFMBALNOPROFIT
     , C_CHANNEL
     , C_REQFILEMULTIIMP
     , C_EXPGFUND26FILE
     , C_GFCOMPARETYPE
     , C_YEBCHKAGCFAILOPENACCO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TAGENCYINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TAGENCYINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TAGENCYINFO_PFD成功"
      exit 0
   fi
fi
