#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MT_TRADINGDETAIL_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MT_TRADINGDETAIL_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  TRADINGDAY  STRING  COMMENT  '交易日',
  SECUMARKET  DECIMAL(10,0)  COMMENT  '证券市场',
  FINANCEVALUE  DECIMAL(19,4)  COMMENT  '融资余额(元)',
  FINANCEBUYVALUE  DECIMAL(19,4)  COMMENT  '融资买入额(元)',
  FINANCEREFUNDVALUE  DECIMAL(19,4)  COMMENT  '融资偿还额(元)',
  SECURITYVOLUME  DECIMAL(18,2)  COMMENT  '融券余量(股)',
  SECURITYSELLVOLUME  DECIMAL(18,2)  COMMENT  '融券卖出量(股)',
  SECURITYREFUNDVOLUME  DECIMAL(18,2)  COMMENT  '融券偿还量(股)',
  SECURITYVALUE  DECIMAL(19,4)  COMMENT  '融券余量金额(元)',
  TRADINGVALUE  DECIMAL(19,4)  COMMENT  '交易金额(元)',
  FINAINTOTALRATIO  DECIMAL(9,6)  COMMENT  '融资占交易所融资余额比(%)',
  SECUINTOTALRATIO  DECIMAL(9,6)  COMMENT  '融券占交易所融券余额比(%)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '融资融券交易明细'
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
                                   , INFOSOURCE
                                   , INNERCODE
                                   , TRADINGDAY
                                   , SECUMARKET
                                   , FINANCEVALUE
                                   , FINANCEBUYVALUE
                                   , FINANCEREFUNDVALUE
                                   , SECURITYVOLUME
                                   , SECURITYSELLVOLUME
                                   , SECURITYREFUNDVOLUME
                                   , SECURITYVALUE
                                   , TRADINGVALUE
                                   , FINAINTOTALRATIO
                                   , SECUINTOTALRATIO
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.MT_TRADINGDETAIL"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "SECUMARKET", "type": "DOUBLE"}, {"name": "FINANCEVALUE", "type": "DOUBLE"}, {"name": "FINANCEBUYVALUE", "type": "DOUBLE"}, {"name": "FINANCEREFUNDVALUE", "type": "DOUBLE"}, {"name": "SECURITYVOLUME", "type": "DOUBLE"}, {"name": "SECURITYSELLVOLUME", "type": "DOUBLE"}, {"name": "SECURITYREFUNDVOLUME", "type": "DOUBLE"}, {"name": "SECURITYVALUE", "type": "DOUBLE"}, {"name": "TRADINGVALUE", "type": "DOUBLE"}, {"name": "FINAINTOTALRATIO", "type": "DOUBLE"}, {"name": "SECUINTOTALRATIO", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mt_tradingdetail_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mt_tradingdetail_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mt_tradingdetail_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mt_tradingdetail_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MT_TRADINGDETAIL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MT_TRADINGDETAIL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mt_tradingdetail_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MT_TRADINGDETAIL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INFOSOURCE
     , INNERCODE
     , TRADINGDAY
     , SECUMARKET
     , FINANCEVALUE
     , FINANCEBUYVALUE
     , FINANCEREFUNDVALUE
     , SECURITYVOLUME
     , SECURITYSELLVOLUME
     , SECURITYREFUNDVOLUME
     , SECURITYVALUE
     , TRADINGVALUE
     , FINAINTOTALRATIO
     , SECUINTOTALRATIO
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MT_TRADINGDETAIL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MT_TRADINGDETAIL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MT_TRADINGDETAIL_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MT_TRADINGDETAIL_PFD成功"
      exit 0
   fi
fi
