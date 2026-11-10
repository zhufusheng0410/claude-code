#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_STIBSHARESTRU_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBSHARESTRU_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  ENDDATE  STRING  COMMENT  '截止日期',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  PARVALUE  DECIMAL(25,10)  COMMENT  '每股面值(元)',
  TOTALSHARES  DECIMAL(16,0)  COMMENT  '总股本(股)',
  ASHARES  DECIMAL(16,0)  COMMENT  '1.A股(股)',
  AFLOATS  DECIMAL(16,0)  COMMENT  '1)流通A股(股)',
  RESTRICTEDASHARES  DECIMAL(16,0)  COMMENT  '1.1)有限售条件的流通A股(股)(计算)',
  NONRESISHARESJY  DECIMAL(16,0)  COMMENT  '1.2)无限售条件流通A股(股)(计算)',
  RESTRICTASHAREP  DECIMAL(16,0)  COMMENT  '1.3)有限售条件的流通A股(股)(披露)',
  NONRESTRICTEDSHARES  DECIMAL(16,0)  COMMENT  '1.4)无限售条件流通A股(股)(披露)',
  NONLISTEDSHARES  DECIMAL(16,0)  COMMENT  '2)未流通A股(股)',
  SRUNLISTEDSHARE  DECIMAL(16,0)  COMMENT  '3)增发、配股未上市股份(股)',
  HSHARES  DECIMAL(16,0)  COMMENT  '2.H股(股)',
  OTHERFLOATSHARES  DECIMAL(16,0)  COMMENT  '3.海外上市股(股)',
  SSHARES  DECIMAL(16,0)  COMMENT  '1)S股(股)',
  NSHARES  DECIMAL(16,0)  COMMENT  '2)N股(股)',
  DSHARES  DECIMAL(16,0)  COMMENT  '3)D股(股)',
  PROMOTERSHARES  DECIMAL(16,0)  COMMENT  '1.发起人股(股)',
  STATESHARES  DECIMAL(16,0)  COMMENT  '1)国家股(股)',
  SLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '其中:国有法人股(股)',
  DLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '2)境内法人股(股)',
  FLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '3)境外法人股(股)',
  OTHERPROMOTERSHARES  DECIMAL(16,0)  COMMENT  '4)其它发起人股(股)',
  NLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '2.自然人法人股(股)',
  DNLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '1)境内自然人法人股(股)',
  FNLEGALPERSONSHARES  DECIMAL(16,0)  COMMENT  '2)境外自然人法人股(股)',
  FLOATSHARE  DECIMAL(16,0)  COMMENT  '流通股份(股)',
  AFLOATLISTED  DECIMAL(16,0)  COMMENT  '1.已上市流通A股(包含高管股)(股)',
  COMMONLPSHARES  DECIMAL(16,0)  COMMENT  '2.一般法人配售持股(股)',
  RESTRICTEDAFLOATSHARES  DECIMAL(16,0)  COMMENT  '3.有限售流通A股(股)',
  NEWISSUEUNLISTED  DECIMAL(16,0)  COMMENT  '4.增发未上市(股)',
  RIGHTSISSUEUNLISTED  DECIMAL(16,0)  COMMENT  '5.配股未上市(股)',
  FOREIGNFLOATLISTED  DECIMAL(16,0)  COMMENT  '6.境外上市股(股)',
  STATEHOLDING  DECIMAL(16,0)  COMMENT  '1.国家持股(股)',
  SLEGALPERSONHOLDING  DECIMAL(16,0)  COMMENT  '2.国有法人持股(股)',
  OTHERDCAPITALHOLDING  DECIMAL(16,0)  COMMENT  '3.其他内资持股(股)',
  DLPERSONHOLDING  DECIMAL(16,0)  COMMENT  '3.1)境内法人持股(股)',
  DNPERSONHOLDING  DECIMAL(16,0)  COMMENT  '3.2)境内自然人持股(股)',
  MANAGEMENTSHARES  DECIMAL(16,0)  COMMENT  '3.3)高管股(股)',
  FOREIGNHOLDING  DECIMAL(16,0)  COMMENT  '4.外资持股(股)',
  FLPERSONHOLDING  DECIMAL(16,0)  COMMENT  '4.1)境外法人持股(股)',
  FNPERSONHOLDING  DECIMAL(16,0)  COMMENT  '4.2)境外自然人持股(股)',
  OTHERRESTRICTEDSHARES  DECIMAL(16,0)  COMMENT  '5.其他有限售(股)',
  CHANGETYPE  DECIMAL(10,0)  COMMENT  '股本变动原因类别',
  CHANGEREASON  STRING  COMMENT  '股本变动原因说明',
  INSERTTIME  STRING  COMMENT  '发布时间',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  PARVALUECURRENCYUNIT  DECIMAL(10,0)  COMMENT  '每股面值货币单位',
  STATEGICINVESTORSHARES  DECIMAL(16,0)  COMMENT  '战略投资者配售持股(股)',
  NONRESTRICTEDHSHARES  DECIMAL(16,0)  COMMENT  '无限售H股',
  RESTRICTEDHSHARES  DECIMAL(16,0)  COMMENT  '有限售H股'
)
COMMENT '科创板公司股本结构'
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
                                   , INFOPUBLDATE
                                   , PARVALUE
                                   , TOTALSHARES
                                   , ASHARES
                                   , AFLOATS
                                   , RESTRICTEDASHARES
                                   , NONRESISHARESJY
                                   , RESTRICTASHAREP
                                   , NONRESTRICTEDSHARES
                                   , NONLISTEDSHARES
                                   , SRUNLISTEDSHARE
                                   , HSHARES
                                   , OTHERFLOATSHARES
                                   , SSHARES
                                   , NSHARES
                                   , DSHARES
                                   , PROMOTERSHARES
                                   , STATESHARES
                                   , SLEGALPERSONSHARES
                                   , DLEGALPERSONSHARES
                                   , FLEGALPERSONSHARES
                                   , OTHERPROMOTERSHARES
                                   , NLEGALPERSONSHARES
                                   , DNLEGALPERSONSHARES
                                   , FNLEGALPERSONSHARES
                                   , FLOATSHARE
                                   , AFLOATLISTED
                                   , COMMONLPSHARES
                                   , RESTRICTEDAFLOATSHARES
                                   , NEWISSUEUNLISTED
                                   , RIGHTSISSUEUNLISTED
                                   , FOREIGNFLOATLISTED
                                   , STATEHOLDING
                                   , SLEGALPERSONHOLDING
                                   , OTHERDCAPITALHOLDING
                                   , DLPERSONHOLDING
                                   , DNPERSONHOLDING
                                   , MANAGEMENTSHARES
                                   , FOREIGNHOLDING
                                   , FLPERSONHOLDING
                                   , FNPERSONHOLDING
                                   , OTHERRESTRICTEDSHARES
                                   , CHANGETYPE
                                   , CHANGEREASON
                                   , INSERTTIME
                                   , UPDATETIME
                                   , JSID
                                   , PARVALUECURRENCYUNIT
                                   , STATEGICINVESTORSHARES
                                   , NONRESTRICTEDHSHARES
                                   , RESTRICTEDHSHARES
                                FROM ${jy_src_schema}.LC_STIBSHARESTRU"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "TOTALSHARES", "type": "DOUBLE"}, {"name": "ASHARES", "type": "DOUBLE"}, {"name": "AFLOATS", "type": "DOUBLE"}, {"name": "RESTRICTEDASHARES", "type": "DOUBLE"}, {"name": "NONRESISHARESJY", "type": "DOUBLE"}, {"name": "RESTRICTASHAREP", "type": "DOUBLE"}, {"name": "NONRESTRICTEDSHARES", "type": "DOUBLE"}, {"name": "NONLISTEDSHARES", "type": "DOUBLE"}, {"name": "SRUNLISTEDSHARE", "type": "DOUBLE"}, {"name": "HSHARES", "type": "DOUBLE"}, {"name": "OTHERFLOATSHARES", "type": "DOUBLE"}, {"name": "SSHARES", "type": "DOUBLE"}, {"name": "NSHARES", "type": "DOUBLE"}, {"name": "DSHARES", "type": "DOUBLE"}, {"name": "PROMOTERSHARES", "type": "DOUBLE"}, {"name": "STATESHARES", "type": "DOUBLE"}, {"name": "SLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "DLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "FLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "OTHERPROMOTERSHARES", "type": "DOUBLE"}, {"name": "NLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "DNLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "FNLEGALPERSONSHARES", "type": "DOUBLE"}, {"name": "FLOATSHARE", "type": "DOUBLE"}, {"name": "AFLOATLISTED", "type": "DOUBLE"}, {"name": "COMMONLPSHARES", "type": "DOUBLE"}, {"name": "RESTRICTEDAFLOATSHARES", "type": "DOUBLE"}, {"name": "NEWISSUEUNLISTED", "type": "DOUBLE"}, {"name": "RIGHTSISSUEUNLISTED", "type": "DOUBLE"}, {"name": "FOREIGNFLOATLISTED", "type": "DOUBLE"}, {"name": "STATEHOLDING", "type": "DOUBLE"}, {"name": "SLEGALPERSONHOLDING", "type": "DOUBLE"}, {"name": "OTHERDCAPITALHOLDING", "type": "DOUBLE"}, {"name": "DLPERSONHOLDING", "type": "DOUBLE"}, {"name": "DNPERSONHOLDING", "type": "DOUBLE"}, {"name": "MANAGEMENTSHARES", "type": "DOUBLE"}, {"name": "FOREIGNHOLDING", "type": "DOUBLE"}, {"name": "FLPERSONHOLDING", "type": "DOUBLE"}, {"name": "FNPERSONHOLDING", "type": "DOUBLE"}, {"name": "OTHERRESTRICTEDSHARES", "type": "DOUBLE"}, {"name": "CHANGETYPE", "type": "DOUBLE"}, {"name": "CHANGEREASON", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "PARVALUECURRENCYUNIT", "type": "DOUBLE"}, {"name": "STATEGICINVESTORSHARES", "type": "DOUBLE"}, {"name": "NONRESTRICTEDHSHARES", "type": "DOUBLE"}, {"name": "RESTRICTEDHSHARES", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_stibsharestru_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_stibsharestru_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_stibsharestru_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_stibsharestru_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_STIBSHARESTRU_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_STIBSHARESTRU_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_stibsharestru_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBSHARESTRU_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , INFOSOURCE
     , ENDDATE
     , INFOPUBLDATE
     , PARVALUE
     , TOTALSHARES
     , ASHARES
     , AFLOATS
     , RESTRICTEDASHARES
     , NONRESISHARESJY
     , RESTRICTASHAREP
     , NONRESTRICTEDSHARES
     , NONLISTEDSHARES
     , SRUNLISTEDSHARE
     , HSHARES
     , OTHERFLOATSHARES
     , SSHARES
     , NSHARES
     , DSHARES
     , PROMOTERSHARES
     , STATESHARES
     , SLEGALPERSONSHARES
     , DLEGALPERSONSHARES
     , FLEGALPERSONSHARES
     , OTHERPROMOTERSHARES
     , NLEGALPERSONSHARES
     , DNLEGALPERSONSHARES
     , FNLEGALPERSONSHARES
     , FLOATSHARE
     , AFLOATLISTED
     , COMMONLPSHARES
     , RESTRICTEDAFLOATSHARES
     , NEWISSUEUNLISTED
     , RIGHTSISSUEUNLISTED
     , FOREIGNFLOATLISTED
     , STATEHOLDING
     , SLEGALPERSONHOLDING
     , OTHERDCAPITALHOLDING
     , DLPERSONHOLDING
     , DNPERSONHOLDING
     , MANAGEMENTSHARES
     , FOREIGNHOLDING
     , FLPERSONHOLDING
     , FNPERSONHOLDING
     , OTHERRESTRICTEDSHARES
     , CHANGETYPE
     , CHANGEREASON
     , INSERTTIME
     , UPDATETIME
     , JSID
     , PARVALUECURRENCYUNIT
     , STATEGICINVESTORSHARES
     , NONRESTRICTEDHSHARES
     , RESTRICTEDHSHARES
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_STIBSHARESTRU_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBSHARESTRU_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_STIBSHARESTRU_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_STIBSHARESTRU_PFD成功"
      exit 0
   fi
fi
