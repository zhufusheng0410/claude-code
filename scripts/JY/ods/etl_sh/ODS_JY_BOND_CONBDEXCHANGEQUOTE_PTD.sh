#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  TRADINGDAY  STRING  COMMENT  '交易日',
  BONDNATURE  DECIMAL(10,0)  COMMENT  '债券性质',
  MATURITY  DECIMAL(9,6)  COMMENT  '存续期限',
  PREVCLOSEPRICE  DECIMAL(19,4)  COMMENT  '昨收盘(元)',
  OPENPRICE  DECIMAL(19,4)  COMMENT  '今开盘(元)',
  HIGHPRICE  DECIMAL(19,4)  COMMENT  '最高价(元)',
  LOWPRICE  DECIMAL(19,4)  COMMENT  '最低价(元)',
  CLOSEPRICE  DECIMAL(19,4)  COMMENT  '收盘价(元)',
  CHANGEPCT  DECIMAL(9,6)  COMMENT  '涨跌幅',
  TURNOVERRATE  DECIMAL(11,6)  COMMENT  '换手率(%)',
  TURNOVERVOLUME  DECIMAL(19,4)  COMMENT  '成交量(股)',
  TURNOVERVALUE  DECIMAL(19,4)  COMMENT  '成交金额(元)',
  TURNOVERDEALS  DECIMAL(10,0)  COMMENT  '成交笔数(笔)',
  NEWCONVETPRICE  DECIMAL(19,4)  COMMENT  '最新转股价(元)',
  STOCKPRICE  DECIMAL(19,4)  COMMENT  '最新股票价格(元)',
  CBCONVERTVALUE  DECIMAL(30,8)  COMMENT  '转债转换价值',
  CONVERTPREMIUMRATE  DECIMAL(30,8)  COMMENT  '转股溢价率(%)',
  CONVERTPARPRICE  DECIMAL(30,8)  COMMENT  '转换平价',
  YRMAT  DECIMAL(9,6)  COMMENT  '债券剩余年限(年)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  YTM_OP  DECIMAL(30,8)  COMMENT  '开盘价到期收益率(%)',
  DURATION_OP  DECIMAL(30,8)  COMMENT  '开盘价麦氏久期',
  MODIFIEDDURATION_OP  DECIMAL(30,8)  COMMENT  '开盘价修正久期',
  CONVEXITY_OP  DECIMAL(30,8)  COMMENT  '开盘价凸度',
  YTM_HI  DECIMAL(30,8)  COMMENT  '最高价到期收益率(%)',
  DURATION_HI  DECIMAL(30,8)  COMMENT  '最高价麦氏久期',
  MODIFIEDDURATION_HI  DECIMAL(30,8)  COMMENT  '最高价修正久期',
  CONVEXITY_HI  DECIMAL(30,8)  COMMENT  '最高价凸度',
  YTM_LO  DECIMAL(30,8)  COMMENT  '最低价到期收益率(%)',
  DURATION_LO  DECIMAL(30,8)  COMMENT  '最低价麦氏久期',
  MODIFIEDDURATION_LO  DECIMAL(30,8)  COMMENT  '最低价修正久期',
  CONVEXITY_LO  DECIMAL(30,8)  COMMENT  '最低价凸度',
  YTM_CL  DECIMAL(30,8)  COMMENT  '收盘价到期收益率(%)',
  DURATION_CL  DECIMAL(30,8)  COMMENT  '收盘价麦氏久期',
  MODIFIEDDURATION_CL  DECIMAL(30,8)  COMMENT  '收盘价修正久期',
  CONVEXITY_CL  DECIMAL(30,8)  COMMENT  '收盘价凸度',
  YTM_AVG  DECIMAL(30,8)  COMMENT  '均价到期收益率(%)',
  DURATION_AVG  DECIMAL(30,8)  COMMENT  '均价麦氏久期',
  MODIFIEDDURATION_AVG  DECIMAL(30,8)  COMMENT  '均价修正久期',
  CONVEXITY_AVG  DECIMAL(30,8)  COMMENT  '均价凸度',
  ACCRUEDINTEREST  DECIMAL(19,4)  COMMENT  '每百元面值应计利息(元)'
)
COMMENT '可转换债券行情'
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
                                   , BONDNATURE
                                   , MATURITY
                                   , PREVCLOSEPRICE
                                   , OPENPRICE
                                   , HIGHPRICE
                                   , LOWPRICE
                                   , CLOSEPRICE
                                   , CHANGEPCT
                                   , TURNOVERRATE
                                   , TURNOVERVOLUME
                                   , TURNOVERVALUE
                                   , TURNOVERDEALS
                                   , NEWCONVETPRICE
                                   , STOCKPRICE
                                   , CBCONVERTVALUE
                                   , CONVERTPREMIUMRATE
                                   , CONVERTPARPRICE
                                   , YRMAT
                                   , UPDATETIME
                                   , JSID
                                   , YTM_OP
                                   , DURATION_OP
                                   , MODIFIEDDURATION_OP
                                   , CONVEXITY_OP
                                   , YTM_HI
                                   , DURATION_HI
                                   , MODIFIEDDURATION_HI
                                   , CONVEXITY_HI
                                   , YTM_LO
                                   , DURATION_LO
                                   , MODIFIEDDURATION_LO
                                   , CONVEXITY_LO
                                   , YTM_CL
                                   , DURATION_CL
                                   , MODIFIEDDURATION_CL
                                   , CONVEXITY_CL
                                   , YTM_AVG
                                   , DURATION_AVG
                                   , MODIFIEDDURATION_AVG
                                   , CONVEXITY_AVG
                                   , ACCRUEDINTEREST
                                FROM ${jy_src_schema}.BOND_CONBDEXCHANGEQUOTE
                                WHERE TRADINGDAY between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "BONDNATURE", "type": "DOUBLE"}, {"name": "MATURITY", "type": "DOUBLE"}, {"name": "PREVCLOSEPRICE", "type": "DOUBLE"}, {"name": "OPENPRICE", "type": "DOUBLE"}, {"name": "HIGHPRICE", "type": "DOUBLE"}, {"name": "LOWPRICE", "type": "DOUBLE"}, {"name": "CLOSEPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCT", "type": "DOUBLE"}, {"name": "TURNOVERRATE", "type": "DOUBLE"}, {"name": "TURNOVERVOLUME", "type": "DOUBLE"}, {"name": "TURNOVERVALUE", "type": "DOUBLE"}, {"name": "TURNOVERDEALS", "type": "DOUBLE"}, {"name": "NEWCONVETPRICE", "type": "DOUBLE"}, {"name": "STOCKPRICE", "type": "DOUBLE"}, {"name": "CBCONVERTVALUE", "type": "DOUBLE"}, {"name": "CONVERTPREMIUMRATE", "type": "DOUBLE"}, {"name": "CONVERTPARPRICE", "type": "DOUBLE"}, {"name": "YRMAT", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "YTM_OP", "type": "DOUBLE"}, {"name": "DURATION_OP", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_OP", "type": "DOUBLE"}, {"name": "CONVEXITY_OP", "type": "DOUBLE"}, {"name": "YTM_HI", "type": "DOUBLE"}, {"name": "DURATION_HI", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_HI", "type": "DOUBLE"}, {"name": "CONVEXITY_HI", "type": "DOUBLE"}, {"name": "YTM_LO", "type": "DOUBLE"}, {"name": "DURATION_LO", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_LO", "type": "DOUBLE"}, {"name": "CONVEXITY_LO", "type": "DOUBLE"}, {"name": "YTM_CL", "type": "DOUBLE"}, {"name": "DURATION_CL", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_CL", "type": "DOUBLE"}, {"name": "CONVEXITY_CL", "type": "DOUBLE"}, {"name": "YTM_AVG", "type": "DOUBLE"}, {"name": "DURATION_AVG", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_AVG", "type": "DOUBLE"}, {"name": "CONVEXITY_AVG", "type": "DOUBLE"}, {"name": "ACCRUEDINTEREST", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_conbdexchangequote_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_conbdexchangequote_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_conbdexchangequote_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_conbdexchangequote_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_conbdexchangequote_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , TRADINGDAY
     , BONDNATURE
     , MATURITY
     , PREVCLOSEPRICE
     , OPENPRICE
     , HIGHPRICE
     , LOWPRICE
     , CLOSEPRICE
     , CHANGEPCT
     , TURNOVERRATE
     , TURNOVERVOLUME
     , TURNOVERVALUE
     , TURNOVERDEALS
     , NEWCONVETPRICE
     , STOCKPRICE
     , CBCONVERTVALUE
     , CONVERTPREMIUMRATE
     , CONVERTPARPRICE
     , YRMAT
     , UPDATETIME
     , JSID
     , YTM_OP
     , DURATION_OP
     , MODIFIEDDURATION_OP
     , CONVEXITY_OP
     , YTM_HI
     , DURATION_HI
     , MODIFIEDDURATION_HI
     , CONVEXITY_HI
     , YTM_LO
     , DURATION_LO
     , MODIFIEDDURATION_LO
     , CONVEXITY_LO
     , YTM_CL
     , DURATION_CL
     , MODIFIEDDURATION_CL
     , CONVEXITY_CL
     , YTM_AVG
     , DURATION_AVG
     , MODIFIEDDURATION_AVG
     , CONVEXITY_AVG
     , ACCRUEDINTEREST
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(TRADINGDAY,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CONBDEXCHANGEQUOTE_PTD成功"
      exit 0
   fi
fi
