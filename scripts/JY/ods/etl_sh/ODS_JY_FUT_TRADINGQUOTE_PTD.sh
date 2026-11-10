#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_FUT_TRADINGQUOTE_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_FUT_TRADINGQUOTE_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  CONTRACTINNERCODE  STRING  COMMENT  '合约内部编码',
  TRADINGDAY  STRING  COMMENT  '交易日',
  CONTRACTCODE  STRING  COMMENT  '合约代码',
  EXCHANGECODE  STRING  COMMENT  '交易所代码',
  OPTIONCODE  STRING  COMMENT  '品种代码',
  SERIESFLAG  STRING  COMMENT  '合约序列标志',
  PREVSETTLEPRICE  DECIMAL(19,4)  COMMENT  '前结算',
  PREVCLOSEPRICE  DECIMAL(19,4)  COMMENT  '昨收盘(元)',
  OPENPRICE  DECIMAL(19,4)  COMMENT  '今开盘(元)',
  HIGHPRICE  DECIMAL(19,4)  COMMENT  '最高价(元)',
  LOWPRICE  DECIMAL(19,4)  COMMENT  '最低价(元)',
  CLOSEPRICE  DECIMAL(19,4)  COMMENT  '收盘价(元)',
  CHANGEOFCTPS  DECIMAL(19,4)  COMMENT  '收盘较前结算涨跌',
  CHANGEPCTCTPS  DECIMAL(18,10)  COMMENT  '收盘较前结算涨跌幅(%)',
  CHANGEOFCLOSEPRICE  DECIMAL(19,4)  COMMENT  '收盘价涨跌',
  CHANGEPCTCLOSEPRICE  DECIMAL(18,10)  COMMENT  '收盘价涨跌幅(%)',
  SETTLEPRICE  DECIMAL(19,4)  COMMENT  '最新结算价',
  CHANGEOFSETTPRICE  DECIMAL(19,4)  COMMENT  '结算价涨跌',
  CHANGEPCTSETTPRICE  DECIMAL(18,10)  COMMENT  '结算价涨跌幅',
  OPENINTEREST  DECIMAL(18,4)  COMMENT  '持仓量(手)',
  CHANGEOFOPENINTEREST  DECIMAL(18,4)  COMMENT  '持仓量变化(手)',
  CHANGEPCTOPENINTEREST  DECIMAL(18,10)  COMMENT  '持仓量变化幅度(%)',
  TURNOVERVOLUME  DECIMAL(18,4)  COMMENT  '成交量(股)',
  CHANGEOFTURNOVERVOLUME  DECIMAL(18,4)  COMMENT  '成交额增减(亿元)',
  CHANGEPCTTURNOVERVOLUME  DECIMAL(18,10)  COMMENT  '成交量变化幅度(%)',
  TURNOVERVALUE  DECIMAL(19,4)  COMMENT  '成交金额(元)',
  CHANGEOFTURNOVERVALUE  DECIMAL(19,4)  COMMENT  '成交金额变化(元)',
  CHANGEPCTTURNOVERVALUE  DECIMAL(18,10)  COMMENT  '成交金额变化幅度(%)',
  BASISVALUE  DECIMAL(18,4)  COMMENT  '基差',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  MAINCONTRACTMARK  STRING  COMMENT  '主力标志'
)
COMMENT '金融期货每日行情'
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
                                   , CONTRACTINNERCODE
                                   , TO_CHAR(TRADINGDAY,'YYYYMMDD') TRADINGDAY
                                   , CONTRACTCODE
                                   , EXCHANGECODE
                                   , OPTIONCODE
                                   , SERIESFLAG
                                   , PREVSETTLEPRICE
                                   , PREVCLOSEPRICE
                                   , OPENPRICE
                                   , HIGHPRICE
                                   , LOWPRICE
                                   , CLOSEPRICE
                                   , CHANGEOFCTPS
                                   , CHANGEPCTCTPS
                                   , CHANGEOFCLOSEPRICE
                                   , CHANGEPCTCLOSEPRICE
                                   , SETTLEPRICE
                                   , CHANGEOFSETTPRICE
                                   , CHANGEPCTSETTPRICE
                                   , OPENINTEREST
                                   , CHANGEOFOPENINTEREST
                                   , CHANGEPCTOPENINTEREST
                                   , TURNOVERVOLUME
                                   , CHANGEOFTURNOVERVOLUME
                                   , CHANGEPCTTURNOVERVOLUME
                                   , TURNOVERVALUE
                                   , CHANGEOFTURNOVERVALUE
                                   , CHANGEPCTTURNOVERVALUE
                                   , BASISVALUE
                                   , UPDATETIME
                                   , JSID
                                   , MAINCONTRACTMARK
                                FROM ${jy_src_schema}.FUT_TRADINGQUOTE
                                WHERE TRADINGDAY between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "CONTRACTINNERCODE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "CONTRACTCODE", "type": "STRING"}, {"name": "EXCHANGECODE", "type": "DOUBLE"}, {"name": "OPTIONCODE", "type": "DOUBLE"}, {"name": "SERIESFLAG", "type": "DOUBLE"}, {"name": "PREVSETTLEPRICE", "type": "DOUBLE"}, {"name": "PREVCLOSEPRICE", "type": "DOUBLE"}, {"name": "OPENPRICE", "type": "DOUBLE"}, {"name": "HIGHPRICE", "type": "DOUBLE"}, {"name": "LOWPRICE", "type": "DOUBLE"}, {"name": "CLOSEPRICE", "type": "DOUBLE"}, {"name": "CHANGEOFCTPS", "type": "DOUBLE"}, {"name": "CHANGEPCTCTPS", "type": "DOUBLE"}, {"name": "CHANGEOFCLOSEPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCTCLOSEPRICE", "type": "DOUBLE"}, {"name": "SETTLEPRICE", "type": "DOUBLE"}, {"name": "CHANGEOFSETTPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCTSETTPRICE", "type": "DOUBLE"}, {"name": "OPENINTEREST", "type": "DOUBLE"}, {"name": "CHANGEOFOPENINTEREST", "type": "DOUBLE"}, {"name": "CHANGEPCTOPENINTEREST", "type": "DOUBLE"}, {"name": "TURNOVERVOLUME", "type": "DOUBLE"}, {"name": "CHANGEOFTURNOVERVOLUME", "type": "DOUBLE"}, {"name": "CHANGEPCTTURNOVERVOLUME", "type": "DOUBLE"}, {"name": "TURNOVERVALUE", "type": "DOUBLE"}, {"name": "CHANGEOFTURNOVERVALUE", "type": "DOUBLE"}, {"name": "CHANGEPCTTURNOVERVALUE", "type": "DOUBLE"}, {"name": "BASISVALUE", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "MAINCONTRACTMARK", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_fut_tradingquote_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_fut_tradingquote_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_fut_tradingquote_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_fut_tradingquote_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_FUT_TRADINGQUOTE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_FUT_TRADINGQUOTE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_fut_tradingquote_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_FUT_TRADINGQUOTE_PTD PARTITION(P_DT)
SELECT
       ID
     , CONTRACTINNERCODE
     , TRADINGDAY
     , CONTRACTCODE
     , EXCHANGECODE
     , OPTIONCODE
     , SERIESFLAG
     , PREVSETTLEPRICE
     , PREVCLOSEPRICE
     , OPENPRICE
     , HIGHPRICE
     , LOWPRICE
     , CLOSEPRICE
     , CHANGEOFCTPS
     , CHANGEPCTCTPS
     , CHANGEOFCLOSEPRICE
     , CHANGEPCTCLOSEPRICE
     , SETTLEPRICE
     , CHANGEOFSETTPRICE
     , CHANGEPCTSETTPRICE
     , OPENINTEREST
     , CHANGEOFOPENINTEREST
     , CHANGEPCTOPENINTEREST
     , TURNOVERVOLUME
     , CHANGEOFTURNOVERVOLUME
     , CHANGEPCTTURNOVERVOLUME
     , TURNOVERVALUE
     , CHANGEOFTURNOVERVALUE
     , CHANGEPCTTURNOVERVALUE
     , BASISVALUE
     , UPDATETIME
     , JSID
     , MAINCONTRACTMARK
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(TRADINGDAY,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_FUT_TRADINGQUOTE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_FUT_TRADINGQUOTE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_FUT_TRADINGQUOTE_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_FUT_TRADINGQUOTE_PTD成功"
      exit 0
   fi
fi
