#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITCURRENTS_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITCURRENTS_PTD_TMP(
  C_BUSINFLAG  STRING  COMMENT  '业务类别',
  C_PROFITFLAG  STRING  COMMENT  '计提业绩报酬',
  D_CDATE  STRING  COMMENT  '拆分处理日期',
  C_CSERIALNO  STRING  COMMENT  '',
  C_CSERIALNOTOTAL  STRING  COMMENT  '',
  C_FUNDACCO  STRING  COMMENT  '限制的基金账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_AGENCYNO  STRING  COMMENT  '销售商',
  C_NETNO  STRING  COMMENT  '网点号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  D_DATE  STRING  COMMENT  '登记日期',
  L_SERIALNO  DECIMAL(10,0)  COMMENT  '',
  D_ORIGINALDATE  STRING  COMMENT  '',
  C_ORIGINALNO  STRING  COMMENT  '',
  D_REGISTDATE  STRING  COMMENT  '',
  F_CONFBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_CONFSHARES  DECIMAL(16,2)  COMMENT  '',
  F_TRADEFARE  DECIMAL(16,2)  COMMENT  '',
  F_TAFARE  DECIMAL(16,2)  COMMENT  '',
  F_STAMPTAX  DECIMAL(16,2)  COMMENT  '',
  F_BACKFARE  DECIMAL(16,2)  COMMENT  '',
  F_OTHERFARE1  DECIMAL(16,2)  COMMENT  '',
  F_BEGINASSET  DECIMAL(16,2)  COMMENT  '',
  F_ENDASSET  DECIMAL(16,2)  COMMENT  '',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '拆分后净值',
  F_TOTALNETVALUE  DECIMAL(16,8)  COMMENT  '',
  F_CURRATIO  DECIMAL(11,8)  COMMENT  '',
  F_YEARRATIO  DECIMAL(11,8)  COMMENT  '',
  F_PROTECTRATIO  DECIMAL(11,8)  COMMENT  '',
  F_MANAGERFARE  DECIMAL(16,2)  COMMENT  '',
  F_PROFITBACKFARE  DECIMAL(16,2)  COMMENT  '',
  F_DEDUCTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_FACTDEDUCTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_FACTDEDUCTSHARES  DECIMAL(16,2)  COMMENT  '',
  F_BONUSBALANCE  DECIMAL(16,2)  COMMENT  '',
  D_BEGINDATE  STRING  COMMENT  '启用日期',
  L_HOLD  DECIMAL(5,0)  COMMENT  '',
  C_CALCONLY  STRING  COMMENT  '是否为试算方案',
  F_DATUMYIELDRATIO  DECIMAL(11,8)  COMMENT  '',
  F_VALUEADDEDFARE  DECIMAL(16,2)  COMMENT  '',
  F_FLOOR  DECIMAL(11,8)  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  C_UPGRADEFLAG  STRING  COMMENT  '是否参与升降级',
  F_UPGRADENETVALUE  DECIMAL(11,8)  COMMENT  '',
  F_UPGRADETOTALBONUS  DECIMAL(11,8)  COMMENT  '',
  F_DCTBGNNETVALUE  DECIMAL(17,14)  COMMENT  '',
  F_TOTALCASHUNITBONUS  DECIMAL(17,14)  COMMENT  '',
  F_TOTALUNITBONUS  DECIMAL(15,12)  COMMENT  '',
  F_COSTPRICE  DECIMAL(15,12)  COMMENT  '',
  F_AGENCYFARE  DECIMAL(16,2)  COMMENT  '',
  F_REGISTFARE  DECIMAL(16,2)  COMMENT  '',
  F_HISDEDUCTBALANCE  DECIMAL(16,2)  COMMENT  '',
  L_YEARDAYS  DECIMAL(10,0)  COMMENT  '尾随佣金年天数',
  C_DEDUCTFORMULA  STRING  COMMENT  '',
  C_TRYCALCFLAG  STRING  COMMENT  '',
  D_LASTARCHIVEDATE  STRING  COMMENT  '',
  F_TARGETRATIO  DECIMAL(11,8)  COMMENT  '',
  F_TRYCALCNETVALUE  DECIMAL(16,8)  COMMENT  '',
  F_EXCESSINCOME  DECIMAL(16,2)  COMMENT  ''
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_BUSINFLAG
                                   , C_PROFITFLAG
                                   , D_CDATE
                                   , C_CSERIALNO
                                   , C_CSERIALNOTOTAL
                                   , C_FUNDACCO
                                   , C_FUNDCODE
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_SHARETYPE
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , L_SERIALNO
                                   , D_ORIGINALDATE
                                   , C_ORIGINALNO
                                   , D_REGISTDATE
                                   , F_CONFBALANCE
                                   , F_CONFSHARES
                                   , F_TRADEFARE
                                   , F_TAFARE
                                   , F_STAMPTAX
                                   , F_BACKFARE
                                   , F_OTHERFARE1
                                   , F_BEGINASSET
                                   , F_ENDASSET
                                   , F_NETVALUE
                                   , F_TOTALNETVALUE
                                   , F_CURRATIO
                                   , F_YEARRATIO
                                   , F_PROTECTRATIO
                                   , F_MANAGERFARE
                                   , F_PROFITBACKFARE
                                   , F_DEDUCTBALANCE
                                   , F_FACTDEDUCTBALANCE
                                   , F_FACTDEDUCTSHARES
                                   , F_BONUSBALANCE
                                   , D_BEGINDATE
                                   , L_HOLD
                                   , C_CALCONLY
                                   , F_DATUMYIELDRATIO
                                   , F_VALUEADDEDFARE
                                   , F_FLOOR
                                   , C_SUBFUNDCODE
                                   , C_UPGRADEFLAG
                                   , F_UPGRADENETVALUE
                                   , F_UPGRADETOTALBONUS
                                   , F_DCTBGNNETVALUE
                                   , F_TOTALCASHUNITBONUS
                                   , F_TOTALUNITBONUS
                                   , F_COSTPRICE
                                   , F_AGENCYFARE
                                   , F_REGISTFARE
                                   , F_HISDEDUCTBALANCE
                                   , L_YEARDAYS
                                   , C_DEDUCTFORMULA
                                   , C_TRYCALCFLAG
                                   , D_LASTARCHIVEDATE
                                   , F_TARGETRATIO
                                   , F_TRYCALCNETVALUE
                                   , F_EXCESSINCOME
                                FROM ${hsfta_src_schema}.TPROFITCURRENTS
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "C_PROFITFLAG", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_CSERIALNOTOTAL", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "L_SERIALNO", "type": "DOUBLE"}, {"name": "D_ORIGINALDATE", "type": "STRING"}, {"name": "C_ORIGINALNO", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "F_CONFBALANCE", "type": "DOUBLE"}, {"name": "F_CONFSHARES", "type": "DOUBLE"}, {"name": "F_TRADEFARE", "type": "DOUBLE"}, {"name": "F_TAFARE", "type": "DOUBLE"}, {"name": "F_STAMPTAX", "type": "DOUBLE"}, {"name": "F_BACKFARE", "type": "DOUBLE"}, {"name": "F_OTHERFARE1", "type": "DOUBLE"}, {"name": "F_BEGINASSET", "type": "DOUBLE"}, {"name": "F_ENDASSET", "type": "DOUBLE"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_TOTALNETVALUE", "type": "DOUBLE"}, {"name": "F_CURRATIO", "type": "DOUBLE"}, {"name": "F_YEARRATIO", "type": "DOUBLE"}, {"name": "F_PROTECTRATIO", "type": "DOUBLE"}, {"name": "F_MANAGERFARE", "type": "DOUBLE"}, {"name": "F_PROFITBACKFARE", "type": "DOUBLE"}, {"name": "F_DEDUCTBALANCE", "type": "DOUBLE"}, {"name": "F_FACTDEDUCTBALANCE", "type": "DOUBLE"}, {"name": "F_FACTDEDUCTSHARES", "type": "DOUBLE"}, {"name": "F_BONUSBALANCE", "type": "DOUBLE"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "L_HOLD", "type": "DOUBLE"}, {"name": "C_CALCONLY", "type": "STRING"}, {"name": "F_DATUMYIELDRATIO", "type": "DOUBLE"}, {"name": "F_VALUEADDEDFARE", "type": "DOUBLE"}, {"name": "F_FLOOR", "type": "DOUBLE"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "C_UPGRADEFLAG", "type": "STRING"}, {"name": "F_UPGRADENETVALUE", "type": "DOUBLE"}, {"name": "F_UPGRADETOTALBONUS", "type": "DOUBLE"}, {"name": "F_DCTBGNNETVALUE", "type": "DOUBLE"}, {"name": "F_TOTALCASHUNITBONUS", "type": "DOUBLE"}, {"name": "F_TOTALUNITBONUS", "type": "DOUBLE"}, {"name": "F_COSTPRICE", "type": "DOUBLE"}, {"name": "F_AGENCYFARE", "type": "DOUBLE"}, {"name": "F_REGISTFARE", "type": "DOUBLE"}, {"name": "F_HISDEDUCTBALANCE", "type": "DOUBLE"}, {"name": "L_YEARDAYS", "type": "DOUBLE"}, {"name": "C_DEDUCTFORMULA", "type": "STRING"}, {"name": "C_TRYCALCFLAG", "type": "STRING"}, {"name": "D_LASTARCHIVEDATE", "type": "STRING"}, {"name": "F_TARGETRATIO", "type": "DOUBLE"}, {"name": "F_TRYCALCNETVALUE", "type": "DOUBLE"}, {"name": "F_EXCESSINCOME", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tprofitcurrents_ptd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tprofitcurrents_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tprofitcurrents_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tprofitcurrents_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TPROFITCURRENTS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TPROFITCURRENTS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tprofitcurrents_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITCURRENTS_PTD PARTITION(P_DT)
SELECT
       C_BUSINFLAG
     , C_PROFITFLAG
     , D_CDATE
     , C_CSERIALNO
     , C_CSERIALNOTOTAL
     , C_FUNDACCO
     , C_FUNDCODE
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_SHARETYPE
     , D_DATE
     , L_SERIALNO
     , D_ORIGINALDATE
     , C_ORIGINALNO
     , D_REGISTDATE
     , F_CONFBALANCE
     , F_CONFSHARES
     , F_TRADEFARE
     , F_TAFARE
     , F_STAMPTAX
     , F_BACKFARE
     , F_OTHERFARE1
     , F_BEGINASSET
     , F_ENDASSET
     , F_NETVALUE
     , F_TOTALNETVALUE
     , F_CURRATIO
     , F_YEARRATIO
     , F_PROTECTRATIO
     , F_MANAGERFARE
     , F_PROFITBACKFARE
     , F_DEDUCTBALANCE
     , F_FACTDEDUCTBALANCE
     , F_FACTDEDUCTSHARES
     , F_BONUSBALANCE
     , D_BEGINDATE
     , L_HOLD
     , C_CALCONLY
     , F_DATUMYIELDRATIO
     , F_VALUEADDEDFARE
     , F_FLOOR
     , C_SUBFUNDCODE
     , C_UPGRADEFLAG
     , F_UPGRADENETVALUE
     , F_UPGRADETOTALBONUS
     , F_DCTBGNNETVALUE
     , F_TOTALCASHUNITBONUS
     , F_TOTALUNITBONUS
     , F_COSTPRICE
     , F_AGENCYFARE
     , F_REGISTFARE
     , F_HISDEDUCTBALANCE
     , L_YEARDAYS
     , C_DEDUCTFORMULA
     , C_TRYCALCFLAG
     , D_LASTARCHIVEDATE
     , F_TARGETRATIO
     , F_TRYCALCNETVALUE
     , F_EXCESSINCOME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITCURRENTS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITCURRENTS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TPROFITCURRENTS_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TPROFITCURRENTS_PTD成功"
      exit 0
   fi
fi
