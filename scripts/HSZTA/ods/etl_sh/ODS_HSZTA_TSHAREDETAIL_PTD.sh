#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TSHAREDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHAREDETAIL_PTD_TMP(
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  D_CDATE  STRING  COMMENT  '确认日期',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  C_SOURCETYPE  STRING  COMMENT  '份额来源',
  F_REMAINSHARES  DECIMAL(16,2)  COMMENT  '本笔剩余份额',
  D_REGISTDATE  STRING  COMMENT  '份额注册日期',
  F_ORIBALANCE  DECIMAL(16,2)  COMMENT  '原确认金额',
  F_ORISHARES  DECIMAL(16,2)  COMMENT  '原确认份额',
  F_ORINETVALUE  DECIMAL(16,8)  COMMENT  '原单位净值',
  C_ORISOURCE  STRING  COMMENT  '份额原始来源',
  F_BACKFARERATIO  DECIMAL(5,4)  COMMENT  '后收费原费率',
  F_RULEAGIO  DECIMAL(5,4)  COMMENT  '符合规则的折扣',
  F_ORIAGIO  DECIMAL(5,4)  COMMENT  '原始费率折扣',
  F_MAXALLOTRATIO  DECIMAL(5,4)  COMMENT  '历史最高申购费率',
  F_MINREDEEMRATIO  DECIMAL(5,4)  COMMENT  '历史最低赎回费率',
  F_MINBACKRATIO  DECIMAL(5,4)  COMMENT  '历史最低后收费率',
  C_HOLDFLAG  STRING  COMMENT  '持有限制标志',
  C_ACCEPTMODE  STRING  COMMENT  '交易方式',
  C_SPECIALCODE  STRING  COMMENT  '特殊代码',
  C_FIRSTCSERIALNO  STRING  COMMENT  '首次确认编号',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_FUNDMETHOD  STRING  COMMENT  '资金方式',
  C_BANKNO  STRING  COMMENT  '银行编号',
  C_SUBFUNDMETHOD  STRING  COMMENT  '明细资金方式',
  C_SPECIALTIES  STRING  COMMENT  '份额特殊标志',
  F_APPORTIONRATIO  DECIMAL(9,8)  COMMENT  '后收费垫付费率',
  F_FARERATIO  DECIMAL(5,4)  COMMENT  '营业性费率',
  F_MANAGEFARE  DECIMAL(16,2)  COMMENT  '账户管理费金额',
  F_INTERESTSHARE  DECIMAL(16,2)  COMMENT  '利息转份额',
  F_BACKFARE  DECIMAL(16,2)  COMMENT  '后收手续费',
  D_LASTDEDUCTDATE  STRING  COMMENT  '',
  F_INCOME  DECIMAL(16,2)  COMMENT  '昨日基金收益',
  F_NEWINCOME  DECIMAL(16,2)  COMMENT  '当天新增未付收益',
  D_CYCLESTARTDATE  STRING  COMMENT  '本循环开始日期',
  D_CYCLEENDDATE  STRING  COMMENT  '本循环结束日期',
  L_CYCLE  DECIMAL(10,0)  COMMENT  '',
  D_CYCLENEXTDATE  STRING  COMMENT  '循环下一个开始日期',
  C_PRODUCTCYCLE  STRING  COMMENT  '',
  F_ALREADYMAKESHARES  DECIMAL(16,2)  COMMENT  '',
  F_CSERVICEFARE  DECIMAL(16,2)  COMMENT  '',
  C_SECONDACCO  STRING  COMMENT  '强增账户的二级账号',
  F_EVENNETVALUE  DECIMAL(17,9)  COMMENT  '保本单位净值',
  C_PROTECTFLAG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  C_PROMISENO  STRING  COMMENT  '承诺优惠协议号',
  F_CYCLEINCOME  DECIMAL(16,2)  COMMENT  '',
  D_LASTBONUSDATE  STRING  COMMENT  '',
  D_ORI02REQDATE  STRING  COMMENT  '',
  C_PROMISESHARESFLAG  STRING  COMMENT  '',
  C_LASTOUTFUNDCODE  STRING  COMMENT  '',
  F_CALINCOME  DECIMAL(16,6)  COMMENT  '',
  F_FUNDENDSHARE  DECIMAL(16,2)  COMMENT  '',
  F_TOTALUNITBONUS  DECIMAL(20,12)  COMMENT  '',
  F_COSTPRICE  DECIMAL(20,12)  COMMENT  '',
  F_COSTFARE  DECIMAL(16,2)  COMMENT  '原税费',
  F_DEDUCTEDBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_FIXEDFAREFLAG  STRING  COMMENT  '',
  F_LASTDEDUCTNETVALUE  DECIMAL(16,8)  COMMENT  '',
  F_NEWNETVALUE  DECIMAL(16,8)  COMMENT  '',
  F_LASTDEDUCTASSET  DECIMAL(16,2)  COMMENT  '',
  F_NEWASSET  DECIMAL(16,2)  COMMENT  '',
  D_FIRSTINVESTDATE  STRING  COMMENT  '',
  D_LASTPROTECTDATE  STRING  COMMENT  '',
  F_REDEEMEDBASESHR  DECIMAL(16,2)  COMMENT  '',
  C_LIMITCIRCLEBEGINDATE  STRING  COMMENT  '',
  C_LIMITRDMOPENDATE  STRING  COMMENT  '',
  F_SUBBALANCE  DECIMAL(16,2)  COMMENT  '',
  D_LASTCHARGEMGRFAREDATE  STRING  COMMENT  '',
  F_INCOMEBAK  DECIMAL(16,2)  COMMENT  '',
  F_NEWINCOMEBAK  DECIMAL(16,2)  COMMENT  '',
  F_BUDGETNEWNETVALUE  DECIMAL(16,8)  COMMENT  '',
  F_BUDGETNEWASSET  DECIMAL(16,2)  COMMENT  '',
  F_LASTOPENDAYASSET  DECIMAL(16,2)  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  F_LOCKSHARES  DECIMAL(16,2)  COMMENT  '',
  F_TOTALINCOME  DECIMAL(16,2)  COMMENT  '',
  D_ORI02CFMDATE  STRING  COMMENT  '',
  F_PROFITLEVELVALUE  DECIMAL(16,8)  COMMENT  '',
  D_LASTPROFITDATE  STRING  COMMENT  '',
  F_LASTDECUCTYRATIO  DECIMAL(11,8)  COMMENT  '',
  F_COSTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_NEWMANAGEFARE  DECIMAL(16,2)  COMMENT  '',
  D_LASTPFTRDMDATE  STRING  COMMENT  '',
  D_CYCLENEXTDATE2  STRING  COMMENT  '',
  D_REGULARNEXTDATE  STRING  COMMENT  '',
  D_FACTLASTDEDUCTDATE  STRING  COMMENT  '',
  D_CYCLEFIRSTENDDATE  STRING  COMMENT  '',
  L_ALLOWRDMDAYS  DECIMAL(3,0)  COMMENT  '',
  C_REQUESTNO  STRING  COMMENT  '',
  F_FAMGRFEE  DECIMAL(16,2)  COMMENT  '',
  F_SVRRETFARE  DECIMAL(16,2)  COMMENT  '',
  F_NEWSVRRETFARE  DECIMAL(16,2)  COMMENT  '',
  F_EVENBALANCE  DECIMAL(16,2)  COMMENT  '',
  D_LASTFLOATMNGFEE  STRING  COMMENT  '',
  D_YIELDOVERDATE  STRING  COMMENT  '',
  C_ICDATA  STRING  COMMENT  '',
  D_FROZENENDDATE  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '',
  D_GFUNDENDDATE  STRING  COMMENT  '',
  D_GFUNDNEXTDATE  STRING  COMMENT  ''
)
COMMENT '份额明细表'
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
              "querySql": ["SELECT  C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , D_CDATE
                                   , C_CSERIALNO
                                   , C_SOURCETYPE
                                   , F_REMAINSHARES
                                   , D_REGISTDATE
                                   , F_ORIBALANCE
                                   , F_ORISHARES
                                   , F_ORINETVALUE
                                   , C_ORISOURCE
                                   , F_BACKFARERATIO
                                   , F_RULEAGIO
                                   , F_ORIAGIO
                                   , F_MAXALLOTRATIO
                                   , F_MINREDEEMRATIO
                                   , F_MINBACKRATIO
                                   , C_HOLDFLAG
                                   , C_ACCEPTMODE
                                   , C_SPECIALCODE
                                   , C_FIRSTCSERIALNO
                                   , C_BOURSEFLAG
                                   , C_FUNDMETHOD
                                   , C_BANKNO
                                   , C_SUBFUNDMETHOD
                                   , C_SPECIALTIES
                                   , F_APPORTIONRATIO
                                   , F_FARERATIO
                                   , F_MANAGEFARE
                                   , F_INTERESTSHARE
                                   , F_BACKFARE
                                   , D_LASTDEDUCTDATE
                                   , F_INCOME
                                   , F_NEWINCOME
                                   , D_CYCLESTARTDATE
                                   , D_CYCLEENDDATE
                                   , L_CYCLE
                                   , D_CYCLENEXTDATE
                                   , C_PRODUCTCYCLE
                                   , F_ALREADYMAKESHARES
                                   , F_CSERVICEFARE
                                   , C_SECONDACCO
                                   , F_EVENNETVALUE
                                   , C_PROTECTFLAG
                                   , C_PARTNERID
                                   , C_PROMISENO
                                   , F_CYCLEINCOME
                                   , D_LASTBONUSDATE
                                   , D_ORI02REQDATE
                                   , C_PROMISESHARESFLAG
                                   , C_LASTOUTFUNDCODE
                                   , F_CALINCOME
                                   , F_FUNDENDSHARE
                                   , F_TOTALUNITBONUS
                                   , F_COSTPRICE
                                   , F_COSTFARE
                                   , F_DEDUCTEDBALANCE
                                   , C_FIXEDFAREFLAG
                                   , F_LASTDEDUCTNETVALUE
                                   , F_NEWNETVALUE
                                   , F_LASTDEDUCTASSET
                                   , F_NEWASSET
                                   , D_FIRSTINVESTDATE
                                   , D_LASTPROTECTDATE
                                   , F_REDEEMEDBASESHR
                                   , C_LIMITCIRCLEBEGINDATE
                                   , C_LIMITRDMOPENDATE
                                   , F_SUBBALANCE
                                   , D_LASTCHARGEMGRFAREDATE
                                   , F_INCOMEBAK
                                   , F_NEWINCOMEBAK
                                   , F_BUDGETNEWNETVALUE
                                   , F_BUDGETNEWASSET
                                   , F_LASTOPENDAYASSET
                                   , C_SUBFUNDCODE
                                   , F_LOCKSHARES
                                   , F_TOTALINCOME
                                   , D_ORI02CFMDATE
                                   , F_PROFITLEVELVALUE
                                   , D_LASTPROFITDATE
                                   , F_LASTDECUCTYRATIO
                                   , F_COSTBALANCE
                                   , F_NEWMANAGEFARE
                                   , D_LASTPFTRDMDATE
                                   , D_CYCLENEXTDATE2
                                   , D_REGULARNEXTDATE
                                   , D_FACTLASTDEDUCTDATE
                                   , D_CYCLEFIRSTENDDATE
                                   , L_ALLOWRDMDAYS
                                   , C_REQUESTNO
                                   , F_FAMGRFEE
                                   , F_SVRRETFARE
                                   , F_NEWSVRRETFARE
                                   , F_EVENBALANCE
                                   , D_LASTFLOATMNGFEE
                                   , D_YIELDOVERDATE
                                   , C_ICDATA
                                   , D_FROZENENDDATE
                                   , C_MEMO
                                   , D_GFUNDENDDATE
                                   , D_GFUNDNEXTDATE
                                FROM ${hszta_src_schema}.TSHAREDETAIL
                                WHERE D_CDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_SOURCETYPE", "type": "STRING"}, {"name": "F_REMAINSHARES", "type": "DOUBLE"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "F_ORIBALANCE", "type": "DOUBLE"}, {"name": "F_ORISHARES", "type": "DOUBLE"}, {"name": "F_ORINETVALUE", "type": "DOUBLE"}, {"name": "C_ORISOURCE", "type": "STRING"}, {"name": "F_BACKFARERATIO", "type": "DOUBLE"}, {"name": "F_RULEAGIO", "type": "DOUBLE"}, {"name": "F_ORIAGIO", "type": "DOUBLE"}, {"name": "F_MAXALLOTRATIO", "type": "DOUBLE"}, {"name": "F_MINREDEEMRATIO", "type": "DOUBLE"}, {"name": "F_MINBACKRATIO", "type": "DOUBLE"}, {"name": "C_HOLDFLAG", "type": "STRING"}, {"name": "C_ACCEPTMODE", "type": "STRING"}, {"name": "C_SPECIALCODE", "type": "STRING"}, {"name": "C_FIRSTCSERIALNO", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_FUNDMETHOD", "type": "STRING"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_SUBFUNDMETHOD", "type": "STRING"}, {"name": "C_SPECIALTIES", "type": "STRING"}, {"name": "F_APPORTIONRATIO", "type": "DOUBLE"}, {"name": "F_FARERATIO", "type": "DOUBLE"}, {"name": "F_MANAGEFARE", "type": "DOUBLE"}, {"name": "F_INTERESTSHARE", "type": "DOUBLE"}, {"name": "F_BACKFARE", "type": "DOUBLE"}, {"name": "D_LASTDEDUCTDATE", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_NEWINCOME", "type": "DOUBLE"}, {"name": "D_CYCLESTARTDATE", "type": "STRING"}, {"name": "D_CYCLEENDDATE", "type": "STRING"}, {"name": "L_CYCLE", "type": "DOUBLE"}, {"name": "D_CYCLENEXTDATE", "type": "STRING"}, {"name": "C_PRODUCTCYCLE", "type": "STRING"}, {"name": "F_ALREADYMAKESHARES", "type": "DOUBLE"}, {"name": "F_CSERVICEFARE", "type": "DOUBLE"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "F_EVENNETVALUE", "type": "DOUBLE"}, {"name": "C_PROTECTFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_PROMISENO", "type": "STRING"}, {"name": "F_CYCLEINCOME", "type": "DOUBLE"}, {"name": "D_LASTBONUSDATE", "type": "STRING"}, {"name": "D_ORI02REQDATE", "type": "STRING"}, {"name": "C_PROMISESHARESFLAG", "type": "STRING"}, {"name": "C_LASTOUTFUNDCODE", "type": "STRING"}, {"name": "F_CALINCOME", "type": "DOUBLE"}, {"name": "F_FUNDENDSHARE", "type": "DOUBLE"}, {"name": "F_TOTALUNITBONUS", "type": "DOUBLE"}, {"name": "F_COSTPRICE", "type": "DOUBLE"}, {"name": "F_COSTFARE", "type": "DOUBLE"}, {"name": "F_DEDUCTEDBALANCE", "type": "DOUBLE"}, {"name": "C_FIXEDFAREFLAG", "type": "STRING"}, {"name": "F_LASTDEDUCTNETVALUE", "type": "DOUBLE"}, {"name": "F_NEWNETVALUE", "type": "DOUBLE"}, {"name": "F_LASTDEDUCTASSET", "type": "DOUBLE"}, {"name": "F_NEWASSET", "type": "DOUBLE"}, {"name": "D_FIRSTINVESTDATE", "type": "STRING"}, {"name": "D_LASTPROTECTDATE", "type": "STRING"}, {"name": "F_REDEEMEDBASESHR", "type": "DOUBLE"}, {"name": "C_LIMITCIRCLEBEGINDATE", "type": "STRING"}, {"name": "C_LIMITRDMOPENDATE", "type": "STRING"}, {"name": "F_SUBBALANCE", "type": "DOUBLE"}, {"name": "D_LASTCHARGEMGRFAREDATE", "type": "STRING"}, {"name": "F_INCOMEBAK", "type": "DOUBLE"}, {"name": "F_NEWINCOMEBAK", "type": "DOUBLE"}, {"name": "F_BUDGETNEWNETVALUE", "type": "DOUBLE"}, {"name": "F_BUDGETNEWASSET", "type": "DOUBLE"}, {"name": "F_LASTOPENDAYASSET", "type": "DOUBLE"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "F_LOCKSHARES", "type": "DOUBLE"}, {"name": "F_TOTALINCOME", "type": "DOUBLE"}, {"name": "D_ORI02CFMDATE", "type": "STRING"}, {"name": "F_PROFITLEVELVALUE", "type": "DOUBLE"}, {"name": "D_LASTPROFITDATE", "type": "STRING"}, {"name": "F_LASTDECUCTYRATIO", "type": "DOUBLE"}, {"name": "F_COSTBALANCE", "type": "DOUBLE"}, {"name": "F_NEWMANAGEFARE", "type": "DOUBLE"}, {"name": "D_LASTPFTRDMDATE", "type": "STRING"}, {"name": "D_CYCLENEXTDATE2", "type": "STRING"}, {"name": "D_REGULARNEXTDATE", "type": "STRING"}, {"name": "D_FACTLASTDEDUCTDATE", "type": "STRING"}, {"name": "D_CYCLEFIRSTENDDATE", "type": "STRING"}, {"name": "L_ALLOWRDMDAYS", "type": "DOUBLE"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "F_FAMGRFEE", "type": "DOUBLE"}, {"name": "F_SVRRETFARE", "type": "DOUBLE"}, {"name": "F_NEWSVRRETFARE", "type": "DOUBLE"}, {"name": "F_EVENBALANCE", "type": "DOUBLE"}, {"name": "D_LASTFLOATMNGFEE", "type": "STRING"}, {"name": "D_YIELDOVERDATE", "type": "STRING"}, {"name": "C_ICDATA", "type": "STRING"}, {"name": "D_FROZENENDDATE", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "D_GFUNDENDDATE", "type": "STRING"}, {"name": "D_GFUNDNEXTDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tsharedetail_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tsharedetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tsharedetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tsharedetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TSHAREDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TSHAREDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tsharedetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHAREDETAIL_PTD PARTITION(P_DT)
SELECT
       C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , D_CDATE
     , C_CSERIALNO
     , C_SOURCETYPE
     , F_REMAINSHARES
     , D_REGISTDATE
     , F_ORIBALANCE
     , F_ORISHARES
     , F_ORINETVALUE
     , C_ORISOURCE
     , F_BACKFARERATIO
     , F_RULEAGIO
     , F_ORIAGIO
     , F_MAXALLOTRATIO
     , F_MINREDEEMRATIO
     , F_MINBACKRATIO
     , C_HOLDFLAG
     , C_ACCEPTMODE
     , C_SPECIALCODE
     , C_FIRSTCSERIALNO
     , C_BOURSEFLAG
     , C_FUNDMETHOD
     , C_BANKNO
     , C_SUBFUNDMETHOD
     , C_SPECIALTIES
     , F_APPORTIONRATIO
     , F_FARERATIO
     , F_MANAGEFARE
     , F_INTERESTSHARE
     , F_BACKFARE
     , D_LASTDEDUCTDATE
     , F_INCOME
     , F_NEWINCOME
     , D_CYCLESTARTDATE
     , D_CYCLEENDDATE
     , L_CYCLE
     , D_CYCLENEXTDATE
     , C_PRODUCTCYCLE
     , F_ALREADYMAKESHARES
     , F_CSERVICEFARE
     , C_SECONDACCO
     , F_EVENNETVALUE
     , C_PROTECTFLAG
     , C_PARTNERID
     , C_PROMISENO
     , F_CYCLEINCOME
     , D_LASTBONUSDATE
     , D_ORI02REQDATE
     , C_PROMISESHARESFLAG
     , C_LASTOUTFUNDCODE
     , F_CALINCOME
     , F_FUNDENDSHARE
     , F_TOTALUNITBONUS
     , F_COSTPRICE
     , F_COSTFARE
     , F_DEDUCTEDBALANCE
     , C_FIXEDFAREFLAG
     , F_LASTDEDUCTNETVALUE
     , F_NEWNETVALUE
     , F_LASTDEDUCTASSET
     , F_NEWASSET
     , D_FIRSTINVESTDATE
     , D_LASTPROTECTDATE
     , F_REDEEMEDBASESHR
     , C_LIMITCIRCLEBEGINDATE
     , C_LIMITRDMOPENDATE
     , F_SUBBALANCE
     , D_LASTCHARGEMGRFAREDATE
     , F_INCOMEBAK
     , F_NEWINCOMEBAK
     , F_BUDGETNEWNETVALUE
     , F_BUDGETNEWASSET
     , F_LASTOPENDAYASSET
     , C_SUBFUNDCODE
     , F_LOCKSHARES
     , F_TOTALINCOME
     , D_ORI02CFMDATE
     , F_PROFITLEVELVALUE
     , D_LASTPROFITDATE
     , F_LASTDECUCTYRATIO
     , F_COSTBALANCE
     , F_NEWMANAGEFARE
     , D_LASTPFTRDMDATE
     , D_CYCLENEXTDATE2
     , D_REGULARNEXTDATE
     , D_FACTLASTDEDUCTDATE
     , D_CYCLEFIRSTENDDATE
     , L_ALLOWRDMDAYS
     , C_REQUESTNO
     , F_FAMGRFEE
     , F_SVRRETFARE
     , F_NEWSVRRETFARE
     , F_EVENBALANCE
     , D_LASTFLOATMNGFEE
     , D_YIELDOVERDATE
     , C_ICDATA
     , D_FROZENENDDATE
     , C_MEMO
     , D_GFUNDENDDATE
     , D_GFUNDNEXTDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_CDATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TSHAREDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHAREDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TSHAREDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TSHAREDETAIL_PTD成功"
      exit 0
   fi
fi
