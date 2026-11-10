#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_BSHAREIPO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_BSHAREIPO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  INTENTLETTERPUBLDATE  STRING  COMMENT  '招股公告日(招股意向书发布日期)',
  PROSPECTUSPUBLDATE  STRING  COMMENT  '招股说明书发布日期',
  LISTANNOUNCEMENTDATE  STRING  COMMENT  '上市公告日(上市公告书发布日期)',
  RAISINGMETHOD  DECIMAL(10,0)  COMMENT  '募资方式',
  STOCKTYPE  STRING  COMMENT  '发行股票类型',
  PARVALUERMB  DECIMAL(19,4)  COMMENT  '每股面值(人民币元)',
  PRICEUNIT  DECIMAL(10,0)  COMMENT  '期货单位',
  ISSUEPRICERMB  DECIMAL(19,4)  COMMENT  '每股发行价(人民币元)',
  ISSUEPRICEFC  DECIMAL(19,4)  COMMENT  '每股发行价(外币元)',
  WEIGHTEDPERATIO  DECIMAL(30,8)  COMMENT  '发行市盈率(加权平均)(倍)',
  DILUTEDPERATIO  DECIMAL(30,8)  COMMENT  '发行市盈率(全面摊薄)(倍)',
  STRAINVESTORPLAPRICEFC  DECIMAL(19,4)  COMMENT  '战略投资者配售价(外币元)',
  ISSUEVOLPLANNED  DECIMAL(16,0)  COMMENT  '计划发行量(股)',
  OVERALLOTMENTOPTION  DECIMAL(16,0)  COMMENT  '超额配售权(股)',
  ISSUEMETHOD  DECIMAL(10,0)  COMMENT  '发行方式',
  ISSUEOBJECT  STRING  COMMENT  '发行对象',
  PLASTARTDATE  STRING  COMMENT  '配售起始日',
  PLAENDDATE  STRING  COMMENT  '配售截止日',
  PAYSTARTDATE  STRING  COMMENT  '缴费起始',
  PAYENDDATE  STRING  COMMENT  '缴费截止',
  UNDERWRITINGSTARTDATE  STRING  COMMENT  '*承销期上限',
  UNDERWRITINGENDDATE  STRING  COMMENT  '*承销期下限',
  PREPAREDLISTEXCHANGE  DECIMAL(10,0)  COMMENT  '上市地',
  DIVIDENDPOLICY  STRING  COMMENT  '股利分配政策',
  ESTIMATEDFIRSTDIVIDATE  STRING  COMMENT  '预计首次分配时间',
  UNDERWRITINGMODE  DECIMAL(10,0)  COMMENT  '承销方式',
  ACTUALISSUEVOL  DECIMAL(16,0)  COMMENT  '实际发行量(股)',
  TOTALISSUEMVRMB  DECIMAL(19,4)  COMMENT  '发行总市值(人民币元)',
  ISSUECOSTRMB  DECIMAL(19,4)  COMMENT  '发行费用(人民币元)',
  IPOPROCEEDSRMB  DECIMAL(19,4)  COMMENT  '募集资金总额(人民币元)',
  IPONETPROCEEDSRMB  DECIMAL(19,4)  COMMENT  '募集资金净额(人民币元)',
  ISSUECOSTPERSHARERMB  DECIMAL(19,4)  COMMENT  '每股发行费用(人民币元)',
  TOTALISSUEMVFC  DECIMAL(19,4)  COMMENT  '发行总市值(外币元)',
  ISSUECOSTFC  DECIMAL(19,4)  COMMENT  '发行费用(外币元)',
  IPOPROCEEDSFC  DECIMAL(19,4)  COMMENT  '募集资金总额(外币元)',
  IPONETPROCEEDSFC  DECIMAL(19,4)  COMMENT  '募集资金净额(外币元)',
  ISSUECOSTPERSHAREFC  DECIMAL(19,4)  COMMENT  '每股发行费用(外币元)',
  DATETOACCOUNT  STRING  COMMENT  '募集资金到帐时间',
  LISTDATE  STRING  COMMENT  '上市日期',
  OUTSTANDINGSHARES  DECIMAL(16,0)  COMMENT  '本次上市流通股数(股)',
  STRAINVESTORPLAVOL  DECIMAL(16,0)  COMMENT  '战略投资者配售股数(股)',
  PLANUM  DECIMAL(10,0)  COMMENT  '配售户数(户)',
  UNDERWRITERBOUGHTVOL  DECIMAL(16,0)  COMMENT  '余股包销数量(股)',
  FIRSTOPENPRICE  DECIMAL(19,4)  COMMENT  '上市首日开盘价(元)',
  FIRSTCLOSEPRICE  DECIMAL(19,4)  COMMENT  '上市首日收盘价(元)',
  FIRSTTURNOVER  DECIMAL(9,6)  COMMENT  '上市首日换手率(%)',
  EARNINGFORECASTYEAR  STRING  COMMENT  '盈利预测年度',
  MAININCOMEFORECAST  DECIMAL(19,4)  COMMENT  '主营业务收入预测(元)',
  NETPROFITFORECAST  DECIMAL(19,4)  COMMENT  '净利润预测(元)',
  DILUTEDEPSFORECAST  DECIMAL(19,4)  COMMENT  '全面摊薄每股盈利预测(元)',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT 'B股首次发行与上市'
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
                                   , INITIALINFOPUBLDATE
                                   , INTENTLETTERPUBLDATE
                                   , PROSPECTUSPUBLDATE
                                   , LISTANNOUNCEMENTDATE
                                   , RAISINGMETHOD
                                   , STOCKTYPE
                                   , PARVALUERMB
                                   , PRICEUNIT
                                   , ISSUEPRICERMB
                                   , ISSUEPRICEFC
                                   , WEIGHTEDPERATIO
                                   , DILUTEDPERATIO
                                   , STRAINVESTORPLAPRICEFC
                                   , ISSUEVOLPLANNED
                                   , OVERALLOTMENTOPTION
                                   , ISSUEMETHOD
                                   , ISSUEOBJECT
                                   , PLASTARTDATE
                                   , PLAENDDATE
                                   , PAYSTARTDATE
                                   , PAYENDDATE
                                   , UNDERWRITINGSTARTDATE
                                   , UNDERWRITINGENDDATE
                                   , PREPAREDLISTEXCHANGE
                                   , DIVIDENDPOLICY
                                   , ESTIMATEDFIRSTDIVIDATE
                                   , UNDERWRITINGMODE
                                   , ACTUALISSUEVOL
                                   , TOTALISSUEMVRMB
                                   , ISSUECOSTRMB
                                   , IPOPROCEEDSRMB
                                   , IPONETPROCEEDSRMB
                                   , ISSUECOSTPERSHARERMB
                                   , TOTALISSUEMVFC
                                   , ISSUECOSTFC
                                   , IPOPROCEEDSFC
                                   , IPONETPROCEEDSFC
                                   , ISSUECOSTPERSHAREFC
                                   , DATETOACCOUNT
                                   , LISTDATE
                                   , OUTSTANDINGSHARES
                                   , STRAINVESTORPLAVOL
                                   , PLANUM
                                   , UNDERWRITERBOUGHTVOL
                                   , FIRSTOPENPRICE
                                   , FIRSTCLOSEPRICE
                                   , FIRSTTURNOVER
                                   , EARNINGFORECASTYEAR
                                   , MAININCOMEFORECAST
                                   , NETPROFITFORECAST
                                   , DILUTEDEPSFORECAST
                                   , XGRQ
                                   , JSID
                                FROM ${jy_src_schema}.LC_BSHAREIPO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "INTENTLETTERPUBLDATE", "type": "STRING"}, {"name": "PROSPECTUSPUBLDATE", "type": "STRING"}, {"name": "LISTANNOUNCEMENTDATE", "type": "STRING"}, {"name": "RAISINGMETHOD", "type": "DOUBLE"}, {"name": "STOCKTYPE", "type": "DOUBLE"}, {"name": "PARVALUERMB", "type": "DOUBLE"}, {"name": "PRICEUNIT", "type": "DOUBLE"}, {"name": "ISSUEPRICERMB", "type": "DOUBLE"}, {"name": "ISSUEPRICEFC", "type": "DOUBLE"}, {"name": "WEIGHTEDPERATIO", "type": "DOUBLE"}, {"name": "DILUTEDPERATIO", "type": "DOUBLE"}, {"name": "STRAINVESTORPLAPRICEFC", "type": "DOUBLE"}, {"name": "ISSUEVOLPLANNED", "type": "DOUBLE"}, {"name": "OVERALLOTMENTOPTION", "type": "DOUBLE"}, {"name": "ISSUEMETHOD", "type": "DOUBLE"}, {"name": "ISSUEOBJECT", "type": "STRING"}, {"name": "PLASTARTDATE", "type": "STRING"}, {"name": "PLAENDDATE", "type": "STRING"}, {"name": "PAYSTARTDATE", "type": "STRING"}, {"name": "PAYENDDATE", "type": "STRING"}, {"name": "UNDERWRITINGSTARTDATE", "type": "STRING"}, {"name": "UNDERWRITINGENDDATE", "type": "STRING"}, {"name": "PREPAREDLISTEXCHANGE", "type": "DOUBLE"}, {"name": "DIVIDENDPOLICY", "type": "STRING"}, {"name": "ESTIMATEDFIRSTDIVIDATE", "type": "STRING"}, {"name": "UNDERWRITINGMODE", "type": "DOUBLE"}, {"name": "ACTUALISSUEVOL", "type": "DOUBLE"}, {"name": "TOTALISSUEMVRMB", "type": "DOUBLE"}, {"name": "ISSUECOSTRMB", "type": "DOUBLE"}, {"name": "IPOPROCEEDSRMB", "type": "DOUBLE"}, {"name": "IPONETPROCEEDSRMB", "type": "DOUBLE"}, {"name": "ISSUECOSTPERSHARERMB", "type": "DOUBLE"}, {"name": "TOTALISSUEMVFC", "type": "DOUBLE"}, {"name": "ISSUECOSTFC", "type": "DOUBLE"}, {"name": "IPOPROCEEDSFC", "type": "DOUBLE"}, {"name": "IPONETPROCEEDSFC", "type": "DOUBLE"}, {"name": "ISSUECOSTPERSHAREFC", "type": "DOUBLE"}, {"name": "DATETOACCOUNT", "type": "STRING"}, {"name": "LISTDATE", "type": "STRING"}, {"name": "OUTSTANDINGSHARES", "type": "DOUBLE"}, {"name": "STRAINVESTORPLAVOL", "type": "DOUBLE"}, {"name": "PLANUM", "type": "DOUBLE"}, {"name": "UNDERWRITERBOUGHTVOL", "type": "DOUBLE"}, {"name": "FIRSTOPENPRICE", "type": "DOUBLE"}, {"name": "FIRSTCLOSEPRICE", "type": "DOUBLE"}, {"name": "FIRSTTURNOVER", "type": "DOUBLE"}, {"name": "EARNINGFORECASTYEAR", "type": "STRING"}, {"name": "MAININCOMEFORECAST", "type": "DOUBLE"}, {"name": "NETPROFITFORECAST", "type": "DOUBLE"}, {"name": "DILUTEDEPSFORECAST", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_bshareipo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_bshareipo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_bshareipo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_bshareipo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_BSHAREIPO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_BSHAREIPO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_bshareipo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_BSHAREIPO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INITIALINFOPUBLDATE
     , INTENTLETTERPUBLDATE
     , PROSPECTUSPUBLDATE
     , LISTANNOUNCEMENTDATE
     , RAISINGMETHOD
     , STOCKTYPE
     , PARVALUERMB
     , PRICEUNIT
     , ISSUEPRICERMB
     , ISSUEPRICEFC
     , WEIGHTEDPERATIO
     , DILUTEDPERATIO
     , STRAINVESTORPLAPRICEFC
     , ISSUEVOLPLANNED
     , OVERALLOTMENTOPTION
     , ISSUEMETHOD
     , ISSUEOBJECT
     , PLASTARTDATE
     , PLAENDDATE
     , PAYSTARTDATE
     , PAYENDDATE
     , UNDERWRITINGSTARTDATE
     , UNDERWRITINGENDDATE
     , PREPAREDLISTEXCHANGE
     , DIVIDENDPOLICY
     , ESTIMATEDFIRSTDIVIDATE
     , UNDERWRITINGMODE
     , ACTUALISSUEVOL
     , TOTALISSUEMVRMB
     , ISSUECOSTRMB
     , IPOPROCEEDSRMB
     , IPONETPROCEEDSRMB
     , ISSUECOSTPERSHARERMB
     , TOTALISSUEMVFC
     , ISSUECOSTFC
     , IPOPROCEEDSFC
     , IPONETPROCEEDSFC
     , ISSUECOSTPERSHAREFC
     , DATETOACCOUNT
     , LISTDATE
     , OUTSTANDINGSHARES
     , STRAINVESTORPLAVOL
     , PLANUM
     , UNDERWRITERBOUGHTVOL
     , FIRSTOPENPRICE
     , FIRSTCLOSEPRICE
     , FIRSTTURNOVER
     , EARNINGFORECASTYEAR
     , MAININCOMEFORECAST
     , NETPROFITFORECAST
     , DILUTEDEPSFORECAST
     , XGRQ
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_BSHAREIPO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_BSHAREIPO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_BSHAREIPO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_BSHAREIPO_PFD成功"
      exit 0
   fi
fi
