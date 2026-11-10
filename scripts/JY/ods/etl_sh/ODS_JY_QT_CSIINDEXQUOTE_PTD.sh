#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_QT_CSIINDEXQUOTE_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_QT_CSIINDEXQUOTE_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INDEXCODE  STRING  COMMENT  '指数代码',
  INDEXCSITYPE  DECIMAL(10,0)  COMMENT  '中证指数类别',
  TRADINGDAY  STRING  COMMENT  '交易日',
  OPENPRICE  DECIMAL(19,4)  COMMENT  '今开盘(元)',
  HIGHPRICE  DECIMAL(19,4)  COMMENT  '最高价(元)',
  LOWPRICE  DECIMAL(19,4)  COMMENT  '最低价(元)',
  CLOSEPRICE  DECIMAL(19,4)  COMMENT  '收盘价(元)',
  TURNOVERVOLUME  DECIMAL(19,2)  COMMENT  '成交量(股)',
  TURNOVERVALUE  DECIMAL(19,2)  COMMENT  '成交金额(元)',
  OPENINTEREST  DECIMAL(19,2)  COMMENT  '持仓量(手)',
  SETTLEVALUE  DECIMAL(19,4)  COMMENT  '资金清算额(元)',
  CHANGEOF  DECIMAL(19,4)  COMMENT  '日涨跌',
  CHANGEPCT  DECIMAL(19,4)  COMMENT  '涨跌幅',
  TOTALMV  DECIMAL(19,4)  COMMENT  '总市值',
  INDEXPERATIO1  DECIMAL(19,4)  COMMENT  '指数市盈率(I)',
  INDEXPERATIO2  DECIMAL(19,4)  COMMENT  '指数市盈率(II)',
  INDEXDYRATIO1  DECIMAL(19,4)  COMMENT  '指数股息率(I)',
  INDEXDYRATIO2  DECIMAL(19,4)  COMMENT  '指数股息率(II)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  PREVCLOSEPRICE  DECIMAL(19,4)  COMMENT  '昨收盘(元/点)'
)
COMMENT '中证指数行情'
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
                                   , INDEXCODE
                                   , INDEXCSITYPE
                                   , TO_CHAR(TRADINGDAY,'YYYYMMDD') TRADINGDAY
                                   , OPENPRICE
                                   , HIGHPRICE
                                   , LOWPRICE
                                   , CLOSEPRICE
                                   , TURNOVERVOLUME
                                   , TURNOVERVALUE
                                   , OPENINTEREST
                                   , SETTLEVALUE
                                   , CHANGEOF
                                   , CHANGEPCT
                                   , TOTALMV
                                   , INDEXPERATIO1
                                   , INDEXPERATIO2
                                   , INDEXDYRATIO1
                                   , INDEXDYRATIO2
                                   , UPDATETIME
                                   , JSID
                                   , PREVCLOSEPRICE
                                FROM ${jy_src_schema}.QT_CSIINDEXQUOTE
                                WHERE TRADINGDAY between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INDEXCODE", "type": "DOUBLE"}, {"name": "INDEXCSITYPE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "OPENPRICE", "type": "DOUBLE"}, {"name": "HIGHPRICE", "type": "DOUBLE"}, {"name": "LOWPRICE", "type": "DOUBLE"}, {"name": "CLOSEPRICE", "type": "DOUBLE"}, {"name": "TURNOVERVOLUME", "type": "DOUBLE"}, {"name": "TURNOVERVALUE", "type": "DOUBLE"}, {"name": "OPENINTEREST", "type": "DOUBLE"}, {"name": "SETTLEVALUE", "type": "DOUBLE"}, {"name": "CHANGEOF", "type": "DOUBLE"}, {"name": "CHANGEPCT", "type": "DOUBLE"}, {"name": "TOTALMV", "type": "DOUBLE"}, {"name": "INDEXPERATIO1", "type": "DOUBLE"}, {"name": "INDEXPERATIO2", "type": "DOUBLE"}, {"name": "INDEXDYRATIO1", "type": "DOUBLE"}, {"name": "INDEXDYRATIO2", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "PREVCLOSEPRICE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_qt_csiindexquote_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_qt_csiindexquote_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_qt_csiindexquote_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_qt_csiindexquote_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_QT_CSIINDEXQUOTE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_QT_CSIINDEXQUOTE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_qt_csiindexquote_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_QT_CSIINDEXQUOTE_PTD PARTITION(P_DT)
SELECT
       ID
     , INDEXCODE
     , INDEXCSITYPE
     , TRADINGDAY
     , OPENPRICE
     , HIGHPRICE
     , LOWPRICE
     , CLOSEPRICE
     , TURNOVERVOLUME
     , TURNOVERVALUE
     , OPENINTEREST
     , SETTLEVALUE
     , CHANGEOF
     , CHANGEPCT
     , TOTALMV
     , INDEXPERATIO1
     , INDEXPERATIO2
     , INDEXDYRATIO1
     , INDEXDYRATIO2
     , UPDATETIME
     , JSID
     , PREVCLOSEPRICE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(TRADINGDAY,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_QT_CSIINDEXQUOTE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_QT_CSIINDEXQUOTE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_QT_CSIINDEXQUOTE_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_QT_CSIINDEXQUOTE_PTD成功"
      exit 0
   fi
fi
