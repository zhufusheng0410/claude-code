#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TDIVIDENDDETAIL_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TDIVIDENDDETAIL_PTD_TMP(
  D_CDATE  STRING  COMMENT  '确认日期',
  C_CSERIALNO  STRING  COMMENT  'TA确认号',
  D_REGDATE  STRING  COMMENT  '分红登记日期',
  D_DATE  STRING  COMMENT  '发放日期',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  F_TOTALSHARE  DECIMAL(16,2)  COMMENT  '分红基数份额',
  F_UNITPROFIT  DECIMAL(7,4)  COMMENT  '每单位分红',
  F_TOTALPROFIT  DECIMAL(16,2)  COMMENT  '红利总额',
  F_TAX  DECIMAL(16,2)  COMMENT  '所得税',
  C_FLAG  STRING  COMMENT  '分红方式',
  F_REALBALANCE  DECIMAL(16,2)  COMMENT  '实发现金红利',
  F_REINVESTBALANCE  DECIMAL(16,2)  COMMENT  '再投资红利金额',
  F_REALSHARES  DECIMAL(16,2)  COMMENT  '再投资份额',
  F_FARE  DECIMAL(16,2)  COMMENT  '再投资费用',
  D_LASTDATE  STRING  COMMENT  '再投资处理日期',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '再投资单位净值',
  F_FROZENBALANCE  DECIMAL(16,2)  COMMENT  '冻结金额',
  F_FROZENSHARES  DECIMAL(16,2)  COMMENT  '冻结份额',
  F_INCOMETAX  DECIMAL(9,4)  COMMENT  '所得税率',
  C_RESERVE  STRING  COMMENT  '保留字段',
  D_REQUESTDATE  STRING  COMMENT  '再投资申请日',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  C_SENDTYPE  STRING  COMMENT  '',
  F_AHEADINCOME  DECIMAL(16,2)  COMMENT  '',
  C_TRADEACCOBAK  STRING  COMMENT  '',
  F_ACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_DEDUCT  DECIMAL(16,2)  COMMENT  '',
  C_SUBFUNDCODE  STRING  COMMENT  '',
  F_AGENCYFEE  DECIMAL(16,2)  COMMENT  '',
  F_TRANSFERFEE  DECIMAL(16,2)  COMMENT  '',
  F_OTHERFEE1  DECIMAL(16,2)  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  F_FLOORPROFIT  DECIMAL(10,9)  COMMENT  '',
  D_LASTARCHIVEDATE  STRING  COMMENT  '',
  F_DEDUCTPROTECT  DECIMAL(16,2)  COMMENT  '',
  C_DIVIDENDTYPE  STRING  COMMENT  '',
  C_ERRORDETAIL  STRING  COMMENT  '',
  C_DEDUCTFLAG  STRING  COMMENT  ''
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  D_CDATE
                                   , C_CSERIALNO
                                   , D_REGDATE
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , F_TOTALSHARE
                                   , F_UNITPROFIT
                                   , F_TOTALPROFIT
                                   , F_TAX
                                   , C_FLAG
                                   , F_REALBALANCE
                                   , F_REINVESTBALANCE
                                   , F_REALSHARES
                                   , F_FARE
                                   , D_LASTDATE
                                   , F_NETVALUE
                                   , F_FROZENBALANCE
                                   , F_FROZENSHARES
                                   , F_INCOMETAX
                                   , C_RESERVE
                                   , D_REQUESTDATE
                                   , C_SHARECLASS
                                   , C_SENDTYPE
                                   , F_AHEADINCOME
                                   , C_TRADEACCOBAK
                                   , F_ACCUMSHARES
                                   , F_DEDUCT
                                   , C_SUBFUNDCODE
                                   , F_AGENCYFEE
                                   , F_TRANSFERFEE
                                   , F_OTHERFEE1
                                   , C_SPECIALACCOFLAG
                                   , C_PARTNERID
                                   , F_FLOORPROFIT
                                   , D_LASTARCHIVEDATE
                                   , F_DEDUCTPROTECT
                                   , C_DIVIDENDTYPE
                                   , C_ERRORDETAIL
                                   , C_DEDUCTFLAG
                                FROM ${hsfta_src_schema}.TDIVIDENDDETAIL
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_CDATE", "type": "STRING"}, {"name": "C_CSERIALNO", "type": "STRING"}, {"name": "D_REGDATE", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "F_TOTALSHARE", "type": "DOUBLE"}, {"name": "F_UNITPROFIT", "type": "DOUBLE"}, {"name": "F_TOTALPROFIT", "type": "DOUBLE"}, {"name": "F_TAX", "type": "DOUBLE"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "F_REALBALANCE", "type": "DOUBLE"}, {"name": "F_REINVESTBALANCE", "type": "DOUBLE"}, {"name": "F_REALSHARES", "type": "DOUBLE"}, {"name": "F_FARE", "type": "DOUBLE"}, {"name": "D_LASTDATE", "type": "STRING"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "F_FROZENBALANCE", "type": "DOUBLE"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "F_INCOMETAX", "type": "DOUBLE"}, {"name": "C_RESERVE", "type": "STRING"}, {"name": "D_REQUESTDATE", "type": "STRING"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "C_SENDTYPE", "type": "STRING"}, {"name": "F_AHEADINCOME", "type": "DOUBLE"}, {"name": "C_TRADEACCOBAK", "type": "STRING"}, {"name": "F_ACCUMSHARES", "type": "DOUBLE"}, {"name": "F_DEDUCT", "type": "DOUBLE"}, {"name": "C_SUBFUNDCODE", "type": "STRING"}, {"name": "F_AGENCYFEE", "type": "DOUBLE"}, {"name": "F_TRANSFERFEE", "type": "DOUBLE"}, {"name": "F_OTHERFEE1", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "F_FLOORPROFIT", "type": "DOUBLE"}, {"name": "D_LASTARCHIVEDATE", "type": "STRING"}, {"name": "F_DEDUCTPROTECT", "type": "DOUBLE"}, {"name": "C_DIVIDENDTYPE", "type": "STRING"}, {"name": "C_ERRORDETAIL", "type": "STRING"}, {"name": "C_DEDUCTFLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tdividenddetail_ptd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tdividenddetail_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tdividenddetail_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tdividenddetail_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TDIVIDENDDETAIL_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TDIVIDENDDETAIL_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tdividenddetail_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TDIVIDENDDETAIL_PTD PARTITION(P_DT)
SELECT
       D_CDATE
     , C_CSERIALNO
     , D_REGDATE
     , D_DATE
     , C_FUNDACCO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , C_AGENCYNO
     , C_NETNO
     , F_TOTALSHARE
     , F_UNITPROFIT
     , F_TOTALPROFIT
     , F_TAX
     , C_FLAG
     , F_REALBALANCE
     , F_REINVESTBALANCE
     , F_REALSHARES
     , F_FARE
     , D_LASTDATE
     , F_NETVALUE
     , F_FROZENBALANCE
     , F_FROZENSHARES
     , F_INCOMETAX
     , C_RESERVE
     , D_REQUESTDATE
     , C_SHARECLASS
     , C_SENDTYPE
     , F_AHEADINCOME
     , C_TRADEACCOBAK
     , F_ACCUMSHARES
     , F_DEDUCT
     , C_SUBFUNDCODE
     , F_AGENCYFEE
     , F_TRANSFERFEE
     , F_OTHERFEE1
     , C_SPECIALACCOFLAG
     , C_PARTNERID
     , F_FLOORPROFIT
     , D_LASTARCHIVEDATE
     , F_DEDUCTPROTECT
     , C_DIVIDENDTYPE
     , C_ERRORDETAIL
     , C_DEDUCTFLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TDIVIDENDDETAIL_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TDIVIDENDDETAIL_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TDIVIDENDDETAIL_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TDIVIDENDDETAIL_PTD成功"
      exit 0
   fi
fi
