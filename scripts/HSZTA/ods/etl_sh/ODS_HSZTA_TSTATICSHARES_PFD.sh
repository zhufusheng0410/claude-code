#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TSTATICSHARES_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSTATICSHARES_PFD_TMP(
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类别',
  F_REALSHARES  DECIMAL(16,2)  COMMENT  '份额余额',
  F_FROZENSHARES  DECIMAL(16,2)  COMMENT  '冻结份额',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  D_LASTMODIFY  STRING  COMMENT  '最后修改日期',
  F_INCOME  DECIMAL(16,2)  COMMENT  '未付收益',
  F_FROZENINCOME  DECIMAL(16,2)  COMMENT  '冻结未付收益',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  F_PROTECTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_NEWINCOME  DECIMAL(16,2)  COMMENT  '当天新分配收益',
  C_INVESTED  STRING  COMMENT  '',
  F_PRESPLITSHARES  DECIMAL(16,2)  COMMENT  '',
  F_PRESPLITINCOME  DECIMAL(16,2)  COMMENT  '',
  C_SPECIALACCOFLAG  STRING  COMMENT  '是否余额理财客户',
  F_ADJUSTBALANCE  DECIMAL(16,2)  COMMENT  '',
  F_FLOORINCOME  DECIMAL(10,9)  COMMENT  '收益分配截去的收益',
  C_PARTNERID  STRING  COMMENT  '',
  F_FUNDENDSHARE  DECIMAL(16,2)  COMMENT  '',
  F_FROZENNEWINCOME  DECIMAL(16,2)  COMMENT  '',
  F_YEBINVESTSHARES  DECIMAL(16,2)  COMMENT  '',
  C_YEBINVESTFLAG  STRING  COMMENT  '',
  D_FIRSTPCSDATE  STRING  COMMENT  '',
  F_MONTHINCOME  DECIMAL(16,2)  COMMENT  '',
  F_PREMONTHINCOME  DECIMAL(16,2)  COMMENT  '',
  F_CSERVICEFARE  DECIMAL(16,2)  COMMENT  '',
  D_FIRSTINVESTDATE  STRING  COMMENT  '',
  F_PREREALSHARES  DECIMAL(16,2)  COMMENT  '',
  F_PAYBASEBALA  DECIMAL(16,2)  COMMENT  '',
  C_CREDITACCOFLAG  STRING  COMMENT  '',
  F_PRESHARES_MGRINCOME  DECIMAL(16,2)  COMMENT  '',
  F_PREINCOME_MGRINCOME  DECIMAL(16,2)  COMMENT  '',
  F_BACKNEWINCOME  DECIMAL(16,2)  COMMENT  '',
  F_YEBPRESHARES  DECIMAL(16,2)  COMMENT  '',
  F_TOTALINCOME  DECIMAL(16,2)  COMMENT  '',
  F_LOCKBASESHARES  DECIMAL(16,2)  COMMENT  '',
  F_FLOORBOUNS  DECIMAL(10,9)  COMMENT  '',
  F_FROZENFLOORBOUNS  DECIMAL(10,9)  COMMENT  '',
  F_PAYBASEBALABAK  DECIMAL(16,2)  COMMENT  '',
  C_ICDATA  STRING  COMMENT  '',
  C_ISUPBONUSTYPE  STRING  COMMENT  ''
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , F_REALSHARES
                                   , F_FROZENSHARES
                                   , C_BONUSTYPE
                                   , D_LASTMODIFY
                                   , F_INCOME
                                   , F_FROZENINCOME
                                   , C_CUSTTYPE
                                   , C_SHARECLASS
                                   , C_BOURSEFLAG
                                   , F_PROTECTBALANCE
                                   , F_NEWINCOME
                                   , C_INVESTED
                                   , F_PRESPLITSHARES
                                   , F_PRESPLITINCOME
                                   , C_SPECIALACCOFLAG
                                   , F_ADJUSTBALANCE
                                   , F_FLOORINCOME
                                   , C_PARTNERID
                                   , F_FUNDENDSHARE
                                   , F_FROZENNEWINCOME
                                   , F_YEBINVESTSHARES
                                   , C_YEBINVESTFLAG
                                   , D_FIRSTPCSDATE
                                   , F_MONTHINCOME
                                   , F_PREMONTHINCOME
                                   , F_CSERVICEFARE
                                   , D_FIRSTINVESTDATE
                                   , F_PREREALSHARES
                                   , F_PAYBASEBALA
                                   , C_CREDITACCOFLAG
                                   , F_PRESHARES_MGRINCOME
                                   , F_PREINCOME_MGRINCOME
                                   , F_BACKNEWINCOME
                                   , F_YEBPRESHARES
                                   , F_TOTALINCOME
                                   , F_LOCKBASESHARES
                                   , F_FLOORBOUNS
                                   , F_FROZENFLOORBOUNS
                                   , F_PAYBASEBALABAK
                                   , C_ICDATA
                                   , C_ISUPBONUSTYPE
                                FROM ${hszta_src_schema}.TSTATICSHARES"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "F_REALSHARES", "type": "DOUBLE"}, {"name": "F_FROZENSHARES", "type": "DOUBLE"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "F_INCOME", "type": "DOUBLE"}, {"name": "F_FROZENINCOME", "type": "DOUBLE"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "F_PROTECTBALANCE", "type": "DOUBLE"}, {"name": "F_NEWINCOME", "type": "DOUBLE"}, {"name": "C_INVESTED", "type": "STRING"}, {"name": "F_PRESPLITSHARES", "type": "DOUBLE"}, {"name": "F_PRESPLITINCOME", "type": "DOUBLE"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "F_ADJUSTBALANCE", "type": "DOUBLE"}, {"name": "F_FLOORINCOME", "type": "DOUBLE"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "F_FUNDENDSHARE", "type": "DOUBLE"}, {"name": "F_FROZENNEWINCOME", "type": "DOUBLE"}, {"name": "F_YEBINVESTSHARES", "type": "DOUBLE"}, {"name": "C_YEBINVESTFLAG", "type": "STRING"}, {"name": "D_FIRSTPCSDATE", "type": "STRING"}, {"name": "F_MONTHINCOME", "type": "DOUBLE"}, {"name": "F_PREMONTHINCOME", "type": "DOUBLE"}, {"name": "F_CSERVICEFARE", "type": "DOUBLE"}, {"name": "D_FIRSTINVESTDATE", "type": "STRING"}, {"name": "F_PREREALSHARES", "type": "DOUBLE"}, {"name": "F_PAYBASEBALA", "type": "DOUBLE"}, {"name": "C_CREDITACCOFLAG", "type": "STRING"}, {"name": "F_PRESHARES_MGRINCOME", "type": "DOUBLE"}, {"name": "F_PREINCOME_MGRINCOME", "type": "DOUBLE"}, {"name": "F_BACKNEWINCOME", "type": "DOUBLE"}, {"name": "F_YEBPRESHARES", "type": "DOUBLE"}, {"name": "F_TOTALINCOME", "type": "DOUBLE"}, {"name": "F_LOCKBASESHARES", "type": "DOUBLE"}, {"name": "F_FLOORBOUNS", "type": "DOUBLE"}, {"name": "F_FROZENFLOORBOUNS", "type": "DOUBLE"}, {"name": "F_PAYBASEBALABAK", "type": "DOUBLE"}, {"name": "C_ICDATA", "type": "STRING"}, {"name": "C_ISUPBONUSTYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tstaticshares_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tstaticshares_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tstaticshares_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tstaticshares_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TSTATICSHARES_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TSTATICSHARES_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tstaticshares_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSTATICSHARES_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , F_REALSHARES
     , F_FROZENSHARES
     , C_BONUSTYPE
     , D_LASTMODIFY
     , F_INCOME
     , F_FROZENINCOME
     , C_CUSTTYPE
     , C_SHARECLASS
     , C_BOURSEFLAG
     , F_PROTECTBALANCE
     , F_NEWINCOME
     , C_INVESTED
     , F_PRESPLITSHARES
     , F_PRESPLITINCOME
     , C_SPECIALACCOFLAG
     , F_ADJUSTBALANCE
     , F_FLOORINCOME
     , C_PARTNERID
     , F_FUNDENDSHARE
     , F_FROZENNEWINCOME
     , F_YEBINVESTSHARES
     , C_YEBINVESTFLAG
     , D_FIRSTPCSDATE
     , F_MONTHINCOME
     , F_PREMONTHINCOME
     , F_CSERVICEFARE
     , D_FIRSTINVESTDATE
     , F_PREREALSHARES
     , F_PAYBASEBALA
     , C_CREDITACCOFLAG
     , F_PRESHARES_MGRINCOME
     , F_PREINCOME_MGRINCOME
     , F_BACKNEWINCOME
     , F_YEBPRESHARES
     , F_TOTALINCOME
     , F_LOCKBASESHARES
     , F_FLOORBOUNS
     , F_FROZENFLOORBOUNS
     , F_PAYBASEBALABAK
     , C_ICDATA
     , C_ISUPBONUSTYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TSTATICSHARES_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSTATICSHARES_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TSTATICSHARES_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TSTATICSHARES_PFD成功"
      exit 0
   fi
fi
