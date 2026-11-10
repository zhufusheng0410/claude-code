#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDDAY_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDDAY_PFD_TMP(
  D_DATE  STRING  COMMENT  '净值日期',
  D_CDATE  STRING  COMMENT  '确认日期',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_TODAYSTATUS  STRING  COMMENT  '今日基金状态',
  C_STATUS  STRING  COMMENT  '昨日基金状态',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '基金净值（成交价）',
  F_LASTSHARES  DECIMAL(16,2)  COMMENT  '昨日总份额',
  F_LASTASSET  DECIMAL(16,2)  COMMENT  '昨日总净值',
  F_ASUCCEED  DECIMAL(16,2)  COMMENT  '当日增加份数',
  F_RSUCCEED  DECIMAL(16,2)  COMMENT  '当日减少份数',
  C_VASTFLAG  STRING  COMMENT  '巨额赎回标志',
  F_ENCASHRATIO  DECIMAL(9,8)  COMMENT  '巨额赎回比例',
  F_CHANGERATIO  DECIMAL(9,8)  COMMENT  '巨额赎回，转出确认比例',
  C_EXCESSFLAG  STRING  COMMENT  '超额申购标志',
  F_SUBSCRIBERATIO  DECIMAL(11,10)  COMMENT  '超额申购比例',
  C_INPUTPERSONNEL  STRING  COMMENT  '输入员',
  C_CHECKPERSONNEL  STRING  COMMENT  '复核员',
  F_INCOME  DECIMAL(16,2)  COMMENT  '昨日基金收益',
  F_INCOMERATIO  DECIMAL(9,6)  COMMENT  '年收益率',
  F_UNASSIGN  DECIMAL(16,2)  COMMENT  '未分配收益',
  F_INCOMEUNIT  DECIMAL(10,5)  COMMENT  '万份单位收益',
  F_TOTALNETVALUE  DECIMAL(16,8)  COMMENT  '累计净值',
  F_SERVICEFARE  DECIMAL(16,2)  COMMENT  '销售服务费',
  F_ASSIGN  DECIMAL(16,2)  COMMENT  '当天分配收益',
  F_GROWTHRATE  DECIMAL(11,8)  COMMENT  '',
  F_MANAGEFARE  DECIMAL(16,2)  COMMENT  '账户管理费金额',
  F_PROTECTBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_TODAYTRFSTATUS  STRING  COMMENT  '',
  C_TODAYCHGSTATUS  STRING  COMMENT  '',
  C_TODAYPCSSTATUS  STRING  COMMENT  '',
  C_TODAYSPLITSTATUS  STRING  COMMENT  '',
  D_EXPORTDATE  STRING  COMMENT  '',
  C_ACCOEXCESSFLAG  STRING  COMMENT  '',
  F_ENDACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_QINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_DOUBLEINCOME  DECIMAL(16,2)  COMMENT  '',
  F_DINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_OFFSETINCOME  DECIMAL(16,2)  COMMENT  '',
  F_DEPOSITAGMINCOME  DECIMAL(16,2)  COMMENT  '',
  F_DEPOSITAGMDBLINCOME  DECIMAL(16,2)  COMMENT  '',
  C_NETVALUEFLAG  STRING  COMMENT  '',
  F_ORIINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ORIDOUBLEINCOME  DECIMAL(16,2)  COMMENT  '',
  F_RDMACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_ORIDEPOSITAGMINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ORIDEPOSITAGMDBLINCOME  DECIMAL(16,2)  COMMENT  '',
  F_DEPOSITRDMINCOME  DECIMAL(16,2)  COMMENT  '',
  F_DEPOSITRDMDBLINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ORIDEPOSITRDMINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ORIDEPOSITRDMDBLINCOME  DECIMAL(16,2)  COMMENT  '',
  F_FOREIGNCURRENCYNETVALUE  DECIMAL(16,8)  COMMENT  '',
  F_FOREIGNCURRENCYTOTALVALUE  DECIMAL(16,8)  COMMENT  '',
  C_LASTWORKDAYSTATUS  STRING  COMMENT  '',
  F_PMAXBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '',
  F_EMAXBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '',
  F_PMAXSUMBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '',
  F_EMAXSUMBIDSAMOUNT  DECIMAL(16,2)  COMMENT  '',
  F_PMAXREDSVOL  DECIMAL(16,2)  COMMENT  '',
  F_EMAXREDSVOL  DECIMAL(16,2)  COMMENT  '',
  F_PMAXSUMREDSVOL  DECIMAL(16,2)  COMMENT  '',
  F_EMAXSUMREDSVOL  DECIMAL(16,2)  COMMENT  '',
  F_YEBINCOME  DECIMAL(16,2)  COMMENT  '',
  F_YEBASSIGN  DECIMAL(16,2)  COMMENT  '',
  F_YEBUNASSIGN  DECIMAL(16,2)  COMMENT  '',
  D_NEXTOPENDAY  STRING  COMMENT  '',
  F_TOTALDOUBLEINCOME  DECIMAL(16,2)  COMMENT  '',
  F_EXCHANGERATE  DECIMAL(7,4)  COMMENT  '',
  C_ASSETLOWLIMIT  STRING  COMMENT  '',
  C_ACCOUNTLOWLIMIT  STRING  COMMENT  '',
  F_7DAYINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_JANINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_MARINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_HALFINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_YEARINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_JANAVGINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_MARAVGINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_HALFAVGINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_YEARAVGINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  L_ACCOCOUNT  DECIMAL(10,0)  COMMENT  '',
  C_ISNEEDCALCRDMFEE  STRING  COMMENT  '',
  F_CROSSTALASTSHARES  DECIMAL(16,2)  COMMENT  '',
  F_CROSSTALASTASSET  DECIMAL(16,2)  COMMENT  '',
  C_ISNEEDRDMBYALLOT  STRING  COMMENT  '',
  F_VALUELEVEL  DECIMAL(9,4)  COMMENT  '',
  C_LASTTRFSTATUS  STRING  COMMENT  '',
  C_LASTCHGSTATUS  STRING  COMMENT  '',
  C_LASTPCSSTATUS  STRING  COMMENT  '',
  C_LASTSPLITSTATUS  STRING  COMMENT  '',
  F_SEVENRDMASSET  DECIMAL(16,2)  COMMENT  '',
  C_SEVENRDMFLAG  STRING  COMMENT  '',
  F_SEVENRDMRATIO  DECIMAL(9,8)  COMMENT  '',
  F_EXTERNALRATIO  DECIMAL(7,4)  COMMENT  '',
  F_CALCGROWTHRATE  DECIMAL(9,6)  COMMENT  '',
  F_APPOINTNETVALUE  DECIMAL(15,12)  COMMENT  '',
  F_DISCOUNTRATE  DECIMAL(10,4)  COMMENT  '',
  C_TMPOPENDAY  STRING  COMMENT  '',
  C_SUPPORTFUNDSTATUS  STRING  COMMENT  '',
  F_TRYCALCSUBRATIO  DECIMAL(11,10)  COMMENT  ''
)
COMMENT '基金日信息'
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
              "querySql": ["SELECT  D_DATE
                                   , D_CDATE
                                   , C_FUNDCODE
                                   , C_TODAYSTATUS
                                   , C_STATUS
                                   , F_NETVALUE
                                   , F_LASTSHARES
                                   , F_LASTASSET
                                   , F_ASUCCEED
                                   , F_RSUCCEED
                                   , C_VASTFLAG
                                   , F_ENCASHRATIO
                                   , F_CHANGERATIO
                                   , C_EXCESSFLAG
                                   , F_SUBSCRIBERATIO
                                   , C_INPUTPERSONNEL
                                   , C_CHECKPERSONNEL
                                   , F_INCOME
                                   , F_INCOMERATIO
                                   , F_UNASSIGN
                                   , F_INCOMEUNIT
                                   , F_TOTALNETVALUE
                                   , F_SERVICEFARE
                                   , F_ASSIGN
                                   , F_GROWTHRATE
                                   , F_MANAGEFARE
                                   , F_PROTECTBALANCE
                                   , C_TODAYTRFSTATUS
                                   , C_TODAYCHGSTATUS
                                   , C_TODAYPCSSTATUS
                                   , C_TODAYSPLITSTATUS
                                   , D_EXPORTDATE
                                   , C_ACCOEXCESSFLAG
                                   , F_ENDACCUMSHARES
                                   , F_QINCOMERATIO
                                   , F_DOUBLEINCOME
                                   , F_DINCOMERATIO
                                   , F_OFFSETINCOME
                                   , F_DEPOSITAGMINCOME
                                   , F_DEPOSITAGMDBLINCOME
                                   , C_NETVALUEFLAG
                                   , F_ORIINCOME
                                   , F_ORIDOUBLEINCOME
                                   , F_RDMACCUMSHARES
                                   , F_ORIDEPOSITAGMINCOME
                                   , F_ORIDEPOSITAGMDBLINCOME
                                   , F_DEPOSITRDMINCOME
                                   , F_DEPOSITRDMDBLINCOME
                                   , F_ORIDEPOSITRDMINCOME
                                   , F_ORIDEPOSITRDMDBLINCOME
                                   , F_FOREIGNCURRENCYNETVALUE
                                   , F_FOREIGNCURRENCYTOTALVALUE
                                   , C_LASTWORKDAYSTATUS
                                   , F_PMAXBIDSAMOUNT
                                   , F_EMAXBIDSAMOUNT
                                   , F_PMAXSUMBIDSAMOUNT
                                   , F_EMAXSUMBIDSAMOUNT
                                   , F_PMAXREDSVOL
                                   , F_EMAXREDSVOL
                                   , F_PMAXSUMREDSVOL
                                   , F_EMAXSUMREDSVOL
                                   , F_YEBINCOME
                                   , F_YEBASSIGN
                                   , F_YEBUNASSIGN
                                   , D_NEXTOPENDAY
                                   , F_TOTALDOUBLEINCOME
                                   , F_EXCHANGERATE
                                   , C_ASSETLOWLIMIT
                                   , C_ACCOUNTLOWLIMIT
                                   , F_7DAYINCOMERATIO
                                   , F_JANINCOMERATIO
                                   , F_MARINCOMERATIO
                                   , F_HALFINCOMERATIO
                                   , F_YEARINCOMERATIO
                                   , F_JANAVGINCOMERATIO
                                   , F_MARAVGINCOMERATIO
                                   , F_HALFAVGINCOMERATIO
                                   , F_YEARAVGINCOMERATIO
                                   , L_ACCOCOUNT
                                   , C_ISNEEDCALCRDMFEE
                                   , F_CROSSTALASTSHARES
                                   , F_CROSSTALASTASSET
                                   , C_ISNEEDRDMBYALLOT
                                   , F_VALUELEVEL
                                   , C_LASTTRFSTATUS
                                   , C_LASTCHGSTATUS
                                   , C_LASTPCSSTATUS
                                   , C_LASTSPLITSTATUS
                                   , F_SEVENRDMASSET
                                   , C_SEVENRDMFLAG
                                   , F_SEVENRDMRATIO
                                   , F_EXTERNALRATIO
                                   , F_CALCGROWTHRATE
                                   , F_APPOINTNETVALUE
                                   , F_DISCOUNTRATE
                                   , C_TMPOPENDAY
                                   , C_SUPPORTFUNDSTATUS
                                   , F_TRYCALCSUBRATIO
                                FROM ${hsfta_src_schema}.TFUNDDAY"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_DATE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_TODAYSTATUS", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_LASTSHARES", "type": "DOUBLE"}, {"name": "F_LASTASSET", "type": "DOUBLE"}, {"name": "F_ASUCCEED", "type": "DOUBLE"}, {"name": "F_RSUCCEED", "type": "DOUBLE"}, {"name": "C_VASTFLAG", "type": "STRING"}, {"name": "F_ENCASHRATIO", "type": "DOUBLE"}, {"name": "F_CHANGERATIO", "type": "DOUBLE"}, {"name": "C_EXCESSFLAG", "type": "STRING"}, {"name": "F_SUBSCRIBERATIO", "type": "DOUBLE"}, {"name": "C_INPUTPERSONNEL", "type": "STRING"}, {"name": "C_CHECKPERSONNEL", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_INCOMERATIO", "type": "DOUBLE"}, {"name": "F_UNASSIGN", "type": "DOUBLE"}, {"name": "F_INCOMEUNIT", "type": "DOUBLE"}, {"name": "F_TOTALNETVALUE", "type": "DOUBLE"}, {"name": "F_SERVICEFARE", "type": "DOUBLE"}, {"name": "F_ASSIGN", "type": "DOUBLE"}, {"name": "F_GROWTHRATE", "type": "DOUBLE"}, {"name": "F_MANAGEFARE", "type": "DOUBLE"}, {"name": "F_PROTECTBALANCE", "type": "DOUBLE"}, {"name": "C_TODAYTRFSTATUS", "type": "STRING"}, {"name": "C_TODAYCHGSTATUS", "type": "STRING"}, {"name": "C_TODAYPCSSTATUS", "type": "STRING"}, {"name": "C_TODAYSPLITSTATUS", "type": "STRING"}, {"name": "D_EXPORTDATE", "type": "STRING"}, {"name": "C_ACCOEXCESSFLAG", "type": "STRING"}, {"name": "F_ENDACCUMSHARES", "type": "DOUBLE"}, {"name": "F_QINCOMERATIO", "type": "DOUBLE"}, {"name": "F_DOUBLEINCOME", "type": "DOUBLE"}, {"name": "F_DINCOMERATIO", "type": "DOUBLE"}, {"name": "F_OFFSETINCOME", "type": "DOUBLE"}, {"name": "F_DEPOSITAGMINCOME", "type": "DOUBLE"}, {"name": "F_DEPOSITAGMDBLINCOME", "type": "DOUBLE"}, {"name": "C_NETVALUEFLAG", "type": "STRING"}, {"name": "F_ORIINCOME", "type": "DOUBLE"}, {"name": "F_ORIDOUBLEINCOME", "type": "DOUBLE"}, {"name": "F_RDMACCUMSHARES", "type": "DOUBLE"}, {"name": "F_ORIDEPOSITAGMINCOME", "type": "DOUBLE"}, {"name": "F_ORIDEPOSITAGMDBLINCOME", "type": "DOUBLE"}, {"name": "F_DEPOSITRDMINCOME", "type": "DOUBLE"}, {"name": "F_DEPOSITRDMDBLINCOME", "type": "DOUBLE"}, {"name": "F_ORIDEPOSITRDMINCOME", "type": "DOUBLE"}, {"name": "F_ORIDEPOSITRDMDBLINCOME", "type": "DOUBLE"}, {"name": "F_FOREIGNCURRENCYNETVALUE", "type": "DOUBLE"}, {"name": "F_FOREIGNCURRENCYTOTALVALUE", "type": "DOUBLE"}, {"name": "C_LASTWORKDAYSTATUS", "type": "STRING"}, {"name": "F_PMAXBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_EMAXBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_PMAXSUMBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_EMAXSUMBIDSAMOUNT", "type": "DOUBLE"}, {"name": "F_PMAXREDSVOL", "type": "DOUBLE"}, {"name": "F_EMAXREDSVOL", "type": "DOUBLE"}, {"name": "F_PMAXSUMREDSVOL", "type": "DOUBLE"}, {"name": "F_EMAXSUMREDSVOL", "type": "DOUBLE"}, {"name": "F_YEBINCOME", "type": "DOUBLE"}, {"name": "F_YEBASSIGN", "type": "DOUBLE"}, {"name": "F_YEBUNASSIGN", "type": "DOUBLE"}, {"name": "D_NEXTOPENDAY", "type": "STRING"}, {"name": "F_TOTALDOUBLEINCOME", "type": "DOUBLE"}, {"name": "F_EXCHANGERATE", "type": "DOUBLE"}, {"name": "C_ASSETLOWLIMIT", "type": "STRING"}, {"name": "C_ACCOUNTLOWLIMIT", "type": "STRING"}, {"name": "F_7DAYINCOMERATIO", "type": "DOUBLE"}, {"name": "F_JANINCOMERATIO", "type": "DOUBLE"}, {"name": "F_MARINCOMERATIO", "type": "DOUBLE"}, {"name": "F_HALFINCOMERATIO", "type": "DOUBLE"}, {"name": "F_YEARINCOMERATIO", "type": "DOUBLE"}, {"name": "F_JANAVGINCOMERATIO", "type": "DOUBLE"}, {"name": "F_MARAVGINCOMERATIO", "type": "DOUBLE"}, {"name": "F_HALFAVGINCOMERATIO", "type": "DOUBLE"}, {"name": "F_YEARAVGINCOMERATIO", "type": "DOUBLE"}, {"name": "L_ACCOCOUNT", "type": "DOUBLE"}, {"name": "C_ISNEEDCALCRDMFEE", "type": "STRING"}, {"name": "F_CROSSTALASTSHARES", "type": "DOUBLE"}, {"name": "F_CROSSTALASTASSET", "type": "DOUBLE"}, {"name": "C_ISNEEDRDMBYALLOT", "type": "STRING"}, {"name": "F_VALUELEVEL", "type": "DOUBLE"}, {"name": "C_LASTTRFSTATUS", "type": "STRING"}, {"name": "C_LASTCHGSTATUS", "type": "STRING"}, {"name": "C_LASTPCSSTATUS", "type": "STRING"}, {"name": "C_LASTSPLITSTATUS", "type": "STRING"}, {"name": "F_SEVENRDMASSET", "type": "DOUBLE"}, {"name": "C_SEVENRDMFLAG", "type": "STRING"}, {"name": "F_SEVENRDMRATIO", "type": "DOUBLE"}, {"name": "F_EXTERNALRATIO", "type": "DOUBLE"}, {"name": "F_CALCGROWTHRATE", "type": "DOUBLE"}, {"name": "F_APPOINTNETVALUE", "type": "DOUBLE"}, {"name": "F_DISCOUNTRATE", "type": "DOUBLE"}, {"name": "C_TMPOPENDAY", "type": "STRING"}, {"name": "C_SUPPORTFUNDSTATUS", "type": "STRING"}, {"name": "F_TRYCALCSUBRATIO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tfundday_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tfundday_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tfundday_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tfundday_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TFUNDDAY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TFUNDDAY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tfundday_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDDAY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       D_DATE
     , D_CDATE
     , C_FUNDCODE
     , C_TODAYSTATUS
     , C_STATUS
     , F_NETVALUE
     , F_LASTSHARES
     , F_LASTASSET
     , F_ASUCCEED
     , F_RSUCCEED
     , C_VASTFLAG
     , F_ENCASHRATIO
     , F_CHANGERATIO
     , C_EXCESSFLAG
     , F_SUBSCRIBERATIO
     , C_INPUTPERSONNEL
     , C_CHECKPERSONNEL
     , F_INCOME
     , F_INCOMERATIO
     , F_UNASSIGN
     , F_INCOMEUNIT
     , F_TOTALNETVALUE
     , F_SERVICEFARE
     , F_ASSIGN
     , F_GROWTHRATE
     , F_MANAGEFARE
     , F_PROTECTBALANCE
     , C_TODAYTRFSTATUS
     , C_TODAYCHGSTATUS
     , C_TODAYPCSSTATUS
     , C_TODAYSPLITSTATUS
     , D_EXPORTDATE
     , C_ACCOEXCESSFLAG
     , F_ENDACCUMSHARES
     , F_QINCOMERATIO
     , F_DOUBLEINCOME
     , F_DINCOMERATIO
     , F_OFFSETINCOME
     , F_DEPOSITAGMINCOME
     , F_DEPOSITAGMDBLINCOME
     , C_NETVALUEFLAG
     , F_ORIINCOME
     , F_ORIDOUBLEINCOME
     , F_RDMACCUMSHARES
     , F_ORIDEPOSITAGMINCOME
     , F_ORIDEPOSITAGMDBLINCOME
     , F_DEPOSITRDMINCOME
     , F_DEPOSITRDMDBLINCOME
     , F_ORIDEPOSITRDMINCOME
     , F_ORIDEPOSITRDMDBLINCOME
     , F_FOREIGNCURRENCYNETVALUE
     , F_FOREIGNCURRENCYTOTALVALUE
     , C_LASTWORKDAYSTATUS
     , F_PMAXBIDSAMOUNT
     , F_EMAXBIDSAMOUNT
     , F_PMAXSUMBIDSAMOUNT
     , F_EMAXSUMBIDSAMOUNT
     , F_PMAXREDSVOL
     , F_EMAXREDSVOL
     , F_PMAXSUMREDSVOL
     , F_EMAXSUMREDSVOL
     , F_YEBINCOME
     , F_YEBASSIGN
     , F_YEBUNASSIGN
     , D_NEXTOPENDAY
     , F_TOTALDOUBLEINCOME
     , F_EXCHANGERATE
     , C_ASSETLOWLIMIT
     , C_ACCOUNTLOWLIMIT
     , F_7DAYINCOMERATIO
     , F_JANINCOMERATIO
     , F_MARINCOMERATIO
     , F_HALFINCOMERATIO
     , F_YEARINCOMERATIO
     , F_JANAVGINCOMERATIO
     , F_MARAVGINCOMERATIO
     , F_HALFAVGINCOMERATIO
     , F_YEARAVGINCOMERATIO
     , L_ACCOCOUNT
     , C_ISNEEDCALCRDMFEE
     , F_CROSSTALASTSHARES
     , F_CROSSTALASTASSET
     , C_ISNEEDRDMBYALLOT
     , F_VALUELEVEL
     , C_LASTTRFSTATUS
     , C_LASTCHGSTATUS
     , C_LASTPCSSTATUS
     , C_LASTSPLITSTATUS
     , F_SEVENRDMASSET
     , C_SEVENRDMFLAG
     , F_SEVENRDMRATIO
     , F_EXTERNALRATIO
     , F_CALCGROWTHRATE
     , F_APPOINTNETVALUE
     , F_DISCOUNTRATE
     , C_TMPOPENDAY
     , C_SUPPORTFUNDSTATUS
     , F_TRYCALCSUBRATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDDAY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TFUNDDAY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TFUNDDAY_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TFUNDDAY_PFD成功"
      exit 0
   fi
fi
