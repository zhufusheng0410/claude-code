#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CASHFLOW_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CASHFLOW_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  CASHFLOWTYPE  STRING  COMMENT  '现金流类型',
  CASHFLOWTYPEDESC  STRING  COMMENT  '现金流类型描述',
  VALUEBEGINDATE  STRING  COMMENT  '计息起始日期',
  VALUEENDDATE  STRING  COMMENT  '计息截止日期',
  PAYMENTDATE  STRING  COMMENT  '利息支付起始日',
  REGDATE  STRING  COMMENT  '权益登记日',
  EXDIVIDATE  STRING  COMMENT  '除权除息日',
  INTERESTPER  DECIMAL(27,12)  COMMENT  '每百元面额付息(元)',
  PAYMENTPER  DECIMAL(27,12)  COMMENT  '每百元面额兑付现金',
  INTERESTTAXRATE  DECIMAL(18,6)  COMMENT  '利息税率',
  TOTALSIZE  DECIMAL(18,6)  COMMENT  '总规模(百万元)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  CASHFLOW  DECIMAL(27,12)  COMMENT  '每百元现金流(元)',
  INSTALMENTREPAYTYPE  STRING  COMMENT  '分期偿还类型',
  NETPAIDPRINCIPAL  DECIMAL(19,12)  COMMENT  '提前兑付净价',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '债券现金流'
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
                                   , CASHFLOWTYPE
                                   , CASHFLOWTYPEDESC
                                   , VALUEBEGINDATE
                                   , VALUEENDDATE
                                   , PAYMENTDATE
                                   , REGDATE
                                   , EXDIVIDATE
                                   , INTERESTPER
                                   , PAYMENTPER
                                   , INTERESTTAXRATE
                                   , TOTALSIZE
                                   , UPDATETIME
                                   , JSID
                                   , CASHFLOW
                                   , INSTALMENTREPAYTYPE
                                   , NETPAIDPRINCIPAL
                                   , INSERTTIME
                                FROM ${jy_src_schema}.BOND_CASHFLOW"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "CASHFLOWTYPE", "type": "DOUBLE"}, {"name": "CASHFLOWTYPEDESC", "type": "STRING"}, {"name": "VALUEBEGINDATE", "type": "STRING"}, {"name": "VALUEENDDATE", "type": "STRING"}, {"name": "PAYMENTDATE", "type": "STRING"}, {"name": "REGDATE", "type": "STRING"}, {"name": "EXDIVIDATE", "type": "STRING"}, {"name": "INTERESTPER", "type": "DOUBLE"}, {"name": "PAYMENTPER", "type": "DOUBLE"}, {"name": "INTERESTTAXRATE", "type": "DOUBLE"}, {"name": "TOTALSIZE", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "CASHFLOW", "type": "DOUBLE"}, {"name": "INSTALMENTREPAYTYPE", "type": "DOUBLE"}, {"name": "NETPAIDPRINCIPAL", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_cashflow_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_cashflow_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_cashflow_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_cashflow_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CASHFLOW_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CASHFLOW_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_cashflow_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CASHFLOW_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , CASHFLOWTYPE
     , CASHFLOWTYPEDESC
     , VALUEBEGINDATE
     , VALUEENDDATE
     , PAYMENTDATE
     , REGDATE
     , EXDIVIDATE
     , INTERESTPER
     , PAYMENTPER
     , INTERESTTAXRATE
     , TOTALSIZE
     , UPDATETIME
     , JSID
     , CASHFLOW
     , INSTALMENTREPAYTYPE
     , NETPAIDPRINCIPAL
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CASHFLOW_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CASHFLOW_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CASHFLOW_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CASHFLOW_PFD成功"
      exit 0
   fi
fi
