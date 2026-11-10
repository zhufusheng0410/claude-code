#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TREQUEST_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TREQUEST_PTD_TMP(
  C_BUSINFLAG  STRING  COMMENT  '业务代码',
  D_DATE  STRING  COMMENT  '发放日期',
  L_SERIALNO  DECIMAL(10,0)  COMMENT  '申请序号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  D_REQUESTDATE  STRING  COMMENT  '申请日期',
  C_REQUESTNO  STRING  COMMENT  '申请编号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  F_BALANCE  DECIMAL(16,2)  COMMENT  '申请金额',
  F_SHARES  DECIMAL(16,2)  COMMENT  '申请份额',
  F_FOREFARE  DECIMAL(16,2)  COMMENT  '',
  C_OTHERCODE  STRING  COMMENT  '对方基金代码',
  C_OTHERSHARE  STRING  COMMENT  '对方份额类别',
  C_OTHERACCO  STRING  COMMENT  '对方基金账号',
  C_OTHERTRADEACCO  STRING  COMMENT  '对方交易账号',
  C_OTHERAGENCY  STRING  COMMENT  '对方销售商',
  C_OTHERNETNO  STRING  COMMENT  '对方网点',
  D_ORIGINALDATE  STRING  COMMENT  '份额原确认日期',
  C_ORIGINALNO  STRING  COMMENT  '原确认编号',
  C_EXCEEDFLAG  STRING  COMMENT  '巨额赎回处理标志',
  D_HOPEDATE  STRING  COMMENT  '希望处理日期',
  F_AGIO  DECIMAL(5,4)  COMMENT  '费率折扣',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_FREEZECAUSE  STRING  COMMENT  '冻结原因',
  C_FREEZEENDDATE  STRING  COMMENT  '冻结截止日期',
  C_FREEZENO  STRING  COMMENT  '冻结法律文书号',
  C_UNFREEZENO  STRING  COMMENT  '解冻法律文书号',
  C_FORIGINALNO  STRING  COMMENT  '原申请编号',
  D_REGISTDATE  STRING  COMMENT  '份额注册日期',
  L_RATIONDATE  DECIMAL(10,0)  COMMENT  '定期日期',
  C_RATIONTERM  STRING  COMMENT  '定期定额周期',
  C_PROTOCOLNO  STRING  COMMENT  '协议号',
  D_PROTOCOLENDDATE  STRING  COMMENT  '协议截止日期',
  C_CHILDNETNO  STRING  COMMENT  '操作网点编号',
  C_CITYNO  STRING  COMMENT  '城市编号(地区)',
  C_TAFLAG  STRING  COMMENT  'TA发起标志',
  C_OUTBUSINFLAG  STRING  COMMENT  '外部业务标志',
  C_AUDITFLAG  STRING  COMMENT  '复核标志',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_CUSTNO  STRING  COMMENT  '客户编号',
  D_CDATE  STRING  COMMENT  '最后确认日期',
  C_STATUS  STRING  COMMENT  '确认状态',
  C_CAUSE  STRING  COMMENT  '失败原因',
  F_CONFIRMBALANCE  DECIMAL(16,2)  COMMENT  '确认金额(累计)',
  F_CONFIRMSHARES  DECIMAL(16,2)  COMMENT  '确认份额(累计)',
  C_MEMO  STRING  COMMENT  '备注',
  C_RESERVE  STRING  COMMENT  '申请交易账号',
  F_ORIAGIO  DECIMAL(5,4)  COMMENT  '原始费率折扣',
  F_CONFIRMRATIO  DECIMAL(9,8)  COMMENT  '确认比例',
  F_RULEAGIO  DECIMAL(5,4)  COMMENT  '符合规则的折扣',
  C_NODEALFLAG  STRING  COMMENT  '不用处理标志',
  C_BROKER  STRING  COMMENT  '经纪人',
  F_PRICE  DECIMAL(16,8)  COMMENT  '设置成交价格',
  F_OTHERPRICE  DECIMAL(16,8)  COMMENT  '设置的对方价格',
  F_CHSHARE  DECIMAL(16,2)  COMMENT  '兑付份额（累计）',
  C_OPERATOR  STRING  COMMENT  '操作员',
  C_ACTCODE  STRING  COMMENT  '促销活动代码',
  C_ACCEPTMODE  STRING  COMMENT  '交易方式',
  C_TRANSFERCAUSE  STRING  COMMENT  '过户原因',
  D_CDATE1  STRING  COMMENT  '首次处理日期',
  D_REQUESTTIME  STRING  COMMENT  '申请时间',
  F_INCOME  DECIMAL(16,2)  COMMENT  '昨日基金收益',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_FUNDTYPE  STRING  COMMENT  '资金方式',
  F_BACKFAREAGIO  DECIMAL(5,4)  COMMENT  '转换补差费折扣率',
  C_BANKNO  STRING  COMMENT  '银行编号',
  C_SUBFUNDMETHOD  STRING  COMMENT  '明细资金方式',
  C_COMBCODE  STRING  COMMENT  '组合编号',
  C_IMPROPERREDEEM  STRING  COMMENT  'C_IMPROPERREDEEM',
  F_PUNISHRATIO  DECIMAL(5,4)  COMMENT  'F_PUNISHRATIO',
  C_MAINTRDACCO  STRING  COMMENT  'C_MAINTRDACCO',
  C_TACODE  STRING  COMMENT  'TA代码',
  C_ZDCSERIALNO  STRING  COMMENT  '',
  F_SPECMANAGERFARE  DECIMAL(16,2)  COMMENT  '',
  F_CONFIRMAGIO  DECIMAL(5,4)  COMMENT  '',
  C_RATIONVARIETY  STRING  COMMENT  '',
  C_RATIONSERIALNO  STRING  COMMENT  '',
  C_RATIONTYPE  STRING  COMMENT  '定期定额类型',
  D_PROTOCOLBEGINDATE  STRING  COMMENT  '',
  C_RATIONPURPOSE  STRING  COMMENT  '',
  L_RATIONFREQUENCY  DECIMAL(5,0)  COMMENT  '',
  C_RATIONNUM  DECIMAL(16,2)  COMMENT  '',
  C_RATIONTIMEUNIT  STRING  COMMENT  '',
  C_TRADEMETHOD  STRING  COMMENT  '',
  L_LIQUIDATEDAYS  DECIMAL(3,0)  COMMENT  '',
  C_CREDITREDEEMFLAG  STRING  COMMENT  '',
  F_ADVANCESHARE  DECIMAL(16,2)  COMMENT  '',
  C_PAYSHARESFLAG  STRING  COMMENT  '',
  C_NORDMFARE  STRING  COMMENT  '',
  F_FINALCFMBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_ORIBACKFAREAGIO  DECIMAL(5,4)  COMMENT  '后收费折扣率',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  D_FACTDATE  STRING  COMMENT  '',
  C_DETAILFLAG  STRING  COMMENT  '',
  F_TRADEFARE  DECIMAL(16,2)  COMMENT  '交易费',
  C_RATIONKIND  STRING  COMMENT  '',
  C_RATIONKINDNO  STRING  COMMENT  '',
  C_TODAYNODEALFLAG  STRING  COMMENT  '',
  C_ISALLRDM  STRING  COMMENT  '',
  F_MGRINCOME  DECIMAL(16,2)  COMMENT  '',
  F_PRETOTALFARE  DECIMAL(16,2)  COMMENT  '',
  C_ZCBORDERID  STRING  COMMENT  '',
  D_CYCLEENDDATE  STRING  COMMENT  '',
  F_UNINCOMESHARES  DECIMAL(16,2)  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  D_ORI02REQDATE  STRING  COMMENT  '',
  F_SCFMGRINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ONTHEWAYREQSHR  DECIMAL(16,2)  COMMENT  '',
  C_TRANONWAYSHRFLAG  STRING  COMMENT  '',
  D_OPTIME  STRING  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  C_ZYTYPE  STRING  COMMENT  '',
  C_SUBTANOSHARE  STRING  COMMENT  '',
  C_REQDATATYPE  STRING  COMMENT  '',
  C_ISCALCRDMFEE  STRING  COMMENT  '',
  F_RDMFEESHARES  DECIMAL(16,2)  COMMENT  '',
  C_MANUALAGIOFLAG  STRING  COMMENT  '',
  C_SLBORIGINALNO  STRING  COMMENT  '',
  C_SPECIFICATION  STRING  COMMENT  '',
  C_WECHATREQUESTNO  STRING  COMMENT  '',
  D_PROFITHOLDENDDATE  STRING  COMMENT  '',
  C_OUTFUND  STRING  COMMENT  '',
  C_OUTOTHERFUND  STRING  COMMENT  '',
  F_EXTENDSHARES  DECIMAL(16,2)  COMMENT  '',
  D_LASTARCHIVEDATE  STRING  COMMENT  '',
  F_DEDUCTPROTECT  DECIMAL(16,2)  COMMENT  '',
  C_IPADDRESS  STRING  COMMENT  '',
  C_MACADDRESS  STRING  COMMENT  '',
  C_IMEI  STRING  COMMENT  '',
  C_UUID  STRING  COMMENT  '',
  C_ACCTNAMEOFCLEARINGAGENCY  STRING  COMMENT  '',
  C_ACCTNOOFCLEARINGAGENCY  STRING  COMMENT  '',
  C_CLEARINGAGENCY  STRING  COMMENT  '',
  C_ERRORDETAIL  STRING  COMMENT  '',
  C_SHARESADJUSTFLAG  STRING  COMMENT  '',
  F_TOTALSUCCESSFUL  DECIMAL(16,2)  COMMENT  ''
)
COMMENT '交易申请表'
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
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , L_SERIALNO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , D_REQUESTDATE
                                   , C_REQUESTNO
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , F_BALANCE
                                   , F_SHARES
                                   , F_FOREFARE
                                   , C_OTHERCODE
                                   , C_OTHERSHARE
                                   , C_OTHERACCO
                                   , C_OTHERTRADEACCO
                                   , C_OTHERAGENCY
                                   , C_OTHERNETNO
                                   , D_ORIGINALDATE
                                   , C_ORIGINALNO
                                   , C_EXCEEDFLAG
                                   , D_HOPEDATE
                                   , F_AGIO
                                   , C_BONUSTYPE
                                   , C_FREEZECAUSE
                                   , C_FREEZEENDDATE
                                   , C_FREEZENO
                                   , C_UNFREEZENO
                                   , C_FORIGINALNO
                                   , D_REGISTDATE
                                   , L_RATIONDATE
                                   , C_RATIONTERM
                                   , C_PROTOCOLNO
                                   , D_PROTOCOLENDDATE
                                   , C_CHILDNETNO
                                   , C_CITYNO
                                   , C_TAFLAG
                                   , C_OUTBUSINFLAG
                                   , C_AUDITFLAG
                                   , C_CUSTTYPE
                                   , C_CUSTNO
                                   , D_CDATE
                                   , C_STATUS
                                   , C_CAUSE
                                   , F_CONFIRMBALANCE
                                   , F_CONFIRMSHARES
                                   , C_MEMO
                                   , C_RESERVE
                                   , F_ORIAGIO
                                   , F_CONFIRMRATIO
                                   , F_RULEAGIO
                                   , C_NODEALFLAG
                                   , C_BROKER
                                   , F_PRICE
                                   , F_OTHERPRICE
                                   , F_CHSHARE
                                   , C_OPERATOR
                                   , C_ACTCODE
                                   , C_ACCEPTMODE
                                   , C_TRANSFERCAUSE
                                   , D_CDATE1
                                   , D_REQUESTTIME
                                   , F_INCOME
                                   , C_BOURSEFLAG
                                   , C_FUNDTYPE
                                   , F_BACKFAREAGIO
                                   , C_BANKNO
                                   , C_SUBFUNDMETHOD
                                   , C_COMBCODE
                                   , C_IMPROPERREDEEM
                                   , F_PUNISHRATIO
                                   , C_MAINTRDACCO
                                   , C_TACODE
                                   , C_ZDCSERIALNO
                                   , F_SPECMANAGERFARE
                                   , F_CONFIRMAGIO
                                   , C_RATIONVARIETY
                                   , C_RATIONSERIALNO
                                   , C_RATIONTYPE
                                   , D_PROTOCOLBEGINDATE
                                   , C_RATIONPURPOSE
                                   , L_RATIONFREQUENCY
                                   , C_RATIONNUM
                                   , C_RATIONTIMEUNIT
                                   , C_TRADEMETHOD
                                   , L_LIQUIDATEDAYS
                                   , C_CREDITREDEEMFLAG
                                   , F_ADVANCESHARE
                                   , C_PAYSHARESFLAG
                                   , C_NORDMFARE
                                   , F_FINALCFMBALANCE
                                   , F_ORIBACKFAREAGIO
                                   , C_SPECIALACCOFLAG
                                   , D_FACTDATE
                                   , C_DETAILFLAG
                                   , F_TRADEFARE
                                   , C_RATIONKIND
                                   , C_RATIONKINDNO
                                   , C_TODAYNODEALFLAG
                                   , C_ISALLRDM
                                   , F_MGRINCOME
                                   , F_PRETOTALFARE
                                   , C_ZCBORDERID
                                   , D_CYCLEENDDATE
                                   , F_UNINCOMESHARES
                                   , C_PARTNERID
                                   , D_ORI02REQDATE
                                   , F_SCFMGRINCOME
                                   , F_ONTHEWAYREQSHR
                                   , C_TRANONWAYSHRFLAG
                                   , D_OPTIME
                                   , C_SUBFUNDCODE
                                   , C_ZYTYPE
                                   , C_SUBTANOSHARE
                                   , C_REQDATATYPE
                                   , C_ISCALCRDMFEE
                                   , F_RDMFEESHARES
                                   , C_MANUALAGIOFLAG
                                   , C_SLBORIGINALNO
                                   , C_SPECIFICATION
                                   , C_WECHATREQUESTNO
                                   , D_PROFITHOLDENDDATE
                                   , C_OUTFUND
                                   , C_OUTOTHERFUND
                                   , F_EXTENDSHARES
                                   , D_LASTARCHIVEDATE
                                   , F_DEDUCTPROTECT
                                   , C_IPADDRESS
                                   , C_MACADDRESS
                                   , C_IMEI
                                   , C_UUID
                                   , C_ACCTNAMEOFCLEARINGAGENCY
                                   , C_ACCTNOOFCLEARINGAGENCY
                                   , C_CLEARINGAGENCY
                                   , C_ERRORDETAIL
                                   , C_SHARESADJUSTFLAG
                                   , F_TOTALSUCCESSFUL
                                FROM ${hsfta_src_schema}.TREQUEST
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "L_SERIALNO", "type": "DOUBLE"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "D_REQUESTDATE", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "F_BALANCE", "type": "DOUBLE"}, {"name": "F_SHARES", "type": "DOUBLE"}, {"name": "F_FOREFARE", "type": "DOUBLE"}, {"name": "C_OTHERCODE", "type": "STRING"}, {"name": "C_OTHERSHARE", "type": "STRING"}, {"name": "C_OTHERACCO", "type": "STRING"}, {"name": "C_OTHERTRADEACCO", "type": "STRING"}, {"name": "C_OTHERAGENCY", "type": "STRING"}, {"name": "C_OTHERNETNO", "type": "STRING"}, {"name": "D_ORIGINALDATE", "type": "STRING"}, {"name": "C_ORIGINALNO", "type": "STRING"}, {"name": "C_EXCEEDFLAG", "type": "STRING"}, {"name": "D_HOPEDATE", "type": "STRING"}, {"name": "F_AGIO", "type": "DOUBLE"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "C_FREEZEENDDATE", "type": "STRING"}, {"name": "C_FREEZENO", "type": "STRING"}, {"name": "C_UNFREEZENO", "type": "STRING"}, {"name": "C_FORIGINALNO", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "L_RATIONDATE", "type": "DOUBLE"}, {"name": "C_RATIONTERM", "type": "STRING"}, {"name": "C_PROTOCOLNO", "type": "STRING"}, {"name": "D_PROTOCOLENDDATE", "type": "STRING"}, {"name": "C_CHILDNETNO", "type": "STRING"}, {"name": "C_CITYNO", "type": "STRING"}, {"name": "C_TAFLAG", "type": "STRING"}, {"name": "C_OUTBUSINFLAG", "type": "STRING"}, {"name": "C_AUDITFLAG", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_CUSTNO", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_CAUSE", "type": "STRING"}, {"name": "F_CONFIRMBALANCE", "type": "DOUBLE"}, {"name": "F_CONFIRMSHARES", "type": "DOUBLE"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "C_RESERVE", "type": "STRING"}, {"name": "F_ORIAGIO", "type": "DOUBLE"}, {"name": "F_CONFIRMRATIO", "type": "DOUBLE"}, {"name": "F_RULEAGIO", "type": "DOUBLE"}, {"name": "C_NODEALFLAG", "type": "STRING"}, {"name": "C_BROKER", "type": "STRING"}, {"name": "F_PRICE", "type": "DOUBLE"}, {"name": "F_OTHERPRICE", "type": "DOUBLE"}, {"name": "F_CHSHARE", "type": "DOUBLE"}, {"name": "C_OPERATOR", "type": "STRING"}, {"name": "C_ACTCODE", "type": "STRING"}, {"name": "C_ACCEPTMODE", "type": "STRING"}, {"name": "C_TRANSFERCAUSE", "type": "STRING"}, {"name": "D_CDATE1", "type": "STRING"}, {"name": "D_REQUESTTIME", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_FUNDTYPE", "type": "STRING"}, {"name": "F_BACKFAREAGIO", "type": "DOUBLE"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_SUBFUNDMETHOD", "type": "STRING"}, {"name": "C_COMBCODE", "type": "STRING"}, {"name": "C_IMPROPERREDEEM", "type": "STRING"}, {"name": "F_PUNISHRATIO", "type": "DOUBLE"}, {"name": "C_MAINTRDACCO", "type": "STRING"}, {"name": "C_TACODE", "type": "STRING"}, {"name": "C_ZDCSERIALNO", "type": "STRING"}, {"name": "F_SPECMANAGERFARE", "type": "DOUBLE"}, {"name": "F_CONFIRMAGIO", "type": "DOUBLE"}, {"name": "C_RATIONVARIETY", "type": "STRING"}, {"name": "C_RATIONSERIALNO", "type": "STRING"}, {"name": "C_RATIONTYPE", "type": "STRING"}, {"name": "D_PROTOCOLBEGINDATE", "type": "STRING"}, {"name": "C_RATIONPURPOSE", "type": "STRING"}, {"name": "L_RATIONFREQUENCY", "type": "DOUBLE"}, {"name": "C_RATIONNUM", "type": "DOUBLE"}, {"name": "C_RATIONTIMEUNIT", "type": "STRING"}, {"name": "C_TRADEMETHOD", "type": "STRING"}, {"name": "L_LIQUIDATEDAYS", "type": "DOUBLE"}, {"name": "C_CREDITREDEEMFLAG", "type": "STRING"}, {"name": "F_ADVANCESHARE", "type": "DOUBLE"}, {"name": "C_PAYSHARESFLAG", "type": "STRING"}, {"name": "C_NORDMFARE", "type": "STRING"}, {"name": "F_FINALCFMBALANCE", "type": "DOUBLE"}, {"name": "F_ORIBACKFAREAGIO", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "D_FACTDATE", "type": "STRING"}, {"name": "C_DETAILFLAG", "type": "STRING"}, {"name": "F_TRADEFARE", "type": "DOUBLE"}, {"name": "C_RATIONKIND", "type": "STRING"}, {"name": "C_RATIONKINDNO", "type": "STRING"}, {"name": "C_TODAYNODEALFLAG", "type": "STRING"}, {"name": "C_ISALLRDM", "type": "STRING"}, {"name": "F_MGRINCOME", "type": "DOUBLE"}, {"name": "F_PRETOTALFARE", "type": "DOUBLE"}, {"name": "C_ZCBORDERID", "type": "STRING"}, {"name": "D_CYCLEENDDATE", "type": "STRING"}, {"name": "F_UNINCOMESHARES", "type": "DOUBLE"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "D_ORI02REQDATE", "type": "STRING"}, {"name": "F_SCFMGRINCOME", "type": "DOUBLE"}, {"name": "F_ONTHEWAYREQSHR", "type": "DOUBLE"}, {"name": "C_TRANONWAYSHRFLAG", "type": "STRING"}, {"name": "D_OPTIME", "type": "STRING"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "C_ZYTYPE", "type": "STRING"}, {"name": "C_SUBTANOSHARE", "type": "STRING"}, {"name": "C_REQDATATYPE", "type": "STRING"}, {"name": "C_ISCALCRDMFEE", "type": "STRING"}, {"name": "F_RDMFEESHARES", "type": "DOUBLE"}, {"name": "C_MANUALAGIOFLAG", "type": "STRING"}, {"name": "C_SLBORIGINALNO", "type": "STRING"}, {"name": "C_SPECIFICATION", "type": "STRING"}, {"name": "C_WECHATREQUESTNO", "type": "STRING"}, {"name": "D_PROFITHOLDENDDATE", "type": "STRING"}, {"name": "C_OUTFUND", "type": "STRING"}, {"name": "C_OUTOTHERFUND", "type": "STRING"}, {"name": "F_EXTENDSHARES", "type": "DOUBLE"}, {"name": "D_LASTARCHIVEDATE", "type": "STRING"}, {"name": "F_DEDUCTPROTECT", "type": "DOUBLE"}, {"name": "C_IPADDRESS", "type": "STRING"}, {"name": "C_MACADDRESS", "type": "STRING"}, {"name": "C_IMEI", "type": "STRING"}, {"name": "C_UUID", "type": "STRING"}, {"name": "C_ACCTNAMEOFCLEARINGAGENCY", "type": "STRING"}, {"name": "C_ACCTNOOFCLEARINGAGENCY", "type": "STRING"}, {"name": "C_CLEARINGAGENCY", "type": "STRING"}, {"name": "C_ERRORDETAIL", "type": "STRING"}, {"name": "C_SHARESADJUSTFLAG", "type": "STRING"}, {"name": "F_TOTALSUCCESSFUL", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_trequest_ptd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_trequest_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_trequest_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_trequest_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TREQUEST_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TREQUEST_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_trequest_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TREQUEST_PTD PARTITION(P_DT)
SELECT
       C_BUSINFLAG
     , D_DATE
     , L_SERIALNO
     , C_AGENCYNO
     , C_NETNO
     , D_REQUESTDATE
     , C_REQUESTNO
     , C_FUNDACCO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , F_BALANCE
     , F_SHARES
     , F_FOREFARE
     , C_OTHERCODE
     , C_OTHERSHARE
     , C_OTHERACCO
     , C_OTHERTRADEACCO
     , C_OTHERAGENCY
     , C_OTHERNETNO
     , D_ORIGINALDATE
     , C_ORIGINALNO
     , C_EXCEEDFLAG
     , D_HOPEDATE
     , F_AGIO
     , C_BONUSTYPE
     , C_FREEZECAUSE
     , C_FREEZEENDDATE
     , C_FREEZENO
     , C_UNFREEZENO
     , C_FORIGINALNO
     , D_REGISTDATE
     , L_RATIONDATE
     , C_RATIONTERM
     , C_PROTOCOLNO
     , D_PROTOCOLENDDATE
     , C_CHILDNETNO
     , C_CITYNO
     , C_TAFLAG
     , C_OUTBUSINFLAG
     , C_AUDITFLAG
     , C_CUSTTYPE
     , C_CUSTNO
     , D_CDATE
     , C_STATUS
     , C_CAUSE
     , F_CONFIRMBALANCE
     , F_CONFIRMSHARES
     , C_MEMO
     , C_RESERVE
     , F_ORIAGIO
     , F_CONFIRMRATIO
     , F_RULEAGIO
     , C_NODEALFLAG
     , C_BROKER
     , F_PRICE
     , F_OTHERPRICE
     , F_CHSHARE
     , C_OPERATOR
     , C_ACTCODE
     , C_ACCEPTMODE
     , C_TRANSFERCAUSE
     , D_CDATE1
     , D_REQUESTTIME
     , F_INCOME
     , C_BOURSEFLAG
     , C_FUNDTYPE
     , F_BACKFAREAGIO
     , C_BANKNO
     , C_SUBFUNDMETHOD
     , C_COMBCODE
     , C_IMPROPERREDEEM
     , F_PUNISHRATIO
     , C_MAINTRDACCO
     , C_TACODE
     , C_ZDCSERIALNO
     , F_SPECMANAGERFARE
     , F_CONFIRMAGIO
     , C_RATIONVARIETY
     , C_RATIONSERIALNO
     , C_RATIONTYPE
     , D_PROTOCOLBEGINDATE
     , C_RATIONPURPOSE
     , L_RATIONFREQUENCY
     , C_RATIONNUM
     , C_RATIONTIMEUNIT
     , C_TRADEMETHOD
     , L_LIQUIDATEDAYS
     , C_CREDITREDEEMFLAG
     , F_ADVANCESHARE
     , C_PAYSHARESFLAG
     , C_NORDMFARE
     , F_FINALCFMBALANCE
     , F_ORIBACKFAREAGIO
     , C_SPECIALACCOFLAG
     , D_FACTDATE
     , C_DETAILFLAG
     , F_TRADEFARE
     , C_RATIONKIND
     , C_RATIONKINDNO
     , C_TODAYNODEALFLAG
     , C_ISALLRDM
     , F_MGRINCOME
     , F_PRETOTALFARE
     , C_ZCBORDERID
     , D_CYCLEENDDATE
     , F_UNINCOMESHARES
     , C_PARTNERID
     , D_ORI02REQDATE
     , F_SCFMGRINCOME
     , F_ONTHEWAYREQSHR
     , C_TRANONWAYSHRFLAG
     , D_OPTIME
     , C_SUBFUNDCODE
     , C_ZYTYPE
     , C_SUBTANOSHARE
     , C_REQDATATYPE
     , C_ISCALCRDMFEE
     , F_RDMFEESHARES
     , C_MANUALAGIOFLAG
     , C_SLBORIGINALNO
     , C_SPECIFICATION
     , C_WECHATREQUESTNO
     , D_PROFITHOLDENDDATE
     , C_OUTFUND
     , C_OUTOTHERFUND
     , F_EXTENDSHARES
     , D_LASTARCHIVEDATE
     , F_DEDUCTPROTECT
     , C_IPADDRESS
     , C_MACADDRESS
     , C_IMEI
     , C_UUID
     , C_ACCTNAMEOFCLEARINGAGENCY
     , C_ACCTNOOFCLEARINGAGENCY
     , C_CLEARINGAGENCY
     , C_ERRORDETAIL
     , C_SHARESADJUSTFLAG
     , F_TOTALSUCCESSFUL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TREQUEST_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TREQUEST_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TREQUEST_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TREQUEST_PTD成功"
      exit 0
   fi
fi
