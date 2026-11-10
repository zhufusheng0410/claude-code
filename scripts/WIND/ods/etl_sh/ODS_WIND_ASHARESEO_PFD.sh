#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_ASHARESEO_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHARESEO_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  S_FELLOW_PROGRESS  DECIMAL(18,2)  COMMENT  '方案进度',
  S_FELLOW_ISSUETYPE  STRING  COMMENT  '发行方式',
  CRNCY_CODE  STRING  COMMENT  '货币代码',
  S_FELLOW_PRICE  DECIMAL(18,2)  COMMENT  '发行价格(元)',
  S_FELLOW_AMOUNT  DECIMAL(18,2)  COMMENT  '发行数量(万股)',
  S_FELLOW_COLLECTION  DECIMAL(18,2)  COMMENT  '募集资金(元)',
  S_FELLOW_RECORDDATE  STRING  COMMENT  '股权登记日',
  S_FELLOW_PAYSTARTDATE  STRING  COMMENT  '缴款起始日期',
  S_FELLOW_PAYENDDATE  STRING  COMMENT  '缴款截止日期',
  S_FELLOW_SUBDATE  STRING  COMMENT  '网上申购日',
  S_FELLOW_OTCDATE  STRING  COMMENT  '网下发行日期',
  S_FELLOW_LISTDATE  STRING  COMMENT  '向公众增发股份上市日期',
  S_FELLOW_INSTLISTDATE  STRING  COMMENT  '向机构增发股份上市日期',
  S_FELLOW_CHANGEDATE  STRING  COMMENT  '定向增发股份变动日期',
  S_FELLOW_ROADSHOWDATE  STRING  COMMENT  '网上路演日',
  S_FELLOW_REFUNDDATE  STRING  COMMENT  '网下申购定金退款日或补缴余款日',
  S_FELLOW_UNFROZEDATE  STRING  COMMENT  '网上申购资金解冻日',
  S_FELLOW_PREPLANDATE  STRING  COMMENT  '预案公告日',
  S_FELLOW_SMTGANNCEDATE  STRING  COMMENT  '股东大会公告日',
  S_FELLOW_PASSDATE  STRING  COMMENT  '发审委/上市委通过公告日',
  S_FELLOW_APPROVEDDATE  STRING  COMMENT  '证监会通过公告日',
  S_FELLOW_ANNCEDATE  STRING  COMMENT  '上网发行公告日',
  S_FELLOW_RATIOANNCEDATE  STRING  COMMENT  '网上中签率公告日',
  S_FELLOW_OFFERINGDATE  STRING  COMMENT  '增发公告日',
  S_FELLOW_LISTANNDATE  STRING  COMMENT  '上市公告日',
  S_FELLOW_OFFERINGOBJECT  STRING  COMMENT  '发行对象',
  S_FELLOW_PRICEUPLIMIT  DECIMAL(18,2)  COMMENT  '增发预案价上限',
  S_FELLOW_PRICEDOWNLIMIT  DECIMAL(18,2)  COMMENT  '增发预案价下限',
  S_SEO_CODE  STRING  COMMENT  '增发代码',
  S_SEO_NAME  STRING  COMMENT  '增发简称',
  S_SEO_PE  DECIMAL(18,2)  COMMENT  '发行市盈率(摊薄)',
  S_SEO_AMTBYPLACING  DECIMAL(18,2)  COMMENT  '上网发行数量(万股)',
  S_SEO_AMTTOJUR  DECIMAL(18,2)  COMMENT  '网下发行数量(万股)',
  S_SEO_HOLDERSUBSMODE  STRING  COMMENT  '大股东认购方式',
  S_SEO_HOLDERSUBSRATE  DECIMAL(18,2)  COMMENT  '大股东认购比例(%)',
  ANN_DT  STRING  COMMENT  '最新公告日期',
  PRICINGMODE  DECIMAL(18,2)  COMMENT  '定向增发定价方式代码',
  S_FELLOW_ORGPRICEMIN  DECIMAL(18,2)  COMMENT  '原始预案价下限',
  S_FELLOW_DISCNTRATIO  DECIMAL(18,2)  COMMENT  '折扣率',
  S_FELLOW_DATE  STRING  COMMENT  '定增发行日期',
  S_FELLOW_SUBINVITATIONDT  STRING  COMMENT  '认购邀请书日',
  S_FELLOW_YEAR  STRING  COMMENT  '增发年度',
  S_FELLOW_OBJECTIVE_CODE  DECIMAL(18,2)  COMMENT  '定向增发目的代码',
  PRICINGDATE  STRING  COMMENT  '定价基准日',
  IS_NO_PUBLIC  DECIMAL(18,2)  COMMENT  '是否属于非公开发行',
  EXPENSE  DECIMAL(18,2)  COMMENT  '发行费用(元)',
  S_RIGHTSISSUE_EXDIVIDENDDATE  STRING  COMMENT  '除权日',
  IS_EXDIVIDEND  DECIMAL(18,2)  COMMENT  '是否除权',
  SUB_MODE  DECIMAL(18,2)  COMMENT  '定增认购方式代码',
  OLDSPLA_MOLE  DECIMAL(18,2)  COMMENT  '老股东配售比例分子',
  OLDSPLA_MODE  STRING  COMMENT  '老股东配售代码',
  EXP_COLLECTION  DECIMAL(18,2)  COMMENT  '预计募集资金(元)',
  S_FELLOW_TYPE  STRING  COMMENT  '增发类型',
  S_FELLOW_OBJECTIVE  STRING  COMMENT  '增发目的说明',
  S_FELLOW_OFFERINGOBJECT_DES  STRING  COMMENT  '发行对象说明',
  EVENT_ID  STRING  COMMENT  '事件ID',
  PRICE_CONDITION  STRING  COMMENT  '价格制定依据',
  PRICE_DT_TYPE  STRING  COMMENT  '定价基准日类型',
  ORGPRICE_PCT  DECIMAL(18,2)  COMMENT  '预案价格相对基准价格比例(%)',
  ACTPRICE_PCT  DECIMAL(18,2)  COMMENT  '实施价格相对基准价格比例(%)',
  APPRVBYSASSC_DT  STRING  COMMENT  '国资委批准公告日期',
  S_FELLOW_INITIAL_PLAN  STRING  COMMENT  '初始预案公告日',
  LEADUNDERWRITER  STRING  COMMENT  '主承销商',
  CURRENCY_SUBSCRIPTION_NUM  DECIMAL(18,2)  COMMENT  '货币认购数量(万股)',
  NON_MONETARY_SUBSCRIPTION_NUM  DECIMAL(18,2)  COMMENT  '非货币认购数量(万股)',
  CURRENCY_SUBSCRIPTION_AMOUNT  DECIMAL(18,2)  COMMENT  '货币认购金额(元)',
  NOCURRENCY_SUBSCRIPTION_AMOUNT  DECIMAL(18,2)  COMMENT  '非货币认购金额(元)',
  IS_CONTAIN_HOLDER  DECIMAL(18,2)  COMMENT  '发行对象是否包含控股股东',
  OLDSPLA_DENOMINATOR  DECIMAL(18,2)  COMMENT  '老股东配售比例分母',
  NUM_SHARES_PREAONLINE  DECIMAL(18,2)  COMMENT  '网上向老股东优先配售数量(万股)',
  SHARE_RECORDDATE  STRING  COMMENT  '股份登记日（定向）',
  ADD_SUBSCRIPTION_STARTDATE  STRING  COMMENT  '追加认购起始日期',
  ADD_SUBSCRIPTION_ENDDATE  STRING  COMMENT  '追加认购截止日期',
  FUND_VERIFICATION_DATE  STRING  COMMENT  '验资日期',
  PRIVATE_PLACEMENT_SHARENUM  DECIMAL(18,2)  COMMENT  '定向配售数量(万股)',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国A股增发'
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
            "username": "${wind_username}",
            "password": "${wind_password}",
            "connection": [{
              "querySql": ["SELECT  OBJECT_ID
                                   , S_INFO_WINDCODE
                                   , S_FELLOW_PROGRESS
                                   , S_FELLOW_ISSUETYPE
                                   , CRNCY_CODE
                                   , S_FELLOW_PRICE
                                   , S_FELLOW_AMOUNT
                                   , S_FELLOW_COLLECTION
                                   , S_FELLOW_RECORDDATE
                                   , S_FELLOW_PAYSTARTDATE
                                   , S_FELLOW_PAYENDDATE
                                   , S_FELLOW_SUBDATE
                                   , S_FELLOW_OTCDATE
                                   , S_FELLOW_LISTDATE
                                   , S_FELLOW_INSTLISTDATE
                                   , S_FELLOW_CHANGEDATE
                                   , S_FELLOW_ROADSHOWDATE
                                   , S_FELLOW_REFUNDDATE
                                   , S_FELLOW_UNFROZEDATE
                                   , S_FELLOW_PREPLANDATE
                                   , S_FELLOW_SMTGANNCEDATE
                                   , S_FELLOW_PASSDATE
                                   , S_FELLOW_APPROVEDDATE
                                   , S_FELLOW_ANNCEDATE
                                   , S_FELLOW_RATIOANNCEDATE
                                   , S_FELLOW_OFFERINGDATE
                                   , S_FELLOW_LISTANNDATE
                                   , S_FELLOW_OFFERINGOBJECT
                                   , S_FELLOW_PRICEUPLIMIT
                                   , S_FELLOW_PRICEDOWNLIMIT
                                   , S_SEO_CODE
                                   , S_SEO_NAME
                                   , S_SEO_PE
                                   , S_SEO_AMTBYPLACING
                                   , S_SEO_AMTTOJUR
                                   , S_SEO_HOLDERSUBSMODE
                                   , S_SEO_HOLDERSUBSRATE
                                   , ANN_DT
                                   , PRICINGMODE
                                   , S_FELLOW_ORGPRICEMIN
                                   , S_FELLOW_DISCNTRATIO
                                   , S_FELLOW_DATE
                                   , S_FELLOW_SUBINVITATIONDT
                                   , S_FELLOW_YEAR
                                   , S_FELLOW_OBJECTIVE_CODE
                                   , PRICINGDATE
                                   , IS_NO_PUBLIC
                                   , EXPENSE
                                   , S_RIGHTSISSUE_EXDIVIDENDDATE
                                   , IS_EXDIVIDEND
                                   , SUB_MODE
                                   , OLDSPLA_MOLE
                                   , OLDSPLA_MODE
                                   , EXP_COLLECTION
                                   , S_FELLOW_TYPE
                                   , S_FELLOW_OBJECTIVE
                                   , S_FELLOW_OFFERINGOBJECT_DES
                                   , EVENT_ID
                                   , PRICE_CONDITION
                                   , PRICE_DT_TYPE
                                   , ORGPRICE_PCT
                                   , ACTPRICE_PCT
                                   , APPRVBYSASSC_DT
                                   , S_FELLOW_INITIAL_PLAN
                                   , LEADUNDERWRITER
                                   , CURRENCY_SUBSCRIPTION_NUM
                                   , NON_MONETARY_SUBSCRIPTION_NUM
                                   , CURRENCY_SUBSCRIPTION_AMOUNT
                                   , NOCURRENCY_SUBSCRIPTION_AMOUNT
                                   , IS_CONTAIN_HOLDER
                                   , OLDSPLA_DENOMINATOR
                                   , NUM_SHARES_PREAONLINE
                                   , SHARE_RECORDDATE
                                   , ADD_SUBSCRIPTION_STARTDATE
                                   , ADD_SUBSCRIPTION_ENDDATE
                                   , FUND_VERIFICATION_DATE
                                   , PRIVATE_PLACEMENT_SHARENUM
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.ASHARESEO"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "S_FELLOW_PROGRESS", "type": "DOUBLE"}, {"name": "S_FELLOW_ISSUETYPE", "type": "STRING"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "S_FELLOW_PRICE", "type": "DOUBLE"}, {"name": "S_FELLOW_AMOUNT", "type": "DOUBLE"}, {"name": "S_FELLOW_COLLECTION", "type": "DOUBLE"}, {"name": "S_FELLOW_RECORDDATE", "type": "STRING"}, {"name": "S_FELLOW_PAYSTARTDATE", "type": "STRING"}, {"name": "S_FELLOW_PAYENDDATE", "type": "STRING"}, {"name": "S_FELLOW_SUBDATE", "type": "STRING"}, {"name": "S_FELLOW_OTCDATE", "type": "STRING"}, {"name": "S_FELLOW_LISTDATE", "type": "STRING"}, {"name": "S_FELLOW_INSTLISTDATE", "type": "STRING"}, {"name": "S_FELLOW_CHANGEDATE", "type": "STRING"}, {"name": "S_FELLOW_ROADSHOWDATE", "type": "STRING"}, {"name": "S_FELLOW_REFUNDDATE", "type": "STRING"}, {"name": "S_FELLOW_UNFROZEDATE", "type": "STRING"}, {"name": "S_FELLOW_PREPLANDATE", "type": "STRING"}, {"name": "S_FELLOW_SMTGANNCEDATE", "type": "STRING"}, {"name": "S_FELLOW_PASSDATE", "type": "STRING"}, {"name": "S_FELLOW_APPROVEDDATE", "type": "STRING"}, {"name": "S_FELLOW_ANNCEDATE", "type": "STRING"}, {"name": "S_FELLOW_RATIOANNCEDATE", "type": "STRING"}, {"name": "S_FELLOW_OFFERINGDATE", "type": "STRING"}, {"name": "S_FELLOW_LISTANNDATE", "type": "STRING"}, {"name": "S_FELLOW_OFFERINGOBJECT", "type": "STRING"}, {"name": "S_FELLOW_PRICEUPLIMIT", "type": "DOUBLE"}, {"name": "S_FELLOW_PRICEDOWNLIMIT", "type": "DOUBLE"}, {"name": "S_SEO_CODE", "type": "STRING"}, {"name": "S_SEO_NAME", "type": "STRING"}, {"name": "S_SEO_PE", "type": "DOUBLE"}, {"name": "S_SEO_AMTBYPLACING", "type": "DOUBLE"}, {"name": "S_SEO_AMTTOJUR", "type": "DOUBLE"}, {"name": "S_SEO_HOLDERSUBSMODE", "type": "STRING"}, {"name": "S_SEO_HOLDERSUBSRATE", "type": "DOUBLE"}, {"name": "ANN_DT", "type": "STRING"}, {"name": "PRICINGMODE", "type": "DOUBLE"}, {"name": "S_FELLOW_ORGPRICEMIN", "type": "DOUBLE"}, {"name": "S_FELLOW_DISCNTRATIO", "type": "DOUBLE"}, {"name": "S_FELLOW_DATE", "type": "STRING"}, {"name": "S_FELLOW_SUBINVITATIONDT", "type": "STRING"}, {"name": "S_FELLOW_YEAR", "type": "STRING"}, {"name": "S_FELLOW_OBJECTIVE_CODE", "type": "DOUBLE"}, {"name": "PRICINGDATE", "type": "STRING"}, {"name": "IS_NO_PUBLIC", "type": "DOUBLE"}, {"name": "EXPENSE", "type": "DOUBLE"}, {"name": "S_RIGHTSISSUE_EXDIVIDENDDATE", "type": "STRING"}, {"name": "IS_EXDIVIDEND", "type": "DOUBLE"}, {"name": "SUB_MODE", "type": "DOUBLE"}, {"name": "OLDSPLA_MOLE", "type": "DOUBLE"}, {"name": "OLDSPLA_MODE", "type": "STRING"}, {"name": "EXP_COLLECTION", "type": "DOUBLE"}, {"name": "S_FELLOW_TYPE", "type": "STRING"}, {"name": "S_FELLOW_OBJECTIVE", "type": "STRING"}, {"name": "S_FELLOW_OFFERINGOBJECT_DES", "type": "STRING"}, {"name": "EVENT_ID", "type": "STRING"}, {"name": "PRICE_CONDITION", "type": "STRING"}, {"name": "PRICE_DT_TYPE", "type": "STRING"}, {"name": "ORGPRICE_PCT", "type": "DOUBLE"}, {"name": "ACTPRICE_PCT", "type": "DOUBLE"}, {"name": "APPRVBYSASSC_DT", "type": "STRING"}, {"name": "S_FELLOW_INITIAL_PLAN", "type": "STRING"}, {"name": "LEADUNDERWRITER", "type": "STRING"}, {"name": "CURRENCY_SUBSCRIPTION_NUM", "type": "DOUBLE"}, {"name": "NON_MONETARY_SUBSCRIPTION_NUM", "type": "DOUBLE"}, {"name": "CURRENCY_SUBSCRIPTION_AMOUNT", "type": "DOUBLE"}, {"name": "NOCURRENCY_SUBSCRIPTION_AMOUNT", "type": "DOUBLE"}, {"name": "IS_CONTAIN_HOLDER", "type": "DOUBLE"}, {"name": "OLDSPLA_DENOMINATOR", "type": "DOUBLE"}, {"name": "NUM_SHARES_PREAONLINE", "type": "DOUBLE"}, {"name": "SHARE_RECORDDATE", "type": "STRING"}, {"name": "ADD_SUBSCRIPTION_STARTDATE", "type": "STRING"}, {"name": "ADD_SUBSCRIPTION_ENDDATE", "type": "STRING"}, {"name": "FUND_VERIFICATION_DATE", "type": "STRING"}, {"name": "PRIVATE_PLACEMENT_SHARENUM", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_ashareseo_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_ashareseo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_ashareseo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_ashareseo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_ASHARESEO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_ASHARESEO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_ashareseo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_ASHARESEO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , S_FELLOW_PROGRESS
     , S_FELLOW_ISSUETYPE
     , CRNCY_CODE
     , S_FELLOW_PRICE
     , S_FELLOW_AMOUNT
     , S_FELLOW_COLLECTION
     , S_FELLOW_RECORDDATE
     , S_FELLOW_PAYSTARTDATE
     , S_FELLOW_PAYENDDATE
     , S_FELLOW_SUBDATE
     , S_FELLOW_OTCDATE
     , S_FELLOW_LISTDATE
     , S_FELLOW_INSTLISTDATE
     , S_FELLOW_CHANGEDATE
     , S_FELLOW_ROADSHOWDATE
     , S_FELLOW_REFUNDDATE
     , S_FELLOW_UNFROZEDATE
     , S_FELLOW_PREPLANDATE
     , S_FELLOW_SMTGANNCEDATE
     , S_FELLOW_PASSDATE
     , S_FELLOW_APPROVEDDATE
     , S_FELLOW_ANNCEDATE
     , S_FELLOW_RATIOANNCEDATE
     , S_FELLOW_OFFERINGDATE
     , S_FELLOW_LISTANNDATE
     , S_FELLOW_OFFERINGOBJECT
     , S_FELLOW_PRICEUPLIMIT
     , S_FELLOW_PRICEDOWNLIMIT
     , S_SEO_CODE
     , S_SEO_NAME
     , S_SEO_PE
     , S_SEO_AMTBYPLACING
     , S_SEO_AMTTOJUR
     , S_SEO_HOLDERSUBSMODE
     , S_SEO_HOLDERSUBSRATE
     , ANN_DT
     , PRICINGMODE
     , S_FELLOW_ORGPRICEMIN
     , S_FELLOW_DISCNTRATIO
     , S_FELLOW_DATE
     , S_FELLOW_SUBINVITATIONDT
     , S_FELLOW_YEAR
     , S_FELLOW_OBJECTIVE_CODE
     , PRICINGDATE
     , IS_NO_PUBLIC
     , EXPENSE
     , S_RIGHTSISSUE_EXDIVIDENDDATE
     , IS_EXDIVIDEND
     , SUB_MODE
     , OLDSPLA_MOLE
     , OLDSPLA_MODE
     , EXP_COLLECTION
     , S_FELLOW_TYPE
     , S_FELLOW_OBJECTIVE
     , S_FELLOW_OFFERINGOBJECT_DES
     , EVENT_ID
     , PRICE_CONDITION
     , PRICE_DT_TYPE
     , ORGPRICE_PCT
     , ACTPRICE_PCT
     , APPRVBYSASSC_DT
     , S_FELLOW_INITIAL_PLAN
     , LEADUNDERWRITER
     , CURRENCY_SUBSCRIPTION_NUM
     , NON_MONETARY_SUBSCRIPTION_NUM
     , CURRENCY_SUBSCRIPTION_AMOUNT
     , NOCURRENCY_SUBSCRIPTION_AMOUNT
     , IS_CONTAIN_HOLDER
     , OLDSPLA_DENOMINATOR
     , NUM_SHARES_PREAONLINE
     , SHARE_RECORDDATE
     , ADD_SUBSCRIPTION_STARTDATE
     , ADD_SUBSCRIPTION_ENDDATE
     , FUND_VERIFICATION_DATE
     , PRIVATE_PLACEMENT_SHARENUM
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_ASHARESEO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHARESEO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_ASHARESEO_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_ASHARESEO_PFD成功"
      exit 0
   fi
fi
