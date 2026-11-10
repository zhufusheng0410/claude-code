#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRMDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRMDETAIL_PTD_TMP(
  C_BUSINFLAG  STRING  COMMENT  '业务代码',
  D_CDATE  STRING  COMMENT  '确认日期',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  C_CSERIALNOTOTAL  STRING  COMMENT  '总确认号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  D_ORIGINALDATE  STRING  COMMENT  '份额原确认日期',
  C_ORICSERIALNO  STRING  COMMENT  '源确认单号',
  D_REGISTDATE  STRING  COMMENT  '份额注册日期',
  F_CONFBALANCE  DECIMAL(16,2)  COMMENT  '确认金额',
  F_CONFSHARES  DECIMAL(16,2)  COMMENT  '确认份额',
  F_TRADEFARE  DECIMAL(16,2)  COMMENT  '交易费',
  F_TAFARE  DECIMAL(16,2)  COMMENT  '过户费',
  F_STAMPTAX  DECIMAL(16,2)  COMMENT  '印花税',
  F_BACKFARE  DECIMAL(16,2)  COMMENT  '后收手续费',
  F_OTHERFARE1  DECIMAL(16,2)  COMMENT  '其他费用1',
  F_BREACHFARE  DECIMAL(16,2)  COMMENT  '违约金',
  F_PROFITBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_APPORTIONFARE  DECIMAL(16,2)  COMMENT  '后收费分摊费用',
  F_CHINCOME  DECIMAL(16,2)  COMMENT  '兑现的未付收益',
  F_ASSIGNEDINCOME  DECIMAL(16,2)  COMMENT  '当天分配收益',
  F_CONFIRMINCOME  DECIMAL(16,2)  COMMENT  '确认的未付收益',
  C_SECONDACCO  STRING  COMMENT  '强增账户的二级账号',
  F_FUNDFARE  DECIMAL(16,2)  COMMENT  '归基金资产费',
  F_FUNDFARERATIO  DECIMAL(5,4)  COMMENT  '',
  F_VALUEADDEDFARE  DECIMAL(16,2)  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  L_BATCHNO  DECIMAL(2,0)  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  L_HOLD  DECIMAL(16,2)  COMMENT  '',
  F_TRADERATIO  DECIMAL(9,8)  COMMENT  '',
  F_MANAGEFARE4CUST  DECIMAL(16,2)  COMMENT  '',
  F_MANAGEFARE4REGIST  DECIMAL(16,2)  COMMENT  '',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '',
  F_PFTREDRESSBAL  DECIMAL(16,2)  COMMENT  '',
  F_PROFITREDRESS  DECIMAL(16,2)  COMMENT  '',
  C_ORISOURCE  STRING  COMMENT  '',
  D_DEFINENAVDATE  STRING  COMMENT  '',
  F_SVRRETFARE  DECIMAL(16,2)  COMMENT  '',
  F_SVRRETFARE4CUST  DECIMAL(16,2)  COMMENT  '',
  F_SVRRETFARE4AGC  DECIMAL(16,2)  COMMENT  '',
  C_LASTEXITFLAG  STRING  COMMENT  '',
  C_TRDCSERIALNO  STRING  COMMENT  '',
  F_FLOATMANAGEFEE  DECIMAL(16,2)  COMMENT  '',
  F_DEFINEBREAKRATIO  DECIMAL(9,8)  COMMENT  ''
)
COMMENT '交易确认明细'
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
              "querySql": ["SELECT  C_BUSINFLAG
                                   , D_CDATE
                                   , C_CSERIALNO
                                   , C_CSERIALNOTOTAL
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , D_ORIGINALDATE
                                   , C_ORICSERIALNO
                                   , D_REGISTDATE
                                   , F_CONFBALANCE
                                   , F_CONFSHARES
                                   , F_TRADEFARE
                                   , F_TAFARE
                                   , F_STAMPTAX
                                   , F_BACKFARE
                                   , F_OTHERFARE1
                                   , F_BREACHFARE
                                   , F_PROFITBALANCE
                                   , F_APPORTIONFARE
                                   , F_CHINCOME
                                   , F_ASSIGNEDINCOME
                                   , F_CONFIRMINCOME
                                   , C_SECONDACCO
                                   , F_FUNDFARE
                                   , F_FUNDFARERATIO
                                   , F_VALUEADDEDFARE
                                   , C_SPECIALACCOFLAG
                                   , C_PARTNERID
                                   , L_BATCHNO
                                   , C_SUBFUNDCODE
                                   , L_HOLD
                                   , F_TRADERATIO
                                   , F_MANAGEFARE4CUST
                                   , F_MANAGEFARE4REGIST
                                   , F_NETVALUE
                                   , F_PFTREDRESSBAL
                                   , F_PROFITREDRESS
                                   , C_ORISOURCE
                                   , D_DEFINENAVDATE
                                   , F_SVRRETFARE
                                   , F_SVRRETFARE4CUST
                                   , F_SVRRETFARE4AGC
                                   , C_LASTEXITFLAG
                                   , C_TRDCSERIALNO
                                   , F_FLOATMANAGEFEE
                                   , F_DEFINEBREAKRATIO
                                FROM ${hszta_src_schema}.TCONFIRMDETAIL
                                WHERE D_CDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_BUSINFLAG", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_CSERIALNOTOTAL", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "D_ORIGINALDATE", "type": "STRING"}, {"name": "C_ORICSERIALNO", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "F_CONFBALANCE", "type": "DOUBLE"}, {"name": "F_CONFSHARES", "type": "DOUBLE"}, {"name": "F_TRADEFARE", "type": "DOUBLE"}, {"name": "F_TAFARE", "type": "DOUBLE"}, {"name": "F_STAMPTAX", "type": "DOUBLE"}, {"name": "F_BACKFARE", "type": "DOUBLE"}, {"name": "F_OTHERFARE1", "type": "DOUBLE"}, {"name": "F_BREACHFARE", "type": "DOUBLE"}, {"name": "F_PROFITBALANCE", "type": "DOUBLE"}, {"name": "F_APPORTIONFARE", "type": "DOUBLE"}, {"name": "F_CHINCOME", "type": "DOUBLE"}, {"name": "F_ASSIGNEDINCOME", "type": "DOUBLE"}, {"name": "F_CONFIRMINCOME", "type": "DOUBLE"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "F_FUNDFARE", "type": "DOUBLE"}, {"name": "F_FUNDFARERATIO", "type": "DOUBLE"}, {"name": "F_VALUEADDEDFARE", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "L_BATCHNO", "type": "DOUBLE"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "L_HOLD", "type": "DOUBLE"}, {"name": "F_TRADERATIO", "type": "DOUBLE"}, {"name": "F_MANAGEFARE4CUST", "type": "DOUBLE"}, {"name": "F_MANAGEFARE4REGIST", "type": "DOUBLE"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_PFTREDRESSBAL", "type": "DOUBLE"}, {"name": "F_PROFITREDRESS", "type": "DOUBLE"}, {"name": "C_ORISOURCE", "type": "STRING"}, {"name": "D_DEFINENAVDATE", "type": "STRING"}, {"name": "F_SVRRETFARE", "type": "DOUBLE"}, {"name": "F_SVRRETFARE4CUST", "type": "DOUBLE"}, {"name": "F_SVRRETFARE4AGC", "type": "DOUBLE"}, {"name": "C_LASTEXITFLAG", "type": "STRING"}, {"name": "C_TRDCSERIALNO", "type": "STRING"}, {"name": "F_FLOATMANAGEFEE", "type": "DOUBLE"}, {"name": "F_DEFINEBREAKRATIO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tconfirmdetail_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tconfirmdetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tconfirmdetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tconfirmdetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TCONFIRMDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TCONFIRMDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tconfirmdetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRMDETAIL_PTD PARTITION(P_DT)
SELECT
       C_BUSINFLAG
     , D_CDATE
     , C_CSERIALNO
     , C_CSERIALNOTOTAL
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , D_ORIGINALDATE
     , C_ORICSERIALNO
     , D_REGISTDATE
     , F_CONFBALANCE
     , F_CONFSHARES
     , F_TRADEFARE
     , F_TAFARE
     , F_STAMPTAX
     , F_BACKFARE
     , F_OTHERFARE1
     , F_BREACHFARE
     , F_PROFITBALANCE
     , F_APPORTIONFARE
     , F_CHINCOME
     , F_ASSIGNEDINCOME
     , F_CONFIRMINCOME
     , C_SECONDACCO
     , F_FUNDFARE
     , F_FUNDFARERATIO
     , F_VALUEADDEDFARE
     , C_SPECIALACCOFLAG
     , C_PARTNERID
     , L_BATCHNO
     , C_SUBFUNDCODE
     , L_HOLD
     , F_TRADERATIO
     , F_MANAGEFARE4CUST
     , F_MANAGEFARE4REGIST
     , F_NETVALUE
     , F_PFTREDRESSBAL
     , F_PROFITREDRESS
     , C_ORISOURCE
     , D_DEFINENAVDATE
     , F_SVRRETFARE
     , F_SVRRETFARE4CUST
     , F_SVRRETFARE4AGC
     , C_LASTEXITFLAG
     , C_TRDCSERIALNO
     , F_FLOATMANAGEFEE
     , F_DEFINEBREAKRATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_CDATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRMDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCONFIRMDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TCONFIRMDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TCONFIRMDETAIL_PTD成功"
      exit 0
   fi
fi
