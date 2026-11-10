#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_DINDICESFORVALUATION_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_DINDICESFORVALUATION_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  TRADINGDAY  STRING  COMMENT  '交易日',
  PE  DECIMAL(18,4)  COMMENT  '市盈率',
  PB  DECIMAL(18,4)  COMMENT  '市净率',
  PCF  DECIMAL(18,4)  COMMENT  '市现率',
  PS  DECIMAL(18,4)  COMMENT  '市销率',
  DIVIDENDRATIO  DECIMAL(9,6)  COMMENT  '股息率',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  PSTTM  DECIMAL(18,4)  COMMENT  '滚动市销率',
  TOTALMV  DECIMAL(19,4)  COMMENT  '总市值',
  NEGOTIABLEMV  DECIMAL(19,4)  COMMENT  '流通市值',
  PELYR  DECIMAL(18,4)  COMMENT  '',
  PCFTTM  DECIMAL(18,4)  COMMENT  '',
  PCFS  DECIMAL(18,4)  COMMENT  '',
  PCFSTTM  DECIMAL(18,4)  COMMENT  '',
  DIVIDENDRATIOLYR  DECIMAL(9,6)  COMMENT  '',
  ENTERPRISEVALUEW  DECIMAL(19,4)  COMMENT  '',
  ENTERPRISEVALUEN  DECIMAL(19,4)  COMMENT  '',
  INSERTTIME  STRING  COMMENT  '',
  TOTALMV2  DECIMAL(18,4)  COMMENT  '公司总市值',
  TOTALASMV  DECIMAL(18,4)  COMMENT  'A/B股总市值',
  PETTMCUT  DECIMAL(18,4)  COMMENT  '扣非后滚动市盈率',
  FORWARDPEQA  DECIMAL(18,4)  COMMENT  '动态市盈率_季度外推',
  FORWARDPEHR  DECIMAL(18,4)  COMMENT  '动态市盈率_历史占比',
  PEG  DECIMAL(18,4)  COMMENT  'PEG',
  PETTMTOORRATE  DECIMAL(18,4)  COMMENT  '滚动市盈率/营业收入三年复合增长率',
  FORWARDPCFQA  DECIMAL(18,4)  COMMENT  '动态市现率(经营现金流)_季度外推',
  FORWARDPCFHR  DECIMAL(18,4)  COMMENT  '动态市现率(经营现金流)_历史占比',
  FORWARDPCFSQA  DECIMAL(18,4)  COMMENT  '动态市现率(现金流净额)_季度外推',
  FORWARDPCFSHR  DECIMAL(18,4)  COMMENT  '动态市现率(现金流净额)_历史占比',
  FORWARDPSQA  DECIMAL(18,4)  COMMENT  '动态市销率_季度外推',
  FORWARDPSHR  DECIMAL(18,4)  COMMENT  '动态市销率_历史占比',
  DIVIDENDRATIOLYR2  DECIMAL(18,4)  COMMENT  '静态股息率(报告期)',
  DIVIDENDRATIO2  DECIMAL(18,4)  COMMENT  '滚动股息率(报告期)',
  EVTOEBITDA  DECIMAL(18,4)  COMMENT  '企业价值倍数(剔除货币资金)',
  EVTOOR  DECIMAL(18,4)  COMMENT  '企业价值(剔除货币资金)/营业收入',
  EVTOFCFF  DECIMAL(18,4)  COMMENT  '企业价值(剔除货币资金)/企业自由现金流',
  EVTOCFO  DECIMAL(18,4)  COMMENT  '企业价值(剔除货币资金)/经营现金流',
  EVTOGP  DECIMAL(18,4)  COMMENT  '企业价值(剔除货币资金)/毛利',
  PER  DECIMAL(18,4)  COMMENT  '总市值/研发支出前利润',
  EVTOEBITDARANDD  DECIMAL(18,4)  COMMENT  '企业价值(剔除货币资金)/(EBITDA+研发费用)',
  TOTALMVTORANDD  DECIMAL(18,4)  COMMENT  '市值/研发费用',
  MVA  DECIMAL(18,4)  COMMENT  '市场附加价值(MVA)(元)',
  FLOATMVA  DECIMAL(18,4)  COMMENT  '流通盘市场附加价值(元)',
  MARKETVALUETODEBT1  DECIMAL(18,4)  COMMENT  '总市值/总负债',
  MARKETVALUETODEBT2  DECIMAL(18,4)  COMMENT  '公司总市值/总负债',
  DEBTTOASSETVALUE1  DECIMAL(18,4)  COMMENT  '总负债/总资产市值',
  DEBTTOASSETVALUE2  DECIMAL(18,4)  COMMENT  '总负债/公司总资产市值',
  PBLF  DECIMAL(18,4)  COMMENT  '市净率LF'
)
COMMENT '公司估值分析日指标_新会计准则'
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
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , INNERCODE
                                   , TO_CHAR(TRADINGDAY,'YYYYMMDD') TRADINGDAY
                                   , PE
                                   , PB
                                   , PCF
                                   , PS
                                   , DIVIDENDRATIO
                                   , UPDATETIME
                                   , JSID
                                   , PSTTM
                                   , TOTALMV
                                   , NEGOTIABLEMV
                                   , PELYR
                                   , PCFTTM
                                   , PCFS
                                   , PCFSTTM
                                   , DIVIDENDRATIOLYR
                                   , ENTERPRISEVALUEW
                                   , ENTERPRISEVALUEN
                                   , INSERTTIME
                                   , TOTALMV2
                                   , TOTALASMV
                                   , PETTMCUT
                                   , FORWARDPEQA
                                   , FORWARDPEHR
                                   , PEG
                                   , PETTMTOORRATE
                                   , FORWARDPCFQA
                                   , FORWARDPCFHR
                                   , FORWARDPCFSQA
                                   , FORWARDPCFSHR
                                   , FORWARDPSQA
                                   , FORWARDPSHR
                                   , DIVIDENDRATIOLYR2
                                   , DIVIDENDRATIO2
                                   , EVTOEBITDA
                                   , EVTOOR
                                   , EVTOFCFF
                                   , EVTOCFO
                                   , EVTOGP
                                   , PER
                                   , EVTOEBITDARANDD
                                   , TOTALMVTORANDD
                                   , MVA
                                   , FLOATMVA
                                   , MARKETVALUETODEBT1
                                   , MARKETVALUETODEBT2
                                   , DEBTTOASSETVALUE1
                                   , DEBTTOASSETVALUE2
                                   , PBLF
                                FROM ${jy_src_schema}.LC_DINDICESFORVALUATION
                                WHERE TRADINGDAY between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "PE", "type": "DOUBLE"}, {"name": "PB", "type": "DOUBLE"}, {"name": "PCF", "type": "DOUBLE"}, {"name": "PS", "type": "DOUBLE"}, {"name": "DIVIDENDRATIO", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "PSTTM", "type": "DOUBLE"}, {"name": "TOTALMV", "type": "DOUBLE"}, {"name": "NEGOTIABLEMV", "type": "DOUBLE"}, {"name": "PELYR", "type": "DOUBLE"}, {"name": "PCFTTM", "type": "DOUBLE"}, {"name": "PCFS", "type": "DOUBLE"}, {"name": "PCFSTTM", "type": "DOUBLE"}, {"name": "DIVIDENDRATIOLYR", "type": "DOUBLE"}, {"name": "ENTERPRISEVALUEW", "type": "DOUBLE"}, {"name": "ENTERPRISEVALUEN", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "TOTALMV2", "type": "DOUBLE"}, {"name": "TOTALASMV", "type": "DOUBLE"}, {"name": "PETTMCUT", "type": "DOUBLE"}, {"name": "FORWARDPEQA", "type": "DOUBLE"}, {"name": "FORWARDPEHR", "type": "DOUBLE"}, {"name": "PEG", "type": "DOUBLE"}, {"name": "PETTMTOORRATE", "type": "DOUBLE"}, {"name": "FORWARDPCFQA", "type": "DOUBLE"}, {"name": "FORWARDPCFHR", "type": "DOUBLE"}, {"name": "FORWARDPCFSQA", "type": "DOUBLE"}, {"name": "FORWARDPCFSHR", "type": "DOUBLE"}, {"name": "FORWARDPSQA", "type": "DOUBLE"}, {"name": "FORWARDPSHR", "type": "DOUBLE"}, {"name": "DIVIDENDRATIOLYR2", "type": "DOUBLE"}, {"name": "DIVIDENDRATIO2", "type": "DOUBLE"}, {"name": "EVTOEBITDA", "type": "DOUBLE"}, {"name": "EVTOOR", "type": "DOUBLE"}, {"name": "EVTOFCFF", "type": "DOUBLE"}, {"name": "EVTOCFO", "type": "DOUBLE"}, {"name": "EVTOGP", "type": "DOUBLE"}, {"name": "PER", "type": "DOUBLE"}, {"name": "EVTOEBITDARANDD", "type": "DOUBLE"}, {"name": "TOTALMVTORANDD", "type": "DOUBLE"}, {"name": "MVA", "type": "DOUBLE"}, {"name": "FLOATMVA", "type": "DOUBLE"}, {"name": "MARKETVALUETODEBT1", "type": "DOUBLE"}, {"name": "MARKETVALUETODEBT2", "type": "DOUBLE"}, {"name": "DEBTTOASSETVALUE1", "type": "DOUBLE"}, {"name": "DEBTTOASSETVALUE2", "type": "DOUBLE"}, {"name": "PBLF", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_dindicesforvaluation_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_dindicesforvaluation_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_dindicesforvaluation_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_dindicesforvaluation_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_DINDICESFORVALUATION_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_DINDICESFORVALUATION_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_dindicesforvaluation_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_DINDICESFORVALUATION_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , TRADINGDAY
     , PE
     , PB
     , PCF
     , PS
     , DIVIDENDRATIO
     , UPDATETIME
     , JSID
     , PSTTM
     , TOTALMV
     , NEGOTIABLEMV
     , PELYR
     , PCFTTM
     , PCFS
     , PCFSTTM
     , DIVIDENDRATIOLYR
     , ENTERPRISEVALUEW
     , ENTERPRISEVALUEN
     , INSERTTIME
     , TOTALMV2
     , TOTALASMV
     , PETTMCUT
     , FORWARDPEQA
     , FORWARDPEHR
     , PEG
     , PETTMTOORRATE
     , FORWARDPCFQA
     , FORWARDPCFHR
     , FORWARDPCFSQA
     , FORWARDPCFSHR
     , FORWARDPSQA
     , FORWARDPSHR
     , DIVIDENDRATIOLYR2
     , DIVIDENDRATIO2
     , EVTOEBITDA
     , EVTOOR
     , EVTOFCFF
     , EVTOCFO
     , EVTOGP
     , PER
     , EVTOEBITDARANDD
     , TOTALMVTORANDD
     , MVA
     , FLOATMVA
     , MARKETVALUETODEBT1
     , MARKETVALUETODEBT2
     , DEBTTOASSETVALUE1
     , DEBTTOASSETVALUE2
     , PBLF
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(TRADINGDAY,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_LC_DINDICESFORVALUATION_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_DINDICESFORVALUATION_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_DINDICESFORVALUATION_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_DINDICESFORVALUATION_PTD成功"
      exit 0
   fi
fi
