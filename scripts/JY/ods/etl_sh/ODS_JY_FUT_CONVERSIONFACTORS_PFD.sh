#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_FUT_CONVERSIONFACTORS_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_FUT_CONVERSIONFACTORS_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  ISSUANCEORG  DECIMAL(10,0)  COMMENT  '发布机构',
  CONTRACTINNERCODE  STRING  COMMENT  '合约内部编码',
  SERIALNUMBER  DECIMAL(10,0)  COMMENT  '序号',
  IBMARKETINNERCODE  STRING  COMMENT  '银行间债券市场内部编码',
  SHEXCHANGEINNERCODE  STRING  COMMENT  '上海证券交易所内部编码',
  SZEXCHANGEINNERCODE  STRING  COMMENT  '深圳证券交易所内部编码',
  COUPONRATE  DECIMAL(19,8)  COMMENT  '票面利率',
  CONVERSIONFACTORS  DECIMAL(19,8)  COMMENT  '转换因子',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '期货交割转换因子'
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
                                   , INFOPUBLDATE
                                   , ISSUANCEORG
                                   , CONTRACTINNERCODE
                                   , SERIALNUMBER
                                   , IBMARKETINNERCODE
                                   , SHEXCHANGEINNERCODE
                                   , SZEXCHANGEINNERCODE
                                   , COUPONRATE
                                   , CONVERSIONFACTORS
                                   , XGRQ
                                   , JSID
                                FROM ${jy_src_schema}.FUT_CONVERSIONFACTORS"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "ISSUANCEORG", "type": "DOUBLE"}, {"name": "CONTRACTINNERCODE", "type": "DOUBLE"}, {"name": "SERIALNUMBER", "type": "DOUBLE"}, {"name": "IBMARKETINNERCODE", "type": "DOUBLE"}, {"name": "SHEXCHANGEINNERCODE", "type": "DOUBLE"}, {"name": "SZEXCHANGEINNERCODE", "type": "DOUBLE"}, {"name": "COUPONRATE", "type": "DOUBLE"}, {"name": "CONVERSIONFACTORS", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_fut_conversionfactors_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_fut_conversionfactors_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_fut_conversionfactors_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_fut_conversionfactors_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_FUT_CONVERSIONFACTORS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_FUT_CONVERSIONFACTORS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_fut_conversionfactors_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_FUT_CONVERSIONFACTORS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INFOPUBLDATE
     , ISSUANCEORG
     , CONTRACTINNERCODE
     , SERIALNUMBER
     , IBMARKETINNERCODE
     , SHEXCHANGEINNERCODE
     , SZEXCHANGEINNERCODE
     , COUPONRATE
     , CONVERSIONFACTORS
     , XGRQ
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_FUT_CONVERSIONFACTORS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_FUT_CONVERSIONFACTORS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_FUT_CONVERSIONFACTORS_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_FUT_CONVERSIONFACTORS_PFD成功"
      exit 0
   fi
fi
