#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_ASHAREDIVIDEND_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREDIVIDEND_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  WIND_CODE  STRING  COMMENT  'Wind代码（废弃）',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  S_DIV_PROGRESS  STRING  COMMENT  '方案进度',
  STK_DVD_PER_SH  DECIMAL(18,2)  COMMENT  '每股送转',
  CASH_DVD_PER_SH_PRE_TAX  DECIMAL(18,2)  COMMENT  '每股派息(税前)(元)',
  CASH_DVD_PER_SH_AFTER_TAX  DECIMAL(18,2)  COMMENT  '每股派息(税后)(元)',
  EQY_RECORD_DT  STRING  COMMENT  '股权登记日',
  EX_DT  STRING  COMMENT  '除权除息日',
  DVD_PAYOUT_DT  STRING  COMMENT  '派息日',
  LISTING_DT_OF_DVD_SHR  STRING  COMMENT  '红股上市日',
  S_DIV_PRELANDATE  STRING  COMMENT  '预案公告日',
  S_DIV_SMTGDATE  STRING  COMMENT  '股东大会公告日',
  DVD_ANN_DT  STRING  COMMENT  '分红实施公告日',
  S_DIV_BASEDATE  STRING  COMMENT  '基准日期',
  S_DIV_BASESHARE  DECIMAL(18,2)  COMMENT  '基准股本(万股)',
  CRNCY_CODE  STRING  COMMENT  '货币代码',
  ANN_DT  STRING  COMMENT  '最新公告日期',
  IS_CHANGED  DECIMAL(18,2)  COMMENT  '方案是否变更',
  REPORT_PERIOD  STRING  COMMENT  '分红年度',
  S_DIV_CHANGE  STRING  COMMENT  '方案变更说明',
  S_DIV_BONUSRATE  DECIMAL(18,2)  COMMENT  '每股送股比例',
  S_DIV_CONVERSEDRATE  DECIMAL(18,2)  COMMENT  '每股转增比例',
  MEMO  STRING  COMMENT  '备注',
  S_DIV_PREANNDT  STRING  COMMENT  '预案预披露公告日',
  S_DIV_OBJECT  STRING  COMMENT  '分红对象',
  IS_TRANSFER  DECIMAL(18,2)  COMMENT  '是否不分转',
  DISTRI_PROFIT_CONSOLIDATE  DECIMAL(18,2)  COMMENT  '可分配利润(合并)',
  DISTRI_PROFIT_PARENT_COMP  DECIMAL(18,2)  COMMENT  '可分配利润(母公司)',
  TOT_CASH_DVD  DECIMAL(18,2)  COMMENT  '现金分红总额',
  OTHER_TOT_CASH_DVD  DECIMAL(18,2)  COMMENT  '以其他方式(如回购)现金分红总额',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国A股分红'
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
                                   , WIND_CODE
                                   , S_INFO_WINDCODE
                                   , S_DIV_PROGRESS
                                   , STK_DVD_PER_SH
                                   , CASH_DVD_PER_SH_PRE_TAX
                                   , CASH_DVD_PER_SH_AFTER_TAX
                                   , EQY_RECORD_DT
                                   , EX_DT
                                   , DVD_PAYOUT_DT
                                   , LISTING_DT_OF_DVD_SHR
                                   , S_DIV_PRELANDATE
                                   , S_DIV_SMTGDATE
                                   , DVD_ANN_DT
                                   , S_DIV_BASEDATE
                                   , S_DIV_BASESHARE
                                   , CRNCY_CODE
                                   , ANN_DT
                                   , IS_CHANGED
                                   , REPORT_PERIOD
                                   , S_DIV_CHANGE
                                   , S_DIV_BONUSRATE
                                   , S_DIV_CONVERSEDRATE
                                   , MEMO
                                   , S_DIV_PREANNDT
                                   , S_DIV_OBJECT
                                   , IS_TRANSFER
                                   , DISTRI_PROFIT_CONSOLIDATE
                                   , DISTRI_PROFIT_PARENT_COMP
                                   , TOT_CASH_DVD
                                   , OTHER_TOT_CASH_DVD
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.ASHAREDIVIDEND"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "WIND_CODE", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "S_DIV_PROGRESS", "type": "STRING"}, {"name": "STK_DVD_PER_SH", "type": "DOUBLE"}, {"name": "CASH_DVD_PER_SH_PRE_TAX", "type": "DOUBLE"}, {"name": "CASH_DVD_PER_SH_AFTER_TAX", "type": "DOUBLE"}, {"name": "EQY_RECORD_DT", "type": "STRING"}, {"name": "EX_DT", "type": "STRING"}, {"name": "DVD_PAYOUT_DT", "type": "STRING"}, {"name": "LISTING_DT_OF_DVD_SHR", "type": "STRING"}, {"name": "S_DIV_PRELANDATE", "type": "STRING"}, {"name": "S_DIV_SMTGDATE", "type": "STRING"}, {"name": "DVD_ANN_DT", "type": "STRING"}, {"name": "S_DIV_BASEDATE", "type": "STRING"}, {"name": "S_DIV_BASESHARE", "type": "DOUBLE"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "ANN_DT", "type": "STRING"}, {"name": "IS_CHANGED", "type": "DOUBLE"}, {"name": "REPORT_PERIOD", "type": "STRING"}, {"name": "S_DIV_CHANGE", "type": "STRING"}, {"name": "S_DIV_BONUSRATE", "type": "DOUBLE"}, {"name": "S_DIV_CONVERSEDRATE", "type": "DOUBLE"}, {"name": "MEMO", "type": "STRING"}, {"name": "S_DIV_PREANNDT", "type": "STRING"}, {"name": "S_DIV_OBJECT", "type": "STRING"}, {"name": "IS_TRANSFER", "type": "DOUBLE"}, {"name": "DISTRI_PROFIT_CONSOLIDATE", "type": "DOUBLE"}, {"name": "DISTRI_PROFIT_PARENT_COMP", "type": "DOUBLE"}, {"name": "TOT_CASH_DVD", "type": "DOUBLE"}, {"name": "OTHER_TOT_CASH_DVD", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_asharedividend_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_asharedividend_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_asharedividend_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_asharedividend_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_ASHAREDIVIDEND_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_ASHAREDIVIDEND_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_asharedividend_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREDIVIDEND_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , WIND_CODE
     , S_INFO_WINDCODE
     , S_DIV_PROGRESS
     , STK_DVD_PER_SH
     , CASH_DVD_PER_SH_PRE_TAX
     , CASH_DVD_PER_SH_AFTER_TAX
     , EQY_RECORD_DT
     , EX_DT
     , DVD_PAYOUT_DT
     , LISTING_DT_OF_DVD_SHR
     , S_DIV_PRELANDATE
     , S_DIV_SMTGDATE
     , DVD_ANN_DT
     , S_DIV_BASEDATE
     , S_DIV_BASESHARE
     , CRNCY_CODE
     , ANN_DT
     , IS_CHANGED
     , REPORT_PERIOD
     , S_DIV_CHANGE
     , S_DIV_BONUSRATE
     , S_DIV_CONVERSEDRATE
     , MEMO
     , S_DIV_PREANNDT
     , S_DIV_OBJECT
     , IS_TRANSFER
     , DISTRI_PROFIT_CONSOLIDATE
     , DISTRI_PROFIT_PARENT_COMP
     , TOT_CASH_DVD
     , OTHER_TOT_CASH_DVD
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_ASHAREDIVIDEND_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREDIVIDEND_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_ASHAREDIVIDEND_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_ASHAREDIVIDEND_PFD成功"
      exit 0
   fi
fi
