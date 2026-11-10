#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_ASHARECAPITALIZATION_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHARECAPITALIZATION_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  WIND_CODE  STRING  COMMENT  'Wind代码',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  CHANGE_DT  STRING  COMMENT  '变动日期',
  TOT_SHR  DECIMAL(18,2)  COMMENT  '总股本(万股)',
  FLOAT_SHR  DECIMAL(18,2)  COMMENT  '流通股(万股)',
  FLOAT_A_SHR  DECIMAL(18,2)  COMMENT  '流通A股(万股)',
  FLOAT_B_SHR  DECIMAL(18,2)  COMMENT  '流通B股(万股)',
  FLOAT_H_SHR  DECIMAL(18,2)  COMMENT  '香港流通股(万股)',
  FLOAT_OVERSEAS_SHR  DECIMAL(18,2)  COMMENT  '海外流通股(万股)',
  RESTRICTED_A_SHR  DECIMAL(18,2)  COMMENT  '限售A股(万股)',
  S_SHARE_RTD_STATE  DECIMAL(18,2)  COMMENT  '限售A股(国家持股)',
  S_SHARE_RTD_STATEJUR  DECIMAL(18,2)  COMMENT  '限售A股(国有法人持股)',
  S_SHARE_RTD_SUBOTHERDOMES  DECIMAL(18,2)  COMMENT  '限售A股(其他内资持股)',
  S_SHARE_RTD_DOMESJUR  DECIMAL(18,2)  COMMENT  '限售A股(其他内资持股:境内法人持股)',
  S_SHARE_RTD_INST  DECIMAL(18,2)  COMMENT  '限售A股(其他内资持股:机构配售股)',
  S_SHARE_RTD_DOMESNP  DECIMAL(18,2)  COMMENT  '限售A股(其他内资持股:境内自然人持股)',
  S_SHARE_RTD_SENMANAGER  DECIMAL(18,2)  COMMENT  '限售股份(高管持股)(万股)',
  S_SHARE_RTD_SUBFRGN  DECIMAL(18,2)  COMMENT  '限售A股(外资持股)',
  S_SHARE_RTD_FRGNJUR  DECIMAL(18,2)  COMMENT  '限售A股(境外法人持股)',
  S_SHARE_RTD_FRGNNP  DECIMAL(18,2)  COMMENT  '限售A股(境外自然人持股)',
  RESTRICTED_B_SHR  DECIMAL(18,2)  COMMENT  '限售B股(万股)',
  OTHER_RESTRICTED_SHR  DECIMAL(18,2)  COMMENT  '其他限售股',
  NON_TRADABLE_SHR  DECIMAL(18,2)  COMMENT  '非流通股',
  S_SHARE_NTRD_STATE_PCT  DECIMAL(18,2)  COMMENT  '非流通股(国有股)',
  S_SHARE_NTRD_STATE  DECIMAL(18,2)  COMMENT  '非流通股(国家股)',
  S_SHARE_NTRD_STATJUR  DECIMAL(18,2)  COMMENT  '非流通股(国有法人股)',
  S_SHARE_NTRD_SUBDOMESJUR  DECIMAL(18,2)  COMMENT  '非流通股(境内法人股)',
  S_SHARE_NTRD_DOMESINITOR  DECIMAL(18,2)  COMMENT  '非流通股(境内法人股:境内发起人股)',
  S_SHARE_NTRD_IPOJURIS  DECIMAL(18,2)  COMMENT  '非流通股(境内法人股:募集法人股)',
  S_SHARE_NTRD_GENJURIS  DECIMAL(18,2)  COMMENT  '非流通股(境内法人股:一般法人股)',
  S_SHARE_NTRD_STRTINVESTOR  DECIMAL(18,2)  COMMENT  '非流通股(境内法人股:战略投资者持股)',
  S_SHARE_NTRD_FUNDBAL  DECIMAL(18,2)  COMMENT  '非流通股(境内法人股:基金持股)',
  S_SHARE_NTRD_IPOINIP  DECIMAL(18,2)  COMMENT  '非流通股(自然人股)',
  S_SHARE_NTRD_TRFNSHARE  DECIMAL(18,2)  COMMENT  '转配股(万股)',
  S_SHARE_NTRD_SNORMNGER  DECIMAL(18,2)  COMMENT  '流通股(高管持股)',
  S_SHARE_NTRD_INSDEREMP  DECIMAL(18,2)  COMMENT  '内部职工股(万股)',
  S_SHARE_NTRD_PRFSHARE  DECIMAL(18,2)  COMMENT  '优先股(万股)',
  S_SHARE_NTRD_NONLSTFRGN  DECIMAL(18,2)  COMMENT  '非流通股(非上市外资股)',
  S_SHARE_NTRD_STAQ  DECIMAL(18,2)  COMMENT  'STAQ股(万股)',
  S_SHARE_NTRD_NET  DECIMAL(18,2)  COMMENT  'NET股(万股)',
  S_SHARE_CHANGEREASON  STRING  COMMENT  '股本变动原因',
  S_SHARE_TOTALA  DECIMAL(18,2)  COMMENT  'A股合计',
  S_SHARE_TOTALB  DECIMAL(18,2)  COMMENT  'B股合计',
  S_SHARE_OTCA  DECIMAL(18,2)  COMMENT  '三板A股',
  S_SHARE_OTCB  DECIMAL(18,2)  COMMENT  '三板B股',
  S_SHARE_TOTALOTC  DECIMAL(18,2)  COMMENT  '三板合计',
  S_SHARE_H  DECIMAL(18,2)  COMMENT  '香港上市股',
  S_SHARE_TOTALTRADABLE  DECIMAL(18,2)  COMMENT  '流通股合计',
  S_SHARE_TOTALRESTRICTED  DECIMAL(18,2)  COMMENT  '限售股合计',
  S_SHARE_NONTRADABLE  DECIMAL(18,2)  COMMENT  '股改前非流通股',
  ANN_DT  STRING  COMMENT  '公告日期',
  CHANGE_DT1  STRING  COMMENT  '变动日期1',
  CUR_SIGN  DECIMAL(18,2)  COMMENT  '最新标志',
  IS_VALID  DECIMAL(18,2)  COMMENT  '是否有效',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国A股股本'
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
                                   , CHANGE_DT
                                   , TOT_SHR
                                   , FLOAT_SHR
                                   , FLOAT_A_SHR
                                   , FLOAT_B_SHR
                                   , FLOAT_H_SHR
                                   , FLOAT_OVERSEAS_SHR
                                   , RESTRICTED_A_SHR
                                   , S_SHARE_RTD_STATE
                                   , S_SHARE_RTD_STATEJUR
                                   , S_SHARE_RTD_SUBOTHERDOMES
                                   , S_SHARE_RTD_DOMESJUR
                                   , S_SHARE_RTD_INST
                                   , S_SHARE_RTD_DOMESNP
                                   , S_SHARE_RTD_SENMANAGER
                                   , S_SHARE_RTD_SUBFRGN
                                   , S_SHARE_RTD_FRGNJUR
                                   , S_SHARE_RTD_FRGNNP
                                   , RESTRICTED_B_SHR
                                   , OTHER_RESTRICTED_SHR
                                   , NON_TRADABLE_SHR
                                   , S_SHARE_NTRD_STATE_PCT
                                   , S_SHARE_NTRD_STATE
                                   , S_SHARE_NTRD_STATJUR
                                   , S_SHARE_NTRD_SUBDOMESJUR
                                   , S_SHARE_NTRD_DOMESINITOR
                                   , S_SHARE_NTRD_IPOJURIS
                                   , S_SHARE_NTRD_GENJURIS
                                   , S_SHARE_NTRD_STRTINVESTOR
                                   , S_SHARE_NTRD_FUNDBAL
                                   , S_SHARE_NTRD_IPOINIP
                                   , S_SHARE_NTRD_TRFNSHARE
                                   , S_SHARE_NTRD_SNORMNGER
                                   , S_SHARE_NTRD_INSDEREMP
                                   , S_SHARE_NTRD_PRFSHARE
                                   , S_SHARE_NTRD_NONLSTFRGN
                                   , S_SHARE_NTRD_STAQ
                                   , S_SHARE_NTRD_NET
                                   , S_SHARE_CHANGEREASON
                                   , S_SHARE_TOTALA
                                   , S_SHARE_TOTALB
                                   , S_SHARE_OTCA
                                   , S_SHARE_OTCB
                                   , S_SHARE_TOTALOTC
                                   , S_SHARE_H
                                   , S_SHARE_TOTALTRADABLE
                                   , S_SHARE_TOTALRESTRICTED
                                   , S_SHARE_NONTRADABLE
                                   , ANN_DT
                                   , CHANGE_DT1
                                   , CUR_SIGN
                                   , IS_VALID
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.ASHARECAPITALIZATION"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "WIND_CODE", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "CHANGE_DT", "type": "STRING"}, {"name": "TOT_SHR", "type": "DOUBLE"}, {"name": "FLOAT_SHR", "type": "DOUBLE"}, {"name": "FLOAT_A_SHR", "type": "DOUBLE"}, {"name": "FLOAT_B_SHR", "type": "DOUBLE"}, {"name": "FLOAT_H_SHR", "type": "DOUBLE"}, {"name": "FLOAT_OVERSEAS_SHR", "type": "DOUBLE"}, {"name": "RESTRICTED_A_SHR", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_STATE", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_STATEJUR", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_SUBOTHERDOMES", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_DOMESJUR", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_INST", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_DOMESNP", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_SENMANAGER", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_SUBFRGN", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_FRGNJUR", "type": "DOUBLE"}, {"name": "S_SHARE_RTD_FRGNNP", "type": "DOUBLE"}, {"name": "RESTRICTED_B_SHR", "type": "DOUBLE"}, {"name": "OTHER_RESTRICTED_SHR", "type": "DOUBLE"}, {"name": "NON_TRADABLE_SHR", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_STATE_PCT", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_STATE", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_STATJUR", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_SUBDOMESJUR", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_DOMESINITOR", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_IPOJURIS", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_GENJURIS", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_STRTINVESTOR", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_FUNDBAL", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_IPOINIP", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_TRFNSHARE", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_SNORMNGER", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_INSDEREMP", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_PRFSHARE", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_NONLSTFRGN", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_STAQ", "type": "DOUBLE"}, {"name": "S_SHARE_NTRD_NET", "type": "DOUBLE"}, {"name": "S_SHARE_CHANGEREASON", "type": "STRING"}, {"name": "S_SHARE_TOTALA", "type": "DOUBLE"}, {"name": "S_SHARE_TOTALB", "type": "DOUBLE"}, {"name": "S_SHARE_OTCA", "type": "DOUBLE"}, {"name": "S_SHARE_OTCB", "type": "DOUBLE"}, {"name": "S_SHARE_TOTALOTC", "type": "DOUBLE"}, {"name": "S_SHARE_H", "type": "DOUBLE"}, {"name": "S_SHARE_TOTALTRADABLE", "type": "DOUBLE"}, {"name": "S_SHARE_TOTALRESTRICTED", "type": "DOUBLE"}, {"name": "S_SHARE_NONTRADABLE", "type": "DOUBLE"}, {"name": "ANN_DT", "type": "STRING"}, {"name": "CHANGE_DT1", "type": "STRING"}, {"name": "CUR_SIGN", "type": "DOUBLE"}, {"name": "IS_VALID", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_asharecapitalization_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_asharecapitalization_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_asharecapitalization_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_asharecapitalization_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_ASHARECAPITALIZATION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_ASHARECAPITALIZATION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_asharecapitalization_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_ASHARECAPITALIZATION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , WIND_CODE
     , S_INFO_WINDCODE
     , CHANGE_DT
     , TOT_SHR
     , FLOAT_SHR
     , FLOAT_A_SHR
     , FLOAT_B_SHR
     , FLOAT_H_SHR
     , FLOAT_OVERSEAS_SHR
     , RESTRICTED_A_SHR
     , S_SHARE_RTD_STATE
     , S_SHARE_RTD_STATEJUR
     , S_SHARE_RTD_SUBOTHERDOMES
     , S_SHARE_RTD_DOMESJUR
     , S_SHARE_RTD_INST
     , S_SHARE_RTD_DOMESNP
     , S_SHARE_RTD_SENMANAGER
     , S_SHARE_RTD_SUBFRGN
     , S_SHARE_RTD_FRGNJUR
     , S_SHARE_RTD_FRGNNP
     , RESTRICTED_B_SHR
     , OTHER_RESTRICTED_SHR
     , NON_TRADABLE_SHR
     , S_SHARE_NTRD_STATE_PCT
     , S_SHARE_NTRD_STATE
     , S_SHARE_NTRD_STATJUR
     , S_SHARE_NTRD_SUBDOMESJUR
     , S_SHARE_NTRD_DOMESINITOR
     , S_SHARE_NTRD_IPOJURIS
     , S_SHARE_NTRD_GENJURIS
     , S_SHARE_NTRD_STRTINVESTOR
     , S_SHARE_NTRD_FUNDBAL
     , S_SHARE_NTRD_IPOINIP
     , S_SHARE_NTRD_TRFNSHARE
     , S_SHARE_NTRD_SNORMNGER
     , S_SHARE_NTRD_INSDEREMP
     , S_SHARE_NTRD_PRFSHARE
     , S_SHARE_NTRD_NONLSTFRGN
     , S_SHARE_NTRD_STAQ
     , S_SHARE_NTRD_NET
     , S_SHARE_CHANGEREASON
     , S_SHARE_TOTALA
     , S_SHARE_TOTALB
     , S_SHARE_OTCA
     , S_SHARE_OTCB
     , S_SHARE_TOTALOTC
     , S_SHARE_H
     , S_SHARE_TOTALTRADABLE
     , S_SHARE_TOTALRESTRICTED
     , S_SHARE_NONTRADABLE
     , ANN_DT
     , CHANGE_DT1
     , CUR_SIGN
     , IS_VALID
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_ASHARECAPITALIZATION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHARECAPITALIZATION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_ASHARECAPITALIZATION_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_ASHARECAPITALIZATION_PFD成功"
      exit 0
   fi
fi
