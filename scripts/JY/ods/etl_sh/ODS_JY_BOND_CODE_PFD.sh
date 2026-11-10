#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CODE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CODE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  SECUCODE  STRING  COMMENT  '证券代码',
  SECUABBR  STRING  COMMENT  '证券简称',
  CHISPELLING  STRING  COMMENT  '拼音证券简称',
  CHINAME  STRING  COMMENT  '中文名称',
  CHINAMEABBR  STRING  COMMENT  '中文名称缩写',
  ENGNAME  STRING  COMMENT  '英文名称',
  ENGNAMEABBR  STRING  COMMENT  '英文名称缩写',
  CURRENCY  DECIMAL(10,0)  COMMENT  '货币单位',
  SECUMARKET  DECIMAL(10,0)  COMMENT  '证券市场',
  LISTEDDATE  STRING  COMMENT  '上市日期',
  LISTEDSECTOR  DECIMAL(10,0)  COMMENT  '上市板块',
  LISTEDSTATE  DECIMAL(10,0)  COMMENT  '上市状态',
  DELISTDATE  STRING  COMMENT  '停止交易日',
  ISSUER  STRING  COMMENT  '发行人',
  ISSUERNATURE  DECIMAL(10,0)  COMMENT  '发行人性质',
  BONDNATURE  DECIMAL(10,0)  COMMENT  '债券性质',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  INTERESTENDDATE  STRING  COMMENT  '到期日',
  BONDTYPELEVEL1  STRING  COMMENT  '债券分类(级别1)',
  BONDTYPELEVEL1DESC  STRING  COMMENT  '债券分类说明(级别1)',
  BONDTYPELEVEL2  STRING  COMMENT  '债券分类(级别2)',
  BONDTYPELEVEL2DESC  STRING  COMMENT  '债券分类说明(级别2)',
  ISSUEYEAR  DECIMAL(10,0)  COMMENT  '债券年度',
  ISSUEPHASE  DECIMAL(10,0)  COMMENT  '债券期次',
  EXTENDEDABBR  STRING  COMMENT  '扩位简称',
  EXTENDEDSPELLING  STRING  COMMENT  '拼音扩位简称'
)
COMMENT '债券代码对照表'
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
                                   , COMPANYCODE
                                   , SECUCODE
                                   , SECUABBR
                                   , CHISPELLING
                                   , CHINAME
                                   , CHINAMEABBR
                                   , ENGNAME
                                   , ENGNAMEABBR
                                   , CURRENCY
                                   , SECUMARKET
                                   , LISTEDDATE
                                   , LISTEDSECTOR
                                   , LISTEDSTATE
                                   , DELISTDATE
                                   , ISSUER
                                   , ISSUERNATURE
                                   , BONDNATURE
                                   , UPDATETIME
                                   , JSID
                                   , INTERESTENDDATE
                                   , BONDTYPELEVEL1
                                   , BONDTYPELEVEL1DESC
                                   , BONDTYPELEVEL2
                                   , BONDTYPELEVEL2DESC
                                   , ISSUEYEAR
                                   , ISSUEPHASE
                                   , EXTENDEDABBR
                                   , EXTENDEDSPELLING
                                FROM ${jy_src_schema}.BOND_CODE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "SECUCODE", "type": "STRING"}, {"name": "SECUABBR", "type": "STRING"}, {"name": "CHISPELLING", "type": "STRING"}, {"name": "CHINAME", "type": "STRING"}, {"name": "CHINAMEABBR", "type": "STRING"}, {"name": "ENGNAME", "type": "STRING"}, {"name": "ENGNAMEABBR", "type": "STRING"}, {"name": "CURRENCY", "type": "DOUBLE"}, {"name": "SECUMARKET", "type": "DOUBLE"}, {"name": "LISTEDDATE", "type": "STRING"}, {"name": "LISTEDSECTOR", "type": "DOUBLE"}, {"name": "LISTEDSTATE", "type": "DOUBLE"}, {"name": "DELISTDATE", "type": "STRING"}, {"name": "ISSUER", "type": "STRING"}, {"name": "ISSUERNATURE", "type": "DOUBLE"}, {"name": "BONDNATURE", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "INTERESTENDDATE", "type": "STRING"}, {"name": "BONDTYPELEVEL1", "type": "DOUBLE"}, {"name": "BONDTYPELEVEL1DESC", "type": "STRING"}, {"name": "BONDTYPELEVEL2", "type": "DOUBLE"}, {"name": "BONDTYPELEVEL2DESC", "type": "STRING"}, {"name": "ISSUEYEAR", "type": "DOUBLE"}, {"name": "ISSUEPHASE", "type": "DOUBLE"}, {"name": "EXTENDEDABBR", "type": "STRING"}, {"name": "EXTENDEDSPELLING", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_code_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_code_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_code_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_code_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CODE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CODE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_code_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CODE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , INNERCODE
     , COMPANYCODE
     , SECUCODE
     , SECUABBR
     , CHISPELLING
     , CHINAME
     , CHINAMEABBR
     , ENGNAME
     , ENGNAMEABBR
     , CURRENCY
     , SECUMARKET
     , LISTEDDATE
     , LISTEDSECTOR
     , LISTEDSTATE
     , DELISTDATE
     , ISSUER
     , ISSUERNATURE
     , BONDNATURE
     , UPDATETIME
     , JSID
     , INTERESTENDDATE
     , BONDTYPELEVEL1
     , BONDTYPELEVEL1DESC
     , BONDTYPELEVEL2
     , BONDTYPELEVEL2DESC
     , ISSUEYEAR
     , ISSUEPHASE
     , EXTENDEDABBR
     , EXTENDEDSPELLING
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CODE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CODE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CODE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CODE_PFD成功"
      exit 0
   fi
fi
