#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CONBDBASICINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDBASICINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  SECUCODE  STRING  COMMENT  '证券代码',
  SECUABBR  STRING  COMMENT  '证券简称',
  BONDFORM  DECIMAL(10,0)  COMMENT  '债券形式',
  CBEMBEDDEDOPTION  DECIMAL(10,0)  COMMENT  '附属权证',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  GUARANTOR  STRING  COMMENT  '担保方',
  CRAS  STRING  COMMENT  '评级机构',
  CREDITRATING  STRING  COMMENT  '债券信用级别(字母)',
  LEADUNDERWRITER  STRING  COMMENT  '主承销商',
  MATURITY  DECIMAL(5,2)  COMMENT  '存续期限',
  STARTDATE  STRING  COMMENT  '起始日期',
  ENDDATE  STRING  COMMENT  '日期',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  ISSUEVOLUME  DECIMAL(16,0)  COMMENT  '实际发行量(股)',
  ACTUALISSUESIZE  DECIMAL(19,4)  COMMENT  '实际发行规模(元)',
  COMPOUNDMETHOD  DECIMAL(10,0)  COMMENT  '计息方式',
  INTPAYMENTMETHOD  DECIMAL(10,0)  COMMENT  '付息方式',
  COUPONFREQ  DECIMAL(10,0)  COMMENT  '付息频率(次/年)',
  COUPONRATE  DECIMAL(9,6)  COMMENT  '票面利率',
  INCRSCOUPONMARGIN  DECIMAL(9,6)  COMMENT  '累进利率计息年递增额',
  FRNMARGIN  DECIMAL(9,6)  COMMENT  '浮动利率计息基准利差',
  FRNREFRATETEXT  DECIMAL(10,0)  COMMENT  '浮动利率计息基准',
  MINANNUALRATE  DECIMAL(9,6)  COMMENT  '债券保底利率(%)',
  INTPAYMENTDESCRIPTION  STRING  COMMENT  '付息方式描述',
  LISTEDDATE  STRING  COMMENT  '上市日期',
  LISTEDENDDATE  STRING  COMMENT  '上市截止日',
  TRADEENDDATE  STRING  COMMENT  '摘牌日',
  LASTTRADINGDATE  STRING  COMMENT  '最后交易日',
  DELISTDATE  STRING  COMMENT  '停止交易日',
  CONVSTKABBRNAME  STRING  COMMENT  '转股简称',
  CONVCODE  STRING  COMMENT  '转股代码',
  CONVTERMSTARTDATE  STRING  COMMENT  '转股起始日',
  CONVTERMENDDATE  STRING  COMMENT  '转股截止日',
  STOPCONVDATE  STRING  COMMENT  '停止转股日',
  CALLPROTECTION  DECIMAL(9,6)  COMMENT  '赎回保护期(年)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  MULTIGUARANTOR  STRING  COMMENT  '再担保人',
  SPONSOR  STRING  COMMENT  '保荐机构',
  INTERESTITEM  STRING  COMMENT  '利息条款描述',
  INTERESTFORMULA  DECIMAL(10,0)  COMMENT  '利息计算公式',
  RATEIFFLOAT  DECIMAL(10,0)  COMMENT  '利率是否浮动',
  RATEADJUSTMODE  DECIMAL(10,0)  COMMENT  '利率调整模式',
  REDEEMOFINTEREST  DECIMAL(19,4)  COMMENT  '到期利息补偿(元/张)',
  CALLPRICEEND  DECIMAL(9,4)  COMMENT  '赎回价(到期赎回)',
  PRIMALGUARRATIO  DECIMAL(19,4)  COMMENT  '初始担保比例',
  COMPRATE  DECIMAL(10,4)  COMMENT  '',
  BONDOTHERSTATE  DECIMAL(10,0)  COMMENT  '债券状态',
  REDEMPTIONMETHOD  DECIMAL(10,0)  COMMENT  '',
  INSERTTIME  STRING  COMMENT  '',
  EARLYMATURITYDATE  STRING  COMMENT  '添加列EarlyMaturityDate',
  OPMATURITY  STRING  COMMENT  '添加列OPMaturity',
  IFGUARANTEEDSETTLE  DECIMAL(10,0)  COMMENT  '是否担保交收(交易所)',
  LASTCONVDATE  STRING  COMMENT  '最后转股日',
  INITIALCONVPRICE  DECIMAL(19,4)  COMMENT  '(发行披露)初始转股价'
)
COMMENT '可转债基本信息表'
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
                                   , SECUCODE
                                   , SECUABBR
                                   , BONDFORM
                                   , CBEMBEDDEDOPTION
                                   , INITIALINFOPUBLDATE
                                   , GUARANTOR
                                   , CRAS
                                   , CREDITRATING
                                   , LEADUNDERWRITER
                                   , MATURITY
                                   , STARTDATE
                                   , ENDDATE
                                   , PARVALUE
                                   , ISSUEVOLUME
                                   , ACTUALISSUESIZE
                                   , COMPOUNDMETHOD
                                   , INTPAYMENTMETHOD
                                   , COUPONFREQ
                                   , COUPONRATE
                                   , INCRSCOUPONMARGIN
                                   , FRNMARGIN
                                   , FRNREFRATETEXT
                                   , MINANNUALRATE
                                   , INTPAYMENTDESCRIPTION
                                   , LISTEDDATE
                                   , LISTEDENDDATE
                                   , TRADEENDDATE
                                   , LASTTRADINGDATE
                                   , DELISTDATE
                                   , CONVSTKABBRNAME
                                   , CONVCODE
                                   , CONVTERMSTARTDATE
                                   , CONVTERMENDDATE
                                   , STOPCONVDATE
                                   , CALLPROTECTION
                                   , UPDATETIME
                                   , JSID
                                   , MULTIGUARANTOR
                                   , SPONSOR
                                   , INTERESTITEM
                                   , INTERESTFORMULA
                                   , RATEIFFLOAT
                                   , RATEADJUSTMODE
                                   , REDEEMOFINTEREST
                                   , CALLPRICEEND
                                   , PRIMALGUARRATIO
                                   , COMPRATE
                                   , BONDOTHERSTATE
                                   , REDEMPTIONMETHOD
                                   , INSERTTIME
                                   , EARLYMATURITYDATE
                                   , OPMATURITY
                                   , IFGUARANTEEDSETTLE
                                   , LASTCONVDATE
                                   , INITIALCONVPRICE
                                FROM ${jy_src_schema}.BOND_CONBDBASICINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "SECUCODE", "type": "STRING"}, {"name": "SECUABBR", "type": "STRING"}, {"name": "BONDFORM", "type": "DOUBLE"}, {"name": "CBEMBEDDEDOPTION", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "GUARANTOR", "type": "STRING"}, {"name": "CRAS", "type": "STRING"}, {"name": "CREDITRATING", "type": "STRING"}, {"name": "LEADUNDERWRITER", "type": "STRING"}, {"name": "MATURITY", "type": "DOUBLE"}, {"name": "STARTDATE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "ISSUEVOLUME", "type": "DOUBLE"}, {"name": "ACTUALISSUESIZE", "type": "DOUBLE"}, {"name": "COMPOUNDMETHOD", "type": "DOUBLE"}, {"name": "INTPAYMENTMETHOD", "type": "DOUBLE"}, {"name": "COUPONFREQ", "type": "DOUBLE"}, {"name": "COUPONRATE", "type": "DOUBLE"}, {"name": "INCRSCOUPONMARGIN", "type": "DOUBLE"}, {"name": "FRNMARGIN", "type": "DOUBLE"}, {"name": "FRNREFRATETEXT", "type": "DOUBLE"}, {"name": "MINANNUALRATE", "type": "DOUBLE"}, {"name": "INTPAYMENTDESCRIPTION", "type": "STRING"}, {"name": "LISTEDDATE", "type": "STRING"}, {"name": "LISTEDENDDATE", "type": "STRING"}, {"name": "TRADEENDDATE", "type": "STRING"}, {"name": "LASTTRADINGDATE", "type": "STRING"}, {"name": "DELISTDATE", "type": "STRING"}, {"name": "CONVSTKABBRNAME", "type": "STRING"}, {"name": "CONVCODE", "type": "STRING"}, {"name": "CONVTERMSTARTDATE", "type": "STRING"}, {"name": "CONVTERMENDDATE", "type": "STRING"}, {"name": "STOPCONVDATE", "type": "STRING"}, {"name": "CALLPROTECTION", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "MULTIGUARANTOR", "type": "STRING"}, {"name": "SPONSOR", "type": "STRING"}, {"name": "INTERESTITEM", "type": "STRING"}, {"name": "INTERESTFORMULA", "type": "DOUBLE"}, {"name": "RATEIFFLOAT", "type": "DOUBLE"}, {"name": "RATEADJUSTMODE", "type": "DOUBLE"}, {"name": "REDEEMOFINTEREST", "type": "DOUBLE"}, {"name": "CALLPRICEEND", "type": "DOUBLE"}, {"name": "PRIMALGUARRATIO", "type": "DOUBLE"}, {"name": "COMPRATE", "type": "DOUBLE"}, {"name": "BONDOTHERSTATE", "type": "DOUBLE"}, {"name": "REDEMPTIONMETHOD", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "EARLYMATURITYDATE", "type": "STRING"}, {"name": "OPMATURITY", "type": "STRING"}, {"name": "IFGUARANTEEDSETTLE", "type": "DOUBLE"}, {"name": "LASTCONVDATE", "type": "STRING"}, {"name": "INITIALCONVPRICE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_conbdbasicinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_conbdbasicinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_conbdbasicinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_conbdbasicinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CONBDBASICINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CONBDBASICINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_conbdbasicinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDBASICINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , SECUCODE
     , SECUABBR
     , BONDFORM
     , CBEMBEDDEDOPTION
     , INITIALINFOPUBLDATE
     , GUARANTOR
     , CRAS
     , CREDITRATING
     , LEADUNDERWRITER
     , MATURITY
     , STARTDATE
     , ENDDATE
     , PARVALUE
     , ISSUEVOLUME
     , ACTUALISSUESIZE
     , COMPOUNDMETHOD
     , INTPAYMENTMETHOD
     , COUPONFREQ
     , COUPONRATE
     , INCRSCOUPONMARGIN
     , FRNMARGIN
     , FRNREFRATETEXT
     , MINANNUALRATE
     , INTPAYMENTDESCRIPTION
     , LISTEDDATE
     , LISTEDENDDATE
     , TRADEENDDATE
     , LASTTRADINGDATE
     , DELISTDATE
     , CONVSTKABBRNAME
     , CONVCODE
     , CONVTERMSTARTDATE
     , CONVTERMENDDATE
     , STOPCONVDATE
     , CALLPROTECTION
     , UPDATETIME
     , JSID
     , MULTIGUARANTOR
     , SPONSOR
     , INTERESTITEM
     , INTERESTFORMULA
     , RATEIFFLOAT
     , RATEADJUSTMODE
     , REDEEMOFINTEREST
     , CALLPRICEEND
     , PRIMALGUARRATIO
     , COMPRATE
     , BONDOTHERSTATE
     , REDEMPTIONMETHOD
     , INSERTTIME
     , EARLYMATURITYDATE
     , OPMATURITY
     , IFGUARANTEEDSETTLE
     , LASTCONVDATE
     , INITIALCONVPRICE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CONBDBASICINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDBASICINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CONBDBASICINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CONBDBASICINFO_PFD成功"
      exit 0
   fi
fi
