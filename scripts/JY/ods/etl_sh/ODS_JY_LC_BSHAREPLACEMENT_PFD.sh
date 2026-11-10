#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_BSHAREPLACEMENT_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_BSHAREPLACEMENT_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  PLAYEAR  STRING  COMMENT  '配股年度',
  STOCKTYPE  STRING  COMMENT  '发行股票类型',
  ADVANCEDATE  STRING  COMMENT  '预案发布日期',
  SMDECIPUBLDATE  STRING  COMMENT  '股东大会决议公告日期',
  ADVANCEVALIDSTARTDATE  STRING  COMMENT  '预案有效期起始日',
  ADVANCEVALIDENDDATE  STRING  COMMENT  '预案有效期截止日',
  PLARATIOPLANNED  DECIMAL(9,4)  COMMENT  '计划配股比例(10配X)',
  PRICINGMODEL  DECIMAL(10,0)  COMMENT  '定价方式',
  PRICINGDESCRIPTION  STRING  COMMENT  '配股价格确定方式说明',
  PRICEUNIT  STRING  COMMENT  '期货单位',
  PLAPRICECEILINGRMB  DECIMAL(19,4)  COMMENT  '配股价格上限(人民币元)',
  PLAPRICEFLOORRMB  DECIMAL(19,4)  COMMENT  '配股价格下限(人民币元)',
  PLAPRICECEILINGFC  DECIMAL(19,4)  COMMENT  '配股价格上限(外币元)',
  PLAPRICEFLOORFC  DECIMAL(19,4)  COMMENT  '配股价格下限(外币元)',
  AUTHORIZEDDECLAREDATE  STRING  COMMENT  '配股获准公告日',
  PLAPROSPECTUSPUBLDATE  STRING  COMMENT  '配股说明书刊登日期',
  WARRANTABBRNAME  STRING  COMMENT  '配股权证简称',
  WARRANTCODE  STRING  COMMENT  '配股权证代码',
  ACTUALPLARATIO  DECIMAL(9,4)  COMMENT  '实际配股比例(10配X)',
  PLAOBJECT  STRING  COMMENT  '配股对象',
  PARVALUERMB  DECIMAL(19,4)  COMMENT  '每股面值(人民币元)',
  PLAPRICERMB  DECIMAL(19,4)  COMMENT  '每股配股价格(人民币元)',
  PLAPRICEFC  DECIMAL(19,4)  COMMENT  '每股配股价格(外币)',
  PLANNEDPLAVOL  DECIMAL(16,0)  COMMENT  '计划配股数量(股)',
  ODDLOTSTREATMENT  DECIMAL(10,0)  COMMENT  '零股处理方法',
  LASTTRADINGDAY  STRING  COMMENT  '最后交易日',
  EXRIGHTDATE  STRING  COMMENT  '除权日',
  RIGHTREGDATE  STRING  COMMENT  '股权登记日',
  WARRANTTRADESTARTDATE  STRING  COMMENT  '配股权证交易起始日',
  WARRANTTRADEENDDATE  STRING  COMMENT  '配股权证交易截至日',
  PAYSTARTDATE  STRING  COMMENT  '缴费起始',
  PAYENDDATE  STRING  COMMENT  '缴费截止',
  PLALISTDATE  STRING  COMMENT  '配股上市日',
  IPOPROCEEDSRMB  DECIMAL(19,4)  COMMENT  '募集资金总额(人民币元)',
  ISSUECOSTRMB  DECIMAL(19,4)  COMMENT  '发行费用(人民币元)',
  IPONETPROCEEDSRMB  DECIMAL(19,4)  COMMENT  '募集资金净额(人民币元)',
  IPOPROCEEDSFC  DECIMAL(19,4)  COMMENT  '募集资金总额(外币元)',
  ISSUECOSTFC  DECIMAL(19,4)  COMMENT  '发行费用(外币元)',
  IPONETPROCEEDSFC  DECIMAL(19,4)  COMMENT  '募集资金净额(外币元)',
  SCHEMECHANGE  DECIMAL(10,0)  COMMENT  '方案是否变更',
  CHANGESTATEMENT  STRING  COMMENT  '方案变动说明',
  UNDERWRITINGMODE  DECIMAL(10,0)  COMMENT  '承销方式',
  ACTUALPLAVOL  DECIMAL(16,0)  COMMENT  '实际配股数量(股)',
  UNDERWRITERBOUGHTVOL  DECIMAL(16,0)  COMMENT  '余股包销数量(股)',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  EVENTPROCEDURECODE  DECIMAL(10,0)  COMMENT  '事件进程1',
  BASESHARES  DECIMAL(16,0)  COMMENT  '配股股本基数(股)'
)
COMMENT 'B股配股'
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
                                   , ADVANCEVALIDSTARTDATE
                                   , ADVANCEVALIDENDDATE
                                   , PLARATIOPLANNED
                                   , PRICINGMODEL
                                   , PRICINGDESCRIPTION
                                   , PRICEUNIT
                                   , PLAPRICECEILINGRMB
                                   , PLAPRICEFLOORRMB
                                   , PLAPRICECEILINGFC
                                   , PLAPRICEFLOORFC
                                   , AUTHORIZEDDECLAREDATE
                                   , PLAPROSPECTUSPUBLDATE
                                   , WARRANTABBRNAME
                                   , WARRANTCODE
                                   , ACTUALPLARATIO
                                   , PLAOBJECT
                                   , PARVALUERMB
                                   , PLAPRICERMB
                                   , PLAPRICEFC
                                   , PLANNEDPLAVOL
                                   , ODDLOTSTREATMENT
                                   , LASTTRADINGDAY
                                   , EXRIGHTDATE
                                   , RIGHTREGDATE
                                   , WARRANTTRADESTARTDATE
                                   , WARRANTTRADEENDDATE
                                   , PAYSTARTDATE
                                   , PAYENDDATE
                                   , PLALISTDATE
                                   , IPOPROCEEDSRMB
                                   , ISSUECOSTRMB
                                   , IPONETPROCEEDSRMB
                                   , IPOPROCEEDSFC
                                   , ISSUECOSTFC
                                   , IPONETPROCEEDSFC
                                   , SCHEMECHANGE
                                   , CHANGESTATEMENT
                                   , UNDERWRITINGMODE
                                   , ACTUALPLAVOL
                                   , UNDERWRITERBOUGHTVOL
                                   , XGRQ
                                   , JSID
                                   , EVENTPROCEDURECODE
                                   , BASESHARES
                                FROM ${jy_src_schema}.LC_BSHAREPLACEMENT"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "PLAYEAR", "type": "STRING"}, {"name": "STOCKTYPE", "type": "DOUBLE"}, {"name": "ADVANCEDATE", "type": "STRING"}, {"name": "SMDECIPUBLDATE", "type": "STRING"}, {"name": "ADVANCEVALIDSTARTDATE", "type": "STRING"}, {"name": "ADVANCEVALIDENDDATE", "type": "STRING"}, {"name": "PLARATIOPLANNED", "type": "DOUBLE"}, {"name": "PRICINGMODEL", "type": "DOUBLE"}, {"name": "PRICINGDESCRIPTION", "type": "STRING"}, {"name": "PRICEUNIT", "type": "STRING"}, {"name": "PLAPRICECEILINGRMB", "type": "DOUBLE"}, {"name": "PLAPRICEFLOORRMB", "type": "DOUBLE"}, {"name": "PLAPRICECEILINGFC", "type": "DOUBLE"}, {"name": "PLAPRICEFLOORFC", "type": "DOUBLE"}, {"name": "AUTHORIZEDDECLAREDATE", "type": "STRING"}, {"name": "PLAPROSPECTUSPUBLDATE", "type": "STRING"}, {"name": "WARRANTABBRNAME", "type": "STRING"}, {"name": "WARRANTCODE", "type": "STRING"}, {"name": "ACTUALPLARATIO", "type": "DOUBLE"}, {"name": "PLAOBJECT", "type": "STRING"}, {"name": "PARVALUERMB", "type": "DOUBLE"}, {"name": "PLAPRICERMB", "type": "DOUBLE"}, {"name": "PLAPRICEFC", "type": "DOUBLE"}, {"name": "PLANNEDPLAVOL", "type": "DOUBLE"}, {"name": "ODDLOTSTREATMENT", "type": "DOUBLE"}, {"name": "LASTTRADINGDAY", "type": "STRING"}, {"name": "EXRIGHTDATE", "type": "STRING"}, {"name": "RIGHTREGDATE", "type": "STRING"}, {"name": "WARRANTTRADESTARTDATE", "type": "STRING"}, {"name": "WARRANTTRADEENDDATE", "type": "STRING"}, {"name": "PAYSTARTDATE", "type": "STRING"}, {"name": "PAYENDDATE", "type": "STRING"}, {"name": "PLALISTDATE", "type": "STRING"}, {"name": "IPOPROCEEDSRMB", "type": "DOUBLE"}, {"name": "ISSUECOSTRMB", "type": "DOUBLE"}, {"name": "IPONETPROCEEDSRMB", "type": "DOUBLE"}, {"name": "IPOPROCEEDSFC", "type": "DOUBLE"}, {"name": "ISSUECOSTFC", "type": "DOUBLE"}, {"name": "IPONETPROCEEDSFC", "type": "DOUBLE"}, {"name": "SCHEMECHANGE", "type": "DOUBLE"}, {"name": "CHANGESTATEMENT", "type": "STRING"}, {"name": "UNDERWRITINGMODE", "type": "DOUBLE"}, {"name": "ACTUALPLAVOL", "type": "DOUBLE"}, {"name": "UNDERWRITERBOUGHTVOL", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "EVENTPROCEDURECODE", "type": "DOUBLE"}, {"name": "BASESHARES", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_bshareplacement_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_bshareplacement_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_bshareplacement_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_bshareplacement_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_BSHAREPLACEMENT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_BSHAREPLACEMENT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_bshareplacement_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_BSHAREPLACEMENT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INITIALINFOPUBLDATE
     , PLAYEAR
     , STOCKTYPE
     , ADVANCEDATE
     , SMDECIPUBLDATE
     , ADVANCEVALIDSTARTDATE
     , ADVANCEVALIDENDDATE
     , PLARATIOPLANNED
     , PRICINGMODEL
     , PRICINGDESCRIPTION
     , PRICEUNIT
     , PLAPRICECEILINGRMB
     , PLAPRICEFLOORRMB
     , PLAPRICECEILINGFC
     , PLAPRICEFLOORFC
     , AUTHORIZEDDECLAREDATE
     , PLAPROSPECTUSPUBLDATE
     , WARRANTABBRNAME
     , WARRANTCODE
     , ACTUALPLARATIO
     , PLAOBJECT
     , PARVALUERMB
     , PLAPRICERMB
     , PLAPRICEFC
     , PLANNEDPLAVOL
     , ODDLOTSTREATMENT
     , LASTTRADINGDAY
     , EXRIGHTDATE
     , RIGHTREGDATE
     , WARRANTTRADESTARTDATE
     , WARRANTTRADEENDDATE
     , PAYSTARTDATE
     , PAYENDDATE
     , PLALISTDATE
     , IPOPROCEEDSRMB
     , ISSUECOSTRMB
     , IPONETPROCEEDSRMB
     , IPOPROCEEDSFC
     , ISSUECOSTFC
     , IPONETPROCEEDSFC
     , SCHEMECHANGE
     , CHANGESTATEMENT
     , UNDERWRITINGMODE
     , ACTUALPLAVOL
     , UNDERWRITERBOUGHTVOL
     , XGRQ
     , JSID
     , EVENTPROCEDURECODE
     , BASESHARES
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_BSHAREPLACEMENT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_BSHAREPLACEMENT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_BSHAREPLACEMENT_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_BSHAREPLACEMENT_PFD成功"
      exit 0
   fi
fi
