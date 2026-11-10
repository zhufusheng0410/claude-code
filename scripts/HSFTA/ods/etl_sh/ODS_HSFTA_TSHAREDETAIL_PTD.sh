#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TSHAREDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSHAREDETAIL_PTD_TMP(
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  D_CDATE  STRING  COMMENT  '确认日期',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  C_SOURCETYPE  STRING  COMMENT  '份额来源',
  F_REMAINSHARES  DECIMAL(16,2)  COMMENT  '本笔剩余份额',
  D_REGISTDATE  STRING  COMMENT  '份额注册日期',
  F_ORIBALANCE  DECIMAL(16,2)  COMMENT  '原确认金额',
  F_ORISHARES  DECIMAL(16,2)  COMMENT  '原确认份额',
  F_COSTFARE  DECIMAL(16,2)  COMMENT  '原税费',
  F_ORINETVALUE  DECIMAL(16,8)  COMMENT  '原单位净值',
  F_GAINBALANCE  DECIMAL(16,2)  COMMENT  '浮动盈亏',
  C_PROMISENO  STRING  COMMENT  '承诺优惠协议号',
  F_CSHAREFARE  DECIMAL(16,2)  COMMENT  'C类的手续费',
  D_LASTMODIFY  STRING  COMMENT  '最后修改日期',
  C_ORIAGENCY  STRING  COMMENT  '原销售机构',
  C_BONUSFLAG  STRING  COMMENT  '分红来源标志',
  C_ORISOURCE  STRING  COMMENT  '份额原始来源',
  F_BACKFARERATIO  DECIMAL(5,4)  COMMENT  '后收费原费率',
  F_RULEAGIO  DECIMAL(5,4)  COMMENT  '符合规则的折扣',
  F_ORIAGIO  DECIMAL(5,4)  COMMENT  '原始费率折扣',
  F_MAXALLOTRATIO  DECIMAL(5,4)  COMMENT  '历史最高申购费率',
  F_MINREDEEMRATIO  DECIMAL(5,4)  COMMENT  '历史最低赎回费率',
  F_MINBACKRATIO  DECIMAL(5,4)  COMMENT  '历史最低后收费率',
  F_EVENNETVALUE  DECIMAL(10,9)  COMMENT  '保本单位净值',
  C_HOLDFLAG  STRING  COMMENT  '持有限制标志',
  C_ACCEPTMODE  STRING  COMMENT  '交易方式',
  F_TOTALBONUS  DECIMAL(16,8)  COMMENT  '累计单位分红',
  C_ACTCODE  STRING  COMMENT  '活动代码',
  D_APPENDDATE  STRING  COMMENT  '记录新增日期',
  C_FIRSTCSERIALNO  STRING  COMMENT  '首次确认编号',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_FUNDTYPE  STRING  COMMENT  '资金方式',
  C_BANKNO  STRING  COMMENT  '银行编号',
  C_SUBFUNDMETHOD  STRING  COMMENT  '明细资金方式',
  C_SPECIALTIES  STRING  COMMENT  '份额特殊标志',
  F_SPLITSHARES  DECIMAL(16,2)  COMMENT  '拆分增加份额',
  F_FLOORSHARES  DECIMAL(10,9)  COMMENT  '截去的份额',
  F_APPORTIONRATIO  DECIMAL(9,8)  COMMENT  '后收费垫付费率',
  F_FARERATIO  DECIMAL(5,4)  COMMENT  '营业性费率',
  F_MANAGEFARE  DECIMAL(16,2)  COMMENT  '账户管理费金额',
  F_INTERESTSHARE  DECIMAL(16,2)  COMMENT  '利息转份额',
  F_BACKFARE  DECIMAL(16,2)  COMMENT  '后收手续费',
  F_CHGFILLRATIO  DECIMAL(9,8)  COMMENT  '',
  D_LASTDEDUCTDATE  STRING  COMMENT  '',
  F_ASSIGNEDSHARES  DECIMAL(16,2)  COMMENT  '',
  C_PROTECTFLAG  STRING  COMMENT  '',
  C_ORIBOURSE  STRING  COMMENT  '',
  F_INCOME  DECIMAL(16,2)  COMMENT  '昨日基金收益',
  F_NEWINCOME  DECIMAL(16,2)  COMMENT  '当天新增未付收益',
  F_ASSIGNEDINCOME  DECIMAL(16,2)  COMMENT  '',
  D_CYCLEENDDATE  STRING  COMMENT  '',
  D_CYCLEBEGINDATE  STRING  COMMENT  '',
  D_CYCLENEXTDATE  STRING  COMMENT  '',
  F_ACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_LASTACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_LASTINCOME  DECIMAL(16,2)  COMMENT  '',
  F_CYCLEINCOME  DECIMAL(16,2)  COMMENT  '',
  F_CYCLEACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_DOUBLEINCOME  DECIMAL(16,2)  COMMENT  '',
  F_CYCLEDOUBLEINCOME  DECIMAL(16,2)  COMMENT  '',
  F_NEWDOUBLEINCOME  DECIMAL(16,2)  COMMENT  '',
  F_INTERESTINCOME  DECIMAL(16,2)  COMMENT  '',
  F_REALINTERESTSHARE  DECIMAL(16,2)  COMMENT  '',
  F_CALINCOME  DECIMAL(16,6)  COMMENT  '',
  D_INTERESTDATE  STRING  COMMENT  '',
  D_LASTINCOMEMAKEUPDATE  STRING  COMMENT  '',
  F_EXPECTTOTALBONUS  DECIMAL(16,2)  COMMENT  '',
  F_ENDBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_BEGINBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_LOCKFLAG  STRING  COMMENT  '',
  C_LOCKCSERIALNO  STRING  COMMENT  '',
  F_CSERVICEFARE  DECIMAL(16,2)  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  D_LASTCHARGEMGRFAREDATE  STRING  COMMENT  '',
  C_PROMOTIONPERIODSHAREFLAG  STRING  COMMENT  '',
  F_DEDUCTEDBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_ASSIGNEDDEDUCTEDBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_PRODUCTCYCLE  STRING  COMMENT  '',
  C_UPGRADEFLAG  STRING  COMMENT  '是否参与升降级',
  F_UPGRADENETVALUE  DECIMAL(11,8)  COMMENT  '',
  F_UPGRADETOTALBONUS  DECIMAL(11,8)  COMMENT  '',
  F_NEXTDCTBGNNETVALUE  DECIMAL(17,14)  COMMENT  '',
  F_TOTALCASHUNITBONUS  DECIMAL(17,14)  COMMENT  '',
  C_ORIGINALNO  STRING  COMMENT  '',
  C_FIRSTDEDCUTFLAG  STRING  COMMENT  '',
  D_LASTPAYINCOMEDATE  STRING  COMMENT  '',
  C_PROMISESHARESFLAG  STRING  COMMENT  '',
  F_TOTALUNITBONUS  DECIMAL(15,12)  COMMENT  '',
  F_COSTPRICE  DECIMAL(15,12)  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  F_NEWCSERVICEFARE  DECIMAL(16,2)  COMMENT  '',
  D_SCF02REQDATE  STRING  COMMENT  '',
  F_SCF02REQBANLANCE  DECIMAL(16,2)  COMMENT  '',
  C_INCOMEGRADE  STRING  COMMENT  '',
  D_LASTBONUSDATE  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  D_ORI02REQDATE  STRING  COMMENT  '',
  D_LASTEQUALQUITDATE  STRING  COMMENT  '',
  F_INCOMERATIO  DECIMAL(16,8)  COMMENT  '年收益率',
  F_REDEEMEDBASESHR  DECIMAL(16,2)  COMMENT  '',
  D_FIRSTINVESTDATE  STRING  COMMENT  '',
  D_NEXTEQUALQUITDATE  STRING  COMMENT  '',
  L_PERIODS  DECIMAL(10,0)  COMMENT  '当前保本期数',
  C_SLBORIGINALNO  STRING  COMMENT  '',
  F_TOTALINCOME  DECIMAL(16,2)  COMMENT  '',
  C_DETAILCSERIALNO  STRING  COMMENT  '',
  D_DATUMDATE  STRING  COMMENT  '',
  F_ASSIGNEDNEWINCOME  DECIMAL(16,2)  COMMENT  '',
  F_NEWMANAGEFARE  DECIMAL(16,2)  COMMENT  '',
  F_ASSIGNEDMANAGEFARE  DECIMAL(16,2)  COMMENT  '',
  F_CAPITAL  DECIMAL(16,2)  COMMENT  '',
  F_ASSIGNEDCAPITAL  DECIMAL(16,2)  COMMENT  '',
  D_SUBSIDIARYDATE  STRING  COMMENT  '',
  D_CLERKENDDATE  STRING  COMMENT  ''
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , TO_CHAR(D_CDATE,'YYYYMMDD') D_CDATE
                                   , C_CSERIALNO
                                   , C_SOURCETYPE
                                   , F_REMAINSHARES
                                   , D_REGISTDATE
                                   , F_ORIBALANCE
                                   , F_ORISHARES
                                   , F_COSTFARE
                                   , F_ORINETVALUE
                                   , F_GAINBALANCE
                                   , C_PROMISENO
                                   , F_CSHAREFARE
                                   , D_LASTMODIFY
                                   , C_ORIAGENCY
                                   , C_BONUSFLAG
                                   , C_ORISOURCE
                                   , F_BACKFARERATIO
                                   , F_RULEAGIO
                                   , F_ORIAGIO
                                   , F_MAXALLOTRATIO
                                   , F_MINREDEEMRATIO
                                   , F_MINBACKRATIO
                                   , F_EVENNETVALUE
                                   , C_HOLDFLAG
                                   , C_ACCEPTMODE
                                   , F_TOTALBONUS
                                   , C_ACTCODE
                                   , D_APPENDDATE
                                   , C_FIRSTCSERIALNO
                                   , C_BOURSEFLAG
                                   , C_FUNDTYPE
                                   , C_BANKNO
                                   , C_SUBFUNDMETHOD
                                   , C_SPECIALTIES
                                   , F_SPLITSHARES
                                   , F_FLOORSHARES
                                   , F_APPORTIONRATIO
                                   , F_FARERATIO
                                   , F_MANAGEFARE
                                   , F_INTERESTSHARE
                                   , F_BACKFARE
                                   , F_CHGFILLRATIO
                                   , D_LASTDEDUCTDATE
                                   , F_ASSIGNEDSHARES
                                   , C_PROTECTFLAG
                                   , C_ORIBOURSE
                                   , F_INCOME
                                   , F_NEWINCOME
                                   , F_ASSIGNEDINCOME
                                   , D_CYCLEENDDATE
                                   , D_CYCLEBEGINDATE
                                   , D_CYCLENEXTDATE
                                   , F_ACCUMSHARES
                                   , F_LASTACCUMSHARES
                                   , F_LASTINCOME
                                   , F_CYCLEINCOME
                                   , F_CYCLEACCUMSHARES
                                   , F_DOUBLEINCOME
                                   , F_CYCLEDOUBLEINCOME
                                   , F_NEWDOUBLEINCOME
                                   , F_INTERESTINCOME
                                   , F_REALINTERESTSHARE
                                   , F_CALINCOME
                                   , D_INTERESTDATE
                                   , D_LASTINCOMEMAKEUPDATE
                                   , F_EXPECTTOTALBONUS
                                   , F_ENDBALANCE
                                   , F_BEGINBALANCE
                                   , C_LOCKFLAG
                                   , C_LOCKCSERIALNO
                                   , F_CSERVICEFARE
                                   , C_SPECIALACCOFLAG
                                   , D_LASTCHARGEMGRFAREDATE
                                   , C_PROMOTIONPERIODSHAREFLAG
                                   , F_DEDUCTEDBALANCE
                                   , F_ASSIGNEDDEDUCTEDBALANCE
                                   , C_PRODUCTCYCLE
                                   , C_UPGRADEFLAG
                                   , F_UPGRADENETVALUE
                                   , F_UPGRADETOTALBONUS
                                   , F_NEXTDCTBGNNETVALUE
                                   , F_TOTALCASHUNITBONUS
                                   , C_ORIGINALNO
                                   , C_FIRSTDEDCUTFLAG
                                   , D_LASTPAYINCOMEDATE
                                   , C_PROMISESHARESFLAG
                                   , F_TOTALUNITBONUS
                                   , F_COSTPRICE
                                   , C_SUBFUNDCODE
                                   , F_NEWCSERVICEFARE
                                   , D_SCF02REQDATE
                                   , F_SCF02REQBANLANCE
                                   , C_INCOMEGRADE
                                   , D_LASTBONUSDATE
                                   , C_PARTNERID
                                   , D_ORI02REQDATE
                                   , D_LASTEQUALQUITDATE
                                   , F_INCOMERATIO
                                   , F_REDEEMEDBASESHR
                                   , D_FIRSTINVESTDATE
                                   , D_NEXTEQUALQUITDATE
                                   , L_PERIODS
                                   , C_SLBORIGINALNO
                                   , F_TOTALINCOME
                                   , C_DETAILCSERIALNO
                                   , D_DATUMDATE
                                   , F_ASSIGNEDNEWINCOME
                                   , F_NEWMANAGEFARE
                                   , F_ASSIGNEDMANAGEFARE
                                   , F_CAPITAL
                                   , F_ASSIGNEDCAPITAL
                                   , D_SUBSIDIARYDATE
                                   , D_CLERKENDDATE
                                FROM ${hsfta_src_schema}.TSHAREDETAIL
                                WHERE D_CDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_SOURCETYPE", "type": "STRING"}, {"name": "F_REMAINSHARES", "type": "DOUBLE"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "F_ORIBALANCE", "type": "DOUBLE"}, {"name": "F_ORISHARES", "type": "DOUBLE"}, {"name": "F_COSTFARE", "type": "DOUBLE"}, {"name": "F_ORINETVALUE", "type": "DOUBLE"}, {"name": "F_GAINBALANCE", "type": "DOUBLE"}, {"name": "C_PROMISENO", "type": "STRING"}, {"name": "F_CSHAREFARE", "type": "DOUBLE"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "C_ORIAGENCY", "type": "STRING"}, {"name": "C_BONUSFLAG", "type": "STRING"}, {"name": "C_ORISOURCE", "type": "STRING"}, {"name": "F_BACKFARERATIO", "type": "DOUBLE"}, {"name": "F_RULEAGIO", "type": "DOUBLE"}, {"name": "F_ORIAGIO", "type": "DOUBLE"}, {"name": "F_MAXALLOTRATIO", "type": "DOUBLE"}, {"name": "F_MINREDEEMRATIO", "type": "DOUBLE"}, {"name": "F_MINBACKRATIO", "type": "DOUBLE"}, {"name": "F_EVENNETVALUE", "type": "DOUBLE"}, {"name": "C_HOLDFLAG", "type": "STRING"}, {"name": "C_ACCEPTMODE", "type": "STRING"}, {"name": "F_TOTALBONUS", "type": "DOUBLE"}, {"name": "C_ACTCODE", "type": "STRING"}, {"name": "D_APPENDDATE", "type": "STRING"}, {"name": "C_FIRSTCSERIALNO", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_FUNDTYPE", "type": "STRING"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_SUBFUNDMETHOD", "type": "STRING"}, {"name": "C_SPECIALTIES", "type": "STRING"}, {"name": "F_SPLITSHARES", "type": "DOUBLE"}, {"name": "F_FLOORSHARES", "type": "DOUBLE"}, {"name": "F_APPORTIONRATIO", "type": "DOUBLE"}, {"name": "F_FARERATIO", "type": "DOUBLE"}, {"name": "F_MANAGEFARE", "type": "DOUBLE"}, {"name": "F_INTERESTSHARE", "type": "DOUBLE"}, {"name": "F_BACKFARE", "type": "DOUBLE"}, {"name": "F_CHGFILLRATIO", "type": "DOUBLE"}, {"name": "D_LASTDEDUCTDATE", "type": "STRING"}, {"name": "F_ASSIGNEDSHARES", "type": "DOUBLE"}, {"name": "C_PROTECTFLAG", "type": "STRING"}, {"name": "C_ORIBOURSE", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_NEWINCOME", "type": "DOUBLE"}, {"name": "F_ASSIGNEDINCOME", "type": "DOUBLE"}, {"name": "D_CYCLEENDDATE", "type": "STRING"}, {"name": "D_CYCLEBEGINDATE", "type": "STRING"}, {"name": "D_CYCLENEXTDATE", "type": "STRING"}, {"name": "F_ACCUMSHARES", "type": "DOUBLE"}, {"name": "F_LASTACCUMSHARES", "type": "DOUBLE"}, {"name": "F_LASTINCOME", "type": "DOUBLE"}, {"name": "F_CYCLEINCOME", "type": "DOUBLE"}, {"name": "F_CYCLEACCUMSHARES", "type": "DOUBLE"}, {"name": "F_DOUBLEINCOME", "type": "DOUBLE"}, {"name": "F_CYCLEDOUBLEINCOME", "type": "DOUBLE"}, {"name": "F_NEWDOUBLEINCOME", "type": "DOUBLE"}, {"name": "F_INTERESTINCOME", "type": "DOUBLE"}, {"name": "F_REALINTERESTSHARE", "type": "DOUBLE"}, {"name": "F_CALINCOME", "type": "DOUBLE"}, {"name": "D_INTERESTDATE", "type": "STRING"}, {"name": "D_LASTINCOMEMAKEUPDATE", "type": "STRING"}, {"name": "F_EXPECTTOTALBONUS", "type": "DOUBLE"}, {"name": "F_ENDBALANCE", "type": "DOUBLE"}, {"name": "F_BEGINBALANCE", "type": "DOUBLE"}, {"name": "C_LOCKFLAG", "type": "STRING"}, {"name": "C_LOCKCSERIALNO", "type": "STRING"}, {"name": "F_CSERVICEFARE", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "D_LASTCHARGEMGRFAREDATE", "type": "STRING"}, {"name": "C_PROMOTIONPERIODSHAREFLAG", "type": "STRING"}, {"name": "F_DEDUCTEDBALANCE", "type": "DOUBLE"}, {"name": "F_ASSIGNEDDEDUCTEDBALANCE", "type": "DOUBLE"}, {"name": "C_PRODUCTCYCLE", "type": "STRING"}, {"name": "C_UPGRADEFLAG", "type": "STRING"}, {"name": "F_UPGRADENETVALUE", "type": "DOUBLE"}, {"name": "F_UPGRADETOTALBONUS", "type": "DOUBLE"}, {"name": "F_NEXTDCTBGNNETVALUE", "type": "DOUBLE"}, {"name": "F_TOTALCASHUNITBONUS", "type": "DOUBLE"}, {"name": "C_ORIGINALNO", "type": "STRING"}, {"name": "C_FIRSTDEDCUTFLAG", "type": "STRING"}, {"name": "D_LASTPAYINCOMEDATE", "type": "STRING"}, {"name": "C_PROMISESHARESFLAG", "type": "STRING"}, {"name": "F_TOTALUNITBONUS", "type": "DOUBLE"}, {"name": "F_COSTPRICE", "type": "DOUBLE"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "F_NEWCSERVICEFARE", "type": "DOUBLE"}, {"name": "D_SCF02REQDATE", "type": "STRING"}, {"name": "F_SCF02REQBANLANCE", "type": "DOUBLE"}, {"name": "C_INCOMEGRADE", "type": "STRING"}, {"name": "D_LASTBONUSDATE", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "D_ORI02REQDATE", "type": "STRING"}, {"name": "D_LASTEQUALQUITDATE", "type": "STRING"}, {"name": "F_INCOMERATIO", "type": "DOUBLE"}, {"name": "F_REDEEMEDBASESHR", "type": "DOUBLE"}, {"name": "D_FIRSTINVESTDATE", "type": "STRING"}, {"name": "D_NEXTEQUALQUITDATE", "type": "STRING"}, {"name": "L_PERIODS", "type": "DOUBLE"}, {"name": "C_SLBORIGINALNO", "type": "STRING"}, {"name": "F_TOTALINCOME", "type": "DOUBLE"}, {"name": "C_DETAILCSERIALNO", "type": "STRING"}, {"name": "D_DATUMDATE", "type": "STRING"}, {"name": "F_ASSIGNEDNEWINCOME", "type": "DOUBLE"}, {"name": "F_NEWMANAGEFARE", "type": "DOUBLE"}, {"name": "F_ASSIGNEDMANAGEFARE", "type": "DOUBLE"}, {"name": "F_CAPITAL", "type": "DOUBLE"}, {"name": "F_ASSIGNEDCAPITAL", "type": "DOUBLE"}, {"name": "D_SUBSIDIARYDATE", "type": "STRING"}, {"name": "D_CLERKENDDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tsharedetail_ptd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tsharedetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tsharedetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tsharedetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TSHAREDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TSHAREDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tsharedetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSHAREDETAIL_PTD PARTITION(P_DT)
SELECT
       C_FUNDACCO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , C_AGENCYNO
     , C_NETNO
     , D_CDATE
     , C_CSERIALNO
     , C_SOURCETYPE
     , F_REMAINSHARES
     , D_REGISTDATE
     , F_ORIBALANCE
     , F_ORISHARES
     , F_COSTFARE
     , F_ORINETVALUE
     , F_GAINBALANCE
     , C_PROMISENO
     , F_CSHAREFARE
     , D_LASTMODIFY
     , C_ORIAGENCY
     , C_BONUSFLAG
     , C_ORISOURCE
     , F_BACKFARERATIO
     , F_RULEAGIO
     , F_ORIAGIO
     , F_MAXALLOTRATIO
     , F_MINREDEEMRATIO
     , F_MINBACKRATIO
     , F_EVENNETVALUE
     , C_HOLDFLAG
     , C_ACCEPTMODE
     , F_TOTALBONUS
     , C_ACTCODE
     , D_APPENDDATE
     , C_FIRSTCSERIALNO
     , C_BOURSEFLAG
     , C_FUNDTYPE
     , C_BANKNO
     , C_SUBFUNDMETHOD
     , C_SPECIALTIES
     , F_SPLITSHARES
     , F_FLOORSHARES
     , F_APPORTIONRATIO
     , F_FARERATIO
     , F_MANAGEFARE
     , F_INTERESTSHARE
     , F_BACKFARE
     , F_CHGFILLRATIO
     , D_LASTDEDUCTDATE
     , F_ASSIGNEDSHARES
     , C_PROTECTFLAG
     , C_ORIBOURSE
     , F_INCOME
     , F_NEWINCOME
     , F_ASSIGNEDINCOME
     , D_CYCLEENDDATE
     , D_CYCLEBEGINDATE
     , D_CYCLENEXTDATE
     , F_ACCUMSHARES
     , F_LASTACCUMSHARES
     , F_LASTINCOME
     , F_CYCLEINCOME
     , F_CYCLEACCUMSHARES
     , F_DOUBLEINCOME
     , F_CYCLEDOUBLEINCOME
     , F_NEWDOUBLEINCOME
     , F_INTERESTINCOME
     , F_REALINTERESTSHARE
     , F_CALINCOME
     , D_INTERESTDATE
     , D_LASTINCOMEMAKEUPDATE
     , F_EXPECTTOTALBONUS
     , F_ENDBALANCE
     , F_BEGINBALANCE
     , C_LOCKFLAG
     , C_LOCKCSERIALNO
     , F_CSERVICEFARE
     , C_SPECIALACCOFLAG
     , D_LASTCHARGEMGRFAREDATE
     , C_PROMOTIONPERIODSHAREFLAG
     , F_DEDUCTEDBALANCE
     , F_ASSIGNEDDEDUCTEDBALANCE
     , C_PRODUCTCYCLE
     , C_UPGRADEFLAG
     , F_UPGRADENETVALUE
     , F_UPGRADETOTALBONUS
     , F_NEXTDCTBGNNETVALUE
     , F_TOTALCASHUNITBONUS
     , C_ORIGINALNO
     , C_FIRSTDEDCUTFLAG
     , D_LASTPAYINCOMEDATE
     , C_PROMISESHARESFLAG
     , F_TOTALUNITBONUS
     , F_COSTPRICE
     , C_SUBFUNDCODE
     , F_NEWCSERVICEFARE
     , D_SCF02REQDATE
     , F_SCF02REQBANLANCE
     , C_INCOMEGRADE
     , D_LASTBONUSDATE
     , C_PARTNERID
     , D_ORI02REQDATE
     , D_LASTEQUALQUITDATE
     , F_INCOMERATIO
     , F_REDEEMEDBASESHR
     , D_FIRSTINVESTDATE
     , D_NEXTEQUALQUITDATE
     , L_PERIODS
     , C_SLBORIGINALNO
     , F_TOTALINCOME
     , C_DETAILCSERIALNO
     , D_DATUMDATE
     , F_ASSIGNEDNEWINCOME
     , F_NEWMANAGEFARE
     , F_ASSIGNEDMANAGEFARE
     , F_CAPITAL
     , F_ASSIGNEDCAPITAL
     , D_SUBSIDIARYDATE
     , D_CLERKENDDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_CDATE,'-','') P_DT
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSHAREDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSHAREDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TSHAREDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TSHAREDETAIL_PTD成功"
      exit 0
   fi
fi
