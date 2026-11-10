#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_SHARETYPES  STRING  COMMENT  '份额类别',
  C_SUBBALANCETYPE  STRING  COMMENT  '认购款到账方式',
  C_TNTYPE  STRING  COMMENT  'T＋n方式',
  F_SERVICERATIO  DECIMAL(7,6)  COMMENT  '销售服务费率',
  L_BANKACCONO  STRING  COMMENT  '清算银行编号',
  F_FEWFORCEINVEST  DECIMAL(16,2)  COMMENT  '最小现金红利',
  L_FAREBANKACCONO  STRING  COMMENT  '费用清算银行编号',
  C_CONFIRMRIGHT  STRING  COMMENT  '确权申请开通标志',
  D_SERVFAREBGNDATE  STRING  COMMENT  '销售服务费起始日期',
  D_SERVFAREENDDATE  STRING  COMMENT  '销售服务费截止日期',
  C_PAYFREQ  STRING  COMMENT  '服务费支付频率',
  D_CONTRACTDATE  STRING  COMMENT  '签约起始日期',
  C_ALLOTLIQTYPE  STRING  COMMENT  '申购资金交收方式',
  C_REDEEMLIQTYPE  STRING  COMMENT  '赎回资金交收方式',
  C_BACKFAREMODE  STRING  COMMENT  '后收费分成模式',
  L_ACCONUM  DECIMAL(3,0)  COMMENT  '专户产品最大账户数',
  C_ALLOWEDBREACHRDM  STRING  COMMENT  '是否允许发起违约赎回',
  C_RATIONAGIOMODE  STRING  COMMENT  '定投优惠模式',
  D_EXPORTEDDATE  STRING  COMMENT  '',
  C_EXTRADEALTYPE  STRING  COMMENT  '超额申购的处理模式',
  C_CMPECONTRACT  STRING  COMMENT  '核对电子合同',
  C_ECONTRACTTRADERULE  STRING  COMMENT  '电子合同控制交易规则',
  C_ECONTRACTTRADE  STRING  COMMENT  '电子合同控制交易',
  C_OTCCOMPARETTYPE  STRING  COMMENT  '',
  C_ISOTC  STRING  COMMENT  '是否OTC产品',
  C_OTCDETAIL  STRING  COMMENT  '',
  F_CSHARESSERVICERATIO  DECIMAL(7,6)  COMMENT  'C类销售服务费率(%)',
  C_BACKFARECALCUTYPE  STRING  COMMENT  '',
  C_SERVICEFARECALTYPE  STRING  COMMENT  '销售服务费计算方式',
  C_ISEXPFUNDDAY  STRING  COMMENT  '',
  C_REGISTINTOFUNDFARE  STRING  COMMENT  '注册机构费用处理方式',
  L_TAILDAYS  DECIMAL(4,0)  COMMENT  '',
  C_HIDEFUNDTOTAL  STRING  COMMENT  '行情文件屏蔽总份额',
  F_AGENCYMAXFARE  DECIMAL(16,2)  COMMENT  '',
  C_FEDJJDTALAUNCH  STRING  COMMENT  '份额冻结解冻由TA发起',
  C_VASTDEALTYPE  STRING  COMMENT  '',
  C_EXPAGENATURALDAY  STRING  COMMENT  '',
  F_SERVICEMANAGERATIO  DECIMAL(7,6)  COMMENT  '',
  C_CONFIRMCANUSE  STRING  COMMENT  'T日确认的份额T+1日可用',
  C_NETSETTLEMENT  STRING  COMMENT  '报表扎差交收',
  C_LARGEREDTAFLAG  STRING  COMMENT  '',
  L_SERVICEFAREDATE  DECIMAL(4,0)  COMMENT  '销售服务费计算年天数',
  C_ISEXPQ7FILE  STRING  COMMENT  '',
  C_SUBSPCSCHKMONEYTYPE  STRING  COMMENT  '',
  C_WSYJCALCBYVALUELEVEL  STRING  COMMENT  '',
  C_ECONTRACTTRADEACCO  STRING  COMMENT  '',
  C_EXPAGENATURALDAY05  STRING  COMMENT  '',
  C_CTLBYVALUELEVEL  STRING  COMMENT  '',
  F_TOTVALUELEVEL  DECIMAL(16,8)  COMMENT  '',
  C_KJAGENCYNO  STRING  COMMENT  '',
  C_INVESTREDEEM  STRING  COMMENT  '',
  C_RDMNOSHAREDEALTYPE  STRING  COMMENT  '',
  C_NEWINCOMEISCHANGE  STRING  COMMENT  '',
  C_EXPAGESUMINCOME  STRING  COMMENT  '',
  L_LIQUIDATECHANGEIN  DECIMAL(10,0)  COMMENT  '',
  L_LIQUIDATECHANGE  DECIMAL(10,0)  COMMENT  '',
  C_DETAIL  STRING  COMMENT  '',
  C_SHAREOUTINCOMEINVEST  STRING  COMMENT  '',
  C_07FILEEXPHISNETVALUE  STRING  COMMENT  '',
  C_CALINTEREST  STRING  COMMENT  '',
  C_ISEXPCOLLECT  STRING  COMMENT  '',
  D_LONGALLOTPAYBENDATE  STRING  COMMENT  '',
  D_LONGALLOTPAYENDDATE  STRING  COMMENT  '',
  L_LONGALLOTPAYCOUNT  DECIMAL(10,0)  COMMENT  '',
  C_REINVESTMODE  STRING  COMMENT  '',
  C_PCSFIXEDFEEAGIO  STRING  COMMENT  '',
  C_REDEEMCHANGEINCOME  STRING  COMMENT  '',
  C_EXPAGENATURALDAY06  STRING  COMMENT  '',
  C_EVERYDAYCHANGE  STRING  COMMENT  '',
  C_APPOINTREDEEM  STRING  COMMENT  '',
  C_05COMPARETYPE  STRING  COMMENT  '',
  L_MANDEALFAILDAYS  DECIMAL(18,2)  COMMENT  '',
  C_EXPAGENATURALDAY04  STRING  COMMENT  '',
  L_ADVANCENDAYSPUR  DECIMAL(10,0)  COMMENT  '',
  L_ADVANCENDAYSRDM  DECIMAL(10,0)  COMMENT  '',
  C_YEBALLRDMMODE  STRING  COMMENT  '',
  C_FIRSTINVESTINCLUDEFEE  STRING  COMMENT  '',
  C_STEPINVESTINCLUDEFEE  STRING  COMMENT  '',
  C_SHORTCYCLE26FILEEXPTYPE  STRING  COMMENT  '',
  C_EXPZHENDDATE  STRING  COMMENT  '',
  C_EXPORT26  STRING  COMMENT  '',
  C_ENDSHAREAUTOEXIT  STRING  COMMENT  '',
  C_ISBALRDM  STRING  COMMENT  '',
  C_FUNDMETHODTYPE  STRING  COMMENT  '',
  C_05RESTSHRSYN06REST  STRING  COMMENT  '',
  C_EXPSCF26DATERULE  STRING  COMMENT  '',
  C_UPGRADEFLAG  STRING  COMMENT  '',
  C_CROSS13CHKFAIL  STRING  COMMENT  '',
  C_CALLTAILFEETYPE  STRING  COMMENT  '',
  D_EXPC2DATE  STRING  COMMENT  '',
  F_PROFITAGENCYRATIO  DECIMAL(9,8)  COMMENT  '',
  C_26EXPFIRSTEND  STRING  COMMENT  '',
  C_SUBRATIOMODE  STRING  COMMENT  '',
  C_ISEDITMFDATA  STRING  COMMENT  '',
  C_NOLMTMAXALLOTBALA  STRING  COMMENT  '',
  F_WEIHUFARERATIO  DECIMAL(9,8)  COMMENT  '',
  D_EXPCFMPUBSIDEDATE  STRING  COMMENT  '',
  C_CALINTERESTBATCH  STRING  COMMENT  '',
  F_JIGOUFARERATIO  DECIMAL(9,8)  COMMENT  '',
  C_PURCHASEPREDEAL  STRING  COMMENT  '',
  C_FJYGHTALAUNCH  STRING  COMMENT  '',
  C_FILE04EXPNAVDATE  STRING  COMMENT  '',
  C_HOPEPURRDMDEALTYPE  STRING  COMMENT  '',
  C_EXPFUNDBFISSUEDATE  STRING  COMMENT  '',
  C_ISNOUPGRADE  STRING  COMMENT  '',
  C_EXP26BYAPRDAY  STRING  COMMENT  '',
  C_EXPT0NAV  STRING  COMMENT  ''
)
COMMENT '基金销售商参数表'
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
              "querySql": ["SELECT  C_FUNDCODE
                                   , C_AGENCYNO
                                   , C_SHARETYPES
                                   , C_SUBBALANCETYPE
                                   , C_TNTYPE
                                   , F_SERVICERATIO
                                   , L_BANKACCONO
                                   , F_FEWFORCEINVEST
                                   , L_FAREBANKACCONO
                                   , C_CONFIRMRIGHT
                                   , D_SERVFAREBGNDATE
                                   , D_SERVFAREENDDATE
                                   , C_PAYFREQ
                                   , D_CONTRACTDATE
                                   , C_ALLOTLIQTYPE
                                   , C_REDEEMLIQTYPE
                                   , C_BACKFAREMODE
                                   , L_ACCONUM
                                   , C_ALLOWEDBREACHRDM
                                   , C_RATIONAGIOMODE
                                   , D_EXPORTEDDATE
                                   , C_EXTRADEALTYPE
                                   , C_CMPECONTRACT
                                   , C_ECONTRACTTRADERULE
                                   , C_ECONTRACTTRADE
                                   , C_OTCCOMPARETTYPE
                                   , C_ISOTC
                                   , C_OTCDETAIL
                                   , F_CSHARESSERVICERATIO
                                   , C_BACKFARECALCUTYPE
                                   , C_SERVICEFARECALTYPE
                                   , C_ISEXPFUNDDAY
                                   , C_REGISTINTOFUNDFARE
                                   , L_TAILDAYS
                                   , C_HIDEFUNDTOTAL
                                   , F_AGENCYMAXFARE
                                   , C_FEDJJDTALAUNCH
                                   , C_VASTDEALTYPE
                                   , C_EXPAGENATURALDAY
                                   , F_SERVICEMANAGERATIO
                                   , C_CONFIRMCANUSE
                                   , C_NETSETTLEMENT
                                   , C_LARGEREDTAFLAG
                                   , L_SERVICEFAREDATE
                                   , C_ISEXPQ7FILE
                                   , C_SUBSPCSCHKMONEYTYPE
                                   , C_WSYJCALCBYVALUELEVEL
                                   , C_ECONTRACTTRADEACCO
                                   , C_EXPAGENATURALDAY05
                                   , C_CTLBYVALUELEVEL
                                   , F_TOTVALUELEVEL
                                   , C_KJAGENCYNO
                                   , C_INVESTREDEEM
                                   , C_RDMNOSHAREDEALTYPE
                                   , C_NEWINCOMEISCHANGE
                                   , C_EXPAGESUMINCOME
                                   , L_LIQUIDATECHANGEIN
                                   , L_LIQUIDATECHANGE
                                   , C_DETAIL
                                   , C_SHAREOUTINCOMEINVEST
                                   , C_07FILEEXPHISNETVALUE
                                   , C_CALINTEREST
                                   , C_ISEXPCOLLECT
                                   , D_LONGALLOTPAYBENDATE
                                   , D_LONGALLOTPAYENDDATE
                                   , L_LONGALLOTPAYCOUNT
                                   , C_REINVESTMODE
                                   , C_PCSFIXEDFEEAGIO
                                   , C_REDEEMCHANGEINCOME
                                   , C_EXPAGENATURALDAY06
                                   , C_EVERYDAYCHANGE
                                   , C_APPOINTREDEEM
                                   , C_05COMPARETYPE
                                   , L_MANDEALFAILDAYS
                                   , C_EXPAGENATURALDAY04
                                   , L_ADVANCENDAYSPUR
                                   , L_ADVANCENDAYSRDM
                                   , C_YEBALLRDMMODE
                                   , C_FIRSTINVESTINCLUDEFEE
                                   , C_STEPINVESTINCLUDEFEE
                                   , C_SHORTCYCLE26FILEEXPTYPE
                                   , C_EXPZHENDDATE
                                   , C_EXPORT26
                                   , C_ENDSHAREAUTOEXIT
                                   , C_ISBALRDM
                                   , C_FUNDMETHODTYPE
                                   , C_05RESTSHRSYN06REST
                                   , C_EXPSCF26DATERULE
                                   , C_UPGRADEFLAG
                                   , C_CROSS13CHKFAIL
                                   , C_CALLTAILFEETYPE
                                   , D_EXPC2DATE
                                   , F_PROFITAGENCYRATIO
                                   , C_26EXPFIRSTEND
                                   , C_SUBRATIOMODE
                                   , C_ISEDITMFDATA
                                   , C_NOLMTMAXALLOTBALA
                                   , F_WEIHUFARERATIO
                                   , D_EXPCFMPUBSIDEDATE
                                   , C_CALINTERESTBATCH
                                   , F_JIGOUFARERATIO
                                   , C_PURCHASEPREDEAL
                                   , C_FJYGHTALAUNCH
                                   , C_FILE04EXPNAVDATE
                                   , C_HOPEPURRDMDEALTYPE
                                   , C_EXPFUNDBFISSUEDATE
                                   , C_ISNOUPGRADE
                                   , C_EXP26BYAPRDAY
                                   , C_EXPT0NAV
                                FROM ${hszta_src_schema}.TFUNDAGENCY"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_SHARETYPES", "type": "STRING"}, {"name": "C_SUBBALANCETYPE", "type": "STRING"}, {"name": "C_TNTYPE", "type": "STRING"}, {"name": "F_SERVICERATIO", "type": "DOUBLE"}, {"name": "L_BANKACCONO", "type": "DOUBLE"}, {"name": "F_FEWFORCEINVEST", "type": "DOUBLE"}, {"name": "L_FAREBANKACCONO", "type": "DOUBLE"}, {"name": "C_CONFIRMRIGHT", "type": "STRING"}, {"name": "D_SERVFAREBGNDATE", "type": "STRING"}, {"name": "D_SERVFAREENDDATE", "type": "STRING"}, {"name": "C_PAYFREQ", "type": "STRING"}, {"name": "D_CONTRACTDATE", "type": "STRING"}, {"name": "C_ALLOTLIQTYPE", "type": "STRING"}, {"name": "C_REDEEMLIQTYPE", "type": "STRING"}, {"name": "C_BACKFAREMODE", "type": "STRING"}, {"name": "L_ACCONUM", "type": "DOUBLE"}, {"name": "C_ALLOWEDBREACHRDM", "type": "STRING"}, {"name": "C_RATIONAGIOMODE", "type": "STRING"}, {"name": "D_EXPORTEDDATE", "type": "STRING"}, {"name": "C_EXTRADEALTYPE", "type": "STRING"}, {"name": "C_CMPECONTRACT", "type": "STRING"}, {"name": "C_ECONTRACTTRADERULE", "type": "STRING"}, {"name": "C_ECONTRACTTRADE", "type": "STRING"}, {"name": "C_OTCCOMPARETTYPE", "type": "STRING"}, {"name": "C_ISOTC", "type": "STRING"}, {"name": "C_OTCDETAIL", "type": "STRING"}, {"name": "F_CSHARESSERVICERATIO", "type": "DOUBLE"}, {"name": "C_BACKFARECALCUTYPE", "type": "STRING"}, {"name": "C_SERVICEFARECALTYPE", "type": "STRING"}, {"name": "C_ISEXPFUNDDAY", "type": "STRING"}, {"name": "C_REGISTINTOFUNDFARE", "type": "STRING"}, {"name": "L_TAILDAYS", "type": "DOUBLE"}, {"name": "C_HIDEFUNDTOTAL", "type": "STRING"}, {"name": "F_AGENCYMAXFARE", "type": "DOUBLE"}, {"name": "C_FEDJJDTALAUNCH", "type": "STRING"}, {"name": "C_VASTDEALTYPE", "type": "STRING"}, {"name": "C_EXPAGENATURALDAY", "type": "STRING"}, {"name": "F_SERVICEMANAGERATIO", "type": "DOUBLE"}, {"name": "C_CONFIRMCANUSE", "type": "STRING"}, {"name": "C_NETSETTLEMENT", "type": "STRING"}, {"name": "C_LARGEREDTAFLAG", "type": "STRING"}, {"name": "L_SERVICEFAREDATE", "type": "DOUBLE"}, {"name": "C_ISEXPQ7FILE", "type": "STRING"}, {"name": "C_SUBSPCSCHKMONEYTYPE", "type": "STRING"}, {"name": "C_WSYJCALCBYVALUELEVEL", "type": "STRING"}, {"name": "C_ECONTRACTTRADEACCO", "type": "STRING"}, {"name": "C_EXPAGENATURALDAY05", "type": "STRING"}, {"name": "C_CTLBYVALUELEVEL", "type": "STRING"}, {"name": "F_TOTVALUELEVEL", "type": "DOUBLE"}, {"name": "C_KJAGENCYNO", "type": "STRING"}, {"name": "C_INVESTREDEEM", "type": "STRING"}, {"name": "C_RDMNOSHAREDEALTYPE", "type": "STRING"}, {"name": "C_NEWINCOMEISCHANGE", "type": "STRING"}, {"name": "C_EXPAGESUMINCOME", "type": "STRING"}, {"name": "L_LIQUIDATECHANGEIN", "type": "DOUBLE"}, {"name": "L_LIQUIDATECHANGE", "type": "DOUBLE"}, {"name": "C_DETAIL", "type": "STRING"}, {"name": "C_SHAREOUTINCOMEINVEST", "type": "STRING"}, {"name": "C_07FILEEXPHISNETVALUE", "type": "STRING"}, {"name": "C_CALINTEREST", "type": "STRING"}, {"name": "C_ISEXPCOLLECT", "type": "STRING"}, {"name": "D_LONGALLOTPAYBENDATE", "type": "STRING"}, {"name": "D_LONGALLOTPAYENDDATE", "type": "STRING"}, {"name": "L_LONGALLOTPAYCOUNT", "type": "DOUBLE"}, {"name": "C_REINVESTMODE", "type": "STRING"}, {"name": "C_PCSFIXEDFEEAGIO", "type": "STRING"}, {"name": "C_REDEEMCHANGEINCOME", "type": "STRING"}, {"name": "C_EXPAGENATURALDAY06", "type": "STRING"}, {"name": "C_EVERYDAYCHANGE", "type": "STRING"}, {"name": "C_APPOINTREDEEM", "type": "STRING"}, {"name": "C_05COMPARETYPE", "type": "STRING"}, {"name": "L_MANDEALFAILDAYS", "type": "DOUBLE"}, {"name": "C_EXPAGENATURALDAY04", "type": "STRING"}, {"name": "L_ADVANCENDAYSPUR", "type": "DOUBLE"}, {"name": "L_ADVANCENDAYSRDM", "type": "DOUBLE"}, {"name": "C_YEBALLRDMMODE", "type": "STRING"}, {"name": "C_FIRSTINVESTINCLUDEFEE", "type": "STRING"}, {"name": "C_STEPINVESTINCLUDEFEE", "type": "STRING"}, {"name": "C_SHORTCYCLE26FILEEXPTYPE", "type": "STRING"}, {"name": "C_EXPZHENDDATE", "type": "STRING"}, {"name": "C_EXPORT26", "type": "STRING"}, {"name": "C_ENDSHAREAUTOEXIT", "type": "STRING"}, {"name": "C_ISBALRDM", "type": "STRING"}, {"name": "C_FUNDMETHODTYPE", "type": "STRING"}, {"name": "C_05RESTSHRSYN06REST", "type": "STRING"}, {"name": "C_EXPSCF26DATERULE", "type": "STRING"}, {"name": "C_UPGRADEFLAG", "type": "STRING"}, {"name": "C_CROSS13CHKFAIL", "type": "STRING"}, {"name": "C_CALLTAILFEETYPE", "type": "STRING"}, {"name": "D_EXPC2DATE", "type": "STRING"}, {"name": "F_PROFITAGENCYRATIO", "type": "DOUBLE"}, {"name": "C_26EXPFIRSTEND", "type": "STRING"}, {"name": "C_SUBRATIOMODE", "type": "STRING"}, {"name": "C_ISEDITMFDATA", "type": "STRING"}, {"name": "C_NOLMTMAXALLOTBALA", "type": "STRING"}, {"name": "F_WEIHUFARERATIO", "type": "DOUBLE"}, {"name": "D_EXPCFMPUBSIDEDATE", "type": "STRING"}, {"name": "C_CALINTERESTBATCH", "type": "STRING"}, {"name": "F_JIGOUFARERATIO", "type": "DOUBLE"}, {"name": "C_PURCHASEPREDEAL", "type": "STRING"}, {"name": "C_FJYGHTALAUNCH", "type": "STRING"}, {"name": "C_FILE04EXPNAVDATE", "type": "STRING"}, {"name": "C_HOPEPURRDMDEALTYPE", "type": "STRING"}, {"name": "C_EXPFUNDBFISSUEDATE", "type": "STRING"}, {"name": "C_ISNOUPGRADE", "type": "STRING"}, {"name": "C_EXP26BYAPRDAY", "type": "STRING"}, {"name": "C_EXPT0NAV", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tfundagency_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tfundagency_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tfundagency_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tfundagency_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TFUNDAGENCY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TFUNDAGENCY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tfundagency_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_AGENCYNO
     , C_SHARETYPES
     , C_SUBBALANCETYPE
     , C_TNTYPE
     , F_SERVICERATIO
     , L_BANKACCONO
     , F_FEWFORCEINVEST
     , L_FAREBANKACCONO
     , C_CONFIRMRIGHT
     , D_SERVFAREBGNDATE
     , D_SERVFAREENDDATE
     , C_PAYFREQ
     , D_CONTRACTDATE
     , C_ALLOTLIQTYPE
     , C_REDEEMLIQTYPE
     , C_BACKFAREMODE
     , L_ACCONUM
     , C_ALLOWEDBREACHRDM
     , C_RATIONAGIOMODE
     , D_EXPORTEDDATE
     , C_EXTRADEALTYPE
     , C_CMPECONTRACT
     , C_ECONTRACTTRADERULE
     , C_ECONTRACTTRADE
     , C_OTCCOMPARETTYPE
     , C_ISOTC
     , C_OTCDETAIL
     , F_CSHARESSERVICERATIO
     , C_BACKFARECALCUTYPE
     , C_SERVICEFARECALTYPE
     , C_ISEXPFUNDDAY
     , C_REGISTINTOFUNDFARE
     , L_TAILDAYS
     , C_HIDEFUNDTOTAL
     , F_AGENCYMAXFARE
     , C_FEDJJDTALAUNCH
     , C_VASTDEALTYPE
     , C_EXPAGENATURALDAY
     , F_SERVICEMANAGERATIO
     , C_CONFIRMCANUSE
     , C_NETSETTLEMENT
     , C_LARGEREDTAFLAG
     , L_SERVICEFAREDATE
     , C_ISEXPQ7FILE
     , C_SUBSPCSCHKMONEYTYPE
     , C_WSYJCALCBYVALUELEVEL
     , C_ECONTRACTTRADEACCO
     , C_EXPAGENATURALDAY05
     , C_CTLBYVALUELEVEL
     , F_TOTVALUELEVEL
     , C_KJAGENCYNO
     , C_INVESTREDEEM
     , C_RDMNOSHAREDEALTYPE
     , C_NEWINCOMEISCHANGE
     , C_EXPAGESUMINCOME
     , L_LIQUIDATECHANGEIN
     , L_LIQUIDATECHANGE
     , C_DETAIL
     , C_SHAREOUTINCOMEINVEST
     , C_07FILEEXPHISNETVALUE
     , C_CALINTEREST
     , C_ISEXPCOLLECT
     , D_LONGALLOTPAYBENDATE
     , D_LONGALLOTPAYENDDATE
     , L_LONGALLOTPAYCOUNT
     , C_REINVESTMODE
     , C_PCSFIXEDFEEAGIO
     , C_REDEEMCHANGEINCOME
     , C_EXPAGENATURALDAY06
     , C_EVERYDAYCHANGE
     , C_APPOINTREDEEM
     , C_05COMPARETYPE
     , L_MANDEALFAILDAYS
     , C_EXPAGENATURALDAY04
     , L_ADVANCENDAYSPUR
     , L_ADVANCENDAYSRDM
     , C_YEBALLRDMMODE
     , C_FIRSTINVESTINCLUDEFEE
     , C_STEPINVESTINCLUDEFEE
     , C_SHORTCYCLE26FILEEXPTYPE
     , C_EXPZHENDDATE
     , C_EXPORT26
     , C_ENDSHAREAUTOEXIT
     , C_ISBALRDM
     , C_FUNDMETHODTYPE
     , C_05RESTSHRSYN06REST
     , C_EXPSCF26DATERULE
     , C_UPGRADEFLAG
     , C_CROSS13CHKFAIL
     , C_CALLTAILFEETYPE
     , D_EXPC2DATE
     , F_PROFITAGENCYRATIO
     , C_26EXPFIRSTEND
     , C_SUBRATIOMODE
     , C_ISEDITMFDATA
     , C_NOLMTMAXALLOTBALA
     , F_WEIHUFARERATIO
     , D_EXPCFMPUBSIDEDATE
     , C_CALINTERESTBATCH
     , F_JIGOUFARERATIO
     , C_PURCHASEPREDEAL
     , C_FJYGHTALAUNCH
     , C_FILE04EXPNAVDATE
     , C_HOPEPURRDMDEALTYPE
     , C_EXPFUNDBFISSUEDATE
     , C_ISNOUPGRADE
     , C_EXP26BYAPRDAY
     , C_EXPT0NAV
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDAGENCY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TFUNDAGENCY_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TFUNDAGENCY_PFD成功"
      exit 0
   fi
fi
