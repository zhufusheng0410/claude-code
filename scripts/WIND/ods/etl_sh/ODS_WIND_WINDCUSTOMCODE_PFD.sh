#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_WINDCUSTOMCODE_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_WINDCUSTOMCODE_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  S_INFO_ASHARECODE  STRING  COMMENT  '证券ID',
  S_INFO_COMPCODE  STRING  COMMENT  '公司ID',
  S_INFO_SECURITIESTYPES  STRING  COMMENT  '证券类型',
  S_INFO_SECTYPENAME  STRING  COMMENT  '类型名称',
  S_INFO_COUNTRYNAME  STRING  COMMENT  '国别',
  S_INFO_COUNTRYCODE  STRING  COMMENT  '国别编号',
  S_INFO_EXCHMARKETNAME  STRING  COMMENT  '交易所',
  S_INFO_EXCHMARKET  STRING  COMMENT  '交易所编号',
  CRNCY_NAME  STRING  COMMENT  '币种',
  CRNCY_CODE  STRING  COMMENT  '币种编号',
  S_INFO_ISINCODE  STRING  COMMENT  'ISIN代码',
  S_INFO_CODE  STRING  COMMENT  '交易代码',
  S_INFO_NAME  STRING  COMMENT  '证券中文简称',
  EXCHMARKET  STRING  COMMENT  '交易所',
  SECURITY_STATUS  DECIMAL(18,2)  COMMENT  '存续状态',
  S_INFO_ORG_CODE  STRING  COMMENT  '组织机构代码',
  S_INFO_TYPECODE  DECIMAL(18,2)  COMMENT  '分类代码',
  S_INFO_MIN_PRICE_CHG_UNIT  DECIMAL(18,2)  COMMENT  '最小价格变动单位',
  S_INFO_LOT_SIZE  DECIMAL(18,2)  COMMENT  '每手数量',
  S_INFO_ENAME  STRING  COMMENT  '证券英文简称',
  TRADING_HOURS_CODE  STRING  COMMENT  '交易时段编码',
  S_INFO_SECTYPEBCODE  DECIMAL(18,2)  COMMENT  '品种大类代码',
  S_INFO_SECTYPESCODE  DECIMAL(18,2)  COMMENT  '品种细类代码',
  S_INFO_PINYIN  STRING  COMMENT  '简称拼音',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT 'Wind兼容代码'
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
            "username": "${wind_username}",
            "password": "${wind_password}",
            "connection": [{
              "querySql": ["SELECT  OBJECT_ID
                                   , S_INFO_WINDCODE
                                   , S_INFO_ASHARECODE
                                   , S_INFO_COMPCODE
                                   , S_INFO_SECURITIESTYPES
                                   , S_INFO_SECTYPENAME
                                   , S_INFO_COUNTRYNAME
                                   , S_INFO_COUNTRYCODE
                                   , S_INFO_EXCHMARKETNAME
                                   , S_INFO_EXCHMARKET
                                   , CRNCY_NAME
                                   , CRNCY_CODE
                                   , S_INFO_ISINCODE
                                   , S_INFO_CODE
                                   , S_INFO_NAME
                                   , EXCHMARKET
                                   , SECURITY_STATUS
                                   , S_INFO_ORG_CODE
                                   , S_INFO_TYPECODE
                                   , S_INFO_MIN_PRICE_CHG_UNIT
                                   , S_INFO_LOT_SIZE
                                   , S_INFO_ENAME
                                   , TRADING_HOURS_CODE
                                   , S_INFO_SECTYPEBCODE
                                   , S_INFO_SECTYPESCODE
                                   , S_INFO_PINYIN
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.WINDCUSTOMCODE"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "S_INFO_ASHARECODE", "type": "STRING"}, {"name": "S_INFO_COMPCODE", "type": "STRING"}, {"name": "S_INFO_SECURITIESTYPES", "type": "STRING"}, {"name": "S_INFO_SECTYPENAME", "type": "STRING"}, {"name": "S_INFO_COUNTRYNAME", "type": "STRING"}, {"name": "S_INFO_COUNTRYCODE", "type": "STRING"}, {"name": "S_INFO_EXCHMARKETNAME", "type": "STRING"}, {"name": "S_INFO_EXCHMARKET", "type": "STRING"}, {"name": "CRNCY_NAME", "type": "STRING"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "S_INFO_ISINCODE", "type": "STRING"}, {"name": "S_INFO_CODE", "type": "STRING"}, {"name": "S_INFO_NAME", "type": "STRING"}, {"name": "EXCHMARKET", "type": "STRING"}, {"name": "SECURITY_STATUS", "type": "DOUBLE"}, {"name": "S_INFO_ORG_CODE", "type": "STRING"}, {"name": "S_INFO_TYPECODE", "type": "DOUBLE"}, {"name": "S_INFO_MIN_PRICE_CHG_UNIT", "type": "DOUBLE"}, {"name": "S_INFO_LOT_SIZE", "type": "DOUBLE"}, {"name": "S_INFO_ENAME", "type": "STRING"}, {"name": "TRADING_HOURS_CODE", "type": "STRING"}, {"name": "S_INFO_SECTYPEBCODE", "type": "DOUBLE"}, {"name": "S_INFO_SECTYPESCODE", "type": "DOUBLE"}, {"name": "S_INFO_PINYIN", "type": "STRING"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_windcustomcode_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_windcustomcode_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_windcustomcode_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_windcustomcode_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_WINDCUSTOMCODE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_WINDCUSTOMCODE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_windcustomcode_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_WINDCUSTOMCODE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , S_INFO_ASHARECODE
     , S_INFO_COMPCODE
     , S_INFO_SECURITIESTYPES
     , S_INFO_SECTYPENAME
     , S_INFO_COUNTRYNAME
     , S_INFO_COUNTRYCODE
     , S_INFO_EXCHMARKETNAME
     , S_INFO_EXCHMARKET
     , CRNCY_NAME
     , CRNCY_CODE
     , S_INFO_ISINCODE
     , S_INFO_CODE
     , S_INFO_NAME
     , EXCHMARKET
     , SECURITY_STATUS
     , S_INFO_ORG_CODE
     , S_INFO_TYPECODE
     , S_INFO_MIN_PRICE_CHG_UNIT
     , S_INFO_LOT_SIZE
     , S_INFO_ENAME
     , TRADING_HOURS_CODE
     , S_INFO_SECTYPEBCODE
     , S_INFO_SECTYPESCODE
     , S_INFO_PINYIN
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_WINDCUSTOMCODE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_WINDCUSTOMCODE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_WINDCUSTOMCODE_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_WINDCUSTOMCODE_PFD成功"
      exit 0
   fi
fi
