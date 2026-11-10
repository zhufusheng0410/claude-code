#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TACCONET_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TACCONET_PFD_TMP(
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_OPENFLAG  STRING  COMMENT  '开户网点标志',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_BANKNO  STRING  COMMENT  '交收行名称',
  C_BANKACCO  STRING  COMMENT  '交收行账号',
  C_NAMEINBANK  STRING  COMMENT  '交收行户名',
  D_APPENDDATE  STRING  COMMENT  '记录新增日期',
  C_CHILDNETNO  STRING  COMMENT  '操作网点编号',
  C_TRADEACCOBAK  STRING  COMMENT  '交易账号',
  C_SPECIALACCOFLAG  STRING  COMMENT  '是否特殊账号',
  C_SPECIALACCOID  STRING  COMMENT  '',
  C_HIFASFLAG  STRING  COMMENT  '是否定制账户',
  C_BROADCASTFLAG  STRING  COMMENT  '',
  C_ISENDOWACCO  STRING  COMMENT  '是否赋予账户',
  C_PARTNERID  STRING  COMMENT  '',
  C_ACCTNAMEOFCLEARINGAGENCY  STRING  COMMENT  '',
  C_ACCTNOOFCLEARINGAGENCY  STRING  COMMENT  '',
  C_CLEARINGAGENCY  STRING  COMMENT  ''
)
COMMENT '账号可交易网点'
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
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_OPENFLAG
                                   , C_BONUSTYPE
                                   , C_BANKNO
                                   , C_BANKACCO
                                   , C_NAMEINBANK
                                   , D_APPENDDATE
                                   , C_CHILDNETNO
                                   , C_TRADEACCOBAK
                                   , C_SPECIALACCOFLAG
                                   , C_SPECIALACCOID
                                   , C_HIFASFLAG
                                   , C_BROADCASTFLAG
                                   , C_ISENDOWACCO
                                   , C_PARTNERID
                                   , C_ACCTNAMEOFCLEARINGAGENCY
                                   , C_ACCTNOOFCLEARINGAGENCY
                                   , C_CLEARINGAGENCY
                                FROM ${hsfta_src_schema}.TACCONET"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_OPENFLAG", "type": "STRING"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_BANKACCO", "type": "STRING"}, {"name": "C_NAMEINBANK", "type": "STRING"}, {"name": "D_APPENDDATE", "type": "STRING"}, {"name": "C_CHILDNETNO", "type": "STRING"}, {"name": "C_TRADEACCOBAK", "type": "STRING"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_SPECIALACCOID", "type": "STRING"}, {"name": "C_HIFASFLAG", "type": "STRING"}, {"name": "C_BROADCASTFLAG", "type": "STRING"}, {"name": "C_ISENDOWACCO", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_ACCTNAMEOFCLEARINGAGENCY", "type": "STRING"}, {"name": "C_ACCTNOOFCLEARINGAGENCY", "type": "STRING"}, {"name": "C_CLEARINGAGENCY", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tacconet_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tacconet_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tacconet_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tacconet_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TACCONET_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TACCONET_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tacconet_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TACCONET_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_OPENFLAG
     , C_BONUSTYPE
     , C_BANKNO
     , C_BANKACCO
     , C_NAMEINBANK
     , D_APPENDDATE
     , C_CHILDNETNO
     , C_TRADEACCOBAK
     , C_SPECIALACCOFLAG
     , C_SPECIALACCOID
     , C_HIFASFLAG
     , C_BROADCASTFLAG
     , C_ISENDOWACCO
     , C_PARTNERID
     , C_ACCTNAMEOFCLEARINGAGENCY
     , C_ACCTNOOFCLEARINGAGENCY
     , C_CLEARINGAGENCY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TACCONET_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TACCONET_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TACCONET_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TACCONET_PFD成功"
      exit 0
   fi
fi
