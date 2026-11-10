#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_OPT_OPTIONCONTRACT_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_OPT_OPTIONCONTRACT_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  CONTRACTCODE  STRING  COMMENT  '合约代码',
  TRADINGCODE  STRING  COMMENT  '交易代码',
  CONTRACTABBR  STRING  COMMENT  '合约简称',
  ULAINNERCODE  STRING  COMMENT  '标的内部编码',
  ULANAME  STRING  COMMENT  '标的名称',
  ULATYPE  DECIMAL(10,0)  COMMENT  '品种类别',
  \`EXCHANGE\`  DECIMAL(10,0)  COMMENT  '上市地点',
  CONTRACTTYPE  STRING  COMMENT  '合约类型',
  STRIKEPRICE  DECIMAL(19,4)  COMMENT  '行权价格',
  CONTRACTSIZE  DECIMAL(10,0)  COMMENT  '合约单位',
  CONTRACTSTATE  DECIMAL(10,0)  COMMENT  '合约状态',
  EXPIRATIONYEAR  STRING  COMMENT  '到期年',
  EXPIRATIONMONTH  STRING  COMMENT  '到期月',
  EXPIRATIONDATE  STRING  COMMENT  '要约市场过期日',
  LASTTRADINGDATE  STRING  COMMENT  '最后交易日',
  EXERCISEDATE  STRING  COMMENT  '行权日',
  SETTLEMENTDATE  STRING  COMMENT  '交割日期',
  LISTINGDATE  STRING  COMMENT  '3)上市流通日期',
  LISTINGREASON  DECIMAL(10,0)  COMMENT  '挂牌原因',
  LISTINGPRICE  DECIMAL(19,4)  COMMENT  '上市价格条件',
  LISTINGDAYPC  DECIMAL(19,4)  COMMENT  '挂牌日涨停价',
  LISTINGDAYPF  DECIMAL(19,4)  COMMENT  '挂牌日跌停价',
  IFADJUSTED  DECIMAL(10,0)  COMMENT  '是否调整',
  DELISTINGDATE  STRING  COMMENT  '生效日期',
  DELISTINGREASON  DECIMAL(10,0)  COMMENT  '摘牌原因',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  IFREAL  DECIMAL(10,0)  COMMENT  '是否真实',
  VARIETYULAINNERCODE  STRING  COMMENT  '品种标的内部编码'
)
COMMENT '期权合约'
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
                                   , CONTRACTCODE
                                   , TRADINGCODE
                                   , CONTRACTABBR
                                   , ULAINNERCODE
                                   , ULANAME
                                   , ULATYPE
                                   , EXCHANGE
                                   , CONTRACTTYPE
                                   , STRIKEPRICE
                                   , CONTRACTSIZE
                                   , CONTRACTSTATE
                                   , EXPIRATIONYEAR
                                   , EXPIRATIONMONTH
                                   , EXPIRATIONDATE
                                   , LASTTRADINGDATE
                                   , EXERCISEDATE
                                   , SETTLEMENTDATE
                                   , LISTINGDATE
                                   , LISTINGREASON
                                   , LISTINGPRICE
                                   , LISTINGDAYPC
                                   , LISTINGDAYPF
                                   , IFADJUSTED
                                   , DELISTINGDATE
                                   , DELISTINGREASON
                                   , UPDATETIME
                                   , JSID
                                   , IFREAL
                                   , VARIETYULAINNERCODE
                                FROM ${jy_src_schema}.OPT_OPTIONCONTRACT"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "CONTRACTCODE", "type": "DOUBLE"}, {"name": "TRADINGCODE", "type": "STRING"}, {"name": "CONTRACTABBR", "type": "STRING"}, {"name": "ULAINNERCODE", "type": "DOUBLE"}, {"name": "ULANAME", "type": "STRING"}, {"name": "ULATYPE", "type": "DOUBLE"}, {"name": "EXCHANGE", "type": "DOUBLE"}, {"name": "CONTRACTTYPE", "type": "DOUBLE"}, {"name": "STRIKEPRICE", "type": "DOUBLE"}, {"name": "CONTRACTSIZE", "type": "DOUBLE"}, {"name": "CONTRACTSTATE", "type": "DOUBLE"}, {"name": "EXPIRATIONYEAR", "type": "STRING"}, {"name": "EXPIRATIONMONTH", "type": "STRING"}, {"name": "EXPIRATIONDATE", "type": "STRING"}, {"name": "LASTTRADINGDATE", "type": "STRING"}, {"name": "EXERCISEDATE", "type": "STRING"}, {"name": "SETTLEMENTDATE", "type": "STRING"}, {"name": "LISTINGDATE", "type": "STRING"}, {"name": "LISTINGREASON", "type": "DOUBLE"}, {"name": "LISTINGPRICE", "type": "DOUBLE"}, {"name": "LISTINGDAYPC", "type": "DOUBLE"}, {"name": "LISTINGDAYPF", "type": "DOUBLE"}, {"name": "IFADJUSTED", "type": "DOUBLE"}, {"name": "DELISTINGDATE", "type": "STRING"}, {"name": "DELISTINGREASON", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "IFREAL", "type": "DOUBLE"}, {"name": "VARIETYULAINNERCODE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_opt_optioncontract_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_opt_optioncontract_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_opt_optioncontract_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_opt_optioncontract_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_OPT_OPTIONCONTRACT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_OPT_OPTIONCONTRACT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_opt_optioncontract_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_OPT_OPTIONCONTRACT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , CONTRACTCODE
     , TRADINGCODE
     , CONTRACTABBR
     , ULAINNERCODE
     , ULANAME
     , ULATYPE
     , \`EXCHANGE\`
     , CONTRACTTYPE
     , STRIKEPRICE
     , CONTRACTSIZE
     , CONTRACTSTATE
     , EXPIRATIONYEAR
     , EXPIRATIONMONTH
     , EXPIRATIONDATE
     , LASTTRADINGDATE
     , EXERCISEDATE
     , SETTLEMENTDATE
     , LISTINGDATE
     , LISTINGREASON
     , LISTINGPRICE
     , LISTINGDAYPC
     , LISTINGDAYPF
     , IFADJUSTED
     , DELISTINGDATE
     , DELISTINGREASON
     , UPDATETIME
     , JSID
     , IFREAL
     , VARIETYULAINNERCODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_OPT_OPTIONCONTRACT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_OPT_OPTIONCONTRACT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_OPT_OPTIONCONTRACT_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_OPT_OPTIONCONTRACT_PFD成功"
      exit 0
   fi
fi
