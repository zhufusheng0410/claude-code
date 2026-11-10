#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  SETTLEMENTDATE  STRING  COMMENT  '交割日期',
  PREVNETPRICE  DECIMAL(19,4)  COMMENT  '前期净价(元)',
  PREVWTDAVGPRICECLN  DECIMAL(19,4)  COMMENT  '前期净价均价(元/%)',
  OPENNETPRICE  DECIMAL(19,4)  COMMENT  '净价开盘价(元)',
  HIGHNETPRICE  DECIMAL(19,4)  COMMENT  '净价最高价(元)',
  LOWNETPRICE  DECIMAL(19,4)  COMMENT  '净价最低价(元)',
  CLOSENETPRICE  DECIMAL(19,4)  COMMENT  '净价收盘价(元)',
  WTDAVGNETPRICE  DECIMAL(19,4)  COMMENT  '净价均价(元)',
  CHANGEPCTCLN  DECIMAL(18,6)  COMMENT  '净价涨跌幅(%)',
  NPVIBRATIONRANGE  DECIMAL(18,6)  COMMENT  '净价振幅(%)',
  PREVDIRTYPRICE  DECIMAL(19,4)  COMMENT  '前期全价(元)',
  PREVWTDAVGPRICEDT  DECIMAL(19,4)  COMMENT  '前期全价均价(元/%)',
  OPENDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价开盘价(元)',
  HIGHDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价最高价(元)',
  LOWDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价最低价(元)',
  CLOSEDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价收盘价(元)',
  WTDAVGDIRTYPRICE  DECIMAL(19,4)  COMMENT  '全价均价(元)',
  CHANGEPCTDT  DECIMAL(18,6)  COMMENT  '全价涨跌幅',
  DPVIBRATIONRANGE  DECIMAL(18,6)  COMMENT  '全价振幅(%)',
  TURNOVERRATE  DECIMAL(18,6)  COMMENT  '换手率(%)',
  SETTLEVOL  DECIMAL(19,4)  COMMENT  '债券交割量(元)',
  SETTLEVALUE  DECIMAL(19,4)  COMMENT  '资金清算额(元)',
  TRANSACTNUM  DECIMAL(10,0)  COMMENT  '结算笔数(笔)',
  AVGSETTLEVOLPERTRANSACT  DECIMAL(19,4)  COMMENT  '平均每笔结算金额(元/笔)',
  ACCRINTEREST  DECIMAL(19,4)  COMMENT  '期末应计利息(元)',
  YRMAT  DECIMAL(18,4)  COMMENT  '债券剩余年限(年)',
  AVGYTM  DECIMAL(19,4)  COMMENT  '平均收益率',
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
  SETTLEPRINCIPAL  DECIMAL(18,4)  COMMENT  '债券交割本金额(元)',
  SETTLEMENTDAY  DECIMAL(10,0)  COMMENT  '结算天数(天)',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '银行间债券结算行情'
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
                                   , TO_CHAR(SETTLEMENTDATE,'YYYYMMDD') SETTLEMENTDATE
                                   , PREVNETPRICE
                                   , PREVWTDAVGPRICECLN
                                   , OPENNETPRICE
                                   , HIGHNETPRICE
                                   , LOWNETPRICE
                                   , CLOSENETPRICE
                                   , WTDAVGNETPRICE
                                   , CHANGEPCTCLN
                                   , NPVIBRATIONRANGE
                                   , PREVDIRTYPRICE
                                   , PREVWTDAVGPRICEDT
                                   , OPENDIRTYPRICE
                                   , HIGHDIRTYPRICE
                                   , LOWDIRTYPRICE
                                   , CLOSEDIRTYPRICE
                                   , WTDAVGDIRTYPRICE
                                   , CHANGEPCTDT
                                   , DPVIBRATIONRANGE
                                   , TURNOVERRATE
                                   , SETTLEVOL
                                   , SETTLEVALUE
                                   , TRANSACTNUM
                                   , AVGSETTLEVOLPERTRANSACT
                                   , ACCRINTEREST
                                   , YRMAT
                                   , AVGYTM
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
                                   , SETTLEPRINCIPAL
                                   , SETTLEMENTDAY
                                   , INSERTTIME
                                FROM ${jy_src_schema}.BOND_IBSETTLEMENTQUOTE
                                WHERE SETTLEMENTDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "SETTLEMENTDATE", "type": "STRING"}, {"name": "PREVNETPRICE", "type": "DOUBLE"}, {"name": "PREVWTDAVGPRICECLN", "type": "DOUBLE"}, {"name": "OPENNETPRICE", "type": "DOUBLE"}, {"name": "HIGHNETPRICE", "type": "DOUBLE"}, {"name": "LOWNETPRICE", "type": "DOUBLE"}, {"name": "CLOSENETPRICE", "type": "DOUBLE"}, {"name": "WTDAVGNETPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCTCLN", "type": "DOUBLE"}, {"name": "NPVIBRATIONRANGE", "type": "DOUBLE"}, {"name": "PREVDIRTYPRICE", "type": "DOUBLE"}, {"name": "PREVWTDAVGPRICEDT", "type": "DOUBLE"}, {"name": "OPENDIRTYPRICE", "type": "DOUBLE"}, {"name": "HIGHDIRTYPRICE", "type": "DOUBLE"}, {"name": "LOWDIRTYPRICE", "type": "DOUBLE"}, {"name": "CLOSEDIRTYPRICE", "type": "DOUBLE"}, {"name": "WTDAVGDIRTYPRICE", "type": "DOUBLE"}, {"name": "CHANGEPCTDT", "type": "DOUBLE"}, {"name": "DPVIBRATIONRANGE", "type": "DOUBLE"}, {"name": "TURNOVERRATE", "type": "DOUBLE"}, {"name": "SETTLEVOL", "type": "DOUBLE"}, {"name": "SETTLEVALUE", "type": "DOUBLE"}, {"name": "TRANSACTNUM", "type": "DOUBLE"}, {"name": "AVGSETTLEVOLPERTRANSACT", "type": "DOUBLE"}, {"name": "ACCRINTEREST", "type": "DOUBLE"}, {"name": "YRMAT", "type": "DOUBLE"}, {"name": "AVGYTM", "type": "DOUBLE"}, {"name": "YTM_OP", "type": "DOUBLE"}, {"name": "DURATION_OP", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_OP", "type": "DOUBLE"}, {"name": "CONVEXITY_OP", "type": "DOUBLE"}, {"name": "YTM_HI", "type": "DOUBLE"}, {"name": "DURATION_HI", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_HI", "type": "DOUBLE"}, {"name": "CONVEXITY_HI", "type": "DOUBLE"}, {"name": "YTM_LO", "type": "DOUBLE"}, {"name": "DURATION_LO", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_LO", "type": "DOUBLE"}, {"name": "CONVEXITY_LO", "type": "DOUBLE"}, {"name": "YTM_CL", "type": "DOUBLE"}, {"name": "DURATION_CL", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_CL", "type": "DOUBLE"}, {"name": "CONVEXITY_CL", "type": "DOUBLE"}, {"name": "YTM_AVG", "type": "DOUBLE"}, {"name": "DURATION_AVG", "type": "DOUBLE"}, {"name": "MODIFIEDDURATION_AVG", "type": "DOUBLE"}, {"name": "CONVEXITY_AVG", "type": "DOUBLE"}, {"name": "ROI", "type": "DOUBLE"}, {"name": "ROP", "type": "DOUBLE"}, {"name": "TR", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "SETTLEPRINCIPAL", "type": "DOUBLE"}, {"name": "SETTLEMENTDAY", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_ibsettlementquote_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_ibsettlementquote_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_ibsettlementquote_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_ibsettlementquote_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_ibsettlementquote_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , SETTLEMENTDATE
     , PREVNETPRICE
     , PREVWTDAVGPRICECLN
     , OPENNETPRICE
     , HIGHNETPRICE
     , LOWNETPRICE
     , CLOSENETPRICE
     , WTDAVGNETPRICE
     , CHANGEPCTCLN
     , NPVIBRATIONRANGE
     , PREVDIRTYPRICE
     , PREVWTDAVGPRICEDT
     , OPENDIRTYPRICE
     , HIGHDIRTYPRICE
     , LOWDIRTYPRICE
     , CLOSEDIRTYPRICE
     , WTDAVGDIRTYPRICE
     , CHANGEPCTDT
     , DPVIBRATIONRANGE
     , TURNOVERRATE
     , SETTLEVOL
     , SETTLEVALUE
     , TRANSACTNUM
     , AVGSETTLEVOLPERTRANSACT
     , ACCRINTEREST
     , YRMAT
     , AVGYTM
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
     , SETTLEPRINCIPAL
     , SETTLEMENTDAY
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(SETTLEMENTDATE,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_IBSETTLEMENTQUOTE_PTD成功"
      exit 0
   fi
fi
