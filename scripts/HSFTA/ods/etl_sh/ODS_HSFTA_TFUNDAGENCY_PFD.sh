#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  L_LIQUIDATEALLOT  DECIMAL(10,0)  COMMENT  '申购清算天数',
  L_LIQUIDATEREDEEM  DECIMAL(10,0)  COMMENT  '赎回清算天数',
  L_LIQUIDATEBONUS  DECIMAL(10,0)  COMMENT  '分红清算天数',
  L_LIQUIDATESUB  DECIMAL(10,0)  COMMENT  '认购清算天数',
  C_SUBBALANCETYPE  STRING  COMMENT  '认购款到账方式',
  C_WORKTYPE  STRING  COMMENT  '工作日方式',
  C_TNTYPE  STRING  COMMENT  'T＋n方式',
  L_LIQUIDATECHANGE  DECIMAL(10,0)  COMMENT  '基金转换清算天数',
  F_SERVICERATIO  DECIMAL(7,6)  COMMENT  '销售服务费率',
  L_LIQUIDATEFARE  DECIMAL(10,0)  COMMENT  '费用结算日期',
  C_CALCULATETYPE  STRING  COMMENT  '计算方式',
  L_BANKACCONO  STRING  COMMENT  '清算银行编号',
  F_FEWFORCEINVEST  DECIMAL(16,2)  COMMENT  '最小现金红利',
  L_FAREBANKACCONO  STRING  COMMENT  '费用清算银行编号',
  C_FUNDWORKTYPE  STRING  COMMENT  '资金的工作日方式',
  C_RATIONOPEN  STRING  COMMENT  '',
  D_INTERESTENDDATE  STRING  COMMENT  '',
  C_CONFIRMRIGHT  STRING  COMMENT  '确权申请开通标志',
  D_FEEVALIDBGNDATE  STRING  COMMENT  '',
  C_PAYFREQ  STRING  COMMENT  '服务费支付频率',
  D_FEEENDDATE  STRING  COMMENT  '',
  D_SERVFAREBGNDATE  STRING  COMMENT  '销售服务费起始日期',
  D_SERVFAREENDDATE  STRING  COMMENT  '销售服务费截止日期',
  D_CONTRACTDATE  STRING  COMMENT  '签约起始日期',
  C_CMPECONTRACT  STRING  COMMENT  '核对电子合同',
  L_LIQUIDATEALLOT_AGN  DECIMAL(10,0)  COMMENT  '',
  C_ECONTRACTTRADE  STRING  COMMENT  '电子合同控制交易',
  C_ECONTRACTTRADERULE  STRING  COMMENT  '电子合同控制交易规则',
  L_TAILDAYS  DECIMAL(4,0)  COMMENT  '尾随佣金计算年天数',
  C_FARELIQFREQUENCY  STRING  COMMENT  '',
  F_MINTAILFARE  DECIMAL(16,2)  COMMENT  '尾随佣金起付金额',
  C_BACKFAREMODE  STRING  COMMENT  '后收费分成模式',
  C_BACKFARECALCUTYPE  STRING  COMMENT  '',
  C_TAILSEGMENT  STRING  COMMENT  '是否累进计算',
  C_ISNOFUNDFARE  STRING  COMMENT  '',
  F_CREDITBALA  DECIMAL(16,2)  COMMENT  '',
  C_EARLYEXITREQ  STRING  COMMENT  '',
  D_EXPORTEDDATE  STRING  COMMENT  '',
  C_SUBFLAG  STRING  COMMENT  '',
  C_STOCKCALCULATETYPE  STRING  COMMENT  '',
  F_CSHARESSERVICERATIO  DECIMAL(7,6)  COMMENT  'C类销售服务费率(%)',
  F_INVESTRATIO  DECIMAL(7,6)  COMMENT  '',
  D_LONGALLOTPAYBENDATE  STRING  COMMENT  '',
  D_LONGALLOTPAYENDDATE  STRING  COMMENT  '',
  L_LONGALLOTPAYCOUNT  DECIMAL(10,0)  COMMENT  '',
  C_REGISTINTOFUNDFARE  STRING  COMMENT  '注册机构费用处理方式',
  C_SUBREQCONFIRMTYPE  STRING  COMMENT  '',
  C_CONFIRMCANUSE  STRING  COMMENT  'T日确认的份额T+1日可用',
  L_SERVICEDAYS  DECIMAL(4,0)  COMMENT  '',
  C_EXPAGENATURALDAY  STRING  COMMENT  '',
  C_ISEXPFUNDDAY  STRING  COMMENT  '',
  C_AMOUNTCONTROLDISNET  STRING  COMMENT  '',
  F_SUPERVISIONSERVICERATIO  DECIMAL(7,6)  COMMENT  '',
  C_EXPACCOUNTDATA  STRING  COMMENT  '',
  C_CONFIRMSHARETYPE  STRING  COMMENT  '',
  C_OUTPROPERTY  STRING  COMMENT  '对外公告基金类型',
  C_HIDEFUNDTOTAL  STRING  COMMENT  '行情文件屏蔽总份额',
  C_07FILEEXPHISNETVALUE  STRING  COMMENT  '',
  C_FUNDCHGTSHARECANUSE  STRING  COMMENT  '',
  F_AGCDEDUCTRATIO  DECIMAL(9,8)  COMMENT  '',
  C_KJAGENCYNO  STRING  COMMENT  '',
  C_SUBDIFFERNEWOLDCUST  STRING  COMMENT  '',
  C_WSYJCALCBYVALUELEVEL  STRING  COMMENT  '',
  F_TAILRATIO  DECIMAL(7,6)  COMMENT  '',
  C_SPECIALDAYSETBYFUNDAGENCY  STRING  COMMENT  '',
  C_07FILESYFROMRESTDAY  STRING  COMMENT  '',
  C_FINALFEERATIOLIMIT  STRING  COMMENT  '',
  C_EXPBJHQ  STRING  COMMENT  '',
  C_NOTLARGETRADELIMIT  STRING  COMMENT  '',
  C_HOLDMODE  STRING  COMMENT  '',
  D_VALUEADDEDFAREBGN  STRING  COMMENT  '',
  D_VALUEADDEDFAREEND  STRING  COMMENT  '',
  F_MINVALUEADDEDFARE  DECIMAL(16,2)  COMMENT  '',
  L_VALUEADDEDFAREDAYS  DECIMAL(4,0)  COMMENT  '',
  C_VALUEADDEDFARESEGMENT  STRING  COMMENT  '',
  C_ISREALSALER  STRING  COMMENT  '',
  C_FILTERSERVFARE  STRING  COMMENT  '',
  F_ANTBELONGRATIO  DECIMAL(9,8)  COMMENT  '',
  C_ISSIGNED  STRING  COMMENT  '',
  F_PERSONANTBELONGRATIO  DECIMAL(9,8)  COMMENT  '',
  F_INSTITUTIONANTBELONGRATIO  DECIMAL(9,8)  COMMENT  ''
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , C_AGENCYNO
                                   , L_LIQUIDATEALLOT
                                   , L_LIQUIDATEREDEEM
                                   , L_LIQUIDATEBONUS
                                   , L_LIQUIDATESUB
                                   , C_SUBBALANCETYPE
                                   , C_WORKTYPE
                                   , C_TNTYPE
                                   , L_LIQUIDATECHANGE
                                   , F_SERVICERATIO
                                   , L_LIQUIDATEFARE
                                   , C_CALCULATETYPE
                                   , L_BANKACCONO
                                   , F_FEWFORCEINVEST
                                   , L_FAREBANKACCONO
                                   , C_FUNDWORKTYPE
                                   , C_RATIONOPEN
                                   , D_INTERESTENDDATE
                                   , C_CONFIRMRIGHT
                                   , D_FEEVALIDBGNDATE
                                   , C_PAYFREQ
                                   , D_FEEENDDATE
                                   , D_SERVFAREBGNDATE
                                   , D_SERVFAREENDDATE
                                   , D_CONTRACTDATE
                                   , C_CMPECONTRACT
                                   , L_LIQUIDATEALLOT_AGN
                                   , C_ECONTRACTTRADE
                                   , C_ECONTRACTTRADERULE
                                   , L_TAILDAYS
                                   , C_FARELIQFREQUENCY
                                   , F_MINTAILFARE
                                   , C_BACKFAREMODE
                                   , C_BACKFARECALCUTYPE
                                   , C_TAILSEGMENT
                                   , C_ISNOFUNDFARE
                                   , F_CREDITBALA
                                   , C_EARLYEXITREQ
                                   , D_EXPORTEDDATE
                                   , C_SUBFLAG
                                   , C_STOCKCALCULATETYPE
                                   , F_CSHARESSERVICERATIO
                                   , F_INVESTRATIO
                                   , D_LONGALLOTPAYBENDATE
                                   , D_LONGALLOTPAYENDDATE
                                   , L_LONGALLOTPAYCOUNT
                                   , C_REGISTINTOFUNDFARE
                                   , C_SUBREQCONFIRMTYPE
                                   , C_CONFIRMCANUSE
                                   , L_SERVICEDAYS
                                   , C_EXPAGENATURALDAY
                                   , C_ISEXPFUNDDAY
                                   , C_AMOUNTCONTROLDISNET
                                   , F_SUPERVISIONSERVICERATIO
                                   , C_EXPACCOUNTDATA
                                   , C_CONFIRMSHARETYPE
                                   , C_OUTPROPERTY
                                   , C_HIDEFUNDTOTAL
                                   , C_07FILEEXPHISNETVALUE
                                   , C_FUNDCHGTSHARECANUSE
                                   , F_AGCDEDUCTRATIO
                                   , C_KJAGENCYNO
                                   , C_SUBDIFFERNEWOLDCUST
                                   , C_WSYJCALCBYVALUELEVEL
                                   , F_TAILRATIO
                                   , C_SPECIALDAYSETBYFUNDAGENCY
                                   , C_07FILESYFROMRESTDAY
                                   , C_FINALFEERATIOLIMIT
                                   , C_EXPBJHQ
                                   , C_NOTLARGETRADELIMIT
                                   , C_HOLDMODE
                                   , D_VALUEADDEDFAREBGN
                                   , D_VALUEADDEDFAREEND
                                   , F_MINVALUEADDEDFARE
                                   , L_VALUEADDEDFAREDAYS
                                   , C_VALUEADDEDFARESEGMENT
                                   , C_ISREALSALER
                                   , C_FILTERSERVFARE
                                   , F_ANTBELONGRATIO
                                   , C_ISSIGNED
                                   , F_PERSONANTBELONGRATIO
                                   , F_INSTITUTIONANTBELONGRATIO
                                FROM ${hsfta_src_schema}.TFUNDAGENCY"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "L_LIQUIDATEALLOT", "type": "DOUBLE"}, {"name": "L_LIQUIDATEREDEEM", "type": "DOUBLE"}, {"name": "L_LIQUIDATEBONUS", "type": "DOUBLE"}, {"name": "L_LIQUIDATESUB", "type": "DOUBLE"}, {"name": "C_SUBBALANCETYPE", "type": "STRING"}, {"name": "C_WORKTYPE", "type": "STRING"}, {"name": "C_TNTYPE", "type": "STRING"}, {"name": "L_LIQUIDATECHANGE", "type": "DOUBLE"}, {"name": "F_SERVICERATIO", "type": "DOUBLE"}, {"name": "L_LIQUIDATEFARE", "type": "DOUBLE"}, {"name": "C_CALCULATETYPE", "type": "STRING"}, {"name": "L_BANKACCONO", "type": "DOUBLE"}, {"name": "F_FEWFORCEINVEST", "type": "DOUBLE"}, {"name": "L_FAREBANKACCONO", "type": "DOUBLE"}, {"name": "C_FUNDWORKTYPE", "type": "STRING"}, {"name": "C_RATIONOPEN", "type": "STRING"}, {"name": "D_INTERESTENDDATE", "type": "STRING"}, {"name": "C_CONFIRMRIGHT", "type": "STRING"}, {"name": "D_FEEVALIDBGNDATE", "type": "STRING"}, {"name": "C_PAYFREQ", "type": "STRING"}, {"name": "D_FEEENDDATE", "type": "STRING"}, {"name": "D_SERVFAREBGNDATE", "type": "STRING"}, {"name": "D_SERVFAREENDDATE", "type": "STRING"}, {"name": "D_CONTRACTDATE", "type": "STRING"}, {"name": "C_CMPECONTRACT", "type": "STRING"}, {"name": "L_LIQUIDATEALLOT_AGN", "type": "DOUBLE"}, {"name": "C_ECONTRACTTRADE", "type": "STRING"}, {"name": "C_ECONTRACTTRADERULE", "type": "STRING"}, {"name": "L_TAILDAYS", "type": "DOUBLE"}, {"name": "C_FARELIQFREQUENCY", "type": "STRING"}, {"name": "F_MINTAILFARE", "type": "DOUBLE"}, {"name": "C_BACKFAREMODE", "type": "STRING"}, {"name": "C_BACKFARECALCUTYPE", "type": "STRING"}, {"name": "C_TAILSEGMENT", "type": "STRING"}, {"name": "C_ISNOFUNDFARE", "type": "STRING"}, {"name": "F_CREDITBALA", "type": "DOUBLE"}, {"name": "C_EARLYEXITREQ", "type": "STRING"}, {"name": "D_EXPORTEDDATE", "type": "STRING"}, {"name": "C_SUBFLAG", "type": "STRING"}, {"name": "C_STOCKCALCULATETYPE", "type": "STRING"}, {"name": "F_CSHARESSERVICERATIO", "type": "DOUBLE"}, {"name": "F_INVESTRATIO", "type": "DOUBLE"}, {"name": "D_LONGALLOTPAYBENDATE", "type": "STRING"}, {"name": "D_LONGALLOTPAYENDDATE", "type": "STRING"}, {"name": "L_LONGALLOTPAYCOUNT", "type": "DOUBLE"}, {"name": "C_REGISTINTOFUNDFARE", "type": "STRING"}, {"name": "C_SUBREQCONFIRMTYPE", "type": "STRING"}, {"name": "C_CONFIRMCANUSE", "type": "STRING"}, {"name": "L_SERVICEDAYS", "type": "DOUBLE"}, {"name": "C_EXPAGENATURALDAY", "type": "STRING"}, {"name": "C_ISEXPFUNDDAY", "type": "STRING"}, {"name": "C_AMOUNTCONTROLDISNET", "type": "STRING"}, {"name": "F_SUPERVISIONSERVICERATIO", "type": "DOUBLE"}, {"name": "C_EXPACCOUNTDATA", "type": "STRING"}, {"name": "C_CONFIRMSHARETYPE", "type": "STRING"}, {"name": "C_OUTPROPERTY", "type": "STRING"}, {"name": "C_HIDEFUNDTOTAL", "type": "STRING"}, {"name": "C_07FILEEXPHISNETVALUE", "type": "STRING"}, {"name": "C_FUNDCHGTSHARECANUSE", "type": "STRING"}, {"name": "F_AGCDEDUCTRATIO", "type": "DOUBLE"}, {"name": "C_KJAGENCYNO", "type": "STRING"}, {"name": "C_SUBDIFFERNEWOLDCUST", "type": "STRING"}, {"name": "C_WSYJCALCBYVALUELEVEL", "type": "STRING"}, {"name": "F_TAILRATIO", "type": "DOUBLE"}, {"name": "C_SPECIALDAYSETBYFUNDAGENCY", "type": "STRING"}, {"name": "C_07FILESYFROMRESTDAY", "type": "STRING"}, {"name": "C_FINALFEERATIOLIMIT", "type": "STRING"}, {"name": "C_EXPBJHQ", "type": "STRING"}, {"name": "C_NOTLARGETRADELIMIT", "type": "STRING"}, {"name": "C_HOLDMODE", "type": "STRING"}, {"name": "D_VALUEADDEDFAREBGN", "type": "STRING"}, {"name": "D_VALUEADDEDFAREEND", "type": "STRING"}, {"name": "F_MINVALUEADDEDFARE", "type": "DOUBLE"}, {"name": "L_VALUEADDEDFAREDAYS", "type": "DOUBLE"}, {"name": "C_VALUEADDEDFARESEGMENT", "type": "STRING"}, {"name": "C_ISREALSALER", "type": "STRING"}, {"name": "C_FILTERSERVFARE", "type": "STRING"}, {"name": "F_ANTBELONGRATIO", "type": "DOUBLE"}, {"name": "C_ISSIGNED", "type": "STRING"}, {"name": "F_PERSONANTBELONGRATIO", "type": "DOUBLE"}, {"name": "F_INSTITUTIONANTBELONGRATIO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tfundagency_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tfundagency_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tfundagency_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tfundagency_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TFUNDAGENCY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TFUNDAGENCY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tfundagency_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_AGENCYNO
     , L_LIQUIDATEALLOT
     , L_LIQUIDATEREDEEM
     , L_LIQUIDATEBONUS
     , L_LIQUIDATESUB
     , C_SUBBALANCETYPE
     , C_WORKTYPE
     , C_TNTYPE
     , L_LIQUIDATECHANGE
     , F_SERVICERATIO
     , L_LIQUIDATEFARE
     , C_CALCULATETYPE
     , L_BANKACCONO
     , F_FEWFORCEINVEST
     , L_FAREBANKACCONO
     , C_FUNDWORKTYPE
     , C_RATIONOPEN
     , D_INTERESTENDDATE
     , C_CONFIRMRIGHT
     , D_FEEVALIDBGNDATE
     , C_PAYFREQ
     , D_FEEENDDATE
     , D_SERVFAREBGNDATE
     , D_SERVFAREENDDATE
     , D_CONTRACTDATE
     , C_CMPECONTRACT
     , L_LIQUIDATEALLOT_AGN
     , C_ECONTRACTTRADE
     , C_ECONTRACTTRADERULE
     , L_TAILDAYS
     , C_FARELIQFREQUENCY
     , F_MINTAILFARE
     , C_BACKFAREMODE
     , C_BACKFARECALCUTYPE
     , C_TAILSEGMENT
     , C_ISNOFUNDFARE
     , F_CREDITBALA
     , C_EARLYEXITREQ
     , D_EXPORTEDDATE
     , C_SUBFLAG
     , C_STOCKCALCULATETYPE
     , F_CSHARESSERVICERATIO
     , F_INVESTRATIO
     , D_LONGALLOTPAYBENDATE
     , D_LONGALLOTPAYENDDATE
     , L_LONGALLOTPAYCOUNT
     , C_REGISTINTOFUNDFARE
     , C_SUBREQCONFIRMTYPE
     , C_CONFIRMCANUSE
     , L_SERVICEDAYS
     , C_EXPAGENATURALDAY
     , C_ISEXPFUNDDAY
     , C_AMOUNTCONTROLDISNET
     , F_SUPERVISIONSERVICERATIO
     , C_EXPACCOUNTDATA
     , C_CONFIRMSHARETYPE
     , C_OUTPROPERTY
     , C_HIDEFUNDTOTAL
     , C_07FILEEXPHISNETVALUE
     , C_FUNDCHGTSHARECANUSE
     , F_AGCDEDUCTRATIO
     , C_KJAGENCYNO
     , C_SUBDIFFERNEWOLDCUST
     , C_WSYJCALCBYVALUELEVEL
     , F_TAILRATIO
     , C_SPECIALDAYSETBYFUNDAGENCY
     , C_07FILESYFROMRESTDAY
     , C_FINALFEERATIOLIMIT
     , C_EXPBJHQ
     , C_NOTLARGETRADELIMIT
     , C_HOLDMODE
     , D_VALUEADDEDFAREBGN
     , D_VALUEADDEDFAREEND
     , F_MINVALUEADDEDFARE
     , L_VALUEADDEDFAREDAYS
     , C_VALUEADDEDFARESEGMENT
     , C_ISREALSALER
     , C_FILTERSERVFARE
     , F_ANTBELONGRATIO
     , C_ISSIGNED
     , F_PERSONANTBELONGRATIO
     , F_INSTITUTIONANTBELONGRATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDAGENCY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TFUNDAGENCY_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TFUNDAGENCY_PFD成功"
      exit 0
   fi
fi
