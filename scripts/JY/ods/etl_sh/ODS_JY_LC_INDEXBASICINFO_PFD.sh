#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_INDEXBASICINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_INDEXBASICINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INDEXCODE  STRING  COMMENT  '指数代码',
  INDEXTYPE  DECIMAL(10,0)  COMMENT  '指数类别',
  COMPONENTTYPE  DECIMAL(10,0)  COMMENT  '成份证券类别',
  INDUSTRYSTANDARD  DECIMAL(10,0)  COMMENT  '行业标准',
  INDUSTRYTYPE  DECIMAL(10,0)  COMMENT  '行业类别',
  PUBORGCODE  STRING  COMMENT  '发布机构代码',
  PUBORGNAME  STRING  COMMENT  '发布机构名称',
  CREATINDEXORGCODE  STRING  COMMENT  '编制机构代码',
  CREATINDEXORGNAME  STRING  COMMENT  '编制机构名称',
  PUBDATE  STRING  COMMENT  '发布日期',
  BASEDATE  STRING  COMMENT  '基日',
  BASEPOINT  DECIMAL(16,4)  COMMENT  '基点(点)',
  WAMETHOD  DECIMAL(10,0)  COMMENT  '加权方式',
  COMPONENTSUM  DECIMAL(10,0)  COMMENT  '成份证券数量',
  COMPONENTADPERIOD  DECIMAL(10,0)  COMMENT  '成份证券调整周期',
  INDEXREMARK  STRING  COMMENT  '指数简介',
  ENDDATE  STRING  COMMENT  '日期',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  INDEXPRICETYPE  DECIMAL(10,0)  COMMENT  '指数计算类别',
  INDEXDESIGNTYPE  DECIMAL(10,0)  COMMENT  '指数设计类别',
  RELATIONSHIP  DECIMAL(10,0)  COMMENT  '与主指数关系',
  RELAMAININDEXCODE  STRING  COMMENT  '对应主指数代码',
  SECUMARKET  DECIMAL(10,0)  COMMENT  '成份证券市场',
  CURRENCYCODE  DECIMAL(10,0)  COMMENT  '币种',
  INDEXABSTRACT  STRING  COMMENT  '指数摘要',
  RELAMAINCODE  DECIMAL(10,0)  COMMENT  '对应主指数内码',
  PUBINDEXTYPE  DECIMAL(10,0)  COMMENT  '指数类别(发布机构)',
  INDEXSERIES  DECIMAL(10,0)  COMMENT  '指数系列'
)
COMMENT '指数基本情况'
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
                                   , INDEXCODE
                                   , INDEXTYPE
                                   , COMPONENTTYPE
                                   , INDUSTRYSTANDARD
                                   , INDUSTRYTYPE
                                   , PUBORGCODE
                                   , PUBORGNAME
                                   , CREATINDEXORGCODE
                                   , CREATINDEXORGNAME
                                   , PUBDATE
                                   , BASEDATE
                                   , BASEPOINT
                                   , WAMETHOD
                                   , COMPONENTSUM
                                   , COMPONENTADPERIOD
                                   , INDEXREMARK
                                   , ENDDATE
                                   , XGRQ
                                   , JSID
                                   , INDEXPRICETYPE
                                   , INDEXDESIGNTYPE
                                   , RELATIONSHIP
                                   , RELAMAININDEXCODE
                                   , SECUMARKET
                                   , CURRENCYCODE
                                   , INDEXABSTRACT
                                   , RELAMAINCODE
                                   , PUBINDEXTYPE
                                   , INDEXSERIES
                                FROM ${jy_src_schema}.LC_INDEXBASICINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INDEXCODE", "type": "DOUBLE"}, {"name": "INDEXTYPE", "type": "DOUBLE"}, {"name": "COMPONENTTYPE", "type": "DOUBLE"}, {"name": "INDUSTRYSTANDARD", "type": "DOUBLE"}, {"name": "INDUSTRYTYPE", "type": "DOUBLE"}, {"name": "PUBORGCODE", "type": "DOUBLE"}, {"name": "PUBORGNAME", "type": "STRING"}, {"name": "CREATINDEXORGCODE", "type": "DOUBLE"}, {"name": "CREATINDEXORGNAME", "type": "STRING"}, {"name": "PUBDATE", "type": "STRING"}, {"name": "BASEDATE", "type": "STRING"}, {"name": "BASEPOINT", "type": "DOUBLE"}, {"name": "WAMETHOD", "type": "DOUBLE"}, {"name": "COMPONENTSUM", "type": "DOUBLE"}, {"name": "COMPONENTADPERIOD", "type": "DOUBLE"}, {"name": "INDEXREMARK", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "INDEXPRICETYPE", "type": "DOUBLE"}, {"name": "INDEXDESIGNTYPE", "type": "DOUBLE"}, {"name": "RELATIONSHIP", "type": "DOUBLE"}, {"name": "RELAMAININDEXCODE", "type": "STRING"}, {"name": "SECUMARKET", "type": "DOUBLE"}, {"name": "CURRENCYCODE", "type": "DOUBLE"}, {"name": "INDEXABSTRACT", "type": "STRING"}, {"name": "RELAMAINCODE", "type": "DOUBLE"}, {"name": "PUBINDEXTYPE", "type": "DOUBLE"}, {"name": "INDEXSERIES", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_indexbasicinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_indexbasicinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_indexbasicinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_indexbasicinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_INDEXBASICINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_INDEXBASICINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_indexbasicinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_INDEXBASICINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INDEXCODE
     , INDEXTYPE
     , COMPONENTTYPE
     , INDUSTRYSTANDARD
     , INDUSTRYTYPE
     , PUBORGCODE
     , PUBORGNAME
     , CREATINDEXORGCODE
     , CREATINDEXORGNAME
     , PUBDATE
     , BASEDATE
     , BASEPOINT
     , WAMETHOD
     , COMPONENTSUM
     , COMPONENTADPERIOD
     , INDEXREMARK
     , ENDDATE
     , XGRQ
     , JSID
     , INDEXPRICETYPE
     , INDEXDESIGNTYPE
     , RELATIONSHIP
     , RELAMAININDEXCODE
     , SECUMARKET
     , CURRENCYCODE
     , INDEXABSTRACT
     , RELAMAINCODE
     , PUBINDEXTYPE
     , INDEXSERIES
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_INDEXBASICINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_INDEXBASICINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_INDEXBASICINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_INDEXBASICINFO_PFD成功"
      exit 0
   fi
fi
