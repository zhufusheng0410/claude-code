#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_PS_ARCHIVES_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_PS_ARCHIVES_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  RELATINGINNERCODE  STRING  COMMENT  '相关基础证券的内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  ISSUEPUBLDATE  STRING  COMMENT  '发行公告日',
  ISSUETYPE  DECIMAL(10,0)  COMMENT  '发行类别',
  CURRENCY  DECIMAL(10,0)  COMMENT  '货币单位',
  ISSUEVOL  DECIMAL(19,2)  COMMENT  '发行量(股)',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  ISSUEPRICE  DECIMAL(19,4)  COMMENT  '实际发行价(元)',
  MATURITY  STRING  COMMENT  '存续期限',
  IFFLOATED  DECIMAL(10,0)  COMMENT  '股息率是否浮动',
  DIVIDENDRATIO  DECIMAL(8,4)  COMMENT  '股息率',
  FIXEDPREMIUM  DECIMAL(8,4)  COMMENT  '固定溢价',
  FLOATINGRATEDATUM  DECIMAL(10,0)  COMMENT  '浮动利率计息基准',
  DIVIDENDDESCRIPTION  STRING  COMMENT  '股息描述',
  PAYMENTMETHOD  DECIMAL(10,0)  COMMENT  '支付方式',
  INTERESTSTARTDATE  STRING  COMMENT  '计息起始日',
  INITIALDIVIDENDDATE  STRING  COMMENT  '首次派息日',
  INTPAYMENTDESCRIPTION  STRING  COMMENT  '付息方式描述',
  IFACCUMULATED  DECIMAL(10,0)  COMMENT  '股息是否累积',
  IFPARTICIPATED  DECIMAL(10,0)  COMMENT  '是否参与剩余利润分配',
  IFCONVERT  DECIMAL(10,0)  COMMENT  '是否可强制转股',
  CONVSTKABBRNAME  STRING  COMMENT  '转股简称',
  CONVCODE  STRING  COMMENT  '转股代码',
  INITIALCONVETPRICE  DECIMAL(19,4)  COMMENT  '初始转股价(元/股)',
  CONVTERMSTARTDATE  STRING  COMMENT  '转股起始日',
  CONVTERMENDDATE  STRING  COMMENT  '转股截止日',
  LASTTRADINGDAY  STRING  COMMENT  '最后交易日',
  DELISTDATE  STRING  COMMENT  '停止交易日',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  ACCOUNTTREAT  DECIMAL(10,0)  COMMENT  '会计处理方式',
  COMPOUNDMETHOD  DECIMAL(10,0)  COMMENT  '计息方式',
  AVERAGEDAYS  DECIMAL(10,0)  COMMENT  '均值计算天数(天)',
  AIFORMULA  DECIMAL(10,0)  COMMENT  '利息计算公式',
  ENDDATE  STRING  COMMENT  '日期',
  REDEMCONDITIONS  STRING  COMMENT  '赎回条件说明',
  REDEMPRICE  STRING  COMMENT  '赎回价格说明',
  CONVERSIONCONDITIONS  STRING  COMMENT  '转股条件说明',
  CONVERSIONPRICE  STRING  COMMENT  '转股价格说明',
  CONVERSIONPERIOD  STRING  COMMENT  '转股期限说明'
)
COMMENT '优先股概况'
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
                                   , RELATINGINNERCODE
                                   , INITIALINFOPUBLDATE
                                   , ISSUEPUBLDATE
                                   , ISSUETYPE
                                   , CURRENCY
                                   , ISSUEVOL
                                   , PARVALUE
                                   , ISSUEPRICE
                                   , MATURITY
                                   , IFFLOATED
                                   , DIVIDENDRATIO
                                   , FIXEDPREMIUM
                                   , FLOATINGRATEDATUM
                                   , DIVIDENDDESCRIPTION
                                   , PAYMENTMETHOD
                                   , INTERESTSTARTDATE
                                   , INITIALDIVIDENDDATE
                                   , INTPAYMENTDESCRIPTION
                                   , IFACCUMULATED
                                   , IFPARTICIPATED
                                   , IFCONVERT
                                   , CONVSTKABBRNAME
                                   , CONVCODE
                                   , INITIALCONVETPRICE
                                   , CONVTERMSTARTDATE
                                   , CONVTERMENDDATE
                                   , LASTTRADINGDAY
                                   , DELISTDATE
                                   , UPDATETIME
                                   , JSID
                                   , ACCOUNTTREAT
                                   , COMPOUNDMETHOD
                                   , AVERAGEDAYS
                                   , AIFORMULA
                                   , ENDDATE
                                   , REDEMCONDITIONS
                                   , REDEMPRICE
                                   , CONVERSIONCONDITIONS
                                   , CONVERSIONPRICE
                                   , CONVERSIONPERIOD
                                FROM ${jy_src_schema}.PS_ARCHIVES"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "RELATINGINNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "ISSUEPUBLDATE", "type": "STRING"}, {"name": "ISSUETYPE", "type": "DOUBLE"}, {"name": "CURRENCY", "type": "DOUBLE"}, {"name": "ISSUEVOL", "type": "DOUBLE"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "ISSUEPRICE", "type": "DOUBLE"}, {"name": "MATURITY", "type": "STRING"}, {"name": "IFFLOATED", "type": "DOUBLE"}, {"name": "DIVIDENDRATIO", "type": "DOUBLE"}, {"name": "FIXEDPREMIUM", "type": "DOUBLE"}, {"name": "FLOATINGRATEDATUM", "type": "DOUBLE"}, {"name": "DIVIDENDDESCRIPTION", "type": "STRING"}, {"name": "PAYMENTMETHOD", "type": "DOUBLE"}, {"name": "INTERESTSTARTDATE", "type": "STRING"}, {"name": "INITIALDIVIDENDDATE", "type": "STRING"}, {"name": "INTPAYMENTDESCRIPTION", "type": "STRING"}, {"name": "IFACCUMULATED", "type": "DOUBLE"}, {"name": "IFPARTICIPATED", "type": "DOUBLE"}, {"name": "IFCONVERT", "type": "DOUBLE"}, {"name": "CONVSTKABBRNAME", "type": "STRING"}, {"name": "CONVCODE", "type": "STRING"}, {"name": "INITIALCONVETPRICE", "type": "DOUBLE"}, {"name": "CONVTERMSTARTDATE", "type": "STRING"}, {"name": "CONVTERMENDDATE", "type": "STRING"}, {"name": "LASTTRADINGDAY", "type": "STRING"}, {"name": "DELISTDATE", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "ACCOUNTTREAT", "type": "DOUBLE"}, {"name": "COMPOUNDMETHOD", "type": "DOUBLE"}, {"name": "AVERAGEDAYS", "type": "DOUBLE"}, {"name": "AIFORMULA", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "REDEMCONDITIONS", "type": "STRING"}, {"name": "REDEMPRICE", "type": "STRING"}, {"name": "CONVERSIONCONDITIONS", "type": "STRING"}, {"name": "CONVERSIONPRICE", "type": "STRING"}, {"name": "CONVERSIONPERIOD", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_ps_archives_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_ps_archives_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_ps_archives_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_ps_archives_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_PS_ARCHIVES_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_PS_ARCHIVES_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_ps_archives_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_PS_ARCHIVES_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , RELATINGINNERCODE
     , INITIALINFOPUBLDATE
     , ISSUEPUBLDATE
     , ISSUETYPE
     , CURRENCY
     , ISSUEVOL
     , PARVALUE
     , ISSUEPRICE
     , MATURITY
     , IFFLOATED
     , DIVIDENDRATIO
     , FIXEDPREMIUM
     , FLOATINGRATEDATUM
     , DIVIDENDDESCRIPTION
     , PAYMENTMETHOD
     , INTERESTSTARTDATE
     , INITIALDIVIDENDDATE
     , INTPAYMENTDESCRIPTION
     , IFACCUMULATED
     , IFPARTICIPATED
     , IFCONVERT
     , CONVSTKABBRNAME
     , CONVCODE
     , INITIALCONVETPRICE
     , CONVTERMSTARTDATE
     , CONVTERMENDDATE
     , LASTTRADINGDAY
     , DELISTDATE
     , UPDATETIME
     , JSID
     , ACCOUNTTREAT
     , COMPOUNDMETHOD
     , AVERAGEDAYS
     , AIFORMULA
     , ENDDATE
     , REDEMCONDITIONS
     , REDEMPRICE
     , CONVERSIONCONDITIONS
     , CONVERSIONPRICE
     , CONVERSIONPERIOD
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_PS_ARCHIVES_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_PS_ARCHIVES_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_PS_ARCHIVES_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_PS_ARCHIVES_PFD成功"
      exit 0
   fi
fi
