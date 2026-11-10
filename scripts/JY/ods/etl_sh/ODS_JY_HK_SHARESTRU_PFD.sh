#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_HK_SHARESTRU_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_HK_SHARESTRU_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  ENDDATE  STRING  COMMENT  '日期',
  PARVALUEUNITCOMSHARE  DECIMAL(10,0)  COMMENT  '普通股面值单位',
  PARVALUECOMSHARE  DECIMAL(19,10)  COMMENT  '普通股面值(元/股)',
  PARVALUEUNITPRESHARE  DECIMAL(10,0)  COMMENT  '优先股面值单位',
  PARVALUEPRESHARE  DECIMAL(19,10)  COMMENT  '优先股面值(元/股)',
  AUTHORIZEDCAPITALCOMSHARE  DECIMAL(19,4)  COMMENT  '法定股本(元)',
  AUTHORIZEDSHARESCOMSHARE  DECIMAL(18,2)  COMMENT  '法定股数(股)',
  PAIDUPCAPITALCOMSHARE  DECIMAL(19,4)  COMMENT  '实收股本(元)',
  PAIDUPSHARESCOMSHARE  DECIMAL(18,2)  COMMENT  '实收股数(股)',
  LISTEDSHARES  DECIMAL(18,2)  COMMENT  '#已上市(股)',
  UNLISTEDSHARES  DECIMAL(18,2)  COMMENT  '#待上市(股)',
  NOTHKSHARES  DECIMAL(18,2)  COMMENT  '#非港股(股)',
  AUTHORIZEDCAPITALPRESHARE  DECIMAL(19,4)  COMMENT  '法定股本(元)',
  AUTHORIZEDSHARESPRESHARE  DECIMAL(18,2)  COMMENT  '法定股数(股)',
  PAIDUPCAPITALPRESHARE  DECIMAL(19,4)  COMMENT  '实收股本(元)',
  PAIDUPSHARESPRESHARE  DECIMAL(18,2)  COMMENT  '实收股数(股)',
  AUTHORIZEDCAPITALTOTAL  DECIMAL(19,4)  COMMENT  '法定股本(元)',
  AUTHORIZEDSHARESTOTAL  DECIMAL(18,2)  COMMENT  '法定股数(股)',
  PAIDUPCAPITALTOTAL  DECIMAL(19,4)  COMMENT  '实收股本(元)',
  PAIDUPSHARESTOTAL  DECIMAL(18,2)  COMMENT  '实收股数(股)',
  PAIDUPSHARESCHGCOMSHARE  DECIMAL(18,2)  COMMENT  '普通股实收变动股数(股)',
  PAIDUPSHARESCHGPRESHARE  DECIMAL(18,2)  COMMENT  '优先股实收变动股数(股)',
  CHANGETYPE  DECIMAL(10,0)  COMMENT  '变动原因',
  CHANGEREASON  STRING  COMMENT  '简称变更原因',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  AUTHCAPITALCOMSHAREA  DECIMAL(19,2)  COMMENT  'A类法定股本(元)',
  AUTHCAPITALCOMSHAREB  DECIMAL(19,2)  COMMENT  'B类法定股本(元)',
  AUTHSHARESCOMSHAREA  DECIMAL(18,0)  COMMENT  'A类法定股数(股)',
  AUTHSHARESCOMSHAREB  DECIMAL(18,0)  COMMENT  'B类法定股数(股)',
  PAIDUPCAPITALCOMSHAREA  DECIMAL(19,2)  COMMENT  'A类实收股本(元)',
  PAIDUPCAPITALCOMSHAREB  DECIMAL(19,2)  COMMENT  'B类实收股本(元)',
  PAIDUPSHARESCOMSHAREA  DECIMAL(18,0)  COMMENT  'A类实收股数(股)',
  PAIDUPSHARESCOMSHAREB  DECIMAL(18,0)  COMMENT  'B类实收股数(股)',
  LISTEDSHARESA  DECIMAL(18,0)  COMMENT  '#A类已上市(股)',
  LISTEDSHARESB  DECIMAL(18,0)  COMMENT  '#B类已上市(股)',
  UNLISTEDSHARESA  DECIMAL(18,0)  COMMENT  '#A类待上市(股)',
  UNLISTEDSHARESB  DECIMAL(18,0)  COMMENT  '#B类待上市(股)',
  PAIDUPSHCHGCOMSHAREA  DECIMAL(18,0)  COMMENT  'A类普通股实收变动股数(股)',
  PAIDUPSHCHGCOMSHAREB  DECIMAL(18,0)  COMMENT  'B类普通股实收变动股数(股)',
  VOTINGRIGHTSA  DECIMAL(10,0)  COMMENT  'A类投票权(票/股)',
  VOTINGRIGHTSB  DECIMAL(10,0)  COMMENT  'B类投票权(票/股)',
  LISTEDSHARES2  DECIMAL(18,2)  COMMENT  '已上市港股股数2(股)',
  TREASURYSHARES  DECIMAL(18,2)  COMMENT  '库存股',
  ASHARES  DECIMAL(18,2)  COMMENT  'A股',
  BSHARES  DECIMAL(18,2)  COMMENT  'B股',
  DSHARES  DECIMAL(18,2)  COMMENT  'D股',
  NONLISTEDSHARES  DECIMAL(18,2)  COMMENT  '非上市流通股',
  OVERSEASCOUNTRY  STRING  COMMENT  '海外上市国家'
)
COMMENT '港股股本结构'
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
                                   , COMPANYCODE
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , ENDDATE
                                   , PARVALUEUNITCOMSHARE
                                   , PARVALUECOMSHARE
                                   , PARVALUEUNITPRESHARE
                                   , PARVALUEPRESHARE
                                   , AUTHORIZEDCAPITALCOMSHARE
                                   , AUTHORIZEDSHARESCOMSHARE
                                   , PAIDUPCAPITALCOMSHARE
                                   , PAIDUPSHARESCOMSHARE
                                   , LISTEDSHARES
                                   , UNLISTEDSHARES
                                   , NOTHKSHARES
                                   , AUTHORIZEDCAPITALPRESHARE
                                   , AUTHORIZEDSHARESPRESHARE
                                   , PAIDUPCAPITALPRESHARE
                                   , PAIDUPSHARESPRESHARE
                                   , AUTHORIZEDCAPITALTOTAL
                                   , AUTHORIZEDSHARESTOTAL
                                   , PAIDUPCAPITALTOTAL
                                   , PAIDUPSHARESTOTAL
                                   , PAIDUPSHARESCHGCOMSHARE
                                   , PAIDUPSHARESCHGPRESHARE
                                   , CHANGETYPE
                                   , CHANGEREASON
                                   , XGRQ
                                   , JSID
                                   , AUTHCAPITALCOMSHAREA
                                   , AUTHCAPITALCOMSHAREB
                                   , AUTHSHARESCOMSHAREA
                                   , AUTHSHARESCOMSHAREB
                                   , PAIDUPCAPITALCOMSHAREA
                                   , PAIDUPCAPITALCOMSHAREB
                                   , PAIDUPSHARESCOMSHAREA
                                   , PAIDUPSHARESCOMSHAREB
                                   , LISTEDSHARESA
                                   , LISTEDSHARESB
                                   , UNLISTEDSHARESA
                                   , UNLISTEDSHARESB
                                   , PAIDUPSHCHGCOMSHAREA
                                   , PAIDUPSHCHGCOMSHAREB
                                   , VOTINGRIGHTSA
                                   , VOTINGRIGHTSB
                                   , LISTEDSHARES2
                                   , TREASURYSHARES
                                   , ASHARES
                                   , BSHARES
                                   , DSHARES
                                   , NONLISTEDSHARES
                                   , OVERSEASCOUNTRY
                                FROM ${jy_src_schema}.HK_SHARESTRU"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "PARVALUEUNITCOMSHARE", "type": "DOUBLE"}, {"name": "PARVALUECOMSHARE", "type": "DOUBLE"}, {"name": "PARVALUEUNITPRESHARE", "type": "DOUBLE"}, {"name": "PARVALUEPRESHARE", "type": "DOUBLE"}, {"name": "AUTHORIZEDCAPITALCOMSHARE", "type": "DOUBLE"}, {"name": "AUTHORIZEDSHARESCOMSHARE", "type": "DOUBLE"}, {"name": "PAIDUPCAPITALCOMSHARE", "type": "DOUBLE"}, {"name": "PAIDUPSHARESCOMSHARE", "type": "DOUBLE"}, {"name": "LISTEDSHARES", "type": "DOUBLE"}, {"name": "UNLISTEDSHARES", "type": "DOUBLE"}, {"name": "NOTHKSHARES", "type": "DOUBLE"}, {"name": "AUTHORIZEDCAPITALPRESHARE", "type": "DOUBLE"}, {"name": "AUTHORIZEDSHARESPRESHARE", "type": "DOUBLE"}, {"name": "PAIDUPCAPITALPRESHARE", "type": "DOUBLE"}, {"name": "PAIDUPSHARESPRESHARE", "type": "DOUBLE"}, {"name": "AUTHORIZEDCAPITALTOTAL", "type": "DOUBLE"}, {"name": "AUTHORIZEDSHARESTOTAL", "type": "DOUBLE"}, {"name": "PAIDUPCAPITALTOTAL", "type": "DOUBLE"}, {"name": "PAIDUPSHARESTOTAL", "type": "DOUBLE"}, {"name": "PAIDUPSHARESCHGCOMSHARE", "type": "DOUBLE"}, {"name": "PAIDUPSHARESCHGPRESHARE", "type": "DOUBLE"}, {"name": "CHANGETYPE", "type": "DOUBLE"}, {"name": "CHANGEREASON", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "AUTHCAPITALCOMSHAREA", "type": "DOUBLE"}, {"name": "AUTHCAPITALCOMSHAREB", "type": "DOUBLE"}, {"name": "AUTHSHARESCOMSHAREA", "type": "DOUBLE"}, {"name": "AUTHSHARESCOMSHAREB", "type": "DOUBLE"}, {"name": "PAIDUPCAPITALCOMSHAREA", "type": "DOUBLE"}, {"name": "PAIDUPCAPITALCOMSHAREB", "type": "DOUBLE"}, {"name": "PAIDUPSHARESCOMSHAREA", "type": "DOUBLE"}, {"name": "PAIDUPSHARESCOMSHAREB", "type": "DOUBLE"}, {"name": "LISTEDSHARESA", "type": "DOUBLE"}, {"name": "LISTEDSHARESB", "type": "DOUBLE"}, {"name": "UNLISTEDSHARESA", "type": "DOUBLE"}, {"name": "UNLISTEDSHARESB", "type": "DOUBLE"}, {"name": "PAIDUPSHCHGCOMSHAREA", "type": "DOUBLE"}, {"name": "PAIDUPSHCHGCOMSHAREB", "type": "DOUBLE"}, {"name": "VOTINGRIGHTSA", "type": "DOUBLE"}, {"name": "VOTINGRIGHTSB", "type": "DOUBLE"}, {"name": "LISTEDSHARES2", "type": "DOUBLE"}, {"name": "TREASURYSHARES", "type": "DOUBLE"}, {"name": "ASHARES", "type": "DOUBLE"}, {"name": "BSHARES", "type": "DOUBLE"}, {"name": "DSHARES", "type": "DOUBLE"}, {"name": "NONLISTEDSHARES", "type": "DOUBLE"}, {"name": "OVERSEASCOUNTRY", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_hk_sharestru_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_hk_sharestru_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_hk_sharestru_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_hk_sharestru_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_HK_SHARESTRU_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_HK_SHARESTRU_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_hk_sharestru_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_HK_SHARESTRU_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , ENDDATE
     , PARVALUEUNITCOMSHARE
     , PARVALUECOMSHARE
     , PARVALUEUNITPRESHARE
     , PARVALUEPRESHARE
     , AUTHORIZEDCAPITALCOMSHARE
     , AUTHORIZEDSHARESCOMSHARE
     , PAIDUPCAPITALCOMSHARE
     , PAIDUPSHARESCOMSHARE
     , LISTEDSHARES
     , UNLISTEDSHARES
     , NOTHKSHARES
     , AUTHORIZEDCAPITALPRESHARE
     , AUTHORIZEDSHARESPRESHARE
     , PAIDUPCAPITALPRESHARE
     , PAIDUPSHARESPRESHARE
     , AUTHORIZEDCAPITALTOTAL
     , AUTHORIZEDSHARESTOTAL
     , PAIDUPCAPITALTOTAL
     , PAIDUPSHARESTOTAL
     , PAIDUPSHARESCHGCOMSHARE
     , PAIDUPSHARESCHGPRESHARE
     , CHANGETYPE
     , CHANGEREASON
     , XGRQ
     , JSID
     , AUTHCAPITALCOMSHAREA
     , AUTHCAPITALCOMSHAREB
     , AUTHSHARESCOMSHAREA
     , AUTHSHARESCOMSHAREB
     , PAIDUPCAPITALCOMSHAREA
     , PAIDUPCAPITALCOMSHAREB
     , PAIDUPSHARESCOMSHAREA
     , PAIDUPSHARESCOMSHAREB
     , LISTEDSHARESA
     , LISTEDSHARESB
     , UNLISTEDSHARESA
     , UNLISTEDSHARESB
     , PAIDUPSHCHGCOMSHAREA
     , PAIDUPSHCHGCOMSHAREB
     , VOTINGRIGHTSA
     , VOTINGRIGHTSB
     , LISTEDSHARES2
     , TREASURYSHARES
     , ASHARES
     , BSHARES
     , DSHARES
     , NONLISTEDSHARES
     , OVERSEASCOUNTRY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_HK_SHARESTRU_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_HK_SHARESTRU_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_HK_SHARESTRU_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_HK_SHARESTRU_PFD成功"
      exit 0
   fi
fi
