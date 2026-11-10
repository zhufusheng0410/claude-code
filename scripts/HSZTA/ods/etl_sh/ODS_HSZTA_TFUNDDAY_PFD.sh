#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDDAY_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDDAY_PFD_TMP(
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
  F_SUBSCRIBERATIO  DECIMAL(9,8)  COMMENT  '超额申购比例',
  C_INPUTPERSONNEL  STRING  COMMENT  '输入员',
  C_CHECKPERSONNEL  STRING  COMMENT  '复核员',
  C_CHECK  STRING  COMMENT  '',
  F_INCOME  DECIMAL(16,2)  COMMENT  '昨日基金收益',
  F_INCOMEUNIT  DECIMAL(10,5)  COMMENT  '万份单位收益',
  F_INCOMERATIO  DECIMAL(9,6)  COMMENT  '年收益率',
  F_UNASSIGN  DECIMAL(16,2)  COMMENT  '未分配收益',
  F_TOTALNETVALUE  DECIMAL(16,8)  COMMENT  '累计净值',
  F_SERVICEFARE  DECIMAL(16,2)  COMMENT  '销售服务费',
  F_ASSIGN  DECIMAL(16,2)  COMMENT  '当天分配收益',
  F_MANAGEFARE  DECIMAL(16,2)  COMMENT  '账户管理费金额',
  F_PROTECTBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_TODAYPCSSTATUS  STRING  COMMENT  '',
  C_TODAYCHGSTATUS  STRING  COMMENT  '',
  C_TODAYTRFSTATUS  STRING  COMMENT  '',
  C_TODAYSPLITSTATUS  STRING  COMMENT  '',
  D_EXPORTDATE  STRING  COMMENT  '',
  F_EXCHANGERATE  DECIMAL(9,6)  COMMENT  '',
  F_STRUCTUREDTOTALASSET  DECIMAL(16,2)  COMMENT  '',
  C_NETREDEEMORPURCHASEFLAG  STRING  COMMENT  '',
  F_YEBINCOME  DECIMAL(16,2)  COMMENT  '',
  F_YEBASSIGN  DECIMAL(16,2)  COMMENT  '',
  F_YEBUNASSIGN  DECIMAL(16,2)  COMMENT  '',
  F_OFFSETINCOME  DECIMAL(16,2)  COMMENT  '',
  F_QINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  C_PERMITDEAL  STRING  COMMENT  '',
  D_FILEDATE  STRING  COMMENT  '',
  C_ISNEEDCALCRDMFEE  STRING  COMMENT  '',
  F_CROSSTALASTSHARES  DECIMAL(16,2)  COMMENT  '',
  F_CROSSTALASTASSET  DECIMAL(16,2)  COMMENT  '',
  F_EXRIGHTPRICE  DECIMAL(16,8)  COMMENT  '',
  F_INDEXPRICE  DECIMAL(21,8)  COMMENT  '',
  F_JANINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_MARINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_HALFINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_YEARINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_JANAVGINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_MARAVGINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_HALFAVGINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  F_YEARAVGINCOMERATIO  DECIMAL(9,6)  COMMENT  '',
  C_ACCOUNTLOWLIMIT  STRING  COMMENT  '',
  C_ASSETLOWLIMIT  STRING  COMMENT  '',
  L_ACCOCOUNT  DECIMAL(10,0)  COMMENT  '',
  C_WATERMARKEXCEPT  STRING  COMMENT  '',
  F_FOFEXTERNALRATIO  DECIMAL(7,4)  COMMENT  '',
  F_VALUELEVEL  DECIMAL(9,4)  COMMENT  '',
  C_SECONDCHECK  STRING  COMMENT  '',
  F_ORIINCOME  DECIMAL(16,2)  COMMENT  '',
  C_PROFITBUDGETFLAG  STRING  COMMENT  '',
  D_EXPORTASSET07DATE  STRING  COMMENT  '',
  F_ADDASSET  DECIMAL(16,2)  COMMENT  '',
  F_REDUCEASSET  DECIMAL(16,2)  COMMENT  '',
  F_MAXRDMASSET  DECIMAL(16,2)  COMMENT  '',
  C_MAXRDMFLAG  STRING  COMMENT  '',
  F_RDMCFMRATIO  DECIMAL(11,8)  COMMENT  '',
  F_NETREDEEMRATIO  DECIMAL(9,8)  COMMENT  '',
  L_BATCHNO  DECIMAL(2,0)  COMMENT  '',
  F_NAVCHANGRATIO  DECIMAL(11,8)  COMMENT  '',
  F_UNASSETDISTRIBUTE  DECIMAL(11,2)  COMMENT  '',
  C_T0FUNDDAY  STRING  COMMENT  '',
  F_GROWTHRATE  DECIMAL(9,6)  COMMENT  '',
  D_ADVANCENPURDATE  STRING  COMMENT  '',
  D_ADVANCENRDMDATE  STRING  COMMENT  '',
  F_YEBINNTRUSTINCOME  DECIMAL(16,2)  COMMENT  '',
  C_CHECKNAVANDEXCELSTAT  STRING  COMMENT  '',
  C_STRUCTCAPTIALRATIOFLAG  STRING  COMMENT  '',
  F_NETLASTRATIO  DECIMAL(7,4)  COMMENT  '',
  F_RDMRATIO  DECIMAL(9,8)  COMMENT  '',
  C_ASSISTATUS  STRING  COMMENT  '',
  C_FUNDNAVEXP  STRING  COMMENT  '',
  D_FUNDNAVEXPDATE  STRING  COMMENT  '',
  C_ICDATA  STRING  COMMENT  '',
  C_MANUALMODIFY  STRING  COMMENT  '',
  C_MODMNGFARE  STRING  COMMENT  '',
  F_SHAREMANAGEFARE  DECIMAL(16,2)  COMMENT  '',
  F_TODAYALLASSET  DECIMAL(16,2)  COMMENT  ''
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
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
                                   , C_CHECK
                                   , F_INCOME
                                   , F_INCOMEUNIT
                                   , F_INCOMERATIO
                                   , F_UNASSIGN
                                   , F_TOTALNETVALUE
                                   , F_SERVICEFARE
                                   , F_ASSIGN
                                   , F_MANAGEFARE
                                   , F_PROTECTBALANCE
                                   , C_TODAYPCSSTATUS
                                   , C_TODAYCHGSTATUS
                                   , C_TODAYTRFSTATUS
                                   , C_TODAYSPLITSTATUS
                                   , D_EXPORTDATE
                                   , F_EXCHANGERATE
                                   , F_STRUCTUREDTOTALASSET
                                   , C_NETREDEEMORPURCHASEFLAG
                                   , F_YEBINCOME
                                   , F_YEBASSIGN
                                   , F_YEBUNASSIGN
                                   , F_OFFSETINCOME
                                   , F_QINCOMERATIO
                                   , C_PERMITDEAL
                                   , D_FILEDATE
                                   , C_ISNEEDCALCRDMFEE
                                   , F_CROSSTALASTSHARES
                                   , F_CROSSTALASTASSET
                                   , F_EXRIGHTPRICE
                                   , F_INDEXPRICE
                                   , F_JANINCOMERATIO
                                   , F_MARINCOMERATIO
                                   , F_HALFINCOMERATIO
                                   , F_YEARINCOMERATIO
                                   , F_JANAVGINCOMERATIO
                                   , F_MARAVGINCOMERATIO
                                   , F_HALFAVGINCOMERATIO
                                   , F_YEARAVGINCOMERATIO
                                   , C_ACCOUNTLOWLIMIT
                                   , C_ASSETLOWLIMIT
                                   , L_ACCOCOUNT
                                   , C_WATERMARKEXCEPT
                                   , F_FOFEXTERNALRATIO
                                   , F_VALUELEVEL
                                   , C_SECONDCHECK
                                   , F_ORIINCOME
                                   , C_PROFITBUDGETFLAG
                                   , D_EXPORTASSET07DATE
                                   , F_ADDASSET
                                   , F_REDUCEASSET
                                   , F_MAXRDMASSET
                                   , C_MAXRDMFLAG
                                   , F_RDMCFMRATIO
                                   , F_NETREDEEMRATIO
                                   , L_BATCHNO
                                   , F_NAVCHANGRATIO
                                   , F_UNASSETDISTRIBUTE
                                   , C_T0FUNDDAY
                                   , F_GROWTHRATE
                                   , D_ADVANCENPURDATE
                                   , D_ADVANCENRDMDATE
                                   , F_YEBINNTRUSTINCOME
                                   , C_CHECKNAVANDEXCELSTAT
                                   , C_STRUCTCAPTIALRATIOFLAG
                                   , F_NETLASTRATIO
                                   , F_RDMRATIO
                                   , C_ASSISTATUS
                                   , C_FUNDNAVEXP
                                   , D_FUNDNAVEXPDATE
                                   , C_ICDATA
                                   , C_MANUALMODIFY
                                   , C_MODMNGFARE
                                   , F_SHAREMANAGEFARE
                                   , F_TODAYALLASSET
                                FROM ${hszta_src_schema}.TFUNDDAY"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_DATE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_TODAYSTATUS", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_LASTSHARES", "type": "DOUBLE"}, {"name": "F_LASTASSET", "type": "DOUBLE"}, {"name": "F_ASUCCEED", "type": "DOUBLE"}, {"name": "F_RSUCCEED", "type": "DOUBLE"}, {"name": "C_VASTFLAG", "type": "STRING"}, {"name": "F_ENCASHRATIO", "type": "DOUBLE"}, {"name": "F_CHANGERATIO", "type": "DOUBLE"}, {"name": "C_EXCESSFLAG", "type": "STRING"}, {"name": "F_SUBSCRIBERATIO", "type": "DOUBLE"}, {"name": "C_INPUTPERSONNEL", "type": "STRING"}, {"name": "C_CHECKPERSONNEL", "type": "STRING"}, {"name": "C_CHECK", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_INCOMEUNIT", "type": "DOUBLE"}, {"name": "F_INCOMERATIO", "type": "DOUBLE"}, {"name": "F_UNASSIGN", "type": "DOUBLE"}, {"name": "F_TOTALNETVALUE", "type": "DOUBLE"}, {"name": "F_SERVICEFARE", "type": "DOUBLE"}, {"name": "F_ASSIGN", "type": "DOUBLE"}, {"name": "F_MANAGEFARE", "type": "DOUBLE"}, {"name": "F_PROTECTBALANCE", "type": "DOUBLE"}, {"name": "C_TODAYPCSSTATUS", "type": "STRING"}, {"name": "C_TODAYCHGSTATUS", "type": "STRING"}, {"name": "C_TODAYTRFSTATUS", "type": "STRING"}, {"name": "C_TODAYSPLITSTATUS", "type": "STRING"}, {"name": "D_EXPORTDATE", "type": "STRING"}, {"name": "F_EXCHANGERATE", "type": "DOUBLE"}, {"name": "F_STRUCTUREDTOTALASSET", "type": "DOUBLE"}, {"name": "C_NETREDEEMORPURCHASEFLAG", "type": "STRING"}, {"name": "F_YEBINCOME", "type": "DOUBLE"}, {"name": "F_YEBASSIGN", "type": "DOUBLE"}, {"name": "F_YEBUNASSIGN", "type": "DOUBLE"}, {"name": "F_OFFSETINCOME", "type": "DOUBLE"}, {"name": "F_QINCOMERATIO", "type": "DOUBLE"}, {"name": "C_PERMITDEAL", "type": "STRING"}, {"name": "D_FILEDATE", "type": "STRING"}, {"name": "C_ISNEEDCALCRDMFEE", "type": "STRING"}, {"name": "F_CROSSTALASTSHARES", "type": "DOUBLE"}, {"name": "F_CROSSTALASTASSET", "type": "DOUBLE"}, {"name": "F_EXRIGHTPRICE", "type": "DOUBLE"}, {"name": "F_INDEXPRICE", "type": "DOUBLE"}, {"name": "F_JANINCOMERATIO", "type": "DOUBLE"}, {"name": "F_MARINCOMERATIO", "type": "DOUBLE"}, {"name": "F_HALFINCOMERATIO", "type": "DOUBLE"}, {"name": "F_YEARINCOMERATIO", "type": "DOUBLE"}, {"name": "F_JANAVGINCOMERATIO", "type": "DOUBLE"}, {"name": "F_MARAVGINCOMERATIO", "type": "DOUBLE"}, {"name": "F_HALFAVGINCOMERATIO", "type": "DOUBLE"}, {"name": "F_YEARAVGINCOMERATIO", "type": "DOUBLE"}, {"name": "C_ACCOUNTLOWLIMIT", "type": "STRING"}, {"name": "C_ASSETLOWLIMIT", "type": "STRING"}, {"name": "L_ACCOCOUNT", "type": "DOUBLE"}, {"name": "C_WATERMARKEXCEPT", "type": "STRING"}, {"name": "F_FOFEXTERNALRATIO", "type": "DOUBLE"}, {"name": "F_VALUELEVEL", "type": "DOUBLE"}, {"name": "C_SECONDCHECK", "type": "STRING"}, {"name": "F_ORIINCOME", "type": "DOUBLE"}, {"name": "C_PROFITBUDGETFLAG", "type": "STRING"}, {"name": "D_EXPORTASSET07DATE", "type": "STRING"}, {"name": "F_ADDASSET", "type": "DOUBLE"}, {"name": "F_REDUCEASSET", "type": "DOUBLE"}, {"name": "F_MAXRDMASSET", "type": "DOUBLE"}, {"name": "C_MAXRDMFLAG", "type": "STRING"}, {"name": "F_RDMCFMRATIO", "type": "DOUBLE"}, {"name": "F_NETREDEEMRATIO", "type": "DOUBLE"}, {"name": "L_BATCHNO", "type": "DOUBLE"}, {"name": "F_NAVCHANGRATIO", "type": "DOUBLE"}, {"name": "F_UNASSETDISTRIBUTE", "type": "DOUBLE"}, {"name": "C_T0FUNDDAY", "type": "STRING"}, {"name": "F_GROWTHRATE", "type": "DOUBLE"}, {"name": "D_ADVANCENPURDATE", "type": "STRING"}, {"name": "D_ADVANCENRDMDATE", "type": "STRING"}, {"name": "F_YEBINNTRUSTINCOME", "type": "DOUBLE"}, {"name": "C_CHECKNAVANDEXCELSTAT", "type": "STRING"}, {"name": "C_STRUCTCAPTIALRATIOFLAG", "type": "STRING"}, {"name": "F_NETLASTRATIO", "type": "DOUBLE"}, {"name": "F_RDMRATIO", "type": "DOUBLE"}, {"name": "C_ASSISTATUS", "type": "STRING"}, {"name": "C_FUNDNAVEXP", "type": "STRING"}, {"name": "D_FUNDNAVEXPDATE", "type": "STRING"}, {"name": "C_ICDATA", "type": "STRING"}, {"name": "C_MANUALMODIFY", "type": "STRING"}, {"name": "C_MODMNGFARE", "type": "STRING"}, {"name": "F_SHAREMANAGEFARE", "type": "DOUBLE"}, {"name": "F_TODAYALLASSET", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tfundday_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tfundday_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tfundday_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tfundday_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TFUNDDAY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TFUNDDAY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tfundday_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDDAY_PFD PARTITION(P_DT='${p_end_dt}')
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
     , C_CHECK
     , F_INCOME
     , F_INCOMEUNIT
     , F_INCOMERATIO
     , F_UNASSIGN
     , F_TOTALNETVALUE
     , F_SERVICEFARE
     , F_ASSIGN
     , F_MANAGEFARE
     , F_PROTECTBALANCE
     , C_TODAYPCSSTATUS
     , C_TODAYCHGSTATUS
     , C_TODAYTRFSTATUS
     , C_TODAYSPLITSTATUS
     , D_EXPORTDATE
     , F_EXCHANGERATE
     , F_STRUCTUREDTOTALASSET
     , C_NETREDEEMORPURCHASEFLAG
     , F_YEBINCOME
     , F_YEBASSIGN
     , F_YEBUNASSIGN
     , F_OFFSETINCOME
     , F_QINCOMERATIO
     , C_PERMITDEAL
     , D_FILEDATE
     , C_ISNEEDCALCRDMFEE
     , F_CROSSTALASTSHARES
     , F_CROSSTALASTASSET
     , F_EXRIGHTPRICE
     , F_INDEXPRICE
     , F_JANINCOMERATIO
     , F_MARINCOMERATIO
     , F_HALFINCOMERATIO
     , F_YEARINCOMERATIO
     , F_JANAVGINCOMERATIO
     , F_MARAVGINCOMERATIO
     , F_HALFAVGINCOMERATIO
     , F_YEARAVGINCOMERATIO
     , C_ACCOUNTLOWLIMIT
     , C_ASSETLOWLIMIT
     , L_ACCOCOUNT
     , C_WATERMARKEXCEPT
     , F_FOFEXTERNALRATIO
     , F_VALUELEVEL
     , C_SECONDCHECK
     , F_ORIINCOME
     , C_PROFITBUDGETFLAG
     , D_EXPORTASSET07DATE
     , F_ADDASSET
     , F_REDUCEASSET
     , F_MAXRDMASSET
     , C_MAXRDMFLAG
     , F_RDMCFMRATIO
     , F_NETREDEEMRATIO
     , L_BATCHNO
     , F_NAVCHANGRATIO
     , F_UNASSETDISTRIBUTE
     , C_T0FUNDDAY
     , F_GROWTHRATE
     , D_ADVANCENPURDATE
     , D_ADVANCENRDMDATE
     , F_YEBINNTRUSTINCOME
     , C_CHECKNAVANDEXCELSTAT
     , C_STRUCTCAPTIALRATIOFLAG
     , F_NETLASTRATIO
     , F_RDMRATIO
     , C_ASSISTATUS
     , C_FUNDNAVEXP
     , D_FUNDNAVEXPDATE
     , C_ICDATA
     , C_MANUALMODIFY
     , C_MODMNGFARE
     , F_SHAREMANAGEFARE
     , F_TODAYALLASSET
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDDAY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDDAY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TFUNDDAY_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TFUNDDAY_PFD成功"
      exit 0
   fi
fi
