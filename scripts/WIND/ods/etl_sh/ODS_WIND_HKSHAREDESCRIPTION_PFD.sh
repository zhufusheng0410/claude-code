#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_HKSHAREDESCRIPTION_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_HKSHAREDESCRIPTION_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  S_INFO_CODE  STRING  COMMENT  '交易代码',
  S_INFO_ISINCODE  STRING  COMMENT  '[内部]ISIN代码',
  S_INFO_NAME  STRING  COMMENT  '证券中文简称',
  S_INFO_NAME_ENG  STRING  COMMENT  '[内部]证券英文简称',
  S_INFO_FULLNAME  STRING  COMMENT  '[内部]证券中文全称',
  S_INFO_FULLNAME_ENG  STRING  COMMENT  '[内部]证券英文全称',
  SECURITYCLASS  DECIMAL(18,2)  COMMENT  '品种大类代码',
  SECURITYSUBCLASS  DECIMAL(18,2)  COMMENT  '品种细类代码',
  SECURITYTYPE  STRING  COMMENT  '品种类型(兼容)',
  S_INFO_COUNTRYCODE  STRING  COMMENT  '国家及地区代码',
  S_INFO_EXCHANGE_ENG  STRING  COMMENT  '交易所英文简称',
  S_INFO_EXCHANGE  STRING  COMMENT  '交易所名称(兼容)',
  S_INFO_LISTBOARD  STRING  COMMENT  '上市板',
  S_INFO_COMPCODE  STRING  COMMENT  '公司id',
  S_INFO_STATUS  DECIMAL(18,2)  COMMENT  '存续状态',
  CRNCY_CODE  STRING  COMMENT  '交易币种',
  S_INFO_PAR  DECIMAL(18,2)  COMMENT  '面值',
  MIN_PRC_CHG_UNIT  DECIMAL(18,2)  COMMENT  '最小价格变动单位',
  S_INFO_UNITPERLOT  DECIMAL(18,2)  COMMENT  '每手数量',
  S_INFO_LISTDATE  STRING  COMMENT  '开始交易日期',
  S_INFO_DELISTDATE  STRING  COMMENT  '最后交易日期',
  S_INFO_LISTPRICE  DECIMAL(18,2)  COMMENT  '挂牌价',
  IS_HKSC  DECIMAL(18,2)  COMMENT  '是否在港股通范围内',
  ISTEMPORARYSYMBOL  DECIMAL(18,2)  COMMENT  '是否并行临时代码',
  IS_H  DECIMAL(18,2)  COMMENT  '是否是H股',
  S_INFO_PINYIN  STRING  COMMENT  '简称拼音',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '香港股票基本资料'
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
                                   , S_INFO_CODE
                                   , S_INFO_ISINCODE
                                   , S_INFO_NAME
                                   , S_INFO_NAME_ENG
                                   , S_INFO_FULLNAME
                                   , S_INFO_FULLNAME_ENG
                                   , SECURITYCLASS
                                   , SECURITYSUBCLASS
                                   , SECURITYTYPE
                                   , S_INFO_COUNTRYCODE
                                   , S_INFO_EXCHANGE_ENG
                                   , S_INFO_EXCHANGE
                                   , S_INFO_LISTBOARD
                                   , S_INFO_COMPCODE
                                   , S_INFO_STATUS
                                   , CRNCY_CODE
                                   , S_INFO_PAR
                                   , MIN_PRC_CHG_UNIT
                                   , S_INFO_UNITPERLOT
                                   , S_INFO_LISTDATE
                                   , S_INFO_DELISTDATE
                                   , S_INFO_LISTPRICE
                                   , IS_HKSC
                                   , ISTEMPORARYSYMBOL
                                   , IS_H
                                   , S_INFO_PINYIN
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.HKSHAREDESCRIPTION"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "S_INFO_CODE", "type": "STRING"}, {"name": "S_INFO_ISINCODE", "type": "STRING"}, {"name": "S_INFO_NAME", "type": "STRING"}, {"name": "S_INFO_NAME_ENG", "type": "STRING"}, {"name": "S_INFO_FULLNAME", "type": "STRING"}, {"name": "S_INFO_FULLNAME_ENG", "type": "STRING"}, {"name": "SECURITYCLASS", "type": "DOUBLE"}, {"name": "SECURITYSUBCLASS", "type": "DOUBLE"}, {"name": "SECURITYTYPE", "type": "STRING"}, {"name": "S_INFO_COUNTRYCODE", "type": "STRING"}, {"name": "S_INFO_EXCHANGE_ENG", "type": "STRING"}, {"name": "S_INFO_EXCHANGE", "type": "STRING"}, {"name": "S_INFO_LISTBOARD", "type": "STRING"}, {"name": "S_INFO_COMPCODE", "type": "STRING"}, {"name": "S_INFO_STATUS", "type": "DOUBLE"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "S_INFO_PAR", "type": "DOUBLE"}, {"name": "MIN_PRC_CHG_UNIT", "type": "DOUBLE"}, {"name": "S_INFO_UNITPERLOT", "type": "DOUBLE"}, {"name": "S_INFO_LISTDATE", "type": "STRING"}, {"name": "S_INFO_DELISTDATE", "type": "STRING"}, {"name": "S_INFO_LISTPRICE", "type": "DOUBLE"}, {"name": "IS_HKSC", "type": "DOUBLE"}, {"name": "ISTEMPORARYSYMBOL", "type": "DOUBLE"}, {"name": "IS_H", "type": "DOUBLE"}, {"name": "S_INFO_PINYIN", "type": "STRING"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_hksharedescription_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_hksharedescription_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_hksharedescription_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_hksharedescription_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_HKSHAREDESCRIPTION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_HKSHAREDESCRIPTION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_hksharedescription_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_HKSHAREDESCRIPTION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , S_INFO_CODE
     , S_INFO_ISINCODE
     , S_INFO_NAME
     , S_INFO_NAME_ENG
     , S_INFO_FULLNAME
     , S_INFO_FULLNAME_ENG
     , SECURITYCLASS
     , SECURITYSUBCLASS
     , SECURITYTYPE
     , S_INFO_COUNTRYCODE
     , S_INFO_EXCHANGE_ENG
     , S_INFO_EXCHANGE
     , S_INFO_LISTBOARD
     , S_INFO_COMPCODE
     , S_INFO_STATUS
     , CRNCY_CODE
     , S_INFO_PAR
     , MIN_PRC_CHG_UNIT
     , S_INFO_UNITPERLOT
     , S_INFO_LISTDATE
     , S_INFO_DELISTDATE
     , S_INFO_LISTPRICE
     , IS_HKSC
     , ISTEMPORARYSYMBOL
     , IS_H
     , S_INFO_PINYIN
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_HKSHAREDESCRIPTION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_HKSHAREDESCRIPTION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_HKSHAREDESCRIPTION_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_HKSHAREDESCRIPTION_PFD成功"
      exit 0
   fi
fi
