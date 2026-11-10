#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_ISSUE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_ISSUE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  BONDFULLNAME  STRING  COMMENT  '债券全称',
  BONDNATURE  DECIMAL(10,0)  COMMENT  '债券性质',
  BONDFORM  DECIMAL(10,0)  COMMENT  '债券形式',
  CURRENCYUNIT  DECIMAL(10,0)  COMMENT  '货币单位',
  CROSSEXCHANGE  DECIMAL(10,0)  COMMENT  '是否跨市场',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  ISSUER  STRING  COMMENT  '发行人',
  ISSUERNATURE  DECIMAL(10,0)  COMMENT  '发行人性质',
  GUARANTOR  STRING  COMMENT  '担保方',
  GUARANTMETHOD  DECIMAL(10,0)  COMMENT  '担保方式',
  CRAS  STRING  COMMENT  '评级机构',
  CREDITRATING  STRING  COMMENT  '债券信用级别(字母)',
  LEADUNDERWRITER  STRING  COMMENT  '主承销商',
  UNDERWRITINGMETHOD  DECIMAL(10,0)  COMMENT  '承销方式',
  PUBLICANNOUNCEMENTDATE  STRING  COMMENT  '发行公告发布日期',
  ISSUEOBJECT  STRING  COMMENT  '发行对象',
  ISSUEMETHOD  STRING  COMMENT  '发行方式',
  ISSUEPRICE  DECIMAL(19,4)  COMMENT  '实际发行价(元)',
  SUBSTRIPTIONUNIT  DECIMAL(19,4)  COMMENT  '网下认购单位(元)',
  ISSUECOMMISSIONRATE  DECIMAL(10,6)  COMMENT  '发行手续费率',
  ISSUESTARDATE  STRING  COMMENT  '发行期起始日',
  ISSUEENDDATE  STRING  COMMENT  '发行日期下限',
  PLANISSUESIZE  DECIMAL(19,2)  COMMENT  '计划发行总额(包含计划增发)(元)',
  ACTUALISSUESIZE  DECIMAL(19,2)  COMMENT  '实际发行规模(元)',
  EXPUANNOUNCEMENTDAY  STRING  COMMENT  '上市公告书发布日期',
  LISTEDDATE  STRING  COMMENT  '上市日期',
  \`EXCHANGE\`  DECIMAL(10,0)  COMMENT  '上市地点',
  TRADEUNIT  STRING  COMMENT  '买卖单位(股/手)',
  PARVALUEPER  DECIMAL(19,4)  COMMENT  '每手面值(元)',
  DELISTDATE  STRING  COMMENT  '停止交易日',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  APPLYCODEONLINE  STRING  COMMENT  '上网发行申购代码',
  APPLYUNITONLINE  DECIMAL(16,2)  COMMENT  '上网发行认购单位(股)',
  APPLYMAXONLINE  DECIMAL(16,2)  COMMENT  '上网发行申购上限(股)',
  APPLYMINONLINE  DECIMAL(16,2)  COMMENT  '网上认购数量下限(元)',
  APPLYMINOFFLINE  DECIMAL(16,2)  COMMENT  '网下认购数量下限(元)'
)
COMMENT '债券发行与上市'
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
                                   , INNERCODE
                                   , BONDFULLNAME
                                   , BONDNATURE
                                   , BONDFORM
                                   , CURRENCYUNIT
                                   , CROSSEXCHANGE
                                   , INITIALINFOPUBLDATE
                                   , ISSUER
                                   , ISSUERNATURE
                                   , GUARANTOR
                                   , GUARANTMETHOD
                                   , CRAS
                                   , CREDITRATING
                                   , LEADUNDERWRITER
                                   , UNDERWRITINGMETHOD
                                   , PUBLICANNOUNCEMENTDATE
                                   , ISSUEOBJECT
                                   , ISSUEMETHOD
                                   , ISSUEPRICE
                                   , SUBSTRIPTIONUNIT
                                   , ISSUECOMMISSIONRATE
                                   , ISSUESTARDATE
                                   , ISSUEENDDATE
                                   , PLANISSUESIZE
                                   , ACTUALISSUESIZE
                                   , EXPUANNOUNCEMENTDAY
                                   , LISTEDDATE
                                   , EXCHANGE
                                   , TRADEUNIT
                                   , PARVALUEPER
                                   , DELISTDATE
                                   , UPDATETIME
                                   , JSID
                                   , APPLYCODEONLINE
                                   , APPLYUNITONLINE
                                   , APPLYMAXONLINE
                                   , APPLYMINONLINE
                                   , APPLYMINOFFLINE
                                FROM ${jy_src_schema}.BOND_ISSUE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "BONDFULLNAME", "type": "STRING"}, {"name": "BONDNATURE", "type": "DOUBLE"}, {"name": "BONDFORM", "type": "DOUBLE"}, {"name": "CURRENCYUNIT", "type": "DOUBLE"}, {"name": "CROSSEXCHANGE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "ISSUER", "type": "STRING"}, {"name": "ISSUERNATURE", "type": "DOUBLE"}, {"name": "GUARANTOR", "type": "STRING"}, {"name": "GUARANTMETHOD", "type": "DOUBLE"}, {"name": "CRAS", "type": "STRING"}, {"name": "CREDITRATING", "type": "STRING"}, {"name": "LEADUNDERWRITER", "type": "STRING"}, {"name": "UNDERWRITINGMETHOD", "type": "DOUBLE"}, {"name": "PUBLICANNOUNCEMENTDATE", "type": "STRING"}, {"name": "ISSUEOBJECT", "type": "STRING"}, {"name": "ISSUEMETHOD", "type": "STRING"}, {"name": "ISSUEPRICE", "type": "DOUBLE"}, {"name": "SUBSTRIPTIONUNIT", "type": "DOUBLE"}, {"name": "ISSUECOMMISSIONRATE", "type": "DOUBLE"}, {"name": "ISSUESTARDATE", "type": "STRING"}, {"name": "ISSUEENDDATE", "type": "STRING"}, {"name": "PLANISSUESIZE", "type": "DOUBLE"}, {"name": "ACTUALISSUESIZE", "type": "DOUBLE"}, {"name": "EXPUANNOUNCEMENTDAY", "type": "STRING"}, {"name": "LISTEDDATE", "type": "STRING"}, {"name": "EXCHANGE", "type": "DOUBLE"}, {"name": "TRADEUNIT", "type": "STRING"}, {"name": "PARVALUEPER", "type": "DOUBLE"}, {"name": "DELISTDATE", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "APPLYCODEONLINE", "type": "STRING"}, {"name": "APPLYUNITONLINE", "type": "DOUBLE"}, {"name": "APPLYMAXONLINE", "type": "DOUBLE"}, {"name": "APPLYMINONLINE", "type": "DOUBLE"}, {"name": "APPLYMINOFFLINE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_issue_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_issue_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_issue_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_issue_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_ISSUE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_ISSUE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_issue_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_ISSUE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , INNERCODE
     , BONDFULLNAME
     , BONDNATURE
     , BONDFORM
     , CURRENCYUNIT
     , CROSSEXCHANGE
     , INITIALINFOPUBLDATE
     , ISSUER
     , ISSUERNATURE
     , GUARANTOR
     , GUARANTMETHOD
     , CRAS
     , CREDITRATING
     , LEADUNDERWRITER
     , UNDERWRITINGMETHOD
     , PUBLICANNOUNCEMENTDATE
     , ISSUEOBJECT
     , ISSUEMETHOD
     , ISSUEPRICE
     , SUBSTRIPTIONUNIT
     , ISSUECOMMISSIONRATE
     , ISSUESTARDATE
     , ISSUEENDDATE
     , PLANISSUESIZE
     , ACTUALISSUESIZE
     , EXPUANNOUNCEMENTDAY
     , LISTEDDATE
     , \`EXCHANGE\`
     , TRADEUNIT
     , PARVALUEPER
     , DELISTDATE
     , UPDATETIME
     , JSID
     , APPLYCODEONLINE
     , APPLYUNITONLINE
     , APPLYMAXONLINE
     , APPLYMINONLINE
     , APPLYMINOFFLINE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_ISSUE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_ISSUE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_ISSUE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_ISSUE_PFD成功"
      exit 0
   fi
fi
