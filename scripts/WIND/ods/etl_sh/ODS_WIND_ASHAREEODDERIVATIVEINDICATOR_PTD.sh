#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  S_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  TRADE_DT  STRING  COMMENT  '交易日期',
  CRNCY_CODE  STRING  COMMENT  '货币代码',
  S_VAL_MV  DECIMAL(18,2)  COMMENT  '当日总市值',
  S_DQ_MV  DECIMAL(18,2)  COMMENT  '当日流通市值',
  S_PQ_HIGH_52W_  DECIMAL(18,2)  COMMENT  '52周最高价',
  S_PQ_LOW_52W_  DECIMAL(18,2)  COMMENT  '52周最低价',
  S_VAL_PE  DECIMAL(18,2)  COMMENT  '市盈率(PE)',
  S_VAL_PB_NEW  DECIMAL(18,2)  COMMENT  '市净率(PB)',
  S_VAL_PE_TTM  DECIMAL(18,2)  COMMENT  '市盈率(PE,TTM)',
  S_VAL_PCF_OCF  DECIMAL(18,2)  COMMENT  '市现率(PCF,经营现金流)',
  S_VAL_PCF_OCFTTM  DECIMAL(18,2)  COMMENT  '市现率(PCF,经营现金流TTM)',
  S_VAL_PCF_NCF  DECIMAL(18,2)  COMMENT  '市现率(PCF,现金净流量)',
  S_VAL_PCF_NCFTTM  DECIMAL(18,2)  COMMENT  '市现率(PCF,现金净流量TTM)',
  S_VAL_PS  DECIMAL(18,2)  COMMENT  '市销率(PS)',
  S_VAL_PS_TTM  DECIMAL(18,2)  COMMENT  '市销率(PS,TTM)',
  S_DQ_TURN  DECIMAL(18,2)  COMMENT  '换手率',
  S_DQ_FREETURNOVER  DECIMAL(18,2)  COMMENT  '换手率(基准.自由流通股本)',
  TOT_SHR_TODAY  DECIMAL(18,2)  COMMENT  '当日总股本',
  FLOAT_A_SHR_TODAY  DECIMAL(18,2)  COMMENT  '当日流通股本',
  S_DQ_CLOSE_TODAY  DECIMAL(18,2)  COMMENT  '当日收盘价',
  S_PRICE_DIV_DPS  DECIMAL(18,2)  COMMENT  '股价/每股派息',
  S_PQ_ADJHIGH_52W  DECIMAL(18,2)  COMMENT  '52周最高价(复权)',
  S_PQ_ADJLOW_52W  DECIMAL(18,2)  COMMENT  '52周最低价(复权)',
  FREE_SHARES_TODAY  DECIMAL(18,2)  COMMENT  '当日自由流通股本',
  NET_PROFIT_PARENT_COMP_TTM  DECIMAL(18,2)  COMMENT  '归属母公司净利润(TTM)',
  NET_PROFIT_PARENT_COMP_LYR  DECIMAL(18,2)  COMMENT  '归属母公司净利润(LYR)',
  NET_ASSETS_TODAY  DECIMAL(18,2)  COMMENT  '当日净资产',
  NET_CASH_FLOWS_OPER_ACT_TTM  DECIMAL(18,2)  COMMENT  '经营活动产生的现金流量净额(TTM)',
  NET_CASH_FLOWS_OPER_ACT_LYR  DECIMAL(18,2)  COMMENT  '经营活动产生的现金流量净额(LYR)',
  OPER_REV_TTM  DECIMAL(18,2)  COMMENT  '营业收入(TTM)',
  OPER_REV_LYR  DECIMAL(18,2)  COMMENT  '营业收入(LYR)',
  NET_INCR_CASH_CASH_EQU_TTM  DECIMAL(18,2)  COMMENT  '现金及现金等价物净增加额(TTM)',
  NET_INCR_CASH_CASH_EQU_LYR  DECIMAL(18,2)  COMMENT  '现金及现金等价物净增加额(LYR)',
  UP_DOWN_LIMIT_STATUS  DECIMAL(18,2)  COMMENT  '涨跌停状态',
  LOWEST_HIGHEST_STATUS  DECIMAL(18,2)  COMMENT  '最高最低价状态',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国A股日行情估值指标'
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
                                   , TRADE_DT
                                   , CRNCY_CODE
                                   , S_VAL_MV
                                   , S_DQ_MV
                                   , S_PQ_HIGH_52W_
                                   , S_PQ_LOW_52W_
                                   , S_VAL_PE
                                   , S_VAL_PB_NEW
                                   , S_VAL_PE_TTM
                                   , S_VAL_PCF_OCF
                                   , S_VAL_PCF_OCFTTM
                                   , S_VAL_PCF_NCF
                                   , S_VAL_PCF_NCFTTM
                                   , S_VAL_PS
                                   , S_VAL_PS_TTM
                                   , S_DQ_TURN
                                   , S_DQ_FREETURNOVER
                                   , TOT_SHR_TODAY
                                   , FLOAT_A_SHR_TODAY
                                   , S_DQ_CLOSE_TODAY
                                   , S_PRICE_DIV_DPS
                                   , S_PQ_ADJHIGH_52W
                                   , S_PQ_ADJLOW_52W
                                   , FREE_SHARES_TODAY
                                   , NET_PROFIT_PARENT_COMP_TTM
                                   , NET_PROFIT_PARENT_COMP_LYR
                                   , NET_ASSETS_TODAY
                                   , NET_CASH_FLOWS_OPER_ACT_TTM
                                   , NET_CASH_FLOWS_OPER_ACT_LYR
                                   , OPER_REV_TTM
                                   , OPER_REV_LYR
                                   , NET_INCR_CASH_CASH_EQU_TTM
                                   , NET_INCR_CASH_CASH_EQU_LYR
                                   , UP_DOWN_LIMIT_STATUS
                                   , LOWEST_HIGHEST_STATUS
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.ASHAREEODDERIVATIVEINDICATOR
                                WHERE TRADE_DT between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "S_INFO_WINDCODE", "type": "STRING"}, {"name": "TRADE_DT", "type": "STRING"}, {"name": "CRNCY_CODE", "type": "STRING"}, {"name": "S_VAL_MV", "type": "DOUBLE"}, {"name": "S_DQ_MV", "type": "DOUBLE"}, {"name": "S_PQ_HIGH_52W_", "type": "DOUBLE"}, {"name": "S_PQ_LOW_52W_", "type": "DOUBLE"}, {"name": "S_VAL_PE", "type": "DOUBLE"}, {"name": "S_VAL_PB_NEW", "type": "DOUBLE"}, {"name": "S_VAL_PE_TTM", "type": "DOUBLE"}, {"name": "S_VAL_PCF_OCF", "type": "DOUBLE"}, {"name": "S_VAL_PCF_OCFTTM", "type": "DOUBLE"}, {"name": "S_VAL_PCF_NCF", "type": "DOUBLE"}, {"name": "S_VAL_PCF_NCFTTM", "type": "DOUBLE"}, {"name": "S_VAL_PS", "type": "DOUBLE"}, {"name": "S_VAL_PS_TTM", "type": "DOUBLE"}, {"name": "S_DQ_TURN", "type": "DOUBLE"}, {"name": "S_DQ_FREETURNOVER", "type": "DOUBLE"}, {"name": "TOT_SHR_TODAY", "type": "DOUBLE"}, {"name": "FLOAT_A_SHR_TODAY", "type": "DOUBLE"}, {"name": "S_DQ_CLOSE_TODAY", "type": "DOUBLE"}, {"name": "S_PRICE_DIV_DPS", "type": "DOUBLE"}, {"name": "S_PQ_ADJHIGH_52W", "type": "DOUBLE"}, {"name": "S_PQ_ADJLOW_52W", "type": "DOUBLE"}, {"name": "FREE_SHARES_TODAY", "type": "DOUBLE"}, {"name": "NET_PROFIT_PARENT_COMP_TTM", "type": "DOUBLE"}, {"name": "NET_PROFIT_PARENT_COMP_LYR", "type": "DOUBLE"}, {"name": "NET_ASSETS_TODAY", "type": "DOUBLE"}, {"name": "NET_CASH_FLOWS_OPER_ACT_TTM", "type": "DOUBLE"}, {"name": "NET_CASH_FLOWS_OPER_ACT_LYR", "type": "DOUBLE"}, {"name": "OPER_REV_TTM", "type": "DOUBLE"}, {"name": "OPER_REV_LYR", "type": "DOUBLE"}, {"name": "NET_INCR_CASH_CASH_EQU_TTM", "type": "DOUBLE"}, {"name": "NET_INCR_CASH_CASH_EQU_LYR", "type": "DOUBLE"}, {"name": "UP_DOWN_LIMIT_STATUS", "type": "DOUBLE"}, {"name": "LOWEST_HIGHEST_STATUS", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_ashareeodderivativeindicator_ptd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_ashareeodderivativeindicator_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_ashareeodderivativeindicator_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_ashareeodderivativeindicator_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_ashareeodderivativeindicator_ptd_tmp.json

inceptor_beeline "
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD PARTITION(P_DT)
SELECT
       OBJECT_ID
     , S_INFO_WINDCODE
     , TRADE_DT
     , CRNCY_CODE
     , S_VAL_MV
     , S_DQ_MV
     , S_PQ_HIGH_52W_
     , S_PQ_LOW_52W_
     , S_VAL_PE
     , S_VAL_PB_NEW
     , S_VAL_PE_TTM
     , S_VAL_PCF_OCF
     , S_VAL_PCF_OCFTTM
     , S_VAL_PCF_NCF
     , S_VAL_PCF_NCFTTM
     , S_VAL_PS
     , S_VAL_PS_TTM
     , S_DQ_TURN
     , S_DQ_FREETURNOVER
     , TOT_SHR_TODAY
     , FLOAT_A_SHR_TODAY
     , S_DQ_CLOSE_TODAY
     , S_PRICE_DIV_DPS
     , S_PQ_ADJHIGH_52W
     , S_PQ_ADJLOW_52W
     , FREE_SHARES_TODAY
     , NET_PROFIT_PARENT_COMP_TTM
     , NET_PROFIT_PARENT_COMP_LYR
     , NET_ASSETS_TODAY
     , NET_CASH_FLOWS_OPER_ACT_TTM
     , NET_CASH_FLOWS_OPER_ACT_LYR
     , OPER_REV_TTM
     , OPER_REV_LYR
     , NET_INCR_CASH_CASH_EQU_TTM
     , NET_INCR_CASH_CASH_EQU_LYR
     , UP_DOWN_LIMIT_STATUS
     , LOWEST_HIGHEST_STATUS
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , TRADE_DT P_DT
  FROM ODS_XDAY_WIND.ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD失败"
      exit 1
   else
      echo "插入到ODS_WIND_ASHAREEODDERIVATIVEINDICATOR_PTD成功"
      exit 0
   fi
fi
