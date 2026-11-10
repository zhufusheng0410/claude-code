#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_REPORT_CODE  STRING  COMMENT  '申报代码',
  VC_STOCK_NAME  STRING  COMMENT  '证券名称',
  VC_STOCK_SPELL  STRING  COMMENT  '证券拼音码',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  C_ASSET_CLASS  STRING  COMMENT  '资产类别',
  EN_UPLIMITED_RATIO  DECIMAL(15,8)  COMMENT  '涨停板比例',
  EN_DOWNLIMITED_RATIO  DECIMAL(15,8)  COMMENT  '跌停板比例',
  L_UPLIMITED_AMOUNT  DECIMAL(20,4)  COMMENT  '最高数量限额',
  L_DOWNLIMITED_AMOUNT  DECIMAL(20,4)  COMMENT  '最低数量限额',
  C_DEFAULT_PRICE  STRING  COMMENT  '价格模式',
  VC_FROZEN_CODE  STRING  COMMENT  '委托冻结代码',
  VC_RELATIVE_FROZEN_CODE  STRING  COMMENT  '委托关联冻结代码',
  VC_ASSIGN_CODE  STRING  COMMENT  '配售关联代码',
  VC_ASSET_RELATIVE_CODE  STRING  COMMENT  '资产关联代码',
  VC_MATCH_RELATIVE1_CODE  STRING  COMMENT  '配对关联代码1',
  VC_MATCH_RELATIVE2_CODE  STRING  COMMENT  '配对关联代码2',
  L_TOTAL_AMOUNT  DECIMAL(16,0)  COMMENT  '总股本',
  L_TURNOVER_AMOUNT  DECIMAL(16,0)  COMMENT  '流通股本',
  EN_REPAY_YEAR  DECIMAL(14,8)  COMMENT  '市盈率',
  L_COMPANY_ID  DECIMAL(10,0)  COMMENT  '*发行公司',
  VC_MIXED_TYPE  STRING  COMMENT  '杂项分类',
  L_NEAR_AMOUNT  DECIMAL(16,0)  COMMENT  '靠档股本',
  L_PUBLISH_DATE  DECIMAL(8,0)  COMMENT  '发行日期',
  L_TURNOVER_DATE  DECIMAL(8,0)  COMMENT  '可流通日期',
  L_TOTAL_LOCK_DAYS  DECIMAL(8,0)  COMMENT  '总锁定天数',
  L_LEFT_LOCK_DAYS  DECIMAL(8,0)  COMMENT  '可流通剩余天数',
  VC_STOCK_FULLNAME  STRING  COMMENT  '证券全称',
  C_STOP_FLAG  STRING  COMMENT  '停牌标志',
  EN_LAST_PRICE  DECIMAL(16,8)  COMMENT  '最新价/今收盘价',
  VC_INTERNATIONAL_CODE  STRING  COMMENT  '国际代码',
  VC_RIC_CODE  STRING  COMMENT  '国际代码',
  VC_SEDOL_CODE  STRING  COMMENT  '伦敦代码',
  VC_CUSIP_CODE  STRING  COMMENT  '美国代码',
  VC_BLOOMBERG_CODE  STRING  COMMENT  '彭博代码',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  EN_FACE_VALUES  DECIMAL(16,8)  COMMENT  '面值',
  L_LISTING_DATE  DECIMAL(8,0)  COMMENT  '网上上市日期',
  C_LONG_STOP_FLAG  STRING  COMMENT  '长期停牌标志',
  VC_ACTUAL_CODE  STRING  COMMENT  '实际代码',
  L_BUY_UNIT  DECIMAL(20,4)  COMMENT  '买入最小单位',
  L_SALE_UNIT  DECIMAL(20,4)  COMMENT  '卖出最小单位',
  VC_ISSUE_COUNTRY  STRING  COMMENT  '发行国家/地区',
  VC_RISK_COUNTRY  STRING  COMMENT  '风险国家/地区',
  L_WX_LISTING_DATE  DECIMAL(8,0)  COMMENT  '网下上市日期',
  L_ADD_DATE  DECIMAL(8,0)  COMMENT  '增加日期',
  EN_ESTIMATE_PROB  DECIMAL(9,8)  COMMENT  '#累计询价预估中签率',
  VC_TRADE_CURRENCY_NO  STRING  COMMENT  '交易币种',
  VC_ACCOUNTANT_STOCK_CODE  STRING  COMMENT  '证券会计编码',
  L_UNDERWRITER_ID  STRING  COMMENT  '承销机构',
  EN_RIGHT_PRICE  DECIMAL(16,8)  COMMENT  '复权价格',
  EN_VENUEESTIMATE_PROB  DECIMAL(9,8)  COMMENT  '预估中签率',
  C_IPO_MARKETCAP  STRING  COMMENT  '按市值申购',
  VC_REFERENCE_FA_CODE  STRING  COMMENT  '参照估值代码',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_AMOUNT_PER_HAND  DECIMAL(10,0)  COMMENT  '每手股数',
  C_TRADE_ACTIVE  STRING  COMMENT  '交易活跃',
  C_BS_FLAG  STRING  COMMENT  '买卖标志',
  C_CQCX  STRING  COMMENT  '除权除息标志',
  L_ZSSSL  DECIMAL(10,0)  COMMENT  '做市商数量',
  C_HZJY_FLAG  STRING  COMMENT  '回转交易标志',
  C_STOCK_FEE_TYPE  STRING  COMMENT  '证券费用子类',
  L_ISSUE_TOTAL_AMOUNT  DECIMAL(16,0)  COMMENT  '发行总股本',
  EN_LOWEST_INQUERY_VALUE  DECIMAL(20,4)  COMMENT  '网下询价最低市值',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '结束日期',
  VC_SZ_STOCKSTATUS  STRING  COMMENT  '深证状态',
  EN_PRE_CLOSE_PRICE  DECIMAL(16,4)  COMMENT  '前收盘价'
)
COMMENT '证券信息表'
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
            "username": "${o32_username}",
            "password": "${o32_password}",
            "connection": [{
              "querySql": ["SELECT  L_DATE
                                   , VC_INTER_CODE
                                   , C_MARKET_NO
                                   , VC_REPORT_CODE
                                   , VC_STOCK_NAME
                                   , VC_STOCK_SPELL
                                   , C_STOCK_TYPE
                                   , C_ASSET_CLASS
                                   , EN_UPLIMITED_RATIO
                                   , EN_DOWNLIMITED_RATIO
                                   , L_UPLIMITED_AMOUNT
                                   , L_DOWNLIMITED_AMOUNT
                                   , C_DEFAULT_PRICE
                                   , VC_FROZEN_CODE
                                   , VC_RELATIVE_FROZEN_CODE
                                   , VC_ASSIGN_CODE
                                   , VC_ASSET_RELATIVE_CODE
                                   , VC_MATCH_RELATIVE1_CODE
                                   , VC_MATCH_RELATIVE2_CODE
                                   , L_TOTAL_AMOUNT
                                   , L_TURNOVER_AMOUNT
                                   , EN_REPAY_YEAR
                                   , L_COMPANY_ID
                                   , VC_MIXED_TYPE
                                   , L_NEAR_AMOUNT
                                   , L_PUBLISH_DATE
                                   , L_TURNOVER_DATE
                                   , L_TOTAL_LOCK_DAYS
                                   , L_LEFT_LOCK_DAYS
                                   , VC_STOCK_FULLNAME
                                   , C_STOP_FLAG
                                   , EN_LAST_PRICE
                                   , VC_INTERNATIONAL_CODE
                                   , VC_RIC_CODE
                                   , VC_SEDOL_CODE
                                   , VC_CUSIP_CODE
                                   , VC_BLOOMBERG_CODE
                                   , VC_CURRENCY_NO
                                   , EN_FACE_VALUES
                                   , L_LISTING_DATE
                                   , C_LONG_STOP_FLAG
                                   , VC_ACTUAL_CODE
                                   , L_BUY_UNIT
                                   , L_SALE_UNIT
                                   , VC_ISSUE_COUNTRY
                                   , VC_RISK_COUNTRY
                                   , L_WX_LISTING_DATE
                                   , L_ADD_DATE
                                   , EN_ESTIMATE_PROB
                                   , VC_TRADE_CURRENCY_NO
                                   , VC_ACCOUNTANT_STOCK_CODE
                                   , L_UNDERWRITER_ID
                                   , EN_RIGHT_PRICE
                                   , EN_VENUEESTIMATE_PROB
                                   , C_IPO_MARKETCAP
                                   , VC_REFERENCE_FA_CODE
                                   , VC_TIMESTAMP
                                   , L_AMOUNT_PER_HAND
                                   , C_TRADE_ACTIVE
                                   , C_BS_FLAG
                                   , C_CQCX
                                   , L_ZSSSL
                                   , C_HZJY_FLAG
                                   , C_STOCK_FEE_TYPE
                                   , L_ISSUE_TOTAL_AMOUNT
                                   , EN_LOWEST_INQUERY_VALUE
                                   , L_END_DATE
                                   , VC_SZ_STOCKSTATUS
                                   , EN_PRE_CLOSE_PRICE
                                FROM ${o32_src_schema}.THISSTOCKINFO
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "VC_STOCK_NAME", "type": "STRING"}, {"name": "VC_STOCK_SPELL", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "C_ASSET_CLASS", "type": "STRING"}, {"name": "EN_UPLIMITED_RATIO", "type": "DOUBLE"}, {"name": "EN_DOWNLIMITED_RATIO", "type": "DOUBLE"}, {"name": "L_UPLIMITED_AMOUNT", "type": "DOUBLE"}, {"name": "L_DOWNLIMITED_AMOUNT", "type": "DOUBLE"}, {"name": "C_DEFAULT_PRICE", "type": "STRING"}, {"name": "VC_FROZEN_CODE", "type": "STRING"}, {"name": "VC_RELATIVE_FROZEN_CODE", "type": "STRING"}, {"name": "VC_ASSIGN_CODE", "type": "STRING"}, {"name": "VC_ASSET_RELATIVE_CODE", "type": "STRING"}, {"name": "VC_MATCH_RELATIVE1_CODE", "type": "STRING"}, {"name": "VC_MATCH_RELATIVE2_CODE", "type": "STRING"}, {"name": "L_TOTAL_AMOUNT", "type": "DOUBLE"}, {"name": "L_TURNOVER_AMOUNT", "type": "DOUBLE"}, {"name": "EN_REPAY_YEAR", "type": "DOUBLE"}, {"name": "L_COMPANY_ID", "type": "DOUBLE"}, {"name": "VC_MIXED_TYPE", "type": "STRING"}, {"name": "L_NEAR_AMOUNT", "type": "DOUBLE"}, {"name": "L_PUBLISH_DATE", "type": "DOUBLE"}, {"name": "L_TURNOVER_DATE", "type": "DOUBLE"}, {"name": "L_TOTAL_LOCK_DAYS", "type": "DOUBLE"}, {"name": "L_LEFT_LOCK_DAYS", "type": "DOUBLE"}, {"name": "VC_STOCK_FULLNAME", "type": "STRING"}, {"name": "C_STOP_FLAG", "type": "STRING"}, {"name": "EN_LAST_PRICE", "type": "DOUBLE"}, {"name": "VC_INTERNATIONAL_CODE", "type": "STRING"}, {"name": "VC_RIC_CODE", "type": "STRING"}, {"name": "VC_SEDOL_CODE", "type": "STRING"}, {"name": "VC_CUSIP_CODE", "type": "STRING"}, {"name": "VC_BLOOMBERG_CODE", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "EN_FACE_VALUES", "type": "DOUBLE"}, {"name": "L_LISTING_DATE", "type": "DOUBLE"}, {"name": "C_LONG_STOP_FLAG", "type": "STRING"}, {"name": "VC_ACTUAL_CODE", "type": "STRING"}, {"name": "L_BUY_UNIT", "type": "DOUBLE"}, {"name": "L_SALE_UNIT", "type": "DOUBLE"}, {"name": "VC_ISSUE_COUNTRY", "type": "STRING"}, {"name": "VC_RISK_COUNTRY", "type": "STRING"}, {"name": "L_WX_LISTING_DATE", "type": "DOUBLE"}, {"name": "L_ADD_DATE", "type": "DOUBLE"}, {"name": "EN_ESTIMATE_PROB", "type": "DOUBLE"}, {"name": "VC_TRADE_CURRENCY_NO", "type": "STRING"}, {"name": "VC_ACCOUNTANT_STOCK_CODE", "type": "STRING"}, {"name": "L_UNDERWRITER_ID", "type": "STRING"}, {"name": "EN_RIGHT_PRICE", "type": "DOUBLE"}, {"name": "EN_VENUEESTIMATE_PROB", "type": "DOUBLE"}, {"name": "C_IPO_MARKETCAP", "type": "STRING"}, {"name": "VC_REFERENCE_FA_CODE", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_AMOUNT_PER_HAND", "type": "DOUBLE"}, {"name": "C_TRADE_ACTIVE", "type": "STRING"}, {"name": "C_BS_FLAG", "type": "STRING"}, {"name": "C_CQCX", "type": "STRING"}, {"name": "L_ZSSSL", "type": "DOUBLE"}, {"name": "C_HZJY_FLAG", "type": "STRING"}, {"name": "C_STOCK_FEE_TYPE", "type": "STRING"}, {"name": "L_ISSUE_TOTAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_LOWEST_INQUERY_VALUE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "VC_SZ_STOCKSTATUS", "type": "STRING"}, {"name": "EN_PRE_CLOSE_PRICE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstockinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstockinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstockinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstockinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTOCKINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTOCKINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstockinfo_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_INTER_CODE
     , C_MARKET_NO
     , VC_REPORT_CODE
     , VC_STOCK_NAME
     , VC_STOCK_SPELL
     , C_STOCK_TYPE
     , C_ASSET_CLASS
     , EN_UPLIMITED_RATIO
     , EN_DOWNLIMITED_RATIO
     , L_UPLIMITED_AMOUNT
     , L_DOWNLIMITED_AMOUNT
     , C_DEFAULT_PRICE
     , VC_FROZEN_CODE
     , VC_RELATIVE_FROZEN_CODE
     , VC_ASSIGN_CODE
     , VC_ASSET_RELATIVE_CODE
     , VC_MATCH_RELATIVE1_CODE
     , VC_MATCH_RELATIVE2_CODE
     , L_TOTAL_AMOUNT
     , L_TURNOVER_AMOUNT
     , EN_REPAY_YEAR
     , L_COMPANY_ID
     , VC_MIXED_TYPE
     , L_NEAR_AMOUNT
     , L_PUBLISH_DATE
     , L_TURNOVER_DATE
     , L_TOTAL_LOCK_DAYS
     , L_LEFT_LOCK_DAYS
     , VC_STOCK_FULLNAME
     , C_STOP_FLAG
     , EN_LAST_PRICE
     , VC_INTERNATIONAL_CODE
     , VC_RIC_CODE
     , VC_SEDOL_CODE
     , VC_CUSIP_CODE
     , VC_BLOOMBERG_CODE
     , VC_CURRENCY_NO
     , EN_FACE_VALUES
     , L_LISTING_DATE
     , C_LONG_STOP_FLAG
     , VC_ACTUAL_CODE
     , L_BUY_UNIT
     , L_SALE_UNIT
     , VC_ISSUE_COUNTRY
     , VC_RISK_COUNTRY
     , L_WX_LISTING_DATE
     , L_ADD_DATE
     , EN_ESTIMATE_PROB
     , VC_TRADE_CURRENCY_NO
     , VC_ACCOUNTANT_STOCK_CODE
     , L_UNDERWRITER_ID
     , EN_RIGHT_PRICE
     , EN_VENUEESTIMATE_PROB
     , C_IPO_MARKETCAP
     , VC_REFERENCE_FA_CODE
     , VC_TIMESTAMP
     , L_AMOUNT_PER_HAND
     , C_TRADE_ACTIVE
     , C_BS_FLAG
     , C_CQCX
     , L_ZSSSL
     , C_HZJY_FLAG
     , C_STOCK_FEE_TYPE
     , L_ISSUE_TOTAL_AMOUNT
     , EN_LOWEST_INQUERY_VALUE
     , L_END_DATE
     , VC_SZ_STOCKSTATUS
     , EN_PRE_CLOSE_PRICE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTOCKINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTOCKINFO_PFD成功"
      exit 0
   fi
fi
