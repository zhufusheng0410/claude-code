#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_CCBONDISSUANCE_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_CCBONDISSUANCE_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  CRNCY_CODE  STRING  COMMENT  '货币代码',
  ANN_DT  STRING  COMMENT  '公告日期',
  CB_INFO_PREPLANDATE  STRING  COMMENT  '预案公告日',
  CB_INFO_SMTGANNCEDATE  STRING  COMMENT  '股东大会公告日',
  CB_ISSUE_ANNCELSTDATE  STRING  COMMENT  '上市公告日',
  CB_INFO_LISTEDDATE  STRING  COMMENT  '上市日期',
  CB_INFO_LISTDATE  STRING  COMMENT  '方案进度',
  CB_INFO_ISSEPARATION  DECIMAL(18,2)  COMMENT  '是否分离交易可转债',
  CB_INFO_DISTRIBUTO  STRING  COMMENT  '分销商ID',
  CB_INFO_RECOMMENDER  STRING  COMMENT  '上市推荐人',
  CB_CLAUSE_ISCHAINTEREST  DECIMAL(18,2)  COMMENT  '利率是否随存款利率调整',
  CB_CLAUSE_ISCOMINTEREST  DECIMAL(18,2)  COMMENT  '是否有利息补偿条款',
  CB_CLAUSE_COMINTEREST  DECIMAL(18,2)  COMMENT  '补偿利率(%)',
  CB_CLAUSE_COMINTERESTITEM  STRING  COMMENT  '利率补偿说明',
  CB_CLAUSE_CONVERSIONITEM  STRING  COMMENT  '初始转股价条款',
  CB_CLAUSE_CONVCHANGEITEM  STRING  COMMENT  '转股价格调整条款',
  CB_CLAUSE_CONVMONTH  STRING  COMMENT  '转换期条款',
  CB_CLAUSE_INICONVPRICE  DECIMAL(18,2)  COMMENT  '初始转股价格',
  CB_CLAUSE_INICONVPROPORTION  DECIMAL(18,2)  COMMENT  '初始转股价溢价比例(%)',
  CB_CLAUSE_CALLITEM  STRING  COMMENT  '回售条款',
  CB_CLAUSE_RESET_ITEM  STRING  COMMENT  '赎回条款',
  CB_CLAUSE_RESETITEM  STRING  COMMENT  '特别向下修正条款',
  CB_CLAUSE_RATIONITEM  STRING  COMMENT  '向原股东配售安排条款',
  CB_LIST_PASSDATE  STRING  COMMENT  '发审委通过公告日',
  CB_LIST_PERMITDATE  STRING  COMMENT  '证监会核准公告日',
  CB_LIST_ANNOUNCEDATE  STRING  COMMENT  '发行公告日',
  CB_LIST_ANNOCEDATE  STRING  COMMENT  '发行结果公告日',
  CB_LIST_TYPE  STRING  COMMENT  '发行方式',
  CB_LIST_FEE  DECIMAL(18,2)  COMMENT  '发行费用',
  CB_LIST_RATIONDATE  STRING  COMMENT  '老股东配售日期',
  CB_LIST_RATIONCHKINDATE  STRING  COMMENT  '老股东配售股权登记日',
  CB_LIST_RATIONPAYMTDATE  STRING  COMMENT  '老股东配售缴款日',
  CB_LIST_RATIONCODE  STRING  COMMENT  '老股东配售代码',
  CB_LIST_RATIONNAME  STRING  COMMENT  '老股东配售简称',
  CB_LIST_RATIONPRICE  DECIMAL(18,2)  COMMENT  '老股东配售价格',
  CB_LIST_RATIONRATIODE  DECIMAL(18,2)  COMMENT  '老股东配售比例分母',
  CB_LIST_RATIONRATIOMO  DECIMAL(18,2)  COMMENT  '老股东配售比例分子',
  CB_LIST_RATIONVOL  DECIMAL(18,2)  COMMENT  '向老股东配售数量(张)',
  CB_LIST_ORIGINALS  DECIMAL(18,2)  COMMENT  '老股东配售户数',
  CB_LIST_DTONL  STRING  COMMENT  '上网发行日期',
  CB_LIST_PCHASECODEONL  STRING  COMMENT  '上网发行申购代码',
  CB_LIST_PCHNAMEONL  STRING  COMMENT  '上网发行申购名称',
  CB_LIST_PCHPRICEONL  DECIMAL(18,2)  COMMENT  '上网发行申购价格',
  CB_LIST_ISSUEVOLONL  DECIMAL(18,2)  COMMENT  '上网发行数量(不含优先配售)(张)',
  CB_LIST_CODEONL  DECIMAL(18,2)  COMMENT  '上网发行配号总数',
  CB_LIST_EXCESSPCHONL  DECIMAL(18,2)  COMMENT  '上网发行超额认购倍数(不含优先配售)',
  CB_RESULT_EFSUBSCRPOFF  DECIMAL(18,2)  COMMENT  '网上有效申购户数(不含优先配售)',
  CB_RESULT_SUCRATEOFF  DECIMAL(18,2)  COMMENT  '网上有效申购手数(不含优先配售)',
  CB_LIST_DATEINSTOFF  STRING  COMMENT  '网下向机构投资者发行日期',
  CB_LIST_VOLINSTOFF  DECIMAL(18,2)  COMMENT  '网下向机构投资者发行数量(不含优先配售)(张)',
  CB_RESULT_SUCRATEON  DECIMAL(18,2)  COMMENT  '网上中签率(不含优先配售)(%)',
  CB_LIST_EFFECTPCHVOLOFF  DECIMAL(18,2)  COMMENT  '网下有效申购手数(不含优先配售)',
  CB_LIST_EFFPCHOF  DECIMAL(18,2)  COMMENT  '网下有效申购户数(不含优先配售)',
  CB_LIST_SUCRATEOFF  DECIMAL(18,2)  COMMENT  '网下中签率(不含优先配售)(%)',
  CB_LIST_PRERATIONVOL  DECIMAL(18,2)  COMMENT  '网下优先配售数量（张）',
  S_INFO_COMPCODE  STRING  COMMENT  '转股公司ID',
  CB_LIST_ISSUESIZE  DECIMAL(18,2)  COMMENT  '发行规模(万元)',
  CB_LIST_ISSUEQUANTITY  DECIMAL(18,2)  COMMENT  '发行数量(万张)',
  SEC_ID  STRING  COMMENT  '证券ID',
  MINUNLINE_NO  DECIMAL(18,2)  COMMENT  '网下最小申购数量(机构)',
  DEPUNLINE_RATIO  STRING  COMMENT  '网下定金比例(机构)',
  MAXUNLINE_NO  DECIMAL(18,2)  COMMENT  '网下最大申购数量(机构)',
  UNLINE_UD  STRING  COMMENT  '网下申购累进单位说明',
  IS_CONVERTIBLE_BONDS  DECIMAL(18,2)  COMMENT  '是否可转债',
  MINUNLINE_PUBLIC  DECIMAL(18,2)  COMMENT  '网上最小申购数量(公众)(元)',
  MAXUNLINE_PUBLIC  DECIMAL(18,2)  COMMENT  '网上最大申购数量(公众)(万元)',
  B_INFO_TERM_YEAR_  DECIMAL(18,2)  COMMENT  '债券期限(年)',
  B_INFO_INTERESTTYPE  STRING  COMMENT  '利率类型',
  B_INFO_COUPONRATE  DECIMAL(18,2)  COMMENT  '利率(%)',
  B_INFO_INTERESTFREQUENCY  STRING  COMMENT  '付息频率',
  CB_RESULT_SUCRATEON2  DECIMAL(18,2)  COMMENT  '[内部]网上中签率(不含优先配售)(%)',
  B_INFO_COUPONTXT  STRING  COMMENT  '利率说明',
  S_RATIOANNCEDATE  STRING  COMMENT  '网上中签率公告日',
  S_RATIODATE  STRING  COMMENT  '网上中签结果公告日',
  FIRSTPRELANDATE  STRING  COMMENT  '首次预案公告日',
  LEADUNDERWRITER  STRING  COMMENT  '主承销商',
  COUNTERGUAR_INTRODUCTION  STRING  COMMENT  '反担保情况',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国可转债发行'
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
                                   , CRNCY_CODE
                                   , ANN_DT
                                   , CB_INFO_PREPLANDATE
                                   , CB_INFO_SMTGANNCEDATE
                                   , CB_ISSUE_ANNCELSTDATE
                                   , CB_INFO_LISTEDDATE
                                   , CB_INFO_LISTDATE
                                   , CB_INFO_ISSEPARATION
                                   , CB_INFO_DISTRIBUTO
                                   , CB_INFO_RECOMMENDER
                                   , CB_CLAUSE_ISCHAINTEREST
                                   , CB_CLAUSE_ISCOMINTEREST
                                   , CB_CLAUSE_COMINTEREST
                                   , CB_CLAUSE_COMINTERESTITEM
                                   , CB_CLAUSE_CONVERSIONITEM
                                   , CB_CLAUSE_CONVCHANGEITEM
                                   , CB_CLAUSE_CONVMONTH
                                   , CB_CLAUSE_INICONVPRICE
                                   , CB_CLAUSE_INICONVPROPORTION
                                   , CB_CLAUSE_CALLITEM
                                   , CB_CLAUSE_RESET_ITEM
                                   , CB_CLAUSE_RESETITEM
                                   , CB_CLAUSE_RATIONITEM
                                   , CB_LIST_PASSDATE
                                   , CB_LIST_PERMITDATE
                                   , CB_LIST_ANNOUNCEDATE
                                   , CB_LIST_ANNOCEDATE
                                   , CB_LIST_TYPE
                                   , CB_LIST_FEE
                                   , CB_LIST_RATIONDATE
                                   , CB_LIST_RATIONCHKINDATE
                                   , CB_LIST_RATIONPAYMTDATE
                                   , CB_LIST_RATIONCODE
                                   , CB_LIST_RATIONNAME
                                   , CB_LIST_RATIONPRICE
                                   , CB_LIST_RATIONRATIODE
                                   , CB_LIST_RATIONRATIOMO
                                   , CB_LIST_RATIONVOL
                                   , CB_LIST_ORIGINALS
                                   , CB_LIST_DTONL
                                   , CB_LIST_PCHASECODEONL
                                   , CB_LIST_PCHNAMEONL
                                   , CB_LIST_PCHPRICEONL
                                   , CB_LIST_ISSUEVOLONL
                                   , CB_LIST_CODEONL
                                   , CB_LIST_EXCESSPCHONL
                                   , CB_RESULT_EFSUBSCRPOFF
                                   , CB_RESULT_SUCRATEOFF
                                   , CB_LIST_DATEINSTOFF
                                   , CB_LIST_VOLINSTOFF
                                   , CB_RESULT_SUCRATEON
                                   , CB_LIST_EFFECTPCHVOLOFF
                                   , CB_LIST_EFFPCHOF
                                   , CB_LIST_SUCRATEOFF
                                   , CB_LIST_PRERATIONVOL
                                   , S_INFO_COMPCODE
                                   , CB_LIST_ISSUESIZE
                                   , CB_LIST_ISSUEQUANTITY
                                   , SEC_ID
                                   , MINUNLINE_NO
                                   , DEPUNLINE_RATIO
                                   , MAXUNLINE_NO
                                   , UNLINE_UD
                                   , IS_CONVERTIBLE_BONDS
                                   , MINUNLINE_PUBLIC
                                   , MAXUNLINE_PUBLIC
                                   , B_INFO_TERM_YEAR_
                                   , B_INFO_INTERESTTYPE
                                   , B_INFO_COUPONRATE
                                   , B_INFO_INTERESTFREQUENCY
                                   , CB_RESULT_SUCRATEON2
                                   , B_INFO_COUPONTXT
                                   , S_RATIOANNCEDATE
                                   , S_RATIODATE
                                   , FIRSTPRELANDATE
                                   , LEADUNDERWRITER
                                   , COUNTERGUAR_INTRODUCTION
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.CCBONDISSUANCE"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "ANN_DT", "type": "STRING"}, {"name": "CB_INFO_PREPLANDATE", "type": "STRING"}, {"name": "CB_INFO_SMTGANNCEDATE", "type": "STRING"}, {"name": "CB_ISSUE_ANNCELSTDATE", "type": "STRING"}, {"name": "CB_INFO_LISTEDDATE", "type": "STRING"}, {"name": "CB_INFO_LISTDATE", "type": "STRING"}, {"name": "CB_INFO_ISSEPARATION", "type": "DOUBLE"}, {"name": "CB_INFO_DISTRIBUTO", "type": "STRING"}, {"name": "CB_INFO_RECOMMENDER", "type": "STRING"}, {"name": "CB_CLAUSE_ISCHAINTEREST", "type": "DOUBLE"}, {"name": "CB_CLAUSE_ISCOMINTEREST", "type": "DOUBLE"}, {"name": "CB_CLAUSE_COMINTEREST", "type": "DOUBLE"}, {"name": "CB_CLAUSE_COMINTERESTITEM", "type": "STRING"}, {"name": "CB_CLAUSE_CONVERSIONITEM", "type": "STRING"}, {"name": "CB_CLAUSE_CONVCHANGEITEM", "type": "STRING"}, {"name": "CB_CLAUSE_CONVMONTH", "type": "STRING"}, {"name": "CB_CLAUSE_INICONVPRICE", "type": "DOUBLE"}, {"name": "CB_CLAUSE_INICONVPROPORTION", "type": "DOUBLE"}, {"name": "CB_CLAUSE_CALLITEM", "type": "STRING"}, {"name": "CB_CLAUSE_RESET_ITEM", "type": "STRING"}, {"name": "CB_CLAUSE_RESETITEM", "type": "STRING"}, {"name": "CB_CLAUSE_RATIONITEM", "type": "STRING"}, {"name": "CB_LIST_PASSDATE", "type": "STRING"}, {"name": "CB_LIST_PERMITDATE", "type": "STRING"}, {"name": "CB_LIST_ANNOUNCEDATE", "type": "STRING"}, {"name": "CB_LIST_ANNOCEDATE", "type": "STRING"}, {"name": "CB_LIST_TYPE", "type": "STRING"}, {"name": "CB_LIST_FEE", "type": "DOUBLE"}, {"name": "CB_LIST_RATIONDATE", "type": "STRING"}, {"name": "CB_LIST_RATIONCHKINDATE", "type": "STRING"}, {"name": "CB_LIST_RATIONPAYMTDATE", "type": "STRING"}, {"name": "CB_LIST_RATIONCODE", "type": "STRING"}, {"name": "CB_LIST_RATIONNAME", "type": "STRING"}, {"name": "CB_LIST_RATIONPRICE", "type": "DOUBLE"}, {"name": "CB_LIST_RATIONRATIODE", "type": "DOUBLE"}, {"name": "CB_LIST_RATIONRATIOMO", "type": "DOUBLE"}, {"name": "CB_LIST_RATIONVOL", "type": "DOUBLE"}, {"name": "CB_LIST_ORIGINALS", "type": "DOUBLE"}, {"name": "CB_LIST_DTONL", "type": "STRING"}, {"name": "CB_LIST_PCHASECODEONL", "type": "STRING"}, {"name": "CB_LIST_PCHNAMEONL", "type": "STRING"}, {"name": "CB_LIST_PCHPRICEONL", "type": "DOUBLE"}, {"name": "CB_LIST_ISSUEVOLONL", "type": "DOUBLE"}, {"name": "CB_LIST_CODEONL", "type": "DOUBLE"}, {"name": "CB_LIST_EXCESSPCHONL", "type": "DOUBLE"}, {"name": "CB_RESULT_EFSUBSCRPOFF", "type": "DOUBLE"}, {"name": "CB_RESULT_SUCRATEOFF", "type": "DOUBLE"}, {"name": "CB_LIST_DATEINSTOFF", "type": "STRING"}, {"name": "CB_LIST_VOLINSTOFF", "type": "DOUBLE"}, {"name": "CB_RESULT_SUCRATEON", "type": "DOUBLE"}, {"name": "CB_LIST_EFFECTPCHVOLOFF", "type": "DOUBLE"}, {"name": "CB_LIST_EFFPCHOF", "type": "DOUBLE"}, {"name": "CB_LIST_SUCRATEOFF", "type": "DOUBLE"}, {"name": "CB_LIST_PRERATIONVOL", "type": "DOUBLE"}, {"name": "S_INFO_COMPCODE", "type": "STRING"}, {"name": "CB_LIST_ISSUESIZE", "type": "DOUBLE"}, {"name": "CB_LIST_ISSUEQUANTITY", "type": "DOUBLE"}, {"name": "SEC_ID", "type": "STRING"}, {"name": "MINUNLINE_NO", "type": "DOUBLE"}, {"name": "DEPUNLINE_RATIO", "type": "STRING"}, {"name": "MAXUNLINE_NO", "type": "DOUBLE"}, {"name": "UNLINE_UD", "type": "STRING"}, {"name": "IS_CONVERTIBLE_BONDS", "type": "DOUBLE"}, {"name": "MINUNLINE_PUBLIC", "type": "DOUBLE"}, {"name": "MAXUNLINE_PUBLIC", "type": "DOUBLE"}, {"name": "B_INFO_TERM_YEAR_", "type": "DOUBLE"}, {"name": "B_INFO_INTERESTTYPE", "type": "STRING"}, {"name": "B_INFO_COUPONRATE", "type": "DOUBLE"}, {"name": "B_INFO_INTERESTFREQUENCY", "type": "STRING"}, {"name": "CB_RESULT_SUCRATEON2", "type": "DOUBLE"}, {"name": "B_INFO_COUPONTXT", "type": "STRING"}, {"name": "S_RATIOANNCEDATE", "type": "STRING"}, {"name": "S_RATIODATE", "type": "STRING"}, {"name": "FIRSTPRELANDATE", "type": "STRING"}, {"name": "LEADUNDERWRITER", "type": "STRING"}, {"name": "COUNTERGUAR_INTRODUCTION", "type": "STRING"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_ccbondissuance_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_ccbondissuance_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_ccbondissuance_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_ccbondissuance_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_CCBONDISSUANCE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_CCBONDISSUANCE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_ccbondissuance_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_CCBONDISSUANCE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , CRNCY_CODE
     , ANN_DT
     , CB_INFO_PREPLANDATE
     , CB_INFO_SMTGANNCEDATE
     , CB_ISSUE_ANNCELSTDATE
     , CB_INFO_LISTEDDATE
     , CB_INFO_LISTDATE
     , CB_INFO_ISSEPARATION
     , CB_INFO_DISTRIBUTO
     , CB_INFO_RECOMMENDER
     , CB_CLAUSE_ISCHAINTEREST
     , CB_CLAUSE_ISCOMINTEREST
     , CB_CLAUSE_COMINTEREST
     , CB_CLAUSE_COMINTERESTITEM
     , CB_CLAUSE_CONVERSIONITEM
     , CB_CLAUSE_CONVCHANGEITEM
     , CB_CLAUSE_CONVMONTH
     , CB_CLAUSE_INICONVPRICE
     , CB_CLAUSE_INICONVPROPORTION
     , CB_CLAUSE_CALLITEM
     , CB_CLAUSE_RESET_ITEM
     , CB_CLAUSE_RESETITEM
     , CB_CLAUSE_RATIONITEM
     , CB_LIST_PASSDATE
     , CB_LIST_PERMITDATE
     , CB_LIST_ANNOUNCEDATE
     , CB_LIST_ANNOCEDATE
     , CB_LIST_TYPE
     , CB_LIST_FEE
     , CB_LIST_RATIONDATE
     , CB_LIST_RATIONCHKINDATE
     , CB_LIST_RATIONPAYMTDATE
     , CB_LIST_RATIONCODE
     , CB_LIST_RATIONNAME
     , CB_LIST_RATIONPRICE
     , CB_LIST_RATIONRATIODE
     , CB_LIST_RATIONRATIOMO
     , CB_LIST_RATIONVOL
     , CB_LIST_ORIGINALS
     , CB_LIST_DTONL
     , CB_LIST_PCHASECODEONL
     , CB_LIST_PCHNAMEONL
     , CB_LIST_PCHPRICEONL
     , CB_LIST_ISSUEVOLONL
     , CB_LIST_CODEONL
     , CB_LIST_EXCESSPCHONL
     , CB_RESULT_EFSUBSCRPOFF
     , CB_RESULT_SUCRATEOFF
     , CB_LIST_DATEINSTOFF
     , CB_LIST_VOLINSTOFF
     , CB_RESULT_SUCRATEON
     , CB_LIST_EFFECTPCHVOLOFF
     , CB_LIST_EFFPCHOF
     , CB_LIST_SUCRATEOFF
     , CB_LIST_PRERATIONVOL
     , S_INFO_COMPCODE
     , CB_LIST_ISSUESIZE
     , CB_LIST_ISSUEQUANTITY
     , SEC_ID
     , MINUNLINE_NO
     , DEPUNLINE_RATIO
     , MAXUNLINE_NO
     , UNLINE_UD
     , IS_CONVERTIBLE_BONDS
     , MINUNLINE_PUBLIC
     , MAXUNLINE_PUBLIC
     , B_INFO_TERM_YEAR_
     , B_INFO_INTERESTTYPE
     , B_INFO_COUPONRATE
     , B_INFO_INTERESTFREQUENCY
     , CB_RESULT_SUCRATEON2
     , B_INFO_COUPONTXT
     , S_RATIOANNCEDATE
     , S_RATIODATE
     , FIRSTPRELANDATE
     , LEADUNDERWRITER
     , COUNTERGUAR_INTRODUCTION
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_CCBONDISSUANCE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_CCBONDISSUANCE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_CCBONDISSUANCE_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_CCBONDISSUANCE_PFD成功"
      exit 0
   fi
fi
