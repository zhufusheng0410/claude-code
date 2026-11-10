#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_FUT_DAILYQUOTE_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_FUT_DAILYQUOTE_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  ENDDATE  STRING  COMMENT  '日期',
  REPORTPERIOD  DECIMAL(10,0)  COMMENT  '报告周期',
  REPORTAREA  DECIMAL(10,0)  COMMENT  '统计区域类别',
  ADJUSTMARK  STRING  COMMENT  '调整标志',
  \`EXCHANGE\`  DECIMAL(10,0)  COMMENT  '上市地点',
  CONTRACTNAME  STRING  COMMENT  '合约名称',
  OPTIONCODE  STRING  COMMENT  '品种代码',
  TERM  STRING  COMMENT  '期限描述',
  SETTLEMENTYEAR  STRING  COMMENT  '交割年',
  SETTLEMENTMONTH  STRING  COMMENT  '交割月',
  SETTLEMENTDATE  STRING  COMMENT  '交割日期',
  CODE  STRING  COMMENT  '代码',
  CONTINUUMMARK  STRING  COMMENT  '连续标志',
  PREVSETTLEPRICE  DECIMAL(19,4)  COMMENT  '前结算',
  OPENPRICE  DECIMAL(19,4)  COMMENT  '今开盘(元)',
  HIGHPRICE  DECIMAL(19,4)  COMMENT  '最高价(元)',
  LOWPRICE  DECIMAL(19,4)  COMMENT  '最低价(元)',
  CLOSEPRICE  DECIMAL(19,4)  COMMENT  '收盘价(元)',
  SETTLEPRICE  DECIMAL(19,4)  COMMENT  '最新结算价',
  VOLUME  DECIMAL(18,2)  COMMENT  '成交量(手)',
  OPENINTEREST  DECIMAL(18,2)  COMMENT  '持仓量(手)',
  OPENINTERESTCHANGE  DECIMAL(18,2)  COMMENT  '持仓量变化(手)',
  TURNOVER  DECIMAL(19,4)  COMMENT  '成交额',
  NOTES  STRING  COMMENT  '备注说明',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  MAINCONTRACTMARK  STRING  COMMENT  '主力标志'
)
COMMENT '期货交易日行情'
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
                                   , TO_CHAR(ENDDATE,'YYYYMMDD') ENDDATE
                                   , REPORTPERIOD
                                   , REPORTAREA
                                   , ADJUSTMARK
                                   , EXCHANGE
                                   , CONTRACTNAME
                                   , OPTIONCODE
                                   , TERM
                                   , SETTLEMENTYEAR
                                   , SETTLEMENTMONTH
                                   , SETTLEMENTDATE
                                   , CODE
                                   , CONTINUUMMARK
                                   , PREVSETTLEPRICE
                                   , OPENPRICE
                                   , HIGHPRICE
                                   , LOWPRICE
                                   , CLOSEPRICE
                                   , SETTLEPRICE
                                   , VOLUME
                                   , OPENINTEREST
                                   , OPENINTERESTCHANGE
                                   , TURNOVER
                                   , NOTES
                                   , UPDATETIME
                                   , JSID
                                   , INNERCODE
                                   , MAINCONTRACTMARK
                                FROM ${jy_src_schema}.FUT_DAILYQUOTE
                                WHERE ENDDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "REPORTPERIOD", "type": "DOUBLE"}, {"name": "REPORTAREA", "type": "DOUBLE"}, {"name": "ADJUSTMARK", "type": "DOUBLE"}, {"name": "EXCHANGE", "type": "DOUBLE"}, {"name": "CONTRACTNAME", "type": "STRING"}, {"name": "OPTIONCODE", "type": "DOUBLE"}, {"name": "TERM", "type": "STRING"}, {"name": "SETTLEMENTYEAR", "type": "STRING"}, {"name": "SETTLEMENTMONTH", "type": "STRING"}, {"name": "SETTLEMENTDATE", "type": "STRING"}, {"name": "CODE", "type": "DOUBLE"}, {"name": "CONTINUUMMARK", "type": "DOUBLE"}, {"name": "PREVSETTLEPRICE", "type": "DOUBLE"}, {"name": "OPENPRICE", "type": "DOUBLE"}, {"name": "HIGHPRICE", "type": "DOUBLE"}, {"name": "LOWPRICE", "type": "DOUBLE"}, {"name": "CLOSEPRICE", "type": "DOUBLE"}, {"name": "SETTLEPRICE", "type": "DOUBLE"}, {"name": "VOLUME", "type": "DOUBLE"}, {"name": "OPENINTEREST", "type": "DOUBLE"}, {"name": "OPENINTERESTCHANGE", "type": "DOUBLE"}, {"name": "TURNOVER", "type": "DOUBLE"}, {"name": "NOTES", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "MAINCONTRACTMARK", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_fut_dailyquote_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_fut_dailyquote_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_fut_dailyquote_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_fut_dailyquote_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_FUT_DAILYQUOTE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_FUT_DAILYQUOTE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_fut_dailyquote_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_FUT_DAILYQUOTE_PTD PARTITION(P_DT)
SELECT
       ID
     , ENDDATE
     , REPORTPERIOD
     , REPORTAREA
     , ADJUSTMARK
     , \`EXCHANGE\`
     , CONTRACTNAME
     , OPTIONCODE
     , TERM
     , SETTLEMENTYEAR
     , SETTLEMENTMONTH
     , SETTLEMENTDATE
     , CODE
     , CONTINUUMMARK
     , PREVSETTLEPRICE
     , OPENPRICE
     , HIGHPRICE
     , LOWPRICE
     , CLOSEPRICE
     , SETTLEPRICE
     , VOLUME
     , OPENINTEREST
     , OPENINTERESTCHANGE
     , TURNOVER
     , NOTES
     , UPDATETIME
     , JSID
     , INNERCODE
     , MAINCONTRACTMARK
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(ENDDATE,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_FUT_DAILYQUOTE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_FUT_DAILYQUOTE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_FUT_DAILYQUOTE_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_FUT_DAILYQUOTE_PTD成功"
      exit 0
   fi
fi
