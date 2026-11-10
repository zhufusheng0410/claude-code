#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INDEXTYPE  DECIMAL(10,0)  COMMENT  '指数类别',
  TRADINGDAY  STRING  COMMENT  '交易日',
  PREVCLOSEPRICE  DECIMAL(19,4)  COMMENT  '昨收盘(元)',
  CLOSEPRICE  DECIMAL(19,4)  COMMENT  '收盘价(元)',
  DURATION1  DECIMAL(10,4)  COMMENT  '平均市值法久期',
  DURATION2  DECIMAL(10,4)  COMMENT  '修正久期',
  CONVEXITY1  DECIMAL(10,4)  COMMENT  '平均市值法凸性',
  CONVEXITY2  DECIMAL(10,4)  COMMENT  '平均现金流法凸性',
  YTM  DECIMAL(10,4)  COMMENT  '到期收益率',
  TTM  DECIMAL(10,4)  COMMENT  '平均待偿期限(年)',
  INTERESTPAYMENTRATE  DECIMAL(10,4)  COMMENT  '平均派息率(%)',
  TOTALMARKETVALUE  DECIMAL(18,6)  COMMENT  '指数总市值(百万元)',
  CHANGEPCT  DECIMAL(18,6)  COMMENT  '涨跌幅',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  DIRTYPRICEINDEX  DECIMAL(19,4)  COMMENT  '全价指数',
  NETPRICEINDEX  DECIMAL(19,4)  COMMENT  '净价指数',
  YTMBYMARKETVALUE  DECIMAL(10,4)  COMMENT  '平均市值法到期收益率(%)',
  AVGBASICPOINTVALUE  DECIMAL(10,4)  COMMENT  '平均基点价值',
  PREDIRTYPRICEINDEX  DECIMAL(19,4)  COMMENT  '前日全价指数值',
  PRENETPRICEINDEX  DECIMAL(19,4)  COMMENT  '前日净价指数值',
  DIRTYPRICEINDEXCHANGEPCT  DECIMAL(10,4)  COMMENT  '全价指数涨跌幅(%)',
  NETPRICEINDEXCHANGEPCT  DECIMAL(10,4)  COMMENT  '净价指数涨跌幅(%)',
  SPOTSETTVOL  DECIMAL(18,6)  COMMENT  '现券结算量(百万元)',
  MAINCODE  STRING  COMMENT  '主指数内部编码***',
  INDEXPREVCLOSEPRICE  DECIMAL(19,4)  COMMENT  '指数昨收盘',
  INDEXCLOSEPRICE  DECIMAL(19,4)  COMMENT  '指数收盘价',
  INDEXCHANGEPCT  DECIMAL(19,4)  COMMENT  '指数涨跌幅(%)***'
)
COMMENT '中债指数行情'
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
                                   , INDEXTYPE
                                   , TO_CHAR(TRADINGDAY,'YYYYMMDD') TRADINGDAY
                                   , PREVCLOSEPRICE
                                   , CLOSEPRICE
                                   , DURATION1
                                   , DURATION2
                                   , CONVEXITY1
                                   , CONVEXITY2
                                   , YTM
                                   , TTM
                                   , INTERESTPAYMENTRATE
                                   , TOTALMARKETVALUE
                                   , CHANGEPCT
                                   , UPDATETIME
                                   , JSID
                                   , DIRTYPRICEINDEX
                                   , NETPRICEINDEX
                                   , YTMBYMARKETVALUE
                                   , AVGBASICPOINTVALUE
                                   , PREDIRTYPRICEINDEX
                                   , PRENETPRICEINDEX
                                   , DIRTYPRICEINDEXCHANGEPCT
                                   , NETPRICEINDEXCHANGEPCT
                                   , SPOTSETTVOL
                                   , MAINCODE
                                   , INDEXPREVCLOSEPRICE
                                   , INDEXCLOSEPRICE
                                   , INDEXCHANGEPCT
                                FROM ${jy_src_schema}.BOND_CHINABONDINDEXQUOTE
                                WHERE TRADINGDAY between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INDEXTYPE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "PREVCLOSEPRICE", "type": "DOUBLE"}, {"name": "CLOSEPRICE", "type": "DOUBLE"}, {"name": "DURATION1", "type": "DOUBLE"}, {"name": "DURATION2", "type": "DOUBLE"}, {"name": "CONVEXITY1", "type": "DOUBLE"}, {"name": "CONVEXITY2", "type": "DOUBLE"}, {"name": "YTM", "type": "DOUBLE"}, {"name": "TTM", "type": "DOUBLE"}, {"name": "INTERESTPAYMENTRATE", "type": "DOUBLE"}, {"name": "TOTALMARKETVALUE", "type": "DOUBLE"}, {"name": "CHANGEPCT", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "DIRTYPRICEINDEX", "type": "DOUBLE"}, {"name": "NETPRICEINDEX", "type": "DOUBLE"}, {"name": "YTMBYMARKETVALUE", "type": "DOUBLE"}, {"name": "AVGBASICPOINTVALUE", "type": "DOUBLE"}, {"name": "PREDIRTYPRICEINDEX", "type": "DOUBLE"}, {"name": "PRENETPRICEINDEX", "type": "DOUBLE"}, {"name": "DIRTYPRICEINDEXCHANGEPCT", "type": "DOUBLE"}, {"name": "NETPRICEINDEXCHANGEPCT", "type": "DOUBLE"}, {"name": "SPOTSETTVOL", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "INDEXPREVCLOSEPRICE", "type": "DOUBLE"}, {"name": "INDEXCLOSEPRICE", "type": "DOUBLE"}, {"name": "INDEXCHANGEPCT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_chinabondindexquote_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_chinabondindexquote_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_chinabondindexquote_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_chinabondindexquote_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_chinabondindexquote_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , INDEXTYPE
     , TRADINGDAY
     , PREVCLOSEPRICE
     , CLOSEPRICE
     , DURATION1
     , DURATION2
     , CONVEXITY1
     , CONVEXITY2
     , YTM
     , TTM
     , INTERESTPAYMENTRATE
     , TOTALMARKETVALUE
     , CHANGEPCT
     , UPDATETIME
     , JSID
     , DIRTYPRICEINDEX
     , NETPRICEINDEX
     , YTMBYMARKETVALUE
     , AVGBASICPOINTVALUE
     , PREDIRTYPRICEINDEX
     , PRENETPRICEINDEX
     , DIRTYPRICEINDEXCHANGEPCT
     , NETPRICEINDEXCHANGEPCT
     , SPOTSETTVOL
     , MAINCODE
     , INDEXPREVCLOSEPRICE
     , INDEXCLOSEPRICE
     , INDEXCHANGEPCT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(TRADINGDAY,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CHINABONDINDEXQUOTE_PTD成功"
      exit 0
   fi
fi
