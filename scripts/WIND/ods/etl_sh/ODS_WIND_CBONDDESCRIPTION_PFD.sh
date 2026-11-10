#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_CBONDDESCRIPTION_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_CBONDDESCRIPTION_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  B_INFO_FULLNAME  STRING  COMMENT  '债券名称',
  B_INFO_ISSUER  STRING  COMMENT  '发行人',
  B_ISSUE_ANNOUNCEMENT  STRING  COMMENT  '发行公告日',
  B_ISSUE_FIRSTISSUE  STRING  COMMENT  '发行起始日',
  B_ISSUE_LASTISSUE  STRING  COMMENT  '发行截止日',
  B_ISSUE_AMOUNTPLAN  DECIMAL(18,2)  COMMENT  '计划发行总量(亿元)',
  B_ISSUE_AMOUNTACT  DECIMAL(18,2)  COMMENT  '实际发行总量(亿元)',
  B_INFO_ISSUEPRICE  DECIMAL(18,2)  COMMENT  '发行价格',
  B_INFO_PAR  DECIMAL(18,2)  COMMENT  '面值',
  B_INFO_COUPONRATE  DECIMAL(18,2)  COMMENT  '发行票面利率(%)',
  B_INFO_SPREAD  DECIMAL(18,2)  COMMENT  '利差(%)',
  B_INFO_CARRYDATE  STRING  COMMENT  '计息起始日',
  B_INFO_ENDDATE  STRING  COMMENT  '计息截止日',
  B_INFO_MATURITYDATE  STRING  COMMENT  '到期日',
  B_INFO_TERM_YEAR_  DECIMAL(18,2)  COMMENT  '债券期限(年)',
  B_INFO_TERM_DAY_  DECIMAL(18,2)  COMMENT  '债券期限(天)',
  B_INFO_PAYMENTDATE  STRING  COMMENT  '兑付日',
  B_INFO_PAYMENTTYPE  DECIMAL(18,2)  COMMENT  '计息方式',
  B_INFO_INTERESTFREQUENCY  STRING  COMMENT  '付息频率',
  B_INFO_FORM  STRING  COMMENT  '债券形式',
  B_INFO_COUPON  DECIMAL(18,2)  COMMENT  '息票品种',
  B_INFO_INTERESTTYPE  DECIMAL(18,2)  COMMENT  '附息利率品种',
  B_INFO_ACT  DECIMAL(18,2)  COMMENT  '特殊年计息天数',
  B_ISSUE_FEE  DECIMAL(18,2)  COMMENT  '发行手续费率(%)',
  B_REDEMPTION_FEERATION  DECIMAL(18,2)  COMMENT  '兑付手续费率(%)',
  B_INFO_TAXRATE  DECIMAL(18,2)  COMMENT  '所得税率',
  CRNCY_CODE  STRING  COMMENT  '货币代码',
  S_INFO_NAME  STRING  COMMENT  '债券简称',
  S_INFO_EXCHMARKET  STRING  COMMENT  '交易所',
  B_INFO_GUARANTOR  STRING  COMMENT  '担保人',
  B_INFO_GUARTYPE  DECIMAL(18,2)  COMMENT  '担保方式',
  B_INFO_LISTDATE  STRING  COMMENT  '上市日期',
  B_INFO_YEARSNUMBER  DECIMAL(18,2)  COMMENT  '年内序号',
  S_DIV_RECORDDATE  STRING  COMMENT  '兑付登记起始日',
  B_INFO_CODEBYPLACING  STRING  COMMENT  '上网发行认购代码',
  B_INFO_DELISTDATE  STRING  COMMENT  '退市日期',
  B_INFO_ISSUETYPE  DECIMAL(18,2)  COMMENT  '发行方式',
  B_INFO_GUARINTRODUCTION  STRING  COMMENT  '担保简介',
  B_INFO_BGNDBYPLACING  STRING  COMMENT  '上网发行起始日期',
  B_INFO_ENDDBYPLACING  STRING  COMMENT  '上网发行截止日期',
  B_INFO_AMOUNTBYPLACING  DECIMAL(18,2)  COMMENT  '上网发行数量(亿元)',
  B_INFO_UNDERWRITINGCODE  DECIMAL(18,2)  COMMENT  '承销方式代码',
  B_INFO_ISSUERCODE  STRING  COMMENT  '发行人编号',
  B_INFO_FORMERCODE  STRING  COMMENT  '原债券代码',
  B_INFO_COUPONTXT  STRING  COMMENT  '利率说明',
  IS_FAILURE  DECIMAL(18,2)  COMMENT  '是否发行失败',
  IS_CROSSMARKET  DECIMAL(18,2)  COMMENT  '是否跨市场',
  B_INFO_COUPONDATETXT  STRING  COMMENT  '付息日说明',
  B_INFO_SUBORDINATEORNOT  DECIMAL(18,2)  COMMENT  '是否次级债或混合资本债',
  B_TENDRST_REFERYIELD  DECIMAL(18,2)  COMMENT  '参考收益率',
  B_INFO_CURPAR  DECIMAL(18,2)  COMMENT  '最新面值',
  S_INFO_FORMERWINDCODE  STRING  COMMENT  '原Wind代码',
  IS_CORPORATE_BOND  DECIMAL(18,2)  COMMENT  '是否公司债',
  B_INFO_ISSUERTYPE  STRING  COMMENT  '发行人类型',
  B_INFO_SPECIALBONDTYPE  STRING  COMMENT  '特殊债券类型',
  IS_PAYADVANCED  STRING  COMMENT  '是否可提前兑付',
  IS_CALLABLE  STRING  COMMENT  '是否可赎回',
  IS_CHOOSERIGHT  STRING  COMMENT  '是否有选择权',
  IS_NETPRICE  DECIMAL(18,2)  COMMENT  '是否净价',
  IS_ACT_DAYS  DECIMAL(18,2)  COMMENT  '是否按实际天数计息',
  IS_INCBONDS  DECIMAL(18,2)  COMMENT  '是否增发债',
  ISSUE_OBJECT  STRING  COMMENT  '发行对象',
  B_INFO_ACTUALBENCHMARK  STRING  COMMENT  '计息基准',
  REGISTER_FILE_TYPE_CODE  DECIMAL(18,2)  COMMENT  '注册文件类型代码',
  REGISTER_FILE_NUMBER  STRING  COMMENT  '注册文件号',
  LIST_ANN_DATE  STRING  COMMENT  '上市公告日',
  REIMBURSEMENT  STRING  COMMENT  '偿还方式',
  BOND_RATING  STRING  COMMENT  '发行时债券评级',
  ANN_DATE  STRING  COMMENT  '公告日期',
  B_ISSUE_AMOUNT_MAX  DECIMAL(18,2)  COMMENT  '发行金额上限',
  B_INFO_GUARANTEE_ID  STRING  COMMENT  '担保人ID',
  B_INFO_PINYIN  STRING  COMMENT  '简称拼音',
  TRADE_TYPE_CODE  DECIMAL(18,2)  COMMENT  '交易方式',
  IS_TAXFREE  STRING  COMMENT  '是否免税',
  IS_INRIGHT  STRING  COMMENT  '是否含权债',
  ACCOUNTTREATMENT_TYPE  DECIMAL(18,2)  COMMENT  '会计处理类型代码',
  TAX_PAYER  DECIMAL(18,2)  COMMENT  '税款承担方',
  B_INFO_GUARANTEESETTLEMENT  DECIMAL(18,2)  COMMENT  '是否担保交收',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国债券基本资料'
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
                                   , B_INFO_FULLNAME
                                   , B_INFO_ISSUER
                                   , B_ISSUE_ANNOUNCEMENT
                                   , B_ISSUE_FIRSTISSUE
                                   , B_ISSUE_LASTISSUE
                                   , B_ISSUE_AMOUNTPLAN
                                   , B_ISSUE_AMOUNTACT
                                   , B_INFO_ISSUEPRICE
                                   , B_INFO_PAR
                                   , B_INFO_COUPONRATE
                                   , B_INFO_SPREAD
                                   , B_INFO_CARRYDATE
                                   , B_INFO_ENDDATE
                                   , B_INFO_MATURITYDATE
                                   , B_INFO_TERM_YEAR_
                                   , B_INFO_TERM_DAY_
                                   , B_INFO_PAYMENTDATE
                                   , B_INFO_PAYMENTTYPE
                                   , B_INFO_INTERESTFREQUENCY
                                   , B_INFO_FORM
                                   , B_INFO_COUPON
                                   , B_INFO_INTERESTTYPE
                                   , B_INFO_ACT
                                   , B_ISSUE_FEE
                                   , B_REDEMPTION_FEERATION
                                   , B_INFO_TAXRATE
                                   , CRNCY_CODE
                                   , S_INFO_NAME
                                   , S_INFO_EXCHMARKET
                                   , B_INFO_GUARANTOR
                                   , B_INFO_GUARTYPE
                                   , B_INFO_LISTDATE
                                   , B_INFO_YEARSNUMBER
                                   , S_DIV_RECORDDATE
                                   , B_INFO_CODEBYPLACING
                                   , B_INFO_DELISTDATE
                                   , B_INFO_ISSUETYPE
                                   , B_INFO_GUARINTRODUCTION
                                   , B_INFO_BGNDBYPLACING
                                   , B_INFO_ENDDBYPLACING
                                   , B_INFO_AMOUNTBYPLACING
                                   , B_INFO_UNDERWRITINGCODE
                                   , B_INFO_ISSUERCODE
                                   , B_INFO_FORMERCODE
                                   , B_INFO_COUPONTXT
                                   , IS_FAILURE
                                   , IS_CROSSMARKET
                                   , B_INFO_COUPONDATETXT
                                   , B_INFO_SUBORDINATEORNOT
                                   , B_TENDRST_REFERYIELD
                                   , B_INFO_CURPAR
                                   , S_INFO_FORMERWINDCODE
                                   , IS_CORPORATE_BOND
                                   , B_INFO_ISSUERTYPE
                                   , B_INFO_SPECIALBONDTYPE
                                   , IS_PAYADVANCED
                                   , IS_CALLABLE
                                   , IS_CHOOSERIGHT
                                   , IS_NETPRICE
                                   , IS_ACT_DAYS
                                   , IS_INCBONDS
                                   , ISSUE_OBJECT
                                   , B_INFO_ACTUALBENCHMARK
                                   , REGISTER_FILE_TYPE_CODE
                                   , REGISTER_FILE_NUMBER
                                   , LIST_ANN_DATE
                                   , REIMBURSEMENT
                                   , BOND_RATING
                                   , ANN_DATE
                                   , B_ISSUE_AMOUNT_MAX
                                   , B_INFO_GUARANTEE_ID
                                   , B_INFO_PINYIN
                                   , TRADE_TYPE_CODE
                                   , IS_TAXFREE
                                   , IS_INRIGHT
                                   , ACCOUNTTREATMENT_TYPE
                                   , TAX_PAYER
                                   , B_INFO_GUARANTEESETTLEMENT
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.CBONDDESCRIPTION"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "B_INFO_FULLNAME", "type": "STRING"}, {"name": "B_INFO_ISSUER", "type": "STRING"}, {"name": "B_ISSUE_ANNOUNCEMENT", "type": "STRING"}, {"name": "B_ISSUE_FIRSTISSUE", "type": "STRING"}, {"name": "B_ISSUE_LASTISSUE", "type": "STRING"}, {"name": "B_ISSUE_AMOUNTPLAN", "type": "DOUBLE"}, {"name": "B_ISSUE_AMOUNTACT", "type": "DOUBLE"}, {"name": "B_INFO_ISSUEPRICE", "type": "DOUBLE"}, {"name": "B_INFO_PAR", "type": "DOUBLE"}, {"name": "B_INFO_COUPONRATE", "type": "DOUBLE"}, {"name": "B_INFO_SPREAD", "type": "DOUBLE"}, {"name": "B_INFO_CARRYDATE", "type": "STRING"}, {"name": "B_INFO_ENDDATE", "type": "STRING"}, {"name": "B_INFO_MATURITYDATE", "type": "STRING"}, {"name": "B_INFO_TERM_YEAR_", "type": "DOUBLE"}, {"name": "B_INFO_TERM_DAY_", "type": "DOUBLE"}, {"name": "B_INFO_PAYMENTDATE", "type": "STRING"}, {"name": "B_INFO_PAYMENTTYPE", "type": "DOUBLE"}, {"name": "B_INFO_INTERESTFREQUENCY", "type": "STRING"}, {"name": "B_INFO_FORM", "type": "STRING"}, {"name": "B_INFO_COUPON", "type": "DOUBLE"}, {"name": "B_INFO_INTERESTTYPE", "type": "DOUBLE"}, {"name": "B_INFO_ACT", "type": "DOUBLE"}, {"name": "B_ISSUE_FEE", "type": "DOUBLE"}, {"name": "B_REDEMPTION_FEERATION", "type": "DOUBLE"}, {"name": "B_INFO_TAXRATE", "type": "DOUBLE"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "S_INFO_NAME", "type": "STRING"}, {"name": "S_INFO_EXCHMARKET", "type": "STRING"}, {"name": "B_INFO_GUARANTOR", "type": "STRING"}, {"name": "B_INFO_GUARTYPE", "type": "DOUBLE"}, {"name": "B_INFO_LISTDATE", "type": "STRING"}, {"name": "B_INFO_YEARSNUMBER", "type": "DOUBLE"}, {"name": "S_DIV_RECORDDATE", "type": "STRING"}, {"name": "B_INFO_CODEBYPLACING", "type": "STRING"}, {"name": "B_INFO_DELISTDATE", "type": "STRING"}, {"name": "B_INFO_ISSUETYPE", "type": "DOUBLE"}, {"name": "B_INFO_GUARINTRODUCTION", "type": "STRING"}, {"name": "B_INFO_BGNDBYPLACING", "type": "STRING"}, {"name": "B_INFO_ENDDBYPLACING", "type": "STRING"}, {"name": "B_INFO_AMOUNTBYPLACING", "type": "DOUBLE"}, {"name": "B_INFO_UNDERWRITINGCODE", "type": "DOUBLE"}, {"name": "B_INFO_ISSUERCODE", "type": "STRING"}, {"name": "B_INFO_FORMERCODE", "type": "STRING"}, {"name": "B_INFO_COUPONTXT", "type": "STRING"}, {"name": "IS_FAILURE", "type": "DOUBLE"}, {"name": "IS_CROSSMARKET", "type": "DOUBLE"}, {"name": "B_INFO_COUPONDATETXT", "type": "STRING"}, {"name": "B_INFO_SUBORDINATEORNOT", "type": "DOUBLE"}, {"name": "B_TENDRST_REFERYIELD", "type": "DOUBLE"}, {"name": "B_INFO_CURPAR", "type": "DOUBLE"}, {"name": "S_INFO_FORMERWINDCODE", "type": "STRING"}, {"name": "IS_CORPORATE_BOND", "type": "DOUBLE"}, {"name": "B_INFO_ISSUERTYPE", "type": "STRING"}, {"name": "B_INFO_SPECIALBONDTYPE", "type": "STRING"}, {"name": "IS_PAYADVANCED", "type": "STRING"}, {"name": "IS_CALLABLE", "type": "STRING"}, {"name": "IS_CHOOSERIGHT", "type": "STRING"}, {"name": "IS_NETPRICE", "type": "DOUBLE"}, {"name": "IS_ACT_DAYS", "type": "DOUBLE"}, {"name": "IS_INCBONDS", "type": "DOUBLE"}, {"name": "ISSUE_OBJECT", "type": "STRING"}, {"name": "B_INFO_ACTUALBENCHMARK", "type": "STRING"}, {"name": "REGISTER_FILE_TYPE_CODE", "type": "DOUBLE"}, {"name": "REGISTER_FILE_NUMBER", "type": "STRING"}, {"name": "LIST_ANN_DATE", "type": "STRING"}, {"name": "REIMBURSEMENT", "type": "STRING"}, {"name": "BOND_RATING", "type": "STRING"}, {"name": "ANN_DATE", "type": "STRING"}, {"name": "B_ISSUE_AMOUNT_MAX", "type": "DOUBLE"}, {"name": "B_INFO_GUARANTEE_ID", "type": "STRING"}, {"name": "B_INFO_PINYIN", "type": "STRING"}, {"name": "TRADE_TYPE_CODE", "type": "DOUBLE"}, {"name": "IS_TAXFREE", "type": "STRING"}, {"name": "IS_INRIGHT", "type": "STRING"}, {"name": "ACCOUNTTREATMENT_TYPE", "type": "DOUBLE"}, {"name": "TAX_PAYER", "type": "DOUBLE"}, {"name": "B_INFO_GUARANTEESETTLEMENT", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_cbonddescription_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_cbonddescription_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_cbonddescription_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_cbonddescription_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_CBONDDESCRIPTION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_CBONDDESCRIPTION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_cbonddescription_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_CBONDDESCRIPTION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , B_INFO_FULLNAME
     , B_INFO_ISSUER
     , B_ISSUE_ANNOUNCEMENT
     , B_ISSUE_FIRSTISSUE
     , B_ISSUE_LASTISSUE
     , B_ISSUE_AMOUNTPLAN
     , B_ISSUE_AMOUNTACT
     , B_INFO_ISSUEPRICE
     , B_INFO_PAR
     , B_INFO_COUPONRATE
     , B_INFO_SPREAD
     , B_INFO_CARRYDATE
     , B_INFO_ENDDATE
     , B_INFO_MATURITYDATE
     , B_INFO_TERM_YEAR_
     , B_INFO_TERM_DAY_
     , B_INFO_PAYMENTDATE
     , B_INFO_PAYMENTTYPE
     , B_INFO_INTERESTFREQUENCY
     , B_INFO_FORM
     , B_INFO_COUPON
     , B_INFO_INTERESTTYPE
     , B_INFO_ACT
     , B_ISSUE_FEE
     , B_REDEMPTION_FEERATION
     , B_INFO_TAXRATE
     , CRNCY_CODE
     , S_INFO_NAME
     , S_INFO_EXCHMARKET
     , B_INFO_GUARANTOR
     , B_INFO_GUARTYPE
     , B_INFO_LISTDATE
     , B_INFO_YEARSNUMBER
     , S_DIV_RECORDDATE
     , B_INFO_CODEBYPLACING
     , B_INFO_DELISTDATE
     , B_INFO_ISSUETYPE
     , B_INFO_GUARINTRODUCTION
     , B_INFO_BGNDBYPLACING
     , B_INFO_ENDDBYPLACING
     , B_INFO_AMOUNTBYPLACING
     , B_INFO_UNDERWRITINGCODE
     , B_INFO_ISSUERCODE
     , B_INFO_FORMERCODE
     , B_INFO_COUPONTXT
     , IS_FAILURE
     , IS_CROSSMARKET
     , B_INFO_COUPONDATETXT
     , B_INFO_SUBORDINATEORNOT
     , B_TENDRST_REFERYIELD
     , B_INFO_CURPAR
     , S_INFO_FORMERWINDCODE
     , IS_CORPORATE_BOND
     , B_INFO_ISSUERTYPE
     , B_INFO_SPECIALBONDTYPE
     , IS_PAYADVANCED
     , IS_CALLABLE
     , IS_CHOOSERIGHT
     , IS_NETPRICE
     , IS_ACT_DAYS
     , IS_INCBONDS
     , ISSUE_OBJECT
     , B_INFO_ACTUALBENCHMARK
     , REGISTER_FILE_TYPE_CODE
     , REGISTER_FILE_NUMBER
     , LIST_ANN_DATE
     , REIMBURSEMENT
     , BOND_RATING
     , ANN_DATE
     , B_ISSUE_AMOUNT_MAX
     , B_INFO_GUARANTEE_ID
     , B_INFO_PINYIN
     , TRADE_TYPE_CODE
     , IS_TAXFREE
     , IS_INRIGHT
     , ACCOUNTTREATMENT_TYPE
     , TAX_PAYER
     , B_INFO_GUARANTEESETTLEMENT
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_CBONDDESCRIPTION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_CBONDDESCRIPTION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_CBONDDESCRIPTION_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_CBONDDESCRIPTION_PFD成功"
      exit 0
   fi
fi
