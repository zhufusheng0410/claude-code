#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TCONFIRM_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCONFIRM_PTD_TMP(
  C_BUSINFLAG  STRING  COMMENT  '业务代码',
  D_CDATE  STRING  COMMENT  '确认日期',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  D_DATE  STRING  COMMENT  '申请日期',
  L_SERIALNO  DECIMAL(10,0)  COMMENT  '申请序号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  F_CONFIRMBALANCE  DECIMAL(16,2)  COMMENT  '确认金额',
  F_CONFIRMSHARES  DECIMAL(16,2)  COMMENT  '确认份额',
  F_TRADEFARE  DECIMAL(16,2)  COMMENT  '交易费',
  F_TAFARE  DECIMAL(16,2)  COMMENT  '过户费',
  F_STAMPTAX  DECIMAL(16,2)  COMMENT  '印花税',
  F_BACKFARE  DECIMAL(16,2)  COMMENT  '后收手续费',
  F_OTHERFARE1  DECIMAL(16,2)  COMMENT  '其他费用1',
  F_INTEREST  DECIMAL(16,2)  COMMENT  '利息',
  F_INTERESTTAX  DECIMAL(16,2)  COMMENT  '利息税',
  F_TOTALFARE  DECIMAL(16,2)  COMMENT  '总费用',
  F_AGENCYFARE  DECIMAL(16,2)  COMMENT  '销售商费',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '基金净值（成交价）',
  F_FROZENBALANCE  DECIMAL(16,2)  COMMENT  '确认冻结资金',
  F_UNFROZENBALANCE  DECIMAL(16,2)  COMMENT  '确认解冻金额',
  C_STATUS  STRING  COMMENT  '处理标志',
  C_CAUSE  STRING  COMMENT  '失败原因',
  C_TAFLAG  STRING  COMMENT  'TA发起标志',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_CUSTNO  STRING  COMMENT  '客户编号',
  F_GAINBALANCE  DECIMAL(16,2)  COMMENT  '投资收益',
  F_ORIFARE  DECIMAL(16,2)  COMMENT  '原费用(指交易费)',
  C_REQUESTENDFLAG  STRING  COMMENT  '申请结束标志',
  F_UNBALANCE  DECIMAL(16,2)  COMMENT  '未确认金额',
  F_UNSHARES  DECIMAL(16,2)  COMMENT  '未确认份额',
  C_RESERVE  STRING  COMMENT  '保留字段',
  F_INTERESTSHARE  DECIMAL(16,2)  COMMENT  '利息转份额',
  F_CHINCOME  DECIMAL(16,2)  COMMENT  '兑现的未付收益',
  F_CHSHARE  DECIMAL(16,2)  COMMENT  '兑现的份额',
  F_CONFIRMINCOME  DECIMAL(16,2)  COMMENT  '确认的未付收益',
  F_ORITRADEFARE  DECIMAL(16,2)  COMMENT  '打折前交易费',
  F_ORITAFARE  DECIMAL(16,2)  COMMENT  '打折前过户费',
  F_ORIBACKFARE  DECIMAL(16,2)  COMMENT  '打折前后收费',
  F_ORIOTHERFARE1  DECIMAL(16,2)  COMMENT  '打折前其它费',
  C_REQUESTNO  STRING  COMMENT  '申请编号',
  F_BALANCE  DECIMAL(16,2)  COMMENT  '申请金额',
  F_SHARES  DECIMAL(16,2)  COMMENT  '申请份额',
  F_AGIO  DECIMAL(5,4)  COMMENT  '折扣',
  F_LASTSHARES  DECIMAL(16,2)  COMMENT  '本笔交易后余额',
  F_LASTFREEZESHARE  DECIMAL(16,2)  COMMENT  '本笔交易后冻结',
  C_OTHERCODE  STRING  COMMENT  '对方基金代码',
  C_OTHERACCO  STRING  COMMENT  '对方基金账号',
  C_OTHERAGENCY  STRING  COMMENT  '对方销售商',
  C_OTHERNETNO  STRING  COMMENT  '对方网点',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_FORIGINALNO  STRING  COMMENT  '原申请编号',
  C_EXCEEDFLAG  STRING  COMMENT  '巨额赎回处理标志',
  C_CHILDNETNO  STRING  COMMENT  '操作网点编号',
  C_OTHERSHARE  STRING  COMMENT  '对方份额类别',
  C_ACTCODE  STRING  COMMENT  '活动代码',
  C_ACCEPTMODE  STRING  COMMENT  '交易方式',
  C_FREEZECAUSE  STRING  COMMENT  '冻结原因',
  C_FREEZEENDDATE  STRING  COMMENT  '冻结截止日期',
  F_TOTALBALANCE  DECIMAL(16,2)  COMMENT  '累计申购实现金额',
  F_TOTALSHARES  DECIMAL(16,2)  COMMENT  '累计赎回实现份额',
  C_OUTBUSINFLAG  STRING  COMMENT  '外部业务标志',
  C_PROTOCOLNO  STRING  COMMENT  '协议号',
  C_MEMO  STRING  COMMENT  '备注',
  F_REGISTFARE  DECIMAL(16,2)  COMMENT  '注册费',
  F_FUNDFARE  DECIMAL(16,2)  COMMENT  '归基金资产费',
  F_ORIAGIO  DECIMAL(5,4)  COMMENT  '原始费率折扣',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  D_CISDATE  STRING  COMMENT  '利息计算起始日期',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_FUNDTYPE  STRING  COMMENT  '资金方式',
  F_BACKFAREAGIO  DECIMAL(5,4)  COMMENT  '转换补差费折扣率',
  C_BANKNO  STRING  COMMENT  '银行编号',
  C_SUBFUNDMETHOD  STRING  COMMENT  '明细资金方式',
  C_COMBCODE  STRING  COMMENT  '组合编号',
  F_RETURNFARE  DECIMAL(16,2)  COMMENT  '',
  D_REQUESTTIME  STRING  COMMENT  '申请时间',
  C_ADJUSTMENTFLAG  STRING  COMMENT  '',
  F_SPECMANAGERFARE  DECIMAL(16,2)  COMMENT  '',
  F_PROTECTBALANCE  DECIMAL(16,2)  COMMENT  '',
  D_ORIGINALCFMDATE  STRING  COMMENT  '',
  F_VALUEADDEDFARE  DECIMAL(16,2)  COMMENT  '',
  C_SCFORICSERIALNO  STRING  COMMENT  '',
  C_NEGOTIATEFLAG  STRING  COMMENT  '',
  F_LONGREGISTPAY  DECIMAL(16,2)  COMMENT  '',
  C_PAYSHARESFLAG  STRING  COMMENT  '',
  F_LONGRATIONCOUNT  DECIMAL(10,0)  COMMENT  '',
  F_LONGALLOTPAY  DECIMAL(16,2)  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  D_FACTDATE  STRING  COMMENT  '',
  F_ADJUSTINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ADJUSTCYCLEINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ADJUSTACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_ADJUSTCYCLEACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_ORIREGISTFARE  DECIMAL(16,2)  COMMENT  '',
  C_RATIONKIND  STRING  COMMENT  '',
  C_RATIONKINDNO  STRING  COMMENT  '',
  C_ORIGINALNO  STRING  COMMENT  '原申请编号',
  C_CFMPREADJUSTFLAG  STRING  COMMENT  '',
  C_ISALLRDM  STRING  COMMENT  '',
  F_MRGINCOME  DECIMAL(16,2)  COMMENT  '',
  D_SCF02REQDATE  STRING  COMMENT  '',
  F_SCF02REQBANLANCE  DECIMAL(16,2)  COMMENT  '',
  C_ADJUSTSHAREFLAG  STRING  COMMENT  '',
  F_MGRINCOME  DECIMAL(16,2)  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  F_SCFMGRINCOME  DECIMAL(16,2)  COMMENT  '',
  D_ORI02REQDATE  STRING  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  F_ONTHEWAYCFMSHR  DECIMAL(16,2)  COMMENT  '',
  D_ORIGINALAPPDATE  STRING  COMMENT  '',
  F_RDMFEESHARES  DECIMAL(16,2)  COMMENT  '',
  C_WECHATREQUESTNO  STRING  COMMENT  '',
  D_LASTARCHIVEDATE  STRING  COMMENT  '',
  C_CITYNO  STRING  COMMENT  '',
  F_INVESTMANAGEFARE  DECIMAL(16,2)  COMMENT  '',
  F_MGRMANAGEFARE  DECIMAL(16,2)  COMMENT  '',
  F_DEDUCTPROTECT  DECIMAL(16,2)  COMMENT  '',
  C_TRANSFERCAUSE  STRING  COMMENT  '',
  C_IPADDRESS  STRING  COMMENT  '',
  C_MACADDRESS  STRING  COMMENT  '',
  C_IMEI  STRING  COMMENT  '',
  C_UUID  STRING  COMMENT  '',
  C_ACCTNAMEOFCLEARINGAGENCY  STRING  COMMENT  '',
  C_ACCTNOOFCLEARINGAGENCY  STRING  COMMENT  '',
  C_CLEARINGAGENCY  STRING  COMMENT  '',
  C_ERRORDETAIL  STRING  COMMENT  '',
  F_RAISEINTEREST  DECIMAL(16,2)  COMMENT  '',
  L_TERMOFPERIODICSUBS  DECIMAL(5,0)  COMMENT  '',
  D_PERIODICSUBSBEGIN  STRING  COMMENT  '',
  D_PERIODICSUBSEND  STRING  COMMENT  '',
  L_PERIODICSUBSSEND  DECIMAL(2,0)  COMMENT  '',
  C_BUSINESSFINISHFLAG  STRING  COMMENT  ''
)
COMMENT '交易确认表'
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
              "querySql": ["SELECT  C_BUSINFLAG
                                   , TO_CHAR(D_CDATE,'YYYYMMDD') D_CDATE
                                   , C_CSERIALNO
                                   , D_DATE
                                   , L_SERIALNO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , F_CONFIRMBALANCE
                                   , F_CONFIRMSHARES
                                   , F_TRADEFARE
                                   , F_TAFARE
                                   , F_STAMPTAX
                                   , F_BACKFARE
                                   , F_OTHERFARE1
                                   , F_INTEREST
                                   , F_INTERESTTAX
                                   , F_TOTALFARE
                                   , F_AGENCYFARE
                                   , F_NETVALUE
                                   , F_FROZENBALANCE
                                   , F_UNFROZENBALANCE
                                   , C_STATUS
                                   , C_CAUSE
                                   , C_TAFLAG
                                   , C_CUSTTYPE
                                   , C_CUSTNO
                                   , F_GAINBALANCE
                                   , F_ORIFARE
                                   , C_REQUESTENDFLAG
                                   , F_UNBALANCE
                                   , F_UNSHARES
                                   , C_RESERVE
                                   , F_INTERESTSHARE
                                   , F_CHINCOME
                                   , F_CHSHARE
                                   , F_CONFIRMINCOME
                                   , F_ORITRADEFARE
                                   , F_ORITAFARE
                                   , F_ORIBACKFARE
                                   , F_ORIOTHERFARE1
                                   , C_REQUESTNO
                                   , F_BALANCE
                                   , F_SHARES
                                   , F_AGIO
                                   , F_LASTSHARES
                                   , F_LASTFREEZESHARE
                                   , C_OTHERCODE
                                   , C_OTHERACCO
                                   , C_OTHERAGENCY
                                   , C_OTHERNETNO
                                   , C_BONUSTYPE
                                   , C_FORIGINALNO
                                   , C_EXCEEDFLAG
                                   , C_CHILDNETNO
                                   , C_OTHERSHARE
                                   , C_ACTCODE
                                   , C_ACCEPTMODE
                                   , C_FREEZECAUSE
                                   , C_FREEZEENDDATE
                                   , F_TOTALBALANCE
                                   , F_TOTALSHARES
                                   , C_OUTBUSINFLAG
                                   , C_PROTOCOLNO
                                   , C_MEMO
                                   , F_REGISTFARE
                                   , F_FUNDFARE
                                   , F_ORIAGIO
                                   , C_SHARECLASS
                                   , D_CISDATE
                                   , C_BOURSEFLAG
                                   , C_FUNDTYPE
                                   , F_BACKFAREAGIO
                                   , C_BANKNO
                                   , C_SUBFUNDMETHOD
                                   , C_COMBCODE
                                   , F_RETURNFARE
                                   , D_REQUESTTIME
                                   , C_ADJUSTMENTFLAG
                                   , F_SPECMANAGERFARE
                                   , F_PROTECTBALANCE
                                   , D_ORIGINALCFMDATE
                                   , F_VALUEADDEDFARE
                                   , C_SCFORICSERIALNO
                                   , C_NEGOTIATEFLAG
                                   , F_LONGREGISTPAY
                                   , C_PAYSHARESFLAG
                                   , F_LONGRATIONCOUNT
                                   , F_LONGALLOTPAY
                                   , C_SPECIALACCOFLAG
                                   , D_FACTDATE
                                   , F_ADJUSTINCOME
                                   , F_ADJUSTCYCLEINCOME
                                   , F_ADJUSTACCUMSHARES
                                   , F_ADJUSTCYCLEACCUMSHARES
                                   , F_ORIREGISTFARE
                                   , C_RATIONKIND
                                   , C_RATIONKINDNO
                                   , C_ORIGINALNO
                                   , C_CFMPREADJUSTFLAG
                                   , C_ISALLRDM
                                   , F_MRGINCOME
                                   , D_SCF02REQDATE
                                   , F_SCF02REQBANLANCE
                                   , C_ADJUSTSHAREFLAG
                                   , F_MGRINCOME
                                   , C_PARTNERID
                                   , F_SCFMGRINCOME
                                   , D_ORI02REQDATE
                                   , C_SUBFUNDCODE
                                   , F_ONTHEWAYCFMSHR
                                   , D_ORIGINALAPPDATE
                                   , F_RDMFEESHARES
                                   , C_WECHATREQUESTNO
                                   , D_LASTARCHIVEDATE
                                   , C_CITYNO
                                   , F_INVESTMANAGEFARE
                                   , F_MGRMANAGEFARE
                                   , F_DEDUCTPROTECT
                                   , C_TRANSFERCAUSE
                                   , C_IPADDRESS
                                   , C_MACADDRESS
                                   , C_IMEI
                                   , C_UUID
                                   , C_ACCTNAMEOFCLEARINGAGENCY
                                   , C_ACCTNOOFCLEARINGAGENCY
                                   , C_CLEARINGAGENCY
                                   , C_ERRORDETAIL
                                   , F_RAISEINTEREST
                                   , L_TERMOFPERIODICSUBS
                                   , D_PERIODICSUBSBEGIN
                                   , D_PERIODICSUBSEND
                                   , L_PERIODICSUBSSEND
                                   , C_BUSINESSFINISHFLAG
                                FROM ${hsfta_src_schema}.TCONFIRM
                                WHERE D_CDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "L_SERIALNO", "type": "DOUBLE"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "F_CONFIRMBALANCE", "type": "DOUBLE"}, {"name": "F_CONFIRMSHARES", "type": "DOUBLE"}, {"name": "F_TRADEFARE", "type": "DOUBLE"}, {"name": "F_TAFARE", "type": "DOUBLE"}, {"name": "F_STAMPTAX", "type": "DOUBLE"}, {"name": "F_BACKFARE", "type": "DOUBLE"}, {"name": "F_OTHERFARE1", "type": "DOUBLE"}, {"name": "F_INTEREST", "type": "DOUBLE"}, {"name": "F_INTERESTTAX", "type": "DOUBLE"}, {"name": "F_TOTALFARE", "type": "DOUBLE"}, {"name": "F_AGENCYFARE", "type": "DOUBLE"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_FROZENBALANCE", "type": "DOUBLE"}, {"name": "F_UNFROZENBALANCE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_CAUSE", "type": "STRING"}, {"name": "C_TAFLAG", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_CUSTNO", "type": "STRING"}, {"name": "F_GAINBALANCE", "type": "DOUBLE"}, {"name": "F_ORIFARE", "type": "DOUBLE"}, {"name": "C_REQUESTENDFLAG", "type": "STRING"}, {"name": "F_UNBALANCE", "type": "DOUBLE"}, {"name": "F_UNSHARES", "type": "DOUBLE"}, {"name": "C_RESERVE", "type": "STRING"}, {"name": "F_INTERESTSHARE", "type": "DOUBLE"}, {"name": "F_CHINCOME", "type": "DOUBLE"}, {"name": "F_CHSHARE", "type": "DOUBLE"}, {"name": "F_CONFIRMINCOME", "type": "DOUBLE"}, {"name": "F_ORITRADEFARE", "type": "DOUBLE"}, {"name": "F_ORITAFARE", "type": "DOUBLE"}, {"name": "F_ORIBACKFARE", "type": "DOUBLE"}, {"name": "F_ORIOTHERFARE1", "type": "DOUBLE"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "F_BALANCE", "type": "DOUBLE"}, {"name": "F_SHARES", "type": "DOUBLE"}, {"name": "F_AGIO", "type": "DOUBLE"}, {"name": "F_LASTSHARES", "type": "DOUBLE"}, {"name": "F_LASTFREEZESHARE", "type": "DOUBLE"}, {"name": "C_OTHERCODE", "type": "STRING"}, {"name": "C_OTHERACCO", "type": "STRING"}, {"name": "C_OTHERAGENCY", "type": "STRING"}, {"name": "C_OTHERNETNO", "type": "STRING"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_FORIGINALNO", "type": "STRING"}, {"name": "C_EXCEEDFLAG", "type": "STRING"}, {"name": "C_CHILDNETNO", "type": "STRING"}, {"name": "C_OTHERSHARE", "type": "STRING"}, {"name": "C_ACTCODE", "type": "STRING"}, {"name": "C_ACCEPTMODE", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "C_FREEZEENDDATE", "type": "STRING"}, {"name": "F_TOTALBALANCE", "type": "DOUBLE"}, {"name": "F_TOTALSHARES", "type": "DOUBLE"}, {"name": "C_OUTBUSINFLAG", "type": "STRING"}, {"name": "C_PROTOCOLNO", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "F_REGISTFARE", "type": "DOUBLE"}, {"name": "F_FUNDFARE", "type": "DOUBLE"}, {"name": "F_ORIAGIO", "type": "DOUBLE"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "D_CISDATE", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_FUNDTYPE", "type": "STRING"}, {"name": "F_BACKFAREAGIO", "type": "DOUBLE"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_SUBFUNDMETHOD", "type": "STRING"}, {"name": "C_COMBCODE", "type": "STRING"}, {"name": "F_RETURNFARE", "type": "DOUBLE"}, {"name": "D_REQUESTTIME", "type": "STRING"}, {"name": "C_ADJUSTMENTFLAG", "type": "STRING"}, {"name": "F_SPECMANAGERFARE", "type": "DOUBLE"}, {"name": "F_PROTECTBALANCE", "type": "DOUBLE"}, {"name": "D_ORIGINALCFMDATE", "type": "STRING"}, {"name": "F_VALUEADDEDFARE", "type": "DOUBLE"}, {"name": "C_SCFORICSERIALNO", "type": "STRING"}, {"name": "C_NEGOTIATEFLAG", "type": "STRING"}, {"name": "F_LONGREGISTPAY", "type": "DOUBLE"}, {"name": "C_PAYSHARESFLAG", "type": "STRING"}, {"name": "F_LONGRATIONCOUNT", "type": "DOUBLE"}, {"name": "F_LONGALLOTPAY", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "D_FACTDATE", "type": "STRING"}, {"name": "F_ADJUSTINCOME", "type": "DOUBLE"}, {"name": "F_ADJUSTCYCLEINCOME", "type": "DOUBLE"}, {"name": "F_ADJUSTACCUMSHARES", "type": "DOUBLE"}, {"name": "F_ADJUSTCYCLEACCUMSHARES", "type": "DOUBLE"}, {"name": "F_ORIREGISTFARE", "type": "DOUBLE"}, {"name": "C_RATIONKIND", "type": "STRING"}, {"name": "C_RATIONKINDNO", "type": "STRING"}, {"name": "C_ORIGINALNO", "type": "STRING"}, {"name": "C_CFMPREADJUSTFLAG", "type": "STRING"}, {"name": "C_ISALLRDM", "type": "STRING"}, {"name": "F_MRGINCOME", "type": "DOUBLE"}, {"name": "D_SCF02REQDATE", "type": "STRING"}, {"name": "F_SCF02REQBANLANCE", "type": "DOUBLE"}, {"name": "C_ADJUSTSHAREFLAG", "type": "STRING"}, {"name": "F_MGRINCOME", "type": "DOUBLE"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "F_SCFMGRINCOME", "type": "DOUBLE"}, {"name": "D_ORI02REQDATE", "type": "STRING"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "F_ONTHEWAYCFMSHR", "type": "DOUBLE"}, {"name": "D_ORIGINALAPPDATE", "type": "STRING"}, {"name": "F_RDMFEESHARES", "type": "DOUBLE"}, {"name": "C_WECHATREQUESTNO", "type": "STRING"}, {"name": "D_LASTARCHIVEDATE", "type": "STRING"}, {"name": "C_CITYNO", "type": "STRING"}, {"name": "F_INVESTMANAGEFARE", "type": "DOUBLE"}, {"name": "F_MGRMANAGEFARE", "type": "DOUBLE"}, {"name": "F_DEDUCTPROTECT", "type": "DOUBLE"}, {"name": "C_TRANSFERCAUSE", "type": "STRING"}, {"name": "C_IPADDRESS", "type": "STRING"}, {"name": "C_MACADDRESS", "type": "STRING"}, {"name": "C_IMEI", "type": "STRING"}, {"name": "C_UUID", "type": "STRING"}, {"name": "C_ACCTNAMEOFCLEARINGAGENCY", "type": "STRING"}, {"name": "C_ACCTNOOFCLEARINGAGENCY", "type": "STRING"}, {"name": "C_CLEARINGAGENCY", "type": "STRING"}, {"name": "C_ERRORDETAIL", "type": "STRING"}, {"name": "F_RAISEINTEREST", "type": "DOUBLE"}, {"name": "L_TERMOFPERIODICSUBS", "type": "DOUBLE"}, {"name": "D_PERIODICSUBSBEGIN", "type": "STRING"}, {"name": "D_PERIODICSUBSEND", "type": "STRING"}, {"name": "L_PERIODICSUBSSEND", "type": "DOUBLE"}, {"name": "C_BUSINESSFINISHFLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tconfirm_ptd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tconfirm_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tconfirm_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tconfirm_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TCONFIRM_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TCONFIRM_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tconfirm_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCONFIRM_PTD PARTITION(P_DT)
SELECT
       C_BUSINFLAG
     , D_CDATE
     , C_CSERIALNO
     , D_DATE
     , L_SERIALNO
     , C_AGENCYNO
     , C_NETNO
     , C_FUNDACCO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , F_CONFIRMBALANCE
     , F_CONFIRMSHARES
     , F_TRADEFARE
     , F_TAFARE
     , F_STAMPTAX
     , F_BACKFARE
     , F_OTHERFARE1
     , F_INTEREST
     , F_INTERESTTAX
     , F_TOTALFARE
     , F_AGENCYFARE
     , F_NETVALUE
     , F_FROZENBALANCE
     , F_UNFROZENBALANCE
     , C_STATUS
     , C_CAUSE
     , C_TAFLAG
     , C_CUSTTYPE
     , C_CUSTNO
     , F_GAINBALANCE
     , F_ORIFARE
     , C_REQUESTENDFLAG
     , F_UNBALANCE
     , F_UNSHARES
     , C_RESERVE
     , F_INTERESTSHARE
     , F_CHINCOME
     , F_CHSHARE
     , F_CONFIRMINCOME
     , F_ORITRADEFARE
     , F_ORITAFARE
     , F_ORIBACKFARE
     , F_ORIOTHERFARE1
     , C_REQUESTNO
     , F_BALANCE
     , F_SHARES
     , F_AGIO
     , F_LASTSHARES
     , F_LASTFREEZESHARE
     , C_OTHERCODE
     , C_OTHERACCO
     , C_OTHERAGENCY
     , C_OTHERNETNO
     , C_BONUSTYPE
     , C_FORIGINALNO
     , C_EXCEEDFLAG
     , C_CHILDNETNO
     , C_OTHERSHARE
     , C_ACTCODE
     , C_ACCEPTMODE
     , C_FREEZECAUSE
     , C_FREEZEENDDATE
     , F_TOTALBALANCE
     , F_TOTALSHARES
     , C_OUTBUSINFLAG
     , C_PROTOCOLNO
     , C_MEMO
     , F_REGISTFARE
     , F_FUNDFARE
     , F_ORIAGIO
     , C_SHARECLASS
     , D_CISDATE
     , C_BOURSEFLAG
     , C_FUNDTYPE
     , F_BACKFAREAGIO
     , C_BANKNO
     , C_SUBFUNDMETHOD
     , C_COMBCODE
     , F_RETURNFARE
     , D_REQUESTTIME
     , C_ADJUSTMENTFLAG
     , F_SPECMANAGERFARE
     , F_PROTECTBALANCE
     , D_ORIGINALCFMDATE
     , F_VALUEADDEDFARE
     , C_SCFORICSERIALNO
     , C_NEGOTIATEFLAG
     , F_LONGREGISTPAY
     , C_PAYSHARESFLAG
     , F_LONGRATIONCOUNT
     , F_LONGALLOTPAY
     , C_SPECIALACCOFLAG
     , D_FACTDATE
     , F_ADJUSTINCOME
     , F_ADJUSTCYCLEINCOME
     , F_ADJUSTACCUMSHARES
     , F_ADJUSTCYCLEACCUMSHARES
     , F_ORIREGISTFARE
     , C_RATIONKIND
     , C_RATIONKINDNO
     , C_ORIGINALNO
     , C_CFMPREADJUSTFLAG
     , C_ISALLRDM
     , F_MRGINCOME
     , D_SCF02REQDATE
     , F_SCF02REQBANLANCE
     , C_ADJUSTSHAREFLAG
     , F_MGRINCOME
     , C_PARTNERID
     , F_SCFMGRINCOME
     , D_ORI02REQDATE
     , C_SUBFUNDCODE
     , F_ONTHEWAYCFMSHR
     , D_ORIGINALAPPDATE
     , F_RDMFEESHARES
     , C_WECHATREQUESTNO
     , D_LASTARCHIVEDATE
     , C_CITYNO
     , F_INVESTMANAGEFARE
     , F_MGRMANAGEFARE
     , F_DEDUCTPROTECT
     , C_TRANSFERCAUSE
     , C_IPADDRESS
     , C_MACADDRESS
     , C_IMEI
     , C_UUID
     , C_ACCTNAMEOFCLEARINGAGENCY
     , C_ACCTNOOFCLEARINGAGENCY
     , C_CLEARINGAGENCY
     , C_ERRORDETAIL
     , F_RAISEINTEREST
     , L_TERMOFPERIODICSUBS
     , D_PERIODICSUBSBEGIN
     , D_PERIODICSUBSEND
     , L_PERIODICSUBSSEND
     , C_BUSINESSFINISHFLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_CDATE,'-','') P_DT
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TCONFIRM_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TCONFIRM_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TCONFIRM_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TCONFIRM_PTD成功"
      exit 0
   fi
fi
