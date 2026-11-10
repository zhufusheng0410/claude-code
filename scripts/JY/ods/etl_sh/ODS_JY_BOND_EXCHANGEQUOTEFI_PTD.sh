#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_EXCHANGEQUOTEFI_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_EXCHANGEQUOTEFI_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  TRADINGDAY  STRING  COMMENT  '交易日',
  ACCRUEDINTEREST  DECIMAL(18,8)  COMMENT  '每百元面值应计利息(元)',
  PREVCLOSENETPRICE  DECIMAL(19,4)  COMMENT  '净价昨收盘(元)',
  OPENNETPRICE  DECIMAL(19,4)  COMMENT  '净价开盘价(元)',
  HIGHNETPRICE  DECIMAL(19,4)  COMMENT  '净价最高价(元)',
  LOWNETPRICE  DECIMAL(19,4)  COMMENT  '净价最低价(元)',
  CLOSENETPRICE  DECIMAL(19,4)  COMMENT  '净价收盘价(元)',
  AVGNETPRICE  DECIMAL(19,4)  COMMENT  '净价均价(元)',
  CHANGEPCT  DECIMAL(18,6)  COMMENT  '涨跌幅',
  NPVIBRATIONRANGE  DECIMAL(18,6)  COMMENT  '净价振幅(%)',
  PREVCLOSEDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价昨收盘(元)',
  OPENDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价开盘价(元)',
  HIGHDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价最高价(元)',
  LOWDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价最低价(元)',
  CLOSEDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价收盘价(元)',
  AVGDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价均价(元)',
  CHANGEPCTDT  DECIMAL(18,6)  COMMENT  '全价涨跌幅',
  DPVIBRATIONRANGE  DECIMAL(18,6)  COMMENT  '全价振幅(%)',
  TURNOVERRATE  DECIMAL(18,6)  COMMENT  '换手率(%)',
  TURNOVERVOLUME  DECIMAL(19,4)  COMMENT  '成交量(股)',
  TURNOVERVALUE  DECIMAL(19,4)  COMMENT  '成交金额(元)',
  TURNOVERDEALS  DECIMAL(19,4)  COMMENT  '成交笔数(笔)',
  YRMAT  STRING  COMMENT  '债券剩余年限(年)',
  YTM_OP  DECIMAL(30,8)  COMMENT  '开盘价到期收益率(%)',
  DURATION_OP  DECIMAL(30,8)  COMMENT  '开盘价麦氏久期',
  MODIFIEDDURATION_OP  DECIMAL(30,8)  COMMENT  '开盘价修正久期',
  CONVEXITY_OP  DECIMAL(30,8)  COMMENT  '开盘价凸度',
  YTM_HI  DECIMAL(30,8)  COMMENT  '最高价到期收益率(%)',
  DURATION_HI  DECIMAL(30,8)  COMMENT  '最高价麦氏久期',
  MODIFIEDDURATION_HI  DECIMAL(30,8)  COMMENT  '最高价修正久期',
  CONVEXITY_HI  DECIMAL(30,8)  COMMENT  '最高价凸度',
  YTM_LO  DECIMAL(30,8)  COMMENT  '最低价到期收益率(%)',
  DURATION_LO  DECIMAL(30,8)  COMMENT  '最低价麦氏久期',
  MODIFIEDDURATION_LO  DECIMAL(30,8)  COMMENT  '最低价修正久期',
  CONVEXITY_LO  DECIMAL(30,8)  COMMENT  '最低价凸度',
  YTM_CL  DECIMAL(30,8)  COMMENT  '收盘价到期收益率(%)',
  DURATION_CL  DECIMAL(30,8)  COMMENT  '收盘价麦氏久期',
  MODIFIEDDURATION_CL  DECIMAL(30,8)  COMMENT  '收盘价修正久期',
  CONVEXITY_CL  DECIMAL(30,8)  COMMENT  '收盘价凸度',
  YTM_AVG  DECIMAL(30,8)  COMMENT  '均价到期收益率(%)',
  DURATION_AVG  DECIMAL(30,8)  COMMENT  '均价麦氏久期',
  MODIFIEDDURATION_AVG  DECIMAL(30,8)  COMMENT  '均价修正久期',
  CONVEXITY_AVG  DECIMAL(30,8)  COMMENT  '均价凸度',
  ROI  DECIMAL(19,4)  COMMENT  '利息回报(元)',
  ROP  DECIMAL(19,4)  COMMENT  '价格回报(元)',
  TR  DECIMAL(19,4)  COMMENT  '总回报(元)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  WEIGHTEDNETPRICE  DECIMAL(19,4)  COMMENT  '净价加权价(元)',
  WEIGHTEDDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价加权价(元)',
  YTM_WAP  DECIMAL(30,8)  COMMENT  '加权价到期收益率(%)'
)
COMMENT '交易所固定收益证券平台债券行情'
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
                                   , INNERCODE
                                   , TO_CHAR(TRADINGDAY,'YYYYMMDD') TRADINGDAY
                                   , ACCRUEDINTEREST
                                   , PREVCLOSENETPRICE
                                   , OPENNETPRICE
                                   , HIGHNETPRICE
                                   , LOWNETPRICE
                                   , CLOSENETPRICE
                                   , AVGNETPRICE
                                   , CHANGEPCT
                                   , NPVIBRATIONRANGE
                                   , PREVCLOSEDIRTYPRICE
                                   , OPENDIRTYPRICE
                                   , HIGHDIRTYPRICE
                                   , LOWDIRTYPRICE
                                   , CLOSEDIRTYPRICE
                                   , AVGDIRTYPRICE
                                   , CHANGEPCTDT
                                   , DPVIBRATIONRANGE
                                   , TURNOVERRATE
                                   , TURNOVERVOLUME
                                   , TURNOVERVALUE
                                   , TURNOVERDEALS
                                   , YRMAT
                                   , YTM_OP
                                   , DURATION_OP
                                   , MODIFIEDDURATION_OP
                                   , CONVEXITY_OP
                                   , YTM_HI
                                   , DURATION_HI
                                   , MODIFIEDDURATION_HI
                                   , CONVEXITY_HI
                                   , YTM_LO
                                   , DURATION_LO
                                   , MODIFIEDDURATION_LO
                                   , CONVEXITY_LO
                                   , YTM_CL
                                   , DURATION_CL
                                   , MODIFIEDDURATION_CL
                                   , CONVEXITY_CL
                                   , YTM_AVG
                                   , DURATION_AVG
                                   , MODIFIEDDURATION_AVG
                                   , CONVEXITY_AVG
                                   , ROI
                                   , ROP
                                   , TR
                                   , UPDATETIME
                                   , JSID
                                   , WEIGHTEDNETPRICE
                                   , WEIGHTEDDIRTYPRICE
                                   , YTM_WAP
                                FROM ${jy_src_schema}.BOND_EXCHANGEQUOTEFI
                                WHERE TRADINGDAY between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "ACCRUEDINTEREST", "type": "DOUBLE"}, {"name": "PREVCLOSENETPRICE", "type": "DOUBLE"}, {"name": "OPENNETPRICE", "type": "DOUBLE"}, {"name": "HIGHNETPRICE", "type": "DOUBLE"}, {"name": "LOWNETPRICE", "type": "DOUBLE"}, {"name": "CLOSENETPRICE", "type": "DOUBLE"}, {"name": "AVGNETPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCT", "type": "DOUBLE"}, {"name": "NPVIBRATIONRANGE", "type": "DOUBLE"}, {"name": "PREVCLOSEDIRTYPRICE", "type": "DOUBLE"}, {"name": "OPENDIRTYPRICE", "type": "DOUBLE"}, {"name": "HIGHDIRTYPRICE", "type": "DOUBLE"}, {"name": "LOWDIRTYPRICE", "type": "DOUBLE"}, {"name": "CLOSEDIRTYPRICE", "type": "DOUBLE"}, {"name": "AVGDIRTYPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCTDT", "type": "DOUBLE"}, {"name": "DPVIBRATIONRANGE", "type": "DOUBLE"}, {"name": "TURNOVERRATE", "type": "DOUBLE"}, {"name": "TURNOVERVOLUME", "type": "DOUBLE"}, {"name": "TURNOVERVALUE", "type": "DOUBLE"}, {"name": "TURNOVERDEALS", "type": "DOUBLE"}, {"name": "YRMAT", "type": "STRING"}, {"name": "YTM_OP", "type": "DOUBLE"}, {"name": "DURATION_OP", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_OP", "type": "DOUBLE"}, {"name": "CONVEXITY_OP", "type": "DOUBLE"}, {"name": "YTM_HI", "type": "DOUBLE"}, {"name": "DURATION_HI", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_HI", "type": "DOUBLE"}, {"name": "CONVEXITY_HI", "type": "DOUBLE"}, {"name": "YTM_LO", "type": "DOUBLE"}, {"name": "DURATION_LO", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_LO", "type": "DOUBLE"}, {"name": "CONVEXITY_LO", "type": "DOUBLE"}, {"name": "YTM_CL", "type": "DOUBLE"}, {"name": "DURATION_CL", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_CL", "type": "DOUBLE"}, {"name": "CONVEXITY_CL", "type": "DOUBLE"}, {"name": "YTM_AVG", "type": "DOUBLE"}, {"name": "DURATION_AVG", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_AVG", "type": "DOUBLE"}, {"name": "CONVEXITY_AVG", "type": "DOUBLE"}, {"name": "ROI", "type": "DOUBLE"}, {"name": "ROP", "type": "DOUBLE"}, {"name": "TR", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "WEIGHTEDNETPRICE", "type": "DOUBLE"}, {"name": "WEIGHTEDDIRTYPRICE", "type": "DOUBLE"}, {"name": "YTM_WAP", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_exchangequotefi_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_exchangequotefi_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_exchangequotefi_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_exchangequotefi_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_EXCHANGEQUOTEFI_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_EXCHANGEQUOTEFI_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_exchangequotefi_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_EXCHANGEQUOTEFI_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , TRADINGDAY
     , ACCRUEDINTEREST
     , PREVCLOSENETPRICE
     , OPENNETPRICE
     , HIGHNETPRICE
     , LOWNETPRICE
     , CLOSENETPRICE
     , AVGNETPRICE
     , CHANGEPCT
     , NPVIBRATIONRANGE
     , PREVCLOSEDIRTYPRICE
     , OPENDIRTYPRICE
     , HIGHDIRTYPRICE
     , LOWDIRTYPRICE
     , CLOSEDIRTYPRICE
     , AVGDIRTYPRICE
     , CHANGEPCTDT
     , DPVIBRATIONRANGE
     , TURNOVERRATE
     , TURNOVERVOLUME
     , TURNOVERVALUE
     , TURNOVERDEALS
     , YRMAT
     , YTM_OP
     , DURATION_OP
     , MODIFIEDDURATION_OP
     , CONVEXITY_OP
     , YTM_HI
     , DURATION_HI
     , MODIFIEDDURATION_HI
     , CONVEXITY_HI
     , YTM_LO
     , DURATION_LO
     , MODIFIEDDURATION_LO
     , CONVEXITY_LO
     , YTM_CL
     , DURATION_CL
     , MODIFIEDDURATION_CL
     , CONVEXITY_CL
     , YTM_AVG
     , DURATION_AVG
     , MODIFIEDDURATION_AVG
     , CONVEXITY_AVG
     , ROI
     , ROP
     , TR
     , UPDATETIME
     , JSID
     , WEIGHTEDNETPRICE
     , WEIGHTEDDIRTYPRICE
     , YTM_WAP
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(TRADINGDAY,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_BOND_EXCHANGEQUOTEFI_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_EXCHANGEQUOTEFI_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_EXCHANGEQUOTEFI_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_EXCHANGEQUOTEFI_PTD成功"
      exit 0
   fi
fi
