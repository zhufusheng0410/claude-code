#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_SHARESTRU_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_SHARESTRU_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  ENDDATE  STRING  COMMENT  '日期',
  NONLISTEDSHARES  DECIMAL(16,0)  COMMENT  '2)未流通A股(股)',
  PROMOTERSHARES  DECIMAL(16,0)  COMMENT  '1.发起人股(股)',
  STATESHARES  DECIMAL(16,0)  COMMENT  '国家股(股)',
  DLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '境内法人股(股)',
  FLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '外资法人股(股)',
  OTHERPROMOTERSHARES  DECIMAL(16,0)  COMMENT  '其它发起人股(股)',
  RAISEDLPSHARES  DECIMAL(16,0)  COMMENT  '2.募集法人股(股)',
  NATURALPERSONHOLDLPSHARES  DECIMAL(16,0)  COMMENT  '3.自然人法人股(股)',
  STAFFSHARES  DECIMAL(16,0)  COMMENT  '4.职工股(股)',
  RIGHTSISSUETRANSFERRED  DECIMAL(16,0)  COMMENT  '5.转配股(股)',
  PREFERREDANDOTHERSHARES  DECIMAL(16,0)  COMMENT  '6.优先股及其他(股)',
  PREFERREDSHARES  DECIMAL(16,0)  COMMENT  '其中:优先股(股)',
  FLOATSHARE  DECIMAL(16,0)  COMMENT  '流通股本(股)',
  AFLOATS  DECIMAL(16,0)  COMMENT  '1)流通A股(股)',
  AFLOATLISTED  DECIMAL(16,0)  COMMENT  '1)已上市流通A股(包含高管股)(股)',
  MANAGEMENTSHARES  DECIMAL(16,0)  COMMENT  '##高管股(股)',
  STATEGICINVESTORSHARES  DECIMAL(16,0)  COMMENT  '2)战略投资者配售持股(股)',
  COMMONLPSHARES  DECIMAL(16,0)  COMMENT  '3)一般法人配售持股(股)',
  MUTUALFUNDSHARES  DECIMAL(16,0)  COMMENT  '4)基金配售持股(股)',
  ADDITIONALISSUEUNLISTED  DECIMAL(16,0)  COMMENT  '5)增发未上市(股)',
  RIGHTSISSUEUNLISTED  DECIMAL(16,0)  COMMENT  '6)配股未上市(股)',
  BSHARES  DECIMAL(16,0)  COMMENT  'B股_旧(股)',
  HSHARES  DECIMAL(16,0)  COMMENT  '3.H股(股)',
  SSHARES  DECIMAL(16,0)  COMMENT  '1)S股(股)',
  NSHARES  DECIMAL(16,0)  COMMENT  '2)N股(股)',
  OTHERFLOATSHARES  DECIMAL(16,0)  COMMENT  '4.海外上市股(股)',
  TOTALSHARES  DECIMAL(16,0)  COMMENT  '总股本(股)',
  CHANGETYPE  DECIMAL(10,0)  COMMENT  '变动原因',
  CHANGEREASON  STRING  COMMENT  '简称变更原因',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  SLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '其中:国有法人股(股)',
  RAISEDSLPSHARES  DECIMAL(16,0)  COMMENT  '其中:募集国有法人股(股)',
  OTHERAFLOATSHARES  DECIMAL(16,0)  COMMENT  '7)其他流通股份(股)',
  RESTRICTEDAFLOATSHARES  DECIMAL(16,0)  COMMENT  '8)有限售流通A股(股)',
  RESTRINCTSTAFFSHARES  DECIMAL(16,0)  COMMENT  '其中:有限售流通股中职工股(股)',
  NONLISTEDBSHARES  DECIMAL(16,0)  COMMENT  '其中:未流通B股_旧',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  RESTRICTEDSHARES  DECIMAL(16,0)  COMMENT  '有限售条件的流通股(股)',
  STATEHOLDING  DECIMAL(16,0)  COMMENT  'A.国家持股(股)',
  SLEGALPERSONHOLDING  DECIMAL(16,0)  COMMENT  'B.国有法人持股(股)',
  OTHERDCAPITALHOLDING  DECIMAL(16,0)  COMMENT  'C.其他内资持股(股)',
  DLEGALPERSONHOLDING  DECIMAL(16,0)  COMMENT  'a.境内法人持股(股)',
  DNATURALPERSONHOLDING  DECIMAL(16,0)  COMMENT  'b.境内自然人持股(股)',
  FOREIGNHOLDING  DECIMAL(16,0)  COMMENT  'D.外资持股(股)',
  FLEGALPERSONHOLDING  DECIMAL(16,0)  COMMENT  '其中:境外法人持股(股)',
  FNATURALPERSONHOLDING  DECIMAL(16,0)  COMMENT  '其中:境外自然人持股(股)',
  OTHERRESTRICTEDSHARES  DECIMAL(16,0)  COMMENT  'E.其他有限售(股)',
  RESTRICTEDBFLOATSHARES  DECIMAL(16,0)  COMMENT  '有限售B股(股)',
  PERVALUE  DECIMAL(25,10)  COMMENT  '每股面值(元)',
  ASHARES  DECIMAL(16,0)  COMMENT  '1.A股(股)',
  NONRESTRICTEDSHARES  DECIMAL(16,0)  COMMENT  '1.4)无限售条件流通A股(股)(披露)',
  BSHARESTOTAL  DECIMAL(16,0)  COMMENT  '2.B股(股)',
  LISTEDBSHARES  DECIMAL(16,0)  COMMENT  '1)流通B股(股)',
  NONLISTEDRESTRICTEDBSHARES  DECIMAL(16,0)  COMMENT  '2)未流通B股(股)',
  FOREIGNHOLDINGASHARES  DECIMAL(16,0)  COMMENT  '外资持A股(股)',
  RESTRICTEDASHARES  DECIMAL(16,0)  COMMENT  '1.1)有限售条件的流通A股(股)(计算)',
  OTHERFNONLISTEDSHARES  DECIMAL(16,0)  COMMENT  '7.其他外资股(股)',
  NONRESISHARESJY  DECIMAL(16,0)  COMMENT  '1.2)无限售条件流通A股(股)(计算)',
  RESTRICTASHAREP  DECIMAL(16,0)  COMMENT  '1.3)有限售条件的流通A股(股)(披露)',
  SRUNLISTEDSHARE  DECIMAL(16,0)  COMMENT  '增发、配股未上市股份(股)(披露)',
  NONRESIBSHARES  DECIMAL(16,0)  COMMENT  '其中:无限售流通B股',
  DSHARES  DECIMAL(16,0)  COMMENT  '',
  GDRSHARES  DECIMAL(16,0)  COMMENT  '5.GDR代表基础股票(股)',
  PARVALUECURRENCYUNIT  DECIMAL(10,0)  COMMENT  '每股面值货币单位',
  INSERTTIME  STRING  COMMENT  '发布时间',
  NONRESTRICTEDHSHARES  DECIMAL(16,0)  COMMENT  '无限售H股',
  RESTRICTEDHSHARES  DECIMAL(16,0)  COMMENT  '有限售H股',
  OUNLISTEDSHARES  DECIMAL(16,0)  COMMENT  '其他未流通股(股)',
  OTHERNONLISTEDSHARES  DECIMAL(16,0)  COMMENT  '8.其他未流通股(股)'
)
COMMENT '公司股本结构变动'
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
                                   , INFOSOURCE
                                   , ENDDATE
                                   , NONLISTEDSHARES
                                   , PROMOTERSHARES
                                   , STATESHARES
                                   , DLEGALPERSONSHARES
                                   , FLEGALPERSONSHARES
                                   , OTHERPROMOTERSHARES
                                   , RAISEDLPSHARES
                                   , NATURALPERSONHOLDLPSHARES
                                   , STAFFSHARES
                                   , RIGHTSISSUETRANSFERRED
                                   , PREFERREDANDOTHERSHARES
                                   , PREFERREDSHARES
                                   , FLOATSHARE
                                   , AFLOATS
                                   , AFLOATLISTED
                                   , MANAGEMENTSHARES
                                   , STATEGICINVESTORSHARES
                                   , COMMONLPSHARES
                                   , MUTUALFUNDSHARES
                                   , ADDITIONALISSUEUNLISTED
                                   , RIGHTSISSUEUNLISTED
                                   , BSHARES
                                   , HSHARES
                                   , SSHARES
                                   , NSHARES
                                   , OTHERFLOATSHARES
                                   , TOTALSHARES
                                   , CHANGETYPE
                                   , CHANGEREASON
                                   , XGRQ
                                   , JSID
                                   , SLEGALPERSONSHARES
                                   , RAISEDSLPSHARES
                                   , OTHERAFLOATSHARES
                                   , RESTRICTEDAFLOATSHARES
                                   , RESTRINCTSTAFFSHARES
                                   , NONLISTEDBSHARES
                                   , INFOPUBLDATE
                                   , RESTRICTEDSHARES
                                   , STATEHOLDING
                                   , SLEGALPERSONHOLDING
                                   , OTHERDCAPITALHOLDING
                                   , DLEGALPERSONHOLDING
                                   , DNATURALPERSONHOLDING
                                   , FOREIGNHOLDING
                                   , FLEGALPERSONHOLDING
                                   , FNATURALPERSONHOLDING
                                   , OTHERRESTRICTEDSHARES
                                   , RESTRICTEDBFLOATSHARES
                                   , PERVALUE
                                   , ASHARES
                                   , NONRESTRICTEDSHARES
                                   , BSHARESTOTAL
                                   , LISTEDBSHARES
                                   , NONLISTEDRESTRICTEDBSHARES
                                   , FOREIGNHOLDINGASHARES
                                   , RESTRICTEDASHARES
                                   , OTHERFNONLISTEDSHARES
                                   , NONRESISHARESJY
                                   , RESTRICTASHAREP
                                   , SRUNLISTEDSHARE
                                   , NONRESIBSHARES
                                   , DSHARES
                                   , GDRSHARES
                                   , PARVALUECURRENCYUNIT
                                   , INSERTTIME
                                   , NONRESTRICTEDHSHARES
                                   , RESTRICTEDHSHARES
                                   , OUNLISTEDSHARES
                                   , OTHERNONLISTEDSHARES
                                FROM ${jy_src_schema}.LC_SHARESTRU"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "NONLISTEDSHARES", "type": "DOUBLE"}, {"name": "PROMOTERSHARES", "type": "DOUBLE"}, {"name": "STATESHARES", "type": "DOUBLE"}, {"name": "DLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "FLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "OTHERPROMOTERSHARES", "type": "DOUBLE"}, {"name": "RAISEDLPSHARES", "type": "DOUBLE"}, {"name": "NATURALPERSONHOLDLPSHARES", "type": "DOUBLE"}, {"name": "STAFFSHARES", "type": "DOUBLE"}, {"name": "RIGHTSISSUETRANSFERRED", "type": "DOUBLE"}, {"name": "PREFERREDANDOTHERSHARES", "type": "DOUBLE"}, {"name": "PREFERREDSHARES", "type": "DOUBLE"}, {"name": "FLOATSHARE", "type": "DOUBLE"}, {"name": "AFLOATS", "type": "DOUBLE"}, {"name": "AFLOATLISTED", "type": "DOUBLE"}, {"name": "MANAGEMENTSHARES", "type": "DOUBLE"}, {"name": "STATEGICINVESTORSHARES", "type": "DOUBLE"}, {"name": "COMMONLPSHARES", "type": "DOUBLE"}, {"name": "MUTUALFUNDSHARES", "type": "DOUBLE"}, {"name": "ADDITIONALISSUEUNLISTED", "type": "DOUBLE"}, {"name": "RIGHTSISSUEUNLISTED", "type": "DOUBLE"}, {"name": "BSHARES", "type": "DOUBLE"}, {"name": "HSHARES", "type": "DOUBLE"}, {"name": "SSHARES", "type": "DOUBLE"}, {"name": "NSHARES", "type": "DOUBLE"}, {"name": "OTHERFLOATSHARES", "type": "DOUBLE"}, {"name": "TOTALSHARES", "type": "DOUBLE"}, {"name": "CHANGETYPE", "type": "DOUBLE"}, {"name": "CHANGEREASON", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "SLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "RAISEDSLPSHARES", "type": "DOUBLE"}, {"name": "OTHERAFLOATSHARES", "type": "DOUBLE"}, {"name": "RESTRICTEDAFLOATSHARES", "type": "DOUBLE"}, {"name": "RESTRINCTSTAFFSHARES", "type": "DOUBLE"}, {"name": "NONLISTEDBSHARES", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "RESTRICTEDSHARES", "type": "DOUBLE"}, {"name": "STATEHOLDING", "type": "DOUBLE"}, {"name": "SLEGALPERSONHOLDING", "type": "DOUBLE"}, {"name": "OTHERDCAPITALHOLDING", "type": "DOUBLE"}, {"name": "DLEGALPERSONHOLDING", "type": "DOUBLE"}, {"name": "DNATURALPERSONHOLDING", "type": "DOUBLE"}, {"name": "FOREIGNHOLDING", "type": "DOUBLE"}, {"name": "FLEGALPERSONHOLDING", "type": "DOUBLE"}, {"name": "FNATURALPERSONHOLDING", "type": "DOUBLE"}, {"name": "OTHERRESTRICTEDSHARES", "type": "DOUBLE"}, {"name": "RESTRICTEDBFLOATSHARES", "type": "DOUBLE"}, {"name": "PERVALUE", "type": "DOUBLE"}, {"name": "ASHARES", "type": "DOUBLE"}, {"name": "NONRESTRICTEDSHARES", "type": "DOUBLE"}, {"name": "BSHARESTOTAL", "type": "DOUBLE"}, {"name": "LISTEDBSHARES", "type": "DOUBLE"}, {"name": "NONLISTEDRESTRICTEDBSHARES", "type": "DOUBLE"}, {"name": "FOREIGNHOLDINGASHARES", "type": "DOUBLE"}, {"name": "RESTRICTEDASHARES", "type": "DOUBLE"}, {"name": "OTHERFNONLISTEDSHARES", "type": "DOUBLE"}, {"name": "NONRESISHARESJY", "type": "DOUBLE"}, {"name": "RESTRICTASHAREP", "type": "DOUBLE"}, {"name": "SRUNLISTEDSHARE", "type": "DOUBLE"}, {"name": "NONRESIBSHARES", "type": "DOUBLE"}, {"name": "DSHARES", "type": "DOUBLE"}, {"name": "GDRSHARES", "type": "DOUBLE"}, {"name": "PARVALUECURRENCYUNIT", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "NONRESTRICTEDHSHARES", "type": "DOUBLE"}, {"name": "RESTRICTEDHSHARES", "type": "DOUBLE"}, {"name": "OUNLISTEDSHARES", "type": "DOUBLE"}, {"name": "OTHERNONLISTEDSHARES", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_sharestru_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_sharestru_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_sharestru_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_sharestru_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_SHARESTRU_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_SHARESTRU_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_sharestru_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_SHARESTRU_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , INFOSOURCE
     , ENDDATE
     , NONLISTEDSHARES
     , PROMOTERSHARES
     , STATESHARES
     , DLEGALPERSONSHARES
     , FLEGALPERSONSHARES
     , OTHERPROMOTERSHARES
     , RAISEDLPSHARES
     , NATURALPERSONHOLDLPSHARES
     , STAFFSHARES
     , RIGHTSISSUETRANSFERRED
     , PREFERREDANDOTHERSHARES
     , PREFERREDSHARES
     , FLOATSHARE
     , AFLOATS
     , AFLOATLISTED
     , MANAGEMENTSHARES
     , STATEGICINVESTORSHARES
     , COMMONLPSHARES
     , MUTUALFUNDSHARES
     , ADDITIONALISSUEUNLISTED
     , RIGHTSISSUEUNLISTED
     , BSHARES
     , HSHARES
     , SSHARES
     , NSHARES
     , OTHERFLOATSHARES
     , TOTALSHARES
     , CHANGETYPE
     , CHANGEREASON
     , XGRQ
     , JSID
     , SLEGALPERSONSHARES
     , RAISEDSLPSHARES
     , OTHERAFLOATSHARES
     , RESTRICTEDAFLOATSHARES
     , RESTRINCTSTAFFSHARES
     , NONLISTEDBSHARES
     , INFOPUBLDATE
     , RESTRICTEDSHARES
     , STATEHOLDING
     , SLEGALPERSONHOLDING
     , OTHERDCAPITALHOLDING
     , DLEGALPERSONHOLDING
     , DNATURALPERSONHOLDING
     , FOREIGNHOLDING
     , FLEGALPERSONHOLDING
     , FNATURALPERSONHOLDING
     , OTHERRESTRICTEDSHARES
     , RESTRICTEDBFLOATSHARES
     , PERVALUE
     , ASHARES
     , NONRESTRICTEDSHARES
     , BSHARESTOTAL
     , LISTEDBSHARES
     , NONLISTEDRESTRICTEDBSHARES
     , FOREIGNHOLDINGASHARES
     , RESTRICTEDASHARES
     , OTHERFNONLISTEDSHARES
     , NONRESISHARESJY
     , RESTRICTASHAREP
     , SRUNLISTEDSHARE
     , NONRESIBSHARES
     , DSHARES
     , GDRSHARES
     , PARVALUECURRENCYUNIT
     , INSERTTIME
     , NONRESTRICTEDHSHARES
     , RESTRICTEDHSHARES
     , OUNLISTEDSHARES
     , OTHERNONLISTEDSHARES
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_SHARESTRU_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_SHARESTRU_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_SHARESTRU_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_SHARESTRU_PFD成功"
      exit 0
   fi
fi
