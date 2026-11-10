#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  ISSUER  STRING  COMMENT  '发行人',
  BONDNATURE  DECIMAL(10,0)  COMMENT  '债券性质',
  PROSPECTUSISSUEDATE  STRING  COMMENT  '扩募说明书发布日期',
  ISSUEMETHOD  STRING  COMMENT  '发行方式',
  ISSUEOBJECT  STRING  COMMENT  '发行对象',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  ISSUEPRICE  DECIMAL(19,4)  COMMENT  '实际发行价(元)',
  ISSUESTARTDATE  STRING  COMMENT  '发行日期上限',
  ISSUEENDDATE  STRING  COMMENT  '发行日期下限',
  PROJECTCHANGINGDES  STRING  COMMENT  '方案变动说明',
  PROJECTCHANGINGTYPE  STRING  COMMENT  '方案变动类型',
  GUARANTOR  STRING  COMMENT  '担保方',
  LEADUNDERWRITER  STRING  COMMENT  '主承销商',
  CRAS  STRING  COMMENT  '评级机构',
  CREDITRATING  STRING  COMMENT  '债券信用级别(字母)',
  UNDERWRITINGMETHOD  DECIMAL(10,0)  COMMENT  '承销方式',
  UNDERWRITINGSTARTDATE  STRING  COMMENT  '*承销期上限',
  UNDERWRITINGENDDATE  STRING  COMMENT  '*承销期下限',
  PREFALTCODEH  STRING  COMMENT  '老股东优先配售代码',
  PREFALTNAMEH  STRING  COMMENT  '老股东优先配售名称',
  PREFALTREGDATEH  STRING  COMMENT  '老股东优先配售股权登记日',
  PREFALTPAYSTARTDATEH  STRING  COMMENT  '老股东优先配售缴款起始日',
  PREFALTPAYENDDATEH  STRING  COMMENT  '老股东优先配售缴款截止日',
  PREFALTPROPORTIONH  DECIMAL(9,4)  COMMENT  '老股东优先配售比例(每100股配X张)',
  PREFALTUNITH  DECIMAL(10,0)  COMMENT  '老股东优先配售单位(张)',
  PREFALTSIZEH  DECIMAL(19,4)  COMMENT  '老股东优先配售总额(元)',
  PREFALTVALIDAPPLYVOLH  DECIMAL(19,0)  COMMENT  '老股东优先配售有效申购张数(张)',
  PREFALTVALIDAPPLYNUMH  DECIMAL(10,0)  COMMENT  '老股东优先有效申购户数(户)',
  PREFALTOVERSUBSTIMEH  DECIMAL(12,4)  COMMENT  '老股东优先超额认购倍数(倍)',
  PREFALTRATIOH  DECIMAL(18,15)  COMMENT  '老股东优先配售中签率',
  ALTSIZEF  DECIMAL(19,4)  COMMENT  '基金配售总额(元)',
  ALTPAYSTARTDATEF  STRING  COMMENT  '基金配售缴款起始日',
  ALTPAYENDDATEF  STRING  COMMENT  '基金配售缴款截止日',
  ALTSIZEI  DECIMAL(19,4)  COMMENT  '法人配售总额(元)',
  ALTPAYSTARTDATEI  STRING  COMMENT  '法人配售缴款起始日',
  ALTPAYENDDATEI  STRING  COMMENT  '法人配售缴款截止日',
  OFFLINEPUBOFFVALIDAPPLYVOLI  DECIMAL(19,0)  COMMENT  '网下机构配售有效申购张数(张)',
  OFFLINEPUBOFFVALIDAPPLYNUMI  DECIMAL(10,0)  COMMENT  '网下机构配售有效申购户数(户)',
  OFFLINEPUBOFFOVERSUBSTIMEI  DECIMAL(12,4)  COMMENT  '网下机构配售超额认购倍数(倍)',
  OFFLINEPUBOFFRATIOI  DECIMAL(18,15)  COMMENT  '网下机构配售中签率',
  ONLINEPUBOFFCODE  STRING  COMMENT  '上网申购代码',
  ONLINEPUBOFFNAME  STRING  COMMENT  '上网申购名称',
  ONLINEPUBOFFDATE  STRING  COMMENT  '上网发行日期',
  ONLINEPUBOFFSIZE  DECIMAL(19,4)  COMMENT  '上网发行总额(元)',
  ONLINEPUBOFFUNIT  DECIMAL(10,0)  COMMENT  '上网申购单位(张)',
  ONLINEPUBOFFAPPLYCAP  DECIMAL(10,0)  COMMENT  '上网申购上限(张)',
  ONLINEPUBOFFVALIDAPPLYVOL  DECIMAL(19,0)  COMMENT  '上网发行有效申购张数(张)',
  ONLINEPUBOFFVALIDAPPLYNUM  DECIMAL(10,0)  COMMENT  '上网发行有效申购户数(户)',
  ONLINEPUBOFFOVERSUBSTIME  DECIMAL(12,4)  COMMENT  '上网发行超额认购倍数(倍)',
  ONLINEPUBOFFRATIO  DECIMAL(18,15)  COMMENT  '上网发行中签率',
  ACTUALISSUESIZE  DECIMAL(19,4)  COMMENT  '实际发行规模(元)',
  ISSUEVOL  DECIMAL(16,0)  COMMENT  '发行量(股)',
  PROCEEDS  DECIMAL(19,4)  COMMENT  '募集资金总额(元)',
  ISSUECOST  DECIMAL(19,4)  COMMENT  '发行费用总额(元)',
  NETPROCEEDS  DECIMAL(19,4)  COMMENT  '募集资金净额(外币元)',
  UNDERWRITERBOUGHTVOLUME  DECIMAL(16,0)  COMMENT  '余额包销数量(张)',
  LISTANNOUNCEMENTDATE  STRING  COMMENT  '上市公告日(上市公告书发布日期)',
  EXCHANGEDAY  STRING  COMMENT  '上市日期',
  PROFITFORECASTYEAR  STRING  COMMENT  '盈利预测年度',
  REVENUEFORECAST  DECIMAL(19,4)  COMMENT  '主营业务收入预测(元)',
  NETPROFITFORECAST  DECIMAL(19,4)  COMMENT  '净利润预测(元)',
  DILUTEEPSFORECAST  DECIMAL(19,4)  COMMENT  '全面摊薄每股盈利预测',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  ONLINEPUBOFFAPPLYMIN  DECIMAL(10,0)  COMMENT  '上网申购下限(张)',
  OFFLINEAPPLYUNIT  DECIMAL(10,0)  COMMENT  '网下申购单位(张)',
  OFFLINEAPPLYMAX  DECIMAL(10,0)  COMMENT  '网下申购上限(张)',
  OFFLINEAPPLYMIN  DECIMAL(10,0)  COMMENT  '网下申购下限(张)',
  DEPOSITRATIO  DECIMAL(9,6)  COMMENT  '缴纳定金比例(%)',
  DEPOSITNUM  DECIMAL(19,4)  COMMENT  '定金数量(元)',
  DEPOSITENDDATE  STRING  COMMENT  '缴纳申购定金截止日',
  PLANISSUESIZE  DECIMAL(19,2)  COMMENT  '计划发行规模(元)',
  PREFALTPAYREFUNDDATEH  STRING  COMMENT  '老股东优先配售申购资金退款日(有限售)',
  OFFLINEPAYEDTIMEI  STRING  COMMENT  '网下配售缴款截止时间',
  OFFLINEPAYREFUNDDATEI  STRING  COMMENT  '网下配售申购资金退款日',
  OFFLINEADDALTSTDATEI  STRING  COMMENT  '网下追加配售起始日',
  OFFLINEADDALTEDDATEI  STRING  COMMENT  '网下追加配售截止日',
  OFFLINEADDALTPAEDDATEI  STRING  COMMENT  '网下追加配售缴款截止日',
  OFFLINEADDALTPAEDTIMEI  STRING  COMMENT  '网下追加配售缴款截止时间',
  OFFLINEADDALTREDATEI  STRING  COMMENT  '网下追加配售资金退款日',
  ONLINEPUBOFFPAYENDDATE  STRING  COMMENT  '网上发行缴款截止日',
  DEPOSITENDTIME  STRING  COMMENT  '缴纳申购定金截止时间',
  OFFLINEAPPLYMAENDDATE  STRING  COMMENT  '',
  OFFLINEAPPLYMAENDTIME  STRING  COMMENT  '',
  OFFLINEISSUEDATEI  STRING  COMMENT  '网下配售发行日期',
  OFFLINERFQDATEI  STRING  COMMENT  '网下配售询价(簿记建档)日期',
  OFFLINEPUBOFFVALIDPAYNUMI  DECIMAL(10,0)  COMMENT  '网下机构配售有效申购缴款户数(户)',
  ONLINEPUBOFFRATIODATE  STRING  COMMENT  '网上中签率公告日',
  ONLINEPUBOFFRESULTDATE  STRING  COMMENT  '网上中签结果公告日',
  ONLINEPUBOFFRATIOACT  DECIMAL(18,15)  COMMENT  '实际网上发行中签率(%)',
  ISSUERESULTPUBLDATE  STRING  COMMENT  '发行结果公告日',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '可转债发行信息'
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
                                   , ISSUER
                                   , BONDNATURE
                                   , PROSPECTUSISSUEDATE
                                   , ISSUEMETHOD
                                   , ISSUEOBJECT
                                   , PARVALUE
                                   , ISSUEPRICE
                                   , ISSUESTARTDATE
                                   , ISSUEENDDATE
                                   , PROJECTCHANGINGDES
                                   , PROJECTCHANGINGTYPE
                                   , GUARANTOR
                                   , LEADUNDERWRITER
                                   , CRAS
                                   , CREDITRATING
                                   , UNDERWRITINGMETHOD
                                   , UNDERWRITINGSTARTDATE
                                   , UNDERWRITINGENDDATE
                                   , PREFALTCODEH
                                   , PREFALTNAMEH
                                   , PREFALTREGDATEH
                                   , PREFALTPAYSTARTDATEH
                                   , PREFALTPAYENDDATEH
                                   , PREFALTPROPORTIONH
                                   , PREFALTUNITH
                                   , PREFALTSIZEH
                                   , PREFALTVALIDAPPLYVOLH
                                   , PREFALTVALIDAPPLYNUMH
                                   , PREFALTOVERSUBSTIMEH
                                   , PREFALTRATIOH
                                   , ALTSIZEF
                                   , ALTPAYSTARTDATEF
                                   , ALTPAYENDDATEF
                                   , ALTSIZEI
                                   , ALTPAYSTARTDATEI
                                   , ALTPAYENDDATEI
                                   , OFFLINEPUBOFFVALIDAPPLYVOLI
                                   , OFFLINEPUBOFFVALIDAPPLYNUMI
                                   , OFFLINEPUBOFFOVERSUBSTIMEI
                                   , OFFLINEPUBOFFRATIOI
                                   , ONLINEPUBOFFCODE
                                   , ONLINEPUBOFFNAME
                                   , ONLINEPUBOFFDATE
                                   , ONLINEPUBOFFSIZE
                                   , ONLINEPUBOFFUNIT
                                   , ONLINEPUBOFFAPPLYCAP
                                   , ONLINEPUBOFFVALIDAPPLYVOL
                                   , ONLINEPUBOFFVALIDAPPLYNUM
                                   , ONLINEPUBOFFOVERSUBSTIME
                                   , ONLINEPUBOFFRATIO
                                   , ACTUALISSUESIZE
                                   , ISSUEVOL
                                   , PROCEEDS
                                   , ISSUECOST
                                   , NETPROCEEDS
                                   , UNDERWRITERBOUGHTVOLUME
                                   , LISTANNOUNCEMENTDATE
                                   , EXCHANGEDAY
                                   , PROFITFORECASTYEAR
                                   , REVENUEFORECAST
                                   , NETPROFITFORECAST
                                   , DILUTEEPSFORECAST
                                   , UPDATETIME
                                   , JSID
                                   , ONLINEPUBOFFAPPLYMIN
                                   , OFFLINEAPPLYUNIT
                                   , OFFLINEAPPLYMAX
                                   , OFFLINEAPPLYMIN
                                   , DEPOSITRATIO
                                   , DEPOSITNUM
                                   , DEPOSITENDDATE
                                   , PLANISSUESIZE
                                   , PREFALTPAYREFUNDDATEH
                                   , OFFLINEPAYEDTIMEI
                                   , OFFLINEPAYREFUNDDATEI
                                   , OFFLINEADDALTSTDATEI
                                   , OFFLINEADDALTEDDATEI
                                   , OFFLINEADDALTPAEDDATEI
                                   , OFFLINEADDALTPAEDTIMEI
                                   , OFFLINEADDALTREDATEI
                                   , ONLINEPUBOFFPAYENDDATE
                                   , DEPOSITENDTIME
                                   , OFFLINEAPPLYMAENDDATE
                                   , OFFLINEAPPLYMAENDTIME
                                   , OFFLINEISSUEDATEI
                                   , OFFLINERFQDATEI
                                   , OFFLINEPUBOFFVALIDPAYNUMI
                                   , ONLINEPUBOFFRATIODATE
                                   , ONLINEPUBOFFRESULTDATE
                                   , ONLINEPUBOFFRATIOACT
                                   , ISSUERESULTPUBLDATE
                                   , INSERTTIME
                                FROM ${jy_src_schema}.BOND_CONBDISSUE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "ISSUER", "type": "STRING"}, {"name": "BONDNATURE", "type": "DOUBLE"}, {"name": "PROSPECTUSISSUEDATE", "type": "STRING"}, {"name": "ISSUEMETHOD", "type": "STRING"}, {"name": "ISSUEOBJECT", "type": "STRING"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "ISSUEPRICE", "type": "DOUBLE"}, {"name": "ISSUESTARTDATE", "type": "STRING"}, {"name": "ISSUEENDDATE", "type": "STRING"}, {"name": "PROJECTCHANGINGDES", "type": "STRING"}, {"name": "PROJECTCHANGINGTYPE", "type": "DOUBLE"}, {"name": "GUARANTOR", "type": "STRING"}, {"name": "LEADUNDERWRITER", "type": "STRING"}, {"name": "CRAS", "type": "STRING"}, {"name": "CREDITRATING", "type": "STRING"}, {"name": "UNDERWRITINGMETHOD", "type": "DOUBLE"}, {"name": "UNDERWRITINGSTARTDATE", "type": "STRING"}, {"name": "UNDERWRITINGENDDATE", "type": "STRING"}, {"name": "PREFALTCODEH", "type": "STRING"}, {"name": "PREFALTNAMEH", "type": "STRING"}, {"name": "PREFALTREGDATEH", "type": "STRING"}, {"name": "PREFALTPAYSTARTDATEH", "type": "STRING"}, {"name": "PREFALTPAYENDDATEH", "type": "STRING"}, {"name": "PREFALTPROPORTIONH", "type": "DOUBLE"}, {"name": "PREFALTUNITH", "type": "DOUBLE"}, {"name": "PREFALTSIZEH", "type": "DOUBLE"}, {"name": "PREFALTVALIDAPPLYVOLH", "type": "DOUBLE"}, {"name": "PREFALTVALIDAPPLYNUMH", "type": "DOUBLE"}, {"name": "PREFALTOVERSUBSTIMEH", "type": "DOUBLE"}, {"name": "PREFALTRATIOH", "type": "DOUBLE"}, {"name": "ALTSIZEF", "type": "DOUBLE"}, {"name": "ALTPAYSTARTDATEF", "type": "STRING"}, {"name": "ALTPAYENDDATEF", "type": "STRING"}, {"name": "ALTSIZEI", "type": "DOUBLE"}, {"name": "ALTPAYSTARTDATEI", "type": "STRING"}, {"name": "ALTPAYENDDATEI", "type": "STRING"}, {"name": "OFFLINEPUBOFFVALIDAPPLYVOLI", "type": "DOUBLE"}, {"name": "OFFLINEPUBOFFVALIDAPPLYNUMI", "type": "DOUBLE"}, {"name": "OFFLINEPUBOFFOVERSUBSTIMEI", "type": "DOUBLE"}, {"name": "OFFLINEPUBOFFRATIOI", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFCODE", "type": "STRING"}, {"name": "ONLINEPUBOFFNAME", "type": "STRING"}, {"name": "ONLINEPUBOFFDATE", "type": "STRING"}, {"name": "ONLINEPUBOFFSIZE", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFUNIT", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFAPPLYCAP", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFVALIDAPPLYVOL", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFVALIDAPPLYNUM", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFOVERSUBSTIME", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFRATIO", "type": "DOUBLE"}, {"name": "ACTUALISSUESIZE", "type": "DOUBLE"}, {"name": "ISSUEVOL", "type": "DOUBLE"}, {"name": "PROCEEDS", "type": "DOUBLE"}, {"name": "ISSUECOST", "type": "DOUBLE"}, {"name": "NETPROCEEDS", "type": "DOUBLE"}, {"name": "UNDERWRITERBOUGHTVOLUME", "type": "DOUBLE"}, {"name": "LISTANNOUNCEMENTDATE", "type": "STRING"}, {"name": "EXCHANGEDAY", "type": "STRING"}, {"name": "PROFITFORECASTYEAR", "type": "STRING"}, {"name": "REVENUEFORECAST", "type": "DOUBLE"}, {"name": "NETPROFITFORECAST", "type": "DOUBLE"}, {"name": "DILUTEEPSFORECAST", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFAPPLYMIN", "type": "DOUBLE"}, {"name": "OFFLINEAPPLYUNIT", "type": "DOUBLE"}, {"name": "OFFLINEAPPLYMAX", "type": "DOUBLE"}, {"name": "OFFLINEAPPLYMIN", "type": "DOUBLE"}, {"name": "DEPOSITRATIO", "type": "DOUBLE"}, {"name": "DEPOSITNUM", "type": "DOUBLE"}, {"name": "DEPOSITENDDATE", "type": "STRING"}, {"name": "PLANISSUESIZE", "type": "DOUBLE"}, {"name": "PREFALTPAYREFUNDDATEH", "type": "STRING"}, {"name": "OFFLINEPAYEDTIMEI", "type": "STRING"}, {"name": "OFFLINEPAYREFUNDDATEI", "type": "STRING"}, {"name": "OFFLINEADDALTSTDATEI", "type": "STRING"}, {"name": "OFFLINEADDALTEDDATEI", "type": "STRING"}, {"name": "OFFLINEADDALTPAEDDATEI", "type": "STRING"}, {"name": "OFFLINEADDALTPAEDTIMEI", "type": "STRING"}, {"name": "OFFLINEADDALTREDATEI", "type": "STRING"}, {"name": "ONLINEPUBOFFPAYENDDATE", "type": "STRING"}, {"name": "DEPOSITENDTIME", "type": "STRING"}, {"name": "OFFLINEAPPLYMAENDDATE", "type": "STRING"}, {"name": "OFFLINEAPPLYMAENDTIME", "type": "STRING"}, {"name": "OFFLINEISSUEDATEI", "type": "STRING"}, {"name": "OFFLINERFQDATEI", "type": "STRING"}, {"name": "OFFLINEPUBOFFVALIDPAYNUMI", "type": "DOUBLE"}, {"name": "ONLINEPUBOFFRATIODATE", "type": "STRING"}, {"name": "ONLINEPUBOFFRESULTDATE", "type": "STRING"}, {"name": "ONLINEPUBOFFRATIOACT", "type": "DOUBLE"}, {"name": "ISSUERESULTPUBLDATE", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_conbdissue_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_conbdissue_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_conbdissue_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_conbdissue_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CONBDISSUE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CONBDISSUE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_conbdissue_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , ISSUER
     , BONDNATURE
     , PROSPECTUSISSUEDATE
     , ISSUEMETHOD
     , ISSUEOBJECT
     , PARVALUE
     , ISSUEPRICE
     , ISSUESTARTDATE
     , ISSUEENDDATE
     , PROJECTCHANGINGDES
     , PROJECTCHANGINGTYPE
     , GUARANTOR
     , LEADUNDERWRITER
     , CRAS
     , CREDITRATING
     , UNDERWRITINGMETHOD
     , UNDERWRITINGSTARTDATE
     , UNDERWRITINGENDDATE
     , PREFALTCODEH
     , PREFALTNAMEH
     , PREFALTREGDATEH
     , PREFALTPAYSTARTDATEH
     , PREFALTPAYENDDATEH
     , PREFALTPROPORTIONH
     , PREFALTUNITH
     , PREFALTSIZEH
     , PREFALTVALIDAPPLYVOLH
     , PREFALTVALIDAPPLYNUMH
     , PREFALTOVERSUBSTIMEH
     , PREFALTRATIOH
     , ALTSIZEF
     , ALTPAYSTARTDATEF
     , ALTPAYENDDATEF
     , ALTSIZEI
     , ALTPAYSTARTDATEI
     , ALTPAYENDDATEI
     , OFFLINEPUBOFFVALIDAPPLYVOLI
     , OFFLINEPUBOFFVALIDAPPLYNUMI
     , OFFLINEPUBOFFOVERSUBSTIMEI
     , OFFLINEPUBOFFRATIOI
     , ONLINEPUBOFFCODE
     , ONLINEPUBOFFNAME
     , ONLINEPUBOFFDATE
     , ONLINEPUBOFFSIZE
     , ONLINEPUBOFFUNIT
     , ONLINEPUBOFFAPPLYCAP
     , ONLINEPUBOFFVALIDAPPLYVOL
     , ONLINEPUBOFFVALIDAPPLYNUM
     , ONLINEPUBOFFOVERSUBSTIME
     , ONLINEPUBOFFRATIO
     , ACTUALISSUESIZE
     , ISSUEVOL
     , PROCEEDS
     , ISSUECOST
     , NETPROCEEDS
     , UNDERWRITERBOUGHTVOLUME
     , LISTANNOUNCEMENTDATE
     , EXCHANGEDAY
     , PROFITFORECASTYEAR
     , REVENUEFORECAST
     , NETPROFITFORECAST
     , DILUTEEPSFORECAST
     , UPDATETIME
     , JSID
     , ONLINEPUBOFFAPPLYMIN
     , OFFLINEAPPLYUNIT
     , OFFLINEAPPLYMAX
     , OFFLINEAPPLYMIN
     , DEPOSITRATIO
     , DEPOSITNUM
     , DEPOSITENDDATE
     , PLANISSUESIZE
     , PREFALTPAYREFUNDDATEH
     , OFFLINEPAYEDTIMEI
     , OFFLINEPAYREFUNDDATEI
     , OFFLINEADDALTSTDATEI
     , OFFLINEADDALTEDDATEI
     , OFFLINEADDALTPAEDDATEI
     , OFFLINEADDALTPAEDTIMEI
     , OFFLINEADDALTREDATEI
     , ONLINEPUBOFFPAYENDDATE
     , DEPOSITENDTIME
     , OFFLINEAPPLYMAENDDATE
     , OFFLINEAPPLYMAENDTIME
     , OFFLINEISSUEDATEI
     , OFFLINERFQDATEI
     , OFFLINEPUBOFFVALIDPAYNUMI
     , ONLINEPUBOFFRATIODATE
     , ONLINEPUBOFFRESULTDATE
     , ONLINEPUBOFFRATIOACT
     , ISSUERESULTPUBLDATE
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CONBDISSUE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CONBDISSUE_PFD成功"
      exit 0
   fi
fi
