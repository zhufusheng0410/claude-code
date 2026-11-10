#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERSJC_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERSJC_PTD_TMP(
  L_FUNDID  STRING  COMMENT  '帐套编号',
  VC_CODE  STRING  COMMENT  '会计科目编码',
  VC_FULLNAME  STRING  COMMENT  '会计科目全路径名称',
  EN_DEBIT  DECIMAL(19,4)  COMMENT  '借方金额',
  EN_CREDIT  DECIMAL(19,4)  COMMENT  '贷方金额',
  EN_FOREIGN  DECIMAL(19,4)  COMMENT  '外币金额',
  EN_QUANTITY  DECIMAL(21,6)  COMMENT  '数量',
  VC_DEPARTMENT  STRING  COMMENT  '部门',
  VC_CASH  STRING  COMMENT  '现金流量',
  VC_INSURANCE  STRING  COMMENT  '险种',
  VC_CHARGE  STRING  COMMENT  '缴费方式',
  VC_BOURSE  STRING  COMMENT  '交易所',
  VC_DAYS  STRING  COMMENT  '天数',
  VC_INVESTACC  STRING  COMMENT  '投资帐户',
  VC_SETTLENO  STRING  COMMENT  '决算号',
  VC_COSTAPPORTION  STRING  COMMENT  '成本分摊',
  L_TZLX  STRING  COMMENT  '投资类型',
  L_ZQNM  DECIMAL(20,0)  COMMENT  '证券内码',
  VC_CODE_HS  STRING  COMMENT  '恒生标准科目',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_TRADEAMO  DECIMAL(19,4)  COMMENT  '本币成交金额',
  EN_FORTRADEAMO  DECIMAL(19,4)  COMMENT  '外币成交金额',
  L_CCHSID  DECIMAL(4,0)  COMMENT  '持仓核算ID',
  L_YEAR  DECIMAL(4,0)  COMMENT  '会计年度',
  L_MONTH  DECIMAL(2,0)  COMMENT  '会计月份',
  L_KIND  STRING  COMMENT  '借贷方向',
  L_KMFX  DECIMAL(4,0)  COMMENT  ''
)
COMMENT '会计结存表'
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_FUNDID
                                   , VC_CODE
                                   , VC_FULLNAME
                                   , EN_DEBIT
                                   , EN_CREDIT
                                   , EN_FOREIGN
                                   , EN_QUANTITY
                                   , VC_DEPARTMENT
                                   , VC_CASH
                                   , VC_INSURANCE
                                   , VC_CHARGE
                                   , VC_BOURSE
                                   , VC_DAYS
                                   , VC_INVESTACC
                                   , VC_SETTLENO
                                   , VC_COSTAPPORTION
                                   , L_TZLX
                                   , L_ZQNM
                                   , VC_CODE_HS
                                   , VC_JSBZ
                                   , EN_TRADEAMO
                                   , EN_FORTRADEAMO
                                   , L_CCHSID
                                   , L_YEAR
                                   , L_MONTH
                                   , L_KIND
                                   , L_KMFX
                                FROM ${hsfa_src_schema}.TVOUCHERSJC
                                WHERE L_YEAR+L_MONTH between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_FUNDID", "type": "DOUBLE"}, {"name": "VC_CODE", "type": "STRING"}, {"name": "VC_FULLNAME", "type": "STRING"}, {"name": "EN_DEBIT", "type": "DOUBLE"}, {"name": "EN_CREDIT", "type": "DOUBLE"}, {"name": "EN_FOREIGN", "type": "DOUBLE"}, {"name": "EN_QUANTITY", "type": "DOUBLE"}, {"name": "VC_DEPARTMENT", "type": "STRING"}, {"name": "VC_CASH", "type": "STRING"}, {"name": "VC_INSURANCE", "type": "STRING"}, {"name": "VC_CHARGE", "type": "STRING"}, {"name": "VC_BOURSE", "type": "STRING"}, {"name": "VC_DAYS", "type": "STRING"}, {"name": "VC_INVESTACC", "type": "STRING"}, {"name": "VC_SETTLENO", "type": "STRING"}, {"name": "VC_COSTAPPORTION", "type": "STRING"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_CODE_HS", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_TRADEAMO", "type": "DOUBLE"}, {"name": "EN_FORTRADEAMO", "type": "DOUBLE"}, {"name": "L_CCHSID", "type": "DOUBLE"}, {"name": "L_YEAR", "type": "DOUBLE"}, {"name": "L_MONTH", "type": "DOUBLE"}, {"name": "L_KIND", "type": "DOUBLE"}, {"name": "L_KMFX", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tvouchersjc_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tvouchersjc_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tvouchersjc_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tvouchersjc_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TVOUCHERSJC_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TVOUCHERSJC_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tvouchersjc_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERSJC_PTD PARTITION(P_DT)
SELECT
       L_FUNDID
     , VC_CODE
     , VC_FULLNAME
     , EN_DEBIT
     , EN_CREDIT
     , EN_FOREIGN
     , EN_QUANTITY
     , VC_DEPARTMENT
     , VC_CASH
     , VC_INSURANCE
     , VC_CHARGE
     , VC_BOURSE
     , VC_DAYS
     , VC_INVESTACC
     , VC_SETTLENO
     , VC_COSTAPPORTION
     , L_TZLX
     , L_ZQNM
     , VC_CODE_HS
     , VC_JSBZ
     , EN_TRADEAMO
     , EN_FORTRADEAMO
     , L_CCHSID
     , L_YEAR
     , L_MONTH
     , L_KIND
     , L_KMFX
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , '${p_end_dt}' P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERSJC_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERSJC_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TVOUCHERSJC_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TVOUCHERSJC_PTD成功"
      exit 0
   fi
fi
