#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TSTATICSHARES_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSTATICSHARES_PFD_TMP(
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  F_REALSHARES  DECIMAL(16,2)  COMMENT  '份额余额',
  F_FROZENSHARES  DECIMAL(16,2)  COMMENT  '冻结份额',
  F_TRADEFREEZE  DECIMAL(16,2)  COMMENT  '交易冻结',
  F_LASTSHARES  DECIMAL(16,2)  COMMENT  'N天内到账份额',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  D_LASTMODIFY  STRING  COMMENT  '最后修改日期',
  F_INCOME  DECIMAL(16,2)  COMMENT  '未付收益',
  F_FROZENINCOME  DECIMAL(16,2)  COMMENT  '冻结未付收益',
  D_APPENDDATE  STRING  COMMENT  '记录新增日期',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  C_PRECLASS  STRING  COMMENT  '昨日份额级别',
  F_PREREALSHARES  DECIMAL(16,2)  COMMENT  '昨日份额',
  F_NEWINCOME  DECIMAL(16,2)  COMMENT  '当天新分配收益',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_NODEALGRADE  STRING  COMMENT  '是否参与升降级',
  F_FLOORINCOME  DECIMAL(10,9)  COMMENT  '收益分配截去的收益',
  F_PROTECTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_LASTINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_LASTACCUMSHARES  DECIMAL(16,2)  COMMENT  '',
  C_OLDCUSTFLAG  STRING  COMMENT  '',
  F_ASSIGNEDINCOME  DECIMAL(16,2)  COMMENT  '',
  F_SPLITSHARES  DECIMAL(16,2)  COMMENT  '',
  F_FLOORSHARES  DECIMAL(9,8)  COMMENT  '',
  F_SERVICEFARE  DECIMAL(16,2)  COMMENT  '销售服务费',
  F_NEWSERVICEFARE  DECIMAL(16,2)  COMMENT  '',
  F_BACKUPINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ORINEWINCOME  DECIMAL(16,2)  COMMENT  '',
  F_PAYBASEBALA  DECIMAL(16,2)  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '是否余额理财客户',
  F_ORIREALSHARESINCOME  DECIMAL(16,2)  COMMENT  '',
  F_EXCEPTINCOME  DECIMAL(16,2)  COMMENT  '',
  F_ORIINCOME  DECIMAL(16,2)  COMMENT  '',
  D_PAYTURNONDATE  STRING  COMMENT  '',
  C_EXCEPTINCOMEFLAG  STRING  COMMENT  '',
  F_INCOMEASSIGNBASE  DECIMAL(16,2)  COMMENT  '',
  F_BEFORESPLITSHARE  DECIMAL(16,2)  COMMENT  '',
  C_PARTNERID  STRING  COMMENT  '',
  C_DISTRIBUTEDINCOME  STRING  COMMENT  '',
  D_FIRSTINVESTDATE  STRING  COMMENT  '',
  F_FROZENNEWINCOME  DECIMAL(16,2)  COMMENT  '',
  D_PRELASTMODIFY  STRING  COMMENT  '',
  F_TOTALINCOME  DECIMAL(16,2)  COMMENT  '',
  F_DATUMSHARES  DECIMAL(16,2)  COMMENT  '',
  F_HISFLOORPROFIT  DECIMAL(9,8)  COMMENT  ''
)
COMMENT '静态份额表'
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
              "querySql": ["SELECT  C_FUNDACCO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , F_REALSHARES
                                   , F_FROZENSHARES
                                   , F_TRADEFREEZE
                                   , F_LASTSHARES
                                   , C_BONUSTYPE
                                   , D_LASTMODIFY
                                   , F_INCOME
                                   , F_FROZENINCOME
                                   , D_APPENDDATE
                                   , C_CUSTTYPE
                                   , C_SHARECLASS
                                   , C_PRECLASS
                                   , F_PREREALSHARES
                                   , F_NEWINCOME
                                   , C_BOURSEFLAG
                                   , C_NODEALGRADE
                                   , F_FLOORINCOME
                                   , F_PROTECTBALANCE
                                   , F_LASTINCOME
                                   , F_ACCUMSHARES
                                   , F_LASTACCUMSHARES
                                   , C_OLDCUSTFLAG
                                   , F_ASSIGNEDINCOME
                                   , F_SPLITSHARES
                                   , F_FLOORSHARES
                                   , F_SERVICEFARE
                                   , F_NEWSERVICEFARE
                                   , F_BACKUPINCOME
                                   , F_ORINEWINCOME
                                   , F_PAYBASEBALA
                                   , C_SPECIALACCOFLAG
                                   , F_ORIREALSHARESINCOME
                                   , F_EXCEPTINCOME
                                   , F_ORIINCOME
                                   , D_PAYTURNONDATE
                                   , C_EXCEPTINCOMEFLAG
                                   , F_INCOMEASSIGNBASE
                                   , F_BEFORESPLITSHARE
                                   , C_PARTNERID
                                   , C_DISTRIBUTEDINCOME
                                   , D_FIRSTINVESTDATE
                                   , F_FROZENNEWINCOME
                                   , D_PRELASTMODIFY
                                   , F_TOTALINCOME
                                   , F_DATUMSHARES
                                   , F_HISFLOORPROFIT
                                FROM ${hsfta_src_schema}.TSTATICSHARES"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "F_REALSHARES", "type": "DOUBLE"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "F_TRADEFREEZE", "type": "DOUBLE"}, {"name": "F_LASTSHARES", "type": "DOUBLE"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_FROZENINCOME", "type": "DOUBLE"}, {"name": "D_APPENDDATE", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "C_PRECLASS", "type": "STRING"}, {"name": "F_PREREALSHARES", "type": "DOUBLE"}, {"name": "F_NEWINCOME", "type": "DOUBLE"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_NODEALGRADE", "type": "STRING"}, {"name": "F_FLOORINCOME", "type": "DOUBLE"}, {"name": "F_PROTECTBALANCE", "type": "DOUBLE"}, {"name": "F_LASTINCOME", "type": "DOUBLE"}, {"name": "F_ACCUMSHARES", "type": "DOUBLE"}, {"name": "F_LASTACCUMSHARES", "type": "DOUBLE"}, {"name": "C_OLDCUSTFLAG", "type": "STRING"}, {"name": "F_ASSIGNEDINCOME", "type": "DOUBLE"}, {"name": "F_SPLITSHARES", "type": "DOUBLE"}, {"name": "F_FLOORSHARES", "type": "DOUBLE"}, {"name": "F_SERVICEFARE", "type": "DOUBLE"}, {"name": "F_NEWSERVICEFARE", "type": "DOUBLE"}, {"name": "F_BACKUPINCOME", "type": "DOUBLE"}, {"name": "F_ORINEWINCOME", "type": "DOUBLE"}, {"name": "F_PAYBASEBALA", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "F_ORIREALSHARESINCOME", "type": "DOUBLE"}, {"name": "F_EXCEPTINCOME", "type": "DOUBLE"}, {"name": "F_ORIINCOME", "type": "DOUBLE"}, {"name": "D_PAYTURNONDATE", "type": "STRING"}, {"name": "C_EXCEPTINCOMEFLAG", "type": "STRING"}, {"name": "F_INCOMEASSIGNBASE", "type": "DOUBLE"}, {"name": "F_BEFORESPLITSHARE", "type": "DOUBLE"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_DISTRIBUTEDINCOME", "type": "STRING"}, {"name": "D_FIRSTINVESTDATE", "type": "STRING"}, {"name": "F_FROZENNEWINCOME", "type": "DOUBLE"}, {"name": "D_PRELASTMODIFY", "type": "STRING"}, {"name": "F_TOTALINCOME", "type": "DOUBLE"}, {"name": "F_DATUMSHARES", "type": "DOUBLE"}, {"name": "F_HISFLOORPROFIT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tstaticshares_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tstaticshares_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tstaticshares_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tstaticshares_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TSTATICSHARES_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TSTATICSHARES_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tstaticshares_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSTATICSHARES_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDACCO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , C_AGENCYNO
     , C_NETNO
     , F_REALSHARES
     , F_FROZENSHARES
     , F_TRADEFREEZE
     , F_LASTSHARES
     , C_BONUSTYPE
     , D_LASTMODIFY
     , F_INCOME
     , F_FROZENINCOME
     , D_APPENDDATE
     , C_CUSTTYPE
     , C_SHARECLASS
     , C_PRECLASS
     , F_PREREALSHARES
     , F_NEWINCOME
     , C_BOURSEFLAG
     , C_NODEALGRADE
     , F_FLOORINCOME
     , F_PROTECTBALANCE
     , F_LASTINCOME
     , F_ACCUMSHARES
     , F_LASTACCUMSHARES
     , C_OLDCUSTFLAG
     , F_ASSIGNEDINCOME
     , F_SPLITSHARES
     , F_FLOORSHARES
     , F_SERVICEFARE
     , F_NEWSERVICEFARE
     , F_BACKUPINCOME
     , F_ORINEWINCOME
     , F_PAYBASEBALA
     , C_SPECIALACCOFLAG
     , F_ORIREALSHARESINCOME
     , F_EXCEPTINCOME
     , F_ORIINCOME
     , D_PAYTURNONDATE
     , C_EXCEPTINCOMEFLAG
     , F_INCOMEASSIGNBASE
     , F_BEFORESPLITSHARE
     , C_PARTNERID
     , C_DISTRIBUTEDINCOME
     , D_FIRSTINVESTDATE
     , F_FROZENNEWINCOME
     , D_PRELASTMODIFY
     , F_TOTALINCOME
     , F_DATUMSHARES
     , F_HISFLOORPROFIT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSTATICSHARES_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSTATICSHARES_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TSTATICSHARES_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TSTATICSHARES_PFD成功"
      exit 0
   fi
fi
