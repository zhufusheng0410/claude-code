#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TREQUEST_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TREQUEST_PTD_TMP(
  C_BUSINFLAG  STRING  COMMENT  '业务类型',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  D_REQUESTDATE  STRING  COMMENT  '申请日期',
  D_REQUESTTIME  STRING  COMMENT  '申请时间',
  C_REQUESTNO  STRING  COMMENT  '申请编号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  F_BALANCE  DECIMAL(16,2)  COMMENT  '申请金额',
  F_SHARES  DECIMAL(16,2)  COMMENT  '申请份额',
  C_OTHERCODE  STRING  COMMENT  '对方基金代码',
  C_OTHERSHARE  STRING  COMMENT  '对方份额类别',
  C_OTHERACCO  STRING  COMMENT  '对方基金账号',
  C_OTHERTRADEACCO  STRING  COMMENT  '对方交易账号',
  C_OTHERAGENCY  STRING  COMMENT  '对方销售商',
  C_OTHERNETNO  STRING  COMMENT  '对方网点',
  D_ORIGINALDATE  STRING  COMMENT  '份额原确认日期',
  C_ORICSERIALNO  STRING  COMMENT  '源确认单号',
  D_REGISTDATE  STRING  COMMENT  '份额注册日期',
  C_EXCEEDFLAG  STRING  COMMENT  '巨额赎回处理标志',
  D_HOPEDATE  STRING  COMMENT  '希望处理日期',
  F_AGIO  DECIMAL(5,4)  COMMENT  '费率折扣',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_FREEZECAUSE  STRING  COMMENT  '冻结原因',
  C_FREEZEENDDATE  STRING  COMMENT  '冻结截止日期',
  C_FREEZENO  STRING  COMMENT  '冻结法律文书号',
  C_ORIREQUESTNO  STRING  COMMENT  '原申请编号',
  L_RATIONDATE  DECIMAL(4,0)  COMMENT  '定期日期',
  C_RATIONTERM  STRING  COMMENT  '定期定额周期',
  C_PROTOCOLNO  STRING  COMMENT  '协议号',
  D_PROTOCOLENDDATE  STRING  COMMENT  '协议截止日期',
  C_CHILDNETNO  STRING  COMMENT  '操作网点编号',
  C_CITYNO  STRING  COMMENT  '城市编号(地区)',
  C_TAFLAG  STRING  COMMENT  'TA发起标志',
  C_OUTBUSINFLAG  STRING  COMMENT  '外部业务标志',
  C_AUDITFLAG  STRING  COMMENT  '复核标志',
  F_CONFIRMBALANCE  DECIMAL(16,2)  COMMENT  '确认金额(累计)',
  F_CONFIRMSHARES  DECIMAL(16,2)  COMMENT  '确认份额(累计)',
  F_ORIAGIO  DECIMAL(5,4)  COMMENT  '原始费率折扣',
  F_ORIBACKFAREAGIO  DECIMAL(5,4)  COMMENT  '后收费折扣率',
  F_CONFIRMRATIO  DECIMAL(9,8)  COMMENT  '确认比例',
  C_OPERATOR  STRING  COMMENT  '操作员',
  F_PRICE  DECIMAL(16,8)  COMMENT  '设置成交价格',
  F_OTHERPRICE  DECIMAL(16,8)  COMMENT  '设置的对方价格',
  C_SPECIALCODE  STRING  COMMENT  '特殊代码',
  C_ACCEPTMODE  STRING  COMMENT  '交易方式',
  C_TRANSFERCAUSE  STRING  COMMENT  '过户原因',
  F_INCOME  DECIMAL(16,2)  COMMENT  '昨日基金收益',
  C_FUNDMETHOD  STRING  COMMENT  '资金方式',
  F_BACKFAREAGIO  DECIMAL(5,4)  COMMENT  '转换补差费折扣率',
  C_BANKNO  STRING  COMMENT  '银行编号',
  C_SUBFUNDMETHOD  STRING  COMMENT  '明细资金方式',
  C_COMBCODE  STRING  COMMENT  '组合编号',
  C_IMPROPERREDEEM  STRING  COMMENT  'C_IMPROPERREDEEM',
  F_PUNISHRATIO  DECIMAL(5,4)  COMMENT  'F_PUNISHRATIO',
  C_REQTRADEACCO  STRING  COMMENT  '申请交易账号',
  C_MAINTRDACCO  STRING  COMMENT  'C_MAINTRDACCO',
  C_NODEALFLAG  STRING  COMMENT  '不用处理标志',
  C_ORIFUNDCODE  STRING  COMMENT  '',
  C_ADJUSTCAUSE  STRING  COMMENT  '调整原因',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  C_SYSROLE  STRING  COMMENT  '系统角色',
  C_STATUS  STRING  COMMENT  '确认状态',
  C_IMPORTFLAG  STRING  COMMENT  '',
  C_SPLITFLAG  STRING  COMMENT  '',
  D_CDATE  STRING  COMMENT  '最后确认日期',
  D_DATE  STRING  COMMENT  '发放日期',
  C_RATIONVARIETY  STRING  COMMENT  '',
  C_RATIONSERIALNO  STRING  COMMENT  '',
  C_RATIONTYPE  STRING  COMMENT  '定期定额类型',
  D_PROTOCOLBEGINDATE  STRING  COMMENT  '',
  C_BROKER  STRING  COMMENT  '经纪人',
  C_RATIONPURPOSE  STRING  COMMENT  '',
  L_RATIONFREQUENCY  DECIMAL(5,0)  COMMENT  '',
  C_RATIONTIMEUNIT  STRING  COMMENT  '',
  F_RATIONNUM  DECIMAL(16,2)  COMMENT  '',
  C_TRADEMETHOD  STRING  COMMENT  '',
  C_SOLUTIONID  STRING  COMMENT  '计划代码',
  C_TACODE  STRING  COMMENT  'TA代码',
  D_FACTDATE  STRING  COMMENT  '',
  C_FORCEREDEMPTIONTYPE  STRING  COMMENT  '',
  C_SECONDACCO  STRING  COMMENT  '强增账户的二级账号',
  C_PARTNERID  STRING  COMMENT  '',
  F_ORIREQSHARES  DECIMAL(16,2)  COMMENT  '',
  C_OTHERSECONDACCO  STRING  COMMENT  '',
  F_TOTALBACKENDLOAD  DECIMAL(16,2)  COMMENT  '',
  F_TRADEFARE  DECIMAL(16,2)  COMMENT  '交易费',
  F_ONTHEWAYREQSHR  DECIMAL(16,2)  COMMENT  '',
  C_MEMO  STRING  COMMENT  '备注',
  F_DEFINEDRATIO  DECIMAL(9,8)  COMMENT  '',
  F_REQRDMBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_TODAYNODEALFLAG  STRING  COMMENT  '',
  C_T0BULLBEARFLAG  STRING  COMMENT  '',
  F_DEFINEDFEE  DECIMAL(16,2)  COMMENT  '',
  C_NEWCODE  STRING  COMMENT  '',
  D_CDATE1  STRING  COMMENT  '',
  C_MONEYTYPE  STRING  COMMENT  '',
  C_REQDATATYPE  STRING  COMMENT  '',
  C_CHAGETYPE  STRING  COMMENT  '',
  D_LASTDEDUCTDATE  STRING  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  F_TADEFINEDFEE  DECIMAL(16,2)  COMMENT  '',
  F_TARESTMGRINCOME  DECIMAL(16,2)  COMMENT  '',
  C_IMPAGENCYNO  STRING  COMMENT  '',
  F_T0FAILSHARES  DECIMAL(16,2)  COMMENT  '',
  C_TAKEINCOME  STRING  COMMENT  '',
  C_VIRTUALTACODE  STRING  COMMENT  '',
  C_BLACKLEVEL  STRING  COMMENT  '',
  C_IPADDRESS  STRING  COMMENT  '',
  C_MACADDRESS  STRING  COMMENT  '',
  C_IMEI  STRING  COMMENT  '',
  C_UUID  STRING  COMMENT  '',
  C_NAMEINBANK  STRING  COMMENT  '',
  C_BANKACCO  STRING  COMMENT  '',
  D_DEFINENAVDATE  STRING  COMMENT  '',
  C_ISTAFRMLAUNCH  STRING  COMMENT  '',
  D_DEFPURDATE  STRING  COMMENT  '',
  C_CHKMANUALCODE  STRING  COMMENT  '',
  C_SUBAGENCYNO  STRING  COMMENT  '',
  F_DEFINEBREAKRATIO  DECIMAL(9,8)  COMMENT  '',
  C_AUTOUNFRZ  STRING  COMMENT  '',
  C_RDMREASON  STRING  COMMENT  ''
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_BUSINFLAG
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , D_REQUESTDATE
                                   , D_REQUESTTIME
                                   , C_REQUESTNO
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , F_BALANCE
                                   , F_SHARES
                                   , C_OTHERCODE
                                   , C_OTHERSHARE
                                   , C_OTHERACCO
                                   , C_OTHERTRADEACCO
                                   , C_OTHERAGENCY
                                   , C_OTHERNETNO
                                   , D_ORIGINALDATE
                                   , C_ORICSERIALNO
                                   , D_REGISTDATE
                                   , C_EXCEEDFLAG
                                   , D_HOPEDATE
                                   , F_AGIO
                                   , C_BONUSTYPE
                                   , C_FREEZECAUSE
                                   , C_FREEZEENDDATE
                                   , C_FREEZENO
                                   , C_ORIREQUESTNO
                                   , L_RATIONDATE
                                   , C_RATIONTERM
                                   , C_PROTOCOLNO
                                   , D_PROTOCOLENDDATE
                                   , C_CHILDNETNO
                                   , C_CITYNO
                                   , C_TAFLAG
                                   , C_OUTBUSINFLAG
                                   , C_AUDITFLAG
                                   , F_CONFIRMBALANCE
                                   , F_CONFIRMSHARES
                                   , F_ORIAGIO
                                   , F_ORIBACKFAREAGIO
                                   , F_CONFIRMRATIO
                                   , C_OPERATOR
                                   , F_PRICE
                                   , F_OTHERPRICE
                                   , C_SPECIALCODE
                                   , C_ACCEPTMODE
                                   , C_TRANSFERCAUSE
                                   , F_INCOME
                                   , C_FUNDMETHOD
                                   , F_BACKFAREAGIO
                                   , C_BANKNO
                                   , C_SUBFUNDMETHOD
                                   , C_COMBCODE
                                   , C_IMPROPERREDEEM
                                   , F_PUNISHRATIO
                                   , C_REQTRADEACCO
                                   , C_MAINTRDACCO
                                   , C_NODEALFLAG
                                   , C_ORIFUNDCODE
                                   , C_ADJUSTCAUSE
                                   , C_CSERIALNO
                                   , C_SYSROLE
                                   , C_STATUS
                                   , C_IMPORTFLAG
                                   , C_SPLITFLAG
                                   , D_CDATE
                                   , D_DATE
                                   , C_RATIONVARIETY
                                   , C_RATIONSERIALNO
                                   , C_RATIONTYPE
                                   , D_PROTOCOLBEGINDATE
                                   , C_BROKER
                                   , C_RATIONPURPOSE
                                   , L_RATIONFREQUENCY
                                   , C_RATIONTIMEUNIT
                                   , F_RATIONNUM
                                   , C_TRADEMETHOD
                                   , C_SOLUTIONID
                                   , C_TACODE
                                   , D_FACTDATE
                                   , C_FORCEREDEMPTIONTYPE
                                   , C_SECONDACCO
                                   , C_PARTNERID
                                   , F_ORIREQSHARES
                                   , C_OTHERSECONDACCO
                                   , F_TOTALBACKENDLOAD
                                   , F_TRADEFARE
                                   , F_ONTHEWAYREQSHR
                                   , C_MEMO
                                   , F_DEFINEDRATIO
                                   , F_REQRDMBALANCE
                                   , C_TODAYNODEALFLAG
                                   , C_T0BULLBEARFLAG
                                   , F_DEFINEDFEE
                                   , C_NEWCODE
                                   , D_CDATE1
                                   , C_MONEYTYPE
                                   , C_REQDATATYPE
                                   , C_CHAGETYPE
                                   , D_LASTDEDUCTDATE
                                   , C_SUBFUNDCODE
                                   , F_TADEFINEDFEE
                                   , F_TARESTMGRINCOME
                                   , C_IMPAGENCYNO
                                   , F_T0FAILSHARES
                                   , C_TAKEINCOME
                                   , C_VIRTUALTACODE
                                   , C_BLACKLEVEL
                                   , C_IPADDRESS
                                   , C_MACADDRESS
                                   , C_IMEI
                                   , C_UUID
                                   , C_NAMEINBANK
                                   , C_BANKACCO
                                   , D_DEFINENAVDATE
                                   , C_ISTAFRMLAUNCH
                                   , D_DEFPURDATE
                                   , C_CHKMANUALCODE
                                   , C_SUBAGENCYNO
                                   , F_DEFINEBREAKRATIO
                                   , C_AUTOUNFRZ
                                   , C_RDMREASON
                                FROM ${hszta_src_schema}.TREQUEST
                                WHERE D_REQUESTDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "D_REQUESTDATE", "type": "STRING"}, {"name": "D_REQUESTTIME", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "F_BALANCE", "type": "DOUBLE"}, {"name": "F_SHARES", "type": "DOUBLE"}, {"name": "C_OTHERCODE", "type": "STRING"}, {"name": "C_OTHERSHARE", "type": "STRING"}, {"name": "C_OTHERACCO", "type": "STRING"}, {"name": "C_OTHERTRADEACCO", "type": "STRING"}, {"name": "C_OTHERAGENCY", "type": "STRING"}, {"name": "C_OTHERNETNO", "type": "STRING"}, {"name": "D_ORIGINALDATE", "type": "STRING"}, {"name": "C_ORICSERIALNO", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "C_EXCEEDFLAG", "type": "STRING"}, {"name": "D_HOPEDATE", "type": "STRING"}, {"name": "F_AGIO", "type": "DOUBLE"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "C_FREEZEENDDATE", "type": "STRING"}, {"name": "C_FREEZENO", "type": "STRING"}, {"name": "C_ORIREQUESTNO", "type": "STRING"}, {"name": "L_RATIONDATE", "type": "DOUBLE"}, {"name": "C_RATIONTERM", "type": "STRING"}, {"name": "C_PROTOCOLNO", "type": "STRING"}, {"name": "D_PROTOCOLENDDATE", "type": "STRING"}, {"name": "C_CHILDNETNO", "type": "STRING"}, {"name": "C_CITYNO", "type": "STRING"}, {"name": "C_TAFLAG", "type": "STRING"}, {"name": "C_OUTBUSINFLAG", "type": "STRING"}, {"name": "C_AUDITFLAG", "type": "STRING"}, {"name": "F_CONFIRMBALANCE", "type": "DOUBLE"}, {"name": "F_CONFIRMSHARES", "type": "DOUBLE"}, {"name": "F_ORIAGIO", "type": "DOUBLE"}, {"name": "F_ORIBACKFAREAGIO", "type": "DOUBLE"}, {"name": "F_CONFIRMRATIO", "type": "DOUBLE"}, {"name": "C_OPERATOR", "type": "STRING"}, {"name": "F_PRICE", "type": "DOUBLE"}, {"name": "F_OTHERPRICE", "type": "DOUBLE"}, {"name": "C_SPECIALCODE", "type": "STRING"}, {"name": "C_ACCEPTMODE", "type": "STRING"}, {"name": "C_TRANSFERCAUSE", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "C_FUNDMETHOD", "type": "STRING"}, {"name": "F_BACKFAREAGIO", "type": "DOUBLE"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_SUBFUNDMETHOD", "type": "STRING"}, {"name": "C_COMBCODE", "type": "STRING"}, {"name": "C_IMPROPERREDEEM", "type": "STRING"}, {"name": "F_PUNISHRATIO", "type": "DOUBLE"}, {"name": "C_REQTRADEACCO", "type": "STRING"}, {"name": "C_MAINTRDACCO", "type": "STRING"}, {"name": "C_NODEALFLAG", "type": "STRING"}, {"name": "C_ORIFUNDCODE", "type": "STRING"}, {"name": "C_ADJUSTCAUSE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_SYSROLE", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "C_IMPORTFLAG", "type": "STRING"}, {"name": "C_SPLITFLAG", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "C_RATIONVARIETY", "type": "STRING"}, {"name": "C_RATIONSERIALNO", "type": "STRING"}, {"name": "C_RATIONTYPE", "type": "STRING"}, {"name": "D_PROTOCOLBEGINDATE", "type": "STRING"}, {"name": "C_BROKER", "type": "STRING"}, {"name": "C_RATIONPURPOSE", "type": "STRING"}, {"name": "L_RATIONFREQUENCY", "type": "DOUBLE"}, {"name": "C_RATIONTIMEUNIT", "type": "STRING"}, {"name": "F_RATIONNUM", "type": "DOUBLE"}, {"name": "C_TRADEMETHOD", "type": "STRING"}, {"name": "C_SOLUTIONID", "type": "STRING"}, {"name": "C_TACODE", "type": "STRING"}, {"name": "D_FACTDATE", "type": "STRING"}, {"name": "C_FORCEREDEMPTIONTYPE", "type": "STRING"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "F_ORIREQSHARES", "type": "DOUBLE"}, {"name": "C_OTHERSECONDACCO", "type": "STRING"}, {"name": "F_TOTALBACKENDLOAD", "type": "DOUBLE"}, {"name": "F_TRADEFARE", "type": "DOUBLE"}, {"name": "F_ONTHEWAYREQSHR", "type": "DOUBLE"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "F_DEFINEDRATIO", "type": "DOUBLE"}, {"name": "F_REQRDMBALANCE", "type": "DOUBLE"}, {"name": "C_TODAYNODEALFLAG", "type": "STRING"}, {"name": "C_T0BULLBEARFLAG", "type": "STRING"}, {"name": "F_DEFINEDFEE", "type": "DOUBLE"}, {"name": "C_NEWCODE", "type": "STRING"}, {"name": "D_CDATE1", "type": "STRING"}, {"name": "C_MONEYTYPE", "type": "STRING"}, {"name": "C_REQDATATYPE", "type": "STRING"}, {"name": "C_CHAGETYPE", "type": "STRING"}, {"name": "D_LASTDEDUCTDATE", "type": "STRING"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "F_TADEFINEDFEE", "type": "DOUBLE"}, {"name": "F_TARESTMGRINCOME", "type": "DOUBLE"}, {"name": "C_IMPAGENCYNO", "type": "STRING"}, {"name": "F_T0FAILSHARES", "type": "DOUBLE"}, {"name": "C_TAKEINCOME", "type": "STRING"}, {"name": "C_VIRTUALTACODE", "type": "STRING"}, {"name": "C_BLACKLEVEL", "type": "STRING"}, {"name": "C_IPADDRESS", "type": "STRING"}, {"name": "C_MACADDRESS", "type": "STRING"}, {"name": "C_IMEI", "type": "STRING"}, {"name": "C_UUID", "type": "STRING"}, {"name": "C_NAMEINBANK", "type": "STRING"}, {"name": "C_BANKACCO", "type": "STRING"}, {"name": "D_DEFINENAVDATE", "type": "STRING"}, {"name": "C_ISTAFRMLAUNCH", "type": "STRING"}, {"name": "D_DEFPURDATE", "type": "STRING"}, {"name": "C_CHKMANUALCODE", "type": "STRING"}, {"name": "C_SUBAGENCYNO", "type": "STRING"}, {"name": "F_DEFINEBREAKRATIO", "type": "DOUBLE"}, {"name": "C_AUTOUNFRZ", "type": "STRING"}, {"name": "C_RDMREASON", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_trequest_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_trequest_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_trequest_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_trequest_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TREQUEST_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TREQUEST_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_trequest_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TREQUEST_PTD PARTITION(P_DT)
SELECT
       C_BUSINFLAG
     , C_AGENCYNO
     , C_NETNO
     , D_REQUESTDATE
     , D_REQUESTTIME
     , C_REQUESTNO
     , C_FUNDACCO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , F_BALANCE
     , F_SHARES
     , C_OTHERCODE
     , C_OTHERSHARE
     , C_OTHERACCO
     , C_OTHERTRADEACCO
     , C_OTHERAGENCY
     , C_OTHERNETNO
     , D_ORIGINALDATE
     , C_ORICSERIALNO
     , D_REGISTDATE
     , C_EXCEEDFLAG
     , D_HOPEDATE
     , F_AGIO
     , C_BONUSTYPE
     , C_FREEZECAUSE
     , C_FREEZEENDDATE
     , C_FREEZENO
     , C_ORIREQUESTNO
     , L_RATIONDATE
     , C_RATIONTERM
     , C_PROTOCOLNO
     , D_PROTOCOLENDDATE
     , C_CHILDNETNO
     , C_CITYNO
     , C_TAFLAG
     , C_OUTBUSINFLAG
     , C_AUDITFLAG
     , F_CONFIRMBALANCE
     , F_CONFIRMSHARES
     , F_ORIAGIO
     , F_ORIBACKFAREAGIO
     , F_CONFIRMRATIO
     , C_OPERATOR
     , F_PRICE
     , F_OTHERPRICE
     , C_SPECIALCODE
     , C_ACCEPTMODE
     , C_TRANSFERCAUSE
     , F_INCOME
     , C_FUNDMETHOD
     , F_BACKFAREAGIO
     , C_BANKNO
     , C_SUBFUNDMETHOD
     , C_COMBCODE
     , C_IMPROPERREDEEM
     , F_PUNISHRATIO
     , C_REQTRADEACCO
     , C_MAINTRDACCO
     , C_NODEALFLAG
     , C_ORIFUNDCODE
     , C_ADJUSTCAUSE
     , C_CSERIALNO
     , C_SYSROLE
     , C_STATUS
     , C_IMPORTFLAG
     , C_SPLITFLAG
     , D_CDATE
     , D_DATE
     , C_RATIONVARIETY
     , C_RATIONSERIALNO
     , C_RATIONTYPE
     , D_PROTOCOLBEGINDATE
     , C_BROKER
     , C_RATIONPURPOSE
     , L_RATIONFREQUENCY
     , C_RATIONTIMEUNIT
     , F_RATIONNUM
     , C_TRADEMETHOD
     , C_SOLUTIONID
     , C_TACODE
     , D_FACTDATE
     , C_FORCEREDEMPTIONTYPE
     , C_SECONDACCO
     , C_PARTNERID
     , F_ORIREQSHARES
     , C_OTHERSECONDACCO
     , F_TOTALBACKENDLOAD
     , F_TRADEFARE
     , F_ONTHEWAYREQSHR
     , C_MEMO
     , F_DEFINEDRATIO
     , F_REQRDMBALANCE
     , C_TODAYNODEALFLAG
     , C_T0BULLBEARFLAG
     , F_DEFINEDFEE
     , C_NEWCODE
     , D_CDATE1
     , C_MONEYTYPE
     , C_REQDATATYPE
     , C_CHAGETYPE
     , D_LASTDEDUCTDATE
     , C_SUBFUNDCODE
     , F_TADEFINEDFEE
     , F_TARESTMGRINCOME
     , C_IMPAGENCYNO
     , F_T0FAILSHARES
     , C_TAKEINCOME
     , C_VIRTUALTACODE
     , C_BLACKLEVEL
     , C_IPADDRESS
     , C_MACADDRESS
     , C_IMEI
     , C_UUID
     , C_NAMEINBANK
     , C_BANKACCO
     , D_DEFINENAVDATE
     , C_ISTAFRMLAUNCH
     , D_DEFPURDATE
     , C_CHKMANUALCODE
     , C_SUBAGENCYNO
     , F_DEFINEBREAKRATIO
     , C_AUTOUNFRZ
     , C_RDMREASON
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_REQUESTDATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TREQUEST_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TREQUEST_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TREQUEST_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TREQUEST_PTD成功"
      exit 0
   fi
fi
