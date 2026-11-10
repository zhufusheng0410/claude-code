#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_PERFORMANCEFORECAST_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_PERFORMANCEFORECAST_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  ENDDATE  STRING  COMMENT  '日期',
  FORCASTTYPE  STRING  COMMENT  '业绩预计类型',
  FORCASTREASON  DECIMAL(10,0)  COMMENT  '业绩预计原因',
  RESULTSTATEMENT  STRING  COMMENT  '业绩预计结果说明',
  FORCASTCONTENT  STRING  COMMENT  '业绩预计内容描述',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  EGROWTHRATEFLOOR  DECIMAL(23,8)  COMMENT  '预计幅度起始(披露)(%)',
  EGROWTHRATECEILING  DECIMAL(23,8)  COMMENT  '预计幅度截止(披露)(%)',
  EEARNINGFLOOR  DECIMAL(19,4)  COMMENT  '预计收入起始(元)',
  EEARNINGCEILING  DECIMAL(19,4)  COMMENT  '预计收入截止(元)',
  EPROFITFLOOR  DECIMAL(19,4)  COMMENT  '预计利润起始(元)',
  EPROFITCEILING  DECIMAL(19,4)  COMMENT  '预计利润截止(元)',
  EEPSFLOOR  DECIMAL(23,8)  COMMENT  '预计每股收益起始(元/股)',
  EEPSCEILING  DECIMAL(23,8)  COMMENT  '预计每股收益截止(元/股)',
  FORECASTOBJECT  DECIMAL(10,0)  COMMENT  '业绩预计对象',
  NPYOYCONSISTENTFORECAST  DECIMAL(18,4)  COMMENT  '一致预期净利润增幅(%)',
  EGROWRATEFLOORC  DECIMAL(23,8)  COMMENT  '预计幅度起始(计算)(%)',
  EGROWTHRATECEILC  DECIMAL(23,8)  COMMENT  '预计幅度截止(计算)(%)',
  LASTPROFIT  DECIMAL(19,4)  COMMENT  '上年同期净利润(元)',
  LASTEARNING  DECIMAL(19,4)  COMMENT  '上年同期收入(元)',
  LASTEPS  DECIMAL(23,8)  COMMENT  '上年同期基本每股收益(元)',
  INSERTTIME  STRING  COMMENT  '发布时间',
  ANNOUNCEMENTTAG  DECIMAL(10,0)  COMMENT  '公告标签',
  EVALUEFLOOR  DECIMAL(19,4)  COMMENT  '预计对象值起始(元)',
  EVALUECEILING  DECIMAL(19,4)  COMMENT  '预计对象值截止(元)'
)
COMMENT '业绩预告'
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
                                   , ENDDATE
                                   , FORCASTTYPE
                                   , FORCASTREASON
                                   , RESULTSTATEMENT
                                   , FORCASTCONTENT
                                   , XGRQ
                                   , JSID
                                   , EGROWTHRATEFLOOR
                                   , EGROWTHRATECEILING
                                   , EEARNINGFLOOR
                                   , EEARNINGCEILING
                                   , EPROFITFLOOR
                                   , EPROFITCEILING
                                   , EEPSFLOOR
                                   , EEPSCEILING
                                   , FORECASTOBJECT
                                   , NPYOYCONSISTENTFORECAST
                                   , EGROWRATEFLOORC
                                   , EGROWTHRATECEILC
                                   , LASTPROFIT
                                   , LASTEARNING
                                   , LASTEPS
                                   , INSERTTIME
                                   , ANNOUNCEMENTTAG
                                   , EVALUEFLOOR
                                   , EVALUECEILING
                                FROM ${jy_src_schema}.LC_PERFORMANCEFORECAST"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "FORCASTTYPE", "type": "DOUBLE"}, {"name": "FORCASTREASON", "type": "DOUBLE"}, {"name": "RESULTSTATEMENT", "type": "STRING"}, {"name": "FORCASTCONTENT", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "EGROWTHRATEFLOOR", "type": "DOUBLE"}, {"name": "EGROWTHRATECEILING", "type": "DOUBLE"}, {"name": "EEARNINGFLOOR", "type": "DOUBLE"}, {"name": "EEARNINGCEILING", "type": "DOUBLE"}, {"name": "EPROFITFLOOR", "type": "DOUBLE"}, {"name": "EPROFITCEILING", "type": "DOUBLE"}, {"name": "EEPSFLOOR", "type": "DOUBLE"}, {"name": "EEPSCEILING", "type": "DOUBLE"}, {"name": "FORECASTOBJECT", "type": "DOUBLE"}, {"name": "NPYOYCONSISTENTFORECAST", "type": "DOUBLE"}, {"name": "EGROWRATEFLOORC", "type": "DOUBLE"}, {"name": "EGROWTHRATECEILC", "type": "DOUBLE"}, {"name": "LASTPROFIT", "type": "DOUBLE"}, {"name": "LASTEARNING", "type": "DOUBLE"}, {"name": "LASTEPS", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "ANNOUNCEMENTTAG", "type": "DOUBLE"}, {"name": "EVALUEFLOOR", "type": "DOUBLE"}, {"name": "EVALUECEILING", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_performanceforecast_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_performanceforecast_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_performanceforecast_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_performanceforecast_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_PERFORMANCEFORECAST_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_PERFORMANCEFORECAST_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_performanceforecast_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_PERFORMANCEFORECAST_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , INFOPUBLDATE
     , ENDDATE
     , FORCASTTYPE
     , FORCASTREASON
     , RESULTSTATEMENT
     , FORCASTCONTENT
     , XGRQ
     , JSID
     , EGROWTHRATEFLOOR
     , EGROWTHRATECEILING
     , EEARNINGFLOOR
     , EEARNINGCEILING
     , EPROFITFLOOR
     , EPROFITCEILING
     , EEPSFLOOR
     , EEPSCEILING
     , FORECASTOBJECT
     , NPYOYCONSISTENTFORECAST
     , EGROWRATEFLOORC
     , EGROWTHRATECEILC
     , LASTPROFIT
     , LASTEARNING
     , LASTEPS
     , INSERTTIME
     , ANNOUNCEMENTTAG
     , EVALUEFLOOR
     , EVALUECEILING
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_PERFORMANCEFORECAST_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_PERFORMANCEFORECAST_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_PERFORMANCEFORECAST_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_PERFORMANCEFORECAST_PFD成功"
      exit 0
   fi
fi
