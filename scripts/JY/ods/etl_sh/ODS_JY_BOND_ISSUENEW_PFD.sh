#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_ISSUENEW_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_ISSUENEW_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  CROSSEXCHANGE  DECIMAL(10,0)  COMMENT  '是否跨市场',
  BONDNATURE  DECIMAL(10,0)  COMMENT  '债券性质',
  ISSUER  STRING  COMMENT  '发行人',
  ISSUERNATURE  DECIMAL(10,0)  COMMENT  '发行人性质',
  ISSUETYPE  DECIMAL(10,0)  COMMENT  '发行类别',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  ADVANCEDATE  STRING  COMMENT  '预案发布日期',
  SMDECIPUBLDATE  STRING  COMMENT  '股东大会决议公告日期',
  ADVANCEVALIDSTARTDATE  STRING  COMMENT  '预案有效期起始日',
  ADVANCEVALIDENDDATE  STRING  COMMENT  '预案有效期截止日',
  PUBLICANNOUNCEMENTDATE  STRING  COMMENT  '发行公告发布日期',
  BIDSTARTDATE  STRING  COMMENT  '招标日/薄记建档日起始日',
  BIDENDDATE  STRING  COMMENT  '招标日/薄记建档日截止日',
  ISSUEDATESTART  STRING  COMMENT  '发行日期起始日',
  ISSUEDATEEND  STRING  COMMENT  '发行日期截止日',
  ISSUESTARTDATEONLINE  STRING  COMMENT  '网上发行日期起始日',
  ISSUEENDDATEONLINE  STRING  COMMENT  '网上发行日期截止日',
  ISSUESTARTDATEOFFLINE  STRING  COMMENT  '网下发行日期起始日',
  ISSUEENDDATEOFFLINE  STRING  COMMENT  '网下发行日期截止日',
  DISTRIBUTESTARTDATE  STRING  COMMENT  '分销起始日',
  DISTRIBUTEENDDATE  STRING  COMMENT  '分销截止日',
  TRANSFERSTARTDATE  STRING  COMMENT  '划款起始日',
  TRANSFERENDDATE  STRING  COMMENT  '截止过户末日',
  CONSTARTDATEONLINE  STRING  COMMENT  '网上缴款日起始日',
  CONENDDATEONLINE  STRING  COMMENT  '网上缴款日截止日',
  CONSTARTDATEOFFLINE  STRING  COMMENT  '网下缴款日起始日',
  CONENDDATEOFFLINE  STRING  COMMENT  '网下缴款日截止日',
  TRADESINCIRCLEPUBDATE  STRING  COMMENT  '交易流通公告发布日期',
  REGDATE  STRING  COMMENT  '权益登记日',
  LISTANNOUNCEPUBDATE  STRING  COMMENT  '上市公告书发布日期',
  LISTEDDATEINBANK  STRING  COMMENT  '(银行间)上市日期',
  LISTEDDATEINEXCHANGE  STRING  COMMENT  '(交易所)上市日期',
  BIDTARGET  DECIMAL(10,0)  COMMENT  '招标标的',
  UNDERWRITINGMETHOD  DECIMAL(10,0)  COMMENT  '承销方式',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  ISSUEPRICE  DECIMAL(19,4)  COMMENT  '实际发行价(元)',
  ISSUECOMMISSIONRATE  DECIMAL(19,4)  COMMENT  '发行手续费率',
  COMMISSIONRATE  DECIMAL(19,4)  COMMENT  '兑付手续费(%)',
  ISSUEOBJECTINBANK  STRING  COMMENT  '(银行间)发行对象(文字)',
  ISSUEOBJECTINEXCHANGE  STRING  COMMENT  '(交易所)发行对象(文字)',
  APPLYCODEONLINE  STRING  COMMENT  '上网发行申购代码',
  APPLYABBRONLINE  STRING  COMMENT  '网上认购简称',
  CURRENCY  DECIMAL(10,0)  COMMENT  '货币单位',
  PLANISSUESIZE  DECIMAL(19,8)  COMMENT  '计划发行总额(包含计划增发)(元)',
  PLANISSUEADDSIZE  DECIMAL(19,8)  COMMENT  '其中：计划追加发行(百万元)',
  PLANISSUESIZEINBANK  DECIMAL(19,8)  COMMENT  '其中：银行间计划发行(百万元)',
  PLANISSUESIZEINEXCHANGE  DECIMAL(19,8)  COMMENT  '其中：交易所计划发行',
  PLANISSUESIZEONLINE  DECIMAL(19,8)  COMMENT  '交易所其中：网上计划发行(百万元)',
  PLANISSUESIZEOFFLINE  DECIMAL(19,8)  COMMENT  '交易所其中：网下计划发行(百万元)',
  ACTUALISSUESIZE  DECIMAL(19,8)  COMMENT  '实际发行规模(元)',
  ACTUALADDISSUESIZE  DECIMAL(19,8)  COMMENT  '其中：实际追加发行(百万元)',
  APPLYUNIT  DECIMAL(19,4)  COMMENT  '认购单位(元)',
  APPLYMAX  DECIMAL(19,4)  COMMENT  '认购数量上限(元)',
  APPLYMIN  DECIMAL(19,4)  COMMENT  '认购数量下限(元)',
  APPLYUNITONLINE  DECIMAL(19,4)  COMMENT  '上网发行认购单位(股)',
  APPLYMAXONLINE  DECIMAL(19,4)  COMMENT  '上网发行申购上限(股)',
  APPLYMINONLINE  DECIMAL(19,4)  COMMENT  '网上认购数量下限(元)',
  APPLYUNITOFFLINE  DECIMAL(19,4)  COMMENT  '网下认购单位(元)',
  APPLYMAXOFFLINE  DECIMAL(19,4)  COMMENT  '网下认购数量上限(元)',
  APPLYMINOFFLINE  DECIMAL(19,4)  COMMENT  '网下认购数量下限(元)',
  PROJECTCHANGINGDES  STRING  COMMENT  '方案变动说明',
  PROJECTCHANGINGTYPE  STRING  COMMENT  '方案变动类型',
  ISSUECODEADD  STRING  COMMENT  '增发代码',
  REMARK  STRING  COMMENT  '备注',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  REPALCEMENTCODE  STRING  COMMENT  '被置换债券代码',
  REPALCEMENTPRICE  DECIMAL(19,4)  COMMENT  '被置换债券价格'
)
COMMENT '债券发行上市与增发'
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
                                   , MAINCODE
                                   , CROSSEXCHANGE
                                   , BONDNATURE
                                   , ISSUER
                                   , ISSUERNATURE
                                   , ISSUETYPE
                                   , INITIALINFOPUBLDATE
                                   , ADVANCEDATE
                                   , SMDECIPUBLDATE
                                   , ADVANCEVALIDSTARTDATE
                                   , ADVANCEVALIDENDDATE
                                   , PUBLICANNOUNCEMENTDATE
                                   , BIDSTARTDATE
                                   , BIDENDDATE
                                   , ISSUEDATESTART
                                   , ISSUEDATEEND
                                   , ISSUESTARTDATEONLINE
                                   , ISSUEENDDATEONLINE
                                   , ISSUESTARTDATEOFFLINE
                                   , ISSUEENDDATEOFFLINE
                                   , DISTRIBUTESTARTDATE
                                   , DISTRIBUTEENDDATE
                                   , TRANSFERSTARTDATE
                                   , TRANSFERENDDATE
                                   , CONSTARTDATEONLINE
                                   , CONENDDATEONLINE
                                   , CONSTARTDATEOFFLINE
                                   , CONENDDATEOFFLINE
                                   , TRADESINCIRCLEPUBDATE
                                   , REGDATE
                                   , LISTANNOUNCEPUBDATE
                                   , LISTEDDATEINBANK
                                   , LISTEDDATEINEXCHANGE
                                   , BIDTARGET
                                   , UNDERWRITINGMETHOD
                                   , PARVALUE
                                   , ISSUEPRICE
                                   , ISSUECOMMISSIONRATE
                                   , COMMISSIONRATE
                                   , ISSUEOBJECTINBANK
                                   , ISSUEOBJECTINEXCHANGE
                                   , APPLYCODEONLINE
                                   , APPLYABBRONLINE
                                   , CURRENCY
                                   , PLANISSUESIZE
                                   , PLANISSUEADDSIZE
                                   , PLANISSUESIZEINBANK
                                   , PLANISSUESIZEINEXCHANGE
                                   , PLANISSUESIZEONLINE
                                   , PLANISSUESIZEOFFLINE
                                   , ACTUALISSUESIZE
                                   , ACTUALADDISSUESIZE
                                   , APPLYUNIT
                                   , APPLYMAX
                                   , APPLYMIN
                                   , APPLYUNITONLINE
                                   , APPLYMAXONLINE
                                   , APPLYMINONLINE
                                   , APPLYUNITOFFLINE
                                   , APPLYMAXOFFLINE
                                   , APPLYMINOFFLINE
                                   , PROJECTCHANGINGDES
                                   , PROJECTCHANGINGTYPE
                                   , ISSUECODEADD
                                   , REMARK
                                   , UPDATETIME
                                   , JSID
                                   , REPALCEMENTCODE
                                   , REPALCEMENTPRICE
                                FROM ${jy_src_schema}.BOND_ISSUENEW"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "CROSSEXCHANGE", "type": "DOUBLE"}, {"name": "BONDNATURE", "type": "DOUBLE"}, {"name": "ISSUER", "type": "STRING"}, {"name": "ISSUERNATURE", "type": "DOUBLE"}, {"name": "ISSUETYPE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "ADVANCEDATE", "type": "STRING"}, {"name": "SMDECIPUBLDATE", "type": "STRING"}, {"name": "ADVANCEVALIDSTARTDATE", "type": "STRING"}, {"name": "ADVANCEVALIDENDDATE", "type": "STRING"}, {"name": "PUBLICANNOUNCEMENTDATE", "type": "STRING"}, {"name": "BIDSTARTDATE", "type": "STRING"}, {"name": "BIDENDDATE", "type": "STRING"}, {"name": "ISSUEDATESTART", "type": "STRING"}, {"name": "ISSUEDATEEND", "type": "STRING"}, {"name": "ISSUESTARTDATEONLINE", "type": "STRING"}, {"name": "ISSUEENDDATEONLINE", "type": "STRING"}, {"name": "ISSUESTARTDATEOFFLINE", "type": "STRING"}, {"name": "ISSUEENDDATEOFFLINE", "type": "STRING"}, {"name": "DISTRIBUTESTARTDATE", "type": "STRING"}, {"name": "DISTRIBUTEENDDATE", "type": "STRING"}, {"name": "TRANSFERSTARTDATE", "type": "STRING"}, {"name": "TRANSFERENDDATE", "type": "STRING"}, {"name": "CONSTARTDATEONLINE", "type": "STRING"}, {"name": "CONENDDATEONLINE", "type": "STRING"}, {"name": "CONSTARTDATEOFFLINE", "type": "STRING"}, {"name": "CONENDDATEOFFLINE", "type": "STRING"}, {"name": "TRADESINCIRCLEPUBDATE", "type": "STRING"}, {"name": "REGDATE", "type": "STRING"}, {"name": "LISTANNOUNCEPUBDATE", "type": "STRING"}, {"name": "LISTEDDATEINBANK", "type": "STRING"}, {"name": "LISTEDDATEINEXCHANGE", "type": "STRING"}, {"name": "BIDTARGET", "type": "DOUBLE"}, {"name": "UNDERWRITINGMETHOD", "type": "DOUBLE"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "ISSUEPRICE", "type": "DOUBLE"}, {"name": "ISSUECOMMISSIONRATE", "type": "DOUBLE"}, {"name": "COMMISSIONRATE", "type": "DOUBLE"}, {"name": "ISSUEOBJECTINBANK", "type": "STRING"}, {"name": "ISSUEOBJECTINEXCHANGE", "type": "STRING"}, {"name": "APPLYCODEONLINE", "type": "STRING"}, {"name": "APPLYABBRONLINE", "type": "STRING"}, {"name": "CURRENCY", "type": "DOUBLE"}, {"name": "PLANISSUESIZE", "type": "DOUBLE"}, {"name": "PLANISSUEADDSIZE", "type": "DOUBLE"}, {"name": "PLANISSUESIZEINBANK", "type": "DOUBLE"}, {"name": "PLANISSUESIZEINEXCHANGE", "type": "DOUBLE"}, {"name": "PLANISSUESIZEONLINE", "type": "DOUBLE"}, {"name": "PLANISSUESIZEOFFLINE", "type": "DOUBLE"}, {"name": "ACTUALISSUESIZE", "type": "DOUBLE"}, {"name": "ACTUALADDISSUESIZE", "type": "DOUBLE"}, {"name": "APPLYUNIT", "type": "DOUBLE"}, {"name": "APPLYMAX", "type": "DOUBLE"}, {"name": "APPLYMIN", "type": "DOUBLE"}, {"name": "APPLYUNITONLINE", "type": "DOUBLE"}, {"name": "APPLYMAXONLINE", "type": "DOUBLE"}, {"name": "APPLYMINONLINE", "type": "DOUBLE"}, {"name": "APPLYUNITOFFLINE", "type": "DOUBLE"}, {"name": "APPLYMAXOFFLINE", "type": "DOUBLE"}, {"name": "APPLYMINOFFLINE", "type": "DOUBLE"}, {"name": "PROJECTCHANGINGDES", "type": "STRING"}, {"name": "PROJECTCHANGINGTYPE", "type": "DOUBLE"}, {"name": "ISSUECODEADD", "type": "DOUBLE"}, {"name": "REMARK", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "REPALCEMENTCODE", "type": "DOUBLE"}, {"name": "REPALCEMENTPRICE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_issuenew_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_issuenew_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_issuenew_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_issuenew_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_ISSUENEW_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_ISSUENEW_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_issuenew_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_ISSUENEW_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , CROSSEXCHANGE
     , BONDNATURE
     , ISSUER
     , ISSUERNATURE
     , ISSUETYPE
     , INITIALINFOPUBLDATE
     , ADVANCEDATE
     , SMDECIPUBLDATE
     , ADVANCEVALIDSTARTDATE
     , ADVANCEVALIDENDDATE
     , PUBLICANNOUNCEMENTDATE
     , BIDSTARTDATE
     , BIDENDDATE
     , ISSUEDATESTART
     , ISSUEDATEEND
     , ISSUESTARTDATEONLINE
     , ISSUEENDDATEONLINE
     , ISSUESTARTDATEOFFLINE
     , ISSUEENDDATEOFFLINE
     , DISTRIBUTESTARTDATE
     , DISTRIBUTEENDDATE
     , TRANSFERSTARTDATE
     , TRANSFERENDDATE
     , CONSTARTDATEONLINE
     , CONENDDATEONLINE
     , CONSTARTDATEOFFLINE
     , CONENDDATEOFFLINE
     , TRADESINCIRCLEPUBDATE
     , REGDATE
     , LISTANNOUNCEPUBDATE
     , LISTEDDATEINBANK
     , LISTEDDATEINEXCHANGE
     , BIDTARGET
     , UNDERWRITINGMETHOD
     , PARVALUE
     , ISSUEPRICE
     , ISSUECOMMISSIONRATE
     , COMMISSIONRATE
     , ISSUEOBJECTINBANK
     , ISSUEOBJECTINEXCHANGE
     , APPLYCODEONLINE
     , APPLYABBRONLINE
     , CURRENCY
     , PLANISSUESIZE
     , PLANISSUEADDSIZE
     , PLANISSUESIZEINBANK
     , PLANISSUESIZEINEXCHANGE
     , PLANISSUESIZEONLINE
     , PLANISSUESIZEOFFLINE
     , ACTUALISSUESIZE
     , ACTUALADDISSUESIZE
     , APPLYUNIT
     , APPLYMAX
     , APPLYMIN
     , APPLYUNITONLINE
     , APPLYMAXONLINE
     , APPLYMINONLINE
     , APPLYUNITOFFLINE
     , APPLYMAXOFFLINE
     , APPLYMINOFFLINE
     , PROJECTCHANGINGDES
     , PROJECTCHANGINGTYPE
     , ISSUECODEADD
     , REMARK
     , UPDATETIME
     , JSID
     , REPALCEMENTCODE
     , REPALCEMENTPRICE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_ISSUENEW_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_ISSUENEW_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_ISSUENEW_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_ISSUENEW_PFD成功"
      exit 0
   fi
fi
