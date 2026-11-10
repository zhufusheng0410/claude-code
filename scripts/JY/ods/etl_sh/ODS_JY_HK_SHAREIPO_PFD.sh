#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_HK_SHAREIPO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_HK_SHAREIPO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  PROCESS  DECIMAL(10,0)  COMMENT  '关联进程说明',
  BDDECISIONPUBLDATE  STRING  COMMENT  '董事会公告日',
  BDDECISIONSIGNDATE  STRING  COMMENT  '董事会公告签署日',
  SMDECIPUBLDATE  STRING  COMMENT  '股东大会决议公告日期',
  PROSPECTUSPUBLDATE  STRING  COMMENT  '招股说明书发布日期',
  CONTRACTSIGNDATE  STRING  COMMENT  '股权转让协议签署日',
  ABORTPUBLDATE  STRING  COMMENT  '终止实施公告日',
  ISSUETYPE  DECIMAL(10,0)  COMMENT  '发行类别',
  ISSUEMETHOD  DECIMAL(10,0)  COMMENT  '发行方式',
  ISSUEOBJECT  DECIMAL(10,0)  COMMENT  '发行对象',
  CURRENCYUNIT  DECIMAL(10,0)  COMMENT  '货币单位',
  PARVALUE  DECIMAL(19,10)  COMMENT  '面值(人民币)',
  TRADEUNIT  DECIMAL(10,0)  COMMENT  '买卖单位(股/手)',
  ISSUEPRICECURRENCYUNIT  DECIMAL(10,0)  COMMENT  '发行价单位',
  UNDERWRITINGMODE  DECIMAL(10,0)  COMMENT  '承销方式',
  RATIONMODEL  DECIMAL(10,0)  COMMENT  '发行量定量方式',
  ISSUEVOLPLANNED  DECIMAL(18,2)  COMMENT  '计划发行量(股)',
  NEWSHAREVOLPLANNED  DECIMAL(18,2)  COMMENT  '—配售新股股数(股)',
  STORESHAREVOLPLANNED  DECIMAL(18,2)  COMMENT  '—配售存量股数(股)',
  QUALIFIEDSHALLOTMENTPLANNED  DECIMAL(18,2)  COMMENT  '—##合资格股东优先配售股数(股)',
  PUBLICNEWSHAREPLANNED  DECIMAL(18,2)  COMMENT  '公开发售新股股数(股)',
  PUBLICSTORESHAREPLANNED  DECIMAL(18,2)  COMMENT  '公开发售存量股数(股)',
  STAFFPRIORALLOTMENTPLANNED  DECIMAL(18,2)  COMMENT  '—##全职职员优先发售股数(股)',
  OVERALLOTMENTOPTIONPLANNED  DECIMAL(18,2)  COMMENT  '预计超额配售权股数(股)',
  ISSUEPRICECEILING  DECIMAL(18,8)  COMMENT  '发行价上限(最高价)(元)',
  ISSUEPRICEFLOOR  DECIMAL(18,8)  COMMENT  '发行价下限(元)',
  TRADEUNITPRICEATCEILING  DECIMAL(19,4)  COMMENT  '按最高价每手支付价格(元)',
  REFERRENCEPRICE  DECIMAL(10,0)  COMMENT  '预期参考价位',
  PROCEEDSPLANNED  DECIMAL(19,4)  COMMENT  '预计募资总额(元)',
  NETPROCEEDSPLANNED  DECIMAL(19,4)  COMMENT  '预计所得款净额(元)',
  OVERALLOTMENTPROCEEDSPLANNED  DECIMAL(19,4)  COMMENT  '预计超额配售所得款净额(元)',
  ISSUECOSTPLANNED  DECIMAL(19,4)  COMMENT  '预计发行总费用(元)',
  COMMISIONRATIO  DECIMAL(18,8)  COMMENT  '佣金比例',
  ISSUEEXPIREDATE  STRING  COMMENT  '发行有效期截止日',
  LASTTRADEDATE  STRING  COMMENT  '最后买卖日(优先配额)',
  EXDIVIDATE  STRING  COMMENT  '除权除息日',
  RIGHTREGDATE  STRING  COMMENT  '股权登记日',
  TRANSFERENDFIRSTDATE  STRING  COMMENT  '截止过户首日',
  TRANSFERENDLASTDATE  STRING  COMMENT  '截止过户末日',
  PAYENDDATE  STRING  COMMENT  '缴费截止',
  ISSUEENDDATE  STRING  COMMENT  '发行日期下限',
  DATETOACCOUNT  STRING  COMMENT  '募集资金到帐时间',
  REFUNDMENTOUTDATE  STRING  COMMENT  '退款寄发日',
  ISSUECOMPLISHMENTDATE  STRING  COMMENT  '发行完成日',
  PROPOSEDLISTDATE  STRING  COMMENT  '预计上市日',
  OVERALLOTMENTPROPOSEDLISTDATE  STRING  COMMENT  '超额配售股份预计上市日',
  ISSUERESULTPUBLDATE  STRING  COMMENT  '中签率公告日',
  OVERALLOTMENTOPTIONEXPIREDATE  STRING  COMMENT  '超额配售权行使完成日',
  OFFERRATIOX  DECIMAL(10,0)  COMMENT  '供股比例(X：Y)—X',
  OFFERRATIOY  DECIMAL(10,0)  COMMENT  '供股比例(X：Y)—Y',
  ISSUEBASE  DECIMAL(10,0)  COMMENT  '发行基准',
  ISSUEBASESHARES  DECIMAL(18,2)  COMMENT  '发行基准股数(股)',
  ISSUEVOL  DECIMAL(18,2)  COMMENT  '发行量(股)',
  RATIOINPRISHARE  DECIMAL(18,8)  COMMENT  '占原来股份比例',
  RATIOINPOSTSHARE  DECIMAL(18,8)  COMMENT  '占扩大后股份比例',
  NEWSHAREVOL  DECIMAL(18,2)  COMMENT  '—配售新股股数(股)',
  STORESHAREALLOTMENT  DECIMAL(18,2)  COMMENT  '—配售存量股数(股)',
  QUALIFIEDSHPRIORALLOTMENT  DECIMAL(18,2)  COMMENT  '—##合资格股东优先配售股数(股)',
  PUBLICOFFEREDNEWSHARE  DECIMAL(18,2)  COMMENT  '—公开发售新股股数(股)',
  PUBLICOFFEREDSTORESHARE  DECIMAL(18,2)  COMMENT  '—公开发售存量股数(股)',
  STAFFPRIORALLOTMENT  DECIMAL(18,2)  COMMENT  '—##全职职员优先发售股数(股)',
  OVERALLOTMENTOPTION  DECIMAL(18,2)  COMMENT  '超额配售权(股)',
  OVERALLOTMENTNEWSHARE  DECIMAL(18,2)  COMMENT  '—超额配售新股股数(股)',
  OVERALLOTMENTSTORESHARE  DECIMAL(18,2)  COMMENT  '—超额配售存量股数(股)',
  ISSUEPRICE  DECIMAL(18,8)  COMMENT  '实际发行价(元)',
  TOTALPROCEEDS  DECIMAL(19,4)  COMMENT  '募资总额(元)',
  NETPROCEEDS  DECIMAL(19,4)  COMMENT  '募集资金净额(外币元)',
  OVERALLOTMENTPROCEEDS  DECIMAL(19,4)  COMMENT  '超额配售募资总额(元)',
  OVERALLOTMENTNETPROCEEDS  DECIMAL(19,4)  COMMENT  '超额配售所得款净额(元)',
  PUBAPPLYUNIT  DECIMAL(18,2)  COMMENT  '1)公众股认购有效申请份数(白/黄/电子)',
  PUBAPPLYSHARES  DECIMAL(18,2)  COMMENT  '—公众股认购股数(股)',
  PUBAPPLYMULTIPLE  DECIMAL(18,8)  COMMENT  '—公众股认购倍数',
  STAFFAPPLYUNIT  DECIMAL(18,2)  COMMENT  '2)全职职员优先配售有效申请份数(粉红色)',
  STAFFAPPLYSHARES  DECIMAL(18,2)  COMMENT  '—职员优先配售认购股数(股)',
  STAFFAPPLYMULTIPLE  DECIMAL(18,8)  COMMENT  '—职员优先配售认购倍数',
  ALLOTMENTAPPLYUNITS  DECIMAL(18,2)  COMMENT  '3)配售申请份数',
  ALLOTMENTAPPLYSHARES  DECIMAL(18,2)  COMMENT  '—配售申请股数(股)',
  ALLOTMENTAPPLYMULTIPLE  DECIMAL(18,8)  COMMENT  '—配售申请倍数',
  QUALIFIEDSHAPPLYUNITS  DECIMAL(18,2)  COMMENT  '#合资格股东优先配售有效申请份数(蓝色)',
  QUALIFIEDSHAPPLYSHARES  DECIMAL(18,2)  COMMENT  '—合资格股东优先配售认购股数(股)',
  QUALIFIEDSHAPPLYMULTIPLE  DECIMAL(18,8)  COMMENT  '—合资格股东优先股配售认购倍数',
  VALIDAPPLYSHARES  DECIMAL(18,2)  COMMENT  '4)有效申请总股数(股)',
  VALIDAPPLYALLOTMENTSHARES  DECIMAL(18,2)  COMMENT  '有效申请暂定配额股数(股)',
  VALIDAPPLYOVERALLOTMENTSHARES  DECIMAL(18,2)  COMMENT  '有效申请额外发行股数(股)',
  IRREVOCABLEUNDERTAKINGSHARES  DECIMAL(18,2)  COMMENT  '5)不可撤回承诺股数(股)',
  SUBSCRIBEREMAINSHARES  DECIMAL(18,2)  COMMENT  '认购不足股数(股)',
  UNDERWRITERBOUGHTVOL  DECIMAL(18,2)  COMMENT  '余股包销数量(股)',
  UNDERWRITERNUMBER  DECIMAL(10,0)  COMMENT  '承配人总数',
  FIRSTUNDERWRITERALLOTMENT  DECIMAL(18,2)  COMMENT  '最大承配人配售股数(股)',
  FIRST5UNDERWRITERSALLOTMENT  DECIMAL(18,2)  COMMENT  '前5大承配人配售股数(股)',
  FIRST10UNDERWRITERSALLOTMENT  DECIMAL(18,2)  COMMENT  '前10大承配人配售股数(股)',
  FIRST15UNDERWRITERSALLOTMENT  DECIMAL(18,2)  COMMENT  '前15大承配人配售股数(股)',
  FIRST20UNDERWRITERSALLOTMENT  DECIMAL(18,2)  COMMENT  '前20大承配人配售股数(股)',
  FIRST25UNDERWRITERSALLOTMENT  DECIMAL(18,2)  COMMENT  '前25大承配人配售股数(股)',
  RELATIVEALLOTMENT  DECIMAL(18,2)  COMMENT  '关联人士配售股数(股)',
  STETEMENT  STRING  COMMENT  '备注',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  APPLYSTARTDATE  STRING  COMMENT  '申购起始日',
  PRICINGDATE  STRING  COMMENT  '定价日期',
  MIDPRICEPSHARE  DECIMAL(18,2)  COMMENT  '每股中位价(元)',
  TOTALSUBSHARES  DECIMAL(18,2)  COMMENT  '实际认购股数(股)',
  TOTALNUMSUBCEILING  DECIMAL(18,2)  COMMENT  '认购总股数上限(股)',
  TOTALNUMSUBMEDIAN  DECIMAL(18,2)  COMMENT  '认购总股数中位数(股)',
  TOTALNUMSUBFLOOR  DECIMAL(18,2)  COMMENT  '认购总股数下限(股)',
  GLOBALSALESRATIO  DECIMAL(18,8)  COMMENT  '占全球发售比例(%)',
  ISSUEDCAPITALRATIO  DECIMAL(18,8)  COMMENT  '占已发行股本比例(%)',
  IFOVERALLOTMENT  DECIMAL(10,0)  COMMENT  '是否执行超额配售',
  LASTTRADINGDAYCLOSEPRICE  DECIMAL(18,8)  COMMENT  '转市场前最后交易日收盘价',
  EVENTNUMBER  STRING  COMMENT  '事项编号',
  INITIALISSUEPRICE  DECIMAL(18,8)  COMMENT  '初始发行价',
  TRANSFERSUBENDDATE  STRING  COMMENT  '递交过户文件截止日',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '港股发行与上市'
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
                                   , PROCESS
                                   , BDDECISIONPUBLDATE
                                   , BDDECISIONSIGNDATE
                                   , SMDECIPUBLDATE
                                   , PROSPECTUSPUBLDATE
                                   , CONTRACTSIGNDATE
                                   , ABORTPUBLDATE
                                   , ISSUETYPE
                                   , ISSUEMETHOD
                                   , ISSUEOBJECT
                                   , CURRENCYUNIT
                                   , PARVALUE
                                   , TRADEUNIT
                                   , ISSUEPRICECURRENCYUNIT
                                   , UNDERWRITINGMODE
                                   , RATIONMODEL
                                   , ISSUEVOLPLANNED
                                   , NEWSHAREVOLPLANNED
                                   , STORESHAREVOLPLANNED
                                   , QUALIFIEDSHALLOTMENTPLANNED
                                   , PUBLICNEWSHAREPLANNED
                                   , PUBLICSTORESHAREPLANNED
                                   , STAFFPRIORALLOTMENTPLANNED
                                   , OVERALLOTMENTOPTIONPLANNED
                                   , ISSUEPRICECEILING
                                   , ISSUEPRICEFLOOR
                                   , TRADEUNITPRICEATCEILING
                                   , REFERRENCEPRICE
                                   , PROCEEDSPLANNED
                                   , NETPROCEEDSPLANNED
                                   , OVERALLOTMENTPROCEEDSPLANNED
                                   , ISSUECOSTPLANNED
                                   , COMMISIONRATIO
                                   , ISSUEEXPIREDATE
                                   , LASTTRADEDATE
                                   , EXDIVIDATE
                                   , RIGHTREGDATE
                                   , TRANSFERENDFIRSTDATE
                                   , TRANSFERENDLASTDATE
                                   , PAYENDDATE
                                   , ISSUEENDDATE
                                   , DATETOACCOUNT
                                   , REFUNDMENTOUTDATE
                                   , ISSUECOMPLISHMENTDATE
                                   , PROPOSEDLISTDATE
                                   , OVERALLOTMENTPROPOSEDLISTDATE
                                   , ISSUERESULTPUBLDATE
                                   , OVERALLOTMENTOPTIONEXPIREDATE
                                   , OFFERRATIOX
                                   , OFFERRATIOY
                                   , ISSUEBASE
                                   , ISSUEBASESHARES
                                   , ISSUEVOL
                                   , RATIOINPRISHARE
                                   , RATIOINPOSTSHARE
                                   , NEWSHAREVOL
                                   , STORESHAREALLOTMENT
                                   , QUALIFIEDSHPRIORALLOTMENT
                                   , PUBLICOFFEREDNEWSHARE
                                   , PUBLICOFFEREDSTORESHARE
                                   , STAFFPRIORALLOTMENT
                                   , OVERALLOTMENTOPTION
                                   , OVERALLOTMENTNEWSHARE
                                   , OVERALLOTMENTSTORESHARE
                                   , ISSUEPRICE
                                   , TOTALPROCEEDS
                                   , NETPROCEEDS
                                   , OVERALLOTMENTPROCEEDS
                                   , OVERALLOTMENTNETPROCEEDS
                                   , PUBAPPLYUNIT
                                   , PUBAPPLYSHARES
                                   , PUBAPPLYMULTIPLE
                                   , STAFFAPPLYUNIT
                                   , STAFFAPPLYSHARES
                                   , STAFFAPPLYMULTIPLE
                                   , ALLOTMENTAPPLYUNITS
                                   , ALLOTMENTAPPLYSHARES
                                   , ALLOTMENTAPPLYMULTIPLE
                                   , QUALIFIEDSHAPPLYUNITS
                                   , QUALIFIEDSHAPPLYSHARES
                                   , QUALIFIEDSHAPPLYMULTIPLE
                                   , VALIDAPPLYSHARES
                                   , VALIDAPPLYALLOTMENTSHARES
                                   , VALIDAPPLYOVERALLOTMENTSHARES
                                   , IRREVOCABLEUNDERTAKINGSHARES
                                   , SUBSCRIBEREMAINSHARES
                                   , UNDERWRITERBOUGHTVOL
                                   , UNDERWRITERNUMBER
                                   , FIRSTUNDERWRITERALLOTMENT
                                   , FIRST5UNDERWRITERSALLOTMENT
                                   , FIRST10UNDERWRITERSALLOTMENT
                                   , FIRST15UNDERWRITERSALLOTMENT
                                   , FIRST20UNDERWRITERSALLOTMENT
                                   , FIRST25UNDERWRITERSALLOTMENT
                                   , RELATIVEALLOTMENT
                                   , STETEMENT
                                   , XGRQ
                                   , JSID
                                   , APPLYSTARTDATE
                                   , PRICINGDATE
                                   , MIDPRICEPSHARE
                                   , TOTALSUBSHARES
                                   , TOTALNUMSUBCEILING
                                   , TOTALNUMSUBMEDIAN
                                   , TOTALNUMSUBFLOOR
                                   , GLOBALSALESRATIO
                                   , ISSUEDCAPITALRATIO
                                   , IFOVERALLOTMENT
                                   , LASTTRADINGDAYCLOSEPRICE
                                   , EVENTNUMBER
                                   , INITIALISSUEPRICE
                                   , TRANSFERSUBENDDATE
                                   , INSERTTIME
                                FROM ${jy_src_schema}.HK_SHAREIPO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "PROCESS", "type": "DOUBLE"}, {"name": "BDDECISIONPUBLDATE", "type": "STRING"}, {"name": "BDDECISIONSIGNDATE", "type": "STRING"}, {"name": "SMDECIPUBLDATE", "type": "STRING"}, {"name": "PROSPECTUSPUBLDATE", "type": "STRING"}, {"name": "CONTRACTSIGNDATE", "type": "STRING"}, {"name": "ABORTPUBLDATE", "type": "STRING"}, {"name": "ISSUETYPE", "type": "DOUBLE"}, {"name": "ISSUEMETHOD", "type": "DOUBLE"}, {"name": "ISSUEOBJECT", "type": "DOUBLE"}, {"name": "CURRENCYUNIT", "type": "DOUBLE"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "TRADEUNIT", "type": "DOUBLE"}, {"name": "ISSUEPRICECURRENCYUNIT", "type": "DOUBLE"}, {"name": "UNDERWRITINGMODE", "type": "DOUBLE"}, {"name": "RATIONMODEL", "type": "DOUBLE"}, {"name": "ISSUEVOLPLANNED", "type": "DOUBLE"}, {"name": "NEWSHAREVOLPLANNED", "type": "DOUBLE"}, {"name": "STORESHAREVOLPLANNED", "type": "DOUBLE"}, {"name": "QUALIFIEDSHALLOTMENTPLANNED", "type": "DOUBLE"}, {"name": "PUBLICNEWSHAREPLANNED", "type": "DOUBLE"}, {"name": "PUBLICSTORESHAREPLANNED", "type": "DOUBLE"}, {"name": "STAFFPRIORALLOTMENTPLANNED", "type": "DOUBLE"}, {"name": "OVERALLOTMENTOPTIONPLANNED", "type": "DOUBLE"}, {"name": "ISSUEPRICECEILING", "type": "DOUBLE"}, {"name": "ISSUEPRICEFLOOR", "type": "DOUBLE"}, {"name": "TRADEUNITPRICEATCEILING", "type": "DOUBLE"}, {"name": "REFERRENCEPRICE", "type": "DOUBLE"}, {"name": "PROCEEDSPLANNED", "type": "DOUBLE"}, {"name": "NETPROCEEDSPLANNED", "type": "DOUBLE"}, {"name": "OVERALLOTMENTPROCEEDSPLANNED", "type": "DOUBLE"}, {"name": "ISSUECOSTPLANNED", "type": "DOUBLE"}, {"name": "COMMISIONRATIO", "type": "DOUBLE"}, {"name": "ISSUEEXPIREDATE", "type": "STRING"}, {"name": "LASTTRADEDATE", "type": "STRING"}, {"name": "EXDIVIDATE", "type": "STRING"}, {"name": "RIGHTREGDATE", "type": "STRING"}, {"name": "TRANSFERENDFIRSTDATE", "type": "STRING"}, {"name": "TRANSFERENDLASTDATE", "type": "STRING"}, {"name": "PAYENDDATE", "type": "STRING"}, {"name": "ISSUEENDDATE", "type": "STRING"}, {"name": "DATETOACCOUNT", "type": "STRING"}, {"name": "REFUNDMENTOUTDATE", "type": "STRING"}, {"name": "ISSUECOMPLISHMENTDATE", "type": "STRING"}, {"name": "PROPOSEDLISTDATE", "type": "STRING"}, {"name": "OVERALLOTMENTPROPOSEDLISTDATE", "type": "STRING"}, {"name": "ISSUERESULTPUBLDATE", "type": "STRING"}, {"name": "OVERALLOTMENTOPTIONEXPIREDATE", "type": "STRING"}, {"name": "OFFERRATIOX", "type": "DOUBLE"}, {"name": "OFFERRATIOY", "type": "DOUBLE"}, {"name": "ISSUEBASE", "type": "DOUBLE"}, {"name": "ISSUEBASESHARES", "type": "DOUBLE"}, {"name": "ISSUEVOL", "type": "DOUBLE"}, {"name": "RATIOINPRISHARE", "type": "DOUBLE"}, {"name": "RATIOINPOSTSHARE", "type": "DOUBLE"}, {"name": "NEWSHAREVOL", "type": "DOUBLE"}, {"name": "STORESHAREALLOTMENT", "type": "DOUBLE"}, {"name": "QUALIFIEDSHPRIORALLOTMENT", "type": "DOUBLE"}, {"name": "PUBLICOFFEREDNEWSHARE", "type": "DOUBLE"}, {"name": "PUBLICOFFEREDSTORESHARE", "type": "DOUBLE"}, {"name": "STAFFPRIORALLOTMENT", "type": "DOUBLE"}, {"name": "OVERALLOTMENTOPTION", "type": "DOUBLE"}, {"name": "OVERALLOTMENTNEWSHARE", "type": "DOUBLE"}, {"name": "OVERALLOTMENTSTORESHARE", "type": "DOUBLE"}, {"name": "ISSUEPRICE", "type": "DOUBLE"}, {"name": "TOTALPROCEEDS", "type": "DOUBLE"}, {"name": "NETPROCEEDS", "type": "DOUBLE"}, {"name": "OVERALLOTMENTPROCEEDS", "type": "DOUBLE"}, {"name": "OVERALLOTMENTNETPROCEEDS", "type": "DOUBLE"}, {"name": "PUBAPPLYUNIT", "type": "DOUBLE"}, {"name": "PUBAPPLYSHARES", "type": "DOUBLE"}, {"name": "PUBAPPLYMULTIPLE", "type": "DOUBLE"}, {"name": "STAFFAPPLYUNIT", "type": "DOUBLE"}, {"name": "STAFFAPPLYSHARES", "type": "DOUBLE"}, {"name": "STAFFAPPLYMULTIPLE", "type": "DOUBLE"}, {"name": "ALLOTMENTAPPLYUNITS", "type": "DOUBLE"}, {"name": "ALLOTMENTAPPLYSHARES", "type": "DOUBLE"}, {"name": "ALLOTMENTAPPLYMULTIPLE", "type": "DOUBLE"}, {"name": "QUALIFIEDSHAPPLYUNITS", "type": "DOUBLE"}, {"name": "QUALIFIEDSHAPPLYSHARES", "type": "DOUBLE"}, {"name": "QUALIFIEDSHAPPLYMULTIPLE", "type": "DOUBLE"}, {"name": "VALIDAPPLYSHARES", "type": "DOUBLE"}, {"name": "VALIDAPPLYALLOTMENTSHARES", "type": "DOUBLE"}, {"name": "VALIDAPPLYOVERALLOTMENTSHARES", "type": "DOUBLE"}, {"name": "IRREVOCABLEUNDERTAKINGSHARES", "type": "DOUBLE"}, {"name": "SUBSCRIBEREMAINSHARES", "type": "DOUBLE"}, {"name": "UNDERWRITERBOUGHTVOL", "type": "DOUBLE"}, {"name": "UNDERWRITERNUMBER", "type": "DOUBLE"}, {"name": "FIRSTUNDERWRITERALLOTMENT", "type": "DOUBLE"}, {"name": "FIRST5UNDERWRITERSALLOTMENT", "type": "DOUBLE"}, {"name": "FIRST10UNDERWRITERSALLOTMENT", "type": "DOUBLE"}, {"name": "FIRST15UNDERWRITERSALLOTMENT", "type": "DOUBLE"}, {"name": "FIRST20UNDERWRITERSALLOTMENT", "type": "DOUBLE"}, {"name": "FIRST25UNDERWRITERSALLOTMENT", "type": "DOUBLE"}, {"name": "RELATIVEALLOTMENT", "type": "DOUBLE"}, {"name": "STETEMENT", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "APPLYSTARTDATE", "type": "STRING"}, {"name": "PRICINGDATE", "type": "STRING"}, {"name": "MIDPRICEPSHARE", "type": "DOUBLE"}, {"name": "TOTALSUBSHARES", "type": "DOUBLE"}, {"name": "TOTALNUMSUBCEILING", "type": "DOUBLE"}, {"name": "TOTALNUMSUBMEDIAN", "type": "DOUBLE"}, {"name": "TOTALNUMSUBFLOOR", "type": "DOUBLE"}, {"name": "GLOBALSALESRATIO", "type": "DOUBLE"}, {"name": "ISSUEDCAPITALRATIO", "type": "DOUBLE"}, {"name": "IFOVERALLOTMENT", "type": "DOUBLE"}, {"name": "LASTTRADINGDAYCLOSEPRICE", "type": "DOUBLE"}, {"name": "EVENTNUMBER", "type": "DOUBLE"}, {"name": "INITIALISSUEPRICE", "type": "DOUBLE"}, {"name": "TRANSFERSUBENDDATE", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_hk_shareipo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_hk_shareipo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_hk_shareipo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_hk_shareipo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_HK_SHAREIPO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_HK_SHAREIPO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_hk_shareipo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_HK_SHAREIPO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INITIALINFOPUBLDATE
     , PROCESS
     , BDDECISIONPUBLDATE
     , BDDECISIONSIGNDATE
     , SMDECIPUBLDATE
     , PROSPECTUSPUBLDATE
     , CONTRACTSIGNDATE
     , ABORTPUBLDATE
     , ISSUETYPE
     , ISSUEMETHOD
     , ISSUEOBJECT
     , CURRENCYUNIT
     , PARVALUE
     , TRADEUNIT
     , ISSUEPRICECURRENCYUNIT
     , UNDERWRITINGMODE
     , RATIONMODEL
     , ISSUEVOLPLANNED
     , NEWSHAREVOLPLANNED
     , STORESHAREVOLPLANNED
     , QUALIFIEDSHALLOTMENTPLANNED
     , PUBLICNEWSHAREPLANNED
     , PUBLICSTORESHAREPLANNED
     , STAFFPRIORALLOTMENTPLANNED
     , OVERALLOTMENTOPTIONPLANNED
     , ISSUEPRICECEILING
     , ISSUEPRICEFLOOR
     , TRADEUNITPRICEATCEILING
     , REFERRENCEPRICE
     , PROCEEDSPLANNED
     , NETPROCEEDSPLANNED
     , OVERALLOTMENTPROCEEDSPLANNED
     , ISSUECOSTPLANNED
     , COMMISIONRATIO
     , ISSUEEXPIREDATE
     , LASTTRADEDATE
     , EXDIVIDATE
     , RIGHTREGDATE
     , TRANSFERENDFIRSTDATE
     , TRANSFERENDLASTDATE
     , PAYENDDATE
     , ISSUEENDDATE
     , DATETOACCOUNT
     , REFUNDMENTOUTDATE
     , ISSUECOMPLISHMENTDATE
     , PROPOSEDLISTDATE
     , OVERALLOTMENTPROPOSEDLISTDATE
     , ISSUERESULTPUBLDATE
     , OVERALLOTMENTOPTIONEXPIREDATE
     , OFFERRATIOX
     , OFFERRATIOY
     , ISSUEBASE
     , ISSUEBASESHARES
     , ISSUEVOL
     , RATIOINPRISHARE
     , RATIOINPOSTSHARE
     , NEWSHAREVOL
     , STORESHAREALLOTMENT
     , QUALIFIEDSHPRIORALLOTMENT
     , PUBLICOFFEREDNEWSHARE
     , PUBLICOFFEREDSTORESHARE
     , STAFFPRIORALLOTMENT
     , OVERALLOTMENTOPTION
     , OVERALLOTMENTNEWSHARE
     , OVERALLOTMENTSTORESHARE
     , ISSUEPRICE
     , TOTALPROCEEDS
     , NETPROCEEDS
     , OVERALLOTMENTPROCEEDS
     , OVERALLOTMENTNETPROCEEDS
     , PUBAPPLYUNIT
     , PUBAPPLYSHARES
     , PUBAPPLYMULTIPLE
     , STAFFAPPLYUNIT
     , STAFFAPPLYSHARES
     , STAFFAPPLYMULTIPLE
     , ALLOTMENTAPPLYUNITS
     , ALLOTMENTAPPLYSHARES
     , ALLOTMENTAPPLYMULTIPLE
     , QUALIFIEDSHAPPLYUNITS
     , QUALIFIEDSHAPPLYSHARES
     , QUALIFIEDSHAPPLYMULTIPLE
     , VALIDAPPLYSHARES
     , VALIDAPPLYALLOTMENTSHARES
     , VALIDAPPLYOVERALLOTMENTSHARES
     , IRREVOCABLEUNDERTAKINGSHARES
     , SUBSCRIBEREMAINSHARES
     , UNDERWRITERBOUGHTVOL
     , UNDERWRITERNUMBER
     , FIRSTUNDERWRITERALLOTMENT
     , FIRST5UNDERWRITERSALLOTMENT
     , FIRST10UNDERWRITERSALLOTMENT
     , FIRST15UNDERWRITERSALLOTMENT
     , FIRST20UNDERWRITERSALLOTMENT
     , FIRST25UNDERWRITERSALLOTMENT
     , RELATIVEALLOTMENT
     , STETEMENT
     , XGRQ
     , JSID
     , APPLYSTARTDATE
     , PRICINGDATE
     , MIDPRICEPSHARE
     , TOTALSUBSHARES
     , TOTALNUMSUBCEILING
     , TOTALNUMSUBMEDIAN
     , TOTALNUMSUBFLOOR
     , GLOBALSALESRATIO
     , ISSUEDCAPITALRATIO
     , IFOVERALLOTMENT
     , LASTTRADINGDAYCLOSEPRICE
     , EVENTNUMBER
     , INITIALISSUEPRICE
     , TRANSFERSUBENDDATE
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_HK_SHAREIPO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_HK_SHAREIPO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_HK_SHAREIPO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_HK_SHAREIPO_PFD成功"
      exit 0
   fi
fi
