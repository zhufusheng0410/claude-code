#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECURRENTS_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECURRENTS_PTD_TMP(
  D_CDATE  STRING  COMMENT  '确认日期',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  C_BUSINFLAG  STRING  COMMENT  '业务代码',
  D_REQUESTDATE  STRING  COMMENT  '申请日期',
  C_REQUESTNO  STRING  COMMENT  '申请编号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  F_OCCURSHARES  DECIMAL(16,2)  COMMENT  '本次发生份额',
  F_OCCURBALANCE  DECIMAL(16,2)  COMMENT  '本次发生金额',
  F_LASTSHARES  DECIMAL(16,2)  COMMENT  '最新总份额',
  F_OCCURFREEZE  DECIMAL(16,2)  COMMENT  '本次冻结发生额',
  F_LASTFREEZESHARE  DECIMAL(16,2)  COMMENT  '本次冻结余额',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_OUTBUSINFLAG  STRING  COMMENT  '外部业务标志',
  L_SERIALNO  DECIMAL(16,0)  COMMENT  '申请序号',
  C_ADJUSTCAUSE  STRING  COMMENT  '份额调整原因',
  C_SECONDACCO  STRING  COMMENT  '强增账户的二级账号',
  C_SPECIALACCOFLAG  STRING  COMMENT  '特殊代码',
  C_PARTNERID  STRING  COMMENT  '',
  C_CREDITACCOFLAG  STRING  COMMENT  '',
  D_SHAREVALIDDATE  STRING  COMMENT  '',
  C_FORCEREDEMPTIONTYPE  STRING  COMMENT  '',
  D_DEFINENAVDATE  STRING  COMMENT  '',
  C_ICDATA  STRING  COMMENT  '',
  F_DEFINEBREAKRATIO  DECIMAL(9,8)  COMMENT  ''
)
COMMENT '份额变化流水'
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  D_CDATE
                                   , C_CSERIALNO
                                   , C_BUSINFLAG
                                   , D_REQUESTDATE
                                   , C_REQUESTNO
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , F_OCCURSHARES
                                   , F_OCCURBALANCE
                                   , F_LASTSHARES
                                   , F_OCCURFREEZE
                                   , F_LASTFREEZESHARE
                                   , C_BONUSTYPE
                                   , C_CUSTTYPE
                                   , C_SHARECLASS
                                   , C_BOURSEFLAG
                                   , C_OUTBUSINFLAG
                                   , L_SERIALNO
                                   , C_ADJUSTCAUSE
                                   , C_SECONDACCO
                                   , C_SPECIALACCOFLAG
                                   , C_PARTNERID
                                   , C_CREDITACCOFLAG
                                   , D_SHAREVALIDDATE
                                   , C_FORCEREDEMPTIONTYPE
                                   , D_DEFINENAVDATE
                                   , C_ICDATA
                                   , F_DEFINEBREAKRATIO
                                FROM ${hszta_src_schema}.TSHARECURRENTS
                                WHERE D_CDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "D_REQUESTDATE", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "F_OCCURSHARES", "type": "DOUBLE"}, {"name": "F_OCCURBALANCE", "type": "DOUBLE"}, {"name": "F_LASTSHARES", "type": "DOUBLE"}, {"name": "F_OCCURFREEZE", "type": "DOUBLE"}, {"name": "F_LASTFREEZESHARE", "type": "DOUBLE"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_OUTBUSINFLAG", "type": "STRING"}, {"name": "L_SERIALNO", "type": "DOUBLE"}, {"name": "C_ADJUSTCAUSE", "type": "STRING"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_CREDITACCOFLAG", "type": "STRING"}, {"name": "D_SHAREVALIDDATE", "type": "STRING"}, {"name": "C_FORCEREDEMPTIONTYPE", "type": "STRING"}, {"name": "D_DEFINENAVDATE", "type": "STRING"}, {"name": "C_ICDATA", "type": "STRING"}, {"name": "F_DEFINEBREAKRATIO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tsharecurrents_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tsharecurrents_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tsharecurrents_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tsharecurrents_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TSHARECURRENTS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TSHARECURRENTS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tsharecurrents_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECURRENTS_PTD PARTITION(P_DT)
SELECT
       D_CDATE
     , C_CSERIALNO
     , C_BUSINFLAG
     , D_REQUESTDATE
     , C_REQUESTNO
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , F_OCCURSHARES
     , F_OCCURBALANCE
     , F_LASTSHARES
     , F_OCCURFREEZE
     , F_LASTFREEZESHARE
     , C_BONUSTYPE
     , C_CUSTTYPE
     , C_SHARECLASS
     , C_BOURSEFLAG
     , C_OUTBUSINFLAG
     , L_SERIALNO
     , C_ADJUSTCAUSE
     , C_SECONDACCO
     , C_SPECIALACCOFLAG
     , C_PARTNERID
     , C_CREDITACCOFLAG
     , D_SHAREVALIDDATE
     , C_FORCEREDEMPTIONTYPE
     , D_DEFINENAVDATE
     , C_ICDATA
     , F_DEFINEBREAKRATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_CDATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECURRENTS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECURRENTS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TSHARECURRENTS_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TSHARECURRENTS_PTD成功"
      exit 0
   fi
fi
