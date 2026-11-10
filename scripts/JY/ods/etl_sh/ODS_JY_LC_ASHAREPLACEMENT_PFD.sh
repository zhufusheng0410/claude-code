#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_ASHAREPLACEMENT_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHAREPLACEMENT_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  PLAYEAR  STRING  COMMENT  '配股年度',
  STOCKTYPE  STRING  COMMENT  '发行股票类型',
  ADVANCEDATE  STRING  COMMENT  '预案发布日期',
  SMDECIPUBLDATE  STRING  COMMENT  '股东大会决议公告日期',
  PRICINGMODEL  DECIMAL(10,0)  COMMENT  '定价方式',
  PRICINGDESCRIPTION  STRING  COMMENT  '配股价格确定方式说明',
  ADVANCEVALIDSTARTDATE  STRING  COMMENT  '预案有效期起始日',
  ADVANCEVALIDENDDATE  STRING  COMMENT  '预案有效期截止日',
  PLARATIOPLANNED  DECIMAL(9,4)  COMMENT  '计划配股比例(10配X)',
  PLAPRICECEILING  DECIMAL(19,4)  COMMENT  '配股价格上限(最高价)(元)',
  PLAPRICEFLOOR  DECIMAL(19,4)  COMMENT  '配股价格下限(最低价)(元)',
  DECIPUBLDATE  STRING  COMMENT  '决案公布日',
  PLAPROSPECTUSPUBLDATE  STRING  COMMENT  '配股说明书刊登日期',
  PLAABBRNAME  STRING  COMMENT  '配股简称',
  PLACODE  STRING  COMMENT  '配股代码',
  BASESHARES  DECIMAL(16,0)  COMMENT  '配股股本基数(股)',
  PLANNEDPLAVOL  DECIMAL(16,0)  COMMENT  '计划配股数量(股)',
  ACTUALPLARATIO  DECIMAL(9,4)  COMMENT  '实际配股比例(10配X)',
  ACTUALPLAVOL  DECIMAL(16,0)  COMMENT  '实际配股数量(股)',
  PLAOBJECT  STRING  COMMENT  '配股对象',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  PLAPRICE  DECIMAL(19,4)  COMMENT  '每股配股价格(元)',
  TRANSFERPLARATIO  DECIMAL(9,4)  COMMENT  '转配比(10转配X)',
  TRANSFERPLAVOL  DECIMAL(16,0)  COMMENT  '转配股(股)',
  TRANSFERFEEPERSHARE  DECIMAL(19,4)  COMMENT  '每股转配费(元)',
  ODDLOTSTREATMENT  DECIMAL(10,0)  COMMENT  '零股处理方法',
  PLAPROCEEDS  DECIMAL(19,4)  COMMENT  '实际募集资金(元)',
  PLACOST  DECIMAL(19,4)  COMMENT  '发行费用总额(元)',
  UNDERWRITINGFEE  DECIMAL(19,4)  COMMENT  '承销费用(元)',
  CPAFEE  DECIMAL(19,4)  COMMENT  '注册会计师费用(元)',
  ASSETAPPRAISALFEE  DECIMAL(19,4)  COMMENT  '资产评估费用(元)',
  LANDEVALUATIONFEE  DECIMAL(19,4)  COMMENT  '土地评估费用(元)',
  ATTORNEYFEE  DECIMAL(19,4)  COMMENT  '律师费用(元)',
  TOTALAGENTFEE  DECIMAL(19,4)  COMMENT  '中介机构费合计(元)',
  ONLINEISSUEFEE  DECIMAL(19,4)  COMMENT  '上网发行费用(元)',
  SCRIPFEE  DECIMAL(19,4)  COMMENT  '股票登记费用(元)',
  SPONSORFEE  DECIMAL(19,4)  COMMENT  '上市推荐费用(元)',
  OTHERFEE  DECIMAL(19,4)  COMMENT  '其他费用(元)',
  PLANETPROCEEDS  DECIMAL(19,4)  COMMENT  '募集资金净额(元)',
  RIGHTREGDATE  STRING  COMMENT  '股权登记日',
  EXRIGHTDATE  STRING  COMMENT  '除权日',
  PAYSTARTDATE  STRING  COMMENT  '缴费起始',
  PAYENDDATE  STRING  COMMENT  '缴费截止',
  DATETOACCOUNT  STRING  COMMENT  '募集资金到帐时间',
  MONEYTOACCOUNT  DECIMAL(19,4)  COMMENT  '募集资金到帐金额(元)',
  PLALISTDATE  STRING  COMMENT  '配股上市日',
  LARGESHSUBSSTATEMENT  STRING  COMMENT  '大股东认配说明',
  SCHEMECHANGE  DECIMAL(10,0)  COMMENT  '方案是否变更',
  CHANGESTATEMENT  STRING  COMMENT  '方案变动说明',
  UNDERWRITINGMODE  DECIMAL(10,0)  COMMENT  '承销方式',
  UNDERWRITERBOUGHTVOL  DECIMAL(16,0)  COMMENT  '余股包销数量(股)',
  PUBLICSHSUBSCRIPTIONESTI  DECIMAL(16,0)  COMMENT  '公众股东预计认配股数(股)',
  PUBLICSHSUBSCRIPTIONACTU  DECIMAL(16,0)  COMMENT  '公众股东实际认配股数(股)',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  PLANNEDPLAPROCEEDS  DECIMAL(19,4)  COMMENT  '计划募集资金总额(元)',
  ADJUSTEDPLARATIOPL  DECIMAL(9,4)  COMMENT  '最新计划配股比例(10配X)',
  ADJUSTEDPLAVOLPL  DECIMAL(16,0)  COMMENT  '最新计划配股数量(股)',
  UWSPONFEE  DECIMAL(19,4)  COMMENT  '1)承销保荐费用合计(元)',
  CPAAPPRAISALFEE  DECIMAL(19,4)  COMMENT  '2)审计验资及评估费用合计(元)',
  CSRCIACAPPROVALDATE  STRING  COMMENT  '证监会发审委通过公告日',
  SASACAPPROVALPUBLDATE  STRING  COMMENT  '国资委通过公告日',
  CSRCAPPROVALPUBLDATE  STRING  COMMENT  '证监会批准公告日',
  EXAPPROVALPUBLDATE  STRING  COMMENT  '交易所审核通过日',
  ISSUEMETHOD  DECIMAL(10,0)  COMMENT  '发行方式',
  EVENTPROCEDURECODE  DECIMAL(10,0)  COMMENT  '事件进程1',
  LATESTINFOPUBLDATE  STRING  COMMENT  '最新公告日期',
  PLAPROSPECTUS  STRING  COMMENT  '配股说明',
  RESULTPULBDATE  STRING  COMMENT  '配股结果公告日',
  LISTANNOUNCEDATE  STRING  COMMENT  '配股上市公告日',
  PLANNEDBASESHARES  DECIMAL(16,0)  COMMENT  '计划配股股本基数(股)',
  PLAOBJECTCATEGORY  DECIMAL(10,0)  COMMENT  '配股对象类别',
  PLABASEDATE  STRING  COMMENT  '配股基准日',
  LARGESHHOLDSUM  DECIMAL(16,0)  COMMENT  '持股5%以上大股东持股数(股)',
  LARGESHSUBSCRIPESTI  DECIMAL(16,0)  COMMENT  '持股5%以上大股东计划认配股数(股)',
  LARGESHSUBSCRIPACTU  DECIMAL(16,0)  COMMENT  '持股5%以上大股东实际认配股数(股)',
  NAPSAFTERALLOTMENT  DECIMAL(19,4)  COMMENT  '配股完成后预计每股净资产(元)',
  EPSAFTERALLOTMENT  DECIMAL(19,4)  COMMENT  '配股完成后预计每股收益(元)',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT 'A股配股'
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
                                   , PLAYEAR
                                   , STOCKTYPE
                                   , ADVANCEDATE
                                   , SMDECIPUBLDATE
                                   , PRICINGMODEL
                                   , PRICINGDESCRIPTION
                                   , ADVANCEVALIDSTARTDATE
                                   , ADVANCEVALIDENDDATE
                                   , PLARATIOPLANNED
                                   , PLAPRICECEILING
                                   , PLAPRICEFLOOR
                                   , DECIPUBLDATE
                                   , PLAPROSPECTUSPUBLDATE
                                   , PLAABBRNAME
                                   , PLACODE
                                   , BASESHARES
                                   , PLANNEDPLAVOL
                                   , ACTUALPLARATIO
                                   , ACTUALPLAVOL
                                   , PLAOBJECT
                                   , PARVALUE
                                   , PLAPRICE
                                   , TRANSFERPLARATIO
                                   , TRANSFERPLAVOL
                                   , TRANSFERFEEPERSHARE
                                   , ODDLOTSTREATMENT
                                   , PLAPROCEEDS
                                   , PLACOST
                                   , UNDERWRITINGFEE
                                   , CPAFEE
                                   , ASSETAPPRAISALFEE
                                   , LANDEVALUATIONFEE
                                   , ATTORNEYFEE
                                   , TOTALAGENTFEE
                                   , ONLINEISSUEFEE
                                   , SCRIPFEE
                                   , SPONSORFEE
                                   , OTHERFEE
                                   , PLANETPROCEEDS
                                   , RIGHTREGDATE
                                   , EXRIGHTDATE
                                   , PAYSTARTDATE
                                   , PAYENDDATE
                                   , DATETOACCOUNT
                                   , MONEYTOACCOUNT
                                   , PLALISTDATE
                                   , LARGESHSUBSSTATEMENT
                                   , SCHEMECHANGE
                                   , CHANGESTATEMENT
                                   , UNDERWRITINGMODE
                                   , UNDERWRITERBOUGHTVOL
                                   , PUBLICSHSUBSCRIPTIONESTI
                                   , PUBLICSHSUBSCRIPTIONACTU
                                   , XGRQ
                                   , JSID
                                   , PLANNEDPLAPROCEEDS
                                   , ADJUSTEDPLARATIOPL
                                   , ADJUSTEDPLAVOLPL
                                   , UWSPONFEE
                                   , CPAAPPRAISALFEE
                                   , CSRCIACAPPROVALDATE
                                   , SASACAPPROVALPUBLDATE
                                   , CSRCAPPROVALPUBLDATE
                                   , EXAPPROVALPUBLDATE
                                   , ISSUEMETHOD
                                   , EVENTPROCEDURECODE
                                   , LATESTINFOPUBLDATE
                                   , PLAPROSPECTUS
                                   , RESULTPULBDATE
                                   , LISTANNOUNCEDATE
                                   , PLANNEDBASESHARES
                                   , PLAOBJECTCATEGORY
                                   , PLABASEDATE
                                   , LARGESHHOLDSUM
                                   , LARGESHSUBSCRIPESTI
                                   , LARGESHSUBSCRIPACTU
                                   , NAPSAFTERALLOTMENT
                                   , EPSAFTERALLOTMENT
                                   , INSERTTIME
                                FROM ${jy_src_schema}.LC_ASHAREPLACEMENT"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "PLAYEAR", "type": "STRING"}, {"name": "STOCKTYPE", "type": "DOUBLE"}, {"name": "ADVANCEDATE", "type": "STRING"}, {"name": "SMDECIPUBLDATE", "type": "STRING"}, {"name": "PRICINGMODEL", "type": "DOUBLE"}, {"name": "PRICINGDESCRIPTION", "type": "STRING"}, {"name": "ADVANCEVALIDSTARTDATE", "type": "STRING"}, {"name": "ADVANCEVALIDENDDATE", "type": "STRING"}, {"name": "PLARATIOPLANNED", "type": "DOUBLE"}, {"name": "PLAPRICECEILING", "type": "DOUBLE"}, {"name": "PLAPRICEFLOOR", "type": "DOUBLE"}, {"name": "DECIPUBLDATE", "type": "STRING"}, {"name": "PLAPROSPECTUSPUBLDATE", "type": "STRING"}, {"name": "PLAABBRNAME", "type": "STRING"}, {"name": "PLACODE", "type": "STRING"}, {"name": "BASESHARES", "type": "DOUBLE"}, {"name": "PLANNEDPLAVOL", "type": "DOUBLE"}, {"name": "ACTUALPLARATIO", "type": "DOUBLE"}, {"name": "ACTUALPLAVOL", "type": "DOUBLE"}, {"name": "PLAOBJECT", "type": "STRING"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "PLAPRICE", "type": "DOUBLE"}, {"name": "TRANSFERPLARATIO", "type": "DOUBLE"}, {"name": "TRANSFERPLAVOL", "type": "DOUBLE"}, {"name": "TRANSFERFEEPERSHARE", "type": "DOUBLE"}, {"name": "ODDLOTSTREATMENT", "type": "DOUBLE"}, {"name": "PLAPROCEEDS", "type": "DOUBLE"}, {"name": "PLACOST", "type": "DOUBLE"}, {"name": "UNDERWRITINGFEE", "type": "DOUBLE"}, {"name": "CPAFEE", "type": "DOUBLE"}, {"name": "ASSETAPPRAISALFEE", "type": "DOUBLE"}, {"name": "LANDEVALUATIONFEE", "type": "DOUBLE"}, {"name": "ATTORNEYFEE", "type": "DOUBLE"}, {"name": "TOTALAGENTFEE", "type": "DOUBLE"}, {"name": "ONLINEISSUEFEE", "type": "DOUBLE"}, {"name": "SCRIPFEE", "type": "DOUBLE"}, {"name": "SPONSORFEE", "type": "DOUBLE"}, {"name": "OTHERFEE", "type": "DOUBLE"}, {"name": "PLANETPROCEEDS", "type": "DOUBLE"}, {"name": "RIGHTREGDATE", "type": "STRING"}, {"name": "EXRIGHTDATE", "type": "STRING"}, {"name": "PAYSTARTDATE", "type": "STRING"}, {"name": "PAYENDDATE", "type": "STRING"}, {"name": "DATETOACCOUNT", "type": "STRING"}, {"name": "MONEYTOACCOUNT", "type": "DOUBLE"}, {"name": "PLALISTDATE", "type": "STRING"}, {"name": "LARGESHSUBSSTATEMENT", "type": "STRING"}, {"name": "SCHEMECHANGE", "type": "DOUBLE"}, {"name": "CHANGESTATEMENT", "type": "STRING"}, {"name": "UNDERWRITINGMODE", "type": "DOUBLE"}, {"name": "UNDERWRITERBOUGHTVOL", "type": "DOUBLE"}, {"name": "PUBLICSHSUBSCRIPTIONESTI", "type": "DOUBLE"}, {"name": "PUBLICSHSUBSCRIPTIONACTU", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "PLANNEDPLAPROCEEDS", "type": "DOUBLE"}, {"name": "ADJUSTEDPLARATIOPL", "type": "DOUBLE"}, {"name": "ADJUSTEDPLAVOLPL", "type": "DOUBLE"}, {"name": "UWSPONFEE", "type": "DOUBLE"}, {"name": "CPAAPPRAISALFEE", "type": "DOUBLE"}, {"name": "CSRCIACAPPROVALDATE", "type": "STRING"}, {"name": "SASACAPPROVALPUBLDATE", "type": "STRING"}, {"name": "CSRCAPPROVALPUBLDATE", "type": "STRING"}, {"name": "EXAPPROVALPUBLDATE", "type": "STRING"}, {"name": "ISSUEMETHOD", "type": "DOUBLE"}, {"name": "EVENTPROCEDURECODE", "type": "DOUBLE"}, {"name": "LATESTINFOPUBLDATE", "type": "STRING"}, {"name": "PLAPROSPECTUS", "type": "STRING"}, {"name": "RESULTPULBDATE", "type": "STRING"}, {"name": "LISTANNOUNCEDATE", "type": "STRING"}, {"name": "PLANNEDBASESHARES", "type": "DOUBLE"}, {"name": "PLAOBJECTCATEGORY", "type": "DOUBLE"}, {"name": "PLABASEDATE", "type": "STRING"}, {"name": "LARGESHHOLDSUM", "type": "DOUBLE"}, {"name": "LARGESHSUBSCRIPESTI", "type": "DOUBLE"}, {"name": "LARGESHSUBSCRIPACTU", "type": "DOUBLE"}, {"name": "NAPSAFTERALLOTMENT", "type": "DOUBLE"}, {"name": "EPSAFTERALLOTMENT", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_ashareplacement_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_ashareplacement_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_ashareplacement_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_ashareplacement_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_ASHAREPLACEMENT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_ASHAREPLACEMENT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_ashareplacement_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHAREPLACEMENT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INITIALINFOPUBLDATE
     , PLAYEAR
     , STOCKTYPE
     , ADVANCEDATE
     , SMDECIPUBLDATE
     , PRICINGMODEL
     , PRICINGDESCRIPTION
     , ADVANCEVALIDSTARTDATE
     , ADVANCEVALIDENDDATE
     , PLARATIOPLANNED
     , PLAPRICECEILING
     , PLAPRICEFLOOR
     , DECIPUBLDATE
     , PLAPROSPECTUSPUBLDATE
     , PLAABBRNAME
     , PLACODE
     , BASESHARES
     , PLANNEDPLAVOL
     , ACTUALPLARATIO
     , ACTUALPLAVOL
     , PLAOBJECT
     , PARVALUE
     , PLAPRICE
     , TRANSFERPLARATIO
     , TRANSFERPLAVOL
     , TRANSFERFEEPERSHARE
     , ODDLOTSTREATMENT
     , PLAPROCEEDS
     , PLACOST
     , UNDERWRITINGFEE
     , CPAFEE
     , ASSETAPPRAISALFEE
     , LANDEVALUATIONFEE
     , ATTORNEYFEE
     , TOTALAGENTFEE
     , ONLINEISSUEFEE
     , SCRIPFEE
     , SPONSORFEE
     , OTHERFEE
     , PLANETPROCEEDS
     , RIGHTREGDATE
     , EXRIGHTDATE
     , PAYSTARTDATE
     , PAYENDDATE
     , DATETOACCOUNT
     , MONEYTOACCOUNT
     , PLALISTDATE
     , LARGESHSUBSSTATEMENT
     , SCHEMECHANGE
     , CHANGESTATEMENT
     , UNDERWRITINGMODE
     , UNDERWRITERBOUGHTVOL
     , PUBLICSHSUBSCRIPTIONESTI
     , PUBLICSHSUBSCRIPTIONACTU
     , XGRQ
     , JSID
     , PLANNEDPLAPROCEEDS
     , ADJUSTEDPLARATIOPL
     , ADJUSTEDPLAVOLPL
     , UWSPONFEE
     , CPAAPPRAISALFEE
     , CSRCIACAPPROVALDATE
     , SASACAPPROVALPUBLDATE
     , CSRCAPPROVALPUBLDATE
     , EXAPPROVALPUBLDATE
     , ISSUEMETHOD
     , EVENTPROCEDURECODE
     , LATESTINFOPUBLDATE
     , PLAPROSPECTUS
     , RESULTPULBDATE
     , LISTANNOUNCEDATE
     , PLANNEDBASESHARES
     , PLAOBJECTCATEGORY
     , PLABASEDATE
     , LARGESHHOLDSUM
     , LARGESHSUBSCRIPESTI
     , LARGESHSUBSCRIPACTU
     , NAPSAFTERALLOTMENT
     , EPSAFTERALLOTMENT
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_ASHAREPLACEMENT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_ASHAREPLACEMENT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_ASHAREPLACEMENT_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_ASHAREPLACEMENT_PFD成功"
      exit 0
   fi
fi
