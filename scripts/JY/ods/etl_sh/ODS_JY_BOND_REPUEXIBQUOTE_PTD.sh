#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_REPUEXIBQUOTE_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_REPUEXIBQUOTE_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  TRADINGDAY  STRING  COMMENT  '交易日',
  \`EXCHANGE\`  DECIMAL(10,0)  COMMENT  '上市地点',
  REPURCHASENATURE  STRING  COMMENT  '回购类型',
  MATURITYTYPE  STRING  COMMENT  '期限品种',
  PRECLOSEPRICE  DECIMAL(18,10)  COMMENT  '昨收盘(元)',
  OPENPRICE  DECIMAL(18,10)  COMMENT  '今开盘(元)',
  HIGHPRICE  DECIMAL(18,10)  COMMENT  '最高价(元)',
  LOWPRICE  DECIMAL(18,10)  COMMENT  '最低价(元)',
  CLOSEPRICE  DECIMAL(18,10)  COMMENT  '收盘价(元)',
  WEIGHTAVERAGEPRICE  DECIMAL(18,10)  COMMENT  '加权价(%)',
  TURNOVERVOL  DECIMAL(19,4)  COMMENT  '成交量(张)',
  TURNOVERDEALS  DECIMAL(10,0)  COMMENT  '成交笔数(笔)',
  TURNOVERVALUE  DECIMAL(19,4)  COMMENT  '成交金额(元)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  WEIGHTAVERAGEPRICER  DECIMAL(18,10)  COMMENT  '加权价(利率债)(%)',
  AVGREPUMATURITY  DECIMAL(18,4)  COMMENT  '平均回购期限(天)'
)
COMMENT '交易所及银行间回购交易行情'
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
                                   , EXCHANGE
                                   , REPURCHASENATURE
                                   , MATURITYTYPE
                                   , PRECLOSEPRICE
                                   , OPENPRICE
                                   , HIGHPRICE
                                   , LOWPRICE
                                   , CLOSEPRICE
                                   , WEIGHTAVERAGEPRICE
                                   , TURNOVERVOL
                                   , TURNOVERDEALS
                                   , TURNOVERVALUE
                                   , UPDATETIME
                                   , JSID
                                   , WEIGHTAVERAGEPRICER
                                   , AVGREPUMATURITY
                                FROM ${jy_src_schema}.BOND_REPUEXIBQUOTE
                                WHERE TRADINGDAY between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "EXCHANGE", "type": "DOUBLE"}, {"name": "REPURCHASENATURE", "type": "DOUBLE"}, {"name": "MATURITYTYPE", "type": "STRING"}, {"name": "PRECLOSEPRICE", "type": "DOUBLE"}, {"name": "OPENPRICE", "type": "DOUBLE"}, {"name": "HIGHPRICE", "type": "DOUBLE"}, {"name": "LOWPRICE", "type": "DOUBLE"}, {"name": "CLOSEPRICE", "type": "DOUBLE"}, {"name": "WEIGHTAVERAGEPRICE", "type": "DOUBLE"}, {"name": "TURNOVERVOL", "type": "DOUBLE"}, {"name": "TURNOVERDEALS", "type": "DOUBLE"}, {"name": "TURNOVERVALUE", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "WEIGHTAVERAGEPRICER", "type": "DOUBLE"}, {"name": "AVGREPUMATURITY", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_repuexibquote_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_repuexibquote_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_repuexibquote_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_repuexibquote_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_REPUEXIBQUOTE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_REPUEXIBQUOTE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_repuexibquote_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_REPUEXIBQUOTE_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , TRADINGDAY
     , \`EXCHANGE\`
     , REPURCHASENATURE
     , MATURITYTYPE
     , PRECLOSEPRICE
     , OPENPRICE
     , HIGHPRICE
     , LOWPRICE
     , CLOSEPRICE
     , WEIGHTAVERAGEPRICE
     , TURNOVERVOL
     , TURNOVERDEALS
     , TURNOVERVALUE
     , UPDATETIME
     , JSID
     , WEIGHTAVERAGEPRICER
     , AVGREPUMATURITY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(TRADINGDAY,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_BOND_REPUEXIBQUOTE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_REPUEXIBQUOTE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_REPUEXIBQUOTE_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_REPUEXIBQUOTE_PTD成功"
      exit 0
   fi
fi
