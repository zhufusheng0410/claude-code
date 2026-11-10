#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_RMBINTERESTRATE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_RMBINTERESTRATE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  SOURCES  STRING  COMMENT  '信息来源',
  ADJUSTDATE  STRING  COMMENT  '调整日期',
  DEMANDDEPOSITS  DECIMAL(9,6)  COMMENT  '#货币活期存款(百万元)',
  TIMEDEPOSIT3M  DECIMAL(9,6)  COMMENT  '三个月',
  TIMEDEPOSIT6M  DECIMAL(9,6)  COMMENT  '半年',
  TIMEDEPOSIT1Y  DECIMAL(9,6)  COMMENT  '一年',
  TIMEDEPOSIT2Y  DECIMAL(9,6)  COMMENT  '二年',
  TIMEDEPOSIT3Y  DECIMAL(9,6)  COMMENT  '三年',
  TIMEDEPOSIT5Y  DECIMAL(9,6)  COMMENT  '五年',
  OD1Y  DECIMAL(9,6)  COMMENT  '一年',
  OD3Y  DECIMAL(9,6)  COMMENT  '三年',
  OD5Y  DECIMAL(9,6)  COMMENT  '五年',
  ODOPTIONALTIMEORDEMAND  STRING  COMMENT  '定活两便(文字)',
  ODCONTRACTUALDEPOSITS  DECIMAL(9,6)  COMMENT  '协定存款',
  NOTICEDEPOSITS1D  DECIMAL(9,6)  COMMENT  '一天',
  NOTICEDEPOSITS7D  DECIMAL(9,6)  COMMENT  '七天',
  STBELOW6MONTHS  DECIMAL(9,6)  COMMENT  '六个月以内',
  ST6TO12MONTHS  DECIMAL(9,6)  COMMENT  '六个月至一年',
  MLT1TO3YEARS  DECIMAL(9,6)  COMMENT  '一至三年',
  MLT3TO5YEARS  DECIMAL(9,6)  COMMENT  '三至五年',
  MLT5PLUSYEARS  DECIMAL(9,6)  COMMENT  '五年以上',
  DISCOUNT  STRING  COMMENT  '贴现(元)',
  IHAF5YBELOW  DECIMAL(9,6)  COMMENT  '五年以下',
  IHAF5YABOVE  DECIMAL(9,6)  COMMENT  '五年以上',
  CBANKIHAF6MBELOW  DECIMAL(9,6)  COMMENT  '6个月以内',
  CBANKIHAF6MTO1Y  DECIMAL(9,6)  COMMENT  '6个月至一年',
  CBANKIHAF1TO3Y  DECIMAL(9,6)  COMMENT  '一至三年',
  CBANKIHAF3TO5Y  DECIMAL(9,6)  COMMENT  '三至五年',
  CBANKIHAF5YABOVE  DECIMAL(9,6)  COMMENT  '五年以上',
  LOANTOWELFAREENTERPRISE  DECIMAL(9,6)  COMMENT  '民政部门福利工厂贷款',
  LOANTODEVELOPINGAREAS  DECIMAL(9,6)  COMMENT  '老少边穷发展经济贷款',
  LOANTOPOORCOUNTY  DECIMAL(9,6)  COMMENT  '贫困县办工业贷款',
  LOANTONATIONTRADE  DECIMAL(9,6)  COMMENT  '民族贸易及民族用品生产贷款',
  DISCOUNTLOANTOPA  DECIMAL(9,6)  COMMENT  '扶贫贴息贷款(含牧区)',
  RESERVEDEPOSIT  DECIMAL(9,6)  COMMENT  '准备金存款利率',
  EXCESSRESERVEDEPOSIT  DECIMAL(9,6)  COMMENT  '超额准备金存款利率',
  RELOAN20D  DECIMAL(9,6)  COMMENT  '二十天',
  RELOAN3M  DECIMAL(9,6)  COMMENT  '三个月',
  RELOAN6M  DECIMAL(9,6)  COMMENT  '六个月',
  RELOAN1Y  DECIMAL(9,6)  COMMENT  '一年',
  REDISCOUNT  DECIMAL(9,6)  COMMENT  '再贴现利率',
  REMARKS  STRING  COMMENT  '备注',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '人民币利率表'
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
                                   , SOURCES
                                   , ADJUSTDATE
                                   , DEMANDDEPOSITS
                                   , TIMEDEPOSIT3M
                                   , TIMEDEPOSIT6M
                                   , TIMEDEPOSIT1Y
                                   , TIMEDEPOSIT2Y
                                   , TIMEDEPOSIT3Y
                                   , TIMEDEPOSIT5Y
                                   , OD1Y
                                   , OD3Y
                                   , OD5Y
                                   , ODOPTIONALTIMEORDEMAND
                                   , ODCONTRACTUALDEPOSITS
                                   , NOTICEDEPOSITS1D
                                   , NOTICEDEPOSITS7D
                                   , STBELOW6MONTHS
                                   , ST6TO12MONTHS
                                   , MLT1TO3YEARS
                                   , MLT3TO5YEARS
                                   , MLT5PLUSYEARS
                                   , DISCOUNT
                                   , IHAF5YBELOW
                                   , IHAF5YABOVE
                                   , CBANKIHAF6MBELOW
                                   , CBANKIHAF6MTO1Y
                                   , CBANKIHAF1TO3Y
                                   , CBANKIHAF3TO5Y
                                   , CBANKIHAF5YABOVE
                                   , LOANTOWELFAREENTERPRISE
                                   , LOANTODEVELOPINGAREAS
                                   , LOANTOPOORCOUNTY
                                   , LOANTONATIONTRADE
                                   , DISCOUNTLOANTOPA
                                   , RESERVEDEPOSIT
                                   , EXCESSRESERVEDEPOSIT
                                   , RELOAN20D
                                   , RELOAN3M
                                   , RELOAN6M
                                   , RELOAN1Y
                                   , REDISCOUNT
                                   , REMARKS
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.BOND_RMBINTERESTRATE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "SOURCES", "type": "STRING"}, {"name": "ADJUSTDATE", "type": "STRING"}, {"name": "DEMANDDEPOSITS", "type": "DOUBLE"}, {"name": "TIMEDEPOSIT3M", "type": "DOUBLE"}, {"name": "TIMEDEPOSIT6M", "type": "DOUBLE"}, {"name": "TIMEDEPOSIT1Y", "type": "DOUBLE"}, {"name": "TIMEDEPOSIT2Y", "type": "DOUBLE"}, {"name": "TIMEDEPOSIT3Y", "type": "DOUBLE"}, {"name": "TIMEDEPOSIT5Y", "type": "DOUBLE"}, {"name": "OD1Y", "type": "DOUBLE"}, {"name": "OD3Y", "type": "DOUBLE"}, {"name": "OD5Y", "type": "DOUBLE"}, {"name": "ODOPTIONALTIMEORDEMAND", "type": "STRING"}, {"name": "ODCONTRACTUALDEPOSITS", "type": "DOUBLE"}, {"name": "NOTICEDEPOSITS1D", "type": "DOUBLE"}, {"name": "NOTICEDEPOSITS7D", "type": "DOUBLE"}, {"name": "STBELOW6MONTHS", "type": "DOUBLE"}, {"name": "ST6TO12MONTHS", "type": "DOUBLE"}, {"name": "MLT1TO3YEARS", "type": "DOUBLE"}, {"name": "MLT3TO5YEARS", "type": "DOUBLE"}, {"name": "MLT5PLUSYEARS", "type": "DOUBLE"}, {"name": "DISCOUNT", "type": "STRING"}, {"name": "IHAF5YBELOW", "type": "DOUBLE"}, {"name": "IHAF5YABOVE", "type": "DOUBLE"}, {"name": "CBANKIHAF6MBELOW", "type": "DOUBLE"}, {"name": "CBANKIHAF6MTO1Y", "type": "DOUBLE"}, {"name": "CBANKIHAF1TO3Y", "type": "DOUBLE"}, {"name": "CBANKIHAF3TO5Y", "type": "DOUBLE"}, {"name": "CBANKIHAF5YABOVE", "type": "DOUBLE"}, {"name": "LOANTOWELFAREENTERPRISE", "type": "DOUBLE"}, {"name": "LOANTODEVELOPINGAREAS", "type": "DOUBLE"}, {"name": "LOANTOPOORCOUNTY", "type": "DOUBLE"}, {"name": "LOANTONATIONTRADE", "type": "DOUBLE"}, {"name": "DISCOUNTLOANTOPA", "type": "DOUBLE"}, {"name": "RESERVEDEPOSIT", "type": "DOUBLE"}, {"name": "EXCESSRESERVEDEPOSIT", "type": "DOUBLE"}, {"name": "RELOAN20D", "type": "DOUBLE"}, {"name": "RELOAN3M", "type": "DOUBLE"}, {"name": "RELOAN6M", "type": "DOUBLE"}, {"name": "RELOAN1Y", "type": "DOUBLE"}, {"name": "REDISCOUNT", "type": "DOUBLE"}, {"name": "REMARKS", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_rmbinterestrate_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_rmbinterestrate_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_rmbinterestrate_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_rmbinterestrate_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_RMBINTERESTRATE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_RMBINTERESTRATE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_rmbinterestrate_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_RMBINTERESTRATE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INFOPUBLDATE
     , SOURCES
     , ADJUSTDATE
     , DEMANDDEPOSITS
     , TIMEDEPOSIT3M
     , TIMEDEPOSIT6M
     , TIMEDEPOSIT1Y
     , TIMEDEPOSIT2Y
     , TIMEDEPOSIT3Y
     , TIMEDEPOSIT5Y
     , OD1Y
     , OD3Y
     , OD5Y
     , ODOPTIONALTIMEORDEMAND
     , ODCONTRACTUALDEPOSITS
     , NOTICEDEPOSITS1D
     , NOTICEDEPOSITS7D
     , STBELOW6MONTHS
     , ST6TO12MONTHS
     , MLT1TO3YEARS
     , MLT3TO5YEARS
     , MLT5PLUSYEARS
     , DISCOUNT
     , IHAF5YBELOW
     , IHAF5YABOVE
     , CBANKIHAF6MBELOW
     , CBANKIHAF6MTO1Y
     , CBANKIHAF1TO3Y
     , CBANKIHAF3TO5Y
     , CBANKIHAF5YABOVE
     , LOANTOWELFAREENTERPRISE
     , LOANTODEVELOPINGAREAS
     , LOANTOPOORCOUNTY
     , LOANTONATIONTRADE
     , DISCOUNTLOANTOPA
     , RESERVEDEPOSIT
     , EXCESSRESERVEDEPOSIT
     , RELOAN20D
     , RELOAN3M
     , RELOAN6M
     , RELOAN1Y
     , REDISCOUNT
     , REMARKS
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_RMBINTERESTRATE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_RMBINTERESTRATE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_RMBINTERESTRATE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_RMBINTERESTRATE_PFD成功"
      exit 0
   fi
fi
