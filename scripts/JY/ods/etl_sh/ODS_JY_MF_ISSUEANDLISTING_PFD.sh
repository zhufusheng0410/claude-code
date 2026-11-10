#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_ISSUEANDLISTING_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_ISSUEANDLISTING_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  PROSPECTUSISSUEDDATE  STRING  COMMENT  '招募说明书发布日期',
  LISTANNOUNCEMENTISSUEDATE  STRING  COMMENT  '上市公告书发布日期',
  FUNDRAISINGMETHOD  DECIMAL(10,0)  COMMENT  '募资方式',
  FUNDTYPE  DECIMAL(10,0)  COMMENT  '基金类别',
  ISSUEOBJECT  STRING  COMMENT  '发行对象',
  ISSUESTARTDATE  STRING  COMMENT  '发行日期上限',
  ISSUEENDDATE  STRING  COMMENT  '发行日期下限',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  UNITISSUEPRICE  DECIMAL(19,4)  COMMENT  '单位基金发行价格(元)',
  UNITISSUEFEE  DECIMAL(19,4)  COMMENT  '单位基金发行费用(元)',
  SHAREISSUED  DECIMAL(18,4)  COMMENT  '基金单位发行总份额(份)',
  INITIATORSUBSCRIBEVOLUME  DECIMAL(18,0)  COMMENT  '发起人认购份额(份)',
  INITIATORHOLDFLOATSHARES  DECIMAL(18,0)  COMMENT  '发起人持有可流通份额数量(份)',
  INITIATORHOLDTERM  DECIMAL(18,4)  COMMENT  '发起人可流通份额持有期限(月)',
  MINIINITIATORHOLDINGRATIO  DECIMAL(18,6)  COMMENT  '存续期发起人最低持有份额比例',
  FINSTITUTIONQUOTA  DECIMAL(18,0)  COMMENT  '保险公司等机构配售份额(份)',
  PUBLICOFFERSHARES  DECIMAL(18,0)  COMMENT  '上网公开发行份额(份)',
  GENERALLEGALPERSONQUOTA  DECIMAL(18,0)  COMMENT  '一般法人网下配售份额(份)',
  ABBRNAMEFORAPPLYING  STRING  COMMENT  '申购简称',
  APPLYINGCODE  STRING  COMMENT  '申购代码',
  APPLYINGUNIT  DECIMAL(10,0)  COMMENT  '申购单位(份)',
  MINIMUMAPPLYING  DECIMAL(10,0)  COMMENT  '单一帐户申购下限(份)',
  MAXIMUMAPPLYING  DECIMAL(10,0)  COMMENT  '单一帐户申购上限(份)',
  APPLYINGTIMES  DECIMAL(10,0)  COMMENT  '单一帐户申购次数',
  VALIDLAPPLYINGACCOUNTS  DECIMAL(10,0)  COMMENT  '发行有效申购总户数(户)',
  VALIDAPPLYINGVOL  DECIMAL(18,0)  COMMENT  '发行有效申购总量(份)',
  OVERAPPLYINGMULTIPLES  DECIMAL(18,4)  COMMENT  '发行超额认购倍数(倍)',
  FREEZEFUNDS  DECIMAL(18,4)  COMMENT  '发行冻结资金(元)',
  HITRATIO  DECIMAL(18,9)  COMMENT  '发行中签率',
  LISTEDDATE  STRING  COMMENT  '上市日期',
  LISTEDPLACE  DECIMAL(10,0)  COMMENT  '基金上市地点',
  OUTSTANDINGSHARES  DECIMAL(18,0)  COMMENT  '本次上市流通股数(股)',
  FIRSTDAYOPENPRICE  DECIMAL(18,3)  COMMENT  '上市首日开盘价(元)',
  FIRSTDAYCOLSEPRICE  DECIMAL(18,3)  COMMENT  '上市首日收盘价(元)',
  FIRSTDAYTURNOVERRATIO  DECIMAL(18,6)  COMMENT  '上市首日换手率',
  ESTABLISHMENTDATE  STRING  COMMENT  '公司成立日期',
  APPLYOPENINGDATE  STRING  COMMENT  '申购开放起始日',
  REDEEMOPENINGDATE  STRING  COMMENT  '赎回开放起始日',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  CURRENCYCODE  DECIMAL(10,0)  COMMENT  '计价货币',
  CURRENCYSTYLE  DECIMAL(10,0)  COMMENT  '货币样式',
  ISSUESTATE  DECIMAL(10,0)  COMMENT  '发行状态',
  ISSUECANCELDATE  STRING  COMMENT  '取消发行时间',
  ORGISSUESTARTDATE  STRING  COMMENT  '机构发行起始日',
  ORGISSUEENDDATE  STRING  COMMENT  '机构发行截止日',
  INITIALPARVALUE  DECIMAL(19,4)  COMMENT  '基金初始单位面值(元)',
  RAISEAPRVDATE  STRING  COMMENT  '',
  ISSUEPLANSHARES  DECIMAL(18,0)  COMMENT  '准予基金募集份额(份)',
  STRATEGYISSUEPLAN  DECIMAL(18,0)  COMMENT  '初始战略配售发售份额(份)',
  ORIGINATORISSUEPLAN  DECIMAL(18,0)  COMMENT  '其中:原始权益人及同一控制下的关联方(份)',
  OTHERSTRAISSUEPLAN  DECIMAL(18,0)  COMMENT  '其中:其他战略配售投资者(份)',
  ISSUEPLANOFFLINE  DECIMAL(18,0)  COMMENT  '网下初始发售份额(份)',
  ISSUEPLANONLINE  DECIMAL(18,0)  COMMENT  '公众初始发售份额(份)',
  ISSUEPRICECEILING  DECIMAL(19,4)  COMMENT  '发行价格上限(元)',
  ISSUEPRICEFLOOR  DECIMAL(19,4)  COMMENT  '发行价格下限(元)',
  BIDDERMINAPPLY  DECIMAL(18,0)  COMMENT  '网下配售对象最低拟认购份额(份)',
  INCREASINGAPPLYPER  DECIMAL(18,0)  COMMENT  '网下配售对象拟认购份额最小变动单位(份)',
  BIDDERMAXAPPLY  DECIMAL(18,0)  COMMENT  '网下配售对象最高拟认购份额(份)',
  ACTISSUEONLINE  DECIMAL(18,0)  COMMENT  '网上发行实际发售份额(份)',
  VALIDAPPLYVOLONLINE  DECIMAL(18,0)  COMMENT  '网上发行有效认购总额(份)',
  VALIDAPPLYNUMONLINE  DECIMAL(18,0)  COMMENT  '网上发行有效认购户数',
  LOTRATEONLINE  DECIMAL(18,10)  COMMENT  '网上发行最终中签率',
  NUMALLOTEDONLINE  DECIMAL(18,0)  COMMENT  '网上发行配号总数',
  INITIALINVESTORNUM  DECIMAL(18,0)  COMMENT  '初步询价投资者家数',
  INITIALBIDDERNUM  DECIMAL(18,0)  COMMENT  '初步询价配售对象家数',
  INITIALAPPLYVOL  DECIMAL(18,0)  COMMENT  '初步询价申报总量(份)',
  CONFORMINVESTORNUM  DECIMAL(18,0)  COMMENT  '符合规定询价投资者家数',
  CONFORMBIDDERNUM  DECIMAL(18,0)  COMMENT  '符合规定询价配售对象家数',
  CONFORMAPPLYVOL  DECIMAL(18,0)  COMMENT  '符合规定询价申报总量(份)',
  VALIDQUOTEINVESTORNUM  DECIMAL(18,0)  COMMENT  '有效报价投资者家数',
  VALIDQUOTEBIDDERNUM  DECIMAL(18,0)  COMMENT  '有效报价配售对象家数',
  VALIDAPPLYVOL  DECIMAL(18,0)  COMMENT  '有效报价申报总量(份)',
  ACTISSUEOFFLINE  DECIMAL(18,0)  COMMENT  '网下发行实际发售份额(份)',
  VALIDAPPLYVOLOFFLINE  DECIMAL(18,0)  COMMENT  '网下发行有效认购总额(份)',
  VALIDAPPLYINVESTORNUM  DECIMAL(18,0)  COMMENT  '网下发行有效认购投资者家数',
  VALIDAPPLYBIDDERNUM  DECIMAL(18,0)  COMMENT  '网下发行有效认购配售对象家数',
  LOTRATEOFFLINE  DECIMAL(18,10)  COMMENT  '网下发行最终中签率',
  ACTRAISINGAMOUNT  DECIMAL(19,4)  COMMENT  '基金募集总金额(元)',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '公募基金发行与上市'
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
                                   , PROSPECTUSISSUEDDATE
                                   , LISTANNOUNCEMENTISSUEDATE
                                   , FUNDRAISINGMETHOD
                                   , FUNDTYPE
                                   , ISSUEOBJECT
                                   , ISSUESTARTDATE
                                   , ISSUEENDDATE
                                   , PARVALUE
                                   , UNITISSUEPRICE
                                   , UNITISSUEFEE
                                   , SHAREISSUED
                                   , INITIATORSUBSCRIBEVOLUME
                                   , INITIATORHOLDFLOATSHARES
                                   , INITIATORHOLDTERM
                                   , MINIINITIATORHOLDINGRATIO
                                   , FINSTITUTIONQUOTA
                                   , PUBLICOFFERSHARES
                                   , GENERALLEGALPERSONQUOTA
                                   , ABBRNAMEFORAPPLYING
                                   , APPLYINGCODE
                                   , APPLYINGUNIT
                                   , MINIMUMAPPLYING
                                   , MAXIMUMAPPLYING
                                   , APPLYINGTIMES
                                   , VALIDLAPPLYINGACCOUNTS
                                   , VALIDAPPLYINGVOL
                                   , OVERAPPLYINGMULTIPLES
                                   , FREEZEFUNDS
                                   , HITRATIO
                                   , LISTEDDATE
                                   , LISTEDPLACE
                                   , OUTSTANDINGSHARES
                                   , FIRSTDAYOPENPRICE
                                   , FIRSTDAYCOLSEPRICE
                                   , FIRSTDAYTURNOVERRATIO
                                   , ESTABLISHMENTDATE
                                   , APPLYOPENINGDATE
                                   , REDEEMOPENINGDATE
                                   , XGRQ
                                   , JSID
                                   , CURRENCYCODE
                                   , CURRENCYSTYLE
                                   , ISSUESTATE
                                   , ISSUECANCELDATE
                                   , ORGISSUESTARTDATE
                                   , ORGISSUEENDDATE
                                   , INITIALPARVALUE
                                   , RAISEAPRVDATE
                                   , ISSUEPLANSHARES
                                   , STRATEGYISSUEPLAN
                                   , ORIGINATORISSUEPLAN
                                   , OTHERSTRAISSUEPLAN
                                   , ISSUEPLANOFFLINE
                                   , ISSUEPLANONLINE
                                   , ISSUEPRICECEILING
                                   , ISSUEPRICEFLOOR
                                   , BIDDERMINAPPLY
                                   , INCREASINGAPPLYPER
                                   , BIDDERMAXAPPLY
                                   , ACTISSUEONLINE
                                   , VALIDAPPLYVOLONLINE
                                   , VALIDAPPLYNUMONLINE
                                   , LOTRATEONLINE
                                   , NUMALLOTEDONLINE
                                   , INITIALINVESTORNUM
                                   , INITIALBIDDERNUM
                                   , INITIALAPPLYVOL
                                   , CONFORMINVESTORNUM
                                   , CONFORMBIDDERNUM
                                   , CONFORMAPPLYVOL
                                   , VALIDQUOTEINVESTORNUM
                                   , VALIDQUOTEBIDDERNUM
                                   , VALIDAPPLYVOL
                                   , ACTISSUEOFFLINE
                                   , VALIDAPPLYVOLOFFLINE
                                   , VALIDAPPLYINVESTORNUM
                                   , VALIDAPPLYBIDDERNUM
                                   , LOTRATEOFFLINE
                                   , ACTRAISINGAMOUNT
                                   , INSERTTIME
                                FROM ${jy_src_schema}.MF_ISSUEANDLISTING"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "PROSPECTUSISSUEDDATE", "type": "STRING"}, {"name": "LISTANNOUNCEMENTISSUEDATE", "type": "STRING"}, {"name": "FUNDRAISINGMETHOD", "type": "DOUBLE"}, {"name": "FUNDTYPE", "type": "DOUBLE"}, {"name": "ISSUEOBJECT", "type": "STRING"}, {"name": "ISSUESTARTDATE", "type": "STRING"}, {"name": "ISSUEENDDATE", "type": "STRING"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "UNITISSUEPRICE", "type": "DOUBLE"}, {"name": "UNITISSUEFEE", "type": "DOUBLE"}, {"name": "SHAREISSUED", "type": "DOUBLE"}, {"name": "INITIATORSUBSCRIBEVOLUME", "type": "DOUBLE"}, {"name": "INITIATORHOLDFLOATSHARES", "type": "DOUBLE"}, {"name": "INITIATORHOLDTERM", "type": "DOUBLE"}, {"name": "MINIINITIATORHOLDINGRATIO", "type": "DOUBLE"}, {"name": "FINSTITUTIONQUOTA", "type": "DOUBLE"}, {"name": "PUBLICOFFERSHARES", "type": "DOUBLE"}, {"name": "GENERALLEGALPERSONQUOTA", "type": "DOUBLE"}, {"name": "ABBRNAMEFORAPPLYING", "type": "STRING"}, {"name": "APPLYINGCODE", "type": "STRING"}, {"name": "APPLYINGUNIT", "type": "DOUBLE"}, {"name": "MINIMUMAPPLYING", "type": "DOUBLE"}, {"name": "MAXIMUMAPPLYING", "type": "DOUBLE"}, {"name": "APPLYINGTIMES", "type": "DOUBLE"}, {"name": "VALIDLAPPLYINGACCOUNTS", "type": "DOUBLE"}, {"name": "VALIDAPPLYINGVOL", "type": "DOUBLE"}, {"name": "OVERAPPLYINGMULTIPLES", "type": "DOUBLE"}, {"name": "FREEZEFUNDS", "type": "DOUBLE"}, {"name": "HITRATIO", "type": "DOUBLE"}, {"name": "LISTEDDATE", "type": "STRING"}, {"name": "LISTEDPLACE", "type": "DOUBLE"}, {"name": "OUTSTANDINGSHARES", "type": "DOUBLE"}, {"name": "FIRSTDAYOPENPRICE", "type": "DOUBLE"}, {"name": "FIRSTDAYCOLSEPRICE", "type": "DOUBLE"}, {"name": "FIRSTDAYTURNOVERRATIO", "type": "DOUBLE"}, {"name": "ESTABLISHMENTDATE", "type": "STRING"}, {"name": "APPLYOPENINGDATE", "type": "STRING"}, {"name": "REDEEMOPENINGDATE", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "CURRENCYCODE", "type": "DOUBLE"}, {"name": "CURRENCYSTYLE", "type": "DOUBLE"}, {"name": "ISSUESTATE", "type": "DOUBLE"}, {"name": "ISSUECANCELDATE", "type": "STRING"}, {"name": "ORGISSUESTARTDATE", "type": "STRING"}, {"name": "ORGISSUEENDDATE", "type": "STRING"}, {"name": "INITIALPARVALUE", "type": "DOUBLE"}, {"name": "RAISEAPRVDATE", "type": "STRING"}, {"name": "ISSUEPLANSHARES", "type": "DOUBLE"}, {"name": "STRATEGYISSUEPLAN", "type": "DOUBLE"}, {"name": "ORIGINATORISSUEPLAN", "type": "DOUBLE"}, {"name": "OTHERSTRAISSUEPLAN", "type": "DOUBLE"}, {"name": "ISSUEPLANOFFLINE", "type": "DOUBLE"}, {"name": "ISSUEPLANONLINE", "type": "DOUBLE"}, {"name": "ISSUEPRICECEILING", "type": "DOUBLE"}, {"name": "ISSUEPRICEFLOOR", "type": "DOUBLE"}, {"name": "BIDDERMINAPPLY", "type": "DOUBLE"}, {"name": "INCREASINGAPPLYPER", "type": "DOUBLE"}, {"name": "BIDDERMAXAPPLY", "type": "DOUBLE"}, {"name": "ACTISSUEONLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYVOLONLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYNUMONLINE", "type": "DOUBLE"}, {"name": "LOTRATEONLINE", "type": "DOUBLE"}, {"name": "NUMALLOTEDONLINE", "type": "DOUBLE"}, {"name": "INITIALINVESTORNUM", "type": "DOUBLE"}, {"name": "INITIALBIDDERNUM", "type": "DOUBLE"}, {"name": "INITIALAPPLYVOL", "type": "DOUBLE"}, {"name": "CONFORMINVESTORNUM", "type": "DOUBLE"}, {"name": "CONFORMBIDDERNUM", "type": "DOUBLE"}, {"name": "CONFORMAPPLYVOL", "type": "DOUBLE"}, {"name": "VALIDQUOTEINVESTORNUM", "type": "DOUBLE"}, {"name": "VALIDQUOTEBIDDERNUM", "type": "DOUBLE"}, {"name": "VALIDAPPLYVOL", "type": "DOUBLE"}, {"name": "ACTISSUEOFFLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYVOLOFFLINE", "type": "DOUBLE"}, {"name": "VALIDAPPLYINVESTORNUM", "type": "DOUBLE"}, {"name": "VALIDAPPLYBIDDERNUM", "type": "DOUBLE"}, {"name": "LOTRATEOFFLINE", "type": "DOUBLE"}, {"name": "ACTRAISINGAMOUNT", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_issueandlisting_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_issueandlisting_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_issueandlisting_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_issueandlisting_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_ISSUEANDLISTING_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_ISSUEANDLISTING_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_issueandlisting_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_ISSUEANDLISTING_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INITIALINFOPUBLDATE
     , PROSPECTUSISSUEDDATE
     , LISTANNOUNCEMENTISSUEDATE
     , FUNDRAISINGMETHOD
     , FUNDTYPE
     , ISSUEOBJECT
     , ISSUESTARTDATE
     , ISSUEENDDATE
     , PARVALUE
     , UNITISSUEPRICE
     , UNITISSUEFEE
     , SHAREISSUED
     , INITIATORSUBSCRIBEVOLUME
     , INITIATORHOLDFLOATSHARES
     , INITIATORHOLDTERM
     , MINIINITIATORHOLDINGRATIO
     , FINSTITUTIONQUOTA
     , PUBLICOFFERSHARES
     , GENERALLEGALPERSONQUOTA
     , ABBRNAMEFORAPPLYING
     , APPLYINGCODE
     , APPLYINGUNIT
     , MINIMUMAPPLYING
     , MAXIMUMAPPLYING
     , APPLYINGTIMES
     , VALIDLAPPLYINGACCOUNTS
     , VALIDAPPLYINGVOL
     , OVERAPPLYINGMULTIPLES
     , FREEZEFUNDS
     , HITRATIO
     , LISTEDDATE
     , LISTEDPLACE
     , OUTSTANDINGSHARES
     , FIRSTDAYOPENPRICE
     , FIRSTDAYCOLSEPRICE
     , FIRSTDAYTURNOVERRATIO
     , ESTABLISHMENTDATE
     , APPLYOPENINGDATE
     , REDEEMOPENINGDATE
     , XGRQ
     , JSID
     , CURRENCYCODE
     , CURRENCYSTYLE
     , ISSUESTATE
     , ISSUECANCELDATE
     , ORGISSUESTARTDATE
     , ORGISSUEENDDATE
     , INITIALPARVALUE
     , RAISEAPRVDATE
     , ISSUEPLANSHARES
     , STRATEGYISSUEPLAN
     , ORIGINATORISSUEPLAN
     , OTHERSTRAISSUEPLAN
     , ISSUEPLANOFFLINE
     , ISSUEPLANONLINE
     , ISSUEPRICECEILING
     , ISSUEPRICEFLOOR
     , BIDDERMINAPPLY
     , INCREASINGAPPLYPER
     , BIDDERMAXAPPLY
     , ACTISSUEONLINE
     , VALIDAPPLYVOLONLINE
     , VALIDAPPLYNUMONLINE
     , LOTRATEONLINE
     , NUMALLOTEDONLINE
     , INITIALINVESTORNUM
     , INITIALBIDDERNUM
     , INITIALAPPLYVOL
     , CONFORMINVESTORNUM
     , CONFORMBIDDERNUM
     , CONFORMAPPLYVOL
     , VALIDQUOTEINVESTORNUM
     , VALIDQUOTEBIDDERNUM
     , VALIDAPPLYVOL
     , ACTISSUEOFFLINE
     , VALIDAPPLYVOLOFFLINE
     , VALIDAPPLYINVESTORNUM
     , VALIDAPPLYBIDDERNUM
     , LOTRATEOFFLINE
     , ACTRAISINGAMOUNT
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_ISSUEANDLISTING_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_ISSUEANDLISTING_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_ISSUEANDLISTING_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_ISSUEANDLISTING_PFD成功"
      exit 0
   fi
fi
