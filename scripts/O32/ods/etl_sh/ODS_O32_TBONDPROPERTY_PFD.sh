#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBONDPROPERTY_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBONDPROPERTY_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_PUBLISH_DATE  DECIMAL(8,0)  COMMENT  '发行日期',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '结束日期',
  L_BEGINCAL_DATE  DECIMAL(8,0)  COMMENT  '起息日期',
  L_MARKET_DATE  DECIMAL(8,0)  COMMENT  '上市日期',
  EN_EXIST_LIMITE  DECIMAL(15,8)  COMMENT  '期限',
  EN_PUBLISH_PRICE  DECIMAL(16,8)  COMMENT  '发行价',
  EN_FACE_PRICE  DECIMAL(16,8)  COMMENT  '面额',
  EN_YEAR_RATE  DECIMAL(9,8)  COMMENT  '票面利率',
  L_RATE_DAYS  DECIMAL(10,0)  COMMENT  '记息天数',
  EN_PAY_INTEVAL  DECIMAL(9,2)  COMMENT  '年付息次数',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  EN_BOND_INTEREST  DECIMAL(18,12)  COMMENT  '百元债券利息',
  EN_REAL_INTEREST  DECIMAL(18,12)  COMMENT  '实际利息',
  EN_NEXT_BOND_INTEREST  DECIMAL(18,12)  COMMENT  '下一日利息',
  C_SUBJECT_TYPE  STRING  COMMENT  '计算科目类别',
  L_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '维护日期',
  L_NEXT_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '下次维护日期',
  C_INSIDE_APPRAISE  STRING  COMMENT  '内部评级',
  C_OUTER_APPRAISE  STRING  COMMENT  '外部评级',
  EN_BASIC_RATE  DECIMAL(9,8)  COMMENT  '基本利差',
  C_BASIC_RATE_TYPE  STRING  COMMENT  '基准类别',
  EN_LEAST_RATE  DECIMAL(9,8)  COMMENT  '保底利率',
  C_INVESTOR_OPERATION_TYPE  STRING  COMMENT  '投资人选择权类型',
  L_INVESTOR_OPERATION_DATE  DECIMAL(8,0)  COMMENT  '投资人行权日期',
  C_PUBLISHER_OPERATION_TYPE  STRING  COMMENT  '发行人选择权类型',
  L_PUBLISHER_OPERATION_DATE  DECIMAL(8,0)  COMMENT  '发行人行权日期',
  C_TRUSTEE  STRING  COMMENT  '托管机构',
  C_NET_PRICE  STRING  COMMENT  '净价标志',
  VC_APPRAISE_ORGAN  STRING  COMMENT  '外部评级机构',
  C_INTEREST_TYPE  STRING  COMMENT  '利率类型',
  C_PAY_INTEREST_TYPE  STRING  COMMENT  '付息类型',
  L_LEFT_TERM  DECIMAL(10,0)  COMMENT  '剩余久期＃',
  EN_MATURITY  DECIMAL(16,8)  COMMENT  '麦氏久期',
  EN_MATURITY_ADJUST  DECIMAL(16,8)  COMMENT  '修正久期＃',
  EN_CHANGE_PRICE  DECIMAL(8,4)  COMMENT  't日转股价格',
  L_CHANGE_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '转股开始日期',
  L_CHANGE_END_DATE  DECIMAL(8,0)  COMMENT  '转股结束日期',
  EN_INVESTOR_OPERATION_PRICE  DECIMAL(16,8)  COMMENT  '投资人行权价格',
  EN_PUBLISHER_OPERATION_PRICE  DECIMAL(16,8)  COMMENT  '发行人行权价格',
  L_TRADE_DEADLINE  DECIMAL(8,0)  COMMENT  '交易结束日期',
  EN_FAIR_YIELD_RATIO  DECIMAL(11,8)  COMMENT  '中债登公允收益率',
  EN_VALUATE_DURATION  DECIMAL(16,8)  COMMENT  '估价修正久期',
  EN_VALUATE_CONVEXITY  DECIMAL(16,8)  COMMENT  '估价凸性',
  EN_VALUATE_POINT_VALUE  DECIMAL(16,8)  COMMENT  '估价基点价值',
  EN_VALUATE_SPREAD_DURATION  DECIMAL(16,8)  COMMENT  '估价利差久期',
  EN_VALUATE_RATE_DURATION  DECIMAL(16,8)  COMMENT  '估价利率久期',
  EN_YESTERDAY_CHANGE_PRICE  DECIMAL(8,4)  COMMENT  't-1日转股价格',
  EN_POINT_VALUE  DECIMAL(16,8)  COMMENT  '基点价值',
  EN_CONVEXITY  DECIMAL(16,8)  COMMENT  '凸性',
  L_STARTCAL_DATE  DECIMAL(8,0)  COMMENT  '原始起息日',
  C_INTEREST_CALC_TYPE  STRING  COMMENT  '利息计算方法',
  C_PAYMENTOFINTEREST_TYPE  STRING  COMMENT  '到期付息方式',
  L_GUARANTOR_ID  DECIMAL(10,0)  COMMENT  '担保人',
  EN_BP_CEILING  DECIMAL(5,4)  COMMENT  '利率调整基点上限',
  EN_BP_FLOOR  DECIMAL(5,4)  COMMENT  '利率调整基点下限',
  L_YEAR  DECIMAL(10,0)  COMMENT  '年份',
  L_TIMES  DECIMAL(10,0)  COMMENT  '期数',
  EN_CURR_FACE_PRICE  DECIMAL(16,8)  COMMENT  '当前面额',
  C_RATEDAYS_CALC_TYPE  STRING  COMMENT  '计息天数计算类型',
  L_NEXTPAYMENT_DATE  DECIMAL(8,0)  COMMENT  '下一付息日',
  C_MOODY_APPRAISE  STRING  COMMENT  '穆迪评级',
  C_SP_APPRAISE  STRING  COMMENT  '标普评级',
  C_FITCH_APPRAISE  STRING  COMMENT  '惠誉评级',
  C_OTHER_APPRAISE_ONE  STRING  COMMENT  '其它评级一',
  C_OTHER_APPRAISE_TWO  STRING  COMMENT  '其它评级二',
  C_YIELD_RATIO_TYPE  STRING  COMMENT  '收益率类型',
  EN_TODAY_INTEREST  DECIMAL(18,12)  COMMENT  '当日利息',
  C_INTEREST_TYPE_EX  STRING  COMMENT  '扩展利率类型',
  C_PAY_CAPITAL_TYPE  STRING  COMMENT  '本金偿还类型',
  L_OUTER_APPRAISE_DATE  DECIMAL(8,0)  COMMENT  '外部评级日期',
  L_ZQHS_BEGINDATE  DECIMAL(8,0)  COMMENT  '债回售登记开始日期',
  L_ZQHS_ENDDATE  DECIMAL(8,0)  COMMENT  '债回售登记结束日期',
  L_SUPERVENTION_MARKET_DATE  DECIMAL(8,0)  COMMENT  '续发上市日期',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_BOND_COUNT  DECIMAL(10,0)  COMMENT  '债券期数',
  L_NEXT_RATECHANGE_DATE  DECIMAL(8,0)  COMMENT  '下一利息调整日',
  C_DRAWBENCHMRK  STRING  COMMENT  '计息基准',
  EN_ACCRUED_INTEREST  DECIMAL(10,8)  COMMENT  '应计利息',
  L_ISSUEBALANCE  DECIMAL(16,0)  COMMENT  '债券发行余额',
  EN_ZZ_FAIR_YIELD_RATIO  DECIMAL(9,8)  COMMENT  '中证公允收益率',
  C_HEDGE_APPRAISE  STRING  COMMENT  '',
  C_LEVEL_EXPECTATION  STRING  COMMENT  '评级展望',
  C_OTHER_APPRAISE_THREE  STRING  COMMENT  '其他评级三',
  C_OTHER_APPRAISE_FOUR  STRING  COMMENT  '其他评级四',
  C_PASS_SPPI_TEST  STRING  COMMENT  '是否通过sppi测试',
  VC_SPPI_FAIL_REASON  STRING  COMMENT  '',
  EN_SPPI_DOWNLIMIT_PRICE  DECIMAL(16,8)  COMMENT  '',
  C_ISSPECIAL  STRING  COMMENT  '',
  C_ISENDDEFAULT  STRING  COMMENT  '',
  C_ISFTABOND  STRING  COMMENT  '',
  VC_DCQ  STRING  COMMENT  '',
  VC_PARTY_NO  STRING  COMMENT  '',
  VC_BONDTYPE_NAME  STRING  COMMENT  '',
  VC_BONDTYPE_ID  STRING  COMMENT  '',
  C_OFFERRINGCANCELFLAG  STRING  COMMENT  '',
  EN_HQZ_XQGZ_PRICE  DECIMAL(16,8)  COMMENT  '含权债行权估值净价fim使用',
  EN_HQZ_XQGZ_YIELD_RATIO  DECIMAL(9,8)  COMMENT  '含权债行权估值收益率fim使用',
  EN_HQZ_XQGZ_DURATION  DECIMAL(16,8)  COMMENT  '含权债行权估值久期fim使用',
  EN_HQZ_XQGZ_CONVEXITY  DECIMAL(16,8)  COMMENT  '含权债行权估值凸性fim使用',
  EN_HZQ_XQGZ_VP_VALUE  DECIMAL(16,8)  COMMENT  '含权债行权估值基点价值fim使用',
  VC_SPECIALPLAN_CODE  STRING  COMMENT  '',
  EN_DELTA  DECIMAL(16,8)  COMMENT  '',
  EN_ZZD_NONRECOMMEND_RATIO  DECIMAL(9,8)  COMMENT  '',
  VC_TIMESTAMP2  STRING  COMMENT  '',
  VC_FINAL_DEBTORS  STRING  COMMENT  '',
  C_ODM  STRING  COMMENT  '',
  C_CENTER_MATCH  STRING  COMMENT  '',
  C_ISUNSECURED  STRING  COMMENT  '',
  C_IS_HISDATA  STRING  COMMENT  '',
  C_BOND_FLAG  STRING  COMMENT  '',
  L_SPECBOND_BEGINDATE  DECIMAL(8,0)  COMMENT  '',
  EN_NEXT_TRADEDATE_RATIO  DECIMAL(18,12)  COMMENT  '',
  EN_PUREDEBT_VALUE  DECIMAL(16,8)  COMMENT  '',
  VC_SPPI_EXTRAINFO  STRING  COMMENT  '',
  C_PUTBACK_RESELL_FLAG  STRING  COMMENT  '',
  VC_TIMESTAMP3  STRING  COMMENT  '',
  VC_ORIGINAL_BEARER  STRING  COMMENT  '',
  VC_ACCEPTOR  STRING  COMMENT  '',
  VC_DISCOUNT_CLERK  STRING  COMMENT  '',
  C_IS_FORCEREDEEM  STRING  COMMENT  '',
  C_CITY_RANK  STRING  COMMENT  '',
  VC_GUARANTOR_IDS  STRING  COMMENT  '',
  L_PAYMENT_DATE  DECIMAL(8,0)  COMMENT  ''
)
COMMENT '债券属性表'
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
                                   , L_PUBLISH_DATE
                                   , L_END_DATE
                                   , L_BEGINCAL_DATE
                                   , L_MARKET_DATE
                                   , EN_EXIST_LIMITE
                                   , EN_PUBLISH_PRICE
                                   , EN_FACE_PRICE
                                   , EN_YEAR_RATE
                                   , L_RATE_DAYS
                                   , EN_PAY_INTEVAL
                                   , C_MARKET_NO
                                   , EN_BOND_INTEREST
                                   , EN_REAL_INTEREST
                                   , EN_NEXT_BOND_INTEREST
                                   , C_SUBJECT_TYPE
                                   , L_MODIFY_DATE
                                   , L_NEXT_MODIFY_DATE
                                   , C_INSIDE_APPRAISE
                                   , C_OUTER_APPRAISE
                                   , EN_BASIC_RATE
                                   , C_BASIC_RATE_TYPE
                                   , EN_LEAST_RATE
                                   , C_INVESTOR_OPERATION_TYPE
                                   , L_INVESTOR_OPERATION_DATE
                                   , C_PUBLISHER_OPERATION_TYPE
                                   , L_PUBLISHER_OPERATION_DATE
                                   , C_TRUSTEE
                                   , C_NET_PRICE
                                   , VC_APPRAISE_ORGAN
                                   , C_INTEREST_TYPE
                                   , C_PAY_INTEREST_TYPE
                                   , L_LEFT_TERM
                                   , EN_MATURITY
                                   , EN_MATURITY_ADJUST
                                   , EN_CHANGE_PRICE
                                   , L_CHANGE_BEGIN_DATE
                                   , L_CHANGE_END_DATE
                                   , EN_INVESTOR_OPERATION_PRICE
                                   , EN_PUBLISHER_OPERATION_PRICE
                                   , L_TRADE_DEADLINE
                                   , EN_FAIR_YIELD_RATIO
                                   , EN_VALUATE_DURATION
                                   , EN_VALUATE_CONVEXITY
                                   , EN_VALUATE_POINT_VALUE
                                   , EN_VALUATE_SPREAD_DURATION
                                   , EN_VALUATE_RATE_DURATION
                                   , EN_YESTERDAY_CHANGE_PRICE
                                   , EN_POINT_VALUE
                                   , EN_CONVEXITY
                                   , L_STARTCAL_DATE
                                   , C_INTEREST_CALC_TYPE
                                   , C_PAYMENTOFINTEREST_TYPE
                                   , L_GUARANTOR_ID
                                   , EN_BP_CEILING
                                   , EN_BP_FLOOR
                                   , L_YEAR
                                   , L_TIMES
                                   , EN_CURR_FACE_PRICE
                                   , C_RATEDAYS_CALC_TYPE
                                   , L_NEXTPAYMENT_DATE
                                   , C_MOODY_APPRAISE
                                   , C_SP_APPRAISE
                                   , C_FITCH_APPRAISE
                                   , C_OTHER_APPRAISE_ONE
                                   , C_OTHER_APPRAISE_TWO
                                   , C_YIELD_RATIO_TYPE
                                   , EN_TODAY_INTEREST
                                   , C_INTEREST_TYPE_EX
                                   , C_PAY_CAPITAL_TYPE
                                   , L_OUTER_APPRAISE_DATE
                                   , L_ZQHS_BEGINDATE
                                   , L_ZQHS_ENDDATE
                                   , L_SUPERVENTION_MARKET_DATE
                                   , L_VIRTUAL_KEY
                                   , VC_TIMESTAMP
                                   , L_BOND_COUNT
                                   , L_NEXT_RATECHANGE_DATE
                                   , C_DRAWBENCHMRK
                                   , EN_ACCRUED_INTEREST
                                   , L_ISSUEBALANCE
                                   , EN_ZZ_FAIR_YIELD_RATIO
                                   , C_HEDGE_APPRAISE
                                   , C_LEVEL_EXPECTATION
                                   , C_OTHER_APPRAISE_THREE
                                   , C_OTHER_APPRAISE_FOUR
                                   , C_PASS_SPPI_TEST
                                   , VC_SPPI_FAIL_REASON
                                   , EN_SPPI_DOWNLIMIT_PRICE
                                   , C_ISSPECIAL
                                   , C_ISENDDEFAULT
                                   , C_ISFTABOND
                                   , VC_DCQ
                                   , VC_PARTY_NO
                                   , VC_BONDTYPE_NAME
                                   , VC_BONDTYPE_ID
                                   , C_OFFERRINGCANCELFLAG
                                   , EN_HQZ_XQGZ_PRICE
                                   , EN_HQZ_XQGZ_YIELD_RATIO
                                   , EN_HQZ_XQGZ_DURATION
                                   , EN_HQZ_XQGZ_CONVEXITY
                                   , EN_HZQ_XQGZ_VP_VALUE
                                   , VC_SPECIALPLAN_CODE
                                   , EN_DELTA
                                   , EN_ZZD_NONRECOMMEND_RATIO
                                   , VC_TIMESTAMP2
                                   , VC_FINAL_DEBTORS
                                   , C_ODM
                                   , C_CENTER_MATCH
                                   , C_ISUNSECURED
                                   , C_IS_HISDATA
                                   , C_BOND_FLAG
                                   , L_SPECBOND_BEGINDATE
                                   , EN_NEXT_TRADEDATE_RATIO
                                   , EN_PUREDEBT_VALUE
                                   , VC_SPPI_EXTRAINFO
                                   , C_PUTBACK_RESELL_FLAG
                                   , VC_TIMESTAMP3
                                   , VC_ORIGINAL_BEARER
                                   , VC_ACCEPTOR
                                   , VC_DISCOUNT_CLERK
                                   , C_IS_FORCEREDEEM
                                   , C_CITY_RANK
                                   , VC_GUARANTOR_IDS
                                   , L_PAYMENT_DATE
                                FROM ${o32_src_schema}.THISBONDPROPERTY
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_PUBLISH_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "L_BEGINCAL_DATE", "type": "DOUBLE"}, {"name": "L_MARKET_DATE", "type": "DOUBLE"}, {"name": "EN_EXIST_LIMITE", "type": "DOUBLE"}, {"name": "EN_PUBLISH_PRICE", "type": "DOUBLE"}, {"name": "EN_FACE_PRICE", "type": "DOUBLE"}, {"name": "EN_YEAR_RATE", "type": "DOUBLE"}, {"name": "L_RATE_DAYS", "type": "DOUBLE"}, {"name": "EN_PAY_INTEVAL", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "EN_BOND_INTEREST", "type": "DOUBLE"}, {"name": "EN_REAL_INTEREST", "type": "DOUBLE"}, {"name": "EN_NEXT_BOND_INTEREST", "type": "DOUBLE"}, {"name": "C_SUBJECT_TYPE", "type": "STRING"}, {"name": "L_MODIFY_DATE", "type": "DOUBLE"}, {"name": "L_NEXT_MODIFY_DATE", "type": "DOUBLE"}, {"name": "C_INSIDE_APPRAISE", "type": "STRING"}, {"name": "C_OUTER_APPRAISE", "type": "STRING"}, {"name": "EN_BASIC_RATE", "type": "DOUBLE"}, {"name": "C_BASIC_RATE_TYPE", "type": "STRING"}, {"name": "EN_LEAST_RATE", "type": "DOUBLE"}, {"name": "C_INVESTOR_OPERATION_TYPE", "type": "STRING"}, {"name": "L_INVESTOR_OPERATION_DATE", "type": "DOUBLE"}, {"name": "C_PUBLISHER_OPERATION_TYPE", "type": "STRING"}, {"name": "L_PUBLISHER_OPERATION_DATE", "type": "DOUBLE"}, {"name": "C_TRUSTEE", "type": "STRING"}, {"name": "C_NET_PRICE", "type": "STRING"}, {"name": "VC_APPRAISE_ORGAN", "type": "STRING"}, {"name": "C_INTEREST_TYPE", "type": "STRING"}, {"name": "C_PAY_INTEREST_TYPE", "type": "STRING"}, {"name": "L_LEFT_TERM", "type": "DOUBLE"}, {"name": "EN_MATURITY", "type": "DOUBLE"}, {"name": "EN_MATURITY_ADJUST", "type": "DOUBLE"}, {"name": "EN_CHANGE_PRICE", "type": "DOUBLE"}, {"name": "L_CHANGE_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_CHANGE_END_DATE", "type": "DOUBLE"}, {"name": "EN_INVESTOR_OPERATION_PRICE", "type": "DOUBLE"}, {"name": "EN_PUBLISHER_OPERATION_PRICE", "type": "DOUBLE"}, {"name": "L_TRADE_DEADLINE", "type": "DOUBLE"}, {"name": "EN_FAIR_YIELD_RATIO", "type": "DOUBLE"}, {"name": "EN_VALUATE_DURATION", "type": "DOUBLE"}, {"name": "EN_VALUATE_CONVEXITY", "type": "DOUBLE"}, {"name": "EN_VALUATE_POINT_VALUE", "type": "DOUBLE"}, {"name": "EN_VALUATE_SPREAD_DURATION", "type": "DOUBLE"}, {"name": "EN_VALUATE_RATE_DURATION", "type": "DOUBLE"}, {"name": "EN_YESTERDAY_CHANGE_PRICE", "type": "DOUBLE"}, {"name": "EN_POINT_VALUE", "type": "DOUBLE"}, {"name": "EN_CONVEXITY", "type": "DOUBLE"}, {"name": "L_STARTCAL_DATE", "type": "DOUBLE"}, {"name": "C_INTEREST_CALC_TYPE", "type": "STRING"}, {"name": "C_PAYMENTOFINTEREST_TYPE", "type": "STRING"}, {"name": "L_GUARANTOR_ID", "type": "DOUBLE"}, {"name": "EN_BP_CEILING", "type": "DOUBLE"}, {"name": "EN_BP_FLOOR", "type": "DOUBLE"}, {"name": "L_YEAR", "type": "DOUBLE"}, {"name": "L_TIMES", "type": "DOUBLE"}, {"name": "EN_CURR_FACE_PRICE", "type": "DOUBLE"}, {"name": "C_RATEDAYS_CALC_TYPE", "type": "STRING"}, {"name": "L_NEXTPAYMENT_DATE", "type": "DOUBLE"}, {"name": "C_MOODY_APPRAISE", "type": "STRING"}, {"name": "C_SP_APPRAISE", "type": "STRING"}, {"name": "C_FITCH_APPRAISE", "type": "STRING"}, {"name": "C_OTHER_APPRAISE_ONE", "type": "STRING"}, {"name": "C_OTHER_APPRAISE_TWO", "type": "STRING"}, {"name": "C_YIELD_RATIO_TYPE", "type": "STRING"}, {"name": "EN_TODAY_INTEREST", "type": "DOUBLE"}, {"name": "C_INTEREST_TYPE_EX", "type": "STRING"}, {"name": "C_PAY_CAPITAL_TYPE", "type": "STRING"}, {"name": "L_OUTER_APPRAISE_DATE", "type": "DOUBLE"}, {"name": "L_ZQHS_BEGINDATE", "type": "DOUBLE"}, {"name": "L_ZQHS_ENDDATE", "type": "DOUBLE"}, {"name": "L_SUPERVENTION_MARKET_DATE", "type": "DOUBLE"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_BOND_COUNT", "type": "DOUBLE"}, {"name": "L_NEXT_RATECHANGE_DATE", "type": "DOUBLE"}, {"name": "C_DRAWBENCHMRK", "type": "STRING"}, {"name": "EN_ACCRUED_INTEREST", "type": "DOUBLE"}, {"name": "L_ISSUEBALANCE", "type": "DOUBLE"}, {"name": "EN_ZZ_FAIR_YIELD_RATIO", "type": "DOUBLE"}, {"name": "C_HEDGE_APPRAISE", "type": "STRING"}, {"name": "C_LEVEL_EXPECTATION", "type": "STRING"}, {"name": "C_OTHER_APPRAISE_THREE", "type": "STRING"}, {"name": "C_OTHER_APPRAISE_FOUR", "type": "STRING"}, {"name": "C_PASS_SPPI_TEST", "type": "STRING"}, {"name": "VC_SPPI_FAIL_REASON", "type": "STRING"}, {"name": "EN_SPPI_DOWNLIMIT_PRICE", "type": "DOUBLE"}, {"name": "C_ISSPECIAL", "type": "STRING"}, {"name": "C_ISENDDEFAULT", "type": "STRING"}, {"name": "C_ISFTABOND", "type": "STRING"}, {"name": "VC_DCQ", "type": "STRING"}, {"name": "VC_PARTY_NO", "type": "STRING"}, {"name": "VC_BONDTYPE_NAME", "type": "STRING"}, {"name": "VC_BONDTYPE_ID", "type": "STRING"}, {"name": "C_OFFERRINGCANCELFLAG", "type": "STRING"}, {"name": "EN_HQZ_XQGZ_PRICE", "type": "DOUBLE"}, {"name": "EN_HQZ_XQGZ_YIELD_RATIO", "type": "DOUBLE"}, {"name": "EN_HQZ_XQGZ_DURATION", "type": "DOUBLE"}, {"name": "EN_HQZ_XQGZ_CONVEXITY", "type": "DOUBLE"}, {"name": "EN_HZQ_XQGZ_VP_VALUE", "type": "DOUBLE"}, {"name": "VC_SPECIALPLAN_CODE", "type": "STRING"}, {"name": "EN_DELTA", "type": "DOUBLE"}, {"name": "EN_ZZD_NONRECOMMEND_RATIO", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP2", "type": "STRING"}, {"name": "VC_FINAL_DEBTORS", "type": "STRING"}, {"name": "C_ODM", "type": "STRING"}, {"name": "C_CENTER_MATCH", "type": "STRING"}, {"name": "C_ISUNSECURED", "type": "STRING"}, {"name": "C_IS_HISDATA", "type": "STRING"}, {"name": "C_BOND_FLAG", "type": "STRING"}, {"name": "L_SPECBOND_BEGINDATE", "type": "DOUBLE"}, {"name": "EN_NEXT_TRADEDATE_RATIO", "type": "DOUBLE"}, {"name": "EN_PUREDEBT_VALUE", "type": "DOUBLE"}, {"name": "VC_SPPI_EXTRAINFO", "type": "STRING"}, {"name": "C_PUTBACK_RESELL_FLAG", "type": "STRING"}, {"name": "VC_TIMESTAMP3", "type": "STRING"}, {"name": "VC_ORIGINAL_BEARER", "type": "STRING"}, {"name": "VC_ACCEPTOR", "type": "STRING"}, {"name": "VC_DISCOUNT_CLERK", "type": "STRING"}, {"name": "C_IS_FORCEREDEEM", "type": "STRING"}, {"name": "C_CITY_RANK", "type": "STRING"}, {"name": "VC_GUARANTOR_IDS", "type": "STRING"}, {"name": "L_PAYMENT_DATE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbondproperty_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbondproperty_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbondproperty_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbondproperty_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBONDPROPERTY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBONDPROPERTY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbondproperty_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBONDPROPERTY_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_INTER_CODE
     , L_PUBLISH_DATE
     , L_END_DATE
     , L_BEGINCAL_DATE
     , L_MARKET_DATE
     , EN_EXIST_LIMITE
     , EN_PUBLISH_PRICE
     , EN_FACE_PRICE
     , EN_YEAR_RATE
     , L_RATE_DAYS
     , EN_PAY_INTEVAL
     , C_MARKET_NO
     , EN_BOND_INTEREST
     , EN_REAL_INTEREST
     , EN_NEXT_BOND_INTEREST
     , C_SUBJECT_TYPE
     , L_MODIFY_DATE
     , L_NEXT_MODIFY_DATE
     , C_INSIDE_APPRAISE
     , C_OUTER_APPRAISE
     , EN_BASIC_RATE
     , C_BASIC_RATE_TYPE
     , EN_LEAST_RATE
     , C_INVESTOR_OPERATION_TYPE
     , L_INVESTOR_OPERATION_DATE
     , C_PUBLISHER_OPERATION_TYPE
     , L_PUBLISHER_OPERATION_DATE
     , C_TRUSTEE
     , C_NET_PRICE
     , VC_APPRAISE_ORGAN
     , C_INTEREST_TYPE
     , C_PAY_INTEREST_TYPE
     , L_LEFT_TERM
     , EN_MATURITY
     , EN_MATURITY_ADJUST
     , EN_CHANGE_PRICE
     , L_CHANGE_BEGIN_DATE
     , L_CHANGE_END_DATE
     , EN_INVESTOR_OPERATION_PRICE
     , EN_PUBLISHER_OPERATION_PRICE
     , L_TRADE_DEADLINE
     , EN_FAIR_YIELD_RATIO
     , EN_VALUATE_DURATION
     , EN_VALUATE_CONVEXITY
     , EN_VALUATE_POINT_VALUE
     , EN_VALUATE_SPREAD_DURATION
     , EN_VALUATE_RATE_DURATION
     , EN_YESTERDAY_CHANGE_PRICE
     , EN_POINT_VALUE
     , EN_CONVEXITY
     , L_STARTCAL_DATE
     , C_INTEREST_CALC_TYPE
     , C_PAYMENTOFINTEREST_TYPE
     , L_GUARANTOR_ID
     , EN_BP_CEILING
     , EN_BP_FLOOR
     , L_YEAR
     , L_TIMES
     , EN_CURR_FACE_PRICE
     , C_RATEDAYS_CALC_TYPE
     , L_NEXTPAYMENT_DATE
     , C_MOODY_APPRAISE
     , C_SP_APPRAISE
     , C_FITCH_APPRAISE
     , C_OTHER_APPRAISE_ONE
     , C_OTHER_APPRAISE_TWO
     , C_YIELD_RATIO_TYPE
     , EN_TODAY_INTEREST
     , C_INTEREST_TYPE_EX
     , C_PAY_CAPITAL_TYPE
     , L_OUTER_APPRAISE_DATE
     , L_ZQHS_BEGINDATE
     , L_ZQHS_ENDDATE
     , L_SUPERVENTION_MARKET_DATE
     , L_VIRTUAL_KEY
     , VC_TIMESTAMP
     , L_BOND_COUNT
     , L_NEXT_RATECHANGE_DATE
     , C_DRAWBENCHMRK
     , EN_ACCRUED_INTEREST
     , L_ISSUEBALANCE
     , EN_ZZ_FAIR_YIELD_RATIO
     , C_HEDGE_APPRAISE
     , C_LEVEL_EXPECTATION
     , C_OTHER_APPRAISE_THREE
     , C_OTHER_APPRAISE_FOUR
     , C_PASS_SPPI_TEST
     , VC_SPPI_FAIL_REASON
     , EN_SPPI_DOWNLIMIT_PRICE
     , C_ISSPECIAL
     , C_ISENDDEFAULT
     , C_ISFTABOND
     , VC_DCQ
     , VC_PARTY_NO
     , VC_BONDTYPE_NAME
     , VC_BONDTYPE_ID
     , C_OFFERRINGCANCELFLAG
     , EN_HQZ_XQGZ_PRICE
     , EN_HQZ_XQGZ_YIELD_RATIO
     , EN_HQZ_XQGZ_DURATION
     , EN_HQZ_XQGZ_CONVEXITY
     , EN_HZQ_XQGZ_VP_VALUE
     , VC_SPECIALPLAN_CODE
     , EN_DELTA
     , EN_ZZD_NONRECOMMEND_RATIO
     , VC_TIMESTAMP2
     , VC_FINAL_DEBTORS
     , C_ODM
     , C_CENTER_MATCH
     , C_ISUNSECURED
     , C_IS_HISDATA
     , C_BOND_FLAG
     , L_SPECBOND_BEGINDATE
     , EN_NEXT_TRADEDATE_RATIO
     , EN_PUREDEBT_VALUE
     , VC_SPPI_EXTRAINFO
     , C_PUTBACK_RESELL_FLAG
     , VC_TIMESTAMP3
     , VC_ORIGINAL_BEARER
     , VC_ACCEPTOR
     , VC_DISCOUNT_CLERK
     , C_IS_FORCEREDEEM
     , C_CITY_RANK
     , VC_GUARANTOR_IDS
     , L_PAYMENT_DATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TBONDPROPERTY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBONDPROPERTY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBONDPROPERTY_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBONDPROPERTY_PFD成功"
      exit 0
   fi
fi
