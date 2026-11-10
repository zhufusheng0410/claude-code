#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_FUT_CONTRACTMAIN_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_FUT_CONTRACTMAIN_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  CONTRACTINNERCODE  STRING  COMMENT  '合约内部编码',
  CONTRACTCODE  STRING  COMMENT  '合约代码',
  CONTRACTNAME  STRING  COMMENT  '合约名称',
  EXCHANGECODE  STRING  COMMENT  '交易所代码',
  CONTRACTTYPE  STRING  COMMENT  '合约类型',
  OPTIONCODE  STRING  COMMENT  '品种代码',
  CONTRACTMULTIPLIER  STRING  COMMENT  '交易单位/合约乘数',
  PRICEUNIT  STRING  COMMENT  '期货单位',
  LITTLESTCHANGEUNIT  STRING  COMMENT  '最小变动价位',
  CHANGEPCTLIMIT  STRING  COMMENT  '每日涨跌幅度',
  CURRENCYCODE  DECIMAL(10,0)  COMMENT  '计价货币',
  DELIVERYYEAR  STRING  COMMENT  '交割年',
  DELIVERYMONTH  STRING  COMMENT  '交割月',
  EFFECTIVEDATE  STRING  COMMENT  '生效日期',
  LASTTRADINGDATE  STRING  COMMENT  '最后交易日',
  DELIVERYDATE  STRING  COMMENT  '交割日期',
  LASTDELIVERYDATE  STRING  COMMENT  '最后交割日',
  DELIVERYMETHOD  DECIMAL(10,0)  COMMENT  '交割方式',
  DELIVERYGRADES  STRING  COMMENT  '交割等级',
  MINMARGINRATIO  DECIMAL(9,6)  COMMENT  '最低交易保证金率(%)',
  TRADINGCOMMISSION  STRING  COMMENT  '交易手续费',
  DELIVERYCOMMISSION  STRING  COMMENT  '交割手续费',
  SETTPRICECODE  STRING  COMMENT  '结算价计算方式分类代码',
  SETTPRICEDESC  STRING  COMMENT  '结算价计算方式',
  DELISETTPRICECODE  STRING  COMMENT  '交割结算价计算方式分类代码',
  DELISETTPRICEDESC  STRING  COMMENT  '交割结算价计算方式',
  LISTBASISPRICE  DECIMAL(19,4)  COMMENT  '挂牌基准价',
  CHANGEPCTLISTPRICE  DECIMAL(18,10)  COMMENT  '挂牌价涨跌幅(%)',
  CONTRACTSTATE  DECIMAL(10,0)  COMMENT  '合约状态',
  CHANGEREASON  STRING  COMMENT  '简称变更原因',
  CONTRACTMONTH  STRING  COMMENT  '合约月份',
  EXCHANGEDATE  STRING  COMMENT  '交易时间',
  LASTTRADINGDATEDESC  STRING  COMMENT  '最后交易日描述',
  LASTTRADINGTIMEDESC  STRING  COMMENT  '最后交易日交易时间描述',
  DELIVERYDATEDESC  STRING  COMMENT  '交割日期描述',
  LASTDELIVERYDATEDESC  STRING  COMMENT  '最后交割日日期描述',
  CONTRACTINTRODUCTION  STRING  COMMENT  '合约简介',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  CMVALUE  DECIMAL(10,0)  COMMENT  '合约乘数(数值)',
  CONTRACTABBR  STRING  COMMENT  '合约简称',
  IFREAL  DECIMAL(10,0)  COMMENT  '是否真实',
  INITIALMARGINRATIO  DECIMAL(9,6)  COMMENT  '最初交易保证金(%)',
  VARIETYINNERCODE  STRING  COMMENT  '品种内部编码',
  CONTINUECONTTYPE  STRING  COMMENT  '连续合约类型1',
  ISIN  STRING  COMMENT  'ISIN代码'
)
COMMENT '期货合约主表'
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
                                   , CONTRACTCODE
                                   , CONTRACTNAME
                                   , EXCHANGECODE
                                   , CONTRACTTYPE
                                   , OPTIONCODE
                                   , CONTRACTMULTIPLIER
                                   , PRICEUNIT
                                   , LITTLESTCHANGEUNIT
                                   , CHANGEPCTLIMIT
                                   , CURRENCYCODE
                                   , DELIVERYYEAR
                                   , DELIVERYMONTH
                                   , EFFECTIVEDATE
                                   , LASTTRADINGDATE
                                   , DELIVERYDATE
                                   , LASTDELIVERYDATE
                                   , DELIVERYMETHOD
                                   , DELIVERYGRADES
                                   , MINMARGINRATIO
                                   , TRADINGCOMMISSION
                                   , DELIVERYCOMMISSION
                                   , SETTPRICECODE
                                   , SETTPRICEDESC
                                   , DELISETTPRICECODE
                                   , DELISETTPRICEDESC
                                   , LISTBASISPRICE
                                   , CHANGEPCTLISTPRICE
                                   , CONTRACTSTATE
                                   , CHANGEREASON
                                   , CONTRACTMONTH
                                   , EXCHANGEDATE
                                   , LASTTRADINGDATEDESC
                                   , LASTTRADINGTIMEDESC
                                   , DELIVERYDATEDESC
                                   , LASTDELIVERYDATEDESC
                                   , CONTRACTINTRODUCTION
                                   , UPDATETIME
                                   , JSID
                                   , CMVALUE
                                   , CONTRACTABBR
                                   , IFREAL
                                   , INITIALMARGINRATIO
                                   , VARIETYINNERCODE
                                   , CONTINUECONTTYPE
                                   , ISIN
                                FROM ${jy_src_schema}.FUT_CONTRACTMAIN"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "CONTRACTINNERCODE", "type": "DOUBLE"}, {"name": "CONTRACTCODE", "type": "STRING"}, {"name": "CONTRACTNAME", "type": "STRING"}, {"name": "EXCHANGECODE", "type": "DOUBLE"}, {"name": "CONTRACTTYPE", "type": "DOUBLE"}, {"name": "OPTIONCODE", "type": "DOUBLE"}, {"name": "CONTRACTMULTIPLIER", "type": "STRING"}, {"name": "PRICEUNIT", "type": "STRING"}, {"name": "LITTLESTCHANGEUNIT", "type": "STRING"}, {"name": "CHANGEPCTLIMIT", "type": "STRING"}, {"name": "CURRENCYCODE", "type": "DOUBLE"}, {"name": "DELIVERYYEAR", "type": "STRING"}, {"name": "DELIVERYMONTH", "type": "STRING"}, {"name": "EFFECTIVEDATE", "type": "STRING"}, {"name": "LASTTRADINGDATE", "type": "STRING"}, {"name": "DELIVERYDATE", "type": "STRING"}, {"name": "LASTDELIVERYDATE", "type": "STRING"}, {"name": "DELIVERYMETHOD", "type": "DOUBLE"}, {"name": "DELIVERYGRADES", "type": "STRING"}, {"name": "MINMARGINRATIO", "type": "DOUBLE"}, {"name": "TRADINGCOMMISSION", "type": "STRING"}, {"name": "DELIVERYCOMMISSION", "type": "STRING"}, {"name": "SETTPRICECODE", "type": "DOUBLE"}, {"name": "SETTPRICEDESC", "type": "STRING"}, {"name": "DELISETTPRICECODE", "type": "DOUBLE"}, {"name": "DELISETTPRICEDESC", "type": "STRING"}, {"name": "LISTBASISPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCTLISTPRICE", "type": "DOUBLE"}, {"name": "CONTRACTSTATE", "type": "DOUBLE"}, {"name": "CHANGEREASON", "type": "STRING"}, {"name": "CONTRACTMONTH", "type": "STRING"}, {"name": "EXCHANGEDATE", "type": "STRING"}, {"name": "LASTTRADINGDATEDESC", "type": "STRING"}, {"name": "LASTTRADINGTIMEDESC", "type": "STRING"}, {"name": "DELIVERYDATEDESC", "type": "STRING"}, {"name": "LASTDELIVERYDATEDESC", "type": "STRING"}, {"name": "CONTRACTINTRODUCTION", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "CMVALUE", "type": "DOUBLE"}, {"name": "CONTRACTABBR", "type": "STRING"}, {"name": "IFREAL", "type": "DOUBLE"}, {"name": "INITIALMARGINRATIO", "type": "DOUBLE"}, {"name": "VARIETYINNERCODE", "type": "DOUBLE"}, {"name": "CONTINUECONTTYPE", "type": "DOUBLE"}, {"name": "ISIN", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_fut_contractmain_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_fut_contractmain_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_fut_contractmain_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_fut_contractmain_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_FUT_CONTRACTMAIN_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_FUT_CONTRACTMAIN_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_fut_contractmain_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_FUT_CONTRACTMAIN_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , CONTRACTINNERCODE
     , CONTRACTCODE
     , CONTRACTNAME
     , EXCHANGECODE
     , CONTRACTTYPE
     , OPTIONCODE
     , CONTRACTMULTIPLIER
     , PRICEUNIT
     , LITTLESTCHANGEUNIT
     , CHANGEPCTLIMIT
     , CURRENCYCODE
     , DELIVERYYEAR
     , DELIVERYMONTH
     , EFFECTIVEDATE
     , LASTTRADINGDATE
     , DELIVERYDATE
     , LASTDELIVERYDATE
     , DELIVERYMETHOD
     , DELIVERYGRADES
     , MINMARGINRATIO
     , TRADINGCOMMISSION
     , DELIVERYCOMMISSION
     , SETTPRICECODE
     , SETTPRICEDESC
     , DELISETTPRICECODE
     , DELISETTPRICEDESC
     , LISTBASISPRICE
     , CHANGEPCTLISTPRICE
     , CONTRACTSTATE
     , CHANGEREASON
     , CONTRACTMONTH
     , EXCHANGEDATE
     , LASTTRADINGDATEDESC
     , LASTTRADINGTIMEDESC
     , DELIVERYDATEDESC
     , LASTDELIVERYDATEDESC
     , CONTRACTINTRODUCTION
     , UPDATETIME
     , JSID
     , CMVALUE
     , CONTRACTABBR
     , IFREAL
     , INITIALMARGINRATIO
     , VARIETYINNERCODE
     , CONTINUECONTTYPE
     , ISIN
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_FUT_CONTRACTMAIN_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_FUT_CONTRACTMAIN_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_FUT_CONTRACTMAIN_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_FUT_CONTRACTMAIN_PFD成功"
      exit 0
   fi
fi
