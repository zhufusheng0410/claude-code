#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_QT_PERFORMANCEDATA_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_QT_PERFORMANCEDATA_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  TRADINGDAY  STRING  COMMENT  '交易日',
  CLOSEPRICE  DECIMAL(19,4)  COMMENT  '收盘价(元)',
  CHANGEPCT  DECIMAL(18,4)  COMMENT  '涨跌幅',
  BACKWARDPRICE  DECIMAL(19,4)  COMMENT  '后复权收盘价(元)',
  RISINGUPDAYS  DECIMAL(10,0)  COMMENT  '连涨天数',
  FALLINGDOWNDAYS  DECIMAL(10,0)  COMMENT  '连跌天数',
  MAXRISINGUPDAYS  DECIMAL(10,0)  COMMENT  '历史连涨最多天数',
  MAXFALLINGDOWNDAYS  DECIMAL(10,0)  COMMENT  '历史连跌最多天数',
  FALLONDEBUT  DECIMAL(10,0)  COMMENT  '是否破发',
  FALLONNAPS  DECIMAL(10,0)  COMMENT  '是否破净',
  AHPREMIUMRATE50  DECIMAL(10,0)  COMMENT  'AH溢价率是否大于50%',
  STOCKBOARD  DECIMAL(10,0)  COMMENT  '今日是否涨停一字板',
  LIMITBOARD  DECIMAL(10,0)  COMMENT  '今日是否跌停一字板',
  SURGEDLIMIT  DECIMAL(10,0)  COMMENT  '今日是否涨停股',
  DECLINELIMIT  DECIMAL(10,0)  COMMENT  '今日是否跌停股',
  HIGHESTPRICE  DECIMAL(10,0)  COMMENT  '最高价(人民币元/100外币)',
  LOWESTPRICE  DECIMAL(10,0)  COMMENT  '最低价(人民币元/100外币)',
  HIGHESTPRICERW  DECIMAL(10,0)  COMMENT  '是否近一周新高',
  LOWESTPRICERW  DECIMAL(10,0)  COMMENT  '是否近一周新低',
  HIGHESTPRICETW  DECIMAL(10,0)  COMMENT  '是否本周以来新高',
  LOWESTPRICETW  DECIMAL(10,0)  COMMENT  '是否本周以来新低',
  HIGHESTPRICERM  DECIMAL(10,0)  COMMENT  '是否近一月新高',
  LOWESTPRICERM  DECIMAL(10,0)  COMMENT  '是否近一月新低',
  HIGHESTPRICETM  DECIMAL(10,0)  COMMENT  '是否本月以来新高',
  LOWESTPRICETM  DECIMAL(10,0)  COMMENT  '是否本月以来新低',
  HIGHESTPRICER3M  DECIMAL(10,0)  COMMENT  '是否近三个月新高',
  LOWESTPRICER3M  DECIMAL(10,0)  COMMENT  '是否近三个月新低',
  HIGHESTPRICER6M  DECIMAL(10,0)  COMMENT  '是否近半年新高',
  LOWESTPRICER6M  DECIMAL(10,0)  COMMENT  '是否近半年新低',
  HIGHESTPRICEYTD  DECIMAL(10,0)  COMMENT  '是否今年以来新高',
  LOWESTPRICEYTD  DECIMAL(10,0)  COMMENT  '是否今年以来新低',
  HIGHESTPRICER12M  DECIMAL(10,0)  COMMENT  '是否近一年新高',
  LOWESTPRICER12M  DECIMAL(10,0)  COMMENT  '是否近一年新低',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '股票日行情表现'
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
                                   , CLOSEPRICE
                                   , CHANGEPCT
                                   , BACKWARDPRICE
                                   , RISINGUPDAYS
                                   , FALLINGDOWNDAYS
                                   , MAXRISINGUPDAYS
                                   , MAXFALLINGDOWNDAYS
                                   , FALLONDEBUT
                                   , FALLONNAPS
                                   , AHPREMIUMRATE50
                                   , STOCKBOARD
                                   , LIMITBOARD
                                   , SURGEDLIMIT
                                   , DECLINELIMIT
                                   , HIGHESTPRICE
                                   , LOWESTPRICE
                                   , HIGHESTPRICERW
                                   , LOWESTPRICERW
                                   , HIGHESTPRICETW
                                   , LOWESTPRICETW
                                   , HIGHESTPRICERM
                                   , LOWESTPRICERM
                                   , HIGHESTPRICETM
                                   , LOWESTPRICETM
                                   , HIGHESTPRICER3M
                                   , LOWESTPRICER3M
                                   , HIGHESTPRICER6M
                                   , LOWESTPRICER6M
                                   , HIGHESTPRICEYTD
                                   , LOWESTPRICEYTD
                                   , HIGHESTPRICER12M
                                   , LOWESTPRICER12M
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.QT_PERFORMANCEDATA
                                WHERE TRADINGDAY between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "CLOSEPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCT", "type": "DOUBLE"}, {"name": "BACKWARDPRICE", "type": "DOUBLE"}, {"name": "RISINGUPDAYS", "type": "DOUBLE"}, {"name": "FALLINGDOWNDAYS", "type": "DOUBLE"}, {"name": "MAXRISINGUPDAYS", "type": "DOUBLE"}, {"name": "MAXFALLINGDOWNDAYS", "type": "DOUBLE"}, {"name": "FALLONDEBUT", "type": "DOUBLE"}, {"name": "FALLONNAPS", "type": "DOUBLE"}, {"name": "AHPREMIUMRATE50", "type": "DOUBLE"}, {"name": "STOCKBOARD", "type": "DOUBLE"}, {"name": "LIMITBOARD", "type": "DOUBLE"}, {"name": "SURGEDLIMIT", "type": "DOUBLE"}, {"name": "DECLINELIMIT", "type": "DOUBLE"}, {"name": "HIGHESTPRICE", "type": "DOUBLE"}, {"name": "LOWESTPRICE", "type": "DOUBLE"}, {"name": "HIGHESTPRICERW", "type": "DOUBLE"}, {"name": "LOWESTPRICERW", "type": "DOUBLE"}, {"name": "HIGHESTPRICETW", "type": "DOUBLE"}, {"name": "LOWESTPRICETW", "type": "DOUBLE"}, {"name": "HIGHESTPRICERM", "type": "DOUBLE"}, {"name": "LOWESTPRICERM", "type": "DOUBLE"}, {"name": "HIGHESTPRICETM", "type": "DOUBLE"}, {"name": "LOWESTPRICETM", "type": "DOUBLE"}, {"name": "HIGHESTPRICER3M", "type": "DOUBLE"}, {"name": "LOWESTPRICER3M", "type": "DOUBLE"}, {"name": "HIGHESTPRICER6M", "type": "DOUBLE"}, {"name": "LOWESTPRICER6M", "type": "DOUBLE"}, {"name": "HIGHESTPRICEYTD", "type": "DOUBLE"}, {"name": "LOWESTPRICEYTD", "type": "DOUBLE"}, {"name": "HIGHESTPRICER12M", "type": "DOUBLE"}, {"name": "LOWESTPRICER12M", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_qt_performancedata_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_qt_performancedata_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_qt_performancedata_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_qt_performancedata_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_QT_PERFORMANCEDATA_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_QT_PERFORMANCEDATA_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_qt_performancedata_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_QT_PERFORMANCEDATA_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , TRADINGDAY
     , CLOSEPRICE
     , CHANGEPCT
     , BACKWARDPRICE
     , RISINGUPDAYS
     , FALLINGDOWNDAYS
     , MAXRISINGUPDAYS
     , MAXFALLINGDOWNDAYS
     , FALLONDEBUT
     , FALLONNAPS
     , AHPREMIUMRATE50
     , STOCKBOARD
     , LIMITBOARD
     , SURGEDLIMIT
     , DECLINELIMIT
     , HIGHESTPRICE
     , LOWESTPRICE
     , HIGHESTPRICERW
     , LOWESTPRICERW
     , HIGHESTPRICETW
     , LOWESTPRICETW
     , HIGHESTPRICERM
     , LOWESTPRICERM
     , HIGHESTPRICETM
     , LOWESTPRICETM
     , HIGHESTPRICER3M
     , LOWESTPRICER3M
     , HIGHESTPRICER6M
     , LOWESTPRICER6M
     , HIGHESTPRICEYTD
     , LOWESTPRICEYTD
     , HIGHESTPRICER12M
     , LOWESTPRICER12M
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(TRADINGDAY,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_QT_PERFORMANCEDATA_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_QT_PERFORMANCEDATA_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_QT_PERFORMANCEDATA_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_QT_PERFORMANCEDATA_PTD成功"
      exit 0
   fi
fi
