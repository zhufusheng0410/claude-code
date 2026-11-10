#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITCURRENTS_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITCURRENTS_PTD_TMP(
  C_BUSINFLAG  STRING  COMMENT  '业务类别',
  C_SORTFLAG  STRING  COMMENT  '',
  D_DATE  STRING  COMMENT  '登记日期',
  D_CDATE  STRING  COMMENT  '拆分处理日期',
  C_CSERIALNO  STRING  COMMENT  '',
  C_CSERIALNOTOTAL  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '限制的基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商',
  C_NETNO  STRING  COMMENT  '网点号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  D_REGISTDATE  STRING  COMMENT  '',
  F_SHARES  DECIMAL(16,2)  COMMENT  '',
  D_BEGINDATE  STRING  COMMENT  '启用日期',
  F_ORINAV  DECIMAL(16,8)  COMMENT  '',
  F_ORITOTALNAV  DECIMAL(16,8)  COMMENT  '',
  F_NAV  DECIMAL(16,8)  COMMENT  '',
  F_TOTALNAV  DECIMAL(16,8)  COMMENT  '',
  F_CURRRATIO  DECIMAL(11,8)  COMMENT  '',
  F_YEARRATIO  DECIMAL(11,8)  COMMENT  '',
  F_STANDARDRATIO  DECIMAL(11,8)  COMMENT  '比较基准收益率(%)',
  F_DEDUCTMNGFARE  DECIMAL(16,2)  COMMENT  '',
  F_RETURNFARE  DECIMAL(16,2)  COMMENT  '',
  F_ORIBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_FACTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_FACTSHARES  DECIMAL(16,2)  COMMENT  '',
  F_BONUSBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_CALCONLY  STRING  COMMENT  '是否为试算方案',
  C_ORICSERIALNO  STRING  COMMENT  '',
  L_HOLD  DECIMAL(10,0)  COMMENT  '',
  C_OUTFUNDCODE  STRING  COMMENT  '对外基金代码',
  F_EXPECTEDBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_INCOME  DECIMAL(16,2)  COMMENT  '',
  F_DEDUCTRATIO  DECIMAL(9,8)  COMMENT  '',
  F_VALUEADDEDFARE  DECIMAL(16,2)  COMMENT  '',
  C_SECONDACCO  STRING  COMMENT  '强增账户的二级账号',
  F_TOTALUNITBONUS  DECIMAL(20,12)  COMMENT  '',
  F_COSTPRICE  DECIMAL(20,12)  COMMENT  '',
  C_OTHERCODE  STRING  COMMENT  '转换入基金',
  C_OTHERSHARE  STRING  COMMENT  '转换入份额类别',
  C_FLAG  STRING  COMMENT  '是否已经发起',
  F_INDEXYEARRATIO  DECIMAL(11,8)  COMMENT  '',
  F_LASTDEDUCTASSET  DECIMAL(16,2)  COMMENT  '',
  F_NEWASSET  DECIMAL(16,2)  COMMENT  '',
  F_PROFITBALANCE4AGT  DECIMAL(16,2)  COMMENT  '',
  F_BEGININDEXPRICE  DECIMAL(21,8)  COMMENT  '',
  F_ENDINDEXPRICE  DECIMAL(21,8)  COMMENT  '',
  F_INDEXCURRATIO  DECIMAL(11,8)  COMMENT  '',
  F_BEGINDEXCHANGERATE  DECIMAL(7,4)  COMMENT  '',
  F_ENDEXCHANGERATE  DECIMAL(7,4)  COMMENT  '',
  L_BATCHNO  DECIMAL(2,0)  COMMENT  '',
  D_BEGINNETVALUEDATE  STRING  COMMENT  '',
  D_ENDNETVALUEDATE  STRING  COMMENT  '',
  D_LASTPROFITDATE  STRING  COMMENT  '',
  F_LASTDECUCTYRATIO  DECIMAL(11,8)  COMMENT  '',
  C_ORISOURCE  STRING  COMMENT  '',
  L_HOLDWORKDAYS  DECIMAL(10,0)  COMMENT  '',
  L_YEARWORKDAYS  DECIMAL(10,0)  COMMENT  '',
  C_METHOD  STRING  COMMENT  '',
  F_OVERPROFIT  DECIMAL(16,2)  COMMENT  '',
  F_PROFITBALANCE4ATTEND  DECIMAL(16,2)  COMMENT  '',
  D_ORIDATE  STRING  COMMENT  '',
  F_INDEXCURRATIOADJUST  DECIMAL(11,8)  COMMENT  '',
  F_HISDEDUCTBALANCE  DECIMAL(16,2)  COMMENT  '',
  C_DEDUCTFORMULA  STRING  COMMENT  '',
  D_HOLDENDDATE  STRING  COMMENT  '',
  F_FAOVERPROFIT  DECIMAL(16,2)  COMMENT  '',
  F_FAMGRFEE  DECIMAL(16,2)  COMMENT  '',
  C_BREACHFLAG  STRING  COMMENT  '',
  F_BEDISCOUNTFACTBAL  DECIMAL(16,2)  COMMENT  '',
  C_GETSERIAL  STRING  COMMENT  '',
  F_STARTMARKUPLIMITKI  DECIMAL(16,2)  COMMENT  '',
  F_CONFBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_PFTBAL2MACCO  DECIMAL(16,6)  COMMENT  '',
  F_PROFITDISCOUNT  DECIMAL(5,4)  COMMENT  '',
  F_HOPECURNAV  DECIMAL(16,8)  COMMENT  '',
  F_HOPECURRRATIO  DECIMAL(11,8)  COMMENT  '',
  F_HOPEYEARRATIO  DECIMAL(11,8)  COMMENT  '',
  F_REGCRATIO  DECIMAL(11,8)  COMMENT  '',
  F_REGYRATIO  DECIMAL(11,8)  COMMENT  '',
  L_REGHOLD  DECIMAL(10,0)  COMMENT  ''
)
COMMENT '业绩提成保底处理流水'
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
                                   , C_SORTFLAG
                                   , D_DATE
                                   , D_CDATE
                                   , C_CSERIALNO
                                   , C_CSERIALNOTOTAL
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , D_REGISTDATE
                                   , F_SHARES
                                   , D_BEGINDATE
                                   , F_ORINAV
                                   , F_ORITOTALNAV
                                   , F_NAV
                                   , F_TOTALNAV
                                   , F_CURRRATIO
                                   , F_YEARRATIO
                                   , F_STANDARDRATIO
                                   , F_DEDUCTMNGFARE
                                   , F_RETURNFARE
                                   , F_ORIBALANCE
                                   , F_FACTBALANCE
                                   , F_FACTSHARES
                                   , F_BONUSBALANCE
                                   , C_CALCONLY
                                   , C_ORICSERIALNO
                                   , L_HOLD
                                   , C_OUTFUNDCODE
                                   , F_EXPECTEDBALANCE
                                   , F_INCOME
                                   , F_DEDUCTRATIO
                                   , F_VALUEADDEDFARE
                                   , C_SECONDACCO
                                   , F_TOTALUNITBONUS
                                   , F_COSTPRICE
                                   , C_OTHERCODE
                                   , C_OTHERSHARE
                                   , C_FLAG
                                   , F_INDEXYEARRATIO
                                   , F_LASTDEDUCTASSET
                                   , F_NEWASSET
                                   , F_PROFITBALANCE4AGT
                                   , F_BEGININDEXPRICE
                                   , F_ENDINDEXPRICE
                                   , F_INDEXCURRATIO
                                   , F_BEGINDEXCHANGERATE
                                   , F_ENDEXCHANGERATE
                                   , L_BATCHNO
                                   , D_BEGINNETVALUEDATE
                                   , D_ENDNETVALUEDATE
                                   , D_LASTPROFITDATE
                                   , F_LASTDECUCTYRATIO
                                   , C_ORISOURCE
                                   , L_HOLDWORKDAYS
                                   , L_YEARWORKDAYS
                                   , C_METHOD
                                   , F_OVERPROFIT
                                   , F_PROFITBALANCE4ATTEND
                                   , D_ORIDATE
                                   , F_INDEXCURRATIOADJUST
                                   , F_HISDEDUCTBALANCE
                                   , C_DEDUCTFORMULA
                                   , D_HOLDENDDATE
                                   , F_FAOVERPROFIT
                                   , F_FAMGRFEE
                                   , C_BREACHFLAG
                                   , F_BEDISCOUNTFACTBAL
                                   , C_GETSERIAL
                                   , F_STARTMARKUPLIMITKI
                                   , F_CONFBALANCE
                                   , F_PFTBAL2MACCO
                                   , F_PROFITDISCOUNT
                                   , F_HOPECURNAV
                                   , F_HOPECURRRATIO
                                   , F_HOPEYEARRATIO
                                   , F_REGCRATIO
                                   , F_REGYRATIO
                                   , L_REGHOLD
                                FROM ${hszta_src_schema}.TPROFITCURRENTS
                                WHERE D_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "C_SORTFLAG", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_CSERIALNOTOTAL", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "F_SHARES", "type": "DOUBLE"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "F_ORINAV", "type": "DOUBLE"}, {"name": "F_ORITOTALNAV", "type": "DOUBLE"}, {"name": "F_NAV", "type": "DOUBLE"}, {"name": "F_TOTALNAV", "type": "DOUBLE"}, {"name": "F_CURRRATIO", "type": "DOUBLE"}, {"name": "F_YEARRATIO", "type": "DOUBLE"}, {"name": "F_STANDARDRATIO", "type": "DOUBLE"}, {"name": "F_DEDUCTMNGFARE", "type": "DOUBLE"}, {"name": "F_RETURNFARE", "type": "DOUBLE"}, {"name": "F_ORIBALANCE", "type": "DOUBLE"}, {"name": "F_FACTBALANCE", "type": "DOUBLE"}, {"name": "F_FACTSHARES", "type": "DOUBLE"}, {"name": "F_BONUSBALANCE", "type": "DOUBLE"}, {"name": "C_CALCONLY", "type": "STRING"}, {"name": "C_ORICSERIALNO", "type": "STRING"}, {"name": "L_HOLD", "type": "DOUBLE"}, {"name": "C_OUTFUNDCODE", "type": "STRING"}, {"name": "F_EXPECTEDBALANCE", "type": "DOUBLE"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_DEDUCTRATIO", "type": "DOUBLE"}, {"name": "F_VALUEADDEDFARE", "type": "DOUBLE"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "F_TOTALUNITBONUS", "type": "DOUBLE"}, {"name": "F_COSTPRICE", "type": "DOUBLE"}, {"name": "C_OTHERCODE", "type": "STRING"}, {"name": "C_OTHERSHARE", "type": "STRING"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "F_INDEXYEARRATIO", "type": "DOUBLE"}, {"name": "F_LASTDEDUCTASSET", "type": "DOUBLE"}, {"name": "F_NEWASSET", "type": "DOUBLE"}, {"name": "F_PROFITBALANCE4AGT", "type": "DOUBLE"}, {"name": "F_BEGININDEXPRICE", "type": "DOUBLE"}, {"name": "F_ENDINDEXPRICE", "type": "DOUBLE"}, {"name": "F_INDEXCURRATIO", "type": "DOUBLE"}, {"name": "F_BEGINDEXCHANGERATE", "type": "DOUBLE"}, {"name": "F_ENDEXCHANGERATE", "type": "DOUBLE"}, {"name": "L_BATCHNO", "type": "DOUBLE"}, {"name": "D_BEGINNETVALUEDATE", "type": "STRING"}, {"name": "D_ENDNETVALUEDATE", "type": "STRING"}, {"name": "D_LASTPROFITDATE", "type": "STRING"}, {"name": "F_LASTDECUCTYRATIO", "type": "DOUBLE"}, {"name": "C_ORISOURCE", "type": "STRING"}, {"name": "L_HOLDWORKDAYS", "type": "DOUBLE"}, {"name": "L_YEARWORKDAYS", "type": "DOUBLE"}, {"name": "C_METHOD", "type": "STRING"}, {"name": "F_OVERPROFIT", "type": "DOUBLE"}, {"name": "F_PROFITBALANCE4ATTEND", "type": "DOUBLE"}, {"name": "D_ORIDATE", "type": "STRING"}, {"name": "F_INDEXCURRATIOADJUST", "type": "DOUBLE"}, {"name": "F_HISDEDUCTBALANCE", "type": "DOUBLE"}, {"name": "C_DEDUCTFORMULA", "type": "STRING"}, {"name": "D_HOLDENDDATE", "type": "STRING"}, {"name": "F_FAOVERPROFIT", "type": "DOUBLE"}, {"name": "F_FAMGRFEE", "type": "DOUBLE"}, {"name": "C_BREACHFLAG", "type": "STRING"}, {"name": "F_BEDISCOUNTFACTBAL", "type": "DOUBLE"}, {"name": "C_GETSERIAL", "type": "STRING"}, {"name": "F_STARTMARKUPLIMITKI", "type": "DOUBLE"}, {"name": "F_CONFBALANCE", "type": "DOUBLE"}, {"name": "F_PFTBAL2MACCO", "type": "DOUBLE"}, {"name": "F_PROFITDISCOUNT", "type": "DOUBLE"}, {"name": "F_HOPECURNAV", "type": "DOUBLE"}, {"name": "F_HOPECURRRATIO", "type": "DOUBLE"}, {"name": "F_HOPEYEARRATIO", "type": "DOUBLE"}, {"name": "F_REGCRATIO", "type": "DOUBLE"}, {"name": "F_REGYRATIO", "type": "DOUBLE"}, {"name": "L_REGHOLD", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tprofitcurrents_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tprofitcurrents_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tprofitcurrents_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tprofitcurrents_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TPROFITCURRENTS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TPROFITCURRENTS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tprofitcurrents_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITCURRENTS_PTD PARTITION(P_DT)
SELECT
       C_BUSINFLAG
     , C_SORTFLAG
     , D_DATE
     , D_CDATE
     , C_CSERIALNO
     , C_CSERIALNOTOTAL
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , D_REGISTDATE
     , F_SHARES
     , D_BEGINDATE
     , F_ORINAV
     , F_ORITOTALNAV
     , F_NAV
     , F_TOTALNAV
     , F_CURRRATIO
     , F_YEARRATIO
     , F_STANDARDRATIO
     , F_DEDUCTMNGFARE
     , F_RETURNFARE
     , F_ORIBALANCE
     , F_FACTBALANCE
     , F_FACTSHARES
     , F_BONUSBALANCE
     , C_CALCONLY
     , C_ORICSERIALNO
     , L_HOLD
     , C_OUTFUNDCODE
     , F_EXPECTEDBALANCE
     , F_INCOME
     , F_DEDUCTRATIO
     , F_VALUEADDEDFARE
     , C_SECONDACCO
     , F_TOTALUNITBONUS
     , F_COSTPRICE
     , C_OTHERCODE
     , C_OTHERSHARE
     , C_FLAG
     , F_INDEXYEARRATIO
     , F_LASTDEDUCTASSET
     , F_NEWASSET
     , F_PROFITBALANCE4AGT
     , F_BEGININDEXPRICE
     , F_ENDINDEXPRICE
     , F_INDEXCURRATIO
     , F_BEGINDEXCHANGERATE
     , F_ENDEXCHANGERATE
     , L_BATCHNO
     , D_BEGINNETVALUEDATE
     , D_ENDNETVALUEDATE
     , D_LASTPROFITDATE
     , F_LASTDECUCTYRATIO
     , C_ORISOURCE
     , L_HOLDWORKDAYS
     , L_YEARWORKDAYS
     , C_METHOD
     , F_OVERPROFIT
     , F_PROFITBALANCE4ATTEND
     , D_ORIDATE
     , F_INDEXCURRATIOADJUST
     , F_HISDEDUCTBALANCE
     , C_DEDUCTFORMULA
     , D_HOLDENDDATE
     , F_FAOVERPROFIT
     , F_FAMGRFEE
     , C_BREACHFLAG
     , F_BEDISCOUNTFACTBAL
     , C_GETSERIAL
     , F_STARTMARKUPLIMITKI
     , F_CONFBALANCE
     , F_PFTBAL2MACCO
     , F_PROFITDISCOUNT
     , F_HOPECURNAV
     , F_HOPECURRRATIO
     , F_HOPEYEARRATIO
     , F_REGCRATIO
     , F_REGYRATIO
     , L_REGHOLD
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_DATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITCURRENTS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITCURRENTS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TPROFITCURRENTS_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TPROFITCURRENTS_PTD成功"
      exit 0
   fi
fi
