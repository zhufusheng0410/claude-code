#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUETERM_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUETERM_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  COUPONRATETERM  STRING  COMMENT  '利率及付息条款',
  COUPRATECOMPTERM  STRING  COMMENT  '利息补偿条款',
  INITIALCPCONFIRMTERM  STRING  COMMENT  '初始转股价确定条款',
  CPADJUSTMENTTERM  STRING  COMMENT  '转股价格调整条款',
  CPREVISIONTERM  STRING  COMMENT  '转股价格修正条款',
  REDEEMTERM  STRING  COMMENT  '赎回条款',
  SELLBACKTERM  STRING  COMMENT  '回售条款',
  FROCECONVERTTERM  STRING  COMMENT  '强制性转股条款',
  DEALINGREMAINCBTERM  STRING  COMMENT  '转换余股处理条款',
  CYDIVIATTRTERM  STRING  COMMENT  '转换年度股利归属条款',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  CONBREDEEMTERM  STRING  COMMENT  '可转债到期赎回条款',
  INSERTTIME  STRING  COMMENT  '发布时间',
  PREFPLASCHEDULETERM  STRING  COMMENT  '向原股东配售安排条款',
  CONVERSIONPERIODTERM  STRING  COMMENT  '转换期条款'
)
COMMENT '可转债发行条款'
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
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , COUPONRATETERM
                                   , COUPRATECOMPTERM
                                   , INITIALCPCONFIRMTERM
                                   , CPADJUSTMENTTERM
                                   , CPREVISIONTERM
                                   , REDEEMTERM
                                   , SELLBACKTERM
                                   , FROCECONVERTTERM
                                   , DEALINGREMAINCBTERM
                                   , CYDIVIATTRTERM
                                   , UPDATETIME
                                   , JSID
                                   , CONBREDEEMTERM
                                   , INSERTTIME
                                   , PREFPLASCHEDULETERM
                                   , CONVERSIONPERIODTERM
                                FROM ${jy_src_schema}.BOND_CONBDISSUETERM"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "COUPONRATETERM", "type": "STRING"}, {"name": "COUPRATECOMPTERM", "type": "STRING"}, {"name": "INITIALCPCONFIRMTERM", "type": "STRING"}, {"name": "CPADJUSTMENTTERM", "type": "STRING"}, {"name": "CPREVISIONTERM", "type": "STRING"}, {"name": "REDEEMTERM", "type": "STRING"}, {"name": "SELLBACKTERM", "type": "STRING"}, {"name": "FROCECONVERTTERM", "type": "STRING"}, {"name": "DEALINGREMAINCBTERM", "type": "STRING"}, {"name": "CYDIVIATTRTERM", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "CONBREDEEMTERM", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "PREFPLASCHEDULETERM", "type": "STRING"}, {"name": "CONVERSIONPERIODTERM", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_conbdissueterm_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_conbdissueterm_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_conbdissueterm_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_conbdissueterm_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CONBDISSUETERM_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CONBDISSUETERM_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_conbdissueterm_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUETERM_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , COUPONRATETERM
     , COUPRATECOMPTERM
     , INITIALCPCONFIRMTERM
     , CPADJUSTMENTTERM
     , CPREVISIONTERM
     , REDEEMTERM
     , SELLBACKTERM
     , FROCECONVERTTERM
     , DEALINGREMAINCBTERM
     , CYDIVIATTRTERM
     , UPDATETIME
     , JSID
     , CONBREDEEMTERM
     , INSERTTIME
     , PREFPLASCHEDULETERM
     , CONVERSIONPERIODTERM
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUETERM_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDISSUETERM_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CONBDISSUETERM_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CONBDISSUETERM_PFD成功"
      exit 0
   fi
fi
