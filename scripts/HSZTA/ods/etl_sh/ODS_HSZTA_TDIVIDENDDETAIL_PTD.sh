#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TDIVIDENDDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TDIVIDENDDETAIL_PTD_TMP(
  D_REGDATE  STRING  COMMENT  '分红登记日期',
  D_CDATE  STRING  COMMENT  '确认日期',
  D_DATE  STRING  COMMENT  '发放日期',
  D_LASTDATE  STRING  COMMENT  '再投资处理日期',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  C_FLAG  STRING  COMMENT  '分红方式',
  F_TOTALSHARE  DECIMAL(16,2)  COMMENT  '分红基数份额',
  F_UNITPROFIT  DECIMAL(16,8)  COMMENT  '每单位分红',
  F_TOTALPROFIT  DECIMAL(16,2)  COMMENT  '红利总额',
  F_REALBALANCE  DECIMAL(16,2)  COMMENT  '实发现金红利',
  F_REINVESTBALANCE  DECIMAL(16,2)  COMMENT  '再投资红利金额',
  F_REALSHARES  DECIMAL(16,2)  COMMENT  '再投资份额',
  F_TAX  DECIMAL(16,2)  COMMENT  '所得税',
  F_FARE  DECIMAL(16,2)  COMMENT  '再投资费用',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '再投资单位净值',
  F_FROZENBALANCE  DECIMAL(16,2)  COMMENT  '冻结金额',
  F_FROZENSHARES  DECIMAL(16,2)  COMMENT  '冻结份额',
  F_SUMSHARES  DECIMAL(16,2)  COMMENT  '总份额',
  F_INCOMETAX  DECIMAL(7,4)  COMMENT  '所得税率',
  F_DEDUCTBALANCE  DECIMAL(16,2)  COMMENT  '扣除金额',
  C_IMPORTFLAG  STRING  COMMENT  '',
  C_RESERVE  STRING  COMMENT  '保留字段',
  C_SECONDACCO  STRING  COMMENT  '强增账户的二级账号',
  C_OUTFUNDCODE  STRING  COMMENT  '对外基金代码',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  C_SCHEMANO  STRING  COMMENT  '分红方案编号',
  C_ORICSERIALNO  STRING  COMMENT  '',
  F_PROFITBALANCE4AGT  DECIMAL(16,2)  COMMENT  '',
  C_CREDITACCOFLAG  STRING  COMMENT  '',
  C_CUSTTYPE  STRING  COMMENT  '',
  D_REGISTDATE  STRING  COMMENT  '',
  F_REALSHARESUM  DECIMAL(16,2)  COMMENT  '',
  L_BATCHNO  DECIMAL(2,0)  COMMENT  '',
  C_BONUSDETAIL  STRING  COMMENT  '',
  C_ISFUNDEND  STRING  COMMENT  '',
  F_PROFITBALANCE4ATTEND  DECIMAL(16,2)  COMMENT  '',
  D_ORIREGISTERDATE  STRING  COMMENT  '',
  D_ORIREINVESTDATE  STRING  COMMENT  '',
  C_ORISOURCETYPE  STRING  COMMENT  '',
  C_ISISSUEINTEREST  STRING  COMMENT  '',
  C_DTLREQUESTNO  STRING  COMMENT  '',
  C_BONUSFLAG  STRING  COMMENT  '',
  D_DTLCYCLEENDDATE  STRING  COMMENT  '',
  F_FLOATMANAGEFEE  DECIMAL(16,2)  COMMENT  '',
  C_ICDATA  STRING  COMMENT  '',
  D_INCSHAREDATE  STRING  COMMENT  '',
  F_PFTBAL2MACCO  DECIMAL(16,6)  COMMENT  '',
  D_DTLLASTDEDUCTDATE  STRING  COMMENT  ''
)
COMMENT '基金分红明细'
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
              "querySql": ["SELECT  D_REGDATE
                                   , D_CDATE
                                   , D_DATE
                                   , D_LASTDATE
                                   , C_CSERIALNO
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_SHARECLASS
                                   , C_FLAG
                                   , F_TOTALSHARE
                                   , F_UNITPROFIT
                                   , F_TOTALPROFIT
                                   , F_REALBALANCE
                                   , F_REINVESTBALANCE
                                   , F_REALSHARES
                                   , F_TAX
                                   , F_FARE
                                   , F_NETVALUE
                                   , F_FROZENBALANCE
                                   , F_FROZENSHARES
                                   , F_SUMSHARES
                                   , F_INCOMETAX
                                   , F_DEDUCTBALANCE
                                   , C_IMPORTFLAG
                                   , C_RESERVE
                                   , C_SECONDACCO
                                   , C_OUTFUNDCODE
                                   , C_SPECIALACCOFLAG
                                   , C_PARTNERID
                                   , C_SCHEMANO
                                   , C_ORICSERIALNO
                                   , F_PROFITBALANCE4AGT
                                   , C_CREDITACCOFLAG
                                   , C_CUSTTYPE
                                   , D_REGISTDATE
                                   , F_REALSHARESUM
                                   , L_BATCHNO
                                   , C_BONUSDETAIL
                                   , C_ISFUNDEND
                                   , F_PROFITBALANCE4ATTEND
                                   , D_ORIREGISTERDATE
                                   , D_ORIREINVESTDATE
                                   , C_ORISOURCETYPE
                                   , C_ISISSUEINTEREST
                                   , C_DTLREQUESTNO
                                   , C_BONUSFLAG
                                   , D_DTLCYCLEENDDATE
                                   , F_FLOATMANAGEFEE
                                   , C_ICDATA
                                   , D_INCSHAREDATE
                                   , F_PFTBAL2MACCO
                                   , D_DTLLASTDEDUCTDATE
                                FROM ${hszta_src_schema}.TDIVIDENDDETAIL
                                WHERE D_REGDATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_REGDATE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "D_LASTDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "F_TOTALSHARE", "type": "DOUBLE"}, {"name": "F_UNITPROFIT", "type": "DOUBLE"}, {"name": "F_TOTALPROFIT", "type": "DOUBLE"}, {"name": "F_REALBALANCE", "type": "DOUBLE"}, {"name": "F_REINVESTBALANCE", "type": "DOUBLE"}, {"name": "F_REALSHARES", "type": "DOUBLE"}, {"name": "F_TAX", "type": "DOUBLE"}, {"name": "F_FARE", "type": "DOUBLE"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_FROZENBALANCE", "type": "DOUBLE"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "F_SUMSHARES", "type": "DOUBLE"}, {"name": "F_INCOMETAX", "type": "DOUBLE"}, {"name": "F_DEDUCTBALANCE", "type": "DOUBLE"}, {"name": "C_IMPORTFLAG", "type": "STRING"}, {"name": "C_RESERVE", "type": "STRING"}, {"name": "C_SECONDACCO", "type": "STRING"}, {"name": "C_OUTFUNDCODE", "type": "STRING"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_SCHEMANO", "type": "STRING"}, {"name": "C_ORICSERIALNO", "type": "STRING"}, {"name": "F_PROFITBALANCE4AGT", "type": "DOUBLE"}, {"name": "C_CREDITACCOFLAG", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "D_REGISTDATE", "type": "STRING"}, {"name": "F_REALSHARESUM", "type": "DOUBLE"}, {"name": "L_BATCHNO", "type": "DOUBLE"}, {"name": "C_BONUSDETAIL", "type": "STRING"}, {"name": "C_ISFUNDEND", "type": "STRING"}, {"name": "F_PROFITBALANCE4ATTEND", "type": "DOUBLE"}, {"name": "D_ORIREGISTERDATE", "type": "STRING"}, {"name": "D_ORIREINVESTDATE", "type": "STRING"}, {"name": "C_ORISOURCETYPE", "type": "STRING"}, {"name": "C_ISISSUEINTEREST", "type": "STRING"}, {"name": "C_DTLREQUESTNO", "type": "STRING"}, {"name": "C_BONUSFLAG", "type": "STRING"}, {"name": "D_DTLCYCLEENDDATE", "type": "STRING"}, {"name": "F_FLOATMANAGEFEE", "type": "DOUBLE"}, {"name": "C_ICDATA", "type": "STRING"}, {"name": "D_INCSHAREDATE", "type": "STRING"}, {"name": "F_PFTBAL2MACCO", "type": "DOUBLE"}, {"name": "D_DTLLASTDEDUCTDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tdividenddetail_ptd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tdividenddetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tdividenddetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tdividenddetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TDIVIDENDDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TDIVIDENDDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tdividenddetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TDIVIDENDDETAIL_PTD PARTITION(P_DT)
SELECT
       D_REGDATE
     , D_CDATE
     , D_DATE
     , D_LASTDATE
     , C_CSERIALNO
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , C_SHARECLASS
     , C_FLAG
     , F_TOTALSHARE
     , F_UNITPROFIT
     , F_TOTALPROFIT
     , F_REALBALANCE
     , F_REINVESTBALANCE
     , F_REALSHARES
     , F_TAX
     , F_FARE
     , F_NETVALUE
     , F_FROZENBALANCE
     , F_FROZENSHARES
     , F_SUMSHARES
     , F_INCOMETAX
     , F_DEDUCTBALANCE
     , C_IMPORTFLAG
     , C_RESERVE
     , C_SECONDACCO
     , C_OUTFUNDCODE
     , C_SPECIALACCOFLAG
     , C_PARTNERID
     , C_SCHEMANO
     , C_ORICSERIALNO
     , F_PROFITBALANCE4AGT
     , C_CREDITACCOFLAG
     , C_CUSTTYPE
     , D_REGISTDATE
     , F_REALSHARESUM
     , L_BATCHNO
     , C_BONUSDETAIL
     , C_ISFUNDEND
     , F_PROFITBALANCE4ATTEND
     , D_ORIREGISTERDATE
     , D_ORIREINVESTDATE
     , C_ORISOURCETYPE
     , C_ISISSUEINTEREST
     , C_DTLREQUESTNO
     , C_BONUSFLAG
     , D_DTLCYCLEENDDATE
     , F_FLOATMANAGEFEE
     , C_ICDATA
     , D_INCSHAREDATE
     , F_PFTBAL2MACCO
     , D_DTLLASTDEDUCTDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , D_REGDATE P_DT
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TDIVIDENDDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TDIVIDENDDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TDIVIDENDDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TDIVIDENDDETAIL_PTD成功"
      exit 0
   fi
fi
